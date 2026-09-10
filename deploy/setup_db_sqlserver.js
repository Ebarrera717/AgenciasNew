const mssql = require('mssql');

// ============================================================================
// AGENCIASNEW - VALIDADOR DE CONEXIÓN E INSTALACIÓN PARA SQL SERVER
// Archivo: deploy/setup_db_sqlserver.js
// REGLA ESTRICTA: El instalador NUNCA crea la base de datos automáticamente.
// ============================================================================

async function validateSQLServerConnection(host, instance, port, database, user, password) {
    console.log('\n================================================================');
    console.log('   VALIDACIÓN DE CONEXIÓN E INSTALACIÓN AGENCIASNEW (SQL SERVER)  ');
    console.log('================================================================\n');

    let serverVal = host || '127.0.0.1';
    if (instance && instance.trim() !== '') {
        serverVal = `${serverVal}\\${instance.trim()}`;
    }

    const sqlConfig = {
        user: user,
        password: password,
        server: host,
        database: database,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 30000
    };

    if (port && port !== '' && parseInt(port) > 0) {
        sqlConfig.port = parseInt(port);
    } else if (instance) {
        sqlConfig.options.instanceName = instance;
    } else {
        sqlConfig.port = 1433;
    }

    console.log(`[PASO 1] Probando conexión a la base de datos existente [${database}] en ${serverVal}...`);

    let pool = null;
    try {
        pool = await mssql.connect(sqlConfig);
        console.log(' -> ¡Conexión exitosa!');

        console.log('\n[PASO 2] Verificando que la base de datos contenga la estructura requerida (restaurada de .BAK)...');
        const resTables = await pool.request().query(`
            SELECT COUNT(*) AS tableCount FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');
        `);

        const tableCount = resTables.recordset[0].tableCount;
        if (tableCount === 0) {
            throw new Error(`La base de datos [${database}] existe pero está completamente vacía. Debe restaurar primero el archivo de backup Korex_SQLServer_Inicial.bak.`);
        }

        console.log(` -> Base de datos validada correctamente (${tableCount} tablas encontradas).`);

        console.log('\n[PASO 3] Verificando permisos de lectura y escritura para la aplicación...');
        await pool.request().query(`
            SELECT TOP 1 id FROM dbo.[Role];
        `);
        console.log(' -> Permisos de lectura (SELECT) validados.');

        await pool.close();

        console.log('\n================================================================');
        console.log('   RESULTADO: CONEXIÓN Y ESTRUCTURA VALIDADA CORRECTAMENTE     ');
        console.log('================================================================\n');
        return true;

    } catch (err) {
        console.error('\n❌ ERROR DE VALIDACIÓN:');
        console.error(`  ${err.message}`);
        if (pool) await pool.close().catch(() => {});
        return false;
    }
}

if (require.main === module) {
    const args = process.argv.slice(2);
    const host = args[0] || '127.0.0.1';
    const instance = args[1] || '';
    const port = args[2] || '1433';
    const database = args[3] || 'Korex_colaereo';
    const user = args[4] || 'sa';
    const password = args[5] || 'zzeusagencias';

    validateSQLServerConnection(host, instance, port, database, user, password);
}

module.exports = { validateSQLServerConnection };
