-- 2.5. spImplantListar
IF OBJECT_ID('dbo.spImplantListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spImplantListar;
GO

CREATE PROCEDURE dbo.spImplantListar
    @p_branchId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.[id], i.[code], i.[name], i.[branchId], b.[name] AS [branchName], ISNULL(i.[isActive], 1) AS [isActive]
    FROM dbo.[Implant] i
    LEFT JOIN dbo.[Branch] b ON i.[branchId] = b.[id]
    WHERE (@p_branchId IS NULL OR i.[branchId] = @p_branchId)
    ORDER BY i.[name] ASC;
END;
GO
