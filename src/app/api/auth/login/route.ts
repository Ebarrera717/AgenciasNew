import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import bcrypt from 'bcryptjs'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function POST(req: NextRequest) {
    try {
        const { email, password } = await req.json()
        const targetEmail = email?.toLowerCase()

        if (!targetEmail || !password) {
            return NextResponse.json({ message: 'Email y contraseña son requeridos' }, { status: 400 })
        }

        if (isSQLServerMode()) {
            console.log('[LOGIN] Autenticando directamente en SQL Server...');
            let pool;
            try {
                pool = await getSQLServerConnection();
                const result = await pool.request()
                    .input('email', targetEmail)
                    .query('SELECT TOP 1 u.*, r.name AS roleName, r.permissions AS rolePermissions FROM dbo.[User] u LEFT JOIN dbo.[Role] r ON u.roleId = r.id WHERE LOWER(u.email) = LOWER(@email)');
                await pool.close();

                const dbUser = result.recordset[0];
                if (!dbUser) {
                    return NextResponse.json({ message: 'Credenciales inválidas' }, { status: 401 });
                }

                const isValid = await bcrypt.compare(password, dbUser.passwordHash);
                if (!isValid) {
                    return NextResponse.json({ message: 'Credenciales inválidas' }, { status: 401 });
                }

                const { normalizeRolePermissions } = await import('@/lib/permissions');
                let rolePermissions = {};
                try {
                    rolePermissions = normalizeRolePermissions(typeof dbUser.rolePermissions === 'string' ? JSON.parse(dbUser.rolePermissions) : dbUser.rolePermissions);
                } catch (e) {}

                const response = NextResponse.json({
                    message: 'Acceso concedido',
                    user: {
                        id: dbUser.id,
                        name: dbUser.name,
                        email: dbUser.email,
                        role: dbUser.roleName || 'Administrador',
                        permissions: rolePermissions,
                        branchId: dbUser.branchId,
                        implantId: dbUser.implantId,
                        ticketPrinterId: dbUser.ticketPrinterId,
                        canEditReports: dbUser.canEditReports ?? false
                    },
                });
                return response;
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const user = await prisma.user.findUnique({
            where: { email: targetEmail },
            include: { role: true },
        })

        if (!user) {
            return NextResponse.json({ message: 'Credenciales inválidas' }, { status: 401 })
        }

        const isValid = await bcrypt.compare(password, user.passwordHash)

        if (!isValid) {
            return NextResponse.json({ message: 'Credenciales inválidas' }, { status: 401 })
        }

        const { normalizeRolePermissions } = await import('@/lib/permissions');
        const rolePermissions = normalizeRolePermissions(user.role.permissions);

        const response = NextResponse.json({
            message: 'Acceso concedido',
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role.name,
                permissions: rolePermissions,
                branchId: user.branchId,
                implantId: user.implantId,
                ticketPrinterId: user.ticketPrinterId,
                canEditReports: user.canEditReports ?? false
            },
        })

        try {
            const { getStoredLicenseStatus } = await import('@/lib/license');
            const licenseStatus = await getStoredLicenseStatus();
            if (licenseStatus.expirationDate) {
                response.cookies.set('korex_lic_exp', licenseStatus.expirationDate, {
                    path: '/',
                    httpOnly: true,
                    sameSite: 'lax'
                });
            }
        } catch (licErr) {
            console.error('Error adjuntando cookie de licencia:', licErr);
        }

        return response
    } catch (error: any) {
        console.error('Login error:', error)

        let message = 'Error interno del servidor';
        let mainDetail = error?.message || String(error) || 'Error no especificado';
        if (error?.originalError?.message) {
            mainDetail += ` | Causa raíz: ${error.originalError.message}`;
        }
        let detail = mainDetail;
        let category: 'DATABASE' | 'CREDENTIALS' | 'SERVER' = 'SERVER';
        let suggestion = '1. Verifique los logs del servidor.\n2. Asegúrese de que el servicio de base de datos esté iniciado.\n3. Revise la variable de entorno DATABASE_URL_SQLSERVER / DATABASE_URL en .env';

        const errStr = String(error?.message || '').toLowerCase();
        const errCode = String(error?.code || error?.originalError?.code || '');

        if (
            errStr.includes('connect') ||
            errStr.includes('econnrefused') ||
            errStr.includes('connection') ||
            errStr.includes('unable to open') ||
            errStr.includes('server is not reachable') ||
            errStr.includes('timeout') ||
            errStr.includes('closed') ||
            errStr.includes('elogin') ||
            errStr.includes('enotfound') ||
            errCode === 'P1001' ||
            errCode === 'P1002' ||
            errCode === 'P1008' ||
            errCode === 'ELOGIN'
        ) {
            category = 'DATABASE';
            message = 'No se pudo conectar con la Base de Datos';
            suggestion = '1. Verifique que el servicio de SQL Server esté en ejecución en el servidor.\n2. Si usa un nombre de host (ej. ZEUSAGENCIAS10), intente cambiarlo en .env a 127.0.0.1:1433 o localhost:1433.\n3. Confirme que el usuario (sa / zeusagencias) y contraseña en .env sean válidos.';
        } else if (
            errStr.includes('does not exist') ||
            errStr.includes('invalid object name') ||
            errStr.includes('relation') ||
            errCode === 'P2021' ||
            errCode === 'P2022'
        ) {
            category = 'DATABASE';
            message = 'Tabla o Esquema de Base de Datos Incompleto';
            suggestion = '1. Verifique que la base de datos configurada en .env exista (ej. Korex_Pruebas).\n2. Asegúrese de haber restaurado el backup inicial (.bak) o ejecutado los scripts T-SQL de creación de tablas.';
        } else if (
            errStr.includes('access denied') ||
            errStr.includes('login failed') ||
            errStr.includes('authentication') ||
            errCode === 'P1000'
        ) {
            category = 'CREDENTIALS';
            message = 'Fallo de Autenticación con la Base de Datos';
            suggestion = '1. Verifique el usuario (ej. sa o zeusagencias) y la contraseña en el archivo .env.\n2. Confirme que la cuenta de SQL Server / Postgres tenga permisos de lectura y escritura.';
        }

        return NextResponse.json({
            message,
            detail,
            category,
            suggestion,
            errorCode: errCode || 'SERVER_ERROR'
        }, { status: 500 })
    }
}
