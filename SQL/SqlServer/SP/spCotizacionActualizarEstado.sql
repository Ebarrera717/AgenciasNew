-- 2.42. spCotizacionActualizarEstado
IF OBJECT_ID('dbo.spCotizacionActualizarEstado', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizarEstado;
GO

CREATE PROCEDURE dbo.spCotizacionActualizarEstado
    @p_response NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF ISJSON(@p_response) = 1
    BEGIN
        DECLARE @estadosStr NVARCHAR(MAX);
        DECLARE resp_cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT JSON_VALUE(value, '$.Estados') FROM OPENJSON(@p_response);

        OPEN resp_cur;
        FETCH NEXT FROM resp_cur INTO @estadosStr;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @estadosStr IS NOT NULL AND @estadosStr <> ''
            BEGIN
                DECLARE @item NVARCHAR(255);
                DECLARE item_cur CURSOR LOCAL FAST_FORWARD FOR
                SELECT value FROM STRING_SPLIT(@estadosStr, '|');

                OPEN item_cur;
                FETCH NEXT FROM item_cur INTO @item;

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    IF CHARINDEX(':', @item) > 0
                    BEGIN
                        DECLARE @idStr NVARCHAR(50) = SUBSTRING(@item, 1, CHARINDEX(':', @item) - 1);
                        DECLARE @estado NVARCHAR(50) = SUBSTRING(@item, CHARINDEX(':', @item) + 1, LEN(@item));
                        DECLARE @quotId INT = TRY_CAST(@idStr AS INT);
                        IF @quotId IS NOT NULL
                        BEGIN
                            UPDATE dbo.[Quotation]
                            SET [state] = @estado,
                                [stateUpdatedAt] = GETDATE()
                            WHERE id = @quotId;
                        END;
                    END;
                    FETCH NEXT FROM item_cur INTO @item;
                END;

                CLOSE item_cur;
                DEALLOCATE item_cur;
            END;

            FETCH NEXT FROM resp_cur INTO @estadosStr;
        END;

        CLOSE resp_cur;
        DEALLOCATE resp_cur;
    END;
END;
GO
