import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const quotation = await prisma.quotation.findUnique({
            where: { id },
            include: {
                client: true,
                seller: true,
                branch: true,
                implant: true,
                ticketPrinter: true,
                manualServices: true,
                products: {
                    include: {
                        appliedTaxes: true,
                        passengers: true,
                        variables: true,
                        payments: true,
                        product: true,
                        provider: true,
                        prestadora: true
                    }
                },
                combos: {
                    include: {
                        combo: {
                            include: {
                                products: {
                                    include: {
                                        product: true,
                                        appliedTaxes: {
                                            include: { chargeAndTax: true }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } as any
        })

        if (!quotation) {
            return NextResponse.json({ message: 'Cotización no encontrada' }, { status: 404 })
        }

        let stateHistory: any[] = [];
        try {
            stateHistory = await prisma.$queryRawUnsafe(
                `SELECT * FROM public.fn_obtener_historial_estados($1::INT)`,
                id
            );
        } catch (shErr: any) {
            console.warn('Warning: Could not fetch stateHistory for quotation ' + id + ':', shErr.message);
        }

        return NextResponse.json({
            ...quotation,
            stateHistory
        })
    } catch (error: any) {
        console.error('Error fetching quotation:', error)
        return NextResponse.json({ message: 'Error interno del servidor', error: error.message }, { status: 500 })
    }
}

export async function PUT(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const body = await request.json()
        const userIdHeader = request.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCotizacionActualizar"($1::INT, $2::JSONB, $3::INT, $4::TEXT)`,
            id,
            JSON.stringify(body),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE',
                module: 'QUOTATION',
                description: `Cotización ${id} actualizada (SP). ${message}`,
                metadata: { id }
            });
        });

        return NextResponse.json({ message: message || 'Cotización actualizada', quotation: { id } })
    } catch (error: any) {
        console.error('Error updating quotation (PUT):', error)
        return NextResponse.json({ message: 'Error al actualizar la cotización: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) {
            return NextResponse.json({ message: 'ID de cotización inválido' }, { status: 400 })
        }

        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCotizacionEliminar"($1::INT, $2::INT, $3::TEXT)`,
            id,
            actingUserId,
            '' // p_mensaje_resultado
        )

        const message = results[0]?.p_mensaje_resultado || ''
        if (message.startsWith('ERROR')) {
            throw new Error(message)
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'DELETE',
                module: 'QUOTATION',
                description: `Cotización ${id} eliminada (SP). ${message}`,
                metadata: { id }
            });
        });

        return NextResponse.json({ message: message || 'Cotización eliminada con éxito' })
    } catch (error: any) {
        console.error('Error deleting quotation:', error)
        return NextResponse.json({ message: 'Error al eliminar la cotización: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
