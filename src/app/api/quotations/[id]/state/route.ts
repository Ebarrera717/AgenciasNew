import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

export async function PUT(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const body = await request.json()
        const { state, description } = body
        const userIdHeader = request.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCotizacionActualizarEstadoManual"($1::INT, $2::TEXT, $3::TEXT, $4::INT, $5::TEXT)`,
            id,
            state,
            description || null,
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
                action: 'UPDATE_STATE',
                module: 'QUOTATION',
                description: `Se actualizó el estado de la cotización #${id} a ${state}. Descripción: ${description || ''}`,
                metadata: { id, state, description }
            });
        });

        return NextResponse.json({ message: message || 'Estado de cotización actualizado', quotation: { id } })
    } catch (error: any) {
        console.error('Error updating quotation state:', error)
        return NextResponse.json({ message: 'Error al cambiar estado: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
