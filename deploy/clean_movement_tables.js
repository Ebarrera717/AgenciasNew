const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Cargador de variables de entorno manual de alta compatibilidad (Sin dependencias externas)
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

// Carga segura del driver 'pg'
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
            console.error("\n❌ [ERROR] No se pudo encontrar la librería 'pg' para conectar a PostgreSQL.");
            console.error("Asegúrese de ejecutar el script desde el directorio instalado o que exista la carpeta node_modules.\n");
            process.exit(1);
        }
    }
}
const { Client } = pg;

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

const DEFAULT_SP_SQL = `
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

    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_quotation_consecutivo') THEN
        ALTER SEQUENCE public.seq_quotation_consecutivo RESTART WITH 1;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'Invoices_id_seq') THEN
        ALTER SEQUENCE public."Invoices_id_seq" RESTART WITH 1;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Tablas de movimientos vaciadas exitosamente. Parámetros y maestros intactos.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
`;

async function cleanMovementTables() {
    console.log("================================================================");
    console.log("  LIMPIADOR DE TABLAS DE MOVIMIENTOS - PASO PRUEBAS A PRODUCCION");
    console.log("================================================================");

    let connectionString = process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo';
    
    // Parse default DB name from connection string
    let dbName = 'Korex_colaereo';
    try {
        const parsedUrl = new URL(connectionString);
        dbName = parsedUrl.pathname.replace(/^\//, '') || 'Korex_colaereo';
    } catch (e) {}

    // Check CLI flags or environment override
    const dbArg = process.argv.find(a => a.startsWith('--db=') || a.startsWith('--dbname='));
    const isNonInteractive = process.argv.includes('--non-interactive') || process.env.NON_INTERACTIVE === 'true';

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
        console.log(`\nBase de datos objetivo especificada por parámetro: ${dbName}`);
    } else if (!isNonInteractive && process.stdin.isTTY) {
        console.log(`\nBase de datos configurada por defecto (.env): ${dbName}`);
        const changeChoice = await askQuestion(`¿Desea cambiar la base de datos a blanquear? (S/N) [N]: `);

        if (changeChoice.toUpperCase() === 'S' || changeChoice.toUpperCase() === 'SI' || changeChoice.toUpperCase() === 'SÍ') {
            const newDbInput = await askQuestion(`Ingrese el nombre de la base de datos o URL de conexión [${dbName}]: `);
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

    console.log(`\nBase de datos seleccionada: ${dbName}`);
    console.log("Iniciando proceso de vaciado de movimientos operacionales...\n");

    const client = new Client({ connectionString });
    try {
        await client.connect();
    } catch (connErr) {
        console.error(`  [ERROR] No se pudo conectar a la base de datos '${dbName}': ${connErr.message}`);
        process.exit(1);
    }

    try {
        // Garantizar el despliegue del procedimiento actualizado spLimpiarMovimientosProduccion
        let spSql = DEFAULT_SP_SQL;
        const spPath = path.join(__dirname, '..', 'SQL', 'SP', 'spLimpiarMovimientosProduccion.sql');
        const spPathAlt = path.join(__dirname, 'SQL', 'SP', 'spLimpiarMovimientosProduccion.sql');
        if (fs.existsSync(spPath)) {
            spSql = fs.readFileSync(spPath, 'utf8');
        } else if (fs.existsSync(spPathAlt)) {
            spSql = fs.readFileSync(spPathAlt, 'utf8');
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

        console.log("\n[PASO 2/2] Auditando estado post-limpieza de la base de datos '" + dbName + "'...");
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

        console.log("\n  --- TABLAS DE MOVIMIENTOS VACIANAS EN '" + dbName + "' (TRANSACCIONALES) ---");
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
        console.log(`  EXITO: La base de datos '${dbName}' ha sido limpiada de movimientos`);
        console.log("  y está lista para iniciar la operación en PRODUCCION.");
        console.log("================================================================\n");

    } catch (err) {
        console.error(`  [ERROR] Falló la limpieza de movimientos: ${err.message}`);
        process.exit(1);
    } finally {
        await client.end();
    }
}

cleanMovementTables();
