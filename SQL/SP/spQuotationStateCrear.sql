DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateCrear"(
    p_code TEXT,
    p_name TEXT,
    p_color TEXT,
    p_acting_user_id INT,
    INOUT p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    -- Sincronizar automáticamente la secuencia al MAX(id) existente para evitar colisiones PK (error 23505)
    BEGIN
        SELECT MAX(id) INTO v_max FROM public."QuotationState";
        IF v_max IS NULL THEN
            PERFORM setval('public."QuotationState_id_seq"', 1, false);
        ELSE
            PERFORM setval('public."QuotationState_id_seq"', v_max, true);
        END IF;
    EXCEPTION WHEN OTHERS THEN
    END;

    INSERT INTO public."QuotationState" (code, name, color, "isActive")
    VALUES (TRIM(UPPER(p_code)), TRIM(p_name), COALESCE(p_color, 'blue'), true)
    RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización creado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        IF EXISTS (SELECT 1 FROM public."QuotationState" WHERE UPPER(TRIM(code)) = UPPER(TRIM(p_code))) THEN
            p_mensaje_resultado := 'ERROR: El código "' || TRIM(p_code) || '" ya existe.';
        ELSE
            p_mensaje_resultado := 'ERROR: Restricción única violada: ' || SQLERRM;
        END IF;
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;
