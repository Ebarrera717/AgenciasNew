DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spClienteCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spClienteCrear(
    p_name TEXT,
    p_document TEXT,
    p_contact_info TEXT,
    p_address TEXT,
    p_mandatory_variables JSONB,
    p_acting_user_id INT,
    p_seller_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_credit_days INT DEFAULT 0,
    INOUT p_client_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Client" WHERE document = p_document) THEN
        p_mensaje_resultado := 'ERROR: El documento ya está registrado';
        RETURN;
    END IF;

    INSERT INTO public."Client" ("name", "document", "contactInfo", "address", "mandatoryVariables", "sellerId", "isActive", "creditDays")
    VALUES (p_name, p_document, p_contact_info, p_address, p_mandatory_variables, p_seller_id, COALESCE(p_is_active, true), COALESCE(p_credit_days, 0))
    RETURNING id INTO p_client_id;

    p_mensaje_resultado := 'SUCCESS: Cliente creado con ID ' || p_client_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$BODY$
LANGUAGE plpgsql;
