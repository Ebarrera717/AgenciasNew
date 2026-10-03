DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spLogRegistrar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spLogRegistrar"(
    p_user_id INT, 
    p_module TEXT, 
    p_action TEXT, 
    p_description TEXT, 
    p_metadata JSONB, 
    INOUT p_temp_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."SystemLog" (
        "userId", "module", "action", "description", "metadata", "createdAt"
    ) VALUES (
        p_user_id, UPPER(p_module), UPPER(p_action), p_description, p_metadata, NOW()
    ) RETURNING id INTO p_temp_id;
END;
$$;