DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityGetDetails'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."spTraceabilityGetDetails"(
    p_code TEXT
)
RETURNS TABLE (
    log_id INT,
    session_code TEXT,
    "userId" INT,
    origin TEXT,
    userName TEXT,
    "eventType" TEXT,
    "stepName" TEXT,
    "spName" TEXT,
    endpoint TEXT,
    "durationMs" DOUBLE PRECISION,
    status TEXT,
    "inputData" JSONB,
    "outputData" JSONB,
    "techMessage" TEXT,
    "functionalMessage" TEXT,
    "stackTrace" TEXT,
    "affectedId" TEXT,
    "createdAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id AS log_id,
        l.code AS session_code,
        l."userId",
        COALESCE(l.origin, 'WEB') AS origin,
        COALESCE(u.name, 'Sistema / Anonimo') AS userName,
        l."eventType",
        l."stepName",
        l."spName",
        l.endpoint,
        COALESCE(l."durationMs", 0) AS "durationMs",
        l.status,
        l."inputData",
        l."outputData",
        l."techMessage",
        l."functionalMessage",
        l."stackTrace",
        l."affectedId",
        l."createdAt"
    FROM public."TraceabilityLog" l
    LEFT JOIN public."User" u ON l."userId" = u.id
    WHERE l.code = p_code OR l."sessionId" IN (SELECT id FROM public."TraceabilitySession" WHERE code = p_code)
    ORDER BY l.id ASC;
END;
$$;
