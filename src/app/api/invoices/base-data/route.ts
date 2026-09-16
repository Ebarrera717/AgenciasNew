import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const safeQuery = async (q: string) => {
                    try {
                        const r = await pool!.request().query(q);
                        return r.recordset || [];
                    } catch (e: any) {
                        console.warn(`[invoices/base-data] SQL Server query failed: ${q}`, e.message);
                        return [];
                    }
                };

                const [
                    clients, providers, prestadoras, branches, implants, products,
                    taxes, sellers, ticketPrinters, variables, currencies,
                    creditCards, payments, ticketTypes, parameters, cities, combos
                ] = await Promise.all([
                    safeQuery('SELECT [id], [name], [document] FROM dbo.[Client] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Provider] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Prestadora] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Branch] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT [id], [code], [name], [branchId] FROM dbo.[Implant] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Product] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[ChargeAndTax] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Seller] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[TicketPrinter] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[MasterVariable] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Currency] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[CreditCard] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[Payment] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[TicketType] WHERE [isActive] = 1 OR [isActive] IS NULL'),
                    safeQuery('SELECT * FROM dbo.[SystemParameter]'),
                    safeQuery('SELECT * FROM dbo.[Cities]'),
                    safeQuery('SELECT * FROM dbo.[Combo] WHERE [isActive] = 1 OR [isActive] IS NULL')
                ]);
                await pool.close();

                return NextResponse.json({
                    clients,
                    providers,
                    prestadoras,
                    branches,
                    implants,
                    products,
                    taxes,
                    sellers,
                    ticketPrinters,
                    variables,
                    currentUser: null,
                    combos,
                    currencies,
                    creditCards,
                    payments,
                    ticketTypes,
                    parameters,
                    cities
                });
            } catch (err: any) {
                if (pool) await pool.close();
                console.error('Error fetching invoices base-data in SQL Server mode:', err);
                return NextResponse.json({ message: 'Error fetching base data', detail: err.message }, { status: 500 });
            }
        }
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : undefined

        // Defensive check for models
        const requiredModels = ['client', 'provider', 'prestadora', 'branch', 'implant', 'product', 'chargeAndTax', 'seller', 'ticketPrinter', 'masterVariable', 'user', 'combo', 'currency']
        const availableModels = Object.keys(prisma).filter(k => k[0] !== '$' && k[0] !== '_');
        
        for (const model of requiredModels) {
            if (!(prisma as any)[model]) {
                console.warn(`Prisma model "${model}" is undefined in base-data API! Available: ${availableModels.join(', ')}`)
                // We'll continue but this model will return empty array below
            }
        }

        const [clients, providers, prestadoras, branches, implants, products, taxes, sellers, ticketPrinters, variables, currentUser, combos, currencies, creditCards, payments, ticketTypes, parameters] = await Promise.all([
            (prisma as any).client?.findMany({ where: { isActive: { not: false } }, select: { id: true, name: true, document: true } }) || Promise.resolve([]),
            (prisma as any).provider?.findMany({ where: { isActive: { not: false } }, include: { prestadoras: true } }) || Promise.resolve([]),
            (prisma as any).prestadora?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).branch?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).implant?.findMany({ where: { isActive: { not: false } }, select: { id: true, code: true, name: true, branchId: true } }) || Promise.resolve([]),
            (prisma as any).product?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).chargeAndTax?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).seller?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).ticketPrinter?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).masterVariable?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            actingUserId ? (prisma as any).user?.findUnique({ where: { id: actingUserId } }) : Promise.resolve(null),
            (prisma as any).combo?.findMany({
                where: { isActive: { not: false } },
                include: {
                    products: {
                        include: {
                            appliedTaxes: {
                                include: { chargeAndTax: true }
                            },
                            product: true
                        }
                    }
                },
                orderBy: { createdAt: 'desc' }
            }),
            (prisma as any).currency?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).creditCard?.findMany({ where: { inactive: false, isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).payment?.findMany({ where: { inactive: false } }) || Promise.resolve([]),
            (prisma as any).ticketType?.findMany({ where: { isActive: { not: false } } }) || Promise.resolve([]),
            (prisma as any).systemParameter?.findMany() || Promise.resolve([])
        ])

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const validCombos = (combos || []).map((combo: any) => ({
            ...combo,
            products: combo.products.filter((p: any) => !p.checkOutDate || new Date(p.checkOutDate) >= today)
        })).filter((combo: any) => combo.products.length > 0 && (combo.cupos === undefined || combo.cupos === null || combo.cupos > 0));

        let cities: any[] = [];
        try {
            const cityRecords: any = await prisma.$queryRawUnsafe('SELECT * FROM public."fnCityListar"()');
            cities = Array.isArray(cityRecords) ? cityRecords : [];
        } catch (e) {
            console.error('Error fetching cities in base-data:', e);
        }

        return NextResponse.json({
            clients,
            providers,
            prestadoras,
            branches,
            implants,
            products,
            taxes,
            sellers,
            ticketPrinters,
            variables,
            currentUser,
            combos: validCombos,
            currencies,
            creditCards,
            payments,
            ticketTypes,
            parameters,
            cities
        })
    } catch (error: any) {
        console.error('Data fetch error:', error)
        return NextResponse.json({ message: 'Error fetching base data', detail: error?.message || String(error) }, { status: 500 })
    }
}
