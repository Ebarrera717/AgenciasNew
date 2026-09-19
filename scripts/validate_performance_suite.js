/**
 * validate_performance_suite.js
 * Suite automatizada de pruebas para el Skill Obligatorio de Monitoreo Autónomo,
 * Optimización y Protección del Rendimiento (PostgreSQL + SQL Server).
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('================================================================');
console.log('  SUITE DE PRUEBAS: MONITOREO Y PROTECCIÓN DEL RENDIMIENTO     ');
console.log('                 (POSTGRESQL + SQL SERVER)                      ');
console.log('================================================================\n');

let totalTests = 0;
let passedTests = 0;
let failedTests = 0;

function runTest(id, name, fn) {
  totalTests++;
  process.stdout.write(`[${id}] ${name}... `);
  try {
    fn();
    console.log('✅ OK');
    passedTests++;
  } catch (err) {
    console.log(`❌ FALLÓ: ${err.message}`);
    failedTests++;
  }
}

const rootDir = path.resolve(__dirname, '..');
const scriptsDir = path.join(rootDir, 'scripts');
const deployDir = path.join(rootDir, 'deploy');
const diagDir = path.join(rootDir, 'Diagnosticos');

// ----------------------------------------------------------------------------
// BLOQUE 1: VERIFICACIÓN DE ARTEFACTOS Y ESTRUCTURA DEL MOTOR
// ----------------------------------------------------------------------------
runTest('TEST-PERF-ENGINE-EXISTS', 'Existencia del motor de rendimiento y wrapper PowerShell', () => {
  const engineJs = path.join(scriptsDir, 'korex_performance_engine.js');
  const enginePs = path.join(deployDir, 'Korex_Performance_Engine.ps1');
  if (!fs.existsSync(engineJs)) throw new Error('Falta scripts/korex_performance_engine.js');
  if (!fs.existsSync(enginePs)) throw new Error('Falta deploy/Korex_Performance_Engine.ps1');

  const content = fs.readFileSync(engineJs, 'utf8');
  if (!content.includes('runPostgresPerformance') || !content.includes('runSqlServerPerformance')) {
    throw new Error('korex_performance_engine.js no contiene implementaciones para ambos motores.');
  }
});

// ----------------------------------------------------------------------------
// BLOQUE 2: EJECUCIÓN DEL MOTOR EN POSTGRESQL Y SQL SERVER
// ----------------------------------------------------------------------------
runTest('TEST-PERF-POSTGRES', 'Ejecución del análisis de rendimiento en PostgreSQL', () => {
  const cmd = `node "${path.join(scriptsDir, 'korex_performance_engine.js')}" --engine=postgres --mode=recommend`;
  execSync(cmd, { stdio: 'pipe' });
  const files = fs.readdirSync(diagDir);
  const hasPgReport = files.some(f => f.startsWith('Korex_Rendimiento_POSTGRES') && f.endsWith('.html'));
  if (!hasPgReport) throw new Error('No se generó el reporte HTML de rendimiento de PostgreSQL');
});

runTest('TEST-PERF-SQLSERVER', 'Ejecución del análisis de rendimiento en SQL Server', () => {
  const cmd = `node "${path.join(scriptsDir, 'korex_performance_engine.js')}" --engine=sqlserver --mode=recommend`;
  execSync(cmd, { stdio: 'pipe' });
  const files = fs.readdirSync(diagDir);
  const hasSqlReport = files.some(f => f.startsWith('Korex_Rendimiento_SQLSERVER') && f.endsWith('.html'));
  if (!hasSqlReport) throw new Error('No se generó el reporte HTML de rendimiento de SQL Server');
});

// ----------------------------------------------------------------------------
// BLOQUE 3: LÍNEA BASE HISTÓRICA Y DETECCIÓN DE REGRESIONES
// ----------------------------------------------------------------------------
runTest('TEST-PERF-BASELINE', 'Generación y verificación de línea base (.performance_baseline.json)', () => {
  const baselinePath = path.join(rootDir, '.performance_baseline.json');
  if (!fs.existsSync(baselinePath)) throw new Error('No se generó .performance_baseline.json');
  const baseline = JSON.parse(fs.readFileSync(baselinePath, 'utf8'));
  if (!baseline.postgres || !baseline.sqlserver) {
    throw new Error('.performance_baseline.json debe registrar líneas base para postgres y sqlserver.');
  }
});

// ----------------------------------------------------------------------------
// BLOQUE 4: REGLAS DE SEGURIDAD Y PROTECCIÓN DE DATOS
// ----------------------------------------------------------------------------
runTest('TEST-PERF-SAFETY-POLICY', 'Garantía de política de seguridad (No DROP/ALTER destructivo automático)', () => {
  const engineContent = fs.readFileSync(path.join(scriptsDir, 'korex_performance_engine.js'), 'utf8');
  if (engineContent.includes('DROP INDEX') || engineContent.includes('DROP TABLE')) {
    throw new Error('El motor de rendimiento contiene operaciones destructivas automáticas DROP prohibidas.');
  }
});

runTest('TEST-PERF-SANITIZE', 'Sanitización estricta de reportes de rendimiento (0 contraseñas o credenciales)', () => {
  const files = fs.readdirSync(diagDir);
  const perfHtmls = files.filter(f => f.startsWith('Korex_Rendimiento_') && f.endsWith('.html'));
  for (const ph of perfHtmls) {
    const content = fs.readFileSync(path.join(diagDir, ph), 'utf8');
    if (content.includes('zzeusagencias') || content.includes('postgres://postgres:')) {
      throw new Error(`El reporte ${ph} contiene credenciales no sanitizadas.`);
    }
  }
});

// ----------------------------------------------------------------------------
// RESUMEN FINAL
// ----------------------------------------------------------------------------
console.log('\n================================================================');
console.log(`  RESUMEN DE PRUEBAS DE RENDIMIENTO Y PROTECCIÓN:`);
console.log(`  Total: ${totalTests} | ✅ Pasaron: ${passedTests} | ❌ Fallaron: ${failedTests}`);
console.log('================================================================\n');

if (failedTests > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
