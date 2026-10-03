DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spUsuarioCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spUsuarioCrear(
    p_name TEXT,
    p_email TEXT,
    p_password_hash TEXT,
    p_role_id INT,
    p_branch_id INT,
    p_implant_id INT,
    p_ticket_printer_id INT,
    p_acting_user_id INT,
    INOUT p_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar si el email ya existe
    IF EXISTS (SELECT 1 FROM public."User" WHERE email = p_email) THEN
        p_mensaje_resultado := 'ERROR: El email ' || p_email || ' ya está registrado.';
        RETURN;
    END IF;

    INSERT INTO public."User" (
        "name", 
        "email", 
        "passwordHash", 
        "roleId", 
        "branchId", 
        "implantId", 
        "ticketPrinterId"
    )
    VALUES (
        p_name, 
        p_email, 
        p_password_hash, 
        p_role_id, 
        p_branch_id, 
        p_implant_id, 
        p_ticket_printer_id
    )
    RETURNING id INTO p_user_id;

    p_mensaje_resultado := 'SUCCESS: Usuario creado con ID ' || p_user_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
