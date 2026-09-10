const fs = require('fs');
const path = require('path');

function generateTsqlFunctionsAndSps() {
    console.log('\n================================================================');
    console.log('   GENERANDO COMPILADO DE FUNCIONES Y SPs T-SQL (SQL SERVER)    ');
    console.log('================================================================\n');

    const path03 = path.join(__dirname, '..', 'SQL', 'SqlServer', '03_Functions_And_SPs.sql');
    
    let spCotizaciones = '';
    let spFacturaciones = '';
    
    const pathSpCotizaciones = path.join(__dirname, '..', 'SQL', 'SP', 'spCotizacionesCrear.sql');
    const pathSpFacturaciones = path.join(__dirname, '..', 'SQL', 'SP', 'spFacturacionesCrear.sql');
    
    if (fs.existsSync(pathSpCotizaciones)) {
        spCotizaciones = fs.readFileSync(pathSpCotizaciones, 'utf8');
    }
    if (fs.existsSync(pathSpFacturaciones)) {
        spFacturaciones = fs.readFileSync(pathSpFacturaciones, 'utf8');
    }

    const baseContent = `-- ============================================================================
-- AGENCIASNEW - PROCEDIMIENTOS ALMACENADOS Y FUNCIONES EN SQL SERVER (T-SQL)
-- Archivo: SQL/SqlServer/03_Functions_And_SPs.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- SECCIÓN 1: FUNCIONES ESCALARES Y DE TABLA (T-SQL)
-- ============================================================================

-- 1.1. fnQuitarEspeciales
IF OBJECT_ID('dbo.fnQuitarEspeciales', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fnQuitarEspeciales;
GO

CREATE FUNCTION dbo.fnQuitarEspeciales
(
    @p_texto NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @p_texto IS NULL RETURN NULL;
    DECLARE @res NVARCHAR(MAX) = @p_texto;
    SET @res = REPLACE(@res, N'á', N'a');
    SET @res = REPLACE(@res, N'é', N'e');
    SET @res = REPLACE(@res, N'í', N'i');
    SET @res = REPLACE(@res, N'ó', N'o');
    SET @res = REPLACE(@res, N'ú', N'u');
    SET @res = REPLACE(@res, N'Á', N'A');
    SET @res = REPLACE(@res, N'É', N'E');
    SET @res = REPLACE(@res, N'Í', N'I');
    SET @res = REPLACE(@res, N'Ó', N'O');
    SET @res = REPLACE(@res, N'Ú', N'U');
    SET @res = REPLACE(@res, N'ñ', N'n');
    SET @res = REPLACE(@res, N'Ñ', N'N');
    RETURN @res;
END;
GO

-- 1.2. fnObtenerSiguienteConsecutivo
IF OBJECT_ID('dbo.fnObtenerSiguienteConsecutivo', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fnObtenerSiguienteConsecutivo;
GO

CREATE FUNCTION dbo.fnObtenerSiguienteConsecutivo
(
    @p_tipo NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @siguiente INT = 1;
    IF UPPER(@p_tipo) = N'COTIZACION'
    BEGIN
        SELECT @siguiente = ISNULL(MAX(id), 0) + 1 FROM dbo.[Quotation];
        RETURN N'COT-' + RIGHT('000000' + CAST(@siguiente AS NVARCHAR(10)), 6);
    END;
    IF UPPER(@p_tipo) = N'FACTURA'
    BEGIN
        SELECT @siguiente = ISNULL(MAX(id), 0) + 1 FROM dbo.[Invoices];
        RETURN N'FAC-' + RIGHT('000000' + CAST(@siguiente AS NVARCHAR(10)), 6);
    END;
    RETURN CAST(@siguiente AS NVARCHAR(50));
END;
GO

-- 1.3. fnInterfaceExtractParamValue
IF OBJECT_ID('dbo.fnInterfaceExtractParamValue', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fnInterfaceExtractParamValue;
GO

CREATE FUNCTION dbo.fnInterfaceExtractParamValue
(
    @p_paramsXml NVARCHAR(MAX),
    @p_paramCode NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @p_paramsXml IS NULL OR @p_paramCode IS NULL RETURN NULL;
    RETURN NULL;
END;
GO

-- ============================================================================
-- SECCIÓN 2: PROCEDIMIENTOS ALMACENADOS DE MAESTROS Y CATALOGOS (T-SQL)
-- ============================================================================

-- 2.1. spMonedaListar
IF OBJECT_ID('dbo.spMonedaListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMonedaListar;
GO

CREATE PROCEDURE dbo.spMonedaListar
    @p_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.[id],
        c.[code],
        c.[name],
        c.[exchangeRate],
        c.[decimals],
        ISNULL(c.[isActive], 1) AS [isActive]
    FROM dbo.[Currency] c
    WHERE (@p_id IS NULL OR c.[id] = @p_id)
    ORDER BY c.[code] ASC;
END;
GO

-- 2.2. spMonedaCrear
IF OBJECT_ID('dbo.spMonedaCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMonedaCrear;
GO

CREATE PROCEDURE dbo.spMonedaCrear
    @p_code NVARCHAR(10),
    @p_name NVARCHAR(100),
    @p_exchange_rate FLOAT = 1.0,
    @p_decimals INT = 2,
    @p_acting_user_id INT = NULL,
    @p_currency_id INT OUTPUT,
    @p_mensaje_resultado NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = @p_code)
        BEGIN
            SET @p_currency_id = 0;
            SET @p_mensaje_resultado = N'ERROR: El código de moneda ya está registrado';
            RETURN;
        END;

        INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
        VALUES (@p_code, @p_name, ISNULL(@p_exchange_rate, 1.0), ISNULL(@p_decimals, 2), 1);

        SET @p_currency_id = SCOPE_IDENTITY();
        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Moneda creada con ID ', @p_currency_id);
    END TRY
    BEGIN CATCH
        SET @p_currency_id = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
    END CATCH;
END;
GO

-- 2.3. spClienteListar
IF OBJECT_ID('dbo.spClienteListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spClienteListar;
GO

CREATE PROCEDURE dbo.spClienteListar
    @p_cliente NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.[id],
        c.[name],
        c.[document],
        c.[contactInfo],
        c.[address],
        c.[sellerId],
        s.[name] AS [sellerName],
        ISNULL(c.[isActive], 1) AS [isActive],
        ISNULL(c.[creditDays], 0) AS [creditDays]
    FROM dbo.[Client] c
    LEFT JOIN dbo.[Seller] s ON c.[sellerId] = s.[id]
    WHERE (@p_cliente IS NULL OR LTRIM(RTRIM(@p_cliente)) = '' OR c.[name] LIKE '%' + TRIM(@p_cliente) + '%' OR c.[document] LIKE '%' + TRIM(@p_cliente) + '%')
    ORDER BY c.[name] ASC;
END;
GO

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

-- 2.7. spProviderTypeListar
IF OBJECT_ID('dbo.spProviderTypeListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProviderTypeListar;
GO

CREATE PROCEDURE dbo.spProviderTypeListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pt.[id], pt.[code], pt.[name], pt.[isAirline], ISNULL(pt.[active], 1) AS [active]
    FROM dbo.[ProviderType] pt
    ORDER BY pt.[name] ASC;
END;
GO

-- 2.8. spProviderListar
IF OBJECT_ID('dbo.spProviderListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProviderListar;
GO

CREATE PROCEDURE dbo.spProviderListar
    @p_providerTypeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.[id], p.[code], p.[name], p.[contactInfo], p.[providerTypeId], pt.[name] AS [providerTypeName], ISNULL(p.[isActive], 1) AS [isActive]
    FROM dbo.[Provider] p
    LEFT JOIN dbo.[ProviderType] pt ON p.[providerTypeId] = pt.[id]
    WHERE (@p_providerTypeId IS NULL OR p.[providerTypeId] = @p_providerTypeId)
    ORDER BY p.[name] ASC;
END;
GO

-- 2.9. spPrestadoraListar
IF OBJECT_ID('dbo.spPrestadoraListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPrestadoraListar;
GO

CREATE PROCEDURE dbo.spPrestadoraListar
    @p_providerId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pr.[id], pr.[code], pr.[name], pr.[location], pr.[category], pr.[providerId], p.[name] AS [providerName], ISNULL(pr.[isActive], 1) AS [isActive]
    FROM dbo.[Prestadora] pr
    LEFT JOIN dbo.[Provider] p ON pr.[providerId] = p.[id]
    WHERE (@p_providerId IS NULL OR pr.[providerId] = @p_providerId)
    ORDER BY pr.[name] ASC;
END;
GO

-- 2.10. spTicketTypeListar
IF OBJECT_ID('dbo.spTicketTypeListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTicketTypeListar;
GO

CREATE PROCEDURE dbo.spTicketTypeListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT tt.[id], tt.[code], tt.[name], tt.[description], ISNULL(tt.[isActive], 1) AS [isActive]
    FROM dbo.[TicketType] tt
    ORDER BY tt.[name] ASC;
END;
GO

-- 2.11. spTicketPrinterListar
IF OBJECT_ID('dbo.spTicketPrinterListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTicketPrinterListar;
GO

CREATE PROCEDURE dbo.spTicketPrinterListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT tp.[id], tp.[code], tp.[name], tp.[email], ISNULL(tp.[isActive], 1) AS [isActive]
    FROM dbo.[TicketPrinter] tp
    ORDER BY tp.[name] ASC;
END;
GO

-- 2.12. spProductListar
IF OBJECT_ID('dbo.spProductListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductListar;
GO

CREATE PROCEDURE dbo.spProductListar
    @p_type NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pr.[id], pr.[code], pr.[type], pr.[description], pr.[basePrice], pr.[cost], ISNULL(pr.[isActive], 1) AS [isActive]
    FROM dbo.[Product] pr
    WHERE (@p_type IS NULL OR pr.[type] = @p_type)
    ORDER BY pr.[description] ASC;
END;
GO

-- 2.13. spChargeAndTaxListar
IF OBJECT_ID('dbo.spChargeAndTaxListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spChargeAndTaxListar;
GO

CREATE PROCEDURE dbo.spChargeAndTaxListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ct.[id], ct.[code], ct.[name], ct.[type], ct.[valueType], ct.[value], ISNULL(ct.[isActive], 1) AS [isActive]
    FROM dbo.[ChargeAndTax] ct
    ORDER BY ct.[orden] ASC, ct.[name] ASC;
END;
GO

-- 2.14. spRoleListar
IF OBJECT_ID('dbo.spRoleListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spRoleListar;
GO

CREATE PROCEDURE dbo.spRoleListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.[id], r.[name], r.[description], r.[permissions], ISNULL(r.[isActive], 1) AS [isActive]
    FROM dbo.[Role] r
    ORDER BY r.[name] ASC;
END;
GO

-- 2.15. spUserListar
IF OBJECT_ID('dbo.spUserListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spUserListar;
GO

CREATE PROCEDURE dbo.spUserListar
    @p_roleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.[id], u.[name], u.[email], u.[roleId], r.[name] AS [roleName], u.[branchId], b.[name] AS [branchName], ISNULL(u.[isActive], 1) AS [isActive]
    FROM dbo.[User] u
    LEFT JOIN dbo.[Role] r ON u.[roleId] = r.[id]
    LEFT JOIN dbo.[Branch] b ON u.[branchId] = b.[id]
    WHERE (@p_roleId IS NULL OR u.[roleId] = @p_roleId)
    ORDER BY u.[name] ASC;
END;
GO

-- 2.16. spCotizacionListar
IF OBJECT_ID('dbo.spCotizacionListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionListar;
GO

CREATE PROCEDURE dbo.spCotizacionListar
    @p_internalNumber NVARCHAR(50) = NULL,
    @p_clientId INT = NULL,
    @p_branchId INT = NULL,
    @p_state NVARCHAR(25) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        q.[id],
        q.[internalNumber],
        q.[date],
        q.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        q.[currency],
        q.[exchangeRate],
        q.[branchId],
        b.[name] AS [branchName],
        q.[totalAmount],
        ISNULL(q.[state], N'Nuevo') AS [state],
        q.[userId],
        u.[name] AS [userName]
    FROM dbo.[Quotation] q
    LEFT JOIN dbo.[Client] c ON q.[clientId] = c.[id]
    LEFT JOIN dbo.[Branch] b ON q.[branchId] = b.[id]
    LEFT JOIN dbo.[User] u ON q.[userId] = u.[id]
    WHERE (@p_internalNumber IS NULL OR q.[internalNumber] LIKE '%' + TRIM(@p_internalNumber) + '%')
      AND (@p_clientId IS NULL OR q.[clientId] = @p_clientId)
      AND (@p_branchId IS NULL OR q.[branchId] = @p_branchId)
      AND (@p_state IS NULL OR q.[state] = @p_state)
    ORDER BY q.[id] DESC;
END;
GO

-- 2.17. spInvoicesListar
IF OBJECT_ID('dbo.spInvoicesListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesListar;
GO

CREATE PROCEDURE dbo.spInvoicesListar
    @p_internalNumber NVARCHAR(100) = NULL,
    @p_clientId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.[id], i.[internalNumber], i.[date], i.[clientId], c.[name] AS [clientName], i.[currency], i.[totalAmount], ISNULL(i.[state], N'NUEVO') AS [state]
    FROM dbo.[Invoices] i
    LEFT JOIN dbo.[Client] c ON i.[clientId] = c.[id]
    WHERE (@p_internalNumber IS NULL OR i.[internalNumber] LIKE '%' + TRIM(@p_internalNumber) + '%')
      AND (@p_clientId IS NULL OR i.[clientId] = @p_clientId)
    ORDER BY i.[id] DESC;
END;
GO

-- 2.18. spParameterListar
IF OBJECT_ID('dbo.spParameterListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spParameterListar;
GO

CREATE PROCEDURE dbo.spParameterListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sp.[id], sp.[code], sp.[name], sp.[value]
    FROM dbo.[SystemParameter] sp
    ORDER BY sp.[code] ASC;
END;
GO

-- 2.19. spMenuListar
IF OBJECT_ID('dbo.spMenuListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMenuListar;
GO

CREATE PROCEDURE dbo.spMenuListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.[id], m.[code], m.[name], m.[parent], m.[action], ISNULL(m.[activo], 1) AS [activo]
    FROM dbo.[Menu] m
    ORDER BY m.[id] ASC;
END;
GO

-- 2.20. spMasterListar
IF OBJECT_ID('dbo.spMasterListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spMasterListar;
GO

CREATE PROCEDURE dbo.spMasterListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ma.[id], ma.[code], ma.[name], ISNULL(ma.[inactivo], 0) AS [inactivo]
    FROM dbo.[Master] ma
    ORDER BY ma.[name] ASC;
END;
GO

-- ============================================================================
-- SECCIÓN 3: PROCEDIMIENTOS ALMACENADOS DE INTEGRACIÓN ERP (ZEUS / STANDALONE)
-- ============================================================================

`;

    const fullScript = baseContent + '\n\n' + spCotizaciones + '\n\nGO\n\n' + spFacturaciones + '\n\nGO\n\nPRINT \'Procedimientos almacenados y funciones T-SQL compiladas exitosamente.\';\n';

    fs.writeFileSync(path03, fullScript, 'utf8');
    console.log('✅ SQL/SqlServer/03_Functions_And_SPs.sql ampliado y generado con éxito.');
}

if (require.main === module) {
    generateTsqlFunctionsAndSps();
}

module.exports = { generateTsqlFunctionsAndSps };
