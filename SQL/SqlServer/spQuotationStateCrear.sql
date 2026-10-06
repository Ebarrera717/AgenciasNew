IF OBJECT_ID('dbo.spQuotationStateCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spQuotationStateCrear;
GO

CREATE PROCEDURE dbo.spQuotationStateCrear
    @p_code NVARCHAR(50),
    @p_name NVARCHAR(100),
    @p_color NVARCHAR(50) = 'blue',
    @p_isActive BIT = 1,
    @p_acting_user_id INT = NULL,
    @p_id INT OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @p_code = UPPER(LTRIM(RTRIM(@p_code)));
        SET @p_name = LTRIM(RTRIM(@p_name));

        IF @p_code IS NULL OR @p_code = ''
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El código es obligatorio.';
            RETURN;
        END

        IF @p_name IS NULL OR @p_name = ''
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El nombre es obligatorio.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = @p_code)
        BEGIN
            SET @p_mensaje_resultado = N'ERROR: El código "' + @p_code + N'" ya existe.';
            RETURN;
        END

        INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive])
        VALUES (@p_code, @p_name, ISNULL(@p_color, 'blue'), ISNULL(@p_isActive, 1));

        SET @p_id = SCOPE_IDENTITY();
        SET @p_mensaje_resultado = N'SUCCESS: Estado de cotización creado correctamente.';
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = N'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO
