DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImportQuotation'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spImportQuotation"(
    IN p_text_data TEXT,
    IN p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de cotizaciones desde TEXTO PLANO DELIMITADO.
    Formato esperado: 34 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_quotation_record RECORD;
    v_product_record RECORD;
    v_quotation_id INT;
    v_qp_id INT;
    v_internal_number TEXT;
    v_client_id INT;
    v_branch_id INT;
    v_implant_id INT;
    v_seller_id INT;
    v_ticket_printer_id INT;
    v_product_id INT;
    v_provider_id INT;
    v_prestadora_id INT;
    v_tax_id INT;
    v_main_tax_id INT;
    v_variable_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_rows (
        row_id INT GENERATED ALWAYS AS IDENTITY, --0
        grupo TEXT, --1
        cliente_doc TEXT, --2
        sucursal_cd TEXT, --3
        implant_cd TEXT, --4
        vendedor_cd TEXT, --5
        tiqueteador_cd TEXT, --6
        moneda TEXT, --7
        tasa_cambio DECIMAL, -- 8
        comision_global DECIMAL, -- 9
        cargos_global DECIMAL, --10
        producto_cd TEXT, --11
        proveedor_nm TEXT, --12 
        proveedor_cd TEXT, --13
        prestadora_cd TEXT, --14
        impuestos_str TEXT, --15
        variables_str TEXT, --16
        pasajeros_str TEXT, --17
        precio DECIMAL, --18
        cantidad INT, --19
        check_in TIMESTAMP, --20
        check_out TIMESTAMP, --21
        pax_adultos INT, --22
        pax_ninos INT, --23
        destino TEXT, --24
        tipo_servicio TEXT, --25
        reserva TEXT, --26
        com_vendedor DECIMAL, --27
        com_tiqueteador DECIMAL, --28
        combos_str TEXT, --29
        nacionalidad INT DEFAULT 1, --30
        cargo_principal_cd TEXT, --31
        cost DECIMAL DEFAULT 0, --32
        provider_due_date TIMESTAMP, --33
        provider_invoice TEXT --34
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            INSERT INTO tmp_import_rows (
                grupo, cliente_doc, sucursal_cd, implant_cd, vendedor_cd, tiqueteador_cd,
                moneda, tasa_cambio, comision_global, cargos_global, producto_cd,
                proveedor_nm, proveedor_cd, prestadora_cd, impuestos_str, variables_str,
                pasajeros_str, precio, cantidad, check_in, check_out, pax_adultos, pax_ninos,
                destino, tipo_servicio, reserva, com_vendedor, com_tiqueteador, combos_str,
                nacionalidad, cargo_principal_cd, cost, provider_due_date, provider_invoice
            ) VALUES (
                TRIM(v_cols[1]), -- grupo 
                TRIM(v_cols[2]), -- cliente_doc 
                TRIM(v_cols[3]), -- sucursal_cd
                TRIM(v_cols[4]), -- implant_cd
                TRIM(v_cols[5]), -- vendedor_cd
                TRIM(v_cols[6]), -- tiqueteador_cd
                TRIM(v_cols[7]), -- moneda
                CASE WHEN TRIM(v_cols[8]) = '' THEN NULL WHEN POSITION(':' IN v_cols[8]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[8]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[8]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- tasa_cambio
                CASE WHEN TRIM(v_cols[9]) = '' THEN NULL WHEN POSITION(':' IN v_cols[9]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[9]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[9]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision_global
                CASE WHEN TRIM(v_cols[10]) = '' THEN NULL WHEN POSITION(':' IN v_cols[10]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[10]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[10]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- cargos_global
                TRIM(v_cols[11]), -- Producto Codigo
                TRIM(v_cols[12]), -- Prov Nombre
                TRIM(v_cols[13]), -- Prov Codigo
                TRIM(v_cols[14]), -- Prestadora Codigo
                COALESCE(NULLIF(TRIM(v_cols[15]), ''), CASE WHEN POSITION(':' IN v_cols[10]) > 0 THEN TRIM(v_cols[10]) ELSE '' END), -- Impuestos
                TRIM(v_cols[16]), -- Variables
                TRIM(v_cols[17]), -- Pasajeros
                CASE WHEN TRIM(v_cols[18]) = '' THEN NULL WHEN POSITION(':' IN v_cols[18]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[18]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[18]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- precio
                CASE WHEN TRIM(v_cols[19]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[19]), '[^0-9]', '', 'g'), '')::INT END, -- cantidad
                CASE WHEN TRIM(v_cols[20]) <> '' THEN REPLACE(TRIM(v_cols[20]), '/', '-')::TIMESTAMP ELSE NULL END, -- check_in
                CASE WHEN TRIM(v_cols[21]) <> '' THEN REPLACE(TRIM(v_cols[21]), '/', '-')::TIMESTAMP ELSE NULL END, -- check_out
                CASE WHEN TRIM(v_cols[22]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[22]), '[^0-9]', '', 'g'), '')::INT END, -- pax_adultos
                CASE WHEN TRIM(v_cols[23]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[23]), '[^0-9]', '', 'g'), '')::INT END, -- pax_ninos
                TRIM(v_cols[24]), -- destino
                TRIM(v_cols[25]), -- tipo_servicio
                TRIM(v_cols[26]), -- reserva 
                CASE WHEN TRIM(v_cols[27]) = '' THEN NULL WHEN POSITION(':' IN v_cols[27]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[27]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[27]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision vendedor
                CASE WHEN TRIM(v_cols[28]) = '' THEN NULL WHEN POSITION(':' IN v_cols[28]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[28]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[28]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision tiqueteador
                TRIM(v_cols[29]), -- codigo combos
                COALESCE(NULLIF(REGEXP_REPLACE(TRIM(v_cols[30]), '[^0-9]', '', 'g'), '')::INT, 1), -- nacionalidad
                TRIM(v_cols[31]), -- cargo_principal_cd
                CASE WHEN TRIM(v_cols[32]) = '' THEN NULL WHEN POSITION(':' IN v_cols[32]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[32]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[32]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- cost
                CASE WHEN TRIM(v_cols[33]) <> '' THEN REPLACE(TRIM(v_cols[33]), '/', '-')::TIMESTAMP ELSE NULL END, -- provider_due_date
                NULLIF(TRIM(v_cols[34]), '') -- provider_invoice
            );
        EXCEPTION WHEN OTHERS THEN
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': ' || SQLERRM;
            RETURN;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos
    FOR v_quotation_record IN (
        SELECT grupo, 
               MAX(cliente_doc) as cliente_doc, 
               MAX(sucursal_cd) as sucursal_cd, 
               MAX(implant_cd) as implant_cd, 
               MAX(vendedor_cd) as vendedor_cd, 
               MAX(tiqueteador_cd) as tiqueteador_cd, 
               MAX(moneda) as moneda, 
               MAX(tasa_cambio) as tasa_cambio, 
               MAX(comision_global) as comision_global, 
               MAX(cargos_global) as cargos_global,
               MAX(combos_str) as combos_str
        FROM tmp_import_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_quotation_record.cliente_doc;
        IF v_client_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Cliente con documento o código "' || v_quotation_record.cliente_doc || '" no encontrado en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_quotation_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Sucursal con código "' || v_quotation_record.sucursal_cd || '" no encontrada en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_quotation_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_quotation_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_quotation_record.tiqueteador_cd);

        -- Validación de variables obligatorias del cliente para cotizaciones
        DECLARE
            v_client_mandatory_vars JSONB;
            v_client_var_id_text TEXT;
            v_req_var_id INT;
            v_req_var_name TEXT;
            v_req_var_code TEXT;
            v_check_prod RECORD;
        BEGIN
            SELECT "mandatoryVariables" INTO v_client_mandatory_vars FROM public."Client" WHERE id = v_client_id;
            IF v_client_mandatory_vars IS NOT NULL THEN
                IF jsonb_typeof(v_client_mandatory_vars) = 'object' AND v_client_mandatory_vars ? 'quotation' AND jsonb_typeof(v_client_mandatory_vars->'quotation') = 'array' THEN
                    v_client_mandatory_vars := v_client_mandatory_vars->'quotation';
                ELSIF jsonb_typeof(v_client_mandatory_vars) = 'object' AND v_client_mandatory_vars ? 'quotations' AND jsonb_typeof(v_client_mandatory_vars->'quotations') = 'array' THEN
                    v_client_mandatory_vars := v_client_mandatory_vars->'quotations';
                ELSIF jsonb_typeof(v_client_mandatory_vars) <> 'array' THEN
                    v_client_mandatory_vars := '[]'::JSONB;
                END IF;
            END IF;

            IF v_client_mandatory_vars IS NOT NULL AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN
                FOR v_client_var_id_text IN SELECT jsonb_array_elements_text(v_client_mandatory_vars) LOOP
                    v_req_var_id := v_client_var_id_text::INT;
                    SELECT "name", "code" INTO v_req_var_name, v_req_var_code FROM public."MasterVariable" WHERE id = v_req_var_id;
                    v_req_var_name := COALESCE(v_req_var_name, 'Variable #' || v_req_var_id);

                    FOR v_check_prod IN SELECT * FROM tmp_import_rows WHERE grupo = v_quotation_record.grupo LOOP
                        IF v_check_prod.variables_str IS NULL OR NOT EXISTS (
                            SELECT 1 FROM unnest(string_to_array(v_check_prod.variables_str, '|')) AS var_item
                            WHERE (
                                LOWER(TRIM(split_part(var_item, ':', 1))) = LOWER(TRIM(COALESCE(v_req_var_code, '')))
                                OR LOWER(TRIM(split_part(var_item, ':', 1))) = LOWER(TRIM(v_req_var_id::TEXT))
                            ) AND NULLIF(TRIM(substr(var_item, length(split_part(var_item, ':', 1)) + 2)), '') IS NOT NULL
                        ) THEN
                            p_mensaje_resultado := 'ERROR en GRUPO ' || v_quotation_record.grupo || ': El cliente requiere completar la variable adicional "' || v_req_var_name || '" en el producto "' || COALESCE(v_check_prod.producto_cd, 'Ítem') || '".';
                            RETURN;
                        END IF;
                    END LOOP;
                END LOOP;
            END IF;
        END;

        -- Obtener decimales de la moneda
        v_decimals := public.fn_obtener_decimales_moneda(COALESCE(v_quotation_record.moneda, 'COP'));

        v_internal_number := 'QUO-SP-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;

        INSERT INTO public."Quotation" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_quotation_record.moneda, 'COP'), 
            COALESCE(v_quotation_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_quotation_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_quotation_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id
        ) RETURNING id INTO v_quotation_id;

        v_created_ids := v_created_ids || v_quotation_id || ',';

        v_total_amount := COALESCE(v_quotation_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_quotation_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."QuotationCombo" ("quotationId", "comboId") VALUES (v_quotation_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."QuotationProduct" (
                                "quotationId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_quotation_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_qp_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."QuotationProductTax" (
                                "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_qp_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
                                   ROUND(cpt.amount::numeric, v_decimals)::double precision, cpt."isMain"
                            FROM public."ComboProductTax" cpt
                            JOIN public."ChargeAndTax" ct ON cpt."chargeAndTaxId" = ct.id
                            WHERE cpt."comboProductId" = v_cp_record.id;
                            
                            -- Sumar impuestos al total
                            v_total_amount := v_total_amount + COALESCE((SELECT SUM(amount) FROM public."ComboProductTax" WHERE "comboProductId" = v_cp_record.id), 0);
                        END LOOP;
                    END IF;
                END;
            END LOOP;
        END IF;

        -- Procesar Productos Individuales
        FOR v_product_record IN (SELECT * FROM tmp_import_rows WHERE grupo = v_quotation_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN CONTINUE; END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            v_prestadora_id := NULL;
            IF v_product_record.prestadora_cd IS NOT NULL AND TRIM(v_product_record.prestadora_cd) <> '' THEN
                SELECT id INTO v_prestadora_id FROM public."Prestadora" 
                WHERE LOWER(code) = LOWER(TRIM(v_product_record.prestadora_cd)) OR LOWER(name) = LOWER(TRIM(v_product_record.prestadora_cd))
                LIMIT 1;
            END IF;

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_qp_id := NULL;
            SELECT id INTO v_qp_id FROM public."QuotationProduct" 
            WHERE "quotationId" = v_quotation_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_qp_id IS NOT NULL THEN
                UPDATE public."QuotationProduct" SET
                    "quantity" = COALESCE(v_product_record.quantity, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "providerId" = COALESCE(v_provider_id, "providerId"),
                    "prestadoraId" = COALESCE(v_prestadora_id, "prestadoraId"),
                    "checkInDate" = COALESCE(v_product_record.check_in, "checkInDate"),
                    "checkOutDate" = COALESCE(v_product_record.check_out, "checkOutDate"),
                    "nights" = CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                                 THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                                 ELSE "nights" END,
                    "paxAdults" = COALESCE(v_product_record.pax_adultos, "paxAdults"),
                    "paxChildren" = COALESCE(v_product_record.pax_ninos, "paxChildren"),
                    "serviceType" = COALESCE(v_product_record.tipo_servicio, "serviceType"),
                    "destination" = COALESCE(v_product_record.destino, "destination"),
                    "reservationCode" = COALESCE(v_product_record.reserva, "reservationCode"),
                    "sellerCommission" = ROUND(COALESCE(v_product_record.com_vendedor, "sellerCommission")::numeric, v_decimals)::double precision,
                    "ticketPrinterCommission" = ROUND(COALESCE(v_product_record.com_tiqueteador, "ticketPrinterCommission")::numeric, v_decimals)::double precision,
                    "inNationality" = COALESCE(v_product_record.nacionalidad, "inNationality"),
                    "mainTaxId" = COALESCE(v_main_tax_id, "mainTaxId"),
                    "cost" = ROUND(COALESCE(v_product_record.cost, "cost")::numeric, v_decimals)::double precision,
                    "providerDueDate" = COALESCE(v_product_record.provider_due_date, "providerDueDate"),
                    "providerInvoice" = COALESCE(v_product_record.provider_invoice, "providerInvoice")
                WHERE id = v_qp_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."QuotationProductTax" WHERE "quotationProductId" = v_qp_id;
                END IF;
            ELSE
                IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."QuotationProduct" (
                    "quotationId", "productId", "quantity", "price", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "inNationality", "mainTaxId", "cost", "providerDueDate", "providerInvoice"
                ) VALUES (
                    v_quotation_id, v_product_id, COALESCE(v_product_record.quantity, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    COALESCE(v_product_record.nacionalidad, 1), v_main_tax_id, 
                    ROUND(COALESCE(v_product_record.cost, 0)::numeric, v_decimals)::double precision,
                    v_product_record.provider_due_date, v_product_record.provider_invoice
                ) RETURNING id INTO v_qp_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.quantity, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductTax" (
                            "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount"
                        ) 
                        SELECT v_qp_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                    VALUES (v_qp_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                        VALUES (v_qp_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en QuotationProductTax
        UPDATE public."Quotation"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0) AS cargos_global
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = v_quotation_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_quotation_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' cotizaciones importadas. [' || RTRIM(v_created_ids, ',') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;
