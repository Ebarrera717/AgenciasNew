const { Pool } = require('pg');

async function testInsert() {
    const pool = new Pool({
        connectionString: 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public'
    });
    try {
        const buf = Buffer.from('test attachment content');
        const res = await pool.query(
            'INSERT INTO public."Attachment" ("quotationId", "fileName", "fileType", "fileSize", "fileContent", "createdAt") VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING id, "quotationId", "fileName"',
            [23, 'test.txt', 'text/plain', buf.length, buf]
        );
        console.log('Inserted:', res.rows);
        await pool.query('DELETE FROM public."Attachment" WHERE id = $1', [res.rows[0].id]);
        console.log('Cleaned up test row successfully.');
    } catch (e) {
        console.error('Error inserting:', e);
    } finally {
        await pool.end();
    }
}

testInsert();
