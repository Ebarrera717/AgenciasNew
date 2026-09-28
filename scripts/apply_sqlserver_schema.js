const mssql = require('mssql');
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

// Query postgres for SQL Server config
async function getSQLServerConfig() {
    return {
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        database: process.env.SQLSERVER_DATABASE || 'Korex_Pruebas',
        port: process.env.SQLSERVER_PORT ? parseInt(process.env.SQLSERVER_PORT) : 1433,
        options: { encrypt: false, trustServerCertificate: true, enableArithAbort: true }
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
