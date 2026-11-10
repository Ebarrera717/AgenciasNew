import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';
import {
    DEFAULT_ITEM_DESCRIPTION_CONFIG,
    DEFAULT_OBSERVATIONS_CONFIG,
    ZeusTextSectionConfig
} from '@/lib/zeus-text-formatter';

export const dynamic = 'force-dynamic';

const PARAM_ITEM_DESC = 'ZeusItemDescriptionConfig';
const PARAM_OBS = 'ZeusObservationsConfig';

/**
 * Obtiene la configuración de textos para Zeus ERP
 */
export async function GET() {
    try {
        let itemDescConfig: ZeusTextSectionConfig = DEFAULT_ITEM_DESCRIPTION_CONFIG;
        let obsConfig: ZeusTextSectionConfig = DEFAULT_OBSERVATIONS_CONFIG;

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            try {
                const res = await pool.request().query(`
                    SELECT [code], [value] 
                    FROM dbo.[SystemParameter] 
                    WHERE [code] IN ('${PARAM_ITEM_DESC}', '${PARAM_OBS}')
                `);
                for (const row of res.recordset || []) {
                    if (row.code === PARAM_ITEM_DESC && row.value) {
                        try { itemDescConfig = JSON.parse(row.value); } catch {}
                    }
                    if (row.code === PARAM_OBS && row.value) {
                        try { obsConfig = JSON.parse(row.value); } catch {}
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
            `, [PARAM_ITEM_DESC, PARAM_OBS]);

            for (const row of rows || []) {
                if (row.code === PARAM_ITEM_DESC && row.value) {
                    try { itemDescConfig = JSON.parse(row.value); } catch {}
                }
                if (row.code === PARAM_OBS && row.value) {
                    try { obsConfig = JSON.parse(row.value); } catch {}
                }
            }
        }

        return NextResponse.json({
            success: true,
            itemDescriptionConfig: itemDescConfig,
            observationsConfig: obsConfig
        });
    } catch (error: any) {
        console.error('Error fetching Zeus export config:', error);
        return NextResponse.json({
            success: false,
            message: 'Error al obtener configuración de textos Zeus: ' + error.message,
            itemDescriptionConfig: DEFAULT_ITEM_DESCRIPTION_CONFIG,
            observationsConfig: DEFAULT_OBSERVATIONS_CONFIG
        }, { status: 500 });
    }
}

/**
 * Guarda o actualiza la configuración de textos para Zeus ERP
 */
export async function POST(req: NextRequest) {
    try {
        const body = await req.json();
        const { itemDescriptionConfig, observationsConfig } = body;

        const itemDescVal = JSON.stringify(itemDescriptionConfig || DEFAULT_ITEM_DESCRIPTION_CONFIG);
        const obsVal = JSON.stringify(observationsConfig || DEFAULT_OBSERVATIONS_CONFIG);

        if (isSQLServerMode()) {
            const pool = await getSQLServerConnection();
            try {
                // Upsert para ZeusItemDescriptionConfig
                await pool.request()
                    .input('code', PARAM_ITEM_DESC)
                    .input('name', 'Parametrización Descripción Ítems Zeus ERP')
                    .input('value', itemDescVal)
                    .query(`
                        IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = @code)
                            UPDATE dbo.[SystemParameter] SET [value] = @value, [name] = @name WHERE [code] = @code
                        ELSE
                            INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (@code, @name, @value)
                    `);

                // Upsert para ZeusObservationsConfig
                await pool.request()
                    .input('code', PARAM_OBS)
                    .input('name', 'Parametrización Observaciones Zeus ERP')
                    .input('value', obsVal)
                    .query(`
                        IF EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = @code)
                            UPDATE dbo.[SystemParameter] SET [value] = @value, [name] = @name WHERE [code] = @code
                        ELSE
                            INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (@code, @name, @value)
                    `);
            } finally {
                await pool.close();
            }
        } else {
            // PostgreSQL Upsert
            await prisma.$queryRawUnsafe(`
                INSERT INTO public."SystemParameter" ("code", "name", "value")
                VALUES ($1, $2, $3)
                ON CONFLICT ("code") DO UPDATE 
                SET "value" = EXCLUDED."value", "name" = EXCLUDED."name"
            `, PARAM_ITEM_DESC, 'Parametrización Descripción Ítems Zeus ERP', itemDescVal);

            await prisma.$queryRawUnsafe(`
                INSERT INTO public."SystemParameter" ("code", "name", "value")
                VALUES ($1, $2, $3)
                ON CONFLICT ("code") DO UPDATE 
                SET "value" = EXCLUDED."value", "name" = EXCLUDED."name"
            `, PARAM_OBS, 'Parametrización Observaciones Zeus ERP', obsVal);
        }

        return NextResponse.json({
            success: true,
            message: 'Configuración de exportación a Zeus ERP guardada correctamente.'
        });
    } catch (error: any) {
        console.error('Error saving Zeus export config:', error);
        return NextResponse.json({
            success: false,
            message: 'Error al guardar la configuración: ' + error.message
        }, { status: 500 });
    }
}
