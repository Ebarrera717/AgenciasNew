import prisma from '@/lib/prisma';
import { isSQLServerMode } from '@/lib/sqlserver';

/**
 * Registra un evento de auditoría en el sistema usando Prisma.
 */
export async function registerLog(
    userId: number | null,
    module: string,
    action: string,
    description: string,
    metadata: any = null
) {
    try {
        console.log(`[AuditLog_DEBUG] Intentando registrar: ${module} - ${action}: ${description}`);

        if (isSQLServerMode()) {
            console.log(`[AuditLog_SQLSERVER] ${module} - ${action}: ${description}`);
            return;
        }

        const logEntry = await prisma.systemLog.create({
            data: {
                userId: userId && userId !== 0 ? Number(userId) : null,
                module: module.toUpperCase(),
                action: action.toUpperCase(),
                description,
                metadata: metadata || null
            }
        });

        console.log(`[AuditLog_SUCCESS] Evento registrado ID: ${logEntry.id}`);
        return logEntry;
    } catch (error: any) {
        console.error('[AuditLog_ERROR] Fallo al crear log en Prisma:', error.message);
        if (error.code) console.error('  Code:', error.code);
    }
}

/**
 * Registra un error de sistema o excepción estructurada con metadatos extendidos.
 */
export async function registerErrorLog(params: {
    userId?: number | null;
    module: string;
    action?: string;
    description: string;
    errorDetails?: string;
    endpoint?: string;
    statusCode?: number;
}) {
    return registerLog(
        params.userId || null,
        params.module,
        params.action || 'ERROR',
        params.description,
        {
            errorDetails: params.errorDetails || null,
            endpoint: params.endpoint || null,
            statusCode: params.statusCode || 500,
            timestamp: new Date().toISOString()
        }
    );
}

/**
 * Función compatibilidad para soportar compilación Next.js limpia sin refactorizar.
 */
export async function logSystemEvent(params: {
    userId: number | null | undefined,
    action: string,
    module: string,
    description: string,
    metadata?: any
}) {
    return registerLog(params.userId || null, params.module, params.action, params.description, params.metadata);
}
