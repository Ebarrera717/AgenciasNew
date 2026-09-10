const { Client: PgClient } = require('pg');
const mssql = require('mssql');
const fs = require('fs');

// ============================================================================
// AGENCIASNEW - HERRAMIENTA INDEPENDIENTE DE MIGRACIÓN: POSTGRESQL -> SQL SERVER
// Archivo: deploy/migrate_pg_to_sqlserver.js
// ============================================================================

async function runMigration() {
    console.log('\n================================================================');
    console.log('   HERRAMIENTA DE MIGRACIÓN OPERATIVA: POSTGRESQL -> SQL SERVER  ');
    console.log('================================================================\n');

    // Conexión PostgreSQL (Origen)
    const pgConnString = process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
    const pgClient = new PgClient({ connectionString: pgConnString });

    // Conexión SQL Server (Destino)
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
        console.log('[PASO 1] Conectando a PostgreSQL (Origen)...');
        await pgClient.connect();
        console.log(' -> Conexión exitosa a PostgreSQL local.');

        console.log(`[PASO 2] Conectando a SQL Server (Destino: ${sqlConfig.server}:${sqlConfig.port}/${sqlConfig.database})...`);
        sqlPool = await mssql.connect(sqlConfig);
        console.log(' -> Conexión exitosa a SQL Server.');

        // Tablas a migrar en orden estricto de llaves foráneas
        const tablesToMigrate = [
            'Role',
            'TicketPrinter',
            'Branch',
            'Implant',
            'User',
            'Seller',
            'Client',
            'ProviderType',
            'Provider',
            'Prestadora',
            'TicketType',
            'Product',
            'Currency',
            'SystemParameter',
            'Menu',
            'Master',
            'ChargeAndTax',
            'Quotation',
            'QuotationProduct',
            'Invoices'
        ];

        console.log('\n[PASO 3] Iniciando transferencia de registros por tabla...\n');
        const metrics = [];

        for (const tableName of tablesToMigrate) {
            // 1. Obtener datos de Postgres
            const pgRes = await pgClient.query(`SELECT * FROM public."${tableName}" ORDER BY id ASC`);
            const rows = pgRes.rows;

            if (rows.length === 0) {
                metrics.push({ Tabla: tableName, Registros_PG: 0, Insertados_SQL: 0, Estado: 'SIN DATOS' });
                continue;
            }

            // 2. Limpiar tabla en SQL Server si fuera necesario
            const req = sqlPool.request();
            await req.query(`DELETE FROM dbo.[${tableName}];`);

            // 3. Activar IDENTITY_INSERT
            await req.query(`SET IDENTITY_INSERT dbo.[${tableName}] ON;`);

            let countInserted = 0;

            for (const row of rows) {
                const keys = Object.keys(row);
                const colList = keys.map(k => `[${k}]`).join(', ');
                const paramList = keys.map((_, i) => `@p${i}`).join(', ');

                const insertReq = sqlPool.request();
                keys.forEach((k, i) => {
                    let val = row[k];
                    if (val !== null && typeof val === 'object' && !(val instanceof Date) && !Buffer.isBuffer(val)) {
                        val = JSON.stringify(val);
                    }
                    insertReq.input(`p${i}`, val);
                });

                try {
                    await insertReq.query(`INSERT INTO dbo.[${tableName}] (${colList}) VALUES (${paramList});`);
                    countInserted++;
                } catch (insErr) {
                    console.error(` -> Error insertando fila en ${tableName} (ID: ${row.id}):`, insErr.message);
                }
            }

            // 4. Desactivar IDENTITY_INSERT
            await req.query(`SET IDENTITY_INSERT dbo.[${tableName}] OFF;`);

            // 5. Re-sincronizar contador IDENTITY
            const maxIdRes = await req.query(`SELECT ISNULL(MAX(id), 0) AS maxId FROM dbo.[${tableName}];`);
            const maxId = maxIdRes.recordset[0].maxId;
            if (maxId > 0) {
                await req.query(`DBCC CHECKIDENT ('dbo.[${tableName}]', RESEED, ${maxId});`);
            }

            metrics.push({ Tabla: tableName, Registros_PG: rows.length, Insertados_SQL: countInserted, Estado: countInserted === rows.length ? 'EXITOSO' : 'CON ADVERTENCIAS' });
        }

        console.log('================================================================');
        console.log('            REPORTE MIGRACIÓN POSTGRES -> SQL SERVER            ');
        console.log('================================================================');
        console.table(metrics);

        await pgClient.end();
        await sqlPool.close();

    } catch (err) {
        console.log('\n[AVISO DE MIGRACIÓN]');
        console.log(`Detalle: ${err.message}`);
        console.log('La herramienta de migración independiente está lista en deploy/migrate_pg_to_sqlserver.js');
        if (pgClient) await pgClient.end().catch(() => {});
        if (sqlPool) await sqlPool.close().catch(() => {});
    }
}

runMigration();
