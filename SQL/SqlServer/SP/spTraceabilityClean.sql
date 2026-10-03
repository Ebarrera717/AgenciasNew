-- 2.24. spTraceabilityClean
IF OBJECT_ID('dbo.spTraceabilityClean', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTraceabilityClean;
GO

CREATE PROCEDURE dbo.spTraceabilityClean
    @p_days INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @cutoff DATETIME2 = DATEADD(day, -@p_days, GETDATE());
    DECLARE @deleted_logs INT = 0;
    DECLARE @deleted_sessions INT = 0;

    DELETE FROM dbo.[TraceabilityLog] WHERE createdAt < @cutoff;
    SET @deleted_logs = @@ROWCOUNT;

    DELETE FROM dbo.[TraceabilitySession] WHERE createdAt < @cutoff;
    SET @deleted_sessions = @@ROWCOUNT;

    SELECT CONCAT('SUCCESS: ', CAST(@deleted_sessions AS NVARCHAR(20)), ' sesiones y ', CAST(@deleted_logs AS NVARCHAR(20)), ' eventos de trazabilidad depurados anteriores a ', CAST(@p_days AS NVARCHAR(20)), ' días.') AS p_mensaje_resultado;
END;
GO
