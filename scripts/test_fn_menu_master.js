const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

async function main() {
    await client.connect();
    try {
        const resMenu = await client.query('SELECT * FROM public.fnMenuAll()');
        console.log('fnMenuAll rows:', resMenu.rows.length, resMenu.rows.slice(0, 3));
    } catch (e) {
        console.error('fnMenuAll error:', e.message);
    }

    try {
        const resMaster = await client.query('SELECT * FROM public."fnMasterList"()');
        console.log('fnMasterList rows:', resMaster.rows.length, resMaster.rows.slice(0, 3));
    } catch (e) {
        console.error('fnMasterList error:', e.message);
    }
    await client.end();
}

main().catch(console.error);
