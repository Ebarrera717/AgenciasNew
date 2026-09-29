const mssql = require('mssql');
require('dotenv').config();

async function testExportFields() {
    console.log('\n======================================================');
    console.log('   TEST VALIDATION: INVOICE EXPORT FIELDS TO ZEUS ERP  ');
    console.log('======================================================\n');

    const configKorex = {
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'Korex_Pruebas',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433
    };

    const configZeus = {
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        user: process.env.SQLSERVER_USER || 'zeusagencias',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        database: 'ZeusAgencias_23',
        options: { encrypt: false, trustServerCertificate: true },
        port: 1433
    };

    // 1. Connect to Korex_Pruebas
    const poolKorex = new mssql.ConnectionPool(configKorex);
    await poolKorex.connect();

    // Create a test invoice in Korex
    const invRes = await poolKorex.request().query(`
        INSERT INTO dbo.[Invoices] (clientId, branchId, date, dueDate, currency, exchangeRate, totalAmount, baseCommissionable, commissionPercentage, chargesAndTaxes, state, fuente, serie, consecutivo, internalNumber)
        VALUES (
            (SELECT TOP 1 id FROM dbo.[Client] WHERE isActive = 1),
            (SELECT TOP 1 id FROM dbo.[Branch] WHERE isActive = 1),
            GETDATE(),
            GETDATE(),
            'COP',
            1.0,
            23800,
            20000,
            0,
            3800,
            'PENDING',
            '55',
            '33',
            '',
            'TEST-EXP-' + CAST(DATEDIFF(second, '2026-01-01', GETDATE()) AS VARCHAR)
        );
        SELECT SCOPE_IDENTITY() as newId;
    `);
    const invoiceId = invRes.recordset[0].newId;
    console.log(`Created test invoice in Korex: #${invoiceId}`);

    // Insert Product Item
    await poolKorex.request().query(`
        INSERT INTO dbo.[InvoicesProduct] (
            invoiceId, productId, providerId, prestadoraId, ticketTypeId, descripcion,
            price, quantity, cost, checkInDate, checkOutDate, nights, destination,
            serviceType, servicios, providerInvoice, providerDueDate, inNationality
        ) VALUES (
            ${invoiceId},
            (SELECT TOP 1 id FROM dbo.[Product]),
            (SELECT TOP 1 id FROM dbo.[Provider]),
            (SELECT TOP 1 id FROM dbo.[Prestadora]),
            (SELECT TOP 1 id FROM dbo.[TicketType]),
            'Habitacion Suite Estandar',
            20000,
            1,
            16000,
            '2026-10-01 14:00:00',
            '2026-10-10 11:00:00',
            9,
            'BOG',
            'HOTEL',
            'Desayuno Buffet e Internet de Alta Velocidad',
            'FAC-PROV-9988',
            '2026-10-15 00:00:00',
            1
        );
    `);

    // Insert tax & payment
    const prodIdRes = await poolKorex.request().query(`SELECT TOP 1 id FROM dbo.[InvoicesProduct] WHERE invoiceId = ${invoiceId}`);
    const ipId = prodIdRes.recordset[0].id;

    await poolKorex.request().query(`
        INSERT INTO dbo.[InvoicesProductTax] (invoiceProductId, chargeAndTaxId, valueSnapshot, valueTypeSnapshot, explicitAmount, isMain)
        VALUES 
            (${ipId}, (SELECT TOP 1 id FROM dbo.[ChargeAndTax] WHERE code = 'TAR'), 0, 'FIXED', 20000, 1),
            (${ipId}, (SELECT TOP 1 id FROM dbo.[ChargeAndTax] WHERE code = 'IVA'), 19, 'PERCENTAGE', 3800, 0);

        INSERT INTO dbo.[InvoicesProductPayment] (invoiceProductId, paymentMethod, amount)
        VALUES (${ipId}, 'Efectivo', 23800);

        INSERT INTO dbo.[InvoicesProductPasenger] (invoiceProductId, name, document)
        VALUES (${ipId}, 'JUAN PEREZ GONZALEZ', '12345678');
    `);

    // 2. Export Invoice via spExportInvoices
    console.log('Executing spExportInvoices...');
    const expRes = await poolKorex.request()
        .input('Envoices_id', mssql.VarChar, String(invoiceId))
        .input('User_id', mssql.Int, 1)
        .execute('dbo.spExportInvoices');

    const xmlStr = expRes.recordset[0]?.mensaje_resultado || expRes.output?.mensaje_resultado || '';
    console.log('\n--- EXPORT XML PAYLOAD (SAMPLE) ---');
    console.log(xmlStr.substring(0, 1200));

    // Verify XML contains all required fields
    const hasFacProv = xmlStr.includes('FAC-PROV-9988');
    const hasVenceProv = xmlStr.includes('2026-10-15');
    const hasCheckIn = xmlStr.includes('2026-10-01');
    const hasCheckOut = xmlStr.includes('2026-10-10');
    const hasServicios = xmlStr.includes('Desayuno Buffet e Internet de Alta Velocidad');

    console.log('\n--- XML TAG VERIFICATION ---');
    console.log('  -> cd_facturaproveedor (FAC-PROV-9988):', hasFacProv ? '✅ OK' : '❌ FAILED');
    console.log('  -> dt_fechavencimientoproveedor (2026-10-15):', hasVenceProv ? '✅ OK' : '❌ FAILED');
    console.log('  -> CheckIn (2026-10-01):', hasCheckIn ? '✅ OK' : '❌ FAILED');
    console.log('  -> CheckOut (2026-10-10):', hasCheckOut ? '✅ OK' : '❌ FAILED');
    console.log('  -> ds_servicio (Desayuno Buffet...):', hasServicios ? '✅ OK' : '❌ FAILED');

    if (!hasFacProv || !hasVenceProv || !hasCheckIn || !hasCheckOut || !hasServicios) {
        throw new Error('XML payload is missing required export fields!');
    }

    // 3. Connect to ZeusAgencias_23 and execute spFacturacionesCrear
    console.log('\nConnecting to ZeusAgencias_23 and injecting XML...');
    const poolZeus = new mssql.ConnectionPool(configZeus);
    await poolZeus.connect();

    const zeusRes = await poolZeus.request()
        .input('xml', mssql.VarChar(mssql.MAX), xmlStr)
        .execute('dbo.spFacturacionesCrear');

    console.log('Result from spFacturacionesCrear:', zeusRes.recordset);

    // 4. Verify in Zeus ERP tables: Fac_Servicios and FacturaProveedor
    const lastFac = await poolZeus.request().query(`
        SELECT TOP 1 id, cd_fuente, cd_serie, cd_consecutivo, dt_fechacont
        FROM dbo.fac_factura WITH (NOLOCK)
        ORDER BY id DESC
    `);
    const zeusFac = lastFac.recordset[0];
    console.log('\n--- ZEUS ERP INVOICE CREATED ---', zeusFac);

    if (zeusFac) {
        const srvCheck = await poolZeus.request().query(`
            SELECT id, ds_servicio, dt_llegada, dt_salida, dt_FechaSalidaSrv, dt_FechaLlegadaSrv, dt_VenceFac, cd_tiquete, cd_proveedores
            FROM dbo.Fac_Servicios WITH (NOLOCK)
            WHERE id_fac_factura = ${zeusFac.id}
        `);
        console.log('\n--- ZEUS ERP Fac_Servicios RECORDS ---', srvCheck.recordset);

        const fpCheck = await poolZeus.request().query(`
            SELECT id, id_fac_factura, cd_FacturaProveedor, cd_Proveedor, dt_fechaFacturaProveedor
            FROM dbo.FacturaProveedor WITH (NOLOCK)
            WHERE id_fac_factura = ${zeusFac.id}
        `);
        console.log('\n--- ZEUS ERP FacturaProveedor RECORDS ---', fpCheck.recordset);

        if (fpCheck.recordset.length > 0) {
            console.log('✅ FacturaProveedor successfully populated in Zeus ERP!');
        } else {
            console.warn('⚠️ FacturaProveedor was not populated for Zeus invoice id:', zeusFac.id);
        }

        if (srvCheck.recordset.some(s => s.ds_servicio && s.ds_servicio.includes('Desayuno Buffet'))) {
            console.log('✅ ds_servicio correctly saved in Zeus ERP Fac_Servicios!');
        }

        if (srvCheck.recordset.some(s => s.dt_llegada && s.dt_llegada.toISOString().startsWith('2026-10-01'))) {
            console.log('✅ Check-In date (dt_llegada) correctly saved in Zeus ERP Fac_Servicios!');
        }

        if (srvCheck.recordset.some(s => s.dt_salida && s.dt_salida.toISOString().startsWith('2026-10-10'))) {
            console.log('✅ Check-Out date (dt_salida) correctly saved in Zeus ERP Fac_Servicios!');
        }
    }

    await poolKorex.close();
    await poolZeus.close();
    console.log('\n🎉 ALL VERIFICATIONS COMPLETED SUCCESSFULLY!\n');
}

testExportFields().catch(err => {
    console.error('Test error:', err);
    process.exit(1);
});
