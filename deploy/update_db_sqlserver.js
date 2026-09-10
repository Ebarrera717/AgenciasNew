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

    let serverVal = host || '127.0.0.1';
    if (instance && instance.trim() !== '') {
        serverVal = `${serverVal}\\${instance.trim()}`;
    }

    const sqlConfig = {
        user: user || process.env.SQLSERVER_USER || 'sa',
        password: password || process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        server: host || process.env.SQLSERVER_HOST || '127.0.0.1',
        database: database || process.env.SQLSERVER_DB || 'Korex_colaereo',
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };

    if (port && parseInt(port) > 0) {
        sqlConfig.port = parseInt(port);
    } else if (instance) {
        sqlConfig.options.instanceName = instance;
    } else {
        sqlConfig.port = 1433;
    }

    console.log(`[PASO 1] Conectando a la base de datos de producción [${sqlConfig.database}] en ${serverVal}...`);

    let pool = null;
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

        let batchCount = 0;
        for (const batch of batches) {
            batchCount++;
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
        console.error(`  ${err.message}`);
        if (pool) await pool.close().catch(() => {});
        return false;
    }
}

if (require.main === module) {
    const args = process.argv.slice(2);
    runSqlServerUpdate(args[0], args[1], args[2], args[3], args[4], args[5]);
}

module.exports = { runSqlServerUpdate };
