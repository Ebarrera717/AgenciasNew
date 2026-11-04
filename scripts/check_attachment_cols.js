const { Pool } = require('pg');

async function check() {
    const pool = new Pool({
        connectionString: 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public'
    });
    try {
        const res = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment'");
        console.log('Columns of public.Attachment:');
        console.table(res.rows);

        const seqRes = await pool.query("SELECT * FROM pg_sequences WHERE schemaname = 'public' AND sequencename LIKE '%Attachment%'");
        console.log('Sequences for Attachment:', seqRes.rows);
    } catch (err) {
        console.error('Error:', err.message);
    } finally {
        await pool.end();
    }
}

check();
