DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTransactionConsecutiveActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spTransactionConsecutiveActualizar"(
    IN p_id integer,
    IN p_transaction_type text,
    IN p_description text,
    IN p_prefix text,
    IN p_initial_number integer,
    IN p_current_number integer,
    IN p_branch_id integer,
    IN p_implant_id integer,
    IN p_is_active boolean,
    IN p_user_id integer,
    INOUT p_mensaje_resultado text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción es obligatoria.';
        RETURN;
    END IF;

    UPDATE public."TransactionConsecutive"
    SET 
        "transactionType" = UPPER(TRIM(p_transaction_type)),
        "description" = TRIM(p_description),
        "prefix" = TRIM(p_prefix),
        "initialNumber" = COALESCE(p_initial_number, "initialNumber"),
        "currentNumber" = COALESCE(p_current_number, "currentNumber"),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
