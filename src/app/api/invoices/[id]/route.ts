import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode } from '@/lib/sqlserver'
import mssql from 'mssql'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        if (isSQLServerMode()) {
            const { getSQLServerConnection } = await import('@/lib/sqlserver');
            let pool;
            try {
                pool = await getSQLServerConnection();
                const req = pool.request();
                req.input('p_id', mssql.Int, id);
                const result = await req.execute('dbo.spInvoicesObtener');
                await pool.close();

                const sets: any[] = (result.recordsets as any) || [];
                const invoiceRow = sets[0]?.[0];
                if (!invoiceRow) {
                    return NextResponse.json({ message: 'Factura no encontrada' }, { status: 404 });
                }

                const productsRaw: any[] = sets[1] || [];
                const taxesRaw: any[] = sets[2] || [];
                const paxesRaw: any[] = sets[3] || [];
                const varsRaw: any[] = sets[4] || [];
                const pymtsRaw: any[] = sets[5] || [];
                const itinsRaw: any[] = sets[6] || [];
                const combosRaw: any[] = sets[7] || [];

                const products = productsRaw.map((p: any) => ({
                    ...p,
                    ticketCode: p.ticketCode || null,
                    appliedTaxes: taxesRaw.filter((t: any) => t.invoiceProductId === p.id),
                    passengers: paxesRaw.filter((px: any) => px.invoiceProductId === p.id),
                    variables: varsRaw.filter((v: any) => v.invoiceProductId === p.id),
                    payments: pymtsRaw.filter((pm: any) => pm.invoiceProductId === p.id),
                    itinerariesItineraryList: itinsRaw.filter((it: any) => it.invoiceProductId === p.id),
                    product: { id: p.productId, name: p.productName, code: p.productCode }
                }));

                const invoice = {
                    ...invoiceRow,
                    products,
                    combos: combosRaw
                };

                return NextResponse.json(invoice);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const invoice = await prisma.invoices.findUnique({
            where: { id }
        }) as any;

        if (!invoice) {
            return NextResponse.json({ message: 'Factura no encontrada' }, { status: 404 })
        }

        const productsRaw = await prisma.invoicesProduct.findMany({ where: { invoiceId: id } });
        
        const products = [];
        for (const p of productsRaw) {
            const appliedTaxes = await prisma.invoicesProductTax.findMany({ where: { invoiceProductId: p.id } });
            const passengers = await prisma.invoicesProductPasenger.findMany({ where: { invoiceProductId: p.id } });
            const variables = await prisma.invoicesProductVariable.findMany({ where: { invoiceProductId: p.id } });
            const payments = await prisma.invoicesProductPayment.findMany({ where: { invoiceProductId: p.id } });
            const itinerariesItineraryList = await prisma.invoicesProductItinerary.findMany({ where: { invoiceProductId: p.id }, orderBy: { id: 'asc' } });
            
            let productDetails = null;
            if (p.productId) {
                productDetails = await prisma.product.findUnique({ where: { id: p.productId } });
            }
            
            products.push({
                ...p,
                ticketCode: (p as any).ticketCode || null,
                appliedTaxes,
                passengers,
                variables,
                payments,
                itinerariesItineraryList,
                product: productDetails
            });
        }
        invoice.products = products;

        const combosRaw = await prisma.invoicesProductCombo.findMany({ where: { invoiceId: id } });
        const combos = [];
        for (const c of combosRaw) {
             let comboDetails = null;
             if (c.comboId) {
                 comboDetails = await prisma.combo.findUnique({ where: { id: c.comboId } });
             }
             combos.push({
                 ...c,
                 combo: comboDetails
             });
        }
        invoice.combos = combos;

        return NextResponse.json(invoice)
    } catch (error: any) {
        console.error('Error fetching invoice:', error)
        return NextResponse.json({ message: 'Error interno del servidor', error: error.message }, { status: 500 })
    }
}

export async function PUT(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    const startTime = Date.now()
    const { generateTraceCode, recordTraceEvent } = await import('@/lib/traceability')
    const traceCode = generateTraceCode()
    let actingUserId = 1

    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const body = await request.json()
        console.log("PUT INVOICE BODY:", JSON.stringify(body, null, 2));
        const userIdHeader = request.headers.get('X-User-Id')
        actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Edición de Factura',
            action: 'ACTUALIZAR_FACTURA',
            process: 'Actualización de Factura',
            eventType: 'INICIO_PROCESO',
            stepName: 'Recepción y Validación de Cambios',
            endpoint: `/api/invoices/${id}`,
            inputData: body,
            affectedId: id,
            status: 'IN_PROGRESS'
        });

        let message = '';
        if (isSQLServerMode()) {
            const { executeSQLServerProcedure } = await import('@/lib/sqlserver');

            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Edición de Factura',
                action: 'ACTUALIZAR_FACTURA',
                process: 'Ejecución SP T-SQL',
                eventType: 'SP_INICIO',
                stepName: 'Invocación spInvoicesActualizar (SQL Server)',
                spName: 'spInvoicesActualizar',
                affectedId: id,
                status: 'IN_PROGRESS'
            });

            const results = await executeSQLServerProcedure('spInvoicesActualizar', {
                p_id: id,
                p_data: JSON.stringify(body),
                p_acting_user_id: actingUserId
            });
            const row = Array.isArray(results) ? results[0] : {};
            message = row?.p_mensaje_resultado || '';
        } else {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Edición de Factura',
                action: 'ACTUALIZAR_FACTURA',
                process: 'Ejecución SP PostgreSQL',
                eventType: 'SP_INICIO',
                stepName: 'Invocación spInvoicesActualizar (PostgreSQL)',
                spName: 'spInvoicesActualizar',
                affectedId: id,
                status: 'IN_PROGRESS'
            });

            const results: any[] = await prisma.$queryRawUnsafe(
                `CALL public.spInvoicesActualizar($1::INT, $2::JSONB, $3::INT, $4::TEXT)`,
                id,
                JSON.stringify(body),
                actingUserId,
                '' // p_mensaje_resultado
            );

            message = results[0]?.p_mensaje_resultado || '';
        }

        if (message.startsWith('ERROR')) {
            await recordTraceEvent({
                code: traceCode,
                userId: actingUserId,
                module: 'Facturación',
                screen: 'Edición de Factura',
                action: 'ACTUALIZAR_FACTURA',
                process: 'Error en SP',
                eventType: 'ERROR',
                stepName: 'Actualización Fallida',
                endpoint: `/api/invoices/${id}`,
                durationMs: Date.now() - startTime,
                status: 'ERROR',
                affectedId: id,
                functionalMessage: message
            });
            throw new Error(message);
        }

        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Edición de Factura',
            action: 'ACTUALIZAR_FACTURA',
            process: 'Fin de Actualización',
            eventType: 'FIN_PROCESO',
            stepName: 'Factura Actualizada Exitosamente',
            endpoint: `/api/invoices/${id}`,
            durationMs: Date.now() - startTime,
            status: 'SUCCESS',
            outputData: { id, message },
            affectedId: id,
            functionalMessage: message || `Factura #${id} actualizada exitosamente`
        });

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE',
                module: 'INVOICE',
                description: `Factura ${id} actualizada (SP). ${message}`,
                metadata: { id }
            });
        });

        return NextResponse.json({ message: message || 'Factura actualizada', invoice: { id } })
    } catch (error: any) {
        console.error('Error updating invoice (PUT):', error)
        await recordTraceEvent({
            code: traceCode,
            userId: actingUserId,
            module: 'Facturación',
            screen: 'Edición de Factura',
            action: 'ACTUALIZAR_FACTURA',
            process: 'Excepción Capturada',
            eventType: 'EXCEPCION',
            stepName: 'Fallo No Controlado',
            endpoint: `/api/invoices/${id}`,
            durationMs: Date.now() - startTime,
            status: 'ERROR',
            techMessage: error.message,
            stackTrace: error.stack
        });
        return NextResponse.json({ message: 'Error al actualizar la factura: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}

export async function DELETE() {
    return NextResponse.json(
        { message: 'Las facturas no se pueden eliminar del sistema. Solo pueden ser anuladas.' },
        { status: 400 }
    )
}

