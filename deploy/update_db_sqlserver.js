const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

// ============================================================================
// AGENCIASNEW - EJECUTOR DEL ACTUALIZADOR DE BASE DE DATOS (SQL SERVER)
// REGLA ESTRICTA (SKILL CONTROL ABSOLUTO):
// 1. PROHIBIDO EL FALLBACK DE CONEXIÓN A SERVIDORES DE DESARROLLO (ZEUSAGENCIAS10).
// 2. VALIDACIÓN DE IDENTIDAD DE BASE DE DATOS ANTES DE CUALQUIER DDL.
// 3. EXIT CODE 4 SI LA CONEXIÓN O IDENTIDAD NO CORRESPONDE AL .ENV DEL CLIENTE.
// ============================================================================

async function runSqlServerUpdate(host, instance, port, database, user, password) {
    console.log('\n================================================================');
    console.log('   ACTUALIZADOR DE BASE DE DATOS Y REGLAS - SQL SERVER          ');
    console.log('================================================================\n');

    const updaterSqlPath = path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql');
    if (!fs.existsSync(updaterSqlPath)) {
        console.error('❌ ERROR CRÍTICO [Exit Code 6]: No se encontró el script de actualización ActualizadorSERVER.sql');
        process.exit(6);
    }

    const sqlContent = fs.readFileSync(updaterSqlPath, 'utf8');

    // REGLA 8 & 9: PROHIBIDO USAR FALLBACKS HARDCODEADOS DE DESARROLLO
    let targetHost = host || process.env.DB_HOST || process.env.SQLSERVER_HOST;
    let targetUser = user || process.env.DB_USER || process.env.SQLSERVER_USER;
    let targetPass = password || process.env.DB_PASSWORD || process.env.SQLSERVER_PASSWORD;
    let targetDb = database || process.env.DB_NAME || process.env.SQLSERVER_DB;
    let targetPort = port ? parseInt(port, 10) : parseInt(process.env.DB_PORT || process.env.SQLSERVER_PORT || '1433', 10);

    // Parse from DATABASE_URL_SQLSERVER or DATABASE_URL if host/db not provided
    if (!targetHost || !targetDb) {
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
                        targetHost = hostPortPart.split(':')[0];
                        if (targetHost.toLowerCase() === 'localhost') targetHost = '127.0.0.1';
                        const pStr = hostPortPart.split(':')[1];
                        if (pStr) targetPort = parseInt(pStr, 10);

                        const params = clean.split(';');
                        for (const p of params) {
                            const eqIdx = p.indexOf('=');
                            if (eqIdx > 0) {
                                const k = p.substring(0, eqIdx).trim().toLowerCase();
                                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                                if (k === 'database') targetDb = v;
                                else if (k === 'user' || k === 'user id' || k === 'uid') targetUser = v;
                                else if (k === 'password' || k === 'pwd') targetPass = v;
                            }
                        }
                    }
                }
            }
        } catch (e) {}
    }

    // REGLA 8 & 12: SI FALTA CONFIGURACIÓN, BLOQUEAR E INFORMAR DE INMEDIATO (EXIT CODE 3)
    if (!targetHost || !targetDb || !targetUser) {
        console.error('❌ ERROR CRÍTICO [Exit Code 3]: No se encontró información de conexión SQL Server válida en el .env del cliente.');
        console.error('   PROHIBICIÓN ABSOLUTA DE FALLBACK: El actualizador se detuvo para evitar modificar una base incorrecta.');
        process.exit(3);
    }

    if (targetHost.toLowerCase() === 'localhost' || targetHost === '.' || targetHost === '(local)') {
        targetHost = '127.0.0.1';
    }

    let serverVal = targetHost;
    if (instance && instance.trim() !== '') {
        serverVal = `${serverVal}\\${instance.trim()}`;
    }

    const sqlConfig = {
        user: targetUser,
        password: targetPass,
        server: targetHost,
        database: targetDb,
        port: targetPort || 1433,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 15000,
        requestTimeout: 120000
    };

    console.log(`[PASO 1] Conectando a la base de datos configurada [${sqlConfig.database}] en ${serverVal}:${sqlConfig.port}...`);

    let pool = null;
    let batchCount = 0;
    let successCount = 0;
    let warningCount = 0;
    let currentBatchText = '';

    try {
        pool = await mssql.connect(sqlConfig);
        console.log(' -> ¡Conexión establecida!');

        // REGLA 10: VALIDACIÓN DE IDENTIDAD REAL DE LA BASE DE DATOS
        console.log('\n[PASO 1.5] Validando Identidad de Servidor y Base de Datos...');
        const identityRes = await pool.request().query(`
            SELECT 
                CAST(SERVERPROPERTY('MachineName') AS VARCHAR(255)) as ServerName,
                CAST(SERVERPROPERTY('ServerName') AS VARCHAR(255)) as InstanceName,
                DB_NAME() as CurrentDatabase,
                SUSER_SNAME() as CurrentUser
        `);
        const realInfo = identityRes.recordset[0];
        console.log(` -> Servidor Real: ${realInfo.ServerName} (${realInfo.InstanceName})`);
        console.log(` -> Base de Datos Real: ${realInfo.CurrentDatabase}`);
        console.log(` -> Usuario Real: ${realInfo.CurrentUser}`);

        // Verificar que la base a la que nos conectamos coincida con la configurada
        if (realInfo.CurrentDatabase.toLowerCase() !== targetDb.toLowerCase()) {
            console.error(`\n❌ ERROR CRÍTICO DE IDENTIDAD [Exit Code 4]:`);
            console.error(`   La conexión SQL Server no corresponde a la instalación configurada.`);
            console.error(`   Esperado: Base '${targetDb}' | Conectado a: Base '${realInfo.CurrentDatabase}'`);
            console.error(`   La actualización fue detenida con 0 DDL ejecutado para evitar modificar una base incorrecta.`);
            await pool.close();
            process.exit(4);
        }

        console.log(' -> ✅ Identidad de Base de Datos Verificada y Correcta.');

        console.log('\n[PASO 2] Ejecutando lotes de actualización DDL, Semillas y SPs...');

        // Separar bloques por la sentencia GO de forma resiliente
        const batches = sqlContent
            .split(/\r?\n[ \t]*GO[ \t]*(?:--[^\r\n]*)?(?:\r?\n|$)/i)
            .map(b => b.replace(/^[ \t]*GO[ \t]*$/gmi, '').trim())
            .filter(b => b.length > 0);

        console.log(` -> Total de lotes (batches) a ejecutar: ${batches.length}`);

        for (const batch of batches) {
            batchCount++;
            currentBatchText = batch;
            try {
                await pool.request().batch(batch);
                successCount++;
            } catch (bErr) {
                warningCount++;
                const firstLine = batch.split('\n').find(l => l.trim().length > 0) || '';
                console.warn(`  ⚠️ [Lote #${batchCount}] Advertencia: ${bErr.message} (Inicio: ${firstLine.substring(0, 60)})`);
            }
        }

        console.log(` -> Lotes procesados: ${successCount} aplicados exitosamente, ${warningCount} advertencias no críticas.`);

        await pool.close();

        console.log('\n================================================================');
        console.log('   ACTUALIZACIÓN T-SQL COMPLETADA. CONTINUANDO A GUARDIAN.     ');
        console.log('================================================================\n');
        return true;

    } catch (err) {
        console.error('\n❌ ERROR FATAL DURANTE LA ACTUALIZACIÓN EN SQL SERVER [Exit Code 1]:');
        console.error(`  En batch #${batchCount}:`);
        console.error(`  ${currentBatchText.slice(0, 300)}`);
        console.error(`  Mensaje: ${err.message}`);
        if (pool) await pool.close().catch(() => {});
        process.exit(1);
    }
}

if (require.main === module) {
    const args = process.argv.slice(2);
    runSqlServerUpdate(args[0], args[1], args[2], args[3], args[4], args[5]).then(success => {
        if (!success) {
            process.exit(1);
        }
    }).catch(err => {
        console.error('Fatal unhandled error:', err);
        process.exit(1);
    });
}

module.exports = { runSqlServerUpdate };
