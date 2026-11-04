const mssql = require('mssql');
(async () => {
    const pool = await mssql.connect({
        server: '192.168.15.8', user: 'zeusagencias', password: 'zzeusagencias', database: 'ZeusAgencias_Colaereo',
        options: { encrypt: false, trustServerCertificate: true }
    });
    const res = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spCotizacionesCrear')) as def");
    const def = res.recordset[0].def;
    console.log('Contains COT.ds_cliente_ciudad:', def.includes('COT.ds_cliente_ciudad'));
    console.log('Contains CL.CIUDAD:', def.includes('CL.CIUDAD'));
    console.log('Contains cd_codigo lookup for tiqueteador:', def.includes('cd_codigo'));
    await pool.close();
})();
