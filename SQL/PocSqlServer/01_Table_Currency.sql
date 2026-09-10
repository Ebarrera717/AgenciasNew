-- ============================================================================
-- PRUEBA DE CONCEPTO (PoC) MIGRACION SQL SERVER - AGENCIASNEW
-- Archivo: 01_Table_Currency.sql
-- Motor: Microsoft SQL Server (T-SQL)
-- ============================================================================

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
    PRINT 'Tabla dbo.Currency creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'Tabla dbo.Currency ya existe.';
END;
