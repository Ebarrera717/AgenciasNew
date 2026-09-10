import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function GET(req: Request) {
    try {
        const { searchParams } = new URL(req.url);
        const table = searchParams.get('table');

        if (!table) {
            return NextResponse.json({ error: 'Table is required' }, { status: 400 });
        }

        // Sanitize table name (letters/numbers/underscores only)
        const cleanTable = table.replace(/[^a-zA-Z0-9_]/g, '');

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`SELECT * FROM dbo.[${cleanTable}] ORDER BY id ASC`);
                await pool.close();
                return NextResponse.json(res.recordset);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results = await prisma.$queryRawUnsafe(`SELECT * FROM public."${cleanTable}" ORDER BY id ASC`);
        return NextResponse.json(results);
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
