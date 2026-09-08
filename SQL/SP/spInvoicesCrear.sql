DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spInvoicesCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spInvoicesCrear(
    p_data JSONB,
    p_acting_user_id INT,
    INOUT p_invoice_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_internal_number TEXT;
    v_invoice_id INT;
    v_item RECORD;
    v_tax RECORD;
    v_pax RECORD;
    v_var RECORD;
    v_combo RECORD;
    v_payment RECORD;
    v_itinerary RECORD;
    v_invoice_product_id INT;
    v_real_product_id INT;
    v_existing_invoice_number TEXT;
    v_temp_msg TEXT;
    v_decimals INT;
    v_fuente TEXT;
    v_serie TEXT;
    v_consecutivo TEXT;
    v_consec_id INT;
    v_next_num BIGINT;
    v_billing_code TEXT;
    v_branch_id INT;
    v_implant_id INT;
    v_resolution_id INT;
    v_res RECORD;
    v_res_rec RECORD;
    v_consec_json JSONB;
    v_fuente_val TEXT;
    v_serie_val TEXT;
    v_consec_val TEXT;
    v_consec_num BIGINT;
BEGIN
    -- ----------------------------------------------------
    -- FASE 1: PRE-VALIDACIONES OBLIGATORIAS (Síncrona sin modificar BD)
    -- ----------------------------------------------------
    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La factura debe tener al menos un producto.';
        RETURN;
    END IF;

    v_branch_id := NULLIF(p_data->>'branchId', '')::INT;
    v_implant_id := NULLIF(p_data->>'implantId', '')::INT;

    -- Obtener decimales de la moneda
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    v_resolution_id := NULLIF(p_data->>'resolutionId', '')::INT;

    v_internal_number := 'INV-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 1000)::text;

    v_fuente := NULLIF(p_data->>'fuente', '');
    v_serie := NULLIF(p_data->>'serie', '');
    v_consecutivo := NULLIF(p_data->>'consecutivo', '');

    -- Lógica de asignación de consecutivo automático desde SysConsecutivo si consecutivo es nulo o vacío
    IF v_consecutivo IS NULL THEN
        v_billing_code := COALESCE(
            NULLIF(p_data->>'codigo', ''), 
            NULLIF(p_data->>'codigoFacturacion', ''), 
            NULLIF(p_data->>'billingCode', ''), 
            v_fuente, 
            'FACT'
        );

        SELECT id, NULLIF(fuente, ''), NULLIF(serie, '') 
        INTO v_consec_id, v_fuente, v_serie
        FROM public."SysConsecutivo"
        WHERE LOWER(codigo) = LOWER(v_billing_code)
           OR (v_branch_id IS NOT NULL AND "branchId" = v_branch_id AND ("implantId" IS NULL OR "implantId" = v_implant_id))
        ORDER BY 
            (CASE WHEN LOWER(codigo) = LOWER(v_billing_code) THEN 1 ELSE 2 END),
            (CASE WHEN "implantId" IS NOT NULL THEN 1 WHEN "branchId" IS NOT NULL THEN 2 ELSE 3 END),
            id DESC
        LIMIT 1;

        IF v_consec_id IS NOT NULL THEN
            UPDATE public."SysConsecutivo"
            SET consecutivo = consecutivo + 1,
                "updatedAt" = CURRENT_TIMESTAMP
            WHERE id = v_consec_id
            RETURNING consecutivo INTO v_next_num;

            v_consecutivo := LPAD(v_next_num::TEXT, 8, '0');
        ELSE
            SELECT COALESCE(MAX(consecutivo::BIGINT), 0) + 1 INTO v_next_num 
            FROM public."Invoices" 
            WHERE consecutivo ~ '^[0-9]+$';

            v_consecutivo := LPAD(v_next_num::TEXT, 8, '0');
        END IF;
    END IF;

    -- Resolución y Validación de Rango de Numeración
    IF v_resolution_id IS NULL AND v_implant_id IS NOT NULL THEN
        SELECT "resolutionId" INTO v_resolution_id FROM public."Implant" WHERE id = v_implant_id;
    END IF;

    IF v_resolution_id IS NULL AND v_branch_id IS NOT NULL THEN
        SELECT "resolutionId" INTO v_resolution_id FROM public."Branch" WHERE id = v_branch_id;
    END IF;

    IF v_resolution_id IS NULL AND v_serie IS NOT NULL THEN
        SELECT id INTO v_resolution_id FROM public."Resolution" WHERE activo = TRUE AND prefijo ILIKE v_serie ORDER BY id DESC LIMIT 1;
    END IF;

    IF v_resolution_id IS NULL THEN
        SELECT id INTO v_resolution_id FROM public."Resolution" WHERE activo = TRUE ORDER BY id DESC LIMIT 1;
    END IF;

    IF v_resolution_id IS NOT NULL THEN
        SELECT * INTO v_res FROM public."Resolution" WHERE id = v_resolution_id;

        IF v_res.id IS NOT NULL THEN
            -- 1. Validar estado de la resolución
            IF v_res.activo IS FALSE THEN
                p_mensaje_resultado := 'ERROR: La resolución de facturación "' || v_res.name || '" (' || v_res.code || ') se encuentra inactiva.';
                RETURN;
            END IF;

            -- 2. Validar vigencia / expiración de la resolución
            IF v_res.expira IS NOT NULL AND v_res.expira::DATE < CURRENT_DATE THEN
                IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                    p_mensaje_resultado := 'ERROR: La resolución de facturación "' || v_res.name || '" (' || v_res.code || ') se encuentra vencida desde el ' || to_char(v_res.expira, 'YYYY-MM-DD') || '.';
                    RETURN;
                END IF;
            END IF;

            -- 3. Validar rango numérico autorizado del consecutivo
            IF v_consecutivo IS NOT NULL AND v_consecutivo ~ '^[0-9]+$' THEN
                v_consec_num := v_consecutivo::BIGINT;

                IF v_res.inicial IS NOT NULL AND v_consec_num < v_res.inicial THEN
                    IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                        p_mensaje_resultado := 'ERROR: El consecutivo generado (' || v_consec_num || ') es menor al rango inicial autorizado (' || v_res.inicial || ') para la resolución "' || v_res.name || '".';
                        RETURN;
                    END IF;
                END IF;

                IF v_res."end" IS NOT NULL AND v_consec_num > v_res."end" THEN
                    IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                        p_mensaje_resultado := 'ERROR: El consecutivo generado (' || v_consec_num || ') supera el rango final autorizado (' || v_res."end" || ') para la resolución "' || v_res.name || '".';
                        RETURN;
                    END IF;
                END IF;
            END IF;

            -- 4. Asignar prefijo de resolución a la serie si no fue provisto
            IF v_serie IS NULL AND NULLIF(v_res.prefijo, '') IS NOT NULL THEN
                v_serie := v_res.prefijo;
            END IF;
        END IF;
    END IF;

    -- 5. Validar unicidad del consecutivo (evitar duplicidad)
    IF v_consecutivo IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM public."Invoices"
            WHERE consecutivo = v_consecutivo
              AND COALESCE(serie, '') = COALESCE(v_serie, '')
              AND COALESCE(fuente, '') = COALESCE(v_fuente, '')
        ) THEN
            p_mensaje_resultado := 'ERROR: Ya existe una factura emitida con la numeración ' || COALESCE(v_fuente || '-', '') || COALESCE(v_serie || '-', '') || v_consecutivo || '.';
            RETURN;
        END IF;
    END IF;

    -- Pre-validar items (Productos, tiquetes duplicados, productos al vuelo)
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                      "serviceType" TEXT
                  )
    LOOP
        v_real_product_id := NULL;
        IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' THEN
            SELECT id INTO v_real_product_id FROM public."Product" WHERE code = v_item."ticketCode";
        ELSE
            v_real_product_id := v_item."productId";
        END IF;

        -- Si no hay productId ni ticketCode válido
        IF v_real_product_id IS NULL AND (v_item."ticketCode" IS NULL OR TRIM(v_item."ticketCode") = '') THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            RETURN;
        END IF;

        -- Validación de Unicidad para Número de Tiquete / Voucher (ticketCode)
        IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
            SELECT inv."internalNumber" INTO v_existing_invoice_number
            FROM public."InvoicesProduct" ip
            JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
            WHERE ip."ticketCode" = TRIM(v_item."ticketCode")
            LIMIT 1;

            IF v_existing_invoice_number IS NOT NULL THEN
                p_mensaje_resultado := 'ERROR: El tiquete N° ' || TRIM(v_item."ticketCode") || ' ya está facturado en la factura ' || v_existing_invoice_number;
                RETURN;
            END IF;
        END IF;
    END LOOP;

    -- Buscar Resolución de Documentos Activa para la Sucursal e Implante
    SELECT * INTO v_res_rec
    FROM public."DocumentResolution"
    WHERE ("branchId" IS NULL OR "branchId" = v_branch_id)
      AND (
          (v_implant_id IS NOT NULL AND "implantId" = v_implant_id)
          OR ("implantId" IS NULL)
      )
      AND "isActive" = true
    ORDER BY CASE WHEN "branchId" = v_branch_id THEN 1 ELSE 2 END,
             CASE WHEN "implantId" = v_implant_id THEN 1 ELSE 2 END
    LIMIT 1
    FOR UPDATE;

    IF v_res_rec.id IS NOT NULL THEN
        -- Validar Vencimiento de la Resolución
        IF v_res_rec."expirationDate" IS NOT NULL AND v_res_rec."expirationDate" < CURRENT_DATE THEN
            p_mensaje_resultado := 'ERROR: La resolución N° ' || COALESCE(v_res_rec."resolutionNumber", '') || ' asignada a la sucursal venció el ' || to_char(v_res_rec."expirationDate", 'DD/MM/YYYY') || '.';
            RETURN;
        END IF;

        -- Validar Rango Final de Numeración
        IF v_res_rec."currentNumber" > v_res_rec."finalNumber" THEN
            p_mensaje_resultado := 'ERROR: La resolución N° ' || COALESCE(v_res_rec."resolutionNumber", '') || ' ha superado la numeración máxima autorizada (' || v_res_rec."finalNumber"::text || ').';
            RETURN;
        END IF;
    END IF;

    -- ----------------------------------------------------
    -- FASE 2: EJECUCIÓN TRANSACCIONAL PROTEGIDA CON ROLLBACK AUTOMÁTICO
    -- ----------------------------------------------------
    BEGIN
        IF v_res_rec.id IS NOT NULL THEN
            v_serie_val := COALESCE(NULLIF(p_data->>'serie', ''), v_res_rec.prefix);
            IF NULLIF(p_data->>'consecutivo', '') IS NOT NULL THEN
                v_consec_val := p_data->>'consecutivo';
            ELSE
                v_consec_val := v_res_rec."currentNumber"::text;
                -- Incrementar consecutivo actual en la resolución activa
                UPDATE public."DocumentResolution"
                SET "currentNumber" = "currentNumber" + 1
                WHERE id = v_res_rec.id;
            END IF;
        ELSE
            -- Fallback a Maestro de Consecutivos de Transacciones
            IF NULLIF(p_data->>'consecutivo', '') IS NOT NULL THEN
                v_consec_val := p_data->>'consecutivo';
                v_serie_val := NULLIF(p_data->>'serie', '');
            ELSE
                v_consec_json := public."fnObtenerSiguienteConsecutivo"('INVOICE', v_branch_id, v_implant_id);
                v_consec_val := v_consec_json->>'consecutivoNumber';
                v_serie_val := COALESCE(NULLIF(p_data->>'serie', ''), NULLIF(v_consec_json->>'prefix', ''));
            END IF;
        END IF;

        -- Construir internalNumber sin anteponer prefijo si este es nulo o vacío
        v_internal_number := CASE 
            WHEN v_serie_val IS NOT NULL AND TRIM(v_serie_val) <> '' THEN v_serie_val || '-' || v_consec_val 
            ELSE v_consec_val 
        END;

        v_fuente_val := COALESCE(NULLIF(p_data->>'fuente', ''), 'FE');

        -- Inserción de la Factura Cabecera
        INSERT INTO public."Invoices" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", 
            "totalAmount", "userId", "state", "fuente", "serie", "consecutivo"
        ) VALUES (
            v_internal_number, CURRENT_TIMESTAMP, NULLIF(p_data->>'clientId', '')::INT, p_data->>'currency', COALESCE(NULLIF(p_data->>'exchangeRate', '')::FLOAT, 1.0),
            v_branch_id, v_implant_id, NULLIF(p_data->>'sellerId', '')::INT, NULLIF(p_data->>'ticketPrinterId', '')::INT,
            0, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::FLOAT, 0.0), COALESCE(ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision, 0.0),
            COALESCE(ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision, 0.0), p_acting_user_id, 'NUEVO',
            v_fuente_val, v_serie_val, v_consec_val
        ) RETURNING id INTO v_invoice_id;

        FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
        LOOP
            INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId")
            VALUES (v_invoice_id, COALESCE(v_combo."comboId", v_combo.id));
        END LOOP;

        FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                          "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                          quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                          "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                          "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                          "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                          "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "inNationality" INT,
                          "servicios" TEXT, "itemDescription" TEXT, "itinerary" TEXT, "class" TEXT, "airline" TEXT, "ticketTypeId" TEXT, "payments" JSONB, "itinerariesItineraryList" JSONB
                      )
        LOOP
            -- 1. Lógica de Producto Al Vuelo
            IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' THEN
                SELECT id INTO v_real_product_id FROM public."Product" WHERE code = v_item."ticketCode";
                
                IF v_real_product_id IS NULL THEN
                    CALL public.spProductoCrear(
                        v_item."ticketCode",
                        COALESCE(v_item."type", 'Tiquete'),
                        COALESCE(v_item."description", 'Tiquete ' || v_item."ticketCode"),
                        COALESCE(v_item.price, 0),
                        COALESCE(v_item.cost, 0),
                        NULL, 
                        COALESCE(v_item."serviceType", 'Aire'),
                        p_acting_user_id,
                        v_real_product_id,
                        v_temp_msg
                    );
                    IF v_temp_msg LIKE 'ERROR%' THEN
                        RAISE EXCEPTION '%', v_temp_msg;
                    END IF;
                END IF;
            ELSE
                v_real_product_id := v_item."productId";
            END IF;

            IF v_real_product_id IS NULL THEN
                RAISE EXCEPTION 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            END IF;

            -- 1.5 Validación de Unicidad para Número de Tiquete / Voucher (ticketCode)
            IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
                SELECT inv."internalNumber" INTO v_existing_invoice_number
                FROM public."InvoicesProduct" ip
                JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
                WHERE ip."ticketCode" = TRIM(v_item."ticketCode")
                LIMIT 1;

                IF v_existing_invoice_number IS NOT NULL THEN
                    RAISE EXCEPTION 'ERROR: El tiquete N° % ya está facturado en la factura %', TRIM(v_item."ticketCode"), v_existing_invoice_number;
                END IF;
            END IF;

            -- 2. Inserción de Producto
            INSERT INTO public."InvoicesProduct" (
                "invoiceId", "productId", "ticketCode", "quantity", "price", "cost", "providerId", "prestadoraId",
                "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
                "serviceType", "destination", "reservationCode", "sellerCommission", 
                "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
                "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
            ) VALUES (
                v_invoice_id, v_real_product_id, NULLIF(TRIM(v_item."ticketCode"), ''), v_item.quantity, 
                ROUND(v_item.price::numeric, v_decimals)::double precision, 
                ROUND(v_item.cost::numeric, v_decimals)::double precision, 
                NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
                CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
                CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
                v_item.nights, v_item."paxAdults", v_item."paxChildren",
                v_item."serviceType", v_item."destination", v_item."reservationCode", 
                ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
                ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
                NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
                v_item."servicios", COALESCE(v_item."itemDescription", v_item."description"), v_item."itinerary", v_item."class", v_item."airline", NULLIF(v_item."ticketTypeId", '')::INT
            ) RETURNING id INTO v_invoice_product_id;

            IF v_item.passengers IS NOT NULL THEN
                FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                    VALUES (v_invoice_product_id, v_pax.name, v_pax.document);
                END LOOP;
            END IF;

            IF v_item."appliedTaxes" IS NOT NULL THEN
                FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
                LOOP
                    INSERT INTO public."InvoicesProductTax" (
                        "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                    )
                    SELECT v_invoice_product_id, ct.id, ct.value, ct."valueType", 
                           ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                           CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                    FROM public."ChargeAndTax" ct
                    WHERE ct.id = v_tax."chargeAndTaxId";
                END LOOP;
            END IF;

            IF v_item.variables IS NOT NULL THEN
                FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                    VALUES (v_invoice_product_id, v_var."masterVariableId", v_var.value);
                END LOOP;
            END IF;

            IF v_item.payments IS NOT NULL THEN
                FOR v_payment IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(amount FLOAT, "paymentMethod" TEXT, "reference" TEXT, "date" TEXT, "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductPayment" ("invoiceProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
                    VALUES (
                        v_invoice_product_id, 
                        ROUND(v_payment.amount::numeric, v_decimals)::double precision, 
                        v_payment."paymentMethod", v_payment.reference, 
                        CASE WHEN v_payment."date" IS NOT NULL AND v_payment."date" <> '' THEN v_payment."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END, 
                        v_payment."creditCardId", v_payment."cardNumber", v_payment."authorizationCode", v_payment."voucher", v_payment."expirationDate"
                    );
                END LOOP;
            END IF;

            IF v_item."itinerariesItineraryList" IS NOT NULL THEN
                FOR v_itinerary IN SELECT * FROM jsonb_to_recordset(v_item."itinerariesItineraryList") AS x(origin TEXT, destination TEXT, class TEXT, "checkInDate" TEXT, "checkOutDate" TEXT, "prestadoraCode" TEXT, "farebasis" TEXT, "Numflight" TEXT, "Typeflight" TEXT, "amount" FLOAT, "co2" NUMERIC, orden INT)
                LOOP
                    INSERT INTO public."InvoicesProductItinerary" ("invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount", "co2", "orden")
                    VALUES (
                        v_invoice_product_id, v_itinerary.origin, v_itinerary.destination, v_itinerary.class, 
                        CASE WHEN v_itinerary."checkInDate" IS NOT NULL AND v_itinerary."checkInDate" <> '' THEN v_itinerary."checkInDate"::TIMESTAMP ELSE NULL END, 
                        CASE WHEN v_itinerary."checkOutDate" IS NOT NULL AND v_itinerary."checkOutDate" <> '' THEN v_itinerary."checkOutDate"::TIMESTAMP ELSE NULL END, 
                        COALESCE(v_itinerary."prestadoraCode", ''), COALESCE(v_itinerary."farebasis", ''), v_itinerary."Numflight", v_itinerary."Typeflight", 
                        ROUND(COALESCE(v_itinerary."amount", 0)::numeric, v_decimals)::double precision, 
                        v_itinerary."co2", v_itinerary.orden
                    );
                END LOOP;
            END IF;

        END LOOP;

        -- Calcular y actualizar el totalAmount basado en impuestos si aplica
        UPDATE public."Invoices"
        SET "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
            SELECT COALESCE(SUM(ipt."explicitAmount"), 0)
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = v_invoice_id
        ))::numeric, v_decimals)::double precision
        WHERE id = v_invoice_id;

        p_invoice_id := v_invoice_id;
        p_mensaje_resultado := 'SUCCESS: Factura creada correctamente con ID ' || v_invoice_id;

    EXCEPTION
        WHEN OTHERS THEN
            p_invoice_id := NULL;
            p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
END;
$$;
