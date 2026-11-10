import prisma from '@/lib/prisma';
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import {
    DEFAULT_ITEM_DESCRIPTION_CONFIG,
    DEFAULT_OBSERVATIONS_CONFIG,
    ZeusTextSectionConfig
} from '@/lib/zeus-text-formatter';

/**
 * Consulta de configuraciones activas desde la base de datos (PostgreSQL o SQL Server).
 * Este módulo se ejecuta estrictamente en el entorno del servidor (Server-Side).
 */
export async function getZeusTextConfigs(): Promise<{
    itemDescriptionConfig: ZeusTextSectionConfig;
    observationsConfig: ZeusTextSectionConfig;
}> {
    try {
        let itemDescriptionConfig: ZeusTextSectionConfig = DEFAULT_ITEM_DESCRIPTION_CONFIG;
        let observationsConfig: ZeusTextSectionConfig = DEFAULT_OBSERVATIONS_CONFIG;

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            try {
                const res = await pool.request().query(`
                    SELECT [code], [value] 
                    FROM dbo.[SystemParameter] 
                    WHERE [code] IN ('ZeusItemDescriptionConfig', 'ZeusObservationsConfig')
                `);
                for (const row of res.recordset || []) {
                    if (row.code === 'ZeusItemDescriptionConfig' && row.value) {
                        try { itemDescriptionConfig = JSON.parse(row.value); } catch {}
                    }
                    if (row.code === 'ZeusObservationsConfig' && row.value) {
                        try { observationsConfig = JSON.parse(row.value); } catch {}
                    }
                }
            } finally {
                await pool.close();
            }
        } else {
            const rows = await prisma.$queryRawUnsafe<any[]>(`
                SELECT "code", "value" 
                FROM public."SystemParameter" 
                WHERE "code" = ANY($1::text[])
            `, ['ZeusItemDescriptionConfig', 'ZeusObservationsConfig']);

            for (const row of rows || []) {
                if (row.code === 'ZeusItemDescriptionConfig' && row.value) {
                    try { itemDescriptionConfig = JSON.parse(row.value); } catch {}
                }
                if (row.code === 'ZeusObservationsConfig' && row.value) {
                    try { observationsConfig = JSON.parse(row.value); } catch {}
                }
            }
        }

        return { itemDescriptionConfig, observationsConfig };
    } catch (e: any) {
        console.warn('[ZEUS_TEXT_SERVICE] Error obteniendo configuraciones de BD, usando valores por defecto:', e.message);
        return {
            itemDescriptionConfig: DEFAULT_ITEM_DESCRIPTION_CONFIG,
            observationsConfig: DEFAULT_OBSERVATIONS_CONFIG
        };
    }
}
