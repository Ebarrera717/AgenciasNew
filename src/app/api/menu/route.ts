import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spMenuListar');
                await pool.close();
                const items = (res.recordset || []).filter((r: any) => r.activo === true || r.activo === 1 || r.activo === 'true');
                return NextResponse.json(items);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        // Query using fnMenu() function
        const menuItems: any[] = await prisma.$queryRawUnsafe(`SELECT * FROM public.fnMenu()`)
        return NextResponse.json(menuItems)
    } catch (error: any) {
        console.error('Error executing fnMenu():', error)
        try {
            // Fallback: direct table query
            const fallbackItems = await prisma.menu.findMany({
                where: { activo: true },
                orderBy: { id: 'asc' }
            })
            return NextResponse.json(fallbackItems)
        } catch (fallbackErr: any) {
            console.error('Error fetching menu items:', fallbackErr)
            return NextResponse.json({ message: 'Error fetching menu' }, { status: 500 })
        }
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, name, parent, action, activo } = body

        const menuItem = await prisma.menu.create({
            data: {
                code,
                name,
                parent: parent ? Number(parent) : null,
                action,
                activo: activo ?? true
            }
        })
        return NextResponse.json(menuItem)
    } catch (error: any) {
        console.error('Error creating menu item:', error)
        return NextResponse.json({ message: error.message || 'Error creating menu item' }, { status: 500 })
    }
}
