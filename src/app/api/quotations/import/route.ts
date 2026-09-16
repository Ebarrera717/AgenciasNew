import { NextRequest, NextResponse } from 'next/server'
import { registerLog } from '@/lib/logger'
import { executeSQLServerProcedure } from '@/lib/sqlserver'
import { executePostgresQuery } from '@/lib/postgres'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'
import { getNextTransactionConsecutive } from '@/lib/consecutives'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
    const startTime = Date.now();
    const traceCode = generateTraceCode();
    const userIdHeader = req.headers.get('X-User-Id');
    const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1;

    try {
        const rows = await req.json()
        if (!Array.isArray(rows) || rows.length === 0) {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                origin: 'EXCEL',
                module: 'Cotizaciones',
                screen: 'Importación Excel',
                action: 'IMPORTAR_EXCEL_COTIZACIONES',
                process: 'Validación de Archivo',
                eventType: 'ERROR',
                stepName: 'Archivo Vacío',
                endpoint: '/api/quotations/import',
                durationMs: Date.now() - startTime,
                status: 'ERROR',
                functionalMessage: 'El archivo Excel está vacío o no es válido'
            });
            return NextResponse.json({ message: 'El archivo está vacío o no es válido' }, { status: 400 })
        }

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            origin: 'EXCEL',
            module: 'Cotizaciones',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_COTIZACIONES',
            process: 'Procesamiento de Filas Excel',
            eventType: 'INICIO_PROCESO',
            stepName: `Recepción de ${rows.length} filas Excel`,
            endpoint: '/api/quotations/import',
            inputData: { rowCount: rows.length, sampleRow: rows[0] },
            status: 'IN_PROGRESS'
        });

        // MOTOR ACTIVO = UNA ÚNICA INFRAESTRUCTURA (Skill: motor-engine-isolation)
        const { isSQLServerMode, getSQLServerConnection } = await import('@/lib/sqlserver');
        if (isSQLServerMode()) {
            console.log('[IMPORT_QUOTATIONS_SQLSERVER] Motor Activo: SQL Server. Procesando importación 100% nativa en SQL Server (Korex_pruebas)...');
            const mssql = (await import('mssql')).default;
            const pool = await getSQLServerConnection();
            
            const grouped = new Map<string, any[]>();
            for (const r of rows) {
                const key = (r.Grupo_Cotizacion || '1').toString();
                if (!grouped.has(key)) grouped.set(key, []);
                grouped.get(key)!.push(r);
            }

            const createdIds: number[] = [];
            const createdConsecutives: string[] = [];

            for (const [groupKey, items] of grouped.entries()) {
                const first = items[0];
                
                // 1. Resolver Cliente
                const clientDoc = (first.Cliente_Documento || '').toString().trim();
                let clientId = 1;
                if (clientDoc) {
                    const clientRes = await pool.request()
                        .input('doc', mssql.VarChar, clientDoc)
                        .query(`SELECT TOP 1 id FROM dbo.[Client] WHERE document = @doc`);
                    if (clientRes.recordset && clientRes.recordset.length > 0) {
                        clientId = clientRes.recordset[0].id;
                    } else {
                        const newClientRes = await pool.request()
                            .input('name', mssql.VarChar, first.Cliente_Nombre || `Cliente ${clientDoc}`)
                            .input('doc', mssql.VarChar, clientDoc)
                            .query(`INSERT INTO dbo.[Client] (name, document) OUTPUT INSERTED.id VALUES (@name, @doc)`);
                        if (newClientRes.recordset && newClientRes.recordset.length > 0) {
                            clientId = newClientRes.recordset[0].id;
                        }
                    }
                }

                // 2. Resolver Sucursal, Implante, Vendedor, Tiqueteador
                let branchId = 1;
                if (first.Sucursal_Codigo) {
                    const bRes = await pool.request().input('code', mssql.VarChar, first.Sucursal_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Branch] WHERE code = @code`);
                    if (bRes.recordset && bRes.recordset.length > 0) branchId = bRes.recordset[0].id;
                }
                let implantId: number | null = null;
                if (first.Implant_Codigo) {
                    const iRes = await pool.request().input('code', mssql.VarChar, first.Implant_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Implant] WHERE code = @code`);
                    if (iRes.recordset && iRes.recordset.length > 0) implantId = iRes.recordset[0].id;
                }
                let sellerId: number | null = null;
                if (first.Vendedor_Codigo) {
                    const sRes = await pool.request().input('code', mssql.VarChar, first.Vendedor_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Seller] WHERE code = @code`);
                    if (sRes.recordset && sRes.recordset.length > 0) sellerId = sRes.recordset[0].id;
                }
                let ticketPrinterId: number | null = null;
                if (first.Tiqueteador_Codigo) {
                    const tRes = await pool.request().input('code', mssql.VarChar, first.Tiqueteador_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[TicketPrinter] WHERE code = @code`);
                    if (tRes.recordset && tRes.recordset.length > 0) ticketPrinterId = tRes.recordset[0].id;
                }

                const consecInfo = await getNextTransactionConsecutive('QUOTATION', branchId, implantId);
                const internalNum = first.Consecutivo 
                    ? (first.Serie ? `${first.Serie}-${first.Consecutivo}` : first.Consecutivo)
                    : consecInfo.formattedConsecutive;
                const globalCargos = parseFloat(first.Cargos_A_Cotizacion || '0');
                const currency = first.Moneda || 'COP';
                const exchangeRate = parseFloat(first.Tasa_Cambio || '1');
                const commissionPct = parseFloat(first.Comision_Global_Pct || '0');

                // Insert Quotation Header
                const qRes = await pool.request()
                    .input('internalNumber', mssql.VarChar, internalNum)
                    .input('clientId', mssql.Int, clientId)
                    .input('currency', mssql.VarChar, currency)
                    .input('exchangeRate', mssql.Float, exchangeRate)
                    .input('branchId', mssql.Int, branchId)
                    .input('implantId', mssql.Int, implantId)
                    .input('sellerId', mssql.Int, sellerId)
                    .input('ticketPrinterId', mssql.Int, ticketPrinterId)
                    .input('commissionPercentage', mssql.Float, commissionPct)
                    .input('chargesAndTaxes', mssql.Float, globalCargos)
                    .input('totalAmount', mssql.Float, 0)
                    .input('userId', mssql.Int, actingUserId)
                    .query(`
                        INSERT INTO dbo.[Quotation] (
                            internalNumber, clientId, currency, exchangeRate, branchId, implantId, sellerId,
                            ticketPrinterId, commissionPercentage, chargesAndTaxes, totalAmount, userId
                        ) OUTPUT INSERTED.id VALUES (
                            @internalNumber, @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId,
                            @ticketPrinterId, @commissionPercentage, @chargesAndTaxes, @totalAmount, @userId
                        )
                    `);

                const quotationId = qRes.recordset[0].id;
                createdIds.push(quotationId);
                createdConsecutives.push(internalNum);

                let quotationTotalSum = globalCargos;

                // Insert Items
                for (const it of items) {
                    let productId = 1;
                    if (it.Producto_Codigo) {
                        const pRes = await pool.request().input('code', mssql.VarChar, it.Producto_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Product] WHERE code = @code`);
                        if (pRes.recordset && pRes.recordset.length > 0) productId = pRes.recordset[0].id;
                    }
                    let providerId: number | null = null;
                    if (it.Proveedor_Codigo) {
                        const prRes = await pool.request().input('code', mssql.VarChar, it.Proveedor_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Provider] WHERE code = @code`);
                        if (prRes.recordset && prRes.recordset.length > 0) providerId = prRes.recordset[0].id;
                    }

                    const rawPrice = it.Precio_Unitario ?? it['Precio Unitario'] ?? it.Precio ?? '0';
                    let itemPrice = parseFloat(rawPrice || '0');
                    const quantity = parseInt(it.Cantidad || '1', 10);
                    const cost = parseFloat(it.Costo || '0');

                    await pool.request()
                        .input('quotationId', mssql.Int, quotationId)
                        .input('productId', mssql.Int, productId)
                        .input('quantity', mssql.Int, quantity)
                        .input('price', mssql.Float, itemPrice)
                        .input('cost', mssql.Float, cost)
                        .input('providerId', mssql.Int, providerId)
                        .query(`
                            INSERT INTO dbo.[QuotationProduct] (
                                quotationId, productId, quantity, price, cost, providerId
                            ) VALUES (
                                @quotationId, @productId, @quantity, @price, @cost, @providerId
                            )
                        `);

                    quotationTotalSum += (itemPrice * quantity);
                }

                // Update Total
                await pool.request().input('id', mssql.Int, quotationId).input('total', mssql.Float, quotationTotalSum).query(`UPDATE dbo.[Quotation] SET totalAmount = @total WHERE id = @id`);
            }

            await pool.close();

            const createdConsecutiveStr = createdConsecutives.join(', ');
            const dbMessage = `SUCCESS: ${createdIds.length} cotizaciones importadas nativamente en SQL Server (Korex_pruebas). [${createdConsecutiveStr}]`;

            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                origin: 'EXCEL',
                module: 'Cotizaciones',
                screen: 'Importación Excel SQL Server',
                action: 'IMPORTAR_EXCEL_COTIZACIONES_SQLSERVER',
                process: 'Fin Importación SQL Server Nativo',
                eventType: 'FIN_PROCESO',
                stepName: 'Importación Excel Completada en SQL Server',
                endpoint: '/api/quotations/import',
                durationMs: Date.now() - startTime,
                status: 'SUCCESS',
                outputData: { detail: dbMessage, importedCount: grouped.size, createdIds, createdConsecutives },
                functionalMessage: dbMessage
            });

            return NextResponse.json({
                message: 'Importación finalizada',
                detail: dbMessage,
                importedCount: grouped.size,
                createdIds,
                createdConsecutives
            });
        }

        // 1. Convertir el array de objetos a un string delimitado (Texto Plano)
        const textData = rows.map((row: any) => {
            const cols = [
                row.Grupo_Cotizacion || '',
                row.Cliente_Documento || '',
                row.Sucursal_Codigo || '',
                row.Implant_Codigo || '',
                row.Vendedor_Codigo || '',
                row.Tiqueteador_Codigo || '',
                row.Moneda || '',
                row.Tasa_Cambio || '',
                row.Comision_Global_Pct || '',
                row.Cargos_A_Cotizacion || '',
                row.Producto_Codigo || '',
                '', // Proveedor_Nombre
                row.Proveedor_Codigo || '',
                row.Prestadora_Codigo || row.Hotel_Codigo || row.Hotel_id || '', // Soporte para alias de columna
                row.Impuestos_Nombres_Y_Valores || '',
                row.Variables_Codigos_Y_Valores || '',
                row.Pasajeros || '',
                row.Precio_Unitario || '',
                row.Cantidad || '',
                row.CheckIn || '',
                row.CheckOut || '',
                row.Pax_Adultos || '',
                row.Pax_Ninos || '',
                row.Destino || '',
                row.Tipo_Servicio || '',
                row.Reserva || '',
                row.Comision_Vendedor_Producto || '',
                row.Comision_Tiqueteador_Producto || '',
                row.Combo_Codigos || '',
                row.Nacionalidad || '1',
                row.Cargo_Principal || ''
            ];
            // Limpieza profunda: evitar que caracteres especiales rompan el formato caret (^)
            return cols.map(c => (c !== undefined && c !== null ? c.toString().replace(/\^/g, ' ') : '')).join('^');
        }).join('\n');

        // 2. Ejecutar el Stored Procedure enviando el TEXTO
        const result: any[] = await executePostgresQuery(
            `CALL public."spImportQuotation"($1, $2, $3)`,
            [textData, actingUserId, '']
        );

        // Extraer mensaje
        const rowData = result && result.length > 0 ? result[0] : null;
        let dbMessage = (rowData?.p_mensaje_resultado || rowData?.mensaje_resultado || (rowData ? Object.values(rowData)[0] : '')) as string;
        
        console.log('[Import API] SP Result:', dbMessage);

        if (dbMessage.startsWith('ERROR')) {
            throw new Error(dbMessage);
        }

        // 3. Extraer IDs de las cotizaciones creadas
        const idMatch = dbMessage.match(/(?:ID_LIST)?\[([^\]]+)\]/);
        const createdIdsStr = idMatch ? idMatch[1] : '';
        const createdIds = createdIdsStr ? createdIdsStr.split(',').map((id: string) => parseInt(id.trim())).filter(id => !isNaN(id)) : [];

        let createdConsecutives: string[] = [];
        if (createdIds.length > 0) {
            try {
                const fetched: any[] = await executePostgresQuery(
                    `SELECT id, "internalNumber" FROM public."Quotation" WHERE id = ANY($1::int[])`,
                    [createdIds]
                );
                const mapIdToConsec = new Map(fetched.map(f => [f.id, f.internalNumber || f.id.toString()]));
                createdConsecutives = createdIds.map(id => mapIdToConsec.get(id) || id.toString());
                const createdConsecutiveStr = createdConsecutives.join(', ');
                dbMessage = dbMessage.replace(/\[[^\]]+\]/, `[${createdConsecutiveStr}]`);
            } catch (e) {
                console.warn('[IMPORT API] Could not fetch internalNumbers for created quotations:', e);
            }
        }

        // 4. Auditoría de la importación
        await registerLog(
            actingUserId,
            'QUOTATION',
            'IMPORT',
            `Importación masiva mediante SP. Filas: ${rows.length}. IDs creados: ${createdIdsStr}`,
            { rowCount: rows.length, dbMessage, createdIds }
        );

        // Exportación opcional a Zeus ERP solo si la regla de parámetro automático está explícitamente habilitada (value === '1')
        let autoExportResult = null;
        if (createdIds.length > 0) {
            let autoExportParamVal = '0';
            try {
                const paramRows: any[] = await executePostgresQuery(
                    `SELECT "value" FROM public."SystemParameter" WHERE "code" = $1`,
                    ['EnviarCotizacionesAutoSQLserver']
                );
                if (paramRows && paramRows.length > 0) autoExportParamVal = paramRows[0].value;
            } catch (e) {}

            const shouldExportToZeusERP = autoExportParamVal === '1';

            if (shouldExportToZeusERP) {
                try {
                    console.log(`[EXPORT_ZEUS_ERP] Exportando automáticamente a Zeus ERP para IDs: ${createdIdsStr}`);
                    
                    // Obtener XML desde Postgres
                    const exportResult: any[] = await executePostgresQuery(
                        `CALL spexportquotation($1, $2, $3)`,
                        [createdIdsStr, actingUserId, '']
                    );

                    const row = exportResult && exportResult.length > 0 ? exportResult[0] : null;
                    const xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;

                    if (xmlStr && typeof xmlStr === 'string' && !xmlStr.startsWith('ERROR')) {
                        const sqlResult = await executeSQLServerProcedure('spCotizacionesCrear', { xml: xmlStr });
                        
                        autoExportResult = { success: true, message: 'Exportado automáticamente a SQL Server', sqlResult };
                        await registerLog(actingUserId, 'QUOTATION', 'AUTO_EXPORT_SUCCESS', `ID(s) ${createdIdsStr}: Exportación automática exitosa`, { sqlResult });
                    } else {
                        autoExportResult = { success: false, message: 'No se generó XML válido para exportación automática' };
                        await registerLog(actingUserId, 'QUOTATION', 'AUTO_EXPORT_ERROR', `ID(s) ${createdIdsStr}: Error en generación de XML`, { xml: xmlStr });
                    }
                } catch (exportError: any) {
                    console.error('[AUTO_EXPORT] Error:', exportError.message);
                    autoExportResult = { success: false, error: exportError.message };
                    await registerLog(actingUserId, 'QUOTATION', 'AUTO_EXPORT_SQL_ERROR', `ID(s) ${createdIdsStr}: ${exportError.message}`, { error: exportError.message });
                }
            }
        }

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            origin: 'EXCEL',
            module: 'Cotizaciones',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_COTIZACIONES',
            process: 'Fin Importación Excel',
            eventType: 'FIN_PROCESO',
            stepName: 'Importación Excel Completada',
            endpoint: '/api/quotations/import',
            durationMs: Date.now() - startTime,
            status: 'SUCCESS',
            outputData: { detail: dbMessage, importedCount: rows.length, createdIds, autoExportResult },
            functionalMessage: dbMessage
        });

        return NextResponse.json({ 
            message: 'Importación finalizada',
            detail: dbMessage,
            importedCount: rows.length,
            createdIds,
            autoExport: autoExportResult
        })
    } catch (error: any) {
        console.error('Import error (via SP TEXT):', error);

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            origin: 'EXCEL',
            module: 'Cotizaciones',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_COTIZACIONES',
            process: 'Excepción Capturada',
            eventType: 'EXCEPCION',
            stepName: 'Fallo al Procesar Excel',
            endpoint: '/api/quotations/import',
            durationMs: Date.now() - startTime,
            status: 'ERROR',
            functionalMessage: error.message,
            techMessage: error.toString(),
            stackTrace: error.stack
        });
        
        // Registrar error catastrófico en auditoría
        await registerLog(userIdHeader ? parseInt(userIdHeader) : 1, 'QUOTATION', 'IMPORT_CRITICAL_ERROR', error.message, { stack: error.stack });

        return NextResponse.json({ 
            message: `Error durante la importación: ${error.message}`, 
            error: error.message,
            detail: error.toString()
        }, { status: 500 })
    }
}
