-- 2.39. spCotizacionDuplicar
IF OBJECT_ID('dbo.spCotizacionDuplicar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionDuplicar;
GO

CREATE PROCEDURE dbo.spCotizacionDuplicar
    @p_quotation_id INT,
    @p_acting_user_id INT = 1,
    @p_new_quotation_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_quotation_id)
        BEGIN
            SET @p_new_quotation_id = 0;
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización origen no encontrada (ID ', @p_quotation_id, N').');
            SELECT 0 AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, NULL AS internalNumber;
            RETURN;
        END;

        DECLARE @userId INT = @p_acting_user_id;
        IF @userId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @userId)
            SET @userId = NULL;

        DECLARE @branchId INT, @implantId INT;
        SELECT @branchId = branchId, @implantId = implantId FROM dbo.[Quotation] WHERE id = @p_quotation_id;

        DECLARE @internalNumber NVARCHAR(100) = NULL;
        EXEC dbo.spObtenerSiguienteConsecutivo N'QUOTATION', @branchId, @implantId, @internalNumber OUTPUT;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Quotation] (
            internalNumber, [date], clientId, currency, exchangeRate,
            branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, commissionPercentage, chargesAndTaxes,
            totalAmount, userId, state, stateDescription, stateUpdatedAt,
            costoTotal, valorBase, utilidad, comisionTotalPercentage,
            comisionFreelancePercentage, comisionFreelanceValue,
            comisionPropiaPercentage, comisionPropiaValue, comisionUtilidadPercentage,
            destination, startDate, endDate, passenger, paxAdults, paxChildren,
            reservationCode, copyFieldsToProducts, manualDescription
        )
        SELECT
            ISNULL(@internalNumber, N'TEMP'), GETDATE(), clientId, currency, exchangeRate,
            branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, commissionPercentage, chargesAndTaxes,
            totalAmount, ISNULL(@userId, userId), N'NUEVO', CONCAT(N'Copia de cotización #', CAST(@p_quotation_id AS NVARCHAR(20))), GETDATE(),
            costoTotal, valorBase, utilidad, comisionTotalPercentage,
            comisionFreelancePercentage, comisionFreelanceValue,
            comisionPropiaPercentage, comisionPropiaValue, comisionUtilidadPercentage,
            destination, startDate, endDate, passenger, paxAdults, paxChildren,
            reservationCode, copyFieldsToProducts, manualDescription
        FROM dbo.[Quotation]
        WHERE id = @p_quotation_id;

        SET @p_new_quotation_id = SCOPE_IDENTITY();

        IF @internalNumber IS NULL OR @internalNumber = N'TEMP'
        BEGIN
            SET @internalNumber = CAST(@p_new_quotation_id AS NVARCHAR(50));
            UPDATE dbo.[Quotation]
            SET internalNumber = @internalNumber
            WHERE id = @p_new_quotation_id;
        END;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, state, [description], createdAt, userId)
        VALUES (@p_new_quotation_id, N'NUEVO', CONCAT(N'Copia de cotización #', CAST(@p_quotation_id AS NVARCHAR(20))), GETDATE(), @userId);

        -- Duplicar combos
        IF OBJECT_ID('dbo.QuotationCombo', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[QuotationCombo] (quotationId, comboId)
            SELECT @p_new_quotation_id, comboId
            FROM dbo.[QuotationCombo]
            WHERE quotationId = @p_quotation_id;
        END;

        -- Duplicar servicios manuales
        IF OBJECT_ID('dbo.QuotationManualService', 'U') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[QuotationManualService] (quotationId, providerName, serviceName, cost, salePrice, utility, createdAt)
            SELECT @p_new_quotation_id, providerName, serviceName, cost, salePrice, utility, GETDATE()
            FROM dbo.[QuotationManualService]
            WHERE quotationId = @p_quotation_id;
        END;

        -- Duplicar productos
        DECLARE @origQpId INT, @newQpId INT;
        DECLARE qp_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_quotation_id;

        OPEN qp_cursor;
        FETCH NEXT FROM qp_cursor INTO @origQpId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.[QuotationProduct] (
                quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                checkInDate, checkOutDate, nights, paxAdults, paxChildren,
                serviceType, destination, reservationCode, sellerCommission,
                ticketPrinterCommission, comboId, mainTaxId, inNationality,
                service, servicios, descripcion, description, passenger,
                providerDueDate, providerInvoice
            )
            SELECT
                @p_new_quotation_id, productId, quantity, price, cost, providerId, prestadoraId,
                checkInDate, checkOutDate, nights, paxAdults, paxChildren,
                serviceType, destination, reservationCode, sellerCommission,
                ticketPrinterCommission, comboId, mainTaxId, inNationality,
                service, servicios, descripcion, description, passenger,
                providerDueDate, providerInvoice
            FROM dbo.[QuotationProduct]
            WHERE id = @origQpId;

            SET @newQpId = SCOPE_IDENTITY();

            -- Duplicar pasajeros
            INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, [name], document)
            SELECT @newQpId, [name], document
            FROM dbo.[QuotationProductPassenger]
            WHERE quotationProductId = @origQpId;

            -- Duplicar impuestos
            INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
            SELECT @newQpId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain
            FROM dbo.[QuotationProductTax]
            WHERE quotationProductId = @origQpId;

            -- Duplicar variables
            INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, [value])
            SELECT @newQpId, masterVariableId, [value]
            FROM dbo.[QuotationProductVariable]
            WHERE quotationProductId = @origQpId;

            -- Duplicar pagos
            INSERT INTO dbo.[QuotationProductPayment] (quotationProductId, amount, paymentMethod, reference, [date], creditCardId, cardNumber, authorizationCode, voucher, expirationDate)
            SELECT @newQpId, amount, paymentMethod, reference, [date], creditCardId, cardNumber, authorizationCode, voucher, expirationDate
            FROM dbo.[QuotationProductPayment]
            WHERE quotationProductId = @origQpId;

            FETCH NEXT FROM qp_cursor INTO @origQpId;
        END;

        CLOSE qp_cursor;
        DEALLOCATE qp_cursor;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización duplicada correctamente con ID ', @p_new_quotation_id);
        SELECT @p_new_quotation_id AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, @internalNumber AS internalNumber;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_new_quotation_id = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_new_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado, NULL AS internalNumber;
    END CATCH;
END;
GO
