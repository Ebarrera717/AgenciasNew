import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const procedureId = searchParams.get('procedureId')

        if (!procedureId) {
            return NextResponse.json({ message: 'El parámetro "procedureId" es requerido.' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('procedureId', Number(procedureId))
                    .query(`
                        SELECT [id], [procedureId], [name], [description], [filterValues], [filterConfig], [columnConfigs], [selectedTotals]
                        FROM dbo.[ExecutionPreset]
                        WHERE [procedureId] = @procedureId
                        ORDER BY [name] ASC
                    `);
                await pool.close();
                const presets = res.recordset.map((p: any) => ({
                    ...p,
                    filterValues: typeof p.filterValues === 'string' ? JSON.parse(p.filterValues) : p.filterValues,
                    filterConfig: typeof p.filterConfig === 'string' ? JSON.parse(p.filterConfig) : p.filterConfig,
                    columnConfigs: typeof p.columnConfigs === 'string' ? JSON.parse(p.columnConfigs) : p.columnConfigs,
                    selectedTotals: typeof p.selectedTotals === 'string' ? JSON.parse(p.selectedTotals) : p.selectedTotals
                }));
                return NextResponse.json(presets);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const presets = await prisma.executionPreset.findMany({
            where: { procedureId: Number(procedureId) },
            orderBy: { name: 'asc' }
        })

        return NextResponse.json(presets)
    } catch (error: any) {
        console.error('Error fetching execution presets:', error)
        return NextResponse.json({ message: 'Error al obtener plantillas guardadas.', error: error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, name, procedureId, description, filterValues, filterConfig, columnConfigs, selectedTotals } = body

        if (!name || !procedureId) {
            return NextResponse.json({ message: 'El nombre y el ID del procedimiento son obligatorios.' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const fVal = JSON.stringify(filterValues || {});
                const fCfg = JSON.stringify(filterConfig || {});
                const cCfg = JSON.stringify(columnConfigs || []);
                const sTot = JSON.stringify(selectedTotals || []);
                if (id) {
                    await pool.request()
                        .input('id', Number(id))
                        .input('name', name)
                        .input('description', description || null)
                        .input('filterValues', fVal)
                        .input('filterConfig', fCfg)
                        .input('columnConfigs', cCfg)
                        .input('selectedTotals', sTot)
                        .query(`
                            UPDATE dbo.[ExecutionPreset]
                            SET [name] = @name, [description] = @description, [filterValues] = @filterValues,
                                [filterConfig] = @filterConfig, [columnConfigs] = @columnConfigs, [selectedTotals] = @selectedTotals
                            WHERE [id] = @id
                        `);
                    await pool.close();
                    return NextResponse.json({ id: Number(id), name, procedureId: Number(procedureId), description, filterValues: filterValues || {}, filterConfig: filterConfig || {}, columnConfigs: columnConfigs || [], selectedTotals: selectedTotals || [] });
                } else {
                    const res = await pool.request()
                        .input('procedureId', Number(procedureId))
                        .input('name', name)
                        .input('description', description || null)
                        .input('filterValues', fVal)
                        .input('filterConfig', fCfg)
                        .input('columnConfigs', cCfg)
                        .input('selectedTotals', sTot)
                        .query(`
                            INSERT INTO dbo.[ExecutionPreset] ([procedureId], [name], [description], [filterValues], [filterConfig], [columnConfigs], [selectedTotals])
                            OUTPUT INSERTED.id
                            VALUES (@procedureId, @name, @description, @filterValues, @filterConfig, @columnConfigs, @selectedTotals)
                        `);
                    await pool.close();
                    return NextResponse.json({ id: res.recordset[0]?.id, name, procedureId: Number(procedureId), description, filterValues: filterValues || {}, filterConfig: filterConfig || {}, columnConfigs: columnConfigs || [], selectedTotals: selectedTotals || [] });
                }
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        if (id) {
            const updated = await prisma.executionPreset.update({
                where: { id: Number(id) },
                data: {
                    name,
                    description,
                    filterValues: filterValues || {},
                    filterConfig: filterConfig || {},
                    columnConfigs: columnConfigs || [],
                    selectedTotals: selectedTotals || []
                }
            })
            return NextResponse.json(updated)
        } else {
            const created = await prisma.executionPreset.create({
                data: {
                    name,
                    procedureId: Number(procedureId),
                    description,
                    filterValues: filterValues || {},
                    filterConfig: filterConfig || {},
                    columnConfigs: columnConfigs || [],
                    selectedTotals: selectedTotals || []
                }
            })
            return NextResponse.json(created)
        }
    } catch (error: any) {
        console.error('Error saving execution preset:', error)
        return NextResponse.json({ message: error.message || 'Error al guardar la plantilla.' }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')

        if (!id) {
            return NextResponse.json({ message: 'El ID de la plantilla es requerido.' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', Number(id))
                    .query(`DELETE FROM dbo.[ExecutionPreset] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true, message: 'Plantilla eliminada con éxito.' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.executionPreset.delete({
            where: { id: Number(id) }
        })

        return NextResponse.json({ success: true, message: 'Plantilla eliminada con éxito.' })
    } catch (error: any) {
        console.error('Error deleting execution preset:', error)
        return NextResponse.json({ message: error.message || 'Error al eliminar la plantilla.' }, { status: 500 })
    }
}
