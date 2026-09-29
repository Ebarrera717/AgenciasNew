-- ============================================================================
-- spInvoicesListar - Listado Completo de Facturas (SQL Server / T-SQL)
-- ============================================================================

IF OBJECT_ID('dbo.spInvoicesListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesListar;
GO

CREATE PROCEDURE dbo.spInvoicesListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        i.[id],
        i.[internalNumber],
        i.[date],
        i.[dueDate],
        i.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        ISNULL(NULLIF(i.[totalAmount], 0), 0) AS [totalAmount],
        ISNULL(i.[currency], 'COP') AS [currency],
        ISNULL(i.[state], 'NUEVO') AS [state],
        ISNULL(i.[isExcelImport], 0) AS [isExcelImport],
        i.[zeusInvoiceNumber],
        i.[fuente],
        i.[serie],
        i.[consecutivo],
        (
            SELECT TOP 1 ipp.[name]
            FROM dbo.[InvoicesProduct] ip
            JOIN dbo.[InvoicesProductPasenger] ipp ON ipp.[invoiceProductId] = ip.[id]
            WHERE ip.[invoiceId] = i.[id] AND ipp.[name] IS NOT NULL AND ipp.[name] <> ''
        ) AS [paxName],
        (
            SELECT TOP 1 ISNULL(prest.[name], prov.[name])
            FROM dbo.[InvoicesProduct] ip
            LEFT JOIN dbo.[Prestadora] prest ON ip.[prestadoraId] = prest.[id]
            LEFT JOIN dbo.[Provider] prov ON ip.[providerId] = prov.[id]
            WHERE ip.[invoiceId] = i.[id] AND (prest.[name] IS NOT NULL OR prov.[name] IS NOT NULL)
        ) AS [providerName],
        (
            SELECT MIN(ip.[checkInDate])
            FROM dbo.[InvoicesProduct] ip
            WHERE ip.[invoiceId] = i.[id]
        ) AS [checkInDate],
        (
            SELECT MAX(ip.[checkOutDate])
            FROM dbo.[InvoicesProduct] ip
            WHERE ip.[invoiceId] = i.[id]
        ) AS [checkOutDate]
    FROM dbo.[Invoices] i
    LEFT JOIN dbo.[Client] c ON i.[clientId] = c.[id]
    ORDER BY i.[date] DESC, i.[id] DESC;
END;
GO
