DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spDocumentResolutionCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spDocumentResolutionCrear"(
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_resolution_number text,
    IN p_initial_number integer,
    IN p_final_number integer,
    IN p_resolution_date timestamp without time zone,
    IN p_prefix text,
    IN p_expiration_date timestamp without time zone,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_resolution_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_curr integer;
BEGIN
    -- Validaciones básicas
    IF p_branch_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_resolution_number IS NULL OR TRIM(p_resolution_number) = '' THEN
        p_mensaje_resultado := 'ERROR: El número de resolución es obligatorio.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_final_number IS NULL OR p_initial_number > p_final_number THEN
        p_mensaje_resultado := 'ERROR: La numeración inicial no puede ser mayor que la numeración final.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_expiration_date IS NULL THEN
        p_mensaje_resultado := 'ERROR: La fecha de vencimiento es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    v_curr := COALESCE(p_initial_number, 1);

    -- REGLA: Si la nueva resolución es activa, desactivar cualquier otra resolución activa previa para esta misma combinación sucursal / implante
    IF COALESCE(p_is_active, true) = true THEN
        UPDATE public."DocumentResolution"
        SET "isActive" = false
        WHERE "branchId" = p_branch_id
          AND (
              ("implantId" IS NULL AND p_implant_id IS NULL)
              OR ("implantId" = p_implant_id)
          )
          AND "isActive" = true;
    END IF;

    INSERT INTO public."DocumentResolution" (
        "branchId",
        "implantId",
        "resolutionNumber",
        "initialNumber",
        "finalNumber",
        "currentNumber",
        "resolutionDate",
        "prefix",
        "expirationDate",
        "isActive",
        "createdAt"
    ) VALUES (
        p_branch_id,
        p_implant_id,
        TRIM(p_resolution_number),
        p_initial_number,
        p_final_number,
        v_curr,
        COALESCE(p_resolution_date, CURRENT_TIMESTAMP),
        TRIM(p_prefix),
        p_expiration_date,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_resolution_id := 0;
END;
$$;
