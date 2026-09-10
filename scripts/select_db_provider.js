const fs = require('fs');
const path = require('path');

const provider = (process.argv[2] || 'postgresql').toLowerCase().trim();
const envPath = path.join(__dirname, '..', '.env');

const pgConn = 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
const sqlConn = 'sqlserver://ZEUSAGENCIAS10:1433;database=Korex_Pruebas;user=zeusagencias;password=zzeusagencias;encrypt=false;trustServerCertificate=true';

let envLines = [];

if (provider === 'sqlserver') {
    envLines = [
        `DATABASE_PROVIDER="sqlserver"`,
        `DATABASE_URL="${sqlConn}"`,
        `DATABASE_URL_SQLSERVER="${sqlConn}"`,
        `DATABASE_URL_POSTGRES="${pgConn}"`,
        `NEXTAUTH_SECRET="KorexProductionSecretKey2024_Security"`,
        `LICENSE_SECRET="Korex_Master_License_Secret_Key_2026_Secure"`,
        `PORT="3001"`
    ];
    console.log('✅ Configuración .env actualizada a: SQL Server (ZEUSAGENCIAS10 / Korex_Pruebas)');
} else {
    envLines = [
        `DATABASE_PROVIDER="postgresql"`,
        `DATABASE_URL="${pgConn}"`,
        `DATABASE_URL_POSTGRES="${pgConn}"`,
        `DATABASE_URL_SQLSERVER="${sqlConn}"`,
        `NEXTAUTH_SECRET="KorexProductionSecretKey2024_Security"`,
        `LICENSE_SECRET="Korex_Master_License_Secret_Key_2026_Secure"`,
        `PORT="3001"`
    ];
    console.log('✅ Configuración .env actualizada a: PostgreSQL (192.168.80.26 / Korex_colaereo)');
}

fs.writeFileSync(envPath, envLines.join('\n') + '\n', 'utf8');
