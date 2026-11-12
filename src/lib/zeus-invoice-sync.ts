import prisma from '@/lib/prisma';
import { isSQLServerMode, getZeusSQLServerConnection, getSQLServerConnection } from '@/lib/sqlserver';

let isSyncing = false;
let lastSyncTimestamp = 0;
const MIN_SYNC_INTERVAL_MS = 25000; // Throttle: Máximo una ejecución en segundo plano cada 25 segundos

/**
 * Dispara la sincronización de facturas de Zeus ERP hacia Korex en segundo plano.
 * No es bloqueante (fire-and-forget), garantizando 0 ms de sobrecarga en la respuesta HTTP.
 */
export function triggerZeusInvoiceSyncInBackground(): void {
    const now = Date.now();
    if (isSyncing || (now - lastSyncTimestamp < MIN_SYNC_INTERVAL_MS)) {
        return;
    }

    isSyncing = true;
    setImmediate(async () => {
        try {
            await syncZeusInvoices();
        } catch (err: any) {
            console.error('[ZEUS_INVOICE_SYNC] Error en sincronización en segundo plano:', err?.message || err);
        } finally {
            isSyncing = false;
            lastSyncTimestamp = Date.now();
        }
    });
}

/**
 * Ejecuta la sincronización de facturas asociadas a cotizaciones desde Zeus ERP hacia Korex.
 * Consulta de forma no bloqueante (WITH (NOLOCK)) las cotizaciones facturadas en Zeus ERP
 * y actualiza zeusInvoiceNumber, zeusInvoiceDate y estado ('FACTURADO') en Korex.
 */
export async function syncZeusInvoices(): Promise<{ syncedCount: number; message: string; details?: any[] }> {
    let zeusPool: any = null;
    try {
        zeusPool = await getZeusSQLServerConnection();
    } catch (connErr: any) {
        console.warn('[ZEUS_INVOICE_SYNC] No fue posible conectar con Zeus ERP:', connErr?.message || connErr);
        return { syncedCount: 0, message: 'Zeus ERP no disponible o no configurado' };
    }

    try {
        // En Zeus ERP: consultar cotizaciones que tienen factura asociada usando WITH (NOLOCK)
        const zeusResult = await zeusPool.request().query(`
            SELECT 
                c.id AS id_cotizacion,
                LTRIM(RTRIM(c.cd_consecutivo)) AS zeus_consecutivo,
                cf.id_fac_factura,
                LTRIM(RTRIM(f.numero)) AS numero_factura,
                f.dt_fecha AS fecha_factura
            FROM dbo.Cotizacion c WITH (NOLOCK)
            INNER JOIN dbo.Cotizacion_facturas cf WITH (NOLOCK) ON cf.id_cotizacion = c.id
            INNER JOIN dbo.Fac_Factura f WITH (NOLOCK) ON f.id = cf.id_fac_factura
            WHERE f.numero IS NOT NULL AND LTRIM(RTRIM(f.numero)) <> ''
        `);

        const records = zeusResult.recordset || [];
        if (records.length === 0) {
            return { syncedCount: 0, message: 'No hay cotizaciones con factura vinculada en Zeus ERP' };
        }

        let updatedCount = 0;
        const details: any[] = [];

        if (isSQLServerMode()) {
            const korexPool = await getSQLServerConnection();
            try {
                for (const row of records) {
                    const parsedId = parseInt(row.zeus_consecutivo, 10);
                    const invNumber = String(row.numero_factura || '').trim();
                    const invDate = row.fecha_factura ? new Date(row.fecha_factura) : null;
                    if (!invNumber) continue;

                    const res = await korexPool.request()
                        .input('invNumber', invNumber)
                        .input('invDate', invDate)
                        .input('quotId', isNaN(parsedId) ? -1 : parsedId)
                        .input('internalNum', String(row.zeus_consecutivo || '').trim())
                        .query(`
                            UPDATE dbo.[Quotation]
                            SET [zeusInvoiceNumber] = @invNumber,
                                [zeusInvoiceDate] = @invDate,
                                [state] = CASE WHEN UPPER(ISNULL([state], '')) = 'ENVIADO' THEN 'FACTURADO' ELSE [state] END
                            WHERE ([id] = @quotId OR [internalNumber] = @internalNum OR [internalNumber] = CAST(@quotId AS NVARCHAR(50)))
                              AND ([zeusInvoiceNumber] IS NULL OR [zeusInvoiceNumber] <> @invNumber)
                        `);

                    if (res.rowsAffected && res.rowsAffected[0] > 0) {
                        updatedCount += res.rowsAffected[0];
                        details.push({
                            cotizacionId: isNaN(parsedId) ? row.zeus_consecutivo : parsedId,
                            facturaNumero: invNumber,
                            fechaFactura: invDate
                        });
                    }
                }
            } finally {
                await korexPool.close();
            }
        } else {
            // PostgreSQL Mode
            for (const row of records) {
                const parsedId = parseInt(row.zeus_consecutivo, 10);
                const invNumber = String(row.numero_factura || '').trim();
                const invDate = row.fecha_factura ? new Date(row.fecha_factura) : null;
                if (!invNumber) continue;

                const quotId = isNaN(parsedId) ? -1 : parsedId;
                const internalNum = String(row.zeus_consecutivo || '').trim();

                const updated: any = await prisma.$executeRawUnsafe(`
                    UPDATE public."Quotation"
                    SET "zeusInvoiceNumber" = $1,
                        "zeusInvoiceDate" = $2,
                        "state" = CASE WHEN UPPER(COALESCE("state", '')) = 'ENVIADO' THEN 'FACTURADO' ELSE "state" END
                    WHERE (id = $3 OR "internalNumber" = $4 OR "internalNumber" = $3::text)
                      AND ("zeusInvoiceNumber" IS NULL OR "zeusInvoiceNumber" <> $1)
                `, invNumber, invDate, quotId, internalNum);

                if (Number(updated) > 0) {
                    updatedCount += Number(updated);
                    details.push({
                        cotizacionId: quotId,
                        facturaNumero: invNumber,
                        fechaFactura: invDate
                    });
                }
            }
        }

        if (updatedCount > 0) {
            console.log(`[ZEUS_INVOICE_SYNC] ✅ Sincronización exitosa: ${updatedCount} cotización(es) actualizada(s) con número de factura de Zeus.`);
        }

        return {
            syncedCount: updatedCount,
            message: `Sincronización finalizada. Cotizaciones actualizadas: ${updatedCount}`,
            details
        };
    } finally {
        if (zeusPool) {
            try {
                await zeusPool.close();
            } catch (_) {}
        }
    }
}
