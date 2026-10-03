DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCityCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCityCrear"(IN p_code text, IN p_name text, IN p_countriesId integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Cities" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Cities" ("code", "name", "countriesId", "statecode", "iata") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_countriesId, p_statecode, p_iata) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $procedure$;