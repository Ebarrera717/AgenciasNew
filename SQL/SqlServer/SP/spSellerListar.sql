-- 2.6. spSellerListar
IF OBJECT_ID('dbo.spSellerListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spSellerListar;
GO

CREATE PROCEDURE dbo.spSellerListar
    @p_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.[id], s.[code], s.[name], s.[email], ISNULL(s.[isActive], 1) AS [isActive]
    FROM dbo.[Seller] s
    WHERE (@p_id IS NULL OR s.[id] = @p_id)
    ORDER BY s.[name] ASC;
END;
GO
