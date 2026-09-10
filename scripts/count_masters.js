const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

async function main() {
    await client.connect();
    const tables = ['Countries', 'Cities', 'Airports', 'Payment'];
    for (const t of tables) {
        try {
            const res = await client.query(`SELECT COUNT(*) FROM public."${t}"`);
            console.log(`${t}: ${res.rows[0].count} registros`);
        } catch (e) {
            console.log(`${t}: error - ${e.message}`);
        }
    }
    await client.end();
}

main().catch(console.error);
