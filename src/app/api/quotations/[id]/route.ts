import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection, executeSQLServerProcedure } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            const req = pool.request();
            req.input('p_id', id);
            const result = await req.execute('spCotizacionObtener');
            await pool.close();

            const row = result.recordset?.[0];
            if (!row || row.mensaje) {
                return NextResponse.json({ message: 'Cotización no encontrada' }, { status: 404 });
            }

            const parseJson = (val: any) => {
                if (!val) return null;
                if (typeof val === 'object') return val;
                try { return JSON.parse(val); } catch (e) { return null; }
            };

            const parsedQuotation = {
                ...row,
                client: parseJson(row.clientJson),
                seller: parseJson(row.sellerJson),
                branch: parseJson(row.branchJson),
                implant: parseJson(row.implantJson),
                ticketPrinter: parseJson(row.ticketPrinterJson),
                products: (parseJson(row.productsJson) || []).map((p: any) => ({
                    ...p,
                    product: parseJson(p.productJson),
                    provider: parseJson(p.providerJson),
                    prestadora: parseJson(p.prestadoraJson),
                    passengers: parseJson(p.passengersJson) || [],
                    variables: parseJson(p.variablesJson) || [],
                    appliedTaxes: parseJson(p.appliedTaxesJson) || [],
                    payments: parseJson(p.paymentsJson) || []
                })),
                combos: parseJson(row.combosJson) || [],
                manualServices: parseJson(row.manualServicesJson) || [],
                stateHistory: parseJson(row.stateHistoryJson) || []
            };

            return NextResponse.json(parsedQuotation);
        }

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

        let message: string = '';
        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spCotizacionActualizar', {
                p_id: id,
                p_data: JSON.stringify(body),
                p_acting_user_id: actingUserId
            });
            message = Array.isArray(results) ? results[0]?.p_mensaje_resultado || '' : '';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spCotizacionActualizar"($1::INT, $2::JSONB, $3::INT, $4::TEXT)`,
                id,
                JSON.stringify(body),
                actingUserId,
                '' // p_mensaje_resultado
            );
            message = results[0]?.p_mensaje_resultado || '';
        }
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

        let message: string = '';
        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spCotizacionEliminar', {
                p_id: id,
                p_acting_user_id: actingUserId
            });
            message = Array.isArray(results) ? results[0]?.p_mensaje_resultado || '' : '';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spCotizacionEliminar"($1::INT, $2::INT, $3::TEXT)`,
                id,
                actingUserId,
                '' // p_mensaje_resultado
            );
            message = results[0]?.p_mensaje_resultado || '';
        }
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
