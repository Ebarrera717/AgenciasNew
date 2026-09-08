DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPreCotizacionConvertir'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spPreCotizacionConvertir
-- Descripción: Procedimiento en PostgreSQL para registrar la conversión de una Pre-Cotización a Cotización,
--              o registrar únicamente la respuesta/duda sin convertir la pre-cotización.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spPreCotizacionConvertir"(
    IN p_pre_quotation_id INT,
    IN p_quotation_id INT,
    IN p_acting_user_id INT,
    IN p_notice_response TEXT,
    OUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_convert BOOLEAN;
    v_current_state TEXT;
    v_acting_user_id INT;
BEGIN
    IF p_pre_quotation_id IS NULL OR p_pre_quotation_id = 0 THEN
        p_mensaje_resultado := 'ERROR: ID de Pre-Cotización inválido.';
        RETURN;
    END IF;

    -- Obtener userId válido garantizado para evitar NOT NULL / FK violations
    SELECT COALESCE(
        (SELECT id FROM public."User" WHERE id = p_acting_user_id LIMIT 1),
        (SELECT "userId" FROM public."PreQuotation" WHERE id = p_pre_quotation_id),
        (SELECT id FROM public."User" ORDER BY id ASC LIMIT 1),
        1
    ) INTO v_acting_user_id;

    v_is_convert := (p_quotation_id IS NOT NULL AND p_quotation_id > 0);

    SELECT state INTO v_current_state FROM public."PreQuotation" WHERE id = p_pre_quotation_id;

    IF v_is_convert THEN
        UPDATE public."PreQuotation"
        SET state = 'COTIZADA',
            "convertedQuotationId" = p_quotation_id,
            "convertedAt" = CURRENT_TIMESTAMP,
            "convertedUserId" = v_acting_user_id,
            "noticeResponse" = COALESCE(p_notice_response, "noticeResponse"),
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = p_pre_quotation_id;

        INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
        VALUES (p_pre_quotation_id, 'COTIZADA', 'Pre-cotización convertida exitosamente a cotización (ID: ' || p_quotation_id::TEXT || ')', v_acting_user_id, CURRENT_TIMESTAMP);

        p_mensaje_resultado := 'SUCCESS: Pre-Cotización convertida a Cotización correctamente.';
    ELSE
        UPDATE public."PreQuotation"
        SET "noticeResponse" = COALESCE(p_notice_response, "noticeResponse"),
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = p_pre_quotation_id;

        INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
        VALUES (p_pre_quotation_id, COALESCE(v_current_state, 'POR COTIZAR'), 'Respuesta / Duda registrada en la pre-cotización: ' || COALESCE(p_notice_response, ''), v_acting_user_id, CURRENT_TIMESTAMP);

        p_mensaje_resultado := 'SUCCESS: Respuesta / Duda registrada en la Pre-Cotización correctamente.';
    END IF;
END;
$$;
