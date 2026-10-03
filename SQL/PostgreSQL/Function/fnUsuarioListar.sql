DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnUsuarioListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnUsuarioListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', u.id,
            'name', u.name,
            'email', u.email,
            'roleId', u."roleId",
            'role', (
                SELECT jsonb_build_object('id', r.id, 'name', r.name)
                FROM public."Role" r
                WHERE r.id = u."roleId"
            ),
            'branchId', u."branchId",
            'branch', CASE WHEN u."branchId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', b.id, 'name', b.name, 'code', b.code)
                FROM public."Branch" b
                WHERE b.id = u."branchId"
            ) ELSE NULL END,
            'implantId', u."implantId",
            'implant', CASE WHEN u."implantId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', i.id, 'name', i.name, 'code', i.code)
                FROM public."Implant" i
                WHERE i.id = u."implantId"
            ) ELSE NULL END,
            'ticketPrinterId', u."ticketPrinterId",
            'ticketPrinter', CASE WHEN u."ticketPrinterId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', t.id, 'name', t.name, 'code', t.code)
                FROM public."TicketPrinter" t
                WHERE t.id = u."ticketPrinterId"
            ) ELSE NULL END
        )
    FROM public."User" u
    ORDER BY u.name ASC;
END;
$$;
