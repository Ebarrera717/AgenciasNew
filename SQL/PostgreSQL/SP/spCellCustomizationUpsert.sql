DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCellCustomizationUpsert'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCellCustomizationUpsert(
    p_code text,
    p_name text,
    p_value text,
    p_branch_id integer,
    p_implant_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, p_branch_id, NULL)
        ON CONFLICT ("branchId", "code") WHERE "branchId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    ELSIF p_implant_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, NULL, p_implant_id)
        ON CONFLICT ("implantId", "code") WHERE "implantId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    END IF;
END;
$$;
