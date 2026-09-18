import { NextRequest, NextResponse } from 'next/server'
import { registerLog } from '@/lib/logger'
import { executeSQLServerProcedure, isSQLServerMode, getZeusERPDatabaseName } from '@/lib/sqlserver'
import { executePostgresQuery } from '@/lib/postgres'
import { generateTraceCode, recordTraceEvent } from '@/lib/traceability'
import { getNextTransactionConsecutive } from '@/lib/consecutives'

export const dynamic = 'force-dynamic'

function normalizeDateString(val: any): string {
    if (!val) return '';
    if (val instanceof Date) {
        if (!isNaN(val.getTime())) {
            return val.toISOString().substring(0, 10);
        }
        return '';
    }
    let str = val.toString().trim();
    if (!str) return '';

    // Convert Excel serial date (e.g., 46296 -> 2026-10-01)
    const num = Number(str);
    if (!isNaN(num) && num > 30000 && num < 100000) {
        const dateObj = new Date(Math.round((num - 25569) * 86400 * 1000));
        if (!isNaN(dateObj.getTime())) {
            return dateObj.toISOString().substring(0, 10);
        }
    }

    // Replace slashes with dashes
    str = str.replace(/\//g, '-');

    // Standard YYYY-MM-DD
    if (/^\d{4}-\d{2}-\d{2}/.test(str)) {
        return str;
    }

    // DD-MM-YYYY or D-M-YYYY
    const dmyMatch = str.match(/^(\d{1,2})-(\d{1,2})-(\d{4})/);
    if (dmyMatch) {
        const day = dmyMatch[1].padStart(2, '0');
        const month = dmyMatch[2].padStart(2, '0');
        const year = dmyMatch[3];
        return `${year}-${month}-${day}`;
    }

    return str;
}

function extractNumericValue(val: any): string {
    if (val === undefined || val === null) return '';
    let str = val.toString().trim();
    if (!str) return '';

    if (!isNaN(Number(str))) return str;

    if (str.includes(':')) {
        const parts = str.split(':');
        str = parts[parts.length - 1].trim();
        if (!isNaN(Number(str))) return str;
    }

    str = str.replace(/[$A-Za-z\s]/g, '');

    if (/^\d{1,3}(\.\d{3})+(,\d+)?$/.test(str)) {
        str = str.replace(/\./g, '').replace(',', '.');
    } else if (/^\d{1,3}(,\d{3})+(\.\d+)?$/.test(str)) {
        str = str.replace(/,/g, '');
    } else if (/^\d+,\d+$/.test(str)) {
        str = str.replace(',', '.');
    }

    const cleanStr = str.replace(/[^0-9.-]/g, '');
    if (cleanStr && !isNaN(Number(cleanStr))) {
        return cleanStr;
    }

    return str;
}

function getExcelVariableString(row: any): string {
    if (!row || typeof row !== 'object') return '';
    const explicit = row.Variables_Codigos_Y_Valores || row.Variables_Cotizacion || row.Variables_Adicionales || 
                     row.Variables_Codigos || row.Variables_Co || row.Variables || 
                     row['Variables_Codigos_Y_Valores'] || row['Variables Codigos Y Valores'] || 
                     row['Variables_Co'] || row['Variables_Cotizacion'] || row['Variables_Adicionales'] || row['Variables'];
    if (explicit !== undefined && explicit !== null && explicit !== '') {
        return explicit.toString().trim();
    }
    for (const key of Object.keys(row)) {
        if (/^variables?/i.test(key.trim())) {
            const val = row[key];
            if (val !== undefined && val !== null && val.toString().trim() !== '') {
                return val.toString().trim();
            }
        }
    }
    return '';
}

export async function POST(req: NextRequest) {
    const startTime = Date.now();
    const traceCode = generateTraceCode();
    const userIdHeader = req.headers.get('X-User-Id');
    const actingUserId: number = userIdHeader ? parseInt(userIdHeader, 10) : 1;

    try {
        const rows = await req.json()
        if (!Array.isArray(rows) || rows.length === 0) {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                origin: 'EXCEL',
                module: 'Facturación',
                screen: 'Importación Excel',
                action: 'IMPORTAR_EXCEL_FACTURAS',
                process: 'Validación de Archivo',
                eventType: 'ERROR',
                stepName: 'Archivo Vacío',
                endpoint: '/api/invoices/import',
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
            module: 'Facturación',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_FACTURAS',
            process: 'Procesamiento de Filas Excel',
            eventType: 'INICIO_PROCESO',
            stepName: `Recepción de ${rows.length} filas Excel`,
            endpoint: '/api/invoices/import',
            inputData: { rowCount: rows.length, sampleRow: rows[0] },
            status: 'IN_PROGRESS'
        });

        // MOTOR ACTIVO = UNA ÚNICA INFRAESTRUCTURA (Skill: motor-engine-isolation)
        if (isSQLServerMode()) {
            console.log('[IMPORT_API] Motor Activo: SQL Server. Procesando importación 100% nativa en SQL Server (Korex_pruebas)...');
            const mssql = (await import('mssql')).default;
            const { getSQLServerConnection } = await import('@/lib/sqlserver');
            
            const pool = await getSQLServerConnection();

            // Filtrar filas vacías de la hoja de Excel
            const validRows = rows.filter((r: any) => {
                if (!r || typeof r !== 'object') return false;
                return Boolean(
                    r.Cliente_Documento || r.Producto_Codigo || r.Precio_Unitario || r.Cargos_A_Factura || r.Proveedor_Codigo || r.Pasajeros
                );
            });

            const grouped = new Map<string, any[]>();
            for (const r of validRows) {
                const key = (r.Grupo_Factura || '1').toString().trim();
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

                // 2. Resolver Sucursal, Implante, Vendedor, Tiqueteador con Validación Estricta por Código
                let branchId = 1;
                if (first.Sucursal_Codigo) {
                    const bCode = first.Sucursal_Codigo.toString().trim();
                    const bRes = await pool.request().input('code', mssql.VarChar, bCode).query(`SELECT TOP 1 id FROM dbo.[Branch] WHERE UPPER(code) = UPPER(@code)`);
                    if (bRes.recordset && bRes.recordset.length > 0) {
                        branchId = bRes.recordset[0].id;
                    } else {
                        await pool.close();
                        return NextResponse.json({ message: `ERROR: La Sucursal con código '${bCode}' no existe en el sistema.` }, { status: 400 });
                    }
                }

                let implantId: number | null = null;
                if (first.Implant_Codigo) {
                    const iCode = first.Implant_Codigo.toString().trim();
                    const iRes = await pool.request().input('code', mssql.VarChar, iCode).query(`SELECT TOP 1 id FROM dbo.[Implant] WHERE UPPER(code) = UPPER(@code)`);
                    if (iRes.recordset && iRes.recordset.length > 0) {
                        implantId = iRes.recordset[0].id;
                    } else {
                        await pool.close();
                        return NextResponse.json({ message: `ERROR: El Implante con código '${iCode}' no existe en el sistema.` }, { status: 400 });
                    }
                }

                let sellerId: number | null = null;
                if (first.Vendedor_Codigo) {
                    const sCode = first.Vendedor_Codigo.toString().trim();
                    const sRes = await pool.request()
                        .input('code', mssql.VarChar, sCode)
                        .query(`SELECT TOP 1 id FROM dbo.[Seller] WHERE UPPER(code) = UPPER(@code)`);
                    if (sRes.recordset && sRes.recordset.length > 0) {
                        sellerId = sRes.recordset[0].id;
                    } else {
                        await pool.close();
                        return NextResponse.json({ message: `ERROR: El Vendedor con código '${sCode}' no está registrado en la maestría de Vendedores. La factura no fue subida.` }, { status: 400 });
                    }
                }

                let ticketPrinterId: number | null = null;
                if (first.Tiqueteador_Codigo) {
                    const tCode = first.Tiqueteador_Codigo.toString().trim();
                    const tRes = await pool.request()
                        .input('code', mssql.VarChar, tCode)
                        .query(`SELECT TOP 1 id FROM dbo.[TicketPrinter] WHERE UPPER(code) = UPPER(@code)`);
                    if (tRes.recordset && tRes.recordset.length > 0) {
                        ticketPrinterId = tRes.recordset[0].id;
                    } else {
                        await pool.close();
                        return NextResponse.json({ message: `ERROR: El Tiqueteador con código '${tCode}' no está registrado en la maestría de Tiqueteadores. La factura no fue subida.` }, { status: 400 });
                    }
                }

                // 3. Consecutivo e Internal Number
                const consecInfo = await getNextTransactionConsecutive('INVOICE', branchId, implantId);
                const consecVal = first.Consecutivo ? first.Consecutivo.toString().trim() : consecInfo.consecutivoNumber.toString();
                const serieVal = first.Serie ? first.Serie.toString().trim() : (consecInfo.prefix || null);
                const fuenteVal = first.Fuente ? first.Fuente.toString().trim() : 'FE';
                const internalNum = first.Consecutivo 
                    ? (serieVal ? `${serieVal}-${consecVal}` : consecVal)
                    : consecInfo.formattedConsecutive;

                const globalCargos = parseFloat(extractNumericValue(first.Cargos_A_Factura) || '0');
                const currency = first.Moneda || 'COP';
                const exchangeRate = parseFloat(extractNumericValue(first.Tasa_Cambio) || '1');
                const commissionPct = parseFloat(extractNumericValue(first.Comision_Global_Pct) || '0');

                // Insert Header
                const invRes = await pool.request()
                    .input('internalNumber', mssql.VarChar, internalNum)
                    .input('clientId', mssql.Int, clientId)
                    .input('currency', mssql.VarChar, currency)
                    .input('exchangeRate', mssql.Float, exchangeRate)
                    .input('branchId', mssql.Int, branchId)
                    .input('implantId', mssql.Int, implantId)
                    .input('sellerId', mssql.Int, sellerId)
                    .input('ticketPrinterId', mssql.Int, ticketPrinterId)
                    .input('baseCommissionable', mssql.Float, 0)
                    .input('commissionPercentage', mssql.Float, commissionPct)
                    .input('chargesAndTaxes', mssql.Float, globalCargos)
                    .input('totalAmount', mssql.Float, 0)
                    .input('userId', mssql.Int, actingUserId)
                    .input('fuente', mssql.VarChar, fuenteVal)
                    .input('serie', mssql.VarChar, serieVal)
                    .input('consecutivo', mssql.VarChar, consecVal)
                    .query(`
                        INSERT INTO dbo.[Invoices] (
                            internalNumber, clientId, currency, exchangeRate, branchId, implantId, sellerId,
                            ticketPrinterId, baseCommissionable, commissionPercentage, chargesAndTaxes, totalAmount, userId, fuente, serie, consecutivo
                        ) OUTPUT INSERTED.id VALUES (
                            @internalNumber, @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId,
                            @ticketPrinterId, @baseCommissionable, @commissionPercentage, @chargesAndTaxes, @totalAmount, @userId, @fuente, @serie, @consecutivo
                        )
                    `);

                const invoiceId = invRes.recordset[0].id;
                createdIds.push(invoiceId);
                createdConsecutives.push(first.Consecutivo || internalNum);

                let invoiceTotalSum = 0;

                // Insert Items
                for (const it of items) {
                    let productId = 1;
                    if (it.Producto_Codigo) {
                        const pRes = await pool.request().input('code', mssql.VarChar, it.Producto_Codigo.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Product] WHERE code = @code`);
                        if (pRes.recordset && pRes.recordset.length > 0) productId = pRes.recordset[0].id;
                    }
                    let providerId: number | null = null;
                    if (it.Proveedor_Codigo) {
                        const prCode = it.Proveedor_Codigo.toString().trim();
                        const prRes = await pool.request().input('code', mssql.VarChar, prCode).query(`SELECT TOP 1 id FROM dbo.[Provider] WHERE UPPER(code) = UPPER(@code) OR UPPER(airlineCode) = UPPER(@code) OR UPPER(sigla) = UPPER(@code) OR UPPER(name) LIKE '%' + UPPER(@code) + '%'`);
                        if (prRes.recordset && prRes.recordset.length > 0) providerId = prRes.recordset[0].id;
                    }

                    const rawPrice = it.Precio_Unitario ?? it['Precio Unitario'] ?? it.Precio ?? it.Valor_Unitario ?? it.Valor ?? '0';
                    let itemPrice = parseFloat(extractNumericValue(rawPrice) || '0');
                    const quantity = parseInt(extractNumericValue(it.Cantidad) || '1', 10);
                    const cost = parseFloat(extractNumericValue(it.Costo) || '0');
                    const checkIn = normalizeDateString(it.CheckIn || it['Check-In'] || '');
                    const checkOut = normalizeDateString(it.CheckOut || it['Check-Out'] || '');

                    if (checkIn && checkOut && new Date(checkOut).getTime() < new Date(checkIn).getTime()) {
                        await pool.close();
                        return NextResponse.json({
                            message: `ERROR en Excel: La fecha final / Check-Out ('${checkOut}') no puede ser anterior a la fecha inicial / Check-In ('${checkIn}') para el ítem '${it.Producto_Codigo || 'Producto'}'. Por favor verifique el archivo Excel.`
                        }, { status: 400 });
                    }

                    const prodRes = await pool.request()
                        .input('invoiceId', mssql.Int, invoiceId)
                        .input('productId', mssql.Int, productId)
                        .input('quantity', mssql.Int, quantity)
                        .input('price', mssql.Float, itemPrice)
                        .input('cost', mssql.Float, cost)
                        .input('providerId', mssql.Int, providerId)
                        .input('checkInDate', mssql.VarChar, checkIn || null)
                        .input('checkOutDate', mssql.VarChar, checkOut || null)
                        .input('paxAdults', mssql.Int, parseInt(extractNumericValue(it.Pax_Adultos) || '1', 10))
                        .input('paxChildren', mssql.Int, parseInt(extractNumericValue(it.Pax_Ninos) || '0', 10))
                        .input('serviceType', mssql.VarChar, it.Tipo_Servicio || null)
                        .input('destination', mssql.VarChar, it.Destino || null)
                        .input('reservationCode', mssql.VarChar, it.Reserva || null)
                        .input('servicios', mssql.VarChar, it.Servicios || null)
                        .input('descripcion', mssql.VarChar, it.Descripcion || null)
                        .input('itinerary', mssql.VarChar, it.Itinerario || null)
                        .input('class', mssql.VarChar, it.Clase || null)
                        .input('airline', mssql.VarChar, it.Aerolinea || null)
                        .query(`
                            INSERT INTO dbo.[InvoicesProduct] (
                                invoiceId, productId, quantity, price, cost, providerId, checkInDate, checkOutDate,
                                paxAdults, paxChildren, serviceType, destination, reservationCode, servicios, descripcion, itinerary, class, airline
                            ) OUTPUT INSERTED.id VALUES (
                                @invoiceId, @productId, @quantity, @price, @cost, @providerId, TRY_CAST(@checkInDate AS DATETIME2), TRY_CAST(@checkOutDate AS DATETIME2),
                                @paxAdults, @paxChildren, @serviceType, @destination, @reservationCode, @servicios, @descripcion, @itinerary, @class, @airline
                            )
                        `);

                    const invoiceProductId = prodRes.recordset[0].id;
                    let itemTaxesSum = 0;

                    // Inserción de Impuestos / Cargos / Tarifa (InvoicesProductTax)
                    const itemTaxesToInsert: { taxCode: string; amount: number; isMain: boolean }[] = [];
                    const cargoStr = (it.Cargos_A_Factura || it.Cargo_Principal || '').toString().trim();
                    if (cargoStr) {
                        if (cargoStr.includes(':')) {
                            const parts = cargoStr.split(':');
                            const tCode = parts[0].trim();
                            const tAmt = parseFloat(extractNumericValue(parts[1]) || '0');
                            if (tCode && tAmt > 0) {
                                itemTaxesToInsert.push({ taxCode: tCode, amount: tAmt, isMain: true });
                            }
                        } else {
                            const tCode = cargoStr;
                            const tAmt = parseFloat(extractNumericValue(it.Cargos_A_Factura || rawPrice) || '0');
                            if (tCode && tAmt > 0) {
                                itemTaxesToInsert.push({ taxCode: tCode, amount: tAmt, isMain: true });
                            }
                        }
                    }

                    const taxStr = (it.Impuestos_Nombres_Y_Valores || '').toString().trim();
                    if (taxStr) {
                        const tItems = taxStr.split('|');
                        for (const tItem of tItems) {
                            if (!tItem.trim() || !tItem.includes(':')) continue;
                            const parts = tItem.split(':');
                            const tCode = parts[0].trim();
                            const tAmt = parseFloat(extractNumericValue(parts[1]) || '0');
                            if (tCode && tAmt > 0) {
                                if (!itemTaxesToInsert.some(x => x.taxCode.toUpperCase() === tCode.toUpperCase())) {
                                    itemTaxesToInsert.push({ taxCode: tCode, amount: tAmt, isMain: itemTaxesToInsert.length === 0 });
                                }
                            }
                        }
                    }

                    let mainTaxId: number | null = null;
                    for (const tObj of itemTaxesToInsert) {
                        let chargeAndTaxId: number | null = null;
                        const taxRes = await pool.request()
                            .input('code', mssql.VarChar, tObj.taxCode)
                            .query(`SELECT TOP 1 id, value, valueType FROM dbo.[ChargeAndTax] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) LIKE '%' + UPPER(@code) + '%'`);
                        
                        if (taxRes.recordset && taxRes.recordset.length > 0) {
                            chargeAndTaxId = taxRes.recordset[0].id;
                            const valSnapshot = taxRes.recordset[0].value || 0;
                            const valTypeSnapshot = taxRes.recordset[0].valueType || 'MONTO';
                            if (tObj.isMain) mainTaxId = chargeAndTaxId;

                            await pool.request()
                                .input('invoiceProductId', mssql.Int, invoiceProductId)
                                .input('chargeAndTaxId', mssql.Int, chargeAndTaxId)
                                .input('valueSnapshot', mssql.Float, valSnapshot)
                                .input('valueTypeSnapshot', mssql.VarChar, valTypeSnapshot)
                                .input('explicitAmount', mssql.Float, tObj.amount)
                                .input('isMain', mssql.Bit, tObj.isMain ? 1 : 0)
                                .query(`
                                    INSERT INTO dbo.[InvoicesProductTax] (
                                        invoiceProductId, chargeAndTaxId, valueSnapshot, valueTypeSnapshot, explicitAmount, isMain
                                    ) VALUES (
                                        @invoiceProductId, @chargeAndTaxId, @valueSnapshot, @valueTypeSnapshot, @explicitAmount, @isMain
                                    )
                                `);

                            itemTaxesSum += tObj.amount;
                        }
                    }

                    if (mainTaxId) {
                        await pool.request()
                            .input('id', mssql.Int, invoiceProductId)
                            .input('mainTaxId', mssql.Int, mainTaxId)
                            .query(`UPDATE dbo.[InvoicesProduct] SET mainTaxId = @mainTaxId WHERE id = @id`);
                    }

                    invoiceTotalSum += ((itemPrice * quantity) + itemTaxesSum);

                    // Inserción de Pagos
                    const pymtsStr = (it.Pagos || '').toString().trim();
                    if (pymtsStr) {
                        const pymtItems = pymtsStr.split('|');
                        for (const pItem of pymtItems) {
                            if (!pItem.trim()) continue;
                            const parts = pItem.split(':');
                            const amt = parseFloat(extractNumericValue(parts[0]?.trim()) || '0');
                            const method = parts[1]?.trim() || 'Efectivo';
                            const ref = parts.slice(2).join(':').trim();
                            await pool.request()
                                .input('invoiceProductId', mssql.Int, invoiceProductId)
                                .input('amount', mssql.Float, amt)
                                .input('paymentMethod', mssql.VarChar, method)
                                .input('reference', mssql.VarChar, ref || null)
                                .query(`INSERT INTO dbo.[InvoicesProductPayment] (invoiceProductId, amount, paymentMethod, reference) VALUES (@invoiceProductId, @amount, @paymentMethod, @reference)`);
                        }
                    }

                    // Inserción de Pasajeros
                    const paxStr = (it.Pasajeros || '').toString().trim();
                    if (paxStr) {
                        const paxItems = paxStr.split('|');
                        for (const paxItem of paxItems) {
                            if (!paxItem.trim()) continue;
                            const parts = paxItem.split(':');
                            await pool.request()
                                .input('invoiceProductId', mssql.Int, invoiceProductId)
                                .input('name', mssql.VarChar, parts[0]?.trim() || '')
                                .input('document', mssql.VarChar, parts[1]?.trim() || '')
                                .query(`INSERT INTO dbo.[InvoicesProductPasenger] (invoiceProductId, name, document) VALUES (@invoiceProductId, @name, @document)`);
                        }
                    }

                    // Inserción de Variables Adicionales (SystemParameterVariables / MasterVariables)
                    const varStr = getExcelVariableString(it);
                    if (varStr) {
                        const varItems = varStr.split('|');
                        for (const vItem of varItems) {
                            if (!vItem.trim() || !vItem.includes(':')) continue;
                            const parts = vItem.split(':');
                            const varCode = parts[0].trim();
                            const varVal = parts.slice(1).join(':').trim();
                            if (varCode && varVal) {
                                let masterVarId: number | null = null;
                                const mvRes = await pool.request()
                                    .input('code', mssql.VarChar, varCode)
                                    .query(`SELECT TOP 1 id FROM dbo.[MasterVariable] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) = UPPER(@code)`);
                                if (mvRes.recordset && mvRes.recordset.length > 0) {
                                    masterVarId = mvRes.recordset[0].id;
                                } else {
                                    const newMvRes = await pool.request()
                                        .input('code', mssql.VarChar, varCode)
                                        .input('name', mssql.VarChar, varCode)
                                        .query(`INSERT INTO dbo.[MasterVariable] (code, name) OUTPUT INSERTED.id VALUES (@code, @name)`);
                                    if (newMvRes.recordset && newMvRes.recordset.length > 0) {
                                        masterVarId = newMvRes.recordset[0].id;
                                    }
                                }

                                if (masterVarId) {
                                    await pool.request()
                                        .input('invoiceProductId', mssql.Int, invoiceProductId)
                                        .input('masterVariableId', mssql.Int, masterVarId)
                                        .input('value', mssql.VarChar, varVal)
                                        .query(`INSERT INTO dbo.[InvoicesProductVariable] (invoiceProductId, masterVariableId, value) VALUES (@invoiceProductId, @masterVariableId, @value)`);
                                }
                            }
                        }
                    }
                }

                // Update Total
                await pool.request().input('id', mssql.Int, invoiceId).input('total', mssql.Float, invoiceTotalSum).query(`UPDATE dbo.[Invoices] SET totalAmount = @total WHERE id = @id`);
            }

            await pool.close();

            const createdConsecutiveStr = createdConsecutives.join(', ');
            const dbMessage = `SUCCESS: ${createdIds.length} facturas importadas nativamente en SQL Server (Korex_pruebas). [${createdConsecutiveStr}]`;

            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                origin: 'EXCEL',
                module: 'Facturación',
                screen: 'Importación Excel SQL Server',
                action: 'IMPORTAR_EXCEL_FACTURAS_SQLSERVER',
                process: 'Fin Importación SQL Server Nativo',
                eventType: 'FIN_PROCESO',
                stepName: 'Importación Excel Completada en SQL Server',
                endpoint: '/api/invoices/import',
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

        // MOTOR ACTIVO: PostgreSQL
        console.log('[IMPORT API] Motor Activo: PostgreSQL. Procesando importación 100% nativa en PostgreSQL...');
        const textData = rows.map((row: any) => {
            const checkInClean = normalizeDateString(row.CheckIn || row['Check-In'] || row['Check_In'] || row.checkin || '');
            const checkOutClean = normalizeDateString(row.CheckOut || row['Check-Out'] || row['Check_Out'] || row.checkout || '');
            
            const cargosAFacturaRaw = (row.Cargos_A_Factura || '').toString().trim();
            const cargosAFacturaClean = extractNumericValue(cargosAFacturaRaw);
            
            let impuestosStr = row.Impuestos_Nombres_Y_Valores || '';
            if (!impuestosStr && cargosAFacturaRaw.includes(':')) {
                impuestosStr = cargosAFacturaRaw;
            }

            const cols = [
                row.Grupo_Factura || '',
                row.Cliente_Documento || '',
                row.Sucursal_Codigo || '',
                row.Implant_Codigo || '',
                row.Vendedor_Codigo || '',
                row.Tiqueteador_Codigo || '',
                row.Moneda || '',
                extractNumericValue(row.Tasa_Cambio || ''),
                extractNumericValue(row.Comision_Global_Pct || ''),
                cargosAFacturaClean,
                row.Producto_Codigo || '',
                row.Proveedor_Nombre || '',
                row.Proveedor_Codigo || '',
                row.Prestadora_Codigo || row.Hotel_Codigo || row.Hotel_id || '',
                impuestosStr,
                getExcelVariableString(row),
                row.Pasajeros || '',
                extractNumericValue(row.Precio_Unitario || ''),
                extractNumericValue(row.Cantidad || ''),
                checkInClean,
                checkOutClean,
                extractNumericValue(row.Pax_Adultos || ''),
                extractNumericValue(row.Pax_Ninos || ''),
                row.Destino || '',
                row.Tipo_Servicio || '',
                row.Reserva || '',
                extractNumericValue(row.Comision_Vendedor_Producto || ''),
                extractNumericValue(row.Comision_Tiqueteador_Producto || ''),
                row.Combo_Codigos || '',
                extractNumericValue(row.Nacionalidad || '1'),
                row.Cargo_Principal || '',
                extractNumericValue(row.Costo || ''),
                row.Servicios || '',
                row.Descripcion || '',
                row.Itinerario || '',
                row.Clase || '',
                row.Aerolinea || '',
                row.Tipo_Tiquete_Codigo || '',
                row.Pagos || '',
                row.Itinerarios || '',
                row.Fuente || '',
                row.Serie || '',
                row.Consecutivo || ''
            ];
            return cols.map(c => (c !== undefined && c !== null ? c.toString().replace(/\^/g, ' ') : '')).join('^');
        }).join('\n');

        const result: any[] = await executePostgresQuery(
            `CALL public."spImportInvoices"($1, $2, $3)`,
            [textData, actingUserId, '']
        );

        const rowData = result && result.length > 0 ? result[0] : null;
        let dbMessage = (rowData?.p_mensaje_resultado || rowData?.mensaje_resultado || (rowData ? Object.values(rowData)[0] : '')) as string;

        if (dbMessage.startsWith('ERROR')) {
            throw new Error(dbMessage);
        }

        const idMatch = dbMessage.match(/(?:ID_LIST)?\[([^\]]+)\]/);
        const createdIdsStr = idMatch ? idMatch[1] : '';
        const createdIds = createdIdsStr ? createdIdsStr.split(',').map((id: string) => parseInt(id.trim())).filter(id => !isNaN(id)) : [];

        let createdConsecutives: string[] = [];
        if (createdIds.length > 0) {
            try {
                const fetched: any[] = await executePostgresQuery(
                    `SELECT id, "internalNumber", consecutivo FROM public."Invoices" WHERE id = ANY($1::int[])`,
                    [createdIds]
                );
                const mapIdToConsec = new Map(fetched.map(f => [f.id, f.internalNumber || f.consecutivo || f.id.toString()]));
                createdConsecutives = createdIds.map(id => mapIdToConsec.get(id) || id.toString());
                const createdConsecutiveStr = createdConsecutives.join(', ');
                dbMessage = dbMessage.replace(/\[[^\]]+\]/, `[${createdConsecutiveStr}]`);
            } catch (e) {
                console.warn('[IMPORT API] Could not fetch internalNumbers for created invoices:', e);
            }
        }

        // Exportación opcional a Zeus ERP solo si la regla de parámetro automático está explícitamente habilitada (value === '1')
        let autoExportResult = null;
        if (createdIds.length > 0) {
            let autoExportParamVal = '0';
            try {
                const paramRows: any[] = await executePostgresQuery(
                    `SELECT "value" FROM public."SystemParameter" WHERE "code" = $1`,
                    ['EnviarFacturasAutoSQLserver']
                );
                if (paramRows && paramRows.length > 0) autoExportParamVal = paramRows[0].value;
            } catch (e) {}

            const shouldExportToZeusERP = autoExportParamVal === '1';

            if (shouldExportToZeusERP) {
                try {
                    console.log(`[EXPORT_ZEUS_ERP] Exportando automáticamente a Zeus ERP (IDs: ${createdIdsStr})...`);
                    const exportResult: any[] = await executePostgresQuery(
                        `CALL spexportinvoices($1, $2, $3)`,
                        [createdIdsStr, actingUserId, '']
                    );

                    const row = exportResult && exportResult.length > 0 ? exportResult[0] : null;
                    const xmlStr = (row?.mensaje_resultado || row?.p_mensaje_resultado || (row && typeof row === 'object' ? Object.values(row)[0] : '')) as string;

                    if (xmlStr && typeof xmlStr === 'string' && !xmlStr.startsWith('ERROR')) {
                        const targetDb = await getZeusERPDatabaseName();
                        const sqlResult = await executeSQLServerProcedure('spFacturacionesCrear', { xml: xmlStr }, targetDb);
                        autoExportResult = { success: true, message: 'Exportado automáticamente a SQL Server (Zeus ERP)', sqlResult };
                        await registerLog(actingUserId, 'INVOICE', 'AUTO_EXPORT_SUCCESS', `ID(s) ${createdIdsStr}: Exportación automática exitosa a SQL Server`, { sqlResult });
                    } else {
                        autoExportResult = { success: false, message: `No se generó XML válido de exportación: ${xmlStr}` };
                    }
                } catch (expErr: any) {
                    console.error('[AUTO_EXPORT_INVOICES] Error en exportación a SQL Server:', expErr);
                    autoExportResult = { success: false, error: expErr.message };
                }
            }
        }

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            origin: 'EXCEL',
            module: 'Facturación',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_FACTURAS',
            process: 'Fin Importación Excel',
            eventType: 'FIN_PROCESO',
            stepName: 'Importación Excel Completada',
            endpoint: '/api/invoices/import',
            durationMs: Date.now() - startTime,
            status: 'SUCCESS',
            outputData: { detail: dbMessage, importedCount: rows.length, createdIds, createdConsecutives, autoExportResult },
            functionalMessage: dbMessage
        });

        await registerLog(
            actingUserId,
            'INVOICE',
            'IMPORT',
            `Importación masiva mediante SP. Filas: ${rows.length}. Facturas creadas: ${createdConsecutives.join(', ') || createdIdsStr}`,
            { rowCount: rows.length, dbMessage, createdIds, createdConsecutives, autoExportResult }
        );

        return NextResponse.json({ 
            message: 'Importación finalizada',
            detail: dbMessage,
            importedCount: rows.length,
            createdIds,
            createdConsecutives,
            autoExportResult
        })
    } catch (error: any) {
        console.error('Import error (via SP TEXT):', error);

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            origin: 'EXCEL',
            module: 'Facturación',
            screen: 'Importación Excel',
            action: 'IMPORTAR_EXCEL_FACTURAS',
            process: 'Excepción Capturada',
            eventType: 'EXCEPCION',
            stepName: 'Fallo al Procesar Excel',
            endpoint: '/api/invoices/import',
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
