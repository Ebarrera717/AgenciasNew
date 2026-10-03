DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCellCustomizationDelete'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCellCustomizationDelete(
    p_code text,
    p_branch_id integer,
    p_implant_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "branchId" = p_branch_id AND "implantId" IS NULL;
    ELSIF p_implant_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "implantId" = p_implant_id;
    END IF;
END;
$$;
