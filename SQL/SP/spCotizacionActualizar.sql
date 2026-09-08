DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCotizacionActualizar(
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
    v_pmt RECORD;
    v_combo RECORD;
    v_manual RECORD;
    v_quotation_product_id INT;
    -- Variables para validación de campos obligatorios dinámicos
    v_val_item JSONB;
    v_val_prod_id INT;
    v_mandatory_fields JSONB;
    v_field_key TEXT;
    v_model TEXT;
    v_field_name TEXT;
    v_prod_desc TEXT;
    v_has_passengers BOOLEAN;
    v_has_empty_pax_name BOOLEAN;
    v_has_payments BOOLEAN;
    v_json_field_name TEXT;
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
    v_old_state TEXT;
    -- Variables para cálculos financieros
    v_mostrar_totalizacion BOOLEAN;
    v_comision_utilidad DOUBLE PRECISION;
    v_comision_freelance DOUBLE PRECISION;
    v_comision_propia DOUBLE PRECISION;
    v_costo_total DOUBLE PRECISION;
    v_valor_base DOUBLE PRECISION;
    v_decimals INT;
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM public."Quotation" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: La cotización con ID ' || p_id || ' no existe.';
        RETURN;
    END IF;

    SELECT "state" INTO v_old_state FROM public."Quotation" WHERE id = p_id;

    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
        WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
    ) THEN
        p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
        RETURN;
    END IF;

    -- Validación de campos obligatorios dinámicos por producto
    FOR v_val_item IN SELECT jsonb_array_elements(p_data->'items')
    LOOP
        v_val_prod_id := (v_val_item->>'productId')::INT;
        
        SELECT "mandatoryFields", "description" 
        INTO v_mandatory_fields, v_prod_desc 
        FROM public."Product" 
        WHERE id = v_val_prod_id;

        v_prod_desc := COALESCE(v_prod_desc, 'Producto #' || v_val_prod_id);

        IF v_mandatory_fields IS NOT NULL AND jsonb_typeof(v_mandatory_fields) = 'array' THEN
            FOR v_field_key IN SELECT jsonb_array_elements_text(v_mandatory_fields)
            LOOP
                v_model := split_part(v_field_key, '.', 1);
                v_field_name := split_part(v_field_key, '.', 2);

                IF v_model = 'Quotation' THEN
                    IF NULLIF(p_data->>v_field_name, '') IS NULL THEN
                        p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo general "' || v_field_name || '".';
                        RETURN;
                    END IF;
                ELSIF v_model = 'QuotationProduct' THEN
                    v_json_field_name := v_field_name;
                    IF v_field_name = 'checkInDate' THEN
                        v_json_field_name := 'checkIn';
                    ELSIF v_field_name = 'checkOutDate' THEN
                        v_json_field_name := 'checkOut';
                    ELSIF v_field_name = 'description' THEN
                        v_json_field_name := 'descripcion';
                    ELSIF v_field_name = 'service' THEN
                        IF NULLIF(v_val_item->>'service', '') IS NULL AND v_val_item->>'servicios' IS NOT NULL THEN
                            v_json_field_name := 'servicios';
                        END IF;
                    END IF;

                    IF v_field_name = 'passengers' THEN
                        v_has_passengers := FALSE;
                        v_has_empty_pax_name := FALSE;
                        
                        IF v_val_item->'passengers' IS NOT NULL AND jsonb_typeof(v_val_item->'passengers') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'passengers') > 0, FALSE) INTO v_has_passengers;
                            SELECT EXISTS (
                                SELECT 1 FROM jsonb_to_recordset(v_val_item->'passengers') AS p(name TEXT)
                                WHERE p.name IS NULL OR trim(p.name) = ''
                            ) INTO v_has_empty_pax_name;
                        END IF;

                        IF NOT v_has_passengers OR v_has_empty_pax_name THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pasajero con su nombre.';
                            RETURN;
                        END IF;
                    ELSIF v_field_name = 'payments' THEN
                        v_has_payments := FALSE;
                        IF v_val_item->'payments' IS NOT NULL AND jsonb_typeof(v_val_item->'payments') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'payments') > 0, FALSE) INTO v_has_payments;
                        END IF;

                        IF NOT v_has_payments THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pago.';
                            RETURN;
                        END IF;
                    ELSE
                        IF NULLIF(v_val_item->>v_json_field_name, '') IS NULL THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo "' || v_field_name || '".';
                            RETURN;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    -- Validación de variables obligatorias específicas del cliente
    v_client_id := NULLIF(p_data->>'clientId', '')::INT;
    IF v_client_id IS NOT NULL THEN
        SELECT "mandatoryVariables" INTO v_client_mandatory_vars
        FROM public."Client"
        WHERE id = v_client_id;

        IF v_client_mandatory_vars IS NOT NULL AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN
            FOR v_client_var_id_text IN SELECT jsonb_array_elements_text(v_client_mandatory_vars)
            LOOP
                v_req_var_id := v_client_var_id_text::INT;
                
                SELECT "name" INTO v_req_var_name FROM public."MasterVariable" WHERE id = v_req_var_id;
                v_req_var_name := COALESCE(v_req_var_name, 'Variable #' || v_req_var_id);

                FOR v_item_json IN SELECT jsonb_array_elements(p_data->'items')
                LOOP
                    v_item_prod_id := (v_item_json->>'productId')::INT;
                    SELECT "description" INTO v_item_prod_desc FROM public."Product" WHERE id = v_item_prod_id;
                    v_item_prod_desc := COALESCE(v_item_prod_desc, 'Producto #' || v_item_prod_id);

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
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    UPDATE public."Quotation" SET
        "clientId" = NULLIF(p_data->>'clientId', '')::INT,
        "currency" = p_data->>'currency',
        "exchangeRate" = NULLIF(p_data->>'exchangeRate', '')::FLOAT,
        "branchId" = NULLIF(p_data->>'branchId', '')::INT,
        "implantId" = NULLIF(p_data->>'implantId', '')::INT,
        "sellerId" = NULLIF(p_data->>'sellerId', '')::INT,
        "ticketPrinterId" = NULLIF(p_data->>'ticketPrinterId', '')::INT,
        "commissionPercentage" = NULLIF(p_data->>'commissionPercentage', '')::FLOAT,
        "chargesAndTaxes" = ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision,
        "totalAmount" = ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision,
        "state" = COALESCE(p_data->>'state', 'Nuevo'),
        "stateDescription" = CASE WHEN COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN p_data->>'stateDescription' ELSE "stateDescription" END,
        "stateUpdatedAt" = CASE WHEN COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN CURRENT_TIMESTAMP ELSE "stateUpdatedAt" END,
        "date" = CURRENT_TIMESTAMP,
        "destination" = p_data->>'destination',
        "startDate" = CASE WHEN p_data->>'startDate' IS NOT NULL AND p_data->>'startDate' <> '' THEN (p_data->>'startDate')::TIMESTAMP ELSE NULL END,
        "endDate" = CASE WHEN p_data->>'endDate' IS NOT NULL AND p_data->>'endDate' <> '' THEN (p_data->>'endDate')::TIMESTAMP ELSE NULL END,
        "passenger" = p_data->>'passenger',
        "paxAdults" = NULLIF(p_data->>'paxAdults', '')::INT,
        "paxChildren" = NULLIF(p_data->>'paxChildren', '')::INT,
        "reservationCode" = p_data->>'reservationCode',
        "copyFieldsToProducts" = COALESCE(NULLIF(p_data->>'copyFieldsToProducts', '')::BOOLEAN, TRUE),
        "manualDescription" = p_data->>'manualDescription'
    WHERE id = p_id;

    -- Insertar historial de estado si cambia
    IF COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN
        INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
        VALUES (p_id, COALESCE(p_data->>'state', 'Nuevo'), p_data->>'stateDescription', CURRENT_TIMESTAMP, p_acting_user_id);
    END IF;

    DELETE FROM public."QuotationCombo" WHERE "quotationId" = p_id;
    FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
    LOOP
        INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
        VALUES (p_id, COALESCE(v_combo."comboId", v_combo.id));
    END LOOP;

    DELETE FROM public."QuotationManualService" WHERE "quotationId" = p_id;
    IF p_data->'manualServices' IS NOT NULL AND jsonb_typeof(p_data->'manualServices') = 'array' THEN
        FOR v_manual IN SELECT * FROM jsonb_to_recordset(p_data->'manualServices') AS x(
            "providerName" TEXT, "serviceName" TEXT, "cost" FLOAT, "salePrice" FLOAT, "utility" FLOAT
        )
        LOOP
            INSERT INTO public."QuotationManualService" (
                "quotationId", "providerName", "serviceName", "cost", "salePrice", "utility"
            ) VALUES (
                p_id, 
                v_manual."providerName", 
                v_manual."serviceName", 
                COALESCE(v_manual."cost", 0), 
                COALESCE(v_manual."salePrice", 0), 
                COALESCE(v_manual."utility", COALESCE(v_manual."salePrice", 0) - COALESCE(v_manual."cost", 0))
            );
        END LOOP;
    END IF;

    DELETE FROM public."QuotationProduct" WHERE "quotationId" = p_id;
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                      "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                      "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                      "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                      "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "payments" JSONB, "inNationality" INT,
                      "service" TEXT, "servicios" TEXT, "descripcion" TEXT, "passenger" TEXT
                  )
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission", 
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            p_id, v_item."productId", v_item.quantity, 
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
            COALESCE(v_item."service", v_item."servicios"), COALESCE(v_item."servicios", v_item."service"), v_item."descripcion",
            v_item."passenger"
        ) RETURNING id INTO v_quotation_product_id;

        IF v_item.passengers IS NOT NULL THEN
            FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
            LOOP
                INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                VALUES (v_quotation_product_id, v_pax.name, v_pax.document);
            END LOOP;
        END IF;

        IF v_item."appliedTaxes" IS NOT NULL THEN
            FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
            LOOP
                INSERT INTO public."QuotationProductTax" (
                    "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                )
                SELECT v_quotation_product_id, ct.id, ct.value, ct."valueType", 
                       ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                       CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                FROM public."ChargeAndTax" ct
                WHERE ct.id = v_tax."chargeAndTaxId";
            END LOOP;
        END IF;

        IF v_item.variables IS NOT NULL THEN
            FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
            LOOP
                INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                VALUES (v_quotation_product_id, v_var."masterVariableId", v_var.value);
            END LOOP;
        END IF;

        IF v_item.payments IS NOT NULL THEN
            FOR v_pmt IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(
                "amount" FLOAT, "paymentMethod" TEXT, "date" TEXT, "reference" TEXT,
                "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT
            )
            LOOP
                INSERT INTO public."QuotationProductPayment" (
                    "quotationProductId", "amount", "paymentMethod", "reference", "date",
                    "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                ) VALUES (
                    v_quotation_product_id, 
                    ROUND(v_pmt."amount"::numeric, v_decimals)::double precision, 
                    v_pmt."paymentMethod", v_pmt."reference",
                    CASE WHEN v_pmt."date" IS NOT NULL AND v_pmt."date" <> '' THEN v_pmt."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END,
                    v_pmt."creditCardId", v_pmt."cardNumber", v_pmt."authorizationCode", v_pmt."voucher", v_pmt."expirationDate"
                );
            END LOOP;
        END IF;
    END LOOP;

    -- Recalcular valores financieros
    SELECT 
        COALESCE(SUM(qp.cost), 0.0), 
        COALESCE(SUM(
            qp.price * qp.quantity + COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM public."QuotationProductTax" qpt2
                JOIN public."ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0.0)
        ), 0.0)
    INTO v_costo_total, v_valor_base
    FROM public."QuotationProduct" qp
    WHERE qp."quotationId" = p_id;

    SELECT COALESCE(value = 'true', FALSE) INTO v_mostrar_totalizacion
    FROM public."SystemParameter"
    WHERE code = 'MOSTRAR_TOTALIZACION_COTIZACION';

    v_comision_freelance := COALESCE(NULLIF(p_data->>'comisionFreelancePercentage', '')::DOUBLE PRECISION, 0.0);

    IF v_mostrar_totalizacion THEN
        v_comision_utilidad := ROUND(public.fn_calcular_porcentaje_comision(public.fn_calcular_utilidad(v_valor_base, v_costo_total), v_valor_base)::NUMERIC, 2)::DOUBLE PRECISION;
        v_comision_propia := v_comision_utilidad - v_comision_freelance;
    ELSE
        v_comision_propia := public.fn_calcular_comision_resta(
            COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
            v_comision_freelance
        );
    END IF;

    UPDATE public."Quotation"
    SET 
        "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0)
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = p_id
        ))::numeric, v_decimals)::double precision,
        "costoTotal" = ROUND(v_costo_total::numeric, v_decimals)::double precision,
        "valorBase" = ROUND(v_valor_base::numeric, v_decimals)::double precision,
        "comisionTotalPercentage" = COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
        "comisionFreelancePercentage" = v_comision_freelance,
        "comisionPropiaPercentage" = v_comision_propia,
        "commissionPercentage" = v_comision_propia,
        "utilidad" = ROUND(public.fn_calcular_utilidad(v_valor_base, v_costo_total)::numeric, v_decimals)::double precision,
        "comisionUtilidadPercentage" = public.fn_calcular_porcentaje_comision(
            public.fn_calcular_utilidad(v_valor_base, v_costo_total),
            v_valor_base
        ),
        "comisionFreelanceValue" = ROUND(public.fn_calcular_valor_comision(v_comision_freelance, v_valor_base)::numeric, v_decimals)::double precision,
        "comisionPropiaValue" = ROUND(public.fn_calcular_valor_comision(v_comision_propia, v_valor_base)::numeric, v_decimals)::double precision
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cotización ' || p_id || ' actualizada correctamente.';

    -- Registrar en Auditoría
    CALL public."spLogRegistrar"(
        p_acting_user_id, 
        'QUOTATION', 
        'UPDATE', 
        'Se actualizó la cotización con ID ' || p_id, 
        p_data, 
        v_quotation_product_id -- Reutilizamos variable para el logId temporal
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
