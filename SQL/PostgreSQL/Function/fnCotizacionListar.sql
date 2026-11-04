DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCotizacionListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public.fnCotizacionListar();

CREATE OR REPLACE FUNCTION public.fnCotizacionListar(
    p_referencia VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_cliente VARCHAR DEFAULT NULL,
    p_elaborado_por VARCHAR DEFAULT NULL,
    p_monto_total NUMERIC DEFAULT NULL,
    p_estado VARCHAR DEFAULT NULL
)
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
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

    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q.id::text,
            'date', q.date,
            'clientId', q."clientId",
            'currency', q.currency,
            'exchangeRate', q."exchangeRate",
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
            'state', q.state,
            'stateColor', (
                SELECT qs.color
                FROM public."QuotationState" qs
                WHERE UPPER(TRIM(qs.code)) = UPPER(TRIM(COALESCE(q.state, 'NUEVO')))
                   OR UPPER(TRIM(qs.name)) = UPPER(TRIM(COALESCE(q.state, 'NUEVO')))
                LIMIT 1
            ),
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'user', CASE WHEN u.id IS NOT NULL THEN jsonb_build_object('id', u.id, 'name', u.name) ELSE NULL END,
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object(
                'id', c.id,
                'name', c.name,
                'document', c.document
            ) ELSE jsonb_build_object('id', null, 'name', 'Cliente desconocido', 'document', '') END,
            'products', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', qp.id,
                            'productId', qp."productId",
                            'product', jsonb_build_object(
                                'id', p.id,
                                'description', p.description
                            ),
                            'provider', CASE WHEN prov.id IS NOT NULL THEN jsonb_build_object('id', prov.id, 'name', prov.name) ELSE NULL END,
                            'prestadora', CASE WHEN h.id IS NOT NULL THEN jsonb_build_object('id', h.id, 'name', h.name) ELSE NULL END,
                            'quantity', qp.quantity,
                            'price', qp.price,
                            'checkInDate', qp."checkInDate",
                            'checkOutDate', qp."checkOutDate",
                            'inNationality', COALESCE(qp."inNationality", 1),
                            'mainTaxId', qp."mainTaxId",
                            'passengers', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpax.id, 'name', qpax.name, 'document', qpax.document))
                                FROM public."QuotationProductPassenger" qpax
                                WHERE qpax."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'variables', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qvar.id, 'masterVariableId', qvar."masterVariableId", 'value', qvar.value))
                                FROM public."QuotationProductVariable" qvar
                                WHERE qvar."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'appliedTaxes', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('chargeAndTaxId', qpt."chargeAndTaxId", 'explicitAmount', qpt."explicitAmount", 'isMain', qpt."isMain"))
                                FROM public."QuotationProductTax" qpt
                                WHERE qpt."quotationProductId" = qp.id
                            ), '[]'::jsonb)
                        )
                    )
                    FROM public."QuotationProduct" qp
                    LEFT JOIN public."Product" p ON qp."productId" = p.id
                    LEFT JOIN public."Provider" prov ON qp."providerId" = prov.id
                    LEFT JOIN public."Prestadora" h ON qp."prestadoraId" = h.id
                    WHERE qp."quotationId" = q.id
                ),
                '[]'::jsonb
            )
        )
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."User" u ON q."userId" = u.id
    WHERE 
        (p_referencia IS NULL OR q.id::text ILIKE '%' || p_referencia || '%')
        AND (p_fecha_desde IS NULL OR q.date::date >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR q.date::date <= p_fecha_hasta)
        AND (p_cliente IS NULL OR TRIM(p_cliente) = '' OR (c.name IS NOT NULL AND c.name ILIKE '%' || TRIM(p_cliente) || '%'))
        AND (p_elaborado_por IS NULL OR TRIM(p_elaborado_por) = '' OR (u.name IS NOT NULL AND u.name ILIKE '%' || TRIM(p_elaborado_por) || '%'))
        AND (p_monto_total IS NULL OR q."totalAmount" = p_monto_total)
        AND (p_estado IS NULL OR TRIM(p_estado) = '' OR q.state ILIKE '%' || TRIM(p_estado) || '%')
    ORDER BY q.date DESC;
END;
$$;
