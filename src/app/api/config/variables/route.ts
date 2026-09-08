import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        const variables = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnVariableListar()`)
        return NextResponse.json(paginateArray(req, variables, v => [v.code, v.name]))
    } catch (error) {
        return NextResponse.json({ message: 'Error fetching variables' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isForAll = body.isForAllClients !== undefined ? Boolean(body.isForAllClients) : false
        
        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spVariableCrear($1::TEXT, $2::TEXT, $3::INT, $4::INT, $5::TEXT, $6::BOOLEAN)`,
            body.code,
            body.name,
            actingUserId,
            0, // p_variable_id
            '', // p_mensaje_resultado
            isForAll
        );

        const dbId = results[0]?.p_variable_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating variable');
        }

        const variable = { id: dbId, ...body, isForAllClients: isForAll };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Variable ${variable.name} creada (SP).`, metadata: variable });
        });

        return NextResponse.json(variable)
    } catch (error: any) {
        console.error('Error creating variable:', error);
        return NextResponse.json({ message: 'Error al crear variable: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isForAll = body.isForAllClients !== undefined ? Boolean(body.isForAllClients) : false
        
        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spVariableActualizar($1::INT, $2::TEXT, $3::TEXT, $4::INT, $5::TEXT, $6::BOOLEAN)`,
            parseInt(body.id),
            body.code,
            body.name,
            actingUserId,
            '', // p_mensaje_resultado
            isForAll
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."MasterVariable" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(body.id));
        }

        if (body.isForAllClients !== undefined) {
            await prisma.$executeRawUnsafe(`UPDATE public."MasterVariable" SET "isForAllClients" = $1 WHERE id = $2`, Boolean(body.isForAllClients), parseInt(body.id));
        }

        const variable = { ...body, isForAllClients: isForAll };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Variable ${variable.name} actualizada (SP).`, metadata: variable });
        });

        return NextResponse.json(variable)
    } catch (error: any) {
        console.error('Error updating variable:', error);
        return NextResponse.json({ message: 'Error al actualizar variable: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        if (!id) return NextResponse.json({ message: 'ID is required' }, { status: 400 })

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spVariableEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Variable con ID ${id} eliminada (SP).` });
        });

        return NextResponse.json({ message: 'Variable deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting variable:', error);
        return NextResponse.json({ message: 'Error al eliminar variable: ' + error.message }, { status: 500 })
    }
}
