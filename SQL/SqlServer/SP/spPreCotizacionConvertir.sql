-- 2.32. spPreCotizacionConvertir
IF OBJECT_ID('dbo.spPreCotizacionConvertir', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionConvertir;
GO

CREATE PROCEDURE dbo.spPreCotizacionConvertir
    @p_pre_quotation_id INT,
    @p_quotation_id INT = NULL,
    @p_acting_user_id INT = 1,
    @p_notice_response NVARCHAR(MAX) = NULL,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation] WHERE id = @p_pre_quotation_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Pre-Cotización con ID ', @p_pre_quotation_id, N' no existe');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        BEGIN TRANSACTION;

        IF @p_quotation_id IS NOT NULL AND @p_quotation_id > 0
        BEGIN
            UPDATE dbo.[PreQuotation]
            SET [state] = N'CONVERTIDA',
                convertedQuotationId = @p_quotation_id,
                convertedUserId = @actingUserId,
                convertedAt = GETDATE(),
                noticeResponse = ISNULL(@p_notice_response, noticeResponse),
                updatedAt = GETDATE()
            WHERE id = @p_pre_quotation_id;

            INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
            VALUES (@p_pre_quotation_id, N'CONVERTIDA', CONCAT(N'Convertida a Cotización #', @p_quotation_id), GETDATE(), @actingUserId);

            SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización convertida exitosamente a Cotización #', @p_quotation_id);
        END
        ELSE
        BEGIN
            UPDATE dbo.[PreQuotation]
            SET noticeResponse = ISNULL(@p_notice_response, noticeResponse),
                updatedAt = GETDATE()
            WHERE id = @p_pre_quotation_id;

            IF @p_notice_response IS NOT NULL AND TRIM(@p_notice_response) <> ''
            BEGIN
                INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
                VALUES (@p_pre_quotation_id, N'RESPUESTA_DUDA', CONCAT(N'Respuesta/Duda: ', @p_notice_response), GETDATE(), @actingUserId);
            END;

            SET @p_mensaje_resultado = N'SUCCESS: Respuesta / Duda registrada en la Pre-Cotización correctamente.';
        END;

        COMMIT TRANSACTION;
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
