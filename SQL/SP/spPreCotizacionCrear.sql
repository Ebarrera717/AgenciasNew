DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPreCotizacionCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spPreCotizacionCrear
-- Descripción: Procedimiento en PostgreSQL para crear Pre-Cotizaciones con consecutivo unificado compartido.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spPreCotizacionCrear"(
    IN p_data JSONB,
    IN p_acting_user_id INT,
    OUT p_pre_quotation_id INT,
    OUT p_consecutivo INT,
    OUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_consecutivo INT;
    v_branch_id INT;
BEGIN
    v_branch_id := NULLIF(p_data->>'branchId', '')::INT;

    IF v_branch_id IS NULL THEN
        p_pre_quotation_id := 0;
        p_consecutivo := 0;
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        RETURN;
    END IF;

    -- Obtener el consecutivo único compartido de la secuencia
    v_consecutivo := nextval('public.seq_quotation_consecutivo')::INT;

    INSERT INTO public."PreQuotation" (
        consecutivo,
        "clientNameText",
        "clientId",
        "headerDescription",
        "providerId",
        "ticketPrinterId",
        "sellerId",
        "branchId",
        "preQuotationType",
        "quotationNotice",
        "noticeResponse",
        "startDate",
        "endDate",
        "customFields",
        "state",
        "userId",
        "createdAt",
        "updatedAt"
    ) VALUES (
        v_consecutivo,
        p_data->>'clientNameText',
        NULLIF(p_data->>'clientId', '')::INT,
        p_data->>'headerDescription',
        NULLIF(p_data->>'providerId', '')::INT,
        NULLIF(p_data->>'ticketPrinterId', '')::INT,
        NULLIF(p_data->>'sellerId', '')::INT,
        v_branch_id,
        COALESCE(NULLIF(p_data->>'preQuotationType', ''), 'General'),
        p_data->>'quotationNotice',
        p_data->>'noticeResponse',
        CASE WHEN p_data->>'startDate' IS NOT NULL AND p_data->>'startDate' <> '' THEN (p_data->>'startDate')::TIMESTAMP ELSE NULL END,
        CASE WHEN p_data->>'endDate' IS NOT NULL AND p_data->>'endDate' <> '' THEN (p_data->>'endDate')::TIMESTAMP ELSE NULL END,
        COALESCE(p_data->'customFields', '{}'::jsonb),
        'POR COTIZAR',
        p_acting_user_id,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_pre_quotation_id;

    -- Historial de estado inicial
    INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
    VALUES (p_pre_quotation_id, 'POR COTIZAR', 'Creación de pre-cotización con consecutivo #' || v_consecutivo, p_acting_user_id, CURRENT_TIMESTAMP);

    p_consecutivo := v_consecutivo;
    p_mensaje_resultado := 'SUCCESS: Pre-Cotización creada correctamente con consecutivo #' || v_consecutivo;
END;
$$;
