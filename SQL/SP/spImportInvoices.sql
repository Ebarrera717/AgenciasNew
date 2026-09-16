DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImportInvoices'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spImportInvoices"(
    IN p_text_data TEXT,
    IN p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de facturas desde TEXTO PLANO DELIMITADO con soporte para pagos e itinerarios.
    Formato esperado: 40 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_invoice_record RECORD;
    v_product_record RECORD;
    v_invoice_id INT;
    v_ip_id INT;
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
    v_ticket_type_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_pay_item TEXT;
    v_pay_parts TEXT[];
    v_pay_method TEXT;
    v_pay_ref TEXT;
    v_pay_date TIMESTAMP;
    v_pay_card_id INT;
    v_pay_card_num TEXT;
    v_pay_auth TEXT;
    v_pay_voucher TEXT;
    v_pay_exp TEXT;
    v_itin_item TEXT;
    v_itin_parts TEXT[];
    v_itin_origin TEXT;
    v_itin_dest TEXT;
    v_itin_class TEXT;
    v_itin_check_in TIMESTAMP;
    v_itin_check_out TIMESTAMP;
    v_itin_orden INT;
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_invoice_rows (
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
        costo DECIMAL DEFAULT 0, --32
        servicios TEXT, --33
        descripcion TEXT, --34
        itinerary TEXT, --35
        class TEXT, --36
        airline TEXT, --37
        tipo_tiquete_cd TEXT, --38
        pagos_str TEXT, --39
        itinerarios_str TEXT, --40
        fuente TEXT, --41
        serie TEXT, --42
        consecutivo TEXT --43
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_invoice_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            -- Validar formato de Check-In (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[20]) <> '' AND REPLACE(TRIM(v_cols[20]), '/', '-') !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [CheckIn]): Formato de fecha incorrecto. Valor recibido: "' || TRIM(v_cols[20]) || '". Ejemplo de formato correcto: 2026-10-01 (o 2026/10/01)';
                RETURN;
            END IF;

            -- Validar formato de Check-Out (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[21]) <> '' AND REPLACE(TRIM(v_cols[21]), '/', '-') !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [CheckOut]): Formato de fecha incorrecto. Valor recibido: "' || TRIM(v_cols[21]) || '". Ejemplo de formato correcto: 2026-10-10 (o 2026/10/10)';
                RETURN;
            END IF;
            
            INSERT INTO tmp_import_invoice_rows (
                grupo, cliente_doc, sucursal_cd, implant_cd, vendedor_cd, tiqueteador_cd,
                moneda, tasa_cambio, comision_global, cargos_global, producto_cd,
                proveedor_nm, proveedor_cd, prestadora_cd, impuestos_str, variables_str,
                pasajeros_str, precio, cantidad, check_in, check_out, pax_adultos, pax_ninos,
                destino, tipo_servicio, reserva, com_vendedor, com_tiqueteador, combos_str,
                nacionalidad, cargo_principal_cd, costo, servicios, descripcion, itinerary,
                class, airline, tipo_tiquete_cd, pagos_str, itinerarios_str,
                fuente, serie, consecutivo
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
                CASE WHEN TRIM(v_cols[32]) = '' THEN NULL WHEN POSITION(':' IN v_cols[32]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[32]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[32]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- costo
                TRIM(v_cols[33]), -- servicios
                TRIM(v_cols[34]), -- descripcion
                TRIM(v_cols[35]), -- itinerary
                TRIM(v_cols[36]), -- class
                TRIM(v_cols[37]), -- airline
                TRIM(v_cols[38]),  -- tipo_tiquete_cd
                TRIM(v_cols[39]),  -- pagos_str
                TRIM(v_cols[40]),  -- itinerarios_str
                TRIM(v_cols[41]),  -- fuente
                TRIM(v_cols[42]),  -- serie
                TRIM(v_cols[43])   -- consecutivo
            );
        EXCEPTION WHEN OTHERS THEN
            DECLARE
                v_err_col TEXT := '';
                v_example TEXT := '';
            BEGIN
                IF SQLERRM LIKE '%numeric%' OR SQLERRM LIKE '%numérico%' THEN
                    IF TRIM(v_cols[8]) <> '' AND TRIM(v_cols[8]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Tasa_Cambio])'; v_example := '. Ejemplo de formato correcto: 4000 o 1';
                    ELSIF TRIM(v_cols[9]) <> '' AND TRIM(v_cols[9]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Global_Pct])'; v_example := '. Ejemplo de formato correcto: 10 o 0';
                    ELSIF TRIM(v_cols[10]) <> '' AND TRIM(v_cols[10]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Cargos_A_Factura])'; v_example := '. Ejemplo de formato correcto: 20000 o TAR:20000';
                    ELSIF TRIM(v_cols[18]) <> '' AND TRIM(v_cols[18]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Precio_Unitario])'; v_example := '. Ejemplo de formato correcto: 100000 o 100000.50';
                    ELSIF TRIM(v_cols[19]) <> '' AND TRIM(v_cols[19]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Cantidad])'; v_example := '. Ejemplo de formato correcto: 1 o 2';
                    ELSIF TRIM(v_cols[22]) <> '' AND TRIM(v_cols[22]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Pax_Adultos])'; v_example := '. Ejemplo de formato correcto: 1 o 2';
                    ELSIF TRIM(v_cols[23]) <> '' AND TRIM(v_cols[23]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Pax_Ninos])'; v_example := '. Ejemplo de formato correcto: 0 o 1';
                    ELSIF TRIM(v_cols[27]) <> '' AND TRIM(v_cols[27]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Vendedor_Producto])'; v_example := '. Ejemplo de formato correcto: 5.0 o 0';
                    ELSIF TRIM(v_cols[28]) <> '' AND TRIM(v_cols[28]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Tiqueteador_Producto])'; v_example := '. Ejemplo de formato correcto: 2.0 o 0';
                    ELSIF TRIM(v_cols[32]) <> '' AND TRIM(v_cols[32]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Costo])'; v_example := '. Ejemplo de formato correcto: 80000 u 80000.0';
                    END IF;
                END IF;
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || v_err_col || ': ' || SQLERRM || v_example || ' (Valor: ' || v_row_text || ')';
                RETURN;
            END;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos de Facturas
    FOR v_invoice_record IN (
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
               MAX(combos_str) as combos_str,
               MAX(fuente) as fuente,
               MAX(serie) as serie,
               MAX(consecutivo) as consecutivo
        FROM tmp_import_invoice_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_invoice_record.cliente_doc OR LOWER(code) = LOWER(v_invoice_record.cliente_doc);
        IF v_client_id IS NULL THEN 
            IF EXISTS (SELECT 1 FROM public."Provider" WHERE document = v_invoice_record.cliente_doc OR LOWER(code) = LOWER(v_invoice_record.cliente_doc) OR LOWER(name) = LOWER(v_invoice_record.cliente_doc)) THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Cliente_Documento]): El valor "' || v_invoice_record.cliente_doc || '" corresponde a un PROVEEDOR (ej: NIT Avianca/Aerolínea), no a un Cliente. Por favor especifique un documento o código de Cliente en esta columna (ej: 79898456 o CLI-001).';
            ELSE
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Cliente_Documento]): Cliente con documento o código "' || v_invoice_record.cliente_doc || '" no encontrado en el sistema. Ejemplo de valor correcto: Cédula o NIT registrado en Maestros -> Clientes (ej: 79898456 o CLI-001)';
            END IF;
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_invoice_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Sucursal_Codigo]): Sucursal con código "' || v_invoice_record.sucursal_cd || '" no encontrada en el sistema. Ejemplo de valor correcto: Código registrado en Maestros -> Sucursales (ej: BOG01 o MED01)';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_invoice_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_invoice_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_invoice_record.tiqueteador_cd);

        -- Asignar número consecutivo interno
        IF v_invoice_record.consecutivo IS NOT NULL AND TRIM(v_invoice_record.consecutivo) <> '' THEN
            v_internal_number := COALESCE(NULLIF(TRIM(COALESCE(v_invoice_record.serie, '') || '-' || v_invoice_record.consecutivo), '-'), v_invoice_record.consecutivo);
        ELSE
            SELECT x.v_consec_json->>'formattedConsecutive' INTO v_internal_number
            FROM (SELECT public."fnObtenerSiguienteConsecutivo"('INVOICE', v_branch_id, v_implant_id) AS v_consec_json) x;

            IF v_internal_number IS NULL OR v_internal_number = '' THEN
                v_internal_number := 'FAC-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;
            END IF;
        END IF;

        INSERT INTO public."Invoices" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId", "state",
            "fuente", "serie", "consecutivo"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_invoice_record.moneda, 'COP'), 
            COALESCE(v_invoice_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_invoice_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_invoice_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id, 'NUEVO',
            v_invoice_record.fuente, v_invoice_record.serie, v_invoice_record.consecutivo
        ) RETURNING id INTO v_invoice_id;

        v_created_ids := v_created_ids || v_internal_number || ', ';

        v_total_amount := COALESCE(v_invoice_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_invoice_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId") VALUES (v_invoice_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."InvoicesProduct" (
                                "invoiceId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_invoice_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_ip_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."InvoicesProductTax" (
                                "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_ip_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
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
        FOR v_product_record IN (SELECT * FROM tmp_import_invoice_rows WHERE grupo = v_invoice_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN 
                DECLARE
                    v_temp_msg TEXT;
                BEGIN
                    CALL public.spProductoCrear(
                        v_product_record.producto_cd,
                        COALESCE(v_product_record.tipo_servicio, 'Tiquete'),
                        COALESCE(v_product_record.descripcion, 'Tiquete ' || v_product_record.producto_cd),
                        COALESCE(v_product_record.precio, 0),
                        COALESCE(v_product_record.costo, 0),
                        NULL, 
                        COALESCE(v_product_record.tipo_servicio, 'Aire'),
                        p_user_id,
                        v_product_id,
                        v_temp_msg
                    );
                    IF v_temp_msg LIKE 'ERROR%' THEN
                        p_mensaje_resultado := v_temp_msg;
                        RETURN;
                    END IF;
                END;
            END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            SELECT id INTO v_prestadora_id FROM public."Prestadora" WHERE LOWER(code) = LOWER(v_product_record.prestadora_cd);

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_ticket_type_id := NULL;
            IF v_product_record.tipo_tiquete_cd <> '' THEN
                SELECT id INTO v_ticket_type_id FROM public."TicketType" WHERE LOWER(code) = LOWER(v_product_record.tipo_tiquete_cd);
            END IF;

            v_ip_id := NULL;
            SELECT id INTO v_ip_id FROM public."InvoicesProduct" 
            WHERE "invoiceId" = v_invoice_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_ip_id IS NOT NULL THEN
                UPDATE public."InvoicesProduct" SET
                    "quantity" = COALESCE(v_product_record.cantidad, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "cost" = ROUND(COALESCE(v_product_record.costo, "cost")::numeric, v_decimals)::double precision,
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
                    "servicios" = COALESCE(v_product_record.servicios, "servicios"),
                    "descripcion" = COALESCE(v_product_record.descripcion, "descripcion"),
                    "itinerary" = COALESCE(v_product_record.itinerary, "itinerary"),
                    "class" = COALESCE(v_product_record.class, "class"),
                    "airline" = COALESCE(v_product_record.airline, "airline"),
                    "ticketTypeId" = COALESCE(v_ticket_type_id, "ticketTypeId")
                WHERE id = v_ip_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."InvoicesProductTax" WHERE "invoiceProductId" = v_ip_id;
                END IF;
            ELSE
                IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."InvoicesProduct" (
                    "invoiceId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "comboId", "mainTaxId", "inNationality", "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
                ) VALUES (
                    v_invoice_id, v_product_id, COALESCE(v_product_record.cantidad, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.costo, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    NULL, v_main_tax_id, COALESCE(v_product_record.nacionalidad, 1),
                    v_product_record.servicios, v_product_record.descripcion, v_product_record.itinerary, v_product_record.class, v_product_record.airline, v_ticket_type_id
                ) RETURNING id INTO v_ip_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.cantidad, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductTax" (
                            "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                        ) 
                        SELECT v_ip_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision,
                               CASE WHEN v_main_tax_id = id THEN TRUE ELSE FALSE END
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                    VALUES (v_ip_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                        VALUES (v_ip_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pagos
            IF v_product_record.pagos_str IS NOT NULL AND v_product_record.pagos_str <> '' THEN
                FOREACH v_pay_item IN ARRAY string_to_array(v_product_record.pagos_str, '|') LOOP
                    v_pay_parts := string_to_array(v_pay_item, ':');
                    
                    v_pay_method := NULLIF(TRIM(v_pay_parts[2]), '');
                    v_pay_ref := NULLIF(TRIM(v_pay_parts[3]), '');
                    
                    v_pay_date := CURRENT_TIMESTAMP;
                    IF v_pay_parts[4] IS NOT NULL AND TRIM(v_pay_parts[4]) <> '' THEN
                        v_pay_date := TRIM(v_pay_parts[4])::TIMESTAMP;
                    END IF;

                    v_pay_card_id := NULL;
                    IF v_pay_parts[5] IS NOT NULL AND TRIM(v_pay_parts[5]) <> '' THEN
                        v_pay_card_id := TRIM(v_pay_parts[5])::INT;
                    END IF;

                    v_pay_card_num := NULLIF(TRIM(v_pay_parts[6]), '');
                    v_pay_auth := NULLIF(TRIM(v_pay_parts[7]), '');
                    v_pay_voucher := NULLIF(TRIM(v_pay_parts[8]), '');
                    v_pay_exp := NULLIF(TRIM(v_pay_parts[9]), '');

                    INSERT INTO public."InvoicesProductPayment" (
                        "invoiceProductId", "amount", "paymentMethod", "reference", "date", 
                        "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                    ) VALUES (
                        v_ip_id, 
                        ROUND(NULLIF(TRIM(v_pay_parts[1]), '')::numeric, v_decimals)::double precision, 
                        v_pay_method, 
                        v_pay_ref, 
                        v_pay_date, 
                        v_pay_card_id, 
                        v_pay_card_num, 
                        v_pay_auth, 
                        v_pay_voucher, 
                        v_pay_exp
                    );
                END LOOP;
            END IF;

            -- Split para Itinerarios
            IF v_product_record.itinerarios_str IS NOT NULL AND v_product_record.itinerarios_str <> '' THEN
                FOREACH v_itin_item IN ARRAY string_to_array(v_product_record.itinerarios_str, '|') LOOP
                    v_itin_parts := string_to_array(v_itin_item, ':');
                    
                    v_itin_origin := NULLIF(TRIM(v_itin_parts[1]), '');
                    v_itin_dest := NULLIF(TRIM(v_itin_parts[2]), '');
                    v_itin_class := NULLIF(TRIM(v_itin_parts[3]), '');
                    
                    v_itin_check_in := NULL;
                    IF v_itin_parts[4] IS NOT NULL AND TRIM(v_itin_parts[4]) <> '' THEN
                        v_itin_check_in := TRIM(v_itin_parts[4])::TIMESTAMP;
                    END IF;

                    v_itin_check_out := NULL;
                    IF v_itin_parts[5] IS NOT NULL AND TRIM(v_itin_parts[5]) <> '' THEN
                        v_itin_check_out := TRIM(v_itin_parts[5])::TIMESTAMP;
                    END IF;

                    v_itin_orden := NULL;
                    IF v_itin_parts[6] IS NOT NULL AND TRIM(v_itin_parts[6]) <> '' THEN
                        v_itin_orden := TRIM(v_itin_parts[6])::INT;
                    END IF;

                    INSERT INTO public."InvoicesProductItinerary" (
                        "invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "orden"
                    ) VALUES (
                        v_ip_id, 
                        v_itin_origin, 
                        v_itin_dest, 
                        v_itin_class, 
                        v_itin_check_in, 
                        v_itin_check_out, 
                        v_itin_orden
                    );
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en InvoicesProductTax
        UPDATE public."Invoices"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(ipt."explicitAmount"), 0) AS cargos_global
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = v_invoice_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_invoice_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' facturas importadas. [' || RTRIM(v_created_ids, ', ') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;
