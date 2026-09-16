const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

// ============================================================================
// AGENCIASNEW - EJECUTOR DEL ACTUALIZADOR DE BASE DE DATOS (SQL SERVER)
// Archivo: deploy/update_db_sqlserver.js
// REGLA ESTRICTA: EL ACTUALIZADOR NUNCA RE-CREA NI ELIMINA TABLAS OPERATIVAS.
// ============================================================================

async function runSqlServerUpdate(host, instance, port, database, user, password) {
    console.log('\n================================================================');
    console.log('   ACTUALIZADOR DE BASE DE DATOS Y REGLAS - SQL SERVER          ');
    console.log('================================================================\n');

    const updaterSqlPath = path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql');
    if (!fs.existsSync(updaterSqlPath)) {
        throw new Error('No se encontró el script de actualización ActualizadorSERVER.sql');
    }

    const sqlContent = fs.readFileSync(updaterSqlPath, 'utf8');

    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = 'Korex_Pruebas';
    let defaultPort = 1433;

    try {
        const envPath = path.join(__dirname, '..', '.env');
        if (fs.existsSync(envPath)) {
            const envContent = fs.readFileSync(envPath, 'utf8');
            const match = envContent.match(/^DATABASE_URL_SQLSERVER\s*=\s*["']?([^"'\r\n]+)/m) || envContent.match(/^DATABASE_URL\s*=\s*["']?([^"'\r\n]+)/m);
            if (match && match[1]) {
                const cleanUrl = match[1].replace(/["']/g, '').trim();
                if (cleanUrl.startsWith('sqlserver://') || cleanUrl.startsWith('mssql://')) {
                    const clean = cleanUrl.replace(/^(sqlserver|mssql):\/\//i, '');
                    const hostPortPart = clean.split(';')[0];
                    defaultHost = hostPortPart.split(':')[0] || 'ZEUSAGENCIAS10';
                    if (defaultHost.toLowerCase() === 'localhost') defaultHost = '127.0.0.1';
                    const pStr = hostPortPart.split(':')[1];
                    if (pStr) defaultPort = parseInt(pStr, 10);

                    const params = clean.split(';');
                    for (const p of params) {
                        const eqIdx = p.indexOf('=');
                        if (eqIdx > 0) {
                            const k = p.substring(0, eqIdx).trim().toLowerCase();
                            const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                            if (k === 'database') defaultDb = v;
                            else if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                            else if (k === 'password' || k === 'pwd') defaultPass = v;
                        }
                    }
                }
            }
        }
    } catch (e) {}

    let targetHost = host || process.env.SQLSERVER_HOST || defaultHost;
    let targetUser = user || process.env.SQLSERVER_USER || defaultUser;
    let targetPass = password || process.env.SQLSERVER_PASSWORD || defaultPass;
    let targetDb = database || process.env.SQLSERVER_DB || defaultDb;
    let targetPort = port ? parseInt(port, 10) : defaultPort;

    let serverVal = targetHost;
    if (instance && instance.trim() !== '') {
        serverVal = `${serverVal}\\${instance.trim()}`;
    }

    const sqlConfig = {
        user: targetUser,
        password: targetPass,
        server: targetHost,
        database: targetDb,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };

    if (targetPort && targetPort > 0) {
        sqlConfig.port = targetPort;
    } else if (instance) {
        sqlConfig.options.instanceName = instance;
    } else {
        sqlConfig.port = 1433;
    }

    console.log(`[PASO 1] Conectando a la base de datos de producción [${sqlConfig.database}] en ${serverVal}...`);

    let pool = null;
    let batchCount = 0;
    let currentBatchText = '';
    try {
        pool = await mssql.connect(sqlConfig);
        console.log(' -> ¡Conexión establecida!');

        console.log('\n[PASO 2] Ejecutando lotes de actualización DDL, Semillas y SPs...');

        // Separar bloques por la sentencia GO
        const batches = sqlContent
            .split(/^GO\s*$/mi)
            .map(b => b.trim())
            .filter(b => b.length > 0);

        console.log(` -> Total de lotes (batches) a ejecutar: ${batches.length}`);

        for (const batch of batches) {
            batchCount++;
            currentBatchText = batch;
            await pool.request().batch(batch);
        }

        console.log(` -> ¡Todos los ${batchCount} lotes fueron aplicados exitosamente!`);

        console.log('\n[PASO 3] Auditando estado final de la actualización...');
        const resTables = await pool.request().query(`
            SELECT COUNT(*) AS tableCount FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');
        `);
        const resSps = await pool.request().query(`
            SELECT COUNT(*) AS spCount FROM sys.procedures WHERE schema_id = SCHEMA_ID('dbo');
        `);

        console.log(` -> Tablas verificadas: ${resTables.recordset[0].tableCount}`);
        console.log(` -> Procedimientos y Funciones compilados: ${resSps.recordset[0].spCount}`);

        await pool.close();

        console.log('\n================================================================');
        console.log('   ACTUALIZACIÓN DE BASE DE DATOS SQL SERVER COMPLETADA EXITOSAMENTE ');
        console.log('================================================================\n');
        return true;

    } catch (err) {
        console.error('\n❌ ERROR DURANTE LA ACTUALIZACIÓN EN SQL SERVER:');
        console.error(`  En batch #${batchCount}:`);
        console.error(`  ${currentBatchText.slice(0, 300)}`);
        console.error(`  Mensaje: ${err.message}`);
        if (pool) await pool.close().catch(() => {});
        return false;
    }
}

if (require.main === module) {
    const args = process.argv.slice(2);
    runSqlServerUpdate(args[0], args[1], args[2], args[3], args[4], args[5]);
}

module.exports = { runSqlServerUpdate };
