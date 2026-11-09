SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.spCotizacionEliminarZeus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionEliminarZeus;
GO

CREATE OR ALTER PROCEDURE dbo.spCotizacionEliminarZeus
(
    @cd_consecutivo VARCHAR(50) = NULL,
    @id_cotizacion INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @res_id_cotizacion INT = NULL;
    DECLARE @res_consecutivo VARCHAR(50) = NULL;
    DECLARE @res_estado INT = NULL;
    DECLARE @res_cliente VARCHAR(250) = NULL;

    -- 1. Identificar la cotización en Zeus ERP por ID o por Consecutivo (con o sin padding de ceros)
    SELECT TOP 1 
        @res_id_cotizacion = id,
        @res_consecutivo = LTRIM(RTRIM(cd_consecutivo)),
        @res_estado = in_estado,
        @res_cliente = ds_cliente_nombre
    FROM dbo.Cotizacion WITH (NOLOCK)
    WHERE (@id_cotizacion IS NOT NULL AND id = @id_cotizacion)
       OR (@cd_consecutivo IS NOT NULL AND LTRIM(RTRIM(cd_consecutivo)) = LTRIM(RTRIM(@cd_consecutivo)))
       OR (@cd_consecutivo IS NOT NULL AND LTRIM(RTRIM(cd_consecutivo)) = RIGHT('00000000' + LTRIM(RTRIM(@cd_consecutivo)), 8))
       OR (@cd_consecutivo IS NOT NULL AND ISNUMERIC(@cd_consecutivo) = 1 AND TRY_CAST(cd_consecutivo AS INT) = TRY_CAST(@cd_consecutivo AS INT));

    IF @res_id_cotizacion IS NULL
    BEGIN
        SELECT 
            'La cotización ' + ISNULL(@cd_consecutivo, CAST(@id_cotizacion AS VARCHAR)) + ' no existe en la base de datos de Zeus ERP.' AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            NULL AS IdZeusEliminado,
            NULL AS ConsecutivoEliminado;
        RETURN 1;
    END

    -- 2. VALIDAR SI ESTÁ FACTURADA O LIQUIDADA EN ZEUS ERP
    -- 2.1 Por estado en cabecera Cotizacion (in_estado = 2 'Parcialmente Liquidada' o 3 'Liquidada')
    IF @res_estado IN (2, 3)
    BEGIN
        SELECT 
            '❌ No se puede eliminar: La cotización #' + @res_consecutivo + ' se encuentra ' + 
            CASE @res_estado WHEN 2 THEN 'Parcialmente Liquidada' WHEN 3 THEN 'Liquidada/Facturada' ELSE 'Facturada' END + 
            ' en Zeus ERP.' AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
        RETURN 1;
    END

    -- 2.2 Por referencia de factura o remisión en CotizacionServicios
    IF EXISTS (
        SELECT 1 FROM dbo.CotizacionServicios WITH (NOLOCK)
        WHERE id_Cotizacion = @res_id_cotizacion 
          AND (
            (id_fac_factura IS NOT NULL AND id_fac_factura > 0)
            OR (id_fac_remision IS NOT NULL AND id_fac_remision > 0)
            OR (id_fac_facturaComision IS NOT NULL AND id_fac_facturaComision > 0)
          )
    )
    BEGIN
        SELECT 
            '❌ No se puede eliminar: La cotización #' + @res_consecutivo + ' ya cuenta con servicios asociados a facturas o remisiones en Zeus ERP.' AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
        RETURN 1;
    END

    -- 2.3 Por referencia en Fac_Servicios (ítems facturados en Zeus ERP)
    IF EXISTS (
        SELECT 1 FROM dbo.Fac_Servicios fs WITH (NOLOCK)
        INNER JOIN dbo.CotizacionServicios cs WITH (NOLOCK) ON fs.id_CotizacionServicios = cs.id
        WHERE cs.id_Cotizacion = @res_id_cotizacion
    )
    BEGIN
        SELECT 
            '❌ No se puede eliminar: Existen servicios facturados en Zeus ERP vinculados a esta cotización.' AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
        RETURN 1;
    END

    -- 2.4 Por comisiones liquidadas de facturas
    IF OBJECT_ID('dbo.ComisionesFacturas') IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.ComisionesFacturas WITH (NOLOCK) WHERE id_cotizacion = @res_id_cotizacion)
       OR (OBJECT_ID('dbo.ComisionesFacturasDetalle') IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.ComisionesFacturasDetalle WITH (NOLOCK) WHERE id_cotizacion = @res_id_cotizacion))
    BEGIN
        SELECT 
            '❌ No se puede eliminar: La cotización #' + @res_consecutivo + ' tiene registros de comisiones de facturas en Zeus ERP.' AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
        RETURN 1;
    END

    -- 3. ELIMINACIÓN SEGURA EN TRANSACCIÓN ATÓMICA
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Tabla temporal para almacenar los IDs de los servicios de esta cotización
        DECLARE @tblServicios TABLE (id INT PRIMARY KEY);
        INSERT INTO @tblServicios (id)
        SELECT id FROM dbo.CotizacionServicios WHERE id_Cotizacion = @res_id_cotizacion;

        -- A. Eliminar tablas hijas de CotizacionServicios
        IF OBJECT_ID('dbo.CotizacionServicios_PaxAdicional') IS NOT NULL
            DELETE FROM dbo.CotizacionServicios_PaxAdicional WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios) OR id_Cotizacion = @res_id_cotizacion;

        -- Eliminar CotizacionImpuestos antes de eliminar CotizacionCargos
        IF OBJECT_ID('dbo.CotizacionImpuestos') IS NOT NULL
            DELETE FROM dbo.CotizacionImpuestos 
            WHERE id_CotizacionCargos IN (
                SELECT id FROM dbo.CotizacionCargos WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios)
            );

        IF OBJECT_ID('dbo.CotizacionCargos') IS NOT NULL
            DELETE FROM dbo.CotizacionCargos WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.CotizacionServiciosFormasPago') IS NOT NULL
            DELETE FROM dbo.CotizacionServiciosFormasPago WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.Fac_Servicios_TiposFacturacionHoteles') IS NOT NULL
            DELETE FROM dbo.Fac_Servicios_TiposFacturacionHoteles WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.CotizacionServicios_TipoProv') IS NOT NULL
            DELETE FROM dbo.CotizacionServicios_TipoProv WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.CotizacionServicios_VoucherAdicional') IS NOT NULL
            DELETE FROM dbo.CotizacionServicios_VoucherAdicional WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios) OR id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.CotizacionServicios_TiquetesAdicionales') IS NOT NULL
            DELETE FROM dbo.CotizacionServicios_TiquetesAdicionales WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios) OR id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Fac_Servicios_CargoTipoPlan') IS NOT NULL
            DELETE FROM dbo.Fac_Servicios_CargoTipoPlan WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.Servicios_ProveedoresAdicionales') IS NOT NULL
            DELETE FROM dbo.Servicios_ProveedoresAdicionales WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.CotizacionesPagosComision') IS NOT NULL
            DELETE FROM dbo.CotizacionesPagosComision WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios) OR id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Fac_ServiciosImagen') IS NOT NULL
            DELETE FROM dbo.Fac_ServiciosImagen WHERE id_CotizacionServicios IN (SELECT id FROM @tblServicios);

        IF OBJECT_ID('dbo.VariableDatosMaestro') IS NOT NULL
            DELETE FROM dbo.VariableDatosMaestro 
            WHERE CodigoMaestro IN (SELECT cd_Consecutivo_VariablesAdicionales FROM dbo.CotizacionServicios WHERE id_Cotizacion = @res_id_cotizacion AND cd_Consecutivo_VariablesAdicionales IS NOT NULL);

        -- B. Eliminar tablas hijas directas de Cotizacion
        IF OBJECT_ID('dbo.EmailTiempoRespuestaGuiaCotizaciones') IS NOT NULL
            DELETE FROM dbo.EmailTiempoRespuestaGuiaCotizaciones WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_SeguimientoCliente') IS NOT NULL
            DELETE FROM dbo.Cotizacion_SeguimientoCliente WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_Solicitud') IS NOT NULL
            DELETE FROM dbo.Cotizacion_Solicitud WHERE Id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.CotizacionOrdenesPago') IS NOT NULL
            DELETE FROM dbo.CotizacionOrdenesPago WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_Seguimiento') IS NOT NULL
            DELETE FROM dbo.Cotizacion_Seguimiento WHERE id_cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_GrConcepto') IS NOT NULL
            DELETE FROM dbo.Cotizacion_GrConcepto WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.CotizacionFormatosAdicionales') IS NOT NULL
            DELETE FROM dbo.CotizacionFormatosAdicionales WHERE id_cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.CotizacionFormatosAdicionalesItineracio') IS NOT NULL
            DELETE FROM dbo.CotizacionFormatosAdicionalesItineracio WHERE id_cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Fac_DepartItems') IS NOT NULL
            DELETE FROM dbo.Fac_DepartItems WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Fac_ReferidosItems') IS NOT NULL
            DELETE FROM dbo.Fac_ReferidosItems WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_radicacion') IS NOT NULL
            DELETE FROM dbo.Cotizacion_radicacion WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.CotizacionCambioAutoEtapas') IS NOT NULL
            DELETE FROM dbo.CotizacionCambioAutoEtapas WHERE id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.JobEmail_Log') IS NOT NULL
            DELETE FROM dbo.JobEmail_Log WHERE Id_Cotizacion = @res_id_cotizacion;

        IF OBJECT_ID('dbo.Cotizacion_Opciones') IS NOT NULL
            DELETE FROM dbo.Cotizacion_Opciones WHERE id_cotizacion = @res_id_cotizacion;

        -- C. Eliminar servicios de cotización
        DELETE FROM dbo.CotizacionServicios WHERE id_Cotizacion = @res_id_cotizacion;

        -- D. Eliminar cabecera de cotización
        DELETE FROM dbo.Cotizacion WHERE id = @res_id_cotizacion;

        COMMIT TRANSACTION;

        SELECT 
            '✅ Cotización #' + @res_consecutivo + ' (ID Zeus: #' + CAST(@res_id_cotizacion AS VARCHAR) + ') eliminada exitosamente de Zeus ERP.' AS Respuesta,
            0 AS Estado,
            1 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @errMsg VARCHAR(MAX) = ERROR_MESSAGE();
        SELECT 
            '❌ Error al eliminar cotización en Zeus ERP: ' + @errMsg AS Respuesta,
            1 AS Estado,
            0 AS Eliminado,
            @res_id_cotizacion AS IdZeusEliminado,
            @res_consecutivo AS ConsecutivoEliminado;
        RETURN 1;
    END CATCH
END;
GO
