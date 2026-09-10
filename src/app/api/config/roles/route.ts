import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import { normalizeRolePermissions, isSuperAdminRole } from '@/lib/permissions';

export const dynamic = 'force-dynamic';

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const requesterRole = searchParams.get('userRole')?.toUpperCase().trim() || req.headers.get('x-user-role')?.toUpperCase().trim() || '';
        const isRequesterSuperAdmin = isSuperAdminRole(requesterRole);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT r.[id], r.[name], r.[description], r.[permissions],
                           (SELECT COUNT(*) FROM dbo.[User] u WHERE u.[roleId] = r.[id]) AS user_count
                    FROM dbo.[Role] r
                    ORDER BY r.[id] ASC
                `);
                await pool.close();
                let formatted = res.recordset.map((role: any) => {
                    const roleName = String(role.name);
                    const isSuper = isSuperAdminRole(roleName);
                    return {
                        id: Number(role.id),
                        name: roleName,
                        description: String(role.description || ''),
                        permissions: normalizeRolePermissions(role.permissions, roleName),
                        userCount: Number(role.user_count || 0),
                        isSuperAdmin: isSuper
                    };
                });
                if (!isRequesterSuperAdmin) {
                    formatted = formatted.filter(r => !r.isSuperAdmin);
                }
                return NextResponse.json(formatted);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        // Ejecución a través de la Función SQL de PostgreSQL fnRoleListar()
        const roles: any[] = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnRoleListar"()`);

        let formatted = roles.map(role => {
            const roleName = String(role.name);
            const isSuper = isSuperAdminRole(roleName);
            return {
                id: Number(role.id),
                name: roleName,
                description: String(role.description || ''),
                permissions: normalizeRolePermissions(role.permissions, roleName),
                userCount: Number(role.user_count || 0),
                isSuperAdmin: isSuper
            };
        });

        // REGLA: El rol SUPERADMINISTRADOR solo es visible para usuarios SUPERADMINISTRADORES
        if (!isRequesterSuperAdmin) {
            formatted = formatted.filter(r => !r.isSuperAdmin);
        }

        return NextResponse.json(formatted);
    } catch (error: any) {
        console.error('Error consultando roles:', error);
        return NextResponse.json({ message: 'Error consultando roles en la base de datos' }, { status: 500 });
    }
}

export async function POST(req: NextRequest) {
    try {
        const { name, description, permissions } = await req.json();

        if (!name || !name.trim()) {
            return NextResponse.json({ message: 'El nombre del rol es requerido' }, { status: 400 });
        }

        const roleName = String(name).trim();
        const normPermissions = normalizeRolePermissions(permissions, roleName);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const permStr = JSON.stringify(normPermissions);
                const res = await pool.request()
                    .input('name', roleName)
                    .input('description', description ? String(description).trim() : '')
                    .input('permissions', permStr)
                    .query(`
                        INSERT INTO dbo.[Role] ([name], [description], [permissions])
                        OUTPUT INSERTED.id
                        VALUES (@name, @description, @permissions)
                    `);
                await pool.close();
                return NextResponse.json({ message: 'Rol guardado exitosamente', id: res.recordset[0]?.id });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        // Ejecución a través del Procedimiento Almacenado public.spRoleGuardarYPermisos
        const result: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spRoleGuardarYPermisos"($1, $2, $3, $4::jsonb, NULL, NULL)`,
            0,
            roleName,
            description ? String(description).trim() : '',
            JSON.stringify(normPermissions)
        );

        return NextResponse.json({ message: 'Rol guardado exitosamente en la base de datos', result });
    } catch (error: any) {
        console.error('Error guardando rol:', error);
        return NextResponse.json({ message: error.message || 'Error al guardar el rol en BD' }, { status: 500 });
    }
}

export async function PUT(req: NextRequest) {
    try {
        const { id, name, description, permissions } = await req.json();

        if (!id) {
            return NextResponse.json({ message: 'El ID del rol es requerido' }, { status: 400 });
        }

        const roleName = String(name || '').trim();
        const normPermissions = normalizeRolePermissions(permissions, roleName);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const permStr = JSON.stringify(normPermissions);
                await pool.request()
                    .input('id', Number(id))
                    .input('name', roleName)
                    .input('description', description ? String(description).trim() : '')
                    .input('permissions', permStr)
                    .query(`
                        UPDATE dbo.[Role]
                        SET [name] = @name, [description] = @description, [permissions] = @permissions
                        WHERE [id] = @id
                    `);
                await pool.close();
                return NextResponse.json({ message: 'Rol actualizado con éxito' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        // Ejecución a través del Procedimiento Almacenado public.spRoleGuardarYPermisos
        const result: any[] = await prisma.$queryRawUnsafe(
            `CALL public."spRoleGuardarYPermisos"($1, $2, $3, $4::jsonb, NULL, NULL)`,
            Number(id),
            roleName,
            description ? String(description).trim() : '',
            JSON.stringify(normPermissions)
        );

        return NextResponse.json({ message: 'Rol actualizado con éxito en la base de datos', result });
    } catch (error: any) {
        console.error('Error actualizando rol:', error);
        return NextResponse.json({ message: error.message || 'Error al actualizar el rol en BD' }, { status: 500 });
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get('id');

        if (!id) {
            return NextResponse.json({ message: 'ID de rol requerido' }, { status: 400 });
        }

        const roleId = Number(id);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const roleCheck = await pool.request()
                    .input('id', roleId)
                    .query(`SELECT [name] FROM dbo.[Role] WHERE [id] = @id`);
                if (roleCheck.recordset[0] && isSuperAdminRole(roleCheck.recordset[0].name)) {
                    await pool.close();
                    return NextResponse.json({ message: 'El rol SUPERADMINISTRADOR no puede ser eliminado.' }, { status: 400 });
                }
                const userCheck = await pool.request()
                    .input('id', roleId)
                    .query(`SELECT COUNT(*) as count FROM dbo.[User] WHERE [roleId] = @id`);
                if (userCheck.recordset[0]?.count > 0) {
                    await pool.close();
                    return NextResponse.json({ message: `No se puede eliminar el rol porque tiene ${userCheck.recordset[0].count} usuario(s) asignado(s).` }, { status: 400 });
                }
                await pool.request()
                    .input('id', roleId)
                    .query(`DELETE FROM dbo.[Role] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Rol eliminado con éxito' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const roleCheck: any[] = await prisma.$queryRawUnsafe(
            `SELECT name FROM public."Role" WHERE id = $1`,
            roleId
        );

        if (roleCheck[0] && isSuperAdminRole(roleCheck[0].name)) {
            return NextResponse.json({ message: 'El rol SUPERADMINISTRADOR es un rol del sistema y no puede ser eliminado.' }, { status: 400 });
        }

        const checkUser: any[] = await prisma.$queryRawUnsafe(
            `SELECT COUNT(*)::int as count FROM public."User" WHERE "roleId" = $1`,
            roleId
        );

        if (checkUser[0]?.count > 0) {
            return NextResponse.json({ message: `No se puede eliminar el rol porque tiene ${checkUser[0].count} usuario(s) asignado(s).` }, { status: 400 });
        }

        await prisma.$executeRawUnsafe(`DELETE FROM public."Role" WHERE id = $1`, roleId);

        return NextResponse.json({ message: 'Rol eliminado con éxito de la base de datos' });
    } catch (error: any) {
        console.error('Error eliminando rol:', error);
        return NextResponse.json({ message: 'Error al eliminar el rol' }, { status: 500 });
    }
}
