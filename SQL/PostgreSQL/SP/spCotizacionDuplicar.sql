DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionDuplicar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCotizacionDuplicar(
    IN p_quotation_id INT,
    IN p_acting_user_id INT,
    INOUT p_new_quotation_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_internal_number TEXT;
    v_new_id INT;
    v_orig_quotation RECORD;
    v_orig_qp RECORD;
    v_new_qp_id INT;
    v_user_id INT := NULL;
BEGIN
    -- Validar existencia de la cotización origen
    SELECT * INTO v_orig_quotation 
    FROM public."Quotation" 
    WHERE id = p_quotation_id;

    IF v_orig_quotation.id IS NULL THEN
        p_mensaje_resultado := 'ERROR: Cotización origen no encontrada (ID ' || p_quotation_id || ').';
        RETURN;
    END IF;

    -- Validar si p_acting_user_id existe en la tabla User, de lo contrario usar el de la cotización origen
    IF p_acting_user_id IS NOT NULL THEN
        SELECT id INTO v_user_id FROM public."User" WHERE id = p_acting_user_id;
    END IF;

    IF v_user_id IS NULL THEN
        v_user_id := v_orig_quotation."userId";
    END IF;

    -- Generar consecutivo único interno desde TransactionConsecutive
    SELECT x.v_consec_json->>'formattedConsecutive' INTO v_internal_number
    FROM (SELECT public."fnObtenerSiguienteConsecutivo"('QUOTATION', v_orig_quotation."branchId", v_orig_quotation."implantId") AS v_consec_json) x;

    IF v_internal_number IS NULL OR v_internal_number = '' THEN
        v_internal_number := 'COT-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 10000)::text;
    END IF;

    -- Insertar la cabecera duplicada de la cotización
    INSERT INTO public."Quotation" (
        "internalNumber", "date", "clientId", "currency", "exchangeRate",
        "branchId", "implantId", "sellerId", "ticketPrinterId",
        "baseCommissionable", "commissionPercentage", "chargesAndTaxes",
        "totalAmount", "userId", "state", "stateDescription", "stateUpdatedAt",
        "costoTotal", "valorBase", "utilidad", "comisionTotalPercentage",
        "comisionFreelancePercentage", "comisionFreelanceValue",
        "comisionPropiaPercentage", "comisionPropiaValue", "comisionUtilidadPercentage",
        "destination", "startDate", "endDate", "passenger", "paxAdults", "paxChildren",
        "reservationCode", "copyFieldsToProducts", "manualDescription"
    ) VALUES (
        v_internal_number, CURRENT_TIMESTAMP, v_orig_quotation."clientId", v_orig_quotation."currency", v_orig_quotation."exchangeRate",
        v_orig_quotation."branchId", v_orig_quotation."implantId", v_orig_quotation."sellerId", v_orig_quotation."ticketPrinterId",
        v_orig_quotation."baseCommissionable", v_orig_quotation."commissionPercentage", v_orig_quotation."chargesAndTaxes",
        v_orig_quotation."totalAmount", v_user_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP,
        v_orig_quotation."costoTotal", v_orig_quotation."valorBase", v_orig_quotation."utilidad", v_orig_quotation."comisionTotalPercentage",
        v_orig_quotation."comisionFreelancePercentage", v_orig_quotation."comisionFreelanceValue",
        v_orig_quotation."comisionPropiaPercentage", v_orig_quotation."comisionPropiaValue", v_orig_quotation."comisionUtilidadPercentage",
        v_orig_quotation."destination", v_orig_quotation."startDate", v_orig_quotation."endDate", v_orig_quotation."passenger", v_orig_quotation."paxAdults", v_orig_quotation."paxChildren",
        v_orig_quotation."reservationCode", v_orig_quotation."copyFieldsToProducts", v_orig_quotation."manualDescription"
    ) RETURNING id INTO v_new_id;

    -- Insertar registro inicial en el historial de estados
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (v_new_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP, v_user_id);

    -- Duplicar combos asociados
    INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
    SELECT v_new_id, "comboId"
    FROM public."QuotationCombo"
    WHERE "quotationId" = p_quotation_id;

    -- Duplicar servicios manuales si la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        INSERT INTO public."QuotationManualService" ("quotationId", "providerName", "serviceName", "cost", "salePrice", "utility")
        SELECT v_new_id, "providerName", "serviceName", "cost", "salePrice", "utility"
        FROM public."QuotationManualService"
        WHERE "quotationId" = p_quotation_id;
    END IF;

    -- Duplicar productos y sus detalles
    FOR v_orig_qp IN 
        SELECT * FROM public."QuotationProduct" WHERE "quotationId" = p_quotation_id
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission",
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_new_id, v_orig_qp."productId", v_orig_qp."quantity", v_orig_qp."price", v_orig_qp."cost", v_orig_qp."providerId", v_orig_qp."prestadoraId",
            v_orig_qp."checkInDate", v_orig_qp."checkOutDate", v_orig_qp."nights", v_orig_qp."paxAdults", v_orig_qp."paxChildren",
            v_orig_qp."serviceType", v_orig_qp."destination", v_orig_qp."reservationCode", v_orig_qp."sellerCommission",
            v_orig_qp."ticketPrinterCommission", v_orig_qp."comboId", v_orig_qp."mainTaxId", v_orig_qp."inNationality",
            v_orig_qp."service", v_orig_qp."servicios", v_orig_qp."descripcion", v_orig_qp."passenger"
        ) RETURNING id INTO v_new_qp_id;

        -- Duplicar Pasajeros del producto
        INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
        SELECT v_new_qp_id, "name", "document"
        FROM public."QuotationProductPassenger"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Impuestos del producto
        INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain")
        SELECT v_new_qp_id, "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
        FROM public."QuotationProductTax"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Variables del producto
        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
        SELECT v_new_qp_id, "masterVariableId", "value"
        FROM public."QuotationProductVariable"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Pagos del producto
        INSERT INTO public."QuotationProductPayment" ("quotationProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
        SELECT v_new_qp_id, "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
        FROM public."QuotationProductPayment"
        WHERE "quotationProductId" = v_orig_qp.id;

    END LOOP;

    p_new_quotation_id := v_new_id;
    p_mensaje_resultado := 'SUCCESS: Cotización duplicada correctamente con ID ' || v_new_id;

    -- Registrar en auditoría
    CALL public."spLogRegistrar"(
        v_user_id, 
        'QUOTATION', 
        'DUPLICATE', 
        'Se duplicó la cotización #' || p_quotation_id || ' generando la cotización #' || v_new_id || ' (' || v_internal_number || ')', 
        jsonb_build_object('sourceQuotationId', p_quotation_id, 'newQuotationId', v_new_id), 
        v_new_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$procedure$;
