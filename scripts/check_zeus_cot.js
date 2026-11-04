const mssql = require('mssql');

(async () => {
    try {
        const pool = await mssql.connect({
            server: '192.168.15.8',
            user: 'zeusagencias',
            password: 'zzeusagencias',
            database: 'ZeusAgencias_Colaereo',
            options: { encrypt: false, trustServerCertificate: true }
        });

        const res = await pool.request().query("SELECT TOP 5 id, cd_consecutivo, cd_cliente_codigo, ds_cliente_nombre, ds_cliente_dir, ds_cliente_ciudad, ds_cliente_tel, id_tiqueteador, cd_vendedor, dt_fechacont FROM dbo.Cotizacion WHERE cd_consecutivo LIKE '%18' OR id = 18 ORDER BY id DESC");
        console.log('Cotizaciones in ZeusAgencias_Colaereo:', res.recordset);

        // Also check what tiqueteador id 49 and 148 are
        const tq = await pool.request().query("SELECT id, cd_codigo, ds_nombre FROM dbo.Tiqueteadores WHERE id IN (49, 148)");
        console.log('Tiqueteadores 49 and 148:', tq.recordset);

        await pool.close();
    } catch (e) {
        console.error(e);
    }
})();
