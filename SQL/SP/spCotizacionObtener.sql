IF OBJECT_ID('dbo.spCotizacionObtener', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionObtener;
GO

CREATE PROCEDURE dbo.spCotizacionObtener
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        q.[id],
        q.[internalNumber],
        q.[date],
        q.[clientId],
        q.[currency],
        q.[exchangeRate],
        q.[branchId],
        q.[implantId],
        q.[sellerId],
        q.[ticketPrinterId],
        q.[commissionPercentage],
        q.[chargesAndTaxes],
        q.[totalAmount],
        q.[destination],
        q.[startDate],
        q.[endDate],
        q.[passenger],
        q.[paxAdults],
        q.[paxChildren],
        q.[reservationCode],
        q.[copyFieldsToProducts],
        q.[manualDescription],
        ISNULL(q.[state], N'Nuevo') AS [state],
        q.[stateDescription],
        q.[stateUpdatedAt],
        (
            SELECT c.[id], c.[name], c.[document]
            FROM dbo.[Client] c
            WHERE c.[id] = q.[clientId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [clientJson],
        (
            SELECT s.[id], s.[name], s.[code]
            FROM dbo.[Seller] s
            WHERE s.[id] = q.[sellerId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [sellerJson],
        (
            SELECT b.[id], b.[name], b.[code]
            FROM dbo.[Branch] b
            WHERE b.[id] = q.[branchId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [branchJson],
        (
            SELECT imp.[id], imp.[name], imp.[code]
            FROM dbo.[Implant] imp
            WHERE imp.[id] = q.[implantId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [implantJson],
        (
            SELECT tp.[id], tp.[name], tp.[code]
            FROM dbo.[TicketPrinter] tp
            WHERE tp.[id] = q.[ticketPrinterId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [ticketPrinterJson],
        (
            SELECT 
                qp.[id],
                qp.[productId],
                qp.[providerId],
                qp.[prestadoraId],
                qp.[quantity],
                qp.[price],
                qp.[cost],
                qp.[checkInDate],
                qp.[checkOutDate],
                qp.[nights],
                qp.[paxAdults],
                qp.[paxChildren],
                qp.[serviceType],
                qp.[destination],
                qp.[reservationCode],
                qp.[sellerCommission],
                qp.[ticketPrinterCommission],
                qp.[comboId],
                qp.[mainTaxId],
                qp.[inNationality],
                qp.[service],
                qp.[servicios],
                qp.[descripcion],
                qp.[passenger],
                qp.[providerDueDate],
                qp.[providerInvoice],
                (
                    SELECT p.[id], p.[description], p.[code]
                    FROM dbo.[Product] p
                    WHERE p.[id] = qp.[productId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [productJson],
                (
                    SELECT prov.[id], prov.[name], prov.[code]
                    FROM dbo.[Provider] prov
                    WHERE prov.[id] = qp.[providerId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [providerJson],
                (
                    SELECT prest.[id], prest.[name], prest.[code]
                    FROM dbo.[Prestadora] prest
                    WHERE prest.[id] = qp.[prestadoraId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [prestadoraJson],
                (
                    SELECT qpax.[id], qpax.[name], qpax.[document]
                    FROM dbo.[QuotationProductPassenger] qpax
                    WHERE qpax.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [passengersJson],
                (
                    SELECT qvar.[id], qvar.[masterVariableId], qvar.[value]
                    FROM dbo.[QuotationProductVariable] qvar
                    WHERE qvar.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [variablesJson],
                (
                    SELECT qpt.[id], qpt.[chargeAndTaxId], qpt.[explicitAmount] AS [amount], qpt.[explicitAmount], ct.[code] AS [taxCode], ct.[name] AS [taxName]
                    FROM dbo.[QuotationProductTax] qpt
                    LEFT JOIN dbo.[ChargeAndTax] ct ON qpt.[chargeAndTaxId] = ct.[id]
                    WHERE qpt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [appliedTaxesJson],
                (
                    SELECT qpmt.[id], qpmt.[amount], qpmt.[paymentMethod], qpmt.[date], qpmt.[reference], qpmt.[creditCardId], qpmt.[cardNumber], qpmt.[authorizationCode], qpmt.[voucher], qpmt.[expirationDate]
                    FROM dbo.[QuotationProductPayment] qpmt
                    WHERE qpmt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [paymentsJson]
            FROM dbo.[QuotationProduct] qp
            WHERE qp.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [productsJson],
        (
            SELECT qc.[comboId] AS [id], qc.[comboId], cmb.[name]
            FROM dbo.[QuotationCombo] qc
            LEFT JOIN dbo.[Combo] cmb ON qc.[comboId] = cmb.[id]
            WHERE qc.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [combosJson],
        (
            SELECT ms.[id], ms.[serviceName] AS [name], ms.[serviceName], ms.[salePrice] AS [amount], ms.[salePrice], ms.[cost], ms.[utility], ms.[providerName]
            FROM dbo.[QuotationManualService] ms
            WHERE ms.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [manualServicesJson],
        (
            SELECT sh.[id], sh.[quotationId], sh.[state], sh.[description], sh.[userId], u.[name] AS [userName], sh.[createdAt]
            FROM dbo.[QuotationStateHistory] sh
            LEFT JOIN dbo.[User] u ON sh.[userId] = u.[id]
            WHERE sh.[quotationId] = q.[id]
            ORDER BY sh.[id] ASC
            FOR JSON PATH
        ) AS [stateHistoryJson]
    FROM dbo.[Quotation] q
    WHERE q.[id] = @p_id;
END;
GO
