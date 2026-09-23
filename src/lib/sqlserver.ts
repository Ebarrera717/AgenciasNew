import mssql from 'mssql'
import prisma from './prisma'
import { decryptPassword, decryptUrlPasswords } from './security'

import fs from 'fs'
import path from 'path'

export function isSQLServerMode(): boolean {
    try {
        const envPath = path.join(process.cwd(), '.env');
        if (fs.existsSync(envPath)) {
            const content = fs.readFileSync(envPath, 'utf8');
            const match = content.match(/^DATABASE_PROVIDER\s*=\s*["']?([^"'\r\n]+)/m);
            if (match && match[1]) {
                const prov = match[1].replace(/["']/g, '').trim().toLowerCase();
                if (prov === 'sqlserver') return true;
                if (prov === 'postgresql') return false;
            }
        }
    } catch (e) {}

    const provider = (process.env.DATABASE_PROVIDER || '').toLowerCase().trim();
    if (provider === 'sqlserver') return true;
    if (provider === 'postgresql') return false;

    const dbUrl = (process.env.DATABASE_URL || '').trim();
    return dbUrl.startsWith('sqlserver://') || dbUrl.startsWith('mssql://');
}


export function parseSQLServerUrl(connStr: string) {
    let clean = connStr.replace(/^(sqlserver|mssql):\/\//i, '');
    let hostPortPart = clean.split(';')[0];
    let host = hostPortPart.split(':')[0] || '127.0.0.1';
    let portStr = hostPortPart.split(':')[1] || '';

    let instanceName: string | undefined = undefined;
    if (host.includes('\\')) {
        const parts = host.split('\\');
        host = parts[0];
        instanceName = parts[1];
    }

    let database = '';
    let user = '';
    let password = '';

    const params = clean.split(';');
    for (const p of params) {
        const eqIdx = p.indexOf('=');
        if (eqIdx > 0) {
            const key = p.substring(0, eqIdx).trim().toLowerCase();
            const val = decodeURIComponent(p.substring(eqIdx + 1).trim());
            if (key === 'database') database = val;
            else if (key === 'user' || key === 'user id' || key === 'uid') user = val;
            else if (key === 'password' || key === 'pwd') password = decryptPassword(val);
            else if (key === 'instance' || key === 'instancename') instanceName = val;
            else if (key === 'port') portStr = val;
        }
    }

    return {
        servidor: instanceName ? `${host}\\${instanceName}` : host,
        instanceName: instanceName,
        rawHost: host,
        usuario: user,
        clave: password,
        base_datos: database,
        puerto: portStr
    };
}

/**
 * Obtiene el nombre de la base de datos externa de Zeus ERP desde Parámetros del Sistema (BaseSQLServer)
 * o desde process.env.ZEUS_ERP_DB, por defecto 'ZeusAgencias_23'. NUNCA Korex_pruebas.
 */
export async function getZeusERPDatabaseName(): Promise<string> {
    try {
        const param = await prisma.systemParameter.findUnique({
            where: { code: 'BaseSQLServer' },
            select: { value: true }
        });
        if (param && param.value && param.value.trim() !== '') {
            return param.value.trim();
        }
    } catch (e) {}

    return process.env.ZEUS_ERP_DB || 'ZeusAgencias_23';
}

/**
 * Obtiene la conexión a SQL Server usando la variable de entorno o la función de Postgres.
 */
export async function getSQLServerConnection(overrideDbName?: string) {
    let configRow: any = null;
    let sqlUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;

    try {
        const envPath = path.join(process.cwd(), '.env');
        if (fs.existsSync(envPath)) {
            const content = fs.readFileSync(envPath, 'utf8');
            const match = content.match(/^DATABASE_URL_SQLSERVER\s*=\s*["']?([^"'\r\n]+)/m) || content.match(/^DATABASE_URL\s*=\s*["']?([^"'\r\n]+)/m);
            if (match && match[1]) {
                const cleanUrl = match[1].replace(/["']/g, '').trim();
                if (cleanUrl.startsWith('sqlserver://') || cleanUrl.startsWith('mssql://')) {
                    sqlUrl = cleanUrl;
                }
            }
        }
    } catch (e) {}

    if (sqlUrl && (sqlUrl.startsWith('sqlserver://') || sqlUrl.startsWith('mssql://'))) {
        configRow = parseSQLServerUrl(sqlUrl);
    } else {
        try {
            const result = await prisma.$queryRawUnsafe<any[]>('SELECT * FROM "fnGetSQLServerConfig"()');
            if (result && result.length > 0) {
                configRow = result[0];
            }
        } catch (e: any) {
            console.warn('[SQL_CONN] No se pudo leer fnGetSQLServerConfig de Postgres:', e.message);
        }
    }

    if (!configRow || !configRow.servidor || configRow.servidor.trim() === '') {
        throw new Error('Parámetros de conexión a SQL Server no configurados en .env ni en Parámetros del Sistema.');
    }

    let serverVal = (configRow.servidor || '').trim();
    if (serverVal.includes('/')) serverVal = serverVal.replace('/', '\\');
    const userVal = (configRow.usuario || '').trim();
    const passVal = decryptPassword((configRow.clave || '').trim());
    const dbVal = overrideDbName || (configRow.base_datos || '').trim();
    const portVal = (configRow.puerto || '').trim();

    let host = serverVal;
    let instanceName: string | undefined = configRow.instanceName;

    if (serverVal.includes('\\')) {
        const parts = serverVal.split('\\');
        host = parts[0];
        instanceName = parts[1];
    }

    const sqlConfig: any = {
        user: userVal,
        password: passVal,
        server: host,
        database: dbVal,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true,
            connectTimeout: 15000
        },
        connectionTimeout: 15000,
        requestTimeout: 60000
    };

    if (instanceName) {
        sqlConfig.options.instanceName = instanceName;
        if (portVal && portVal !== '' && portVal !== '1433') {
            sqlConfig.port = parseInt(portVal, 10);
        }
        console.log(`[SQL_DEBUG] Conectando a [${dbVal}] en: ${host}\\${instanceName} (Vía SQL Browser)`);
    } else if (portVal && portVal !== '') {
        sqlConfig.port = parseInt(portVal, 10);
        console.log(`[SQL_DEBUG] Conectando a [${dbVal}] en: ${host}:${sqlConfig.port}`);
    } else {
        sqlConfig.port = 1433;
        console.log(`[SQL_DEBUG] Conectando a [${dbVal}] en: ${host}:1433`);
    }

    try {
        const pool = new mssql.ConnectionPool(sqlConfig);
        await pool.connect();
        console.log(`[SQL_CONN] ¡ÉXITO al conectar con BD [${dbVal}] en SQL Server (${host}${instanceName ? '\\' + instanceName : ''})!`);
        return pool;
    } catch (error: any) {
        console.warn(`[SQL_CONN] Falló intento principal de conexión a '${dbVal}' en '${host}${instanceName ? '\\' + instanceName : ''}': ${error.message}`);
        
        // Estrategia de fallbacks inteligentes
        const fallbackHosts: { server: string; instanceName?: string; port?: number }[] = [];
        if (instanceName) {
            if (host.toLowerCase() !== 'localhost') fallbackHosts.push({ server: 'localhost', instanceName });
            if (host !== '127.0.0.1') fallbackHosts.push({ server: '127.0.0.1', instanceName });
            const compName = process.env.COMPUTERNAME;
            if (compName && host.toUpperCase() !== compName.toUpperCase()) fallbackHosts.push({ server: compName, instanceName });
        } else {
            if (host !== '127.0.0.1') fallbackHosts.push({ server: '127.0.0.1', port: sqlConfig.port || 1433 });
            if (host.toLowerCase() !== 'localhost') fallbackHosts.push({ server: 'localhost', port: sqlConfig.port || 1433 });
        }

        for (const fb of fallbackHosts) {
            try {
                console.log(`[SQL_CONN] Intentando conexión de respaldo en '${fb.server}${fb.instanceName ? '\\' + fb.instanceName : ':' + (fb.port || 1433)}'...`);
                const fbConfig = {
                    ...sqlConfig,
                    server: fb.server,
                    port: fb.port,
                    options: { ...sqlConfig.options }
                };
                if (fb.instanceName) {
                    fbConfig.options.instanceName = fb.instanceName;
                    delete fbConfig.port;
                } else {
                    delete fbConfig.options.instanceName;
                }
                const poolFb = new mssql.ConnectionPool(fbConfig);
                await poolFb.connect();
                console.log(`[SQL_CONN] ¡ÉXITO al conectar con BD [${dbVal}] mediante fallback ${fb.server}!`);
                return poolFb;
            } catch (fbErr: any) {
                console.warn(`[SQL_CONN] Falló fallback en ${fb.server}: ${fbErr.message}`);
            }
        }

        const richMsg = `[Servidor Configurado: ${serverVal}${portVal ? ':' + portVal : ''} | Host Intentado: ${host} | Instancia: ${instanceName || 'Predeterminada'} | BD: ${dbVal} | Usuario: ${userVal}] - Error: ${error.message}${error.code ? ' [Código: ' + error.code + ']' : ''}`;
        const enrichedError = new Error(richMsg);
        (enrichedError as any).code = error.code || 'SQL_CONN_ERROR';
        (enrichedError as any).originalError = error;
        (enrichedError as any).connectionConfig = { server: serverVal, host, instanceName, port: sqlConfig.port, db: dbVal, user: userVal };
        throw enrichedError;
    }
}

/**
 * Ejecuta un Stored Procedure en SQL Server.
 */
export async function executeSQLServerProcedure(spName: string, params: any, targetDb?: string) {
    let pool;
    const startTime = Date.now();
    const isTraceProcedure = spName.toLowerCase().includes('sptraceability');
    const cleanSpName = spName.toLowerCase().replace(/^dbo\./, '').trim();
    const isZeusProcedure = cleanSpName === 'spfacturacionescrear' || 
                            cleanSpName === 'spcotizacionescrear';

    try {
        const fullSpName = spName.includes('.') ? spName : `dbo.${spName}`;
        let dbToUse = targetDb;
        if (!dbToUse && isZeusProcedure) {
            dbToUse = await getZeusERPDatabaseName();
        }
        console.log(`[SQL_SERVER_EXEC] Procedimiento: ${fullSpName} | BD Destino: ${dbToUse || 'Principal (.env)'} | Parámetros:`, JSON.stringify(params));
        pool = await getSQLServerConnection(dbToUse);
        const request = pool.request();

        if (params) {
            Object.keys(params).forEach(key => {
                const val = params[key];
                if (val === null || val === undefined) {
                    request.input(key, mssql.VarChar(mssql.MAX), null);
                } else if (typeof val === 'number') {
                    if (Number.isInteger(val)) {
                        request.input(key, mssql.Int, val);
                    } else {
                        request.input(key, mssql.Float, val);
                    }
                } else if (typeof val === 'boolean') {
                    request.input(key, mssql.Bit, val);
                } else {
                    request.input(key, mssql.VarChar(mssql.MAX), String(val));
                }
            });
        }

        const result = await request.execute(fullSpName);
        await pool.close();
        let executionResult: any = result.recordset;
        const allRecordsets = result.recordsets as any[] | undefined;
        if (Array.isArray(allRecordsets) && allRecordsets.length > 1) {
            const foundLogRs = allRecordsets.find(rs => rs && rs.length > 0 && ('invoiceId' in rs[0] || 'quotationId' in rs[0] || 'success' in rs[0]));
            executionResult = foundLogRs || allRecordsets[allRecordsets.length - 1] || result.recordset;
        }
        if (!executionResult && result.rowsAffected) {
            executionResult = result.rowsAffected;
        }

        if (!isTraceProcedure) {
            import('@/lib/traceability').then(({ recordTraceEvent }) => {
                recordTraceEvent({
                    module: 'BASE_DATOS',
                    screen: 'Ejecución SP SQL Server',
                    action: 'EJECUCION_SP',
                    process: `Invocación ${fullSpName}`,
                    eventType: 'SP_FIN',
                    stepName: `SP ${spName} Ejecutado`,
                    spName: fullSpName,
                    durationMs: Date.now() - startTime,
                    status: 'SUCCESS',
                    inputData: params,
                    outputData: executionResult
                }).catch(e => console.error('[TRACE_SP_AUTO_ERROR]', e?.message));
            }).catch(() => {});
        }

        return executionResult;
    } catch (err: any) {
        if (pool) await pool.close();

        const formattedTechMsg = err?.lineNumber || err?.procedureName
            ? `❌ Error T-SQL #${err?.number || 0} en SP '${err?.procedureName || spName}' (Línea ${err?.lineNumber || 'N/A'}): ${err?.message}`
            : (err?.message || 'Error de ejecución en SQL Server');

        if (!isTraceProcedure) {
            import('@/lib/traceability').then(({ recordTraceEvent }) => {
                recordTraceEvent({
                    module: 'BASE_DATOS',
                    screen: 'Ejecución SP SQL Server',
                    action: 'EJECUCION_SP',
                    process: `Fallo ${spName}`,
                    eventType: 'ERROR',
                    stepName: `Error en SP ${spName}`,
                    spName: spName,
                    durationMs: Date.now() - startTime,
                    status: 'ERROR',
                    inputData: params,
                    techMessage: formattedTechMsg,
                    stackTrace: err?.stack
                }).catch(e => console.error('[TRACE_SP_AUTO_ERROR]', e?.message));
            }).catch(() => {});
        }
        throw new Error(formattedTechMsg);
    }
}

