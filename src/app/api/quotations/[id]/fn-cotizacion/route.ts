import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        let quotationData: any = null;
        if (isSQLServerMode()) {
            const { getSQLServerConnection } = await import('@/lib/sqlserver');
            const pool = await getSQLServerConnection();
            const req = pool.request();
            req.input('p_id', id);
            const result = await req.execute('spCotizacionObtener');
            await pool.close();

            const row = result.recordset?.[0];
            if (row && !row.mensaje) {
                const parseJson = (val: any) => {
                    if (!val) return null;
                    if (typeof val === 'object') return val;
                    try { return JSON.parse(val); } catch (e) { return null; }
                };

                quotationData = {
                    ...row,
                    client: parseJson(row.clientJson),
                    seller: parseJson(row.sellerJson),
                    branch: parseJson(row.branchJson),
                    implant: parseJson(row.implantJson),
                    ticketPrinter: parseJson(row.ticketPrinterJson),
                    products: (parseJson(row.productsJson) || []).map((p: any) => ({
                        ...p,
                        product: parseJson(p.productJson),
                        provider: parseJson(p.providerJson),
                        prestadora: parseJson(p.prestadoraJson),
                        passengers: parseJson(p.passengersJson) || [],
                        variables: parseJson(p.variablesJson) || [],
                        appliedTaxes: parseJson(p.appliedTaxesJson) || [],
                        payments: parseJson(p.paymentsJson) || []
                    })),
                    combos: parseJson(row.combosJson) || [],
                    manualServices: parseJson(row.manualServicesJson) || [],
                    stateHistory: parseJson(row.stateHistoryJson) || []
                };
            }
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `SELECT public.fnCotizacion($1::INT) as data`,
                id
            );
            quotationData = results[0]?.data;
        }

        if (!quotationData) {
            return NextResponse.json({ message: 'Cotización no encontrada' }, { status: 404 })
        }

        return NextResponse.json(quotationData)
    } catch (error: any) {
        console.error('Error executing fnCotizacion API:', error)
        return NextResponse.json({ message: 'Error al consultar fnCotizacion: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
