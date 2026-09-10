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
                    SELECT [id], [code], [name], [dane], [region], [prefix], [currencyId] AS [curencyId], [isActive], CASE WHEN [isActive] = 1 THEN 0 ELSE 1 END AS [inactive]
                    FROM dbo.[Countries]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (c: any) => [c.code, c.name, c.dane]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const records = await prisma.$queryRawUnsafe('SELECT * FROM public."fnCountryListar"()');
        return NextResponse.json(paginateArray(req, records as any[], (c: any) => [c.code, c.name, c.dane]));
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
                    .input('dane', body.dane || null)
                    .input('region', body.region || null)
                    .input('prefix', body.prefix || null)
                    .input('currencyId', body.curencyId ? parseInt(body.curencyId) : null)
                    .query(`
                        INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [currencyId], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @dane, @region, @prefix, @currencyId, 1)
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
        const p_dane = body.dane !== undefined && body.dane !== '' ? "'" + String(body.dane).replace(/'/g, "''") + "'" : null;
        const p_region = body.region !== undefined && body.region !== '' ? "'" + String(body.region).replace(/'/g, "''") + "'" : null;
        const p_prefix = body.prefix !== undefined && body.prefix !== '' ? "'" + String(body.prefix).replace(/'/g, "''") + "'" : null;
        const p_curencyId = body.curencyId !== undefined && body.curencyId !== '' ? body.curencyId : null;

        const query = `CALL public."spCountryCrear"(${p_code}, ${p_name}, ${p_dane}, ${p_region}, ${p_prefix}, ${p_curencyId}, ${userId}, null, null)`;
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
                    .input('dane', body.dane || null)
                    .input('region', body.region || null)
                    .input('prefix', body.prefix || null)
                    .input('currencyId', body.curencyId ? parseInt(body.curencyId) : null)
                    .input('isActive', isAct)
                    .query(`
                        UPDATE dbo.[Countries]
                        SET [code] = @code, [name] = @name, [dane] = @dane, [region] = @region, [prefix] = @prefix, [currencyId] = @currencyId, [isActive] = @isActive
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
        const p_dane = body.dane !== undefined && body.dane !== '' ? "'" + String(body.dane).replace(/'/g, "''") + "'" : null;
        const p_region = body.region !== undefined && body.region !== '' ? "'" + String(body.region).replace(/'/g, "''") + "'" : null;
        const p_prefix = body.prefix !== undefined && body.prefix !== '' ? "'" + String(body.prefix).replace(/'/g, "''") + "'" : null;
        const p_curencyId = body.curencyId !== undefined && body.curencyId !== '' ? body.curencyId : null;

        const query = `CALL public."spCountryActualizar"(${p_id}, ${p_code}, ${p_name}, ${p_dane}, ${p_region}, ${p_prefix}, ${p_curencyId}, ${userId}, null)`;
        const result: any = await prisma.$queryRawUnsafe(query);
        const mensaje = result[0]?.p_mensaje_resultado || 'ERROR: No message';

        if (!mensaje.startsWith('SUCCESS')) {
            return NextResponse.json({ error: mensaje }, { status: 400 });
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."Countries" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(p_id));
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
                    .query(`DELETE FROM dbo.[Countries] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const query = `CALL public."spCountryEliminar"(${id}, ${userId}, null)`;
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
