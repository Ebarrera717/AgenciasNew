DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spInvoicesActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spInvoicesActualizar(
    p_id INT,
    p_data JSONB,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
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
    -- Variables para validación de variables obligatorias específicas del cliente
    v_client_id INT;
    v_client_mandatory_vars JSONB;
    v_client_var_id_text TEXT;
    v_req_var_id INT;
    v_req_var_name TEXT;
    v_item_json JSONB;
    v_item_prod_id INT;
    v_item_prod_desc TEXT;
    v_has_var BOOLEAN;
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM public."Invoices" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: La factura con ID ' || p_id || ' no existe.';
        RETURN;
    END IF;

    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La factura debe tener al menos un producto.';
        RETURN;
    END IF;

    -- Validación de variables obligatorias específicas del cliente para Facturas
    v_client_id := NULLIF(p_data->>'clientId', '')::INT;
    IF v_client_id IS NOT NULL THEN
        SELECT "mandatoryVariables" INTO v_client_mandatory_vars
        FROM public."Client"
        WHERE id = v_client_id;

        IF v_client_mandatory_vars IS NOT NULL THEN
            IF jsonb_typeof(v_client_mandatory_vars) = 'object' AND v_client_mandatory_vars ? 'invoice' AND jsonb_typeof(v_client_mandatory_vars->'invoice') = 'array' THEN
                v_client_mandatory_vars := v_client_mandatory_vars->'invoice';
            ELSIF jsonb_typeof(v_client_mandatory_vars) = 'object' AND v_client_mandatory_vars ? 'invoices' AND jsonb_typeof(v_client_mandatory_vars->'invoices') = 'array' THEN
                v_client_mandatory_vars := v_client_mandatory_vars->'invoices';
            ELSE
                v_client_mandatory_vars := '[]'::JSONB;
            END IF;
        END IF;

        IF v_client_mandatory_vars IS NOT NULL AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN
            FOR v_client_var_id_text IN SELECT jsonb_array_elements_text(v_client_mandatory_vars)
            LOOP
                v_req_var_id := v_client_var_id_text::INT;
                
                SELECT "name" INTO v_req_var_name FROM public."MasterVariable" WHERE id = v_req_var_id;
                v_req_var_name := COALESCE(v_req_var_name, 'Variable #' || v_req_var_id);

                FOR v_item_json IN SELECT jsonb_array_elements(p_data->'items')
                LOOP
                    v_item_prod_id := NULLIF(v_item_json->>'productId', '')::INT;
                    IF v_item_prod_id IS NOT NULL THEN
                        SELECT "description" INTO v_item_prod_desc FROM public."Product" WHERE id = v_item_prod_id;
                    ELSE
                        v_item_prod_desc := NULL;
                    END IF;
                    v_item_prod_desc := COALESCE(v_item_prod_desc, COALESCE(v_item_json->>'description', COALESCE(v_item_json->>'itemDescription', COALESCE(v_item_json->>'ticketCode', 'Producto #' || COALESCE(v_item_prod_id::TEXT, '1')))));

                    SELECT EXISTS (
                        SELECT 1 FROM jsonb_to_recordset(v_item_json->'variables') AS v("masterVariableId" INT, value TEXT)
                        WHERE v."masterVariableId" = v_req_var_id AND NULLIF(trim(v.value), '') IS NOT NULL
                    ) INTO v_has_var;

                    IF NOT v_has_var THEN
                        p_mensaje_resultado := 'ERROR: El cliente requiere completar la variable adicional "' || v_req_var_name || '" en el producto "' || v_item_prod_desc || '".';
                        RETURN;
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
    END IF;

    -- Obtener decimales de la moneda
    v_decimals := COALESCE(public.fn_obtener_decimales_moneda(p_data->>'currency'), 2);

    UPDATE public."Invoices" SET
        "clientId" = NULLIF(p_data->>'clientId', '')::INT,
        "currency" = p_data->>'currency',
        "exchangeRate" = NULLIF(p_data->>'exchangeRate', '')::FLOAT,
        "branchId" = NULLIF(p_data->>'branchId', '')::INT,
        "implantId" = NULLIF(p_data->>'implantId', '')::INT,
        "sellerId" = NULLIF(p_data->>'sellerId', '')::INT,
        "ticketPrinterId" = NULLIF(p_data->>'ticketPrinterId', '')::INT,
        "commissionPercentage" = NULLIF(p_data->>'commissionPercentage', '')::FLOAT,
        "chargesAndTaxes" = COALESCE(ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision, 0.0),
        "totalAmount" = COALESCE(ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision, 0.0),
        "state" = COALESCE(p_data->>'state', 'Nuevo'),
        "date" = CURRENT_TIMESTAMP,
        "fuente" = NULLIF(p_data->>'fuente', ''),
        "serie" = NULLIF(p_data->>'serie', ''),
        "consecutivo" = NULLIF(p_data->>'consecutivo', '')
    WHERE id = p_id;

    DELETE FROM public."InvoicesProductCombo" WHERE "invoiceId" = p_id;
    FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
    LOOP
        INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId")
        VALUES (p_id, COALESCE(v_combo."comboId", v_combo.id));
    END LOOP;

    DELETE FROM public."InvoicesProductItinerary" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = p_id);
    DELETE FROM public."InvoicesProductPayment" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = p_id);
    DELETE FROM public."InvoicesProduct" WHERE "invoiceId" = p_id;
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                      quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                      "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                      "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                      "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                      "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "inNationality" INT,
                      "servicios" TEXT, "itemDescription" TEXT, "itinerary" TEXT, "class" TEXT, "airline" TEXT, "ticketTypeId" TEXT, "payments" JSONB, "itinerariesItineraryList" JSONB,
                      "providerDueDate" TEXT, "providerInvoice" TEXT
                  )
    LOOP
        -- 1. Lógica de Producto Al Vuelo
        IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL THEN
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
                    p_mensaje_resultado := v_temp_msg;
                    RETURN;
                END IF;
            END IF;
        ELSE
            v_real_product_id := v_item."productId";
        END IF;

        IF v_real_product_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            RETURN;
        END IF;

        -- 2. Validación de Unicidad para Aire/Tiquete por número de tiquete (ticketCode)
        IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
            SELECT inv."internalNumber" INTO v_existing_invoice_number
            FROM public."InvoicesProduct" ip
            JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
            WHERE ip."ticketCode" = TRIM(v_item."ticketCode") AND inv.id <> p_id
            LIMIT 1;

            IF v_existing_invoice_number IS NOT NULL THEN
                p_mensaje_resultado := 'ERROR: El tiquete N° ' || TRIM(v_item."ticketCode") || ' ya está facturado en la factura ' || v_existing_invoice_number;
                RETURN;
            END IF;
        END IF;

        -- 3. Inserción de Producto
        INSERT INTO public."InvoicesProduct" (
            "invoiceId", "productId", "ticketCode", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission", 
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId",
            "providerDueDate", "providerInvoice"
        ) VALUES (
            p_id, v_real_product_id, NULLIF(TRIM(v_item."ticketCode"), ''), COALESCE(v_item.quantity, 1), 
            COALESCE(ROUND(v_item.price::numeric, v_decimals)::double precision, 0), 
            COALESCE(ROUND(v_item.cost::numeric, v_decimals)::double precision, 0), 
            NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
            CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
            CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
            v_item.nights, v_item."paxAdults", v_item."paxChildren",
            v_item."serviceType", v_item."destination", v_item."reservationCode", 
            ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
            ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
            NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
            v_item."servicios", COALESCE(v_item."itemDescription", v_item."description"), v_item."itinerary", v_item."class", v_item."airline", NULLIF(v_item."ticketTypeId", '')::INT,
            CASE WHEN v_item."providerDueDate" IS NOT NULL AND v_item."providerDueDate" <> '' THEN v_item."providerDueDate"::TIMESTAMP ELSE NULL END,
            v_item."providerInvoice"
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

    -- Calcular y actualizar el totalAmount
    UPDATE public."Invoices"
    SET "totalAmount" = ROUND((
        COALESCE((
            SELECT SUM(COALESCE(ip."price" * ip."quantity", 0))
            FROM public."InvoicesProduct" ip
            WHERE ip."invoiceId" = p_id
        ), 0)
        + COALESCE("chargesAndTaxes", 0) 
        + COALESCE((
            SELECT SUM(ipt."explicitAmount")
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = p_id
        ), 0)
    )::numeric, v_decimals)::double precision
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Factura ' || p_id || ' actualizada correctamente.';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
