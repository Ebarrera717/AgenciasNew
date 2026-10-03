DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImpuestoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImpuestoCrear(
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
    INOUT p_tax_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        IF EXISTS (SELECT 1 FROM public."ChargeAndTax" WHERE LOWER("code") = LOWER(TRIM(p_code))) THEN
            p_mensaje_resultado := 'ERROR: Ya existe un cargo o impuesto registrado con el código ' || quote_literal(p_code);
            RETURN;
        END IF;
    END IF;

    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "orden", "productIds", "targetTaxId", "isActive")
    VALUES (p_code, p_name, p_type, p_value_type, p_value, p_is_editable, COALESCE(p_orden, 0), COALESCE(p_product_ids, '[]'::jsonb), p_target_tax_id, COALESCE(p_is_active, true))
    RETURNING id INTO p_tax_id;

    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto creado con ID ' || p_tax_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
