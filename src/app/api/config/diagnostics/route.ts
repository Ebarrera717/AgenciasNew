import { NextResponse, NextRequest } from 'next/server';
import prisma from '@/lib/prisma';
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import { getStoredLicenseStatus } from '@/lib/license';
import { registerErrorLog } from '@/lib/logger';

export async function GET(req: NextRequest) {
    const diagnosticsResult: any = {
        timestamp: new Date().toISOString(),
        postgres: { status: 'UNKNOWN', message: '' },
        sqlServer: { status: 'UNKNOWN', message: '', server: '', database: '' },
        license: { status: 'UNKNOWN', message: '', clientName: '', expirationDate: '', daysRemaining: null },
        recentErrors: []
    };

    // 1. Probar Base de Datos Principal
    if (isSQLServerMode()) {
        try {
            const pool = await getSQLServerConnection();
            const res = await pool.request().query('SELECT @@VERSION as version');
            diagnosticsResult.postgres = {
                status: 'OK',
                message: 'Conectado exitosamente a SQL Server Direct Mode',
                version: res.recordset[0]?.version || 'SQL Server'
            };
            await pool.close();
        } catch (err: any) {
            diagnosticsResult.postgres = {
                status: 'ERROR',
                message: `Error al conectar a SQL Server: ${err.message}`
            };
        }
    } else {
        try {
            const pgCheck: any = await prisma.$queryRawUnsafe('SELECT version() as version');
            diagnosticsResult.postgres = {
                status: 'OK',
                message: 'Conectado exitosamente a PostgreSQL (Korex_colaereo)',
                version: pgCheck[0]?.version || 'PostgreSQL'
            };
        } catch (err: any) {
            diagnosticsResult.postgres = {
                status: 'ERROR',
                message: `Error al conectar a PostgreSQL local: ${err.message}`
            };
        }
    }

    // 2. Probar SQL Server ERP Zeus
    try {
        const pool = await getSQLServerConnection();
        const testRes = await pool.request().query('SELECT COUNT(*) as count FROM dbo.CLIENTES');
        diagnosticsResult.sqlServer = {
            status: 'OK',
            message: `Conexión exitosa con Zeus ERP (${testRes.recordset[0]?.count || 0} clientes registrados en ERP)`
        };
        await pool.close();
    } catch (err: any) {
        diagnosticsResult.sqlServer = {
            status: 'WARNING',
            message: `No se pudo conectar a SQL Server Zeus ERP: ${err.message}`
        };
    }

    // 3. Probar Estado de Licencia
    try {
        const licenseStatus = await getStoredLicenseStatus();
        diagnosticsResult.license = {
            status: licenseStatus.status,
            message: licenseStatus.isLicensed ? 'Licencia activa y validada' : 'Licencia no válida o no configurada',
            clientName: licenseStatus.clientName,
            expirationDate: licenseStatus.expirationDate,
            daysRemaining: licenseStatus.daysRemaining,
            nit: licenseStatus.nit
        };
    } catch (err: any) {
        diagnosticsResult.license = {
            status: 'ERROR',
            message: `Error al verificar la licencia: ${err.message}`
        };
    }

    // 4. Consultar últimos errores del sistema
    if (!isSQLServerMode()) {
        try {
            const errors = await prisma.systemLog.findMany({
                where: {
                    OR: [
                        { action: 'ERROR' },
                        { description: { contains: 'ERROR', mode: 'insensitive' } }
                    ]
                },
                orderBy: { createdAt: 'desc' },
                take: 20,
                include: { user: true }
            });

            diagnosticsResult.recentErrors = errors.map((e: any) => ({
                id: e.id,
                createdAt: e.createdAt,
                module: e.module,
                action: e.action,
                description: e.description,
                userName: e.user?.name || 'Sistema / Automático',
                metadata: e.metadata
            }));
        } catch (err: any) {
            console.error('Error al consultar logs de diagnóstico:', err);
        }
    }

    return NextResponse.json(diagnosticsResult);
}

export async function POST(req: Request) {
    try {
        const userIdHeader = req.headers.get('X-User-Id');
        const userId = userIdHeader ? parseInt(userIdHeader) : null;
        const body = await req.json();

        const { module, action, description, errorDetails, endpoint, statusCode } = body;

        if (!description) {
            return NextResponse.json({ error: 'La descripción del error es requerida' }, { status: 400 });
        }

        const log = await registerErrorLog({
            userId,
            module: module || 'FRONTEND',
            action: action || 'ERROR',
            description,
            errorDetails,
            endpoint,
            statusCode: statusCode || 500
        });

        return NextResponse.json({ success: true, id: log?.id });
    } catch (error: any) {
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
