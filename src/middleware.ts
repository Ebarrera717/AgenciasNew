import { NextResponse, NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
    const { pathname } = req.nextUrl;

    // Rutas públicas que NUNCA se bloquean
    if (
        pathname.startsWith('/login') ||
        pathname.startsWith('/analytics/login') ||
        pathname.startsWith('/licencia-expirada') ||
        pathname.startsWith('/api/auth') ||
        pathname.startsWith('/api/kax/auth') ||
        pathname.startsWith('/api/config/license') ||
        pathname.startsWith('/_next') ||
        pathname.includes('.')
    ) {
        return NextResponse.next();
    }

    // 1. Verificación de Expiración / Falta de Licencia en Edge Runtime
    const licExpCookie = req.cookies.get('korex_lic_exp')?.value;

    let isLicenseBlocked = false;

    if (licExpCookie === 'EXPIRED' || licExpCookie === 'UNLICENSED') {
        isLicenseBlocked = true;
    } else if (licExpCookie) {
        const expDate = new Date(`${licExpCookie}T23:59:59.999Z`);
        if (isNaN(expDate.getTime()) || new Date() > expDate) {
            isLicenseBlocked = true;
        }
    }

    if (isLicenseBlocked) {
        if (pathname.startsWith('/api')) {
            return NextResponse.json(
                { message: 'La licencia del sistema ha expirado o no ha sido activada. Por favor ingrese una clave válida.' },
                { status: 402 } // Payment Required
            );
        }
        return NextResponse.redirect(new URL('/licencia-expirada', req.url));
    }

    // 2. Verificación de Token de Autenticación de Usuario (Si se requiere)
    const authToken = req.cookies.get('auth_token')?.value;

    if (!authToken && process.env.REQUIRE_AUTH === 'true') {
        if (pathname.startsWith('/api')) {
            return NextResponse.json({ message: 'No autorizado' }, { status: 401 });
        }
        return NextResponse.redirect(new URL('/login', req.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/dashboard/:path*', '/api/:path*'],
};
