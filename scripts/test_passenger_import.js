const fs = require('fs');
const path = require('path');
const { getQuotationTemplateData, getInvoiceTemplateData } = require('../src/lib/excel-templates');
const { parseExcelPassengers, buildExcelPassengersString } = require('../src/app/api/quotations/import/route');

function testTemplateData() {
    console.log('======================================================');
    console.log(' TEST: PLANTILLAS EXCEL Y PARSEO DE PASAJEROS');
    console.log('======================================================');

    // 1. Verificar Plantilla de Cotizaciones
    const qData = getQuotationTemplateData();
    console.log('\n[Plantilla Cotizaciones]');
    console.log('  -> Filas de ejemplo:', qData.length);
    console.log('  -> Fila 0 Pasajero_Nombres:', qData[0].Pasajero_Nombres);
    console.log('  -> Fila 0 Pasajero_Apellidos:', qData[0].Pasajero_Apellidos);
    console.log('  -> Fila 0 Pasajeros:', qData[0].Pasajeros);

    if (!qData[0].Pasajero_Nombres || !qData[0].Pasajero_Apellidos) {
        throw new Error('Faltan columnas Pasajero_Nombres / Pasajero_Apellidos en plantilla de Cotizaciones');
    }

    const parsedQ0 = parseExcelPassengers(qData[0]);
    console.log('  -> Pasajeros parseados fila 0:', parsedQ0);
    if (parsedQ0.length < 2 || parsedQ0[0].firstName !== 'Juan Carlos' || parsedQ0[0].lastName !== 'Perez Gomez') {
        throw new Error('Fallo en parseo de pasajeros fila 0 de Cotizaciones');
    }
    const buildQ0 = buildExcelPassengersString(qData[0]);
    console.log('  -> String formateado:', buildQ0);
    if (!buildQ0.includes('Juan Carlos:Perez Gomez') || !buildQ0.includes('Maria Elena:Garcia Lopez')) {
        throw new Error('Fallo en buildExcelPassengersString de Cotizaciones');
    }
    console.log('  ✅ [OK] Plantilla de Cotizaciones verificada');

    // 2. Verificar Plantilla de Facturas
    const invData = getInvoiceTemplateData();
    console.log('\n[Plantilla Facturas]');
    console.log('  -> Filas de ejemplo:', invData.length);
    console.log('  -> Fila 0 Pasajero_Nombres:', invData[0].Pasajero_Nombres);
    console.log('  -> Fila 0 Pasajero_Apellidos:', invData[0].Pasajero_Apellidos);
    console.log('  -> Fila 0 Pasajeros:', invData[0].Pasajeros);

    if (!invData[0].Pasajero_Nombres || !invData[0].Pasajero_Apellidos) {
        throw new Error('Faltan columnas Pasajero_Nombres / Pasajero_Apellidos en plantilla de Facturas');
    }

    const parsedInv0 = parseExcelPassengers(invData[0]);
    console.log('  -> Pasajeros parseados fila 0:', parsedInv0);
    if (parsedInv0.length < 2 || parsedInv0[0].firstName !== 'Juan Carlos' || parsedInv0[0].lastName !== 'Perez Gomez') {
        throw new Error('Fallo en parseo de pasajeros fila 0 de Facturas');
    }
    const buildInv0 = buildExcelPassengersString(invData[0]);
    console.log('  -> String formateado:', buildInv0);
    if (!buildInv0.includes('Juan Carlos:Perez Gomez') || !buildInv0.includes('Maria Elena:Garcia Lopez')) {
        throw new Error('Fallo en buildExcelPassengersString de Facturas');
    }
    console.log('  ✅ [OK] Plantilla de Facturas verificada');

    // 3. Probar compatibilidad con formato legado "Juan Perez:12345678"
    console.log('\n[Compatibilidad Formato Legado]');
    const legacyRow = {
        Pasajeros: 'Gabriel Garcia Marquez:708090|Mercedes Barcha Pardo:809010'
    };
    const parsedLegacy = parseExcelPassengers(legacyRow);
    console.log('  -> Legado parseado:', parsedLegacy);
    if (parsedLegacy[0].firstName !== 'Gabriel' || parsedLegacy[0].lastName !== 'Garcia Marquez' ||
        parsedLegacy[1].firstName !== 'Mercedes' || parsedLegacy[1].lastName !== 'Barcha Pardo') {
        throw new Error('Fallo en compatibilidad con formato legado de pasajeros');
    }
    console.log('  ✅ [OK] Compatibilidad con formato legado validada');

    console.log('\n======================================================');
    console.log(' 🎉 TODAS LAS PRUEBAS DE PLANTILLAS PASARON CON ÉXITO');
    console.log('======================================================\n');
}

testTemplateData();
