-- ==========================================================
-- ARCHIVO ACTUALIZADOR COMPLETO: TABLAS + FUNCIONES + SPS
-- Generado Automáticamente
-- ==========================================================

-- >>> 1. CREACIÓN DE TABLAS E ÍNDICES (TABLEINI) <<<

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spUsuarioActualizar(
    p_user_id INT,
    p_name TEXT,
    p_email TEXT,
    p_password_hash TEXT, -- NULL significa que no se actualiza la contraseña
    p_role_id INT,
    p_branch_id INT,
    p_implant_id INT,
    p_ticket_printer_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM public."User" WHERE id = p_user_id) THEN
        p_mensaje_resultado := 'ERROR: Usuario con ID ' || p_user_id || ' no encontrado.';
        RETURN;
    END IF;

    -- Validar si el email ya existe en otro usuario
    IF EXISTS (SELECT 1 FROM public."User" WHERE email = p_email AND id != p_user_id) THEN
        p_mensaje_resultado := 'ERROR: El email ' || p_email || ' ya está registrado por otro usuario.';
        RETURN;
    END IF;

    -- Actualizar el usuario
    UPDATE public."User"
    SET 
        "name" = COALESCE(p_name, "name"),
        "email" = COALESCE(p_email, "email"),
        "passwordHash" = COALESCE(p_password_hash, "passwordHash"),
        "roleId" = COALESCE(p_role_id, "roleId"),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "ticketPrinterId" = p_ticket_printer_id
    WHERE id = p_user_id;

    p_mensaje_resultado := 'SUCCESS: Usuario actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

    -- Duplicar combos asociados
    INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
    SELECT v_new_id, "comboId"
    FROM public."QuotationCombo"
    WHERE "quotationId" = p_quotation_id;

    -- Duplicar servicios manuales si la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        INSERT INTO public."QuotationManualService" ("quotationId", "providerName", "serviceName", "cost", "salePrice", "utility")
        SELECT v_new_id, "providerName", "serviceName", "cost", "salePrice", "utility"
        FROM public."QuotationManualService"
        WHERE "quotationId" = p_quotation_id;
    END IF;

    -- Duplicar productos y sus detalles
    FOR v_orig_qp IN 
        SELECT * FROM public."QuotationProduct" WHERE "quotationId" = p_quotation_id
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission",
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_new_id, v_orig_qp."productId", v_orig_qp."quantity", v_orig_qp."price", v_orig_qp."cost", v_orig_qp."providerId", v_orig_qp."prestadoraId",
            v_orig_qp."checkInDate", v_orig_qp."checkOutDate", v_orig_qp."nights", v_orig_qp."paxAdults", v_orig_qp."paxChildren",
            v_orig_qp."serviceType", v_orig_qp."destination", v_orig_qp."reservationCode", v_orig_qp."sellerCommission",
            v_orig_qp."ticketPrinterCommission", v_orig_qp."comboId", v_orig_qp."mainTaxId", v_orig_qp."inNationality",
            v_orig_qp."service", v_orig_qp."servicios", v_orig_qp."descripcion", v_orig_qp."passenger"
        ) RETURNING id INTO v_new_qp_id;

        -- Duplicar Pasajeros del producto
        INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
        SELECT v_new_qp_id, "name", "document"
        FROM public."QuotationProductPassenger"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Impuestos del producto
        INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain")
        SELECT v_new_qp_id, "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
        FROM public."QuotationProductTax"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Variables del producto
        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
        SELECT v_new_qp_id, "masterVariableId", "value"
        FROM public."QuotationProductVariable"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Pagos del producto
        INSERT INTO public."QuotationProductPayment" ("quotationProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
        SELECT v_new_qp_id, "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
        FROM public."QuotationProductPayment"
        WHERE "quotationProductId" = v_orig_qp.id;

    END LOOP;

    p_new_quotation_id := v_new_id;
    p_mensaje_resultado := 'SUCCESS: Cotización duplicada correctamente con ID ' || v_new_id;

    -- Registrar en auditoría
    CALL public."spLogRegistrar"(
        v_user_id, 
        'QUOTATION', 
        'DUPLICATE', 
        'Se duplicó la cotización #' || p_quotation_id || ' generando la cotización #' || v_new_id || ' (' || v_internal_number || ')', 
        jsonb_build_object('sourceQuotationId', p_quotation_id, 'newQuotationId', v_new_id), 
        v_new_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;;

-- Inyectado automáticamente: spSiteModuleMasterToggle.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSiteModuleMasterToggle'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spSiteModuleMasterToggle"(
    p_type text,
    p_id integer,
    p_active boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF UPPER(p_type) = 'MENU' THEN
        UPDATE public."Menu"
        SET activo = p_active
        WHERE id = p_id;
    ELSIF UPPER(p_type) = 'MASTER' THEN
        UPDATE public."Master"
        SET inactivo = NOT p_active
        WHERE id = p_id;
    ELSE
        RAISE EXCEPTION 'Tipo no válido: %. Se requiere MENU o MASTER.', p_type;
    END IF;
END;
$$;;

-- Inyectado automáticamente: fnAirportListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnAirportListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnAirportListar"()
RETURNS TABLE(id integer, code text, name text, "citiesId" integer, "cityName" text)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT a.id, a.code::text, a.name::text, a."citiesId", c.name::text FROM public."Airports" a LEFT JOIN public."Cities" c ON a."citiesId" = c.id ORDER BY a.name ASC;
END; $function$;;

-- Inyectado automáticamente: fnCellCustomizationListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCellCustomizationListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnCellCustomizationListar(
    p_branch_id integer,
    p_implant_id integer
)
RETURNS TABLE (
    id integer,
    code varchar(50),
    "name" varchar(100),
    "value" varchar(10),
    "branchId" integer,
    "implantId" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cc.id,
        cc.code::varchar(50),
        cc."name"::varchar(100),
        cc."value"::varchar(10),
        cc."branchId",
        cc."implantId"
    FROM public."CellCustomization" cc
    WHERE 
        (p_branch_id IS NOT NULL AND cc."branchId" = p_branch_id AND cc."implantId" IS NULL)
        OR
        (p_implant_id IS NOT NULL AND cc."implantId" = p_implant_id);
END;
$$;;

-- Inyectado automáticamente: fnCityListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCityListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCityListar"()
RETURNS TABLE(id integer, code text, name text, "countriesId" integer, statecode text, iata text, "countryName" text)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT c.id, c.code::text, c.name::text, c."countriesId", c.statecode::text, c.iata::text, co.name::text FROM public."Cities" c LEFT JOIN public."Countries" co ON c."countriesId" = co.id ORDER BY c.name ASC;
END; $function$;;

-- Inyectado automáticamente: fnClienteListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnClienteListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public.fnClienteListar();

CREATE OR REPLACE FUNCTION public.fnClienteListar()
RETURNS TABLE (
    id integer,
    name text,
    document text,
    "contactInfo" text,
    address text,
    "mandatoryVariables" jsonb,
    "sellerId" integer,
    "sellerCode" text,
    "sellerName" text,
    "isActive" boolean,
    "creditDays" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        COALESCE(c.name, '')::text,
        COALESCE(c.document, '')::text,
        c."contactInfo"::text,
        c.address::text,
        c."mandatoryVariables",
        c."sellerId",
        s.code::text AS "sellerCode",
        s.name::text AS "sellerName",
        COALESCE(c."isActive", true) AS "isActive",
        COALESCE(c."creditDays", 0)::integer AS "creditDays"
    FROM public."Client" c
    LEFT JOIN public."Seller" s ON s.id = c."sellerId"
    ORDER BY c.id DESC;
END;
$$;;

-- Inyectado automáticamente: fnComboListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnComboListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnComboListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', c.id,
            'code', c.code,
            'name', c.name,
            'cupos', c."cupos",
            'currencyId', c."currencyId",
            'createdAt', c."createdAt",
            'products', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', cp.id,
                        'productId', cp."productId",
                        'product', jsonb_build_object('id', p.id, 'code', p.code, 'description', p.description),
                        'quantity', cp.quantity,
                        'price', cp.price,
                        'cost', COALESCE(cp."cost", 0),
                        'providerId', cp."providerId",
                        'prestadoraId', cp."prestadoraId",
                        'checkInDate', cp."checkInDate",
                        'checkOutDate', cp."checkOutDate",
                        'paxAdults', cp."paxAdults",
                        'paxChildren', cp."paxChildren",
                        'mainTaxId', cp."mainTaxId",
                        'inNationality', COALESCE(cp."inNationality", 1),
                        'appliedTaxes', (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'id', cpt.id,
                                    'chargeAndTaxId', cpt."chargeAndTaxId",
                                    'amount', cpt.amount,
                                    'isMain', cpt."isMain",
                                    'chargeAndTax', (
                                        SELECT jsonb_build_object('id', ct.id, 'name', ct.name, 'value', ct.value, 'valueType', ct."valueType")
                                        FROM public."ChargeAndTax" ct WHERE ct.id = cpt."chargeAndTaxId"
                                    )
                                )
                            )
                            FROM public."ComboProductTax" cpt
                            WHERE cpt."comboProductId" = cp.id
                        )
                    )
                )
                FROM public."ComboProduct" cp
                JOIN public."Product" p ON cp."productId" = p.id
                WHERE cp."comboId" = c.id
            ), '[]'::jsonb)
        )
    FROM public."Combo" c
    ORDER BY c."createdAt" DESC;
END;
$$;;

-- Inyectado automáticamente: fnCotizacion.sql
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
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object(
                'id', c.id,
                'name', c.name,
                'document', c.document
            ) ELSE jsonb_build_object('id', null, 'name', 'Cliente desconocido', 'document', '') END,
            'combos', COALESCE((
                SELECT jsonb_agg(jsonb_build_object('id', qc."comboId", 'comboId', qc."comboId", 'name', cb.name))
                FROM public."QuotationCombo" qc
                JOIN public."Combo" cb ON qc."comboId" = cb.id
                WHERE qc."quotationId" = q.id
            ), '[]'::jsonb),
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
    WHERE q.id = p_quotation_id;

    RETURN v_result;
END;
$$;;

-- Inyectado automáticamente: fnCotizacionHistorial.sql
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

    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
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
            'userName', COALESCE(u.name, 'Sistema'),
            'state', COALESCE(q.state, 'NUEVO'),
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
$$;;

-- Inyectado automáticamente: fnCotizacionListar.sql
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
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
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
$$;;

-- Inyectado automáticamente: fnCountryListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCountryListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCountryListar"()
RETURNS TABLE(id integer, code text, name text, dane text, region text, prefix text, "curencyId" integer)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT c.id, c.code::text, c.name::text, c.dane::text, c.region::text, c.prefix::text, c."curencyId" FROM public."Countries" c ORDER BY c.id ASC;
END; $function$;;

-- Inyectado automáticamente: fnCreditCardListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCreditCardListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCreditCardListar"()
RETURNS TABLE(
    id integer,
    code text,
    name text,
    type text,
    inactive boolean
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.code,
        c.name,
        c.type,
        c.inactive
    FROM public."CreditCard" c
    ORDER BY c.id ASC;
END;
$function$;;

-- Inyectado automáticamente: fnCreditCardValidar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCreditCardValidar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCreditCardValidar"(
    p_referencia text
)
RETURNS TABLE(
    es_valido boolean,
    codigo_tarjeta text,
    numero_tarjeta text,
    tarjeta_id integer,
    nombre_tarjeta text,
    mensaje text
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_code text;
    v_number text;
    v_id integer;
    v_name text;
BEGIN
    IF p_referencia IS NULL OR TRIM(p_referencia) = '' THEN
        RETURN QUERY SELECT true, ''::text, ''::text, NULL::integer, ''::text, 'OK'::text;
        RETURN;
    END IF;

    p_referencia := TRIM(p_referencia);

    -- Si tiene al menos 2 caracteres iniciales que son letras (ej: VI0000000000007023)
    IF length(p_referencia) >= 2 AND substring(p_referencia from 1 for 2) ~ '^[A-Za-z]{2}$' THEN
        v_code := UPPER(substring(p_referencia from 1 for 2));
        v_number := substring(p_referencia from 3);

        SELECT c.id, c.name INTO v_id, v_name
        FROM public."CreditCard" c
        WHERE UPPER(TRIM(c.code)) = v_code AND c.inactive = false
        LIMIT 1;

        IF v_id IS NOT NULL THEN
            RETURN QUERY SELECT true, v_code, v_number, v_id, v_name, 'SUCCESS'::text;
        ELSE
            RETURN QUERY SELECT false, v_code, v_number, NULL::integer, ''::text, ('El código de tarjeta "' || v_code || '" no existe en el Maestro de Tarjetas de Crédito.')::text;
        END IF;
    ELSE
        -- Si son solo números o no empieza por código de 2 letras
        RETURN QUERY SELECT true, ''::text, p_referencia, NULL::integer, ''::text, 'Sin código de tipo de tarjeta'::text;
    END IF;
END;
$function$;;

-- Inyectado automáticamente: fnDocumentResolutionListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnDocumentResolutionListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnDocumentResolutionListar"()
RETURNS TABLE (
    id integer,
    "branchId" integer,
    "branchName" text,
    "implantId" integer,
    "implantName" text,
    "resolutionNumber" text,
    "initialNumber" integer,
    "finalNumber" integer,
    "currentNumber" integer,
    "resolutionDate" timestamp without time zone,
    "prefix" text,
    "expirationDate" timestamp without time zone,
    "isActive" boolean,
    "createdAt" timestamp without time zone
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dr.id,
        dr."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        dr."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        dr."resolutionNumber"::text,
        dr."initialNumber",
        dr."finalNumber",
        dr."currentNumber",
        dr."resolutionDate",
        COALESCE(dr.prefix, '')::text,
        dr."expirationDate",
        dr."isActive",
        dr."createdAt"
    FROM public."DocumentResolution" dr
    LEFT JOIN public."Branch" b ON b.id = dr."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = dr."implantId"
    ORDER BY dr.id DESC;
END;
$$;;

-- Inyectado automáticamente: fnEquivalenceInterface.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnEquivalenceInterface'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnEquivalenceInterface"(
	p_id_interface integer,
	p_id_master integer,
	p_value text
)
RETURNS text
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_equivalence TEXT;
    v_master_code TEXT;
BEGIN
    -- Si el valor es nulo o vacío, retornamos el mismo valor
    IF p_value IS NULL OR trim(p_value) = '' THEN
        RETURN p_value;
    END IF;

    -- Buscamos el equivalente en la tabla EquivalencesInterfaces
    SELECT cd_codigo 
    INTO v_equivalence
    FROM public."EquivalencesInterfaces"
    WHERE id_interfaces = p_id_interface
      AND id_master = p_id_master
      AND cd_codigoInte = p_value
    LIMIT 1;

    -- Si no se encuentra equivalencia:
    IF v_equivalence IS NULL OR trim(v_equivalence) = '' THEN
        -- Si corresponde al maestro de Impuestos (ChargeAndTax), mapear por defecto a 'OTR' (Otros Impuestos)
        SELECT code INTO v_master_code FROM public."Master" WHERE id = p_id_master LIMIT 1;
        IF v_master_code = 'ChargeAndTax' THEN
            RETURN 'OTR';
        ELSE
            RETURN p_value;
        END IF;
    ELSE
        RETURN v_equivalence;
    END IF;
END;
$BODY$;

ALTER FUNCTION public."fnEquivalenceInterface"(integer, integer, text) OWNER TO postgres;;

-- Inyectado automáticamente: fnImplantListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnImplantListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnImplantListar()
RETURNS SETOF public."Implant"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Implant" ORDER BY name ASC;
END;
$$;;

-- Inyectado automáticamente: fnInterfaceExtractParamValue.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnInterfaceExtractParamValue'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnInterfaceExtractParamValue"(
    p_interface_id INTEGER,
    p_field_code TEXT,
    p_booking_file TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_prefix TEXT;
    v_delimiter TEXT;
    v_start_pos INTEGER;
    v_length INTEGER;
    v_line TEXT;
    v_extracted TEXT := NULL;
    v_pos INTEGER;
    v_lines TEXT[];
    i INTEGER;
BEGIN
    IF p_booking_file IS NULL OR TRIM(p_booking_file) = '' THEN
        RETURN NULL;
    END IF;

    -- 1. Buscar regla parametrizada para la interfaz y código de campo
    SELECT "prefix", "delimiter", "startPosition", "length"
    INTO v_prefix, v_delimiter, v_start_pos, v_length
    FROM public."InterfaceExtractParam"
    WHERE "interfaceId" = p_interface_id
      AND UPPER("fieldCode") = UPPER(TRIM(p_field_code))
      AND "isActive" = TRUE
    ORDER BY id DESC
    LIMIT 1;

    -- Fallbacks por defecto si no hay regla configurada
    IF v_prefix IS NULL OR v_prefix = '' THEN
        IF UPPER(TRIM(p_field_code)) = 'CLIENT' THEN
            v_prefix := 'RM*NC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_prefix := 'RM*VEN-';
        ELSIF UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_prefix := 'RM*TK-';
        ELSIF UPPER(TRIM(p_field_code)) = 'BRANCH' THEN
            v_prefix := 'RM*SUC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'IMPLANT' THEN
            v_prefix := 'RM*IMP-';
        ELSE
            RETURN NULL;
        END IF;
    END IF;

    IF v_delimiter IS NULL THEN
        v_delimiter := '-';
    END IF;

    -- 2. Dividir archivo en líneas
    v_lines := string_to_array(p_booking_file, E'\n');

    -- 3. Recorrer líneas buscando el prefijo constante
    FOR i IN 1..array_length(v_lines, 1) LOOP
        v_line := TRIM(v_lines[i]);
        v_line := REPLACE(v_line, E'\r', '');

        v_pos := POSITION(v_prefix IN v_line);
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_pos := POSITION('RM*VE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*VE-'; END IF;
        END IF;
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_pos := POSITION('RM*ASE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*ASE-'; END IF;
        END IF;
        IF v_pos > 0 THEN
            v_extracted := SUBSTRING(v_line FROM v_pos + CHAR_LENGTH(v_prefix));
            v_extracted := TRIM(v_extracted);

            IF v_delimiter IS NOT NULL AND v_delimiter <> '' THEN
                v_pos := POSITION(v_delimiter IN v_extracted);
                IF v_pos > 1 THEN
                    v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_pos - 1);
                END IF;
            END IF;

            IF v_length IS NOT NULL AND v_length > 0 AND CHAR_LENGTH(v_extracted) > v_length THEN
                v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_length);
            END IF;

            v_extracted := TRIM(v_extracted);
            IF v_extracted <> '' THEN
                RETURN v_extracted;
            END IF;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$;;

-- Inyectado automáticamente: fnInterfacesList.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnInterfacesList'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public."fnInterfacesList"();

CREATE OR REPLACE FUNCTION public."fnInterfacesList"()
RETURNS TABLE(
    id integer,
    code text,
    name text,
    inactivo boolean,
    bl_genera_archivoplano boolean,
    ds_storedprocedure_archivoplano text,
    bl_job boolean,
    ds_namejob text,
    bl_facturador boolean,
    id_gds integer
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.code,
        i.name,
        i.inactivo,
        i.bl_genera_archivoplano,
        i.ds_storedprocedure_archivoplano,
        i.bl_job,
        i.ds_namejob,
        i.bl_facturador,
        i.id_gds
    FROM public."Interfaces" i
    ORDER BY i.name ASC;
END;
$BODY$;

ALTER FUNCTION public."fnInterfacesList"() OWNER TO postgres;;

-- Inyectado automáticamente: fnInvoicesListar.sql
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
$$;;

-- Inyectado automáticamente: fnMasterList.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnMasterList'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnMasterList"()
RETURNS TABLE(
    id integer,
    code text,
    name text,
    inactivo boolean
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.code,
        m.name,
        m.inactivo
    FROM public."Master" m
    ORDER BY m.name ASC;
END;
$BODY$;

ALTER FUNCTION public."fnMasterList"() OWNER TO postgres;;

-- Inyectado automáticamente: fnMenuAll.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnMenuAll'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnMenuAll()
RETURNS SETOF public."Menu"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Menu"
    ORDER BY id ASC;
END;
$$;;

-- Inyectado automáticamente: fnMonedaListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnMonedaListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public.fnMonedaListar(INT);

CREATE OR REPLACE FUNCTION public.fnMonedaListar(
    p_id INT DEFAULT NULL
)
RETURNS TABLE (
    id             INT,
    code           TEXT,
    name           TEXT,
    "exchangeRate" FLOAT,
    decimals       INT,
    "isActive"     BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.code,
        c.name,
        c."exchangeRate",
        c.decimals,
        COALESCE(c."isActive", true) AS "isActive"
    FROM public."Currency" c
    WHERE
        p_id IS NULL
        OR c.id = p_id
    ORDER BY c.code;
END;
$$;;

-- Inyectado automáticamente: fnObtenerSiguienteConsecutivo.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnObtenerSiguienteConsecutivo'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnObtenerSiguienteConsecutivo"(
    p_transaction_type text,
    p_branch_id integer DEFAULT NULL,
    p_implant_id integer DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec RECORD;
    v_next_val integer;
    v_prefix text := '';
    v_padding integer := 0;
    v_num_str text;
    v_formatted text;
    v_res_json jsonb;
    v_norm_type text;
BEGIN
    v_norm_type := UPPER(TRIM(COALESCE(p_transaction_type, 'INVOICE')));

    -- 1. Intentar buscar un consecutivo específico para la combinación sucursal e implante
    SELECT * INTO v_rec
    FROM public."TransactionConsecutive"
    WHERE "isActive" = true
      AND (
          UPPER("transactionType") = v_norm_type
          OR (v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA') AND UPPER("transactionType") IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA'))
          OR (v_norm_type IN ('QUOTATION', 'COTIZACION') AND UPPER("transactionType") IN ('QUOTATION', 'COTIZACION'))
          OR (v_norm_type IN ('PREQUOTATION', 'PRECOTIZACION') AND UPPER("transactionType") IN ('PREQUOTATION', 'PRECOTIZACION'))
          OR (v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') AND UPPER("transactionType") IN ('CREDIT_NOTE', 'NOTA_CREDITO'))
      )
      AND (
          (p_branch_id IS NOT NULL AND "branchId" = p_branch_id)
          OR ("branchId" IS NULL)
      )
      AND (
          (p_implant_id IS NOT NULL AND "implantId" = p_implant_id)
          OR ("implantId" IS NULL)
      )
    ORDER BY 
        CASE WHEN p_implant_id IS NOT NULL AND "implantId" = p_implant_id THEN 1 WHEN "implantId" IS NOT NULL THEN 3 ELSE 2 END,
        CASE WHEN p_branch_id IS NOT NULL AND "branchId" = p_branch_id THEN 1 WHEN "branchId" IS NOT NULL THEN 3 ELSE 2 END,
        id ASC
    LIMIT 1
    FOR UPDATE;

    -- Si existe un registro configurado
    IF v_rec.id IS NOT NULL THEN
        v_next_val := COALESCE(v_rec."currentNumber", v_rec."initialNumber", 1);
        v_prefix := COALESCE(TRIM(v_rec.prefix), '');
        v_padding := COALESCE(v_rec.padding, 0);

        -- Incrementar atómicamente para la siguiente transacción
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = "currentNumber" + 1,
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = v_rec.id;
    ELSE
        -- Fallback si no existe parámetro de consecutivo configurado todavía
        v_prefix := CASE 
            WHEN v_norm_type IN ('QUOTATION', 'COTIZACION') THEN 'COT'
            WHEN v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION') THEN 'FAC'
            WHEN v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') THEN 'NC'
            ELSE 'DOC'
        END;

        IF v_norm_type IN ('QUOTATION', 'COTIZACION') THEN
            SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_val FROM public."Quotation";
        ELSE
            SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_val FROM public."Invoices";
        END IF;
    END IF;

    v_num_str := v_next_val::text;
    IF v_padding > 0 AND length(v_num_str) < v_padding THEN
        v_num_str := lpad(v_num_str, v_padding, '0');
    END IF;

    IF v_prefix <> '' THEN
        IF v_prefix LIKE '%-' OR v_prefix LIKE '%/' THEN
            v_formatted := v_prefix || v_num_str;
        ELSE
            v_formatted := v_prefix || '-' || v_num_str;
        END IF;
    ELSE
        v_formatted := v_num_str;
    END IF;

    v_res_json := jsonb_build_object(
        'consecutivoNumber', v_next_val,
        'prefix', v_prefix,
        'formattedConsecutive', v_formatted,
        'consecutivoId', v_rec.id
    );

    RETURN v_res_json;
END;
$$;;

-- Inyectado automáticamente: fnParameterListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnParameterListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnParameterListar()
RETURNS SETOF public."SystemParameter"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."SystemParameter" ORDER BY name ASC;
END;
$$;;

-- Inyectado automáticamente: fnPaymentListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnPaymentListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnPaymentListar"()
RETURNS TABLE(id integer, code text, name text, iscash boolean, iscredit boolean, inactive boolean)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT p.id, p.code, p.name, p.iscash, p.iscredit, p.inactive FROM public."Payment" p ORDER BY p.id ASC;
END; $function$;;

-- Inyectado automáticamente: fnPreCotizacionListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

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
$$;;

-- Inyectado automáticamente: fnProductoListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnProductoListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnProductoListar()
RETURNS SETOF public."Product"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Product" ORDER BY id DESC;
END;
$$;;

-- Inyectado automáticamente: fnProveedorListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnProveedorListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnProveedorListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'name', p.name,
            'contactInfo', p."contactInfo",
            'commissionConfig', p."commissionConfig",
            'providerTypeId', p."providerTypeId",
            'providerTypeName', pt.name,
            'isAirline', COALESCE(pt."isAirline", false),
            'airlineCode', p."airlineCode",
            'sigla', p."sigla",
            'isActive', COALESCE(p."isActive", true),
            'prestadoras', COALESCE((
                SELECT jsonb_agg(h)
                FROM public."Prestadora" h
                WHERE h."providerId" = p.id
            ), '[]'::jsonb)
        )
    FROM public."Provider" p
    LEFT JOIN public."ProviderType" pt ON pt.id = p."providerTypeId"
    ORDER BY p.name ASC;
END;
$$;;

-- Inyectado automáticamente: fnProviderTypeListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnProviderTypeListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnProviderTypeListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', pt.id,
            'code', pt.code,
            'name', pt.name,
            'isAirline', pt."isAirline",
            'active', pt.active,
            'isActive', COALESCE(pt."isActive", pt.active, true)
        )
    FROM public."ProviderType" pt
    ORDER BY pt.name ASC;
END;
$$;;

-- Inyectado automáticamente: fnQuitarEspeciales.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnQuitarEspeciales'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnQuitarEspeciales"(texto TEXT)
RETURNS TEXT AS $$
BEGIN
    IF texto IS NULL THEN
        RETURN NULL;
    END IF;

    -- Reemplaza cualquier carácter que NO sea letra, número o espacio por un espacio ' '
    -- Incluye soporte para letras con tildes y ñ (a-zA-Z0-9áéíóúÁÉÍÓÚñÑ)
    RETURN REGEXP_REPLACE(texto, '[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]', ' ', 'g');
END;
$$ LANGUAGE plpgsql IMMUTABLE;;

-- Inyectado automáticamente: fnQuotationStateListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnQuotationStateListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;


CREATE OR REPLACE FUNCTION public."fnQuotationStateListar"()
RETURNS TABLE(id integer, code text, name text, color text, "createdAt" timestamp)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT t.id, t.code::text, t.name::text, t.color::text, t."createdAt"::timestamp FROM public."QuotationState" t ORDER BY t.name ASC;
END; $function$;;

-- Inyectado automáticamente: fnReportDinamic.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnReportDinamic'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public."fnReportDinamic"(INTEGER);
DROP FUNCTION IF EXISTS public."fnReportDinamic"(INTEGER, JSON);

CREATE OR REPLACE FUNCTION public."fnReportDinamic"(
    p_report_id INTEGER,
    p_filter_values JSON DEFAULT '{}'::json
)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_table VARCHAR;
    v_custom_sql TEXT;
    v_sql TEXT;
    v_select_clause TEXT;
    v_from_clause TEXT;
    v_where_clause TEXT := '1=1';
    v_order_col VARCHAR;
    v_order_dir VARCHAR;
    v_result json;
    v_filter RECORD;
    v_val TEXT;
    v_val_to TEXT;
BEGIN
    -- 1. Obtener la configuración del reporte
    SELECT base_table, custom_sql INTO v_base_table, v_custom_sql
    FROM public."Report"
    WHERE id = p_report_id;

    IF v_base_table IS NULL AND v_custom_sql IS NULL THEN
        RAISE EXCEPTION 'Reporte no encontrado';
    END IF;

    -- 2. Construir el Origen de Datos (Custom SQL o Tabla Base)
    IF v_custom_sql IS NOT NULL AND v_custom_sql <> '' THEN
        -- Si hay SQL personalizado, lo usamos como fuente
        v_from_clause := '(' || v_custom_sql || ') t1 ';
        v_select_clause := '*';
    ELSE
        -- 2.1 Construir el SELECT (Columnas Visibles)
        SELECT string_agg(
            CASE 
                WHEN is_calculated THEN formula_expression || ' AS "' || COALESCE(alias, 'Calculado') || '"'
                ELSE COALESCE(table_alias || '.', '') || '"' || column_name || '"' || ' AS "' || COALESCE(alias, column_name) || '"'
            END,
            ', ' ORDER BY sort_order ASC
        ) INTO v_select_clause
        FROM public."ReportColumns"
        WHERE report_id = p_report_id AND is_visible = true;

        IF v_select_clause IS NULL THEN
            v_select_clause := '*'; 
        END IF;

        -- 2.2 Construir el FROM y los JOINS
        v_from_clause := 'public."' || v_base_table || '" t1 ';

        SELECT v_from_clause || string_agg(
            join_type || ' public."' || table_name || '" ' || alias || ' ON ' || join_condition,
            ' ' ORDER BY sort_order ASC
        ) INTO v_from_clause
        FROM public."ReportJoins"
        WHERE report_id = p_report_id;

        IF v_from_clause IS NULL THEN
            v_from_clause := 'public."' || v_base_table || '" t1 ';
        END IF;
    END IF;

    -- 4. Construir el WHERE (Filtros Dinámicos con Rangos)
    FOR v_filter IN SELECT * FROM public."ReportFilters" WHERE report_id = p_report_id LOOP
        v_val := p_filter_values->>(COALESCE(v_filter.table_alias, 't1') || '.' || v_filter.column_name);
        v_val_to := p_filter_values->>(COALESCE(v_filter.table_alias, 't1') || '.' || v_filter.column_name || '_to');
        
        DECLARE
            v_field_expr TEXT;
        BEGIN
            -- Determinar la expresión del campo
            IF v_custom_sql IS NOT NULL AND v_custom_sql <> '' THEN
                -- En Custom SQL, si el usuario puso algo como q."date", 
                -- debemos quitar el "q." porque afuera solo existe el alias "t1"
                IF v_filter.column_name ~ '\.' THEN
                    v_field_expr := 't1."' || split_part(v_filter.column_name, '.', 2) || '"';
                    -- Limpiar comillas si el split_part las dejó
                    v_field_expr := replace(v_field_expr, '"', ''); 
                    -- Re-envolver con comillas de forma segura
                    v_field_expr := 't1."' || v_field_expr || '"';
                ELSE
                    v_field_expr := 't1."' || v_filter.column_name || '"';
                END IF;
            ELSIF v_filter.column_name ~ '["\.]' THEN
                v_field_expr := v_filter.column_name;
            ELSE
                v_field_expr := COALESCE(v_filter.table_alias, 't1') || '."' || v_filter.column_name || '"';
            END IF;

            IF (v_val IS NOT NULL AND v_val <> '') OR (v_val_to IS NOT NULL AND v_val_to <> '') THEN
                IF v_filter.filter_type = 'date' THEN
                    IF v_val IS NOT NULL AND v_val <> '' AND v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' BETWEEN ''' || v_val || '''::date AND ''' || v_val_to || '''::date';
                    ELSIF v_val IS NOT NULL AND v_val <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' >= ''' || v_val || '''::date';
                    ELSIF v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' <= ''' || v_val_to || '''::date';
                    END IF;
                ELSIF v_filter.filter_type = 'number' THEN
                    IF v_val IS NOT NULL AND v_val <> '' AND v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' BETWEEN ' || v_val || ' AND ' || v_val_to;
                    ELSIF v_val IS NOT NULL AND v_val <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' >= ' || v_val;
                    ELSIF v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' <= ' || v_val_to;
                    END IF;
                ELSE -- text / like
                    v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' ILIKE ''%' || v_val || '%''';
                END IF;
            END IF;
        END;
    END LOOP;

    -- 5. Ensamblar SQL Final con Ordenamiento Múltiple
    v_sql := 'SELECT json_agg(row_to_json(t)) FROM (SELECT ' || v_select_clause || ' FROM ' || v_from_clause || ' WHERE ' || v_where_clause;
    
    -- Agregar ORDER BY si está definido (Múltiple)
    DECLARE
        v_order_by TEXT;
    BEGIN
        SELECT string_agg(
            CASE 
                WHEN column_expr ~ '^[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+$' THEN -- Formato t1.columna
                    split_part(column_expr, '.', 1) || '."' || split_part(column_expr, '.', 2) || '"'
                ELSE column_expr 
            END || ' ' || direction, 
            ', ' ORDER BY sort_order ASC
        ) INTO v_order_by
        FROM public."ReportSorts" WHERE report_id = p_report_id;
        
        IF v_order_by IS NOT NULL THEN
            v_sql := v_sql || ' ORDER BY ' || v_order_by;
        END IF;
    END;

    v_sql := v_sql || ') t';

    -- 6. Ejecutar dinámicamente
    EXECUTE v_sql INTO v_result;

    IF v_result IS NULL THEN
        v_result := '[]'::json;
    END IF;

    RETURN v_result;
END;
$$;;

-- Inyectado automáticamente: fnReservaBuscarParaFacturar.sql
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
$$;;

-- Inyectado automáticamente: fnRoleListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnRoleListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Función: fnRoleListar
-- Descripción: Consulta el listado de roles con su matriz de permisos y conteo de usuarios asignados.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE FUNCTION public."fnRoleListar"()
RETURNS TABLE (
    id INT,
    name VARCHAR,
    description TEXT,
    permissions JSONB,
    user_count BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name::VARCHAR,
        COALESCE(r.description, '')::TEXT,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB,
        COUNT(u.id)::BIGINT AS user_count
    FROM public."Role" r
    LEFT JOIN public."User" u ON u."roleId" = r.id
    GROUP BY r.id, r.name, r.description, r.permissions
    ORDER BY r.id ASC;
END;
$$;;

-- Inyectado automáticamente: fnRptCotizacion.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnRptCotizacion'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

DROP FUNCTION IF EXISTS public."fnRptCotizacion"(integer, integer);

CREATE OR REPLACE FUNCTION public."fnRptCotizacion"(
	p_id_ini integer,
	p_id_fin integer)
    RETURNS TABLE(
        -- Cabecera Cotización
        "idCotizacion" integer,
        "internalNumber" text,
        "asesor" text,
        "fecha" timestamp without time zone,
        "currency" text,
        "tCambio" double precision,
        "state" text,
        "descripcionPlan" text,
        "observaciones" text,
        "baseCommissionable" double precision,
        "commissionPercentage" double precision,
        "totalAmount" double precision,
        "costoTotal" double precision,
        "valorBase" double precision,
        "utilidad" double precision,
        "comisionFreelanceValue" double precision,
        "comisionPropiaValue" double precision,
        "comisionTotalPercentage" double precision,
        "comisionFreelancePercentage" double precision,
        "comisionPropiaPercentage" double precision,
        "comisionUtilidadPercentage" double precision,

        -- Cliente
        "clienteNombre" text,
        "clienteIdentificacion" text,
        "clienteDireccion" text,
        "clienteTelefono" text,

        -- Resúmenes de cabecera
        "pasajeros" text,
        "totalAdultos" integer,
        "totalNinos" integer,
        "baseComisionable" double precision,
        "comisionAsesor" double precision,
        "fechasViaje" text,
        "hotelesServicios" text,
        "vendedor" text,
        "logo" bytea,
        "destinoCabecera" text,
        "fechaInicioCabecera" timestamp without time zone,
        "fechaFinCabecera" timestamp without time zone,
        "pasajeroCabecera" text,
        "paxAdultosCabecera" integer,
        "paxNinosCabecera" integer,
        "reservacionCabecera" text,
        "descripcionManualCabecera" text,

        -- Datos del Producto/Item
        "idProducto" integer,
        "productDescripcion" text,
        "productTipo" text,
        "productCodigo" text,
        "productConcepto" text,
        "productItinerario" text,
        "productClase" text,
        "productVuelo" text,
        "precio" double precision,
        "cantidad" integer,
        "costo" double precision,
        "checkIn" text,
        "checkOut" text,
        "noches" integer,
        "paxAdultos" integer,
        "paxNinos" integer,
        "destino" text,
        "codigoReserva" text,
        "tipoServicio" text,
        "servicio" text,
        "descripcion" text,

        -- Proveedor del producto
        "proveedorNombre" text,
        "proveedorNIT" text,
        "proveedorContacto" text,

        -- Prestadora del producto
        "prestadoraNombre" text,
        "prestadoraCategoria" text,
        "prestadoraUbicacion" text,

        -- Valores financieros calculados del producto
        "tarifaNeta" double precision,
        "impuestos" double precision,
        "adicionalesServ" double precision,
        "comision" double precision,
        "descuento" double precision,
        "sobrecomision" double precision,
        "fee" double precision,
        "total" double precision
    ) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        -- Cabecera Cotización
        q.id AS "idCotizacion",
        COALESCE(q."internalNumber", '')::text AS "internalNumber",
        COALESCE(u.name, '')::text AS "asesor",
        q.date AS "fecha",
        COALESCE(q.currency, '')::text AS "currency",
        q."exchangeRate"::double precision AS "tCambio",
        COALESCE(q.state, '')::text AS "state",
        ('Cotización ' || q."internalNumber")::text AS "descripcionPlan",
        COALESCE(q.state, '')::text AS "observaciones",
        COALESCE(q."baseCommissionable", 0)::double precision AS "baseCommissionable",
        COALESCE(q."commissionPercentage", 0)::double precision AS "commissionPercentage",
        COALESCE(q."totalAmount", 0)::double precision AS "totalAmount",
        COALESCE(q."costoTotal", 0)::double precision AS "costoTotal",
        COALESCE(q."valorBase", 0)::double precision AS "valorBase",
        COALESCE(q."utilidad", 0)::double precision AS "utilidad",
        COALESCE(
            q."comisionFreelanceValue", 
            CASE WHEN COALESCE(q."valorBase", 0) > 0 AND COALESCE(q."comisionFreelancePercentage", 0) > 0 
                 THEN ROUND(((COALESCE(q."comisionFreelancePercentage", 0) / 100.0) * q."valorBase")::numeric, 2) 
                 ELSE 0 END
        )::double precision AS "comisionFreelanceValue",
        COALESCE(
            q."comisionPropiaValue", 
            COALESCE(q."utilidad", 0) - COALESCE(
                q."comisionFreelanceValue", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 AND COALESCE(q."comisionFreelancePercentage", 0) > 0 
                     THEN ROUND(((COALESCE(q."comisionFreelancePercentage", 0) / 100.0) * q."valorBase")::numeric, 2) 
                     ELSE 0 END
            )
        )::double precision AS "comisionPropiaValue",
        COALESCE(
            q."comisionTotalPercentage", 
            COALESCE(
                q."comisionUtilidadPercentage", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 
                     THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                     ELSE 0 END
            )
        )::double precision AS "comisionTotalPercentage",
        COALESCE(q."comisionFreelancePercentage", 0)::double precision AS "comisionFreelancePercentage",
        ROUND(COALESCE(
            q."comisionPropiaPercentage", 
            COALESCE(
                q."comisionUtilidadPercentage", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 
                     THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                     ELSE 0 END
            ) - COALESCE(q."comisionFreelancePercentage", 0)
        )::numeric, 2)::double precision AS "comisionPropiaPercentage",
        COALESCE(
            q."comisionUtilidadPercentage", 
            CASE WHEN COALESCE(q."valorBase", 0) > 0 
                 THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                 ELSE 0 END
        )::double precision AS "comisionUtilidadPercentage",

        -- Cliente
        COALESCE(c.name, '')::text AS "clienteNombre",
        COALESCE(c.document, '')::text AS "clienteIdentificacion",
        COALESCE(c.address, '')::text AS "clienteDireccion",
        COALESCE(c."contactInfo", '')::text AS "clienteTelefono",

        -- Resúmenes de cabecera (pasajeros/adultos/niños = del producto actual)
        (
            SELECT string_agg(p.name, ', ')
            FROM "QuotationProductPassenger" p
            WHERE p."quotationProductId" = qp.id
        )::text AS "pasajeros",
        COALESCE(qp."paxAdults", 0)::integer AS "totalAdultos",
        COALESCE(qp."paxChildren", 0)::integer AS "totalNinos",
        COALESCE(q."baseCommissionable", 0)::double precision AS "baseComisionable",
        COALESCE(q."commissionPercentage", 0)::double precision AS "comisionAsesor",
        COALESCE(to_char(qp."checkInDate", 'DD/MM/YYYY') || ' al ' || to_char(qp."checkOutDate", 'DD/MM/YYYY'), '')::text AS "fechasViaje",
        COALESCE(prod.description, '')::text AS "hotelesServicios",
        COALESCE(sel.name, '')::text AS "vendedor",
        COALESCE(i.logo, b.logo) AS "logo",
        COALESCE(q.destination, '')::text AS "destinoCabecera",
        q."startDate" AS "fechaInicioCabecera",
        q."endDate" AS "fechaFinCabecera",
        COALESCE(q.passenger, '')::text AS "pasajeroCabecera",
        COALESCE(q."paxAdults", 0)::integer AS "paxAdultosCabecera",
        COALESCE(q."paxChildren", 0)::integer AS "paxNinosCabecera",
        COALESCE(q."reservationCode", '')::text AS "reservacionCabecera",
        COALESCE(q."manualDescription", '')::text AS "descripcionManualCabecera",

        -- Datos del Producto/Item
        qp.id AS "idProducto",
        COALESCE(prod.description, '')::text AS "productDescripcion",
        COALESCE(prod.type, '')::text AS "productTipo",
        COALESCE(prod.code, '')::text AS "productCodigo",
        COALESCE(prod."billingConcept", '')::text AS "productConcepto",
        COALESCE(prod."airlineItinerary", '')::text AS "productItinerario",
        COALESCE(prod."classItinerary", '')::text AS "productClase",
        COALESCE(prod."flightItinerary", '')::text AS "productVuelo",
        COALESCE(qp.price, 0)::double precision AS "precio",
        COALESCE(qp.quantity, 1)::integer AS "cantidad",
        COALESCE(qp.cost, 0)::double precision AS "costo",
        COALESCE(to_char(qp."checkInDate", 'DD/MM/YYYY'), '')::text AS "checkIn",
        COALESCE(to_char(qp."checkOutDate", 'DD/MM/YYYY'), '')::text AS "checkOut",
        COALESCE(qp.nights, 0)::integer AS "noches",
        COALESCE(qp."paxAdults", 0)::integer AS "paxAdultos",
        COALESCE(qp."paxChildren", 0)::integer AS "paxNinos",
        COALESCE(qp.destination, '')::text AS "destino",
        COALESCE(qp."reservationCode", '')::text AS "codigoReserva",
        COALESCE(qp."serviceType", '')::text AS "tipoServicio",
        COALESCE(qp.service, '')::text AS "servicio",
        COALESCE(qp.description, '')::text AS "descripcion",

        -- Proveedor
        COALESCE(prov.name, '')::text AS "proveedorNombre",
        COALESCE(prov.code, '')::text AS "proveedorNIT",
        COALESCE(prov."contactInfo", '')::text AS "proveedorContacto",

        -- Prestadora
        COALESCE(pre.name, '')::text AS "prestadoraNombre",
        COALESCE(pre.category, '')::text AS "prestadoraCategoria",
        COALESCE(pre.location, '')::text AS "prestadoraUbicacion",

        -- Valores financieros del producto
        (
            COALESCE(qp.price, 0) +
            COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN "ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0)
        )::double precision AS "tarifaNeta",

        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2.type = 'TAX'
            ), 0
        )::double precision AS "impuestos",

        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN "ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2.type = 'CHARGE'
                  AND NOT (
                      ct2."targetTaxId" IS NOT NULL AND (
                          target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                      )
                  )
            ), 0
        )::double precision AS "adicionalesServ",

        COALESCE(qp."sellerCommission", 0)::double precision AS "comision",
        0::double precision AS "descuento",
        0::double precision AS "sobrecomision",
        0::double precision AS "fee",
        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                WHERE qpt2."quotationProductId" = qp.id
            ), 0
        )::double precision AS "total"

    FROM "Quotation" q
    LEFT JOIN "Client" c ON q."clientId" = c.id
    LEFT JOIN "Seller" sel ON q."sellerId" = sel.id
    LEFT JOIN "User" u ON q."userId" = u.id
    LEFT JOIN "Branch" b ON q."branchId" = b.id
    LEFT JOIN "Implant" i ON q."implantId" = i.id
    LEFT JOIN "QuotationProduct" qp ON qp."quotationId" = q.id
    LEFT JOIN "Product" prod ON qp."productId" = prod.id
    LEFT JOIN "Provider" prov ON qp."providerId" = prov.id
    LEFT JOIN "Prestadora" pre ON qp."prestadoraId" = pre.id
    WHERE q.id BETWEEN p_id_ini AND p_id_fin
    ORDER BY q.id, qp.id;
END;
$BODY$;;

-- Inyectado automáticamente: fnSellerListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnSellerListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnSellerListar()
RETURNS SETOF public."Seller"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Seller" ORDER BY name ASC;
END;
$$;;

-- Inyectado automáticamente: fnTicketPrinterListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnTicketPrinterListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnTicketPrinterListar()
RETURNS SETOF public."TicketPrinter"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."TicketPrinter" ORDER BY name ASC;
END;
$$;;

-- Inyectado automáticamente: fnTicketTypeListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnTicketTypeListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;


CREATE OR REPLACE FUNCTION public."fnTicketTypeListar"()
RETURNS TABLE(id integer, code text, name text, description text, "isActive" boolean)
LANGUAGE plpgsql AS $function$
BEGIN
    RETURN QUERY SELECT t.id, t.code::text, t.name::text, t.description::text, t."isActive" FROM public."TicketType" t ORDER BY t.name ASC;
END; $function$;;

-- Inyectado automáticamente: fnTransactionConsecutiveListar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnTransactionConsecutiveListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnTransactionConsecutiveListar"()
RETURNS TABLE (
    id integer,
    "transactionType" text,
    "description" text,
    "prefix" text,
    "initialNumber" integer,
    "currentNumber" integer,
    "branchId" integer,
    "branchName" text,
    "implantId" integer,
    "implantName" text,
    "isActive" boolean,
    "createdAt" timestamp without time zone
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.id,
        tc."transactionType"::text,
        tc."description"::text,
        COALESCE(tc.prefix, '')::text,
        tc."initialNumber",
        tc."currentNumber",
        tc."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        tc."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        tc."isActive",
        tc."createdAt"
    FROM public."TransactionConsecutive" tc
    LEFT JOIN public."Branch" b ON b.id = tc."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = tc."implantId"
    ORDER BY tc.id DESC;
END;
$$;;

-- Inyectado automáticamente: fnUserPermissions.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnUserPermissions'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Función: fnUserPermissions
-- Descripción: Retorna el rol y la matriz de permisos JSON de un usuario desde la base de datos PostgreSQL.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE FUNCTION public."fnUserPermissions"(p_user_id INT)
RETURNS TABLE (
    user_id INT,
    role_id INT,
    role_name VARCHAR,
    permissions JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        r.id AS role_id,
        r.name::VARCHAR AS role_name,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB AS permissions
    FROM public."User" u
    JOIN public."Role" r ON u."roleId" = r.id
    WHERE u.id = p_user_id;
END;
$$;;

-- Inyectado automáticamente: fnUsuarioListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnUsuarioListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnUsuarioListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', u.id,
            'name', u.name,
            'email', u.email,
            'roleId', u."roleId",
            'role', (
                SELECT jsonb_build_object('id', r.id, 'name', r.name)
                FROM public."Role" r
                WHERE r.id = u."roleId"
            ),
            'branchId', u."branchId",
            'branch', CASE WHEN u."branchId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', b.id, 'name', b.name, 'code', b.code)
                FROM public."Branch" b
                WHERE b.id = u."branchId"
            ) ELSE NULL END,
            'implantId', u."implantId",
            'implant', CASE WHEN u."implantId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', i.id, 'name', i.name, 'code', i.code)
                FROM public."Implant" i
                WHERE i.id = u."implantId"
            ) ELSE NULL END,
            'ticketPrinterId', u."ticketPrinterId",
            'ticketPrinter', CASE WHEN u."ticketPrinterId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', t.id, 'name', t.name, 'code', t.code)
                FROM public."TicketPrinter" t
                WHERE t.id = u."ticketPrinterId"
            ) ELSE NULL END
        )
    FROM public."User" u
    ORDER BY u.name ASC;
END;
$$;;

-- Inyectado automáticamente: fnVariableListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnVariableListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnVariableListar()
RETURNS SETOF public."MasterVariable"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."MasterVariable" ORDER BY name ASC;
END;
$$;;

-- Inyectado automáticamente: fn_obtener_decimales_moneda.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fn_obtener_decimales_moneda'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fn_obtener_decimales_moneda(p_currency_code TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_decimals INT;
BEGIN
    SELECT COALESCE(decimals, 2) INTO v_decimals
    FROM public."Currency"
    WHERE LOWER(code) = LOWER(p_currency_code);
    
    RETURN COALESCE(v_decimals, 2);
END;
$$;;

-- Inyectado automáticamente: fn_obtener_historial_estados.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fn_obtener_historial_estados'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- Crear función para obtener el historial de estados de una cotización
CREATE OR REPLACE FUNCTION public.fn_obtener_historial_estados(p_quotation_id INT)
RETURNS TABLE (
    id INT,
    state VARCHAR(25),
    description TEXT,
    "createdAt" TIMESTAMP,
    "userId" INT,
    "userName" TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        qsh.id,
        qsh.state,
        qsh.description,
        qsh."createdAt",
        qsh."userId",
        COALESCE(u.name, 'Sistema'::TEXT) AS "userName"
    FROM public."QuotationStateHistory" qsh
    LEFT JOIN public."User" u ON qsh."userId" = u.id
    WHERE qsh."quotationId" = p_quotation_id
    ORDER BY qsh."createdAt" DESC;
END;
$$ LANGUAGE plpgsql;;

-- Inyectado automáticamente: spAirportActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spAirportActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spAirportActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_citiesId integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Airports" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Airports" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Airports" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "citiesId" = p_citiesId WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spAirportCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spAirportCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spAirportCrear"(IN p_code text, IN p_name text, IN p_citiesId integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Airports" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Airports" ("code", "name", "citiesId") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_citiesId) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $procedure$;;

-- Inyectado automáticamente: spAirportEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spAirportEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spAirportEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
BEGIN
    DELETE FROM public."Airports" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spBranchCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spBranchCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spBranchCrear(
    p_code TEXT,
    p_name TEXT,
    p_logo BYTEA,
    p_template BYTEA,
    p_template_config JSONB,
    p_html_template TEXT,
    p_resolution_id INT DEFAULT NULL,
    p_invoice_template BYTEA DEFAULT NULL,
    p_invoice_template_config JSONB DEFAULT NULL,
    p_invoice_html_template TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_branch_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Branch" (
        "code", "name", "logo", "template", "templateConfig", "htmlTemplate",
        "resolutionId", "invoiceTemplate", "invoiceTemplateConfig", "invoiceHtmlTemplate", "isActive"
    )
    VALUES (
        p_code, p_name, p_logo, p_template, p_template_config, p_html_template,
        p_resolution_id, p_invoice_template, p_invoice_template_config, p_invoice_html_template, COALESCE(p_is_active, true)
    )
    RETURNING id INTO p_branch_id;

    p_mensaje_resultado := 'SUCCESS: Sucursal creada con ID ' || p_branch_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spBranchEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spBranchEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spBranchEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Branch" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Sucursal con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."Branch" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Sucursal eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spCellCustomizationDelete.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCellCustomizationDelete'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCellCustomizationDelete(
    p_code text,
    p_branch_id integer,
    p_implant_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "branchId" = p_branch_id AND "implantId" IS NULL;
    ELSIF p_implant_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "implantId" = p_implant_id;
    END IF;
END;
$$;;

-- Inyectado automáticamente: spCellCustomizationUpsert.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCellCustomizationUpsert'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCellCustomizationUpsert(
    p_code text,
    p_name text,
    p_value text,
    p_branch_id integer,
    p_implant_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, p_branch_id, NULL)
        ON CONFLICT ("branchId", "code") WHERE "branchId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    ELSIF p_implant_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, NULL, p_implant_id)
        ON CONFLICT ("implantId", "code") WHERE "implantId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    END IF;
END;
$$;;

-- Inyectado automáticamente: spCityActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCityActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCityActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_countriesId integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Cities" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Cities" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Cities" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "countriesId" = p_countriesId, "statecode" = p_statecode, "iata" = p_iata WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spCityCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCityCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCityCrear"(IN p_code text, IN p_name text, IN p_countriesId integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Cities" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Cities" ("code", "name", "countriesId", "statecode", "iata") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_countriesId, p_statecode, p_iata) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $procedure$;;

-- Inyectado automáticamente: spCityEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCityEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCityEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
BEGIN
    DELETE FROM public."Cities" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spClienteActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spClienteActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spClienteActualizar(
    p_id INT,
    p_name TEXT,
    p_document TEXT,
    p_contact_info TEXT,
    p_address TEXT,
    p_mandatory_variables JSONB,
    p_acting_user_id INT,
    p_seller_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_credit_days INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Client" WHERE document = p_document AND id <> p_id) THEN
        p_mensaje_resultado := 'ERROR: El documento ya está registrado por otro cliente.';
        RETURN;
    END IF;

    UPDATE public."Client" SET
        "name" = p_name,
        "document" = p_document,
        "contactInfo" = p_contact_info,
        "address" = p_address,
        "mandatoryVariables" = p_mandatory_variables,
        "sellerId" = p_seller_id,
        "isActive" = COALESCE(p_is_active, true),
        "creditDays" = COALESCE(p_credit_days, 0)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cliente ' || p_id || ' actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$BODY$
LANGUAGE plpgsql;;

-- Inyectado automáticamente: spClienteCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spClienteCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spClienteCrear(
    p_name TEXT,
    p_document TEXT,
    p_contact_info TEXT,
    p_address TEXT,
    p_mandatory_variables JSONB,
    p_acting_user_id INT,
    p_seller_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_credit_days INT DEFAULT 0,
    INOUT p_client_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Client" WHERE document = p_document) THEN
        p_mensaje_resultado := 'ERROR: El documento ya está registrado';
        RETURN;
    END IF;

    INSERT INTO public."Client" ("name", "document", "contactInfo", "address", "mandatoryVariables", "sellerId", "isActive", "creditDays")
    VALUES (p_name, p_document, p_contact_info, p_address, p_mandatory_variables, p_seller_id, COALESCE(p_is_active, true), COALESCE(p_credit_days, 0))
    RETURNING id INTO p_client_id;

    p_mensaje_resultado := 'SUCCESS: Cliente creado con ID ' || p_client_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$BODY$
LANGUAGE plpgsql;;

-- Inyectado automáticamente: spClienteEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spClienteEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spClienteEliminar(
    p_id INT,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
AS $BODY$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT name INTO v_name FROM public."Client" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El cliente no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."Quotation" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."Invoices" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."PreQuotation" WHERE "clientId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el cliente "' || v_name || '" porque cuenta con ' || v_count || ' registro(s) de cotizaciones o facturas asociadas. Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Client" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Cliente eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$BODY$
LANGUAGE plpgsql;;

-- Inyectado automáticamente: spComboActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spComboActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spComboActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_cupos INT,
    p_currency_id INT,
    p_products JSONB,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
    DECLARE
        v_item RECORD;
        v_tax RECORD;
        v_combo_product_id INT;
        v_local_combo_id INT := p_id;
    BEGIN
        IF v_local_combo_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: p_id is NULL (backend error).';
            RETURN;
        END IF;

        -- Actualizar datos básicos
        UPDATE public."Combo" SET "code" = p_code, "name" = p_name, "cupos" = COALESCE(p_cupos, 0), "currencyId" = p_currency_id, "updatedAt"=CURRENT_TIMESTAMP WHERE id = v_local_combo_id;

        -- Limpiar productos previos
        DELETE FROM public."ComboProductTax" WHERE "comboProductId" IN (SELECT id FROM public."ComboProduct" WHERE "comboId" = v_local_combo_id);
        DELETE FROM public."ComboProduct" WHERE "comboId" = v_local_combo_id;

        -- Insertar productos nuevos
        IF p_products IS NOT NULL AND jsonb_array_length(p_products) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_to_recordset(p_products) AS x(
                "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" INT, "prestadoraId" INT, 
                "checkInDate" TIMESTAMP, "checkOutDate" TIMESTAMP,
                "paxAdults" INT, "paxChildren" INT, "mainTaxId" INT, "appliedTaxes" JSONB, "inNationality" INT
            )
            LOOP
                IF v_item."productId" IS NOT NULL THEN
                    INSERT INTO public."ComboProduct" (
                        "comboId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                        "checkInDate", "checkOutDate",
                        "paxAdults", "paxChildren", "mainTaxId", "inNationality"
                    ) VALUES (
                        v_local_combo_id, v_item."productId", COALESCE(v_item.quantity, 1), COALESCE(v_item.price, 0), v_item.cost, v_item."providerId", v_item."prestadoraId",
                        v_item."checkInDate", v_item."checkOutDate",
                        v_item."paxAdults", v_item."paxChildren", v_item."mainTaxId", COALESCE(v_item."inNationality", 1)
                    ) RETURNING id INTO v_combo_product_id;

                    -- Insertar impuestos del producto si existen
                    IF v_item."appliedTaxes" IS NOT NULL THEN
                        FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS t("chargeAndTaxId" INT, amount FLOAT, "isMain" BOOLEAN)
                        LOOP
                            INSERT INTO public."ComboProductTax" ("comboProductId", "chargeAndTaxId", "amount", "isMain")
                            VALUES (v_combo_product_id, v_tax."chargeAndTaxId", v_tax.amount, COALESCE(v_tax."isMain", FALSE));
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        p_mensaje_resultado := 'SUCCESS: Combo ' || v_local_combo_id || ' actualizado correctamente.';
    EXCEPTION WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
$$;;

-- Inyectado automáticamente: spComboCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spComboCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spComboCrear(
    p_code TEXT,
    p_name TEXT,
    p_cupos INT,
    p_currency_id INT,
    p_products JSONB,
    p_acting_user_id INT,
    INOUT p_combo_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
    DECLARE
        v_item RECORD;
        v_tax RECORD;
        v_combo_product_id INT;
        v_inserted_combo_id INT;
    BEGIN
        -- Insertar el combo principal
        INSERT INTO public."Combo" ("code", "name", "cupos", "currencyId", "createdAt","updatedAt")
        VALUES (p_code, p_name, COALESCE(p_cupos, 0), p_currency_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING id INTO v_inserted_combo_id;

        IF v_inserted_combo_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: No se pudo generar el ID del Combo.';
            RETURN;
        END IF;

        -- Insertar productos del combo
        IF p_products IS NOT NULL AND jsonb_array_length(p_products) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_to_recordset(p_products) AS x(
                "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" INT, "prestadoraId" INT, 
                "checkInDate" TIMESTAMP, "checkOutDate" TIMESTAMP,
                "paxAdults" INT, "paxChildren" INT, "mainTaxId" INT, "appliedTaxes" JSONB, "inNationality" INT
            )
            LOOP
                -- Solo insertar si hay un producto válido
                IF v_item."productId" IS NOT NULL THEN
                    INSERT INTO public."ComboProduct" (
                        "comboId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                        "checkInDate", "checkOutDate",
                        "paxAdults", "paxChildren", "mainTaxId", "inNationality"
                    ) VALUES (
                        v_inserted_combo_id, v_item."productId", COALESCE(v_item.quantity, 1), COALESCE(v_item.price, 0), v_item.cost, v_item."providerId", v_item."prestadoraId",
                        v_item."checkInDate", v_item."checkOutDate",
                        v_item."paxAdults", v_item."paxChildren", v_item."mainTaxId", COALESCE(v_item."inNationality", 1)
                    ) RETURNING id INTO v_combo_product_id;

                    -- Insertar impuestos asociados si existen
                    IF v_item."appliedTaxes" IS NOT NULL THEN
                        FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS t("chargeAndTaxId" INT, amount FLOAT, "isMain" BOOLEAN)
                        LOOP
                            INSERT INTO public."ComboProductTax" ("comboProductId", "chargeAndTaxId", "amount", "isMain")
                            VALUES (v_combo_product_id, v_tax."chargeAndTaxId", v_tax.amount, COALESCE(v_tax."isMain", FALSE));
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        p_combo_id := v_inserted_combo_id;
        p_mensaje_resultado := 'SUCCESS: Combo creado correctamente con ID ' || v_inserted_combo_id;

    EXCEPTION WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
$$;;

-- Inyectado automáticamente: spComboEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spComboEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spComboEliminar(
    p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public."Combo" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Combo eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END;
$$;;

-- Inyectado automáticamente: spCotizacionActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'dbo' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

IF OBJECT_ID('dbo.spCotizacionActualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizar;
GO

CREATE PROCEDURE dbo.spCotizacionActualizar
    @p_id INT,
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: Cotización ' + CAST(@p_id AS NVARCHAR(20)) + N' no existe.';
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END

        DECLARE @clientId INT = JSON_VALUE(@p_data, '$.clientId');
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = JSON_VALUE(@p_data, '$.branchId');
        DECLARE @implantId INT = JSON_VALUE(@p_data, '$.implantId');
        DECLARE @sellerId INT = JSON_VALUE(@p_data, '$.sellerId');
        DECLARE @ticketPrinterId INT = JSON_VALUE(@p_data, '$.ticketPrinterId');
        DECLARE @totalAmount FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @state NVARCHAR(50) = ISNULL(JSON_VALUE(@p_data, '$.state'), N'NUEVO');
        DECLARE @stateDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.stateDescription');
        DECLARE @destination NVARCHAR(250) = JSON_VALUE(@p_data, '$.destination');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @passenger NVARCHAR(250) = JSON_VALUE(@p_data, '$.passenger');
        DECLARE @paxAdults INT = JSON_VALUE(@p_data, '$.paxAdults');
        DECLARE @paxChildren INT = JSON_VALUE(@p_data, '$.paxChildren');
        DECLARE @reservationCode NVARCHAR(100) = JSON_VALUE(@p_data, '$.reservationCode');
        DECLARE @manualDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.manualDescription');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        BEGIN TRANSACTION;

        UPDATE dbo.[Quotation]
        SET
            clientId = @clientId,
            currency = @currency,
            exchangeRate = @exchangeRate,
            branchId = ISNULL(@branchId, branchId),
            implantId = @implantId,
            sellerId = @sellerId,
            ticketPrinterId = @ticketPrinterId,
            totalAmount = @totalAmount,
            baseCommissionable = @baseCommissionable,
            chargesAndTaxes = @chargesAndTaxes,
            commissionPercentage = @commissionPercentage,
            state = @state,
            stateDescription = ISNULL(@stateDescription, stateDescription),
            stateUpdatedAt = GETDATE(),
            destination = @destination,
            startDate = @startDate,
            endDate = @endDate,
            passenger = @passenger,
            paxAdults = @paxAdults,
            paxChildren = @paxChildren,
            reservationCode = @reservationCode,
            manualDescription = @manualDescription
        WHERE id = @p_id;

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DELETE FROM dbo.[QuotationProductTax] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductVariable] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPayment] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProduct] WHERE quotationId = @p_id;

            DECLARE @item_val_upd NVARCHAR(MAX);
            DECLARE item_cur_upd CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur_upd;
            FETCH NEXT FROM item_cur_upd INTO @item_val_upd;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.productId') AS INT);
                DECLARE @quantityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.quantity') AS INT), 1);
                DECLARE @priceUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.price') AS FLOAT), 0);
                DECLARE @costUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.cost') AS FLOAT), 0);
                DECLARE @providerIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.providerId') AS INT);
                DECLARE @prestadoraIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.prestadoraId') AS INT);
                DECLARE @checkInDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkOut') AS DATETIME2);
                DECLARE @nightsUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.nights') AS INT);
                DECLARE @paxAdultsItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxChildren') AS INT);
                DECLARE @serviceTypeUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.serviceType');
                DECLARE @destinationItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.destination');
                DECLARE @reservationCodeItemUpd NVARCHAR(100) = JSON_VALUE(@item_val_upd, '$.reservationCode');
                DECLARE @sellerCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.comboId') AS INT);
                DECLARE @mainTaxIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.mainTaxId') AS INT);
                DECLARE @inNationalityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.inNationality') AS INT), 1);
                DECLARE @serviceUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.service');
                DECLARE @serviciosUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.servicios');
                DECLARE @descripcionUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.descripcion');
                DECLARE @passengerItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.passenger');

                IF @providerIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerIdUpd) SET @providerIdUpd = NULL;
                IF @prestadoraIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraIdUpd) SET @prestadoraIdUpd = NULL;

                DECLARE @qp_id_upd INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, passenger
                ) VALUES (
                    @p_id, @productIdUpd, @quantityUpd, @priceUpd, @costUpd, @providerIdUpd, @prestadoraIdUpd,
                    @checkInDateUpd, @checkOutDateUpd, @nightsUpd, @paxAdultsItemUpd, @paxChildrenItemUpd, @serviceTypeUpd, @destinationItemUpd,
                    @reservationCodeItemUpd, @sellerCommissionUpd, @ticketPrinterCommissionUpd, @comboIdUpd, @mainTaxIdUpd, @inNationalityUpd,
                    @serviceUpd, @serviciosUpd, @descripcionUpd, @passengerItemUpd
                );
                SET @qp_id_upd = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val_upd, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT),
                        JSON_VALUE(tax.value, '$.valueTypeSnapshot'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxIdUpd OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val_upd, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val_upd, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, document)
                    SELECT
                        @qp_id_upd,
                        JSON_VALUE(pax.value, '$.name'),
                        JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@item_val_upd, '$.passengers') AS pax
                    WHERE JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '';
                END

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val_upd, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val_upd, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val_upd, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id_upd,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val_upd, '$.payments') AS pmt;
                END

                FETCH NEXT FROM item_cur_upd INTO @item_val_upd;
            END

            CLOSE item_cur_upd;
            DEALLOCATE item_cur_upd;
        END

        -- Recalculate totalAmount if 0 or missing
        DECLARE @calcTotalUpd FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_id
        );
        IF @calcTotalUpd IS NULL OR @calcTotalUpd = 0
        BEGIN
            SET @calcTotalUpd = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_id
            );
        END

        IF @calcTotalUpd IS NOT NULL AND @calcTotalUpd > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @calcTotalUpd,
                baseCommissionable = ISNULL(NULLIF(@baseCommissionable, 0), @calcTotalUpd),
                chargesAndTaxes = ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotalUpd)
            WHERE id = @p_id;
        END
        ELSE IF @totalAmount > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @totalAmount
            WHERE id = @p_id;
        END

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = N'SUCCESS: Cotización ' + CAST(@p_id AS NVARCHAR(20)) + N' actualizada correctamente.';
        SELECT @p_id AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = N'ERROR: ' + ERROR_MESSAGE();
        SELECT 0 AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH
END;;

-- Inyectado automáticamente: spCotizacionCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'dbo' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

IF OBJECT_ID('dbo.spCotizacionCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionCrear;
GO

CREATE PROCEDURE dbo.spCotizacionCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_quotation_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);
        END

        DECLARE @clientId INT = JSON_VALUE(@p_data, '$.clientId');
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = JSON_VALUE(@p_data, '$.branchId');
        DECLARE @implantId INT = JSON_VALUE(@p_data, '$.implantId');
        DECLARE @sellerId INT = JSON_VALUE(@p_data, '$.sellerId');
        DECLARE @ticketPrinterId INT = JSON_VALUE(@p_data, '$.ticketPrinterId');
        DECLARE @totalAmount FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @destination NVARCHAR(250) = JSON_VALUE(@p_data, '$.destination');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @passenger NVARCHAR(250) = JSON_VALUE(@p_data, '$.passenger');
        DECLARE @paxAdults INT = JSON_VALUE(@p_data, '$.paxAdults');
        DECLARE @paxChildren INT = JSON_VALUE(@p_data, '$.paxChildren');
        DECLARE @reservationCode NVARCHAR(100) = JSON_VALUE(@p_data, '$.reservationCode');
        DECLARE @manualDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.manualDescription');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        DECLARE @internalNum NVARCHAR(100) = NULL;
        EXEC dbo.spObtenerSiguienteConsecutivo N'QUOTATION', @branchId, @implantId, @consecutivo_formateado = @internalNum OUTPUT;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Quotation] (
            internalNumber, [date], clientId, currency, exchangeRate, branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, chargesAndTaxes, totalAmount, commissionPercentage, userId, state, stateDescription, stateUpdatedAt,
            destination, startDate, endDate, passenger, paxAdults, paxChildren, reservationCode, manualDescription
        ) VALUES (
            ISNULL(@internalNum, N'TEMP'), GETDATE(), @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId, @ticketPrinterId,
            @baseCommissionable, @chargesAndTaxes, @totalAmount, @commissionPercentage, @actingUserId, N'NUEVO', N'Creación de cotización', GETDATE(),
            @destination, @startDate, @endDate, @passenger, @paxAdults, @paxChildren, @reservationCode, @manualDescription
        );

        SET @p_quotation_id = SCOPE_IDENTITY();

        IF @internalNum IS NULL OR @internalNum = N'TEMP'
        BEGIN
            UPDATE dbo.[Quotation]
            SET internalNumber = CAST(@p_quotation_id AS NVARCHAR(50))
            WHERE id = @p_quotation_id;
        END

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, state, [description], createdAt, userId)
        VALUES (@p_quotation_id, N'NUEVO', N'Creación de cotización', GETDATE(), @actingUserId);

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE @item_val NVARCHAR(MAX);
            DECLARE item_cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur;
            FETCH NEXT FROM item_cur INTO @item_val;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productId INT = TRY_CAST(JSON_VALUE(@item_val, '$.productId') AS INT);
                DECLARE @quantity INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.cost') AS FLOAT), 0);
                DECLARE @providerId INT = TRY_CAST(JSON_VALUE(@item_val, '$.providerId') AS INT);
                DECLARE @prestadoraId INT = TRY_CAST(JSON_VALUE(@item_val, '$.prestadoraId') AS INT);
                DECLARE @checkInDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@item_val, '$.nights') AS INT);
                DECLARE @paxAdultsItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxChildren') AS INT);
                DECLARE @serviceType NVARCHAR(250) = JSON_VALUE(@item_val, '$.serviceType');
                DECLARE @destinationItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.destination');
                DECLARE @reservationCodeItem NVARCHAR(100) = JSON_VALUE(@item_val, '$.reservationCode');
                DECLARE @sellerCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@item_val, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@item_val, '$.mainTaxId') AS INT);
                DECLARE @inNationality INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.inNationality') AS INT), 1);
                DECLARE @service NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.service');
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.descripcion');
                DECLARE @passengerItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.passenger');

                IF @providerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerId) SET @providerId = NULL;
                IF @prestadoraId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraId) SET @prestadoraId = NULL;

                DECLARE @qp_id INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, passenger
                ) VALUES (
                    @p_quotation_id, @productId, @quantity, @price, @cost, @providerId, @prestadoraId,
                    @checkInDate, @checkOutDate, @nights, @paxAdultsItem, @paxChildrenItem, @serviceType, @destinationItem,
                    @reservationCodeItem, @sellerCommission, @ticketPrinterCommission, @comboId, @mainTaxId, @inNationality,
                    @service, @servicios, @descripcion, @passengerItem
                );
                SET @qp_id = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT),
                        JSON_VALUE(tax.value, '$.valueTypeSnapshot'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, document)
                    SELECT
                        @qp_id,
                        JSON_VALUE(pax.value, '$.name'),
                        JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@item_val, '$.passengers') AS pax
                    WHERE JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '';
                END

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val, '$.payments') AS pmt;
                END

                FETCH NEXT FROM item_cur INTO @item_val;
            END

            CLOSE item_cur;
            DEALLOCATE item_cur;
        END

        -- Recalculate totalAmount if 0 or missing
        DECLARE @calcTotal FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_quotation_id
        );
        IF @calcTotal IS NULL OR @calcTotal = 0
        BEGIN
            SET @calcTotal = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_quotation_id
            );
        END

        IF @calcTotal IS NOT NULL AND @calcTotal > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @calcTotal,
                baseCommissionable = ISNULL(NULLIF(@baseCommissionable, 0), @calcTotal),
                chargesAndTaxes = ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotal)
            WHERE id = @p_quotation_id;
        END
        ELSE IF @totalAmount > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @totalAmount
            WHERE id = @p_quotation_id;
        END

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = N'SUCCESS: Cotización creada correctamente con ID ' + CAST(@p_quotation_id AS NVARCHAR(20));
        SELECT @p_quotation_id AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = N'ERROR: ' + ERROR_MESSAGE();
        SELECT 0 AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH
END;;

-- Inyectado automáticamente: spCotizacionDuplicar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionDuplicar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCotizacionDuplicar(
    IN p_quotation_id INT,
    IN p_acting_user_id INT,
    INOUT p_new_quotation_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_internal_number TEXT;
    v_new_id INT;
    v_orig_quotation RECORD;
    v_orig_qp RECORD;
    v_new_qp_id INT;
    v_user_id INT := NULL;
BEGIN
    -- Validar existencia de la cotización origen
    SELECT * INTO v_orig_quotation 
    FROM public."Quotation" 
    WHERE id = p_quotation_id;

    IF v_orig_quotation.id IS NULL THEN
        p_mensaje_resultado := 'ERROR: Cotización origen no encontrada (ID ' || p_quotation_id || ').';
        RETURN;
    END IF;

    -- Validar si p_acting_user_id existe en la tabla User, de lo contrario usar el de la cotización origen
    IF p_acting_user_id IS NOT NULL THEN
        SELECT id INTO v_user_id FROM public."User" WHERE id = p_acting_user_id;
    END IF;

    IF v_user_id IS NULL THEN
        v_user_id := v_orig_quotation."userId";
    END IF;

    -- Generar consecutivo único interno desde TransactionConsecutive
    SELECT x.v_consec_json->>'formattedConsecutive' INTO v_internal_number
    FROM (SELECT public."fnObtenerSiguienteConsecutivo"('QUOTATION', v_orig_quotation."branchId", v_orig_quotation."implantId") AS v_consec_json) x;

    IF v_internal_number IS NULL OR v_internal_number = '' THEN
        v_internal_number := 'COT-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 10000)::text;
    END IF;

    -- Insertar la cabecera duplicada de la cotización
    INSERT INTO public."Quotation" (
        "internalNumber", "date", "clientId", "currency", "exchangeRate",
        "branchId", "implantId", "sellerId", "ticketPrinterId",
        "baseCommissionable", "commissionPercentage", "chargesAndTaxes",
        "totalAmount", "userId", "state", "stateDescription", "stateUpdatedAt",
        "costoTotal", "valorBase", "utilidad", "comisionTotalPercentage",
        "comisionFreelancePercentage", "comisionFreelanceValue",
        "comisionPropiaPercentage", "comisionPropiaValue", "comisionUtilidadPercentage",
        "destination", "startDate", "endDate", "passenger", "paxAdults", "paxChildren",
        "reservationCode", "copyFieldsToProducts", "manualDescription"
    ) VALUES (
        v_internal_number, CURRENT_TIMESTAMP, v_orig_quotation."clientId", v_orig_quotation."currency", v_orig_quotation."exchangeRate",
        v_orig_quotation."branchId", v_orig_quotation."implantId", v_orig_quotation."sellerId", v_orig_quotation."ticketPrinterId",
        v_orig_quotation."baseCommissionable", v_orig_quotation."commissionPercentage", v_orig_quotation."chargesAndTaxes",
        v_orig_quotation."totalAmount", v_user_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP,
        v_orig_quotation."costoTotal", v_orig_quotation."valorBase", v_orig_quotation."utilidad", v_orig_quotation."comisionTotalPercentage",
        v_orig_quotation."comisionFreelancePercentage", v_orig_quotation."comisionFreelanceValue",
        v_orig_quotation."comisionPropiaPercentage", v_orig_quotation."comisionPropiaValue", v_orig_quotation."comisionUtilidadPercentage",
        v_orig_quotation."destination", v_orig_quotation."startDate", v_orig_quotation."endDate", v_orig_quotation."passenger", v_orig_quotation."paxAdults", v_orig_quotation."paxChildren",
        v_orig_quotation."reservationCode", v_orig_quotation."copyFieldsToProducts", v_orig_quotation."manualDescription"
    ) RETURNING id INTO v_new_id;

    -- Insertar registro inicial en el historial de estados
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (v_new_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP, v_user_id);

    -- Duplicar combos asociados
    INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
    SELECT v_new_id, "comboId"
    FROM public."QuotationCombo"
    WHERE "quotationId" = p_quotation_id;

    -- Duplicar servicios manuales si la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        INSERT INTO public."QuotationManualService" ("quotationId", "providerName", "serviceName", "cost", "salePrice", "utility")
        SELECT v_new_id, "providerName", "serviceName", "cost", "salePrice", "utility"
        FROM public."QuotationManualService"
        WHERE "quotationId" = p_quotation_id;
    END IF;

    -- Duplicar productos y sus detalles
    FOR v_orig_qp IN 
        SELECT * FROM public."QuotationProduct" WHERE "quotationId" = p_quotation_id
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission",
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_new_id, v_orig_qp."productId", v_orig_qp."quantity", v_orig_qp."price", v_orig_qp."cost", v_orig_qp."providerId", v_orig_qp."prestadoraId",
            v_orig_qp."checkInDate", v_orig_qp."checkOutDate", v_orig_qp."nights", v_orig_qp."paxAdults", v_orig_qp."paxChildren",
            v_orig_qp."serviceType", v_orig_qp."destination", v_orig_qp."reservationCode", v_orig_qp."sellerCommission",
            v_orig_qp."ticketPrinterCommission", v_orig_qp."comboId", v_orig_qp."mainTaxId", v_orig_qp."inNationality",
            v_orig_qp."service", v_orig_qp."servicios", v_orig_qp."descripcion", v_orig_qp."passenger"
        ) RETURNING id INTO v_new_qp_id;

        -- Duplicar Pasajeros del producto
        INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
        SELECT v_new_qp_id, "name", "document"
        FROM public."QuotationProductPassenger"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Impuestos del producto
        INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain")
        SELECT v_new_qp_id, "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
        FROM public."QuotationProductTax"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Variables del producto
        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
        SELECT v_new_qp_id, "masterVariableId", "value"
        FROM public."QuotationProductVariable"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Pagos del producto
        INSERT INTO public."QuotationProductPayment" ("quotationProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
        SELECT v_new_qp_id, "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
        FROM public."QuotationProductPayment"
        WHERE "quotationProductId" = v_orig_qp.id;

    END LOOP;

    p_new_quotation_id := v_new_id;
    p_mensaje_resultado := 'SUCCESS: Cotización duplicada correctamente con ID ' || v_new_id;

    -- Registrar en auditoría
    CALL public."spLogRegistrar"(
        v_user_id, 
        'QUOTATION', 
        'DUPLICATE', 
        'Se duplicó la cotización #' || p_quotation_id || ' generando la cotización #' || v_new_id || ' (' || v_internal_number || ')', 
        jsonb_build_object('sourceQuotationId', p_quotation_id, 'newQuotationId', v_new_id), 
        v_new_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;;

-- Inyectado automáticamente: spCotizacionesCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'dbo' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

-- Eliminar si existe
IF OBJECT_ID('dbo.spCotizacionesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionesCrear;
GO

CREATE PROCEDURE dbo.spCotizacionesCrear
(
    @xml VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('dbo.ImpRet', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ImpRet (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL,
            cd_cuenta VARCHAR(20) NULL,
            am_porcentaje NUMERIC(5,2) NULL DEFAULT 0,
            in_tipo CHAR(1) NULL DEFAULT 'I',
            Id_cargo_dep INT NULL,
            bl_IVA BIT NULL DEFAULT 0
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.ImpRet WHERE id = 1)
        BEGIN
            SET IDENTITY_INSERT dbo.ImpRet ON;
            INSERT INTO dbo.ImpRet (id, cd_codigo, ds_nombre, cd_cuenta, am_porcentaje, in_tipo, bl_IVA)
            VALUES (1, '01', 'IVA 19%', '240805', 19.00, 'I', 1);
            SET IDENTITY_INSERT dbo.ImpRet OFF;
        END
    END
    ELSE IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo')
    BEGIN
        ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
    END;

    IF OBJECT_ID('dbo.CargosDesc', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CargosDesc (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL
        );
    END;

    BEGIN TRY
        DECLARE @xmlData XML;

        DECLARE @Cotizacion TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			id_sucursal INT NOT NULL,
			id_implante INT NULL,
			cd_consecutivo char(8) NOT NULL,
			id_usuario INT NOT NULL,
			dt_fechacont smalldatetime NOT NULL,
			dt_fecha smalldatetime NOT NULL,
			id_usuarioAct INT NOT NULL,
			dt_fechaAct smalldatetime NOT NULL,
			cd_tercero_codigo varchar(25) NOT NULL,
			ds_tercero_nombre varchar(250) NOT NULL,
			cd_cliente_codigo varchar(25) NOT NULL,
			ds_cliente_nombre varchar(250) NOT NULL,
			ds_cliente_dir varchar(250) NOT NULL,
			ds_cliente_ciudad varchar(40) NOT NULL,
			ds_cliente_tel varchar(25) NULL,
			ds_cliente_dirdesp varchar(250) NULL,
			ds_cliente_email varchar(60) NULL,
			ds_cliente_contacto varchar(40) NULL,
			ds_cliente_contacto_email varchar(60) NULL,
			id_monedas_IATA INT NOT NULL,
			cd_vendedor char(3) NOT NULL,
			id_tiqueteador INT NOT NULL,
			bn_anexo varbinary(max) NULL,
			am_tcambio smallmoney NOT NULL,
			am_tcambiousd money NULL,
			cd_cencosto char(16) NULL,
			ds_observacion varchar(8000) NULL,
			ds_Campo_libre1 varchar(500) NULL,
			ds_Campo_libre2 varchar(500) NULL,
			id_tipoventa INT NULL,
			in_estado tinyINT NOT NULL,
			dt_vence smalldatetime NULL,
			Id_Etapa INT NULL,
			ds_seguimiento_etapa varchar(500) NULL,
			bl_ManejaOpciones bit NOT NULL,
			in_NumeroOpciones INT NULL,
			bl_CerrarCotizacion bit NOT NULL,
			in_OpcionSeleccionada INT NULL,
			bl_grupos bit NOT NULL,
			gk_sabre varchar(25) NULL,
			id_Especialista INT NULL,
			id_TipoFormaPagoProveedor INT NULL,
			id_MedioReservacion INT NULL,
			bl_bloqueada bit NOT NULL,
			id_usuario_Bloqueo INT NULL,
			ds_AlertaSolicitud varchar(8000) NULL,
			bl_comisiona bit NOT NULL,
			ds_FormaDePago varchar(250) NULL,
			ds_records varchar(25) NULL,
			bl_entregadoCliente bit NOT NULL,
			dt_entregadoCliente smalldatetime NULL,
			id_sys_entidades INT NULL,
			id_MonedaPagoDestino INT NULL,
			id_FormaPagoDestino INT NULL,
			ds_DocumentoPagoDestino varchar(50) NULL,
			dt_CheckInPagoDestino smalldatetime NULL,
			dt_CheckOutPagoDestino smalldatetime NULL,
			bl_fechaPagoDestino bit NOT NULL,
			ds_hotelTieneTiquete varchar(2) NULL,
			ds_GDS varchar(2) NULL,
			id_Evento INT NULL,
			id_Cotizacion INT NULL,
			bl_existe BIT NULL
		)

		DECLARE @CotizacionServicios TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			id_TiposConceptFac INT NOT NULL,
			id_ConceptoFacturacion INT NOT NULL,
			id_TiposServicio INT NULL,
			id_Cotizacion INT NULL,
			id_fac_factura INT NULL,
			id_fac_remision INT NULL,
			cd_proveedores varchar(25) NULL,
			ds_tiposervnm varchar(50) NULL,
			cd_prov_hotel char(10) NULL,
			cd_prov_car char(10) NULL,
			cd_prov_air char(10) NULL,
			ds_destino varchar(30) NULL,
			ds_servicio varchar(250) NULL,
			ds_descrip varchar(4000) NULL,
			ds_paxname varchar(20) NULL,
			ds_paxape varchar(20) NULL,
			cd_paxtype char(3) NULL,
			in_nacionalidad tinyINT NOT NULL,
			cd_voucher varchar(20) NULL,
			in_cantpax INT NOT NULL,
			dt_llegada smalldatetime NULL,
			dt_salida smalldatetime NULL,
			cd_cencosto varchar(16) NULL,
			cd_auxiliar varchar(16) NULL,
			cd_item varchar(16) NULL,
			am_valorprov money NULL,
			id_monedaprov INT NULL,
			ds_InfoAdicional varchar(8000) NULL,
			id_carrental INT NULL,
			id_hoteles INT NULL,
			bl_anulado bit NOT NULL,
			cd_tiquete char(11) NULL,
			cd_fuente_anul char(2) NULL,
			cd_serie_anul char(2) NULL,
			cd_consecutivo_anul char(8) NULL,
			id_usuario_anul INT NULL,
			id_sucursal_anul INT NULL,
			id_implante_anul INT NULL,
			am_basecomisionable money NULL,
			am_porcomision numeric(8, 4) NULL,
			cd_voucherPrefijo varchar(3) NULL,
			bl_notdomicilionacional bit NULL,
			Valor_Comision money NULL,
			Valor_Recaudo money NULL,
			dias_recaudo INT NULL,
			ds_paxClasificacion char(7) NULL,
			id_tipoplan INT NULL,
			id_acomodacion INT NULL,
			in_dias INT NULL,
			in_noches INT NULL,
			ds_records varchar(25) NULL,
			id_GrConcepto INT NULL,
			in_diasSrv INT NULL,
			in_nochesSrv INT NULL,
			Id_Especialista INT NULL,
			am_porcentaje_descuento numeric(8, 4) NULL,
			am_valor_descuento money NULL,
			ds_motivo_descuento varchar(1000) NULL,
			id_cargosdesc_descuento INT NULL,
			in_NumeroOpcion INT NULL,
			dt_FechaSalidaSrv smalldatetime NULL,
			dt_FechaLlegadaSrv smalldatetime NULL,
			cd_localizador varchar(25) NULL,
			cd_voucherpax varchar(25) NULL,
			am_basecomisionableprov money NULL,
			am_porcomisionprov numeric(8, 4) NULL,
			cd_NumeFac varchar(15) NULL,
			dt_VenceFac smalldatetime NULL,
			id_AcomodacionSrv INT NULL,
			id_TipoPlanSrv INT NULL,
			in_habitaciones INT NULL,
			in_habitacionesSrv INT NULL,
			cd_Consecutivo_VariablesAdicionales varchar(8) NULL,
			cd_confirmacion varchar(25) NULL,
			ds_confirmadopor varchar(250) NULL,
			cd_paxidentificacion varchar(25) NULL,
			bl_politicaCancelacion bit NOT NULL,
			dt_politicaCancelacion smalldatetime NULL,
			id_tipoHabitacion INT NULL,
			id_fac_facturaComision INT NULL,
			id_fac_remisionComision INT NULL,
			id_TarjetaAsistencia INT NULL,
			id_Regiones INT NULL,
			Iden_GDS INT NULL,
			id_sys_entidades INT NULL,
			ds_TipoAuto varchar(50) NULL,
			ds_Origen varchar(30) NULL,
			ds_DirOrigen varchar(250) NULL,
			ds_DirDestino varchar(250) NULL,
			ds_TipoTarifa varchar(50) NULL,
			am_ValorUSD money NULL,
			ds_NoVuelo varchar(25) NULL,
			ds_Vehiculo varchar(250) NULL,
			ds_Placa varchar(25) NULL,
			ds_CategoriaVehiculo varchar(250) NULL,
			ds_NombreConductor varchar(50) NULL,
			ds_telefono varchar(25) NULL,
			ds_IdiomaConductor varchar(25) NULL,
			id_MonedaSrv INT NULL,
			id_TipoServicio INT NULL,
			id_Aerolinea INT NULL,
			in_EdadPax INT NULL,
			am_PorFacParcial numeric(8, 4) NOT NULL,
			ds_GDS varchar(2) NULL,
			dt_fechaficheroBBVA smalldatetime NULL,
			bl_tiquete bit NOT NULL,
			am_basedescuento money NULL,
			am_pordescuento numeric(18, 4) NULL,
			id_CotizacionServicios_Depende INT NULL,
			id_CotizacionServicios INT NULL,
			cd_Cotizacion varchar(25) NULL
		 )

		 DECLARE @CotizacionServicios_PaxAdicional TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_Cotizacion int NULL,
			id_CotizacionServicios int NULL,
			ds_paxape varchar(30) NULL,
			ds_paxname varchar(30) NULL,
			ds_paxprefix char(3) NULL,
			ds_paxClasificacion char(7) NULL,
			cd_voucherpax varchar(25) NULL,
			cd_paxidentificacion varchar(25) NULL,
			in_edad int NULL,
			cd_tiquete char(50) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		)

		DECLARE @CotizacionCargos TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_CotizacionServicios int NULL,
			id_cargosdesc int NOT NULL,
			ds_cargonm varchar(50) NOT NULL,
			bl_noshow bit NOT NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			am_valor  AS (am_contado+am_credito),
			am_contado_ME money NOT NULL,
			am_credito_ME money NOT NULL,
			am_valor_ME  AS (am_contado_ME+am_credito_ME),
			id_CotizacionCargos INT NULL,
			cd_CotizacionCargos varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		 )

		 DECLARE @CotizacionImpuestos TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_CotizacionCargos int NULL,
			id_ImpRet int NOT NULL,
			ds_Impas varchar(50) NOT NULL,
			cd_impcta varchar(16) NULL,
			am_porcentaje smallmoney NOT NULL,
			bl_contabilizar bit NOT NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			am_valor  AS (am_contado+am_credito),
			am_contado_ME money NOT NULL,
			am_credito_ME money NOT NULL,
			am_valor_ME  AS (am_contado_ME+am_credito_ME),
			cd_CotizacionImpuestos varchar(25) NULL,
			cd_CotizacionCargos varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		)

		DECLARE @VariableDatosMaestro TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			IDEN_Maestro numeric(18, 0) NOT NULL,
			IDEN_Variable numeric(18, 0) NOT NULL,
			CodigoMaestro varchar(50) NOT NULL,
			ValorNumerico numeric(18, 6) NULL,
			ValorFecha smalldatetime NULL,
			ValorVarchar varchar(500) NULL,
			cd_VariableDatosMaestro varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		 )

		 DECLARE @Fac_Servicios_TiposFacturacionHoteles TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL,
			cd_TiposFacturacionHoteles varchar(25) NULL,
			cd_cargosdesc varchar(25) NULL,
			id_Fac_Servicios int NULL,
			id_CotizacionServicios int NULL,
			Id_TiposFacturacionHoteles int NOT NULL,
			in_cantidad int NULL,
			am_valor money NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			Id_Cotizacion_Solicitud int NULL,
			id_cargosdesc int NULL,
			ds_cargonm varchar(50) NULL
		 )
		
		DECLARE @CotizacionServicios_TipoProv TABLE(
			id int IDENTITY(1,1) NOT NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL,
			id_CotizacionServicios int NULL,
			id_TipoProveedores int NULL,
			cd_TipoProveedores varchar(25) NULL,
			ds_TipoProveedores varchar(60) NULL,
			cd_proveedores varchar(25) NULL,
			ds_proveedores varchar(250) NULL
		)

		DECLARE @CotizacionServiciosFormasPago TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			cd_Cotizacion VARCHAR(25) NULL,
			cd_CotizacionServicios VARCHAR(25) NULL,
			id_CotizacionServicios INT NULL,
			Id_Cotizacion INT NULL,
			id_FormasPago INT NULL,
			cd_codigo VARCHAR(3) NULL,
			ds_FPnm VARCHAR(50) NULL,
			bl_FPrepresenta BIT NOT NULL DEFAULT 0,
			id_TarjetasCredito INT NULL,
			cd_tccode NCHAR(10) NULL,
			ds_tcnumber CHAR(16) NULL,
			ds_tcvoucher VARCHAR(25) NULL,
			cd_idbanco CHAR(3) NULL,
			ds_cheque VARCHAR(30) NULL,
			ds_referencia VARCHAR(50) NULL,
			am_valor MONEY NOT NULL DEFAULT 0,
			ds_tcexp VARCHAR(7) NULL,
			ds_plaza CHAR(3) NULL,
			ds_Poliza VARCHAR(20) NULL,
			ds_PolAnexo VARCHAR(20) NULL,
			am_valor_ME MONEY NOT NULL DEFAULT 0,
			ds_tcautorizacion VARCHAR(25) NULL,
			in_tccuotas INT NULL
		)

        -- Validar que el XML sea correcto
        IF @xml IS NULL OR LTRIM(RTRIM(@xml)) = ''
        BEGIN
            --THROW 50001, 'El XML es obligatorio.', 1;
            SELECT 'El XML es obligatorio.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Limpiar saltos de línea y tabuladores para evitar que se guarden en campos de texto (usuario, tercero, dirección, etc.)
        SET @xml = REPLACE(REPLACE(REPLACE(@xml, CHAR(13), ''), CHAR(10), ''), CHAR(9), '');

        SET @xmlData = TRY_CAST(@xml AS XML);

        IF @xmlData IS NULL
        BEGIN
            --THROW 50002, 'El XML no tiene un formato válido.', 1;
            SELECT 'El XML no tiene un formato válido.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Extraer los principales códigos maestros del XML para validarlos
        DECLARE @val_cd_cliente_codigo VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_cliente_codigo)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_sucursal VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_sucursal)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_vendedor VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_vendedor)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_tiqueteador VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_tiqueteador)[1]', 'VARCHAR(25)');

        -- 1. Validar Cliente
        IF @val_cd_cliente_codigo IS NOT NULL AND @val_cd_cliente_codigo <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Client] WHERE document = @val_cd_cliente_codigo OR CAST(id AS VARCHAR(25)) = @val_cd_cliente_codigo
            )
            BEGIN
                SELECT 'cliente ' + @val_cd_cliente_codigo + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 2. Validar Sucursal
        IF @val_cd_sucursal IS NOT NULL AND @val_cd_sucursal <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Branch] WHERE code = @val_cd_sucursal OR CAST(id AS VARCHAR(25)) = @val_cd_sucursal
            )
            BEGIN
                SELECT 'sucursal ' + @val_cd_sucursal + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 3. Validar Vendedor
        IF @val_cd_vendedor IS NOT NULL AND @val_cd_vendedor <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Seller] WHERE code = @val_cd_vendedor OR CAST(id AS VARCHAR(25)) = @val_cd_vendedor
            )
            BEGIN
                SELECT 'vendedor ' + @val_cd_vendedor + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 4. Validar Tiqueteador
        IF @val_cd_tiqueteador IS NOT NULL AND @val_cd_tiqueteador <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[TicketPrinter] WHERE code = @val_cd_tiqueteador OR CAST(id AS VARCHAR(25)) = @val_cd_tiqueteador
            )
            BEGIN
                SELECT 'tiqueteador ' + @val_cd_tiqueteador + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 5. Validar Proveedores de Servicios
        DECLARE @invalid_proveedor VARCHAR(25) = NULL;
        
        SELECT TOP 1 @invalid_proveedor = S.node.value('cd_proveedores[1]', 'VARCHAR(25)')
        FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios') AS S(node)
        WHERE S.node.value('cd_proveedores[1]', 'VARCHAR(25)') IS NOT NULL 
          AND S.node.value('cd_proveedores[1]', 'VARCHAR(25)') <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.[Provider] WHERE code = S.node.value('cd_proveedores[1]', 'VARCHAR(25)') OR CAST(id AS VARCHAR(25)) = S.node.value('cd_proveedores[1]', 'VARCHAR(25)')
          );

        IF @invalid_proveedor IS NOT NULL
        BEGIN
            SELECT 'proveedor ' + @invalid_proveedor + ' no existe' AS 'Respuesta', 1 AS 'Estado';
            RETURN 1;
        END

        -- 6. Si la base de datos es Standalone KoreX (sin tabla dbo.Cotizacion de Zeus ERP), responder OK
        IF OBJECT_ID('dbo.Cotizacion', 'U') IS NULL
        BEGIN
            SELECT 'Cotización exportada exitosamente (Entorno Standalone KoreX)' AS 'Respuesta', 0 AS 'Estado';
            RETURN 0;
        END

        -- Extraer datos del XML
        BEGIN TRANSACTION;

		INSERT INTO @Cotizacion(
			id_sucursal,
			id_implante,
			cd_consecutivo,
			id_usuario,
			dt_fechacont,
			dt_fecha,
			id_usuarioAct,
			dt_fechaAct,
			cd_tercero_codigo,
			ds_tercero_nombre,
			cd_cliente_codigo,
			ds_cliente_nombre,
			ds_cliente_dir,
			ds_cliente_ciudad,
			ds_cliente_tel,
			ds_cliente_dirdesp,
			ds_cliente_email,
			ds_cliente_contacto,
			ds_cliente_contacto_email,
			id_monedas_IATA,
			cd_vendedor,
			id_tiqueteador,
			bn_anexo,
			am_tcambio,
			am_tcambiousd,
			cd_cencosto,
			ds_observacion,
			ds_Campo_libre1,
			ds_Campo_libre2,
			id_tipoventa,
			in_estado,
			dt_vence,
			Id_Etapa,
			ds_seguimiento_etapa,
			bl_ManejaOpciones,
			in_NumeroOpciones,
			bl_CerrarCotizacion,
			in_OpcionSeleccionada,
			bl_grupos,
			gk_sabre,
			id_Especialista,
			id_TipoFormaPagoProveedor,
			id_MedioReservacion,
			bl_bloqueada,
			id_usuario_Bloqueo,
			ds_AlertaSolicitud,
			bl_comisiona,
			ds_FormaDePago,
			ds_records,
			bl_entregadoCliente,
			dt_entregadoCliente,
			id_sys_entidades,
			id_MonedaPagoDestino,
			id_FormaPagoDestino,
			ds_DocumentoPagoDestino,
			dt_CheckInPagoDestino,
			dt_CheckOutPagoDestino,
			bl_fechaPagoDestino,
			ds_hotelTieneTiquete,
			ds_GDS,
			id_Evento,
			id_Cotizacion,
			bl_existe
		)	
        SELECT 
			id_sucursal = ISNULL(S.id,1),
			id_implante = I.id,
			cd_consecutivo = C.Cotizacion.value('cd_consecutivo[1]','VARCHAR(25)'),
			id_usuario = ISNULL(U.id,1),
			dt_fechacont = ISNULL(C.Cotizacion.value('dt_fechacont[1]','SMALLDATETIME'),'19000101'),
			dt_fecha = ISNULL(C.Cotizacion.value('dt_fecha[1]','SMALLDATETIME'),'19000101'),
			id_usuarioAct = ISNULL(U.id,1),
			dt_fechaAct = ISNULL(C.Cotizacion.value('dt_fechaAct[1]','SMALLDATETIME'),'19000101'),
			cd_tercero_codigo = ISNULL(CL.document, ISNULL(C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),'')),
			ds_tercero_nombre = ISNULL(CL.name, ISNULL(C.Cotizacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),'')),
			cd_cliente_codigo = ISNULL(C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),''),
			ds_cliente_nombre = ISNULL(C.Cotizacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),''),
			ds_cliente_dir = ISNULL(C.Cotizacion.value('ds_cliente_dir[1]','VARCHAR(250)'),''),
			ds_cliente_ciudad = ISNULL(C.Cotizacion.value('ds_cliente_ciudad[1]','VARCHAR(40)'),''),
			ds_cliente_tel = ISNULL(C.Cotizacion.value('ds_cliente_tel[1]','VARCHAR(25)'),''),
			ds_cliente_dirdesp = ISNULL(C.Cotizacion.value('ds_cliente_dirdesp[1]','VARCHAR(250)'),''),
			ds_cliente_email = ISNULL(C.Cotizacion.value('ds_cliente_email[1]','VARCHAR(60)'),''),
			ds_cliente_contacto = ISNULL(C.Cotizacion.value('ds_cliente_contacto[1]','VARCHAR(40)'),''),
			ds_cliente_contacto_email = ISNULL(C.Cotizacion.value('ds_cliente_contacto_email[1]','VARCHAR(60)'),''),
			id_monedas_IATA = ISNULL(M.id,1),
			cd_vendedor = ISNULL(C.Cotizacion.value('cd_vendedor[1]','VARCHAR(3)'),''),
			id_tiqueteador = ISNULL(Tq.id, ISNULL((SELECT TOP 1 id FROM dbo.[TicketPrinter]), 1)),
			bn_anexo = NULL,
			am_tcambio = ISNULL(C.Cotizacion.value('am_tcambio[1]','SMALLMONEY'),1),
			am_tcambiousd = ISNULL(C.Cotizacion.value('am_tcambiousd[1]','MONEY'),1),
			cd_cencosto = ISNULL(C.Cotizacion.value('cd_cencosto[1]','VARCHAR(16)'),''),
			ds_observacion = ISNULL(C.Cotizacion.value('ds_observacion[1]','VARCHAR(8000)'),''),
			ds_Campo_libre1 = ISNULL(C.Cotizacion.value('ds_Campo_libre1[1]','VARCHAR(500)'),''),
			ds_Campo_libre2 = ISNULL(C.Cotizacion.value('ds_Campo_libre2[1]','VARCHAR(500)'),''),
			id_tipoventa = Tv.id,
			in_estado = ISNULL(C.Cotizacion.value('in_estado[1]','INT'),1),
			dt_vence = C.Cotizacion.value('dt_vence[1]','SMALLDATETIME'),
			Id_Etapa = NULL,
			ds_seguimiento_etapa = '',
			bl_ManejaOpciones = 0,
			in_NumeroOpciones = NULL,
			bl_CerrarCotizacion = 0,
			in_OpcionSeleccionada = NULL,
			bl_grupos = 0,
			gk_sabre = '',
			id_Especialista = NULL,
			id_TipoFormaPagoProveedor = NULL,
			id_MedioReservacion = NULL,
			bl_bloqueada = 0,
			id_usuario_Bloqueo = NULL,
			ds_AlertaSolicitud = '',
			bl_comisiona = 0,
			ds_FormaDePago = ISNULL(C.Cotizacion.value('ds_FormaDePago[1]','VARCHAR(250)'),''),
			ds_records = '',
			bl_entregadoCliente = 0,
			dt_entregadoCliente = NULL,
			id_sys_entidades = 65,
			id_MonedaPagoDestino = NULL,
			id_FormaPagoDestino = NULL,
			ds_DocumentoPagoDestino = NULL,
			dt_CheckInPagoDestino = NULL,
			dt_CheckOutPagoDestino = NULL,
			bl_fechaPagoDestino = 0,
			ds_hotelTieneTiquete = NULL,
			ds_GDS = C.Cotizacion.value('ds_GDS[1]','VARCHAR(2)'),
			id_Evento = NULL,
			id_Cotizacion = NULL,
			bl_existe = CASE WHEN CC.id IS NOT NULL THEN 1 ELSE 0 END 
        FROM @xmlData.nodes('Cotizaciones/Cotizacion') AS C(Cotizacion)
		LEFT JOIN dbo.[Branch] S ON (S.code = C.Cotizacion.value('cd_sucursal[1]','VARCHAR(25)') OR CAST(S.id AS VARCHAR(25)) = C.Cotizacion.value('cd_sucursal[1]','VARCHAR(25)'))
		LEFT JOIN dbo.[Implant] I ON (I.code = C.Cotizacion.value('cd_implante[1]','VARCHAR(25)') OR CAST(I.id AS VARCHAR(25)) = C.Cotizacion.value('cd_implante[1]','VARCHAR(25)'))
		LEFT JOIN dbo.[User] U ON (U.email = C.Cotizacion.value('cd_usuario[1]','VARCHAR(250)') OR U.name = C.Cotizacion.value('cd_usuario[1]','VARCHAR(250)'))
		LEFT JOIN dbo.[Client] CL ON (CL.document = C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)') OR CAST(CL.id AS VARCHAR(25)) = C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'))
		LEFT JOIN dbo.Monedas_IATA M ON M.cd_codigo=C.Cotizacion.value('cd_monedas_IATA[1]','VARCHAR(3)')
		LEFT JOIN dbo.[TicketPrinter] Tq ON (Tq.code = C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(6)') OR CAST(Tq.id AS VARCHAR(25)) = C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(6)'))
		LEFT JOIN dbo.TipoVenta Tv ON Tv.cd_codigo=C.Cotizacion.value('cd_tipoventa[1]','VARCHAR(16)')
		LEFT JOIN dbo.Cotizacion CC ON CC.cd_consecutivo = C.Cotizacion.value('cd_consecutivo[1]','VARCHAR(25)')		 
		
		INSERT INTO @CotizacionServicios(
			id_TiposConceptFac ,
			id_ConceptoFacturacion ,
			id_TiposServicio ,
			id_Cotizacion ,
			id_fac_factura ,
			id_fac_remision,
			cd_proveedores ,
			ds_tiposervnm ,
			cd_prov_hotel,
			cd_prov_car,
			cd_prov_air,
			ds_destino ,
			ds_servicio ,
			ds_descrip,
			ds_paxname,
			ds_paxape,
			cd_paxtype,
			in_nacionalidad ,
			cd_voucher ,
			in_cantpax ,
			dt_llegada ,
			dt_salida ,
			cd_cencosto ,
			cd_auxiliar ,
			cd_item ,
			am_valorprov ,
			id_monedaprov ,
			ds_InfoAdicional ,
			id_carrental ,
			id_hoteles ,
			bl_anulado ,
			cd_tiquete ,
			cd_fuente_anul ,
			cd_serie_anul ,
			cd_consecutivo_anul ,
			id_usuario_anul,
			id_sucursal_anul,
			id_implante_anul,
			am_basecomisionable,
			am_porcomision ,
			cd_voucherPrefijo,
			bl_notdomicilionacional,
			Valor_Comision,
			Valor_Recaudo,
			dias_recaudo,
			ds_paxClasificacion,
			id_tipoplan,
			id_acomodacion ,
			in_dias,
			in_noches ,
			ds_records ,
			id_GrConcepto,
			in_diasSrv,
			in_nochesSrv ,
			Id_Especialista ,
			am_porcentaje_descuento ,
			am_valor_descuento ,
			ds_motivo_descuento ,
			id_cargosdesc_descuento,
			in_NumeroOpcion ,
			dt_FechaSalidaSrv ,
			dt_FechaLlegadaSrv ,
			cd_localizador ,
			cd_voucherpax ,
			am_basecomisionableprov ,
			am_porcomisionprov ,
			cd_NumeFac ,
			dt_VenceFac ,
			id_AcomodacionSrv ,
			id_TipoPlanSrv ,
			in_habitaciones ,
			in_habitacionesSrv ,
			cd_Consecutivo_VariablesAdicionales ,
			cd_confirmacion,
			ds_confirmadopor,
			cd_paxidentificacion,
			bl_politicaCancelacion,
			dt_politicaCancelacion,
			id_tipoHabitacion,
			id_fac_facturaComision,
			id_fac_remisionComision,
			id_TarjetaAsistencia,
			id_Regiones,
			Iden_GDS,
			id_sys_entidades,
			ds_TipoAuto,
			ds_Origen,
			ds_DirOrigen ,
			ds_DirDestino,
			ds_TipoTarifa,
			am_ValorUSD,
			ds_NoVuelo ,
			ds_Vehiculo,
			ds_Placa ,
			ds_CategoriaVehiculo ,
			ds_NombreConductor ,
			ds_telefono ,
			ds_IdiomaConductor ,
			id_MonedaSrv ,
			id_TipoServicio ,
			id_Aerolinea ,
			in_EdadPax,
			am_PorFacParcial,
			ds_GDS,
			dt_fechaficheroBBVA,
			bl_tiquete,
			am_basedescuento,
			am_pordescuento,
			id_CotizacionServicios_Depende,
			id_CotizacionServicios,
			cd_Cotizacion
		 )
		 SELECT
			id_TiposConceptFac = ISNULL(CF.id_TiposConceptoFacturacion,2),
			id_ConceptoFacturacion = ISNULL(CF.id,3),
			id_TiposServicio=ISNULL(TS.id,9) ,
			id_Cotizacion=NULL ,
			id_fac_factura=NULL ,
			id_fac_remision=NULL,
			cd_proveedores=ISNULL(C.CotizacionServicios.value('cd_proveedores[1]','VARCHAR(25)'),'') ,
			ds_tiposervnm=ISNULL(C.CotizacionServicios.value('ds_tiposervnm[1]','VARCHAR(25)'),'') ,
			cd_prov_hotel=ISNULL(C.CotizacionServicios.value('cd_prov_hotel[1]','VARCHAR(25)'),'') ,
			cd_prov_car=ISNULL(C.CotizacionServicios.value('cd_prov_car[1]','VARCHAR(25)'),'') ,
			cd_prov_air=ISNULL(C.CotizacionServicios.value('cd_prov_air[1]','VARCHAR(25)'),'') ,
			ds_destino=ISNULL(C.CotizacionServicios.value('ds_destino[1]','VARCHAR(25)'),'') ,
			ds_servicio=ISNULL(C.CotizacionServicios.value('ds_servicio[1]','VARCHAR(25)'),'') ,
			ds_descrip=ISNULL(C.CotizacionServicios.value('ds_descrip[1]','VARCHAR(25)'),'') ,
			ds_paxname=ISNULL(C.CotizacionServicios.value('ds_paxname[1]','VARCHAR(25)'),'') ,
			ds_paxape=ISNULL(C.CotizacionServicios.value('ds_paxape[1]','VARCHAR(25)'),'') ,
			cd_paxtype=SUBSTRING(ISNULL(C.CotizacionServicios.value('cd_paxtype[1]','VARCHAR(25)'),''), 1, 3) ,
			in_nacionalidad=ISNULL(C.CotizacionServicios.value('in_nacionalidad[1]','INT'),1) ,
			cd_voucher=ISNULL(C.CotizacionServicios.value('cd_voucher[1]','VARCHAR(25)'),'') ,
			in_cantpax=ISNULL(C.CotizacionServicios.value('in_cantpax[1]','INT'),1) ,
			dt_llegada=ISNULL(C.CotizacionServicios.value('dt_llegada[1]','SMALLDATETIME'),'19000101'),
			dt_salida=ISNULL(C.CotizacionServicios.value('dt_salida[1]','SMALLDATETIME'),'19000101'),
			cd_cencosto=ISNULL(C.CotizacionServicios.value('cd_cencosto[1]','VARCHAR(25)'),'')  ,
			cd_auxiliar=ISNULL(C.CotizacionServicios.value('cd_auxiliar[1]','VARCHAR(25)'),'')  ,
			cd_item =ISNULL(C.CotizacionServicios.value('cd_item[1]','VARCHAR(25)'),'') ,
			am_valorprov = 0,
			id_monedaprov = NULL,
			ds_InfoAdicional ='',
			id_carrental = NULL,
			id_hoteles = H.id,
			bl_anulado = 0,
			cd_tiquete ='',
			cd_fuente_anul ='',
			cd_serie_anul ='',
			cd_consecutivo_anul ='',
			id_usuario_anul=NULL,
			id_sucursal_anul=NULL,
			id_implante_anul=NULL,
			am_basecomisionable=ISNULL(C.CotizacionServicios.value('am_basecomisionable[1]','MONEY'),0) ,
			am_porcomision=ISNULL(C.CotizacionServicios.value('am_porcomision[1]','MONEY'),0) ,
			cd_voucherPrefijo='',
			bl_notdomicilionacional=0,
			Valor_Comision=ISNULL(C.CotizacionServicios.value('valor_comision[1]','MONEY'),0) ,
			Valor_Recaudo=0,
			dias_recaudo=0,
			ds_paxClasificacion=SUBSTRING(ISNULL(C.CotizacionServicios.value('ds_paxclasificacion[1]','VARCHAR(25)'),''), 1, 7) ,
			id_tipoplan=NULL,
			id_acomodacion=NULL ,
			in_dias=ISNULL(C.CotizacionServicios.value('in_dias[1]','INT'),1),
			in_noches=ISNULL(C.CotizacionServicios.value('in_noches[1]','INT'),1) ,
			ds_records =ISNULL(C.CotizacionServicios.value('ds_records[1]','VARCHAR(25)'),'') ,
			id_GrConcepto=NULL,
			in_diasSrv=0,
			in_nochesSrv=0 ,
			Id_Especialista=NULL ,
			am_porcentaje_descuento=0 ,
			am_valor_descuento=0 ,
			ds_motivo_descuento='' ,
			id_cargosdesc_descuento=NULL,
			in_NumeroOpcion=0 ,
			dt_FechaSalidaSrv=GETDATE() ,
			dt_FechaLlegadaSrv=GETDATE() ,
			cd_localizador='' ,
			cd_voucherpax='' ,
			am_basecomisionableprov=0 ,
			am_porcomisionprov=0 ,
			cd_NumeFac='' ,
			dt_VenceFac=GETDATE() ,
			id_AcomodacionSrv=NULL ,
			id_TipoPlanSrv=NULL ,
			in_habitaciones=0 ,
			in_habitacionesSrv=0 ,
			cd_Consecutivo_VariablesAdicionales=ISNULL(C.CotizacionServicios.value('cd_consecutivo_variablesadicionales[1]','VARCHAR(25)'),'') ,
			cd_confirmacion='',
			ds_confirmadopor='',
			cd_paxidentificacion='',
			bl_politicaCancelacion=0,
			dt_politicaCancelacion=NULL,
			id_tipoHabitacion=NULL,
			id_fac_facturaComision=NULL,
			id_fac_remisionComision=NULL,
			id_TarjetaAsistencia=NULL,
			id_Regiones=NULL,
			Iden_GDS=6,
			id_sys_entidades=35,
			ds_TipoAuto='',
			ds_Origen='',
			ds_DirOrigen='' ,
			ds_DirDestino='',
			ds_TipoTarifa='',
			am_ValorUSD=1,
			ds_NoVuelo='' ,
			ds_Vehiculo='',
			ds_Placa='' ,
			ds_CategoriaVehiculo='' ,
			ds_NombreConductor='' ,
			ds_telefono='' ,
			ds_IdiomaConductor='' ,
			id_MonedaSrv=NULL,
			id_TipoServicio=NULL ,
			id_Aerolinea=NULL ,
			in_EdadPax=0,
			am_PorFacParcial=0,
			ds_GDS='',
			dt_fechaficheroBBVA=GETDATE(),
			bl_tiquete=0,
			am_basedescuento=0,
			am_pordescuento=0,
			id_CotizacionServicios_Depende=NULL,
			id_CotizacionServicios=NULL,
			cd_Cotizacion = ISNULL(C.CotizacionServicios.value('cd_cotizacion[1]','VARCHAR(25)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios') AS C(CotizacionServicios)
		 LEFT JOIN dbo.ConceptoFacturacion CF ON CF.cd_codigo=C.CotizacionServicios.value('cd_conceptofacturacion[1]','VARCHAR(25)')
		 LEFT JOIN dbo.TiposServicios TS ON TS.cd_codigo=C.CotizacionServicios.value('cd_tiposservicio[1]','VARCHAR(25)')
		 LEFT JOIN dbo.Hoteles H ON H.cd_codigo=C.CotizacionServicios.value('cd_hoteles[1]','VARCHAR(25)')
        
		INSERT INTO @CotizacionServicios_PaxAdicional(
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete,
			cd_Cotizacion,
			cd_CotizacionServicios
		)
		SELECT
			id_Cotizacion=NULL,
			id_CotizacionServicios=NULL,
			ds_paxape=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxape[1]','VARCHAR(30)'),''),
			ds_paxname=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxname[1]','VARCHAR(30)'),''),
			ds_paxprefix=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxprefix[1]','VARCHAR(3)'),''),
			ds_paxClasificacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxClasificacion[1]','VARCHAR(7)'),''),
			cd_voucherpax=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_voucherpax[1]','VARCHAR(25)'),''),
			cd_paxidentificacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_tiquete[1]','VARCHAR(25)'),''),
			in_edad=ISNULL(C.CotizacionServicios_PaxAdicional.value('in_edad[1]','INT'),''),
			cd_tiquete=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_tiquete[1]','VARCHAR(11)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'') 
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_PaxAdicional') AS C(CotizacionServicios_PaxAdicional)	
		
		INSERT INTO @CotizacionCargos(
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado ,
			am_credito ,
			am_contado_ME ,
			am_credito_ME ,
			id_CotizacionCargos,
			cd_CotizacionCargos,
			cd_Cotizacion,
			cd_CotizacionServicios
		 )
		 SELECT 
			id_CotizacionServicios=NULL,
			id_cargosdesc=CD.id,
			ds_cargonm=ISNULL(C.CotizacionCargos.value('ds_cargonm[1]','VARCHAR(50)'),''),
			bl_noshow=ISNULL(C.CotizacionCargos.value('bl_noshow[1]','INT'),''),
			am_contado=ISNULL(C.CotizacionCargos.value('am_contado[1]','MONEY'),''),
			am_credito=ISNULL(C.CotizacionCargos.value('am_credito[1]','MONEY'),''),
			am_contado_ME=ISNULL(C.CotizacionCargos.value('am_contado_ME[1]','MONEY'),''),
			am_credito_ME=ISNULL(C.CotizacionCargos.value('am_credito_ME[1]','MONEY'),''),
			id_CotizacionCargos=NULL,
			cd_CotizacionCargos = ISNULL(C.CotizacionCargos.value('cd_cotizacioncargos[1]','VARCHAR(25)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionCargos.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionCargos.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionCargos') AS C(CotizacionCargos)
		 LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=ISNULL(C.CotizacionCargos.value('cd_cargosdesc[1]','VARCHAR(3)'),'') 

		INSERT INTO @CotizacionImpuestos(
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME,
			cd_CotizacionImpuestos,
			cd_CotizacionCargos,
			cd_Cotizacion,
			cd_CotizacionServicios
		)
		SELECT
			id_CotizacionCargos=NULL,
			id_ImpRet=IR.id,
			ds_Impas= ISNULL(C.CotizacionImpuestos.value('ds_impas[1]','VARCHAR(16)'),''),
			cd_impcta= ISNULL(C.CotizacionImpuestos.value('cd_impcta[1]','VARCHAR(16)'),''),
			am_porcentaje=ISNULL(C.CotizacionImpuestos.value('am_porcentaje[1]','MONEY'),0),
			bl_contabilizar=ISNULL(C.CotizacionImpuestos.value('bl_contabilizar[1]','INT'),0),
			am_contado=ISNULL(C.CotizacionImpuestos.value('am_contado[1]','MONEY'),0),
			am_credito=ISNULL(C.CotizacionImpuestos.value('am_credito[1]','MONEY'),0),
			am_contado_ME=ISNULL(C.CotizacionImpuestos.value('am_contado_ME[1]','MONEY'),0),
			am_credito_ME=ISNULL(C.CotizacionImpuestos.value('am_credito_ME[1]','MONEY'),0),
			cd_CotizacionImpuestos = ISNULL(C.CotizacionImpuestos.value('cd_cotizacionimpuestos[1]','VARCHAR(25)'),''),
			cd_CotizacionCargos = ISNULL(C.CotizacionImpuestos.value('cd_cotizacioncargos[1]','VARCHAR(25)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionImpuestos.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionImpuestos.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'')
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionImpuestos') AS C(CotizacionImpuestos)
		LEFT JOIN dbo.ImpRet IR ON IR.cd_codigo=ISNULL(C.CotizacionImpuestos.value('cd_impret[1]','VARCHAR(3)'),'') 

		INSERT INTO @VariableDatosMaestro(
			IDEN_Maestro ,
			IDEN_Variable ,
			CodigoMaestro ,
			ValorNumerico ,
			ValorFecha ,
			ValorVarchar 
		 )
		 SELECT
			IDEN_Maestro=M.IDEN ,
			IDEN_Variable=V.IDEN ,
			CodigoMaestro=ISNULL(C.CotizacionServicios_VariableAdicional.value('cd_cotizacionservicios[1]','VARCHAR(50)'),'') ,
			ValorNumerico=NULL ,
			ValorFecha=NULL ,
			ValorVarchar=ISNULL(C.CotizacionServicios_VariableAdicional.value('ds_valor[1]','VARCHAR(500)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_VariableAdicional') AS C(CotizacionServicios_VariableAdicional)
		 LEFT JOIN dbo.VariableDefinicion V ON V.Nombre = ISNULL(C.CotizacionServicios_VariableAdicional.value('cd_codigo[1]','VARCHAR(25)'),'')
		 LEFT JOIN dbo.VariableDefinicionMaestro M ON M.Codigo = ISNULL(C.CotizacionServicios_VariableAdicional.value('ds_maestro[1]','VARCHAR(30)'),'')
		 
		 INSERT INTO @Fac_Servicios_TiposFacturacionHoteles (
			cd_Cotizacion,
			cd_CotizacionServicios,
			cd_TiposFacturacionHoteles,
			cd_cargosdesc,
			id_Fac_Servicios,
			id_CotizacionServicios,
			Id_TiposFacturacionHoteles,
			in_cantidad,
			am_valor,
			am_contado,
			am_credito,
			Id_Cotizacion_Solicitud,
			id_cargosdesc,
			ds_cargonm
		)
		SELECT cd_Cotizacion=ISNULL(C.TiposFacturacionHoteles.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			   cd_CotizacionServicios=ISNULL(C.TiposFacturacionHoteles.value('cd_cotizacionservicios[1]','VARCHAR(25)'),''),
			   cd_TiposFacturacionHoteles=ISNULL(C.TiposFacturacionHoteles.value('cd_tiposfacturacionhoteles[1]','VARCHAR(25)'),''),
			   cd_cargosdesc=ISNULL(C.TiposFacturacionHoteles.value('cd_cargosdesc[1]','VARCHAR(25)'),'TAR'),
			   id_Fac_Servicios=NULL,
			   id_CotizacionServicios=NULL,
			   Id_TiposFacturacionHoteles=ISNULL(TF.id,5),
			   in_cantidad=ISNULL(C.TiposFacturacionHoteles.value('in_cantidad[1]','INT'),1),
			   am_valor=ISNULL(C.TiposFacturacionHoteles.value('am_valor[1]','MONEY'),0),
			   am_contado=ISNULL(C.TiposFacturacionHoteles.value('am_contado[1]','MONEY'),0),
			   am_credito=ISNULL(C.TiposFacturacionHoteles.value('am_credito[1]','MONEY'),0),
			   Id_Cotizacion_Solicitud=NULL,
			   id_cargosdesc=ISNULL(CD.id,1),
			   ds_cargonm=ISNULL(CD.ds_nombre,'Tarifa')
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/Fac_Servicios_TiposFacturacionHoteles') AS C(TiposFacturacionHoteles)
		LEFT JOIN dbo.TiposFacturacionHoteles TF ON TF.cd_codigo=ISNULL(C.TiposFacturacionHoteles.value('cd_tiposfacturacionhotel[1]','VARCHAR(3)'),'') 
		LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=ISNULL(C.TiposFacturacionHoteles.value('cd_cargosdesc[1]','VARCHAR(3)'),'') 

		INSERT INTO @CotizacionServicios_TipoProv(
			cd_Cotizacion,
			cd_CotizacionServicios,
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		)
		SELECT
			cd_Cotizacion=ISNULL(C.CotizacionServicios_TipoProv.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionServicios_TipoProv.value('cd_cotizacionservicios[1]','VARCHAR(25)'),''),
			id_CotizacionServicios=NULL,
			id_TipoProveedores=ISNULL(TP.id,1),
			cd_TipoProveedores=ISNULL(TP.cd_codigo,'Hotel'),
			ds_TipoProveedores=ISNULL(TP.ds_descrip,'Proveedor Tipo Hotel'),
			cd_proveedores=ISNULL(H.cd_codigo,''),
			ds_proveedores=ISNULL(H.ds_nombre,'')	
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_TipoProv') AS C(CotizacionServicios_TipoProv)
		LEFT JOIN dbo.TipoProveedores TP ON TP.cd_codigo=ISNULL(C.CotizacionServicios_TipoProv.value('cd_tipoproveedores[1]','VARCHAR(3)'),'')
		LEFT JOIN dbo.Hoteles H ON H.cd_codigo=ISNULL(C.CotizacionServicios_TipoProv.value('cd_proveedores[1]','VARCHAR(25)'),'')
		
		-- Insert (cd_consecutivo automático)
        INSERT INTO dbo.Cotizacion(
				id_sucursal,
				id_implante,
				cd_consecutivo,
				id_usuario,
				dt_fechacont,
				id_usuarioAct,  
				dt_fechaAct,
				dt_vence, 
				cd_tercero_codigo,
				ds_tercero_nombre,
				cd_cliente_codigo,
				ds_cliente_nombre,
				ds_cliente_dir,
				ds_cliente_ciudad,
				ds_cliente_tel,
				ds_cliente_dirdesp,
				ds_cliente_email,
				ds_cliente_contacto,
				ds_cliente_contacto_email,
				id_monedas_IATA,
				am_tcambio,
				cd_vendedor,
				id_tiqueteador,
				am_tcambiousd,
				id_tipoventa,
				ds_observacion,
				ds_Campo_libre1,
				ds_Campo_libre2,
				in_estado,
				bl_ManejaOpciones,
				in_NumeroOpciones,
				bl_CerrarCotizacion,
				in_OpcionSeleccionada,
				bl_grupos,
				id_Especialista,
				id_TipoFormaPagoProveedor,
				id_MedioReservacion,
				bl_comisiona,
				ds_alertasolicitud	,
				ds_FormaDePago ,
				bl_entregadoCliente,
				dt_entregadoCliente,
				id_sys_entidades, 
				id_MonedaPagoDestino,	
				id_FormaPagoDestino	,
				ds_DocumentoPagoDestino,
				BL_fechaPagoDestino,
				dt_CheckInPagoDestino,	
				dt_CheckOutPagoDestino,
				ds_hotelTieneTiquete, 
				ds_GDS, 
				id_evento
		)
		SELECT id_sucursal,
				id_implante,
				cd_consecutivo,
				id_usuario,
				dt_fechacont,
				id_usuarioAct,  
				dt_fechaAct,
				dt_vence, 
				cd_tercero_codigo,
				ds_tercero_nombre,
				cd_cliente_codigo,
				ds_cliente_nombre,
				ds_cliente_dir,
				ds_cliente_ciudad,
				ds_cliente_tel,
				ds_cliente_dirdesp,
				ds_cliente_email,
				ds_cliente_contacto,
				ds_cliente_contacto_email,
				id_monedas_IATA,
				am_tcambio,
				cd_vendedor,
				id_tiqueteador,
				am_tcambiousd,
				id_tipoventa,
				ds_observacion,
				ds_Campo_libre1,
				ds_Campo_libre2,
				in_estado,
				bl_ManejaOpciones,
				in_NumeroOpciones,
				bl_CerrarCotizacion,
				in_OpcionSeleccionada,
				bl_grupos,
				id_Especialista,
				id_TipoFormaPagoProveedor,
				id_MedioReservacion,
				bl_comisiona,
				ds_alertasolicitud	,
				ds_FormaDePago ,
				bl_entregadoCliente,
				dt_entregadoCliente,
				id_sys_entidades, 
				id_MonedaPagoDestino,	
				id_FormaPagoDestino	,
				ds_DocumentoPagoDestino,
				BL_fechaPagoDestino,
				dt_CheckInPagoDestino,	
				dt_CheckOutPagoDestino,
				ds_hotelTieneTiquete, 
				ds_GDS, 	
				id_evento
		FROM @Cotizacion
		WHERE bl_existe=0

		UPDATE CC
		SET CC.id_cotizacion=C.id
		FROM @Cotizacion CC
		INNER JOIN dbo.Cotizacion C ON C.cd_consecutivo=CC.cd_consecutivo

		UPDATE CS
		SET CS.id_cotizacion=C.id
		FROM @CotizacionServicios CS
		INNER JOIN dbo.Cotizacion C ON C.cd_consecutivo=CS.cd_Cotizacion
		
		INSERT INTO CotizacionServicios(
			id_TiposConceptFac,
			id_ConceptoFacturacion,
			id_TiposServicio,
			id_Cotizacion,
			id_fac_factura,
			id_fac_remision,
			cd_proveedores,
			ds_tiposervnm ,
			cd_prov_hotel,
			cd_prov_car,
			cd_prov_air,
			ds_destino ,
			ds_servicio,
			ds_descrip ,
			ds_paxname,
			ds_paxape,
			cd_paxtype ,
			in_nacionalidad,
			cd_voucher,
			in_cantpax ,
			dt_llegada ,
			dt_salida ,
			cd_cencosto ,
			cd_auxiliar,
			cd_item ,
			am_valorprov,
			id_monedaprov,
			ds_InfoAdicional,
			id_carrental,
			id_hoteles,
			bl_anulado ,
			cd_tiquete ,
			cd_fuente_anul ,
			cd_serie_anul ,
			cd_consecutivo_anul,
			id_usuario_anul,
			id_sucursal_anul,
			id_implante_anul,
			am_basecomisionable,
			am_porcomision,
			cd_voucherPrefijo,
			bl_notdomicilionacional,
			Valor_Comision,
			Valor_Recaudo,
			dias_recaudo,
			ds_paxClasificacion,
			id_tipoplan,
			id_acomodacion,
			in_dias,
			in_noches,
			ds_records,
			id_GrConcepto,
			in_diasSrv,
			in_nochesSrv,
			Id_Especialista,
			am_porcentaje_descuento,
			am_valor_descuento,
			ds_motivo_descuento,
			id_cargosdesc_descuento,
			in_NumeroOpcion,
			dt_FechaSalidaSrv,
			dt_FechaLlegadaSrv,
			cd_localizador,
			cd_voucherpax,
			am_basecomisionableprov,
			am_porcomisionprov,
			cd_NumeFac,
			dt_VenceFac,
			id_AcomodacionSrv,
			id_TipoPlanSrv,
			in_habitaciones,
			in_habitacionesSrv,
			cd_Consecutivo_VariablesAdicionales,
			cd_confirmacion ,
			ds_confirmadopor ,
			cd_paxidentificacion ,
			bl_politicaCancelacion ,
			dt_politicaCancelacion ,
			id_tipoHabitacion ,
			id_fac_facturaComision,
			id_fac_remisionComision,
			id_TarjetaAsistencia ,
			id_Regiones,
			Iden_GDS,
			id_sys_entidades,
			ds_TipoAuto,
			ds_Origen,
			ds_DirOrigen,
			ds_DirDestino,
			ds_TipoTarifa,
			am_ValorUSD,
			ds_NoVuelo,
			ds_Vehiculo,
			ds_Placa,
			ds_CategoriaVehiculo,
			ds_NombreConductor,
			ds_telefono,
			ds_IdiomaConductor,
			id_MonedaSrv,
			id_TipoServicio,
			id_Aerolinea,
			in_EdadPax,
			am_PorFacParcial,
			ds_GDS,
			dt_fechaficheroBBVA,
			bl_tiquete ,
			am_basedescuento,
			am_pordescuento,
			id_CotizacionServicios_Depende
		)
		SELECT
			cs.id_TiposConceptFac,
			cs.id_ConceptoFacturacion,
			cs.id_TiposServicio,
			cs.id_Cotizacion,
			cs.id_fac_factura,
			cs.id_fac_remision,
			cs.cd_proveedores,
			cs.ds_tiposervnm ,
			cs.cd_prov_hotel,
			cs.cd_prov_car,
			cs.cd_prov_air,
			cs.ds_destino ,
			cs.ds_servicio,
			cs.ds_descrip ,
			cs.ds_paxname,
			cs.ds_paxape,
			cs.cd_paxtype ,
			cs.in_nacionalidad,
			cs.cd_voucher,
			cs.in_cantpax ,
			cs.dt_llegada ,
			cs.dt_salida ,
			cs.cd_cencosto ,
			cs.cd_auxiliar,
			cs.cd_item ,
			cs.am_valorprov,
			cs.id_monedaprov,
			cs.ds_InfoAdicional,
			cs.id_carrental,
			cs.id_hoteles,
			cs.bl_anulado ,
			cs.cd_tiquete ,
			cs.cd_fuente_anul ,
			cs.cd_serie_anul ,
			cs.cd_consecutivo_anul,
			cs.id_usuario_anul,
			cs.id_sucursal_anul,
			cs.id_implante_anul,
			cs.am_basecomisionable,
			cs.am_porcomision,
			cs.cd_voucherPrefijo,
			cs.bl_notdomicilionacional,
			cs.Valor_Comision,
			cs.Valor_Recaudo,
			cs.dias_recaudo,
			cs.ds_paxClasificacion,
			cs.id_tipoplan,
			cs.id_acomodacion,
			cs.in_dias,
			cs.in_noches,
			cs.ds_records,
			cs.id_GrConcepto,
			cs.in_diasSrv,
			cs.in_nochesSrv,
			cs.Id_Especialista,
			cs.am_porcentaje_descuento,
			cs.am_valor_descuento,
			cs.ds_motivo_descuento,
			cs.id_cargosdesc_descuento,
			cs.in_NumeroOpcion,
			cs.dt_FechaSalidaSrv,
			cs.dt_FechaLlegadaSrv,
			cs.cd_localizador,
			cs.cd_voucherpax,
			cs.am_basecomisionableprov,
			cs.am_porcomisionprov,
			cs.cd_NumeFac,
			cs.dt_VenceFac,
			cs.id_AcomodacionSrv,
			cs.id_TipoPlanSrv,
			cs.in_habitaciones,
			cs.in_habitacionesSrv,
			cs.cd_Consecutivo_VariablesAdicionales,
			cs.cd_confirmacion ,
			cs.ds_confirmadopor ,
			cs.cd_paxidentificacion ,
			cs.bl_politicaCancelacion ,
			cs.dt_politicaCancelacion ,
			cs.id_tipoHabitacion ,
			cs.id_fac_facturaComision,
			cs.id_fac_remisionComision,
			cs.id_TarjetaAsistencia ,
			cs.id_Regiones,
			cs.Iden_GDS,
			cs.id_sys_entidades,
			cs.ds_TipoAuto,
			cs.ds_Origen,
			cs.ds_DirOrigen,
			cs.ds_DirDestino,
			cs.ds_TipoTarifa,
			cs.am_ValorUSD,
			cs.ds_NoVuelo,
			cs.ds_Vehiculo,
			cs.ds_Placa,
			cs.ds_CategoriaVehiculo,
			cs.ds_NombreConductor,
			cs.ds_telefono,
			cs.ds_IdiomaConductor,
			cs.id_MonedaSrv,
			cs.id_TipoServicio,
			cs.id_Aerolinea,
			cs.in_EdadPax,
			cs.am_PorFacParcial,
			cs.ds_GDS,
			cs.dt_fechaficheroBBVA,
			cs.bl_tiquete ,
			cs.am_basedescuento,
			cs.am_pordescuento,
			cs.id_CotizacionServicios_Depende	
		FROM @CotizacionServicios cs
		INNER JOIN @Cotizacion c ON c.cd_consecutivo=cs.cd_Cotizacion AND c.bl_existe=0

		UPDATE CCS
		SET CCS.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios CCS
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CCS.cd_Consecutivo_VariablesAdicionales

		UPDATE CSP
		SET CSP.id_Cotizacion=CS.id_Cotizacion,
			CSP.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios_PaxAdicional CSP 
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CSP.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CSP.cd_Cotizacion AND bl_existe=0

		INSERT INTO dbo.CotizacionServicios_PaxAdicional(
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete
		)
		SELECT
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete
		FROM @CotizacionServicios_PaxAdicional
		WHERE id_CotizacionServicios IS NOT NULL 

		UPDATE CC
		SET CC.id_CotizacionServicios=CS.id
		FROM @CotizacionCargos CC
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CC.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CC.cd_Cotizacion AND bl_existe=0
		
		INSERT INTO dbo.CotizacionCargos(
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		 )
		 SELECT
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		 FROM @CotizacionCargos
		 WHERE id_CotizacionServicios IS NOT NULL 

		 --SELECT c.*
		 --FROM CotizacionCargos C
		 --INNER JOIN @CotizacionCargos CC ON CC.id_cargosdesc=C.id_cargosdesc AND CC.id_CotizacionServicios=C.id_CotizacionServicios

		 UPDATE CC
		 SET CC.id_CotizacionCargos=C.id
		 FROM @CotizacionCargos CC
		 INNER JOIN dbo.CotizacionCargos C ON C.id_cargosdesc=CC.id_cargosdesc AND C.id_CotizacionServicios=CC.id_CotizacionServicios
		 INNER JOIN @Cotizacion CT ON CT.cd_consecutivo = CC.cd_Cotizacion AND bl_existe=0
		 
		 --select  * from @CotizacionCargos
		 
		 UPDATE I
		 SET I.id_CotizacionCargos=C.id_CotizacionCargos
		 FROM @CotizacionImpuestos I
		 INNER JOIN @CotizacionCargos C ON C.cd_CotizacionCargos = I.cd_CotizacionCargos AND C.cd_CotizacionServicios=I.cd_CotizacionServicios
		 INNER JOIN @Cotizacion CT ON CT.cd_consecutivo = C.cd_Cotizacion AND bl_existe=0


		 INSERT INTO dbo.CotizacionImpuestos(
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		)
		SELECT 
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		FROM @CotizacionImpuestos
		WHERE id_CotizacionCargos IS NOT NULL 
		
		INSERT INTO dbo.VariableDatosMaestro(
			IDEN_Maestro,
			IDEN_Variable,
			CodigoMaestro,
			ValorNumerico,
			ValorFecha,
			ValorVarchar
		 )
		 SELECT 
			V.IDEN_Maestro,
			V.IDEN_Variable,
			V.CodigoMaestro,
			V.ValorNumerico,
			V.ValorFecha,
			V.ValorVarchar
		 FROM @VariableDatosMaestro V
		 INNER JOIN @CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = V.CodigoMaestro
		 INNER JOIN @Cotizacion C ON C.cd_consecutivo = CS.cd_Cotizacion AND bl_existe=0
		 GROUP BY V.IDEN_Maestro,
				  V.IDEN_Variable,
				  V.CodigoMaestro,
				  V.ValorNumerico,
				  V.ValorFecha,
				  V.ValorVarchar
		
		UPDATE TF
		SET TF.id_CotizacionServicios=CS.id_CotizacionServicios
		FROM @Fac_Servicios_TiposFacturacionHoteles TF
		INNER JOIN @CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = TF.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CS.cd_Cotizacion AND C.bl_existe=0

		INSERT INTO dbo.Fac_Servicios_TiposFacturacionHoteles(
			id_Fac_Servicios,
			id_CotizacionServicios,
			Id_TiposFacturacionHoteles,
			in_cantidad,
			am_valor,
			am_contado,
			am_credito,
			Id_Cotizacion_Solicitud,
			id_cargosdesc,
			ds_cargonm
		)
		SELECT id_Fac_Servicios,
			   id_CotizacionServicios,
			   Id_TiposFacturacionHoteles,
			   in_cantidad,
			   am_valor,
			   am_contado,
			   am_credito,
			   Id_Cotizacion_Solicitud,
			   id_cargosdesc,
			   ds_cargonm
		FROM @Fac_Servicios_TiposFacturacionHoteles
		WHERE Id_TiposFacturacionHoteles IS NOT NULL


		UPDATE TP
		SET TP.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios_TipoProv TP
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = TP.cd_CotizacionServicios

		
		INSERT INTO dbo.CotizacionServicios_TipoProv(
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		)
		SELECT 
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		FROM @CotizacionServicios_TipoProv
		WHERE ISNULL(cd_proveedores,'') <> ''  

		-- Parsear formas de pago desde el XML
		INSERT INTO @CotizacionServiciosFormasPago(
			cd_Cotizacion,
			cd_CotizacionServicios,
			cd_codigo,
			ds_FPnm,
			bl_FPrepresenta,
			ds_tcnumber,
			ds_tcvoucher,
			ds_referencia,
			am_valor,
			ds_tcexp,
			am_valor_ME,
			ds_tcautorizacion
		)
		SELECT
			FP.FormasPago.value('cd_cotizacion[1]', 'VARCHAR(25)') AS cd_Cotizacion,
			FP.FormasPago.value('cd_cotizacionservicios[1]', 'VARCHAR(25)') AS cd_CotizacionServicios,
			ISNULL(FP.FormasPago.value('cd_codigo[1]', 'VARCHAR(3)'), '') AS cd_codigo,
			ISNULL(FP.FormasPago.value('ds_fpnm[1]', 'VARCHAR(50)'), '') AS ds_FPnm,
			ISNULL(FP.FormasPago.value('bl_fprepresenta[1]', 'BIT'), 0) AS bl_FPrepresenta,
			ISNULL(FP.FormasPago.value('ds_tcnumber[1]', 'CHAR(16)'), '') AS ds_tcnumber,
			ISNULL(FP.FormasPago.value('ds_tcvoucher[1]', 'VARCHAR(25)'), '') AS ds_tcvoucher,
			ISNULL(FP.FormasPago.value('ds_referencia[1]', 'VARCHAR(50)'), '') AS ds_referencia,
			ISNULL(FP.FormasPago.value('am_valor[1]', 'MONEY'), 0) AS am_valor,
			ISNULL(FP.FormasPago.value('ds_tcexp[1]', 'VARCHAR(7)'), '') AS ds_tcexp,
			ISNULL(FP.FormasPago.value('am_valor_me[1]', 'MONEY'), 0) AS am_valor_ME,
			ISNULL(FP.FormasPago.value('ds_tcautorizacion[1]', 'VARCHAR(25)'), '') AS ds_tcautorizacion
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServiciosFormasPago') AS FP(FormasPago);

		-- Resolver FKs de formas de pago
		-- ds_FPnm viene con el cd_codigo desde Postgres; se obtiene id y nombre real desde dbo.FormasPago
		UPDATE FP
		SET FP.id_CotizacionServicios = CS.id,
		    FP.Id_Cotizacion          = CS.Id_Cotizacion,
		    FP.id_FormasPago          = ISNULL(FPM.id, 1),
		    FP.ds_FPnm                = ISNULL(FPM.ds_nombre, FP.ds_FPnm)
		FROM @CotizacionServiciosFormasPago FP
		LEFT JOIN dbo.FormasPago FPM ON FPM.cd_codigo = FP.cd_codigo
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = FP.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = FP.cd_Cotizacion AND C.bl_existe=0

		-- Insertar en tabla real
		INSERT INTO dbo.CotizacionServiciosFormasPago(
			id_CotizacionServicios,
			Id_Cotizacion,
			id_FormasPago,
			ds_FPnm,
			bl_FPrepresenta,
			id_TarjetasCredito,
			cd_tccode,
			ds_tcnumber,
			ds_tcvoucher,
			cd_idbanco,
			ds_cheque,
			ds_referencia,
			am_valor,
			ds_tcexp,
			ds_plaza,
			ds_Poliza,
			ds_PolAnexo,
			am_valor_ME,
			ds_tcautorizacion,
			in_tccuotas
		)
		SELECT
			id_CotizacionServicios,
			Id_Cotizacion,
			id_FormasPago,
			ds_FPnm,
			bl_FPrepresenta,
			id_TarjetasCredito,
			cd_tccode,
			ds_tcnumber,
			ds_tcvoucher,
			cd_idbanco,
			ds_cheque,
			ds_referencia,
			am_valor,
			ds_tcexp,
			ds_plaza,
			ds_Poliza,
			ds_PolAnexo,
			am_valor_ME,
			ds_tcautorizacion,
			in_tccuotas
		FROM @CotizacionServiciosFormasPago
		WHERE id_CotizacionServicios IS NOT NULL

		--ROLLBACK TRANSACTION;
        COMMIT TRANSACTION;

		DECLARE @estado VARCHAR(8000)
		SET @estado=''
		SELECT @estado=@estado+ISNULL(cd_consecutivo,'0') + ':' + CASE WHEN id_Cotizacion IS NOT NULL THEN 'Enviado' ELSE 'Nuevo' END + '|'
		FROM @Cotizacion;
        -- Retorno mejorado: Lista resumida de lo procesado
        SELECT 
            cd_consecutivo AS Cotizacion,
            CASE 
                WHEN bl_existe = 1 THEN 'Ya existe en SQL Server'
                ELSE 'Creada exitosamente'
            END AS Estado,
            bl_existe,
            id_Cotizacion AS IdProcesado,
			@estado AS Estados
        FROM @Cotizacion;

		RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO;

-- Inyectado automáticamente: spCountriesActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spCountriesActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spCountriesActualizar"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountriesActualizar"(
    IN p_id integer,
    IN p_code text,
    IN p_name text,
    IN p_dane text,
    IN p_region text,
    IN p_prefix text,
    IN p_curencyId integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL public."spCountryActualizar"(p_id, p_code, p_name, p_dane, p_region, p_prefix, p_curencyId, p_user_id, p_mensaje_resultado);
END;
$$;;

-- Inyectado automáticamente: spCountriesCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spCountriesCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spCountriesCrear"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountriesCrear"(
    IN p_code text,
    IN p_name text,
    IN p_dane text,
    IN p_region text,
    IN p_prefix text,
    IN p_curencyId integer,
    IN p_user_id integer,
    INOUT p_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL public."spCountryCrear"(p_code, p_name, p_dane, p_region, p_prefix, p_curencyId, p_user_id, p_id, p_mensaje_resultado);
END;
$$;;

-- Inyectado automáticamente: spCountriesEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spCountriesEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spCountriesEliminar"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountriesEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL public."spCountryEliminar"(p_id, p_user_id, p_mensaje_resultado);
END;
$$;;

-- Inyectado automáticamente: spCountryActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCountryActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountryActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyId integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Countries" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Countries" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Countries" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "dane" = p_dane, "region" = p_region, "prefix" = p_prefix, "curencyId" = p_curencyId WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spCountryCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCountryCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountryCrear"(IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyId integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Countries" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Countries" ("code", "name", "dane", "region", "prefix", "curencyId") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_dane, p_region, p_prefix, p_curencyId) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $procedure$;;

-- Inyectado automáticamente: spCountryEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCountryEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCountryEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
BEGIN
    DELETE FROM public."Countries" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spCreditCardActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCreditCardActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCreditCardActualizar"(
    IN p_id integer,
    IN p_code text,
    IN p_name text,
    IN p_type text,
    IN p_inactive boolean,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_existente integer;
BEGIN
    -- Validar existencia
    SELECT id INTO v_existente FROM public."CreditCard" WHERE id = p_id;
    IF v_existente IS NULL THEN
        p_mensaje_resultado := 'ERROR: La tarjeta de crédito no existe.';
        RETURN;
    END IF;

    -- Validar código único
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        SELECT id INTO v_existente FROM public."CreditCard" WHERE "code" = p_code AND id <> p_id;
        IF v_existente IS NOT NULL THEN
            p_mensaje_resultado := 'ERROR: El código ya está registrado para otra tarjeta de crédito.';
            RETURN;
        END IF;
    END IF;

    -- Validar nombre
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        p_mensaje_resultado := 'ERROR: El nombre de la tarjeta es obligatorio.';
        RETURN;
    END IF;

    UPDATE public."CreditCard"
    SET
        "code" = COALESCE(TRIM(p_code), ''),
        "name" = TRIM(p_name),
        "type" = COALESCE(TRIM(p_type), ''),
        "inactive" = p_inactive
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
    
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;;

-- Inyectado automáticamente: spCreditCardCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCreditCardCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCreditCardCrear"(
    IN p_code text,
    IN p_name text,
    IN p_type text,
    IN p_user_id integer,
    INOUT p_card_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_existente integer;
BEGIN
    -- Validar código único
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        SELECT id INTO v_existente FROM public."CreditCard" WHERE "code" = p_code;
        IF v_existente IS NOT NULL THEN
            p_mensaje_resultado := 'ERROR: El código ya está registrado para otra tarjeta de crédito.';
            RETURN;
        END IF;
    END IF;

    -- Validar nombre
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        p_mensaje_resultado := 'ERROR: El nombre de la tarjeta es obligatorio.';
        RETURN;
    END IF;

    INSERT INTO public."CreditCard" (
        "code",
        "name",
        "type",
        "inactive"
    ) VALUES (
        COALESCE(TRIM(p_code), ''),
        TRIM(p_name),
        COALESCE(TRIM(p_type), ''),
        false
    ) RETURNING id INTO p_card_id;

    p_mensaje_resultado := 'SUCCESS';
    
    -- Log the action (handled by backend or DB trigger)
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_card_id := 0;
END;
$procedure$;;

-- Inyectado automáticamente: spCreditCardEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCreditCardEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCreditCardEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_existente integer;
BEGIN
    -- Validar existencia
    SELECT id INTO v_existente FROM public."CreditCard" WHERE id = p_id;
    IF v_existente IS NULL THEN
        p_mensaje_resultado := 'ERROR: La tarjeta de crédito no existe.';
        RETURN;
    END IF;

    -- Podríamos verificar si tiene dependencias en InvoicesProductPayment
    -- antes de eliminar. Por simplicidad, intentamos eliminar directamente
    -- y si hay constraint, saltará excepción.
    
    DELETE FROM public."CreditCard" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
    
EXCEPTION
    WHEN foreign_key_violation THEN
        p_mensaje_resultado := 'ERROR: No se puede eliminar la tarjeta porque está en uso.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;;

-- Inyectado automáticamente: spDocumentResolutionActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

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
$$;;

-- Inyectado automáticamente: spDocumentResolutionCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spDocumentResolutionCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spDocumentResolutionCrear"(
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_resolution_number text,
    IN p_initial_number integer,
    IN p_final_number integer,
    IN p_resolution_date timestamp without time zone,
    IN p_prefix text,
    IN p_expiration_date timestamp without time zone,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_resolution_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_curr integer;
BEGIN
    -- Validaciones básicas
    IF p_branch_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_resolution_number IS NULL OR TRIM(p_resolution_number) = '' THEN
        p_mensaje_resultado := 'ERROR: El número de resolución es obligatorio.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_final_number IS NULL OR p_initial_number > p_final_number THEN
        p_mensaje_resultado := 'ERROR: La numeración inicial no puede ser mayor que la numeración final.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_expiration_date IS NULL THEN
        p_mensaje_resultado := 'ERROR: La fecha de vencimiento es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    v_curr := COALESCE(p_initial_number, 1);

    -- REGLA: Si la nueva resolución es activa, desactivar cualquier otra resolución activa previa para esta misma combinación sucursal / implante
    IF COALESCE(p_is_active, true) = true THEN
        UPDATE public."DocumentResolution"
        SET "isActive" = false
        WHERE "branchId" = p_branch_id
          AND (
              ("implantId" IS NULL AND p_implant_id IS NULL)
              OR ("implantId" = p_implant_id)
          )
          AND "isActive" = true;
    END IF;

    INSERT INTO public."DocumentResolution" (
        "branchId",
        "implantId",
        "resolutionNumber",
        "initialNumber",
        "finalNumber",
        "currentNumber",
        "resolutionDate",
        "prefix",
        "expirationDate",
        "isActive",
        "createdAt"
    ) VALUES (
        p_branch_id,
        p_implant_id,
        TRIM(p_resolution_number),
        p_initial_number,
        p_final_number,
        v_curr,
        COALESCE(p_resolution_date, CURRENT_TIMESTAMP),
        TRIM(p_prefix),
        p_expiration_date,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_resolution_id := 0;
END;
$$;;

-- Inyectado automáticamente: spDocumentResolutionEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spDocumentResolutionEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spDocumentResolutionEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID de la resolución es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."DocumentResolution"
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spEquivalencesInterfacesConsultar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spEquivalencesInterfacesConsultar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spEquivalencesInterfacesConsultar"(
    IN p_id_interfaces integer DEFAULT NULL,
    IN p_id_master integer DEFAULT NULL
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    -- This procedure returns a result set. Since it's a procedure, returning result sets
    -- is not native in the same way as functions, but we can return a refcursor or
    -- just use a FUNCTION instead for querying.
    -- To align with the prompt requesting a "Consultar" SP, we can just do a select
    -- or we change it to a FUNCTION. I'll create a FUNCTION as well to make it easy to consume.
    -- But since prompt says "consultara spEquivalencesInterfacesConsultar", maybe it means a function or SP returning table.
    -- PostgreSQL 11+ procedures don't return tables directly without INOUT refcursors.
    -- I will drop this and create a FUNCTION fnEquivalencesInterfacesConsultar instead, or an SP that returns a refcursor.
    -- Let's define it as a PROCEDURE that doesn't strictly return, but we will create the FUNCTION.
END;
$BODY$;

-- Creating the function to easily fetch data
CREATE OR REPLACE FUNCTION public."fnEquivalencesInterfacesConsultar"(
    p_id_interfaces integer DEFAULT NULL,
    p_id_master integer DEFAULT NULL
)
RETURNS TABLE (
    id integer,
    id_interfaces integer,
    id_master integer,
    cd_maestro text,
    cd_codigo text,
    cd_codigoInte text,
    dt_fecha timestamp without time zone,
    interface_name text,
    master_name text
)
LANGUAGE plpgsql
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.id_interfaces,
        e.id_master,
        e.cd_maestro,
        e.cd_codigo,
        e.cd_codigoInte,
        e.dt_fecha,
        i.name AS interface_name,
        m.name AS master_name
    FROM public."EquivalencesInterfaces" e
    JOIN public."Interfaces" i ON e.id_interfaces = i.id
    JOIN public."Master" m ON e.id_master = m.id
    WHERE (p_id_interfaces IS NULL OR e.id_interfaces = p_id_interfaces)
      AND (p_id_master IS NULL OR e.id_master = p_id_master)
    ORDER BY e.dt_fecha DESC;
END;
$BODY$;;

-- Inyectado automáticamente: spEquivalencesInterfacesCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spEquivalencesInterfacesCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spEquivalencesInterfacesCrear"(
    IN p_id_interfaces integer,
    IN p_id_master integer,
    IN p_cd_maestro text,
    IN p_cd_codigo text,
    IN p_cd_codigoInte text,
    IN p_user_id integer,
    INOUT p_new_id integer DEFAULT NULL
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_log_id INT;
BEGIN
    INSERT INTO public."EquivalencesInterfaces" (
        id_interfaces, 
        id_master, 
        cd_maestro, 
        cd_codigo, 
        cd_codigoInte
    ) VALUES (
        p_id_interfaces,
        p_id_master,
        p_cd_maestro,
        p_cd_codigo,
        p_cd_codigoInte
    ) RETURNING id INTO p_new_id;

    -- Registrar en SystemLog
    CALL public."spLogRegistrar"(
        p_user_id,
        'EQUIVALENCES_INTERFACES',
        'CREATE',
        'Creación de equivalencia de interface con ID: ' || p_new_id,
        jsonb_build_object(
            'id_interfaces', p_id_interfaces,
            'id_master', p_id_master,
            'cd_maestro', p_cd_maestro,
            'cd_codigo', p_cd_codigo,
            'cd_codigoInte', p_cd_codigoInte
        ),
        v_log_id
    );
END;
$BODY$;;

-- Inyectado automáticamente: spEquivalencesInterfacesEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spEquivalencesInterfacesEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spEquivalencesInterfacesEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_success boolean DEFAULT false
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_log_id INT;
BEGIN
    DELETE FROM public."EquivalencesInterfaces"
    WHERE id = p_id;

    IF FOUND THEN
        p_success := true;
        
        -- Registrar en SystemLog
        CALL public."spLogRegistrar"(
            p_user_id,
            'EQUIVALENCES_INTERFACES',
            'DELETE',
            'Eliminación de equivalencia de interface con ID: ' || p_id,
            jsonb_build_object('id', p_id),
            v_log_id
        );
    ELSE
        p_success := false;
    END IF;
END;
$BODY$;;

-- Inyectado automáticamente: spExportInvoices (2).sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spExportInvoices'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spExportInvoices"(
    Envoices_id TEXT,
	User_id INT,
	INOUT mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Generación de XML para exportación de Facturas (Invoices). Restructurado según especificaciones del usuario.
*/
DECLARE
    v_xml TEXT;
    v_nombre_usuario TEXT;
	v_state   TEXT;
    v_msg     TEXT;
    v_context TEXT;
    v_line    TEXT;
BEGIN
    -- 1. Inicializar
    mensaje_resultado := '';

    Envoices_id := TRIM(BOTH ',' FROM TRIM(COALESCE(Envoices_id, '')));
    IF Envoices_id = '' THEN
        mensaje_resultado := 'ERROR: No se han proporcionado IDs de Facturacion válidos.';
        RETURN;
    END IF;

    -- 2. Validación de usuario
    SELECT "name" INTO v_nombre_usuario FROM public."User" WHERE id = User_id;
    IF NOT FOUND THEN
        mensaje_resultado := 'ERROR: El usuario ' || User_id || ' no existe.';
        RETURN;
    END IF;

    -- 3. Crear Tablas Temporales
    CREATE TEMP TABLE IF NOT EXISTS Facturacion (
		id INTEGER GENERATED ALWAYS AS IDENTITY,
		cd_fuente VARCHAR(2),
		cd_serie VARCHAR(2),
		cd_consecutivo VARCHAR(8),
		cd_usuario INTEGER,  
		cd_sucursal VARCHAR(3), 
		cd_implante VARCHAR(3), 
		dt_fechacont TIMESTAMP,
		dt_vence TIMESTAMP,
		cd_tercero_codigo VARCHAR(25),
		ds_tercero_nombre VARCHAR(250),
		cd_cliente_codigo VARCHAR(25), 
		ds_cliente_nombre VARCHAR(250),
		ds_cliente_dir VARCHAR(250),
		ds_cliente_ciudad VARCHAR(40),
		ds_cliente_tel VARCHAR(50),
		ds_cliente_dirdesp VARCHAR(250),
		ds_cliente_email VARCHAR(60),
		ds_cliente_contacto VARCHAR(40),
		ds_cliente_contacto_email VARCHAR(60),
		id_monedas_iata INTEGER,
		cd_vendedor CHAR(3),
		id_tiqueteador INTEGER,
		bn_anexo BYTEA,
		Tcambio DECIMAL,
		am_tcambiousd DECIMAL,
		id_tipoventa INTEGER,
		ds_num_resolucion VARCHAR(20), 
		in_num_inicial NUMERIC(18,0), 
		in_num_final NUMERIC(18,0), 
		ds_numeracion_autorizada VARCHAR(50),
		dt_fecha_resolucion TIMESTAMP,	
		CodigoArchivoFisico VARCHAR(25),
		ds_Observacion VARCHAR(8000),
		ds_Campo_libre1 varchar(500),
		ds_Campo_libre2 varchar(500),
		cd_fuente_Reemplaza CHAR(2),
		cd_serie_Reemplaza CHAR(2),
		cd_consecutivo_Reemplaza CHAR(8),		
		ds_Actividad_Economica VARCHAR(10),
		ds_Tarifa_ICA VARCHAR(15),	
		SqlStmt TEXT,
		AnticiposSqlStmt TEXT,
		TotalFactura DECIMAL,
		TotalCupoCreditoCliente DECIMAL,
		bl_BloqueoCupoCredito BIT(1),
		bl_generadaauto BIT(1),
		ds_CotizacionesId Varchar(500),
		Id_Cierre INTEGER,
		cd_TipoFact CHAR(2),
		id_fac_remisionRelacionada INTEGER,
		id_fac_facturaRelacionada INTEGER,
		ds_DescripcionFac VARCHAR(500),
		bl_nocont BIT(1),
		ProductosSqlStmt TEXT,
		cd_CF_TipoComprobante VARCHAR(15),
		id_Licitacion INTEGER,
		ValorFactura DECIMAL,
		id_Especialista INTEGER,
		id_tiqueteador_Facturador INTEGER,
		id_TipoFormaPagoProveedor INTEGER,
		id_MedioReservacion INTEGER,
		bl_refacturacion BIT(1),
		bl_comisiona BIT(1),
		cd_fuente_factura VARCHAR(2),
		cd_serie_factura VARCHAR(2),
		cd_consecutivo_factura VARCHAR(8),
		id_NotasAerolinea INTEGER,
		bl_interface INTEGER,
		id_evento INTEGER,
		bl_NoEnviarFacElectronica BIT(1),
		bl_FacturaComision BIT(1),
		bl_DescontarComisionCxP BIT(1),
		ds_num_resolucion_Adicional VARCHAR(20),
		id_fac_facturaRefacturacion VARCHAR(8000),
		bl_refacturacion_contabilizar_saldos BIT(1),
		ZML_VariablesXML TEXT,
		bl_FormatoResumidoFactElectro BIT(1),
		bl_ExigeAdjuntoFactElectro BIT(1),
		bl_omitir_Validar_IVA_facturacion BIT(1),
		ds_Respuesta TEXT,
        id_item INTEGER
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS Item (
		id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		tipo_item VARCHAR(10),
		id_factura INTEGER,
		in_tipoitem INTEGER,
		id_referencia_origen INTEGER,             
		cd_tiquete VARCHAR(50),
		ds_descrip VARCHAR(500),
		in_nacionalidad INTEGER,
		cd_cencosto VARCHAR(50),
		cd_auxiliar VARCHAR(50),
		cd_item VARCHAR(50),
		am_tarifa DECIMAL,
		am_iva DECIMAL,
		am_tua DECIMAL,
		am_comb DECIMAL,
		am_vat DECIMAL,
		am_Comision DECIMAL,
		ds_paxname VARCHAR(30),
		ds_paxape VARCHAR(30),
		ds_paxprefix CHAR(3),
		cd_tourcode VARCHAR(25),
		NumTktConj INTEGER,
		cd_TipoTiquete CHAR(3),
		id_air INTEGER,
		ds_itinerario VARCHAR(250),
		ds_itinerarioaerolinea VARCHAR(128),
		ds_clases VARCHAR(61),
		ds_Observaciones VARCHAR(8000),
		am_highfare DECIMAL,
		am_lowfare DECIMAL,
		ds_solicita VARCHAR(200),
		ds_lapsoviaje VARCHAR(50),
		cd_tktrevisado VARCHAR(14),
		cd_PasaportePax VARCHAR(25),
		cd_pax_CC VARCHAR(20),
		am_PorFacParcial DECIMAL,
		in_cantpax INTEGER,
		Id_Precompra INTEGER,
		cd_FormaPagoTAO VARCHAR(3),
		cd_TarjetaCreditoTAO VARCHAR(4),
		cd_NumeroTarjetaTAO VARCHAR(25),
		cd_VencimientoTarjetaTAO CHAR(6),
		cd_NumeroPolizaTAO VARCHAR(50),
		cd_AnexoPolizaTAO VARCHAR(50),
		ds_AutorizacionTarjetaTAO VARCHAR(25),
		in_cuotasTarjetaTAO INTEGER,
		id_FormasPago INTEGER,
		id_TarjetasCredito INTEGER,
		am_fp1 DECIMAL,
		ds_cc_code VARCHAR(2),
		ds_cc_number VARCHAR(25),
		ds_cc_vence VARCHAR(5),
		ds_cc_autorizacion VARCHAR(25),
		ds_cc_voucher VARCHAR(25),
		in_cc_cuotas INTEGER,
		am_fp2 DECIMAL,
		ds_cc_code2 VARCHAR(2),
		ds_cc_number2 VARCHAR(25),
		ds_cc_vence2 VARCHAR(5),
		ds_cc_autorizacion2 VARCHAR(25),
		ds_cc_voucher2 VARCHAR(25),
		in_cc_cuotas2 INTEGER,
		id_monedas_iata INTEGER,
		Tcambio DECIMAL,
		id_sucursal INTEGER,
		id_implante INTEGER,
		bl_ahorro BIT(1),
		cd_TipoTiqueteGDS VARCHAR(3),
		id_TiposDocumento INTEGER,
		id_entdist INTEGER,
		id_entvend INTEGER,
		cd_destino VARCHAR(3),
		dt_fechaexped TIMESTAMP,
		id_tiqueteadores INTEGER,
		id_gds INTEGER,
		iden_gds INTEGER,
		am_comisionPNR DECIMAL,
		ds_records VARCHAR(62),
		bl_NoCalcComision BIT(1),
		bl_NoCalcIvaComision BIT(1),
		am_basecomisionable DECIMAL,
		am_porcomision DECIMAL,
		id_tiposconceptfac INTEGER,
		id_conceptofacturacion INTEGER,
		id_tiposservicio INTEGER,
		cd_proveedores VARCHAR(25),
		ds_servicio VARCHAR(250),
		am_valorprov DECIMAL,
		id_monedaprov INTEGER,
		dt_llegada TIMESTAMP,
		dt_salida TIMESTAMP,
		am_pordescuento NUMERIC(8,4),
		am_basedescuento DECIMAL,
		Fecha_Salida TIMESTAMP,
		Fecha_Llegada TIMESTAMP,
		ColId VARCHAR(25),
		cd_Consecutivo_depende VARCHAR(50),
		CodigoReserva VARCHAR(50),
		cd_Consecutivo_variablesadicionales VARCHAR(50),
		am_valor_total DECIMAL,
		ds_proveedores VARCHAR(250),
		id_FormasPagoAirPlus INTEGER,
		cd_FormasPagoAirPlus VARCHAR(3),
		ds_FormasPagoAirPlus VARCHAR(100),
		id_TarjetasCreditoAirPlus INTEGER,
		cd_TarjetasCreditoAirPlus VARCHAR(4),
		ds_numerotarjetaAirPlus VARCHAR(25),
		id_reserva INTEGER,
		OrdenGrabacion INTEGER
    ) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS itinerarios(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura VARCHAR(25),
		id_item VARCHAR(25),
		id_tipoitem VARCHAR(25),
		ds_itinerario VARCHAR(250),
		ds_itinerarioaerolinea VARCHAR(128)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Pasajeros(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura VARCHAR(25),
		id_item VARCHAR(25),
		id_tipoitem VARCHAR(25),
		ds_paxape VARCHAR(30),
		ds_paxname VARCHAR(30),
		ds_paxprefix CHAR(3),
		ds_paxClasificacion CHAR(25),
		cd_voucherpax VARCHAR(25),
		cd_paxidentificacion VARCHAR(25),
		in_edad INT,
		cd_tiquete CHAR(50)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CargosImpuestos(
		id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		id_factura VARCHAR(25),
		id_item VARCHAR(25),
		id_tipoitem VARCHAR(25),
		cd_codigo VARCHAR(20),
		ds_nombre VARCHAR(100),
		cd_tipo CHAR(1),
		am_porcentaje NUMERIC(8,4),
		am_valor DECIMAL,
		am_contado DECIMAL,
		am_credito DECIMAL,
		id_carg INTEGER,
		id_imp INTEGER,
		bl_iva BIT(1),
		in_orden INTEGER
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Formaspago(
		id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		id_factura VARCHAR(25),
		id_item VARCHAR(25),
		id_tipoitem VARCHAR(25),
		id_formaspago INTEGER,
		cd_codigo VARCHAR(10),
		ds_nombre VARCHAR(50),
		id_tarjetascredito INTEGER,
		cd_tipotarjeta VARCHAR(10),
		ds_numerotarjeta VARCHAR(50),
		ds_vouchertarjeta VARCHAR(50),
		ds_expiraciontarjeta VARCHAR(10),
		ds_autorizaciontarjeta VARCHAR(50),
		in_cuotas INTEGER,
		cd_banco VARCHAR(50),
		ds_cheque VARCHAR(50),
		ds_plaza VARCHAR(50),
		ds_referencia VARCHAR(50),
		ds_Poliza VARCHAR(50),
		ds_PolizaAnexo VARCHAR(50),
		am_valor DECIMAL
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Variables(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura VARCHAR(25),
		id_item VARCHAR(25),
		id_tipoitem VARCHAR(25),
		ds_maestro VARCHAR(25), 
		ds_VariableAdicional VARCHAR(25),
		ds_valor VARCHAR(500),
		cd_codigo CHAR(25)
	) ON COMMIT DROP;

    -- 4. Poblar Tabla Facturacion
    INSERT INTO Facturacion (
		cd_fuente, cd_serie, cd_consecutivo, cd_usuario, cd_sucursal, cd_implante, 
		dt_fechacont, dt_vence, cd_tercero_codigo, ds_tercero_nombre, cd_cliente_codigo, 
		ds_cliente_nombre, ds_cliente_dir, ds_cliente_ciudad, ds_cliente_tel, ds_cliente_dirdesp, 
		ds_cliente_email, ds_cliente_contacto, ds_cliente_contacto_email, id_monedas_iata, 
		cd_vendedor, id_tiqueteador, bn_anexo, Tcambio, am_tcambiousd, id_tipoventa, 
		ds_num_resolucion, in_num_inicial, in_num_final, ds_numeracion_autorizada, 
		dt_fecha_resolucion, CodigoArchivoFisico, ds_Observacion, ds_Campo_libre1, 
		ds_Campo_libre2, cd_fuente_Reemplaza, cd_serie_Reemplaza, cd_consecutivo_Reemplaza, 
		ds_Actividad_Economica, ds_Tarifa_ICA, SqlStmt, AnticiposSqlStmt, TotalFactura, 
		TotalCupoCreditoCliente, bl_BloqueoCupoCredito, bl_generadaauto, ds_CotizacionesId, 
		Id_Cierre, cd_TipoFact, id_fac_remisionRelacionada, id_fac_facturaRelacionada, 
		ds_DescripcionFac, bl_nocont, ProductosSqlStmt, cd_CF_TipoComprobante, id_Licitacion, 
		ValorFactura, id_Especialista, id_tiqueteador_Facturador, id_TipoFormaPagoProveedor, 
		id_MedioReservacion, bl_refacturacion, bl_comisiona, cd_fuente_factura, cd_serie_factura, 
		cd_consecutivo_factura, id_NotasAerolinea, bl_interface, id_evento, bl_NoEnviarFacElectronica, 
		bl_FacturaComision, bl_DescontarComisionCxP, ds_num_resolucion_Adicional, 
		id_fac_facturaRefacturacion, bl_refacturacion_contabilizar_saldos, ZML_VariablesXML, 
		bl_FormatoResumidoFactElectro, bl_ExigeAdjuntoFactElectro, bl_omitir_Validar_IVA_facturacion, 
		ds_Respuesta, id_item
    )
    SELECT 
        '' AS cd_fuente,
        '' AS cd_serie,
        SUBSTRING('I' || LPAD(e.id::text, 7, '0'), 1, 8) AS cd_consecutivo,
        User_id AS cd_usuario,
        SUBSTRING(COALESCE(b.code, ''), 1, 3) AS cd_sucursal,
        SUBSTRING(COALESCE(i.code, ''), 1, 3) AS cd_implante,
        e.date AS dt_fechacont,
        e.date AS dt_vence,
        SUBSTRING(COALESCE(c.document, ''), 1, 25) AS cd_tercero_codigo,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.name, '')), 1, 250) AS ds_tercero_nombre,
        SUBSTRING(COALESCE(c.document, ''), 1, 25) AS cd_cliente_codigo,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.name, '')), 1, 250) AS ds_cliente_nombre,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.address, '')), 1, 250) AS ds_cliente_dir,
        '' AS ds_cliente_ciudad,
        '' AS ds_cliente_tel,
        '' AS ds_cliente_dirdesp,
        SUBSTRING(COALESCE(u.email, ''), 1, 60) AS ds_cliente_email,
        '' AS ds_cliente_contacto,
        '' AS ds_cliente_contacto_email,
        NULL AS id_monedas_iata,
        SUBSTRING(COALESCE(s.code, ''), 1, 3)::char(3) AS cd_vendedor,
        NULL AS id_tiqueteador,
        NULL::bytea AS bn_anexo,
        COALESCE(e."exchangeRate", 1.0) AS Tcambio,
        1.0 AS am_tcambiousd,
        NULL AS id_tipoventa,
        '' AS ds_num_resolucion,
        0 AS in_num_inicial,
        0 AS in_num_final,
        '' AS ds_numeracion_autorizada,
        NULL AS dt_fecha_resolucion,
        '' AS CodigoArchivoFisico,
        '' AS ds_Observacion,
        '' AS ds_Campo_libre1,
        '' AS ds_Campo_libre2,
        '' AS cd_fuente_Reemplaza,
        '' AS cd_serie_Reemplaza,
        '' AS cd_consecutivo_Reemplaza,
        '' AS ds_Actividad_Economica,
        '' AS ds_Tarifa_ICA,
        '' AS SqlStmt,
        NULL AS AnticiposSqlStmt,
        COALESCE(e."totalAmount", 0) AS TotalFactura,
        0 AS TotalCupoCreditoCliente,
        B'0' AS bl_BloqueoCupoCredito,
        B'0' AS bl_generadaauto,
        NULL AS ds_CotizacionesId,
        NULL AS Id_Cierre,
        NULL AS cd_TipoFact,
        NULL AS id_fac_remisionRelacionada,
        NULL AS id_fac_facturaRelacionada,
        NULL AS ds_DescripcionFac,
        B'0' AS bl_nocont,
        NULL AS ProductosSqlStmt,
        NULL AS cd_CF_TipoComprobante,
        NULL AS id_Licitacion,
        COALESCE(e."totalAmount", 0) AS ValorFactura,
        NULL AS id_Especialista,
        NULL AS id_tiqueteador_Facturador,
        NULL AS id_TipoFormaPagoProveedor,
        NULL AS id_MedioReservacion,
        B'0' AS bl_refacturacion,
        B'0' AS bl_comisiona,
        NULL AS cd_fuente_factura,
        NULL AS cd_serie_factura,
        NULL AS cd_consecutivo_factura,
        NULL AS id_NotasAerolinea,
        0 AS bl_interface,
        NULL AS id_evento,
        B'0' AS bl_NoEnviarFacElectronica,
        B'0' AS bl_FacturaComision,
        B'0' AS bl_DescontarComisionCxP,
        '' AS ds_num_resolucion_Adicional,
        NULL AS id_fac_facturaRefacturacion,
        B'0' AS bl_refacturacion_contabilizar_saldos,
        NULL AS ZML_VariablesXML,
        B'0' AS bl_FormatoResumidoFactElectro,
        B'0' AS bl_ExigeAdjuntoFactElectro,
        B'0' AS bl_omitir_Validar_IVA_facturacion,
        NULL AS ds_Respuesta,
        e.id AS id_item
    FROM public."Invoices" e
    JOIN public."Client" c ON e."clientId" = c.id
    JOIN public."Branch" b ON e."branchId" = b.id
    LEFT JOIN public."Implant" i ON e."implantId" = i.id
    LEFT JOIN public."Seller" s ON e."sellerId" = s.id
    LEFT JOIN public."User" u ON e."userId" = u.id
    WHERE e.id = ANY(string_to_array(Envoices_id, ',')::int[]);

    -- 5. Poblar Tabla Item
    INSERT INTO Item (
		tipo_item, id_factura, in_tipoitem, id_referencia_origen, cd_tiquete, 
		ds_descrip, in_nacionalidad, cd_cencosto, cd_auxiliar, cd_item, 
		am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision, 
		ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, 
		cd_TipoTiquete, id_air, ds_itinerario, ds_itinerarioaerolinea, 
		ds_clases, ds_Observaciones, am_highfare, am_lowfare, ds_solicita, 
		ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, 
		am_PorFacParcial, in_cantpax, Id_Precompra, cd_FormaPagoTAO, 
		cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, cd_VencimientoTarjetaTAO, 
		cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, ds_AutorizacionTarjetaTAO, 
		in_cuotasTarjetaTAO, id_FormasPago, id_TarjetasCredito, am_fp1, 
		ds_cc_code, ds_cc_number, ds_cc_vence, ds_cc_autorizacion, 
		ds_cc_voucher, in_cc_cuotas, am_fp2, ds_cc_code2, ds_cc_number2, 
		ds_cc_vence2, ds_cc_autorizacion2, ds_cc_voucher2, in_cc_cuotas2, 
		id_monedas_iata, Tcambio, id_sucursal, id_implante, bl_ahorro, 
		cd_TipoTiqueteGDS, id_TiposDocumento, id_entdist, id_entvend, 
		cd_destino, dt_fechaexped, id_tiqueteadores, id_gds, iden_gds, 
		am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision, 
		am_basecomisionable, am_porcomision, id_tiposconceptfac, 
		id_conceptofacturacion, id_tiposservicio, cd_proveedores, 
		ds_servicio, am_valorprov, id_monedaprov, dt_llegada, dt_salida, 
		am_pordescuento, am_basedescuento, Fecha_Salida, Fecha_Llegada, 
		ColId, cd_Consecutivo_depende, CodigoReserva, 
		cd_Consecutivo_variablesadicionales, am_valor_total, ds_proveedores, 
		id_FormasPagoAirPlus, cd_FormasPagoAirPlus, ds_FormasPagoAirPlus, 
		id_TarjetasCreditoAirPlus, cd_TarjetasCreditoAirPlus, 
		ds_numerotarjetaAirPlus, id_reserva, OrdenGrabacion
    )
    SELECT 
		CASE WHEN p.type='Tiquete' THEN 'Aire' 
			 WHEN p.type='ALOJAMIENTO' THEN 'Hotel' 
			 WHEN p.type='ALQUILER' THEN 'Auto'
			 WHEN p.type='TAO' THEN 'TAO'
			 ELSE 'SRV'
		END AS tipo_item,
        f.id_item AS id_factura,
		CASE WHEN p.type='Tiquete' THEN 1 
			 WHEN p.type='ALOJAMIENTO' THEN 3
			 WHEN p.type='ALQUILER' THEN 3
			 WHEN p.type='TAO' THEN 2
			 ELSE 3
		END AS in_tipoitem,
        ep.id AS id_referencia_origen,
        CASE WHEN p.type='Tiquete' THEN p.code ELSE '' END AS cd_tiquete,
        SUBSTRING(COALESCE(ep.descripcion, ''), 1, 500) AS ds_descrip,
        COALESCE(ep."inNationality", 1) AS in_nacionalidad,
        '' AS cd_cencosto,
        '' AS cd_auxiliar,
        'I' || LPAD(ep.id::text, 7, '0') AS cd_item,
        COALESCE((SELECT SUM("explicitAmount") FROM public."InvoicesProductTax" ipt WHERE ipt."invoiceProductId" = ep.id AND ipt."isMain" = true), 0) AS am_tarifa,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'IVA'), 0) AS am_iva,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'TUA'), 0) AS am_tua,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'CMB'), 0) AS am_comb,
        0 AS am_vat,
        COALESCE(ep."sellerCommission", 0) AS am_Comision,
		CASE WHEN epp.name IS NULL OR TRIM(epp.name) = '' THEN '' WHEN TRIM(epp.name) NOT LIKE '% %' THEN TRIM(epp.name) ELSE COALESCE(arr[1], '') END AS ds_paxname,
		CASE WHEN epp.name IS NULL OR TRIM(epp.name) = '' THEN '' WHEN TRIM(epp.name) NOT LIKE '% %' THEN '' ELSE COALESCE(arr[2], '') END AS ds_paxape,
		CASE WHEN TRIM(epp.name) LIKE '% %' THEN SUBSTRING(COALESCE(arr[3], ''), 1, 3)::char(3) ELSE ''::char(3) END AS ds_paxprefix,
        '' AS cd_tourcode,
        NULL AS NumTktConj,
        ''::char(3) AS cd_TipoTiquete,
        CASE WHEN p.type='Tiquete' THEN ep.id ELSE NULL END AS id_air,
        SUBSTRING(COALESCE(ep.itinerary, ''), 1, 250) AS ds_itinerario,
        SUBSTRING(COALESCE(ep.itinerary, ''), 1, 128) AS ds_itinerarioaerolinea,
        SUBSTRING(COALESCE(ep.class, ''), 1, 61) AS ds_clases,
        '' AS ds_Observaciones,
        0 AS am_highfare,
        0 AS am_lowfare,
        '' AS ds_solicita,
        '' AS ds_lapsoviaje,
        '' AS cd_tktrevisado,
        '' AS cd_PasaportePax,
        '' AS cd_pax_CC,
        0 AS am_PorFacParcial,
        COALESCE(cardinality(arr), 1) AS in_cantpax,
        NULL AS Id_Precompra,
        '' AS cd_FormaPagoTAO,
        '' AS cd_TarjetaCreditoTAO,
        '' AS cd_NumeroTarjetaTAO,
        '' AS cd_VencimientoTarjetaTAO,
        '' AS cd_NumeroPolizaTAO,
        '' AS cd_AnexoPolizaTAO,
        '' AS ds_AutorizacionTarjetaTAO,
        NULL AS in_cuotasTarjetaTAO,
        NULL AS id_FormasPago,
        NULL AS id_TarjetasCredito,
        0 AS am_fp1,
		COALESCE((SELECT cc.code FROM public."InvoicesProductPayment" ipp JOIN public."CreditCard" cc ON cc.id = ipp."creditCardId" WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_code,
		COALESCE((SELECT ipp."cardNumber" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_number,
		COALESCE((SELECT ipp."expirationDate" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_vence,
		COALESCE((SELECT ipp."authorizationCode" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_autorizacion,
		COALESCE((SELECT ipp."voucher" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_voucher,
        NULL AS in_cc_cuotas,
        0 AS am_fp2,
        '' AS ds_cc_code2,
        '' AS ds_cc_number2,
        '' AS ds_cc_vence2,
        '' AS ds_cc_autorizacion2,
        '' AS ds_cc_voucher2,
        NULL AS in_cc_cuotas2,
        NULL AS id_monedas_iata,
        COALESCE(e."exchangeRate", 1.0) AS Tcambio,
        e."branchId" AS id_sucursal,
        e."implantId" AS id_implante,
        B'0' AS bl_ahorro,
        '' AS cd_TipoTiqueteGDS,
        NULL AS id_TiposDocumento,
        NULL AS id_entdist,
        NULL AS id_entvend,
        SUBSTRING(COALESCE(ep.destination, ''), 1, 3) AS cd_destino,
        e.date AS dt_fechaexped,
        NULL AS id_tiqueteadores,
        NULL AS id_gds,
        1 AS iden_gds,
        0 AS am_comisionPNR,
        '' AS ds_records,
        B'0' AS bl_NoCalcComision,
        B'0' AS bl_NoCalcIvaComision,
        0 AS am_basecomisionable,
        0 AS am_porcomision,
        NULL AS id_tiposconceptfac,
        NULL AS id_conceptofacturacion,
        NULL AS id_tiposservicio,
        SUBSTRING(COALESCE(prov.code, prov.name, ''), 1, 25) AS cd_proveedores,
        SUBSTRING(COALESCE(pr.description, ''), 1, 250) AS ds_servicio,
        ep.price AS am_valorprov,
        NULL AS id_monedaprov,
        COALESCE(ep."checkInDate", e.date) AS dt_llegada,
        COALESCE(ep."checkOutDate", e.date) AS dt_salida,
        0 AS am_pordescuento,
        0 AS am_basedescuento,
        COALESCE(ep."checkInDate", e.date) AS Fecha_Salida,
        COALESCE(ep."checkOutDate", e.date) AS Fecha_Llegada,
        '' AS ColId,
        '' AS cd_Consecutivo_depende,
        SUBSTRING(COALESCE(ep."reservationCode", ''), 1, 50) AS CodigoReserva,
        'I' || LPAD(ep.id::text, 7, '0') AS cd_Consecutivo_variablesadicionales,
        (ep.price * ep.quantity) AS am_valor_total,
        SUBSTRING(COALESCE(prov.name, prov.code, ''), 1, 250) AS ds_proveedores,
        NULL AS id_FormasPagoAirPlus,
        '' AS cd_FormasPagoAirPlus,
        '' AS ds_FormasPagoAirPlus,
        NULL AS id_TarjetasCreditoAirPlus,
        '' AS cd_TarjetasCreditoAirPlus,
        '' AS ds_numerotarjetaAirPlus,
        NULL AS id_reserva,
        NULL AS OrdenGrabacion
    FROM public."InvoicesProduct" ep
	JOIN public."Invoices" e ON ep."invoiceId" = e.id
    JOIN public."Product" pr ON ep."productId" = pr.id
    JOIN Facturacion f ON ep."invoiceId" = f.id_item
    LEFT JOIN public."Provider" prov ON ep."providerId" = prov."id"
	LEFT JOIN public."Prestadora" pre ON pre."id" = ep."prestadoraId"
	LEFT JOIN LATERAL ( SELECT  pp.*,
		        				regexp_split_to_array(TRIM(pp.name), 's+') AS arr
		    			FROM public."InvoicesProductPasenger" pp 
						WHERE pp."invoiceProductId" = ep.id
    					ORDER BY pp.id
    					LIMIT 1) epp ON true;

    -- 6. Poblar Tabla itinerarios
    INSERT INTO itinerarios (
        id_factura, id_item, id_tipoitem, ds_itinerario, ds_itinerarioaerolinea
    )
    SELECT 
        f.cd_consecutivo AS id_factura,
        itm.cd_item AS id_item,
        itm.tipo_item AS id_tipoitem,
        ep.itinerary AS ds_itinerario,
        ep.itinerary AS ds_itinerarioaerolinea
    FROM public."InvoicesProduct" ep
    JOIN Item itm ON ep.id = itm.id_referencia_origen
    JOIN Facturacion f ON ep."invoiceId" = f.id_item
    WHERE ep.itinerary IS NOT NULL AND ep.itinerary <> '';

    -- 7. Poblar Tabla Pasajeros
    INSERT INTO Pasajeros (
        id_factura, id_item, id_tipoitem, ds_paxape, ds_paxname, ds_paxprefix,
        ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion, in_edad, cd_tiquete
    )
    SELECT 
        f.cd_consecutivo AS id_factura,
        itm.cd_item AS id_item,
        itm.tipo_item AS id_tipoitem,
	    CASE WHEN p.name IS NULL OR TRIM(p.name) = '' THEN '' WHEN TRIM(p.name) NOT LIKE '% %' THEN '' ELSE COALESCE(arr[2], '') END AS ds_paxape,
	    CASE WHEN p.name IS NULL OR TRIM(p.name) = '' THEN '' WHEN TRIM(p.name) NOT LIKE '% %' THEN TRIM(p.name) ELSE COALESCE(arr[1], '') END AS ds_paxname,
	    CASE WHEN TRIM(p.name) LIKE '% %' THEN SUBSTRING(COALESCE(arr[3], ''), 1, 3)::char(3) ELSE ''::char(3) END AS ds_paxprefix,
        '' AS ds_paxClasificacion,
        '' AS cd_voucherpax,
        p.document AS cd_paxidentificacion, 
        0 AS in_edad, 
        '' AS cd_tiquete
	FROM (
	    SELECT 
	        p.*,
	        regexp_split_to_array(TRIM(p.name), 's+') AS arr,
	        ROW_NUMBER() OVER (
	            PARTITION BY p."invoiceProductId"
	            ORDER BY p.id
	        ) AS rn
	    FROM public."InvoicesProductPasenger" p
	) p
    JOIN Item itm ON p."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_item
    WHERE p.rn > 1;

    -- 8. Poblar Tabla CargosImpuestos
    INSERT INTO CargosImpuestos (
        id_factura, id_item, id_tipoitem, cd_codigo, ds_nombre, cd_tipo,
        am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden
    )
    SELECT 
        f.cd_consecutivo AS id_factura,
        itm.cd_item AS id_item,
        itm.tipo_item AS id_tipoitem,
        COALESCE(ct.code, 'TAR') AS cd_codigo,
        COALESCE(ct.name, 'Tarifa') AS ds_nombre,
        CASE WHEN t."isMain" = true THEN 'C' ELSE 'I' END AS cd_tipo,
        COALESCE(ct.value, 0) AS am_porcentaje,
        t."explicitAmount" AS am_valor,
        t."explicitAmount" AS am_contado,
        0 AS am_credito,
        ct.id AS id_carg,
        ct.id AS id_imp,
        CASE WHEN ct.code = 'IVA' THEN B'1' ELSE B'0' END AS bl_iva,
        1 AS in_orden
    FROM public."InvoicesProductTax" t
    JOIN public."ChargeAndTax" ct ON t."chargeAndTaxId" = ct.id
    JOIN Item itm ON t."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_item;

    -- 9. Poblar Tabla Formaspago
    INSERT INTO Formaspago (
        id_factura, id_item, id_tipoitem, id_formaspago, cd_codigo, ds_nombre,
        id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta,
        ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, cd_banco,
        ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
    )
    SELECT 
        f.cd_consecutivo AS id_factura,
        itm.cd_item AS id_item,
        itm.tipo_item AS id_tipoitem,
        ipp.id AS id_formaspago,
        ipp."paymentMethod" AS cd_codigo,
        ipp."paymentMethod" AS ds_nombre,
        ipp."creditCardId" AS id_tarjetascredito,
        COALESCE(cc.code, '') AS cd_tipotarjeta,
        COALESCE(ipp."cardNumber", '') AS ds_numerotarjeta,
        COALESCE(ipp.voucher, '') AS ds_vouchertarjeta,
        COALESCE(ipp."expirationDate", '') AS ds_expiraciontarjeta,
        COALESCE(ipp."authorizationCode", '') AS ds_autorizaciontarjeta,
        NULL AS in_cuotas,
        '' AS cd_banco,
        '' AS ds_cheque,
        '' AS ds_plaza,
        COALESCE(ipp.reference, '') AS ds_referencia,
        '' AS ds_Poliza,
        '' AS ds_PolizaAnexo,
        ipp.amount AS am_valor
    FROM public."InvoicesProductPayment" ipp
    JOIN Item itm ON ipp."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_item
    LEFT JOIN public."CreditCard" cc ON ipp."creditCardId" = cc.id;

    -- 10. Poblar Tabla Variables
    INSERT INTO Variables (
        id_factura, id_item, id_tipoitem, ds_maestro, ds_VariableAdicional, ds_valor, cd_codigo
    )
    SELECT 
        f.cd_consecutivo AS id_factura,
        itm.cd_item AS id_item,
        itm.tipo_item AS id_tipoitem,
        'Item' AS ds_maestro,
        COALESCE(mv.name, '') AS ds_VariableAdicional,
        COALESCE(v.value, '') AS ds_valor,
        COALESCE(mv.code, '') AS cd_codigo
    FROM public."InvoicesProductVariable" v
    JOIN public."MasterVariable" mv ON v."masterVariableId" = mv.id
    JOIN Item itm ON v."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_item;

    -- 11. Generar XML
    SELECT xmlroot(
        xmlelement(name "Facturaciones",
            xmlagg(
                xmlelement(name "Facturacion",
                    xmlforest(
                        f.cd_fuente, f.cd_serie, f.cd_consecutivo, f.cd_usuario, f.cd_sucursal, f.cd_implante, 
						f.dt_fechacont, f.dt_vence, f.cd_tercero_codigo, f.ds_tercero_nombre, f.cd_cliente_codigo, 
						f.ds_cliente_nombre, f.ds_cliente_dir, f.ds_cliente_ciudad, f.ds_cliente_tel, f.ds_cliente_dirdesp, 
						f.ds_cliente_email, f.ds_cliente_contacto, f.ds_cliente_contacto_email, f.id_monedas_iata, 
						f.cd_vendedor, f.id_tiqueteador, f.bn_anexo, f.Tcambio, f.am_tcambiousd, f.id_tipoventa, 
						f.ds_num_resolucion, f.in_num_inicial, f.in_num_final, f.ds_numeracion_autorizada, 
						f.dt_fecha_resolucion, f.CodigoArchivoFisico, f.ds_Observacion, f.ds_Campo_libre1, 
						f.ds_Campo_libre2, f.cd_fuente_Reemplaza, f.cd_serie_Reemplaza, f.cd_consecutivo_Reemplaza, 
						f.ds_Actividad_Economica, f.ds_Tarifa_ICA, f.SqlStmt, f.AnticiposSqlStmt, f.TotalFactura, 
						f.TotalCupoCreditoCliente, f.bl_BloqueoCupoCredito, f.bl_generadaauto, f.ds_CotizacionesId, 
						f.Id_Cierre, f.cd_TipoFact, f.id_fac_remisionRelacionada, f.id_fac_facturaRelacionada, 
						f.ds_DescripcionFac, f.bl_nocont, f.ProductosSqlStmt, f.cd_CF_TipoComprobante, f.id_Licitacion, 
						f.ValorFactura, f.id_Especialista, f.id_tiqueteador_Facturador, f.id_TipoFormaPagoProveedor, 
						f.id_MedioReservacion, f.bl_refacturacion, f.bl_comisiona, f.cd_fuente_factura, f.cd_serie_factura, 
						f.cd_consecutivo_factura, f.id_NotasAerolinea, f.bl_interface, f.id_evento, f.bl_NoEnviarFacElectronica, 
						f.bl_FacturaComision, f.bl_DescontarComisionCxP, f.ds_num_resolucion_Adicional, 
						f.id_fac_facturaRefacturacion, f.bl_refacturacion_contabilizar_saldos, f.ZML_VariablesXML, 
						f.bl_FormatoResumidoFactElectro, f.bl_ExigeAdjuntoFactElectro, f.bl_omitir_Validar_IVA_facturacion, 
						f.ds_Respuesta
                    ),
                    (
                        SELECT xmlagg(
                            xmlelement(name "Item",
                                xmlforest(
									s.tipo_item, s.id_factura, s.in_tipoitem, s.id_referencia_origen, s.cd_tiquete, 
									s.ds_descrip, s.in_nacionalidad, s.cd_cencosto, s.cd_auxiliar, s.cd_item, 
									s.am_tarifa, s.am_iva, s.am_tua, s.am_comb, s.am_vat, s.am_Comision, 
									s.ds_paxname, s.ds_paxape, s.ds_paxprefix, s.cd_tourcode, s.NumTktConj, 
									s.cd_TipoTiquete, s.id_air, s.ds_itinerario, s.ds_itinerarioaerolinea, 
									s.ds_clases, s.ds_Observaciones, s.am_highfare, s.am_lowfare, s.ds_solicita, 
									s.ds_lapsoviaje, s.cd_tktrevisado, s.cd_PasaportePax, s.cd_pax_CC, 
									s.am_PorFacParcial, s.in_cantpax, s.Id_Precompra, s.cd_FormaPagoTAO, 
									s.cd_TarjetaCreditoTAO, s.cd_NumeroTarjetaTAO, s.cd_VencimientoTarjetaTAO, 
									s.cd_NumeroPolizaTAO, s.cd_AnexoPolizaTAO, s.ds_AutorizacionTarjetaTAO, 
									s.in_cuotasTarjetaTAO, s.id_FormasPago, s.id_TarjetasCredito, s.am_fp1, 
									s.ds_cc_code, s.ds_cc_number, s.ds_cc_vence, s.ds_cc_autorizacion, 
									s.ds_cc_voucher, s.in_cc_cuotas, s.am_fp2, s.ds_cc_code2, s.ds_cc_number2, 
									s.ds_cc_vence2, s.ds_cc_autorizacion2, s.ds_cc_voucher2, s.in_cc_cuotas2, 
									s.id_monedas_iata, s.Tcambio, s.id_sucursal, s.id_implante, s.bl_ahorro, 
									s.cd_TipoTiqueteGDS, s.id_TiposDocumento, s.id_entdist, s.id_entvend, 
									s.cd_destino, s.dt_fechaexped, s.id_tiqueteadores, s.id_gds, s.iden_gds, 
									s.am_comisionPNR, s.ds_records, s.bl_NoCalcComision, s.bl_NoCalcIvaComision, 
									s.am_basecomisionable, s.am_porcomision, s.id_tiposconceptfac, 
									s.id_conceptofacturacion, s.id_tiposservicio, s.cd_proveedores, 
									s.ds_servicio, s.am_valorprov, s.id_monedaprov, s.dt_llegada, s.dt_salida, 
									s.am_pordescuento, s.am_basedescuento, s.Fecha_Salida, s.Fecha_Llegada, 
									s.ColId, s.cd_Consecutivo_depende, s.CodigoReserva, 
									s.cd_Consecutivo_variablesadicionales, s.am_valor_total, s.ds_proveedores, 
									s.id_FormasPagoAirPlus, s.cd_FormasPagoAirPlus, s.ds_FormasPagoAirPlus, 
									s.id_TarjetasCreditoAirPlus, s.cd_TarjetasCreditoAirPlus, 
									s.ds_numerotarjetaAirPlus, s.id_reserva, s.OrdenGrabacion
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "itinerarios",
                                            xmlforest(
                                                iti.id_factura, iti.id_item, iti.id_tipoitem, iti.ds_itinerario, iti.ds_itinerarioaerolinea
                                            )
                                        )
                                    )
                                    FROM itinerarios iti
                                    WHERE iti.id_item = s.cd_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Pasajeros",
                                            xmlforest(
                                                p.id_factura, p.id_item, p.id_tipoitem, p.ds_paxape, p.ds_paxname, p.ds_paxprefix,
                                                p.ds_paxClasificacion, p.cd_voucherpax, p.cd_paxidentificacion, p.in_edad, p.cd_tiquete
                                            )
                                        )
                                    )
                                    FROM Pasajeros p
                                    WHERE p.id_item = s.cd_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CargosImpuestos",
                                            xmlforest(
                                                ci.id_factura, ci.id_item, ci.id_tipoitem, ci.cd_codigo, ci.ds_nombre, ci.cd_tipo,
                                                ci.am_porcentaje, ci.am_valor, ci.am_contado, ci.am_credito, ci.id_carg, ci.id_imp,
                                                ci.bl_iva, ci.in_orden
                                            )
                                        )
                                    )
                                    FROM CargosImpuestos ci
                                    WHERE ci.id_item = s.cd_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Formaspago",
                                            xmlforest(
                                                fp.id_factura, fp.id_item, fp.id_tipoitem, fp.id_formaspago, fp.cd_codigo, fp.ds_nombre,
                                                fp.id_tarjetascredito, fp.cd_tipotarjeta, fp.ds_numerotarjeta, fp.ds_vouchertarjeta,
                                                fp.ds_expiraciontarjeta, fp.ds_autorizaciontarjeta, fp.in_cuotas, fp.cd_banco,
                                                fp.ds_cheque, fp.ds_plaza, fp.ds_referencia, fp.ds_Poliza, fp.ds_PolizaAnexo, fp.am_valor
                                            )
                                        )
                                    )
                                    FROM Formaspago fp
                                    WHERE fp.id_item = s.cd_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Variables",
                                            xmlforest(
                                                v.id_factura, v.id_item, v.id_tipoitem, v.ds_maestro, v.ds_VariableAdicional, v.ds_valor, v.cd_codigo
                                            )
                                        )
                                    )
                                    FROM Variables v
                                    WHERE v.id_item = s.cd_item
                                )
                            )
                        )
                        FROM Item s
                        WHERE s.id_factura = f.id_item
                    )
                )
            )
        ),
        version '1.0', standalone yes
    )::text INTO v_xml
    FROM Facturacion f;

    mensaje_resultado := COALESCE(v_xml, '<?xml version="1.0" standalone="yes"?><Facturaciones />');

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_context = PG_EXCEPTION_CONTEXT;
		v_line := substring(v_context from 'line ([0-9]+)')::TEXT;
        mensaje_resultado := format('ERROR: %s | EN LÍNEA: %s | ESTADO: %s', v_msg, v_line, v_state);
END;
$$;;

-- Inyectado automáticamente: spFacturaActualizarEstado.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spFacturaActualizarEstado'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spFacturaActualizarEstado"(
    IN p_results JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_item RECORD;
BEGIN
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_results) AS x("invoiceId" INT, "success" INT, "message" TEXT)
    LOOP
        -- success = 1 (true) maps to EXPORTADO, success = 0 (false) maps to ERROR_EXPORTACION
        IF v_item."success" = 1 THEN
            UPDATE public."Invoices"
            SET "state" = 'EXPORTADO'
            WHERE id = v_item."invoiceId";
        ELSE
            UPDATE public."Invoices"
            SET "state" = 'ERROR_EXPORTACION'
            WHERE id = v_item."invoiceId";
        END IF;
    END LOOP;
END;
$$;;

-- Inyectado automáticamente: spFacturacionesCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'dbo' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.spFacturacionesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spFacturacionesCrear;
GO

CREATE PROCEDURE dbo.spFacturacionesCrear
(
    @xml VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    IF OBJECT_ID('dbo.ImpRet', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ImpRet (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL,
            cd_cuenta VARCHAR(20) NULL,
            am_porcentaje NUMERIC(5,2) NULL DEFAULT 0,
            in_tipo CHAR(1) NULL DEFAULT 'I',
            Id_cargo_dep INT NULL,
            bl_IVA BIT NULL DEFAULT 0
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.ImpRet WHERE id = 1)
        BEGIN
            SET IDENTITY_INSERT dbo.ImpRet ON;
            INSERT INTO dbo.ImpRet (id, cd_codigo, ds_nombre, cd_cuenta, am_porcentaje, in_tipo, bl_IVA)
            VALUES (1, '01', 'IVA 19%', '240805', 19.00, 'I', 1);
            SET IDENTITY_INSERT dbo.ImpRet OFF;
        END
    END
    ELSE IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo')
    BEGIN
        ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
    END;

    IF OBJECT_ID('dbo.CargosDesc', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CargosDesc (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL
        );
    END;

    IF OBJECT_ID('dbo.parametros', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.parametros (
            id INT IDENTITY(1,1) PRIMARY KEY,
            nombre VARCHAR(250) NULL,
            valor VARCHAR(MAX) NULL
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.parametros WHERE id = 33)
        BEGIN
            SET IDENTITY_INSERT dbo.parametros ON;
            INSERT INTO dbo.parametros (id, nombre, valor) VALUES (33, 'NumeroDecimales', '2');
            SET IDENTITY_INSERT dbo.parametros OFF;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.parametros WHERE id = 326)
        BEGIN
            SET IDENTITY_INSERT dbo.parametros ON;
            INSERT INTO dbo.parametros (id, nombre, valor) VALUES (326, 'CalcularAutoValoresItemFac', 'N');
            SET IDENTITY_INSERT dbo.parametros OFF;
        END;
    END;

    IF OBJECT_ID('dbo.Parametr', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Parametr (
            PARAMETRO VARCHAR(50) PRIMARY KEY,
            VALOPAR VARCHAR(250) NULL
        );
    END;

    BEGIN TRY
        -- BEGIN TRANSACTION; -- Comentado para permitir transacciones individuales por factura

        DECLARE @xmlData XML;

        Declare @Error Int
	
		DECLARE @cd_fuente VARCHAR(2)
		DECLARE @cd_serie VARCHAR(2)
		DECLARE @cd_consecutivo VARCHAR(8)
		DECLARE @id_facturacion INT
		DECLARE @id_item INT
		DECLARE @in_tipoitem INT
		Declare @Iden Int
		Declare @Categoria varchar(50)
		Declare @Operacion varchar(500)
		Declare @Llave1 varchar(50)
		Declare @Llave2 varchar(50)
		Declare @Llave3 varchar(50)
		Declare @Llave4 varchar(50)
		Declare @transaccion_guid uniqueidentifier
		Declare @Estado varchar(50)
		Declare @UltimoMensaje varchar(1000)
		Declare @Procesado datetime
		Declare @id_facture INT

		Declare @Fecha datetime
		Declare @FechaCont datetime
		Declare @Intentos Int
		Declare @Minute_wait INT

		Declare @MsjErrorValidar Varchar(MAX)
		Declare @Mensaje_Error Varchar(500);

		Declare @cur_cd_sucursal VARCHAR(MAX)
		Declare @cur_cd_implante VARCHAR(MAX)
		Declare @cur_id_sucursal INT
		Declare @cur_id_implante INT

		Declare @ReservaFactura VARCHAR(100)
		Declare @ds_cliid CHAR(10)
		Declare @cd_cliente CHAR(10)
		Declare @ds_cliname VARCHAR(250)
		Declare @ds_clidir VARCHAR(250)
		Declare @ds_clicity VARCHAR(50)
		Declare @ds_clitel VARCHAR(25)
		Declare @ds_ClienteEmail VARCHAR(100)
		Declare @ds_moneda CHAR(3)
		Declare @cd_vendedor CHAR(3)
		Declare @cd_tiqueteador VARCHAR(6)
		Declare @am_TasaCambio MONEY
		Declare @cd_tipoventa VARCHAR(10)
		Declare @cd_licitacion INT
		Declare @ds_descripcion VARCHAR(500)
		Declare @ds_Observaciones VARCHAR(8000)
		Declare @ds_archivo VARCHAR(250)
		Declare @id_reserva INT
		Declare @cd_reserva VARCHAR(10)
		Declare @cd_sucursal CHAR(5)
		Declare @cd_implante CHAR(5)
		Declare @id_sucursal INT
		Declare @id_implante INT
		Declare @cd_bu VARCHAR(25) 

		Declare @id_monedas_iata INT
		Declare @id_tiqueteador INT
		Declare @id_tipoventa INT
		Declare @am_tcambiousd MONEY
		Declare @ValorFactura MONEY

		Declare @ds_impas_iva VARCHAR(50)
		Declare @cd_impcta_iva VARCHAR(16)
		Declare @am_porcentaje_iva NUMERIC(5,2)

		-- Variables to fetch item fields inside the cursor of a specific invoice
		Declare @item_Tipo VARCHAR(5)
		Declare @item_id_reserva INT
		Declare @item_iden_gds INT
		Declare @item_ds_aero_code CHAR(3)
		Declare @item_ds_tkt_number CHAR(10)
		Declare @item_in_nacionalidad TINYINT
		Declare @item_am_tarifa MONEY
		Declare @item_am_iva MONEY
		Declare @item_am_tua MONEY
		Declare @item_am_comb MONEY
		Declare @item_am_vat MONEY
		Declare @item_am_Comision MONEY
		Declare @item_ds_pax_firstnm VARCHAR(30)
		Declare @item_ds_pax_lastnm VARCHAR(30)
		Declare @item_ds_pax_prefix CHAR(3)
		Declare @item_cd_tourcode VARCHAR(25)
		Declare @item_NumTktConj INT
		Declare @item_cd_TipoTiquete CHAR(3)
		Declare @item_id_air INT
		Declare @item_ds_itinerario VARCHAR(250)
		Declare @item_cd_Ahorro CHAR(3)
		Declare @item_am_highfare MONEY
		Declare @item_am_lowfare MONEY
		Declare @item_ds_solicita VARCHAR(200)
		Declare @item_ds_lapsoviaje VARCHAR(50)
		Declare @item_cd_tktrevisado VARCHAR(14)
		Declare @item_cd_PasaportePax VARCHAR(25)
		Declare @item_am_PorFacParcial MONEY
		Declare @item_in_cantpax INT
		Declare @item_Id_Precompra INT
		Declare @item_cd_FormaPagoTAO VARCHAR(3)
		Declare @item_TarjetaCreditoTAO VARCHAR(4)
		Declare @item_NumeroTarjetaTAO VARCHAR(25)
		Declare @item_am_fptao MONEY
		Declare @item_am_tao MONEY
		Declare @item_am_ivatao MONEY
		Declare @item_Id_Srv INT
		Declare @item_cd_conceptofacturacion INT
		Declare @item_cd_tiposervicio INT
		Declare @item_cd_proveedores VARCHAR(25)
		Declare @item_ds_proveedores VARCHAR(250)
		Declare @item_cd_confirmation VARCHAR(25)
		Declare @item_dt_checkin SMALLDATETIME
		Declare @item_dt_checkout SMALLDATETIME
		Declare @item_cd_city VARCHAR(25)
		Declare @item_in_noches INT
		Declare @item_Servicio VARCHAR(123)
		Declare @item_Descrip VARCHAR(78)
		Declare @item_am_TarifaContado MONEY
		Declare @item_am_IvaContado MONEY
		Declare @item_am_TarifaCredito MONEY
		Declare @item_am_IvaCredito MONEY
		Declare @item_cd_centrocosto VARCHAR(50)
		Declare @item_cd_auxiliar VARCHAR(50)
		DECLARE @item_cd_item VARCHAR(50)
		Declare @item_cd_fp_OtrosItems VARCHAR(3)
		Declare @item_id_tipoproveedor INT
		Declare @item_cd_tipoproveedor VARCHAR(10)
		Declare @item_ds_tipoproveedor VARCHAR(100)
		Declare @item_Fecha_Salida SMALLDATETIME
		Declare @item_Fecha_Llegada SMALLDATETIME
		Declare @item_PNR VARCHAR(62)
		Declare @item_ds_itinerarioaerolinea VARCHAR(128)
		Declare @item_ds_tkt_prefix CHAR(3)
		Declare @item_bl_ahorro BIT
		Declare @item_cd_VencimientoTarjetaTAO CHAR(6)
		Declare @item_cd_NumeroPolizaTAO VARCHAR(50)
		Declare @item_cd_AnexoPolizaTAO VARCHAR(50)
		Declare @item_ds_AutorizacionTarjetaTAO VARCHAR(25)
		Declare @item_in_cuotasTarjetaTAO INT
		Declare @item_id_FormasPago INT
		Declare @item_id_TarjetasCredito INT
		Declare @item_am_fp1 MONEY
		Declare @item_ds_cc_code VARCHAR(2)
		Declare @item_ds_cc_number VARCHAR(25)
		Declare @item_ds_cc_vence VARCHAR(5)
		Declare @item_ds_cc_autorizacion VARCHAR(25)
		Declare @item_ds_cc_voucher VARCHAR(25)
		Declare @item_in_cc_cuotas INT
		Declare @item_am_fp2 MONEY
		Declare @item_ds_cc_code2 VARCHAR(2)
		Declare @item_ds_cc_number2 VARCHAR(25)
		Declare @item_ds_cc_vence2 VARCHAR(5)
		Declare @item_ds_cc_autorizacion2 VARCHAR(25)
		Declare @item_ds_cc_voucher2 VARCHAR(25)
		Declare @item_in_cc_cuotas2 INT
		Declare @item_cd_pax_CC VARCHAR(20)
		Declare @item_cd_destino VARCHAR(3)
		Declare @item_ds_clases VARCHAR(61)
		Declare @item_ds_Observaciones VARCHAR(8000)
		Declare @item_ds_fecha SMALLDATETIME
		Declare @SqlStmt NVARCHAR(MAX)

		Declare @LogResults TABLE (
			invoiceId INT,
			success INT,
			message VARCHAR(MAX)
		);

		Declare @ItemIndex INT
		Declare @ContadoRatio FLOAT
		Declare @TarifaSqlStmt NVARCHAR(MAX)
		Declare @TktSqlStmt NVARCHAR(MAX)
		Declare @TktItinSqlStmt NVARCHAR(MAX)
		Declare @TaoCargSqlStmt NVARCHAR(MAX)
		Declare @TaoFpSqlStmt NVARCHAR(MAX)
		Declare @TaoSqlStmt NVARCHAR(MAX)
		Declare @SrvCargSqlStmt NVARCHAR(MAX)
		Declare @SrvProvSqlStmt NVARCHAR(MAX)
		Declare @SrvPaxSqlStmt NVARCHAR(MAX)
		Declare @SrvHtlSqlStmt NVARCHAR(MAX)
		Declare @SrvImpuestosSqlStmt NVARCHAR(MAX)
		Declare @SrvFpSqlStmt NVARCHAR(MAX)
		Declare @SrvSqlStmt NVARCHAR(MAX)

		Declare @id_formaspago_tao INT
		Declare @ds_fpnm_tao VARCHAR(50)
		Declare @id_tarjetascredito_tao INT

		Declare @ResultTable TABLE (
			Respuesta VARCHAR(1000), 
			Estado INT,
			id_ReciboCaja INT,
			id_FormaPago INT,
			ds_FormaPago VARCHAR(100),
			cd_fuente VARCHAR(10),
			cd_serie VARCHAR(10),
			cd_consecutivo VARCHAR(20),
			ds_Tipo VARCHAR(50),
			am_valor MONEY,
			Resolucionmsg VARCHAR(1000),
			NCF VARCHAR(50),
			FechaCaducidad DATETIME,
			ds_Alerta VARCHAR(1000),
			in_ConsecutivoUnicoDocumento INT,
			DocumentoCausacionCxP VARCHAR(100)
		)
		Declare @FacturaRespuesta VARCHAR(MAX)
		Declare @FacturaEstado INT

		-- Variables for #GenerarConceptosAuto cursor loop
		Declare @c_id_ConceptoFacturacion INT
		Declare @c_cd_ConceptoFacturacion VARCHAR(50)
		Declare @c_ds_ConceptoFacturacion VARCHAR(250)
		Declare @c_id_TiposConceptFac INT
		Declare @c_bl_contorlarCargImp BIT
		Declare @c_bl_CalculoAutoValoresFacturacion BIT
		Declare @c_id_TiposServicio INT
		Declare @c_cd_TiposServicio VARCHAR(50)
		Declare @c_ds_TiposServicio VARCHAR(250)
		Declare @c_cd_proveedores VARCHAR(25)
		Declare @c_ds_proveedores VARCHAR(250)
		Declare @c_cd_tiquete VARCHAR(50)
		Declare @c_ds_servicio VARCHAR(250)
		Declare @c_ds_descrip VARCHAR(500)
		Declare @c_ds_paxname VARCHAR(30)
		Declare @c_ds_paxape VARCHAR(30)
		Declare @c_cd_paxtype CHAR(3)
		Declare @c_ds_paxClasificacion CHAR(6)
		Declare @c_in_nacionalidad TINYINT
		Declare @c_dt_llegada SMALLDATETIME
		Declare @c_dt_salida SMALLDATETIME
		Declare @c_cd_cencosto VARCHAR(50)
		Declare @c_cd_auxiliar VARCHAR(50)
		Declare @c_cd_item VARCHAR(50)
		Declare @c_Valor MONEY
		Declare @c_am_Contado MONEY
		Declare @c_am_Credito MONEY
		Declare @c_ValorIva MONEY
		Declare @c_Total MONEY
		Declare @c_PorIva NUMERIC(5,2)
		Declare @c_am_ContadoIva MONEY
		Declare @c_am_CreditoIva MONEY
		Declare @c_codigoimpiva VARCHAR(3)
		Declare @c_nombreimpiva VARCHAR(50) 
		Declare @c_ColId VARCHAR(25)
		Declare @c_cd_Consecutivo_depende VARCHAR(50)
		Declare @c_CodigoReserva VARCHAR(50)
		Declare @c_am_ImpuestoComision MONEY
		Declare @c_Respuesta VARCHAR(1000)
		Declare @c_bl_RutaExentaIva BIT
		Declare @c_id_FormasPago INT
		Declare @c_id_TarjetasCredito INT
		Declare @c_am_basedescuento MONEY
		Declare @c_am_pordescuento NUMERIC(8,4)
		Declare @c_id_FormasPagoAirPlus INT
		Declare @c_cd_FormasPagoAirPlus VARCHAR(3)
		Declare @c_ds_FormasPagoAirPlus VARCHAR(100)
		Declare @c_id_TarjetasCreditoAirPlus INT
		Declare @c_cd_TarjetasCreditoAirPlus VARCHAR(4)
		Declare @c_ds_numerotarjetaAirPlus VARCHAR(25)
		Declare @c_cd_codigotc VARCHAR(2)
		Declare @c_ds_numerotc VARCHAR(25)
		Declare @c_ds_vencetc VARCHAR(5)
		Declare @c_ds_autorizaciontc VARCHAR(25)
		Declare @c_ds_vouchertc VARCHAR(25)
		Declare @c_in_cuotastc INT


		DECLARE @CalcularAutoValoresItemFac CHAR(1) = 'N';
		DECLARE @RecalcTotalValue MONEY;
		DECLARE @RecalcTotalPayment MONEY;
		DECLARE @NumDecimales INT

		CREATE TABLE #Facturacion (
			id INT IDENTITY(1,1) PRIMARY KEY,
			cd_fuente VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_serie VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_consecutivo VARCHAR(8) COLLATE DATABASE_DEFAULT,
			Tipo VARCHAR(25) COLLATE DATABASE_DEFAULT,
			Servicio VARCHAR(123) COLLATE DATABASE_DEFAULT,
			Descrip VARCHAR(78) COLLATE DATABASE_DEFAULT,
			id_factura INT,
			id_item INT,
			in_tipoitem INT,
			iden_gds INT,
			ds_fecha SMALLDATETIME,
			cd_tiqueteador VARCHAR(6) COLLATE DATABASE_DEFAULT,
			cd_vendedor CHAR(3) COLLATE DATABASE_DEFAULT,
			cd_cliente CHAR(10) COLLATE DATABASE_DEFAULT,
			am_highfare MONEY,
			am_lowfare MONEY,
			am_fare MONEY,
			ds_reasoncode CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cliname VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clidir VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clicity VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_cliid CHAR(10) COLLATE DATABASE_DEFAULT,
			ds_itinerario VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clases VARCHAR(61) COLLATE DATABASE_DEFAULT,
			in_nacionalidad TINYINT,
			id_air INT,
			ds_pax_number TINYINT,
			ds_pax_firstnm VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_pax_lastnm VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_pax_prefix CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_tkt_number CHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tkt_prefix CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_aero_code CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_moneda CHAR(3) COLLATE DATABASE_DEFAULT,
			am_tarifa MONEY,
			am_iva MONEY,
			am_tua MONEY,
			am_comb MONEY,
			am_vat MONEY,
			ds_cc_code CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cc_number VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_tao MONEY,
			am_ivatao MONEY,
			am_cap MONEY,
			am_ivacap MONEY,
			ds_cc_code2 CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cc_number2 CHAR(16) COLLATE DATABASE_DEFAULT,
			am_fp1 MONEY,
			am_fp2 MONEY,
			cd_tktrevisado VARCHAR(14) COLLATE DATABASE_DEFAULT,
			am_TarifaContado MONEY,
			am_IvaContado MONEY,
			am_OtrosContado MONEY,
			am_TarifaCredito MONEY,
			am_IvaCredito MONEY,
			am_OtrosCredito MONEY,
			am_Comision MONEY,
			cd_clitipodoc VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_clitipotercero CHAR(1) COLLATE DATABASE_DEFAULT,
			ds_clirazoncial VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_cliname2 VARCHAR(60) COLLATE DATABASE_DEFAULT,
			ds_clilastname VARCHAR(60) COLLATE DATABASE_DEFAULT,
			ds_clilastname2 VARCHAR(60) COLLATE DATABASE_DEFAULT,
			cd_clipais VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_clitel VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_TipoTransaccion VARCHAR(1) COLLATE DATABASE_DEFAULT,
			Fecha_Salida SMALLDATETIME,
			Fecha_Llegada SMALLDATETIME,
			Id_Srv INT,
			cd_conceptofacturacion INT,
			cd_tiposervicio INT,
			cd_proveedores VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_car INT,
			dt_entrega SMALLDATETIME,
			in_cars INT,
			cd_carcode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_conf_car VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_citysalida VARCHAR(25) COLLATE DATABASE_DEFAULT,
			dt_retorno SMALLDATETIME,
			cd_cartype VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_currency VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_tarifacar MONEY,
			cd_bookingsource VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_ratecode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			id_htl INT,
			dt_checkin SMALLDATETIME,
			in_guests INT,
			cd_confirmation VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_city VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_htlchain VARCHAR(25) COLLATE DATABASE_DEFAULT,
			dt_checkout SMALLDATETIME,
			in_noches INT,
			ds_htlname VARCHAR(250) COLLATE DATABASE_DEFAULT,
			in_habs INT,
			cd_bed VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_ratecode_htl VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_htlcur VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_htltarifa MONEY,
			cd_agcur VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_agtarifa MONEY,
			ds_dir1 VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_tel VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_fax VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_centrocosto VARCHAR(50) COLLATE DATABASE_DEFAULT,
			NumTktConj INT,
			Respuesta VARCHAR(1) COLLATE DATABASE_DEFAULT,
			ds_solicita VARCHAR(200) COLLATE DATABASE_DEFAULT,
			cd_pax_CC VARCHAR(20) COLLATE DATABASE_DEFAULT,
			ds_lapsoviaje VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_archivo VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_Observaciones VARCHAR(8000) COLLATE DATABASE_DEFAULT,
			ds_ClienteEmail VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_sucursal CHAR(5) COLLATE DATABASE_DEFAULT,
			cd_implante CHAR(5) COLLATE DATABASE_DEFAULT,
			bl_ClienteActualizar BIT,
			bl_NotificacionMPD BIT,
			cd_FormaPagoTAO VARCHAR(3) COLLATE DATABASE_DEFAULT,
			cd_TarjetaCreditoTAO VARCHAR(4) COLLATE DATABASE_DEFAULT,
			cd_NumeroTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_VencimientoTarjetaTAO CHAR(6) COLLATE DATABASE_DEFAULT,
			cd_NumeroPolizaTAO VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_AnexoPolizaTAO VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_PorDesFormaPagoTA NUMERIC(8,4),
			cd_Penalidad CHAR(14) COLLATE DATABASE_DEFAULT,
			ds_cc_vence CHAR(5) COLLATE DATABASE_DEFAULT,
			ds_cc_vence2 CHAR(5) COLLATE DATABASE_DEFAULT,
			ds_cc_autorizacion VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_autorizacion2 VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_voucher VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_voucher2 VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_AutorizacionTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_VoucherTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_fptao MONEY,
			in_cc_cuotas INT,
			in_cc_cuotas2 INT,
			in_cuotasTarjetaTAO INT,
			cd_TipoTarifaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_TipoTiquete CHAR(3) COLLATE DATABASE_DEFAULT,
			am_TasaCambio MONEY,
			cd_tiqueteador_facturador CHAR(3) COLLATE DATABASE_DEFAULT,
			bl_ahorro BIT,
			in_CantidadTarifaTAO INT,
			in_CantidadSegmentoTAO INT,
			cd_tourcode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_contrato VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_PasaportePax VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_itinerarioaerolinea VARCHAR(128) COLLATE DATABASE_DEFAULT,
			ds_tkt_prefixIata CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_Evento VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_iata VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_aero_codeIata CHAR(3) COLLATE DATABASE_DEFAULT,
			ReservaFactura VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_Ahorro CHAR(3) COLLATE DATABASE_DEFAULT,
			cd_Categoria VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_PorFacParcial MONEY,
			am_PorFacParcial_Utilizar MONEY,
			in_cantpax INT,
			Id_Precompra INT,
			id_sucursal INT,
			bl_cotizacion BIT,
			cd_htl VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			id_formapago_cliente INT,
			cd_formapago_cliente VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_formapago_cliente VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_fp_OtrosItems VARCHAR(3) COLLATE DATABASE_DEFAULT,
			cd_auxiliar VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_tipoventa VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_iva2 MONEY,
			cd_licitacion INT,
			ds_descripcion VARCHAR(500) COLLATE DATABASE_DEFAULT,
			id_tipoproveedor INT,
			cd_tipoproveedor VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tipoproveedor VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_Consecutivo_variablesadicionales VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_item VARCHAR(50) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #CargosImpuestos (
			id INT, id_facturacion INT, id_item INT, in_tipoitem INT,
			in_orden INT, cd_codigo VARCHAR(20) COLLATE DATABASE_DEFAULT, ds_nombre VARCHAR(100) COLLATE DATABASE_DEFAULT, cd_tipo CHAR(1) COLLATE DATABASE_DEFAULT, 
			cd_codigopadre VARCHAR(20) COLLATE DATABASE_DEFAULT, cd_tipopadre VARCHAR(20) COLLATE DATABASE_DEFAULT, am_porcentaje NUMERIC(8,4),
			am_contado MONEY, am_credito MONEY, am_valor MONEY, id_carg INT, id_imp INT, bl_iva BIT
		);

		CREATE TABLE #FormasPagos (
			id INT, id_facturacion INT, id_item INT, in_tipoitem INT,
			in_orden INT, id_formaspago INT, cd_codigo VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_nombre VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_tarjetascredito INT, cd_tipotarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_numerotarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_vouchertarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_expiraciontarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_autorizaciontarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_coutas INT, cd_banco VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_cheque VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_plaza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_referencia VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_Poliza VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_PolizaAnexo VARCHAR(50) COLLATE DATABASE_DEFAULT, am_valor MONEY
		);

		CREATE TABLE #Pasajeros (
			id_facturacion INT, id_item INT, in_tipoitem INT,
			ds_paxape VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_paxname VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_paxprefix VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_paxClasificacion VARCHAR(10) COLLATE DATABASE_DEFAULT,
			cd_voucherpax VARCHAR(50) COLLATE DATABASE_DEFAULT, cd_paxidentificacion VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_edad INT, cd_tiquete VARCHAR(50) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #Itinerarios (
			id_facturacion INT, id_item INT, in_tipoitem INT, in_orden INT,
			ds_origen VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_destino VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_clase VARCHAR(25) COLLATE DATABASE_DEFAULT, dt_llegada SMALLDATETIME, dt_salida SMALLDATETIME,
			ds_terminal VARCHAR(25) COLLATE DATABASE_DEFAULT, cd_aerolinea VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_farebasis VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_numerovuelo VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_tipovuelo VARCHAR(25) COLLATE DATABASE_DEFAULT, am_valor MONEY, am_co2 MONEY
		);

		CREATE TABLE #VariablesAdicionales (
			id_facturacion INT, id_item INT, in_tipoitem INT,
			ds_maestro VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_VariableAdicional VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_valor VARCHAR(500) COLLATE DATABASE_DEFAULT, cd_codigo VARCHAR(25) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #GenerarConceptosAuto (
			id_ConceptoFacturacion INT,
			cd_ConceptoFacturacion VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_ConceptoFacturacion VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_TiposConceptFac INT,
			bl_contorlarCargImp BIT,
			bl_CalculoAutoValoresFacturacion BIT,
			id_TiposServicio INT,
			cd_TiposServicio VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_TiposServicio VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_proveedores VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_tiquete VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_servicio VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_descrip VARCHAR(500) COLLATE DATABASE_DEFAULT,
			ds_paxname VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_paxape VARCHAR(30) COLLATE DATABASE_DEFAULT,
			cd_paxtype CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_paxClasificacion CHAR(6) COLLATE DATABASE_DEFAULT,
			in_nacionalidad TINYINT,
			dt_llegada SMALLDATETIME,
			dt_salida SMALLDATETIME,
			cd_cencosto VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_auxiliar VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_item VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Valor MONEY,
			am_Contado MONEY,
			am_Credito MONEY,
			ColId VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_Consecutivo_depende VARCHAR(50) COLLATE DATABASE_DEFAULT,
			CodigoReserva VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_ImpuestoComision MONEY,
			Respuesta VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			bl_RutaExentaIva BIT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			am_basedescuento MONEY,
			am_pordescuento NUMERIC(8,4),
			id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_TarjetasCreditoAirPlus INT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_codigotc VARCHAR(2) COLLATE DATABASE_DEFAULT,
			ds_numerotc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_vencetc VARCHAR(5) COLLATE DATABASE_DEFAULT,
			ds_autorizaciontc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_vouchertc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			in_cuotastc INT
		);

		CREATE TABLE #TmpFacturaItems (
			id INT IDENTITY(1,1) PRIMARY KEY,
			id_factura INT,
			id_item INT,
			in_tipoitem INT,
			tipo_item VARCHAR(10),                 -- 'Aire', 'TAO', 'SRV','Hotel','Auto'
			id_referencia_origen INT,              -- ID de ReservasGDS_Detalles or ReservaGDS_Servicios
			cd_fuente VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_serie VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_consecutivo VARCHAR(8) COLLATE DATABASE_DEFAULT,
			cd_tiquete VARCHAR(50),
			ds_descrip VARCHAR(500),
			in_nacionalidad INT,
			cd_cencosto VARCHAR(50),
			cd_auxiliar VARCHAR(50),
			cd_item VARCHAR(50),
			am_tarifa MONEY,
			am_iva MONEY,
			am_tua MONEY,
			am_comb MONEY,
			am_vat MONEY,
			am_Comision MONEY,
			ds_paxname VARCHAR(30),
			ds_paxape VARCHAR(30),
			ds_paxprefix CHAR(3),
			cd_tourcode VARCHAR(25),
			NumTktConj INT,
			cd_TipoTiquete CHAR(3),
			id_air INT,
			ds_itinerario VARCHAR(250),
			ds_itinerarioaerolinea VARCHAR(128),
			ds_clases VARCHAR(61),
			ds_Observaciones VARCHAR(8000),
			am_highfare MONEY,
			am_lowfare MONEY,
			ds_solicita VARCHAR(200),
			ds_lapsoviaje VARCHAR(50),
			cd_tktrevisado VARCHAR(14),
			cd_PasaportePax VARCHAR(25),
			cd_pax_CC VARCHAR(20),
			am_PorFacParcial MONEY,
			in_cantpax INT,
			Id_Precompra INT,
			cd_FormaPagoTAO VARCHAR(3),
			cd_TarjetaCreditoTAO VARCHAR(4),
			cd_NumeroTarjetaTAO VARCHAR(25),
			cd_VencimientoTarjetaTAO CHAR(6),
			cd_NumeroPolizaTAO VARCHAR(50),
			cd_AnexoPolizaTAO VARCHAR(50),
			ds_AutorizacionTarjetaTAO VARCHAR(25),
			in_cuotasTarjetaTAO INT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			am_fp1 MONEY,
			ds_cc_code VARCHAR(2),
			ds_cc_number VARCHAR(25),
			ds_cc_vence VARCHAR(5),
			ds_cc_autorizacion VARCHAR(25),
			ds_cc_voucher VARCHAR(25),
			in_cc_cuotas INT,
			am_fp2 MONEY,
			ds_cc_code2 VARCHAR(2),
			ds_cc_number2 VARCHAR(25),
			ds_cc_vence2 VARCHAR(5),
			ds_cc_autorizacion2 VARCHAR(25),
			ds_cc_voucher2 VARCHAR(25),
			in_cc_cuotas2 INT,
			id_monedas_iata INT,
			Tcambio MONEY,
			id_sucursal INT,
			id_implante INT,
			bl_ahorro BIT,
			cd_TipoTiqueteGDS VARCHAR(3),
			id_TiposDocumento INT,
			id_entdist INT,
			id_entvend INT,
			cd_destino VARCHAR(3),
			dt_fechaexped SMALLDATETIME,
			id_tiqueteadores INT,
			id_gds INT,
			iden_gds INT,
			am_comisionPNR MONEY,
			ds_records VARCHAR(62),
			bl_NoCalcComision BIT,
			bl_NoCalcIvaComision BIT,
			am_basecomisionable MONEY,
			am_porcomision MONEY,
			id_tiposconceptfac INT,
			id_conceptofacturacion INT,
			id_tiposservicio INT,
			cd_proveedores VARCHAR(25),
			ds_servicio VARCHAR(250),
			am_valorprov MONEY,
			id_monedaprov INT,
			dt_llegada SMALLDATETIME,
			dt_salida SMALLDATETIME,
			am_pordescuento NUMERIC(8,4),
			am_basedescuento MONEY,
			Fecha_Salida SMALLDATETIME,
			Fecha_Llegada SMALLDATETIME,
			ColId VARCHAR(25),
			cd_Consecutivo_depende VARCHAR(50),
			CodigoReserva VARCHAR(50),
			cd_Consecutivo_variablesadicionales VARCHAR(50),
			am_valor_total MONEY,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_tipoproveedor INT,
			cd_tipoproveedor VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tipoproveedor VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_TarjetasCreditoAirPlus INT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			id_reserva INT,
			OrdenGrabacion INT
		);

		CREATE TABLE #TmpFacturaCargos (
			id_cargo_temp INT IDENTITY(1,1) PRIMARY KEY,
			id_item INT,
			cd_codigo VARCHAR(20) COLLATE DATABASE_DEFAULT,
			ds_nombre VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_tipo CHAR(1) COLLATE DATABASE_DEFAULT,
			am_porcentaje NUMERIC(8,4),
			am_valor MONEY,
			am_contado MONEY,
			am_credito MONEY,
			id_carg INT,
			id_imp INT,
			bl_iva BIT,
			in_orden INT
		);

		CREATE TABLE #TmpFacturaFormasPago (
			id_fp_temp INT IDENTITY(1,1) PRIMARY KEY,
			id_item INT,
			id_formaspago INT,
			cd_codigo VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_nombre VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_tarjetascredito INT,
			cd_tipotarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_numerotarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_vouchertarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_expiraciontarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_autorizaciontarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_cuotas INT,
			cd_banco VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_cheque VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_plaza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_referencia VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_Poliza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_PolizaAnexo VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_valor MONEY
		);


		IF OBJECT_ID('dbo.ImpRet', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 
				@ds_impas_iva = ds_nombre, 
				@cd_impcta_iva = cd_cuenta, 
				@am_porcentaje_iva = am_porcentaje,
				@c_PorIva = am_porcentaje,
				@c_codigoimpiva = cd_codigo,
				@c_nombreimpiva = ds_nombre
			FROM dbo.ImpRet 
			WHERE id = 1;
		END
		IF @am_porcentaje_iva IS NULL SET @am_porcentaje_iva = 19.00;
		IF @c_PorIva IS NULL SET @c_PorIva = 19.00;

		IF OBJECT_ID('dbo.parametros', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 @NumDecimales = TRY_CAST(LTRIM(RTRIM(valor)) AS INT) FROM dbo.parametros WHERE id = 33;
			SELECT TOP 1 @CalcularAutoValoresItemFac = ISNULL(LTRIM(RTRIM(valor)), 'N') FROM dbo.parametros WHERE id = 326;
		END
		IF @NumDecimales IS NULL SET @NumDecimales = 2;
		IF @CalcularAutoValoresItemFac IS NULL SET @CalcularAutoValoresItemFac = 'N';

        -- Validar que el XML sea correcto
        IF @xml IS NULL OR LTRIM(RTRIM(@xml)) = ''
        BEGIN
            --THROW 50001, 'El XML es obligatorio.', 1;
            SELECT 'El XML es obligatorio.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Limpiar saltos de línea y tabuladores para evitar que se guarden en campos de texto (usuario, tercero, dirección, etc.)
        SET @xml = REPLACE(REPLACE(REPLACE(@xml, CHAR(13), ''), CHAR(10), ''), CHAR(9), '');

        SET @xmlData = TRY_CAST(@xml AS XML);

        IF @xmlData IS NULL
        BEGIN
            --THROW 50002, 'El XML no tiene un formato válido.', 1;
            SELECT 'El XML no tiene un formato válido.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Extraer datos del XML

		INSERT INTO #Facturacion(
			cd_fuente, 
			cd_serie,
			cd_consecutivo,
			Tipo,
			Servicio,
			Descrip,
			id_factura,
			id_item,
			in_tipoitem,
			iden_gds,
			ds_fecha,
			cd_tiqueteador,
			cd_vendedor,
			cd_cliente,
			am_highfare,
			am_lowfare,
			am_fare,
			ds_reasoncode,
			ds_cliname,
			ds_clidir,
			ds_clicity,
			ds_cliid,
			ds_itinerario,
			ds_clases,
			in_nacionalidad,
			id_air,
			ds_pax_number,
			ds_pax_firstnm,
			ds_pax_lastnm,
			ds_pax_prefix,
			ds_tkt_number,
			ds_tkt_prefix,
			ds_aero_code,
			ds_moneda,
			am_tarifa,
			am_iva,
			am_tua,
			am_comb,
			am_vat,
			ds_cc_code,
			ds_cc_number,
			am_tao,
			am_ivatao,
			am_cap,
			am_ivacap,
			ds_cc_code2,
			ds_cc_number2,
			am_fp1,
			am_fp2,
			cd_tktrevisado,
			am_TarifaContado,
			am_IvaContado,
			am_OtrosContado,
			am_TarifaCredito,
			am_IvaCredito,
			am_OtrosCredito,
			am_Comision,
			cd_clitipodoc,
			cd_clitipotercero,
			ds_clirazoncial,
			ds_cliname2,
			ds_clilastname,
			ds_clilastname2,
			cd_clipais,
			ds_clitel,
			cd_TipoTransaccion,
			Fecha_Salida,
			Fecha_Llegada,
			Id_Srv,
			cd_conceptofacturacion,
			cd_tiposervicio,
			cd_proveedores,
			ds_proveedores,
			id_car,
			dt_entrega,
			in_cars,
			cd_carcode,
			cd_conf_car,
			cd_citysalida,
			dt_retorno,
			cd_cartype,
			cd_currency,
			am_tarifacar,
			cd_bookingsource,
			cd_ratecode,
			id_htl,
			dt_checkin,
			in_guests,
			cd_confirmation,
			cd_city,
			cd_htlchain,
			dt_checkout,
			in_noches,
			ds_htlname,
			in_habs,
			cd_bed,
			cd_ratecode_htl,
			cd_htlcur,
			am_htltarifa,
			cd_agcur,
			am_agtarifa,
			ds_dir1,
			ds_tel,
			ds_fax,
			cd_centrocosto,
			NumTktConj,
			Respuesta,
			ds_solicita,
			cd_pax_CC,
			ds_lapsoviaje,
			ds_archivo,
			ds_Observaciones,
			ds_ClienteEmail,
			cd_sucursal,
			cd_implante, 
			bl_ClienteActualizar,
			bl_NotificacionMPD,
			cd_FormaPagoTAO,
			cd_TarjetaCreditoTAO, 
			cd_NumeroTarjetaTAO, 
			cd_VencimientoTarjetaTAO, 
			cd_NumeroPolizaTAO,
			cd_AnexoPolizaTAO,
			am_PorDesFormaPagoTA, 
			cd_Penalidad, 
			ds_cc_vence, 
			ds_cc_vence2,
			ds_cc_autorizacion ,
			ds_cc_autorizacion2 ,
			ds_cc_voucher,
			ds_cc_voucher2 ,
			ds_AutorizacionTarjetaTAO,
			ds_VoucherTarjetaTAO,
			am_fptao,
			in_cc_cuotas,
			in_cc_cuotas2,
			in_cuotasTarjetaTAO,
			cd_TipoTarifaTAO,
			cd_TipoTiquete,
			am_TasaCambio,
			cd_tiqueteador_facturador ,
			bl_ahorro	,
			in_CantidadTarifaTAO,
			in_CantidadSegmentoTAO,
			cd_tourcode ,
			ds_contrato,
			cd_PasaportePax,
			ds_itinerarioaerolinea,
			ds_tkt_prefixIata,
			ds_Evento,
			cd_iata ,
			ds_aero_codeIata,
			ReservaFactura ,
			cd_Ahorro,
			cd_Categoria ,
			Id_FormasPagoAirPlus,
			cd_FormasPagoAirPlus,
			ds_FormasPagoAirPlus,
			cd_TarjetasCreditoAirPlus,
			ds_numerotarjetaAirPlus,
			am_PorFacParcial,
			am_PorFacParcial_Utilizar,
			in_cantpax,
			Id_Precompra,
			id_sucursal,
			bl_cotizacion,
			cd_htl,
			id_FormasPago,
			id_TarjetasCredito,
			id_formapago_cliente,
			cd_formapago_cliente,
			ds_formapago_cliente,
			cd_fp_OtrosItems,
			cd_auxiliar,
			cd_tipoventa,
			am_iva2,
			cd_licitacion,
			ds_descripcion,
			id_tipoproveedor,
			cd_tipoproveedor,
			ds_tipoproveedor,
			cd_Consecutivo_variablesadicionales,
			cd_item

		)	        
		SELECT 
			cd_fuente = F.Facturacion.value('cd_fuente[1]','VARCHAR(2)'), 
			cd_serie = F.Facturacion.value('cd_serie[1]','VARCHAR(2)'),
			cd_consecutivo = F.Facturacion.value('cd_consecutivo[1]','VARCHAR(8)'),
			Tipo = NULL,
			Servicio = '',
			Descrip = '',
			id_factura = F.Facturacion.value('id_factura[1]','INT'),
			id_item = NULL,
			in_tipoitem = NULL,
			iden_gds = NULL,
			ds_fecha = ISNULL(F.Facturacion.value('dt_fechacont[1]','SMALLDATETIME'),'19000101'),
			cd_tiqueteador = ISNULL(F.Facturacion.value('cd_tiqueteador[1]','VARCHAR(25)'),''),
			cd_vendedor = ISNULL(F.Facturacion.value('cd_vendedor[1]','VARCHAR(25)'),''),
			cd_cliente = ISNULL(F.Facturacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),''),
			am_highfare = 0,
			am_lowfare = 0,
			am_fare = 0,
			ds_reasoncode = '',
			ds_cliname = ISNULL(F.Facturacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),''),
			ds_clidir = ISNULL(F.Facturacion.value('ds_cliente_dir[1]','VARCHAR(250)'),''),
			ds_clicity = ISNULL(F.Facturacion.value('ds_cliente_ciudad[1]','VARCHAR(50)'),''),
			ds_cliid = ISNULL(F.Facturacion.value('cd_cliente_codigo[1]','VARCHAR(10)'),''),
			ds_itinerario = '',
			ds_clases = '',
			in_nacionalidad = 0,
			id_air = NULL,
			ds_pax_number = 0,
			ds_pax_firstnm = '',
			ds_pax_lastnm = '',
			ds_pax_prefix = '',
			ds_tkt_number = '',
			ds_tkt_prefix = '',
			ds_aero_code = '',
			ds_moneda = ISNULL(F.Facturacion.value('cd_monedas_iata[1]','VARCHAR(25)'),'COP'),
			am_tarifa = 0,
			am_iva = 0,
			am_tua = 0,
			am_comb = 0,
			am_vat = 0,
			ds_cc_code = '',
			ds_cc_number = '',
			am_tao = 0,
			am_ivatao = 0,
			am_cap = 0,
			am_ivacap = 0,
			ds_cc_code2 = '',
			ds_cc_number2 = '',
			am_fp1 = 0,
			am_fp2 = 0,
			cd_tktrevisado = '',
			am_TarifaContado = 0,
			am_IvaContado = 0,
			am_OtrosContado = 0,
			am_TarifaCredito = 0,
			am_IvaCredito = 0,
			am_OtrosCredito = 0,
			am_Comision = 0,
			cd_clitipodoc = '',
			cd_clitipotercero = '',
			ds_clirazoncial = '',
			ds_cliname2 = '',
			ds_clilastname = '',
			ds_clilastname2 = '',
			cd_clipais = '',
			ds_clitel = ISNULL(F.Facturacion.value('ds_cliente_tel[1]','VARCHAR(61)'),''),
			cd_TipoTransaccion = '',
			Fecha_Salida = GETDATE(),
			Fecha_Llegada = GETDATE(),
			Id_Srv = NULL,
			cd_conceptofacturacion = '',
			cd_tiposervicio = '',
			cd_proveedores = '',
			ds_proveedores = '',
			id_car = NULL,
			dt_entrega = GETDATE(),
			in_cars = 0,
			cd_carcode = '',
			cd_conf_car = '',
			cd_citysalida=ISNULL(F.Facturacion.value('cd_citysalida[1]','VARCHAR(61)'),''),
			dt_retorno=F.Facturacion.value('dt_retorno[1]','SMALLDATETIME'),
			cd_cartype=ISNULL(F.Facturacion.value('cd_cartype[1]','VARCHAR(61)'),''),
			cd_currency=ISNULL(F.Facturacion.value('cd_currency[1]','VARCHAR(3)'),'COP'),
			am_tarifacar=ISNULL(F.Facturacion.value('am_tarifacar[1]','MONEY'),0),
			cd_bookingsource=ISNULL(F.Facturacion.value('cd_bookingsource[1]','VARCHAR(61)'),''),
			cd_ratecode=ISNULL(F.Facturacion.value('cd_ratecode[1]','VARCHAR(61)'),''),
			id_htl=NULL,
			dt_checkin=F.Facturacion.value('dt_checkin[1]','SMALLDATETIME'),
			in_guests=ISNULL(F.Facturacion.value('in_guests[1]','INT'),0),
			cd_confirmation=ISNULL(F.Facturacion.value('cd_confirmation[1]','VARCHAR(61)'),''),
			cd_city=ISNULL(F.Facturacion.value('cd_city[1]','VARCHAR(61)'),''),
			cd_htlchain=ISNULL(F.Facturacion.value('cd_htlchain[1]','VARCHAR(61)'),''),
			dt_checkout=F.Facturacion.value('dt_checkout[1]','SMALLDATETIME'),
			in_noches=ISNULL(F.Facturacion.value('in_noches[1]','INT'),0),
			ds_htlname=ISNULL(F.Facturacion.value('ds_htlname[1]','VARCHAR(61)'),''),
			in_habs=ISNULL(F.Facturacion.value('in_habs[1]','INT'),0),
			cd_bed=ISNULL(F.Facturacion.value('cd_bed[1]','VARCHAR(61)'),''),
			cd_ratecode_htl=ISNULL(F.Facturacion.value('cd_ratecode_htl[1]','VARCHAR(61)'),''),
			cd_htlcur=ISNULL(F.Facturacion.value('cd_htlcur[1]','VARCHAR(61)'),''),
			am_htltarifa=ISNULL(F.Facturacion.value('am_htltarifa[1]','MONEY'),0),
			cd_agcur=ISNULL(F.Facturacion.value('cd_agcur[1]','VARCHAR(61)'),''),
			am_agtarifa=ISNULL(F.Facturacion.value('am_agtarifa[1]','MONEY'),0),
			ds_dir1=ISNULL(F.Facturacion.value('ds_dir1[1]','VARCHAR(61)'),''),
			ds_tel=ISNULL(F.Facturacion.value('ds_tel[1]','VARCHAR(61)'),''),
			ds_fax=ISNULL(F.Facturacion.value('ds_fax[1]','VARCHAR(61)'),''),
			cd_centrocosto=ISNULL(F.Facturacion.value('cd_centrocosto[1]','VARCHAR(61)'),''),
			NumTktConj=ISNULL(F.Facturacion.value('NumTktConj[1]','VARCHAR(61)'),''),
			Respuesta=NULL,
			ds_solicita = '',
			cd_pax_CC = '',
			ds_lapsoviaje = '',
			ds_archivo = ISNULL(F.Facturacion.value('ds_archivo[1]','VARCHAR(61)'),''),
			ds_Observaciones = ISNULL(F.Facturacion.value('ds_Observacion[1]','VARCHAR(8000)'),''),
			ds_ClienteEmail = ISNULL(F.Facturacion.value('ds_cliente_email[1]','VARCHAR(61)'),''),
			cd_sucursal = ISNULL(F.Facturacion.value('cd_sucursal[1]','VARCHAR(25)'),'OFP'),
			cd_implante = ISNULL(F.Facturacion.value('cd_implante[1]','VARCHAR(25)'),''), 
			bl_ClienteActualizar = 0,
			bl_NotificacionMPD = 0,
			cd_FormaPagoTAO = '',
			cd_TarjetaCreditoTAO = '', 
			cd_NumeroTarjetaTAO = '', 
			cd_VencimientoTarjetaTAO = '__/__', 
			cd_NumeroPolizaTAO = '',
			cd_AnexoPolizaTAO = '',
			am_PorDesFormaPagoTA = 0, 
			cd_Penalidad = '', 
			ds_cc_vence = '', 
			ds_cc_vence2 = '',
			ds_cc_autorizacion = '',
			ds_cc_autorizacion2 = '',
			ds_cc_voucher = '',
			ds_cc_voucher2 = '',
			ds_AutorizacionTarjetaTAO = '',
			ds_VoucherTarjetaTAO = '',
			am_fptao = 0,
			in_cc_cuotas = 0,
			in_cc_cuotas2 = 0,
			in_cuotasTarjetaTAO = 0,
			cd_TipoTarifaTAO = '',
			cd_TipoTiquete = '',
			am_TasaCambio = ISNULL(F.Facturacion.value('Tcambio[1]','MONEY'),1),
			cd_tiqueteador_facturador = '',
			bl_ahorro = 0,
			in_CantidadTarifaTAO = 0,
			in_CantidadSegmentoTAO = 0,
			cd_tourcode = '',
			ds_contrato = '',
			cd_PasaportePax = '',
			ds_itinerarioaerolinea = '',
			ds_tkt_prefixIata = '',
			ds_Evento = ISNULL(F.Facturacion.value('ds_Evento[1]','VARCHAR(61)'),''),
			cd_iata = ISNULL(F.Facturacion.value('cd_iata[1]','VARCHAR(61)'),''),
			ds_aero_codeIata = '',
			ReservaFactura = '',
			cd_Ahorro = '',
			cd_Categoria = '',
			Id_FormasPagoAirPlus = NULL,
			cd_FormasPagoAirPlus = '',
			ds_FormasPagoAirPlus = '',
			cd_TarjetasCreditoAirPlus = '',
			ds_numerotarjetaAirPlus = '',
			am_PorFacParcial = 100,
			am_PorFacParcial_Utilizar = 0,
			in_cantpax = 0,
			Id_Precompra = NULL,
			id_sucursal = 1,
			bl_cotizacion = 0,
			cd_htl = '',
			id_FormasPago = NULL,
			id_TarjetasCredito = NULL,
			id_formapago_cliente = NULL,
			cd_formapago_cliente = '',
			ds_formapago_cliente = '',
			cd_fp_OtrosItems = '',
			cd_auxiliar = '',
			cd_tipoventa = ISNULL(F.Facturacion.value('id_tipoventa[1]','VARCHAR(61)'),''),
			am_iva2 = 0,
			cd_licitacion = ISNULL(F.Facturacion.value('id_Licitacion[1]','VARCHAR(61)'),''),
			ds_descripcion = '',
			id_tipoproveedor = NULL,
			cd_tipoproveedor = '',
			ds_tipoproveedor = '',
			cd_Consecutivo_variablesadicionales = '',
			cd_item = ''
        FROM @xmlData.nodes('/Facturaciones/Facturacion') AS F(Facturacion);


		INSERT INTO #TmpFacturaItems (
			id_factura, id_item, in_tipoitem, tipo_item, id_referencia_origen, cd_fuente, cd_serie, cd_consecutivo, cd_tiquete, ds_descrip, in_nacionalidad, 
			cd_cencosto, cd_auxiliar, cd_item, am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision, 
			ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, cd_TipoTiquete, id_air, 
			ds_itinerario, ds_itinerarioaerolinea, ds_clases, ds_Observaciones, am_highfare, am_lowfare, 
			ds_solicita, ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, am_PorFacParcial, 
			in_cantpax, Id_Precompra, cd_FormaPagoTAO, cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, 
			cd_VencimientoTarjetaTAO, cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, ds_AutorizacionTarjetaTAO, 
			in_cuotasTarjetaTAO, id_FormasPago, id_TarjetasCredito, am_fp1, ds_cc_code, ds_cc_number, 
			ds_cc_vence, ds_cc_autorizacion, ds_cc_voucher, in_cc_cuotas, am_fp2, ds_cc_code2, 
			ds_cc_number2, ds_cc_vence2, ds_cc_autorizacion2, ds_cc_voucher2, in_cc_cuotas2, 
			id_monedas_iata, Tcambio, id_sucursal, id_implante, bl_ahorro, cd_TipoTiqueteGDS, 
			id_TiposDocumento, id_entdist, id_entvend, cd_destino, dt_fechaexped, id_tiqueteadores, 
			id_gds, iden_gds, am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision, 
			am_basecomisionable, am_porcomision, id_tiposconceptfac, id_conceptofacturacion, 
			id_tiposservicio, cd_proveedores, ds_servicio, am_valorprov, id_monedaprov, dt_llegada, 
			dt_salida, am_pordescuento, Fecha_Salida, Fecha_Llegada, am_basedescuento, cd_Consecutivo_depende, 
			cd_Consecutivo_variablesadicionales, am_valor_total, ds_proveedores, id_tipoproveedor, cd_tipoproveedor, ds_tipoproveedor,
			id_FormasPagoAirPlus, cd_FormasPagoAirPlus, ds_FormasPagoAirPlus, id_TarjetasCreditoAirPlus,
			cd_TarjetasCreditoAirPlus, ds_numerotarjetaAirPlus, id_reserva,	OrdenGrabacion
		)
		SELECT 
			id_factura = F.Item.value('id_factura[1]','INT'),
			id_item = F.Item.value('id_item[1]','INT'),
			in_tipoitem = F.Item.value('in_tipoitem[1]','INT'),
			tipo_item = F.Item.value('tipo_item[1]','VARCHAR(10)'),
			id_referencia_origen = F.Item.value('id_referencia_origen[1]','INT'),
			cd_fuente=FF.cd_fuente,
			cd_serie=FF.cd_serie,
			cd_consecutivo=FF.cd_consecutivo,
			cd_tiquete = ISNULL(F.Item.value('cd_tiquete[1]','VARCHAR(50)'),''),
			ds_descrip = ISNULL(F.Item.value('ds_descrip[1]','VARCHAR(500)'),''),
			in_nacionalidad = ISNULL(F.Item.value('in_nacionalidad[1]','INT'),0),
			cd_cencosto = ISNULL(F.Item.value('cd_cencosto[1]','VARCHAR(50)'),''),
			cd_auxiliar = ISNULL(F.Item.value('cd_auxiliar[1]','VARCHAR(50)'),''),
			cd_item = ISNULL(F.Item.value('cd_item[1]','VARCHAR(50)'),''),
			am_tarifa = ISNULL(F.Item.value('am_tarifa[1]','MONEY'),0),
			am_iva = ISNULL(F.Item.value('am_iva[1]','MONEY'),0),
			am_tua = ISNULL(F.Item.value('am_tua[1]','MONEY'),0),
			am_comb = ISNULL(F.Item.value('am_comb[1]','MONEY'),0),
			am_vat = ISNULL(F.Item.value('am_vat[1]','MONEY'),0),
			am_Comision = ISNULL(F.Item.value('am_comision[1]','MONEY'),0),
			ds_paxname = ISNULL(F.Item.value('ds_paxname[1]','VARCHAR(30)'),''),
			ds_paxape = ISNULL(F.Item.value('ds_paxape[1]','VARCHAR(30)'),''),
			ds_paxprefix = ISNULL(F.Item.value('ds_paxprefix[1]','VARCHAR(3)'),''),
			cd_tourcode = ISNULL(F.Item.value('cd_tourcode[1]','VARCHAR(25)'),''),
			NumTktConj = F.Item.value('NumTktConj[1]','INT'),
			cd_TipoTiquete = F.Item.value('cd_tipotiquete[1]','VARCHAR(3)'),
			id_air = F.Item.value('id_air[1]','INT'),
			ds_itinerario = ISNULL(F.Item.value('ds_itinerario[1]','VARCHAR(250)'),''),
			ds_itinerarioaerolinea = ISNULL(F.Item.value('ds_itinerarioaerolinea[1]','VARCHAR(128)'),''),
			ds_clases = ISNULL(F.Item.value('ds_clases[1]','VARCHAR(61)'),''),
			ds_Observaciones = ISNULL(F.Item.value('ds_observaciones[1]','VARCHAR(8000)'),''),
			am_highfare = ISNULL(F.Item.value('am_highfare[1]','MONEY'),0),
			am_lowfare = ISNULL(F.Item.value('am_lowfare[1]','MONEY'),0),
			ds_solicita = ISNULL(F.Item.value('ds_solicita[1]','VARCHAR(200)'),''),
			ds_lapsoviaje = ISNULL(F.Item.value('ds_lapsoviaje[1]','VARCHAR(50)'),''),
			cd_tktrevisado = ISNULL(F.Item.value('cd_tktrevisado[1]','VARCHAR(14)'),''),
			cd_PasaportePax = ISNULL(F.Item.value('cd_pasaportepax[1]','VARCHAR(25)'),''),
			cd_pax_CC = ISNULL(F.Item.value('cd_pax_cc[1]','VARCHAR(20)'),''),
			am_PorFacParcial = ISNULL(F.Item.value('am_porfacparcial[1]','MONEY'),100),
			in_cantpax = ISNULL(F.Item.value('in_cantpax[1]','INT'),0),
			Id_Precompra = F.Item.value('id_precompra[1]','INT'),
			cd_FormaPagoTAO = ISNULL(F.Item.value('cd_formapagotao[1]','VARCHAR(3)'),''),
			cd_TarjetaCreditoTAO = ISNULL(F.Item.value('cd_tarjetacreditotao[1]','VARCHAR(4)'),''),
			cd_NumeroTarjetaTAO = ISNULL(F.Item.value('cd_numerotarjetatao[1]','VARCHAR(25)'),''),
			cd_VencimientoTarjetaTAO = ISNULL(F.Item.value('cd_vencimientotarjetatao[1]','VARCHAR(6)'),''),
			cd_NumeroPolizaTAO = ISNULL(F.Item.value('cd_numeropolizatao[1]','VARCHAR(50)'),''),
			cd_AnexoPolizaTAO = ISNULL(F.Item.value('cd_anexopolizatao[1]','VARCHAR(50)'),''),
			ds_AutorizacionTarjetaTAO = ISNULL(F.Item.value('ds_autorizaciontarjetatao[1]','VARCHAR(25)'),''),
			in_cuotasTarjetaTAO = ISNULL(F.Item.value('in_cuotasTarjetatao[1]','INT'),0),
			id_FormasPago = FP.id,
			id_TarjetasCredito = TC.id,
			am_fp1 = ISNULL(F.Item.value('am_fp1[1]','MONEY'),0),
			ds_cc_code = ISNULL(F.Item.value('ds_cc_code[1]','VARCHAR(2)'),''),
			ds_cc_number = ISNULL(F.Item.value('ds_cc_number[1]','VARCHAR(25)'),''),
			ds_cc_vence = ISNULL(F.Item.value('ds_cc_vence[1]','VARCHAR(5)'),''),
			ds_cc_autorizacion = ISNULL(F.Item.value('ds_cc_autorizacion[1]','VARCHAR(25)'),''),
			ds_cc_voucher = ISNULL(F.Item.value('ds_cc_voucher[1]','VARCHAR(25)'),''),
			in_cc_cuotas = ISNULL(F.Item.value('in_cc_cuotas[1]','INT'),0),
			am_fp2 = ISNULL(F.Item.value('am_fp2[1]','MONEY'),0),
			ds_cc_code2 = ISNULL(F.Item.value('ds_cc_code2[1]','VARCHAR(2)'),''),
			ds_cc_number2 = ISNULL(F.Item.value('ds_cc_number2[1]','VARCHAR(25)'),''),
			ds_cc_vence2 = ISNULL(F.Item.value('ds_cc_vence2[1]','VARCHAR(5)'),''),
			ds_cc_autorizacion2 = ISNULL(F.Item.value('ds_cc_autorizacion2[1]','VARCHAR(25)'),''),
			ds_cc_voucher2 = ISNULL(F.Item.value('ds_cc_voucher2[1]','VARCHAR(25)'),''),
			in_cc_cuotas2 = ISNULL(F.Item.value('in_cc_cuotas2[1]','INT'),0),
			id_monedas_iata = M.id,
			Tcambio = ISNULL(F.Item.value('tcambio[1]','MONEY'),1),
			id_sucursal = S.id,
			id_implante = I.id,
			bl_ahorro = ISNULL(F.Item.value('bl_ahorro[1]','BIT'),0),
			cd_TipoTiqueteGDS = ISNULL(F.Item.value('cd_tipotiquetegds[1]','VARCHAR(3)'),''),
			id_TiposDocumento = TD.id,
			id_entdist = ED.id,
			id_entvend = EV.id,
			cd_destino = ISNULL(F.Item.value('cd_destino[1]','VARCHAR(3)'),''),
			dt_fechaexped = F.Item.value('dt_fechaexped[1]','SMALLDATETIME'),
			id_tiqueteadores = TQ.id,
			id_gds = F.Item.value('id_gds[1]','INT'),
			iden_gds = F.Item.value('iden_gds[1]','INT'),
			am_comisionPNR = ISNULL(F.Item.value('am_comisionpnr[1]','MONEY'),0),
			ds_records = ISNULL(F.Item.value('ds_records[1]','VARCHAR(62)'),''),
			bl_NoCalcComision = ISNULL(F.Item.value('bl_nocalccomision[1]','BIT'),0),
			bl_NoCalcIvaComision = ISNULL(F.Item.value('bl_nocalcivacomision[1]','BIT'),0),
			am_basecomisionable = ISNULL(F.Item.value('am_basecomisionable[1]','MONEY'),0),
			am_porcomision = ISNULL(F.Item.value('am_porcomision[1]','MONEY'),0),
			id_tiposconceptfac = ISNULL(CF.id_TiposConceptoFacturacion, ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion ORDER BY id), 2)),
			id_conceptofacturacion = ISNULL(CF.id, ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE cd_codigo = 'SOP'), ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion ORDER BY id), 1))),
			id_tiposservicio = ISNULL(CASE WHEN TS.id IS NOT NULL THEN TS.id ELSE TSA.id_TipoServicio END, ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios WHERE cd_codigo IN ('htn','SOP')), ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios ORDER BY id), 1))),
			cd_proveedores = ISNULL(F.Item.value('cd_proveedores[1]','VARCHAR(25)'),''),
			ds_servicio = ISNULL(F.Item.value('ds_servicio[1]','VARCHAR(250)'),''),
			am_valorprov = ISNULL(F.Item.value('am_valorprov[1]','MONEY'),0),
			id_monedaprov = F.Item.value('id_monedaprov[1]','INT'),
			dt_llegada = F.Item.value('dt_llegada[1]','SMALLDATETIME'),
			dt_salida = F.Item.value('dt_salida[1]','SMALLDATETIME'),
			am_pordescuento = ISNULL(F.Item.value('am_pordescuento[1]','NUMERIC(8,4)'),0),
			Fecha_Salida = F.Item.value('fecha_salida[1]','SMALLDATETIME'),
			Fecha_Llegada = F.Item.value('fecha_llegada[1]','SMALLDATETIME'),
			am_basedescuento = ISNULL(F.Item.value('am_basedescuento[1]','MONEY'),0),
			cd_Consecutivo_depende = ISNULL(F.Item.value('cd_consecutivo_depende[1]','VARCHAR(50)'),''),
			cd_Consecutivo_variablesadicionales = ISNULL(F.Item.value('cd_consecutivo_variablesadicionales[1]','VARCHAR(50)'),''),
			am_valor_total = ISNULL(F.Item.value('am_valor_total[1]','MONEY'),0), 
			ds_proveedores = ISNULL(F.Item.value('ds_proveedores[1]','VARCHAR(25)'),''),
			id_tipoproveedor = ISNULL(TP.id,1),
			cd_tipoproveedor = ISNULL(F.Item.value('cd_tipoproveedor[1]','VARCHAR(25)'),'HTL'),
			ds_tipoproveedor = ISNULL(F.Item.value('ds_tipoproveedor[1]','VARCHAR(50)'),'Hotel'),
			id_FormasPagoAirPlus = F.Item.value('id_formaspagoairplus[1]','INT'),
			cd_FormasPagoAirPlus = ISNULL(F.Item.value('cd_formaspagoairplus[1]','VARCHAR(25)'),''),
			ds_FormasPagoAirPlus = ISNULL(F.Item.value('ds_formaspagoairplus[1]','VARCHAR(50)'),''),
			id_TarjetasCreditoAirPlus = F.Item.value('id_tarjetascreditoairplus[1]','INT'),
			cd_TarjetasCreditoAirPlus = ISNULL(F.Item.value('cd_tarjetascreditoairplus[1]','VARCHAR(25)'),''),
			ds_numerotarjetaAirPlus = ISNULL(F.Item.value('ds_numerotarjetaairplus[1]','VARCHAR(50)'),''),
			id_reserva = F.Item.value('id_reserva[1]','INT'),	
			OrdenGrabacion = ROW_NUMBER() OVER (ORDER BY id_item ASC)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item') F(Item)
		LEFT JOIN #Facturacion FF ON FF.id_factura = F.Item.value('id_factura[1]','INT')
		LEFT JOIN dbo.Monedas_IATA M ON M.cd_codigo = F.Item.value('cd_monedas_iata[1]','VARCHAR(25)')
		LEFT JOIN dbo.Sucursales S ON S.cd_codigo = F.Item.value('cd_sucursal[1]','VARCHAR(25)')
		LEFT JOIN dbo.Implantes I ON I.cd_codigo = F.Item.value('cd_implante[1]','VARCHAR(25)')
		LEFT JOIN dbo.FormasPago FP ON FP.cd_codigo = F.Item.value('cd_formasPago[1]','VARCHAR(25)')
		LEFT JOIN dbo.TarjetasCredito TC ON TC.cd_codigo = F.Item.value('cd_tarjetascredito[1]','VARCHAR(25)')
		LEFT JOIN dbo.TiposDocumento TD ON TD.cd_codigo = F.Item.value('cd_tiposdocumento[1]','VARCHAR(25)')
		LEFT JOIN dbo.Entidades ED ON ED.cd_codigo = F.Item.value('cd_entdist[1]','VARCHAR(25)')
		LEFT JOIN dbo.Entidades	EV ON EV.cd_codigo = F.Item.value('cd_entvend[1]','VARCHAR(25)')
		LEFT JOIN dbo.Tiqueteadores	TQ ON TQ.cd_codigo = F.Item.value('cd_tiqueteadores[1]','VARCHAR(25)')
		LEFT JOIN dbo.TiposServicios TS ON TS.cd_codigo = F.Item.value('cd_tiposservicio[1]','VARCHAR(25)')
		LEFT JOIN dbo.ConceptoFacturacion CF ON CF.cd_codigo = F.Item.value('cd_conceptofacturacion[1]','VARCHAR(25)')
		LEFT JOIN dbo.tiposServicio_asignados TSA ON TSA.id_ConceptoFacturacion = CF.id
		LEFT JOIN dbo.TipoProveedores TP ON TP.cd_codigo = F.Item.value('cd_tipoproveedor[1]','VARCHAR(25)')
		
		-- Populate child tables from XML
		DELETE FROM #Pasajeros;
		INSERT INTO #Pasajeros (
			id_facturacion, id_item, in_tipoitem, ds_paxape, ds_paxname, ds_paxprefix, ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion, in_edad, cd_tiquete
		)
		SELECT 
			id_facturacion=ISNULL(P.Pax.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(P.Pax.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(P.Pax.value('in_tipoitem[1]', 'INT'),0),
			ds_paxape=ISNULL(P.Pax.value('ds_paxape[1]', 'VARCHAR(50)'),''),
			ds_paxname=ISNULL(P.Pax.value('ds_paxname[1]', 'VARCHAR(50)'),''),
			ds_paxprefix=ISNULL(P.Pax.value('ds_paxprefix[1]', 'VARCHAR(10)'),''),
			ds_paxclasificacion=ISNULL(P.Pax.value('ds_paxclasificacion[1]', 'VARCHAR(10)'),''),
			cd_voucherpax=ISNULL(P.Pax.value('cd_voucherpax[1]', 'VARCHAR(50)'),''),
			cd_paxidentificacion=ISNULL(P.Pax.value('cd_paxidentificacion[1]', 'VARCHAR(50)'),''),
			in_edad=ISNULL(P.Pax.value('in_edad[1]', 'INT'),0),
			cd_tiquete=ISNULL(P.Pax.value('cd_tiquete[1]', 'VARCHAR(50)'),'')
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Pasajeros') P(Pax);

		DELETE FROM #Itinerarios;
		INSERT INTO #Itinerarios (
			id_facturacion, id_item, in_tipoitem, in_orden, ds_origen, ds_destino, ds_clase, dt_llegada, dt_salida, ds_terminal, cd_aerolinea, cd_farebasis, ds_numerovuelo, ds_tipovuelo, am_valor, am_co2
		)
		SELECT 
			id_facturacion=ISNULL(I.Itin.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(I.Itin.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(I.Itin.value('in_tipoitem[1]', 'INT'),0),
			in_orden=ISNULL(I.Itin.value('in_orden[1]', 'INT'),0),
			ds_origen=ISNULL(I.Itin.value('ds_origen[1]', 'VARCHAR(25)'),''),
			ds_destino=ISNULL(I.Itin.value('ds_destino[1]', 'VARCHAR(25)'),''),
			ds_clase=ISNULL(I.Itin.value('ds_clase[1]', 'VARCHAR(25)'),''),
			dt_llegada=ISNULL(I.Itin.value('dt_llegada[1]', 'SMALLDATETIME'),'19000101 00:00'),
			dt_salida=ISNULL(I.Itin.value('dt_salida[1]', 'SMALLDATETIME'),'19000101 00:00'),
			ds_terminal=ISNULL(I.Itin.value('ds_terminal[1]', 'VARCHAR(25)'),''),
			cd_aerolinea=ISNULL(I.Itin.value('cd_aerolinea[1]', 'VARCHAR(25)'),''),
			cd_farebasis=ISNULL(I.Itin.value('cd_farebasis[1]', 'VARCHAR(25)'),''),
			ds_numerovuelo=ISNULL(I.Itin.value('ds_numerovuelo[1]', 'VARCHAR(25)'),''),
			ds_tipovuelo=ISNULL(I.Itin.value('ds_tipovuelo[1]', 'VARCHAR(25)'),''),
			am_valor=ISNULL(I.Itin.value('am_valor[1]', 'MONEY'),0),
			am_co2=ISNULL(I.Itin.value('am_co2[1]', 'MONEY'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/itinerarios') I(Itin);

		DELETE FROM #CargosImpuestos;
		INSERT INTO #CargosImpuestos (
			id_facturacion, id_item, in_tipoitem, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_contado, am_credito, am_valor, id_carg, id_imp, bl_iva, in_orden
		)
		SELECT 
			id_facturacion=ISNULL(C.Cargo.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(C.Cargo.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(C.Cargo.value('in_tipoitem[1]', 'INT'),0),
			cd_codigo=ISNULL(C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)'),''),
			ds_nombre=ISNULL(C.Cargo.value('ds_nombre[1]', 'VARCHAR(100)'),''),
			cd_tipo=ISNULL(C.Cargo.value('cd_tipo[1]', 'CHAR(1)'),''),
			am_porcentaje=ISNULL(C.Cargo.value('am_porcentaje[1]', 'MONEY'),0),
			am_contado=ISNULL(C.Cargo.value('am_contado[1]', 'MONEY'),0),
			am_credito=ISNULL(C.Cargo.value('am_credito[1]', 'MONEY'),0),
			am_valor=ISNULL(C.Cargo.value('am_valor[1]', 'MONEY'),0),
			id_carg=CASE WHEN CD.id IS NOT NULL THEN CD.id ELSE IR.Id_cargo_dep END, 
			id_imp=IR.id, 
			bl_iva=ISNULL(IR.bl_IVA,0),
			in_orden=ISNULL(C.Cargo.value('in_orden[1]', 'INT'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/CargosImpuestos') C(Cargo)
		LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)') AND C.Cargo.value('cd_tipo[1]', 'CHAR(1)') IN ('C','D')
		LEFT JOIN dbo.ImpRet IR ON IR.cd_codigo=C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)') AND C.Cargo.value('cd_tipo[1]', 'CHAR(1)') IN ('I','R'); 

		DELETE FROM #FormasPagos;
		INSERT INTO #FormasPagos (
			id_facturacion, id_item, in_tipoitem, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_coutas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
		)
		SELECT 
			id_facturacion=ISNULL(F.Pago.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(F.Pago.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(F.Pago.value('in_tipoitem[1]', 'INT'),0),
			id_formaspago=ISNULL(FP.id,0),
			cd_codigo=ISNULL(F.Pago.value('cd_codigo[1]', 'VARCHAR(10)'),''),
			ds_nombre=ISNULL(F.Pago.value('ds_nombre[1]', 'VARCHAR(50)'),''),
			id_tarjetascredito=ISNULL(TC.id,0),
			cd_tipotarjeta=ISNULL(F.Pago.value('cd_tipotarjeta[1]', 'VARCHAR(10)'),''),
			ds_numerotarjeta=ISNULL(F.Pago.value('ds_numerotarjeta[1]', 'VARCHAR(50)'),''),
			ds_vouchertarjeta=ISNULL(F.Pago.value('ds_vouchertarjeta[1]', 'VARCHAR(50)'),''),
			ds_expiraciontarjeta=ISNULL(F.Pago.value('ds_expiraciontarjeta[1]', 'VARCHAR(10)'),''),
			ds_autorizaciontarjeta=ISNULL(F.Pago.value('ds_autorizaciontarjeta[1]', 'VARCHAR(50)'),''),
			in_cuotas=ISNULL(F.Pago.value('in_cuotas[1]', 'INT'),0),
			cd_banco=ISNULL(F.Pago.value('cd_banco[1]', 'VARCHAR(50)'),''),
			ds_cheque=ISNULL(F.Pago.value('ds_cheque[1]', 'VARCHAR(50)'),''),
			ds_plaza=ISNULL(F.Pago.value('ds_plaza[1]', 'VARCHAR(50)'),''),
			ds_referencia=ISNULL(F.Pago.value('ds_referencia[1]', 'VARCHAR(50)'),''),
			ds_Poliza=ISNULL(F.Pago.value('ds_Poliza[1]', 'VARCHAR(50)'),''),
			ds_PolizaAnexo=ISNULL(F.Pago.value('ds_PolizaAnexo[1]', 'VARCHAR(50)'),''),
			am_valor=ISNULL(F.Pago.value('am_valor[1]', 'MONEY'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Formaspago') F(Pago)
		LEFT JOIN dbo.FormasPago FP ON FP.cd_codigo = F.Pago.value('cd_codigo[1]', 'VARCHAR(10)')
		LEFT JOIN dbo.TarjetasCredito TC ON TC.cd_codigo = F.Pago.value('cd_tipotarjeta[1]', 'VARCHAR(10)');

		DELETE FROM #VariablesAdicionales;
		INSERT INTO #VariablesAdicionales (
			id_facturacion, id_item, in_tipoitem, ds_maestro, ds_VariableAdicional, ds_valor, cd_codigo
		)
		SELECT 
			id_facturacion=ISNULL(NULLIF(V.Var.value('id_factura[1]', 'INT'),0), ISNULL(NULLIF(V.Var.value('../id_factura[1]', 'INT'),0), ISNULL(V.Var.value('../../id_factura[1]', 'INT'),0))),
			id_item=ISNULL(V.Var.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(V.Var.value('in_tipoitem[1]', 'INT'),0),
			ds_maestro=ISNULL(V.Var.value('ds_maestro[1]', 'VARCHAR(25)'),''),
			ds_VariableAdicional=ISNULL(V.Var.value('ds_VariableAdicional[1]', 'VARCHAR(25)'),''),
			ds_valor=ISNULL(V.Var.value('ds_valor[1]', 'VARCHAR(500)'),''),
			cd_codigo=ISNULL(V.Var.value('cd_codigo[1]', 'VARCHAR(25)'),'')
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Variables') V(Var);
	
	
	--While 1 = 1
	--Begin
		SET @Fecha = GETDATE();
		IF OBJECT_ID('dbo.Parametr', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 @FechaCont = REPLACE(VALOPAR, '/', '') FROM dbo.Parametr WHERE PARAMETRO = 'FECHACT';
		END
		IF @FechaCont IS NULL SET @FechaCont = GETDATE();
		

			-- Cursor over unique ReservaFactura in this query result
			DECLARE curInvoices CURSOR LOCAL FOR
			SELECT DISTINCT cd_fuente,cd_serie,cd_consecutivo,id_factura
			FROM #Facturacion;

			OPEN curInvoices;
			FETCH NEXT FROM curInvoices INTO @cd_fuente,@cd_serie,@cd_consecutivo,@id_facturacion;

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				DELETE FROM #TmpFacturaCargos;
				DELETE FROM #TmpFacturaFormasPago;

				SET IDENTITY_INSERT #TmpFacturaItems ON;
				

				INSERT INTO #TmpFacturaCargos (id_item, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden)
				SELECT id_item, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden
				FROM #CargosImpuestos
				WHERE id_facturacion = @id_facturacion;

				INSERT INTO #TmpFacturaFormasPago (id_item, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor)
				SELECT id_item, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_coutas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
				FROM #FormasPagos
				WHERE id_facturacion = @id_facturacion;

				-- Fetch header details from the first record in the group

				SELECT TOP 1
					@id_facturacion = id_factura,
					@id_item = id_item,
					@in_tipoitem = in_tipoitem, 
					@ds_cliid = ds_cliid,
					@cd_cliente = cd_cliente,
					@ds_cliname = ds_cliname,
					@ds_clidir = ds_clidir,
					@ds_clicity = ds_clicity,
					@ds_clitel = ds_clitel,
					@ds_ClienteEmail = ds_ClienteEmail,
					@ds_moneda = ds_moneda,
					@cd_vendedor = cd_vendedor,
					@cd_tiqueteador = cd_tiqueteador,
					@am_TasaCambio = am_TasaCambio,
					@cd_tipoventa = cd_tipoventa,
					@cd_licitacion = cd_licitacion,
					@ds_descripcion = ds_descripcion,
					@ds_Observaciones = ds_Observaciones,
					@ds_archivo = ds_archivo,
					@id_reserva = id,
					@cd_reserva = ReservaFactura,
					@cd_sucursal = cd_sucursal,
					@cd_implante = cd_implante,
					@FechaCont = ds_fecha
				FROM #Facturacion
				WHERE cd_fuente = @cd_fuente
					 AND cd_serie = @cd_serie
					 AND cd_consecutivo = @cd_consecutivo

				-- Resolve IDs for headers
				IF ISNULL(@cd_sucursal,'')=''
				BEGIN
					SET @cd_sucursal='01'
					SET @cd_implante=NULL
				END
				SELECT TOP 1 @id_sucursal = id FROM dbo.Sucursales WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_sucursal));
				IF @id_sucursal IS NULL SELECT TOP 1 @id_sucursal = id FROM dbo.Sucursales ORDER BY id;

				SELECT TOP 1 @id_implante = id FROM dbo.Implantes WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_implante)) AND id_sucursal = @id_sucursal;
				SELECT TOP 1 @id_monedas_iata = id FROM dbo.Monedas_IATA WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@ds_moneda));
				IF @id_monedas_iata IS NULL SELECT TOP 1 @id_monedas_iata = id FROM dbo.Monedas_IATA ORDER BY id;

				SELECT TOP 1 @id_tiqueteador = id FROM dbo.Tiqueteadores WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_tiqueteador));
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM ZeusAgencias_23.dbo.Tiqueteadores WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_tiqueteador));
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM dbo.Tiqueteadores ORDER BY id;
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM ZeusAgencias_23.dbo.Tiqueteadores ORDER BY id;
				IF @id_tiqueteador IS NULL SET @id_tiqueteador = 2;

				SELECT TOP 1 @id_tipoventa = id_tipoventa FROM dbo.Tiqueteadores WHERE id = @id_tiqueteador;
				SELECT TOP 1 @cd_bu = cd_bu FROM dbo.Implantes WHERE id = @id_implante;
				IF ISNULL(@cd_bu,'')='' SELECT TOP 1 @cd_bu = cd_bu FROM dbo.Sucursales WHERE id = @id_sucursal;
				IF @id_tipoventa IS NULL SET @id_tipoventa = 1;

				SELECT TOP 1 @am_tcambiousd = am_tasa_cambio FROM dbo.Monedas_IATA WHERE cd_codigo = 'USD';
				IF @am_tcambiousd IS NULL SET @am_tcambiousd = 1.0;

				SELECT @ValorFactura = SUM(
					CASE 
						WHEN tipo_item = 'Aire' THEN (am_tarifa + am_iva + am_tua + am_comb + am_vat)
						ELSE am_tarifa + am_iva + am_vat
					END
				)
				FROM #TmpFacturaItems;

				UPDATE #Facturacion
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 10)
				WHERE tipo IN ('SRV','Hotel','Auto') AND cd_Consecutivo_variablesadicionales IS NULL

				-- Build dynamic SQL @SqlStmt
				SET @SqlStmt = '';
				SET @ItemIndex = 1;	
					

				-- Generar cd_Consecutivo_variablesadicionales aleatorio para los servicios padres
				UPDATE #TmpFacturaItems
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 10)
				WHERE tipo_item IN ('SRV','Hotel','Auto') AND cd_Consecutivo_variablesadicionales IS NULL
				 
				UPDATE C
				SET C.am_valor = ROUND(p.am_valor * (C.am_porcentaje/ 100.0), @NumDecimales),
					C.am_contado = ROUND(p.am_contado * (C.am_porcentaje / 100.0), @NumDecimales),
					C.am_Credito = ROUND(p.am_Credito * (C.am_porcentaje / 100.0), @NumDecimales)
				FROM #TmpFacturaCargos C
				INNER JOIN #TmpFacturaCargos P ON P.id_cargo_temp <> C.id_cargo_temp AND P.id_item = C.id_item AND p.id_carg = C.id_carg AND ISNULL(P.am_valor,0)<>0 AND P.cd_tipo = 'C'
				INNER JOIN #TmpFacturaItems FI ON FI.id_item = C.id_item
				inner join dbo.ConceptoFacturacion CF ON CF.id = FI.id_conceptofacturacion
				WHERE ISNULL(C.am_valor,0)=0 AND ISNULL(C.am_porcentaje,0)<>0 AND C.cd_tipo IN ('I') AND (@CalcularAutoValoresItemFac = 'S' OR CF.bl_CalculoAutoValoresFacturacion=1)	
					  AND CF.id NOT IN(1,2);

				UPDATE FP
				SET FP.am_valor=ISNULL((SELECT SUM(C.am_valor) FROM #TmpFacturaCargos C WHERE C.id_item = FP.id_item AND ISNULL(C.am_valor,0)<>0),FP.am_valor) 
				FROM #TmpFacturaFormasPago FP
				INNER JOIN #TmpFacturaItems FI ON FI.id_item = FP.id_item
				INNER JOIN dbo.ConceptoFacturacion CF ON CF.id = FI.id_conceptofacturacion
				WHERE (@CalcularAutoValoresItemFac = 'S' OR CF.bl_CalculoAutoValoresFacturacion=1)
					  AND CF.id NOT IN(1,2);	
								
				-- Reconstruct dynamic @SqlStmt from tables
				SET @SqlStmt = '';
				SET @ItemIndex = 1;

				DECLARE @gen_id_item INT, @gen_tipo_item VARCHAR(10), @gen_cd_tiquete VARCHAR(50), @gen_ds_descrip VARCHAR(500), @gen_in_nacionalidad INT, @gen_cd_cencosto VARCHAR(50), @gen_cd_auxiliar VARCHAR(50), @gen_cd_item VARCHAR(50), @gen_am_tarifa MONEY, @gen_am_iva MONEY, @gen_am_tua MONEY, @gen_am_comb MONEY, @gen_am_vat MONEY, @gen_am_Comision MONEY, @gen_ds_paxname VARCHAR(30), @gen_ds_paxape VARCHAR(30), @gen_ds_paxprefix CHAR(3), @gen_cd_tourcode VARCHAR(25), @gen_NumTktConj INT, @gen_cd_TipoTiquete CHAR(3), @gen_id_air INT, @gen_ds_itinerario VARCHAR(250), @gen_ds_itinerarioaerolinea VARCHAR(128), @gen_ds_clases VARCHAR(61), @gen_ds_Observaciones VARCHAR(8000), @gen_am_highfare MONEY, @gen_am_lowfare MONEY, @gen_ds_solicita VARCHAR(200), @gen_ds_lapsoviaje VARCHAR(50), @gen_cd_tktrevisado VARCHAR(14), @gen_cd_PasaportePax VARCHAR(25), @gen_cd_pax_CC VARCHAR(20), @gen_am_PorFacParcial MONEY, @gen_in_cantpax INT, @gen_Id_Precompra INT, @gen_id_FormasPago INT, @gen_id_TarjetasCredito INT, @gen_id_sucursal INT, @gen_id_implante INT, @gen_bl_ahorro BIT, @gen_cd_TipoTiqueteGDS VARCHAR(3), @gen_id_TiposDocumento INT, @gen_id_entdist INT, @gen_id_entvend INT, @gen_cd_destino VARCHAR(3), @gen_dt_fechaexped SMALLDATETIME, @gen_id_tiqueteadores INT, @gen_id_gds INT, @gen_iden_gds INT, @gen_am_comisionPNR MONEY, @gen_ds_records VARCHAR(62), @gen_bl_NoCalcComision BIT, @gen_bl_NoCalcIvaComision BIT, @gen_am_basecomisionable MONEY, @gen_am_porcomision MONEY, @gen_id_tiposconceptfac INT, @gen_id_conceptofacturacion INT, @gen_id_tiposservicio INT,@gen_ds_tiposservicio VARCHAR(50), @gen_cd_proveedores VARCHAR(25), @gen_ds_servicio VARCHAR(250), @gen_am_valorprov MONEY, @gen_id_monedaprov INT, @gen_dt_llegada SMALLDATETIME, @gen_dt_salida SMALLDATETIME, @gen_am_pordescuento NUMERIC(8,4), @gen_Fecha_Salida SMALLDATETIME, @gen_Fecha_Llegada SMALLDATETIME, @gen_am_basedescuento MONEY, @gen_cd_Consecutivo_depende VARCHAR(50), @gen_cd_Consecutivo_variablesadicionales VARCHAR(50), @gen_id_referencia_origen INT, @gen_id_tipoproveedor INT, @gen_cd_tipoproveedor VARCHAR(50), @gen_ds_tipoproveedor VARCHAR(250);


				DECLARE curGenItems CURSOR LOCAL FAST_FORWARD FOR
				SELECT 
					id_item, tipo_item, cd_tiquete, ds_descrip, in_nacionalidad, cd_cencosto, cd_auxiliar, cd_item, am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision,
					ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, cd_TipoTiquete, id_air, ds_itinerario, ds_itinerarioaerolinea, ds_clases, ds_Observaciones,
					am_highfare, am_lowfare, ds_solicita, ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, am_PorFacParcial, in_cantpax, Id_Precompra,
					id_FormasPago, id_TarjetasCredito, id_sucursal, id_implante, bl_ahorro, cd_TipoTiqueteGDS, id_TiposDocumento, id_entdist, id_entvend,
					cd_destino, dt_fechaexped, id_tiqueteadores, id_gds, iden_gds, am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision,
					am_basecomisionable, am_porcomision, id_tiposconceptfac, id_conceptofacturacion, id_tiposservicio, cd_proveedores, ds_servicio,
					am_valorprov, id_monedaprov, dt_llegada, dt_salida, am_pordescuento, Fecha_Salida, Fecha_Llegada, am_basedescuento, cd_Consecutivo_depende, cd_Consecutivo_variablesadicionales, id_referencia_origen, id_tipoproveedor, cd_tipoproveedor, ds_tipoproveedor
				FROM #TmpFacturaItems
				WHERE id_factura=@id_facturacion
				ORDER BY id_item;

				IF OBJECT_ID('tempdb..#TmpVariablesObtenidas') IS NOT NULL DROP TABLE #TmpVariablesObtenidas;
				CREATE TABLE #TmpVariablesObtenidas (
					Iden_Variable INT,
					Nombre VARCHAR(100) COLLATE DATABASE_DEFAULT,
					ValorObtenido VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
					Id_Reserva INT,
					IDEN_Maestro INT,
					cd_Maestro VARCHAR(50) COLLATE DATABASE_DEFAULT
				);

				OPEN curGenItems;
				FETCH NEXT FROM curGenItems INTO 
					@gen_id_item, @gen_tipo_item, @gen_cd_tiquete, @gen_ds_descrip, @gen_in_nacionalidad, @gen_cd_cencosto, @gen_cd_auxiliar, @gen_cd_item, @gen_am_tarifa, @gen_am_iva, @gen_am_tua, @gen_am_comb, @gen_am_vat, @gen_am_Comision,
					@gen_ds_paxname, @gen_ds_paxape, @gen_ds_paxprefix, @gen_cd_tourcode, @gen_NumTktConj, @gen_cd_TipoTiquete, @gen_id_air, @gen_ds_itinerario, @gen_ds_itinerarioaerolinea, @gen_ds_clases, @gen_ds_Observaciones,
					@gen_am_highfare, @gen_am_lowfare, @gen_ds_solicita, @gen_ds_lapsoviaje, @gen_cd_tktrevisado, @gen_cd_PasaportePax, @gen_cd_pax_CC, @gen_am_PorFacParcial, @gen_in_cantpax, @gen_Id_Precompra,
					@gen_id_FormasPago, @gen_id_TarjetasCredito, @gen_id_sucursal, @gen_id_implante, @gen_bl_ahorro, @gen_cd_TipoTiqueteGDS, @gen_id_TiposDocumento, @gen_id_entdist, @gen_id_entvend,
					@gen_cd_destino, @gen_dt_fechaexped, @gen_id_tiqueteadores, @gen_id_gds, @gen_iden_gds, @gen_am_comisionPNR, @gen_ds_records, @gen_bl_NoCalcComision, @gen_bl_NoCalcIvaComision,
					@gen_am_basecomisionable, @gen_am_porcomision, @gen_id_tiposconceptfac, @gen_id_conceptofacturacion, @gen_id_tiposservicio, @gen_cd_proveedores, @gen_ds_servicio,
					@gen_am_valorprov, @gen_id_monedaprov, @gen_dt_llegada, @gen_dt_salida, @gen_am_pordescuento, @gen_Fecha_Salida, @gen_Fecha_Llegada, @gen_am_basedescuento, @gen_cd_Consecutivo_depende, @gen_cd_Consecutivo_variablesadicionales, @gen_id_referencia_origen, @gen_id_tipoproveedor, @gen_cd_tipoproveedor, @gen_ds_tipoproveedor;
			
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					IF @gen_tipo_item IN ('Aire')
					BEGIN

						-- Build cargos / impuestos SQL
						SET @TktSqlStmt = '';
						
						DELETE FROM #TmpVariablesObtenidas;
						IF @gen_id_referencia_origen IS NOT NULL AND OBJECT_ID('dbo.spConfiguracionVariablesObtenerValores', 'P') IS NOT NULL
						BEGIN
							INSERT INTO #TmpVariablesObtenidas
							EXEC dbo.spConfiguracionVariablesObtenerValores 
								@id_usuario = 1, 
								@id_ReservaGDS_Detalles = @gen_id_referencia_origen;
								
							DECLARE @var_Iden_Variable INT, @var_IDEN_Maestro INT, @var_ValorObtenido VARCHAR(MAX);
							DECLARE curVars CURSOR LOCAL FAST_FORWARD FOR
							SELECT Iden_Variable, IDEN_Maestro, ValorObtenido FROM #TmpVariablesObtenidas WHERE ISNULL(ValorObtenido, '') <> '';

							OPEN curVars;
							FETCH NEXT FROM curVars INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TktSqlStmt = @TktSqlStmt + ' INSERT INTO dbo.VariableDatosMaestro (Iden_Variable, IDEN_Maestro, cd_maestro, ValorObtenido) VALUES (' + CAST(@var_Iden_Variable AS VARCHAR) + ', ' + CAST(@var_IDEN_Maestro AS VARCHAR) + ', ''' + REPLACE(@gen_cd_tiquete, '''', '''''') + ''', ''' + REPLACE(@var_ValorObtenido, '''', '''''') + ''');' + CHAR(13) + CHAR(10)
								FETCH NEXT FROM curVars INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido;
							END;
							CLOSE curVars;
							DEALLOCATE curVars;
						END
						
						DECLARE @c_codigo VARCHAR(20), @ds_nombre VARCHAR(100), @cd_tipo CHAR(1), @am_porcentaje NUMERIC(8,4), @am_valor MONEY, @am_contado MONEY, @am_credito MONEY, @id_carg INT, @id_imp INT;
						
						DECLARE @TktImpuestosSqlStmt VARCHAR(MAX) = '';
						
						DECLARE curItemCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');

						OPEN curItemCargos;
						FETCH NEXT FROM curItemCargos INTO @c_codigo, @ds_nombre, @cd_tipo, @am_porcentaje, @am_valor, @am_contado, @am_credito, @id_carg, @id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @c_codigotax VARCHAR(20), @ds_nombretax VARCHAR(100), @cd_tipotax CHAR(1), @am_porcentajetax NUMERIC(8,4), @am_valortax MONEY, @am_contadotax MONEY, @am_creditotax MONEY, @id_cargtax INT, @id_imptax INT;
							SET @TktImpuestosSqlStmt='';
							DECLARE curItemTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg = @id_carg AND cd_tipo IN ('I','R');

							OPEN curItemTaxes;
							FETCH NEXT FROM curItemTaxes INTO @c_codigotax, @ds_nombretax, @cd_tipotax, @am_porcentajetax, @am_valortax, @am_contadotax, @am_creditotax, @id_cargtax, @id_imptax;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TktImpuestosSqlStmt = @TktImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteImpuestos_Insertar @id_tiquetecargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + REPLACE(@ds_nombretax, '''', '''''') + ''',@cd_impcta='''', @am_valor = ' + CAST(@am_valortax AS VARCHAR) + ', @am_contado = ' + CAST(@am_contadotax AS VARCHAR) + ', @am_credito = ' + CAST(@am_creditotax AS VARCHAR) + ', @am_porcentaje = ' + CAST(@am_porcentajetax AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;'  
								FETCH NEXT FROM curItemTaxes INTO @c_codigotax, @ds_nombretax, @cd_tipotax, @am_porcentajetax, @am_valortax, @am_contadotax, @am_creditotax, @id_cargtax, @id_imptax;
							END
							CLOSE curItemTaxes;
							DEALLOCATE curItemTaxes;

							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteCargos_Insertar @id_fac_remision = @NewRmId, @id_fac_factura = @NewFacId, @id_tiquetes = @NewTktId, @id_cargosdesc = ' + CAST(ISNULL(@id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + REPLACE(@ds_nombre, '''', '''''') + ''', @am_valor = ' + CAST(@am_valor AS VARCHAR) + ', @am_contado = ' + CAST(@am_contado AS VARCHAR) + ', @am_credito = ' + CAST(@am_credito AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(@TktImpuestosSqlStmt, '''', '''''') + ''';'  
							
							FETCH NEXT FROM curItemCargos INTO @c_codigo, @ds_nombre, @cd_tipo, @am_porcentaje, @am_valor, @am_contado, @am_credito, @id_carg, @id_imp;
						END
						CLOSE curItemCargos;
						DEALLOCATE curItemCargos;
								

						-- Build Formas de Pago SQL
						DECLARE @fp_id_fp INT, @fp_id_tc INT, @fp_cd_codigo VARCHAR(10), @fp_ds_nombre VARCHAR(50), @fp_cd_tipotarjeta VARCHAR(10), @fp_ds_numerotarjeta VARCHAR(50), @fp_ds_vouchertarjeta VARCHAR(50), @fp_ds_expiraciontarjeta VARCHAR(10), @fp_ds_autorizaciontarjeta VARCHAR(50), @fp_in_cuotas INT, @fp_am_valor MONEY;
						DECLARE curItemFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemFPs;
						FETCH NEXT FROM curItemFPs INTO @fp_id_fp, @fp_id_tc, @fp_cd_codigo, @fp_ds_nombre, @fp_cd_tipotarjeta, @fp_ds_numerotarjeta, @fp_ds_vouchertarjeta, @fp_ds_expiraciontarjeta, @fp_ds_autorizaciontarjeta, @fp_in_cuotas, @fp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteFormasPago_Insertar @id_tiquetes = @NewTktId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_FormasPago = ' + CAST(@fp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@fp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_TarjetasCredito = ' + ISNULL(CAST(@fp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @fp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @fp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @fp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @fp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@fp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @fp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@fp_in_cuotas AS VARCHAR),'0') + ';' 
							FETCH NEXT FROM curItemFPs INTO @fp_id_fp, @fp_id_tc, @fp_cd_codigo, @fp_ds_nombre, @fp_cd_tipotarjeta, @fp_ds_numerotarjeta, @fp_ds_vouchertarjeta, @fp_ds_expiraciontarjeta, @fp_ds_autorizaciontarjeta, @fp_in_cuotas, @fp_am_valor;
						END
						CLOSE curItemFPs;
						DEALLOCATE curItemFPs;

						-- Build Itinerarios SQL (inline query, no temp table needed)
						SET @TktItinSqlStmt = '';
						SELECT 
							@TktItinSqlStmt = @TktItinSqlStmt + + CHAR(13) + CHAR(10) + 
							'EXECUTE dbo.spza_TiqueteItinerarios_Insertar 
								@id_fac_factura = @NewFacId, 
								@id_fac_remision = @NewRmId, 
								@id_Tiquetes = @NewTktId, 
								@orden = ' + CAST(in_orden AS VARCHAR) + ', 
								@cd_origen = ''' + ISNULL(ds_origen,'') + ''', 
								@cd_destino = ''' + ISNULL(ds_destino,'') + ''', 
								@cd_clase = ''' + ISNULL(LEFT(ds_clase,1),'') + ''', 
								@fecha_salida = ''' + ISNULL(CONVERT(VARCHAR(10),dt_salida,111),'') + ''', 
								@hora_salida = ''' + ISNULL(CONVERT(VARCHAR(8),dt_salida,108),'') + ''', 
								@hora_llegada = ''' + ISNULL(CONVERT(VARCHAR(8),dt_llegada,108),'') + ''', 
								@terminal = ''' + REPLACE(ISNULL(ds_terminal,''), '''', '''''') + ''', 
								@cd_aero_siglas = ''' + ISNULL(cd_aerolinea,'') + ''', 
								@cd_farebasis = ''' + ISNULL(cd_farebasis,'') + ''', 
								@ds_NumVuelo = ''' + ISNULL(ds_numerovuelo,'') + ''', 
								@ds_TipoVuelo = ''' + ISNULL(ds_tipovuelo,'') + ''', 
								@am_valor = ' + CAST(ISNULL(am_valor, 0) AS VARCHAR) + ', 
								@bl_NoUtilizado = NULL, 
								@am_co2 = ' + CAST(ISNULL(am_co2, 0) AS VARCHAR) + '; '
						FROM #Itinerarios
						WHERE id_item = @gen_id_item
						ORDER BY in_orden;

						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) + '
						DECLARE @NewTktId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Tiquete_Vender
							@cd_tiquete = ''' + ISNULL(@gen_cd_tiquete,'') + ''',
							@id_TiposDocumento = ' + ISNULL(CAST(@gen_id_TiposDocumento AS VARCHAR),'NULL') + ',
							@id_entdist = ' + ISNULL(CAST(@gen_id_entdist AS VARCHAR),'1') + ',
							@in_estado = 1,
							@in_nacionalidad = ' + ISNULL(CAST(@gen_in_nacionalidad AS VARCHAR),'1') + ',
							@id_entvend = ' + ISNULL(CAST(@gen_id_entvend AS VARCHAR),'NULL') + ',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@cd_tktrevisado = ' + ISNULL('''' + @gen_cd_tktrevisado + '''', 'NULL') + ',
							@id_pax = NULL,
							@ds_paxname = ''' + ISNULL(@gen_ds_paxname,'') + ''',
							@ds_paxape = ''' + ISNULL(@gen_ds_paxape,'') + ''',
							@ds_paxprefix = ''' + ISNULL(@gen_ds_paxprefix, '') + ''',
							@cd_paxcedula = ''' + ISNULL(@gen_cd_pax_CC, '') + ''',
							@ds_itinerario = ''' + ISNULL(LEFT(@gen_ds_itinerario, 63),'') + ''',
							@ds_itinerarioaerolinea = ''' + LEFT(ISNULL(@gen_ds_itinerarioaerolinea, ''), 63) + ''',
							@ds_clases = ''' + ISNULL(@gen_ds_clases, '') + ''',
							@dt_fechasalida = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@dt_fechallegada = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@cd_destino = ''' + ISNULL(@gen_cd_destino, '') + ''',
							@dt_fechaexped = ''' + ISNULL(CONVERT(VARCHAR, @gen_dt_fechaexped, 120),'19000101') + ''',
							@id_usuario = 1,
							@id_tiqueteadores = ' + ISNULL(CAST(@gen_id_tiqueteadores AS VARCHAR),'NULL') + ',
							@am_hf = ' + ISNULL(CAST(@gen_am_highfare AS VARCHAR),'0') + ',
							@am_lf = ' + ISNULL(CAST(@gen_am_lowfare AS VARCHAR),'0') + ',
							@am_tarifa = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'0') + ',
							@cd_ah = ''' + ISNULL(@gen_cd_tourcode, '') + ''',
							@am_desah = 0,
							@id_gds = ' + ISNULL(CAST(@gen_id_gds AS VARCHAR),'NULL') + ',
							@iden_gds = ' + ISNULL(CAST(@gen_iden_gds AS VARCHAR),'NULL') + ',
							@in_numtktconj = ' + ISNULL(CAST(@gen_NumTktConj AS VARCHAR),'0') + ',
							@bl_NoCalcComision = 0,
							@bl_NoCalcIvaComision = 0,
							@am_comisionPNR = ' + ISNULL(CAST(@gen_am_Comision AS VARCHAR),'0') + ',
							@am_basecomisionable = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'0') + ',
							@am_porcomision = 0,
							@ds_records = ''' + ISNULL(@gen_ds_records,'') + ''',
							@id_hotel = NULL,
							@id_precompra = ' + ISNULL(CAST(@gen_Id_Precompra AS VARCHAR), 'NULL') + ',
							@id_TipoTiquete = NULL,
							@id_ReassonCode = NULL,
							@cencosto_interno = ''' + ISNULL(@gen_cd_cencosto, '') + ''',
							@ds_solicita = ''' + ISNULL(@gen_ds_solicita, '') + ''',
							@ds_lapsoviaje = ''' + ISNULL(@gen_ds_lapsoviaje, '') + ''',
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@cd_TiqueteGr = NULL,
							@SqlStmt = ''' + REPLACE(ISNULL(@TktSqlStmt,''), '''', '''''') + ''',
							@SqlStmtItinerarios = ''' + REPLACE(ISNULL(@TktItinSqlStmt,''), '''', '''''') + ''',
							@id_sucursal = @id_sucursal,
							@id_implante = @id_implante,
							@bl_ahorro = ' + CAST(@gen_bl_ahorro AS VARCHAR) + ',
							@cd_TipoTiqueteGDS = ''' + ISNULL(@gen_cd_TipoTiqueteGDS, '') + ''',
							@cd_tourcode = ''' + ISNULL(@gen_cd_tourcode, '') + ''',
							@cd_PasaportePax = ''' + ISNULL(@gen_cd_PasaportePax, '') + ''',
							@am_valor_aerolinea = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'') + ',
							@am_porcentaje_comision_BackEnd = 0,
							@am_valor_comision_BackEnd = 0,
							@am_PorFacParcial = ' + CAST(ISNULL(@gen_am_PorFacParcial, 100) AS VARCHAR) + ',
							@in_cantpax = ' + CAST(ISNULL(@gen_in_cantpax, 1) AS VARCHAR) + ',
							@OrdenGrabacion = ' + CAST(ISNULL(@ItemIndex, 1) AS VARCHAR) + ',
							@cd_Penalidad = NULL,
							@id_entdistIata = NULL,
							@id_entvendIata = NULL; ';			
					END
					ELSE IF @gen_tipo_item = 'TAO'
					BEGIN 
						-- Build cargos / impuestos SQL
						SET @TaoCargSqlStmt = '';
						
						DECLARE @tc_codigo VARCHAR(20), @tc_ds_nombre VARCHAR(100), @tc_cd_tipo CHAR(1), @tc_am_porcentaje NUMERIC(8,4), @tc_am_valor MONEY, @tc_am_contado MONEY, @tc_am_credito MONEY, @tc_id_carg INT, @tc_id_imp INT;
						
						DECLARE @TaoImpuestosSqlStmt VARCHAR(MAX) = '';
												
						DECLARE curItemTaoCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');

						OPEN curItemTaoCargos;
						FETCH NEXT FROM curItemTaoCargos INTO @tc_codigo, @tc_ds_nombre, @tc_cd_tipo, @tc_am_porcentaje, @tc_am_valor, @tc_am_contado, @tc_am_credito, @tc_id_carg, @tc_id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @tc_codigotax VARCHAR(20), @tc_ds_nombretax VARCHAR(100), @tc_cd_tipotax CHAR(1), @tc_am_porcentajetax NUMERIC(8,4), @tc_am_valortax MONEY, @tc_am_contadotax MONEY, @tc_am_creditotax MONEY, @tc_id_cargtax INT, @tc_id_imptax INT;
							SET @TaoImpuestosSqlStmt='';

							DECLARE curItemTaoTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg=@tc_id_carg AND cd_tipo IN ('I','R');

							OPEN curItemTaoTaxes;
							FETCH NEXT FROM curItemTaoTaxes INTO @tc_codigotax, @tc_ds_nombretax, @tc_cd_tipotax, @tc_am_porcentajetax, @tc_am_valortax, @tc_am_contadotax, @tc_am_creditotax, @tc_id_cargtax, @tc_id_imptax;	
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TaoImpuestosSqlStmt = @TaoImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoImpuestos_Insertar @id_FacTaoCargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@tc_id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@tc_ds_nombretax,'') + ''', @cd_impcta='''', @am_valor = ' + CAST(ISNULL(@tc_am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@tc_am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@tc_am_creditotax,0) AS VARCHAR) + ', @am_porcentaje=' + CAST(ISNULL(@tc_am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;' 
								FETCH NEXT FROM curItemTaoTaxes INTO @tc_codigotax, @tc_ds_nombretax, @tc_cd_tipotax, @tc_am_porcentajetax, @tc_am_valortax, @tc_am_contadotax, @tc_am_creditotax, @tc_id_cargtax, @tc_id_imptax;
							END
							CLOSE curItemTaoTaxes;
							DEALLOCATE curItemTaoTaxes;

							SET @TaoCargSqlStmt = @TaoCargSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoCargos_Insertar @id_fac_remision = @NewRmId, @id_fac_factura = @NewFacId, @Id_Fac_Tao = @NewTaoId, @id_cargosdesc = ' + CAST(ISNULL(@tc_id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@tc_ds_nombre,'') + ''', @am_valor = ' + CAST(ISNULL(@tc_am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@tc_am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@tc_am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@TaoImpuestosSqlStmt,''), '''', '''''') + ''';' 
							FETCH NEXT FROM curItemTaoCargos INTO @tc_codigo, @tc_ds_nombre, @tc_cd_tipo, @tc_am_porcentaje, @tc_am_valor, @tc_am_contado, @tc_am_credito, @tc_id_carg, @tc_id_imp;
						END
						CLOSE curItemTaoCargos;
						DEALLOCATE curItemTaoCargos;
						
						SET @TaoFpSqlStmt = '';
						
						DECLARE @tfp_id_fp INT, @tfp_id_tc INT, @tfp_cd_codigo VARCHAR(10), @tfp_ds_nombre VARCHAR(50), @tfp_cd_tipotarjeta VARCHAR(10), @tfp_ds_numerotarjeta VARCHAR(50), @tfp_ds_vouchertarjeta VARCHAR(50), @tfp_ds_expiraciontarjeta VARCHAR(10), @tfp_ds_autorizaciontarjeta VARCHAR(50), @tfp_in_cuotas INT, @tfp_am_valor MONEY;
						DECLARE curItemTaoFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta , ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemTaoFPs;
						FETCH NEXT FROM curItemTaoFPs INTO @tfp_id_fp, @tfp_id_tc, @tfp_cd_codigo, @tfp_ds_nombre, @tfp_cd_tipotarjeta, @tfp_ds_numerotarjeta, @tfp_ds_vouchertarjeta, @tfp_ds_expiraciontarjeta, @tfp_ds_autorizaciontarjeta, @tfp_in_cuotas, @tfp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @TaoFpSqlStmt = @TaoFpSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoFormasPago_Insertar @Id_Fac_Tao = @NewTaoId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_formaspago = ' + CAST(@tfp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@tfp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_tarjetascredito = ' + ISNULL(CAST(@tfp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @tfp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @tfp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @tfp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @tfp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@tfp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @tfp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@tfp_in_cuotas AS VARCHAR), '0') + ';' 
							FETCH NEXT FROM curItemTaoFPs INTO @tfp_id_fp, @tfp_id_tc, @tfp_cd_codigo, @tfp_ds_nombre, @tfp_cd_tipotarjeta, @tfp_ds_numerotarjeta, @tfp_ds_vouchertarjeta, @tfp_ds_expiraciontarjeta, @tfp_ds_autorizaciontarjeta, @tfp_in_cuotas, @tfp_am_valor;
						END
						CLOSE curItemTaoFPs;
						DEALLOCATE curItemTaoFPs;

						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) +'
						DECLARE @NewTaoId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Tao_Vender
							@cd_tiquete = ''' + ISNULL(@gen_cd_tiquete, '') + ''',
							@ds_descrip = ''' + ISNULL(@gen_ds_descrip, '') + ''',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@in_nacionalidad = ' + CAST(ISNULL(@gen_in_nacionalidad,0) AS VARCHAR) + ',
							@cd_cencosto = ''' + ISNULL(@gen_cd_cencosto, '') + ''',
							@cd_aux = ''' + ISNULL(@gen_cd_auxiliar, '') + ''',
							@cd_coditem = ''' + ISNULL(@gen_cd_item, '') + ''',
							@am_basecomisionable = ' + CAST(ISNULL(@gen_am_tarifa,0) AS VARCHAR) + ',
							@am_porcomision = 0,
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@OrdenGrabacion = ' + CAST(@ItemIndex AS VARCHAR) + ',
							@SqlStmt = ''' + REPLACE(@TaoCargSqlStmt + @TaoFpSqlStmt, '''', '''''') + '''; '

							
					END
					ELSE IF @gen_tipo_item IN ('SRV','Hotel','Auto')
					BEGIN
						-- Build cargos / impuestos / provider / pax SQL
						SET @SrvSqlStmt = '';
						SET @SrvImpuestosSqlStmt = '';
						
						DELETE FROM #TmpVariablesObtenidas;
						IF @gen_id_referencia_origen IS NOT NULL AND OBJECT_ID('dbo.spConfiguracionVariablesObtenerValores', 'P') IS NOT NULL
						BEGIN
							INSERT INTO #TmpVariablesObtenidas
							EXEC dbo.spConfiguracionVariablesObtenerValores 
								@id_usuario = 1, 
								@id_ReservaGDS_Servicios = @gen_id_referencia_origen;

							DECLARE @var_Iden_Variable_srv INT, @var_IDEN_Maestro_srv INT, @var_ValorObtenido_srv VARCHAR(MAX);
							DECLARE curVarsSrv CURSOR LOCAL FAST_FORWARD FOR
							SELECT Iden_Variable, IDEN_Maestro, ValorObtenido FROM #TmpVariablesObtenidas WHERE ISNULL(ValorObtenido, '') <> '';

							OPEN curVarsSrv;
							FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @SrvSqlStmt = @SrvSqlStmt +CHAR(13) + CHAR(10)+ ' INSERT INTO dbo.VariableDatosMaestro (Iden_Variable, IDEN_Maestro, cd_maestro, ValorObtenido) VALUES (' + CAST(@var_Iden_Variable_srv AS VARCHAR) + ', ' + CAST(@var_IDEN_Maestro_srv AS VARCHAR) + ', ''' + REPLACE(@gen_cd_Consecutivo_variablesadicionales, '''', '''''') + ''', ''' + REPLACE(@var_ValorObtenido_srv, '''', '''''') + ''');' 
								FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv;
							END;
							CLOSE curVarsSrv;
							DEALLOCATE curVarsSrv;
						END
						SET @SrvCargSqlStmt = '';
						SET @SrvFpSqlStmt = '';

						DECLARE @sc_codigo VARCHAR(20), @sc_ds_nombre VARCHAR(100), @sc_cd_tipo CHAR(1), @sc_am_porcentaje NUMERIC(8,4), @sc_am_valor MONEY, @sc_am_contado MONEY, @sc_am_credito MONEY, @sc_id_carg INT, @sc_id_imp INT;
						DECLARE @HasTarCargo BIT, @IsFirstCargo BIT;
						
						-- First Pass: accumulate service taxes (impuestos/retenciones)
						-- Second Pass: process cargos and link accumulated taxes to 'TAR' or first cargo
						DECLARE curItemSrvCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');
						

						OPEN curItemSrvCargos;
						FETCH NEXT FROM curItemSrvCargos INTO @sc_codigo, @sc_ds_nombre, @sc_cd_tipo, @sc_am_porcentaje, @sc_am_valor, @sc_am_contado, @sc_am_credito, @sc_id_carg, @sc_id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @sc_codigotax VARCHAR(20), @sc_ds_nombretax VARCHAR(100), @sc_cd_tipotax CHAR(1), @sc_am_porcentajetax NUMERIC(8,4), @sc_am_valortax MONEY, @sc_am_contadotax MONEY, @sc_am_creditotax MONEY, @sc_id_cargtax INT, @sc_id_imptax INT;
							SET @SrvImpuestosSqlStmt='';
							DECLARE curItemSrvTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg=@sc_id_carg AND cd_tipo IN ('I','R');

							OPEN curItemSrvTaxes;
							FETCH NEXT FROM curItemSrvTaxes INTO @sc_codigotax, @sc_ds_nombretax, @sc_cd_tipotax, @sc_am_porcentajetax, @sc_am_valortax, @sc_am_contadotax, @sc_am_creditotax, @sc_id_cargtax, @sc_id_imptax;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @SrvImpuestosSqlStmt = @SrvImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioImpuestos_Insertar @id_FacServiciosCargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@sc_id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@sc_ds_nombretax, '') + ''', @cd_impcta = '''', @am_valor = ' + CAST(ISNULL(@sc_am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_creditotax,0) AS VARCHAR) + ', @am_porcentaje = ' + CAST(ISNULL(@sc_am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar = 1, @am_deltaCorreccion = 0;' 
								
								FETCH NEXT FROM curItemSrvTaxes INTO @sc_codigotax, @sc_ds_nombretax, @sc_cd_tipotax, @sc_am_porcentajetax, @sc_am_valortax, @sc_am_contadotax, @sc_am_creditotax, @sc_id_cargtax, @sc_id_imptax;
							END
							CLOSE curItemSrvTaxes;
							DEALLOCATE curItemSrvTaxes;

							SET @SrvCargSqlStmt = @SrvCargSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioCargos_Insertar @id_Fac_Servicios = @NewSrvId, @id_cargosdesc = ' + CAST(ISNULL(@sc_id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@sc_ds_nombre, '') + ''', @am_valor = ' + CAST(ISNULL(@sc_am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@SrvImpuestosSqlStmt,''), '''', '''''') + ''';' 
							
							FETCH NEXT FROM curItemSrvCargos INTO @sc_codigo, @sc_ds_nombre, @sc_cd_tipo, @sc_am_porcentaje, @sc_am_valor, @sc_am_contado, @sc_am_credito, @sc_id_carg, @sc_id_imp;
						END
						CLOSE curItemSrvCargos;
						DEALLOCATE curItemSrvCargos;
						 
						-- Build Formas de Pago SQL
						DECLARE @sfp_id_fp INT, @sfp_id_tc INT, @sfp_cd_codigo VARCHAR(10), @sfp_ds_nombre VARCHAR(50), @sfp_cd_tipotarjeta VARCHAR(10), @sfp_ds_numerotarjeta VARCHAR(50), @sfp_ds_vouchertarjeta VARCHAR(50), @sfp_ds_expiraciontarjeta VARCHAR(10), @sfp_ds_autorizaciontarjeta VARCHAR(50), @sfp_in_cuotas INT, @sfp_am_valor MONEY;
						DECLARE curItemSrvFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemSrvFPs;
						FETCH NEXT FROM curItemSrvFPs INTO @sfp_id_fp, @sfp_id_tc, @sfp_cd_codigo, @sfp_ds_nombre, @sfp_cd_tipotarjeta, @sfp_ds_numerotarjeta, @sfp_ds_vouchertarjeta, @sfp_ds_expiraciontarjeta, @sfp_ds_autorizaciontarjeta, @sfp_in_cuotas, @sfp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @SrvFpSqlStmt = @SrvFpSqlStmt + CHAR(13) + CHAR(10) +' EXECUTE dbo.spza_ServicioFormasPago_Insertar @id_Fac_Servicios = @NewSrvId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_formaspago = ' + CAST(@sfp_id_fp AS VARCHAR) + ',@ds_fpnm =' + ISNULL('''' + @sfp_ds_nombre + '''', 'NULL') + ', @am_valor = ' + CAST(@sfp_am_valor AS VARCHAR) + ',@bl_fprepresenta=0 , @id_tarjetascredito = ' + ISNULL(CAST(@sfp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' +@sfp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @sfp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @sfp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @sfp_ds_expiraciontarjeta + '''', 'NULL') + ', @ds_tcautorizacion = ' + ISNULL('''' + @sfp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@sfp_in_cuotas AS VARCHAR),'0') + ', @cd_idbanco=NULL, @ds_cheque=NULL,@ds_plaza=NULL,@ds_referencia=NULL, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio;' 
							FETCH NEXT FROM curItemSrvFPs INTO @sfp_id_fp, @sfp_id_tc, @sfp_cd_codigo, @sfp_ds_nombre, @sfp_cd_tipotarjeta, @sfp_ds_numerotarjeta, @sfp_ds_vouchertarjeta, @sfp_ds_expiraciontarjeta, @sfp_ds_autorizaciontarjeta, @sfp_in_cuotas, @sfp_am_valor;
						END
						CLOSE curItemSrvFPs;
						DEALLOCATE curItemSrvFPs;

						-- Build provider SQL
						SET @SrvProvSqlStmt = '';
						DECLARE @c_id_tipoproveedor INT, @c_cd_tipoproveedor VARCHAR(10), @c_ds_tipoproveedor VARCHAR(100);
						IF ISNULL(@gen_cd_proveedores, '') <> ''
						BEGIN
							SELECT TOP 1 
								@c_id_tipoproveedor = tp.id, 
								@c_cd_tipoproveedor = tp.cd_codigo, 
								@c_ds_tipoproveedor = tp.ds_nombre 
							FROM dbo.TipoProveedores tp WITH(NOLOCK) 
							WHERE tp.cd_codigo = ISNULL(@gen_cd_tipoproveedor,'HTL');

							SELECT @c_cd_proveedores = IDPROVE
								   ,@c_ds_proveedores = RAZONCIAL
							FROM dbo.PROVEEDORES 
							WHERE IDPROVE = @gen_cd_proveedores;
							
							IF @c_id_tipoproveedor IS NOT NULL
							BEGIN
								SET @SrvProvSqlStmt = CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioTipoProv_Insertar @id_Fac_Servicios = @NewSrvId, @id_tipoproveedores = ' + CAST(@c_id_tipoproveedor AS VARCHAR) + ', @cd_TipoProveedores = ''' + ISNULL(@c_cd_tipoproveedor,'') + ''', @ds_TipoProveedores = ''' + ISNULL(@c_ds_tipoproveedor,'')+ ''', @cd_proveedores = ''' + ISNULL(@c_cd_proveedores,'')+''', @ds_proveedores = ''' + ISNULL(@c_ds_proveedores,'')+ ''';'
							END;
						END;

						SELECT @gen_ds_tiposservicio = ds_nombre FROM dbo.TiposServicios WHERE id = @gen_id_tiposservicio

						-- Build pax SQL
						SET @SrvPaxSqlStmt = '';
						IF ISNULL(@gen_ds_paxname, '') <> ''
						BEGIN
							SET @SrvPaxSqlStmt = CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioPaxAdicional_insertar @FacId = @NewFacId, @RemId = @NewRemId, @id_Fac_Servicios = @NewSrvId, @ds_paxname = ''' + REPLACE(@gen_ds_paxname, '''', '''''') + ''', @ds_paxape = ''' + REPLACE(@gen_ds_paxape, '''', '''''') + ''', @in_edad = NULL, @ds_paxprefix= ''' + @gen_ds_paxprefix + ''', @ds_paxClasificacion = NULL, @cd_voucherpax=NULL, @cd_tiquete=NULL;'
						END;

						SET @SrvSqlStmt = @SrvCargSqlStmt + @SrvFpSqlStmt + @SrvProvSqlStmt;
						
						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) + '
						DECLARE @NewSrvId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Servicio_Vender
							@ds_descrip = ''' + ISNULL(@gen_ds_descrip, '') + ''',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@id_CotizacionServicios = NULL,
							@in_nacionalidad = ' + CAST(ISNULL(@gen_in_nacionalidad,1) AS VARCHAR) + ',
							@cd_cencosto = ' + CASE WHEN ISNULL(@gen_cd_cencosto, '')='' THEN 'NULL' ELSE '' + ISNULL(@gen_cd_cencosto, '') + '' END + ',
							@cd_auxiliar = ''' + ISNULL(@gen_cd_auxiliar, '') + ''',
							@cd_item = ''' + ISNULL(@gen_cd_item, '') + ''',
							@id_tiposconceptfac = ' + ISNULL(CAST(@gen_id_tiposconceptfac AS VARCHAR), 'NULL') + ',
							@id_conceptofacturacion = ' + ISNULL(CAST(@gen_id_conceptofacturacion AS VARCHAR), 'NULL') + ',
							@id_tiposservicio = ' + ISNULL(CAST(@gen_id_tiposservicio AS VARCHAR), 'NULL') + ',
							@cd_tiquete = ' + ISNULL('''' + @gen_cd_tiquete + '''', 'NULL') + ',
							@id_voucherstocks = NULL,
							@cd_voucherPrefijo = NULL,
							@cd_proveedores = ''' + ISNULL(@gen_cd_proveedores, '') + ''',
							@ds_tiposervnm = ''' + ISNULL(@gen_ds_tiposservicio, '') + ''',
							@cd_prov_hotel = NULL,
							@cd_prov_car = NULL,
							@cd_prov_air = NULL,
							@ds_servicio = ''' + ISNULL(@gen_ds_servicio, '') + ''',
							@am_valorprov = ' + CAST(ISNULL(@gen_am_tarifa,0) AS VARCHAR) + ',
							@id_monedaprov = ' + ISNULL(CAST(@id_monedas_iata AS VARCHAR), 'NULL') + ',
							@ds_InfoAdicional = NULL,
							@ds_paxname = ''' + ISNULL(@gen_ds_paxname, '') + ''',
							@ds_paxape = ''' + ISNULL(@gen_ds_paxape, '') + ''',
							@cd_paxtype = ''' + ISNULL(@gen_ds_paxprefix, '') + ''',
							@in_edad = NULL,
							@cd_voucher = NULL,
							@in_cantpax = 1,
							@dt_llegada = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@dt_salida = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@ds_destino = ''' + ISNULL(@gen_cd_destino, '') + ''',
							@id_gds = '+ CAST(ISNULL(@gen_id_gds,1) AS VARCHAR) + ',
							@am_basecomisionable = ' + CAST(ISNULL(@gen_am_basecomisionable,0) AS VARCHAR) + ',
							@am_porcomision = 0,
							@id_tipoplan = NULL,
							@id_acomodacion = NULL,
							@ds_paxClasificacion = NULL,
							@in_dias = NULL,
							@in_noches = NULL,
							@bl_notdomicilionacional=0,
							@CodigoReserva =''' + ISNULL(@gen_ds_records,'') + ''',
							@AnticiposSqlStmt = NULL,
							@PaxAdicionalSqlStmt = ''' + REPLACE(ISNULL(@SrvPaxSqlStmt,''), '''', '''''') + ''', 
							@VoucherAdicionalSqlStmt = NULL,
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@Id_GrConcepto = NULL,
							@in_diasSrv = NULL,
							@in_nochesSrv = NULL,
							@OrdenGrabacion = ' + CAST(@ItemIndex AS VARCHAR) + ',
							@Id_Especialista = NULL,
							@am_porcentaje_descuento = ' + CAST(ISNULL(@gen_am_pordescuento, 0) AS VARCHAR) + ',
							@am_valor_descuento = 0,
							@ds_motivo_descuento = NULL,
							@Id_CargosDesc_Descuento = NULL,
							@dt_FechaSalidaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@dt_FechaLlegadaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@cd_localizador = NULL,
							@cd_VoucherPax = NULL,
							@am_basecomisionableprov = ' + CAST(ISNULL(@gen_am_basecomisionable,0) AS VARCHAR) + ',
							@am_porcomisionprov = 0,
							@cd_NumeFac = NULL,
							@dt_VenceFac = NULL,
							@Id_AcomodacionSrv = NULL,
							@Id_TipoPlanSrv = NULL,
							@in_habitaciones = NULL,
							@in_habitacionesSrv = NULL,
							@SqlStmt = ''' + REPLACE(@SrvSqlStmt, '''', '''''') + ''',
							@cd_Consecutivo_variablesadicionales = ' + ISNULL('''' + @gen_cd_Consecutivo_variablesadicionales + '''', 'NULL') + ',
							@cd_confirmacion = NULL,
							@ds_confirmadopor = NULL,
							@cd_paxidentificacion = NULL,
							@bl_politicaCancelacion = 0,
							@dt_politicaCancelacion = NULL,
							@id_tipoHabitacion = NULL,
							@cd_Consecutivo_depende = ' + ISNULL('''' + @gen_cd_Consecutivo_depende + '''', 'NULL') + ',
							@id_TarjetaAsistencia = NULL,
							@id_Regiones = NULL,
							@Iden_GDS = NULL,
							@id_sys_entidades = 108,
							@ds_TipoAuto = NULL,
							@ds_Origen = NULL,
							@ds_DirOrigen = NULL,
							@ds_DirDestino = NULL,
							@ds_TipoTarifa = NULL,
							@am_ValorUSD = NULL,
							@ds_NoVuelo = NULL,
							@ds_Vehiculo = NULL,
							@ds_Placa = NULL,
							@ds_CategoriaVehiculo = NULL,
							@ds_NombreConductor = NULL,
							@ds_telefono = NULL,
							@ds_IdiomaConductor = NULL,
							@id_MonedaSrv = ' + ISNULL(CAST(@gen_id_monedaprov AS VARCHAR), 'NULL') + ',
							@id_TipoServicio = NULL,
							@id_Aerolinea = NULL,
							@am_PorFacParcial = 100,
							@ds_GDS = NULL,
							@am_basedescuento = ' + CAST(ISNULL(@gen_am_basedescuento, 0) AS VARCHAR) + ',
							@am_pordescuento = ' + CAST(ISNULL(@gen_am_pordescuento, 0) AS VARCHAR) + '; '

					END;
					SET @ItemIndex = @ItemIndex + 1;
					FETCH NEXT FROM curGenItems INTO 
						@gen_id_item, @gen_tipo_item, @gen_cd_tiquete, @gen_ds_descrip, @gen_in_nacionalidad, @gen_cd_cencosto, @gen_cd_auxiliar, @gen_cd_item, @gen_am_tarifa, @gen_am_iva, @gen_am_tua, @gen_am_comb, @gen_am_vat, @gen_am_Comision,
						@gen_ds_paxname, @gen_ds_paxape, @gen_ds_paxprefix, @gen_cd_tourcode, @gen_NumTktConj, @gen_cd_TipoTiquete, @gen_id_air, @gen_ds_itinerario, @gen_ds_itinerarioaerolinea, @gen_ds_clases, @gen_ds_Observaciones,
						@gen_am_highfare, @gen_am_lowfare, @gen_ds_solicita, @gen_ds_lapsoviaje, @gen_cd_tktrevisado, @gen_cd_PasaportePax, @gen_cd_pax_CC, @gen_am_PorFacParcial, @gen_in_cantpax, @gen_Id_Precompra,
						@gen_id_FormasPago, @gen_id_TarjetasCredito, @gen_id_sucursal, @gen_id_implante, @gen_bl_ahorro, @gen_cd_TipoTiqueteGDS, @gen_id_TiposDocumento, @gen_id_entdist, @gen_id_entvend,
						@gen_cd_destino, @gen_dt_fechaexped, @gen_id_tiqueteadores, @gen_id_gds, @gen_iden_gds, @gen_am_comisionPNR, @gen_ds_records, @gen_bl_NoCalcComision, @gen_bl_NoCalcIvaComision,
						@gen_am_basecomisionable, @gen_am_porcomision, @gen_id_tiposconceptfac, @gen_id_conceptofacturacion, @gen_id_tiposservicio, @gen_cd_proveedores, @gen_ds_servicio,
						@gen_am_valorprov, @gen_id_monedaprov, @gen_dt_llegada, @gen_dt_salida, @gen_am_pordescuento, @gen_Fecha_Salida, @gen_Fecha_Llegada, @gen_am_basedescuento, @gen_cd_Consecutivo_depende, @gen_cd_Consecutivo_variablesadicionales, @gen_id_referencia_origen, @gen_id_tipoproveedor, @gen_cd_tipoproveedor, @gen_ds_tipoproveedor;
				END;
				CLOSE curGenItems;
				DEALLOCATE curGenItems;
				
				-- Execute spza_Factura_Crear inside a TRY CATCH
				SET @FacturaRespuesta = NULL;
				SET @FacturaEstado = NULL;

				BEGIN TRY
					DECLARE @ReturnCode INT;
					DECLARE @FacturaExecSqlStmt NVARCHAR(MAX);

					DECLARE @ZML_VariablesStr VARCHAR(MAX) = NULL;
					SELECT 
						@ZML_VariablesStr = COALESCE(@ZML_VariablesStr + ' UNION ALL ', '') + 
						'SELECT ' + ISNULL('''' + REPLACE(cd_codigo, '''', '''''') + '''', 'NULL') + ' AS cd_items, NULL AS ds_Items, ' + 
						ISNULL('''' + REPLACE(ds_maestro, '''', '''''') + '''', 'NULL') + ' AS ds_Maestro, ' + 
						ISNULL('''' + REPLACE(ds_VariableAdicional, '''', '''''') + '''', 'NULL') + ' AS ds_Variable, ' + 
						ISNULL('''' + REPLACE(ds_valor, '''', '''''') + '''', 'NULL') + ' AS ds_Valor, ' +
						ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ' AS id_Clientes'
					FROM #VariablesAdicionales
					WHERE id_facturacion = @id_facturacion;

					SET @FacturaExecSqlStmt = N'
						EXEC @ReturnCode = ZeusAgencias_23.dbo.spza_Factura_Crear' + CHAR(13) + CHAR(10) +
							'@id_usuario = 1,' + CHAR(13) + CHAR(10) +
							'@id_sucursal = ' + ISNULL(CAST(@id_sucursal AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_implante = ' + ISNULL(CAST(@id_implante AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@dt_fechacont = ' + ISNULL('''' + CONVERT(VARCHAR, @FechaCont, 120) + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@dt_vence = ' + ISNULL('''' + CONVERT(VARCHAR, @FechaCont, 120) + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_tercero_codigo = ' + ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_tercero_nombre = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_cliente_codigo = ' + ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_nombre = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_dir = ' + ISNULL('''' + REPLACE(@ds_clidir, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_ciudad = ' + ISNULL('''' + REPLACE(@ds_clicity, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_tel = ' + ISNULL('''' + REPLACE(@ds_clitel, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_dirdesp = ' + ISNULL('''' + REPLACE(@ds_clidir, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_email = ' + ISNULL('''' + REPLACE(@ds_ClienteEmail, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_contacto = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_contacto_email = ' + ISNULL('''' + REPLACE(@ds_ClienteEmail, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_monedas_iata = ' + ISNULL(CAST(@id_monedas_iata AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_vendedor = ' + ISNULL('''' + REPLACE(@cd_vendedor, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_tiqueteador = ' + ISNULL(CAST(@id_tiqueteador AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@bn_anexo = NULL,' + CHAR(13) + CHAR(10) +
							'@Tcambio = ' + ISNULL(CAST(@am_TasaCambio AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@am_tcambiousd = ' + ISNULL(CAST(@am_tcambiousd AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_tipoventa = ' + ISNULL(CAST(@id_tipoventa AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_num_resolucion = '''',' + CHAR(13) + CHAR(10) +
							'@in_num_inicial = 0,' + CHAR(13) + CHAR(10) +
							'@in_num_final = 0,' + CHAR(13) + CHAR(10) +
							'@ds_numeracion_autorizada = NULL,' + CHAR(13) + CHAR(10) +
							'@dt_fecha_resolucion = NULL,' + CHAR(13) + CHAR(10) +
							'@CodigoArchivoFisico = '''',' + CHAR(13) + CHAR(10) +
							'@ds_Observacion = ' + ISNULL('''' + REPLACE(@ds_Observaciones, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_Campo_libre1 = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Campo_libre2 = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_fuente_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_serie_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_consecutivo_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Actividad_Economica = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Tarifa_ICA = NULL,' + CHAR(13) + CHAR(10) +
							'@SqlStmt = ' + ISNULL('''' + REPLACE(@SqlStmt, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@AnticiposSqlStmt = NULL,' + CHAR(13) + CHAR(10) +
							'@TotalFactura = ' + ISNULL(CAST(@ValorFactura AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@TotalCupoCreditoCliente = 0,' + CHAR(13) + CHAR(10) +
							'@bl_BloqueoCupoCredito = 0,' + CHAR(13) + CHAR(10) +
							'@bl_generadaauto = 1,' + CHAR(13) + CHAR(10) +
							'@ds_CotizacionesId = NULL,' + CHAR(13) + CHAR(10) +
							'@Id_Cierre = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_TipoFact = NULL,' + CHAR(13) + CHAR(10) +
							'@id_fac_remisionRelacionada = NULL,' + CHAR(13) + CHAR(10) +
							'@id_fac_facturaRelacionada = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_DescripcionFac = ' + ISNULL('''' + REPLACE(@ds_descripcion, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@bl_nocont = 0,' + CHAR(13) + CHAR(10) +
							'@ProductosSqlStmt = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_CF_TipoComprobante = NULL,' + CHAR(13) + CHAR(10) +
							'@id_Licitacion = ' + ISNULL(CAST(@cd_licitacion AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ValorFactura = ' + ISNULL(CAST(@ValorFactura AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_Especialista = NULL,' + CHAR(13) + CHAR(10) +
							'@id_tiqueteador_Facturador = NULL,' + CHAR(13) + CHAR(10) +
							'@id_TipoFormaPagoProveedor = NULL,' + CHAR(13) + CHAR(10) +
							'@id_MedioReservacion = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_refacturacion = 0,' + CHAR(13) + CHAR(10) +
							'@bl_comisiona = 0,' + CHAR(13) + CHAR(10) +
							'@cd_fuente_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_serie_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_consecutivo_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@id_NotasAerolinea = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_interface = 0,' + CHAR(13) + CHAR(10) +
							'@id_evento = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_NoEnviarFacElectronica = 0,' + CHAR(13) + CHAR(10) +
							'@bl_DescontarComisionCxP = 0,' + CHAR(13) + CHAR(10) +
							'@ds_num_resolucion_Adicional = '''',' + CHAR(13) + CHAR(10) +
							'@id_fac_facturaRefacturacion = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_refacturacion_contabilizar_saldos = 0,' + CHAR(13) + CHAR(10) +
							'@ZML_VariablesXML = @ZML_VariablesXML,' + CHAR(13) + CHAR(10) +
							'@bl_FormatoResumidoFactElectro = 0,' + CHAR(13) + CHAR(10) +
							'@bl_ExigeAdjuntoFactElectro = 0,' + CHAR(13) + CHAR(10) +
							'@bl_omitir_Validar_IVA_facturacion = 0,' + CHAR(13) + CHAR(10) +
							'@ZML_AjusteIvaXML = NULL;';
					
					EXEC sp_executesql @FacturaExecSqlStmt, 
						N'@ZML_VariablesXML VARCHAR(MAX), @FacturaRespuesta VARCHAR(8000) OUTPUT, @ReturnCode INT OUTPUT', 
						@ZML_VariablesXML = @ZML_VariablesStr,
						@FacturaRespuesta = @FacturaRespuesta OUTPUT, 
						@ReturnCode = @ReturnCode OUTPUT;
					
					IF @ReturnCode = 0
					BEGIN
						SET @FacturaEstado = 0;
					END
					ELSE
					BEGIN
						SET @FacturaEstado = 1;
						IF @FacturaRespuesta IS NULL OR LTRIM(RTRIM(@FacturaRespuesta)) = ''
						BEGIN
							SET @FacturaRespuesta = 'Error en spFacturaCrear (Código de retorno: ' + CAST(ISNULL(@ReturnCode, 1) AS VARCHAR) + ')';
						END;
						SET @FacturaRespuesta = @FacturaRespuesta + CHAR(13) + CHAR(10) + '--- DYNAMIC EXECUTION TRACE ---' + CHAR(13) + CHAR(10) + ISNULL(@FacturaExecSqlStmt, '');
					END
				END TRY
				BEGIN CATCH
					SET @FacturaEstado = 1;
					DECLARE @ErrNum INT = ERROR_NUMBER();
					DECLARE @ErrLine INT = ERROR_LINE();
					DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
					DECLARE @ErrProc NVARCHAR(128) = ERROR_PROCEDURE();
					SET @FacturaRespuesta = '❌ Error ' + CAST(@ErrNum AS VARCHAR) + ' (Línea ' + CAST(@ErrLine AS VARCHAR) + ' en ' + ISNULL(@ErrProc, 'spFacturaCrear') + '): ' + ISNULL(@ErrMsg, 'Error no especificado') + CHAR(13) + CHAR(10) + '--- DYNAMIC EXECUTION TRACE ---' + CHAR(13) + CHAR(10) + ISNULL(@FacturaExecSqlStmt, '');
				END CATCH
				-- Collect log result
				INSERT INTO @LogResults (invoiceId, success, message)
				VALUES (@id_facturacion, CASE WHEN @FacturaEstado = 0 THEN 1 ELSE 0 END, @FacturaRespuesta);

				FETCH NEXT FROM curInvoices INTO @cd_fuente,@cd_serie,@cd_consecutivo,@id_facturacion;
			END;

			CLOSE curInvoices;
			DEALLOCATE curInvoices;
			
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
			
			SELECT invoiceId, success, message FROM @LogResults;
			RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT,
            @ErrorLine INT,
            @ErrorNumber INT,
            @ErrorProc NVARCHAR(128);

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorLine = ERROR_LINE(),
            @ErrorNumber = ERROR_NUMBER(),
            @ErrorProc = ERROR_PROCEDURE();

        DECLARE @FullErrorMsg NVARCHAR(4000) = '❌ Error ' + CAST(ISNULL(@ErrorNumber,0) AS NVARCHAR) + ' (Línea ' + CAST(ISNULL(@ErrorLine,0) AS NVARCHAR) + ' de ' + ISNULL(@ErrorProc, 'spFacturacionesCrear') + '): ' + ISNULL(@ErrorMessage, 'Error no especificado');

        RAISERROR (@FullErrorMsg, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO;

-- Inyectado automáticamente: spImplantCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImplantCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImplantCrear(
    p_code TEXT,
    p_name TEXT,
    p_logo BYTEA,
    p_template BYTEA,
    p_template_config JSONB,
    p_html_template TEXT,
    p_branch_id INT,
    p_resolution_id INT DEFAULT NULL,
    p_invoice_template BYTEA DEFAULT NULL,
    p_invoice_template_config JSONB DEFAULT NULL,
    p_invoice_html_template TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_implant_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Implant" (
        "code", "name", "logo", "template", "templateConfig", "htmlTemplate", "branchId",
        "resolutionId", "invoiceTemplate", "invoiceTemplateConfig", "invoiceHtmlTemplate", "isActive"
    )
    VALUES (
        p_code, p_name, p_logo, p_template, p_template_config, p_html_template, p_branch_id,
        p_resolution_id, p_invoice_template, p_invoice_template_config, p_invoice_html_template, COALESCE(p_is_active, true)
    )
    RETURNING id INTO p_implant_id;

    p_mensaje_resultado := 'SUCCESS: Implant creado con ID ' || p_implant_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spImplantEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImplantEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImplantEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Implant" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Implant con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."Implant" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Implant eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spImportInvoices.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImportInvoices'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spImportInvoices"(
    IN p_text_data TEXT,
    IN p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de facturas desde TEXTO PLANO DELIMITADO con soporte para pagos e itinerarios.
    Formato esperado: 40 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_invoice_record RECORD;
    v_product_record RECORD;
    v_invoice_id INT;
    v_ip_id INT;
    v_internal_number TEXT;
    v_client_id INT;
    v_branch_id INT;
    v_implant_id INT;
    v_seller_id INT;
    v_ticket_printer_id INT;
    v_product_id INT;
    v_provider_id INT;
    v_prestadora_id INT;
    v_tax_id INT;
    v_main_tax_id INT;
    v_variable_id INT;
    v_ticket_type_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_pay_item TEXT;
    v_pay_parts TEXT[];
    v_pay_method TEXT;
    v_pay_ref TEXT;
    v_pay_date TIMESTAMP;
    v_pay_card_id INT;
    v_pay_card_num TEXT;
    v_pay_auth TEXT;
    v_pay_voucher TEXT;
    v_pay_exp TEXT;
    v_itin_item TEXT;
    v_itin_parts TEXT[];
    v_itin_origin TEXT;
    v_itin_dest TEXT;
    v_itin_class TEXT;
    v_itin_check_in TIMESTAMP;
    v_itin_check_out TIMESTAMP;
    v_itin_orden INT;
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_invoice_rows (
        row_id INT GENERATED ALWAYS AS IDENTITY, --0
        grupo TEXT, --1
        cliente_doc TEXT, --2
        sucursal_cd TEXT, --3
        implant_cd TEXT, --4
        vendedor_cd TEXT, --5
        tiqueteador_cd TEXT, --6
        moneda TEXT, --7
        tasa_cambio DECIMAL, -- 8
        comision_global DECIMAL, -- 9
        cargos_global DECIMAL, --10
        producto_cd TEXT, --11
        proveedor_nm TEXT, --12 
        proveedor_cd TEXT, --13
        prestadora_cd TEXT, --14
        impuestos_str TEXT, --15
        variables_str TEXT, --16
        pasajeros_str TEXT, --17
        precio DECIMAL, --18
        cantidad INT, --19
        check_in TIMESTAMP, --20
        check_out TIMESTAMP, --21
        pax_adultos INT, --22
        pax_ninos INT, --23
        destino TEXT, --24
        tipo_servicio TEXT, --25
        reserva TEXT, --26
        com_vendedor DECIMAL, --27
        com_tiqueteador DECIMAL, --28
        combos_str TEXT, --29
        nacionalidad INT DEFAULT 1, --30
        cargo_principal_cd TEXT, --31
        costo DECIMAL DEFAULT 0, --32
        servicios TEXT, --33
        descripcion TEXT, --34
        itinerary TEXT, --35
        class TEXT, --36
        airline TEXT, --37
        tipo_tiquete_cd TEXT, --38
        pagos_str TEXT, --39
        itinerarios_str TEXT, --40
        fuente TEXT, --41
        serie TEXT, --42
        consecutivo TEXT --43
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_invoice_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            -- Validar formato de Check-In (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[20]) <> '' AND REPLACE(TRIM(v_cols[20]), '/', '-') !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [CheckIn]): Formato de fecha incorrecto. Valor recibido: "' || TRIM(v_cols[20]) || '". Ejemplo de formato correcto: 2026-10-01 (o 2026/10/01)';
                RETURN;
            END IF;

            -- Validar formato de Check-Out (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[21]) <> '' AND REPLACE(TRIM(v_cols[21]), '/', '-') !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [CheckOut]): Formato de fecha incorrecto. Valor recibido: "' || TRIM(v_cols[21]) || '". Ejemplo de formato correcto: 2026-10-10 (o 2026/10/10)';
                RETURN;
            END IF;
            
            INSERT INTO tmp_import_invoice_rows (
                grupo, cliente_doc, sucursal_cd, implant_cd, vendedor_cd, tiqueteador_cd,
                moneda, tasa_cambio, comision_global, cargos_global, producto_cd,
                proveedor_nm, proveedor_cd, prestadora_cd, impuestos_str, variables_str,
                pasajeros_str, precio, cantidad, check_in, check_out, pax_adultos, pax_ninos,
                destino, tipo_servicio, reserva, com_vendedor, com_tiqueteador, combos_str,
                nacionalidad, cargo_principal_cd, costo, servicios, descripcion, itinerary,
                class, airline, tipo_tiquete_cd, pagos_str, itinerarios_str,
                fuente, serie, consecutivo
            ) VALUES (
                TRIM(v_cols[1]), -- grupo 
                TRIM(v_cols[2]), -- cliente_doc 
                TRIM(v_cols[3]), -- sucursal_cd
                TRIM(v_cols[4]), -- implant_cd
                TRIM(v_cols[5]), -- vendedor_cd
                TRIM(v_cols[6]), -- tiqueteador_cd
                TRIM(v_cols[7]), -- moneda
                CASE WHEN TRIM(v_cols[8]) = '' THEN NULL WHEN POSITION(':' IN v_cols[8]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[8]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[8]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- tasa_cambio
                CASE WHEN TRIM(v_cols[9]) = '' THEN NULL WHEN POSITION(':' IN v_cols[9]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[9]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[9]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision_global
                CASE WHEN TRIM(v_cols[10]) = '' THEN NULL WHEN POSITION(':' IN v_cols[10]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[10]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[10]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- cargos_global
                TRIM(v_cols[11]), -- Producto Codigo
                TRIM(v_cols[12]), -- Prov Nombre
                TRIM(v_cols[13]), -- Prov Codigo
                TRIM(v_cols[14]), -- Prestadora Codigo
                COALESCE(NULLIF(TRIM(v_cols[15]), ''), CASE WHEN POSITION(':' IN v_cols[10]) > 0 THEN TRIM(v_cols[10]) ELSE '' END), -- Impuestos
                TRIM(v_cols[16]), -- Variables
                TRIM(v_cols[17]), -- Pasajeros
                CASE WHEN TRIM(v_cols[18]) = '' THEN NULL WHEN POSITION(':' IN v_cols[18]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[18]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[18]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- precio
                CASE WHEN TRIM(v_cols[19]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[19]), '[^0-9]', '', 'g'), '')::INT END, -- cantidad
                CASE WHEN TRIM(v_cols[20]) <> '' THEN REPLACE(TRIM(v_cols[20]), '/', '-')::TIMESTAMP ELSE NULL END, -- check_in
                CASE WHEN TRIM(v_cols[21]) <> '' THEN REPLACE(TRIM(v_cols[21]), '/', '-')::TIMESTAMP ELSE NULL END, -- check_out
                CASE WHEN TRIM(v_cols[22]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[22]), '[^0-9]', '', 'g'), '')::INT END, -- pax_adultos
                CASE WHEN TRIM(v_cols[23]) = '' THEN NULL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[23]), '[^0-9]', '', 'g'), '')::INT END, -- pax_ninos
                TRIM(v_cols[24]), -- destino
                TRIM(v_cols[25]), -- tipo_servicio
                TRIM(v_cols[26]), -- reserva 
                CASE WHEN TRIM(v_cols[27]) = '' THEN NULL WHEN POSITION(':' IN v_cols[27]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[27]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[27]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision vendedor
                CASE WHEN TRIM(v_cols[28]) = '' THEN NULL WHEN POSITION(':' IN v_cols[28]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[28]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[28]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- comision tiqueteador
                TRIM(v_cols[29]), -- codigo combos
                COALESCE(NULLIF(REGEXP_REPLACE(TRIM(v_cols[30]), '[^0-9]', '', 'g'), '')::INT, 1), -- nacionalidad
                TRIM(v_cols[31]), -- cargo_principal_cd
                CASE WHEN TRIM(v_cols[32]) = '' THEN NULL WHEN POSITION(':' IN v_cols[32]) > 0 THEN NULLIF(REGEXP_REPLACE(SPLIT_PART(TRIM(v_cols[32]), ':', 2), '[^0-9.-]', '', 'g'), '')::DECIMAL ELSE NULLIF(REGEXP_REPLACE(TRIM(v_cols[32]), '[^0-9.-]', '', 'g'), '')::DECIMAL END, -- costo
                TRIM(v_cols[33]), -- servicios
                TRIM(v_cols[34]), -- descripcion
                TRIM(v_cols[35]), -- itinerary
                TRIM(v_cols[36]), -- class
                TRIM(v_cols[37]), -- airline
                TRIM(v_cols[38]),  -- tipo_tiquete_cd
                TRIM(v_cols[39]),  -- pagos_str
                TRIM(v_cols[40]),  -- itinerarios_str
                TRIM(v_cols[41]),  -- fuente
                TRIM(v_cols[42]),  -- serie
                TRIM(v_cols[43])   -- consecutivo
            );
        EXCEPTION WHEN OTHERS THEN
            DECLARE
                v_err_col TEXT := '';
                v_example TEXT := '';
            BEGIN
                IF SQLERRM LIKE '%numeric%' OR SQLERRM LIKE '%numérico%' THEN
                    IF TRIM(v_cols[8]) <> '' AND TRIM(v_cols[8]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Tasa_Cambio])'; v_example := '. Ejemplo de formato correcto: 4000 o 1';
                    ELSIF TRIM(v_cols[9]) <> '' AND TRIM(v_cols[9]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Global_Pct])'; v_example := '. Ejemplo de formato correcto: 10 o 0';
                    ELSIF TRIM(v_cols[10]) <> '' AND TRIM(v_cols[10]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Cargos_A_Factura])'; v_example := '. Ejemplo de formato correcto: 20000 o TAR:20000';
                    ELSIF TRIM(v_cols[18]) <> '' AND TRIM(v_cols[18]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Precio_Unitario])'; v_example := '. Ejemplo de formato correcto: 100000 o 100000.50';
                    ELSIF TRIM(v_cols[19]) <> '' AND TRIM(v_cols[19]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Cantidad])'; v_example := '. Ejemplo de formato correcto: 1 o 2';
                    ELSIF TRIM(v_cols[22]) <> '' AND TRIM(v_cols[22]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Pax_Adultos])'; v_example := '. Ejemplo de formato correcto: 1 o 2';
                    ELSIF TRIM(v_cols[23]) <> '' AND TRIM(v_cols[23]) !~ '^\d+$' THEN 
                        v_err_col := ' (Columna [Pax_Ninos])'; v_example := '. Ejemplo de formato correcto: 0 o 1';
                    ELSIF TRIM(v_cols[27]) <> '' AND TRIM(v_cols[27]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Vendedor_Producto])'; v_example := '. Ejemplo de formato correcto: 5.0 o 0';
                    ELSIF TRIM(v_cols[28]) <> '' AND TRIM(v_cols[28]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Comision_Tiqueteador_Producto])'; v_example := '. Ejemplo de formato correcto: 2.0 o 0';
                    ELSIF TRIM(v_cols[32]) <> '' AND TRIM(v_cols[32]) !~ '^-?\d+(\.\d+)?$' THEN 
                        v_err_col := ' (Columna [Costo])'; v_example := '. Ejemplo de formato correcto: 80000 u 80000.0';
                    END IF;
                END IF;
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || v_err_col || ': ' || SQLERRM || v_example || ' (Valor: ' || v_row_text || ')';
                RETURN;
            END;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos de Facturas
    FOR v_invoice_record IN (
        SELECT grupo, 
               MAX(cliente_doc) as cliente_doc, 
               MAX(sucursal_cd) as sucursal_cd, 
               MAX(implant_cd) as implant_cd, 
               MAX(vendedor_cd) as vendedor_cd, 
               MAX(tiqueteador_cd) as tiqueteador_cd, 
               MAX(moneda) as moneda, 
               MAX(tasa_cambio) as tasa_cambio, 
               MAX(comision_global) as comision_global, 
               MAX(cargos_global) as cargos_global,
               MAX(combos_str) as combos_str,
               MAX(fuente) as fuente,
               MAX(serie) as serie,
               MAX(consecutivo) as consecutivo
        FROM tmp_import_invoice_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_invoice_record.cliente_doc OR LOWER(code) = LOWER(v_invoice_record.cliente_doc);
        IF v_client_id IS NULL THEN 
            IF EXISTS (SELECT 1 FROM public."Provider" WHERE document = v_invoice_record.cliente_doc OR LOWER(code) = LOWER(v_invoice_record.cliente_doc) OR LOWER(name) = LOWER(v_invoice_record.cliente_doc)) THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Cliente_Documento]): El valor "' || v_invoice_record.cliente_doc || '" corresponde a un PROVEEDOR (ej: NIT Avianca/Aerolínea), no a un Cliente. Por favor especifique un documento o código de Cliente en esta columna (ej: 79898456 o CLI-001).';
            ELSE
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Cliente_Documento]): Cliente con documento o código "' || v_invoice_record.cliente_doc || '" no encontrado en el sistema. Ejemplo de valor correcto: Cédula o NIT registrado en Maestros -> Clientes (ej: 79898456 o CLI-001)';
            END IF;
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_invoice_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ' (Columna [Sucursal_Codigo]): Sucursal con código "' || v_invoice_record.sucursal_cd || '" no encontrada en el sistema. Ejemplo de valor correcto: Código registrado en Maestros -> Sucursales (ej: BOG01 o MED01)';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_invoice_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_invoice_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_invoice_record.tiqueteador_cd);

        -- Asignar número consecutivo interno
        IF v_invoice_record.consecutivo IS NOT NULL AND TRIM(v_invoice_record.consecutivo) <> '' THEN
            v_internal_number := COALESCE(NULLIF(TRIM(COALESCE(v_invoice_record.serie, '') || '-' || v_invoice_record.consecutivo), '-'), v_invoice_record.consecutivo);
        ELSE
            SELECT x.v_consec_json->>'formattedConsecutive' INTO v_internal_number
            FROM (SELECT public."fnObtenerSiguienteConsecutivo"('INVOICE', v_branch_id, v_implant_id) AS v_consec_json) x;

            IF v_internal_number IS NULL OR v_internal_number = '' THEN
                v_internal_number := 'FAC-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;
            END IF;
        END IF;

        INSERT INTO public."Invoices" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId", "state",
            "fuente", "serie", "consecutivo"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_invoice_record.moneda, 'COP'), 
            COALESCE(v_invoice_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_invoice_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_invoice_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id, 'NUEVO',
            v_invoice_record.fuente, v_invoice_record.serie, v_invoice_record.consecutivo
        ) RETURNING id INTO v_invoice_id;

        v_created_ids := v_created_ids || v_internal_number || ', ';

        v_total_amount := COALESCE(v_invoice_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_invoice_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId") VALUES (v_invoice_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."InvoicesProduct" (
                                "invoiceId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_invoice_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_ip_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."InvoicesProductTax" (
                                "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_ip_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
                                   ROUND(cpt.amount::numeric, v_decimals)::double precision, cpt."isMain"
                            FROM public."ComboProductTax" cpt
                            JOIN public."ChargeAndTax" ct ON cpt."chargeAndTaxId" = ct.id
                            WHERE cpt."comboProductId" = v_cp_record.id;
                            
                            -- Sumar impuestos al total
                            v_total_amount := v_total_amount + COALESCE((SELECT SUM(amount) FROM public."ComboProductTax" WHERE "comboProductId" = v_cp_record.id), 0);
                        END LOOP;
                    END IF;
                END;
            END LOOP;
        END IF;

        -- Procesar Productos Individuales
        FOR v_product_record IN (SELECT * FROM tmp_import_invoice_rows WHERE grupo = v_invoice_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN 
                DECLARE
                    v_temp_msg TEXT;
                BEGIN
                    CALL public.spProductoCrear(
                        v_product_record.producto_cd,
                        COALESCE(v_product_record.tipo_servicio, 'Tiquete'),
                        COALESCE(v_product_record.descripcion, 'Tiquete ' || v_product_record.producto_cd),
                        COALESCE(v_product_record.precio, 0),
                        COALESCE(v_product_record.costo, 0),
                        NULL, 
                        COALESCE(v_product_record.tipo_servicio, 'Aire'),
                        p_user_id,
                        v_product_id,
                        v_temp_msg
                    );
                    IF v_temp_msg LIKE 'ERROR%' THEN
                        p_mensaje_resultado := v_temp_msg;
                        RETURN;
                    END IF;
                END;
            END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            SELECT id INTO v_prestadora_id FROM public."Prestadora" WHERE LOWER(code) = LOWER(v_product_record.prestadora_cd);

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_ticket_type_id := NULL;
            IF v_product_record.tipo_tiquete_cd <> '' THEN
                SELECT id INTO v_ticket_type_id FROM public."TicketType" WHERE LOWER(code) = LOWER(v_product_record.tipo_tiquete_cd);
            END IF;

            v_ip_id := NULL;
            SELECT id INTO v_ip_id FROM public."InvoicesProduct" 
            WHERE "invoiceId" = v_invoice_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_ip_id IS NOT NULL THEN
                UPDATE public."InvoicesProduct" SET
                    "quantity" = COALESCE(v_product_record.cantidad, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "cost" = ROUND(COALESCE(v_product_record.costo, "cost")::numeric, v_decimals)::double precision,
                    "providerId" = COALESCE(v_provider_id, "providerId"),
                    "prestadoraId" = COALESCE(v_prestadora_id, "prestadoraId"),
                    "checkInDate" = COALESCE(v_product_record.check_in, "checkInDate"),
                    "checkOutDate" = COALESCE(v_product_record.check_out, "checkOutDate"),
                    "nights" = CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                                 THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                                 ELSE "nights" END,
                    "paxAdults" = COALESCE(v_product_record.pax_adultos, "paxAdults"),
                    "paxChildren" = COALESCE(v_product_record.pax_ninos, "paxChildren"),
                    "serviceType" = COALESCE(v_product_record.tipo_servicio, "serviceType"),
                    "destination" = COALESCE(v_product_record.destino, "destination"),
                    "reservationCode" = COALESCE(v_product_record.reserva, "reservationCode"),
                    "sellerCommission" = ROUND(COALESCE(v_product_record.com_vendedor, "sellerCommission")::numeric, v_decimals)::double precision,
                    "ticketPrinterCommission" = ROUND(COALESCE(v_product_record.com_tiqueteador, "ticketPrinterCommission")::numeric, v_decimals)::double precision,
                    "inNationality" = COALESCE(v_product_record.nacionalidad, "inNationality"),
                    "mainTaxId" = COALESCE(v_main_tax_id, "mainTaxId"),
                    "servicios" = COALESCE(v_product_record.servicios, "servicios"),
                    "descripcion" = COALESCE(v_product_record.descripcion, "descripcion"),
                    "itinerary" = COALESCE(v_product_record.itinerary, "itinerary"),
                    "class" = COALESCE(v_product_record.class, "class"),
                    "airline" = COALESCE(v_product_record.airline, "airline"),
                    "ticketTypeId" = COALESCE(v_ticket_type_id, "ticketTypeId")
                WHERE id = v_ip_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."InvoicesProductTax" WHERE "invoiceProductId" = v_ip_id;
                END IF;
            ELSE
                IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."InvoicesProduct" (
                    "invoiceId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "comboId", "mainTaxId", "inNationality", "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
                ) VALUES (
                    v_invoice_id, v_product_id, COALESCE(v_product_record.cantidad, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.costo, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    NULL, v_main_tax_id, COALESCE(v_product_record.nacionalidad, 1),
                    v_product_record.servicios, v_product_record.descripcion, v_product_record.itinerary, v_product_record.class, v_product_record.airline, v_ticket_type_id
                ) RETURNING id INTO v_ip_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.cantidad, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductTax" (
                            "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                        ) 
                        SELECT v_ip_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision,
                               CASE WHEN v_main_tax_id = id THEN TRUE ELSE FALSE END
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                    VALUES (v_ip_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                        VALUES (v_ip_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pagos
            IF v_product_record.pagos_str IS NOT NULL AND v_product_record.pagos_str <> '' THEN
                FOREACH v_pay_item IN ARRAY string_to_array(v_product_record.pagos_str, '|') LOOP
                    v_pay_parts := string_to_array(v_pay_item, ':');
                    
                    v_pay_method := NULLIF(TRIM(v_pay_parts[2]), '');
                    v_pay_ref := NULLIF(TRIM(v_pay_parts[3]), '');
                    
                    v_pay_date := CURRENT_TIMESTAMP;
                    IF v_pay_parts[4] IS NOT NULL AND TRIM(v_pay_parts[4]) <> '' THEN
                        v_pay_date := TRIM(v_pay_parts[4])::TIMESTAMP;
                    END IF;

                    v_pay_card_id := NULL;
                    IF v_pay_parts[5] IS NOT NULL AND TRIM(v_pay_parts[5]) <> '' THEN
                        v_pay_card_id := TRIM(v_pay_parts[5])::INT;
                    END IF;

                    v_pay_card_num := NULLIF(TRIM(v_pay_parts[6]), '');
                    v_pay_auth := NULLIF(TRIM(v_pay_parts[7]), '');
                    v_pay_voucher := NULLIF(TRIM(v_pay_parts[8]), '');
                    v_pay_exp := NULLIF(TRIM(v_pay_parts[9]), '');

                    INSERT INTO public."InvoicesProductPayment" (
                        "invoiceProductId", "amount", "paymentMethod", "reference", "date", 
                        "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                    ) VALUES (
                        v_ip_id, 
                        ROUND(NULLIF(TRIM(v_pay_parts[1]), '')::numeric, v_decimals)::double precision, 
                        v_pay_method, 
                        v_pay_ref, 
                        v_pay_date, 
                        v_pay_card_id, 
                        v_pay_card_num, 
                        v_pay_auth, 
                        v_pay_voucher, 
                        v_pay_exp
                    );
                END LOOP;
            END IF;

            -- Split para Itinerarios
            IF v_product_record.itinerarios_str IS NOT NULL AND v_product_record.itinerarios_str <> '' THEN
                FOREACH v_itin_item IN ARRAY string_to_array(v_product_record.itinerarios_str, '|') LOOP
                    v_itin_parts := string_to_array(v_itin_item, ':');
                    
                    v_itin_origin := NULLIF(TRIM(v_itin_parts[1]), '');
                    v_itin_dest := NULLIF(TRIM(v_itin_parts[2]), '');
                    v_itin_class := NULLIF(TRIM(v_itin_parts[3]), '');
                    
                    v_itin_check_in := NULL;
                    IF v_itin_parts[4] IS NOT NULL AND TRIM(v_itin_parts[4]) <> '' THEN
                        v_itin_check_in := TRIM(v_itin_parts[4])::TIMESTAMP;
                    END IF;

                    v_itin_check_out := NULL;
                    IF v_itin_parts[5] IS NOT NULL AND TRIM(v_itin_parts[5]) <> '' THEN
                        v_itin_check_out := TRIM(v_itin_parts[5])::TIMESTAMP;
                    END IF;

                    v_itin_orden := NULL;
                    IF v_itin_parts[6] IS NOT NULL AND TRIM(v_itin_parts[6]) <> '' THEN
                        v_itin_orden := TRIM(v_itin_parts[6])::INT;
                    END IF;

                    INSERT INTO public."InvoicesProductItinerary" (
                        "invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "orden"
                    ) VALUES (
                        v_ip_id, 
                        v_itin_origin, 
                        v_itin_dest, 
                        v_itin_class, 
                        v_itin_check_in, 
                        v_itin_check_out, 
                        v_itin_orden
                    );
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en InvoicesProductTax
        UPDATE public."Invoices"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(ipt."explicitAmount"), 0) AS cargos_global
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = v_invoice_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_invoice_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' facturas importadas. [' || RTRIM(v_created_ids, ', ') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;;

-- Inyectado automáticamente: spImportQuotation.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImportQuotation'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spImportQuotation"(
    IN p_text_data TEXT,
    IN p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de cotizaciones desde TEXTO PLANO DELIMITADO.
    Formato esperado: 28 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_quotation_record RECORD;
    v_product_record RECORD;
    v_quotation_id INT;
    v_qp_id INT;
    v_internal_number TEXT;
    v_client_id INT;
    v_branch_id INT;
    v_implant_id INT;
    v_seller_id INT;
    v_ticket_printer_id INT;
    v_product_id INT;
    v_provider_id INT;
    v_prestadora_id INT;
    v_tax_id INT;
    v_main_tax_id INT;
    v_variable_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_rows (
        row_id INT GENERATED ALWAYS AS IDENTITY, --0
        grupo TEXT, --1
        cliente_doc TEXT, --2
        sucursal_cd TEXT, --3
        implant_cd TEXT, --4
        vendedor_cd TEXT, --5
        tiqueteador_cd TEXT, --6
        moneda TEXT, --7
        tasa_cambio DECIMAL, -- 8
        comision_global DECIMAL, -- 9
        cargos_global DECIMAL, --10
        producto_cd TEXT, --11
        proveedor_nm TEXT, --12 
        proveedor_cd TEXT, --13
        prestadora_cd TEXT, --14
        impuestos_str TEXT, --15
        variables_str TEXT, --16
        pasajeros_str TEXT, --17
        precio DECIMAL, --18
        cantidad INT, --19
        check_in TIMESTAMP, --20
        check_out TIMESTAMP, --21
        pax_adultos INT, --22
        pax_ninos INT, --23
        destino TEXT, --24
        tipo_servicio TEXT, --25
        reserva TEXT, --26
        com_vendedor DECIMAL, --27
        com_tiqueteador DECIMAL, --28
        combos_str TEXT, --29
        nacionalidad INT DEFAULT 1, --30
        cargo_principal_cd TEXT, --31
		cost DECIMAL DEFAULT 0--32
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            -- Validar formato de Check-In (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[20]) <> '' AND TRIM(v_cols[20]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-In. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[20]);
                RETURN;
            END IF;

            -- Validar formato de Check-Out (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[21]) <> '' AND TRIM(v_cols[21]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-Out. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[21]);
                RETURN;
            END IF;
            
            INSERT INTO tmp_import_rows (
                grupo, -- 1
				cliente_doc, -- 2 
				sucursal_cd, -- 3
				implant_cd, -- 4
				vendedor_cd, -- 5
				tiqueteador_cd, -- 6
                moneda, -- 7
				tasa_cambio, -- 8 
				comision_global, -- 9
				cargos_global, -- 10
				producto_cd, -- 11
                proveedor_nm, -- 12
				proveedor_cd, -- 13
				prestadora_cd, -- 14
				impuestos_str, -- 15
				variables_str, -- 16
				pasajeros_str, -- 17
                precio, -- 18
				cantidad, -- 19
				check_in, -- 20
				check_out, -- 21
				pax_adultos, -- 22
				pax_ninos, -- 23
                destino, -- 24
				tipo_servicio, -- 25
				reserva, -- 26
				com_vendedor, -- 27 
				com_tiqueteador, -- 28
                combos_str, -- 29
				nacionalidad, -- 30
				cargo_principal_cd, -- 31
				cost -- 32
            ) VALUES (
                TRIM(v_cols[1]), -- grupo 
				TRIM(v_cols[2]), -- cliente_doc 
				TRIM(v_cols[3]), -- sucursal_cd
				TRIM(v_cols[4]), -- implant_cd
				TRIM(v_cols[5]), -- vendedor_cd
				TRIM(v_cols[6]), -- tiqueteador_cd
                TRIM(v_cols[7]), -- moneda
				NULLIF(TRIM(v_cols[8]), '')::DECIMAL, -- tasa_cambio
				NULLIF(TRIM(v_cols[9]), '')::DECIMAL, -- comision_global
                NULLIF(TRIM(v_cols[10]), '')::DECIMAL, --cargos_global
				TRIM(v_cols[11]), -- Producto Codigo
                TRIM(v_cols[12]), -- Prov Nombre
                TRIM(v_cols[13]), -- Prov Codigo
                TRIM(v_cols[14]), -- Prestadora Codigo
                TRIM(v_cols[15]), -- Vars
				TRIM(v_cols[16]), -- Impuestos
				TRIM(v_cols[17]), -- Pasajeros
                NULLIF(TRIM(v_cols[18]), '')::DECIMAL, -- precio
				NULLIF(TRIM(v_cols[19]), '')::INT, -- cantidad
                CASE WHEN TRIM(v_cols[20]) <> '' THEN TRIM(v_cols[20])::TIMESTAMP ELSE NULL END, -- check_in
                CASE WHEN TRIM(v_cols[21]) <> '' THEN TRIM(v_cols[21])::TIMESTAMP ELSE NULL END, -- check_out
                NULLIF(TRIM(v_cols[22]), '')::INT, -- pax_adultos
				NULLIF(TRIM(v_cols[23]), '')::INT, -- pax_ninos
                TRIM(v_cols[24]), -- destino
				TRIM(v_cols[25]), -- tipo_servicio
				TRIM(v_cols[26]), -- reserva 
				NULLIF(TRIM(v_cols[27]), '')::DECIMAL, -- comision vendedor
				NULLIF(TRIM(v_cols[28]), '')::DECIMAL, -- comision tiqueteador
                TRIM(v_cols[29]), -- codigo combos
				COALESCE(NULLIF(TRIM(v_cols[30]), '')::INT, 1), -- nacionalidad
                TRIM(v_cols[31]), --cargo_principal_cd
				NULLIF(TRIM(v_cols[32]), '')::DECIMAL --costo
            );
        EXCEPTION WHEN OTHERS THEN
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': ' || SQLERRM || ' (Valor: ' || v_row_text || ')';
            RETURN;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos
    FOR v_quotation_record IN (
        SELECT grupo, 
               MAX(cliente_doc) as cliente_doc, 
               MAX(sucursal_cd) as sucursal_cd, 
               MAX(implant_cd) as implant_cd, 
               MAX(vendedor_cd) as vendedor_cd, 
               MAX(tiqueteador_cd) as tiqueteador_cd, 
               MAX(moneda) as moneda, 
               MAX(tasa_cambio) as tasa_cambio, 
               MAX(comision_global) as comision_global, 
               MAX(cargos_global) as cargos_global,
               MAX(combos_str) as combos_str
        FROM tmp_import_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_quotation_record.cliente_doc;
        IF v_client_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Cliente con documento o código "' || v_quotation_record.cliente_doc || '" no encontrado en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_quotation_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Sucursal con código "' || v_quotation_record.sucursal_cd || '" no encontrada en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_quotation_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_quotation_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_quotation_record.tiqueteador_cd);

        -- Obtener decimales de la moneda
        v_decimals := public.fn_obtener_decimales_moneda(COALESCE(v_quotation_record.moneda, 'COP'));

        v_internal_number := 'QUO-SP-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;

        RAISE NOTICE 'DEBUG: moneda=%, tasa=%, seller=%', v_quotation_record.moneda, v_quotation_record.tasa_cambio, v_quotation_record.vendedor_cd;
        INSERT INTO public."Quotation" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_quotation_record.moneda, 'COP'), 
            COALESCE(v_quotation_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_quotation_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_quotation_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id
        ) RETURNING id INTO v_quotation_id;

        v_created_ids := v_created_ids || v_quotation_id || ',';

        v_total_amount := COALESCE(v_quotation_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_quotation_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."QuotationCombo" ("quotationId", "comboId") VALUES (v_quotation_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."QuotationProduct" (
                                "quotationId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_quotation_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_qp_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."QuotationProductTax" (
                                "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_qp_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
                                   ROUND(cpt.amount::numeric, v_decimals)::double precision, cpt."isMain"
                            FROM public."ComboProductTax" cpt
                            JOIN public."ChargeAndTax" ct ON cpt."chargeAndTaxId" = ct.id
                            WHERE cpt."comboProductId" = v_cp_record.id;
                            
                            -- Sumar impuestos al total
                            v_total_amount := v_total_amount + COALESCE((SELECT SUM(amount) FROM public."ComboProductTax" WHERE "comboProductId" = v_cp_record.id), 0);
                        END LOOP;
                    END IF;
                END;
            END LOOP;
        END IF;

        -- Procesar Productos Individuales
        FOR v_product_record IN (SELECT * FROM tmp_import_rows WHERE grupo = v_quotation_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN CONTINUE; END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            SELECT id INTO v_prestadora_id FROM public."Prestadora" WHERE LOWER(code) = LOWER(v_product_record.prestadora_cd);

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_qp_id := NULL;
            SELECT id INTO v_qp_id FROM public."QuotationProduct" 
            WHERE "quotationId" = v_quotation_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_qp_id IS NOT NULL THEN
                UPDATE public."QuotationProduct" SET
                    "quantity" = COALESCE(v_product_record.quantity, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "providerId" = COALESCE(v_provider_id, "providerId"),
                    "prestadoraId" = COALESCE(v_prestadora_id, "prestadoraId"),
                    "checkInDate" = COALESCE(v_product_record.check_in, "checkInDate"),
                    "checkOutDate" = COALESCE(v_product_record.check_out, "checkOutDate"),
                    "nights" = CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                                 THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                                 ELSE "nights" END,
                    "paxAdults" = COALESCE(v_product_record.pax_adultos, "paxAdults"),
                    "paxChildren" = COALESCE(v_product_record.pax_ninos, "paxChildren"),
                    "serviceType" = COALESCE(v_product_record.tipo_servicio, "serviceType"),
                    "destination" = COALESCE(v_product_record.destino, "destination"),
                    "reservationCode" = COALESCE(v_product_record.reserva, "reservationCode"),
                    "sellerCommission" = ROUND(COALESCE(v_product_record.com_vendedor, "sellerCommission")::numeric, v_decimals)::double precision,
                    "ticketPrinterCommission" = ROUND(COALESCE(v_product_record.com_tiqueteador, "ticketPrinterCommission")::numeric, v_decimals)::double precision,
                    "inNationality" = COALESCE(v_product_record.nacionalidad, "inNationality"),
                    "mainTaxId" = COALESCE(v_main_tax_id, "mainTaxId"),
					"cost" = ROUND(COALESCE(v_product_record.cost, "cost")::numeric, v_decimals)::double precision
                WHERE id = v_qp_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."QuotationProductTax" WHERE "quotationProductId" = v_qp_id;
                END IF;
            ELSE
                IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."QuotationProduct" (
                    "quotationId", "productId", "quantity", "price", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "inNationality", "mainTaxId", "cost"
                ) VALUES (
                    v_quotation_id, v_product_id, COALESCE(v_product_record.quantity, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    COALESCE(v_product_record.nacionalidad, 1), v_main_tax_id, 
                    ROUND(COALESCE(v_product_record.cost, 0)::numeric, v_decimals)::double precision
                ) RETURNING id INTO v_qp_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.quantity, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductTax" (
                            "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount"
                        ) 
                        SELECT v_qp_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                    VALUES (v_qp_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                        VALUES (v_qp_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en QuotationProductTax
        UPDATE public."Quotation"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0) AS cargos_global
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = v_quotation_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_quotation_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' cotizaciones importadas. [' || RTRIM(v_created_ids, ',') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;;

-- Inyectado automáticamente: spImpuestoCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImpuestoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImpuestoCrear(
    p_code TEXT,
    p_name TEXT,
    p_type TEXT,
    p_value_type TEXT,
    p_value DECIMAL,
    p_is_editable BOOLEAN,
    p_orden INT DEFAULT 0,
    p_product_ids JSONB DEFAULT '[]'::jsonb,
    p_target_tax_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_tax_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        IF EXISTS (SELECT 1 FROM public."ChargeAndTax" WHERE LOWER("code") = LOWER(TRIM(p_code))) THEN
            p_mensaje_resultado := 'ERROR: Ya existe un cargo o impuesto registrado con el código ' || quote_literal(p_code);
            RETURN;
        END IF;
    END IF;

    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "orden", "productIds", "targetTaxId", "isActive")
    VALUES (p_code, p_name, p_type, p_value_type, p_value, p_is_editable, COALESCE(p_orden, 0), COALESCE(p_product_ids, '[]'::jsonb), p_target_tax_id, COALESCE(p_is_active, true))
    RETURNING id INTO p_tax_id;

    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto creado con ID ' || p_tax_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spInterfaceAmadeusPG.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spInterfaceAmadeus'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE spInterfaceAmadeus(
    p_op TEXT,
    p_Booking TEXT,
    p_file TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables generales de control
    v_line TEXT;
    v_lines TEXT[];
    v_state INTEGER := 0;
    
    -- Variables para la tabla BookingGDS
    v_code VARCHAR(10);
    v_type VARCHAR(10);
    v_blanch VARCHAR(25) := 'BOG';
    v_implant VARCHAR(25);
    v_external BOOLEAN := false;
    v_date TIMESTAMP;
    v_currency VARCHAR(3) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_tiquetPrinter VARCHAR(25);
    v_seller VARCHAR(25);
    v_client VARCHAR(50);
    v_typetransaction VARCHAR(25) := '1';
    v_iata VARCHAR(25);
    v_description TEXT;
    v_observation TEXT;

    -- Variables temporales auxiliares
    v_nacionalidad INTEGER := 1;
    v_centrocosto VARCHAR(50);
    v_solicita VARCHAR(200);
    v_over VARCHAR(25);
    v_evento VARCHAR(250);
    v_highfare NUMERIC := 0;
    v_lowfare NUMERIC := 0;
    v_fare NUMERIC := 0;
    v_reasoncode VARCHAR(10);
    v_pax_cc VARCHAR(20);
    v_lapsoviaje VARCHAR(50);

    v_facturador VARCHAR(6);
    v_aerolinea_vende VARCHAR(10) := 'AV';
    v_provider_matched VARCHAR(50);
    v_tkt VARCHAR(20);
    
    -- Colecciones (Itinerarios, Pasajeros, Taxes, EMD, Pagos)
    v_iti_origenes TEXT[] := '{}';
    v_iti_destinos TEXT[] := '{}';
    v_iti_vuelos TEXT[] := '{}';
    v_iti_clases TEXT[] := '{}';
    v_iti_aerolineas TEXT[] := '{}';
    v_iti_farebasis TEXT[] := '{}';
    v_iti_fechas_llegada TIMESTAMP[] := '{}';
    v_iti_fechas_salida TIMESTAMP[] := '{}';

    v_pax_nombres TEXT[] := '{}';
    v_pax_apellidos TEXT[] := '{}';
    v_pax_prefixs TEXT[] := '{}';
    v_pax_tiquetes TEXT[] := '{}';
    v_pax_idx INTEGER := 0;

    v_tax_codes TEXT[] := '{}';
    v_tax_vals NUMERIC[] := '{}';
    v_tax_parsed BOOLEAN := false;
    v_id_master_chargeandtax INTEGER;
    v_raw_tax_code TEXT;
    v_equiv_tax_code TEXT;
    v_tax_exists_idx INTEGER;

    v_emd_codigos TEXT[] := '{}';
    v_emd_descripciones TEXT[] := '{}';
    v_emd_totales NUMERIC[] := '{}';

    v_pay_tipos TEXT[] := '{}';
    v_pay_tarjetas TEXT[] := '{}';
    v_pay_montos NUMERIC[] := '{}';
    v_pay_numbers TEXT[] := '{}';
    v_pay_expiries TEXT[] := '{}';
    v_pay_approvals TEXT[] := '{}';

    -- IDs de inserción
    v_booking_gds_id INTEGER;
    v_booking_product_gds_id INTEGER;
    v_booking_product_emd_id INTEGER;
    
    -- Variables para Tarifas
    v_am_tarifa NUMERIC := 0;
    v_am_tarifa_base NUMERIC := 0;
    v_am_impuestos NUMERIC := 0;
    v_am_otros NUMERIC := 0;
    v_am_tarifalocal NUMERIC := 0;
    v_am_total NUMERIC := 0;
    v_existing_booking TEXT;

    v_sub_line TEXT;
    v_i INTEGER;
    v_j INTEGER;

    v_parts TEXT[];
    v_item TEXT;
    v_clean_str TEXT;
    v_match TEXT[];
    v_val_monto NUMERIC;
BEGIN

    -- Obtener ID del Maestro ChargeAndTax para equivalencias
    SELECT id INTO v_id_master_chargeandtax FROM public."Master" WHERE code = 'ChargeAndTax' LIMIT 1;

    -- 1. Separar el archivo por saltos de línea
    v_lines := string_to_array(p_Booking, E'\n');
    
    -- Estado de la reserva
    IF p_Booking LIKE '%ENDX%' OR p_Booking LIKE '%END%' OR p_Booking LIKE '%CHD%' THEN
        v_state := 1;
    ELSE
        v_state := 0;
        RAISE EXCEPTION 'Reserva no confirmada: %', p_file;
    END IF;

    -- ==============================================================
    -- LECTURA ÚNICA DEL ARCHIVO: Extracción de datos y colecciones
    -- ==============================================================
    FOREACH v_line IN ARRAY v_lines
    LOOP
        v_line := rtrim(v_line, E'\r');
        
        -- D- Fechas (D-260716;260804...)
        IF starts_with(v_line, 'D-') THEN
            IF length(v_line) >= 14 THEN
                BEGIN
                    v_date := to_timestamp(substring(v_line from 9 for 6), 'YYMMDD');
                EXCEPTION WHEN OTHERS THEN
                    v_date := CURRENT_TIMESTAMP;
                END;
            END IF;

        -- Linea 3 (1A...;1A...;BOGZ12475;AIR) -> Sucursal y Pseudo
        ELSIF starts_with(v_line, '1A') AND position(';' in v_line) > 0 THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 3 THEN
                v_blanch := left(trim(v_parts[3]), 3);
                v_iata := trim(v_parts[3]);
            END IF;

        -- Linea MUC1A / M- / M (Localizador PNR)
        ELSIF (starts_with(v_line, 'MUC1A') OR starts_with(v_line, 'M-') OR starts_with(v_line, 'M')) AND v_code IS NULL THEN
            v_sub_line := trim(v_line);
            IF length(v_sub_line) >= 12 THEN
                v_code := trim(substring(v_sub_line from 7 for 6));
            END IF;
            
        -- A- Aerolínea Vendedora (Ej: A-LATAM AIRLINES COLOMBIA;4C)
        ELSIF starts_with(v_line, 'A-') THEN
            IF position(';' in v_line) > 0 THEN
                v_aerolinea_vende := LEFT(TRIM(split_part(v_line, ';', 2)), 2);
            ELSIF length(v_line) >= 12 THEN
                v_aerolinea_vende := LEFT(TRIM(substring(v_line from 11 for 2)), 2);
            END IF;
            IF v_aerolinea_vende IS NULL OR v_aerolinea_vende = '' THEN
                v_aerolinea_vende := 'AV';
            END IF;
            
        -- C- Agentes (Tiqueteador, Facturador, Vendedor)
        ELSIF starts_with(v_line, 'C-') THEN
            v_sub_line := substring(v_line from 3);
            v_parts := string_to_array(v_sub_line, '/');
            IF array_length(v_parts, 1) >= 1 THEN v_tiquetPrinter := trim(v_parts[1]); END IF;
            IF array_length(v_parts, 1) >= 2 THEN v_seller := left(trim(v_parts[2]), 6); END IF;

        -- H- ITINERARIOS
        ELSIF starts_with(v_line, 'H-') AND v_line NOT LIKE '%VOID%' THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 6 THEN
                DECLARE
                    v_origen VARCHAR(3);
                    v_destino VARCHAR(3);
                    v_aero VARCHAR(10);
                    v_vuelo VARCHAR(4);
                    v_clase VARCHAR(1);
                    v_f_str VARCHAR(100);
                    v_f_tokens TEXT[];
                    v_dia VARCHAR(2);
                    v_mes_str VARCHAR(3);
                    v_mes VARCHAR(2);
                    v_anio VARCHAR(4);
                    v_dep_h VARCHAR(2);
                    v_dep_m VARCHAR(2);
                    v_arr_h VARCHAR(2);
                    v_arr_m VARCHAR(2);
                    v_dt_token TEXT;
                    v_arr_token TEXT;
                    v_ts_salida TIMESTAMP;
                    v_ts_llegada TIMESTAMP;
                BEGIN
                    v_origen := right(trim(v_parts[2]), 3);
                    v_destino := trim(v_parts[4]);
                    
                    -- Normalizar espacios multiples en v_parts[6]
                    v_f_str := regexp_replace(trim(v_parts[6]), '\s+', ' ', 'g');
                    v_f_tokens := string_to_array(v_f_str, ' ');

                    IF array_length(v_f_tokens, 1) >= 6 THEN
                        v_aero := v_f_tokens[1];
                        v_vuelo := lpad(v_f_tokens[2], 4, '0');
                        v_clase := v_f_tokens[3];
                        v_dt_token := v_f_tokens[5]; -- ej: 15AUG0710
                        v_arr_token := v_f_tokens[6]; -- ej: 1130

                        IF length(v_dt_token) >= 9 THEN
                            v_dia := substring(v_dt_token from 1 for 2);
                            v_mes_str := upper(substring(v_dt_token from 3 for 3));
                            v_dep_h := substring(v_dt_token from 6 for 2);
                            v_dep_m := substring(v_dt_token from 8 for 2);
                        END IF;

                        IF length(v_arr_token) >= 4 THEN
                            v_arr_h := substring(v_arr_token from 1 for 2);
                            v_arr_m := substring(v_arr_token from 3 for 2);
                        END IF;

                        v_anio := to_char(COALESCE(v_date, CURRENT_TIMESTAMP), 'YYYY');
                        v_mes := CASE v_mes_str
                            WHEN 'JAN' THEN '01' WHEN 'FEB' THEN '02' WHEN 'MAR' THEN '03'
                            WHEN 'APR' THEN '04' WHEN 'MAY' THEN '05' WHEN 'JUN' THEN '06'
                            WHEN 'JUL' THEN '07' WHEN 'AUG' THEN '08' WHEN 'SEP' THEN '09'
                            WHEN 'OCT' THEN '10' WHEN 'NOV' THEN '11' WHEN 'DEC' THEN '12'
                            ELSE '01'
                        END;

                        BEGIN
                            v_ts_salida := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_dep_h, '00') || ':' || COALESCE(v_dep_m, '00'), 'YYYY-MM-DD HH24:MI');
                            v_ts_llegada := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_arr_h, '00') || ':' || COALESCE(v_arr_m, '00'), 'YYYY-MM-DD HH24:MI');
                        EXCEPTION WHEN OTHERS THEN
                            v_ts_salida := COALESCE(v_date, CURRENT_TIMESTAMP);
                            v_ts_llegada := COALESCE(v_date, CURRENT_TIMESTAMP);
                        END;

                        v_iti_origenes := array_append(v_iti_origenes, v_origen);
                        v_iti_destinos := array_append(v_iti_destinos, v_destino);
                        v_iti_vuelos := array_append(v_iti_vuelos, v_vuelo);
                        v_iti_clases := array_append(v_iti_clases, v_clase);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, v_aero);
                        IF array_length(v_f_tokens, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_f_tokens[7]));
                        ELSIF array_length(v_parts, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_parts[7]));
                        ELSE
                            v_iti_farebasis := array_append(v_iti_farebasis, '');
                        END IF;
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_ts_salida);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_ts_llegada);
                    END IF;
                END;
            END IF;

        -- I- PASAJEROS
        ELSIF starts_with(v_line, 'I-') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 2 THEN
                DECLARE
                    v_p_str TEXT;
                    v_pos_slash INT;
                    v_ape TEXT;
                    v_nom TEXT;
                    v_prefix VARCHAR(4) := 'MR';
                BEGIN
                    v_p_str := trim(v_parts[2]);
                    v_p_str := regexp_replace(v_p_str, '^[0-9]+', '');
                    v_pos_slash := position('/' in v_p_str);
                    IF v_pos_slash > 0 THEN
                        v_ape := substring(v_p_str from 1 for v_pos_slash - 1);
                        v_nom := substring(v_p_str from v_pos_slash + 1);
                        
                        IF v_nom LIKE '% MRS' OR v_nom LIKE '%MRS' THEN
                            v_prefix := 'MRS';
                            v_nom := trim(replace(v_nom, 'MRS', ''));
                        ELSIF v_nom LIKE '% MR' OR v_nom LIKE '%MR' THEN
                            v_prefix := 'MR';
                            v_nom := trim(replace(v_nom, 'MR', ''));
                        ELSIF v_nom LIKE '% MISS' OR v_nom LIKE '%MISS' THEN
                            v_prefix := 'MISS';
                            v_nom := trim(replace(v_nom, 'MISS', ''));
                        END IF;

                        v_pax_nombres := array_append(v_pax_nombres, trim(v_nom));
                        v_pax_apellidos := array_append(v_pax_apellidos, trim(v_ape));
                        v_pax_prefixs := array_append(v_pax_prefixs, v_prefix);
                        v_pax_tiquetes := array_append(v_pax_tiquetes, '');
                        v_pax_idx := v_pax_idx + 1;
                    END IF;
                END;
            END IF;

        -- T- TIQUETES (Extrae únicamente el número de 10 dígitos del tiquete)
        ELSIF starts_with(v_line, 'T-') THEN
            v_clean_str := substring(v_line from '[0-9]{10}');
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := split_part(split_part(v_line, ';', 1), '-', 3);
            END IF;
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := regexp_replace(split_part(v_line, ';', 1), '^.*-', '');
            END IF;
            v_tkt := trim(v_clean_str);
            IF v_pax_idx > 0 THEN
                v_pax_tiquetes[v_pax_idx] := v_tkt;
            END IF;

        -- IMPUESTOS (KFTR, KFTF, KNTB, KFTB, KSTF, KFTI, KNTI, KSTI) - Tomar la primera linea encontrada y aplicar equivalencias (fallback a 'OTR')
        ELSIF (starts_with(v_line, 'KFTR') OR starts_with(v_line, 'KFTF') OR starts_with(v_line, 'KNTB') OR starts_with(v_line, 'KFTB') 
           OR starts_with(v_line, 'KSTF') OR starts_with(v_line, 'KFTI') OR starts_with(v_line, 'KNTI') OR starts_with(v_line, 'KSTI')) AND NOT v_tax_parsed THEN
            v_parts := string_to_array(v_line, ';');
            FOR v_i IN 2 .. COALESCE(array_length(v_parts, 1), 0) LOOP
                v_item := trim(v_parts[v_i]);
                IF length(v_item) >= 6 THEN
                    v_match := regexp_matches(v_item, '(COP|USD|EUR)([0-9.]+)\s+([A-Z0-9]{2})');
                    IF array_length(v_match, 1) >= 3 THEN
                        v_raw_tax_code := v_match[3];
                        v_val_monto := v_match[2]::NUMERIC;

                        -- Evaluar equivalencia en DB. Si no existe mapeo, retorna 'OTR'
                        IF v_id_master_chargeandtax IS NOT NULL THEN
                            v_equiv_tax_code := public."fnEquivalenceInterface"(2, v_id_master_chargeandtax, v_raw_tax_code);
                        ELSE
                            v_equiv_tax_code := v_raw_tax_code;
                        END IF;

                        -- Verificar si el código equivalente ya fue agregado para sumar su valor
                        v_tax_exists_idx := 0;
                        FOR v_j IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                            IF v_tax_codes[v_j] = v_equiv_tax_code THEN
                                v_tax_exists_idx := v_j;
                                EXIT;
                            END IF;
                        END LOOP;

                        IF v_tax_exists_idx > 0 THEN
                            v_tax_vals[v_tax_exists_idx] := v_tax_vals[v_tax_exists_idx] + v_val_monto;
                        ELSE
                            v_tax_codes := array_append(v_tax_codes, v_equiv_tax_code);
                            v_tax_vals := array_append(v_tax_vals, v_val_monto);
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            v_tax_parsed := true;

        -- TARIFAS (K-F, K-R, KN-F, KN-R, KS-F, KS-R, ATC, K-B)
        ELSIF starts_with(v_line, 'K-') OR starts_with(v_line, 'KN-') OR starts_with(v_line, 'KS-') OR starts_with(v_line, 'ATC') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 1 THEN
                v_currency := COALESCE(substring(v_parts[1] from '[A-Z]{3}'), 'COP');
            END IF;

            FOREACH v_item IN ARRAY v_parts
            LOOP
                IF v_item LIKE '%COP%' OR v_item LIKE '%USD%' THEN
                    BEGIN
                        v_val_monto := cast(regexp_replace(v_item, '[^0-9.]', '', 'g') as NUMERIC);
                        IF v_val_monto > v_am_tarifalocal THEN
                            v_am_tarifalocal := v_val_monto;
                        END IF;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END LOOP;
            v_am_total := v_am_tarifalocal;

        -- EMD - Electronic Miscellaneous Document
        ELSIF starts_with(v_line, 'EMD') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 20 THEN
                v_emd_codigos := array_append(v_emd_codigos, substring(v_parts[1] from 4));
                v_emd_descripciones := array_append(v_emd_descripciones, trim(v_parts[19]));
                BEGIN
                    v_emd_totales := array_append(v_emd_totales, cast(regexp_replace(v_parts[array_length(v_parts, 1)], '[^0-9.]', '', 'g') as NUMERIC));
                EXCEPTION WHEN OTHERS THEN 
                    v_emd_totales := array_append(v_emd_totales, 0.0); 
                END;
            END IF;

        -- FP - FORMAS DE PAGO (Ej: FPCCVI0000000000007023E01/0528/A076194;S3;P1-2)
        ELSIF starts_with(v_line, 'FP') THEN
            DECLARE
                v_fp_clean TEXT;
                v_fp_tipo TEXT := 'CA';
                v_fp_monto NUMERIC := 0;
                v_fp_card_type TEXT := '';
                v_fp_card_number TEXT := '';
                v_fp_exp TEXT := '__/__';
                v_fp_auth TEXT := '';
                v_already_exists BOOLEAN := false;
            BEGIN
                v_fp_clean := regexp_replace(v_line, '^FP-?', '');
                IF v_fp_clean LIKE 'CASH%' OR v_fp_clean LIKE 'CA%' THEN
                    v_fp_tipo := 'CA';
                ELSIF v_fp_clean LIKE 'CC%' OR v_fp_clean LIKE 'TC%' THEN
                    v_fp_tipo := 'CC';
                    -- Extraer franquicia (ej: VI, MC, AX, DC)
                    v_fp_card_type := substring(v_fp_clean from '^(?:CC|TC)([A-Za-z]{2})');
                    IF v_fp_card_type IS NULL OR v_fp_card_type = '' THEN
                        v_fp_card_type := substring(v_line from 'FPCC([A-Za-z]{2})');
                    END IF;
                    IF v_fp_card_type IS NULL THEN v_fp_card_type := ''; END IF;

                    v_fp_card_number := substring(v_line from 'FPCC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from 'CC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    END IF;
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from '([0-9]{13,16})');
                    END IF;

                    v_fp_exp := substring(v_line from '/([0-9]{4})/');
                    IF v_fp_exp IS NULL OR v_fp_exp = '' THEN v_fp_exp := '__/__'; END IF;

                    v_fp_auth := substring(v_line from '/([A-Z0-9]+)(?:;|\s|$)');
                    IF v_fp_auth IS NULL THEN v_fp_auth := ''; END IF;
                END IF;

                IF v_fp_clean LIKE '%COP%' OR v_fp_clean LIKE '%USD%' THEN
                    BEGIN
                        v_fp_monto := cast(substring(v_fp_clean from '[0-9.]+') as NUMERIC);
                    EXCEPTION WHEN OTHERS THEN v_fp_monto := v_am_total; END;
                ELSE
                    v_fp_monto := COALESCE(v_am_total, 0);
                END IF;

                -- Prevenir duplicar la misma forma de pago registrada en múltiples líneas del archivo
                FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                    IF v_pay_tipos[v_i] = v_fp_tipo AND COALESCE(v_pay_numbers[v_i], '') = COALESCE(v_fp_card_number, '') THEN
                        v_already_exists := true;
                        EXIT;
                    END IF;
                END LOOP;

                IF NOT v_already_exists THEN
                    v_pay_tipos := array_append(v_pay_tipos, v_fp_tipo);
                    v_pay_tarjetas := array_append(v_pay_tarjetas, COALESCE(v_fp_card_type, ''));
                    v_pay_montos := array_append(v_pay_montos, v_fp_monto);
                    v_pay_numbers := array_append(v_pay_numbers, COALESCE(v_fp_card_number, ''));
                    v_pay_expiries := array_append(v_pay_expiries, v_fp_exp);
                    v_pay_approvals := array_append(v_pay_approvals, COALESCE(v_fp_auth, ''));
                END IF;
            END;

        -- OTROS REMARKS
        ELSIF v_line LIKE '%CENTRO COSTO%' THEN
            v_centrocosto := left(substring(v_line from position('CENTRO COSTO' in v_line) + 13), 50);
        ELSIF v_line LIKE '%SOLICITA%' THEN
            v_solicita := left(substring(v_line from position('SOLICITA' in v_line) + 9), 200);
        ELSIF v_line LIKE '%RM*NC-' AND v_client IS NULL THEN
            v_client := trim(split_part(v_line, '-', 2));
        END IF;

    END LOOP;

    -- Extracción dinámica de parámetros según reglas de la interfaz Amadeus (id_interfaces = 2) y resolución de equivalencias
    DECLARE
        v_dyn_val TEXT;
        v_id_master_client INTEGER;
        v_id_master_seller INTEGER;
        v_id_master_tp INTEGER;
        v_id_master_branch INTEGER;
        v_id_master_implant INTEGER;
        v_resolved_client TEXT;
        v_resolved_seller TEXT;
        v_resolved_tp TEXT;
        v_resolved_branch TEXT;
        v_resolved_implant TEXT;
    BEGIN
        SELECT id INTO v_id_master_client FROM public."Master" WHERE UPPER(code) = 'CLIENT' LIMIT 1;
        SELECT id INTO v_id_master_seller FROM public."Master" WHERE UPPER(code) = 'SELLER' LIMIT 1;
        SELECT id INTO v_id_master_tp FROM public."Master" WHERE UPPER(code) = 'TICKETPRINTER' LIMIT 1;
        SELECT id INTO v_id_master_branch FROM public."Master" WHERE UPPER(code) = 'BRANCH' LIMIT 1;
        SELECT id INTO v_id_master_implant FROM public."Master" WHERE UPPER(code) = 'IMPLANT' LIMIT 1;

        -- 1. CLIENT
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Client', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_client := v_dyn_val; END IF;
        IF v_client IS NOT NULL AND v_client <> '' THEN
            IF v_id_master_client IS NOT NULL THEN
                v_client := public."fnEquivalenceInterface"(2, v_id_master_client, v_client);
            END IF;
            SELECT document INTO v_resolved_client FROM public."Client" 
            WHERE document = v_client OR UPPER(name) ILIKE '%' || UPPER(v_client) || '%' OR CAST(id AS TEXT) = v_client LIMIT 1;
            IF v_resolved_client IS NOT NULL THEN v_client := v_resolved_client; END IF;
        END IF;

        -- 2. SELLER (Comprobar RM*VEN- o RM*VE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Seller', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_seller := v_dyn_val; END IF;
        IF v_seller IS NULL OR v_seller = '' THEN
            v_seller := substring(p_Booking from 'RM\*VEN-([A-Za-z0-9]+)');
            IF v_seller IS NULL OR v_seller = '' THEN
                v_seller := substring(p_Booking from 'RM\*VE-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_seller IS NOT NULL AND v_seller <> '' THEN
            IF v_id_master_seller IS NOT NULL THEN
                v_seller := public."fnEquivalenceInterface"(2, v_id_master_seller, v_seller);
            END IF;
            SELECT code INTO v_resolved_seller FROM public."Seller" 
            WHERE UPPER(code) = UPPER(v_seller) OR UPPER(name) ILIKE '%' || UPPER(v_seller) || '%' OR CAST(id AS TEXT) = v_seller LIMIT 1;
            IF v_resolved_seller IS NOT NULL THEN v_seller := v_resolved_seller; END IF;
        END IF;

        -- 3. TICKETPRINTER (Comprobar RM*TK- o RM*ASE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'TicketPrinter', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_tiquetPrinter := v_dyn_val; END IF;
        IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
            v_tiquetPrinter := substring(p_Booking from 'RM\*ASE-([A-Za-z0-9]+)');
            IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
                v_tiquetPrinter := substring(p_Booking from 'RM\*TK-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_tiquetPrinter IS NOT NULL AND v_tiquetPrinter <> '' THEN
            IF v_id_master_tp IS NOT NULL THEN
                v_tiquetPrinter := public."fnEquivalenceInterface"(2, v_id_master_tp, v_tiquetPrinter);
            END IF;
            SELECT code INTO v_resolved_tp FROM public."TicketPrinter" 
            WHERE UPPER(code) = UPPER(v_tiquetPrinter) OR UPPER(name) ILIKE '%' || UPPER(v_tiquetPrinter) || '%' OR CAST(id AS TEXT) = v_tiquetPrinter LIMIT 1;
            IF v_resolved_tp IS NOT NULL THEN v_tiquetPrinter := v_resolved_tp; END IF;
        END IF;

        -- 4. BRANCH
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Branch', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_blanch := v_dyn_val; END IF;
        IF v_blanch IS NOT NULL AND v_blanch <> '' THEN
            IF v_id_master_branch IS NOT NULL THEN
                v_blanch := public."fnEquivalenceInterface"(2, v_id_master_branch, v_blanch);
            END IF;
            SELECT code INTO v_resolved_branch FROM public."Branch" 
            WHERE UPPER(code) = UPPER(v_blanch) OR UPPER(name) ILIKE '%' || UPPER(v_blanch) || '%' OR CAST(id AS TEXT) = v_blanch LIMIT 1;
            IF v_resolved_branch IS NOT NULL THEN v_blanch := v_resolved_branch; END IF;
        END IF;

        -- 5. IMPLANT (RM*IMP-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Implant', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_implant := v_dyn_val; END IF;
        IF v_implant IS NULL OR v_implant = '' THEN
            v_implant := substring(p_Booking from 'RM\*IMP-([A-Za-z0-9]+)');
        END IF;
        IF v_implant IS NOT NULL AND v_implant <> '' THEN
            IF v_id_master_implant IS NOT NULL THEN
                v_implant := public."fnEquivalenceInterface"(2, v_id_master_implant, v_implant);
            END IF;
            SELECT code INTO v_resolved_implant FROM public."Implant" 
            WHERE UPPER(code) = UPPER(v_implant) OR UPPER(name) ILIKE '%' || UPPER(v_implant) || '%' OR CAST(id AS TEXT) = v_implant LIMIT 1;
            IF v_resolved_implant IS NOT NULL THEN v_implant := v_resolved_implant; END IF;
        END IF;
    END;

    -- ==============================================================
    -- VALIDACIÓN Y ASIGNACIÓN DE PROVEEDOR POR SIGLA DE AEROLÍNEA
    -- ==============================================================
    SELECT code INTO v_provider_matched
    FROM public."Provider"
    WHERE UPPER(sigla) = UPPER(v_aerolinea_vende) 
       OR UPPER(code) = UPPER(v_aerolinea_vende)
       OR UPPER("airlineCode") = UPPER(v_aerolinea_vende)
    LIMIT 1;

    -- ==============================================================
    -- INSERCIÓN EN TABLAS
    -- ==============================================================
    v_type := 'RES';
    v_description := COALESCE(v_evento, '') || ' ' || COALESCE(v_solicita, '');

    -- 1. Cabecera (Upsert y Verificación de Cambios)
    v_booking_gds_id := NULL;
    v_existing_booking := NULL;

    IF v_code IS NOT NULL AND v_code <> '' THEN
        SELECT id, "booking" INTO v_booking_gds_id, v_existing_booking 
        FROM public."BookingGDS" 
        WHERE "code" = v_code 
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NULL AND (v_tkt IS NOT NULL AND v_tkt <> '') THEN
        SELECT b."id", b."booking" INTO v_booking_gds_id, v_existing_booking
        FROM public."BookingGDS" b
        JOIN public."BookingProductGDS" bp ON bp."bookingId" = b."id"
        WHERE bp."code" = v_tkt
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NOT NULL THEN
        -- Sobrescribir la reserva y reemplazar sus detalles
        UPDATE public."BookingGDS" SET
            "type" = COALESCE(v_type, 'RES'), 
            "blanch" = v_blanch, 
            "implant" = COALESCE(v_implant, ''), 
            "external" = v_external, 
            "gds" = 2, 
            "date" = COALESCE(v_date, CURRENT_TIMESTAMP), 
            "currency" = v_currency, 
            "exchangeRate" = v_exchangeRate, 
            "tiquetPrinter" = COALESCE(v_tiquetPrinter, ''), 
            "seller" = COALESCE(v_seller, ''), 
            "client" = COALESCE(v_client, ''), 
            "booking" = p_Booking, 
            "typetransaction" = v_typetransaction, 
            "iata" = COALESCE(v_iata, ''), 
            "description" = v_description, 
            "observation" = v_observation, 
            "state" = CAST(v_state AS VARCHAR)
        WHERE "id" = v_booking_gds_id;

        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            COALESCE(v_code, 'DESC'), 
            COALESCE(v_type, 'RES'), 
            v_blanch, 
            COALESCE(v_implant, ''), 
            v_external, 
            2, 
            COALESCE(v_date, CURRENT_TIMESTAMP), 
            v_currency, 
            v_exchangeRate, 
            COALESCE(v_tiquetPrinter, ''), 
            COALESCE(v_seller, ''), 
            COALESCE(v_client, ''), 
            p_Booking, 
            v_typetransaction, 
            COALESCE(v_iata, ''), 
            v_description, 
            v_observation, 
            CAST(v_state AS VARCHAR)
        ) RETURNING "id" INTO v_booking_gds_id;
    END IF;

    -- ==============================================================
    -- CREACIÓN DE PRODUCTOS (UN PRODUCTO POR CADA TIQUETE / PASAJERO)
    -- ==============================================================
    DECLARE
        v_num_pax INTEGER;
        v_num_prods INTEGER;
        v_pax_i INTEGER;
        v_prod_code TEXT;
        v_prod_price NUMERIC;
        v_prod_tax_base NUMERIC;
        v_prod_tax_val NUMERIC;
        v_prod_pay_val NUMERIC;
    BEGIN
        v_num_pax := GREATEST(COALESCE(array_length(v_pax_nombres, 1), 0), COALESCE(array_length(v_pax_tiquetes, 1), 0));
        v_num_prods := GREATEST(1, v_num_pax);

        FOR v_pax_i IN 1 .. v_num_prods LOOP
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_tiquetes, 1) AND v_pax_tiquetes[v_pax_i] IS NOT NULL AND v_pax_tiquetes[v_pax_i] <> '' THEN
                v_prod_code := v_pax_tiquetes[v_pax_i];
            ELSE
                v_prod_code := COALESCE(v_tkt, 'VUE');
            END IF;

            v_prod_price := v_am_total;

            -- 2. Producto Padre (Vuelo / Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_aerolinea_vende, COALESCE(v_provider_matched, v_aerolinea_vende),
                1, v_prod_price, COALESCE(v_code, ''), v_nacionalidad, 'NUEVO', 'VUE'
            ) RETURNING "id" INTO v_booking_product_gds_id;

            -- 3. Detalle Itinerarios para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], v_iti_fechas_salida[v_i], 
                        v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], COALESCE(v_iti_farebasis[v_i], ''), v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 4. Detalle Pasajero para este producto
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_nombres, 1) AND v_pax_nombres[v_pax_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_pax_i::TEXT, v_pax_nombres[v_pax_i], v_pax_apellidos[v_pax_i], v_pax_prefixs[v_pax_i], COALESCE(v_pax_tiquetes[v_pax_i], ''), '', ''
                );
            END IF;

            -- 5. Detalle Impuestos (Taxes) completo para este producto
            v_am_impuestos := 0;
            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_am_impuestos := v_am_impuestos + COALESCE(v_tax_vals[v_i], 0);
                END IF;
            END LOOP;

            v_prod_tax_base := GREATEST(0, v_prod_price - v_am_impuestos);

            IF v_prod_tax_base > 0 OR v_prod_price <> 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tax_base
                );
            END IF;

            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_prod_tax_val := COALESCE(v_tax_vals[v_i], 0);
                    INSERT INTO public."BookingProductTaxGDS" (
                        "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_tax_codes[v_i], v_tax_codes[v_i], 'tax', false, 0, (v_prod_tax_val::DOUBLE PRECISION)
                    );
                END IF;
            END LOOP;

            -- 6. Formas de Pago proporcionales por tiquete para que la suma cuadre con el valor del tiquete
            FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                IF v_pay_tipos[v_i] IS NOT NULL THEN
                    v_prod_pay_val := COALESCE(v_pay_montos[v_i], v_am_total);
                    INSERT INTO public."BookingProductPaymentGDS" (
                        "bookingProductId", "bookingProductFEEId", "code", "name", "type", "typecreditcard", 
                        "numbercreditcard", "vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
                        "bank", "square", "reference", "policy", "policyannex", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, NULL, v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tarjetas[v_i],
                        COALESCE(v_pay_numbers[v_i], ''), '', COALESCE(v_pay_expiries[v_i], '__/__'), COALESCE(v_pay_approvals[v_i], ''), 0,
                        '', '', '', '', '', v_prod_pay_val
                    );
                END IF;
            END LOOP;

            -- 7. Variables Adicionales Dinámicas para este producto
            DECLARE
                r_param RECORD;
                v_var_value TEXT;
                v_mv_code TEXT;
                v_mv_name TEXT;
            BEGIN
                FOR r_param IN 
                    SELECT "fieldCode", "fieldName"
                    FROM public."InterfaceExtractParam"
                    WHERE "interfaceId" = 2
                      AND "isActive" = TRUE
                      AND UPPER("fieldCode") NOT IN ('CLIENT', 'SELLER', 'TICKETPRINTER', 'BRANCH', 'IMPLANT')
                LOOP
                    v_var_value := public."fnInterfaceExtractParamValue"(2, r_param."fieldCode", p_Booking);
                    IF v_var_value IS NOT NULL AND v_var_value <> '' THEN
                        SELECT code, name INTO v_mv_code, v_mv_name
                        FROM public."MasterVariable"
                        WHERE UPPER(code) = UPPER(r_param."fieldCode") OR UPPER(name) = UPPER(r_param."fieldName")
                        LIMIT 1;

                        IF v_mv_code IS NULL THEN
                            v_mv_code := r_param."fieldCode";
                            v_mv_name := r_param."fieldName";
                        END IF;

                        INSERT INTO public."BookingProductVariableGDS" (
                            "bookingProductId", "code", "name", "value"
                        ) VALUES (
                            v_booking_product_gds_id, v_mv_code, v_mv_name, v_var_value
                        );
                    END IF;
                END LOOP;
            END;

        END LOOP;
    END;

    -- 8. Productos EMD
    FOR v_i IN 1 .. COALESCE(array_length(v_emd_codigos, 1), 0) LOOP
        IF v_emd_codigos[v_i] IS NOT NULL THEN
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_emd_codigos[v_i], 'flight', COALESCE(v_emd_descripciones[v_i], ''), COALESCE(v_aerolinea_vende, ''), COALESCE(v_provider_matched, v_aerolinea_vende),
                1, COALESCE(v_emd_totales[v_i], 0), v_code, COALESCE(v_nacionalidad, 1), 'NUEVO', 'EMD'
            ) RETURNING "id" INTO v_booking_product_emd_id;
        END IF;
    END LOOP;

    RAISE NOTICE 'Amadeus Booking % successfully parsed and inserted.', v_code;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error processing Amadeus file: % - %', SQLSTATE, SQLERRM;
    ROLLBACK;
    RAISE;
END;
$$;;

-- Inyectado automáticamente: spInterfaceFile.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'spinterfacefile' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

-- Drop de sobrecargas previas para prevenir error 42883
DO $$ 
BEGIN
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacefile(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceFile"(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacefile CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceFile" CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Procedimiento Principal Case-Insensitive (para Npgsql / C#)
CREATE OR REPLACE PROCEDURE public.spinterfacefile(
    op TEXT,
    booking TEXT,
    file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    file_extension TEXT;
BEGIN
    file_extension := lower(substring(file from '\.[^\.]*$'));

    IF file_extension = '.fil' THEN
        CALL public.spinterfacesabre(op, booking, file);
    ELSE
        CALL public.spinterfaceamadeus(op, booking, file);
    END IF;
END;
$BODY$;

-- Alias con comillas para retrocompatibilidad
CREATE OR REPLACE PROCEDURE public."spInterfaceFile"(
    op TEXT,
    booking TEXT,
    file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CALL public.spinterfacefile(op, booking, file);
END;
$BODY$;;

-- Inyectado automáticamente: spInterfaceSabre.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

-- Drop de sobrecargas previas para prevenir error 42883
DO $$ 
BEGIN
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre"(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre" CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE OR REPLACE PROCEDURE public."spInterfaceSabre"(
    p_op TEXT,
    p_Booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    -- Variables Generales
    v_code VARCHAR(12) := NULL;
    v_blanch VARCHAR(25) := '001';
    v_implant VARCHAR(25) := '';
    v_date TIMESTAMP := CURRENT_TIMESTAMP;
    v_seller VARCHAR(25) := '';
    v_client VARCHAR(50) := '';
    v_currency VARCHAR(10) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_aerolinea_vende VARCHAR(10) := 'AA';
    v_provider_matched VARCHAR(50) := NULL;
    v_tiqueteador VARCHAR(20) := '';
    
    -- Variables de Sistema Adicionales Extraídas
    v_var_codes TEXT[] := ARRAY[]::TEXT[];
    v_var_names TEXT[] := ARRAY[]::TEXT[];
    v_var_values TEXT[] := ARRAY[]::TEXT[];
    
    -- Lineas
    v_lines TEXT[];
    v_line TEXT;
    v_i INT;
    
    -- Pasajeros
    v_pax_nombres TEXT[] := ARRAY[]::TEXT[];
    v_pax_apellidos TEXT[] := ARRAY[]::TEXT[];
    
    -- M2 Totales e Impuestos Generales y Pago M2
    v_m2_currency VARCHAR(10) := 'COP';
    v_m2_tarifa DOUBLE PRECISION := 0.0;
    v_m2_total DOUBLE PRECISION := 0.0;
    v_m2_tax_codes TEXT[] := ARRAY[]::TEXT[];
    v_m2_tax_amounts DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_m2_pay_type TEXT := NULL;
    v_m2_pay_card TEXT := '';
    v_m2_pay_number TEXT := '';
    
    -- Tiquetes y M50
    v_tkt_codes TEXT[] := ARRAY[]::TEXT[];
    v_tkt_prestadoras TEXT[] := ARRAY[]::TEXT[];
    v_tkt_tarifas DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_impuestos DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_pay_types TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_cards TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_numbers TEXT[] := ARRAY[]::TEXT[];
    
    -- Itinerarios M30
    v_iti_origenes TEXT[] := ARRAY[]::TEXT[];
    v_iti_destinos TEXT[] := ARRAY[]::TEXT[];
    v_iti_vuelos TEXT[] := ARRAY[]::TEXT[];
    v_iti_clases TEXT[] := ARRAY[]::TEXT[];
    v_iti_aerolineas TEXT[] := ARRAY[]::TEXT[];
    v_iti_fechas_salida TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    v_iti_fechas_llegada TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    
    -- IDs de Tablas
    v_booking_gds_id INT;
    v_booking_product_gds_id INT;
BEGIN
    -- 1. Separar líneas del contenido del archivo (p_Booking)
    v_lines := string_to_array(p_Booking, E'\n');
    IF v_lines IS NULL OR array_length(v_lines, 1) = 0 THEN
        RAISE EXCEPTION 'El contenido del archivo Sabre está vacío.' USING ERRCODE = 'P0001';
    END IF;

    -- 2. Recorrer archivo y parsear
    FOR v_i IN 1 .. array_length(v_lines, 1) LOOP
        v_line := REPLACE(REPLACE(v_lines[v_i], E'\r', ''), E'\uFEFF', '');
        
        -- Cabecera AA (PNR y Sucursal)
        IF v_line LIKE 'AA%' OR (v_code IS NULL AND POSITION('AA' IN v_line) = 1) THEN
            IF length(v_line) >= 61 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 6)), '');
            END IF;
            IF v_code IS NULL AND length(v_line) >= 20 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 10)), '');
            END IF;
            IF length(v_line) >= 18 THEN
                v_blanch := COALESCE(NULLIF(TRIM(SUBSTRING(v_line FROM 12 FOR 7)), ''), v_blanch);
            END IF;
        END IF;

        -- Pasajeros M1
        IF v_line LIKE 'M1%' THEN
            DECLARE
                v_raw_pax TEXT;
                v_slash_pos INT;
                v_ape TEXT;
                v_nom TEXT;
            BEGIN
                v_raw_pax := TRIM(SUBSTRING(v_line FROM 5 FOR 80));
                v_slash_pos := POSITION('/' IN v_raw_pax);
                IF v_slash_pos > 0 THEN
                    v_ape := TRIM(SUBSTRING(v_raw_pax FROM 1 FOR v_slash_pos - 1));
                    v_nom := TRIM(SUBSTRING(v_raw_pax FROM v_slash_pos + 1));
                ELSE
                    v_ape := v_raw_pax;
                    v_nom := '';
                END IF;
                IF v_ape <> '' THEN
                    v_pax_apellidos := array_append(v_pax_apellidos, v_ape);
                    v_pax_nombres := array_append(v_pax_nombres, v_nom);
                END IF;
            END;
        END IF;

        -- Totales e Impuestos de linea M2 (M201ADT...)
        IF v_line LIKE 'M2%' THEN
            DECLARE
                v_cop1_pos INT;
                v_cop2_pos INT;
                v_curr_code TEXT := 'COP';
                v_between TEXT;
                v_base_match TEXT[];
                v_tax_part TEXT;
                v_r RECORD;
                v_after_cop2 TEXT;
                v_tot_match TEXT[];
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                v_cop1_pos := POSITION('COP' IN v_line);
                IF v_cop1_pos = 0 THEN
                    v_cop1_pos := POSITION('USD' IN v_line);
                    v_curr_code := 'USD';
                END IF;

                IF v_cop1_pos > 0 THEN
                    v_m2_currency := v_curr_code;
                    v_currency := v_curr_code;

                    v_cop2_pos := POSITION(v_curr_code IN SUBSTRING(v_line FROM v_cop1_pos + 3));
                    IF v_cop2_pos > 0 THEN
                        v_cop2_pos := v_cop1_pos + 3 + v_cop2_pos - 1;
                        v_between := TRIM(SUBSTRING(v_line FROM v_cop1_pos + 3 FOR v_cop2_pos - (v_cop1_pos + 3)));
                        
                        v_base_match := regexp_matches(v_between, '^([0-9.]+)');
                        IF array_length(v_base_match, 1) >= 1 THEN
                            v_m2_tarifa := (v_base_match[1])::DOUBLE PRECISION;
                            v_tax_part := TRIM(SUBSTRING(v_between FROM length(v_base_match[1]) + 1));
                            
                            FOR v_r IN SELECT (m[1])::DOUBLE PRECISION AS amt, m[2] AS code
                                       FROM regexp_matches(v_tax_part, '([0-9.]+)\s*([A-Z0-9]{2})', 'g') AS m
                            LOOP
                                v_m2_tax_amounts := array_append(v_m2_tax_amounts, v_r.amt);
                                v_m2_tax_codes := array_append(v_m2_tax_codes, v_r.code);
                            END LOOP;
                        END IF;

                        v_after_cop2 := TRIM(SUBSTRING(v_line FROM v_cop2_pos + 3));
                        v_tot_match := regexp_matches(v_after_cop2, '^([0-9.]+)');
                        IF array_length(v_tot_match, 1) >= 1 THEN
                            v_m2_total := (v_tot_match[1])::DOUBLE PRECISION;
                        END IF;
                    END IF;
                END IF;

                -- Extracción de Tarjeta de Crédito en M2 si contiene CC
                v_cc_pos := POSITION('CC' IN v_line);
                IF v_cc_pos > 0 THEN
                    v_m2_pay_type := 'TC';
                    v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                    IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                        v_m2_pay_card := v_cand_card;
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                    ELSE
                        v_m2_pay_card := '';
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                    END IF;

                    IF array_length(v_num_match, 1) >= 1 THEN
                        v_m2_pay_number := v_num_match[1];
                    END IF;
                END IF;
            END;
        END IF;

        -- Itinerarios Vuelos M30 (AIRN)
        IF v_line LIKE 'M30%' THEN
            DECLARE
                v_airn_pos INT;
                v_date_str TEXT;
                v_day INT;
                v_mon_str TEXT;
                v_mon INT;
                v_year INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;
                v_orig TEXT;
                v_dest TEXT;
                v_rest TEXT;
                v_airline TEXT;
                v_flight TEXT;
                v_class TEXT;
                v_dep_time TEXT;
                v_arr_time TEXT;
                v_check_in TIMESTAMP;
                v_check_out TIMESTAMP;
            BEGIN
                v_airn_pos := POSITION('AIRN' IN v_line);
                IF v_airn_pos > 0 THEN
                    v_date_str := SUBSTRING(v_line FROM 10 FOR 5);
                    v_day := (SUBSTRING(v_date_str FROM 1 FOR 2))::INT;
                    v_mon_str := UPPER(SUBSTRING(v_date_str FROM 3 FOR 3));
                    
                    v_mon := CASE v_mon_str
                        WHEN 'JAN' THEN 1 WHEN 'FEB' THEN 2 WHEN 'MAR' THEN 3
                        WHEN 'APR' THEN 4 WHEN 'MAY' THEN 5 WHEN 'JUN' THEN 6
                        WHEN 'JUL' THEN 7 WHEN 'AUG' THEN 8 WHEN 'SEP' THEN 9
                        WHEN 'OCT' THEN 10 WHEN 'NOV' THEN 11 WHEN 'DEC' THEN 12
                        ELSE 1 END;
                        
                    v_orig := SUBSTRING(v_line FROM v_airn_pos + 4 FOR 3);
                    v_dest := SUBSTRING(v_line FROM v_airn_pos + 24 FOR 3);
                    
                    v_rest := TRIM(SUBSTRING(v_line FROM v_airn_pos + 44));
                    v_airline := SUBSTRING(v_rest FROM 1 FOR 2);
                    v_flight := TRIM(SUBSTRING(v_rest FROM 4 FOR 4));
                    v_class := SUBSTRING(v_rest FROM 8 FOR 1);
                    v_dep_time := SUBSTRING(v_rest FROM 10 FOR 4);
                    v_arr_time := SUBSTRING(v_rest FROM 15 FOR 4);
                    
                    v_check_in := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_dep_time FROM 1 FOR 2))::INT, (SUBSTRING(v_dep_time FROM 3 FOR 2))::INT, 0);
                    v_check_out := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_arr_time FROM 1 FOR 2))::INT, (SUBSTRING(v_arr_time FROM 3 FOR 2))::INT, 0);
                    IF v_check_out < v_check_in THEN
                        v_check_out := v_check_out + INTERVAL '1 day';
                    END IF;

                    IF v_airline IS NOT NULL AND v_airline <> '' THEN
                        v_aerolinea_vende := v_airline;
                    END IF;

                    IF v_orig IS NOT NULL AND v_dest IS NOT NULL THEN
                        v_iti_origenes := array_append(v_iti_origenes, v_orig);
                        v_iti_destinos := array_append(v_iti_destinos, v_dest);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, COALESCE(v_airline, 'AA'));
                        v_iti_vuelos := array_append(v_iti_vuelos, COALESCE(v_flight, '0000'));
                        v_iti_clases := array_append(v_iti_clases, COALESCE(v_class, 'Y'));
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_check_in);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_check_out);
                    END IF;
                END IF;
            END;
        END IF;

        -- Tiquetes, Valores e Impuestos M50 / M501 / M502
        IF v_line LIKE 'M50%' THEN
            DECLARE
                v_hash_pos INT;
                v_tkt_num TEXT := NULL;
                v_prestadora TEXT := 'AA';
                v_parts TEXT[];
                v_raw_tarifa TEXT;
                v_raw_tax TEXT;
                v_val_tarifa DOUBLE PRECISION := 0.0;
                v_val_tax DOUBLE PRECISION := 0.0;
                v_pay_type TEXT := 'TC';
                v_card_type TEXT := '';
                v_card_num TEXT := '';
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                -- 1. Numero de Tiquete y Prestadora Code
                v_hash_pos := POSITION('#' IN v_line);
                IF v_hash_pos > 2 THEN
                    v_prestadora := NULLIF(TRIM(SUBSTRING(v_line FROM v_hash_pos - 2 FOR 2)), '');
                    IF v_prestadora IS NULL THEN v_prestadora := 'AA'; END IF;
                END IF;

                IF v_hash_pos > 0 THEN
                    v_parts := string_to_array(v_line, '/');
                    IF array_length(v_parts, 1) >= 1 THEN
                        v_tkt_num := NULLIF(regexp_replace(v_parts[1], '^.*?#', ''), '');
                        IF v_tkt_num IS NOT NULL THEN
                            v_num_match := regexp_matches(v_tkt_num, '[0-9]{10,13}');
                            IF array_length(v_num_match, 1) >= 1 THEN
                                v_tkt_num := v_num_match[1];
                            END IF;
                        END IF;
                    END IF;

                    -- 2. Valor Tarifa (Segmento 3 por '/')
                    IF array_length(v_parts, 1) >= 3 THEN
                        v_raw_tarifa := regexp_replace(v_parts[3], '[^0-9.]', '', 'g');
                        IF v_raw_tarifa <> '' THEN
                            v_val_tarifa := v_raw_tarifa::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 3. Valor Otros Impuestos (Segmento 4 por '/')
                    IF array_length(v_parts, 1) >= 4 THEN
                        v_raw_tax := regexp_replace(v_parts[4], '[^0-9.]', '', 'g');
                        IF v_raw_tax <> '' THEN
                            v_val_tax := v_raw_tax::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 4. Forma de Pago y Tarjeta (Extraer franquicia VI/MC/AX/DC y numero despues de CC)
                    v_cc_pos := POSITION('CC' IN v_line);
                    IF v_cc_pos > 0 THEN
                        v_pay_type := 'TC';
                        v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                        IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                            v_card_type := v_cand_card;
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                        ELSE
                            v_card_type := '';
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                        END IF;

                        IF array_length(v_num_match, 1) >= 1 THEN
                            v_card_num := v_num_match[1];
                        END IF;
                    ELSIF POSITION('/CA ' IN v_line) > 0 OR POSITION('/CK ' IN v_line) > 0 THEN
                        v_pay_type := 'CA';
                        v_card_type := '';
                        v_card_num := '';
                    END IF;

                    IF v_tkt_num IS NOT NULL THEN
                        v_tkt_codes := array_append(v_tkt_codes, v_tkt_num);
                        v_tkt_prestadoras := array_append(v_tkt_prestadoras, COALESCE(v_prestadora, 'AA'));
                        v_tkt_tarifas := array_append(v_tkt_tarifas, v_val_tarifa);
                        v_tkt_impuestos := array_append(v_tkt_impuestos, v_val_tax);
                        v_tkt_pay_types := array_append(v_tkt_pay_types, v_pay_type);
                        v_tkt_pay_cards := array_append(v_tkt_pay_cards, v_card_type);
                        v_tkt_pay_numbers := array_append(v_tkt_pay_numbers, v_card_num);
                    END IF;
                END IF;
            END;
        END IF;

        -- Extracción de Parámetros y Variables M8 / M9 / RM
        IF v_line LIKE 'M8%' OR v_line LIKE 'M9%' OR v_line LIKE 'RM%' THEN
            DECLARE
                v_param RECORD;
                v_pref TEXT;
                v_pos INT;
                v_val TEXT;
            BEGIN
                -- M828AGENT* / M928AGENT*
                IF v_line LIKE 'M828AGENT*%' OR v_line LIKE 'M928AGENT*%' THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM 9 FOR 10));
                    v_seller := COALESCE(NULLIF(v_seller, ''), v_tiqueteador);
                END IF;

                -- Extracción por registros de InterfaceExtractParam
                FOR v_param IN 
                    SELECT p."fieldCode", p."fieldName", p.prefix, p.delimiter 
                    FROM public."InterfaceExtractParam" p
                    WHERE p."isActive" = true
                LOOP
                    v_pref := TRIM(COALESCE(v_param.prefix, ''));
                    IF v_pref <> '' AND POSITION(UPPER(v_pref) IN UPPER(v_line)) > 0 THEN
                        v_pos := POSITION(UPPER(v_pref) IN UPPER(v_line)) + length(v_pref);
                        v_val := TRIM(SUBSTRING(v_line FROM v_pos));

                        IF v_param."fieldCode" IN ('Client', 'CLI', 'Cliente') THEN
                            v_client := v_val;
                        ELSIF v_param."fieldCode" IN ('Branch', 'SUC', 'Sucursal') THEN
                            v_blanch := v_val;
                        ELSIF v_param."fieldCode" IN ('Implant', 'IMP', 'Implante') THEN
                            v_implant := v_val;
                        ELSIF v_param."fieldCode" IN ('TicketPrinter', 'ASE', 'Tiqueteador') THEN
                            v_tiqueteador := v_val;
                        ELSIF v_param."fieldCode" IN ('Seller', 'VEN', 'Vendedor') THEN
                            v_seller := v_val;
                        ELSE
                            -- Guardar Variable de Sistema Adicional (ej. 001, 002)
                            IF NOT (v_param."fieldCode" = ANY(v_var_codes)) THEN
                                v_var_codes := array_append(v_var_codes, v_param."fieldCode");
                                v_var_names := array_append(v_var_names, v_param."fieldName");
                                v_var_values := array_append(v_var_values, v_val);
                            END IF;
                        END IF;
                    END IF;
                END LOOP;

                -- Fallbacks estándar si no hay coincidencia en InterfaceExtractParam
                IF (v_client IS NULL OR v_client = '') AND POSITION('CLI-' IN v_line) > 0 THEN
                    v_client := TRIM(SUBSTRING(v_line FROM POSITION('CLI-' IN v_line) + 4));
                END IF;
                IF (v_blanch IS NULL OR v_blanch = '001') AND POSITION('SUC-' IN v_line) > 0 THEN
                    v_blanch := TRIM(SUBSTRING(v_line FROM POSITION('SUC-' IN v_line) + 4));
                END IF;
                IF (v_implant IS NULL OR v_implant = '') AND POSITION('IMP-' IN v_line) > 0 THEN
                    v_implant := TRIM(SUBSTRING(v_line FROM POSITION('IMP-' IN v_line) + 4));
                END IF;
                IF (v_tiqueteador IS NULL OR v_tiqueteador = '') AND POSITION('ASE-' IN v_line) > 0 THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM POSITION('ASE-' IN v_line) + 4));
                END IF;
                IF (v_seller IS NULL OR v_seller = '') AND POSITION('VEN-' IN v_line) > 0 THEN
                    v_seller := TRIM(SUBSTRING(v_line FROM POSITION('VEN-' IN v_line) + 4));
                END IF;

                -- Fallback para CC- (001) y FF- (002)
                IF POSITION('CC-' IN v_line) > 0 AND NOT ('001' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('CC-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '001');
                    v_var_names := array_append(v_var_names, 'centro de costo');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
                IF POSITION('FF-' IN v_line) > 0 AND NOT ('002' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('FF-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '002');
                    v_var_names := array_append(v_var_names, 'Fecha de Facturacion');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
            END;
        END IF;

    END LOOP;

    -- Validar existencia de PNR
    IF v_code IS NULL OR v_code = '' THEN
        RAISE EXCEPTION 'No se encontro codigo de reserva en la cabecera (AA).' USING ERRCODE = 'P0001';
    END IF;

    -- Upsert en BookingGDS con gds = 1 (SABRE)
    SELECT id INTO v_booking_gds_id FROM public."BookingGDS" WHERE "code" = v_code LIMIT 1;

    IF v_booking_gds_id IS NOT NULL THEN
        UPDATE public."BookingGDS" SET
            "type" = 'RES',
            "blanch" = COALESCE(v_blanch, '001'),
            "implant" = COALESCE(v_implant, ''),
            "client" = COALESCE(v_client, ''),
            "seller" = COALESCE(v_seller, ''),
            "tiquetPrinter" = COALESCE(v_tiqueteador, ''),
            "gds" = 1, -- 1 = SABRE
            "date" = CURRENT_TIMESTAMP,
            "currency" = v_currency,
            "exchangeRate" = v_exchangeRate,
            "booking" = p_Booking,
            "state" = 'NUEVO'
        WHERE id = v_booking_gds_id;

        DELETE FROM public."BookingProductVariableGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            v_code, 'RES', COALESCE(v_blanch, '001'), COALESCE(v_implant, ''), false, 1, CURRENT_TIMESTAMP, -- 1 = SABRE
            v_currency, v_exchangeRate, COALESCE(v_tiqueteador, ''), COALESCE(v_seller, ''), COALESCE(v_client, ''), 
            p_Booking, '1', '', 'Sabre Interface', '', 'NUEVO'
        ) RETURNING id INTO v_booking_gds_id;
    END IF;

    -- Creación de productos y detalles por tiquete / M50 o M2
    DECLARE
        v_num_tkts INT;
        v_tkt_i INT;
        v_prod_code TEXT;
        v_prod_prestadora TEXT;
        v_prod_tarifa DOUBLE PRECISION;
        v_prod_tax DOUBLE PRECISION;
        v_total_prod_price DOUBLE PRECISION;
        v_final_pay_type TEXT;
        v_final_pay_card TEXT;
        v_final_pay_number TEXT;
    BEGIN
        v_num_tkts := COALESCE(array_length(v_tkt_codes, 1), 0);
        IF v_num_tkts = 0 THEN
            v_num_tkts := 1;
            v_tkt_codes := ARRAY['VUE'];
            v_tkt_prestadoras := ARRAY[v_aerolinea_vende];
            v_tkt_tarifas := ARRAY[COALESCE(v_m2_tarifa, 0.0)];
            v_tkt_impuestos := ARRAY[0.0];
            v_tkt_pay_types := ARRAY[COALESCE(v_m2_pay_type, 'TC')];
            v_tkt_pay_cards := ARRAY[COALESCE(v_m2_pay_card, '')];
            v_tkt_pay_numbers := ARRAY[COALESCE(v_m2_pay_number, '')];
        END IF;

        FOR v_tkt_i IN 1 .. v_num_tkts LOOP
            v_prod_code := v_tkt_codes[v_tkt_i];
            v_prod_prestadora := COALESCE(v_tkt_prestadoras[v_tkt_i], v_aerolinea_vende);
            
            IF v_m2_tarifa > 0 THEN
                v_prod_tarifa := v_m2_tarifa;
            ELSE
                v_prod_tarifa := COALESCE(v_tkt_tarifas[v_tkt_i], 0.0);
            END IF;

            IF v_m2_total > 0 THEN
                v_total_prod_price := v_m2_total;
            ELSE
                v_prod_tax := COALESCE(v_tkt_impuestos[v_tkt_i], 0.0);
                v_total_prod_price := v_prod_tarifa + v_prod_tax;
            END IF;

            -- Forma de pago final priorizando datos extraídos
            v_final_pay_type := COALESCE(v_tkt_pay_types[v_tkt_i], v_m2_pay_type, 'TC');
            v_final_pay_card := COALESCE(NULLIF(v_tkt_pay_cards[v_tkt_i], ''), v_m2_pay_card, '');
            v_final_pay_number := COALESCE(NULLIF(v_tkt_pay_numbers[v_tkt_i], ''), v_m2_pay_number, '');

            -- Buscar proveedor por prestadora code
            SELECT code INTO v_provider_matched
            FROM public."Provider"
            WHERE UPPER(sigla) = UPPER(v_prod_prestadora) 
               OR UPPER(code) = UPPER(v_prod_prestadora)
               OR UPPER("airlineCode") = UPPER(v_prod_prestadora)
            LIMIT 1;

            -- Inserción de Producto (Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_prod_prestadora, COALESCE(v_provider_matched, v_prod_prestadora),
                1, v_total_prod_price, v_code, 1, 'NUEVO', 'VUE'
            ) RETURNING id INTO v_booking_product_gds_id;

            -- 1. Impuesto Tarifa (TAR)
            IF v_prod_tarifa > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tarifa
                );
            END IF;

            -- 2. Impuestos detallados con Homologación
            IF array_length(v_m2_tax_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_m2_tax_codes, 1) LOOP
                    DECLARE
                        v_tax_code_gds TEXT;
                        v_tax_amt DOUBLE PRECISION;
                        v_homolog_code TEXT := NULL;
                        v_homolog_name TEXT := NULL;
                    BEGIN
                        v_tax_code_gds := v_m2_tax_codes[v_i];
                        v_tax_amt := v_m2_tax_amounts[v_i];

                        SELECT eq.cd_codigo, cat.name
                        INTO v_homolog_code, v_homolog_name
                        FROM public."EquivalencesInterfaces" eq
                        LEFT JOIN public."ChargeAndTax" cat ON cat.code = eq.cd_codigo
                        WHERE eq.cd_maestro = 'ChargeAndTax'
                          AND UPPER(TRIM(eq.cd_codigointe)) = UPPER(TRIM(v_tax_code_gds))
                        LIMIT 1;

                        IF v_homolog_code IS NULL THEN
                            SELECT code, name
                            INTO v_homolog_code, v_homolog_name
                            FROM public."ChargeAndTax"
                            WHERE UPPER(code) = UPPER(v_tax_code_gds)
                            LIMIT 1;
                        END IF;

                        IF v_homolog_code IS NULL THEN
                            v_homolog_code := v_tax_code_gds;
                            v_homolog_name := v_tax_code_gds;
                        END IF;

                        INSERT INTO public."BookingProductTaxGDS" (
                            "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                        ) VALUES (
                            v_booking_product_gds_id, v_homolog_code, COALESCE(v_homolog_name, v_homolog_code), 'tax', false, 0, v_tax_amt
                        );
                    END;
                END LOOP;
            ELSIF v_prod_tax > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'OTR', 'Otros Impuestos', 'tax', false, 0, v_prod_tax
                );
            END IF;

            -- 3. Forma de Pago Única para ESTE tiquete
            IF v_final_pay_type IS NOT NULL AND v_final_pay_type <> '' THEN
                INSERT INTO public."BookingProductPaymentGDS" (
                    "bookingProductId", "code", "name", "type", "typecreditcard", "numbercreditcard", "amount"
                ) VALUES (
                    v_booking_product_gds_id, v_final_pay_type, v_final_pay_type, v_final_pay_type,
                    v_final_pay_card, COALESCE(v_final_pay_number, ''), v_total_prod_price
                );
            END IF;

            -- 4. Itinerario para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], 
                        v_iti_fechas_salida[v_i], v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], 
                        '', v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 5. Pasajero para este producto
            IF v_tkt_i <= COALESCE(array_length(v_pax_nombres, 1), 0) AND v_pax_nombres[v_tkt_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_tkt_i::TEXT, v_pax_nombres[v_tkt_i], v_pax_apellidos[v_tkt_i], '', COALESCE(v_tkt_codes[v_tkt_i], ''), '', ''
                );
            END IF;

            -- 6. Variables de Sistema Adicionales Extraídas
            IF array_length(v_var_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_var_codes, 1) LOOP
                    INSERT INTO public."BookingProductVariableGDS" (
                        "bookingProductId", "code", "name", "value"
                    ) VALUES (
                        v_booking_product_gds_id, v_var_codes[v_i], v_var_names[v_i], v_var_values[v_i]
                    );
                END LOOP;
            END IF;

        END LOOP;
    END;

    RAISE NOTICE 'Reserva Sabre PNR % procesada exitosamente.', v_code;
END;
$BODY$;

-- Alias case-insensitive para Npgsql / C#
CREATE OR REPLACE PROCEDURE public.spinterfacesabre(
    p_op TEXT,
    p_booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CALL public."spInterfaceSabre"(p_op, p_booking, p_file);
END;
$BODY$;;

-- Inyectado automáticamente: spInterfaceSabrePG.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

-- Drop de sobrecargas previas para prevenir error 42883
DO $$ 
BEGIN
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre"(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacesabre CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceSabre" CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

CREATE OR REPLACE PROCEDURE public."spInterfaceSabre"(
    p_op TEXT,
    p_Booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    -- Variables Generales
    v_code VARCHAR(12) := NULL;
    v_blanch VARCHAR(25) := '001';
    v_implant VARCHAR(25) := '';
    v_date TIMESTAMP := CURRENT_TIMESTAMP;
    v_seller VARCHAR(25) := '';
    v_client VARCHAR(50) := '';
    v_currency VARCHAR(10) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_aerolinea_vende VARCHAR(10) := 'AA';
    v_provider_matched VARCHAR(50) := NULL;
    v_tiqueteador VARCHAR(20) := '';
    
    -- Variables de Sistema Adicionales Extraídas
    v_var_codes TEXT[] := ARRAY[]::TEXT[];
    v_var_names TEXT[] := ARRAY[]::TEXT[];
    v_var_values TEXT[] := ARRAY[]::TEXT[];
    
    -- Lineas
    v_lines TEXT[];
    v_line TEXT;
    v_i INT;
    
    -- Pasajeros
    v_pax_nombres TEXT[] := ARRAY[]::TEXT[];
    v_pax_apellidos TEXT[] := ARRAY[]::TEXT[];
    
    -- M2 Totales e Impuestos Generales y Pago M2
    v_m2_currency VARCHAR(10) := 'COP';
    v_m2_tarifa DOUBLE PRECISION := 0.0;
    v_m2_total DOUBLE PRECISION := 0.0;
    v_m2_tax_codes TEXT[] := ARRAY[]::TEXT[];
    v_m2_tax_amounts DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_m2_pay_type TEXT := NULL;
    v_m2_pay_card TEXT := '';
    v_m2_pay_number TEXT := '';
    
    -- Tiquetes y M50
    v_tkt_codes TEXT[] := ARRAY[]::TEXT[];
    v_tkt_prestadoras TEXT[] := ARRAY[]::TEXT[];
    v_tkt_tarifas DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_impuestos DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_pay_types TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_cards TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_numbers TEXT[] := ARRAY[]::TEXT[];
    
    -- Itinerarios M30
    v_iti_origenes TEXT[] := ARRAY[]::TEXT[];
    v_iti_destinos TEXT[] := ARRAY[]::TEXT[];
    v_iti_vuelos TEXT[] := ARRAY[]::TEXT[];
    v_iti_clases TEXT[] := ARRAY[]::TEXT[];
    v_iti_aerolineas TEXT[] := ARRAY[]::TEXT[];
    v_iti_fechas_salida TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    v_iti_fechas_llegada TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    
    -- IDs de Tablas
    v_booking_gds_id INT;
    v_booking_product_gds_id INT;
BEGIN
    -- 1. Separar líneas del contenido del archivo (p_Booking)
    v_lines := string_to_array(p_Booking, E'\n');
    IF v_lines IS NULL OR array_length(v_lines, 1) = 0 THEN
        RAISE EXCEPTION 'El contenido del archivo Sabre está vacío.' USING ERRCODE = 'P0001';
    END IF;

    -- 2. Recorrer archivo y parsear
    FOR v_i IN 1 .. array_length(v_lines, 1) LOOP
        v_line := REPLACE(REPLACE(v_lines[v_i], E'\r', ''), E'\uFEFF', '');
        
        -- Cabecera AA (PNR y Sucursal)
        IF v_line LIKE 'AA%' OR (v_code IS NULL AND POSITION('AA' IN v_line) = 1) THEN
            IF length(v_line) >= 61 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 6)), '');
            END IF;
            IF v_code IS NULL AND length(v_line) >= 20 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 10)), '');
            END IF;
            IF length(v_line) >= 18 THEN
                v_blanch := COALESCE(NULLIF(TRIM(SUBSTRING(v_line FROM 12 FOR 7)), ''), v_blanch);
            END IF;
        END IF;

        -- Pasajeros M1
        IF v_line LIKE 'M1%' THEN
            DECLARE
                v_raw_pax TEXT;
                v_slash_pos INT;
                v_ape TEXT;
                v_nom TEXT;
            BEGIN
                v_raw_pax := TRIM(SUBSTRING(v_line FROM 5 FOR 80));
                v_slash_pos := POSITION('/' IN v_raw_pax);
                IF v_slash_pos > 0 THEN
                    v_ape := TRIM(SUBSTRING(v_raw_pax FROM 1 FOR v_slash_pos - 1));
                    v_nom := TRIM(SUBSTRING(v_raw_pax FROM v_slash_pos + 1));
                ELSE
                    v_ape := v_raw_pax;
                    v_nom := '';
                END IF;
                IF v_ape <> '' THEN
                    v_pax_apellidos := array_append(v_pax_apellidos, v_ape);
                    v_pax_nombres := array_append(v_pax_nombres, v_nom);
                END IF;
            END;
        END IF;

        -- Totales e Impuestos de linea M2 (M201ADT...)
        IF v_line LIKE 'M2%' THEN
            DECLARE
                v_cop1_pos INT;
                v_cop2_pos INT;
                v_curr_code TEXT := 'COP';
                v_between TEXT;
                v_base_match TEXT[];
                v_tax_part TEXT;
                v_r RECORD;
                v_after_cop2 TEXT;
                v_tot_match TEXT[];
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                v_cop1_pos := POSITION('COP' IN v_line);
                IF v_cop1_pos = 0 THEN
                    v_cop1_pos := POSITION('USD' IN v_line);
                    v_curr_code := 'USD';
                END IF;

                IF v_cop1_pos > 0 THEN
                    v_m2_currency := v_curr_code;
                    v_currency := v_curr_code;

                    v_cop2_pos := POSITION(v_curr_code IN SUBSTRING(v_line FROM v_cop1_pos + 3));
                    IF v_cop2_pos > 0 THEN
                        v_cop2_pos := v_cop1_pos + 3 + v_cop2_pos - 1;
                        v_between := TRIM(SUBSTRING(v_line FROM v_cop1_pos + 3 FOR v_cop2_pos - (v_cop1_pos + 3)));
                        
                        v_base_match := regexp_matches(v_between, '^([0-9.]+)');
                        IF array_length(v_base_match, 1) >= 1 THEN
                            v_m2_tarifa := (v_base_match[1])::DOUBLE PRECISION;
                            v_tax_part := TRIM(SUBSTRING(v_between FROM length(v_base_match[1]) + 1));
                            
                            FOR v_r IN SELECT (m[1])::DOUBLE PRECISION AS amt, m[2] AS code
                                       FROM regexp_matches(v_tax_part, '([0-9.]+)\s*([A-Z0-9]{2})', 'g') AS m
                            LOOP
                                v_m2_tax_amounts := array_append(v_m2_tax_amounts, v_r.amt);
                                v_m2_tax_codes := array_append(v_m2_tax_codes, v_r.code);
                            END LOOP;
                        END IF;

                        v_after_cop2 := TRIM(SUBSTRING(v_line FROM v_cop2_pos + 3));
                        v_tot_match := regexp_matches(v_after_cop2, '^([0-9.]+)');
                        IF array_length(v_tot_match, 1) >= 1 THEN
                            v_m2_total := (v_tot_match[1])::DOUBLE PRECISION;
                        END IF;
                    END IF;
                END IF;

                -- Extracción de Tarjeta de Crédito en M2 si contiene CC
                v_cc_pos := POSITION('CC' IN v_line);
                IF v_cc_pos > 0 THEN
                    v_m2_pay_type := 'TC';
                    v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                    IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                        v_m2_pay_card := v_cand_card;
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                    ELSE
                        v_m2_pay_card := '';
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                    END IF;

                    IF array_length(v_num_match, 1) >= 1 THEN
                        v_m2_pay_number := v_num_match[1];
                    END IF;
                END IF;
            END;
        END IF;

        -- Itinerarios Vuelos M30 (AIRN)
        IF v_line LIKE 'M30%' THEN
            DECLARE
                v_airn_pos INT;
                v_date_str TEXT;
                v_day INT;
                v_mon_str TEXT;
                v_mon INT;
                v_year INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;
                v_orig TEXT;
                v_dest TEXT;
                v_rest TEXT;
                v_airline TEXT;
                v_flight TEXT;
                v_class TEXT;
                v_dep_time TEXT;
                v_arr_time TEXT;
                v_check_in TIMESTAMP;
                v_check_out TIMESTAMP;
            BEGIN
                v_airn_pos := POSITION('AIRN' IN v_line);
                IF v_airn_pos > 0 THEN
                    v_date_str := SUBSTRING(v_line FROM 10 FOR 5);
                    v_day := (SUBSTRING(v_date_str FROM 1 FOR 2))::INT;
                    v_mon_str := UPPER(SUBSTRING(v_date_str FROM 3 FOR 3));
                    
                    v_mon := CASE v_mon_str
                        WHEN 'JAN' THEN 1 WHEN 'FEB' THEN 2 WHEN 'MAR' THEN 3
                        WHEN 'APR' THEN 4 WHEN 'MAY' THEN 5 WHEN 'JUN' THEN 6
                        WHEN 'JUL' THEN 7 WHEN 'AUG' THEN 8 WHEN 'SEP' THEN 9
                        WHEN 'OCT' THEN 10 WHEN 'NOV' THEN 11 WHEN 'DEC' THEN 12
                        ELSE 1 END;
                        
                    v_orig := SUBSTRING(v_line FROM v_airn_pos + 4 FOR 3);
                    v_dest := SUBSTRING(v_line FROM v_airn_pos + 24 FOR 3);
                    
                    v_rest := TRIM(SUBSTRING(v_line FROM v_airn_pos + 44));
                    v_airline := SUBSTRING(v_rest FROM 1 FOR 2);
                    v_flight := TRIM(SUBSTRING(v_rest FROM 4 FOR 4));
                    v_class := SUBSTRING(v_rest FROM 8 FOR 1);
                    v_dep_time := SUBSTRING(v_rest FROM 10 FOR 4);
                    v_arr_time := SUBSTRING(v_rest FROM 15 FOR 4);
                    
                    v_check_in := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_dep_time FROM 1 FOR 2))::INT, (SUBSTRING(v_dep_time FROM 3 FOR 2))::INT, 0);
                    v_check_out := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_arr_time FROM 1 FOR 2))::INT, (SUBSTRING(v_arr_time FROM 3 FOR 2))::INT, 0);
                    IF v_check_out < v_check_in THEN
                        v_check_out := v_check_out + INTERVAL '1 day';
                    END IF;

                    IF v_airline IS NOT NULL AND v_airline <> '' THEN
                        v_aerolinea_vende := v_airline;
                    END IF;

                    IF v_orig IS NOT NULL AND v_dest IS NOT NULL THEN
                        v_iti_origenes := array_append(v_iti_origenes, v_orig);
                        v_iti_destinos := array_append(v_iti_destinos, v_dest);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, COALESCE(v_airline, 'AA'));
                        v_iti_vuelos := array_append(v_iti_vuelos, COALESCE(v_flight, '0000'));
                        v_iti_clases := array_append(v_iti_clases, COALESCE(v_class, 'Y'));
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_check_in);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_check_out);
                    END IF;
                END IF;
            END;
        END IF;

        -- Tiquetes, Valores e Impuestos M50 / M501 / M502
        IF v_line LIKE 'M50%' THEN
            DECLARE
                v_hash_pos INT;
                v_tkt_num TEXT := NULL;
                v_prestadora TEXT := 'AA';
                v_parts TEXT[];
                v_raw_tarifa TEXT;
                v_raw_tax TEXT;
                v_val_tarifa DOUBLE PRECISION := 0.0;
                v_val_tax DOUBLE PRECISION := 0.0;
                v_pay_type TEXT := 'TC';
                v_card_type TEXT := '';
                v_card_num TEXT := '';
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                -- 1. Numero de Tiquete y Prestadora Code
                v_hash_pos := POSITION('#' IN v_line);
                IF v_hash_pos > 2 THEN
                    v_prestadora := NULLIF(TRIM(SUBSTRING(v_line FROM v_hash_pos - 2 FOR 2)), '');
                    IF v_prestadora IS NULL THEN v_prestadora := 'AA'; END IF;
                END IF;

                IF v_hash_pos > 0 THEN
                    v_parts := string_to_array(v_line, '/');
                    IF array_length(v_parts, 1) >= 1 THEN
                        v_tkt_num := NULLIF(regexp_replace(v_parts[1], '^.*?#', ''), '');
                        IF v_tkt_num IS NOT NULL THEN
                            v_num_match := regexp_matches(v_tkt_num, '[0-9]{10,13}');
                            IF array_length(v_num_match, 1) >= 1 THEN
                                v_tkt_num := v_num_match[1];
                            END IF;
                        END IF;
                    END IF;

                    -- 2. Valor Tarifa (Segmento 3 por '/')
                    IF array_length(v_parts, 1) >= 3 THEN
                        v_raw_tarifa := regexp_replace(v_parts[3], '[^0-9.]', '', 'g');
                        IF v_raw_tarifa <> '' THEN
                            v_val_tarifa := v_raw_tarifa::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 3. Valor Otros Impuestos (Segmento 4 por '/')
                    IF array_length(v_parts, 1) >= 4 THEN
                        v_raw_tax := regexp_replace(v_parts[4], '[^0-9.]', '', 'g');
                        IF v_raw_tax <> '' THEN
                            v_val_tax := v_raw_tax::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 4. Forma de Pago y Tarjeta (Extraer franquicia VI/MC/AX/DC y numero despues de CC)
                    v_cc_pos := POSITION('CC' IN v_line);
                    IF v_cc_pos > 0 THEN
                        v_pay_type := 'TC';
                        v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                        IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                            v_card_type := v_cand_card;
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                        ELSE
                            v_card_type := '';
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                        END IF;

                        IF array_length(v_num_match, 1) >= 1 THEN
                            v_card_num := v_num_match[1];
                        END IF;
                    ELSIF POSITION('/CA ' IN v_line) > 0 OR POSITION('/CK ' IN v_line) > 0 THEN
                        v_pay_type := 'CA';
                        v_card_type := '';
                        v_card_num := '';
                    END IF;

                    IF v_tkt_num IS NOT NULL THEN
                        v_tkt_codes := array_append(v_tkt_codes, v_tkt_num);
                        v_tkt_prestadoras := array_append(v_tkt_prestadoras, COALESCE(v_prestadora, 'AA'));
                        v_tkt_tarifas := array_append(v_tkt_tarifas, v_val_tarifa);
                        v_tkt_impuestos := array_append(v_tkt_impuestos, v_val_tax);
                        v_tkt_pay_types := array_append(v_tkt_pay_types, v_pay_type);
                        v_tkt_pay_cards := array_append(v_tkt_pay_cards, v_card_type);
                        v_tkt_pay_numbers := array_append(v_tkt_pay_numbers, v_card_num);
                    END IF;
                END IF;
            END;
        END IF;

        -- Extracción de Parámetros y Variables M8 / M9 / RM
        IF v_line LIKE 'M8%' OR v_line LIKE 'M9%' OR v_line LIKE 'RM%' THEN
            DECLARE
                v_param RECORD;
                v_pref TEXT;
                v_pos INT;
                v_val TEXT;
            BEGIN
                -- M828AGENT* / M928AGENT*
                IF v_line LIKE 'M828AGENT*%' OR v_line LIKE 'M928AGENT*%' THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM 9 FOR 10));
                    v_seller := COALESCE(NULLIF(v_seller, ''), v_tiqueteador);
                END IF;

                -- Extracción por registros de InterfaceExtractParam
                FOR v_param IN 
                    SELECT p."fieldCode", p."fieldName", p.prefix, p.delimiter 
                    FROM public."InterfaceExtractParam" p
                    WHERE p."isActive" = true
                LOOP
                    v_pref := TRIM(COALESCE(v_param.prefix, ''));
                    IF v_pref <> '' AND POSITION(UPPER(v_pref) IN UPPER(v_line)) > 0 THEN
                        v_pos := POSITION(UPPER(v_pref) IN UPPER(v_line)) + length(v_pref);
                        v_val := TRIM(SUBSTRING(v_line FROM v_pos));

                        IF v_param."fieldCode" IN ('Client', 'CLI', 'Cliente') THEN
                            v_client := v_val;
                        ELSIF v_param."fieldCode" IN ('Branch', 'SUC', 'Sucursal') THEN
                            v_blanch := v_val;
                        ELSIF v_param."fieldCode" IN ('Implant', 'IMP', 'Implante') THEN
                            v_implant := v_val;
                        ELSIF v_param."fieldCode" IN ('TicketPrinter', 'ASE', 'Tiqueteador') THEN
                            v_tiqueteador := v_val;
                        ELSIF v_param."fieldCode" IN ('Seller', 'VEN', 'Vendedor') THEN
                            v_seller := v_val;
                        ELSE
                            -- Guardar Variable de Sistema Adicional (ej. 001, 002)
                            IF NOT (v_param."fieldCode" = ANY(v_var_codes)) THEN
                                v_var_codes := array_append(v_var_codes, v_param."fieldCode");
                                v_var_names := array_append(v_var_names, v_param."fieldName");
                                v_var_values := array_append(v_var_values, v_val);
                            END IF;
                        END IF;
                    END IF;
                END LOOP;

                -- Fallbacks estándar si no hay coincidencia en InterfaceExtractParam
                IF (v_client IS NULL OR v_client = '') AND POSITION('CLI-' IN v_line) > 0 THEN
                    v_client := TRIM(SUBSTRING(v_line FROM POSITION('CLI-' IN v_line) + 4));
                END IF;
                IF (v_blanch IS NULL OR v_blanch = '001') AND POSITION('SUC-' IN v_line) > 0 THEN
                    v_blanch := TRIM(SUBSTRING(v_line FROM POSITION('SUC-' IN v_line) + 4));
                END IF;
                IF (v_implant IS NULL OR v_implant = '') AND POSITION('IMP-' IN v_line) > 0 THEN
                    v_implant := TRIM(SUBSTRING(v_line FROM POSITION('IMP-' IN v_line) + 4));
                END IF;
                IF (v_tiqueteador IS NULL OR v_tiqueteador = '') AND POSITION('ASE-' IN v_line) > 0 THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM POSITION('ASE-' IN v_line) + 4));
                END IF;
                IF (v_seller IS NULL OR v_seller = '') AND POSITION('VEN-' IN v_line) > 0 THEN
                    v_seller := TRIM(SUBSTRING(v_line FROM POSITION('VEN-' IN v_line) + 4));
                END IF;

                -- Fallback para CC- (001) y FF- (002)
                IF POSITION('CC-' IN v_line) > 0 AND NOT ('001' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('CC-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '001');
                    v_var_names := array_append(v_var_names, 'centro de costo');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
                IF POSITION('FF-' IN v_line) > 0 AND NOT ('002' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('FF-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '002');
                    v_var_names := array_append(v_var_names, 'Fecha de Facturacion');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
            END;
        END IF;

    END LOOP;

    -- Validar existencia de PNR
    IF v_code IS NULL OR v_code = '' THEN
        RAISE EXCEPTION 'No se encontro codigo de reserva en la cabecera (AA).' USING ERRCODE = 'P0001';
    END IF;

    -- Upsert en BookingGDS con gds = 1 (SABRE)
    SELECT id INTO v_booking_gds_id FROM public."BookingGDS" WHERE "code" = v_code LIMIT 1;

    IF v_booking_gds_id IS NOT NULL THEN
        UPDATE public."BookingGDS" SET
            "type" = 'RES',
            "blanch" = COALESCE(v_blanch, '001'),
            "implant" = COALESCE(v_implant, ''),
            "client" = COALESCE(v_client, ''),
            "seller" = COALESCE(v_seller, ''),
            "tiquetPrinter" = COALESCE(v_tiqueteador, ''),
            "gds" = 1, -- 1 = SABRE
            "date" = CURRENT_TIMESTAMP,
            "currency" = v_currency,
            "exchangeRate" = v_exchangeRate,
            "booking" = p_Booking,
            "state" = 'NUEVO'
        WHERE id = v_booking_gds_id;

        DELETE FROM public."BookingProductVariableGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            v_code, 'RES', COALESCE(v_blanch, '001'), COALESCE(v_implant, ''), false, 1, CURRENT_TIMESTAMP, -- 1 = SABRE
            v_currency, v_exchangeRate, COALESCE(v_tiqueteador, ''), COALESCE(v_seller, ''), COALESCE(v_client, ''), 
            p_Booking, '1', '', 'Sabre Interface', '', 'NUEVO'
        ) RETURNING id INTO v_booking_gds_id;
    END IF;

    -- Creación de productos y detalles por tiquete / M50 o M2
    DECLARE
        v_num_tkts INT;
        v_tkt_i INT;
        v_prod_code TEXT;
        v_prod_prestadora TEXT;
        v_prod_tarifa DOUBLE PRECISION;
        v_prod_tax DOUBLE PRECISION;
        v_total_prod_price DOUBLE PRECISION;
        v_final_pay_type TEXT;
        v_final_pay_card TEXT;
        v_final_pay_number TEXT;
    BEGIN
        v_num_tkts := COALESCE(array_length(v_tkt_codes, 1), 0);
        IF v_num_tkts = 0 THEN
            v_num_tkts := 1;
            v_tkt_codes := ARRAY['VUE'];
            v_tkt_prestadoras := ARRAY[v_aerolinea_vende];
            v_tkt_tarifas := ARRAY[COALESCE(v_m2_tarifa, 0.0)];
            v_tkt_impuestos := ARRAY[0.0];
            v_tkt_pay_types := ARRAY[COALESCE(v_m2_pay_type, 'TC')];
            v_tkt_pay_cards := ARRAY[COALESCE(v_m2_pay_card, '')];
            v_tkt_pay_numbers := ARRAY[COALESCE(v_m2_pay_number, '')];
        END IF;

        FOR v_tkt_i IN 1 .. v_num_tkts LOOP
            v_prod_code := v_tkt_codes[v_tkt_i];
            v_prod_prestadora := COALESCE(v_tkt_prestadoras[v_tkt_i], v_aerolinea_vende);
            
            IF v_m2_tarifa > 0 THEN
                v_prod_tarifa := v_m2_tarifa;
            ELSE
                v_prod_tarifa := COALESCE(v_tkt_tarifas[v_tkt_i], 0.0);
            END IF;

            IF v_m2_total > 0 THEN
                v_total_prod_price := v_m2_total;
            ELSE
                v_prod_tax := COALESCE(v_tkt_impuestos[v_tkt_i], 0.0);
                v_total_prod_price := v_prod_tarifa + v_prod_tax;
            END IF;

            -- Forma de pago final priorizando datos extraídos
            v_final_pay_type := COALESCE(v_tkt_pay_types[v_tkt_i], v_m2_pay_type, 'TC');
            v_final_pay_card := COALESCE(NULLIF(v_tkt_pay_cards[v_tkt_i], ''), v_m2_pay_card, '');
            v_final_pay_number := COALESCE(NULLIF(v_tkt_pay_numbers[v_tkt_i], ''), v_m2_pay_number, '');

            -- Buscar proveedor por prestadora code
            SELECT code INTO v_provider_matched
            FROM public."Provider"
            WHERE UPPER(sigla) = UPPER(v_prod_prestadora) 
               OR UPPER(code) = UPPER(v_prod_prestadora)
               OR UPPER("airlineCode") = UPPER(v_prod_prestadora)
            LIMIT 1;

            -- Inserción de Producto (Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_prod_prestadora, COALESCE(v_provider_matched, v_prod_prestadora),
                1, v_total_prod_price, v_code, 1, 'NUEVO', 'VUE'
            ) RETURNING id INTO v_booking_product_gds_id;

            -- 1. Impuesto Tarifa (TAR)
            IF v_prod_tarifa > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tarifa
                );
            END IF;

            -- 2. Impuestos detallados con Homologación
            IF array_length(v_m2_tax_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_m2_tax_codes, 1) LOOP
                    DECLARE
                        v_tax_code_gds TEXT;
                        v_tax_amt DOUBLE PRECISION;
                        v_homolog_code TEXT := NULL;
                        v_homolog_name TEXT := NULL;
                    BEGIN
                        v_tax_code_gds := v_m2_tax_codes[v_i];
                        v_tax_amt := v_m2_tax_amounts[v_i];

                        SELECT eq.cd_codigo, cat.name
                        INTO v_homolog_code, v_homolog_name
                        FROM public."EquivalencesInterfaces" eq
                        LEFT JOIN public."ChargeAndTax" cat ON cat.code = eq.cd_codigo
                        WHERE eq.cd_maestro = 'ChargeAndTax'
                          AND UPPER(TRIM(eq.cd_codigointe)) = UPPER(TRIM(v_tax_code_gds))
                        LIMIT 1;

                        IF v_homolog_code IS NULL THEN
                            SELECT code, name
                            INTO v_homolog_code, v_homolog_name
                            FROM public."ChargeAndTax"
                            WHERE UPPER(code) = UPPER(v_tax_code_gds)
                            LIMIT 1;
                        END IF;

                        IF v_homolog_code IS NULL THEN
                            v_homolog_code := v_tax_code_gds;
                            v_homolog_name := v_tax_code_gds;
                        END IF;

                        INSERT INTO public."BookingProductTaxGDS" (
                            "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                        ) VALUES (
                            v_booking_product_gds_id, v_homolog_code, COALESCE(v_homolog_name, v_homolog_code), 'tax', false, 0, v_tax_amt
                        );
                    END;
                END LOOP;
            ELSIF v_prod_tax > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'OTR', 'Otros Impuestos', 'tax', false, 0, v_prod_tax
                );
            END IF;

            -- 3. Forma de Pago Única para ESTE tiquete
            IF v_final_pay_type IS NOT NULL AND v_final_pay_type <> '' THEN
                INSERT INTO public."BookingProductPaymentGDS" (
                    "bookingProductId", "code", "name", "type", "typecreditcard", "numbercreditcard", "amount"
                ) VALUES (
                    v_booking_product_gds_id, v_final_pay_type, v_final_pay_type, v_final_pay_type,
                    v_final_pay_card, COALESCE(v_final_pay_number, ''), v_total_prod_price
                );
            END IF;

            -- 4. Itinerario para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], 
                        v_iti_fechas_salida[v_i], v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], 
                        '', v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 5. Pasajero para este producto
            IF v_tkt_i <= COALESCE(array_length(v_pax_nombres, 1), 0) AND v_pax_nombres[v_tkt_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_tkt_i::TEXT, v_pax_nombres[v_tkt_i], v_pax_apellidos[v_tkt_i], '', COALESCE(v_tkt_codes[v_tkt_i], ''), '', ''
                );
            END IF;

            -- 6. Variables de Sistema Adicionales Extraídas
            IF array_length(v_var_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_var_codes, 1) LOOP
                    INSERT INTO public."BookingProductVariableGDS" (
                        "bookingProductId", "code", "name", "value"
                    ) VALUES (
                        v_booking_product_gds_id, v_var_codes[v_i], v_var_names[v_i], v_var_values[v_i]
                    );
                END LOOP;
            END IF;

        END LOOP;
    END;

    RAISE NOTICE 'Reserva Sabre PNR % procesada exitosamente.', v_code;
END;
$BODY$;

-- Alias case-insensitive para Npgsql / C#
CREATE OR REPLACE PROCEDURE public.spinterfacesabre(
    p_op TEXT,
    p_booking TEXT,
    p_file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CALL public."spInterfaceSabre"(p_op, p_booking, p_file);
END;
$BODY$;;

-- Inyectado automáticamente: spLimpiarMovimientosProduccion.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spLimpiarMovimientosProduccion'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spLimpiarMovimientosProduccion"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spLimpiarMovimientosProduccion"(
    INOUT p_mensaje_resultado text DEFAULT ''
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_tbl TEXT;
    v_tables TEXT[] := ARRAY[
        'Quotation', 'QuotationProduct', 'QuotationProductTax', 'QuotationProductVariable', 
        'QuotationProductPassenger', 'QuotationProductPayment', 'QuotationCombo', 'QuotationInvoice', 
        'QuotationStateHistory', 'QuotationPrintCustomization', 'QuotationManualService', 'PreQuotation', 
        'PreQuotationStateHistory', 'Invoices', 'Invoice', 'InvoicesProduct', 'InvoicesProductTax', 
        'InvoicesProductVariable', 'InvoicesProductPasenger', 'InvoicesProductPayment', 
        'InvoicesProductCombo', 'InvoicesProductItinerary', 'BookingGDS', 'BookingsGDS_log', 
        'BookingProductGDS', 'BookingProductItineraryGDS', 'BookingProductPassangerGDS', 
        'BookingProductTaxGDS', 'BookingProductVariableGDS', 'BookingProductFEEGDS', 
        'BookingProductPaymentGDS', 'BookingsGDSInvoiceAuto', 'BookingGDSInvoiceAutoLog', 
        'BranchGDSInvoiceAuto', 'SystemLog', 'ExecutionPreset', 'ExecutionProcedure', 'Attachment', 
        'EquivalenciasInterfaces_Log'
    ];
BEGIN
    FOREACH v_tbl IN ARRAY v_tables
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = v_tbl) THEN
            EXECUTE 'TRUNCATE TABLE public."' || v_tbl || '" CASCADE;';
        END IF;
    END LOOP;

    -- Reinicio dinámico universal de TODAS las secuencias en public (IDs y Consecutivos)
    FOR r IN 
        SELECT c.relname 
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'S'
    LOOP
        EXECUTE 'ALTER SEQUENCE public."' || r.relname || '" RESTART WITH 1;';
    END LOOP;

    -- Reiniciar los consecutivos de transacciones a su valor inicial configurado
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TransactionConsecutive') THEN
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = COALESCE("initialNumber", 1);
    END IF;

    p_mensaje_resultado := 'SUCCESS: Tablas de movimientos vaciadas y consecutivos/secuencias reiniciados exitosamente a 1.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spLogRegistrar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spLogRegistrar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spLogRegistrar"(
    p_user_id INT, 
    p_module TEXT, 
    p_action TEXT, 
    p_description TEXT, 
    p_metadata JSONB, 
    INOUT p_temp_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."SystemLog" (
        "userId", "module", "action", "description", "metadata", "createdAt"
    ) VALUES (
        p_user_id, UPPER(p_module), UPPER(p_action), p_description, p_metadata, NOW()
    ) RETURNING id INTO p_temp_id;
END;
$$;;

-- Inyectado automáticamente: spMaestroImportar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMaestroImportar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMaestroImportar(
    p_tipo TEXT,
    p_text_data TEXT, -- Delimited text (Rows by \n, Cols by ^)
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_count INT := 0;
    v_errors TEXT := '';
    v_branch_id INT;
    v_provider_id INT;
    v_prov_type_id INT;
    v_role_id INT;
    v_hashed_password TEXT := '$2a$10$7zB.Y7S5y5y5y5y5y5y5y.y5y5y5y5y5y5y5y5y5y5y5y5y5y5y'; -- Placeholder hash
BEGIN
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');
            
            IF p_tipo = 'sucursales' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Branch" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'implants' THEN
                -- Format: code^name^branchCode
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    v_branch_id := NULL;
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER("code") = LOWER(TRIM(v_cols[3]));
                    END IF;
                    
                    INSERT INTO public."Implant" ("code", "name", "branchId")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), v_branch_id)
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "branchId" = EXCLUDED."branchId";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'vendedores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Seller" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."Seller" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tiqueteadores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."TicketPrinter" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."TicketPrinter" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'impuestos' THEN
                -- Format: code^name^type^valueType^value
                IF v_cols[2] IS NOT NULL AND v_cols[3] IS NOT NULL THEN
                    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "inNationality")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]), NULLIF(TRIM(v_cols[5]), '')::DECIMAL, TRUE, COALESCE(NULLIF(TRIM(v_cols[6]), '')::INT, 1))
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "type" = EXCLUDED."type",
                        "valueType" = EXCLUDED."valueType",
                        "value" = EXCLUDED."value",
                        "inNationality" = EXCLUDED."inNationality";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'clientes' THEN
                -- Format: document^name^contactInfo^address
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Client" ("document", "name", "contactInfo", "address")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]))
                    ON CONFLICT ("document") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo", 
                        "address" = EXCLUDED."address";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'proveedores' THEN
                -- Format: code^name^contactInfo^providerTypeCode^airlineCode^sigla
                IF v_cols[2] IS NOT NULL OR v_cols[1] IS NOT NULL THEN
                    v_prov_type_id := NULL;
                    IF array_length(v_cols, 1) >= 4 AND v_cols[4] IS NOT NULL AND TRIM(v_cols[4]) <> '' THEN
                        SELECT id INTO v_prov_type_id FROM public."ProviderType" WHERE LOWER("code") = LOWER(TRIM(v_cols[4])) OR LOWER("name") = LOWER(TRIM(v_cols[4])) LIMIT 1;
                    END IF;

                    INSERT INTO public."Provider" ("code", "name", "contactInfo", "providerTypeId", "airlineCode", "sigla")
                    VALUES (
                        NULLIF(TRIM(v_cols[1]), ''), 
                        TRIM(v_cols[2]), 
                        NULLIF(TRIM(v_cols[3]), ''), 
                        v_prov_type_id, 
                        CASE WHEN array_length(v_cols, 1) >= 5 THEN NULLIF(TRIM(v_cols[5]), '') ELSE NULL END,
                        CASE WHEN array_length(v_cols, 1) >= 6 THEN NULLIF(TRIM(v_cols[6]), '') ELSE NULL END
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo",
                        "providerTypeId" = COALESCE(EXCLUDED."providerTypeId", public."Provider"."providerTypeId"),
                        "airlineCode" = COALESCE(EXCLUDED."airlineCode", public."Provider"."airlineCode"),
                        "sigla" = COALESCE(EXCLUDED."sigla", public."Provider"."sigla");
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tipos-proveedores' THEN
                -- Format: code^name^isAirline
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
                    VALUES (
                        TRIM(v_cols[1]), 
                        TRIM(v_cols[2]), 
                        (UPPER(TRIM(v_cols[3])) IN ('SI', 'S', 'TRUE', '1')), 
                        true
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "isAirline" = EXCLUDED."isAirline";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'productos' THEN
                -- Format: description^basePrice^code^type^billingConcept^serviceType
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Product" ("code", "type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (TRIM(v_cols[3]), COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "type" = EXCLUDED."type",
                            "description" = EXCLUDED."description",
                            "basePrice" = EXCLUDED."basePrice",
                            "billingConcept" = EXCLUDED."billingConcept",
                            "serviceType" = EXCLUDED."serviceType";
                    ELSE
                        INSERT INTO public."Product" ("type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'prestadoras' THEN
                -- Format: name^providerCode^code^category^location^type
                IF v_cols[1] IS NOT NULL THEN
                    v_provider_id := NULL;
                    IF v_cols[2] IS NOT NULL AND TRIM(v_cols[2]) <> '' THEN
                        SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER("code") = LOWER(TRIM(v_cols[2])) OR LOWER("name") = LOWER(TRIM(v_cols[2])) LIMIT 1;
                    END IF;

                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Prestadora" ("name", "providerId", "code", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[3]), TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "name" = EXCLUDED."name",
                            "providerId" = EXCLUDED."providerId",
                            "category" = EXCLUDED."category",
                            "location" = EXCLUDED."location",
                            "type" = EXCLUDED."type";
                    ELSE
                        INSERT INTO public."Prestadora" ("name", "providerId", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'variables' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."MasterVariable" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'parametros' THEN
                -- Format: code^name^value
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."SystemParameter" ("code", "name", "value")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
                    v_count := v_count + 1;
                END IF;

            END IF;

        EXCEPTION WHEN OTHERS THEN
            v_errors := v_errors || 'Error en fila [' || v_row_text || ']: ' || SQLERRM || '; ';
        END;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: Registros procesados: ' || v_count || '. ' || COALESCE(v_errors, '');
END;
$$;;

-- Inyectado automáticamente: spMonedaActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMonedaActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMonedaActualizar(
    p_id            INT,
    p_code          TEXT,
    p_name          TEXT,
    p_exchange_rate FLOAT,
    p_decimals      INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    -- Verificar que el nuevo código no esté en uso por otra moneda
    IF EXISTS (SELECT 1 FROM public."Currency" WHERE code = p_code AND id <> p_id) THEN
        p_mensaje_resultado := 'ERROR: El código ' || p_code || ' ya está en uso por otra moneda';
        RETURN;
    END IF;

    UPDATE public."Currency"
    SET
        code           = p_code,
        name           = p_name,
        "exchangeRate" = p_exchange_rate,
        decimals       = COALESCE(p_decimals, 2)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Moneda ' || p_id || ' actualizada correctamente';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spMonedaCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMonedaCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMonedaCrear(
    p_code         TEXT,
    p_name         TEXT,
    p_exchange_rate FLOAT,
    p_decimals     INT,
    p_acting_user_id INT,
    INOUT p_currency_id      INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Currency" WHERE code = p_code) THEN
        p_mensaje_resultado := 'ERROR: El código de moneda ya está registrado';
        RETURN;
    END IF;

    INSERT INTO public."Currency" (code, name, "exchangeRate", decimals)
    VALUES (p_code, p_name, p_exchange_rate, COALESCE(p_decimals, 2))
    RETURNING id INTO p_currency_id;

    p_mensaje_resultado := 'SUCCESS: Moneda creada con ID ' || p_currency_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spMonedaEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMonedaEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMonedaEliminar(
    p_id              INT,
    p_acting_user_id  INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    DELETE FROM public."Currency" WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Moneda ' || p_id || ' eliminada correctamente';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spMonedaListar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMonedaListar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMonedaListar(
    p_id                  INT,       -- NULL = traer todas, valor = traer una específica
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    -- Retorna el resultado como conjunto de filas usando RETURN QUERY no aplica en PROCEDURE;
    -- El cliente (API) debe ejecutar un SELECT directamente después de llamar este SP,
    -- o usar una función (fnMonedaListar) para retornar rows.
    -- Este SP valida existencia y devuelve el mensaje de estado.

    IF p_id IS NULL THEN
        p_mensaje_resultado := 'SUCCESS: Consulta de todas las monedas';
    ELSE
        p_mensaje_resultado := 'SUCCESS: Consulta de moneda ID ' || p_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spParameterActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spParameterActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spParameterActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_value TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Parámetro con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."SystemParameter"
    SET "code" = p_code,
        "name" = p_name,
        "value" = p_value
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Parámetro actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spParameterCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spParameterCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spParameterCrear(
    p_code TEXT,
    p_name TEXT,
    p_value TEXT,
    p_acting_user_id INT,
    INOUT p_parameter_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."SystemParameter" ("code", "name", "value")
    VALUES (p_code, p_name, p_value)
    RETURNING id INTO p_parameter_id;

    p_mensaje_resultado := 'SUCCESS: Parámetro creado con ID ' || p_parameter_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spParameterEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spParameterEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spParameterEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Parámetro con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."SystemParameter" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Parámetro eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spPaymentActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPaymentActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spPaymentActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_inactive boolean, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Payment" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Payment" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Payment" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "iscash" = COALESCE(p_iscash, false), "iscredit" = COALESCE(p_iscredit, false), "inactive" = COALESCE(p_inactive, false) WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spPaymentCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPaymentCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spPaymentCrear"(IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Payment" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Payment" ("code", "name", "iscash", "iscredit", "inactive") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), COALESCE(p_iscash, false), COALESCE(p_iscredit, false), false) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $procedure$;;

-- Inyectado automáticamente: spPaymentEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPaymentEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spPaymentEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
LANGUAGE plpgsql AS $procedure$
BEGIN
    DELETE FROM public."Payment" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $procedure$;;

-- Inyectado automáticamente: spPreCotizacionConvertir.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

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
$$;;

-- Inyectado automáticamente: spPreCotizacionCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

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
$$;;

-- Inyectado automáticamente: spPreCotizacionEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPreCotizacionEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spPreCotizacionEliminar
-- Descripción: Elimina una pre-cotización y su historial en PostgreSQL.
--              Resetea la secuencia si la tabla queda vacía.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spPreCotizacionEliminar"(
    IN p_id INT,
    OUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."PreQuotation" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Pre-Cotización ' || p_id || ' no existe.';
        RETURN;
    END IF;

    DELETE FROM public."PreQuotationStateHistory" WHERE "preQuotationId" = p_id;
    DELETE FROM public."PreQuotation" WHERE id = p_id;

    -- Reseteo de secuencia si la tabla queda totalmente vacía
    IF NOT EXISTS (SELECT 1 FROM public."PreQuotation") THEN
        PERFORM setval('public."PreQuotation_id_seq"', 1, false);
    END IF;

    p_mensaje_resultado := 'SUCCESS: Pre-Cotización eliminada correctamente';
END;
$$;;

-- Inyectado automáticamente: spPrestadoraCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPrestadoraCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spPrestadoraCrear(
    p_code TEXT,
    p_name TEXT,
    p_category TEXT,
    p_location TEXT,
    p_provider_id INT,
    p_type TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_prestadora_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Prestadora" ("code", "name", "category", "location", "providerId", "type", "isActive")
    VALUES (p_code, p_name, p_category, p_location, p_provider_id, p_type, COALESCE(p_is_active, true))
    RETURNING id INTO p_prestadora_id;

    p_mensaje_resultado := 'SUCCESS: Prestadora creado con ID ' || p_prestadora_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spPrestadoraEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPrestadoraEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spPrestadoraEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public."Prestadora" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Prestadora eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProductoActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProductoActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProductoActualizar(
    p_id INT,
    p_code TEXT,
    p_type TEXT,
    p_description TEXT,
    p_base_price FLOAT,
    p_cost FLOAT,
    p_billing_concept TEXT,
    p_service_type TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Product" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Producto con ID ' || p_id || ' no encontrado';
        RETURN;
    END IF;

    UPDATE public."Product" SET
        "code" = p_code,
        "type" = p_type,
        "description" = p_description,
        "basePrice" = p_base_price,
        "cost" = p_cost,
        "billingConcept" = p_billing_concept,
        "serviceType" = p_service_type
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Producto actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProductoCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProductoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProductoCrear(
    p_code TEXT,
    p_type TEXT,
    p_description TEXT,
    p_base_price FLOAT,
    p_cost FLOAT,
    p_billing_concept TEXT,
    p_service_type TEXT,
    p_acting_user_id INT,
    INOUT p_product_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Product" ("code", "type", "description", "basePrice", "cost", "billingConcept", "serviceType")
    VALUES (p_code, p_type, p_description, p_base_price, p_cost, p_billing_concept, p_service_type)
    RETURNING id INTO p_product_id;

    p_mensaje_resultado := 'SUCCESS: Producto creado con ID ' || p_product_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProductoEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProductoEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProductoEliminar(
    p_id INT,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT description INTO v_name FROM public."Product" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El producto especificado no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."QuotationProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."InvoicesProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."ComboProduct" WHERE "productId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el producto "' || v_name || '" porque ya se encuentra registrado en ' || v_count || ' cotización(es) o factura(s). Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Product" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Producto eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProveedorActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProveedorActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProveedorActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_contact_info TEXT,
    p_commission_config JSONB,
    p_provider_type_id INT,
    p_airline_code TEXT,
    p_sigla TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public."Provider" SET
        "code" = p_code,
        "name" = p_name,
        "contactInfo" = p_contact_info,
        "commissionConfig" = p_commission_config,
        "providerTypeId" = p_provider_type_id,
        "airlineCode" = p_airline_code,
        "sigla" = p_sigla,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Proveedor actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProveedorCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProveedorCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProveedorCrear(
    p_code TEXT,
    p_name TEXT,
    p_contact_info TEXT,
    p_commission_config JSONB,
    p_provider_type_id INT,
    p_airline_code TEXT,
    p_sigla TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_provider_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Provider" ("code", "name", "contactInfo", "commissionConfig", "providerTypeId", "airlineCode", "sigla", "isActive")
    VALUES (p_code, p_name, p_contact_info, p_commission_config, p_provider_type_id, p_airline_code, p_sigla, COALESCE(p_is_active, true))
    RETURNING id INTO p_provider_id;

    p_mensaje_resultado := 'SUCCESS: Proveedor creado con ID ' || p_provider_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProveedorEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProveedorEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProveedorEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public."Provider" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Proveedor eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProviderTypeActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProviderTypeActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProviderTypeActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_is_airline BOOLEAN,
    p_active BOOLEAN,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public."ProviderType" SET
        "code" = p_code,
        "name" = p_name,
        "isAirline" = COALESCE(p_is_airline, false),
        "active" = COALESCE(p_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProviderTypeCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProviderTypeCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProviderTypeCrear(
    p_code TEXT,
    p_name TEXT,
    p_is_airline BOOLEAN,
    p_active BOOLEAN,
    p_acting_user_id INT,
    INOUT p_prov_type_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
    VALUES (p_code, p_name, COALESCE(p_is_airline, false), COALESCE(p_active, true))
    RETURNING id INTO p_prov_type_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor creado con ID ' || p_prov_type_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spProviderTypeEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProviderTypeEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProviderTypeEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public."ProviderType" WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spQuotationStateActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateActualizar"(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_color TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."QuotationState"
    SET code = COALESCE(p_code, code),
        name = COALESCE(p_name, name),
        color = p_color
    WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización actualizado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spQuotationStateCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateCrear"(
    p_code TEXT,
    p_name TEXT,
    p_color TEXT,
    p_acting_user_id INT,
    INOUT p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO public."QuotationState" (code, name, color)
    VALUES (p_code, p_name, p_color)
    RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización creado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spQuotationStateEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spQuotationStateEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spQuotationStateEliminar"(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public."QuotationState" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización eliminado correctamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spResolucionActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spResolucionActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spResolucionActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_date TIMESTAMP WITH TIME ZONE,
    p_expira TIMESTAMP WITH TIME ZONE,
    p_inicial BIGINT,
    p_end BIGINT,
    p_autoriza TEXT,
    p_prefijo TEXT,
    p_alerta INT,
    p_day INT,
    p_permitir BOOLEAN,
    p_activo BOOLEAN,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Resolution" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Resolución con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."Resolution"
    SET "code" = p_code,
        "name" = p_name,
        "date" = p_date,
        "expira" = p_expira,
        "inicial" = p_inicial,
        "end" = p_end,
        "autoriza" = p_autoriza,
        "prefijo" = p_prefijo,
        "alerta" = p_alerta,
        "day" = p_day,
        "permitir" = COALESCE(p_permitir, false),
        "activo" = COALESCE(p_activo, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Resolución actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spResolucionCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spResolucionCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spResolucionCrear(
    p_code TEXT,
    p_name TEXT,
    p_date TIMESTAMP WITH TIME ZONE,
    p_expira TIMESTAMP WITH TIME ZONE,
    p_inicial BIGINT,
    p_end BIGINT,
    p_autoriza TEXT,
    p_prefijo TEXT,
    p_alerta INT,
    p_day INT,
    p_permitir BOOLEAN,
    p_activo BOOLEAN,
    p_acting_user_id INT,
    INOUT p_resolution_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Resolution" (
        "code", "name", "date", "expira", "inicial", "end", "autoriza", "prefijo", "alerta", "day", "permitir", "activo"
    )
    VALUES (
        p_code, p_name, p_date, p_expira, p_inicial, p_end, p_autoriza, p_prefijo, p_alerta, p_day, COALESCE(p_permitir, false), COALESCE(p_activo, true)
    )
    RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS: Resolución creada con ID ' || p_resolution_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spResolucionEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spResolucionEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spResolucionEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Resolution" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Resolución con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."Resolution" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Resolución eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spRoleGuardarYPermisos.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spRoleGuardarYPermisos'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spRoleGuardarYPermisos
-- Descripción: Procedimiento en PostgreSQL para crear, actualizar y gestionar los permisos de los roles.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spRoleGuardarYPermisos"(
    IN p_id INT,
    IN p_name VARCHAR,
    IN p_description TEXT,
    IN p_permissions JSONB,
    OUT p_res_id INT,
    OUT p_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
BEGIN
    v_name := TRIM(p_name);
    
    IF v_name IS NULL OR v_name = '' THEN
        p_res_id := 0;
        p_message := 'El nombre del rol no puede estar vacío.';
        RETURN;
    END IF;

    -- Si p_id es nulo o 0 -> Crear Nuevo Rol
    IF p_id IS NULL OR p_id = 0 THEN
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name)) THEN
            p_res_id := 0;
            p_message := 'Ya existe un rol registrado con ese nombre.';
            RETURN;
        END IF;

        INSERT INTO public."Role" (name, description, permissions)
        VALUES (v_name, TRIM(p_description), COALESCE(p_permissions, '{}'::jsonb))
        RETURNING id INTO p_res_id;

        p_message := 'Rol creado exitosamente en la base de datos.';
        RETURN;
    ELSE
        -- Actualizar Rol Existente
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name) AND id <> p_id) THEN
            p_res_id := 0;
            p_message := 'El nombre especificado ya está en uso por otro rol.';
            RETURN;
        END IF;

        UPDATE public."Role"
        SET name = v_name,
            description = TRIM(p_description),
            permissions = COALESCE(p_permissions, permissions)
        WHERE id = p_id;

        p_res_id := p_id;
        p_message := 'Rol y matriz de permisos actualizados correctamente.';
        RETURN;
    END IF;
END;
$$;;

-- Inyectado automáticamente: spSellerCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSellerCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSellerCrear(
    p_code TEXT,
    p_name TEXT,
    p_email TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_seller_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Seller" ("code", "name", "email", "isActive")
    VALUES (p_code, p_name, p_email, COALESCE(p_is_active, true))
    RETURNING id INTO p_seller_id;

    p_mensaje_resultado := 'SUCCESS: Vendedor creado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spSellerEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSellerEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSellerEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Seller" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Vendedor con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."Seller" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Vendedor eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spSysConsecutivoActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoActualizar(
    p_id INT,
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_branch_id INT,
    p_implant_id INT,
    p_fuente VARCHAR,
    p_serie VARCHAR,
    p_consecutivo BIGINT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    UPDATE public."SysConsecutivo"
    SET 
        "codigo" = TRIM(p_codigo),
        "nombre" = TRIM(p_nombre),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "fuente" = TRIM(p_fuente),
        "serie" = TRIM(p_serie),
        "consecutivo" = COALESCE(p_consecutivo, 0),
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo actualizado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spSysConsecutivoCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoCrear(
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_branch_id INT,
    p_implant_id INT,
    p_fuente VARCHAR,
    p_serie VARCHAR,
    p_consecutivo BIGINT,
    p_acting_user_id INT,
    INOUT p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    INSERT INTO public."SysConsecutivo" (
        "codigo", "nombre", "branchId", "implantId", "fuente", "serie", "consecutivo", "createdAt", "updatedAt"
    ) VALUES (
        TRIM(p_codigo), TRIM(p_nombre), p_branch_id, p_implant_id, TRIM(p_fuente), TRIM(p_serie), COALESCE(p_consecutivo, 0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id INTO p_id;

    p_mensaje_resultado := 'SUCCESS: Consecutivo creado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spSysConsecutivoEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSysConsecutivoEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSysConsecutivoEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."SysConsecutivo"
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo eliminado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTicketPrinterActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketPrinterActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spTicketPrinterActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_email TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."TicketPrinter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Tiqueteador con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."TicketPrinter"
    SET "code" = p_code,
        "name" = p_name,
        "email" = p_email
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tiqueteador actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTicketPrinterCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketPrinterCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spTicketPrinterCrear(
    p_code TEXT,
    p_name TEXT,
    p_email TEXT,
    p_acting_user_id INT,
    INOUT p_printer_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."TicketPrinter" ("code", "name", "email")
    VALUES (p_code, p_name, p_email)
    RETURNING id INTO p_printer_id;

    p_mensaje_resultado := 'SUCCESS: Tiqueteador creado con ID ' || p_printer_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTicketPrinterEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketPrinterEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spTicketPrinterEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."TicketPrinter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Tiqueteador con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."TicketPrinter" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tiqueteador eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTicketTypeActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketTypeActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spTicketTypeActualizar"(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_description TEXT,
    p_isActive BOOLEAN,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public."TicketType"
    SET code = COALESCE(p_code, code),
        name = COALESCE(p_name, name),
        description = p_description,
        "isActive" = COALESCE(p_isActive, "isActive")
    WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete actualizado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spTicketTypeCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketTypeCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spTicketTypeCrear"(
    p_code TEXT,
    p_name TEXT,
    p_description TEXT,
    p_isActive BOOLEAN,
    p_acting_user_id INT,
    INOUT p_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO public."TicketType" (code, name, description, "isActive")
    VALUES (p_code, p_name, p_description, COALESCE(p_isActive, true))
    RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete creado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spTicketTypeEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketTypeEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;


CREATE OR REPLACE PROCEDURE public."spTicketTypeEliminar"(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public."TicketType" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete eliminado correctamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;;

-- Inyectado automáticamente: spTraceabilityClean.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityClean'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTraceabilityClean"(
    IN p_days INT DEFAULT 30,
    INOUT p_mensaje_resultado TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted_logs INT := 0;
    v_deleted_sessions INT := 0;
BEGIN
    DELETE FROM public."TraceabilityLog"
    WHERE "createdAt" < (NOW() - (p_days || ' days')::INTERVAL);
    GET DIAGNOSTICS v_deleted_logs = ROW_COUNT;

    DELETE FROM public."TraceabilitySession"
    WHERE "createdAt" < (NOW() - (p_days || ' days')::INTERVAL);
    GET DIAGNOSTICS v_deleted_sessions = ROW_COUNT;

    p_mensaje_resultado := 'SUCCESS: ' || v_deleted_sessions || ' sesiones y ' || v_deleted_logs || ' eventos de trazabilidad depurados anteriores a ' || p_days || ' días.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTraceabilityGetDetails.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityGetDetails'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."spTraceabilityGetDetails"(
    p_code TEXT
)
RETURNS TABLE (
    log_id INT,
    session_code TEXT,
    "userId" INT,
    origin TEXT,
    userName TEXT,
    "eventType" TEXT,
    "stepName" TEXT,
    "spName" TEXT,
    endpoint TEXT,
    "durationMs" DOUBLE PRECISION,
    status TEXT,
    "inputData" JSONB,
    "outputData" JSONB,
    "techMessage" TEXT,
    "functionalMessage" TEXT,
    "stackTrace" TEXT,
    "affectedId" TEXT,
    "createdAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id AS log_id,
        l.code AS session_code,
        l."userId",
        COALESCE(l.origin, 'WEB') AS origin,
        COALESCE(u.name, 'Sistema / Anonimo') AS userName,
        l."eventType",
        l."stepName",
        l."spName",
        l.endpoint,
        COALESCE(l."durationMs", 0) AS "durationMs",
        l.status,
        l."inputData",
        l."outputData",
        l."techMessage",
        l."functionalMessage",
        l."stackTrace",
        l."affectedId",
        l."createdAt"
    FROM public."TraceabilityLog" l
    LEFT JOIN public."User" u ON l."userId" = u.id
    WHERE l.code = p_code OR l."sessionId" IN (SELECT id FROM public."TraceabilitySession" WHERE code = p_code)
    ORDER BY l.id ASC;
END;
$$;;

-- Inyectado automáticamente: spTraceabilityList.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityList'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."spTraceabilityList"(
    p_code TEXT DEFAULT NULL,
    p_user_id INT DEFAULT NULL,
    p_module TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    code TEXT,
    "userId" INT,
    origin TEXT,
    userName TEXT,
    module TEXT,
    screen TEXT,
    action TEXT,
    process TEXT,
    status TEXT,
    "totalDurationMs" DOUBLE PRECISION,
    "errorMessage" TEXT,
    "eventCount" BIGINT,
    "createdAt" TIMESTAMP,
    "updatedAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.code,
        s."userId",
        COALESCE(s.origin, 'WEB') AS origin,
        COALESCE(u.name, 'Sistema / Anonimo') AS userName,
        s.module,
        s.screen,
        s.action,
        s.process,
        s.status,
        COALESCE(s."totalDurationMs", 0) AS "totalDurationMs",
        s."errorMessage",
        (SELECT COUNT(*) FROM public."TraceabilityLog" l WHERE l."sessionId" = s.id) AS "eventCount",
        s."createdAt",
        s."updatedAt"
    FROM public."TraceabilitySession" s
    LEFT JOIN public."User" u ON s."userId" = u.id
    WHERE (p_code IS NULL OR TRIM(p_code) = '' OR s.code ILIKE '%' || TRIM(p_code) || '%')
      AND (p_user_id IS NULL OR p_user_id = 0 OR s."userId" = p_user_id)
      AND (p_module IS NULL OR TRIM(p_module) = '' OR s.module ILIKE '%' || TRIM(p_module) || '%')
      AND (p_status IS NULL OR TRIM(p_status) = '' OR s.status ILIKE TRIM(p_status))
      AND (p_start_date IS NULL OR s."createdAt" >= p_start_date)
      AND (p_end_date IS NULL OR s."createdAt" <= p_end_date)
    ORDER BY s."createdAt" DESC
    LIMIT 100;
END;
$$;;

-- Inyectado automáticamente: spTraceabilityLog.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTraceabilityLog'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTraceabilityLog"(
    IN p_code TEXT,
    IN p_user_id INT,
    IN p_origin TEXT,
    IN p_module TEXT,
    IN p_screen TEXT,
    IN p_action TEXT,
    IN p_process TEXT,
    IN p_event_type TEXT,
    IN p_step_name TEXT,
    IN p_sp_name TEXT,
    IN p_endpoint TEXT,
    IN p_duration_ms DOUBLE PRECISION,
    IN p_status TEXT,
    IN p_input_data JSONB,
    IN p_output_data JSONB,
    IN p_tech_message TEXT,
    IN p_functional_message TEXT,
    IN p_stack_trace TEXT,
    IN p_affected_id TEXT,
    INOUT p_mensaje_resultado TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Registro de sesiones y eventos individuales de trazabilidad y diagnóstico con taxonomía de origen.
*/
DECLARE
    v_session_id INT;
    v_mode TEXT := 'OFF';
    v_origin TEXT := COALESCE(NULLIF(TRIM(p_origin), ''), 'WEB');
BEGIN
    -- Leer modo actual de trazabilidad
    SELECT value INTO v_mode FROM public."SystemParameter" WHERE UPPER(code) = 'TRACEABILITY_MODE';
    v_mode := COALESCE(UPPER(v_mode), 'OFF');

    -- Si el modo está deshabilitado y no es un evento de ERROR/EXCEPCION, omitir
    IF v_mode = 'OFF' AND UPPER(COALESCE(p_event_type, '')) NOT IN ('ERROR', 'EXCEPCION') THEN
        p_mensaje_resultado := 'TRACE_DISABLED';
        RETURN;
    END IF;

    -- Garantizar sesión principal
    SELECT id INTO v_session_id FROM public."TraceabilitySession" WHERE code = p_code;

    IF v_session_id IS NULL THEN
        INSERT INTO public."TraceabilitySession" (
            "code", "userId", "origin", "module", "screen", "action", "process", "status", "errorMessage"
        ) VALUES (
            p_code, p_user_id, v_origin, COALESCE(p_module, 'GENERAL'), p_screen, COALESCE(p_action, 'EJECUCION'), p_process,
            CASE 
                WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(COALESCE(p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(COALESCE(p_status, '')) = 'SUCCESS' OR UPPER(COALESCE(p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE COALESCE(p_status, 'IN_PROGRESS')
            END,
            CASE WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN COALESCE(p_functional_message, p_tech_message) ELSE NULL END
        ) RETURNING id INTO v_session_id;
    ELSE
        UPDATE public."TraceabilitySession" SET
            "updatedAt" = NOW(),
            "origin" = COALESCE(v_origin, "origin"),
            "totalDurationMs" = COALESCE("totalDurationMs", 0) + COALESCE(p_duration_ms, 0),
            "status" = CASE 
                WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(COALESCE(p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(COALESCE(p_status, '')) = 'SUCCESS' OR UPPER(COALESCE(p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE "status"
            END,
            "errorMessage" = CASE WHEN UPPER(COALESCE(p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN COALESCE(p_functional_message, p_tech_message, "errorMessage") ELSE "errorMessage" END
        WHERE id = v_session_id;
    END IF;

    -- Registrar evento en TraceabilityLog
    INSERT INTO public."TraceabilityLog" (
        "sessionId", "code", "userId", "origin", "eventType", "stepName", "spName", "endpoint",
        "durationMs", "status", "inputData", "outputData", "techMessage", "functionalMessage",
        "stackTrace", "affectedId"
    ) VALUES (
        v_session_id, p_code, p_user_id, v_origin, COALESCE(p_event_type, 'INFO'), COALESCE(p_step_name, 'PASO'),
        p_sp_name, p_endpoint, COALESCE(p_duration_ms, 0), COALESCE(p_status, 'SUCCESS'),
        p_input_data, p_output_data, p_tech_message, p_functional_message,
        p_stack_trace, p_affected_id
    );

    p_mensaje_resultado := 'SUCCESS: Evento registrado en traza ' || p_code;
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTransactionConsecutiveActualizar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTransactionConsecutiveActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTransactionConsecutiveActualizar"(
    IN p_id integer,
    IN p_transaction_type text,
    IN p_description text,
    IN p_prefix text,
    IN p_initial_number integer,
    IN p_current_number integer,
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción es obligatoria.';
        RETURN;
    END IF;

    UPDATE public."TransactionConsecutive"
    SET 
        "transactionType" = UPPER(TRIM(p_transaction_type)),
        "description" = TRIM(p_description),
        "prefix" = TRIM(p_prefix),
        "initialNumber" = COALESCE(p_initial_number, "initialNumber"),
        "currentNumber" = COALESCE(p_current_number, "currentNumber"),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spTransactionConsecutiveCrear.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTransactionConsecutiveCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTransactionConsecutiveCrear"(
    IN p_transaction_type text,
    IN p_description text,
    IN p_prefix text,
    IN p_initial_number integer,
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_consecutivo_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción de la transacción es obligatoria.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_initial_number < 1 THEN
        p_initial_number := 1;
    END IF;

    INSERT INTO public."TransactionConsecutive" (
        "transactionType",
        "description",
        "prefix",
        "initialNumber",
        "currentNumber",
        "branchId",
        "implantId",
        "isActive",
        "createdAt"
    ) VALUES (
        UPPER(TRIM(p_transaction_type)),
        TRIM(p_description),
        TRIM(p_prefix),
        p_initial_number,
        p_initial_number,
        p_branch_id,
        p_implant_id,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_consecutivo_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_consecutivo_id := 0;
END;
$$;;

-- Inyectado automáticamente: spTransactionConsecutiveEliminar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTransactionConsecutiveEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTransactionConsecutiveEliminar"(
    IN p_id integer,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."TransactionConsecutive"
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spUsuarioConsultar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioConsultar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.spUsuarioConsultar(
    p_id INT DEFAULT NULL,
    p_email TEXT DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    "name" TEXT,
    "email" TEXT,
    "roleId" INT,
    "branchId" INT,
    "implantId" INT,
    "ticketPrinterId" INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name AS "name",
        u.email AS "email",
        u."roleId" AS "roleId",
        u."branchId" AS "branchId",
        u."implantId" AS "implantId",
        u."ticketPrinterId" AS "ticketPrinterId"
    FROM public."User" u
    WHERE (p_id IS NULL OR u.id = p_id)
      AND (p_email IS NULL OR u.email = p_email)
    ORDER BY u.id ASC;
END;
$$;;

-- Inyectado automáticamente: spUsuarioCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spUsuarioCrear(
    p_name TEXT,
    p_email TEXT,
    p_password_hash TEXT,
    p_role_id INT,
    p_branch_id INT,
    p_implant_id INT,
    p_ticket_printer_id INT,
    p_acting_user_id INT,
    INOUT p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar si el email ya existe
    IF EXISTS (SELECT 1 FROM public."User" WHERE email = p_email) THEN
        p_mensaje_resultado := 'ERROR: El email ' || p_email || ' ya está registrado.';
        RETURN;
    END IF;

    INSERT INTO public."User" (
        "name", 
        "email", 
        "passwordHash", 
        "roleId", 
        "branchId", 
        "implantId", 
        "ticketPrinterId"
    )
    VALUES (
        p_name, 
        p_email, 
        p_password_hash, 
        p_role_id, 
        p_branch_id, 
        p_implant_id, 
        p_ticket_printer_id
    )
    RETURNING id INTO p_user_id;

    p_mensaje_resultado := 'SUCCESS: Usuario creado con ID ' || p_user_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spUsuarioEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spUsuarioEliminar(
    p_user_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM public."User" WHERE id = p_user_id) THEN
        p_mensaje_resultado := 'ERROR: Usuario con ID ' || p_user_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."User" WHERE id = p_user_id;
    
    p_mensaje_resultado := 'SUCCESS: Usuario eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spVariableActualizar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spVariableActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spVariableActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT,
    p_is_for_all_clients BOOLEAN DEFAULT false
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."MasterVariable" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Variable con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."MasterVariable"
    SET "code" = p_code,
        "name" = p_name,
        "isForAllClients" = COALESCE(p_is_for_all_clients, false)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Variable actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spVariableCrear.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spVariableCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spVariableCrear(
    p_code TEXT,
    p_name TEXT,
    p_acting_user_id INT,
    INOUT p_variable_id INT,
    INOUT p_mensaje_resultado TEXT,
    p_is_for_all_clients BOOLEAN DEFAULT false
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."MasterVariable" ("code", "name", "isForAllClients")
    VALUES (p_code, p_name, COALESCE(p_is_for_all_clients, false))
    RETURNING id INTO p_variable_id;

    p_mensaje_resultado := 'SUCCESS: Variable creada con ID ' || p_variable_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spVariableEliminar.sql
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spVariableEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spVariableEliminar(
    p_id INT,
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."MasterVariable" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Variable con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."MasterVariable" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Variable eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;;

-- Inyectado automáticamente: spCotizacionDuplicar.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionDuplicar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spCotizacionDuplicar"(
    IN p_quotation_id INT,
    IN p_acting_user_id INT,
    INOUT p_new_quotation_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_internal_number TEXT;
    v_new_id INT;
    v_orig_quotation RECORD;
    v_orig_qp RECORD;
    v_new_qp_id INT;
    v_user_id INT := NULL;
BEGIN
    -- Validar existencia de la cotización origen
    SELECT * INTO v_orig_quotation 
    FROM public."Quotation" 
    WHERE id = p_quotation_id;

    IF v_orig_quotation.id IS NULL THEN
        p_mensaje_resultado := 'ERROR: Cotización origen no encontrada (ID ' || p_quotation_id || ').';
        RETURN;
    END IF;

    -- Validar si p_acting_user_id existe en la tabla User, de lo contrario usar el de la cotización origen
    IF p_acting_user_id IS NOT NULL THEN
        SELECT id INTO v_user_id FROM public."User" WHERE id = p_acting_user_id;
    END IF;

    IF v_user_id IS NULL THEN
        v_user_id := v_orig_quotation."userId";
    END IF;

    -- Generar consecutivo único interno
    v_internal_number := 'QUO-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 10000)::text;

    -- Insertar la cabecera duplicada de la cotización
    INSERT INTO public."Quotation" (
        "internalNumber", "date", "clientId", "currency", "exchangeRate",
        "branchId", "implantId", "sellerId", "ticketPrinterId",
        "baseCommissionable", "commissionPercentage", "chargesAndTaxes",
        "totalAmount", "userId", "state", "stateDescription", "stateUpdatedAt",
        "costoTotal", "valorBase", "utilidad", "comisionTotalPercentage",
        "comisionFreelancePercentage", "comisionFreelanceValue",
        "comisionPropiaPercentage", "comisionPropiaValue", "comisionUtilidadPercentage",
        "destination", "startDate", "endDate", "passenger", "paxAdults", "paxChildren",
        "reservationCode", "copyFieldsToProducts", "manualDescription"
    ) VALUES (
        v_internal_number, CURRENT_TIMESTAMP, v_orig_quotation."clientId", v_orig_quotation."currency", v_orig_quotation."exchangeRate",
        v_orig_quotation."branchId", v_orig_quotation."implantId", v_orig_quotation."sellerId", v_orig_quotation."ticketPrinterId",
        v_orig_quotation."baseCommissionable", v_orig_quotation."commissionPercentage", v_orig_quotation."chargesAndTaxes",
        v_orig_quotation."totalAmount", v_user_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP,
        v_orig_quotation."costoTotal", v_orig_quotation."valorBase", v_orig_quotation."utilidad", v_orig_quotation."comisionTotalPercentage",
        v_orig_quotation."comisionFreelancePercentage", v_orig_quotation."comisionFreelanceValue",
        v_orig_quotation."comisionPropiaPercentage", v_orig_quotation."comisionPropiaValue", v_orig_quotation."comisionUtilidadPercentage",
        v_orig_quotation."destination", v_orig_quotation."startDate", v_orig_quotation."endDate", v_orig_quotation."passenger", v_orig_quotation."paxAdults", v_orig_quotation."paxChildren",
        v_orig_quotation."reservationCode", v_orig_quotation."copyFieldsToProducts", v_orig_quotation."manualDescription"
    ) RETURNING id INTO v_new_id;

    -- Insertar registro inicial en el historial de estados
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (v_new_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP, v_user_id);

    -- Duplicar combos asociados
    INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
    SELECT v_new_id, "comboId"
    FROM public."QuotationCombo"
    WHERE "quotationId" = p_quotation_id;

    -- Duplicar servicios manuales si la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        INSERT INTO public."QuotationManualService" ("quotationId", "providerName", "serviceName", "cost", "salePrice", "utility")
        SELECT v_new_id, "providerName", "serviceName", "cost", "salePrice", "utility"
        FROM public."QuotationManualService"
        WHERE "quotationId" = p_quotation_id;
    END IF;

    -- Duplicar productos y sus detalles
    FOR v_orig_qp IN 
        SELECT * FROM public."QuotationProduct" WHERE "quotationId" = p_quotation_id
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission",
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_new_id, v_orig_qp."productId", v_orig_qp."quantity", v_orig_qp."price", v_orig_qp."cost", v_orig_qp."providerId", v_orig_qp."prestadoraId",
            v_orig_qp."checkInDate", v_orig_qp."checkOutDate", v_orig_qp."nights", v_orig_qp."paxAdults", v_orig_qp."paxChildren",
            v_orig_qp."serviceType", v_orig_qp."destination", v_orig_qp."reservationCode", v_orig_qp."sellerCommission",
            v_orig_qp."ticketPrinterCommission", v_orig_qp."comboId", v_orig_qp."mainTaxId", v_orig_qp."inNationality",
            v_orig_qp."service", v_orig_qp."servicios", v_orig_qp."descripcion", v_orig_qp."passenger"
        ) RETURNING id INTO v_new_qp_id;

        -- Duplicar Pasajeros del producto
        INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
        SELECT v_new_qp_id, "name", "document"
        FROM public."QuotationProductPassenger"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Impuestos del producto
        INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain")
        SELECT v_new_qp_id, "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
        FROM public."QuotationProductTax"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Variables del producto
        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
        SELECT v_new_qp_id, "masterVariableId", "value"
        FROM public."QuotationProductVariable"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Pagos del producto
        INSERT INTO public."QuotationProductPayment" ("quotationProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
        SELECT v_new_qp_id, "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
        FROM public."QuotationProductPayment"
        WHERE "quotationProductId" = v_orig_qp.id;

    END LOOP;

    p_new_quotation_id := v_new_id;
    p_mensaje_resultado := 'SUCCESS: Cotización duplicada correctamente con ID ' || v_new_id;

    -- Registrar en auditoría
    CALL public."spLogRegistrar"(
        v_user_id, 
        'QUOTATION', 
        'DUPLICATE', 
        'Se duplicó la cotización #' || p_quotation_id || ' generando la cotización #' || v_new_id || ' (' || v_internal_number || ')', 
        jsonb_build_object('sourceQuotationId', p_quotation_id, 'newQuotationId', v_new_id), 
        v_new_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;;

-- Inyectado automáticamente: spSiteModuleMasterToggle.sql
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS proc_name FROM pg_proc WHERE proname ILIKE 'public' LOOP
        BEGIN
            EXECUTE 'DROP PROCEDURE IF EXISTS ' || r.proc_name || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSiteModuleMasterToggle'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spSiteModuleMasterToggle"(
    p_type text,
    p_id integer,
    p_active boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF UPPER(p_type) = 'MENU' THEN
        UPDATE public."Menu"
        SET activo = p_active
        WHERE id = p_id;
    ELSIF UPPER(p_type) = 'MASTER' THEN
        UPDATE public."Master"
        SET inactivo = NOT p_active
        WHERE id = p_id;
    ELSE
        RAISE EXCEPTION 'Tipo no válido: %. Se requiere MENU o MASTER.', p_type;
    END IF;
END;
$$;;