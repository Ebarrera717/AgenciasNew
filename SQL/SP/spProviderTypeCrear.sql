DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProviderTypeCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProviderTypeCrear(
    p_code TEXT,
    p_name TEXT,
    p_is_airline BOOLEAN,
    p_active BOOLEAN,
    p_acting_user_id INT,
    INOUT p_prov_type_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
    VALUES (p_code, p_name, COALESCE(p_is_airline, false), COALESCE(p_active, true))
    RETURNING id INTO p_prov_type_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor creado con ID ' || p_prov_type_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
