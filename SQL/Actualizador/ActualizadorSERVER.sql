-- ============================================================================
-- AGENCIASNEW - SCRIPT DE ACTUALIZACIÓN IDEMPOTENTE PARA SQL SERVER
-- Generado Automáticamente por deploy/sync_sqlserver_updater.js
-- Fecha de Generación: 2026-09-18T17:11:40.934Z
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
        [isActive] BIT NULL CONSTRAINT DF_TicketType_IsActive DEFAULT 1
    );
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
        [isActive] BIT NOT NULL CONSTRAINT DF_ChargeAndTax_IsActive DEFAULT 1
    );
END;

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
        [passenger] NVARCHAR(255) NULL
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
        [valueSnapshot] FLOAT NOT NULL,
        [valueTypeSnapshot] NVARCHAR(50) NOT NULL,
        [explicitAmount] FLOAT NULL,
        [isMain] BIT NOT NULL CONSTRAINT DF_QuotationProductTax_IsMain DEFAULT 0
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
        [userId] INT NULL CONSTRAINT FK_QuotationStateHistory_User REFERENCES dbo.[User]([id])
    );
END;

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
        [dueDate] DATETIME2 NULL
    );
END;

-- 20a. InvoicesProduct
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProduct' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProduct] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProduct PRIMARY KEY,
        [invoiceId] INT NOT NULL,
        [productId] INT NOT NULL,
        [quantity] INT NOT NULL,
        [price] FLOAT NOT NULL,
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
        [ticketCode] NVARCHAR(255) NULL
    );
END;

-- 20b. InvoicesProductTax
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InvoicesProductTax' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[InvoicesProductTax] (
        [id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoicesProductTax PRIMARY KEY,
        [invoiceProductId] INT NOT NULL,
        [chargeAndTaxId] INT NOT NULL,
        [valueSnapshot] FLOAT NOT NULL,
        [valueTypeSnapshot] NVARCHAR(50) NOT NULL,
        [explicitAmount] FLOAT NULL,
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
        [Nombre] VARCHAR(50) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VariableDefinicionMaestro' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.[VariableDefinicionMaestro] (
        [IDEN] NUMERIC(18,0) IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Codigo] VARCHAR(50) NULL
    );
END;

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
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ServidorSQLServer', N'Host de SQL Server', N'127.0.0.1');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'BaseSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'BaseSQLServer', N'Base de Datos SQL Server', N'Korex_colaereo');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'UsuarioSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'UsuarioSQLServer', N'Usuario SQL Server', N'sa');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ClaveSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ClaveSQLServer', N'Contraseña SQL Server', N'zzeusagencias');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PuertoSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PuertoSQLServer', N'Puerto SQL Server', N'1433');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarCotizacionesAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarCotizacionesAutoSQLserver', N'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', N'1');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarFacturacionAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarFacturacionAutoSQLserver', N'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', N'1');
END;

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
    VALUES (N'Eduardo Barrera', N'ebarrera@zagencias.com', N'$2b$10$e1v0/9V8ZPVqejcqarQfq.hDLlKuva.M/mNsSUxOTefeyuUTqoaW2', @SuperAdminRoleId, 1);
END
ELSE
BEGIN
    UPDATE dbo.[User] SET [roleId] = @SuperAdminRoleId WHERE [email] = N'ebarrera@zagencias.com';
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
IF OBJECT_ID('dbo.ImpRet', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ImpRet') AND name = 'in_tipo') ALTER TABLE dbo.ImpRet ADD in_tipo CHAR(1) NULL DEFAULT 'I';
GO
IF OBJECT_ID('dbo.TiposServicios', 'U') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TiposServicios') AND name = 'cd_cuenta') ALTER TABLE dbo.TiposServicios ADD cd_cuenta VARCHAR(20) NULL;
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







-- ==========================================
-- Procedimiento Zeus ERP: spCotizacionesCrear.sql
-- ==========================================

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
			id_TiposConceptFac = ISNULL(CF.id_TiposConceptoFacturacion, ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(C.CotizacionServicios.value('cd_conceptofacturacion[1]','VARCHAR(25)')))), ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = 'SOP'), 2))),
			id_ConceptoFacturacion = ISNULL(CF.id, ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(C.CotizacionServicios.value('cd_conceptofacturacion[1]','VARCHAR(25)')))), ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = 'SOP'), 3))),
			id_TiposServicio = ISNULL(
				TS.id,
				ISNULL(
					(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(C.CotizacionServicios.value('cd_tiposservicio[1]','VARCHAR(50)')))),
					ISNULL(
						(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(C.CotizacionServicios.value('cd_tiposservicio[1]','VARCHAR(100)')))),
						ISNULL(
							(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(C.CotizacionServicios.value('ds_servicio[1]','VARCHAR(100)')))),
							ISNULL(
								(SELECT TOP 1 TSA2.id_TipoServicio FROM dbo.tiposServicio_asignados TSA2 JOIN dbo.TiposServicios TS2 ON TS2.id = TSA2.id_TipoServicio WHERE TSA2.id_ConceptoFacturacion = CF.id),
								ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = 'htn'), 1)
							)
						)
					)
				)
			),
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
		 LEFT JOIN dbo.ConceptoFacturacion CF ON RTRIM(LTRIM(CF.cd_codigo)) = RTRIM(LTRIM(C.CotizacionServicios.value('cd_conceptofacturacion[1]','VARCHAR(25)')))
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
		
		-- Validar Regla Universal de Cuentas Contables para Cotizaciones
		-- 1. CARGOS / SERVICIOS (3 Niveles: 1. Tipo de Servicio -> 2. Concepto de Facturación -> 3. Cargo)
		DECLARE @c_srv_name VARCHAR(100), @c_id_ts INT, @c_id_cf INT, @c_id_cd INT, @c_cargo_name VARCHAR(100), @c_acct VARCHAR(20), @c_cot_num VARCHAR(50);
		DECLARE curCotCargos CURSOR LOCAL FAST_FORWARD FOR
		SELECT 
			CS.ds_servicio,
			CS.id_TiposServicio,
			CS.id_ConceptoFacturacion,
			CC.id_cargosdesc,
			CC.ds_cargonm,
			CC.cd_Cotizacion
		FROM @CotizacionCargos CC
		JOIN @CotizacionServicios CS ON CS.cd_Consecutivo_VariablesAdicionales = CC.cd_CotizacionServicios AND CS.cd_Cotizacion = CC.cd_Cotizacion;

		OPEN curCotCargos;
		FETCH NEXT FROM curCotCargos INTO @c_srv_name, @c_id_ts, @c_id_cf, @c_id_cd, @c_cargo_name, @c_cot_num;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @c_acct = NULL;
			
			-- 1. Tipo de Servicio
			IF @c_id_ts IS NOT NULL
				SELECT TOP 1 @c_acct = cd_cuenta FROM dbo.TiposServicios WHERE id = @c_id_ts AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
				
			-- 2. Concepto de Facturación
			IF (@c_acct IS NULL OR RTRIM(LTRIM(@c_acct)) = '') AND @c_id_cf IS NOT NULL
				SELECT TOP 1 @c_acct = cd_cuenta FROM dbo.ConceptoFacturacion WHERE id = @c_id_cf AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
				
			-- 3. Cargo
			IF (@c_acct IS NULL OR RTRIM(LTRIM(@c_acct)) = '') AND @c_id_cd IS NOT NULL
				SELECT TOP 1 @c_acct = cd_cuenta FROM dbo.CargosDesc WHERE id = @c_id_cd AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
				
			IF @c_acct IS NULL OR RTRIM(LTRIM(@c_acct)) = ''
			BEGIN
				CLOSE curCotCargos;
				DEALLOCATE curCotCargos;
				DECLARE @err_cot_acct NVARCHAR(4000) = '❌ Cotización ' + ISNULL(@c_cot_num, '') + ': Error de Parametrización Contable: No fue posible determinar la cuenta contable para el Cargo/Servicio "' + ISNULL(@c_cargo_name, ISNULL(@c_srv_name, 'Cargo')) + '". Verifique la parametrización en Tipo de Servicio, Concepto de Facturación o Cargo.';
				RAISERROR(@err_cot_acct, 16, 1);
				RETURN;
			END

			FETCH NEXT FROM curCotCargos INTO @c_srv_name, @c_id_ts, @c_id_cf, @c_id_cd, @c_cargo_name, @c_cot_num;
		END
		CLOSE curCotCargos;
		DEALLOCATE curCotCargos;

		-- 2. IMPUESTOS (Directo desde ImpRet)
		DECLARE @c_tax_name VARCHAR(100), @c_id_ir INT, @c_tax_acct VARCHAR(20), @c_tax_cot VARCHAR(50);
		DECLARE curCotTaxes CURSOR LOCAL FAST_FORWARD FOR
		SELECT CI.ds_Impas, CI.id_ImpRet, CI.cd_Cotizacion
		FROM @CotizacionImpuestos CI;

		OPEN curCotTaxes;
		FETCH NEXT FROM curCotTaxes INTO @c_tax_name, @c_id_ir, @c_tax_cot;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @c_tax_acct = NULL;
			IF @c_id_ir IS NOT NULL
				SELECT TOP 1 @c_tax_acct = cd_cuenta FROM dbo.ImpRet WHERE id = @c_id_ir AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
				
			IF @c_tax_acct IS NULL OR RTRIM(LTRIM(@c_tax_acct)) = ''
			BEGIN
				CLOSE curCotTaxes;
				DEALLOCATE curCotTaxes;
				DECLARE @err_cot_tax NVARCHAR(4000) = '❌ Cotización ' + ISNULL(@c_tax_cot, '') + ': Error de Parametrización Contable: El Impuesto "' + ISNULL(@c_tax_name, 'Impuesto') + '" no tiene cuenta contable configurada en la tabla de Impuestos (ImpRet).';
				RAISERROR(@err_cot_tax, 16, 1);
				RETURN;
			END

			FETCH NEXT FROM curCotTaxes INTO @c_tax_name, @c_id_ir, @c_tax_cot;
		END
		CLOSE curCotTaxes;
		DEALLOCATE curCotTaxes;

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


-- ==========================================
-- Procedimiento Zeus ERP: spFacturacionesCrear.sql
-- ==========================================

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

    IF OBJECT_ID('dbo.ImpRet') IS NULL
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

    IF OBJECT_ID('dbo.CargosDesc') IS NULL
    BEGIN
        CREATE TABLE dbo.CargosDesc (
            id INT IDENTITY(1,1) PRIMARY KEY,
            cd_codigo VARCHAR(20) NOT NULL,
            ds_nombre VARCHAR(250) NULL,
            cd_cuenta VARCHAR(20) NULL
        );
    END;
    IF OBJECT_ID('dbo.CargosDesc') IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CargosDesc') AND name = 'cd_cuenta')
            ALTER TABLE dbo.CargosDesc ADD cd_cuenta VARCHAR(20) NULL;

        UPDATE dbo.CargosDesc 
        SET cd_cuenta = '28151080' 
        WHERE (cd_codigo = 'TAR' OR id = 1) AND (cd_cuenta IS NULL OR RTRIM(LTRIM(cd_cuenta)) = '');
    END;

    IF OBJECT_ID('dbo.parametros') IS NULL
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

    IF OBJECT_ID('dbo.Parametr') IS NULL
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
			id INT IDENTITY(1,1),
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
			id_tiposconceptfac = ISNULL(CF.id_TiposConceptoFacturacion, ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(F.Item.value('cd_conceptofacturacion[1]','VARCHAR(25)')))), ISNULL((SELECT TOP 1 id_TiposConceptoFacturacion FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = 'SOP'), 2))),
			id_conceptofacturacion = ISNULL(CF.id, ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(F.Item.value('cd_conceptofacturacion[1]','VARCHAR(25)')))), ISNULL((SELECT TOP 1 id FROM dbo.ConceptoFacturacion WHERE RTRIM(LTRIM(cd_codigo)) = 'SOP'), 3))),
			id_tiposservicio = ISNULL(
				TS.id,
				ISNULL(
					(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(F.Item.value('cd_tiposservicio[1]','VARCHAR(50)')))),
					ISNULL(
						(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(F.Item.value('cd_tiposservicio[1]','VARCHAR(100)')))),
						ISNULL(
							(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(F.Item.value('ds_servicio[1]','VARCHAR(100)')))),
							ISNULL(
								(SELECT TOP 1 TSA2.id_TipoServicio FROM dbo.tiposServicio_asignados TSA2 JOIN dbo.TiposServicios TS2 ON TS2.id = TSA2.id_TipoServicio WHERE TSA2.id_ConceptoFacturacion = CF.id),
								ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = 'htn'), 1)
							)
						)
					)
				)
			),
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
		LEFT JOIN dbo.ConceptoFacturacion CF ON RTRIM(LTRIM(CF.cd_codigo)) = RTRIM(LTRIM(F.Item.value('cd_conceptofacturacion[1]','VARCHAR(25)')))
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
			id_carg = ISNULL(
				CD.id,
				ISNULL(
					(SELECT TOP 1 id FROM dbo.CargosDesc WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(C.Cargo.value('cd_codigo[1]', 'VARCHAR(20)'))) OR RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(C.Cargo.value('ds_nombre[1]', 'VARCHAR(100)')))),
					ISNULL(
						(SELECT TOP 1 id FROM dbo.CargosDesc WHERE cd_codigo = 'TAR'),
						CASE WHEN CD.id IS NOT NULL THEN CD.id ELSE ISNULL(IR.Id_cargo_dep, 1) END
					)
				)
			),
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
			SELECT DISTINCT id_factura, cd_fuente, cd_serie, cd_consecutivo
			FROM #Facturacion;

			OPEN curInvoices;
			FETCH NEXT FROM curInvoices INTO @id_facturacion, @cd_fuente, @cd_serie, @cd_consecutivo;

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

				-- Fetch header details from the specific invoice record

				SELECT TOP 1
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
				WHERE id_factura = @id_facturacion;

				-- Enriquecimiento obligatorio desde el maestro CLIENTES de Zeus ERP
				DECLARE @z_dir VARCHAR(250), @z_ciudad VARCHAR(50), @z_tel VARCHAR(50), @z_email VARCHAR(100), @z_vendedor VARCHAR(10), @z_razoncial VARCHAR(250);
				SELECT TOP 1 
					@z_razoncial = RTRIM(LTRIM(RAZONCIAL)),
					@z_dir = RTRIM(LTRIM(DIRECCION)), 
					@z_ciudad = RTRIM(LTRIM(CIUDAD)), 
					@z_tel = RTRIM(LTRIM(TELEFONO)), 
					@z_email = RTRIM(LTRIM(EMAIL)), 
					@z_vendedor = RTRIM(LTRIM(IDVENDE)) 
				FROM dbo.CLIENTES 
				WHERE LTRIM(RTRIM(IDCLIENTE)) = LTRIM(RTRIM(@cd_cliente)) OR LTRIM(RTRIM(IDCLIENTE)) = LTRIM(RTRIM(@ds_cliid));

				IF @z_dir IS NOT NULL AND @z_dir <> '' SET @ds_clidir = @z_dir;
				IF @z_ciudad IS NOT NULL AND @z_ciudad <> '' SET @ds_clicity = @z_ciudad;
				IF @z_tel IS NOT NULL AND @z_tel <> '' SET @ds_clitel = @z_tel;
				IF @z_email IS NOT NULL AND @z_email <> '' SET @ds_ClienteEmail = @z_email;
				IF @z_vendedor IS NOT NULL AND @z_vendedor <> '' SET @cd_vendedor = @z_vendedor;
				IF @z_razoncial IS NOT NULL AND @z_razoncial <> '' SET @ds_cliname = @z_razoncial;

				-- Validar que el vendedor exista en MAEVENDE de Zeus ERP
				IF @cd_vendedor IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.MAEVENDE WHERE RTRIM(LTRIM(IDVENDE)) = RTRIM(LTRIM(@cd_vendedor)))
				BEGIN
					SELECT TOP 1 @cd_vendedor = IDVENDE FROM dbo.MAEVENDE WHERE IDVENDE IS NOT NULL ORDER BY IDVENDE ASC;
				END;

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
				FROM #TmpFacturaItems
				WHERE id_factura = @id_facturacion;

				IF @ValorFactura IS NULL OR @ValorFactura = 0
				BEGIN
					SELECT @ValorFactura = SUM(am_valor)
					FROM #TmpFacturaCargos;
				END;
				IF @ValorFactura IS NULL SET @ValorFactura = 0;

				UPDATE #Facturacion
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 8)
				WHERE tipo IN ('SRV','Hotel','Auto') AND cd_Consecutivo_variablesadicionales IS NULL AND id_factura = @id_facturacion;

				-- Build dynamic SQL @SqlStmt
				SET @SqlStmt = '';
				SET @ItemIndex = 1;	
					

				-- Generar cd_Consecutivo_variablesadicionales aleatorio para los servicios padres (8 caracteres para concordar con Fac_Servicios)
				UPDATE #TmpFacturaItems
				SET cd_Consecutivo_variablesadicionales = LEFT(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 8)
				WHERE tipo_item IN ('SRV','Hotel','Auto') AND (cd_Consecutivo_variablesadicionales IS NULL OR cd_Consecutivo_variablesadicionales = '') AND id_factura = @id_facturacion;
				 
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
					  AND CF.id NOT IN(1,2)
					  AND ISNULL(FP.am_valor, 0) = 0
					  AND (SELECT COUNT(*) FROM #TmpFacturaFormasPago WHERE id_item = FP.id_item) = 1;	
								
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
						
						-- Variables Adicionales para Tiquetes (desde #VariablesAdicionales enviadas en XML)
						DECLARE @var_Iden_Variable INT, @var_IDEN_Maestro INT, @var_ValorObtenido VARCHAR(MAX), @var_TipoDato VARCHAR(20);
						DECLARE curVarsTkt CURSOR LOCAL FAST_FORWARD FOR
						SELECT 
							ISNULL(vd.IDEN, 0) AS Iden_Variable,
							ISNULL(vdm.IDEN, 35) AS IDEN_Maestro,
							va.ds_valor AS ValorObtenido,
							ISNULL(vd.TipoDato, 'Varchar') AS TipoDato
						FROM #VariablesAdicionales va
						LEFT JOIN dbo.VariableDefinicion vd ON (
							UPPER(RTRIM(LTRIM(vd.Nombre))) = UPPER(RTRIM(LTRIM(va.ds_VariableAdicional)))
							OR UPPER(RTRIM(LTRIM(vd.Nombre))) = UPPER(RTRIM(LTRIM(va.cd_codigo)))
							OR UPPER(RTRIM(LTRIM(vd.Descripcion))) = UPPER(RTRIM(LTRIM(va.ds_VariableAdicional)))
							OR UPPER(RTRIM(LTRIM(vd.Presentacion))) = '[' + UPPER(RTRIM(LTRIM(va.ds_VariableAdicional))) + ']'
							OR UPPER(RTRIM(LTRIM(vd.Presentacion))) = '[' + UPPER(RTRIM(LTRIM(va.cd_codigo))) + ']'
						)
						LEFT JOIN dbo.VariableDefinicionMaestro vdm ON vdm.Codigo = 'Tiquetes'
						WHERE (va.id_item = @gen_id_item OR (va.id_facturacion = @id_facturacion AND (va.id_item IS NULL OR va.id_item = 0)))
						  AND ISNULL(va.ds_valor, '') <> '';

						OPEN curVarsTkt;
						FETCH NEXT FROM curVarsTkt INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido, @var_TipoDato;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @var_Iden_Variable > 0
							BEGIN
								SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' IF NOT EXISTS (SELECT 1 FROM dbo.VariableMaestro WHERE IDEN_Maestro = ' + CAST(@var_IDEN_Maestro AS VARCHAR) + ' AND IDEN_Variable = ' + CAST(@var_Iden_Variable AS VARCHAR) + ') INSERT INTO dbo.VariableMaestro (IDEN_Maestro, IDEN_Variable, Formula, OrdenEvaluacion) VALUES (' + CAST(@var_IDEN_Maestro AS VARCHAR) + ', ' + CAST(@var_Iden_Variable AS VARCHAR) + ', '''', 0);' + CHAR(13) + CHAR(10) +
									' INSERT INTO dbo.VariableDatosMaestro (IDEN_Maestro, IDEN_Variable, CodigoMaestro, ValorNumerico, ValorFecha, ValorVarchar) VALUES (' + 
									CAST(@var_IDEN_Maestro AS VARCHAR) + ', ' + 
									CAST(@var_Iden_Variable AS VARCHAR) + ', ''' + 
									REPLACE(@gen_cd_tiquete, '''', '''''') + ''', ' +
									CASE WHEN @var_TipoDato IN ('Numeric', 'Integer') AND ISNUMERIC(@var_ValorObtenido) = 1 THEN REPLACE(@var_ValorObtenido, ',', '.') ELSE 'NULL' END + ', ' +
									CASE WHEN @var_TipoDato = 'Date' AND ISDATE(@var_ValorObtenido) = 1 THEN '''' + REPLACE(@var_ValorObtenido, '''', '''''') + '''' ELSE 'NULL' END + ', ''' +
									REPLACE(@var_ValorObtenido, '''', '''''') + ''');';
							END;
							FETCH NEXT FROM curVarsTkt INTO @var_Iden_Variable, @var_IDEN_Maestro, @var_ValorObtenido, @var_TipoDato;
						END;
						CLOSE curVarsTkt;
						DEALLOCATE curVarsTkt;
						
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
								SET @TktImpuestosSqlStmt = @TktImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteImpuestos_Insertar @id_tiquetecargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@ds_nombretax,'') + ''', @cd_impcta = '''', @am_valor = ' + CAST(ISNULL(@am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@am_creditotax,0) AS VARCHAR) + ', @am_porcentaje=' + CAST(ISNULL(@am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;' 
								FETCH NEXT FROM curItemTaxes INTO @c_codigotax, @ds_nombretax, @cd_tipotax, @am_porcentajetax, @am_valortax, @am_contadotax, @am_creditotax, @id_cargtax, @id_imptax;
							END
							CLOSE curItemTaxes;
							DEALLOCATE curItemTaxes;

							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteCargos_Insertar @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_tiquetes = @NewTktId, @id_cargosdesc = ' + CAST(ISNULL(@id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@ds_nombre,'') + ''', @am_valor = ' + CAST(ISNULL(@am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@TktImpuestosSqlStmt,''), '''', '''''') + ''';'  
							
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
							SET @TktSqlStmt = @TktSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_TiqueteFormasPago_Insertar @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_Tiquetes = @NewTktId, @id_formaspago = ' + CAST(@fp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@fp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_tarjetascredito = ' + ISNULL(CAST(@fp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @fp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @fp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @fp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @fp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@fp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @fp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@fp_in_cuotas AS VARCHAR), '0') + ';' 
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
							@am_iva = ' + ISNULL(CAST(@gen_am_iva AS VARCHAR),'0') + ',
							@am_comision = ' + ISNULL(CAST(@gen_am_comision AS VARCHAR),'0') + ',
							@am_porcomision = ' + ISNULL(CAST(@gen_am_porcomision AS VARCHAR),'0') + ',
							@am_tua = ' + ISNULL(CAST(@gen_am_tua AS VARCHAR),'0') + ',
							@am_comb = ' + ISNULL(CAST(@gen_am_comb AS VARCHAR),'0') + ',
							@am_vat = ' + ISNULL(CAST(@gen_am_vat AS VARCHAR),'0') + ',
							@cd_ah = ''' + ISNULL(@gen_cd_tourcode, '') + ''',
							@am_desah = 0,
							@id_gds = ' + ISNULL(CAST(@gen_id_gds AS VARCHAR),'NULL') + ',
							@iden_gds = ' + ISNULL(CAST(@gen_iden_gds AS VARCHAR),'NULL') + ',
							@in_numtktconj = ' + ISNULL(CAST(@gen_NumTktConj AS VARCHAR),'0') + ',
							@bl_NoCalcComision = 0,
							@bl_NoCalcIvaComision = 0,
							@am_comisionPNR = ' + ISNULL(CAST(@gen_am_Comision AS VARCHAR),'0') + ',
							@am_basecomisionable = ' + ISNULL(CAST(@gen_am_tarifa AS VARCHAR),'0') + ',
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
						
						-- Variables Adicionales para Servicios (desde #VariablesAdicionales enviadas en XML)
						IF ISNULL(@gen_cd_Consecutivo_variablesadicionales, '') = ''
						BEGIN
							SET @gen_cd_Consecutivo_variablesadicionales = 'I' + RIGHT('0000000' + CAST(@gen_id_item AS VARCHAR), 7);
						END;

						DECLARE @SrvVarsSqlStmt VARCHAR(MAX) = '';
						SET @SrvVarsSqlStmt = '';
						DECLARE @var_Iden_Variable_srv INT, @var_IDEN_Maestro_srv INT, @var_ValorObtenido_srv VARCHAR(MAX), @var_TipoDato_srv VARCHAR(20);
						DECLARE curVarsSrv CURSOR LOCAL FAST_FORWARD FOR
						SELECT 
							ISNULL(vd.IDEN, 0) AS Iden_Variable,
							ISNULL(vdm.IDEN, 37) AS IDEN_Maestro,
							va.ds_valor AS ValorObtenido,
							ISNULL(vd.TipoDato, 'Varchar') AS TipoDato
						FROM #VariablesAdicionales va
						LEFT JOIN dbo.VariableDefinicion vd ON (
							UPPER(RTRIM(LTRIM(vd.Nombre))) = UPPER(RTRIM(LTRIM(va.ds_VariableAdicional)))
							OR UPPER(RTRIM(LTRIM(vd.Nombre))) = UPPER(RTRIM(LTRIM(va.cd_codigo)))
							OR UPPER(RTRIM(LTRIM(vd.Descripcion))) = UPPER(RTRIM(LTRIM(va.ds_VariableAdicional)))
							OR UPPER(RTRIM(LTRIM(vd.Presentacion))) = '[' + UPPER(RTRIM(LTRIM(va.ds_VariableAdicional))) + ']'
							OR UPPER(RTRIM(LTRIM(vd.Presentacion))) = '[' + UPPER(RTRIM(LTRIM(va.cd_codigo))) + ']'
						)
						LEFT JOIN dbo.VariableDefinicionMaestro vdm ON vdm.Codigo = 'FacturacionServicios'
						WHERE (va.id_item = @gen_id_item OR (va.id_facturacion = @id_facturacion AND (va.id_item IS NULL OR va.id_item = 0)))
						  AND ISNULL(va.ds_valor, '') <> '';

						OPEN curVarsSrv;
						FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv, @var_TipoDato_srv;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @var_Iden_Variable_srv > 0
							BEGIN
								SET @SrvVarsSqlStmt = @SrvVarsSqlStmt + CHAR(13) + CHAR(10) + ' IF NOT EXISTS (SELECT 1 FROM dbo.VariableMaestro WHERE IDEN_Maestro = ' + CAST(@var_IDEN_Maestro_srv AS VARCHAR) + ' AND IDEN_Variable = ' + CAST(@var_Iden_Variable_srv AS VARCHAR) + ') INSERT INTO dbo.VariableMaestro (IDEN_Maestro, IDEN_Variable, Formula, OrdenEvaluacion) VALUES (' + CAST(@var_IDEN_Maestro_srv AS VARCHAR) + ', ' + CAST(@var_Iden_Variable_srv AS VARCHAR) + ', '''', 0);' + CHAR(13) + CHAR(10) +
									' INSERT INTO dbo.VariableDatosMaestro (IDEN_Maestro, IDEN_Variable, CodigoMaestro, ValorNumerico, ValorFecha, ValorVarchar)' +
									' SELECT ' + CAST(@var_IDEN_Maestro_srv AS VARCHAR) + ', ' + CAST(@var_Iden_Variable_srv AS VARCHAR) + ', cd_Consecutivo_VariablesAdicionales, ' +
									CASE WHEN @var_TipoDato_srv IN ('Numeric', 'Integer') AND ISNUMERIC(@var_ValorObtenido_srv) = 1 THEN REPLACE(@var_ValorObtenido_srv, ',', '.') ELSE 'NULL' END + ', ' +
									CASE WHEN @var_TipoDato_srv = 'Date' AND ISDATE(@var_ValorObtenido_srv) = 1 THEN '''' + REPLACE(@var_ValorObtenido_srv, '''', '''''') + '''' ELSE 'NULL' END + ', ''' +
									REPLACE(@var_ValorObtenido_srv, '''', '''''') + '''' +
									' FROM dbo.Fac_Servicios WHERE id = @NewSrvId;';
							END;
							FETCH NEXT FROM curVarsSrv INTO @var_Iden_Variable_srv, @var_IDEN_Maestro_srv, @var_ValorObtenido_srv, @var_TipoDato_srv;
						END;
						CLOSE curVarsSrv;
						DEALLOCATE curVarsSrv;

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
								-- Validar cuenta del Impuesto (Directo desde ImpRet)
							IF @sc_id_imptax IS NOT NULL
							BEGIN
								DECLARE @tax_acct_val VARCHAR(20) = NULL;
								SELECT @tax_acct_val = cd_cuenta FROM dbo.ImpRet WHERE id = @sc_id_imptax;
								IF @tax_acct_val IS NULL OR RTRIM(LTRIM(@tax_acct_val)) = ''
								BEGIN
									DECLARE @err_tax_msg NVARCHAR(4000) = '❌ Error de Parametrización Contable: El Impuesto "' + ISNULL(@sc_ds_nombretax, 'DESCONOCIDO') + '" no tiene cuenta contable configurada en la tabla de Impuestos (ImpRet). Por favor verifique la parametrización en AgenciasNew o en Zeus ERP antes de continuar.';
									RAISERROR(@err_tax_msg, 16, 1);
									RETURN;
								END;
							END;
								SET @SrvImpuestosSqlStmt = @SrvImpuestosSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioImpuestos_Insertar @id_FacServiciosCargos = @NewCargId, @id_impret = ' + CAST(ISNULL(@sc_id_imptax, 1) AS VARCHAR) + ', @ds_impas = ''' + ISNULL(@sc_ds_nombretax,'') + ''', @cd_impcta='''', @am_valor = ' + CAST(ISNULL(@sc_am_valortax,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contadotax,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_creditotax,0) AS VARCHAR) + ', @am_porcentaje=' + CAST(ISNULL(@sc_am_porcentajetax,0) AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @bl_contabilizar=1;' 
								
							FETCH NEXT FROM curItemSrvTaxes INTO @sc_codigotax, @sc_ds_nombretax, @sc_cd_tipotax, @sc_am_porcentajetax, @sc_am_valortax, @sc_am_contadotax, @sc_am_creditotax, @sc_id_cargtax, @sc_id_imptax;
						END
						CLOSE curItemSrvTaxes;
						DEALLOCATE curItemSrvTaxes;

						-- REGLA UNIVERSAL DE ASIGNACION DE CUENTAS CONTABLES (3 NIVELES)
						-- 1ª Prioridad: Tipo de Servicio (TiposServicios.cd_cuenta)
						-- 2ª Prioridad: Concepto de Facturacion (ConceptoFacturacion.cd_cuenta)
						-- 3ª Prioridad: Cargo (CargosDesc.cd_cuenta)
						DECLARE @resolved_account VARCHAR(20) = NULL;

						IF @gen_id_tiposservicio IS NOT NULL
						BEGIN
							SELECT @resolved_account = cd_cuenta 
							FROM dbo.TiposServicios 
							WHERE id = @gen_id_tiposservicio AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
						END;

						IF (@resolved_account IS NULL OR RTRIM(LTRIM(@resolved_account)) = '') AND @gen_id_conceptofacturacion IS NOT NULL
						BEGIN
							SELECT @resolved_account = cd_cuenta 
							FROM dbo.ConceptoFacturacion 
							WHERE id = @gen_id_conceptofacturacion AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
						END;

						IF (@resolved_account IS NULL OR RTRIM(LTRIM(@resolved_account)) = '') AND @sc_id_carg IS NOT NULL
						BEGIN
							SELECT @resolved_account = cd_cuenta 
							FROM dbo.CargosDesc 
							WHERE id = @sc_id_carg AND cd_cuenta IS NOT NULL AND RTRIM(LTRIM(cd_cuenta)) <> '';
						END;

						-- Si ninguno de los 3 niveles tiene cuenta contable, detener y emitir error controlado
						IF @resolved_account IS NULL OR RTRIM(LTRIM(@resolved_account)) = ''
						BEGIN
							DECLARE @err_cargo_msg NVARCHAR(4000) = '❌ Error de Parametrización Contable: No fue posible determinar la cuenta contable para el Cargo/Servicio "' + ISNULL(@sc_ds_nombre, 'DESCONOCIDO') + '". Verifique la parametrización en Tipo de Servicio (' + ISNULL(@gen_ds_tiposservicio, '') + '), Concepto de Facturación o Cargo.';
							RAISERROR(@err_cargo_msg, 16, 1);
							RETURN;
						END;

						SET @SrvCargSqlStmt = @SrvCargSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioCargos_Insertar @id_Fac_Servicios = @NewSrvId, @id_cargosdesc = ' + CAST(ISNULL(@sc_id_carg, 1) AS VARCHAR) + ', @ds_cargonm = ''' + ISNULL(@sc_ds_nombre,'') + ''', @am_valor = ' + CAST(ISNULL(@sc_am_valor,0) AS VARCHAR) + ', @am_contado = ' + CAST(ISNULL(@sc_am_contado,0) AS VARCHAR) + ', @am_credito = ' + CAST(ISNULL(@sc_am_credito,0) AS VARCHAR) + ', @bl_noshow = 0, @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @SqlStmt = ''' + REPLACE(ISNULL(@SrvImpuestosSqlStmt,''), '''', '''''') + ''';' 
						
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
						SET @SrvFpSqlStmt = @SrvFpSqlStmt + CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioFormasPago_Insertar @id_fac_factura = @NewFacId, @id_fac_remision = @NewRmId, @id_Fac_Servicios = @NewSrvId, @id_formaspago = ' + CAST(@sfp_id_fp AS VARCHAR) + ', @ds_fpnm = ''' + REPLACE(@sfp_ds_nombre, '''', '''''') + ''', @bl_fprepresenta = 0, @id_tarjetascredito = ' + ISNULL(CAST(@sfp_id_tc AS VARCHAR), 'NULL') + ', @cd_tccode = ' + ISNULL('''' + @sfp_cd_tipotarjeta + '''', 'NULL') + ', @ds_tcnumber = ' + ISNULL('''' + @sfp_ds_numerotarjeta + '''', 'NULL') + ', @ds_tcvoucher = ' + ISNULL('''' + @sfp_ds_vouchertarjeta + '''', 'NULL') + ', @ds_tcexp = ' + ISNULL('''' + @sfp_ds_expiraciontarjeta + '''', 'NULL') + ', @cd_idbanco = NULL, @ds_cheque = NULL, @ds_plaza = NULL, @ds_referencia = NULL, @ds_poliza = NULL, @ds_polanexo = NULL, @am_valor = ' + CAST(@sfp_am_valor AS VARCHAR) + ', @id_monedas_iata = @id_monedas_iata, @Tcambio = @Tcambio, @ds_tcautorizacion = ' + ISNULL('''' + @sfp_ds_autorizaciontarjeta + '''', 'NULL') + ', @in_tccuotas = ' + ISNULL(CAST(@sfp_in_cuotas AS VARCHAR), '0') + ';' 
						FETCH NEXT FROM curItemSrvFPs INTO @sfp_id_fp, @sfp_id_tc, @sfp_cd_codigo, @sfp_ds_nombre, @sfp_cd_tipotarjeta, @sfp_ds_numerotarjeta, @sfp_ds_vouchertarjeta, @sfp_ds_expiraciontarjeta, @sfp_ds_autorizaciontarjeta, @sfp_in_cuotas, @sfp_am_valor;
					END
					CLOSE curItemSrvFPs;
					DEALLOCATE curItemSrvFPs;

					-- Build provider SQL
					SET @SrvProvSqlStmt = '';
					DECLARE @c_id_tipoproveedor INT, @c_cd_tipoproveedor VARCHAR(10), @c_ds_tipoproveedor VARCHAR(100);
					
					IF @gen_cd_proveedores IS NOT NULL
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
							SET @SrvProvSqlStmt = CHAR(13) + CHAR(10) + ' EXECUTE dbo.spza_ServicioTipoProv_Insertar @id_Fac_Servicios = @NewSrvId, @id_tipoproveedores = ' + CAST(@c_id_tipoproveedor AS VARCHAR) + ', @cd_TipoProveedores = ''' + ISNULL(@c_cd_tipoproveedor,'') + ''', @ds_TipoProveedores = ''' + ISNULL(@c_ds_tipoproveedor,'')+ ''', @cd_proveedores = ''' + ISNULL(@c_cd_proveedores,'')+''', @ds_proveedores = ''' + ISNULL(@c_cd_proveedores,'')+ ''';'
						END;
					END;

					IF @gen_id_tiposservicio IS NULL
					BEGIN
						SELECT TOP 1 @gen_id_tiposservicio = ISNULL(
							(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(@gen_ds_tiposservicio))),
							ISNULL(
								(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(@gen_ds_tiposservicio))),
								ISNULL(
									(SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(ds_nombre)) = RTRIM(LTRIM(@gen_ds_servicio))),
									ISNULL((SELECT TOP 1 id FROM dbo.TiposServicios WHERE RTRIM(LTRIM(cd_codigo)) = 'htn'), 1)
								)
							)
						);
					END;

						SELECT @gen_ds_tiposservicio = ds_nombre FROM dbo.TiposServicios WHERE id = @gen_id_tiposservicio;

						-- Separar nombre y apellido del titular si ds_paxape viene vacio
						IF (ISNULL(@gen_ds_paxape, '') = '' AND CHARINDEX(' ', LTRIM(RTRIM(@gen_ds_paxname))) > 0)
						BEGIN
							DECLARE @raw_pax_main VARCHAR(100) = LTRIM(RTRIM(@gen_ds_paxname));
							IF LEN(@raw_pax_main) - LEN(REPLACE(@raw_pax_main, ' ', '')) = 1
							BEGIN
								SET @gen_ds_paxape = LTRIM(SUBSTRING(@raw_pax_main, CHARINDEX(' ', @raw_pax_main) + 1, 100));
								SET @gen_ds_paxname = SUBSTRING(@raw_pax_main, 1, CHARINDEX(' ', @raw_pax_main) - 1);
							END
							ELSE
							BEGIN
								DECLARE @sp_idx INT = CHARINDEX(' ', @raw_pax_main, CHARINDEX(' ', @raw_pax_main) + 1);
								SET @gen_ds_paxape = LTRIM(SUBSTRING(@raw_pax_main, @sp_idx + 1, 100));
								SET @gen_ds_paxname = SUBSTRING(@raw_pax_main, 1, @sp_idx - 1);
							END
						END;

						-- Build pax adicionales SQL (pasajeros orden > 1)
						SET @SrvPaxSqlStmt = '';
						DECLARE @ad_paxname VARCHAR(50), @ad_paxape VARCHAR(50), @ad_paxprefix VARCHAR(10), @ad_voucher VARCHAR(50), @ad_ident VARCHAR(50);
						DECLARE curExtraPax CURSOR LOCAL FAST_FORWARD FOR
						SELECT 
							CASE 
								WHEN ISNULL(ds_paxape, '') <> '' THEN ds_paxname
								WHEN CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) = 0 THEN ds_paxname
								WHEN LEN(LTRIM(RTRIM(ds_paxname))) - LEN(REPLACE(LTRIM(RTRIM(ds_paxname)), ' ', '')) = 1 
									THEN SUBSTRING(LTRIM(RTRIM(ds_paxname)), 1, CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) - 1)
								ELSE SUBSTRING(LTRIM(RTRIM(ds_paxname)), 1, CHARINDEX(' ', LTRIM(RTRIM(ds_paxname)), CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) + 1) - 1)
							END AS ds_paxname,
							CASE 
								WHEN ISNULL(ds_paxape, '') <> '' THEN ds_paxape
								WHEN CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) = 0 THEN ''
								WHEN LEN(LTRIM(RTRIM(ds_paxname))) - LEN(REPLACE(LTRIM(RTRIM(ds_paxname)), ' ', '')) = 1 
									THEN LTRIM(SUBSTRING(LTRIM(RTRIM(ds_paxname)), CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) + 1, 100))
								ELSE LTRIM(SUBSTRING(LTRIM(RTRIM(ds_paxname)), CHARINDEX(' ', LTRIM(RTRIM(ds_paxname)), CHARINDEX(' ', LTRIM(RTRIM(ds_paxname))) + 1) + 1, 100))
							END AS ds_paxape,
							ISNULL(NULLIF(ds_paxprefix, ''), 'SR') AS ds_paxprefix,
							cd_voucherpax,
							cd_paxidentificacion
						FROM (
							SELECT *, ROW_NUMBER() OVER (ORDER BY id ASC) AS rn
							FROM #Pasajeros
							WHERE id_item = @gen_id_item
						) p_numbered
						WHERE p_numbered.rn > 1;

						OPEN curExtraPax;
						FETCH NEXT FROM curExtraPax INTO @ad_paxname, @ad_paxape, @ad_paxprefix, @ad_voucher, @ad_ident;
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @SrvPaxSqlStmt = @SrvPaxSqlStmt + CHAR(13) + CHAR(10) + 
								' EXECUTE dbo.spza_ServicioPaxAdicional_insertar @FacId = @NewFacId, @RemId = @NewRemId, @id_Fac_Servicios = @NewSrvId, @ds_paxname = ''' + 
								REPLACE(@ad_paxname, '''', '''''') + ''', @ds_paxape = ''' + REPLACE(@ad_paxape, '''', '''''') + 
								''', @in_edad = NULL, @ds_paxprefix= ''' + @ad_paxprefix + ''', @ds_paxClasificacion = NULL, @cd_voucherpax=NULL, @cd_tiquete=NULL;';
							FETCH NEXT FROM curExtraPax INTO @ad_paxname, @ad_paxape, @ad_paxprefix, @ad_voucher, @ad_ident;
						END;
						CLOSE curExtraPax;
						DEALLOCATE curExtraPax;

						-- Validar inconsistencia de rango de fechas (Fecha Final / Check-Out anterior a Fecha Inicial / Check-In)
						DECLARE @val_f_salida SMALLDATETIME = ISNULL(@gen_dt_salida, @gen_Fecha_Salida);
						DECLARE @val_f_llegada SMALLDATETIME = ISNULL(@gen_dt_llegada, @gen_Fecha_Llegada);

						IF @val_f_salida IS NOT NULL AND @val_f_llegada IS NOT NULL AND @val_f_salida < @val_f_llegada
						BEGIN
							DECLARE @err_date_msg NVARCHAR(4000) = '❌ Factura ' + ISNULL(@cd_consecutivo, '') + ': Inconsistencia de fechas en el producto "' + ISNULL(@gen_ds_descrip, 'Ítem') + '". La Fecha Final / Check-Out (' + CONVERT(VARCHAR, @val_f_salida, 111) + ') no puede ser anterior a la Fecha Inicial / Check-In (' + CONVERT(VARCHAR, @val_f_llegada, 111) + '). Por favor edite la factura y corrija las fechas.';
							RAISERROR(@err_date_msg, 16, 1);
							RETURN;
						END;

						-- Calcular noches y dias
						DECLARE @calc_noches INT = DATEDIFF(day, @val_f_llegada, @val_f_salida);
						IF @calc_noches IS NULL OR @calc_noches <= 0 SET @calc_noches = 1;
						DECLARE @calc_dias INT = @calc_noches;

						SET @SrvSqlStmt = @SrvVarsSqlStmt + @SrvCargSqlStmt + @SrvFpSqlStmt + @SrvProvSqlStmt;
						
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
							@dt_llegada = ' + ISNULL('''' + CONVERT(VARCHAR, ISNULL(@gen_dt_llegada, @gen_Fecha_Llegada), 120) + '''', 'NULL') + ',
							@dt_salida = ' + ISNULL('''' + CONVERT(VARCHAR, ISNULL(@gen_dt_salida, @gen_Fecha_Salida), 120) + '''', 'NULL') + ',
							@ds_destino = ''' + ISNULL(@gen_cd_destino, '') + ''',
							@id_gds = '+ CAST(ISNULL(@gen_id_gds,1) AS VARCHAR) + ',
							@am_basecomisionable = ' + CAST(ISNULL(@gen_am_basecomisionable,0) AS VARCHAR) + ',
							@am_porcomision = 0,
							@id_tipoplan = NULL,
							@id_acomodacion = NULL,
							@ds_paxClasificacion = NULL,
							@in_dias = ' + CAST(@calc_dias AS VARCHAR) + ',
							@in_noches = ' + CAST(@calc_noches AS VARCHAR) + ',
							@bl_notdomicilionacional=0,
							@CodigoReserva =''' + ISNULL(@gen_ds_records,'') + ''',
							@AnticiposSqlStmt = NULL,
							@PaxAdicionalSqlStmt = ''' + REPLACE(ISNULL(@SrvPaxSqlStmt,''), '''', '''''') + ''', 
							@VoucherAdicionalSqlStmt = NULL,
							@id_monedas_iata = @id_monedas_iata,
							@Tcambio = @Tcambio,
							@Id_GrConcepto = NULL,
							@in_diasSrv = ' + CAST(@calc_dias AS VARCHAR) + ',
							@in_nochesSrv = ' + CAST(@calc_noches AS VARCHAR) + ',
							@OrdenGrabacion = ' + CAST(@ItemIndex AS VARCHAR) + ',
							@Id_Especialista = NULL,
							@am_porcentaje_descuento = ' + CAST(ISNULL(@gen_am_pordescuento, 0) AS VARCHAR) + ',
							@am_valor_descuento = 0,
							@ds_motivo_descuento = NULL,
							@Id_CargosDesc_Descuento = NULL,
							@dt_FechaSalidaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, ISNULL(@gen_Fecha_Salida, @gen_dt_salida), 120) + '''', 'NULL') + ',
							@dt_FechaLlegadaSrv = ' + ISNULL('''' + CONVERT(VARCHAR, ISNULL(@gen_Fecha_Llegada, @gen_dt_llegada), 120) + '''', 'NULL') + ',
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
					
					-- 1. Variables explícitas desde el XML
					SELECT 
						@ZML_VariablesStr = COALESCE(@ZML_VariablesStr + ' UNION ALL ', '') + 
						'SELECT ' + ISNULL('''' + REPLACE(cd_codigo, '''', '''''') + '''', 'NULL') + ' AS cd_items, NULL AS ds_Items, ' + 
						ISNULL('''' + REPLACE(ds_maestro, '''', '''''') + '''', 'NULL') + ' AS ds_Maestro, ' + 
						ISNULL('''' + REPLACE(ds_VariableAdicional, '''', '''''') + '''', 'NULL') + ' AS ds_Variable, ' + 
						ISNULL('''' + REPLACE(ds_valor, '''', '''''') + '''', 'NULL') + ' AS ds_Valor, ' +
						ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ' AS id_Clientes'
					FROM #VariablesAdicionales
					WHERE id_facturacion = @id_facturacion;

					-- 2. Variables exigidas por el cliente en Zeus ERP para Servicios (IDEN_Maestro = 37 / FacturacionServicios)
					SELECT 
						@ZML_VariablesStr = COALESCE(@ZML_VariablesStr + ' UNION ALL ', '') + 
						'SELECT ' + ISNULL('''' + REPLACE(FI.cd_Consecutivo_variablesadicionales, '''', '''''') + '''', 'NULL') + ' AS cd_items, NULL AS ds_Items, ''FacturacionServicios'' AS ds_Maestro, ' + 
						ISNULL('''' + REPLACE(VD.Nombre, '''', '''''') + '''', 'NULL') + ' AS ds_Variable, ' + 
						'ISNULL(NULLIF(''' + REPLACE(ISNULL(VD.DefaultVarchar, 'N/A'), '''', '''''') + ''', ''''), ''N/A'') AS ds_Valor, ' +
						ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ' AS id_Clientes'
					FROM #TmpFacturaItems FI
					CROSS JOIN dbo.Cliente_ConfiguracionVariables CCV
					JOIN dbo.VariableDefinicion VD ON VD.IDEN = CCV.Iden_Variable
					WHERE FI.id_factura = @id_facturacion 
					  AND FI.tipo_item IN ('SRV', 'Hotel', 'Auto')
					  AND CCV.IDEN_Maestro = 37
					  AND RTRIM(LTRIM(CCV.id_cliente)) = RTRIM(LTRIM(@cd_cliente))
					  AND CCV.bl_Exige = 1
					  AND NOT EXISTS (
						  SELECT 1 FROM #VariablesAdicionales VA 
						  WHERE VA.id_facturacion = @id_facturacion 
						    AND VA.cd_codigo = FI.cd_Consecutivo_variablesadicionales
						    AND VA.ds_VariableAdicional = VD.Nombre
					  );

					-- 3. Variables exigidas por el cliente en Zeus ERP para Tiquetes (IDEN_Maestro = 35 / FacturacionTiquetes)
					SELECT 
						@ZML_VariablesStr = COALESCE(@ZML_VariablesStr + ' UNION ALL ', '') + 
						'SELECT ' + ISNULL('''' + REPLACE(FI.cd_tiquete, '''', '''''') + '''', 'NULL') + ' AS cd_items, NULL AS ds_Items, ''FacturacionTiquetes'' AS ds_Maestro, ' + 
						ISNULL('''' + REPLACE(VD.Nombre, '''', '''''') + '''', 'NULL') + ' AS ds_Variable, ' + 
						'ISNULL(NULLIF(''' + REPLACE(ISNULL(VD.DefaultVarchar, 'N/A'), '''', '''''') + ''', ''''), ''N/A'') AS ds_Valor, ' +
						ISNULL('''' + REPLACE(@cd_cliente, '''', '''''') + '''', 'NULL') + ' AS id_Clientes'
					FROM #TmpFacturaItems FI
					CROSS JOIN dbo.Cliente_ConfiguracionVariables CCV
					JOIN dbo.VariableDefinicion VD ON VD.IDEN = CCV.Iden_Variable
					WHERE FI.id_factura = @id_facturacion 
					  AND FI.tipo_item IN ('Aire')
					  AND CCV.IDEN_Maestro = 35
					  AND RTRIM(LTRIM(CCV.id_cliente)) = RTRIM(LTRIM(@cd_cliente))
					  AND CCV.bl_Exige = 1
					  AND NOT EXISTS (
						  SELECT 1 FROM #VariablesAdicionales VA 
						  WHERE VA.id_facturacion = @id_facturacion 
						    AND VA.cd_codigo = FI.cd_tiquete
						    AND VA.ds_VariableAdicional = VD.Nombre
					  );

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

						-- Consultar el último registro recién creado en Zeus ERP fac_factura
						DECLARE @resFuente VARCHAR(10) = NULL;
						DECLARE @resSerie VARCHAR(10) = NULL;
						DECLARE @resConsecutivo VARCHAR(20) = NULL;

						IF @cd_cliente IS NOT NULL AND TRIM(@cd_cliente) <> ''
						BEGIN
							SELECT TOP 1 
								@resFuente = LTRIM(RTRIM(cd_fuente)),
								@resSerie = LTRIM(RTRIM(cd_serie)),
								@resConsecutivo = LTRIM(RTRIM(cd_consecutivo))
							FROM ZeusAgencias_23.dbo.fac_factura WITH (NOLOCK)
							WHERE cd_tercero_codigo = LTRIM(RTRIM(@cd_cliente))
							ORDER BY id DESC;
						END

						IF @resConsecutivo IS NULL
						BEGIN
							SELECT TOP 1 
								@resFuente = LTRIM(RTRIM(cd_fuente)),
								@resSerie = LTRIM(RTRIM(cd_serie)),
								@resConsecutivo = LTRIM(RTRIM(cd_consecutivo))
							FROM ZeusAgencias_23.dbo.fac_factura WITH (NOLOCK)
							ORDER BY id DESC;
						END

						IF @resFuente IS NULL SET @resFuente = ISNULL(NULLIF(LTRIM(RTRIM(@cd_fuente)), ''), '55');
						IF @resSerie IS NULL SET @resSerie = ISNULL(NULLIF(LTRIM(RTRIM(@cd_serie)), ''), '33');
						
						-- Actualizar registro local de Invoices si la tabla existe en la BD activa (Korex local)
						DECLARE @numInterno VARCHAR(50) = NULL;
						IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
						BEGIN
							UPDATE dbo.[Invoices]
							SET 
								fuente = @resFuente,
								serie = @resSerie,
								consecutivo = @resConsecutivo,
								state = 'EXPORTED'
							WHERE id = @id_facturacion;

							SELECT TOP 1 @numInterno = ISNULL(internalNumber, CAST(id AS VARCHAR)) FROM dbo.[Invoices] WHERE id = @id_facturacion;
						END;

						SET @FacturaRespuesta = '✅ Factura ' + ISNULL(@numInterno, CAST(@id_facturacion AS VARCHAR)) + ' (Zeus ERP N° ' + ISNULL(@resFuente, '') + '-' + ISNULL(@resSerie, '') + '-' + ISNULL(@resConsecutivo, '') + '): Exportada e inyectada correctamente a Zeus ERP.';
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

				FETCH NEXT FROM curInvoices INTO @id_facturacion, @cd_fuente, @cd_serie, @cd_consecutivo;
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


-- ==========================================
-- Procedimiento Zeus ERP: spza_Factura_Contabilizar.sql
-- ==========================================

CREATE OR ALTER PROCEDURE [dbo].[spza_Factura_Contabilizar] 
	-- Parametros del procedimiento
	@id_usuario 			INT,
	@id_factura 			INT,
	@bl_ContAuto 			BIT = 0,
	@CodigoArchivoFisico 	VARCHAR(25) = NULL,
	@bl_mostrarmsg BIT = 0 --rgelis 2018/12/11 req.74447
 
AS

Begin
	SET NOCOUNT On;
	  set xact_abort On 
    --region: Declaracion e inicializacion de variables
  	Declare @bl_permit			 BIT 	, -- Permiso de ejecucion del proceso
  			@bl_as 	   			 BIT	, -- Auditar exito
	 		@bl_af 			     BIT	, -- Auditar fallido	 		
			@procmsg	VARCHAR(8000)	, -- Mensaje devuelto por procedimientos llamados desde este procedimiento
			@procret 	BIT 			, -- Valor de retorno de los procedimientos llamados desde este procedimiento
			@idproce	int		    	, -- Codigo de proceso
	 		@retry 		BIT			    , -- 1=Reintentar ; 0=Abortar  
	 		@retrycont	INT			    , -- Contador de reintentos
	 		@maxretries INT			    , -- Maximo numero de reintentos
	 		@timeout	NVARCHAR(4000)  , -- Tiempo de espera maximo por bloqueo de registros
	 		@stmt 		NVARCHAR(4000)  , -- Cadena de instrucciones T-SQL
			@tc			INT 			, -- Numero de transacciones abiertas
			@msg	    VARCHAR(8000)   , -- Mensaje retornado por el sistema
			@retval		TINYINT 		, -- Valor de retorno de este procedimiento: 0:Exito ; 1:Error(Bloque Catch)
			@totalant	MONEY 			 -- Total de anticipos aplicados
   			;	
	
	Select 	@idproce 			 = 136,
			@retry				 = 1 		   ,
			@retrycont			 = 0		   ,
			@tc 			 	 = @@TRANCOUNT ,
			@retval				 = 1;
  	--Endregion	
			
  	--region: Manejo de tiempo de espera y de reintentos por bloqueo de tablas/registros  
   	Select @maxretries = convert(INT,Valor) From dbo.Parametros Where Id = 60 ;
	Select @timeout    = convert(NVARCHAR(4000),Valor) From dbo.Parametros Where Id = 50 ;		
	SET @stmt = N'SET LOCK_TIMEOUT '+ltrim(rtrim(@timeout))
	EXEC sp_executesql @stmt,N''
	--Endregion
	
	WHILE ( (@retry = 1) AND (@retrycont <= @maxretries) )
	Begin
		SET @retry = 0;
    
    	--region: Bloque TRY
    	Begin TRY 
    	    --Si es una factura generada a partir de remision se debe contabilizar usando
    	    --el sp de contabilizacion de facturas generadas a partir de remisiones
    	    If EXISTS
	    	    	(Select * From dbo.fac_remision Where id_fac_factura = @id_factura 
	    	    		AND cd_fuente_anul 		IS  NULL
		    	    	AND cd_serie_anul 		IS  NULL
	    		    	AND cd_consecutivo_anul IS  NULL
	    	    	)
    	    Begin 	    		
    	    	
	    	    EXECUTE @retval=dbo.spza_Remision_ConvertirFactura_Contabilizar 
	    	    	 @id_usuario=@id_usuario 
					,@id_factura=@id_factura 
					,@idremisiones=''
					,@CodigoArchivoFisico=@CodigoArchivoFisico 
					,@rpta=@msg OUTPUT 	;
				Select @msg AS 'Respuesta', 1 AS 'Estado' /*rgelis 2014/04/30 req.19917*/	
				RETURN @retval;
			End 					
    	    
    	        	    
    		--ObteniEndo informacion de seguridad y auditoria--
			EXEC dbo.spzaProcesoUsuario_Consultar @id_usuario   = @id_usuario       ,
							 @id_proceso   = @idproce 		    , 
												  @bl_permit    = @bl_permit OUTPUT , 
												  @bl_auditsuc  = @bl_as 	 OUTPUT , 
												  @bl_auditfail = @bl_af 	 OUTPUT ;
			If (@bl_permit = 0)
			Begin 
				Select 'No posee permisos suficientes para ejecutar esta acción.' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;		
				RETURN @retval;
			End 
			


						--Instrucciones del procedimiento-----------------------------------------
			Declare @fuente CHAR(2), 
					@numdoctra CHAR(10),
					@factotal MONEY,
					@errorcont INT,
					@anomes CHAR(6),
					@fechadoc CHAR(10),
					@descridoc VARCHAR(120),
					@Bu VARCHAR(25),
					@idvEnde CHAR(3),
					@idtercero VARCHAR(25),
					@idcliente VARCHAR(25), --rgelis 2017/02/23 req.47387
					@vencefac CHAR(10),
					@ctacartera VARCHAR(16),
					@ctacartera_Cli VARCHAR(16),
					@Manejactacartera_Suc CHAR(1),
					@ctacartera_Suc VARCHAR(16),
					@Manejactacartera_Imp CHAR(1),
					@ctacartera_Imp VARCHAR(16),
					@ctacartera_Tv VARCHAR(16),/*rgelis 2014/06/06 req,20533*/
					@cliente VARCHAR(250),
					@Numdoc CHAR(13),
					@CxC_Val MONEY,					
					@moneda CHAR(3),
					@tcambio SMALLMONEY,
					@CxP_Nac VARCHAR(16),
					@CxP_Int VARCHAR(16),
					@BU_Anticipo VARCHAR(25),  
					@ManejarCtaAlternaTAO BIT, 
					@CtaAlternaTAONac VARCHAR(16), 
					@CtaAlternaTAOInter VARCHAR(16),
					@CtaCajaRcAuto VARCHAR(16),
					@IdBancoRcAuto CHAR(3),
					@IdPlazaRcAuto CHAR(3),
					@Cd_serieRcAuto CHAR(2),
					@CtaCajaRcOtrAuto VARCHAR(16),
					@IdBancoRcOtrAuto CHAR(3),
					@IdPlazaRcOtrAuto CHAR(3),
					@Cd_serieRcOtrAuto CHAR(2),
					@bl_RcAuto BIT,
					@bl_RcSoloTkt BIT,
					@bl_RcFac BIT,
					@bl_RcTktOtr BIT,
					@bl_ExistTksTCFac BIT,
					@id_sucursal INT, 
					@id_implante INT,
					@TotalFacTktTC AS MONEY,
					@TotalFacTC AS MONEY,
					@LongitudRefe INT,
					@bl_ReferenciaCxPProveSrv CHAR(1),
					@bl_ReferenciaCxCProveSrv CHAR(1), 
					@Id_Cierre INT,
					@CodIVAFacNuevaComCierre VARCHAR(3),
					@CodComisionFacNuevaComCierre VARCHAR(3),
					@NCF varchar(25),
					@TipoDocumento Varchar(2),
					@cd_cencoSucursal CHAR(16), /*rgelis 2012/09/04 req.10397*/
					@cd_cencoImplante CHAR(16), /*jramirez 2015/10/23*/
					@bl_manejarcencostoImplante INT,
					@cd_cencoSucursalTaoNac CHAR(16), /*rgelis 2014/10/22 req.22121*/
					@cd_cencoSucursalTaoInt CHAR(16), /*rgelis 2014/10/22 req.22121*/
					@bl_nocont BIT, --rgelis 2018/04/30 req.33683
					@LlevarCliTerContabil Varchar(1),
					@cd_cuenta_IVAPenalidad VARCHAR(16),
					@cd_cuenta_IVAPenalidadSUC VARCHAR(16),
					@cd_cuenta_IVAPenalidadIMP VARCHAR(16),
					@bl_cuenta_IVAPenalidad VARCHAR(1),
					@cd_impuestotaonac CHAR(3), /*inicio rgelis 2014/10/22 req.22121*/
					@cd_impuestotaoint CHAR(3), 
					@id_impuestotaonac INT, 
					@id_impuestotaoint INT, /*fin rgelis 2014/10/22 req.22121*/
					@bl_interface INT,
					@Decimales INT,
					@bl_ContabilizarNitProv BIT, /*rgelis 2016/12/09 req.34960*/
					--Inicio Jramirez 2016/10/11 R3244
					@SaldoFactura Money, 
					@bl_refacturacion  INT, 
					@bl_refacturacion_contabilizar_saldos INT,
					@fuente_refacturacion varchar(2), 
					@numdoctra_refacturacion varchar(10),
					@bl_LlevarSrvTercero INT, 
					@cd_proveedorTAO Varchar(25),
					--Fin Jramirez 2016/10/11 R3244
					@bl_QuitarCerosIzquierda BIT,
					@bl_QuitarSerieDocumento BIT,
					@bl_AgregarPrefijoResolucion BIT,
					@cd_prefijo varchar(25),
					@numefac varchar(25)
			--Variables de Resoluciones
			Declare 
				@procmsgRC varchar(8000)
				,@ResolucionmsgRC varchar(8000)
			--Variables RC automatico
			Declare @cd_fuenteRC CHAR(2)
				,@cd_serieRC CHAR(2)
				,@cd_consecutivoRC varCHAR(8)
				,@cd_fuenteRCOtr CHAR(2)
				,@cd_fuenteRC_F CHAR(2)
				,@TotalRc MONEY
				,@id_FpRc INT
				,@id_FpRcAux INT
				,@bl_GenerarSoloUnRCPorFP BIT;	/*rgelis 2016/07/15 req.32431*/			
				
			--Tipo de documento de la factura
			Select @TipoDocumento = rtrim(Valor) From dbo.parametros Where Id = 237
			--Llevar al Cliente y Tercero de la Factura la contabilización de cargos de servicios con cuentas parametrizadas
			Select @LlevarCliTerContabil = rtrim(Valor) From dbo.parametros Where Id = 332

			--Otra cuanta para el iva de las penalidades
			Select @cd_cuenta_IVAPenalidad = rtrim(Valor) From dbo.parametros Where Id = 349
			Select @bl_cuenta_IVAPenalidad = rtrim(Valor) From dbo.parametros Where Id = 350  
			
			Select @cd_impuestotaonac = rtrim(Valor) From dbo.parametros Where Id = 330	/*inicio rgelis 2014/10/22 req.22121*/
			Select @cd_impuestotaoint = rtrim(Valor) From dbo.parametros Where Id = 331 
			select @id_impuestotaonac=id from ImpRet where cd_codigo =@cd_impuestotaonac
			select @id_impuestotaoint=id from ImpRet where cd_codigo =@cd_impuestotaoint /*fin rgelis 2014/10/22 req.22121*/	
			
			Set @bl_manejarcencostoImplante = 0
			SELECT @bl_manejarcencostoImplante = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 137
			--Decimales
			SELECT @Decimales = Valor FROM Parametros WHERE id=33

			Set @bl_QuitarCerosIzquierda = 0
			Set @bl_QuitarSerieDocumento = 0
			Set @bl_AgregarPrefijoResolucion = 0
			SELECT @bl_QuitarCerosIzquierda = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 588
			SELECT @bl_QuitarSerieDocumento = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 589
			SELECT @bl_AgregarPrefijoResolucion = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 590

			SELECT @bl_ContabilizarNitProv = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 478 /*rgelis 2016/12/09 req.34960*/
 			Select 	@fuente    = f.cd_fuente,
					@numdoctra = f.cd_serie+f.cd_consecutivo,
					@factotal  = dbo.fnza_Get_FacturaTotal(@id_factura),
					@anomes = dbo.fnza_Get_ANODCTO(f.dt_fechacont),
					@fechadoc = dbo.fnza_Get_FECHDCTO(f.dt_fechacont),
					@Numdoc = @FUENTE+'-'+@NUMDOCTRA,
					@descridoc = CASE WHEN ISNULL(f.cd_TipoFact,'')<>'' THEN f.cd_TipoFact
								      ELSE @TipoDocumento END + ' '+@Numdoc+'. '+RTRIM(f.ds_tercero_nombre),
					@Bu = isnull(i.cd_bu,isnull(s.cd_bu,'')),
					@idtercero = f.cd_tercero_codigo,
					@idcliente = f.cd_cliente_codigo,
					@idvEnde = f.cd_vEndedor,
					@vencefac = dbo.fnza_Get_FECHDCTO(f.dt_vence),
					@ctacartera_Cli = isnull(c.CODICTA,''),
					@ctacartera_Suc = isnull(s.cd_cuenta_cartera,''),
					@ctacartera_Imp = isnull(i.cd_cuenta_cartera,''),
					@cliente = rtrim(f.ds_cliente_nombre),
					@moneda = m.cd_codigo,
					@tcambio = CASE WHEN f.bl_generadaauto = 0 AND f.am_tcambio > 1 THEN f.am_tcambio ELSE m.am_tasa_cambio END, /*rgelis 2015/11/26 Orden.421302*/
					@id_sucursal = s.id,
					@id_implante = i.id,
					@CtaCajaRcAuto = cd_CuentaCaja,
					@IdBancoRcAuto = cd_banco,
					@IdPlazaRcAuto = cd_plaza,
					@Cd_serieRcAuto = Cd_serieRC,
					@CtaCajaRcOtrAuto = cd_CuentaCajaOtr,
					@IdBancoRcOtrAuto = cd_bancoOtr,
					@IdPlazaRcOtrAuto = cd_plazaOtr,
					@Cd_serieRcOtrAuto = Cd_serieRCOtr,
					--@bl_RcAuto = bl_RcAuto, /* inicio rgelis 2012/10/11 req.10702*/
					--@bl_RcSoloTkt = bl_RcSoloTkt,
					--@bl_RcFac = bl_RcFac,
					--@bl_RcTktOtr = bl_RcTktOtr,
					@bl_RcAuto = ISNULL(CRC.bl_GenerarRC_Auto,0),
					@bl_RcSoloTkt = ISNULL(CRC.bl_GenerarRCSoloTkt,0),
					@bl_RcFac = ISNULL(bl_GenerarRCSoloFac,0),
					@bl_RcTktOtr = ISNULL(bl_GenerarRCIndependiente,0), /* fin rgelis 2012/10/11 req.10702*/
					@Id_Cierre = Id_Cierre,
					@NCF = f.NCF,
					@cd_cencoSucursal = CASE WHEN ISNULL(Tq.bl_cencosto,0)=1 AND ISNULL(Tq.cd_cencosto,'')<>'' THEN ISNULL(Tq.cd_cencosto,'') ELSE ISNULL(s.cd_cencosto,'') END, --rgelis 2017/09/14 req.52526 
					@cd_cencoImplante = CASE WHEN ISNULL(Tq.bl_cencosto,0)=1 AND ISNULL(Tq.cd_cencosto,'')<>'' THEN ISNULL(Tq.cd_cencosto,'') ELSE ISNULL(I.cd_cencosto,'') END, --rgelis 2017/09/14 req.52526
					@TipoDocumento = CASE WHEN ISNULL(f.cd_TipoFact,'')<>'' THEN f.cd_TipoFact
										ELSE @TipoDocumento
									END,	/*rgelis 2012/10/31 req.10779*/
					@bl_nocont = f.bl_nocont, --rgelis 2018/02/16 req.33683*/
					@cd_cuenta_IVAPenalidadSUC = ISNULL(s.cd_cuenta_IVAPenalidad,''),
					@cd_cuenta_IVAPenalidadIMP = ISNULL(i.cd_cuenta_IVAPenalidad,''),
					@cd_cencoSucursalTaoNac = ISNULL(tao.cd_cencosto,''), /*inicio rgelis 2014/10/22 req.22121*/
					@cd_cencoSucursalTaoInt = ISNULL(tao.cd_cencostoInternacional,''), 
					@id_impuestotaonac = ISNULL(tao.id_ImpRetIva,@id_impuestotaonac),
					@id_impuestotaoint = ISNULL(tao.id_ImpRetIvaInter,@id_impuestotaoint), /*fin rgelis 2014/10/22 req.22121*/	
					@bl_interface = bl_interface,
					@bl_refacturacion  = bl_refacturacion,
					@bl_refacturacion_contabilizar_saldos = bl_refacturacion_contabilizar_saldos,
					@bl_LlevarSrvTercero = tao.bl_LlevarSrvTercero,
					@cd_proveedorTAO = tao.cd_proveedor,
					@cd_prefijo = ISNULL(r.cd_prefijo,''),
					@numefac = CASE WHEN @bl_AgregarPrefijoResolucion = 1 THEN ISNULL(r.cd_prefijo,'') ELSE '' END + CASE WHEN @bl_QuitarSerieDocumento = 0 THEN CASE WHEN @bl_QuitarCerosIzquierda = 1 THEN CONVERT(VARCHAR(8),CONVERT(NUMERIC(18,0),f.cd_serie)) ELSE f.cd_serie END ELSE '' END + CASE WHEN @bl_QuitarCerosIzquierda = 1 THEN CONVERT(VARCHAR(8),CONVERT(NUMERIC(18,0),f.cd_consecutivo)) ELSE f.cd_consecutivo END

				From dbo.fac_factura f 
					INNER JOIN dbo.CLIENTES c On (f.cd_cliente_codigo=c.IDCLIENTE)
					INNER JOIN dbo.Sucursales s On (f.id_sucursal = s.id)
					INNER JOIN dbo.Monedas_IATA m On (f.id_monedas_IATA = m.id)
					LEFT JOIN dbo.Implantes I On (f.id_implante = I.id)
					LEFT JOIN dbo.ConfiguracioRecibosCaja As CRC ON CRC.id_Sucursal=f.id_sucursal And ISNULL(CRC.id_implante,0) = ISNULL(f.id_implante,0) /* rgelis 2012/10/11 req.10702*/
					LEFT JOIN dbo.TarifaAdministrativa tao ON tao.id_Sucursal=f.id_sucursal And ISNULL(tao.id_implante,0) = ISNULL(f.id_implante,0) /* rgelis 2014/10/22 req.22121*/
					LEFT JOIN dbo.Tiqueteadores Tq ON Tq.id=f.id_tiqueteador  --rgelis 2017/09/14 req.52526
					LEFT JOIN dbo.resoluciones r ON r.ds_num_resolucion = f.ds_num_resolucion
				Where f.id = @id_factura;
				
				/*inicio rgelis 2013/09/09 req.16665*/
				--Total Comisiones
				DECLARE @result AS MONEY
				SET @result=0
				--Total de impuestos de servicios
				SELECT @result=@result+sum(isnull(fsi.am_valor,0))
				FROM dbo.fac_factura f 
					LEFT JOIN dbo.fac_servicios fs ON (fs.id_fac_factura =f.id)
					INNER JOIN dbo.Fac_ServiciosCargos  fsc ON (fs.id = fsc.id_Fac_Servicios )
					LEFT JOIN dbo.Fac_ServiciosImpuestos  fsi ON (fsi.id_FacServiciosCargos = fsc.id)
					INNER JOIN dbo.ConceptoFacturacion cf ON (cf.id = fs.id_ConceptoFacturacion)
				WHERE f.id = @id_factura AND fs.bl_anulado = 0 AND fs.id_TiposConceptFac=4 AND cf.bl_llevarAlGasto = 1
				GROUP BY f.id;
				
				--Total de cargos de servicios
				SELECT @result=@result+sum(isnull(fsc.am_valor,0))
				FROM dbo.fac_factura f 
					LEFT JOIN dbo.fac_servicios fs ON (fs.id_fac_factura =f.id)
					INNER JOIN dbo.Fac_ServiciosCargos  fsc ON (fs.id = fsc.id_Fac_Servicios )
					INNER JOIN dbo.ConceptoFacturacion cf ON (cf.id = fs.id_ConceptoFacturacion) 
				WHERE f.id = @id_factura AND fs.bl_anulado = 0 AND fs.id_TiposConceptFac=4 AND cf.bl_llevarAlGasto = 1
				GROUP BY f.id;	
				
				SET @factotal = @factotal - @result*2 				
				/*fin rgelis 2013/09/09 req.16665*/

			/*inicio rgelis 2012/10/31 req.10779*/
			If isnull(@TipoDocumento,'') = ''
			Begin 
				Select 'Debe ingresar un tipo de documento para las Facturas. Verifique los parametros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End 
			IF Not Exists (Select * From dbo.TIPOFACT Where Tipofact = @TipoDocumento)
			Begin 
				Select 'Debe ingresar un tipo de documento valido para las Facturas. Verifique los parametros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End				
			/*fin rgelis 2012/10/31 req.10779*/
			
			If EXISTS(Select ANODCTO From dbo.DOCUMENT Where FNTEDCTO = @fuente AND NUMEDCTO = @numdoctra AND SUDBDCTO<>0 AND SUCRDCTO<>0 AND NUMTDCTO<>0)
			Begin 
				Select 'La factura ya se encuentra contabilizada' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End

			/*inicio rgelis 2014/08/13 req.21488*/
			IF EXISTS(Select * From dbo.Fac_Servicios fs					
					    INNER JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
						Where fs.id_fac_factura = @id_factura
						  AND p.Deshabilitado = 1 
						)
			BEGIN
				Select TOP(1) 'El proveedor '+p.IDPROVE +' del servicio '+ fs.ds_servicio + ' esta desabilitado. Verifique en el maestro proveedores' AS 'Respuesta', 1 AS 'Estado'
				FROM dbo.Fac_Servicios fs
				INNER JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
				WHERE fs.id_fac_factura = @id_factura
				AND p.Deshabilitado = 1
				SET	@retval = 1;
				RETURN @retval;
			END 
			/*fin rgelis 2014/08/13 req.21488*/

			If EXISTS(SELECT * From dbo.tiquetes t 
						INNER JOIN dbo.tiquetecargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
						LEFT  JOIN dbo.TiqueteImpuestos ti On (ti.id_TiqueteCargos  = tc.id)
						INNER JOIN dbo.ImpRet ir On (ir.id = ti.id_ImpRet)
						LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id) 
					Where t.id_fac_factura = @id_factura 
						  AND @bl_cuenta_IVAPenalidad = 'S'
						  AND ISNULL(t.cd_Penalidad,'') <> ''
						  AND ti.id_ImpRet IN(1,2,3,4,12)
						  AND @cd_cuenta_IVAPenalidad=''
						  AND @cd_cuenta_IVAPenalidadSUC=''
						  AND @cd_cuenta_IVAPenalidadIMP=''
				)
			Begin 
				Select 'Esta activo el parámetro "Utilizar Otra Cuenta para el IVA de la Penalidad" '+CHAR(13)+CHAR(10)+'y no asigno ninguna Cuenta. Verifique los parámetros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End

			/*inicio rgelis 2012/10/01 req.10699*/ 
			select @ctacartera = ISNULL(CCC.cd_Cuenta,'')
			From dbo.fac_factura As f
				INNER JOIN dbo.Configuracion_remisiones As CR ON CR.Id_Cliente=f.cd_cliente_codigo
				INNER JOIN dbo.Clientes_CuentasCartera As CCC ON CCC.Id_Configuracion_remisiones=CR.Id 
			Where f.id = @id_factura
				And CCC.id_Moneda=f.id_monedas_IATA 
				And CCC.id_Sucursal=f.id_sucursal 
				And ISNULL(CCC.id_Implante,0) = ISNULL(f.id_implante,0)
				And CR.bl_utilizarCuentasCartera = 1;
			/*fin rgelis 2012/10/01 req.10699*/

			/*inicio rgelis 2013/03/07 req.10699*/	
			If(@ctacartera IS NULL OR rtrim(ltrim(@ctacartera)) = '')
			BEGIN
				select @ctacartera = ISNULL(CCC.cd_Cuenta,'')
				From dbo.fac_factura As f
					INNER JOIN dbo.Sucursales As S ON S.Id=f.id_Sucursal
					LEFT JOIN dbo.Implantes As I ON I.id=f.id_Implante 
					INNER JOIN dbo.Clientes_CuentasCartera As CCC ON CCC.Id_Sucursal=f.id_Sucursal And ISNULL(CCC.Id_Implante,0)=ISNULL(f.id_implante,0)
					left join configuracion_remisiones cr on cr.id = ccc.Id_Configuracion_remisiones
				Where f.id = @id_factura
					And CCC.id_Moneda=f.id_monedas_IATA
					And (CCC.Id_Configuracion_remisiones is null  OR (ccc.Id_Configuracion_remisiones is not null and cr.id_cliente = f.cd_cliente_codigo))
					And ((S.bl_UtilizarCxCMoneda=1 AND I.id IS NULL) OR ISNULL(I.bl_UtilizarCxCMoneda,0)=1);
			END	
			/*fin rgelis 2013/03/07 req.10699*/
			
			--Si el cliente no tiene cuenta de cartera asignada entonces se usa la cuenta de cartera por defecto
			--SET @ctacartera = '' /*rgelis 2012/10/01 req.10699 se comenta para que no asigne vacio*/
			Select @Manejactacartera_Suc = rtrim(ltrim(valor)) From Parametros Where Id = 132
			Select @Manejactacartera_Imp = rtrim(ltrim(valor)) From Parametros Where Id = 135
			If @Manejactacartera_Imp = 'S'  AND (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL) /*rgelis 2012/10/01 req.10699 se agrega para verifique que este vacia la cuenta de cartera*/ 
				SET @ctacartera = @ctacartera_Imp
				
			If @Manejactacartera_Suc = 'S'  AND (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL)
				SET @ctacartera = @ctacartera_Suc
			
			If (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL)
				SET @ctacartera = @ctacartera_Cli
					
			If rtrim(ltrim(@ctacartera))='' or @ctacartera is null 
			Begin 
				Select @ctacartera=rtrim(ltrim(valopar)) From dbo.Parametr Where PARAMETRO = 'CxCCli'
			End 

			/*inicio rgelis 2014/06/06 req,20533*/
			IF Exists(SELECT * FROM Parametros WHERE Id=334 AND LTRIM(Valor)='S')
			BEGIN
				SELECT @ctacartera_Tv=ISNULL(tv.cd_cuenta_cartera,'')  
				FROM dbo.fac_factura f 
				INNER JOIN dbo.TipoVenta tv ON tv.id = f.id_tipoventa
				WHERE f.id = @id_factura
				
				If IsNull(@ctacartera_Tv,'')<>''
					SET @ctacartera = @ctacartera_Tv
				  
			END
			/*fin rgelis 2014/06/06 req,20533*/	 
			
			--ObteniEndo CxP Nacional e Internacional por defecto para aerolineas
			Select @CxP_Nac = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 13;
			Select @CxP_Int = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 14; 
			
			--ObteniEndo la Cuenta Alterna para la TAO cuando tiene retencion (FELIX)
			Select @ManejarCtaAlternaTAO = bl_CuentaAlternaTAO From Configuracion_remisiones Where id_cliente =  @idcliente	   

			If @ManejarCtaAlternaTAO = 1
			Begin
				Select @CtaAlternaTAONac = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 201;
				Select @CtaAlternaTAOInter = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 205;
				/*inicio rgelis 2014/10/22 req.22121*/
				SELECT @CtaAlternaTAONac = cd_CuentaAlternaNac
					  ,@CtaAlternaTAOInter = cd_CuentaAlternaInter
				FROM dbo.fac_factura ff 
				INNER JOIN dbo.TarifaAdministrativa tao ON (ISNULL(tao.id_Sucursal,0) = ISNULL(ff.id_sucursal,0) 
															AND ISNULL(tao.id_Implante,0) = ISNULL(ff.id_implante,0)) 
				WHERE ff.id=@id_factura 
				/*fin rgelis 2014/10/22 req.22121*/
			End

			--Longitud de la referencia de la factura para la CxP de servicios de proveedores
			Select @LongitudRefe = VALOPAR From dbo.Parametr Where PARAMETRO = 'LongitudRefe'
			Select @bl_ReferenciaCxPProveSrv = rtrim(ltrim(valor)) From DBO.PARAMETROS Where id = 212
			SELECT @bl_ReferenciaCxCProveSrv = rtrim(ltrim(valor)) From DBO.PARAMETROS Where id = 578 --rgelis 2019/07/31 req.60143
			--Iniciando / salvando transaccion depEndiEndo si ya esta iniciada o no--

		  	Begin TRAN;		
			
 			--Datos Cabecera--------------------------------------------------------------------
 			DELETE dbo.Document_Insertar Where SpId = @@SpId
			DELETE dbo.Document_AGEMIN Where SpId = @@SpId
			--Insertar en document_agemin--
			Insert Into dbo.Document_AGEMIN 
					(
						SPID,
						ANODCTO,
						FNTEDCTO,
						NUMEDCTO,
						FECHDCTO,
						NUMTDCTO,
						SUDBDCTO,
						SUCRDCTO,
						DESCDCTO,
						IDTERCERO,
						IDCLIPRV,
						BU
					)
				VALUES 
					(
						@@SPID,			
						@anomes,
						@fuente,
						@numdoctra,
						@fechadoc,
						-1,
						@factotal,
						@factotal,
						@descridoc,
						@idtercero,
						@idcliente,
						@Bu
					)

			------------------------------------------------------------------------------------			
			Insert Into dbo.Document_Insertar 
			Select  * From dbo.document_agemin Where FNTEDCTO=@FUENTE And NUMEDCTO=@NUMDOCTRA
			------------------------------------------------------------------------------------
	
			--Datos Detalle---------------------------------------------------------------------------
			Delete dbo.Transac_Insertar Where SpId = @@SPID
			DELETE dbo.TRANSAC_agemin Where spid = @@SPID
			IF @bl_nocont = 0
			BEGIN  
				--Insertar en transac_agemin---									
			
				-----------------------------------------------------------
				--Inicio Jramirez 2016/10/11 R3244
				-----------------------------------------------------------
				IF @bl_refacturacion = 1 AND @bl_refacturacion_contabilizar_saldos = 1
				BEGIN

					Declare @NFacturasRefacturacion INT, @anomesfac char(7), @FechaCorte  CHAR(10);
					Declare @TableRefacturaciones Table (cd_fuente Varchar(2), Numero Varchar(10))
				
					--Obtenemos la fecha actual
					SELECT @FechaCorte=replace(rtrim(VALOPAR),'/','') FROM Parametr WHERE PARAMETRO = 'FECHACT';
					SELECT @anomesfac = dbo.fnza_Get_ANODCTO(@FechaCorte);

					--Debemos Verificar si fue uno a uno o factura consolidada
					Set @NFacturasRefacturacion  = 0
					Select @NFacturasRefacturacion  = Count(*) From dbo.fac_factura_Refacturacion Where id_fac_factura_refacturacion = @id_factura

					--Se es una a ana la refacturacion
					IF @NFacturasRefacturacion = 1
					BEGIN
						--Obtenemos la informacion de la factura que genera la refacturacion
						Select
							@fuente_refacturacion = cd_fuente
							,@numdoctra_refacturacion = numero
						From dbo.fac_factura_Refacturacion
						Inner Join Fac_factura on Fac_factura.id =fac_factura_Refacturacion.id_fac_factura
						Where id_fac_factura_refacturacion = @id_factura

						--Obtenemos el saldo de la factura CxC
						Set @SaldoFactura = 0
						Select @SaldoFactura = SUM(ff.SACTFAC)
						FROM dbo.Transac t 
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
						INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
													AND ff.IDCLIPRV	= t.CLIPRV
													AND ff.TIPOFACT	= t.TIPOFAC
													AND ff.NUMEFAC	= t.NUMEFAC
													AND ff.VENCFAC	= t.VENCEFAC
													AND ff.REFEFAC	= t.REFEFAC
													AND ff.CLASECP='C'
													AND ff.ANOMESFAC=@anomesfac
						Where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  --And t.INDCPITRA='2'
					
						If @SaldoFactura IS NULL
						Begin
							DELETE dbo.Document_Insertar Where SpId = @@SpId
							DELETE dbo.Document_AGEMIN Where SpId = @@SpId
							--Si la transaccion fue creada en el procedimiento entonces se actualiza--
 		 					If (XACT_STATE() <> 0) and (@@TRANCOUNT > 0) 
	   						Begin 
								COMMIT TRAN;	
							End 
							set @retval = 0;
							RETURN @retval;
						End
						If @SaldoFactura > 0
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@SaldoFactura,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										@SaldoFactura*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
							where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  And t.INDCPITRA='2'
						End
						If @SaldoFactura = 0 
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@factotal,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										@factotal*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
							where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  And t.INDCPITRA='2'
						End
					
					END 
					ELSE IF @NFacturasRefacturacion > 1
					BEGIN
						--Obtenemos la informacion de la factura que genera la refacturacion
						Insert Into @TableRefacturaciones
						Select
							cd_fuente
							,numero
						From dbo.fac_factura_Refacturacion
						Inner Join dbo.Fac_factura on Fac_factura.id =fac_factura_Refacturacion.id_fac_factura
						Where id_fac_factura_refacturacion = @id_factura

						--Obtenemos el saldo de todas las facturas CxC
						Set @SaldoFactura = 0
						Select @SaldoFactura = sum(ff.SACTFAC)
						FROM dbo.Transac t 
						Inner Join @TableRefacturaciones tr on tr.cd_fuente = t.idfuente and tr.numero = t.numdoctra
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
						INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
													AND ff.IDCLIPRV	= t.CLIPRV
													AND ff.TIPOFACT	= t.TIPOFAC
													AND ff.NUMEFAC	= t.NUMEFAC
													AND ff.VENCFAC	= t.VENCEFAC
													AND ff.REFEFAC	= t.REFEFAC
													AND ff.CLASECP='C'
													AND ff.ANOMESFAC=@anomesfac

						If @SaldoFactura > 0
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@SaldoFactura,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									''
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										ff.SACTFAC*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							Inner Join @TableRefacturaciones tr on tr.cd_fuente = t.idfuente and tr.numero = t.numdoctra
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
						End

					END 

					--8) Actualizando campos comunes
					Update dbo.Transac_AGEMIN SET 
							anotra 	 	= @anomes,
							idfuente 	= @fuente,
							numdoctra	= @numdoctra,
							fechatra	= @fechadoc,
							idvEnde		= @idvEnde,
							idusuario	= 'Zeus Agencia Mn',
							fechafact	= @fechadoc,					
							indcpitra	= dbo.fnza_GetTipoCuenta(codicta),
							AUXIAUX		= CASE WHEN dbo.fnza_GetTipoCuenta(CODICTA)='5' AND ISNULL(AUXIAUX,'')='' THEN dbo.fnza_GetAuxiAbierto(CODICTA) ELSE AUXIAUX END
					Where SpId = @@SPID; 		

					Update dbo.Transac_AGEMIN 
					SET BU = @Bu
					Where SpId = @@SPID AND (BU IS NULL OR BU = ''); 
				END
				-----------------------------------------------------------
				--Fin Jramirez 2016/10/11 R3244
				-----------------------------------------------------------
				ELSE
				BEGIN 
					--1) Insertando registro de cartera (cuenta por cobrar)
					--1a) ObteniEndo las obligaciones a terceros
					Declare @t TABLE (
										spid 		INT  ,
										codicta 	VARCHAR (16) ,
										nittra 		VARCHAR(25),
										descritra 	VARCHAR(40),
										valortra 	MONEY ,
										indcpitra 	CHAR(1),
										cliprv 		CHAR(10)
									)

					Insert Into @t 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(tf.am_valor),'2',isnull(c.IDCLIENTE ,@idcliente)
						From dbo.Tiquetes t 
							INNER JOIN dbo.TiqueteFormasPago tf On (t.id = tf.id_Tiquetes AND tf.id_fac_factura = @id_factura)
							INNER JOIN dbo.FormasPago fp On (tf.id_FormasPago = fp.id)
							LEFT JOIN dbo.CLIENTES c On  (c.IDCLIENTE=isnull(fp.cd_Tercero,'')) --(c.IDTERCERO=fp.cd_Tercero or (fp.cd_tercero is null and c.idtercero=''))
						Where t.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre,c.IDCLIENTE 
					UNION 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(fsp.am_valor),'2',isnull(c.IDCLIENTE,@idcliente)
						From dbo.Fac_Servicios fs 
							INNER JOIN dbo.Fac_ServiciosFormasPago fsp On (fs.id = fsp.id_Fac_Servicios  AND fsp.id_fac_factura = @id_factura)
							INNER JOIN dbo.FormasPago fp On (fsp.id_FormasPago = fp.id)		
							LEFT JOIN dbo.CLIENTES c On (c.IDCLIENTE=isnull(fp.cd_Tercero,''))
						Where fs.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre,c.IDCLIENTE 
					UNION 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(ftp.am_valor),'2',isnull(c.IDCLIENTE,@idcliente)
						From dbo.fac_TAO ft 
							INNER JOIN dbo.Fac_TaoFormasPago ftp On (ft.id = ftp.id_Fac_Tao AND ftp.id_fac_factura = @id_factura)
							INNER JOIN FormasPago fp On (ftp.id_FormasPago = fp.id)		
							LEFT JOIN dbo.CLIENTES c On (c.IDCLIENTE=isnull(fp.cd_Tercero,''))
						Where ft.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre ,c.IDCLIENTE
								
					/*--Se cambio por que en Halcon son mayoristas y alla necesitan que se valla a un proveedor.
					Select 
						@@SPID
						, ISNULL(fp.cd_Cuenta,@ctacartera)
						, isnull(fp.cd_Tercero,isnull(P.IDTERCERO,@idtercero))
						, 'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0)))
						, sum(ftp.am_valor)
						, '2'
						, isnull(c.IDCLIENTE,isnull(P.IDPROVE,@idcliente))
					From dbo.fac_TAO ft 
						INNER JOIN dbo.Fac_TaoFormasPago ftp On (ft.id = ftp.id_Fac_Tao AND ftp.id_fac_factura = @id_factura)
						INNER JOIN FormasPago fp On (ftp.id_FormasPago = fp.id)	
						INNER JOIN dbo.ConceptoFacturacion cf on cf.cd_codigo = CASE WHEN ft.in_nacionalidad=1 THEN 'CAN' ELSE 'CAI' END 
						LEFT JOIN PROVEEDORES p ON p.IDPROVE = cf.cd_proveedor
						LEFT JOIN dbo.CLIENTES c On (c.IDTERCERO=isnull(fp.cd_Tercero,''))
					Where ft.id_fac_factura = @id_factura 
						AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
					GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre ,c.IDCLIENTE,P.IDTERCERO, p.IDPROVE	*/				
			
					/* INICIO - JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/
					DECLARE 
						 @bl_DescontarComisionCxP		BIT
						, @CxP_Comisiones				VARCHAR(16)
						, @Descritra_Comisiones			VARCHAR(40)
						, @Factura_Comisiones			VARCHAR(10)
						, @RefeFac_Comisiones			VARCHAR(40)
						, @TipoFac_Comisiones			VARCHAR(2)
						, @VenceFac_Comisiones			VARCHAR(10)

					IF EXISTS(	SELECT ff.Id 
								FROM dbo.fac_factura f
								INNER JOIN dbo.fac_factura ff ON ff.id = f.id_fac_facturaRelacionada AND ff.bl_comisiona = 1
								WHERE f.id = @id_factura AND f.bl_DescontarComisionCxP = 1)
					BEGIN 
						SELECT 
							@CxP_Comisiones=t.CODICTA
							, @TipoFac_Comisiones = t.TIPOFAC
							, @Factura_Comisiones=t.NUMEFAC
							, @VenceFac_Comisiones = t.VENCEFAC
							, @RefeFac_Comisiones = t.REFEFAC
							, @Descritra_Comisiones = t.DESCRITRA 
							,@bl_DescontarComisionCxP = 1
						FROM dbo.fac_factura f
						INNER JOIN dbo.fac_factura ff ON ff.id = f.id_fac_facturaRelacionada
						INNER JOIN dbo.TRANSAC t on t.IDFUENTE = ff.cd_fuente AND t.NUMDOCTRA = ff.numero
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro
						WHERE f.id = @id_factura and t.INDCPITRA='3' AND eslibroprincipal = 1
					END 
					ELSE IF EXISTS(	SELECT ff.Id 
								FROM dbo.fac_factura f
								INNER JOIN dbo.fac_remision ff ON ff.id = f.id_fac_RemisionRelacionada AND ff.bl_comisiona = 1
								WHERE f.id = @id_factura AND f.bl_DescontarComisionCxP = 1)
					BEGIN 
						SELECT 
							@CxP_Comisiones=t.CODICTA
							, @TipoFac_Comisiones = t.TIPOFAC
							, @Factura_Comisiones=t.NUMEFAC
							, @VenceFac_Comisiones = t.VENCEFAC
							, @RefeFac_Comisiones = t.REFEFAC
							, @Descritra_Comisiones = t.DESCRITRA 
							, @bl_DescontarComisionCxP = 1
						FROM dbo.fac_factura f
						INNER JOIN dbo.fac_remision ff ON ff.id = f.id_fac_RemisionRelacionada
						INNER JOIN dbo.TRANSAC t on t.IDFUENTE = ff.cd_fuente AND t.NUMDOCTRA = ff.numero
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro
						WHERE f.id = @id_factura and t.INDCPITRA='3' AND eslibroprincipal = 1
					END 
					/* FIN - JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/

					--Restando el valor cubierto por FP u otros Terceros de  la CxC al cliente 
					Select @CxC_Val = @factotal - isnull(sum(valortra),0) From @t
					--Insertando CxC al cliente
 					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								BU,
								RefeFac		
							)
						VALUES 
							(
								@@SPID,						
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @CxP_Comisiones ELSE @ctacartera END, /*JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/
								@idtercero,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @Descritra_Comisiones ELSE LEFT('CxC: '+ rtrim(@cliente),40) END,
								@CxC_Val,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN 3 ELSE 2 END,
								@idcliente,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @TipoFac_Comisiones ELSE @TipoDocumento END,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @VenceFac_Comisiones ELSE @vencefac END,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @Factura_Comisiones ELSE @numefac END, --@numdoctra END,
								@Bu,
								CASE 
									WHEN @bl_DescontarComisionCxP = 1 THEN @RefeFac_Comisiones 
									WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') --rgelis 2019/07/31 req.90143
									ELSE '' END
							)
						
					--Insertando registros de cartera a otros terceros
					Insert Into dbo.Transac_AGEMIN (spid,codicta,nittra,descritra,valortra,indcpitra,cliprv,TIPOFAC,vencefac,numefac)
						Select spid,codicta,nittra,descritra,ISNULL(sum(valortra),0),indcpitra,cliprv,@TipoDocumento,@vencefac,@NUMDOCTRA
							From @t
							GROUP BY spid,codicta,nittra,descritra,indcpitra,cliprv


					--Calculando valor totla cubierto por anticipos del cliente.
					-- y obteniEndo el BU del anticipo
					Select 
						@totalant=isnull(sum(valor) ,0)
						--,@BU_Anticipo = BU	/*rgelis 2015/10/13 se comentarea porque no permite realizar la suma de anticipos cuando hay varios BU */
					From dbo.AnticiposCliente 
					Where id_fac_factura=@id_factura;
					--GROUP BY BU; 			
		
					--Insertando registro de disminucion de cartera por el valor total cubieto por anticipos
		 			Insert Into dbo.Transac_AGEMIN 
						(
							spid,
							codicta,
							nittra,
							descritra,
							valortra,
							indcpitra,
							cliprv,
							tipofac,
							vencefac,
							numefac,
							bu,
							REFEFAC 
						)
					VALUES 
						(
							@@SPID,						
							@ctacartera,
							@idtercero,
							LEFT('Disminucion de CxC por cruce de anticipo',40),
							@totalant*-1,
							2,
							@idcliente
							,@TipoDocumento
							,@vencefac
							,@NUMDOCTRA
							,@BU
							,CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
						)					
			
			
					--Insertando registros para disminuir saldo a favor del cliente
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								valormoneda,
								tasacambio,
								BU,
								IdItem
							)
			 			Select 	 @@SPID
			 					,cuenta
			 					,@idtercero
			 					,LEFT('DB a anticipo #: '+rtrim(ltrim(numero)),40)
			 					,valor = a.Valor  			 			
			 					,'3'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,a.ValorUSD 
			 					,a.TcFac 
			 					,BU
								,IdItem 
			 				From dbo.AnticiposCliente a Where id_fac_factura=@id_factura;
			
					--Insertando registros de difrencia en cambio a favor
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								bu
							)
			 			Select 	 @@SPID
			 					,m.CODIAJUSTE
			 					,@idtercero
			 					,'Diferencia en cambio a favor'
			 					,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,bu
			 				From dbo.AnticiposCliente a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac<a.TcAnticipo
			 					AND m.CODIAJUSTE IS NOT NULL AND m.CODIAJUSTE <>''
			 					;
			
					--Insertando registros de ajuste en cambio a favor (cuenta de anticipo)
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								statustra,
								bu,
								IdItem
							)
			 			Select 	 @@SPID
			 					,a.Cuenta 
			 					,@idtercero
			 					,'Ajuste moneda en cambio a favor'
			 					,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,'AJ'
			 					,bu
								,IdItem
			 				From dbo.AnticiposCliente a 
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac<a.TcAnticipo
			 					AND a.TcAnticipo>0;
			
					--Insertando registros de difrencia en cambio a perdida
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								bu
							)
			 			Select 	 @@SPID
			 					,m.CtaAjusteMonPerdida 
			 					,@idtercero
			 					,'Ajuste moneda en cambio en contra'
			 					,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,bu
			 				From dbo.AnticiposCliente a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac>a.TcAnticipo
			 					AND m.CtaAjusteMonPerdida IS NOT NULL AND m.CtaAjusteMonPerdida<>''
			 					;
			
					--Insertando registros de difrencia en cambio a perdida
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								statustra,
								bu,
								IdItem
							)
			 			Select 	 @@SPID
			 					,a.Cuenta  
			 					,@idtercero
			 					,'Ajuste moneda en cambio en contra'
			 					,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,'AJ'
			 					,bu
								,IdItem
			 				From dbo.AnticiposCliente a
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac>a.TcAnticipo 
								AND a.TcAnticipo>0;
					---------------------------------------			
					-- Fin anticipo del cliente -----------
					---------------------------------------
			
					--Calculando valor totla cubierto por anticipos del Proveedor.
					-- y obteniEndo el BU del anticipo
					If EXISTS (Select * From dbo.AnticiposProveedores Where id_fac_factura=@id_factura)
					Begin 
						Declare 
							@Count INT,
							@Max_Id INT,
							@Id_fac_Servicio INT,
							@cd_tercero_AntProve VARCHAR(10),
							@cd_proveedores VARCHAR(10),
							@ds_proveedores VARCHAR(250),
							@id_ConceptoFacturacion INT, 
							@id_TiposServicio INT,
							@ds_servicio VARCHAR(25),
							@totalantProve MONEY,
							@BU_AnticipoProve VARCHAR(25),/*rgelis 2013/03/05 req.3505*/ 
							@CtaCxPAnticipoProve VARCHAR(16),
							@Id_Tiquete INT /*rgelis 2014/12/03 req.22131*/
				
						--Creamos una table temporal e insertamos los servicios con anticipos a proveedores.				
						Declare @TAntProve TABLE (Id INT IDENTITY, Id_fac_Servicio INT, cd_tercero_AntProve VARCHAR(10), cd_proveedores VARCHAR(10), ds_proveedores VARCHAR(250),id_ConceptoFacturacion INT, id_TiposServicio INT, ds_servicio VARCHAR(25),id_Tiquete INT) /*rgelis 2014/12/03 req.22131*/
				
						Insert Into @TAntProve (Id_fac_Servicio, cd_tercero_AntProve, cd_proveedores, ds_proveedores, id_ConceptoFacturacion, id_TiposServicio, ds_servicio,id_Tiquete)/*rgelis 2014/12/03 req.22131*/
						Select Fac_servicios.Id, IDTERCERO, cd_proveedores, RAZONCIAL, id_ConceptoFacturacion, id_TiposServicio, LEFT(rtrim(Fac_servicios.ds_servicio),25), NULL AS 'id_Tiquete' /*rgelis 2014/12/03 req.22131*/
						From dbo.Fac_servicios 
						INNER JOIN dbo.AnticiposProveedores On (AnticiposProveedores.id_fac_servicios = Fac_servicios.id AND AnticiposProveedores.id_fac_factura = Fac_servicios.id_fac_factura)
						INNER JOIN dbo.proveedores On (proveedores.IDPROVE = Fac_servicios.cd_proveedores)
						Where Fac_servicios.id_fac_factura = @Id_factura
				
						UNION ALL /*inicio rgelis 2014/12/03 req.22131*/
				
						Select NULL AS 'Id_fac_Servicio', P.IDTERCERO, E.cd_proveedor, P.RAZONCIAL, T.in_nacionalidad AS 'id_ConceptoFacturacion', T.id_TiposDocumento AS 'id_TiposServicio', 'Tkt. '+T.cd_tiquete AS 'ds_servicio', T.id AS 'id_Tiquete'
						From dbo.Tiquetes T
						INNER JOIN dbo.AnticiposProveedores A On (A.id_tiquetes = T.id AND A.id_fac_factura = T.id_fac_factura)
						INNER JOIN Entidades E ON (E.id = T.id_entvend) 
						INNER JOIN dbo.proveedores p On (p.IDPROVE = E.cd_proveedor)
						Where T.id_fac_factura = @Id_factura
						/*fin rgelis 2014/12/03 req.22131*/
				
						SET @Count = 1;
						Select @Max_Id = max(id) From @TAntProve;

						WHILE @Count <= @Max_Id
						Begin
							--Obtenemos los datos del servcio de proveedores que vamos a cruzar.
							Select 					
								@Id_fac_Servicio = Id_fac_Servicio,
								@cd_tercero_AntProve = cd_tercero_AntProve,
								@cd_proveedores = cd_proveedores,
								@ds_proveedores = ds_proveedores,
								@id_ConceptoFacturacion = id_ConceptoFacturacion, 
								@id_TiposServicio = id_TiposServicio,
								@ds_servicio = ds_servicio,
								@Id_Tiquete = id_Tiquete /*rgelis 2014/12/03 req.22131*/
							From @TAntProve Where id = @Count
					
							IF ISNULL(@Id_Tiquete,0) = 0  /*inicio rgelis 2014/12/03 req.22131*/
							BEGIN
								SET @CtaCxPAnticipoProve = dbo.fnza_GetServicioCxP(@id_fac_servicio,@cd_proveedores,@id_ConceptoFacturacion,@id_TiposServicio)

							END 
							ELSE
							BEGIN
								SELECT @CtaCxPAnticipoProve = CASE WHEN t.in_nacionalidad =1 AND e.cd_cta_nac IS NOT NULL AND e.cd_cta_nac<>'' 
																	 THEN e.cd_cta_nac
																   WHEN t.in_nacionalidad =1 AND @CxP_Nac IS NOT NULL AND @CxP_Nac<>''
																	 THEN @CxP_Nac
																   WHEN t.in_nacionalidad =2 AND e.cd_cta_int IS NOT NULL AND e.cd_cta_int<>'' 
																	 THEN e.cd_cta_int
																   WHEN t.in_nacionalidad =2 AND @CxP_Int IS NOT NULL AND @CxP_Int<>''
																	 THEN @CxP_Int
																   Else NULL 
															   END	
								FROM dbo.Tiquetes t	
								INNER JOIN dbo.Entidades e ON e.id=t.id_entvend
								WHERE t.id=	@Id_Tiquete

							END	 /*fin rgelis 2014/12/03 req.22131*/

							Select 
								@totalantProve=isnull(sum(valor),0),
								@BU_AnticipoProve = BU
							From dbo.AnticiposProveedores
							Where id_fac_factura=@id_factura and (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/ 
							GROUP BY BU;

							--Insertando registro de disminucion de cartera por el valor total cubieto por anticipos
		 					Insert Into dbo.Transac_AGEMIN 
								(
									spid,codicta,nittra,refefac,descritra,valortra,indcpitra,cliprv,tipofac,vencefac,numefac,bu
								)
							VALUES 
								(
									@@SPID,						
									@CtaCxPAnticipoProve,
									@cd_tercero_AntProve,
									@ds_servicio,
									LEFT('Disminucion de CxP por cruce de anticipo de proveedor',40),
									@totalantProve,
									2,
									@cd_proveedores,
									@TipoDocumento,
									@vencefac,
									@NUMDOCTRA,
									@BU_AnticipoProve
								)	

							--Insertando registros para disminuir saldo a favor del cliente
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,codicta,nittra,descritra,valortra,indcpitra,cliprv,refefac,idzona,tipofac,idvEnde,vencefac,numefac,valormoneda,tasacambio,BU,IdItem
									)
	 						Select 	 @@SPID
	 								,cuenta
	 								,@cd_tercero_AntProve
	 								,LEFT('DB a anticipo #: '+rtrim(ltrim(numero)),40)
	 								,valor = a.Valor*-1			 			
	 								,'3'
	 								,cliprv			 			
	 								,referencia			 			
	 								,zona
	 								,TIPO
	 								,vEndedor
	 								,vencimiento
	 								,numero
	 								,a.ValorUSD 
	 								,a.TcFac 
	 								,BU 
									,a.IdItem
	 						From dbo.AnticiposProveedores a
							Where id_fac_factura=@id_factura and (id_fac_servicios = @Id_fac_Servicio  OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/

							--Insertando registros de difrencia en cambio a favor
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										bu
									)
			 				Select 	 @@SPID
			 						,m.CODIAJUSTE
			 						,@cd_tercero_AntProve
			 						,'Diferencia en cambio a favor'
			 						,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,bu
			 				From dbo.AnticiposProveedores a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac<a.TcAnticipo
			 					AND m.CODIAJUSTE IS NOT NULL AND m.CODIAJUSTE <>''
			 					;
							
			
			
							--Insertando registros de ajuste en cambio a favor (cuenta de anticipo)
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										statustra,
										bu,
										IdItem
									)
			 				Select 	 @@SPID
			 						,a.Cuenta 
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio a favor'
			 						,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,'AJ'
			 						,bu
									,IdItem
			 				From dbo.AnticiposProveedores a 
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio  OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac<a.TcAnticipo
			 					AND a.TcAnticipo>0;
			
							--Insertando registros de difrencia en cambio a perdida
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										bu
									)
			 				Select 	 @@SPID
			 						,m.CtaAjusteMonPerdida 
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio en contra'
			 						,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,bu
			 				From dbo.AnticiposProveedores a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac>a.TcAnticipo
			 					AND m.CtaAjusteMonPerdida IS NOT NULL AND m.CtaAjusteMonPerdida<>''
			 					;
			
							--Insertando registros de difrencia en cambio a perdida
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										statustra,
										bu,
										IdItem
									)
			 				Select 	 @@SPID
			 						,a.Cuenta  
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio en contra'
			 						,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,'AJ'
			 						,bu
									,IdItem
			 				From dbo.AnticiposProveedores a
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac>a.TcAnticipo 
								AND a.TcAnticipo>0;

							SET @Count = @Count + 1;

						End 	
					End 
					--------------------------------------------------------
					-- Fin anticipo Proveedor ------------------------------
					--------------------------------------------------------
			
					--2) Insertando registros de tiquetes (cuenta por pagar)			
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac
							)
						Select 	@@SPID,
								'Codicta' = CASE 
												WHEN t.in_nacionalidad =1 AND e.cd_cta_nac IS NOT NULL AND e.cd_cta_nac<>'' 
													THEN e.cd_cta_nac
												WHEN t.in_nacionalidad =1 AND @CxP_Nac IS NOT NULL AND @CxP_Nac<>''
													THEN @CxP_Nac
												WHEN t.in_nacionalidad =2 AND e.cd_cta_int IS NOT NULL AND e.cd_cta_int<>'' 
													THEN e.cd_cta_int
												WHEN t.in_nacionalidad =2 AND @CxP_Int IS NOT NULL AND @CxP_Int<>''
													THEN @CxP_Int
												Else NULL 
											End,
								rtrim(p.IDTERCERO),
								LEFT('CxP '+rtrim(p.RAZONCIAL),40),
								sum(dbo.fnza_Get_TiqueteTotalCxP(@id_factura,NULL,t.id))*-1,
								convert(CHAR(1),'3'),
								rtrim(p.IDPROVE)
								,@TipoDocumento
								,@vencefac
								,@NUMDOCTRA
							From dbo.Tiquetes t
								INNER JOIN dbo.Entidades e On (t.id_entvEnd = e.id)			
								INNER JOIN dbo.PROVEEDORES p On (e.cd_proveedor = p.IDPROVE)			
							Where t.id_fac_factura = @id_factura
							GROUP BY p.IDTERCERO,p.IDPROVE, p.RAZONCIAL,e.cd_cta_nac,e.cd_cta_int,p.CODICTA,t.in_nacionalidad;

					--2.1)  Insertando cargos de tiquetes con cuentas parametrizadas
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,					
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								codicta = 	CASE 
												WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta
												Else c.cd_cuenta 
								   			End,	
								@idtercero,					
								LEFT(rtrim(tc.ds_cargonm)+ ': '+rtrim(t.cd_tiquete),40),
								sum(tc.am_valor)*-1,
								@idcliente  
							From dbo.tiquetes t 
								INNER JOIN dbo.TiqueteCargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
								INNER JOIN dbo.CargosDesc c On (c.id=tc.id_cargosdesc)		 
								LEFT JOIN dbo.Cargos_BU cb On (c.id=cb.id_cargo AND cb.id_cargo = tc.id)				
							Where t.id_fac_factura = @id_factura 
								AND abs(tc.am_valor)<>0
								AND dbo.fnza_CargoManejaCuenta(tc.id_cargosdesc)=1
								--AND isnull(cb.cd_bu,@Bu)=@Bu 
							GROUP BY c.cd_cuenta,cb.cd_cuenta,tc.ds_cargonm,t.cd_tiquete
			
					--2.2) Insertando registros de impuestos sobre cargos de tiquetes con cuentas parametrizadas 
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra, 
								baseretetra,
								tipofac,
								vencefac,
								numefac
							)
						Select 
							spid,
							codicta,
							nittra,
							descritra,
							valortra,
							indcpitra,
							cliprv,
							porretetra, 
							baseretetra,
							tipofac= Case WHEN indcpitra IN (2,3) THEN @TipoDocumento ELSE NULL END,
							vencefac=Case WHEN indcpitra IN (2,3) THEN @vencefac ELSE NULL END ,
							numefac=Case WHEN indcpitra IN (2,3) THEN @NUMDOCTRA ELSE NULL END 
						From(
							Select 	@@SPID As 'Spid',
								codicta = 	CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
													WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
													WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
													WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
													Else ir.cd_cuenta
								   			End,	
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN p.idtercero ELSE @idtercero END 'nittra',
								LEFT(ti.ds_Impas+': '+rtrim(t.cd_tiquete),40) As 'descritra',
								sum(ti.am_valor)*-1 as 'valortra',
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN dbo.fnza_GetTipoCuenta(CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End) ELSE convert(CHAR(1),'1') END AS 'indcpitra',
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN ti.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN tid.id IS NOT NULL THEN ROUND(abs(tid.am_valor)*-1,@Decimales) ELSE ROUND((tc.am_valor)*-1 ,@Decimales) END
												End  
								From dbo.tiquetes t 
									INNER JOIN dbo.tiquetecargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
									LEFT  JOIN dbo.TiqueteImpuestos ti On (ti.id_TiqueteCargos  = tc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = ti.id_ImpRet)
									LEFT  JOIN dbo.proveedores p on p.idprove = cd_proveedor
									LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id)
									LEFT  JOIN dbo.TiqueteImpuestos tid On (tid.id_ImpRet = ir.Id_imp_dep AND tid.id_TiqueteCargos  = ti.id_TiqueteCargos)
								Where t.id_fac_factura = @id_factura 
									AND abs(ti.am_valor)<>0
									AND isnull(ib.cd_bu,@bu)=@bu
									AND (dbo.fnza_CargoManejaCuenta(tc.id_cargosdesc)=1
										OR (ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND ti.id_ImpRet IN(1,2,3,4,12))
										OR (ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '')
										)
								GROUP BY ir.cd_cuenta,ti.ds_Impas,t.cd_tiquete,t.cd_Penalidad,ti.am_porcentaje,tc.am_valor,ib.cd_cuenta,ti.id_impret
								,ir.bl_contabilizar_proveedor,ir.cd_proveedor,p.idtercero,tid.id,tid.am_valor--R52825 - Jramirez - 20170919
							) Impuestos
						
					--3) Insertando registros de servicios de proveedor (cuenta por pagar) 
				
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								refefac,
								idcenco,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								iditem
							)
						SELECT 
							SPID
							, t.codicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN @idtercero ELSE nittra END AS 'nittra'
							, descritra
							, refefac
							, idcenco
							, valortra
							, m.indcpicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE cliprv END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE tipofac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE vencefac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE numefac END
							, cd_item 
						FROM (					
							Select 	SPID = @@SPID,
									dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio) AS 'codicta',
									p.IDTERCERO AS 'nittra',
									LEFT('CxP: '+rtrim(p.RAZONCIAL),40) AS 'descritra',
									CASE WHEN @bl_ReferenciaCxPProveSrv = 'S' THEN LEFT(rtrim(fs.ds_records),@LongitudRefe) Else '' END AS 'refefac',
									case when dbo.fnza_ManejaCenCo (dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio)) = 1 then ISNULL(fs.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
									sum(dbo.fnza_Get_FacServicioTotalCxP(fs.id,@BU))*-1 AS 'valortra',
									convert(CHAR(1),'3') AS 'indcpitra',
									p.IDPROVE AS 'cliprv'
									,@TipoDocumento AS 'tipofac'
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN dbo.fnza_Get_FECHDCTO(fs.dt_VenceFac) ELSE @vencefac END AS 'vencefac' /*inicio rgelis 2014/11/10 req.22115*/
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN fs.cd_NumeFac ELSE @NUMDOCTRA END AS 'numefac' /*fin rgelis 2014/11/10 req.22115*/
									, ts.bl_ContabilizarClienteFac
									, fs.cd_item
								From dbo.Fac_Servicios fs		
									INNER JOIN dbo.conceptofacturacion cf on (cf.id = fs.id_ConceptoFacturacion)			
									LEFT JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
									LEFT JOIN dbo.TiposServicios ts On (ts.id = fs.id_TiposServicio)
								Where fs.id_fac_factura = @id_factura 
									AND fs.id_TiposConceptFac = 2
									AND cf.bl_llevarAlIngreso = 0
								GROUP BY p.CODICTA
										,p.IDTERCERO
										,p.RAZONCIAL
										,p.IDPROVE
										,fs.id
										,fs.cd_proveedores
										,fs.id_ConceptoFacturacion
										,fs.id_TiposServicio
										,fs.cd_cencosto
										,fs.ds_records
										,ts.bl_ContabilizarClienteFac
										,fs.cd_item
										,fs.cd_NumeFac /*inicio rgelis 2014/11/10 req.22115*/
										,fs.dt_VenceFac	/*fin rgelis 2014/11/10 req.22115*/
						) AS T
						INNER JOIN MAECONT m ON m.CODICTA = t.CODICTA	
						
												
						--3.1)  Insertando cargos de servicios con cuentas parametrizadas
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,		
								auxiaux,
								idcenco,
								iditem,				
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								codicta = 	CASE 
												WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta
												Else c.cd_cuenta 
								   			End,	
								IdTercero = CASE 	WHEN @LlevarCliTerContabil = 'S' Then @idtercero
													WHEN dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta Else c.cd_cuenta End) = 4 THEN p.IdTercero 
													Else @idtercero End,	
								f.cd_auxiliar,
								case when dbo.fnza_ManejaCenCo (CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta Else c.cd_cuenta End) = 1 then ISNULL(f.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								f.cd_item,				
								LEFT(rtrim(fc.ds_cargonm)+ ': '+rtrim(f.ds_servicio),40),
								sum(fc.am_valor)*-1,
								IdCliProve = CASE 	WHEN @LlevarCliTerContabil = 'S' Then @idcliente
													WHEN dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta Else c.cd_cuenta End) = 4 THEN p.IDPROVE 
													Else @idtercero End
							From dbo.Fac_Servicios f 
								INNER JOIN dbo.conceptofacturacion cf on (cf.id = f.id_ConceptoFacturacion)
								LEFT JOIN dbo.PROVEEDORES p On (f.cd_proveedores = p.IDPROVE)					
								INNER JOIN dbo.Fac_ServiciosCargos fc On (f.id = fc.id_Fac_Servicios)
								INNER JOIN dbo.CargosDesc c On (c.id=fc.id_cargosdesc)		 
								LEFT JOIN dbo.Cargos_BU cb On (c.id=cb.id_cargo AND cb.id_cargo = fc.id)				
							Where f.id_fac_factura = @id_factura 
								AND abs(fc.am_valor)<>0
								AND dbo.fnza_CargoManejaCuenta(fc.id_cargosdesc)=1
								AND f.id_TiposConceptFac = 2
								AND cf.bl_llevarAlIngreso = 0
								--AND isnull(cb.cd_bu,@Bu)=@Bu 
							GROUP BY c.cd_cuenta,cb.cd_cuenta,fc.ds_cargonm,f.ds_servicio,p.IdTercero,p.IDPROVE,f.cd_auxiliar,f.cd_cencosto,f.cd_item
			
					--3.2) Insertando registros de Impuestos de servicios con cuentas parametrizadas	
					--xyz
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra,
								baseretetra
							)
						Select 	@@SPID,
								codicta = 	CASE
												WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
												Else ir.cd_cuenta
								   			End,
								@idtercero,
								f.cd_auxiliar,
								case when dbo.fnza_ManejaCenCo (CASE WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta Else ir.cd_cuenta End) = 1 then ISNULL(f.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								f.cd_item,	
								LEFT(fi.ds_Impas+': '+rtrim(f.ds_servicio),40),
								sum(fi.am_valor)*-1,
								convert(CHAR(1),'1'),
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE 
																WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																Else ir.cd_cuenta
									   						End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN fi.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE 
																WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																Else ir.cd_cuenta
									   						End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN fid.id IS NOT NULL THEN ROUND(abs(fid.am_valor)*-1,@Decimales) ELSE ROUND((fc.am_valor)*-1 ,@Decimales) END
												End  
							From dbo.Fac_Servicios  f 
								INNER JOIN dbo.conceptofacturacion cf on (cf.id = f.id_ConceptoFacturacion)
								INNER JOIN dbo.Fac_ServiciosCargos fc On (f.id = fc.id_Fac_Servicios)
								LEFT  JOIN dbo.Fac_ServiciosImpuestos  fi On (fi.id_FacServiciosCargos   = fc.id)
								INNER JOIN dbo.ImpRet ir On (ir.id = fi.id_ImpRet)
								LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id)
								LEFT  JOIN dbo.Fac_ServiciosImpuestos fid On (fid.id_ImpRet = ir.Id_imp_dep AND fid.id_FacServiciosCargos = fi.id_FacServiciosCargos)
							Where f.id_fac_factura = @id_factura 
								AND abs(fi.am_valor)<>0
								AND isnull(ib.cd_bu,@bu)=@bu
								AND dbo.fnza_ImpManejaCuenta(fi.Id_ImpRet,@BU)=1
								AND f.id_TiposConceptFac = 2 
								AND cf.bl_llevarAlIngreso = 0
							GROUP BY ir.cd_cuenta,fi.ds_Impas,f.ds_servicio,fi.am_porcentaje,fc.am_valor,ib.cd_cuenta,fi.id_impret,f.cd_auxiliar,f.cd_cencosto,f.cd_item,ir.bl_contabilizar_proveedor,ir.cd_proveedor,fid.id,fid.am_valor--R52825 - Jramirez - 20170919


					--Codigo del Cargo de comision para la factura nueva con las Comisiones y IVA de Comisiones de los tiquetes del cierre
					Select @CodComisionFacNuevaComCierre	= Valor From dbo.parametros Where Id = 224
					--Codigo del Impuesto IVA para la factura nueva con las Comisiones y IVA de Comisiones de los tiquetes del cierre
					Select @CodIVAFacNuevaComCierre	= Valor From dbo.parametros Where Id = 225
					
 					--4) Insertando registros de  ventas propias y comisiones (ingresos - contabilizacion por cargos)
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,						
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								codicta = 	CASE 
												WHEN (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1) THEN isnull(cd_cuenta_Causacion_Ingreso,'')
												WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, 'Comision')
												WHEN dbo.fnza_Get_CtaCargoBu(@Bu,fsc.id_cargosdesc)<>'' THEN dbo.fnza_Get_CtaCargoBu(@Bu,fsc.id_cargosdesc)
												WHEN isnull(c.cd_cuenta,'')<>'' THEN c.cd_cuenta
												WHEN cf.cd_codigo = 'CEM' THEN  dbo.fnza_Get_CargoEmisionCta(fs.in_nacionalidad,fs.cd_tiquete,@id_factura,null)
												WHEN cf.cd_codigo = 'SCR' THEN dbo.fnza_Get_ServiceChargeCta(fs.in_nacionalidad,fs.cd_tiquete)
												Else dbo.fnza_GetServicioCxP(fs.id,'',fs.id_ConceptoFacturacion,fs.id_TiposServicio)
								   			End,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,
								ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,						
								LEFT(rtrim(cf.ds_nombre)+ ': '+rtrim(fs.ds_servicio),40),
								CASE WHEN fs.id_TiposConceptFac = 3 Or cf.bl_llevarAlGasto = 0 THEN sum(fsc.am_valor)*-1 ELSE sum(fsc.am_valor)*1 END,/*rgelis 2013/09/09 req.16665*/
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDPROVE,'')<>'' THEN p.IDPROVE ELSE @idcliente END
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.CargosDesc c On (c.id=fsc.id_cargosdesc)
								INNER JOIN dbo.ConceptoFacturacion cf On (cf.id = fs.id_ConceptoFacturacion)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/ 
							Where fs.id_fac_factura = @id_factura 
							AND (fs.id_TiposConceptFac IN (3,4) OR (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1))
							AND abs(fsc.am_valor)<>0

							GROUP BY c.cd_cuenta,fs.ds_servicio,fsc.am_valor,cf.cd_cuenta,fsc.id_cargosdesc,cf.cd_codigo,fs.in_nacionalidad,fs.cd_tiquete,fs.id,fs.id_ConceptoFacturacion,fs.id_TiposServicio ,fs.cd_auxiliar ,fs.cd_cencosto,fs.cd_item ,cf.ds_nombre, fs.id_TiposConceptFac ,cf.bl_llevarAlGasto, p.IDTERCERO, p.IDPROVE/*rgelis 2013/09/09 req.16665*/ /*rgelis 2016/12/09 req.34960*/
							,bl_llevarAlIngreso, cd_cuenta_Causacion_Ingreso
					 

 					--5) Insertando registros de impuestos
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,/* inicio rgelis 2012/09/04 req.10397*/ 
								idcenco,
								iditem,/*fin rgelis 2012/09/04 req.10397*/ 
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra, 
								baseretetra
							)
						Select 	@@SPID,
								codicta = 	CASE 
												--WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, 'IVA sobre comisiones de tiquetes aereos')
												WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
												WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)
												--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
												WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta										
												Else ia.cd_cuenta
								   			End,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,/*inicio rgelis 2012/09/04 req.10397*/ 
								case when dbo.fnza_ManejaCenCo (CASE
																	WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																	WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																	WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)
																	--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																	WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta										
																	Else ia.cd_cuenta
								   								End) = 1 then ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,/*fin rgelis 2012/09/04 req.10397*/ 								
								--LEFT(fsi.ds_Impas+': '+rtrim(fs.ds_servicio),40),
								LEFT(fsi.ds_Impas+': ' + case when fs.cd_tiquete is not null then 'tkt.' + fs.cd_tiquete else '' end +rtrim(fs.ds_servicio),40),
								CASE WHEN fs.id_TiposConceptFac = 3 Or c.bl_llevarAlGasto = 0 THEN sum(fsi.am_valor)*-1 ELSE sum(fsi.am_valor)*1 END , /*rgelis 2013/09/09 req.16665*/
								convert(CHAR(1),'1'),
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE
																WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad) 
																WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)													
																--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta														
																Else ia.cd_cuenta
									   						End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN fsi.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE
																WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad) 
																WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)													
																--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta														
																Else ia.cd_cuenta
									   						End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN fsib.id IS NOT NULL 
																	 THEN ROUND((sum(fsib.am_valor))*-1 ,@Decimales) 
																	 ELSE ROUND((sum(fsc.am_valor))*-1 ,@Decimales)
																END
												End  
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.ConceptoFacturacion c On (fs.id_ConceptoFacturacion =c.id)					
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.Fac_ServiciosImpuestos fsi On (fsi.id_FacServiciosCargos = fsc.id)
								INNER JOIN dbo.ImpRet ir On (ir.id = fsi.id_ImpRet)
								LEFT  JOIN dbo.Impuestos_asignados ia On 
									(
											ia.id_ConceptoFacturacion = fs.id_ConceptoFacturacion
										AND ia.id_impuesto      	  = fsi.id_ImpRet 
									)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/
								LEFT JOIN dbo.Fac_ServiciosImpuestos fsib On (fsib.id_ImpRet = ir.Id_imp_dep AND fsib.id_FacServiciosCargos = fsi.id_FacServiciosCargos)
							Where fs.id_fac_factura = @id_factura AND fs.id_TiposConceptFac IN (3,4) AND abs(fsi.am_valor)>0
							GROUP BY fs.cd_tiquete, ir.cd_cuenta,fsi.ds_Impas,fs.ds_servicio,fsi.am_porcentaje,fsc.am_valor,ia.cd_cuenta,fsi.id_impret,c.cd_codigo,fs.in_nacionalidad,fs.cd_auxiliar,fs.cd_cencosto,fs.cd_item, fs.id_TiposConceptFac,c.bl_llevarAlGasto,p.IDTERCERO,fsib.id /*rgelis 2016/12/09 req.34960*/ /*rgelis 2013/09/09 req.16665*/,ir.bl_contabilizar_proveedor,ir.cd_proveedor--R52825 - Jramirez - 20170919
						
					--6) Insertando registros de TAO (ingresos)
					--xyz
					IF @bl_LlevarSrvTercero = 1 and isnull(@cd_proveedorTAO ,'') <> ''
					begin
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,					
								descritra,
								valortra,
								indcpitra,
								cliprv,
								TIPOFAC,
								VENCEFAC,
								NUMEFAC
							)
						Select 	
							@@SPID,
							CASE	WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 1 and @CtaAlternaTAONac is not null and @CtaAlternaTAONac <> '' THEN @CtaAlternaTAONac
									WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 2 and @CtaAlternaTAOInter is not null and @CtaAlternaTAOInter <> '' THEN @CtaAlternaTAOInter
									Else dbo.fnza_Get_FacTaoCta(ft.in_nacionalidad,ft.cd_tiquete,@id_factura,null) 
									End AS 'codicta',	
							p.IDTERCERO,					
							LEFT(rtrim(ftc.ds_cargonm)+ ' TAO TKT: '+rtrim(ft.cd_tiquete),40),
							sum(ftc.am_valor)*-1,
							convert(CHAR(1),'3'),
							p.IDPROVE,
							@TipoDocumento,
							@vencefac,
							@numdoctra
						From dbo.fac_tao ft 
							INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao AND ft.id_fac_factura = ftc.id_fac_factura)
							INNER JOIN dbo.CargosDesc c On (c.id=ftc.id_cargosdesc)		 
							outer apply (select * from proveedores where idprove = @cd_proveedorTAO) p 
						Where ft.id_fac_factura = @id_factura 
							AND abs(ftc.am_valor)<>0
						GROUP BY c.cd_cuenta,ftc.ds_cargonm,ft.cd_tiquete,ft.in_nacionalidad,p.IDTERCERO,p.IDPROVE	
						
						
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									cliprv,
								TIPOFAC,
								VENCEFAC,
								NUMEFAC
								)
							Select 	@@SPID,
									codicta = CASE 
												WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,null)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fti.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fti.id_impret)
												Else ir.cd_cuenta
											  End,
									p.IDTERCERO,
									LEFT(fti.ds_Impas+' . Tkt: '+rtrim(ft.cd_tiquete),40),
									(sum(fti.am_valor))*-1,
									convert(CHAR(1),'3'),
									p.IDPROVE,
									@TipoDocumento,
									@vencefac,
									@numdoctra 
								From dbo.fac_TAO ft 
									INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao)
									INNER JOIN dbo.Fac_TaoImpuestos fti On (fti.id_FacTaoCargos = ftc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = fti.id_ImpRet)
									outer apply (select * from proveedores where idprove = @cd_proveedorTAO) p 
								Where ft.id_fac_factura = @id_factura 
								GROUP BY ir.cd_cuenta
										,fti.ds_Impas 
										,ft.cd_tiquete
										,fti.am_porcentaje
										,ftc.am_valor
										,fti.id_ImpRet
										,ft.in_nacionalidad
										,ft.id_fac_factura  
										,p.IDTERCERO
										,p.IDPROVE
																						
					end
					else
					begin
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									auxiaux,
									idcenco,
									iditem,
									descritra,
									valortra,
									indcpitra,
									cliprv
								)
							Select 	@@SPID AS 'spid',
									CASE	WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 1 and @CtaAlternaTAONac is not null and @CtaAlternaTAONac <> '' THEN @CtaAlternaTAONac
											WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 2 and @CtaAlternaTAOInter is not null and @CtaAlternaTAOInter <> '' THEN @CtaAlternaTAOInter
											Else dbo.fnza_Get_FacTaoCta(ft.in_nacionalidad,ft.cd_tiquete,@id_factura,null) 
											End AS 'codicta',
									@idtercero AS 'nittra',
									ft.cd_aux AS 'auxiaux',
									CASE WHEN RTRIM(ISNULL(ft.cd_cencosto,''))<>'' THEN ft.cd_cencosto /*inicio rgelis 2014/10/22 req.22121*/
										 WHEN RTRIM(ISNULL(@cd_cencoSucursal,''))<>'' THEN @cd_cencoSucursal
										 WHEN ft.in_nacionalidad = 1 THEN @cd_cencoSucursalTaoNac
										 ELSE @cd_cencoSucursalTaoInt END AS 'idcenco', /*rgelis 2012/09/04 req.10397*//*fin rgelis 2014/10/22 req.22121*/
									ft.cd_coditem AS 'iditem',
									LEFT('TAO tkt: ' + rtrim(ft.cd_tiquete),40) AS 'descritra',
									dbo.fnza_Get_FacTaoCargos(ft.id)*-1 AS 'valortra',
									convert(CHAR(1),'1') AS 'indcpitra',
									@idcliente AS 'cliprv'
								From dbo.fac_TAO ft
								Where ft.id_fac_factura = @id_factura


			
						--7) Insertando registros de impuestos de TAO
						--xyz
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									cliprv,
									porretetra, 
									baseretetra
								)
							Select 	@@SPID,
									codicta = CASE 
												WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,null)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fti.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fti.id_impret)
												Else ir.cd_cuenta
											  End,
									@idtercero,
									LEFT(fti.ds_Impas+' . Tkt: '+rtrim(ft.cd_tiquete),40),
									(sum(fti.am_valor))*-1,
									--sum((fti.am_valor))*-1,
									convert(CHAR(1),'1'),
									CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
									'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje(CASE WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,NULL) Else ir.cd_cuenta End) /*rgelis 2014/10/22 req.22121*/
														WHEN 0 THEN 0
														WHEN 1 THEN fti.am_porcentaje
													End,
										
									'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje(CASE WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,NULL) Else ir.cd_cuenta End) /*rgelis 2014/10/22 req.22121*/
														WHEN 0 THEN 0
														WHEN 1 THEN CASE WHEN ftid.id IS NOT NULL THEN ROUND(abs(ftid.am_valor)*-1,@Decimales) ELSE ROUND(abs(ftc.am_valor)*-1,@Decimales) END
													End  
								From dbo.fac_TAO ft 
									INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao)
									INNER JOIN dbo.Fac_TaoImpuestos fti On (fti.id_FacTaoCargos = ftc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = fti.id_ImpRet)
									LEFT JOIN dbo.Fac_TaoImpuestos ftid ON (ftid.id_ImpRet = Ir.Id_imp_dep AND ftid.id_FacTaoCargos=fti.id_FacTaoCargos)
								Where ft.id_fac_factura = @id_factura 
								GROUP BY ir.cd_cuenta
										,fti.ds_Impas 
										,ft.cd_tiquete
										,fti.am_porcentaje
										,ftc.am_valor
										,fti.id_ImpRet
										,ft.in_nacionalidad
										,ft.id_fac_factura  /*rgelis 2014/10/22 req.22121*/		
										,ir.bl_contabilizar_proveedor,ir.cd_proveedor	--R52825 - Jramirez - 20170919
										,ftid.id
										,ftid.am_valor		
					end
					--8) Actualizando campos comunes
					Update dbo.Transac_AGEMIN SET 
							anotra 	 	= @anomes,
							idfuente 	= @fuente,
							numdoctra	= @numdoctra,
							fechatra	= @fechadoc,
							idvEnde		= @idvEnde,
							idusuario	= 'Zeus Agencia Mn',
							fechafact	= @fechadoc,					
							indcpitra	= dbo.fnza_GetTipoCuenta(codicta),
							AUXIAUX		= CASE WHEN dbo.fnza_GetTipoCuenta(CODICTA)='5' AND ISNULL(AUXIAUX,'')='' THEN dbo.fnza_GetAuxiAbierto(CODICTA) ELSE AUXIAUX END
						Where SpId = @@SPID; 		

					Update dbo.Transac_AGEMIN 
					SET BU = @Bu
					Where SpId = @@SPID AND (BU IS NULL OR BU = ''); 

					----------------------------------------------------------------------------------------------------
					---Inicio Causación CxP servicio de tercero
					----------------------------------------------------------------------------------------------------
					Declare 
						@fteCausacionCxPSrv3ros Varchar(25)
						,@sreCausacionCxPSrv3ros Varchar(25)
						,@cscutvoCausacionCxPSrv3ros Varchar(25)
						,@NumeroCausacionCxPSrv3ros Varchar(50)
						,@totalCausacionCxPSrv3ros MONEY
						
	   				--Incrementando y obteniendo consecutivo--
	   				SET @procmsg = ''  			
					IF EXISTS(	SELECT * 
								FROM fac_servicios fs
								INNER JOIN conceptofacturacion cf on cf.id = id_ConceptoFacturacion
								WHERE id_fac_Factura = @id_factura and bl_servicio_propio = 1
								)


					BEGIN
  						EXEC @procret = dbo.spza_IncrementaConsecutivo @id_MaeTipoTransacciones = 31,
														   			@id_sucursal             = @id_sucursal    ,
														   			@id_implante             = @id_implante    , 
														   			@cd_fuente               = @fteCausacionCxPSrv3ros     OUTPUT ,
														   			@cd_serie				 = @sreCausacionCxPSrv3ros     OUTPUT ,
														   			@cd_consecutivo          = @cscutvoCausacionCxPSrv3ros OUTPUT ,
														   			@errmsg					 = @procmsg OUTPUT ;
					END
					set @msg = @procmsg
				
					IF (@procmsg <> '') -- Proceso de incremento de consecutivo fallido				
					BEGIN 
						set @retval = 1
						IF (@@TRANCOUNT >0) ROLLBACK TRAN;	
					
						IF (@bl_af = 1)
						BEGIN
							EXEC dbo.spzaAuditoria_Insertar	@id_proceso = @idproce   ,
											 			 				@id_usuario = @id_usuario ,
											 			 				@cd_status  = 0           , 
											 			 				@admsg      = @msg	  ;			
						END	  
						
						Select @procmsg As 'Respuesta', 1 AS 'Estado' ;
						RETURN 1 ;
					END 


						--select @fteCausacionCxPSrv3ros as IDFUENTE
						--	, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA


					-- Insertando registros de servicios de proveedor (cuenta por pagar) para la nota de Causación CxP servicio de tercero
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								IDFUENTE,
								NUMDOCTRA,
								codicta,
								nittra,
								descritra,
								refefac,
								idcenco,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								iditem
							)
						SELECT 
							SPID
							, @fteCausacionCxPSrv3ros as IDFUENTE
							, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA
							, t.codicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN @idtercero ELSE nittra END AS 'nittra'
							, descritra
							, refefac
							, idcenco
							, valortra
							, m.indcpicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE cliprv END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE tipofac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE vencefac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE numefac END
							, cd_item 
						FROM (					
							Select 	SPID = @@SPID,
									dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio) AS 'codicta',
									p.IDTERCERO AS 'nittra',
									LEFT('CxP: '+rtrim(p.RAZONCIAL),40) AS 'descritra',
									CASE WHEN @bl_ReferenciaCxPProveSrv = 'S' THEN LEFT(rtrim(fs.ds_records),@LongitudRefe) Else '' END AS 'refefac',
									case when dbo.fnza_ManejaCenCo (dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio)) = 1 then ISNULL(fs.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
									sum(dbo.fnza_Get_FacServicioTotalCxP(fs.id,@BU))*-1 AS 'valortra',
									convert(CHAR(1),'3') AS 'indcpitra',
									p.IDPROVE AS 'cliprv'
									,@TipoDocumento AS 'tipofac'
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN dbo.fnza_Get_FECHDCTO(fs.dt_VenceFac) ELSE @vencefac END AS 'vencefac' /*inicio rgelis 2014/11/10 req.22115*/
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN fs.cd_NumeFac ELSE @NUMDOCTRA END AS 'numefac' /*fin rgelis 2014/11/10 req.22115*/
									, ts.bl_ContabilizarClienteFac
									, fs.cd_item
								From dbo.Fac_Servicios fs		
									INNER JOIN dbo.conceptofacturacion cf on (cf.id = fs.id_ConceptoFacturacion)
									LEFT JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
									LEFT JOIN dbo.TiposServicios ts On (ts.id = fs.id_TiposServicio)
								Where fs.id_fac_factura = @id_factura 
									AND fs.id_TiposConceptFac = 2
									AND cf.bl_llevarAlIngreso = 1
								GROUP BY p.CODICTA
										,p.IDTERCERO
										,p.RAZONCIAL
										,p.IDPROVE
										,fs.id
										,fs.cd_proveedores
										,fs.id_ConceptoFacturacion
										,fs.id_TiposServicio
										,fs.cd_cencosto
										,fs.ds_records
										,ts.bl_ContabilizarClienteFac
										,fs.cd_item
										,fs.cd_NumeFac /*inicio rgelis 2014/11/10 req.22115*/
										,fs.dt_VenceFac	/*fin rgelis 2014/11/10 req.22115*/
						) AS T
						INNER JOIN MAECONT m ON m.CODICTA = t.CODICTA	
						
						--select @fteCausacionCxPSrv3ros as IDFUENTE, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA
						
						--) Insertando registros de  ventas propias y comisiones (ingresos - contabilizacion por cargos) 
						-- para la notaCausación CxP servicio de tercero
						Select @totalCausacionCxPSrv3ros = valortra from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros and numdoctra=@NumeroCausacionCxPSrv3ros and valortra>0
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								IDFUENTE,
								NUMDOCTRA,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,						
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								@fteCausacionCxPSrv3ros as IDFUENTE,
								@sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA,
								codicta = 	cd_cuenta_Causacion_GastoCosto,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,
								ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,						
								LEFT('Gasto ' + rtrim(cf.ds_nombre)+ ': '+rtrim(fs.ds_servicio),40),
								fsc.am_valor,
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDPROVE,'')<>'' THEN p.IDPROVE ELSE @idcliente END
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.CargosDesc c On (c.id=fsc.id_cargosdesc)
								INNER JOIN dbo.ConceptoFacturacion cf On (cf.id = fs.id_ConceptoFacturacion)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/ 
							Where fs.id_fac_factura = @id_factura 
							AND (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1)
							AND abs(fsc.am_valor)<>0

							GROUP BY c.cd_cuenta,fs.ds_servicio,fsc.am_valor,cf.cd_cuenta,fsc.id_cargosdesc,cf.cd_codigo,fs.in_nacionalidad,fs.cd_tiquete,fs.id,fs.id_ConceptoFacturacion,fs.id_TiposServicio ,fs.cd_auxiliar ,fs.cd_cencosto,fs.cd_item ,cf.ds_nombre, fs.id_TiposConceptFac ,cf.bl_llevarAlGasto, p.IDTERCERO, p.IDPROVE/*rgelis 2013/09/09 req.16665*/ /*rgelis 2016/12/09 req.34960*/
							,bl_llevarAlIngreso, cd_cuenta_Causacion_GastoCosto
					

							IF EXISTS(select * from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros and spid=@@spid)
							BEGIN
								--select * from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros
								set @NumeroCausacionCxPSrv3ros = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros
								--Insertar en document_agemin--
								Insert Into dbo.Document_AGEMIN 
									(
										SPID,
										ANODCTO,
										FNTEDCTO,
										NUMEDCTO,
										FECHDCTO,
										NUMTDCTO,
										SUDBDCTO,
										SUCRDCTO,
										DESCDCTO,
										IDTERCERO,
										IDCLIPRV,
										BU
									)
								VALUES 
									(
										@@SPID,			
										@anomes,
										@fteCausacionCxPSrv3ros,
										@NumeroCausacionCxPSrv3ros,
										@fechadoc,
										-1,
										@totalCausacionCxPSrv3ros,
										@totalCausacionCxPSrv3ros,
										@descridoc,
										@idtercero,
										@idcliente,
										@Bu
									)

								Insert Into dbo.Document_Insertar 
								Select  * From dbo.document_agemin Where FNTEDCTO=@fteCausacionCxPSrv3ros And NUMEDCTO=@NumeroCausacionCxPSrv3ros


							END
							------------------------------------------------------------------------------------			


						
					----------------------------------------------------------------------------------------------------
					---Fin Causación CxP servicio de tercero
					----------------------------------------------------------------------------------------------------
					/*iniciorgelis 2012/10/11 req.10814*/
					--8.a) Recibo de Caja automatico
				
						--Si esta activo generar RC
					If (@bl_RcAuto = 1)
					Begin
						--Instrucciones del RC Automatico -----------------------------------------				
						SET @procmsgRC = ''  	
						SET @ResolucionmsgRC = ''		
				
						--Obtenemos la fuente de RC de los parametros.
						--Select @cd_fuenteRC = Valor From dbo.parametros Where id = 51 /*rgelis 2013/08/05 req.15991*/
						--Select @cd_fuenteRCOtr = Valor From dbo.parametros Where id = 206	/*rgelis 2013/08/05 req.15991*/
				
						If @cd_fuenteRCOtr is null or @cd_fuenteRCOtr = ''
						Begin
							SET @cd_fuenteRCOtr = @cd_fuenteRC
						End
						--Se declaran las variables contadoras
						DECLARE @CONTRC_D INT,@MAXRC_D INT; 
						--se daclaran las tablas de los recibos de caja para el document y el transac 
						DECLARE @RC_Document TABLE(id numeric identity( 1,1) NOT NULL
								,id_Fp INT
								,cd_FP CHAR(3)
								,am_FP MONEY
								,cd_Cuenta CHAR(16)
								,cd_Banco CHAR(3)
								,cd_Plaza CHAR(3)
								,cd_Serie CHAR(2)
								,cd_TipoFac CHAR(3)
								,in_Tipo INT
								,cd_Fuente CHAR(2)
								,cd_Consecutivo  VARCHAR(8)
								,id_TarjetasCredito INT /*rgelis 2014/03/04 req.18770*/
								,bl_GenerarSoloUnRCPorFP BIT
								,in_Fp INT); /*rgelis 2016/07/15 req.32431*/
						
						DECLARE @RC_Transac TABLE(id numeric identity( 1,1) NOT NULL
								,id_Fp INT
								,cd_FP CHAR(3)
								,am_FP MONEY
								,cd_Cuenta CHAR(16)
								,cd_Banco CHAR(3)
								,cd_Plaza CHAR(3)
								,cd_Serie CHAR(2)
								,cd_TipoFac CHAR(3)
								,ds_tcvoucher CHAR(25)
								,in_Tipo INT
								,in_item INT
								,cd_Fuente CHAR(2)
								,cd_Consecutivo VARCHAR(8)
								,id_TarjetasCredito INT
								,ds_tcnumber VARCHAR(16)
								,ds_tcautorizacion VARCHAR(25)/*rgelis 2014/03/04 req.18770*/
								,bl_GenerarSoloUnRCPorFP BIT /*rgelis 2016/07/15 req.32431*/
								,in_Fp INT
								,am_TarifaItem MONEY
								,am_IVAItem MONEY);
						--se consulta los recibos de caja de la factura y se inserta en la tabla para el transac 		
				
						INSERT INTO @RC_Transac(id_Fp, cd_FP, am_FP, cd_Cuenta, cd_Banco, cd_Plaza, cd_Fuente, cd_Serie, cd_TipoFac, ds_tcvoucher, in_Tipo, in_item, id_TarjetasCredito,ds_tcnumber,ds_tcautorizacion,bl_GenerarSoloUnRCPorFP,in_Fp, am_TarifaItem, am_IVAItem)/*rgelis 2014/03/04 req.18770*/ /*rgelis 2016/07/15 req.32431*/
						SELECT 
							id_Fp 
							, cd_FP
							, am_FP
							, cd_Cuenta
							, cd_Banco
							, cd_Plaza
							, cd_Fuente
							, cd_Serie
							, cd_TipoFac
							, ds_tcvoucher
							, in_Tipo
							, in_item
							, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							, right(rtrim(ltrim(ds_tcnumber)),4)
							, ds_tcautorizacion
							, bl_GenerarSoloUnRCPorFP /*rgelis 2016/07/15 req.32431*/
							, in_Fp = 1--ROW_NUMBER() OVER(PARTITION BY id_Fp ORDER BY id_Fp,id_TarjetasCredito)
							, am_TarifaItem
							, am_IVAItem
						FROM dbo.fnza_RCAutomaticoFPItems(@id_factura,null,CASE WHEN @bl_interface = 1 THEN 0 ELSE 1 END);

						UPDATE @RC_Transac
						SET cd_TipoFac = CASE 
							WHEN RTRIM(ISNULL(cd_TipoFac, '')) <> '' THEN cd_TipoFac
							WHEN EXISTS (SELECT 1 FROM dbo.FormasPago fp WHERE fp.id = id_Fp AND RTRIM(ISNULL(fp.id_MonedaContabilidad, '')) <> '') 
								THEN (SELECT TOP 1 RTRIM(fp.id_MonedaContabilidad) FROM dbo.FormasPago fp WHERE fp.id = id_Fp)
							ELSE 'EFE'
						END
						WHERE cd_TipoFac IS NULL OR RTRIM(cd_TipoFac) = '';
						

						
						--Retenciones en los RC
						Declare @MAxFileT_TC INT, @ContadorT_TC INT

						Declare @TTarjetasCreditoRCImpRet TABLE (Id Int Identity, id_TarjetasCredito	INT, am_fp	Money, 
						Id_CargosDesc INT, id_ImpRet	INT, cd_tipo INT, am_porcentaje	Numeric(18,4), 
						Id_cargo_dep	INT, Id_imp_dep	INT, am_TarifaItem Money, am_IVAItem Money, am_valor Money, cd_cuenta varchar(16), 
						id_fp INT, in_tipo INT, ds_tcnumber VARCHAR(16), ds_descripcion_item Varchar(40), cd_cencosto Varchar(16))
						
						INSERT INTO  @TTarjetasCreditoRCImpRet
						select 
							rct.id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							,am_fp
							, Id_CargosDesc = NULL
							, tc.id_ImpRet
							, cd_tipo
							, am_porcentaje
							, Id_cargo_dep
							, Id_imp_dep
							, am_TarifaItem
							, am_IVAItem
							, am_valor = 0
							, cd_cuenta = i.cd_cuenta
							, rct.id_fp, rct.in_tipo, rct.ds_tcnumber
							, ds_descripcion_item = left(i.ds_nombre,40)
							, cd_cencosto=NULL
						from @RC_Transac rct
						inner join TarjetasCreditoRCImpRet tc on tc.id_TarjetasCredito = rct.id_TarjetasCredito
						inner join ImpRet i on i.id = tc.id_ImpRet
						and id_Sucursales = @id_sucursal
						and isnull(id_Implantes,0) = isnull(@id_implante,0)
						
						UNION ALL

						select 
							rct.id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							,am_fp
							, Id_CargosDesc = 1
							, id_ImpRet = NULL
							, cd_tipo = 0
							, am_porcentaje = am_porcentaje_comision
							, Id_cargo_dep = NULL
							, Id_imp_dep = NULL
							, am_TarifaItem
							, am_IVAItem
							, am_valor = 0
							, cd_cuenta = tc.cd_cuenta
							, rct.id_fp, rct.in_tipo, rct.ds_tcnumber
							, ds_descripcion_item
							,cd_cencosto
						from @RC_Transac rct
						OUTER APPLY (
										Select top 1 tc.* ,cc.cd_cuenta, am_porcentaje_comision = cc.am_porcentaje, ds_descripcion_item = left(cc.ds_nombre,40),cd_cencosto
										From TarjetasCreditoRCImpRet tc 
										inner join ConceptoComisiones cc on cc.id = tc.id_ConceptoComisiones
										where tc.id_TarjetasCredito = rct.id_TarjetasCredito 						
										and id_Sucursales = @id_sucursal
										and isnull(id_Implantes,0) = isnull(@id_implante,0)
									) TC
						SET @MAxFileT_TC = @@ROWCOUNT
						Set @ContadorT_TC = 1
						If exists( Select * from @TTarjetasCreditoRCImpRet)
						Begin
							--Calculamos la comision
							Update @TTarjetasCreditoRCImpRet
							Set am_valor = round(am_TarifaItem * (am_porcentaje/100),0)
							Where Id_CargosDesc = 1
							
							--Calculamos los impuestos o retenciones que dependan de la tarifa
							Update t
							Set am_valor = round(t.am_TarifaItem * (t.am_porcentaje/100),0)
							From @TTarjetasCreditoRCImpRet t
							Where Id_cargo_dep = 1

							Update t
							Set am_valor = round(t.am_IVAItem * (t.am_porcentaje/100),0)
							From @TTarjetasCreditoRCImpRet t
							Where Id_imp_dep = 1


							While @ContadorT_TC < = @MAxFileT_TC
							Begin
								--Select 
								--	@Id_imp_depT_TC = Id_imp_dep
								--	,@Id_cargo_depT_TC = Id_cargo_dep
								--	,@id_TarjetasCreditoT_TC = id_TarjetasCredito
								--	,@am_fpT_TC = am_fp
								--From @TTarjetasCreditoRCImpRet Where Id = @ContadorT_TC

								Update t
								Set am_valor = round(tt.am_valor * (t.am_porcentaje/100),0)
								From @TTarjetasCreditoRCImpRet t
								Inner Join @TTarjetasCreditoRCImpRet tt on tt.id_TarjetasCredito = t.id_TarjetasCredito
																			AND tt.id_TarjetasCredito = t.id_TarjetasCredito	
																			AND tt.am_fp = t.am_fp
																			AND tt.Id_imp_dep = t.id_ImpRet
								Where t.Id = @ContadorT_TC and t.am_valor = 0
								set @ContadorT_TC = @ContadorT_TC + 1

							End

						End 
						
						--Select * From @TTarjetasCreditoRCImpRet
						--Select * From @RC_Transac

						Declare @RC_PagosCombinados TABLE (id int identity,id_Fp INT,in_tipo int,ds_tcnumber varchar(4)) /*Jramirez 2017/02/03 req.32431*/
						INSERT INTO @RC_PagosCombinados
						SELECT DISTINCT id_fp,in_tipo,ds_tcnumber from @RC_Transac

						Update rc
						Set rc.in_Fp = rcc.id
						From @RC_Transac rc
						Inner Join @RC_PagosCombinados rcc on rcc.id_fp = rc.id_fp and rcc.in_tipo = rc.in_tipo  and rcc.ds_tcnumber = rc.ds_tcnumber
						
						--se verifica que la factura tenga recibos de caja para generar
						IF EXISTS(SELECT * FROM @RC_Transac)
				
						BEGIN
					
							--se llena la tabla de recibos de caja para el document 
							INSERT INTO @RC_Document(id_Fp, cd_FP, am_FP, cd_Cuenta, cd_Banco, cd_Plaza, cd_Fuente,cd_Serie, cd_TipoFac, in_Tipo, id_TarjetasCredito, bl_GenerarSoloUnRCPorFP, in_FP)/*rgelis 2014/03/04 req.18770*/ /*rgelis 2016/07/15 req.32431*/
							SELECT 
								id_Fp 
								, cd_FP
								, SUM(am_FP) As 'am_FP' 
								, cd_Cuenta
								, cd_Banco
								, cd_Plaza
								, cd_Fuente
								, cd_Serie
								, cd_TipoFac
								, in_Tipo
								, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
								, bl_GenerarSoloUnRCPorFP /*rgelis 2016/07/15 req.32431*/
								, in_FP
							FROM @RC_Transac
							GROUP BY
								id_Fp 
								, cd_FP
								, cd_Cuenta
								, cd_Banco
								, cd_Plaza
								, cd_Fuente
								, cd_Serie
								, cd_TipoFac
								, in_Tipo
								, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
								, bl_GenerarSoloUnRCPorFP 
								, in_Fp/*rgelis 2016/07/15 req.32431*/

							--se inicializa las variables contabilizadoras de las tablas	
							SELECT @MAXRC_D=COUNT(*) FROM @RC_Document;
							SET @CONTRC_D=1;
							SET @id_FpRcAux=0
							
							--se recorre las tablas de recibos de caja para el document
							WHILE (@CONTRC_D<=@MAXRC_D) 
							BEGIN
								--se obtiene la serie,fuente,cuenta,total de recibo de caja configurada 
				
								SELECT  @cd_serieRC = cd_Serie
										,@cd_fuenteRC_F = cd_Fuente /*rgelis 2013/08/05 req.15991(CASE WHEN in_Tipo = 2 AND LTRIM(RTRIM(cd_FP))='TC' THEN @cd_fuenteRCOtr
																WHEN LTRIM(RTRIM(cd_FP))='TC' THEN @cd_fuenteRC
															ELSE cd_Fuente
															END)*/
										,@id_FpRc = id_Fp
										,@bl_GenerarSoloUnRCPorFP = bl_GenerarSoloUnRCPorFP	/*rgelis 2016/07/15 req.32431*/								 	 
								FROM @RC_Document WHERE id=@CONTRC_D;
								--se crea el consecutivo
	

								If IsNull(@cd_fuenteRC_F,'') = ''
								Begin
									SET @retval = 1
									Set @msg = 'No se ha definido la fuente para los recibos de caja.'

									If @@TRANCOUNT > 0
									Begin 
										ROLLBACK TRAN;	
									End 

									RAISERROR (@msg,16,127);
									RETURN @retval;
								End

								IF (@id_FpRc<>@id_FpRcAux OR @bl_GenerarSoloUnRCPorFP = 0)
								BEGIN
									EXEC @procret = dbo.spza_IncrementaConsecutivo_Contabilidad 
											'*'
											, @cd_fuenteRC_F
											, @cd_serieRC
											, 'I'
											, @cd_consecutivoRC OUT
											, @procmsgRC OUT;
						
									set @cd_consecutivoRC = right('00000000'+@cd_consecutivoRC,8);
			
									If (@procmsgRC <> '' or @procret <> 0) -- Proceso de incremento de consecutivo fallido				
									Begin 
										If @@TRANCOUNT > 0
										Begin 
											ROLLBACK TRAN;	
										End 
									
										Select @procmsgRC As 'Respuesta',
												1 AS 'Estado' ;
										RETURN 1 ;

									End
									SET @id_FpRcAux = @id_FpRc	
								END
								-- se actualiza la tabla del document con las fuentes y los consecutivos creados
								UPDATE @RC_Document
								SET cd_Fuente = @cd_fuenteRC_F
									,cd_Consecutivo = @cd_consecutivoRC
								WHERE id=@CONTRC_D;
							   
								SET @CONTRC_D = @CONTRC_D + 1;   
							END
							
							/*inicio rgelis 2013/11/13 req.17600*/
							--se valida que las cuEntas para los recibos de caja solo sean de caja o de banco
							SET @procmsgRC='';
							SELECT @procmsgRC = @procmsgRC + RTRIM(CODICTA) + ','  
							FROM (SELECT M.CODICTA  
									FROM @RC_Transac As Rc 
									 INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta
									WHERE M.INDCPICTA NOT IN('1','6') OR (M.INDCPICTA = '1' AND M.IDBANCO IS NULL)
								) AS Tc
							GROUP BY CODICTA 
							IF LEN(@procmsgRC)>0
							BEGIN
								SET @procmsgRC = substring(@procmsgRC,1,len(@procmsgRC)-1)
							END 			 
							IF (@procmsgRC <> '')		  	  
							Begin 
								Select 'Las Cuentas : '+ @procmsgRC +' que fueron Configuradas para la creacion de recibos de caja automático no son de caja ni de banco ' AS 'Respuesta', 1 AS 'Estado'
								ROLLBACK TRAN;
								RETURN 1 ;
							End
							/*fin rgelis 2013/11/13 req.17600*/	
							-- se actualiza la tabla del Transac con las fuentes y los consecutivos creados 
							UPDATE T 
							SET T.cd_Fuente=D.cd_Fuente
								,T.cd_Consecutivo=D.cd_Consecutivo
							FROM @RC_Transac As T
								INNER JOIN @RC_Document As D ON D.id_FP=T.id_FP AND D.cd_FP=T.cd_FP And D.in_Tipo=T.in_Tipo And D.cd_TipoFac=T.cd_TipoFac And D.in_FP=T.in_FP ;/*rgelis 2017/05/09 req.49675*//*rgelis 2013/02/26 req.12870*/
							-- se inserta en el document las cabeceras de los recibos de caja 
					
					 
							Insert Into dbo.Document_AGEMIN 
								(
									SPID,
									ANODCTO,
									FNTEDCTO,
									NUMEDCTO,
									FECHDCTO,
									NUMTDCTO,
									SUDBDCTO,
									SUCRDCTO,
									DESCDCTO,
									IDTERCERO,
									IDCLIPRV,
									CBADCTO,
									BU
								)
							SELECT 		
									@@SPID,			
									@anomes,
									cd_Fuente,
									cd_Serie+cd_Consecutivo,
									@fechadoc,
									-1,
									SUM(am_Fp),
									SUM(am_Fp),
									LEFT('Cancelación de Factura: '+ @numdoctra,40),
									@idtercero,
									@idcliente,
									'' AS cd_Cuenta, /*rgelis 2016/07/15 req.32431*/
									@Bu
							FROM @RC_Document
							GROUP BY cd_Fuente,cd_Serie,cd_Consecutivo;/*rgelis 2016/07/15 req.32431*/
					
							-- se inserta en el transac las carteras de los recibos de caja 
					
							Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									anotra,
									idfuente,
									numdoctra,
									fechatra,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									idvEnde,
									tipofac,
									numefac,
									vencefac,
									idusuario,
									cliprv,
									fechafact,
									BU,
									REFEFAC
								)
							Select 
									@@SPID,
									@anomes,
									Cd_Fuente													AS 'IDFUENTE',
									Cd_Serie+cd_consecutivo										AS 'NUMDOCTRA',
									@fechadoc													AS 'FECHATRA',
									Case When IsNull(Fp.Cd_cuenta,'') <> '' Then Fp.Cd_cuenta Else @ctacartera End AS 'CODICTA',
									Case When IsNull(Fp.cd_Tercero,'') <> '' Then Fp.cd_Tercero Else @idtercero End AS 'NITTRA',
									LEFT('Cancelación de Factura: '+ @numdoctra,40)				AS 'DESCRITRA',
									(am_FP)*-1													AS 'VALORTRA',
									'2'															AS 'INDCPITRA',
									@idvEnde													AS 'IDVEndE',
									@TipoDocumento												AS 'TIPOFAC',
									--@NUMDOCTRA													AS 'NUMEFAC',
									@numefac													AS 'NUMEFAC',
									@vencefac													AS 'VENCEFAC',
									'Zeus Agencia Mn'											AS 'IDUSUARIO',
									@idcliente													AS 'CLIPRV',
									@fechadoc													AS 'FECHAFACT',
									@Bu															AS 'BU',
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END
							From @RC_Document 
							Inner Join FormasPago FP on fp.Id = id_Fp ; --Esto es para utilizar la CtaCxC general o de la FP
					
							-- se inserta en el transac los tkt, el tao y los servicios de los recibos de caja 
							If NOT exists( Select * from @TTarjetasCreditoRCImpRet)
							Begin
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Cancelación de Factura: '+ @numdoctra,40)					AS 'DESCRITRA',
										am_FP															AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher
											 ELSE @numefac END											AS 'NUMEFAC', 
											 --Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + ds_tcnumber,25) ELSE '' END 
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	  
							End
							Else
							Begin
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Cancelación de Factura: '+ @numdoctra ,40)					AS 'DESCRITRA',
										am_FP - am_valor													AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher
											 ELSE @numefac END											AS 'NUMEFAC',	 
											 --Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + rc.ds_tcnumber,25) ELSE '' END 
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
									INNER JOIN (	Select 
													id_fp, in_tipo, ds_tcnumber, am_valor = sum(isnull(am_valor,0)) 
													from @TTarjetasCreditoRCImpRet 
													group by id_fp, in_tipo, ds_tcnumber) tt 
											on tt.id_fp = rc.id_fp
											AND tt.in_tipo = rc.in_tipo
											AND tt.ds_tcnumber = rc.ds_tcnumber
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	  
								
								--registro de Comisiones - impuestos y retenciones
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC,
										IDCENCO
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										tt.cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Pago Factura: '+ @numdoctra + ' - ' + ds_descripcion_item,40)					AS 'DESCRITRA',
										am_valor													AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher 
											 Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + rc.ds_tcnumber,25) ELSE '' END ,
										cd_cencosto
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
									INNER JOIN (	Select 
													id_fp, in_tipo, ds_tcnumber, am_valor, cd_cuenta,  ds_descripcion_item, cd_cencosto
													from @TTarjetasCreditoRCImpRet ) tt 
													--group by id_fp, in_tipo, ds_tcnumber
											on tt.id_fp = rc.id_fp
											AND tt.in_tipo = rc.in_tipo
											AND tt.ds_tcnumber = rc.ds_tcnumber
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	 
								--select * from Transac_AGEMIN where SpId=@@SPID and idfuente='01'
							End
					
						END
								
						INSERT INTO dbo.Fac_RecibosCaja (id_fac_factura,id_fac_remision,id_FormaPago,cd_Fuente,cd_Serie,cd_Consecutivo,in_Tipo,am_valor,id_TarjetasCredito)/*rgelis 2014/03/04 req.18770*/
						SELECT @id_factura
								,NULL
								,id_FP
								,cd_Fuente
								,cd_Serie
								,cd_Consecutivo
								,in_Tipo
								,SUM(am_FP) AS 'am_FP'
								,id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
						FROM @RC_Document
						GROUP BY id_FP,cd_Fuente,cd_Serie,cd_Consecutivo,in_Tipo,id_TarjetasCredito;

						  /*inicio rgelis 2014/03/04 req.18770*/
						Set @Retval = 0


						Exec @Retval = dbo.spza_FacRecibosCajaTCPropia_Contabilizar @id_usuario=@id_usuario,@id_factura=@id_factura,@id_remision=NULL,@ctacartera=@ctacartera,@msg = @procmsg OUTPUT,@bl_Contabilizar=0

						IF (@Retval <> 0 ) -- Proceso fallido
						BEGIN
							IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK TRAN;
							END
		    
							raiserror( @procmsg,16,1)		    
		    

							IF (@bl_af = 1) --Se debe auditar proceso fallido
								BEGIN
									EXEC dbo.spzaAuditoria_Insertar @id_proceso = @idproce    ,
										@id_usuario = @id_usuario ,
										@cd_status  = 1           ,
										@admsg      = @procmsg       ;
								END
    

							RETURN 1 ;
						END
						/*inicio rgelis 2014/03/04 req.18770*/
								
						Insert Into dbo.Document_Insertar 
						Select  D.* From dbo.document_agemin As D  
						Where d.SpId = @@spid 
						And D.FNTEDCTO+D.NUMEDCTO in (SELECT cd_Fuente+cd_Serie+cd_Consecutivo FROM @RC_Document)		
					
						Insert Into dbo.Transac_Insertar
						Select  T.* From dbo.Transac_AGEMIN As T 
						Where t.SpId = @@spid
						and isnull(VALORTRA,0)<>0
						And t.IDFUENTE+t.NUMDOCTRA in (SELECT cd_Fuente+cd_Serie+cd_Consecutivo FROM @RC_Transac)			
				
					End 
			
					/*fin rgelis 2012/10/11 req.10814*/	
				END
				------------------------------------------------------------------------------------------
				--9) Actualizando Statustra, valor moneda y tasacambio a los registros de cuentas que manejan moneda y no tienen estado 'AJ'
				-- el estado 'AJ' causa que el validador de movimientos contables omita la comprobacion de 
				-- los registros de transacciones que tienen cuentas que manejan moneda.
				Declare @monedaLocal char(3), @MonedaEquivalente VARCHAR(3)
				SELECT @monedaLocal = valor From parametros Where id=10;
				SELECT @MonedaEquivalente = id_monedaContabilidad FROM dbo.Monedas_IATA where cd_codigo = @moneda

				If @moneda <> @monedaLocal and @moneda is not null and @moneda <> ''
				Begin
					IF EXISTS(
								SELECT *
								FROM Transac_AGEMIN
								INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
								Where 
									SpId = @@SPID 
									AND Valortra is not null 
									AND valortra <> 0 
									AND ISNULL(MAECONT.IDMONEDA,'') <> ''
								
									AND maecont.indcpicta='3'
							) and ISnull(@MonedaEquivalente,'') = ''
					BEGIN
						SET @retval = 1
						Set @msg = 'No se ha definido la moneda equivalante para la moneda: '  + @moneda + char(13) +  'Por favor en el maestro de monedas coloque esta información.'

						IF @@TRANCOUNT > 0
						BEGIN 
							ROLLBACK TRAN;	
						END 

						RAISERROR (@msg,16,127);
						RETURN @retval;					

					END 

					IF EXISTS(
								SELECT *
								FROM Transac_AGEMIN
								INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
								Where 
									SpId = @@SPID 
									AND Valortra is not null 
									AND valortra <> 0 
									AND ISNULL(MAECONT.IDMONEDA,'') <> ''
									AND MAECONT.IDMONEDA <> @MonedaEquivalente
									AND maecont.indcpicta='3'
							)
					BEGIN
						SET @retval = 1

						SELECT DISTINCT @msg = isnull(@msg,'') + 'Las cuenta de Proveedores parametrizada tienen diferente moneda a la moneda de la factura. Cuenta: ' + isnull(MAECONT.codicta,'') + char(13)
						FROM Transac_AGEMIN
						INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
						Where 
							SpId = @@SPID 
							AND Valortra is not null 
							AND valortra <> 0 
							AND ISNULL(MAECONT.IDMONEDA,'') <> ''
							AND MAECONT.IDMONEDA <> @MonedaEquivalente
							AND maecont.indcpicta='3'

						IF @@TRANCOUNT > 0
						BEGIN 
							ROLLBACK TRAN;	
						END 

						RAISERROR (@msg,16,127);
						RETURN @retval;		
					END 
				
					Update dbo.Transac_AGEMIN SET 
						valormoneda = case when DESCRITRA NOT LIKE '%ajuste%moneda%' then dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,0) else valormoneda end,	
						tasacambio  =  dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,1) 
					Where SpId = @@SPID and Valortra is not null and valortra <> 0  --SpId = @@SPID AND STATUSTRA <> 'AJ' AND TasaCambio <> 0 AND VALORMONEDA <>0; 		
				
					Update dbo.Transac_Insertar SET 
						valormoneda = case when DESCRITRA NOT LIKE '%ajuste%moneda%' then  dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,0) else valormoneda end,	
						tasacambio  = dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,1) 
					Where SpId = @@SPID and Valortra is not null and valortra <> 0 AND ISNULL(valormoneda,0) = 0				
				End 
				
				
				Insert Into dbo.Transac_Insertar
				Select  * From dbo.Transac_AGEMIN Where IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0 AND SpId=@@spid;		
				
									
				
				-------------------------------------------------------------------------------------------------------------
				--Contabilizacion Causación CxP servicio de tercero


				Update dbo.Transac_AGEMIN SET 
						anotra 	 	= @anomes,
						--idfuente 	= @fuente,
						--numdoctra	= @numdoctra,
						fechatra	= @fechadoc,
						idvEnde		= @idvEnde,
						idusuario	= 'Zeus Agencia Mn',
						fechafact	= @fechadoc,					
						indcpitra	= dbo.fnza_GetTipoCuenta(codicta)
					Where SpId = @@SPID AND IDFUENTE = @fteCausacionCxPSrv3ros And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros; 		

				Update dbo.Transac_AGEMIN 
				SET BU = @Bu
				Where SpId = @@SPID AND (BU IS NULL OR BU = '') AND IDFUENTE = @fteCausacionCxPSrv3ros And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros; 

				Insert Into dbo.Transac_Insertar
				Select  * From dbo.Transac_AGEMIN Where IDFUENTE = @fteCausacionCxPSrv3ros 
				And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros AND VALORTRA <> 0 AND SpId=@@spid;						

				Update fac_Factura
				set
					cd_fuente_NCausacionSrvTer				= @fteCausacionCxPSrv3ros
					,cd_serie_NCausacionSrvTer				= @sreCausacionCxPSrv3ros
					,cd_consecutivo_NCausacionSrvTer		= @cscutvoCausacionCxPSrv3ros
				Where id = @id_factura

				--Select  * From dbo.Transac_AGEMIN Where SpId=@@spid AND VALORTRA <> 0
				--Contabilizacion Causación CxP servicio de tercero
				-------------------------------------------------------------------------------------------------------------

				--Select  * From dbo.Transac_AGEMIN WHERE SpId=@@spid ORDER BY NUMDOCTRA
				------------------------------------------------------------------------------------------
				-- Inicio Debug

	
				--Select  * From dbo.Document_Insertar Where SpId=@@spid;--DEBUG	
				--Select  * From dbo.Transac_Insertar Where SpId=@@spid;--DEBUG		
				--Factura
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0;--DEBUG		
				--Rc Tkt
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @cd_fuenteRC And NUMDOCTRA = @cd_serieRC+@cd_consecutivoRC AND VALORTRA <> 0; --DEBUG
				--RC otro		
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @cd_fuenteRCOtr And NUMDOCTRA = @cd_serieRCOtr+@cd_consecutivoRCOtr AND VALORTRA <> 0; --DEBUG
				-- Fin Debug			
			
				------------------------------------------------------------------------------------------
				-- Actualizamos el NFC
				------------------------------------------------------------------------------------------
				Update	Transac_Insertar
				Set	Transac_Insertar.NCF		= @NCF
				From dbo.Transac_Insertar Inner Join Maecont On Transac_Insertar.Codicta=Maecont.Codicta
				Where Maecont.IndNcf = 1
					And	Transac_Insertar.SpId = @@SpId
				------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------

				------Este Sp se encarga de realizar la contabilizacion NIIF
		   		SELECT @ERRORCONT=1			
				EXEC @ERRORCONT = dbo.Spza_NIIF_Contabilizar 
				IF @ERRORCONT<>0 
				BEGIN 
					IF @@TRANCOUNT > 0 
					BEGIN 
						ROLLBACK TRAN ;		
					END
					--Determinando si se debe auditar el proceso fallido
					IF (@bl_af = 1) 
					BEGIN 			
						EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
														 @id_usuario = @id_usuario ,
														 @cd_status  = 0           , 												 
														 @admsg      = ' Ocurrio un error generando la Contabilización NIIF',
								 						 @msgparams  = NULL;
					END 			 		
					RAISERROR ('Ocurrio un error generando la Contabilización NIIF',16,125);
					RETURN @ERRORCONT; 
				END

				Update dbo.Transac_Insertar SET 				
				Id_Movimiento = ISNULL(Id_Movimiento,''),statustra = ISNULL(statustra,'XA') 
				Where SpId = @@SPID 

				Select @ERRORCONT=1			
				EXEC @ERRORCONT=dbo.spInsertarDatosEnContabilidad @SoloValidarSinInsertar='S',
							   @ActualizacionEnLinea='S',
							   @DevolverLoteDeErrores='N',
							   @MostrarMensajesDeError='S',
							   @ValidarCuadre = 'S',
							   @AgruparRegistrosIguales = 'S',
							   @Aplicacion= 'Agencia Minorista SQL',
							   @TiposDeMensajes = 'G'
			
				If @ERRORCONT<>0 
				Begin 
   	        		If @@TRANCOUNT > 0 
   	        		Begin 
   	        			ROLLBACK TRAN ; 
   	        		End 
					--Determinando si se debe auditar el proceso exitoso
					If (@bl_af = 1) 
					Begin 											   	        	
						EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
														 @id_usuario = @id_usuario ,
														 @cd_status  = 0           , 												 
														 @admsg      = NULL,
								 						 @msgparams  = @Numdoc;
					End 			 		
					--Select 'Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles' AS 'Respuesta', 1 AS 'Estado'
					RAISERROR ('Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles',16,124);
					RETURN @ERRORCONT; 
				End
				Else 
				Begin 
					EXEC @ERRORCONT=dbo.spInsertarDatosEnContabilidad @SoloValidarSinInsertar='N',
					   @ActualizacionEnLinea='S',
					   @DevolverLoteDeErrores='N',
					   @MostrarMensajesDeError='N',
					   @ValidarCuadre = 'S',
					   @AgruparRegistrosIguales = 'S',
					   @Aplicacion= 'Agencia Minorista SQL',
					   @TiposDeMensajes = 'G'

					If @ERRORCONT<>0 
					Begin 
					
	   	        		If @@TRANCOUNT > 0 
	   	        		Begin 
	   	        			ROLLBACK TRAN ; 
	   	        		End 
	   	        	
						--If (@bl_af = 1) 
						--Begin 										
						--	EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
						--									 @id_usuario = @id_usuario ,
						--									 @cd_status  = 1           , 												 
						--									 @admsg      = NULL,
						--			 						 @msgparams  = @Numdoc;
						--End 	
						--Select 'Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles' AS 'Respuesta', 1 AS 'Estado'
						RAISERROR ('Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles',16,124);
						RETURN @ERRORCONT; 
					End
				
					--Registrando formas de pago para ecibos de caja
					Declare @FormaPagoStr VARCHAR(max);
					EXEC dbo.spza_ExportarFormasPagoRC
						@id_factura = @id_factura,
						@FormaPagoStr = @FormaPagoStr OUTPUT 	
				
					--Insertando la forma de pago
					Insert Into dbo.FormaPago_Age
							(
								fuente,
								documento,
								cuenta,
								cliente,
								tipofac,
								numefac,
								vencefac,
								refefac,
								FormaPago
							)
						VALUES 
							(
								@fuente,
								@numdoctra,
								@ctacartera,
								@idcliente,
								@TipoDocumento,
								@numefac,--@numdoctra,
								@vencefac,
								'',
								LEFT(RTRIM(@FormaPagoStr),1519)
							);
				
					--Asignar Archivo Fisico--
					If @CodigoArchivoFisico IS NOT NULL and  @CodigoArchivoFisico <> ''
					Begin
					EXEC Dbo.SpArchivoFisico_Documentos 	@operacion = 'I'
															,@fuente = @fuente
															,@Documento = @numdoctra
															,@CodigoArchivoFisico = @CodigoArchivoFisico
												
					End
					--Fin Archivo Fisico--
					EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
													 @id_usuario = @id_usuario ,
													 @cd_status  = 1           , 												 
													 @admsg      = NULL,
								 					 @msgparams  = @Numdoc;
				
				
				End
			END	 
			--------------------------------------------------------------------------			
			IF @bl_mostrarmsg = 1 --inicio rgelis 2018/12/11 req.74447
			BEGIN								 		 
				IF EXISTS(SELECT * FROM dbo.Transac_Insertar WHERE IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0 AND SPID = @@SPID)
					SELECT 'La factura fue contabilizada satisfactoriamente' AS 'Respuesta', 1 AS 'Estado';
				ELSE IF @bl_nocont = 1
					SELECT 'La factura no se puede contabilizar, Tiene la bandera "no contabilizar" activa' AS 'Respuesta', 0 AS 'Estado';
			END --inicio rgelis 2018/12/11 req.74447
			UPDATE dbo.fac_factura SET cd_ctacartera=@ctacartera WHERE id=@id_factura --rgelis 2019/08/08 req.92012
 		 	--Si la transaccion fue creada en el procedimiento entonces se actualiza--
 		 	If (XACT_STATE() <> 0) and (@@TRANCOUNT > 0) 
	   	    Begin 
				COMMIT TRAN;	
			End 
			set @retval = 0;
			RETURN @retval;
	 End TRY 
		--Endregion
    	
		--region: Bloque CATCH (Manejo de excepciones)
    	Begin CATCH 
 			--Error de duplicado--
			If error_number()= 2601
 			Begin 
 				SET @msg =  'No se pudo crear la Factura. Ya existe';
      			SET @retval = 1
	   	       
	   	       If @@TRANCOUNT > 0 
	           Begin 
	           		ROLLBACK TRAN ; 
	           End
	   	       
	   	        RAISERROR (@msg,16,124);
	   	      	--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce ,
													 			 @id_usuario = @id_usuario ,
													 			 @cd_status  = 0      ,
													 			 @msgparams  = @Numdoc, 
													 			 @admsg      = @msg	   ;				
	   	        RETURN @retval;
		    End
		    
 			-- Tiempo de espera alcanzado --
		    If ERROR_NUMBER() = 1222
		    Begin
      			SET @msg =  'No se pudo ejecutar el proceso. Tiempo de espera agotado.';
      			SET @retval = 1
	   	        
	   	        If @@TRANCOUNT > 0 
   	        	Begin 
   	        		ROLLBACK TRAN ; 
   	        	End
   	        	
	   	        RAISERROR (@msg,16,125);
	   	       	--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce ,
													 			 @id_usuario = @id_usuario ,
													 			 @cd_status  = 0           ,
													 			 @msgparams  = @Numdoc,
													 			 @admsg      = @msg	   ;				
	   	        RETURN @retval;
		    End
		    
		    -- Registro bloqueado / Conflicto de actualizacion
		    Else If ERROR_NUMBER() IN (1205, 3960)
    		Begin
    			If @@TRANCOUNT > 0 
   	        	Begin 
   	        		ROLLBACK TRAN ; 
   	        	End 
	   	        
		       	SET @retry     = 1              ;
		       	SET @retrycont = @retrycont + 1 ; 

	    	 End
	    	 Else
		     Begin
		     	-- Error no manejado --			   	   	        
   	        	If @@TRANCOUNT > 0 
   	      		Begin 
   	        		ROLLBACK TRAN ; 
   	        	End
						
				SET @retval = 1;
 				SET @msg =	'Ha ocurrido un error. Información para soporte tecnico:'			+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						    'Numero: ' + isnull(CAST(ERROR_NUMBER()   AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Mensaje: ' + isnull(ERROR_MESSAGE(),'') 					   		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						 	'Severidad: ' + isnull(CAST(ERROR_SEVERITY() AS VARCHAR(10)),'') 	+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						 	'Estado: ' + isnull(CAST(ERROR_STATE()    AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Procedimiento: ' + isnull(ERROR_PROCEDURE(),'')					+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Linea: ' + isnull(CAST(ERROR_LINE() 	   AS VARCHAR(10)),''); 							
	
				RAISERROR (@msg,16,126);
				--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar	@id_proceso = @idproce   ,
										 			 			@id_usuario = @id_usuario ,
										 			 			@cd_status  = 0           ,
										 			 			@msgparams  = @Numdoc, 
										 			 			@admsg      = @msg	  ;				
				RETURN @retval;
		     End
		End CATCH  
	   --Endregion
	End 
	
	--region: Manejo de reintentos
	If (@retrycont>@maxretries) 
	Begin 
		SET @retval = 1
		SET @msg = 'No se pudo finalizar el proceso. Maximo numero de reintentos alcanzado.'
		--Se debe auditar proceso fallido
		If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
											 			 @id_usuario = @id_usuario ,
											 			 @cd_status  = 0           ,
											 			 @msgparams  = @Numdoc, 
											 			 @admsg      = @msg	   ;												 	   					   
  		RAISERROR (@msg,16,127);
  		RETURN @retval;
  	End   	
    --Endregion
    RETURN @retval;
End

GO


PRINT 'Procedimientos almacenados y funciones T-SQL compiladas exitosamente.';


GO
