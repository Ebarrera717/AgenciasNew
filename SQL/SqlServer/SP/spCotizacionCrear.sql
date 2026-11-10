-- 2.37. spCotizacionCrear
IF OBJECT_ID('dbo.spCotizacionCrear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionCrear;
GO

CREATE PROCEDURE dbo.spCotizacionCrear
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_quotation_id INT = NULL OUTPUT,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])
        BEGIN
            DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);
        END;

        DECLARE @clientId INT = TRY_CAST(JSON_VALUE(@p_data, '$.clientId') AS INT);
        DECLARE @currency NVARCHAR(10) = ISNULL(JSON_VALUE(@p_data, '$.currency'), 'COP');
        DECLARE @exchangeRate FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.exchangeRate') AS FLOAT), 1);
        DECLARE @branchId INT = TRY_CAST(JSON_VALUE(@p_data, '$.branchId') AS INT);
        DECLARE @implantId INT = TRY_CAST(JSON_VALUE(@p_data, '$.implantId') AS INT);
        DECLARE @sellerId INT = TRY_CAST(JSON_VALUE(@p_data, '$.sellerId') AS INT);
        DECLARE @ticketPrinterId INT = TRY_CAST(JSON_VALUE(@p_data, '$.ticketPrinterId') AS INT);
        DECLARE @totalAmount FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.totalAmount') AS FLOAT), 0);
        DECLARE @baseCommissionable FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.baseCommissionable') AS FLOAT), 0);
        DECLARE @chargesAndTaxes FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.chargesAndTaxes') AS FLOAT), 0);
        DECLARE @commissionPercentage FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.commissionPercentage') AS FLOAT), 0);
        DECLARE @destination NVARCHAR(250) = JSON_VALUE(@p_data, '$.destination');
        DECLARE @startDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.startDate') AS DATETIME2);
        DECLARE @endDate DATETIME2 = TRY_CAST(JSON_VALUE(@p_data, '$.endDate') AS DATETIME2);
        DECLARE @passenger NVARCHAR(250) = JSON_VALUE(@p_data, '$.passenger');
        DECLARE @passengerFirstName NVARCHAR(150) = JSON_VALUE(@p_data, '$.passengerFirstName');
        DECLARE @passengerLastName NVARCHAR(150) = JSON_VALUE(@p_data, '$.passengerLastName');

        IF @passengerFirstName IS NULL AND @passengerLastName IS NULL AND NULLIF(LTRIM(RTRIM(@passenger)), '') IS NOT NULL
        BEGIN
            IF CHARINDEX(' ', LTRIM(RTRIM(@passenger))) = 0
                SET @passengerFirstName = LTRIM(RTRIM(@passenger));
            ELSE
            BEGIN
                SET @passengerFirstName = SUBSTRING(LTRIM(RTRIM(@passenger)), 1, CHARINDEX(' ', LTRIM(RTRIM(@passenger))) - 1);
                SET @passengerLastName = SUBSTRING(LTRIM(RTRIM(@passenger)), CHARINDEX(' ', LTRIM(RTRIM(@passenger))) + 1, LEN(@passenger));
            END
        END;
        IF @passenger IS NULL AND (@passengerFirstName IS NOT NULL OR @passengerLastName IS NOT NULL)
            SET @passenger = LTRIM(RTRIM(CONCAT(ISNULL(@passengerFirstName, N''), N' ', ISNULL(@passengerLastName, N''))));
        DECLARE @paxAdults INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxAdults') AS INT);
        DECLARE @paxChildren INT = TRY_CAST(JSON_VALUE(@p_data, '$.paxChildren') AS INT);
        DECLARE @reservationCode NVARCHAR(100) = JSON_VALUE(@p_data, '$.reservationCode');
        DECLARE @manualDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.manualDescription');
        DECLARE @observations NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.observations');

        DECLARE @actingUserId INT = TRY_CAST(JSON_VALUE(@p_data, '$.userId') AS INT);
        IF @actingUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE id = @actingUserId)
            SET @actingUserId = NULL;

        IF @actingUserId IS NULL AND NULLIF(LTRIM(RTRIM(JSON_VALUE(@p_data, '$.userEmail'))), '') IS NOT NULL
        BEGIN
            SELECT TOP 1 @actingUserId = [id]
            FROM dbo.[User]
            WHERE LOWER(LTRIM(RTRIM([email]))) = LOWER(LTRIM(RTRIM(JSON_VALUE(@p_data, '$.userEmail'))))
            ORDER BY [id] ASC;
        END;

        IF @actingUserId IS NULL AND @p_acting_user_id IS NOT NULL
        BEGIN
            SELECT TOP 1 @actingUserId = [id] FROM dbo.[User] WHERE id = @p_acting_user_id;
        END;

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

        -- Si no vino usuario explícito en @p_data (o cayó en el fallback 1) y el Tiqueteador seleccionado corresponde a un Usuario del sistema, asignar ese Usuario creador
        IF (@actingUserId IS NULL OR (@actingUserId = 1 AND NULLIF(LTRIM(RTRIM(JSON_VALUE(@p_data, '$.userId'))), '') IS NULL AND NULLIF(LTRIM(RTRIM(JSON_VALUE(@p_data, '$.userEmail'))), '') IS NULL))
           AND @ticketPrinterId IS NOT NULL
        BEGIN
            DECLARE @tpUserId INT = NULL;
            SELECT TOP 1 @tpUserId = u.[id]
            FROM dbo.[TicketPrinter] tp
            JOIN dbo.[User] u ON (
                u.[ticketPrinterId] = tp.[id]
                OR (NULLIF(LTRIM(RTRIM(tp.[email])), '') IS NOT NULL AND LOWER(LTRIM(RTRIM(u.[email]))) = LOWER(LTRIM(RTRIM(tp.[email]))))
                OR (NULLIF(LTRIM(RTRIM(tp.[name])), '') IS NOT NULL AND UPPER(LTRIM(RTRIM(u.[name]))) = UPPER(LTRIM(RTRIM(tp.[name]))))
            )
            WHERE tp.[id] = @ticketPrinterId
            ORDER BY u.[id] ASC;

            IF @tpUserId IS NOT NULL
                SET @actingUserId = @tpUserId;
        END;

        DECLARE @internalNum NVARCHAR(100) = NULL;
        EXEC dbo.spObtenerSiguienteConsecutivo N'QUOTATION', @branchId, @implantId, @internalNum OUTPUT;

        -- Validación de variables adicionales obligatorias del cliente para cotizaciones
        IF @clientId IS NOT NULL
        BEGIN
            DECLARE @clientMandatoryVarsJson NVARCHAR(MAX) = (SELECT mandatoryVariables FROM dbo.[Client] WHERE id = @clientId);
            IF @clientMandatoryVarsJson IS NOT NULL AND ISJSON(@clientMandatoryVarsJson) = 1
            BEGIN
                DECLARE @reqVarList TABLE (varId INT);
                IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotation') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotation') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_QUERY(@clientMandatoryVarsJson, '$.quotations') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson, '$.quotations') WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END
                ELSE IF JSON_VALUE(@clientMandatoryVarsJson, '$[0]') IS NOT NULL
                BEGIN
                    INSERT INTO @reqVarList (varId)
                    SELECT TRY_CAST([value] AS INT) FROM OPENJSON(@clientMandatoryVarsJson) WHERE TRY_CAST([value] AS INT) IS NOT NULL;
                END;

                IF EXISTS (SELECT 1 FROM @reqVarList)
                BEGIN
                    DECLARE @reqVarId INT;
                    DECLARE req_var_cur CURSOR LOCAL FAST_FORWARD FOR
                    SELECT varId FROM @reqVarList;

                    OPEN req_var_cur;
                    FETCH NEXT FROM req_var_cur INTO @reqVarId;

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        DECLARE @reqVarName NVARCHAR(250) = (SELECT [name] FROM dbo.[MasterVariable] WHERE id = @reqVarId);
                        SET @reqVarName = ISNULL(@reqVarName, CONCAT(N'Variable #', @reqVarId));

                        IF EXISTS (
                            SELECT 1
                            FROM OPENJSON(@p_data, '$.items') AS itm
                            OUTER APPLY (
                                SELECT COUNT(1) AS cnt
                                FROM OPENJSON(itm.[value], '$.variables') AS v
                                WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                  AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                            ) vars
                            WHERE ISNULL(vars.cnt, 0) = 0
                        )
                        BEGIN
                            DECLARE @missingProdDesc NVARCHAR(250) = (
                                SELECT TOP 1 ISNULL(p.[description], CONCAT(N'Producto #', ISNULL(TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS NVARCHAR(50)), '1')))
                                FROM OPENJSON(@p_data, '$.items') AS itm
                                LEFT JOIN dbo.[Product] p ON p.id = TRY_CAST(JSON_VALUE(itm.[value], '$.productId') AS INT)
                                OUTER APPLY (
                                    SELECT COUNT(1) AS cnt
                                    FROM OPENJSON(itm.[value], '$.variables') AS v
                                    WHERE TRY_CAST(JSON_VALUE(v.[value], '$.masterVariableId') AS INT) = @reqVarId
                                      AND NULLIF(LTRIM(RTRIM(JSON_VALUE(v.[value], '$.value'))), '') IS NOT NULL
                                ) vars
                                WHERE ISNULL(vars.cnt, 0) = 0
                            );

                            SET @p_mensaje_resultado = CONCAT(N'ERROR: El cliente requiere completar la variable adicional "', @reqVarName, N'" en el producto "', ISNULL(@missingProdDesc, N'Producto'), N'".');
                            CLOSE req_var_cur;
                            DEALLOCATE req_var_cur;
                            RETURN;
                        END;

                        FETCH NEXT FROM req_var_cur INTO @reqVarId;
                    END;

                    CLOSE req_var_cur;
                    DEALLOCATE req_var_cur;
                END;
            END;
        END;

        BEGIN TRANSACTION;

        INSERT INTO dbo.[Quotation] (
            internalNumber, [date], clientId, currency, exchangeRate, branchId, implantId, sellerId, ticketPrinterId,
            baseCommissionable, chargesAndTaxes, totalAmount, commissionPercentage, userId, state, stateDescription, stateUpdatedAt,
            destination, startDate, endDate, passenger, passengerFirstName, passengerLastName, paxAdults, paxChildren, reservationCode, manualDescription, observations
        ) VALUES (
            ISNULL(@internalNum, N'TEMP'), GETDATE(), @clientId, @currency, @exchangeRate, @branchId, @implantId, @sellerId, @ticketPrinterId,
            @baseCommissionable, @chargesAndTaxes, @totalAmount, @commissionPercentage, @actingUserId, N'NUEVO', N'Creación de cotización', GETDATE(),
            @destination, @startDate, @endDate, @passenger, @passengerFirstName, @passengerLastName, @paxAdults, @paxChildren, @reservationCode, @manualDescription, @observations
        );

        SET @p_quotation_id = SCOPE_IDENTITY();

        IF @internalNum IS NULL OR @internalNum = N'TEMP'
        BEGIN
            UPDATE dbo.[Quotation]
            SET internalNumber = CAST(@p_quotation_id AS NVARCHAR(50))
            WHERE id = @p_quotation_id;
        END;

        INSERT INTO dbo.[QuotationStateHistory] (quotationId, state, [description], createdAt, userId)
        VALUES (@p_quotation_id, N'NUEVO', N'Creación de cotización', GETDATE(), @actingUserId);

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DECLARE @item_val NVARCHAR(MAX);
            DECLARE item_cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur;
            FETCH NEXT FROM item_cur INTO @item_val;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productId INT = TRY_CAST(JSON_VALUE(@item_val, '$.productId') AS INT);
                DECLARE @quantity INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.quantity') AS INT), 1);
                DECLARE @price FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.price') AS FLOAT), 0);
                DECLARE @cost FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.cost') AS FLOAT), 0);
                DECLARE @providerId INT = TRY_CAST(JSON_VALUE(@item_val, '$.providerId') AS INT);
                DECLARE @prestadoraId INT = TRY_CAST(JSON_VALUE(@item_val, '$.prestadoraId') AS INT);
                DECLARE @checkInDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.checkOut') AS DATETIME2);
                DECLARE @nights INT = TRY_CAST(JSON_VALUE(@item_val, '$.nights') AS INT);
                DECLARE @paxAdultsItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItem INT = TRY_CAST(JSON_VALUE(@item_val, '$.paxChildren') AS INT);
                DECLARE @serviceType NVARCHAR(250) = JSON_VALUE(@item_val, '$.serviceType');
                DECLARE @destinationItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.destination');
                DECLARE @reservationCodeItem NVARCHAR(100) = JSON_VALUE(@item_val, '$.reservationCode');
                DECLARE @sellerCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommission FLOAT = TRY_CAST(JSON_VALUE(@item_val, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboId INT = TRY_CAST(JSON_VALUE(@item_val, '$.comboId') AS INT);
                DECLARE @mainTaxId INT = TRY_CAST(JSON_VALUE(@item_val, '$.mainTaxId') AS INT);
                DECLARE @inNationality INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val, '$.inNationality') AS INT), 1);
                DECLARE @service NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.service');
                DECLARE @servicios NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.servicios');
                DECLARE @descripcion NVARCHAR(MAX) = JSON_VALUE(@item_val, '$.descripcion');
                DECLARE @passengerItem NVARCHAR(250) = JSON_VALUE(@item_val, '$.passenger');
                DECLARE @passengerFirstNameItem NVARCHAR(150) = JSON_VALUE(@item_val, '$.passengerFirstName');
                DECLARE @passengerLastNameItem NVARCHAR(150) = JSON_VALUE(@item_val, '$.passengerLastName');

                IF @passengerFirstNameItem IS NULL AND @passengerLastNameItem IS NULL AND NULLIF(LTRIM(RTRIM(@passengerItem)), '') IS NOT NULL
                BEGIN
                    IF CHARINDEX(' ', LTRIM(RTRIM(@passengerItem))) = 0
                        SET @passengerFirstNameItem = LTRIM(RTRIM(@passengerItem));
                    ELSE
                    BEGIN
                        SET @passengerFirstNameItem = SUBSTRING(LTRIM(RTRIM(@passengerItem)), 1, CHARINDEX(' ', LTRIM(RTRIM(@passengerItem))) - 1);
                        SET @passengerLastNameItem = SUBSTRING(LTRIM(RTRIM(@passengerItem)), CHARINDEX(' ', LTRIM(RTRIM(@passengerItem))) + 1, LEN(@passengerItem));
                    END
                END;
                IF @passengerItem IS NULL AND (@passengerFirstNameItem IS NOT NULL OR @passengerLastNameItem IS NOT NULL)
                    SET @passengerItem = LTRIM(RTRIM(CONCAT(ISNULL(@passengerFirstNameItem, N''), N' ', ISNULL(@passengerLastNameItem, N''))));
                DECLARE @providerDueDate DATETIME2 = TRY_CAST(JSON_VALUE(@item_val, '$.providerDueDate') AS DATETIME2);
                DECLARE @providerInvoice NVARCHAR(100) = JSON_VALUE(@item_val, '$.providerInvoice');

                IF @providerId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerId) SET @providerId = NULL;
                IF @prestadoraId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraId) SET @prestadoraId = NULL;

                DECLARE @qp_id INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, description, passenger, passengerFirstName, passengerLastName, providerDueDate, providerInvoice
                ) VALUES (
                    @p_quotation_id, @productId, @quantity, @price, @cost, @providerId, @prestadoraId,
                    @checkInDate, @checkOutDate, @nights, @paxAdultsItem, @paxChildrenItem, @serviceType, @destinationItem,
                    @reservationCodeItem, @sellerCommission, @ticketPrinterCommission, @comboId, @mainTaxId, @inNationality,
                    @service, @servicios, @descripcion, @descripcion, @passengerItem, @passengerFirstNameItem, @passengerLastNameItem, @providerDueDate, @providerInvoice
                );
                SET @qp_id = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'FIXED'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxId OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END;

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, firstName, lastName, document)
                    SELECT
                        @qp_id,
                        LTRIM(RTRIM(COALESCE(
                            NULLIF(CONCAT(ISNULL(JSON_VALUE(pax.value, '$.firstName'), N''), N' ', ISNULL(JSON_VALUE(pax.value, '$.lastName'), N'')), N' '),
                            JSON_VALUE(pax.value, '$.name'),
                            N''
                        ))),
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(JSON_VALUE(pax.value, '$.firstName'))), N''),
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name')))) = 0 THEN LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name')))
                                ELSE SUBSTRING(LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name'))), 1, CHARINDEX(' ', LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name')))) - 1)
                            END
                        ),
                        COALESCE(
                            NULLIF(LTRIM(RTRIM(JSON_VALUE(pax.value, '$.lastName'))), N''),
                            CASE 
                                WHEN CHARINDEX(' ', LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name')))) = 0 THEN N''
                                ELSE SUBSTRING(LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name'))), CHARINDEX(' ', LTRIM(RTRIM(JSON_VALUE(pax.value, '$.name')))) + 1, LEN(JSON_VALUE(pax.value, '$.name')))
                            END
                        ),
                        JSON_VALUE(pax.value, '$.document')
                    FROM OPENJSON(@item_val, '$.passengers') AS pax
                    WHERE (JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '')
                       OR (JSON_VALUE(pax.value, '$.firstName') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.firstName')) <> '')
                       OR (JSON_VALUE(pax.value, '$.lastName') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.lastName')) <> '');
                END;

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END;

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val, '$.payments') AS pmt;
                END;

                FETCH NEXT FROM item_cur INTO @item_val;
            END;

            CLOSE item_cur;
            DEALLOCATE item_cur;
        END;

        -- Recalculate totalAmount and internal financial summary (valorBase without duplicating mainTaxId)
        DECLARE @calcTotal FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_quotation_id
        );
        IF @calcTotal IS NULL OR @calcTotal = 0
        BEGIN
            SET @calcTotal = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_quotation_id
            );
        END;

        DECLARE @costoTotalCalc FLOAT = 0;
        DECLARE @valorBaseCalc FLOAT = 0;
        SELECT
            @costoTotalCalc = ISNULL(SUM(ISNULL(qp.cost, 0)), 0),
            @valorBaseCalc = ISNULL(SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1) + ISNULL(add_base.extraBase, 0)), 0)
        FROM dbo.[QuotationProduct] qp
        OUTER APPLY (
            SELECT SUM(ISNULL(qpt2.explicitAmount, 0)) AS extraBase
            FROM dbo.[QuotationProductTax] qpt2
            JOIN dbo.[ChargeAndTax] ct2 ON ct2.id = qpt2.chargeAndTaxId
            LEFT JOIN dbo.[ChargeAndTax] target_ct ON target_ct.id = ct2.targetTaxId
            WHERE qpt2.quotationProductId = qp.id
              AND ISNULL(qpt2.isMain, 0) = 0
              AND qpt2.chargeAndTaxId <> ISNULL(qp.mainTaxId, -1)
              AND ct2.targetTaxId IS NOT NULL
              AND (
                  target_ct.[type] = 'PRINCIPAL' OR ISNULL(target_ct.isEditable, 1) = 0 OR target_ct.code = 'TAR' OR target_ct.[name] LIKE '%TARIFA%' OR target_ct.id = qp.mainTaxId
              )
        ) add_base
        WHERE qp.quotationId = @p_quotation_id;

        DECLARE @utilidadCalc FLOAT = @valorBaseCalc - @costoTotalCalc;
        DECLARE @comisionUtilidadPct FLOAT = CASE WHEN @valorBaseCalc > 0 THEN ROUND((@utilidadCalc / @valorBaseCalc) * 100.0, 2) ELSE 0 END;
        DECLARE @comisionTotalPct FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.comisionTotalPercentage') AS FLOAT), @commissionPercentage);
        DECLARE @comisionFreelancePct FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.comisionFreelancePercentage') AS FLOAT), 0);
        DECLARE @mostrarTotalizacion BIT = CASE WHEN EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE code = 'MOSTRAR_TOTALIZACION_COTIZACION' AND [value] = 'true') THEN 1 ELSE 0 END;
        DECLARE @comisionPropiaPct FLOAT = CASE WHEN @mostrarTotalizacion = 1 THEN (@comisionUtilidadPct - @comisionFreelancePct) ELSE (@comisionTotalPct - @comisionFreelancePct) END;

        UPDATE dbo.[Quotation]
        SET totalAmount = CASE WHEN @calcTotal IS NOT NULL AND @calcTotal > 0 THEN @calcTotal WHEN @totalAmount > 0 THEN @totalAmount ELSE totalAmount END,
            baseCommissionable = CASE WHEN @calcTotal IS NOT NULL AND @calcTotal > 0 THEN ISNULL(NULLIF(@baseCommissionable, 0), @calcTotal) ELSE baseCommissionable END,
            chargesAndTaxes = CASE WHEN @calcTotal IS NOT NULL AND @calcTotal > 0 THEN ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotal) ELSE chargesAndTaxes END,
            costoTotal = @costoTotalCalc,
            valorBase = @valorBaseCalc,
            utilidad = @utilidadCalc,
            comisionTotalPercentage = @comisionTotalPct,
            comisionFreelancePercentage = @comisionFreelancePct,
            comisionPropiaPercentage = @comisionPropiaPct,
            commissionPercentage = @comisionPropiaPct,
            comisionUtilidadPercentage = @comisionUtilidadPct,
            comisionFreelanceValue = (@comisionFreelancePct / 100.0) * @valorBaseCalc,
            comisionPropiaValue = (@comisionPropiaPct / 100.0) * @valorBaseCalc
        WHERE id = @p_quotation_id;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización creada correctamente con ID ', @p_quotation_id);
        SELECT @p_quotation_id AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_quotation_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
