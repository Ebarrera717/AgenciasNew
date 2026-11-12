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

    -- Auto-reparación de cotizaciones cuyo userId quedó en NULL o en el fallback 1 cuando el Tiqueteador corresponde a otro Usuario creador registrado
    UPDATE q_fix
    SET q_fix.[userId] = u2.[id]
    FROM dbo.[Quotation] q_fix
    JOIN dbo.[TicketPrinter] tp ON tp.[id] = q_fix.[ticketPrinterId]
    CROSS APPLY (
        SELECT TOP 1 u.[id]
        FROM dbo.[User] u
        WHERE u.[ticketPrinterId] = tp.[id]
           OR (NULLIF(LTRIM(RTRIM(tp.[email])), '') IS NOT NULL AND LOWER(LTRIM(RTRIM(u.[email]))) = LOWER(LTRIM(RTRIM(tp.[email]))))
           OR (NULLIF(LTRIM(RTRIM(tp.[name])), '') IS NOT NULL AND UPPER(LTRIM(RTRIM(u.[name]))) = UPPER(LTRIM(RTRIM(tp.[name]))))
        ORDER BY u.[id] ASC
    ) u2
    WHERE (q_fix.[userId] IS NULL OR q_fix.[userId] = 1)
      AND u2.[id] <> 1
      AND ISNULL(q_fix.[userId], 0) <> u2.[id];

    UPDATE qsh_fix
    SET qsh_fix.[userId] = q_src.[userId]
    FROM dbo.[QuotationStateHistory] qsh_fix
    JOIN dbo.[Quotation] q_src ON qsh_fix.[quotationId] = q_src.[id]
    WHERE qsh_fix.[state] = N'NUEVO'
      AND (qsh_fix.[userId] IS NULL OR qsh_fix.[userId] = 1)
      AND q_src.[userId] IS NOT NULL
      AND q_src.[userId] <> 1;

    SELECT 
        q.[id],
        q.[internalNumber],
        q.[date],
        c.[name] AS [clientName],
        COALESCE(
            (
                SELECT TOP 1 u_init.[name]
                FROM dbo.[QuotationStateHistory] qsh_init
                JOIN dbo.[User] u_init ON u_init.[id] = qsh_init.[userId]
                WHERE qsh_init.[quotationId] = q.[id]
                  AND qsh_init.[state] = N'NUEVO'
                  AND qsh_init.[userId] IS NOT NULL
                  AND (qsh_init.[userId] <> 1 OR q.[userId] = 1)
                ORDER BY qsh_init.[id] ASC
            ),
            u.[name],
            N'Sistema'
        ) AS [userName],
        q.[totalAmount],
        q.[currency],
        ISNULL(q.[state], N'NUEVO') AS [state],
        q.[stateDescription],
        q.[destination],
        q.[startDate],
        q.[endDate],
        q.[passenger],
        q.[reservationCode],
        q.[zeusInvoiceNumber],
        q.[zeusInvoiceDate],
        (
            SELECT TOP 1 qs.[color]
            FROM dbo.[QuotationState] qs
            WHERE UPPER(LTRIM(RTRIM(qs.[code]))) = UPPER(LTRIM(RTRIM(ISNULL(q.[state], 'NUEVO'))))
               OR UPPER(LTRIM(RTRIM(qs.[name]))) = UPPER(LTRIM(RTRIM(ISNULL(q.[state], 'NUEVO'))))
        ) AS [stateColor]
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
