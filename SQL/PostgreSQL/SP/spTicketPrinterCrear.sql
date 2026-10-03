DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spTicketPrinterCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spTicketPrinterCrear(
    p_code TEXT,
    p_name TEXT,
    p_email TEXT,
    p_acting_user_id INT,
    INOUT p_printer_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."TicketPrinter" ("code", "name", "email")
    VALUES (p_code, p_name, p_email)
    RETURNING id INTO p_printer_id;

    p_mensaje_resultado := 'SUCCESS: Tiqueteador creado con ID ' || p_printer_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
