-- ============================================================================
-- AGENCIASNEW - PROCEDIMIENTOS ALMACENADOS Y FUNCIONES EN SQL SERVER (T-SQL)
-- Archivo: SQL/SqlServer/03_Functions_And_SPs.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Safeguards de Columnas para Tablas de Zeus ERP y Korex
IF OBJECT_ID('dbo.ImpRet', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo') ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
GO
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'cd_vendedor') ALTER TABLE dbo.Facturas ADD cd_vendedor VARCHAR(25) NULL;
GO
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_tiqueteador') ALTER TABLE dbo.Facturas ADD id_tiqueteador INT NULL;
GO
IF OBJECT_ID('dbo.TipoProveedores', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TipoProveedores') AND name = 'ds_descrip') ALTER TABLE dbo.TipoProveedores ADD ds_descrip VARCHAR(250) NULL;
GO
IF OBJECT_ID('dbo.ConceptoFacturacion', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ConceptoFacturacion') AND name = 'id_TiposConceptoFacturacion') ALTER TABLE dbo.ConceptoFacturacion ADD id_TiposConceptoFacturacion INT NULL DEFAULT 2;
GO
IF OBJECT_ID('dbo.VariableDefinicionMaestro', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicionMaestro') AND name = 'IDEN') ALTER TABLE dbo.VariableDefinicionMaestro ADD IDEN INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicionMaestro') AND name = 'Codigo') ALTER TABLE dbo.VariableDefinicionMaestro ADD Codigo VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicionMaestro') AND name = 'Nombre') ALTER TABLE dbo.VariableDefinicionMaestro ADD Nombre VARCHAR(250) NULL;
END;
GO
IF OBJECT_ID('dbo.VariableDefinicion', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'IDEN') ALTER TABLE dbo.VariableDefinicion ADD IDEN INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Codigo') ALTER TABLE dbo.VariableDefinicion ADD Codigo VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Nombre') ALTER TABLE dbo.VariableDefinicion ADD Nombre VARCHAR(250) NULL;
END;
GO

-- Safeguards para dbo.Cotizacion
IF OBJECT_ID('dbo.Cotizacion', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_sucursal') ALTER TABLE dbo.Cotizacion ADD id_sucursal INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_implante') ALTER TABLE dbo.Cotizacion ADD id_implante INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_consecutivo') ALTER TABLE dbo.Cotizacion ADD cd_consecutivo VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_usuario') ALTER TABLE dbo.Cotizacion ADD id_usuario INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_fechacont') ALTER TABLE dbo.Cotizacion ADD dt_fechacont SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_fecha') ALTER TABLE dbo.Cotizacion ADD dt_fecha SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_usuarioAct') ALTER TABLE dbo.Cotizacion ADD id_usuarioAct INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_fechaAct') ALTER TABLE dbo.Cotizacion ADD dt_fechaAct SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_usuarioAct') ALTER TABLE dbo.Cotizacion ADD cd_usuarioAct VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_vence') ALTER TABLE dbo.Cotizacion ADD dt_vence SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tercero_codigo') ALTER TABLE dbo.Cotizacion ADD cd_tercero_codigo VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_tercero_nombre') ALTER TABLE dbo.Cotizacion ADD ds_tercero_nombre VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_cliente_codigo') ALTER TABLE dbo.Cotizacion ADD cd_cliente_codigo VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_nombre') ALTER TABLE dbo.Cotizacion ADD ds_cliente_nombre VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_dir') ALTER TABLE dbo.Cotizacion ADD ds_cliente_dir VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_ciudad') ALTER TABLE dbo.Cotizacion ADD ds_cliente_ciudad VARCHAR(40) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_tel') ALTER TABLE dbo.Cotizacion ADD ds_cliente_tel VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_dirdesp') ALTER TABLE dbo.Cotizacion ADD ds_cliente_dirdesp VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_email') ALTER TABLE dbo.Cotizacion ADD ds_cliente_email VARCHAR(60) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_contacto') ALTER TABLE dbo.Cotizacion ADD ds_cliente_contacto VARCHAR(40) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_contacto_email') ALTER TABLE dbo.Cotizacion ADD ds_cliente_contacto_email VARCHAR(60) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_monedas_IATA') ALTER TABLE dbo.Cotizacion ADD id_monedas_IATA INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'am_tcambio') ALTER TABLE dbo.Cotizacion ADD am_tcambio FLOAT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_vendedor') ALTER TABLE dbo.Cotizacion ADD cd_vendedor VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tiqueteador') ALTER TABLE dbo.Cotizacion ADD cd_tiqueteador VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tiqueteador') ALTER TABLE dbo.Cotizacion ADD id_tiqueteador INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tiqueteador_Facturador') ALTER TABLE dbo.Cotizacion ADD id_tiqueteador_Facturador INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'am_tcambiousd') ALTER TABLE dbo.Cotizacion ADD am_tcambiousd FLOAT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tipoventa') ALTER TABLE dbo.Cotizacion ADD id_tipoventa INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tipoventa') ALTER TABLE dbo.Cotizacion ADD cd_tipoventa VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_observacion') ALTER TABLE dbo.Cotizacion ADD ds_observacion VARCHAR(8000) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_Campo_libre1') ALTER TABLE dbo.Cotizacion ADD ds_Campo_libre1 VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_Campo_libre2') ALTER TABLE dbo.Cotizacion ADD ds_Campo_libre2 VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_estado') ALTER TABLE dbo.Cotizacion ADD in_estado INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_ManejaOpciones') ALTER TABLE dbo.Cotizacion ADD bl_ManejaOpciones BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_NumeroOpciones') ALTER TABLE dbo.Cotizacion ADD in_NumeroOpciones INT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_CerrarCotizacion') ALTER TABLE dbo.Cotizacion ADD bl_CerrarCotizacion BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_OpcionSeleccionada') ALTER TABLE dbo.Cotizacion ADD in_OpcionSeleccionada INT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_grupos') ALTER TABLE dbo.Cotizacion ADD bl_grupos BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'gk_sabre') ALTER TABLE dbo.Cotizacion ADD gk_sabre VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_Especialista') ALTER TABLE dbo.Cotizacion ADD id_Especialista INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_TipoFormaPagoProveedor') ALTER TABLE dbo.Cotizacion ADD id_TipoFormaPagoProveedor INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_MedioReservacion') ALTER TABLE dbo.Cotizacion ADD id_MedioReservacion INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_comisiona') ALTER TABLE dbo.Cotizacion ADD bl_comisiona BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_alertasolicitud') ALTER TABLE dbo.Cotizacion ADD ds_alertasolicitud VARCHAR(8000) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_FormaDePago') ALTER TABLE dbo.Cotizacion ADD ds_FormaDePago VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_entregadoCliente') ALTER TABLE dbo.Cotizacion ADD bl_entregadoCliente BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_entregadoCliente') ALTER TABLE dbo.Cotizacion ADD dt_entregadoCliente SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_sys_entidades') ALTER TABLE dbo.Cotizacion ADD id_sys_entidades INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_MonedaPagoDestino') ALTER TABLE dbo.Cotizacion ADD id_MonedaPagoDestino INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_FormaPagoDestino') ALTER TABLE dbo.Cotizacion ADD id_FormaPagoDestino INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_DocumentoPagoDestino') ALTER TABLE dbo.Cotizacion ADD ds_DocumentoPagoDestino VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'BL_fechaPagoDestino') ALTER TABLE dbo.Cotizacion ADD BL_fechaPagoDestino BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_CheckInPagoDestino') ALTER TABLE dbo.Cotizacion ADD dt_CheckInPagoDestino SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_CheckOutPagoDestino') ALTER TABLE dbo.Cotizacion ADD dt_CheckOutPagoDestino SMALLDATETIME NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_hotelTieneTiquete') ALTER TABLE dbo.Cotizacion ADD ds_hotelTieneTiquete VARCHAR(2) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_GDS') ALTER TABLE dbo.Cotizacion ADD ds_GDS VARCHAR(2) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_evento') ALTER TABLE dbo.Cotizacion ADD id_evento INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_Etapa') ALTER TABLE dbo.Cotizacion ADD cd_Etapa VARCHAR(25) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_Etapa') ALTER TABLE dbo.Cotizacion ADD id_Etapa INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_bloqueada') ALTER TABLE dbo.Cotizacion ADD bl_bloqueada BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_usuario_Bloqueo') ALTER TABLE dbo.Cotizacion ADD cd_usuario_Bloqueo VARCHAR(25) NULL;
END;
GO

-- Safeguards para dbo.CotizacionServicios
IF OBJECT_ID('dbo.CotizacionServicios', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_descrip') ALTER TABLE dbo.CotizacionServicios ADD ds_descrip VARCHAR(4000) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_servicio') ALTER TABLE dbo.CotizacionServicios ADD ds_servicio VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_tiposervnm') ALTER TABLE dbo.CotizacionServicios ADD ds_tiposervnm VARCHAR(50) NULL;
END;
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
    SELECT 
        pr.[id], 
        pr.[code], 
        pr.[type], 
        pr.[description], 
        pr.[basePrice], 
        pr.[cost], 
        pr.[billingConcept], 
        pr.[serviceType], 
        ISNULL(pr.[isActive], 1) AS [isActive]
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

-- 2.21. spTraceabilityLog
IF OBJECT_ID('dbo.spTraceabilityLog', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spTraceabilityLog;
GO

CREATE PROCEDURE dbo.spTraceabilityLog
    @p_code NVARCHAR(50),
    @p_user_id INT = NULL,
    @p_origin NVARCHAR(50) = 'WEB',
    @p_module NVARCHAR(100) = 'GENERAL',
    @p_screen NVARCHAR(100) = NULL,
    @p_action NVARCHAR(100) = 'EJECUCION',
    @p_process NVARCHAR(100) = NULL,
    @p_event_type NVARCHAR(50) = 'INFO',
    @p_step_name NVARCHAR(255) = 'PASO',
    @p_sp_name NVARCHAR(255) = NULL,
    @p_endpoint NVARCHAR(500) = NULL,
    @p_duration_ms FLOAT = 0,
    @p_status NVARCHAR(50) = 'SUCCESS',
    @p_input_data NVARCHAR(MAX) = NULL,
    @p_output_data NVARCHAR(MAX) = NULL,
    @p_tech_message NVARCHAR(MAX) = NULL,
    @p_functional_message NVARCHAR(MAX) = NULL,
    @p_stack_trace NVARCHAR(MAX) = NULL,
    @p_affected_id NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_session_id INT;
    DECLARE @v_mode NVARCHAR(50) = 'OFF';
    DECLARE @v_origin NVARCHAR(50) = ISNULL(NULLIF(TRIM(@p_origin), ''), 'WEB');

    SELECT TOP 1 @v_mode = UPPER([value]) FROM dbo.[SystemParameter] WHERE UPPER([code]) = 'TRACEABILITY_MODE';
    SET @v_mode = ISNULL(@v_mode, 'OFF');

    IF @v_mode = 'OFF' AND UPPER(ISNULL(@p_event_type, '')) NOT IN ('ERROR', 'EXCEPCION')
    BEGIN
        RETURN;
    END;

    SELECT TOP 1 @v_session_id = id FROM dbo.[TraceabilitySession] WHERE code = @p_code;

    IF @v_session_id IS NULL
    BEGIN
        INSERT INTO dbo.[TraceabilitySession] (
            [code], [userId], [origin], [module], [screen], [action], [process], [status], [errorMessage]
        ) VALUES (
            @p_code, @p_user_id, @v_origin, ISNULL(@p_module, 'GENERAL'), @p_screen, ISNULL(@p_action, 'EJECUCION'), @p_process,
            CASE 
                WHEN UPPER(ISNULL(@p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(ISNULL(@p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(ISNULL(@p_status, '')) = 'SUCCESS' OR UPPER(ISNULL(@p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE ISNULL(@p_status, 'IN_PROGRESS')
            END,
            CASE WHEN UPPER(ISNULL(@p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN ISNULL(@p_functional_message, @p_tech_message) ELSE NULL END
        );
        SET @v_session_id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.[TraceabilitySession] SET
            [updatedAt] = GETDATE(),
            [origin] = ISNULL(@v_origin, [origin]),
            [totalDurationMs] = ISNULL([totalDurationMs], 0) + ISNULL(@p_duration_ms, 0),
            [status] = CASE 
                WHEN UPPER(ISNULL(@p_event_type, '')) IN ('ERROR', 'EXCEPCION') OR UPPER(ISNULL(@p_status, '')) = 'ERROR' THEN 'ERROR'
                WHEN UPPER(ISNULL(@p_status, '')) = 'SUCCESS' OR UPPER(ISNULL(@p_event_type, '')) IN ('FIN_PROCESO', 'API_RESPONSE', 'SP_FIN') THEN 'SUCCESS'
                ELSE [status]
            END,
            [errorMessage] = CASE WHEN UPPER(ISNULL(@p_event_type, '')) IN ('ERROR', 'EXCEPCION') THEN ISNULL(@p_functional_message, ISNULL(@p_tech_message, [errorMessage])) ELSE [errorMessage] END
        WHERE id = @v_session_id;
    END;

    INSERT INTO dbo.[TraceabilityLog] (
        [sessionId], [code], [userId], [origin], [eventType], [stepName], [spName], [endpoint],
        [durationMs], [status], [inputData], [outputData], [techMessage], [functionalMessage],
        [stackTrace], [affectedId]
    ) VALUES (
        @v_session_id, @p_code, @p_user_id, @v_origin, ISNULL(@p_event_type, 'INFO'), ISNULL(@p_step_name, 'PASO'),
        @p_sp_name, @p_endpoint, ISNULL(@p_duration_ms, 0), ISNULL(@p_status, 'SUCCESS'),
        @p_input_data, @p_output_data, @p_tech_message, @p_functional_message,
        @p_stack_trace, @p_affected_id
    );
END;
GO

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

-- ============================================================================
-- SECCIÓN 3: PROCEDIMIENTOS ALMACENADOS DE INTEGRACIÓN ERP (ZEUS / STANDALONE)
-- ============================================================================





-- Eliminar si existe
IF OBJECT_ID('dbo.spCotizacionesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionesCrear;
GO

CREATE PROCEDURE dbo.spCotizacionesCrear
(
    @xml VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('dbo.ImpRet', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ImpRet (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL,
            cd_cuenta VARCHAR(20) NULL,
            am_porcentaje NUMERIC(5,2) NULL DEFAULT 0,
            in_tipo CHAR(1) NULL DEFAULT 'I',
            Id_cargo_dep INT NULL,
            bl_IVA BIT NULL DEFAULT 0
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.ImpRet WHERE id = 1)
        BEGIN
            SET IDENTITY_INSERT dbo.ImpRet ON;
            INSERT INTO dbo.ImpRet (id, cd_codigo, ds_nombre, cd_cuenta, am_porcentaje, in_tipo, bl_IVA)
            VALUES (1, '01', 'IVA 19%', '240805', 19.00, 'I', 1);
            SET IDENTITY_INSERT dbo.ImpRet OFF;
        END
    END
    ELSE IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo')
    BEGIN
        ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
    END;

    IF OBJECT_ID('dbo.CargosDesc', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CargosDesc (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL
        );
    END;

    BEGIN TRY
        DECLARE @xmlData XML;

        DECLARE @Cotizacion TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			id_sucursal INT NOT NULL,
			id_implante INT NULL,
			cd_consecutivo char(8) NOT NULL,
			id_usuario INT NOT NULL,
			dt_fechacont smalldatetime NOT NULL,
			dt_fecha smalldatetime NOT NULL,
			id_usuarioAct INT NOT NULL,
			dt_fechaAct smalldatetime NOT NULL,
			cd_tercero_codigo varchar(25) NOT NULL,
			ds_tercero_nombre varchar(250) NOT NULL,
			cd_cliente_codigo varchar(25) NOT NULL,
			ds_cliente_nombre varchar(250) NOT NULL,
			ds_cliente_dir varchar(250) NOT NULL,
			ds_cliente_ciudad varchar(40) NOT NULL,
			ds_cliente_tel varchar(25) NULL,
			ds_cliente_dirdesp varchar(250) NULL,
			ds_cliente_email varchar(60) NULL,
			ds_cliente_contacto varchar(40) NULL,
			ds_cliente_contacto_email varchar(60) NULL,
			id_monedas_IATA INT NOT NULL,
			cd_vendedor char(3) NOT NULL,
			id_tiqueteador INT NOT NULL,
			bn_anexo varbinary(max) NULL,
			am_tcambio smallmoney NOT NULL,
			am_tcambiousd money NULL,
			cd_cencosto char(16) NULL,
			ds_observacion varchar(8000) NULL,
			ds_Campo_libre1 varchar(500) NULL,
			ds_Campo_libre2 varchar(500) NULL,
			id_tipoventa INT NULL,
			in_estado tinyINT NOT NULL,
			dt_vence smalldatetime NULL,
			Id_Etapa INT NULL,
			ds_seguimiento_etapa varchar(500) NULL,
			bl_ManejaOpciones bit NOT NULL,
			in_NumeroOpciones INT NULL,
			bl_CerrarCotizacion bit NOT NULL,
			in_OpcionSeleccionada INT NULL,
			bl_grupos bit NOT NULL,
			gk_sabre varchar(25) NULL,
			id_Especialista INT NULL,
			id_TipoFormaPagoProveedor INT NULL,
			id_MedioReservacion INT NULL,
			bl_bloqueada bit NOT NULL,
			id_usuario_Bloqueo INT NULL,
			ds_AlertaSolicitud varchar(8000) NULL,
			bl_comisiona bit NOT NULL,
			ds_FormaDePago varchar(250) NULL,
			ds_records varchar(25) NULL,
			bl_entregadoCliente bit NOT NULL,
			dt_entregadoCliente smalldatetime NULL,
			id_sys_entidades INT NULL,
			id_MonedaPagoDestino INT NULL,
			id_FormaPagoDestino INT NULL,
			ds_DocumentoPagoDestino varchar(50) NULL,
			dt_CheckInPagoDestino smalldatetime NULL,
			dt_CheckOutPagoDestino smalldatetime NULL,
			bl_fechaPagoDestino bit NOT NULL,
			ds_hotelTieneTiquete varchar(2) NULL,
			ds_GDS varchar(2) NULL,
			id_Evento INT NULL,
			id_Cotizacion INT NULL,
			bl_existe BIT NULL
		)

		DECLARE @CotizacionServicios TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			id_TiposConceptFac INT NOT NULL,
			id_ConceptoFacturacion INT NOT NULL,
			id_TiposServicio INT NULL,
			id_Cotizacion INT NULL,
			id_fac_factura INT NULL,
			id_fac_remision INT NULL,
			cd_proveedores varchar(25) NULL,
			ds_tiposervnm varchar(50) NULL,
			cd_prov_hotel char(10) NULL,
			cd_prov_car char(10) NULL,
			cd_prov_air char(10) NULL,
			ds_destino varchar(30) NULL,
			ds_servicio varchar(250) NULL,
			ds_descrip varchar(4000) NULL,
			ds_paxname varchar(20) NULL,
			ds_paxape varchar(20) NULL,
			cd_paxtype char(3) NULL,
			in_nacionalidad tinyINT NOT NULL,
			cd_voucher varchar(20) NULL,
			in_cantpax INT NOT NULL,
			dt_llegada smalldatetime NULL,
			dt_salida smalldatetime NULL,
			cd_cencosto varchar(16) NULL,
			cd_auxiliar varchar(16) NULL,
			cd_item varchar(16) NULL,
			am_valorprov money NULL,
			id_monedaprov INT NULL,
			ds_InfoAdicional varchar(8000) NULL,
			id_carrental INT NULL,
			id_hoteles INT NULL,
			bl_anulado bit NOT NULL,
			cd_tiquete char(11) NULL,
			cd_fuente_anul char(2) NULL,
			cd_serie_anul char(2) NULL,
			cd_consecutivo_anul char(8) NULL,
			id_usuario_anul INT NULL,
			id_sucursal_anul INT NULL,
			id_implante_anul INT NULL,
			am_basecomisionable money NULL,
			am_porcomision numeric(8, 4) NULL,
			cd_voucherPrefijo varchar(3) NULL,
			bl_notdomicilionacional bit NULL,
			Valor_Comision money NULL,
			Valor_Recaudo money NULL,
			dias_recaudo INT NULL,
			ds_paxClasificacion char(7) NULL,
			id_tipoplan INT NULL,
			id_acomodacion INT NULL,
			in_dias INT NULL,
			in_noches INT NULL,
			ds_records varchar(25) NULL,
			id_GrConcepto INT NULL,
			in_diasSrv INT NULL,
			in_nochesSrv INT NULL,
			Id_Especialista INT NULL,
			am_porcentaje_descuento numeric(8, 4) NULL,
			am_valor_descuento money NULL,
			ds_motivo_descuento varchar(1000) NULL,
			id_cargosdesc_descuento INT NULL,
			in_NumeroOpcion INT NULL,
			dt_FechaSalidaSrv smalldatetime NULL,
			dt_FechaLlegadaSrv smalldatetime NULL,
			cd_localizador varchar(25) NULL,
			cd_voucherpax varchar(25) NULL,
			am_basecomisionableprov money NULL,
			am_porcomisionprov numeric(8, 4) NULL,
			cd_NumeFac varchar(15) NULL,
			dt_VenceFac smalldatetime NULL,
			id_AcomodacionSrv INT NULL,
			id_TipoPlanSrv INT NULL,
			in_habitaciones INT NULL,
			in_habitacionesSrv INT NULL,
			cd_Consecutivo_VariablesAdicionales varchar(8) NULL,
			cd_confirmacion varchar(25) NULL,
			ds_confirmadopor varchar(250) NULL,
			cd_paxidentificacion varchar(25) NULL,
			bl_politicaCancelacion bit NOT NULL,
			dt_politicaCancelacion smalldatetime NULL,
			id_tipoHabitacion INT NULL,
			id_fac_facturaComision INT NULL,
			id_fac_remisionComision INT NULL,
			id_TarjetaAsistencia INT NULL,
			id_Regiones INT NULL,
			Iden_GDS INT NULL,
			id_sys_entidades INT NULL,
			ds_TipoAuto varchar(50) NULL,
			ds_Origen varchar(30) NULL,
			ds_DirOrigen varchar(250) NULL,
			ds_DirDestino varchar(250) NULL,
			ds_TipoTarifa varchar(50) NULL,
			am_ValorUSD money NULL,
			ds_NoVuelo varchar(25) NULL,
			ds_Vehiculo varchar(250) NULL,
			ds_Placa varchar(25) NULL,
			ds_CategoriaVehiculo varchar(250) NULL,
			ds_NombreConductor varchar(50) NULL,
			ds_telefono varchar(25) NULL,
			ds_IdiomaConductor varchar(25) NULL,
			id_MonedaSrv INT NULL,
			id_TipoServicio INT NULL,
			id_Aerolinea INT NULL,
			in_EdadPax INT NULL,
			am_PorFacParcial numeric(8, 4) NOT NULL,
			ds_GDS varchar(2) NULL,
			dt_fechaficheroBBVA smalldatetime NULL,
			bl_tiquete bit NOT NULL,
			am_basedescuento money NULL,
			am_pordescuento numeric(18, 4) NULL,
			id_CotizacionServicios_Depende INT NULL,
			id_CotizacionServicios INT NULL,
			cd_Cotizacion varchar(25) NULL
		 )

		 DECLARE @CotizacionServicios_PaxAdicional TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_Cotizacion int NULL,
			id_CotizacionServicios int NULL,
			ds_paxape varchar(30) NULL,
			ds_paxname varchar(30) NULL,
			ds_paxprefix char(3) NULL,
			ds_paxClasificacion char(7) NULL,
			cd_voucherpax varchar(25) NULL,
			cd_paxidentificacion varchar(25) NULL,
			in_edad int NULL,
			cd_tiquete char(50) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		)

		DECLARE @CotizacionCargos TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_CotizacionServicios int NULL,
			id_cargosdesc int NOT NULL,
			ds_cargonm varchar(50) NOT NULL,
			bl_noshow bit NOT NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			am_valor  AS (am_contado+am_credito),
			am_contado_ME money NOT NULL,
			am_credito_ME money NOT NULL,
			am_valor_ME  AS (am_contado_ME+am_credito_ME),
			id_CotizacionCargos INT NULL,
			cd_CotizacionCargos varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		 )

		 DECLARE @CotizacionImpuestos TABLE(
			id int IDENTITY(1,1) NOT NULL,
			id_CotizacionCargos int NULL,
			id_ImpRet int NOT NULL,
			ds_Impas varchar(50) NOT NULL,
			cd_impcta varchar(16) NULL,
			am_porcentaje smallmoney NOT NULL,
			bl_contabilizar bit NOT NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			am_valor  AS (am_contado+am_credito),
			am_contado_ME money NOT NULL,
			am_credito_ME money NOT NULL,
			am_valor_ME  AS (am_contado_ME+am_credito_ME),
			cd_CotizacionImpuestos varchar(25) NULL,
			cd_CotizacionCargos varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		)

		DECLARE @VariableDatosMaestro TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			IDEN_Maestro numeric(18, 0) NOT NULL,
			IDEN_Variable numeric(18, 0) NOT NULL,
			CodigoMaestro varchar(50) NOT NULL,
			ValorNumerico numeric(18, 6) NULL,
			ValorFecha smalldatetime NULL,
			ValorVarchar varchar(500) NULL,
			cd_VariableDatosMaestro varchar(25) NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL
		 )

		 DECLARE @Fac_Servicios_TiposFacturacionHoteles TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL,
			cd_TiposFacturacionHoteles varchar(25) NULL,
			cd_cargosdesc varchar(25) NULL,
			id_Fac_Servicios int NULL,
			id_CotizacionServicios int NULL,
			Id_TiposFacturacionHoteles int NOT NULL,
			in_cantidad int NULL,
			am_valor money NULL,
			am_contado money NOT NULL,
			am_credito money NOT NULL,
			Id_Cotizacion_Solicitud int NULL,
			id_cargosdesc int NULL,
			ds_cargonm varchar(50) NULL
		 )
		
		DECLARE @CotizacionServicios_TipoProv TABLE(
			id int IDENTITY(1,1) NOT NULL,
			cd_Cotizacion varchar(25) NULL,
			cd_CotizacionServicios varchar(25) NULL,
			id_CotizacionServicios int NULL,
			id_TipoProveedores int NULL,
			cd_TipoProveedores varchar(25) NULL,
			ds_TipoProveedores varchar(60) NULL,
			cd_proveedores varchar(25) NULL,
			ds_proveedores varchar(250) NULL
		)

		DECLARE @CotizacionServiciosFormasPago TABLE(
			id INT IDENTITY(1,1) NOT NULL,
			cd_Cotizacion VARCHAR(25) NULL,
			cd_CotizacionServicios VARCHAR(25) NULL,
			id_CotizacionServicios INT NULL,
			Id_Cotizacion INT NULL,
			id_FormasPago INT NULL,
			cd_codigo VARCHAR(3) NULL,
			ds_FPnm VARCHAR(50) NULL,
			bl_FPrepresenta BIT NOT NULL DEFAULT 0,
			id_TarjetasCredito INT NULL,
			cd_tccode NCHAR(10) NULL,
			ds_tcnumber CHAR(16) NULL,
			ds_tcvoucher VARCHAR(25) NULL,
			cd_idbanco CHAR(3) NULL,
			ds_cheque VARCHAR(30) NULL,
			ds_referencia VARCHAR(50) NULL,
			am_valor MONEY NOT NULL DEFAULT 0,
			ds_tcexp VARCHAR(7) NULL,
			ds_plaza CHAR(3) NULL,
			ds_Poliza VARCHAR(20) NULL,
			ds_PolAnexo VARCHAR(20) NULL,
			am_valor_ME MONEY NOT NULL DEFAULT 0,
			ds_tcautorizacion VARCHAR(25) NULL,
			in_tccuotas INT NULL
		)

        -- Validar que el XML sea correcto
        IF @xml IS NULL OR LTRIM(RTRIM(@xml)) = ''
        BEGIN
            --THROW 50001, 'El XML es obligatorio.', 1;
            SELECT 'El XML es obligatorio.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Limpiar saltos de línea y tabuladores para evitar que se guarden en campos de texto (usuario, tercero, dirección, etc.)
        SET @xml = REPLACE(REPLACE(REPLACE(@xml, CHAR(13), ''), CHAR(10), ''), CHAR(9), '');

        SET @xmlData = TRY_CAST(@xml AS XML);

        IF @xmlData IS NULL
        BEGIN
            --THROW 50002, 'El XML no tiene un formato válido.', 1;
            SELECT 'El XML no tiene un formato válido.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Extraer los principales códigos maestros del XML para validarlos
        DECLARE @val_cd_cliente_codigo VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_cliente_codigo)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_sucursal VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_sucursal)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_vendedor VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_vendedor)[1]', 'VARCHAR(25)');
        DECLARE @val_cd_tiqueteador VARCHAR(25) = @xmlData.value('(Cotizaciones/Cotizacion/cd_tiqueteador)[1]', 'VARCHAR(25)');

        -- 1. Validar Cliente
        IF @val_cd_cliente_codigo IS NOT NULL AND @val_cd_cliente_codigo <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Client] WHERE document = @val_cd_cliente_codigo OR CAST(id AS VARCHAR(25)) = @val_cd_cliente_codigo
            )
            BEGIN
                SELECT 'cliente ' + @val_cd_cliente_codigo + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 2. Validar Sucursal
        IF @val_cd_sucursal IS NOT NULL AND @val_cd_sucursal <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Branch] WHERE code = @val_cd_sucursal OR CAST(id AS VARCHAR(25)) = @val_cd_sucursal
            )
            BEGIN
                SELECT 'sucursal ' + @val_cd_sucursal + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 3. Validar Vendedor
        IF @val_cd_vendedor IS NOT NULL AND @val_cd_vendedor <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[Seller] WHERE code = @val_cd_vendedor OR CAST(id AS VARCHAR(25)) = @val_cd_vendedor
            )
            BEGIN
                SELECT 'vendedor ' + @val_cd_vendedor + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 4. Validar Tiqueteador
        IF @val_cd_tiqueteador IS NOT NULL AND @val_cd_tiqueteador <> ''
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM dbo.[TicketPrinter] WHERE code = @val_cd_tiqueteador OR CAST(id AS VARCHAR(25)) = @val_cd_tiqueteador
            )
            BEGIN
                SELECT 'tiqueteador ' + @val_cd_tiqueteador + ' no existe' AS 'Respuesta', 1 AS 'Estado';
                RETURN 1;
            END
        END

        -- 5. Validar Proveedores de Servicios
        DECLARE @invalid_proveedor VARCHAR(25) = NULL;
        
        SELECT TOP 1 @invalid_proveedor = S.node.value('cd_proveedores[1]', 'VARCHAR(25)')
        FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios') AS S(node)
        WHERE S.node.value('cd_proveedores[1]', 'VARCHAR(25)') IS NOT NULL 
          AND S.node.value('cd_proveedores[1]', 'VARCHAR(25)') <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.[Provider] WHERE code = S.node.value('cd_proveedores[1]', 'VARCHAR(25)') OR CAST(id AS VARCHAR(25)) = S.node.value('cd_proveedores[1]', 'VARCHAR(25)')
          );

        IF @invalid_proveedor IS NOT NULL
        BEGIN
            SELECT 'proveedor ' + @invalid_proveedor + ' no existe' AS 'Respuesta', 1 AS 'Estado';
            RETURN 1;
        END

        -- 6. Si la base de datos es Standalone KoreX (sin tabla dbo.Cotizacion de Zeus ERP), responder OK
        IF OBJECT_ID('dbo.Cotizacion', 'U') IS NULL
        BEGIN
            SELECT 'Cotización exportada exitosamente (Entorno Standalone KoreX)' AS 'Respuesta', 0 AS 'Estado';
            RETURN 0;
        END

        -- Extraer datos del XML
        BEGIN TRANSACTION;

		INSERT INTO @Cotizacion(
			id_sucursal,
			id_implante,
			cd_consecutivo,
			id_usuario,
			dt_fechacont,
			dt_fecha,
			id_usuarioAct,
			dt_fechaAct,
			cd_tercero_codigo,
			ds_tercero_nombre,
			cd_cliente_codigo,
			ds_cliente_nombre,
			ds_cliente_dir,
			ds_cliente_ciudad,
			ds_cliente_tel,
			ds_cliente_dirdesp,
			ds_cliente_email,
			ds_cliente_contacto,
			ds_cliente_contacto_email,
			id_monedas_IATA,
			cd_vendedor,
			id_tiqueteador,
			bn_anexo,
			am_tcambio,
			am_tcambiousd,
			cd_cencosto,
			ds_observacion,
			ds_Campo_libre1,
			ds_Campo_libre2,
			id_tipoventa,
			in_estado,
			dt_vence,
			Id_Etapa,
			ds_seguimiento_etapa,
			bl_ManejaOpciones,
			in_NumeroOpciones,
			bl_CerrarCotizacion,
			in_OpcionSeleccionada,
			bl_grupos,
			gk_sabre,
			id_Especialista,
			id_TipoFormaPagoProveedor,
			id_MedioReservacion,
			bl_bloqueada,
			id_usuario_Bloqueo,
			ds_AlertaSolicitud,
			bl_comisiona,
			ds_FormaDePago,
			ds_records,
			bl_entregadoCliente,
			dt_entregadoCliente,
			id_sys_entidades,
			id_MonedaPagoDestino,
			id_FormaPagoDestino,
			ds_DocumentoPagoDestino,
			dt_CheckInPagoDestino,
			dt_CheckOutPagoDestino,
			bl_fechaPagoDestino,
			ds_hotelTieneTiquete,
			ds_GDS,
			id_Evento,
			id_Cotizacion,
			bl_existe
		)	
        SELECT 
			id_sucursal = ISNULL(S.id,1),
			id_implante = I.id,
			cd_consecutivo = C.Cotizacion.value('cd_consecutivo[1]','VARCHAR(25)'),
			id_usuario = ISNULL(U.id,1),
			dt_fechacont = ISNULL(C.Cotizacion.value('dt_fechacont[1]','SMALLDATETIME'),'19000101'),
			dt_fecha = ISNULL(C.Cotizacion.value('dt_fecha[1]','SMALLDATETIME'),'19000101'),
			id_usuarioAct = ISNULL(U.id,1),
			dt_fechaAct = ISNULL(C.Cotizacion.value('dt_fechaAct[1]','SMALLDATETIME'),'19000101'),
			cd_tercero_codigo = ISNULL(CL.document, ISNULL(C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),'')),
			ds_tercero_nombre = ISNULL(CL.name, ISNULL(C.Cotizacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),'')),
			cd_cliente_codigo = ISNULL(C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),''),
			ds_cliente_nombre = ISNULL(C.Cotizacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),''),
			ds_cliente_dir = ISNULL(C.Cotizacion.value('ds_cliente_dir[1]','VARCHAR(250)'),''),
			ds_cliente_ciudad = ISNULL(C.Cotizacion.value('ds_cliente_ciudad[1]','VARCHAR(40)'),''),
			ds_cliente_tel = ISNULL(C.Cotizacion.value('ds_cliente_tel[1]','VARCHAR(25)'),''),
			ds_cliente_dirdesp = ISNULL(C.Cotizacion.value('ds_cliente_dirdesp[1]','VARCHAR(250)'),''),
			ds_cliente_email = ISNULL(C.Cotizacion.value('ds_cliente_email[1]','VARCHAR(60)'),''),
			ds_cliente_contacto = ISNULL(C.Cotizacion.value('ds_cliente_contacto[1]','VARCHAR(40)'),''),
			ds_cliente_contacto_email = ISNULL(C.Cotizacion.value('ds_cliente_contacto_email[1]','VARCHAR(60)'),''),
			id_monedas_IATA = ISNULL(M.id,1),
			cd_vendedor = ISNULL(C.Cotizacion.value('cd_vendedor[1]','VARCHAR(3)'),''),
			id_tiqueteador = ISNULL(Tq.id, ISNULL((SELECT TOP 1 id FROM dbo.[TicketPrinter]), 1)),
			bn_anexo = NULL,
			am_tcambio = ISNULL(C.Cotizacion.value('am_tcambio[1]','SMALLMONEY'),1),
			am_tcambiousd = ISNULL(C.Cotizacion.value('am_tcambiousd[1]','MONEY'),1),
			cd_cencosto = ISNULL(C.Cotizacion.value('cd_cencosto[1]','VARCHAR(16)'),''),
			ds_observacion = ISNULL(C.Cotizacion.value('ds_observacion[1]','VARCHAR(8000)'),''),
			ds_Campo_libre1 = ISNULL(C.Cotizacion.value('ds_Campo_libre1[1]','VARCHAR(500)'),''),
			ds_Campo_libre2 = ISNULL(C.Cotizacion.value('ds_Campo_libre2[1]','VARCHAR(500)'),''),
			id_tipoventa = Tv.id,
			in_estado = ISNULL(C.Cotizacion.value('in_estado[1]','INT'),1),
			dt_vence = C.Cotizacion.value('dt_vence[1]','SMALLDATETIME'),
			Id_Etapa = NULL,
			ds_seguimiento_etapa = '',
			bl_ManejaOpciones = 0,
			in_NumeroOpciones = NULL,
			bl_CerrarCotizacion = 0,
			in_OpcionSeleccionada = NULL,
			bl_grupos = 0,
			gk_sabre = '',
			id_Especialista = NULL,
			id_TipoFormaPagoProveedor = NULL,
			id_MedioReservacion = NULL,
			bl_bloqueada = 0,
			id_usuario_Bloqueo = NULL,
			ds_AlertaSolicitud = '',
			bl_comisiona = 0,
			ds_FormaDePago = ISNULL(C.Cotizacion.value('ds_FormaDePago[1]','VARCHAR(250)'),''),
			ds_records = '',
			bl_entregadoCliente = 0,
			dt_entregadoCliente = NULL,
			id_sys_entidades = 65,
			id_MonedaPagoDestino = NULL,
			id_FormaPagoDestino = NULL,
			ds_DocumentoPagoDestino = NULL,
			dt_CheckInPagoDestino = NULL,
			dt_CheckOutPagoDestino = NULL,
			bl_fechaPagoDestino = 0,
			ds_hotelTieneTiquete = NULL,
			ds_GDS = C.Cotizacion.value('ds_GDS[1]','VARCHAR(2)'),
			id_Evento = NULL,
			id_Cotizacion = NULL,
			bl_existe = CASE WHEN CC.id IS NOT NULL THEN 1 ELSE 0 END 
        FROM @xmlData.nodes('Cotizaciones/Cotizacion') AS C(Cotizacion)
		LEFT JOIN dbo.[Branch] S ON (S.code = C.Cotizacion.value('cd_sucursal[1]','VARCHAR(25)') OR CAST(S.id AS VARCHAR(25)) = C.Cotizacion.value('cd_sucursal[1]','VARCHAR(25)'))
		LEFT JOIN dbo.[Implant] I ON (I.code = C.Cotizacion.value('cd_implante[1]','VARCHAR(25)') OR CAST(I.id AS VARCHAR(25)) = C.Cotizacion.value('cd_implante[1]','VARCHAR(25)'))
		LEFT JOIN dbo.[User] U ON (U.email = C.Cotizacion.value('cd_usuario[1]','VARCHAR(250)') OR U.name = C.Cotizacion.value('cd_usuario[1]','VARCHAR(250)'))
		LEFT JOIN dbo.[Client] CL ON (CL.document = C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)') OR CAST(CL.id AS VARCHAR(25)) = C.Cotizacion.value('cd_cliente_codigo[1]','VARCHAR(25)'))
		LEFT JOIN dbo.Monedas_IATA M ON M.cd_codigo=C.Cotizacion.value('cd_monedas_IATA[1]','VARCHAR(3)')
		LEFT JOIN dbo.[TicketPrinter] Tq ON (Tq.code = C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(6)') OR CAST(Tq.id AS VARCHAR(25)) = C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(6)'))
		LEFT JOIN dbo.TipoVenta Tv ON Tv.cd_codigo=C.Cotizacion.value('cd_tipoventa[1]','VARCHAR(16)')
		LEFT JOIN dbo.Cotizacion CC ON CC.cd_consecutivo = C.Cotizacion.value('cd_consecutivo[1]','VARCHAR(25)')		 
		
		INSERT INTO @CotizacionServicios(
			id_TiposConceptFac ,
			id_ConceptoFacturacion ,
			id_TiposServicio ,
			id_Cotizacion ,
			id_fac_factura ,
			id_fac_remision,
			cd_proveedores ,
			ds_tiposervnm ,
			cd_prov_hotel,
			cd_prov_car,
			cd_prov_air,
			ds_destino ,
			ds_servicio ,
			ds_descrip,
			ds_paxname,
			ds_paxape,
			cd_paxtype,
			in_nacionalidad ,
			cd_voucher ,
			in_cantpax ,
			dt_llegada ,
			dt_salida ,
			cd_cencosto ,
			cd_auxiliar ,
			cd_item ,
			am_valorprov ,
			id_monedaprov ,
			ds_InfoAdicional ,
			id_carrental ,
			id_hoteles ,
			bl_anulado ,
			cd_tiquete ,
			cd_fuente_anul ,
			cd_serie_anul ,
			cd_consecutivo_anul ,
			id_usuario_anul,
			id_sucursal_anul,
			id_implante_anul,
			am_basecomisionable,
			am_porcomision ,
			cd_voucherPrefijo,
			bl_notdomicilionacional,
			Valor_Comision,
			Valor_Recaudo,
			dias_recaudo,
			ds_paxClasificacion,
			id_tipoplan,
			id_acomodacion ,
			in_dias,
			in_noches ,
			ds_records ,
			id_GrConcepto,
			in_diasSrv,
			in_nochesSrv ,
			Id_Especialista ,
			am_porcentaje_descuento ,
			am_valor_descuento ,
			ds_motivo_descuento ,
			id_cargosdesc_descuento,
			in_NumeroOpcion ,
			dt_FechaSalidaSrv ,
			dt_FechaLlegadaSrv ,
			cd_localizador ,
			cd_voucherpax ,
			am_basecomisionableprov ,
			am_porcomisionprov ,
			cd_NumeFac ,
			dt_VenceFac ,
			id_AcomodacionSrv ,
			id_TipoPlanSrv ,
			in_habitaciones ,
			in_habitacionesSrv ,
			cd_Consecutivo_VariablesAdicionales ,
			cd_confirmacion,
			ds_confirmadopor,
			cd_paxidentificacion,
			bl_politicaCancelacion,
			dt_politicaCancelacion,
			id_tipoHabitacion,
			id_fac_facturaComision,
			id_fac_remisionComision,
			id_TarjetaAsistencia,
			id_Regiones,
			Iden_GDS,
			id_sys_entidades,
			ds_TipoAuto,
			ds_Origen,
			ds_DirOrigen ,
			ds_DirDestino,
			ds_TipoTarifa,
			am_ValorUSD,
			ds_NoVuelo ,
			ds_Vehiculo,
			ds_Placa ,
			ds_CategoriaVehiculo ,
			ds_NombreConductor ,
			ds_telefono ,
			ds_IdiomaConductor ,
			id_MonedaSrv ,
			id_TipoServicio ,
			id_Aerolinea ,
			in_EdadPax,
			am_PorFacParcial,
			ds_GDS,
			dt_fechaficheroBBVA,
			bl_tiquete,
			am_basedescuento,
			am_pordescuento,
			id_CotizacionServicios_Depende,
			id_CotizacionServicios,
			cd_Cotizacion
		 )
		 SELECT
			id_TiposConceptFac = ISNULL(CF.id_TiposConceptoFacturacion,2),
			id_ConceptoFacturacion = ISNULL(CF.id,3),
			id_TiposServicio=ISNULL(TS.id,9) ,
			id_Cotizacion=NULL ,
			id_fac_factura=NULL ,
			id_fac_remision=NULL,
			cd_proveedores=ISNULL(C.CotizacionServicios.value('cd_proveedores[1]','VARCHAR(25)'),'') ,
			ds_tiposervnm=ISNULL(C.CotizacionServicios.value('ds_tiposervnm[1]','VARCHAR(25)'),'') ,
			cd_prov_hotel=ISNULL(C.CotizacionServicios.value('cd_prov_hotel[1]','VARCHAR(25)'),'') ,
			cd_prov_car=ISNULL(C.CotizacionServicios.value('cd_prov_car[1]','VARCHAR(25)'),'') ,
			cd_prov_air=ISNULL(C.CotizacionServicios.value('cd_prov_air[1]','VARCHAR(25)'),'') ,
			ds_destino=ISNULL(C.CotizacionServicios.value('ds_destino[1]','VARCHAR(25)'),'') ,
			ds_servicio=ISNULL(C.CotizacionServicios.value('ds_servicio[1]','VARCHAR(25)'),'') ,
			ds_descrip=ISNULL(C.CotizacionServicios.value('ds_descrip[1]','VARCHAR(25)'),'') ,
			ds_paxname=ISNULL(C.CotizacionServicios.value('ds_paxname[1]','VARCHAR(25)'),'') ,
			ds_paxape=ISNULL(C.CotizacionServicios.value('ds_paxape[1]','VARCHAR(25)'),'') ,
			cd_paxtype=SUBSTRING(ISNULL(C.CotizacionServicios.value('cd_paxtype[1]','VARCHAR(25)'),''), 1, 3) ,
			in_nacionalidad=ISNULL(C.CotizacionServicios.value('in_nacionalidad[1]','INT'),1) ,
			cd_voucher=ISNULL(C.CotizacionServicios.value('cd_voucher[1]','VARCHAR(25)'),'') ,
			in_cantpax=ISNULL(C.CotizacionServicios.value('in_cantpax[1]','INT'),1) ,
			dt_llegada=ISNULL(C.CotizacionServicios.value('dt_llegada[1]','SMALLDATETIME'),'19000101'),
			dt_salida=ISNULL(C.CotizacionServicios.value('dt_salida[1]','SMALLDATETIME'),'19000101'),
			cd_cencosto=ISNULL(C.CotizacionServicios.value('cd_cencosto[1]','VARCHAR(25)'),'')  ,
			cd_auxiliar=ISNULL(C.CotizacionServicios.value('cd_auxiliar[1]','VARCHAR(25)'),'')  ,
			cd_item =ISNULL(C.CotizacionServicios.value('cd_item[1]','VARCHAR(25)'),'') ,
			am_valorprov = 0,
			id_monedaprov = NULL,
			ds_InfoAdicional ='',
			id_carrental = NULL,
			id_hoteles = H.id,
			bl_anulado = 0,
			cd_tiquete ='',
			cd_fuente_anul ='',
			cd_serie_anul ='',
			cd_consecutivo_anul ='',
			id_usuario_anul=NULL,
			id_sucursal_anul=NULL,
			id_implante_anul=NULL,
			am_basecomisionable=ISNULL(C.CotizacionServicios.value('am_basecomisionable[1]','MONEY'),0) ,
			am_porcomision=ISNULL(C.CotizacionServicios.value('am_porcomision[1]','MONEY'),0) ,
			cd_voucherPrefijo='',
			bl_notdomicilionacional=0,
			Valor_Comision=ISNULL(C.CotizacionServicios.value('valor_comision[1]','MONEY'),0) ,
			Valor_Recaudo=0,
			dias_recaudo=0,
			ds_paxClasificacion=SUBSTRING(ISNULL(C.CotizacionServicios.value('ds_paxclasificacion[1]','VARCHAR(25)'),''), 1, 7) ,
			id_tipoplan=NULL,
			id_acomodacion=NULL ,
			in_dias=ISNULL(C.CotizacionServicios.value('in_dias[1]','INT'),1),
			in_noches=ISNULL(C.CotizacionServicios.value('in_noches[1]','INT'),1) ,
			ds_records =ISNULL(C.CotizacionServicios.value('ds_records[1]','VARCHAR(25)'),'') ,
			id_GrConcepto=NULL,
			in_diasSrv=0,
			in_nochesSrv=0 ,
			Id_Especialista=NULL ,
			am_porcentaje_descuento=0 ,
			am_valor_descuento=0 ,
			ds_motivo_descuento='' ,
			id_cargosdesc_descuento=NULL,
			in_NumeroOpcion=0 ,
			dt_FechaSalidaSrv=GETDATE() ,
			dt_FechaLlegadaSrv=GETDATE() ,
			cd_localizador='' ,
			cd_voucherpax='' ,
			am_basecomisionableprov=0 ,
			am_porcomisionprov=0 ,
			cd_NumeFac='' ,
			dt_VenceFac=GETDATE() ,
			id_AcomodacionSrv=NULL ,
			id_TipoPlanSrv=NULL ,
			in_habitaciones=0 ,
			in_habitacionesSrv=0 ,
			cd_Consecutivo_VariablesAdicionales=ISNULL(C.CotizacionServicios.value('cd_consecutivo_variablesadicionales[1]','VARCHAR(25)'),'') ,
			cd_confirmacion='',
			ds_confirmadopor='',
			cd_paxidentificacion='',
			bl_politicaCancelacion=0,
			dt_politicaCancelacion=NULL,
			id_tipoHabitacion=NULL,
			id_fac_facturaComision=NULL,
			id_fac_remisionComision=NULL,
			id_TarjetaAsistencia=NULL,
			id_Regiones=NULL,
			Iden_GDS=6,
			id_sys_entidades=35,
			ds_TipoAuto='',
			ds_Origen='',
			ds_DirOrigen='' ,
			ds_DirDestino='',
			ds_TipoTarifa='',
			am_ValorUSD=1,
			ds_NoVuelo='' ,
			ds_Vehiculo='',
			ds_Placa='' ,
			ds_CategoriaVehiculo='' ,
			ds_NombreConductor='' ,
			ds_telefono='' ,
			ds_IdiomaConductor='' ,
			id_MonedaSrv=NULL,
			id_TipoServicio=NULL ,
			id_Aerolinea=NULL ,
			in_EdadPax=0,
			am_PorFacParcial=0,
			ds_GDS='',
			dt_fechaficheroBBVA=GETDATE(),
			bl_tiquete=0,
			am_basedescuento=0,
			am_pordescuento=0,
			id_CotizacionServicios_Depende=NULL,
			id_CotizacionServicios=NULL,
			cd_Cotizacion = ISNULL(C.CotizacionServicios.value('cd_cotizacion[1]','VARCHAR(25)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios') AS C(CotizacionServicios)
		 LEFT JOIN dbo.ConceptoFacturacion CF ON CF.cd_codigo=C.CotizacionServicios.value('cd_conceptofacturacion[1]','VARCHAR(25)')
		 LEFT JOIN dbo.TiposServicios TS ON TS.cd_codigo=C.CotizacionServicios.value('cd_tiposservicio[1]','VARCHAR(25)')
		 LEFT JOIN dbo.Hoteles H ON H.cd_codigo=C.CotizacionServicios.value('cd_hoteles[1]','VARCHAR(25)')
        
		INSERT INTO @CotizacionServicios_PaxAdicional(
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete,
			cd_Cotizacion,
			cd_CotizacionServicios
		)
		SELECT
			id_Cotizacion=NULL,
			id_CotizacionServicios=NULL,
			ds_paxape=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxape[1]','VARCHAR(30)'),''),
			ds_paxname=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxname[1]','VARCHAR(30)'),''),
			ds_paxprefix=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxprefix[1]','VARCHAR(3)'),''),
			ds_paxClasificacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('ds_paxClasificacion[1]','VARCHAR(7)'),''),
			cd_voucherpax=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_voucherpax[1]','VARCHAR(25)'),''),
			cd_paxidentificacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_tiquete[1]','VARCHAR(25)'),''),
			in_edad=ISNULL(C.CotizacionServicios_PaxAdicional.value('in_edad[1]','INT'),''),
			cd_tiquete=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_tiquete[1]','VARCHAR(11)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionServicios_PaxAdicional.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'') 
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_PaxAdicional') AS C(CotizacionServicios_PaxAdicional)	
		
		INSERT INTO @CotizacionCargos(
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado ,
			am_credito ,
			am_contado_ME ,
			am_credito_ME ,
			id_CotizacionCargos,
			cd_CotizacionCargos,
			cd_Cotizacion,
			cd_CotizacionServicios
		 )
		 SELECT 
			id_CotizacionServicios=NULL,
			id_cargosdesc=CD.id,
			ds_cargonm=ISNULL(C.CotizacionCargos.value('ds_cargonm[1]','VARCHAR(50)'),''),
			bl_noshow=ISNULL(C.CotizacionCargos.value('bl_noshow[1]','INT'),''),
			am_contado=ISNULL(C.CotizacionCargos.value('am_contado[1]','MONEY'),''),
			am_credito=ISNULL(C.CotizacionCargos.value('am_credito[1]','MONEY'),''),
			am_contado_ME=ISNULL(C.CotizacionCargos.value('am_contado_ME[1]','MONEY'),''),
			am_credito_ME=ISNULL(C.CotizacionCargos.value('am_credito_ME[1]','MONEY'),''),
			id_CotizacionCargos=NULL,
			cd_CotizacionCargos = ISNULL(C.CotizacionCargos.value('cd_cotizacioncargos[1]','VARCHAR(25)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionCargos.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionCargos.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionCargos') AS C(CotizacionCargos)
		 LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=ISNULL(C.CotizacionCargos.value('cd_cargosdesc[1]','VARCHAR(3)'),'') 

		INSERT INTO @CotizacionImpuestos(
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME,
			cd_CotizacionImpuestos,
			cd_CotizacionCargos,
			cd_Cotizacion,
			cd_CotizacionServicios
		)
		SELECT
			id_CotizacionCargos=NULL,
			id_ImpRet=IR.id,
			ds_Impas= ISNULL(C.CotizacionImpuestos.value('ds_impas[1]','VARCHAR(16)'),''),
			cd_impcta= ISNULL(C.CotizacionImpuestos.value('cd_impcta[1]','VARCHAR(16)'),''),
			am_porcentaje=ISNULL(C.CotizacionImpuestos.value('am_porcentaje[1]','MONEY'),0),
			bl_contabilizar=ISNULL(C.CotizacionImpuestos.value('bl_contabilizar[1]','INT'),0),
			am_contado=ISNULL(C.CotizacionImpuestos.value('am_contado[1]','MONEY'),0),
			am_credito=ISNULL(C.CotizacionImpuestos.value('am_credito[1]','MONEY'),0),
			am_contado_ME=ISNULL(C.CotizacionImpuestos.value('am_contado_ME[1]','MONEY'),0),
			am_credito_ME=ISNULL(C.CotizacionImpuestos.value('am_credito_ME[1]','MONEY'),0),
			cd_CotizacionImpuestos = ISNULL(C.CotizacionImpuestos.value('cd_cotizacionimpuestos[1]','VARCHAR(25)'),''),
			cd_CotizacionCargos = ISNULL(C.CotizacionImpuestos.value('cd_cotizacioncargos[1]','VARCHAR(25)'),''),
			cd_Cotizacion=ISNULL(C.CotizacionImpuestos.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionImpuestos.value('cd_cotizacionservicios[1]','VARCHAR(25)'),'')
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionImpuestos') AS C(CotizacionImpuestos)
		LEFT JOIN dbo.ImpRet IR ON IR.cd_codigo=ISNULL(C.CotizacionImpuestos.value('cd_impret[1]','VARCHAR(3)'),'') 

		INSERT INTO @VariableDatosMaestro(
			IDEN_Maestro ,
			IDEN_Variable ,
			CodigoMaestro ,
			ValorNumerico ,
			ValorFecha ,
			ValorVarchar 
		 )
		 SELECT
			IDEN_Maestro=M.IDEN ,
			IDEN_Variable=V.IDEN ,
			CodigoMaestro=ISNULL(C.CotizacionServicios_VariableAdicional.value('cd_cotizacionservicios[1]','VARCHAR(50)'),'') ,
			ValorNumerico=NULL ,
			ValorFecha=NULL ,
			ValorVarchar=ISNULL(C.CotizacionServicios_VariableAdicional.value('ds_valor[1]','VARCHAR(500)'),'') 
		 FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_VariableAdicional') AS C(CotizacionServicios_VariableAdicional)
		 LEFT JOIN dbo.VariableDefinicion V ON V.Nombre = ISNULL(C.CotizacionServicios_VariableAdicional.value('cd_codigo[1]','VARCHAR(25)'),'')
		 LEFT JOIN dbo.VariableDefinicionMaestro M ON M.Codigo = ISNULL(C.CotizacionServicios_VariableAdicional.value('ds_maestro[1]','VARCHAR(30)'),'')
		 
		 INSERT INTO @Fac_Servicios_TiposFacturacionHoteles (
			cd_Cotizacion,
			cd_CotizacionServicios,
			cd_TiposFacturacionHoteles,
			cd_cargosdesc,
			id_Fac_Servicios,
			id_CotizacionServicios,
			Id_TiposFacturacionHoteles,
			in_cantidad,
			am_valor,
			am_contado,
			am_credito,
			Id_Cotizacion_Solicitud,
			id_cargosdesc,
			ds_cargonm
		)
		SELECT cd_Cotizacion=ISNULL(C.TiposFacturacionHoteles.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			   cd_CotizacionServicios=ISNULL(C.TiposFacturacionHoteles.value('cd_cotizacionservicios[1]','VARCHAR(25)'),''),
			   cd_TiposFacturacionHoteles=ISNULL(C.TiposFacturacionHoteles.value('cd_tiposfacturacionhoteles[1]','VARCHAR(25)'),''),
			   cd_cargosdesc=ISNULL(C.TiposFacturacionHoteles.value('cd_cargosdesc[1]','VARCHAR(25)'),'TAR'),
			   id_Fac_Servicios=NULL,
			   id_CotizacionServicios=NULL,
			   Id_TiposFacturacionHoteles=ISNULL(TF.id,5),
			   in_cantidad=ISNULL(C.TiposFacturacionHoteles.value('in_cantidad[1]','INT'),1),
			   am_valor=ISNULL(C.TiposFacturacionHoteles.value('am_valor[1]','MONEY'),0),
			   am_contado=ISNULL(C.TiposFacturacionHoteles.value('am_contado[1]','MONEY'),0),
			   am_credito=ISNULL(C.TiposFacturacionHoteles.value('am_credito[1]','MONEY'),0),
			   Id_Cotizacion_Solicitud=NULL,
			   id_cargosdesc=ISNULL(CD.id,1),
			   ds_cargonm=ISNULL(CD.ds_nombre,'Tarifa')
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/Fac_Servicios_TiposFacturacionHoteles') AS C(TiposFacturacionHoteles)
		LEFT JOIN dbo.TiposFacturacionHoteles TF ON TF.cd_codigo=ISNULL(C.TiposFacturacionHoteles.value('cd_tiposfacturacionhotel[1]','VARCHAR(3)'),'') 
		LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=ISNULL(C.TiposFacturacionHoteles.value('cd_cargosdesc[1]','VARCHAR(3)'),'') 

		INSERT INTO @CotizacionServicios_TipoProv(
			cd_Cotizacion,
			cd_CotizacionServicios,
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		)
		SELECT
			cd_Cotizacion=ISNULL(C.CotizacionServicios_TipoProv.value('cd_cotizacion[1]','VARCHAR(25)'),''),
			cd_CotizacionServicios=ISNULL(C.CotizacionServicios_TipoProv.value('cd_cotizacionservicios[1]','VARCHAR(25)'),''),
			id_CotizacionServicios=NULL,
			id_TipoProveedores=ISNULL(TP.id,1),
			cd_TipoProveedores=ISNULL(TP.cd_codigo,'Hotel'),
			ds_TipoProveedores=ISNULL(TP.ds_descrip,'Proveedor Tipo Hotel'),
			cd_proveedores=ISNULL(H.cd_codigo,''),
			ds_proveedores=ISNULL(H.ds_nombre,'')	
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServicios_TipoProv') AS C(CotizacionServicios_TipoProv)
		LEFT JOIN dbo.TipoProveedores TP ON TP.cd_codigo=ISNULL(C.CotizacionServicios_TipoProv.value('cd_tipoproveedores[1]','VARCHAR(3)'),'')
		LEFT JOIN dbo.Hoteles H ON H.cd_codigo=ISNULL(C.CotizacionServicios_TipoProv.value('cd_proveedores[1]','VARCHAR(25)'),'')
		
		-- Insert (cd_consecutivo automático)
        INSERT INTO dbo.Cotizacion(
				id_sucursal,
				id_implante,
				cd_consecutivo,
				id_usuario,
				dt_fechacont,
				id_usuarioAct,  
				dt_fechaAct,
				dt_vence, 
				cd_tercero_codigo,
				ds_tercero_nombre,
				cd_cliente_codigo,
				ds_cliente_nombre,
				ds_cliente_dir,
				ds_cliente_ciudad,
				ds_cliente_tel,
				ds_cliente_dirdesp,
				ds_cliente_email,
				ds_cliente_contacto,
				ds_cliente_contacto_email,
				id_monedas_IATA,
				am_tcambio,
				cd_vendedor,
				id_tiqueteador,
				am_tcambiousd,
				id_tipoventa,
				ds_observacion,
				ds_Campo_libre1,
				ds_Campo_libre2,
				in_estado,
				bl_ManejaOpciones,
				in_NumeroOpciones,
				bl_CerrarCotizacion,
				in_OpcionSeleccionada,
				bl_grupos,
				id_Especialista,
				id_TipoFormaPagoProveedor,
				id_MedioReservacion,
				bl_comisiona,
				ds_alertasolicitud	,
				ds_FormaDePago ,
				bl_entregadoCliente,
				dt_entregadoCliente,
				id_sys_entidades, 
				id_MonedaPagoDestino,	
				id_FormaPagoDestino	,
				ds_DocumentoPagoDestino,
				BL_fechaPagoDestino,
				dt_CheckInPagoDestino,	
				dt_CheckOutPagoDestino,
				ds_hotelTieneTiquete, 
				ds_GDS, 
				id_evento
		)
		SELECT id_sucursal,
				id_implante,
				cd_consecutivo,
				id_usuario,
				dt_fechacont,
				id_usuarioAct,  
				dt_fechaAct,
				dt_vence, 
				cd_tercero_codigo,
				ds_tercero_nombre,
				cd_cliente_codigo,
				ds_cliente_nombre,
				ds_cliente_dir,
				ds_cliente_ciudad,
				ds_cliente_tel,
				ds_cliente_dirdesp,
				ds_cliente_email,
				ds_cliente_contacto,
				ds_cliente_contacto_email,
				id_monedas_IATA,
				am_tcambio,
				cd_vendedor,
				id_tiqueteador,
				am_tcambiousd,
				id_tipoventa,
				ds_observacion,
				ds_Campo_libre1,
				ds_Campo_libre2,
				in_estado,
				bl_ManejaOpciones,
				in_NumeroOpciones,
				bl_CerrarCotizacion,
				in_OpcionSeleccionada,
				bl_grupos,
				id_Especialista,
				id_TipoFormaPagoProveedor,
				id_MedioReservacion,
				bl_comisiona,
				ds_alertasolicitud	,
				ds_FormaDePago ,
				bl_entregadoCliente,
				dt_entregadoCliente,
				id_sys_entidades, 
				id_MonedaPagoDestino,	
				id_FormaPagoDestino	,
				ds_DocumentoPagoDestino,
				BL_fechaPagoDestino,
				dt_CheckInPagoDestino,	
				dt_CheckOutPagoDestino,
				ds_hotelTieneTiquete, 
				ds_GDS, 	
				id_evento
		FROM @Cotizacion
		WHERE bl_existe=0

		UPDATE CC
		SET CC.id_cotizacion=C.id
		FROM @Cotizacion CC
		INNER JOIN dbo.Cotizacion C ON C.cd_consecutivo=CC.cd_consecutivo

		UPDATE CS
		SET CS.id_cotizacion=C.id
		FROM @CotizacionServicios CS
		INNER JOIN dbo.Cotizacion C ON C.cd_consecutivo=CS.cd_Cotizacion
		
		INSERT INTO CotizacionServicios(
			id_TiposConceptFac,
			id_ConceptoFacturacion,
			id_TiposServicio,
			id_Cotizacion,
			id_fac_factura,
			id_fac_remision,
			cd_proveedores,
			ds_tiposervnm ,
			cd_prov_hotel,
			cd_prov_car,
			cd_prov_air,
			ds_destino ,
			ds_servicio,
			ds_descrip ,
			ds_paxname,
			ds_paxape,
			cd_paxtype ,
			in_nacionalidad,
			cd_voucher,
			in_cantpax ,
			dt_llegada ,
			dt_salida ,
			cd_cencosto ,
			cd_auxiliar,
			cd_item ,
			am_valorprov,
			id_monedaprov,
			ds_InfoAdicional,
			id_carrental,
			id_hoteles,
			bl_anulado ,
			cd_tiquete ,
			cd_fuente_anul ,
			cd_serie_anul ,
			cd_consecutivo_anul,
			id_usuario_anul,
			id_sucursal_anul,
			id_implante_anul,
			am_basecomisionable,
			am_porcomision,
			cd_voucherPrefijo,
			bl_notdomicilionacional,
			Valor_Comision,
			Valor_Recaudo,
			dias_recaudo,
			ds_paxClasificacion,
			id_tipoplan,
			id_acomodacion,
			in_dias,
			in_noches,
			ds_records,
			id_GrConcepto,
			in_diasSrv,
			in_nochesSrv,
			Id_Especialista,
			am_porcentaje_descuento,
			am_valor_descuento,
			ds_motivo_descuento,
			id_cargosdesc_descuento,
			in_NumeroOpcion,
			dt_FechaSalidaSrv,
			dt_FechaLlegadaSrv,
			cd_localizador,
			cd_voucherpax,
			am_basecomisionableprov,
			am_porcomisionprov,
			cd_NumeFac,
			dt_VenceFac,
			id_AcomodacionSrv,
			id_TipoPlanSrv,
			in_habitaciones,
			in_habitacionesSrv,
			cd_Consecutivo_VariablesAdicionales,
			cd_confirmacion ,
			ds_confirmadopor ,
			cd_paxidentificacion ,
			bl_politicaCancelacion ,
			dt_politicaCancelacion ,
			id_tipoHabitacion ,
			id_fac_facturaComision,
			id_fac_remisionComision,
			id_TarjetaAsistencia ,
			id_Regiones,
			Iden_GDS,
			id_sys_entidades,
			ds_TipoAuto,
			ds_Origen,
			ds_DirOrigen,
			ds_DirDestino,
			ds_TipoTarifa,
			am_ValorUSD,
			ds_NoVuelo,
			ds_Vehiculo,
			ds_Placa,
			ds_CategoriaVehiculo,
			ds_NombreConductor,
			ds_telefono,
			ds_IdiomaConductor,
			id_MonedaSrv,
			id_TipoServicio,
			id_Aerolinea,
			in_EdadPax,
			am_PorFacParcial,
			ds_GDS,
			dt_fechaficheroBBVA,
			bl_tiquete ,
			am_basedescuento,
			am_pordescuento,
			id_CotizacionServicios_Depende
		)
		SELECT
			cs.id_TiposConceptFac,
			cs.id_ConceptoFacturacion,
			cs.id_TiposServicio,
			cs.id_Cotizacion,
			cs.id_fac_factura,
			cs.id_fac_remision,
			cs.cd_proveedores,
			cs.ds_tiposervnm ,
			cs.cd_prov_hotel,
			cs.cd_prov_car,
			cs.cd_prov_air,
			cs.ds_destino ,
			cs.ds_servicio,
			cs.ds_descrip ,
			cs.ds_paxname,
			cs.ds_paxape,
			cs.cd_paxtype ,
			cs.in_nacionalidad,
			cs.cd_voucher,
			cs.in_cantpax ,
			cs.dt_llegada ,
			cs.dt_salida ,
			cs.cd_cencosto ,
			cs.cd_auxiliar,
			cs.cd_item ,
			cs.am_valorprov,
			cs.id_monedaprov,
			cs.ds_InfoAdicional,
			cs.id_carrental,
			cs.id_hoteles,
			cs.bl_anulado ,
			cs.cd_tiquete ,
			cs.cd_fuente_anul ,
			cs.cd_serie_anul ,
			cs.cd_consecutivo_anul,
			cs.id_usuario_anul,
			cs.id_sucursal_anul,
			cs.id_implante_anul,
			cs.am_basecomisionable,
			cs.am_porcomision,
			cs.cd_voucherPrefijo,
			cs.bl_notdomicilionacional,
			cs.Valor_Comision,
			cs.Valor_Recaudo,
			cs.dias_recaudo,
			cs.ds_paxClasificacion,
			cs.id_tipoplan,
			cs.id_acomodacion,
			cs.in_dias,
			cs.in_noches,
			cs.ds_records,
			cs.id_GrConcepto,
			cs.in_diasSrv,
			cs.in_nochesSrv,
			cs.Id_Especialista,
			cs.am_porcentaje_descuento,
			cs.am_valor_descuento,
			cs.ds_motivo_descuento,
			cs.id_cargosdesc_descuento,
			cs.in_NumeroOpcion,
			cs.dt_FechaSalidaSrv,
			cs.dt_FechaLlegadaSrv,
			cs.cd_localizador,
			cs.cd_voucherpax,
			cs.am_basecomisionableprov,
			cs.am_porcomisionprov,
			cs.cd_NumeFac,
			cs.dt_VenceFac,
			cs.id_AcomodacionSrv,
			cs.id_TipoPlanSrv,
			cs.in_habitaciones,
			cs.in_habitacionesSrv,
			cs.cd_Consecutivo_VariablesAdicionales,
			cs.cd_confirmacion ,
			cs.ds_confirmadopor ,
			cs.cd_paxidentificacion ,
			cs.bl_politicaCancelacion ,
			cs.dt_politicaCancelacion ,
			cs.id_tipoHabitacion ,
			cs.id_fac_facturaComision,
			cs.id_fac_remisionComision,
			cs.id_TarjetaAsistencia ,
			cs.id_Regiones,
			cs.Iden_GDS,
			cs.id_sys_entidades,
			cs.ds_TipoAuto,
			cs.ds_Origen,
			cs.ds_DirOrigen,
			cs.ds_DirDestino,
			cs.ds_TipoTarifa,
			cs.am_ValorUSD,
			cs.ds_NoVuelo,
			cs.ds_Vehiculo,
			cs.ds_Placa,
			cs.ds_CategoriaVehiculo,
			cs.ds_NombreConductor,
			cs.ds_telefono,
			cs.ds_IdiomaConductor,
			cs.id_MonedaSrv,
			cs.id_TipoServicio,
			cs.id_Aerolinea,
			cs.in_EdadPax,
			cs.am_PorFacParcial,
			cs.ds_GDS,
			cs.dt_fechaficheroBBVA,
			cs.bl_tiquete ,
			cs.am_basedescuento,
			cs.am_pordescuento,
			cs.id_CotizacionServicios_Depende	
		FROM @CotizacionServicios cs
		INNER JOIN @Cotizacion c ON c.cd_consecutivo=cs.cd_Cotizacion AND c.bl_existe=0

		UPDATE CCS
		SET CCS.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios CCS
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CCS.cd_Consecutivo_VariablesAdicionales

		UPDATE CSP
		SET CSP.id_Cotizacion=CS.id_Cotizacion,
			CSP.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios_PaxAdicional CSP 
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CSP.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CSP.cd_Cotizacion AND bl_existe=0

		INSERT INTO dbo.CotizacionServicios_PaxAdicional(
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete
		)
		SELECT
			id_Cotizacion,
			id_CotizacionServicios,
			ds_paxape,
			ds_paxname,
			ds_paxprefix,
			ds_paxClasificacion,
			cd_voucherpax,
			cd_paxidentificacion,
			in_edad,
			cd_tiquete
		FROM @CotizacionServicios_PaxAdicional
		WHERE id_CotizacionServicios IS NOT NULL 

		UPDATE CC
		SET CC.id_CotizacionServicios=CS.id
		FROM @CotizacionCargos CC
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales=CC.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CC.cd_Cotizacion AND bl_existe=0
		
		INSERT INTO dbo.CotizacionCargos(
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		 )
		 SELECT
			id_CotizacionServicios,
			id_cargosdesc,
			ds_cargonm,
			bl_noshow,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		 FROM @CotizacionCargos
		 WHERE id_CotizacionServicios IS NOT NULL 

		 --SELECT c.*
		 --FROM CotizacionCargos C
		 --INNER JOIN @CotizacionCargos CC ON CC.id_cargosdesc=C.id_cargosdesc AND CC.id_CotizacionServicios=C.id_CotizacionServicios

		 UPDATE CC
		 SET CC.id_CotizacionCargos=C.id
		 FROM @CotizacionCargos CC
		 INNER JOIN dbo.CotizacionCargos C ON C.id_cargosdesc=CC.id_cargosdesc AND C.id_CotizacionServicios=CC.id_CotizacionServicios
		 INNER JOIN @Cotizacion CT ON CT.cd_consecutivo = CC.cd_Cotizacion AND bl_existe=0
		 
		 --select  * from @CotizacionCargos
		 
		 UPDATE I
		 SET I.id_CotizacionCargos=C.id_CotizacionCargos
		 FROM @CotizacionImpuestos I
		 INNER JOIN @CotizacionCargos C ON C.cd_CotizacionCargos = I.cd_CotizacionCargos AND C.cd_CotizacionServicios=I.cd_CotizacionServicios
		 INNER JOIN @Cotizacion CT ON CT.cd_consecutivo = C.cd_Cotizacion AND bl_existe=0


		 INSERT INTO dbo.CotizacionImpuestos(
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		)
		SELECT 
			id_CotizacionCargos,
			id_ImpRet,
			ds_Impas,
			cd_impcta,
			am_porcentaje,
			bl_contabilizar,
			am_contado,
			am_credito,
			am_contado_ME,
			am_credito_ME
		FROM @CotizacionImpuestos
		WHERE id_CotizacionCargos IS NOT NULL 
		
		INSERT INTO dbo.VariableDatosMaestro(
			IDEN_Maestro,
			IDEN_Variable,
			CodigoMaestro,
			ValorNumerico,
			ValorFecha,
			ValorVarchar
		 )
		 SELECT 
			V.IDEN_Maestro,
			V.IDEN_Variable,
			V.CodigoMaestro,
			V.ValorNumerico,
			V.ValorFecha,
			V.ValorVarchar
		 FROM @VariableDatosMaestro V
		 INNER JOIN @CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = V.CodigoMaestro
		 INNER JOIN @Cotizacion C ON C.cd_consecutivo = CS.cd_Cotizacion AND bl_existe=0
		 GROUP BY V.IDEN_Maestro,
				  V.IDEN_Variable,
				  V.CodigoMaestro,
				  V.ValorNumerico,
				  V.ValorFecha,
				  V.ValorVarchar
		
		UPDATE TF
		SET TF.id_CotizacionServicios=CS.id_CotizacionServicios
		FROM @Fac_Servicios_TiposFacturacionHoteles TF
		INNER JOIN @CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = TF.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = CS.cd_Cotizacion AND C.bl_existe=0

		INSERT INTO dbo.Fac_Servicios_TiposFacturacionHoteles(
			id_Fac_Servicios,
			id_CotizacionServicios,
			Id_TiposFacturacionHoteles,
			in_cantidad,
			am_valor,
			am_contado,
			am_credito,
			Id_Cotizacion_Solicitud,
			id_cargosdesc,
			ds_cargonm
		)
		SELECT id_Fac_Servicios,
			   id_CotizacionServicios,
			   Id_TiposFacturacionHoteles,
			   in_cantidad,
			   am_valor,
			   am_contado,
			   am_credito,
			   Id_Cotizacion_Solicitud,
			   id_cargosdesc,
			   ds_cargonm
		FROM @Fac_Servicios_TiposFacturacionHoteles
		WHERE Id_TiposFacturacionHoteles IS NOT NULL


		UPDATE TP
		SET TP.id_CotizacionServicios=CS.id
		FROM @CotizacionServicios_TipoProv TP
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = TP.cd_CotizacionServicios

		
		INSERT INTO dbo.CotizacionServicios_TipoProv(
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		)
		SELECT 
			id_CotizacionServicios,
			id_TipoProveedores,
			cd_TipoProveedores,
			ds_TipoProveedores,
			cd_proveedores,
			ds_proveedores
		FROM @CotizacionServicios_TipoProv
		WHERE ISNULL(cd_proveedores,'') <> ''  

		-- Parsear formas de pago desde el XML
		INSERT INTO @CotizacionServiciosFormasPago(
			cd_Cotizacion,
			cd_CotizacionServicios,
			cd_codigo,
			ds_FPnm,
			bl_FPrepresenta,
			ds_tcnumber,
			ds_tcvoucher,
			ds_referencia,
			am_valor,
			ds_tcexp,
			am_valor_ME,
			ds_tcautorizacion
		)
		SELECT
			FP.FormasPago.value('cd_cotizacion[1]', 'VARCHAR(25)') AS cd_Cotizacion,
			FP.FormasPago.value('cd_cotizacionservicios[1]', 'VARCHAR(25)') AS cd_CotizacionServicios,
			ISNULL(FP.FormasPago.value('cd_codigo[1]', 'VARCHAR(3)'), '') AS cd_codigo,
			ISNULL(FP.FormasPago.value('ds_fpnm[1]', 'VARCHAR(50)'), '') AS ds_FPnm,
			ISNULL(FP.FormasPago.value('bl_fprepresenta[1]', 'BIT'), 0) AS bl_FPrepresenta,
			ISNULL(FP.FormasPago.value('ds_tcnumber[1]', 'CHAR(16)'), '') AS ds_tcnumber,
			ISNULL(FP.FormasPago.value('ds_tcvoucher[1]', 'VARCHAR(25)'), '') AS ds_tcvoucher,
			ISNULL(FP.FormasPago.value('ds_referencia[1]', 'VARCHAR(50)'), '') AS ds_referencia,
			ISNULL(FP.FormasPago.value('am_valor[1]', 'MONEY'), 0) AS am_valor,
			ISNULL(FP.FormasPago.value('ds_tcexp[1]', 'VARCHAR(7)'), '') AS ds_tcexp,
			ISNULL(FP.FormasPago.value('am_valor_me[1]', 'MONEY'), 0) AS am_valor_ME,
			ISNULL(FP.FormasPago.value('ds_tcautorizacion[1]', 'VARCHAR(25)'), '') AS ds_tcautorizacion
		FROM @xmlData.nodes('Cotizaciones/Cotizacion/CotizacionServicios/CotizacionServiciosFormasPago') AS FP(FormasPago);

		-- Resolver FKs de formas de pago
		-- ds_FPnm viene con el cd_codigo desde Postgres; se obtiene id y nombre real desde dbo.FormasPago
		UPDATE FP
		SET FP.id_CotizacionServicios = CS.id,
		    FP.Id_Cotizacion          = CS.Id_Cotizacion,
		    FP.id_FormasPago          = ISNULL(FPM.id, 1),
		    FP.ds_FPnm                = ISNULL(FPM.ds_nombre, FP.ds_FPnm)
		FROM @CotizacionServiciosFormasPago FP
		LEFT JOIN dbo.FormasPago FPM ON FPM.cd_codigo = FP.cd_codigo
		INNER JOIN dbo.CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = FP.cd_CotizacionServicios
		INNER JOIN @Cotizacion C ON C.cd_consecutivo = FP.cd_Cotizacion AND C.bl_existe=0

		-- Insertar en tabla real
		INSERT INTO dbo.CotizacionServiciosFormasPago(
			id_CotizacionServicios,
			Id_Cotizacion,
			id_FormasPago,
			ds_FPnm,
			bl_FPrepresenta,
			id_TarjetasCredito,
			cd_tccode,
			ds_tcnumber,
			ds_tcvoucher,
			cd_idbanco,
			ds_cheque,
			ds_referencia,
			am_valor,
			ds_tcexp,
			ds_plaza,
			ds_Poliza,
			ds_PolAnexo,
			am_valor_ME,
			ds_tcautorizacion,
			in_tccuotas
		)
		SELECT
			id_CotizacionServicios,
			Id_Cotizacion,
			id_FormasPago,
			ds_FPnm,
			bl_FPrepresenta,
			id_TarjetasCredito,
			cd_tccode,
			ds_tcnumber,
			ds_tcvoucher,
			cd_idbanco,
			ds_cheque,
			ds_referencia,
			am_valor,
			ds_tcexp,
			ds_plaza,
			ds_Poliza,
			ds_PolAnexo,
			am_valor_ME,
			ds_tcautorizacion,
			in_tccuotas
		FROM @CotizacionServiciosFormasPago
		WHERE id_CotizacionServicios IS NOT NULL

		--ROLLBACK TRANSACTION;
        COMMIT TRANSACTION;

		DECLARE @estado VARCHAR(8000)
		SET @estado=''
		SELECT @estado=@estado+ISNULL(cd_consecutivo,'0') + ':' + CASE WHEN id_Cotizacion IS NOT NULL THEN 'Enviado' ELSE 'Nuevo' END + '|'
		FROM @Cotizacion;
        -- Retorno mejorado: Lista resumida de lo procesado
        SELECT 
            cd_consecutivo AS Cotizacion,
            CASE 
                WHEN bl_existe = 1 THEN 'Ya existe en SQL Server'
                ELSE 'Creada exitosamente'
            END AS Estado,
            bl_existe,
            id_Cotizacion AS IdProcesado,
			@estado AS Estados
        FROM @Cotizacion;

		RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.spFacturacionesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spFacturacionesCrear;
GO

CREATE PROCEDURE dbo.spFacturacionesCrear
(
    @xml VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    IF OBJECT_ID('dbo.ImpRet', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.ImpRet (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL,
            cd_cuenta VARCHAR(20) NULL,
            am_porcentaje NUMERIC(5,2) NULL DEFAULT 0,
            in_tipo CHAR(1) NULL DEFAULT 'I',
            Id_cargo_dep INT NULL,
            bl_IVA BIT NULL DEFAULT 0
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.ImpRet WHERE id = 1)
        BEGIN
            SET IDENTITY_INSERT dbo.ImpRet ON;
            INSERT INTO dbo.ImpRet (id, cd_codigo, ds_nombre, cd_cuenta, am_porcentaje, in_tipo, bl_IVA)
            VALUES (1, '01', 'IVA 19%', '240805', 19.00, 'I', 1);
            SET IDENTITY_INSERT dbo.ImpRet OFF;
        END
    END
    ELSE IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo')
    BEGIN
        ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
    END;

    IF OBJECT_ID('dbo.CargosDesc', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.CargosDesc (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL
        );
    END;

    IF OBJECT_ID('dbo.parametros', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.parametros (
            id INT IDENTITY(1,1) PRIMARY KEY,
            nombre VARCHAR(250) NULL,
            valor VARCHAR(MAX) NULL
        );
        IF NOT EXISTS (SELECT 1 FROM dbo.parametros WHERE id = 33)
        BEGIN
            SET IDENTITY_INSERT dbo.parametros ON;
            INSERT INTO dbo.parametros (id, nombre, valor) VALUES (33, 'NumeroDecimales', '2');
            SET IDENTITY_INSERT dbo.parametros OFF;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.parametros WHERE id = 326)
        BEGIN
            SET IDENTITY_INSERT dbo.parametros ON;
            INSERT INTO dbo.parametros (id, nombre, valor) VALUES (326, 'CalcularAutoValoresItemFac', 'N');
            SET IDENTITY_INSERT dbo.parametros OFF;
        END;
    END;

    IF OBJECT_ID('dbo.Parametr', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Parametr (
            PARAMETRO VARCHAR(50) PRIMARY KEY,
            VALOPAR VARCHAR(250) NULL
        );
    END;

    BEGIN TRY
        -- BEGIN TRANSACTION; -- Comentado para permitir transacciones individuales por factura

        DECLARE @xmlData XML;

        Declare @Error Int
	
		DECLARE @cd_fuente VARCHAR(2)
		DECLARE @cd_serie VARCHAR(2)
		DECLARE @cd_consecutivo VARCHAR(8)
		DECLARE @id_facturacion INT
		DECLARE @id_item INT
		DECLARE @in_tipoitem INT
		Declare @Iden Int
		Declare @Categoria varchar(50)
		Declare @Operacion varchar(500)
		Declare @Llave1 varchar(50)
		Declare @Llave2 varchar(50)
		Declare @Llave3 varchar(50)
		Declare @Llave4 varchar(50)
		Declare @transaccion_guid uniqueidentifier
		Declare @Estado varchar(50)
		Declare @UltimoMensaje varchar(1000)
		Declare @Procesado datetime
		Declare @id_facture INT

		Declare @Fecha datetime
		Declare @FechaCont datetime
		Declare @Intentos Int
		Declare @Minute_wait INT

		Declare @MsjErrorValidar Varchar(MAX)
		Declare @Mensaje_Error Varchar(500);

		Declare @cur_cd_sucursal VARCHAR(MAX)
		Declare @cur_cd_implante VARCHAR(MAX)
		Declare @cur_id_sucursal INT
		Declare @cur_id_implante INT

		Declare @ReservaFactura VARCHAR(100)
		Declare @ds_cliid CHAR(10)
		Declare @cd_cliente CHAR(10)
		Declare @ds_cliname VARCHAR(250)
		Declare @ds_clidir VARCHAR(250)
		Declare @ds_clicity VARCHAR(50)
		Declare @ds_clitel VARCHAR(25)
		Declare @ds_ClienteEmail VARCHAR(100)
		Declare @ds_moneda CHAR(3)
		Declare @cd_vendedor CHAR(3)
		Declare @cd_tiqueteador VARCHAR(6)
		Declare @am_TasaCambio MONEY
		Declare @cd_tipoventa VARCHAR(10)
		Declare @cd_licitacion INT
		Declare @ds_descripcion VARCHAR(500)
		Declare @ds_Observaciones VARCHAR(8000)
		Declare @ds_archivo VARCHAR(250)
		Declare @id_reserva INT
		Declare @cd_reserva VARCHAR(10)
		Declare @cd_sucursal CHAR(5)
		Declare @cd_implante CHAR(5)
		Declare @id_sucursal INT
		Declare @id_implante INT
		Declare @cd_bu VARCHAR(25) 

		Declare @id_monedas_iata INT
		Declare @id_tiqueteador INT
		Declare @id_tipoventa INT
		Declare @am_tcambiousd MONEY
		Declare @ValorFactura MONEY

		Declare @ds_impas_iva VARCHAR(50)
		Declare @cd_impcta_iva VARCHAR(16)
		Declare @am_porcentaje_iva NUMERIC(5,2)

		-- Variables to fetch item fields inside the cursor of a specific invoice
		Declare @item_Tipo VARCHAR(5)
		Declare @item_id_reserva INT
		Declare @item_iden_gds INT
		Declare @item_ds_aero_code CHAR(3)
		Declare @item_ds_tkt_number CHAR(10)
		Declare @item_in_nacionalidad TINYINT
		Declare @item_am_tarifa MONEY
		Declare @item_am_iva MONEY
		Declare @item_am_tua MONEY
		Declare @item_am_comb MONEY
		Declare @item_am_vat MONEY
		Declare @item_am_Comision MONEY
		Declare @item_ds_pax_firstnm VARCHAR(30)
		Declare @item_ds_pax_lastnm VARCHAR(30)
		Declare @item_ds_pax_prefix CHAR(3)
		Declare @item_cd_tourcode VARCHAR(25)
		Declare @item_NumTktConj INT
		Declare @item_cd_TipoTiquete CHAR(3)
		Declare @item_id_air INT
		Declare @item_ds_itinerario VARCHAR(250)
		Declare @item_cd_Ahorro CHAR(3)
		Declare @item_am_highfare MONEY
		Declare @item_am_lowfare MONEY
		Declare @item_ds_solicita VARCHAR(200)
		Declare @item_ds_lapsoviaje VARCHAR(50)
		Declare @item_cd_tktrevisado VARCHAR(14)
		Declare @item_cd_PasaportePax VARCHAR(25)
		Declare @item_am_PorFacParcial MONEY
		Declare @item_in_cantpax INT
		Declare @item_Id_Precompra INT
		Declare @item_cd_FormaPagoTAO VARCHAR(3)
		Declare @item_TarjetaCreditoTAO VARCHAR(4)
		Declare @item_NumeroTarjetaTAO VARCHAR(25)
		Declare @item_am_fptao MONEY
		Declare @item_am_tao MONEY
		Declare @item_am_ivatao MONEY
		Declare @item_Id_Srv INT
		Declare @item_cd_conceptofacturacion INT
		Declare @item_cd_tiposervicio INT
		Declare @item_cd_proveedores VARCHAR(25)
		Declare @item_ds_proveedores VARCHAR(250)
		Declare @item_cd_confirmation VARCHAR(25)
		Declare @item_dt_checkin SMALLDATETIME
		Declare @item_dt_checkout SMALLDATETIME
		Declare @item_cd_city VARCHAR(25)
		Declare @item_in_noches INT
		Declare @item_Servicio VARCHAR(123)
		Declare @item_Descrip VARCHAR(78)
		Declare @item_am_TarifaContado MONEY
		Declare @item_am_IvaContado MONEY
		Declare @item_am_TarifaCredito MONEY
		Declare @item_am_IvaCredito MONEY
		Declare @item_cd_centrocosto VARCHAR(50)
		Declare @item_cd_auxiliar VARCHAR(50)
		DECLARE @item_cd_item VARCHAR(50)
		Declare @item_cd_fp_OtrosItems VARCHAR(3)
		Declare @item_id_tipoproveedor INT
		Declare @item_cd_tipoproveedor VARCHAR(10)
		Declare @item_ds_tipoproveedor VARCHAR(100)
		Declare @item_Fecha_Salida SMALLDATETIME
		Declare @item_Fecha_Llegada SMALLDATETIME
		Declare @item_PNR VARCHAR(62)
		Declare @item_ds_itinerarioaerolinea VARCHAR(128)
		Declare @item_ds_tkt_prefix CHAR(3)
		Declare @item_bl_ahorro BIT
		Declare @item_cd_VencimientoTarjetaTAO CHAR(6)
		Declare @item_cd_NumeroPolizaTAO VARCHAR(50)
		Declare @item_cd_AnexoPolizaTAO VARCHAR(50)
		Declare @item_ds_AutorizacionTarjetaTAO VARCHAR(25)
		Declare @item_in_cuotasTarjetaTAO INT
		Declare @item_id_FormasPago INT
		Declare @item_id_TarjetasCredito INT
		Declare @item_am_fp1 MONEY
		Declare @item_ds_cc_code VARCHAR(2)
		Declare @item_ds_cc_number VARCHAR(25)
		Declare @item_ds_cc_vence VARCHAR(5)
		Declare @item_ds_cc_autorizacion VARCHAR(25)
		Declare @item_ds_cc_voucher VARCHAR(25)
		Declare @item_in_cc_cuotas INT
		Declare @item_am_fp2 MONEY
		Declare @item_ds_cc_code2 VARCHAR(2)
		Declare @item_ds_cc_number2 VARCHAR(25)
		Declare @item_ds_cc_vence2 VARCHAR(5)
		Declare @item_ds_cc_autorizacion2 VARCHAR(25)
		Declare @item_ds_cc_voucher2 VARCHAR(25)
		Declare @item_in_cc_cuotas2 INT
		Declare @item_cd_pax_CC VARCHAR(20)
		Declare @item_cd_destino VARCHAR(3)
		Declare @item_ds_clases VARCHAR(61)
		Declare @item_ds_Observaciones VARCHAR(8000)
		Declare @item_ds_fecha SMALLDATETIME
		Declare @SqlStmt NVARCHAR(MAX)

		Declare @LogResults TABLE (
			invoiceId INT,
			success INT,
			message VARCHAR(MAX)
		);

		Declare @ItemIndex INT
		Declare @ContadoRatio FLOAT
		Declare @TarifaSqlStmt NVARCHAR(MAX)
		Declare @TktSqlStmt NVARCHAR(MAX)
		Declare @TktItinSqlStmt NVARCHAR(MAX)
		Declare @TaoCargSqlStmt NVARCHAR(MAX)
		Declare @TaoFpSqlStmt NVARCHAR(MAX)
		Declare @TaoSqlStmt NVARCHAR(MAX)
		Declare @SrvCargSqlStmt NVARCHAR(MAX)
		Declare @SrvProvSqlStmt NVARCHAR(MAX)
		Declare @SrvPaxSqlStmt NVARCHAR(MAX)
		Declare @SrvHtlSqlStmt NVARCHAR(MAX)
		Declare @SrvImpuestosSqlStmt NVARCHAR(MAX)
		Declare @SrvFpSqlStmt NVARCHAR(MAX)
		Declare @SrvSqlStmt NVARCHAR(MAX)

		Declare @id_formaspago_tao INT
		Declare @ds_fpnm_tao VARCHAR(50)
		Declare @id_tarjetascredito_tao INT

		Declare @ResultTable TABLE (
			Respuesta VARCHAR(1000), 
			Estado INT,
			id_ReciboCaja INT,
			id_FormaPago INT,
			ds_FormaPago VARCHAR(100),
			cd_fuente VARCHAR(10),
			cd_serie VARCHAR(10),
			cd_consecutivo VARCHAR(20),
			ds_Tipo VARCHAR(50),
			am_valor MONEY,
			Resolucionmsg VARCHAR(1000),
			NCF VARCHAR(50),
			FechaCaducidad DATETIME,
			ds_Alerta VARCHAR(1000),
			in_ConsecutivoUnicoDocumento INT,
			DocumentoCausacionCxP VARCHAR(100)
		)
		Declare @FacturaRespuesta VARCHAR(MAX)
		Declare @FacturaEstado INT

		-- Variables for #GenerarConceptosAuto cursor loop
		Declare @c_id_ConceptoFacturacion INT
		Declare @c_cd_ConceptoFacturacion VARCHAR(50)
		Declare @c_ds_ConceptoFacturacion VARCHAR(250)
		Declare @c_id_TiposConceptFac INT
		Declare @c_bl_contorlarCargImp BIT
		Declare @c_bl_CalculoAutoValoresFacturacion BIT
		Declare @c_id_TiposServicio INT
		Declare @c_cd_TiposServicio VARCHAR(50)
		Declare @c_ds_TiposServicio VARCHAR(250)
		Declare @c_cd_proveedores VARCHAR(25)
		Declare @c_ds_proveedores VARCHAR(250)
		Declare @c_cd_tiquete VARCHAR(50)
		Declare @c_ds_servicio VARCHAR(250)
		Declare @c_ds_descrip VARCHAR(500)
		Declare @c_ds_paxname VARCHAR(30)
		Declare @c_ds_paxape VARCHAR(30)
		Declare @c_cd_paxtype CHAR(3)
		Declare @c_ds_paxClasificacion CHAR(6)
		Declare @c_in_nacionalidad TINYINT
		Declare @c_dt_llegada SMALLDATETIME
		Declare @c_dt_salida SMALLDATETIME
		Declare @c_cd_cencosto VARCHAR(50)
		Declare @c_cd_auxiliar VARCHAR(50)
		Declare @c_cd_item VARCHAR(50)
		Declare @c_Valor MONEY
		Declare @c_am_Contado MONEY
		Declare @c_am_Credito MONEY
		Declare @c_ValorIva MONEY
		Declare @c_Total MONEY
		Declare @c_PorIva NUMERIC(5,2)
		Declare @c_am_ContadoIva MONEY
		Declare @c_am_CreditoIva MONEY
		Declare @c_codigoimpiva VARCHAR(3)
		Declare @c_nombreimpiva VARCHAR(50) 
		Declare @c_ColId VARCHAR(25)
		Declare @c_cd_Consecutivo_depende VARCHAR(50)
		Declare @c_CodigoReserva VARCHAR(50)
		Declare @c_am_ImpuestoComision MONEY
		Declare @c_Respuesta VARCHAR(1000)
		Declare @c_bl_RutaExentaIva BIT
		Declare @c_id_FormasPago INT
		Declare @c_id_TarjetasCredito INT
		Declare @c_am_basedescuento MONEY
		Declare @c_am_pordescuento NUMERIC(8,4)
		Declare @c_id_FormasPagoAirPlus INT
		Declare @c_cd_FormasPagoAirPlus VARCHAR(3)
		Declare @c_ds_FormasPagoAirPlus VARCHAR(100)
		Declare @c_id_TarjetasCreditoAirPlus INT
		Declare @c_cd_TarjetasCreditoAirPlus VARCHAR(4)
		Declare @c_ds_numerotarjetaAirPlus VARCHAR(25)
		Declare @c_cd_codigotc VARCHAR(2)
		Declare @c_ds_numerotc VARCHAR(25)
		Declare @c_ds_vencetc VARCHAR(5)
		Declare @c_ds_autorizaciontc VARCHAR(25)
		Declare @c_ds_vouchertc VARCHAR(25)
		Declare @c_in_cuotastc INT


		DECLARE @CalcularAutoValoresItemFac CHAR(1) = 'N';
		DECLARE @RecalcTotalValue MONEY;
		DECLARE @RecalcTotalPayment MONEY;
		DECLARE @NumDecimales INT

		CREATE TABLE #Facturacion (
			id INT IDENTITY(1,1) PRIMARY KEY,
			cd_fuente VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_serie VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_consecutivo VARCHAR(8) COLLATE DATABASE_DEFAULT,
			Tipo VARCHAR(25) COLLATE DATABASE_DEFAULT,
			Servicio VARCHAR(123) COLLATE DATABASE_DEFAULT,
			Descrip VARCHAR(78) COLLATE DATABASE_DEFAULT,
			id_factura INT,
			id_item INT,
			in_tipoitem INT,
			iden_gds INT,
			ds_fecha SMALLDATETIME,
			cd_tiqueteador VARCHAR(6) COLLATE DATABASE_DEFAULT,
			cd_vendedor CHAR(3) COLLATE DATABASE_DEFAULT,
			cd_cliente CHAR(10) COLLATE DATABASE_DEFAULT,
			am_highfare MONEY,
			am_lowfare MONEY,
			am_fare MONEY,
			ds_reasoncode CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cliname VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clidir VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clicity VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_cliid CHAR(10) COLLATE DATABASE_DEFAULT,
			ds_itinerario VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_clases VARCHAR(61) COLLATE DATABASE_DEFAULT,
			in_nacionalidad TINYINT,
			id_air INT,
			ds_pax_number TINYINT,
			ds_pax_firstnm VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_pax_lastnm VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_pax_prefix CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_tkt_number CHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tkt_prefix CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_aero_code CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_moneda CHAR(3) COLLATE DATABASE_DEFAULT,
			am_tarifa MONEY,
			am_iva MONEY,
			am_tua MONEY,
			am_comb MONEY,
			am_vat MONEY,
			ds_cc_code CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cc_number VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_tao MONEY,
			am_ivatao MONEY,
			am_cap MONEY,
			am_ivacap MONEY,
			ds_cc_code2 CHAR(2) COLLATE DATABASE_DEFAULT,
			ds_cc_number2 CHAR(16) COLLATE DATABASE_DEFAULT,
			am_fp1 MONEY,
			am_fp2 MONEY,
			cd_tktrevisado VARCHAR(14) COLLATE DATABASE_DEFAULT,
			am_TarifaContado MONEY,
			am_IvaContado MONEY,
			am_OtrosContado MONEY,
			am_TarifaCredito MONEY,
			am_IvaCredito MONEY,
			am_OtrosCredito MONEY,
			am_Comision MONEY,
			cd_clitipodoc VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_clitipotercero CHAR(1) COLLATE DATABASE_DEFAULT,
			ds_clirazoncial VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_cliname2 VARCHAR(60) COLLATE DATABASE_DEFAULT,
			ds_clilastname VARCHAR(60) COLLATE DATABASE_DEFAULT,
			ds_clilastname2 VARCHAR(60) COLLATE DATABASE_DEFAULT,
			cd_clipais VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_clitel VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_TipoTransaccion VARCHAR(1) COLLATE DATABASE_DEFAULT,
			Fecha_Salida SMALLDATETIME,
			Fecha_Llegada SMALLDATETIME,
			Id_Srv INT,
			cd_conceptofacturacion INT,
			cd_tiposervicio INT,
			cd_proveedores VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_car INT,
			dt_entrega SMALLDATETIME,
			in_cars INT,
			cd_carcode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_conf_car VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_citysalida VARCHAR(25) COLLATE DATABASE_DEFAULT,
			dt_retorno SMALLDATETIME,
			cd_cartype VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_currency VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_tarifacar MONEY,
			cd_bookingsource VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_ratecode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			id_htl INT,
			dt_checkin SMALLDATETIME,
			in_guests INT,
			cd_confirmation VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_city VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_htlchain VARCHAR(25) COLLATE DATABASE_DEFAULT,
			dt_checkout SMALLDATETIME,
			in_noches INT,
			ds_htlname VARCHAR(250) COLLATE DATABASE_DEFAULT,
			in_habs INT,
			cd_bed VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_ratecode_htl VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_htlcur VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_htltarifa MONEY,
			cd_agcur VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_agtarifa MONEY,
			ds_dir1 VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_tel VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_fax VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_centrocosto VARCHAR(50) COLLATE DATABASE_DEFAULT,
			NumTktConj INT,
			Respuesta VARCHAR(1) COLLATE DATABASE_DEFAULT,
			ds_solicita VARCHAR(200) COLLATE DATABASE_DEFAULT,
			cd_pax_CC VARCHAR(20) COLLATE DATABASE_DEFAULT,
			ds_lapsoviaje VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_archivo VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_Observaciones VARCHAR(8000) COLLATE DATABASE_DEFAULT,
			ds_ClienteEmail VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_sucursal CHAR(5) COLLATE DATABASE_DEFAULT,
			cd_implante CHAR(5) COLLATE DATABASE_DEFAULT,
			bl_ClienteActualizar BIT,
			bl_NotificacionMPD BIT,
			cd_FormaPagoTAO VARCHAR(3) COLLATE DATABASE_DEFAULT,
			cd_TarjetaCreditoTAO VARCHAR(4) COLLATE DATABASE_DEFAULT,
			cd_NumeroTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_VencimientoTarjetaTAO CHAR(6) COLLATE DATABASE_DEFAULT,
			cd_NumeroPolizaTAO VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_AnexoPolizaTAO VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_PorDesFormaPagoTA NUMERIC(8,4),
			cd_Penalidad CHAR(14) COLLATE DATABASE_DEFAULT,
			ds_cc_vence CHAR(5) COLLATE DATABASE_DEFAULT,
			ds_cc_vence2 CHAR(5) COLLATE DATABASE_DEFAULT,
			ds_cc_autorizacion VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_autorizacion2 VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_voucher VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_cc_voucher2 VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_AutorizacionTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_VoucherTarjetaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_fptao MONEY,
			in_cc_cuotas INT,
			in_cc_cuotas2 INT,
			in_cuotasTarjetaTAO INT,
			cd_TipoTarifaTAO VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_TipoTiquete CHAR(3) COLLATE DATABASE_DEFAULT,
			am_TasaCambio MONEY,
			cd_tiqueteador_facturador CHAR(3) COLLATE DATABASE_DEFAULT,
			bl_ahorro BIT,
			in_CantidadTarifaTAO INT,
			in_CantidadSegmentoTAO INT,
			cd_tourcode VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_contrato VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_PasaportePax VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_itinerarioaerolinea VARCHAR(128) COLLATE DATABASE_DEFAULT,
			ds_tkt_prefixIata CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_Evento VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_iata VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_aero_codeIata CHAR(3) COLLATE DATABASE_DEFAULT,
			ReservaFactura VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_Ahorro CHAR(3) COLLATE DATABASE_DEFAULT,
			cd_Categoria VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			am_PorFacParcial MONEY,
			am_PorFacParcial_Utilizar MONEY,
			in_cantpax INT,
			Id_Precompra INT,
			id_sucursal INT,
			bl_cotizacion BIT,
			cd_htl VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			id_formapago_cliente INT,
			cd_formapago_cliente VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_formapago_cliente VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_fp_OtrosItems VARCHAR(3) COLLATE DATABASE_DEFAULT,
			cd_auxiliar VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_tipoventa VARCHAR(10) COLLATE DATABASE_DEFAULT,
			am_iva2 MONEY,
			cd_licitacion INT,
			ds_descripcion VARCHAR(500) COLLATE DATABASE_DEFAULT,
			id_tipoproveedor INT,
			cd_tipoproveedor VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tipoproveedor VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_Consecutivo_variablesadicionales VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_item VARCHAR(50) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #CargosImpuestos (
			id INT, id_facturacion INT, id_item INT, in_tipoitem INT,
			in_orden INT, cd_codigo VARCHAR(20) COLLATE DATABASE_DEFAULT, ds_nombre VARCHAR(100) COLLATE DATABASE_DEFAULT, cd_tipo CHAR(1) COLLATE DATABASE_DEFAULT, 
			cd_codigopadre VARCHAR(20) COLLATE DATABASE_DEFAULT, cd_tipopadre VARCHAR(20) COLLATE DATABASE_DEFAULT, am_porcentaje NUMERIC(8,4),
			am_contado MONEY, am_credito MONEY, am_valor MONEY, id_carg INT, id_imp INT, bl_iva BIT
		);

		CREATE TABLE #FormasPagos (
			id INT, id_facturacion INT, id_item INT, in_tipoitem INT,
			in_orden INT, id_formaspago INT, cd_codigo VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_nombre VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_tarjetascredito INT, cd_tipotarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_numerotarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_vouchertarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_expiraciontarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_autorizaciontarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_coutas INT, cd_banco VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_cheque VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_plaza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_referencia VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_Poliza VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_PolizaAnexo VARCHAR(50) COLLATE DATABASE_DEFAULT, am_valor MONEY
		);

		CREATE TABLE #Pasajeros (
			id_facturacion INT, id_item INT, in_tipoitem INT,
			ds_paxape VARCHAR(50) COLLATE DATABASE_DEFAULT, ds_paxname VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_paxprefix VARCHAR(10) COLLATE DATABASE_DEFAULT, ds_paxClasificacion VARCHAR(10) COLLATE DATABASE_DEFAULT,
			cd_voucherpax VARCHAR(50) COLLATE DATABASE_DEFAULT, cd_paxidentificacion VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_edad INT, cd_tiquete VARCHAR(50) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #Itinerarios (
			id_facturacion INT, id_item INT, in_tipoitem INT, in_orden INT,
			ds_origen VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_destino VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_clase VARCHAR(25) COLLATE DATABASE_DEFAULT, dt_llegada SMALLDATETIME, dt_salida SMALLDATETIME,
			ds_terminal VARCHAR(25) COLLATE DATABASE_DEFAULT, cd_aerolinea VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_farebasis VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_numerovuelo VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_tipovuelo VARCHAR(25) COLLATE DATABASE_DEFAULT, am_valor MONEY, am_co2 MONEY
		);

		CREATE TABLE #VariablesAdicionales (
			id_facturacion INT, id_item INT, in_tipoitem INT,
			ds_maestro VARCHAR(25) COLLATE DATABASE_DEFAULT, ds_VariableAdicional VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_valor VARCHAR(500) COLLATE DATABASE_DEFAULT, cd_codigo VARCHAR(25) COLLATE DATABASE_DEFAULT
		);

		CREATE TABLE #GenerarConceptosAuto (
			id_ConceptoFacturacion INT,
			cd_ConceptoFacturacion VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_ConceptoFacturacion VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_TiposConceptFac INT,
			bl_contorlarCargImp BIT,
			bl_CalculoAutoValoresFacturacion BIT,
			id_TiposServicio INT,
			cd_TiposServicio VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_TiposServicio VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_proveedores VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			cd_tiquete VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_servicio VARCHAR(250) COLLATE DATABASE_DEFAULT,
			ds_descrip VARCHAR(500) COLLATE DATABASE_DEFAULT,
			ds_paxname VARCHAR(30) COLLATE DATABASE_DEFAULT,
			ds_paxape VARCHAR(30) COLLATE DATABASE_DEFAULT,
			cd_paxtype CHAR(3) COLLATE DATABASE_DEFAULT,
			ds_paxClasificacion CHAR(6) COLLATE DATABASE_DEFAULT,
			in_nacionalidad TINYINT,
			dt_llegada SMALLDATETIME,
			dt_salida SMALLDATETIME,
			cd_cencosto VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_auxiliar VARCHAR(50) COLLATE DATABASE_DEFAULT,
			cd_item VARCHAR(50) COLLATE DATABASE_DEFAULT,
			Valor MONEY,
			am_Contado MONEY,
			am_Credito MONEY,
			ColId VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_Consecutivo_depende VARCHAR(50) COLLATE DATABASE_DEFAULT,
			CodigoReserva VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_ImpuestoComision MONEY,
			Respuesta VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			bl_RutaExentaIva BIT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			am_basedescuento MONEY,
			am_pordescuento NUMERIC(8,4),
			id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_TarjetasCreditoAirPlus INT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			cd_codigotc VARCHAR(2) COLLATE DATABASE_DEFAULT,
			ds_numerotc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_vencetc VARCHAR(5) COLLATE DATABASE_DEFAULT,
			ds_autorizaciontc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			ds_vouchertc VARCHAR(25) COLLATE DATABASE_DEFAULT,
			in_cuotastc INT
		);

		CREATE TABLE #TmpFacturaItems (
			id INT IDENTITY(1,1) PRIMARY KEY,
			id_factura INT,
			id_item INT,
			in_tipoitem INT,
			tipo_item VARCHAR(10),                 -- 'Aire', 'TAO', 'SRV','Hotel','Auto'
			id_referencia_origen INT,              -- ID de ReservasGDS_Detalles or ReservaGDS_Servicios
			cd_fuente VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_serie VARCHAR(2) COLLATE DATABASE_DEFAULT,
			cd_consecutivo VARCHAR(8) COLLATE DATABASE_DEFAULT,
			cd_tiquete VARCHAR(50),
			ds_descrip VARCHAR(500),
			in_nacionalidad INT,
			cd_cencosto VARCHAR(50),
			cd_auxiliar VARCHAR(50),
			cd_item VARCHAR(50),
			am_tarifa MONEY,
			am_iva MONEY,
			am_tua MONEY,
			am_comb MONEY,
			am_vat MONEY,
			am_Comision MONEY,
			ds_paxname VARCHAR(30),
			ds_paxape VARCHAR(30),
			ds_paxprefix CHAR(3),
			cd_tourcode VARCHAR(25),
			NumTktConj INT,
			cd_TipoTiquete CHAR(3),
			id_air INT,
			ds_itinerario VARCHAR(250),
			ds_itinerarioaerolinea VARCHAR(128),
			ds_clases VARCHAR(61),
			ds_Observaciones VARCHAR(8000),
			am_highfare MONEY,
			am_lowfare MONEY,
			ds_solicita VARCHAR(200),
			ds_lapsoviaje VARCHAR(50),
			cd_tktrevisado VARCHAR(14),
			cd_PasaportePax VARCHAR(25),
			cd_pax_CC VARCHAR(20),
			am_PorFacParcial MONEY,
			in_cantpax INT,
			Id_Precompra INT,
			cd_FormaPagoTAO VARCHAR(3),
			cd_TarjetaCreditoTAO VARCHAR(4),
			cd_NumeroTarjetaTAO VARCHAR(25),
			cd_VencimientoTarjetaTAO CHAR(6),
			cd_NumeroPolizaTAO VARCHAR(50),
			cd_AnexoPolizaTAO VARCHAR(50),
			ds_AutorizacionTarjetaTAO VARCHAR(25),
			in_cuotasTarjetaTAO INT,
			id_FormasPago INT,
			id_TarjetasCredito INT,
			am_fp1 MONEY,
			ds_cc_code VARCHAR(2),
			ds_cc_number VARCHAR(25),
			ds_cc_vence VARCHAR(5),
			ds_cc_autorizacion VARCHAR(25),
			ds_cc_voucher VARCHAR(25),
			in_cc_cuotas INT,
			am_fp2 MONEY,
			ds_cc_code2 VARCHAR(2),
			ds_cc_number2 VARCHAR(25),
			ds_cc_vence2 VARCHAR(5),
			ds_cc_autorizacion2 VARCHAR(25),
			ds_cc_voucher2 VARCHAR(25),
			in_cc_cuotas2 INT,
			id_monedas_iata INT,
			Tcambio MONEY,
			id_sucursal INT,
			id_implante INT,
			bl_ahorro BIT,
			cd_TipoTiqueteGDS VARCHAR(3),
			id_TiposDocumento INT,
			id_entdist INT,
			id_entvend INT,
			cd_destino VARCHAR(3),
			dt_fechaexped SMALLDATETIME,
			id_tiqueteadores INT,
			id_gds INT,
			iden_gds INT,
			am_comisionPNR MONEY,
			ds_records VARCHAR(62),
			bl_NoCalcComision BIT,
			bl_NoCalcIvaComision BIT,
			am_basecomisionable MONEY,
			am_porcomision MONEY,
			id_tiposconceptfac INT,
			id_conceptofacturacion INT,
			id_tiposservicio INT,
			cd_proveedores VARCHAR(25),
			ds_servicio VARCHAR(250),
			am_valorprov MONEY,
			id_monedaprov INT,
			dt_llegada SMALLDATETIME,
			dt_salida SMALLDATETIME,
			am_pordescuento NUMERIC(8,4),
			am_basedescuento MONEY,
			Fecha_Salida SMALLDATETIME,
			Fecha_Llegada SMALLDATETIME,
			ColId VARCHAR(25),
			cd_Consecutivo_depende VARCHAR(50),
			CodigoReserva VARCHAR(50),
			cd_Consecutivo_variablesadicionales VARCHAR(50),
			am_valor_total MONEY,
			ds_proveedores VARCHAR(250) COLLATE DATABASE_DEFAULT,
			id_tipoproveedor INT,
			cd_tipoproveedor VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_tipoproveedor VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_FormasPagoAirPlus INT,
			cd_FormasPagoAirPlus VARCHAR(3) COLLATE DATABASE_DEFAULT,
			ds_FormasPagoAirPlus VARCHAR(100) COLLATE DATABASE_DEFAULT,
			id_TarjetasCreditoAirPlus INT,
			cd_TarjetasCreditoAirPlus VARCHAR(4) COLLATE DATABASE_DEFAULT,
			ds_numerotarjetaAirPlus VARCHAR(25) COLLATE DATABASE_DEFAULT,
			id_reserva INT,
			OrdenGrabacion INT
		);

		CREATE TABLE #TmpFacturaCargos (
			id_cargo_temp INT IDENTITY(1,1) PRIMARY KEY,
			id_item INT,
			cd_codigo VARCHAR(20) COLLATE DATABASE_DEFAULT,
			ds_nombre VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cd_tipo CHAR(1) COLLATE DATABASE_DEFAULT,
			am_porcentaje NUMERIC(8,4),
			am_valor MONEY,
			am_contado MONEY,
			am_credito MONEY,
			id_carg INT,
			id_imp INT,
			bl_iva BIT,
			in_orden INT
		);

		CREATE TABLE #TmpFacturaFormasPago (
			id_fp_temp INT IDENTITY(1,1) PRIMARY KEY,
			id_item INT,
			id_formaspago INT,
			cd_codigo VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_nombre VARCHAR(50) COLLATE DATABASE_DEFAULT,
			id_tarjetascredito INT,
			cd_tipotarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_numerotarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_vouchertarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_expiraciontarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT,
			ds_autorizaciontarjeta VARCHAR(50) COLLATE DATABASE_DEFAULT,
			in_cuotas INT,
			cd_banco VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_cheque VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_plaza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_referencia VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_Poliza VARCHAR(50) COLLATE DATABASE_DEFAULT,
			ds_PolizaAnexo VARCHAR(50) COLLATE DATABASE_DEFAULT,
			am_valor MONEY
		);


		IF OBJECT_ID('dbo.ImpRet', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 
				@ds_impas_iva = ds_nombre, 
				@cd_impcta_iva = cd_cuenta, 
				@am_porcentaje_iva = am_porcentaje,
				@c_PorIva = am_porcentaje,
				@c_codigoimpiva = cd_codigo,
				@c_nombreimpiva = ds_nombre
			FROM dbo.ImpRet 
			WHERE id = 1;
		END
		IF @am_porcentaje_iva IS NULL SET @am_porcentaje_iva = 19.00;
		IF @c_PorIva IS NULL SET @c_PorIva = 19.00;

		IF OBJECT_ID('dbo.parametros', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 @NumDecimales = TRY_CAST(LTRIM(RTRIM(valor)) AS INT) FROM dbo.parametros WHERE id = 33;
			SELECT TOP 1 @CalcularAutoValoresItemFac = ISNULL(LTRIM(RTRIM(valor)), 'N') FROM dbo.parametros WHERE id = 326;
		END
		IF @NumDecimales IS NULL SET @NumDecimales = 2;
		IF @CalcularAutoValoresItemFac IS NULL SET @CalcularAutoValoresItemFac = 'N';

        -- Validar que el XML sea correcto
        IF @xml IS NULL OR LTRIM(RTRIM(@xml)) = ''
        BEGIN
            --THROW 50001, 'El XML es obligatorio.', 1;
            SELECT 'El XML es obligatorio.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Limpiar saltos de línea y tabuladores para evitar que se guarden en campos de texto (usuario, tercero, dirección, etc.)
        SET @xml = REPLACE(REPLACE(REPLACE(@xml, CHAR(13), ''), CHAR(10), ''), CHAR(9), '');

        SET @xmlData = TRY_CAST(@xml AS XML);

        IF @xmlData IS NULL
        BEGIN
            --THROW 50002, 'El XML no tiene un formato válido.', 1;
            SELECT 'El XML no tiene un formato válido.' AS 'Respuesta', 1 AS 'Estado'
			RETURN 1;
        END

        -- Extraer datos del XML

		INSERT INTO #Facturacion(
			cd_fuente, 
			cd_serie,
			cd_consecutivo,
			Tipo,
			Servicio,
			Descrip,
			id_factura,
			id_item,
			in_tipoitem,
			iden_gds,
			ds_fecha,
			cd_tiqueteador,
			cd_vendedor,
			cd_cliente,
			am_highfare,
			am_lowfare,
			am_fare,
			ds_reasoncode,
			ds_cliname,
			ds_clidir,
			ds_clicity,
			ds_cliid,
			ds_itinerario,
			ds_clases,
			in_nacionalidad,
			id_air,
			ds_pax_number,
			ds_pax_firstnm,
			ds_pax_lastnm,
			ds_pax_prefix,
			ds_tkt_number,
			ds_tkt_prefix,
			ds_aero_code,
			ds_moneda,
			am_tarifa,
			am_iva,
			am_tua,
			am_comb,
			am_vat,
			ds_cc_code,
			ds_cc_number,
			am_tao,
			am_ivatao,
			am_cap,
			am_ivacap,
			ds_cc_code2,
			ds_cc_number2,
			am_fp1,
			am_fp2,
			cd_tktrevisado,
			am_TarifaContado,
			am_IvaContado,
			am_OtrosContado,
			am_TarifaCredito,
			am_IvaCredito,
			am_OtrosCredito,
			am_Comision,
			cd_clitipodoc,
			cd_clitipotercero,
			ds_clirazoncial,
			ds_cliname2,
			ds_clilastname,
			ds_clilastname2,
			cd_clipais,
			ds_clitel,
			cd_TipoTransaccion,
			Fecha_Salida,
			Fecha_Llegada,
			Id_Srv,
			cd_conceptofacturacion,
			cd_tiposervicio,
			cd_proveedores,
			ds_proveedores,
			id_car,
			dt_entrega,
			in_cars,
			cd_carcode,
			cd_conf_car,
			cd_citysalida,
			dt_retorno,
			cd_cartype,
			cd_currency,
			am_tarifacar,
			cd_bookingsource,
			cd_ratecode,
			id_htl,
			dt_checkin,
			in_guests,
			cd_confirmation,
			cd_city,
			cd_htlchain,
			dt_checkout,
			in_noches,
			ds_htlname,
			in_habs,
			cd_bed,
			cd_ratecode_htl,
			cd_htlcur,
			am_htltarifa,
			cd_agcur,
			am_agtarifa,
			ds_dir1,
			ds_tel,
			ds_fax,
			cd_centrocosto,
			NumTktConj,
			Respuesta,
			ds_solicita,
			cd_pax_CC,
			ds_lapsoviaje,
			ds_archivo,
			ds_Observaciones,
			ds_ClienteEmail,
			cd_sucursal,
			cd_implante, 
			bl_ClienteActualizar,
			bl_NotificacionMPD,
			cd_FormaPagoTAO,
			cd_TarjetaCreditoTAO, 
			cd_NumeroTarjetaTAO, 
			cd_VencimientoTarjetaTAO, 
			cd_NumeroPolizaTAO,
			cd_AnexoPolizaTAO,
			am_PorDesFormaPagoTA, 
			cd_Penalidad, 
			ds_cc_vence, 
			ds_cc_vence2,
			ds_cc_autorizacion ,
			ds_cc_autorizacion2 ,
			ds_cc_voucher,
			ds_cc_voucher2 ,
			ds_AutorizacionTarjetaTAO,
			ds_VoucherTarjetaTAO,
			am_fptao,
			in_cc_cuotas,
			in_cc_cuotas2,
			in_cuotasTarjetaTAO,
			cd_TipoTarifaTAO,
			cd_TipoTiquete,
			am_TasaCambio,
			cd_tiqueteador_facturador ,
			bl_ahorro	,
			in_CantidadTarifaTAO,
			in_CantidadSegmentoTAO,
			cd_tourcode ,
			ds_contrato,
			cd_PasaportePax,
			ds_itinerarioaerolinea,
			ds_tkt_prefixIata,
			ds_Evento,
			cd_iata ,
			ds_aero_codeIata,
			ReservaFactura ,
			cd_Ahorro,
			cd_Categoria ,
			Id_FormasPagoAirPlus,
			cd_FormasPagoAirPlus,
			ds_FormasPagoAirPlus,
			cd_TarjetasCreditoAirPlus,
			ds_numerotarjetaAirPlus,
			am_PorFacParcial,
			am_PorFacParcial_Utilizar,
			in_cantpax,
			Id_Precompra,
			id_sucursal,
			bl_cotizacion,
			cd_htl,
			id_FormasPago,
			id_TarjetasCredito,
			id_formapago_cliente,
			cd_formapago_cliente,
			ds_formapago_cliente,
			cd_fp_OtrosItems,
			cd_auxiliar,
			cd_tipoventa,
			am_iva2,
			cd_licitacion,
			ds_descripcion,
			id_tipoproveedor,
			cd_tipoproveedor,
			ds_tipoproveedor,
			cd_Consecutivo_variablesadicionales,
			cd_item

		)	        
		SELECT 
			cd_fuente = F.Facturacion.value('cd_fuente[1]','VARCHAR(2)'), 
			cd_serie = F.Facturacion.value('cd_serie[1]','VARCHAR(2)'),
			cd_consecutivo = F.Facturacion.value('cd_consecutivo[1]','VARCHAR(8)'),
			Tipo = NULL,
			Servicio = '',
			Descrip = '',
			id_factura = F.Facturacion.value('id_factura[1]','INT'),
			id_item = NULL,
			in_tipoitem = NULL,
			iden_gds = NULL,
			ds_fecha = ISNULL(F.Facturacion.value('dt_fechacont[1]','SMALLDATETIME'),'19000101'),
			cd_tiqueteador = ISNULL(F.Facturacion.value('cd_tiqueteador[1]','VARCHAR(25)'),''),
			cd_vendedor = ISNULL(F.Facturacion.value('cd_vendedor[1]','VARCHAR(25)'),''),
			cd_cliente = ISNULL(F.Facturacion.value('cd_cliente_codigo[1]','VARCHAR(25)'),''),
			am_highfare = 0,
			am_lowfare = 0,
			am_fare = 0,
			ds_reasoncode = '',
			ds_cliname = ISNULL(F.Facturacion.value('ds_cliente_nombre[1]','VARCHAR(250)'),''),
			ds_clidir = ISNULL(F.Facturacion.value('ds_cliente_dir[1]','VARCHAR(250)'),''),
			ds_clicity = ISNULL(F.Facturacion.value('ds_cliente_ciudad[1]','VARCHAR(50)'),''),
			ds_cliid = ISNULL(F.Facturacion.value('cd_cliente_codigo[1]','VARCHAR(10)'),''),
			ds_itinerario = '',
			ds_clases = '',
			in_nacionalidad = 0,
			id_air = NULL,
			ds_pax_number = 0,
			ds_pax_firstnm = '',
			ds_pax_lastnm = '',
			ds_pax_prefix = '',
			ds_tkt_number = '',
			ds_tkt_prefix = '',
			ds_aero_code = '',
			ds_moneda = ISNULL(F.Facturacion.value('cd_monedas_iata[1]','VARCHAR(25)'),'COP'),
			am_tarifa = 0,
			am_iva = 0,
			am_tua = 0,
			am_comb = 0,
			am_vat = 0,
			ds_cc_code = '',
			ds_cc_number = '',
			am_tao = 0,
			am_ivatao = 0,
			am_cap = 0,
			am_ivacap = 0,
			ds_cc_code2 = '',
			ds_cc_number2 = '',
			am_fp1 = 0,
			am_fp2 = 0,
			cd_tktrevisado = '',
			am_TarifaContado = 0,
			am_IvaContado = 0,
			am_OtrosContado = 0,
			am_TarifaCredito = 0,
			am_IvaCredito = 0,
			am_OtrosCredito = 0,
			am_Comision = 0,
			cd_clitipodoc = '',
			cd_clitipotercero = '',
			ds_clirazoncial = '',
			ds_cliname2 = '',
			ds_clilastname = '',
			ds_clilastname2 = '',
			cd_clipais = '',
			ds_clitel = ISNULL(F.Facturacion.value('ds_cliente_tel[1]','VARCHAR(61)'),''),
			cd_TipoTransaccion = '',
			Fecha_Salida = GETDATE(),
			Fecha_Llegada = GETDATE(),
			Id_Srv = NULL,
			cd_conceptofacturacion = '',
			cd_tiposervicio = '',
			cd_proveedores = '',
			ds_proveedores = '',
			id_car = NULL,
			dt_entrega = GETDATE(),
			in_cars = 0,
			cd_carcode = '',
			cd_conf_car = '',
			cd_citysalida=ISNULL(F.Facturacion.value('cd_citysalida[1]','VARCHAR(61)'),''),
			dt_retorno=F.Facturacion.value('dt_retorno[1]','SMALLDATETIME'),
			cd_cartype=ISNULL(F.Facturacion.value('cd_cartype[1]','VARCHAR(61)'),''),
			cd_currency=ISNULL(F.Facturacion.value('cd_currency[1]','VARCHAR(3)'),'COP'),
			am_tarifacar=ISNULL(F.Facturacion.value('am_tarifacar[1]','MONEY'),0),
			cd_bookingsource=ISNULL(F.Facturacion.value('cd_bookingsource[1]','VARCHAR(61)'),''),
			cd_ratecode=ISNULL(F.Facturacion.value('cd_ratecode[1]','VARCHAR(61)'),''),
			id_htl=NULL,
			dt_checkin=F.Facturacion.value('dt_checkin[1]','SMALLDATETIME'),
			in_guests=ISNULL(F.Facturacion.value('in_guests[1]','INT'),0),
			cd_confirmation=ISNULL(F.Facturacion.value('cd_confirmation[1]','VARCHAR(61)'),''),
			cd_city=ISNULL(F.Facturacion.value('cd_city[1]','VARCHAR(61)'),''),
			cd_htlchain=ISNULL(F.Facturacion.value('cd_htlchain[1]','VARCHAR(61)'),''),
			dt_checkout=F.Facturacion.value('dt_checkout[1]','SMALLDATETIME'),
			in_noches=ISNULL(F.Facturacion.value('in_noches[1]','INT'),0),
			ds_htlname=ISNULL(F.Facturacion.value('ds_htlname[1]','VARCHAR(61)'),''),
			in_habs=ISNULL(F.Facturacion.value('in_habs[1]','INT'),0),
			cd_bed=ISNULL(F.Facturacion.value('cd_bed[1]','VARCHAR(61)'),''),
			cd_ratecode_htl=ISNULL(F.Facturacion.value('cd_ratecode_htl[1]','VARCHAR(61)'),''),
			cd_htlcur=ISNULL(F.Facturacion.value('cd_htlcur[1]','VARCHAR(61)'),''),
			am_htltarifa=ISNULL(F.Facturacion.value('am_htltarifa[1]','MONEY'),0),
			cd_agcur=ISNULL(F.Facturacion.value('cd_agcur[1]','VARCHAR(61)'),''),
			am_agtarifa=ISNULL(F.Facturacion.value('am_agtarifa[1]','MONEY'),0),
			ds_dir1=ISNULL(F.Facturacion.value('ds_dir1[1]','VARCHAR(61)'),''),
			ds_tel=ISNULL(F.Facturacion.value('ds_tel[1]','VARCHAR(61)'),''),
			ds_fax=ISNULL(F.Facturacion.value('ds_fax[1]','VARCHAR(61)'),''),
			cd_centrocosto=ISNULL(F.Facturacion.value('cd_centrocosto[1]','VARCHAR(61)'),''),
			NumTktConj=ISNULL(F.Facturacion.value('NumTktConj[1]','VARCHAR(61)'),''),
			Respuesta=NULL,
			ds_solicita = '',
			cd_pax_CC = '',
			ds_lapsoviaje = '',
			ds_archivo = ISNULL(F.Facturacion.value('ds_archivo[1]','VARCHAR(61)'),''),
			ds_Observaciones = ISNULL(F.Facturacion.value('ds_Observacion[1]','VARCHAR(8000)'),''),
			ds_ClienteEmail = ISNULL(F.Facturacion.value('ds_cliente_email[1]','VARCHAR(61)'),''),
			cd_sucursal = ISNULL(F.Facturacion.value('cd_sucursal[1]','VARCHAR(25)'),'OFP'),
			cd_implante = ISNULL(F.Facturacion.value('cd_implante[1]','VARCHAR(25)'),''), 
			bl_ClienteActualizar = 0,
			bl_NotificacionMPD = 0,
			cd_FormaPagoTAO = '',
			cd_TarjetaCreditoTAO = '', 
			cd_NumeroTarjetaTAO = '', 
			cd_VencimientoTarjetaTAO = '__/__', 
			cd_NumeroPolizaTAO = '',
			cd_AnexoPolizaTAO = '',
			am_PorDesFormaPagoTA = 0, 
			cd_Penalidad = '', 
			ds_cc_vence = '', 
			ds_cc_vence2 = '',
			ds_cc_autorizacion = '',
			ds_cc_autorizacion2 = '',
			ds_cc_voucher = '',
			ds_cc_voucher2 = '',
			ds_AutorizacionTarjetaTAO = '',
			ds_VoucherTarjetaTAO = '',
			am_fptao = 0,
			in_cc_cuotas = 0,
			in_cc_cuotas2 = 0,
			in_cuotasTarjetaTAO = 0,
			cd_TipoTarifaTAO = '',
			cd_TipoTiquete = '',
			am_TasaCambio = ISNULL(F.Facturacion.value('Tcambio[1]','MONEY'),1),
			cd_tiqueteador_facturador = '',
			bl_ahorro = 0,
			in_CantidadTarifaTAO = 0,
			in_CantidadSegmentoTAO = 0,
			cd_tourcode = '',
			ds_contrato = '',
			cd_PasaportePax = '',
			ds_itinerarioaerolinea = '',
			ds_tkt_prefixIata = '',
			ds_Evento = ISNULL(F.Facturacion.value('ds_Evento[1]','VARCHAR(61)'),''),
			cd_iata = ISNULL(F.Facturacion.value('cd_iata[1]','VARCHAR(61)'),''),
			ds_aero_codeIata = '',
			ReservaFactura = '',
			cd_Ahorro = '',
			cd_Categoria = '',
			Id_FormasPagoAirPlus = NULL,
			cd_FormasPagoAirPlus = '',
			ds_FormasPagoAirPlus = '',
			cd_TarjetasCreditoAirPlus = '',
			ds_numerotarjetaAirPlus = '',
			am_PorFacParcial = 100,
			am_PorFacParcial_Utilizar = 0,
			in_cantpax = 0,
			Id_Precompra = NULL,
			id_sucursal = 1,
			bl_cotizacion = 0,
			cd_htl = '',
			id_FormasPago = NULL,
			id_TarjetasCredito = NULL,
			id_formapago_cliente = NULL,
			cd_formapago_cliente = '',
			ds_formapago_cliente = '',
			cd_fp_OtrosItems = '',
			cd_auxiliar = '',
			cd_tipoventa = ISNULL(F.Facturacion.value('id_tipoventa[1]','VARCHAR(61)'),''),
			am_iva2 = 0,
			cd_licitacion = ISNULL(F.Facturacion.value('id_Licitacion[1]','VARCHAR(61)'),''),
			ds_descripcion = '',
			id_tipoproveedor = NULL,
			cd_tipoproveedor = '',
			ds_tipoproveedor = '',
			cd_Consecutivo_variablesadicionales = '',
			cd_item = ''
        FROM @xmlData.nodes('/Facturaciones/Facturacion') AS F(Facturacion);


		INSERT INTO #TmpFacturaItems (
			id_factura, id_item, in_tipoitem, tipo_item, id_referencia_origen, cd_fuente, cd_serie, cd_consecutivo, cd_tiquete, ds_descrip, in_nacionalidad, 
			cd_cencosto, cd_auxiliar, cd_item, am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision, 
			ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, cd_TipoTiquete, id_air, 
			ds_itinerario, ds_itinerarioaerolinea, ds_clases, ds_Observaciones, am_highfare, am_lowfare, 
			ds_solicita, ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, am_PorFacParcial, 
			in_cantpax, Id_Precompra, cd_FormaPagoTAO, cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, 
			cd_VencimientoTarjetaTAO, cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, ds_AutorizacionTarjetaTAO, 
			in_cuotasTarjetaTAO, id_FormasPago, id_TarjetasCredito, am_fp1, ds_cc_code, ds_cc_number, 
			ds_cc_vence, ds_cc_autorizacion, ds_cc_voucher, in_cc_cuotas, am_fp2, ds_cc_code2, 
			ds_cc_number2, ds_cc_vence2, ds_cc_autorizacion2, ds_cc_voucher2, in_cc_cuotas2, 
			id_monedas_iata, Tcambio, id_sucursal, id_implante, bl_ahorro, cd_TipoTiqueteGDS, 
			id_TiposDocumento, id_entdist, id_entvend, cd_destino, dt_fechaexped, id_tiqueteadores, 
			id_gds, iden_gds, am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision, 
			am_basecomisionable, am_porcomision, id_tiposconceptfac, id_conceptofacturacion, 
			id_tiposservicio, cd_proveedores, ds_servicio, am_valorprov, id_monedaprov, dt_llegada, 
			dt_salida, am_pordescuento, Fecha_Salida, Fecha_Llegada, am_basedescuento, cd_Consecutivo_depende, 
			cd_Consecutivo_variablesadicionales, am_valor_total, ds_proveedores, id_tipoproveedor, cd_tipoproveedor, ds_tipoproveedor,
			id_FormasPagoAirPlus, cd_FormasPagoAirPlus, ds_FormasPagoAirPlus, id_TarjetasCreditoAirPlus,
			cd_TarjetasCreditoAirPlus, ds_numerotarjetaAirPlus, id_reserva,	OrdenGrabacion
		)
		SELECT 
			id_factura = F.Item.value('id_factura[1]','INT'),
			id_item = F.Item.value('id_item[1]','INT'),
			in_tipoitem = F.Item.value('in_tipoitem[1]','INT'),
			tipo_item = F.Item.value('tipo_item[1]','VARCHAR(10)'),
			id_referencia_origen = F.Item.value('id_referencia_origen[1]','INT'),
			cd_fuente=FF.cd_fuente,
			cd_serie=FF.cd_serie,
			cd_consecutivo=FF.cd_consecutivo,
			cd_tiquete = ISNULL(F.Item.value('cd_tiquete[1]','VARCHAR(50)'),''),
			ds_descrip = ISNULL(F.Item.value('ds_descrip[1]','VARCHAR(500)'),''),
			in_nacionalidad = ISNULL(F.Item.value('in_nacionalidad[1]','INT'),0),
			cd_cencosto = ISNULL(F.Item.value('cd_cencosto[1]','VARCHAR(50)'),''),
			cd_auxiliar = ISNULL(F.Item.value('cd_auxiliar[1]','VARCHAR(50)'),''),
			cd_item = ISNULL(F.Item.value('cd_item[1]','VARCHAR(50)'),''),
			am_tarifa = ISNULL(F.Item.value('am_tarifa[1]','MONEY'),0),
			am_iva = ISNULL(F.Item.value('am_iva[1]','MONEY'),0),
			am_tua = ISNULL(F.Item.value('am_tua[1]','MONEY'),0),
			am_comb = ISNULL(F.Item.value('am_comb[1]','MONEY'),0),
			am_vat = ISNULL(F.Item.value('am_vat[1]','MONEY'),0),
			am_Comision = ISNULL(F.Item.value('am_comision[1]','MONEY'),0),
			ds_paxname = ISNULL(F.Item.value('ds_paxname[1]','VARCHAR(30)'),''),
			ds_paxape = ISNULL(F.Item.value('ds_paxape[1]','VARCHAR(30)'),''),
			ds_paxprefix = ISNULL(F.Item.value('ds_paxprefix[1]','VARCHAR(3)'),''),
			cd_tourcode = ISNULL(F.Item.value('cd_tourcode[1]','VARCHAR(25)'),''),
			NumTktConj = F.Item.value('NumTktConj[1]','INT'),
			cd_TipoTiquete = F.Item.value('cd_tipotiquete[1]','VARCHAR(3)'),
			id_air = F.Item.value('id_air[1]','INT'),
			ds_itinerario = ISNULL(F.Item.value('ds_itinerario[1]','VARCHAR(250)'),''),
			ds_itinerarioaerolinea = ISNULL(F.Item.value('ds_itinerarioaerolinea[1]','VARCHAR(128)'),''),
			ds_clases = ISNULL(F.Item.value('ds_clases[1]','VARCHAR(61)'),''),
			ds_Observaciones = ISNULL(F.Item.value('ds_observaciones[1]','VARCHAR(8000)'),''),
			am_highfare = ISNULL(F.Item.value('am_highfare[1]','MONEY'),0),
			am_lowfare = ISNULL(F.Item.value('am_lowfare[1]','MONEY'),0),
			ds_solicita = ISNULL(F.Item.value('ds_solicita[1]','VARCHAR(200)'),''),
			ds_lapsoviaje = ISNULL(F.Item.value('ds_lapsoviaje[1]','VARCHAR(50)'),''),
			cd_tktrevisado = ISNULL(F.Item.value('cd_tktrevisado[1]','VARCHAR(14)'),''),
			cd_PasaportePax = ISNULL(F.Item.value('cd_pasaportepax[1]','VARCHAR(25)'),''),
			cd_pax_CC = ISNULL(F.Item.value('cd_pax_cc[1]','VARCHAR(20)'),''),
			am_PorFacParcial = ISNULL(F.Item.value('am_porfacparcial[1]','MONEY'),100),
			in_cantpax = ISNULL(F.Item.value('in_cantpax[1]','INT'),0),
			Id_Precompra = F.Item.value('id_precompra[1]','INT'),
			cd_FormaPagoTAO = ISNULL(F.Item.value('cd_formapagotao[1]','VARCHAR(3)'),''),
			cd_TarjetaCreditoTAO = ISNULL(F.Item.value('cd_tarjetacreditotao[1]','VARCHAR(4)'),''),
			cd_NumeroTarjetaTAO = ISNULL(F.Item.value('cd_numerotarjetatao[1]','VARCHAR(25)'),''),
			cd_VencimientoTarjetaTAO = ISNULL(F.Item.value('cd_vencimientotarjetatao[1]','VARCHAR(6)'),''),
			cd_NumeroPolizaTAO = ISNULL(F.Item.value('cd_numeropolizatao[1]','VARCHAR(50)'),''),
			cd_AnexoPolizaTAO = ISNULL(F.Item.value('cd_anexopolizatao[1]','VARCHAR(50)'),''),
			ds_AutorizacionTarjetaTAO = ISNULL(F.Item.value('ds_autorizaciontarjetatao[1]','VARCHAR(25)'),''),
			in_cuotasTarjetaTAO = ISNULL(F.Item.value('in_cuotasTarjetatao[1]','INT'),0),
			id_FormasPago = FP.id,
			id_TarjetasCredito = TC.id,
			am_fp1 = ISNULL(F.Item.value('am_fp1[1]','MONEY'),0),
			ds_cc_code = ISNULL(F.Item.value('ds_cc_code[1]','VARCHAR(2)'),''),
			ds_cc_number = ISNULL(F.Item.value('ds_cc_number[1]','VARCHAR(25)'),''),
			ds_cc_vence = ISNULL(F.Item.value('ds_cc_vence[1]','VARCHAR(5)'),''),
			ds_cc_autorizacion = ISNULL(F.Item.value('ds_cc_autorizacion[1]','VARCHAR(25)'),''),
			ds_cc_voucher = ISNULL(F.Item.value('ds_cc_voucher[1]','VARCHAR(25)'),''),
			in_cc_cuotas = ISNULL(F.Item.value('in_cc_cuotas[1]','INT'),0),
			am_fp2 = ISNULL(F.Item.value('am_fp2[1]','MONEY'),0),
			ds_cc_code2 = ISNULL(F.Item.value('ds_cc_code2[1]','VARCHAR(2)'),''),
			ds_cc_number2 = ISNULL(F.Item.value('ds_cc_number2[1]','VARCHAR(25)'),''),
			ds_cc_vence2 = ISNULL(F.Item.value('ds_cc_vence2[1]','VARCHAR(5)'),''),
			ds_cc_autorizacion2 = ISNULL(F.Item.value('ds_cc_autorizacion2[1]','VARCHAR(25)'),''),
			ds_cc_voucher2 = ISNULL(F.Item.value('ds_cc_voucher2[1]','VARCHAR(25)'),''),
			in_cc_cuotas2 = ISNULL(F.Item.value('in_cc_cuotas2[1]','INT'),0),
			id_monedas_iata = M.id,
			Tcambio = ISNULL(F.Item.value('tcambio[1]','MONEY'),1),
			id_sucursal = S.id,
			id_implante = I.id,
			bl_ahorro = ISNULL(F.Item.value('bl_ahorro[1]','BIT'),0),
			cd_TipoTiqueteGDS = ISNULL(F.Item.value('cd_tipotiquetegds[1]','VARCHAR(3)'),''),
			id_TiposDocumento = TD.id,
			id_entdist = ED.id,
			id_entvend = EV.id,
			cd_destino = ISNULL(F.Item.value('cd_destino[1]','VARCHAR(3)'),''),
			dt_fechaexped = F.Item.value('dt_fechaexped[1]','SMALLDATETIME'),
			id_tiqueteadores = TQ.id,
			id_gds = F.Item.value('id_gds[1]','INT'),
			iden_gds = F.Item.value('iden_gds[1]','INT'),
			am_comisionPNR = ISNULL(F.Item.value('am_comisionpnr[1]','MONEY'),0),
			ds_records = ISNULL(F.Item.value('ds_records[1]','VARCHAR(62)'),''),
			bl_NoCalcComision = ISNULL(F.Item.value('bl_nocalccomision[1]','BIT'),0),
			bl_NoCalcIvaComision = ISNULL(F.Item.value('bl_nocalcivacomision[1]','BIT'),0),
			am_basecomisionable = ISNULL(F.Item.value('am_basecomisionable[1]','MONEY'),0),
			am_porcomision = ISNULL(F.Item.value('am_porcomision[1]','MONEY'),0),
			id_tiposconceptfac = ISNULL(CF.id_TiposConceptoFacturacion, ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion ORDER BY id), 2)),
			id_conceptofacturacion = ISNULL(CF.id, ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE cd_codigo = 'SOP'), ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion ORDER BY id), 1))),
			id_tiposservicio = ISNULL(CASE WHEN TS.id IS NOT NULL THEN TS.id ELSE TSA.id_TipoServicio END, ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios WHERE cd_codigo IN ('htn','SOP')), ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios ORDER BY id), 1))),
			cd_proveedores = ISNULL(F.Item.value('cd_proveedores[1]','VARCHAR(25)'),''),
			ds_servicio = ISNULL(F.Item.value('ds_servicio[1]','VARCHAR(250)'),''),
			am_valorprov = ISNULL(F.Item.value('am_valorprov[1]','MONEY'),0),
			id_monedaprov = F.Item.value('id_monedaprov[1]','INT'),
			dt_llegada = F.Item.value('dt_llegada[1]','SMALLDATETIME'),
			dt_salida = F.Item.value('dt_salida[1]','SMALLDATETIME'),
			am_pordescuento = ISNULL(F.Item.value('am_pordescuento[1]','NUMERIC(8,4)'),0),
			Fecha_Salida = F.Item.value('fecha_salida[1]','SMALLDATETIME'),
			Fecha_Llegada = F.Item.value('fecha_llegada[1]','SMALLDATETIME'),
			am_basedescuento = ISNULL(F.Item.value('am_basedescuento[1]','MONEY'),0),
			cd_Consecutivo_depende = ISNULL(F.Item.value('cd_consecutivo_depende[1]','VARCHAR(50)'),''),
			cd_Consecutivo_variablesadicionales = ISNULL(F.Item.value('cd_consecutivo_variablesadicionales[1]','VARCHAR(50)'),''),
			am_valor_total = ISNULL(F.Item.value('am_valor_total[1]','MONEY'),0), 
			ds_proveedores = ISNULL(F.Item.value('ds_proveedores[1]','VARCHAR(25)'),''),
			id_tipoproveedor = ISNULL(TP.id,1),
			cd_tipoproveedor = ISNULL(F.Item.value('cd_tipoproveedor[1]','VARCHAR(25)'),'HTL'),
			ds_tipoproveedor = ISNULL(F.Item.value('ds_tipoproveedor[1]','VARCHAR(50)'),'Hotel'),
			id_FormasPagoAirPlus = F.Item.value('id_formaspagoairplus[1]','INT'),
			cd_FormasPagoAirPlus = ISNULL(F.Item.value('cd_formaspagoairplus[1]','VARCHAR(25)'),''),
			ds_FormasPagoAirPlus = ISNULL(F.Item.value('ds_formaspagoairplus[1]','VARCHAR(50)'),''),
			id_TarjetasCreditoAirPlus = F.Item.value('id_tarjetascreditoairplus[1]','INT'),
			cd_TarjetasCreditoAirPlus = ISNULL(F.Item.value('cd_tarjetascreditoairplus[1]','VARCHAR(25)'),''),
			ds_numerotarjetaAirPlus = ISNULL(F.Item.value('ds_numerotarjetaairplus[1]','VARCHAR(50)'),''),
			id_reserva = F.Item.value('id_reserva[1]','INT'),	
			OrdenGrabacion = ROW_NUMBER() OVER (ORDER BY id_item ASC)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item') F(Item)
		LEFT JOIN #Facturacion FF ON FF.id_factura = F.Item.value('id_factura[1]','INT')
		LEFT JOIN dbo.Monedas_IATA M ON M.cd_codigo = F.Item.value('cd_monedas_iata[1]','VARCHAR(25)')
		LEFT JOIN dbo.Sucursales S ON S.cd_codigo = F.Item.value('cd_sucursal[1]','VARCHAR(25)')
		LEFT JOIN dbo.Implantes I ON I.cd_codigo = F.Item.value('cd_implante[1]','VARCHAR(25)')
		LEFT JOIN dbo.FormasPago FP ON FP.cd_codigo = F.Item.value('cd_formasPago[1]','VARCHAR(25)')
		LEFT JOIN dbo.TarjetasCredito TC ON TC.cd_codigo = F.Item.value('cd_tarjetascredito[1]','VARCHAR(25)')
		LEFT JOIN dbo.TiposDocumento TD ON TD.cd_codigo = F.Item.value('cd_tiposdocumento[1]','VARCHAR(25)')
		LEFT JOIN dbo.Entidades ED ON ED.cd_codigo = F.Item.value('cd_entdist[1]','VARCHAR(25)')
		LEFT JOIN dbo.Entidades	EV ON EV.cd_codigo = F.Item.value('cd_entvend[1]','VARCHAR(25)')
		LEFT JOIN dbo.Tiqueteadores	TQ ON TQ.cd_codigo = F.Item.value('cd_tiqueteadores[1]','VARCHAR(25)')
		LEFT JOIN dbo.TiposServicios TS ON TS.cd_codigo = F.Item.value('cd_tiposservicio[1]','VARCHAR(25)')
		LEFT JOIN dbo.ConceptoFacturacion CF ON CF.cd_codigo = F.Item.value('cd_conceptofacturacion[1]','VARCHAR(25)')
		LEFT JOIN dbo.tiposServicio_asignados TSA ON TSA.id_ConceptoFacturacion = CF.id
		LEFT JOIN dbo.TipoProveedores TP ON TP.cd_codigo = F.Item.value('cd_tipoproveedor[1]','VARCHAR(25)')
		
		-- Populate child tables from XML
		DELETE FROM #Pasajeros;
		INSERT INTO #Pasajeros (
			id_facturacion, id_item, in_tipoitem, ds_paxape, ds_paxname, ds_paxprefix, ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion, in_edad, cd_tiquete
		)
		SELECT 
			id_facturacion=ISNULL(P.Pax.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(P.Pax.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(P.Pax.value('in_tipoitem[1]', 'INT'),0),
			ds_paxape=ISNULL(P.Pax.value('ds_paxape[1]', 'VARCHAR(50)'),''),
			ds_paxname=ISNULL(P.Pax.value('ds_paxname[1]', 'VARCHAR(50)'),''),
			ds_paxprefix=ISNULL(P.Pax.value('ds_paxprefix[1]', 'VARCHAR(10)'),''),
			ds_paxclasificacion=ISNULL(P.Pax.value('ds_paxclasificacion[1]', 'VARCHAR(10)'),''),
			cd_voucherpax=ISNULL(P.Pax.value('cd_voucherpax[1]', 'VARCHAR(50)'),''),
			cd_paxidentificacion=ISNULL(P.Pax.value('cd_paxidentificacion[1]', 'VARCHAR(50)'),''),
			in_edad=ISNULL(P.Pax.value('in_edad[1]', 'INT'),0),
			cd_tiquete=ISNULL(P.Pax.value('cd_tiquete[1]', 'VARCHAR(50)'),'')
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Pasajeros') P(Pax);

		DELETE FROM #Itinerarios;
		INSERT INTO #Itinerarios (
			id_facturacion, id_item, in_tipoitem, in_orden, ds_origen, ds_destino, ds_clase, dt_llegada, dt_salida, ds_terminal, cd_aerolinea, cd_farebasis, ds_numerovuelo, ds_tipovuelo, am_valor, am_co2
		)
		SELECT 
			id_facturacion=ISNULL(I.Itin.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(I.Itin.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(I.Itin.value('in_tipoitem[1]', 'INT'),0),
			in_orden=ISNULL(I.Itin.value('in_orden[1]', 'INT'),0),
			ds_origen=ISNULL(I.Itin.value('ds_origen[1]', 'VARCHAR(25)'),''),
			ds_destino=ISNULL(I.Itin.value('ds_destino[1]', 'VARCHAR(25)'),''),
			ds_clase=ISNULL(I.Itin.value('ds_clase[1]', 'VARCHAR(25)'),''),
			dt_llegada=ISNULL(I.Itin.value('dt_llegada[1]', 'SMALLDATETIME'),'19000101 00:00'),
			dt_salida=ISNULL(I.Itin.value('dt_salida[1]', 'SMALLDATETIME'),'19000101 00:00'),
			ds_terminal=ISNULL(I.Itin.value('ds_terminal[1]', 'VARCHAR(25)'),''),
			cd_aerolinea=ISNULL(I.Itin.value('cd_aerolinea[1]', 'VARCHAR(25)'),''),
			cd_farebasis=ISNULL(I.Itin.value('cd_farebasis[1]', 'VARCHAR(25)'),''),
			ds_numerovuelo=ISNULL(I.Itin.value('ds_numerovuelo[1]', 'VARCHAR(25)'),''),
			ds_tipovuelo=ISNULL(I.Itin.value('ds_tipovuelo[1]', 'VARCHAR(25)'),''),
			am_valor=ISNULL(I.Itin.value('am_valor[1]', 'MONEY'),0),
			am_co2=ISNULL(I.Itin.value('am_co2[1]', 'MONEY'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/itinerarios') I(Itin);

		DELETE FROM #CargosImpuestos;
		INSERT INTO #CargosImpuestos (
			id_facturacion, id_item, in_tipoitem, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_contado, am_credito, am_valor, id_carg, id_imp, bl_iva, in_orden
		)
		SELECT 
			id_facturacion=ISNULL(C.Cargo.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(C.Cargo.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(C.Cargo.value('in_tipoitem[1]', 'INT'),0),
			cd_codigo=ISNULL(C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)'),''),
			ds_nombre=ISNULL(C.Cargo.value('ds_nombre[1]', 'VARCHAR(100)'),''),
			cd_tipo=ISNULL(C.Cargo.value('cd_tipo[1]', 'CHAR(1)'),''),
			am_porcentaje=ISNULL(C.Cargo.value('am_porcentaje[1]', 'MONEY'),0),
			am_contado=ISNULL(C.Cargo.value('am_contado[1]', 'MONEY'),0),
			am_credito=ISNULL(C.Cargo.value('am_credito[1]', 'MONEY'),0),
			am_valor=ISNULL(C.Cargo.value('am_valor[1]', 'MONEY'),0),
			id_carg=CASE WHEN CD.id IS NOT NULL THEN CD.id ELSE IR.Id_cargo_dep END, 
			id_imp=IR.id, 
			bl_iva=ISNULL(IR.bl_IVA,0),
			in_orden=ISNULL(C.Cargo.value('in_orden[1]', 'INT'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/CargosImpuestos') C(Cargo)
		LEFT JOIN dbo.CargosDesc CD ON CD.cd_codigo=C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)') AND C.Cargo.value('cd_tipo[1]', 'CHAR(1)') IN ('C','D')
		LEFT JOIN dbo.ImpRet IR ON IR.cd_codigo=C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)') AND C.Cargo.value('cd_tipo[1]', 'CHAR(1)') IN ('I','R'); 

		DELETE FROM #FormasPagos;
		INSERT INTO #FormasPagos (
			id_facturacion, id_item, in_tipoitem, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_coutas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
		)
		SELECT 
			id_facturacion=ISNULL(F.Pago.value('id_factura[1]', 'INT'),0),
			id_item=ISNULL(F.Pago.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(F.Pago.value('in_tipoitem[1]', 'INT'),0),
			id_formaspago=ISNULL(FP.id,0),
			cd_codigo=ISNULL(F.Pago.value('cd_codigo[1]', 'VARCHAR(10)'),''),
			ds_nombre=ISNULL(F.Pago.value('ds_nombre[1]', 'VARCHAR(50)'),''),
			id_tarjetascredito=ISNULL(TC.id,0),
			cd_tipotarjeta=ISNULL(F.Pago.value('cd_tipotarjeta[1]', 'VARCHAR(10)'),''),
			ds_numerotarjeta=ISNULL(F.Pago.value('ds_numerotarjeta[1]', 'VARCHAR(50)'),''),
			ds_vouchertarjeta=ISNULL(F.Pago.value('ds_vouchertarjeta[1]', 'VARCHAR(50)'),''),
			ds_expiraciontarjeta=ISNULL(F.Pago.value('ds_expiraciontarjeta[1]', 'VARCHAR(10)'),''),
			ds_autorizaciontarjeta=ISNULL(F.Pago.value('ds_autorizaciontarjeta[1]', 'VARCHAR(50)'),''),
			in_cuotas=ISNULL(F.Pago.value('in_cuotas[1]', 'INT'),0),
			cd_banco=ISNULL(F.Pago.value('cd_banco[1]', 'VARCHAR(50)'),''),
			ds_cheque=ISNULL(F.Pago.value('ds_cheque[1]', 'VARCHAR(50)'),''),
			ds_plaza=ISNULL(F.Pago.value('ds_plaza[1]', 'VARCHAR(50)'),''),
			ds_referencia=ISNULL(F.Pago.value('ds_referencia[1]', 'VARCHAR(50)'),''),
			ds_Poliza=ISNULL(F.Pago.value('ds_Poliza[1]', 'VARCHAR(50)'),''),
			ds_PolizaAnexo=ISNULL(F.Pago.value('ds_PolizaAnexo[1]', 'VARCHAR(50)'),''),
			am_valor=ISNULL(F.Pago.value('am_valor[1]', 'MONEY'),0)
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Formaspago') F(Pago)
		LEFT JOIN dbo.FormasPago FP ON FP.cd_codigo = F.Pago.value('cd_codigo[1]', 'VARCHAR(10)')
		LEFT JOIN dbo.TarjetasCredito TC ON TC.cd_codigo = F.Pago.value('cd_tipotarjeta[1]', 'VARCHAR(10)');

		DELETE FROM #VariablesAdicionales;
		INSERT INTO #VariablesAdicionales (
			id_facturacion, id_item, in_tipoitem, ds_maestro, ds_VariableAdicional, ds_valor, cd_codigo
		)
		SELECT 
			id_facturacion=ISNULL(NULLIF(V.Var.value('id_factura[1]', 'INT'),0), ISNULL(NULLIF(V.Var.value('../id_factura[1]', 'INT'),0), ISNULL(V.Var.value('../../id_factura[1]', 'INT'),0))),
			id_item=ISNULL(V.Var.value('id_item[1]', 'INT'),0),
			in_tipoitem=ISNULL(V.Var.value('in_tipoitem[1]', 'INT'),0),
			ds_maestro=ISNULL(V.Var.value('ds_maestro[1]', 'VARCHAR(25)'),''),
			ds_VariableAdicional=ISNULL(V.Var.value('ds_VariableAdicional[1]', 'VARCHAR(25)'),''),
			ds_valor=ISNULL(V.Var.value('ds_valor[1]', 'VARCHAR(500)'),''),
			cd_codigo=ISNULL(V.Var.value('cd_codigo[1]', 'VARCHAR(25)'),'')
		FROM @xmlData.nodes('/Facturaciones/Facturacion/Item/Variables') V(Var);
	
	
	--While 1 = 1
	--Begin
		SET @Fecha = GETDATE();
		IF OBJECT_ID('dbo.Parametr', 'U') IS NOT NULL
		BEGIN
			SELECT TOP 1 @FechaCont = REPLACE(VALOPAR, '/', '') FROM dbo.Parametr WHERE PARAMETRO = 'FECHACT';
		END
		IF @FechaCont IS NULL SET @FechaCont = GETDATE();
		

			-- Cursor over unique ReservaFactura in this query result
			DECLARE curInvoices CURSOR LOCAL FOR
			SELECT DISTINCT cd_fuente,cd_serie,cd_consecutivo,id_factura
			FROM #Facturacion;

			OPEN curInvoices;
			FETCH NEXT FROM curInvoices INTO @cd_fuente,@cd_serie,@cd_consecutivo,@id_facturacion;

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				DELETE FROM #TmpFacturaCargos;
				DELETE FROM #TmpFacturaFormasPago;

				SET IDENTITY_INSERT #TmpFacturaItems ON;
				

				INSERT INTO #TmpFacturaCargos (id_item, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden)
				SELECT id_item, cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden
				FROM #CargosImpuestos
				WHERE id_facturacion = @id_facturacion;

				INSERT INTO #TmpFacturaFormasPago (id_item, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor)
				SELECT id_item, id_formaspago, cd_codigo, ds_nombre, id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_coutas, cd_banco, ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
				FROM #FormasPagos
				WHERE id_facturacion = @id_facturacion;

				-- Fetch header details from the first record in the group

				SELECT TOP 1
					@id_facturacion = id_factura,
					@id_item = id_item,
					@in_tipoitem = in_tipoitem, 
					@ds_cliid = ds_cliid,
					@cd_cliente = cd_cliente,
					@ds_cliname = ds_cliname,
					@ds_clidir = ds_clidir,
					@ds_clicity = ds_clicity,
					@ds_clitel = ds_clitel,
					@ds_ClienteEmail = ds_ClienteEmail,
					@ds_moneda = ds_moneda,
					@cd_vendedor = cd_vendedor,
					@cd_tiqueteador = cd_tiqueteador,
					@am_TasaCambio = am_TasaCambio,
					@cd_tipoventa = cd_tipoventa,
					@cd_licitacion = cd_licitacion,
					@ds_descripcion = ds_descripcion,
					@ds_Observaciones = ds_Observaciones,
					@ds_archivo = ds_archivo,
					@id_reserva = id,
					@cd_reserva = ReservaFactura,
					@cd_sucursal = cd_sucursal,
					@cd_implante = cd_implante,
					@FechaCont = ds_fecha
				FROM #Facturacion
				WHERE cd_fuente = @cd_fuente
					 AND cd_serie = @cd_serie
					 AND cd_consecutivo = @cd_consecutivo

				-- Resolve IDs for headers
				IF ISNULL(@cd_sucursal,'')=''
				BEGIN
					SET @cd_sucursal='01'
					SET @cd_implante=NULL
				END
				SELECT TOP 1 @id_sucursal = id FROM dbo.Sucursales WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_sucursal));
				IF @id_sucursal IS NULL SELECT TOP 1 @id_sucursal = id FROM dbo.Sucursales ORDER BY id;

				SELECT TOP 1 @id_implante = id FROM dbo.Implantes WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_implante)) AND id_sucursal = @id_sucursal;
				SELECT TOP 1 @id_monedas_iata = id FROM dbo.Monedas_IATA WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@ds_moneda));
				IF @id_monedas_iata IS NULL SELECT TOP 1 @id_monedas_iata = id FROM dbo.Monedas_IATA ORDER BY id;

				SELECT TOP 1 @id_tiqueteador = id FROM dbo.Tiqueteadores WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_tiqueteador));
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM ZeusAgencias_23.dbo.Tiqueteadores WHERE LTRIM(RTRIM(cd_codigo)) = LTRIM(RTRIM(@cd_tiqueteador));
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM dbo.Tiqueteadores ORDER BY id;
				IF @id_tiqueteador IS NULL SELECT TOP 1 @id_tiqueteador = id FROM ZeusAgencias_23.dbo.Tiqueteadores ORDER BY id;
				IF @id_tiqueteador IS NULL SET @id_tiqueteador = 2;

				SELECT TOP 1 @id_tipoventa = id_tipoventa FROM dbo.Tiqueteadores WHERE id = @id_tiqueteador;
				SELECT TOP 1 @cd_bu = cd_bu FROM dbo.Implantes WHERE id = @id_implante;
				IF ISNULL(@cd_bu,'')='' SELECT TOP 1 @cd_bu = cd_bu FROM dbo.Sucursales WHERE id = @id_sucursal;
				IF @id_tipoventa IS NULL SET @id_tipoventa = 1;

				SELECT TOP 1 @am_tcambiousd = am_tasa_cambio FROM dbo.Monedas_IATA WHERE cd_codigo = 'USD';
				IF @am_tcambiousd IS NULL SET @am_tcambiousd = 1.0;

				SELECT @ValorFactura = SUM(
					CASE 
						WHEN tipo_item = 'Aire' THEN (am_tarifa + am_iva + am_tua + am_comb + am_vat)
						ELSE am_tarifa + am_iva + am_vat
					END
				)
				FROM #TmpFacturaItems;

				UPDATE #Facturacion
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 10)
				WHERE tipo IN ('SRV','Hotel','Auto') AND cd_Consecutivo_variablesadicionales IS NULL

				-- Build dynamic SQL @SqlStmt
				SET @SqlStmt = '';
				SET @ItemIndex = 1;	
					

				-- Generar cd_Consecutivo_variablesadicionales aleatorio para los servicios padres
				UPDATE #TmpFacturaItems
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 10)
				WHERE tipo_item IN ('SRV','Hotel','Auto') AND cd_Consecutivo_variablesadicionales IS NULL
				 
				UPDATE C
				SET C.am_valor = ROUND(p.am_valor * (C.am_porcentaje/ 100.0), @NumDecimales),
					C.am_contado = ROUND(p.am_contado * (C.am_porcentaje / 100.0), @NumDecimales),
					C.am_Credito = ROUND(p.am_Credito * (C.am_porcentaje / 100.0), @NumDecimales)
				FROM #TmpFacturaCargos C
				INNER JOIN #TmpFacturaCargos P ON P.id_cargo_temp <> C.id_cargo_temp AND P.id_item = C.id_item AND p.id_carg = C.id_carg AND ISNULL(P.am_valor,0)<>0 AND P.cd_tipo = 'C'
				INNER JOIN #TmpFacturaItems FI ON FI.id_item = C.id_item
				inner join dbo.ConceptoFacturacion CF ON CF.id = FI.id_conceptofacturacion
				WHERE ISNULL(C.am_valor,0)=0 AND ISNULL(C.am_porcentaje,0)<>0 AND C.cd_tipo IN ('I') AND (@CalcularAutoValoresItemFac = 'S' OR CF.bl_CalculoAutoValoresFacturacion=1)	
					  AND CF.id NOT IN(1,2);

				UPDATE FP
				SET FP.am_valor=ISNULL((SELECT SUM(C.am_valor) FROM #TmpFacturaCargos C WHERE C.id_item = FP.id_item AND ISNULL(C.am_valor,0)<>0),FP.am_valor) 
				FROM #TmpFacturaFormasPago FP
				INNER JOIN #TmpFacturaItems FI ON FI.id_item = FP.id_item
				INNER JOIN dbo.ConceptoFacturacion CF ON CF.id = FI.id_conceptofacturacion
				WHERE (@CalcularAutoValoresItemFac = 'S' OR CF.bl_CalculoAutoValoresFacturacion=1)
					  AND CF.id NOT IN(1,2);	
								
				-- Reconstruct dynamic @SqlStmt from tables
				SET @SqlStmt = '';
				SET @ItemIndex = 1;

				DECLARE @gen_id_item INT, @gen_tipo_item VARCHAR(10), @gen_cd_tiquete VARCHAR(50), @gen_ds_descrip VARCHAR(500), @gen_in_nacionalidad INT, @gen_cd_cencosto VARCHAR(50), @gen_cd_auxiliar VARCHAR(50), @gen_cd_item VARCHAR(50), @gen_am_tarifa MONEY, @gen_am_iva MONEY, @gen_am_tua MONEY, @gen_am_comb MONEY, @gen_am_vat MONEY, @gen_am_Comision MONEY, @gen_ds_paxname VARCHAR(30), @gen_ds_paxape VARCHAR(30), @gen_ds_paxprefix CHAR(3), @gen_cd_tourcode VARCHAR(25), @gen_NumTktConj INT, @gen_cd_TipoTiquete CHAR(3), @gen_id_air INT, @gen_ds_itinerario VARCHAR(250), @gen_ds_itinerarioaerolinea VARCHAR(128), @gen_ds_clases VARCHAR(61), @gen_ds_Observaciones VARCHAR(8000), @gen_am_highfare MONEY, @gen_am_lowfare MONEY, @gen_ds_solicita VARCHAR(200), @gen_ds_lapsoviaje VARCHAR(50), @gen_cd_tktrevisado VARCHAR(14), @gen_cd_PasaportePax VARCHAR(25), @gen_cd_pax_CC VARCHAR(20), @gen_am_PorFacParcial MONEY, @gen_in_cantpax INT, @gen_Id_Precompra INT, @gen_id_FormasPago INT, @gen_id_TarjetasCredito INT, @gen_id_sucursal INT, @gen_id_implante INT, @gen_bl_ahorro BIT, @gen_cd_TipoTiqueteGDS VARCHAR(3), @gen_id_TiposDocumento INT, @gen_id_entdist INT, @gen_id_entvend INT, @gen_cd_destino VARCHAR(3), @gen_dt_fechaexped SMALLDATETIME, @gen_id_tiqueteadores INT, @gen_id_gds INT, @gen_iden_gds INT, @gen_am_comisionPNR MONEY, @gen_ds_records VARCHAR(62), @gen_bl_NoCalcComision BIT, @gen_bl_NoCalcIvaComision BIT, @gen_am_basecomisionable MONEY, @gen_am_porcomision MONEY, @gen_id_tiposconceptfac INT, @gen_id_conceptofacturacion INT, @gen_id_tiposservicio INT,@gen_ds_tiposservicio VARCHAR(50), @gen_cd_proveedores VARCHAR(25), @gen_ds_servicio VARCHAR(250), @gen_am_valorprov MONEY, @gen_id_monedaprov INT, @gen_dt_llegada SMALLDATETIME, @gen_dt_salida SMALLDATETIME, @gen_am_pordescuento NUMERIC(8,4), @gen_Fecha_Salida SMALLDATETIME, @gen_Fecha_Llegada SMALLDATETIME, @gen_am_basedescuento MONEY, @gen_cd_Consecutivo_depende VARCHAR(50), @gen_cd_Consecutivo_variablesadicionales VARCHAR(50), @gen_id_referencia_origen INT, @gen_id_tipoproveedor INT, @gen_cd_tipoproveedor VARCHAR(50), @gen_ds_tipoproveedor VARCHAR(250);


				DECLARE curGenItems CURSOR LOCAL FAST_FORWARD FOR
				SELECT 
					id_item, tipo_item, cd_tiquete, ds_descrip, in_nacionalidad, cd_cencosto, cd_auxiliar, cd_item, am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision,
					ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, cd_TipoTiquete, id_air, ds_itinerario, ds_itinerarioaerolinea, ds_clases, ds_Observaciones,
					am_highfare, am_lowfare, ds_solicita, ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, am_PorFacParcial, in_cantpax, Id_Precompra,
					id_FormasPago, id_TarjetasCredito, id_sucursal, id_implante, bl_ahorro, cd_TipoTiqueteGDS, id_TiposDocumento, id_entdist, id_entvend,
					cd_destino, dt_fechaexped, id_tiqueteadores, id_gds, iden_gds, am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision,
					am_basecomisionable, am_porcomision, id_tiposconceptfac, id_conceptofacturacion, id_tiposservicio, cd_proveedores, ds_servicio,
					am_valorprov, id_monedaprov, dt_llegada, dt_salida, am_pordescuento, Fecha_Salida, Fecha_Llegada, am_basedescuento, cd_Consecutivo_depende, cd_Consecutivo_variablesadicionales, id_referencia_origen, id_tipoproveedor, cd_tipoproveedor, ds_tipoproveedor
				FROM #TmpFacturaItems
				WHERE id_factura=@id_facturacion
				ORDER BY id_item;

				IF OBJECT_ID('tempdb..#TmpVariablesObtenidas') IS NOT NULL DROP TABLE #TmpVariablesObtenidas;
				CREATE TABLE #TmpVariablesObtenidas (
					Iden_Variable INT,
					Nombre VARCHAR(100) COLLATE DATABASE_DEFAULT,
					ValorObtenido VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
					Id_Reserva INT,
					IDEN_Maestro INT,
					cd_Maestro VARCHAR(50) COLLATE DATABASE_DEFAULT
				);

				OPEN curGenItems;
				FETCH NEXT FROM curGenItems INTO 
					@gen_id_item, @gen_tipo_item, @gen_cd_tiquete, @gen_ds_descrip, @gen_in_nacionalidad, @gen_cd_cencosto, @gen_cd_auxiliar, @gen_cd_item, @gen_am_tarifa, @gen_am_iva, @gen_am_tua, @gen_am_comb, @gen_am_vat, @gen_am_Comision,
					@gen_ds_paxname, @gen_ds_paxape, @gen_ds_paxprefix, @gen_cd_tourcode, @gen_NumTktConj, @gen_cd_TipoTiquete, @gen_id_air, @gen_ds_itinerario, @gen_ds_itinerarioaerolinea, @gen_ds_clases, @gen_ds_Observaciones,
					@gen_am_highfare, @gen_am_lowfare, @gen_ds_solicita, @gen_ds_lapsoviaje, @gen_cd_tktrevisado, @gen_cd_PasaportePax, @gen_cd_pax_CC, @gen_am_PorFacParcial, @gen_in_cantpax, @gen_Id_Precompra,
					@gen_id_FormasPago, @gen_id_TarjetasCredito, @gen_id_sucursal, @gen_id_implante, @gen_bl_ahorro, @gen_cd_TipoTiqueteGDS, @gen_id_TiposDocumento, @gen_id_entdist, @gen_id_entvend,
					@gen_cd_destino, @gen_dt_fechaexped, @gen_id_tiqueteadores, @gen_id_gds, @gen_iden_gds, @gen_am_comisionPNR, @gen_ds_records, @gen_bl_NoCalcComision, @gen_bl_NoCalcIvaComision,
					@gen_am_basecomisionable, @gen_am_porcomision, @gen_id_tiposconceptfac, @gen_id_conceptofacturacion, @gen_id_tiposservicio, @gen_cd_proveedores, @gen_ds_servicio,
					@gen_am_valorprov, @gen_id_monedaprov, @gen_dt_llegada, @gen_dt_salida, @gen_am_pordescuento, @gen_Fecha_Salida, @gen_Fecha_Llegada, @gen_am_basedescuento, @gen_cd_Consecutivo_depende, @gen_cd_Consecutivo_variablesadicionales, @gen_id_referencia_origen, @gen_id_tipoproveedor, @gen_cd_tipoproveedor, @gen_ds_tipoproveedor;
			
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					IF @gen_tipo_item IN ('Aire')
					BEGIN

						-- Build cargos / impuestos SQL
						SET @TktSqlStmt = '';
						
						DELETE FROM #TmpVariablesObtenidas;
						IF @gen_id_referencia_origen IS NOT NULL AND OBJECT_ID('dbo.spConfiguracionVariablesObtenerValores', 'P') IS NOT NULL
						BEGIN
							INSERT INTO #TmpVariablesObtenidas
							EXEC dbo.spConfiguracionVariablesObtenerValores 
								@id_usuario = 1, 
								@id_ReservaGDS_Detalles = @gen_id_referencia_origen;
								
							DECLARE @var_Iden_Variable INT, @var_IDEN_Maestro INT, @var_ValorObtenido VARCHAR(MAX);
							DECLARE curVars CURSOR LOCAL FAST_FORWARD FOR
							SELECT Iden_Variable, IDEN_Maestro, ValorObtenido FROM #TmpVariablesObtenidas WHERE ISNULL(ValorObtenido, '') <> '';

							OPEN curVars;
							FETCH NEXT FROM curVars INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TktSqlStmt = @TktSqlStmt + ' INSERT INTO dbo.VariableDatosMaestro (Iden_Variable, IDEN_Maestro, cd_maestro, ValorObtenido) VALUES (' + CAST(@var_Iden_Variable AS VARCHAR) + ', ' + CAST(@var_IDEN_Maestro AS VARCHAR) + ', ''' + REPLACE(@gen_cd_tiquete, '''', '''''') + ''', ''' + REPLACE(@var_ValorObtenido, '''', '''''') + ''');' + CHAR(13) + CHAR(10)
								FETCH NEXT FROM curVars INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido;
							END;
							CLOSE curVars;
							DEALLOCATE curVars;
						END
						
						DECLARE @c_codigo VARCHAR(20), @ds_nombre VARCHAR(100), @cd_tipo CHAR(1), @am_porcentaje NUMERIC(8,4), @am_valor MONEY, @am_contado MONEY, @am_credito MONEY, @id_carg INT, @id_imp INT;
						
						DECLARE @TktImpuestosSqlStmt VARCHAR(MAX) = '';
						
						DECLARE curItemCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');

						OPEN curItemCargos;
						FETCH NEXT FROM curItemCargos INTO @c_codigo, @ds_nombre, @cd_tipo, @am_porcentaje, @am_valor, @am_contado, @am_credito, @id_carg, @id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @c_codigotax VARCHAR(20), @ds_nombretax VARCHAR(100), @cd_tipotax CHAR(1), @am_porcentajetax NUMERIC(8,4), @am_valortax MONEY, @am_contadotax MONEY, @am_creditotax MONEY, @id_cargtax INT, @id_imptax INT;
							SET @TktImpuestosSqlStmt='';
							DECLARE curItemTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg = @id_carg AND cd_tipo IN ('I','R');

							OPEN curItemTaxes;
							FETCH NEXT FROM curItemTaxes INTO @c_codigotax, @ds_nombretax, @cd_tipotax, @am_porcentajetax, @am_valortax, @am_contadotax, @am_creditotax, @id_cargtax, @id_imptax;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TktImpuestosSqlStmt = @TktImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteImpuestos_Insertar @id_tiquetecargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + REPLACE(@ds_nombretax, '''', '''''') + ''',@cd_impcta='''', @am_valor = ' + CAST(@am_valortax AS VARCHAR) + ', @am_contado = ' + CAST(@am_contadotax AS VARCHAR) + ', @am_credito = ' + CAST(@am_creditotax AS VARCHAR) + ', @am_porcentaje = ' + CAST(@am_porcentajetax AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;'  
								FETCH NEXT FROM curItemTaxes INTO @c_codigotax, @ds_nombretax, @cd_tipotax, @am_porcentajetax, @am_valortax, @am_contadotax, @am_creditotax, @id_cargtax, @id_imptax;
							END
							CLOSE curItemTaxes;
							DEALLOCATE curItemTaxes;

							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteCargos_Insertar @id_fac_remision = @NewRmId, @id_fac_factura = @NewFacId, @id_tiquetes = @NewTktId, @id_cargosdesc = ' + CAST(ISNULL(@id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + REPLACE(@ds_nombre, '''', '''''') + ''', @am_valor = ' + CAST(@am_valor AS VARCHAR) + ', @am_contado = ' + CAST(@am_contado AS VARCHAR) + ', @am_credito = ' + CAST(@am_credito AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(@TktImpuestosSqlStmt, '''', '''''') + ''';'  
							
							FETCH NEXT FROM curItemCargos INTO @c_codigo, @ds_nombre, @cd_tipo, @am_porcentaje, @am_valor, @am_contado, @am_credito, @id_carg, @id_imp;
						END
						CLOSE curItemCargos;
						DEALLOCATE curItemCargos;
								

						-- Build Formas de Pago SQL
						DECLARE @fp_id_fp INT, @fp_id_tc INT, @fp_cd_codigo VARCHAR(10), @fp_ds_nombre VARCHAR(50), @fp_cd_tipotarjeta VARCHAR(10), @fp_ds_numerotarjeta VARCHAR(50), @fp_ds_vouchertarjeta VARCHAR(50), @fp_ds_expiraciontarjeta VARCHAR(10), @fp_ds_autorizaciontarjeta VARCHAR(50), @fp_in_cuotas INT, @fp_am_valor MONEY;
						DECLARE curItemFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemFPs;
						FETCH NEXT FROM curItemFPs INTO @fp_id_fp, @fp_id_tc, @fp_cd_codigo, @fp_ds_nombre, @fp_cd_tipotarjeta, @fp_ds_numerotarjeta, @fp_ds_vouchertarjeta, @fp_ds_expiraciontarjeta, @fp_ds_autorizaciontarjeta, @fp_in_cuotas, @fp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteFormasPago_Insertar @id_tiquetes = @NewTktId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_FormasPago = ' + CAST(@fp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@fp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_TarjetasCredito = ' + ISNULL(CAST(@fp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @fp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @fp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @fp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @fp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@fp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @fp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@fp_in_cuotas AS VARCHAR),'0') + ';' 
							FETCH NEXT FROM curItemFPs INTO @fp_id_fp, @fp_id_tc, @fp_cd_codigo, @fp_ds_nombre, @fp_cd_tipotarjeta, @fp_ds_numerotarjeta, @fp_ds_vouchertarjeta, @fp_ds_expiraciontarjeta, @fp_ds_autorizaciontarjeta, @fp_in_cuotas, @fp_am_valor;
						END
						CLOSE curItemFPs;
						DEALLOCATE curItemFPs;

						-- Build Itinerarios SQL (inline query, no temp table needed)
						SET @TktItinSqlStmt = '';
						SELECT 
							@TktItinSqlStmt = @TktItinSqlStmt + + CHAR(13) + CHAR(10) + 
							'EXECUTE dbo.spza_TiqueteItinerarios_Insertar 
								@id_fac_factura = @NewFacId, 
								@id_fac_remision = @NewRmId, 
								@id_Tiquetes = @NewTktId, 
								@orden = ' + CAST(in_orden AS VARCHAR) + ', 
								@cd_origen = ''' + ISNULL(ds_origen,'') + ''', 
								@cd_destino = ''' + ISNULL(ds_destino,'') + ''', 
								@cd_clase = ''' + ISNULL(LEFT(ds_clase,1),'') + ''', 
								@fecha_salida = ''' + ISNULL(CONVERT(VARCHAR(10),dt_salida,111),'') + ''', 
								@hora_salida = ''' + ISNULL(CONVERT(VARCHAR(8),dt_salida,108),'') + ''', 
								@hora_llegada = ''' + ISNULL(CONVERT(VARCHAR(8),dt_llegada,108),'') + ''', 
								@terminal = ''' + REPLACE(ISNULL(ds_terminal,''), '''', '''''') + ''', 
								@cd_aero_siglas = ''' + ISNULL(cd_aerolinea,'') + ''', 
								@cd_farebasis = ''' + ISNULL(cd_farebasis,'') + ''', 
								@ds_NumVuelo = ''' + ISNULL(ds_numerovuelo,'') + ''', 
								@ds_TipoVuelo = ''' + ISNULL(ds_tipovuelo,'') + ''', 
								@am_valor = ' + CAST(ISNULL(am_valor, 0) AS VARCHAR) + ', 
								@bl_NoUtilizado = NULL, 
								@am_co2 = ' + CAST(ISNULL(am_co2, 0) AS VARCHAR) + '; '
						FROM #Itinerarios
						WHERE id_item = @gen_id_item
						ORDER BY in_orden;

						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) + '
						DECLARE @NewTktId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Tiquete_Vender
							@cd_tiquete = ''' + ISNULL(@gen_cd_tiquete,'') + ''',
							@id_TiposDocumento = ' + ISNULL(CAST(@gen_id_TiposDocumento AS VARCHAR),'NULL') + ',
							@id_entdist = ' + ISNULL(CAST(@gen_id_entdist AS VARCHAR),'1') + ',
							@in_estado = 1,
							@in_nacionalidad = ' + ISNULL(CAST(@gen_in_nacionalidad AS VARCHAR),'1') + ',
							@id_entvend = ' + ISNULL(CAST(@gen_id_entvend AS VARCHAR),'NULL') + ',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@cd_tktrevisado = ' + ISNULL('''' + @gen_cd_tktrevisado + '''', 'NULL') + ',
							@id_pax = NULL,
							@ds_paxname = ''' + ISNULL(@gen_ds_paxname,'') + ''',
							@ds_paxape = ''' + ISNULL(@gen_ds_paxape,'') + ''',
							@ds_paxprefix = ''' + ISNULL(@gen_ds_paxprefix, '') + ''',
							@cd_paxcedula = ''' + ISNULL(@gen_cd_pax_CC, '') + ''',
							@ds_itinerario = ''' + ISNULL(LEFT(@gen_ds_itinerario, 63),'') + ''',
							@ds_itinerarioaerolinea = ''' + LEFT(ISNULL(@gen_ds_itinerarioaerolinea, ''), 63) + ''',
							@ds_clases = ''' + ISNULL(@gen_ds_clases, '') + ''',
							@dt_fechasalida = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@dt_fechallegada = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@cd_destino = ''' + ISNULL(@gen_cd_destino, '') + ''',
							@dt_fechaexped = ''' + ISNULL(CONVERT(VARCHAR, @gen_dt_fechaexped, 120),'19000101') + ''',
							@id_usuario = 1,
							@id_tiqueteadores = ' + ISNULL(CAST(@gen_id_tiqueteadores AS VARCHAR),'NULL') + ',
							@am_hf = ' + ISNULL(CAST(@gen_am_highfare AS VARCHAR),'0') + ',
							@am_lf = ' + ISNULL(CAST(@gen_am_lowfare AS VARCHAR),'0') + ',
							@am_tarifa = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'0') + ',
							@cd_ah = ''' + ISNULL(@gen_cd_tourcode, '') + ''',
							@am_desah = 0,
							@id_gds = ' + ISNULL(CAST(@gen_id_gds AS VARCHAR),'NULL') + ',
							@iden_gds = ' + ISNULL(CAST(@gen_iden_gds AS VARCHAR),'NULL') + ',
							@in_numtktconj = ' + ISNULL(CAST(@gen_NumTktConj AS VARCHAR),'0') + ',
							@bl_NoCalcComision = 0,
							@bl_NoCalcIvaComision = 0,
							@am_comisionPNR = ' + ISNULL(CAST(@gen_am_Comision AS VARCHAR),'0') + ',
							@am_basecomisionable = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'0') + ',
							@am_porcomision = 0,
							@ds_records = ''' + ISNULL(@gen_ds_records,'') + ''',
							@id_hotel = NULL,
							@id_precompra = ' + ISNULL(CAST(@gen_Id_Precompra AS VARCHAR), 'NULL') + ',
							@id_TipoTiquete = NULL,
							@id_ReassonCode = NULL,
							@cencosto_interno = ''' + ISNULL(@gen_cd_cencosto, '') + ''',
							@ds_solicita = ''' + ISNULL(@gen_ds_solicita, '') + ''',
							@ds_lapsoviaje = ''' + ISNULL(@gen_ds_lapsoviaje, '') + ''',
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@cd_TiqueteGr = NULL,
							@SqlStmt = ''' + REPLACE(ISNULL(@TktSqlStmt,''), '''', '''''') + ''',
							@SqlStmtItinerarios = ''' + REPLACE(ISNULL(@TktItinSqlStmt,''), '''', '''''') + ''',
							@id_sucursal = @id_sucursal,
							@id_implante = @id_implante,
							@bl_ahorro = ' + CAST(@gen_bl_ahorro AS VARCHAR) + ',
							@cd_TipoTiqueteGDS = ''' + ISNULL(@gen_cd_TipoTiqueteGDS, '') + ''',
							@cd_tourcode = ''' + ISNULL(@gen_cd_tourcode, '') + ''',
							@cd_PasaportePax = ''' + ISNULL(@gen_cd_PasaportePax, '') + ''',
							@am_valor_aerolinea = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'') + ',
							@am_porcentaje_comision_BackEnd = 0,
							@am_valor_comision_BackEnd = 0,
							@am_PorFacParcial = ' + CAST(ISNULL(@gen_am_PorFacParcial, 100) AS VARCHAR) + ',
							@in_cantpax = ' + CAST(ISNULL(@gen_in_cantpax, 1) AS VARCHAR) + ',
							@OrdenGrabacion = ' + CAST(ISNULL(@ItemIndex, 1) AS VARCHAR) + ',
							@cd_Penalidad = NULL,
							@id_entdistIata = NULL,
							@id_entvendIata = NULL; ';			
					END
					ELSE IF @gen_tipo_item = 'TAO'
					BEGIN 
						-- Build cargos / impuestos SQL
						SET @TaoCargSqlStmt = '';
						
						DECLARE @tc_codigo VARCHAR(20), @tc_ds_nombre VARCHAR(100), @tc_cd_tipo CHAR(1), @tc_am_porcentaje NUMERIC(8,4), @tc_am_valor MONEY, @tc_am_contado MONEY, @tc_am_credito MONEY, @tc_id_carg INT, @tc_id_imp INT;
						
						DECLARE @TaoImpuestosSqlStmt VARCHAR(MAX) = '';
												
						DECLARE curItemTaoCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');

						OPEN curItemTaoCargos;
						FETCH NEXT FROM curItemTaoCargos INTO @tc_codigo, @tc_ds_nombre, @tc_cd_tipo, @tc_am_porcentaje, @tc_am_valor, @tc_am_contado, @tc_am_credito, @tc_id_carg, @tc_id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @tc_codigotax VARCHAR(20), @tc_ds_nombretax VARCHAR(100), @tc_cd_tipotax CHAR(1), @tc_am_porcentajetax NUMERIC(8,4), @tc_am_valortax MONEY, @tc_am_contadotax MONEY, @tc_am_creditotax MONEY, @tc_id_cargtax INT, @tc_id_imptax INT;
							SET @TaoImpuestosSqlStmt='';

							DECLARE curItemTaoTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg=@tc_id_carg AND cd_tipo IN ('I','R');

							OPEN curItemTaoTaxes;
							FETCH NEXT FROM curItemTaoTaxes INTO @tc_codigotax, @tc_ds_nombretax, @tc_cd_tipotax, @tc_am_porcentajetax, @tc_am_valortax, @tc_am_contadotax, @tc_am_creditotax, @tc_id_cargtax, @tc_id_imptax;	
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @TaoImpuestosSqlStmt = @TaoImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoImpuestos_Insertar @id_FacTaoCargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@tc_id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@tc_ds_nombretax,'') + ''', @cd_impcta='''', @am_valor = ' + CAST(ISNULL(@tc_am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@tc_am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@tc_am_creditotax,0) AS VARCHAR) + ', @am_porcentaje=' + CAST(ISNULL(@tc_am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;' 
								FETCH NEXT FROM curItemTaoTaxes INTO @tc_codigotax, @tc_ds_nombretax, @tc_cd_tipotax, @tc_am_porcentajetax, @tc_am_valortax, @tc_am_contadotax, @tc_am_creditotax, @tc_id_cargtax, @tc_id_imptax;
							END
							CLOSE curItemTaoTaxes;
							DEALLOCATE curItemTaoTaxes;

							SET @TaoCargSqlStmt = @TaoCargSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoCargos_Insertar @id_fac_remision = @NewRmId, @id_fac_factura = @NewFacId, @Id_Fac_Tao = @NewTaoId, @id_cargosdesc = ' + CAST(ISNULL(@tc_id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@tc_ds_nombre,'') + ''', @am_valor = ' + CAST(ISNULL(@tc_am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@tc_am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@tc_am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@TaoImpuestosSqlStmt,''), '''', '''''') + ''';' 
							FETCH NEXT FROM curItemTaoCargos INTO @tc_codigo, @tc_ds_nombre, @tc_cd_tipo, @tc_am_porcentaje, @tc_am_valor, @tc_am_contado, @tc_am_credito, @tc_id_carg, @tc_id_imp;
						END
						CLOSE curItemTaoCargos;
						DEALLOCATE curItemTaoCargos;
						
						SET @TaoFpSqlStmt = '';
						
						DECLARE @tfp_id_fp INT, @tfp_id_tc INT, @tfp_cd_codigo VARCHAR(10), @tfp_ds_nombre VARCHAR(50), @tfp_cd_tipotarjeta VARCHAR(10), @tfp_ds_numerotarjeta VARCHAR(50), @tfp_ds_vouchertarjeta VARCHAR(50), @tfp_ds_expiraciontarjeta VARCHAR(10), @tfp_ds_autorizaciontarjeta VARCHAR(50), @tfp_in_cuotas INT, @tfp_am_valor MONEY;
						DECLARE curItemTaoFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta , ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemTaoFPs;
						FETCH NEXT FROM curItemTaoFPs INTO @tfp_id_fp, @tfp_id_tc, @tfp_cd_codigo, @tfp_ds_nombre, @tfp_cd_tipotarjeta, @tfp_ds_numerotarjeta, @tfp_ds_vouchertarjeta, @tfp_ds_expiraciontarjeta, @tfp_ds_autorizaciontarjeta, @tfp_in_cuotas, @tfp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @TaoFpSqlStmt = @TaoFpSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TaoFormasPago_Insertar @Id_Fac_Tao = @NewTaoId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_formaspago = ' + CAST(@tfp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@tfp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_tarjetascredito = ' + ISNULL(CAST(@tfp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @tfp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @tfp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @tfp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @tfp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@tfp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @tfp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@tfp_in_cuotas AS VARCHAR), '0') + ';' 
							FETCH NEXT FROM curItemTaoFPs INTO @tfp_id_fp, @tfp_id_tc, @tfp_cd_codigo, @tfp_ds_nombre, @tfp_cd_tipotarjeta, @tfp_ds_numerotarjeta, @tfp_ds_vouchertarjeta, @tfp_ds_expiraciontarjeta, @tfp_ds_autorizaciontarjeta, @tfp_in_cuotas, @tfp_am_valor;
						END
						CLOSE curItemTaoFPs;
						DEALLOCATE curItemTaoFPs;

						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) +'
						DECLARE @NewTaoId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Tao_Vender
							@cd_tiquete = ''' + ISNULL(@gen_cd_tiquete, '') + ''',
							@ds_descrip = ''' + ISNULL(@gen_ds_descrip, '') + ''',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@in_nacionalidad = ' + CAST(ISNULL(@gen_in_nacionalidad,0) AS VARCHAR) + ',
							@cd_cencosto = ''' + ISNULL(@gen_cd_cencosto, '') + ''',
							@cd_aux = ''' + ISNULL(@gen_cd_auxiliar, '') + ''',
							@cd_coditem = ''' + ISNULL(@gen_cd_item, '') + ''',
							@am_basecomisionable = ' + CAST(ISNULL(@gen_am_tarifa,0) AS VARCHAR) + ',
							@am_porcomision = 0,
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@OrdenGrabacion = ' + CAST(@ItemIndex AS VARCHAR) + ',
							@SqlStmt = ''' + REPLACE(@TaoCargSqlStmt + @TaoFpSqlStmt, '''', '''''') + '''; '

							
					END
					ELSE IF @gen_tipo_item IN ('SRV','Hotel','Auto')
					BEGIN
						-- Build cargos / impuestos / provider / pax SQL
						SET @SrvSqlStmt = '';
						SET @SrvImpuestosSqlStmt = '';
						
						DELETE FROM #TmpVariablesObtenidas;
						IF @gen_id_referencia_origen IS NOT NULL AND OBJECT_ID('dbo.spConfiguracionVariablesObtenerValores', 'P') IS NOT NULL
						BEGIN
							INSERT INTO #TmpVariablesObtenidas
							EXEC dbo.spConfiguracionVariablesObtenerValores 
								@id_usuario = 1, 
								@id_ReservaGDS_Servicios = @gen_id_referencia_origen;

							DECLARE @var_Iden_Variable_srv INT, @var_IDEN_Maestro_srv INT, @var_ValorObtenido_srv VARCHAR(MAX);
							DECLARE curVarsSrv CURSOR LOCAL FAST_FORWARD FOR
							SELECT Iden_Variable, IDEN_Maestro, ValorObtenido FROM #TmpVariablesObtenidas WHERE ISNULL(ValorObtenido, '') <> '';

							OPEN curVarsSrv;
							FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @SrvSqlStmt = @SrvSqlStmt +CHAR(13) + CHAR(10)+ ' INSERT INTO dbo.VariableDatosMaestro (Iden_Variable, IDEN_Maestro, cd_maestro, ValorObtenido) VALUES (' + CAST(@var_Iden_Variable_srv AS VARCHAR) + ', ' + CAST(@var_IDEN_Maestro_srv AS VARCHAR) + ', ''' + REPLACE(@gen_cd_Consecutivo_variablesadicionales, '''', '''''') + ''', ''' + REPLACE(@var_ValorObtenido_srv, '''', '''''') + ''');' 
								FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv;
							END;
							CLOSE curVarsSrv;
							DEALLOCATE curVarsSrv;
						END
						SET @SrvCargSqlStmt = '';
						SET @SrvFpSqlStmt = '';

						DECLARE @sc_codigo VARCHAR(20), @sc_ds_nombre VARCHAR(100), @sc_cd_tipo CHAR(1), @sc_am_porcentaje NUMERIC(8,4), @sc_am_valor MONEY, @sc_am_contado MONEY, @sc_am_credito MONEY, @sc_id_carg INT, @sc_id_imp INT;
						DECLARE @HasTarCargo BIT, @IsFirstCargo BIT;
						
						-- First Pass: accumulate service taxes (impuestos/retenciones)
						-- Second Pass: process cargos and link accumulated taxes to 'TAR' or first cargo
						DECLARE curItemSrvCargos CURSOR LOCAL FAST_FORWARD FOR
						SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
						FROM #TmpFacturaCargos
						WHERE id_item = @gen_id_item AND cd_tipo IN ('C','D');
						

						OPEN curItemSrvCargos;
						FETCH NEXT FROM curItemSrvCargos INTO @sc_codigo, @sc_ds_nombre, @sc_cd_tipo, @sc_am_porcentaje, @sc_am_valor, @sc_am_contado, @sc_am_credito, @sc_id_carg, @sc_id_imp;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @sc_codigotax VARCHAR(20), @sc_ds_nombretax VARCHAR(100), @sc_cd_tipotax CHAR(1), @sc_am_porcentajetax NUMERIC(8,4), @sc_am_valortax MONEY, @sc_am_contadotax MONEY, @sc_am_creditotax MONEY, @sc_id_cargtax INT, @sc_id_imptax INT;
							SET @SrvImpuestosSqlStmt='';
							DECLARE curItemSrvTaxes CURSOR LOCAL FAST_FORWARD FOR
							SELECT cd_codigo, ds_nombre, cd_tipo, am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp
							FROM #TmpFacturaCargos
							WHERE id_item = @gen_id_item AND id_carg=@sc_id_carg AND cd_tipo IN ('I','R');

							OPEN curItemSrvTaxes;
							FETCH NEXT FROM curItemSrvTaxes INTO @sc_codigotax, @sc_ds_nombretax, @sc_cd_tipotax, @sc_am_porcentajetax, @sc_am_valortax, @sc_am_contadotax, @sc_am_creditotax, @sc_id_cargtax, @sc_id_imptax;
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @SrvImpuestosSqlStmt = @SrvImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioImpuestos_Insertar @id_FacServiciosCargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@sc_id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@sc_ds_nombretax, '') + ''', @cd_impcta = '''', @am_valor = ' + CAST(ISNULL(@sc_am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_creditotax,0) AS VARCHAR) + ', @am_porcentaje = ' + CAST(ISNULL(@sc_am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar = 1, @am_deltaCorreccion = 0;' 
								
								FETCH NEXT FROM curItemSrvTaxes INTO @sc_codigotax, @sc_ds_nombretax, @sc_cd_tipotax, @sc_am_porcentajetax, @sc_am_valortax, @sc_am_contadotax, @sc_am_creditotax, @sc_id_cargtax, @sc_id_imptax;
							END
							CLOSE curItemSrvTaxes;
							DEALLOCATE curItemSrvTaxes;

							SET @SrvCargSqlStmt = @SrvCargSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioCargos_Insertar @id_Fac_Servicios = @NewSrvId, @id_cargosdesc = ' + CAST(ISNULL(@sc_id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@sc_ds_nombre, '') + ''', @am_valor = ' + CAST(ISNULL(@sc_am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@SrvImpuestosSqlStmt,''), '''', '''''') + ''';' 
							
							FETCH NEXT FROM curItemSrvCargos INTO @sc_codigo, @sc_ds_nombre, @sc_cd_tipo, @sc_am_porcentaje, @sc_am_valor, @sc_am_contado, @sc_am_credito, @sc_id_carg, @sc_id_imp;
						END
						CLOSE curItemSrvCargos;
						DEALLOCATE curItemSrvCargos;
						 
						-- Build Formas de Pago SQL
						DECLARE @sfp_id_fp INT, @sfp_id_tc INT, @sfp_cd_codigo VARCHAR(10), @sfp_ds_nombre VARCHAR(50), @sfp_cd_tipotarjeta VARCHAR(10), @sfp_ds_numerotarjeta VARCHAR(50), @sfp_ds_vouchertarjeta VARCHAR(50), @sfp_ds_expiraciontarjeta VARCHAR(10), @sfp_ds_autorizaciontarjeta VARCHAR(50), @sfp_in_cuotas INT, @sfp_am_valor MONEY;
						DECLARE curItemSrvFPs CURSOR LOCAL FAST_FORWARD FOR
						SELECT id_formaspago, id_tarjetascredito, cd_codigo, ds_nombre, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta, ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, am_valor
						FROM #TmpFacturaFormasPago
						WHERE id_item = @gen_id_item;

						OPEN curItemSrvFPs;
						FETCH NEXT FROM curItemSrvFPs INTO @sfp_id_fp, @sfp_id_tc, @sfp_cd_codigo, @sfp_ds_nombre, @sfp_cd_tipotarjeta, @sfp_ds_numerotarjeta, @sfp_ds_vouchertarjeta, @sfp_ds_expiraciontarjeta, @sfp_ds_autorizaciontarjeta, @sfp_in_cuotas, @sfp_am_valor;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @SrvFpSqlStmt = @SrvFpSqlStmt + CHAR(13) + CHAR(10) +' EXECUTE dbo.spza_ServicioFormasPago_Insertar @id_Fac_Servicios = @NewSrvId, @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_formaspago = ' + CAST(@sfp_id_fp AS VARCHAR) + ',@ds_fpnm =' + ISNULL('''' + @sfp_ds_nombre + '''', 'NULL') + ', @am_valor = ' + CAST(@sfp_am_valor AS VARCHAR) + ',@bl_fprepresenta=0 , @id_tarjetascredito = ' + ISNULL(CAST(@sfp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' +@sfp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @sfp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @sfp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @sfp_ds_expiraciontarjeta + '''', 'NULL') + ', @ds_tcautorizacion = ' + ISNULL('''' + @sfp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@sfp_in_cuotas AS VARCHAR),'0') + ', @cd_idbanco=NULL, @ds_cheque=NULL,@ds_plaza=NULL,@ds_referencia=NULL, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio;' 
							FETCH NEXT FROM curItemSrvFPs INTO @sfp_id_fp, @sfp_id_tc, @sfp_cd_codigo, @sfp_ds_nombre, @sfp_cd_tipotarjeta, @sfp_ds_numerotarjeta, @sfp_ds_vouchertarjeta, @sfp_ds_expiraciontarjeta, @sfp_ds_autorizaciontarjeta, @sfp_in_cuotas, @sfp_am_valor;
						END
						CLOSE curItemSrvFPs;
						DEALLOCATE curItemSrvFPs;

						-- Build provider SQL
						SET @SrvProvSqlStmt = '';
						DECLARE @c_id_tipoproveedor INT, @c_cd_tipoproveedor VARCHAR(10), @c_ds_tipoproveedor VARCHAR(100);
						IF ISNULL(@gen_cd_proveedores, '') <> ''
						BEGIN
							SELECT TOP 1 
								@c_id_tipoproveedor = tp.id, 
								@c_cd_tipoproveedor = tp.cd_codigo, 
								@c_ds_tipoproveedor = tp.ds_nombre 
							FROM dbo.TipoProveedores tp WITH(NOLOCK) 
							WHERE tp.cd_codigo = ISNULL(@gen_cd_tipoproveedor,'HTL');

							SELECT @c_cd_proveedores = IDPROVE
								   ,@c_ds_proveedores = RAZONCIAL
							FROM dbo.PROVEEDORES 
							WHERE IDPROVE = @gen_cd_proveedores;
							
							IF @c_id_tipoproveedor IS NOT NULL
							BEGIN
								SET @SrvProvSqlStmt = CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioTipoProv_Insertar @id_Fac_Servicios = @NewSrvId, @id_tipoproveedores = ' + CAST(@c_id_tipoproveedor AS VARCHAR) + ', @cd_TipoProveedores = ''' + ISNULL(@c_cd_tipoproveedor,'') + ''', @ds_TipoProveedores = ''' + ISNULL(@c_ds_tipoproveedor,'')+ ''', @cd_proveedores = ''' + ISNULL(@c_cd_proveedores,'')+''', @ds_proveedores = ''' + ISNULL(@c_ds_proveedores,'')+ ''';'
							END;
						END;

						SELECT @gen_ds_tiposservicio = ds_nombre FROM dbo.TiposServicios WHERE id = @gen_id_tiposservicio

						-- Build pax SQL
						SET @SrvPaxSqlStmt = '';
						IF ISNULL(@gen_ds_paxname, '') <> ''
						BEGIN
							SET @SrvPaxSqlStmt = CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioPaxAdicional_insertar @FacId = @NewFacId, @RemId = @NewRemId, @id_Fac_Servicios = @NewSrvId, @ds_paxname = ''' + REPLACE(@gen_ds_paxname, '''', '''''') + ''', @ds_paxape = ''' + REPLACE(@gen_ds_paxape, '''', '''''') + ''', @in_edad = NULL, @ds_paxprefix= ''' + @gen_ds_paxprefix + ''', @ds_paxClasificacion = NULL, @cd_voucherpax=NULL, @cd_tiquete=NULL;'
						END;

						SET @SrvSqlStmt = @SrvCargSqlStmt + @SrvFpSqlStmt + @SrvProvSqlStmt;
						
						SET @SqlStmt = @SqlStmt + CHAR(13) + CHAR(10) + '
						DECLARE @NewSrvId_' + CAST(@ItemIndex AS VARCHAR) + ' INT;
						EXECUTE dbo.spza_Servicio_Vender
							@ds_descrip = ''' + ISNULL(@gen_ds_descrip, '') + ''',
							@id_fac_factura = @NewFacId,
							@id_fac_remision = @NewRmId,
							@id_CotizacionServicios = NULL,
							@in_nacionalidad = ' + CAST(ISNULL(@gen_in_nacionalidad,1) AS VARCHAR) + ',
							@cd_cencosto = ' + CASE WHEN ISNULL(@gen_cd_cencosto, '')='' THEN 'NULL' ELSE '' + ISNULL(@gen_cd_cencosto, '') + '' END + ',
							@cd_auxiliar = ''' + ISNULL(@gen_cd_auxiliar, '') + ''',
							@cd_item = ''' + ISNULL(@gen_cd_item, '') + ''',
							@id_tiposconceptfac = ' + ISNULL(CAST(@gen_id_tiposconceptfac AS VARCHAR), 'NULL') + ',
							@id_conceptofacturacion = ' + ISNULL(CAST(@gen_id_conceptofacturacion AS VARCHAR), 'NULL') + ',
							@id_tiposservicio = ' + ISNULL(CAST(@gen_id_tiposservicio AS VARCHAR), 'NULL') + ',
							@cd_tiquete = ' + ISNULL('''' + @gen_cd_tiquete + '''', 'NULL') + ',
							@id_voucherstocks = NULL,
							@cd_voucherPrefijo = NULL,
							@cd_proveedores = ''' + ISNULL(@gen_cd_proveedores, '') + ''',
							@ds_tiposervnm = ''' + ISNULL(@gen_ds_tiposservicio, '') + ''',
							@cd_prov_hotel = NULL,
							@cd_prov_car = NULL,
							@cd_prov_air = NULL,
							@ds_servicio = ''' + ISNULL(@gen_ds_servicio, '') + ''',
							@am_valorprov = ' + CAST(ISNULL(@gen_am_tarifa,0) AS VARCHAR) + ',
							@id_monedaprov = ' + ISNULL(CAST(@id_monedas_iata AS VARCHAR), 'NULL') + ',
							@ds_InfoAdicional = NULL,
							@ds_paxname = ''' + ISNULL(@gen_ds_paxname, '') + ''',
							@ds_paxape = ''' + ISNULL(@gen_ds_paxape, '') + ''',
							@cd_paxtype = ''' + ISNULL(@gen_ds_paxprefix, '') + ''',
							@in_edad = NULL,
							@cd_voucher = NULL,
							@in_cantpax = 1,
							@dt_llegada = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@dt_salida = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@ds_destino = ''' + ISNULL(@gen_cd_destino, '') + ''',
							@id_gds = '+ CAST(ISNULL(@gen_id_gds,1) AS VARCHAR) + ',
							@am_basecomisionable = ' + CAST(ISNULL(@gen_am_basecomisionable,0) AS VARCHAR) + ',
							@am_porcomision = 0,
							@id_tipoplan = NULL,
							@id_acomodacion = NULL,
							@ds_paxClasificacion = NULL,
							@in_dias = NULL,
							@in_noches = NULL,
							@bl_notdomicilionacional=0,
							@CodigoReserva =''' + ISNULL(@gen_ds_records,'') + ''',
							@AnticiposSqlStmt = NULL,
							@PaxAdicionalSqlStmt = ''' + REPLACE(ISNULL(@SrvPaxSqlStmt,''), '''', '''''') + ''', 
							@VoucherAdicionalSqlStmt = NULL,
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@Id_GrConcepto = NULL,
							@in_diasSrv = NULL,
							@in_nochesSrv = NULL,
							@OrdenGrabacion = ' + CAST(@ItemIndex AS VARCHAR) + ',
							@Id_Especialista = NULL,
							@am_porcentaje_descuento = ' + CAST(ISNULL(@gen_am_pordescuento, 0) AS VARCHAR) + ',
							@am_valor_descuento = 0,
							@ds_motivo_descuento = NULL,
							@Id_CargosDesc_Descuento = NULL,
							@dt_FechaSalidaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Salida, 120) + '''', 'NULL') + ',
							@dt_FechaLlegadaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, @gen_Fecha_Llegada, 120) + '''', 'NULL') + ',
							@cd_localizador = NULL,
							@cd_VoucherPax = NULL,
							@am_basecomisionableprov = ' + CAST(ISNULL(@gen_am_basecomisionable,0) AS VARCHAR) + ',
							@am_porcomisionprov = 0,
							@cd_NumeFac = NULL,
							@dt_VenceFac = NULL,
							@Id_AcomodacionSrv = NULL,
							@Id_TipoPlanSrv = NULL,
							@in_habitaciones = NULL,
							@in_habitacionesSrv = NULL,
							@SqlStmt = ''' + REPLACE(@SrvSqlStmt, '''', '''''') + ''',
							@cd_Consecutivo_variablesadicionales = ' + ISNULL('''' + @gen_cd_Consecutivo_variablesadicionales + '''', 'NULL') + ',
							@cd_confirmacion = NULL,
							@ds_confirmadopor = NULL,
							@cd_paxidentificacion = NULL,
							@bl_politicaCancelacion = 0,
							@dt_politicaCancelacion = NULL,
							@id_tipoHabitacion = NULL,
							@cd_Consecutivo_depende = ' + ISNULL('''' + @gen_cd_Consecutivo_depende + '''', 'NULL') + ',
							@id_TarjetaAsistencia = NULL,
							@id_Regiones = NULL,
							@Iden_GDS = NULL,
							@id_sys_entidades = 108,
							@ds_TipoAuto = NULL,
							@ds_Origen = NULL,
							@ds_DirOrigen = NULL,
							@ds_DirDestino = NULL,
							@ds_TipoTarifa = NULL,
							@am_ValorUSD = NULL,
							@ds_NoVuelo = NULL,
							@ds_Vehiculo = NULL,
							@ds_Placa = NULL,
							@ds_CategoriaVehiculo = NULL,
							@ds_NombreConductor = NULL,
							@ds_telefono = NULL,
							@ds_IdiomaConductor = NULL,
							@id_MonedaSrv = ' + ISNULL(CAST(@gen_id_monedaprov AS VARCHAR), 'NULL') + ',
							@id_TipoServicio = NULL,
							@id_Aerolinea = NULL,
							@am_PorFacParcial = 100,
							@ds_GDS = NULL,
							@am_basedescuento = ' + CAST(ISNULL(@gen_am_basedescuento, 0) AS VARCHAR) + ',
							@am_pordescuento = ' + CAST(ISNULL(@gen_am_pordescuento, 0) AS VARCHAR) + '; '

					END;
					SET @ItemIndex = @ItemIndex + 1;
					FETCH NEXT FROM curGenItems INTO 
						@gen_id_item, @gen_tipo_item, @gen_cd_tiquete, @gen_ds_descrip, @gen_in_nacionalidad, @gen_cd_cencosto, @gen_cd_auxiliar, @gen_cd_item, @gen_am_tarifa, @gen_am_iva, @gen_am_tua, @gen_am_comb, @gen_am_vat, @gen_am_Comision,
						@gen_ds_paxname, @gen_ds_paxape, @gen_ds_paxprefix, @gen_cd_tourcode, @gen_NumTktConj, @gen_cd_TipoTiquete, @gen_id_air, @gen_ds_itinerario, @gen_ds_itinerarioaerolinea, @gen_ds_clases, @gen_ds_Observaciones,
						@gen_am_highfare, @gen_am_lowfare, @gen_ds_solicita, @gen_ds_lapsoviaje, @gen_cd_tktrevisado, @gen_cd_PasaportePax, @gen_cd_pax_CC, @gen_am_PorFacParcial, @gen_in_cantpax, @gen_Id_Precompra,
						@gen_id_FormasPago, @gen_id_TarjetasCredito, @gen_id_sucursal, @gen_id_implante, @gen_bl_ahorro, @gen_cd_TipoTiqueteGDS, @gen_id_TiposDocumento, @gen_id_entdist, @gen_id_entvend,
						@gen_cd_destino, @gen_dt_fechaexped, @gen_id_tiqueteadores, @gen_id_gds, @gen_iden_gds, @gen_am_comisionPNR, @gen_ds_records, @gen_bl_NoCalcComision, @gen_bl_NoCalcIvaComision,
						@gen_am_basecomisionable, @gen_am_porcomision, @gen_id_tiposconceptfac, @gen_id_conceptofacturacion, @gen_id_tiposservicio, @gen_cd_proveedores, @gen_ds_servicio,
						@gen_am_valorprov, @gen_id_monedaprov, @gen_dt_llegada, @gen_dt_salida, @gen_am_pordescuento, @gen_Fecha_Salida, @gen_Fecha_Llegada, @gen_am_basedescuento, @gen_cd_Consecutivo_depende, @gen_cd_Consecutivo_variablesadicionales, @gen_id_referencia_origen, @gen_id_tipoproveedor, @gen_cd_tipoproveedor, @gen_ds_tipoproveedor;
				END;
				CLOSE curGenItems;
				DEALLOCATE curGenItems;
				
				-- Execute spza_Factura_Crear inside a TRY CATCH
				SET @FacturaRespuesta = NULL;
				SET @FacturaEstado = NULL;

				BEGIN TRY
					DECLARE @ReturnCode INT;
					DECLARE @FacturaExecSqlStmt NVARCHAR(MAX);

					DECLARE @ZML_VariablesStr VARCHAR(MAX) = NULL;
					SELECT 
						@ZML_VariablesStr = COALESCE(@ZML_VariablesStr + ' UNION ALL ', '') + 
						'SELECT ' + ISNULL('''' + REPLACE(cd_codigo, '''', '''''') + '''', 'NULL') + ' AS cd_items, NULL AS ds_Items, ' + 
						ISNULL('''' + REPLACE(ds_maestro, '''', '''''') + '''', 'NULL') + ' AS ds_Maestro, ' + 
						ISNULL('''' + REPLACE(ds_VariableAdicional, '''', '''''') + '''', 'NULL') + ' AS ds_Variable, ' + 
						ISNULL('''' + REPLACE(ds_valor, '''', '''''') + '''', 'NULL') + ' AS ds_Valor, ' +
						ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ' AS id_Clientes'
					FROM #VariablesAdicionales
					WHERE id_facturacion = @id_facturacion;

					SET @FacturaExecSqlStmt = N'
						EXEC @ReturnCode = ZeusAgencias_23.dbo.spza_Factura_Crear' + CHAR(13) + CHAR(10) +
							'@id_usuario = 1,' + CHAR(13) + CHAR(10) +
							'@id_sucursal = ' + ISNULL(CAST(@id_sucursal AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_implante = ' + ISNULL(CAST(@id_implante AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@dt_fechacont = ' + ISNULL('''' + CONVERT(VARCHAR, @FechaCont, 120) + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@dt_vence = ' + ISNULL('''' + CONVERT(VARCHAR, @FechaCont, 120) + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_tercero_codigo = ' + ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_tercero_nombre = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_cliente_codigo = ' + ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_nombre = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_dir = ' + ISNULL('''' + REPLACE(@ds_clidir, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_ciudad = ' + ISNULL('''' + REPLACE(@ds_clicity, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_tel = ' + ISNULL('''' + REPLACE(@ds_clitel, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_dirdesp = ' + ISNULL('''' + REPLACE(@ds_clidir, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_email = ' + ISNULL('''' + REPLACE(@ds_ClienteEmail, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_contacto = ' + ISNULL('''' + REPLACE(@ds_cliname, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_cliente_contacto_email = ' + ISNULL('''' + REPLACE(@ds_ClienteEmail, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_monedas_iata = ' + ISNULL(CAST(@id_monedas_iata AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@cd_vendedor = ' + ISNULL('''' + REPLACE(@cd_vendedor, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_tiqueteador = ' + ISNULL(CAST(@id_tiqueteador AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@bn_anexo = NULL,' + CHAR(13) + CHAR(10) +
							'@Tcambio = ' + ISNULL(CAST(@am_TasaCambio AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@am_tcambiousd = ' + ISNULL(CAST(@am_tcambiousd AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_tipoventa = ' + ISNULL(CAST(@id_tipoventa AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_num_resolucion = '''',' + CHAR(13) + CHAR(10) +
							'@in_num_inicial = 0,' + CHAR(13) + CHAR(10) +
							'@in_num_final = 0,' + CHAR(13) + CHAR(10) +
							'@ds_numeracion_autorizada = NULL,' + CHAR(13) + CHAR(10) +
							'@dt_fecha_resolucion = NULL,' + CHAR(13) + CHAR(10) +
							'@CodigoArchivoFisico = '''',' + CHAR(13) + CHAR(10) +
							'@ds_Observacion = ' + ISNULL('''' + REPLACE(@ds_Observaciones, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ds_Campo_libre1 = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Campo_libre2 = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_fuente_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_serie_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_consecutivo_Reemplaza = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Actividad_Economica = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_Tarifa_ICA = NULL,' + CHAR(13) + CHAR(10) +
							'@SqlStmt = ' + ISNULL('''' + REPLACE(@SqlStmt, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@AnticiposSqlStmt = NULL,' + CHAR(13) + CHAR(10) +
							'@TotalFactura = ' + ISNULL(CAST(@ValorFactura AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@TotalCupoCreditoCliente = 0,' + CHAR(13) + CHAR(10) +
							'@bl_BloqueoCupoCredito = 0,' + CHAR(13) + CHAR(10) +
							'@bl_generadaauto = 1,' + CHAR(13) + CHAR(10) +
							'@ds_CotizacionesId = NULL,' + CHAR(13) + CHAR(10) +
							'@Id_Cierre = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_TipoFact = NULL,' + CHAR(13) + CHAR(10) +
							'@id_fac_remisionRelacionada = NULL,' + CHAR(13) + CHAR(10) +
							'@id_fac_facturaRelacionada = NULL,' + CHAR(13) + CHAR(10) +
							'@ds_DescripcionFac = ' + ISNULL('''' + REPLACE(@ds_descripcion, '''', '''''') + '''', 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@bl_nocont = 0,' + CHAR(13) + CHAR(10) +
							'@ProductosSqlStmt = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_CF_TipoComprobante = NULL,' + CHAR(13) + CHAR(10) +
							'@id_Licitacion = ' + ISNULL(CAST(@cd_licitacion AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@ValorFactura = ' + ISNULL(CAST(@ValorFactura AS VARCHAR), 'NULL') + ',' + CHAR(13) + CHAR(10) +
							'@id_Especialista = NULL,' + CHAR(13) + CHAR(10) +
							'@id_tiqueteador_Facturador = NULL,' + CHAR(13) + CHAR(10) +
							'@id_TipoFormaPagoProveedor = NULL,' + CHAR(13) + CHAR(10) +
							'@id_MedioReservacion = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_refacturacion = 0,' + CHAR(13) + CHAR(10) +
							'@bl_comisiona = 0,' + CHAR(13) + CHAR(10) +
							'@cd_fuente_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_serie_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@cd_consecutivo_factura = NULL,' + CHAR(13) + CHAR(10) +
							'@id_NotasAerolinea = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_interface = 0,' + CHAR(13) + CHAR(10) +
							'@id_evento = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_NoEnviarFacElectronica = 0,' + CHAR(13) + CHAR(10) +
							'@bl_DescontarComisionCxP = 0,' + CHAR(13) + CHAR(10) +
							'@ds_num_resolucion_Adicional = '''',' + CHAR(13) + CHAR(10) +
							'@id_fac_facturaRefacturacion = NULL,' + CHAR(13) + CHAR(10) +
							'@bl_refacturacion_contabilizar_saldos = 0,' + CHAR(13) + CHAR(10) +
							'@ZML_VariablesXML = @ZML_VariablesXML,' + CHAR(13) + CHAR(10) +
							'@bl_FormatoResumidoFactElectro = 0,' + CHAR(13) + CHAR(10) +
							'@bl_ExigeAdjuntoFactElectro = 0,' + CHAR(13) + CHAR(10) +
							'@bl_omitir_Validar_IVA_facturacion = 0,' + CHAR(13) + CHAR(10) +
							'@ZML_AjusteIvaXML = NULL;';
					
					EXEC sp_executesql @FacturaExecSqlStmt, 
						N'@ZML_VariablesXML VARCHAR(MAX), @FacturaRespuesta VARCHAR(8000) OUTPUT, @ReturnCode INT OUTPUT', 
						@ZML_VariablesXML = @ZML_VariablesStr,
						@FacturaRespuesta = @FacturaRespuesta OUTPUT, 
						@ReturnCode = @ReturnCode OUTPUT;
					
					IF @ReturnCode = 0
					BEGIN
						SET @FacturaEstado = 0;
					END
					ELSE
					BEGIN
						SET @FacturaEstado = 1;
						IF @FacturaRespuesta IS NULL OR LTRIM(RTRIM(@FacturaRespuesta)) = ''
						BEGIN
							SET @FacturaRespuesta = 'Error en spFacturaCrear (Código de retorno: ' + CAST(ISNULL(@ReturnCode, 1) AS VARCHAR) + ')';
						END;
						SET @FacturaRespuesta = @FacturaRespuesta + CHAR(13) + CHAR(10) + '--- DYNAMIC EXECUTION TRACE ---' + CHAR(13) + CHAR(10) + ISNULL(@FacturaExecSqlStmt, '');
					END
				END TRY
				BEGIN CATCH
					SET @FacturaEstado = 1;
					DECLARE @ErrNum INT = ERROR_NUMBER();
					DECLARE @ErrLine INT = ERROR_LINE();
					DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
					DECLARE @ErrProc NVARCHAR(128) = ERROR_PROCEDURE();
					SET @FacturaRespuesta = '❌ Error ' + CAST(@ErrNum AS VARCHAR) + ' (Línea ' + CAST(@ErrLine AS VARCHAR) + ' en ' + ISNULL(@ErrProc, 'spFacturaCrear') + '): ' + ISNULL(@ErrMsg, 'Error no especificado') + CHAR(13) + CHAR(10) + '--- DYNAMIC EXECUTION TRACE ---' + CHAR(13) + CHAR(10) + ISNULL(@FacturaExecSqlStmt, '');
				END CATCH
				-- Collect log result
				INSERT INTO @LogResults (invoiceId, success, message)
				VALUES (@id_facturacion, CASE WHEN @FacturaEstado = 0 THEN 1 ELSE 0 END, @FacturaRespuesta);

				FETCH NEXT FROM curInvoices INTO @cd_fuente,@cd_serie,@cd_consecutivo,@id_facturacion;
			END;

			CLOSE curInvoices;
			DEALLOCATE curInvoices;
			
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
			
			SELECT invoiceId, success, message FROM @LogResults;
			RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT,
            @ErrorLine INT,
            @ErrorNumber INT,
            @ErrorProc NVARCHAR(128);

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorLine = ERROR_LINE(),
            @ErrorNumber = ERROR_NUMBER(),
            @ErrorProc = ERROR_PROCEDURE();

        DECLARE @FullErrorMsg NVARCHAR(4000) = '❌ Error ' + CAST(ISNULL(@ErrorNumber,0) AS NVARCHAR) + ' (Línea ' + CAST(ISNULL(@ErrorLine,0) AS NVARCHAR) + ' de ' + ISNULL(@ErrorProc, 'spFacturacionesCrear') + '): ' + ISNULL(@ErrorMessage, 'Error no especificado');

        RAISERROR (@FullErrorMsg, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

GO


IF OBJECT_ID('dbo.spExportInvoices', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spExportInvoices;
GO

CREATE PROCEDURE dbo.spExportInvoices
(
    @Envoices_id VARCHAR(MAX),
    @User_id INT = 0,
    @mensaje_resultado VARCHAR(MAX) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_xml VARCHAR(MAX) = '';
    DECLARE @v_nombre_usuario VARCHAR(250) = '';

    SET @Envoices_id = LTRIM(RTRIM(ISNULL(@Envoices_id, '')));
    IF @Envoices_id = ''
    BEGIN
        SET @mensaje_resultado = 'ERROR: No se han proporcionado IDs de Facturacion válidos.';
        SELECT @mensaje_resultado AS mensaje_resultado;
        RETURN;
    END

    DECLARE @idsTable TABLE (id INT);
    INSERT INTO @idsTable (id)
    SELECT CAST(value AS INT) 
    FROM STRING_SPLIT(@Envoices_id, ',')
    WHERE LTRIM(RTRIM(value)) <> '' AND ISNUMERIC(value) = 1;

    -- 1. PRE-VALIDACIÓN RIGUROSA EN KOREX: Conceptos de Facturación y Clasificación de Servicio
    DECLARE @v_err_concept VARCHAR(MAX) = '';

    SELECT TOP 1 @v_err_concept = 'ERROR: La factura ' + COALESCE(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
        ' contiene el producto ''' + COALESCE(ep.descripcion, pr.description, 'SIN NOMBRE') + 
        ''' que no tiene asignado un Concepto de Facturación en Korex. Por favor asígnelo en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND COALESCE(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), '') = '';

    IF @v_err_concept <> ''
    BEGIN
        SET @mensaje_resultado = @v_err_concept;
        SELECT @mensaje_resultado AS mensaje_resultado;
        RETURN;
    END

    SELECT TOP 1 @v_err_concept = 'ERROR: La factura ' + COALESCE(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
        ' contiene el producto ''' + COALESCE(ep.descripcion, pr.description, 'SIN NOMBRE') + 
        ''' que no tiene asignada una Clasificación de Servicio en Korex. Por favor asígnela en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND COALESCE(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), '') = '';

    IF @v_err_concept <> ''
    BEGIN
        SET @mensaje_resultado = @v_err_concept;
        SELECT @mensaje_resultado AS mensaje_resultado;
        RETURN;
    END

    SELECT @v_nombre_usuario = name FROM dbo.[User] WHERE id = @User_id;
    IF @v_nombre_usuario IS NULL OR @v_nombre_usuario = ''
    BEGIN
        SET @v_nombre_usuario = 'ADMINISTRADOR';
    END

    -- 2. GENERACIÓN DE ESTRUCTURA COMPLETA XML PARA ZEUS ERP
    DECLARE @xmlResult XML;

    SET @xmlResult = (
        SELECT 
            e.id AS [id_factura],
            SUBSTRING(ISNULL(e.fuente, '55'), 1, 2) AS [cd_fuente],
            SUBSTRING(ISNULL(e.serie, '00'), 1, 2) AS [cd_serie],
            SUBSTRING(ISNULL(e.consecutivo, RIGHT('00000000' + CAST(e.id AS VARCHAR(8)), 8)), 1, 8) AS [cd_consecutivo],
            @User_id AS [cd_usuario],
            SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
            SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechacont],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_vence],
            SUBSTRING(ISNULL(c.document, ''), 1, 25) AS [cd_tercero_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 250) AS [ds_tercero_nombre],
            SUBSTRING(ISNULL(c.document, ''), 1, 25) AS [cd_cliente_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 250) AS [ds_cliente_nombre],
            SUBSTRING(ISNULL(c.address, ''), 1, 250) AS [ds_cliente_dir],
            '' AS [ds_cliente_ciudad],
            '' AS [ds_cliente_tel],
            '' AS [ds_cliente_dirdesp],
            SUBSTRING(ISNULL(u.email, ''), 1, 60) AS [ds_cliente_email],
            '' AS [ds_cliente_contacto],
            '' AS [ds_cliente_contacto_email],
            ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
            SUBSTRING(ISNULL(s.code, '01'), 1, 3) AS [cd_vendedor],
            SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteador],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
            CAST(1.0 AS DECIMAL(18,4)) AS [am_tcambiousd],
            1 AS [id_tipoventa],
            '' AS [ds_Observacion],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [TotalFactura],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [ValorFactura],
            (
                SELECT 
                    ep.invoiceId AS [id_factura],
                    ep.id AS [id_item],
                    CASE 
                        WHEN pr.type = 'Tiquete' THEN 'Aire' 
                        WHEN pr.type = 'ALOJAMIENTO' THEN 'Hotel' 
                        WHEN pr.type = 'ALQUILER' THEN 'Auto'
                        WHEN pr.type = 'TAO' THEN 'TAO'
                        ELSE 'SRV'
                    END AS [tipo_item],
                    CASE 
                        WHEN pr.type = 'Tiquete' THEN 1 
                        WHEN pr.type = 'ALOJAMIENTO' THEN 3
                        WHEN pr.type = 'ALQUILER' THEN 3
                        WHEN pr.type = 'TAO' THEN 2
                        ELSE 3
                    END AS [in_tipoitem],
                    ep.id AS [id_referencia_origen],
                    CASE WHEN pr.type = 'Tiquete' THEN ISNULL(pr.code, '') ELSE '' END AS [cd_tiquete],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 500) AS [ds_descrip],
                    ISNULL(ep.inNationality, 1) AS [in_nacionalidad],
                    '' AS [cd_cencosto],
                    '' AS [cd_auxiliar],
                    '' AS [cd_item],
                    CAST(ISNULL(ep.price, 0) AS DECIMAL(18,2)) AS [am_tarifa],
                    CAST(0 AS DECIMAL(18,2)) AS [am_iva],
                    CAST(0 AS DECIMAL(18,2)) AS [am_tua],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comb],
                    CAST(0 AS DECIMAL(18,2)) AS [am_vat],
                    CAST(ISNULL(ep.sellerCommission, 0) AS DECIMAL(18,2)) AS [am_Comision],
                    SUBSTRING(ISNULL((SELECT TOP 1 pp.name FROM dbo.[InvoicesProductPasenger] pp WHERE pp.invoiceProductId = ep.id), c.name), 1, 30) AS [ds_paxname],
                    '' AS [ds_paxape],
                    'SR' AS [ds_paxprefix],
                    '' AS [cd_tourcode],
                    0 AS [NumTktConj],
                    'ACT' AS [cd_TipoTiquete],
                    1 AS [id_air],
                    ISNULL(ep.itinerary, '') AS [ds_itinerario],
                    '' AS [ds_itinerarioaerolinea],
                    ISNULL(ep.class, 'Y') AS [ds_clases],
                    '' AS [ds_Observaciones],
                    CAST(0 AS DECIMAL(18,2)) AS [am_highfare],
                    CAST(0 AS DECIMAL(18,2)) AS [am_lowfare],
                    '' AS [ds_solicita],
                    '' AS [ds_lapsoviaje],
                    '' AS [cd_tktrevisado],
                    '' AS [cd_PasaportePax],
                    '' AS [cd_pax_CC],
                    CAST(100 AS DECIMAL(18,2)) AS [am_PorFacParcial],
                    ISNULL(ep.quantity, 1) AS [in_cantpax],
                    NULL AS [Id_Precompra],
                    '' AS [cd_FormaPagoTAO],
                    '' AS [cd_TarjetaCreditoTAO],
                    '' AS [cd_NumeroTarjetaTAO],
                    '' AS [cd_VencimientoTarjetaTAO],
                    '' AS [cd_NumeroPolizaTAO],
                    '' AS [cd_AnexoPolizaTAO],
                    '' AS [ds_AutorizacionTarjetaTAO],
                    0 AS [in_cuotasTarjetaTAO],
                    ISNULL((SELECT TOP 1 p.code FROM dbo.[InvoicesProductPayment] ipp LEFT JOIN dbo.[Payment] p ON LOWER(p.name) = LOWER(ipp.paymentMethod) WHERE ipp.invoiceProductId = ep.id), 'CRE') AS [cd_FormasPago],
                    '' AS [cd_TarjetasCredito],
                    CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2)) AS [am_fp1],
                    '' AS [ds_cc_code],
                    '' AS [ds_cc_number],
                    '' AS [ds_cc_vence],
                    '' AS [ds_cc_autorizacion],
                    '' AS [ds_cc_voucher],
                    0 AS [in_cc_cuotas],
                    CAST(0 AS DECIMAL(18,2)) AS [am_fp2],
                    '' AS [ds_cc_code2],
                    '' AS [ds_cc_number2],
                    '' AS [ds_cc_vence2],
                    '' AS [ds_cc_autorizacion2],
                    '' AS [ds_cc_voucher2],
                    0 AS [in_cc_cuotas2],
                    ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
                    CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
                    SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
                    SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
                    0 AS [bl_ahorro],
                    'ACT' AS [cd_TipoTiqueteGDS],
                    '' AS [cd_TiposDocumento],
                    '' AS [cd_entdist],
                    '' AS [cd_entvend],
                    'BOG' AS [cd_destino],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechaexped],
                    SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteadores],
                    1 AS [id_gds],
                    1 AS [iden_gds],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comisionPNR],
                    '' AS [ds_records],
                    0 AS [bl_NoCalcComision],
                    0 AS [bl_NoCalcIvaComision],
                    CAST(ISNULL(ep.price, 0) AS DECIMAL(18,2)) AS [am_basecomisionable],
                    CAST(0 AS DECIMAL(18,2)) AS [am_porcomision],
                    '2' AS [cd_tiposconceptfac],
                    LTRIM(RTRIM(pr.billingConcept)) AS [cd_conceptofacturacion],
                    COALESCE(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), NULLIF(LTRIM(RTRIM(pr.serviceType)), '')) AS [cd_tiposservicio],
                    SUBSTRING(ISNULL(prv.code, '01'), 1, 25) AS [cd_proveedores],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 250) AS [ds_servicio],
                    CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2)) AS [am_valorprov],
                    ISNULL(e.currency, 'COP') AS [cd_monedaprov],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_llegada],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_salida],
                    CAST(0 AS DECIMAL(18,2)) AS [am_pordescuento],
                    CAST(0 AS DECIMAL(18,2)) AS [am_basedescuento],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [Fecha_Salida],
                    CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [Fecha_Llegada],
                    '1' AS [id_tipoproveedor],
                    '1' AS [cd_tipoproveedor],
                    'GENERAL' AS [ds_tipoproveedor],
                    -- Sub-nodo: Pasajeros (Garantiza al menos 1 pasajero registrado)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            SUBSTRING(ISNULL(pp.name, c.name), 1, 50) AS [ds_paxname],
                            '' AS [ds_paxape],
                            'SR' AS [ds_paxprefix],
                            '' AS [ds_paxclasificacion],
                            '' AS [cd_voucherpax],
                            SUBSTRING(ISNULL(pp.document, c.document), 1, 50) AS [cd_paxidentificacion],
                            0 AS [in_edad],
                            '' AS [cd_tiquete]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPasenger] pp ON pp.invoiceProductId = ep.id
                        FOR XML PATH('Pasajeros'), TYPE
                    ),
                    -- Sub-nodo: Formaspago (Garantiza al menos CRE / CREDITO)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(p.code, 'CRE') AS [cd_codigo],
                            ISNULL(ipp.paymentMethod, 'CREDITO') AS [ds_nombre],
                            CAST(ISNULL(ipp.amount, ep.price * ep.quantity) AS DECIMAL(18,2)) AS [am_valor]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPayment] ipp ON ipp.invoiceProductId = ep.id
                        LEFT JOIN dbo.[Payment] p ON LOWER(p.name) = LOWER(ipp.paymentMethod)
                        FOR XML PATH('Formaspago'), TYPE
                    ),
                    -- Sub-nodo: CargosImpuestos (Garantiza tarifa e impuestos)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(ct.code, 'TAR') AS [cd_codigo],
                            ISNULL(ct.name, 'Tarifa') AS [ds_nombre],
                            CASE WHEN ipt.isMain = 1 THEN 'C' ELSE 'I' END AS [cd_tipo],
                            CAST(ISNULL(ct.value, 0) AS DECIMAL(18,4)) AS [am_porcentaje],
                            CAST(ISNULL(ipt.explicitAmount, ep.price * ep.quantity) AS DECIMAL(18,2)) AS [am_valor],
                            CAST(0 AS DECIMAL(18,2)) AS [am_contado],
                            CAST(ISNULL(ipt.explicitAmount, ep.price * ep.quantity) AS DECIMAL(18,2)) AS [am_credito],
                            ISNULL(ct.id, 1) AS [id_carg],
                            ISNULL(ct.id, 1) AS [id_imp],
                            CASE WHEN ct.code = 'IVA' THEN 1 ELSE 0 END AS [bl_iva],
                            1 AS [in_orden]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductTax] ipt ON ipt.invoiceProductId = ep.id
                        LEFT JOIN dbo.[ChargeAndTax] ct ON ipt.chargeAndTaxId = ct.id
                        FOR XML PATH('CargosImpuestos'), TYPE
                    ),
                    -- Sub-nodo: Variables
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            'FacturacionServicios' AS [ds_maestro],
                            'ACTIVITY' AS [ds_VariableAdicional],
                            'GENERAL' AS [ds_valor],
                            '' AS [cd_codigo]
                        FOR XML PATH('Variables'), TYPE
                    )
                FROM dbo.[InvoicesProduct] ep
                LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
                LEFT JOIN dbo.[Provider] prv ON ep.providerId = prv.id
                WHERE ep.invoiceId = e.id
                FOR XML PATH('Item'), TYPE
            )
        FROM dbo.[Invoices] e
        JOIN dbo.[Client] c ON e.clientId = c.id
        JOIN dbo.[Branch] b ON e.branchId = b.id
        LEFT JOIN dbo.[Implant] imp ON e.implantId = imp.id
        LEFT JOIN dbo.[Seller] s ON e.sellerId = s.id
        LEFT JOIN dbo.[User] u ON e.userId = u.id
        LEFT JOIN dbo.[TicketPrinter] tp ON e.ticketPrinterId = tp.id
        WHERE e.id IN (SELECT id FROM @idsTable)
        FOR XML PATH('Facturacion'), ROOT('Facturaciones'), TYPE
    );

    SET @v_xml = CAST(@xmlResult AS VARCHAR(MAX));

    IF @v_xml IS NULL OR @v_xml = ''
    BEGIN
        SET @mensaje_resultado = 'ERROR: No se pudo construir la estructura XML para las facturas.';
    END
    ELSE
    BEGIN
        SET @mensaje_resultado = @v_xml;
    END

    SELECT @mensaje_resultado AS mensaje_resultado;
END;


GO

PRINT 'Procedimientos almacenados y funciones T-SQL compiladas exitosamente.';
