const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const { runGuardianValidation } = require('./korex_updater_guardian');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const isSQLServer = (process.env.DB_ENGINE || '').toLowerCase() === 'sqlserver' || process.env.IS_SQLSERVER === 'true';

async function main() {
  const args = process.argv.slice(2);
  const command = args[0] || '--status';

  console.log('============================================================');
  console.log('KOREX DIAGNÓSTICO Y AUTO-REPARACIÓN DE PRODUCCIÓN');
  console.log('============================================================');
  console.log(`Comando: ${command}`);
  console.log(`Motor activo: ${isSQLServer ? 'Microsoft SQL Server' : 'PostgreSQL'}`);
  console.log('------------------------------------------------------------');

  if (command === '--status') {
    await showStatus();
  } else if (command === '--validate') {
    await runGuardianValidation();
  } else if (command === '--repair') {
    await runRepair();
  } else if (command === '--report-zip') {
    await generateReportZip();
  } else {
    console.log('Comandos disponibles:');
    console.log('  --status      : Muestra la versión instalada y el historial de actualización');
    console.log('  --validate    : Valida el 100% de los objetos contra el manifest');
    console.log('  --repair      : Recompila procedimientos y funciones faltantes o dañados');
    console.log('  --report-zip  : Genera un reporte comprimido (KOREX-DIAG-*.zip) para soporte');
  }
}

async function showStatus() {
  if (isSQLServer) {
    const mssql = require('mssql');
    const pool = await mssql.connect({
      user: process.env.DB_USER || 'sa',
      password: process.env.DB_PASSWORD || '',
      server: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '1433', 10),
      database: process.env.DB_NAME || 'Korex_pruebas',
      options: { encrypt: false, trustServerCertificate: true }
    });

    const instRes = await pool.request().query(`SELECT TOP 1 * FROM dbo.Korex_Installation ORDER BY id DESC`);
    const histRes = await pool.request().query(`SELECT TOP 5 * FROM dbo.Korex_UpdateHistory ORDER BY UpdateId DESC`);

    console.log('ESTADO DE LA INSTALACIÓN (SQL SERVER):');
    if (instRes.recordset.length > 0) {
      const inst = instRes.recordset[0];
      console.log(`  - Versión Aplicación: ${inst.AppVersion}`);
      console.log(`  - Versión BD: ${inst.DbVersion}`);
      console.log(`  - Build: ${inst.Build}`);
      console.log(`  - Estado: ${inst.Status}`);
      console.log(`  - Última Validación: ${inst.LastValidationDate}`);
    } else {
      console.log('  - No se encontró registro en Korex_Installation.');
    }

    console.log('\nÚLTIMAS ACTUALIZACIONES:');
    for (const h of histRes.recordset) {
      console.log(`  [Id #${h.UpdateId}] v${h.VersionNueva} (${h.Estado}) - ${h.FechaFin || h.FechaInicio} - ${h.ResumenLog || ''}`);
    }

    await pool.close();
  } else {
    const { Client } = require('pg');
    const pgUrl = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const client = new Client({ connectionString: pgUrl });
    await client.connect();

    const instRes = await client.query(`SELECT * FROM public."Korex_Installation" ORDER BY id DESC LIMIT 1`);
    const histRes = await client.query(`SELECT * FROM public."Korex_UpdateHistory" ORDER BY "UpdateId" DESC LIMIT 5`);

    console.log('ESTADO DE LA INSTALACIÓN (POSTGRESQL):');
    if (instRes.rows.length > 0) {
      const inst = instRes.rows[0];
      console.log(`  - Versión Aplicación: ${inst.AppVersion}`);
      console.log(`  - Versión BD: ${inst.DbVersion}`);
      console.log(`  - Build: ${inst.Build}`);
      console.log(`  - Estado: ${inst.Status}`);
      console.log(`  - Última Validación: ${inst.LastValidationDate}`);
    } else {
      console.log('  - No se encontró registro en Korex_Installation.');
    }

    console.log('\nÚLTIMAS ACTUALIZACIONES:');
    for (const h of histRes.rows) {
      console.log(`  [Id #${h.UpdateId}] v${h.VersionNueva} (${h.Estado}) - ${h.FechaFin || h.FechaInicio} - ${h.ResumenLog || ''}`);
    }

    await client.end();
  }
}

async function runRepair() {
  console.log('Iniciando proceso de reparación de objetos SQL...');
  if (isSQLServer) {
    const { execSync } = require('child_process');
    console.log('Recompilando procedimientos T-SQL...');
    const syncScript = path.resolve(__dirname, '../deploy/sync_zeus_erp.js');
    if (fs.existsSync(syncScript)) {
      execSync(`node "${syncScript}"`, { stdio: 'inherit' });
    }
  } else {
    const genScript = path.resolve(__dirname, '../deploy/gen_schema_json.js');
    const { execSync } = require('child_process');
    console.log('Recompilando funciones PostgreSQL...');
    execSync(`node "${genScript}"`, { stdio: 'inherit' });
  }

  console.log('\nEjecutando re-verificación tras autoreparación...');
  await runGuardianValidation();
}

async function generateReportZip() {
  const archiver = require('archiver');
  const diagDir = path.resolve(__dirname, '../diagnostics');
  if (!fs.existsSync(diagDir)) fs.mkdirSync(diagDir, { recursive: true });

  const timestamp = new Date().toISOString().replace(/[-T:]/g, '').slice(0, 14);
  const zipName = `KOREX-DIAG-${timestamp}.zip`;
  const zipPath = path.join(diagDir, zipName);

  const output = fs.createWriteStream(zipPath);
  const archive = archiver('zip', { zlib: { level: 9 } });

  output.on('close', () => {
    console.log(`\n✅ Diagnóstico de producción generado exitosamente (${archive.pointer()} bytes):`);
    console.log(`   Ruta: ${zipPath}`);
  });

  archive.pipe(output);

  // Add env info sanitized
  let envSanitized = '';
  if (fs.existsSync(path.resolve(__dirname, '../.env'))) {
    const envRaw = fs.readFileSync(path.resolve(__dirname, '../.env'), 'utf8');
    envSanitized = envRaw.replace(/(PASSWORD|SECRET|KEY|TOKEN)\s*=\s*[^\r\n]+/gi, '$1=***REDACTED***');
  }
  archive.append(envSanitized, { name: 'env-sanitized.txt' });

  // Add release manifests
  const manifestSqlServer = path.resolve(__dirname, '../SQL/manifest-sqlserver.json');
  const manifestPg = path.resolve(__dirname, '../SQL/manifest-postgresql.json');
  if (fs.existsSync(manifestSqlServer)) archive.file(manifestSqlServer, { name: 'manifest-sqlserver.json' });
  if (fs.existsSync(manifestPg)) archive.file(manifestPg, { name: 'manifest-postgresql.json' });

  // Add logs
  const logsDir = path.resolve(__dirname, '../logs');
  if (fs.existsSync(logsDir)) {
    archive.directory(logsDir, 'logs');
  }

  await archive.finalize();
}

if (require.main === module) {
  main().catch(err => {
    console.error('Error en Korex Diagnóstico:', err);
    process.exit(1);
  });
}
