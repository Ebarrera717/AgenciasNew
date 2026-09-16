import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import prisma from '@/lib/prisma'
import mssql from 'mssql'

export interface ConsecutiveResult {
    consecutivoNumber: number
    prefix: string
    formattedConsecutive: string
    consecutivoId: number | null
}

export async function getNextTransactionConsecutive(
    transactionType: string,
    branchId: number | null = null,
    implantId: number | null = null
): Promise<ConsecutiveResult> {
    const rawType = (transactionType || 'INVOICE').trim().toUpperCase()

    if (isSQLServerMode()) {
        let pool
        try {
            pool = await getSQLServerConnection()
            const req = pool.request()
                .input('type', mssql.VarChar, rawType)
                .input('branchId', mssql.Int, branchId)
                .input('implantId', mssql.Int, implantId)

            const query = `
                SELECT TOP 1 [id], ISNULL([prefix], '') AS prefix, [currentNumber], ISNULL([padding], 0) AS padding
                FROM dbo.[TransactionConsecutive]
                WHERE [isActive] = 1
                  AND (
                      UPPER([transactionType]) = @type
                      OR (@type IN ('INVOICE','FACTURA','FACTURACION') AND UPPER([transactionType]) IN ('INVOICE','FACTURA','FACTURACION'))
                      OR (@type IN ('QUOTATION','COTIZACION') AND UPPER([transactionType]) IN ('QUOTATION','COTIZACION'))
                      OR (@type IN ('PREQUOTATION','PRECOTIZACION') AND UPPER([transactionType]) IN ('PREQUOTATION','PRECOTIZACION'))
                      OR (@type IN ('CREDIT_NOTE','NOTA_CREDITO') AND UPPER([transactionType]) IN ('CREDIT_NOTE','NOTA_CREDITO'))
                  )
                  AND (@branchId IS NULL OR [branchId] = @branchId OR [branchId] IS NULL)
                  AND (@implantId IS NULL OR [implantId] = @implantId OR [implantId] IS NULL)
                ORDER BY
                  CASE WHEN [implantId] = @implantId THEN 1 WHEN [implantId] IS NOT NULL THEN 3 ELSE 2 END,
                  CASE WHEN [branchId] = @branchId THEN 1 WHEN [branchId] IS NOT NULL THEN 3 ELSE 2 END,
                  [id] ASC;
            `
            const res = await req.query(query)

            if (res.recordset && res.recordset.length > 0) {
                const row = res.recordset[0]
                const consecId = row.id
                const consecNum = row.currentNumber
                const prefixRaw = (row.prefix || '').trim()
                const padding = row.padding || 0

                // Incrementar consecutivo
                await pool.request()
                    .input('id', mssql.Int, consecId)
                    .query(`UPDATE dbo.[TransactionConsecutive] SET [currentNumber] = [currentNumber] + 1, [updatedAt] = GETDATE() WHERE [id] = @id`)

                await pool.close()

                let numStr = consecNum.toString()
                if (padding > 0 && numStr.length < padding) {
                    numStr = numStr.padStart(padding, '0')
                }

                let formatted = ''
                if (prefixRaw) {
                    if (prefixRaw.endsWith('-') || prefixRaw.endsWith('/')) {
                        formatted = `${prefixRaw}${numStr}`
                    } else {
                        formatted = `${prefixRaw}-${numStr}`
                    }
                } else {
                    formatted = numStr
                }

                return {
                    consecutivoNumber: consecNum,
                    prefix: prefixRaw,
                    formattedConsecutive: formatted,
                    consecutivoId: consecId
                }
            } else {
                // Fallback si no hay consecutivo registrado
                let defaultPrefix = 'DOC'
                let tableName = ''

                if (['INVOICE', 'FACTURA', 'FACTURACION'].includes(rawType)) {
                    defaultPrefix = 'FAC'
                    tableName = 'Invoices'
                } else if (['QUOTATION', 'COTIZACION'].includes(rawType)) {
                    defaultPrefix = 'COT'
                    tableName = 'Quotation'
                } else if (['CREDIT_NOTE', 'NOTA_CREDITO'].includes(rawType)) {
                    defaultPrefix = 'NC'
                }

                let nextVal = 1
                if (tableName) {
                    const maxRes = await pool.request().query(`SELECT ISNULL(MAX(id), 0) + 1 AS nextVal FROM dbo.[${tableName}]`)
                    if (maxRes.recordset && maxRes.recordset.length > 0) {
                        nextVal = maxRes.recordset[0].nextVal
                    }
                }
                await pool.close()

                return {
                    consecutivoNumber: nextVal,
                    prefix: defaultPrefix,
                    formattedConsecutive: `${defaultPrefix}-${nextVal}`,
                    consecutivoId: null
                }
            }
        } catch (err) {
            if (pool) await pool.close()
            console.error('Error fetching T-SQL consecutive:', err)
            throw err
        }
    } else {
        // PostgreSQL Mode
        const results: any[] = await prisma.$queryRawUnsafe(
            `SELECT public."fnObtenerSiguienteConsecutivo"($1::TEXT, $2::INT, $3::INT) AS res`,
            rawType,
            branchId,
            implantId
        )
        const resJson = results[0]?.res || {}
        return {
            consecutivoNumber: resJson.consecutivoNumber || 1,
            prefix: resJson.prefix || '',
            formattedConsecutive: resJson.formattedConsecutive || `DOC-${Date.now()}`,
            consecutivoId: resJson.consecutivoId || null
        }
    }
}
