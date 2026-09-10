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
                    SELECT [id], [code], [name], [description], [isActive],
                           CASE WHEN [isActive] = 1 THEN 0 ELSE 1 END AS [inactive]
                    FROM dbo.[TicketType]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (t: any) => [t.code, t.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const records = await prisma.$queryRawUnsafe('SELECT * FROM public."fnTicketTypeListar"()');
        return NextResponse.json(paginateArray(req, records as any[], (t: any) => [t.code, t.name]));
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}

export async function POST(req: Request) {
    try {
        const userId = req.headers.get('X-User-Id') ? parseInt(req.headers.get('X-User-Id') as string) : 0;
        const body = await req.json();
        const p_isActive = body.isActive !== undefined ? (body.isActive ? 1 : 0) : 1;

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('description', body.description || null)
                    .input('isActive', p_isActive)
                    .query(`
                        INSERT INTO dbo.[TicketType] ([code], [name], [description], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @description, @isActive)
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
        const p_description = body.description !== undefined && body.description !== '' ? "'" + String(body.description).replace(/'/g, "''") + "'" : 'null';

        const query = `CALL public."spTicketTypeCrear"(${p_code}, ${p_name}, ${p_description}, ${p_isActive === 1}, ${userId}, null, null)`;
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
        const p_isActive = body.isActive !== undefined ? (body.isActive ? 1 : 0) : (body.inactive ? 0 : 1);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(p_id))
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('description', body.description || null)
                    .input('isActive', p_isActive)
                    .query(`
                        UPDATE dbo.[TicketType]
                        SET [code] = @code, [name] = @name, [description] = @description, [isActive] = @isActive
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
        const p_description = body.description !== undefined && body.description !== '' ? "'" + String(body.description).replace(/'/g, "''") + "'" : 'null';

        const query = `CALL public."spTicketTypeActualizar"(${p_id}, ${p_code}, ${p_name}, ${p_description}, ${p_isActive === 1}, ${userId}, null)`;
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
                    .query(`DELETE FROM dbo.[TicketType] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const query = `CALL public."spTicketTypeEliminar"(${id}, ${userId}, null)`;
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
