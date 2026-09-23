import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

const labelsMap: Record<string, Record<string, string>> = {
    Quotation: {
        clientId: 'Cliente',
        sellerId: 'Vendedor',
        branchId: 'Sucursal',
        implantId: 'Implant',
        ticketPrinterId: 'Tiqueteador',
        currency: 'Moneda a Cotizar',
        exchangeRate: 'Tasa de Cambio',
        commissionPercentage: 'Comisión (%)',
        state: 'Estado de Cotización',
        totalAmount: 'Monto Total',
        baseCommissionable: 'Base Comisionable',
        chargesAndTaxes: 'Cargos e Impuestos'
    },
    QuotationProduct: {
        quantity: 'Cantidad',
        price: 'Precio Base',
        providerId: 'Proveedor',
        inNationality: 'Nacionalidad',
        prestadoraId: 'Prestadora',
        checkInDate: 'Check-In',
        checkOutDate: 'Check-Out',
        nights: 'Noches',
        paxAdults: 'Adultos',
        paxChildren: 'Niños',
        destination: 'Destino',
        serviceType: 'Servicio / Tipo',
        reservationCode: 'Código de Reservación',
        sellerCommission: 'Comisión Vendedor',
        ticketPrinterCommission: 'Comisión Tiqueteador',
        mainTaxId: 'Cargo Principal',
        cost: 'Costo',
        service: 'Servicio',
        description: 'Descripción',
        servicios: 'Servicio (Manual)',
        descripcion: 'Descripción (Manual)',
        passengers: 'Pasajeros',
        payments: 'Formas de Pago',
        providerDueDate: 'Fecha Vencimiento Proveedor',
        providerInvoice: 'Factura Proveedor'
    }
}

function formatFieldName(name: string): string {
    return name
        .replace(/([A-Z])/g, ' $1')
        .replace(/_/g, ' ')
        .replace(/^\w/, c => c.toUpperCase())
        .trim()
}

export async function GET(req: NextRequest) {
    try {
        const runtime = (prisma as any)._runtimeDataModel
        const quotationFields: any[] = []
        const quotationProductFields: any[] = []

        const quotationExclude = ['id', 'date', 'userId', 'internalNumber']
        const quotationProductExclude = ['id', 'quotationId', 'productId', 'comboId']

        if (runtime && runtime.models) {
            // Extract Quotation fields
            if (runtime.models.Quotation && Array.isArray(runtime.models.Quotation.fields)) {
                runtime.models.Quotation.fields.forEach((f: any) => {
                    if (f.kind === 'scalar' && !quotationExclude.includes(f.name)) {
                        const label = labelsMap.Quotation[f.name] || formatFieldName(f.name)
                        quotationFields.push({
                            name: f.name,
                            label,
                            model: 'Quotation',
                            type: f.type
                        })
                    }
                })
            }

            // Extract QuotationProduct fields
            if (runtime.models.QuotationProduct && Array.isArray(runtime.models.QuotationProduct.fields)) {
                runtime.models.QuotationProduct.fields.forEach((f: any) => {
                    if ((f.kind === 'scalar' && !quotationProductExclude.includes(f.name)) || f.name === 'passengers' || f.name === 'payments') {
                        const label = labelsMap.QuotationProduct[f.name] || formatFieldName(f.name)
                        quotationProductFields.push({
                            name: f.name,
                            label,
                            model: 'QuotationProduct',
                            type: f.type
                        })
                    }
                })
            }
        }

        // Fallback in case runtime model is not loaded/available or empty
        if (quotationFields.length === 0) {
            Object.keys(labelsMap.Quotation).forEach(name => {
                quotationFields.push({
                    name,
                    label: labelsMap.Quotation[name],
                    model: 'Quotation',
                    type: 'String' // generic fallback type
                })
            })
        }

        if (quotationProductFields.length === 0) {
            Object.keys(labelsMap.QuotationProduct).forEach(name => {
                quotationProductFields.push({
                    name,
                    label: labelsMap.QuotationProduct[name],
                    model: 'QuotationProduct',
                    type: 'String' // generic fallback type
                })
            })
        }

        return NextResponse.json({
            quotationFields,
            quotationProductFields
        })
    } catch (error: any) {
        console.error('Error fetching quotation fields:', error)
        return NextResponse.json({
            message: 'Error fetching quotation fields',
            detail: error?.message || String(error)
        }, { status: 500 })
    }
}
