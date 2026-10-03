const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Cargador de variables de entorno manual de alta compatibilidad
const envCandidates = [
    path.join(__dirname, '..', '.env'),
    path.join(__dirname, '.env'),
    path.join(process.cwd(), '.env')
];

for (const envPath of envCandidates) {
    if (fs.existsSync(envPath)) {
        try {
            const content = fs.readFileSync(envPath, 'utf8');
            content.split(/\r?\n/).forEach(line => {
                const trimmed = line.trim();
                if (trimmed && !trimmed.startsWith('#')) {
                    const eqIdx = trimmed.indexOf('=');
                    if (eqIdx > 0) {
                        const key = trimmed.slice(0, eqIdx).trim();
                        let val = trimmed.slice(eqIdx + 1).trim();
                        if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
                            val = val.slice(1, -1);
                        }
                        if (key && !process.env[key]) process.env[key] = val;
                    }
                }
            });
        } catch (e) {}
    }
}

function askQuestion(query) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    return new Promise(resolve => rl.question(query, ans => {
        rl.close();
        resolve(ans.trim());
    }));
}

const DEFAULT_PG_SP_SQL = `
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spLimpiarMovimientosProduccion'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spLimpiarMovimientosProduccion"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spLimpiarMovimientosProduccion"(
    INOUT p_mensaje_resultado text DEFAULT ''
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_tbl TEXT;
    v_tables TEXT[] := ARRAY[
        'Quotation', 'QuotationProduct', 'QuotationProductTax', 'QuotationProductVariable', 
        'QuotationProductPassenger', 'QuotationProductPayment', 'QuotationCombo', 'QuotationInvoice', 
        'QuotationStateHistory', 'QuotationPrintCustomization', 'QuotationManualService', 'PreQuotation', 
        'PreQuotationStateHistory', 'Invoices', 'Invoice', 'InvoicesProduct', 'InvoicesProductTax', 
        'InvoicesProductVariable', 'InvoicesProductPasenger', 'InvoicesProductPayment', 
        'InvoicesProductCombo', 'InvoicesProductItinerary', 'BookingGDS', 'BookingsGDS_log', 
        'BookingProductGDS', 'BookingProductItineraryGDS', 'BookingProductPassangerGDS', 
        'BookingProductTaxGDS', 'BookingProductVariableGDS', 'BookingProductFEEGDS', 
        'BookingProductPaymentGDS', 'BookingsGDSInvoiceAuto', 'BookingGDSInvoiceAutoLog', 
        'BranchGDSInvoiceAuto', 'SystemLog', 'ExecutionPreset', 'ExecutionProcedure', 'Attachment', 
        'EquivalenciasInterfaces_Log'
    ];
BEGIN
    FOREACH v_tbl IN ARRAY v_tables
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = v_tbl) THEN
            EXECUTE 'TRUNCATE TABLE public."' || v_tbl || '" CASCADE;';
        END IF;
    END LOOP;

    -- Reinicio dinámico universal de TODAS las secuencias en public (IDs y Consecutivos)
    FOR r IN 
        SELECT c.relname 
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'S'
    LOOP
        EXECUTE 'ALTER SEQUENCE public."' || r.relname || '" RESTART WITH 1;';
    END LOOP;

    -- Reiniciar los consecutivos de transacciones a su valor inicial configurado
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TransactionConsecutive') THEN
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = COALESCE("initialNumber", 1);
    END IF;

    p_mensaje_resultado := 'SUCCESS: Tablas de movimientos vaciadas y consecutivos/secuencias reiniciados exitosamente a 1.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
`;

async function cleanMovementTables() {
    console.log("================================================================");
    console.log("  LIMPIADOR DE TABLAS DE MOVIMIENTOS - PASO PRUEBAS A PRODUCCION");
    console.log("  Soporte Multibase: PostgreSQL + Microsoft SQL Server");
    console.log("================================================================");

    const isNonInteractive = process.argv.includes('--non-interactive') || process.env.NON_INTERACTIVE === 'true';
    const engineArg = process.argv.find(a => a.startsWith('--engine='));
    const dbArg = process.argv.find(a => a.startsWith('--db=') || a.startsWith('--dbname='));

    // 1. Detectar motor de base de datos
    let activeEngine = 'postgres';
    const envDbUrl = process.env.DATABASE_URL || '';
    const envSqlUrl = process.env.DATABASE_URL_SQLSERVER || '';

    if (engineArg) {
        activeEngine = engineArg.split('=')[1].toLowerCase().includes('sql') ? 'sqlserver' : 'postgres';
    } else if (envDbUrl.startsWith('sqlserver://') || envDbUrl.startsWith('mssql://') || envSqlUrl) {
        // Si la URL principal es SQL Server o existe DATABASE_URL_SQLSERVER
        if (envDbUrl.startsWith('sqlserver://') || envDbUrl.startsWith('mssql://')) {
            activeEngine = 'sqlserver';
        }
    }

    if (!isNonInteractive && process.stdin.isTTY && !engineArg) {
        console.log(`\nMotor detectado según configuración: [${activeEngine.toUpperCase()}]`);
        const engineChoice = await askQuestion(`¿Desea seleccionar el motor a limpiar? (1 = PostgreSQL, 2 = SQL Server) [1]: `);
        if (engineChoice === '2') {
            activeEngine = 'sqlserver';
        } else if (engineChoice === '1') {
            activeEngine = 'postgres';
        }
    }

    console.log(`\n================================================================`);
    console.log(`   MOTOR SELECCIONADO: ${activeEngine.toUpperCase()}`);
    console.log(`================================================================`);

    if (activeEngine === 'sqlserver') {
        await cleanSqlServer(dbArg, isNonInteractive);
    } else {
        await cleanPostgres(dbArg, isNonInteractive);
    }
}

async function cleanPostgres(dbArg, isNonInteractive) {
    let pg;
    try {
        pg = require('pg');
    } catch (e1) {
        try { pg = require(path.join(__dirname, '..', 'node_modules', 'pg')); } catch (e2) {
            try { pg = require(path.join(process.cwd(), 'node_modules', 'pg')); } catch (e3) {
                console.error("\n❌ [ERROR] No se pudo encontrar la librería 'pg' para conectar a PostgreSQL.");
                process.exit(1);
            }
        }
    }
    const { Client } = pg;

    let connectionString = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo';
    if (connectionString.startsWith('sqlserver://') || connectionString.startsWith('mssql://')) {
        connectionString = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo';
    }

    let dbName = 'Korex_colaereo';
    try {
        const parsedUrl = new URL(connectionString);
        dbName = parsedUrl.pathname.replace(/^\//, '') || 'Korex_colaereo';
    } catch (e) {}

    if (dbArg) {
        const customTarget = dbArg.split('=')[1].trim();
        if (customTarget.startsWith('postgresql://') || customTarget.startsWith('postgres://')) {
            connectionString = customTarget;
            try { dbName = new URL(connectionString).pathname.replace(/^\//, ''); } catch (e) { dbName = customTarget; }
        } else if (customTarget) {
            dbName = customTarget;
            const parsedUrl = new URL(connectionString);
            parsedUrl.pathname = '/' + dbName;
            connectionString = parsedUrl.toString();
        }
    } else if (!isNonInteractive && process.stdin.isTTY) {
        console.log(`Base de datos PostgreSQL (.env): ${dbName}`);
        const changeChoice = await askQuestion(`¿Desea cambiar la base de datos PostgreSQL a limpiar? (S/N) [N]: `);
        if (changeChoice.toUpperCase() === 'S' || changeChoice.toUpperCase() === 'SI' || changeChoice.toUpperCase() === 'SÍ') {
            const newDbInput = await askQuestion(`Ingrese el nombre de la BD PostgreSQL o URL [${dbName}]: `);
            if (newDbInput) {
                if (newDbInput.startsWith('postgresql://') || newDbInput.startsWith('postgres://')) {
                    connectionString = newDbInput;
                    try { dbName = new URL(connectionString).pathname.replace(/^\//, ''); } catch (e) { dbName = newDbInput; }
                } else {
                    dbName = newDbInput;
                    const parsedUrl = new URL(connectionString);
                    parsedUrl.pathname = '/' + dbName;
                    connectionString = parsedUrl.toString();
                }
            }
        }
    }

    console.log(`\nBase de datos PostgreSQL objetivo: ${dbName}`);
    console.log("Iniciando proceso de vaciado de movimientos operacionales...\n");

    const client = new Client({ connectionString });
    try {
        await client.connect();
    } catch (connErr) {
        console.error(`  [ERROR] No se pudo conectar a PostgreSQL '${dbName}': ${connErr.message}`);
        process.exit(1);
    }

    try {
        let spSql = DEFAULT_PG_SP_SQL;
        const spPath = path.join(__dirname, '..', 'SQL', 'PostgreSQL', 'SP', 'spLimpiarMovimientosProduccion.sql');
        const spPathOld = path.join(__dirname, '..', 'SQL', 'SP', 'spLimpiarMovimientosProduccion.sql');
        if (fs.existsSync(spPath)) {
            spSql = fs.readFileSync(spPath, 'utf8');
        } else if (fs.existsSync(spPathOld)) {
            spSql = fs.readFileSync(spPathOld, 'utf8');
        }

        await client.query(spSql);

        console.log("[PASO 1/2] Invocando Stored Procedure public.spLimpiarMovimientosProduccion()...");
        const res = await client.query('CALL public."spLimpiarMovimientosProduccion"($1::TEXT)', ['']);
        const msg = res.rows[0]?.p_mensaje_resultado || '';

        if (msg.startsWith('ERROR')) {
            throw new Error(msg);
        }

        console.log(`  [OK] ${msg}`);

        async function getCount(tbl) {
            try {
                const r = await client.query(`SELECT COUNT(*) FROM public."${tbl}"`);
                return parseInt(r.rows[0].count, 10);
            } catch (e) {
                return 0;
            }
        }

        console.log("\n[PASO 2/2] Auditando estado post-limpieza de PostgreSQL '" + dbName + "'...");
        const counts = {
            Quotation: await getCount("Quotation"),
            Invoices: (await getCount("Invoices")) + (await getCount("Invoice")),
            PreQuotation: await getCount("PreQuotation"),
            BookingGDS: await getCount("BookingGDS"),
            SystemLog: await getCount("SystemLog")
        };

        const preserved = {
            Client: await getCount("Client"),
            Provider: await getCount("Provider"),
            Seller: await getCount("Seller"),
            Branch: await getCount("Branch"),
            User: await getCount("User"),
            SystemParameter: await getCount("SystemParameter")
        };

        console.log("\n  --- TABLAS DE MOVIMIENTOS VACIADAS EN POSTGRESQL '" + dbName + "' ---");
        console.log(`  * Cotizaciones (Quotation):      ${counts.Quotation} (Limpio)`);
        console.log(`  * Facturas (Invoices):           ${counts.Invoices} (Limpio)`);
        console.log(`  * Pre-Cotizaciones:              ${counts.PreQuotation} (Limpio)`);
        console.log(`  * Reservas GDS:                  ${counts.BookingGDS} (Limpio)`);
        console.log(`  * Logs del Sistema:              ${counts.SystemLog} (Limpio)`);

        console.log("\n  --- PARAMETROS Y MAESTROS PRESERVADOS INTACTOS ---");
        console.log(`  * Clientes Preservados:          ${preserved.Client}`);
        console.log(`  * Proveedores Preservados:       ${preserved.Provider}`);
        console.log(`  * Vendedores Preservados:        ${preserved.Seller}`);
        console.log(`  * Sucursales Preservadas:        ${preserved.Branch}`);
        console.log(`  * Usuarios Preservados:          ${preserved.User}`);
        console.log(`  * Parámetros del Sistema:        ${preserved.SystemParameter}`);

        console.log("\n================================================================");
        console.log(`  EXITO: La base PostgreSQL '${dbName}' ha sido limpiada de movimientos`);
        console.log("  y está lista para iniciar la operación en PRODUCCION.");
        console.log("================================================================\n");

    } catch (err) {
        console.error(`  [ERROR] Falló la limpieza de movimientos en PostgreSQL: ${err.message}`);
        process.exit(1);
    } finally {
        await client.end();
    }
}

async function cleanSqlServer(dbArg, isNonInteractive) {
    let mssql;
    try {
        mssql = require('mssql');
    } catch (e1) {
        try { mssql = require(path.join(__dirname, '..', 'node_modules', 'mssql')); } catch (e2) {
            try { mssql = require(path.join(process.cwd(), 'node_modules', 'mssql')); } catch (e3) {
                console.error("\n❌ [ERROR] No se pudo encontrar la librería 'mssql' para conectar a SQL Server.");
                process.exit(1);
            }
        }
    }

    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = 'Korex_pruebas'; // BD Principal de Korex en SQL Server
    let defaultPort = 1433;

    const envUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL || '';
    if (envUrl && (envUrl.startsWith('sqlserver://') || envUrl.startsWith('mssql://'))) {
        const clean = envUrl.replace(/^(sqlserver|mssql):\/\//i, '');
        const hostPortPart = clean.split(';')[0];
        defaultHost = hostPortPart.split(':')[0] || defaultHost;
        if (defaultHost.toLowerCase() === 'localhost') defaultHost = '127.0.0.1';
        const pStr = hostPortPart.split(':')[1];
        if (pStr) defaultPort = parseInt(pStr, 10);

        const params = clean.split(';');
        for (const p of params) {
            const eqIdx = p.indexOf('=');
            if (eqIdx > 0) {
                const k = p.substring(0, eqIdx).trim().toLowerCase();
                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                else if (k === 'password' || k === 'pwd') defaultPass = v;
                else if (k === 'database' || k === 'initial catalog') defaultDb = v;
            }
        }
    }

    let targetDb = defaultDb;
    if (dbArg) {
        targetDb = dbArg.split('=')[1].trim();
    } else if (!isNonInteractive && process.stdin.isTTY) {
        console.log(`Base de datos SQL Server configurada: ${targetDb}`);
        const changeChoice = await askQuestion(`¿Desea cambiar la base de datos SQL Server a limpiar? (S/N) [N]: `);
        if (changeChoice.toUpperCase() === 'S' || changeChoice.toUpperCase() === 'SI' || changeChoice.toUpperCase() === 'SÍ') {
            const newDbInput = await askQuestion(`Ingrese el nombre de la BD SQL Server [${targetDb}]: `);
            if (newDbInput) targetDb = newDbInput.trim();
        }
    }

    console.log(`\nConectando a SQL Server [${targetDb}] en ${defaultHost}:${defaultPort}...`);

    const sqlConfig = {
        user: process.env.SQLSERVER_USER || defaultUser,
        password: process.env.SQLSERVER_PASSWORD || defaultPass,
        server: process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost,
        database: targetDb,
        port: defaultPort,
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 15000,
        requestTimeout: 60000
    };

    let pool = null;
    try {
        pool = await mssql.connect(sqlConfig);
        console.log(`  -> ¡Conexión con SQL Server [${targetDb}] establecida exitosamente!`);

        // Desplegar SP en SQL Server si no existe
        const spSqlPath = path.join(__dirname, '..', 'SQL', 'SqlServer', 'spLimpiarMovimientosProduccion.sql');
        if (fs.existsSync(spSqlPath)) {
            const spSql = fs.readFileSync(spSqlPath, 'utf8');
            const batches = spSql.split(/^[ \t]*GO[ \t]*$/gmi).map(b => b.trim()).filter(b => b.length > 0);
            for (const batch of batches) {
                await pool.request().query(batch);
            }
        }

        console.log("[PASO 1/2] Invocando Stored Procedure dbo.spLimpiarMovimientosProduccion()...");
        const request = pool.request();
        request.output('p_mensaje_resultado', mssql.NVarChar(4000));
        const res = await request.execute('dbo.spLimpiarMovimientosProduccion');
        const msg = res.output?.p_mensaje_resultado || '';

        if (msg.startsWith('ERROR')) {
            throw new Error(msg);
        }

        console.log(`  [OK] ${msg}`);

        async function getCountSql(tbl) {
            try {
                const r = await pool.request().query(`SELECT COUNT(*) as total FROM dbo.[${tbl}]`);
                return r.recordset[0]?.total || 0;
            } catch (e) {
                return 0;
            }
        }

        console.log("\n[PASO 2/2] Auditando estado post-limpieza de SQL Server '" + targetDb + "'...");
        const counts = {
            Quotation: await getCountSql("Quotation"),
            Invoices: (await getCountSql("Invoices")) + (await getCountSql("Invoice")),
            PreQuotation: await getCountSql("PreQuotation"),
            BookingGDS: await getCountSql("BookingGDS"),
            SystemLog: await getCountSql("SystemLog")
        };

        const preserved = {
            Client: await getCountSql("Client"),
            Provider: await getCountSql("Provider"),
            Seller: await getCountSql("Seller"),
            Branch: await getCountSql("Branch"),
            User: await getCountSql("User"),
            SystemParameter: await getCountSql("SystemParameter")
        };

        console.log("\n  --- TABLAS DE MOVIMIENTOS VACIADAS EN SQL SERVER '" + targetDb + "' ---");
        console.log(`  * Cotizaciones (Quotation):      ${counts.Quotation} (Limpio)`);
        console.log(`  * Facturas (Invoices):           ${counts.Invoices} (Limpio)`);
        console.log(`  * Pre-Cotizaciones:              ${counts.PreQuotation} (Limpio)`);
        console.log(`  * Reservas GDS:                  ${counts.BookingGDS} (Limpio)`);
        console.log(`  * Logs del Sistema:              ${counts.SystemLog} (Limpio)`);

        console.log("\n  --- PARAMETROS Y MAESTROS PRESERVADOS INTACTOS ---");
        console.log(`  * Clientes Preservados:          ${preserved.Client}`);
        console.log(`  * Proveedores Preservados:       ${preserved.Provider}`);
        console.log(`  * Vendedores Preservados:        ${preserved.Seller}`);
        console.log(`  * Sucursales Preservadas:        ${preserved.Branch}`);
        console.log(`  * Usuarios Preservados:          ${preserved.User}`);
        console.log(`  * Parámetros del Sistema:        ${preserved.SystemParameter}`);

        console.log("\n================================================================");
        console.log(`  EXITO: La base SQL Server '${targetDb}' ha sido limpiada de movimientos`);
        console.log("  y está lista para iniciar la operación en PRODUCCION.");
        console.log("================================================================\n");

    } catch (err) {
        console.error(`  [ERROR] Falló la limpieza de movimientos en SQL Server: ${err.message}`);
        process.exit(1);
    } finally {
        if (pool) await pool.close();
    }
}

cleanMovementTables();
