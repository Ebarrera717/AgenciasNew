DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnProveedorListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnProveedorListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'name', p.name,
            'contactInfo', p."contactInfo",
            'commissionConfig', p."commissionConfig",
            'providerTypeId', p."providerTypeId",
            'providerTypeName', pt.name,
            'isAirline', COALESCE(pt."isAirline", false),
            'airlineCode', p."airlineCode",
            'sigla', p."sigla",
            'isActive', COALESCE(p."isActive", true),
            'prestadoras', COALESCE((
                SELECT jsonb_agg(h)
                FROM public."Prestadora" h
                WHERE h."providerId" = p.id
            ), '[]'::jsonb)
        )
    FROM public."Provider" p
    LEFT JOIN public."ProviderType" pt ON pt.id = p."providerTypeId"
    ORDER BY p.name ASC;
END;
$$;
