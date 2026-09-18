import { NextRequest, NextResponse } from 'next/server'
import { executePostgresQuery } from '@/lib/postgres'
import { executeSQLServerProcedure, getZeusERPDatabaseName } from '@/lib/sqlserver'
import { registerLog } from '@/lib/logger'

export async function POST(req: NextRequest) {
    try {
        const { ids, userId, exportType = 'QUOTATION' } = await req.json()

        if (!ids || (Array.isArray(ids) && ids.length === 0)) {
            return NextResponse.json({ message: 'No quotation IDs provided' }, { status: 400 })
        }

        const idsStr = Array.isArray(ids) ? ids.join(',') : ids.toString();
        const pgProcedure = exportType === 'INVOICE' ? 'spExportInvoices' : 'spExportQuotation';
        const mssqlProcedure = exportType === 'INVOICE' ? 'spFacturacionesCrear' : 'spCotizacionesCrear';

        // 1. Obtener XML desde Postgres
        const result = await executePostgresQuery(
            `CALL public.${pgProcedure}($1, $2, $3)`,
            [idsStr, userId ? Number(userId) : 0, '']
        )

        const row = result && result.length > 0 ? result[0] : null;
        let xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        
        if (!xmlStr || typeof xmlStr !== 'string') {
            await registerLog(userId, exportType, 'EXPORT_ERROR', 'No se generó XML desde Postgres', { ids: idsStr });
            return NextResponse.json({ message: 'Error en generación de XML Postgres' }, { status: 500 })
        }

        // 2. Integración Directa con SQL Server (Nueva versión)
        let sqlServerMsg = 'Enviado exitosamente a SQL Server';
        let success = true;
        let spResult: any[] = [];

        try {
            const targetDb = await getZeusERPDatabaseName();
            console.log(`[EXPORT_API] Iniciando carga en SQL Server (BD: ${targetDb}) para ID: ${idsStr} como ${exportType}`);
            
            const sqlResult = await executeSQLServerProcedure(mssqlProcedure, {
                xml: xmlStr
            }, targetDb);

            // El SP devuelve un recordset con el estado de cada cotización procesada
            if (Array.isArray(sqlResult)) {
                spResult = sqlResult;
            } else if (sqlResult && typeof sqlResult === 'object') {
                spResult = [sqlResult];
            }

            // Evaluar el resultado del SP (Estado por cotización procesada)
            if (spResult.length > 0) {
                const hasError = spResult.some((r: any) => r.Respuesta && String(r.Respuesta).toLowerCase().includes('error'));
                success = !hasError;
                const summaryLines = spResult.map((row: any) => {
                    const cotNum = row.Cotizacion || row.cd_consecutivo || row.IdProcesado || idsStr;
                    const cotDisplay = String(cotNum).startsWith('#') ? String(cotNum) : `#${cotNum}`;
                    const idZeus = row.IdProcesado || row.id_Cotizacion || row.id;
                    const isAlreadyExisted = row.bl_existe === 1 || row.bl_existe === true || (row.Estado && String(row.Estado).toLowerCase().includes('ya existe'));

                    if (row.Respuesta && String(row.Respuesta).toLowerCase().includes('error')) {
                        return `❌ Cotización ${cotDisplay}: ${row.Respuesta}`;
                    } else if (isAlreadyExisted) {
                        return `⚠️ Cotización ${cotDisplay} ya existía en la base de datos de Zeus ERP (ID Zeus: ${idZeus || 'N/A'})`;
                    } else {
                        return `✅ Cotización ${cotDisplay} exportada exitosamente a Zeus ERP (ID Zeus: ${idZeus || 'N/A'})`;
                    }
                });
                sqlServerMsg = summaryLines.join(' | ');
            }

            // 4. Actualizar Estado en Postgres (Nueva instrucción de usuario)
            if (success && spResult.length > 0) {
                console.log(`[EXPORT_API] Actualizando estados en Postgres para: ${idsStr}`);
                try {
                    await executePostgresQuery(
                        `CALL public."spCotizacionActualizarEstado"($1::JSONB)`,
                        [JSON.stringify(spResult)]
                    );
                } catch (spPgError) {
                    console.error('[EXPORT_API] Error al actualizar estado en Postgres:', spPgError);
                }
            }

            await registerLog(userId, exportType, success ? 'EXPORT_SUCCESS' : 'EXPORT_SP_ERROR', 
                `ID ${idsStr}: ${sqlServerMsg}`, { spResult, xml: xmlStr });

        } catch (sqlError: any) {
            console.error('[EXPORT_API] Error SQL Server:', sqlError.message);
            success = false;
            sqlServerMsg = sqlError.message;
            await registerLog(userId, exportType, 'EXPORT_SQL_ERROR', `ID ${idsStr}: ${sqlServerMsg}`, { error: sqlError.message, xml: xmlStr });
        }

        // 3. Respuesta JSON para el Dashboard
        return NextResponse.json({ 
            success: success,
            message: success ? 'Exportación completada exitosamente' : sqlServerMsg,
            spResult: spResult,   // ← resultado del SP (Estado por cotización)
            xml: xmlStr
        });

    } catch (error: any) {
        console.error('Fatal Error calling export process:', error)
        return NextResponse.json({ message: 'Error fatal en servidor', details: error.message }, { status: 500 })
    }
}
