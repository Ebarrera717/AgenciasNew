import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { getCellCustomizationConfig, syncCellCustomization } from '@/lib/cell-customization'
import { generateHtmlTemplate } from '@/lib/excel-to-html'
import { logSystemEvent } from '@/lib/logger'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().execute('dbo.spBranchListar');
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset || [], (b: any) => [b.code, b.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const branches = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnBranchListar()`)
        
        const branchesWithData = await Promise.all(branches.map(async b => {
            const physicalConfig = await getCellCustomizationConfig(b.id, null)
            return {
                ...b,
                logo: b.logo ? `data:image/png;base64,${Buffer.from(b.logo).toString('base64')}` : null,
                template: undefined,
                hasTemplate: !!b.template,
                templateConfig: physicalConfig || b.templateConfig,
                invoiceTemplate: undefined,
                hasInvoiceTemplate: !!b.invoiceTemplate,
                invoiceTemplateConfig: b.invoiceTemplateConfig,
                resolutionId: b.resolutionId
            }
        }))
        
        return NextResponse.json(paginateArray(req, branchesWithData, b => [b.code, b.name]))
    } catch (error) {
        return NextResponse.json({ message: 'Error fetching branches' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const resolutionId = body.resolutionId ? parseInt(body.resolutionId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('resolutionId', resolutionId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[Branch] ([code], [name], [resolutionId], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @resolutionId, @isActive)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const branch = { id: dbId, ...body };
                logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Sucursal ${branch.name} creada.`, metadata: branch });
                return NextResponse.json(branch);
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
                console.error("Error generating HTML template during branch creation:", htmlErr);
            }
        }

        let invoiceHtmlTemplate = null;
        if (invoiceTemplateBuffer) {
            try {
                invoiceHtmlTemplate = await generateHtmlTemplate(invoiceTemplateBuffer, body.invoiceTemplateConfig, logoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating invoice HTML template during branch creation:", htmlErr);
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spBranchCrear($1::TEXT, $2::TEXT, $3::BYTEA, $4::BYTEA, $5::JSONB, $6::TEXT, $7::INT, $8::BYTEA, $9::JSONB, $10::TEXT, $11::BOOLEAN, $12::INT, $13::INT, $14::TEXT)`,
            body.code,
            body.name,
            logoBuffer,
            templateBuffer,
            body.templateConfig ? body.templateConfig : null,
            htmlTemplate,
            resolutionId,
            invoiceTemplateBuffer,
            body.invoiceTemplateConfig ? body.invoiceTemplateConfig : null,
            invoiceHtmlTemplate,
            isAct,
            actingUserId,
            0,
            ''
        );

        const dbId = results[0]?.p_branch_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating branch');
        }

        if (body.templateConfig) {
            await syncCellCustomization(dbId, null, body.templateConfig);
        }

        const branch = { id: dbId, ...body };

        logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Sucursal ${branch.name} creada (SP).`, metadata: branch });

        return NextResponse.json(branch)
    } catch (error: any) {
        console.error('Error creating branch:', error);
        return NextResponse.json({ message: 'Error al crear sucursal: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        const dbId = parseInt(body.id);
        const resolutionId = body.resolutionId ? parseInt(body.resolutionId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', dbId)
                    .input('code', body.code || '')
                    .input('name', body.name || '')
                    .input('resolutionId', resolutionId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[Branch]
                        SET [code] = @code, [name] = @name, [resolutionId] = @resolutionId, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const branch = { ...body };
                logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Sucursal ${branch.name} actualizada.`, metadata: branch });
                return NextResponse.json(branch);
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
            await prisma.branch.update({
                where: { id: dbId },
                data: { template: null, htmlTemplate: null }
            });
            finalTemplateBuffer = null;
        } else if (!finalTemplateBuffer || !finalLogoBuffer || !finalInvoiceTemplateBuffer) {
            const current: any = await prisma.branch.findUnique({
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
                console.error("Error generating/updating HTML template during branch update:", htmlErr);
            }
        }

        let invoiceHtmlTemplate = null;
        if (finalInvoiceTemplateBuffer) {
            try {
                invoiceHtmlTemplate = await generateHtmlTemplate(finalInvoiceTemplateBuffer, body.invoiceTemplateConfig, finalLogoBuffer);
            } catch (htmlErr: any) {
                console.error("Error generating/updating invoice HTML template during branch update:", htmlErr);
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spBranchActualizar($1::INT, $2::TEXT, $3::TEXT, $4::BYTEA, $5::BYTEA, $6::JSONB, $7::TEXT, $8::INT, $9::BYTEA, $10::JSONB, $11::TEXT, $12::BOOLEAN, $13::INT, $14::TEXT)`,
            dbId,
            body.code,
            body.name,
            logoBuffer,
            templateBuffer,
            body.templateConfig ? body.templateConfig : null,
            htmlTemplate,
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
            await syncCellCustomization(dbId, null, body.templateConfig);
        }

        const branch = { ...body };

        logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Sucursal ${branch.name} actualizada (SP).`, metadata: branch });

        return NextResponse.json(branch)
    } catch (error: any) {
        console.error('Error updating branch:', error);
        return NextResponse.json({ message: 'Error al actualizar sucursal: ' + error.message }, { status: 500 })
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
                    .query(`DELETE FROM dbo.[Branch] WHERE [id] = @id`);
                await pool.close();
                logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Sucursal con ID ${id} eliminada.` });
                return NextResponse.json({ message: 'Branch deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spBranchEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            ''
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Sucursal con ID ${id} eliminada (SP).` });

        return NextResponse.json({ message: 'Branch deleted successfully' })
    } catch (error: any) {
        console.error('Error deleting branch:', error);
        return NextResponse.json({ message: 'Error al eliminar sucursal: ' + error.message }, { status: 500 })
    }
}
