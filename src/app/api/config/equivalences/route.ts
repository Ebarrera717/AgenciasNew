import { paginateArray } from '@/lib/pagination'
import { NextResponse, NextRequest } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id_interfaces = searchParams.get('id_interfaces')
        const id_master = searchParams.get('id_master')

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                let q = `
                    SELECT eq.[id], eq.[id_interfaces], eq.[id_master], eq.[cd_maestro], eq.[cd_codigo], eq.[cd_codigointe], eq.[isActive],
                           CASE WHEN eq.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           i.[name] AS interfaceName, m.[name] AS masterName
                    FROM dbo.[EquivalencesInterfaces] eq
                    LEFT JOIN dbo.[Interfaces] i ON eq.[id_interfaces] = i.[id]
                    LEFT JOIN dbo.[Master] m ON eq.[id_master] = m.[id]
                    WHERE 1=1
                `;
                const request = pool.request();
                if (id_interfaces && id_interfaces !== 'NULL') {
                    request.input('id_interfaces', parseInt(id_interfaces));
                    q += ` AND eq.[id_interfaces] = @id_interfaces`;
                }
                if (id_master && id_master !== 'NULL') {
                    request.input('id_master', parseInt(id_master));
                    q += ` AND eq.[id_master] = @id_master`;
                }
                q += ` ORDER BY eq.[id] DESC`;
                const res = await request.query(q);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (e: any) => [e.cd_maestro, e.cd_codigo, e.cd_codigointe, e.interfaceName, e.masterName]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const result = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnEquivalencesInterfacesConsultar"(${id_interfaces || 'NULL'}, ${id_master || 'NULL'})`)
        return NextResponse.json(paginateArray(req, result as any[], (e: any) => [e.cd_maestro, e.cd_codigo, e.cd_codigointe, e.interfaceName, e.masterName]))
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function POST(req: Request) {
    try {
        const body = await req.json()
        const { id_interfaces, id_master, cd_maestro, cd_codigo, cd_codigoInte } = body

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id_interfaces', Number(id_interfaces))
                    .input('id_master', Number(id_master))
                    .input('cd_maestro', cd_maestro || '')
                    .input('cd_codigo', cd_codigo || '')
                    .input('cd_codigointe', cd_codigoInte || '')
                    .query(`
                        INSERT INTO dbo.[EquivalencesInterfaces] ([id_interfaces], [id_master], [cd_maestro], [cd_codigo], [cd_codigointe], [isActive])
                        VALUES (@id_interfaces, @id_master, @cd_maestro, @cd_codigo, @cd_codigointe, 1)
                    `);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const userId = req.headers.get('X-User-Id') || '1'
        await prisma.$executeRawUnsafe(
            `CALL public."spEquivalencesInterfacesCrear"($1, $2, $3, $4, $5, $6, $7)`,
            Number(id_interfaces), Number(id_master), cd_maestro, cd_codigo, cd_codigoInte || '', Number(userId), null
        )
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function PUT(req: Request) {
    try {
        const body = await req.json()
        const { id, id_interfaces, id_master, cd_maestro, cd_codigo, cd_codigoInte } = body

        if (!id) return NextResponse.json({ message: 'ID required' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const isAct = body.isActive !== undefined ? (body.isActive ? 1 : 0) : (body.inactive ? 0 : 1);
                await pool.request()
                    .input('id', Number(id))
                    .input('id_interfaces', Number(id_interfaces))
                    .input('id_master', Number(id_master))
                    .input('cd_maestro', cd_maestro || '')
                    .input('cd_codigo', cd_codigo || '')
                    .input('cd_codigointe', cd_codigoInte || '')
                    .input('isActive', isAct)
                    .query(`
                        UPDATE dbo.[EquivalencesInterfaces] 
                        SET [id_interfaces] = @id_interfaces, [id_master] = @id_master, [cd_maestro] = @cd_maestro,
                            [cd_codigo] = @cd_codigo, [cd_codigointe] = @cd_codigointe, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.$executeRawUnsafe(
            `UPDATE public."EquivalencesInterfaces" 
             SET id_interfaces = $1, id_master = $2, cd_maestro = $3, cd_codigo = $4, "cd_codigointe" = $5 
             WHERE id = $6`,
            Number(id_interfaces), Number(id_master), cd_maestro, cd_codigo, cd_codigoInte || '', Number(id)
        )
        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."EquivalencesInterfaces" SET "isActive" = $1 WHERE id = $2`, isAct, Number(id));
        }
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}

export async function DELETE(req: Request) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')

        if (!id) return NextResponse.json({ message: 'ID required' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', Number(id))
                    .query(`DELETE FROM dbo.[EquivalencesInterfaces] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const userId = req.headers.get('X-User-Id') || '1'
        await prisma.$executeRawUnsafe(`CALL public."spEquivalencesInterfacesEliminar"($1, $2, $3)`, Number(id), Number(userId), null)
        return NextResponse.json({ success: true })
    } catch (error: any) {
        return NextResponse.json({ message: error.message }, { status: 500 })
    }
}
