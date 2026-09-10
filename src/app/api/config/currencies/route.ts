import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

// GET - Listar monedas usando fnMonedaListar()
export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const param = id ? parseInt(id) : null

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const reqPool = pool.request();
                reqPool.input('p_currency_id', param);
                const res = await reqPool.execute('dbo.spMonedaListar');
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset || [], (c: any) => [c.code, c.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public.fnMonedaListar($1::INT)`,
            param
        )

        return NextResponse.json(paginateArray(req, results, c => [c.code, c.name]))
    } catch (error: any) {
        console.error('Error retrieving currencies:', error)
        return NextResponse.json({ message: 'Error retrieving currencies: ' + error.message }, { status: 500 })
    }
}

// POST - Crear moneda usando spMonedaCrear
export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, name, exchangeRate, decimals } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (!code || !name || exchangeRate === undefined) {
            return NextResponse.json({ message: 'Código, nombre y tasa de cambio son requeridos' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', code.toUpperCase())
                    .input('name', name)
                    .input('exchangeRate', parseFloat(exchangeRate))
                    .input('decimals', decimals !== undefined ? parseInt(decimals) : 2)
                    .query(`
                        INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @exchangeRate, @decimals, 1)
                    `);
                await pool.close();
                const currency = { 
                    id: res.recordset[0]?.id, 
                    code: code.toUpperCase(), 
                    name, 
                    exchangeRate: parseFloat(exchangeRate),
                    decimals: decimals !== undefined ? parseInt(decimals) : 2
                };
                return NextResponse.json({ message: 'Moneda creada', currency });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spMonedaCrear($1::TEXT, $2::TEXT, $3::FLOAT, $4::INT, $5::INT, $6::INT, $7::TEXT)`,
            code.toUpperCase(),
            name,
            parseFloat(exchangeRate),
            decimals !== undefined ? parseInt(decimals) : 2,
            actingUserId,
            0,  // p_currency_id (INOUT)
            ''  // p_mensaje_resultado (INOUT)
        )

        const currencyId = results[0]?.p_currency_id
        const message: string = results[0]?.p_mensaje_resultado || ''

        if (!currencyId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error al crear la moneda')
        }

        const currency = { 
            id: currencyId, 
            code: code.toUpperCase(), 
            name, 
            exchangeRate: parseFloat(exchangeRate),
            decimals: decimals !== undefined ? parseInt(decimals) : 2
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MONEDA', description: `Moneda ${code} creada (SP).`, metadata: currency })
        })

        return NextResponse.json({ message: 'Moneda creada', currency })
    } catch (error: any) {
        console.error('Error creating currency:', error)
        return NextResponse.json({ message: 'Error creating currency: ' + error.message }, { status: 500 })
    }
}

// PUT - Actualizar moneda usando spMonedaActualizar
export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, code, name, exchangeRate, decimals } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (!id || !code || !name || exchangeRate === undefined) {
            return NextResponse.json({ message: 'ID, código, nombre y tasa de cambio son requeridos' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code.toUpperCase())
                    .input('name', name)
                    .input('exchangeRate', parseFloat(exchangeRate))
                    .input('decimals', decimals !== undefined ? parseInt(decimals) : 2)
                    .query(`
                        UPDATE dbo.[Currency]
                        SET [code] = @code, [name] = @name, [exchangeRate] = @exchangeRate, [decimals] = @decimals
                        WHERE [id] = @id
                    `);
                await pool.close();
                const currency = { 
                    id: parseInt(id), 
                    code: code.toUpperCase(), 
                    name, 
                    exchangeRate: parseFloat(exchangeRate),
                    decimals: decimals !== undefined ? parseInt(decimals) : 2
                };
                return NextResponse.json({ message: 'Moneda actualizada', currency });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spMonedaActualizar($1::INT, $2::TEXT, $3::TEXT, $4::FLOAT, $5::INT, $6::INT, $7::TEXT)`,
            parseInt(id),
            code.toUpperCase(),
            name,
            parseFloat(exchangeRate),
            decimals !== undefined ? parseInt(decimals) : 2,
            actingUserId,
            ''  // p_mensaje_resultado (INOUT)
        )

        const message: string = results[0]?.p_mensaje_resultado || ''
        if (message.startsWith('ERROR')) {
            throw new Error(message)
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."Currency" SET "isActive" = $1 WHERE id = $2`, isAct, parseInt(id));
        }

        const currency = { 
            id: parseInt(id), 
            code: code.toUpperCase(), 
            name, 
            exchangeRate: parseFloat(exchangeRate),
            decimals: decimals !== undefined ? parseInt(decimals) : 2
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MONEDA', description: `Moneda ${code} actualizada (SP).`, metadata: currency })
        })

        return NextResponse.json({ message: 'Moneda actualizada', currency })
    } catch (error: any) {
        console.error('Error updating currency:', error)
        return NextResponse.json({ message: 'Error updating currency: ' + error.message }, { status: 500 })
    }
}

// DELETE - Eliminar moneda usando spMonedaEliminar
export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (!id) {
            return NextResponse.json({ message: 'ID es requerido' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query('DELETE FROM dbo.[Currency] WHERE [id] = @id');
                await pool.close();
                return NextResponse.json({ message: 'Moneda eliminada exitosamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spMonedaEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            ''  // p_mensaje_resultado (INOUT)
        )

        const message: string = results[0]?.p_mensaje_resultado || ''
        if (message.startsWith('ERROR')) {
            throw new Error(message)
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MONEDA', description: `Moneda con ID ${id} eliminada (SP).` })
        })

        return NextResponse.json({ message: 'Moneda eliminada exitosamente' })
    } catch (error: any) {
        console.error('Error deleting currency:', error)
        return NextResponse.json({ message: 'Error deleting currency: ' + error.message }, { status: 500 })
    }
}
