const fs = require('fs');
const path = require('path');

function generateTsqlFunctionsAndSps() {
    console.log('\n================================================================');
    console.log('   GENERANDO COMPILADO DE FUNCIONES Y SPs T-SQL (SQL SERVER)    ');
    console.log('================================================================\n');

    const path03 = path.join(__dirname, '..', 'SQL', 'SqlServer', '03_Functions_And_SPs.sql');
    
    let zeusSpsContent = '';
    const zeusDir = path.join(__dirname, '..', 'SQL', 'ZeusERP');
    if (fs.existsSync(zeusDir)) {
        const files = fs.readdirSync(zeusDir).filter(f => f.endsWith('.sql')).sort();
        for (const file of files) {
            const filePath = path.join(zeusDir, file);
            zeusSpsContent += `\n\n-- ==========================================\n-- Procedimiento Zeus ERP: ${file}\n-- ==========================================\n\n` + fs.readFileSync(filePath, 'utf8') + '\n\nGO\n';
        }
    }

    // Fallback retrocompatible para SQL/SP/
    const pathSpCotizaciones = path.join(__dirname, '..', 'SQL', 'SP', 'spCotizacionesCrear.sql');
    const pathSpFacturaciones = path.join(__dirname, '..', 'SQL', 'SP', 'spFacturacionesCrear.sql');
    if (!zeusSpsContent.includes('spCotizacionesCrear') && fs.existsSync(pathSpCotizaciones)) {
        zeusSpsContent += '\n\n' + fs.readFileSync(pathSpCotizaciones, 'utf8') + '\n\nGO\n';
    }
    if (!zeusSpsContent.includes('spFacturacionesCrear') && fs.existsSync(pathSpFacturaciones)) {
        zeusSpsContent += '\n\n' + fs.readFileSync(pathSpFacturaciones, 'utf8') + '\n\nGO\n';
    }

    // Procedimiento de Exportación de Facturas (spExportInvoices)
    const pathSpExportInvoices = path.join(__dirname, '..', 'SQL', 'SqlServer', 'spExportInvoices.sql');
    if (fs.existsSync(pathSpExportInvoices)) {
        let exportInvSql = fs.readFileSync(pathSpExportInvoices, 'utf8');
        exportInvSql = exportInvSql.replace(/^[ \t]*GO[ \t]*$/gmi, '').trim();
        zeusSpsContent += '\n\n-- ==========================================\n-- Procedimiento Exportación: spExportInvoices\n-- ==========================================\n\n' + exportInvSql + '\n\nGO\n';
    }

    const baseContent = `-- ============================================================================
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
IF OBJECT_ID('dbo.TiposServicios', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TiposServicios') AND name = 'cd_cuenta') ALTER TABLE dbo.TiposServicios ADD cd_cuenta VARCHAR(20) NULL;
GO
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'cd_vendedor') ALTER TABLE dbo.Facturas ADD cd_vendedor VARCHAR(25) NULL;
GO
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_tiqueteador') ALTER TABLE dbo.Facturas ADD id_tiqueteador INT NULL;
GO
IF OBJECT_ID('dbo.ConceptoFacturacion', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ConceptoFacturacion') AND name = 'id_TiposConceptoFacturacion') ALTER TABLE dbo.ConceptoFacturacion ADD id_TiposConceptoFacturacion INT NULL DEFAULT 2;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ConceptoFacturacion') AND name = 'cd_cuenta') ALTER TABLE dbo.ConceptoFacturacion ADD cd_cuenta VARCHAR(20) NULL;
END;
GO
IF OBJECT_ID('dbo.PROVEEDORES', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PROVEEDORES') AND name = 'bl_inactivo') ALTER TABLE dbo.PROVEEDORES ADD bl_inactivo BIT NULL DEFAULT 0;
GO
IF OBJECT_ID('dbo.MAEVENDE', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAEVENDE') AND name = 'IDVENDE') ALTER TABLE dbo.MAEVENDE ADD IDVENDE VARCHAR(20) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAEVENDE') AND name = 'Deshabilitado') ALTER TABLE dbo.MAEVENDE ADD Deshabilitado BIT NULL DEFAULT 0;
END;
GO
IF OBJECT_ID('dbo.CLIENTES', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CLIENTES') AND name = 'bl_inactivo') ALTER TABLE dbo.CLIENTES ADD bl_inactivo BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CLIENTES') AND name = 'IDVENDE') ALTER TABLE dbo.CLIENTES ADD IDVENDE VARCHAR(20) NULL;
END;
GO
IF OBJECT_ID('dbo.Tiqueteadores', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Tiqueteadores') AND name = 'bl_inactivo') ALTER TABLE dbo.Tiqueteadores ADD bl_inactivo BIT NULL DEFAULT 0;
GO
IF OBJECT_ID('dbo.TipoVenta', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TipoVenta') AND name = 'bl_inactivo') ALTER TABLE dbo.TipoVenta ADD bl_inactivo BIT NULL DEFAULT 0;
GO
IF OBJECT_ID('dbo.CargosDesc', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CargosDesc') AND name = 'cd_cuenta') ALTER TABLE dbo.CargosDesc ADD cd_cuenta VARCHAR(20) NULL;
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

-- Safeguards para dbo.Invoices y detalles
IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'fuente') ALTER TABLE dbo.Invoices ADD fuente VARCHAR(20) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'serie') ALTER TABLE dbo.Invoices ADD serie VARCHAR(20) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'consecutivo') ALTER TABLE dbo.Invoices ADD consecutivo VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'isExcelImport') ALTER TABLE dbo.Invoices ADD isExcelImport BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'zeusInvoiceNumber') ALTER TABLE dbo.Invoices ADD zeusInvoiceNumber VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'state') ALTER TABLE dbo.Invoices ADD state VARCHAR(50) NULL DEFAULT 'NUEVO';
END;
GO
IF OBJECT_ID('dbo.InvoicesProductPayment', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPayment') AND name = 'creditCardId') ALTER TABLE dbo.InvoicesProductPayment ADD creditCardId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPayment') AND name = 'authorizationCode') ALTER TABLE dbo.InvoicesProductPayment ADD authorizationCode VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPayment') AND name = 'voucher') ALTER TABLE dbo.InvoicesProductPayment ADD voucher VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPayment') AND name = 'cardNumber') ALTER TABLE dbo.InvoicesProductPayment ADD cardNumber VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPayment') AND name = 'expirationDate') ALTER TABLE dbo.InvoicesProductPayment ADD expirationDate VARCHAR(50) NULL;
END;
GO
IF OBJECT_ID('dbo.InvoicesProduct', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'ticketCode') ALTER TABLE dbo.InvoicesProduct ADD ticketCode VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'mainTaxId') ALTER TABLE dbo.InvoicesProduct ADD mainTaxId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'inNationality') ALTER TABLE dbo.InvoicesProduct ADD inNationality INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'servicios') ALTER TABLE dbo.InvoicesProduct ADD servicios VARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'descripcion') ALTER TABLE dbo.InvoicesProduct ADD descripcion VARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'itinerary') ALTER TABLE dbo.InvoicesProduct ADD itinerary VARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'class') ALTER TABLE dbo.InvoicesProduct ADD class VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'airline') ALTER TABLE dbo.InvoicesProduct ADD airline VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'ticketTypeId') ALTER TABLE dbo.InvoicesProduct ADD ticketTypeId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'providerDueDate') ALTER TABLE dbo.InvoicesProduct ADD providerDueDate DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'providerInvoice') ALTER TABLE dbo.InvoicesProduct ADD providerInvoice VARCHAR(100) NULL;
END;
GO
IF OBJECT_ID('dbo.InvoicesProductTax', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductTax') AND name = 'rate') ALTER TABLE dbo.InvoicesProductTax ADD rate FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductTax') AND name = 'explicitAmount') ALTER TABLE dbo.InvoicesProductTax ADD explicitAmount FLOAT NULL DEFAULT 0;
END;
GO
IF OBJECT_ID('dbo.QuotationProductTax', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.QuotationProductTax ALTER COLUMN valueSnapshot FLOAT NULL;
END;
GO
IF OBJECT_ID('dbo.InvoicesProductVariable', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductVariable') AND name = 'masterVariableId') ALTER TABLE dbo.InvoicesProductVariable ADD masterVariableId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductVariable') AND name = 'value') ALTER TABLE dbo.InvoicesProductVariable ADD value VARCHAR(MAX) NULL;
END;
GO
IF OBJECT_ID('dbo.InvoicesProductPasenger', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPasenger') AND name = 'name') ALTER TABLE dbo.InvoicesProductPasenger ADD name VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductPasenger') AND name = 'document') ALTER TABLE dbo.InvoicesProductPasenger ADD document VARCHAR(50) NULL;
END;
GO
IF OBJECT_ID('dbo.InvoicesProductItinerary', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'orden') ALTER TABLE dbo.InvoicesProductItinerary ADD orden INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'origin') ALTER TABLE dbo.InvoicesProductItinerary ADD origin VARCHAR(10) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'destination') ALTER TABLE dbo.InvoicesProductItinerary ADD destination VARCHAR(10) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'class') ALTER TABLE dbo.InvoicesProductItinerary ADD class VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'checkInDate') ALTER TABLE dbo.InvoicesProductItinerary ADD checkInDate DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'checkOutDate') ALTER TABLE dbo.InvoicesProductItinerary ADD checkOutDate DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'terminal') ALTER TABLE dbo.InvoicesProductItinerary ADD terminal VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'prestadoraCode') ALTER TABLE dbo.InvoicesProductItinerary ADD prestadoraCode VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'farebasis') ALTER TABLE dbo.InvoicesProductItinerary ADD farebasis VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'Numflight') ALTER TABLE dbo.InvoicesProductItinerary ADD Numflight VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'Typeflight') ALTER TABLE dbo.InvoicesProductItinerary ADD Typeflight VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'amount') ALTER TABLE dbo.InvoicesProductItinerary ADD amount FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductItinerary') AND name = 'co2') ALTER TABLE dbo.InvoicesProductItinerary ADD co2 FLOAT NULL DEFAULT 0;
END;
GO
IF OBJECT_ID('dbo.InvoicesProductCombo', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductCombo') AND name = 'comboId') ALTER TABLE dbo.InvoicesProductCombo ADD comboId INT NULL;
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

-- Safeguards para dbo.PreQuotation y dbo.PreQuotationStateHistory
IF OBJECT_ID('dbo.PreQuotation', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.[PreQuotation] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PreQuotation PRIMARY KEY,
        [consecutivo] INT NOT NULL CONSTRAINT UQ_PreQuotation_Consecutivo UNIQUE,
        [clientNameText] NVARCHAR(255) NULL,
        [clientId] INT NULL,
        [headerDescription] NVARCHAR(MAX) NULL,
        [providerId] INT NULL,
        [ticketPrinterId] INT NULL,
        [sellerId] INT NULL,
        [branchId] INT NULL,
        [preQuotationType] NVARCHAR(100) NULL CONSTRAINT DF_PreQuotation_Type DEFAULT N'General',
        [quotationNotice] NVARCHAR(MAX) NULL,
        [noticeResponse] NVARCHAR(MAX) NULL,
        [startDate] DATETIME2 NULL,
        [endDate] DATETIME2 NULL,
        [customFields] NVARCHAR(MAX) NULL CONSTRAINT DF_PreQuotation_CustomFields DEFAULT N'{}',
        [state] NVARCHAR(50) NULL CONSTRAINT DF_PreQuotation_State DEFAULT N'POR COTIZAR',
        [convertedQuotationId] INT NULL,
        [convertedAt] DATETIME2 NULL,
        [convertedUserId] INT NULL,
        [userId] INT NULL,
        [createdAt] DATETIME2 NULL CONSTRAINT DF_PreQuotation_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NULL CONSTRAINT DF_PreQuotation_UpdatedAt DEFAULT GETDATE()
    );
END;
GO

IF OBJECT_ID('dbo.PreQuotationStateHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.[PreQuotationStateHistory] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PreQuotationStateHistory PRIMARY KEY,
        [preQuotationId] INT NOT NULL CONSTRAINT FK_PreQuotationStateHistory_PreQuotation REFERENCES dbo.[PreQuotation]([id]) ON DELETE CASCADE,
        [state] NVARCHAR(50) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [userId] INT NULL,
        [createdAt] DATETIME2 NULL CONSTRAINT DF_PreQuotationStateHistory_CreatedAt DEFAULT GETDATE()
    );
END;
GO

-- Safeguards para dbo.QuotationProductTax y dbo.QuotationProductPayment
IF OBJECT_ID('dbo.QuotationProductTax', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'rate') ALTER TABLE dbo.QuotationProductTax ADD rate FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'explicitAmount') ALTER TABLE dbo.QuotationProductTax ADD explicitAmount FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'valueSnapshot') ALTER TABLE dbo.QuotationProductTax ADD valueSnapshot FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'valueTypeSnapshot') ALTER TABLE dbo.QuotationProductTax ADD valueTypeSnapshot VARCHAR(50) NULL DEFAULT 'PERCENTAGE';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'isMain') ALTER TABLE dbo.QuotationProductTax ADD isMain BIT NULL DEFAULT 0;
END;
GO

IF OBJECT_ID('dbo.QuotationProductPayment', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductPayment') AND name = 'creditCardId') ALTER TABLE dbo.QuotationProductPayment ADD creditCardId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductPayment') AND name = 'authorizationCode') ALTER TABLE dbo.QuotationProductPayment ADD authorizationCode VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductPayment') AND name = 'voucher') ALTER TABLE dbo.QuotationProductPayment ADD voucher VARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductPayment') AND name = 'cardNumber') ALTER TABLE dbo.QuotationProductPayment ADD cardNumber VARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductPayment') AND name = 'expirationDate') ALTER TABLE dbo.QuotationProductPayment ADD expirationDate VARCHAR(50) NULL;
END;
GO

-- Safeguards para dbo.Quotation y detalles
IF OBJECT_ID('dbo.Quotation', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'updatedAt') ALTER TABLE dbo.Quotation ADD updatedAt DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'copyFieldsToProducts') ALTER TABLE dbo.Quotation ADD copyFieldsToProducts BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'costoTotal') ALTER TABLE dbo.Quotation ADD costoTotal FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'valorBase') ALTER TABLE dbo.Quotation ADD valorBase FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'utilidad') ALTER TABLE dbo.Quotation ADD utilidad FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionTotalPercentage') ALTER TABLE dbo.Quotation ADD comisionTotalPercentage FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionFreelancePercentage') ALTER TABLE dbo.Quotation ADD comisionFreelancePercentage FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionFreelanceValue') ALTER TABLE dbo.Quotation ADD comisionFreelanceValue FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionPropiaPercentage') ALTER TABLE dbo.Quotation ADD comisionPropiaPercentage FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionPropiaValue') ALTER TABLE dbo.Quotation ADD comisionPropiaValue FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Quotation') AND name = 'comisionUtilidadPercentage') ALTER TABLE dbo.Quotation ADD comisionUtilidadPercentage FLOAT NULL DEFAULT 0;
END;
GO
IF OBJECT_ID('dbo.QuotationProduct', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'service') ALTER TABLE dbo.QuotationProduct ADD service NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'servicios') ALTER TABLE dbo.QuotationProduct ADD servicios NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'descripcion') ALTER TABLE dbo.QuotationProduct ADD descripcion NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'description') ALTER TABLE dbo.QuotationProduct ADD description NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'providerDueDate') ALTER TABLE dbo.QuotationProduct ADD providerDueDate DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'providerInvoice') ALTER TABLE dbo.QuotationProduct ADD providerInvoice NVARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'inNationality') ALTER TABLE dbo.QuotationProduct ADD inNationality INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'mainTaxId') ALTER TABLE dbo.QuotationProduct ADD mainTaxId INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'sellerCommission') ALTER TABLE dbo.QuotationProduct ADD sellerCommission FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'ticketPrinterCommission') ALTER TABLE dbo.QuotationProduct ADD ticketPrinterCommission FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'comboId') ALTER TABLE dbo.QuotationProduct ADD comboId INT NULL;
END;
GO
IF OBJECT_ID('dbo.QuotationManualService', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.[QuotationManualService] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationManualService PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_QuotationManualService_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [providerName] NVARCHAR(255) NULL,
        [serviceName] NVARCHAR(255) NULL,
        [cost] FLOAT NULL CONSTRAINT DF_QuotationManualService_Cost DEFAULT 0,
        [salePrice] FLOAT NULL CONSTRAINT DF_QuotationManualService_SalePrice DEFAULT 0,
        [utility] FLOAT NULL CONSTRAINT DF_QuotationManualService_Utility DEFAULT 0,
        [createdAt] DATETIME2 NULL CONSTRAINT DF_QuotationManualService_CreatedAt DEFAULT GETDATE()
    );
END;
GO
IF OBJECT_ID('dbo.QuotationCombo', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.[QuotationCombo] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationCombo PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_QuotationCombo_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [comboId] INT NOT NULL
    );
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
        pr.[airlineItinerary], 
        pr.[classItinerary], 
        pr.[flightItinerary], 
        pr.[ticketTypeId], 
        pr.[mandatoryFields], 
        pr.[taxIds], 
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

-- 2.25. spInvoicesObtener
IF OBJECT_ID('dbo.spInvoicesObtener', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesObtener;
GO

CREATE PROCEDURE dbo.spInvoicesObtener
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Recordset 0: Cabecera Invoices
    SELECT 
        i.[id],
        i.[internalNumber],
        i.[date],
        i.[dueDate],
        i.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        i.[currency],
        i.[exchangeRate],
        i.[branchId],
        b.[name] AS [branchName],
        i.[implantId],
        imp.[name] AS [implantName],
        i.[sellerId],
        s.[name] AS [sellerName],
        i.[ticketPrinterId],
        tp.[name] AS [ticketPrinterName],
        i.[baseCommissionable],
        i.[commissionPercentage],
        i.[chargesAndTaxes],
        i.[totalAmount],
        i.[userId],
        u.[name] AS [userName],
        ISNULL(i.[state], N'NUEVO') AS [state],
        i.[fuente],
        i.[serie],
        i.[consecutivo],
        ISNULL(i.[isExcelImport], 0) AS [isExcelImport],
        i.[zeusInvoiceNumber]
    FROM dbo.[Invoices] i
    LEFT JOIN dbo.[Client] c ON i.[clientId] = c.[id]
    LEFT JOIN dbo.[Branch] b ON i.[branchId] = b.[id]
    LEFT JOIN dbo.[Implant] imp ON i.[implantId] = imp.[id]
    LEFT JOIN dbo.[Seller] s ON i.[sellerId] = s.[id]
    LEFT JOIN dbo.[TicketPrinter] tp ON i.[ticketPrinterId] = tp.[id]
    LEFT JOIN dbo.[User] u ON i.[userId] = u.[id]
    WHERE i.[id] = @p_id;

    -- Recordset 1: InvoicesProduct
    SELECT 
        ip.[id],
        ip.[invoiceId],
        ip.[productId],
        p.[description] AS [productName],
        p.[description] AS [productDescription],
        p.[code] AS [productCode],
        ip.[ticketCode],
        ip.[quantity],
        ip.[price],
        ip.[cost],
        ip.[providerId],
        prov.[name] AS [providerName],
        prov.[code] AS [providerCode],
        ip.[prestadoraId],
        prest.[name] AS [prestadoraName],
        prest.[code] AS [prestadoraCode],
        ip.[checkInDate],
        ip.[checkOutDate],
        ip.[nights],
        ip.[paxAdults],
        ip.[paxChildren],
        ip.[serviceType],
        ip.[destination],
        ip.[reservationCode],
        ip.[sellerCommission],
        ip.[ticketPrinterCommission],
        ip.[comboId],
        ip.[mainTaxId],
        ip.[inNationality],
        ip.[servicios],
        ip.[descripcion],
        ip.[itinerary],
        ip.[class],
        ip.[airline],
        ip.[ticketTypeId],
        ip.[providerDueDate],
        ip.[providerInvoice]
    FROM dbo.[InvoicesProduct] ip
    LEFT JOIN dbo.[Product] p ON ip.[productId] = p.[id]
    LEFT JOIN dbo.[Provider] prov ON ip.[providerId] = prov.[id]
    LEFT JOIN dbo.[Prestadora] prest ON ip.[prestadoraId] = prest.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ip.[id] ASC;

    -- Recordset 2: InvoicesProductTax
    SELECT 
        ipt.[id],
        ipt.[invoiceProductId],
        ipt.[chargeAndTaxId],
        ct.[code] AS [taxCode],
        ct.[name] AS [taxName],
        ct.[type] AS [taxType],
        ct.[valueType] AS [taxValueType],
        ISNULL(ipt.[explicitAmount], 0) AS [explicitAmount],
        ISNULL(ipt.[explicitAmount], 0) AS [amount],
        ISNULL(ipt.[rate], 0) AS [rate]
    FROM dbo.[InvoicesProductTax] ipt
    JOIN dbo.[InvoicesProduct] ip ON ipt.[invoiceProductId] = ip.[id]
    LEFT JOIN dbo.[ChargeAndTax] ct ON ipt.[chargeAndTaxId] = ct.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipt.[id] ASC;

    -- Recordset 3: InvoicesProductPasenger
    SELECT 
        ipp.[id],
        ipp.[invoiceProductId],
        ipp.[name],
        ipp.[document]
    FROM dbo.[InvoicesProductPasenger] ipp
    JOIN dbo.[InvoicesProduct] ip ON ipp.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipp.[id] ASC;

    -- Recordset 4: InvoicesProductVariable
    SELECT 
        ipv.[id],
        ipv.[invoiceProductId],
        ipv.[masterVariableId],
        mv.[code] AS [variableCode],
        mv.[name] AS [variableName],
        ipv.[value]
    FROM dbo.[InvoicesProductVariable] ipv
    JOIN dbo.[InvoicesProduct] ip ON ipv.[invoiceProductId] = ip.[id]
    LEFT JOIN dbo.[MasterVariable] mv ON ipv.[masterVariableId] = mv.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipv.[id] ASC;

    -- Recordset 5: InvoicesProductPayment
    SELECT 
        ippay.[id],
        ippay.[invoiceProductId],
        ippay.[amount],
        ippay.[paymentMethod],
        ippay.[date],
        ippay.[reference],
        ippay.[creditCardId],
        ippay.[authorizationCode],
        ippay.[voucher],
        ippay.[cardNumber],
        ippay.[expirationDate]
    FROM dbo.[InvoicesProductPayment] ippay
    JOIN dbo.[InvoicesProduct] ip ON ippay.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ippay.[id] ASC;

    -- Recordset 6: InvoicesProductItinerary
    SELECT 
        ipi.[id],
        ipi.[invoiceProductId],
        ipi.[orden],
        ipi.[origin],
        ipi.[destination],
        ipi.[class],
        ipi.[checkInDate],
        ipi.[checkOutDate],
        ipi.[terminal],
        ipi.[prestadoraCode],
        ipi.[farebasis],
        ipi.[Numflight],
        ipi.[Typeflight],
        ipi.[amount],
        ipi.[co2]
    FROM dbo.[InvoicesProductItinerary] ipi
    JOIN dbo.[InvoicesProduct] ip ON ipi.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @p_id
    ORDER BY ipi.[orden] ASC, ipi.[id] ASC;

    -- Recordset 7: InvoicesProductCombo
    SELECT 
        ipc.[id],
        ipc.[invoiceId],
        ipc.[comboId],
        cmb.[name] AS [comboName]
    FROM dbo.[InvoicesProductCombo] ipc
    LEFT JOIN dbo.[Combo] cmb ON ipc.[comboId] = cmb.[id]
    WHERE ipc.[invoiceId] = @p_id
    ORDER BY ipc.[id] ASC;
END;
GO

-- 2.26. spInvoicesCrear
IF OBJECT_ID('dbo.spInvoicesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesCrear;
GO

CREATE PROCEDURE dbo.spInvoicesCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_invoice_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Invoices])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Invoices]', RESEED, 0);
        END

        DECLARE @clientId INT = JSON_VALUE(@p_data, '$.clientId');
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = JSON_VALUE(@p_data, '$.branchId');
        DECLARE @implantId INT = JSON_VALUE(@p_data, '$.implantId');
        DECLARE @sellerId INT = JSON_VALUE(@p_data, '$.sellerId');
        DECLARE @ticketPrinterId INT = JSON_VALUE(@p_data, '$.ticketPrinterId');
        DECLARE @totalAmount FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @fuente NVARCHAR(20) = ISNULL(JSON_VALUE(@p_data, '$.fuente'), 'FAC');
        DECLARE @serie NVARCHAR(20) = JSON_VALUE(@p_data, '$.serie');
        DECLARE @consecutivo NVARCHAR(50) = JSON_VALUE(@p_data, '$.consecutivo');
        DECLARE @date DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.date') AS DATETIME2);
        DECLARE @dueDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.dueDate') AS DATETIME2);

        IF @date IS NULL SET @date = GETDATE();
        IF @dueDate IS NULL SET @dueDate = @date;

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        IF @consecutivo IS NULL OR LTRIM(RTRIM(@consecutivo)) = ''
        BEGIN
            EXEC dbo.spObtenerSiguienteConsecutivo N'INVOICE', @branchId, @implantId, @consecutivo OUTPUT;
        END

        DECLARE @internalNumber NVARCHAR(100) = CASE 
            WHEN @serie IS NOT NULL AND LTRIM(RTRIM(@serie)) <> '' THEN CONCAT(@serie, '-', @consecutivo)
            ELSE @consecutivo
        END;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Invoices] (
            [internalNumber], [date], [dueDate], [clientId], [currency], [exchangeRate],
            [branchId], [implantId], [sellerId], [ticketPrinterId],
            [baseCommissionable], [commissionPercentage], [chargesAndTaxes],
            [totalAmount], [userId], [state], [fuente], [serie], [consecutivo], [isExcelImport]
        ) VALUES (
            @internalNumber, @date, @dueDate, @clientId, @currency, @exchangeRate,
            @branchId, @implantId, @sellerId, @ticketPrinterId,
            @baseCommissionable, @commissionPercentage, @chargesAndTaxes,
            @totalAmount, @actingUserId, N'NUEVO', @fuente, @serie, @consecutivo, 0
        );

        SET @p_invoice_id = SCOPE_IDENTITY();

        -- Inserción de Combos
        IF JSON_QUERY(@p_data, '$.combos') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[InvoicesProductCombo] ([invoiceId], [comboId])
            SELECT @p_invoice_id, CAST(JSON_VALUE(value, '$.comboId') AS INT)
            FROM OPENJSON(@p_data, '$.combos')
            WHERE JSON_VALUE(value, '$.comboId') IS NOT NULL;
        END;

        -- Inserción de Items (InvoicesProduct)
        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT [key], [value]
            FROM OPENJSON(@p_data, '$.items');

            OPEN item_cursor;
            DECLARE @itemKey NVARCHAR(50), @itemJson NVARCHAR(MAX);

            FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @prodId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.productId') AS INT);
                DECLARE @provId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.providerId') AS INT);
                DECLARE @prestId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.prestadoraId') AS INT);
                DECLARE @ticketCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.ticketCode');
                DECLARE @qty INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.cost') AS FLOAT), 0);
                DECLARE @checkIn DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkIn') AS DATETIME2);
                DECLARE @checkOut DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@itemJson, '$.nights') AS INT);
                DECLARE @paxAdults INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxAdults') AS INT), 1);
                DECLARE @paxChildren INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxChildren') AS INT), 0);
                DECLARE @srvType NVARCHAR(100) = JSON_VALUE(@itemJson, '$.serviceType');
                DECLARE @dest NVARCHAR(250) = JSON_VALUE(@itemJson, '$.destination');
                DECLARE @resCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.reservationCode');
                DECLARE @sComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.sellerCommission') AS FLOAT), 0);
                DECLARE @tpComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.ticketPrinterCommission') AS FLOAT), 0);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.mainTaxId') AS INT);
                DECLARE @inNat INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.inNationality') AS INT), 1);
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = ISNULL(JSON_VALUE(@itemJson, '$.descripcion'), JSON_VALUE(@itemJson, '$.itemDescription'));
                DECLARE @itin NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.itinerary');
                DECLARE @class NVARCHAR(50) = JSON_VALUE(@itemJson, '$.class');
                DECLARE @airline NVARCHAR(100) = JSON_VALUE(@itemJson, '$.airline');
                DECLARE @ticketTypeId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.ticketTypeId') AS INT);
                DECLARE @provDueDate DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.providerDueDate') AS DATETIME2);
                DECLARE @provInvoice NVARCHAR(100) = JSON_VALUE(@itemJson, '$.providerInvoice');

                IF @prodId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Product] WHERE id = @prodId) SET @prodId = NULL;
                IF @provId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @provId) SET @provId = NULL;
                IF @prestId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestId) SET @prestId = NULL;
                IF @ticketTypeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketType] WHERE id = @ticketTypeId) SET @ticketTypeId = NULL;

                INSERT INTO dbo.[InvoicesProduct] (
                    [invoiceId], [productId], [ticketCode], [quantity], [price], [cost],
                    [providerId], [prestadoraId], [checkInDate], [checkOutDate], [nights],
                    [paxAdults], [paxChildren], [serviceType], [destination], [reservationCode],
                    [sellerCommission], [ticketPrinterCommission], [comboId], [mainTaxId], [inNationality],
                    [servicios], [descripcion], [itinerary], [class], [airline], [ticketTypeId],
                    [providerDueDate], [providerInvoice]
                ) VALUES (
                    @p_invoice_id, @prodId, @ticketCode, @qty, @price, @cost,
                    @provId, @prestId, @checkIn, @checkOut, @nights,
                    @paxAdults, @paxChildren, @srvType, @dest, @resCode,
                    @sComm, @tpComm, @comboId, @mainTaxId, @inNat,
                    @servicios, @descripcion, @itin, @class, @airline, @ticketTypeId,
                    @provDueDate, @provInvoice
                );

                DECLARE @newIpId INT = SCOPE_IDENTITY();

                -- Impuestos del Item
                IF JSON_QUERY(@itemJson, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductTax] ([invoiceProductId], [chargeAndTaxId], [explicitAmount], [rate])
                    SELECT 
                        @newIpId,
                        TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT),
                        ISNULL(TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.explicitAmount'), JSON_VALUE(tax.value, '$.amount')) AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.rate') AS FLOAT), 0)
                    FROM OPENJSON(@itemJson, '$.appliedTaxes') AS tax
                    WHERE ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) IS NOT NULL;
                END;

                -- Pasajeros del Item
                IF JSON_QUERY(@itemJson, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPasenger] ([invoiceProductId], [name], [document])
                    SELECT @newIpId, JSON_VALUE(pax.value, '$.name'), JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@itemJson, '$.passengers') AS pax;
                END;

                -- Variables del Item
                IF JSON_QUERY(@itemJson, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductVariable] ([invoiceProductId], [masterVariableId], [value])
                    SELECT 
                        @newIpId,
                        TRY_CAST(JSON_VALUE(vr.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(vr.value, '$.value')
                    FROM OPENJSON(@itemJson, '$.variables') AS vr
                    WHERE JSON_VALUE(vr.value, '$.masterVariableId') IS NOT NULL;
                END;

                -- Pagos del Item
                IF JSON_QUERY(@itemJson, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPayment] (
                        [invoiceProductId], [amount], [paymentMethod], [date], [reference],
                        [creditCardId], [authorizationCode], [voucher], [cardNumber], [expirationDate]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(pay.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pay.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pay.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pay.value, '$.authorizationCode'),
                        JSON_VALUE(pay.value, '$.voucher'),
                        JSON_VALUE(pay.value, '$.cardNumber'),
                        JSON_VALUE(pay.value, '$.expirationDate')
                    FROM OPENJSON(@itemJson, '$.payments') AS pay;
                END;

                -- Itinerarios del Item
                IF JSON_QUERY(@itemJson, '$.itinerariesItineraryList') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductItinerary] (
                        [invoiceProductId], [orden], [origin], [destination], [class],
                        [checkInDate], [checkOutDate], [terminal], [prestadoraCode], [farebasis],
                        [Numflight], [Typeflight], [amount], [co2]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(itin.value, '$.orden') AS INT), 1),
                        JSON_VALUE(itin.value, '$.origin'),
                        JSON_VALUE(itin.value, '$.destination'),
                        JSON_VALUE(itin.value, '$.class'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkInDate') AS DATETIME2),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkOutDate') AS DATETIME2),
                        JSON_VALUE(itin.value, '$.terminal'),
                        JSON_VALUE(itin.value, '$.prestadoraCode'),
                        JSON_VALUE(itin.value, '$.farebasis'),
                        JSON_VALUE(itin.value, '$.Numflight'),
                        JSON_VALUE(itin.value, '$.Typeflight'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.amount') AS FLOAT),
                        TRY_CAST(JSON_VALUE(itin.value, '$.co2') AS FLOAT)
                    FROM OPENJSON(@itemJson, '$.itinerariesItineraryList') AS itin;
                END;

                FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            END;

            CLOSE item_cursor;
            DEALLOCATE item_cursor;
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Factura creada exitosamente con ID ', @p_invoice_id, N' y consecutivo ', @internalNumber);
        SELECT @p_invoice_id AS p_invoice_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_invoice_id = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_invoice_id AS p_invoice_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.27. spInvoicesActualizar
IF OBJECT_ID('dbo.spInvoicesActualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesActualizar;
GO

CREATE PROCEDURE dbo.spInvoicesActualizar
    @p_id INT,
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Invoices] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: La factura con ID ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @clientId INT = JSON_VALUE(@p_data, '$.clientId');
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = JSON_VALUE(@p_data, '$.branchId');
        DECLARE @implantId INT = JSON_VALUE(@p_data, '$.implantId');
        DECLARE @sellerId INT = JSON_VALUE(@p_data, '$.sellerId');
        DECLARE @ticketPrinterId INT = JSON_VALUE(@p_data, '$.ticketPrinterId');
        DECLARE @totalAmount FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @fuente NVARCHAR(20) = JSON_VALUE(@p_data, '$.fuente');
        DECLARE @serie NVARCHAR(20) = JSON_VALUE(@p_data, '$.serie');
        DECLARE @consecutivo NVARCHAR(50) = JSON_VALUE(@p_data, '$.consecutivo');
        DECLARE @date DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.date') AS DATETIME2);
        DECLARE @dueDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.dueDate') AS DATETIME2);
        DECLARE @state NVARCHAR(50) = ISNULL(JSON_VALUE(@p_data, '$.state'), N'NUEVO');

        IF @date IS NULL SET @date = GETDATE();
        IF @dueDate IS NULL SET @dueDate = @date;

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        BEGIN TRANSACTION;

        UPDATE dbo.[Invoices]
        SET [clientId] = ISNULL(@clientId, [clientId]),
            [currency] = ISNULL(@currency, [currency]),
            [exchangeRate] = ISNULL(@exchangeRate, [exchangeRate]),
            [branchId] = @branchId,
            [implantId] = @implantId,
            [sellerId] = @sellerId,
            [ticketPrinterId] = @ticketPrinterId,
            [totalAmount] = @totalAmount,
            [baseCommissionable] = @baseCommissionable,
            [chargesAndTaxes] = @chargesAndTaxes,
            [commissionPercentage] = @commissionPercentage,
            [fuente] = ISNULL(@fuente, [fuente]),
            [serie] = ISNULL(@serie, [serie]),
            [consecutivo] = ISNULL(@consecutivo, [consecutivo]),
            [date] = @date,
            [dueDate] = @dueDate,
            [state] = @state
        WHERE id = @p_id;

        -- Limpieza de detalles anteriores
        DELETE FROM dbo.[InvoicesProductTax] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id);
        DELETE FROM dbo.[InvoicesProductPasenger] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id);
        DELETE FROM dbo.[InvoicesProductVariable] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id);
        DELETE FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id);
        DELETE FROM dbo.[InvoicesProductItinerary] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id);
        DELETE FROM dbo.[InvoicesProductCombo] WHERE invoiceId = @p_id;
        DELETE FROM dbo.[InvoicesProduct] WHERE invoiceId = @p_id;

        -- Inserción de Combos
        IF JSON_QUERY(@p_data, '$.combos') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[InvoicesProductCombo] ([invoiceId], [comboId])
            SELECT @p_id, CAST(JSON_VALUE(value, '$.comboId') AS INT)
            FROM OPENJSON(@p_data, '$.combos')
            WHERE JSON_VALUE(value, '$.comboId') IS NOT NULL;
        END;

        -- Inserción de Items (InvoicesProduct)
        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT [key], [value]
            FROM OPENJSON(@p_data, '$.items');

            OPEN item_cursor;
            DECLARE @itemKey NVARCHAR(50), @itemJson NVARCHAR(MAX);

            FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @prodId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.productId') AS INT);
                DECLARE @provId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.providerId') AS INT);
                DECLARE @prestId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.prestadoraId') AS INT);
                DECLARE @ticketCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.ticketCode');
                DECLARE @qty INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.cost') AS FLOAT), 0);
                DECLARE @checkIn DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkIn') AS DATETIME2);
                DECLARE @checkOut DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@itemJson, '$.nights') AS INT);
                DECLARE @paxAdults INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxAdults') AS INT), 1);
                DECLARE @paxChildren INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxChildren') AS INT), 0);
                DECLARE @srvType NVARCHAR(100) = JSON_VALUE(@itemJson, '$.serviceType');
                DECLARE @dest NVARCHAR(250) = JSON_VALUE(@itemJson, '$.destination');
                DECLARE @resCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.reservationCode');
                DECLARE @sComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.sellerCommission') AS FLOAT), 0);
                DECLARE @tpComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.ticketPrinterCommission') AS FLOAT), 0);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.mainTaxId') AS INT);
                DECLARE @inNat INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.inNationality') AS INT), 1);
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = ISNULL(JSON_VALUE(@itemJson, '$.descripcion'), JSON_VALUE(@itemJson, '$.itemDescription'));
                DECLARE @itin NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.itinerary');
                DECLARE @class NVARCHAR(50) = JSON_VALUE(@itemJson, '$.class');
                DECLARE @airline NVARCHAR(100) = JSON_VALUE(@itemJson, '$.airline');
                DECLARE @ticketTypeId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.ticketTypeId') AS INT);
                DECLARE @provDueDate DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.providerDueDate') AS DATETIME2);
                DECLARE @provInvoice NVARCHAR(100) = JSON_VALUE(@itemJson, '$.providerInvoice');

                IF @prodId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Product] WHERE id = @prodId) SET @prodId = NULL;
                IF @provId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @provId) SET @provId = NULL;
                IF @prestId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestId) SET @prestId = NULL;
                IF @ticketTypeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketType] WHERE id = @ticketTypeId) SET @ticketTypeId = NULL;

                INSERT INTO dbo.[InvoicesProduct] (
                    [invoiceId], [productId], [ticketCode], [quantity], [price], [cost],
                    [providerId], [prestadoraId], [checkInDate], [checkOutDate], [nights],
                    [paxAdults], [paxChildren], [serviceType], [destination], [reservationCode],
                    [sellerCommission], [ticketPrinterCommission], [comboId], [mainTaxId], [inNationality],
                    [servicios], [descripcion], [itinerary], [class], [airline], [ticketTypeId],
                    [providerDueDate], [providerInvoice]
                ) VALUES (
                    @p_id, @prodId, @ticketCode, @qty, @price, @cost,
                    @provId, @prestId, @checkIn, @checkOut, @nights,
                    @paxAdults, @paxChildren, @srvType, @dest, @resCode,
                    @sComm, @tpComm, @comboId, @mainTaxId, @inNat,
                    @servicios, @descripcion, @itin, @class, @airline, @ticketTypeId,
                    @provDueDate, @provInvoice
                );

                DECLARE @newIpId INT = SCOPE_IDENTITY();

                -- Impuestos del Item
                IF JSON_QUERY(@itemJson, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductTax] ([invoiceProductId], [chargeAndTaxId], [explicitAmount], [rate])
                    SELECT 
                        @newIpId,
                        TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT),
                        ISNULL(TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.explicitAmount'), JSON_VALUE(tax.value, '$.amount')) AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.rate') AS FLOAT), 0)
                    FROM OPENJSON(@itemJson, '$.appliedTaxes') AS tax
                    WHERE ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) IS NOT NULL;
                END;

                -- Pasajeros del Item
                IF JSON_QUERY(@itemJson, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPasenger] ([invoiceProductId], [name], [document])
                    SELECT @newIpId, JSON_VALUE(pax.value, '$.name'), JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@itemJson, '$.passengers') AS pax;
                END;

                -- Variables del Item
                IF JSON_QUERY(@itemJson, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductVariable] ([invoiceProductId], [masterVariableId], [value])
                    SELECT 
                        @newIpId,
                        TRY_CAST(JSON_VALUE(vr.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(vr.value, '$.value')
                    FROM OPENJSON(@itemJson, '$.variables') AS vr
                    WHERE JSON_VALUE(vr.value, '$.masterVariableId') IS NOT NULL;
                END;

                -- Pagos del Item
                IF JSON_QUERY(@itemJson, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPayment] (
                        [invoiceProductId], [amount], [paymentMethod], [date], [reference],
                        [creditCardId], [authorizationCode], [voucher], [cardNumber], [expirationDate]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(pay.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pay.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pay.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pay.value, '$.authorizationCode'),
                        JSON_VALUE(pay.value, '$.voucher'),
                        JSON_VALUE(pay.value, '$.cardNumber'),
                        JSON_VALUE(pay.value, '$.expirationDate')
                    FROM OPENJSON(@itemJson, '$.payments') AS pay;
                END;

                -- Itinerarios del Item
                IF JSON_QUERY(@itemJson, '$.itinerariesItineraryList') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductItinerary] (
                        [invoiceProductId], [orden], [origin], [destination], [class],
                        [checkInDate], [checkOutDate], [terminal], [prestadoraCode], [farebasis],
                        [Numflight], [Typeflight], [amount], [co2]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(itin.value, '$.orden') AS INT), 1),
                        JSON_VALUE(itin.value, '$.origin'),
                        JSON_VALUE(itin.value, '$.destination'),
                        JSON_VALUE(itin.value, '$.class'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkInDate') AS DATETIME2),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkOutDate') AS DATETIME2),
                        JSON_VALUE(itin.value, '$.terminal'),
                        JSON_VALUE(itin.value, '$.prestadoraCode'),
                        JSON_VALUE(itin.value, '$.farebasis'),
                        JSON_VALUE(itin.value, '$.Numflight'),
                        JSON_VALUE(itin.value, '$.Typeflight'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.amount') AS FLOAT),
                        TRY_CAST(JSON_VALUE(itin.value, '$.co2') AS FLOAT)
                    FROM OPENJSON(@itemJson, '$.itinerariesItineraryList') AS itin;
                END;

                FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            END;

            CLOSE item_cursor;
            DEALLOCATE item_cursor;
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Factura actualizada exitosamente (ID ', @p_id, N')');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.28. spInvoicesEliminar
IF OBJECT_ID('dbo.spInvoicesEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesEliminar;
GO

CREATE PROCEDURE dbo.spInvoicesEliminar
    @p_id INT,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Invoices] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: La factura con ID ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        UPDATE dbo.[Invoices]
        SET [state] = N'ANULADO'
        WHERE id = @p_id;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Factura anulada exitosamente (ID ', @p_id, N')');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.29. spInvoicesListar
IF OBJECT_ID('dbo.spInvoicesListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesListar;
GO

CREATE PROCEDURE dbo.spInvoicesListar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        i.[id],
        i.[internalNumber],
        i.[date],
        i.[dueDate],
        i.[clientId],
        c.[name] AS [clientName],
        c.[document] AS [clientDocument],
        ISNULL(NULLIF(i.[totalAmount], 0), 0) AS [totalAmount],
        ISNULL(i.[currency], 'COP') AS [currency],
        ISNULL(i.[state], 'NUEVO') AS [state],
        ISNULL(i.[isExcelImport], 0) AS [isExcelImport],
        i.[zeusInvoiceNumber],
        i.[fuente],
        i.[serie],
        i.[consecutivo],
        (
            SELECT TOP 1 ipp.[name]
            FROM dbo.[InvoicesProduct] ip
            JOIN dbo.[InvoicesProductPasenger] ipp ON ipp.[invoiceProductId] = ip.[id]
            WHERE ip.[invoiceId] = i.[id] AND ipp.[name] IS NOT NULL AND ipp.[name] <> ''
        ) AS [paxName],
        (
            SELECT TOP 1 ISNULL(prest.[name], prov.[name])
            FROM dbo.[InvoicesProduct] ip
            LEFT JOIN dbo.[Prestadora] prest ON ip.[prestadoraId] = prest.[id]
            LEFT JOIN dbo.[Provider] prov ON ip.[providerId] = prov.[id]
            WHERE ip.[invoiceId] = i.[id] AND (prest.[name] IS NOT NULL OR prov.[name] IS NOT NULL)
        ) AS [providerName],
        (
            SELECT MIN(ip.[checkInDate])
            FROM dbo.[InvoicesProduct] ip
            WHERE ip.[invoiceId] = i.[id]
        ) AS [checkInDate],
        (
            SELECT MAX(ip.[checkOutDate])
            FROM dbo.[InvoicesProduct] ip
            WHERE ip.[invoiceId] = i.[id]
        ) AS [checkOutDate]
    FROM dbo.[Invoices] i
    LEFT JOIN dbo.[Client] c ON i.[clientId] = c.[id]
    ORDER BY i.[date] DESC, i.[id] DESC;
END;
GO

-- 2.30. spPreCotizacionListar
IF OBJECT_ID('dbo.spPreCotizacionListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionListar;
GO

CREATE PROCEDURE dbo.spPreCotizacionListar
    @p_search NVARCHAR(250) = NULL,
    @p_state NVARCHAR(50) = NULL,
    @p_branch_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        pq.[id],
        pq.[consecutivo],
        pq.[branchId],
        b.[name] AS [branchName],
        pq.[clientId],
        c.[name] AS [clientName],
        pq.[clientNameText],
        pq.[sellerId],
        s.[name] AS [sellerName],
        pq.[ticketPrinterId],
        tp.[name] AS [ticketPrinterName],
        pq.[providerId],
        prov.[name] AS [providerName],
        pq.[headerDescription],
        pq.[quotationNotice],
        pq.[noticeResponse],
        pq.[preQuotationType],
        pq.[startDate],
        pq.[endDate],
        pq.[state],
        pq.[customFields],
        pq.[convertedQuotationId],
        pq.[convertedUserId],
        cu.[name] AS [convertedUserName],
        pq.[convertedAt],
        pq.[createdAt],
        pq.[updatedAt],
        pq.[userId],
        u.[name] AS [userName]
    FROM dbo.[PreQuotation] pq
    LEFT JOIN dbo.[Branch] b ON pq.[branchId] = b.[id]
    LEFT JOIN dbo.[Client] c ON pq.[clientId] = c.[id]
    LEFT JOIN dbo.[Seller] s ON pq.[sellerId] = s.[id]
    LEFT JOIN dbo.[TicketPrinter] tp ON pq.[ticketPrinterId] = tp.[id]
    LEFT JOIN dbo.[Provider] prov ON pq.[providerId] = prov.[id]
    LEFT JOIN dbo.[User] u ON pq.[userId] = u.[id]
    LEFT JOIN dbo.[User] cu ON pq.[convertedUserId] = cu.[id]
    WHERE 
        (@p_search IS NULL OR LTRIM(RTRIM(@p_search)) = '' OR 
         CAST(pq.[consecutivo] AS NVARCHAR(50)) LIKE '%' + @p_search + '%' OR
         pq.[clientNameText] LIKE '%' + @p_search + '%' OR
         c.[name] LIKE '%' + @p_search + '%' OR
         pq.[headerDescription] LIKE '%' + @p_search + '%' OR
         pq.[quotationNotice] LIKE '%' + @p_search + '%')
        AND (@p_state IS NULL OR LTRIM(RTRIM(@p_state)) = '' OR pq.[state] = @p_state)
        AND (@p_branch_id IS NULL OR @p_branch_id = 0 OR pq.[branchId] = @p_branch_id)
    ORDER BY pq.[id] DESC;
END;
GO

-- 2.31. spPreCotizacionCrear
IF OBJECT_ID('dbo.spPreCotizacionCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionCrear;
GO

CREATE PROCEDURE dbo.spPreCotizacionCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_pre_quotation_id INT = NULL OUTPUT,
    @p_consecutivo INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[PreQuotation]', RESEED, 0);
        END;

        DECLARE @branchId INT = TRY_CAST(JSON_VALUE(@p_data, '$.branchId') AS INT);
        DECLARE @clientId INT = TRY_CAST(JSON_VALUE(@p_data, '$.clientId') AS INT);
        DECLARE @clientNameText NVARCHAR(250) = JSON_VALUE(@p_data, '$.clientNameText');
        DECLARE @sellerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.sellerId') AS INT);
        DECLARE @ticketPrinterId INT = TRY_CAST(JSON_VALUE(@p_data, '$.ticketPrinterId') AS INT);
        DECLARE @providerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.providerId') AS INT);
        DECLARE @headerDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.headerDescription');
        DECLARE @quotationNotice NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.quotationNotice');
        DECLARE @preQuotationType NVARCHAR(100) = JSON_VALUE(@p_data, '$.preQuotationType');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @customFields NVARCHAR(MAX) = JSON_QUERY(@p_data, '$.customFields');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;
        IF @providerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerId)
            SET @providerId = NULL;

        DECLARE @nextConsecutivo INT = (SELECT ISNULL(MAX(consecutivo), 0) + 1 FROM dbo.[PreQuotation]);

        BEGIN TRANSACTION;

        INSERT INTO dbo.[PreQuotation] (
            consecutivo, branchId, clientId, clientNameText, sellerId, ticketPrinterId, providerId,
            headerDescription, quotationNotice, preQuotationType, startDate, endDate,
            [state], customFields, createdAt, updatedAt, userId
        ) VALUES (
            @nextConsecutivo, @branchId, @clientId, @clientNameText, @sellerId, @ticketPrinterId, @providerId,
            @headerDescription, @quotationNotice, @preQuotationType, @startDate, @endDate,
            N'PENDIENTE', @customFields, GETDATE(), GETDATE(), @actingUserId
        );

        SET @p_pre_quotation_id = SCOPE_IDENTITY();
        SET @p_consecutivo = @nextConsecutivo;

        INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
        VALUES (@p_pre_quotation_id, N'PENDIENTE', N'Creación de pre-cotización', GETDATE(), @actingUserId);

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización #', @p_consecutivo, N' creada correctamente');
        SELECT @p_pre_quotation_id AS p_pre_quotation_id, @p_consecutivo AS p_consecutivo, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_pre_quotation_id = 0;
        SET @p_consecutivo = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_pre_quotation_id, 0 AS p_consecutivo, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.32. spPreCotizacionConvertir
IF OBJECT_ID('dbo.spPreCotizacionConvertir', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionConvertir;
GO

CREATE PROCEDURE dbo.spPreCotizacionConvertir
    @p_pre_quotation_id INT,
    @p_quotation_id INT = NULL,
    @p_acting_user_id INT = 1,
    @p_notice_response NVARCHAR(MAX) = NULL,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation] WHERE id = @p_pre_quotation_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Pre-Cotización con ID ', @p_pre_quotation_id, N' no existe');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        BEGIN TRANSACTION;

        IF @p_quotation_id IS NOT NULL AND @p_quotation_id > 0
        BEGIN
            UPDATE dbo.[PreQuotation]
            SET [state] = N'CONVERTIDA',
                convertedQuotationId = @p_quotation_id,
                convertedUserId = @actingUserId,
                convertedAt = GETDATE(),
                noticeResponse = ISNULL(@p_notice_response, noticeResponse),
                updatedAt = GETDATE()
            WHERE id = @p_pre_quotation_id;

            INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
            VALUES (@p_pre_quotation_id, N'CONVERTIDA', CONCAT(N'Convertida a Cotización #', @p_quotation_id), GETDATE(), @actingUserId);

            SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización convertida exitosamente a Cotización #', @p_quotation_id);
        END
        ELSE
        BEGIN
            UPDATE dbo.[PreQuotation]
            SET noticeResponse = ISNULL(@p_notice_response, noticeResponse),
                updatedAt = GETDATE()
            WHERE id = @p_pre_quotation_id;

            IF @p_notice_response IS NOT NULL AND TRIM(@p_notice_response) <> ''
            BEGIN
                INSERT INTO dbo.[PreQuotationStateHistory] (preQuotationId, [state], [description], createdAt, userId)
                VALUES (@p_pre_quotation_id, N'RESPUESTA_DUDA', CONCAT(N'Respuesta/Duda: ', @p_notice_response), GETDATE(), @actingUserId);
            END;

            SET @p_mensaje_resultado = N'SUCCESS: Respuesta / Duda registrada en la Pre-Cotización correctamente.';
        END;

        COMMIT TRANSACTION;
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.33. spPreCotizacionEliminar
IF OBJECT_ID('dbo.spPreCotizacionEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spPreCotizacionEliminar;
GO

CREATE PROCEDURE dbo.spPreCotizacionEliminar
    @p_id INT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[PreQuotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Pre-Cotización no encontrada con ID ', @p_id);
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        BEGIN TRANSACTION;
        DELETE FROM dbo.[PreQuotationStateHistory] WHERE preQuotationId = @p_id;
        DELETE FROM dbo.[PreQuotation] WHERE id = @p_id;
        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Pre-Cotización #', @p_id, N' eliminada correctamente');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.34. spCotizacionListar
IF OBJECT_ID('dbo.spCotizacionListar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionListar;
GO

CREATE PROCEDURE dbo.spCotizacionListar
    @p_referencia NVARCHAR(100) = NULL,
    @p_fecha_desde DATE = NULL,
    @p_fecha_hasta DATE = NULL,
    @p_cliente NVARCHAR(250) = NULL,
    @p_elaborado_por NVARCHAR(250) = NULL,
    @p_monto_total FLOAT = NULL,
    @p_estado NVARCHAR(50) = NULL
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
        ISNULL(NULLIF(q.[totalAmount], 0), 0) AS [totalAmount],
        ISNULL(q.[state], N'NUEVO') AS [state],
        q.[stateDescription],
        q.[stateUpdatedAt],
        q.[userId],
        u.[name] AS [userName],
        (
            SELECT c.[id], c.[name], c.[document]
            FROM dbo.[Client] c
            WHERE c.[id] = q.[clientId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [clientJson],
        (
            SELECT u.[id], u.[name]
            FROM dbo.[User] u
            WHERE u.[id] = q.[userId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [userJson],
        (
            SELECT 
                qp.[id],
                qp.[productId],
                qp.[providerId],
                qp.[prestadoraId],
                qp.[quantity],
                qp.[price],
                qp.[checkInDate],
                qp.[checkOutDate],
                qp.[inNationality],
                qp.[mainTaxId],
                (
                    SELECT p.[id], p.[description]
                    FROM dbo.[Product] p
                    WHERE p.[id] = qp.[productId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [productJson],
                (
                    SELECT prov.[id], prov.[name]
                    FROM dbo.[Provider] prov
                    WHERE prov.[id] = qp.[providerId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [providerJson],
                (
                    SELECT prest.[id], prest.[name]
                    FROM dbo.[Prestadora] prest
                    WHERE prest.[id] = qp.[prestadoraId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [prestadoraJson],
                (
                    SELECT qpax.[id], qpax.[name], qpax.[document]
                    FROM dbo.[QuotationProductPassenger] qpax
                    WHERE qpax.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [passengersJson],
                (
                    SELECT qvar.[id], qvar.[masterVariableId], qvar.[value]
                    FROM dbo.[QuotationProductVariable] qvar
                    WHERE qvar.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [variablesJson],
                (
                    SELECT qpt.[chargeAndTaxId], qpt.[explicitAmount], qpt.[isMain]
                    FROM dbo.[QuotationProductTax] qpt
                    WHERE qpt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [appliedTaxesJson]
            FROM dbo.[QuotationProduct] qp
            WHERE qp.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [productsJson]
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
    ORDER BY q.[date] DESC;
END;
GO

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

-- 2.36. spCotizacionObtener
IF OBJECT_ID('dbo.spCotizacionObtener', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionObtener;
GO

CREATE PROCEDURE dbo.spCotizacionObtener
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        q.[id],
        q.[internalNumber],
        q.[date],
        q.[clientId],
        q.[currency],
        q.[exchangeRate],
        q.[branchId],
        q.[implantId],
        q.[sellerId],
        q.[ticketPrinterId],
        q.[commissionPercentage],
        q.[chargesAndTaxes],
        q.[totalAmount],
        q.[destination],
        q.[startDate],
        q.[endDate],
        q.[passenger],
        q.[paxAdults],
        q.[paxChildren],
        q.[reservationCode],
        q.[copyFieldsToProducts],
        q.[manualDescription],
        ISNULL(q.[state], N'Nuevo') AS [state],
        q.[stateDescription],
        q.[stateUpdatedAt],
        (
            SELECT c.[id], c.[name], c.[document]
            FROM dbo.[Client] c
            WHERE c.[id] = q.[clientId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [clientJson],
        (
            SELECT s.[id], s.[name], s.[code]
            FROM dbo.[Seller] s
            WHERE s.[id] = q.[sellerId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [sellerJson],
        (
            SELECT b.[id], b.[name], b.[code]
            FROM dbo.[Branch] b
            WHERE b.[id] = q.[branchId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [branchJson],
        (
            SELECT imp.[id], imp.[name], imp.[code]
            FROM dbo.[Implant] imp
            WHERE imp.[id] = q.[implantId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [implantJson],
        (
            SELECT tp.[id], tp.[name], tp.[code]
            FROM dbo.[TicketPrinter] tp
            WHERE tp.[id] = q.[ticketPrinterId]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS [ticketPrinterJson],
        (
            SELECT 
                qp.[id],
                qp.[productId],
                qp.[providerId],
                qp.[prestadoraId],
                qp.[quantity],
                qp.[price],
                qp.[cost],
                qp.[checkInDate],
                qp.[checkOutDate],
                qp.[nights],
                qp.[paxAdults],
                qp.[paxChildren],
                qp.[serviceType],
                qp.[destination],
                qp.[reservationCode],
                qp.[sellerCommission],
                qp.[ticketPrinterCommission],
                qp.[comboId],
                qp.[mainTaxId],
                qp.[inNationality],
                qp.[service],
                qp.[servicios],
                qp.[descripcion],
                qp.[passenger],
                qp.[providerDueDate],
                qp.[providerInvoice],
                (
                    SELECT p.[id], p.[description], p.[code]
                    FROM dbo.[Product] p
                    WHERE p.[id] = qp.[productId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [productJson],
                (
                    SELECT prov.[id], prov.[name], prov.[code]
                    FROM dbo.[Provider] prov
                    WHERE prov.[id] = qp.[providerId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [providerJson],
                (
                    SELECT prest.[id], prest.[name], prest.[code]
                    FROM dbo.[Prestadora] prest
                    WHERE prest.[id] = qp.[prestadoraId]
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                ) AS [prestadoraJson],
                (
                    SELECT qpax.[id], qpax.[name], qpax.[document]
                    FROM dbo.[QuotationProductPassenger] qpax
                    WHERE qpax.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [passengersJson],
                (
                    SELECT qvar.[id], qvar.[masterVariableId], qvar.[value]
                    FROM dbo.[QuotationProductVariable] qvar
                    WHERE qvar.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [variablesJson],
                (
                    SELECT qpt.[id], qpt.[chargeAndTaxId], qpt.[explicitAmount] AS [amount], qpt.[explicitAmount], ct.[code] AS [taxCode], ct.[name] AS [taxName]
                    FROM dbo.[QuotationProductTax] qpt
                    LEFT JOIN dbo.[ChargeAndTax] ct ON qpt.[chargeAndTaxId] = ct.[id]
                    WHERE qpt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [appliedTaxesJson],
                (
                    SELECT qpmt.[id], qpmt.[amount], qpmt.[paymentMethod], qpmt.[date], qpmt.[reference], qpmt.[creditCardId], qpmt.[cardNumber], qpmt.[authorizationCode], qpmt.[voucher], qpmt.[expirationDate]
                    FROM dbo.[QuotationProductPayment] qpmt
                    WHERE qpmt.[quotationProductId] = qp.[id]
                    FOR JSON PATH
                ) AS [paymentsJson]
            FROM dbo.[QuotationProduct] qp
            WHERE qp.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [productsJson],
        (
            SELECT qc.[comboId] AS [id], qc.[comboId], cmb.[name]
            FROM dbo.[QuotationCombo] qc
            LEFT JOIN dbo.[Combo] cmb ON qc.[comboId] = cmb.[id]
            WHERE qc.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [combosJson],
        (
            SELECT ms.[id], ms.[serviceName] AS [name], ms.[serviceName], ms.[salePrice] AS [amount], ms.[salePrice], ms.[cost], ms.[utility], ms.[providerName]
            FROM dbo.[QuotationManualService] ms
            WHERE ms.[quotationId] = q.[id]
            FOR JSON PATH
        ) AS [manualServicesJson],
        (
            SELECT sh.[id], sh.[quotationId], sh.[state], sh.[description], sh.[userId], u.[name] AS [userName], sh.[createdAt]
            FROM dbo.[QuotationStateHistory] sh
            LEFT JOIN dbo.[User] u ON sh.[userId] = u.[id]
            WHERE sh.[quotationId] = q.[id]
            ORDER BY sh.[id] ASC
            FOR JSON PATH
        ) AS [stateHistoryJson]
    FROM dbo.[Quotation] q
    WHERE q.[id] = @p_id;
END;
GO

-- 2.37. spCotizacionCrear
IF OBJECT_ID('dbo.spCotizacionCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionCrear;
GO

CREATE PROCEDURE dbo.spCotizacionCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_quotation_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);
        END;

        DECLARE @clientId INT = TRY_CAST(JSON_VALUE(@p_data, '$.clientId') AS INT);
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = TRY_CAST(JSON_VALUE(@p_data, '$.branchId') AS INT);
        DECLARE @implantId INT = TRY_CAST(JSON_VALUE(@p_data, '$.implantId') AS INT);
        DECLARE @sellerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.sellerId') AS INT);
        DECLARE @ticketPrinterId INT = TRY_CAST(JSON_VALUE(@p_data, '$.ticketPrinterId') AS INT);
        DECLARE @totalAmount FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @destination NVARCHAR(250) = JSON_VALUE(@p_data, '$.destination');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @passenger NVARCHAR(250) = JSON_VALUE(@p_data, '$.passenger');
        DECLARE @paxAdults INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxAdults') AS INT);
        DECLARE @paxChildren INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxChildren') AS INT);
        DECLARE @reservationCode NVARCHAR(100) = JSON_VALUE(@p_data, '$.reservationCode');
        DECLARE @manualDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.manualDescription');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        DECLARE @internalNum NVARCHAR(100) = NULL;
        EXEC dbo.spObtenerSiguienteConsecutivo N'QUOTATION', @branchId, @implantId, @internalNum OUTPUT;

        -- Validación de variables adicionales obligatorias del cliente para cotizaciones
        IF @clientId IS NOT NULL
        BEGIN
            DECLARE @clientMandatoryVarsJson NVARCHAR(MAX) = (SELECT mandatoryVariables FROM dbo.[Client] WHERE id = @clientId);
            IF @clientMandatoryVarsJson IS NOT NULL AND ISJSON(@clientMandatoryVarsJson) = 1
            BEGIN
                DECLARE @reqVarList TABLE (varId INT);
                IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotation') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotation') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotations') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotations') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_VALUE(@clientMandatoryVarsJson, '$[0]') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson) WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END;

                IF EXISTS (SELECT 1 FROM @reqVarList)
                BEGIN
                    DECLARE @reqVarId INT;
                    DECLARE req_var_cur CURSOR LOCAL FAST_FORWARD FOR
                    SELECT varId FROM @reqVarList;

                    OPEN req_var_cur;
                    FETCH NEXT FROM req_var_cur INTO @reqVarId;

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        DECLARE @reqVarName NVARCHAR(250) = (SELECT [name] FROM dbo.[MasterVariable] WHERE id = @reqVarId);
                        SET @reqVarName = ISNULL(@reqVarName, CONCAT(N'Variable #', @reqVarId));

                        IF EXISTS (
                            SELECT 1
                            FROM OPENJSON(@p_data, '$.items') AS itm
                            OUTER APPLY (
                                SELECT COUNT(1) AS cnt
                                FROM OPENJSON(itm.[value], '$.variables') AS v
                                WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                  AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                            ) vars
                            WHERE ISNULL(vars.cnt, 0) = 0
                        )
                        BEGIN
                            DECLARE @missingProdDesc NVARCHAR(250) = (
                                SELECT TOP 1 ISNULL(p.[description], CONCAT(N'Producto #', ISNULL(TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS NVARCHAR(50)), '1')))
                                FROM OPENJSON(@p_data, '$.items') AS itm
                                LEFT JOIN dbo.[Product] p ON p.id = TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS INT)
                                OUTER APPLY (
                                    SELECT COUNT(1) AS cnt
                                    FROM OPENJSON(itm.[value], '$.variables') AS v
                                    WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                      AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                                ) vars
                                WHERE ISNULL(vars.cnt, 0) = 0
                            );

                            SET @p_mensaje_resultado = CONCAT(N'ERROR: El cliente requiere completar la variable adicional "', @reqVarName, N'" en el producto "', ISNULL(@missingProdDesc, N'Producto'), N'".');
                            CLOSE req_var_cur;
                            DEALLOCATE req_var_cur;
                            RETURN;
                        END;

                        FETCH NEXT FROM req_var_cur INTO @reqVarId;
                    END;

                    CLOSE req_var_cur;
                    DEALLOCATE req_var_cur;
                END;
            END;
        END;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Quotation] (
            internalNumber, [date], clientId, currency, exchangeRate, branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, chargesAndTaxes, totalAmount, commissionPercentage, userId, state, stateDescription, stateUpdatedAt,
            destination, startDate, endDate, passenger, paxAdults, paxChildren, reservationCode, manualDescription
        ) VALUES (
            ISNULL(@internalNum, N'TEMP'), GETDATE(), @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId, @ticketPrinterId,
            @baseCommissionable, @chargesAndTaxes, @totalAmount, @commissionPercentage, @actingUserId, N'NUEVO', N'Creación de cotización', GETDATE(),
            @destination, @startDate, @endDate, @passenger, @paxAdults, @paxChildren, @reservationCode, @manualDescription
        );

        SET @p_quotation_id = SCOPE_IDENTITY();

        IF @internalNum IS NULL OR @internalNum = N'TEMP'
        BEGIN
            UPDATE dbo.[Quotation]
            SET internalNumber = CAST(@p_quotation_id AS NVARCHAR(50))
            WHERE id = @p_quotation_id;
        END;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, state, [description], createdAt, userId)
        VALUES (@p_quotation_id, N'NUEVO', N'Creación de cotización', GETDATE(), @actingUserId);

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE @item_val NVARCHAR(MAX);
            DECLARE item_cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur;
            FETCH NEXT FROM item_cur INTO @item_val;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productId INT = TRY_CAST(JSON_VALUE(@item_val, '$.productId') AS INT);
                DECLARE @quantity INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.cost') AS FLOAT), 0);
                DECLARE @providerId INT = TRY_CAST(JSON_VALUE(@item_val, '$.providerId') AS INT);
                DECLARE @prestadoraId INT = TRY_CAST(JSON_VALUE(@item_val, '$.prestadoraId') AS INT);
                DECLARE @checkInDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@item_val, '$.nights') AS INT);
                DECLARE @paxAdultsItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxChildren') AS INT);
                DECLARE @serviceType NVARCHAR(250) = JSON_VALUE(@item_val, '$.serviceType');
                DECLARE @destinationItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.destination');
                DECLARE @reservationCodeItem NVARCHAR(100) = JSON_VALUE(@item_val, '$.reservationCode');
                DECLARE @sellerCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@item_val, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@item_val, '$.mainTaxId') AS INT);
                DECLARE @inNationality INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.inNationality') AS INT), 1);
                DECLARE @service NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.service');
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.descripcion');
                DECLARE @passengerItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.passenger');
                DECLARE @providerDueDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.providerDueDate') AS DATETIME2);
                DECLARE @providerInvoice NVARCHAR(100) = JSON_VALUE(@item_val, '$.providerInvoice');

                IF @providerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerId) SET @providerId = NULL;
                IF @prestadoraId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraId) SET @prestadoraId = NULL;

                DECLARE @qp_id INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, description, passenger, providerDueDate, providerInvoice
                ) VALUES (
                    @p_quotation_id, @productId, @quantity, @price, @cost, @providerId, @prestadoraId,
                    @checkInDate, @checkOutDate, @nights, @paxAdultsItem, @paxChildrenItem, @serviceType, @destinationItem,
                    @reservationCodeItem, @sellerCommission, @ticketPrinterCommission, @comboId, @mainTaxId, @inNationality,
                    @service, @servicios, @descripcion, @descripcion, @passengerItem, @providerDueDate, @providerInvoice
                );
                SET @qp_id = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'FIXED'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END;

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, document)
                    SELECT
                        @qp_id,
                        JSON_VALUE(pax.value, '$.name'),
                        JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@item_val, '$.passengers') AS pax
                    WHERE JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '';
                END;

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END;

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val, '$.payments') AS pmt;
                END;

                FETCH NEXT FROM item_cur INTO @item_val;
            END;

            CLOSE item_cur;
            DEALLOCATE item_cur;
        END;

        -- Recalculate totalAmount if 0 or missing
        DECLARE @calcTotal FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_quotation_id
        );
        IF @calcTotal IS NULL OR @calcTotal = 0
        BEGIN
            SET @calcTotal = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_quotation_id
            );
        END;

        IF @calcTotal IS NOT NULL AND @calcTotal > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @calcTotal,
                baseCommissionable = ISNULL(NULLIF(@baseCommissionable, 0), @calcTotal),
                chargesAndTaxes = ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotal)
            WHERE id = @p_quotation_id;
        END
        ELSE IF @totalAmount > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @totalAmount
            WHERE id = @p_quotation_id;
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización creada correctamente con ID ', @p_quotation_id);
        SELECT @p_quotation_id AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.38. spCotizacionActualizar
IF OBJECT_ID('dbo.spCotizacionActualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizar;
GO

CREATE PROCEDURE dbo.spCotizacionActualizar
    @p_id INT,
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @clientId INT = TRY_CAST(JSON_VALUE(@p_data, '$.clientId') AS INT);
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = TRY_CAST(JSON_VALUE(@p_data, '$.branchId') AS INT);
        DECLARE @implantId INT = TRY_CAST(JSON_VALUE(@p_data, '$.implantId') AS INT);
        DECLARE @sellerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.sellerId') AS INT);
        DECLARE @ticketPrinterId INT = TRY_CAST(JSON_VALUE(@p_data, '$.ticketPrinterId') AS INT);
        DECLARE @totalAmount FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @state NVARCHAR(50) = ISNULL(JSON_VALUE(@p_data, '$.state'), N'NUEVO');
        DECLARE @stateDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.stateDescription');
        DECLARE @destination NVARCHAR(250) = JSON_VALUE(@p_data, '$.destination');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @passenger NVARCHAR(250) = JSON_VALUE(@p_data, '$.passenger');
        DECLARE @paxAdults INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxAdults') AS INT);
        DECLARE @paxChildren INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxChildren') AS INT);
        DECLARE @reservationCode NVARCHAR(100) = JSON_VALUE(@p_data, '$.reservationCode');
        DECLARE @manualDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.manualDescription');

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        -- Validación de variables adicionales obligatorias del cliente para cotizaciones
        IF @clientId IS NOT NULL
        BEGIN
            DECLARE @clientMandatoryVarsJson NVARCHAR(MAX) = (SELECT mandatoryVariables FROM dbo.[Client] WHERE id = @clientId);
            IF @clientMandatoryVarsJson IS NOT NULL AND ISJSON(@clientMandatoryVarsJson) = 1
            BEGIN
                DECLARE @reqVarList TABLE (varId INT);
                IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotation') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotation') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotations') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotations') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_VALUE(@clientMandatoryVarsJson, '$[0]') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson) WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END;

                IF EXISTS (SELECT 1 FROM @reqVarList)
                BEGIN
                    DECLARE @reqVarId INT;
                    DECLARE req_var_cur CURSOR LOCAL FAST_FORWARD FOR
                    SELECT varId FROM @reqVarList;

                    OPEN req_var_cur;
                    FETCH NEXT FROM req_var_cur INTO @reqVarId;

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        DECLARE @reqVarName NVARCHAR(250) = (SELECT [name] FROM dbo.[MasterVariable] WHERE id = @reqVarId);
                        SET @reqVarName = ISNULL(@reqVarName, CONCAT(N'Variable #', @reqVarId));

                        IF EXISTS (
                            SELECT 1
                            FROM OPENJSON(@p_data, '$.items') AS itm
                            OUTER APPLY (
                                SELECT COUNT(1) AS cnt
                                FROM OPENJSON(itm.[value], '$.variables') AS v
                                WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                  AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                            ) vars
                            WHERE ISNULL(vars.cnt, 0) = 0
                        )
                        BEGIN
                            DECLARE @missingProdDesc NVARCHAR(250) = (
                                SELECT TOP 1 ISNULL(p.[description], CONCAT(N'Producto #', ISNULL(TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS NVARCHAR(50)), '1')))
                                FROM OPENJSON(@p_data, '$.items') AS itm
                                LEFT JOIN dbo.[Product] p ON p.id = TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS INT)
                                OUTER APPLY (
                                    SELECT COUNT(1) AS cnt
                                    FROM OPENJSON(itm.[value], '$.variables') AS v
                                    WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                      AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                                ) vars
                                WHERE ISNULL(vars.cnt, 0) = 0
                            );

                            SET @p_mensaje_resultado = CONCAT(N'ERROR: El cliente requiere completar la variable adicional "', @reqVarName, N'" en el producto "', ISNULL(@missingProdDesc, N'Producto'), N'".');
                            CLOSE req_var_cur;
                            DEALLOCATE req_var_cur;
                            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
                            RETURN;
                        END;

                        FETCH NEXT FROM req_var_cur INTO @reqVarId;
                    END;

                    CLOSE req_var_cur;
                    DEALLOCATE req_var_cur;
                END;
            END;
        END;

        BEGIN TRANSACTION;

        UPDATE dbo.[Quotation]
        SET
            clientId = @clientId,
            currency = @currency,
            exchangeRate = @exchangeRate,
            branchId = ISNULL(@branchId, branchId),
            implantId = @implantId,
            sellerId = @sellerId,
            ticketPrinterId = @ticketPrinterId,
            totalAmount = @totalAmount,
            baseCommissionable = @baseCommissionable,
            chargesAndTaxes = @chargesAndTaxes,
            commissionPercentage = @commissionPercentage,
            state = @state,
            stateDescription = ISNULL(@stateDescription, stateDescription),
            stateUpdatedAt = GETDATE(),
            destination = @destination,
            startDate = @startDate,
            endDate = @endDate,
            passenger = @passenger,
            paxAdults = @paxAdults,
            paxChildren = @paxChildren,
            reservationCode = @reservationCode,
            manualDescription = @manualDescription
        WHERE id = @p_id;

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DELETE FROM dbo.[QuotationProductTax] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductVariable] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPayment] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProduct] WHERE quotationId = @p_id;

            DECLARE @item_val_upd NVARCHAR(MAX);
            DECLARE item_cur_upd CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur_upd;
            FETCH NEXT FROM item_cur_upd INTO @item_val_upd;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.productId') AS INT);
                DECLARE @quantityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.quantity') AS INT), 1);
                DECLARE @priceUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.price') AS FLOAT), 0);
                DECLARE @costUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.cost') AS FLOAT), 0);
                DECLARE @providerIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.providerId') AS INT);
                DECLARE @prestadoraIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.prestadoraId') AS INT);
                DECLARE @checkInDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkOut') AS DATETIME2);
                DECLARE @nightsUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.nights') AS INT);
                DECLARE @paxAdultsItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxChildren') AS INT);
                DECLARE @serviceTypeUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.serviceType');
                DECLARE @destinationItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.destination');
                DECLARE @reservationCodeItemUpd NVARCHAR(100) = JSON_VALUE(@item_val_upd, '$.reservationCode');
                DECLARE @sellerCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.comboId') AS INT);
                DECLARE @mainTaxIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.mainTaxId') AS INT);
                DECLARE @inNationalityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.inNationality') AS INT), 1);
                DECLARE @serviceUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.service');
                DECLARE @serviciosUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.servicios');
                DECLARE @descripcionUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.descripcion');
                DECLARE @passengerItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.passenger');
                DECLARE @providerDueDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.providerDueDate') AS DATETIME2);
                DECLARE @providerInvoiceUpd NVARCHAR(100) = JSON_VALUE(@item_val_upd, '$.providerInvoice');

                IF @providerIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerIdUpd) SET @providerIdUpd = NULL;
                IF @prestadoraIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraIdUpd) SET @prestadoraIdUpd = NULL;

                DECLARE @qp_id_upd INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, description, passenger, providerDueDate, providerInvoice
                ) VALUES (
                    @p_id, @productIdUpd, @quantityUpd, @priceUpd, @costUpd, @providerIdUpd, @prestadoraIdUpd,
                    @checkInDateUpd, @checkOutDateUpd, @nightsUpd, @paxAdultsItemUpd, @paxChildrenItemUpd, @serviceTypeUpd, @destinationItemUpd,
                    @reservationCodeItemUpd, @sellerCommissionUpd, @ticketPrinterCommissionUpd, @comboIdUpd, @mainTaxIdUpd, @inNationalityUpd,
                    @serviceUpd, @serviciosUpd, @descripcionUpd, @descripcionUpd, @passengerItemUpd, @providerDueDateUpd, @providerInvoiceUpd
                );
                SET @qp_id_upd = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val_upd, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'FIXED'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxIdUpd OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val_upd, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END;

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val_upd, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, document)
                    SELECT
                        @qp_id_upd,
                        JSON_VALUE(pax.value, '$.name'),
                        JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@item_val_upd, '$.passengers') AS pax
                    WHERE JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '';
                END;

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val_upd, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val_upd, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END;

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val_upd, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id_upd,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val_upd, '$.payments') AS pmt;
                END;

                FETCH NEXT FROM item_cur_upd INTO @item_val_upd;
            END;

            CLOSE item_cur_upd;
            DEALLOCATE item_cur_upd;
        END;

        -- Recalculate totalAmount if 0 or missing
        DECLARE @calcTotalUpd FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_id
        );
        IF @calcTotalUpd IS NULL OR @calcTotalUpd = 0
        BEGIN
            SET @calcTotalUpd = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_id
            );
        END;

        IF @calcTotalUpd IS NOT NULL AND @calcTotalUpd > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @calcTotalUpd,
                baseCommissionable = ISNULL(NULLIF(@baseCommissionable, 0), @calcTotalUpd),
                chargesAndTaxes = ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotalUpd)
            WHERE id = @p_id;
        END
        ELSE IF @totalAmount > 0
        BEGIN
            UPDATE dbo.[Quotation]
            SET totalAmount = @totalAmount
            WHERE id = @p_id;
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización ', @p_id, N' actualizada correctamente.');
        SELECT @p_id AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.39. spCotizacionDuplicar
IF OBJECT_ID('dbo.spCotizacionDuplicar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionDuplicar;
GO

CREATE PROCEDURE dbo.spCotizacionDuplicar
    @p_quotation_id INT,
    @p_acting_user_id INT = 1,
    @p_new_quotation_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_quotation_id)
        BEGIN
            SET @p_new_quotation_id = 0;
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización origen no encontrada (ID ', @p_quotation_id, N').');
            SELECT 0 AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, NULL AS internalNumber;
            RETURN;
        END;

        DECLARE @userId INT = @p_acting_user_id;
        IF @userId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @userId)
            SET @userId = NULL;

        DECLARE @branchId INT, @implantId INT;
        SELECT @branchId = branchId, @implantId = implantId FROM dbo.[Quotation] WHERE id = @p_quotation_id;

        DECLARE @internalNumber NVARCHAR(100) = NULL;
        EXEC dbo.spObtenerSiguienteConsecutivo N'QUOTATION', @branchId, @implantId, @internalNumber OUTPUT;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Quotation] (
            internalNumber, [date], clientId, currency, exchangeRate,
            branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, commissionPercentage, chargesAndTaxes,
            totalAmount, userId, state, stateDescription, stateUpdatedAt,
            costoTotal, valorBase, utilidad, comisionTotalPercentage,
            comisionFreelancePercentage, comisionFreelanceValue,
            comisionPropiaPercentage, comisionPropiaValue, comisionUtilidadPercentage,
            destination, startDate, endDate, passenger, paxAdults, paxChildren,
            reservationCode, copyFieldsToProducts, manualDescription
        )
        SELECT
            ISNULL(@internalNumber, N'TEMP'), GETDATE(), clientId, currency, exchangeRate,
            branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, commissionPercentage, chargesAndTaxes,
            totalAmount, ISNULL(@userId, userId), N'NUEVO', CONCAT(N'Copia de cotización #', CAST(@p_quotation_id AS NVARCHAR(20))), GETDATE(),
            costoTotal, valorBase, utilidad, comisionTotalPercentage,
            comisionFreelancePercentage, comisionFreelanceValue,
            comisionPropiaPercentage, comisionPropiaValue, comisionUtilidadPercentage,
            destination, startDate, endDate, passenger, paxAdults, paxChildren,
            reservationCode, copyFieldsToProducts, manualDescription
        FROM dbo.[Quotation]
        WHERE id = @p_quotation_id;

        SET @p_new_quotation_id = SCOPE_IDENTITY();

        IF @internalNumber IS NULL OR @internalNumber = N'TEMP'
        BEGIN
            SET @internalNumber = CAST(@p_new_quotation_id AS NVARCHAR(50));
            UPDATE dbo.[Quotation]
            SET internalNumber = @internalNumber
            WHERE id = @p_new_quotation_id;
        END;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, state, [description], createdAt, userId)
        VALUES (@p_new_quotation_id, N'NUEVO', CONCAT(N'Copia de cotización #', CAST(@p_quotation_id AS NVARCHAR(20))), GETDATE(), @userId);

        -- Duplicar combos
        IF OBJECT_ID('dbo.QuotationCombo', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[QuotationCombo] (quotationId, comboId)
            SELECT @p_new_quotation_id, comboId
            FROM dbo.[QuotationCombo]
            WHERE quotationId = @p_quotation_id;
        END;

        -- Duplicar servicios manuales
        IF OBJECT_ID('dbo.QuotationManualService', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[QuotationManualService] (quotationId, providerName, serviceName, cost, salePrice, utility, createdAt)
            SELECT @p_new_quotation_id, providerName, serviceName, cost, salePrice, utility, GETDATE()
            FROM dbo.[QuotationManualService]
            WHERE quotationId = @p_quotation_id;
        END;

        -- Duplicar productos
        DECLARE @origQpId INT, @newQpId INT;
        DECLARE qp_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_quotation_id;

        OPEN qp_cursor;
        FETCH NEXT FROM qp_cursor INTO @origQpId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.[QuotationProduct] (
                quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                checkInDate, checkOutDate, nights, paxAdults, paxChildren,
                serviceType, destination, reservationCode, sellerCommission,
                ticketPrinterCommission, comboId, mainTaxId, inNationality,
                service, servicios, descripcion, description, passenger,
                providerDueDate, providerInvoice
            )
            SELECT
                @p_new_quotation_id, productId, quantity, price, cost, providerId, prestadoraId,
                checkInDate, checkOutDate, nights, paxAdults, paxChildren,
                serviceType, destination, reservationCode, sellerCommission,
                ticketPrinterCommission, comboId, mainTaxId, inNationality,
                service, servicios, descripcion, description, passenger,
                providerDueDate, providerInvoice
            FROM dbo.[QuotationProduct]
            WHERE id = @origQpId;

            SET @newQpId = SCOPE_IDENTITY();

            -- Duplicar pasajeros
            INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, [name], document)
            SELECT @newQpId, [name], document
            FROM dbo.[QuotationProductPassenger]
            WHERE quotationProductId = @origQpId;

            -- Duplicar impuestos
            INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
            SELECT @newQpId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain
            FROM dbo.[QuotationProductTax]
            WHERE quotationProductId = @origQpId;

            -- Duplicar variables
            INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, [value])
            SELECT @newQpId, masterVariableId, [value]
            FROM dbo.[QuotationProductVariable]
            WHERE quotationProductId = @origQpId;

            -- Duplicar pagos
            INSERT INTO dbo.[QuotationProductPayment] (quotationProductId, amount, paymentMethod, reference, [date], creditCardId, cardNumber, authorizationCode, voucher, expirationDate)
            SELECT @newQpId, amount, paymentMethod, reference, [date], creditCardId, cardNumber, authorizationCode, voucher, expirationDate
            FROM dbo.[QuotationProductPayment]
            WHERE quotationProductId = @origQpId;

            FETCH NEXT FROM qp_cursor INTO @origQpId;
        END;

        CLOSE qp_cursor;
        DEALLOCATE qp_cursor;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización duplicada correctamente con ID ', @p_new_quotation_id);
        SELECT @p_new_quotation_id AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, @internalNumber AS internalNumber;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_new_quotation_id = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, NULL AS internalNumber;
    END CATCH;
END;
GO

-- 2.40. spCotizacionEliminar
IF OBJECT_ID('dbo.spCotizacionEliminar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionEliminar;
GO

CREATE PROCEDURE dbo.spCotizacionEliminar
    @p_id INT,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización no encontrada con ID ', @p_id);
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        DECLARE @internalNumber NVARCHAR(100) = (SELECT internalNumber FROM dbo.[Quotation] WHERE id = @p_id);

        BEGIN TRANSACTION;

        DELETE FROM dbo.[QuotationProductTax] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductVariable] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProductPayment] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
        DELETE FROM dbo.[QuotationProduct] WHERE quotationId = @p_id;
        DELETE FROM dbo.[QuotationCombo] WHERE quotationId = @p_id;
        IF OBJECT_ID('dbo.QuotationManualService', 'U') IS NOT NULL DELETE FROM dbo.[QuotationManualService] WHERE quotationId = @p_id;
        DELETE FROM dbo.[QuotationStateHistory] WHERE quotationId = @p_id;
        DELETE FROM dbo.[Quotation] WHERE id = @p_id;

        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización ', ISNULL(@internalNumber, CAST(@p_id AS NVARCHAR(20))), N' eliminada con éxito.');
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

-- 2.41. spCotizacionActualizarEstadoManual
IF OBJECT_ID('dbo.spCotizacionActualizarEstadoManual', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizarEstadoManual;
GO

CREATE PROCEDURE dbo.spCotizacionActualizarEstadoManual
    @p_id INT,
    @p_state NVARCHAR(50),
    @p_description NVARCHAR(MAX) = NULL,
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
        END;

        UPDATE dbo.[Quotation]
        SET [state] = @p_state,
            [stateDescription] = ISNULL(@p_description, [stateDescription]),
            [stateUpdatedAt] = GETDATE()
        WHERE id = @p_id;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, [state], [description], createdAt, userId)
        VALUES (@p_id, @p_state, ISNULL(@p_description, CONCAT(N'Cambio de estado a ', @p_state)), GETDATE(), @p_acting_user_id);

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Estado de cotización #', @p_id, N' actualizado a ', @p_state);
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO

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

-- ============================================================================
-- SECCIÓN 3: PROCEDIMIENTOS ALMACENADOS DE INTEGRACIÓN ERP (ZEUS / STANDALONE)
-- ============================================================================




`;

    const fullScript = baseContent + '\n\n' + zeusSpsContent + '\n\nPRINT \'Procedimientos almacenados y funciones T-SQL compiladas exitosamente.\';\n';

    fs.writeFileSync(path03, fullScript, 'utf8');
    console.log('✅ SQL/SqlServer/03_Functions_And_SPs.sql ampliado y generado con éxito.');

    try {
        const { syncSqlServerUpdater } = require('./sync_sqlserver_updater');
        syncSqlServerUpdater();
    } catch (sErr) {
        console.warn(' [NOTE] No se pudo sincronizar ActualizadorSERVER.sql automáticamente:', sErr.message);
    }
}

if (require.main === module) {
    generateTsqlFunctionsAndSps();
}

module.exports = { generateTsqlFunctionsAndSps };
