DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityLog'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTraceabilityLog"(
    IN p_code TEXT,
    IN p_user_id INT,
    IN p_origin TEXT,
    IN p_module TEXT,
    IN p_screen TEXT,
    IN p_action TEXT,
    IN p_process TEXT,
    IN p_event_type TEXT,
    IN p_step_name TEXT,
    IN p_sp_name TEXT,
    IN p_endpoint TEXT,
    IN p_duration_ms DOUBLE PRECISION,
    IN p_status TEXT,
    IN p_input_data JSONB,
    IN p_output_data JSONB,
    IN p_tech_message TEXT,
    IN p_functional_message TEXT,
    IN p_stack_trace TEXT,
    IN p_affected_id TEXT,
    INOUT p_mensaje_resultado TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Registro de sesiones y eventos individuales de trazabilidad y diagnóstico con taxonomía de origen.
*/
DECLARE
    v_session_id INT;
    v_mode TEXT := 'OFF';
    v_origin TEXT := COALESCE(NULLIF(TRIM(p_origin), ''), 'WEB');
BEGIN
    -- Leer modo actual de trazabilidad
    SELECT value INTO v_mode FROM public."SystemParameter" WHERE UPPER(code) = 'TRACEABILITY_MODE';
    v_mode := COALESCE(UPPER(v_mode), 'OFF');

    -- Si el modo está deshabilitado y no es un evento de ERROR/EXCEPCION, omitir
    IF v_mode = 'OFF' AND UPPER(COALESCE(p_event_type, '')) NOT IN ('ERROR', 'EXCEPCION') THEN
        p_mensaje_resultado := 'TRACE_DISABLED';
        RETURN;
    END IF;

    -- Garantizar sesión principal
    SELECT id INTO v_session_id FROM public."TraceabilitySession" WHERE code = p_code;

    IF v_session_id IS NULL THEN
        INSERT INTO public."TraceabilitySession" (
            "code", "userId", "origin", "module", "screen", "action", "process", "status", "errorMessage"
        ) VALUES (
            p_code, p_user_id, v_origin, COALESCE(p_module, 'GENERAL'), p_screen, COALESCE(p_action, 'EJECUCION'), p_process,
            CASE 
                WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(COALESCE(p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(COALESCE(p_status, '')) = 'SUCCESS' OR UPPER(COALESCE(p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE COALESCE(p_status, 'IN_PROGRESS')
            END,
            CASE WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN COALESCE(p_functional_message, p_tech_message) ELSE NULL END
        ) RETURNING id INTO v_session_id;
    ELSE
        UPDATE public."TraceabilitySession" SET
            "updatedAt" = NOW(),
            "origin" = COALESCE(v_origin, "origin"),
            "totalDurationMs" = COALESCE("totalDurationMs", 0) + COALESCE(p_duration_ms, 0),
            "status" = CASE 
                WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(COALESCE(p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(COALESCE(p_status, '')) = 'SUCCESS' OR UPPER(COALESCE(p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE "status"
            END,
            "errorMessage" = CASE WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN COALESCE(p_functional_message, p_tech_message, "errorMessage") ELSE "errorMessage" END
        WHERE id = v_session_id;
    END IF;

    -- Registrar evento en TraceabilityLog
    INSERT INTO public."TraceabilityLog" (
        "sessionId", "code", "userId", "origin", "eventType", "stepName", "spName", "endpoint",
        "durationMs", "status", "inputData", "outputData", "techMessage", "functionalMessage",
        "stackTrace", "affectedId"
    ) VALUES (
        v_session_id, p_code, p_user_id, v_origin, COALESCE(p_event_type, 'INFO'), COALESCE(p_step_name, 'PASO'),
        p_sp_name, p_endpoint, COALESCE(p_duration_ms, 0), COALESCE(p_status, 'SUCCESS'),
        p_input_data, p_output_data, p_tech_message, p_functional_message,
        p_stack_trace, p_affected_id
    );

    p_mensaje_resultado := 'SUCCESS: Evento registrado en traza ' || p_code;
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
