import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { logSystemEvent } from '@/lib/logger'

export const dynamic = 'force-dynamic'

function serializeConsecutivo(row: any) {
    return {
        ...row,
        consecutivo: row.consecutivo !== null && row.consecutivo !== undefined ? String(row.consecutivo) : '0',
    }
}

export async function GET() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT [id], [codigo], [nombre], [branchId], [implantId], [fuente], [serie], [consecutivo]
                    FROM dbo.[SysConsecutivo]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                const sanitized = res.recordset.map(serializeConsecutivo);
                return NextResponse.json(sanitized);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const rows = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnSysConsecutivoListar()`)
        const sanitized = rows.map(serializeConsecutivo)
        return NextResponse.json(sanitized)
    } catch (error: any) {
        console.error('Error fetching sysconsecutivos:', error)
        return NextResponse.json({ message: 'Error al obtener consecutivos: ' + error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const branchId = body.branchId ? parseInt(body.branchId) : null
        const implantId = body.implantId ? parseInt(body.implantId) : null

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('codigo', body.codigo || '')
                    .input('nombre', body.nombre || '')
                    .input('branchId', branchId)
                    .input('implantId', implantId)
                    .input('fuente', body.fuente || null)
                    .input('serie', body.serie || null)
                    .input('consecutivo', body.consecutivo ? parseInt(body.consecutivo) : 0)
                    .query(`
                        INSERT INTO dbo.[SysConsecutivo] ([codigo], [nombre], [branchId], [implantId], [fuente], [serie], [consecutivo])
                        OUTPUT INSERTED.id
                        VALUES (@codigo, @nombre, @branchId, @implantId, @fuente, @serie, @consecutivo)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const sysConsecutivo = { id: dbId, ...body };
                return NextResponse.json(serializeConsecutivo(sysConsecutivo));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const consecutivoVal = body.consecutivo ? BigInt(body.consecutivo) : BigInt(0)

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spSysConsecutivoCrear($1::VARCHAR, $2::VARCHAR, $3::INT, $4::INT, $5::VARCHAR, $6::VARCHAR, $7::BIGINT, $8::INT, $9::INT, $10::TEXT)`,
            body.codigo,
            body.nombre,
            branchId,
            implantId,
            body.fuente || null,
            body.serie || null,
            consecutivoVal,
            actingUserId,
            0,
            ''
        )

        const dbId = results[0]?.p_id
        const message = results[0]?.p_mensaje_resultado || ''

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creando consecutivo')
        }

        const sysConsecutivo = { id: dbId, ...body }
        logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Consecutivo ${sysConsecutivo.nombre} (${sysConsecutivo.codigo}) creado (SP).`, metadata: sysConsecutivo })

        return NextResponse.json(serializeConsecutivo(sysConsecutivo))
    } catch (error: any) {
        console.error('Error creating sysconsecutivo:', error)
        return NextResponse.json({ message: 'Error al crear consecutivo: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const id = parseInt(body.id)
        const branchId = body.branchId ? parseInt(body.branchId) : null
        const implantId = body.implantId ? parseInt(body.implantId) : null

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', id)
                    .input('codigo', body.codigo || '')
                    .input('nombre', body.nombre || '')
                    .input('branchId', branchId)
                    .input('implantId', implantId)
                    .input('fuente', body.fuente || null)
                    .input('serie', body.serie || null)
                    .input('consecutivo', body.consecutivo ? parseInt(body.consecutivo) : 0)
                    .query(`
                        UPDATE dbo.[SysConsecutivo]
                        SET [codigo] = @codigo, [nombre] = @nombre, [branchId] = @branchId, [implantId] = @implantId,
                            [fuente] = @fuente, [serie] = @serie, [consecutivo] = @consecutivo
                        WHERE [id] = @id
                    `);
                await pool.close();
                return NextResponse.json(serializeConsecutivo(body));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const consecutivoVal = body.consecutivo ? BigInt(body.consecutivo) : BigInt(0)

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spSysConsecutivoActualizar($1::INT, $2::VARCHAR, $3::VARCHAR, $4::INT, $5::INT, $6::VARCHAR, $7::VARCHAR, $8::BIGINT, $9::INT, $10::TEXT)`,
            id,
            body.codigo,
            body.nombre,
            branchId,
            implantId,
            body.fuente || null,
            body.serie || null,
            consecutivoVal,
            actingUserId,
            ''
        )

        const message = results[0]?.p_mensaje_resultado || ''
        if (message.startsWith('ERROR')) {
            throw new Error(message)
        }

        logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Consecutivo ${body.nombre} (${body.codigo}) actualizado (SP).`, metadata: body })

        return NextResponse.json(serializeConsecutivo(body))
    } catch (error: any) {
        console.error('Error updating sysconsecutivo:', error)
        return NextResponse.json({ message: 'Error al actualizar consecutivo: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        if (!id) {
            return NextResponse.json({ message: 'ID es requerido' }, { status: 400 })
        }

        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[SysConsecutivo] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true, message: 'Consecutivo eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spSysConsecutivoEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            ''
        )

        const message = results[0]?.p_mensaje_resultado || ''
        if (message.startsWith('ERROR')) {
            throw new Error(message)
        }

        logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Consecutivo con ID ${id} eliminado (SP).` })

        return NextResponse.json({ success: true, message })
    } catch (error: any) {
        console.error('Error deleting sysconsecutivo:', error)
        return NextResponse.json({ message: 'Error al eliminar consecutivo: ' + error.message }, { status: 500 })
    }
}
