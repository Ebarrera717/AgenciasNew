DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spResolucionCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spResolucionCrear(
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
    INOUT p_resolution_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Resolution" (
        "code", "name", "date", "expira", "inicial", "end", "autoriza", "prefijo", "alerta", "day", "permitir", "activo"
    )
    VALUES (
        p_code, p_name, p_date, p_expira, p_inicial, p_end, p_autoriza, p_prefijo, p_alerta, p_day, COALESCE(p_permitir, false), COALESCE(p_activo, true)
    )
    RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS: Resolución creada con ID ' || p_resolution_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
