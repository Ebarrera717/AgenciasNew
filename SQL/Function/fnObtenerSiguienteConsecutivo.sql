DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnObtenerSiguienteConsecutivo'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnObtenerSiguienteConsecutivo"(
    p_transaction_type text,
    p_branch_id integer DEFAULT NULL,
    p_implant_id integer DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec RECORD;
    v_next_val integer;
    v_prefix text := '';
    v_padding integer := 0;
    v_num_str text;
    v_formatted text;
    v_res_json jsonb;
    v_norm_type text;
BEGIN
    v_norm_type := UPPER(TRIM(COALESCE(p_transaction_type, 'INVOICE')));

    -- 1. Intentar buscar un consecutivo específico para la combinación sucursal e implante
    SELECT * INTO v_rec
    FROM public."TransactionConsecutive"
    WHERE "isActive" = true
      AND (
          UPPER("transactionType") = v_norm_type
          OR (v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA') AND UPPER("transactionType") IN ('INVOICE', 'FACTURA', 'FACTURACION', 'FACTURACION ELECTRONICA'))
          OR (v_norm_type IN ('QUOTATION', 'COTIZACION') AND UPPER("transactionType") IN ('QUOTATION', 'COTIZACION'))
          OR (v_norm_type IN ('PREQUOTATION', 'PRECOTIZACION') AND UPPER("transactionType") IN ('PREQUOTATION', 'PRECOTIZACION'))
          OR (v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') AND UPPER("transactionType") IN ('CREDIT_NOTE', 'NOTA_CREDITO'))
      )
      AND (
          (p_branch_id IS NOT NULL AND "branchId" = p_branch_id)
          OR ("branchId" IS NULL)
      )
      AND (
          (p_implant_id IS NOT NULL AND "implantId" = p_implant_id)
          OR ("implantId" IS NULL)
      )
    ORDER BY 
        CASE WHEN p_implant_id IS NOT NULL AND "implantId" = p_implant_id THEN 1 WHEN "implantId" IS NOT NULL THEN 3 ELSE 2 END,
        CASE WHEN p_branch_id IS NOT NULL AND "branchId" = p_branch_id THEN 1 WHEN "branchId" IS NOT NULL THEN 3 ELSE 2 END,
        id ASC
    LIMIT 1
    FOR UPDATE;

    -- Si existe un registro configurado
    IF v_rec.id IS NOT NULL THEN
        v_next_val := COALESCE(v_rec."currentNumber", v_rec."initialNumber", 1);
        v_prefix := COALESCE(TRIM(v_rec.prefix), '');
        v_padding := COALESCE(v_rec.padding, 0);

        -- Incrementar atómicamente para la siguiente transacción
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = "currentNumber" + 1,
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = v_rec.id;
    ELSE
        -- Fallback si no existe parámetro de consecutivo configurado todavía
        v_prefix := CASE 
            WHEN v_norm_type IN ('QUOTATION', 'COTIZACION') THEN 'COT'
            WHEN v_norm_type IN ('INVOICE', 'FACTURA', 'FACTURACION') THEN 'FAC'
            WHEN v_norm_type IN ('CREDIT_NOTE', 'NOTA_CREDITO') THEN 'NC'
            ELSE 'DOC'
        END;

        IF v_norm_type IN ('QUOTATION', 'COTIZACION') THEN
            SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_val FROM public."Quotation";
        ELSE
            SELECT COALESCE(MAX(id), 0) + 1 INTO v_next_val FROM public."Invoices";
        END IF;
    END IF;

    v_num_str := v_next_val::text;
    IF v_padding > 0 AND length(v_num_str) < v_padding THEN
        v_num_str := lpad(v_num_str, v_padding, '0');
    END IF;

    IF v_prefix <> '' THEN
        IF v_prefix LIKE '%-' OR v_prefix LIKE '%/' THEN
            v_formatted := v_prefix || v_num_str;
        ELSE
            v_formatted := v_prefix || '-' || v_num_str;
        END IF;
    ELSE
        v_formatted := v_num_str;
    END IF;

    v_res_json := jsonb_build_object(
        'consecutivoNumber', v_next_val,
        'prefix', v_prefix,
        'formattedConsecutive', v_formatted,
        'consecutivoId', v_rec.id
    );

    RETURN v_res_json;
END;
$$;
