const path = require('path');
const mssql = require('mssql');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const { generateTsqlFunctionsAndSps } = require('../deploy/gen_tsql_sps_and_functions');

// SPs obligatorios de integración con Zeus ERP que DEBEN existir en SQL Server
const MANDATORY_ZEUS_SPS = [
    'spFacturacionesCrear',
    'spCotizacionesCrear'
];

function getSqlServerConfig(targetDbName) {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = targetDbName || 'ZeusAgencias_23';
    let defaultPort = 1433;
    let instanceName = undefined;

    const envUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;
    if (envUrl && (envUrl.startsWith('sqlserver://') || envUrl.startsWith('mssql://'))) {
        const clean = envUrl.replace(/^(sqlserver|mssql):\/\//i, '');
        const hostPortPart = clean.split(';')[0];
        defaultHost = hostPortPart.split(':')[0] || defaultHost;
        if (defaultHost.toLowerCase() === 'localhost') defaultHost = '127.0.0.1';
        if (defaultHost.includes('\\')) {
            const parts = defaultHost.split('\\');
            defaultHost = parts[0];
            instanceName = parts[1];
        }
        const pStr = hostPortPart.split(':')[1];
        if (pStr) defaultPort = parseInt(pStr, 10);

        const params = clean.split(';');
        for (const p of params) {
            const eqIdx = p.indexOf('=');
            if (eqIdx > 0) {
                const k = p.substring(0, eqIdx).trim().toLowerCase();
                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                else if (k === 'password' || k === 'pwd') defaultPass = v;
                else if (k === 'database' || k === 'initial catalog') {
                    if (!targetDbName) defaultDb = v;
                }
            }
        }
    }

    const host = process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost;
    const user = process.env.SQLSERVER_USER || defaultUser;
    const password = process.env.SQLSERVER_PASSWORD || defaultPass;
    const database = targetDbName || process.env.ZEUS_ERP_DB || defaultDb;
    const port = process.env.SQLSERVER_PORT ? parseInt(process.env.SQLSERVER_PORT, 10) : defaultPort;
    const instance = process.env.SQLSERVER_INSTANCE || instanceName;

    const config = {
        user,
        password,
        server: host,
        database,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };

    if (port && port > 0) {
        config.port = port;
    } else if (instance) {
        config.options.instanceName = instance;
    } else {
        config.port = 1433;
    }

    return config;
}

async function validateAndInjectZeusSps() {
    console.log('\n================================================================');
    console.log('   VERIFICADOR Y SINCRONIZADOR DE SPs DE ZEUS ERP (SQL SERVER)  ');
    console.log('================================================================\n');

    // 1. Recompilar archivos de SPs T-SQL
    console.log('[PASO 1/3] Generando compilados T-SQL desde fuentes SQL/ZeusERP/...');
    generateTsqlFunctionsAndSps();

    // 2. Determinar la base de datos de Zeus ERP (Parámetro 'BaseSQLServer' -> ZeusAgencias_23, NUNCA Korex_pruebas)
    const zeusDbName = process.env.ZEUS_ERP_DB || 'ZeusAgencias_23';
    const dbsToVerify = [zeusDbName];
    console.log(`[PASO 2/3] Base de datos Zeus ERP objetivo: [${zeusDbName}] (Prohibido usar Korex_pruebas para SPs de Zeus ERP)`);

    let overallSuccess = true;

    for (const dbName of dbsToVerify) {
        console.log(`\n[PASO 2/3] Auditando SPs en la base de datos [${dbName}]...`);
        const config = getSqlServerConfig(dbName);
        let pool = null;
        try {
            pool = await mssql.connect(config);
            let missingSps = [];

            for (const spName of MANDATORY_ZEUS_SPS) {
                const res = await pool.request().query(`
                    SELECT OBJECT_ID('dbo.${spName}', 'P') AS sp_id;
                `);
                const spId = res.recordset[0]?.sp_id;
                if (!spId) {
                    missingSps.push(spName);
                    console.log(`  ❌ [FALTANTE]: 'dbo.${spName}' no existe en [${dbName}]`);
                } else {
                    console.log(`  ✅ [OK]: 'dbo.${spName}' presente en [${dbName}] (ID: ${spId})`);
                }
            }

            if (missingSps.length > 0) {
                console.log(`\n  ⚠️ Se detectaron ${missingSps.length} SP(s) faltantes en [${dbName}]. Inyectando automáticamente...`);
                const fs = require('fs');
                const spsSqlPath = path.join(__dirname, '..', 'SQL', 'SqlServer', '03_Functions_And_SPs.sql');
                if (fs.existsSync(spsSqlPath)) {
                    const sqlContent = fs.readFileSync(spsSqlPath, 'utf8');
                    const batches = sqlContent.split(/^GO\s*$/mi).map(b => b.trim()).filter(b => b.length > 0);
                    let okCount = 0;
                    let batchCount = 0;
                    for (const batch of batches) {
                        batchCount++;
                        try {
                            await pool.request().batch(batch);
                            okCount++;
                        } catch (bErr) {
                            console.warn(`  [WARN Batch #${batchCount} en ${dbName}]: ${bErr.message}`);
                        }
                    }
                    console.log(`  -> Sincronizados ${okCount}/${batches.length} lotes en [${dbName}].`);
                }

                // Re-verificar presencia
                for (const spName of missingSps) {
                    const res2 = await pool.request().query(`SELECT OBJECT_ID('dbo.${spName}', 'P') AS sp_id;`);
                    if (res2.recordset[0]?.sp_id) {
                        console.log(`  ✅ [REPARADO]: 'dbo.${spName}' inyectado correctamente en [${dbName}].`);
                    } else {
                        console.error(`  ❌ [CRÍTICO]: No fue posible inyectar 'dbo.${spName}' en [${dbName}].`);
                        overallSuccess = false;
                    }
                }
            } else {
                console.log(`  [OK] Todos los SPs obligatorios están presentes en [${dbName}].`);
            }

            await pool.close();
        } catch (err) {
            console.error(`  ❌ Error de conexión o ejecución en SQL Server [${dbName}]: ${err.message}`);
            if (pool) await pool.close().catch(() => {});
            overallSuccess = false;
        }
    }

    console.log('\n================================================================');
    if (overallSuccess) {
        console.log('   ✅ RESULTADO: Todos los SPs de Zeus ERP verificados e inyectados.');
        console.log('================================================================\n');
        process.exit(0);
    } else {
        console.error('   ❌ RESULTADO: Falló la verificación o inyección de SPs en Zeus ERP.');
        console.log('================================================================\n');
        process.exit(1);
    }
}

validateAndInjectZeusSps();
