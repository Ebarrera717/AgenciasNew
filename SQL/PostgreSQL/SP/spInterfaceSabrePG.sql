-- Drop de sobrecargas previas para prevenir error 42883
DO $$ 
BEGIN
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre"(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre" CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE OR REPLACE PROCEDURE public."spInterfaceSabre"(
    p_op TEXT,
    p_Booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    -- Variables Generales
    v_code VARCHAR(12) := NULL;
    v_blanch VARCHAR(25) := '001';
    v_implant VARCHAR(25) := '';
    v_date TIMESTAMP := CURRENT_TIMESTAMP;
    v_seller VARCHAR(25) := '';
    v_client VARCHAR(50) := '';
    v_currency VARCHAR(10) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_aerolinea_vende VARCHAR(10) := 'AA';
    v_provider_matched VARCHAR(50) := NULL;
    v_tiqueteador VARCHAR(20) := '';
    
    -- Variables de Sistema Adicionales Extraídas
    v_var_codes TEXT[] := ARRAY[]::TEXT[];
    v_var_names TEXT[] := ARRAY[]::TEXT[];
    v_var_values TEXT[] := ARRAY[]::TEXT[];
    
    -- Lineas
    v_lines TEXT[];
    v_line TEXT;
    v_i INT;
    
    -- Pasajeros
    v_pax_nombres TEXT[] := ARRAY[]::TEXT[];
    v_pax_apellidos TEXT[] := ARRAY[]::TEXT[];
    
    -- M2 Totales e Impuestos Generales y Pago M2
    v_m2_currency VARCHAR(10) := 'COP';
    v_m2_tarifa DOUBLE PRECISION := 0.0;
    v_m2_total DOUBLE PRECISION := 0.0;
    v_m2_tax_codes TEXT[] := ARRAY[]::TEXT[];
    v_m2_tax_amounts DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_m2_pay_type TEXT := NULL;
    v_m2_pay_card TEXT := '';
    v_m2_pay_number TEXT := '';
    
    -- Tiquetes y M50
    v_tkt_codes TEXT[] := ARRAY[]::TEXT[];
    v_tkt_prestadoras TEXT[] := ARRAY[]::TEXT[];
    v_tkt_tarifas DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_impuestos DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_pay_types TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_cards TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_numbers TEXT[] := ARRAY[]::TEXT[];
    
    -- Itinerarios M30
    v_iti_origenes TEXT[] := ARRAY[]::TEXT[];
    v_iti_destinos TEXT[] := ARRAY[]::TEXT[];
    v_iti_vuelos TEXT[] := ARRAY[]::TEXT[];
    v_iti_clases TEXT[] := ARRAY[]::TEXT[];
    v_iti_aerolineas TEXT[] := ARRAY[]::TEXT[];
    v_iti_fechas_salida TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    v_iti_fechas_llegada TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    
    -- IDs de Tablas
    v_booking_gds_id INT;
    v_booking_product_gds_id INT;
BEGIN
    -- 1. Separar líneas del contenido del archivo (p_Booking)
    v_lines := string_to_array(p_Booking, E'\n');
    IF v_lines IS NULL OR array_length(v_lines, 1) = 0 THEN
        RAISE EXCEPTION 'El contenido del archivo Sabre está vacío.' USING ERRCODE = 'P0001';
    END IF;

    -- 2. Recorrer archivo y parsear
    FOR v_i IN 1 .. array_length(v_lines, 1) LOOP
        v_line := REPLACE(REPLACE(v_lines[v_i], E'\r', ''), E'\uFEFF', '');
        
        -- Cabecera AA (PNR y Sucursal)
        IF v_line LIKE 'AA%' OR (v_code IS NULL AND POSITION('AA' IN v_line) = 1) THEN
            IF length(v_line) >= 61 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 6)), '');
            END IF;
            IF v_code IS NULL AND length(v_line) >= 20 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 10)), '');
            END IF;
            IF length(v_line) >= 18 THEN
                v_blanch := COALESCE(NULLIF(TRIM(SUBSTRING(v_line FROM 12 FOR 7)), ''), v_blanch);
            END IF;
        END IF;

        -- Pasajeros M1
        IF v_line LIKE 'M1%' THEN
            DECLARE
                v_raw_pax TEXT;
                v_slash_pos INT;
                v_ape TEXT;
                v_nom TEXT;
            BEGIN
                v_raw_pax := TRIM(SUBSTRING(v_line FROM 5 FOR 80));
                v_slash_pos := POSITION('/' IN v_raw_pax);
                IF v_slash_pos > 0 THEN
                    v_ape := TRIM(SUBSTRING(v_raw_pax FROM 1 FOR v_slash_pos - 1));
                    v_nom := TRIM(SUBSTRING(v_raw_pax FROM v_slash_pos + 1));
                ELSE
                    v_ape := v_raw_pax;
                    v_nom := '';
                END IF;
                IF v_ape <> '' THEN
                    v_pax_apellidos := array_append(v_pax_apellidos, v_ape);
                    v_pax_nombres := array_append(v_pax_nombres, v_nom);
                END IF;
            END;
        END IF;

        -- Totales e Impuestos de linea M2 (M201ADT...)
        IF v_line LIKE 'M2%' THEN
            DECLARE
                v_cop1_pos INT;
                v_cop2_pos INT;
                v_curr_code TEXT := 'COP';
                v_between TEXT;
                v_base_match TEXT[];
                v_tax_part TEXT;
                v_r RECORD;
                v_after_cop2 TEXT;
                v_tot_match TEXT[];
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                v_cop1_pos := POSITION('COP' IN v_line);
                IF v_cop1_pos = 0 THEN
                    v_cop1_pos := POSITION('USD' IN v_line);
                    v_curr_code := 'USD';
                END IF;

                IF v_cop1_pos > 0 THEN
                    v_m2_currency := v_curr_code;
                    v_currency := v_curr_code;

                    v_cop2_pos := POSITION(v_curr_code IN SUBSTRING(v_line FROM v_cop1_pos + 3));
                    IF v_cop2_pos > 0 THEN
                        v_cop2_pos := v_cop1_pos + 3 + v_cop2_pos - 1;
                        v_between := TRIM(SUBSTRING(v_line FROM v_cop1_pos + 3 FOR v_cop2_pos - (v_cop1_pos + 3)));
                        
                        v_base_match := regexp_matches(v_between, '^([0-9.]+)');
                        IF array_length(v_base_match, 1) >= 1 THEN
                            v_m2_tarifa := (v_base_match[1])::DOUBLE PRECISION;
                            v_tax_part := TRIM(SUBSTRING(v_between FROM length(v_base_match[1]) + 1));
                            
                            FOR v_r IN SELECT (m[1])::DOUBLE PRECISION AS amt, m[2] AS code
                                       FROM regexp_matches(v_tax_part, '([0-9.]+)\s*([A-Z0-9]{2})', 'g') AS m
                            LOOP
                                v_m2_tax_amounts := array_append(v_m2_tax_amounts, v_r.amt);
                                v_m2_tax_codes := array_append(v_m2_tax_codes, v_r.code);
                            END LOOP;
                        END IF;

                        v_after_cop2 := TRIM(SUBSTRING(v_line FROM v_cop2_pos + 3));
                        v_tot_match := regexp_matches(v_after_cop2, '^([0-9.]+)');
                        IF array_length(v_tot_match, 1) >= 1 THEN
                            v_m2_total := (v_tot_match[1])::DOUBLE PRECISION;
                        END IF;
                    END IF;
                END IF;

                -- Extracción de Tarjeta de Crédito en M2 si contiene CC
                v_cc_pos := POSITION('CC' IN v_line);
                IF v_cc_pos > 0 THEN
                    v_m2_pay_type := 'TC';
                    v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                    IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                        v_m2_pay_card := v_cand_card;
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                    ELSE
                        v_m2_pay_card := '';
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                    END IF;

                    IF array_length(v_num_match, 1) >= 1 THEN
                        v_m2_pay_number := v_num_match[1];
                    END IF;
                END IF;
            END;
        END IF;

        -- Itinerarios Vuelos M30 (AIRN)
        IF v_line LIKE 'M30%' THEN
            DECLARE
                v_airn_pos INT;
                v_date_str TEXT;
                v_day INT;
                v_mon_str TEXT;
                v_mon INT;
                v_year INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;
                v_orig TEXT;
                v_dest TEXT;
                v_rest TEXT;
                v_airline TEXT;
                v_flight TEXT;
                v_class TEXT;
                v_dep_time TEXT;
                v_arr_time TEXT;
                v_check_in TIMESTAMP;
                v_check_out TIMESTAMP;
            BEGIN
                v_airn_pos := POSITION('AIRN' IN v_line);
                IF v_airn_pos > 0 THEN
                    v_date_str := SUBSTRING(v_line FROM 10 FOR 5);
                    v_day := (SUBSTRING(v_date_str FROM 1 FOR 2))::INT;
                    v_mon_str := UPPER(SUBSTRING(v_date_str FROM 3 FOR 3));
                    
                    v_mon := CASE v_mon_str
                        WHEN 'JAN' THEN 1 WHEN 'FEB' THEN 2 WHEN 'MAR' THEN 3
                        WHEN 'APR' THEN 4 WHEN 'MAY' THEN 5 WHEN 'JUN' THEN 6
                        WHEN 'JUL' THEN 7 WHEN 'AUG' THEN 8 WHEN 'SEP' THEN 9
                        WHEN 'OCT' THEN 10 WHEN 'NOV' THEN 11 WHEN 'DEC' THEN 12
                        ELSE 1 END;
                        
                    v_orig := SUBSTRING(v_line FROM v_airn_pos + 4 FOR 3);
                    v_dest := SUBSTRING(v_line FROM v_airn_pos + 24 FOR 3);
                    
                    v_rest := TRIM(SUBSTRING(v_line FROM v_airn_pos + 44));
                    v_airline := SUBSTRING(v_rest FROM 1 FOR 2);
                    v_flight := TRIM(SUBSTRING(v_rest FROM 4 FOR 4));
                    v_class := SUBSTRING(v_rest FROM 8 FOR 1);
                    v_dep_time := SUBSTRING(v_rest FROM 10 FOR 4);
                    v_arr_time := SUBSTRING(v_rest FROM 15 FOR 4);
                    
                    v_check_in := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_dep_time FROM 1 FOR 2))::INT, (SUBSTRING(v_dep_time FROM 3 FOR 2))::INT, 0);
                    v_check_out := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_arr_time FROM 1 FOR 2))::INT, (SUBSTRING(v_arr_time FROM 3 FOR 2))::INT, 0);
                    IF v_check_out < v_check_in THEN
                        v_check_out := v_check_out + INTERVAL '1 day';
                    END IF;

                    IF v_airline IS NOT NULL AND v_airline <> '' THEN
                        v_aerolinea_vende := v_airline;
                    END IF;

                    IF v_orig IS NOT NULL AND v_dest IS NOT NULL THEN
                        v_iti_origenes := array_append(v_iti_origenes, v_orig);
                        v_iti_destinos := array_append(v_iti_destinos, v_dest);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, COALESCE(v_airline, 'AA'));
                        v_iti_vuelos := array_append(v_iti_vuelos, COALESCE(v_flight, '0000'));
                        v_iti_clases := array_append(v_iti_clases, COALESCE(v_class, 'Y'));
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_check_in);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_check_out);
                    END IF;
                END IF;
            END;
        END IF;

        -- Tiquetes, Valores e Impuestos M50 / M501 / M502
        IF v_line LIKE 'M50%' THEN
            DECLARE
                v_hash_pos INT;
                v_tkt_num TEXT := NULL;
                v_prestadora TEXT := 'AA';
                v_parts TEXT[];
                v_raw_tarifa TEXT;
                v_raw_tax TEXT;
                v_val_tarifa DOUBLE PRECISION := 0.0;
                v_val_tax DOUBLE PRECISION := 0.0;
                v_pay_type TEXT := 'TC';
                v_card_type TEXT := '';
                v_card_num TEXT := '';
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                -- 1. Numero de Tiquete y Prestadora Code
                v_hash_pos := POSITION('#' IN v_line);
                IF v_hash_pos > 2 THEN
                    v_prestadora := NULLIF(TRIM(SUBSTRING(v_line FROM v_hash_pos - 2 FOR 2)), '');
                    IF v_prestadora IS NULL THEN v_prestadora := 'AA'; END IF;
                END IF;

                IF v_hash_pos > 0 THEN
                    v_parts := string_to_array(v_line, '/');
                    IF array_length(v_parts, 1) >= 1 THEN
                        v_tkt_num := NULLIF(regexp_replace(v_parts[1], '^.*?#', ''), '');
                        IF v_tkt_num IS NOT NULL THEN
                            v_num_match := regexp_matches(v_tkt_num, '[0-9]{10,13}');
                            IF array_length(v_num_match, 1) >= 1 THEN
                                v_tkt_num := v_num_match[1];
                            END IF;
                        END IF;
                    END IF;

                    -- 2. Valor Tarifa (Segmento 3 por '/')
                    IF array_length(v_parts, 1) >= 3 THEN
                        v_raw_tarifa := regexp_replace(v_parts[3], '[^0-9.]', '', 'g');
                        IF v_raw_tarifa <> '' THEN
                            v_val_tarifa := v_raw_tarifa::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 3. Valor Otros Impuestos (Segmento 4 por '/')
                    IF array_length(v_parts, 1) >= 4 THEN
                        v_raw_tax := regexp_replace(v_parts[4], '[^0-9.]', '', 'g');
                        IF v_raw_tax <> '' THEN
                            v_val_tax := v_raw_tax::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 4. Forma de Pago y Tarjeta (Extraer franquicia VI/MC/AX/DC y numero despues de CC)
                    v_cc_pos := POSITION('CC' IN v_line);
                    IF v_cc_pos > 0 THEN
                        v_pay_type := 'TC';
                        v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                        IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                            v_card_type := v_cand_card;
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                        ELSE
                            v_card_type := '';
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                        END IF;

                        IF array_length(v_num_match, 1) >= 1 THEN
                            v_card_num := v_num_match[1];
                        END IF;
                    ELSIF POSITION('/CA ' IN v_line) > 0 OR POSITION('/CK ' IN v_line) > 0 THEN
                        v_pay_type := 'CA';
                        v_card_type := '';
                        v_card_num := '';
                    END IF;

                    IF v_tkt_num IS NOT NULL THEN
                        v_tkt_codes := array_append(v_tkt_codes, v_tkt_num);
                        v_tkt_prestadoras := array_append(v_tkt_prestadoras, COALESCE(v_prestadora, 'AA'));
                        v_tkt_tarifas := array_append(v_tkt_tarifas, v_val_tarifa);
                        v_tkt_impuestos := array_append(v_tkt_impuestos, v_val_tax);
                        v_tkt_pay_types := array_append(v_tkt_pay_types, v_pay_type);
                        v_tkt_pay_cards := array_append(v_tkt_pay_cards, v_card_type);
                        v_tkt_pay_numbers := array_append(v_tkt_pay_numbers, v_card_num);
                    END IF;
                END IF;
            END;
        END IF;

        -- Extracción de Parámetros y Variables M8 / M9 / RM
        IF v_line LIKE 'M8%' OR v_line LIKE 'M9%' OR v_line LIKE 'RM%' THEN
            DECLARE
                v_param RECORD;
                v_pref TEXT;
                v_pos INT;
                v_val TEXT;
            BEGIN
                -- M828AGENT* / M928AGENT*
                IF v_line LIKE 'M828AGENT*%' OR v_line LIKE 'M928AGENT*%' THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM 9 FOR 10));
                    v_seller := COALESCE(NULLIF(v_seller, ''), v_tiqueteador);
                END IF;

                -- Extracción por registros de InterfaceExtractParam
                FOR v_param IN 
                    SELECT p."fieldCode", p."fieldName", p.prefix, p.delimiter 
                    FROM public."InterfaceExtractParam" p
                    WHERE p."isActive" = true
                LOOP
                    v_pref := TRIM(COALESCE(v_param.prefix, ''));
                    IF v_pref <> '' AND POSITION(UPPER(v_pref) IN UPPER(v_line)) > 0 THEN
                        v_pos := POSITION(UPPER(v_pref) IN UPPER(v_line)) + length(v_pref);
                        v_val := TRIM(SUBSTRING(v_line FROM v_pos));

                        IF v_param."fieldCode" IN ('Client', 'CLI', 'Cliente') THEN
                            v_client := v_val;
                        ELSIF v_param."fieldCode" IN ('Branch', 'SUC', 'Sucursal') THEN
                            v_blanch := v_val;
                        ELSIF v_param."fieldCode" IN ('Implant', 'IMP', 'Implante') THEN
                            v_implant := v_val;
                        ELSIF v_param."fieldCode" IN ('TicketPrinter', 'ASE', 'Tiqueteador') THEN
                            v_tiqueteador := v_val;
                        ELSIF v_param."fieldCode" IN ('Seller', 'VEN', 'Vendedor') THEN
                            v_seller := v_val;
                        ELSE
                            -- Guardar Variable de Sistema Adicional (ej. 001, 002)
                            IF NOT (v_param."fieldCode" = ANY(v_var_codes)) THEN
                                v_var_codes := array_append(v_var_codes, v_param."fieldCode");
                                v_var_names := array_append(v_var_names, v_param."fieldName");
                                v_var_values := array_append(v_var_values, v_val);
                            END IF;
                        END IF;
                    END IF;
                END LOOP;

                -- Fallbacks estándar si no hay coincidencia en InterfaceExtractParam
                IF (v_client IS NULL OR v_client = '') AND POSITION('CLI-' IN v_line) > 0 THEN
                    v_client := TRIM(SUBSTRING(v_line FROM POSITION('CLI-' IN v_line) + 4));
                END IF;
                IF (v_blanch IS NULL OR v_blanch = '001') AND POSITION('SUC-' IN v_line) > 0 THEN
                    v_blanch := TRIM(SUBSTRING(v_line FROM POSITION('SUC-' IN v_line) + 4));
                END IF;
                IF (v_implant IS NULL OR v_implant = '') AND POSITION('IMP-' IN v_line) > 0 THEN
                    v_implant := TRIM(SUBSTRING(v_line FROM POSITION('IMP-' IN v_line) + 4));
                END IF;
                IF (v_tiqueteador IS NULL OR v_tiqueteador = '') AND POSITION('ASE-' IN v_line) > 0 THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM POSITION('ASE-' IN v_line) + 4));
                END IF;
                IF (v_seller IS NULL OR v_seller = '') AND POSITION('VEN-' IN v_line) > 0 THEN
                    v_seller := TRIM(SUBSTRING(v_line FROM POSITION('VEN-' IN v_line) + 4));
                END IF;

                -- Fallback para CC- (001) y FF- (002)
                IF POSITION('CC-' IN v_line) > 0 AND NOT ('001' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('CC-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '001');
                    v_var_names := array_append(v_var_names, 'centro de costo');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
                IF POSITION('FF-' IN v_line) > 0 AND NOT ('002' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('FF-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '002');
                    v_var_names := array_append(v_var_names, 'Fecha de Facturacion');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
            END;
        END IF;

    END LOOP;

    -- Validar existencia de PNR
    IF v_code IS NULL OR v_code = '' THEN
        RAISE EXCEPTION 'No se encontro codigo de reserva en la cabecera (AA).' USING ERRCODE = 'P0001';
    END IF;

    -- Upsert en BookingGDS con gds = 1 (SABRE)
    SELECT id INTO v_booking_gds_id FROM public."BookingGDS" WHERE "code" = v_code LIMIT 1;

    IF v_booking_gds_id IS NOT NULL THEN
        UPDATE public."BookingGDS" SET
            "type" = 'RES',
            "blanch" = COALESCE(v_blanch, '001'),
            "implant" = COALESCE(v_implant, ''),
            "client" = COALESCE(v_client, ''),
            "seller" = COALESCE(v_seller, ''),
            "tiquetPrinter" = COALESCE(v_tiqueteador, ''),
            "gds" = 1, -- 1 = SABRE
            "date" = CURRENT_TIMESTAMP,
            "currency" = v_currency,
            "exchangeRate" = v_exchangeRate,
            "booking" = p_Booking,
            "state" = 'NUEVO'
        WHERE id = v_booking_gds_id;

        DELETE FROM public."BookingProductVariableGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            v_code, 'RES', COALESCE(v_blanch, '001'), COALESCE(v_implant, ''), false, 1, CURRENT_TIMESTAMP, -- 1 = SABRE
            v_currency, v_exchangeRate, COALESCE(v_tiqueteador, ''), COALESCE(v_seller, ''), COALESCE(v_client, ''), 
            p_Booking, '1', '', 'Sabre Interface', '', 'NUEVO'
        ) RETURNING id INTO v_booking_gds_id;
    END IF;

    -- Creación de productos y detalles por tiquete / M50 o M2
    DECLARE
        v_num_tkts INT;
        v_tkt_i INT;
        v_prod_code TEXT;
        v_prod_prestadora TEXT;
        v_prod_tarifa DOUBLE PRECISION;
        v_prod_tax DOUBLE PRECISION;
        v_total_prod_price DOUBLE PRECISION;
        v_final_pay_type TEXT;
        v_final_pay_card TEXT;
        v_final_pay_number TEXT;
    BEGIN
        v_num_tkts := COALESCE(array_length(v_tkt_codes, 1), 0);
        IF v_num_tkts = 0 THEN
            v_num_tkts := 1;
            v_tkt_codes := ARRAY['VUE'];
            v_tkt_prestadoras := ARRAY[v_aerolinea_vende];
            v_tkt_tarifas := ARRAY[COALESCE(v_m2_tarifa, 0.0)];
            v_tkt_impuestos := ARRAY[0.0];
            v_tkt_pay_types := ARRAY[COALESCE(v_m2_pay_type, 'TC')];
            v_tkt_pay_cards := ARRAY[COALESCE(v_m2_pay_card, '')];
            v_tkt_pay_numbers := ARRAY[COALESCE(v_m2_pay_number, '')];
        END IF;

        FOR v_tkt_i IN 1 .. v_num_tkts LOOP
            v_prod_code := v_tkt_codes[v_tkt_i];
            v_prod_prestadora := COALESCE(v_tkt_prestadoras[v_tkt_i], v_aerolinea_vende);
            
            IF v_m2_tarifa > 0 THEN
                v_prod_tarifa := v_m2_tarifa;
            ELSE
                v_prod_tarifa := COALESCE(v_tkt_tarifas[v_tkt_i], 0.0);
            END IF;

            IF v_m2_total > 0 THEN
                v_total_prod_price := v_m2_total;
            ELSE
                v_prod_tax := COALESCE(v_tkt_impuestos[v_tkt_i], 0.0);
                v_total_prod_price := v_prod_tarifa + v_prod_tax;
            END IF;

            -- Forma de pago final priorizando datos extraídos
            v_final_pay_type := COALESCE(v_tkt_pay_types[v_tkt_i], v_m2_pay_type, 'TC');
            v_final_pay_card := COALESCE(NULLIF(v_tkt_pay_cards[v_tkt_i], ''), v_m2_pay_card, '');
            v_final_pay_number := COALESCE(NULLIF(v_tkt_pay_numbers[v_tkt_i], ''), v_m2_pay_number, '');

            -- Buscar proveedor por prestadora code
            SELECT code INTO v_provider_matched
            FROM public."Provider"
            WHERE UPPER(sigla) = UPPER(v_prod_prestadora) 
               OR UPPER(code) = UPPER(v_prod_prestadora)
               OR UPPER("airlineCode") = UPPER(v_prod_prestadora)
            LIMIT 1;

            -- Inserción de Producto (Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_prod_prestadora, COALESCE(v_provider_matched, v_prod_prestadora),
                1, v_total_prod_price, v_code, 1, 'NUEVO', 'VUE'
            ) RETURNING id INTO v_booking_product_gds_id;

            -- 1. Impuesto Tarifa (TAR)
            IF v_prod_tarifa > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tarifa
                );
            END IF;

            -- 2. Impuestos detallados con Homologación
            IF array_length(v_m2_tax_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_m2_tax_codes, 1) LOOP
                    DECLARE
                        v_tax_code_gds TEXT;
                        v_tax_amt DOUBLE PRECISION;
                        v_homolog_code TEXT := NULL;
                        v_homolog_name TEXT := NULL;
                    BEGIN
                        v_tax_code_gds := v_m2_tax_codes[v_i];
                        v_tax_amt := v_m2_tax_amounts[v_i];

                        SELECT eq.cd_codigo, cat.name
                        INTO v_homolog_code, v_homolog_name
                        FROM public."EquivalencesInterfaces" eq
                        LEFT JOIN public."ChargeAndTax" cat ON cat.code = eq.cd_codigo
                        WHERE eq.cd_maestro = 'ChargeAndTax'
                          AND UPPER(TRIM(eq.cd_codigointe)) = UPPER(TRIM(v_tax_code_gds))
                        LIMIT 1;

                        IF v_homolog_code IS NULL THEN
                            SELECT code, name
                            INTO v_homolog_code, v_homolog_name
                            FROM public."ChargeAndTax"
                            WHERE UPPER(code) = UPPER(v_tax_code_gds)
                            LIMIT 1;
                        END IF;

                        IF v_homolog_code IS NULL THEN
                            v_homolog_code := v_tax_code_gds;
                            v_homolog_name := v_tax_code_gds;
                        END IF;

                        INSERT INTO public."BookingProductTaxGDS" (
                            "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                        ) VALUES (
                            v_booking_product_gds_id, v_homolog_code, COALESCE(v_homolog_name, v_homolog_code), 'tax', false, 0, v_tax_amt
                        );
                    END;
                END LOOP;
            ELSIF v_prod_tax > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'OTR', 'Otros Impuestos', 'tax', false, 0, v_prod_tax
                );
            END IF;

            -- 3. Forma de Pago Única para ESTE tiquete
            IF v_final_pay_type IS NOT NULL AND v_final_pay_type <> '' THEN
                INSERT INTO public."BookingProductPaymentGDS" (
                    "bookingProductId", "code", "name", "type", "typecreditcard", "numbercreditcard", "amount"
                ) VALUES (
                    v_booking_product_gds_id, v_final_pay_type, v_final_pay_type, v_final_pay_type,
                    v_final_pay_card, COALESCE(v_final_pay_number, ''), v_total_prod_price
                );
            END IF;

            -- 4. Itinerario para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], 
                        v_iti_fechas_salida[v_i], v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], 
                        '', v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 5. Pasajero para este producto
            IF v_tkt_i <= COALESCE(array_length(v_pax_nombres, 1), 0) AND v_pax_nombres[v_tkt_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_tkt_i::TEXT, v_pax_nombres[v_tkt_i], v_pax_apellidos[v_tkt_i], '', COALESCE(v_tkt_codes[v_tkt_i], ''), '', ''
                );
            END IF;

            -- 6. Variables de Sistema Adicionales Extraídas
            IF array_length(v_var_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_var_codes, 1) LOOP
                    INSERT INTO public."BookingProductVariableGDS" (
                        "bookingProductId", "code", "name", "value"
                    ) VALUES (
                        v_booking_product_gds_id, v_var_codes[v_i], v_var_names[v_i], v_var_values[v_i]
                    );
                END LOOP;
            END IF;

        END LOOP;
    END;

    RAISE NOTICE 'Reserva Sabre PNR % procesada exitosamente.', v_code;
END;
$BODY$;

-- Alias case-insensitive para Npgsql / C#
CREATE OR REPLACE PROCEDURE public.spinterfacesabre(
    p_op TEXT,
    p_booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CALL public."spInterfaceSabre"(p_op, p_booking, p_file);
END;
$BODY$;
