DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImplantCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImplantCrear(
    p_code TEXT,
    p_name TEXT,
    p_logo BYTEA,
    p_template BYTEA,
    p_template_config JSONB,
    p_html_template TEXT,
    p_branch_id INT,
    p_resolution_id INT DEFAULT NULL,
    p_invoice_template BYTEA DEFAULT NULL,
    p_invoice_template_config JSONB DEFAULT NULL,
    p_invoice_html_template TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT true,
    p_acting_user_id INT DEFAULT 1,
    INOUT p_implant_id INT DEFAULT 0,
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public."Implant" (
        "code", "name", "logo", "template", "templateConfig", "htmlTemplate", "branchId",
        "resolutionId", "invoiceTemplate", "invoiceTemplateConfig", "invoiceHtmlTemplate", "isActive"
    )
    VALUES (
        p_code, p_name, p_logo, p_template, p_template_config, p_html_template, p_branch_id,
        p_resolution_id, p_invoice_template, p_invoice_template_config, p_invoice_html_template, COALESCE(p_is_active, true)
    )
    RETURNING id INTO p_implant_id;

    p_mensaje_resultado := 'SUCCESS: Implant creado con ID ' || p_implant_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
