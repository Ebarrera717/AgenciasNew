DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCotizacion'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnCotizacion(p_quotation_id INT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
            'date', q.date,
            'clientId', q."clientId",
            'currency', q.currency,
            'exchangeRate', q."exchangeRate",
            'branchId', q."branchId",
            'implantId', q."implantId",
            'sellerId', q."sellerId",
            'ticketPrinterId', q."ticketPrinterId",
            'commissionPercentage', q."commissionPercentage",
            'chargesAndTaxes', q."chargesAndTaxes",
            'totalAmount', q."totalAmount",
            'state', q.state,
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'costoTotal', COALESCE(q."costoTotal", 0),
            'valorBase', COALESCE(q."valorBase", 0),
            'utilidad', COALESCE(q.utilidad, 0),
            'comisionTotalPercentage', COALESCE(q."comisionTotalPercentage", q."commissionPercentage", 0),
            'comisionFreelancePercentage', COALESCE(q."comisionFreelancePercentage", 0),
            'comisionFreelanceValue', COALESCE(q."comisionFreelanceValue", 0),
            'comisionPropiaPercentage', COALESCE(q."comisionPropiaPercentage", q."commissionPercentage", 0),
            'comisionPropiaValue', COALESCE(q."comisionPropiaValue", 0),
            'comisionUtilidadPercentage', COALESCE(q."comisionUtilidadPercentage", 0),
            'destination', q.destination,
            'startDate', q."startDate",
            'endDate', q."endDate",
            'passengerFirstName', COALESCE(NULLIF(TRIM(q."passengerFirstName"), ''), CASE WHEN q.passenger IS NOT NULL AND TRIM(q.passenger) <> '' THEN SPLIT_PART(TRIM(q.passenger), ' ', 1) ELSE '' END),
            'passengerLastName', COALESCE(NULLIF(TRIM(q."passengerLastName"), ''), CASE WHEN q.passenger IS NOT NULL AND POSITION(' ' IN TRIM(q.passenger)) > 0 THEN SUBSTRING(TRIM(q.passenger) FROM POSITION(' ' IN TRIM(q.passenger)) + 1) ELSE '' END),
            'passenger', q.passenger,
            'paxAdults', q."paxAdults",
            'paxChildren', q."paxChildren",
            'reservationCode', q."reservationCode",
            'copyFieldsToProducts', COALESCE(q."copyFieldsToProducts", true),
            'manualDescription', q."manualDescription",
            'observations', q."observations"
        ) || jsonb_build_object(
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object(
                'id', c.id,
                'name', c.name,
                'document', c.document
            ) ELSE jsonb_build_object('id', null, 'name', 'Cliente desconocido', 'document', '') END,
            'seller', CASE WHEN s.id IS NOT NULL THEN jsonb_build_object('id', s.id, 'name', s.name) ELSE NULL END,
            'branch', CASE WHEN b.id IS NOT NULL THEN jsonb_build_object('id', b.id, 'name', b.name) ELSE NULL END,
            'implant', CASE WHEN imp.id IS NOT NULL THEN jsonb_build_object('id', imp.id, 'name', imp.name) ELSE NULL END,
            'ticketPrinter', CASE WHEN tp.id IS NOT NULL THEN jsonb_build_object('id', tp.id, 'name', tp.name) ELSE NULL END,
            'user', CASE WHEN qu.id IS NOT NULL THEN jsonb_build_object('id', qu.id, 'name', qu.name) ELSE NULL END,
            'userName', COALESCE(qu.name, 'Sistema'),
            'combos', COALESCE((
                SELECT jsonb_agg(jsonb_build_object('id', qc."comboId", 'comboId', qc."comboId", 'name', cb.name))
                FROM public."QuotationCombo" qc
                JOIN public."Combo" cb ON qc."comboId" = cb.id
                WHERE qc."quotationId" = q.id
            ), '[]'::jsonb),
            'manualServices', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', ms.id,
                        'serviceName', ms."serviceName",
                        'name', ms."serviceName",
                        'salePrice', ms."salePrice",
                        'amount', ms."salePrice",
                        'cost', ms.cost,
                        'utility', ms.utility,
                        'providerName', ms."providerName"
                    )
                )
                FROM public."QuotationManualService" ms
                WHERE ms."quotationId" = q.id
            ), '[]'::jsonb),
            'stateHistory', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', qsh.id,
                            'quotationId', qsh."quotationId",
                            'state', qsh.state,
                            'description', qsh.description,
                            'userId', qsh."userId",
                            'userName', COALESCE(u.name, 'Sistema'),
                            'createdAt', qsh."createdAt",
                            'metadata', qsh.metadata
                        ) ORDER BY qsh."createdAt" DESC, qsh.id DESC
                    )
                    FROM public."QuotationStateHistory" qsh
                    LEFT JOIN public."User" u ON qsh."userId" = u.id
                    WHERE qsh."quotationId" = q.id
                ),
                jsonb_build_array(
                    jsonb_build_object(
                        'id', q.id,
                        'quotationId', q.id,
                        'state', COALESCE(q.state, 'NUEVO'),
                        'description', COALESCE(q."stateDescription", 'Creación de cotización'),
                        'userId', q."userId",
                        'userName', COALESCE(qu.name, 'Sistema'),
                        'createdAt', COALESCE(q."stateUpdatedAt", q.date, NOW()),
                        'metadata', jsonb_build_object(
                            'initialState', COALESCE(q.state, 'NUEVO'),
                            'totalAmount', q."totalAmount",
                            'destination', q.destination,
                            'passenger', q.passenger
                        )
                    )
                )
            ),
            'products', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', qp.id,
                            'productId', qp."productId",
                            'product', jsonb_build_object(
                                'id', p.id,
                                'description', p.description,
                                'code', p.code
                            ),
                            'provider', CASE WHEN prov.id IS NOT NULL THEN jsonb_build_object('id', prov.id, 'name', prov.name) ELSE NULL END,
                            'prestadora', CASE WHEN h.id IS NOT NULL THEN jsonb_build_object('id', h.id, 'name', h.name) ELSE NULL END,
                            'providerId', qp."providerId",
                            'prestadoraId', qp."prestadoraId",
                            'quantity', qp.quantity,
                            'price', qp.price,
                            'cost', qp.cost,
                            'checkInDate', qp."checkInDate",
                            'checkOutDate', qp."checkOutDate",
                            'nights', qp.nights,
                            'paxAdults', qp."paxAdults",
                            'paxChildren', qp."paxChildren",
                            'serviceType', qp."serviceType",
                            'destination', qp.destination,
                            'reservationCode', qp."reservationCode",
                            'sellerCommission', qp."sellerCommission",
                            'ticketPrinterCommission', qp."ticketPrinterCommission",
                            'comboId', qp."comboId",
                            'mainTaxId', qp."mainTaxId",
                            'inNationality', COALESCE(qp."inNationality", 1),
                            'service', COALESCE(qp.service, qp.servicios),
                            'servicios', COALESCE(qp.servicios, qp.service),
                            'descripcion', qp.descripcion,
                            'passengerFirstName', qp."passengerFirstName",
                            'passengerLastName', qp."passengerLastName",
                            'passenger', qp.passenger,
                            'providerDueDate', qp."providerDueDate",
                            'providerInvoice', qp."providerInvoice",
                            'passengers', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpax.id, 'firstName', qpax."firstName", 'lastName', qpax."lastName", 'name', qpax.name, 'document', qpax.document))
                                FROM public."QuotationProductPassenger" qpax
                                WHERE qpax."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'variables', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qvar.id, 'masterVariableId', qvar."masterVariableId", 'value', qvar.value))
                                FROM public."QuotationProductVariable" qvar
                                WHERE qvar."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'appliedTaxes', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpt."chargeAndTaxId", 'chargeAndTaxId', qpt."chargeAndTaxId", 'explicitAmount', qpt."explicitAmount", 'valueSnapshot', qpt."valueSnapshot", 'valueTypeSnapshot', qpt."valueTypeSnapshot", 'isMain', qpt."isMain"))
                                FROM public."QuotationProductTax" qpt
                                WHERE qpt."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'payments', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object(
                                    'id', qpmt.id,
                                    'amount', qpmt.amount,
                                    'paymentMethod', qpmt."paymentMethod",
                                    'date', qpmt.date,
                                    'reference', qpmt.reference,
                                    'creditCardId', qpmt."creditCardId",
                                    'cardNumber', qpmt."cardNumber",
                                    'authorizationCode', qpmt."authorizationCode",
                                    'voucher', qpmt.voucher,
                                    'expirationDate', qpmt."expirationDate"
                                ))
                                FROM public."QuotationProductPayment" qpmt
                                WHERE qpmt."quotationProductId" = qp.id
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
    INTO v_result
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."Seller" s ON q."sellerId" = s.id
    LEFT JOIN public."Branch" b ON q."branchId" = b.id
    LEFT JOIN public."Implant" imp ON q."implantId" = imp.id
    LEFT JOIN public."TicketPrinter" tp ON q."ticketPrinterId" = tp.id
    LEFT JOIN public."User" qu ON q."userId" = qu.id
    WHERE q.id = p_quotation_id;

    RETURN v_result;
END;
$$;
