DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spClienteEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spClienteEliminar(
    p_id INT,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
AS $BODY$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT name INTO v_name FROM public."Client" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El cliente no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."Quotation" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."Invoices" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."PreQuotation" WHERE "clientId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el cliente "' || v_name || '" porque cuenta con ' || v_count || ' registro(s) de cotizaciones o facturas asociadas. Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Client" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Cliente eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$BODY$
LANGUAGE plpgsql;
