const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Cargar variables de entorno de .env
const envCandidates = [
    path.join(__dirname, '..', '.env'),
    path.join(__dirname, '.env'),
    path.join(process.cwd(), '.env')
];

let dbUrl = 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
let secretKey = 'Korex_Master_License_Secret_Key_2026_Secure';

for (const envPath of envCandidates) {
    if (fs.existsSync(envPath)) {
        try {
            const envContent = fs.readFileSync(envPath, 'utf8');
            envContent.split(/\r?\n/).forEach(line => {
                const parts = line.split('=');
                if (parts.length >= 2) {
                    const key = parts[0].trim();
                    const val = parts.slice(1).join('=').trim().replace(/^["']|["']$/g, '');
                    if (key === 'DATABASE_URL') dbUrl = val;
                    if (key === 'LICENSE_SECRET') secretKey = val;
                }
            });
        } catch (e) {}
    }
}

// Driver PG seguro
let pg;
try {
    pg = require('pg');
} catch (e1) {
    try {
        pg = require(path.join(__dirname, '..', 'node_modules', 'pg'));
    } catch (e2) {
        try {
            pg = require(path.join(process.cwd(), 'node_modules', 'pg'));
        } catch (e3) {
            console.error("\n❌ [ERROR] No se pudo encontrar la librería 'pg' para conectar a PostgreSQL.\n");
            process.exit(1);
        }
    }
}
const { Client } = pg;

function verifyKey(licenseKey) {
    if (!licenseKey) return { isValid: false, error: 'Clave vacía' };
    const parts = licenseKey.trim().split('.');
    if (parts.length !== 3 || parts[0] !== 'KOR1') {
        return { isValid: false, error: 'Formato de clave no reconocido (debe iniciar por KOR1...)' };
    }

    const [, payloadBase64, signature] = parts;
    const expectedSignature = crypto.createHmac('sha256', secretKey).update(payloadBase64).digest('hex');

    if (signature !== expectedSignature) {
        return { isValid: false, error: 'La firma de la clave es inválida o fue alterada.' };
    }

    try {
        const decoded = JSON.parse(Buffer.from(payloadBase64, 'base64url').toString('utf8'));
        return { isValid: true, payload: { client: decoded.c, nit: decoded.n, exp: decoded.e } };
    } catch (e) {
        return { isValid: false, error: 'Error al descifrar el contenido del token.' };
    }
}

async function activarLicencia(licenseKey, inputClientName, inputNit) {
    const verification = verifyKey(licenseKey);
    if (!verification.isValid) {
        console.error(`\n❌ ERROR DE ACTIVACIÓN: ${verification.error}\n`);
        process.exit(1);
    }

    const { client: payloadClient, nit: payloadNit, exp } = verification.payload;
    const finalClient = (inputClientName && inputClientName.trim()) || payloadClient.trim();
    const finalNit = (inputNit && inputNit.trim()) || payloadNit.trim();

    const pgClient = new Client({ connectionString: dbUrl });

    try {
        await pgClient.connect();

        // Registrar/Actualizar Parámetros en PostgreSQL con la información verificada del token o datos ingresados
        await pgClient.query(`
            INSERT INTO public."SystemParameter" (code, name, value) 
            VALUES ('LICENSE_KEY', 'Clave de Licencia del Sistema', $1),
                   ('LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', $2),
                   ('AGENCY_NAME', 'Nombre o Razón Social de la Agencia', $3),
                   ('AGENCY_NIT', 'NIT de la Agencia', $4)
            ON CONFLICT (code) DO UPDATE SET value = EXCLUDED.value
        `, [licenseKey.trim(), exp, finalClient, finalNit]);

        console.log('\n================================================================');
        console.log('         ✅ LICENCIA ACTIVADA CON ÉXITO EN POSTGRESQL           ');
        console.log('================================================================');
        console.log(`Agencia    : ${finalClient}`);
        console.log(`NIT        : ${finalNit}`);
        console.log(`Nueva Fecha: ${exp}`);
        console.log('================================================================\n');

        await pgClient.end();
    } catch (err) {
        console.error(`\n❌ ERROR EN BASE DE DATOS: ${err.message}\n`);
        process.exit(1);
    }
}

async function runInteractive() {
    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    const ask = (q) => new Promise(res => readline.question(q, ans => res(ans.trim())));

    // Intentar leer datos de agencia actuales
    let currentClient = '';
    let currentNit = '';
    try {
        const pgClient = new Client({ connectionString: dbUrl });
        await pgClient.connect();
        const r1 = await pgClient.query(`SELECT value FROM public."SystemParameter" WHERE code = 'AGENCY_NAME'`);
        const r2 = await pgClient.query(`SELECT value FROM public."SystemParameter" WHERE code = 'AGENCY_NIT'`);
        if (r1.rows.length > 0) currentClient = r1.rows[0].value || '';
        if (r2.rows.length > 0) currentNit = r2.rows[0].value || '';
        await pgClient.end();
    } catch (e) {}

    console.log('\n================================================================');
    console.log('             ACTIVACIÓN DE LICENCIA KOREX                       ');
    console.log('================================================================\n');

    let clientInput = await ask(`Cliente / Razón Social${currentClient ? ' [' + currentClient + ']' : ''}: `);
    if (!clientInput && currentClient) clientInput = currentClient;

    let nitInput = await ask(`Cédula o NIT${currentNit ? ' [' + currentNit + ']' : ''}: `);
    if (!nitInput && currentNit) nitInput = currentNit;

    let keyInput = await ask('Pegue la Clave de Licencia completa (KOR1...): ');

    readline.close();
    await activarLicencia(keyInput, clientInput, nitInput);
}

const args = process.argv.slice(2);
if (args.length >= 1) {
    activarLicencia(args[0], args[1], args[2]);
} else {
    runInteractive();
}
