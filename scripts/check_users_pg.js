const { Pool } = require('pg');
require('dotenv').config();

async function run() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const pool = new Pool({ connectionString: pgUrl });
    const client = await pool.connect();

    try {
        console.log("=== USERS EN POSTGRES ===");
        const res = await client.query('SELECT id, name, email FROM public."User"');
        console.table(res.rows);
    } finally {
        client.release();
        await pool.end();
    }
}

run().catch(console.error);
