import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

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

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCotizacionDuplicar"($1::INT, $2::INT, $3::INT, $4::TEXT)`,
            quotationId,
            actingUserId,
            0, // p_new_quotation_id
            '' // p_mensaje_resultado
        );

        const newQuotationId = results[0]?.p_new_quotation_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!newQuotationId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error al duplicar la cotización');
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'DUPLICATE',
                module: 'QUOTATION',
                description: `Cotización ${quotationId} duplicada exitosamente generando la nueva cotización ID ${newQuotationId}. ${message}`,
                metadata: { originalQuotationId: quotationId, newQuotationId }
            });
        });

        return NextResponse.json({
            message: message || `Cotización duplicada con éxito con ID ${newQuotationId}`,
            newQuotationId
        })
    } catch (error: any) {
        console.error('Error duplicando cotización (POST):', error)
        return NextResponse.json({
            message: 'Error al duplicar la cotización: ' + (error.message || 'Error desconocido')
        }, { status: 500 })
    }
}
