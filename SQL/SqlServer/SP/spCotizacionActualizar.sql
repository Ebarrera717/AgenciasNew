-- 2.38. spCotizacionActualizar
IF OBJECT_ID('dbo.spCotizacionActualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spCotizacionActualizar;
GO

CREATE PROCEDURE dbo.spCotizacionActualizar
    @p_id INT,
    @p_data NVARCHAR(MAX),
    @p_acting_user_id INT = 1,
    @p_mensaje_resultado NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation] WHERE id = @p_id)
        BEGIN
            SET @p_mensaje_resultado = CONCAT(N'ERROR: Cotización ', @p_id, N' no existe.');
            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
            RETURN;
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
        DECLARE @state NVARCHAR(50) = ISNULL(JSON_VALUE(@p_data, '$.state'), N'NUEVO');
        DECLARE @stateDescription NVARCHAR(MAX) = JSON_VALUE(@p_data, '$.stateDescription');
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
                            SELECT @p_mensaje_resultado AS p_mensaje_resultado;
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

        UPDATE dbo.[Quotation]
        SET
            clientId = @clientId,
            currency = @currency,
            exchangeRate = @exchangeRate,
            branchId = ISNULL(@branchId, branchId),
            implantId = @implantId,
            sellerId = @sellerId,
            ticketPrinterId = @ticketPrinterId,
            userId = CASE
                WHEN userId IS NULL OR userId = 1 THEN COALESCE(
                    (
                        SELECT TOP 1 u.id
                        FROM dbo.[TicketPrinter] tp
                        INNER JOIN dbo.[User] u ON (
                            u.ticketPrinterId = tp.id
                            OR (NULLIF(LTRIM(RTRIM(tp.email)), '') IS NOT NULL AND LOWER(LTRIM(RTRIM(u.email))) = LOWER(LTRIM(RTRIM(tp.email))))
                            OR (NULLIF(LTRIM(RTRIM(tp.name)), '') IS NOT NULL AND UPPER(LTRIM(RTRIM(u.name))) = UPPER(LTRIM(RTRIM(tp.name))))
                        )
                        WHERE tp.id = ISNULL(@ticketPrinterId, dbo.[Quotation].ticketPrinterId)
                        ORDER BY CASE WHEN u.ticketPrinterId = tp.id THEN 0 ELSE 1 END, u.id ASC
                    ),
                    userId
                )
                ELSE userId
            END,
            totalAmount = @totalAmount,
            baseCommissionable = @baseCommissionable,
            chargesAndTaxes = @chargesAndTaxes,
            commissionPercentage = @commissionPercentage,
            state = @state,
            stateDescription = ISNULL(@stateDescription, stateDescription),
            stateUpdatedAt = GETDATE(),
            destination = @destination,
            startDate = @startDate,
            endDate = @endDate,
            passenger = @passenger,
            passengerFirstName = @passengerFirstName,
            passengerLastName = @passengerLastName,
            paxAdults = @paxAdults,
            paxChildren = @paxChildren,
            reservationCode = @reservationCode,
            manualDescription = @manualDescription,
            observations = @observations
        WHERE id = @p_id;

        IF JSON_QUERY(@p_data, '$.items') IS NOT NULL
        BEGIN
            DELETE FROM dbo.[QuotationProductTax] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPassenger] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductVariable] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProductPayment] WHERE quotationProductId IN (SELECT id FROM dbo.[QuotationProduct] WHERE quotationId = @p_id);
            DELETE FROM dbo.[QuotationProduct] WHERE quotationId = @p_id;

            DECLARE @item_val_upd NVARCHAR(MAX);
            DECLARE item_cur_upd CURSOR LOCAL FAST_FORWARD FOR
            SELECT [value] FROM OPENJSON(@p_data, '$.items');

            OPEN item_cur_upd;
            FETCH NEXT FROM item_cur_upd INTO @item_val_upd;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @productIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.productId') AS INT);
                DECLARE @quantityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.quantity') AS INT), 1);
                DECLARE @priceUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.price') AS FLOAT), 0);
                DECLARE @costUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.cost') AS FLOAT), 0);
                DECLARE @providerIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.providerId') AS INT);
                DECLARE @prestadoraIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.prestadoraId') AS INT);
                DECLARE @checkInDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkIn') AS DATETIME2);
                DECLARE @checkOutDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.checkOut') AS DATETIME2);
                DECLARE @nightsUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.nights') AS INT);
                DECLARE @paxAdultsItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxAdults') AS INT);
                DECLARE @paxChildrenItemUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.paxChildren') AS INT);
                DECLARE @serviceTypeUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.serviceType');
                DECLARE @destinationItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.destination');
                DECLARE @reservationCodeItemUpd NVARCHAR(100) = JSON_VALUE(@item_val_upd, '$.reservationCode');
                DECLARE @sellerCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.sellerCommission') AS FLOAT);
                DECLARE @ticketPrinterCommissionUpd FLOAT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.ticketPrinterCommission') AS FLOAT);
                DECLARE @comboIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.comboId') AS INT);
                DECLARE @mainTaxIdUpd INT = TRY_CAST(JSON_VALUE(@item_val_upd, '$.mainTaxId') AS INT);
                DECLARE @inNationalityUpd INT = ISNULL(TRY_CAST(JSON_VALUE(@item_val_upd, '$.inNationality') AS INT), 1);
                DECLARE @serviceUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.service');
                DECLARE @serviciosUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.servicios');
                DECLARE @descripcionUpd NVARCHAR(MAX) = JSON_VALUE(@item_val_upd, '$.descripcion');
                DECLARE @passengerItemUpd NVARCHAR(250) = JSON_VALUE(@item_val_upd, '$.passenger');
                DECLARE @passengerFirstNameItemUpd NVARCHAR(150) = JSON_VALUE(@item_val_upd, '$.passengerFirstName');
                DECLARE @passengerLastNameItemUpd NVARCHAR(150) = JSON_VALUE(@item_val_upd, '$.passengerLastName');

                IF @passengerFirstNameItemUpd IS NULL AND @passengerLastNameItemUpd IS NULL AND NULLIF(LTRIM(RTRIM(@passengerItemUpd)), '') IS NOT NULL
                BEGIN
                    IF CHARINDEX(' ', LTRIM(RTRIM(@passengerItemUpd))) = 0
                        SET @passengerFirstNameItemUpd = LTRIM(RTRIM(@passengerItemUpd));
                    ELSE
                    BEGIN
                        SET @passengerFirstNameItemUpd = SUBSTRING(LTRIM(RTRIM(@passengerItemUpd)), 1, CHARINDEX(' ', LTRIM(RTRIM(@passengerItemUpd))) - 1);
                        SET @passengerLastNameItemUpd = SUBSTRING(LTRIM(RTRIM(@passengerItemUpd)), CHARINDEX(' ', LTRIM(RTRIM(@passengerItemUpd))) + 1, LEN(@passengerItemUpd));
                    END
                END;
                IF @passengerItemUpd IS NULL AND (@passengerFirstNameItemUpd IS NOT NULL OR @passengerLastNameItemUpd IS NOT NULL)
                    SET @passengerItemUpd = LTRIM(RTRIM(CONCAT(ISNULL(@passengerFirstNameItemUpd, N''), N' ', ISNULL(@passengerLastNameItemUpd, N''))));
                DECLARE @providerDueDateUpd DATETIME2 = TRY_CAST(JSON_VALUE(@item_val_upd, '$.providerDueDate') AS DATETIME2);
                DECLARE @providerInvoiceUpd NVARCHAR(100) = JSON_VALUE(@item_val_upd, '$.providerInvoice');

                IF @providerIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Provider] WHERE id = @providerIdUpd) SET @providerIdUpd = NULL;
                IF @prestadoraIdUpd IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Prestadora] WHERE id = @prestadoraIdUpd) SET @prestadoraIdUpd = NULL;

                DECLARE @qp_id_upd INT;
                INSERT INTO dbo.[QuotationProduct] (
                    quotationId, productId, quantity, price, cost, providerId, prestadoraId,
                    checkInDate, checkOutDate, nights, paxAdults, paxChildren, serviceType, destination,
                    reservationCode, sellerCommission, ticketPrinterCommission, comboId, mainTaxId, inNationality,
                    service, servicios, descripcion, description, passenger, passengerFirstName, passengerLastName, providerDueDate, providerInvoice
                ) VALUES (
                    @p_id, @productIdUpd, @quantityUpd, @priceUpd, @costUpd, @providerIdUpd, @prestadoraIdUpd,
                    @checkInDateUpd, @checkOutDateUpd, @nightsUpd, @paxAdultsItemUpd, @paxChildrenItemUpd, @serviceTypeUpd, @destinationItemUpd,
                    @reservationCodeItemUpd, @sellerCommissionUpd, @ticketPrinterCommissionUpd, @comboIdUpd, @mainTaxIdUpd, @inNationalityUpd,
                    @serviceUpd, @serviciosUpd, @descripcionUpd, @descripcionUpd, @passengerItemUpd, @passengerFirstNameItemUpd, @passengerLastNameItemUpd, @providerDueDateUpd, @providerInvoiceUpd
                );
                SET @qp_id_upd = SCOPE_IDENTITY();

                -- Insert Applied Taxes (QuotationProductTax)
                IF JSON_QUERY(@item_val_upd, '$.appliedTaxes') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductTax] (quotationProductId, chargeAndTaxId, explicitAmount, valueSnapshot, valueTypeSnapshot, isMain)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.explicitAmount') AS FLOAT), ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.amount') AS FLOAT), 0)),
                        ISNULL(TRY_CAST(JSON_VALUE(tax.value, '$.valueSnapshot') AS FLOAT), 0),
                        ISNULL(JSON_VALUE(tax.value, '$.valueTypeSnapshot'), 'FIXED'),
                        CASE WHEN TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) = @mainTaxIdUpd OR JSON_VALUE(tax.value, '$.isMain') = 'true' THEN 1 ELSE 0 END
                    FROM OPENJSON(@item_val_upd, '$.appliedTaxes') AS tax
                    WHERE TRY_CAST(JSON_VALUE(tax.value, '$.chargeAndTaxId') AS INT) IS NOT NULL;
                END;

                -- Insert Passengers (QuotationProductPassenger)
                IF JSON_QUERY(@item_val_upd, '$.passengers') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPassenger] (quotationProductId, name, firstName, lastName, document)
                    SELECT
                        @qp_id_upd,
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
                    FROM OPENJSON(@item_val_upd, '$.passengers') AS pax
                    WHERE (JSON_VALUE(pax.value, '$.name') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.name')) <> '')
                       OR (JSON_VALUE(pax.value, '$.firstName') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.firstName')) <> '')
                       OR (JSON_VALUE(pax.value, '$.lastName') IS NOT NULL AND TRIM(JSON_VALUE(pax.value, '$.lastName')) <> '');
                END;

                -- Insert Variables (QuotationProductVariable)
                IF JSON_QUERY(@item_val_upd, '$.variables') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductVariable] (quotationProductId, masterVariableId, value)
                    SELECT
                        @qp_id_upd,
                        TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT),
                        JSON_VALUE(v.value, '$.value')
                    FROM OPENJSON(@item_val_upd, '$.variables') AS v
                    WHERE TRY_CAST(JSON_VALUE(v.value, '$.masterVariableId') AS INT) IS NOT NULL;
                END;

                -- Insert Payments (QuotationProductPayment)
                IF JSON_QUERY(@item_val_upd, '$.payments') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.[QuotationProductPayment] (
                        quotationProductId, amount, paymentMethod, date, reference, creditCardId, cardNumber, authorizationCode, voucher, expirationDate
                    )
                    SELECT
                        @qp_id_upd,
                        ISNULL(TRY_CAST(JSON_VALUE(pmt.value, '$.amount') AS FLOAT), 0),
                        JSON_VALUE(pmt.value, '$.paymentMethod'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.date') AS DATETIME2),
                        JSON_VALUE(pmt.value, '$.reference'),
                        TRY_CAST(JSON_VALUE(pmt.value, '$.creditCardId') AS INT),
                        JSON_VALUE(pmt.value, '$.cardNumber'),
                        JSON_VALUE(pmt.value, '$.authorizationCode'),
                        JSON_VALUE(pmt.value, '$.voucher'),
                        JSON_VALUE(pmt.value, '$.expirationDate')
                    FROM OPENJSON(@item_val_upd, '$.payments') AS pmt;
                END;

                FETCH NEXT FROM item_cur_upd INTO @item_val_upd;
            END;

            CLOSE item_cur_upd;
            DEALLOCATE item_cur_upd;
        END;

        -- Recalculate totalAmount and internal financial summary (valorBase without duplicating mainTaxId)
        DECLARE @calcTotalUpd FLOAT = (
            SELECT SUM(ISNULL(qpt.explicitAmount, 0))
            FROM dbo.[QuotationProductTax] qpt
            JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
            WHERE qp.quotationId = @p_id
        );
        IF @calcTotalUpd IS NULL OR @calcTotalUpd = 0
        BEGIN
            SET @calcTotalUpd = (
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = @p_id
            );
        END;

        DECLARE @costoTotalUpd FLOAT = 0;
        DECLARE @valorBaseUpd FLOAT = 0;
        SELECT
            @costoTotalUpd = ISNULL(SUM(ISNULL(qp.cost, 0)), 0),
            @valorBaseUpd = ISNULL(SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1) + ISNULL(add_base.extraBase, 0)), 0)
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
        WHERE qp.quotationId = @p_id;

        DECLARE @utilidadUpd FLOAT = @valorBaseUpd - @costoTotalUpd;
        DECLARE @comisionUtilidadPctUpd FLOAT = CASE WHEN @valorBaseUpd > 0 THEN ROUND((@utilidadUpd / @valorBaseUpd) * 100.0, 2) ELSE 0 END;
        DECLARE @comisionTotalPctUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.comisionTotalPercentage') AS FLOAT), @commissionPercentage);
        DECLARE @comisionFreelancePctUpd FLOAT = ISNULL(TRY_CAST(JSON_VALUE(@p_data, '$.comisionFreelancePercentage') AS FLOAT), 0);
        DECLARE @mostrarTotalizacionUpd BIT = CASE WHEN EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE code = 'MOSTRAR_TOTALIZACION_COTIZACION' AND [value] = 'true') THEN 1 ELSE 0 END;
        DECLARE @comisionPropiaPctUpd FLOAT = CASE WHEN @mostrarTotalizacionUpd = 1 THEN (@comisionUtilidadPctUpd - @comisionFreelancePctUpd) ELSE (@comisionTotalPctUpd - @comisionFreelancePctUpd) END;

        UPDATE dbo.[Quotation]
        SET totalAmount = CASE WHEN @calcTotalUpd IS NOT NULL AND @calcTotalUpd > 0 THEN @calcTotalUpd WHEN @totalAmount > 0 THEN @totalAmount ELSE totalAmount END,
            baseCommissionable = CASE WHEN @calcTotalUpd IS NOT NULL AND @calcTotalUpd > 0 THEN ISNULL(NULLIF(@baseCommissionable, 0), @calcTotalUpd) ELSE baseCommissionable END,
            chargesAndTaxes = CASE WHEN @calcTotalUpd IS NOT NULL AND @calcTotalUpd > 0 THEN ISNULL(NULLIF(@chargesAndTaxes, 0), @calcTotalUpd) ELSE chargesAndTaxes END,
            costoTotal = @costoTotalUpd,
            valorBase = @valorBaseUpd,
            utilidad = @utilidadUpd,
            comisionTotalPercentage = @comisionTotalPctUpd,
            comisionFreelancePercentage = @comisionFreelancePctUpd,
            comisionPropiaPercentage = @comisionPropiaPctUpd,
            commissionPercentage = @comisionPropiaPctUpd,
            comisionUtilidadPercentage = @comisionUtilidadPctUpd,
            comisionFreelanceValue = (@comisionFreelancePctUpd / 100.0) * @valorBaseUpd,
            comisionPropiaValue = (@comisionPropiaPctUpd / 100.0) * @valorBaseUpd
        WHERE id = @p_id;

        COMMIT TRANSACTION;

        SET @p_mensaje_resultado = CONCAT(N'SUCCESS: Cotización ', @p_id, N' actualizada correctamente.');
        SELECT @p_id AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @p_mensaje_resultado = CONCAT(N'ERROR: ', ERROR_MESSAGE());
        SELECT 0 AS p_id, @p_mensaje_resultado AS p_mensaje_resultado;
    END CATCH;
END;
GO
