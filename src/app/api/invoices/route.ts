import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'
import { Pool } from 'pg'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        console.log("POST INVOICE BODY:", JSON.stringify(body, null, 2));
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        let dbInvoiceId: number | null = null;
        let message: string = '';

        if (isSQLServerMode()) {
            console.log('[INVOICE_POST] Modo SQL Server activo. Ejecutando spInvoicesCrear vía pg Pool...');
            const pgUrl = process.env.DATABASE_URL_POSTGRES || 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public';
            const pool = new Pool({ connectionString: pgUrl });
            const client = await pool.connect();
            try {
                const results = await client.query(
                    `CALL public.spInvoicesCrear($1::JSONB, $2::INT, $3::INT, $4::TEXT)`,
                    [JSON.stringify(body), actingUserId, 0, '']
                );
                const row = results.rows[0] || {};
                dbInvoiceId = row.p_invoice_id;
                message = row.p_mensaje_resultado || '';

                if (dbInvoiceId && Array.isArray(body.items)) {
                    for (const item of body.items) {
                        const bProdId = item.bookingProductId || (item.isGDS ? item.id : null);
                        if (bProdId && !isNaN(parseInt(bProdId))) {
                            try {
                                await client.query(
                                    `UPDATE public."BookingProductGDS" 
                                     SET "state" = 'FACTURADO', "invoiceId" = $1 
                                     WHERE id = $2`,
                                    [parseInt(dbInvoiceId.toString()), parseInt(bProdId)]
                                );
                            } catch (e) {
                                console.error(`Error actualizando estado FACTURADO en BookingProductGDS #${bProdId}:`, e);
                            }
                        }
                    }
                }
            } finally {
                client.release();
                await pool.end();
            }
        } else {
            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public.spInvoicesCrear($1::JSONB, $2::INT, $3::INT, $4::TEXT)`,
                JSON.stringify(body),
                actingUserId,
                0, // p_invoice_id
                '' // p_mensaje_resultado
            );

            dbInvoiceId = results[0]?.p_invoice_id;
            message = results[0]?.p_mensaje_resultado || '';

            if (dbInvoiceId && Array.isArray(body.items)) {
                for (const item of body.items) {
                    const bProdId = item.bookingProductId || (item.isGDS ? item.id : null);
                    if (bProdId && !isNaN(parseInt(bProdId))) {
                        try {
                            await prisma.$queryRawUnsafe(
                                `UPDATE public."BookingProductGDS" 
                                 SET "state" = 'FACTURADO', "invoiceId" = $1 
                                 WHERE id = $2`,
                                parseInt(dbInvoiceId.toString()),
                                parseInt(bProdId)
                            );
                        } catch (e) {
                            console.error(`Error actualizando estado FACTURADO en BookingProductGDS #${bProdId}:`, e);
                        }
                    }
                }
            }
        }

        if (!dbInvoiceId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating invoice');
        }

        const invoice = { id: dbInvoiceId };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'CREATE',
                module: 'INVOICE',
                description: `Factura ${dbInvoiceId} creada (SP). ${message}`,
                metadata: { id: dbInvoiceId }
            });
        });

        const finalMessage = message && message !== '' ? message : 'SUCCESS: Factura creada correctamente con ID ' + dbInvoiceId;
        return NextResponse.json({ message: finalMessage, invoice })
    } catch (error: any) {
        console.error('Error saving invoice (POST):', error)
        return NextResponse.json({ message: 'Error al guardar la factura: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
