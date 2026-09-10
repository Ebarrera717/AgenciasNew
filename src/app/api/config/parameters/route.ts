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
                    SELECT [id], [code], [name], [value]
                    FROM dbo.[SystemParameter]
                    ORDER BY [code] ASC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (p: any) => [p.code, p.name, p.value]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const parameters = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnParameterListar()`)
        return NextResponse.json(paginateArray(req, parameters, p => [p.code, p.name, p.value]))
    } catch (error) {
        return NextResponse.json({ message: 'Error retrieving system parameters' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const { code, name, value } = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', code || '')
                    .input('name', name || '')
                    .input('value', value || '')
                    .query(`
                        INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @value)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const parameter = { id: dbId, code, name, value };
                return NextResponse.json({ message: 'Parámetro creado', parameter });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::INT, $5::INT, $6::TEXT)`,
            code,
            name,
            value,
            actingUserId,
            0, // p_parameter_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_parameter_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating parameter');
        }

        const parameter = { id: dbId, code, name, value };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'PARAMETER', description: `Parámetro ${parameter.name} creado (SP).`, metadata: parameter });
        });

        return NextResponse.json({ message: 'Parámetro creado', parameter })
    } catch (error: any) {
        console.error('Error creating parameter:', error);
        return NextResponse.json({ message: 'Error al crear parámetro: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const { id, code, name, value } = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code || '')
                    .input('name', name || '')
                    .input('value', value || '')
                    .query(`
                        UPDATE dbo.[SystemParameter]
                        SET [code] = @code, [name] = @name, [value] = @value
                        WHERE [id] = @id
                    `);
                await pool.close();
                const parameter = { id, code, name, value };
                return NextResponse.json({ message: 'Parámetro actualizado', parameter });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::INT, $6::TEXT)`,
            parseInt(id),
            code,
            name,
            value,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const parameter = { id, code, name, value };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'PARAMETER', description: `Parámetro ${parameter.name} actualizado (SP).`, metadata: parameter });
        });

        return NextResponse.json({ message: 'Parámetro actualizado', parameter })
    } catch (error: any) {
        console.error('Error updating parameter:', error);
        return NextResponse.json({ message: 'Error al actualizar parámetro: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const url = new URL(req.url)
        const id = url.searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (!id) return NextResponse.json({ message: 'Missing ID' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[SystemParameter] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Parámetro eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'PARAMETER', description: `Parámetro con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Parámetro eliminado' })
    } catch (error: any) {
        console.error('Error deleting parameter:', error);
        return NextResponse.json({ message: 'Error al eliminar parámetro: ' + error.message }, { status: 500 })
    }
}
