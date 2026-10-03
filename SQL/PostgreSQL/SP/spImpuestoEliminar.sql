DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImpuestoEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImpuestoEliminar(
    p_id INT,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT name INTO v_name FROM public."ChargeAndTax" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El cargo o impuesto no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."QuotationProductTax" WHERE "chargeAndTaxId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."InvoicesProductTax" WHERE "chargeAndTaxId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."ComboProductTax" WHERE "chargeAndTaxId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el cargo o impuesto "' || v_name || '" porque ya se encuentra registrado en ' || v_count || ' transacción(es) del sistema. Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."ChargeAndTax" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
