-- 2.33. spPreCotizacionEliminar
IF OBJECT_ID('dbo.spPreCotizacionEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionEliminar;
GO

CREATE PROCEDURE dbo.spPreCotizacionEliminar
    @p_id INT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Pre-Cotización no encontrada con ID ', @p_id);
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        BEGIN TRANSACTION;
        DELETE FROM dbo.[PreQuotationStateHistory] WHERE preQuotationId = @p_id;
        DELETE FROM dbo.[PreQuotation] WHERE id = @p_id;
        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización #', @p_id, N' eliminada correctamente');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
