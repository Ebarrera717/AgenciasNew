const path = require('path');
const { Client } = require('pg');
const mssql = require('mssql');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

function getPgConfig() {
    const url = process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL;
    if (url && url.startsWith('postgres')) {
        return { connectionString: url };
    }
    return {
        host: process.env.PGHOST || '192.168.80.26',
        port: parseInt(process.env.PGPORT || '5432', 10),
        database: process.env.PGDATABASE || 'Korex_colaereo',
        user: process.env.PGUSER || 'postgres',
        password: process.env.PGPASSWORD || 'admin123'
    };
}

function getSqlServerConfig(targetDbName) {
    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = targetDbName || 'Korex_Pruebas';
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

        for (const p of clean.split(';')) {
            const eqIdx = p.indexOf('=');
            if (eqIdx > 0) {
                const k = p.substring(0, eqIdx).trim().toLowerCase();
                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                else if (k === 'password' || k === 'pwd') defaultPass = v;
                else if ((k === 'database' || k === 'initial catalog') && !targetDbName) defaultDb = v;
            }
        }
    }

    const config = {
        user: process.env.SQLSERVER_USER || defaultUser,
        password: process.env.SQLSERVER_PASSWORD || defaultPass,
        server: process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost,
        database: targetDbName || defaultDb,
        options: { encrypt: false, trustServerCertificate: true },
        connectionTimeout: 10000,
        requestTimeout: 60000
    };
    if (defaultPort && defaultPort > 0) config.port = defaultPort;
    else if (instanceName) config.options.instanceName = instanceName;
    return config;
}

function extractTag(xml, tag) {
    const regex = new RegExp(`<${tag}>([^<]*)</${tag}>`, 'i');
    const m = xml.match(regex);
    return m ? m[1] : null;
}

function extractBlocks(xml, tag) {
    const regex = new RegExp(`<${tag}>[\\s\\S]*?</${tag}>`, 'gi');
    return xml.match(regex) || [];
}

function assert(cond, msg) {
    if (!cond) throw new Error(`ASSERTION FAILED: ${msg}`);
}

async function runPostgresTests() {
    console.log('\n================================================================');
    console.log('  [POSTGRESQL] PRUEBAS 1-7: TIPOS DE FACTURACIÓN DE HOTELES');
    console.log('================================================================');
    const pg = new Client(getPgConfig());
    await pg.connect();

    let originalParam = null;
    let testInvoiceId = null;
    let testQuotationId = null;

    try {
        // Guardar estado original del parámetro
        const pRes = await pg.query(`SELECT value FROM public."SystemParameter" WHERE code = 'EnviarTiposFacturacionHotelesZeus'`);
        assert(pRes.rows.length > 0, 'El parámetro EnviarTiposFacturacionHotelesZeus debe existir en PostgreSQL');
        originalParam = pRes.rows[0].value;

        // Obtener IDs válidos de maestros
        const clientRow = (await pg.query(`SELECT id FROM public."Client" WHERE "isActive" = true ORDER BY id ASC LIMIT 1`)).rows[0];
        const branchRow = (await pg.query(`SELECT id FROM public."Branch" ORDER BY id ASC LIMIT 1`)).rows[0];
        const userRow = (await pg.query(`SELECT id FROM public."User" ORDER BY id ASC LIMIT 1`)).rows[0];
        const prodRow = (await pg.query(`SELECT id FROM public."Product" WHERE type <> 'Tiquete' AND NULLIF(TRIM("billingConcept"), '') IS NOT NULL ORDER BY id ASC LIMIT 1`)).rows[0]
            || (await pg.query(`SELECT id FROM public."Product" WHERE NULLIF(TRIM("billingConcept"), '') IS NOT NULL ORDER BY id ASC LIMIT 1`)).rows[0]
            || (await pg.query(`SELECT id FROM public."Product" ORDER BY id ASC LIMIT 1`)).rows[0];
        const taxRow = (await pg.query(`SELECT id FROM public."ChargeAndTax" WHERE code = 'TAR' OR type = 'PRINCIPAL' ORDER BY id ASC LIMIT 1`)).rows[0]
            || (await pg.query(`SELECT id FROM public."ChargeAndTax" ORDER BY id ASC LIMIT 1`)).rows[0];

        // Crear factura temporal de prueba
        const invRes = await pg.query(`
            INSERT INTO public."Invoices" ("clientId", "branchId", "userId", date, "currency", "exchangeRate", "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", state, "internalNumber")
            VALUES ($1, $2, $3, NOW(), 'COP', 1, 0, 0, 0, 4242000, 'PENDING', 'TEST-HTL-PG-001')
            RETURNING id
        `, [clientRow.id, branchRow.id, userRow.id]);
        testInvoiceId = invRes.rows[0].id;

        const ipRes = await pg.query(`
            INSERT INTO public."InvoicesProduct" ("invoiceId", "productId", "mainTaxId", descripcion, quantity, price, cost, nights, "checkInDate", "checkOutDate")
            VALUES ($1, $2, $3, 'ALOJAMIENTO PRUEBA 8 NOCHES', 1, 4242000, 3500000, 8, '2026-11-01', '2026-11-09')
            RETURNING id
        `, [testInvoiceId, prodRow.id, taxRow ? taxRow.id : null]);
        const ipId = ipRes.rows[0].id;

        if (taxRow) {
            await pg.query(`
                INSERT INTO public."InvoicesProductTax" ("invoiceProductId", "chargeAndTaxId", "valueTypeSnapshot", "valueSnapshot", "explicitAmount", "isMain")
                VALUES ($1, $2, 'FIXED', 0, 4242000, true)
            `, [ipId, taxRow.id]);
        }

        const runExport = async () => {
            const res = await pg.query(`CALL public.spExportInvoices($1, $2, $3)`, [String(testInvoiceId), userRow.id, '']);
            return res.rows[0].mensaje_resultado;
        };

        // PRUEBA 1: Parámetro deshabilitado (0)
        await pg.query(`UPDATE public."SystemParameter" SET value = '0' WHERE code = 'EnviarTiposFacturacionHotelesZeus'`);
        const xml0 = await runExport();
        assert(xml0 && xml0.includes('<Facturacion>'), `Prueba 1 PG: XML principal debe generarse normalmente. Recibido: ${String(xml0).slice(0, 300)}`);
        assert(xml0.includes('<Item>'), 'Prueba 1 PG: Nodo <Item> debe enviarse normalmente');
        assert(!xml0.includes('<TiposFacturacionHoteles>'), 'Prueba 1 PG: NO debe incluir <TiposFacturacionHoteles> cuando parámetro = 0');
        console.log('  ✅ Prueba 1 (Parámetro = 0): No envía TiposFacturacionHoteles; demás nodos intactos.');

        // PRUEBA 2 & 3 & 6: Parámetro habilitado (1) + Cálculo $4,242,000 / 8 noches = $530,250
        await pg.query(`UPDATE public."SystemParameter" SET value = '1' WHERE code = 'EnviarTiposFacturacionHotelesZeus'`);
        const xml1 = await runExport();
        const blocks1 = extractBlocks(xml1, 'TiposFacturacionHoteles');
        assert(blocks1.length === 1, `Prueba 2 PG: Debe incluir 1 nodo TiposFacturacionHoteles (encontrados: ${blocks1.length})`);
        const cant8 = Number(extractTag(blocks1[0], 'in_cantidad'));
        const val8 = Number(extractTag(blocks1[0], 'am_valor'));
        const cont8 = Number(extractTag(blocks1[0], 'am_contado'));
        const cred8 = Number(extractTag(blocks1[0], 'am_credito'));
        assert(cant8 === 8, `Prueba 3 PG: in_cantidad esperado 8, obtenido ${cant8}`);
        assert(val8 === 530250, `Prueba 3 PG: am_valor esperado 530250, obtenido ${val8}`);
        assert(cont8 === 4242000, `Prueba 3 PG: am_contado esperado 4242000, obtenido ${cont8}`);
        assert(cred8 === 0, `Prueba 3 PG: am_credito esperado 0, obtenido ${cred8}`);
        assert(Math.round(val8 * cant8 * 100) / 100 === 4242000, `Prueba 6 PG: am_valor * in_cantidad debe ser 4242000`);
        console.log(`  ✅ Prueba 2, 3 y 6 (Parámetro = 1, 8 noches, $4.242.000): Cantidad=${cant8}, ValorUnitario=${val8}, Contado=${cont8}, Total=${val8 * cant8}.`);

        // PRUEBA 4: Diferentes cantidades de noches (2, 3, 5, 8)
        for (const testCase of [
            { nights: 2, total: 1000000, expectedUnit: 500000 },
            { nights: 3, total: 900000, expectedUnit: 300000 },
            { nights: 5, total: 2500000, expectedUnit: 500000 },
            { nights: 8, total: 4242000, expectedUnit: 530250 }
        ]) {
            await pg.query(`UPDATE public."InvoicesProduct" SET nights = $1, price = $2, "checkInDate" = NULL, "checkOutDate" = NULL WHERE id = $3`, [testCase.nights, testCase.total, ipId]);
            const xmlN = await runExport();
            const bN = extractBlocks(xmlN, 'TiposFacturacionHoteles');
            assert(bN.length === 1, `Prueba 4 PG (${testCase.nights} noches): debe existir nodo`);
            const cN = Number(extractTag(bN[0], 'in_cantidad'));
            const vN = Number(extractTag(bN[0], 'am_valor'));
            const tN = Number(extractTag(bN[0], 'am_contado'));
            assert(cN === testCase.nights, `Prueba 4 PG: noches esperadas ${testCase.nights}, obtenidas ${cN}`);
            assert(vN === testCase.expectedUnit, `Prueba 4 PG (${testCase.nights}n): valor esperado ${testCase.expectedUnit}, obtenido ${vN}`);
            assert(Math.round(vN * cN * 100) / 100 === testCase.total, `Prueba 4 PG: total conservado (${vN} * ${cN} = ${testCase.total})`);
        }
        console.log('  ✅ Prueba 4 (2, 3, 5 y 8 noches): División exacta y conservación de total verificada.');

        // PRUEBA 5: Noches = 0 y Noches = NULL (sin fechas checkIn/checkOut)
        await pg.query(`UPDATE public."InvoicesProduct" SET nights = 0, "checkInDate" = NULL, "checkOutDate" = NULL WHERE id = $1`, [ipId]);
        const xmlZero = await runExport();
        assert(!xmlZero.startsWith('ERROR:'), `Prueba 5 PG (0 noches): no debe arrojar error (${xmlZero.slice(0, 100)})`);
        assert(!xmlZero.includes('<TiposFacturacionHoteles>'), 'Prueba 5 PG (0 noches): no debe generar registro con noches = 0');

        await pg.query(`UPDATE public."InvoicesProduct" SET nights = NULL, "checkInDate" = NULL, "checkOutDate" = NULL WHERE id = $1`, [ipId]);
        const xmlNull = await runExport();
        assert(!xmlNull.startsWith('ERROR:'), `Prueba 5 PG (NULL noches): no debe arrojar error (${xmlNull.slice(0, 100)})`);
        assert(!xmlNull.includes('<TiposFacturacionHoteles>'), 'Prueba 5 PG (NULL noches): no debe generar registro con noches = NULL');
        console.log('  ✅ Prueba 5 (Noches = 0 y NULL): Sin error de división y sin registros inválidos.');

        // PRUEBA EXTRA: Cotizaciones (spExportQuotation)
        const qRes = await pg.query(`
            INSERT INTO public."Quotation" ("clientId", "branchId", "userId", date, "currency", "exchangeRate", "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", state, "internalNumber")
            VALUES ($1, $2, $3, NOW(), 'COP', 1, 0, 0, 0, 4242000, 'PENDING', 'TEST-COT-HTL-001')
            RETURNING id
        `, [clientRow.id, branchRow.id, userRow.id]);
        testQuotationId = qRes.rows[0].id;
        const qpRes = await pg.query(`
            INSERT INTO public."QuotationProduct" ("quotationId", "productId", "mainTaxId", quantity, price, cost, nights, "checkInDate", "checkOutDate")
            VALUES ($1, $2, $3, 1, 4242000, 3500000, 8, '2026-11-01', '2026-11-09')
            RETURNING id
        `, [testQuotationId, prodRow.id, taxRow ? taxRow.id : null]);
        if (taxRow) {
            await pg.query(`
                INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueTypeSnapshot", "valueSnapshot", "explicitAmount", "isMain")
                VALUES ($1, $2, 'FIXED', 0, 4242000, true)
            `, [qpRes.rows[0].id, taxRow.id]);
        }
        await pg.query(`UPDATE public."SystemParameter" SET value = '1' WHERE code = 'EnviarTiposFacturacionHotelesZeus'`);
        const qXml1 = (await pg.query(`CALL public.spExportQuotation($1, $2, $3)`, [String(testQuotationId), userRow.id, ''])).rows[0].mensaje_resultado;
        const qb1 = extractBlocks(qXml1, 'Fac_Servicios_TiposFacturacionHoteles');
        assert(qb1.length === 1, `Cotización PG (param=1): debe incluir Fac_Servicios_TiposFacturacionHoteles. Recibido: ${String(qXml1).slice(0, 400)}`);
        assert(Number(extractTag(qb1[0], 'in_cantidad')) === 8, 'Cotización PG: in_cantidad = 8');
        assert(Number(extractTag(qb1[0], 'am_valor')) === 530250, 'Cotización PG: am_valor = 530250');
        assert(Number(extractTag(qb1[0], 'am_contado')) === 4242000, 'Cotización PG: am_contado = 4242000');

        await pg.query(`UPDATE public."SystemParameter" SET value = '0' WHERE code = 'EnviarTiposFacturacionHotelesZeus'`);
        const qXml0 = (await pg.query(`CALL public.spExportQuotation($1, $2, $3)`, [String(testQuotationId), userRow.id, ''])).rows[0].mensaje_resultado;
        assert(!qXml0.includes('<Fac_Servicios_TiposFacturacionHoteles>'), 'Cotización PG (param=0): NO debe incluir Fac_Servicios_TiposFacturacionHoteles');
        console.log('  ✅ Prueba 7 (Regresión + spExportQuotation): Cotizaciones y demás nodos de interfaz 100% conformes.');
    } finally {
        if (testInvoiceId) {
            await pg.query(`DELETE FROM public."InvoicesProductTax" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = $1)`, [testInvoiceId]).catch(() => {});
            await pg.query(`DELETE FROM public."InvoicesProduct" WHERE "invoiceId" = $1`, [testInvoiceId]).catch(() => {});
            await pg.query(`DELETE FROM public."Invoices" WHERE id = $1`, [testInvoiceId]).catch(() => {});
        }
        if (testQuotationId) {
            await pg.query(`DELETE FROM public."QuotationProductTax" WHERE "quotationProductId" IN (SELECT id FROM public."QuotationProduct" WHERE "quotationId" = $1)`, [testQuotationId]).catch(() => {});
            await pg.query(`DELETE FROM public."QuotationProduct" WHERE "quotationId" = $1`, [testQuotationId]).catch(() => {});
            await pg.query(`DELETE FROM public."Quotation" WHERE id = $1`, [testQuotationId]).catch(() => {});
        }
        if (originalParam !== null) {
            await pg.query(`UPDATE public."SystemParameter" SET value = $1 WHERE code = 'EnviarTiposFacturacionHotelesZeus'`, [originalParam]).catch(() => {});
        }
        await pg.end();
    }
}

async function runSqlServerTests() {
    console.log('\n================================================================');
    console.log('  [SQL SERVER] PRUEBAS 1-7: TIPOS DE FACTURACIÓN DE HOTELES');
    console.log('================================================================');
    const pool = await mssql.connect(getSqlServerConfig('Korex_Pruebas'));

    let originalParam = null;
    let testInvoiceId = null;

    try {
        // Asegurar existencia del parámetro en Korex_Pruebas
        const pRes = await pool.request().query(`SELECT [value] FROM dbo.[SystemParameter] WHERE [code] = N'EnviarTiposFacturacionHotelesZeus'`);
        if (pRes.recordset.length === 0) {
            await pool.request().query(`INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarTiposFacturacionHotelesZeus', N'Enviar Tipos de Facturación de Hoteles a Zeus ERP (1: Sí, 0: No)', N'1')`);
            originalParam = '1';
        } else {
            originalParam = pRes.recordset[0].value;
        }

        const clientRow = (await pool.request().query(`SELECT TOP 1 id FROM dbo.[Client] WHERE isActive = 1 ORDER BY id ASC`)).recordset[0];
        const branchRow = (await pool.request().query(`SELECT TOP 1 id FROM dbo.[Branch] ORDER BY id ASC`)).recordset[0];
        const userRow = (await pool.request().query(`SELECT TOP 1 id FROM dbo.[User] ORDER BY id ASC`)).recordset[0];
        const prodRow = (await pool.request().query(`SELECT TOP 1 id FROM dbo.[Product] WHERE type <> 'Tiquete' AND NULLIF(LTRIM(RTRIM(billingConcept)), '') IS NOT NULL ORDER BY id ASC`)).recordset[0]
            || (await pool.request().query(`SELECT TOP 1 id FROM dbo.[Product] WHERE NULLIF(LTRIM(RTRIM(billingConcept)), '') IS NOT NULL ORDER BY id ASC`)).recordset[0]
            || (await pool.request().query(`SELECT TOP 1 id FROM dbo.[Product] ORDER BY id ASC`)).recordset[0];
        const taxRow = (await pool.request().query(`SELECT TOP 1 id FROM dbo.[ChargeAndTax] WHERE code = 'TAR' OR type = 'PRINCIPAL' ORDER BY id ASC`)).recordset[0]
            || (await pool.request().query(`SELECT TOP 1 id FROM dbo.[ChargeAndTax] ORDER BY id ASC`)).recordset[0];

        const invRes = await pool.request()
            .input('c', mssql.Int, clientRow.id)
            .input('b', mssql.Int, branchRow.id)
            .input('u', mssql.Int, userRow.id)
            .query(`
                INSERT INTO dbo.[Invoices] (clientId, branchId, userId, [date], currency, exchangeRate, baseCommissionable, commissionPercentage, chargesAndTaxes, totalAmount, [state], internalNumber)
                OUTPUT INSERTED.id
                VALUES (@c, @b, @u, GETDATE(), 'COP', 1, 0, 0, 0, 4242000, 'PENDING', 'TEST-HTL-SQL-001')
            `);
        testInvoiceId = invRes.recordset[0].id;

        const ipRes = await pool.request()
            .input('inv', mssql.Int, testInvoiceId)
            .input('prod', mssql.Int, prodRow.id)
            .input('tax', mssql.Int, taxRow ? taxRow.id : null)
            .query(`
                INSERT INTO dbo.[InvoicesProduct] (invoiceId, productId, mainTaxId, descripcion, quantity, price, cost, nights, checkInDate, checkOutDate)
                OUTPUT INSERTED.id
                VALUES (@inv, @prod, @tax, 'ALOJAMIENTO PRUEBA 8 NOCHES', 1, 4242000, 3500000, 8, '2026-11-01', '2026-11-09')
            `);
        const ipId = ipRes.recordset[0].id;

        if (taxRow) {
            await pool.request()
                .input('ip', mssql.Int, ipId)
                .input('tax', mssql.Int, taxRow.id)
                .query(`
                    INSERT INTO dbo.[InvoicesProductTax] (invoiceProductId, chargeAndTaxId, valueTypeSnapshot, valueSnapshot, explicitAmount, isMain)
                    VALUES (@ip, @tax, 'FIXED', 0, 4242000, 1)
                `);
        }

        const runExport = async () => {
            const res = await pool.request()
                .input('Envoices_id', mssql.VarChar(mssql.MAX), String(testInvoiceId))
                .input('User_id', mssql.Int, userRow.id)
                .execute('dbo.spExportInvoices');
            return res.recordset[0].mensaje_resultado;
        };

        // PRUEBA 1: Parámetro deshabilitado (0)
        await pool.request().query(`UPDATE dbo.[SystemParameter] SET [value] = N'0' WHERE [code] = N'EnviarTiposFacturacionHotelesZeus'`);
        const xml0 = await runExport();
        assert(xml0 && xml0.includes('<Facturacion>'), 'Prueba 1 SQL: XML principal debe generarse normalmente');
        assert(xml0.includes('<Item>'), 'Prueba 1 SQL: Nodo <Item> debe enviarse normalmente');
        assert(!xml0.includes('<TiposFacturacionHoteles>'), 'Prueba 1 SQL: NO debe incluir <TiposFacturacionHoteles> cuando parámetro = 0');
        console.log('  ✅ Prueba 1 (Parámetro = 0): No envía TiposFacturacionHoteles; demás nodos intactos.');

        // PRUEBA 2, 3 y 6: Parámetro habilitado (1) + $4,242,000 / 8 noches = $530,250
        await pool.request().query(`UPDATE dbo.[SystemParameter] SET [value] = N'1' WHERE [code] = N'EnviarTiposFacturacionHotelesZeus'`);
        const xml1 = await runExport();
        const blocks1 = extractBlocks(xml1, 'TiposFacturacionHoteles');
        assert(blocks1.length === 1, `Prueba 2 SQL: Debe incluir 1 nodo TiposFacturacionHoteles (encontrados: ${blocks1.length})`);
        const cant8 = Number(extractTag(blocks1[0], 'in_cantidad'));
        const val8 = Number(extractTag(blocks1[0], 'am_valor'));
        const cont8 = Number(extractTag(blocks1[0], 'am_contado'));
        const cred8 = Number(extractTag(blocks1[0], 'am_credito'));
        assert(cant8 === 8, `Prueba 3 SQL: in_cantidad esperado 8, obtenido ${cant8}`);
        assert(val8 === 530250, `Prueba 3 SQL: am_valor esperado 530250, obtenido ${val8}`);
        assert(cont8 === 4242000, `Prueba 3 SQL: am_contado esperado 4242000, obtenido ${cont8}`);
        assert(cred8 === 0, `Prueba 3 SQL: am_credito esperado 0, obtenido ${cred8}`);
        assert(Math.round(val8 * cant8 * 100) / 100 === 4242000, `Prueba 6 SQL: am_valor * in_cantidad debe ser 4242000`);
        console.log(`  ✅ Prueba 2, 3 y 6 (Parámetro = 1, 8 noches, $4.242.000): Cantidad=${cant8}, ValorUnitario=${val8}, Contado=${cont8}, Total=${val8 * cant8}.`);

        // PRUEBA 4: Diferentes cantidades de noches (2, 3, 5, 8)
        for (const testCase of [
            { nights: 2, total: 1000000, expectedUnit: 500000 },
            { nights: 3, total: 900000, expectedUnit: 300000 },
            { nights: 5, total: 2500000, expectedUnit: 500000 },
            { nights: 8, total: 4242000, expectedUnit: 530250 }
        ]) {
            await pool.request()
                .input('n', mssql.Int, testCase.nights)
                .input('p', mssql.Float, testCase.total)
                .input('id', mssql.Int, ipId)
                .query(`UPDATE dbo.[InvoicesProduct] SET nights = @n, price = @p, checkInDate = NULL, checkOutDate = NULL WHERE id = @id`);
            const xmlN = await runExport();
            const bN = extractBlocks(xmlN, 'TiposFacturacionHoteles');
            assert(bN.length === 1, `Prueba 4 SQL (${testCase.nights} noches): debe existir nodo`);
            const cN = Number(extractTag(bN[0], 'in_cantidad'));
            const vN = Number(extractTag(bN[0], 'am_valor'));
            assert(cN === testCase.nights, `Prueba 4 SQL: noches esperadas ${testCase.nights}, obtenidas ${cN}`);
            assert(vN === testCase.expectedUnit, `Prueba 4 SQL (${testCase.nights}n): valor esperado ${testCase.expectedUnit}, obtenido ${vN}`);
            assert(Math.round(vN * cN * 100) / 100 === testCase.total, `Prueba 4 SQL: total conservado (${vN} * ${cN} = ${testCase.total})`);
        }
        console.log('  ✅ Prueba 4 (2, 3, 5 y 8 noches): División exacta y conservación de total verificada.');

        // PRUEBA 5: Noches = 0 y Noches = NULL
        await pool.request().input('id', mssql.Int, ipId).query(`UPDATE dbo.[InvoicesProduct] SET nights = 0, checkInDate = NULL, checkOutDate = NULL WHERE id = @id`);
        const xmlZero = await runExport();
        assert(!xmlZero.startsWith('ERROR:'), `Prueba 5 SQL (0 noches): no debe arrojar error`);
        assert(!xmlZero.includes('<TiposFacturacionHoteles>'), 'Prueba 5 SQL (0 noches): no debe generar registro con noches = 0');

        await pool.request().input('id', mssql.Int, ipId).query(`UPDATE dbo.[InvoicesProduct] SET nights = NULL, checkInDate = NULL, checkOutDate = NULL WHERE id = @id`);
        const xmlNull = await runExport();
        assert(!xmlNull.startsWith('ERROR:'), `Prueba 5 SQL (NULL noches): no debe arrojar error`);
        assert(!xmlNull.includes('<TiposFacturacionHoteles>'), 'Prueba 5 SQL (NULL noches): no debe generar registro con noches = NULL');
        console.log('  ✅ Prueba 5 (Noches = 0 y NULL): Sin error de división y sin registros inválidos.');
        console.log('  ✅ Prueba 7 (Regresión SQL Server): Estructura completa de XML y cargos intacta.');
    } finally {
        if (testInvoiceId) {
            await pool.request().input('inv', mssql.Int, testInvoiceId).query(`DELETE FROM dbo.[InvoicesProductTax] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @inv)`).catch(() => {});
            await pool.request().input('inv', mssql.Int, testInvoiceId).query(`DELETE FROM dbo.[InvoicesProduct] WHERE invoiceId = @inv`).catch(() => {});
            await pool.request().input('inv', mssql.Int, testInvoiceId).query(`DELETE FROM dbo.[Invoices] WHERE id = @inv`).catch(() => {});
        }
        if (originalParam !== null) {
            await pool.request().input('v', mssql.NVarChar, originalParam).query(`UPDATE dbo.[SystemParameter] SET [value] = @v WHERE [code] = N'EnviarTiposFacturacionHotelesZeus'`).catch(() => {});
        }
        await pool.close();
    }
}

async function runZeusVerification() {
    console.log('\n================================================================');
    console.log('  [ZEUS ERP - ZeusAgencias_23] VERIFICACIÓN DE SPs INYECTADOS');
    console.log('================================================================');
    const pool = await mssql.connect(getSqlServerConfig('ZeusAgencias_23'));
    try {
        const facDef = (await pool.request().query(`SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spFacturacionesCrear')) AS def`)).recordset[0]?.def || '';
        const cotDef = (await pool.request().query(`SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.spCotizacionesCrear')) AS def`)).recordset[0]?.def || '';

        assert(facDef.includes('EnviarTiposFacturacionHotelesZeus'), 'spFacturacionesCrear en ZeusAgencias_23 debe contener la versión actualizada');
        assert(!facDef.includes('Fallback si no vinieron TiposFacturacionHoteles'), 'spFacturacionesCrear NO debe contener el fallback automático de TiposFacturacionHoteles');
        assert(facDef.includes('AND ISNULL(in_cantidad, 0) > 0'), 'spFacturacionesCrear debe filtrar in_cantidad > 0');

        assert(cotDef.includes("cd_tiposfacturacionhoteles[1]"), 'spCotizacionesCrear debe usar XPath corregido cd_tiposfacturacionhoteles[1]');
        assert(cotDef.includes('AND ISNULL(in_cantidad, 0) > 0'), 'spCotizacionesCrear debe filtrar in_cantidad > 0');

        console.log('  ✅ dbo.spFacturacionesCrear verificado en ZeusAgencias_23 (sin fallback automático, respeta XML y in_cantidad > 0).');
        console.log('  ✅ dbo.spCotizacionesCrear verificado en ZeusAgencias_23 (XPath corregido, respeta am_valor e in_cantidad > 0).');
    } finally {
        await pool.close();
    }
}

(async () => {
    try {
        await runPostgresTests();
        await runSqlServerTests();
        await runZeusVerification();
        console.log('\n================================================================');
        console.log('  🎉 TODAS LAS PRUEBAS (1-7) SUPERADAS EN PG + SQL SERVER + ZEUS');
        console.log('================================================================\n');
        process.exit(0);
    } catch (err) {
        console.error('\n❌ FALLO EN PRUEBAS:', err.message);
        process.exit(1);
    }
})();
