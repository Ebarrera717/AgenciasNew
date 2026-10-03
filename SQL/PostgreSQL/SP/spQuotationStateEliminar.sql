DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateEliminar"(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public."QuotationState" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización eliminado correctamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;
