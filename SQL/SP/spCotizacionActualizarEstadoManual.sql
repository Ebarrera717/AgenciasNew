DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionActualizarEstadoManual'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCotizacionActualizarEstadoManual(
    p_quotation_id INT,
    p_state TEXT,
    p_description TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validaciones
    IF p_state IS NULL OR p_state = '' THEN
        p_mensaje_resultado := 'ERROR: El estado es obligatorio.';
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public."Quotation" WHERE id = p_quotation_id) THEN
        p_mensaje_resultado := 'ERROR: La cotización con ID ' || p_quotation_id || ' no existe.';
        RETURN;
    END IF;

    -- Validar si el estado existe en la tabla de estados
    IF NOT EXISTS (SELECT 1 FROM public."QuotationState" WHERE code = p_state) THEN
        p_mensaje_resultado := 'ERROR: El estado "' || p_state || '" no es válido.';
        RETURN;
    END IF;

    UPDATE public."Quotation" SET
        "state" = p_state,
        "stateDescription" = p_description,
        "stateUpdatedAt" = CURRENT_TIMESTAMP
    WHERE id = p_quotation_id;

    -- Insertar historial de estado
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (p_quotation_id, p_state, p_description, CURRENT_TIMESTAMP, p_acting_user_id);

    p_mensaje_resultado := 'SUCCESS: Estado de cotización actualizado correctamente.';

    -- Registrar en Auditoría
    CALL public."spLogRegistrar"(
        p_acting_user_id, 
        'QUOTATION', 
        'UPDATE_STATE', 
        'Se cambió el estado de la cotización ID ' || p_quotation_id || ' a ' || p_state || '. Descripción: ' || COALESCE(p_description, ''), 
        jsonb_build_object('quotationId', p_quotation_id, 'state', p_state, 'description', p_description), 
        p_quotation_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
