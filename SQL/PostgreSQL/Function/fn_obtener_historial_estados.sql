DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fn_obtener_historial_estados'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- Crear función para obtener el historial de estados de una cotización con metadata de cambios
CREATE OR REPLACE FUNCTION public.fn_obtener_historial_estados(p_quotation_id INT)
RETURNS TABLE (
    id INT,
    state VARCHAR(25),
    description TEXT,
    "createdAt" TIMESTAMP,
    "userId" INT,
    "userName" TEXT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        qsh.id,
        qsh.state,
        qsh.description,
        qsh."createdAt",
        qsh."userId",
        COALESCE(u.name, 'Sistema'::TEXT) AS "userName",
        qsh.metadata
    FROM public."QuotationStateHistory" qsh
    LEFT JOIN public."User" u ON qsh."userId" = u.id
    WHERE qsh."quotationId" = p_quotation_id
    ORDER BY qsh."createdAt" DESC, qsh.id DESC;
END;
$$ LANGUAGE plpgsql;
