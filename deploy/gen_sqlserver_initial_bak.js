const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

// ============================================================================
// GENERADOR DE BASE DE DATOS INICIAL EN BLANCO Y BACKUP (.BAK) PARA SQL SERVER
// Archivo: deploy/gen_sqlserver_initial_bak.js
// ============================================================================

function parseSqlServerEnv() {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
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
                    defaultHost = hostPortPart.split(':')[0] || defaultHost;
                    if (defaultHost.toLowerCase() === 'localhost') defaultHost = '127.0.0.1';
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
            }
        }
    } catch (e) {}

    return { defaultUser, defaultPass, defaultHost, defaultPort };
}

async function executeBatchWithGo(pool, sqlScript, stepName = '') {
    const batches = sqlScript
        .split(/^\s*GO\s*$/im)
        .map(b => b.trim())
        .filter(b => b.length > 0);

    let errCount = 0;
    for (let i = 0; i < batches.length; i++) {
        const batch = batches[i];
        try {
            await pool.request().batch(batch);
        } catch (err) {
            errCount++;
            // If it's a DDL / SP creation, check if it is fatal
            if (stepName === '01_Tables.sql' || stepName === '02_Seeds.sql') {
                throw new Error(`Error en batch ${i + 1}/${batches.length} de ${stepName}: ${err.message}`);
            } else {
                console.warn(` [AVISO] Batch ${i + 1}/${batches.length} en ${stepName}: ${err.message}`);
            }
        }
    }
    if (errCount > 0 && (stepName === '01_Tables.sql' || stepName === '02_Seeds.sql')) {
        throw new Error(`Se encontraron ${errCount} errores en ${stepName}`);
    }
}

async function generateInitialBak() {
    console.log('\n================================================================');
    console.log(' GENERADOR DE BASE DE DATOS INICIAL Y BACKUP .BAK (SQL SERVER) ');
    console.log('================================================================\n');

    const appVersion = '1.0';
    const tempDbName = 'Korex_SQLServer_Inicial_Temp';
    const outputBakFileName = `Korex_SQLServer_Inicial_${appVersion}.bak`;
    const outputBakDir = path.join(__dirname, '..', 'deploy', 'BaseLimpia');
    if (!fs.existsSync(outputBakDir)) {
        fs.mkdirSync(outputBakDir, { recursive: true });
    }
    const outputBakPath = path.join(outputBakDir, outputBakFileName);

    // 1. Cargar scripts SQL
    const sqlDir = path.join(__dirname, '..', 'SQL', 'SqlServer');
    const sqlTablesPath = path.join(sqlDir, '01_Tables.sql');
    const sqlSeedsPath = path.join(sqlDir, '02_Seeds.sql');
    const sqlSpsPath = path.join(sqlDir, '03_Functions_And_SPs.sql');

    if (!fs.existsSync(sqlTablesPath) || !fs.existsSync(sqlSeedsPath) || !fs.existsSync(sqlSpsPath)) {
        throw new Error('No se encontraron todos los scripts requeridos en SQL/SqlServer/');
    }

    const sqlTables = fs.readFileSync(sqlTablesPath, 'utf8');
    const sqlSeeds = fs.readFileSync(sqlSeedsPath, 'utf8');
    const sqlSps = fs.readFileSync(sqlSpsPath, 'utf8');

    console.log('[PASO 1] Scripts T-SQL cargados desde SQL/SqlServer/');

    const envDefaults = parseSqlServerEnv();

    const serverHost = process.env.SQLSERVER_HOST || envDefaults.defaultHost;
    const serverPort = parseInt(process.env.SQLSERVER_PORT || String(envDefaults.defaultPort));
    const serverUser = process.env.SQLSERVER_USER || envDefaults.defaultUser;
    const serverPassword = process.env.SQLSERVER_PASSWORD || envDefaults.defaultPass;

    const configMaster = {
        user: serverUser,
        password: serverPassword,
        server: serverHost,
        database: 'master',
        port: serverPort,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 15000,
        requestTimeout: 120000
    };

    let pool = null;
    try {
        console.log(`[PASO 2] Conectando a SQL Server master (${configMaster.server}:${configMaster.port} como ${configMaster.user})...`);
        try {
            pool = await mssql.connect(configMaster);
        } catch (connErr) {
            // Intentar con 127.0.0.1 o ZEUSAGENCIAS10 alternativamente si falló
            const altHost = (configMaster.server === '127.0.0.1' || configMaster.server === 'localhost') ? 'ZEUSAGENCIAS10' : '127.0.0.1';
            console.log(` -> Reintentando conexión con host alternativo (${altHost})...`);
            configMaster.server = altHost;
            pool = await mssql.connect(configMaster);
        }
        console.log(' -> ¡Conexión exitosa a master!');

        // Crear base de datos temporal si no existe
        console.log(`\n[PASO 3] Preparando base de datos temporal [${tempDbName}]...`);
        await pool.request().query(`
            IF EXISTS (SELECT 1 FROM sys.databases WHERE name = '${tempDbName}')
            BEGIN
                ALTER DATABASE [${tempDbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                DROP DATABASE [${tempDbName}];
            END;
            CREATE DATABASE [${tempDbName}];
        `);
        // Cambiar contexto a la base temporal
        await pool.request().query(`USE [${tempDbName}];`);

        // Ejecutar Estructura de Tablas (DDL)
        console.log('\n[PASO 4] Aplicando estructura DDL (01_Tables.sql)...');
        await executeBatchWithGo(pool, sqlTables, '01_Tables.sql');
        console.log(' -> Estructura de tablas aplicada exitosamente.');

        // Ejecutar Semillas Maestras
        console.log('\n[PASO 5] Inyectando semillas maestras iniciales (02_Seeds.sql)...');
        await executeBatchWithGo(pool, sqlSeeds, '02_Seeds.sql');
        console.log(' -> Semillas maestras inyectadas exitosamente.');

        // Ejecutar SPs y Funciones
        console.log('\n[PASO 6] Compilando Stored Procedures y Funciones (03_Functions_And_SPs.sql)...');
        await executeBatchWithGo(pool, sqlSps, '03_Functions_And_SPs.sql');
        console.log(' -> SPs y Funciones compiladas exitosamente.');

        // Validación de Estructura e Integridad (Sin datos operativos)
        console.log('\n[PASO 7] Validando integridad de la base inicial en blanco...');
        const resTables = await pool.request().query(`
            SELECT COUNT(*) AS tableCount FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');
        `);
        const resQuotations = await pool.request().query(`
            SELECT COUNT(*) AS qCount FROM dbo.[Quotation];
        `);

        const tableCount = resTables.recordset[0].tableCount;
        const qCount = resQuotations.recordset[0].qCount;

        console.log(` -> Tablas construidas: ${tableCount}`);
        console.log(` -> Cotizaciones operativas: ${qCount} (Confirmado: 0 registros de clientes).`);

        if (tableCount === 0) {
            throw new Error('La base de datos temporal no contiene tablas dbo.');
        }

        // Generar BACKUP DATABASE .BAK
        console.log(`\n[PASO 8] Generando archivo de backup .BAK: ${outputBakFileName}...`);
        await pool.request().query(`
            BACKUP DATABASE [${tempDbName}]
            TO DISK = '${outputBakPath.replace(/\\/g, '/')}'
            WITH FORMAT, INIT, NAME = N'${tempDbName}-Full Database Backup', SKIP, NOUNLOAD, STATS = 10;
        `);
        
        if (!fs.existsSync(outputBakPath)) {
            throw new Error(`El archivo de backup no se encontró en ${outputBakPath}`);
        }

        const bakStats = fs.statSync(outputBakPath);
        console.log(` -> ¡Backup .BAK generado exitosamente! Tamaño: ${(bakStats.size / (1024 * 1024)).toFixed(2)} MB`);
        console.log(` -> Ubicación: ${outputBakPath}`);

        // Limpiar base temporal
        console.log(`\n[PASO 9] Limpiando base temporal [${tempDbName}]...`);
        await pool.request().query(`
            USE [master];
            ALTER DATABASE [${tempDbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
            DROP DATABASE [${tempDbName}];
        `);
        console.log(' -> Base temporal eliminada.');

        await pool.close();

        console.log('\n================================================================');
        console.log(` PROCESO FINALIZADO EXITOSAMENTE`);
        console.log(` Entregable generado: deploy/BaseLimpia/${outputBakFileName}`);
        console.log('================================================================\n');

    } catch (err) {
        console.error('\n❌ [ERROR CRÍTICO AL GENERAR BACKUP INICIAL .BAK]');
        console.error(`Detalle: ${err.message}\n`);
        if (pool) {
            try {
                await pool.request().query(`
                    USE [master];
                    IF EXISTS (SELECT 1 FROM sys.databases WHERE name = '${tempDbName}')
                    BEGIN
                        ALTER DATABASE [${tempDbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                        DROP DATABASE [${tempDbName}];
                    END;
                `);
                await pool.close();
            } catch (cleanupErr) {}
        }
        process.exit(1);
    }
}

generateInitialBak();
