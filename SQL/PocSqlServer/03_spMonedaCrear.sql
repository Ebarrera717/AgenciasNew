-- ============================================================================
-- PRUEBA DE CONCEPTO (PoC) MIGRACION SQL SERVER - AGENCIASNEW
-- Archivo: 03_spMonedaCrear.sql
-- Motor: Microsoft SQL Server (T-SQL)
-- ============================================================================

IF OBJECT_ID('dbo.spMonedaCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMonedaCrear;
GO

CREATE PROCEDURE dbo.spMonedaCrear
    @p_code NVARCHAR(10),
    @p_name NVARCHAR(100),
    @p_exchange_rate FLOAT = 1.0,
    @p_decimals INT = 2,
    @p_acting_user_id INT = NULL,
    @p_currency_id INT OUTPUT,
    @p_mensaje_resultado NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = @p_code)
        BEGIN
            SET @p_currency_id = 0;
            SET @p_mensaje_resultado = N'ERROR: El código de moneda ya está registrado';
            RETURN;
        END;

        INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
        VALUES (@p_code, @p_name, ISNULL(@p_exchange_rate, 1.0), ISNULL(@p_decimals, 2), 1);

        SET @p_currency_id = SCOPE_IDENTITY();
        SET @p_mensaje_resultado = CONCAT('SUCCESS: Moneda creada con ID ', @p_currency_id);
    END TRY
    BEGIN CATCH
        SET @p_currency_id = 0;
        SET @p_mensaje_resultado = CONCAT('ERROR: ', ERROR_MESSAGE());
    END CATCH;
END;
