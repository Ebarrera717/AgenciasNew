-- 2.18. spParameterListar
IF OBJECT_ID('dbo.spParameterListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spParameterListar;
GO

CREATE PROCEDURE dbo.spParameterListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sp.[id], sp.[code], sp.[name], sp.[value]
    FROM dbo.[SystemParameter] sp
    ORDER BY sp.[code] ASC;
END;
GO
