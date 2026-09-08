DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnPreCotizacionListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Función: fnPreCotizacionListar
-- Descripción: Consulta el listado de Pre-Cotizaciones con LEFT JOIN obligatorio,
--              cálculo de tiempos transcurridos y trazabilidad unificada (Pre-Cotización -> Cotización -> Factura).
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE FUNCTION public."fnPreCotizacionListar"(
    p_search TEXT DEFAULT NULL,
    p_state TEXT DEFAULT NULL,
    p_branch_id INT DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    consecutivo INT,
    client_name TEXT,
    client_id INT,
    header_description TEXT,
    provider_id INT,
    provider_name TEXT,
    ticket_printer_id INT,
    ticket_printer_name TEXT,
    seller_id INT,
    seller_name TEXT,
    branch_id INT,
    branch_name TEXT,
    pre_quotation_type TEXT,
    quotation_notice TEXT,
    notice_response TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    custom_fields JSONB,
    state TEXT,
    user_id INT,
    user_name TEXT,
    created_at TIMESTAMP,
    converted_quotation_id INT,
    converted_internal_number TEXT,
    converted_at TIMESTAMP,
    converted_user_name TEXT,
    invoice_number TEXT,
    elapsed_minutes INT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.consecutivo,
        COALESCE(c.name, p."clientNameText", 'Cliente sin nombre')::TEXT AS client_name,
        p."clientId",
        COALESCE(p."headerDescription", '')::TEXT,
        p."providerId",
        COALESCE(pr.name, '')::TEXT AS provider_name,
        p."ticketPrinterId",
        COALESCE(tp.name, '')::TEXT AS ticket_printer_name,
        p."sellerId",
        COALESCE(s.name, '')::TEXT AS seller_name,
        p."branchId",
        COALESCE(b.name, '')::TEXT AS branch_name,
        COALESCE(p."preQuotationType", 'General')::TEXT,
        COALESCE(p."quotationNotice", '')::TEXT,
        COALESCE(p."noticeResponse", '')::TEXT,
        p."startDate",
        p."endDate",
        COALESCE(p."customFields", '{}'::jsonb),
        p.state::TEXT,
        p."userId",
        COALESCE(u.name, 'Sistema')::TEXT AS user_name,
        p."createdAt",
        p."convertedQuotationId",
        COALESCE(q."internalNumber", '')::TEXT AS converted_internal_number,
        p."convertedAt",
        COALESCE(cu.name, '')::TEXT AS converted_user_name,
        ''::TEXT AS invoice_number,
        (EXTRACT(EPOCH FROM (COALESCE(p."convertedAt", CURRENT_TIMESTAMP) - p."createdAt")) / 60)::INT AS elapsed_minutes
    FROM public."PreQuotation" p
    LEFT JOIN public."Client" c ON p."clientId" = c.id
    LEFT JOIN public."Provider" pr ON p."providerId" = pr.id
    LEFT JOIN public."TicketPrinter" tp ON p."ticketPrinterId" = tp.id
    LEFT JOIN public."Seller" s ON p."sellerId" = s.id
    LEFT JOIN public."Branch" b ON p."branchId" = b.id
    LEFT JOIN public."User" u ON p."userId" = u.id
    LEFT JOIN public."User" cu ON p."convertedUserId" = cu.id
    LEFT JOIN public."Quotation" q ON p."convertedQuotationId" = q.id
    WHERE (p_branch_id IS NULL OR p_branch_id = 0 OR p."branchId" = p_branch_id)
      AND (p_state IS NULL OR p_state = '' OR p.state = p_state)
      AND (
        p_search IS NULL OR p_search = '' OR
        p.consecutivo::TEXT ILIKE '%' || TRIM(p_search) || '%' OR
        c.name ILIKE '%' || TRIM(p_search) || '%' OR
        p."clientNameText" ILIKE '%' || TRIM(p_search) || '%' OR
        p."headerDescription" ILIKE '%' || TRIM(p_search) || '%' OR
        p."quotationNotice" ILIKE '%' || TRIM(p_search) || '%'
      )
    ORDER BY p.id DESC;
END;
$$;
