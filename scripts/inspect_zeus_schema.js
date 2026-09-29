const mssql = require('mssql');
require('dotenv').config();

async function run() {
    const pool = await mssql.connect({
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'ZeusAgencias_23',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433
    });

    console.log('--- spze_ListadoCamposServicio / spze_ItemsCampos DEF ---');
    const sp1 = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spze_ListadoCamposServicio')) as def");
    console.log('spze_ListadoCamposServicio:', sp1.recordset[0]?.def);

    const sp2 = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spze_ItemsCampos')) as def");
    console.log('spze_ItemsCampos:', sp2.recordset[0]?.def);

    const sp3 = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spza_FacturaProveedor_Consultar')) as def");
    console.log('spza_FacturaProveedor_Consultar:', sp3.recordset[0]?.def);

    await pool.close();
}

run().catch(console.error);
