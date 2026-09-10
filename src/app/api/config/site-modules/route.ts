import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { isSuperAdminRole } from '@/lib/permissions'

export const dynamic = 'force-dynamic'

function isRequesterAllowed(req: NextRequest): boolean {
    const role = req.headers.get('x-user-role')?.toUpperCase().trim() || new URL(req.url).searchParams.get('userRole')?.toUpperCase().trim() || '';
    if (role && !isSuperAdminRole(role)) {
        return false;
    }
    return true;
}

export async function GET(req: NextRequest) {
    try {
        if (!isRequesterAllowed(req)) {
            return NextResponse.json({ message: 'Acceso denegado. Exclusivo para SUPERADMINISTRADOR.' }, { status: 403 })
        }
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mRes = await pool.request().query('SELECT [id], [code], [name], [action], [activo] FROM dbo.[Menu] ORDER BY [id] ASC');
                const maRes = await pool.request().query('SELECT [id], [code], [name], ISNULL([inactivo], 0) AS [inactivo] FROM dbo.[Master] ORDER BY [name] ASC');
                await pool.close();
                return NextResponse.json({ modules: mRes.recordset || [], masters: maRes.recordset || [] });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const modules: any[] = await prisma.$queryRawUnsafe(`SELECT * FROM public.fnMenuAll()`)
        const masters: any[] = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnMasterList"()`)
        return NextResponse.json({ modules, masters })
    } catch (error: any) {
        console.error('Error fetching site modules and masters:', error)
        return NextResponse.json({ message: 'Error al consultar módulos y maestros', error: error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        if (!isRequesterAllowed(req)) {
            return NextResponse.json({ message: 'Acceso denegado. Exclusivo para SUPERADMINISTRADOR.' }, { status: 403 })
        }
        const body = await req.json()
        const { type, id, active } = body

        if (!type || !id || active === undefined) {
            return NextResponse.json({ message: 'Parámetros incompletos (type, id, active son requeridos)' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                if (String(type).toUpperCase() === 'MENU') {
                    await pool.request()
                        .input('id', Number(id))
                        .input('active', Boolean(active) ? 1 : 0)
                        .query('UPDATE dbo.[Menu] SET [activo] = @active WHERE [id] = @id');
                } else if (String(type).toUpperCase() === 'MASTER') {
                    await pool.request()
                        .input('id', Number(id))
                        .input('inactivo', Boolean(active) ? 0 : 1)
                        .query('UPDATE dbo.[Master] SET [inactivo] = @inactivo WHERE [id] = @id');
                }
                await pool.close();
                return NextResponse.json({ message: 'Estado actualizado correctamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.$executeRawUnsafe(
            `CALL public."spSiteModuleMasterToggle"($1, $2, $3)`,
            String(type),
            Number(id),
            Boolean(active)
        )

        return NextResponse.json({ message: 'Estado actualizado correctamente' })
    } catch (error: any) {
        console.error('Error updating site module/master state:', error)
        return NextResponse.json({ message: 'Error al actualizar estado', error: error.message }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        if (!isRequesterAllowed(req)) {
            return NextResponse.json({ message: 'Acceso denegado. Exclusivo para SUPERADMINISTRADOR.' }, { status: 403 })
        }
        const body = await req.json()
        if (body.action === 'RESET_ALL') {
            if (isSQLServerMode()) {
                let pool;
                try {
                    pool = await getSQLServerConnection();
                    await pool.request().query('UPDATE dbo.[Menu] SET [activo] = 1; UPDATE dbo.[Master] SET [inactivo] = 0;');
                    await pool.close();
                    return NextResponse.json({ message: 'Todos los módulos y maestros se han restablecido a ACTIVO' });
                } catch (err: any) {
                    if (pool) await pool.close();
                    throw err;
                }
            }
            await prisma.$executeRawUnsafe(`UPDATE public."Menu" SET activo = true;`)
            await prisma.$executeRawUnsafe(`UPDATE public."Master" SET inactivo = false;`)
            return NextResponse.json({ message: 'Todos los módulos y maestros se han restablecido a ACTIVO' })
        }
        return NextResponse.json({ message: 'Acción no válida' }, { status: 400 })
    } catch (error: any) {
        console.error('Error resetting modules/masters:', error)
        return NextResponse.json({ message: 'Error al restablecer módulos', error: error.message }, { status: 500 })
    }
}
