#!/usr/bin/env node
/**
 * scripts/encrypt_password.js
 * Herramienta de línea de comandos para encriptar y desencriptar contraseñas de bases de datos
 * y sanitizar/cifrar variables de entorno en el archivo .env.
 * 
 * Uso:
 *   node scripts/encrypt_password.js <password>
 *   node scripts/encrypt_password.js --decrypt <ENC(...)>
 *   node scripts/encrypt_password.js --env
 *   node scripts/encrypt_password.js --test
 */

const fs = require('fs');
const path = require('path');
const { encryptPassword, decryptPassword, isEncrypted, decryptUrlPasswords } = require('../deploy/security_helper');

const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
================================================================
   KOREX PLATFORM - UTILIDAD DE ENCRIPTACIÓN DE CONTRASEÑAS    
================================================================

Uso:
  node scripts/encrypt_password.js <texto_plano>
      -> Retorna el token cifrado ENC(...)

  node scripts/encrypt_password.js --decrypt <token_ENC>
      -> Retorna la contraseña en texto plano

  node scripts/encrypt_password.js --env
      -> Cifra las contraseñas en el archivo .env activo

  node scripts/encrypt_password.js --test
      -> Ejecuta pruebas de verificación criptográfica
`);
    process.exit(0);
}

if (args[0] === '--test') {
    console.log('[SECURITY_TEST] Ejecutando pruebas de encriptación AES-256...');
    const testCases = [
        'zzeusagencias',
        'Complex!P@ss#2026$%^&*()',
        'ContraseñaConÑyTildes123áéíóú',
        '123456',
        'sql-server-secure-key'
    ];

    let allOk = true;
    for (const raw of testCases) {
        const encrypted = encryptPassword(raw);
        if (!isEncrypted(encrypted)) {
            console.error(`❌ Falló isEncrypted para: ${raw} -> ${encrypted}`);
            allOk = false;
            continue;
        }
        const decrypted = decryptPassword(encrypted);
        if (decrypted !== raw) {
            console.error(`❌ Falló desencriptación: original='${raw}', desencriptado='${decrypted}'`);
            allOk = false;
            continue;
        }
        console.log(`✅ OK: '${raw}' -> '${encrypted}' -> '${decrypted}'`);
    }

    // Probar URLs
    const testPgUrl = `postgresql://postgres:${encryptPassword('mySecretPass')}@127.0.0.1:5432/Korex_colaereo?schema=public`;
    const decryptedPgUrl = decryptUrlPasswords(testPgUrl);
    if (decryptedPgUrl.includes('mySecretPass') && !decryptedPgUrl.includes('ENC(')) {
        console.log(`✅ OK decryptUrlPasswords (PostgreSQL): ${decryptedPgUrl}`);
    } else {
        console.error(`❌ Falló decryptUrlPasswords: ${decryptedPgUrl}`);
        allOk = false;
    }

    const testSqlUrl = `sqlserver://127.0.0.1;database=Korex;user=sa;password=${encryptPassword('SqlPass2026')};`;
    const decryptedSqlUrl = decryptUrlPasswords(testSqlUrl);
    if (decryptedSqlUrl.includes('SqlPass2026') && !decryptedSqlUrl.includes('ENC(')) {
        console.log(`✅ OK decryptUrlPasswords (SQL Server): ${decryptedSqlUrl}`);
    } else {
        console.error(`❌ Falló decryptUrlPasswords: ${decryptedSqlUrl}`);
        allOk = false;
    }

    if (allOk) {
        console.log('\n🌟 ¡Todas las pruebas criptográficas pasaron exitosamente (100% OK)!');
        process.exit(0);
    } else {
        console.error('\n❌ Se detectaron fallas en las pruebas criptográficas.');
        process.exit(1);
    }
}

if (args[0] === '--decrypt') {
    const token = args[1];
    if (!token) {
        console.error('Error: Debe proporcionar el token ENC(...) a desencriptar.');
        process.exit(1);
    }
    const plain = decryptPassword(token);
    console.log(plain);
    process.exit(0);
}

if (args[0] === '--env') {
    const envPath = path.join(__dirname, '..', '.env');
    if (!fs.existsSync(envPath)) {
        console.error('Error: No se encontró el archivo .env en la raíz del proyecto.');
        process.exit(1);
    }

    let envContent = fs.readFileSync(envPath, 'utf8');
    let modified = false;

    // Cifrar contraseñas dentro de DATABASE_URL (Postgres)
    envContent = envContent.replace(/^(DATABASE_URL(?:_POSTGRES)?\s*=\s*["']?)(postgresql:\/\/[^:]+:)([^@]+)(@.+["']?)$/m, (m, prefix, userPart, passPart, restPart) => {
        const cleanPass = passPart.trim();
        if (!isEncrypted(cleanPass) && cleanPass !== '') {
            modified = true;
            const enc = encryptPassword(cleanPass);
            console.log(`[ENV_ENCRYPT] Cifrada contraseña en ${prefix.split('=')[0].trim()}`);
            return `${prefix}${userPart}${enc}${restPart}`;
        }
        return m;
    });

    // Cifrar contraseñas dentro de DATABASE_URL_SQLSERVER
    envContent = envContent.replace(/(password=)([^;"]+)(;?)/gi, (m, prefix, passPart, suffix) => {
        const cleanPass = passPart.trim();
        if (!isEncrypted(cleanPass) && cleanPass !== '') {
            modified = true;
            const enc = encryptPassword(cleanPass);
            console.log(`[ENV_ENCRYPT] Cifrada contraseña en cadena de conexión SQL Server`);
            return `${prefix}${enc}${suffix}`;
        }
        return m;
    });

    // Cifrar variable SQLSERVER_PASSWORD o SQL_PASSWORD directa
    envContent = envContent.replace(/^((?:SQLSERVER_PASSWORD|SQL_PASSWORD|DB_PASSWORD)\s*=\s*["']?)([^"'\r\n]+)(["']?)$/m, (m, prefix, passPart, suffix) => {
        const cleanPass = passPart.trim();
        if (!isEncrypted(cleanPass) && cleanPass !== '') {
            modified = true;
            const enc = encryptPassword(cleanPass);
            console.log(`[ENV_ENCRYPT] Cifrada variable ${prefix.split('=')[0].trim()}`);
            return `${prefix}${enc}${suffix}`;
        }
        return m;
    });

    if (modified) {
        fs.writeFileSync(envPath, envContent, 'utf8');
        console.log('✅ Archivo .env actualizado con contraseñas encriptadas.');
    } else {
        console.log('ℹ️ Las contraseñas en el archivo .env ya se encontraban cifradas o vacías.');
    }
    process.exit(0);
}

// Por defecto: Encriptar el argumento provisto
const input = args[0];
const encrypted = encryptPassword(input);
console.log(encrypted);
