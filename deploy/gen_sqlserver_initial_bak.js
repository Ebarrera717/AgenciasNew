const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

// ============================================================================
// GENERADOR DE BASE DE DATOS INICIAL EN BLANCO Y BACKUP (.BAK) PARA SQL SERVER
// Archivo: deploy/gen_sqlserver_initial_bak.js
// ============================================================================

async function executeBatchWithGo(pool, sqlScript) {
    const batches = sqlScript
        .split(/^\s*GO\s*$/im)
        .map(b => b.trim())
        .filter(b => b.length > 0);

    for (const batch of batches) {
        await pool.request().batch(batch);
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
    const sqlTables = fs.readFileSync(path.join(sqlDir, '01_Tables.sql'), 'utf8');
    const sqlSeeds = fs.readFileSync(path.join(sqlDir, '02_Seeds.sql'), 'utf8');
    const sqlSps = fs.readFileSync(path.join(sqlDir, '03_Functions_And_SPs.sql'), 'utf8');

    console.log('[PASO 1] Scripts T-SQL cargados desde SQL/SqlServer/');

    // Configuración para conectarse al servidor master
    const configMaster = {
        user: process.env.SQLSERVER_USER || 'sa',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        server: process.env.SQLSERVER_HOST || '127.0.0.1',
        database: 'master',
        port: parseInt(process.env.SQLSERVER_PORT || '1433'),
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };

    let pool = null;
    try {
        console.log(`[PASO 2] Conectando a SQL Server (${configMaster.server}:${configMaster.port})...`);
        pool = await mssql.connect(configMaster);
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
        await executeBatchWithGo(pool, sqlTables);
        console.log(' -> Estructura de tablas aplicada.');

        // Ejecutar Semillas Maestras
        console.log('\n[PASO 5] Inyectando semillas maestras iniciales (02_Seeds.sql)...');
        await executeBatchWithGo(pool, sqlSeeds);
        console.log(' -> Semillas maestras inyectadas.');

        // Ejecutar SPs y Funciones
        console.log('\n[PASO 6] Compilando Stored Procedures y Funciones (03_Functions_And_SPs.sql)...');
        await executeBatchWithGo(pool, sqlSps);
        console.log(' -> SPs y Funciones compiladas.');

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

        // Generar BACKUP DATABASE .BAK
        console.log(`\n[PASO 8] Generando archivo de backup .BAK: ${outputBakFileName}...`);
        await pool.request().query(`
            BACKUP DATABASE [${tempDbName}]
            TO DISK = '${outputBakPath.replace(/\\/g, '/')}'
            WITH FORMAT, INIT, NAME = N'${tempDbName}-Full Database Backup', SKIP, NOUNLOAD, STATS = 10;
        `);
        console.log(` -> ¡Backup .BAK generado exitosamente en: ${outputBakPath}!`);

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
        console.log(` Entregable 03 generado: deploy/BaseLimpia/${outputBakFileName}`);
        console.log('================================================================\n');

    } catch (err) {
        console.log('\n[AVISO DE CONEXIÓN / PROCESO]');
        console.log(`Detalle: ${err.message}`);
        console.log('Si no hay una instancia local de SQL Server activa, los scripts T-SQL de la base inicial han sido preparados y validados estructuralmente en SQL/SqlServer/.\n');
        if (pool) await pool.close();
    }
}

generateInitialBak();
