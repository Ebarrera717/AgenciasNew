import crypto from 'crypto';
import prisma from '@/lib/prisma';

const SECRET_KEY = process.env.LICENSE_SECRET || 'Korex_Master_License_Secret_Key_2026_Secure';

export interface LicensePayload {
    client: string;
    nit: string;
    expirationDate: string; // YYYY-MM-DD
    issuedDate: string;
}

export interface LicenseVerificationResult {
    isValid: boolean;
    payload?: LicensePayload;
    error?: string;
}

export interface LicenseStatus {
    isLicensed: boolean;
    isExpired: boolean;
    expirationDate: string | null;
    daysRemaining: number | null;
    clientName: string | null;
    nit: string | null;
    status: 'ACTIVE' | 'WARNING' | 'EXPIRED' | 'UNLICENSED';
}

/**
 * Valida un token de licencia HMAC SHA256
 */
export function verifyLicenseKey(licenseKey: string): LicenseVerificationResult {
    if (!licenseKey || typeof licenseKey !== 'string') {
        return { isValid: false, error: 'Clave de licencia vacía o con formato inválido' };
    }

    const parts = licenseKey.trim().split('.');
    if (parts.length !== 3 || parts[0] !== 'KOR1') {
        return { isValid: false, error: 'Formato de clave de licencia desconocido' };
    }

    const [, payloadBase64, signature] = parts;

    try {
        const expectedSignature = crypto
            .createHmac('sha256', SECRET_KEY)
            .update(payloadBase64)
            .digest('hex');

        // Comparación segura
        if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))) {
            return { isValid: false, error: 'La firma de la clave de licencia es inválida o fue alterada' };
        }

        const decodedJson = Buffer.from(payloadBase64, 'base64url').toString('utf8');
        const rawPayload = JSON.parse(decodedJson);

        if (!rawPayload.c || !rawPayload.n || !rawPayload.e) {
            return { isValid: false, error: 'Contenido de la clave incompleto' };
        }

        return {
            isValid: true,
            payload: {
                client: rawPayload.c,
                nit: rawPayload.n,
                expirationDate: rawPayload.e,
                issuedDate: rawPayload.i || ''
            }
        };
    } catch (err: any) {
        return { isValid: false, error: 'Error al decodificar la licencia: ' + err.message };
    }
}

/**
 * Obtiene el estado actual de la licencia guardada en la Base de Datos
 */
export async function getStoredLicenseStatus(): Promise<LicenseStatus> {
    try {
        const agencyNameParam = await prisma.systemParameter.findUnique({ where: { code: 'AGENCY_NAME' } });
        const agencyNitParam = await prisma.systemParameter.findUnique({ where: { code: 'AGENCY_NIT' } });

        const configuredClient = agencyNameParam?.value?.trim() || null;
        const configuredNit = agencyNitParam?.value?.trim() || null;

        const paramKey = await prisma.systemParameter.findUnique({
            where: { code: 'LICENSE_KEY' }
        });

        if (!paramKey || !paramKey.value) {
            return {
                isLicensed: false,
                isExpired: true,
                expirationDate: null,
                daysRemaining: null,
                clientName: configuredClient,
                nit: configuredNit,
                status: 'UNLICENSED'
            };
        }

        const verification = verifyLicenseKey(paramKey.value);
        if (!verification.isValid || !verification.payload) {
            return {
                isLicensed: false,
                isExpired: true,
                expirationDate: null,
                daysRemaining: null,
                clientName: configuredClient,
                nit: configuredNit,
                status: 'UNLICENSED'
            };
        }

        const { client, nit, expirationDate } = verification.payload;
        const targetExpDate = new Date(`${expirationDate}T23:59:59.999Z`);
        const now = new Date();

        const diffTime = targetExpDate.getTime() - now.getTime();
        const daysRemaining = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        const isExpired = now.getTime() > targetExpDate.getTime();

        let status: 'ACTIVE' | 'WARNING' | 'EXPIRED' | 'UNLICENSED' = 'ACTIVE';
        if (isExpired) {
            status = 'EXPIRED';
        } else if (daysRemaining <= 15) {
            status = 'WARNING';
        }

        return {
            isLicensed: true,
            isExpired,
            expirationDate,
            daysRemaining,
            clientName: configuredClient || client,
            nit: configuredNit || nit,
            status
        };
    } catch (error) {
        console.error('Error al consultar estado de licencia:', error);
        return {
            isLicensed: false,
            isExpired: false,
            expirationDate: null,
            daysRemaining: null,
            clientName: null,
            nit: null,
            status: 'UNLICENSED'
        };
    }
}

/**
 * Registra o actualiza la clave de licencia en la Base de Datos
 */
export async function applyLicenseKey(
    licenseKey: string, 
    actingUserId: number = 1,
    clientNameInput?: string,
    nitInput?: string
) {
    const verification = verifyLicenseKey(licenseKey);
    if (!verification.isValid || !verification.payload) {
        throw new Error(verification.error || 'Clave de licencia inválida');
    }

    const { client, nit, expirationDate } = verification.payload;

    // Registrar / Actualizar Nombre y NIT de la Agencia con la información verificada de la clave de licencia
    const finalClient = (clientNameInput && clientNameInput.trim()) || client.trim();
    const finalNit = (nitInput && nitInput.trim()) || nit.trim();

    // Actualizar en SystemParameter usando Prisma upsert
    await prisma.systemParameter.upsert({
        where: { code: 'LICENSE_KEY' },
        update: { value: licenseKey.trim(), name: 'Clave de Licencia del Sistema' },
        create: { code: 'LICENSE_KEY', name: 'Clave de Licencia del Sistema', value: licenseKey.trim() }
    });

    await prisma.systemParameter.upsert({
        where: { code: 'LICENSE_EXPIRATION_DATE' },
        update: { value: expirationDate, name: 'Fecha de Expiración de Licencia' },
        create: { code: 'LICENSE_EXPIRATION_DATE', name: 'Fecha de Expiración de Licencia', value: expirationDate }
    });

    // Registrar Nombre y NIT de la Agencia oficialmente en la base de datos
    await prisma.systemParameter.upsert({
        where: { code: 'AGENCY_NAME' },
        update: { value: finalClient, name: 'Nombre o Razón Social de la Agencia' },
        create: { code: 'AGENCY_NAME', name: 'Nombre o Razón Social de la Agencia', value: finalClient }
    });

    await prisma.systemParameter.upsert({
        where: { code: 'AGENCY_NIT' },
        update: { value: finalNit, name: 'NIT de la Agencia' },
        create: { code: 'AGENCY_NIT', name: 'NIT de la Agencia', value: finalNit }
    });

    // Registrar en SystemLog
    try {
        const { logSystemEvent } = await import('@/lib/logger');
        await logSystemEvent({
            userId: actingUserId,
            action: 'UPDATE',
            module: 'LICENSE',
            description: `Licencia actualizada para ${finalClient} (NIT ${finalNit}) activa hasta ${expirationDate}.`,
            metadata: { client: finalClient, nit: finalNit, expirationDate }
        });
    } catch (e) {
        console.error('Error al registrar log de licencia:', e);
    }

    return verification.payload;
}
