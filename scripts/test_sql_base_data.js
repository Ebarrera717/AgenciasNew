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
    console.log("SQL URL:", sqlUrl);
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
    
    const queries = [
        ['Provider', 'SELECT * FROM dbo.[Provider] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Prestadora', 'SELECT * FROM dbo.[Prestadora] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Branch', 'SELECT * FROM dbo.[Branch] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Implant', 'SELECT [id], [code], [name], [branchId] FROM dbo.[Implant] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Product', 'SELECT * FROM dbo.[Product] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['ChargeAndTax', 'SELECT * FROM dbo.[ChargeAndTax] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Seller', 'SELECT * FROM dbo.[Seller] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['TicketPrinter', 'SELECT * FROM dbo.[TicketPrinter] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['MasterVariable', 'SELECT * FROM dbo.[MasterVariable] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Currency', 'SELECT * FROM dbo.[Currency] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['CreditCard', 'SELECT * FROM dbo.[CreditCard] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['Payment', 'SELECT * FROM dbo.[Payment] WHERE [isActive] = 1 OR [isActive] IS NULL'],
        ['QuotationState', 'SELECT * FROM dbo.[QuotationState] ORDER BY [id] ASC'],
        ['SystemParameter', 'SELECT * FROM dbo.[SystemParameter]'],
        ['Cities', 'SELECT * FROM dbo.[Cities]']
    ];

    for (const [name, q] of queries) {
        try {
            const res = await pool.request().query(q);
            console.log(`[OK] ${name}: ${res.recordset.length} filas`);
        } catch (err) {
            console.error(`[ERROR] ${name}:`, err.message);
        }
    }

    await pool.close();
}

run().catch(console.error);
