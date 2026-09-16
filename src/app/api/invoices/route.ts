import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
    const startTime = Date.now()
    const traceCode = generateTraceCode()
    let actingUserId = 1

    try {
        const body = await req.json()
        console.log("POST INVOICE BODY:", JSON.stringify(body, null, 2));
        const userIdHeader = req.headers.get('X-User-Id')
        actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Creación de Factura',
            action: 'CREAR_FACTURA',
            process: 'Guardado de Factura',
            eventType: 'INICIO_PROCESO',
            stepName: 'Recepción y Validación de Payload',
            endpoint: '/api/invoices',
            inputData: body,
            status: 'IN_PROGRESS'
        });

        let dbInvoiceId: number | null = null;
        let message: string = '';

        if (isSQLServerMode()) {
            console.log('[INVOICE_POST] Modo SQL Server activo. Ejecutando spInvoicesCrear nativo T-SQL...');
            const { executeSQLServerProcedure } = await import('@/lib/sqlserver');

            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Creación de Factura',
                action: 'CREAR_FACTURA',
                process: 'Ejecución SP T-SQL',
                eventType: 'SP_INICIO',
                stepName: 'Invocación spInvoicesCrear (SQL Server)',
                spName: 'spInvoicesCrear',
                endpoint: '/api/invoices',
                status: 'IN_PROGRESS'
            });

            const results = await executeSQLServerProcedure('spInvoicesCrear', {
                p_data: JSON.stringify(body),
                p_acting_user_id: actingUserId
            });
            const row = Array.isArray(results) ? results[0] : {};
            dbInvoiceId = row?.p_invoice_id || null;
            message = row?.p_mensaje_resultado || '';
        } else {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Creación de Factura',
                action: 'CREAR_FACTURA',
                process: 'Ejecución SP PostgreSQL',
                eventType: 'SP_INICIO',
                stepName: 'Invocación spInvoicesCrear (PostgreSQL)',
                spName: 'spInvoicesCrear',
                endpoint: '/api/invoices',
                status: 'IN_PROGRESS'
            });

            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public.spInvoicesCrear($1::JSONB, $2::INT, $3::INT, $4::TEXT)`,
                JSON.stringify(body),
                actingUserId,
                0, // p_invoice_id
                '' // p_mensaje_resultado
            );

            dbInvoiceId = results[0]?.p_invoice_id;
            message = results[0]?.p_mensaje_resultado || '';

            if (dbInvoiceId && Array.isArray(body.items)) {
                for (const item of body.items) {
                    const bProdId = item.bookingProductId || (item.isGDS ? item.id : null);
                    if (bProdId && !isNaN(parseInt(bProdId))) {
                        try {
                            await prisma.$queryRawUnsafe(
                                `UPDATE public."BookingProductGDS" 
                                 SET "state" = 'FACTURADO', "invoiceId" = $1 
                                 WHERE id = $2`,
                                parseInt(dbInvoiceId.toString()),
                                parseInt(bProdId)
                            );
                        } catch (e) {
                            console.error(`Error actualizando estado FACTURADO en BookingProductGDS #${bProdId}:`, e);
                        }
                    }
                }
            }
        }

        if (dbInvoiceId === null || dbInvoiceId === undefined || message.startsWith('ERROR')) {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Creación de Factura',
                action: 'CREAR_FACTURA',
                process: 'Error en SP',
                eventType: 'ERROR',
                stepName: 'Invocación SP Fallida',
                endpoint: '/api/invoices',
                durationMs: Date.now() - startTime,
                status: 'ERROR',
                functionalMessage: message || 'Error al crear la factura'
            });
            throw new Error(message || 'Error creating invoice');
        }

        const invoice = { id: dbInvoiceId };

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Creación de Factura',
            action: 'CREAR_FACTURA',
            process: 'Fin de Guardado',
            eventType: 'FIN_PROCESO',
            stepName: 'Factura Creada Exitosamente',
            endpoint: '/api/invoices',
            durationMs: Date.now() - startTime,
            status: 'SUCCESS',
            outputData: { dbInvoiceId, message },
            affectedId: dbInvoiceId,
            functionalMessage: message || `Factura #${dbInvoiceId} creada exitosamente`
        });

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'CREATE',
                module: 'INVOICE',
                description: `Factura ${dbInvoiceId} creada (SP). ${message}`,
                metadata: { id: dbInvoiceId }
            });
        });

        const finalMessage = message && message !== '' ? message : 'SUCCESS: Factura creada correctamente con ID ' + dbInvoiceId;
        return NextResponse.json({ message: finalMessage, invoice })
    } catch (error: any) {
        console.error('Error saving invoice (POST):', error)
        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Creación de Factura',
            action: 'CREAR_FACTURA',
            process: 'Excepción Capturada',
            eventType: 'EXCEPCION',
            stepName: 'Fallo No Controlado',
            endpoint: '/api/invoices',
            durationMs: Date.now() - startTime,
            status: 'ERROR',
            techMessage: error.message,
            stackTrace: error.stack
        });
        return NextResponse.json({ message: 'Error al guardar la factura: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
