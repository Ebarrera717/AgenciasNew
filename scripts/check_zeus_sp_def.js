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

        const res = await pool.request().query("SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spCotizacionesCrear')) as def");
        const def = res.recordset[0]?.def || '';
        console.log('spCotizacionesCrear definition length:', def.length);

        // Check how id_tiqueteador is set in current Zeus SP
        const lines = def.split('\n');
        const matchLines = lines.filter(l => l.includes('id_tiqueteador') || l.includes('ds_cliente_ciudad'));
        console.log('Matching lines in active SP:', matchLines);

        await pool.close();
    } catch (e) {
        console.error(e);
    }
})();
