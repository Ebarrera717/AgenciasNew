-- 2.14. spRoleListar
IF OBJECT_ID('dbo.spRoleListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spRoleListar;
GO

CREATE PROCEDURE dbo.spRoleListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.[id], r.[name], r.[description], r.[permissions], ISNULL(r.[isActive], 1) AS [isActive]
    FROM dbo.[Role] r
    ORDER BY r.[name] ASC;
END;
GO
