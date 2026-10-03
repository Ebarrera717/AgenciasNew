/**
 * ============================================================================
 * PROYECTO: KOREX ANALYTICS
 * SCRIPT: Validador Automatizado de Motores y Servicios Backend
 * EJECUCIÓN: node --experimental-strip-types scripts/validate_korex_analytics_backend.ts
 * ============================================================================
 */

import {
    encryptDatabasePassword,
    decryptDatabasePassword,
    hashUserPassword,
    verifyUserPassword,
    sanitizePayload
} from '../src/lib/korex-analytics/security';

import { AuditLogger } from '../src/lib/korex-analytics/audit-logger';
import { SQLPoolManager, SQLProfileConfig } from '../src/lib/korex-analytics/sql-pool-manager';

let totalChecks = 0;
let passedChecks = 0;
let failedChecks = 0;

function assertCheck(name: string, condition: boolean, errorMsg: string = '') {
    totalChecks++;
    if (condition) {
        passedChecks++;
        console.log(`  [OK] ${name}`);
    } else {
        failedChecks++;
        console.error(`  [FAIL] ${name} -> ${errorMsg}`);
    }
}

async function runBackendValidation() {
    console.log('============================================================================');
    console.log('       VALIDACIÓN DE MOTORES Y SERVICIOS BACKEND - KOREX ANALYTICS');
    console.log('============================================================================\n');

    // 1. SEGURIDAD & CIFRADO
    console.log('[CAPA 1] Validando Seguridad, Cifrado AES-256 y Bcrypt...');
    const rawPassword = 'SuperSecretDbPassword2026!#$';
    const encrypted = encryptDatabasePassword(rawPassword);
    assertCheck('Cifrado AES-256 genera formato ENC(...)', encrypted.startsWith('ENC(') && encrypted.endsWith(')'));

    const decrypted = decryptDatabasePassword(encrypted);
    assertCheck('Desencriptación AES-256 recupera el texto plano original', decrypted === rawPassword);

    const userPass = 'KaxAdminUserSecret123!';
    const userHash = await hashUserPassword(userPass);
    assertCheck('Bcrypt genera hash seguro de contraseña', userHash.startsWith('$2'));

    const matchOk = await verifyUserPassword(userPass, userHash);
    const matchFail = await verifyUserPassword('WrongPassword', userHash);
    assertCheck('Verificación bcrypt aprueba contraseña correcta', matchOk === true);
    assertCheck('Verificación bcrypt rechaza contraseña incorrecta', matchFail === false);

    const dirtyPayload = {
        user: 'admin',
        password: 'clearPassword',
        server: '192.168.1.10',
        nested: {
            dbClave: 'anotherSecret',
            port: 1433
        }
    };
    const cleanPayload = sanitizePayload(dirtyPayload);
    assertCheck('Sanitización enmascara contraseñas de primer nivel', cleanPayload.password === '***MASKED***');
    assertCheck('Sanitización enmascara contraseñas anidadas', cleanPayload.nested.dbClave === '***MASKED***');
    assertCheck('Sanitización preserva campos no sensibles', cleanPayload.user === 'admin' && cleanPayload.nested.port === 1433);

    // 2. AUDITORÍA & TRAZABILIDAD
    console.log('\n[CAPA 2] Validando Trazabilidad y Generación de TRC-XXXX...');
    const traceId1 = AuditLogger.generateTraceId();
    const traceId2 = AuditLogger.generateTraceId();
    const traceRegex = /^TRC-\d{8}-[A-F0-9]{6}$/;
    assertCheck('Trace ID cumple con formato TRC-YYYYMMDD-XXXXXX', traceRegex.test(traceId1));
    assertCheck('Trace IDs sucesivos son únicos', traceId1 !== traceId2);

    // 3. AISLAMIENTO Y VALIDACIÓN DE PERFILES SQL SERVER
    console.log('\n[CAPA 3] Validando Aislamiento de Bases y Reglas de Conexión SQL...');
    const mockProfile: SQLProfileConfig = {
        id: 1,
        name: 'Perfil Producción Norte',
        server: 'sql01.korex.local',
        defaultDatabase: 'Korex_Produccion_2026',
        allowedDatabases: ['Korex_Produccion_2026', 'Korex_Historico_2025'],
        username: 'kax_user',
        encryptedPassword: encryptDatabasePassword('MySecretPass')
    };

    // Intentar conectar a una base no permitida debe arrojar excepción de seguridad
    let unauthorizedErrorCaught = false;
    try {
        await SQLPoolManager.getConnection(mockProfile, 'Base_No_Autorizada_Hacker');
    } catch (err: any) {
        if (err.message.includes('no está autorizada en el perfil')) {
            unauthorizedErrorCaught = true;
        }
    }
    assertCheck('El gestor de pools bloquea bases de datos no autorizadas (Aislamiento A vs B)', unauthorizedErrorCaught);

    console.log('\n============================================================================');
    console.log(`RESULTADOS BACKEND: ${passedChecks} APROBADOS, ${failedChecks} FALLIDOS (TOTAL: ${totalChecks})`);
    console.log('============================================================================\n');

    if (failedChecks > 0) {
        process.exit(1);
    } else {
        console.log('>>> BACKEND VALIDADO EXITOSAMENTE: Seguridad, Aislamiento y Trazabilidad al 100%.\n');
        process.exit(0);
    }
}

runBackendValidation();
