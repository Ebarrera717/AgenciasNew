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
            'internalNumber', i."internalNumber",
            'date', i.date,
            'dueDate', i."dueDate",
            'state', i.state,
            'clientName', COALESCE(c.name, ''),
            'totalAmount', COALESCE(i."totalAmount", 0)
        )
    FROM public."Invoices" i
    LEFT JOIN public."Client" c ON c.id = i."clientId"
    ORDER BY i.id DESC;
END;
$$;
