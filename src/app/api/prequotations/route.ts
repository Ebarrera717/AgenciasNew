import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { isSQLServerMode, executeSQLServerProcedure } from '@/lib/sqlserver';

export const dynamic = 'force-dynamic';

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const search = searchParams.get('q')?.trim() || '';
        const state = searchParams.get('state')?.trim() || '';
        const branchId = searchParams.get('branchId') ? parseInt(searchParams.get('branchId')!) : 0;

        let results: any[] = [];
        if (isSQLServerMode()) {
            results = await executeSQLServerProcedure('spPreCotizacionListar', {
                p_search: search || null,
                p_state: state || null,
                p_branch_id: branchId || null
            });
        } else {
            results = await prisma.$queryRawUnsafe(
                `SELECT * FROM public."fnPreCotizacionListar"($1, $2, $3)`,
                search ? search : null,
                state ? state : null,
                branchId ? branchId : null
            );
        }

        return NextResponse.json(results);
    } catch (error: any) {
        console.error('Error al consultar pre-cotizaciones:', error);
        return NextResponse.json({ message: 'Error al consultar pre-cotizaciones: ' + (error.message || '') }, { status: 500 });
    }
}

export async function POST(req: NextRequest) {
    console.log('[PREQUOTATION_POST_DEBUG] Entering POST /api/prequotations. isSQLServerMode():', isSQLServerMode());
    try {
        const body = await req.json();
        const userIdHeader = req.headers.get('X-User-Id');
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : (body.userId || 1);

        let preQuotationId: number | null = null;
        let consecutivo: number | null = null;
        let message: string = '';

        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spPreCotizacionCrear', {
                p_data: JSON.stringify(body),
                p_acting_user_id: actingUserId
            });
            const row = Array.isArray(results) ? results[0] : {};
            preQuotationId = row?.p_pre_quotation_id || null;
            consecutivo = row?.p_consecutivo || null;
            message = row?.p_mensaje_resultado || '';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spPreCotizacionCrear"($1::JSONB, $2::INT, NULL, NULL, NULL)`,
                JSON.stringify(body),
                actingUserId
            );
            preQuotationId = results[0]?.p_pre_quotation_id;
            consecutivo = results[0]?.p_consecutivo;
            message = results[0]?.p_mensaje_resultado || '';
        }

        if (!preQuotationId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error al crear pre-cotización');
        }

        return NextResponse.json({
            message: message || `Pre-Cotización #${consecutivo} creada correctamente`,
            preQuotation: { id: preQuotationId, consecutivo }
        });
    } catch (error: any) {
        console.error('Error al crear pre-cotización:', error);
        return NextResponse.json({ message: error.message || 'Error al crear pre-cotización' }, { status: 500 });
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json();
        const { preQuotationId, quotationId, noticeResponse } = body;
        const userIdHeader = req.headers.get('X-User-Id');
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : (body.userId || 1);

        if (!preQuotationId) {
            return NextResponse.json({ message: 'ID de pre-cotización requerido' }, { status: 400 });
        }

        let message: string = '';

        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spPreCotizacionConvertir', {
                p_pre_quotation_id: Number(preQuotationId),
                p_quotation_id: quotationId ? Number(quotationId) : null,
                p_acting_user_id: actingUserId,
                p_notice_response: noticeResponse ? String(noticeResponse) : null
            });
            const row = Array.isArray(results) ? results[0] : {};
            message = row?.p_mensaje_resultado || 'Pre-Cotización actualizada correctamente';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spPreCotizacionConvertir"($1::INT, $2::INT, $3::INT, $4::TEXT, NULL)`,
                Number(preQuotationId),
                quotationId ? Number(quotationId) : null,
                actingUserId,
                noticeResponse ? String(noticeResponse) : null
            );
            message = results[0]?.p_mensaje_resultado || 'Pre-Cotización actualizada correctamente';
        }

        return NextResponse.json({ message });
    } catch (error: any) {
        console.error('Error al actualizar pre-cotización:', error);
        return NextResponse.json({ message: error.message || 'Error al actualizar pre-cotización' }, { status: 500 });
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get('id');

        if (!id) {
            return NextResponse.json({ message: 'ID de pre-cotización requerido' }, { status: 400 });
        }

        let message: string = '';

        if (isSQLServerMode()) {
            const results = await executeSQLServerProcedure('spPreCotizacionEliminar', {
                p_id: Number(id)
            });
            const row = Array.isArray(results) ? results[0] : {};
            message = row?.p_mensaje_resultado || 'Pre-Cotización eliminada correctamente';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spPreCotizacionEliminar"($1::INT, NULL)`,
                Number(id)
            );
            message = results[0]?.p_mensaje_resultado || 'Pre-Cotización eliminada correctamente';
        }

        return NextResponse.json({ message });
    } catch (error: any) {
        console.error('Error al eliminar pre-cotización:', error);
        return NextResponse.json({ message: error.message || 'Error al eliminar pre-cotización' }, { status: 500 });
    }
}
