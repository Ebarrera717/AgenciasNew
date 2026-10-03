DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spVariableCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spVariableCrear(
    p_code TEXT,
    p_name TEXT,
    p_acting_user_id INT,
    INOUT p_variable_id INT,
    INOUT p_mensaje_resultado TEXT,
    p_is_for_all_clients BOOLEAN DEFAULT false
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."MasterVariable" ("code", "name", "isForAllClients")
    VALUES (p_code, p_name, COALESCE(p_is_for_all_clients, false))
    RETURNING id INTO p_variable_id;

    p_mensaje_resultado := 'SUCCESS: Variable creada con ID ' || p_variable_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
