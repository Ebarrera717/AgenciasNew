-- 2.31. spPreCotizacionCrear
IF OBJECT_ID('dbo.spPreCotizacionCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionCrear;
GO

CREATE PROCEDURE dbo.spPreCotizacionCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_pre_quotation_id INT = NULL OUTPUT,
    @p_consecutivo INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[PreQuotation]', RESEED, 0);
        END;

        DECLARE @branchId INT = TRY_CAST(JSON_VALUE(@p_data, '$.branchId') AS INT);
        DECLARE @clientId INT = TRY_CAST(JSON_VALUE(@p_data, '$.clientId') AS INT);
        DECLARE @clientNameText NVARCHAR(250) = JSON_VALUE(@p_data, '$.clientNameText');
        DECLARE @sellerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.sellerId') AS INT);
        DECLARE @ticketPrinterId INT = TRY_CAST(JSON_VALUE(@p_data, '$.ticketPrinterId') AS INT);
        DECLARE @providerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.providerId') AS INT);
        DECLARE @headerDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.headerDescription');
        DECLARE @quotationNotice NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.quotationNotice');
        DECLARE @preQuotationType NVARCHAR(100) = JSON_VALUE(@p_data, '$.preQuotationType');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @customFields NVARCHAR(MAX) = JSON_QUERY(@p_data, '$.customFields');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;
        IF @providerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerId)
            SET @providerId = NULL;

        DECLARE @nextConsecutivo INT = (SELECT ISNULL(MAX(consecutivo), 0) + 1 FROM dbo.[PreQuotation]);

        BEGIN TRANSACTION;

        INSERT INTO dbo.[PreQuotation] (
            consecutivo, branchId, clientId, clientNameText, sellerId, ticketPrinterId, providerId,
            headerDescription, quotationNotice, preQuotationType, startDate, endDate,
            [state], customFields, createdAt, updatedAt, userId
        ) VALUES (
            @nextConsecutivo, @branchId, @clientId, @clientNameText, @sellerId, @ticketPrinterId, @providerId,
            @headerDescription, @quotationNotice, @preQuotationType, @startDate, @endDate,
            N'PENDIENTE', @customFields, GETDATE(), GETDATE(), @actingUserId
        );

        SET @p_pre_quotation_id = SCOPE_IDENTITY();
        SET @p_consecutivo = @nextConsecutivo;

        INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
        VALUES (@p_pre_quotation_id, N'PENDIENTE', N'Creación de pre-cotización', GETDATE(), @actingUserId);

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización #', @p_consecutivo, N' creada correctamente');
        SELECT @p_pre_quotation_id AS p_pre_quotation_id, @p_consecutivo AS p_consecutivo, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_pre_quotation_id = 0;
        SET @p_consecutivo = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_pre_quotation_id, 0 AS p_consecutivo, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
