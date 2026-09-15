const { Pool } = require('pg');
require('dotenv').config();

async function run() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const pool = new Pool({ connectionString: pgUrl });
    const client = await pool.connect();

    try {
        console.log("=== public.\"Branch\" ===");
        const resB = await client.query('SELECT id, code, name FROM public."Branch"');
        console.table(resB.rows);

        console.log("=== public.\"TicketPrinter\" ===");
        const resT = await client.query('SELECT id, code, name FROM public."TicketPrinter" LIMIT 10');
        console.table(resT.rows);

    } finally {
        client.release();
        await pool.end();
    }
}

run().catch(console.error);
