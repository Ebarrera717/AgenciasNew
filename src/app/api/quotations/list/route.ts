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
            if (referencia) req.input('p_referencia', referencia);
            if (fechaDesde) req.input('p_fecha_desde', fechaDesde);
            if (fechaHasta) req.input('p_fecha_hasta', fechaHasta);
            if (cliente) req.input('p_cliente', cliente);
            if (elaboradoPor) req.input('p_elaborado_por', elaboradoPor);
            if (montoTotal !== null) req.input('p_monto_total', montoTotal);
            if (estado) req.input('p_estado', estado);

            const result = await req.execute('spCotizacionListar');
            await pool.close();

            const parseJson = (val: any) => {
                if (!val) return null;
                if (typeof val === 'object') return val;
                try { return JSON.parse(val); } catch (e) { return null; }
            };

            const rows = result.recordset || [];
            const quotations = rows.map(r => {
                const clientObj = parseJson(r.clientJson) || { id: r.clientId, name: r.clientName || 'Cliente', document: r.clientDocument || '' };
                const userObj = parseJson(r.userJson) || (r.userId ? { id: r.userId, name: r.userName || 'Usuario' } : null);
                const rawProducts = parseJson(r.productsJson) || [];
                const products = rawProducts.map((p: any) => ({
                    ...p,
                    product: parseJson(p.productJson),
                    provider: parseJson(p.providerJson),
                    prestadora: parseJson(p.prestadoraJson),
                    passengers: parseJson(p.passengersJson) || [],
                    variables: parseJson(p.variablesJson) || [],
                    appliedTaxes: parseJson(p.appliedTaxesJson) || []
                }));

                return {
                    id: r.id,
                    internalNumber: r.internalNumber || `${r.id}`,
                    date: r.date,
                    clientId: r.clientId,
                    client: clientObj,
                    userId: r.userId,
                    user: userObj,
                    branchName: r.branchName,
                    totalAmount: r.totalAmount || 0,
                    currency: r.currency || 'COP',
                    exchangeRate: r.exchangeRate || 1,
                    state: r.state || 'NUEVO',
                    stateDescription: r.stateDescription || '',
                    stateUpdatedAt: r.stateUpdatedAt || null,
                    products
                };
            });

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
