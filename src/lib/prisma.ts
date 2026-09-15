import { PrismaClient } from '@prisma/client'
import { Pool } from 'pg'
import { PrismaPg } from '@prisma/adapter-pg'

const getActiveDbUrl = () => {
    const provider = (process.env.DATABASE_PROVIDER || '').toLowerCase().trim();
    if (provider === 'sqlserver') {
        return (process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL || '').trim();
    }
    return (process.env.DATABASE_URL_POSTGRES || process.env.DATABASE_URL || '').trim();
};

const isSqlUrl = (url: string) => {
    const provider = (process.env.DATABASE_PROVIDER || '').toLowerCase().trim();
    if (provider === 'postgresql') return false;
    if (provider === 'sqlserver') return true;
    return url.startsWith('sqlserver://') || url.startsWith('mssql://');
};

import { executePostgresQuery } from './postgres'

const prismaClientSingleton = () => {
    console.log('--- Instantiating NEW PrismaClient ---')
    const connectionString = getActiveDbUrl()

    if (isSqlUrl(connectionString)) {
        console.log('--- Modo Directo SQL Server detectado: Retornando Proxy para Prisma ---')
        const proxyObj = new Proxy({} as any, {
            get(target, prop) {
                if (prop === 'then' || prop === 'catch' || prop === 'finally') return undefined;
                if (prop === '$queryRawUnsafe' || prop === '$executeRawUnsafe') {
                    return async (query: string, ...params: any[]) => {
                        console.log(`[PRISMA_SQLSERVER_PROXY] Redirigiendo ${String(prop)} a ejecutor directo de PostgreSQL: ${query.substring(0, 60)}...`);
                        return executePostgresQuery(query, params);
                    };
                }
                return new Proxy(() => {}, {
                    get(t, p) {
                        return () => Promise.reject(new Error(`[PRISMA_SQLSERVER_PROXY] Prisma no debe ser invocado en modo SQL Server direct. La consulta '${String(prop)}.${String(p)}' debe ser ejecutada mediante getSQLServerConnection().`));
                    },
                    apply() {
                        return Promise.reject(new Error(`[PRISMA_SQLSERVER_PROXY] Prisma no debe ser invocado en modo SQL Server direct. La consulta '${String(prop)}' debe ser ejecutada mediante getSQLServerConnection().`));
                    }
                });
            }
        }) as PrismaClient
        ;(proxyObj as any).__isProxy = true
        return proxyObj
    }

    const pgUrl = connectionString || "postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public"
    const pool = new Pool({ connectionString: pgUrl })
    const adapter = new PrismaPg(pool)

    const prisma = new PrismaClient({
        adapter,
        log: [
            { emit: 'event', level: 'query' },
            { emit: 'stdout', level: 'error' },
            { emit: 'stdout', level: 'info' },
            { emit: 'stdout', level: 'warn' }
        ]
    })

    ;(prisma as any).$on('query', (e: any) => {
        console.log(`[PRISMA_SQL] Consulta: ${e.query} | Params: ${e.params} | Duración: ${e.duration}ms`);
    })

    return prisma
}

type PrismaClientSingleton = ReturnType<typeof prismaClientSingleton>

const globalForPrisma = globalThis as unknown as { prisma_prestadora_v1: PrismaClient | undefined }

const isCurrentSqlMode = (() => {
    return isSqlUrl(getActiveDbUrl());
})();

const isProxyInstance = (obj: any): boolean => {
    if (!obj) return false;
    if (obj.__isProxy === true) return true;
    if (typeof obj._clientVersion !== 'string') return true;
    return false;
};

const cachedPrisma = globalForPrisma.prisma_prestadora_v1;

if (cachedPrisma && isProxyInstance(cachedPrisma) !== isCurrentSqlMode) {
    console.log('[PRISMA_SINGLETON] Modo de base de datos cambió o proxy obsoleto en memoria. Re-creando PrismaClient...');
    globalForPrisma.prisma_prestadora_v1 = undefined;
}

const prisma = globalForPrisma.prisma_prestadora_v1 ?? prismaClientSingleton()

export default prisma

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma_prestadora_v1 = prisma
