DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSellerCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spSellerCrear(
    p_code TEXT,
    p_name TEXT,
    p_email TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_seller_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Seller" ("code", "name", "email", "isActive")
    VALUES (p_code, p_name, p_email, COALESCE(p_is_active, true))
    RETURNING id INTO p_seller_id;

    p_mensaje_resultado := 'SUCCESS: Vendedor creado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
