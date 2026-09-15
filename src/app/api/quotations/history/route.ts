import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, executeSQLServerProcedure } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
    console.log('[QUOTATIONS_HISTORY_DEBUG] Entering GET /api/quotations/history');
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
        const reserva = searchParams.get('reserva') || null
        const pasajero = searchParams.get('pasajero') || null

        if (isSQLServerMode()) {
            console.log('[QUOTATIONS_HISTORY] Modo SQL Server activo. Consultando spCotizacionHistorial...');
            const params: any = {}
            if (referencia) params.p_referencia = referencia
            if (fechaDesde) params.p_fecha_desde = fechaDesde
            if (fechaHasta) params.p_fecha_hasta = fechaHasta
            if (cliente) params.p_cliente = cliente
            if (elaboradoPor) params.p_elaborado_por = elaboradoPor
            if (montoTotal !== null) params.p_monto_total = montoTotal
            if (estado) params.p_estado = estado
            if (reserva) params.p_reserva = reserva
            if (pasajero) params.p_pasajero = pasajero

            const rows = await executeSQLServerProcedure('spCotizacionHistorial', params);
            return NextResponse.json(Array.isArray(rows) ? rows : []);
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public.fnCotizacionHistorial($1::varchar, $2::date, $3::date, $4::varchar, $5::varchar, $6::numeric, $7::varchar, $8::varchar, $9::varchar)`,
            referencia,
            fechaDesde,
            fechaHasta,
            cliente,
            elaboradoPor,
            montoTotal,
            estado,
            reserva,
            pasajero
        );
        const history = results.map(row => row.fncotizacionhistorial);
        return NextResponse.json(history)
    } catch (error: any) {
        console.error('Error fetching quotation history:', error)
        return NextResponse.json({ message: 'Error fetching history', detail: String(error?.message || error || 'Unknown error') }, { status: 500 })
    }
}



