import path from 'path';
import fs from 'fs';
import { executePostgresQuery } from './postgres';
import { executeSQLServerProcedure } from './sqlserver';

export interface HealthStatus {
  appVersion: string;
  dbVersion: string | null;
  build: string | null;
  engine: 'PostgreSQL' | 'SQLServer';
  status: 'HEALTHY' | 'UNHEALTHY' | 'MISMATCH' | 'UNKNOWN';
  message: string;
  checkedAt: string;
}

let cachedHealth: HealthStatus | null = null;
let lastCheckTime = 0;

export async function checkSystemHealth(forceRefresh = false): Promise<HealthStatus> {
  const now = Date.now();
  // Cache for 60 seconds unless forced
  if (!forceRefresh && cachedHealth && (now - lastCheckTime < 60000)) {
    return cachedHealth;
  }

  let appVersion = '3.7.13';
  try {
    const pkgPath = path.resolve(process.cwd(), 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if (pkg.version) appVersion = pkg.version;
    }
  } catch (e) {}

  const isSQLServer = (process.env.DB_ENGINE || '').toLowerCase() === 'sqlserver' || process.env.IS_SQLSERVER === 'true';
  const engine = isSQLServer ? 'SQLServer' : 'PostgreSQL';

  let dbVersion: string | null = null;
  let build: string | null = null;
  let dbStatus = 'UNKNOWN';
  let message = 'Sistema operando normalmente.';

  try {
    if (isSQLServer) {
      const rows = await executeSQLServerProcedure('spKorexGetHealthStatus', {});
      if (rows && rows.length > 0) {
        dbVersion = rows[0].DbVersion;
        build = rows[0].Build;
        dbStatus = rows[0].Status || 'HEALTHY';
      }
    } else {
      const rows = await executePostgresQuery<{ DbVersion: string; Build: string; Status: string }>(
        `SELECT "DbVersion", "Build", "Status" FROM public."Korex_Installation" ORDER BY id DESC LIMIT 1`
      );
      if (rows && rows.length > 0) {
        dbVersion = rows[0].DbVersion;
        build = rows[0].Build;
        dbStatus = rows[0].Status || 'HEALTHY';
      }
    }
  } catch (err: any) {
    message = `Advertencia de conexión o estructura: ${err.message}`;
  }

  let status: 'HEALTHY' | 'UNHEALTHY' | 'MISMATCH' | 'UNKNOWN' = 'HEALTHY';
  if (dbStatus !== 'HEALTHY' && dbStatus !== 'UNKNOWN') {
    status = 'UNHEALTHY';
    message = `La base de datos tiene estado ${dbStatus}. Ejecute node scripts/korex_diagnostico.js --repair`;
  } else if (dbVersion && dbVersion !== appVersion) {
    status = 'MISMATCH';
    message = `Descalce de versión detectado: Código v${appVersion} vs Base de Datos v${dbVersion}.`;
  }

  cachedHealth = {
    appVersion,
    dbVersion,
    build,
    engine,
    status,
    message,
    checkedAt: new Date().toISOString()
  };
  lastCheckTime = now;

  return cachedHealth;
}
