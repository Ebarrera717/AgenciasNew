-- ============================================================================
-- spInvoicesObtener - Consulta Completa de Factura por ID (SQL Server / T-SQL)
-- ============================================================================

IF OBJECT_ID('dbo.spInvoicesObtener', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesObtener;
GO

CREATE PROCEDURE dbo.spInvoicesObtener
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Recordset 0: Cabecera Invoices
    SELECT 
        i.[id],
        i.[internalNumber],
        i.[date],
        i.[dueDate],
        i.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        i.[currency],
        i.[exchangeRate],
        i.[branchId],
        b.[name] AS [branchName],
        i.[implantId],
        imp.[name] AS [implantName],
        i.[sellerId],
        s.[name] AS [sellerName],
        i.[ticketPrinterId],
        tp.[name] AS [ticketPrinterName],
        i.[baseCommissionable],
        i.[commissionPercentage],
        i.[chargesAndTaxes],
        i.[totalAmount],
        i.[userId],
        u.[name] AS [userName],
        ISNULL(i.[state], N'NUEVO') AS [state],
        i.[fuente],
        i.[serie],
        i.[consecutivo],
        ISNULL(i.[isExcelImport], 0) AS [isExcelImport],
        i.[zeusInvoiceNumber]
    FROM dbo.[Invoices] i
    LEFT JOIN dbo.[Client] c ON i.[clientId] = c.[id]
    LEFT JOIN dbo.[Branch] b ON i.[branchId] = b.[id]
    LEFT JOIN dbo.[Implant] imp ON i.[implantId] = imp.[id]
    LEFT JOIN dbo.[Seller] s ON i.[sellerId] = s.[id]
    LEFT JOIN dbo.[TicketPrinter] tp ON i.[ticketPrinterId] = tp.[id]
    LEFT JOIN dbo.[User] u ON i.[userId] = u.[id]
    WHERE i.[id] = @p_id;

    -- Recordset 1: InvoicesProduct
    SELECT 
        ip.[id],
        ip.[invoiceId],
        ip.[productId],
        p.[description] AS [productName],
        p.[description] AS [productDescription],
        p.[code] AS [productCode],
        ip.[ticketCode],
        ip.[quantity],
        ip.[price],
        ip.[cost],
        ip.[providerId],
        prov.[name] AS [providerName],
        prov.[code] AS [providerCode],
        ip.[prestadoraId],
        prest.[name] AS [prestadoraName],
        prest.[code] AS [prestadoraCode],
        ip.[checkInDate],
        ip.[checkOutDate],
        ip.[nights],
        ip.[paxAdults],
        ip.[paxChildren],
        ip.[serviceType],
        ip.[destination],
        ip.[reservationCode],
        ip.[sellerCommission],
        ip.[ticketPrinterCommission],
        ip.[comboId],
        ip.[mainTaxId],
        ip.[inNationality],
        ip.[servicios],
        ip.[descripcion],
        ip.[itinerary],
        ip.[class],
        ip.[airline],
        ip.[ticketTypeId],
        ip.[providerDueDate],
        ip.[providerInvoice]
    FROM dbo.[InvoicesProduct] ip
    LEFT JOIN dbo.[Product] p ON ip.[productId] = p.[id]
    LEFT JOIN dbo.[Provider] prov ON ip.[providerId] = prov.[id]
    LEFT JOIN dbo.[Prestadora] prest ON ip.[prestadoraId] = prest.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ip.[id] ASC;

    -- Recordset 2: InvoicesProductTax
    SELECT 
        ipt.[id],
        ipt.[invoiceProductId],
        ipt.[chargeAndTaxId],
        ct.[code] AS [taxCode],
        ct.[name] AS [taxName],
        ct.[type] AS [taxType],
        ct.[valueType] AS [taxValueType],
        ISNULL(ipt.[explicitAmount], 0) AS [explicitAmount],
        ISNULL(ipt.[explicitAmount], 0) AS [amount],
        ISNULL(ipt.[rate], 0) AS [rate]
    FROM dbo.[InvoicesProductTax] ipt
    JOIN dbo.[InvoicesProduct] ip ON ipt.[invoiceProductId] = ip.[id]
    LEFT JOIN dbo.[ChargeAndTax] ct ON ipt.[chargeAndTaxId] = ct.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipt.[id] ASC;

    -- Recordset 3: InvoicesProductPasenger
    SELECT 
        ipp.[id],
        ipp.[invoiceProductId],
        ipp.[name],
        ipp.[document]
    FROM dbo.[InvoicesProductPasenger] ipp
    JOIN dbo.[InvoicesProduct] ip ON ipp.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipp.[id] ASC;

    -- Recordset 4: InvoicesProductVariable
    SELECT 
        ipv.[id],
        ipv.[invoiceProductId],
        ipv.[masterVariableId],
        mv.[code] AS [variableCode],
        mv.[name] AS [variableName],
        ipv.[value]
    FROM dbo.[InvoicesProductVariable] ipv
    JOIN dbo.[InvoicesProduct] ip ON ipv.[invoiceProductId] = ip.[id]
    LEFT JOIN dbo.[MasterVariable] mv ON ipv.[masterVariableId] = mv.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipv.[id] ASC;

    -- Recordset 5: InvoicesProductPayment
    SELECT 
        ippay.[id],
        ippay.[invoiceProductId],
        ippay.[amount],
        ippay.[paymentMethod],
        ippay.[date],
        ippay.[reference],
        ippay.[creditCardId],
        ippay.[authorizationCode],
        ippay.[voucher],
        ippay.[cardNumber],
        ippay.[expirationDate]
    FROM dbo.[InvoicesProductPayment] ippay
    JOIN dbo.[InvoicesProduct] ip ON ippay.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ippay.[id] ASC;

    -- Recordset 6: InvoicesProductItinerary
    SELECT 
        ipi.[id],
        ipi.[invoiceProductId],
        ipi.[orden],
        ipi.[origin],
        ipi.[destination],
        ipi.[class],
        ipi.[checkInDate],
        ipi.[checkOutDate],
        ipi.[terminal],
        ipi.[prestadoraCode],
        ipi.[farebasis],
        ipi.[Numflight],
        ipi.[Typeflight],
        ipi.[amount],
        ipi.[co2]
    FROM dbo.[InvoicesProductItinerary] ipi
    JOIN dbo.[InvoicesProduct] ip ON ipi.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipi.[orden] ASC, ipi.[id] ASC;

    -- Recordset 7: InvoicesProductCombo
    SELECT 
        ipc.[id],
        ipc.[invoiceId],
        ipc.[comboId],
        cmb.[name] AS [comboName]
    FROM dbo.[InvoicesProductCombo] ipc
    LEFT JOIN dbo.[Combo] cmb ON ipc.[comboId] = cmb.[id]
    WHERE ipc.[invoiceId] = @p_id
    ORDER BY ipc.[id] ASC;
END;
GO
