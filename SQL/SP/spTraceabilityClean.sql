DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityClean'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTraceabilityClean"(
    IN p_days INT DEFAULT 30,
    INOUT p_mensaje_resultado TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted_logs INT := 0;
    v_deleted_sessions INT := 0;
BEGIN
    DELETE FROM public."TraceabilityLog"
    WHERE "createdAt" < (NOW() - (p_days || ' days')::INTERVAL);
    GET DIAGNOSTICS v_deleted_logs = ROW_COUNT;

    DELETE FROM public."TraceabilitySession"
    WHERE "createdAt" < (NOW() - (p_days || ' days')::INTERVAL);
    GET DIAGNOSTICS v_deleted_sessions = ROW_COUNT;

    p_mensaje_resultado := 'SUCCESS: ' || v_deleted_sessions || ' sesiones y ' || v_deleted_logs || ' eventos de trazabilidad depurados anteriores a ' || p_days || ' días.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
