import { NextRequest, NextResponse } from 'next/server'
import { executePostgresQuery } from '@/lib/postgres'
import { isSQLServerMode, getSQLServerConnection, executeSQLServerProcedure } from '@/lib/sqlserver'
import { registerLog } from '@/lib/logger'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'

function formatZeusConsecutive(rawMsg: string): string {
    if (!rawMsg) return '';
    const clean = rawMsg.split('--- DYNAMIC EXECUTION TRACE ---')[0].trim();
    // Pattern like 55-3300000102-61494 or 55-33-00000102
    const match = clean.match(/^([A-Z0-9]{2})-([A-Z0-9]{2})-?([0-9]{8})(?:-\d+)?$/i);
    if (match) {
        return `${match[1]}-${match[2]}-${match[3]}`;
    }
    return clean;
}

export async function POST(req: NextRequest) {
    const traceCode = generateTraceCode();
    try {
        const { ids, userId } = await req.json()

        if (!ids || (Array.isArray(ids) && ids.length === 0)) {
            return NextResponse.json({ message: 'No invoice IDs provided' }, { status: 400 })
        }

        const idsStr = Array.isArray(ids) ? ids.join(',') : ids.toString();

        // 1. Obtener XML (dual motor support)
        let xmlStr = '';
        if (isSQLServerMode()) {
            const sqlResult = await executeSQLServerProcedure('spExportInvoices', { 
                Envoices_id: idsStr, 
                User_id: userId ? Number(userId) : 0 
            });
            xmlStr = Array.isArray(sqlResult) && sqlResult.length > 0 
                ? (sqlResult[0]?.mensaje_resultado || sqlResult[0]?.xml || '') 
                : '';
        } else {
            const result = await executePostgresQuery(
                `CALL spExportInvoices($1, $2, $3)`,
                [idsStr, userId ? Number(userId) : 0, '']
            );
            const row = result && result.length > 0 ? result[0] : null;
            xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        }

        if (!xmlStr || typeof xmlStr !== 'string') {
            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'Facturación',
                screen: 'Exportación Zeus ERP',
                action: 'EXPORTAR_FACTURAS',
                process: 'Generación XML',
                eventType: 'ERROR',
                stepName: 'Error al generar XML',
                endpoint: '/api/invoices/export',
                status: 'ERROR',
                techMessage: 'spExportInvoices no devolvió una cadena XML válida',
                functionalMessage: 'No se pudo generar la estructura XML de facturación'
            });
            await registerLog(userId, 'INVOICE', 'EXPORT_ERROR', 'No se generó XML para facturas', { ids: idsStr });
            return NextResponse.json({ message: 'Error en generación de XML de facturación', traceCode }, { status: 500 })
        }

        // Obtener mapa de números de factura (internalNumber / consecutivo)
        const idArray = idsStr.split(',').map((id: string) => parseInt(id.trim(), 10)).filter((n: number) => !isNaN(n));
        const invoiceNumberMap: Record<number, string> = {};

        if (idArray.length > 0) {
            try {
                if (isSQLServerMode()) {
                    const pool = await getSQLServerConnection();
                    const res = await pool.request().query(`SELECT id, internalNumber, serie, consecutivo FROM dbo.[Invoices] WHERE id IN (${idArray.join(',')})`);
                    await pool.close();
                    for (const r of res.recordset) {
                        const num = r.internalNumber || (r.consecutivo ? (r.serie ? `${r.serie}-${r.consecutivo}` : `FAC-${r.consecutivo}`) : `FAC-${r.id}`);
                        invoiceNumberMap[r.id] = num;
                    }
                } else {
                    const res = await executePostgresQuery(
                        `SELECT id, "internalNumber", serie, consecutivo FROM public."Invoices" WHERE id IN (${idArray.join(',')})`
                    );
                    for (const r of res) {
                        const num = r.internalNumber || (r.consecutivo ? (r.serie ? `${r.serie}-${r.consecutivo}` : `FAC-${r.consecutivo}`) : `FAC-${r.id}`);
                        invoiceNumberMap[r.id] = num;
                    }
                }
            } catch (e: any) {
                console.warn('[EXPORT_API] No se pudieron consultar números de factura:', e.message);
            }
        }

        // 2. Integración Directa con SQL Server (spFacturacionesCrear -> Zeus ERP)
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

            const checkItemSuccess = (item: any): boolean => {
                if (!item) return false;
                if (item.success === 1 || item.success === true || item.success === '1') return true;
                if (item.Estado === 0 || item.Estado === '0' || item.estado === 0 || item.estado === '0') return true;
                const msg = String(item.message || item.Respuesta || item.respuesta || '').trim();
                if (/^[A-Z0-9]{2}-[A-Z0-9]{2}-?[0-9]{8}/i.test(msg)) return true;
                return false;
            };

            const getItemMessage = (item: any): string => {
                if (!item) return '';
                return item.message || item.Respuesta || item.respuesta || (typeof item === 'string' ? item : '');
            };

            if (spResult.length > 0) {
                const hasFailure = spResult.some((item: any) => !checkItemSuccess(item));
                const formattedMsgs = spResult.map((item: any) => {
                    const invId = Number(item.invoiceId || item.Factura || item.id_factura || item.id || (idArray.length === 1 ? idArray[0] : 0));
                    const invNum = invoiceNumberMap[invId] || (invId ? `FAC-${invId}` : idsStr);
                    const isOk = checkItemSuccess(item);
                    const rawMsg = getItemMessage(item);
                    const zeusConsec = formatZeusConsecutive(rawMsg);
                    const zeusStr = zeusConsec ? ` (Zeus ERP N° ${zeusConsec})` : '';
                    if (isOk) {
                        return `✅ Factura ${invNum}${zeusStr}: Exportada correctamente a Zeus ERP`;
                    } else {
                        const cleanMsg = rawMsg.split('--- DYNAMIC EXECUTION TRACE ---')[0].trim();
                        return `❌ Factura ${invNum}: ${cleanMsg || 'Error no especificado en Zeus ERP'}`;
                    }
                });

                if (hasFailure) {
                    success = false;
                    sqlServerMsg = formattedMsgs.join(' | ');
                } else {
                    success = true;
                    sqlServerMsg = formattedMsgs.join(' | ');
                }
            } else {
                const exportedNums = idArray.map((id: number) => invoiceNumberMap[id] || `FAC-${id}`);
                sqlServerMsg = `✅ Factura N° ${exportedNums.join(', ')} exportada exitosamente a Zeus ERP`;
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
                const invId = item.invoiceId || (idArray.length === 1 ? idArray[0] : 0);
                const itemSuccess = checkItemSuccess(item);
                const itemMsg = getItemMessage(item);
                await registerLog(
                    userId ? Number(userId) : null,
                    'INVOICE_EXPORT_DETAIL',
                    itemSuccess ? 'EXPORT_SUCCESS' : 'EXPORT_FAILED',
                    `Factura ID ${invId}: ${itemMsg}`,
                    item
                );
            }

            // Actualizar Estado en la Base de Datos Activa
            if (spResult.length > 0) {
                console.log(`[EXPORT_API] Actualizando estados de facturas para: ${idsStr}`);
                if (isSQLServerMode()) {
                    for (const item of spResult) {
                        const invId = Number(item.invoiceId || item.Factura || item.id_factura || item.id || (idArray.length === 1 ? idArray[0] : 0));
                        const isOk = checkItemSuccess(item);
                        if (isOk && invId > 0) {
                            const rawMsg = getItemMessage(item);
                            const match = rawMsg.match(/^([A-Z0-9]{2})-([A-Z0-9]{2})-?([0-9]{8})/i);
                            const fuente = match ? match[1] : '55';
                            const serie = match ? match[2] : '33';
                            const consecutivo = match ? match[3] : null;
                            const pool = await getSQLServerConnection();
                            await pool.request().query(
                                `UPDATE dbo.[Invoices] SET [state] = 'EXPORTED'${consecutivo ? `, consecutivo = '${consecutivo}', serie = '${serie}', fuente = '${fuente}'` : ''} WHERE id = ${invId}`
                            );
                            await pool.close();
                        }
                    }
                } else {
                    try {
                        await executePostgresQuery(
                            `CALL public."spFacturaActualizarEstado"($1::JSONB)`,
                            [JSON.stringify(spResult)]
                        );
                    } catch (spPgError) {
                        console.error('[EXPORT_API] Error al actualizar estado en Postgres:', spPgError);
                    }
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
