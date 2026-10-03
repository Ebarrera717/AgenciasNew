-- 2.15. spUserListar
IF OBJECT_ID('dbo.spUserListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spUserListar;
GO

CREATE PROCEDURE dbo.spUserListar
    @p_roleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.[id], u.[name], u.[email], u.[roleId], r.[name] AS [roleName], u.[branchId], b.[name] AS [branchName], ISNULL(u.[isActive], 1) AS [isActive]
    FROM dbo.[User] u
    LEFT JOIN dbo.[Role] r ON u.[roleId] = r.[id]
    LEFT JOIN dbo.[Branch] b ON u.[branchId] = b.[id]
    WHERE (@p_roleId IS NULL OR u.[roleId] = @p_roleId)
    ORDER BY u.[name] ASC;
END;
GO
