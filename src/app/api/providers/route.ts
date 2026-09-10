import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const includeInactive = searchParams.get('includeInactive') === 'true'

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spProviderListar');
                await pool.close();
                let providers: any[] = (res.recordset as any[]) || [];
                if (!includeInactive) {
                    providers = providers.filter((p: any) => p.isActive !== false && p.isActive !== 0);
                }
                return NextResponse.json(paginateArray(req, providers, (p: any) => [p.code, p.name, p.sigla, p.airlineCode]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public.fnProveedorListar()`
        );
        let providers = results.map(row => row.fnproveedorlistar);
        if (!includeInactive) {
            providers = providers.filter(p => p.isActive !== false);
        }
        return NextResponse.json(paginateArray(req, providers, p => [p.code, p.name, p.sigla, p.airlineCode]))
    } catch (error) {
        return NextResponse.json({ message: 'Error retrieving providers' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, name, contactInfo, commissionConfig, providerTypeId, airlineCode, sigla, isActive } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', code || null)
                    .input('name', name || '')
                    .input('contactInfo', contactInfo || null)
                    .input('providerTypeId', providerTypeId ? parseInt(providerTypeId) : null)
                    .input('airlineCode', airlineCode || null)
                    .input('sigla', sigla || null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[Provider] ([code], [name], [contactInfo], [providerTypeId], [airlineCode], [sigla], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @contactInfo, @providerTypeId, @airlineCode, @sigla, @isActive)
                    `);
                await pool.close();
                const provider = { id: res.recordset[0]?.id, name };
                return NextResponse.json({ message: 'Proveedor creado', provider });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spProveedorCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::JSONB, $5::INT, $6::TEXT, $7::TEXT, $8::BOOLEAN, $9::INT, $10::INT, $11::TEXT)`,
            code || null,
            name,
            contactInfo || null,
            JSON.stringify(commissionConfig || {}),
            providerTypeId ? parseInt(providerTypeId) : null,
            airlineCode || null,
            sigla || null,
            isAct,
            actingUserId,
            0, // p_provider_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_provider_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating provider');
        }

        const provider = { id: dbId, name };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'PROVIDER', description: `Proveedor ${provider.name} creado (SP).`, metadata: provider });
        });

        return NextResponse.json({ message: 'Proveedor creado', provider })
    } catch (error: any) {
        console.error('Error creating provider:', error);
        return NextResponse.json({ message: 'Error creating provider: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, code, name, contactInfo, commissionConfig, providerTypeId, airlineCode, sigla, isActive } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = isActive !== undefined ? isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code || null)
                    .input('name', name || '')
                    .input('contactInfo', contactInfo || null)
                    .input('providerTypeId', providerTypeId ? parseInt(providerTypeId) : null)
                    .input('airlineCode', airlineCode || null)
                    .input('sigla', sigla || null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[Provider]
                        SET [code] = @code, [name] = @name, [contactInfo] = @contactInfo, [providerTypeId] = @providerTypeId, [airlineCode] = @airlineCode, [sigla] = @sigla, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const provider = { id, name };
                return NextResponse.json({ message: 'Proveedor actualizado', provider });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spProveedorActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::JSONB, $6::INT, $7::TEXT, $8::TEXT, $9::BOOLEAN, $10::INT, $11::TEXT)`,
            parseInt(id),
            code || null,
            name,
            contactInfo || null,
            JSON.stringify(commissionConfig || {}),
            providerTypeId ? parseInt(providerTypeId) : null,
            airlineCode || null,
            sigla || null,
            isAct,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const provider = { id, name };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'PROVIDER', description: `Proveedor ${provider.name} actualizado (SP).`, metadata: provider });
        });

        return NextResponse.json({ message: 'Proveedor actualizado', provider })
    } catch (error: any) {
        console.error('Error updating provider:', error);
        return NextResponse.json({ message: 'Error updating provider: ' + error.message }, { status: 500 })
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
                    .query('DELETE FROM dbo.[Provider] WHERE [id] = @id');
                await pool.close();
                return NextResponse.json({ message: 'Proveedor eliminado exitosamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spProveedorEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'PROVIDER', description: `Proveedor con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Proveedor eliminado exitosamente' })
    } catch (error: any) {
        console.error('Error deleting provider:', error);
        return NextResponse.json({ message: 'Error deleting provider: ' + error.message }, { status: 500 })
    }
}
