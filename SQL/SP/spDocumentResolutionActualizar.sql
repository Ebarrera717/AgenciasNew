DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spDocumentResolutionActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spDocumentResolutionActualizar"(
    IN p_id integer,
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_resolution_number text,
    IN p_initial_number integer,
    IN p_final_number integer,
    IN p_current_number integer,
    IN p_resolution_date timestamp without time zone,
    IN p_prefix text,
    IN p_expiration_date timestamp without time zone,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID de resolución es obligatorio.';
        RETURN;
    END IF;

    IF p_branch_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        RETURN;
    END IF;

    IF p_resolution_number IS NULL OR TRIM(p_resolution_number) = '' THEN
        p_mensaje_resultado := 'ERROR: El número de resolución es obligatorio.';
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_final_number IS NULL OR p_initial_number > p_final_number THEN
        p_mensaje_resultado := 'ERROR: La numeración inicial no puede ser mayor que la numeración final.';
        RETURN;
    END IF;

    -- Si se activa esta resolución, deshabilitar las demás de la misma sucursal / implante
    IF COALESCE(p_is_active, false) = true THEN
        UPDATE public."DocumentResolution"
        SET "isActive" = false
        WHERE "branchId" = p_branch_id
          AND (
              ("implantId" IS NULL AND p_implant_id IS NULL)
              OR ("implantId" = p_implant_id)
          )
          AND id <> p_id
          AND "isActive" = true;
    END IF;

    UPDATE public."DocumentResolution"
    SET 
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "resolutionNumber" = TRIM(p_resolution_number),
        "initialNumber" = p_initial_number,
        "finalNumber" = p_final_number,
        "currentNumber" = COALESCE(p_current_number, "currentNumber"),
        "resolutionDate" = COALESCE(p_resolution_date, "resolutionDate"),
        "prefix" = TRIM(p_prefix),
        "expirationDate" = COALESCE(p_expiration_date, "expirationDate"),
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
