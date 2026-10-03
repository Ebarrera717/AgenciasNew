DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProductoCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProductoCrear(
    p_code TEXT,
    p_type TEXT,
    p_description TEXT,
    p_base_price FLOAT,
    p_cost FLOAT,
    p_billing_concept TEXT,
    p_service_type TEXT,
    p_acting_user_id INT,
    INOUT p_product_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Product" ("code", "type", "description", "basePrice", "cost", "billingConcept", "serviceType")
    VALUES (p_code, p_type, p_description, p_base_price, p_cost, p_billing_concept, p_service_type)
    RETURNING id INTO p_product_id;

    p_mensaje_resultado := 'SUCCESS: Producto creado con ID ' || p_product_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
