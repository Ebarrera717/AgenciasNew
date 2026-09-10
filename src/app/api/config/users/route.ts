import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import bcrypt from 'bcryptjs'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT u.[id], u.[name], u.[email], u.[passwordHash], u.[roleId], u.[branchId], u.[implantId], u.[ticketPrinterId], u.[canEditReports], u.[isActive],
                           CASE WHEN u.[isActive] = 1 THEN 0 ELSE 1 END AS [inactive],
                           r.[name] AS role_name, b.[name] AS branch_name
                    FROM dbo.[User] u
                    LEFT JOIN dbo.[Role] r ON u.[roleId] = r.[id]
                    LEFT JOIN dbo.[Branch] b ON u.[branchId] = b.[id]
                    ORDER BY u.[name] ASC
                `);
                await pool.close();
                const users = res.recordset.map((u: any) => ({
                    ...u,
                    role: u.role_name ? { name: u.role_name } : null,
                    branch: u.branch_name ? { name: u.branch_name } : null
                }));
                return NextResponse.json(paginateArray(req, users, (u: any) => [u.name, u.email, u.role?.name]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const users = await (prisma.user.findMany({
            include: { role: true, branch: true, implant: true, ticketPrinter: true },
            orderBy: { name: 'asc' }
        }) as any)
        return NextResponse.json(paginateArray(req, users, (u: any) => [u.name, u.email, u.role?.name]))
    } catch (error: any) {
        console.error("error fetching users:", error)
        return NextResponse.json({ message: 'Error fetching users', error: error?.message || String(error) }, { status: 500 })
    }
}

import { isSuperAdminRole } from '@/lib/permissions'

async function getRequesterRole(req: NextRequest, actingUserId?: number): Promise<string> {
    let roleStr = req.headers.get('x-user-role')?.toUpperCase().trim() || new URL(req.url).searchParams.get('userRole')?.toUpperCase().trim() || '';
    if (!roleStr && actingUserId) {
        try {
            if (isSQLServerMode()) {
                let pool = await getSQLServerConnection();
                const res = await pool.request().input('uid', actingUserId).query(`
                    SELECT r.[name] FROM dbo.[User] u JOIN dbo.[Role] r ON u.[roleId] = r.[id] WHERE u.[id] = @uid
                `);
                await pool.close();
                if (res.recordset.length > 0) roleStr = res.recordset[0].name || '';
            } else {
                const u = await (prisma.user.findUnique({
                    where: { id: actingUserId },
                    include: { role: true }
                }) as any);
                if (u?.role?.name) roleStr = u.role.name;
            }
        } catch (err) {}
    }
    return roleStr;
}

async function checkIsRoleSuperAdmin(roleId: number): Promise<boolean> {
    try {
        if (isSQLServerMode()) {
            let pool = await getSQLServerConnection();
            const res = await pool.request().input('rid', roleId).query(`SELECT [name] FROM dbo.[Role] WHERE [id] = @rid`);
            await pool.close();
            return isSuperAdminRole(res.recordset[0]?.name);
        } else {
            const role = await prisma.role.findUnique({ where: { id: roleId } });
            return isSuperAdminRole(role?.name);
        }
    } catch (err) {
        return false;
    }
}

async function checkIsUserSuperAdmin(userId: number): Promise<boolean> {
    try {
        if (isSQLServerMode()) {
            let pool = await getSQLServerConnection();
            const res = await pool.request().input('uid', userId).query(`
                SELECT r.[name] FROM dbo.[User] u JOIN dbo.[Role] r ON u.[roleId] = r.[id] WHERE u.[id] = @uid
            `);
            await pool.close();
            return isSuperAdminRole(res.recordset[0]?.name);
        } else {
            const u = await (prisma.user.findUnique({
                where: { id: userId },
                include: { role: true }
            }) as any);
            return isSuperAdminRole(u?.role?.name);
        }
    } catch (err) {
        return false;
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined

        const requesterRole = await getRequesterRole(req, actingUserId);
        const isRequesterSuperAdmin = isSuperAdminRole(requesterRole);
        const targetRoleId = parseInt(body.roleId);
        const targetRoleIsSuperAdmin = await checkIsRoleSuperAdmin(targetRoleId);

        if (targetRoleIsSuperAdmin && !isRequesterSuperAdmin) {
            return NextResponse.json({ message: 'Solo los usuarios con el perfil SUPERADMINISTRADOR pueden crear o asignar usuarios con ese perfil.' }, { status: 403 });
        }

        const passwordHash = await bcrypt.hash(body.password, 10)

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('name', body.name || '')
                    .input('email', body.email || '')
                    .input('passwordHash', passwordHash)
                    .input('roleId', parseInt(body.roleId))
                    .input('branchId', body.branchId ? parseInt(body.branchId) : null)
                    .input('implantId', body.implantId ? parseInt(body.implantId) : null)
                    .input('ticketPrinterId', body.ticketPrinterId ? parseInt(body.ticketPrinterId) : null)
                    .input('canEditReports', body.canEditReports ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [branchId], [implantId], [ticketPrinterId], [canEditReports], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@name, @email, @passwordHash, @roleId, @branchId, @implantId, @ticketPrinterId, @canEditReports, 1)
                    `);
                await pool.close();
                const user = { id: res.recordset[0]?.id, name: body.name, email: body.email, roleId: body.roleId };
                return NextResponse.json(user);
            } catch (err: any) {
                if (pool) await pool.close();
                if (err.message?.includes('UQ_User_Email') || err.message?.includes('UNIQUE')) {
                    return NextResponse.json({ message: 'El correo ya existe' }, { status: 400 });
                }
                throw err;
            }
        }

        const user = await (prisma.user.create({
            data: {
                name: body.name,
                email: body.email,
                passwordHash: passwordHash,
                roleId: parseInt(body.roleId),
                branchId: body.branchId ? parseInt(body.branchId) : undefined,
                implantId: body.implantId ? parseInt(body.implantId) : undefined,
                ticketPrinterId: body.ticketPrinterId ? parseInt(body.ticketPrinterId) : undefined,
                canEditReports: Boolean(body.canEditReports)
            }
        }) as any)

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'CREATE',
                module: 'USER',
                description: `Usuario ${user.name} creado.`,
                metadata: { email: user.email, roleId: user.roleId }
            });
        });

        return NextResponse.json(user)
    } catch (error: any) {
        if (error.code === 'P2002') return NextResponse.json({ message: 'El correo ya existe' }, { status: 400 })
        return NextResponse.json({ message: 'Error creating user' }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined
        const isAct = body.isActive !== undefined ? Boolean(body.isActive) : (body.inactive !== undefined ? !body.inactive : undefined);

        const requesterRole = await getRequesterRole(req, actingUserId);
        const isRequesterSuperAdmin = isSuperAdminRole(requesterRole);
        
        const targetUserId = body.id ? parseInt(body.id) : undefined;
        const targetRoleId = body.roleId ? parseInt(body.roleId) : undefined;

        const isCurrentTargetSuperAdmin = targetUserId ? await checkIsUserSuperAdmin(targetUserId) : false;
        const isNewRoleSuperAdmin = targetRoleId ? await checkIsRoleSuperAdmin(targetRoleId) : false;

        if ((isCurrentTargetSuperAdmin || isNewRoleSuperAdmin) && !isRequesterSuperAdmin) {
            return NextResponse.json({ message: 'Solo los usuarios con el perfil SUPERADMINISTRADOR pueden modificar o asignar el perfil SUPERADMINISTRADOR.' }, { status: 403 });
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                let pwdHash = undefined;
                if (body.password) {
                    pwdHash = await bcrypt.hash(body.password, 10);
                }
                const reqObj = pool.request()
                    .input('id', parseInt(body.id))
                    .input('name', body.name || '')
                    .input('email', body.email || '')
                    .input('roleId', parseInt(body.roleId))
                    .input('branchId', body.branchId ? parseInt(body.branchId) : null)
                    .input('implantId', body.implantId ? parseInt(body.implantId) : null)
                    .input('ticketPrinterId', body.ticketPrinterId ? parseInt(body.ticketPrinterId) : null)
                    .input('canEditReports', body.canEditReports !== undefined ? (body.canEditReports ? 1 : 0) : 0)
                    .input('isActive', isAct !== undefined ? (isAct ? 1 : 0) : 1);

                if (pwdHash) {
                    reqObj.input('passwordHash', pwdHash);
                    await reqObj.query(`
                        UPDATE dbo.[User]
                        SET [name] = @name, [email] = @email, [passwordHash] = @passwordHash, [roleId] = @roleId,
                            [branchId] = @branchId, [implantId] = @implantId, [ticketPrinterId] = @ticketPrinterId,
                            [canEditReports] = @canEditReports, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                } else {
                    await reqObj.query(`
                        UPDATE dbo.[User]
                        SET [name] = @name, [email] = @email, [roleId] = @roleId,
                            [branchId] = @branchId, [implantId] = @implantId, [ticketPrinterId] = @ticketPrinterId,
                            [canEditReports] = @canEditReports, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                }
                await pool.close();
                const user = { id: body.id, name: body.name, email: body.email, roleId: body.roleId };
                return NextResponse.json(user);
            } catch (err: any) {
                if (pool) await pool.close();
                if (err.message?.includes('UQ_User_Email') || err.message?.includes('UNIQUE')) {
                    return NextResponse.json({ message: 'El correo ya existe' }, { status: 400 });
                }
                throw err;
            }
        }

        const data: any = {
            name: body.name,
            email: body.email,
            roleId: parseInt(body.roleId),
            branchId: body.branchId ? parseInt(body.branchId) : null,
            implantId: body.implantId ? parseInt(body.implantId) : null,
            ticketPrinterId: body.ticketPrinterId ? parseInt(body.ticketPrinterId) : null,
            canEditReports: body.canEditReports !== undefined ? Boolean(body.canEditReports) : undefined,
            isActive: isAct
        }

        if (body.password) {
            data.passwordHash = await bcrypt.hash(body.password, 10)
        }

        const user = await (prisma.user.update({
            where: { id: body.id },
            data
        }) as any)

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE',
                module: 'USER',
                description: `Usuario ${user.name} actualizado.`,
                metadata: { id: user.id, email: user.email, roleId: user.roleId }
            });
        });

        return NextResponse.json(user)
    } catch (error: any) {
        if (error.code === 'P2002') return NextResponse.json({ message: 'El correo ya existe' }, { status: 400 })
        return NextResponse.json({ message: 'Error updating user' }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined
        if (!id) return NextResponse.json({ message: 'ID is required' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[User] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'User deleted successfully' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        await prisma.user.delete({
            where: { id: parseInt(id) }
        })

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'DELETE',
                module: 'USER',
                description: `Usuario con ID ${id} eliminado.`
            });
        });

        return NextResponse.json({ message: 'User deleted successfully' })
    } catch (error: any) {
        return NextResponse.json({ message: 'Error deleting user', detail: error.message }, { status: 500 })
    }
}
