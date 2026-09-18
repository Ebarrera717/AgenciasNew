const mssql = require('mssql');
require('dotenv').config();
async function inspect() {
    const pool = await mssql.connect({
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'ZeusAgencias_23',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433
    });
    const cols = await pool.request().query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MAECONT'");
    console.log('COLUMNAS MAECONT:', cols.recordset.map(r => r.COLUMN_NAME).join(', '));

    const res1 = await pool.request().query("SELECT CODICTA, DESCCTA, INDCPICTA, IDMONEDA FROM dbo.MAECONT WHERE CODICTA LIKE '11050501%'");
    console.log('11050501 en ZeusAgencias_23:', res1.recordset[0]);

    // Search which tables in ZeusAgencias_23 contain '11050501'
    const s1 = await pool.request().query("SELECT TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('Sucursales', 'PerfilFacturacion', 'PerfilFacturacion_Detalle', 'Parametros', 'Parametr', 'FormasPago_Sucursal', 'ConfiguracionCuentas')");
    console.log('Tablas candidatas:', s1.recordset.map(r => `${r.TABLE_NAME}.${r.COLUMN_NAME}`));
    
    const defCont = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spza_Factura_Contabilizar')) as def");
    const def = defCont.recordset[0]?.def || '';
    const defCont = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spza_Factura_Contabilizar')) as def");
    const def = defCont.recordset[0]?.def || '';
    const regex = /Insert Into dbo\.Document_Insertar[^\r\n]*/gi;
    let m;
    while ((m = regex.exec(def)) !== null) {
        console.log('Match at pos', m.index);
        console.log(def.substring(m.index, Math.min(def.length, m.index + 400)));
        console.log('---------------------------');
    }
    await pool.close();
    return;
    await pool.close();
    return;
    await contPool.close();
    return;
}
inspect().catch(console.error);
