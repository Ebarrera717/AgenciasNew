IF OBJECT_ID('dbo.spQuotationStateActualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spQuotationStateActualizar;
GO

CREATE PROCEDURE dbo.spQuotationStateActualizar
    @p_id INT,
    @p_code NVARCHAR(50),
    @p_name NVARCHAR(100),
    @p_color NVARCHAR(50) = NULL,
    @p_isActive BIT = NULL,
    @p_acting_user_id INT = NULL,
    @p_mensaje_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @p_code = UPPER(LTRIM(RTRIM(@p_code)));
        SET @p_name = LTRIM(RTRIM(@p_name));

        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [id] = @p_id)
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El estado con ID ' + CAST(@p_id AS NVARCHAR(20)) + N' no existe.';
            RETURN;
        END

        IF @p_code IS NOT NULL AND @p_code <> '' AND EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = @p_code AND [id] <> @p_id)
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El código "' + @p_code + N'" ya existe.';
            RETURN;
        END

        UPDATE dbo.[QuotationState]
        SET [code] = CASE WHEN @p_code IS NOT NULL AND @p_code <> '' THEN @p_code ELSE [code] END,
            [name] = CASE WHEN @p_name IS NOT NULL AND @p_name <> '' THEN @p_name ELSE [name] END,
            [color] = ISNULL(@p_color, [color]),
            [isActive] = ISNULL(@p_isActive, [isActive])
        WHERE [id] = @p_id;

        SET @p_mensaje_resultado = N'SUCCESS: Estado de cotización actualizado correctamente.';
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = N'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO
