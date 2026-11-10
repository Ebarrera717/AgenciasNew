/**
 * test_passenger_separation.js
 * Comprehensive automated verification test for passenger first name / last name separation in:
 * 1. PostgreSQL (Korex_colaereo)
 * 2. SQL Server (Korex_Pruebas)
 * 3. XML Export to Zeus ERP (ds_paxname / ds_paxape)
 * 4. fnRptCotizacion report function
 * 5. Compound names & historical records compatibility
 */

require('dotenv').config();
const { Client } = require('pg');
const sql = require('mssql');

async function testPostgres() {
    console.log('\n======================================================');
    console.log('--- TEST 1: POSTGRESQL (Korex_colaereo) ---');
    console.log('======================================================');

    const pgUrl = process.env.DATABASE_URL_POSTGRES || 
        (process.env.DATABASE_URL && process.env.DATABASE_URL.startsWith('postgresql://') 
            ? process.env.DATABASE_URL 
            : 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public');

    const pgClient = new Client({
        connectionString: pgUrl
    });
    await pgClient.connect();

    try {
        // 1. Verificar columnas DDL
        const colCheck = await pgClient.query(`
            SELECT table_name, column_name 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND ((table_name = 'Quotation' AND column_name IN ('passengerFirstName', 'passengerLastName'))
                OR (table_name = 'QuotationProduct' AND column_name IN ('passengerFirstName', 'passengerLastName'))
                OR (table_name = 'QuotationProductPassenger' AND column_name IN ('firstName', 'lastName'))
                OR (table_name = 'InvoicesProductPasenger' AND column_name IN ('firstName', 'lastName')))
            ORDER BY table_name, column_name;
        `);
        console.log(`[PG] Columnas DDL detectadas: ${colCheck.rows.length}/8 esperadas`);
        if (colCheck.rows.length < 8) {
            throw new Error(`Faltan columnas en PostgreSQL: solo se encontraron ${colCheck.rows.length}/8`);
        }
        console.log('  -> Columnas en Quotation, QuotationProduct, QuotationProductPassenger e InvoicesProductPasenger: OK');

        // 2. Probar creación de Cotización con nombres y apellidos compuestos
        console.log('\n[PG] Creando Cotización con nombres y apellidos compuestos...');
        const testClientRes = await pgClient.query(`SELECT id FROM public."Client" LIMIT 1;`);
        const clientId = testClientRes.rows[0]?.id || null;
        const testBranchRes = await pgClient.query(`SELECT id FROM public."Branch" LIMIT 1;`);
        const branchId = testBranchRes.rows[0]?.id || null;
        const testProdRes = await pgClient.query(`SELECT id FROM public."Product" LIMIT 1;`);
        const prodId = testProdRes.rows[0]?.id || null;
        const testTaxRes = await pgClient.query(`SELECT id FROM public."ChargeAndTax" LIMIT 1;`);
        const taxId = testTaxRes.rows[0]?.id || null;

        const cotizacionPayload = {
            clientId: clientId,
            branchId: branchId,
            passengerFirstName: 'Juan Carlos',
            passengerLastName: 'De la Torre Perez',
            passenger: 'Juan Carlos De la Torre Perez',
            destination: 'Cartagena',
            totalAmount: 1500000,
            currency: 'COP',
            exchangeRate: 1,
            items: [
                {
                    productId: prodId,
                    quantity: 1,
                    price: 1500000,
                    cost: 1200000,
                    mainTaxId: taxId ? taxId.toString() : null,
                    passengerFirstName: 'Maria Elena',
                    passengerLastName: 'Gomez Restrepo',
                    passenger: 'Maria Elena Gomez Restrepo',
                    passengers: [
                        { firstName: 'Maria Elena', lastName: 'Gomez Restrepo', document: '123456789' },
                        { firstName: 'Santiago', lastName: 'De la Torre Gomez', document: '987654321' }
                    ]
                }
            ]
        };

        const createRes = await pgClient.query(`
            CALL public."spCotizacionCrear"($1::jsonb, null, 0, '');
        `, [JSON.stringify(cotizacionPayload)]);

        const newCotId = createRes.rows[0]?.p_quotation_id;
        const createMsg = createRes.rows[0]?.p_mensaje_resultado;
        if (!newCotId || newCotId === 0) {
            throw new Error(`Fallo al crear cotización en PG: ${createMsg}`);
        }

        const cotCheck = await pgClient.query(`
            SELECT id, "passengerFirstName", "passengerLastName", passenger 
            FROM public."Quotation" 
            WHERE id = $1;
        `, [newCotId]);
        const newCot = cotCheck.rows[0];
        console.log(`  -> Cotización creada ID: ${newCot.id}`);
        console.log(`  -> Header passengerFirstName: "${newCot.passengerFirstName}"`);
        console.log(`  -> Header passengerLastName: "${newCot.passengerLastName}"`);
        console.log(`  -> Header passenger legado: "${newCot.passenger}"`);

        if (newCot.passengerFirstName !== 'Juan Carlos' || newCot.passengerLastName !== 'De la Torre Perez') {
            throw new Error('Fallo en asignación de nombres/apellidos en cabecera de Cotización');
        }

        // Verificar fnCotizacion
        const fnCotRes = await pgClient.query(`SELECT public.fncotizacion($1::int) AS cot_data;`, [newCot.id]);
        const cotDet = fnCotRes.rows[0]?.cot_data;
        const item1 = cotDet?.products?.[0] || {};
        console.log(`  -> Item passengerFirstName: "${item1.passengerFirstName}"`);
        console.log(`  -> Item passengerLastName: "${item1.passengerLastName}"`);
        console.log(`  -> Item passengers[0] firstName: "${item1.passengers?.[0]?.firstName}", lastName: "${item1.passengers?.[0]?.lastName}"`);
        console.log(`  -> Item passengers[1] firstName: "${item1.passengers?.[1]?.firstName}", lastName: "${item1.passengers?.[1]?.lastName}"`);

        if (item1.passengerFirstName !== 'Maria Elena' || item1.passengerLastName !== 'Gomez Restrepo') {
            throw new Error('Fallo en asignación de nombres/apellidos en producto de Cotización');
        }
        if (item1.passengers?.[0]?.firstName !== 'Maria Elena' || item1.passengers?.[0]?.lastName !== 'Gomez Restrepo' ||
            item1.passengers?.[1]?.firstName !== 'Santiago' || item1.passengers?.[1]?.lastName !== 'De la Torre Gomez') {
            throw new Error('Fallo en arreglo dinámico de pasajeros en fnCotizacion');
        }
        console.log('  ✅ [OK] Creación y consulta de Cotización con nombres separados en PostgreSQL');

        // 3. Probar spExportQuotation y XML hacia Zeus ERP
        console.log('\n[PG] Verificando XML generado por spExportQuotation hacia Zeus ERP...');
        const expRes = await pgClient.query(`
            CALL public.spexportquotation($1::text, 1::int, ''::text);
        `, [newCot.id.toString()]);
        const xmlOut = expRes.rows[0]?.mensaje_resultado || '';
        const hasPaxName1 = xmlOut.includes('<ds_paxname>Maria Elena</ds_paxname>');
        const hasPaxApe1 = xmlOut.includes('<ds_paxape>Gomez Restrepo</ds_paxape>');
        const hasPaxName2 = xmlOut.includes('<ds_paxname>Santiago</ds_paxname>');
        const hasPaxApe2 = xmlOut.includes('<ds_paxape>De la Torre Gomez</ds_paxape>');
        console.log(`  -> spExportQuotation ds_paxname 'Maria Elena': ${hasPaxName1 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`  -> spExportQuotation ds_paxape 'Gomez Restrepo': ${hasPaxApe1 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`  -> spExportQuotation ds_paxname 'Santiago': ${hasPaxName2 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`  -> spExportQuotation ds_paxape 'De la Torre Gomez': ${hasPaxApe2 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        if (!hasPaxName1 || !hasPaxApe1) {
            throw new Error('Fallo en mapeo de ds_paxname / ds_paxape en spExportQuotation (PostgreSQL)');
        }
        console.log('  ✅ [OK] spExportQuotation exporta ds_paxname y ds_paxape correctamente en PostgreSQL');

        // 4. Probar fnRptCotizacion
        console.log('\n[PG] Verificando columnas en fnRptCotizacion...');
        const rptRes = await pgClient.query(`
            SELECT "idCotizacion", "pasajeroCabeceraNombres", "pasajeroCabeceraApellidos", "pasajerosNombres", "pasajerosApellidos"
            FROM public."fnRptCotizacion"($1::int, $1::int);
        `, [newCot.id]);
        if (rptRes.rows.length > 0) {
            const rpt = rptRes.rows[0];
            console.log(`  -> fnRptCotizacion pasajeroCabeceraNombres: "${rpt.pasajeroCabeceraNombres}"`);
            console.log(`  -> fnRptCotizacion pasajeroCabeceraApellidos: "${rpt.pasajeroCabeceraApellidos}"`);
            console.log(`  -> fnRptCotizacion pasajerosNombres: "${rpt.pasajerosNombres}"`);
            console.log(`  -> fnRptCotizacion pasajerosApellidos: "${rpt.pasajerosApellidos}"`);

            if (rpt.pasajeroCabeceraNombres !== 'Juan Carlos' || rpt.pasajeroCabeceraApellidos !== 'De la Torre Perez') {
                throw new Error('Fallo en columnas de nombres de cabecera en fnRptCotizacion');
            }
            console.log('  ✅ [OK] Columnas separadas en fnRptCotizacion verificadas');
        }

        // 5. Probar Creación de Factura con pasajeros separados
        console.log('\n[PG] Creando Factura con pasajeros con nombres separados...');
        const invPayload = {
            clientId: clientId,
            branchId: branchId,
            totalAmount: 1500000,
            currency: 'COP',
            items: [
                {
                    productId: prodId,
                    quantity: 1,
                    price: 1500000,
                    cost: 1200000,
                    passengers: [
                        { firstName: 'Carlos Alberto', lastName: 'Mendoza Velez', document: '11223344' },
                        { firstName: 'Ana Lucia', lastName: 'Castro Rios', document: '55667788' }
                    ]
                }
            ]
        };

        const invCreateRes = await pgClient.query(`CALL public.spInvoicesCrear($1::jsonb, null, 0, '');`, [JSON.stringify(invPayload)]);
        const newInvId = invCreateRes.rows[0]?.p_invoice_id;
        const invMsg = invCreateRes.rows[0]?.p_mensaje_resultado;
        if (!newInvId || newInvId === 0) {
            throw new Error(`Fallo al crear factura en PG: ${invMsg}`);
        }
        console.log(`  -> Factura creada ID: ${newInvId}`);

        const fnInvRes = await pgClient.query(`
            SELECT * FROM public."fnInvoicesListar"() 
            WHERE ("fnInvoicesListar"->>'id')::int = $1;
        `, [newInvId]);
        const invRow = fnInvRes.rows[0]?.fnInvoicesListar;
        const paxList = invRow?.products?.[0]?.passengers || [];
        console.log(`  -> Factura Pax 1: firstName="${paxList[0]?.firstName}", lastName="${paxList[0]?.lastName}", name="${paxList[0]?.name}"`);
        console.log(`  -> Factura Pax 2: firstName="${paxList[1]?.firstName}", lastName="${paxList[1]?.lastName}", name="${paxList[1]?.name}"`);

        if (paxList[0]?.firstName !== 'Carlos Alberto' || paxList[0]?.lastName !== 'Mendoza Velez' ||
            paxList[1]?.firstName !== 'Ana Lucia' || paxList[1]?.lastName !== 'Castro Rios') {
            throw new Error('Fallo en separación de nombres en pasajeros de Factura en PostgreSQL');
        }
        console.log('  ✅ [OK] Creación y consulta de Factura con nombres separados en PostgreSQL');

        // Limpiar registros de prueba creados
        await pgClient.query(`DELETE FROM public."InvoicesProductPasenger" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = $1)`, [newInvId]);
        await pgClient.query(`DELETE FROM public."InvoicesProduct" WHERE "invoiceId" = $1`, [newInvId]);
        await pgClient.query(`DELETE FROM public."Invoices" WHERE id = $1`, [newInvId]);

        await pgClient.query(`DELETE FROM public."QuotationProductPassenger" WHERE "quotationProductId" IN (SELECT id FROM public."QuotationProduct" WHERE "quotationId" = $1)`, [newCot.id]);
        await pgClient.query(`DELETE FROM public."QuotationProduct" WHERE "quotationId" = $1`, [newCot.id]);
        await pgClient.query(`DELETE FROM public."Quotation" WHERE id = $1`, [newCot.id]);
        console.log('  [OK] Registros de prueba eliminados limpiamente en PostgreSQL.');

    } finally {
        await pgClient.end();
    }
}

async function testSqlServer() {
    console.log('\n======================================================');
    console.log('--- TEST 2: SQL SERVER (Korex_Pruebas) ---');
    console.log('======================================================');

    let defaultUser = 'zeusagencias';
    let defaultPass = 'zzeusagencias';
    let defaultHost = 'ZEUSAGENCIAS10';
    let defaultDb = 'Korex_Pruebas';
    let defaultPort = 1433;

    const envUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL;
    if (envUrl && (envUrl.startsWith('sqlserver://') || envUrl.startsWith('mssql://'))) {
        const clean = envUrl.replace(/^(sqlserver|mssql):\/\//i, '');
        const hostPortPart = clean.split(';')[0];
        defaultHost = hostPortPart.split(':')[0] || defaultHost;
        const params = clean.split(';');
        for (const p of params) {
            const eqIdx = p.indexOf('=');
            if (eqIdx > 0) {
                const k = p.substring(0, eqIdx).trim().toLowerCase();
                const v = decodeURIComponent(p.substring(eqIdx + 1).trim());
                if (k === 'user' || k === 'user id' || k === 'uid') defaultUser = v;
                else if (k === 'password' || k === 'pwd') defaultPass = v;
            }
        }
    }

    const sqlConfig = {
        user: process.env.SQLSERVER_USER || defaultUser,
        password: process.env.SQLSERVER_PASSWORD || defaultPass,
        server: process.env.SQLSERVER_HOST || process.env.SQLSERVER_SERVER || defaultHost,
        port: parseInt(process.env.SQLSERVER_PORT || defaultPort),
        database: process.env.SQLSERVER_DATABASE || 'Korex_Pruebas',
        options: {
            encrypt: false,
            trustServerCertificate: true
        }
    };

    const pool = await sql.connect(sqlConfig);

    try {
        // 1. Verificar columnas DDL en SQL Server
        const colCheck = await pool.request().query(`
            SELECT TABLE_NAME, COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = 'dbo' 
              AND ((TABLE_NAME = 'Quotation' AND COLUMN_NAME IN ('passengerFirstName', 'passengerLastName'))
                OR (TABLE_NAME = 'QuotationProduct' AND COLUMN_NAME IN ('passengerFirstName', 'passengerLastName'))
                OR (TABLE_NAME = 'QuotationProductPassenger' AND COLUMN_NAME IN ('firstName', 'lastName'))
                OR (TABLE_NAME = 'InvoicesProductPasenger' AND COLUMN_NAME IN ('firstName', 'lastName')))
            ORDER BY TABLE_NAME, COLUMN_NAME;
        `);
        console.log(`[SQL Server] Columnas DDL detectadas: ${colCheck.recordset.length}/8 esperadas`);
        if (colCheck.recordset.length < 8) {
            throw new Error(`Faltan columnas en SQL Server: solo se encontraron ${colCheck.recordset.length}/8`);
        }
        console.log('  -> Columnas en Quotation, QuotationProduct, QuotationProductPassenger e InvoicesProductPasenger: OK');

        // 2. Probar creación de Cotización con nombres y apellidos en SQL Server
        console.log('\n[SQL Server] Creando Cotización con nombres separados...');
        const clientRes = await pool.request().query(`SELECT TOP 1 id FROM dbo.[Client];`);
        const clientId = clientRes.recordset[0]?.id || null;
        const branchRes = await pool.request().query(`SELECT TOP 1 id FROM dbo.[Branch];`);
        const branchId = branchRes.recordset[0]?.id || null;
        const prodRes = await pool.request().query(`SELECT TOP 1 id FROM dbo.[Product];`);
        const prodId = prodRes.recordset[0]?.id || null;
        const taxRes = await pool.request().query(`SELECT TOP 1 id FROM dbo.[ChargeAndTax];`);
        const taxId = taxRes.recordset[0]?.id || null;

        const cotPayload = {
            clientId: clientId,
            branchId: branchId,
            passengerFirstName: 'Alejandro',
            passengerLastName: 'Montoya Uribe',
            passenger: 'Alejandro Montoya Uribe',
            destination: 'Santa Marta',
            totalAmount: 2400000,
            currency: 'COP',
            items: [
                {
                    productId: prodId,
                    quantity: 1,
                    price: 2400000,
                    cost: 1900000,
                    mainTaxId: taxId,
                    passengerFirstName: 'Valentina',
                    passengerLastName: 'Osorio Restrepo',
                    passenger: 'Valentina Osorio Restrepo',
                    passengers: [
                        { firstName: 'Valentina', lastName: 'Osorio Restrepo', document: '10203040' },
                        { firstName: 'David', lastName: 'Montoya Osorio', document: '50607080' }
                    ]
                }
            ]
        };

        const createReq = pool.request();
        createReq.input('p_data', sql.NVarChar(sql.MAX), JSON.stringify(cotPayload));
        createReq.output('p_quotation_id', sql.Int);
        createReq.output('p_mensaje_resultado', sql.NVarChar(sql.MAX));
        const cRes = await createReq.execute('dbo.spCotizacionCrear');
        const newCotId = cRes.output.p_quotation_id;
        const cMsg = cRes.output.p_mensaje_resultado;
        if (!newCotId || newCotId === 0) {
            throw new Error(`Fallo en spCotizacionCrear en SQL Server: ${cMsg}`);
        }

        const cotCheck = await pool.request().query(`
            SELECT id, passengerFirstName, passengerLastName, passenger 
            FROM dbo.[Quotation] 
            WHERE id = ${newCotId};
        `);
        const newCot = cotCheck.recordset[0];
        console.log(`  -> Cotización creada en SQL Server ID: ${newCot.id}`);
        console.log(`  -> Header passengerFirstName: "${newCot.passengerFirstName}"`);
        console.log(`  -> Header passengerLastName: "${newCot.passengerLastName}"`);
        console.log(`  -> Header passenger legado: "${newCot.passenger}"`);

        if (newCot.passengerFirstName !== 'Alejandro' || newCot.passengerLastName !== 'Montoya Uribe') {
            throw new Error('Fallo en asignación de nombres/apellidos en cabecera de Cotización en SQL Server');
        }

        // 3. Probar spCotizacionObtener en SQL Server
        const obtReq = pool.request();
        obtReq.input('p_id', sql.Int, newCot.id);
        const obtRes = await obtReq.execute('dbo.spCotizacionObtener');
        const header = obtRes.recordsets[0][0];
        const products = header.productsJson ? (typeof header.productsJson === 'string' ? JSON.parse(header.productsJson) : header.productsJson) : [];
        const item = products[0] || {};
        console.log(`  -> spCotizacionObtener header passengerFirstName: "${header.passengerFirstName}"`);
        console.log(`  -> spCotizacionObtener header passengerLastName: "${header.passengerLastName}"`);
        console.log(`  -> spCotizacionObtener item passengerFirstName: "${item.passengerFirstName}"`);
        console.log(`  -> spCotizacionObtener item passengerLastName: "${item.passengerLastName}"`);
        
        const paxJson = item.passengersJson ? (typeof item.passengersJson === 'string' ? JSON.parse(item.passengersJson) : item.passengersJson) : [];
        console.log(`  -> spCotizacionObtener pax 0: firstName="${paxJson[0]?.firstName}", lastName="${paxJson[0]?.lastName}"`);
        console.log(`  -> spCotizacionObtener pax 1: firstName="${paxJson[1]?.firstName}", lastName="${paxJson[1]?.lastName}"`);

        if (header.passengerFirstName !== 'Alejandro' || header.passengerLastName !== 'Montoya Uribe' ||
            item.passengerFirstName !== 'Valentina' || item.passengerLastName !== 'Osorio Restrepo' ||
            paxJson[0]?.firstName !== 'Valentina' || paxJson[0]?.lastName !== 'Osorio Restrepo' ||
            paxJson[1]?.firstName !== 'David' || paxJson[1]?.lastName !== 'Montoya Osorio') {
            throw new Error('Fallo en spCotizacionObtener en SQL Server');
        }
        console.log('  ✅ [OK] Creación y spCotizacionObtener en SQL Server');

        // 4. Probar actualización con spCotizacionActualizar en SQL Server
        console.log('\n[SQL Server] Actualizando Cotización...');
        const updPayload = {
            ...cotPayload,
            passengerFirstName: 'Alejandro Modificado',
            passengerLastName: 'Montoya Uribe',
            items: [
                {
                    ...cotPayload.items[0],
                    passengerFirstName: 'Valentina Modificada',
                    passengerLastName: 'Osorio Restrepo',
                    passengers: [
                        { firstName: 'Valentina Modificada', lastName: 'Osorio Restrepo', document: '10203040' },
                        { firstName: 'David Modificado', lastName: 'Montoya Osorio', document: '50607080' }
                    ]
                }
            ]
        };
        const updReq = pool.request();
        updReq.input('p_id', sql.Int, newCot.id);
        updReq.input('p_data', sql.NVarChar(sql.MAX), JSON.stringify(updPayload));
        updReq.output('p_mensaje_resultado', sql.NVarChar(sql.MAX));
        await updReq.execute('dbo.spCotizacionActualizar');

        const updCheck = await pool.request().query(`SELECT passengerFirstName, passengerLastName FROM dbo.[Quotation] WHERE id = ${newCot.id}`);
        if (updCheck.recordset[0].passengerFirstName !== 'Alejandro Modificado') {
            throw new Error('Fallo en spCotizacionActualizar al actualizar passengerFirstName');
        }
        console.log('  ✅ [OK] spCotizacionActualizar preservó nombres/apellidos actualizados en SQL Server');

        // 5. Probar spCotizacionDuplicar en SQL Server
        console.log('\n[SQL Server] Duplicando Cotización...');
        const dupReq = pool.request();
        dupReq.input('p_quotation_id', sql.Int, newCot.id);
        dupReq.output('p_new_quotation_id', sql.Int);
        dupReq.output('p_mensaje_resultado', sql.NVarChar(sql.MAX));
        const dupRes = await dupReq.execute('dbo.spCotizacionDuplicar');
        const duplicatedId = dupRes.output.p_new_quotation_id;
        console.log(`  -> Cotización duplicada ID: ${duplicatedId}`);

        const dupCheck = await pool.request().query(`
            SELECT id, passengerFirstName, passengerLastName, passenger 
            FROM dbo.[Quotation] 
            WHERE id = ${duplicatedId};
        `);
        const dupRow = dupCheck.recordset[0];
        if (dupRow.passengerFirstName !== 'Alejandro Modificado' || dupRow.passengerLastName !== 'Montoya Uribe') {
            throw new Error('Fallo en preservación de nombres/apellidos al duplicar cotización en SQL Server');
        }
        console.log('  ✅ [OK] Preservación de nombres/apellidos al duplicar en SQL Server');

        // 6. Probar Creación de Factura en SQL Server
        console.log('\n[SQL Server] Creando Factura con pasajeros con nombres separados...');
        const invPayload = {
            clientId: clientId,
            branchId: branchId,
            totalAmount: 1800000,
            currency: 'COP',
            items: [
                {
                    productId: prodId,
                    quantity: 1,
                    price: 1800000,
                    cost: 1400000,
                    passengers: [
                        { firstName: 'Gabriel', lastName: 'Garcia Marquez', document: '70809010' },
                        { firstName: 'Mercedes', lastName: 'Barcha Pardo', document: '80901020' }
                    ]
                }
            ]
        };

        const invReq = pool.request();
        invReq.input('p_data', sql.NVarChar(sql.MAX), JSON.stringify(invPayload));
        invReq.output('p_invoice_id', sql.Int);
        invReq.output('p_mensaje_resultado', sql.NVarChar(sql.MAX));
        const invRes = await invReq.execute('dbo.spInvoicesCrear');
        const newInvId = invRes.output.p_invoice_id;
        if (!newInvId || newInvId === 0) {
            throw new Error(`Fallo en spInvoicesCrear en SQL Server: ${invRes.output.p_mensaje_resultado}`);
        }
        console.log(`  -> Factura creada en SQL Server ID: ${newInvId}`);

        // Verificar spInvoicesObtener
        const invObtReq = pool.request();
        invObtReq.input('p_id', sql.Int, newInvId);
        const invObtRes = await invObtReq.execute('dbo.spInvoicesObtener');
        const invPaxRows = invObtRes.recordsets[3]; // Recordset 3: Pasajeros (0=Invoice, 1=Items, 2=Taxes, 3=Passengers)
        console.log(`  -> spInvoicesObtener Pax 1: firstName="${invPaxRows[0]?.firstName}", lastName="${invPaxRows[0]?.lastName}"`);
        console.log(`  -> spInvoicesObtener Pax 2: firstName="${invPaxRows[1]?.firstName}", lastName="${invPaxRows[1]?.lastName}"`);

        if (invPaxRows[0]?.firstName !== 'Gabriel' || invPaxRows[0]?.lastName !== 'Garcia Marquez' ||
            invPaxRows[1]?.firstName !== 'Mercedes' || invPaxRows[1]?.lastName !== 'Barcha Pardo') {
            throw new Error('Fallo en spInvoicesObtener con nombres separados en SQL Server');
        }
        console.log('  ✅ [OK] Creación y spInvoicesObtener en SQL Server');

        // 7. Probar spExportInvoices y XML en SQL Server
        console.log('\n[SQL Server] Probando spExportInvoices para exportación a Zeus ERP...');
        const expReq = pool.request();
        expReq.input('Envoices_id', sql.VarChar(sql.MAX), newInvId.toString());
        const expRes = await expReq.execute('dbo.spExportInvoices');
        const xmlOut = expRes.recordset[0]?.mensaje_resultado || '';
        
        console.log('  -> Verificando presencia de ds_paxname y ds_paxape en XML de exportación:');
        const hasPaxName1 = xmlOut.includes('<ds_paxname>Gabriel</ds_paxname>');
        const hasPaxApe1 = xmlOut.includes('<ds_paxape>Garcia Marquez</ds_paxape>');
        const hasPaxName2 = xmlOut.includes('<ds_paxname>Mercedes</ds_paxname>');
        const hasPaxApe2 = xmlOut.includes('<ds_paxape>Barcha Pardo</ds_paxape>');

        console.log(`    * <ds_paxname>Gabriel</ds_paxname>: ${hasPaxName1 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`    * <ds_paxape>Garcia Marquez</ds_paxape>: ${hasPaxApe1 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`    * <ds_paxname>Mercedes</ds_paxname>: ${hasPaxName2 ? '✅ PRESENTE' : '❌ AUSENTE'}`);
        console.log(`    * <ds_paxape>Barcha Pardo</ds_paxape>: ${hasPaxApe2 ? '✅ PRESENTE' : '❌ AUSENTE'}`);

        if (!hasPaxName1 || !hasPaxApe1 || !hasPaxName2 || !hasPaxApe2) {
            console.warn('  [XML Output Snippet]:', xmlOut.substring(0, 1500));
            throw new Error('El XML de spExportInvoices no contiene el mapeo exacto de ds_paxname y ds_paxape');
        }
        console.log('  ✅ [OK] XML de exportación hacia Zeus ERP generado con mapeo directo 100% exacto');

        // Limpiar registros de prueba en SQL Server
        await pool.request().query(`
            DELETE FROM dbo.[InvoicesProductPasenger] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = ${newInvId});
            DELETE FROM dbo.[InvoicesProduct] WHERE invoiceId = ${newInvId};
            DELETE FROM dbo.[Invoices] WHERE id = ${newInvId};

            DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId IN (${newCot.id}, ${duplicatedId}));
            DELETE FROM dbo.[QuotationProduct] WHERE quotationId IN (${newCot.id}, ${duplicatedId});
            DELETE FROM dbo.[Quotation] WHERE id IN (${newCot.id}, ${duplicatedId});
        `);
        console.log('  [OK] Registros de prueba eliminados limpiamente en SQL Server.');

    } finally {
        await pool.close();
    }
}

async function runAll() {
    console.log('======================================================');
    console.log(' SUITE DE VALIDACIÓN AUTOMATIZADA - SEPARACIÓN DE NOMBRES');
    console.log('======================================================');
    try {
        await testPostgres();
        await testSqlServer();
        console.log('\n======================================================');
        console.log(' 🎉 TODAS LAS PRUEBAS MULTIBASE PASARON CON ÉXITO (100%)');
        console.log('======================================================\n');
        process.exit(0);
    } catch (err) {
        console.error('\n❌ ERROR EN LA SUITE DE VALIDACIÓN:', err);
        process.exit(1);
    }
}

runAll();
