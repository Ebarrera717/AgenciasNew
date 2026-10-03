DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoCrear(
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_branch_id INT,
    p_implant_id INT,
    p_fuente VARCHAR,
    p_serie VARCHAR,
    p_consecutivo BIGINT,
    p_acting_user_id INT,
    INOUT p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    INSERT INTO public."SysConsecutivo" (
        "codigo", "nombre", "branchId", "implantId", "fuente", "serie", "consecutivo", "createdAt", "updatedAt"
    ) VALUES (
        TRIM(p_codigo), TRIM(p_nombre), p_branch_id, p_implant_id, TRIM(p_fuente), TRIM(p_serie), COALESCE(p_consecutivo, 0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id INTO p_id;

    p_mensaje_resultado := 'SUCCESS: Consecutivo creado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
