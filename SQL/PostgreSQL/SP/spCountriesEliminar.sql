DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spCountriesEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spCountriesEliminar"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountriesEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL public."spCountryEliminar"(p_id, p_user_id, p_mensaje_resultado);
END;
$$;
