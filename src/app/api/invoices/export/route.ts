import { NextRequest, NextResponse } from 'next/server'
import { executePostgresQuery } from '@/lib/postgres'
import { executeSQLServerProcedure } from '@/lib/sqlserver'
import { registerLog } from '@/lib/logger'

export async function POST(req: NextRequest) {
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
            await registerLog(userId, 'INVOICE', 'EXPORT_ERROR', 'No se generó XML desde Postgres', { ids: idsStr });
            return NextResponse.json({ message: 'Error en generación de XML Postgres' }, { status: 500 })
        }

        // 2. Integración Directa con SQL Server (Nueva versión)
        let sqlServerMsg = 'Enviado exitosamente a SQL Server';
        let success = true;
        let spResult: any[] = [];

        try {
            console.log(`[EXPORT_API] Iniciando carga en SQL Server para ID: ${idsStr}`);
            
            const sqlResult = await executeSQLServerProcedure('spFacturacionesCrear', {
                xml: xmlStr
            });

            // El SP devuelve un recordset con el estado de cada factura procesada
            if (Array.isArray(sqlResult)) {
                spResult = sqlResult;
                const hasFailure = spResult.some(item => !(item.success === 1 || item.success === true || item.success === '1'));
                if (hasFailure) {
                    success = false;
                }
                const messages = spResult.map(item => item.message).filter(Boolean);
                sqlServerMsg = messages.join(' | ');
                if (!sqlServerMsg) {
                    sqlServerMsg = hasFailure ? 'Algunas facturas fallaron al procesarse' : 'Exportación completada exitosamente';
                }
            } else if (sqlResult && typeof sqlResult === 'object') {
                spResult = [sqlResult];
                const item = spResult[0];
                const itemSuccess = item.success === 1 || item.success === true || item.success === '1';
                sqlServerMsg = item.message || '';
                if (!itemSuccess) {
                    success = false;
                    if (!sqlServerMsg) sqlServerMsg = 'Error al procesar en SQL Server';
                }
            }

            // Registrar log detallado por cada factura en Postgres
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

            // 4. Actualizar Estado en Postgres (Nueva instrucción de usuario)
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
            sqlServerMsg = sqlError.message;
            await registerLog(userId, 'INVOICE', 'EXPORT_SQL_ERROR', `ID ${idsStr}: ${sqlServerMsg}`, { error: sqlError.message, xml: xmlStr });
        }

        // 3. Respuesta JSON para el Dashboard
        return NextResponse.json({ 
            success: success,
            message: sqlServerMsg || (success ? 'Exportación completada exitosamente' : 'Error en la exportación'),
            spResult: spResult,   // ← resultado del SP (Estado por factura)
            xml: xmlStr
        });

    } catch (error: any) {
        console.error('Fatal Error calling export process:', error)
        return NextResponse.json({ message: 'Error fatal en servidor', details: error.message }, { status: 500 })
    }
}

