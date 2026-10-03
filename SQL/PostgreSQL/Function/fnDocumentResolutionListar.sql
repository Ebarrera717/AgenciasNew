DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnDocumentResolutionListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnDocumentResolutionListar"()
RETURNS TABLE (
    id integer,
    "branchId" integer,
    "branchName" text,
    "implantId" integer,
    "implantName" text,
    "resolutionNumber" text,
    "initialNumber" integer,
    "finalNumber" integer,
    "currentNumber" integer,
    "resolutionDate" timestamp without time zone,
    "prefix" text,
    "expirationDate" timestamp without time zone,
    "isActive" boolean,
    "createdAt" timestamp without time zone
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dr.id,
        dr."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        dr."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        dr."resolutionNumber"::text,
        dr."initialNumber",
        dr."finalNumber",
        dr."currentNumber",
        dr."resolutionDate",
        COALESCE(dr.prefix, '')::text,
        dr."expirationDate",
        dr."isActive",
        dr."createdAt"
    FROM public."DocumentResolution" dr
    LEFT JOIN public."Branch" b ON b.id = dr."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = dr."implantId"
    ORDER BY dr.id DESC;
END;
$$;
