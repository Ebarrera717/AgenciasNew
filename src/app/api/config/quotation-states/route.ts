import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

async function ensureDefaultStates() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const countRes = await pool.request().query('SELECT COUNT(*) AS total FROM dbo.[QuotationState]');
                if ((countRes.recordset[0]?.total || 0) === 0) {
                    await pool.request().query(`
                        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = 'NUEVO')
                            INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive]) VALUES ('NUEVO', 'Nuevo', 'blue', 1);
                        IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = 'ENVIADO')
                            INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive]) VALUES ('ENVIADO', 'ENVIADO', 'emerald', 1);
                    `);
                }
                await pool.close();
            } catch (err) {
                if (pool) await pool.close();
                console.error("Failed to seed default quotation states in SQL Server", err);
            }
            return;
        }

        // PostgreSQL: Asegurar secuencia y columnas preventivamente
        try {
            await (prisma as any).$executeRawUnsafe(`
                CREATE SEQUENCE IF NOT EXISTS public."QuotationState_id_seq" START WITH 1;
                ALTER TABLE public."QuotationState" ADD COLUMN IF NOT EXISTS "isActive" boolean DEFAULT true NOT NULL;
                ALTER TABLE public."QuotationState" ALTER COLUMN id SET DEFAULT nextval('public."QuotationState_id_seq"'::regclass);
                SELECT setval('public."QuotationState_id_seq"', GREATEST(COALESCE((SELECT MAX(id) FROM public."QuotationState"), 0) + 1, 1), false);
            `);
        } catch (e) {
            // Continuar
        }

        const count = await (prisma as any).quotationState.count();
        if (count === 0) {
            await (prisma as any).quotationState.createMany({
                data: [
                    { code: 'NUEVO', name: 'Nuevo', color: 'blue', isActive: true },
                    { code: 'ENVIADO', name: 'ENVIADO', color: 'emerald', isActive: true }
                ]
            });
            await (prisma as any).$executeRawUnsafe(`
                SELECT setval('public."QuotationState_id_seq"', GREATEST(COALESCE((SELECT MAX(id) FROM public."QuotationState"), 0) + 1, 1), false);
            `).catch(() => {});
        }
    } catch (e) {
        console.error("Failed to seed default quotation states", e);
    }
}

export async function GET(req: NextRequest) {
    try {
        await ensureDefaultStates();

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT [id], [code], [name], [color], [isActive], [createdAt]
                    FROM dbo.[QuotationState]
                    ORDER BY [id] ASC
                `);
                await pool.close();
                const states = res.recordset || [];
                return NextResponse.json(paginateArray(req, states, (q: any) => [q.name, q.code]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results = await (prisma as any).quotationState.findMany({
            orderBy: { id: 'asc' }
        });
        return NextResponse.json(paginateArray(req, results, (q: any) => [q.name, q.code]))
    } catch (error: any) {
        return NextResponse.json({ message: 'Error retrieving quotation states: ' + error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, name, color } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isActive = body.isActive !== undefined ? Boolean(body.isActive) : true

        if (!code || code.trim() === '') {
            return NextResponse.json({ message: 'El código es obligatorio' }, { status: 400 })
        }
        if (!name || name.trim() === '') {
            return NextResponse.json({ message: 'El nombre es obligatorio' }, { status: 400 })
        }

        const cleanCode = code.trim().toUpperCase()
        const cleanName = name.trim()
        const cleanColor = color || 'blue'

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mssql = await import('mssql');
                const reqSql = pool.request()
                    .input('p_code', mssql.NVarChar(50), cleanCode)
                    .input('p_name', mssql.NVarChar(100), cleanName)
                    .input('p_color', mssql.NVarChar(50), cleanColor)
                    .input('p_isActive', mssql.Bit, isActive ? 1 : 0)
                    .input('p_acting_user_id', mssql.Int, actingUserId)
                    .output('p_id', mssql.Int)
                    .output('p_mensaje_resultado', mssql.NVarChar(mssql.MAX));

                const spRes = await reqSql.execute('dbo.spQuotationStateCrear');
                await pool.close();

                const mensaje = spRes.output?.p_mensaje_resultado || '';
                const newId = spRes.output?.p_id;

                if (!mensaje.startsWith('SUCCESS')) {
                    return NextResponse.json({ message: mensaje.replace(/^ERROR:\s*/, '') }, { status: 400 });
                }

                const state = { id: newId, code: cleanCode, name: cleanName, color: cleanColor, isActive };

                const { logSystemEvent } = await import('@/lib/logger');
                logSystemEvent({ 
                    userId: actingUserId, 
                    action: 'CREATE', 
                    module: 'QUOTATION_STATE', 
                    description: `Estado de cotización ${cleanName} (${cleanCode}) creado en SQL Server.`, 
                    metadata: state 
                });

                return NextResponse.json({ message: 'Estado creado', state });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        // Modo PostgreSQL
        const syncSequence = async () => {
            try {
                await (prisma as any).$executeRawUnsafe(`
                    CREATE SEQUENCE IF NOT EXISTS public."QuotationState_id_seq" START WITH 1;
                    ALTER SEQUENCE public."QuotationState_id_seq" OWNED BY public."QuotationState".id;
                    ALTER TABLE public."QuotationState" ALTER COLUMN id SET DEFAULT nextval('public."QuotationState_id_seq"'::regclass);
                    SELECT setval('public."QuotationState_id_seq"', GREATEST(COALESCE((SELECT MAX(id) FROM public."QuotationState"), 0) + 1, 1), false);
                `);
            } catch (seqErr) {
                console.warn('Advertencia al sincronizar secuencia QuotationState_id_seq:', seqErr);
            }
        };

        // Sincronizar preventivamente antes de crear
        await syncSequence();

        let state: any;
        try {
            state = await (prisma as any).quotationState.create({
                data: {
                    code: cleanCode,
                    name: cleanName,
                    color: cleanColor,
                    isActive
                }
            });
        } catch (createError: any) {
            // Si ocurrió un error de colisión de ID por secuencia desfasada (P2002 sobre id)
            if (createError?.message?.includes('id') || (createError?.code === 'P2002' && !createError?.meta?.target?.includes('code'))) {
                console.warn('Re-sincronizando secuencia tras colisión de ID en QuotationState y reintentando...');
                await syncSequence();
                state = await (prisma as any).quotationState.create({
                    data: {
                        code: cleanCode,
                        name: cleanName,
                        color: cleanColor,
                        isActive
                    }
                });
            } else {
                throw createError;
            }
        }

        const { logSystemEvent } = await import('@/lib/logger');
        logSystemEvent({ 
            userId: actingUserId, 
            action: 'CREATE', 
            module: 'QUOTATION_STATE', 
            description: `Estado de cotización ${state.name} (${state.code}) creado.`, 
            metadata: state 
        });

        return NextResponse.json({ message: 'Estado creado', state })
    } catch (error: any) {
        console.error('Error creating quotation state:', error);
        if (error.code === 'P2002' && error?.meta?.target?.includes('code')) {
            return NextResponse.json({ message: 'El código ya existe' }, { status: 400 });
        }
        return NextResponse.json({ message: 'Error al crear estado: ' + (error.message || error) }, { status: 400 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, code, name, color } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (!id) return NextResponse.json({ message: 'Missing ID' }, { status: 400 })
        if (!code || code.trim() === '') {
            return NextResponse.json({ message: 'El código es obligatorio' }, { status: 400 })
        }
        if (!name || name.trim() === '') {
            return NextResponse.json({ message: 'El nombre es obligatorio' }, { status: 400 })
        }

        const isAct = body.isActive !== undefined ? Boolean(body.isActive) : (body.inactive !== undefined ? !body.inactive : undefined);
        const cleanCode = code.trim().toUpperCase()
        const cleanName = name.trim()
        const cleanColor = color || 'blue'

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mssql = await import('mssql');
                const reqSql = pool.request()
                    .input('p_id', mssql.Int, parseInt(id))
                    .input('p_code', mssql.NVarChar(50), cleanCode)
                    .input('p_name', mssql.NVarChar(100), cleanName)
                    .input('p_color', mssql.NVarChar(50), cleanColor)
                    .input('p_isActive', mssql.Bit, isAct !== undefined ? (isAct ? 1 : 0) : null)
                    .input('p_acting_user_id', mssql.Int, actingUserId)
                    .output('p_mensaje_resultado', mssql.NVarChar(mssql.MAX));

                const spRes = await reqSql.execute('dbo.spQuotationStateActualizar');
                await pool.close();

                const mensaje = spRes.output?.p_mensaje_resultado || '';
                if (!mensaje.startsWith('SUCCESS')) {
                    return NextResponse.json({ message: mensaje.replace(/^ERROR:\s*/, '') }, { status: 400 });
                }

                const state = { id: parseInt(id), code: cleanCode, name: cleanName, color: cleanColor, isActive: isAct };

                const { logSystemEvent } = await import('@/lib/logger');
                logSystemEvent({ 
                    userId: actingUserId, 
                    action: 'UPDATE', 
                    module: 'QUOTATION_STATE', 
                    description: `Estado de cotización ${cleanName} (${cleanCode}) actualizado en SQL Server.`, 
                    metadata: state 
                });

                return NextResponse.json({ message: 'Estado actualizado', state });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const state = await (prisma as any).quotationState.update({
            where: { id: parseInt(id) },
            data: {
                code: cleanCode,
                name: cleanName,
                color: cleanColor,
                isActive: isAct
            }
        });

        const { logSystemEvent } = await import('@/lib/logger');
        logSystemEvent({ 
            userId: actingUserId, 
            action: 'UPDATE', 
            module: 'QUOTATION_STATE', 
            description: `Estado de cotización ${state.name} (${state.code}) actualizado.`, 
            metadata: state 
        });

        return NextResponse.json({ message: 'Estado actualizado', state })
    } catch (error: any) {
        console.error('Error updating quotation state:', error);
        if (error.code === 'P2002' && error?.meta?.target?.includes('code')) {
            return NextResponse.json({ message: 'El código ya existe' }, { status: 400 });
        }
        return NextResponse.json({ message: 'Error al actualizar estado: ' + (error.message || error) }, { status: 400 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const url = new URL(req.url)
        const id = url.searchParams.get('id')
        if (!id) return NextResponse.json({ message: 'Missing ID' }, { status: 400 })
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mssql = await import('mssql');
                const reqSql = pool.request()
                    .input('p_id', mssql.Int, parseInt(id))
                    .input('p_acting_user_id', mssql.Int, actingUserId)
                    .output('p_mensaje_resultado', mssql.NVarChar(mssql.MAX));

                const spRes = await reqSql.execute('dbo.spQuotationStateEliminar');
                await pool.close();

                const mensaje = spRes.output?.p_mensaje_resultado || '';
                if (!mensaje.startsWith('SUCCESS')) {
                    return NextResponse.json({ message: mensaje.replace(/^ERROR:\s*/, '') }, { status: 400 });
                }

                const { logSystemEvent } = await import('@/lib/logger');
                logSystemEvent({ 
                    userId: actingUserId, 
                    action: 'DELETE', 
                    module: 'QUOTATION_STATE', 
                    description: `Estado de cotización con ID ${id} eliminado en SQL Server.` 
                });

                return NextResponse.json({ message: 'Estado eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const deletedState = await (prisma as any).quotationState.delete({
            where: { id: parseInt(id) }
        });

        const { logSystemEvent } = await import('@/lib/logger');
        logSystemEvent({ 
            userId: actingUserId, 
            action: 'DELETE', 
            module: 'QUOTATION_STATE', 
            description: `Estado de cotización con ID ${id} (${deletedState.name}) eliminado.` 
        });

        return NextResponse.json({ message: 'Estado eliminado' })
    } catch (error: any) {
        console.error('Error deleting quotation state:', error);
        return NextResponse.json({ message: 'Error al eliminar estado: ' + error.message }, { status: 500 })
    }
}
