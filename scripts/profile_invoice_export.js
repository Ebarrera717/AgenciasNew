const path = require('path');
const mssql = require('mssql');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

function getSqlServerConfig(targetDbName) {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = targetDbName || 'Korex_pruebas';
    let defaultPort = 1433;
    let instanceName = undefined;

    const host = process.env.SQLSERVER_HOST || defaultHost;
    const user = process.env.SQLSERVER_USER || defaultUser;
    const password = process.env.SQLSERVER_PASSWORD || defaultPass;
    const database = targetDbName || defaultDb;
    const port = process.env.SQLSERVER_PORT ? parseInt(process.env.SQLSERVER_PORT, 10) : defaultPort;

    return {
        user,
        password,
        server: host,
        database,
        port,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true,
            requestTimeout: 120000
        }
    };
}

async function run() {
    console.log('Connecting to Korex_pruebas...');
    const korexPool = await mssql.connect(getSqlServerConfig('Korex_pruebas'));
    const topInvoices = await korexPool.request().query('SELECT TOP 10 id, internalNumber, state, zeusInvoiceNumber FROM dbo.Invoices ORDER BY id DESC');
    console.log('Top 10 Invoices in Korex_pruebas:', topInvoices.recordset);
    
    // Test spExportInvoices
    const ids = topInvoices.recordset.map(r => r.id).join(',');
    console.log(`Generating XML for invoices ${ids}...`);
    const t0 = Date.now();
    const expReq = korexPool.request();
    expReq.input('Envoices_id', mssql.VarChar(mssql.MAX), ids);
    expReq.input('User_id', mssql.Int, 1);
    const expRes = await expReq.execute('dbo.spExportInvoices');
    const t1 = Date.now();
    console.log(`spExportInvoices finished in ${t1 - t0}ms`);
    
    const xml = expRes.recordset[0]?.mensaje_resultado || expRes.recordset[0]?.xml || '';
    console.log(`XML length: ${xml.length}`);
    await korexPool.close();

    // Now connect to ZeusAgencias_23 and benchmark spFacturacionesCrear
    console.log('Connecting to ZeusAgencias_23...');
    const zeusPool = await mssql.connect(getSqlServerConfig('ZeusAgencias_23'));
    
    console.log('Executing spFacturacionesCrear in ZeusAgencias_23...');
    const t2 = Date.now();
    const facReq = zeusPool.request();
    facReq.input('xml', mssql.VarChar(mssql.MAX), xml);
    const facRes = await facReq.execute('dbo.spFacturacionesCrear');
    const t3 = Date.now();
    console.log(`spFacturacionesCrear executed in ${t3 - t2}ms`);
    console.log('Results:', facRes.recordset);
    await zeusPool.close();
}

run().catch(console.error);
