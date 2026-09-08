DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnInterfaceExtractParamValue'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnInterfaceExtractParamValue"(
    p_interface_id INTEGER,
    p_field_code TEXT,
    p_booking_file TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_prefix TEXT;
    v_delimiter TEXT;
    v_start_pos INTEGER;
    v_length INTEGER;
    v_line TEXT;
    v_extracted TEXT := NULL;
    v_pos INTEGER;
    v_lines TEXT[];
    i INTEGER;
BEGIN
    IF p_booking_file IS NULL OR TRIM(p_booking_file) = '' THEN
        RETURN NULL;
    END IF;

    -- 1. Buscar regla parametrizada para la interfaz y código de campo
    SELECT "prefix", "delimiter", "startPosition", "length"
    INTO v_prefix, v_delimiter, v_start_pos, v_length
    FROM public."InterfaceExtractParam"
    WHERE "interfaceId" = p_interface_id
      AND UPPER("fieldCode") = UPPER(TRIM(p_field_code))
      AND "isActive" = TRUE
    ORDER BY id DESC
    LIMIT 1;

    -- Fallbacks por defecto si no hay regla configurada
    IF v_prefix IS NULL OR v_prefix = '' THEN
        IF UPPER(TRIM(p_field_code)) = 'CLIENT' THEN
            v_prefix := 'RM*NC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_prefix := 'RM*VEN-';
        ELSIF UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_prefix := 'RM*TK-';
        ELSIF UPPER(TRIM(p_field_code)) = 'BRANCH' THEN
            v_prefix := 'RM*SUC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'IMPLANT' THEN
            v_prefix := 'RM*IMP-';
        ELSE
            RETURN NULL;
        END IF;
    END IF;

    IF v_delimiter IS NULL THEN
        v_delimiter := '-';
    END IF;

    -- 2. Dividir archivo en líneas
    v_lines := string_to_array(p_booking_file, E'\n');

    -- 3. Recorrer líneas buscando el prefijo constante
    FOR i IN 1..array_length(v_lines, 1) LOOP
        v_line := TRIM(v_lines[i]);
        v_line := REPLACE(v_line, E'\r', '');

        v_pos := POSITION(v_prefix IN v_line);
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_pos := POSITION('RM*VE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*VE-'; END IF;
        END IF;
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_pos := POSITION('RM*ASE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*ASE-'; END IF;
        END IF;
        IF v_pos > 0 THEN
            v_extracted := SUBSTRING(v_line FROM v_pos + CHAR_LENGTH(v_prefix));
            v_extracted := TRIM(v_extracted);

            IF v_delimiter IS NOT NULL AND v_delimiter <> '' THEN
                v_pos := POSITION(v_delimiter IN v_extracted);
                IF v_pos > 1 THEN
                    v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_pos - 1);
                END IF;
            END IF;

            IF v_length IS NOT NULL AND v_length > 0 AND CHAR_LENGTH(v_extracted) > v_length THEN
                v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_length);
            END IF;

            v_extracted := TRIM(v_extracted);
            IF v_extracted <> '' THEN
                RETURN v_extracted;
            END IF;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$;
