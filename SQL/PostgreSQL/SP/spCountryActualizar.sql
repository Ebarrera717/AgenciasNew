DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCountryActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountryActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyId integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Countries" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Countries" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Countries" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "dane" = p_dane, "region" = p_region, "prefix" = p_prefix, "curencyId" = p_curencyId WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;