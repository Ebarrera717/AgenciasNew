const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const { Client: PgClient } = require('pg');
const mssql = require('mssql');
const { decryptUrlPasswords, decryptPassword } = require('../deploy/security_helper');

async function runE2ETest() {
    console.log('=== TEST AUTO EXPORT E2E ===\n');

    // 1. Conexión Postgres
    const pgConn = decryptUrlPasswords(process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@127.0.0.1:5432/Korex_colaereo?schema=public');
    const pg = new PgClient({ connectionString: pgConn });
    await pg.connect();

    // 2. Obtener la última cotización y factura válidas
    const cotiRes = await pg.query('SELECT id, "internalNumber" FROM public."Quotation" ORDER BY id DESC LIMIT 1');
    const invRes = await pg.query('SELECT id, "internalNumber", consecutivo FROM public."Invoices" ORDER BY id DESC LIMIT 1');

    if (cotiRes.rows.length === 0 || invRes.rows.length === 0) {
        console.log('No hay cotizaciones o facturas para probar.');
        await pg.end();
        return;
    }

    const coti = cotiRes.rows[0];
    const inv = invRes.rows[0];

    console.log(`1. Cotización seleccionada: ID #${coti.id} (Consecutivo: ${coti.internalNumber})`);
    console.log(`2. Factura seleccionada: ID #${inv.id} (Consecutivo: ${inv.internalNumber || inv.consecutivo})`);

    // 3. Generar XML Cotización
    console.log('\n--- Probando Exportación Cotización ---');
    const xmlCotiRes = await pg.query('CALL public.spExportQuotation($1, $2, $3)', [String(coti.id), 5, '']);
    const xmlCoti = xmlCotiRes.rows[0]?.mensaje_resultado || xmlCotiRes.rows[0]?.p_mensaje_resultado || '';
    console.log(`XML Cotización generado: ${xmlCoti.length} caracteres.`);
    
    // Conectar a Zeus ERP (ZeusAgencias_23)
    const sqlHost = process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10';
    const sqlPass = decryptPassword(process.env.SQLSERVER_PASSWORD || 'zzeusagencias');
    const pool = await mssql.connect({
        server: sqlHost,
        port: 1433,
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: sqlPass,
        database: 'ZeusAgencias_23',
        options: { encrypt: false, trustServerCertificate: true }
    });

    console.log('Conectado a SQL Server (ZeusAgencias_23). Invocando spCotizacionesCrear...');
    const reqCoti = pool.request();
    reqCoti.input('xml', mssql.VarChar(mssql.MAX), xmlCoti);
    const spCotiRes = await reqCoti.execute('dbo.spCotizacionesCrear');
    console.log('Resultado spCotizacionesCrear:');
    console.table(spCotiRes.recordset || spCotiRes.recordsets?.[0] || []);

    // 4. Generar XML Factura
    console.log('\n--- Probando Exportación Factura ---');
    const xmlInvRes = await pg.query('CALL public.spExportInvoices($1, $2, $3)', [String(inv.id), 5, '']);
    const xmlInv = xmlInvRes.rows[0]?.mensaje_resultado || xmlInvRes.rows[0]?.p_mensaje_resultado || '';
    console.log(`XML Factura generado: ${xmlInv.length} caracteres.`);

    console.log('Invocando spFacturacionesCrear en ZeusAgencias_23...');
    const reqInv = pool.request();
    reqInv.input('xml', mssql.VarChar(mssql.MAX), xmlInv);
    const spInvRes = await reqInv.execute('dbo.spFacturacionesCrear');
    console.log('Resultado spFacturacionesCrear:');
    console.table(spInvRes.recordset || spInvRes.recordsets?.[0] || []);

    await pool.close();
    await pg.end();
    console.log('\n=== PRUEBA E2E COMPLETADA CON ÉXITO ===');
}

runE2ETest().catch(e => {
    console.error('Error en prueba E2E:', e);
    process.exit(1);
});
