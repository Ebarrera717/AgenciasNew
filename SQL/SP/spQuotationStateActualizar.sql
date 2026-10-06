DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateActualizar"(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_color TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT,
    p_is_active BOOLEAN DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."QuotationState"
    SET code = COALESCE(TRIM(UPPER(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        color = COALESCE(p_color, color),
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: El estado con ID ' || p_id || ' no existe.';
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Estado de cotización actualizado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código "' || TRIM(p_code) || '" ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;
