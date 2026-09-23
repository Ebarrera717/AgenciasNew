import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const idParam = searchParams.get('id')

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                if (idParam) {
                    const res = await pool.request()
                        .input('id', parseInt(idParam))
                        .query('SELECT TOP 1 * FROM dbo.[Client] WHERE [id] = @id');
                    await pool.close();
                    const client = res.recordset[0];
                    if (!client) return NextResponse.json({ message: 'Client not found' }, { status: 404 });
                    return NextResponse.json(client);
                }

                const res = await pool.request().execute('dbo.spClienteListar');
                await pool.close();
                let clients: any[] = (res.recordset as any[]) || [];
                const includeInactive = searchParams.get('includeInactive') === 'true';
                if (!includeInactive) {
                    clients = clients.filter((c: any) => c.isActive !== false && c.isActive !== 0);
                }
                return NextResponse.json(paginateArray(req, clients, (c: any) => [c.name, c.document]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        if (idParam) {
            const client = await (prisma as any).client?.findUnique({
                where: { id: parseInt(idParam) }
            })
            if (!client) {
                return NextResponse.json({ message: 'Client not found' }, { status: 404 })
            }
            return NextResponse.json(client)
        }

        const includeInactive = searchParams.get('includeInactive') === 'true'
        let clients = await prisma.$queryRawUnsafe<any[]>(
            `SELECT * FROM public.fnClienteListar()`
        )
        if (!includeInactive) {
            clients = clients.filter(c => c.isActive !== false)
        }
        return NextResponse.json(paginateArray(req, clients, c => [c.name, c.document]))
    } catch (error: any) {
        console.error('Error retrieving clients:', error);
        return NextResponse.json({ message: 'Error al obtener clientes: ' + (error?.message || error) }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { name, document, contactInfo, address, mandatoryVariables, sellerId, isActive, creditDays } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);
        const cDays = parseInt(creditDays) || 0;

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mVarsStr = mandatoryVariables ? JSON.stringify(mandatoryVariables) : null;
                const res = await pool.request()
                    .input('name', name || '')
                    .input('document', document || '')
                    .input('contactInfo', contactInfo || null)
                    .input('address', address || null)
                    .input('mandatoryVariables', mVarsStr)
                    .input('sellerId', sellerId ? parseInt(sellerId) : null)
                    .input('isActive', isAct ? 1 : 0)
                    .input('creditDays', cDays)
                    .query(`
                        INSERT INTO dbo.[Client] ([name], [document], [contactInfo], [address], [mandatoryVariables], [sellerId], [isActive], [creditDays])
                        OUTPUT INSERTED.id
                        VALUES (@name, @document, @contactInfo, @address, @mandatoryVariables, @sellerId, @isActive, @creditDays)
                    `);
                await pool.close();
                const dbClientId = res.recordset[0]?.id;
                const client = { id: dbClientId, name, document, sellerId, isActive: isAct, creditDays: cDays, mandatoryVariables };
                return NextResponse.json({ message: 'Cliente creado', client });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spClienteCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::TEXT, $5::JSONB, $6::INT, $7::INT, $8::BOOLEAN, $9::INT, $10::INT, $11::TEXT)`,
            name || '',
            document || '',
            contactInfo || null,
            address || null,
            mandatoryVariables ? JSON.stringify(mandatoryVariables) : null,
            actingUserId,
            sellerId ? parseInt(sellerId) : null,
            isAct,
            cDays,
            0, // p_client_id
            '' // p_mensaje_resultado
        );

        const dbClientId = results[0]?.p_client_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbClientId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating client');
        }

        const client = { id: dbClientId, name, document, sellerId, isActive: isAct, creditDays: cDays };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'CLIENT', description: `Cliente ${client.name} creado (SP).`, metadata: client });
        });

        return NextResponse.json({ message: 'Cliente creado', client })
    } catch (error: any) {
        console.error('Error creating client:', error);
        return NextResponse.json({ message: 'Error creating client: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, name, document, contactInfo, address, mandatoryVariables, sellerId, isActive, creditDays } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);
        const cDays = parseInt(creditDays) || 0;

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mVarsStr = mandatoryVariables ? JSON.stringify(mandatoryVariables) : null;
                await pool.request()
                    .input('id', parseInt(id))
                    .input('name', name || '')
                    .input('document', document || '')
                    .input('contactInfo', contactInfo || null)
                    .input('address', address || null)
                    .input('mandatoryVariables', mVarsStr)
                    .input('sellerId', sellerId ? parseInt(sellerId) : null)
                    .input('isActive', isAct ? 1 : 0)
                    .input('creditDays', cDays)
                    .query(`
                        UPDATE dbo.[Client]
                        SET [name] = @name, [document] = @document, [contactInfo] = @contactInfo, [address] = @address, [mandatoryVariables] = @mandatoryVariables, [sellerId] = @sellerId, [isActive] = @isActive, [creditDays] = @creditDays
                        WHERE [id] = @id
                    `);
                await pool.close();
                const client = { id, name, document, isActive: isAct, creditDays: cDays, mandatoryVariables };
                return NextResponse.json({ message: 'Cliente actualizado', client });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spClienteActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::TEXT, $6::JSONB, $7::INT, $8::INT, $9::BOOLEAN, $10::INT, $11::TEXT)`,
            parseInt(id),
            name || '',
            document || '',
            contactInfo || null,
            address || null,
            mandatoryVariables ? JSON.stringify(mandatoryVariables) : null,
            actingUserId,
            sellerId ? parseInt(sellerId) : null,
            isAct,
            cDays,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const client = { id, name, document, isActive: isAct, creditDays: cDays };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'CLIENT', description: `Cliente ${client.name} actualizado (SP).`, metadata: client });
        });

        return NextResponse.json({ message: 'Cliente actualizado', client })
    } catch (error: any) {
        console.error('Error updating client:', error);
        return NextResponse.json({ message: 'Error updating client: ' + error.message }, { status: 500 })
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
                    .query('DELETE FROM dbo.[Client] WHERE [id] = @id');
                await pool.close();
                return NextResponse.json({ message: 'Cliente eliminado exitosamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spClienteEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'CLIENT', description: `Cliente con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Cliente eliminado exitosamente' })
    } catch (error: any) {
        console.error('Error deleting client:', error);
        return NextResponse.json({ message: 'Error deleting client: ' + error.message }, { status: 500 })
    }
}
