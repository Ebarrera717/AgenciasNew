import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            console.log('[INVOICES_LIST] Modo SQL Server activo. Consultando spInvoicesListar en SQL Server...');
            const pool = await getSQLServerConnection();
            const result = await pool.request().execute('spInvoicesListar');
            await pool.close();

            const rows = result.recordset || [];
            const invoices = rows.map(r => {
                const isExcel = r.isExcelImport === true || r.isExcelImport === 1 || (r.internalNumber || '').startsWith('FAC-');
                const isExported = r.state === 'EXPORTED' || r.state === 'EXPORTADO';
                const zeusNum = r.zeusInvoiceNumber || (isExported && r.consecutivo ? (r.serie && !r.consecutivo.startsWith(r.serie) ? `${r.serie}${r.consecutivo}` : r.consecutivo) : null);
                return {
                    id: r.id,
                    internalNumber: r.internalNumber || `#${r.id}`,
                    date: r.date,
                    dueDate: r.dueDate,
                    client: {
                        id: r.clientId,
                        name: r.clientName || 'Consumidor Final',
                        document: r.clientDocument || ''
                    },
                    clientName: r.clientName || 'Consumidor Final',
                    totalAmount: Number(r.totalAmount) || 0,
                    currency: r.currency || 'COP',
                    state: r.state || 'NUEVO',
                    isExcelImport: isExcel,
                    zeusInvoiceNumber: zeusNum,
                    fuente: r.fuente,
                    serie: r.serie,
                    consecutivo: r.consecutivo,
                    paxName: r.paxName,
                    providerName: r.providerName,
                    checkInDate: r.checkInDate,
                    checkOutDate: r.checkOutDate,
                    products: [
                        {
                            passengerName: r.paxName,
                            checkInDate: r.checkInDate,
                            checkOutDate: r.checkOutDate,
                            prestadora: { name: r.providerName || 'Varios/Ninguno' },
                            passengers: r.paxName ? [{ name: r.paxName }] : []
                        }
                    ]
                };
            });

            return NextResponse.json(invoices);
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public."fnInvoicesListar"()`
        );
        const invoices = results.map(row => {
            const item = row.fninvoiceslistar || row;
            const isExcel = item.isExcelImport === true || item.isExcelImport === 1 || (item.internalNumber || '').startsWith('FAC-');
            const isExported = item.state === 'EXPORTED' || item.state === 'EXPORTADO';
            const zeusNum = item.zeusInvoiceNumber || (isExported && item.consecutivo ? (item.serie && !item.consecutivo.startsWith(item.serie) ? `${item.serie}${item.consecutivo}` : item.consecutivo) : null);
            return {
                ...item,
                isExcelImport: isExcel,
                zeusInvoiceNumber: zeusNum,
                client: item.client || { name: item.clientName || 'Consumidor Final', document: '' },
                products: item.products || []
            };
        });
        return NextResponse.json(invoices)
    } catch (error: any) {
        console.error('Error retrieving invoices:', error)
        return NextResponse.json({ message: 'Error retrieving invoices', details: error?.message || String(error) }, { status: 500 })
    }
}
