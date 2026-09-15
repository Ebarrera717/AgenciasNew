import { NextResponse } from 'next/server'
import { isSQLServerMode } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET() {
    try {
        const isSql = isSQLServerMode()
        let dbName = ''
        let serverName = ''

        if (isSql) {
            const sqlUrl = process.env.DATABASE_URL_SQLSERVER || process.env.DATABASE_URL || ''
            const dbMatch = sqlUrl.match(/database=([^;]+)/i)
            dbName = dbMatch ? dbMatch[1] : 'SQL Server'
            serverName = 'SQL Server (T-SQL)'
        } else {
            dbName = 'Korex_colaereo'
            serverName = 'PostgreSQL (Local)'
        }

        return NextResponse.json({
            isSQLServer: isSql,
            provider: isSql ? 'sqlserver' : 'postgresql',
            name: isSql ? 'Microsoft SQL Server' : 'PostgreSQL',
            shortName: isSql ? 'SQL Server' : 'PostgreSQL',
            serverName,
            dbName
        })
    } catch (e: any) {
        return NextResponse.json({
            isSQLServer: false,
            provider: 'postgresql',
            name: 'PostgreSQL',
            shortName: 'PostgreSQL',
            serverName: 'PostgreSQL',
            dbName: 'Korex_colaereo'
        })
    }
}
