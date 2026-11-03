const mssql = require('mssql');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');

// ============================================================================
// AGENCIASNEW - EJECUTOR DEL ACTUALIZADOR DE BASE DE DATOS (SQL SERVER)
// REGLA ESTRICTA (SKILL CONTROL ABSOLUTO):
// 1. PROHIBIDO EL FALLBACK DE CONEXIÓN A SERVIDORES DE DESARROLLO (ZEUSAGENCIAS10).
// 2. VALIDACIÓN OBLIGATORIA DE EXISTENCIA DE LA BASE DE DATOS:
//    - Si NO existe en el servidor SQL Server, la CREA automáticamente.
//    - Si YA existe, ejecuta directamente los scripts de actualización.
// 3. VALIDACIÓN DE IDENTIDAD DE BASE DE DATOS ANTES DE CUALQUIER DDL.
// 4. EXIT CODE 4 SI LA CONEXIÓN O IDENTIDAD NO CORRESPONDE A LA BASE SOLICITADA.
// ============================================================================

function resolveUpdaterSqlPath() {
    const candidates = [
        path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql'),
        path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.SQL'),
        path.join(__dirname, '..', 'SQL', 'ActualizadorSERVER.sql'),
        path.join(__dirname, '..', 'SQL', 'ActualizadorSERVER.SQL'),
        path.join(__dirname, '..', 'SQL', 'SqlServer', 'ActualizadorSERVER.sql')
    ];
    for (const candidate of candidates) {
        if (fs.existsSync(candidate)) {
            return candidate;
        }
    }
    return null;
}

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Descubre automáticamente el puerto TCP real de una instancia nombrada de SQL Server
 * (ej. LAPTOP-M9RF6IM8\AGENCIAS_PRUEBA) cuando el servicio SQLBrowser está detenido o deshabilitado.
 */
function resolveNamedInstanceTcpPort(rawHost, instanceName, user, password) {
    if (!instanceName) return null;

    // 1. Intentar leer del registro de Windows si la instancia es local
    try {
        const psRegCmd = `$p = Get-ItemProperty "HKLM:\\SOFTWARE\\Microsoft\\Microsoft SQL Server\\MSSQL*.${instanceName}\\MSSQLServer\\SuperSocketNetLib\\Tcp\\IPAll" -ErrorAction SilentlyContinue | Select-Object -First 1; if ($p) { if ($p.TcpPort) { Write-Output $p.TcpPort } elseif ($p.TcpDynamicPorts) { Write-Output $p.TcpDynamicPorts } }`;
        const regOut = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psRegCmd], {
            encoding: 'utf8',
            timeout: 5000,
            stdio: ['ignore', 'pipe', 'ignore']
        }).trim();
        const portMatch = regOut.match(/(\d+)/);
        if (portMatch) {
            return parseInt(portMatch[1], 10);
        }
    } catch (e) {}

    // 2. Intentar descubrir el puerto mediante .NET SqlConnection (soporta Shared Memory / Named Pipes / SQL Browser)
    try {
        const safeServer = `${rawHost}\\${instanceName}`.replace(/'/g, "''");
        const safeUser = (user || '').replace(/'/g, "''");
        const safePass = (password || '').replace(/'/g, "''");
        const psNetCmd = `
            $sc = 'Server=${safeServer};Database=master;User Id=${safeUser};Password=${safePass};Encrypt=False;TrustServerCertificate=True;Connection Timeout=6;';
            $conn = New-Object System.Data.SqlClient.SqlConnection($sc);
            $conn.Open();
            $cmd = $conn.CreateCommand();
            $cmd.CommandText = "SELECT local_tcp_port FROM sys.dm_exec_connections WHERE session_id = @@SPID AND local_tcp_port IS NOT NULL; EXEC xp_readerrorlog 0, 1, N'Server is listening on'";
            $r = $cmd.ExecuteReader();
            $foundPort = '';
            while ($r.Read()) { if ($r[0]) { $foundPort = $r[0].ToString() } }
            if (-not $foundPort -and $r.NextResult()) {
                while ($r.Read()) {
                    $txt = $r[2].ToString();
                    if ($txt -match '<ipv4>\\s+(\\d+)') { $foundPort = $matches[1]; break }
                }
            }
            $conn.Close();
            if ($foundPort) { Write-Output $foundPort }
        `;
        const netOut = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psNetCmd], {
            encoding: 'utf8',
            timeout: 8000,
            stdio: ['ignore', 'pipe', 'ignore']
        }).trim();
        const portMatch = netOut.match(/(\d+)/);
        if (portMatch) {
            return parseInt(portMatch[1], 10);
        }
    } catch (e) {}

    return null;
}

async function runSqlServerUpdate(host, instance, port, database, user, password) {
    console.log('\n================================================================');
    console.log('   INSTALADOR / ACTUALIZADOR DE BASE DE DATOS - SQL SERVER      ');
    console.log('================================================================\n');

    const updaterSqlPath = resolveUpdaterSqlPath();
    if (!updaterSqlPath) {
        console.error('❌ ERROR CRÍTICO [Exit Code 6]: No se encontró el script de actualización ActualizadorSERVER.sql');
        process.exit(6);
    }

    const sqlContent = fs.readFileSync(updaterSqlPath, 'utf8');

    // Si PowerShell 5.1 omitió el argumento vacío "" de instance, reacomodar los 5 argumentos:
    // (host, port, database, user, password)
    if (password === undefined && user !== undefined && database !== undefined && port !== undefined && instance !== undefined && /^\d+$/.test(String(instance).trim())) {
        password = user;
        user = database;
        database = port;
        port = instance;
        instance = '';
    }
    if (instance === 'DEFAULT' || instance === '-') {
        instance = '';
    }

    // REGLA 8 & 9: PROHIBIDO USAR FALLBACKS HARDCODEADOS DE DESARROLLO
    let targetHost = host || process.env.DB_HOST || process.env.SQLSERVER_HOST;
    let targetUser = user || process.env.DB_USER || process.env.SQLSERVER_USER;
    let targetPass = password !== undefined ? password : (process.env.DB_PASSWORD || process.env.SQLSERVER_PASSWORD);
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
        console.error('❌ ERROR CRÍTICO [Exit Code 3]: No se encontró información de conexión SQL Server válida (Servidor, Base de Datos o Usuario).');
        console.error('   PROHIBICIÓN ABSOLUTA DE FALLBACK: El actualizador se detuvo para evitar modificar una base incorrecta.');
        process.exit(3);
    }

    let originalHostInput = targetHost;
    let instanceName = instance && instance.trim() !== '' ? instance.trim() : '';
    if (!instanceName && targetHost.includes('\\')) {
        const parts = targetHost.split('\\');
        targetHost = parts[0];
        instanceName = parts[1];
    }

    const localHostn = (os.hostname() || '').toLowerCase();
    if (
        targetHost.toLowerCase() === 'localhost' ||
        targetHost === '.' ||
        targetHost.toLowerCase() === '(local)' ||
        (localHostn && targetHost.toLowerCase() === localHostn)
    ) {
        targetHost = '127.0.0.1';
    }

    let serverVal = instanceName ? `${originalHostInput.split('\\')[0]}\\${instanceName}` : targetHost;
    let resolvedInstancePort = null;

    if (instanceName) {
        resolvedInstancePort = resolveNamedInstanceTcpPort(originalHostInput.split('\\')[0], instanceName, targetUser, targetPass);
        if (resolvedInstancePort) {
            console.log(` -> Puerto TCP detectado para la instancia [${serverVal}]: ${resolvedInstancePort}`);
            targetPort = resolvedInstancePort;
        }
    }

    const baseOptions = {
        encrypt: false,
        trustServerCertificate: true
    };
    if (instanceName && !resolvedInstancePort) {
        baseOptions.instanceName = instanceName;
    }

    const effectivePort = (instanceName && !resolvedInstancePort) ? undefined : (targetPort || 1433);

    const masterConfig = {
        user: targetUser,
        password: targetPass,
        server: targetHost,
        database: 'master',
        port: effectivePort,
        options: baseOptions,
        connectionTimeout: 15000,
        requestTimeout: 120000
    };

    const sqlConfig = {
        user: targetUser,
        password: targetPass,
        server: targetHost,
        database: targetDb,
        port: effectivePort,
        options: baseOptions,
        connectionTimeout: 15000,
        requestTimeout: 120000
    };

    // =========================================================================
    // PASO 0: VERIFICAR SI LA BASE DE DATOS EXISTE EN MASTER Y CREARLA SI NO EXISTE
    // =========================================================================
    console.log(`[PASO 0] Verificando existencia de la base de datos [${targetDb}] en ${serverVal} (TCP ${effectivePort || 'SQLBrowser'})...`);
    let masterPool = null;
    try {
        masterPool = await mssql.connect(masterConfig);
        const checkDbRes = await masterPool.request()
            .input('dbName', mssql.NVarChar(255), targetDb)
            .query(`
                SELECT 
                    DB_ID(@dbName) AS DbId,
                    (SELECT state_desc FROM sys.databases WHERE name = @dbName) AS StateDesc
            `);

        const dbRow = checkDbRes.recordset[0];
        if (!dbRow || dbRow.DbId === null) {
            console.log(` -> ⚠️ La base de datos [${targetDb}] NO existe en el servidor SQL Server.`);
            console.log(` -> 🛠️ Creando base de datos [${targetDb}] automáticamente...`);

            const safeBracketDb = targetDb.replace(/\]/g, ']]');
            await masterPool.request().batch(`
                IF DB_ID(N'${targetDb.replace(/'/g, "''")}') IS NULL
                BEGIN
                    CREATE DATABASE [${safeBracketDb}];
                END
            `);

            // Esperar a que la base de datos esté en estado ONLINE
            let isOnline = false;
            for (let attempt = 1; attempt <= 20; attempt++) {
                const stateRes = await masterPool.request()
                    .input('dbName', mssql.NVarChar(255), targetDb)
                    .query(`SELECT state_desc FROM sys.databases WHERE name = @dbName`);
                if (stateRes.recordset.length > 0 && stateRes.recordset[0].state_desc === 'ONLINE') {
                    isOnline = true;
                    break;
                }
                await sleep(500);
            }

            if (!isOnline) {
                throw new Error(`La base de datos [${targetDb}] fue creada pero no alcanzó el estado ONLINE a tiempo.`);
            }
            console.log(` -> ✅ Base de datos [${targetDb}] CREADA exitosamente y en estado ONLINE.`);
        } else {
            console.log(` -> ✅ La base de datos [${targetDb}] YA EXISTE (ID: ${dbRow.DbId}, Estado: ${dbRow.StateDesc || 'ONLINE'}).`);
            console.log(` -> Procediendo a ejecutar los scripts de actualización sobre [${targetDb}]...`);
        }

        await masterPool.close();
        masterPool = null;
    } catch (masterErr) {
        if (masterPool) await masterPool.close().catch(() => {});
        console.error(`\n❌ ERROR CRÍTICO AL CONECTAR O VERIFICAR/CREAR LA BASE DE DATOS [${targetDb}] EN MASTER:`);
        console.error(`   Servidor: ${serverVal} (Host: ${targetHost}, Puerto: ${effectivePort || 'SQLBrowser'})`);
        console.error(`   Usuario:  ${targetUser}`);
        console.error(`   Detalle:  ${masterErr.message}`);
        process.exit(4);
    }

    // =========================================================================
    // PASO 1: CONECTAR A LA BASE DE DATOS DESTINO Y VALIDAR IDENTIDAD
    // =========================================================================
    console.log(`\n[PASO 1] Conectando a la base de datos [${sqlConfig.database}] en ${serverVal}...`);

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
                console.log(`  ⚠️ [Lote #${batchCount}] Advertencia no crítica: ${bErr.message} (Inicio: ${firstLine.substring(0, 60)})`);
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

module.exports = { runSqlServerUpdate, resolveNamedInstanceTcpPort };
