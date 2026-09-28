const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

async function testBatches() {
    const pool = await mssql.connect({
        user: 'zeusagencias',
        password: 'zzeusagencias',
        server: 'ZEUSAGENCIAS10',
        database: 'Korex_Pruebas',
        options: { encrypt: false, trustServerCertificate: true, enableArithAbort: true }
    });

    const filePath = path.join(__dirname, 'SQL', 'SqlServer', '03_Functions_And_SPs.sql');
    const sql = fs.readFileSync(filePath, 'utf8');
    const batches = sql.split(/^GO\s*$/gm);

    console.log(`Total batches to test: ${batches.length}`);
    let errCount = 0;

    for (let i = 0; i < batches.length; i++) {
        const batch = batches[i].trim();
        if (!batch) continue;
        try {
            await pool.request().query(batch);
        } catch (err) {
            errCount++;
            const firstLine = batch.split('\n').find(l => l.trim().length > 0) || '';
            console.error(`❌ Batch #${i + 1} Error [${firstLine.substring(0, 60)}...]:`, err.message);
        }
    }

    console.log(`\nTesting completed. Total errors: ${errCount}`);
    await pool.close();
}

testBatches().catch(console.error);
