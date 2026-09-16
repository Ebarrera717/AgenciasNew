const fs = require('fs');
const path = require('path');
const mssql = require('mssql');

const rootDir = path.join(__dirname, '..');
require('dotenv').config({ path: path.join(rootDir, '.env') });

const { generateTsqlFunctionsAndSps } = require('./gen_tsql_sps_and_functions');

// Configuración de conexión a SQL Server (Zeus ERP)
function getSqlServerConfig() {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = 'ZeusAgencias_23';
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
            }
        }
    }

    const host = process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost;
    const user = process.env.SQLSERVER_USER || defaultUser;
    const password = process.env.SQLSERVER_PASSWORD || defaultPass;
    const database = process.env.ZEUS_ERP_DB || 'ZeusAgencias_23';
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

// Ejecutar sincronización directa hacia Zeus ERP
async function syncToZeusERP(silentSuccess = false) {
    const timestamp = new Date().toLocaleTimeString();
    if (!silentSuccess) {
        console.log(`\n================================================================`);
        console.log(`   [${timestamp}] SINCRONIZADOR AUTÓNOMO DE ZEUS ERP (SQL SERVER)  `);
        console.log(`================================================================`);
    }

    // 1. Recompilar 03_Functions_And_SPs.sql desde archivos fuente SQL/SP/
    try {
        generateTsqlFunctionsAndSps();
    } catch (genErr) {
        console.error(`  [ERROR] Falló la generación de T-SQL: ${genErr.message}`);
        return false;
    }

    // 2. Cargar exclusivamente las funciones y SPs de integración para Zeus ERP (evitando crear tablas locales de Korex)
    const spsSqlPath = path.join(rootDir, 'SQL', 'SqlServer', '03_Functions_And_SPs.sql');
    let sqlContent = '';
    if (fs.existsSync(spsSqlPath)) {
        sqlContent = fs.readFileSync(spsSqlPath, 'utf8');
    } else {
        console.error('  [ERROR] No se encontró SQL/SqlServer/03_Functions_And_SPs.sql para sincronizar.');
        return false;
    }

    const config = getSqlServerConfig();
    const dbsToSync = [config.database];

    // También sincronizar en la BD principal de Korex SQL Server si es diferente a Zeus ERP
    let envDbName = null;
    const envUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;
    if (envUrl && (envUrl.startsWith('sqlserver://') || envUrl.startsWith('mssql://'))) {
        const match = envUrl.match(/database=([^;]+)/i);
        if (match && match[1]) envDbName = match[1].trim();
    }
    if (envDbName && !dbsToSync.includes(envDbName)) {
        dbsToSync.unshift(envDbName);
    }

    let overallSuccess = true;

    for (const targetDb of dbsToSync) {
        let pool = null;
        let batchCount = 0;
        let successCount = 0;

        try {
            const dbConfig = { ...config, database: targetDb };
            console.log(`  -> Conectando a BD SQL Server [${targetDb}] en ${dbConfig.server}:${dbConfig.port || 1433}...`);
            pool = await mssql.connect(dbConfig);
            console.log(`  -> ¡Conexión con SQL Server [${targetDb}] establecida!`);

            const batches = sqlContent
                .split(/^GO\s*$/mi)
                .map(b => b.trim())
                .filter(b => b.length > 0);

            console.log(`  -> Aplicando ${batches.length} lotes de actualización en [${targetDb}]...`);

            for (const batch of batches) {
                batchCount++;
                try {
                    await pool.request().batch(batch);
                    successCount++;
                } catch (bErr) {
                    console.warn(`  [WARN Batch #${batchCount} en ${targetDb}]: ${bErr.message.slice(0, 150)}...`);
                }
            }

            const logMsg = `[${new Date().toISOString()}] Sincronización completada: ${successCount}/${batches.length} lotes aplicados exitosamente en [${targetDb}] (${dbConfig.server}).\n`;
            console.log(`  -> ${logMsg.trim()}`);
            const logFilePath = path.join(rootDir, 'SQL', 'Zeus_Sync.log');
            fs.appendFileSync(logFilePath, logMsg, 'utf8');

            await pool.close();
        } catch (err) {
            const errorLog = `[${new Date().toISOString()}] ERROR CONEXIÓN SQL SERVER [${targetDb}]: ${err.message}\n`;
            console.error(`  ${errorLog.trim()}`);
            const logFilePath = path.join(rootDir, 'SQL', 'Zeus_Sync.log');
            fs.appendFileSync(logFilePath, errorLog, 'utf8');
            if (pool) await pool.close().catch(() => {});
            overallSuccess = false;
        }
    }

    return overallSuccess;
}

// Modo Watcher (Observador en tiempo real)
function startZeusWatcher() {
    console.log(`\n================================================================`);
    console.log(`   MODO VIGÍA (WATCHER) DE ZEUS ERP ACTIVADO                     `);
    console.log(`   Monitoreando carpeta: SQL/ en busca de cambios...             `);
    console.log(`================================================================\n`);

    let debounceTimer = null;
    const sqlDir = path.join(rootDir, 'SQL');

    const triggerSync = (filename) => {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(async () => {
            console.log(`\n🔔 [CAMBIO DETECTADO EN LOCAL]: ${filename}`);
            console.log(`⚡ Sincronizando automáticamente con Zeus ERP...`);
            await syncToZeusERP();
        }, 500);
    };

    if (fs.existsSync(sqlDir)) {
        fs.watch(sqlDir, { recursive: true }, (eventType, filename) => {
            if (filename && (filename.endsWith('.sql') || filename.endsWith('.SQL'))) {
                triggerSync(filename);
            }
        });
    }

    // Ejecutar primera sincronización inicial
    syncToZeusERP();
}

if (require.main === module) {
    const isWatch = process.argv.includes('--watch') || process.argv.includes('-w');
    if (isWatch) {
        startZeusWatcher();
    } else {
        syncToZeusERP();
    }
}

module.exports = { syncToZeusERP, startZeusWatcher };
