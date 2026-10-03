-- 2.34. spCotizacionListar
IF OBJECT_ID('dbo.spCotizacionListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionListar;
GO

CREATE PROCEDURE dbo.spCotizacionListar
    @p_referencia NVARCHAR(100) = NULL,
    @p_fecha_desde DATE = NULL,
    @p_fecha_hasta DATE = NULL,
    @p_cliente NVARCHAR(250) = NULL,
    @p_elaborado_por NVARCHAR(250) = NULL,
    @p_monto_total FLOAT = NULL,
    @p_estado NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.[id],
        q.[internalNumber],
        q.[date],
        q.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        q.[currency],
        q.[exchangeRate],
        ISNULL(NULLIF(q.[totalAmount], 0), 0) AS [totalAmount],
        ISNULL(q.[state], N'NUEVO') AS [state],
        q.[stateDescription],
        q.[stateUpdatedAt],
        q.[userId],
        u.[name] AS [userName],
        (
            SELECT c.[id], c.[name], c.[document]
            FROM dbo.[Client] c
            WHERE c.[id] = q.[clientId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [clientJson],
        (
            SELECT u.[id], u.[name]
            FROM dbo.[User] u
            WHERE u.[id] = q.[userId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [userJson],
        (
            SELECT 
                qp.[id],
                qp.[productId],
                qp.[providerId],
                qp.[prestadoraId],
                qp.[quantity],
                qp.[price],
                qp.[checkInDate],
                qp.[checkOutDate],
                qp.[inNationality],
                qp.[mainTaxId],
                (
                    SELECT p.[id], p.[description]
                    FROM dbo.[Product] p
                    WHERE p.[id] = qp.[productId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [productJson],
                (
                    SELECT prov.[id], prov.[name]
                    FROM dbo.[Provider] prov
                    WHERE prov.[id] = qp.[providerId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [providerJson],
                (
                    SELECT prest.[id], prest.[name]
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
                    SELECT qpt.[chargeAndTaxId], qpt.[explicitAmount], qpt.[isMain]
                    FROM dbo.[QuotationProductTax] qpt
                    WHERE qpt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [appliedTaxesJson]
            FROM dbo.[QuotationProduct] qp
            WHERE qp.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [productsJson]
    FROM dbo.[Quotation] q
    LEFT JOIN dbo.[Client] c ON q.[clientId] = c.[id]
    LEFT JOIN dbo.[User] u ON q.[userId] = u.[id]
    WHERE 
        (@p_referencia IS NULL OR CAST(q.[id] AS NVARCHAR(50)) LIKE '%' + @p_referencia + '%' OR q.[internalNumber] LIKE '%' + @p_referencia + '%')
        AND (@p_fecha_desde IS NULL OR CAST(q.[date] AS DATE) >= @p_fecha_desde)
        AND (@p_fecha_hasta IS NULL OR CAST(q.[date] AS DATE) <= @p_fecha_hasta)
        AND (@p_cliente IS NULL OR LTRIM(RTRIM(@p_cliente)) = '' OR c.[name] LIKE '%' + @p_cliente + '%')
        AND (@p_elaborado_por IS NULL OR LTRIM(RTRIM(@p_elaborado_por)) = '' OR u.[name] LIKE '%' + @p_elaborado_por + '%')
        AND (@p_monto_total IS NULL OR q.[totalAmount] = @p_monto_total)
        AND (@p_estado IS NULL OR LTRIM(RTRIM(@p_estado)) = '' OR q.[state] LIKE '%' + @p_estado + '%')
    ORDER BY q.[date] DESC;
END;
GO
