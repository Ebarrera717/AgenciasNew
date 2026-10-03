-- ============================================================================
-- AGENCIASNEW - LIMPIADOR DE MOVIMIENTOS EN SQL SERVER
-- Procedimiento: dbo.spLimpiarMovimientosProduccion
-- ============================================================================

IF OBJECT_ID('dbo.spLimpiarMovimientosProduccion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spLimpiarMovimientosProduccion;
GO

CREATE PROCEDURE dbo.spLimpiarMovimientosProduccion
    @p_mensaje_resultado NVARCHAR(4000) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @tables TABLE (id INT IDENTITY(1,1), tableName NVARCHAR(128));
        
        -- Orden respetando dependencias de llaves foráneas
        INSERT INTO @tables (tableName) VALUES
        ('QuotationProductTax'), ('QuotationProductVariable'), ('QuotationProductPassenger'),
        ('QuotationProductPayment'), ('QuotationCombo'), ('QuotationInvoice'),
        ('QuotationStateHistory'), ('QuotationPrintCustomization'), ('QuotationManualService'),
        ('QuotationProduct'), ('Quotation'), 
        ('PreQuotationStateHistory'), ('PreQuotation'),
        ('InvoicesProductTax'), ('InvoicesProductVariable'), ('InvoicesProductPasenger'),
        ('InvoicesProductPayment'), ('InvoicesProductCombo'), ('InvoicesProductItinerary'),
        ('InvoicesProduct'), ('Invoices'), ('Invoice'),
        ('BookingProductGDS'), ('BookingProductItineraryGDS'), ('BookingProductPassangerGDS'),
        ('BookingProductTaxGDS'), ('BookingProductVariableGDS'), ('BookingProductFEEGDS'),
        ('BookingProductPaymentGDS'), ('BookingsGDSInvoiceAuto'), ('BookingGDSInvoiceAutoLog'),
        ('BranchGDSInvoiceAuto'), ('BookingsGDS_log'), ('BookingGDS'),
        ('SystemLog'), ('ExecutionPreset'), ('ExecutionProcedure'), ('Attachment'),
        ('EquivalenciasInterfaces_Log');

        DECLARE @tbl NVARCHAR(128);
        DECLARE @sqlCmd NVARCHAR(MAX);
        DECLARE curTbl CURSOR LOCAL FAST_FORWARD FOR SELECT tableName FROM @tables ORDER BY id ASC;
        OPEN curTbl;
        FETCH NEXT FROM curTbl INTO @tbl;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF OBJECT_ID('dbo.' + @tbl, 'U') IS NOT NULL
            BEGIN
                SET @sqlCmd = N'DELETE FROM dbo.[' + @tbl + N'];';
                EXEC sp_executesql @sqlCmd;

                IF OBJECTPROPERTY(OBJECT_ID('dbo.' + @tbl), 'TableHasIdentity') = 1
                BEGIN
                    BEGIN TRY
                        SET @sqlCmd = N'DBCC CHECKIDENT (''dbo.[' + @tbl + N']'', RESEED, 0) WITH NO_INFOMSGS;';
                        EXEC sp_executesql @sqlCmd;
                    END TRY
                    BEGIN CATCH
                    END CATCH;
                END;
            END;
            FETCH NEXT FROM curTbl INTO @tbl;
        END;
        CLOSE curTbl;
        DEALLOCATE curTbl;

        IF OBJECT_ID('dbo.TransactionConsecutive', 'U') IS NOT NULL
        BEGIN
            UPDATE dbo.[TransactionConsecutive]
            SET [currentNumber] = COALESCE([initialNumber], 1);
        END;

        SET @p_mensaje_resultado = 'SUCCESS: Tablas de movimientos vaciadas e IDENTITIES/consecutivos reiniciados a 1 en SQL Server.';
    END TRY
    BEGIN CATCH
        SET @p_mensaje_resultado = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH;
END
GO
