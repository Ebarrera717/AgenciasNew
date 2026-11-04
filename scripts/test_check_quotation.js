const { Pool } = require('pg');

async function testCheck() {
    const pool = new Pool({
        connectionString: 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public'
    });
    try {
        const res = await pool.query('SELECT id, "internalNumber", "passenger", "date" FROM public."Quotation" ORDER BY id DESC LIMIT 10');
        console.log('Quotation records:');
        console.table(res.rows);
    } catch (e) {
        console.error('Error querying:', e);
    } finally {
        await pool.end();
    }
}

testCheck();
