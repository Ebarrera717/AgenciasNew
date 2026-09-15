const { Pool } = require('pg');
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
    console.log("=== REINICIANDO TABLAS Y SECUENCIAS DE COTIZACIONES EN POSTGRESQL ===");
    const pgUrl = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const pgPool = new Pool({ connectionString: pgUrl });
    const pgClient = await pgPool.connect();

    try {
        const tables = [
            'QuotationProductPayment', 'QuotationProductTax', 'QuotationProductVariable', 
            'QuotationProductPassenger', 'QuotationProduct', 'QuotationStateHistory', 
            'QuotationCombo', 'QuotationManualService', 'QuotationAttachment', 'Quotation'
        ];
        for (const tbl of tables) {
            await pgClient.query(`TRUNCATE TABLE public."${tbl}" CASCADE;`).catch(() => {});
        }
        await pgClient.query(`ALTER SEQUENCE IF EXISTS public."Quotation_id_seq" RESTART WITH 1;`).catch(() => {});
        console.log("[OK] Postgres: Cotizaciones truncadas y secuencia resetiada a 1.");
    } catch (err) {
        console.error("[ERROR] Postgres reset:", err.message);
    } finally {
        pgClient.release();
        await pgPool.end();
    }

    console.log("\n=== REINICIANDO TABLAS Y SECUENCIAS EN SQL SERVER ===");
    try {
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
            options: { encrypt: false, trustServerCertificate: true, enableArithAbort: true },
            connectionTimeout: 20000,
            requestTimeout: 60000
        };
        if (configRow.puerto) sqlConfig.port = parseInt(configRow.puerto, 10);
        else if (instanceName) sqlConfig.options.instanceName = instanceName;
        else sqlConfig.port = 1433;

        const sqlPool = await mssql.connect(sqlConfig);

        await sqlPool.request().query(`
            IF OBJECT_ID('dbo.Quotation', 'U') IS NOT NULL
            BEGIN
                DELETE FROM dbo.[Quotation];
                DBCC CHECKIDENT ('dbo.Quotation', RESEED, 0);
            END;

            IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
            BEGIN
                UPDATE dbo.[TransactionConsecutive] SET [currentNumber] = 1 WHERE [transactionType] = 'QUOTATION' OR [transactionType] = 'COTIZACION';
            END;

            IF OBJECT_ID('dbo.SysConsecutivo', 'U') IS NOT NULL
            BEGIN
                UPDATE dbo.[SysConsecutivo] SET [consecutivo] = 1 WHERE [codigo] = 'QUOTATION' OR [codigo] = 'COTIZACION';
            END;
        `);
        console.log("[OK] SQL Server: Cotizaciones eliminadas y consecutivos reiniciados.");
        await sqlPool.close();
    } catch (err) {
        console.error("[ERROR] SQL Server reset:", err.message);
    }
}

run().catch(console.error);
