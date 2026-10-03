-- 2.22. spTraceabilityList
IF OBJECT_ID('dbo.spTraceabilityList', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTraceabilityList;
GO

CREATE PROCEDURE dbo.spTraceabilityList
    @p_code NVARCHAR(50) = NULL,
    @p_user_id INT = NULL,
    @p_module NVARCHAR(100) = NULL,
    @p_status NVARCHAR(50) = NULL,
    @p_start_date DATETIME2 = NULL,
    @p_end_date DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 100
        s.id,
        s.code,
        s.userId,
        ISNULL(s.origin, 'WEB') AS origin,
        ISNULL(u.name, 'Sistema / Anonimo') AS userName,
        s.module,
        s.screen,
        s.action,
        s.process,
        s.status,
        ISNULL(s.totalDurationMs, 0) AS totalDurationMs,
        s.errorMessage,
        (SELECT COUNT(*) FROM dbo.[TraceabilityLog] l WHERE l.sessionId = s.id) AS eventCount,
        s.createdAt,
        s.updatedAt
    FROM dbo.[TraceabilitySession] s
    LEFT JOIN dbo.[User] u ON s.userId = u.id
    WHERE (@p_code IS NULL OR TRIM(@p_code) = '' OR s.code LIKE '%' + TRIM(@p_code) + '%')
      AND (@p_user_id IS NULL OR @p_user_id = 0 OR s.userId = @p_user_id)
      AND (@p_module IS NULL OR TRIM(@p_module) = '' OR s.module LIKE '%' + TRIM(@p_module) + '%')
      AND (@p_status IS NULL OR TRIM(@p_status) = '' OR s.status = TRIM(@p_status))
      AND (@p_start_date IS NULL OR s.createdAt >= @p_start_date)
      AND (@p_end_date IS NULL OR s.createdAt <= @p_end_date)
    ORDER BY s.createdAt DESC;
END;
GO
