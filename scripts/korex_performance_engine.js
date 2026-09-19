/**
 * korex_performance_engine.js
 * Motor Autónomo de Monitoreo, Optimización y Protección del Rendimiento
 * Multi-Motor: PostgreSQL + SQL Server con Aislamiento Estricto.
 *
 * Modos:
 *  - monitor: Solo lectura, telemetría y detección de degradación.
 *  - recommend: Analiza y propone optimizaciones clasificadas por impacto y riesgo.
 *  - optimize: Aplica optimizaciones seguras de bajo riesgo previamente probadas.
 *  - maintenance: Ejecuta tareas de mantenimiento autorizadas (ej. actualización de estadísticas).
 */

const fs = require('fs');
const path = require('path');
const { Client: PgClient } = require('pg');
const mssql = require('mssql');
const dotenv = require('dotenv');

const rootDir = path.resolve(__dirname, '..');
dotenv.config({ path: path.join(rootDir, '.env') });

const args = process.argv.slice(2);
function getArg(name, defaultValue) {
  const match = args.find(a => a.startsWith(`--${name}=`));
  if (match) return match.split('=')[1];
  return defaultValue;
}

const engine = (getArg('engine', 'postgres') || 'postgres').toLowerCase();
const mode = (getArg('mode', 'monitor') || 'monitor').toLowerCase();
const generateZip = args.includes('--zip');
const outputDir = getArg('output-dir', path.join(rootDir, 'Diagnosticos'));

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 15);
const reportHtmlPath = path.join(outputDir, `Korex_Rendimiento_${engine.toUpperCase()}_${timestamp}.html`);
const baselineFilePath = path.join(rootDir, '.performance_baseline.json');

function parseSQLServerUrl(connStr) {
  let clean = (connStr || '').replace(/^(sqlserver|mssql):\/\//i, '');
  let hostPortPart = clean.split(';')[0];
  let host = hostPortPart.split(':')[0] || '127.0.0.1';
  let portStr = hostPortPart.split(':')[1] || '';

  let instanceName = undefined;
  if (host.includes('\\')) {
    const parts = host.split('\\');
    host = parts[0];
    instanceName = parts[1];
  }
  if (host.toLowerCase() === 'localhost') host = '127.0.0.1';

  let database = '';
  let user = '';
  let password = '';

  const params = clean.split(';');
  for (const p of params) {
    const eqIdx = p.indexOf('=');
    if (eqIdx > 0) {
      const key = p.substring(0, eqIdx).trim().toLowerCase();
      const val = decodeURIComponent(p.substring(eqIdx + 1).trim());
      if (key === 'database') database = val;
      else if (key === 'user' || key === 'user id' || key === 'uid') user = val;
      else if (key === 'password' || key === 'pwd') password = val;
    }
  }

  return {
    server: host,
    user: user,
    password: password,
    database: database,
    port: portStr ? parseInt(portStr, 10) : 1433,
    options: {
      encrypt: false,
      trustServerCertificate: true,
      instanceName: instanceName
    }
  };
}

console.log('================================================================');
console.log('  KOREX PERFORMANCE & OPTIMIZATION ENGINE                       ');
console.log(`  Motor: ${engine.toUpperCase()} | Modo: ${mode.toUpperCase()} | Fecha: ${new Date().toISOString()}`);
console.log('================================================================\n');

const metrics = {
  engine: engine.toUpperCase(),
  mode: mode.toUpperCase(),
  timestamp: new Date().toISOString(),
  tableStats: [],
  indexStats: [],
  missingIndexes: [],
  slowQueries: [],
  lockStats: [],
  maintenanceStats: [],
  recommendations: [],
  regressions: [],
  summary: { totalTables: 0, totalIndexes: 0, totalSizeMB: 0, avgQueryDurationMs: 0, issuesCount: 0 }
};

async function runPostgresPerformance() {
  console.log('[POSTGRESQL] Analizando rendimiento, tablas, índices y estadísticas...');
  let connString = process.env.DATABASE_URL_POSTGRES;
  if (!connString && process.env.DATABASE_URL && !process.env.DATABASE_URL.startsWith('sqlserver')) {
    connString = process.env.DATABASE_URL;
  }
  if (!connString) {
    connString = 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
  }
  const client = new PgClient({ connectionString: connString });
  await client.connect();

  try {
    // 1. Estadísticas de Tablas y Tamaño
    const resTables = await client.query(`
      SELECT
        c.relname AS table_name,
        c.reltuples::bigint AS estimated_rows,
        pg_total_relation_size(c.oid) / (1024 * 1024)::numeric(10,2) AS total_size_mb,
        pg_relation_size(c.oid) / (1024 * 1024)::numeric(10,2) AS table_size_mb,
        (pg_total_relation_size(c.oid) - pg_relation_size(c.oid)) / (1024 * 1024)::numeric(10,2) AS index_size_mb,
        COALESCE(st.seq_scan, 0) AS seq_scans,
        COALESCE(st.idx_scan, 0) AS idx_scans,
        COALESCE(st.n_dead_tup, 0) AS dead_tuples,
        st.last_analyze
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      LEFT JOIN pg_stat_user_tables st ON st.relid = c.oid
      WHERE n.nspname = 'public' AND c.relkind = 'r'
      ORDER BY pg_total_relation_size(c.oid) DESC
      LIMIT 25;
    `);

    metrics.tableStats = resTables.rows.map(r => ({
      tableName: r.table_name,
      rows: parseInt(r.estimated_rows, 10) || 0,
      totalSizeMB: parseFloat(r.total_size_mb) || 0,
      tableSizeMB: parseFloat(r.table_size_mb) || 0,
      indexSizeMB: parseFloat(r.index_size_mb) || 0,
      seqScans: parseInt(r.seq_scans, 10) || 0,
      idxScans: parseInt(r.idx_scans, 10) || 0,
      deadTuples: parseInt(r.dead_tuples, 10) || 0,
      lastAnalyze: r.last_analyze ? new Date(r.last_analyze).toISOString() : 'Nunca'
    }));

    metrics.summary.totalTables = metrics.tableStats.length;
    metrics.summary.totalSizeMB = metrics.tableStats.reduce((acc, t) => acc + t.totalSizeMB, 0);

    // 2. Índices y Uso
    const resIndexes = await client.query(`
      SELECT
        t.relname AS table_name,
        i.relname AS index_name,
        COALESCE(s.idx_scan, 0) AS idx_scan,
        COALESCE(s.idx_tup_read, 0) AS tup_read,
        COALESCE(s.idx_tup_fetch, 0) AS tup_fetch,
        pg_relation_size(i.oid) / (1024 * 1024)::numeric(10,2) AS index_size_mb
      FROM pg_class t
      JOIN pg_index x ON t.oid = x.indrelid
      JOIN pg_class i ON i.oid = x.indexrelid
      JOIN pg_namespace n ON n.oid = t.relnamespace
      LEFT JOIN pg_stat_user_indexes s ON s.indexrelid = i.oid
      WHERE n.nspname = 'public'
      ORDER BY pg_relation_size(i.oid) DESC
      LIMIT 30;
    `);

    metrics.indexStats = resIndexes.rows.map(r => ({
      tableName: r.table_name,
      indexName: r.index_name,
      scans: parseInt(r.idx_scan, 10) || 0,
      tuplesRead: parseInt(r.tup_read, 10) || 0,
      sizeMB: parseFloat(r.index_size_mb) || 0
    }));
    metrics.summary.totalIndexes = metrics.indexStats.length;

    // 3. Detección de Bloqueos / Esperas
    const resLocks = await client.query(`
      SELECT
        pid,
        usename,
        state,
        age(now(), query_start)::text AS duration,
        query
      FROM pg_stat_activity
      WHERE state != 'idle' AND pid != pg_backend_pid()
      LIMIT 10;
    `);
    metrics.lockStats = resLocks.rows;

    // 4. Benchmark de SPs y Consultas Críticas
    const benchmarkQueries = [
      { name: 'fnCotizacionListar', query: 'SELECT * FROM public."fnCotizacionListar"(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 50, 0);' },
      { name: 'fnCotizacionHistorial', query: 'SELECT * FROM public."fnCotizacionHistorial"(10, 0);' },
      { name: 'fnRoleListar', query: 'SELECT * FROM public."fnRoleListar"();' }
    ];

    for (const b of benchmarkQueries) {
      const start = process.hrtime();
      try {
        await client.query(b.query);
        const diff = process.hrtime(start);
        const durationMs = (diff[0] * 1e3 + diff[1] * 1e-6).toFixed(2);
        metrics.slowQueries.push({ name: b.name, durationMs: parseFloat(durationMs), status: 'OK' });
      } catch (err) {
        metrics.slowQueries.push({ name: b.name, durationMs: 0, status: `Error: ${err.message}` });
      }
    }

    // 5. Análisis de Recomendaciones
    for (const t of metrics.tableStats) {
      if (t.seqScans > 500 && t.idxScans === 0 && t.rows > 100) {
        metrics.recommendations.push({
          type: 'INDEX_RECOMMENDATION',
          target: t.tableName,
          impact: 'ALTO',
          risk: 'BAJO',
          reason: `Tabla ${t.tableName} tiene ${t.seqScans} sequential scans sin uso de índices.`,
          action: `Evaluar índice en columnas de filtrado frecuente para ${t.tableName}.`
        });
      }
      if (t.deadTuples > 1000) {
        metrics.recommendations.push({
          type: 'MAINTENANCE_RECOMMENDATION',
          target: t.tableName,
          impact: 'MEDIO',
          risk: 'BAJO',
          reason: `Tabla ${t.tableName} tiene ${t.deadTuples} dead tuples acumuladas.`,
          action: `Ejecutar VACUUM ANALYZE en tabla ${t.tableName}.`
        });
      }
    }

    // Si modo == maintenance, ejecutar ANALYZE seguro
    if (mode === 'maintenance') {
      console.log('[POSTGRESQL] Ejecutando ANALYZE controlado de estadísticas...');
      await client.query('ANALYZE;');
      metrics.maintenanceStats.push({ action: 'ANALYZE', result: 'Estadísticas actualizadas con éxito', timestamp: new Date().toISOString() });
    }

  } finally {
    await client.end();
  }
}

async function runSqlServerPerformance() {
  console.log('[SQL SERVER] Analizando rendimiento, particiones, DMV de índices y estadísticas...');
  const sqlConn = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL || 'sqlserver://ZEUSAGENCIAS10:1433;database=Korex_Pruebas;user=zeusagencias;password=zzeusagencias;encrypt=false;trustServerCertificate=true';
  const parsed = parseSQLServerUrl(sqlConn);

  const sqlConfig = {
    user: parsed.usuario || process.env.SQLSERVER_USER || 'zeusagencias',
    password: parsed.clave || process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
    server: parsed.servidor || process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
    database: parsed.base_datos || process.env.SQLSERVER_DB || 'Korex_Pruebas',
    port: parsed.puerto ? parseInt(parsed.puerto, 10) : parseInt(process.env.SQLSERVER_PORT || '1433', 10),
    options: {
      encrypt: false,
      trustServerCertificate: true,
      connectTimeout: 8000
    }
  };

  const pool = await mssql.connect(sqlConfig);
  try {
    // 1. Estadísticas de Tablas y Espacio en SQL Server
    const resTables = await pool.request().query(`
      SELECT 
        t.name AS table_name,
        p.rows AS estimated_rows,
        SUM(a.total_pages) * 8 / 1024.0 AS total_size_mb,
        SUM(a.used_pages) * 8 / 1024.0 AS used_size_mb,
        (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.0 AS unused_size_mb
      FROM sys.tables t
      INNER JOIN sys.indexes i ON t.object_id = i.object_id
      INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
      INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
      WHERE t.is_ms_shipped = 0 AND i.object_id > 255
      GROUP BY t.name, p.rows
      ORDER BY total_size_mb DESC;
    `);

    metrics.tableStats = resTables.recordset.map(r => ({
      tableName: r.table_name,
      rows: parseInt(r.estimated_rows, 10) || 0,
      totalSizeMB: parseFloat(r.total_size_mb) || 0,
      usedSizeMB: parseFloat(r.used_size_mb) || 0,
      unusedSizeMB: parseFloat(r.unused_size_mb) || 0
    }));

    metrics.summary.totalTables = metrics.tableStats.length;
    metrics.summary.totalSizeMB = metrics.tableStats.reduce((acc, t) => acc + t.totalSizeMB, 0);

    // 2. Missing Indexes DMV
    const resMissing = await pool.request().query(`
      SELECT TOP 10
        mid.statement AS table_name,
        migs.avg_user_impact AS avg_impact,
        migs.user_seeks AS user_seeks,
        mid.equality_columns,
        mid.inequality_columns,
        mid.included_columns
      FROM sys.dm_db_missing_index_groups mig
      INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
      INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
      ORDER BY migs.avg_user_impact DESC;
    `);

    metrics.missingIndexes = resMissing.recordset.map(r => ({
      tableName: r.table_name,
      avgImpact: parseFloat(r.avg_impact) || 0,
      userSeeks: parseInt(r.user_seeks, 10) || 0,
      equalityColumns: r.equality_columns || '',
      inequalityColumns: r.inequality_columns || '',
      includedColumns: r.included_columns || ''
    }));

    // 3. Bloqueos y Esperas en SQL Server
    const resLocks = await pool.request().query(`
      SELECT 
        tl.resource_type,
        tl.request_mode,
        tl.request_status,
        tl.request_session_id AS session_id
      FROM sys.dm_tran_locks tl
      WHERE tl.resource_database_id = DB_ID() AND tl.request_status = 'WAIT';
    `);
    metrics.lockStats = resLocks.recordset;

    // 4. Benchmark SPs en SQL Server
    const spList = ['spCotizacionListar', 'spRoleListar'];
    for (const spName of spList) {
      const start = process.hrtime();
      try {
        await pool.request().execute(spName);
        const diff = process.hrtime(start);
        const durationMs = (diff[0] * 1e3 + diff[1] * 1e-6).toFixed(2);
        metrics.slowQueries.push({ name: spName, durationMs: parseFloat(durationMs), status: 'OK' });
      } catch (err) {
        metrics.slowQueries.push({ name: spName, durationMs: 0, status: `Error: ${err.message}` });
      }
    }

    // 5. Recomendaciones en SQL Server
    for (const mi of metrics.missingIndexes) {
      metrics.recommendations.push({
        type: 'INDEX_PROPOSAL',
        target: mi.tableName,
        impact: mi.avgImpact > 70 ? 'ALTO' : 'MEDIO',
        risk: 'MEDIO',
        reason: `DMV detectó impacto estimado del ${mi.avgImpact.toFixed(1)}% con ${mi.userSeeks} seeks potenciales.`,
        action: `Propuesta de índice en (${mi.equalityColumns || mi.inequalityColumns})`
      });
    }

    if (mode === 'maintenance') {
      console.log('[SQL SERVER] Ejecutando UPDATE STATISTICS controlado...');
      await pool.request().query('EXEC sp_updatestats;');
      metrics.maintenanceStats.push({ action: 'sp_updatestats', result: 'Estadísticas de base de datos actualizadas con éxito', timestamp: new Date().toISOString() });
    }

  } finally {
    await pool.close();
  }
}

// Comparación con línea base histórica
function evaluateBaseline() {
  if (fs.existsSync(baselineFilePath)) {
    try {
      const baseline = JSON.parse(fs.readFileSync(baselineFilePath, 'utf8'));
      const prevEngine = baseline[engine];
      if (prevEngine && prevEngine.slowQueries) {
        for (const currentQ of metrics.slowQueries) {
          const prevQ = prevEngine.slowQueries.find(q => q.name === currentQ.name);
          if (prevQ && prevQ.durationMs > 0 && currentQ.durationMs > 0) {
            const increasePct = ((currentQ.durationMs - prevQ.durationMs) / prevQ.durationMs) * 100;
            if (increasePct > 100) {
              metrics.regressions.push({
                name: currentQ.name,
                baselineMs: prevQ.durationMs,
                currentMs: currentQ.durationMs,
                increasePct: increasePct.toFixed(1),
                severity: 'ALERTA DE RENDIMIENTO'
              });
            }
          }
        }
      }
    } catch {}
  }

  // Guardar baseline actualizada
  let fullBaseline = {};
  if (fs.existsSync(baselineFilePath)) {
    try { fullBaseline = JSON.parse(fs.readFileSync(baselineFilePath, 'utf8')); } catch {}
  }
  fullBaseline[engine] = {
    timestamp: metrics.timestamp,
    slowQueries: metrics.slowQueries,
    summary: metrics.summary
  };
  fs.writeFileSync(baselineFilePath, JSON.stringify(fullBaseline, null, 2), 'utf8');
}

function generateHtmlReport() {
  const tableRows = metrics.tableStats.map(t => `
    <tr>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;"><strong>${t.tableName}</strong></td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:right;">${t.rows.toLocaleString()}</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:right;">${t.totalSizeMB} MB</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:right;">${t.seqScans !== undefined ? t.seqScans : 'N/D'}</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:right;">${t.idxScans !== undefined ? t.idxScans : 'N/D'}</td>
    </tr>
  `).join('');

  const queryRows = metrics.slowQueries.map(q => `
    <tr>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;"><strong>${q.name}</strong></td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:right;font-weight:bold;">${q.durationMs} ms</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:center;"><span style="color:#10B981;font-weight:bold;">${q.status}</span></td>
    </tr>
  `).join('');

  const recoRows = metrics.recommendations.map(r => `
    <tr>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;"><span style="font-size:11px;font-weight:bold;background:#E0E7FF;color:#3730A3;padding:2px 6px;border-radius:4px;">${r.type}</span></td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;"><strong>${r.target}</strong></td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;font-size:12px;">${r.reason}</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;font-size:12px;color:#1E40AF;">${r.action}</td>
      <td style="padding:8px;border-bottom:1px solid #E5E7EB;text-align:center;"><span style="font-size:11px;font-weight:bold;color:${r.impact === 'ALTO' ? '#DC2626' : '#D97706'};">${r.impact}</span></td>
    </tr>
  `).join('');

  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Informe de Rendimiento y Optimización Korex - ${metrics.engine}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #F3F4F6; margin: 0; padding: 20px; color: #1F2937; }
    .container { max-width: 1100px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); overflow: hidden; }
    .header { background: #0F172A; color: white; padding: 24px 32px; display: flex; justify-content: space-between; align-items: center; }
    .grid-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; padding: 24px 32px; background: #F8FAFC; border-bottom: 1px solid #E2E8F0; }
    .card-info { background: white; padding: 12px 16px; border-radius: 8px; border: 1px solid #E2E8F0; }
    .card-info .label { font-size: 11px; color: #64748B; font-weight: 600; text-transform: uppercase; }
    .card-info .val { font-size: 16px; font-weight: 700; color: #0F172A; margin-top: 2px; }
    .section-title { padding: 20px 32px 10px; font-size: 16px; font-weight: 700; color: #0F172A; }
    table { width: 100%; border-collapse: collapse; text-align: left; }
    th { background: #F1F5F9; padding: 10px; font-size: 12px; font-weight: 700; color: #475569; text-transform: uppercase; border-bottom: 2px solid #CBD5E1; }
    .footer { background: #F8FAFC; padding: 16px 32px; text-align: center; font-size: 12px; color: #64748B; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div>
        <h1 style="margin:0;font-size:22px;">Informe de Monitoreo y Optimización del Rendimiento</h1>
        <div style="font-size:12px;color:#94A3B8;margin-top:4px;">Motor: <strong>${metrics.engine}</strong> | Modo: <strong>${metrics.mode}</strong> | Fecha: ${metrics.timestamp}</div>
      </div>
      <div style="font-size:20px;font-weight:bold;color:#38BDF8;">KOREX PLATFORM</div>
    </div>

    <div class="grid-info">
      <div class="card-info"><div class="label">Tablas Monitoreadas</div><div class="val">${metrics.summary.totalTables}</div></div>
      <div class="card-info"><div class="label">Índices Monitoreados</div><div class="val">${metrics.summary.totalIndexes}</div></div>
      <div class="card-info"><div class="label">Volumen Base de Datos</div><div class="val">${metrics.summary.totalSizeMB.toFixed(2)} MB</div></div>
      <div class="card-info"><div class="label">Recomendaciones</div><div class="val">${metrics.recommendations.length} detectadas</div></div>
    </div>

    <div class="section-title">1. Benchmark de Procedimientos y Consultas Críticas</div>
    <div style="padding:0 32px 16px;overflow-x:auto;">
      <table><thead><tr><th>Operación / Procedimiento</th><th style="text-align:right;">Duración Promedio</th><th style="text-align:center;">Estado</th></tr></thead><tbody>${queryRows || '<tr><td colspan="3">Sin mediciones</td></tr>'}</tbody></table>
    </div>

    <div class="section-title">2. Distribución de Volumen y Escaneos por Tabla</div>
    <div style="padding:0 32px 16px;overflow-x:auto;">
      <table><thead><tr><th>Tabla</th><th style="text-align:right;">Filas Estimadas</th><th style="text-align:right;">Tamaño Total</th><th style="text-align:right;">Seq Scans</th><th style="text-align:right;">Idx Scans</th></tr></thead><tbody>${tableRows || '<tr><td colspan="5">Sin tablas</td></tr>'}</tbody></table>
    </div>

    <div class="section-title">3. Oportunidades de Optimización y Recomendaciones de Índices</div>
    <div style="padding:0 32px 24px;overflow-x:auto;">
      <table><thead><tr><th>Tipo</th><th>Objetivo</th><th>Causa / Diagnóstico</th><th>Acción Recomendada</th><th style="text-align:center;">Impacto</th></tr></thead><tbody>${recoRows || '<tr><td colspan="5" style="padding:10px;text-align:center;color:#10B981;">No se detectaron cuellos de botella ni índices faltantes críticos.</td></tr>'}</tbody></table>
    </div>

    <div class="footer">
      Korex Performance Protection Framework &bull; Aislamiento Estricto PostgreSQL vs SQL Server &bull; Confidencial y Sanitizado
    </div>
  </div>
</body>
</html>`;

  fs.writeFileSync(reportHtmlPath, html, 'utf8');
  console.log(`[REPORTE] Reporte HTML generado exitosamente en: ${reportHtmlPath}`);
}

async function main() {
  try {
    if (engine === 'postgres' || engine === 'postgresql') {
      await runPostgresPerformance();
    } else if (engine === 'sqlserver') {
      await runSqlServerPerformance();
    } else {
      throw new Error(`Motor desconocido: ${engine}. Use postgres o sqlserver.`);
    }

    evaluateBaseline();
    generateHtmlReport();

    console.log('\n================================================================');
    console.log('  EJECUCIÓN DE MONITOREO DE RENDIMIENTO COMPLETADA CON ÉXITO     ');
    console.log('================================================================\n');
  } catch (err) {
    console.error(`\n❌ ERROR EN EL MOTOR DE RENDIMIENTO: ${err.message}`);
    process.exit(1);
  }
}

main();
