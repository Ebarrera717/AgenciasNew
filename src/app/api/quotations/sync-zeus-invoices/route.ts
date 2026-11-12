import { NextRequest, NextResponse } from 'next/server';
import { syncZeusInvoices } from '@/lib/zeus-invoice-sync';

export const dynamic = 'force-dynamic';

export async function POST(_request: NextRequest) {
    try {
        const result = await syncZeusInvoices();
        return NextResponse.json({
            success: true,
            syncedCount: result.syncedCount,
            message: result.message,
            details: result.details || []
        });
    } catch (error: any) {
        console.error('[API_SYNC_ZEUS_INVOICES] Error:', error);
        return NextResponse.json({
            success: false,
            message: 'Error al sincronizar facturas con Zeus ERP',
            detail: error?.message || String(error)
        }, { status: 500 });
    }
}

export async function GET(_request: NextRequest) {
    try {
        const result = await syncZeusInvoices();
        return NextResponse.json({
            success: true,
            syncedCount: result.syncedCount,
            message: result.message,
            details: result.details || []
        });
    } catch (error: any) {
        console.error('[API_SYNC_ZEUS_INVOICES] Error:', error);
        return NextResponse.json({
            success: false,
            message: 'Error al sincronizar facturas con Zeus ERP',
            detail: error?.message || String(error)
        }, { status: 500 });
    }
}
