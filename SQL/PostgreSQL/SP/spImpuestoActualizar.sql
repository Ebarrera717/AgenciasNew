DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImpuestoActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImpuestoActualizar(
    p_id INT,
    p_code TEXT,
    p_name TEXT,
    p_type TEXT,
    p_value_type TEXT,
    p_value DECIMAL,
    p_is_editable BOOLEAN,
    p_orden INT DEFAULT 0,
    p_product_ids JSONB DEFAULT '[]'::jsonb,
    p_target_tax_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        IF EXISTS (SELECT 1 FROM public."ChargeAndTax" WHERE LOWER("code") = LOWER(TRIM(p_code)) AND id <> p_id) THEN
            p_mensaje_resultado := 'ERROR: Ya existe otro cargo o impuesto registrado con el código ' || quote_literal(p_code);
            RETURN;
        END IF;
    END IF;

    UPDATE public."ChargeAndTax" SET
        "code" = p_code,
        "name" = p_name,
        "type" = p_type,
        "valueType" = p_value_type,
        "value" = p_value,
        "isEditable" = p_is_editable,
        "orden" = COALESCE(p_orden, 0),
        "productIds" = COALESCE(p_product_ids, '[]'::jsonb),
        "targetTaxId" = p_target_tax_id,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
