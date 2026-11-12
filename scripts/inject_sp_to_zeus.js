const fs = require('fs');
const path = require('path');
const mssql = require('mssql');

const spCotizacionesFile = path.join(__dirname, '..', 'SQL', 'ZeusERP', 'spCotizacionesCrear.sql');
const spCotizacionesSql = fs.readFileSync(spCotizacionesFile, 'utf8');

const spFacturacionesFile = path.join(__dirname, '..', 'SQL', 'ZeusERP', 'spFacturacionesCrear.sql');
const spFacturacionesSql = fs.readFileSync(spFacturacionesFile, 'utf8');

const targetDbs = ['ZeusAgencias_Colaereo', 'ZeusAgencias_Colaereo_Prueba'];

(async () => {
    for (const db of targetDbs) {
        console.log(`\n======================================================`);
        console.log(`Inyectando SPs en [${db}] (192.168.15.8)...`);
        console.log(`======================================================`);
        let pool = null;
        try {
            pool = await mssql.connect({
                server: '192.168.15.8',
                user: 'zeusagencias',
                password: 'zzeusagencias',
                database: db,
                options: { encrypt: false, trustServerCertificate: true },
                requestTimeout: 60000
            });

            // 1. Inyectar spCotizacionesCrear
            console.log(`  -> Inyectando spCotizacionesCrear...`);
            const cotBatches = spCotizacionesSql.split(/^GO\s*$/mi).map(b => b.trim()).filter(b => b.length > 0);
            for (const batch of cotBatches) {
                await pool.request().batch(batch);
            }
            console.log(`  ✅ spCotizacionesCrear inyectado con éxito.`);

            // 2. Inyectar spFacturacionesCrear
            console.log(`  -> Inyectando spFacturacionesCrear...`);
            const facBatches = spFacturacionesSql.split(/^GO\s*$/mi).map(b => b.trim()).filter(b => b.length > 0);
            for (const batch of facBatches) {
                await pool.request().batch(batch);
            }
            console.log(`  ✅ spFacturacionesCrear inyectado con éxito.`);

            // Verificar ambos SPs
            const chkCot = await pool.request().query("SELECT OBJECT_ID('dbo.spCotizacionesCrear') as sp_id");
            const chkFac = await pool.request().query("SELECT OBJECT_ID('dbo.spFacturacionesCrear') as sp_id");

            console.log(`✅ [${db}]:`);
            console.log(`   - spCotizacionesCrear: ID ${chkCot.recordset[0]?.sp_id}`);
            console.log(`   - spFacturacionesCrear: ID ${chkFac.recordset[0]?.sp_id}`);

            // Actualizar todas las cotizaciones en dbo.Cotizacion que tengan ciudad o teléfono vacío
            const fixRes = await pool.request().query(`
                UPDATE C
                SET 
                    C.ds_cliente_ciudad = LEFT(
                        COALESCE(
                            NULLIF(RTRIM(LTRIM(CL.CIUDAD)), ''),
                            NULLIF(RTRIM(LTRIM(C.ds_cliente_ciudad)), ''),
                            'BOGOTA'
                        ), 40
                    ),
                    C.ds_cliente_tel = LEFT(
                        COALESCE(
                            NULLIF(RTRIM(LTRIM(CL.TELEFONO)), ''),
                            NULLIF(RTRIM(LTRIM(C.ds_cliente_tel)), ''),
                            ''
                        ), 25
                    ),
                    C.ds_cliente_dir = LEFT(
                        COALESCE(
                            NULLIF(RTRIM(LTRIM(C.ds_cliente_dir)), ''),
                            NULLIF(RTRIM(LTRIM(CL.DIRECCION)), ''),
                            ''
                        ), 250
                    ),
                    C.id_sys_entidades = COALESCE(NULLIF(C.id_sys_entidades, 0), 65)
                FROM dbo.Cotizacion C
                CROSS APPLY (
                    SELECT TOP 1 IDCLIENTE, IDTERCERO, CIUDAD, TELEFONO, DIRECCION
                    FROM dbo.CLIENTES CL WITH (NOLOCK)
                    WHERE RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) 
                       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_cliente_codigo))
                       OR RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_tercero_codigo))
                       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_tercero_codigo))
                    ORDER BY 
                       CASE WHEN RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) THEN 0 ELSE 1 END,
                       CL.IDCLIENTE ASC
                ) CL
                WHERE C.ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(C.ds_cliente_ciudad)) = ''
                   OR C.ds_cliente_tel IS NULL OR RTRIM(LTRIM(C.ds_cliente_tel)) = ''
                   OR (RTRIM(LTRIM(C.ds_cliente_ciudad)) = 'BOGOTA' AND NULLIF(RTRIM(LTRIM(CL.CIUDAD)), '') IS NOT NULL AND UPPER(RTRIM(LTRIM(CL.CIUDAD))) <> 'BOGOTA');
            `);
            console.log(`   - Cotizaciones actualizadas con ciudad/teléfono en [${db}]: ${fixRes.rowsAffected[0]}`);

            // Verificar que ya no queden cotizaciones desde la 101 en adelante con ciudad o teléfono vacío
            const verifyRes = await pool.request().query(`
                SELECT cd_consecutivo, cd_cliente_codigo, ds_cliente_ciudad, ds_cliente_tel
                FROM dbo.Cotizacion
                WHERE TRY_CAST(cd_consecutivo AS INT) >= 101
                ORDER BY cd_consecutivo ASC;
            `);
            if (verifyRes.recordset.length > 0) {
                console.table(verifyRes.recordset);
            }

            await pool.close();
        } catch (e) {
            console.error(`❌ Error en [${db}]:`, e.message);
            if (pool) await pool.close().catch(() => {});
        }
    }
})();
