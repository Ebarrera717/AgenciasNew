-- ============================================================================
-- SCRIPT DE REPARACIÓN Y ACTUALIZACIÓN DE CIUDAD, TELÉFONO Y DIRECCIÓN DE CLIENTE
-- EN COTIZACIONES EXISTENTES DE ZEUS ERP (dbo.Cotizacion <- dbo.CLIENTES)
-- ============================================================================
-- Uso: Ejecutar en SQL Server Management Studio sobre la base de datos de Zeus ERP
--      (ejemplo: ZeusAgencias_Colaereo).
-- ============================================================================

SET NOCOUNT ON;

-- 1. Vista previa de las cotizaciones que serán actualizadas
SELECT 
    C.id,
    C.cd_consecutivo,
    C.cd_cliente_codigo,
    C.ds_cliente_nombre,
    C.ds_cliente_ciudad AS ciudad_actual,
    LEFT(COALESCE(NULLIF(RTRIM(LTRIM(CL.CIUDAD)), ''), NULLIF(RTRIM(LTRIM(C.ds_cliente_ciudad)), ''), 'BOGOTA'), 40) AS ciudad_nueva,
    C.ds_cliente_tel AS telefono_actual,
    LEFT(COALESCE(NULLIF(RTRIM(LTRIM(CL.TELEFONO)), ''), NULLIF(RTRIM(LTRIM(C.ds_cliente_tel)), ''), ''), 25) AS telefono_nuevo
FROM dbo.Cotizacion C
CROSS APPLY (
    SELECT TOP 1 IDCLIENTE, IDTERCERO, CIUDAD, TELEFONO, DIRECCION
    FROM dbo.CLIENTES CL WITH (NOLOCK)
    WHERE RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) 
       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_cliente_codigo))
       OR RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_tercero_codigo))
       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_tercero_codigo))
    ORDER BY 
       CASE WHEN RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) THEN 0 ELSE 1 END,
       CL.IDCLIENTE ASC
) CL
WHERE C.ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(C.ds_cliente_ciudad)) = ''
   OR C.ds_cliente_tel IS NULL OR RTRIM(LTRIM(C.ds_cliente_tel)) = ''
   OR (RTRIM(LTRIM(C.ds_cliente_ciudad)) = 'BOGOTA' AND NULLIF(RTRIM(LTRIM(CL.CIUDAD)), '') IS NOT NULL AND UPPER(RTRIM(LTRIM(CL.CIUDAD))) <> 'BOGOTA')
ORDER BY C.cd_consecutivo ASC;

-- 2. Actualizar Ciudad, Teléfono, Dirección e id_sys_entidades en dbo.Cotizacion desde dbo.CLIENTES
UPDATE C
SET 
    C.ds_cliente_ciudad = LEFT(
        COALESCE(
            NULLIF(RTRIM(LTRIM(CL.CIUDAD)), ''),
            NULLIF(RTRIM(LTRIM(C.ds_cliente_ciudad)), ''),
            'BOGOTA'
        ), 40
    ),
    C.ds_cliente_tel = LEFT(
        COALESCE(
            NULLIF(RTRIM(LTRIM(CL.TELEFONO)), ''),
            NULLIF(RTRIM(LTRIM(C.ds_cliente_tel)), ''),
            ''
        ), 25
    ),
    C.ds_cliente_dir = LEFT(
        COALESCE(
            NULLIF(RTRIM(LTRIM(C.ds_cliente_dir)), ''),
            NULLIF(RTRIM(LTRIM(CL.DIRECCION)), ''),
            ''
        ), 250
    ),
    C.id_sys_entidades = COALESCE(NULLIF(C.id_sys_entidades, 0), 65)
FROM dbo.Cotizacion C
CROSS APPLY (
    SELECT TOP 1 IDCLIENTE, IDTERCERO, CIUDAD, TELEFONO, DIRECCION
    FROM dbo.CLIENTES CL WITH (NOLOCK)
    WHERE RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) 
       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_cliente_codigo))
       OR RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_tercero_codigo))
       OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(C.cd_tercero_codigo))
    ORDER BY 
       CASE WHEN RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(C.cd_cliente_codigo)) THEN 0 ELSE 1 END,
       CL.IDCLIENTE ASC
) CL
WHERE C.ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(C.ds_cliente_ciudad)) = ''
   OR C.ds_cliente_tel IS NULL OR RTRIM(LTRIM(C.ds_cliente_tel)) = ''
   OR (RTRIM(LTRIM(C.ds_cliente_ciudad)) = 'BOGOTA' AND NULLIF(RTRIM(LTRIM(CL.CIUDAD)), '') IS NOT NULL AND UPPER(RTRIM(LTRIM(CL.CIUDAD))) <> 'BOGOTA');

-- 3. Verificación posterior
SELECT 
    cd_consecutivo,
    cd_cliente_codigo,
    ds_cliente_nombre,
    ds_cliente_ciudad,
    ds_cliente_tel,
    ds_cliente_dir
FROM dbo.Cotizacion
ORDER BY cd_consecutivo ASC;
