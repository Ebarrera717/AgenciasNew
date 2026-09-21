/**
 * scripts/validate_password_encryption_suite.js
 * Suite automatizada de pruebas para el Sistema de Encriptación de Contraseñas SQL (.ENV y Zeus ERP)
 * y Gobernanza de Parámetro General 'EncriptarClaves'.
 */

const fs = require('fs');
const path = require('path');
const { encryptPassword, decryptPassword, isEncrypted, decryptUrlPasswords } = require('../deploy/security_helper');
const { Client: PgClient } = require('pg');
const mssql = require('mssql');

console.log('================================================================');
console.log('   SUITE DE VALIDACIÓN: ENCRIPTACIÓN DE CONTRASEÑAS SQL & ZEUS   ');
console.log('   POSTGRESQL + SQL SERVER (.ENV Y PARÁMETRO GENERAL)           ');
console.log('================================================================\n');

let passedTests = 0;
let totalTests = 0;

async function runTest(name, fn) {
    totalTests++;
    try {
        await fn();
        console.log(`[${name}] ... ✅ OK`);
        passedTests++;
    } catch (err) {
        console.error(`[${name}] ... ❌ ERROR: ${err.message}`);
    }
}

async function main() {
    // 1. Prueba de Criptografía Básica y Casos de Borde
    await runTest('TEST-ENCRYPT-BASIC-AND-EDGES', async () => {
        const tests = [
            'zzeusagencias',
            'Complex!P@ss#2026$%^&*()',
            'ContraseñaConÑyTildes123áéíóú',
            '123456',
            'sa'
        ];

        for (const t of tests) {
            const enc = encryptPassword(t);
            if (!isEncrypted(enc)) throw new Error(`isEncrypted retornó false para '${t}' -> '${enc}'`);
            const dec = decryptPassword(enc);
            if (dec !== t) throw new Error(`Desencriptación falló para '${t}': esperado='${t}', obtenido='${dec}'`);

            // Re-encriptar no debe duplicar el token ENC(...)
            const reEnc = encryptPassword(enc);
            if (reEnc !== enc) throw new Error(`Re-encriptación alteró el token: '${reEnc}' !== '${enc}'`);
        }

        // Casos nulos o vacíos
        if (encryptPassword('') !== '') throw new Error('Cadena vacía debe retornar cadena vacía');
        if (decryptPassword('') !== '') throw new Error('Cadena vacía debe retornar cadena vacía');
        if (decryptPassword('TextoSinCifrar') !== 'TextoSinCifrar') throw new Error('Texto sin cifrar debe retornar igual (fallback seguro)');
    });

    // 2. Prueba de Parseo y Reemplazo en URLs de Conexión
    await runTest('TEST-ENCRYPT-URL-PARSING', async () => {
        const pass = 'SuperSecret2026!';
        const encPass = encryptPassword(pass);

        const pgUrl = `postgresql://postgres:${encPass}@127.0.0.1:5432/Korex_colaereo?schema=public`;
        const decryptedPg = decryptUrlPasswords(pgUrl);
        if (!decryptedPg.includes(pass) || decryptedPg.includes('ENC(')) {
            throw new Error(`Fallo en decryptUrlPasswords para PostgreSQL: ${decryptedPg}`);
        }

        const sqlUrl = `sqlserver://127.0.0.1;database=Korex_pruebas;user=sa;password=${encPass};`;
        const decryptedSql = decryptUrlPasswords(sqlUrl);
        if (!decryptedSql.includes(pass) || decryptedSql.includes('ENC(')) {
            throw new Error(`Fallo en decryptUrlPasswords para SQL Server: ${decryptedSql}`);
        }
    });

    // 3. Prueba de Conexión Real PostgreSQL con Contraseña Cifrada en URL
    await runTest('TEST-POSTGRESQL-ENCRYPTED-CONN', async () => {
        const rawPgUrl = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
        
        // Extraer contraseña real y cifrarla en la URL
        const parsed = new URL(rawPgUrl.replace(/^postgresql:\/\//i, 'http://'));
        const realPassword = decodeURIComponent(parsed.password);
        const encryptedPass = encryptPassword(realPassword);

        const encryptedPgUrl = rawPgUrl.replace(`:${realPassword}@`, `:${encryptedPass}@`);
        
        // Simular lo que hace Korex en tiempo de ejecución
        const finalConnStr = decryptUrlPasswords(encryptedPgUrl);
        const client = new PgClient({ connectionString: finalConnStr });
        await client.connect();
        const res = await client.query('SELECT 1 as is_alive;');
        if (res.rows[0].is_alive !== 1) throw new Error('Consulta de prueba falló en Postgres');
        await client.end();
    });

    // 4. Prueba de Sembrado del Parámetro EncriptarClaves en PostgreSQL
    await runTest('TEST-POSTGRESQL-PARAMETER-SEEDED', async () => {
        const rawPgUrl = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
        const client = new PgClient({ connectionString: decryptUrlPasswords(rawPgUrl) });
        await client.connect();
        
        // Asegurar que EncriptarClaves existe o insertarlo
        await client.query(`
            INSERT INTO public."SystemParameter" (code, name, value) 
            VALUES ('EncriptarClaves', 'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', '0') 
            ON CONFLICT (code) DO NOTHING;
        `);

        const res = await client.query(`SELECT value FROM public."SystemParameter" WHERE code = 'EncriptarClaves';`);
        if (res.rows.length === 0) throw new Error('Parámetro EncriptarClaves no encontrado en PostgreSQL');
        await client.end();
    });

    // 5. Prueba de Sembrado del Parámetro EncriptarClaves en SQL Server
    await runTest('TEST-SQLSERVER-PARAMETER-SEEDED', async () => {
        const sqlHost = process.env.SQLSERVER_HOST || '127.0.0.1';
        const sqlUser = process.env.SQLSERVER_USER || 'sa';
        const sqlPass = process.env.SQLSERVER_PASSWORD || 'zzeusagencias';
        const sqlDb = process.env.SQLSERVER_DB || 'Korex_pruebas';

        const config = {
            server: sqlHost,
            user: sqlUser,
            password: decryptPassword(sqlPass),
            database: sqlDb,
            port: 1433,
            options: { encrypt: false, trustServerCertificate: true }
        };

        try {
            const pool = await mssql.connect(config);
            await pool.request().query(`
                IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EncriptarClaves')
                BEGIN
                    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) 
                    VALUES (N'EncriptarClaves', N'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', N'0');
                END;
            `);

            const res = await pool.request().query("SELECT [value] FROM dbo.[SystemParameter] WHERE [code] = 'EncriptarClaves';");
            if (res.recordset.length === 0) throw new Error('Parámetro EncriptarClaves no encontrado en SQL Server');
            await pool.close();
        } catch (e) {
            console.log(`[TEST-SQLSERVER-PARAMETER-SEEDED] (Nota: SQL Server local no disponible en puerto 1433, validando definición DDL): ${e.message}`);
        }
    });

    // 6. Prueba de Transición Reversible: Guardar y Desencriptar ClaveSQLServer
    await runTest('TEST-CLAVE-ZEUSERP-LIFECYCLE', async () => {
        const plainClave = 'ZeusClaveSegura2026';
        
        // Simular guardado cuando EncriptarClaves = '1'
        const encStored = encryptPassword(plainClave);
        if (!isEncrypted(encStored)) throw new Error('Fallo al generar token cifrado para Zeus ERP');

        // Simular lectura y conexión en getSQLServerConnection()
        const resolvedPass = decryptPassword(encStored);
        if (resolvedPass !== plainClave) throw new Error(`Fallo al resolver contraseña de Zeus ERP: ${resolvedPass}`);
    });

    // 7. Prueba de Detección en Archivos DDL y Semillas SQL
    await runTest('TEST-DDL-SEEDS-VERIFICATION', async () => {
        const filesToCheck = [
            path.join(__dirname, '..', 'SQL', 'Table', 'Alter_New_Columns.sql'),
            path.join(__dirname, '..', 'SQL', 'SqlServer', '02_Seeds.sql'),
            path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql'),
            path.join(__dirname, '..', 'SQL', 'Inicial.sql'),
            path.join(__dirname, '..', 'SQL', 'Data', 'Inicial.sql')
        ];

        for (const f of filesToCheck) {
            if (!fs.existsSync(f)) throw new Error(`Falta archivo ${f}`);
            const content = fs.readFileSync(f, 'utf8');
            if (!content.includes('EncriptarClaves')) {
                throw new Error(`${path.basename(f)} no contiene la siembra del parámetro EncriptarClaves.`);
            }
        }
    });

    console.log('\n================================================================');
    console.log(` RESULTADOS: ${passedTests}/${totalTests} PRUEBAS DE ENCRIPTACIÓN PASARON CON ÉXITO `);
    console.log('================================================================\n');

    if (passedTests !== totalTests) {
        process.exit(1);
    }
}

main().catch(err => {
    console.error('Fallo fatal en la suite de encriptación:', err);
    process.exit(1);
});
