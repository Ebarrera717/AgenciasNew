DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoActualizar(
    p_id INT,
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_branch_id INT,
    p_implant_id INT,
    p_fuente VARCHAR,
    p_serie VARCHAR,
    p_consecutivo BIGINT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    UPDATE public."SysConsecutivo"
    SET 
        "codigo" = TRIM(p_codigo),
        "nombre" = TRIM(p_nombre),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "fuente" = TRIM(p_fuente),
        "serie" = TRIM(p_serie),
        "consecutivo" = COALESCE(p_consecutivo, 0),
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo actualizado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
