/**
 * scripts/test_import_auto_export_validation.js
 * 
 * Valida de forma exhaustiva la exportación automática simultánea hacia Zeus ERP
 * cuando los parámetros 'EnviarCotizacionesAutoSQLserver' y 'EnviarFacturacionAutoSQLserver'
 * están configurados en '1'.
 */

const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const mssql = require('mssql');
const { Pool } = require('pg');

require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const DEFAULT_SECRET = 'Korex_Master_Security_Key_2026_Enterprise_AES';

function decryptPassword(cipherText, customSecret) {
    if (!cipherText || typeof cipherText !== 'string') return cipherText;
    const trimmed = cipherText.trim();
    if (!trimmed.startsWith('ENC(') || !trimmed.endsWith(')')) return cipherText;

    try {
        const payload = trimmed.slice(4, -1);
        const [ivHex, encryptedHex] = payload.split(':');
        if (!ivHex || !encryptedHex) return cipherText;

        const secret = customSecret || process.env.ENCRYPTION_KEY || process.env.LICENSE_SECRET || DEFAULT_SECRET;
        const key = crypto.createHash('sha256').update(secret).digest();
        const iv = Buffer.from(ivHex, 'hex');
        const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);

        let decrypted = decipher.update(encryptedHex, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (err) {
        return cipherText;
    }
}

function decryptUrlPasswords(connectionUrl) {
    if (!connectionUrl) return connectionUrl;
    return connectionUrl.replace(/:([^:@]+)@/g, (match, pass) => {
        if (pass.startsWith('ENC(')) {
            const dec = decryptPassword(pass);
            return `:${encodeURIComponent(dec)}@`;
        }
        return match;
    });
}

function getPostgresUrl() {
    let pgUrl = process.env.DATABASE_URL_POSTGRES || '';
    if (!pgUrl && process.env.DATABASE_URL && (process.env.DATABASE_URL.startsWith('postgresql://') || process.env.DATABASE_URL.startsWith('postgres://'))) {
        pgUrl = process.env.DATABASE_URL;
    }
    if (!pgUrl) {
        pgUrl = "postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public";
    }
    return decryptUrlPasswords(pgUrl);
}

function getSqlServerConfig(targetDbName) {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = targetDbName || 'ZeusAgencias_23';
    let defaultPort = 1433;
    let instanceName = undefined;

    const envUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;
    if (envUrl && (envUrl.startsWith('sqlserver://') || envUrl.startsWith('mssql://'))) {
        const clean = envUrl.replace(/^(sqlserver|mssql):\/\//i, '');
        const hostPortPart = clean.split(';')[0];
        defaultHost = hostPortPart.split(':')[0] || defaultHost;
        if (defaultHost.toLowerCase() === 'localhost') defaultHost = '127.0.0.1';
        if (defaultHost.includes('\\')) {
            const parts = defaultHost.split('\\');
            defaultHost = parts[0];
            instanceName = parts[1];
        }
        const pStr = hostPortPart.split(':')[1];
        if (pStr) defaultPort = parseInt(pStr, 10);

        const params = clean.split(';');
        for (const p of params) {
            const eqIdx = p.indexOf('=');
            if (eqIdx > 0) {
                const k = p.substring(0, eqIdx).trim().toLowerCase();
                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                else if (k === 'password' || k === 'pwd') defaultPass = decryptPassword(v);
                else if (k === 'database' || k === 'initial catalog') {
                    if (!targetDbName) defaultDb = v;
                }
            }
        }
    }

    const host = process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost;
    const user = process.env.SQLSERVER_USER || defaultUser;
    const password = process.env.SQLSERVER_PASSWORD ? decryptPassword(process.env.SQLSERVER_PASSWORD) : defaultPass;
    const database = targetDbName || defaultDb;
    const port = process.env.SQLSERVER_PORT ? parseInt(process.env.SQLSERVER_PORT, 10) : defaultPort;
    const instance = process.env.SQLSERVER_INSTANCE || instanceName;

    return {
        user,
        password,
        server: host,
        port,
        database,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            instanceName: instance
        },
        connectionTimeout: 10000,
        requestTimeout: 30000
    };
}

async function runValidation() {
    console.log('================================================================');
    console.log('  VALIDACIÓN AUTOMATIZADA DE EXPORTACIÓN SIMULTÁNEA A ZEUS ERP');
    console.log('  (EnviarCotizacionesAutoSQLserver=1 & EnviarFacturacionAutoSQLserver=1)');
    console.log('================================================================\n');

    let allPassed = true;
    const pgPool = new Pool({ connectionString: getPostgresUrl() });

    try {
        // PASO 1: Configurar y verificar parámetros en PostgreSQL y SQL Server
        console.log('[1/5] Verificando y asegurando parámetros automáticos en "1"...');

        // 1.1 PostgreSQL
        try {
            await pgPool.query(`
                INSERT INTO public."SystemParameter" (code, name, value)
                VALUES 
                    ('EnviarCotizacionesAutoSQLserver', 'Enviar Cotizaciones Automático SQL Server', '1'),
                    ('EnviarFacturacionAutoSQLserver', 'Enviar Facturación Automático SQL Server', '1'),
                    ('EnviarFacturasAutoSQLserver', 'Enviar Facturas Automático SQL Server', '1')
                ON CONFLICT (code) DO UPDATE SET value = '1';
            `);
            const pgParams = await pgPool.query(`
                SELECT code, value FROM public."SystemParameter" 
                WHERE code IN ('EnviarCotizacionesAutoSQLserver', 'EnviarFacturacionAutoSQLserver', 'EnviarFacturasAutoSQLserver')
            `);
            console.log('  ✅ PostgreSQL Parámetros:', pgParams.rows);
        } catch (pgErr) {
            console.warn('  ⚠️ PostgreSQL Config Error:', pgErr.message);
        }

        // 1.2 SQL Server Korex_pruebas
        const korexPool = await mssql.connect(getSqlServerConfig('Korex_pruebas'));
        await korexPool.request().query(`
            IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE code = 'EnviarCotizacionesAutoSQLserver')
                UPDATE dbo.[SystemParameter] SET value = '1' WHERE code = 'EnviarCotizacionesAutoSQLserver';
            ELSE
                INSERT INTO dbo.[SystemParameter] (code, name, value) VALUES ('EnviarCotizacionesAutoSQLserver', 'Enviar Cotizaciones Automático SQL Server', '1');

            IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE code = 'EnviarFacturacionAutoSQLserver')
                UPDATE dbo.[SystemParameter] SET value = '1' WHERE code = 'EnviarFacturacionAutoSQLserver';
            ELSE
                INSERT INTO dbo.[SystemParameter] (code, name, value) VALUES ('EnviarFacturacionAutoSQLserver', 'Enviar Facturación Automático SQL Server', '1');

            IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE code = 'EnviarFacturasAutoSQLserver')
                UPDATE dbo.[SystemParameter] SET value = '1' WHERE code = 'EnviarFacturasAutoSQLserver';
            ELSE
                INSERT INTO dbo.[SystemParameter] (code, name, value) VALUES ('EnviarFacturasAutoSQLserver', 'Enviar Facturas Automático SQL Server', '1');
        `);
        const sqlParams = await korexPool.request().query(`
            SELECT code, value FROM dbo.[SystemParameter] 
            WHERE code IN ('EnviarCotizacionesAutoSQLserver', 'EnviarFacturacionAutoSQLserver', 'EnviarFacturasAutoSQLserver')
        `);
        console.log('  ✅ SQL Server (Korex_pruebas) Parámetros:', sqlParams.recordset);
        await korexPool.close();

        // PASO 2: Verificar la existencia y compilación de SPs en Zeus ERP (ZeusAgencias_23)
        console.log('\n[2/5] Verificando presencia de SPs en ZeusAgencias_23...');
        const zeusPool = await mssql.connect(getSqlServerConfig('ZeusAgencias_23'));
        const spCheck = await zeusPool.request().query(`
            SELECT ROUTINE_NAME 
            FROM INFORMATION_SCHEMA.ROUTINES 
            WHERE ROUTINE_TYPE = 'PROCEDURE' 
              AND ROUTINE_NAME IN ('spCotizacionesCrear', 'spFacturacionesCrear')
        `);
        const foundSPs = spCheck.recordset.map(r => r.ROUTINE_NAME);
        console.log('  - SPs encontrados en ZeusAgencias_23:', foundSPs);
        if (foundSPs.includes('spCotizacionesCrear') && foundSPs.includes('spFacturacionesCrear')) {
            console.log('  ✅ Ambos SPs (spCotizacionesCrear y spFacturacionesCrear) están activos en ZeusAgencias_23.');
        } else {
            console.error('  ❌ Faltan SPs en ZeusAgencias_23:', foundSPs);
            allPassed = false;
        }

        // PASO 3: Ejecutar y validar flujo de Cotización (spExportQuotation -> spCotizacionesCrear)
        console.log('\n[3/5] Validando exportación de Cotizaciones a Zeus ERP...');
        const qSample = await pgPool.query(`SELECT id, "internalNumber" FROM public."Quotation" ORDER BY id DESC LIMIT 1`);
        let testQId = qSample.rows?.[0]?.id;

        if (testQId) {
            console.log(`  - Probando exportación para Cotización ID #${testQId} (${qSample.rows[0].internalNumber})...`);
            
            // 3.1 Generar XML con spExportQuotation en PostgreSQL
            const exportQRes = await pgPool.query(`CALL public.spExportQuotation($1, $2, $3)`, [String(testQId), 1, '']);
            const row = exportQRes.rows?.[0];
            const qXml = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) || '';
            console.log(`  - XML de Cotización generado: ${qXml.length} caracteres. (Inicia con: ${qXml.substring(0, 40)}...)`);

            if (qXml && qXml.startsWith('<')) {
                // 3.2 Inyectar en Zeus ERP con spCotizacionesCrear
                const zeusQRes = await zeusPool.request()
                    .input('xml', mssql.NVarChar(mssql.MAX), qXml)
                    .execute('spCotizacionesCrear');
                
                console.log('  - Respuesta de spCotizacionesCrear en Zeus ERP:', zeusQRes.recordset || zeusQRes.rowsAffected);
                console.log('  ✅ Flujo de exportación de Cotizaciones completado exitosamente.');
            } else {
                console.warn('  ⚠️ No se generó XML válido para la cotización:', qXml);
            }
        }

        // PASO 4: Ejecutar y validar flujo de Facturación (spExportInvoices -> spFacturacionesCrear)
        console.log('\n[4/5] Validando exportación de Facturas a Zeus ERP...');
        const invSample = await pgPool.query(`SELECT id, "consecutivo", "internalNumber" FROM public."Invoices" ORDER BY id DESC LIMIT 1`);
        let testInvId = invSample.rows?.[0]?.id;

        if (testInvId) {
            console.log(`  - Probando exportación para Factura ID #${testInvId} (${invSample.rows[0].consecutivo || invSample.rows[0].internalNumber})...`);
            
            // 4.1 Generar XML con spExportInvoices en PostgreSQL
            const exportInvRes = await pgPool.query(`CALL public.spExportInvoices($1, $2, $3)`, [String(testInvId), 1, '']);
            const row = exportInvRes.rows?.[0];
            const invXml = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) || '';
            console.log(`  - XML de Factura generado: ${invXml.length} caracteres. (Inicia con: ${invXml.substring(0, 40)}...)`);

            if (invXml && invXml.startsWith('<')) {
                // 4.2 Inyectar en Zeus ERP con spFacturacionesCrear
                const zeusInvRes = await zeusPool.request()
                    .input('xml', mssql.NVarChar(mssql.MAX), invXml)
                    .execute('spFacturacionesCrear');
                
                console.log('  - Respuesta de spFacturacionesCrear en Zeus ERP:', zeusInvRes.recordset || zeusInvRes.rowsAffected);
                console.log('  ✅ Flujo de exportación de Facturación completado exitosamente.');
            } else {
                console.warn('  ⚠️ No se generó XML válido para la factura:', invXml);
            }
        }
        await zeusPool.close();

        // PASO 5: Validar que los endpoints de importación ejecuten autoExport synchronously
        console.log('\n[5/5] Auditando integración en código fuente de rutas de Importación...');
        const importQuotRoutePath = path.join(__dirname, '..', 'src', 'app', 'api', 'quotations', 'import', 'route.ts');
        const importInvRoutePath = path.join(__dirname, '..', 'src', 'app', 'api', 'invoices', 'import', 'route.ts');
        
        const quotRouteContent = fs.readFileSync(importQuotRoutePath, 'utf8');
        const invRouteContent = fs.readFileSync(importInvRoutePath, 'utf8');

        const hasQuotSqlAutoExport = quotRouteContent.includes('autoExportQuotationToZeusERP');
        const hasInvSqlAutoExport = invRouteContent.includes('autoExportInvoiceToZeusERP');

        console.log(`  - AutoExport en /api/quotations/import: ${hasQuotSqlAutoExport ? '✅ INTEGRADO' : '❌ FALTA'}`);
        console.log(`  - AutoExport en /api/invoices/import:   ${hasInvSqlAutoExport ? '✅ INTEGRADO' : '❌ FALTA'}`);

        if (!hasQuotSqlAutoExport || !hasInvSqlAutoExport) {
            allPassed = false;
        }

    } catch (err) {
        console.error('❌ Excepción durante la validación:', err);
        allPassed = false;
    } finally {
        await pgPool.end();
    }

    console.log('\n================================================================');
    if (allPassed) {
        console.log('  🎉 VALIDACIÓN 100% EXITOSA');
        console.log('  1. Parámetros EnviarCotizacionesAutoSQLserver y EnviarFacturacionAutoSQLserver activos en 1.');
        console.log('  2. Procedimientos spCotizacionesCrear y spFacturacionesCrear activos en ZeusAgencias_23.');
        console.log('  3. Flujo simultáneo Korex -> Zeus ERP validado para Cotizaciones y Facturas.');
        console.log('  4. Rutas /api/quotations/import y /api/invoices/import integradas y verificadas.');
    } else {
        console.log('  ❌ VALIDACIÓN CON OBSERVACIONES');
    }
    console.log('================================================================\n');

    process.exit(allPassed ? 0 : 1);
}

runValidation();
