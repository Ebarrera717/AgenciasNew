-- ==========================================
-- Procedimiento Standalone: spMaestroImportar.sql
-- ==========================================

-- ============================================================================
-- AGENCIASNEW - IMPORTACION MASIVA DE MAESTROS EN SQL SERVER
-- Procedimiento: dbo.spMaestroImportar
-- ============================================================================

IF OBJECT_ID('dbo.spMaestroImportar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMaestroImportar;
GO

CREATE PROCEDURE dbo.spMaestroImportar
    @p_tipo NVARCHAR(100),
    @p_text_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(4000) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_count INT = 0;
    DECLARE @v_errors NVARCHAR(MAX) = '';
    DECLARE @c_line NVARCHAR(MAX);
    DECLARE @pos INT, @nextPos INT;
    
    -- Variables para columnas
    DECLARE @col1 NVARCHAR(500), @col2 NVARCHAR(500), @col3 NVARCHAR(500), 
            @col4 NVARCHAR(500), @col5 NVARCHAR(500), @col6 NVARCHAR(500);
    DECLARE @v_branch_id INT, @v_provider_id INT, @v_prov_type_id INT;

    -- Cursor manual sobre las líneas (\n)
    DECLARE @lines TABLE (id INT IDENTITY(1,1), lineText NVARCHAR(MAX));
    
    -- Separar líneas por LF / CRLF
    SET @p_text_data = REPLACE(@p_text_data, CHAR(13), '');
    
    INSERT INTO @lines (lineText)
    SELECT value FROM STRING_SPLIT(@p_text_data, CHAR(10))
    WHERE RTRIM(LTRIM(value)) <> '';

    DECLARE curLines CURSOR LOCAL FAST_FORWARD FOR 
    SELECT lineText FROM @lines ORDER BY id ASC;

    OPEN curLines;
    FETCH NEXT FROM curLines INTO @c_line;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @c_line = RTRIM(LTRIM(@c_line));
            IF @c_line <> ''
            BEGIN
                -- Parsear columnas delimitadas por '^'
                SET @col1 = NULL; SET @col2 = NULL; SET @col3 = NULL;
                SET @col4 = NULL; SET @col5 = NULL; SET @col6 = NULL;

                -- Extracción de hasta 6 columnas por '^'
                DECLARE @c_idx INT = 1;
                DECLARE @c_part NVARCHAR(MAX);
                DECLARE @c_remain NVARCHAR(MAX) = @c_line + '^';
                
                WHILE CHARINDEX('^', @c_remain) > 0 AND @c_idx <= 6
                BEGIN
                    SET @c_part = SUBSTRING(@c_remain, 1, CHARINDEX('^', @c_remain) - 1);
                    SET @c_remain = SUBSTRING(@c_remain, CHARINDEX('^', @c_remain) + 1, LEN(@c_remain));

                    IF @c_idx = 1 SET @col1 = RTRIM(LTRIM(@c_part));
                    ELSE IF @c_idx = 2 SET @col2 = RTRIM(LTRIM(@c_part));
                    ELSE IF @c_idx = 3 SET @col3 = RTRIM(LTRIM(@c_part));
                    ELSE IF @c_idx = 4 SET @col4 = RTRIM(LTRIM(@c_part));
                    ELSE IF @c_idx = 5 SET @col5 = RTRIM(LTRIM(@c_part));
                    ELSE IF @c_idx = 6 SET @col6 = RTRIM(LTRIM(@c_part));

                    SET @c_idx = @c_idx + 1;
                END

                -- Procesar según tipo de maestro
                IF @p_tipo = 'sucursales'
                BEGIN
                    -- col1: code, col2: name
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        IF EXISTS (SELECT 1 FROM dbo.[Branch] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[Branch] SET [name] = @col2, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[Branch] ([code], [name], [createdAt], [updatedAt]) VALUES (@col1, @col2, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'implants'
                BEGIN
                    -- col1: code, col2: name, col3: branchCode
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        SET @v_branch_id = NULL;
                        IF @col3 IS NOT NULL AND @col3 <> ''
                            SELECT TOP 1 @v_branch_id = id FROM dbo.[Branch] WHERE LOWER([code]) = LOWER(@col3);

                        IF EXISTS (SELECT 1 FROM dbo.[Implant] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[Implant] SET [name] = @col2, [branchId] = @v_branch_id, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[Implant] ([code], [name], [branchId], [createdAt], [updatedAt]) VALUES (@col1, @col2, @v_branch_id, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'vendedores'
                BEGIN
                    -- col1: name, col2: email, col3: code
                    IF @col1 IS NOT NULL
                    BEGIN
                        IF @col3 IS NOT NULL AND @col3 <> ''
                        BEGIN
                            IF EXISTS (SELECT 1 FROM dbo.[Seller] WHERE LOWER([code]) = LOWER(@col3))
                                UPDATE dbo.[Seller] SET [name] = @col1, [email] = NULLIF(@col2, ''), [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col3);
                            ELSE
                                INSERT INTO dbo.[Seller] ([code], [name], [email], [createdAt], [updatedAt]) VALUES (@col3, @col1, NULLIF(@col2, ''), GETDATE(), GETDATE());
                        END
                        ELSE
                        BEGIN
                            INSERT INTO dbo.[Seller] ([name], [email], [createdAt], [updatedAt]) VALUES (@col1, NULLIF(@col2, ''), GETDATE(), GETDATE());
                        END
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'tiqueteadores'
                BEGIN
                    -- col1: name, col2: email, col3: code
                    IF @col1 IS NOT NULL
                    BEGIN
                        IF @col3 IS NOT NULL AND @col3 <> ''
                        BEGIN
                            IF EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE LOWER([code]) = LOWER(@col3))
                                UPDATE dbo.[TicketPrinter] SET [name] = @col1, [email] = NULLIF(@col2, ''), [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col3);
                            ELSE
                                INSERT INTO dbo.[TicketPrinter] ([code], [name], [email], [createdAt], [updatedAt]) VALUES (@col3, @col1, NULLIF(@col2, ''), GETDATE(), GETDATE());
                        END
                        ELSE
                        BEGIN
                            INSERT INTO dbo.[TicketPrinter] ([name], [email], [createdAt], [updatedAt]) VALUES (@col1, NULLIF(@col2, ''), GETDATE(), GETDATE());
                        END
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'impuestos'
                BEGIN
                    -- col1: code, col2: name, col3: type, col4: valueType, col5: value, col6: inNationality
                    IF @col2 IS NOT NULL AND @col3 IS NOT NULL
                    BEGIN
                        DECLARE @v_val FLOAT = TRY_CAST(@col5 AS FLOAT);
                        DECLARE @v_inNat INT = ISNULL(TRY_CAST(@col6 AS INT), 1);

                        IF @col1 IS NOT NULL AND @col1 <> '' AND EXISTS (SELECT 1 FROM dbo.[ChargeAndTax] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[ChargeAndTax] SET [name] = @col2, [type] = @col3, [valueType] = @col4, [value] = @v_val, [inNationality] = @v_inNat, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[ChargeAndTax] ([code], [name], [type], [valueType], [value], [isEditable], [inNationality], [createdAt], [updatedAt]) 
                            VALUES (@col1, @col2, @col3, @col4, @v_val, 1, @v_inNat, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'clientes'
                BEGIN
                    -- col1: document, col2: name, col3: contactInfo, col4: address
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        IF EXISTS (SELECT 1 FROM dbo.[Client] WHERE LOWER([document]) = LOWER(@col1))
                            UPDATE dbo.[Client] SET [name] = @col2, [contactInfo] = @col3, [address] = @col4, [updatedAt] = GETDATE() WHERE LOWER([document]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[Client] ([document], [name], [contactInfo], [address], [createdAt], [updatedAt]) VALUES (@col1, @col2, @col3, @col4, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'proveedores'
                BEGIN
                    -- col1: code, col2: name, col3: contactInfo, col4: providerTypeCode, col5: airlineCode, col6: sigla
                    IF @col2 IS NOT NULL OR @col1 IS NOT NULL
                    BEGIN
                        SET @v_prov_type_id = NULL;
                        IF @col4 IS NOT NULL AND @col4 <> ''
                            SELECT TOP 1 @v_prov_type_id = id FROM dbo.[ProviderType] WHERE LOWER([code]) = LOWER(@col4) OR LOWER([name]) = LOWER(@col4);

                        IF @col1 IS NOT NULL AND @col1 <> '' AND EXISTS (SELECT 1 FROM dbo.[Provider] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[Provider] SET [name] = @col2, [contactInfo] = @col3, [providerTypeId] = ISNULL(@v_prov_type_id, [providerTypeId]), [airlineCode] = ISNULL(@col5, [airlineCode]), [sigla] = ISNULL(@col6, [sigla]), [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[Provider] ([code], [name], [contactInfo], [providerTypeId], [airlineCode], [sigla], [createdAt], [updatedAt]) VALUES (@col1, @col2, @col3, @v_prov_type_id, @col5, @col6, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'tipos-proveedores'
                BEGIN
                    -- col1: code, col2: name, col3: isAirline
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        DECLARE @v_isAir BIT = CASE WHEN UPPER(@col3) IN ('SI', 'S', 'TRUE', '1') THEN 1 ELSE 0 END;
                        IF EXISTS (SELECT 1 FROM dbo.[ProviderType] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[ProviderType] SET [name] = @col2, [isAirline] = @v_isAir, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[ProviderType] ([code], [name], [isAirline], [active], [createdAt], [updatedAt]) VALUES (@col1, @col2, @v_isAir, 1, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'productos'
                BEGIN
                    -- col1: description, col2: basePrice, col3: code, col4: type, col5: billingConcept, col6: serviceType
                    IF @col1 IS NOT NULL
                    BEGIN
                        DECLARE @v_price FLOAT = TRY_CAST(@col2 AS FLOAT);
                        DECLARE @v_type NVARCHAR(50) = ISNULL(@col4, 'SERVICE');

                        IF @col3 IS NOT NULL AND @col3 <> '' AND EXISTS (SELECT 1 FROM dbo.[Product] WHERE LOWER([code]) = LOWER(@col3))
                            UPDATE dbo.[Product] SET [type] = @v_type, [description] = @col1, [basePrice] = @v_price, [billingConcept] = @col5, [serviceType] = @col6, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col3);
                        ELSE
                            INSERT INTO dbo.[Product] ([code], [type], [description], [basePrice], [billingConcept], [serviceType], [createdAt], [updatedAt]) VALUES (@col3, @v_type, @col1, @v_price, @col5, @col6, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'prestadoras'
                BEGIN
                    -- col1: name, col2: providerCode, col3: code, col4: category, col5: location, col6: type
                    IF @col1 IS NOT NULL
                    BEGIN
                        SET @v_provider_id = NULL;
                        IF @col2 IS NOT NULL AND @col2 <> ''
                            SELECT TOP 1 @v_provider_id = id FROM dbo.[Provider] WHERE LOWER([code]) = LOWER(@col2) OR LOWER([name]) = LOWER(@col2);

                        DECLARE @v_pType NVARCHAR(50) = ISNULL(@col6, 'HOTEL');

                        IF @col3 IS NOT NULL AND @col3 <> '' AND EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE LOWER([code]) = LOWER(@col3))
                            UPDATE dbo.[Prestadora] SET [name] = @col1, [providerId] = @v_provider_id, [category] = @col4, [location] = @col5, [type] = @v_pType, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col3);
                        ELSE
                            INSERT INTO dbo.[Prestadora] ([name], [providerId], [code], [category], [location], [type], [createdAt], [updatedAt]) VALUES (@col1, @v_provider_id, @col3, @col4, @col5, @v_pType, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'variables'
                BEGIN
                    -- col1: code, col2: name
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        IF EXISTS (SELECT 1 FROM dbo.[MasterVariable] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[MasterVariable] SET [name] = @col2, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[MasterVariable] ([code], [name], [createdAt], [updatedAt]) VALUES (@col1, @col2, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END
                ELSE IF @p_tipo = 'parametros'
                BEGIN
                    -- col1: code, col2: name, col3: value
                    IF @col1 IS NOT NULL AND @col2 IS NOT NULL
                    BEGIN
                        IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE LOWER([code]) = LOWER(@col1))
                            UPDATE dbo.[SystemParameter] SET [name] = @col2, [value] = @col3, [updatedAt] = GETDATE() WHERE LOWER([code]) = LOWER(@col1);
                        ELSE
                            INSERT INTO dbo.[SystemParameter] ([code], [name], [value], [createdAt], [updatedAt]) VALUES (@col1, @col2, @col3, GETDATE(), GETDATE());
                        SET @v_count = @v_count + 1;
                    END
                END

            END
        END TRY
        BEGIN CATCH
            SET @v_errors = @v_errors + 'Error en fila [' + ISNULL(@c_line, '') + ']: ' + ERROR_MESSAGE() + '; ';
        END CATCH

        FETCH NEXT FROM curLines INTO @c_line;
    END

    CLOSE curLines;
    DEALLOCATE curLines;

    SET @p_mensaje_resultado = 'SUCCESS: Registros procesados: ' + CAST(@v_count AS NVARCHAR(20)) + '. ' + ISNULL(@v_errors, '');
END
GO
