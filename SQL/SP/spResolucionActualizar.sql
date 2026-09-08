DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spResolucionActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spResolucionActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_date TIMESTAMP WITH TIME ZONE,
    p_expira TIMESTAMP WITH TIME ZONE,
    p_inicial BIGINT,
    p_end BIGINT,
    p_autoriza TEXT,
    p_prefijo TEXT,
    p_alerta INT,
    p_day INT,
    p_permitir BOOLEAN,
    p_activo BOOLEAN,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Resolution" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Resolución con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."Resolution"
    SET "code" = p_code,
        "name" = p_name,
        "date" = p_date,
        "expira" = p_expira,
        "inicial" = p_inicial,
        "end" = p_end,
        "autoriza" = p_autoriza,
        "prefijo" = p_prefijo,
        "alerta" = p_alerta,
        "day" = p_day,
        "permitir" = COALESCE(p_permitir, false),
        "activo" = COALESCE(p_activo, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Resolución actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
