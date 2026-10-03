-- 2.4. spBranchListar
IF OBJECT_ID('dbo.spBranchListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spBranchListar;
GO

CREATE PROCEDURE dbo.spBranchListar
    @p_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT b.[id], b.[code], b.[name], ISNULL(b.[isActive], 1) AS [isActive]
    FROM dbo.[Branch] b
    WHERE (@p_id IS NULL OR b.[id] = @p_id)
    ORDER BY b.[name] ASC;
END;
GO
