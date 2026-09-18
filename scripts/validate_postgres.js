const path = require('path');
const dotenv = require('dotenv');

const rootDir = path.join(__dirname, '..');
dotenv.config({ path: path.join(rootDir, '.env') });

const { Client: PgClient } = require(path.join(rootDir, 'node_modules', 'pg'));

const PG_TABLES_TO_VALIDATE = [
    { label: 'Roles (Role)', table: 'Role' },
    { label: 'Usuarios (User)', table: 'User' },
    { label: 'Sucursales (Branch)', table: 'Branch' },
    { label: 'Implants (Implant)', table: 'Implant' },
    { label: 'Tiqueteadores (TicketPrinter)', table: 'TicketPrinter' },
    { label: 'Clientes (Client)', table: 'Client' },
    { label: 'Proveedores (Provider)', table: 'Provider' },
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
    { label: 'Facturas (invoices)', table: 'Invoices' }
];

async function validatePostgresOnly() {
    console.log('================================================================');
    console.log('   VALIDADOR EXCLUSIVO DE POSTGRESQL - AGENCIASNEW              ');
    console.log('================================================================\n');

    const pgConn = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
    const client = new PgClient({ connectionString: pgConn });

    const results = [];

    try {
        console.log('[POSTGRESQL] Conectando a PostgreSQL local...');
        await client.connect();
        console.log(' -> [OK] Conectado exitosamente a PostgreSQL.\n');

        for (const item of PG_TABLES_TO_VALIDATE) {
            let ok = false;
            let count = 0;

            try {
                const r = await client.query(`SELECT COUNT(*) AS c FROM public."${item.table}"`);
                ok = true;
                count = r.rows[0].c;
            } catch (e1) {
                ok = false;
            }

            results.push({
                Componente: item.label,
                Tabla: `public."${item.table}"`,
                Estado: ok ? `✅ PASS (${count} reg)` : '❌ FAIL',
                Resultado: ok ? 'PASS' : 'FAIL'
            });
        }

        // Functions
        let fnCotizOk = false;
        try {
            await client.query(`SELECT * FROM public.fnCotizacionListar(NULL, NULL, NULL, NULL, NULL, NULL, NULL) LIMIT 1`);
            fnCotizOk = true;
        } catch (e) {
            fnCotizOk = false;
        }

        results.push({
            Componente: 'Función: fnCotizacionListar',
            Tabla: 'public.fncotizacionlistar',
            Estado: fnCotizOk ? '✅ PASS (PG PL/pgSQL)' : '❌ FAIL',
            Resultado: fnCotizOk ? 'PASS' : 'FAIL'
        });

        let fnMenuOk = false;
        try {
            await client.query(`SELECT * FROM public.fnMenu() LIMIT 1`);
            fnMenuOk = true;
        } catch (e) {
            fnMenuOk = false;
        }

        results.push({
            Componente: 'Función: fnMenu',
            Tabla: 'public.fnmenu',
            Estado: fnMenuOk ? '✅ PASS (PG PL/pgSQL)' : '❌ FAIL',
            Resultado: fnMenuOk ? 'PASS' : 'FAIL'
        });

        await client.end();
    } catch (err) {
        console.error('❌ Error de conexión a PostgreSQL:', err.message);
        results.push({
            Componente: 'Conexión PostgreSQL',
            Tabla: 'N/A',
            Estado: '❌ FAIL',
            Resultado: 'FAIL'
        });
    }

    console.log('\n================================================================');
    console.log('       MATRIZ DE RESULTADOS AUDITORÍA POSTGRESQL                ');
    console.log('================================================================');
    console.table(results);

    const isAllPass = results.length > 0 && results.every(r => r.Resultado === 'PASS');

    console.log('================================================================');
    if (isAllPass) {
        console.log('  RESULTADO FINAL POSTGRESQL: 100% PASS - APTO PARA EMPAQUETAR  ');
    } else {
        console.log('  RESULTADO FINAL POSTGRESQL: FAIL - SE DETECTARON ERRORES      ');
    }
    console.log('================================================================\n');

    process.exit(isAllPass ? 0 : 1);
}

validatePostgresOnly();
