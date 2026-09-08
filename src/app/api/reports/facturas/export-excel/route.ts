import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import ExcelJS from 'exceljs'
import * as XLSX from 'xlsx'
import { generateHtmlTemplate } from '@/lib/excel-to-html'

const DEFAULT_INVOICE_CONFIG: Record<string, string> = {
    idFactura: "G4",
    internalNumber: "G5",
    fecha: "G6",
    fechaVencimiento: "G7",
    clienteNombre: "B8",
    clienteIdentificacion: "G8",
    clienteDireccion: "B9",
    clienteTelefono: "G9",
    sucursal: "B10",
    implante: "G10",
    vendedor: "B11",
    resolucionTexto: "A12",
    resolucionPrefijo: "F12",
    resolucionAutoriza: "G12",
    moneda: "G14",
    tCambio: "G15",
    baseComisionable: "B35",
    comisionAsesor: "B36",
    impuestos: "G35",
    totalAmount: "G37",
    fechasViaje: "G16",
    pasajeros: "B18",
    hotelesServicios: "A20",
    observaciones: "B40",
    formaPago: "B42",
    logo: "A1"
};

function colNameToIndex(colName: string): number {
    let index = 0;
    for (let i = 0; i < colName.length; i++) {
        index = index * 26 + (colName.charCodeAt(i) - 64);
    }
    return index;
}

function parseCellAddress(addrStr: string) {
    if (!addrStr || typeof addrStr !== 'string') return null;
    const match = addrStr.trim().toUpperCase().match(/^([A-Z]+)(\d+)$/);
    if (!match) return null;
    return { col: colNameToIndex(match[1]), row: parseInt(match[2], 10) };
}

export async function GET(req: Request) {
    try {
        const { searchParams } = new URL(req.url);
        const idIniStr = searchParams.get('idIni');
        const idFinStr = searchParams.get('idFin');
        const format = searchParams.get('format');

        if (!idIniStr || !idFinStr) {
            return NextResponse.json({ error: "Faltan parámetros idIni o idFin" }, { status: 400 });
        }

        const idIni = parseInt(idIniStr, 10);
        const idFin = parseInt(idFinStr, 10);

        const invoices = await prisma.invoices.findMany({
            where: {
                id: { gte: Math.min(idIni, idFin), lte: Math.max(idIni, idFin) }
            },
            orderBy: { id: 'asc' }
        });

        if (!invoices || invoices.length === 0) {
            return NextResponse.json({ error: "No se encontraron facturas en el rango indicado" }, { status: 404 });
        }

        const invoiceIds = invoices.map(i => i.id);

        // Fetch products, passengers, payments, itineraries manually
        const productsRaw = await prisma.invoicesProduct.findMany({
            where: { invoiceId: { in: invoiceIds } }
        });

        const productIds = productsRaw.map(p => p.id);

        const [passengersRaw, paymentsRaw, itinerariesRaw] = await Promise.all([
            prisma.invoicesProductPasenger.findMany({ where: { invoiceProductId: { in: productIds } } }),
            prisma.invoicesProductPayment.findMany({ where: { invoiceProductId: { in: productIds } } }),
            prisma.invoicesProductItinerary.findMany({ where: { invoiceProductId: { in: productIds } } })
        ]);

        const passengersByProduct = new Map<number, any[]>();
        passengersRaw.forEach(px => {
            const list = passengersByProduct.get(px.invoiceProductId) || [];
            list.push(px);
            passengersByProduct.set(px.invoiceProductId, list);
        });

        const paymentsByProduct = new Map<number, any[]>();
        paymentsRaw.forEach(py => {
            const list = paymentsByProduct.get(py.invoiceProductId) || [];
            list.push(py);
            paymentsByProduct.set(py.invoiceProductId, list);
        });

        const productsByInvoice = new Map<number, any[]>();
        productsRaw.forEach(p => {
            const list = productsByInvoice.get(p.invoiceId) || [];
            list.push({
                ...p,
                passengers: passengersByProduct.get(p.id) || [],
                payments: paymentsByProduct.get(p.id) || []
            });
            productsByInvoice.set(p.invoiceId, list);
        });

        // Fetch related entities (Client, Branch, Implant, Seller, Resolution)
        const clientIds = Array.from(new Set(invoices.map(i => i.clientId).filter((id): id is number => id != null)));
        const branchIds = Array.from(new Set(invoices.map(i => i.branchId).filter((id): id is number => id != null)));
        const implantIds = Array.from(new Set(invoices.map(i => i.implantId).filter((id): id is number => id != null)));
        const sellerIds = Array.from(new Set(invoices.map(i => i.sellerId).filter((id): id is number => id != null)));

        const [clients, branches, implants, sellers] = await Promise.all([
            prisma.client.findMany({ where: { id: { in: clientIds } } }),
            prisma.branch.findMany({ where: { id: { in: branchIds } }, include: { resolution: true } as any }),
            prisma.implant.findMany({ where: { id: { in: implantIds } }, include: { resolution: true } as any }),
            prisma.seller.findMany({ where: { id: { in: sellerIds } } })
        ]);

        const clientMap = new Map(clients.map(c => [c.id, c]));
        const branchMap = new Map(branches.map(b => [b.id, b]));
        const implantMap = new Map(implants.map(i => [i.id, i]));
        const sellerMap = new Map(sellers.map(s => [s.id, s]));

        if (format === 'html') {
            const htmlPages: string[] = [];

            for (const inv of invoices) {
                const invProducts = productsByInvoice.get(inv.id) || [];
                const branch: any = inv.branchId ? branchMap.get(inv.branchId) : null;
                const implant: any = inv.implantId ? implantMap.get(inv.implantId) : null;
                const client = inv.clientId ? clientMap.get(inv.clientId) : null;
                const seller = inv.sellerId ? sellerMap.get(inv.sellerId) : null;
                const resolution = implant?.resolution || branch?.resolution || null;

                const templateBuffer = implant?.invoiceTemplate || branch?.invoiceTemplate;
                const templateConfigRaw = implant?.invoiceTemplateConfig || branch?.invoiceTemplateConfig;
                const baseHtmlTemplate = implant?.invoiceHtmlTemplate || branch?.invoiceHtmlTemplate;
                const logoBuffer = implant?.logo || branch?.logo;

                let config = { ...DEFAULT_INVOICE_CONFIG };
                if (templateConfigRaw && typeof templateConfigRaw === 'object') {
                    config = { ...config, ...(templateConfigRaw as any) };
                }

                let resText = '';
                if (resolution) {
                    resText = `Resolución DIAN N° ${resolution.autoriza || ''} de ${resolution.date ? new Date(resolution.date).toLocaleDateString() : ''} Prefijo ${resolution.prefijo || ''} del ${resolution.inicial || 1} al ${resolution.end || 999999}`;
                }

                const servicesText = invProducts.map(p => p.servicios || p.descripcion || '').filter(Boolean).join(' | ');
                const paxNames = invProducts.flatMap(p => (p.passengers || []).map((px: any) => px.name)).filter(Boolean).join(', ');
                const paymentsText = invProducts.flatMap(p => (p.payments || []).map((py: any) => `${py.paymentMethod || 'Pago'}: $${py.amount}`)).join(', ');

                const fieldValues: Record<string, any> = {
                    idFactura: inv.consecutivo || inv.id,
                    internalNumber: inv.internalNumber,
                    fecha: inv.date ? new Date(inv.date).toLocaleDateString('es-CO') : '',
                    fechaVencimiento: inv.dueDate ? new Date(inv.dueDate).toLocaleDateString('es-CO') : (inv.date ? new Date(inv.date).toLocaleDateString('es-CO') : ''),
                    clienteNombre: client?.name || '',
                    clienteIdentificacion: client?.document || '',
                    clienteDireccion: client?.address || '',
                    clienteTelefono: client?.contactInfo || '',
                    sucursal: branch?.name || '',
                    implante: implant?.name || '',
                    vendedor: seller?.name || '',
                    resolucionTexto: resText,
                    resolucionPrefijo: resolution?.prefijo || '',
                    resolucionAutoriza: resolution?.autoriza || '',
                    moneda: inv.currency,
                    tCambio: inv.exchangeRate,
                    baseComisionable: inv.baseCommissionable,
                    comisionAsesor: inv.commissionPercentage,
                    impuestos: inv.chargesAndTaxes,
                    totalAmount: inv.totalAmount,
                    fechasViaje: '',
                    pasajeros: paxNames,
                    hotelesServicios: servicesText,
                    observaciones: inv.state || '',
                    formaPago: paymentsText
                };

                let pageHtml = '';
                if (baseHtmlTemplate) {
                    pageHtml = baseHtmlTemplate;
                    for (const [key, cellAddr] of Object.entries(config)) {
                        if (key === 'logo' || !cellAddr || typeof cellAddr !== 'string') continue;
                        const val = fieldValues[key] !== undefined && fieldValues[key] !== null ? String(fieldValues[key]) : '';
                        const cellRegex = new RegExp(`(<td[^>]*data-cell="${cellAddr}"[^>]*>)(.*?)(</td>)`, 'gi');
                        if (cellRegex.test(pageHtml)) {
                            pageHtml = pageHtml.replace(cellRegex, `$1${val}$3`);
                        }
                    }
                } else if (templateBuffer) {
                    try {
                        const generatedHtml = await generateHtmlTemplate(Buffer.from(templateBuffer as any), config, logoBuffer ? Buffer.from(logoBuffer as any) : undefined);
                        pageHtml = generatedHtml;
                        for (const [key, cellAddr] of Object.entries(config)) {
                            if (key === 'logo' || !cellAddr || typeof cellAddr !== 'string') continue;
                            const val = fieldValues[key] !== undefined && fieldValues[key] !== null ? String(fieldValues[key]) : '';
                            const cellRegex = new RegExp(`(<td[^>]*data-cell="${cellAddr}"[^>]*>)(.*?)(</td>)`, 'gi');
                            pageHtml = pageHtml.replace(cellRegex, `$1${val}$3`);
                        }
                    } catch (e) {
                        console.error('Error generating invoice HTML template:', e);
                    }
                }

                if (!pageHtml) {
                    pageHtml = `
                    <div style="font-family: sans-serif; padding: 24px; border: 1px solid #ccc; margin-bottom: 24px;">
                        <h2>Factura N° ${inv.consecutivo || inv.id} (${inv.internalNumber})</h2>
                        <p><strong>Fecha:</strong> ${inv.date ? new Date(inv.date).toLocaleDateString() : ''}</p>
                        <p><strong>Cliente:</strong> ${client?.name || ''} - NIT: ${client?.document || ''}</p>
                        <p><strong>Sucursal:</strong> ${branch?.name || ''} | <strong>Implante:</strong> ${implant?.name || ''}</p>
                        <p><strong>Resolución:</strong> ${resText}</p>
                        <hr/>
                        <h3>Conceptos</h3>
                        <p>${servicesText || 'Sin detalles'}</p>
                        <hr/>
                        <p style="font-size: 18px;"><strong>Total:</strong> $${inv.totalAmount.toLocaleString()} ${inv.currency}</p>
                    </div>`;
                }

                htmlPages.push(pageHtml);
            }

            const combinedHtml = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8"/>
                <title>Impresión de Facturación</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f4f4f5; }
                    .page-break { page-break-after: always; margin-bottom: 40px; }
                    @media print {
                        body { background: white; padding: 0; }
                        .page-break { page-break-after: always; margin-bottom: 0; }
                        .no-print { display: none !important; }
                    }
                    .btn-print {
                        position: fixed; top: 20px; right: 20px; z-index: 9999;
                        background: #059669; color: white; border: none; padding: 12px 24px;
                        font-weight: bold; border-radius: 8px; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                    }
                </style>
            </head>
            <body>
                <button onclick="window.print()" class="btn-print no-print">🖨️ Imprimir Facturas</button>
                ${htmlPages.map(page => `<div class="page-break">${page}</div>`).join('')}
            </body>
            </html>`;

            return new NextResponse(combinedHtml, {
                headers: { 'Content-Type': 'text/html; charset=utf-8' }
            });
        }

        const outWorkbook = new ExcelJS.Workbook();
        for (const inv of invoices) {
            const invProducts = productsByInvoice.get(inv.id) || [];
            const branch: any = inv.branchId ? branchMap.get(inv.branchId) : null;
            const implant: any = inv.implantId ? implantMap.get(inv.implantId) : null;
            const client = inv.clientId ? clientMap.get(inv.clientId) : null;
            const seller = inv.sellerId ? sellerMap.get(inv.sellerId) : null;
            const resolution = implant?.resolution || branch?.resolution || null;

            const templateBuffer = implant?.invoiceTemplate || branch?.invoiceTemplate;
            const templateConfigRaw = implant?.invoiceTemplateConfig || branch?.invoiceTemplateConfig;

            let config = { ...DEFAULT_INVOICE_CONFIG };
            if (templateConfigRaw && typeof templateConfigRaw === 'object') {
                config = { ...config, ...(templateConfigRaw as any) };
            }

            const tempWorkbook = new ExcelJS.Workbook();
            if (templateBuffer) {
                let finalBuffer = Buffer.from(templateBuffer as any) as any;
                if (finalBuffer[0] === 0xD0 && finalBuffer[1] === 0xCF && finalBuffer[2] === 0x11 && finalBuffer[3] === 0xE0) {
                    try {
                        const xlsWorkbook = XLSX.read(finalBuffer, { type: 'buffer' });
                        finalBuffer = XLSX.write(xlsWorkbook, { bookType: 'xlsx', type: 'buffer' });
                    } catch (e) {}
                }
                await tempWorkbook.xlsx.load(finalBuffer);
            } else {
                const sheet = tempWorkbook.addWorksheet('Factura');
                sheet.getCell('A1').value = `Factura ${inv.consecutivo || inv.id}`;
            }

            const sheet = tempWorkbook.worksheets[0];
            sheet.name = `Factura_${inv.consecutivo || inv.id}`;

            let resText = '';
            if (resolution) {
                resText = `Resolución DIAN N° ${resolution.autoriza || ''} de ${resolution.date ? new Date(resolution.date).toLocaleDateString() : ''} Prefijo ${resolution.prefijo || ''} del ${resolution.inicial || 1} al ${resolution.end || 999999}`;
            }

            const servicesText = invProducts.map(p => p.servicios || p.descripcion || '').filter(Boolean).join(' | ');
            const paxNames = invProducts.flatMap(p => (p.passengers || []).map((px: any) => px.name)).filter(Boolean).join(', ');
            const paymentsText = invProducts.flatMap(p => (p.payments || []).map((py: any) => `${py.paymentMethod || 'Pago'}: $${py.amount}`)).join(', ');

            const fieldValues: Record<string, any> = {
                idFactura: inv.consecutivo || inv.id,
                internalNumber: inv.internalNumber,
                fecha: inv.date ? new Date(inv.date).toLocaleDateString() : '',
                clienteNombre: client?.name || '',
                clienteIdentificacion: client?.document || '',
                clienteDireccion: client?.address || '',
                clienteTelefono: client?.contactInfo || '',
                sucursal: branch?.name || '',
                implante: implant?.name || '',
                vendedor: seller?.name || '',
                resolucionTexto: resText,
                resolucionPrefijo: resolution?.prefijo || '',
                resolucionAutoriza: resolution?.autoriza || '',
                moneda: inv.currency,
                tCambio: inv.exchangeRate,
                baseComisionable: inv.baseCommissionable,
                comisionAsesor: inv.commissionPercentage,
                impuestos: inv.chargesAndTaxes,
                totalAmount: inv.totalAmount,
                fechasViaje: '',
                pasajeros: paxNames,
                hotelesServicios: servicesText,
                observaciones: inv.state || '',
                formaPago: paymentsText
            };

            for (const [key, cellAddr] of Object.entries(config)) {
                if (key === 'logo' || !cellAddr || typeof cellAddr !== 'string') continue;
                const parsed = parseCellAddress(cellAddr);
                if (parsed && fieldValues[key] !== undefined) {
                    sheet.getCell(parsed.row, parsed.col).value = fieldValues[key];
                }
            }

            const newSheet = outWorkbook.addWorksheet(sheet.name);
            sheet.eachRow({ includeEmpty: true }, (row, rowNumber) => {
                const newRow = newSheet.getRow(rowNumber);
                row.eachCell({ includeEmpty: true }, (cell, colNumber) => {
                    const newCell = newRow.getCell(colNumber);
                    newCell.value = cell.value;
                    newCell.style = cell.style;
                });
            });
        }

        const buffer = await outWorkbook.xlsx.writeBuffer();
        return new NextResponse(buffer as any, {
            headers: {
                'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition': `attachment; filename="facturas_${idIni}_${idFin}.xlsx"`
            }
        });

    } catch (error: any) {
        console.error("Error in facturas export-excel route:", error);
        return NextResponse.json({ error: error.message || "Error interno del servidor" }, { status: 500 });
    }
}
