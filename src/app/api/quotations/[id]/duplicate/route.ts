import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function POST(
    req: NextRequest,
    context: { params: Promise<{ id: string }> }
) {
    try {
        const { id: paramId } = await context.params
        const quotationId = parseInt(paramId)
        if (isNaN(quotationId)) {
            return NextResponse.json({ message: 'ID de cotización inválido' }, { status: 400 })
        }

        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        let newQuotationId: number | null = null;
        let message: string = '';
        let internalNumber: string | null = null;

        if (isSQLServerMode()) {
            const { executeSQLServerProcedure } = await import('@/lib/sqlserver');
            const results = await executeSQLServerProcedure('spCotizacionDuplicar', {
                p_quotation_id: quotationId,
                p_acting_user_id: actingUserId
            });
            const row = Array.isArray(results) ? results[0] : {};
            newQuotationId = row?.p_new_quotation_id || null;
            message = row?.p_mensaje_resultado || '';
            internalNumber = row?.internalNumber || null;
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spCotizacionDuplicar"($1::INT, $2::INT, $3::INT, $4::TEXT)`,
                quotationId,
                actingUserId,
                0, // p_new_quotation_id
                '' // p_mensaje_resultado
            );

            newQuotationId = results[0]?.p_new_quotation_id;
            message = results[0]?.p_mensaje_resultado || '';
            if (newQuotationId) {
                const qRow = await prisma.quotation.findUnique({
                    where: { id: newQuotationId },
                    select: { internalNumber: true }
                });
                internalNumber = qRow?.internalNumber || null;
            }
        }

        if (!newQuotationId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error al duplicar la cotización');
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'DUPLICATE',
                module: 'QUOTATION',
                description: `Cotización ${quotationId} duplicada exitosamente generando la nueva cotización ${internalNumber ? internalNumber + ' (ID ' + newQuotationId + ')' : 'ID ' + newQuotationId}. ${message}`,
                metadata: { originalQuotationId: quotationId, newQuotationId, internalNumber }
            });
        });

        return NextResponse.json({
            message: message || `Cotización duplicada con éxito con ID ${newQuotationId}`,
            newQuotationId,
            internalNumber
        })
    } catch (error: any) {
        console.error('Error duplicando cotización (POST):', error)
        return NextResponse.json({
            message: 'Error al duplicar la cotización: ' + (error.message || 'Error desconocido')
        }, { status: 500 })
    }
}
