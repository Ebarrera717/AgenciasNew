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

function parseSafeFloat(val: any, defaultVal = 0): number {
    if (val === undefined || val === null || val === '') return defaultVal;
    if (typeof val === 'number') return isNaN(val) ? defaultVal : val;
    const clean = extractNumericValue(val);
    const num = parseFloat(clean);
    return isNaN(num) ? defaultVal : num;
}

function parseSafeInt(val: any, defaultVal = 0): number {
    if (val === undefined || val === null || val === '') return defaultVal;
    if (typeof val === 'number') return isNaN(val) ? defaultVal : Math.trunc(val);
    const clean = extractNumericValue(val);
    const num = parseInt(clean, 10);
    return isNaN(num) ? defaultVal : num;
}

function getRowValue(row: any, ...aliases: string[]): any {
    if (!row || typeof row !== 'object') return undefined;
    for (const alias of aliases) {
        if (row[alias] !== undefined && row[alias] !== null && row[alias] !== '') return row[alias];
    }
    const rowKeys = Object.keys(row);
    for (const alias of aliases) {
        const cleanAlias = alias.toLowerCase().replace(/[\s_\-\.]/g, '');
        for (const k of rowKeys) {
            const cleanK = k.toLowerCase().trim().replace(/[\s_\-\.]/g, '');
            if (cleanK === cleanAlias && row[k] !== undefined && row[k] !== null && row[k] !== '') {
                return row[k];
            }
        }
    }
    return undefined;
}

function getExcelVariableString(row: any): string {
    if (!row || typeof row !== 'object') return '';
    const explicit = getRowValue(row, 
        'Variables_Codigos_Y_Valores', 'Variables_Cotizacion', 'Variables_Adicionales', 
        'Variables_Codigos', 'Variables_Co', 'Variables', 'Variables Codigos Y Valores'
    );
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

function getExcelPrestadoraCode(row: any): string {
    if (!row || typeof row !== 'object') return '';
    const explicit = getRowValue(row, 
        'Prestadora_Codigo', 'Prestadora_Cod', 'Prestadora_Co', 'Prestadora', 
        'Hotel_Codigo', 'Hotel_id', 'Hotel', 'Prestadora Codigo', 'Hotel Codigo'
    );
    if (explicit !== undefined && explicit !== null && explicit !== '') {
        return explicit.toString().trim();
    }
    for (const key of Object.keys(row)) {
        if (/^prestadora/i.test(key.trim()) || /^hotel/i.test(key.trim())) {
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
                    getRowValue(r, 'Cliente_Documento', 'Documento_Cliente', 'Cliente', 'Documento') ||
                    getRowValue(r, 'Producto_Codigo', 'Producto', 'Codigo_Producto', 'Item') ||
                    getRowValue(r, 'Precio_Unitario', 'Precio Unitario', 'Precio', 'Valor_Unitario', 'Valor', 'Price') ||
                    getRowValue(r, 'Cargos_A_Factura', 'Cargo_Principal', 'Cargos') ||
                    getRowValue(r, 'Proveedor_Codigo', 'Proveedor') ||
                    getRowValue(r, 'Pasajeros', 'Pasajero', 'Pax')
                );
            });

            const grouped = new Map<string, any[]>();
            for (const r of validRows) {
                const key = (getRowValue(r, 'Grupo_Factura', 'Grupo', 'Group') || '1').toString().trim();
                if (!grouped.has(key)) grouped.set(key, []);
                grouped.get(key)!.push(r);
            }

            const createdIds: number[] = [];
            const createdConsecutives: string[] = [];

            const transaction = new mssql.Transaction(pool);
            await transaction.begin();
            let isTxActive = true;

            try {
                for (const [groupKey, items] of grouped.entries()) {
                    const first = items[0];
                    
                    // 1. Resolver Cliente
                    const clientDoc = (getRowValue(first, 'Cliente_Documento', 'Documento_Cliente', 'Cliente', 'Documento') || '').toString().trim();
                    let clientId = 1;
                    if (clientDoc) {
                        const clientRes = await new mssql.Request(transaction)
                            .input('doc', mssql.VarChar, clientDoc)
                            .query(`SELECT TOP 1 id FROM dbo.[Client] WHERE document = @doc`);
                        if (clientRes.recordset && clientRes.recordset.length > 0) {
                            clientId = clientRes.recordset[0].id;
                        } else {
                            const newClientRes = await new mssql.Request(transaction)
                                .input('name', mssql.VarChar, getRowValue(first, 'Cliente_Nombre', 'Nombre_Cliente') || `Cliente ${clientDoc}`)
                                .input('doc', mssql.VarChar, clientDoc)
                                .query(`INSERT INTO dbo.[Client] (name, document) OUTPUT INSERTED.id VALUES (@name, @doc)`);
                            if (newClientRes.recordset && newClientRes.recordset.length > 0) {
                                clientId = newClientRes.recordset[0].id;
                            }
                        }
                    }

                    // 2. Resolver Sucursal, Implante, Vendedor, Tiqueteador con Validación Estricta por Código
                    let branchId = 1;
                    const bCodeVal = getRowValue(first, 'Sucursal_Codigo', 'Sucursal', 'Branch');
                    if (bCodeVal) {
                        const bCode = bCodeVal.toString().trim();
                        const bRes = await new mssql.Request(transaction).input('code', mssql.VarChar, bCode).query(`SELECT TOP 1 id FROM dbo.[Branch] WHERE UPPER(code) = UPPER(@code)`);
                        if (bRes.recordset && bRes.recordset.length > 0) {
                            branchId = bRes.recordset[0].id;
                        } else {
                            throw new Error(`ERROR: La Sucursal con código '${bCode}' no existe en el sistema.`);
                        }
                    }

                    let implantId: number | null = null;
                    const iCodeVal = getRowValue(first, 'Implant_Codigo', 'Implant', 'Implante');
                    if (iCodeVal) {
                        const iCode = iCodeVal.toString().trim();
                        const iRes = await new mssql.Request(transaction).input('code', mssql.VarChar, iCode).query(`SELECT TOP 1 id FROM dbo.[Implant] WHERE UPPER(code) = UPPER(@code)`);
                        if (iRes.recordset && iRes.recordset.length > 0) {
                            implantId = iRes.recordset[0].id;
                        } else {
                            throw new Error(`ERROR: El Implante con código '${iCode}' no existe en el sistema.`);
                        }
                    }

                    let sellerId: number | null = null;
                    const sCodeVal = getRowValue(first, 'Vendedor_Codigo', 'Vendedor', 'Seller');
                    if (sCodeVal) {
                        const sCode = sCodeVal.toString().trim();
                        const sRes = await new mssql.Request(transaction)
                            .input('code', mssql.VarChar, sCode)
                            .query(`SELECT TOP 1 id FROM dbo.[Seller] WHERE UPPER(code) = UPPER(@code)`);
                        if (sRes.recordset && sRes.recordset.length > 0) {
                            sellerId = sRes.recordset[0].id;
                        } else {
                            throw new Error(`ERROR: El Vendedor con código '${sCode}' no está registrado en la maestría de Vendedores. La factura no fue subida.`);
                        }
                    }

                    let ticketPrinterId: number | null = null;
                    const tCodeVal = getRowValue(first, 'Tiqueteador_Codigo', 'Tiqueteador', 'TicketPrinter');
                    if (tCodeVal) {
                        const tCode = tCodeVal.toString().trim();
                        const tRes = await new mssql.Request(transaction)
                            .input('code', mssql.VarChar, tCode)
                            .query(`SELECT TOP 1 id FROM dbo.[TicketPrinter] WHERE UPPER(code) = UPPER(@code)`);
                        if (tRes.recordset && tRes.recordset.length > 0) {
                            ticketPrinterId = tRes.recordset[0].id;
                        } else {
                            throw new Error(`ERROR: El Tiqueteador con código '${tCode}' no está registrado en la maestría de Tiqueteadores. La factura no fue subida.`);
                        }
                    }

                    // Validar variables adicionales obligatorias del cliente para facturas en SQL Server
                    const clientObjRes = await new mssql.Request(transaction)
                        .input('cId', mssql.Int, clientId)
                        .query(`SELECT mandatoryVariables FROM dbo.[Client] WHERE id = @cId`);
                    if (clientObjRes.recordset && clientObjRes.recordset.length > 0) {
                        let mvRaw = clientObjRes.recordset[0].mandatoryVariables;
                        if (typeof mvRaw === 'string') {
                            try { mvRaw = JSON.parse(mvRaw); } catch (e) {}
                        }
                        let reqVarIds: number[] = [];
                        if (Array.isArray(mvRaw)) {
                            reqVarIds = [];
                        } else if (mvRaw && typeof mvRaw === 'object') {
                            reqVarIds = Array.isArray(mvRaw.invoice) ? mvRaw.invoice : (Array.isArray(mvRaw.invoices) ? mvRaw.invoices : []);
                        }

                        if (reqVarIds.length > 0) {
                            for (const itm of items) {
                                const varStr = getExcelVariableString(itm);
                                for (const reqId of reqVarIds) {
                                    const varMasterRes = await new mssql.Request(transaction)
                                        .input('vId', mssql.Int, reqId)
                                        .query(`SELECT id, code, name FROM dbo.[MasterVariable] WHERE id = @vId`);
                                    const vMaster = varMasterRes.recordset?.[0];
                                    const vCode = vMaster?.code?.toLowerCase();
                                    const vName = vMaster?.name || `Variable #${reqId}`;

                                    const hasVar = varStr.split('|').some((part: string) => {
                                        const [c, val] = part.split(':');
                                        return (c?.trim().toLowerCase() === vCode || c?.trim() === reqId.toString()) && val?.trim();
                                    });

                                    if (!hasVar) {
                                        throw new Error(`ERROR en GRUPO ${groupKey}: El cliente requiere completar la variable adicional "${vName}" en el producto "${itm.Producto_Codigo || itm.Numero_Tiquete || 'Ítem'}".`);
                                    }
                                }
                            }
                        }
                    }

                    // 3. Consecutivo e Internal Number
                    const consecInfo = await getNextTransactionConsecutive('INVOICE', branchId, implantId);
                    const consecValRaw = getRowValue(first, 'Consecutivo', 'Consecutive');
                    const consecVal = consecValRaw ? consecValRaw.toString().trim() : consecInfo.consecutivoNumber.toString();
                    const serieValRaw = getRowValue(first, 'Serie', 'Prefix');
                    const serieVal = serieValRaw ? serieValRaw.toString().trim() : (consecInfo.prefix || null);
                    const fuenteValRaw = getRowValue(first, 'Fuente', 'Source');
                    const fuenteVal = fuenteValRaw ? fuenteValRaw.toString().trim() : 'FE';
                    const internalNum = consecValRaw 
                        ? (serieVal ? `${serieVal}-${consecVal}` : consecVal)
                        : consecInfo.formattedConsecutive;

                    const globalCargos = parseSafeFloat(getRowValue(first, 'Cargos_A_Factura', 'Cargos', 'Cargo_Principal'), 0);
                    const currency = (getRowValue(first, 'Moneda', 'Currency') || 'COP').toString().trim();
                    const exchangeRate = parseSafeFloat(getRowValue(first, 'Tasa_Cambio', 'Tasa', 'ExchangeRate'), 1);
                    const commissionPct = parseSafeFloat(getRowValue(first, 'Comision_Global_Pct', 'Comision_Global', 'CommissionPct'), 0);

                    // Verificar si ya existe una factura con el mismo internalNumber
                    const existingRes = await new mssql.Request(transaction)
                        .input('internalNumber', mssql.VarChar, internalNum)
                        .query(`SELECT TOP 1 id, [state], zeusInvoiceNumber FROM dbo.[Invoices] WHERE internalNumber = @internalNumber`);

                    let invoiceId: number;

                    if (existingRes.recordset && existingRes.recordset.length > 0) {
                        const existing = existingRes.recordset[0];
                        const st = (existing.state || '').toUpperCase();
                        if (st === 'EXPORTED' || st === 'EXPORTADA' || (existing.zeusInvoiceNumber && String(existing.zeusInvoiceNumber).trim() !== '')) {
                            console.log(`[IMPORT_API] Factura ${internalNum} ya fue exportada a Zeus ERP. Omitiendo.`);
                            continue;
                        }
                        invoiceId = existing.id;
                        await new mssql.Request(transaction)
                            .input('id', mssql.Int, invoiceId)
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
                                UPDATE dbo.[Invoices] SET
                                    clientId = @clientId, currency = @currency, exchangeRate = @exchangeRate,
                                    branchId = @branchId, implantId = @implantId, sellerId = @sellerId,
                                    ticketPrinterId = @ticketPrinterId, baseCommissionable = @baseCommissionable,
                                    commissionPercentage = @commissionPercentage, chargesAndTaxes = @chargesAndTaxes,
                                    totalAmount = @totalAmount, userId = @userId, fuente = @fuente, serie = @serie,
                                    consecutivo = @consecutivo, isExcelImport = 1, [state] = 'NUEVO'
                                WHERE id = @id
                            `);

                        await new mssql.Request(transaction).input('invId', mssql.Int, invoiceId).query(`
                            DELETE FROM dbo.[InvoicesProductPayment] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @invId);
                            DELETE FROM dbo.[InvoicesProductTax] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @invId);
                            DELETE FROM dbo.[InvoicesProductPasenger] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @invId);
                            DELETE FROM dbo.[InvoicesProductVariable] WHERE invoiceProductId IN (SELECT id FROM dbo.[InvoicesProduct] WHERE invoiceId = @invId);
                            DELETE FROM dbo.[InvoicesProduct] WHERE invoiceId = @invId;
                        `);
                    } else {
                        const invRes = await new mssql.Request(transaction)
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
                                    ticketPrinterId, baseCommissionable, commissionPercentage, chargesAndTaxes, totalAmount, userId, fuente, serie, consecutivo, isExcelImport, [state]
                                ) OUTPUT INSERTED.id VALUES (
                                    @internalNumber, @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId,
                                    @ticketPrinterId, @baseCommissionable, @commissionPercentage, @chargesAndTaxes, @totalAmount, @userId, @fuente, @serie, @consecutivo, 1, 'NUEVO'
                                )
                            `);
                        invoiceId = invRes.recordset[0].id;
                    }
                    let invoiceTotalSum = 0;

                    // Insert Items
                    for (const it of items) {
                        let productId = 1;
                        const prodCodeVal = getRowValue(it, 'Producto_Codigo', 'Producto', 'Codigo_Producto', 'Item');
                        if (prodCodeVal) {
                            const pRes = await new mssql.Request(transaction).input('code', mssql.VarChar, prodCodeVal.toString().trim()).query(`SELECT TOP 1 id FROM dbo.[Product] WHERE code = @code`);
                            if (pRes.recordset && pRes.recordset.length > 0) productId = pRes.recordset[0].id;
                        }
                        let providerId: number | null = null;
                        const provCodeVal = getRowValue(it, 'Proveedor_Codigo', 'Proveedor', 'Provider');
                        if (provCodeVal) {
                            const prCode = provCodeVal.toString().trim();
                            const prRes = await new mssql.Request(transaction).input('code', mssql.VarChar, prCode).query(`SELECT TOP 1 id FROM dbo.[Provider] WHERE UPPER(code) = UPPER(@code) OR UPPER(airlineCode) = UPPER(@code) OR UPPER(sigla) = UPPER(@code) OR UPPER(name) LIKE '%' + UPPER(@code) + '%'`);
                            if (prRes.recordset && prRes.recordset.length > 0) providerId = prRes.recordset[0].id;
                        }

                        let prestadoraId: number | null = null;
                        const prestCode = getExcelPrestadoraCode(it);
                        if (prestCode) {
                            const prestRes = await new mssql.Request(transaction)
                                .input('code', mssql.VarChar, prestCode)
                                .query(`SELECT TOP 1 id FROM dbo.[Prestadora] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) = UPPER(@code) OR UPPER(name) LIKE '%' + UPPER(@code) + '%'`);
                            if (prestRes.recordset && prestRes.recordset.length > 0) {
                                prestadoraId = prestRes.recordset[0].id;
                            }
                        }

                        let ticketTypeId: number | null = null;
                        const ttCode = (getRowValue(it, 'Tipo_Tiquete_Codigo', 'Tipo_Tiquete', 'ticketType', 'TipoTiquete') || '').toString().trim();
                        if (ttCode) {
                            const ttRes = await new mssql.Request(transaction)
                                .input('code', mssql.VarChar, ttCode)
                                .query(`SELECT TOP 1 id FROM dbo.[TicketType] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) = UPPER(@code)`);
                            if (ttRes.recordset && ttRes.recordset.length > 0) {
                                ticketTypeId = ttRes.recordset[0].id;
                            }
                        }

                        const rawPrice = getRowValue(it, 'Precio_Unitario', 'Precio Unitario', 'Precio', 'Valor_Unitario', 'Valor', 'Price', 'Unit_Price', 'Tarifa');
                        let itemPrice = parseSafeFloat(rawPrice, 0);
                        const quantity = parseSafeInt(getRowValue(it, 'Cantidad', 'Quantity', 'Qty'), 1);
                        const cost = parseSafeFloat(getRowValue(it, 'Costo', 'Cost'), 0);
                        const checkIn = normalizeDateString(getRowValue(it, 'CheckIn', 'Check-In', 'Check_In', 'Fecha_Inicio', 'checkin') || '');
                        const checkOut = normalizeDateString(getRowValue(it, 'CheckOut', 'Check-Out', 'Check_Out', 'Fecha_Fin', 'checkout') || '');
                        const sellerComm = parseSafeFloat(getRowValue(it, 'Comision_Vendedor_Producto', 'Comision_Vendedor', 'SellerCommission'), 0);
                        const ticketPrinterComm = parseSafeFloat(getRowValue(it, 'Comision_Tiqueteador_Producto', 'Comision_Tiqueteador', 'TicketPrinterCommission'), 0);
                        const inNationality = parseSafeInt(getRowValue(it, 'Nacionalidad', 'InNationality', 'Nationality'), 1);
                        const ticketCode = (getRowValue(it, 'Numero_Tiquete', 'Tiquete', 'ticketCode', 'Ticket', 'Voucher', 'Codigo_Tiquete', 'Tiquete_Voucher', 'Codigo_Voucher') || '').toString().trim() || null;
                        const paxAdults = parseSafeInt(getRowValue(it, 'Pax_Adultos', 'Adultos', 'PaxAdults'), 1);
                        const paxChildren = parseSafeInt(getRowValue(it, 'Pax_Ninos', 'Ninos', 'PaxChildren'), 0);
                        const srvType = getRowValue(it, 'Tipo_Servicio', 'TipoServicio', 'ServiceType') || null;
                        const dest = getRowValue(it, 'Destino', 'Destination') || null;
                        const resCode = getRowValue(it, 'Reserva', 'ReservationCode', 'Localizador', 'Record_Locator') || null;
                        const serviciosVal = getRowValue(it, 'Servicios', 'Services') || null;
                        const descVal = getRowValue(it, 'Descripcion', 'Description', 'Detalle') || null;
                        const itinVal = getRowValue(it, 'Itinerario', 'Itinerary') || null;
                        const classVal = getRowValue(it, 'Clase', 'Class') || null;
                        const airlineVal = getRowValue(it, 'Aerolinea', 'Airline') || null;
                        const provDueDate = normalizeDateString(getRowValue(it, 'Fecha_Vencimiento_Proveedor', 'Fecha_Vencimiento', 'Vencimiento_Proveedor', 'providerDueDate') || '') || null;
                        const provInvoice = (getRowValue(it, 'Factura_Proveedor', 'Factura', 'Factura_Prov', 'providerInvoice') || '').toString().trim() || null;

                        let nights: number | null = null;
                        if (checkIn && checkOut) {
                            const diffTime = Math.abs(new Date(checkOut).getTime() - new Date(checkIn).getTime());
                            nights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                        } else if (getRowValue(it, 'Noches', 'Nights')) {
                            nights = parseSafeInt(getRowValue(it, 'Noches', 'Nights'), 1);
                        }

                        if (checkIn && checkOut && new Date(checkOut).getTime() < new Date(checkIn).getTime()) {
                            throw new Error(`ERROR en Excel: La fecha final / Check-Out ('${checkOut}') no puede ser anterior a la fecha inicial / Check-In ('${checkIn}') para el ítem '${prodCodeVal || 'Producto'}'. Por favor verifique el archivo Excel.`);
                        }

                        const prodRes = await new mssql.Request(transaction)
                            .input('invoiceId', mssql.Int, invoiceId)
                            .input('productId', mssql.Int, productId)
                            .input('quantity', mssql.Int, quantity)
                            .input('price', mssql.Float, itemPrice)
                            .input('cost', mssql.Float, cost)
                            .input('providerId', mssql.Int, providerId)
                            .input('prestadoraId', mssql.Int, prestadoraId)
                            .input('checkInDate', mssql.VarChar, checkIn || null)
                            .input('checkOutDate', mssql.VarChar, checkOut || null)
                            .input('nights', mssql.Int, nights)
                            .input('paxAdults', mssql.Int, paxAdults)
                            .input('paxChildren', mssql.Int, paxChildren)
                            .input('serviceType', mssql.VarChar, srvType)
                            .input('destination', mssql.VarChar, dest)
                            .input('reservationCode', mssql.VarChar, resCode)
                            .input('sellerCommission', mssql.Float, sellerComm)
                            .input('ticketPrinterCommission', mssql.Float, ticketPrinterComm)
                            .input('inNationality', mssql.Int, inNationality)
                            .input('servicios', mssql.VarChar, serviciosVal)
                            .input('descripcion', mssql.VarChar, descVal)
                            .input('itinerary', mssql.VarChar, itinVal)
                            .input('class', mssql.VarChar, classVal)
                            .input('airline', mssql.VarChar, airlineVal)
                            .input('ticketTypeId', mssql.Int, ticketTypeId)
                            .input('ticketCode', mssql.VarChar, ticketCode)
                            .input('providerDueDate', mssql.VarChar, provDueDate)
                            .input('providerInvoice', mssql.VarChar, provInvoice)
                            .query(`
                                INSERT INTO dbo.[InvoicesProduct] (
                                    invoiceId, productId, quantity, price, cost, providerId, prestadoraId,
                                    checkInDate, checkOutDate, nights, paxAdults, paxChildren,
                                    serviceType, destination, reservationCode, sellerCommission, ticketPrinterCommission,
                                    inNationality, servicios, descripcion, itinerary, class, airline, ticketTypeId, ticketCode,
                                    providerDueDate, providerInvoice
                                ) OUTPUT INSERTED.id VALUES (
                                    @invoiceId, @productId, @quantity, @price, @cost, @providerId, @prestadoraId,
                                    TRY_CAST(@checkInDate AS DATETIME2), TRY_CAST(@checkOutDate AS DATETIME2), @nights, @paxAdults, @paxChildren,
                                    @serviceType, @destination, @reservationCode, @sellerCommission, @ticketPrinterCommission,
                                    @inNationality, @servicios, @descripcion, @itinerary, @class, @airline, @ticketTypeId, @ticketCode,
                                    TRY_CAST(@providerDueDate AS DATETIME2), @providerInvoice
                                )
                            `);

                        const invoiceProductId = prodRes.recordset[0].id;
                        let itemTaxesSum = 0;

                        // Inserción de Impuestos / Cargos / Tarifa (InvoicesProductTax)
                        const itemTaxesToInsert: { taxCode: string; amount: number; isMain: boolean }[] = [];
                        const cargoStr = (it.Cargos_A_Factura || it.Cargo_Principal || '').toString().trim();
                        const taxStr = (it.Impuestos_Nombres_Y_Valores || '').toString().trim();

                        const parseTaxesString = (str: string, defaultMain: boolean = false) => {
                            if (!str) return;
                            const items = str.split('|');
                            for (let index = 0; index < items.length; index++) {
                                const item = items[index].trim();
                                if (!item) continue;
                                
                                let tCode = '';
                                let tAmt = 0;
                                
                                if (item.includes(':')) {
                                    const parts = item.split(':');
                                    tCode = parts[0].trim();
                                    tAmt = parseFloat(extractNumericValue(parts.slice(1).join(':')) || '0');
                                } else {
                                    tCode = defaultMain ? (it.Cargo_Principal || 'TAR') : item;
                                    tAmt = parseFloat(extractNumericValue(item) || '0');
                                }

                                if (tCode && tAmt > 0) {
                                    const upperCode = tCode.toUpperCase();
                                    if (!itemTaxesToInsert.some(x => x.taxCode.toUpperCase() === upperCode)) {
                                        itemTaxesToInsert.push({
                                            taxCode: tCode,
                                            amount: tAmt,
                                            isMain: defaultMain && index === 0
                                        });
                                    }
                                }
                            }
                        };

                        parseTaxesString(cargoStr, true);
                        parseTaxesString(taxStr, false);

                        if (itemTaxesToInsert.length > 0 && !itemTaxesToInsert.some(x => x.isMain)) {
                            itemTaxesToInsert[0].isMain = true;
                        }

                        let mainTaxId: number | null = null;
                        for (const tObj of itemTaxesToInsert) {
                            let chargeAndTaxId: number | null = null;
                            let valSnapshot = 0;
                            let valTypeSnapshot = 'MONTO';

                            const taxRes = await new mssql.Request(transaction)
                                .input('code', mssql.VarChar, tObj.taxCode)
                                .query(`SELECT TOP 1 id, value, valueType FROM dbo.[ChargeAndTax] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) = UPPER(@code)`);
                            
                            if (taxRes.recordset && taxRes.recordset.length > 0) {
                                chargeAndTaxId = taxRes.recordset[0].id;
                                valSnapshot = taxRes.recordset[0].value || 0;
                                valTypeSnapshot = taxRes.recordset[0].valueType || 'MONTO';
                            } else {
                                const newTaxRes = await new mssql.Request(transaction)
                                    .input('code', mssql.VarChar, tObj.taxCode)
                                    .input('name', mssql.VarChar, tObj.taxCode)
                                    .input('type', mssql.VarChar, tObj.isMain ? 'CHARGE' : 'TAX')
                                    .input('valueType', mssql.VarChar, 'MONTO')
                                    .input('value', mssql.Float, 0)
                                    .query(`INSERT INTO dbo.[ChargeAndTax] (code, name, type, valueType, value, isEditable) OUTPUT INSERTED.id VALUES (@code, @name, @type, @valueType, @value, 1)`);
                                
                                if (newTaxRes.recordset && newTaxRes.recordset.length > 0) {
                                    chargeAndTaxId = newTaxRes.recordset[0].id;
                                }
                            }

                            if (chargeAndTaxId) {
                                if (tObj.isMain) mainTaxId = chargeAndTaxId;

                                await new mssql.Request(transaction)
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
                            await new mssql.Request(transaction)
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
                                await new mssql.Request(transaction)
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
                                await new mssql.Request(transaction)
                                    .input('invoiceProductId', mssql.Int, invoiceProductId)
                                    .input('name', mssql.VarChar, parts[0]?.trim() || '')
                                    .input('document', mssql.VarChar, parts[1]?.trim() || '')
                                    .query(`INSERT INTO dbo.[InvoicesProductPasenger] (invoiceProductId, name, document) VALUES (@invoiceProductId, @name, @document)`);
                            }
                        }

                        // Inserción de Variables Adicionales
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
                                    const mvRes = await new mssql.Request(transaction)
                                        .input('code', mssql.VarChar, varCode)
                                        .query(`SELECT TOP 1 id FROM dbo.[MasterVariable] WHERE UPPER(code) = UPPER(@code) OR UPPER(name) = UPPER(@code)`);
                                    if (mvRes.recordset && mvRes.recordset.length > 0) {
                                        masterVarId = mvRes.recordset[0].id;
                                    } else {
                                        const newMvRes = await new mssql.Request(transaction)
                                            .input('code', mssql.VarChar, varCode)
                                            .input('name', mssql.VarChar, varCode)
                                            .query(`INSERT INTO dbo.[MasterVariable] (code, name) OUTPUT INSERTED.id VALUES (@code, @name)`);
                                        if (newMvRes.recordset && newMvRes.recordset.length > 0) {
                                            masterVarId = newMvRes.recordset[0].id;
                                        }
                                    }

                                    if (masterVarId) {
                                        await new mssql.Request(transaction)
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
                    await new mssql.Request(transaction).input('id', mssql.Int, invoiceId).input('total', mssql.Float, invoiceTotalSum).query(`UPDATE dbo.[Invoices] SET totalAmount = @total WHERE id = @id`);

                    createdIds.push(invoiceId);
                    createdConsecutives.push(first.Consecutivo || internalNum);
                }

                await transaction.commit();
                isTxActive = false;
            } catch (txErr: any) {
                if (isTxActive) {
                    try { await transaction.rollback(); } catch (_) {}
                    isTxActive = false;
                }
                await pool.close();
                throw txErr;
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

            // Exportación opcional a Zeus ERP solo si la regla de parámetro automático está explícitamente habilitada (value === '1')
            let autoExportResult = null;
            if (createdIds.length > 0) {
                try {
                    const { autoExportInvoiceToZeusERP } = await import('@/lib/zeus-auto-export');
                    autoExportResult = await autoExportInvoiceToZeusERP(createdIds, actingUserId);
                } catch (expErr: any) {
                    console.warn('[AUTO_EXPORT] Auto-export to Zeus ERP warning on SQL Server invoice import:', expErr?.message);
                }
            }

            return NextResponse.json({
                message: 'Importación finalizada',
                detail: dbMessage,
                importedCount: grouped.size,
                createdIds,
                createdConsecutives,
                autoExportResult
            });
        }

        // MOTOR ACTIVO: PostgreSQL
        console.log('[IMPORT API] Motor Activo: PostgreSQL. Procesando importación 100% nativa en PostgreSQL...');
        const textData = rows.map((row: any) => {
            const checkInClean = normalizeDateString(getRowValue(row, 'CheckIn', 'Check-In', 'Check_In', 'Fecha_Inicio', 'checkin') || '');
            const checkOutClean = normalizeDateString(getRowValue(row, 'CheckOut', 'Check-Out', 'Check_Out', 'Fecha_Fin', 'checkout') || '');
            
            const cargosAFacturaRaw = (getRowValue(row, 'Cargos_A_Factura', 'Cargos', 'Cargo_Principal') || '').toString().trim();
            const cargosAFacturaClean = extractNumericValue(cargosAFacturaRaw);
            
            let impuestosStr = (getRowValue(row, 'Impuestos_Nombres_Y_Valores', 'Impuestos', 'Taxes') || '').toString().trim();
            if (cargosAFacturaRaw.includes(':')) {
                impuestosStr = impuestosStr ? `${cargosAFacturaRaw}|${impuestosStr}` : cargosAFacturaRaw;
            }

            const cols = [
                getRowValue(row, 'Grupo_Factura', 'Grupo', 'Group') || '',
                getRowValue(row, 'Cliente_Documento', 'Documento_Cliente', 'Cliente', 'Documento') || '',
                getRowValue(row, 'Sucursal_Codigo', 'Sucursal', 'Branch') || '',
                getRowValue(row, 'Implant_Codigo', 'Implant', 'Implante') || '',
                getRowValue(row, 'Vendedor_Codigo', 'Vendedor', 'Seller') || '',
                getRowValue(row, 'Tiqueteador_Codigo', 'Tiqueteador', 'TicketPrinter') || '',
                getRowValue(row, 'Moneda', 'Currency') || '',
                extractNumericValue(getRowValue(row, 'Tasa_Cambio', 'Tasa', 'ExchangeRate') || ''),
                extractNumericValue(getRowValue(row, 'Comision_Global_Pct', 'Comision_Global', 'CommissionPct') || ''),
                cargosAFacturaClean,
                getRowValue(row, 'Producto_Codigo', 'Producto', 'Codigo_Producto', 'Item') || '',
                getRowValue(row, 'Proveedor_Nombre', 'Nombre_Proveedor') || '',
                getRowValue(row, 'Proveedor_Codigo', 'Proveedor', 'Provider') || '',
                getExcelPrestadoraCode(row),
                impuestosStr,
                getExcelVariableString(row),
                getRowValue(row, 'Pasajeros', 'Pasajero', 'Pax') || '',
                extractNumericValue(getRowValue(row, 'Precio_Unitario', 'Precio Unitario', 'Precio', 'Valor_Unitario', 'Valor', 'Price', 'Unit_Price', 'Tarifa') || ''),
                extractNumericValue(getRowValue(row, 'Cantidad', 'Quantity', 'Qty') || ''),
                checkInClean,
                checkOutClean,
                extractNumericValue(getRowValue(row, 'Pax_Adultos', 'Adultos', 'PaxAdults') || ''),
                extractNumericValue(getRowValue(row, 'Pax_Ninos', 'Ninos', 'PaxChildren') || ''),
                getRowValue(row, 'Destino', 'Destination') || '',
                getRowValue(row, 'Tipo_Servicio', 'TipoServicio', 'ServiceType') || '',
                getRowValue(row, 'Reserva', 'ReservationCode', 'Localizador', 'Record_Locator') || '',
                extractNumericValue(getRowValue(row, 'Comision_Vendedor_Producto', 'Comision_Vendedor', 'SellerCommission') || ''),
                extractNumericValue(getRowValue(row, 'Comision_Tiqueteador_Producto', 'Comision_Tiqueteador', 'TicketPrinterCommission') || ''),
                getRowValue(row, 'Combo_Codigos', 'Combo') || '',
                extractNumericValue(getRowValue(row, 'Nacionalidad', 'InNationality', 'Nationality') || '1'),
                getRowValue(row, 'Cargo_Principal', 'Cargo') || '',
                extractNumericValue(getRowValue(row, 'Costo', 'Cost') || ''),
                getRowValue(row, 'Servicios', 'Services') || '',
                getRowValue(row, 'Descripcion', 'Description', 'Detalle') || '',
                getRowValue(row, 'Itinerario', 'Itinerary') || '',
                getRowValue(row, 'Clase', 'Class') || '',
                getRowValue(row, 'Aerolinea', 'Airline') || '',
                getRowValue(row, 'Tipo_Tiquete_Codigo', 'Tipo_Tiquete', 'ticketType', 'TipoTiquete') || '',
                getRowValue(row, 'Pagos', 'Payments') || '',
                getRowValue(row, 'Itinerarios', 'Itineraries') || '',
                getRowValue(row, 'Fuente', 'Source') || '',
                getRowValue(row, 'Serie', 'Prefix') || '',
                getRowValue(row, 'Consecutivo', 'Consecutive') || '',
                normalizeDateString(getRowValue(row, 'Fecha_Vencimiento_Proveedor', 'Fecha_Vencimiento', 'Vencimiento_Proveedor', 'providerDueDate') || ''),
                (getRowValue(row, 'Factura_Proveedor', 'Factura', 'Factura_Prov', 'providerInvoice') || '').toString().trim()
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
            try {
                const { autoExportInvoiceToZeusERP } = await import('@/lib/zeus-auto-export');
                autoExportResult = await autoExportInvoiceToZeusERP(createdIds, actingUserId);
            } catch (expErr: any) {
                console.warn('[AUTO_EXPORT] Auto-export to Zeus ERP warning on Postgres invoice import:', expErr?.message);
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
