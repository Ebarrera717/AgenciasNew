import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
    try {
        const { searchParams } = new URL(request.url)
        const referencia = searchParams.get('referencia') || null
        const fechaDesde = searchParams.get('fechaDesde') || null
        const fechaHasta = searchParams.get('fechaHasta') || null
        const cliente = searchParams.get('cliente') || null
        const elaboradoPor = searchParams.get('elaboradoPor') || null
        const montoTotalStr = searchParams.get('montoTotal')
        const montoTotal = (montoTotalStr && !isNaN(parseFloat(montoTotalStr))) ? parseFloat(montoTotalStr) : null
        const estado = searchParams.get('estado') || null

        if (isSQLServerMode()) {
            console.log('[QUOTATIONS_LIST] Modo SQL Server activo. Consultando spCotizacionListar en SQL Server...');
            const pool = await getSQLServerConnection();
            const req = pool.request();
            if (referencia) req.input('p_internalNumber', referencia);
            if (estado) req.input('p_state', estado);

            const result = await req.execute('spCotizacionListar');
            await pool.close();

            const rows = result.recordset || [];
            const quotations = rows.map(r => ({
                id: r.id,
                internalNumber: r.internalNumber || `#${r.id}`,
                date: r.date,
                clientName: r.clientName || 'Cliente',
                userName: r.userName || 'Usuario',
                totalAmount: r.totalAmount || 0,
                currency: r.currency || 'COP',
                state: r.state || 'NUEVO'
            }));

            return NextResponse.json(quotations);
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public.fnCotizacionListar($1::varchar, $2::date, $3::date, $4::varchar, $5::varchar, $6::numeric, $7::varchar)`,
            referencia,
            fechaDesde,
            fechaHasta,
            cliente,
            elaboradoPor,
            montoTotal,
            estado
        );
        const quotations = results.map(row => row.fncotizacionlistar || row);
        return NextResponse.json(quotations);
    } catch (error: any) {
        console.error('Error retrieving quotations:', error)
        return NextResponse.json({ message: 'Error retrieving quotations', detail: error?.message }, { status: 500 })
    }
}
