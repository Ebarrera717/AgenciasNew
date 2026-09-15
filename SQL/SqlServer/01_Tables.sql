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
        [isActive] BIT NOT NULL CONSTRAINT DF_TransactionConsecutive_IsActive DEFAULT 1
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

PRINT 'Tablas de la base de datos SQL Server estructuradas exitosamente.';
