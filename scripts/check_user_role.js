const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

async function main() {
    await client.connect();
    const res = await client.query(`
        SELECT u.id, u.name, u.email, u."roleId", r.name AS role_name
        FROM public."User" u
        LEFT JOIN public."Role" r ON u."roleId" = r.id
        WHERE u.email = 'ebarrera@zagencias.com'
    `);
    console.log('User record:', res.rows);
    const allRoles = await client.query('SELECT * FROM public."Role"');
    console.log('All roles:', allRoles.rows);
    await client.end();
}

main().catch(console.error);
