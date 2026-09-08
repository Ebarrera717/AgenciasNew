import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCotizacionCrear"($1::JSONB, $2::INT, $3::INT, $4::TEXT)`,
            JSON.stringify(body),
            actingUserId,
            0, // p_quotation_id
            '' // p_mensaje_resultado
        );

        const dbQuotationId = results[0]?.p_quotation_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbQuotationId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating quotation');
        }

        const quotation = { id: dbQuotationId };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'CREATE',
                module: 'QUOTATION',
                description: `Cotización ${dbQuotationId} creada (SP). ${message}`,
                metadata: { id: dbQuotationId }
            });
        });

        const finalMessage = message && message !== '' ? message : 'SUCCESS: Cotización creada correctamente con ID ' + dbQuotationId;
        return NextResponse.json({ message: finalMessage, quotation })
    } catch (error: any) {
        console.error('Error saving quotation (POST):', error)
        return NextResponse.json({ message: 'Error al guardar la cotización: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
