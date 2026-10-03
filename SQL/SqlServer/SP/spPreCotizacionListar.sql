-- 2.30. spPreCotizacionListar
IF OBJECT_ID('dbo.spPreCotizacionListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionListar;
GO

CREATE PROCEDURE dbo.spPreCotizacionListar
    @p_search NVARCHAR(250) = NULL,
    @p_state NVARCHAR(50) = NULL,
    @p_branch_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        pq.[id],
        pq.[consecutivo],
        pq.[branchId],
        b.[name] AS [branchName],
        pq.[clientId],
        c.[name] AS [clientName],
        pq.[clientNameText],
        pq.[sellerId],
        s.[name] AS [sellerName],
        pq.[ticketPrinterId],
        tp.[name] AS [ticketPrinterName],
        pq.[providerId],
        prov.[name] AS [providerName],
        pq.[headerDescription],
        pq.[quotationNotice],
        pq.[noticeResponse],
        pq.[preQuotationType],
        pq.[startDate],
        pq.[endDate],
        pq.[state],
        pq.[customFields],
        pq.[convertedQuotationId],
        pq.[convertedUserId],
        cu.[name] AS [convertedUserName],
        pq.[convertedAt],
        pq.[createdAt],
        pq.[updatedAt],
        pq.[userId],
        u.[name] AS [userName]
    FROM dbo.[PreQuotation] pq
    LEFT JOIN dbo.[Branch] b ON pq.[branchId] = b.[id]
    LEFT JOIN dbo.[Client] c ON pq.[clientId] = c.[id]
    LEFT JOIN dbo.[Seller] s ON pq.[sellerId] = s.[id]
    LEFT JOIN dbo.[TicketPrinter] tp ON pq.[ticketPrinterId] = tp.[id]
    LEFT JOIN dbo.[Provider] prov ON pq.[providerId] = prov.[id]
    LEFT JOIN dbo.[User] u ON pq.[userId] = u.[id]
    LEFT JOIN dbo.[User] cu ON pq.[convertedUserId] = cu.[id]
    WHERE 
        (@p_search IS NULL OR LTRIM(RTRIM(@p_search)) = '' OR 
         CAST(pq.[consecutivo] AS NVARCHAR(50)) LIKE '%' + @p_search + '%' OR
         pq.[clientNameText] LIKE '%' + @p_search + '%' OR
         c.[name] LIKE '%' + @p_search + '%' OR
         pq.[headerDescription] LIKE '%' + @p_search + '%' OR
         pq.[quotationNotice] LIKE '%' + @p_search + '%')
        AND (@p_state IS NULL OR LTRIM(RTRIM(@p_state)) = '' OR pq.[state] = @p_state)
        AND (@p_branch_id IS NULL OR @p_branch_id = 0 OR pq.[branchId] = @p_branch_id)
    ORDER BY pq.[id] DESC;
END;
GO
