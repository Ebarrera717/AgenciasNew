DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spCountriesCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spCountriesCrear"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountriesCrear"(
    IN p_code text,
    IN p_name text,
    IN p_dane text,
    IN p_region text,
    IN p_prefix text,
    IN p_curencyId integer,
    IN p_user_id integer,
    INOUT p_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL public."spCountryCrear"(p_code, p_name, p_dane, p_region, p_prefix, p_curencyId, p_user_id, p_id, p_mensaje_resultado);
END;
$$;
