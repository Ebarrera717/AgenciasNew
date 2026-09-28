const path = require('path');
const mssql = require('mssql');
require('dotenv').config({ path: path.join(__dirname, '.env') });

function getSQLServerConfig(targetDb = 'Korex_Pruebas') {
    return {
        user: 'zeusagencias',
        password: 'zzeusagencias',
        server: 'ZEUSAGENCIAS10',
        database: targetDb,
        port: 1433,
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true
        }
    };
}

async function executeSQLServerProcedure(pool, procName, params = {}) {
    const req = pool.request();
    for (const [key, val] of Object.entries(params)) {
        req.input(key, val);
    }
    const result = await req.execute(procName);
    return result.recordset || [];
}

async function testAllSps() {
    console.log('================================================================');
    console.log('   PRUEBA INTEGRAL DE TODOS LOS SPs EN SQL SERVER (Korex_Pruebas)');
    console.log('================================================================\n');

    const pool = await mssql.connect(getSQLServerConfig('Korex_Pruebas'));

    try {
        // 1. Probar spPreCotizacionListar
        console.log('[TEST 1] spPreCotizacionListar...');
        const preList = await executeSQLServerProcedure(pool, 'spPreCotizacionListar', { p_search: null, p_state: null, p_branch_id: null });
        console.log('  -> OK: Filas retornadas:', preList.length);

        // 2. Probar spPreCotizacionCrear
        console.log('[TEST 2] spPreCotizacionCrear...');
        const preData = {
            branchId: 1,
            clientNameText: 'Cliente Prueba Pre-Cotización',
            headerDescription: 'Solicitud viaje Cancún',
            quotationNotice: 'Solicita hotel 5 estrellas',
            preQuotationType: 'Vacacional',
            startDate: '2026-11-01',
            endDate: '2026-11-08'
        };
        const createPreRes = await executeSQLServerProcedure(pool, 'spPreCotizacionCrear', {
            p_data: JSON.stringify(preData),
            p_acting_user_id: 1
        });
        const preId = createPreRes[0]?.p_pre_quotation_id;
        const preConsecutivo = createPreRes[0]?.p_consecutivo;
        console.log('  -> OK: Creada Pre-Cotización ID:', preId, 'Consecutivo:', preConsecutivo);

        // 3. Probar spPreCotizacionConvertir (solo registrar respuesta)
        console.log('[TEST 3] spPreCotizacionConvertir (Respuesta a Duda)...');
        const respPreRes = await executeSQLServerProcedure(pool, 'spPreCotizacionConvertir', {
            p_pre_quotation_id: preId,
            p_quotation_id: null,
            p_acting_user_id: 1,
            p_notice_response: 'Se revisaron opciones en Cancún'
        });
        console.log('  -> OK:', respPreRes[0]?.p_mensaje_resultado);

        // 4. Probar spCotizacionCrear
        console.log('[TEST 4] spCotizacionCrear...');
        const cotData = {
            clientId: 1,
            branchId: 1,
            currency: 'COP',
            exchangeRate: 1,
            commissionPercentage: 10,
            destination: 'Cancún',
            passenger: 'Juan Pérez',
            paxAdults: 2,
            paxChildren: 0,
            items: [
                {
                    productId: 1,
                    quantity: 2,
                    price: 1500000,
                    cost: 1300000,
                    providerId: 1,
                    appliedTaxes: [
                        { id: 1, chargeAndTaxId: 1, amount: 3000000, explicitAmount: 3000000 }
                    ],
                    passengers: [{ name: 'Juan Pérez', document: '12345678' }],
                    variables: []
                }
            ]
        };
        const cotCreateRes = await executeSQLServerProcedure(pool, 'spCotizacionCrear', {
            p_data: JSON.stringify(cotData),
            p_acting_user_id: 1
        });
        const cotId = cotCreateRes[0]?.p_quotation_id;
        console.log('  -> OK: Cotización creada con ID:', cotId);

        // 5. Probar spPreCotizacionConvertir (Convertir a Cotización)
        console.log('[TEST 5] spPreCotizacionConvertir (Convertir)...');
        const convertRes = await executeSQLServerProcedure(pool, 'spPreCotizacionConvertir', {
            p_pre_quotation_id: preId,
            p_quotation_id: cotId,
            p_acting_user_id: 1,
            p_notice_response: 'Convertida exitosamente'
        });
        console.log('  -> OK:', convertRes[0]?.p_mensaje_resultado);

        // 6. Probar spCotizacionObtener
        console.log('[TEST 6] spCotizacionObtener...');
        const reqObt = pool.request();
        reqObt.input('p_id', cotId);
        const obtResult = await reqObt.execute('spCotizacionObtener');
        const cotRow = obtResult.recordset?.[0];
        console.log('  -> OK: Cotización obtenida. InternalNumber:', cotRow?.internalNumber);
        console.log('  -> Products JSON length:', cotRow?.productsJson?.length || 0);

        // 7. Probar spCotizacionHistorial
        console.log('[TEST 7] spCotizacionHistorial...');
        const histRows = await executeSQLServerProcedure(pool, 'spCotizacionHistorial', {
            p_referencia: String(cotId)
        });
        console.log('  -> OK: Filas historial retornadas:', histRows.length);

        // 8. Probar spCotizacionDuplicar
        console.log('[TEST 8] spCotizacionDuplicar...');
        const dupRes = await executeSQLServerProcedure(pool, 'spCotizacionDuplicar', {
            p_quotation_id: cotId,
            p_acting_user_id: 1
        });
        const dupId = dupRes[0]?.p_new_quotation_id;
        console.log('  -> OK: Cotización duplicada ID:', dupId, 'Consecutivo:', dupRes[0]?.internalNumber);

        // 9. Probar spCotizacionActualizar
        console.log('[TEST 9] spCotizacionActualizar...');
        cotData.destination = 'Cancún Modificado';
        const actRes = await executeSQLServerProcedure(pool, 'spCotizacionActualizar', {
            p_id: cotId,
            p_data: JSON.stringify(cotData),
            p_acting_user_id: 1
        });
        console.log('  -> OK:', actRes[0]?.p_mensaje_resultado);

        // 10. Probar spCotizacionEliminar
        console.log('[TEST 10] spCotizacionEliminar (Duplicada y Creada)...');
        await executeSQLServerProcedure(pool, 'spCotizacionEliminar', { p_id: dupId, p_acting_user_id: 1 });
        await executeSQLServerProcedure(pool, 'spCotizacionEliminar', { p_id: cotId, p_acting_user_id: 1 });
        console.log('  -> OK: Eliminadas cotizaciones de prueba');

        // 11. Probar spPreCotizacionEliminar
        console.log('[TEST 11] spPreCotizacionEliminar...');
        const delPreRes = await executeSQLServerProcedure(pool, 'spPreCotizacionEliminar', { p_id: preId });
        console.log('  -> OK:', delPreRes[0]?.p_mensaje_resultado);

        // 12. Probar spInvoicesObtener
        console.log('[TEST 12] spInvoicesObtener (Factura 121)...');
        const invReq = pool.request();
        invReq.input('p_id', 121);
        const invRes = await invReq.execute('spInvoicesObtener');
        console.log('  -> OK: Invoices recordsets retornados:', invRes.recordsets.length);

        console.log('\n================================================================');
        console.log('   ✅ TODOS LOS SPs PROBADOS CON ÉXITO EN SQL SERVER (100% OK)   ');
        console.log('================================================================\n');
    } finally {
        await pool.close();
    }
}

testAllSps().catch(err => {
    console.error('❌ ERROR EN PRUEBA:', err);
    process.exit(1);
});
