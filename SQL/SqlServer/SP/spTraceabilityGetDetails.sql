-- 2.23. spTraceabilityGetDetails
IF OBJECT_ID('dbo.spTraceabilityGetDetails', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTraceabilityGetDetails;
GO

CREATE PROCEDURE dbo.spTraceabilityGetDetails
    @p_code NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        l.id AS log_id,
        l.code AS session_code,
        l.userId,
        ISNULL(l.origin, 'WEB') AS origin,
        ISNULL(u.name, 'Sistema / Anonimo') AS userName,
        l.eventType,
        l.stepName,
        l.spName,
        l.endpoint,
        ISNULL(l.durationMs, 0) AS durationMs,
        l.status,
        l.inputData,
        l.outputData,
        l.techMessage,
        l.functionalMessage,
        l.stackTrace,
        l.affectedId,
        l.createdAt
    FROM dbo.[TraceabilityLog] l
    LEFT JOIN dbo.[User] u ON l.userId = u.id
    WHERE l.code = @p_code OR l.sessionId IN (SELECT id FROM dbo.[TraceabilitySession] WHERE code = @p_code)
    ORDER BY l.id ASC;
END;
GO
