const mssql = require('mssql');
require('dotenv').config();

function parseSQLServerUrl(connStr) {
    let clean = connStr.replace(/^(sqlserver|mssql):\/\//i, '');
    let hostPortPart = clean.split(';')[0];
    let host = hostPortPart.split(':')[0] || '127.0.0.1';
    let portStr = hostPortPart.split(':')[1] || '';

    let instanceName = undefined;
    if (host.includes('\\')) {
        const parts = host.split('\\');
        host = parts[0];
        instanceName = parts[1];
    }
    if (host.toLowerCase() === 'localhost') host = '127.0.0.1';

    let database = '';
    let user = '';
    let password = '';

    const params = clean.split(';');
    for (const p of params) {
        const eqIdx = p.indexOf('=');
        if (eqIdx > 0) {
            const key = p.substring(0, eqIdx).trim().toLowerCase();
            const val = decodeURIComponent(p.substring(eqIdx + 1).trim());
            if (key === 'database') database = val;
            else if (key === 'user' || key === 'user id' || key === 'uid') user = val;
            else if (key === 'password' || key === 'pwd') password = val;
        }
    }

    return {
        servidor: instanceName ? `${host}\\${instanceName}` : host,
        usuario: user,
        clave: password,
        base_datos: database,
        puerto: portStr
    };
}

async function run() {
    const sqlUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;
    const configRow = parseSQLServerUrl(sqlUrl);
    
    let host = configRow.servidor;
    let instanceName;
    if (host.includes('\\')) {
        const parts = host.split('\\');
        host = parts[0];
        instanceName = parts[1];
    }
    if (host.toLowerCase() === 'localhost') host = '127.0.0.1';

    const sqlConfig = {
        user: configRow.usuario,
        password: configRow.clave,
        server: host,
        database: configRow.base_datos,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true
        },
        connectionTimeout: 20000,
        requestTimeout: 60000
    };
    if (configRow.puerto) sqlConfig.port = parseInt(configRow.puerto, 10);
    else if (instanceName) sqlConfig.options.instanceName = instanceName;
    else sqlConfig.port = 1433;

    console.log("Conectando a SQL Server:", host, sqlConfig.database);
    const pool = await mssql.connect(sqlConfig);

    await pool.request().query(`
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

        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'NUEVO')
            INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive]) VALUES (N'NUEVO', N'Nuevo', N'blue', 1);

        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'ENVIADO')
            INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive]) VALUES (N'ENVIADO', N'ENVIADO', N'emerald', 1);
    `);

    console.log("¡Tabla dbo.[QuotationState] y semillas aplicadas con éxito en SQL Server!");
    await pool.close();
}

run().catch(console.error);
