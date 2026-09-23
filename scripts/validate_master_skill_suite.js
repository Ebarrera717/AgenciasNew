/**
 * scripts/validate_master_skill_suite.js
 * Suite automatizada para validar el SKILL MAESTRO KOREX (ID: 74163)
 * Desarrollo, Instalación, Actualización, Aislamiento, Seguridad y No Contaminación del .env
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const DEPLOY_DIR = path.join(ROOT_DIR, 'deploy');
const RELEASE_DIR = path.join(ROOT_DIR, 'RELEASE_KOREX');

console.log('================================================================');
console.log('    SUITE DE VALIDACIÓN: SKILL MAESTRO KOREX (ID: 74163)       ');
console.log('    AISLAMIENTO, PROTECCIÓN INVIOLABLE .ENV Y NO CONTAMINACIÓN ');
console.log('================================================================\n');

let passedTests = 0;
let totalTests = 0;

function runTest(name, fn) {
    totalTests++;
    try {
        fn();
        console.log(`[${name}] ... ✅ OK`);
        passedTests++;
    } catch (err) {
        console.error(`[${name}] ... ❌ ERROR: ${err.message}`);
    }
}

// 1. Verificar exclusión de .env en RELEASE_KOREX y en Inno Setup (.iss)
runTest('TEST-MASTER-ENV-EXCLUSION', () => {
    // A. RELEASE_KOREX no debe tener .env
    const envInRelease = path.join(RELEASE_DIR, '.env');
    if (fs.existsSync(envInRelease)) {
        throw new Error('Existe archivo .env en RELEASE_KOREX. Viola regla de no transporte de .env a producción.');
    }

    // B. Todos los .iss deben excluir .env
    const issFiles = ['Korex.iss', 'Korex_Update.iss', 'Korex_SQLServer.iss', 'Korex_SQLServer_Update.iss'];
    for (const iss of issFiles) {
        const p = path.join(DEPLOY_DIR, iss);
        if (!fs.existsSync(p)) throw new Error(`Falta archivo ${iss}`);
        const content = fs.readFileSync(p, 'utf8');
        if (!content.includes('Excludes:') || !content.includes('.env')) {
            throw new Error(`${iss} no contiene cláusula Excludes para archivos .env.`);
        }
    }
});

// 2. Verificar que Generar_Empaquetado.ps1 elimina .env de RELEASE_KOREX
runTest('TEST-MASTER-PACKAGER-SANITIZATION', () => {
    const pkgScript = path.join(DEPLOY_DIR, 'Generar_Empaquetado.ps1');
    const content = fs.readFileSync(pkgScript, 'utf8');
    if (!content.includes('.env*') || !content.includes('Remove-Item')) {
        throw new Error('Generar_Empaquetado.ps1 no sanitiza explícitamente archivos .env.');
    }
});

// 3. Verificar que Actualizadores se detienen si no existe .env (Sin fallbacks inventados)
runTest('TEST-MASTER-UPDATER-ENV-PROTECTION', () => {
    const upPg = path.join(DEPLOY_DIR, 'Update_Korex.ps1');
    const upSql = path.join(DEPLOY_DIR, 'Update_Korex_SQLServer.ps1');

    const contentPg = fs.readFileSync(upPg, 'utf8');
    const contentSql = fs.readFileSync(upSql, 'utf8');

    // PG debe abortar si no hay .env y no tener defaults como 'agencias_new'
    if (!contentPg.includes('No se encontro el archivo .env de la instalacion existente') || contentPg.includes('agencias_new')) {
        throw new Error('Update_Korex.ps1 no aborta correctamente ante ausencia de .env o contiene base de datos default de pruebas.');
    }

    // SQL Server debe abortar si no hay .env y no tener defaults como 'Korex_colaereo' o 'zzeusagencias'
    if (!contentSql.includes('No se encontro el archivo .env de la instalacion existente') || contentSql.includes('Korex_colaereo"; $SqlUser = "sa"')) {
        throw new Error('Update_Korex_SQLServer.ps1 no aborta ante ausencia de .env o contiene credenciales fallback de pruebas.');
    }
});

// 4. Verificar que Setup genera .env desde cero con DATABASE_PROVIDER
runTest('TEST-MASTER-SETUP-ZERO-ENV', () => {
    const setupPg = path.join(DEPLOY_DIR, 'Setup_Korex_Silent.ps1');
    const setupSql = path.join(DEPLOY_DIR, 'Setup_Korex_SQLServer_Silent.ps1');

    const contentPg = fs.readFileSync(setupPg, 'utf8');
    const contentSql = fs.readFileSync(setupSql, 'utf8');

    if (!contentPg.includes('DATABASE_PROVIDER') || !contentPg.includes('postgresql')) {
        throw new Error('Setup_Korex_Silent.ps1 no define DATABASE_PROVIDER="postgresql".');
    }
    if (!contentSql.includes('DATABASE_PROVIDER') || !contentSql.includes('sqlserver')) {
        throw new Error('Setup_Korex_SQLServer_Silent.ps1 no define DATABASE_PROVIDER="sqlserver".');
    }
});

// 5. Verificar parámetros iniciales limpios de Zeus ERP en semillas
runTest('TEST-MASTER-CLEAN-ZEUS-SEEDS', () => {
    const alterScript = path.join(ROOT_DIR, 'SQL', 'Table', 'Alter_New_Columns.sql');
    const seedsScript = path.join(ROOT_DIR, 'SQL', 'SqlServer', '02_Seeds.sql');

    const contentAlter = fs.readFileSync(alterScript, 'utf8');
    const contentSeeds = fs.readFileSync(seedsScript, 'utf8');

    // No debe sembrar ZEUSAGENCIAS10 como host por defecto
    if (contentAlter.includes("'ServidorSQLServer', 'Host de SQL Server', 'ZEUSAGENCIAS10'")) {
        throw new Error('Alter_New_Columns.sql contiene host de Zeus ERP de pruebas hardcodeado.');
    }
    if (contentSeeds.includes("N'ServidorSQLServer', N'Host de SQL Server', N'127.0.0.1'")) {
        throw new Error('02_Seeds.sql contiene host de Zeus ERP activo por defecto.');
    }
});

// 6. Verificar Aislamiento de Motores (0 operaciones en motor contrario)
runTest('TEST-MASTER-ENGINE-ISOLATION', () => {
    const setupPg = path.join(DEPLOY_DIR, 'Setup_Korex_Silent.ps1');
    const setupSql = path.join(DEPLOY_DIR, 'Setup_Korex_SQLServer_Silent.ps1');

    const contentPg = fs.readFileSync(setupPg, 'utf8');
    const contentSql = fs.readFileSync(setupSql, 'utf8');

    if (contentPg.includes('System.Data.SqlClient') || contentPg.includes('Korex_SQLServer_Service')) {
        throw new Error('Setup de PostgreSQL contiene referencias activas a componentes de SQL Server.');
    }
    if (contentSql.includes('Check-PostgresConnection') || contentSql.includes('db_installer.js $PgHost')) {
        throw new Error('Setup de SQL Server contiene referencias activas a componentes de PostgreSQL.');
    }
});

// 7. Verificar Skill Maestro registrado en .agents/skills/korex-master-rules/SKILL.md
runTest('TEST-MASTER-SKILL-REGISTRATION', () => {
    const skillPath = path.join(ROOT_DIR, '.agents', 'skills', 'korex-master-rules', 'SKILL.md');
    if (!fs.existsSync(skillPath)) {
        throw new Error('No se encontró el archivo .agents/skills/korex-master-rules/SKILL.md.');
    }
    const content = fs.readFileSync(skillPath, 'utf8');
    if (!content.includes('74163') || !content.includes('SKILL MAESTRO')) {
        throw new Error('El archivo SKILL.md no contiene la identificación completa del Skill Maestro 74163.');
    }
});

// 8. Verificar Skill Maestro de Control de Regresiones en .agents/skills/correcciones-permanencia-proteccion/SKILL.md
runTest('TEST-MASTER-REGRESSION-SKILL-REGISTRATION', () => {
    const skillPath = path.join(ROOT_DIR, '.agents', 'skills', 'correcciones-permanencia-proteccion', 'SKILL.md');
    if (!fs.existsSync(skillPath)) {
        throw new Error('No se encontró el archivo .agents/skills/correcciones-permanencia-proteccion/SKILL.md.');
    }
    const content = fs.readFileSync(skillPath, 'utf8');
    if (!content.includes('CONTROL DE REGRESIONES Y PROTECCIÓN DE CORRECCIONES') || !content.includes('TODO LO QUE SE CORRIGE, SE PROTEGE')) {
        throw new Error('El archivo SKILL.md no contiene la declaración completa del Principio Maestro "TODO LO QUE SE CORRIGE, SE PROTEGE".');
    }
});

console.log('\n================================================================');
console.log(`  RESUMEN DE PRUEBAS SKILL MAESTRO (ID 74163):`);
console.log(`  Total: ${totalTests} | ✅ Pasaron: ${passedTests} | ❌ Fallaron: ${totalTests - passedTests}`);
console.log('================================================================\n');

if (passedTests !== totalTests) {
    process.exit(1);
} else {
    process.exit(0);
}
