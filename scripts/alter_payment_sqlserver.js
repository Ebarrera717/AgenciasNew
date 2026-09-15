const mssql = require('mssql');

const config = {
    user: process.env.SQLSERVER_USER || 'zeusagencias',
    password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
    server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
    database: process.env.SQLSERVER_DB || 'Korex_Pruebas',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

async function main() {
    try {
        console.log('Conectando a SQL Server para alterar dbo.Payment:', config.server, config.database);
        const pool = await mssql.connect(config);

        await pool.request().query(`
            IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Payment') AND name = 'isCash')
            BEGIN
                ALTER TABLE dbo.[Payment] ADD [isCash] BIT NOT NULL CONSTRAINT DF_Payment_IsCash DEFAULT 0;
                PRINT 'Columna isCash agregada';
            END;

            IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Payment') AND name = 'isCredit')
            BEGIN
                ALTER TABLE dbo.[Payment] ADD [isCredit] BIT NOT NULL CONSTRAINT DF_Payment_IsCredit DEFAULT 0;
                PRINT 'Columna isCredit agregada';
            END;
        `);

        console.log('¡Columnas isCash e isCredit garantizadas en SQL Server dbo.Payment!');
        await pool.close();
    } catch (e) {
        console.error('Error alterando dbo.Payment:', e);
    }
}

main();
