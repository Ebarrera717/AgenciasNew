import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { getCellCustomizationConfig, syncCellCustomization } from '@/lib/cell-customization'
import { generateHtmlTemplate } from '@/lib/excel-to-html'
import { logSystemEvent } from '@/lib/logger'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT i.[id], i.[code], i.[name], i.[branchId], i.[resolutionId], i.[isActive],
                           CASE WHEN i.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           b.[id] AS b_id, b.[code] AS b_code, b.[name] AS b_name
                    FROM dbo.[Implant] i
                    LEFT JOIN dbo.[Branch] b ON i.[branchId] = b.[id]
                    ORDER BY i.[id] DESC
                `);
                await pool.close();
                const implantsWithData = res.recordset.map((i: any) => ({
                    ...i,
                    logo: null,
                    hasTemplate: false,
                    hasInvoiceTemplate: false,
                    branch: i.b_id ? { id: i.b_id, code: i.b_code, name: i.b_name } : null
                }));
                return NextResponse.json(paginateArray(req, implantsWithData, (i: any) => [i.code, i.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const implants = await prisma.$queryRawUnsafe<any[]>(
            `SELECT i.*, 
                    json_build_object('id', b.id, 'code', b.code, 'name', b.name) as branch
             FROM public.fnImplantListar() i
             LEFT JOIN public."Branch" b ON i."branchId" = b.id`
        )
        
        const implantsWithData = await Promise.all(implants.map(async i => {
            const physicalConfig = await getCellCustomizationConfig(null, i.id)
            return {
                ...i,
                logo: i.logo ? `data:image/png;base64,${Buffer.from(i.logo).toString('base64')}` : null,
                template: undefined,
                hasTemplate: !!i.template,
                templateConfig: physicalConfig || i.templateConfig,
                invoiceTemplate: undefined,
                hasInvoiceTemplate: !!i.invoiceTemplate,
                invoiceTemplateConfig: i.invoiceTemplateConfig,
                resolutionId: i.resolutionId,
                branch: i.branch && i.branch.id ? i.branch : null
            }
        }))
        
        return NextResponse.json(paginateArray(req, implantsWithData, i => [i.code, i.name]))
    } catch (error: any) {
        console.error('Error in implants GET', error)
        return NextResponse.json({ message: 'Error fetching implants', detail: error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        const resolutionId = body.resolutionId ? parseInt(body.resolutionId) : null;
        const branchId = body.branchId ? parseInt(body.branchId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('branchId', branchId)
                    .input('resolutionId', resolutionId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[Implant] ([code], [name], [branchId], [resolutionId], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @branchId, @resolutionId, @isActive)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const implant = { id: dbId, ...body };
                return NextResponse.json(implant);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        let logoBuffer = null;
        if (body.logo) {
            const base64Data = body.logo.replace(/^data:image\/\w+;base64,/, "");
            logoBuffer = Buffer.from(base64Data, 'base64');
        }

        let templateBuffer = null;
        if (body.template) {
            const cleanBase64 = body.template.split(';base64,').pop() || body.template;
            templateBuffer = Buffer.from(cleanBase64, 'base64');
        }

        let invoiceTemplateBuffer = null;
        if (body.invoiceTemplate) {
            const cleanBase64 = body.invoiceTemplate.split(';base64,').pop() || body.invoiceTemplate;
            invoiceTemplateBuffer = Buffer.from(cleanBase64, 'base64');
        }

        let htmlTemplate = null;
        if (templateBuffer) {
            try {
                htmlTemplate = await generateHtmlTemplate(templateBuffer, body.templateConfig, logoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating HTML template during implant creation:", htmlErr);
            }
        }

        let invoiceHtmlTemplate = null;
        if (invoiceTemplateBuffer) {
            try {
                invoiceHtmlTemplate = await generateHtmlTemplate(invoiceTemplateBuffer, body.invoiceTemplateConfig, logoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating invoice HTML template during implant creation:", htmlErr);
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImplantCrear($1::TEXT, $2::TEXT, $3::BYTEA, $4::BYTEA, $5::JSONB, $6::TEXT, $7::INT, $8::INT, $9::BYTEA, $10::JSONB, $11::TEXT, $12::BOOLEAN, $13::INT, $14::INT, $15::TEXT)`,
            body.code,
            body.name,
            logoBuffer,
            templateBuffer,
            body.templateConfig ? body.templateConfig : null,
            htmlTemplate,
            branchId,
            resolutionId,
            invoiceTemplateBuffer,
            body.invoiceTemplateConfig ? body.invoiceTemplateConfig : null,
            invoiceHtmlTemplate,
            isAct,
            actingUserId,
            0,
            ''
        );

        const dbId = results[0]?.p_implant_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating implant');
        }

        if (body.templateConfig) {
            await syncCellCustomization(null, dbId, body.templateConfig);
        }

        const implant = { id: dbId, ...body };

        logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Implant ${implant.name} creado (SP).`, metadata: implant });

        return NextResponse.json(implant)
    } catch (error: any) {
        console.error('Error creating implant:', error);
        return NextResponse.json({ message: 'Error al crear implant: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const dbId = parseInt(body.id);
        const resolutionId = body.resolutionId ? parseInt(body.resolutionId) : null;
        const branchId = body.branchId ? parseInt(body.branchId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', dbId)
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('branchId', branchId)
                    .input('resolutionId', resolutionId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[Implant]
                        SET [code] = @code, [name] = @name, [branchId] = @branchId, [resolutionId] = @resolutionId, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const implant = { ...body };
                return NextResponse.json(implant);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        
        let logoBuffer = null;
        if (body.logo) {
            const base64Data = body.logo.replace(/^data:image\/\w+;base64,/, "");
            logoBuffer = Buffer.from(base64Data, 'base64');
        }

        let templateBuffer = null;
        if (body.template) {
            const cleanBase64 = body.template.split(';base64,').pop() || body.template;
            templateBuffer = Buffer.from(cleanBase64, 'base64');
        }

        let invoiceTemplateBuffer = null;
        if (body.invoiceTemplate) {
            const cleanBase64 = body.invoiceTemplate.split(';base64,').pop() || body.invoiceTemplate;
            invoiceTemplateBuffer = Buffer.from(cleanBase64, 'base64');
        }

        let finalLogoBuffer = logoBuffer;
        let finalTemplateBuffer = templateBuffer;
        let finalInvoiceTemplateBuffer = invoiceTemplateBuffer;
        
        if (body.clearTemplate) {
            await prisma.implant.update({
                where: { id: dbId },
                data: { template: null, htmlTemplate: null }
            });
            finalTemplateBuffer = null;
        } else if (!finalTemplateBuffer || !finalLogoBuffer || !finalInvoiceTemplateBuffer) {
            const current: any = await prisma.implant.findUnique({
                where: { id: dbId },
                select: { template: true, logo: true, invoiceTemplate: true } as any
            });
            if (!finalTemplateBuffer && current?.template) {
                finalTemplateBuffer = Buffer.from(current.template);
            }
            if (!finalLogoBuffer && current?.logo) {
                finalLogoBuffer = Buffer.from(current.logo);
            }
            if (!finalInvoiceTemplateBuffer && current?.invoiceTemplate) {
                finalInvoiceTemplateBuffer = Buffer.from(current.invoiceTemplate);
            }
        }

        let htmlTemplate = null;
        if (finalTemplateBuffer) {
            try {
                htmlTemplate = await generateHtmlTemplate(finalTemplateBuffer, body.templateConfig, finalLogoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating/updating HTML template during implant update:", htmlErr);
            }
        }

        let invoiceHtmlTemplate = null;
        if (finalInvoiceTemplateBuffer) {
            try {
                invoiceHtmlTemplate = await generateHtmlTemplate(finalInvoiceTemplateBuffer, body.invoiceTemplateConfig, finalLogoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating/updating invoice HTML template during implant update:", htmlErr);
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImplantActualizar($1::INT, $2::TEXT, $3::TEXT, $4::BYTEA, $5::BYTEA, $6::JSONB, $7::TEXT, $8::INT, $9::INT, $10::BYTEA, $11::JSONB, $12::TEXT, $13::BOOLEAN, $14::INT, $15::TEXT)`,
            dbId,
            body.code,
            body.name,
            logoBuffer,
            templateBuffer,
            body.templateConfig ? body.templateConfig : null,
            htmlTemplate,
            branchId,
            resolutionId,
            invoiceTemplateBuffer,
            body.invoiceTemplateConfig ? body.invoiceTemplateConfig : null,
            invoiceHtmlTemplate,
            isAct,
            actingUserId,
            ''
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        if (body.templateConfig) {
            await syncCellCustomization(null, dbId, body.templateConfig);
        }

        const implant = { ...body };

        logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Implant ${implant.name} actualizado (SP).`, metadata: implant });

        return NextResponse.json(implant)
    } catch (error: any) {
        console.error('Error updating implant:', error);
        return NextResponse.json({ message: 'Error al actualizar implant: ' + error.message }, { status: 500 })
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
                    .query(`DELETE FROM dbo.[Implant] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Implant deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImplantEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            ''
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Implant con ID ${id} eliminado (SP).` });

        return NextResponse.json({ message: 'Implant deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting implant:', error);
        return NextResponse.json({ message: 'Error al eliminar implant: ' + error.message }, { status: 500 })
    }
}
