import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { executeSQLServerProcedure, isSQLServerMode } from '@/lib/sqlserver';

export const dynamic = 'force-dynamic';

export async function POST(req: NextRequest) {
    try {
        const body = await req.json();
        const days = body.days ? parseInt(body.days, 10) : 30;

        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spTraceabilityClean', {
                p_days: days
            });
            const row = Array.isArray(results) ? results[0] : {};
            return NextResponse.json({
                message: row?.p_mensaje_resultado || 'Depuración de trazabilidad finalizada en SQL Server'
            });
        }

        const result: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spTraceabilityClean"($1::INT, $2::TEXT)`,
            days,
            null
        );

        const rowData = result && result.length > 0 ? result[0] : null;
        const dbMessage = (rowData?.p_mensaje_resultado || rowData?.mensaje_resultado || 'Depuración finalizada en PostgreSQL') as string;

        return NextResponse.json({ message: dbMessage });
    } catch (error: any) {
        console.error('[TRACEABILITY_CLEAN_API_ERROR]', error);
        return NextResponse.json({ message: 'Error al ejecutar depuración de trazabilidad', error: error.message }, { status: 500 });
    }
}
