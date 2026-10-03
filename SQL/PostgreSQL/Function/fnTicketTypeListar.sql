DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnTicketTypeListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;


CREATE OR REPLACE FUNCTION public."fnTicketTypeListar"()
RETURNS TABLE(id integer, code text, name text, description text, "isActive" boolean)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT t.id, t.code::text, t.name::text, t.description::text, t."isActive" FROM public."TicketType" t ORDER BY t.name ASC;
END; $function$;
