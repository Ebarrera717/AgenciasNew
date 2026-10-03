DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnInvoicesListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnInvoicesListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', i.id,
            'internalNumber', i."internalNumber",
            'date', i.date,
            'dueDate', i."dueDate",
            'state', COALESCE(i.state, 'NUEVO'),
            'isExcelImport', COALESCE(i."isExcelImport", false),
            'zeusInvoiceNumber', i."zeusInvoiceNumber",
            'fuente', i.fuente,
            'serie', i.serie,
            'consecutivo', i.consecutivo,
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object('id', c.id, 'name', c.name, 'document', c.document) ELSE jsonb_build_object('id', null, 'name', 'Consumidor Final', 'document', '') END,
            'clientName', COALESCE(c.name, 'Consumidor Final'),
            'totalAmount', COALESCE(i."totalAmount", 0),
            'currency', COALESCE(i.currency, 'COP'),
            'products', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', ip.id,
                            'productId', ip."productId",
                            'ticketCode', ip."ticketCode",
                            'checkInDate', ip."checkInDate",
                            'checkOutDate', ip."checkOutDate",
                            'nights', ip.nights,
                            'paxAdults', ip."paxAdults",
                            'paxChildren', ip."paxChildren",
                            'mainTaxId', ip."mainTaxId",
                            'provider', CASE WHEN prov.id IS NOT NULL THEN jsonb_build_object('id', prov.id, 'name', prov.name) ELSE NULL END,
                            'prestadora', CASE WHEN h.id IS NOT NULL THEN jsonb_build_object('id', h.id, 'name', h.name) ELSE NULL END,
                            'passengers', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', pax.id, 'name', pax.name, 'document', pax.document))
                                FROM public."InvoicesProductPasenger" pax
                                WHERE pax."invoiceProductId" = ip.id
                            ), '[]'::jsonb)
                        )
                    )
                    FROM public."InvoicesProduct" ip
                    LEFT JOIN public."Provider" prov ON ip."providerId" = prov.id
                    LEFT JOIN public."Prestadora" h ON ip."prestadoraId" = h.id
                    WHERE ip."invoiceId" = i.id
                ),
                '[]'::jsonb
            )
        )
    FROM public."Invoices" i
    LEFT JOIN public."Client" c ON c.id = i."clientId"
    ORDER BY i.id DESC;
END;
$$;
