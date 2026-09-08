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
    v_res_json jsonb;
BEGIN
    p_transaction_type := UPPER(TRIM(COALESCE(p_transaction_type, 'INVOICE')));

    -- 1. Intentar buscar un consecutivo específico para la combinación sucursal e implante
    SELECT * INTO v_rec
    FROM public."TransactionConsecutive"
    WHERE UPPER("transactionType") = p_transaction_type
      AND "isActive" = true
      AND (
          (p_branch_id IS NOT NULL AND "branchId" = p_branch_id)
          OR ("branchId" IS NULL)
      )
      AND (
          (p_implant_id IS NOT NULL AND "implantId" = p_implant_id)
          OR ("implantId" IS NULL)
      )
    ORDER BY 
        CASE WHEN "branchId" = p_branch_id THEN 1 ELSE 2 END,
        CASE WHEN "implantId" = p_implant_id THEN 1 ELSE 2 END,
        id ASC
    LIMIT 1
    FOR UPDATE;

    -- Si existe un registro configurado
    IF v_rec.id IS NOT NULL THEN
        v_next_val := v_rec."currentNumber";
        v_prefix := COALESCE(v_rec.prefix, '');

        -- Incrementar atómicamente para la siguiente transacción
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = "currentNumber" + 1
        WHERE id = v_rec.id;
    ELSE
        -- Fallback si no existe parámetro de consecutivo configurado todavía
        v_prefix := CASE 
            WHEN p_transaction_type = 'INVOICE' THEN 'INV'
            WHEN p_transaction_type = 'CREDIT_NOTE' THEN 'NC'
            WHEN p_transaction_type = 'QUOTATION' THEN 'COT'
            ELSE 'DOC'
        END;

        -- Usar la secuencia PostgreSQL si no hay registro manual
        v_next_val := nextval('public."Invoices_id_seq"');
    END IF;

    v_res_json := jsonb_build_object(
        'consecutivoNumber', v_next_val,
        'prefix', v_prefix,
        'formattedConsecutive', CASE WHEN v_prefix <> '' THEN v_prefix || '-' || v_next_val::text ELSE v_next_val::text END
    );

    RETURN v_res_json;
END;
$$;
