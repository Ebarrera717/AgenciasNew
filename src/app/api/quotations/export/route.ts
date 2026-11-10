import { NextRequest, NextResponse } from 'next/server'
import { executePostgresQuery } from '@/lib/postgres'
import { executeSQLServerProcedure, getZeusERPDatabaseName, isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { registerLog } from '@/lib/logger'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'

export async function POST(req: NextRequest) {
    const traceCode = generateTraceCode();
    try {
        const { ids, userId, exportType = 'QUOTATION' } = await req.json()

        if (!ids || (Array.isArray(ids) && ids.length === 0)) {
            return NextResponse.json({ message: 'No quotation IDs provided', traceCode }, { status: 400 })
        }

        const idArray: number[] = (Array.isArray(ids) ? ids : ids.toString().split(','))
            .map((id: any) => parseInt(String(id).trim(), 10))
            .filter((n: number) => !isNaN(n));

        if (idArray.length === 0) {
            return NextResponse.json({ message: 'No valid quotation IDs provided', traceCode }, { status: 400 });
        }

        const idsStr = idArray.join(',');
        const pgProcedure = exportType === 'INVOICE' ? 'spExportInvoices' : 'spExportQuotation';
        const mssqlProcedure = exportType === 'INVOICE' ? 'spFacturacionesCrear' : 'spCotizacionesCrear';

        // 1. Obtener XML (dual motor support)
        let xmlStr = '';
        if (isSQLServerMode()) {
            const sqlResult = await executeSQLServerProcedure(pgProcedure, {
                [exportType === 'INVOICE' ? 'Envoices_id' : 'Quotation_id']: idsStr,
                User_id: userId ? Number(userId) : 0
            });
            xmlStr = Array.isArray(sqlResult) && sqlResult.length > 0
                ? (sqlResult[0]?.mensaje_resultado || sqlResult[0]?.xml || '')
                : '';
        } else {
            const result = await executePostgresQuery(
                `CALL public.${pgProcedure}($1, $2, $3)`,
                [idsStr, userId ? Number(userId) : 0, '']
            );
            const row = result && result.length > 0 ? result[0] : null;
            xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        }

        // Validación estricta de estructura XML
        const isXmlInvalid = !xmlStr || 
            typeof xmlStr !== 'string' || 
            xmlStr.trim().startsWith('ERROR:') || 
            xmlStr.trim().startsWith('error:') ||
            (!xmlStr.includes('<Cotizacion') && !xmlStr.includes('<Factura'));

        if (isXmlInvalid) {
            const errorMsg = (!xmlStr || typeof xmlStr !== 'string') 
                ? 'No se generó XML para cotizaciones' 
                : xmlStr.trim();

            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'COTIZACIONES',
                screen: 'Historial de Cotizaciones',
                action: 'EXPORTAR_ZEUS_ERP',
                process: 'Generación XML',
                eventType: 'ERROR',
                stepName: 'Fallo al generar XML en Base de Datos',
                spName: pgProcedure,
                endpoint: '/api/quotations/export',
                status: 'ERROR',
                techMessage: errorMsg,
                functionalMessage: `Error al generar XML para cotizaciones [${idsStr}]: ${errorMsg}`
            });

            await registerLog(userId, exportType, 'EXPORT_ERROR', errorMsg, { ids: idsStr });
            return NextResponse.json({ 
                success: false,
                message: `Error en generación de XML de cotización: ${errorMsg}`, 
                traceCode 
            }, { status: 500 });
        }

        // 1.5 Aplicar Parametrización Dinámica de Descripción de Ítems y Observaciones para Zeus ERP
        try {
            const { getZeusTextConfigs } = await import('@/lib/zeus-text-service');
            const { applyZeusTextFormattingToXml } = await import('@/lib/zeus-text-formatter');
            const { itemDescriptionConfig, observationsConfig } = await getZeusTextConfigs();
            xmlStr = applyZeusTextFormattingToXml(xmlStr, itemDescriptionConfig, observationsConfig);
        } catch (fmtErr: any) {
            console.warn('[EXPORT_API] Advertencia al aplicar parametrización de textos Zeus:', fmtErr.message);
        }

        // 2. Integración Directa con SQL Server (Zeus ERP)
        let sqlServerMsg = 'Enviado exitosamente a SQL Server';
        let success = true;
        let spResult: any[] = [];

        try {
            const targetDb = await getZeusERPDatabaseName();
            console.log(`[EXPORT_API] [${traceCode}] Iniciando carga en SQL Server (BD: ${targetDb}) para ID: ${idsStr} como ${exportType}`);

            const sqlResult = await executeSQLServerProcedure(mssqlProcedure, {
                xml: xmlStr
            }, targetDb);

            // El SP devuelve un recordset con el estado de cada cotización procesada
            if (Array.isArray(sqlResult)) {
                spResult = sqlResult;
            } else if (sqlResult && typeof sqlResult === 'object') {
                spResult = [sqlResult];
            }

            const checkQuotationError = (row: any): boolean => {
                if (!row) return true;
                const resp = String(row.Respuesta || row.respuesta || '').toLowerCase();
                const estado = String(row.Estado || row.estado || '').toLowerCase();

                // 1. Mensajes explícitos de error en Respuesta o Estado
                if (resp.includes('error') || resp.includes('no existe') || resp.includes('no válido') || resp.includes('no valido') || resp.includes('invalido') || resp.includes('inválido')) return true;
                if (estado.includes('error') || estado.includes('falló') || estado.includes('fallo')) return true;

                // 2. Si tiene IdProcesado, o Estado dice "Creada exitosamente", o bl_existe es 1/true, fue exitosa
                if (row.IdProcesado || estado.includes('creada') || estado.includes('exitosa') || row.bl_existe === 1 || row.bl_existe === true) {
                    return false;
                }

                // 3. Códigos numéricos de error (ej. early returns con SELECT '...', 1 AS 'Estado')
                if (typeof row.Estado === 'number' && row.Estado !== 0) return true;
                if (typeof row.Estado === 'string' && /^[0-9]+$/.test(row.Estado.trim()) && Number(row.Estado) !== 0) return true;

                return false;
            };

            // Evaluar el resultado del SP (Estado por cotización procesada)
            if (spResult.length > 0) {
                const hasError = spResult.some(checkQuotationError);
                success = !hasError;
                const summaryLines = spResult.map((row: any) => {
                    const cotNum = row.Cotizacion || row.cd_consecutivo || row.IdProcesado || idsStr;
                    const cotDisplay = String(cotNum).startsWith('#') ? String(cotNum) : `#${cotNum}`;
                    const idZeus = row.IdProcesado || row.id_Cotizacion || row.id;
                    const isAlreadyExisted = row.bl_existe === 1 || row.bl_existe === true || (row.Estado && String(row.Estado).toLowerCase().includes('ya existe'));
                    const isErr = checkQuotationError(row);

                    if (isErr) {
                        return `❌ Cotización ${cotDisplay}: ${row.Respuesta || row.Estado || 'Error no especificado en Zeus ERP'}`;
                    } else if (isAlreadyExisted) {
                        return `⚠️ Cotización ${cotDisplay} ya existía en Zeus ERP (ID Zeus: #${idZeus || 'N/A'})`;
                    } else {
                        return `✅ Cotización ${cotDisplay} exportada exitosamente a Zeus ERP (ID Zeus: #${idZeus || 'N/A'})`;
                    }
                });
                sqlServerMsg = summaryLines.join(' | ');
            } else {
                success = false;
                sqlServerMsg = `⚠️ El procedimiento ${mssqlProcedure} no retornó confirmación de cotizaciones procesadas desde Zeus ERP.`;
            }

            // 3. Registrar Trazabilidad y Diagnóstico
            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'COTIZACIONES',
                screen: 'Historial de Cotizaciones',
                action: 'EXPORTAR_ZEUS_ERP',
                process: `Invocación ${mssqlProcedure}`,
                eventType: success ? 'FIN_PROCESO' : 'ERROR',
                stepName: success ? 'Cotización exportada a Zeus ERP' : 'Fallo en Stored Procedure Zeus ERP',
                spName: mssqlProcedure,
                endpoint: '/api/quotations/export',
                status: success ? 'SUCCESS' : 'ERROR',
                techMessage: sqlServerMsg,
                functionalMessage: success ? 'Cotizaciones exportadas exitosamente a Zeus ERP' : `Fallo al exportar cotizaciones: ${sqlServerMsg}`,
                inputData: { ids: idsStr, xmlLength: xmlStr.length },
                outputData: spResult
            });

            // 4. Actualizar Estado en BD Activa (Dual Motor)
            if (success) {
                console.log(`[EXPORT_API] [${traceCode}] Actualizando estados para cotizaciones: ${idsStr}`);

                const enrichedResult = spResult.map((item: any, idx: number) => ({
                    ...item,
                    quotationId: idArray[idx] || (idArray.length === 1 ? idArray[0] : null)
                }));

                if (isSQLServerMode()) {
                    const pool = await getSQLServerConnection();
                    try {
                        for (const qId of idArray) {
                            await pool.request().query(
                                `UPDATE dbo.[Quotation] SET [state] = 'ENVIADO', [stateUpdatedAt] = GETDATE() WHERE id = ${qId}`
                            );
                        }
                    } finally {
                        await pool.close();
                    }
                } else {
                    try {
                        // Llamar sin comillas para resolución limpia insensible a mayúsculas
                        await executePostgresQuery(
                            `CALL public.spCotizacionActualizarEstado($1::JSONB)`,
                            [JSON.stringify(enrichedResult.length > 0 ? enrichedResult : spResult)]
                        );
                    } catch (spPgError: any) {
                        console.warn('[EXPORT_API] spCotizacionActualizarEstado aviso:', spPgError.message);
                    }
                    if (idArray.length > 0) {
                        try {
                            await executePostgresQuery(
                                `UPDATE public."Quotation" SET "state" = 'ENVIADO', "stateUpdatedAt" = CURRENT_TIMESTAMP WHERE id = ANY($1::int[])`,
                                [idArray]
                            );
                        } catch (updateErr: any) {
                            console.error('[EXPORT_API] Error al ejecutar UPDATE directo en Postgres:', updateErr.message);
                        }
                    }
                }
            }

            await registerLog(userId, exportType, success ? 'EXPORT_SUCCESS' : 'EXPORT_SP_ERROR', 
                `ID ${idsStr}: ${sqlServerMsg}`, { spResult, xml: xmlStr, traceCode });

        } catch (sqlError: any) {
            console.error('[EXPORT_API] Error SQL Server:', sqlError.message);
            success = false;
            sqlServerMsg = sqlError.message || 'Error de conexión o procesamiento en SQL Server (Zeus ERP)';

            await recordTraceEvent({
                code: traceCode,
                userId: userId ? Number(userId) : null,
                origin: 'EXPORTACION',
                module: 'COTIZACIONES',
                screen: 'Historial de Cotizaciones',
                action: 'EXPORTAR_ZEUS_ERP',
                process: 'Conexión / Ejecución Zeus ERP',
                eventType: 'ERROR',
                stepName: 'Fallo al conectar o ejecutar en Zeus ERP',
                spName: mssqlProcedure,
                endpoint: '/api/quotations/export',
                status: 'ERROR',
                techMessage: sqlError.message,
                functionalMessage: `Error al conectar o ejecutar en Zeus ERP: ${sqlError.message}`,
                stackTrace: sqlError.stack
            });

            await registerLog(userId, exportType, 'EXPORT_SQL_ERROR', `ID ${idsStr}: ${sqlServerMsg}`, { error: sqlError.message, xml: xmlStr, traceCode });
        }

        // 5. Respuesta JSON para el Dashboard
        return NextResponse.json({ 
            success: success,
            message: sqlServerMsg,
            spResult: spResult,
            xml: xmlStr,
            traceCode
        });

    } catch (error: any) {
        console.error('Fatal Error calling export process:', error);
        await recordTraceEvent({
            code: traceCode,
            origin: 'EXPORTACION',
            module: 'COTIZACIONES',
            screen: 'Historial de Cotizaciones',
            action: 'EXPORTAR_ZEUS_ERP',
            process: 'Fatal Error Handler',
            eventType: 'ERROR',
            stepName: 'Excepción crítica en servidor Next.js',
            endpoint: '/api/quotations/export',
            status: 'ERROR',
            techMessage: error.message,
            stackTrace: error.stack
        }).catch(() => {});

        return NextResponse.json({ message: 'Error fatal en servidor', details: error.message, traceCode }, { status: 500 })
    }
}
