const mssql = require('mssql');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

async function testConnection() {
  const args = process.argv.slice(2);
  let envHost = process.env.DB_HOST || process.env.SQLSERVER_HOST;
  let envPort = process.env.DB_PORT || process.env.SQLSERVER_PORT;
  let envUser = process.env.DB_USER || process.env.SQLSERVER_USER;
  let envPass = process.env.DB_PASSWORD || process.env.SQLSERVER_PASSWORD;
  let envDb = process.env.DB_NAME || process.env.SQLSERVER_DB;

  const dbUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL || '';
  if (dbUrl && (!envHost || !envUser || !envPass)) {
      const matchHost = dbUrl.match(/(?:sqlserver|mssql):\/\/([^:;\/]+)(?::(\d+))?/i);
      const matchUser = dbUrl.match(/user=([^;]+)/i);
      const matchPass = dbUrl.match(/password=([^;]+)/i);
      const matchDb = dbUrl.match(/database=([^;]+)/i);

      if (matchHost) envHost = envHost || matchHost[1];
      if (matchHost && matchHost[2]) envPort = envPort || matchHost[2];
      if (matchUser) envUser = envUser || matchUser[1];
      if (matchPass) envPass = envPass || matchPass[1];
      if (matchDb) envDb = envDb || matchDb[1];
  }

  const host = args[0] || envHost || '127.0.0.1';
  const port = parseInt(args[1] || envPort || '1433', 10);
  const user = args[2] || envUser || 'sa';
  const password = args[3] || envPass || '';
  const database = args[4] || envDb || 'Korex_pruebas';

  console.log('============================================================');
  console.log('  PRUEBA PREVIA DE CONEXIÓN A SQL SERVER (PRE-BUILD CHECK)');
  console.log('============================================================');
  console.log(`  - Servidor: ${host}:${port}`);
  console.log(`  - Base de datos: ${database}`);
  console.log(`  - Usuario: ${user}`);
  console.log('------------------------------------------------------------');

  const config = {
    user,
    password,
    server: host.toLowerCase() === 'localhost' ? '127.0.0.1' : host,
    port,
    database,
    options: {
      encrypt: false,
      trustServerCertificate: true
    },
    connectionTimeout: 8000,
    requestTimeout: 15000
  };

  try {
    const pool = await mssql.connect(config);
    const res = await pool.request().query("SELECT SERVERPROPERTY('MachineName') as MachineName, DB_NAME() as CurrentDb");
    const info = res.recordset[0];
    console.log(`✅ Conexión Exitosa con SQL Server: [${info.MachineName} / ${info.CurrentDb}]`);
    await pool.close();
    process.exit(0);
  } catch (err) {
    console.error(`\n❌ ERROR CRÍTICO DE CONEXIÓN [Exit Code 4]:`);
    console.error(`   No fue posible conectarse a SQL Server en [${host}:${port}].`);
    console.error(`   Detalle técnico: ${err.message}`);
    console.error(`   PROHIBIDO CONTINUAR: El proceso de actualización/generación fue CANCELADO.\n`);
    process.exit(4);
  }
}

if (require.main === module) {
  testConnection();
}

module.exports = { testConnection };
