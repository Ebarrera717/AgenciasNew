DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spImplantActualizar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spImplantActualizar(
    p_id INT,
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
    INOUT p_mensaje_resultado TEXT DEFAULT ''
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Implant" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Implant con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."Implant"
    SET "code" = p_code,
        "name" = p_name,
        "logo" = COALESCE(p_logo, "logo"),
        "template" = COALESCE(p_template, "template"),
        "templateConfig" = COALESCE(p_template_config, "templateConfig"),
        "htmlTemplate" = COALESCE(p_html_template, "htmlTemplate"),
        "branchId" = p_branch_id,
        "resolutionId" = p_resolution_id,
        "invoiceTemplate" = COALESCE(p_invoice_template, "invoiceTemplate"),
        "invoiceTemplateConfig" = COALESCE(p_invoice_template_config, "invoiceTemplateConfig"),
        "invoiceHtmlTemplate" = COALESCE(p_invoice_html_template, "invoiceHtmlTemplate"),
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Implant actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
