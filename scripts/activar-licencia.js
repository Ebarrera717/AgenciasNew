const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Cargar variables de entorno de .env
const envCandidates = [
    path.join(__dirname, '..', '.env'),
    path.join(__dirname, '.env'),
    path.join(process.cwd(), '.env')
];

let dbUrl = '';
let dbUrlSqlServer = '';
let dbProvider = '';
let secretKey = 'Korex_Master_License_Secret_Key_2026_Secure';

for (const envPath of envCandidates) {
    if (fs.existsSync(envPath)) {
        try {
            const envContent = fs.readFileSync(envPath, 'utf8');
            envContent.split(/\r?\n/).forEach(line => {
                const trimmed = line.trim();
                if (!trimmed || trimmed.startsWith('#')) return;
                const eqIdx = trimmed.indexOf('=');
                if (eqIdx > 0) {
                    const key = trimmed.slice(0, eqIdx).trim();
                    const val = trimmed.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, '');
                    if (key === 'DATABASE_URL') dbUrl = val;
                    if (key === 'DATABASE_URL_SQLSERVER') dbUrlSqlServer = val;
                    if (key === 'DATABASE_PROVIDER') dbProvider = val.toLowerCase();
                    if (key === 'LICENSE_SECRET') secretKey = val;
                }
            });
            break;
        } catch (e) {}
    }
}

const isSqlServerEnv =
    dbProvider === 'sqlserver' ||
    Boolean(dbUrlSqlServer) ||
    (dbUrl && (dbUrl.toLowerCase().startsWith('sqlserver://') || dbUrl.toLowerCase().startsWith('mssql://'))) ||
    (!dbUrl && fs.existsSync(path.join(__dirname, '..', 'SQL', 'ActualizadorSERVER.sql'))) ||
    (!dbUrl && fs.existsSync(path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql')));

function parseSqlServerUrl(rawUrl) {
    const clean = (rawUrl || '').replace(/^(sqlserver|mssql):\/\//i, '');
    const parts = clean.split(';');
    const hostPortPart = parts[0] || '';
    let host = hostPortPart.split(':')[0] || '127.0.0.1';
    let port = 1433;
    if (hostPortPart.includes(':')) {
        const parsedPort = parseInt(hostPortPart.split(':')[1], 10);
        if (!isNaN(parsedPort)) port = parsedPort;
    }
    let database = '';
    let user = '';
    let password = '';

    for (const p of parts.slice(1)) {
        const eqIdx = p.indexOf('=');
        if (eqIdx > 0) {
            const k = p.substring(0, eqIdx).trim().toLowerCase();
            const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
            if (k === 'database') database = v;
            else if (k === 'user' || k === 'user id' || k === 'uid') user = v;
            else if (k === 'password' || k === 'pwd') password = v;
        }
    }

    if (host.toLowerCase() === 'localhost' || host === '.' || host === '(local)') {
        host = '127.0.0.1';
    }

    return { host, port, database, user, password };
}

function loadMssqlDriver() {
    const candidates = [
        'mssql',
        path.join(__dirname, '..', 'node_modules', 'mssql'),
        path.join(process.cwd(), 'node_modules', 'mssql')
    ];
    for (const c of candidates) {
        try {
            return require(c);
        } catch (e) {}
    }
    console.error("\n❌ [ERROR] No se pudo encontrar la librería 'mssql' para conectar a SQL Server.\n");
    process.exit(1);
}

function loadPgDriver() {
    const candidates = [
        'pg',
        path.join(__dirname, '..', 'node_modules', 'pg'),
        path.join(process.cwd(), 'node_modules', 'pg')
    ];
    for (const c of candidates) {
        try {
            return require(c);
        } catch (e) {}
    }
    console.error("\n❌ [ERROR] No se pudo encontrar la librería 'pg' para conectar a PostgreSQL.\n");
    process.exit(1);
}

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

function buildSqlServerConfig(connParams) {
    const os = require('os');
    const { execFileSync } = require('child_process');
    let serverHost = connParams.host || '127.0.0.1';
    let instanceName = undefined;
    if (serverHost.includes('\\')) {
        const parts = serverHost.split('\\');
        serverHost = parts[0];
        instanceName = parts[1];
    }
    const localHostname = (os.hostname() || '').toLowerCase();
    if (
        serverHost.toLowerCase() === 'localhost' ||
        serverHost === '.' ||
        serverHost.toLowerCase() === '(local)' ||
        (localHostname && serverHost.toLowerCase() === localHostname)
    ) {
        serverHost = '127.0.0.1';
    }
    let resolvedPort = connParams.port || 1433;
    let foundInstancePort = (connParams.port && connParams.port !== 1433) ? connParams.port : null;
    if (instanceName && !foundInstancePort) {
        try {
            const psRegCmd = `$p = Get-ItemProperty "HKLM:\\SOFTWARE\\Microsoft\\Microsoft SQL Server\\MSSQL*.${instanceName}\\MSSQLServer\\SuperSocketNetLib\\Tcp\\IPAll" -ErrorAction SilentlyContinue | Select-Object -First 1; if ($p) { if ($p.TcpPort) { Write-Output $p.TcpPort } elseif ($p.TcpDynamicPorts) { Write-Output $p.TcpDynamicPorts } }`;
            const regOut = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psRegCmd], {
                encoding: 'utf8',
                timeout: 4000,
                stdio: ['ignore', 'pipe', 'ignore']
            }).trim();
            const pm = regOut.match(/(\d+)/);
            if (pm) foundInstancePort = parseInt(pm[1], 10);
        } catch (e) {}
    }
    if (foundInstancePort) {
        resolvedPort = foundInstancePort;
    }

    const options = {
        encrypt: false,
        trustServerCertificate: true
    };
    if (instanceName && !foundInstancePort) {
        options.instanceName = instanceName;
    }
    return {
        user: connParams.user,
        password: connParams.password,
        server: serverHost,
        database: connParams.database,
        port: (instanceName && !foundInstancePort) ? undefined : resolvedPort,
        options,
        connectionTimeout: 15000
    };
}

async function activarLicencia(licenseKey, inputClientName, inputNit, customSqlConn = null) {
    const verification = verifyKey(licenseKey);
    if (!verification.isValid) {
        console.error(`\n❌ ERROR DE ACTIVACIÓN: ${verification.error}\n`);
        process.exit(1);
    }

    const { client: payloadClient, nit: payloadNit, exp } = verification.payload;
    const finalClient = (inputClientName && inputClientName.trim()) || payloadClient.trim();
    const finalNit = (inputNit && inputNit.trim()) || payloadNit.trim();

    if (isSqlServerEnv || customSqlConn) {
        const mssql = loadMssqlDriver();
        const connParams = customSqlConn || parseSqlServerUrl(dbUrlSqlServer || dbUrl);
        if (!connParams.host || !connParams.database || !connParams.user) {
            console.error('\n❌ ERROR DE CONEXIÓN SQL SERVER: Faltan datos de conexión (Servidor, Base de Datos o Usuario).\n');
            process.exit(1);
        }

        const sqlConfig = buildSqlServerConfig(connParams);
        let pool = null;
        try {
            pool = await mssql.connect(sqlConfig);

            const upsertParam = async (code, name, val) => {
                await pool.request()
                    .input('code', mssql.NVarChar(100), code)
                    .input('name', mssql.NVarChar(255), name)
                    .input('val', mssql.NVarChar(mssql.MAX), val)
                    .query(`
                        IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = @code)
                            UPDATE dbo.[SystemParameter] SET [value] = @val, [name] = @name WHERE [code] = @code;
                        ELSE
                            INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (@code, @name, @val);
                    `);
            };

            await upsertParam('LICENSE_KEY', 'Clave de Licencia del Sistema', licenseKey.trim());
            await upsertParam('LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', exp);
            await upsertParam('AGENCY_NAME', 'Nombre o Razón Social de la Agencia', finalClient);
            await upsertParam('AGENCY_NIT', 'NIT de la Agencia', finalNit);

            console.log('\n================================================================');
            console.log('         ✅ LICENCIA ACTIVADA CON ÉXITO EN SQL SERVER           ');
            console.log('================================================================');
            console.log(`Servidor   : ${connParams.host}:${connParams.port || 1433}`);
            console.log(`Base Datos : ${connParams.database}`);
            console.log(`Agencia    : ${finalClient}`);
            console.log(`NIT        : ${finalNit}`);
            console.log(`Nueva Fecha: ${exp}`);
            console.log('================================================================\n');

            await pool.close();
            return;
        } catch (err) {
            if (pool) await pool.close().catch(() => {});
            console.error(`\n❌ ERROR EN BASE DE DATOS SQL SERVER: ${err.message}\n`);
            process.exit(1);
        }
    }

    // Modo PostgreSQL
    const pg = loadPgDriver();
    const { Client } = pg;
    const finalPgUrl = dbUrl || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
    const pgClient = new Client({ connectionString: finalPgUrl });

    try {
        await pgClient.connect();

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
        console.error(`\n❌ ERROR EN BASE DE DATOS POSTGRESQL: ${err.message}\n`);
        process.exit(1);
    }
}

async function runInteractive() {
    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    const ask = (q) => new Promise(res => readline.question(q, ans => res(ans.trim())));

    console.log('\n================================================================');
    console.log('             ACTIVACIÓN DE LICENCIA KOREX                       ');
    console.log('================================================================\n');

    let currentClient = '';
    let currentNit = '';
    let customSqlConn = null;

    if (isSqlServerEnv) {
        let parsed = parseSqlServerUrl(dbUrlSqlServer || dbUrl);
        if (!parsed.database || !parsed.user) {
            console.log('No se detectó archivo .env local con credenciales de SQL Server.');
            console.log('Ingrese los datos del Servidor SQL Server donde reside la base de datos:\n');
            const hostIn = await ask('Servidor SQL Server [127.0.0.1]: ');
            const portIn = await ask('Puerto SQL Server [1433]: ');
            const dbIn = await ask('Nombre de la Base de Datos SQL Server: ');
            const userIn = await ask('Usuario SQL Server [sa]: ');
            const passIn = await ask('Contraseña SQL Server: ');
            parsed = {
                host: hostIn || '127.0.0.1',
                port: parseInt(portIn || '1433', 10),
                database: dbIn,
                user: userIn || 'sa',
                password: passIn
            };
        }
        customSqlConn = parsed;

        try {
            const mssql = loadMssqlDriver();
            const pool = await mssql.connect(buildSqlServerConfig(customSqlConn));
            const r = await pool.request().query(`SELECT [code], [value] FROM dbo.[SystemParameter] WHERE [code] IN ('AGENCY_NAME', 'AGENCY_NIT')`);
            for (const row of r.recordset) {
                if (row.code === 'AGENCY_NAME') currentClient = row.value || '';
                if (row.code === 'AGENCY_NIT') currentNit = row.value || '';
            }
            await pool.close();
        } catch (e) {}
    } else {
        try {
            const pg = loadPgDriver();
            const { Client } = pg;
            const finalPgUrl = dbUrl || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
            const pgClient = new Client({ connectionString: finalPgUrl });
            await pgClient.connect();
            const r1 = await pgClient.query(`SELECT value FROM public."SystemParameter" WHERE code = 'AGENCY_NAME'`);
            const r2 = await pgClient.query(`SELECT value FROM public."SystemParameter" WHERE code = 'AGENCY_NIT'`);
            if (r1.rows.length > 0) currentClient = r1.rows[0].value || '';
            if (r2.rows.length > 0) currentNit = r2.rows[0].value || '';
            await pgClient.end();
        } catch (e) {}
    }

    let clientInput = await ask(`Cliente / Razón Social${currentClient ? ' [' + currentClient + ']' : ''}: `);
    if (!clientInput && currentClient) clientInput = currentClient;

    let nitInput = await ask(`Cédula o NIT${currentNit ? ' [' + currentNit + ']' : ''}: `);
    if (!nitInput && currentNit) nitInput = currentNit;

    let keyInput = await ask('Pegue la Clave de Licencia completa (KOR1...): ');

    readline.close();
    await activarLicencia(keyInput, clientInput, nitInput, customSqlConn);
}

const args = process.argv.slice(2);
if (args.length >= 1) {
    activarLicencia(args[0], args[1], args[2]);
} else {
    runInteractive();
}
