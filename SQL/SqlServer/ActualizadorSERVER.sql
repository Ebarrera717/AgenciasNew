-- ============================================================================
-- AGENCIASNEW - SCRIPT DE ACTUALIZACIÓN IDEMPOTENTE PARA SQL SERVER
-- Generado Automáticamente por deploy/sync_sqlserver_updater.js
-- Fecha de Generación: 2026-10-03T18:25:39.348Z
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- --------------------------------------------------------------------------
-- SECCIÓN 1: ALTERACIÓN Y CREACIÓN IDEMPOTENTE DE TABLAS (DDL)
-- --------------------------------------------------------------------------
-- ============================================================================
-- AGENCIASNEW - ESTRUCTURA COMPLETA DE TABLAS EN MICROSOFT SQL SERVER
-- Archivo: SQL/SqlServer/01_Tables.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Role
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Role' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Role] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Role PRIMARY KEY,
        [name] NVARCHAR(100) NOT NULL CONSTRAINT UQ_Role_Name UNIQUE,
        [description] NVARCHAR(MAX) NULL,
        [permissions] NVARCHAR(MAX) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Role_IsActive DEFAULT 1
    );
END;

-- 2. TicketPrinter
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TicketPrinter' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TicketPrinter] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TicketPrinter PRIMARY KEY,
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_TicketPrinter_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [email] NVARCHAR(150) NULL,
        [isActive] BIT NULL CONSTRAINT DF_TicketPrinter_IsActive DEFAULT 1
    );
END;

-- 3. Branch
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Branch' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Branch] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Branch PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Branch_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [logo] VARBINARY(MAX) NULL,
        [template] VARBINARY(MAX) NULL,
        [templateConfig] NVARCHAR(MAX) NULL,
        [htmlTemplate] NVARCHAR(MAX) NULL,
        [resolutionId] INT NULL,
        [invoiceTemplate] VARBINARY(MAX) NULL,
        [invoiceTemplateConfig] NVARCHAR(MAX) NULL,
        [invoiceHtmlTemplate] NVARCHAR(MAX) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Branch_IsActive DEFAULT 1
    );
END;

-- 4. Implant
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Implant' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Implant] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Implant PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Implant_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [branchId] INT NULL CONSTRAINT FK_Implant_Branch REFERENCES dbo.[Branch]([id]),
        [logo] VARBINARY(MAX) NULL,
        [template] VARBINARY(MAX) NULL,
        [templateConfig] NVARCHAR(MAX) NULL,
        [htmlTemplate] NVARCHAR(MAX) NULL,
        [resolutionId] INT NULL,
        [invoiceTemplate] VARBINARY(MAX) NULL,
        [invoiceTemplateConfig] NVARCHAR(MAX) NULL,
        [invoiceHtmlTemplate] NVARCHAR(MAX) NULL,
        [isActive] BIT NULL CONSTRAINT DF_Implant_IsActive DEFAULT 1
    );
END;

-- 5. User
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[User] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_User PRIMARY KEY,
        [name] NVARCHAR(150) NOT NULL,
        [email] NVARCHAR(150) NOT NULL CONSTRAINT UQ_User_Email UNIQUE,
        [passwordHash] NVARCHAR(255) NOT NULL,
        [resetPasswordToken] NVARCHAR(255) NULL,
        [resetPasswordExpires] DATETIME2 NULL,
        [roleId] INT NOT NULL CONSTRAINT FK_User_Role REFERENCES dbo.[Role]([id]),
        [branchId] INT NULL CONSTRAINT FK_User_Branch REFERENCES dbo.[Branch]([id]),
        [implantId] INT NULL CONSTRAINT FK_User_Implant REFERENCES dbo.[Implant]([id]),
        [ticketPrinterId] INT NULL CONSTRAINT FK_User_TicketPrinter REFERENCES dbo.[TicketPrinter]([id]),
        [canEditReports] BIT NULL CONSTRAINT DF_User_CanEditReports DEFAULT 0,
        [isActive] BIT NOT NULL CONSTRAINT DF_User_IsActive DEFAULT 1
    );

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_User_ResetToken' AND object_id = OBJECT_ID('dbo.[User]'))
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX UQ_User_ResetToken ON dbo.[User]([resetPasswordToken]) WHERE [resetPasswordToken] IS NOT NULL;
    END;
END;

-- 6. Seller
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Seller' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Seller] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Seller PRIMARY KEY,
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_Seller_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [email] NVARCHAR(150) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Seller_IsActive DEFAULT 1
    );
END;

-- 7. Client
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Client' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Client] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Client PRIMARY KEY,
        [name] NVARCHAR(150) NOT NULL,
        [document] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Client_Document UNIQUE,
        [contactInfo] NVARCHAR(MAX) NULL,
        [address] NVARCHAR(255) NULL,
        [mandatoryVariables] NVARCHAR(MAX) NULL,
        [sellerId] INT NULL CONSTRAINT FK_Client_Seller REFERENCES dbo.[Seller]([id]),
        [isActive] BIT NOT NULL CONSTRAINT DF_Client_IsActive DEFAULT 1,
        [creditDays] INT NULL CONSTRAINT DF_Client_CreditDays DEFAULT 0
    );
END;

-- 8. ProviderType
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProviderType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ProviderType] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProviderType PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_ProviderType_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [isAirline] BIT NOT NULL CONSTRAINT DF_ProviderType_IsAirline DEFAULT 0,
        [active] BIT NOT NULL CONSTRAINT DF_ProviderType_Active DEFAULT 1,
        [isActive] BIT NOT NULL CONSTRAINT DF_ProviderType_IsActive DEFAULT 1,
        [createdAt] DATETIME2 NULL CONSTRAINT DF_ProviderType_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NULL CONSTRAINT DF_ProviderType_UpdatedAt DEFAULT GETDATE()
    );
END;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ProviderType') AND name = 'isActive')
BEGIN
    ALTER TABLE dbo.[ProviderType] ADD [isActive] BIT NOT NULL CONSTRAINT DF_ProviderType_IsActive DEFAULT 1;
END;

-- 9. Provider
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Provider' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Provider] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Provider PRIMARY KEY,
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_Provider_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [contactInfo] NVARCHAR(MAX) NULL,
        [commissionConfig] NVARCHAR(MAX) NULL,
        [providerTypeId] INT NULL CONSTRAINT FK_Provider_ProviderType REFERENCES dbo.[ProviderType]([id]),
        [airlineCode] NVARCHAR(10) NULL,
        [sigla] NVARCHAR(10) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Provider_IsActive DEFAULT 1
    );
END;

-- 10. Prestadora
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Prestadora' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Prestadora] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Prestadora PRIMARY KEY,
        [name] NVARCHAR(150) NOT NULL,
        [location] NVARCHAR(150) NULL,
        [category] NVARCHAR(100) NULL,
        [providerId] INT NULL CONSTRAINT FK_Prestadora_Provider REFERENCES dbo.[Provider]([id]),
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_Prestadora_Code UNIQUE,
        [type] NVARCHAR(50) NULL,
        [initials] NVARCHAR(50) NULL,
        [nogds] NVARCHAR(50) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Prestadora_IsActive DEFAULT 1
    );
END;

-- 11. TicketType
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TicketType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TicketType] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TicketType PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_TicketType_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [isActive] BIT NULL CONSTRAINT DF_TicketType_IsActive DEFAULT 1,
        [createdAt] DATETIME2 NULL CONSTRAINT DF_TicketType_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NULL
    );
END;
IF OBJECT_ID('dbo.TicketType', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketType') AND name = 'createdAt') ALTER TABLE dbo.[TicketType] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketType') AND name = 'updatedAt') ALTER TABLE dbo.[TicketType] ADD [updatedAt] DATETIME2 NULL;
END;

-- 12. Product
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Product' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Product] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Product PRIMARY KEY,
        [type] NVARCHAR(50) NOT NULL,
        [description] NVARCHAR(MAX) NOT NULL,
        [basePrice] FLOAT NOT NULL,
        [cost] FLOAT NULL CONSTRAINT DF_Product_Cost DEFAULT 0,
        [billingConcept] NVARCHAR(100) NULL,
        [serviceType] NVARCHAR(100) NULL,
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_Product_Code UNIQUE,
        [airlineItinerary] NVARCHAR(MAX) NULL,
        [classItinerary] NVARCHAR(MAX) NULL,
        [flightItinerary] NVARCHAR(MAX) NULL,
        [ticketTypeId] INT NULL CONSTRAINT FK_Product_TicketType REFERENCES dbo.[TicketType]([id]),
        [mandatoryFields] NVARCHAR(MAX) NULL,
        [taxIds] NVARCHAR(MAX) NULL CONSTRAINT DF_Product_TaxIds DEFAULT '[]',
        [isActive] BIT NOT NULL CONSTRAINT DF_Product_IsActive DEFAULT 1
    );
END;

-- 13. Quotation
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotation' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Quotation] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Quotation PRIMARY KEY,
        [internalNumber] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Quotation_InternalNumber UNIQUE,
        [date] DATETIME2 NOT NULL CONSTRAINT DF_Quotation_Date DEFAULT GETDATE(),
        [clientId] INT NULL,
        [currency] NVARCHAR(10) NULL,
        [exchangeRate] FLOAT NULL,
        [branchId] INT NULL,
        [implantId] INT NULL,
        [sellerId] INT NULL,
        [ticketPrinterId] INT NULL,
        [baseCommissionable] FLOAT NULL CONSTRAINT DF_Quotation_baseCommissionable DEFAULT 0,
        [commissionPercentage] FLOAT NULL CONSTRAINT DF_Quotation_commissionPercentage DEFAULT 0,
        [chargesAndTaxes] FLOAT NULL CONSTRAINT DF_Quotation_chargesAndTaxes DEFAULT 0,
        [totalAmount] FLOAT NULL CONSTRAINT DF_Quotation_totalAmount DEFAULT 0,
        [userId] INT NULL CONSTRAINT FK_Quotation_User REFERENCES dbo.[User]([id]),
        [state] NVARCHAR(25) NULL CONSTRAINT DF_Quotation_State DEFAULT N'Nuevo',
        [stateDescription] NVARCHAR(MAX) NULL,
        [stateUpdatedAt] DATETIME2 NULL,
        [costoTotal] FLOAT NULL CONSTRAINT DF_Quotation_CostoTotal DEFAULT 0,
        [valorBase] FLOAT NULL CONSTRAINT DF_Quotation_ValorBase DEFAULT 0,
        [utilidad] FLOAT NULL CONSTRAINT DF_Quotation_Utilidad DEFAULT 0,
        [comisionTotalPercentage] FLOAT NULL CONSTRAINT DF_Quotation_ComisionTotalPct DEFAULT 0,
        [comisionFreelancePercentage] FLOAT NULL CONSTRAINT DF_Quotation_ComisionFreelancePct DEFAULT 0,
        [comisionFreelanceValue] FLOAT NULL CONSTRAINT DF_Quotation_ComisionFreelanceVal DEFAULT 0,
        [comisionPropiaPercentage] FLOAT NULL CONSTRAINT DF_Quotation_ComisionPropiaPct DEFAULT 0,
        [comisionPropiaValue] FLOAT NULL CONSTRAINT DF_Quotation_ComisionPropiaVal DEFAULT 0,
        [comisionUtilidadPercentage] FLOAT NULL CONSTRAINT DF_Quotation_ComisionUtilidadPct DEFAULT 0,
        [destination] NVARCHAR(255) NULL,
        [startDate] DATETIME2 NULL,
        [endDate] DATETIME2 NULL,
        [passenger] NVARCHAR(255) NULL,
        [paxAdults] INT NULL,
        [paxChildren] INT NULL,
        [reservationCode] NVARCHAR(255) NULL,
        [copyFieldsToProducts] BIT NULL CONSTRAINT DF_Quotation_CopyFields DEFAULT 1,
        [manualDescription] NVARCHAR(MAX) NULL
    );
END;

-- 14. Currency
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Currency' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Currency] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Currency PRIMARY KEY,
        [code] NVARCHAR(10) NOT NULL CONSTRAINT UQ_Currency_Code UNIQUE,
        [name] NVARCHAR(100) NOT NULL,
        [exchangeRate] FLOAT NOT NULL CONSTRAINT DF_Currency_ExchangeRate DEFAULT 1.0,
        [decimals] INT NOT NULL CONSTRAINT DF_Currency_Decimals DEFAULT 2,
        [isActive] BIT NOT NULL CONSTRAINT DF_Currency_IsActive DEFAULT 1
    );
END;

-- 15. SystemParameter
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SystemParameter' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[SystemParameter] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SystemParameter PRIMARY KEY,
        [code] NVARCHAR(100) NOT NULL CONSTRAINT UQ_SystemParameter_Code UNIQUE,
        [name] NVARCHAR(255) NOT NULL,
        [value] NVARCHAR(MAX) NOT NULL
    );
END;

-- 16. Menu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Menu' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Menu] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Menu PRIMARY KEY,
        [code] NVARCHAR(100) NOT NULL CONSTRAINT UQ_Menu_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [parent] INT NULL,
        [action] NVARCHAR(255) NOT NULL,
        [activo] BIT NULL CONSTRAINT DF_Menu_Activo DEFAULT 1
    );
END;

-- 17. Master
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Master] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Master PRIMARY KEY,
        [code] NVARCHAR(100) NOT NULL CONSTRAINT UQ_Master_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [inactivo] BIT NOT NULL CONSTRAINT DF_Master_Inactivo DEFAULT 0
    );
END;

-- 17b. MasterVariable
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MasterVariable' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[MasterVariable] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MasterVariable PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_MasterVariable_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [isForAllClients] BIT NOT NULL CONSTRAINT DF_MasterVariable_IsForAll DEFAULT 0,
        [isActive] BIT NOT NULL CONSTRAINT DF_MasterVariable_IsActive DEFAULT 1
    );
END;

-- 18. ChargeAndTax
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChargeAndTax' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ChargeAndTax] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ChargeAndTax PRIMARY KEY,
        [name] NVARCHAR(150) NOT NULL,
        [type] NVARCHAR(50) NOT NULL,
        [valueType] NVARCHAR(50) NOT NULL,
        [value] FLOAT NOT NULL,
        [isEditable] BIT NOT NULL CONSTRAINT DF_ChargeAndTax_IsEditable DEFAULT 1,
        [code] NVARCHAR(50) NULL CONSTRAINT UQ_ChargeAndTax_Code UNIQUE,
        [orden] INT NULL CONSTRAINT DF_ChargeAndTax_Orden DEFAULT 0,
        [productIds] NVARCHAR(MAX) NULL CONSTRAINT DF_ChargeAndTax_ProductIds DEFAULT '[]',
        [targetTaxId] INT NULL,
        [inNationality] INT NULL CONSTRAINT DF_ChargeAndTax_InNationality DEFAULT 1,
        [isActive] BIT NOT NULL CONSTRAINT DF_ChargeAndTax_IsActive DEFAULT 1
    );
END;
IF OBJECT_ID('dbo.ChargeAndTax', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChargeAndTax') AND name = 'inNationality')
    ALTER TABLE dbo.[ChargeAndTax] ADD [inNationality] INT NULL DEFAULT 1;

-- 19. QuotationProduct
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationProduct' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationProduct] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationProduct PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_QuotationProduct_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [productId] INT NOT NULL CONSTRAINT FK_QuotationProduct_Product REFERENCES dbo.[Product]([id]),
        [quantity] INT NOT NULL,
        [price] FLOAT NOT NULL,
        [cost] FLOAT NULL CONSTRAINT DF_QuotationProduct_Cost DEFAULT 0,
        [providerId] INT NULL CONSTRAINT FK_QuotationProduct_Provider REFERENCES dbo.[Provider]([id]),
        [prestadoraId] INT NULL CONSTRAINT FK_QuotationProduct_Prestadora REFERENCES dbo.[Prestadora]([id]),
        [checkInDate] DATETIME2 NULL,
        [checkOutDate] DATETIME2 NULL,
        [nights] INT NULL,
        [paxAdults] INT NULL,
        [paxChildren] INT NULL,
        [serviceType] NVARCHAR(100) NULL,
        [destination] NVARCHAR(255) NULL,
        [reservationCode] NVARCHAR(100) NULL,
        [sellerCommission] FLOAT NULL,
        [ticketPrinterCommission] FLOAT NULL,
        [comboId] INT NULL,
        [mainTaxId] INT NULL,
        [inNationality] INT NULL CONSTRAINT DF_QuotationProduct_InNationality DEFAULT 1,
        [service] NVARCHAR(MAX) NULL,
        [description] NVARCHAR(MAX) NULL,
        [servicios] NVARCHAR(MAX) NULL,
        [descripcion] NVARCHAR(MAX) NULL,
        [passenger] NVARCHAR(255) NULL,
        [providerDueDate] DATETIME2 NULL,
        [providerInvoice] NVARCHAR(100) NULL
    );
END;

-- 19a. Combo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Combo' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Combo] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Combo PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL,
        [name] NVARCHAR(255) NOT NULL,
        [cupos] INT NULL CONSTRAINT DF_Combo_Cupos DEFAULT 0,
        [currencyId] INT NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_Combo_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NULL CONSTRAINT DF_Combo_UpdatedAt DEFAULT GETDATE(),
        [isActive] BIT NOT NULL CONSTRAINT DF_Combo_IsActive DEFAULT 1
    );
END;

-- 19b. QuotationProductPassenger
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationProductPassenger' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationProductPassenger] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationProductPassenger PRIMARY KEY,
        [quotationProductId] INT NOT NULL CONSTRAINT FK_QuotationProductPassenger_QuotationProduct REFERENCES dbo.[QuotationProduct]([id]) ON DELETE CASCADE,
        [name] NVARCHAR(255) NOT NULL,
        [document] NVARCHAR(50) NOT NULL
    );
END;

-- 19c. QuotationProductTax
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationProductTax' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationProductTax] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationProductTax PRIMARY KEY,
        [quotationProductId] INT NOT NULL CONSTRAINT FK_QuotationProductTax_QuotationProduct REFERENCES dbo.[QuotationProduct]([id]) ON DELETE CASCADE,
        [chargeAndTaxId] INT NOT NULL CONSTRAINT FK_QuotationProductTax_ChargeAndTax REFERENCES dbo.[ChargeAndTax]([id]),
        [valueSnapshot] FLOAT NULL CONSTRAINT DF_QuotationProductTax_valueSnapshot DEFAULT 0,
        [valueTypeSnapshot] NVARCHAR(50) NULL CONSTRAINT DF_QuotationProductTax_valueTypeSnapshot DEFAULT 'PERCENTAGE',
        [explicitAmount] FLOAT NULL,
        [rate] FLOAT NULL CONSTRAINT DF_QuotationProductTax_rate DEFAULT 0,
        [isMain] BIT NULL CONSTRAINT DF_QuotationProductTax_IsMain DEFAULT 0
    );
END;

-- 19d. QuotationProductVariable
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationProductVariable' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationProductVariable] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationProductVariable PRIMARY KEY,
        [quotationProductId] INT NOT NULL CONSTRAINT FK_QuotationProductVariable_QuotationProduct REFERENCES dbo.[QuotationProduct]([id]) ON DELETE CASCADE,
        [masterVariableId] INT NOT NULL CONSTRAINT FK_QuotationProductVariable_MasterVariable REFERENCES dbo.[MasterVariable]([id]),
        [value] NVARCHAR(MAX) NOT NULL
    );
END;

-- 19e. QuotationProductPayment
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationProductPayment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationProductPayment] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationProductPayment PRIMARY KEY,
        [quotationProductId] INT NOT NULL CONSTRAINT FK_QuotationProductPayment_QuotationProduct REFERENCES dbo.[QuotationProduct]([id]) ON DELETE CASCADE,
        [amount] FLOAT NOT NULL,
        [paymentMethod] NVARCHAR(100) NULL,
        [date] DATETIME2 NULL CONSTRAINT DF_QuotationProductPayment_Date DEFAULT GETDATE(),
        [reference] NVARCHAR(255) NULL,
        [creditCardId] INT NULL,
        [cardNumber] NVARCHAR(20) NULL,
        [authorizationCode] NVARCHAR(50) NULL,
        [voucher] NVARCHAR(50) NULL,
        [expirationDate] NVARCHAR(10) NULL
    );
END;

-- 19f. QuotationCombo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationCombo' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationCombo] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationCombo PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_QuotationCombo_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [comboId] INT NOT NULL CONSTRAINT FK_QuotationCombo_Combo REFERENCES dbo.[Combo]([id])
    );
END;

-- 19g. QuotationManualService
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationManualService' AND schema_id = SCHEMA_ID('dbo'))
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

-- 19h. QuotationStateHistory
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationStateHistory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationStateHistory] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationStateHistory PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_QuotationStateHistory_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [state] NVARCHAR(25) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_QuotationStateHistory_CreatedAt DEFAULT GETDATE(),
        [userId] INT NULL CONSTRAINT FK_QuotationStateHistory_User REFERENCES dbo.[User]([id]),
        [metadata] NVARCHAR(MAX) NULL
    );
END;

IF OBJECT_ID('dbo.QuotationStateHistory', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationStateHistory') AND name = 'metadata')
    ALTER TABLE dbo.[QuotationStateHistory] ADD [metadata] NVARCHAR(MAX) NULL;

-- 20. Invoices
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Invoices' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Invoices] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Invoices PRIMARY KEY,
        [internalNumber] NVARCHAR(100) NOT NULL CONSTRAINT UQ_Invoices_InternalNumber UNIQUE,
        [date] DATETIME2 NOT NULL CONSTRAINT DF_Invoices_Date DEFAULT GETDATE(),
        [clientId] INT NOT NULL,
        [currency] NVARCHAR(10) NOT NULL,
        [exchangeRate] FLOAT NOT NULL,
        [branchId] INT NOT NULL,
        [implantId] INT NULL,
        [sellerId] INT NULL,
        [ticketPrinterId] INT NULL,
        [baseCommissionable] FLOAT NOT NULL,
        [commissionPercentage] FLOAT NOT NULL,
        [chargesAndTaxes] FLOAT NOT NULL,
        [totalAmount] FLOAT NOT NULL,
        [userId] INT NULL,
        [state] NVARCHAR(25) NULL CONSTRAINT DF_Invoices_State DEFAULT N'NUEVO',
        [fuente] NVARCHAR(50) NULL,
        [serie] NVARCHAR(50) NULL,
        [consecutivo] NVARCHAR(50) NULL,
        [dueDate] DATETIME2 NULL,
        [isExcelImport] BIT NULL CONSTRAINT DF_Invoices_IsExcelImport DEFAULT 0,
        [zeusInvoiceNumber] NVARCHAR(100) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'isExcelImport')
    ALTER TABLE dbo.[Invoices] ADD [isExcelImport] BIT NULL CONSTRAINT DF_Invoices_IsExcelImport DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'zeusInvoiceNumber')
    ALTER TABLE dbo.[Invoices] ADD [zeusInvoiceNumber] NVARCHAR(100) NULL;

-- 20a. InvoicesProduct
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProduct' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProduct] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProduct PRIMARY KEY,
        [invoiceId] INT NOT NULL,
        [productId] INT NOT NULL,
        [quantity] INT NULL CONSTRAINT DF_InvoicesProduct_Quantity DEFAULT 1,
        [price] FLOAT NULL CONSTRAINT DF_InvoicesProduct_Price DEFAULT 0,
        [cost] FLOAT NULL CONSTRAINT DF_InvoicesProduct_Cost DEFAULT 0,
        [providerId] INT NULL,
        [prestadoraId] INT NULL,
        [checkInDate] DATETIME2 NULL,
        [checkOutDate] DATETIME2 NULL,
        [nights] INT NULL,
        [paxAdults] INT NULL,
        [paxChildren] INT NULL,
        [serviceType] NVARCHAR(255) NULL,
        [destination] NVARCHAR(255) NULL,
        [reservationCode] NVARCHAR(255) NULL,
        [sellerCommission] FLOAT NULL,
        [ticketPrinterCommission] FLOAT NULL,
        [comboId] INT NULL,
        [mainTaxId] INT NULL,
        [inNationality] INT NULL CONSTRAINT DF_InvoicesProduct_InNationality DEFAULT 1,
        [servicios] NVARCHAR(MAX) NULL,
        [descripcion] NVARCHAR(MAX) NULL,
        [itinerary] NVARCHAR(MAX) NULL,
        [class] NVARCHAR(100) NULL,
        [ticketTypeId] INT NULL,
        [airline] NVARCHAR(100) NULL,
        [ticketCode] NVARCHAR(255) NULL,
        [providerDueDate] DATETIME2 NULL,
        [providerInvoice] NVARCHAR(100) NULL
    );
END;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'price')
BEGIN
    ALTER TABLE dbo.[InvoicesProduct] ALTER COLUMN [price] FLOAT NULL;
END;
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'DF_InvoicesProduct_Price')
BEGIN
    ALTER TABLE dbo.[InvoicesProduct] ADD CONSTRAINT DF_InvoicesProduct_Price DEFAULT 0 FOR [price];
END;
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'quantity')
BEGIN
    ALTER TABLE dbo.[InvoicesProduct] ALTER COLUMN [quantity] INT NULL;
END;
IF NOT EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'DF_InvoicesProduct_Quantity')
BEGIN
    ALTER TABLE dbo.[InvoicesProduct] ADD CONSTRAINT DF_InvoicesProduct_Quantity DEFAULT 1 FOR [quantity];
END;

-- 20b. InvoicesProductTax
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductTax' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductTax] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductTax PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [chargeAndTaxId] INT NOT NULL,
        [valueSnapshot] FLOAT NULL CONSTRAINT DF_InvoicesProductTax_valueSnapshot DEFAULT 0,
        [valueTypeSnapshot] NVARCHAR(50) NULL CONSTRAINT DF_InvoicesProductTax_valueTypeSnapshot DEFAULT 'PERCENTAGE',
        [explicitAmount] FLOAT NULL,
        [rate] FLOAT NULL CONSTRAINT DF_InvoicesProductTax_rate DEFAULT 0,
        [isMain] BIT NULL CONSTRAINT DF_InvoicesProductTax_IsMain DEFAULT 0
    );
END;

-- 20c. InvoicesProductPasenger
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductPasenger' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductPasenger] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductPasenger PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [name] NVARCHAR(255) NOT NULL,
        [document] NVARCHAR(255) NOT NULL
    );
END;

-- 20d. InvoicesProductVariable
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductVariable' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductVariable] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductVariable PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [masterVariableId] INT NOT NULL,
        [value] NVARCHAR(255) NOT NULL
    );
END;

-- 20e. InvoicesProductPayment
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductPayment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductPayment] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductPayment PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [amount] FLOAT NOT NULL,
        [paymentMethod] NVARCHAR(100) NULL,
        [date] DATETIME2 NULL CONSTRAINT DF_InvoicesProductPayment_Date DEFAULT GETDATE(),
        [reference] NVARCHAR(255) NULL
    );
END;

-- 20f. InvoicesProductItinerary
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductItinerary' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductItinerary] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductItinerary PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [orden] INT NULL,
        [origin] NVARCHAR(255) NOT NULL,
        [destination] NVARCHAR(255) NOT NULL,
        [class] NVARCHAR(255) NULL,
        [checkInDate] DATETIME2 NULL,
        [checkOutDate] DATETIME2 NULL,
        [terminal] NVARCHAR(255) NULL,
        [prestadoraCode] NVARCHAR(255) NULL,
        [farebasis] NVARCHAR(255) NULL,
        [Numflight] NVARCHAR(25) NULL,
        [Typeflight] NVARCHAR(1) NULL,
        [amount] FLOAT NULL,
        [co2] FLOAT NULL
    );
END;

-- 20g. InvoicesProductCombo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductCombo' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductCombo] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductCombo PRIMARY KEY,
        [invoiceId] INT NOT NULL,
        [comboId] INT NOT NULL
    );
END;

-- 20g_att. Attachment
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attachment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Attachment] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Attachment PRIMARY KEY,
        [quotationId] INT NOT NULL CONSTRAINT FK_Attachment_Quotation REFERENCES dbo.[Quotation]([id]) ON DELETE CASCADE,
        [fileName] NVARCHAR(255) NOT NULL,
        [fileType] NVARCHAR(100) NOT NULL,
        [fileSize] INT NOT NULL,
        [fileContent] VARBINARY(MAX) NOT NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_Attachment_createdAt DEFAULT GETDATE()
    );
END;


-- 20h. TraceabilitySession
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilitySession' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilitySession] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilitySession PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_TraceabilitySession_Code UNIQUE,
        [userId] INT NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilitySession_Origin DEFAULT 'WEB',
        [module] NVARCHAR(100) NOT NULL,
        [screen] NVARCHAR(100) NULL,
        [action] NVARCHAR(100) NOT NULL,
        [process] NVARCHAR(100) NULL,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceabilitySession_Status DEFAULT 'IN_PROGRESS',
        [totalDurationMs] FLOAT NULL CONSTRAINT DF_TraceabilitySession_TotalDurationMs DEFAULT 0,
        [errorMessage] NVARCHAR(MAX) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilitySession_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilitySession_UpdatedAt DEFAULT GETDATE()
    );
END;

-- 20i. TraceabilityLog
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilityLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilityLog] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilityLog PRIMARY KEY,
        [sessionId] INT NOT NULL,
        [code] NVARCHAR(50) NOT NULL,
        [userId] INT NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilityLog_Origin DEFAULT 'WEB',
        [eventType] NVARCHAR(50) NOT NULL,
        [stepName] NVARCHAR(255) NOT NULL,
        [spName] NVARCHAR(255) NULL,
        [endpoint] NVARCHAR(500) NULL,
        [durationMs] FLOAT NULL CONSTRAINT DF_TraceabilityLog_DurationMs DEFAULT 0,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceabilityLog_Status DEFAULT 'SUCCESS',
        [inputData] NVARCHAR(MAX) NULL,
        [outputData] NVARCHAR(MAX) NULL,
        [techMessage] NVARCHAR(MAX) NULL,
        [functionalMessage] NVARCHAR(MAX) NULL,
        [stackTrace] NVARCHAR(MAX) NULL,
        [affectedId] NVARCHAR(255) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilityLog_CreatedAt DEFAULT GETDATE()
    );
END;

-- 21. Countries
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Countries' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Countries] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Countries PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Countries_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [dane] NVARCHAR(50) NULL,
        [region] NVARCHAR(100) NULL,
        [prefix] NVARCHAR(20) NULL,
        [currencyId] INT NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Countries_IsActive DEFAULT 1
    );
END;

-- 22. Cities
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cities] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cities PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Cities_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [countriesId] INT NULL CONSTRAINT FK_Cities_Countries REFERENCES dbo.[Countries]([id]),
        [statecode] NVARCHAR(50) NULL,
        [iata] NVARCHAR(20) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Cities_IsActive DEFAULT 1
    );
END;

-- 23. Airports
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Airports' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Airports] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Airports PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Airports_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [citiesId] INT NULL CONSTRAINT FK_Airports_Cities REFERENCES dbo.[Cities]([id]),
        [isActive] BIT NOT NULL CONSTRAINT DF_Airports_IsActive DEFAULT 1
    );
END;

-- 24. CreditCard
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CreditCard' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CreditCard] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CreditCard PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_CreditCard_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [type] NVARCHAR(50) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_CreditCard_IsActive DEFAULT 1
    );
END;

-- 25. MasterVariable
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MasterVariable' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[MasterVariable] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MasterVariable PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_MasterVariable_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [isForAllClients] BIT NOT NULL CONSTRAINT DF_MasterVariable_IsForAll DEFAULT 0,
        [isActive] BIT NOT NULL CONSTRAINT DF_MasterVariable_IsActive DEFAULT 1
    );
END;

-- 26. Resolution
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Resolution' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Resolution] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Resolution PRIMARY KEY,
        [code] NVARCHAR(50) NULL,
        [resolutionNumber] NVARCHAR(100) NOT NULL,
        [resolutionDate] DATETIME2 NULL,
        [prefix] NVARCHAR(20) NULL,
        [fromNumber] INT NULL,
        [toNumber] INT NULL,
        [currentNumber] INT NULL,
        [validFrom] DATETIME2 NULL,
        [validTo] DATETIME2 NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Resolution_IsActive DEFAULT 1
    );
END;

-- 27. DocumentResolution
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DocumentResolution' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[DocumentResolution] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DocumentResolution PRIMARY KEY,
        [documentType] NVARCHAR(50) NOT NULL,
        [resolutionNumber] NVARCHAR(100) NOT NULL,
        [prefix] NVARCHAR(20) NULL,
        [fromNumber] INT NULL,
        [toNumber] INT NULL,
        [currentNumber] INT NULL,
        [validFrom] DATETIME2 NULL,
        [validTo] DATETIME2 NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_DocumentResolution_IsActive DEFAULT 1
    );
END;

-- 28. SysConsecutivo
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SysConsecutivo' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[SysConsecutivo] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SysConsecutivo PRIMARY KEY,
        [codigo] NVARCHAR(50) NOT NULL,
        [nombre] NVARCHAR(150) NULL,
        [branchId] INT NULL,
        [implantId] INT NULL,
        [fuente] NVARCHAR(50) NULL,
        [serie] NVARCHAR(50) NULL,
        [consecutivo] INT NOT NULL CONSTRAINT DF_SysConsecutivo_Num DEFAULT 1,
        [isActive] BIT NOT NULL CONSTRAINT DF_SysConsecutivo_IsActive DEFAULT 1
    );
END;

-- 29. TransactionConsecutive
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TransactionConsecutive' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TransactionConsecutive] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TransactionConsecutive PRIMARY KEY,
        [transactionType] NVARCHAR(50) NOT NULL,
        [description] NVARCHAR(150) NULL,
        [prefix] NVARCHAR(20) NULL,
        [initialNumber] INT NOT NULL CONSTRAINT DF_TxCons_Init DEFAULT 1,
        [currentNumber] INT NOT NULL CONSTRAINT DF_TxCons_Curr DEFAULT 1,
        [branchId] INT NULL,
        [implantId] INT NULL,
        [padding] INT NULL CONSTRAINT DF_TxCons_Padding DEFAULT 4,
        [isActive] BIT NOT NULL CONSTRAINT DF_TransactionConsecutive_IsActive DEFAULT 1,
        [updatedAt] DATETIME2 NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransactionConsecutive') AND name = 'padding')
BEGIN
    ALTER TABLE dbo.[TransactionConsecutive] ADD [padding] INT NULL CONSTRAINT DF_TxCons_Padding DEFAULT 4;
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransactionConsecutive') AND name = 'updatedAt')
BEGIN
    ALTER TABLE dbo.[TransactionConsecutive] ADD [updatedAt] DATETIME2 NULL;
END;

-- 29.1 TraceabilitySession
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilitySession' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilitySession] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilitySession PRIMARY KEY,
        [code] NVARCHAR(100) NOT NULL,
        [userId] INT NULL,
        [userName] NVARCHAR(150) NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceSession_Origin DEFAULT N'WEB',
        [module] NVARCHAR(100) NOT NULL,
        [screen] NVARCHAR(100) NULL,
        [action] NVARCHAR(100) NOT NULL,
        [process] NVARCHAR(250) NULL,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceSession_Status DEFAULT N'IN_PROGRESS',
        [totalDurationMs] FLOAT NOT NULL CONSTRAINT DF_TraceSession_Dur DEFAULT 0,
        [errorMessage] NVARCHAR(MAX) NULL,
        [eventCount] INT NOT NULL CONSTRAINT DF_TraceSession_Events DEFAULT 1,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceSession_Created DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceSession_Updated DEFAULT GETDATE()
    );
END;

-- 29.2 TraceabilityLog
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilityLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilityLog] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilityLog PRIMARY KEY,
        [sessionId] INT NULL,
        [code] NVARCHAR(100) NOT NULL,
        [userId] INT NULL,
        [userName] NVARCHAR(150) NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceLog_Origin DEFAULT N'WEB',
        [eventType] NVARCHAR(50) NOT NULL,
        [stepName] NVARCHAR(250) NOT NULL,
        [spName] NVARCHAR(150) NULL,
        [endpoint] NVARCHAR(250) NULL,
        [durationMs] FLOAT NOT NULL CONSTRAINT DF_TraceLog_Dur DEFAULT 0,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceLog_Status DEFAULT N'SUCCESS',
        [inputData] NVARCHAR(MAX) NULL,
        [outputData] NVARCHAR(MAX) NULL,
        [techMessage] NVARCHAR(MAX) NULL,
        [functionalMessage] NVARCHAR(MAX) NULL,
        [stackTrace] NVARCHAR(MAX) NULL,
        [affectedId] NVARCHAR(100) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceLog_Created DEFAULT GETDATE()
    );
END;

-- 30. Equivalence
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Equivalence' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Equivalence] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Equivalence PRIMARY KEY,
        [category] NVARCHAR(50) NOT NULL,
        [sourceCode] NVARCHAR(50) NOT NULL,
        [targetCode] NVARCHAR(50) NOT NULL,
        [description] NVARCHAR(150) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_Equivalence_IsActive DEFAULT 1
    );
END;

-- 31. ExecutionProcedure
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ExecutionProcedure' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ExecutionProcedure] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ExecutionProcedure PRIMARY KEY,
        [name] NVARCHAR(150) NOT NULL,
        [spName] NVARCHAR(150) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [parameters] NVARCHAR(MAX) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_ExecutionProcedure_IsActive DEFAULT 1
    );
END;

-- 32. ExecutionPreset
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ExecutionPreset' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ExecutionPreset] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ExecutionPreset PRIMARY KEY,
        [procedureId] INT NOT NULL CONSTRAINT FK_ExecutionPreset_Procedure REFERENCES dbo.[ExecutionProcedure]([id]),
        [name] NVARCHAR(150) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [filterValues] NVARCHAR(MAX) NULL,
        [filterConfig] NVARCHAR(MAX) NULL,
        [columnConfigs] NVARCHAR(MAX) NULL,
        [selectedTotals] NVARCHAR(MAX) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_ExecutionPreset_IsActive DEFAULT 1
    );
END;

-- 33. Payment
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Payment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Payment] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Payment PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_Payment_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [isCash] BIT NOT NULL CONSTRAINT DF_Payment_IsCash DEFAULT 0,
        [isCredit] BIT NOT NULL CONSTRAINT DF_Payment_IsCredit DEFAULT 0,
        [isActive] BIT NOT NULL CONSTRAINT DF_Payment_IsActive DEFAULT 1
    );
END;

-- 34. QuotationState
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuotationState' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[QuotationState] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_QuotationState PRIMARY KEY,
        [code] NVARCHAR(50) NOT NULL CONSTRAINT UQ_QuotationState_Code UNIQUE,
        [name] NVARCHAR(150) NOT NULL,
        [color] NVARCHAR(50) NULL,
        [isActive] BIT NOT NULL CONSTRAINT DF_QuotationState_IsActive DEFAULT 1,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_QuotationState_CreatedAt DEFAULT GETDATE()
    );
END;

-- 35. PreQuotation
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PreQuotation' AND schema_id = SCHEMA_ID('dbo'))
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

-- 36. PreQuotationStateHistory
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PreQuotationStateHistory' AND schema_id = SCHEMA_ID('dbo'))
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

-- 37. TraceabilitySession
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilitySession' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilitySession] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilitySession PRIMARY KEY,
        [code] NVARCHAR(100) NOT NULL CONSTRAINT UQ_TraceabilitySession_Code UNIQUE,
        [userId] INT NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilitySession_Origin DEFAULT N'WEB',
        [module] NVARCHAR(100) NOT NULL,
        [screen] NVARCHAR(150) NULL,
        [action] NVARCHAR(150) NOT NULL,
        [process] NVARCHAR(150) NULL,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceabilitySession_Status DEFAULT N'IN_PROGRESS',
        [totalDurationMs] FLOAT NULL CONSTRAINT DF_TraceabilitySession_TotalDuration DEFAULT 0,
        [errorMessage] NVARCHAR(MAX) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilitySession_CreatedAt DEFAULT GETDATE(),
        [updatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilitySession_UpdatedAt DEFAULT GETDATE()
    );
END;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TraceabilitySession') AND name = 'origin')
BEGIN
    ALTER TABLE dbo.[TraceabilitySession] ADD [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilitySession_Origin DEFAULT N'WEB';
END;

-- 38. TraceabilityLog
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TraceabilityLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TraceabilityLog] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TraceabilityLog PRIMARY KEY,
        [sessionId] INT NOT NULL,
        [code] NVARCHAR(100) NOT NULL,
        [userId] INT NULL,
        [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilityLog_Origin DEFAULT N'WEB',
        [eventType] NVARCHAR(100) NOT NULL,
        [stepName] NVARCHAR(200) NOT NULL,
        [spName] NVARCHAR(200) NULL,
        [endpoint] NVARCHAR(255) NULL,
        [durationMs] FLOAT NULL CONSTRAINT DF_TraceabilityLog_Duration DEFAULT 0,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT DF_TraceabilityLog_Status DEFAULT N'SUCCESS',
        [inputData] NVARCHAR(MAX) NULL,
        [outputData] NVARCHAR(MAX) NULL,
        [techMessage] NVARCHAR(MAX) NULL,
        [functionalMessage] NVARCHAR(MAX) NULL,
        [stackTrace] NVARCHAR(MAX) NULL,
        [affectedId] NVARCHAR(100) NULL,
        [createdAt] DATETIME2 NOT NULL CONSTRAINT DF_TraceabilityLog_CreatedAt DEFAULT GETDATE()
    );
END;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TraceabilityLog') AND name = 'origin')
BEGIN
    ALTER TABLE dbo.[TraceabilityLog] ADD [origin] NVARCHAR(50) NULL CONSTRAINT DF_TraceabilityLog_Origin DEFAULT N'WEB';
END;

-- 39. ImpRet
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ImpRet' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ImpRet] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ImpRet PRIMARY KEY,
        [cd_codigo] VARCHAR(20) NOT NULL CONSTRAINT UQ_ImpRet_Code UNIQUE,
        [ds_nombre] VARCHAR(250) NULL,
        [cd_cuenta] VARCHAR(20) NULL,
        [am_porcentaje] NUMERIC(5,2) NULL CONSTRAINT DF_ImpRet_Porcentaje DEFAULT 0,
        [in_tipo] CHAR(1) NULL CONSTRAINT DF_ImpRet_Tipo DEFAULT 'I',
        [Id_cargo_dep] INT NULL,
        [bl_IVA] BIT NULL CONSTRAINT DF_ImpRet_BlIva DEFAULT 0
    );
    IF NOT EXISTS (SELECT 1 FROM dbo.[ImpRet] WHERE id = 1)
    BEGIN
        SET IDENTITY_INSERT dbo.[ImpRet] ON;
        INSERT INTO dbo.[ImpRet] (id, cd_codigo, ds_nombre, cd_cuenta, am_porcentaje, in_tipo, bl_IVA)
        VALUES (1, '01', 'IVA 19%', '240805', 19.00, 'I', 1);
        SET IDENTITY_INSERT dbo.[ImpRet] OFF;
    END;
END;

-- 40. CargosDesc
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CargosDesc' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CargosDesc] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CargosDesc PRIMARY KEY,
        [cd_codigo] VARCHAR(20) NOT NULL CONSTRAINT UQ_CargosDesc_Code UNIQUE,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

-- 41. parametros
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'parametros' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[parametros] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_parametros PRIMARY KEY,
        [nombre] VARCHAR(250) NULL,
        [valor] VARCHAR(MAX) NULL
    );
    IF NOT EXISTS (SELECT 1 FROM dbo.[parametros] WHERE id = 33)
    BEGIN
        SET IDENTITY_INSERT dbo.[parametros] ON;
        INSERT INTO dbo.[parametros] (id, nombre, valor) VALUES (33, 'NumeroDecimales', '2');
        SET IDENTITY_INSERT dbo.[parametros] OFF;
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.[parametros] WHERE id = 326)
    BEGIN
        SET IDENTITY_INSERT dbo.[parametros] ON;
        INSERT INTO dbo.[parametros] (id, nombre, valor) VALUES (326, 'CalcularAutoValoresItemFac', 'N');
        SET IDENTITY_INSERT dbo.[parametros] OFF;
    END;
END;

-- 42. Parametr
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Parametr' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Parametr] (
        [PARAMETRO] VARCHAR(50) NOT NULL CONSTRAINT PK_Parametr PRIMARY KEY,
        [VALOPAR] VARCHAR(250) NULL
    );
END;



-- ============================================================================
-- TABLAS MAESTRAS Y COMPLEMENTARIAS DE ZEUS ERP (AUTOGENERADAS POR AUDITORÍA)
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Monedas_IATA' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Monedas_IATA] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Monedas_IATA PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NOT NULL CONSTRAINT UQ_Monedas_IATA_Code UNIQUE,
        [ds_nombre] VARCHAR(250) NULL,
        [am_tasa_cambio] MONEY NULL DEFAULT 1
    );
    IF NOT EXISTS (SELECT 1 FROM dbo.[Monedas_IATA] WHERE cd_codigo = 'COP')
        INSERT INTO dbo.[Monedas_IATA] (cd_codigo, ds_nombre, am_tasa_cambio) VALUES ('COP', 'PESOS COLOMBIANOS', 1);
    IF NOT EXISTS (SELECT 1 FROM dbo.[Monedas_IATA] WHERE cd_codigo = 'USD')
        INSERT INTO dbo.[Monedas_IATA] (cd_codigo, ds_nombre, am_tasa_cambio) VALUES ('USD', 'DOLARES AMERICANOS', 4000);
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sucursales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Sucursales] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sucursales PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NOT NULL CONSTRAINT UQ_Sucursales_Code UNIQUE,
        [ds_nombre] VARCHAR(250) NULL,
        [cd_bu] VARCHAR(25) NULL
    );
    IF NOT EXISTS (SELECT 1 FROM dbo.[Sucursales] WHERE id = 1)
        INSERT INTO dbo.[Sucursales] (cd_codigo, ds_nombre, cd_bu) VALUES ('01', 'PRINCIPAL', 'MAIN');
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Implantes' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Implantes] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Implantes PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NOT NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [id_sucursal] INT NULL,
        [cd_bu] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FormasPago' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[FormasPago] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FormasPago PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NOT NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TarjetasCredito' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TarjetasCredito] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TarjetasCredito PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NOT NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tarjetascredito' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[tarjetascredito] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TiposDocumento' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TiposDocumento] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Entidades' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Entidades] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tiqueteadores' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Tiqueteadores] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [id_tipoventa] INT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TiposServicios' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TiposServicios] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [cd_cuenta] VARCHAR(20) NULL
    );
END;

IF OBJECT_ID('dbo.TiposServicios', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TiposServicios') AND name = 'cd_cuenta')
        ALTER TABLE dbo.[TiposServicios] ADD [cd_cuenta] VARCHAR(20) NULL;
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConceptoFacturacion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConceptoFacturacion] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tiposServicio_asignados' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[tiposServicio_asignados] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [id_ConceptoFacturacion] INT NULL,
        [id_TipoServicio] INT NULL,
        [id_TiposServicios] INT NULL
    );
END;

IF OBJECT_ID('dbo.tiposServicio_asignados', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tiposServicio_asignados') AND name = 'id_TipoServicio') 
        ALTER TABLE dbo.tiposServicio_asignados ADD id_TipoServicio INT NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tiposServicio_asignados') AND name = 'id_TiposServicios') 
        ALTER TABLE dbo.tiposServicio_asignados ADD id_TiposServicios INT NULL;
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoProveedores' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TipoProveedores] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TipoVenta' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TipoVenta] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Hoteles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Hoteles] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CLIENTES' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CLIENTES] (
        [IDCLIENTE] VARCHAR(25) NOT NULL PRIMARY KEY,
        [RAZONCIAL] VARCHAR(250) NULL,
        [DIRECCION] VARCHAR(250) NULL,
        [TELEFONO] VARCHAR(50) NULL,
        [CIUDAD] VARCHAR(100) NULL,
        [EMAIL] VARCHAR(150) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PROVEEDORES' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[PROVEEDORES] (
        [IDPROVE] VARCHAR(25) NOT NULL PRIMARY KEY,
        [RAZONCIAL] VARCHAR(250) NULL,
        [CODICTA] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MAEVENDE' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[MAEVENDE] (
        [IDVENDE] VARCHAR(25) NOT NULL PRIMARY KEY,
        [NOMBVENDE] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TERCEROS' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TERCEROS] (
        [IDTERCERO] VARCHAR(25) NOT NULL PRIMARY KEY,
        [RAZONCIAL] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Terceros' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Terceros] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FACTURAS' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[FACTURAS] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_fuente] VARCHAR(10) NULL,
        [cd_serie] VARCHAR(10) NULL,
        [cd_consecutivo] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FUENTES' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[FUENTES] (
        [cd_fuente] VARCHAR(10) NOT NULL PRIMARY KEY,
        [ds_fuente] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Fac_Factura' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Fac_Factura] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_fuente] VARCHAR(10) NULL,
        [cd_serie] VARCHAR(10) NULL,
        [cd_consecutivo] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'fac_factura' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[fac_factura] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_fuente] VARCHAR(10) NULL,
        [cd_serie] VARCHAR(10) NULL,
        [cd_consecutivo] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'resoluciones' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[resoluciones] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ds_num_resolucion] VARCHAR(50) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NotasAerolinea' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[NotasAerolinea] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(25) NULL,
        [ds_nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CargosAsignados' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CargosAsignados] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CargosAsignados_ConceptoFac' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CargosAsignados_ConceptoFac] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CargosAsignados_Configuracion_ImpCategoriaFiscal' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CargosAsignados_Configuracion_ImpCategoriaFiscal] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categorias' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Categorias] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cierres' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cierres] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cliente_ConfiguracionVariables' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cliente_ConfiguracionVariables] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cliente_FP_AirPlus' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cliente_FP_AirPlus] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Clientes_Descuentos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Clientes_Descuentos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ColaImpresion_Documentos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ColaImpresion_Documentos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracioFacturaTarjetasPropias_NumerosTC' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracioFacturaTarjetasPropias_NumerosTC] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracionClientesConceptos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracionClientesConceptos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracionConceptosAutoClientes' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracionConceptosAutoClientes] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracionConceptosAutoClientes_Conceptos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracionConceptosAutoClientes_Conceptos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracionTransacciones_Adicionales' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracionTransacciones_Adicionales] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConfiguracionVariables' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ConfiguracionVariables] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Configuracion_ImpCategoriaFiscal' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Configuracion_ImpCategoriaFiscal] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Configuracion_remisiones' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Configuracion_remisiones] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cotizacion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cotizacion] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionCargos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionCargos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionImpuestos' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionImpuestos] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionServicios' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionServicios] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionServiciosFormasPago' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionServiciosFormasPago] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionServicios_PaxAdicional' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionServicios_PaxAdicional] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CotizacionServicios_TipoProv' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[CotizacionServicios_TipoProv] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cotizacion_facturas' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Cotizacion_facturas] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EquivalencesInterfaces' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[EquivalencesInterfaces] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Etapas' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Etapas] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Fac_RecibosCaja' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Fac_RecibosCaja] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Fac_Servicios' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Fac_Servicios] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Fac_Servicios_TiposFacturacionHoteles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Fac_Tao' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Fac_Tao] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'fac_TAO' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[fac_TAO] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GREmpresarial' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[GREmpresarial] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ImpAsignados' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ImpAsignados] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ImpAsignados_ConceptoFac' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ImpAsignados_ConceptoFac] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ImpAsignados_Configuracion_ImpCategoriaFiscal' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ImpAsignados_Configuracion_ImpCategoriaFiscal] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Impuestos_bu' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Impuestos_bu] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Interfaces' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Interfaces] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InterfaceExtractParam' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InterfaceExtractParam] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [interfaceId] INT NOT NULL,
        [fieldCode] VARCHAR(50) NOT NULL,
        [fieldName] VARCHAR(100) NOT NULL,
        [prefix] VARCHAR(100) NOT NULL,
        [delimiter] VARCHAR(20) NULL DEFAULT '-',
        [startPosition] INT NULL DEFAULT 0,
        [length] INT NULL DEFAULT 0,
        [isActive] BIT NOT NULL DEFAULT 1,
        [createdAt] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReservaGDS_Detalles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ReservaGDS_Detalles] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReservaGDS_Servicios' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ReservaGDS_Servicios] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReservaGDS_VariableAdicional' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ReservaGDS_VariableAdicional] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReservasGDS' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[ReservasGDS] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Segmento' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Segmento] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TiposFacturacionHoteles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[TiposFacturacionHoteles] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tiquetes' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Tiquetes] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuario' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Usuario] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDatosMaestro' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDatosMaestro] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDefinicion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDefinicion] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDefinicionMaestro' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDefinicionMaestro] (
        [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [cd_codigo] VARCHAR(50) NULL,
        [ds_nombre] VARCHAR(250) NULL,
        [created_at] DATETIME2 NULL DEFAULT GETDATE()
    );
END;




-- ============================================================================
-- GARANTÍA DE COLUMNAS USADAS EN SPs T-SQL
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_consecutivo')
    ALTER TABLE dbo.[Cotizacion] ADD [cd_consecutivo] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[Cotizacion] ADD [cd_Cotizacion] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_consecutivo')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_consecutivo] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_Cotizacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_consecutivo_anul')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_consecutivo_anul] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_Consecutivo_VariablesAdicionales')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_Consecutivo_VariablesAdicionales] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[CotizacionCargos] ADD [cd_Cotizacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionCargos] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'id_cargosdesc')
    ALTER TABLE dbo.[CotizacionCargos] ADD [id_cargosdesc] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [cd_Cotizacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'id_impret')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [id_impret] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [cd_Cotizacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'cd_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [cd_CotizacionServicios] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'Id_Cotizacion')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [Id_Cotizacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'id_FormasPago')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [id_FormasPago] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'cd_codigo')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [cd_codigo] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_FPnm')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_FPnm] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'bl_FPrepresenta')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [bl_FPrepresenta] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'id_TarjetasCredito')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [id_TarjetasCredito] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'cd_tccode')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [cd_tccode] NCHAR(10) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_tcnumber')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_tcnumber] CHAR(16) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_tcvoucher')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_tcvoucher] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'cd_idbanco')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [cd_idbanco] CHAR(3) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_cheque')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_cheque] VARCHAR(30) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_referencia')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_referencia] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'am_valor')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [am_valor] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_tcexp')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_tcexp] VARCHAR(7) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_plaza')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_plaza] CHAR(3) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_Poliza')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_Poliza] VARCHAR(20) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_PolAnexo')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_PolAnexo] VARCHAR(20) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'am_valor_ME')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [am_valor_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'ds_tcautorizacion')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [ds_tcautorizacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServiciosFormasPago') AND name = 'in_tccuotas')
    ALTER TABLE dbo.[CotizacionServiciosFormasPago] ADD [in_tccuotas] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'Id_Cotizacion')
    ALTER TABLE dbo.[Cotizacion] ADD [Id_Cotizacion] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Id_Cotizacion')
    ALTER TABLE dbo.[CotizacionServicios] ADD [Id_Cotizacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Id_Cotizacion_Solicitud')
    ALTER TABLE dbo.[CotizacionServicios] ADD [Id_Cotizacion_Solicitud] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_proveedores')
    ALTER TABLE dbo.[CotizacionServicios] ADD [ds_proveedores] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_proveedores')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_proveedores] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'ds_cargonm')
    ALTER TABLE dbo.[CotizacionCargos] ADD [ds_cargonm] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'bl_noshow')
    ALTER TABLE dbo.[CotizacionCargos] ADD [bl_noshow] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_contado')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_contado] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_credito')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_credito] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_valor')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_valor] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_contado_ME')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_contado_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_credito_ME')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_credito_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'am_valor_ME')
    ALTER TABLE dbo.[CotizacionCargos] ADD [am_valor_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'id_CotizacionCargos')
    ALTER TABLE dbo.[CotizacionCargos] ADD [id_CotizacionCargos] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'cd_CotizacionCargos')
    ALTER TABLE dbo.[CotizacionCargos] ADD [cd_CotizacionCargos] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionCargos') AND name = 'cd_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionCargos] ADD [cd_CotizacionServicios] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'id_CotizacionCargos')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [id_CotizacionCargos] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'ds_Impas')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [ds_Impas] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'cd_impcta')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [cd_impcta] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_porcentaje')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_porcentaje] NUMERIC(5,2) NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'bl_contabilizar')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [bl_contabilizar] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_contado')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_contado] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_credito')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_credito] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_valor')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_valor] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_contado_ME')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_contado_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_credito_ME')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_credito_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'am_valor_ME')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [am_valor_ME] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'cd_CotizacionImpuestos')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [cd_CotizacionImpuestos] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'cd_CotizacionCargos')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [cd_CotizacionCargos] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionImpuestos') AND name = 'cd_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionImpuestos] ADD [cd_CotizacionServicios] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [cd_Cotizacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'cd_CotizacionServicios')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [cd_CotizacionServicios] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'cd_TiposFacturacionHoteles')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [cd_TiposFacturacionHoteles] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'cd_cargosdesc')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [cd_cargosdesc] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'id_Fac_Servicios')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [id_Fac_Servicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'Id_TiposFacturacionHoteles')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [Id_TiposFacturacionHoteles] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'in_cantidad')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [in_cantidad] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'am_valor')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [am_valor] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'am_contado')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [am_contado] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'am_credito')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [am_credito] MONEY NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'Id_Cotizacion_Solicitud')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [Id_Cotizacion_Solicitud] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'id_cargosdesc')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [id_cargosdesc] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') AND name = 'ds_cargonm')
    ALTER TABLE dbo.[Fac_Servicios_TiposFacturacionHoteles] ADD [ds_cargonm] VARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'Id_Cotizacion')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [Id_Cotizacion] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [id_CotizacionServicios] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'Id_Cotizacion')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [Id_Cotizacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'ds_proveedores')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [ds_proveedores] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'cd_proveedores')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [cd_proveedores] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'id_tipoproveedores')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [id_tipoproveedores] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'cd_TipoProveedores')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [cd_TipoProveedores] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_TipoProv') AND name = 'ds_TipoProveedores')
    ALTER TABLE dbo.[CotizacionServicios_TipoProv] ADD [ds_TipoProveedores] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion_facturas') AND name = 'cd_Cotizacion')
    ALTER TABLE dbo.[Cotizacion_facturas] ADD [cd_Cotizacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion_facturas') AND name = 'id_CotizacionServicios')
    ALTER TABLE dbo.[Cotizacion_facturas] ADD [id_CotizacionServicios] INT NULL;

-- 21. VariableDefinicion, VariableDefinicionMaestro, VariableDatosMaestro
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDefinicion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDefinicion] (
        [IDEN] NUMERIC(18,0) IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Nombre] VARCHAR(250) NULL,
        [Descripcion] VARCHAR(500) NULL,
        [Presentacion] VARCHAR(250) NULL,
        [TipoDato] VARCHAR(50) NULL,
        [Codigo] VARCHAR(50) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Descripcion')
    ALTER TABLE dbo.[VariableDefinicion] ADD [Descripcion] VARCHAR(500) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Presentacion')
    ALTER TABLE dbo.[VariableDefinicion] ADD [Presentacion] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'TipoDato')
    ALTER TABLE dbo.[VariableDefinicion] ADD [TipoDato] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Codigo')
    ALTER TABLE dbo.[VariableDefinicion] ADD [Codigo] VARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDefinicionMaestro' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDefinicionMaestro] (
        [IDEN] NUMERIC(18,0) IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Codigo] VARCHAR(50) NULL,
        [Nombre] VARCHAR(250) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicionMaestro') AND name = 'Nombre')
    ALTER TABLE dbo.[VariableDefinicionMaestro] ADD [Nombre] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDatosMaestro' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDatosMaestro] (
        [IDEN] NUMERIC(18,0) IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [IDEN_Maestro] NUMERIC(18,0) NULL,
        [IDEN_Variable] NUMERIC(18,0) NULL,
        [CodigoMaestro] VARCHAR(50) NULL,
        [ValorNumerico] NUMERIC(18,6) NULL,
        [ValorFecha] SMALLDATETIME NULL,
        [ValorVarchar] VARCHAR(500) NULL,
        [cd_VariableDatosMaestro] VARCHAR(25) NULL,
        [cd_Cotizacion] VARCHAR(25) NULL,
        [cd_CotizacionServicios] VARCHAR(25) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'IDEN_Maestro')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [IDEN_Maestro] NUMERIC(18,0) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'IDEN_Variable')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [IDEN_Variable] NUMERIC(18,0) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'CodigoMaestro')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [CodigoMaestro] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'ValorNumerico')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [ValorNumerico] NUMERIC(18,6) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'ValorFecha')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [ValorFecha] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDatosMaestro') AND name = 'ValorVarchar')
    ALTER TABLE dbo.[VariableDatosMaestro] ADD [ValorVarchar] VARCHAR(500) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'cd_tiquete')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [cd_tiquete] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_tiquete')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_tiquete] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_tiquete')
    ALTER TABLE dbo.[Fac_Servicios] ADD [cd_tiquete] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'ds_paxname')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [ds_paxname] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'ds_paxape')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [ds_paxape] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'ds_paxprefix')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [ds_paxprefix] VARCHAR(10) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'ds_paxClasificacion')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [ds_paxClasificacion] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'cd_voucherpax')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [cd_voucherpax] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'cd_paxidentificacion')
    ALTER TABLE dbo.[CotizacionServicios_PaxAdicional] ADD [cd_paxidentificacion] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_pordescuento')
    ALTER TABLE dbo.[CotizacionServicios] ADD [am_pordescuento] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_basedescuento')
    ALTER TABLE dbo.[CotizacionServicios] ADD [am_basedescuento] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_CotizacionServicios_Depende')
    ALTER TABLE dbo.[CotizacionServicios] ADD [id_CotizacionServicios_Depende] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'bl_tiquete')
    ALTER TABLE dbo.[CotizacionServicios] ADD [bl_tiquete] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TiposServicios') AND name = 'bl_tiquete')
    ALTER TABLE dbo.[TiposServicios] ADD [bl_tiquete] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'bl_tiquete')
    ALTER TABLE dbo.[Fac_Servicios] ADD [bl_tiquete] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_fechaficheroBBVA')
    ALTER TABLE dbo.[CotizacionServicios] ADD [dt_fechaficheroBBVA] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_fechaficheroBBVA')
    ALTER TABLE dbo.[Fac_Servicios] ADD [dt_fechaficheroBBVA] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_GDS')
    ALTER TABLE dbo.[Cotizacion] ADD [ds_GDS] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_GDS')
    ALTER TABLE dbo.[CotizacionServicios] ADD [ds_GDS] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_GDS')
    ALTER TABLE dbo.[Fac_Servicios] ADD [ds_GDS] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_PorFacParcial')
    ALTER TABLE dbo.[CotizacionServicios] ADD [am_PorFacParcial] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_EdadPax')
    ALTER TABLE dbo.[CotizacionServicios] ADD [in_EdadPax] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_PorFacParcial')
    ALTER TABLE dbo.[Fac_Servicios] ADD [am_PorFacParcial] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_EdadPax')
    ALTER TABLE dbo.[Fac_Servicios] ADD [in_EdadPax] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_Aerolinea')
    ALTER TABLE dbo.[CotizacionServicios] ADD [id_Aerolinea] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_Aerolinea')
    ALTER TABLE dbo.[Fac_Servicios] ADD [id_Aerolinea] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_TipoServicio')
    ALTER TABLE dbo.[CotizacionServicios] ADD [id_TipoServicio] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_TipoServicio')
    ALTER TABLE dbo.[Fac_Servicios] ADD [id_TipoServicio] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_MonedaSrv')
    ALTER TABLE dbo.[CotizacionServicios] ADD [id_MonedaSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_MonedaSrv')
    ALTER TABLE dbo.[CotizacionServicios] ADD [cd_MonedaSrv] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_MonedaSrv')
    ALTER TABLE dbo.[Fac_Servicios] ADD [id_MonedaSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_TipoAuto') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_TipoAuto] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_Origen') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_Origen] VARCHAR(30) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_DirOrigen') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_DirOrigen] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_DirDestino') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_DirDestino] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_TipoTarifa') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_TipoTarifa] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_ValorUSD') ALTER TABLE dbo.[CotizacionServicios] ADD [am_ValorUSD] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_NoVuelo') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_NoVuelo] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_Vehiculo') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_Vehiculo] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_Placa') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_Placa] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_CategoriaVehiculo') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_CategoriaVehiculo] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_NombreConductor') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_NombreConductor] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_telefono') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_telefono] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_IdiomaConductor') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_IdiomaConductor] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_TipoAuto') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_TipoAuto] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_Origen') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_Origen] VARCHAR(30) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_DirOrigen') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_DirOrigen] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_DirDestino') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_DirDestino] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_TipoTarifa') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_TipoTarifa] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_ValorUSD') ALTER TABLE dbo.[Fac_Servicios] ADD [am_ValorUSD] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_NoVuelo') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_NoVuelo] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_Vehiculo') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_Vehiculo] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_Placa') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_Placa] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_CategoriaVehiculo') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_CategoriaVehiculo] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_NombreConductor') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_NombreConductor] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_telefono') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_telefono] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_IdiomaConductor') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_IdiomaConductor] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_sys_entidades') ALTER TABLE dbo.[Cotizacion] ADD [id_sys_entidades] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_Evento') ALTER TABLE dbo.[Cotizacion] ADD [cd_Evento] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_sys_entidades') ALTER TABLE dbo.[CotizacionServicios] ADD [id_sys_entidades] INT NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_sys_entidades') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_sys_entidades] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_sys_entidades') ALTER TABLE dbo.[Fac_Servicios] ADD [id_sys_entidades] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Iden_GDS') ALTER TABLE dbo.[CotizacionServicios] ADD [Iden_GDS] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'Iden_GDS') ALTER TABLE dbo.[Fac_Servicios] ADD [Iden_GDS] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_Regiones') ALTER TABLE dbo.[CotizacionServicios] ADD [id_Regiones] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_Regiones') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_Regiones] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_Regiones') ALTER TABLE dbo.[Fac_Servicios] ADD [id_Regiones] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_Regiones') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_Regiones] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_TarjetaAsistencia') ALTER TABLE dbo.[CotizacionServicios] ADD [id_TarjetaAsistencia] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_TarjetaAsistencia') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_TarjetaAsistencia] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_TarjetaAsistencia') ALTER TABLE dbo.[Fac_Servicios] ADD [id_TarjetaAsistencia] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_TarjetaAsistencia') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_TarjetaAsistencia] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_fac_remisionComision') ALTER TABLE dbo.[CotizacionServicios] ADD [id_fac_remisionComision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_fac_facturaComision') ALTER TABLE dbo.[CotizacionServicios] ADD [id_fac_facturaComision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_fac_remisionComision') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_fac_remisionComision] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_fac_facturaComision') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_fac_facturaComision] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_fac_remisionComision') ALTER TABLE dbo.[Fac_Servicios] ADD [id_fac_remisionComision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_fac_facturaComision') ALTER TABLE dbo.[Fac_Servicios] ADD [id_fac_facturaComision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_fac_remisionComision') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_fac_remisionComision] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_fac_facturaComision') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_fac_facturaComision] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_tipoHabitacion') ALTER TABLE dbo.[CotizacionServicios] ADD [id_tipoHabitacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_tipoHabitacionacion') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_tipoHabitacionacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_tipoHabitacion') ALTER TABLE dbo.[Fac_Servicios] ADD [id_tipoHabitacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_tipoHabitacionacion') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_tipoHabitacionacion] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_politicaCancelacion') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_politicaCancelacion] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'bl_politicaCancelacion') ALTER TABLE dbo.[CotizacionServicios] ADD [bl_politicaCancelacion] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_politicaCancelacion') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_politicaCancelacion] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'bl_politicaCancelacion') ALTER TABLE dbo.[Fac_Servicios] ADD [bl_politicaCancelacion] BIT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_paxidentificacion') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_paxidentificacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_confirmacion') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_confirmacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_confirmadopor') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_confirmadopor] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_paxidentificacion') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_paxidentificacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_confirmacion') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_confirmacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_confirmadopor') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_confirmadopor] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_habitacionesSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [in_habitacionesSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_habitaciones') ALTER TABLE dbo.[CotizacionServicios] ADD [in_habitaciones] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_TipoPlanSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_TipoPlanSrv] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_AcomodacionSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_AcomodacionSrv] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_habitacionesSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [in_habitacionesSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_habitaciones') ALTER TABLE dbo.[Fac_Servicios] ADD [in_habitaciones] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_TipoPlanSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_TipoPlanSrv] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_AcomodacionSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_AcomodacionSrv] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_TipoPlanSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [id_TipoPlanSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_AcomodacionSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [id_AcomodacionSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_TipoPlanSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [id_TipoPlanSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_AcomodacionSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [id_AcomodacionSrv] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_VenceFac') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_VenceFac] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_NumeFac') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_NumeFac] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_basecomisionableprov') ALTER TABLE dbo.[CotizacionServicios] ADD [am_basecomisionableprov] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_porcomisionprov') ALTER TABLE dbo.[CotizacionServicios] ADD [am_porcomisionprov] FLOAT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_VenceFac') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_VenceFac] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_NumeFac') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_NumeFac] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_basecomisionableprov') ALTER TABLE dbo.[Fac_Servicios] ADD [am_basecomisionableprov] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_porcomisionprov') ALTER TABLE dbo.[Fac_Servicios] ADD [am_porcomisionprov] FLOAT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_voucherpax') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_voucherpax] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_localizador') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_localizador] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_voucherpax') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_voucherpax] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_localizador') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_localizador] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_FechaLlegadaSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_FechaLlegadaSrv] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_FechaSalidaSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_FechaSalidaSrv] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_FechaLlegadaSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_FechaLlegadaSrv] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_FechaSalidaSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_FechaSalidaSrv] SMALLDATETIME NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_NumeroOpcion') ALTER TABLE dbo.[CotizacionServicios] ADD [in_NumeroOpcion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_NumeroOpcion') ALTER TABLE dbo.[Fac_Servicios] ADD [in_NumeroOpcion] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_cargosdesc_descuento') ALTER TABLE dbo.[CotizacionServicios] ADD [id_cargosdesc_descuento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_cargosdesc_descuento') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_cargosdesc_descuento] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_motivo_descuento') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_motivo_descuento] VARCHAR(1000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_valor_descuento') ALTER TABLE dbo.[CotizacionServicios] ADD [am_valor_descuento] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_porcentaje_descuento') ALTER TABLE dbo.[CotizacionServicios] ADD [am_porcentaje_descuento] FLOAT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_cargosdesc_descuento') ALTER TABLE dbo.[Fac_Servicios] ADD [id_cargosdesc_descuento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_cargosdesc_descuento') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_cargosdesc_descuento] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_motivo_descuento') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_motivo_descuento] VARCHAR(1000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_valor_descuento') ALTER TABLE dbo.[Fac_Servicios] ADD [am_valor_descuento] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_porcentaje_descuento') ALTER TABLE dbo.[Fac_Servicios] ADD [am_porcentaje_descuento] FLOAT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'Id_Especialista') ALTER TABLE dbo.[Cotizacion] ADD [Id_Especialista] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_Especialista') ALTER TABLE dbo.[Cotizacion] ADD [cd_Especialista] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Id_Especialista') ALTER TABLE dbo.[CotizacionServicios] ADD [Id_Especialista] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_Especialista') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_Especialista] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'Id_Especialista') ALTER TABLE dbo.[Fac_Cotizacion] ADD [Id_Especialista] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'Id_Especialista') ALTER TABLE dbo.[Fac_Servicios] ADD [Id_Especialista] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_Especialista') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_Especialista] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_nochesSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [in_nochesSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_diasSrv') ALTER TABLE dbo.[CotizacionServicios] ADD [in_diasSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_GrConcepto') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_GrConcepto] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_nochesSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [in_nochesSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_diasSrv') ALTER TABLE dbo.[Fac_Servicios] ADD [in_diasSrv] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_GrConcepto') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_GrConcepto] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_GrConcepto') ALTER TABLE dbo.[CotizacionServicios] ADD [id_GrConcepto] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_GrConcepto') ALTER TABLE dbo.[Fac_Servicios] ADD [id_GrConcepto] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_records') ALTER TABLE dbo.[Cotizacion] ADD [ds_records] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_records') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_records] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'ds_records') ALTER TABLE dbo.[Fac_Cotizacion] ADD [ds_records] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_records') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_records] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_noches') ALTER TABLE dbo.[CotizacionServicios] ADD [in_noches] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_dias') ALTER TABLE dbo.[CotizacionServicios] ADD [in_dias] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_acomodacion') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_acomodacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_tipoplan') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_tipoplan] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_noches') ALTER TABLE dbo.[Fac_Servicios] ADD [in_noches] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_dias') ALTER TABLE dbo.[Fac_Servicios] ADD [in_dias] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_acomodacion') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_acomodacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_tipoplan') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_tipoplan] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_acomodacion') ALTER TABLE dbo.[CotizacionServicios] ADD [id_acomodacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_tipoplan') ALTER TABLE dbo.[CotizacionServicios] ADD [id_tipoplan] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_acomodacion') ALTER TABLE dbo.[Fac_Servicios] ADD [id_acomodacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_tipoplan') ALTER TABLE dbo.[Fac_Servicios] ADD [id_tipoplan] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_paxClasificacion') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_paxClasificacion] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_paxClasificacion') ALTER TABLE dbo.[CotizacionServicios] ADD [id_paxClasificacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_paxClasificacion') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_paxClasificacion] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_paxClasificacion') ALTER TABLE dbo.[Fac_Servicios] ADD [id_paxClasificacion] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dias_recaudo') ALTER TABLE dbo.[CotizacionServicios] ADD [dias_recaudo] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Valor_Recaudo') ALTER TABLE dbo.[CotizacionServicios] ADD [Valor_Recaudo] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'Valor_Comision') ALTER TABLE dbo.[CotizacionServicios] ADD [Valor_Comision] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'bl_notdomicilionacional') ALTER TABLE dbo.[CotizacionServicios] ADD [bl_notdomicilionacional] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_voucherPrefijo') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_voucherPrefijo] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dias_recaudo') ALTER TABLE dbo.[Fac_Servicios] ADD [dias_recaudo] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'Valor_Recaudo') ALTER TABLE dbo.[Fac_Servicios] ADD [Valor_Recaudo] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'Valor_Comision') ALTER TABLE dbo.[Fac_Servicios] ADD [Valor_Comision] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'bl_notdomicilionacional') ALTER TABLE dbo.[Fac_Servicios] ADD [bl_notdomicilionacional] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_voucherPrefijo') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_voucherPrefijo] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_porcomision') ALTER TABLE dbo.[CotizacionServicios] ADD [am_porcomision] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_basecomisionable') ALTER TABLE dbo.[CotizacionServicios] ADD [am_basecomisionable] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_porcomision') ALTER TABLE dbo.[Fac_Servicios] ADD [am_porcomision] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_basecomisionable') ALTER TABLE dbo.[Fac_Servicios] ADD [am_basecomisionable] FLOAT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_implante_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_implante_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_implante_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [id_implante_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_sucursal_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_sucursal_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_sucursal_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [id_sucursal_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_usuario_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_usuario_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_usuario_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [id_usuario_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_consecutivo_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_consecutivo_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_serie_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_serie_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_fuente_anul') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_fuente_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'bl_anulado') ALTER TABLE dbo.[CotizacionServicios] ADD [bl_anulado] BIT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_implante_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_implante_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_implante_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [id_implante_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_sucursal_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_sucursal_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_sucursal_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [id_sucursal_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_usuario_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_usuario_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_usuario_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [id_usuario_anul] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_consecutivo_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_consecutivo_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_serie_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_serie_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_fuente_anul') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_fuente_anul] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'bl_anulado') ALTER TABLE dbo.[Fac_Servicios] ADD [bl_anulado] BIT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_hoteles') ALTER TABLE dbo.[CotizacionServicios] ADD [id_hoteles] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_hoteles') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_hoteles] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_carrental') ALTER TABLE dbo.[CotizacionServicios] ADD [id_carrental] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_carrental') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_carrental] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_hoteles') ALTER TABLE dbo.[Fac_Servicios] ADD [id_hoteles] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_hoteles') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_hoteles] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_carrental') ALTER TABLE dbo.[Fac_Servicios] ADD [id_carrental] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_carrental') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_carrental] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_InfoAdicional') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_InfoAdicional] VARCHAR(8000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_InfoAdicional') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_InfoAdicional] VARCHAR(8000) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_monedaprov') ALTER TABLE dbo.[CotizacionServicios] ADD [id_monedaprov] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_monedaprov') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_monedaprov] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_monedaprov') ALTER TABLE dbo.[Fac_Servicios] ADD [id_monedaprov] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_monedaprov') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_monedaprov] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'am_valorprov') ALTER TABLE dbo.[CotizacionServicios] ADD [am_valorprov] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_item') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_item] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_item') ALTER TABLE dbo.[CotizacionServicios] ADD [id_item] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_auxiliar') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_auxiliar] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_auxiliar') ALTER TABLE dbo.[CotizacionServicios] ADD [id_auxiliar] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_cencosto') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_cencosto] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_cencosto') ALTER TABLE dbo.[CotizacionServicios] ADD [id_cencosto] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'am_valorprov') ALTER TABLE dbo.[Fac_Servicios] ADD [am_valorprov] FLOAT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_item') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_item] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_item') ALTER TABLE dbo.[Fac_Servicios] ADD [id_item] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_auxiliar') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_auxiliar] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_auxiliar') ALTER TABLE dbo.[Fac_Servicios] ADD [id_auxiliar] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_cencosto') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_cencosto] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_cencosto') ALTER TABLE dbo.[Fac_Servicios] ADD [id_cencosto] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_salida') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_salida] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'dt_llegada') ALTER TABLE dbo.[CotizacionServicios] ADD [dt_llegada] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_cantpax') ALTER TABLE dbo.[CotizacionServicios] ADD [in_cantpax] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_voucher') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_voucher] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_nacionalidad') ALTER TABLE dbo.[CotizacionServicios] ADD [in_nacionalidad] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_paxtype') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_paxtype] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_salida') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_salida] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'dt_llegada') ALTER TABLE dbo.[Fac_Servicios] ADD [dt_llegada] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_cantpax') ALTER TABLE dbo.[Fac_Servicios] ADD [in_cantpax] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_voucher') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_voucher] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_nacionalidad') ALTER TABLE dbo.[Fac_Servicios] ADD [in_nacionalidad] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_paxtype') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_paxtype] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_paxape') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_paxape] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_paxname') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_paxname] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_descrip') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_descrip] VARCHAR(4000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_servicio') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_servicio] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_proveedores') ALTER TABLE dbo.[CotizacionServicios] ADD [id_proveedores] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_proveedores') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_proveedores] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_proveedores') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_proveedores] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_paxape') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_paxape] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_paxname') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_paxname] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_descrip') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_descrip] VARCHAR(4000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_servicio') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_servicio] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_proveedores') ALTER TABLE dbo.[Fac_Servicios] ADD [id_proveedores] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_proveedores') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_proveedores] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_proveedores') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_proveedores] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_destino') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_destino] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_prov_air') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_prov_air] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_prov_car') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_prov_car] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_prov_hotel') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_prov_hotel] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'ds_tiposervnm') ALTER TABLE dbo.[CotizacionServicios] ADD [ds_tiposervnm] VARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_destino') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_destino] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_prov_air') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_prov_air] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_prov_car') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_prov_car] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_prov_hotel') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_prov_hotel] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'ds_tiposervnm') ALTER TABLE dbo.[Fac_Servicios] ADD [ds_tiposervnm] VARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_fac_remision') ALTER TABLE dbo.[CotizacionServicios] ADD [id_fac_remision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_fac_factura') ALTER TABLE dbo.[CotizacionServicios] ADD [id_fac_factura] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_fac_remision') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_fac_remision] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_fac_factura') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_fac_factura] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_fac_remision') ALTER TABLE dbo.[Fac_Servicios] ADD [id_fac_remision] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_fac_factura') ALTER TABLE dbo.[Fac_Servicios] ADD [id_fac_factura] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_fac_remision') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_fac_remision] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_fac_factura') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_fac_factura] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_TiposServicio') ALTER TABLE dbo.[CotizacionServicios] ADD [id_TiposServicio] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_TiposServicio') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_TiposServicio] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_ConceptoFacturacion') ALTER TABLE dbo.[CotizacionServicios] ADD [id_ConceptoFacturacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_ConceptoFacturacion') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_ConceptoFacturacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_TiposConceptFac') ALTER TABLE dbo.[CotizacionServicios] ADD [id_TiposConceptFac] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_TiposConceptFac') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_TiposConceptFac] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_TiposServicio') ALTER TABLE dbo.[Fac_Servicios] ADD [id_TiposServicio] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_TiposServicio') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_TiposServicio] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_ConceptoFacturacion') ALTER TABLE dbo.[Fac_Servicios] ADD [id_ConceptoFacturacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_ConceptoFacturacion') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_ConceptoFacturacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_TiposConceptFac') ALTER TABLE dbo.[Fac_Servicios] ADD [id_TiposConceptFac] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_TiposConceptFac') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_TiposConceptFac] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_evento') ALTER TABLE dbo.[Cotizacion] ADD [id_evento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_evento') ALTER TABLE dbo.[Cotizacion] ADD [cd_evento] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'id_evento') ALTER TABLE dbo.[CotizacionServicios] ADD [id_evento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'cd_evento') ALTER TABLE dbo.[CotizacionServicios] ADD [cd_evento] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_evento') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_evento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'id_evento') ALTER TABLE dbo.[Fac_Servicios] ADD [id_evento] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'cd_evento') ALTER TABLE dbo.[Fac_Servicios] ADD [cd_evento] VARCHAR(25) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_hotelTieneTiquete') ALTER TABLE dbo.[Cotizacion] ADD [ds_hotelTieneTiquete] VARCHAR(2) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_fechaPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [bl_fechaPagoDestino] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_CheckOutPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [dt_CheckOutPagoDestino] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_CheckInPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [dt_CheckInPagoDestino] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_DocumentoPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [ds_DocumentoPagoDestino] VARCHAR(50) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_FormaPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [cd_FormaPagoDestino] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_MonedaPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [cd_MonedaPagoDestino] VARCHAR(25) NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'ds_hotelTieneTiquete') ALTER TABLE dbo.[Fac_Cotizacion] ADD [ds_hotelTieneTiquete] VARCHAR(2) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_FormaPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [id_FormaPagoDestino] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_MonedaPagoDestino') ALTER TABLE dbo.[Cotizacion] ADD [id_MonedaPagoDestino] INT NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_FormaPagoDestino') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_FormaPagoDestino] INT NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_MonedaPagoDestino') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_MonedaPagoDestino] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_entregadoCliente') ALTER TABLE dbo.[Cotizacion] ADD [dt_entregadoCliente] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_entregadoCliente') ALTER TABLE dbo.[Cotizacion] ADD [bl_entregadoCliente] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_comisiona') ALTER TABLE dbo.[Cotizacion] ADD [bl_comisiona] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_AlertaSolicitud') ALTER TABLE dbo.[Cotizacion] ADD [ds_AlertaSolicitud] VARCHAR(8000) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_usuario_Bloqueo') ALTER TABLE dbo.[Cotizacion] ADD [cd_usuario_Bloqueo] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_bloqueada') ALTER TABLE dbo.[Cotizacion] ADD [bl_bloqueada] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_MedioReservacion') ALTER TABLE dbo.[Cotizacion] ADD [cd_MedioReservacion] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_TipoFormaPagoProveedor') ALTER TABLE dbo.[Cotizacion] ADD [cd_TipoFormaPagoProveedor] VARCHAR(25) NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'dt_entregadoCliente') ALTER TABLE dbo.[Fac_Cotizacion] ADD [dt_entregadoCliente] SMALLDATETIME NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_FormaDePago') ALTER TABLE dbo.[Cotizacion] ADD [ds_FormaDePago] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'gk_sabre') ALTER TABLE dbo.[Cotizacion] ADD [gk_sabre] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_grupos') ALTER TABLE dbo.[Cotizacion] ADD [bl_grupos] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_OpcionSeleccionada') ALTER TABLE dbo.[Cotizacion] ADD [in_OpcionSeleccionada] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_CerrarCotizacion') ALTER TABLE dbo.[Cotizacion] ADD [bl_CerrarCotizacion] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_NumeroOpciones') ALTER TABLE dbo.[Cotizacion] ADD [in_NumeroOpciones] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bl_ManejaOpciones') ALTER TABLE dbo.[Cotizacion] ADD [bl_ManejaOpciones] BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_seguimiento_etapa') ALTER TABLE dbo.[Cotizacion] ADD [ds_seguimiento_etapa] VARCHAR(500) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_Etapa') ALTER TABLE dbo.[Cotizacion] ADD [cd_Etapa] VARCHAR(25) NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'ds_FormaDePago') ALTER TABLE dbo.[Fac_Cotizacion] ADD [ds_FormaDePago] VARCHAR(250) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_MedioReservacion') ALTER TABLE dbo.[Cotizacion] ADD [id_MedioReservacion] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_TipoFormaPagoProveedor') ALTER TABLE dbo.[Cotizacion] ADD [id_TipoFormaPagoProveedor] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_Etapa') ALTER TABLE dbo.[Cotizacion] ADD [id_Etapa] INT NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_MedioReservacion') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_MedioReservacion] INT NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_TipoFormaPagoProveedor') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_TipoFormaPagoProveedor] INT NULL;
IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'id_Etapa') ALTER TABLE dbo.[Fac_Cotizacion] ADD [id_Etapa] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'in_estado') ALTER TABLE dbo.[Cotizacion] ADD [in_estado] INT NULL DEFAULT 1;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'dt_vence') ALTER TABLE dbo.[Cotizacion] ADD [dt_vence] SMALLDATETIME NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tipoventa') ALTER TABLE dbo.[Cotizacion] ADD [cd_tipoventa] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tipoventa') ALTER TABLE dbo.[Cotizacion] ADD [id_tipoventa] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_Campo_libre2') ALTER TABLE dbo.[Cotizacion] ADD [ds_Campo_libre2] VARCHAR(500) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_Campo_libre1') ALTER TABLE dbo.[Cotizacion] ADD [ds_Campo_libre1] VARCHAR(500) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_observacion') ALTER TABLE dbo.[Cotizacion] ADD [ds_observacion] VARCHAR(8000) NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'in_estado') ALTER TABLE dbo.[Fac_Cotizacion] ADD [in_estado] INT NULL DEFAULT 1;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'am_tcambiousd') ALTER TABLE dbo.[Cotizacion] ADD [am_tcambiousd] FLOAT NULL DEFAULT 1;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'am_tcambio') ALTER TABLE dbo.[Cotizacion] ADD [am_tcambio] FLOAT NULL DEFAULT 1;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'bn_anexo') ALTER TABLE dbo.[Cotizacion] ADD [bn_anexo] VARBINARY(MAX) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_contacto_email') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_contacto_email] VARCHAR(60) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_contacto') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_contacto] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_email') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_email] VARCHAR(60) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_dirdesp') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_dirdesp] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_tel') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_tel] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_ciudad') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_ciudad] VARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_dir') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_dir] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_cliente_nombre') ALTER TABLE dbo.[Cotizacion] ADD [ds_cliente_nombre] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_cliente_codigo') ALTER TABLE dbo.[Cotizacion] ADD [cd_cliente_codigo] VARCHAR(25) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'ds_tercero_nombre') ALTER TABLE dbo.[Cotizacion] ADD [ds_tercero_nombre] VARCHAR(250) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tercero_codigo') ALTER TABLE dbo.[Cotizacion] ADD [cd_tercero_codigo] VARCHAR(25) NULL;

IF OBJECT_ID('dbo.Fac_Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Cotizacion') AND name = 'am_tcambiousd') ALTER TABLE dbo.[Fac_Cotizacion] ADD [am_tcambiousd] FLOAT NULL DEFAULT 1;

IF OBJECT_ID('dbo.Facturas') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'cd_vendedor') ALTER TABLE dbo.[Facturas] ADD [cd_vendedor] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Facturas') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_tiqueteador') ALTER TABLE dbo.[Facturas] ADD [id_tiqueteador] INT NULL;
IF OBJECT_ID('dbo.Facturas') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_tiqueteador_Facturador') ALTER TABLE dbo.[Facturas] ADD [id_tiqueteador_Facturador] INT NULL;
IF OBJECT_ID('dbo.Facturas') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_Especialista') ALTER TABLE dbo.[Facturas] ADD [id_Especialista] INT NULL;
IF OBJECT_ID('dbo.Facturas') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Facturas') AND name = 'id_TipoFormaPagoProveedor') ALTER TABLE dbo.[Facturas] ADD [id_TipoFormaPagoProveedor] INT NULL;
IF OBJECT_ID('dbo.Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_vendedor') ALTER TABLE dbo.[Cotizacion] ADD [cd_vendedor] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'cd_tiqueteador') ALTER TABLE dbo.[Cotizacion] ADD [cd_tiqueteador] VARCHAR(25) NULL;
IF OBJECT_ID('dbo.Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tiqueteador') ALTER TABLE dbo.[Cotizacion] ADD [id_tiqueteador] INT NULL;
IF OBJECT_ID('dbo.Cotizacion') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Cotizacion') AND name = 'id_tiqueteador_Facturador') ALTER TABLE dbo.[Cotizacion] ADD [id_tiqueteador_Facturador] INT NULL;

IF OBJECT_ID('dbo.QuotationProduct') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'providerDueDate') ALTER TABLE dbo.[QuotationProduct] ADD [providerDueDate] DATETIME2 NULL;
IF OBJECT_ID('dbo.QuotationProduct') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProduct') AND name = 'providerInvoice') ALTER TABLE dbo.[QuotationProduct] ADD [providerInvoice] NVARCHAR(100) NULL;

IF OBJECT_ID('dbo.InvoicesProduct') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'providerDueDate') ALTER TABLE dbo.[InvoicesProduct] ADD [providerDueDate] DATETIME2 NULL;
IF OBJECT_ID('dbo.InvoicesProduct') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProduct') AND name = 'providerInvoice') ALTER TABLE dbo.[InvoicesProduct] ADD [providerInvoice] NVARCHAR(100) NULL;

-- ============================================================================
-- TABLAS DE CONTROL DE ACTUALIZACIÓN KOREX UPDATE GUARDIAN
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Korex_UpdateHistory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Korex_UpdateHistory] (
        [UpdateId] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Korex_UpdateHistory PRIMARY KEY,
        [VersionAnterior] NVARCHAR(50) NULL,
        [VersionNueva] NVARCHAR(50) NOT NULL,
        [Build] NVARCHAR(50) NULL,
        [Motor] NVARCHAR(50) NOT NULL,
        [Servidor] NVARCHAR(255) NULL,
        [BaseDatos] NVARCHAR(255) NULL,
        [FechaInicio] DATETIME2 NOT NULL CONSTRAINT DF_Korex_UpdateHistory_FechaInicio DEFAULT GETDATE(),
        [FechaFin] DATETIME2 NULL,
        [Estado] NVARCHAR(50) NOT NULL, -- OK, INCOMPLETA, FALLIDA
        [ExitCode] INT NOT NULL DEFAULT 0,
        [Usuario] NVARCHAR(150) NULL,
        [Equipo] NVARCHAR(150) NULL,
        [ResumenLog] NVARCHAR(MAX) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Korex_UpdateObjects' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Korex_UpdateObjects] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Korex_UpdateObjects PRIMARY KEY,
        [UpdateId] INT NOT NULL CONSTRAINT FK_Korex_UpdateObjects_History REFERENCES dbo.[Korex_UpdateHistory]([UpdateId]),
        [ObjectType] NVARCHAR(50) NOT NULL, -- TABLE, COLUMN, PROCEDURE, FUNCTION, INDEX, DATA
        [ObjectName] NVARCHAR(255) NOT NULL,
        [Expected] BIT NOT NULL DEFAULT 1,
        [Executed] BIT NOT NULL DEFAULT 0,
        [Compiled] BIT NOT NULL DEFAULT 0,
        [Validated] BIT NOT NULL DEFAULT 0,
        [HashExpected] NVARCHAR(128) NULL,
        [HashActual] NVARCHAR(128) NULL,
        [Status] NVARCHAR(50) NOT NULL, -- OK, WARNING, ERROR, OMITIDO
        [ErrorMessage] NVARCHAR(MAX) NULL,
        [ExecutionTimeMs] INT NULL DEFAULT 0,
        [FechaVerificacion] DATETIME2 NOT NULL CONSTRAINT DF_Korex_UpdateObjects_Fecha DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Korex_UpdateErrors' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Korex_UpdateErrors] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Korex_UpdateErrors PRIMARY KEY,
        [UpdateId] INT NOT NULL CONSTRAINT FK_Korex_UpdateErrors_History REFERENCES dbo.[Korex_UpdateHistory]([UpdateId]),
        [ObjectName] NVARCHAR(255) NULL,
        [ErrorNumber] INT NULL,
        [ErrorMessage] NVARCHAR(MAX) NOT NULL,
        [StackTrace] NVARCHAR(MAX) NULL,
        [Fecha] DATETIME2 NOT NULL CONSTRAINT DF_Korex_UpdateErrors_Fecha DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Korex_Installation' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[Korex_Installation] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Korex_Installation PRIMARY KEY,
        [AppVersion] NVARCHAR(50) NOT NULL,
        [DbVersion] NVARCHAR(50) NOT NULL,
        [Build] NVARCHAR(50) NULL,
        [Motor] NVARCHAR(50) NOT NULL,
        [LastValidationDate] DATETIME2 NOT NULL CONSTRAINT DF_Korex_Installation_LastVal DEFAULT GETDATE(),
        [Status] NVARCHAR(50) NOT NULL DEFAULT 'HEALTHY',
        [Environment] NVARCHAR(50) NULL DEFAULT 'PRODUCTION'
    );
END;

PRINT 'Tablas de la base de datos SQL Server estructuradas exitosamente.';



GO

-- --------------------------------------------------------------------------
-- SECCIÓN 2: INYECCIÓN Y PRESERVACIÓN DE SEMILLAS Y PARÁMETROS
-- --------------------------------------------------------------------------
-- ============================================================================
-- AGENCIASNEW - SEMILLAS MAESTRAS E INICIALES PARA BASE EN BLANCO (SQL SERVER)
-- Archivo: SQL/SqlServer/02_Seeds.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Roles Iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'SUPERADMINISTRADOR' OR UPPER([name]) LIKE '%SUPERADMIN%')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'SUPERADMINISTRADOR', N'Super Administrador de la plataforma con privilegios de gestión de módulos del sitio y asignación de superadministradores', N'{"all": true, "superadmin": true}', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'Administrador')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'Administrador', N'Rol administrador de la plataforma', N'{"all": true}', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'Agente')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'Agente', N'Rol de agente de ventas y cotizaciones', N'{"quotations": true}', 1);
END;

-- 2. Parámetros del Sistema Requeridos
IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ServidorSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ServidorSQLServer', N'Host de SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'BaseSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'BaseSQLServer', N'Base de Datos SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'UsuarioSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'UsuarioSQLServer', N'Usuario SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ClaveSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ClaveSQLServer', N'Contraseña SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EncriptarClaves')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EncriptarClaves', N'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', N'0');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PuertoSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PuertoSQLServer', N'Puerto SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarCotizacionesAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarCotizacionesAutoSQLserver', N'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', N'0');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarFacturacionAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarFacturacionAutoSQLserver', N'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', N'0');
END;

-- Unificación y limpieza de parámetros duplicados de facturación automática
DELETE FROM dbo.[SystemParameter] WHERE [code] IN (N'EnviarFacturasAutoSQLserver', N'EnviarFacturaAutoSQLserver', N'EnviarFacturacionAuto', N'EnviarFacturasAuto');

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ModoFacturacionAuto')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ModoFacturacionAuto', N'Modo de Facturación Automática (Zeus/Local)', N'FALSE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'AGENCY_NAME')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'AGENCY_NAME', N'Nombre o Razón Social de la Agencia', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'AGENCY_NIT')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'AGENCY_NIT', N'NIT de la Agencia', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TASA_CAMBIO_IATA')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TASA_CAMBIO_IATA', N'Tasa de Cambio IATA', N'4200.00');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_OW')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_OW', N'Tarifa Administrativa Nacional One Way', N'29100');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_RT')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_RT', N'Tarifa Administrativa Nacional Roundtrip', N'52800');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PRODUCTO_TARIFA_ADMINISTRATIVA')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PRODUCTO_TARIFA_ADMINISTRATIVA', N'Producto por Defecto para Tarifa Administrativa', N'77');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_INT_RANGES')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_INT_RANGES', N'Rangos Tarifa Administrativa Internacional (JSON)', N'[{"min":0,"max":354,"feeUsd":15,"label":"Menores o iguales a USD 354"},{"min":354.01,"max":590,"feeUsd":28,"label":"Mayores de USD 354 hasta USD 590"},{"min":590.01,"max":944,"feeUsd":46,"label":"Mayores de USD 590 hasta USD 944"},{"min":944.01,"max":999999,"feeUsd":95,"label":"Mayores de USD 944"}]');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PRODUCTO_RESERVA_GDS')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PRODUCTO_RESERVA_GDS', N'Producto por Defecto para Reservas GDS', N'TAN');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'LICENSE_KEY')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'LICENSE_KEY', N'Clave de Licencia del Sistema', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'LICENSE_EXPIRATION_DATE')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'LICENSE_EXPIRATION_DATE', N'Fecha de Expiración de Licencia', N'');
END;


-- 3. Módulos de Menú de Navegación
IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'quotations')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'quotations', N'Cotizaciones', N'/dashboard/quotations', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'invoices')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'invoices', N'Facturación', N'/dashboard/invoices', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'prequotations')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'prequotations', N'Pre-Cotizaciones', N'/dashboard/prequotations', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'executions')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'executions', N'Ejecuciones', N'/dashboard/executions', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'reports')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'reports', N'Reportes', N'/dashboard/reports', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'settings')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'settings', N'Configuración', N'/dashboard/settings', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'manual')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'manual', N'Manual Operativo', N'/dashboard/manual', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'DIAGNOSTICS')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'DIAGNOSTICS', N'Trazabilidad y Diagnóstico', N'/dashboard/diagnostics', 1);
END;


-- 4. Tablas Maestras del Sitio (Master)
DECLARE @masters TABLE (code NVARCHAR(100), name NVARCHAR(255));
INSERT INTO @masters (code, name) VALUES
(N'Equivalences', N'equivalencias'),
(N'Diagnostics', N'diagnostico'),
(N'SystemParameter', N'parametros'),
(N'User', N'usuarios'),
(N'Branch', N'sucursales'),
(N'Implant', N'implantes'),
(N'ChargeAndTax', N'impuestos'),
(N'Seller', N'vendedores'),
(N'TicketPrinter', N'tiqueteadores'),
(N'Prestadora', N'prestadoras'),
(N'Client', N'clientes'),
(N'Provider', N'proveedores'),
(N'ProviderType', N'tipos-proveedores'),
(N'Product', N'productos'),
(N'MasterVariable', N'variables'),
(N'Combo', N'combos'),
(N'SystemLog', N'logs'),
(N'Currency', N'monedas'),
(N'InterfaceExtractParam', N'extraccion-interfaces'),
(N'DocumentResolution', N'resoluciones-documentos'),
(N'TransactionConsecutive', N'consecutivos-transacciones'),
(N'CreditCard', N'tarjetas-credito'),
(N'Payment', N'formas-pago'),
(N'Countries', N'paises'),
(N'Cities', N'ciudades'),
(N'Airports', N'aeropuertos'),
(N'TicketType', N'tipos-tiquetes'),
(N'QuotationState', N'estados-cotizacion'),
(N'QuotationFormat', N'formatos-cotizacion');

INSERT INTO dbo.[Master] ([code], [name], [inactivo])
SELECT m.code, m.name, 0
FROM @masters m
WHERE NOT EXISTS (SELECT 1 FROM dbo.[Master] target WHERE target.code = m.code);


-- 5. Monedas por Defecto
IF NOT EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = N'COP')
BEGIN
    INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
    VALUES (N'COP', N'Peso Colombiano', 1.0, 0, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = N'USD')
BEGIN
    INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
    VALUES (N'USD', N'Dólar Estadounidense', 4200.0, 2, 1);
END;

-- 5.1 Estados de Cotización Iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'NUEVO')
BEGIN
    INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive])
    VALUES (N'NUEVO', N'Nuevo', N'blue', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'ENVIADO')
BEGIN
    INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive])
    VALUES (N'ENVIADO', N'ENVIADO', N'emerald', 1);
END;



-- 6. Usuarios Iniciales de Administración
DECLARE @SuperAdminRoleId INT;
SELECT TOP 1 @SuperAdminRoleId = [id] FROM dbo.[Role] WHERE UPPER([name]) LIKE '%SUPERADMIN%';
IF @SuperAdminRoleId IS NULL
    SET @SuperAdminRoleId = 1;

IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE [email] = N'ebarrera@zagencias.com')
BEGIN
    INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [isActive])
    VALUES (N'Eduardo Barrera', N'ebarrera@zagencias.com', N'$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2', @SuperAdminRoleId, 1);
END
ELSE
BEGIN
    UPDATE dbo.[User] SET [passwordHash] = N'$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2', [roleId] = @SuperAdminRoleId, [isActive] = 1 WHERE [email] = N'ebarrera@zagencias.com';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE [email] = N'ebarrrera@zagencias.com')
BEGIN
    INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [isActive])
    VALUES (N'Eduardo Barrera', N'ebarrrera@zagencias.com', N'$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2', @SuperAdminRoleId, 1);
END
ELSE
BEGIN
    UPDATE dbo.[User] SET [passwordHash] = N'$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2', [roleId] = @SuperAdminRoleId, [isActive] = 1 WHERE [email] = N'ebarrrera@zagencias.com';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE [email] = N'rubiel1985@msn.com')
BEGIN
    INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [isActive])
    VALUES (N'Rubiel', N'rubiel1985@msn.com', N'$2b$10$e1v0/9V8ZPVqejcqarQfq.hDLlKuva.M/mNsSUxOTefeyuUTqoaW2', 1, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TRACEABILITY_MODE')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
    VALUES (N'TRACEABILITY_MODE', N'Modo de Trazabilidad y Diagnóstico', N'OFF');
END;

PRINT 'Semillas iniciales inyectadas exitosamente.';

-- ============================================================================
-- 7. MAESTROS GLOBALES (Países, Ciudades, Aeropuertos, Formas de Pago)
-- ============================================================================

-- 7.1 Países (194 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CO', N'Colombia', N'169', N'LA', N'57', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'US') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'US', N'Estados Unidos', N'249', N'NA', N'1', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ES') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ES', N'España', N'245', N'EUR', N'34', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DZ', N'Algeria', N'059', N'AFR', N'213', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DK', N'Denmark', N'232', N'EUR', N'45', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CI', N'Cote d Ivoire', N'193', N'AFR', N'225', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SA', N'Saudi Arabia', N'053', N'MEA', N'966', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NG', N'Nigeria', N'528', N'AFR', N'234', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AU', N'Australia', N'069', N'PAC', N'61', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GB', N'United Kingdom', N'628', N'EUR', N'44', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MX') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MX', N'Mexico', N'493', N'LA', N'52', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GH', N'Ghana', N'289', N'AFR', N'233', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TR', N'Turkey', N'827', N'ASI', N'90', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ET') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ET', N'Ethiopia', N'253', N'AFR', N'251', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'YE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'YE', N'Yemen', N'880', N'MEA', N'967', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AR', N'Argentina', N'063', N'LA', N'54', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RU', N'Russian Federation', N'670', N'EUR', N'7', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NO', N'Norway', N'538', N'EUR', N'47', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IS', N'Iceland', N'379', N'EUR', N'354', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MA', N'Morocco', N'474', N'AFR', N'212', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DE', N'Germany', N'023', N'EUR', N'49', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FR', N'France', N'275', N'EUR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SE', N'Sweden', N'764', N'EUR', N'46', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IN', N'India', N'361', N'ASI', N'91', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ID') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ID', N'Indonesia', N'365', N'ASI', N'62', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IT', N'Italy', N'386', N'EUR', N'39', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CK', N'Cook Islands', N'183', N'PAC', N'682', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BR', N'Brazil', N'105', N'LA', N'55', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NZ', N'New Zealand', N'548', N'PAC', N'64', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KZ', N'Kazakstan', N'406', N'ASI', N'7', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZA', N'South Africa', N'756', N'AFR', N'27', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SY', N'Syrian Arab Republic', N'744', N'MEA', N'963', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AD', N'Andorra', N'037', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EG', N'Egypt', N'240', N'MEA', N'20', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JO', N'Jordan', N'403', N'MEA', N'962', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NL', N'Netherlands', N'573', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CL', N'Chile', N'211', N'LA', N'56', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BE', N'Belgium', N'087', N'EUR', N'32', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AG', N'Antigua and Barbuda', N'043', N'CAR', N'1268', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MY', N'Malaysia', N'455', N'ASI', N'60', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MZ', N'Mozambique', N'505', N'AFR', N'258', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'WS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'WS', N'Samoa', N'687', N'PAC', N'685', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PE', N'Peru', N'589', N'LA', N'51', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JP', N'Japan', N'399', N'ASI', N'81', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ER') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ER', N'Eritrea', N'243', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PY', N'Paraguay', N'586', N'LA', N'595', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BS', N'Bahamas', N'077', N'CAR', N'1242', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GR', N'Greece', N'301', N'EUR', N'30', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AW', N'Aruba', N'027', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AE', N'United Arab Emirates', N'244', N'MEA', N'971', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PF', N'French Polynesia', N'599', N'PAC', N'689', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CU', N'Cuba', N'199', N'CAR', N'53', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AI', N'Anguilla', N'041', N'CAR', N'1264', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PH', N'Philippines', N'267', N'ASI', N'63', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BH', N'Bahrain', N'080', N'ASI', N'973', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AZ', N'Azerbaijan', N'074', N'ASI', N'994', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BW', N'Botswana', N'101', N'AFR', N'267', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RO', N'Romania', N'670', N'EUR', N'40', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BM', N'Bermuda', N'090', N'CAR', N'1441', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'YU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'YU', N'Yugoslavia', N'885', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LB', N'Lebanon', N'431', N'MEA', N'961', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FJ', N'Fiji', N'870', N'PAC', N'679', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CF', N'Central African Republic', N'640', N'AFR', N'236', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BB', N'Barbados', N'083', N'CAR', N'1246', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IQ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IQ', N'Iraq', N'369', N'MEA', N'964', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CN', N'China', N'215', N'ASI', N'86', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MH', N'Marshall Islands', N'472', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GM', N'Gambia', N'285', N'AFR', N'220', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BI', N'Burundi', N'115', N'AFR', N'257', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TH', N'Thailand', N'776', N'ASI', N'66', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ML') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ML', N'Mali', N'464', N'AFR', N'223', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VE', N'Venezuela', N'850', N'LA', N'58', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MW', N'Malawi', N'458', N'AFR', N'265', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AN', N'Netherlands Antilles', N'047', N'CAR', N'31', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CH', N'Switzerland', N'767', N'EUR', N'41', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CZ', N'Czech Republic', N'644', N'EUR', N'420', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DO', N'Dominican Republic', N'647', N'CAR', N'1089', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SK', N'Slovakia', N'246', N'EUR', N'421', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HU', N'Hungary', N'355', N'EUR', N'36', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZW', N'Zimbabwe', N'665', N'AFR', N'263', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CV', N'Cape Verde', N'127', N'AFR', N'238', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BN', N'Brunei Darussalam', N'108', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BZ', N'Belize', N'088', N'LA', N'501', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CG', N'Congo', N'177', N'AFR', N'242', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BO', N'Bolivia', N'097', N'LA', N'591', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HT', N'Haiti', N'341', N'CAR', N'509', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GF', N'French Guiana', N'325', N'LA', N'594', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PT', N'Portugal', N'607', N'EUR', N'351', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GP', N'Guadeloupe', N'309', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IE', N'Ireland', N'375', N'EUR', N'353', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BD', N'Bangladesh', N'081', N'ASI', N'880', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PA', N'Panama', N'580', N'LA', N'507', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KR', N'Korea, Republic Of', N'190', N'ASI', N'82', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GN', N'Guinea', N'329', N'AFR', N'224', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LK', N'Sri Lanka', N'750', N'ASI', N'94', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BJ', N'Benin', N'229', N'AFR', N'229', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EC', N'Ecuador', N'239', N'LA', N'593', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CA', N'Canada', N'149', N'NA', N'1', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KY', N'Cayman Islands', N'137', N'CAR', N'1345', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UY', N'Uruguay', N'845', N'LA', N'598', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TZ', N'Tanzania, United Republic Of', N'780', N'AFR', N'255', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HR', N'Croatia', N'198', N'EUR', N'385', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DM', N'Dominica', N'235', N'CAR', N'1767', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TN', N'Tunisia', N'820', N'AFR', N'216', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SN', N'Senegal', N'728', N'AFR', N'221', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CM', N'Cameroon', N'145', N'AFR', N'237', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VN', N'Vietnam', N'855', N'ASI', N'84', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'QA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'QA', N'Qatar', N'618', N'MEA', N'974', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UG', N'Uganda', N'833', N'AFR', N'256', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CY', N'Cyprus', N'221', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VG', N'Virgin Islands, British', N'863', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NA', N'Namibia', N'507', N'AFR', N'264', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IL', N'Israel', N'383', N'MEA', N'972', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CD', N'Congo, The Democratic Republic Of', N'NULL', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MQ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MQ', N'Martinique', N'477', N'CAR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SL', N'Sierra Leone', N'735', N'AFR', N'232', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GT', N'Guatemala', N'317', N'CAR', N'502', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PL', N'Poland', N'603', N'EUR', N'48', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TC', N'Turks and Caicos Islands', N'823', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NC', N'New Caledonia', N'542', N'PAC', N'687', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GI', N'Gibraltar', N'293', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PG', N'Papua New Guinea', N'545', N'PAC', N'675', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GL', N'Greenland', N'305', N'NA', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AT', N'Austria', N'072', N'EUR', N'43', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GU', N'Guam', N'313', N'PAC', N'671', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MT', N'Malta', N'467', N'EUR', N'356', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KM', N'Comoros', N'173', N'AFR', N'269', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TW', N'Taiwan, Province of China', N'218', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PK', N'Pakistan', N'576', N'ASI', N'92', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FI', N'Finland', N'271', N'EUR', N'358', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SB', N'Solomon Islands', N'677', N'PAC', N'677', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HK', N'Hong Kong', N'351', N'ASI', N'852', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UA', N'Ukraine', N'830', N'EUR', N'380', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NU', N'Niue', N'531', N'PAC', N'683', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DJ', N'Djibouti', N'NULL', N'AFR', N'253', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RW', N'Rwanda', N'675', N'AFR', N'250', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JM', N'Jamaica', N'391', N'CAR', N'1876', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SD', N'Sudan', N'759', N'AFR', N'249', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NP', N'Nepal', N'517', N'ASI', N'977', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LT', N'Lithuania', N'443', N'EUR', N'9876', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KW', N'Kuwait', N'413', N'MEA', N'965', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AO', N'Angola', N'040', N'AFR', N'244', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GA', N'Gabon', N'281', N'AFR', N'241', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TG', N'Togo', N'800', N'AFR', N'228', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CR', N'Costa Rica', N'196', N'LA', N'506', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SI', N'Slovenia', N'247', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZM', N'Zambia', N'890', N'AFR', N'260', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LU', N'Luxembourg', N'445', N'EUR', N'352', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KE', N'Kenya', N'410', N'AFR', N'254', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MC', N'Monaco', N'498', N'EUR', N'377', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'OM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'OM', N'Oman', N'556', N'MEA', N'968', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MO', N'Macau', N'447', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NI', N'Nicaragua', N'521', N'LA', N'505', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MV', N'Maldives', N'461', N'ASI', N'960', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LR', N'Liberia', N'434', N'AFR', N'231', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KI', N'Kiribati', N'411', N'PAC', N'686', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MU', N'Mauritius', N'485', N'AFR', N'230', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BY', N'Belarus', N'091', N'EUR', N'375', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LS', N'Lesotho', N'426', N'AFR', N'266', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SZ', N'Swaziland', N'773', N'AFR', N'268', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MR', N'Mauritania', N'488', N'AFR', N'222', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TD', N'Chad', N'203', N'AFR', N'235', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KN', N'Saint Kitts and Nevis', N'695', N'CAR', N'1869', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NE', N'Niger', N'525', N'AFR', N'227', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BF', N'Burkina Faso', N'031', N'AFR', N'226', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GW', N'Guinea-Bissau', N'334', N'AFR', N'245', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SR', N'Suriname', N'770', N'LA', N'597', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KH', N'Cambodia', N'141', N'ASI', N'855', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TT', N'Trinidad and Tobago', N'815', N'CAR', N'1868', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AS', N'American Samoa', N'690', N'PAC', N'1684', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MM', N'Myanmar', N'093', N'ASI', N'95', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LV', N'Latvia', N'429', N'EUR', N'371', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MP', N'Northern Mariana Islands', N'NULL', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PW', N'Palau', N'578', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HN', N'Honduras', N'345', N'LA', N'504', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RE', N'Reunion', N'660', N'AFR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SV', N'El Salvador', N'242', N'LA', N'503', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SC', N'Seychelles', N'731', N'AFR', N'248', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SG', N'Singapore', N'741', N'ASI', N'65', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BA', N'Bosnia and Herzegovina', N'029', N'EUR', N'387', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MK', N'Macedonia, The Former Yugoslav Republic of', N'448', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BG', N'Bulgaria', N'111', N'EUR', N'359', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UZ', N'Uzbekistan', N'847', N'ASI', N'998', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GE', N'Georgia', N'287', N'ASI', N'995', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TO', N'Tonga', N'810', N'PAC', N'676', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IR', N'Iran, Islamic Republic Of', N'372', N'MEA', N'98', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AL', N'Albania', N'017', N'EUR', N'355', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EE', N'Estonia', N'251', N'EUR', N'372', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MG', N'Madagascar', N'450', N'AFR', N'261', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LY', N'Libyan Arab Jamahiriya', N'438', N'AFR', N'218', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VC', N'Saint Vincent and The Grenadines', N'705', N'CAR', N'1784', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VU', N'Vanuatu', N'551', N'PAC', N'678', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LA', N'Lao People s Democratic Republic', N'420', N'ASI', N'856', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ST') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ST', N'STONIA', N'251', N'AFR', N'239', 1);

-- 7.2 Ciudades (297 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOG', N'Bogotá', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'CUN', N'BOG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MDE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MDE', N'Medellín', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'ANT', N'MDE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MIA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MIA', N'Miami', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'FL', N'MIA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAD', N'Madrid', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'MAD', N'MAD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HOU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HOU', N'Houston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'HOU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANC', N'Anchorage', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ANC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LIM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LIM', N'Lima', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LIM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DEN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DEN', N'Denver', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DEN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ATL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ATL', N'Atlanta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ATL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CMH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CMH', N'Columbus', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CMH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOL', N'Hartford', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BOL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SEA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SEA', N'Seattle', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SEA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CLE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CLE', N'Cleveland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CLE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BNA', N'Nashville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOS', N'Boston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUF', N'Buffalo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BUF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BWI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BWI', N'Baltimore', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BWI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHI', N'Chicago', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHS', N'Charleston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CHS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DFW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DFW', N'Dallas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DFW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAY', N'Dayton', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DAY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUB', N'Dublin', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DUB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DTT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DTT', N'Detroit', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DTT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'EWR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'EWR', N'Newark', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'EWR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GEO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GEO', N'Georgetown', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'GEO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GLA', N'Glasgow', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'GLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HNL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HNL', N'Honolulu', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'HNL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAX', N'Los Angeles', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LAX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SFO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SFO', N'San Francisco', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SFO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NYC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NYC', N'New York', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'NYC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAS', N'Las Vegas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LGB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LGB', N'Long Beach', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LGB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ORL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ORL', N'Orlando', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ORL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MEM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MEM', N'Memphis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MEM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MKE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MKE', N'Milwaukee', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MKE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MSP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MSP', N'Minneapolis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MSP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MSY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MSY', N'New Orleans', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MSY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAN', N'San Diego', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NOR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NOR', N'Norfolk', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'NOR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PDX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PDX', N'Portland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'PDX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PHX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PHX', N'Phoenix', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'PHX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RDU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RDU', N'Raleigh', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'RDU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RIC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RIC', N'Richmond', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'RIC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ROC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ROC', N'Rochester', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ROC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAI', N'San Antonio', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAV', N'Savannah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SLC', N'Salt Lake City', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TPA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TPA', N'Tampa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'TPA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TUS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TUS', N'Tucson', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'TUS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YYJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YYJ', N'Victoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'YYJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VAP', N'Valparaiso', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'VAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ABJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ABJ', N'Abidjan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CI'), N'null', N'ABJ', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DHA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DHA', N'Dhahran', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'DHA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RUH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RUH', N'Riyadh', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'RUH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JED') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JED', N'Jeddah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'JED', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KAN', N'Kano', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NG'), N'', N'KAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LOS', N'Lagos', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NG'), N'', N'LOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SYD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SYD', N'Sydney', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'SYD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MEL', N'Melbourne', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'MEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ROM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ROM', N'Roma', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'ROM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PER') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PER', N'Perth', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'PER', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CNS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CNS', N'Cairns', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'CNS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HBA', N'Hobart', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'HBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHD', N'Belfast', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'BHD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MME') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MME', N'Teesside', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'MME', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LBA', N'Leeds', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'LBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LPB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LPB', N'La Paz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'LPB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MID') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MID', N'Merida', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MID', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MZT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MZT', N'Mazatlan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MZT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MTY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MTY', N'Monterrey', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MTY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PVR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PVR', N'Puerto Vallarta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'PVR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VER') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VER', N'Veracruz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'VER', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TAM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TAM', N'Tampico', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'TAM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYM', N'Guaymas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'GYM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GDL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GDL', N'Guadalajara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'GDL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CUN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CUN', N'Cancun', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'CUN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CZM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CZM', N'Cozumel', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'CZM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ACC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ACC', N'Accra', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GH'), N'', N'ACC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ALC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ALC', N'Alicante', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'ALC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AGP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AGP', N'Malaga', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'AGP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BCN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BCN', N'Barcelona', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'BCN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BIO', N'Bilbao', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'BIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GND') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GND', N'Granada', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'GND', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IBZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IBZ', N'Ibiza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'IBZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SVQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SVQ', N'Sevilla', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'SVQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VGO', N'Vigo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VIX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VIX', N'Vitoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VIX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VLC', N'Valencia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZAZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZAZ', N'Zaragoza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'ZAZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SDR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SDR', N'Santander', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'SDR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PNA', N'Pamplona', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'PNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MJV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MJV', N'Murcia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'MJV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAH', N'Menorca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'MAH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AYT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AYT', N'Antalya', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TR'), N'', N'AYT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANK', N'Ankara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TR'), N'', N'ANK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ADD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ADD', N'Addis Ababa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ET'), N'', N'ADD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ADE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ADE', N'Aden', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'YE'), N'', N'ADE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BAQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BAQ', N'Barranquilla', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'ATL', N'BAQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTG', N'Cartagena', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'BOL', N'CTG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CLO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CLO', N'Cali', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'VAL', N'CLO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'000001') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'000001', N'chigorodo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'', N'000001', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHI', N'Bahia Blanca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'BHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUE', N'Buenos Aires', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'BUE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SLZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SLZ', N'San Luis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'SLZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KRS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KRS', N'Kristiansand', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'KRS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SVG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SVG', N'Stavanger', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'SVG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGO', N'Bergen', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'BGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OSL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OSL', N'Oslo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'OSL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAS', N'Casablanca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'CAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RAK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RAK', N'Marrakech', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'RAK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RBA', N'Rabat', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'RBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'STR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'STR', N'Stuttgart', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'STR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LEJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LEJ', N'Leipzig', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'LEJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MUC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MUC', N'Munich', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'MUC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUS', N'Dusseldorf', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'DUS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FRA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FRA', N'Frankfurt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'FRA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PAR', N'Paris', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'PAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOD', N'Bordeaux', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'BOD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LYS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LYS', N'Lyon', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LYS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LHV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LHV', N'Le Havre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LHV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LIL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LIL', N'Lille', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LIL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MMA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MMA', N'Malmo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SE'), N'', N'MMA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DEL', N'Delhi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IN'), N'', N'DEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAA', N'Madras', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IN'), N'', N'MAA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DPS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DPS', N'Denpasar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ID'), N'', N'DPS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JKT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JKT', N'Jakarta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ID'), N'', N'JKT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BRI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BRI', N'Bari', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'BRI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MIL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MIL', N'Milan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'MIL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMO', N'Palermo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'PMO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'POA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'POA', N'Porto Alegre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'POA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'REC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'REC', N'Recife', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'REC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SSA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SSA', N'Salvador', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'SSA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JPA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JPA', N'Joao Pessoa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'JPA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MCZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MCZ', N'Maceio', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'MCZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAT', N'Natal', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'NAT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BSB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BSB', N'Brasilia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BSB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BZC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BZC', N'Buzios', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BZC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BEL', N'Belem', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AJU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AJU', N'Aracaju', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'AJU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHZ', N'Belo Horizonte', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BHZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CWB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CWB', N'Curitiba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'CWB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CGB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CGB', N'Cuiaba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'CGB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IOS', N'Ilheus', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'IOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYN', N'Goiania', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'GYN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FOR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FOR', N'Fortaleza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'FOR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RIO', N'Rio De Janeiro', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'RIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHC', N'Christchurch', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'CHC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AKL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AKL', N'Auckland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'AKL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'WLG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'WLG', N'Wellington', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'WLG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PRY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PRY', N'Pretoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'PRY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PEZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PEZ', N'Port Elizabeth', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'PEZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUR', N'Durban', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'DUR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTW', N'Cape Town', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'CTW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ALP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ALP', N'Aleppo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SY'), N'', N'ALP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAI', N'Cairo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EG'), N'', N'CAI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AMM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AMM', N'Amman', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JO'), N'', N'AMM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AMS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AMS', N'Amsterdam', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NL'), N'', N'AMS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANF', N'Antofagasta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ANF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ARI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ARI', N'Arica', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ARI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IQQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IQQ', N'Iquique', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'IQQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMC', N'Puerto Montt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'PMC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PUQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PUQ', N'Punta Arenas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'PUQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZCO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZCO', N'Temuco', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ZCO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LSC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LSC', N'La Serena', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'LSC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANR', N'Antwerp', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BE'), N'', N'ANR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KUL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KUL', N'Kuala Lumpur', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MY'), N'', N'KUL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PEN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PEN', N'Penang', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MY'), N'', N'PEN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MPM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MPM', N'Maputo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MZ'), N'', N'MPM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'APW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'APW', N'Apia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'WS'), N'', N'APW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AQP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AQP', N'Arequipa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PE'), N'', N'AQP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OSA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OSA', N'Osaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'OSA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FUK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FUK', N'Fukuoka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'FUK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NGO', N'Nagoya', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'NGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OKA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OKA', N'Okinawa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'OKA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ASM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ASM', N'Asmara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ER'), N'', N'ASM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ASU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ASU', N'Asuncion', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PY'), N'', N'ASU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FPO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FPO', N'Freeport', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BS'), N'', N'FPO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAS', N'Nassau', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BS'), N'', N'NAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AUA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AUA', N'Aruba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AW'), N'', N'AUA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AUH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AUH', N'Abu Dhabi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'AUH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DXB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DXB', N'Dubai', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'DXB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SHJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SHJ', N'Sharjah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'SHJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PPT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PPT', N'Papeete', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PF'), N'', N'PPT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VRA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VRA', N'Varadero', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'VRA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZLO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZLO', N'Manzanillo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'ZLO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HOG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HOG', N'Holguin', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'HOG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AVI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AVI', N'Ciego De Avila', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'AVI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MNL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MNL', N'Manila', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PH'), N'', N'MNL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BAH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BAH', N'Bahrain', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BH'), N'', N'BAH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GBE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GBE', N'Gaborone', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BW'), N'', N'GBE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TSR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TSR', N'Timisoara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'RO'), N'', N'TSR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BDA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BDA', N'Bermuda', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BM'), N'', N'BDA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BEY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BEY', N'Beirut', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LB'), N'', N'BEY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAN', N'Nadi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FJ'), N'', N'NAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SUV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SUV', N'Suva', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FJ'), N'', N'SUV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGF', N'Bangui', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CF'), N'', N'BGF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGI', N'Barbados', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BB'), N'', N'BGI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGW', N'Baghdad', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IQ'), N'', N'BGW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BSR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BSR', N'Basra', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IQ'), N'', N'BSR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAN', N'Guangzhou', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'CAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJS', N'Beijing', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'BJS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DLC', N'Dalian', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'DLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SHA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SHA', N'Shanghai', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'SHA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJL', N'Banjul', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GM'), N'', N'BJL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJM', N'Bujumbura', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BI'), N'', N'BJM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BKK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BKK', N'Bangkok', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TH'), N'', N'BKK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HKT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HKT', N'Phuket', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TH'), N'', N'HKT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BKO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BKO', N'Bamako', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ML'), N'', N'BKO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CCS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CCS', N'Caracas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'CCS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMV', N'Porlamar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'PMV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAR', N'Maracaibo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'MAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LLW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LLW', N'Lilongwe', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MW'), N'', N'LLW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BLZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BLZ', N'Blantyre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MW'), N'', N'BLZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BON') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BON', N'Bonaire', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AN'), N'', N'BON', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLH', N'Mulhouse', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CH'), N'', N'MLH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZRH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZRH', N'Zurich', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CH'), N'', N'ZRH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SDQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SDQ', N'Santo Domingo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DO'), N'', N'SDQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BTS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BTS', N'Bratislava', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SK'), N'', N'BTS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUD', N'Budapest', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HU'), N'', N'BUD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUQ', N'Bulawayo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZW'), N'', N'BUQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HRE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HRE', N'Harare', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZW'), N'', N'HRE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BZV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BZV', N'Brazzaville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CG'), N'', N'BZV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CBB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CBB', N'Cochabamba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BO'), N'', N'CBB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PAP', N'Port Au Prince', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HT'), N'', N'PAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAY', N'Cayenne', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GF'), N'', N'CAY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FAO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FAO', N'Faro', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PT'), N'', N'FAO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SNN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SNN', N'Shannon', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IE'), N'', N'SNN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAC', N'Dhaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BD'), N'', N'DAC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CKY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CKY', N'Conakry', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GN'), N'', N'CKY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CMB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CMB', N'Colombo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LK'), N'', N'CMB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'COO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'COO', N'Cotonou', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BJ'), N'', N'COO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYE', N'Guayaquil', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EC'), N'', N'GYE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'UIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'UIO', N'Quito', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EC'), N'', N'UIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YTO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YTO', N'Toronto', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YTO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YEG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YEG', N'Edmonton', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YEG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YUL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YUL', N'Montreal', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YUL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YOW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YOW', N'Ottawa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YOW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YYC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YYC', N'Calgary', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YYC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YQG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YQG', N'Windsor', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YQG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YWG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YWG', N'Winnipeg', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YWG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VAN', N'Vancouver', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'VAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CYR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CYR', N'Colonia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'CYR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PDP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PDP', N'Punta Del Este', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'PDP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MVD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MVD', N'Montevideo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'MVD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAR', N'Dar Es Salaam', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TZ'), N'', N'DAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZAG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZAG', N'Zagreb', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HR'), N'', N'ZAG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DKR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DKR', N'Dakar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SN'), N'', N'DKR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DLA', N'Douala', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CM'), N'', N'DLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YAO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YAO', N'Yaounde', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CM'), N'', N'YAO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DOH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DOH', N'Doha', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'QA'), N'', N'DOH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LCA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LCA', N'Larnaca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CY'), N'', N'LCA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PFO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PFO', N'Paphos', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CY'), N'', N'PFO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'WDH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'WDH', N'Windhoek', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NA'), N'', N'WDH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TLV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TLV', N'Tel Aviv', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IL'), N'', N'TLV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JRS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JRS', N'Jerusalem', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IL'), N'', N'JRS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FBM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FBM', N'Lubumbashi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CD'), N'', N'FBM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FIH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FIH', N'Kinshasa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CD'), N'', N'FIH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FNA', N'Freetown', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SL'), N'', N'FNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GIB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GIB', N'Gibraltar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GI'), N'', N'GIB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GRZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GRZ', N'Graz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'GRZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KLU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KLU', N'Klagenfurt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'KLU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LNZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LNZ', N'Linz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'LNZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLA', N'Malta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MT'), N'', N'MLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KHH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KHH', N'Kaohsiung', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TW'), N'', N'KHH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TPE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TPE', N'Taipei', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TW'), N'', N'TPE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KHI', N'Karachi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PK'), N'', N'KHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ISB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ISB', N'Islamabad', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PK'), N'', N'ISB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HEL', N'Helsinki', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FI'), N'', N'HEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HKG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HKG', N'Hong Kong', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HK'), N'', N'HKG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IEV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IEV', N'Kiev', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UA'), N'', N'IEV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KGL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KGL', N'Kigali', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'RW'), N'', N'KGL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KIN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KIN', N'Kingston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JM'), N'', N'KIN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MBJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MBJ', N'Montego Bay', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JM'), N'', N'MBJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KRT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KRT', N'Khartoum', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SD'), N'', N'KRT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KWI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KWI', N'Kuwait', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'KW'), N'', N'KWI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAD', N'Luanda', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AO'), N'', N'LAD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LBV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LBV', N'Libreville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GA'), N'', N'LBV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LFW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LFW', N'Lome', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TG'), N'', N'LFW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTF', N'CARTAGO', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CR'), N'', N'CTF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LJU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LJU', N'Ljubljana', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SI'), N'', N'LJU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LUN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LUN', N'Lusaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZM'), N'', N'LUN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NBO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NBO', N'Nairobi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'KE'), N'', N'NBO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MCT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MCT', N'Muscat', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'OM'), N'', N'MCT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MGA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MGA', N'Managua', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NI'), N'', N'MGA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLW', N'Monrovia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LR'), N'', N'MLW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NKC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NKC', N'Nouakchott', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MR'), N'', N'NKC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NIM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NIM', N'Niamey', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NE'), N'', N'NIM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PBM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PBM', N'Paramaribo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SR'), N'', N'PBM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAP', N'San Pedro Sula', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HN'), N'', N'SAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TGU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TGU', N'Tegucigalpa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HN'), N'', N'TGU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAL', N'San Salvador', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SV'), N'', N'SAL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SEZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SEZ', N'Mahe Island', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SC'), N'', N'SEZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SJJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SJJ', N'Sarajevo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BA'), N'', N'SJJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SOF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SOF', N'Sofia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BG'), N'', N'SOF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'THR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'THR', N'Teheran', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IR'), N'', N'THR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TIA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TIA', N'Tirana', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AL'), N'', N'TIA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PUJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PUJ', N'PUNTA CANA', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DO'), NULL, N'PUJ', 1);

-- 7.3 Aeropuertos (433 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOG', N'Aeropuerto Internacional El Dorado', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MDE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MDE', N'Aeropuerto Internacional Jose Maria Cordova', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MDE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MIA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MIA', N'Miami International Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAD', N'Adolfo Suarez Madrid-Barajas', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AAP', N'Andrau Airpark', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ABJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ABJ', N'Felix Houphouet Boigny Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ABJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ACC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ACC', N'Kotoka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ACC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ADD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ADD', N'Bole Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ADD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ADE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ADE', N'Yemen Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ADE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AEP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AEP', N'Jorge Newbery', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AGB', N'Mehlhausen', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MUC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AGP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AGP', N'Malaga Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AGP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AJU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AJU', N'Santa Maria Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AJU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AKL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AKL', N'Auckland Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AKL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ALC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ALC', N'Alicante Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ALC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ALP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ALP', N'Nejrab Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ALP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AMM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AMM', N'Queen Alia Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AMM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AMS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AMS', N'Schiphol Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AMS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANC', N'Anchorage Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANF', N'Cerro Moreno Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANK', N'Etimesgut Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANR', N'Deurne Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AOH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AOH', N'Allen County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'APA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'APA', N'Centennial Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'APW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'APW', N'Apia Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'APW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AQP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AQP', N'Rodriguez Ballon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AQP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ARI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ARI', N'Chacalluta Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ARI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ASM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ASM', N'Asmara Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ASM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ASU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ASU', N'Salvio Pettirosse Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ASU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ATL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ATL', N'Hartsfield Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUA', N'Reina Beatrix Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AUA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUH', N'Dhabi Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AUH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUO', N'Auburn Opelika', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AVI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AVI', N'Maximo Gomez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AVI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AYT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AYT', N'Antalya Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AYT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BAH', N'Muharraq Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BAH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BCN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BCN', N'Barcelona Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BCN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BDA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BDA', N'Bermuda International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BDA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BDL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BDL', N'Bradley Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BEL', N'Val De Cans Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BER', N'Berlin Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BEY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BEY', N'Beirut Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BEY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BFI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BFI', N'Seattle Boeing Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BFS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BFS', N'Belfast Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGF', N'Bangui Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGI', N'Grantley Adams Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGO', N'Flesland Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGW', N'Al Muthana Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BHD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BHD', N'Belfast City Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BHI', N'Commandante Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BIO', N'Sondica Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJL', N'Yundum Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJM', N'Bujumbura Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJS', N'Beijing', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKK', N'Bangkok Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BKK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKL', N'Burke Lakefront Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKO', N'Senou Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BKO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BLA', N'Gen J A Anzoategui Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BCN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BLZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BLZ', N'Chileka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BLZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BNA', N'Nashville Metro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOD', N'Merignac Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BON') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BON', N'Flamingo Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BON'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOS', N'Logan Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BRI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BRI', N'Bari Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BRI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BSB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BSB', N'Brasilia Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BSB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BSR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BSR', N'Basra Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BSR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BTS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BTS', N'Ivanka Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BTS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUD', N'Ferihegy Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUE', N'Buenos Aires Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUF', N'Greater Buffalo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUQ', N'Bulawayo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BWI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BWI', N'Baltimore Washington Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BWI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BZC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BZC', N'Buzios Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BZC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BZV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BZV', N'Maya Maya Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BZV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAI', N'Cairo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAN', N'Baiyun Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAS', N'Anfa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAY', N'Rochambeau Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CBB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CBB', N'J Wilsterman Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CBB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CCS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CCS', N'Simon Bolivar Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CCS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CDG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CDG', N'Charles De Gaulle Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGB', N'Marechal Rondon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CGB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGF', N'Cuyahoga County Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGK', N'Soekarno Hatta Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGX', N'Meigs Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHC', N'Christchurch Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHI', N'Chicago Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHS', N'Charleston Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CKY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CKY', N'Conakry Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CKY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLE', N'Hopkins Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLU', N'Columbus Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMB', N'Katunayake Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMH', N'Port Columbus Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMN', N'Mohamed V Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CNF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CNF', N'Tancredo Neves Intl Arpt.', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CNS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CNS', N'Cairns Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CNS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'COO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'COO', N'Cotonou Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'COO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CPT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CPT', N'Cape Town International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CTW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CRW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CRW', N'Yeager Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CSG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CSG', N'Columbus Metro Ft Benning Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CUN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CUN', N'Cancun Aeropuerto Internacional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CUN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CUS', N'Columbus Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CWB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CWB', N'Afonso Pena Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CWB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CXH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CXH', N'Coal Harbor Sea Plane Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CYR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CYR', N'Colonia Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CYR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CZM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CZM', N'Aeropuerto Intl De Cozumel', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CZM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAC', N'Zia Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAL', N'Love Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAR', N'Es Salaam Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAY', N'Dayton International Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DBN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DBN', N'Dublin Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DEL', N'Delhi Indira Gandhi Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DEN', N'Denver Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DET') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DET', N'Detroit City Apt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DFW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DFW', N'Dallas Ft Worth Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DHA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DHA', N'Dhahran Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DHA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DKR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DKR', N'Yoff Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DKR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DLA', N'Douala Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DLC', N'Dalian Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DOH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DOH', N'Doha Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DOH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DPS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DPS', N'Ngurah Rai Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DPS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DTW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DTW', N'Detroit Metro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUB', N'Dublin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUR', N'Durban International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUS', N'Dusseldorf Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DWH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DWH', N'David Wayne Hooks Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DXB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DXB', N'Dubai Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DXB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EAP', N'Mulhouse/Basel Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EFD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EFD', N'Ellington Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ERS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ERS', N'Eros Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WDH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ESB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ESB', N'Esenboga Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EWR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EWR', N'Newark Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'EWR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EZE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EZE', N'Ministro Pistarini', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FAO', N'Faro Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FBM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FBM', N'Luano', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FBM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FBU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FBU', N'Fornebu Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FIH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FIH', N'Kinshasa Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FIH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FNA', N'Lungi Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FOR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FOR', N'Pinto Martines Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FOR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FPO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FPO', N'Freeport Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FPO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FRA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FRA', N'Frankfurt Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FTY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FTY', N'Fulton Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FUK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FUK', N'Itazuke Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FUK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GBE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GBE', N'Gaborone Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GBE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GDL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GDL', N'Miguel Hidalgo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GDL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GED', N'Sussex County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GEO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GEN', N'Gardermoen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GEO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GEO', N'Timehri Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GEO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GGW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GGW', N'International Glasgow', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GIB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GIB', N'North Front Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GIB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GIG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GIG', N'Rio Internacional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GLA', N'Glasgow Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GRX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GRX', N'Granada Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GND'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GRZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GRZ', N'Thalerhof Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GRZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GTR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GTR', N'Golden Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYE', N'Simon Bolivar Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYM', N'Gen Jose M Yanez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYN', N'Santa Genoveva', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HBA', N'Hobart Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HEL', N'Helsinki Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HFD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HFD', N'Brainard Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HKG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HKG', N'Hong Kong Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HKG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HKT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HKT', N'Phuket Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HMA', N'Malmo City Hvc Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HNL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HNL', N'Honolulu Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HNL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HOG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HOG', N'Frank Pias Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HOU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HOU', N'Houston Hobby Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HRE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HRE', N'Harare Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HRE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IAH', N'Houston Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IBZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IBZ', N'Ibiza Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IBZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IEV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IEV', N'Zhulhany Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IEV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IOS', N'Eduardo Gomes Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IQQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IQQ', N'Cavancha Chucumata Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IQQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ISB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ISB', N'Islamabad Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ISB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ITM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ITM', N'Itami Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IWS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IWS', N'West Houston', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JAJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JAJ', N'Perimeter Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JAO', N'Beaver Ruin Helpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JBP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JBP', N'Commerce Business Plaza Heliport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JCC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JCC', N'China Basin Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JDP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JDP', N'Issy Les Moulineaux Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JED', N'Jeddah Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JED'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JFK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JFK', N'John F Kennedy Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JKT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JKT', N'Kemayoran Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JPA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JPA', N'Castro Pinto Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JRE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JRE', N'East 60th St Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JRS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JRS', N'Atarot Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JRS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JTO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JTO', N'Thousand Oaks Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KAN', N'Aminu Kano Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KBP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KBP', N'Borispol Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IEV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KGL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KGL', N'Kayibanda Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KGL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KHH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KHH', N'Kaohsiung Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KHH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KHI', N'Karachi Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KIN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KIN', N'Norman Manly Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KIX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KIX', N'Kansai International Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KLU', N'Klagenfurt Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KLU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KRS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KRS', N'Kjevik Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KRS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KRT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KRT', N'Civil Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KRT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KTP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KTP', N'Tinson Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KUL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KUL', N'Subang Kuala Lumpur Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KWI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KWI', N'Kuwait Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KWI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAD', N'Four De Fevereiro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAP', N'Aeropuerto Gen Marquez De Leon', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LPB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAS', N'McCarran Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAX', N'Los Angeles Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBA', N'Leeds Bradford Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBG', N'Le Bourget Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBH', N'Palm Beach Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBV', N'Libreville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LBV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LCA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LCA', N'Larnaca Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LCA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LEH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LEH', N'Octeville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LHV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LEJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LEJ', N'Schkeuditz Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LEJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LFW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LFW', N'Lome Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LGA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LGA', N'La Guardia', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LGB', N'Long Beach Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LGB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIL', N'Lesquin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIM', N'Nlima Intl Jorge Chavez', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIN', N'Linate Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LJU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LJU', N'Brnik Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LJU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LKE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LKE', N'Lake Union Seaplane Base', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LLW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LLW', N'Lilongwe Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LNZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LNZ', N'Hoersching Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LNZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LOS', N'Murtala Muhammed Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LPB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LPB', N'El Alto Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LPB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LSC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LSC', N'La Florida', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LSC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LUN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LUN', N'Lusaka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LUN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LUQ', N'San Luis Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SLZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LVS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LVS', N'Las Vegas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LYS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LYS', N'Satolas Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LYS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAA', N'Meenambarkkam Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAH', N'Aerop De Menorca', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAR', N'La Chinita Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MBJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MBJ', N'Sangster Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MBJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCO', N'Orlando Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ORL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCT', N'Seeb Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MCT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCZ', N'Palmeres Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MCZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MDW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MDW', N'Midway', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEB', N'Essendon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEL', N'Tullamarine Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEM', N'Memphis Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MGA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MGA', N'Augusto C Sandino', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MGA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MID') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MID', N'Merida Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MID'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MIL', N'Milan Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MJV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MJV', N'San Javier Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MJV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MKE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MKE', N'General Mitchell Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MKE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLA', N'Luqa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLB', N'Melbourne Regional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLH', N'Euroairport French', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLW', N'Sprigg Payne Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MMA', N'Malmo Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MME') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MME', N'Teesside Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MME'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MMX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MMX', N'Sturup Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MNL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MNL', N'Ninoy Aquino Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MNL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MPM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MPM', N'Maputo Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MPM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MRD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MRD', N'Alberto Carnevalli Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MID'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MSP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MSP', N'Minneapolis St Paul Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MSY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MSY', N'Moisant Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MTC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MTC', N'Selfridge Air Natl Guard', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MTY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MTY', N'Escobedo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MTY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MUC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MUC', N'Franz Josef Strauss Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MUC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MVD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MVD', N'Carrasco Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MVD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MXP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MXP', N'Malpensa Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MYF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MYF', N'Montogomery Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MZO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MZO', N'Sierra Maestra Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MZT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MZT', N'Buelina Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MZT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAN', N'Nadi Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAS', N'Nassau Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAT', N'Augusto Severo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NBO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NBO', N'Jomo Kenyatta Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NBO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NEW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NEW', N'New Lakefront Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NGO', N'Komaki Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NIM', N'Niamey Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NKC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NKC', N'Nouakchott Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NKC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NQA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NQA', N'Memphis Naval Air Station', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NSI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NSI', N'Nsimalen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NYC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NYC', N'New York City Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OFK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OFK', N'Karl Stefan Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NOR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OKA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OKA', N'Naha Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OKA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OLU', N'Columbus Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OPF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OPF', N'Opa Locka Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORD', N'OHare Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORL', N'Herndon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ORL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORY', N'Orly Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSA', N'Osaka', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSL', N'Oslo Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSU', N'Ohio State Univ Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PAP', N'Mais Gate Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PAR', N'Paris Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PBM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PBM', N'Zanderij Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PBM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDK', N'Dekalb Peachtree', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDP', N'Cap Curbelo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDX', N'Portland Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PEK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PEK', N'Beijing Capital Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PEN', N'Penang Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PER', N'Perth Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PFO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PFO', N'Paphos Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PHT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PHT', N'Henry County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PHX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PHX', N'Sky Harbor Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PHX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PID') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PID', N'Paradise Island Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PIK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PIK', N'Prestwick Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PLZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PLZ', N'Port Elizabeth Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PEZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMC', N'Tepual Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMO', N'Punta Raisi Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMV', N'Delcaribe Gen S Marino Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PNA', N'Pamplona Noain Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'POA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'POA', N'Porto Alegre Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'POA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PPT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PPT', N'Intl Tahiti Faaa', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PPT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PRX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PRX', N'Paris Cox Field Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PRY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PRY', N'Wonderboom Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PRY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PSK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PSK', N'New River Valley Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PTJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PTJ', N'Portland Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PUQ', N'Presidente Ibanez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PUQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PVR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PVR', N'Ordaz Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PVR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PWK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PWK', N'Pal Waukee Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PWM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PWM', N'Portland Intl Jetport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QBA', N'San Francisco Bay Area Airpts', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QDF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QDF', N'Dallas Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QGV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QGV', N'Neu Isenburg Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QHO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QHO', N'Houston Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QKN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QKN', N'Kingston Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QLA', N'Los Angeles Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QMI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QMI', N'Miami Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QRV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QRV', N'Arras Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QSE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QSE', N'Seattle Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RAC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RAC', N'Horlick Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MKE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RAK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RAK', N'Menara Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RAK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RBA', N'Sale Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RDU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RDU', N'Raleigh Durham Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RDU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'REC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'REC', N'Recife Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'REC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RIC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RIC', N'Byrd Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RIO', N'Rio De Janeiro Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RMA', N'Roma Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ROB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ROB', N'Roberts Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ROC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ROC', N'Monroe Cty Arpt New York', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RSE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RSE', N'Au Rose Bay Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RST') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RST', N'Rochester Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RUH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RUH', N'King Khaled Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RUH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAL', N'El Salvador Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAN', N'Lindbergh Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAP', N'La Mesa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAT', N'San Antonio Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAV', N'Travis Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDA', N'Saddam Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDM', N'Brown Fld Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDQ', N'Las Americas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDR', N'Santander Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDU', N'Santos Dumont Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDV', N'Dov Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TLV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SEA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SEA', N'Seattle Tacoma Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SEZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SEZ', N'Seychelles Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SFO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SFO', N'San Francisco Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SHA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SHA', N'Shanghai Intl Hongqiao', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SHA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SHJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SHJ', N'Sharjah Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SHJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SJJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SJJ', N'Butmir Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SJJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SLC', N'Salt Lake City Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SMO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SMO', N'Santa Monica Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SNN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SNN', N'Shannon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SNN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SOF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SOF', N'Sofia Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SOF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SSA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SSA', N'Dois De Julho Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'STD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'STD', N'Mayor Humberto Vivas Guerrero Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'STR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'STR', N'Eghterdingen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'STR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SUV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SUV', N'Nausori Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SUV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVG', N'Sola Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SVG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVQ', N'San Pablo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SVQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVZ', N'San Antonio Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SXF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SXF', N'Schoenefeld Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SYD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SYD', N'Sydney Kingsford Smith Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TAM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TAM', N'General F Javier Mina', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TAM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TGU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TGU', N'Toncontin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TGU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'THF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'THF', N'Tempelhof Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'THR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'THR', N'Mehrabad Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'THR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TIA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TIA', N'Rinas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TLV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TLV', N'Ben Gurion Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TLV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TMB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TMB', N'Tamiami Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPA', N'Tampa Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPE', N'Chiang Kai Shek Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPF', N'Peter O Knight Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TSR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TSR', N'Timisoara Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TSR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TSS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TSS', N'East 34th St Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TUS', N'Tucson Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TUS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TXL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TXL', N'Tegel Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UBS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UBS', N'Lowndes Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UIO', N'Mariscal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'UIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UIZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UIZ', N'Berz Macomb Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VCT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VCT', N'Victoria Regional Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VER', N'Las Bajadas General Heriberto Jara', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VGO', N'Vigo Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VGT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VGT', N'Las Vegas North Air Terminal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VIT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VIT', N'Vitoria Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VIX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VIX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VIX', N'Eurico Sales Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VIX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VLC', N'Valencia Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VNY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VNY', N'Los Angeles Van Nuys Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VPZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VPZ', N'Porter County', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VRA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VRA', N'Juan Gualberto Gomez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WDH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WDH', N'Windhoek Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WDH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WIL', N'Wilson Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NBO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WLG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WLG', N'Wellington Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WLG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WZY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WZY', N'Seaplane Base Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YAO', N'Yaounde Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YBZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YBZ', N'Downtown Hlpt Toronto', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YEA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YEA', N'Edmonton Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YED', N'Namao Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YEG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YEG', N'Edmonton Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YGK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YGK', N'Norman Rodgers Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YHU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YHU', N'St Hubert Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YIP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YIP', N'Willow Run Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YKZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YKZ', N'Buttonville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMQ', N'Montreal Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMX', N'Mirabel Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMY', N'Victoria Stol', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YOW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YOW', N'Ottawa Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YOW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQF', N'Red Deer Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQG', N'Windsor Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YQG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQY', N'Sydney Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YTO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YTO', N'Toronto Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YTZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YTZ', N'Toronto City Centre Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YUL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YUL', N'Dorval Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YVR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YVR', N'Vancouver Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YWG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YWG', N'Winnipeg Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YWG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YWH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YWH', N'Inner Harbor Sea Plane Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YXD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YXD', N'Edmonton Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYC', N'Calgary Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYJ', N'Victoria Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYZ', N'Lester B Pearson Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZAG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZAG', N'Zagreb Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZAG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZAZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZAZ', N'Zaragoza Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZAZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZCO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZCO', N'Manquehue Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZCO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZLO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZLO', N'Aeropuerto Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZRH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZRH', N'Zurich Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZRH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CTG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CTG', N'Aeropuerto Internacional Rafael Nunez', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CTG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLO', N'Alfonso Bonilla Arag¢n', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DIM', N'Aeropuerto Olaya Herrera', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MDE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BAQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BAQ', N'AEROPUERTO ERNESTO CORTIZO', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BAQ'), 1);

-- 7.4 Formas de Pago (2 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Payment] WHERE [code] = N'EFE') INSERT INTO dbo.[Payment] ([code], [name], [isActive]) VALUES (N'EFE', N'Efectivo', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Payment] WHERE [code] = N'TC') INSERT INTO dbo.[Payment] ([code], [name], [isActive]) VALUES (N'TC', N'Tarjeta De Credito', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = 'PERMITIR_COTIZACION_SIN_PRODUCTOS')
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'Permitir Cotizaciones sin Productos (Solo Cliente/Origen)', '1');


GO

-- --------------------------------------------------------------------------
-- SECCIÓN 3: COMPILACIÓN Y ACTUALIZACIÓN DE PROCEDIMIENTOS Y FUNCIONES
-- --------------------------------------------------------------------------
-- ============================================================================
-- AGENCIASNEW - PROCEDIMIENTOS ALMACENADOS Y FUNCIONES EN SQL SERVER (T-SQL)
-- Archivo: SQL/SqlServer/03_Functions_And_SPs.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Safeguards de Columnas para Tablas de Zeus ERP y Korex
IF OBJECT_ID('dbo.ImpRet', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo') ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'bl_contabilizarCxPProvee') ALTER TABLE dbo.ImpRet ADD bl_contabilizarCxPProvee BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'bl_contabilizar_proveedor') ALTER TABLE dbo.ImpRet ADD bl_contabilizar_proveedor BIT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'cd_cuenta') ALTER TABLE dbo.ImpRet ADD cd_cuenta VARCHAR(20) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'bl_inactivo') ALTER TABLE dbo.ImpRet ADD bl_inactivo BIT NULL DEFAULT 0;
END;
GO
IF OBJECT_ID('dbo.CotizacionServicios_PaxAdicional', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'in_edad') ALTER TABLE dbo.CotizacionServicios_PaxAdicional ADD in_edad INT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') AND name = 'cd_tiquete') ALTER TABLE dbo.CotizacionServicios_PaxAdicional ADD cd_tiquete VARCHAR(50) NULL;
END;
GO
IF OBJECT_ID('dbo.FacturaServicios_PaxAdicional', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FacturaServicios_PaxAdicional') AND name = 'in_edad') ALTER TABLE dbo.FacturaServicios_PaxAdicional ADD in_edad INT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FacturaServicios_PaxAdicional') AND name = 'cd_tiquete') ALTER TABLE dbo.FacturaServicios_PaxAdicional ADD cd_tiquete VARCHAR(50) NULL;
END;
GO
IF OBJECT_ID('dbo.CotizacionServicios', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CotizacionServicios') AND name = 'in_EdadPax')
    ALTER TABLE dbo.CotizacionServicios ADD in_EdadPax INT NULL DEFAULT 0;
GO
IF OBJECT_ID('dbo.Fac_Servicios', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fac_Servicios') AND name = 'in_EdadPax')
    ALTER TABLE dbo.Fac_Servicios ADD in_EdadPax INT NULL DEFAULT 0;
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
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Descripcion') ALTER TABLE dbo.VariableDefinicion ADD Descripcion VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'Presentacion') ALTER TABLE dbo.VariableDefinicion ADD Presentacion VARCHAR(250) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VariableDefinicion') AND name = 'TipoDato') ALTER TABLE dbo.VariableDefinicion ADD TipoDato VARCHAR(50) NULL;
END;
GO

-- Safeguards para tablas maestras
IF OBJECT_ID('dbo.Branch', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Branch') AND name = 'createdAt') ALTER TABLE dbo.[Branch] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Branch') AND name = 'updatedAt') ALTER TABLE dbo.[Branch] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Implant', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Implant') AND name = 'createdAt') ALTER TABLE dbo.[Implant] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Implant') AND name = 'updatedAt') ALTER TABLE dbo.[Implant] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Seller', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Seller') AND name = 'createdAt') ALTER TABLE dbo.[Seller] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Seller') AND name = 'updatedAt') ALTER TABLE dbo.[Seller] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.TicketPrinter', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketPrinter') AND name = 'createdAt') ALTER TABLE dbo.[TicketPrinter] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketPrinter') AND name = 'updatedAt') ALTER TABLE dbo.[TicketPrinter] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.ChargeAndTax', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChargeAndTax') AND name = 'inNationality') ALTER TABLE dbo.[ChargeAndTax] ADD [inNationality] INT NULL DEFAULT 1;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChargeAndTax') AND name = 'createdAt') ALTER TABLE dbo.[ChargeAndTax] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChargeAndTax') AND name = 'updatedAt') ALTER TABLE dbo.[ChargeAndTax] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Client', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Client') AND name = 'createdAt') ALTER TABLE dbo.[Client] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Client') AND name = 'updatedAt') ALTER TABLE dbo.[Client] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Provider', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Provider') AND name = 'createdAt') ALTER TABLE dbo.[Provider] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Provider') AND name = 'updatedAt') ALTER TABLE dbo.[Provider] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.ProviderType', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ProviderType') AND name = 'createdAt') ALTER TABLE dbo.[ProviderType] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ProviderType') AND name = 'updatedAt') ALTER TABLE dbo.[ProviderType] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Product') AND name = 'createdAt') ALTER TABLE dbo.[Product] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Product') AND name = 'updatedAt') ALTER TABLE dbo.[Product] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.Prestadora', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Prestadora') AND name = 'createdAt') ALTER TABLE dbo.[Prestadora] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Prestadora') AND name = 'updatedAt') ALTER TABLE dbo.[Prestadora] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.MasterVariable', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MasterVariable') AND name = 'createdAt') ALTER TABLE dbo.[MasterVariable] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MasterVariable') AND name = 'updatedAt') ALTER TABLE dbo.[MasterVariable] ADD [updatedAt] DATETIME2 NULL;
END;
GO
IF OBJECT_ID('dbo.SystemParameter', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SystemParameter') AND name = 'createdAt') ALTER TABLE dbo.[SystemParameter] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SystemParameter') AND name = 'updatedAt') ALTER TABLE dbo.[SystemParameter] ADD [updatedAt] DATETIME2 NULL;
END;
GO

-- Safeguards para dbo.TransactionConsecutive
IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransactionConsecutive') AND name = 'padding') ALTER TABLE dbo.[TransactionConsecutive] ADD [padding] INT NULL DEFAULT 4;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransactionConsecutive') AND name = 'updatedAt') ALTER TABLE dbo.[TransactionConsecutive] ADD [updatedAt] DATETIME2 NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransactionConsecutive') AND name = 'createdAt') ALTER TABLE dbo.[TransactionConsecutive] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
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
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductTax') AND name = 'valueSnapshot') ALTER TABLE dbo.InvoicesProductTax ADD valueSnapshot FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductTax') AND name = 'valueTypeSnapshot') ALTER TABLE dbo.InvoicesProductTax ADD valueTypeSnapshot VARCHAR(50) NULL DEFAULT 'PERCENTAGE';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicesProductTax') AND name = 'isMain') ALTER TABLE dbo.InvoicesProductTax ADD isMain BIT NULL DEFAULT 0;
    ALTER TABLE dbo.InvoicesProductTax ALTER COLUMN valueSnapshot FLOAT NULL;
    ALTER TABLE dbo.InvoicesProductTax ALTER COLUMN valueTypeSnapshot VARCHAR(50) NULL;
END;
GO
IF OBJECT_ID('dbo.QuotationProductTax', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'rate') ALTER TABLE dbo.QuotationProductTax ADD rate FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'valueSnapshot') ALTER TABLE dbo.QuotationProductTax ADD valueSnapshot FLOAT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'valueTypeSnapshot') ALTER TABLE dbo.QuotationProductTax ADD valueTypeSnapshot VARCHAR(50) NULL DEFAULT 'PERCENTAGE';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.QuotationProductTax') AND name = 'isMain') ALTER TABLE dbo.QuotationProductTax ADD isMain BIT NULL DEFAULT 0;
    ALTER TABLE dbo.QuotationProductTax ALTER COLUMN valueSnapshot FLOAT NULL;
    ALTER TABLE dbo.QuotationProductTax ALTER COLUMN valueTypeSnapshot VARCHAR(50) NULL;
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
IF OBJECT_ID('dbo.TicketType', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketType') AND name = 'createdAt') ALTER TABLE dbo.[TicketType] ADD [createdAt] DATETIME2 NULL DEFAULT GETDATE();
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TicketType') AND name = 'updatedAt') ALTER TABLE dbo.[TicketType] ADD [updatedAt] DATETIME2 NULL;
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

-- 2.0. spObtenerSiguienteConsecutivo
IF OBJECT_ID('dbo.spObtenerSiguienteConsecutivo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spObtenerSiguienteConsecutivo;
GO

CREATE PROCEDURE dbo.spObtenerSiguienteConsecutivo
    @p_transaction_type NVARCHAR(50),
    @p_branch_id INT = NULL,
    @p_implant_id INT = NULL,
    @p_formatted_consecutive NVARCHAR(100) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_norm_type NVARCHAR(50) = UPPER(LTRIM(RTRIM(ISNULL(@p_transaction_type, 'INVOICE'))));
    DECLARE @v_id INT = NULL;
    DECLARE @v_next_val INT = NULL;
    DECLARE @v_prefix NVARCHAR(20) = '';
    DECLARE @v_padding INT = 0;
    DECLARE @v_num_str NVARCHAR(50);
    
    -- 1. Buscar en TransactionConsecutive si la tabla existe
    IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
    BEGIN
        SELECT TOP 1 
            @v_id = id,
            @v_next_val = ISNULL(currentNumber, ISNULL(initialNumber, 1)),
            @v_prefix = ISNULL(LTRIM(RTRIM(prefix)), ''),
            @v_padding = ISNULL(padding, 0)
        FROM dbo.[TransactionConsecutive] WITH (UPDLOCK, ROWLOCK)
        WHERE isActive = 1
          AND (
              UPPER(transactionType) = @v_norm_type
              OR (@v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA') AND UPPER(transactionType) IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA'))
              OR (@v_norm_type IN ('QUOTATION', 'COTIZACION') AND UPPER(transactionType) IN ('QUOTATION', 'COTIZACION'))
              OR (@v_norm_type IN ('PREQUOTATION', 'PRECOTIZACION') AND UPPER(transactionType) IN ('PREQUOTATION', 'PRECOTIZACION'))
              OR (@v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') AND UPPER(transactionType) IN ('CREDIT_NOTE', 'NOTA_CREDITO'))
          )
          AND (@p_branch_id IS NULL OR branchId IS NULL OR branchId = @p_branch_id)
          AND (@p_implant_id IS NULL OR implantId IS NULL OR implantId = @p_implant_id)
        ORDER BY 
            CASE WHEN @p_implant_id IS NOT NULL AND implantId = @p_implant_id THEN 1 WHEN implantId IS NOT NULL THEN 3 ELSE 2 END,
            CASE WHEN @p_branch_id IS NOT NULL AND branchId = @p_branch_id THEN 1 WHEN branchId IS NOT NULL THEN 3 ELSE 2 END,
            id ASC;
    END;
        
    IF @v_id IS NOT NULL
    BEGIN
        UPDATE dbo.[TransactionConsecutive]
        SET currentNumber = currentNumber + 1,
            updatedAt = GETDATE()
        WHERE id = @v_id;
    END
    ELSE
    BEGIN
        SET @v_prefix = CASE 
            WHEN @v_norm_type IN ('QUOTATION', 'COTIZACION') THEN 'COT'
            WHEN @v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION') THEN 'FAC'
            WHEN @v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') THEN 'NC'
            ELSE 'DOC'
        END;
        
        IF @v_norm_type IN ('QUOTATION', 'COTIZACION')
        BEGIN
            IF OBJECT_ID('dbo.Quotation', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Quotation];
            ELSE
                SET @v_next_val = 1;
        END
        ELSE
        BEGIN
            IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Invoices];
            ELSE
                SET @v_next_val = 1;
        END;
    END;
    
    SET @v_num_str = CAST(ISNULL(@v_next_val, 1) AS NVARCHAR(50));
    IF @v_padding > 0 AND LEN(@v_num_str) < @v_padding
        SET @v_num_str = RIGHT(REPLICATE('0', @v_padding) + @v_num_str, @v_padding);
        
    IF @v_prefix <> ''
    BEGIN
        IF RIGHT(@v_prefix, 1) IN ('-', '/')
            SET @p_formatted_consecutive = @v_prefix + @v_num_str;
        ELSE
            SET @p_formatted_consecutive = @v_prefix + '-' + @v_num_str;
    END
    ELSE
        SET @p_formatted_consecutive = @v_num_str;
END;
GO

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
    @p_id INT = NULL,
    @p_search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @targetId INT = @p_id;

    -- Si @p_id es provisto pero no coincide con la clave primaria id, intentar buscar por referencia
    IF @targetId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Invoices] WHERE [id] = @targetId)
    BEGIN
        DECLARE @p_id_str NVARCHAR(100) = CAST(@p_id AS NVARCHAR(100));
        SELECT TOP 1 @targetId = [id]
        FROM dbo.[Invoices]
        WHERE [internalNumber] = @p_id_str
           OR [zeusInvoiceNumber] = @p_id_str
           OR [consecutivo] = @p_id_str
           OR ([serie] IS NOT NULL AND [consecutivo] IS NOT NULL AND ([serie] + '-' + [consecutivo] = @p_id_str OR [serie] + [consecutivo] = @p_id_str));
    END

    -- Si aún no tenemos un targetId válido y se pasó @p_search, resolver por la cadena de búsqueda
    IF @targetId IS NULL AND @p_search IS NOT NULL AND TRIM(@p_search) <> ''
    BEGIN
        DECLARE @cleanSearch NVARCHAR(250) = TRIM(@p_search);
        SELECT TOP 1 @targetId = [id]
        FROM dbo.[Invoices]
        WHERE [internalNumber] = @cleanSearch
           OR [zeusInvoiceNumber] = @cleanSearch
           OR [consecutivo] = @cleanSearch
           OR ([serie] IS NOT NULL AND [consecutivo] IS NOT NULL AND ([serie] + '-' + [consecutivo] = @cleanSearch OR [serie] + [consecutivo] = @cleanSearch));

        -- Fallback si el parámetro de búsqueda era puramente entero
        IF @targetId IS NULL AND ISNUMERIC(@cleanSearch) = 1
        BEGIN
            SELECT TOP 1 @targetId = [id]
            FROM dbo.[Invoices]
            WHERE [id] = CAST(@cleanSearch AS INT);
        END
    END

    -- Fallback de resguardo
    IF @targetId IS NULL
    BEGIN
        SET @targetId = ISNULL(@p_id, 0);
    END

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
    WHERE i.[id] = @targetId;

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
    WHERE ip.[invoiceId] = @targetId
    ORDER BY ip.[id] ASC;

    -- Recordset 2: InvoicesProductTax
    SELECT 
        ipt.[id],
        ipt.[invoiceProductId],
        ipt.[chargeAndTaxId],
        ct.[code] AS [taxCode],
        ct.[name] AS [taxName],
        ct.[type] AS [taxType],
        ISNULL(ipt.[valueTypeSnapshot], ct.[valueType]) AS [taxValueType],
        ISNULL(ipt.[valueSnapshot], ct.[value]) AS [valueSnapshot],
        ISNULL(ipt.[valueTypeSnapshot], ct.[valueType]) AS [valueTypeSnapshot],
        ISNULL(ipt.[isMain], 0) AS [isMain],
        ISNULL(ipt.[explicitAmount], 0) AS [explicitAmount],
        ISNULL(ipt.[explicitAmount], 0) AS [amount],
        ISNULL(ipt.[rate], 0) AS [rate]
    FROM dbo.[InvoicesProductTax] ipt
    JOIN dbo.[InvoicesProduct] ip ON ipt.[invoiceProductId] = ip.[id]
    LEFT JOIN dbo.[ChargeAndTax] ct ON ipt.[chargeAndTaxId] = ct.[id]
    WHERE ip.[invoiceId] = @targetId
    ORDER BY ipt.[id] ASC;

    -- Recordset 3: InvoicesProductPasenger
    SELECT 
        ipp.[id],
        ipp.[invoiceProductId],
        ipp.[name],
        ipp.[document]
    FROM dbo.[InvoicesProductPasenger] ipp
    JOIN dbo.[InvoicesProduct] ip ON ipp.[invoiceProductId] = ip.[id]
    WHERE ip.[invoiceId] = @targetId
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
    WHERE ip.[invoiceId] = @targetId
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
    WHERE ip.[invoiceId] = @targetId
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
    WHERE ip.[invoiceId] = @targetId
    ORDER BY ipi.[orden] ASC, ipi.[id] ASC;

    -- Recordset 7: InvoicesProductCombo
    SELECT 
        ipc.[id],
        ipc.[invoiceId],
        ipc.[comboId],
        cmb.[name] AS [comboName]
    FROM dbo.[InvoicesProductCombo] ipc
    LEFT JOIN dbo.[Combo] cmb ON ipc.[comboId] = cmb.[id]
    WHERE ipc.[invoiceId] = @targetId
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
                    INSERT INTO dbo.[InvoicesProductTax] ([invoiceProductId], [chargeAndTaxId], [explicitAmount], [rate], [valueSnapshot], [valueTypeSnapshot], [isMain])
                    SELECT 
                        @newIpId,
                        TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT),
                        ISNULL(TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.explicitAmount'), JSON_VALUE(tax.value, '$.amount')) AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.rate') AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'PERCENTAGE'),
                        CASE WHEN TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
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
                    INSERT INTO dbo.[InvoicesProductTax] ([invoiceProductId], [chargeAndTaxId], [explicitAmount], [rate], [valueSnapshot], [valueTypeSnapshot], [isMain])
                    SELECT 
                        @newIpId,
                        TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT),
                        ISNULL(TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.explicitAmount'), JSON_VALUE(tax.value, '$.amount')) AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.rate') AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'PERCENTAGE'),
                        CASE WHEN TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
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
        COALESCE(
            NULLIF(
                (
                    SELECT SUM(ipt.[explicitAmount])
                    FROM dbo.[InvoicesProductTax] ipt
                    JOIN dbo.[InvoicesProduct] ip ON ipt.[invoiceProductId] = ip.[id]
                    WHERE ip.[invoiceId] = i.[id]
                ), 0
            ),
            NULLIF(
                (
                    SELECT SUM(ip.[price] * ip.[quantity])
                    FROM dbo.[InvoicesProduct] ip
                    WHERE ip.[invoiceId] = i.[id]
                ), 0
            ),
            i.[totalAmount],
            0
        ) AS [totalAmount],
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
    @p_id INT = NULL,
    @p_search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @targetId INT = @p_id;

    -- Si @p_id es provisto pero no coincide con la clave primaria id, intentar buscar por referencia
    IF @targetId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE [id] = @targetId)
    BEGIN
        DECLARE @p_id_str NVARCHAR(100) = CAST(@p_id AS NVARCHAR(100));
        SELECT TOP 1 @targetId = [id]
        FROM dbo.[Quotation]
        WHERE [internalNumber] = @p_id_str
           OR [reservationCode] = @p_id_str;
    END

    -- Si aún no tenemos un targetId válido y se pasó @p_search, resolver por la cadena de búsqueda
    IF @targetId IS NULL AND @p_search IS NOT NULL AND TRIM(@p_search) <> ''
    BEGIN
        DECLARE @cleanSearch NVARCHAR(250) = TRIM(@p_search);
        SELECT TOP 1 @targetId = [id]
        FROM dbo.[Quotation]
        WHERE [internalNumber] = @cleanSearch
           OR [reservationCode] = @cleanSearch;

        -- Fallback si el parámetro de búsqueda era puramente entero
        IF @targetId IS NULL AND ISNUMERIC(@cleanSearch) = 1
        BEGIN
            SELECT TOP 1 @targetId = [id]
            FROM dbo.[Quotation]
            WHERE [id] = CAST(@cleanSearch AS INT);
        END
    END

    -- Fallback de resguardo
    IF @targetId IS NULL
    BEGIN
        SET @targetId = ISNULL(@p_id, 0);
    END

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
    WHERE q.[id] = @targetId;
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








-- ==========================================
-- Procedimiento Standalone: spExportInvoices.sql
-- ==========================================

CREATE OR ALTER PROCEDURE [dbo].[spExportInvoices]
    @Envoices_id VARCHAR(MAX),
    @User_id INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje_resultado VARCHAR(MAX) = '';

    SET @Envoices_id = LTRIM(RTRIM(@Envoices_id));
    IF @Envoices_id IS NULL OR @Envoices_id = ''
    BEGIN
        SELECT 'ERROR: No se han proporcionado IDs de Facturacion válidos.' AS mensaje_resultado;
        RETURN;
    END;

    -- Validar Usuario
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @User_id)
    BEGIN
        SELECT TOP 1 @User_id = id FROM dbo.[User] WHERE isActive = 1 ORDER BY id ASC;
        IF @User_id IS NULL
        BEGIN
            SELECT TOP 1 @User_id = id FROM dbo.[User] ORDER BY id ASC;
            IF @User_id IS NULL
            BEGIN
                SELECT 'ERROR: No existen usuarios registrados en el sistema.' AS mensaje_resultado;
                RETURN;
            END;
        END;
    END;

    -- Parse IDs
    DECLARE @idsTable TABLE (id INT);
    INSERT INTO @idsTable (id)
    SELECT CAST(value AS INT)
    FROM STRING_SPLIT(@Envoices_id, ',')
    WHERE TRIM(value) <> '' AND ISNUMERIC(TRIM(value)) = 1;

    -- 0. Pre-validación: Factura ya exportada
    DECLARE @err_already_exported VARCHAR(MAX) = '';
    SELECT TOP 1 @err_already_exported = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + ' ya se encuentra exportada a Zeus ERP.'
    FROM dbo.[Invoices] e
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND e.state = 'EXPORTED';

    IF @err_already_exported IS NOT NULL AND @err_already_exported <> ''
    BEGIN
        SELECT @err_already_exported AS mensaje_resultado;
        RETURN;
    END;

    -- 0.1 Pre-validación: Cliente deshabilitado en Korex
    DECLARE @err_client VARCHAR(MAX) = '';
    SELECT TOP 1 
        @err_client = 'ERROR: El cliente "' + ISNULL(c.name, 'DESCONOCIDO') + '" (NIT/Tercero ' + ISNULL(c.document, '') + ') se encuentra deshabilitado en Korex. Debe habilitarlo en el maestro de clientes de Korex antes de exportar la factura.'
    FROM dbo.[Invoices] e
    JOIN dbo.[Client] c ON e.clientId = c.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND c.isActive = 0;

    IF @err_client IS NOT NULL AND @err_client <> ''
    BEGIN
        SELECT @err_client AS mensaje_resultado;
        RETURN;
    END;

    -- 0.2 Pre-validación: Conceptos de Facturación y Tipos de Servicio
    DECLARE @v_err_concept VARCHAR(MAX) = '';

    SELECT TOP 1 
        @v_err_concept = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
                         ' contiene el producto ''' + ISNULL(ep.descripcion, ISNULL(pr.description, 'SIN NOMBRE')) + 
                         ''' que no tiene asignado un Concepto de Facturación ni Clasificación de Servicio en Korex. Por favor asígnelo en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND ISNULL(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), '') = ''
      AND ISNULL(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), ISNULL(NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), '')) = '';

    IF @v_err_concept IS NOT NULL AND @v_err_concept <> ''
    BEGIN
        SELECT @v_err_concept AS mensaje_resultado;
        RETURN;
    END;

    -- Construir XML para Zeus ERP
    DECLARE @xmlResult XML;

    SET @xmlResult = (
        SELECT 
            e.id AS [id_factura],
            '55' AS [cd_fuente],
            '33' AS [cd_serie],
            '' AS [cd_consecutivo],
            1 AS [cd_usuario],
            SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
            SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechacont],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_vence],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_tercero_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_tercero_nombre],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_cliente_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_nombre],
            SUBSTRING(ISNULL(c.address, ''), 1, 150) AS [ds_cliente_dir],
            '' AS [ds_cliente_ciudad],
            '' AS [ds_cliente_tel],
            SUBSTRING(ISNULL(c.address, ''), 1, 150) AS [ds_cliente_dirdesp],
            '' AS [ds_cliente_email],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_contacto],
            '' AS [ds_cliente_contacto_email],
            ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
            SUBSTRING(ISNULL(s.code, 'OFP'), 1, 5) AS [cd_vendedor],
            SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteador],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [am_tcambiousd],
            1 AS [id_tipoventa],
            '' AS [ds_Observacion],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [TotalFactura],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [ValorFactura],
            -- Items
            (
                SELECT 
                    e.id AS [id_factura],
                    ep.id AS [id_item],
                    'Hotel' AS [tipo_item],
                    3 AS [in_tipoitem],
                    ep.id AS [id_referencia_origen],
                    '' AS [cd_tiquete],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 250) AS [ds_descrip],
                    1 AS [in_nacionalidad],
                    '' AS [cd_cencosto],
                    '' AS [cd_auxiliar],
                    '' AS [cd_item],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            LEFT JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                            WHERE ipt.invoiceProductId = ep.id
                              AND (
                                  ipt.isMain = 1 OR
                                  (ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  ))
                              )
                        ), ISNULL(ep.price * ep.quantity, 0))
                    AS DECIMAL(18,2)) AS [am_tarifa],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            WHERE ipt.invoiceProductId = ep.id AND ct.code = 'IVA'
                        ), 0)
                    AS DECIMAL(18,2)) AS [am_iva],
                    CAST(0 AS DECIMAL(18,2)) AS [am_tua],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comb],
                    CAST(0 AS DECIMAL(18,2)) AS [am_vat],
                    CAST(0 AS DECIMAL(18,2)) AS [am_Comision],
                    -- Titular: primer pasajero con nombres y apellidos separados
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, 30)
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - 1)
                        ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) - 1)
                    END AS [ds_paxname],
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN ''
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1, 100)), 1, 30)
                        ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) + 1, 100)), 1, 30)
                    END AS [ds_paxape],
                    'SR' AS [ds_paxprefix],
                    '' AS [cd_tourcode],
                    0 AS [NumTktConj],
                    'ACT' AS [cd_TipoTiquete],
                    1 AS [id_air],
                    '' AS [ds_itinerario],
                    '' AS [ds_itinerarioaerolinea],
                    'Y' AS [ds_clases],
                    '' AS [ds_Observaciones],
                    CAST(0 AS DECIMAL(18,2)) AS [am_highfare],
                    CAST(0 AS DECIMAL(18,2)) AS [am_lowfare],
                    '' AS [ds_solicita],
                    '' AS [ds_lapsoviaje],
                    '' AS [cd_tktrevisado],
                    '' AS [cd_PasaportePax],
                    '' AS [cd_pax_CC],
                    CAST(100.0 AS DECIMAL(18,2)) AS [am_PorFacParcial],
                    ISNULL(ep.paxAdults, 1) AS [in_cantpax],
                    '' AS [cd_FormaPagoTAO],
                    '' AS [cd_TarjetaCreditoTAO],
                    '' AS [cd_NumeroTarjetaTAO],
                    '' AS [cd_VencimientoTarjetaTAO],
                    '' AS [cd_NumeroPolizaTAO],
                    '' AS [cd_AnexoPolizaTAO],
                    '' AS [ds_AutorizacionTarjetaTAO],
                    0 AS [in_cuotasTarjetaTAO],
                    'EFE' AS [cd_FormasPago],
                    '' AS [cd_TarjetasCredito],
                    CAST(
                        ISNULL(
                            (SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id),
                            ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                        )
                    AS DECIMAL(18,2)) AS [am_fp1],
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
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            WHERE ipt.invoiceProductId = ep.id AND ipt.isMain = 1
                        ), ISNULL(ep.price, 0))
                    AS DECIMAL(18,2)) AS [am_basecomisionable],
                    CAST(0 AS DECIMAL(18,2)) AS [am_porcomision],
                    '2' AS [cd_tiposconceptfac],
                    COALESCE(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), 'FAC', '01') AS [cd_conceptofacturacion],
                    COALESCE(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), 'HOTEL', '01') AS [cd_tiposservicio],
                    SUBSTRING(COALESCE(
                        NULLIF(RTRIM(LTRIM(prv.code)), ''),
                        NULLIF(RTRIM(LTRIM(prv.airlineCode)), ''),
                        (SELECT TOP 1 p_fb.code FROM dbo.[Provider] p_fb WHERE p_fb.code IS NOT NULL AND RTRIM(LTRIM(p_fb.code)) <> '' ORDER BY p_fb.id ASC),
                        '890100577'
                    ), 1, 25) AS [cd_proveedores],
                    SUBSTRING(COALESCE(NULLIF(LTRIM(RTRIM(ep.servicios)), ''), NULLIF(LTRIM(RTRIM(ep.descripcion)), ''), NULLIF(LTRIM(RTRIM(pr.description)), ''), ''), 1, 250) AS [ds_servicio],
                    CAST(
                        (
                            ISNULL(ep.price * ep.quantity, 0) +
                            ISNULL((
                                SELECT SUM(ipt2.explicitAmount)
                                FROM dbo.[InvoicesProductTax] ipt2
                                JOIN dbo.[ChargeAndTax] ct2 ON ct2.id = ipt2.chargeAndTaxId
                                LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct2.targetTaxId
                                WHERE ipt2.invoiceProductId = ep.id
                                  AND ipt2.isMain = 0
                                  AND ct2.targetTaxId IS NOT NULL
                                  AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  )
                            ), 0) +
                            CASE WHEN ISNULL(ep.price, 0) = 0 THEN
                                ISNULL((
                                    SELECT SUM(ipt3.explicitAmount)
                                    FROM dbo.[InvoicesProductTax] ipt3
                                    WHERE ipt3.invoiceProductId = ep.id AND ipt3.isMain = 1
                                ), 0)
                            ELSE 0 END
                        )
                    AS DECIMAL(18,2)) AS [am_valorprov],
                    ISNULL(e.currency, 'COP') AS [cd_monedaprov],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [dt_llegada],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [dt_salida],
                    CAST(0 AS DECIMAL(18,2)) AS [am_pordescuento],
                    CAST(0 AS DECIMAL(18,2)) AS [am_basedescuento],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [Fecha_Salida],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [Fecha_Llegada],
                    ISNULL(ep.providerInvoice, '') AS [cd_facturaproveedor],
                    CONVERT(VARCHAR(19), ISNULL(ep.providerDueDate, ISNULL(ep.checkInDate, e.date)), 120) AS [dt_fechavencimientoproveedor],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_noches],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_dias],
                    '1' AS [id_tipoproveedor],
                    '1' AS [cd_tipoproveedor],
                    'GENERAL' AS [ds_tipoproveedor],
                    SUBSTRING(master.dbo.fn_varbintohexstr(HASHBYTES('MD5', CAST(ep.id AS VARCHAR) + CAST(SYSDATETIME() AS VARCHAR))), 3, 8) AS [cd_consecutivo_variablesadicionales],
                    CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [am_valor_total],
                    -- Sub-nodo: Pasajeros (Todos los pasajeros con nombre y apellido divididos)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, 50)
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - 1)
                                ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) - 1)
                            END AS [ds_paxname],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN ''
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1, 100)), 1, 50)
                                ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) + 1, 100)), 1, 50)
                            END AS [ds_paxape],
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
                    -- Sub-nodo: Formaspago (Preservando montos individuales)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(p.code, CASE WHEN LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%' THEN 'TC' ELSE 'EFE' END) AS [cd_codigo],
                            ISNULL(ipp.paymentMethod, 'CONTADO') AS [ds_nombre],
                            CAST(
                                ISNULL(ipp.amount, 
                                    ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                                )
                            AS DECIMAL(18,2)) AS [am_valor]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPayment] ipp ON ipp.invoiceProductId = ep.id
                        LEFT JOIN dbo.[Payment] p ON LOWER(p.name) = LOWER(ipp.paymentMethod)
                        FOR XML PATH('Formaspago'), TYPE
                    ),
                    -- Sub-nodo: CargosImpuestos (Clasificando am_contado y am_credito por forma de pago)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(ct.code, 'TAR') AS [cd_codigo],
                            ISNULL(ct.name, 'Tarifa') AS [ds_nombre],
                            CASE WHEN ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%' THEN 'C' ELSE 'I' END AS [cd_tipo],
                            CAST(ISNULL(ct.value, 0) AS DECIMAL(18,4)) AS [am_porcentaje],
                            CAST(
                                (
                                    ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                    CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                        ISNULL((
                                            SELECT SUM(sub_t.explicitAmount)
                                            FROM dbo.[InvoicesProductTax] sub_t
                                            JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                            WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                              AND sub_t.isMain = 0
                                              AND sub_ct.targetTaxId = ct.id
                                        ), 0)
                                    ELSE 0 END
                                ) AS DECIMAL(18,2)
                            ) AS [am_valor],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                ELSE CAST(
                                    ROUND(
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) * 
                                        ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                        NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                    , 2) AS DECIMAL(18,2)
                                )
                            END AS [am_contado],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                ELSE CAST(
                                    (
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) - 
                                        ROUND(
                                            (
                                                ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                                CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                    ISNULL((
                                                        SELECT SUM(sub_t.explicitAmount)
                                                        FROM dbo.[InvoicesProductTax] sub_t
                                                        JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                        WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                          AND sub_t.isMain = 0
                                                          AND sub_ct.targetTaxId = ct.id
                                                    ), 0)
                                                ELSE 0 END
                                            ) * 
                                            ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                            NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                        , 2)
                                    ) AS DECIMAL(18,2)
                                )
                            END AS [am_credito],
                            ISNULL(ct.id, 1) AS [id_carg],
                            ISNULL(ct.id, 1) AS [id_imp],
                            CASE WHEN ct.code = 'IVA' THEN 1 ELSE 0 END AS [bl_iva],
                            1 AS [in_orden]
                        FROM dbo.[InvoicesProductTax] ipt
                        JOIN dbo.[ChargeAndTax] ct ON ipt.chargeAndTaxId = ct.id
                        LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                        WHERE ipt.invoiceProductId = ep.id
                          AND NOT (
                              ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                  target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                              )
                          )
                        FOR XML PATH('CargosImpuestos'), TYPE
                    ),
                    -- Sub-nodo: Variables (Variables Adicionales dinámicas de InvoicesProductVariable)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            CASE WHEN pr.type = 'Tiquete' THEN 1 ELSE 3 END AS [in_tipoitem],
                            CASE WHEN pr.type = 'Tiquete' THEN 'Tiquetes' ELSE 'FacturacionServicios' END AS [ds_maestro],
                            ISNULL(mv.name, mv.code) AS [ds_VariableAdicional],
                            ISNULL(ipv.value, '') AS [ds_valor],
                            ISNULL(mv.code, '') AS [cd_codigo]
                        FROM dbo.[InvoicesProductVariable] ipv
                        JOIN dbo.[MasterVariable] mv ON ipv.masterVariableId = mv.id
                        WHERE ipv.invoiceProductId = ep.id
                        FOR XML PATH('Variables'), TYPE
                    ),
                    -- Sub-nodo: TiposFacturacionHoteles (para desglose de tarifas por noche/unidad en hoteles y servicios)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            'NCH' AS [cd_tiposfacturacionhoteles],
                            'Noches' AS [ds_tiposfacturacionhoteles],
                            ISNULL(ep.quantity, 1) AS [in_cantidad],
                            CAST(ISNULL(ep.price, 0) AS DECIMAL(18,2)) AS [am_valor],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                ELSE CAST(
                                    ROUND(
                                        ISNULL(ep.price * ep.quantity, 0) * 
                                        ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                        NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                    , 2) AS DECIMAL(18,2)
                                )
                            END AS [am_contado],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2))
                                ELSE CAST(
                                    (
                                        ISNULL(ep.price * ep.quantity, 0) - 
                                        ROUND(
                                            ISNULL(ep.price * ep.quantity, 0) * 
                                            ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                            NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                        , 2)
                                    ) AS DECIMAL(18,2)
                                )
                            END AS [am_credito],
                            ISNULL(ct_main.code, 'TAR') AS [cd_cargosdesc],
                            ISNULL(ct_main.name, 'TARIFA') AS [ds_cargonm],
                            ISNULL(ct_main.id, 1) AS [id_cargosdesc]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[ChargeAndTax] ct_main ON ct_main.id = ep.mainTaxId
                        FOR XML PATH('TiposFacturacionHoteles'), TYPE
                    )
                FROM dbo.[InvoicesProduct] ep
                LEFT JOIN dbo.[ChargeAndTax] ct_main ON ep.mainTaxId = ct_main.id
                LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
                LEFT JOIN dbo.[Provider] prv ON ep.providerId = prv.id
                LEFT JOIN dbo.[InvoicesProductPasenger] pax1 ON pax1.id = (
                    SELECT MIN(pp_min.id) FROM dbo.[InvoicesProductPasenger] pp_min WHERE pp_min.invoiceProductId = ep.id
                )
                WHERE ep.invoiceId = e.id
                  AND (
                      ISNULL(ep.price, 0) > 0 
                      OR ISNULL(ep.cost, 0) > 0 
                      OR NULLIF(LTRIM(RTRIM(ep.descripcion)), '') IS NOT NULL 
                      OR NULLIF(LTRIM(RTRIM(ep.servicios)), '') IS NOT NULL
                  )
                FOR XML PATH('Item'), TYPE
            )
        FROM dbo.[Invoices] e
        LEFT JOIN dbo.[Client] c ON e.clientId = c.id
        LEFT JOIN dbo.[Branch] b ON e.branchId = b.id
        LEFT JOIN dbo.[Implant] imp ON e.implantId = imp.id
        LEFT JOIN dbo.[Seller] s ON e.sellerId = s.id
        LEFT JOIN dbo.[User] u ON e.userId = u.id
        LEFT JOIN dbo.[TicketPrinter] tp ON e.ticketPrinterId = tp.id
        WHERE e.id IN (SELECT id FROM @idsTable)
        FOR XML PATH('Facturacion'), ROOT('Facturaciones'), TYPE
    );

    DECLARE @v_xml VARCHAR(MAX) = CAST(@xmlResult AS VARCHAR(MAX));

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

GO


-- ==========================================
-- Procedimiento Standalone: spInvoicesListar.sql
-- ==========================================

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
        COALESCE(
            NULLIF(
                (
                    SELECT SUM(ipt.[explicitAmount])
                    FROM dbo.[InvoicesProductTax] ipt
                    JOIN dbo.[InvoicesProduct] ip ON ipt.[invoiceProductId] = ip.[id]
                    WHERE ip.[invoiceId] = i.[id]
                ), 0
            ),
            NULLIF(
                (
                    SELECT SUM(ip.[price] * ip.[quantity])
                    FROM dbo.[InvoicesProduct] ip
                    WHERE ip.[invoiceId] = i.[id]
                ), 0
            ),
            i.[totalAmount],
            0
        ) AS [totalAmount],
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

GO


-- ==========================================
-- Procedimiento Standalone: spLimpiarMovimientosProduccion.sql
-- ==========================================

-- ============================================================================
-- AGENCIASNEW - LIMPIADOR DE MOVIMIENTOS EN SQL SERVER
-- Procedimiento: dbo.spLimpiarMovimientosProduccion
-- ============================================================================

IF OBJECT_ID('dbo.spLimpiarMovimientosProduccion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spLimpiarMovimientosProduccion;
GO

CREATE PROCEDURE dbo.spLimpiarMovimientosProduccion
    @p_mensaje_resultado NVARCHAR(4000) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @tables TABLE (id INT IDENTITY(1,1), tableName NVARCHAR(128));
        
        -- Orden respetando dependencias de llaves foráneas
        INSERT INTO @tables (tableName) VALUES
        ('QuotationProductTax'), ('QuotationProductVariable'), ('QuotationProductPassenger'),
        ('QuotationProductPayment'), ('QuotationCombo'), ('QuotationInvoice'),
        ('QuotationStateHistory'), ('QuotationPrintCustomization'), ('QuotationManualService'),
        ('QuotationProduct'), ('Quotation'), 
        ('PreQuotationStateHistory'), ('PreQuotation'),
        ('InvoicesProductTax'), ('InvoicesProductVariable'), ('InvoicesProductPasenger'),
        ('InvoicesProductPayment'), ('InvoicesProductCombo'), ('InvoicesProductItinerary'),
        ('InvoicesProduct'), ('Invoices'), ('Invoice'),
        ('BookingProductGDS'), ('BookingProductItineraryGDS'), ('BookingProductPassangerGDS'),
        ('BookingProductTaxGDS'), ('BookingProductVariableGDS'), ('BookingProductFEEGDS'),
        ('BookingProductPaymentGDS'), ('BookingsGDSInvoiceAuto'), ('BookingGDSInvoiceAutoLog'),
        ('BranchGDSInvoiceAuto'), ('BookingsGDS_log'), ('BookingGDS'),
        ('SystemLog'), ('ExecutionPreset'), ('ExecutionProcedure'), ('Attachment'),
        ('EquivalenciasInterfaces_Log');

        DECLARE @tbl NVARCHAR(128);
        DECLARE @sqlCmd NVARCHAR(MAX);
        DECLARE curTbl CURSOR LOCAL FAST_FORWARD FOR SELECT tableName FROM @tables ORDER BY id ASC;
        OPEN curTbl;
        FETCH NEXT FROM curTbl INTO @tbl;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF OBJECT_ID('dbo.' + @tbl, 'U') IS NOT NULL
            BEGIN
                SET @sqlCmd = N'DELETE FROM dbo.[' + @tbl + N'];';
                EXEC sp_executesql @sqlCmd;

                IF OBJECTPROPERTY(OBJECT_ID('dbo.' + @tbl), 'TableHasIdentity') = 1
                BEGIN
                    BEGIN TRY
                        SET @sqlCmd = N'DBCC CHECKIDENT (''dbo.[' + @tbl + N']'', RESEED, 0) WITH NO_INFOMSGS;';
                        EXEC sp_executesql @sqlCmd;
                    END TRY
                    BEGIN CATCH
                    END CATCH;
                END;
            END;
            FETCH NEXT FROM curTbl INTO @tbl;
        END;
        CLOSE curTbl;
        DEALLOCATE curTbl;

        IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
        BEGIN
            UPDATE dbo.[TransactionConsecutive]
            SET [currentNumber] = COALESCE([initialNumber], 1);
        END;

        SET @p_mensaje_resultado = 'SUCCESS: Tablas de movimientos vaciadas e IDENTITIES/consecutivos reiniciados a 1 en SQL Server.';
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH;
END
GO

GO


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

GO


-- ==========================================
-- Procedimiento Standalone: spObtenerSiguienteConsecutivo.sql
-- ==========================================

IF OBJECT_ID('dbo.spObtenerSiguienteConsecutivo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spObtenerSiguienteConsecutivo;
GO

CREATE PROCEDURE dbo.spObtenerSiguienteConsecutivo
    @p_transaction_type NVARCHAR(50),
    @p_branch_id INT = NULL,
    @p_implant_id INT = NULL,
    @p_formatted_consecutive NVARCHAR(100) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_norm_type NVARCHAR(50) = UPPER(LTRIM(RTRIM(ISNULL(@p_transaction_type, 'INVOICE'))));
    DECLARE @v_id INT = NULL;
    DECLARE @v_next_val INT = NULL;
    DECLARE @v_prefix NVARCHAR(20) = '';
    DECLARE @v_padding INT = 0;
    DECLARE @v_num_str NVARCHAR(50);
    
    -- 1. Buscar en TransactionConsecutive si la tabla existe
    IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
    BEGIN
        SELECT TOP 1 
            @v_id = id,
            @v_next_val = ISNULL(currentNumber, ISNULL(initialNumber, 1)),
            @v_prefix = ISNULL(LTRIM(RTRIM(prefix)), ''),
            @v_padding = ISNULL(padding, 0)
        FROM dbo.[TransactionConsecutive] WITH (UPDLOCK, ROWLOCK)
        WHERE isActive = 1
          AND (
              UPPER(transactionType) = @v_norm_type
              OR (@v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA') AND UPPER(transactionType) IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA'))
              OR (@v_norm_type IN ('QUOTATION', 'COTIZACION') AND UPPER(transactionType) IN ('QUOTATION', 'COTIZACION'))
              OR (@v_norm_type IN ('PREQUOTATION', 'PRECOTIZACION') AND UPPER(transactionType) IN ('PREQUOTATION', 'PRECOTIZACION'))
              OR (@v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') AND UPPER(transactionType) IN ('CREDIT_NOTE', 'NOTA_CREDITO'))
          )
          AND (@p_branch_id IS NULL OR branchId IS NULL OR branchId = @p_branch_id)
          AND (@p_implant_id IS NULL OR implantId IS NULL OR implantId = @p_implant_id)
        ORDER BY 
            CASE WHEN @p_implant_id IS NOT NULL AND implantId = @p_implant_id THEN 1 WHEN implantId IS NOT NULL THEN 3 ELSE 2 END,
            CASE WHEN @p_branch_id IS NOT NULL AND branchId = @p_branch_id THEN 1 WHEN branchId IS NOT NULL THEN 3 ELSE 2 END,
            id ASC;
    END;
        
    IF @v_id IS NOT NULL
    BEGIN
        UPDATE dbo.[TransactionConsecutive]
        SET currentNumber = currentNumber + 1,
            updatedAt = GETDATE()
        WHERE id = @v_id;
    END
    ELSE
    BEGIN
        SET @v_prefix = CASE 
            WHEN @v_norm_type IN ('QUOTATION', 'COTIZACION') THEN 'COT'
            WHEN @v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION') THEN 'FAC'
            WHEN @v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') THEN 'NC'
            ELSE 'DOC'
        END;
        
        IF @v_norm_type IN ('QUOTATION', 'COTIZACION')
        BEGIN
            IF OBJECT_ID('dbo.Quotation', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Quotation];
            ELSE
                SET @v_next_val = 1;
        END
        ELSE
        BEGIN
            IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
                SELECT @v_next_val = ISNULL(MAX(id), 0) + 1 FROM dbo.[Invoices];
            ELSE
                SET @v_next_val = 1;
        END;
    END;
    
    SET @v_num_str = CAST(ISNULL(@v_next_val, 1) AS NVARCHAR(50));
    IF @v_padding > 0 AND LEN(@v_num_str) < @v_padding
        SET @v_num_str = RIGHT(REPLICATE('0', @v_padding) + @v_num_str, @v_padding);
        
    IF @v_prefix <> ''
    BEGIN
        IF RIGHT(@v_prefix, 1) IN ('-', '/')
            SET @p_formatted_consecutive = @v_prefix + @v_num_str;
        ELSE
            SET @p_formatted_consecutive = @v_prefix + '-' + @v_num_str;
    END
    ELSE
        SET @p_formatted_consecutive = @v_num_str;
END;
GO

GO


PRINT 'Procedimientos almacenados y funciones T-SQL compiladas exitosamente.';


GO

-- --------------------------------------------------------------------------
-- spExportInvoices (Generación de XML de Facturas en SQL Server)
-- --------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[spExportInvoices]
    @Envoices_id VARCHAR(MAX),
    @User_id INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensaje_resultado VARCHAR(MAX) = '';

    SET @Envoices_id = LTRIM(RTRIM(@Envoices_id));
    IF @Envoices_id IS NULL OR @Envoices_id = ''
    BEGIN
        SELECT 'ERROR: No se han proporcionado IDs de Facturacion válidos.' AS mensaje_resultado;
        RETURN;
    END;

    -- Validar Usuario
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @User_id)
    BEGIN
        SELECT TOP 1 @User_id = id FROM dbo.[User] WHERE isActive = 1 ORDER BY id ASC;
        IF @User_id IS NULL
        BEGIN
            SELECT TOP 1 @User_id = id FROM dbo.[User] ORDER BY id ASC;
            IF @User_id IS NULL
            BEGIN
                SELECT 'ERROR: No existen usuarios registrados en el sistema.' AS mensaje_resultado;
                RETURN;
            END;
        END;
    END;

    -- Parse IDs
    DECLARE @idsTable TABLE (id INT);
    INSERT INTO @idsTable (id)
    SELECT CAST(value AS INT)
    FROM STRING_SPLIT(@Envoices_id, ',')
    WHERE TRIM(value) <> '' AND ISNUMERIC(TRIM(value)) = 1;

    -- 0. Pre-validación: Factura ya exportada
    DECLARE @err_already_exported VARCHAR(MAX) = '';
    SELECT TOP 1 @err_already_exported = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + ' ya se encuentra exportada a Zeus ERP.'
    FROM dbo.[Invoices] e
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND e.state = 'EXPORTED';

    IF @err_already_exported IS NOT NULL AND @err_already_exported <> ''
    BEGIN
        SELECT @err_already_exported AS mensaje_resultado;
        RETURN;
    END;

    -- 0.1 Pre-validación: Cliente deshabilitado en Korex
    DECLARE @err_client VARCHAR(MAX) = '';
    SELECT TOP 1 
        @err_client = 'ERROR: El cliente "' + ISNULL(c.name, 'DESCONOCIDO') + '" (NIT/Tercero ' + ISNULL(c.document, '') + ') se encuentra deshabilitado en Korex. Debe habilitarlo en el maestro de clientes de Korex antes de exportar la factura.'
    FROM dbo.[Invoices] e
    JOIN dbo.[Client] c ON e.clientId = c.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND c.isActive = 0;

    IF @err_client IS NOT NULL AND @err_client <> ''
    BEGIN
        SELECT @err_client AS mensaje_resultado;
        RETURN;
    END;

    -- 0.2 Pre-validación: Conceptos de Facturación y Tipos de Servicio
    DECLARE @v_err_concept VARCHAR(MAX) = '';

    SELECT TOP 1 
        @v_err_concept = 'ERROR: La factura ' + ISNULL(e.internalNumber, 'FAC-' + CAST(e.id AS VARCHAR)) + 
                         ' contiene el producto ''' + ISNULL(ep.descripcion, ISNULL(pr.description, 'SIN NOMBRE')) + 
                         ''' que no tiene asignado un Concepto de Facturación ni Clasificación de Servicio en Korex. Por favor asígnelo en el maestro de productos o en la factura antes de exportar a Zeus ERP.'
    FROM dbo.[InvoicesProduct] ep
    JOIN dbo.[Invoices] e ON ep.invoiceId = e.id
    LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
    WHERE e.id IN (SELECT id FROM @idsTable)
      AND ISNULL(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), '') = ''
      AND ISNULL(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), ISNULL(NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), '')) = '';

    IF @v_err_concept IS NOT NULL AND @v_err_concept <> ''
    BEGIN
        SELECT @v_err_concept AS mensaje_resultado;
        RETURN;
    END;

    -- Construir XML para Zeus ERP
    DECLARE @xmlResult XML;

    SET @xmlResult = (
        SELECT 
            e.id AS [id_factura],
            '55' AS [cd_fuente],
            '33' AS [cd_serie],
            '' AS [cd_consecutivo],
            1 AS [cd_usuario],
            SUBSTRING(ISNULL(b.code, 'OFP'), 1, 5) AS [cd_sucursal],
            SUBSTRING(ISNULL(imp.code, ''), 1, 5) AS [cd_implante],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_fechacont],
            CONVERT(VARCHAR(19), ISNULL(e.date, GETDATE()), 120) AS [dt_vence],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_tercero_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_tercero_nombre],
            SUBSTRING(ISNULL(c.document, ''), 1, 15) AS [cd_cliente_codigo],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_nombre],
            SUBSTRING(ISNULL(c.address, ''), 1, 150) AS [ds_cliente_dir],
            '' AS [ds_cliente_ciudad],
            '' AS [ds_cliente_tel],
            SUBSTRING(ISNULL(c.address, ''), 1, 150) AS [ds_cliente_dirdesp],
            '' AS [ds_cliente_email],
            SUBSTRING(ISNULL(c.name, ''), 1, 100) AS [ds_cliente_contacto],
            '' AS [ds_cliente_contacto_email],
            ISNULL(e.currency, 'COP') AS [cd_monedas_iata],
            SUBSTRING(ISNULL(s.code, 'OFP'), 1, 5) AS [cd_vendedor],
            SUBSTRING(ISNULL(tp.code, '01'), 1, 6) AS [cd_tiqueteador],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [Tcambio],
            CAST(ISNULL(e.exchangeRate, 1.0) AS DECIMAL(18,4)) AS [am_tcambiousd],
            1 AS [id_tipoventa],
            '' AS [ds_Observacion],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [TotalFactura],
            CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [ValorFactura],
            -- Items
            (
                SELECT 
                    e.id AS [id_factura],
                    ep.id AS [id_item],
                    'Hotel' AS [tipo_item],
                    3 AS [in_tipoitem],
                    ep.id AS [id_referencia_origen],
                    '' AS [cd_tiquete],
                    SUBSTRING(ISNULL(ep.descripcion, ISNULL(pr.description, '')), 1, 250) AS [ds_descrip],
                    1 AS [in_nacionalidad],
                    '' AS [cd_cencosto],
                    '' AS [cd_auxiliar],
                    '' AS [cd_item],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            LEFT JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                            WHERE ipt.invoiceProductId = ep.id
                              AND (
                                  ipt.isMain = 1 OR
                                  (ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  ))
                              )
                        ), ISNULL(ep.price * ep.quantity, 0))
                    AS DECIMAL(18,2)) AS [am_tarifa],
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            JOIN dbo.[ChargeAndTax] ct ON ct.id = ipt.chargeAndTaxId
                            WHERE ipt.invoiceProductId = ep.id AND ct.code = 'IVA'
                        ), 0)
                    AS DECIMAL(18,2)) AS [am_iva],
                    CAST(0 AS DECIMAL(18,2)) AS [am_tua],
                    CAST(0 AS DECIMAL(18,2)) AS [am_comb],
                    CAST(0 AS DECIMAL(18,2)) AS [am_vat],
                    CAST(0 AS DECIMAL(18,2)) AS [am_Comision],
                    -- Titular: primer pasajero con nombres y apellidos separados
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, 30)
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - 1)
                        ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) - 1)
                    END AS [ds_paxname],
                    CASE 
                        WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) = 0 THEN ''
                        WHEN LEN(LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), ' ', '')) = 1 
                            THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1, 100)), 1, 30)
                        ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pax1.name, c.name)))) + 1) + 1, 100)), 1, 30)
                    END AS [ds_paxape],
                    'SR' AS [ds_paxprefix],
                    '' AS [cd_tourcode],
                    0 AS [NumTktConj],
                    'ACT' AS [cd_TipoTiquete],
                    1 AS [id_air],
                    '' AS [ds_itinerario],
                    '' AS [ds_itinerarioaerolinea],
                    'Y' AS [ds_clases],
                    '' AS [ds_Observaciones],
                    CAST(0 AS DECIMAL(18,2)) AS [am_highfare],
                    CAST(0 AS DECIMAL(18,2)) AS [am_lowfare],
                    '' AS [ds_solicita],
                    '' AS [ds_lapsoviaje],
                    '' AS [cd_tktrevisado],
                    '' AS [cd_PasaportePax],
                    '' AS [cd_pax_CC],
                    CAST(100.0 AS DECIMAL(18,2)) AS [am_PorFacParcial],
                    ISNULL(ep.paxAdults, 1) AS [in_cantpax],
                    '' AS [cd_FormaPagoTAO],
                    '' AS [cd_TarjetaCreditoTAO],
                    '' AS [cd_NumeroTarjetaTAO],
                    '' AS [cd_VencimientoTarjetaTAO],
                    '' AS [cd_NumeroPolizaTAO],
                    '' AS [cd_AnexoPolizaTAO],
                    '' AS [ds_AutorizacionTarjetaTAO],
                    0 AS [in_cuotasTarjetaTAO],
                    'EFE' AS [cd_FormasPago],
                    '' AS [cd_TarjetasCredito],
                    CAST(
                        ISNULL(
                            (SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id),
                            ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                        )
                    AS DECIMAL(18,2)) AS [am_fp1],
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
                    CAST(
                        ISNULL((
                            SELECT SUM(ipt.explicitAmount)
                            FROM dbo.[InvoicesProductTax] ipt
                            WHERE ipt.invoiceProductId = ep.id AND ipt.isMain = 1
                        ), ISNULL(ep.price, 0))
                    AS DECIMAL(18,2)) AS [am_basecomisionable],
                    CAST(0 AS DECIMAL(18,2)) AS [am_porcomision],
                    '2' AS [cd_tiposconceptfac],
                    COALESCE(NULLIF(LTRIM(RTRIM(pr.billingConcept)), ''), NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), 'FAC', '01') AS [cd_conceptofacturacion],
                    COALESCE(NULLIF(LTRIM(RTRIM(ep.serviceType)), ''), NULLIF(LTRIM(RTRIM(pr.serviceType)), ''), 'HOTEL', '01') AS [cd_tiposservicio],
                    SUBSTRING(COALESCE(
                        NULLIF(RTRIM(LTRIM(prv.code)), ''),
                        NULLIF(RTRIM(LTRIM(prv.airlineCode)), ''),
                        (SELECT TOP 1 p_fb.code FROM dbo.[Provider] p_fb WHERE p_fb.code IS NOT NULL AND RTRIM(LTRIM(p_fb.code)) <> '' ORDER BY p_fb.id ASC),
                        '890100577'
                    ), 1, 25) AS [cd_proveedores],
                    SUBSTRING(COALESCE(NULLIF(LTRIM(RTRIM(ep.servicios)), ''), NULLIF(LTRIM(RTRIM(ep.descripcion)), ''), NULLIF(LTRIM(RTRIM(pr.description)), ''), ''), 1, 250) AS [ds_servicio],
                    CAST(
                        (
                            ISNULL(ep.price * ep.quantity, 0) +
                            ISNULL((
                                SELECT SUM(ipt2.explicitAmount)
                                FROM dbo.[InvoicesProductTax] ipt2
                                JOIN dbo.[ChargeAndTax] ct2 ON ct2.id = ipt2.chargeAndTaxId
                                LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct2.targetTaxId
                                WHERE ipt2.invoiceProductId = ep.id
                                  AND ipt2.isMain = 0
                                  AND ct2.targetTaxId IS NOT NULL
                                  AND (
                                      target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                                  )
                            ), 0) +
                            CASE WHEN ISNULL(ep.price, 0) = 0 THEN
                                ISNULL((
                                    SELECT SUM(ipt3.explicitAmount)
                                    FROM dbo.[InvoicesProductTax] ipt3
                                    WHERE ipt3.invoiceProductId = ep.id AND ipt3.isMain = 1
                                ), 0)
                            ELSE 0 END
                        )
                    AS DECIMAL(18,2)) AS [am_valorprov],
                    ISNULL(e.currency, 'COP') AS [cd_monedaprov],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [dt_llegada],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [dt_salida],
                    CAST(0 AS DECIMAL(18,2)) AS [am_pordescuento],
                    CAST(0 AS DECIMAL(18,2)) AS [am_basedescuento],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkOutDate, ISNULL(ep.checkInDate, e.date)), 120) AS [Fecha_Salida],
                    CONVERT(VARCHAR(19), ISNULL(ep.checkInDate, e.date), 120) AS [Fecha_Llegada],
                    ISNULL(ep.providerInvoice, '') AS [cd_facturaproveedor],
                    CONVERT(VARCHAR(19), ISNULL(ep.providerDueDate, ISNULL(ep.checkInDate, e.date)), 120) AS [dt_fechavencimientoproveedor],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_noches],
                    CASE 
                        WHEN ep.nights IS NOT NULL AND ep.nights > 0 THEN ep.nights
                        WHEN ep.checkInDate IS NOT NULL AND ep.checkOutDate IS NOT NULL AND DATEDIFF(day, ep.checkInDate, ep.checkOutDate) > 0 
                            THEN DATEDIFF(day, ep.checkInDate, ep.checkOutDate)
                        ELSE 1 
                    END AS [in_dias],
                    '1' AS [id_tipoproveedor],
                    '1' AS [cd_tipoproveedor],
                    'GENERAL' AS [ds_tipoproveedor],
                    SUBSTRING(master.dbo.fn_varbintohexstr(HASHBYTES('MD5', CAST(ep.id AS VARCHAR) + CAST(SYSDATETIME() AS VARCHAR))), 3, 8) AS [cd_consecutivo_variablesadicionales],
                    CAST(ISNULL(e.totalAmount, 0) AS DECIMAL(18,2)) AS [am_valor_total],
                    -- Sub-nodo: Pasajeros (Todos los pasajeros con nombre y apellido divididos)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, 50)
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - 1)
                                ELSE SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), 1, CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) - 1)
                            END AS [ds_paxname],
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) = 0 THEN ''
                                WHEN LEN(LTRIM(RTRIM(ISNULL(pp.name, c.name)))) - LEN(REPLACE(LTRIM(RTRIM(ISNULL(pp.name, c.name))), ' ', '')) = 1 
                                    THEN SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1, 100)), 1, 50)
                                ELSE SUBSTRING(LTRIM(SUBSTRING(LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name))), CHARINDEX(' ', LTRIM(RTRIM(ISNULL(pp.name, c.name)))) + 1) + 1, 100)), 1, 50)
                            END AS [ds_paxape],
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
                    -- Sub-nodo: Formaspago (Preservando montos individuales)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(p.code, CASE WHEN LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%' THEN 'TC' ELSE 'EFE' END) AS [cd_codigo],
                            ISNULL(ipp.paymentMethod, 'CONTADO') AS [ds_nombre],
                            CAST(
                                ISNULL(ipp.amount, 
                                    ISNULL((SELECT SUM(explicitAmount) FROM dbo.[InvoicesProductTax] WHERE invoiceProductId = ep.id), ISNULL(ep.price * ep.quantity, 0))
                                )
                            AS DECIMAL(18,2)) AS [am_valor]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[InvoicesProductPayment] ipp ON ipp.invoiceProductId = ep.id
                        LEFT JOIN dbo.[Payment] p ON LOWER(p.name) = LOWER(ipp.paymentMethod)
                        FOR XML PATH('Formaspago'), TYPE
                    ),
                    -- Sub-nodo: CargosImpuestos (Clasificando am_contado y am_credito por forma de pago)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            ISNULL(ct.code, 'TAR') AS [cd_codigo],
                            ISNULL(ct.name, 'Tarifa') AS [ds_nombre],
                            CASE WHEN ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%' THEN 'C' ELSE 'I' END AS [cd_tipo],
                            CAST(ISNULL(ct.value, 0) AS DECIMAL(18,4)) AS [am_porcentaje],
                            CAST(
                                (
                                    ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                    CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                        ISNULL((
                                            SELECT SUM(sub_t.explicitAmount)
                                            FROM dbo.[InvoicesProductTax] sub_t
                                            JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                            WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                              AND sub_t.isMain = 0
                                              AND sub_ct.targetTaxId = ct.id
                                        ), 0)
                                    ELSE 0 END
                                ) AS DECIMAL(18,2)
                            ) AS [am_valor],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                ELSE CAST(
                                    ROUND(
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) * 
                                        ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                        NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                    , 2) AS DECIMAL(18,2)
                                )
                            END AS [am_contado],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(
                                    (
                                        ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                        CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                            ISNULL((
                                                SELECT SUM(sub_t.explicitAmount)
                                                FROM dbo.[InvoicesProductTax] sub_t
                                                JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                  AND sub_t.isMain = 0
                                                  AND sub_ct.targetTaxId = ct.id
                                            ), 0)
                                        ELSE 0 END
                                    ) AS DECIMAL(18,2)
                                )
                                ELSE CAST(
                                    (
                                        (
                                            ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                            CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                ISNULL((
                                                    SELECT SUM(sub_t.explicitAmount)
                                                    FROM dbo.[InvoicesProductTax] sub_t
                                                    JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                    WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                      AND sub_t.isMain = 0
                                                      AND sub_ct.targetTaxId = ct.id
                                                ), 0)
                                            ELSE 0 END
                                        ) - 
                                        ROUND(
                                            (
                                                ISNULL(ipt.explicitAmount, ep.price * ep.quantity) +
                                                CASE WHEN (ipt.isMain = 1 OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name LIKE '%TARIFA%') THEN
                                                    ISNULL((
                                                        SELECT SUM(sub_t.explicitAmount)
                                                        FROM dbo.[InvoicesProductTax] sub_t
                                                        JOIN dbo.[ChargeAndTax] sub_ct ON sub_t.chargeAndTaxId = sub_ct.id
                                                        WHERE sub_t.invoiceProductId = ipt.invoiceProductId
                                                          AND sub_t.isMain = 0
                                                          AND sub_ct.targetTaxId = ct.id
                                                    ), 0)
                                                ELSE 0 END
                                            ) * 
                                            ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                            NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                        , 2)
                                    ) AS DECIMAL(18,2)
                                )
                            END AS [am_credito],
                            ISNULL(ct.id, 1) AS [id_carg],
                            ISNULL(ct.id, 1) AS [id_imp],
                            CASE WHEN ct.code = 'IVA' THEN 1 ELSE 0 END AS [bl_iva],
                            1 AS [in_orden]
                        FROM dbo.[InvoicesProductTax] ipt
                        JOIN dbo.[ChargeAndTax] ct ON ipt.chargeAndTaxId = ct.id
                        LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct.targetTaxId
                        WHERE ipt.invoiceProductId = ep.id
                          AND NOT (
                              ipt.isMain = 0 AND ct.targetTaxId IS NOT NULL AND (
                                  target_ct.type = 'PRINCIPAL' OR target_ct.isEditable = 0 OR target_ct.code = 'TAR' OR target_ct.name LIKE '%TARIFA%' OR target_ct.id = ep.mainTaxId
                              )
                          )
                        FOR XML PATH('CargosImpuestos'), TYPE
                    ),
                    -- Sub-nodo: Variables (Variables Adicionales dinámicas de InvoicesProductVariable)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            CASE WHEN pr.type = 'Tiquete' THEN 1 ELSE 3 END AS [in_tipoitem],
                            CASE WHEN pr.type = 'Tiquete' THEN 'Tiquetes' ELSE 'FacturacionServicios' END AS [ds_maestro],
                            ISNULL(mv.name, mv.code) AS [ds_VariableAdicional],
                            ISNULL(ipv.value, '') AS [ds_valor],
                            ISNULL(mv.code, '') AS [cd_codigo]
                        FROM dbo.[InvoicesProductVariable] ipv
                        JOIN dbo.[MasterVariable] mv ON ipv.masterVariableId = mv.id
                        WHERE ipv.invoiceProductId = ep.id
                        FOR XML PATH('Variables'), TYPE
                    ),
                    -- Sub-nodo: TiposFacturacionHoteles (para desglose de tarifas por noche/unidad en hoteles y servicios)
                    (
                        SELECT 
                            e.id AS [id_factura],
                            ep.id AS [id_item],
                            3 AS [in_tipoitem],
                            'NCH' AS [cd_tiposfacturacionhoteles],
                            'Noches' AS [ds_tiposfacturacionhoteles],
                            ISNULL(ep.quantity, 1) AS [in_cantidad],
                            CAST(ISNULL(ep.price, 0) AS DECIMAL(18,2)) AS [am_valor],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                ELSE CAST(
                                    ROUND(
                                        ISNULL(ep.price * ep.quantity, 0) * 
                                        ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                        NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                    , 2) AS DECIMAL(18,2)
                                )
                            END AS [am_contado],
                            CASE 
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) LIKE '%tarjeta%' OR LOWER(ipp.paymentMethod) LIKE '%credito%')
                                ) THEN CAST(0 AS DECIMAL(18,2))
                                WHEN NOT EXISTS (
                                    SELECT 1 FROM dbo.[InvoicesProductPayment] ipp 
                                    WHERE ipp.invoiceProductId = ep.id AND (LOWER(ipp.paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(ipp.paymentMethod) NOT LIKE '%credito%')
                                ) THEN CAST(ISNULL(ep.price * ep.quantity, 0) AS DECIMAL(18,2))
                                ELSE CAST(
                                    (
                                        ISNULL(ep.price * ep.quantity, 0) - 
                                        ROUND(
                                            ISNULL(ep.price * ep.quantity, 0) * 
                                            ISNULL((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id AND LOWER(paymentMethod) NOT LIKE '%tarjeta%' AND LOWER(paymentMethod) NOT LIKE '%credito%'), 0) / 
                                            NULLIF((SELECT SUM(amount) FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId = ep.id), 0)
                                        , 2)
                                    ) AS DECIMAL(18,2)
                                )
                            END AS [am_credito],
                            ISNULL(ct_main.code, 'TAR') AS [cd_cargosdesc],
                            ISNULL(ct_main.name, 'TARIFA') AS [ds_cargonm],
                            ISNULL(ct_main.id, 1) AS [id_cargosdesc]
                        FROM (SELECT 1 AS dummy) d
                        LEFT JOIN dbo.[ChargeAndTax] ct_main ON ct_main.id = ep.mainTaxId
                        FOR XML PATH('TiposFacturacionHoteles'), TYPE
                    )
                FROM dbo.[InvoicesProduct] ep
                LEFT JOIN dbo.[ChargeAndTax] ct_main ON ep.mainTaxId = ct_main.id
                LEFT JOIN dbo.[Product] pr ON ep.productId = pr.id
                LEFT JOIN dbo.[Provider] prv ON ep.providerId = prv.id
                LEFT JOIN dbo.[InvoicesProductPasenger] pax1 ON pax1.id = (
                    SELECT MIN(pp_min.id) FROM dbo.[InvoicesProductPasenger] pp_min WHERE pp_min.invoiceProductId = ep.id
                )
                WHERE ep.invoiceId = e.id
                  AND (
                      ISNULL(ep.price, 0) > 0 
                      OR ISNULL(ep.cost, 0) > 0 
                      OR NULLIF(LTRIM(RTRIM(ep.descripcion)), '') IS NOT NULL 
                      OR NULLIF(LTRIM(RTRIM(ep.servicios)), '') IS NOT NULL
                  )
                FOR XML PATH('Item'), TYPE
            )
        FROM dbo.[Invoices] e
        LEFT JOIN dbo.[Client] c ON e.clientId = c.id
        LEFT JOIN dbo.[Branch] b ON e.branchId = b.id
        LEFT JOIN dbo.[Implant] imp ON e.implantId = imp.id
        LEFT JOIN dbo.[Seller] s ON e.sellerId = s.id
        LEFT JOIN dbo.[User] u ON e.userId = u.id
        LEFT JOIN dbo.[TicketPrinter] tp ON e.ticketPrinterId = tp.id
        WHERE e.id IN (SELECT id FROM @idsTable)
        FOR XML PATH('Facturacion'), ROOT('Facturaciones'), TYPE
    );

    DECLARE @v_xml VARCHAR(MAX) = CAST(@xmlResult AS VARCHAR(MAX));

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

GO


GO
