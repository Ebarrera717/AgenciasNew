const { Client } = require('pg');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

async function testPostgresConnection() {
  const args = process.argv.slice(2);
  let host = args[0] || process.env.DB_HOST || 'localhost';
  let port = parseInt(args[1] || process.env.DB_PORT || '5432', 10);
  let user = args[2] || process.env.DB_USER || 'postgres';
  let password = args[3] || process.env.DB_PASSWORD || '';
  let database = args[4] || process.env.DB_NAME || 'Korex_colaereo';

  const pgUrl = process.env.DATABASE_URL_POSTGRES || (process.env.DATABASE_URL && (process.env.DATABASE_URL.startsWith('postgresql://') || process.env.DATABASE_URL.startsWith('postgres://')) ? process.env.DATABASE_URL : null);

  if (pgUrl && (!args[0] || args[0].trim() === '')) {
    try {
      const u = new URL(pgUrl);
      host = u.hostname || host;
      port = parseInt(u.port || '5432', 10);
      user = u.username || user;
      password = decodeURIComponent(u.password || '');
      database = u.pathname.replace(/^\//, '') || database;
    } catch (e) {}
  }

  console.log('============================================================');
  console.log('  PRUEBA PREVIA DE CONEXIÓN A POSTGRESQL (PRE-BUILD CHECK)');
  console.log('============================================================');
  console.log(`  - Servidor: ${host}:${port}`);
  console.log(`  - Base de datos: ${database}`);
  console.log(`  - Usuario: ${user}`);
  console.log('------------------------------------------------------------');

  const clientConfig = {
    user,
    password,
    host: host.toLowerCase() === 'localhost' ? '127.0.0.1' : host,
    port,
    database,
    connectionTimeoutMillis: 8000
  };

  const client = new Client(clientConfig);

  try {
    await client.connect();
    const res = await client.query("SELECT current_database() as db, current_user as usr, inet_server_addr() as host_addr");
    const info = res.rows[0];
    console.log(`✅ Conexión Exitosa con PostgreSQL: [${info.host_addr || host}:${port} / ${info.db}]`);
    await client.end();
    process.exit(0);
  } catch (err) {
    console.error(`\n❌ ERROR CRÍTICO DE CONEXIÓN POSTGRESQL [Exit Code 4]:`);
    console.error(`   No fue posible conectarse a PostgreSQL en [${host}:${port}].`);
    console.error(`   Detalle técnico: ${err.message}`);
    console.error(`   PROHIBIDO CONTINUAR: El proceso de actualización/generación fue CANCELADO.\n`);
    process.exit(4);
  }
}

if (require.main === module) {
  testPostgresConnection();
}

module.exports = { testPostgresConnection };
