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
                const res = await pool.request().query(`
                    SELECT [id], [code], [name], [type], [isActive], CASE WHEN [isActive] = 1 THEN 0 ELSE 1 END AS [inactive]
                    FROM dbo.[CreditCard]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (c: any) => [c.code, c.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const creditCards = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public."fnCreditCardListar"()`)
        return NextResponse.json(paginateArray(req, creditCards, c => [c.code, c.name]))
    } catch (error) {
        return NextResponse.json({ message: 'Error fetching credit cards' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('type', body.type || null)
                    .query(`
                        INSERT INTO dbo.[CreditCard] ([code], [name], [type], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @type, 1)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const creditCard = { id: dbId, ...body, inactive: false };
                return NextResponse.json(creditCard);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCreditCardCrear"($1::TEXT, $2::TEXT, $3::TEXT, $4::INT, $5::INT, $6::TEXT)`,
            body.code || null,
            body.name,
            body.type || null,
            actingUserId,
            0, // p_card_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_card_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating credit card');
        }

        const creditCard = { id: dbId, ...body, inactive: false };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Tarjeta de Crédito ${creditCard.name} creada (SP).`, metadata: creditCard });
        });

        return NextResponse.json(creditCard)
    } catch (error: any) {
        console.error('Error creating credit card:', error);
        return NextResponse.json({ message: 'Error al crear tarjeta de crédito: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        const isAct = body.isActive !== undefined ? Boolean(body.isActive) : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(body.id))
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('type', body.type || null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[CreditCard]
                        SET [code] = @code, [name] = @name, [type] = @type, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const creditCard = { ...body };
                return NextResponse.json(creditCard);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCreditCardActualizar"($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::BOOLEAN, $6::INT, $7::TEXT)`,
            parseInt(body.id),
            body.code || null,
            body.name,
            body.type || null,
            !isAct,
            actingUserId,
            '' // p_mensaje_resultado
        );
        await prisma.$executeRawUnsafe(`UPDATE public."CreditCard" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(body.id));

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const creditCard = { ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Tarjeta de Crédito ${creditCard.name} actualizada (SP).`, metadata: creditCard });
        });

        return NextResponse.json(creditCard)
    } catch (error: any) {
        console.error('Error updating credit card:', error);
        return NextResponse.json({ message: 'Error al actualizar tarjeta de crédito: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        if (!id) return NextResponse.json({ message: 'ID is required' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[CreditCard] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Credit card deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spCreditCardEliminar"($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Tarjeta de Crédito con ID ${id} eliminada (SP).` });
        });

        return NextResponse.json({ message: 'Credit card deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting credit card:', error);
        return NextResponse.json({ message: 'Error al eliminar tarjeta de crédito: ' + error.message }, { status: 500 })
    }
}
