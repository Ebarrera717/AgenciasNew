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
                    SELECT pr.[id], pr.[code], pr.[name], pr.[category], pr.[location], pr.[providerId], pr.[type], pr.[isActive],
                           CASE WHEN pr.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           p.[name] AS providerName
                    FROM dbo.[Prestadora] pr
                    LEFT JOIN dbo.[Provider] p ON pr.[providerId] = p.[id]
                    ORDER BY pr.[id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (p: any) => [p.code, p.name, p.category, p.type, p.providerName]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public.fnPrestadoraListar()`
        );
        const prestadoras = results.map(row => row.fnprestadoralistar);
        return NextResponse.json(paginateArray(req, prestadoras, p => [p.code, p.name, p.category, p.type, p.providerName]))
    } catch (error) {
        console.error('Error fetching prestadoras:', error);
        return NextResponse.json({ message: 'Error fetching prestadoras' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('category', body.category || null)
                    .input('location', body.location || null)
                    .input('providerId', body.providerId ? parseInt(body.providerId) : null)
                    .input('type', body.type || null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[Prestadora] ([code], [name], [category], [location], [providerId], [type], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @category, @location, @providerId, @type, @isActive)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const prestadora = { id: dbId, ...body };
                return NextResponse.json(prestadora);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spPrestadoraCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::TEXT, $5::INT, $6::TEXT, $7::BOOLEAN, $8::INT, $9::INT, $10::TEXT)`,
            body.code || null,
            body.name,
            body.category || null,
            body.location || null,
            parseInt(body.providerId),
            body.type || null,
            isAct,
            actingUserId,
            0, // p_prestadora_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_prestadora_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating prestadora');
        }

        const prestadora = { id: dbId, ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Prestadora ${prestadora.name} creado (SP).`, metadata: prestadora });
        });

        return NextResponse.json(prestadora)
    } catch (error: any) {
        console.error('Error creating prestadora:', error);
        return NextResponse.json({ message: 'Error creating prestadora: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(body.id))
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('category', body.category || null)
                    .input('location', body.location || null)
                    .input('providerId', body.providerId ? parseInt(body.providerId) : null)
                    .input('type', body.type || null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[Prestadora]
                        SET [code] = @code, [name] = @name, [category] = @category, [location] = @location, [providerId] = @providerId, [type] = @type, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const prestadora = { ...body };
                return NextResponse.json(prestadora);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spPrestadoraActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::TEXT, $6::INT, $7::TEXT, $8::BOOLEAN, $9::INT, $10::TEXT)`,
            parseInt(body.id),
            body.code || null,
            body.name,
            body.category || null,
            body.location || null,
            parseInt(body.providerId),
            body.type || null,
            isAct,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const prestadora = { ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Prestadora ${prestadora.name} actualizado (SP).`, metadata: prestadora });
        });

        return NextResponse.json(prestadora)
    } catch (error: any) {
        console.error('Error updating prestadora:', error);
        return NextResponse.json({ message: 'Error updating prestadora: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        if (!id) return NextResponse.json({ message: 'ID is required' }, { status: 400 })
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[Prestadora] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Prestadora deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spPrestadoraEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Prestadora con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Prestadora deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting prestadora:', error);
        return NextResponse.json({ message: 'Error deleting prestadora: ' + error.message }, { status: 500 })
    }
}
