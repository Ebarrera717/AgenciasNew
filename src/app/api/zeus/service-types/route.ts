import { NextRequest, NextResponse } from 'next/server';
import mssql from 'mssql';
import { getZeusSQLServerConnection } from '@/lib/sqlserver';

export const dynamic = 'force-dynamic';

/**
 * GET /api/zeus/service-types
 *
 * Modos de consulta sobre dbo.TiposServicios de ZeusERP (solo lectura, sin modificar objetos nativos):
 * 1) Listado / Búsqueda (por defecto): ?search=texto
 *    Retorna únicamente tipos de servicio ACTIVOS (ISNULL(bl_inactivo, 0) = 0).
 * 2) Validación puntual: ?validate=codigo_o_descripcion
 *    Valida si el valor existe y está activo en ZeusERP, distinguiendo entre ACTIVE, INACTIVE y NOT_FOUND.
 */
export async function GET(req: NextRequest) {
    let pool: mssql.ConnectionPool | null = null;
    try {
        const { searchParams } = new URL(req.url);
        const validateValue = searchParams.get('validate');
        const search = (searchParams.get('search') || '').trim();

        pool = await getZeusSQLServerConnection();

        // Verificar que la tabla dbo.TiposServicios exista en la base ZeusERP configurada
        const tableCheck = await pool.request().query(`
            SELECT OBJECT_ID('dbo.TiposServicios', 'U') AS obj_id
        `);
        if (!tableCheck.recordset?.[0]?.obj_id) {
            return NextResponse.json({
                success: false,
                items: [],
                error: 'La tabla dbo.TiposServicios no existe en la base de datos de ZeusERP configurada.'
            }, { status: 404 });
        }

        // MODO VALIDACIÓN PUNTUAL
        if (validateValue !== null) {
            const trimmed = validateValue.trim();
            if (!trimmed) {
                return NextResponse.json({
                    success: true,
                    valid: true,
                    status: 'EMPTY',
                    code: '',
                    description: '',
                    message: ''
                });
            }

            const reqVal = pool.request();
            reqVal.input('val', mssql.VarChar(100), trimmed);
            const result = await reqVal.query(`
                SELECT TOP 1
                    id,
                    LTRIM(RTRIM(cd_codigo)) AS code,
                    LTRIM(RTRIM(ds_nombre)) AS description,
                    LTRIM(RTRIM(ISNULL(ds_descrip, ''))) AS detail,
                    CAST(ISNULL(bl_inactivo, 0) AS BIT) AS isInactive
                FROM dbo.TiposServicios WITH (NOLOCK)
                WHERE UPPER(LTRIM(RTRIM(cd_codigo))) = UPPER(@val)
                   OR UPPER(LTRIM(RTRIM(ds_nombre))) = UPPER(@val)
                ORDER BY
                    CASE WHEN ISNULL(bl_inactivo, 0) = 0 THEN 0 ELSE 1 END,
                    CASE WHEN UPPER(LTRIM(RTRIM(cd_codigo))) = UPPER(@val) THEN 0 ELSE 1 END,
                    id ASC
            `);

            const row = result.recordset?.[0];
            if (!row) {
                return NextResponse.json({
                    success: true,
                    valid: false,
                    status: 'NOT_FOUND',
                    code: '',
                    description: '',
                    message: `El tipo de servicio "${trimmed}" no existe en ZeusERP. No se enviará como tipo de servicio válido.`
                });
            }

            if (row.isInactive === true || row.isInactive === 1) {
                return NextResponse.json({
                    success: true,
                    valid: false,
                    status: 'INACTIVE',
                    code: row.code,
                    description: row.description,
                    message: `El tipo de servicio "${row.code} - ${row.description}" se encuentra INACTIVO en ZeusERP y no puede utilizarse.`
                });
            }

            return NextResponse.json({
                success: true,
                valid: true,
                status: 'ACTIVE',
                id: row.id,
                code: row.code,
                description: row.description,
                detail: row.detail,
                message: ''
            });
        }

        // MODO BÚSQUEDA / LISTADO (solo activos)
        const request = pool.request();
        request.input('search', mssql.VarChar(100), search);

        const res = await request.query(`
            SELECT
                id,
                LTRIM(RTRIM(cd_codigo)) AS code,
                LTRIM(RTRIM(ds_nombre)) AS description,
                LTRIM(RTRIM(ISNULL(ds_descrip, ''))) AS detail
            FROM dbo.TiposServicios WITH (NOLOCK)
            WHERE ISNULL(bl_inactivo, 0) = 0
              AND LTRIM(RTRIM(ISNULL(cd_codigo, ''))) <> ''
              AND (
                  @search = ''
                  OR LTRIM(RTRIM(cd_codigo)) LIKE '%' + @search + '%'
                  OR LTRIM(RTRIM(ds_nombre)) LIKE '%' + @search + '%'
                  OR LTRIM(RTRIM(ISNULL(ds_descrip, ''))) LIKE '%' + @search + '%'
              )
            ORDER BY LTRIM(RTRIM(cd_codigo)) ASC
        `);

        return NextResponse.json({
            success: true,
            items: res.recordset || []
        });
    } catch (error: any) {
        console.error('[API_ZEUS_SERVICE_TYPES] Error:', error.message);
        return NextResponse.json({
            success: false,
            items: [],
            error: error.message || 'No fue posible consultar los tipos de servicio en ZeusERP.'
        }, { status: 500 });
    } finally {
        if (pool) {
            try { await pool.close(); } catch { /* ignore */ }
        }
    }
}
