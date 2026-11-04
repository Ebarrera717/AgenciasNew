const { Pool } = require('pg');

async function check() {
    const pool = new Pool({
        connectionString: 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public'
    });
    try {
        const res = await pool.query('SELECT id, "quotationId", "fileName", "fileSize", "createdAt" FROM public."Attachment" ORDER BY id DESC LIMIT 10');
        console.log('Recent attachments in PostgreSQL:');
        console.table(res.rows);

        const countRes = await pool.query('SELECT count(*) as total FROM public."Attachment" WHERE "quotationId" = 23');
        console.log('Total attachments for quotation 23:', countRes.rows[0].total);

        const qRes = await pool.query('SELECT id, "internalNumber", "createdAt" FROM public."Quotation" WHERE id = 23');
        console.log('Quotation 23:', qRes.rows[0]);
    } catch (err) {
        console.error('Error:', err.message);
    } finally {
        await pool.end();
    }
}

check();
