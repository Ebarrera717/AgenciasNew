DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'sploglistar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- sploglistar.sql
-- RUTA: c:\Proyectos\AgenciasNew\SQL\SP\spLogListar.sql

CREATE OR REPLACE FUNCTION public.sploglistar(
    p_limit INT DEFAULT 100,
    p_offset INT DEFAULT 0,
    p_module TEXT DEFAULT NULL,
    p_user_id INT DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    "userId" INT,
    "userName" TEXT,
    "action" TEXT,
    "module" TEXT,
    "description" TEXT,
    "metadata" JSON,
    "createdAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l."userId",
        u.name AS "userName",
        l.action AS "action",
        l.module AS "module",
        l.description AS "description",
        l.metadata::JSON AS "metadata",
        l."createdAt" AS "createdAt"
    FROM public."SystemLog" l
    LEFT JOIN public."User" u ON l."userId" = u.id
    WHERE (p_module IS NULL OR l.module = UPPER(p_module))
      AND (p_user_id IS NULL OR l."userId" = p_user_id)
    ORDER BY l."createdAt" DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;
