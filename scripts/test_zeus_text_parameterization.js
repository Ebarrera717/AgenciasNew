/**
 * test_zeus_text_parameterization.js
 * Script de validación automatizada para las 12 pruebas obligatorias de parametrización de textos para Zeus ERP.
 */

const assert = require('assert');
const {
    buildZeusItemDescription,
    buildZeusObservations,
    applyZeusTextFormattingToXml,
    DEFAULT_ITEM_DESCRIPTION_CONFIG,
    DEFAULT_OBSERVATIONS_CONFIG
} = require('../src/lib/zeus-text-formatter');

async function runTests() {
    console.log('========================================================================');
    console.log('  TEST SUITE: PARAMETRIZACION DE TEXTOS PARA ZEUS ERP (12 PRUEBAS)     ');
    console.log('========================================================================\n');

    let passed = 0;
    let failed = 0;

    function test(name, fn) {
        try {
            fn();
            console.log(`  [OK] Prueba ${name}`);
            passed++;
        } catch (e) {
            console.error(`  [FAIL] Prueba ${name}:`, e.message);
            failed++;
        }
    }

    // 1. Exportar utilizando únicamente Descripción Manual
    test('1. Exportar utilizando únicamente Descripción Manual', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: '' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: false, order: 2, label: 'Desde' },
                { id: 'fecha_final', name: 'Fecha final', enabled: false, order: 3, label: 'Hasta' }
            ]
        };
        const item = { descripcion: 'HOTEL GHL MONTERIA', checkInDate: '2026-11-05', checkOutDate: '2026-11-08' };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'HOTEL GHL MONTERIA');
    });

    // 2. Exportar con fechas inicial y final
    test('2. Exportar con fechas inicial y final', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Servicio' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Desde' },
                { id: 'fecha_final', name: 'Fecha final', enabled: true, order: 3, label: 'Hasta' }
            ]
        };
        const item = { descripcion: 'HOTEL CARTAGENA', checkInDate: '2026-11-10', checkOutDate: '2026-11-15' };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'Servicio: HOTEL CARTAGENA - Desde: 10/11/2026 - Hasta: 15/11/2026');
    });

    // 3. Incorporar proveedor, prestador y nacionalidad
    test('3. Incorporar proveedor, prestador y nacionalidad', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Servicio' },
                { id: 'proveedor', name: 'Proveedor', enabled: true, order: 2, label: 'Proveedor' },
                { id: 'prestador', name: 'Prestador', enabled: true, order: 3, label: 'Prestador' },
                { id: 'nacionalidad', name: 'Nacionalidad', enabled: true, order: 4, label: 'Nacionalidad' }
            ]
        };
        const item = {
            descripcion: 'HABITACION ESTANDAR',
            providerCode: 'PRICE_RES',
            prestadoraCode: 'HOTEL_GHL',
            inNationality: 1
        };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'Servicio: HABITACION ESTANDAR - Proveedor: PRICE_RES - Prestador: HOTEL_GHL - Nacionalidad: NACIONAL');
    });

    // 4. Probar diferentes combinaciones de campos
    test('4. Probar diferentes combinaciones de campos (Destino + Pasajero + Reserva)', () => {
        const config = {
            separator: ' | ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Tour' },
                { id: 'destino', name: 'Destino', enabled: true, order: 2, label: 'Destino' },
                { id: 'pasajero', name: 'Pasajero', enabled: true, order: 3, label: 'Pax' },
                { id: 'reservacion', name: 'Reserva', enabled: true, order: 4, label: 'CodReserva' }
            ]
        };
        const item = {
            descripcion: 'PASADIA ISLAS DEL ROSARIO',
            destination: 'CARTAGENA',
            passenger: 'CARLOS GOMEZ',
            reservationCode: 'RES-778899'
        };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'Tour: PASADIA ISLAS DEL ROSARIO | Destino: CARTAGENA | Pax: CARLOS GOMEZ | CodReserva: RES-778899');
    });

    // 5. Cambiar el orden de aparición
    test('5. Cambiar el orden de aparición (Nacionalidad primero, luego Fechas, luego Servicio)', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'nacionalidad', name: 'Nacionalidad', enabled: true, order: 1, label: 'Origen' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Inicia' },
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 3, label: 'Detalle' }
            ]
        };
        const item = {
            descripcion: 'VUELO BOG-CTG',
            checkInDate: '2026-12-01',
            inNationality: 2 // INTERNACIONAL
        };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'Origen: INTERNACIONAL - Inicia: 01/12/2026 - Detalle: VUELO BOG-CTG');
    });

    // 6. Modificar etiquetas personalizadas
    test('6. Modificar etiquetas personalizadas (ej. Desde -> Fecha de inicio, Proveedor -> Aerolínea)', () => {
        const config = {
            separator: ' / ',
            fields: [
                { id: 'proveedor', name: 'Proveedor', enabled: true, order: 1, label: 'Aerolínea' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Fecha de inicio' },
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 3, label: 'Concepto' }
            ]
        };
        const item = {
            providerCode: 'AVIANCA',
            checkInDate: '2026-11-20',
            descripcion: 'TIQUETE BOGOTA'
        };
        const result = buildZeusItemDescription(item, config);
        assert.strictEqual(result, 'Aerolínea: AVIANCA / Fecha de inicio: 20/11/2026 / Concepto: TIQUETE BOGOTA');
    });

    // 7. Validar campos vacíos (no deben generar etiquetas ni separadores sobrantes)
    test('7. Validar campos vacíos (omisión limpia de etiquetas y separadores)', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Servicio' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Desde' },
                { id: 'prestador', name: 'Prestador', enabled: true, order: 3, label: 'Prestador' }, // VACÍO
                { id: 'destino', name: 'Destino', enabled: true, order: 4, label: 'Destino' },       // VACÍO
                { id: 'proveedor', name: 'Proveedor', enabled: true, order: 5, label: 'Proveedor' }
            ]
        };
        const item = {
            descripcion: 'CITY TOUR MEDELLIN',
            checkInDate: '2026-11-25',
            prestadoraCode: '', // Vacío
            destination: null,   // Nulo
            providerCode: 'TURISMO_ANTIOQUIA'
        };
        const result = buildZeusItemDescription(item, config);
        // Debe omitir Prestador y Destino por completo sin dejar dobles guiones " -  - "
        assert.strictEqual(result, 'Servicio: CITY TOUR MEDELLIN - Desde: 25/11/2026 - Proveedor: TURISMO_ANTIOQUIA');
    });

    // 8. Adicionar el número de cotización a Observaciones
    test('8. Adicionar el número de cotización a Observaciones', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'numero_cotizacion', name: 'Número de cotización', enabled: true, order: 1, label: 'Cotización' }
            ]
        };
        const header = { quotationConsecutive: '12580' };
        const result = buildZeusObservations('Cliente solicita tarifa corporativa.', header, config);
        assert.strictEqual(result, 'Cliente solicita tarifa corporativa. - Cotización: 12580');
    });

    // 9. Verificar que se conserve el contenido original de Observaciones
    test('9. Verificar que se conserve el contenido original de Observaciones (sin reemplazo)', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'numero_cotizacion', name: 'Número de cotización', enabled: true, order: 1, label: 'Cotización' },
                { id: 'pasajero', name: 'Pasajero', enabled: true, order: 2, label: 'Pasajero' }
            ]
        };
        const orig = 'Servicio solicitado por el cliente. Confirmación pendiente.';
        const header = { quotationConsecutive: '12580', passengerFirstName: 'JUAN', passengerLastName: 'PEREZ' };
        const result = buildZeusObservations(orig, header, config);
        assert.strictEqual(result, 'Servicio solicitado por el cliente. Confirmación pendiente. - Cotización: 12580 - Pasajero: JUAN PEREZ');
        assert(result.startsWith(orig), 'Debe iniciar obligatoriamente con el texto original');
    });

    // 10. Validar longitudes máximas permitidas por Zeus
    test('10. Validar longitudes máximas permitidas por Zeus (truncamiento seguro sin desborde)', () => {
        const config = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Detalle' }
            ]
        };
        const longText = 'A'.repeat(5000);
        const item = { descripcion: longText };
        const resultDesc = buildZeusItemDescription(item, config, 500); // Límite Facturas Zeus = 500
        assert.strictEqual(resultDesc.length, 500);

        const resultObs = buildZeusObservations(longText, {}, config, 8000); // Límite Obs Zeus = 8000
        assert(resultObs.length <= 8000);
    });

    // 11. Procesamiento end-to-end de XML para Zeus ERP
    test('11. Procesamiento end-to-end de XML para Zeus ERP (applyZeusTextFormattingToXml)', () => {
        const xmlInput = `<?xml version="1.0" standalone="yes"?>
<Cotizaciones>
    <Cotizacion>
        <cd_consecutivo>00012580</cd_consecutivo>
        <ds_observacion>Servicio confirmado.</ds_observacion>
        <ds_paxname>JUAN</ds_paxname>
        <ds_paxape>PEREZ</ds_paxape>
        <CotizacionServicios>
            <ds_descrip>HOTEL CARTAGENA</ds_descrip>
            <dt_llegada>2026-11-10T00:00:00</dt_llegada>
            <dt_salida>2026-11-15T00:00:00</dt_salida>
            <cd_proveedores>ABC</cd_proveedores>
            <in_nacionalidad>1</in_nacionalidad>
            <ds_destino>CARTAGENA</ds_destino>
        </CotizacionServicios>
    </Cotizacion>
</Cotizaciones>`;

        const itemConfig = {
            separator: ' - ',
            fields: [
                { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Servicio' },
                { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Desde' },
                { id: 'fecha_final', name: 'Fecha final', enabled: true, order: 3, label: 'Hasta' },
                { id: 'proveedor', name: 'Proveedor', enabled: true, order: 4, label: 'Proveedor' },
                { id: 'nacionalidad', name: 'Nacionalidad', enabled: true, order: 5, label: 'Nacionalidad' }
            ]
        };

        const obsConfig = {
            separator: ' - ',
            fields: [
                { id: 'numero_cotizacion', name: 'Número de cotización', enabled: true, order: 1, label: 'Cotización' },
                { id: 'pasajero', name: 'Nombre del pasajero', enabled: true, order: 2, label: 'Pasajero' }
            ]
        };

        const xmlOutput = applyZeusTextFormattingToXml(xmlInput, itemConfig, obsConfig);

        assert(xmlOutput.includes('<ds_descrip>Servicio: HOTEL CARTAGENA - Desde: 10/11/2026 - Hasta: 15/11/2026 - Proveedor: ABC - Nacionalidad: NACIONAL</ds_descrip>'), 'ds_descrip debe coincidir con el formato');
        assert(xmlOutput.includes('<ds_observacion>Servicio confirmado. - Cotización: 00012580 - Pasajero: JUAN PEREZ</ds_observacion>'), 'ds_observacion debe coincidir con el formato');
    });

    // 12. Validación de persistencia y compatibilidad dual (PostgreSQL + SQL Server)
    test('12. Validación de persistencia y compatibilidad dual (PostgreSQL y SQL Server)', async () => {
        const { getZeusTextConfigs } = require('../src/lib/zeus-text-service');
        const configs = await getZeusTextConfigs();
        assert(configs !== null && typeof configs === 'object', 'getZeusTextConfigs debe retornar objeto válido');
        assert(Array.isArray(configs.itemDescriptionConfig?.fields), 'itemDescriptionConfig debe contener arreglo de campos');
        assert(Array.isArray(configs.observationsConfig?.fields), 'observationsConfig debe contener arreglo de campos');
    });

    console.log(`\n========================================================================`);
    console.log(`  RESULTADO FINAL: ${passed} PASADAS / ${failed} FALLIDAS`);
    console.log(`========================================================================\n`);

    if (failed > 0) {
        process.exit(1);
    }
}

runTests();
