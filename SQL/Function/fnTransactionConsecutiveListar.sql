DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnTransactionConsecutiveListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnTransactionConsecutiveListar"()
RETURNS TABLE (
    id integer,
    "transactionType" text,
    "description" text,
    "prefix" text,
    "initialNumber" integer,
    "currentNumber" integer,
    "branchId" integer,
    "branchName" text,
    "implantId" integer,
    "implantName" text,
    "isActive" boolean,
    "createdAt" timestamp without time zone
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.id,
        tc."transactionType"::text,
        tc."description"::text,
        COALESCE(tc.prefix, '')::text,
        tc."initialNumber",
        tc."currentNumber",
        tc."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        tc."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        tc."isActive",
        tc."createdAt"
    FROM public."TransactionConsecutive" tc
    LEFT JOIN public."Branch" b ON b.id = tc."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = tc."implantId"
    ORDER BY tc.id DESC;
END;
$$;
