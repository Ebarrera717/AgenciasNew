/**
 * ============================================================================
 * PROYECTO: KOREX ANALYTICS
 * SCRIPT: Validador Automatizado de Arquitectura, DDL y Entregables de Fase 0
 * EJECUCIÓN: node scripts/validate_korex_analytics_suite.js
 * ============================================================================
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
let totalChecks = 0;
let passedChecks = 0;
let failedChecks = 0;

function assertCheck(name, condition, errorMsg = '') {
    totalChecks++;
    if (condition) {
        passedChecks++;
        console.log(`  [OK] ${name}`);
    } else {
        failedChecks++;
        console.error(`  [FAIL] ${name} -> ${errorMsg}`);
    }
}

console.log('============================================================================');
console.log('       INICIANDO SUITE DE VALIDACIÓN - KOREX ANALYTICS FASE 0 & DDL');
console.log('============================================================================\n');

// 1. VERIFICACIÓN DE LOS 12 ENTREGABLES DE FASE 0
console.log('[CAPA 1] Verificando los 12 Documentos Técnicos de Fase 0...');
const REQUIRED_DOCS = [
    'ANALISIS_FASE_0.md',
    'ARQUITECTURA.md',
    'SEGURIDAD.md',
    'USUARIOS.md',
    'PARAMETROS_USUARIOS.md',
    'SQL_SERVER.md',
    'EJECUCIONES.md',
    'BASE_DATOS.md',
    'PRUEBAS.md',
    'MATRIZ_DEPENDENCIAS.md',
    'MATRIZ_RIESGOS.md',
    'IDENTIDAD_VISUAL.md',
    'PROMPT_MAESTRO_KOREX_ANALYTICS.md'
];

REQUIRED_DOCS.forEach(docFile => {
    const fullPath = path.join(ROOT_DIR, 'docs', docFile);
    const exists = fs.existsSync(fullPath);
    const size = exists ? fs.statSync(fullPath).size : 0;
    assertCheck(`Documento docs/${docFile} presente y no vacío`, exists && size > 100, `Archivo no encontrado o vacío`);
});

// 2. VERIFICACIÓN DE ESTRUCTURA DDL Y SQL SCRIPTS
console.log('\n[CAPA 2] Verificando Estructura DDL en SQL/KorexAnalytics/ ...');
const SQL_DIR = path.join(ROOT_DIR, 'SQL', 'KorexAnalytics');
assertCheck('Directorio SQL/KorexAnalytics existe', fs.existsSync(SQL_DIR));

const TABLES_SQL_PATH = path.join(SQL_DIR, '01_Tables.sql');
const DATA_SQL_PATH = path.join(SQL_DIR, '02_InitialData.sql');
const SPS_SQL_PATH = path.join(SQL_DIR, '03_StoredProcedures.sql');

assertCheck('Script 01_Tables.sql existe', fs.existsSync(TABLES_SQL_PATH));
assertCheck('Script 02_InitialData.sql existe', fs.existsSync(DATA_SQL_PATH));
assertCheck('Script 03_StoredProcedures.sql existe', fs.existsSync(SPS_SQL_PATH));

if (fs.existsSync(TABLES_SQL_PATH)) {
    const tablesContent = fs.readFileSync(TABLES_SQL_PATH, 'utf8');
    const expectedTables = [
        'KAX_Role',
        'KAX_User',
        'KAX_UserParameter',
        'KAX_SQLConnectionProfile',
        'KAX_ExecutionProcedure',
        'KAX_ExecutionPreset',
        'KAX_ExecutionRun',
        'KAX_SystemAuditLog'
    ];
    expectedTables.forEach(tbl => {
        assertCheck(`Tabla ${tbl} definida en DDL`, tablesContent.includes(tbl), `Falta declaración de ${tbl}`);
    });
}

// 3. VERIFICACIÓN DE REGLA DE NO HARDCODED CONNECTIONS & AISLAMIENTO
console.log('\n[CAPA 3] Verificando Aislamiento y Regla de No Conexiones Hardcodeadas...');
if (fs.existsSync(TABLES_SQL_PATH) && fs.existsSync(SPS_SQL_PATH)) {
    const allSql = fs.readFileSync(TABLES_SQL_PATH, 'utf8') + fs.readFileSync(SPS_SQL_PATH, 'utf8');
    assertCheck('No hay referencias a "Korex_pruebas" hardcodeadas', !allSql.includes('Korex_pruebas'));
    assertCheck('No hay credenciales fijas de AgenciasNew', !allSql.includes('zzeusagencias') && !allSql.includes('sa_agencias'));
}

// 4. VERIFICACIÓN DE SKILLS E INTEGRACIÓN
console.log('\n[CAPA 4] Verificando Skill de Identidad Visual y Configuración de Agentes...');
const SKILL_PATH = path.join(ROOT_DIR, '.agents', 'skills', 'korex-analytics-design', 'SKILL.md');
assertCheck('Skill korex-analytics-design/SKILL.md existe', fs.existsSync(SKILL_PATH));
if (fs.existsSync(SKILL_PATH)) {
    const skillContent = fs.readFileSync(SKILL_PATH, 'utf8');
    assertCheck('Skill contiene paleta de colores oficial', skillContent.includes('Azul petróleo') && skillContent.includes('Turquesa'));
    assertCheck('Skill contiene referencia a PROMPT_MAESTRO_KOREX_ANALYTICS.md', skillContent.includes('PROMPT_MAESTRO_KOREX_ANALYTICS.md'));
}

console.log('\n============================================================================');
console.log(`RESULTADOS: ${passedChecks} APROBADOS, ${failedChecks} FALLIDOS (TOTAL: ${totalChecks})`);
console.log('============================================================================\n');

if (failedChecks > 0) {
    process.exit(1);
} else {
    console.log('>>> VERIFICACIÓN EXITOSA: Korex Analytics cumple al 100% con los estándares de arquitectura y Fase 0.\n');
    process.exit(0);
}
