import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            const result = await pool.request().execute('dbo.spInvoicesListar');
            await pool.close();

            const rows = result.recordset || [];
            const formattedHistory = rows.map(r => ({
                id: r.id,
                internalNumber: r.internalNumber,
                invoiceNumber: (r.serie ? `${r.serie}-${r.consecutivo}` : r.consecutivo) || r.internalNumber || `#${r.id}`,
                fuente: r.fuente,
                serie: r.serie,
                consecutivo: r.consecutivo,
                date: r.date,
                dueDate: r.dueDate,
                clientName: r.clientName || 'Consumidor Final',
                document: r.clientDocument || '',
                amount: Number(r.totalAmount) || 0,
                totalAmount: Number(r.totalAmount) || 0,
                currency: r.currency || 'COP',
                state: r.state || 'NUEVO',
                userName: r.sellerName || 'Sistema',
                sellerName: r.sellerName || '',
                branchName: r.branchName || '',
                itemsCount: 0
            }));

            return NextResponse.json(formattedHistory);
        }

        const invoices = await prisma.invoices.findMany({
            orderBy: { date: 'desc' },
            take: 100
        });

        const clientIds = [...new Set(invoices.map(i => i.clientId))];
        const sellerIds = [...new Set(invoices.map(i => i.sellerId).filter(Boolean))];
        const branchIds = [...new Set(invoices.map(i => i.branchId))];

        const [clients, sellers, branches] = await Promise.all([
            prisma.client.findMany({ where: { id: { in: clientIds } } }),
            prisma.seller.findMany({ where: { id: { in: sellerIds as number[] } } }),
            prisma.branch.findMany({ where: { id: { in: branchIds } } })
        ]);

        const formattedHistory = invoices.map(inv => {
            const client = clients.find(c => c.id === inv.clientId);
            const seller = sellers.find(s => s.id === inv.sellerId);
            const branch = branches.find(b => b.id === inv.branchId);

            return {
                id: inv.id,
                internalNumber: inv.internalNumber,
                invoiceNumber: (inv.serie ? `${inv.serie}-${inv.consecutivo}` : inv.consecutivo) || inv.internalNumber || `#${inv.id}`,
                fuente: inv.fuente,
                serie: inv.serie,
                consecutivo: inv.consecutivo,
                date: inv.date,
                dueDate: inv.dueDate,
                clientName: client?.name || 'Consumidor Final',
                document: client?.document || '',
                amount: inv.totalAmount || 0,
                totalAmount: inv.totalAmount || 0,
                currency: inv.currency || 'COP',
                state: inv.state || 'NUEVO',
                userName: seller?.name || 'Sistema',
                sellerName: seller?.name || '',
                branchName: branch?.name || '',
                itemsCount: 0
            };
        });

        return NextResponse.json(formattedHistory)
    } catch (error) {
        console.error('Error fetching invoice history:', error)
        return NextResponse.json({ message: 'Error fetching history' }, { status: 500 })
    }
}
