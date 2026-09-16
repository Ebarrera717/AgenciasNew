import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { executeSQLServerProcedure, isSQLServerMode } from '@/lib/sqlserver';

export const dynamic = 'force-dynamic';

export async function GET(req: NextRequest, { params }: { params: Promise<{ code: string }> }) {
    try {
        const { code } = await params;
        if (!code) {
            return NextResponse.json({ message: 'Código de trazabilidad obligatorio' }, { status: 400 });
        }

        let logs: any[] = [];
        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spTraceabilityGetDetails', {
                p_code: code
            });
            logs = Array.isArray(results) ? results : [];
        } else {
            logs = await prisma.$queryRawUnsafe(
                `SELECT * FROM public."spTraceabilityGetDetails"($1)`,
                code
            );
        }

        if (logs.length === 0) {
            return NextResponse.json({ message: `No se encontraron eventos para el código ${code}` }, { status: 404 });
        }

        const first = logs[0];
        const last = logs[logs.length - 1];
        const totalDurationMs = logs.reduce((acc, l) => acc + (l.durationMs || 0), 0);
        const hasError = logs.some(l => l.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(l.eventType));

        const summary = {
            traceCode: code,
            user: first?.username || first?.userName || 'Sistema / Anónimo',
            userId: first?.userId || first?.userid || null,
            totalEvents: logs.length,
            totalDurationMs,
            status: hasError ? 'ERROR' : 'SUCCESS',
            startTime: first?.createdAt || first?.createdat || null,
            endTime: last?.createdAt || last?.createdat || null,
            errorCount: logs.filter(l => l.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(l.eventType)).length
        };

        return NextResponse.json({
            summary,
            logs
        });
    } catch (error: any) {
        console.error('[TRACEABILITY_DETAILS_API_ERROR]', error);
        return NextResponse.json({ message: 'Error al consultar detalle de trazabilidad', error: error.message }, { status: 500 });
    }
}
