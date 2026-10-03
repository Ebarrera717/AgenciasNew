const fs = require('fs');
const path = require('path');

const provider = (process.argv[2] || 'sqlserver').toLowerCase().trim();
const rootDir = path.join(__dirname, '..');
const envPath = path.join(rootDir, '.env');

// Leer variables actuales de .env para no sobreescribir configuraciones del usuario
let envMap = new Map();
let rawLines = [];

if (fs.existsSync(envPath)) {
    try {
        rawLines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/);
        for (const line of rawLines) {
            const trimmed = line.trim();
            if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
                const eqIdx = trimmed.indexOf('=');
                const key = trimmed.slice(0, eqIdx).trim();
                const val = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, '');
                envMap.set(key, val);
            }
        }
    } catch (e) {
        console.error('Error leyendo .env:', e.message);
    }
}

// Obtener o mantener las cadenas configuradas por el usuario
let sqlConn = envMap.get('DATABASE_URL_SQLSERVER') || 
              (envMap.get('DATABASE_PROVIDER') === 'sqlserver' ? envMap.get('DATABASE_URL') : null) || 
              'sqlserver://ZEUSAGENCIAS10:1433;database=Korex_Pruebas;user=zeusagencias;password=zzeusagencias;encrypt=false;trustServerCertificate=true';

let pgConn = envMap.get('DATABASE_URL_POSTGRES') || 
             (envMap.get('DATABASE_PROVIDER') === 'postgresql' ? envMap.get('DATABASE_URL') : null) || 
             'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';

// Actualizar provider y active URL
const activeUrl = provider === 'sqlserver' ? sqlConn : pgConn;
envMap.set('DATABASE_PROVIDER', provider);
envMap.set('DATABASE_URL', activeUrl);
envMap.set('DATABASE_URL_SQLSERVER', sqlConn);
envMap.set('DATABASE_URL_POSTGRES', pgConn);
if (!envMap.has('PORT')) envMap.set('PORT', '3001');
if (!envMap.has('NEXTAUTH_SECRET')) envMap.set('NEXTAUTH_SECRET', 'KorexProductionSecretKey2024_Security');
if (!envMap.has('LICENSE_SECRET')) envMap.set('LICENSE_SECRET', 'Korex_Master_License_Secret_Key_2026_Secure');

// Reconstruir .env preservando estructura
let outLines = [
    '# ============================================================================',
    '# KOREX - AGENCIASNEW - CONFIGURACION OFICIAL DEL SISTEMA',
    '# ============================================================================',
    '',
    `DATABASE_PROVIDER="${envMap.get('DATABASE_PROVIDER')}"`,
    `DATABASE_URL="${envMap.get('DATABASE_URL')}"`,
    `DATABASE_URL_SQLSERVER="${envMap.get('DATABASE_URL_SQLSERVER')}"`,
    `DATABASE_URL_POSTGRES="${envMap.get('DATABASE_URL_POSTGRES')}"`,
    '',
    `NEXTAUTH_SECRET="${envMap.get('NEXTAUTH_SECRET')}"`,
    `LICENSE_SECRET="${envMap.get('LICENSE_SECRET')}"`,
    `PORT="${envMap.get('PORT')}"`,
    ''
];

fs.writeFileSync(envPath, outLines.join('\n'), 'utf8');
console.log(`✅ Motor activo actualizado a [${provider.toUpperCase()}] sin alterar credenciales.`);
