DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spProductoEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spProductoEliminar(
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
    SELECT description INTO v_name FROM public."Product" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El producto especificado no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."QuotationProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."InvoicesProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."ComboProduct" WHERE "productId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el producto "' || v_name || '" porque ya se encuentra registrado en ' || v_count || ' cotización(es) o factura(s). Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Product" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Producto eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
