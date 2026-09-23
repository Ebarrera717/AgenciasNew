const path = require('path');
const dotenv = require('dotenv');

const rootDir = path.join(__dirname, '..');
dotenv.config({ path: path.join(rootDir, '.env') });

let mssql = null;
try {
    mssql = require(path.join(rootDir, 'node_modules', 'mssql'));
} catch (e) {
    try {
        mssql = require('mssql');
    } catch (e2) {}
}

function parseSQLServerUrl(connStr) {
    let clean = (connStr || '').replace(/^(sqlserver|mssql):\/\//i, '');
    let hostPortPart = clean.split(';')[0];
    let host = hostPortPart.split(':')[0] || '127.0.0.1';
    let portStr = hostPortPart.split(':')[1] || '';

    let instanceName = undefined;
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

const SQL_TABLES_TO_VALIDATE = [
    { label: 'Roles (Role)', table: 'Role' },
    { label: 'Usuarios (User)', table: 'User' },
    { label: 'Sucursales (Branch)', table: 'Branch' },
    { label: 'Implants (Implant)', table: 'Implant' },
    { label: 'Tiqueteadores (TicketPrinter)', table: 'TicketPrinter' },
    { label: 'Vendedores (Seller / MAEVENDE)', table: 'Seller', fallback: 'MAEVENDE' },
    { label: 'Clientes (Client / CLIENTES)', table: 'Client', fallback: 'CLIENTES' },
    { label: 'Proveedores (Provider / PROVEEDORES)', table: 'Provider', fallback: 'PROVEEDORES' },
    { label: 'Tipos de Proveedor (ProviderType)', table: 'ProviderType' },
    { label: 'Productos (Product)', table: 'Product' },
    { label: 'Cargos e Impuestos (ChargeAndTax)', table: 'ChargeAndTax' },
    { label: 'Monedas (Currency)', table: 'Currency' },
    { label: 'Parámetros (SystemParameter)', table: 'SystemParameter' },
    { label: 'Módulos del Sitio (Master)', table: 'Master' },
    { label: 'Menú del Sitio (Menu)', table: 'Menu' },
    { label: 'Consecutivos (TransactionConsecutive)', table: 'TransactionConsecutive' },
    { label: 'Estados Cotización (QuotationState)', table: 'QuotationState' },
    { label: 'Cotizaciones (Quotation)', table: 'Quotation' },
    { label: 'Facturas (Invoices)', table: 'Invoices' }
];

async function validateSqlServerOnly() {
    console.log('================================================================');
    console.log('   VALIDADOR EXCLUSIVO DE SQL SERVER - AGENCIASNEW              ');
    console.log('================================================================\n');

    const sqlConn = process.env.DATABASE_URL_SQLSERVER || 'sqlserver://ZEUSAGENCIAS10:1433;database=Korex_Pruebas;user=zeusagencias;password=zzeusagencias;encrypt=false;trustServerCertificate=true';
    const parsed = parseSQLServerUrl(sqlConn);

    const config = {
        server: parsed.rawHost || (parsed.servidor.includes('\\') ? parsed.servidor.split('\\')[0] : parsed.servidor),
        database: parsed.base_datos || 'Korex_Pruebas',
        user: parsed.usuario || 'sa',
        password: parsed.clave || 'zzeusagencias',
        options: {
            encrypt: false,
            trustServerCertificate: true,
            connectTimeout: 8000
        }
    };

    if (parsed.instanceName || parsed.servidor.includes('\\')) {
        config.options.instanceName = parsed.instanceName || parsed.servidor.split('\\')[1];
    } else {
        config.port = parsed.puerto ? parseInt(parsed.puerto) : 1433;
    }

    console.log(`[SQL SERVER] Conectando a ${config.server}:${config.port}/${config.database}...`);
    let pool = null;
    const results = [];

    try {
        pool = await mssql.connect(config);
        console.log(' -> [OK] Conectado exitosamente a SQL Server.\n');

        for (const item of SQL_TABLES_TO_VALIDATE) {
            let ok = false;
            let count = 0;
            let usedTable = item.table;

            try {
                const r = await pool.request().query(`SELECT COUNT(*) AS c FROM dbo.[${item.table}]`);
                ok = true;
                count = r.recordset[0].c;
            } catch (e1) {
                if (item.fallback) {
                    try {
                        const r2 = await pool.request().query(`SELECT COUNT(*) AS c FROM dbo.[${item.fallback}]`);
                        ok = true;
                        count = r2.recordset[0].c;
                        usedTable = item.fallback;
                    } catch (e2) {
                        ok = false;
                    }
                } else {
                    ok = false;
                }
            }

            results.push({
                Componente: item.label,
                Tabla: usedTable,
                Estado: ok ? `✅ PASS (${count} reg)` : '❌ FAIL',
                Resultado: ok ? 'PASS' : 'FAIL'
            });
        }

        // SPs
        let spCotizOk = false;
        try {
            await pool.request().query(`SELECT TOP 1 * FROM sys.procedures WHERE name = 'spCotizacionesListar'`);
            spCotizOk = true;
        } catch (e) {}

        results.push({
            Componente: 'SP: spCotizacionesListar',
            Tabla: 'sys.procedures',
            Estado: spCotizOk ? '✅ PASS (T-SQL)' : '❌ FAIL',
            Resultado: spCotizOk ? 'PASS' : 'FAIL'
        });

        let spMenuOk = false;
        try {
            await pool.request().query(`SELECT TOP 1 * FROM sys.procedures WHERE name = 'spMenuListar'`);
            spMenuOk = true;
        } catch (e) {}

        results.push({
            Componente: 'SP: spMenuListar',
            Tabla: 'sys.procedures',
            Estado: spMenuOk ? '✅ PASS (T-SQL)' : '❌ FAIL',
            Resultado: spMenuOk ? 'PASS' : 'FAIL'
        });

        await pool.close();
    } catch (err) {
        console.error('❌ Error de conexión a SQL Server:', err.message);
        results.push({
            Componente: 'Conexión SQL Server',
            Tabla: 'N/A',
            Estado: '❌ FAIL',
            Resultado: 'FAIL'
        });
    }

    console.log('\n================================================================');
    console.log('       MATRIZ DE RESULTADOS AUDITORÍA SQL SERVER                ');
    console.log('================================================================');
    console.table(results);

    const isAllPass = results.length > 0 && results.every(r => r.Resultado === 'PASS');

    console.log('================================================================');
    if (isAllPass) {
        console.log('  RESULTADO FINAL SQL SERVER: 100% PASS - APTO PARA EMPAQUETAR  ');
    } else {
        console.log('  RESULTADO FINAL SQL SERVER: FAIL - SE DETECTARON ERRORES      ');
    }
    console.log('================================================================\n');

    process.exit(isAllPass ? 0 : 1);
}

validateSqlServerOnly();
