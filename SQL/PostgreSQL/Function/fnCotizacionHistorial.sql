DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCotizacionHistorial'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public.fnCotizacionHistorial(VARCHAR, DATE, DATE, VARCHAR, VARCHAR, NUMERIC, VARCHAR, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.fnCotizacionHistorial(VARCHAR, DATE, DATE, VARCHAR, VARCHAR, NUMERIC, VARCHAR);
DROP FUNCTION IF EXISTS public.fnCotizacionHistorial();

CREATE OR REPLACE FUNCTION public.fnCotizacionHistorial(
    p_referencia VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_cliente VARCHAR DEFAULT NULL,
    p_elaborado_por VARCHAR DEFAULT NULL,
    p_monto_total NUMERIC DEFAULT NULL,
    p_estado VARCHAR DEFAULT NULL,
    p_reserva VARCHAR DEFAULT NULL,
    p_pasajero VARCHAR DEFAULT NULL
)
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_ref_clean VARCHAR;
    v_range_match TEXT[];
    v_id_start INT := NULL;
    v_id_end INT := NULL;
    v_single_id INT := NULL;
BEGIN
    IF p_referencia IS NOT NULL AND TRIM(p_referencia) <> '' THEN
        v_ref_clean := TRIM(p_referencia);
        -- Regex match for range e.g. "1-10", "01-10", "1 a 10", "1..10", "#1 - #10"
        v_range_match := regexp_match(v_ref_clean, '^\s*#?\s*(\d+)\s*(?:-|a|\.\.|\:|\s+a\s+)\s*#?\s*(\d+)\s*$', 'i');
        
        IF v_range_match IS NOT NULL THEN
            v_id_start := v_range_match[1]::INT;
            v_id_end := v_range_match[2]::INT;
            -- Ensure start is <= end
            IF v_id_start > v_id_end THEN
                v_single_id := v_id_start;
                v_id_start := v_id_end;
                v_id_end := v_single_id;
                v_single_id := NULL;
            END IF;
        ELSIF v_ref_clean ~ '^\s*#?\s*(\d+)\s*$' THEN
            v_single_id := (regexp_match(v_ref_clean, '(\d+)'))[1]::INT;
        END IF;
    END IF;

    -- Auto-reparación de cotizaciones cuyo userId quedó en NULL o en el fallback 1 cuando el Tiqueteador corresponde a otro Usuario creador registrado
    UPDATE public."Quotation" q_fix
    SET "userId" = sub.real_user_id
    FROM (
        SELECT q2.id AS quotation_id, u2.id AS real_user_id
        FROM public."Quotation" q2
        LEFT JOIN public."TicketPrinter" tp ON tp.id = q2."ticketPrinterId"
        LEFT JOIN public."User" u2 ON (
            u2."ticketPrinterId" = tp.id
            OR (NULLIF(TRIM(tp.email), '') IS NOT NULL AND LOWER(TRIM(u2.email)) = LOWER(TRIM(tp.email)))
            OR (NULLIF(TRIM(tp.name), '') IS NOT NULL AND UPPER(TRIM(u2.name)) = UPPER(TRIM(tp.name)))
        )
        WHERE (q2."userId" IS NULL OR q2."userId" = 1)
          AND tp.id IS NOT NULL
          AND u2.id IS NOT NULL
          AND u2.id <> 1
    ) sub
    WHERE q_fix.id = sub.quotation_id
      AND COALESCE(q_fix."userId", 0) <> sub.real_user_id;

    UPDATE public."QuotationStateHistory" qsh_fix
    SET "userId" = q_src."userId"
    FROM public."Quotation" q_src
    WHERE qsh_fix."quotationId" = q_src.id
      AND qsh_fix.state = 'NUEVO'
      AND (qsh_fix."userId" IS NULL OR qsh_fix."userId" = 1)
      AND q_src."userId" IS NOT NULL
      AND q_src."userId" <> 1;

    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q.id::text,
            'clientName', COALESCE(c.name, 'Cliente desconocido'),
            'providerName', COALESCE((
                SELECT prov.name 
                FROM public."QuotationProduct" qp
                JOIN public."Provider" prov ON qp."providerId" = prov.id
                WHERE qp."quotationId" = q.id
                LIMIT 1
            ), 'Proveedor Desconocido'),
            'createdAt', q.date,
            'totalAmount', COALESCE(
                NULLIF(q."totalAmount", 0),
                (
                    SELECT COALESCE(SUM(qpt."explicitAmount"), 0)
                    FROM public."QuotationProductTax" qpt
                    JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
                    WHERE qp."quotationId" = q.id
                ),
                (
                    SELECT COALESCE(SUM(qp.price * qp.quantity), 0)
                    FROM public."QuotationProduct" qp
                    WHERE qp."quotationId" = q.id
                ),
                0
            ),
            'currency', q.currency,
            'userName', COALESCE(
                (
                    SELECT u_init.name
                    FROM public."QuotationStateHistory" qsh_init
                    LEFT JOIN public."User" u_init ON u_init.id = qsh_init."userId"
                    WHERE qsh_init."quotationId" = q.id
                      AND qsh_init.state = 'NUEVO'
                      AND qsh_init."userId" IS NOT NULL
                      AND u_init.id IS NOT NULL
                      AND (qsh_init."userId" <> 1 OR q."userId" = 1)
                    ORDER BY qsh_init.id ASC
                    LIMIT 1
                ),
                u.name,
                'Sistema'
            ),
            'state', COALESCE(q.state, 'NUEVO'),
            'stateColor', (
                SELECT qs.color
                FROM public."QuotationState" qs
                WHERE UPPER(TRIM(qs.code)) = UPPER(TRIM(COALESCE(q.state, 'NUEVO')))
                   OR UPPER(TRIM(qs.name)) = UPPER(TRIM(COALESCE(q.state, 'NUEVO')))
                LIMIT 1
            ),
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'nights', COALESCE((
                SELECT qp.nights 
                FROM public."QuotationProduct" qp
                WHERE qp."quotationId" = q.id
                LIMIT 1
            ), 1),
            'reservationCode', COALESCE(
                NULLIF(q."reservationCode", ''),
                (
                    SELECT qp."reservationCode" 
                    FROM public."QuotationProduct" qp 
                    WHERE qp."quotationId" = q.id 
                    AND NULLIF(qp."reservationCode", '') IS NOT NULL 
                    LIMIT 1
                ),
                ''
            ),
            'passengerName', COALESCE(
                NULLIF(q.passenger, ''),
                (
                    SELECT qpax.name 
                    FROM public."QuotationProduct" qp
                    JOIN public."QuotationProductPassenger" qpax ON qpax."quotationProductId" = qp.id
                    WHERE qp."quotationId" = q.id
                    ORDER BY qpax.id ASC
                    LIMIT 1
                ),
                COALESCE((
                    SELECT qp.passenger 
                    FROM public."QuotationProduct" qp 
                    WHERE qp."quotationId" = q.id 
                    AND NULLIF(qp.passenger, '') IS NOT NULL 
                    LIMIT 1
                ), 'Mismo titular')
            )
        )
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."User" u ON q."userId" = u.id
    WHERE 
        (
            p_referencia IS NULL OR TRIM(p_referencia) = ''
            OR (v_id_start IS NOT NULL AND v_id_end IS NOT NULL AND q.id BETWEEN v_id_start AND v_id_end)
            OR (v_single_id IS NOT NULL AND q.id = v_single_id)
            OR (v_id_start IS NULL AND v_single_id IS NULL AND (
                q.id::text ILIKE '%' || p_referencia || '%' OR q."internalNumber" ILIKE '%' || p_referencia || '%'
            ))
        )
        AND (p_fecha_desde IS NULL OR q.date::date >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR q.date::date <= p_fecha_hasta)
        AND (p_cliente IS NULL OR TRIM(p_cliente) = '' OR (c.name IS NOT NULL AND c.name ILIKE '%' || TRIM(p_cliente) || '%'))
        AND (p_elaborado_por IS NULL OR TRIM(p_elaborado_por) = '' OR (u.name IS NOT NULL AND u.name ILIKE '%' || TRIM(p_elaborado_por) || '%'))
        AND (p_monto_total IS NULL OR q."totalAmount" = p_monto_total)
        AND (p_estado IS NULL OR TRIM(p_estado) = '' OR q.state ILIKE '%' || TRIM(p_estado) || '%')
        AND (
            p_reserva IS NULL OR TRIM(p_reserva) = ''
            OR q."reservationCode" ILIKE '%' || TRIM(p_reserva) || '%'
            OR EXISTS (
                SELECT 1 FROM public."QuotationProduct" qp 
                WHERE qp."quotationId" = q.id AND qp."reservationCode" ILIKE '%' || TRIM(p_reserva) || '%'
            )
        )
        AND (
            p_pasajero IS NULL OR TRIM(p_pasajero) = ''
            OR q.passenger ILIKE '%' || TRIM(p_pasajero) || '%'
            OR EXISTS (
                SELECT 1 FROM public."QuotationProduct" qp 
                LEFT JOIN public."QuotationProductPassenger" qpax ON qpax."quotationProductId" = qp.id
                WHERE qp."quotationId" = q.id 
                AND (qpax.name ILIKE '%' || TRIM(p_pasajero) || '%' OR qp.passenger ILIKE '%' || TRIM(p_pasajero) || '%')
            )
        )
    ORDER BY q.id DESC;
END;
$$;
