DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spInterfaceAmadeus'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE spInterfaceAmadeus(
    p_op TEXT,
    p_Booking TEXT,
    p_file TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables generales de control
    v_line TEXT;
    v_lines TEXT[];
    v_state INTEGER := 0;
    
    -- Variables para la tabla BookingGDS
    v_code VARCHAR(10);
    v_type VARCHAR(10);
    v_blanch VARCHAR(25) := 'BOG';
    v_implant VARCHAR(25);
    v_external BOOLEAN := false;
    v_date TIMESTAMP;
    v_currency VARCHAR(3) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_tiquetPrinter VARCHAR(25);
    v_seller VARCHAR(25);
    v_client VARCHAR(50);
    v_typetransaction VARCHAR(25) := '1';
    v_iata VARCHAR(25);
    v_description TEXT;
    v_observation TEXT;

    -- Variables temporales auxiliares
    v_nacionalidad INTEGER := 1;
    v_centrocosto VARCHAR(50);
    v_solicita VARCHAR(200);
    v_over VARCHAR(25);
    v_evento VARCHAR(250);
    v_highfare NUMERIC := 0;
    v_lowfare NUMERIC := 0;
    v_fare NUMERIC := 0;
    v_reasoncode VARCHAR(10);
    v_pax_cc VARCHAR(20);
    v_lapsoviaje VARCHAR(50);

    v_facturador VARCHAR(6);
    v_aerolinea_vende VARCHAR(10) := 'AV';
    v_provider_matched VARCHAR(50);
    v_tkt VARCHAR(20);
    
    -- Colecciones (Itinerarios, Pasajeros, Taxes, EMD, Pagos)
    v_iti_origenes TEXT[] := '{}';
    v_iti_destinos TEXT[] := '{}';
    v_iti_vuelos TEXT[] := '{}';
    v_iti_clases TEXT[] := '{}';
    v_iti_aerolineas TEXT[] := '{}';
    v_iti_farebasis TEXT[] := '{}';
    v_iti_fechas_llegada TIMESTAMP[] := '{}';
    v_iti_fechas_salida TIMESTAMP[] := '{}';

    v_pax_nombres TEXT[] := '{}';
    v_pax_apellidos TEXT[] := '{}';
    v_pax_prefixs TEXT[] := '{}';
    v_pax_tiquetes TEXT[] := '{}';
    v_pax_idx INTEGER := 0;

    v_tax_codes TEXT[] := '{}';
    v_tax_vals NUMERIC[] := '{}';
    v_tax_parsed BOOLEAN := false;
    v_id_master_chargeandtax INTEGER;
    v_raw_tax_code TEXT;
    v_equiv_tax_code TEXT;
    v_tax_exists_idx INTEGER;

    v_emd_codigos TEXT[] := '{}';
    v_emd_descripciones TEXT[] := '{}';
    v_emd_totales NUMERIC[] := '{}';

    v_pay_tipos TEXT[] := '{}';
    v_pay_tarjetas TEXT[] := '{}';
    v_pay_montos NUMERIC[] := '{}';
    v_pay_numbers TEXT[] := '{}';
    v_pay_expiries TEXT[] := '{}';
    v_pay_approvals TEXT[] := '{}';

    -- IDs de inserción
    v_booking_gds_id INTEGER;
    v_booking_product_gds_id INTEGER;
    v_booking_product_emd_id INTEGER;
    
    -- Variables para Tarifas
    v_am_tarifa NUMERIC := 0;
    v_am_tarifa_base NUMERIC := 0;
    v_am_impuestos NUMERIC := 0;
    v_am_otros NUMERIC := 0;
    v_am_tarifalocal NUMERIC := 0;
    v_am_total NUMERIC := 0;
    v_existing_booking TEXT;

    v_sub_line TEXT;
    v_i INTEGER;
    v_j INTEGER;

    v_parts TEXT[];
    v_item TEXT;
    v_clean_str TEXT;
    v_match TEXT[];
    v_val_monto NUMERIC;
BEGIN

    -- Obtener ID del Maestro ChargeAndTax para equivalencias
    SELECT id INTO v_id_master_chargeandtax FROM public."Master" WHERE code = 'ChargeAndTax' LIMIT 1;

    -- 1. Separar el archivo por saltos de línea
    v_lines := string_to_array(p_Booking, E'\n');
    
    -- Estado de la reserva
    IF p_Booking LIKE '%ENDX%' OR p_Booking LIKE '%END%' OR p_Booking LIKE '%CHD%' THEN
        v_state := 1;
    ELSE
        v_state := 0;
        RAISE EXCEPTION 'Reserva no confirmada: %', p_file;
    END IF;

    -- ==============================================================
    -- LECTURA ÚNICA DEL ARCHIVO: Extracción de datos y colecciones
    -- ==============================================================
    FOREACH v_line IN ARRAY v_lines
    LOOP
        v_line := rtrim(v_line, E'\r');
        
        -- D- Fechas (D-260716;260804...)
        IF starts_with(v_line, 'D-') THEN
            IF length(v_line) >= 14 THEN
                BEGIN
                    v_date := to_timestamp(substring(v_line from 9 for 6), 'YYMMDD');
                EXCEPTION WHEN OTHERS THEN
                    v_date := CURRENT_TIMESTAMP;
                END;
            END IF;

        -- Linea 3 (1A...;1A...;BOGZ12475;AIR) -> Sucursal y Pseudo
        ELSIF starts_with(v_line, '1A') AND position(';' in v_line) > 0 THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 3 THEN
                v_blanch := left(trim(v_parts[3]), 3);
                v_iata := trim(v_parts[3]);
            END IF;

        -- Linea MUC1A / M- / M (Localizador PNR)
        ELSIF (starts_with(v_line, 'MUC1A') OR starts_with(v_line, 'M-') OR starts_with(v_line, 'M')) AND v_code IS NULL THEN
            v_sub_line := trim(v_line);
            IF length(v_sub_line) >= 12 THEN
                v_code := trim(substring(v_sub_line from 7 for 6));
            END IF;
            
        -- A- Aerolínea Vendedora (Ej: A-LATAM AIRLINES COLOMBIA;4C)
        ELSIF starts_with(v_line, 'A-') THEN
            IF position(';' in v_line) > 0 THEN
                v_aerolinea_vende := LEFT(TRIM(split_part(v_line, ';', 2)), 2);
            ELSIF length(v_line) >= 12 THEN
                v_aerolinea_vende := LEFT(TRIM(substring(v_line from 11 for 2)), 2);
            END IF;
            IF v_aerolinea_vende IS NULL OR v_aerolinea_vende = '' THEN
                v_aerolinea_vende := 'AV';
            END IF;
            
        -- C- Agentes (Tiqueteador, Facturador, Vendedor)
        ELSIF starts_with(v_line, 'C-') THEN
            v_sub_line := substring(v_line from 3);
            v_parts := string_to_array(v_sub_line, '/');
            IF array_length(v_parts, 1) >= 1 THEN v_tiquetPrinter := trim(v_parts[1]); END IF;
            IF array_length(v_parts, 1) >= 2 THEN v_seller := left(trim(v_parts[2]), 6); END IF;

        -- H- ITINERARIOS
        ELSIF starts_with(v_line, 'H-') AND v_line NOT LIKE '%VOID%' THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 6 THEN
                DECLARE
                    v_origen VARCHAR(3);
                    v_destino VARCHAR(3);
                    v_aero VARCHAR(10);
                    v_vuelo VARCHAR(4);
                    v_clase VARCHAR(1);
                    v_f_str VARCHAR(100);
                    v_f_tokens TEXT[];
                    v_dia VARCHAR(2);
                    v_mes_str VARCHAR(3);
                    v_mes VARCHAR(2);
                    v_anio VARCHAR(4);
                    v_dep_h VARCHAR(2);
                    v_dep_m VARCHAR(2);
                    v_arr_h VARCHAR(2);
                    v_arr_m VARCHAR(2);
                    v_dt_token TEXT;
                    v_arr_token TEXT;
                    v_ts_salida TIMESTAMP;
                    v_ts_llegada TIMESTAMP;
                BEGIN
                    v_origen := right(trim(v_parts[2]), 3);
                    v_destino := trim(v_parts[4]);
                    
                    -- Normalizar espacios multiples en v_parts[6]
                    v_f_str := regexp_replace(trim(v_parts[6]), '\s+', ' ', 'g');
                    v_f_tokens := string_to_array(v_f_str, ' ');

                    IF array_length(v_f_tokens, 1) >= 6 THEN
                        v_aero := v_f_tokens[1];
                        v_vuelo := lpad(v_f_tokens[2], 4, '0');
                        v_clase := v_f_tokens[3];
                        v_dt_token := v_f_tokens[5]; -- ej: 15AUG0710
                        v_arr_token := v_f_tokens[6]; -- ej: 1130

                        IF length(v_dt_token) >= 9 THEN
                            v_dia := substring(v_dt_token from 1 for 2);
                            v_mes_str := upper(substring(v_dt_token from 3 for 3));
                            v_dep_h := substring(v_dt_token from 6 for 2);
                            v_dep_m := substring(v_dt_token from 8 for 2);
                        END IF;

                        IF length(v_arr_token) >= 4 THEN
                            v_arr_h := substring(v_arr_token from 1 for 2);
                            v_arr_m := substring(v_arr_token from 3 for 2);
                        END IF;

                        v_anio := to_char(COALESCE(v_date, CURRENT_TIMESTAMP), 'YYYY');
                        v_mes := CASE v_mes_str
                            WHEN 'JAN' THEN '01' WHEN 'FEB' THEN '02' WHEN 'MAR' THEN '03'
                            WHEN 'APR' THEN '04' WHEN 'MAY' THEN '05' WHEN 'JUN' THEN '06'
                            WHEN 'JUL' THEN '07' WHEN 'AUG' THEN '08' WHEN 'SEP' THEN '09'
                            WHEN 'OCT' THEN '10' WHEN 'NOV' THEN '11' WHEN 'DEC' THEN '12'
                            ELSE '01'
                        END;

                        BEGIN
                            v_ts_salida := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_dep_h, '00') || ':' || COALESCE(v_dep_m, '00'), 'YYYY-MM-DD HH24:MI');
                            v_ts_llegada := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_arr_h, '00') || ':' || COALESCE(v_arr_m, '00'), 'YYYY-MM-DD HH24:MI');
                        EXCEPTION WHEN OTHERS THEN
                            v_ts_salida := COALESCE(v_date, CURRENT_TIMESTAMP);
                            v_ts_llegada := COALESCE(v_date, CURRENT_TIMESTAMP);
                        END;

                        v_iti_origenes := array_append(v_iti_origenes, v_origen);
                        v_iti_destinos := array_append(v_iti_destinos, v_destino);
                        v_iti_vuelos := array_append(v_iti_vuelos, v_vuelo);
                        v_iti_clases := array_append(v_iti_clases, v_clase);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, v_aero);
                        IF array_length(v_f_tokens, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_f_tokens[7]));
                        ELSIF array_length(v_parts, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_parts[7]));
                        ELSE
                            v_iti_farebasis := array_append(v_iti_farebasis, '');
                        END IF;
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_ts_salida);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_ts_llegada);
                    END IF;
                END;
            END IF;

        -- I- PASAJEROS
        ELSIF starts_with(v_line, 'I-') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 2 THEN
                DECLARE
                    v_p_str TEXT;
                    v_pos_slash INT;
                    v_ape TEXT;
                    v_nom TEXT;
                    v_prefix VARCHAR(4) := 'MR';
                BEGIN
                    v_p_str := trim(v_parts[2]);
                    v_p_str := regexp_replace(v_p_str, '^[0-9]+', '');
                    v_pos_slash := position('/' in v_p_str);
                    IF v_pos_slash > 0 THEN
                        v_ape := substring(v_p_str from 1 for v_pos_slash - 1);
                        v_nom := substring(v_p_str from v_pos_slash + 1);
                        
                        IF v_nom LIKE '% MRS' OR v_nom LIKE '%MRS' THEN
                            v_prefix := 'MRS';
                            v_nom := trim(replace(v_nom, 'MRS', ''));
                        ELSIF v_nom LIKE '% MR' OR v_nom LIKE '%MR' THEN
                            v_prefix := 'MR';
                            v_nom := trim(replace(v_nom, 'MR', ''));
                        ELSIF v_nom LIKE '% MISS' OR v_nom LIKE '%MISS' THEN
                            v_prefix := 'MISS';
                            v_nom := trim(replace(v_nom, 'MISS', ''));
                        END IF;

                        v_pax_nombres := array_append(v_pax_nombres, trim(v_nom));
                        v_pax_apellidos := array_append(v_pax_apellidos, trim(v_ape));
                        v_pax_prefixs := array_append(v_pax_prefixs, v_prefix);
                        v_pax_tiquetes := array_append(v_pax_tiquetes, '');
                        v_pax_idx := v_pax_idx + 1;
                    END IF;
                END;
            END IF;

        -- T- TIQUETES (Extrae únicamente el número de 10 dígitos del tiquete)
        ELSIF starts_with(v_line, 'T-') THEN
            v_clean_str := substring(v_line from '[0-9]{10}');
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := split_part(split_part(v_line, ';', 1), '-', 3);
            END IF;
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := regexp_replace(split_part(v_line, ';', 1), '^.*-', '');
            END IF;
            v_tkt := trim(v_clean_str);
            IF v_pax_idx > 0 THEN
                v_pax_tiquetes[v_pax_idx] := v_tkt;
            END IF;

        -- IMPUESTOS (KFTR, KFTF, KNTB, KFTB, KSTF, KFTI, KNTI, KSTI) - Tomar la primera linea encontrada y aplicar equivalencias (fallback a 'OTR')
        ELSIF (starts_with(v_line, 'KFTR') OR starts_with(v_line, 'KFTF') OR starts_with(v_line, 'KNTB') OR starts_with(v_line, 'KFTB') 
           OR starts_with(v_line, 'KSTF') OR starts_with(v_line, 'KFTI') OR starts_with(v_line, 'KNTI') OR starts_with(v_line, 'KSTI')) AND NOT v_tax_parsed THEN
            v_parts := string_to_array(v_line, ';');
            FOR v_i IN 2 .. COALESCE(array_length(v_parts, 1), 0) LOOP
                v_item := trim(v_parts[v_i]);
                IF length(v_item) >= 6 THEN
                    v_match := regexp_matches(v_item, '(COP|USD|EUR)([0-9.]+)\s+([A-Z0-9]{2})');
                    IF array_length(v_match, 1) >= 3 THEN
                        v_raw_tax_code := v_match[3];
                        v_val_monto := v_match[2]::NUMERIC;

                        -- Evaluar equivalencia en DB. Si no existe mapeo, retorna 'OTR'
                        IF v_id_master_chargeandtax IS NOT NULL THEN
                            v_equiv_tax_code := public."fnEquivalenceInterface"(2, v_id_master_chargeandtax, v_raw_tax_code);
                        ELSE
                            v_equiv_tax_code := v_raw_tax_code;
                        END IF;

                        -- Verificar si el código equivalente ya fue agregado para sumar su valor
                        v_tax_exists_idx := 0;
                        FOR v_j IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                            IF v_tax_codes[v_j] = v_equiv_tax_code THEN
                                v_tax_exists_idx := v_j;
                                EXIT;
                            END IF;
                        END LOOP;

                        IF v_tax_exists_idx > 0 THEN
                            v_tax_vals[v_tax_exists_idx] := v_tax_vals[v_tax_exists_idx] + v_val_monto;
                        ELSE
                            v_tax_codes := array_append(v_tax_codes, v_equiv_tax_code);
                            v_tax_vals := array_append(v_tax_vals, v_val_monto);
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            v_tax_parsed := true;

        -- TARIFAS (K-F, K-R, KN-F, KN-R, KS-F, KS-R, ATC, K-B)
        ELSIF starts_with(v_line, 'K-') OR starts_with(v_line, 'KN-') OR starts_with(v_line, 'KS-') OR starts_with(v_line, 'ATC') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 1 THEN
                v_currency := COALESCE(substring(v_parts[1] from '[A-Z]{3}'), 'COP');
            END IF;

            FOREACH v_item IN ARRAY v_parts
            LOOP
                IF v_item LIKE '%COP%' OR v_item LIKE '%USD%' THEN
                    BEGIN
                        v_val_monto := cast(regexp_replace(v_item, '[^0-9.]', '', 'g') as NUMERIC);
                        IF v_val_monto > v_am_tarifalocal THEN
                            v_am_tarifalocal := v_val_monto;
                        END IF;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END LOOP;
            v_am_total := v_am_tarifalocal;

        -- EMD - Electronic Miscellaneous Document
        ELSIF starts_with(v_line, 'EMD') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 20 THEN
                v_emd_codigos := array_append(v_emd_codigos, substring(v_parts[1] from 4));
                v_emd_descripciones := array_append(v_emd_descripciones, trim(v_parts[19]));
                BEGIN
                    v_emd_totales := array_append(v_emd_totales, cast(regexp_replace(v_parts[array_length(v_parts, 1)], '[^0-9.]', '', 'g') as NUMERIC));
                EXCEPTION WHEN OTHERS THEN 
                    v_emd_totales := array_append(v_emd_totales, 0.0); 
                END;
            END IF;

        -- FP - FORMAS DE PAGO (Ej: FPCCVI0000000000007023E01/0528/A076194;S3;P1-2)
        ELSIF starts_with(v_line, 'FP') THEN
            DECLARE
                v_fp_clean TEXT;
                v_fp_tipo TEXT := 'CA';
                v_fp_monto NUMERIC := 0;
                v_fp_card_type TEXT := '';
                v_fp_card_number TEXT := '';
                v_fp_exp TEXT := '__/__';
                v_fp_auth TEXT := '';
                v_already_exists BOOLEAN := false;
            BEGIN
                v_fp_clean := regexp_replace(v_line, '^FP-?', '');
                IF v_fp_clean LIKE 'CASH%' OR v_fp_clean LIKE 'CA%' THEN
                    v_fp_tipo := 'CA';
                ELSIF v_fp_clean LIKE 'CC%' OR v_fp_clean LIKE 'TC%' THEN
                    v_fp_tipo := 'CC';
                    -- Extraer franquicia (ej: VI, MC, AX, DC)
                    v_fp_card_type := substring(v_fp_clean from '^(?:CC|TC)([A-Za-z]{2})');
                    IF v_fp_card_type IS NULL OR v_fp_card_type = '' THEN
                        v_fp_card_type := substring(v_line from 'FPCC([A-Za-z]{2})');
                    END IF;
                    IF v_fp_card_type IS NULL THEN v_fp_card_type := ''; END IF;

                    v_fp_card_number := substring(v_line from 'FPCC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from 'CC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    END IF;
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from '([0-9]{13,16})');
                    END IF;

                    v_fp_exp := substring(v_line from '/([0-9]{4})/');
                    IF v_fp_exp IS NULL OR v_fp_exp = '' THEN v_fp_exp := '__/__'; END IF;

                    v_fp_auth := substring(v_line from '/([A-Z0-9]+)(?:;|\s|$)');
                    IF v_fp_auth IS NULL THEN v_fp_auth := ''; END IF;
                END IF;

                IF v_fp_clean LIKE '%COP%' OR v_fp_clean LIKE '%USD%' THEN
                    BEGIN
                        v_fp_monto := cast(substring(v_fp_clean from '[0-9.]+') as NUMERIC);
                    EXCEPTION WHEN OTHERS THEN v_fp_monto := v_am_total; END;
                ELSE
                    v_fp_monto := COALESCE(v_am_total, 0);
                END IF;

                -- Prevenir duplicar la misma forma de pago registrada en múltiples líneas del archivo
                FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                    IF v_pay_tipos[v_i] = v_fp_tipo AND COALESCE(v_pay_numbers[v_i], '') = COALESCE(v_fp_card_number, '') THEN
                        v_already_exists := true;
                        EXIT;
                    END IF;
                END LOOP;

                IF NOT v_already_exists THEN
                    v_pay_tipos := array_append(v_pay_tipos, v_fp_tipo);
                    v_pay_tarjetas := array_append(v_pay_tarjetas, COALESCE(v_fp_card_type, ''));
                    v_pay_montos := array_append(v_pay_montos, v_fp_monto);
                    v_pay_numbers := array_append(v_pay_numbers, COALESCE(v_fp_card_number, ''));
                    v_pay_expiries := array_append(v_pay_expiries, v_fp_exp);
                    v_pay_approvals := array_append(v_pay_approvals, COALESCE(v_fp_auth, ''));
                END IF;
            END;

        -- OTROS REMARKS
        ELSIF v_line LIKE '%CENTRO COSTO%' THEN
            v_centrocosto := left(substring(v_line from position('CENTRO COSTO' in v_line) + 13), 50);
        ELSIF v_line LIKE '%SOLICITA%' THEN
            v_solicita := left(substring(v_line from position('SOLICITA' in v_line) + 9), 200);
        ELSIF v_line LIKE '%RM*NC-' AND v_client IS NULL THEN
            v_client := trim(split_part(v_line, '-', 2));
        END IF;

    END LOOP;

    -- Extracción dinámica de parámetros según reglas de la interfaz Amadeus (id_interfaces = 2) y resolución de equivalencias
    DECLARE
        v_dyn_val TEXT;
        v_id_master_client INTEGER;
        v_id_master_seller INTEGER;
        v_id_master_tp INTEGER;
        v_id_master_branch INTEGER;
        v_id_master_implant INTEGER;
        v_resolved_client TEXT;
        v_resolved_seller TEXT;
        v_resolved_tp TEXT;
        v_resolved_branch TEXT;
        v_resolved_implant TEXT;
    BEGIN
        SELECT id INTO v_id_master_client FROM public."Master" WHERE UPPER(code) = 'CLIENT' LIMIT 1;
        SELECT id INTO v_id_master_seller FROM public."Master" WHERE UPPER(code) = 'SELLER' LIMIT 1;
        SELECT id INTO v_id_master_tp FROM public."Master" WHERE UPPER(code) = 'TICKETPRINTER' LIMIT 1;
        SELECT id INTO v_id_master_branch FROM public."Master" WHERE UPPER(code) = 'BRANCH' LIMIT 1;
        SELECT id INTO v_id_master_implant FROM public."Master" WHERE UPPER(code) = 'IMPLANT' LIMIT 1;

        -- 1. CLIENT
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Client', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_client := v_dyn_val; END IF;
        IF v_client IS NOT NULL AND v_client <> '' THEN
            IF v_id_master_client IS NOT NULL THEN
                v_client := public."fnEquivalenceInterface"(2, v_id_master_client, v_client);
            END IF;
            SELECT document INTO v_resolved_client FROM public."Client" 
            WHERE document = v_client OR UPPER(name) ILIKE '%' || UPPER(v_client) || '%' OR CAST(id AS TEXT) = v_client LIMIT 1;
            IF v_resolved_client IS NOT NULL THEN v_client := v_resolved_client; END IF;
        END IF;

        -- 2. SELLER (Comprobar RM*VEN- o RM*VE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Seller', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_seller := v_dyn_val; END IF;
        IF v_seller IS NULL OR v_seller = '' THEN
            v_seller := substring(p_Booking from 'RM\*VEN-([A-Za-z0-9]+)');
            IF v_seller IS NULL OR v_seller = '' THEN
                v_seller := substring(p_Booking from 'RM\*VE-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_seller IS NOT NULL AND v_seller <> '' THEN
            IF v_id_master_seller IS NOT NULL THEN
                v_seller := public."fnEquivalenceInterface"(2, v_id_master_seller, v_seller);
            END IF;
            SELECT code INTO v_resolved_seller FROM public."Seller" 
            WHERE UPPER(code) = UPPER(v_seller) OR UPPER(name) ILIKE '%' || UPPER(v_seller) || '%' OR CAST(id AS TEXT) = v_seller LIMIT 1;
            IF v_resolved_seller IS NOT NULL THEN v_seller := v_resolved_seller; END IF;
        END IF;

        -- 3. TICKETPRINTER (Comprobar RM*TK- o RM*ASE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'TicketPrinter', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_tiquetPrinter := v_dyn_val; END IF;
        IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
            v_tiquetPrinter := substring(p_Booking from 'RM\*ASE-([A-Za-z0-9]+)');
            IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
                v_tiquetPrinter := substring(p_Booking from 'RM\*TK-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_tiquetPrinter IS NOT NULL AND v_tiquetPrinter <> '' THEN
            IF v_id_master_tp IS NOT NULL THEN
                v_tiquetPrinter := public."fnEquivalenceInterface"(2, v_id_master_tp, v_tiquetPrinter);
            END IF;
            SELECT code INTO v_resolved_tp FROM public."TicketPrinter" 
            WHERE UPPER(code) = UPPER(v_tiquetPrinter) OR UPPER(name) ILIKE '%' || UPPER(v_tiquetPrinter) || '%' OR CAST(id AS TEXT) = v_tiquetPrinter LIMIT 1;
            IF v_resolved_tp IS NOT NULL THEN v_tiquetPrinter := v_resolved_tp; END IF;
        END IF;

        -- 4. BRANCH
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Branch', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_blanch := v_dyn_val; END IF;
        IF v_blanch IS NOT NULL AND v_blanch <> '' THEN
            IF v_id_master_branch IS NOT NULL THEN
                v_blanch := public."fnEquivalenceInterface"(2, v_id_master_branch, v_blanch);
            END IF;
            SELECT code INTO v_resolved_branch FROM public."Branch" 
            WHERE UPPER(code) = UPPER(v_blanch) OR UPPER(name) ILIKE '%' || UPPER(v_blanch) || '%' OR CAST(id AS TEXT) = v_blanch LIMIT 1;
            IF v_resolved_branch IS NOT NULL THEN v_blanch := v_resolved_branch; END IF;
        END IF;

        -- 5. IMPLANT (RM*IMP-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Implant', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_implant := v_dyn_val; END IF;
        IF v_implant IS NULL OR v_implant = '' THEN
            v_implant := substring(p_Booking from 'RM\*IMP-([A-Za-z0-9]+)');
        END IF;
        IF v_implant IS NOT NULL AND v_implant <> '' THEN
            IF v_id_master_implant IS NOT NULL THEN
                v_implant := public."fnEquivalenceInterface"(2, v_id_master_implant, v_implant);
            END IF;
            SELECT code INTO v_resolved_implant FROM public."Implant" 
            WHERE UPPER(code) = UPPER(v_implant) OR UPPER(name) ILIKE '%' || UPPER(v_implant) || '%' OR CAST(id AS TEXT) = v_implant LIMIT 1;
            IF v_resolved_implant IS NOT NULL THEN v_implant := v_resolved_implant; END IF;
        END IF;
    END;

    -- ==============================================================
    -- VALIDACIÓN Y ASIGNACIÓN DE PROVEEDOR POR SIGLA DE AEROLÍNEA
    -- ==============================================================
    SELECT code INTO v_provider_matched
    FROM public."Provider"
    WHERE UPPER(sigla) = UPPER(v_aerolinea_vende) 
       OR UPPER(code) = UPPER(v_aerolinea_vende)
       OR UPPER("airlineCode") = UPPER(v_aerolinea_vende)
    LIMIT 1;

    -- ==============================================================
    -- INSERCIÓN EN TABLAS
    -- ==============================================================
    v_type := 'RES';
    v_description := COALESCE(v_evento, '') || ' ' || COALESCE(v_solicita, '');

    -- 1. Cabecera (Upsert y Verificación de Cambios)
    v_booking_gds_id := NULL;
    v_existing_booking := NULL;

    IF v_code IS NOT NULL AND v_code <> '' THEN
        SELECT id, "booking" INTO v_booking_gds_id, v_existing_booking 
        FROM public."BookingGDS" 
        WHERE "code" = v_code 
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NULL AND (v_tkt IS NOT NULL AND v_tkt <> '') THEN
        SELECT b."id", b."booking" INTO v_booking_gds_id, v_existing_booking
        FROM public."BookingGDS" b
        JOIN public."BookingProductGDS" bp ON bp."bookingId" = b."id"
        WHERE bp."code" = v_tkt
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NOT NULL THEN
        -- Sobrescribir la reserva y reemplazar sus detalles
        UPDATE public."BookingGDS" SET
            "type" = COALESCE(v_type, 'RES'), 
            "blanch" = v_blanch, 
            "implant" = COALESCE(v_implant, ''), 
            "external" = v_external, 
            "gds" = 2, 
            "date" = COALESCE(v_date, CURRENT_TIMESTAMP), 
            "currency" = v_currency, 
            "exchangeRate" = v_exchangeRate, 
            "tiquetPrinter" = COALESCE(v_tiquetPrinter, ''), 
            "seller" = COALESCE(v_seller, ''), 
            "client" = COALESCE(v_client, ''), 
            "booking" = p_Booking, 
            "typetransaction" = v_typetransaction, 
            "iata" = COALESCE(v_iata, ''), 
            "description" = v_description, 
            "observation" = v_observation, 
            "state" = CAST(v_state AS VARCHAR)
        WHERE "id" = v_booking_gds_id;

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
            COALESCE(v_code, 'DESC'), 
            COALESCE(v_type, 'RES'), 
            v_blanch, 
            COALESCE(v_implant, ''), 
            v_external, 
            2, 
            COALESCE(v_date, CURRENT_TIMESTAMP), 
            v_currency, 
            v_exchangeRate, 
            COALESCE(v_tiquetPrinter, ''), 
            COALESCE(v_seller, ''), 
            COALESCE(v_client, ''), 
            p_Booking, 
            v_typetransaction, 
            COALESCE(v_iata, ''), 
            v_description, 
            v_observation, 
            CAST(v_state AS VARCHAR)
        ) RETURNING "id" INTO v_booking_gds_id;
    END IF;

    -- ==============================================================
    -- CREACIÓN DE PRODUCTOS (UN PRODUCTO POR CADA TIQUETE / PASAJERO)
    -- ==============================================================
    DECLARE
        v_num_pax INTEGER;
        v_num_prods INTEGER;
        v_pax_i INTEGER;
        v_prod_code TEXT;
        v_prod_price NUMERIC;
        v_prod_tax_base NUMERIC;
        v_prod_tax_val NUMERIC;
        v_prod_pay_val NUMERIC;
    BEGIN
        v_num_pax := GREATEST(COALESCE(array_length(v_pax_nombres, 1), 0), COALESCE(array_length(v_pax_tiquetes, 1), 0));
        v_num_prods := GREATEST(1, v_num_pax);

        FOR v_pax_i IN 1 .. v_num_prods LOOP
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_tiquetes, 1) AND v_pax_tiquetes[v_pax_i] IS NOT NULL AND v_pax_tiquetes[v_pax_i] <> '' THEN
                v_prod_code := v_pax_tiquetes[v_pax_i];
            ELSE
                v_prod_code := COALESCE(v_tkt, 'VUE');
            END IF;

            v_prod_price := v_am_total;

            -- 2. Producto Padre (Vuelo / Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_aerolinea_vende, COALESCE(v_provider_matched, v_aerolinea_vende),
                1, v_prod_price, COALESCE(v_code, ''), v_nacionalidad, 'NUEVO', 'VUE'
            ) RETURNING "id" INTO v_booking_product_gds_id;

            -- 3. Detalle Itinerarios para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], v_iti_fechas_salida[v_i], 
                        v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], COALESCE(v_iti_farebasis[v_i], ''), v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 4. Detalle Pasajero para este producto
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_nombres, 1) AND v_pax_nombres[v_pax_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_pax_i::TEXT, v_pax_nombres[v_pax_i], v_pax_apellidos[v_pax_i], v_pax_prefixs[v_pax_i], COALESCE(v_pax_tiquetes[v_pax_i], ''), '', ''
                );
            END IF;

            -- 5. Detalle Impuestos (Taxes) completo para este producto
            v_am_impuestos := 0;
            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_am_impuestos := v_am_impuestos + COALESCE(v_tax_vals[v_i], 0);
                END IF;
            END LOOP;

            v_prod_tax_base := GREATEST(0, v_prod_price - v_am_impuestos);

            IF v_prod_tax_base > 0 OR v_prod_price <> 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tax_base
                );
            END IF;

            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_prod_tax_val := COALESCE(v_tax_vals[v_i], 0);
                    INSERT INTO public."BookingProductTaxGDS" (
                        "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_tax_codes[v_i], v_tax_codes[v_i], 'tax', false, 0, (v_prod_tax_val::DOUBLE PRECISION)
                    );
                END IF;
            END LOOP;

            -- 6. Formas de Pago proporcionales por tiquete para que la suma cuadre con el valor del tiquete
            FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                IF v_pay_tipos[v_i] IS NOT NULL THEN
                    v_prod_pay_val := COALESCE(v_pay_montos[v_i], v_am_total);
                    INSERT INTO public."BookingProductPaymentGDS" (
                        "bookingProductId", "bookingProductFEEId", "code", "name", "type", "typecreditcard", 
                        "numbercreditcard", "vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
                        "bank", "square", "reference", "policy", "policyannex", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, NULL, v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tarjetas[v_i],
                        COALESCE(v_pay_numbers[v_i], ''), '', COALESCE(v_pay_expiries[v_i], '__/__'), COALESCE(v_pay_approvals[v_i], ''), 0,
                        '', '', '', '', '', v_prod_pay_val
                    );
                END IF;
            END LOOP;

            -- 7. Variables Adicionales Dinámicas para este producto
            DECLARE
                r_param RECORD;
                v_var_value TEXT;
                v_mv_code TEXT;
                v_mv_name TEXT;
            BEGIN
                FOR r_param IN 
                    SELECT "fieldCode", "fieldName"
                    FROM public."InterfaceExtractParam"
                    WHERE "interfaceId" = 2
                      AND "isActive" = TRUE
                      AND UPPER("fieldCode") NOT IN ('CLIENT', 'SELLER', 'TICKETPRINTER', 'BRANCH', 'IMPLANT')
                LOOP
                    v_var_value := public."fnInterfaceExtractParamValue"(2, r_param."fieldCode", p_Booking);
                    IF v_var_value IS NOT NULL AND v_var_value <> '' THEN
                        SELECT code, name INTO v_mv_code, v_mv_name
                        FROM public."MasterVariable"
                        WHERE UPPER(code) = UPPER(r_param."fieldCode") OR UPPER(name) = UPPER(r_param."fieldName")
                        LIMIT 1;

                        IF v_mv_code IS NULL THEN
                            v_mv_code := r_param."fieldCode";
                            v_mv_name := r_param."fieldName";
                        END IF;

                        INSERT INTO public."BookingProductVariableGDS" (
                            "bookingProductId", "code", "name", "value"
                        ) VALUES (
                            v_booking_product_gds_id, v_mv_code, v_mv_name, v_var_value
                        );
                    END IF;
                END LOOP;
            END;

        END LOOP;
    END;

    -- 8. Productos EMD
    FOR v_i IN 1 .. COALESCE(array_length(v_emd_codigos, 1), 0) LOOP
        IF v_emd_codigos[v_i] IS NOT NULL THEN
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_emd_codigos[v_i], 'flight', COALESCE(v_emd_descripciones[v_i], ''), COALESCE(v_aerolinea_vende, ''), COALESCE(v_provider_matched, v_aerolinea_vende),
                1, COALESCE(v_emd_totales[v_i], 0), v_code, COALESCE(v_nacionalidad, 1), 'NUEVO', 'EMD'
            ) RETURNING "id" INTO v_booking_product_emd_id;
        END IF;
    END LOOP;

    RAISE NOTICE 'Amadeus Booking % successfully parsed and inserted.', v_code;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error processing Amadeus file: % - %', SQLSTATE, SQLERRM;
    ROLLBACK;
    RAISE;
END;
$$;
