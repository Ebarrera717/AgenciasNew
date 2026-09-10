import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT [id], [name], [spName], [description], [parameters]
                    FROM dbo.[ExecutionProcedure]
                    ORDER BY [name] ASC
                `);
                await pool.close();
                const procedures = res.recordset.map((p: any) => ({
                    ...p,
                    parameters: typeof p.parameters === 'string' ? JSON.parse(p.parameters) : p.parameters
                }));
                return NextResponse.json(procedures);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const procedures = await prisma.executionProcedure.findMany({
            orderBy: { name: 'asc' }
        })
        return NextResponse.json(procedures)
    } catch (error: any) {
        console.error('Error fetching execution procedures:', error)
        return NextResponse.json({ message: 'Error fetching procedures', error: error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, name, spName, description, parameters } = body

        if (!name || !spName) {
            return NextResponse.json({ message: 'El nombre y el SP son obligatorios.' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const paramsStr = JSON.stringify(parameters || []);
                if (id) {
                    await pool.request()
                        .input('id', Number(id))
                        .input('name', name)
                        .input('spName', spName)
                        .input('description', description || null)
                        .input('parameters', paramsStr)
                        .query(`
                            UPDATE dbo.[ExecutionProcedure]
                            SET [name] = @name, [spName] = @spName, [description] = @description, [parameters] = @parameters
                            WHERE [id] = @id
                        `);
                    await pool.close();
                    return NextResponse.json({ id: Number(id), name, spName, description, parameters: parameters || [] });
                } else {
                    const res = await pool.request()
                        .input('name', name)
                        .input('spName', spName)
                        .input('description', description || null)
                        .input('parameters', paramsStr)
                        .query(`
                            INSERT INTO dbo.[ExecutionProcedure] ([name], [spName], [description], [parameters])
                            OUTPUT INSERTED.id
                            VALUES (@name, @spName, @description, @parameters)
                        `);
                    await pool.close();
                    return NextResponse.json({ id: res.recordset[0]?.id, name, spName, description, parameters: parameters || [] });
                }
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        if (id) {
            const updated = await prisma.executionProcedure.update({
                where: { id: Number(id) },
                data: {
                    name,
                    spName,
                    description,
                    parameters: parameters ? parameters : []
                }
            })
            return NextResponse.json(updated)
        } else {
            const created = await prisma.executionProcedure.create({
                data: {
                    name,
                    spName,
                    description,
                    parameters: parameters ? parameters : []
                }
            })
            return NextResponse.json(created)
        }
    } catch (error: any) {
        console.error('Error saving execution procedure:', error)
        return NextResponse.json({ message: error.message || 'Error saving procedure' }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')

        if (!id) {
            return NextResponse.json({ message: 'ID es requerido' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', Number(id))
                    .query(`DELETE FROM dbo.[ExecutionProcedure] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ success: true, message: 'Procedimiento eliminado con éxito' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.executionProcedure.delete({
            where: { id: Number(id) }
        })

        return NextResponse.json({ success: true, message: 'Procedimiento eliminado con éxito' })
    } catch (error: any) {
        console.error('Error deleting execution procedure:', error)
        return NextResponse.json({ message: error.message || 'Error deleting procedure' }, { status: 500 })
    }
}
