-- ==========================================
-- Procedimiento Standalone: spQuotationStateEliminar.sql
-- ==========================================

IF OBJECT_ID('dbo.spQuotationStateEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spQuotationStateEliminar;
GO

CREATE PROCEDURE dbo.spQuotationStateEliminar
    @p_id INT,
    @p_acting_user_id INT = NULL,
    @p_mensaje_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [id] = @p_id)
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El estado con ID ' + CAST(@p_id AS NVARCHAR(20)) + N' no existe.';
            RETURN;
        END

        DELETE FROM dbo.[QuotationState] WHERE [id] = @p_id;

        SET @p_mensaje_resultado = N'SUCCESS: Estado de cotización eliminado correctamente.';
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = N'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO
