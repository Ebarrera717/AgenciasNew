import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'
import { Pool } from 'pg'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        let dbQuotationId: number | null = null;
        let message: string = '';

        if (isSQLServerMode()) {
            console.log('[QUOTATION_POST] Modo SQL Server activo. Ejecutando spCotizacionCrear nativo...');
            const { executeSQLServerProcedure } = await import('@/lib/sqlserver');
            const results = await executeSQLServerProcedure('spCotizacionCrear', {
                p_data: JSON.stringify(body),
                p_acting_user_id: actingUserId
            });
            const row = Array.isArray(results) ? results[0] : {};
            dbQuotationId = row?.p_quotation_id || null;
            message = row?.p_mensaje_resultado || '';
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public."spCotizacionCrear"($1::JSONB, $2::INT, $3::INT, $4::TEXT)`,
                JSON.stringify(body),
                actingUserId,
                0, // p_quotation_id
                '' // p_mensaje_resultado
            );

            dbQuotationId = results[0]?.p_quotation_id;
            message = results[0]?.p_mensaje_resultado || '';
        }

        if (!dbQuotationId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating quotation');
        }

        const quotation = { id: dbQuotationId };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'CREATE',
                module: 'QUOTATION',
                description: `Cotización ${dbQuotationId} creada (SP). ${message}`,
                metadata: { id: dbQuotationId }
            });
        });

        // Intentar auto-exportar a SQL Server si está en modo SQL Server o parámetro activo
        if (dbQuotationId) {
            try {
                const exportRes = await prisma.$queryRawUnsafe<any[]>(
                    `CALL public.spExportQuotation($1, $2, $3)`,
                    dbQuotationId.toString(),
                    actingUserId,
                    ''
                );
                const xmlRow = exportRes && exportRes.length > 0 ? exportRes[0] : null;
                const xmlStr = xmlRow?.mensaje_resultado || xmlRow?.p_mensaje_resultado || (xmlRow && typeof xmlRow === 'object' ? Object.values(xmlRow)[0] : '');
                if (xmlStr && typeof xmlStr === 'string' && xmlStr.trim().startsWith('<')) {
                    const { executeSQLServerProcedure } = await import('@/lib/sqlserver');
                    await executeSQLServerProcedure('spCotizacionesCrear', { xml: xmlStr }).catch((e: any) => console.warn('[AUTO_EXPORT] SQL Server import warning:', e?.message));
                }
            } catch (expErr: any) {
                console.warn('[AUTO_EXPORT] Auto-export to SQL Server warning:', expErr?.message);
            }
        }

        const finalMessage = message && message !== '' ? message : 'SUCCESS: Cotización creada correctamente con ID ' + dbQuotationId;
        return NextResponse.json({ message: finalMessage, quotation })
    } catch (error: any) {
        console.error('Error saving quotation (POST):', error)
        return NextResponse.json({ message: 'Error al guardar la cotización: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
