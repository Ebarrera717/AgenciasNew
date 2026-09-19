/**
 * validate_execution_strategy_suite.js
 * Suite automatizada de pruebas para el Skill Obligatorio:
 * Estrategia de Ejecución y Fallback para Korex (Windows Service + Task Scheduler + IIS).
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('================================================================');
console.log('  SUITE DE PRUEBAS: ESTRATEGIA DE EJECUCIÓN Y FALLBACK KOREX    ');
console.log('         (WINDOWS SERVICE + TASK SCHEDULER + IIS)                ');
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

// 1. Verificación del Administrador de Task Scheduler
runTest('TEST-EXEC-MANAGER-EXISTS', 'Existencia de deploy/task_scheduler_manager.ps1 y funciones clave', () => {
  const scriptPath = path.join(deployDir, 'task_scheduler_manager.ps1');
  if (!fs.existsSync(scriptPath)) throw new Error('Falta deploy/task_scheduler_manager.ps1');
  const content = fs.readFileSync(scriptPath, 'utf8');
  if (!content.includes('Register-KorexStartupTask') || !content.includes('Start-KorexStartupTask') || !content.includes('Get-KorexStartupTaskStatus')) {
    throw new Error('task_scheduler_manager.ps1 no contiene las funciones requeridas.');
  }
});

// 2. Verificación de Lógica de Fallback en Instalador PostgreSQL
runTest('TEST-EXEC-FALLBACK-PG', 'Lógica de contingencia y fallback en Setup_Korex_Silent.ps1', () => {
  const content = fs.readFileSync(path.join(deployDir, 'Setup_Korex_Silent.ps1'), 'utf8');
  if (!content.includes('task_scheduler_manager.ps1') || !content.includes('EXECUTION_MECHANISM')) {
    throw new Error('Setup_Korex_Silent.ps1 no implementa fallback a Task Scheduler.');
  }
  if (!content.includes('ESTRATEGIA B (FALLBACK): WINDOWS TASK SCHEDULER')) {
    throw new Error('Falta mensaje explícito de activación de Estrategia B en log de PG.');
  }
});

// 3. Verificación de Lógica de Fallback en Instalador SQL Server
runTest('TEST-EXEC-FALLBACK-SQL', 'Lógica de contingencia y fallback en Setup_Korex_SQLServer_Silent.ps1', () => {
  const content = fs.readFileSync(path.join(deployDir, 'Setup_Korex_SQLServer_Silent.ps1'), 'utf8');
  if (!content.includes('task_scheduler_manager.ps1') || !content.includes('EXECUTION_MECHANISM')) {
    throw new Error('Setup_Korex_SQLServer_Silent.ps1 no implementa fallback a Task Scheduler.');
  }
  if (!content.includes('Korex SQLServer - Startup')) {
    throw new Error('Falta configuración de tarea específica para SQL Server.');
  }
});

// 4. Preservación del Mecanismo Activo en Actualizadores
runTest('TEST-EXEC-PRESERVE-UPDATE', 'Preservación de EXECUTION_MECHANISM en Update_Korex y Update_Korex_SQLServer', () => {
  const contentPg = fs.readFileSync(path.join(deployDir, 'Update_Korex.ps1'), 'utf8');
  const contentSql = fs.readFileSync(path.join(deployDir, 'Update_Korex_SQLServer.ps1'), 'utf8');
  if (!contentPg.includes('EXECUTION_MECHANISM') || !contentPg.includes('TASK_SCHEDULER')) {
    throw new Error('Update_Korex.ps1 no preserva EXECUTION_MECHANISM.');
  }
  if (!contentSql.includes('EXECUTION_MECHANISM') || !contentSql.includes('TASK_SCHEDULER')) {
    throw new Error('Update_Korex_SQLServer.ps1 no preserva EXECUTION_MECHANISM.');
  }
});

// 5. Soporte en Motor de Diagnóstico (Dominio 8)
runTest('TEST-EXEC-DIAGNOSTIC-DOMAIN8', 'Diagnóstico dual de Servicio y Tarea Programada en Korex_Diagnostics_Engine.ps1', () => {
  const content = fs.readFileSync(path.join(deployDir, 'Korex_Diagnostics_Engine.ps1'), 'utf8');
  if (!content.includes('Task Scheduler') || !content.includes('Korex NextJS - Startup') || !content.includes('Korex SQLServer - Startup')) {
    throw new Error('Korex_Diagnostics_Engine.ps1 no evalúa Task Scheduler en Dominio 8.');
  }
});

// 6. Aislamiento Estricto de Motores
runTest('TEST-EXEC-ISOLATION', 'Aislamiento de nombres de tareas y servicios entre PostgreSQL y SQL Server', () => {
  const contentPg = fs.readFileSync(path.join(deployDir, 'Setup_Korex_Silent.ps1'), 'utf8');
  const contentSql = fs.readFileSync(path.join(deployDir, 'Setup_Korex_SQLServer_Silent.ps1'), 'utf8');
  if (contentPg.includes('Korex SQLServer - Startup')) {
    throw new Error('Setup_Korex_Silent.ps1 contiene referencias a tareas de SQL Server.');
  }
  if (contentSql.includes('Korex NextJS - Startup') && !contentSql.includes('Korex SQLServer - Startup')) {
    throw new Error('Setup_Korex_SQLServer_Silent.ps1 no configura la tarea correcta de SQL Server.');
  }
});

// 7. Empaquetado en Generar_Empaquetado.ps1
runTest('TEST-EXEC-PACKAGE-INCLUSION', 'Inclusión de task_scheduler_manager.ps1 en Generar_Empaquetado.ps1', () => {
  const content = fs.readFileSync(path.join(deployDir, 'Generar_Empaquetado.ps1'), 'utf8');
  if (!content.includes('task_scheduler_manager.ps1')) {
    throw new Error('Generar_Empaquetado.ps1 no copia task_scheduler_manager.ps1 al release.');
  }
});

console.log('\n================================================================');
console.log(`  RESUMEN DE PRUEBAS DE ESTRATEGIA DE EJECUCIÓN:`);
console.log(`  Total: ${totalTests} | ✅ Pasaron: ${passedTests} | ❌ Fallaron: ${failedTests}`);
console.log('================================================================\n');

if (failedTests > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
