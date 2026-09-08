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
$BODY$;
