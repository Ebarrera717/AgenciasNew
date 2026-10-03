-- 2.19. spMenuListar
IF OBJECT_ID('dbo.spMenuListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMenuListar;
GO

CREATE PROCEDURE dbo.spMenuListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.[id], m.[code], m.[name], m.[parent], m.[action], ISNULL(m.[activo], 1) AS [activo]
    FROM dbo.[Menu] m
    ORDER BY m.[id] ASC;
END;
GO
