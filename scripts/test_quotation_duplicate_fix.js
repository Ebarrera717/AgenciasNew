require('dotenv').config();
const { Client } = require('pg');

async function testDuplicate() {
    const pgUrl = process.env.DATABASE_URL_POSTGRES || (process.env.DATABASE_URL && (process.env.DATABASE_URL.startsWith('postgresql://') || process.env.DATABASE_URL.startsWith('postgres://')) ? process.env.DATABASE_URL : 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public');

    let clientConfig = { connectionString: pgUrl };
    try {
      const u = new URL(pgUrl);
      clientConfig = {
        user: u.username || 'postgres',
        password: decodeURIComponent(u.password || ''),
        host: u.hostname || 'localhost',
        port: parseInt(u.port || '5432', 10),
        database: u.pathname.replace(/^\//, '') || 'Korex_colaereo'
      };
    } catch (e) {
      clientConfig = { connectionString: pgUrl };
    }

    const client = new Client(clientConfig);
    await client.connect();

    console.log('--- COTIZACIONES ANTES DE SANEAMIENTO ---');
    const before = await client.query('SELECT id, "internalNumber" FROM public."Quotation" ORDER BY id DESC LIMIT 5;');
    console.table(before.rows);

    // Ejecutar saneamiento de internalNumber
    await client.query(`
        UPDATE public."Quotation"
        SET "internalNumber" = id::text
        WHERE "internalNumber" IS NULL 
           OR "internalNumber" LIKE 'QUO-%' 
           OR "internalNumber" LIKE 'TEMP_%'
           OR "internalNumber" = '';
    `);

    console.log('--- COTIZACIONES DESPUÉS DE SANEAMIENTO ---');
    const after = await client.query('SELECT id, "internalNumber" FROM public."Quotation" ORDER BY id DESC LIMIT 5;');
    console.table(after.rows);

    // Probar duplicar la cotización más reciente
    const topId = after.rows[0].id;
    console.log(`Probando spCotizacionDuplicar sobre cotización ID #${topId}...`);
    const dupRes = await client.query(`CALL public."spCotizacionDuplicar"($1::INT, $2::INT, $3::INT, $4::TEXT);`, [topId, 1, 0, '']);
    console.log('Resultado spCotizacionDuplicar:', dupRes.rows);

    const checkNew = await client.query('SELECT id, "internalNumber", "totalAmount" FROM public."Quotation" ORDER BY id DESC LIMIT 2;');
    console.table(checkNew.rows);

    const newQuo = checkNew.rows[0];
    if (String(newQuo.id) === String(newQuo.internalNumber)) {
        console.log(`✅ TEST SUPERADO: La cotización nueva #${newQuo.id} tiene internalNumber = '${newQuo.internalNumber}'.`);
    } else {
        console.error(`❌ TEST FALLIDO: La cotización nueva #${newQuo.id} tiene internalNumber = '${newQuo.internalNumber}'.`);
    }

    // Limpiar cotización creada en la prueba
    await client.query('DELETE FROM public."Quotation" WHERE id = $1;', [newQuo.id]);
    console.log(`Limpieza de prueba completada (eliminada cotización temporal #${newQuo.id}).`);

    await client.end();
}

testDuplicate().catch(console.error);
