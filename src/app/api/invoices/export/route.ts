import { NextRequest, NextResponse } from 'next/server'
import { executePostgresQuery } from '@/lib/postgres'
import { executeSQLServerProcedure } from '@/lib/sqlserver'
import { registerLog } from '@/lib/logger'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'

export async function POST(req: NextRequest) {
    const traceCode = generateTraceCode();
    try {
        const { ids, userId } = await req.json()

        if (!ids || (Array.isArray(ids) && ids.length === 0)) {
            return NextResponse.json({ message: 'No invoice IDs provided' }, { status: 400 })
        }

        const idsStr = Array.isArray(ids) ? ids.join(',') : ids.toString();

        // 1. Obtener XML desde Postgres
        const result = await executePostgresQuery(
            `CALL spExportInvoices($1, $2, $3)`,
            [idsStr, userId ? Number(userId) : 0, '']
        )

        const row = result && result.length > 0 ? result[0] : null;
        let xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        
        if (!xmlStr || typeof xmlStr !== 'string') {
            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'Facturación',
                screen: 'Exportación Zeus ERP',
                action: 'EXPORTAR_FACTURAS',
                process: 'Generación XML Postgres',
                eventType: 'ERROR',
                stepName: 'Error al generar XML',
                endpoint: '/api/invoices/export',
                status: 'ERROR',
                techMessage: 'spExportInvoices no devolvió una cadena XML válida',
                functionalMessage: 'No se pudo generar la estructura XML de facturación'
            });
            await registerLog(userId, 'INVOICE', 'EXPORT_ERROR', 'No se generó XML desde Postgres', { ids: idsStr });
            return NextResponse.json({ message: 'Error en generación de XML Postgres', traceCode }, { status: 500 })
        }

        // 2. Integración Directa con SQL Server
        let sqlServerMsg = 'Enviado exitosamente a SQL Server';
        let success = true;
        let spResult: any[] = [];

        try {
            console.log(`[EXPORT_API] Iniciando carga en SQL Server para ID: ${idsStr}`);
            
            const sqlResult = await executeSQLServerProcedure('spFacturacionesCrear', {
                xml: xmlStr
            });

            if (Array.isArray(sqlResult)) {
                spResult = sqlResult;
            } else if (sqlResult && typeof sqlResult === 'object') {
                spResult = [sqlResult];
            }

            if (spResult.length > 0) {
                const hasFailure = spResult.some((item: any) => !(item.success === 1 || item.success === true || item.success === '1'));
                if (hasFailure) {
                    success = false;
                }
                const formattedMsgs = spResult.map((item: any) => {
                    const invId = item.invoiceId || item.Factura || item.id || idsStr;
                    const isOk = item.success === 1 || item.success === true || item.success === '1';
                    const rawMsg = item.message || '';
                    const cleanMsg = rawMsg.split('--- DYNAMIC EXECUTION TRACE ---')[0].trim();
                    if (isOk) {
                        return `✅ Factura #${invId}: Exportada correctamente a Zeus ERP`;
                    } else {
                        return `❌ Factura #${invId}: ${cleanMsg || 'Error no especificado en Zeus ERP'}`;
                    }
                });
                sqlServerMsg = formattedMsgs.join(' | ');
            } else {
                sqlServerMsg = 'Exportación procesada en SQL Server';
            }

            // Registrar traza detallada
            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'Facturación',
                screen: 'Exportación Zeus ERP',
                action: 'EXPORTAR_FACTURAS',
                process: 'Ejecución spFacturacionesCrear',
                eventType: success ? 'FIN_PROCESO' : 'ERROR',
                stepName: success ? 'Factura exportada exitosamente' : 'Error en Stored Procedure Zeus ERP',
                spName: 'spFacturacionesCrear',
                endpoint: '/api/invoices/export',
                status: success ? 'SUCCESS' : 'ERROR',
                techMessage: sqlServerMsg,
                functionalMessage: success ? 'Factura exportada correctamente' : `Fallo al exportar factura: ${sqlServerMsg}`,
                inputData: { ids: idsStr, xmlLength: xmlStr.length },
                outputData: spResult
            });

            // Registrar log detallado por cada factura
            for (const item of spResult) {
                const invId = item.invoiceId || 0;
                const itemSuccess = item.success === 1 || item.success === true || item.success === '1';
                const itemMsg = item.message || '';
                await registerLog(
                    userId ? Number(userId) : null,
                    'INVOICE_EXPORT_DETAIL',
                    itemSuccess ? 'EXPORT_SUCCESS' : 'EXPORT_FAILED',
                    `Factura ID ${invId}: ${itemMsg}`,
                    item
                );
            }

            // Actualizar Estado en Postgres
            if (spResult.length > 0) {
                console.log(`[EXPORT_API] Actualizando estados en Postgres para: ${idsStr}`);
                try {
                    await executePostgresQuery(
                        `CALL public."spFacturaActualizarEstado"($1::JSONB)`,
                        [JSON.stringify(spResult)]
                     );
                } catch (spPgError) {
                    console.error('[EXPORT_API] Error al actualizar estado en Postgres:', spPgError);
                }
            }

            await registerLog(userId, 'INVOICE', success ? 'EXPORT_SUCCESS' : 'EXPORT_SP_ERROR', 
                `ID ${idsStr}: ${sqlServerMsg}`, { spResult, xml: xmlStr });

        } catch (sqlError: any) {
            console.error('[EXPORT_API] Error SQL Server:', sqlError.message);
            success = false;
            sqlServerMsg = sqlError.message || 'Error de conexión o ejecución en SQL Server';
            
            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'Facturación',
                screen: 'Exportación Zeus ERP',
                action: 'EXPORTAR_FACTURAS',
                process: 'Conexión / Ejecución SQL Server',
                eventType: 'ERROR',
                stepName: 'Fallo de Ejecución en SQL Server',
                spName: 'spFacturacionesCrear',
                endpoint: '/api/invoices/export',
                status: 'ERROR',
                techMessage: sqlError.message || 'Error no especificado en SQL Server',
                functionalMessage: 'Error de comunicación o procesamiento en SQL Server',
                stackTrace: sqlError.stack
            });

            await registerLog(userId, 'INVOICE', 'EXPORT_SQL_ERROR', `ID ${idsStr}: ${sqlServerMsg}`, { error: sqlError.message, xml: xmlStr });
        }

        return NextResponse.json({ 
            success: success,
            message: sqlServerMsg || (success ? 'Exportación completada exitosamente' : 'Error en la exportación'),
            spResult: spResult,
            xml: xmlStr,
            traceCode
        });

    } catch (error: any) {
        console.error('Fatal Error calling export process:', error)
        return NextResponse.json({ message: 'Error fatal en servidor', details: error.message, traceCode }, { status: 500 })
    }
}

