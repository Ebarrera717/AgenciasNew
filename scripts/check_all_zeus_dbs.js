const mssql = require('mssql');

(async () => {
    try {
        const pool = await mssql.connect({
            server: '192.168.15.8',
            user: 'zeusagencias',
            password: 'zzeusagencias',
            database: 'master',
            options: { encrypt: false, trustServerCertificate: true }
        });

        const dbsRes = await pool.request().query("SELECT name FROM sys.databases WHERE name LIKE '%Zeus%'");
        const zeusDbs = dbsRes.recordset.map(r => r.name);
        console.log('Zeus DBs on 192.168.15.8:', zeusDbs);

        for (const db of zeusDbs) {
            try {
                const spRes = await pool.request().query(`
                    SELECT 
                        OBJECT_ID('${db}.dbo.spCotizacionesCrear') as sp_id,
                        OBJECT_ID('${db}.dbo.Cotizacion') as cot_table,
                        OBJECT_ID('${db}.dbo.CLIENTES') as cli_table,
                        OBJECT_ID('${db}.dbo.Tiqueteadores') as tq_table
                `);
                console.log(`DB [${db}]:`, spRes.recordset[0]);
            } catch(e) {
                console.log(`DB [${db}] error:`, e.message);
            }
        }

        await pool.close();
    } catch (e) {
        console.error(e);
    }
})();
