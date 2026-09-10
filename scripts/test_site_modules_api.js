const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

async function main() {
    await client.connect();
    const resMenu = await client.query('SELECT COUNT(*) FROM public."Menu"');
    const resMaster = await client.query('SELECT COUNT(*) FROM public."Master"');
    console.log('Postgres Menu count:', resMenu.rows[0].count);
    console.log('Postgres Master count:', resMaster.rows[0].count);
    await client.end();
}

main().catch(console.error);
