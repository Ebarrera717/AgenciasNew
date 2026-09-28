import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import mssql from 'mssql'

export const dynamic = 'force-dynamic'

// GET attachments for a quotation
export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: quotationIdStr } = await context.params
        const quotationId = parseInt(quotationIdStr)
        if (isNaN(quotationId)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection()
            const req = pool.request()
            req.input('quotationId', mssql.Int, quotationId)
            const result = await req.query(`
                SELECT id, quotationId, fileName, fileType, fileSize, fileContent, createdAt
                FROM dbo.[Attachment]
                WHERE quotationId = @quotationId
                ORDER BY createdAt DESC
            `)
            await pool.close()

            const attachments = (result.recordset || []).map((att: any) => ({
                id: att.id,
                quotationId: att.quotationId,
                fileName: att.fileName,
                fileType: att.fileType,
                fileSize: att.fileSize,
                createdAt: att.createdAt,
                fileUrl: `data:${att.fileType};base64,${Buffer.from(att.fileContent).toString('base64')}`
            }))
            return NextResponse.json(attachments)
        }

        const attachmentsRaw = await prisma.attachment.findMany({
            where: { quotationId },
            orderBy: { createdAt: 'desc' }
        })
        const attachments = attachmentsRaw.map(att => ({
            ...att,
            fileUrl: `data:${att.fileType};base64,${Buffer.from(att.fileContent).toString('base64')}`
        }))
        return NextResponse.json(attachments)
    } catch (error: any) {
        return NextResponse.json({ message: 'Error fetching attachments', error: error.message }, { status: 500 })
    }
}

// POST new attachment (single or batch)
export async function POST(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: quotationIdStr } = await context.params
        const quotationId = parseInt(quotationIdStr)
        if (isNaN(quotationId)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const body = await request.json()
        const filesToProcess: Array<{ fileName: string; fileType: string; fileSize: number; fileUrl: string }> = 
            Array.isArray(body) ? body : (Array.isArray(body.files) ? body.files : [body])

        if (filesToProcess.length === 0) {
            return NextResponse.json({ message: 'No se recibieron archivos para cargar' }, { status: 400 })
        }

        const userIdHeader = request.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection()
            const transaction = new mssql.Transaction(pool)
            await transaction.begin()

            try {
                const insertedList = []
                for (const item of filesToProcess) {
                    const base64Data = item.fileUrl.includes(';base64,') ? item.fileUrl.split(';base64,').pop() : item.fileUrl
                    if (!base64Data) continue
                    const buffer = Buffer.from(base64Data, 'base64')

                    const req = new mssql.Request(transaction)
                    req.input('quotationId', mssql.Int, quotationId)
                    req.input('fileName', mssql.NVarChar(255), item.fileName)
                    req.input('fileType', mssql.NVarChar(100), item.fileType || 'application/octet-stream')
                    req.input('fileSize', mssql.Int, item.fileSize || buffer.length)
                    req.input('fileContent', mssql.VarBinary(mssql.MAX), buffer)

                    const res = await req.query(`
                        INSERT INTO dbo.[Attachment] (quotationId, fileName, fileType, fileSize, fileContent, createdAt)
                        OUTPUT INSERTED.id, INSERTED.quotationId, INSERTED.fileName, INSERTED.fileType, INSERTED.fileSize, INSERTED.createdAt
                        VALUES (@quotationId, @fileName, @fileType, @fileSize, @fileContent, GETDATE())
                    `)
                    if (res.recordset && res.recordset[0]) {
                        insertedList.push(res.recordset[0])
                    }
                }
                await transaction.commit()
                await pool.close()

                import('@/lib/logger').then(({ logSystemEvent }) => {
                    logSystemEvent({
                        userId: actingUserId,
                        action: 'UPDATE',
                        module: 'QUOTATION',
                        description: `${insertedList.length} adjunto(s) cargado(s) en lote a la cotización ID ${quotationId}.`,
                        metadata: { quotationId, count: insertedList.length }
                    });
                });

                return NextResponse.json({ success: true, count: insertedList.length, attachments: insertedList })
            } catch (txErr) {
                await transaction.rollback()
                await pool.close()
                throw txErr
            }
        }

        const insertedList = []
        for (const item of filesToProcess) {
            const base64Data = item.fileUrl.includes(';base64,') ? item.fileUrl.split(';base64,').pop() : item.fileUrl
            if (!base64Data) continue
            const buffer = Buffer.from(base64Data, 'base64')

            const attachment = await prisma.attachment.create({
                data: {
                    quotationId,
                    fileName: item.fileName,
                    fileType: item.fileType || 'application/octet-stream',
                    fileSize: item.fileSize || buffer.length,
                    fileContent: buffer
                }
            })
            insertedList.push(attachment)
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE',
                module: 'QUOTATION',
                description: `${insertedList.length} adjunto(s) cargado(s) en lote a la cotización ID ${quotationId}.`,
                metadata: { quotationId, count: insertedList.length }
            });
        });

        return NextResponse.json({ success: true, count: insertedList.length, attachments: insertedList })
    } catch (error: any) {
        return NextResponse.json({ message: 'Error uploading attachment(s)', error: error.message }, { status: 500 })
    }
}

// DELETE attachment(s) (single or batch)
export async function DELETE(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: quotationIdStr } = await context.params
        const quotationId = parseInt(quotationIdStr)
        const { searchParams } = new URL(request.url)
        const attachmentIdParam = searchParams.get('attachmentId')
        const attachmentIdsParam = searchParams.get('attachmentIds')

        let idsToDelete: number[] = []

        if (attachmentIdsParam) {
            idsToDelete = attachmentIdsParam.split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n))
        } else if (attachmentIdParam) {
            const singleId = parseInt(attachmentIdParam)
            if (!isNaN(singleId)) idsToDelete.push(singleId)
        } else {
            try {
                const body = await request.json()
                if (Array.isArray(body?.ids)) {
                    idsToDelete = body.ids.map((s: any) => parseInt(s)).filter((n: number) => !isNaN(n))
                } else if (body?.id) {
                    idsToDelete = [parseInt(body.id)]
                }
            } catch (e) {}
        }

        if (idsToDelete.length === 0) {
            return NextResponse.json({ message: 'Faltan IDs de adjuntos a eliminar' }, { status: 400 })
        }

        const userIdHeader = request.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection()
            const req = pool.request()
            req.input('quotationId', mssql.Int, quotationId)
            const idListStr = idsToDelete.map(id => Number(id)).join(',')
            await req.query(`
                DELETE FROM dbo.[Attachment] 
                WHERE quotationId = @quotationId AND id IN (${idListStr})
            `)
            await pool.close()
        } else {
            await prisma.attachment.deleteMany({
                where: {
                    id: { in: idsToDelete },
                    quotationId
                }
            })
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE',
                module: 'QUOTATION',
                description: `${idsToDelete.length} adjunto(s) eliminado(s) de la cotización ID ${quotationId}.`,
                metadata: { quotationId, deletedIds: idsToDelete }
            });
        });

        return NextResponse.json({ message: 'Adjunto(s) eliminado(s) exitosamente', count: idsToDelete.length })
    } catch (error: any) {
        return NextResponse.json({ message: 'Error deleting attachment(s)', error: error.message }, { status: 500 })
    }
}
