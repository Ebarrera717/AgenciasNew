import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spTicketTypeListar');
                await pool.close();
                return NextResponse.json(res.recordset || []);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const ticketTypes = await prisma.ticketType.findMany({
            where: { isActive: true },
            orderBy: { name: 'asc' }
        })

        return NextResponse.json(ticketTypes)
    } catch (error: any) {
        console.error('Error fetching ticket types:', error)
        return NextResponse.json(
            { message: 'Error al obtener los tipos de tiquete', error: error.message },
            { status: 500 }
        )
    }
}
