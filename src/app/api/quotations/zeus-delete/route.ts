import { NextRequest, NextResponse } from 'next/server';
import { executePostgresQuery } from '@/lib/postgres';
import { executeSQLServerProcedure, getZeusERPDatabaseName, isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import { registerLog } from '@/lib/logger';
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability';

export async function POST(req: NextRequest) {
    const traceCode = generateTraceCode();
    try {
        const { quotationId, consecutive, userId } = await req.json();

        if (!quotationId && !consecutive) {
            return NextResponse.json({
                success: false,
                message: 'Debe proporcionar el ID o consecutivo de la cotización a eliminar de Zeus ERP.',
                traceCode
            }, { status: 400 });
        }

        const qId = quotationId ? parseInt(String(quotationId), 10) : null;
        let searchConsecutive = consecutive ? String(consecutive).trim() : '';

        // 1. Obtener datos de la cotización en la BD local de Korex si tenemos el ID
        let localQuotation: any = null;
        if (qId) {
            if (isSQLServerMode()) {
                const pool = await getSQLServerConnection();
                try {
                    const res = await pool.request().query(`SELECT id, internalNumber, state FROM dbo.[Quotation] WHERE id = ${qId}`);
                    localQuotation = res.recordset[0] || null;
                } finally {
                    await pool.close();
                }
            } else {
                const res = await executePostgresQuery(`SELECT id, "internalNumber", "state" FROM public."Quotation" WHERE id = $1`, [qId]);
                localQuotation = res[0] || null;
            }

            if (localQuotation && !searchConsecutive) {
                searchConsecutive = localQuotation.internalNumber || String(localQuotation.id);
            }
        }

        if (!searchConsecutive && qId) {
            searchConsecutive = String(qId);
        }

        // 2. Conectar con la base de datos de Zeus ERP y ejecutar spCotizacionEliminarZeus
        const targetDb = await getZeusERPDatabaseName();
        console.log(`[ZEUS_DELETE] [${traceCode}] Solicitando eliminar cotización en Zeus ERP (BD: ${targetDb}): Consecutivo '${searchConsecutive}', ID Korex: ${qId}`);

        const sqlResult = await executeSQLServerProcedure('spCotizacionEliminarZeus', {
            cd_consecutivo: searchConsecutive,
            id_cotizacion: null
        }, targetDb);

        const row = Array.isArray(sqlResult) && sqlResult.length > 0 ? sqlResult[0] : (sqlResult || {});
        const respuestaMsg = row.Respuesta || row.respuesta || 'Sin respuesta del servidor Zeus ERP';
        const isEliminado = row.Eliminado === 1 || row.eliminado === 1;
        const estadoCod = Number(row.Estado !== undefined ? row.Estado : row.estado);
        const isError = estadoCod !== 0 && !isEliminado;
        const isFacturada = respuestaMsg.includes('Liquidada') || respuestaMsg.includes('Facturada') || respuestaMsg.includes('facturas') || respuestaMsg.includes('facturados');
        const notFoundInZeus = respuestaMsg.includes('no existe');

        // 3. Registrar Trazabilidad
        await recordTraceEvent({
            code: traceCode,
            userId: userId ? Number(userId) : null,
            origin: 'ZEUS_DELETE',
            module: 'COTIZACIONES',
            screen: 'Historial / Edición de Cotizaciones',
            action: 'ELIMINAR_ZEUS_ERP',
            process: 'spCotizacionEliminarZeus',
            eventType: isEliminado ? 'FIN_PROCESO' : (isFacturada ? 'ADVERTENCIA' : 'ERROR'),
            stepName: isEliminado ? 'Cotización eliminada en Zeus ERP' : 'Rechazo al eliminar en Zeus ERP',
            spName: 'spCotizacionEliminarZeus',
            endpoint: '/api/quotations/zeus-delete',
            status: isEliminado ? 'SUCCESS' : (isFacturada ? 'WARNING' : 'ERROR'),
            techMessage: respuestaMsg,
            functionalMessage: respuestaMsg,
            inputData: { quotationId: qId, consecutive: searchConsecutive, targetDb },
            outputData: row
        });

        // 4. Si la cotización fue eliminada exitosamente en Zeus ERP (o si no existía en Zeus pero estaba en Korex como ENVIADO)
        if (isEliminado || (notFoundInZeus && qId)) {
            if (qId) {
                if (isSQLServerMode()) {
                    const pool = await getSQLServerConnection();
                    try {
                        await pool.request().query(`
                            UPDATE dbo.[Quotation] 
                            SET [state] = 'PENDIENTE', [stateUpdatedAt] = GETDATE() 
                            WHERE id = ${qId}
                        `);
                    } finally {
                        await pool.close();
                    }
                } else {
                    await executePostgresQuery(`
                        UPDATE public."Quotation" 
                        SET "state" = 'PENDIENTE', "stateUpdatedAt" = CURRENT_TIMESTAMP 
                        WHERE id = $1
                    `, [qId]);
                }
            }

            await registerLog(userId, 'QUOTATION', 'ZEUS_DELETE_SUCCESS', `Cotización #${searchConsecutive} eliminada en Zeus ERP`, { qId, searchConsecutive, traceCode });

            return NextResponse.json({
                success: true,
                message: isEliminado ? respuestaMsg : `La cotización no existía en Zeus ERP. El estado en Korex fue restaurado a 'PENDIENTE' para permitir enviarla nuevamente.`,
                traceCode,
                idZeusEliminado: row.IdZeusEliminado,
                consecutivoEliminado: row.ConsecutivoEliminado || searchConsecutive
            });
        }

        // Si fue rechazada (por estar facturada u otro motivo de negocio)
        return NextResponse.json({
            success: false,
            message: respuestaMsg,
            isFacturada,
            traceCode
        }, { status: 400 });

    } catch (error: any) {
        console.error('[ZEUS_DELETE] Error:', error.message);
        await recordTraceEvent({
            code: traceCode,
            origin: 'ZEUS_DELETE',
            module: 'COTIZACIONES',
            screen: 'Historial / Edición de Cotizaciones',
            action: 'ELIMINAR_ZEUS_ERP',
            process: 'Fallo de conexión o ejecución',
            eventType: 'ERROR',
            stepName: 'Excepción en /api/quotations/zeus-delete',
            status: 'ERROR',
            techMessage: error.message,
            functionalMessage: `Error al procesar eliminación en Zeus ERP: ${error.message}`,
            stackTrace: error.stack
        });

        return NextResponse.json({
            success: false,
            message: `Error al conectar o ejecutar eliminación en Zeus ERP: ${error.message}`,
            traceCode
        }, { status: 500 });
    }
}
