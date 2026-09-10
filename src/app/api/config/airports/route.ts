import { paginateArray } from '@/lib/pagination'
import { NextResponse, NextRequest } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT a.[id], a.[code], a.[name], a.[citiesId], a.[isActive],
                           CASE WHEN a.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           c.[name] AS cityName
                    FROM dbo.[Airports] a
                    LEFT JOIN dbo.[Cities] c ON a.[citiesId] = c.[id]
                    ORDER BY a.[id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (a: any) => [a.code, a.name, a.cityName]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const records = await prisma.$queryRawUnsafe('SELECT * FROM public."fnAirportListar"()');
        return NextResponse.json(paginateArray(req, records as any[], (a: any) => [a.code, a.name, a.cityName]));
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}

export async function POST(req: Request) {
    try {
        const userId = req.headers.get('X-User-Id') ? parseInt(req.headers.get('X-User-Id') as string) : 0;
        const body = await req.json();

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('citiesId', body.citiesId ? parseInt(body.citiesId) : null)
                    .query(`
                        INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @citiesId, 1)
                    `);
                await pool.close();
                const newId = res.recordset[0]?.id;
                return NextResponse.json({ success: true, id: newId });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const p_code = body.code !== undefined ? (typeof body.code === 'string' ? "'" + body.code.replace(/'/g, "''") + "'" : body.code) : null;
        const p_name = body.name !== undefined ? (typeof body.name === 'string' ? "'" + body.name.replace(/'/g, "''") + "'" : body.name) : null;
        const p_citiesId = body.citiesId !== undefined && body.citiesId !== '' ? body.citiesId : null;

        const query = `CALL public."spAirportCrear"(${p_code}, ${p_name}, ${p_citiesId}, ${userId}, null, null)`;
        const result: any = await prisma.$queryRawUnsafe(query);
        const mensaje = result[0]?.p_mensaje_resultado || 'ERROR: No message';
        const newId = result[0]?.p_id;

        if (!mensaje.startsWith('SUCCESS')) {
            return NextResponse.json({ error: mensaje }, { status: 400 });
        }

        return NextResponse.json({ success: true, id: newId });
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}

export async function PUT(req: Request) {
    try {
        const userId = req.headers.get('X-User-Id') ? parseInt(req.headers.get('X-User-Id') as string) : 0;
        const body = await req.json();
        const p_id = body.id;

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const isAct = body.isActive !== undefined ? (body.isActive ? 1 : 0) : (body.inactive ? 0 : 1);
                await pool.request()
                    .input('id', parseInt(p_id))
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('citiesId', body.citiesId ? parseInt(body.citiesId) : null)
                    .input('isActive', isAct)
                    .query(`
                        UPDATE dbo.[Airports]
                        SET [code] = @code, [name] = @name, [citiesId] = @citiesId, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const p_code = body.code !== undefined ? (typeof body.code === 'string' ? "'" + body.code.replace(/'/g, "''") + "'" : body.code) : null;
        const p_name = body.name !== undefined ? (typeof body.name === 'string' ? "'" + body.name.replace(/'/g, "''") + "'" : body.name) : null;
        const p_citiesId = body.citiesId !== undefined && body.citiesId !== '' ? body.citiesId : null;

        const query = `CALL public."spAirportActualizar"(${p_id}, ${p_code}, ${p_name}, ${p_citiesId}, ${userId}, null)`;
        const result: any = await prisma.$queryRawUnsafe(query);
        const mensaje = result[0]?.p_mensaje_resultado || 'ERROR: No message';

        if (!mensaje.startsWith('SUCCESS')) {
            return NextResponse.json({ error: mensaje }, { status: 400 });
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."Airports" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(p_id));
        }

        return NextResponse.json({ success: true });
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}

export async function DELETE(req: Request) {
    try {
        const userId = req.headers.get('X-User-Id') ? parseInt(req.headers.get('X-User-Id') as string) : 0;
        const { searchParams } = new URL(req.url);
        const id = searchParams.get('id');

        if (!id) return NextResponse.json({ error: 'ID is required' }, { status: 400 });

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[Airports] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const query = `CALL public."spAirportEliminar"(${id}, ${userId}, null)`;
        const result: any = await prisma.$queryRawUnsafe(query);
        const mensaje = result[0]?.p_mensaje_resultado || 'ERROR: No message';

        if (!mensaje.startsWith('SUCCESS')) {
            return NextResponse.json({ error: mensaje }, { status: 400 });
        }

        return NextResponse.json({ success: true });
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
