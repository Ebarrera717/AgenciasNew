/**
 * ============================================================================
 * PROYECTO: KOREX ANALYTICS
 * SCRIPT: Validador Automatizado de Frontend, Rutas y APIs
 * EJECUCIÓN: node scripts/validate_korex_analytics_frontend.js
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
console.log('       VALIDACIÓN DE FRONTEND, RUTAS Y APIS - KOREX ANALYTICS');
console.log('============================================================================\n');

// 1. VERIFICACIÓN DE RUTAS DE FRONTEND
console.log('[CAPA 1] Verificando Vistas y Componentes de Frontend (/analytics)...');
const FRONTEND_FILES = [
    'src/app/analytics/layout.tsx',
    'src/app/analytics/page.tsx',
    'src/app/analytics/login/page.tsx',
    'src/app/analytics/executions/page.tsx',
    'src/app/analytics/sqlserver/page.tsx',
    'src/app/analytics/parameters/page.tsx',
    'src/app/analytics/history/page.tsx'
];

FRONTEND_FILES.forEach(filePath => {
    const fullPath = path.join(ROOT_DIR, filePath);
    const exists = fs.existsSync(fullPath);
    const size = exists ? fs.statSync(fullPath).size : 0;
    assertCheck(`Vista ${filePath} existe y no está vacía`, exists && size > 100);
});

// 2. VERIFICACIÓN DE ENDPOINTS DE API
console.log('\n[CAPA 2] Verificando Endpoints de Backend API (/api/kax)...');
const API_FILES = [
    'src/app/api/kax/auth/login/route.ts',
    'src/app/api/kax/auth/me/route.ts',
    'src/app/api/kax/auth/logout/route.ts',
    'src/app/api/kax/sqlserver/profiles/route.ts',
    'src/app/api/kax/sqlserver/test-connection/route.ts',
    'src/app/api/kax/executions/procedures/route.ts',
    'src/app/api/kax/executions/run/route.ts',
    'src/app/api/kax/executions/presets/route.ts',
    'src/app/api/kax/parameters/user/route.ts'
];

API_FILES.forEach(apiPath => {
    const fullPath = path.join(ROOT_DIR, apiPath);
    const exists = fs.existsSync(fullPath);
    const size = exists ? fs.statSync(fullPath).size : 0;
    assertCheck(`API ${apiPath} existe y no está vacía`, exists && size > 100);
});

// 3. VERIFICACIÓN DE IDENTIDAD VISUAL EN FRONTEND
console.log('\n[CAPA 3] Verificando Tokens de Diseño e Identidad Visual Propia...');
const layoutPath = path.join(ROOT_DIR, 'src/app/analytics/layout.tsx');
if (fs.existsSync(layoutPath)) {
    const layoutContent = fs.readFileSync(layoutPath, 'utf8');
    assertCheck('Layout utiliza paleta slate-950 / cyan-400', layoutContent.includes('slate-950') && layoutContent.includes('cyan-400'));
    assertCheck('Layout incluye branding oficial "KOREX ANALYTICS"', layoutContent.includes('KOREX') && layoutContent.includes('ANALYTICS'));
}

console.log('\n============================================================================');
console.log(`RESULTADOS FRONTEND/APIS: ${passedChecks} APROBADOS, ${failedChecks} FALLIDOS (TOTAL: ${totalChecks})`);
console.log('============================================================================\n');

if (failedChecks > 0) {
    process.exit(1);
} else {
    console.log('>>> FRONTEND & APIS VALIDADO EXITOSAMENTE: Arquitectura, Rutas y Vistas al 100%.\n');
    process.exit(0);
}
