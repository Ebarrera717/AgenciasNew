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
        [ds_nombre] VARCHAR(250) NULL
    );
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

