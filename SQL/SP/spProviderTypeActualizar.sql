DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProviderTypeActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProviderTypeActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_is_airline BOOLEAN,
    p_active BOOLEAN,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public."ProviderType" SET
        "code" = p_code,
        "name" = p_name,
        "isAirline" = COALESCE(p_is_airline, false),
        "active" = COALESCE(p_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
