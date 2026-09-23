import { isSQLServerMode, getSQLServerConnection, executeSQLServerProcedure, getZeusERPDatabaseName } from './sqlserver'
import { executePostgresQuery } from './postgres'
import { registerLog } from './logger'
import { recordTraceEvent, generateTraceCode } from './traceability'

/**
 * Verifica si el parámetro de exportación automática hacia Zeus ERP está habilitado ('1').
 */
export async function isAutoExportEnabled(type: 'QUOTATION' | 'INVOICE'): Promise<boolean> {
    try {
        const codes = type === 'QUOTATION'
            ? ['EnviarCotizacionesAutoSQLserver']
            : ['EnviarFacturacionAutoSQLserver', 'EnviarFacturasAutoSQLserver'];

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            const res = await pool.request()
                .input('c1', codes[0])
                .input('c2', codes[1] || codes[0])
                .query(`SELECT value FROM dbo.[SystemParameter] WHERE code IN (@c1, @c2)`);
            await pool.close();
            return res.recordset?.some((r: any) => String(r.value).trim() === '1') || false;
        } else {
            const res = await executePostgresQuery(
                `SELECT "value" FROM public."SystemParameter" WHERE "code" = ANY($1::text[])`,
                [codes]
            );
            return res?.some((r: any) => String(r.value).trim() === '1') || false;
        }
    } catch (e: any) {
        console.warn(`[ZEUS_AUTO_EXPORT] Error consultando parámetro para ${type}:`, e.message);
        return false;
    }
}

/**
 * Exporta automáticamente una o varias cotizaciones hacia Zeus ERP (SQL Server).
 */
export async function autoExportQuotationToZeusERP(
    quotationIds: number | string | (number | string)[],
    userId: number = 1
): Promise<{ exported: boolean; success?: boolean; message?: string; spResult?: any; xml?: string }> {
    const traceCode = generateTraceCode();
    const idsStr = Array.isArray(quotationIds) ? quotationIds.join(',') : String(quotationIds);

    try {
        const isEnabled = await isAutoExportEnabled('QUOTATION');
        if (!isEnabled) {
            console.log(`[ZEUS_AUTO_EXPORT] Envío automático de cotizaciones desactivado (EnviarCotizacionesAutoSQLserver != 1)`);
            return { exported: false, reason: 'DISABLED' } as any;
        }

        console.log(`[ZEUS_AUTO_EXPORT] Iniciando exportación automática de Cotización(es) [${idsStr}] a Zeus ERP...`);

        // 1. Generación de XML (Dual Motor)
        let xmlStr = '';
        if (isSQLServerMode()) {
            const sqlResult = await executeSQLServerProcedure('spExportQuotation', {
                Quotation_id: idsStr,
                User_id: Number(userId) || 1
            });
            xmlStr = Array.isArray(sqlResult) && sqlResult.length > 0
                ? (sqlResult[0]?.mensaje_resultado || sqlResult[0]?.xml || '')
                : '';
        } else {
            const result = await executePostgresQuery(
                `CALL public.spExportQuotation($1, $2, $3)`,
                [idsStr, Number(userId) || 1, '']
            );
            const row = result && result.length > 0 ? result[0] : null;
            xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        }

        if (!xmlStr || typeof xmlStr !== 'string' || !xmlStr.trim().startsWith('<') || xmlStr.startsWith('ERROR')) {
            console.warn(`[ZEUS_AUTO_EXPORT] No se pudo generar XML válido para cotización(es) [${idsStr}]: ${xmlStr}`);
            await registerLog(userId, 'QUOTATION', 'AUTO_EXPORT_ERROR', `ID(s) ${idsStr}: Error en generación de XML: ${xmlStr}`, { xml: xmlStr });
            return { exported: false, success: false, message: `Error en generación de XML: ${xmlStr}`, xml: xmlStr };
        }

        // 2. Inyección en Zeus ERP (spCotizacionesCrear)
        const targetDb = await getZeusERPDatabaseName();
        console.log(`[ZEUS_AUTO_EXPORT] Inyectando XML en Zeus ERP (BD: ${targetDb}) para Cotización(es) [${idsStr}]...`);

        const sqlResult = await executeSQLServerProcedure('spCotizacionesCrear', { xml: xmlStr }, targetDb);
        const spResult = Array.isArray(sqlResult) ? sqlResult : (sqlResult ? [sqlResult] : []);

        const hasError = spResult.some((r: any) => r.Respuesta && String(r.Respuesta).toLowerCase().includes('error'));
        const success = !hasError;

        // 3. Actualizar Estado en Base de Datos de Korex
        if (success && spResult.length > 0) {
            try {
                if (!isSQLServerMode()) {
                    await executePostgresQuery(
                        `CALL public."spCotizacionActualizarEstado"($1::JSONB)`,
                        [JSON.stringify(spResult)]
                    );
                }
            } catch (statusErr: any) {
                console.warn('[ZEUS_AUTO_EXPORT] Advertencia al actualizar estado de cotización en Korex:', statusErr.message);
            }
        }

        await registerLog(
            userId,
            'QUOTATION',
            success ? 'AUTO_EXPORT_SUCCESS' : 'AUTO_EXPORT_SP_ERROR',
            `ID(s) ${idsStr}: Exportación automática a Zeus ERP completada (${success ? 'Éxito' : 'Con observaciones'})`,
            { spResult, targetDb }
        );

        return {
            exported: true,
            success,
            message: success ? 'Cotización exportada automáticamente a Zeus ERP' : 'Exportación con observaciones en Zeus ERP',
            spResult,
            xml: xmlStr
        };
    } catch (error: any) {
        console.error(`[ZEUS_AUTO_EXPORT] Excepción en exportación automática de cotización [${idsStr}]:`, error.message);
        await registerLog(userId, 'QUOTATION', 'AUTO_EXPORT_EXCEPTION', `ID(s) ${idsStr}: ${error.message}`, { error: error.message });
        return { exported: false, success: false, message: error.message };
    }
}

/**
 * Exporta automáticamente una o varias facturas hacia Zeus ERP (SQL Server).
 */
export async function autoExportInvoiceToZeusERP(
    invoiceIds: number | string | (number | string)[],
    userId: number = 1
): Promise<{ exported: boolean; success?: boolean; message?: string; spResult?: any; xml?: string }> {
    const traceCode = generateTraceCode();
    const idsStr = Array.isArray(invoiceIds) ? invoiceIds.join(',') : String(invoiceIds);

    try {
        const isEnabled = await isAutoExportEnabled('INVOICE');
        if (!isEnabled) {
            console.log(`[ZEUS_AUTO_EXPORT] Envío automático de facturas desactivado (EnviarFacturacionAutoSQLserver != 1)`);
            return { exported: false, reason: 'DISABLED' } as any;
        }

        console.log(`[ZEUS_AUTO_EXPORT] Iniciando exportación automática de Factura(s) [${idsStr}] a Zeus ERP...`);

        // 1. Generación de XML (Dual Motor)
        let xmlStr = '';
        if (isSQLServerMode()) {
            const sqlResult = await executeSQLServerProcedure('spExportInvoices', {
                Envoices_id: idsStr,
                User_id: Number(userId) || 1
            });
            xmlStr = Array.isArray(sqlResult) && sqlResult.length > 0
                ? (sqlResult[0]?.mensaje_resultado || sqlResult[0]?.xml || '')
                : '';
        } else {
            const result = await executePostgresQuery(
                `CALL public.spExportInvoices($1, $2, $3)`,
                [idsStr, Number(userId) || 1, '']
            );
            const row = result && result.length > 0 ? result[0] : null;
            xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;
        }

        if (!xmlStr || typeof xmlStr !== 'string' || !xmlStr.trim().startsWith('<') || xmlStr.startsWith('ERROR')) {
            console.warn(`[ZEUS_AUTO_EXPORT] No se pudo generar XML válido para factura(s) [${idsStr}]: ${xmlStr}`);
            await registerLog(userId, 'INVOICE', 'AUTO_EXPORT_ERROR', `ID(s) ${idsStr}: Error en generación de XML: ${xmlStr}`, { xml: xmlStr });
            return { exported: false, success: false, message: `Error en generación de XML: ${xmlStr}`, xml: xmlStr };
        }

        // 2. Inyección en Zeus ERP (spFacturacionesCrear)
        const targetDb = await getZeusERPDatabaseName();
        console.log(`[ZEUS_AUTO_EXPORT] Inyectando XML en Zeus ERP (BD: ${targetDb}) para Factura(s) [${idsStr}]...`);

        const sqlResult = await executeSQLServerProcedure('spFacturacionesCrear', { xml: xmlStr }, targetDb);
        const spResult = Array.isArray(sqlResult) ? sqlResult : (sqlResult ? [sqlResult] : []);

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

        const hasFailure = spResult.length > 0 && spResult.some((item: any) => !checkItemSuccess(item));
        const success = !hasFailure;

        // 3. Actualizar Estado y Consecutivos en Base de Datos de Korex
        const idArray = idsStr.split(',').map((id: string) => parseInt(id.trim(), 10)).filter((n: number) => !isNaN(n));
        if (spResult.length > 0) {
            if (isSQLServerMode()) {
                for (const item of spResult) {
                    const invId = Number(item.invoiceId || item.Factura || item.id_factura || item.id || (idArray.length === 1 ? idArray[0] : 0));
                    const isOk = checkItemSuccess(item);
                    if (isOk && invId > 0) {
                        const rawMsg = getItemMessage(item);
                        const match = rawMsg.match(/([A-Z0-9]{2})-([A-Z0-9]{2})-?([0-9]{8})/i) || rawMsg.match(/([0-9]{8,10})/i);
                        const fuente = match && match[2] ? match[1] : '55';
                        const serie = match && match[2] ? match[2] : '66';
                        const consecutivo = match ? (match[3] || match[1]) : null;
                        const zeusNum = (serie && consecutivo) ? (consecutivo.startsWith(serie) ? consecutivo : `${serie}${consecutivo}`) : consecutivo;
                        try {
                            const pool = await getSQLServerConnection();
                            await pool.request().query(
                                `UPDATE dbo.[Invoices] SET [state] = 'EXPORTED'${consecutivo ? `, consecutivo = '${consecutivo}', serie = '${serie}', fuente = '${fuente}', zeusInvoiceNumber = '${zeusNum}'` : ''} WHERE id = ${invId}`
                            );
                            await pool.close();
                        } catch (uErr: any) {
                            console.warn('[ZEUS_AUTO_EXPORT] Error actualizando estado de factura SQL Server:', uErr.message);
                        }
                    }
                }
            } else {
                try {
                    await executePostgresQuery(
                        `CALL public."spFacturaActualizarEstado"($1::JSONB)`,
                        [JSON.stringify(spResult)]
                    );
                } catch (spPgError: any) {
                    console.warn('[ZEUS_AUTO_EXPORT] Error al actualizar estado en Postgres:', spPgError.message);
                }
            }
        }

        await registerLog(
            userId,
            'INVOICE',
            success ? 'AUTO_EXPORT_SUCCESS' : 'AUTO_EXPORT_SP_ERROR',
            `ID(s) ${idsStr}: Exportación automática de facturación completada (${success ? 'Éxito' : 'Con errores'})`,
            { spResult, targetDb }
        );

        return {
            exported: true,
            success,
            message: success ? 'Factura exportada automáticamente a Zeus ERP' : 'Exportación con observaciones en Zeus ERP',
            spResult,
            xml: xmlStr
        };
    } catch (error: any) {
        console.error(`[ZEUS_AUTO_EXPORT] Excepción en exportación automática de factura [${idsStr}]:`, error.message);
        await registerLog(userId, 'INVOICE', 'AUTO_EXPORT_EXCEPTION', `ID(s) ${idsStr}: ${error.message}`, { error: error.message });
        return { exported: false, success: false, message: error.message };
    }
}
