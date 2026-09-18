const path = require('path');
const mssql = require('mssql');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

async function runTest() {
    console.log('--- TEST DE EXPORTACION FACTURA 15 ---');
    
    const korexConfig = {
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'Korex_pruebas',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433
    };

    const zeusConfig = {
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'ZeusAgencias_23',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433,
        requestTimeout: 120000
    };

    let korexPool = await mssql.connect(korexConfig);
    const exportReq = korexPool.request();
    exportReq.input('Envoices_id', mssql.VarChar(mssql.MAX), '15');
    exportReq.input('User_id', mssql.Int, 1);
    const exportRes = await exportReq.execute('dbo.spExportInvoices');
    await korexPool.close();

    const xmlStr = exportRes.recordset[0]?.mensaje_resultado;
    console.log('\nXML GENERADO (primeros 500 caracteres):');
    console.log(xmlStr.substring(0, 500));

    let zeusPool = await mssql.connect(zeusConfig);
    const zeusReq = zeusPool.request();
    zeusReq.timeout = 120000;
    zeusReq.input('xml', mssql.VarChar(mssql.MAX), xmlStr);
    
    console.log('\nEjecutando dbo.spFacturacionesCrear en ZeusAgencias_23...');
    try {
        const res = await zeusReq.execute('dbo.spFacturacionesCrear');
        console.log('\nRESULTADO spFacturacionesCrear (Total recordsets:', res.recordsets.length, '):');
        res.recordsets.forEach((rs, idx) => {
            console.log(`\n=== Recordset ${idx} (${rs.length} filas) ===`);
            if (rs.length > 0) {
                const firstRow = rs[0];
                const keys = Object.keys(firstRow);
                console.log('Columns:', keys);
                if (keys.includes('message')) {
                    const msg = String(firstRow.message);
                    console.log('MESSAGE (first 500 chars):', msg.substring(0, 500));
                    const traceIdx = msg.indexOf('--- DYNAMIC EXECUTION TRACE ---');
                    if (traceIdx > -1) {
                        console.log('MESSAGE ONLY (before trace):', msg.substring(0, traceIdx));
                    }
                } else if (keys.includes('invoiceId')) {
                    console.log('Row:', firstRow);
                } else {
                    console.log('Row sample:', JSON.stringify(firstRow).substring(0, 200));
                }
            }
        });
    } catch (err) {
        console.error('\nERROR EJECUTANDO spFacturacionesCrear:');
        console.error(err.message);
    }
    
    console.log('\nConsultando tablas de Zeus ERP para la ultima factura insertada...');
    try {
        const facRes = await zeusPool.request().query(
            "SELECT TOP 1 id, numero, cd_fuente, cd_serie, cd_consecutivo, cd_cliente_codigo, ds_cliente_nombre, ds_cliente_dir, ds_cliente_tel, ds_cliente_ciudad, ds_cliente_email, cd_vendedor FROM dbo.fac_factura ORDER BY id DESC"
        );
        console.log('Ultima FACTURA (dbo.fac_factura):');
        console.log(facRes.recordset[0]);
        
        if (facRes.recordset[0]) {
            const facId = facRes.recordset[0].id;
            
            const srvRes = await zeusPool.request().query(
                "SELECT * FROM dbo.Fac_Servicios WHERE id_fac_factura = " + facId
            );
            console.log('\nFac_Servicios:');
            console.dir(srvRes.recordset, { depth: null });

            if (srvRes.recordset.length > 0) {
                const srvId = srvRes.recordset[0].id;
                const paxRes = await zeusPool.request().query(
                    "SELECT id, id_fac_factura, id_fac_servicios, ds_paxname, ds_paxape FROM dbo.Fac_Servicios_PaxAdicional WHERE id_fac_factura = " + facId + " OR id_fac_servicios = " + srvId
                );
                console.log('\nFac_Servicios_PaxAdicional:');
                console.dir(paxRes.recordset, { depth: null });

                const fpRes = await zeusPool.request().query(
                    "SELECT id, id_fac_factura, id_fac_servicios, id_formaspago, ds_fpnm, am_valor FROM dbo.Fac_ServiciosFormasPago WHERE id_fac_factura = " + facId + " OR id_fac_servicios = " + srvId
                );
                console.log('\nFac_ServiciosFormasPago:');
                console.dir(fpRes.recordset, { depth: null });
            }
        }
    } catch (err) {
        console.error('Error consultando tablas:', err.message);
    }

    await zeusPool.close();
}

runTest().catch(console.error);
