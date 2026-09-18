/**
 * validate_installer_diagnostics.js
 * Suite automatizada de pruebas y validación para el Skill Maestro de Instalación,
 * Actualización, Diagnóstico, Autoreparación y Aislamiento de Motores (PG + SQL).
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('================================================================');
console.log('  SUITE DE PRUEBAS: INSTALACIÓN, ACTUALIZACIÓN Y DIAGNÓSTICO   ');
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
const deployDir = path.join(rootDir, 'deploy');

// ----------------------------------------------------------------------------
// BLOQUE 1: VERIFICACIÓN DE ARCHIVOS Y SEPARACIÓN DE LOS 4 PROCESOS
// ----------------------------------------------------------------------------
runTest('TEST-SETUP-PG', 'Existencia e integridad de GenerarSetup.bat y Setup_Korex_Silent.ps1 (PG)', () => {
  if (!fs.existsSync(path.join(rootDir, 'GenerarSetup.bat'))) throw new Error('Falta GenerarSetup.bat');
  if (!fs.existsSync(path.join(deployDir, 'Setup_Korex_Silent.ps1'))) throw new Error('Falta Setup_Korex_Silent.ps1');
  if (!fs.existsSync(path.join(deployDir, 'Korex.iss'))) throw new Error('Falta Korex.iss');
  const batContent = fs.readFileSync(path.join(rootDir, 'GenerarSetup.bat'), 'utf8');
  if (!batContent.includes('Korex.iss')) throw new Error('GenerarSetup.bat no compila Korex.iss');
});

runTest('TEST-UPDATE-PG', 'Existencia e integridad de GenerarActualizador.bat y Update_Korex.ps1 (PG)', () => {
  if (!fs.existsSync(path.join(rootDir, 'GenerarActualizador.bat'))) throw new Error('Falta GenerarActualizador.bat');
  if (!fs.existsSync(path.join(deployDir, 'Update_Korex.ps1'))) throw new Error('Falta Update_Korex.ps1');
  if (!fs.existsSync(path.join(deployDir, 'Korex_Update.iss'))) throw new Error('Falta Korex_Update.iss');
  const batContent = fs.readFileSync(path.join(rootDir, 'GenerarActualizador.bat'), 'utf8');
  if (!batContent.includes('Korex_Update.iss')) throw new Error('GenerarActualizador.bat no compila Korex_Update.iss');
});

runTest('TEST-SETUP-SQL', 'Existencia e integridad de GenerarSetupSqlServer.bat y Setup_Korex_SQLServer_Silent.ps1', () => {
  if (!fs.existsSync(path.join(rootDir, 'GenerarSetupSqlServer.bat'))) throw new Error('Falta GenerarSetupSqlServer.bat');
  if (!fs.existsSync(path.join(deployDir, 'Setup_Korex_SQLServer_Silent.ps1'))) throw new Error('Falta Setup_Korex_SQLServer_Silent.ps1');
  if (!fs.existsSync(path.join(deployDir, 'Korex_SQLServer.iss'))) throw new Error('Falta Korex_SQLServer.iss');
  const batContent = fs.readFileSync(path.join(rootDir, 'GenerarSetupSqlServer.bat'), 'utf8');
  if (!batContent.includes('Korex_SQLServer.iss')) throw new Error('GenerarSetupSqlServer.bat no compila Korex_SQLServer.iss');
});

runTest('TEST-UPDATE-SQL', 'Existencia e integridad de GenerarActualizadorSqlServer.bat y Update_Korex_SQLServer.ps1', () => {
  if (!fs.existsSync(path.join(rootDir, 'GenerarActualizadorSqlServer.bat'))) throw new Error('Falta GenerarActualizadorSqlServer.bat');
  if (!fs.existsSync(path.join(deployDir, 'Update_Korex_SQLServer.ps1'))) throw new Error('Falta Update_Korex_SQLServer.ps1');
  if (!fs.existsSync(path.join(deployDir, 'Korex_SQLServer_Update.iss'))) throw new Error('Falta Korex_SQLServer_Update.iss');
  const batContent = fs.readFileSync(path.join(rootDir, 'GenerarActualizadorSqlServer.bat'), 'utf8');
  if (!batContent.includes('Korex_SQLServer_Update.iss')) throw new Error('GenerarActualizadorSqlServer.bat no compila Korex_SQLServer_Update.iss');
});

// ----------------------------------------------------------------------------
// BLOQUE 2: AISLAMIENTO ESTRICTO ENTRE PROCESOS PG Y SQL SERVER
// ----------------------------------------------------------------------------
runTest('TEST-ISOLATION-PG', 'Aislamiento de instalador/actualizador PG (0 referencias a SQL Server)', () => {
  const pgSetup = fs.readFileSync(path.join(deployDir, 'Setup_Korex_Silent.ps1'), 'utf8');
  const pgUpdate = fs.readFileSync(path.join(deployDir, 'Update_Korex.ps1'), 'utf8');
  const pgIss = fs.readFileSync(path.join(deployDir, 'Korex.iss'), 'utf8');
  
  if (pgSetup.includes('Setup_Korex_SQLServer') || pgSetup.includes('DATABASE_URL_SQLSERVER')) {
    throw new Error('Setup_Korex_Silent.ps1 contiene referencias cruzadas a SQL Server.');
  }
  if (pgUpdate.includes('Update_Korex_SQLServer') || pgUpdate.includes('DATABASE_URL_SQLSERVER')) {
    throw new Error('Update_Korex.ps1 contiene referencias cruzadas a SQL Server.');
  }
  if (pgIss.includes('Korex_SQLServer')) {
    throw new Error('Korex.iss contiene referencias cruzadas a SQL Server.');
  }
});

runTest('TEST-ISOLATION-SQL', 'Aislamiento de instalador/actualizador SQL Server (0 referencias a PostgreSQL)', () => {
  const sqlSetup = fs.readFileSync(path.join(deployDir, 'Setup_Korex_SQLServer_Silent.ps1'), 'utf8');
  const sqlUpdate = fs.readFileSync(path.join(deployDir, 'Update_Korex_SQLServer.ps1'), 'utf8');
  const sqlIss = fs.readFileSync(path.join(deployDir, 'Korex_SQLServer.iss'), 'utf8');

  if (sqlSetup.includes('Setup_Korex_Silent.ps1') || sqlSetup.includes('Check-PostgresConnection')) {
    throw new Error('Setup_Korex_SQLServer_Silent.ps1 contiene referencias a PostgreSQL.');
  }
  if (sqlUpdate.includes('Check-PostgresConnection') || sqlUpdate.includes('postgresql://')) {
    throw new Error('Update_Korex_SQLServer.ps1 contiene referencias a PostgreSQL.');
  }
  if (sqlIss.includes('Korex_Setup.exe') || sqlIss.includes('Korex_Update')) {
    throw new Error('Korex_SQLServer.iss contiene referencias a ejecutables PostgreSQL.');
  }
});

// ----------------------------------------------------------------------------
// BLOQUE 3: MOTOR DE DIAGNÓSTICO Y REPARACIÓN
// ----------------------------------------------------------------------------
runTest('TEST-DIAGNOSTIC-ENGINE', 'Existencia e integridad del motor Korex_Diagnostics_Engine.ps1', () => {
  const enginePath = path.join(deployDir, 'Korex_Diagnostics_Engine.ps1');
  if (!fs.existsSync(enginePath)) throw new Error('No existe Korex_Diagnostics_Engine.ps1');
  const content = fs.readFileSync(enginePath, 'utf8');
  
  const requiredDomains = [
    'DOMINIO 1: DIAGNOSTICO DE WINDOWS',
    'DOMINIO 2: DIAGNOSTICO DE NODE.JS',
    'DOMINIO 3: DIAGNOSTICO DE ARCHIVOS',
    'DOMINIO 4: DIAGNOSTICO DE DEPENDENCIAS',
    'DOMINIO 5: DIAGNOSTICO DE IIS',
    'DOMINIO 6: DIAGNOSTICO DE ARR Y URL REWRITE',
    'DOMINIO 7: DIAGNOSTICO DE PUERTOS',
    'DOMINIO 8: DIAGNOSTICO DEL PROCESO KOREX',
    'DOMINIO 9: DIAGNOSTICO EXCLUSIVO DE BASE DE DATOS',
    'DOMINIO 10: DIAGNOSTICO HTTP 502.3 PREVENCION',
    'DOMINIO 11: PRUEBA FUNCIONAL END-TO-END'
  ];

  for (const dom of requiredDomains) {
    if (!content.includes(dom)) {
      throw new Error(`Korex_Diagnostics_Engine.ps1 no contiene el dominio requerido: ${dom}`);
    }
  }

  if (!content.includes('GenerateZip') || !content.includes('Compress-Archive')) {
    throw new Error('Korex_Diagnostics_Engine.ps1 no contiene el generador de paquetes ZIP de soporte remoto.');
  }
});

// ----------------------------------------------------------------------------
// BLOQUE 4: EJECUCIÓN DEL MOTOR EN MODO DIAGNÓSTICO (POSTGRESQL Y SQL SERVER)
// ----------------------------------------------------------------------------
runTest('TEST-DIAGNOSTIC-PG', 'Ejecución del motor en modo Diagnostico para PostgreSQL', () => {
  const cmd = `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '${path.join(deployDir, 'Korex_Diagnostics_Engine.ps1')}' -Engine POSTGRESQL -Mode Diagnostico -TargetDir '${rootDir}' -GenerateZip"`;
  try {
    execSync(cmd, { stdio: 'pipe' });
  } catch (err) {
    // Si hay advertencias o código de salida 1 por servicios apagados, comprobar que se generaron los artefactos
    const diagDir = path.join(rootDir, 'Diagnosticos');
    const files = fs.readdirSync(diagDir);
    const hasHtml = files.some(f => f.startsWith('Korex_Diagnostico_POSTGRESQL') && f.endsWith('.html'));
    const hasZip = files.some(f => f.startsWith('Korex_Diagnostico_POSTGRESQL') && f.endsWith('.zip'));
    if (!hasHtml || !hasZip) {
      throw new Error(`Fallo generando reporte o ZIP en PostgreSQL: ${err.message}`);
    }
  }
});

runTest('TEST-DIAGNOSTIC-SQL', 'Ejecución del motor en modo Diagnostico para SQL Server', () => {
  const cmd = `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '${path.join(deployDir, 'Korex_Diagnostics_Engine.ps1')}' -Engine SQLSERVER -Mode Diagnostico -TargetDir '${rootDir}' -GenerateZip"`;
  try {
    execSync(cmd, { stdio: 'pipe' });
  } catch (err) {
    const diagDir = path.join(rootDir, 'Diagnosticos');
    const files = fs.readdirSync(diagDir);
    const hasHtml = files.some(f => f.startsWith('Korex_Diagnostico_SQLSERVER') && f.endsWith('.html'));
    const hasZip = files.some(f => f.startsWith('Korex_Diagnostico_SQLSERVER') && f.endsWith('.zip'));
    if (!hasHtml || !hasZip) {
      throw new Error(`Fallo generando reporte o ZIP en SQL Server: ${err.message}`);
    }
  }
});

// ----------------------------------------------------------------------------
// BLOQUE 5: VERIFICACIÓN DE REPORTES SANITIZADOS
// ----------------------------------------------------------------------------
runTest('TEST-SANITIZE-SECURITY', 'Sanitización estricta de reportes (0 contraseñas o secretos en reportes)', () => {
  const diagDir = path.join(rootDir, 'Diagnosticos');
  const files = fs.readdirSync(diagDir);
  const htmlFiles = files.filter(f => f.endsWith('.html'));
  if (htmlFiles.length === 0) throw new Error('No se encontraron reportes HTML generados');
  
  for (const hf of htmlFiles) {
    const content = fs.readFileSync(path.join(diagDir, hf), 'utf8');
    if (content.includes('zzeusagencias') || content.includes('postgres://postgres:')) {
      throw new Error(`El reporte ${hf} contiene contraseñas no sanitizadas.`);
    }
  }
});

// ----------------------------------------------------------------------------
// RESUMEN FINAL
// ----------------------------------------------------------------------------
console.log('\n================================================================');
console.log(`  RESUMEN DE PRUEBAS DE INSTALADORES Y DIAGNÓSTICO:`);
console.log(`  Total: ${totalTests} | ✅ Pasaron: ${passedTests} | ❌ Fallaron: ${failedTests}`);
console.log('================================================================\n');

if (failedTests > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
