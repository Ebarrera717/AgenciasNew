const { Pool } = require('pg');
require('dotenv').config();

async function test() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const pool = new Pool({ connectionString: pgUrl });
    const client = await pool.connect();

    try {
        console.log('1. Testing spCityCrear with NULL countriesId...');
        const testCode = 'TC' + Math.floor(Math.random() * 10000);
        const query = `CALL public."spCityCrear"('${testCode}', 'Ciudad Prueba Null', null, 'CUN', 'TST', 1, null, null)`;
        const res = await client.query(query);
        console.log('spCityCrear Output:', res.rows);

        console.log('Listing cities via fnCityListar...');
        const listRes = await client.query('SELECT * FROM public."fnCityListar"()');
        const created = listRes.rows.find(c => c.code === testCode);
        if (created) {
            console.log('Created city successfully located:', created);
            console.log('Cleaning up test city ID:', created.id);
            await client.query(`CALL public."spCityEliminar"(${created.id}, 1, null)`);
            console.log('Test city deleted cleanly.');
        } else {
            throw new Error('Created city not found in fnCityListar');
        }

        console.log('\n2. Testing spAirportCrear with NULL citiesId...');
        const testApCode = 'AP' + Math.floor(Math.random() * 10000);
        const apQuery = `CALL public."spAirportCrear"('${testApCode}', 'Aeropuerto Prueba Null', null, 1, null, null)`;
        const apRes = await client.query(apQuery);
        console.log('spAirportCrear Output:', apRes.rows);

        console.log('Listing airports via fnAirportListar...');
        const apListRes = await client.query('SELECT * FROM public."fnAirportListar"()');
        const createdAp = apListRes.rows.find(a => a.code === testApCode);
        if (createdAp) {
            console.log('Created airport successfully located:', createdAp);
            console.log('Cleaning up test airport ID:', createdAp.id);
            await client.query(`CALL public."spAirportEliminar"(${createdAp.id}, 1, null)`);
            console.log('Test airport deleted cleanly.');
        } else {
            throw new Error('Created airport not found in fnAirportListar');
        }

        console.log('\n✅ ALL TESTS PASSED: CITIES & AIRPORTS CREATION AND LISTING ARE 100% OPERATIONAL!');
    } catch (e) {
        console.error('❌ Error during test:', e);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}
test();
