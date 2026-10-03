DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spParameterEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spParameterEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Parámetro con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."SystemParameter" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Parámetro eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
