DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."SysConsecutivo"
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo eliminado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
