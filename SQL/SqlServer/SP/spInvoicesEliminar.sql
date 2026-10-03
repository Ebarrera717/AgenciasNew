-- 2.28. spInvoicesEliminar
IF OBJECT_ID('dbo.spInvoicesEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesEliminar;
GO

CREATE PROCEDURE dbo.spInvoicesEliminar
    @p_id INT,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Invoices] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: La factura con ID ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        UPDATE dbo.[Invoices]
        SET [state] = N'ANULADO'
        WHERE id = @p_id;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Factura anulada exitosamente (ID ', @p_id, N')');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
