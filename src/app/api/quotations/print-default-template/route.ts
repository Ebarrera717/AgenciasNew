import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

// Helper for formatting currency like in export-excel
function formatCurrency(val: number) {
    if (val === null || val === undefined) return '0'
    return val.toLocaleString('es-CO', { minimumFractionDigits: 0, maximumFractionDigits: 0 })
}

function formatDate(dStr: any) {
    if (!dStr) return ''
    const d = new Date(dStr)
    return isNaN(d.getTime()) ? String(dStr) : d.toLocaleDateString()
}

// GET: Obtener la plantilla por defecto del sistema
export async function GET(req: NextRequest) {
    try {
        const template = await prisma.quotationPrintDefaultTemplate.findFirst({
            orderBy: { id: 'asc' }
        })
        return NextResponse.json({ html: template?.html || null, updatedAt: template?.updatedAt || null })
    } catch (error: any) {
        console.error('Error fetching print default template:', error)
        return NextResponse.json({ message: 'Error al obtener plantilla predeterminada', error: error.message }, { status: 500 })
    }
}

// POST: Guardar o actualizar la plantilla por defecto a partir de un HTML editado
export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { quotationId, html } = body

        if (!html || typeof html !== 'string') {
            return NextResponse.json({ message: 'html es requerido' }, { status: 400 })
        }

        let templateHtml = html;

        // Ensure table exists defensively before querying/upserting
        await prisma.$executeRawUnsafe(`
            CREATE TABLE IF NOT EXISTS public."QuotationPrintDefaultTemplate" (
                id SERIAL PRIMARY KEY,
                "html" text NOT NULL,
                "name" character varying(100) DEFAULT 'Default'::character varying,
                "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
                "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
            );
        `).catch(err => console.warn('Warning creating QuotationPrintDefaultTemplate table:', err));

        // Si se proporciona un quotationId, revertimos los valores específicos de esa cotización a marcadores {{key}}
        if (quotationId) {
            const idNum = parseInt(quotationId)
            if (!isNaN(idNum)) {
                try {
                    const rows: any[] = await prisma.$queryRawUnsafe('SELECT * FROM public."fnRptCotizacion"($1, $2)', idNum, idNum)
                    if (rows && rows.length > 0) {
                        const q = rows[0]

                        // Calcular totales de la cotización
                        const totalTarifaNeta = rows.reduce((sum, p) => sum + (p.tarifaNeta || 0), 0)
                        const totalImpuestos = rows.reduce((sum, p) => sum + (p.impuestos || 0), 0)
                        const totalAdicionales = rows.reduce((sum, p) => sum + (p.adicionalesServ || 0), 0)
                        const totalComision = rows.reduce((sum, p) => sum + (p.comision || 0), 0)
                        const totalDescuento = rows.reduce((sum, p) => sum + (p.descuento || 0), 0)
                        const totalSobrecomision = rows.reduce((sum, p) => sum + (p.sobrecomision || 0), 0)
                        const totalFee = rows.reduce((sum, p) => sum + (p.fee || 0), 0)
                        const totalGeneral = rows.reduce((sum, p) => sum + (p.total || 0), 0)

                        // Reemplazos ordenados por especificidad (strings más largos primero)
                        const replacements: Array<[string, string]> = [
                            [q.clienteNombre, '{{clienteNombre}}'],
                            [q.clienteIdentificacion, '{{clienteIdentificacion}}'],
                            [q.clienteDireccion, '{{clienteDireccion}}'],
                            [q.clienteTelefono, '{{clienteTelefono}}'],
                            [q.descripcionPlan, '{{descripcionPlan}}'],
                            [q.fechasViaje, '{{fechasViaje}}'],
                            [q.hotelesServicios, '{{hotelesServicios}}'],
                            [q.pasajeros, '{{pasajeros}}'],
                            [q.observaciones, '{{observaciones}}'],
                            [q.vendedor, '{{vendedor}}'],
                            [q.asesor, '{{asesor}}'],
                            [q.internalNumber, '{{internalNumber}}'],
                            [formatDate(q.fecha), '{{fecha}}'],
                            [formatCurrency(totalGeneral), '{{total}}'],
                            [formatCurrency(totalGeneral - totalComision), '{{totalPago}}'],
                            [formatCurrency(totalTarifaNeta), '{{tarifaNeta}}'],
                            [formatCurrency(totalTarifaNeta - totalComision), '{{tarifaNetaPago}}'],
                            [formatCurrency(totalImpuestos), '{{impuestos}}'],
                            [formatCurrency(totalImpuestos), '{{impuestosPago}}'],
                            [formatCurrency(totalAdicionales), '{{adicionalesServ}}'],
                            [formatCurrency(totalAdicionales), '{{adicionalesServPago}}'],
                            [formatCurrency(totalComision), '{{comision}}'],
                            [formatCurrency(totalDescuento), '{{descuento}}'],
                            [formatCurrency(totalSobrecomision), '{{sobrecomision}}'],
                            [formatCurrency(totalFee), '{{fee}}'],
                            [formatCurrency(q.totalAmount), '{{totalAmount}}'],
                            [formatCurrency(q.costoTotal), '{{costoTotal}}'],
                            [formatCurrency(q.valorBase), '{{valorBase}}'],
                            [formatCurrency(q.utilidad), '{{utilidad}}'],
                            [formatCurrency(q.baseCommissionable), '{{baseComisionable}}'],
                            [formatCurrency(q.comisionAsesor), '{{comisionAsesor}}'],
                            [formatCurrency(q.baseCommissionable - q.comisionAsesor), '{{baseComisionTop}}'],
                            [formatCurrency(q.comisionFreelanceValue), '{{comisionFreelanceValue}}'],
                            [formatCurrency(q.comisionPropiaValue), '{{comisionPropiaValue}}'],
                            [String(q.comisionFreelancePercentage), '{{comisionFreelancePercentage}}'],
                            [String(q.comisionPropiaPercentage), '{{comisionPropiaPercentage}}'],
                            [String(q.comisionUtilidadPercentage), '{{comisionUtilidadPercentage}}'],
                            [String(q.totalAdultos), '{{totalAdultos}}'],
                            [String(q.totalNinos), '{{totalNinos}}'],
                            [String(q.tCambio || 1), '{{tCambio}}'],
                            [String(q.idCotizacion), '{{idCotizacion}}']
                        ]

                        for (const [val, placeholder] of replacements) {
                            if (val && typeof val === 'string' && val.trim().length > 0 && val !== placeholder) {
                                if (val.trim() === '0' || val.trim() === '1') {
                                    templateHtml = templateHtml.split(`>${val}<`).join(`>${placeholder}<`)
                                } else {
                                    templateHtml = templateHtml.split(val).join(placeholder)
                                }
                            }
                        }
                    }
                } catch (fnErr: any) {
                    console.warn('Warning querying fnRptCotizacion for template placeholders:', fnErr);
                }
            }
        }

        // Upsert el primer registro en QuotationPrintDefaultTemplate
        const existing = await prisma.quotationPrintDefaultTemplate.findFirst({ orderBy: { id: 'asc' } })

        let result
        if (existing) {
            result = await prisma.quotationPrintDefaultTemplate.update({
                where: { id: existing.id },
                data: { html: templateHtml, updatedAt: new Date() }
            })
        } else {
            result = await prisma.quotationPrintDefaultTemplate.create({
                data: { html: templateHtml, name: 'Default' }
            })
        }

        return NextResponse.json({
            message: 'Plantilla por defecto guardada correctamente',
            id: result.id
        })
    } catch (error: any) {
        console.error('Error saving print default template:', error)
        return NextResponse.json({ message: 'Error al guardar la plantilla predeterminada', error: error.message }, { status: 500 })
    }
}

// DELETE: Restablecer la plantilla por defecto borrando la plantilla personalizada maestra
export async function DELETE(req: NextRequest) {
    try {
        await prisma.quotationPrintDefaultTemplate.deleteMany()
        return NextResponse.json({ message: 'Plantilla por defecto restablecida correctamente' })
    } catch (error: any) {
        console.error('Error deleting print default template:', error)
        return NextResponse.json({ message: 'Error al restablecer la plantilla predeterminada', error: error.message }, { status: 500 })
    }
}
