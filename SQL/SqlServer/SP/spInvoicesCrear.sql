-- 2.26. spInvoicesCrear
IF OBJECT_ID('dbo.spInvoicesCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spInvoicesCrear;
GO

CREATE PROCEDURE dbo.spInvoicesCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_invoice_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Invoices])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Invoices]', RESEED, 0);
        END

        DECLARE @clientId INT = JSON_VALUE(@p_data, '$.clientId');
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = JSON_VALUE(@p_data, '$.branchId');
        DECLARE @implantId INT = JSON_VALUE(@p_data, '$.implantId');
        DECLARE @sellerId INT = JSON_VALUE(@p_data, '$.sellerId');
        DECLARE @ticketPrinterId INT = JSON_VALUE(@p_data, '$.ticketPrinterId');
        DECLARE @totalAmount FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @fuente NVARCHAR(20) = ISNULL(JSON_VALUE(@p_data, '$.fuente'), 'FAC');
        DECLARE @serie NVARCHAR(20) = JSON_VALUE(@p_data, '$.serie');
        DECLARE @consecutivo NVARCHAR(50) = JSON_VALUE(@p_data, '$.consecutivo');
        DECLARE @date DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.date') AS DATETIME2);
        DECLARE @dueDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.dueDate') AS DATETIME2);

        IF @date IS NULL SET @date = GETDATE();
        IF @dueDate IS NULL SET @dueDate = @date;

        DECLARE @actingUserId INT = @p_acting_user_id;
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId)
            SET @clientId = NULL;
        IF @branchId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Branch] WHERE id = @branchId)
            SET @branchId = NULL;
        IF @sellerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Seller] WHERE id = @sellerId)
            SET @sellerId = NULL;
        IF @implantId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Implant] WHERE id = @implantId)
            SET @implantId = NULL;
        IF @ticketPrinterId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketPrinter] WHERE id = @ticketPrinterId)
            SET @ticketPrinterId = NULL;

        IF @consecutivo IS NULL OR LTRIM(RTRIM(@consecutivo)) = ''
        BEGIN
            EXEC dbo.spObtenerSiguienteConsecutivo N'INVOICE', @branchId, @implantId, @consecutivo OUTPUT;
        END

        DECLARE @internalNumber NVARCHAR(100) = CASE 
            WHEN @serie IS NOT NULL AND LTRIM(RTRIM(@serie)) <> '' THEN CONCAT(@serie, '-', @consecutivo)
            ELSE @consecutivo
        END;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Invoices] (
            [internalNumber], [date], [dueDate], [clientId], [currency], [exchangeRate],
            [branchId], [implantId], [sellerId], [ticketPrinterId],
            [baseCommissionable], [commissionPercentage], [chargesAndTaxes],
            [totalAmount], [userId], [state], [fuente], [serie], [consecutivo], [isExcelImport]
        ) VALUES (
            @internalNumber, @date, @dueDate, @clientId, @currency, @exchangeRate,
            @branchId, @implantId, @sellerId, @ticketPrinterId,
            @baseCommissionable, @commissionPercentage, @chargesAndTaxes,
            @totalAmount, @actingUserId, N'NUEVO', @fuente, @serie, @consecutivo, 0
        );

        SET @p_invoice_id = SCOPE_IDENTITY();

        -- Inserción de Combos
        IF JSON_QUERY(@p_data, '$.combos') IS NOT NULL
        BEGIN
            INSERT INTO dbo.[InvoicesProductCombo] ([invoiceId], [comboId])
            SELECT @p_invoice_id, CAST(JSON_VALUE(value, '$.comboId') AS INT)
            FROM OPENJSON(@p_data, '$.combos')
            WHERE JSON_VALUE(value, '$.comboId') IS NOT NULL;
        END;

        -- Inserción de Items (InvoicesProduct)
        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT [key], [value]
            FROM OPENJSON(@p_data, '$.items');

            OPEN item_cursor;
            DECLARE @itemKey NVARCHAR(50), @itemJson NVARCHAR(MAX);

            FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @prodId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.productId') AS INT);
                DECLARE @provId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.providerId') AS INT);
                DECLARE @prestId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.prestadoraId') AS INT);
                DECLARE @ticketCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.ticketCode');
                DECLARE @qty INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.cost') AS FLOAT), 0);
                DECLARE @checkIn DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkIn') AS DATETIME2);
                DECLARE @checkOut DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@itemJson, '$.nights') AS INT);
                DECLARE @paxAdults INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxAdults') AS INT), 1);
                DECLARE @paxChildren INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.paxChildren') AS INT), 0);
                DECLARE @srvType NVARCHAR(100) = JSON_VALUE(@itemJson, '$.serviceType');
                DECLARE @dest NVARCHAR(250) = JSON_VALUE(@itemJson, '$.destination');
                DECLARE @resCode NVARCHAR(100) = JSON_VALUE(@itemJson, '$.reservationCode');
                DECLARE @sComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.sellerCommission') AS FLOAT), 0);
                DECLARE @tpComm FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.ticketPrinterCommission') AS FLOAT), 0);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.mainTaxId') AS INT);
                DECLARE @inNat INT = ISNULL(TRY_CAST(JSON_VALUE(@itemJson, '$.inNationality') AS INT), 1);
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = ISNULL(JSON_VALUE(@itemJson, '$.descripcion'), JSON_VALUE(@itemJson, '$.itemDescription'));
                DECLARE @itin NVARCHAR(MAX) = JSON_VALUE(@itemJson, '$.itinerary');
                DECLARE @class NVARCHAR(50) = JSON_VALUE(@itemJson, '$.class');
                DECLARE @airline NVARCHAR(100) = JSON_VALUE(@itemJson, '$.airline');
                DECLARE @ticketTypeId INT = TRY_CAST(JSON_VALUE(@itemJson, '$.ticketTypeId') AS INT);
                DECLARE @provDueDate DATETIME2 = TRY_CAST(JSON_VALUE(@itemJson, '$.providerDueDate') AS DATETIME2);
                DECLARE @provInvoice NVARCHAR(100) = JSON_VALUE(@itemJson, '$.providerInvoice');

                IF @prodId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Product] WHERE id = @prodId) SET @prodId = NULL;
                IF @provId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @provId) SET @provId = NULL;
                IF @prestId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestId) SET @prestId = NULL;
                IF @ticketTypeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[TicketType] WHERE id = @ticketTypeId) SET @ticketTypeId = NULL;

                INSERT INTO dbo.[InvoicesProduct] (
                    [invoiceId], [productId], [ticketCode], [quantity], [price], [cost],
                    [providerId], [prestadoraId], [checkInDate], [checkOutDate], [nights],
                    [paxAdults], [paxChildren], [serviceType], [destination], [reservationCode],
                    [sellerCommission], [ticketPrinterCommission], [comboId], [mainTaxId], [inNationality],
                    [servicios], [descripcion], [itinerary], [class], [airline], [ticketTypeId],
                    [providerDueDate], [providerInvoice]
                ) VALUES (
                    @p_invoice_id, @prodId, @ticketCode, @qty, @price, @cost,
                    @provId, @prestId, @checkIn, @checkOut, @nights,
                    @paxAdults, @paxChildren, @srvType, @dest, @resCode,
                    @sComm, @tpComm, @comboId, @mainTaxId, @inNat,
                    @servicios, @descripcion, @itin, @class, @airline, @ticketTypeId,
                    @provDueDate, @provInvoice
                );

                DECLARE @newIpId INT = SCOPE_IDENTITY();

                -- Impuestos del Item
                IF JSON_QUERY(@itemJson, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductTax] ([invoiceProductId], [chargeAndTaxId], [explicitAmount], [rate], [valueSnapshot], [valueTypeSnapshot], [isMain])
                    SELECT 
                        @newIpId,
                        TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT),
                        ISNULL(TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.explicitAmount'), JSON_VALUE(tax.value, '$.amount')) AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.rate') AS FLOAT), 0),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'PERCENTAGE'),
                        CASE WHEN TRY_CAST(ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@itemJson, '$.appliedTaxes') AS tax
                    WHERE ISNULL(JSON_VALUE(tax.value, '$.chargeAndTaxId'), JSON_VALUE(tax.value, '$.id')) IS NOT NULL;
                END;

                -- Pasajeros del Item
                IF JSON_QUERY(@itemJson, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPasenger] ([invoiceProductId], [name], [document])
                    SELECT @newIpId, JSON_VALUE(pax.value, '$.name'), JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@itemJson, '$.passengers') AS pax;
                END;

                -- Variables del Item
                IF JSON_QUERY(@itemJson, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductVariable] ([invoiceProductId], [masterVariableId], [value])
                    SELECT 
                        @newIpId,
                        TRY_CAST(JSON_VALUE(vr.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(vr.value, '$.value')
                    FROM OPENJSON(@itemJson, '$.variables') AS vr
                    WHERE JSON_VALUE(vr.value, '$.masterVariableId') IS NOT NULL;
                END;

                -- Pagos del Item
                IF JSON_QUERY(@itemJson, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductPayment] (
                        [invoiceProductId], [amount], [paymentMethod], [date], [reference],
                        [creditCardId], [authorizationCode], [voucher], [cardNumber], [expirationDate]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(pay.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pay.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pay.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pay.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pay.value, '$.authorizationCode'),
                        JSON_VALUE(pay.value, '$.voucher'),
                        JSON_VALUE(pay.value, '$.cardNumber'),
                        JSON_VALUE(pay.value, '$.expirationDate')
                    FROM OPENJSON(@itemJson, '$.payments') AS pay;
                END;

                -- Itinerarios del Item
                IF JSON_QUERY(@itemJson, '$.itinerariesItineraryList') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[InvoicesProductItinerary] (
                        [invoiceProductId], [orden], [origin], [destination], [class],
                        [checkInDate], [checkOutDate], [terminal], [prestadoraCode], [farebasis],
                        [Numflight], [Typeflight], [amount], [co2]
                    )
                    SELECT 
                        @newIpId,
                        ISNULL(TRY_CAST(JSON_VALUE(itin.value, '$.orden') AS INT), 1),
                        JSON_VALUE(itin.value, '$.origin'),
                        JSON_VALUE(itin.value, '$.destination'),
                        JSON_VALUE(itin.value, '$.class'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkInDate') AS DATETIME2),
                        TRY_CAST(JSON_VALUE(itin.value, '$.checkOutDate') AS DATETIME2),
                        JSON_VALUE(itin.value, '$.terminal'),
                        JSON_VALUE(itin.value, '$.prestadoraCode'),
                        JSON_VALUE(itin.value, '$.farebasis'),
                        JSON_VALUE(itin.value, '$.Numflight'),
                        JSON_VALUE(itin.value, '$.Typeflight'),
                        TRY_CAST(JSON_VALUE(itin.value, '$.amount') AS FLOAT),
                        TRY_CAST(JSON_VALUE(itin.value, '$.co2') AS FLOAT)
                    FROM OPENJSON(@itemJson, '$.itinerariesItineraryList') AS itin;
                END;

                FETCH NEXT FROM item_cursor INTO @itemKey, @itemJson;
            END;

            CLOSE item_cursor;
            DEALLOCATE item_cursor;
        END;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Factura creada exitosamente con ID ', @p_invoice_id, N' y consecutivo ', @internalNumber);
        SELECT @p_invoice_id AS p_invoice_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_invoice_id = 0;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT @p_invoice_id AS p_invoice_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
