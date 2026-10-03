-- 2.35. spCotizacionHistorial
IF OBJECT_ID('dbo.spCotizacionHistorial', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionHistorial;
GO

CREATE PROCEDURE dbo.spCotizacionHistorial
    @p_referencia NVARCHAR(100) = NULL,
    @p_fecha_desde DATE = NULL,
    @p_fecha_hasta DATE = NULL,
    @p_cliente NVARCHAR(250) = NULL,
    @p_elaborado_por NVARCHAR(250) = NULL,
    @p_monto_total FLOAT = NULL,
    @p_estado NVARCHAR(50) = NULL,
    @p_reserva NVARCHAR(100) = NULL,
    @p_pasajero NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.[id],
        q.[internalNumber],
        q.[date],
        c.[name] AS [clientName],
        u.[name] AS [userName],
        q.[totalAmount],
        q.[currency],
        ISNULL(q.[state], N'NUEVO') AS [state],
        q.[stateDescription],
        q.[destination],
        q.[startDate],
        q.[endDate],
        q.[passenger],
        q.[reservationCode]
    FROM dbo.[Quotation] q
    LEFT JOIN dbo.[Client] c ON q.[clientId] = c.[id]
    LEFT JOIN dbo.[User] u ON q.[userId] = u.[id]
    WHERE 
        (@p_referencia IS NULL OR CAST(q.[id] AS NVARCHAR(50)) LIKE '%' + @p_referencia + '%' OR q.[internalNumber] LIKE '%' + @p_referencia + '%')
        AND (@p_fecha_desde IS NULL OR CAST(q.[date] AS DATE) >= @p_fecha_desde)
        AND (@p_fecha_hasta IS NULL OR CAST(q.[date] AS DATE) <= @p_fecha_hasta)
        AND (@p_cliente IS NULL OR LTRIM(RTRIM(@p_cliente)) = '' OR c.[name] LIKE '%' + @p_cliente + '%')
        AND (@p_elaborado_por IS NULL OR LTRIM(RTRIM(@p_elaborado_por)) = '' OR u.[name] LIKE '%' + @p_elaborado_por + '%')
        AND (@p_monto_total IS NULL OR q.[totalAmount] = @p_monto_total)
        AND (@p_estado IS NULL OR LTRIM(RTRIM(@p_estado)) = '' OR q.[state] LIKE '%' + @p_estado + '%')
        AND (@p_reserva IS NULL OR LTRIM(RTRIM(@p_reserva)) = '' OR q.[reservationCode] LIKE '%' + @p_reserva + '%')
        AND (@p_pasajero IS NULL OR LTRIM(RTRIM(@p_pasajero)) = '' OR q.[passenger] LIKE '%' + @p_pasajero + '%')
    ORDER BY q.[date] DESC;
END;
GO
