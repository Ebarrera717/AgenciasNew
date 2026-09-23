
CREATE OR ALTER PROCEDURE [dbo].[spExportInvoices]
    @Envoices_id VARCHAR(MAX),
    @User_id INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje_resultado VARCHAR(MAX) = '';

    SET @Envoices_id = LTRIM(RTRIM(@Envoices_id));
    IF @Envoices_id IS NULL OR @Envoices_id = ''
    BEGIN
        SELECT 'ERROR: No se han proporcionado IDs de Facturacion válidos.' AS mensaje_resultado;
        RETURN;
    END;

    -- Validar Usuario
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @User_id)
    BEGIN
        SELECT TOP 1 @User_id = id FROM dbo.[User] WHERE isActive = 1 ORDER BY id ASC;
        IF @User_id IS NULL
        BEGIN
            SELECT TOP 1 @User_id = id FROM dbo.[User] ORDER BY id ASC;
            IF @User_id IS NULL
            BEGIN
                SELECT 'ERROR: No existen usuarios registrados en el sistema.' AS mensaje_resultado;
                RETURN;
            END;
        END;
    END;

    -- Parse IDs
    DECLARE @idsTable TABLE (id INT);
    INSERT INTO @idsTable (id)
    SELECT CAST(value AS INT)
    FROM STRING_SPLIT(@Envoices_id, ',')
    WHERE TRIM(value) <> '' AND ISNUMERIC(TRIM(value)) = 1;

    -- 0. Pre-validación: Factura ya exportada
    DECLARE @err_already_exported VARCHAR(MAX) = '';
    SELECT TOP 1 @err_already_exported = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + ' ya se encuentra exportada a Zeus ERP.'
    FROM dbo.[Invoices] e
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND e.state = 'EXPORTED';

    IF @err_already_exported IS NOT NULL AND @err_already_exported <> ''
    BEGIN
        SELECT @err_already_exported AS mensaje_resultado;
        RETURN;
    END;

    -- 0.1 Pre-validación: Cliente deshabilitado o inexistente en Zeus ERP
    DECLARE @err_client VARCHAR(MAX) = '';
    SELECT TOP 1 
        @err_client = 'ERROR: El cliente "' + ISNULL(c.name, 'DESCONOCIDO') + '" (NIT/Tercero ' + ISNULL(c.document, '') + ') no existe o se encuentra deshabilitado en Zeus ERP. Debe habilitarlo en el maestro de clientes de Zeus ERP antes de exportar la factura.'
    FROM dbo.[Invoices] e
    JOIN dbo.[Client] c ON e.clientId = c.id
    LEFT JOIN ZeusAgencias_23.dbo.CLIENTES zc ON LTRIM(RTRIM(zc.IDCLIENTE)) = LTRIM(RTRIM(c.document))
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND (zc.IDCLIENTE IS NULL OR zc.Deshabilitado = 1 OR zc.BLOQUEO = 1);

    IF @err_client IS NOT NULL AND @err_client <> ''
    BEGIN
        SELECT @err_client AS mensaje_resultado;
        RETURN;
    END;

    -- 0.2 Pre-validación: Conceptos de Facturación y Tipos de Servicio
    DECLARE @v_err_concept VARCHAR(MAX) = '';

    SELECT TOP 1 
        @v_err_concept = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
                         ' contiene el producto ''' + ISNULL(ep.descripcion, ISNULL(pr.description, 'SIN NOMBRE')) + 
                         ''' que no tiene asignado un Concepto de Facturación en Korex. Por favor asígnelo en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND ISNULL(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), '') = '';

    IF @v_err_concept IS NOT NULL AND @v_err_concept <> ''
    BEGIN
        SELECT @v_err_concept AS mensaje_resultado;
        RETURN;
    END;

    SELECT TOP 1 
        @v_err_concept = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
                         ' contiene el producto ''' + ISNULL(ep.descripcion, ISNULL(pr.description, 'SIN NOMBRE')) + 
                         ''' que no tiene asignada una Clasificación de Servicio en Korex. Por favor asígnela en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND ISNULL(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), ISNULL(NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), '')) = '';

    IF @v_err_concept IS NOT NULL AND @v_err_concept <> ''
    BEGIN
        SELECT @v_err_concept AS mensaje_resultado;
        RETURN;
    END;

    -- Construir XML para Zeus ERP
    DECLARE @xmlResult XML;

    SET @xmlResult = (
        SELECT 
            e.id AS [id_factura],
            '55' AS [cd_fuente],
            '33' AS [cd_serie],
            '' AS [cd_consecutivo],
            1 AS [cd_usuario],
            SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
            SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechacont],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_vence],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_tercero_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_tercero_nombre],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_cliente_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_nombre],
            COALESCE(NULLIF(RTRIM(zc.DIRECCION), ''), SUBSTRING(ISNULL(c.address, ''), 1, 150)) AS [ds_cliente_dir],
            COALESCE(NULLIF(RTRIM(zc.CIUDAD), ''), '') AS [ds_cliente_ciudad],
            COALESCE(NULLIF(RTRIM(zc.TELEFONO), ''), '') AS [ds_cliente_tel],
            COALESCE(NULLIF(RTRIM(zc.DIRECCION), ''), SUBSTRING(ISNULL(c.address, ''), 1, 150)) AS [ds_cliente_dirdesp],
            COALESCE(NULLIF(RTRIM(zc.EMAIL), ''), '') AS [ds_cliente_email],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_contacto],
            COALESCE(NULLIF(RTRIM(zc.EMAIL), ''), '') AS [ds_cliente_contacto_email],
            ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
            COALESCE(NULLIF(RTRIM(zc.IDVENDE), ''), SUBSTRING(ISNULL(s.code, 'OFP'), 1, 5)) AS [cd_vendedor],
            SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteador],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [am_tcambiousd],
            1 AS [id_tipoventa],
            '' AS [ds_Observacion],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [TotalFactura],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [ValorFactura],
            -- Items
            (
                SELECT 
                    e.id AS [id_factura],
                    ep.id AS [id_item],
                    'Hotel' AS [tipo_item],
                    3 AS [in_tipoitem],
                    ep.id AS [id_referencia_origen],
                    '' AS [cd_tiquete],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 250) AS [ds_descrip],
                    1 AS [in_nacionalidad],
                    '' AS [cd_cencosto],
                    '' AS [cd_auxiliar],
                    '' AS [cd_item],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            LEFT JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                            WHERE ipt.invoiceProductId = ep.id
                              AND (
                                  ipt.isMain = 1 OR
                                  (ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  ))
                              )
                        ), ISNULL(ep.price * ep.quantity, 0))
                    AS DECIMAL(18,2)) AS [am_tarifa],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            WHERE ipt.invoiceProductId = ep.id AND ct.code = 'IVA'
                        ), 0)
                    AS DECIMAL(18,2)) AS [am_iva],
                    CAST(0 AS DECIMAL(18,2)) AS [am_tua],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comb],
                    CAST(0 AS DECIMAL(18,2)) AS [am_vat],
                    CAST(0 AS DECIMAL(18,2)) AS [am_Comision],
                    -- Titular: primer pasajero con nombres y apellidos separados
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, 30)
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - 1)
                        ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) - 1)
                    END AS [ds_paxname],
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN ''
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1, 100)), 1, 30)
                        ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) + 1, 100)), 1, 30)
                    END AS [ds_paxape],
                    'SR' AS [ds_paxprefix],
                    '' AS [cd_tourcode],
                    0 AS [NumTktConj],
                    'ACT' AS [cd_TipoTiquete],
                    1 AS [id_air],
                    '' AS [ds_itinerario],
                    '' AS [ds_itinerarioaerolinea],
                    'Y' AS [ds_clases],
                    '' AS [ds_Observaciones],
                    CAST(0 AS DECIMAL(18,2)) AS [am_highfare],
                    CAST(0 AS DECIMAL(18,2)) AS [am_lowfare],
                    '' AS [ds_solicita],
                    '' AS [ds_lapsoviaje],
                    '' AS [cd_tktrevisado],
                    '' AS [cd_PasaportePax],
                    '' AS [cd_pax_CC],
                    CAST(100.0 AS DECIMAL(18,2)) AS [am_PorFacParcial],
                    ISNULL(ep.paxAdults, 1) AS [in_cantpax],
                    '' AS [cd_FormaPagoTAO],
                    '' AS [cd_TarjetaCreditoTAO],
                    '' AS [cd_NumeroTarjetaTAO],
                    '' AS [cd_VencimientoTarjetaTAO],
                    '' AS [cd_NumeroPolizaTAO],
                    '' AS [cd_AnexoPolizaTAO],
                    '' AS [ds_AutorizacionTarjetaTAO],
                    0 AS [in_cuotasTarjetaTAO],
                    'EFE' AS [cd_FormasPago],
                    '' AS [cd_TarjetasCredito],
                    CAST(
                        ISNULL(
                            (SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id),
                            ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                        )
                    AS DECIMAL(18,2)) AS [am_fp1],
                    '' AS [ds_cc_code],
                    '' AS [ds_cc_number],
                    '' AS [ds_cc_vence],
                    '' AS [ds_cc_autorizacion],
                    '' AS [ds_cc_voucher],
                    0 AS [in_cc_cuotas],
                    CAST(0 AS DECIMAL(18,2)) AS [am_fp2],
                    '' AS [ds_cc_code2],
                    '' AS [ds_cc_number2],
                    '' AS [ds_cc_vence2],
                    '' AS [ds_cc_autorizacion2],
                    '' AS [ds_cc_voucher2],
                    0 AS [in_cc_cuotas2],
                    ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
                    CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
                    SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
                    SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
                    0 AS [bl_ahorro],
                    'ACT' AS [cd_TipoTiqueteGDS],
                    '' AS [cd_TiposDocumento],
                    '' AS [cd_entdist],
                    '' AS [cd_entvend],
                    'BOG' AS [cd_destino],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechaexped],
                    SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteadores],
                    1 AS [id_gds],
                    1 AS [iden_gds],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comisionPNR],
                    '' AS [ds_records],
                    0 AS [bl_NoCalcComision],
                    0 AS [bl_NoCalcIvaComision],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            WHERE ipt.invoiceProductId = ep.id AND ipt.isMain = 1
                        ), ISNULL(ep.price, 0))
                    AS DECIMAL(18,2)) AS [am_basecomisionable],
                    CAST(0 AS DECIMAL(18,2)) AS [am_porcomision],
                    '2' AS [cd_tiposconceptfac],
                    LTRIM(RTRIM(pr.billingConcept)) AS [cd_conceptofacturacion],
                    COALESCE(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), NULLIF(LTRIM(RTRIM(pr.serviceType)), '')) AS [cd_tiposservicio],
                    SUBSTRING(ISNULL(prv.code, '01'), 1, 25) AS [cd_proveedores],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 250) AS [ds_servicio],
                    CAST(
                        (
                            ISNULL(ep.price * ep.quantity, 0) +
                            ISNULL((
                                SELECT SUM(ipt2.explicitAmount)
                                FROM dbo.[InvoicesProductTax] ipt2
                                JOIN dbo.[ChargeAndTax] ct2 ON ct2.id = ipt2.chargeAndTaxId
                                LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct2.targetTaxId
                                WHERE ipt2.invoiceProductId = ep.id
                                  AND ipt2.isMain = 0
                                  AND ct2.targetTaxId IS NOT NULL
                                  AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  )
                            ), 0) +
                            CASE WHEN ISNULL(ep.price, 0) = 0 THEN
                                ISNULL((
                                    SELECT SUM(ipt3.explicitAmount)
                                    FROM dbo.[InvoicesProductTax] ipt3
                                    WHERE ipt3.invoiceProductId = ep.id AND ipt3.isMain = 1
                                ), 0)
                            ELSE 0 END
                        )
                    AS DECIMAL(18,2)) AS [am_valorprov],
                    ISNULL(e.currency, 'COP') AS [cd_monedaprov],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [dt_llegada],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [dt_salida],
                    CAST(0 AS DECIMAL(18,2)) AS [am_pordescuento],
                    CAST(0 AS DECIMAL(18,2)) AS [am_basedescuento],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [Fecha_Salida],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [Fecha_Llegada],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_noches],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_dias],
                    '1' AS [id_tipoproveedor],
                    '1' AS [cd_tipoproveedor],
                    'GENERAL' AS [ds_tipoproveedor],
                    'I' + RIGHT('0000000' + CAST(ep.id AS VARCHAR), 7) AS [cd_consecutivo_variablesadicionales],
                    CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [am_valor_total],
                    -- Sub-nodo: Pasajeros (Todos los pasajeros con nombre y apellido divididos)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, 50)
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - 1)
                                ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) - 1)
                            END AS [ds_paxname],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN ''
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1, 100)), 1, 50)
                                ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) + 1, 100)), 1, 50)
                            END AS [ds_paxape],
                            'SR' AS [ds_paxprefix],
                            '' AS [ds_paxclasificacion],
                            '' AS [cd_voucherpax],
                            SUBSTRING(ISNULL(pp.document, c.document), 1, 50) AS [cd_paxidentificacion],
                            0 AS [in_edad],
                            '' AS [cd_tiquete]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPasenger] pp ON pp.invoiceProductId = ep.id
                        FOR XML PATH('Pasajeros'), TYPE
                    ),
                    -- Sub-nodo: Formaspago (Preservando montos individuales)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(p.code, CASE WHEN LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%' THEN 'TC' ELSE 'EFE' END) AS [cd_codigo],
                            ISNULL(ipp.paymentMethod, 'CONTADO') AS [ds_nombre],
                            CAST(
                                ISNULL(ipp.amount, 
                                    ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                                )
                            AS DECIMAL(18,2)) AS [am_valor]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPayment] ipp ON ipp.invoiceProductId = ep.id
                        LEFT JOIN dbo.[Payment] p ON LOWER(p.name) = LOWER(ipp.paymentMethod)
                        FOR XML PATH('Formaspago'), TYPE
                    ),
                    -- Sub-nodo: CargosImpuestos (Clasificando am_contado y am_credito por forma de pago)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(ct.code, 'TAR') AS [cd_codigo],
                            ISNULL(ct.name, 'Tarifa') AS [ds_nombre],
                            CASE WHEN ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%' THEN 'C' ELSE 'I' END AS [cd_tipo],
                            CAST(ISNULL(ct.value, 0) AS DECIMAL(18,4)) AS [am_porcentaje],
                            CAST(
                                (
                                    ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                    CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                        ISNULL((
                                            SELECT SUM(sub_t.explicitAmount)
                                            FROM dbo.[InvoicesProductTax] sub_t
                                            JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                            WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                              AND sub_t.isMain = 0
                                              AND sub_ct.targetTaxId = ct.id
                                        ), 0)
                                    ELSE 0 END
                                ) AS DECIMAL(18,2)
                            ) AS [am_valor],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                ELSE CAST(
                                    ROUND(
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) * 
                                        ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                        NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                    , 2) AS DECIMAL(18,2)
                                )
                            END AS [am_contado],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                ELSE CAST(
                                    (
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) - 
                                        ROUND(
                                            (
                                                ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                                CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                    ISNULL((
                                                        SELECT SUM(sub_t.explicitAmount)
                                                        FROM dbo.[InvoicesProductTax] sub_t
                                                        JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                        WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                          AND sub_t.isMain = 0
                                                          AND sub_ct.targetTaxId = ct.id
                                                    ), 0)
                                                ELSE 0 END
                                            ) * 
                                            ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                            NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                        , 2)
                                    ) AS DECIMAL(18,2)
                                )
                            END AS [am_credito],
                            ISNULL(ct.id, 1) AS [id_carg],
                            ISNULL(ct.id, 1) AS [id_imp],
                            CASE WHEN ct.code = 'IVA' THEN 1 ELSE 0 END AS [bl_iva],
                            1 AS [in_orden]
                        FROM dbo.[InvoicesProductTax] ipt
                        JOIN dbo.[ChargeAndTax] ct ON ipt.chargeAndTaxId = ct.id
                        LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                        WHERE ipt.invoiceProductId = ep.id
                          AND NOT (
                              ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                  target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                              )
                          )
                        FOR XML PATH('CargosImpuestos'), TYPE
                    ),
                    -- Sub-nodo: Variables (Variables Adicionales dinámicas de InvoicesProductVariable)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            CASE WHEN pr.type = 'Tiquete' THEN 1 ELSE 3 END AS [in_tipoitem],
                            CASE WHEN pr.type = 'Tiquete' THEN 'Tiquetes' ELSE 'FacturacionServicios' END AS [ds_maestro],
                            ISNULL(mv.name, mv.code) AS [ds_VariableAdicional],
                            ISNULL(ipv.value, '') AS [ds_valor],
                            ISNULL(mv.code, '') AS [cd_codigo]
                        FROM dbo.[InvoicesProductVariable] ipv
                        JOIN dbo.[MasterVariable] mv ON ipv.masterVariableId = mv.id
                        WHERE ipv.invoiceProductId = ep.id
                        FOR XML PATH('Variables'), TYPE
                    )
                FROM dbo.[InvoicesProduct] ep
                LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
                LEFT JOIN dbo.[Provider] prv ON ep.providerId = prv.id
                LEFT JOIN dbo.[InvoicesProductPasenger] pax1 ON pax1.id = (
                    SELECT MIN(pp_min.id) FROM dbo.[InvoicesProductPasenger] pp_min WHERE pp_min.invoiceProductId = ep.id
                )
                WHERE ep.invoiceId = e.id
                FOR XML PATH('Item'), TYPE
            )
        FROM dbo.[Invoices] e
        JOIN dbo.[Client] c ON e.clientId = c.id
        LEFT JOIN ZeusAgencias_23.dbo.CLIENTES zc ON LTRIM(RTRIM(zc.IDCLIENTE)) = LTRIM(RTRIM(c.document))
        JOIN dbo.[Branch] b ON e.branchId = b.id
        LEFT JOIN dbo.[Implant] imp ON e.implantId = imp.id
        LEFT JOIN dbo.[Seller] s ON e.sellerId = s.id
        LEFT JOIN dbo.[User] u ON e.userId = u.id
        LEFT JOIN dbo.[TicketPrinter] tp ON e.ticketPrinterId = tp.id
        WHERE e.id IN (SELECT id FROM @idsTable)
        FOR XML PATH('Facturacion'), ROOT('Facturaciones'), TYPE
    );

    DECLARE @v_xml VARCHAR(MAX) = CAST(@xmlResult AS VARCHAR(MAX));

    IF @v_xml IS NULL OR @v_xml = ''
    BEGIN
        SET @mensaje_resultado = 'ERROR: No se pudo construir la estructura XML para las facturas.';
    END
    ELSE
    BEGIN
        SET @mensaje_resultado = @v_xml;
    END

    SELECT @mensaje_resultado AS mensaje_resultado;
END;
    