DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPaymentEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spPaymentEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
BEGIN
    DELETE FROM public."Payment" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;