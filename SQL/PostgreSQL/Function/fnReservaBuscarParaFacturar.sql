DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnReservaBuscarParaFacturar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnReservaBuscarParaFacturar(
    p_client TEXT DEFAULT NULL,
    p_passenger TEXT DEFAULT NULL,
    p_record TEXT DEFAULT NULL,
    p_ticket TEXT DEFAULT NULL,
    p_airline TEXT DEFAULT NULL
)
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', b.id,
            'code', b.code,
            'client', COALESCE(b.client, ''),
            'seller', COALESCE(b.seller, ''),
            'tiquetPrinter', COALESCE(b."tiquetPrinter", ''),
            'blanch', COALESCE(b.blanch, 'BOG'),
            'implant', COALESCE(b.implant, ''),
            'currency', COALESCE(b.currency, 'COP'),
            'exchangeRate', COALESCE(b."exchangeRate", 1.0),
            'date', b.date,
            'description', COALESCE(b.description, ''),
            'observation', COALESCE(b.observation, ''),
            'state', COALESCE(b.state, 'NUEVO'),
            'items', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', bp.id,
                        'code', COALESCE(bp.code, ''),
                        'type', COALESCE(bp.type, 'flight'),
                        'description', COALESCE(bp.description, bp.service, ''),
                        'prestadoracode', COALESCE(bp.prestadoracode, ''),
                        'provider', COALESCE(bp.provider, ''),
                        'quantity', COALESCE(bp.quantity, 1),
                        'price', COALESCE(bp.price, 0),
                        'cost', COALESCE(bp.cost, 0),
                        'checkInDate', bp."checkInDate",
                        'checkOutDate', bp."checkOutDate",
                        'nights', COALESCE(bp.nights, 0),
                        'paxAdults', COALESCE(bp."paxAdults", 1),
                        'paxChildren', COALESCE(bp."paxChildren", 0),
                        'serviceType', COALESCE(bp."serviceType", 'flight'),
                        'billingConcept', COALESCE(bp."billingConcept", ''),
                        'destination', COALESCE(bp.destination, ''),
                        'reservationCode', COALESCE(bp."reservationCode", b.code, ''),
                        'ticketCode', COALESCE((
                            SELECT string_agg(DISTINCT bpp2.identification, ', ')
                            FROM public."BookingProductPassangerGDS" bpp2
                            WHERE bpp2."bookingProductId" = bp.id AND bpp2.identification <> ''
                        ), ''),
                        'passengers', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'name', TRIM(COALESCE(bpp2.firstnm, '') || ' ' || COALESCE(bpp2.lastnm, '')),
                                    'document', COALESCE(bpp2.identification, '')
                                )
                            )
                            FROM public."BookingProductPassangerGDS" bpp2
                            WHERE bpp2."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'appliedTaxes', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'code', bpt.code,
                                    'name', bpt.name,
                                    'type', bpt.type,
                                    'amount', COALESCE(bpt.amount, 0),
                                    'ismain', COALESCE(bpt.ismain, false)
                                )
                            )
                            FROM public."BookingProductTaxGDS" bpt
                            WHERE bpt."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'payments', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'code', bpay.code,
                                    'name', bpay.name,
                                    'type', bpay.type,
                                    'typecreditcard', COALESCE(bpay.typecreditcard, ''),
                                    'numbercreditcard', COALESCE(bpay.numbercreditcard, ''),
                                    'vouchercreditcard', COALESCE(bpay.vouchercreditcard, ''),
                                    'authcreditcard', COALESCE(bpay.authcreditcard, ''),
                                    'amount', COALESCE(bpay.amount, 0)
                                )
                            )
                            FROM public."BookingProductPaymentGDS" bpay
                            WHERE bpay."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'itinerary', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'orden', bpi.orden,
                                    'origin', bpi.origin,
                                    'destination', bpi.destination,
                                    'class', bpi.class,
                                    'checkInDate', bpi."checkInDate",
                                    'checkOutDate', bpi."checkOutDate",
                                    'prestadoraCode', bpi."prestadoraCode",
                                    'farebasis', bpi.farebasis,
                                    'Numflight', bpi."Numflight",
                                    'amount', bpi.amount
                                )
                            )
                            FROM public."BookingProductItineraryGDS" bpi
                            WHERE bpi."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'variables', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'masterVariableId', COALESCE(mv.id, 0),
                                    'code', bpv.code,
                                    'name', bpv.name,
                                    'value', bpv.value
                                )
                            )
                            FROM public."BookingProductVariableGDS" bpv
                            LEFT JOIN public."MasterVariable" mv ON UPPER(mv.code) = UPPER(bpv.code) OR UPPER(mv.name) = UPPER(bpv.name)
                            WHERE bpv."bookingProductId" = bp.id
                        ), '[]'::jsonb)
                    )
                )
                FROM public."BookingProductGDS" bp
                WHERE bp."bookingId" = b.id
                  AND COALESCE(bp.state, '') <> 'FACTURADO' 
                  AND bp."invoiceId" IS NULL
            ), '[]'::jsonb)
        )
    FROM public."BookingGDS" b
    WHERE 
        EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_check 
            WHERE bp_check."bookingId" = b.id 
              AND COALESCE(bp_check.state, '') <> 'FACTURADO' 
              AND bp_check."invoiceId" IS NULL
        )
        AND (p_client IS NULL OR TRIM(p_client) = '' OR b.client ILIKE '%' || TRIM(p_client) || '%')
        AND (p_record IS NULL OR TRIM(p_record) = '' OR b.code ILIKE '%' || TRIM(p_record) || '%')
        AND (p_passenger IS NULL OR TRIM(p_passenger) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            INNER JOIN public."BookingProductPassangerGDS" bpp_sub ON bpp_sub."bookingProductId" = bp_sub.id
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND (
                (COALESCE(bpp_sub.firstnm, '') || ' ' || COALESCE(bpp_sub.lastnm, '')) ILIKE '%' || TRIM(p_passenger) || '%'
                OR bpp_sub.identification ILIKE '%' || TRIM(p_passenger) || '%'
            )
        ))
        AND (p_ticket IS NULL OR TRIM(p_ticket) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            INNER JOIN public."BookingProductPassangerGDS" bpp_sub ON bpp_sub."bookingProductId" = bp_sub.id
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND bpp_sub.identification ILIKE '%' || TRIM(p_ticket) || '%'
        ))
        AND (p_airline IS NULL OR TRIM(p_airline) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND (
                bp_sub.prestadoracode ILIKE '%' || TRIM(p_airline) || '%'
                OR bp_sub.provider ILIKE '%' || TRIM(p_airline) || '%'
            )
        ))
    ORDER BY b.id DESC
    LIMIT 50;
END;
$$;
