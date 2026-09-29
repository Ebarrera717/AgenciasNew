import dotenv from 'dotenv';
dotenv.config();
import mssql from 'mssql';

async function testUserImport() {
    console.log('Testing SQL Server invoice import with user payload...');
    
    // User data rows
    const rows = [
        {
            "Grupo_Factura": 1,
            "Cliente_Documento": "79898456",
            "Sucursal_Codigo": "OFP",
            "Implant_Codigo": "",
            "Vendedor_Codigo": "OFP",
            "Tiqueteador_Codigo": "MT",
            "Moneda": "COP",
            "Tasa_Cambio": 1,
            "Comision_Global_Pct": 0,
            "Cargos_A_Factura": "TAR:20000|IVA:3800",
            "Producto_Codigo": "HTN",
            "Proveedor_Nombre": "AVIANCA",
            "Proveedor_Codigo": "890100577",
            "Prestadora_Codigo": "001",
            "Impuestos_Nombres_Y_Valores": "",
            "Variables_Codigos_Y_Valores": "AREAT:XYZZ12|CABINA:NORMAL",
            "Pasajeros": "EMMA BARRERA:12345678|Marina Garcia:87654321",
            "Precio_Unitario": 10000,
            "Cantidad": 2,
            "CheckIn": "2026-10-01",
            "CheckOut": "2026-10-10",
            "Pax_Adultos": 2,
            "Pax_Ninos": 0,
            "Destino": "BOG",
            "Tipo_Servicio": "ALIMENTACION",
            "Reserva": "RES123",
            "Comision_Vendedor_Producto": "",
            "Comision_Tiqueteador_Producto": "",
            "Combo_Codigos": "",
            "Nacionalidad": 1,
            "Cargo_Principal": "TAR",
            "Costo": 8000,
            "Servicios": "Desayuno incluido",
            "Descripcion": "Habitacion doble estandar",
            "Pagos": "13800:Efectivo:REF-123|10000:Tarjeta:REF-456:2026-12-01:1:1234:AUTH123:VOUCH456:2028-12",
            "Fecha_Vencimiento_Proveedor": "2026-10-10",
            "Factura_Proveedor": "123456778"
        },
        {
            "Grupo_Factura": 1,
            "Cliente_Documento": "79898456",
            "Sucursal_Codigo": "OFP",
            "Implant_Codigo": "",
            "Vendedor_Codigo": "OFP",
            "Tiqueteador_Codigo": "MT",
            "Moneda": "COP",
            "Tasa_Cambio": 1,
            "Comision_Global_Pct": 0,
            "Cargos_A_Factura": "TAR:10000|ITC:1900",
            "Producto_Codigo": "HTN",
            "Proveedor_Nombre": "AVIANCA",
            "Proveedor_Codigo": "890100577",
            "Prestadora_Codigo": "001",
            "Impuestos_Nombres_Y_Valores": "",
            "Variables_Codigos_Y_Valores": "AREAT:67899|CABINA:VIP",
            "Pasajeros": "EMMA BARRERA:12345678|Marina Garcia:87654321",
            "Precio_Unitario": 5000,
            "Cantidad": 2,
            "CheckIn": "2026-10-01",
            "CheckOut": "2026-10-10",
            "Pax_Adultos": 2,
            "Pax_Ninos": 0,
            "Destino": "BOG",
            "Tipo_Servicio": "ALIMENTACION",
            "Reserva": "RES456",
            "Comision_Vendedor_Producto": "",
            "Comision_Tiqueteador_Producto": "",
            "Combo_Codigos": "",
            "Nacionalidad": 1,
            "Cargo_Principal": "TAR",
            "Costo": 8000,
            "Servicios": "Desayuno incluido",
            "Descripcion": "Habitacion doble estandar",
            "Pagos": "11900:Efectivo:REF-123",
            "Fecha_Vencimiento_Proveedor": "2026-10-11",
            "Factura_Proveedor": "9888998"
        }
    ];

    const pool = await mssql.connect({
        server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
        port: parseInt(process.env.SQLSERVER_PORT || '1433', 10),
        database: process.env.SQLSERVER_DATABASE || 'Korex_Pruebas',
        user: process.env.SQLSERVER_USER || 'sa',
        password: process.env.SQLSERVER_PASSWORD || 'Zeus123*',
        options: {
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true
        }
    });
    const colInfo = await pool.request().query(`
        SELECT COLUMN_NAME, IS_NULLABLE, DATA_TYPE, COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'InvoicesProduct' AND COLUMN_NAME IN ('price', 'quantity', 'cost')
    `);
    console.log('InvoicesProduct columns:', colInfo.recordset);

    console.log('Testing dummy insert...');
    const testRes = await pool.request()
        .input('invId', mssql.Int, 1)
        .input('prodId', mssql.Int, 1)
        .input('qty', mssql.Int, 2)
        .input('price', mssql.Float, 10000)
        .input('cost', mssql.Float, 8000)
        .query(`
            SELECT TOP 1 * FROM dbo.[InvoicesProduct]
        `);
    console.log('InvoicesProduct query succeeded!');

    await pool.close();
    console.log('Test completed successfully!');
}

testUserImport().catch(console.error);
