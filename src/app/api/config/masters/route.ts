import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spMasterListar');
                await pool.close();
                return NextResponse.json(res.recordset || []);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const result = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnMasterList"()`)
        return NextResponse.json(result)
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}
