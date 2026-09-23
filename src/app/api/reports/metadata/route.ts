import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

const ALLOWED_TABLES = [
    'Quotation',
    'QuotationProduct',
    'QuotationManualService',
    'Client',
    'Seller',
    'TicketPrinter',
    'Branch',
    'Implant',
    'Provider',
    'Prestadora',
    'Product',
    'User'
]

const TABLE_FRIENDLY_NAMES: Record<string, string> = {
    Quotation: 'Cotizaciones (Cabecera)',
    QuotationProduct: 'Productos de Cotización',
    QuotationManualService: 'Servicios / Proveedores Manuales',
    Client: 'Clientes',
    Seller: 'Vendedores / Asesores',
    TicketPrinter: 'Tiqueteadores',
    Branch: 'Sucursales',
    Implant: 'Implants',
    Provider: 'Proveedores',
    Prestadora: 'Prestadoras / Hoteles',
    Product: 'Catálogo de Productos',
    User: 'Usuarios del Sistema'
}

const COLUMN_FRIENDLY_NAMES: Record<string, Record<string, string>> = {
    Quotation: {
        id: 'Número de Cotización (ID)',
        internalNumber: 'Código / Número Interno Cotización',
        date: 'Fecha de Cotización',
        state: 'Estado de Cotización',
        currency: 'Moneda',
        exchangeRate: 'Tasa de Cambio',
        baseCommissionable: 'Base Comisionable',
        commissionPercentage: '% Comisión General',
        chargesAndTaxes: 'Total Cargos e Impuestos',
        totalAmount: 'Valor Total Cotización',
        costoTotal: 'Costo Total Cotización',
        valorBase: 'Valor Base',
        utilidad: 'Utilidad Cotización',
        comisionTotalPercentage: '% Comisión Total',
        comisionFreelancePercentage: '% Comisión Freelance',
        comisionFreelanceValue: '$ Comisión Freelance',
        comisionPropiaPercentage: '% Comisión Propia',
        comisionPropiaValue: '$ Comisión Propia',
        comisionUtilidadPercentage: '% Comisión Utilidad',
        destination: 'Destino Principal Viaje',
        startDate: 'Fecha Inicio Viaje',
        endDate: 'Fecha Fin Viaje',
        passenger: 'Pasajero Principal / Titular',
        paxAdults: 'Total Pasajeros Adultos',
        paxChildren: 'Total Pasajeros Niños',
        reservationCode: 'Código Reserva Principal',
        manualDescription: 'Observaciones / Plan de Viaje'
    },
    QuotationProduct: {
        id: 'ID Producto Cotización',
        quantity: 'Cantidad Producto',
        price: 'Precio Venta Unitario',
        cost: 'Costo Unitario',
        checkInDate: 'Fecha Check-In',
        checkOutDate: 'Fecha Check-Out',
        nights: 'Noches de Estadía',
        paxAdults: 'Pasajeros Adultos (Producto)',
        paxChildren: 'Pasajeros Niños (Producto)',
        serviceType: 'Tipo / Clasificación Servicio',
        destination: 'Destino (Producto)',
        reservationCode: 'Código Reserva (Producto)',
        sellerCommission: 'Comisión Vendedor (Producto)',
        ticketPrinterCommission: 'Comisión Tiqueteador (Producto)',
        passenger: 'Pasajeros Asignados (Producto)',
        service: 'Detalle del Servicio',
        description: 'Descripción del Producto',
        providerDueDate: 'Fecha Vencimiento Proveedor',
        providerInvoice: 'Factura Proveedor'
    },
    QuotationManualService: {
        id: 'ID Servicio Manual',
        providerName: 'Nombre del Proveedor (Manual)',
        serviceName: 'Nombre del Servicio / Producto (Manual)',
        cost: 'Costo Unitario (Manual)',
        salePrice: 'Precio Venta Unitario (Manual)',
        utility: 'Utilidad por Servicio (Manual)'
    },
    Client: {
        id: 'ID Cliente',
        name: 'Nombre del Cliente / Razón Social',
        document: 'NIT / Documento Cliente',
        contactInfo: 'Teléfono / Contacto Cliente',
        address: 'Dirección Cliente'
    },
    Seller: {
        id: 'ID Vendedor',
        code: 'Código Vendedor',
        name: 'Nombre Vendedor / Asesor',
        email: 'Email Vendedor'
    },
    TicketPrinter: {
        id: 'ID Tiqueteador',
        code: 'Código Tiqueteador',
        name: 'Nombre Tiqueteador',
        email: 'Email Tiqueteador'
    },
    Branch: {
        id: 'ID Sucursal',
        code: 'Código Sucursal',
        name: 'Nombre Sucursal'
    },
    Implant: {
        id: 'ID Implant',
        code: 'Código Implant',
        name: 'Nombre Implant'
    },
    Provider: {
        id: 'ID Proveedor',
        code: 'NIT / Código Proveedor',
        name: 'Nombre Proveedor',
        contactInfo: 'Teléfono / Contacto Proveedor'
    },
    Prestadora: {
        id: 'ID Prestadora',
        code: 'Código Prestadora / Hotel',
        name: 'Nombre Prestadora / Hotel',
        location: 'Ubicación Prestadora / Hotel',
        category: 'Categoría Prestadora / Hotel'
    },
    Product: {
        id: 'ID Catálogo Producto',
        code: 'Código Producto Catálogo',
        type: 'Tipo / Categoría Producto Catálogo',
        description: 'Descripción Producto Catálogo',
        basePrice: 'Precio Base Catálogo',
        cost: 'Costo Base Catálogo',
        serviceType: 'Servicio Catálogo'
    },
    User: {
        id: 'ID Usuario',
        name: 'Nombre Usuario Creador',
        email: 'Email Usuario Creador'
    }
}

const EXCLUDED_COLUMNS = ['passwordHash', 'resetPasswordToken', 'resetPasswordExpires', 'mandatoryVariables', 'mandatoryFields', 'commissionConfig', 'templateConfig', 'template', 'logo', 'htmlTemplate']

export async function GET() {
    try {
        // 1. Obtener solo las tablas autorizadas del sitio
        const tables: any = await prisma.$queryRawUnsafe(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            AND table_name IN (${ALLOWED_TABLES.map(t => `'${t}'`).join(',')})
        `)

        // 2. Obtener todas las columnas de las tablas permitidas
        const columns: any = await prisma.$queryRawUnsafe(`
            SELECT table_name, column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name IN (${ALLOWED_TABLES.map(t => `'${t}'`).join(',')})
            ORDER BY ordinal_position
        `)

        // 3. Obtener relaciones (Foreign Keys)
        const relations: any = await prisma.$queryRawUnsafe(`
            SELECT
                tc.table_name AS source_table, 
                kcu.column_name AS source_column, 
                ccu.table_name AS target_table,
                ccu.column_name AS target_column
            FROM 
                information_schema.table_constraints AS tc 
                JOIN information_schema.key_column_usage AS kcu
                  ON tc.constraint_name = kcu.constraint_name
                  AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                  ON ccu.constraint_name = tc.constraint_name
                  AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema='public';
        `)

        // Estructurar la metadata para el frontend
        const metadata: Record<string, any> = {}

        tables.forEach((t: any) => {
            const tableName = t.table_name;
            const friendlyTableName = TABLE_FRIENDLY_NAMES[tableName] || tableName;
            const tableCols = COLUMN_FRIENDLY_NAMES[tableName] || {};

            metadata[tableName] = {
                id: tableName,
                name: friendlyTableName,
                columns: columns
                    .filter((c: any) => c.table_name === tableName && !EXCLUDED_COLUMNS.includes(c.column_name))
                    .map((c: any) => ({
                        id: c.column_name,
                        name: tableCols[c.column_name] || c.column_name,
                        type: c.data_type
                    })),
                relations: relations
                    .filter((r: any) => r.source_table === tableName && ALLOWED_TABLES.includes(r.target_table))
                    .map((r: any) => {
                        const targetFriendly = TABLE_FRIENDLY_NAMES[r.target_table] || r.target_table;
                        return {
                            table: r.target_table,
                            alias: `t_${r.target_table.toLowerCase()}`,
                            name: `Relación: ${targetFriendly}`,
                            condition: `{parentAlias}."${r.source_column}" = {alias}."${r.target_column}"`,
                            type: 'LEFT JOIN'
                        };
                    })
            }
        });

        // Asegurar la relación bidireccional entre Quotation y QuotationProduct
        if (metadata['Quotation'] && metadata['QuotationProduct']) {
            const hasProdRel = metadata['Quotation'].relations.some((r: any) => r.table === 'QuotationProduct');
            if (!hasProdRel) {
                metadata['Quotation'].relations.push({
                    table: 'QuotationProduct',
                    alias: 't_quotationproduct',
                    name: 'Relación: Productos de Cotización',
                    condition: '{parentAlias}."id" = {alias}."quotationId"',
                    type: 'LEFT JOIN'
                });
            }
        }

        // Asegurar la relación bidireccional entre Quotation y QuotationManualService
        if (metadata['Quotation'] && metadata['QuotationManualService']) {
            const hasManualRel = metadata['Quotation'].relations.some((r: any) => r.table === 'QuotationManualService');
            if (!hasManualRel) {
                metadata['Quotation'].relations.push({
                    table: 'QuotationManualService',
                    alias: 't_quotationmanualservice',
                    name: 'Relación: Servicios Manuales',
                    condition: '{parentAlias}."id" = {alias}."quotationId"',
                    type: 'LEFT JOIN'
                });
            }
        }

        return NextResponse.json(metadata)
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}
