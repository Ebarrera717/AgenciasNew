DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCountryListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCountryListar"()
RETURNS TABLE(id integer, code text, name text, dane text, region text, prefix text, "curencyId" integer)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT c.id, c.code::text, c.name::text, c.dane::text, c.region::text, c.prefix::text, c."curencyId" FROM public."Countries" c ORDER BY c.id ASC;
END; $function$;