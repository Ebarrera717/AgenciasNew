DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTransactionConsecutiveCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTransactionConsecutiveCrear"(
    IN p_transaction_type text,
    IN p_description text,
    IN p_prefix text,
    IN p_initial_number integer,
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_consecutivo_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción de la transacción es obligatoria.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_initial_number < 1 THEN
        p_initial_number := 1;
    END IF;

    INSERT INTO public."TransactionConsecutive" (
        "transactionType",
        "description",
        "prefix",
        "initialNumber",
        "currentNumber",
        "branchId",
        "implantId",
        "isActive",
        "createdAt"
    ) VALUES (
        UPPER(TRIM(p_transaction_type)),
        TRIM(p_description),
        TRIM(p_prefix),
        p_initial_number,
        p_initial_number,
        p_branch_id,
        p_implant_id,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_consecutivo_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_consecutivo_id := 0;
END;
$$;
