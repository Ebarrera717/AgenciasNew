DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnInvoicesListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnInvoicesListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', i.id,
            'code', i.code,
            'createdAt', i."createdAt",
            'updatedAt', i."updatedAt",
            'state', i.state,
            'clientName', COALESCE(c.name, ''),
            'total', COALESCE(i.total, 0)
        )
    FROM public."Invoice" i
    LEFT JOIN public."Client" c ON c.id = i."clientId"
    ORDER BY i.id DESC;
END;
$$;
