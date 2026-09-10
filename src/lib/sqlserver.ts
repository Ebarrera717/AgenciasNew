import mssql from 'mssql'
import prisma from './prisma'

export function isSQLServerMode(): boolean {
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
    if (host.toLowerCase() === 'localhost') host = '127.0.0.1';

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
            else if (key === 'password' || key === 'pwd') password = val;
        }
    }

    return {
        servidor: instanceName ? `${host}\\${instanceName}` : host,
        usuario: user,
        clave: password,
        base_datos: database,
        puerto: portStr
    };
}

/**
 * Obtiene la conexión a SQL Server usando la variable de entorno o la función de Postgres.
 */
export async function getSQLServerConnection() {
    let configRow: any = null;
    const sqlUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;

    if (sqlUrl && (sqlUrl.startsWith('sqlserver://') || sqlUrl.startsWith('mssql://'))) {
        console.log('[SQL_CONN] Usando connection string de SQL Server desde variables de entorno (.env)...');
        configRow = parseSQLServerUrl(sqlUrl);
    } else {
        console.log('[SQL_CONN] Llamando a "fnGetSQLServerConfig"() en Postgres...');
        try {
            const result = await prisma.$queryRawUnsafe<any[]>('SELECT * FROM "fnGetSQLServerConfig"()');
            if (result && result.length > 0) {
                configRow = result[0];
            }
        } catch (e: any) {
            console.warn('[SQL_CONN] No se pudo leer fnGetSQLServerConfig de Postgres:', e.message);
        }
    }

    if (!configRow || !configRow.servidor) {
        throw new Error('No se pudo obtener la configuración de conexión a SQL Server desde .env ni desde la base de datos.');
    }

    let serverVal = (configRow.servidor || '').trim();
    if (serverVal.includes('/')) serverVal = serverVal.replace('/', '\\');
    const userVal = (configRow.usuario || '').trim();
    const passVal = (configRow.clave || '').trim();
    const dbVal = (configRow.base_datos || '').trim();
    const portVal = (configRow.puerto || '').trim();

    let host = serverVal;
    let instanceName: string | undefined = undefined;

    if (serverVal.includes('\\')) {
        const parts = serverVal.split('\\');
        host = parts[0];
        instanceName = parts[1];
    }

    if (host.toLowerCase() === 'localhost') {
        host = '127.0.0.1';
    }

    const sqlConfig: any = {
        user: userVal,
        password: passVal,
        server: host,
        database: dbVal,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true
        },
        connectionTimeout: 20000,
        requestTimeout: 60000
    };

    if (portVal && portVal !== '') {
        sqlConfig.port = parseInt(portVal, 10);
        delete sqlConfig.options.instanceName;
        console.log(`[SQL_DEBUG] Conectando por PUERTO: ${host}:${sqlConfig.port}`);
    } else if (instanceName) {
        sqlConfig.options.instanceName = instanceName;
        console.log(`[SQL_DEBUG] Conectando por INSTANCIA: ${host}\\${instanceName} (Vía SQL Browser)`);
    } else {
        sqlConfig.port = 1433;
        console.log(`[SQL_DEBUG] Conectando por DEFECTO (1433): ${host}`);
    }

    try {
        const pool = await mssql.connect(sqlConfig);
        console.log('[SQL_CONN] ¡ÉXITO al conectar con SQL Server!');
        return pool;
    } catch (error: any) {
        console.warn(`[SQL_CONN] Falló primer intento de conexión en '${host}': ${error.message}`);
        
        // Si falló por nombre de host (DNS) o timeout local y el host no era 127.0.0.1, intentar fallback local a 127.0.0.1
        if (host !== '127.0.0.1' && host !== 'localhost') {
            console.log(`[SQL_CONN] Intentando conexión de respaldo en 127.0.0.1 con puerto ${sqlConfig.port || 1433}...`);
            try {
                const fallbackConfig = { ...sqlConfig, server: '127.0.0.1' };
                const poolFallback = await mssql.connect(fallbackConfig);
                console.log('[SQL_CONN] ¡ÉXITO al conectar con SQL Server mediante fallback 127.0.0.1!');
                return poolFallback;
            } catch (fallbackErr: any) {
                console.error('[SQL_CONN] Falló también el intento de respaldo en 127.0.0.1:', fallbackErr.message);
            }
        }

        const richMsg = `[Servidor: ${host} | Puerto: ${sqlConfig.port || 'Instancia (' + (instanceName || 'browser') + ')'} | BD: ${dbVal} | Usuario: ${userVal}] - Error: ${error.message}${error.code ? ' [Código: ' + error.code + ']' : ''}`;
        const enrichedError = new Error(richMsg);
        (enrichedError as any).code = error.code || 'SQL_CONN_ERROR';
        (enrichedError as any).originalError = error;
        (enrichedError as any).connectionConfig = { host, port: sqlConfig.port, db: dbVal, user: userVal };
        throw enrichedError;
    }
}

/**
 * Ejecuta un Stored Procedure en SQL Server.
 */
export async function executeSQLServerProcedure(spName: string, params: any) {
    let pool;
    try {
        console.log(`[SQL_SERVER_EXEC] Procedimiento: ${spName} | Parámetros:`, JSON.stringify(params));
        pool = await getSQLServerConnection();
        const request = pool.request();

        if (params) {
            Object.keys(params).forEach(key => {
                request.input(key, mssql.VarChar(mssql.MAX), params[key]);
            });
        }

        const result = await request.execute(spName);
        await pool.close();
        return result.recordset || result.rowsAffected;
    } catch (err: any) {
        if (pool) await pool.close();
        throw err;
    }
}
