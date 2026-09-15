const { Pool } = require('pg');
require('dotenv').config();

async function run() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const pool = new Pool({ connectionString: pgUrl });
    const client = await pool.connect();

    try {
        console.log("=== PRODUCTS EN POSTGRES ===");
        const res = await client.query('SELECT id, code, description FROM public."Product" LIMIT 10');
        console.table(res.rows);
    } finally {
        client.release();
        await pool.end();
    }
}

run().catch(console.error);
