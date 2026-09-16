import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { executeSQLServerProcedure, isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import { getTraceabilityMode, recordTraceEvent } from '@/lib/traceability';

export const dynamic = 'force-dynamic';

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const code = searchParams.get('code') || '';
        const module = searchParams.get('module') || '';
        const status = searchParams.get('status') || '';
        const userId = searchParams.get('userId') ? parseInt(searchParams.get('userId')!, 10) : null;
        const startDate = searchParams.get('startDate') || null;
        const endDate = searchParams.get('endDate') || null;

        const currentMode = await getTraceabilityMode();

        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spTraceabilityList', {
                p_code: code || null,
                p_user_id: userId || null,
                p_module: module || null,
                p_status: status || null,
                p_start_date: startDate || null,
                p_end_date: endDate || null
            });
            return NextResponse.json({
                mode: currentMode,
                data: Array.isArray(results) ? results : []
            });
        }

        const rows: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public."spTraceabilityList"($1, $2, $3, $4, $5::timestamp, $6::timestamp)`,
            code || null,
            userId || null,
            module || null,
            status || null,
            startDate || null,
            endDate || null
        );

        return NextResponse.json({
            mode: currentMode,
            data: rows
        });
    } catch (error: any) {
        console.error('[TRACEABILITY_API_GET_ERROR]', error);
        return NextResponse.json({ message: 'Error al consultar trazabilidad', error: error.message }, { status: 500 });
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json();

        // 1. Cambiar modo de trazabilidad
        if (body.mode) {
            const newMode = (body.mode || 'OFF').toUpperCase();
            if (!['OFF', 'BASIC', 'DETAILED', 'DIAGNOSTIC'].includes(newMode)) {
                return NextResponse.json({ message: 'Modo de trazabilidad no válido' }, { status: 400 });
            }

            if (isSQLServerMode()) {
                let pool;
                try {
                    pool = await getSQLServerConnection();
                    await pool.request().query(`
                        IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE UPPER([code]) = 'TRACEABILITY_MODE')
                            UPDATE dbo.[SystemParameter] SET [value] = '${newMode}' WHERE UPPER([code]) = 'TRACEABILITY_MODE';
                        ELSE
                            INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
                            VALUES ('TRACEABILITY_MODE', N'Modo de Trazabilidad y Diagnóstico', '${newMode}');
                    `);
                    await pool.close();
                } catch (e: any) {
                    if (pool) await pool.close();
                    throw e;
                }
            } else {
                await prisma.systemParameter.upsert({
                    where: { code: 'TRACEABILITY_MODE' },
                    create: {
                        code: 'TRACEABILITY_MODE',
                        name: 'Modo de Trazabilidad y Diagnóstico',
                        value: newMode
                    },
                    update: { value: newMode }
                });
            }

            return NextResponse.json({ message: `Modo de trazabilidad actualizado a ${newMode}`, mode: newMode });
        }

        // 2. Registrar evento desde frontend/cliente
        const traceCode = await recordTraceEvent({
            code: body.code,
            userId: body.userId || null,
            module: body.module || 'FRONTEND',
            screen: body.screen || 'SETTINGS',
            action: body.action || 'ACCION',
            process: body.process || null,
            eventType: body.eventType || 'ACCION_USUARIO',
            stepName: body.stepName || 'Interacción de usuario',
            endpoint: body.endpoint || null,
            durationMs: body.durationMs || 0,
            status: body.status || 'SUCCESS',
            inputData: body.inputData || null,
            outputData: body.outputData || null,
            techMessage: body.techMessage || null,
            functionalMessage: body.functionalMessage || null,
            stackTrace: body.stackTrace || null,
            affectedId: body.affectedId || null
        });

        return NextResponse.json({ message: 'Evento de traza registrado', code: traceCode });
    } catch (error: any) {
        console.error('[TRACEABILITY_API_POST_ERROR]', error);
        return NextResponse.json({ message: 'Error al procesar solicitud de trazabilidad', error: error.message }, { status: 500 });
    }
}
