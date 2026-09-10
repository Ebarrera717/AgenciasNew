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
                    SELECT dr.[id], dr.[branchId], dr.[implantId], dr.[resolutionNumber], dr.[initialNumber], dr.[finalNumber], dr.[currentNumber],
                           dr.[resolutionDate], dr.[prefix], dr.[expirationDate], dr.[isActive],
                           CASE WHEN dr.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           b.[name] AS branchName, i.[name] AS implantName
                    FROM dbo.[DocumentResolution] dr
                    LEFT JOIN dbo.[Branch] b ON dr.[branchId] = b.[id]
                    LEFT JOIN dbo.[Implant] i ON dr.[implantId] = i.[id]
                    ORDER BY dr.[id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (r: any) => [
                    r.resolutionNumber,
                    r.prefix,
                    r.branchName,
                    r.implantName
                ]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const resolutions = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public."fnDocumentResolutionListar"()`)
        return NextResponse.json(paginateArray(req, resolutions, r => [
            r.resolutionNumber,
            r.prefix,
            r.branchName,
            r.implantName
        ]))
    } catch (error: any) {
        console.error('Error fetching document resolutions:', error)
        return NextResponse.json({ message: 'Error consultando resoluciones de documentos: ' + error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = body.isActive !== undefined ? Boolean(body.isActive) : true;

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('branchId', body.branchId ? parseInt(body.branchId) : null)
                    .input('implantId', body.implantId ? parseInt(body.implantId) : null)
                    .input('resolutionNumber', body.resolutionNumber || '')
                    .input('initialNumber', body.initialNumber ? parseInt(body.initialNumber) : 1)
                    .input('finalNumber', body.finalNumber ? parseInt(body.finalNumber) : 999999)
                    .input('currentNumber', body.initialNumber ? parseInt(body.initialNumber) : 1)
                    .input('resolutionDate', body.resolutionDate ? new Date(body.resolutionDate) : new Date())
                    .input('prefix', body.prefix || null)
                    .input('expirationDate', body.expirationDate ? new Date(body.expirationDate) : null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[DocumentResolution] ([branchId], [implantId], [resolutionNumber], [initialNumber], [finalNumber], [currentNumber], [resolutionDate], [prefix], [expirationDate], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@branchId, @implantId, @resolutionNumber, @initialNumber, @finalNumber, @currentNumber, @resolutionDate, @prefix, @expirationDate, @isActive)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const resolution = { id: dbId, ...body };
                return NextResponse.json(resolution);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        
        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spDocumentResolutionCrear"($1::INT, $2::INT, $3::TEXT, $4::INT, $5::INT, $6::TIMESTAMP, $7::TEXT, $8::TIMESTAMP, $9::BOOLEAN, $10::INT, $11::INT, $12::TEXT)`,
            body.branchId ? parseInt(body.branchId) : null,
            body.implantId ? parseInt(body.implantId) : null,
            body.resolutionNumber,
            body.initialNumber ? parseInt(body.initialNumber) : 1,
            body.finalNumber ? parseInt(body.finalNumber) : 999999,
            body.resolutionDate ? new Date(body.resolutionDate) : new Date(),
            body.prefix || null,
            body.expirationDate ? new Date(body.expirationDate) : null,
            isAct,
            actingUserId,
            0, // p_resolution_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_resolution_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error al crear resolución de documento');
        }

        const resolution = { id: dbId, ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Resolución ${resolution.resolutionNumber} creada (SP).`, metadata: resolution });
        });

        return NextResponse.json(resolution)
    } catch (error: any) {
        console.error('Error creating document resolution:', error);
        return NextResponse.json({ message: 'Error al crear resolución: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const isAct = body.isActive !== undefined ? Boolean(body.isActive) : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(body.id))
                    .input('branchId', body.branchId ? parseInt(body.branchId) : null)
                    .input('implantId', body.implantId ? parseInt(body.implantId) : null)
                    .input('resolutionNumber', body.resolutionNumber || '')
                    .input('initialNumber', body.initialNumber ? parseInt(body.initialNumber) : 1)
                    .input('finalNumber', body.finalNumber ? parseInt(body.finalNumber) : 999999)
                    .input('currentNumber', body.currentNumber ? parseInt(body.currentNumber) : 1)
                    .input('resolutionDate', body.resolutionDate ? new Date(body.resolutionDate) : null)
                    .input('prefix', body.prefix || null)
                    .input('expirationDate', body.expirationDate ? new Date(body.expirationDate) : null)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[DocumentResolution]
                        SET [branchId] = @branchId, [implantId] = @implantId, [resolutionNumber] = @resolutionNumber,
                            [initialNumber] = @initialNumber, [finalNumber] = @finalNumber, [currentNumber] = @currentNumber,
                            [resolutionDate] = @resolutionDate, [prefix] = @prefix, [expirationDate] = @expirationDate, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const resolution = { ...body };
                return NextResponse.json(resolution);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spDocumentResolutionActualizar"($1::INT, $2::INT, $3::INT, $4::TEXT, $5::INT, $6::INT, $7::INT, $8::TIMESTAMP, $9::TEXT, $10::TIMESTAMP, $11::BOOLEAN, $12::INT, $13::TEXT)`,
            parseInt(body.id),
            body.branchId ? parseInt(body.branchId) : null,
            body.implantId ? parseInt(body.implantId) : null,
            body.resolutionNumber,
            body.initialNumber ? parseInt(body.initialNumber) : 1,
            body.finalNumber ? parseInt(body.finalNumber) : 999999,
            body.currentNumber ? parseInt(body.currentNumber) : 1,
            body.resolutionDate ? new Date(body.resolutionDate) : null,
            body.prefix || null,
            body.expirationDate ? new Date(body.expirationDate) : null,
            isAct,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const resolution = { ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Resolución ${resolution.resolutionNumber} actualizada (SP).`, metadata: resolution });
        });

        return NextResponse.json(resolution)
    } catch (error: any) {
        console.error('Error updating document resolution:', error);
        return NextResponse.json({ message: 'Error al actualizar resolución: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        if (!id) return NextResponse.json({ message: 'ID de resolución obligatorio' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[DocumentResolution] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Resolución eliminada exitosamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spDocumentResolutionEliminar"($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Resolución con ID ${id} eliminada (SP).` });
        });

        return NextResponse.json({ message: 'Resolución eliminada exitosamente' })
    } catch (error: any) {
        console.error('Error deleting document resolution:', error);
        return NextResponse.json({ message: 'Error al eliminar resolución: ' + error.message }, { status: 500 })
    }
}
