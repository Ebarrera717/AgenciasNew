-- 2.13. spChargeAndTaxListar
IF OBJECT_ID('dbo.spChargeAndTaxListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spChargeAndTaxListar;
GO

CREATE PROCEDURE dbo.spChargeAndTaxListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ct.[id], ct.[code], ct.[name], ct.[type], ct.[valueType], ct.[value], ISNULL(ct.[isActive], 1) AS [isActive]
    FROM dbo.[ChargeAndTax] ct
    ORDER BY ct.[orden] ASC, ct.[name] ASC;
END;
GO
