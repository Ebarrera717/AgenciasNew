-- 2.40. spCotizacionEliminar
IF OBJECT_ID('dbo.spCotizacionEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionEliminar;
GO

CREATE PROCEDURE dbo.spCotizacionEliminar
    @p_id INT,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización no encontrada con ID ', @p_id);
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @internalNumber NVARCHAR(100) = (SELECT internalNumber FROM dbo.[Quotation] WHERE id = @p_id);

        BEGIN TRANSACTION;

        DELETE FROM dbo.[QuotationProductTax] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductVariable] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductPayment] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProduct] WHERE quotationId = @p_id;
        DELETE FROM dbo.[QuotationCombo] WHERE quotationId = @p_id;
        IF OBJECT_ID('dbo.QuotationManualService', 'U') IS NOT NULL DELETE FROM dbo.[QuotationManualService] WHERE quotationId = @p_id;
        DELETE FROM dbo.[QuotationStateHistory] WHERE quotationId = @p_id;
        DELETE FROM dbo.[Quotation] WHERE id = @p_id;

        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización ', ISNULL(@internalNumber, CAST(@p_id AS NVARCHAR(20))), N' eliminada con éxito.');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
