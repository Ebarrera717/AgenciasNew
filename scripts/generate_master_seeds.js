const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:111985@192.168.80.26:5432/Korex_colaereo'
});

function escapeSql(str) {
    if (str === null || str === undefined) return 'NULL';
    return "N'" + String(str).replace(/'/g, "''") + "'";
}

async function generateMasterSeeds() {
    await client.connect();

    console.log('Obteniendo datos maestros desde PostgreSQL...');

    // 1. Countries
    const resCountries = await client.query(`SELECT id, code, name, dane, region, prefix, "curencyId", "isActive" FROM public."Countries" ORDER BY id ASC`);
    const countryIdMap = new Map(); // old id -> code

    let tsql = `\n-- ============================================================================\n-- 7. MAESTROS GLOBALES (Países, Ciudades, Aeropuertos, Formas de Pago)\n-- ============================================================================\n\n`;

    tsql += `-- 7.1 Países (${resCountries.rows.length} registros)\n`;
    for (const c of resCountries.rows) {
        countryIdMap.set(c.id, c.code);
        const codeEsc = escapeSql(c.code);
        const nameEsc = escapeSql(c.name);
        const daneEsc = escapeSql(c.dane);
        const regionEsc = escapeSql(c.region);
        const prefixEsc = escapeSql(c.prefix);
        const active = c.isActive !== false ? 1 : 0;
        tsql += `IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = ${codeEsc}) INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (${codeEsc}, ${nameEsc}, ${daneEsc}, ${regionEsc}, ${prefixEsc}, ${active});\n`;
    }

    // 2. Cities
    const resCities = await client.query(`SELECT id, code, name, "countriesId", statecode, iata, "isActive" FROM public."Cities" ORDER BY id ASC`);
    const cityIdMap = new Map(); // old id -> code

    tsql += `\n-- 7.2 Ciudades (${resCities.rows.length} registros)\n`;
    for (const c of resCities.rows) {
        cityIdMap.set(c.id, c.code);
        const codeEsc = escapeSql(c.code);
        const nameEsc = escapeSql(c.name);
        const stateEsc = escapeSql(c.statecode);
        const iataEsc = escapeSql(c.iata);
        const active = c.isActive !== false ? 1 : 0;
        const countryCode = c.countriesId ? countryIdMap.get(c.countriesId) : null;
        const countrySubquery = countryCode ? `(SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = ${escapeSql(countryCode)})` : 'NULL';

        tsql += `IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = ${codeEsc}) INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (${codeEsc}, ${nameEsc}, ${countrySubquery}, ${stateEsc}, ${iataEsc}, ${active});\n`;
    }

    // 3. Airports
    const resAirports = await client.query(`SELECT id, code, name, "citiesId", "isActive" FROM public."Airports" ORDER BY id ASC`);
    tsql += `\n-- 7.3 Aeropuertos (${resAirports.rows.length} registros)\n`;
    for (const a of resAirports.rows) {
        const codeEsc = escapeSql(a.code);
        const nameEsc = escapeSql(a.name);
        const active = a.isActive !== false ? 1 : 0;
        const cityCode = a.citiesId ? cityIdMap.get(a.citiesId) : null;
        const citySubquery = cityCode ? `(SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = ${escapeSql(cityCode)})` : 'NULL';

        tsql += `IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = ${codeEsc}) INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (${codeEsc}, ${nameEsc}, ${citySubquery}, ${active});\n`;
    }

    // 4. Payment (Formas de Pago)
    const resPayment = await client.query(`SELECT id, code, name, "isActive" FROM public."Payment" ORDER BY id ASC`);
    tsql += `\n-- 7.4 Formas de Pago (${resPayment.rows.length} registros)\n`;
    for (const p of resPayment.rows) {
        const codeEsc = escapeSql(p.code);
        const nameEsc = escapeSql(p.name);
        const active = p.isActive !== false ? 1 : 0;
        tsql += `IF NOT EXISTS (SELECT 1 FROM dbo.[Payment] WHERE [code] = ${codeEsc}) INSERT INTO dbo.[Payment] ([code], [name], [isActive]) VALUES (${codeEsc}, ${nameEsc}, ${active});\n`;
    }

    await client.end();

    const seedsFilePath = path.join(__dirname, '..', 'SQL', 'SqlServer', '02_Seeds.sql');
    let seedsContent = fs.readFileSync(seedsFilePath, 'utf8');

    // Strip previous section 7 if present
    if (seedsContent.includes('-- 7. MAESTROS GLOBALES')) {
        seedsContent = seedsContent.split('-- 7. MAESTROS GLOBALES')[0].trimEnd() + '\n';
    }

    seedsContent = seedsContent.trimEnd() + '\n' + tsql;
    fs.writeFileSync(seedsFilePath, seedsContent, 'utf8');
    console.log(`✅ ${resCountries.rows.length} Países, ${resCities.rows.length} Ciudades, ${resAirports.rows.length} Aeropuertos y ${resPayment.rows.length} Formas de Pago inyectados exitosamente en SQL/SqlServer/02_Seeds.sql`);
}

generateMasterSeeds().catch(err => {
    console.error('Error generando semillas maestras:', err);
    process.exit(1);
});
