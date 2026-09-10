import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

interface Params {
    id: string
}

export async function GET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
    try {
        const { id: idStr } = await params
        const id = parseInt(idStr)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const { searchParams } = new URL(req.url)
        const exportMode = searchParams.get('export') === 'true'

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('id', id)
                    .query(`SELECT [id], [code], [name], [template], [templateConfig] FROM dbo.[Branch] WHERE [id] = @id`);
                await pool.close();
                const b = res.recordset[0];
                if (!b) return NextResponse.json({ message: 'Sucursal no encontrada' }, { status: 404 });

                let parsedConfig = b.templateConfig;
                if (typeof parsedConfig === 'string') {
                    try { parsedConfig = JSON.parse(parsedConfig); } catch (e) {}
                }

                if (exportMode) {
                    const exportData = {
                        name: `Formato Sucursal: ${b.name}`,
                        description: `Exportado desde la configuración de sucursal ${b.name}`,
                        templateConfig: parsedConfig || {},
                        template: b.template ? Buffer.from(b.template).toString('base64') : null,
                        cellCustomizations: [],
                        exportedAt: new Date().toISOString(),
                        version: '1.0',
                    }
                    const jsonStr = JSON.stringify(exportData, null, 2)
                    const safeFilename = String(b.name).replace(/[^a-zA-Z0-9_-]/g, '_')
                    return new NextResponse(jsonStr, {
                        headers: {
                            'Content-Type': 'application/json',
                            'Content-Disposition': `attachment; filename=formato_sucursal_${safeFilename}.json`,
                        }
                    })
                }

                return NextResponse.json({
                    id: b.id,
                    code: b.code,
                    name: b.name,
                    hasTemplate: !!b.template,
                    templateConfig: parsedConfig,
                });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const branch = await prisma.branch.findUnique({
            where: { id },
            include: {
                cellCustomizations: true
            }
        })

        if (!branch) return NextResponse.json({ message: 'Sucursal no encontrada' }, { status: 404 })

        if (exportMode) {
            // Export as format configuration JSON
            const exportData = {
                name: `Formato Sucursal: ${branch.name}`,
                description: `Exportado desde la configuración de sucursal ${branch.name}`,
                templateConfig: branch.templateConfig || {},
                template: branch.template ? Buffer.from(branch.template as any).toString('base64') : null,
                cellCustomizations: branch.cellCustomizations.map(c => ({
                    code: c.code,
                    name: c.name,
                    value: c.value,
                })),
                exportedAt: new Date().toISOString(),
                version: '1.0',
            }

            const jsonStr = JSON.stringify(exportData, null, 2)
            const safeFilename = branch.name.replace(/[^a-zA-Z0-9_-]/g, '_')
            return new NextResponse(jsonStr, {
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Disposition': `attachment; filename=formato_sucursal_${safeFilename}.json`,
                }
            })
        }

        // Standard GET (not export mode)
        return NextResponse.json({
            id: branch.id,
            code: branch.code,
            name: branch.name,
            hasTemplate: !!branch.template,
            templateConfig: branch.templateConfig,
        })
    } catch (error: any) {
        console.error('Error fetching/exporting branch:', error)
        return NextResponse.json({ message: 'Error al procesar sucursal', error: error.message }, { status: 500 })
    }
}
