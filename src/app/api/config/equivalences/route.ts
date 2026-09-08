import { paginateArray } from '@/lib/pagination'
import { NextResponse, NextRequest } from 'next/server'
import prisma from '@/lib/prisma'

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id_interfaces = searchParams.get('id_interfaces') || 'NULL'
        const id_master = searchParams.get('id_master') || 'NULL'

        const result = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnEquivalencesInterfacesConsultar"(${id_interfaces}, ${id_master})`)
        return NextResponse.json(paginateArray(req, result as any[], (e: any) => [e.cd_maestro, e.cd_codigo, e.cd_codigointe, e.interfaceName, e.masterName]))
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function POST(req: Request) {
    try {
        const body = await req.json()
        const userId = req.headers.get('X-User-Id') || '1'
        const { id_interfaces, id_master, cd_maestro, cd_codigo, cd_codigoInte } = body

        await prisma.$executeRawUnsafe(
            `CALL public."spEquivalencesInterfacesCrear"($1, $2, $3, $4, $5, $6, $7)`,
            Number(id_interfaces), Number(id_master), cd_maestro, cd_codigo, cd_codigoInte || '', Number(userId), null
        )
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function PUT(req: Request) {
    try {
        const body = await req.json()
        const { id, id_interfaces, id_master, cd_maestro, cd_codigo, cd_codigoInte } = body

        if (!id) return NextResponse.json({ message: 'ID required' }, { status: 400 })

        // No hay un procedure de actualizar, por lo tanto usamos un update directo temporalmente
        // hasta que se cree spEquivalencesInterfacesActualizar en DB
        await prisma.$executeRawUnsafe(
            `UPDATE public."EquivalencesInterfaces" 
             SET id_interfaces = $1, id_master = $2, cd_maestro = $3, cd_codigo = $4, "cd_codigointe" = $5 
             WHERE id = $6`,
            Number(id_interfaces), Number(id_master), cd_maestro, cd_codigo, cd_codigoInte || '', Number(id)
        )
        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."EquivalencesInterfaces" SET "isActive" = $1 WHERE id = $2`, isAct, Number(id));
        }
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function DELETE(req: Request) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userId = req.headers.get('X-User-Id') || '1'

        if (!id) return NextResponse.json({ message: 'ID required' }, { status: 400 })

        await prisma.$executeRawUnsafe(`CALL public."spEquivalencesInterfacesEliminar"($1, $2, $3)`, Number(id), Number(userId), null)
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}
