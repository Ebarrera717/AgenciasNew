-- 2.41. spCotizacionActualizarEstadoManual
IF OBJECT_ID('dbo.spCotizacionActualizarEstadoManual', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizarEstadoManual;
GO

CREATE PROCEDURE dbo.spCotizacionActualizarEstadoManual
    @p_id INT,
    @p_state NVARCHAR(50),
    @p_description NVARCHAR(MAX) = NULL,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        UPDATE dbo.[Quotation]
        SET [state] = @p_state,
            [stateDescription] = ISNULL(@p_description, [stateDescription]),
            [stateUpdatedAt] = GETDATE()
        WHERE id = @p_id;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, [state], [description], createdAt, userId)
        VALUES (@p_id, @p_state, ISNULL(@p_description, CONCAT(N'Cambio de estado a ', @p_state)), GETDATE(), @p_acting_user_id);

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Estado de cotización #', @p_id, N' actualizado a ', @p_state);
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
