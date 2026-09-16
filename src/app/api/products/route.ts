import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spProductListar');
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset || [], (p: any) => [p.code, p.type, p.description, p.billingConcept, p.serviceType]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const results = await prisma.product.findMany({
            orderBy: { id: 'desc' }
        });
        return NextResponse.json(paginateArray(req, results, p => [p.code, p.type, p.description, p.billingConcept, p.serviceType]))
    } catch (error) {
        return NextResponse.json({ message: 'Error retrieving products' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, type, description, basePrice, cost, billingConcept, serviceType, flightItinerary, classItinerary, airlineItinerary, ticketTypeId, mandatoryFields, taxIds, isActive } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);

        const parsedTaxIds = taxIds ? (Array.isArray(taxIds) ? taxIds : JSON.parse(taxIds)) : [];

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const taxIdsStr = JSON.stringify(parsedTaxIds);
                const res = await pool.request()
                    .input('code', code || null)
                    .input('type', type || '')
                    .input('description', description || '')
                    .input('basePrice', parseFloat(basePrice?.toString() || '0'))
                    .input('cost', parseFloat(cost?.toString() || '0'))
                    .input('billingConcept', billingConcept || null)
                    .input('serviceType', serviceType || null)
                    .input('taxIds', taxIdsStr)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[Product] ([code], [type], [description], [basePrice], [cost], [billingConcept], [serviceType], [taxIds], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @type, @description, @basePrice, @cost, @billingConcept, @serviceType, @taxIds, @isActive)
                    `);
                await pool.close();
                const product = {
                    id: res.recordset[0]?.id,
                    code: code || null,
                    type,
                    description,
                    basePrice: parseFloat(basePrice?.toString() || '0'),
                    cost: parseFloat(cost?.toString() || '0'),
                    billingConcept: billingConcept || null,
                    serviceType: serviceType || null,
                    taxIds: parsedTaxIds,
                    isActive: isAct
                };
                return NextResponse.json({ message: 'Producto creado', product });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const product = await prisma.product.create({
            data: {
                code: code || null,
                type,
                description,
                basePrice: parseFloat(basePrice?.toString() || '0'),
                cost: parseFloat(cost?.toString() || '0'),
                billingConcept: billingConcept || null,
                serviceType: serviceType || null,
                flightItinerary: flightItinerary || null,
                classItinerary: classItinerary || null,
                airlineItinerary: airlineItinerary || null,
                ticketTypeId: ticketTypeId ? parseInt(ticketTypeId) : null,
                taxIds: parsedTaxIds,
                isActive: isAct
            } as any
        });

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'PRODUCT', description: `Producto ${product.description} creado.`, metadata: product });
        });

        return NextResponse.json({ message: 'Producto creado', product })
    } catch (error: any) {
        console.error('Error creating product:', error);
        return NextResponse.json({ message: 'Error creating product: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, code, type, description, basePrice, cost, billingConcept, serviceType, flightItinerary, classItinerary, airlineItinerary, ticketTypeId, mandatoryFields, taxIds, isActive } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);

        const parsedTaxIds = taxIds ? (Array.isArray(taxIds) ? taxIds : JSON.parse(taxIds)) : [];

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const taxIdsStr = JSON.stringify(parsedTaxIds);
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code || null)
                    .input('type', type || '')
                    .input('description', description || '')
                    .input('basePrice', parseFloat(basePrice?.toString() || '0'))
                    .input('cost', parseFloat(cost?.toString() || '0'))
                    .input('billingConcept', billingConcept || null)
                    .input('serviceType', serviceType || null)
                    .input('taxIds', taxIdsStr)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[Product]
                        SET [code] = @code, [type] = @type, [description] = @description, [basePrice] = @basePrice, [cost] = @cost, [billingConcept] = @billingConcept, [serviceType] = @serviceType, [taxIds] = @taxIds, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const product = {
                    id: parseInt(id),
                    code: code || null,
                    type,
                    description,
                    basePrice: parseFloat(basePrice?.toString() || '0'),
                    cost: parseFloat(cost?.toString() || '0'),
                    billingConcept: billingConcept || null,
                    serviceType: serviceType || null,
                    taxIds: parsedTaxIds,
                    isActive: isAct
                };
                return NextResponse.json({ message: 'Producto actualizado', product });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const product = await prisma.product.update({
            where: { id: parseInt(id) },
            data: {
                code: code || null,
                type,
                description,
                basePrice: parseFloat(basePrice?.toString() || '0'),
                cost: parseFloat(cost?.toString() || '0'),
                billingConcept: billingConcept || null,
                serviceType: serviceType || null,
                flightItinerary: flightItinerary || null,
                classItinerary: classItinerary || null,
                airlineItinerary: airlineItinerary || null,
                ticketTypeId: ticketTypeId ? parseInt(ticketTypeId) : null,
                taxIds: parsedTaxIds,
                isActive: isAct
            } as any
        });

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'PRODUCT', description: `Producto ${product.description} actualizado.`, metadata: product });
        });

        return NextResponse.json({ message: 'Producto actualizado', product })
    } catch (error: any) {
        console.error('Error updating product:', error);
        return NextResponse.json({ message: 'Error updating product: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const url = new URL(req.url)
        const id = url.searchParams.get('id')
        if (!id) return NextResponse.json({ message: 'Missing ID' }, { status: 400 })
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query('DELETE FROM dbo.[Product] WHERE [id] = @id');
                await pool.close();
                return NextResponse.json({ message: 'Producto eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.product.delete({
            where: { id: parseInt(id) }
        });

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'PRODUCT', description: `Producto con ID ${id} eliminado.` });
        });

        return NextResponse.json({ message: 'Producto eliminado' })
    } catch (error: any) {
        console.error('Error deleting product:', error);
        return NextResponse.json({ message: 'Error deleting product: ' + error.message }, { status: 500 })
    }
}
