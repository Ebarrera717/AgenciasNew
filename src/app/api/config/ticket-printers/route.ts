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
                    SELECT [id], [code], [name], [email], [isActive], CASE WHEN [isActive] = 1 THEN 0 ELSE 1 END AS [inactive]
                    FROM dbo.[TicketPrinter]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (tp: any) => [tp.code, tp.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const printers = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnTicketPrinterListar()`)
        return NextResponse.json(paginateArray(req, printers, tp => [tp.code, tp.name]))
    } catch (error) {
        return NextResponse.json({ message: 'Error fetching ticket printers' }, { status: 500 })
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
                    .input('email', body.email || null)
                    .query(`
                        INSERT INTO dbo.[TicketPrinter] ([code], [name], [email], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @email, 1)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const printer = { id: dbId, ...body };
                return NextResponse.json(printer);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        
        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spTicketPrinterCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::INT, $5::INT, $6::TEXT)`,
            body.code || null,
            body.name,
            body.email || null,
            actingUserId,
            0, // p_printer_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_printer_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating ticket printer');
        }

        const printer = { id: dbId, ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Tiqueteador ${printer.name} creado (SP).`, metadata: printer });
        });

        return NextResponse.json(printer)
    } catch (error: any) {
        console.error('Error creating ticket printer:', error);
        return NextResponse.json({ message: 'Error al crear tiqueteador: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const isAct = body.isActive !== undefined ? (body.isActive ? 1 : 0) : (body.inactive ? 0 : 1);
                await pool.request()
                    .input('id', parseInt(body.id))
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('email', body.email || null)
                    .input('isActive', isAct)
                    .query(`
                        UPDATE dbo.[TicketPrinter]
                        SET [code] = @code, [name] = @name, [email] = @email, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const printer = { ...body };
                return NextResponse.json(printer);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spTicketPrinterActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::INT, $6::TEXT)`,
            parseInt(body.id),
            body.code || null,
            body.name,
            body.email || null,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."TicketPrinter" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(body.id));
        }

        const printer = { ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Tiqueteador ${printer.name} actualizado (SP).`, metadata: printer });
        });

        return NextResponse.json(printer)
    } catch (error: any) {
        console.error('Error updating ticket printer:', error);
        return NextResponse.json({ message: 'Error al actualizar tiqueteador: ' + error.message }, { status: 500 })
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
                    .query(`DELETE FROM dbo.[TicketPrinter] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Ticket printer deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spTicketPrinterEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Tiqueteador con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Ticket printer deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting ticket printer:', error);
        return NextResponse.json({ message: 'Error al eliminar tiqueteador: ' + error.message }, { status: 500 })
    }
}
