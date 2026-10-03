DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnProviderTypeListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnProviderTypeListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', pt.id,
            'code', pt.code,
            'name', pt.name,
            'isAirline', pt."isAirline",
            'active', pt.active,
            'isActive', COALESCE(pt."isActive", pt.active, true)
        )
    FROM public."ProviderType" pt
    ORDER BY pt.name ASC;
END;
$$;
