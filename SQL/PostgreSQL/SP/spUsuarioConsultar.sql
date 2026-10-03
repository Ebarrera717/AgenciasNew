DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioConsultar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.spUsuarioConsultar(
    p_id INT DEFAULT NULL,
    p_email TEXT DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    "name" TEXT,
    "email" TEXT,
    "roleId" INT,
    "branchId" INT,
    "implantId" INT,
    "ticketPrinterId" INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name AS "name",
        u.email AS "email",
        u."roleId" AS "roleId",
        u."branchId" AS "branchId",
        u."implantId" AS "implantId",
        u."ticketPrinterId" AS "ticketPrinterId"
    FROM public."User" u
    WHERE (p_id IS NULL OR u.id = p_id)
      AND (p_email IS NULL OR u.email = p_email)
    ORDER BY u.id ASC;
END;
$$;
