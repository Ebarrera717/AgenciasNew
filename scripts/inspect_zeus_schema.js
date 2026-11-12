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

    console.log('--- Fac_Servicios Date Columns ---');
    const cols = await pool.request().query("SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Fac_Servicios' AND (COLUMN_NAME LIKE '%fec%' OR COLUMN_NAME LIKE '%dt_%' OR COLUMN_NAME LIKE '%salida%' OR COLUMN_NAME LIKE '%llegada%') ORDER BY ORDINAL_POSITION");
    console.log(cols.recordset);

    console.log('--- spza_Servicio_Vender Parameters ---');
    const params = await pool.request().query("SELECT PARAMETER_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_NAME = 'spza_Servicio_Vender' ORDER BY ORDINAL_POSITION");
    console.log(params.recordset);

    await pool.close();
}

run().catch(console.error);
