const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

async function main() {
    await client.connect();
    await client.query(`
        UPDATE public."SystemParameter" 
        SET value = '' 
        WHERE code IN ('LICENSE_KEY', 'LICENSE_EXPIRATION_DATE', 'AGENCY_NAME', 'AGENCY_NIT')
    `);
    console.log('✅ Parámetros de licencia y agencia blanqueados correctamente en PostgreSQL local.');
    await client.end();
}

main().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
