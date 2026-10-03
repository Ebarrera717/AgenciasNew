DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fn_obtener_decimales_moneda'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fn_obtener_decimales_moneda(p_currency_code TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_decimals INT;
BEGIN
    SELECT COALESCE(decimals, 2) INTO v_decimals
    FROM public."Currency"
    WHERE LOWER(code) = LOWER(p_currency_code);
    
    RETURN COALESCE(v_decimals, 2);
END;
$$;
