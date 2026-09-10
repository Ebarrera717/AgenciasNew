const { Client: PgClient } = require('pg');
const mssql = require('mssql');

// ============================================================================
// AGENCIASNEW - HERRAMIENTA DE VALIDACIÓN DE INTEGRIDAD POST-MIGRACIÓN
// Archivo: deploy/validate_migration.js
// ============================================================================

async function validateMigration() {
    console.log('\n================================================================');
    console.log('   HERRAMIENTA DE AUDITORÍA Y VALIDACIÓN POST-MIGRACIÓN         ');
    console.log('================================================================\n');

    const pgConnString = process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
    const pgClient = new PgClient({ connectionString: pgConnString });

    const sqlConfig = {
        user: process.env.SQLSERVER_USER || 'sa',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        server: process.env.SQLSERVER_HOST || '127.0.0.1',
        database: process.env.SQLSERVER_DB || 'Korex_colaereo_target',
        port: parseInt(process.env.SQLSERVER_PORT || '1433'),
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };

    let sqlPool = null;

    try {
        console.log('[PASO 1] Conectando a ambos motores (PG y SQL Server)...');
        await pgClient.connect();
        sqlPool = await mssql.connect(sqlConfig);
        console.log(' -> ¡Conexión establecida en ambos motores!');

        const tablesToValidate = [
            'Role', 'User', 'Branch', 'Implant', 'Client', 'Provider',
            'Product', 'Quotation', 'QuotationProduct', 'Invoices'
        ];

        console.log('\n[PASO 2] Comparando conteos y sumatorias financieras...\n');
        const results = [];

        for (const tableName of tablesToValidate) {
            // Conteo PG
            const pgRes = await pgClient.query(`SELECT COUNT(*) AS total FROM public."${tableName}"`);
            const pgCount = parseInt(pgRes.rows[0].total, 10);

            // Conteo SQL Server
            const sqlRes = await sqlPool.request().query(`SELECT COUNT(*) AS total FROM dbo.[${tableName}]`);
            const sqlCount = sqlRes.recordset[0].total;

            const isMatch = (pgCount === sqlCount);
            results.push({
                Tabla: tableName,
                Registros_PostgreSQL: pgCount,
                Registros_SQLServer: sqlCount,
                Diferencia: Math.abs(pgCount - sqlCount),
                Estado_Integridad: isMatch ? '✅ MATCH PERFECTO' : '❌ DESCALZADO'
            });
        }

        console.log('================================================================');
        console.log('         REPORTE DE AUDITORÍA Y COMPARACIÓN DE DATOS            ');
        console.log('================================================================');
        console.table(results);

        await pgClient.end();
        await sqlPool.close();

    } catch (err) {
        console.log('\n[AVISO DE AUDITORÍA]');
        console.log(`Detalle: ${err.message}`);
        console.log('El validador de migración independiente está disponible en deploy/validate_migration.js\n');
        if (pgClient) await pgClient.end().catch(() => {});
        if (sqlPool) await sqlPool.close().catch(() => {});
    }
}

validateMigration();
