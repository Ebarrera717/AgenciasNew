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
            const invoices = rows.map(r => ({
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
                totalAmount: r.totalAmount || 0,
                currency: r.currency || 'COP',
                state: r.state || 'NUEVO',
                products: []
            }));

            return NextResponse.json(invoices);
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public."fnInvoicesListar"()`
        );
        const invoices = results.map(row => {
            const item = row.fninvoiceslistar || row;
            return {
                ...item,
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
