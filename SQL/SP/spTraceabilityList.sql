DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityList'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."spTraceabilityList"(
    p_code TEXT DEFAULT NULL,
    p_user_id INT DEFAULT NULL,
    p_module TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    code TEXT,
    "userId" INT,
    origin TEXT,
    userName TEXT,
    module TEXT,
    screen TEXT,
    action TEXT,
    process TEXT,
    status TEXT,
    "totalDurationMs" DOUBLE PRECISION,
    "errorMessage" TEXT,
    "eventCount" BIGINT,
    "createdAt" TIMESTAMP,
    "updatedAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.code,
        s."userId",
        COALESCE(s.origin, 'WEB') AS origin,
        COALESCE(u.name, 'Sistema / Anonimo') AS userName,
        s.module,
        s.screen,
        s.action,
        s.process,
        s.status,
        COALESCE(s."totalDurationMs", 0) AS "totalDurationMs",
        s."errorMessage",
        (SELECT COUNT(*) FROM public."TraceabilityLog" l WHERE l."sessionId" = s.id) AS "eventCount",
        s."createdAt",
        s."updatedAt"
    FROM public."TraceabilitySession" s
    LEFT JOIN public."User" u ON s."userId" = u.id
    WHERE (p_code IS NULL OR TRIM(p_code) = '' OR s.code ILIKE '%' || TRIM(p_code) || '%')
      AND (p_user_id IS NULL OR p_user_id = 0 OR s."userId" = p_user_id)
      AND (p_module IS NULL OR TRIM(p_module) = '' OR s.module ILIKE '%' || TRIM(p_module) || '%')
      AND (p_status IS NULL OR TRIM(p_status) = '' OR s.status ILIKE TRIM(p_status))
      AND (p_start_date IS NULL OR s."createdAt" >= p_start_date)
      AND (p_end_date IS NULL OR s."createdAt" <= p_end_date)
    ORDER BY s."createdAt" DESC
    LIMIT 100;
END;
$$;
