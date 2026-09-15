const mssql = require('mssql');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Query postgres for SQL Server config
async function getSQLServerConfig() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || "postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public";
    const pgPool = new Pool({ connectionString: pgUrl });
    try {
        const res = await pgPool.query('SELECT * FROM "fnGetSQLServerConfig"()');
        await pgPool.end();
        if (res.rows && res.rows.length > 0) {
            const c = res.rows[0];
            return {
                user: c.db_user || 'sa',
                password: c.db_password || 'zzeusagencias',
                server: c.db_host || '127.0.0.1',
                database: c.db_name || 'Korex_Pruebas',
                port: c.db_port ? parseInt(c.db_port) : 1433,
                options: {
                    encrypt: false,
                    trustServerCertificate: true,
                    instanceName: c.db_instance || undefined
                }
            };
        }
    } catch (err) {
        console.warn('Could not fetch SQL Server config from pg, using defaults:', err.message);
    }
    return {
        user: 'sa',
        password: 'zzeusagencias',
        server: '127.0.0.1',
        database: 'Korex_Pruebas',
        port: 1433,
        options: { encrypt: false, trustServerCertificate: true }
    };
}

async function executeSqlFile(pool, relativePath) {
    const fullPath = path.join(__dirname, '..', relativePath);
    console.log(`Executing ${relativePath}...`);
    const sql = fs.readFileSync(fullPath, 'utf-8');
    const batches = sql.split(/^GO\s*$/gm);
    for (const batch of batches) {
        const trimmed = batch.trim();
        if (trimmed) {
            try {
                await pool.request().query(trimmed);
            } catch (err) {
                console.error(`Error in batch from ${relativePath}:`, err.message);
            }
        }
    }
    console.log(`Finished ${relativePath}`);
}

async function main() {
    try {
        const config = await getSQLServerConfig();
        console.log(`Connecting to SQL Server [${config.database}] at ${config.server}...`);
        const pool = await mssql.connect(config);
        console.log('Connected to SQL Server successfully!');

        await executeSqlFile(pool, 'SQL/SqlServer/01_Tables.sql');
        await executeSqlFile(pool, 'SQL/SqlServer/03_Functions_And_SPs.sql');
        await executeSqlFile(pool, 'SQL/Actualizador/ActualizadorSERVER.sql');

        console.log('SQL Server schema & SPs applied successfully!');
        await pool.close();
    } catch (err) {
        console.error('Fatal error:', err);
    }
}

main();
