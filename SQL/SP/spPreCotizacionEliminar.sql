DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spPreCotizacionEliminar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spPreCotizacionEliminar
-- Descripción: Elimina una pre-cotización y su historial en PostgreSQL.
--              Resetea la secuencia si la tabla queda vacía.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spPreCotizacionEliminar"(
    IN p_id INT,
    OUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."PreQuotation" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Pre-Cotización ' || p_id || ' no existe.';
        RETURN;
    END IF;

    DELETE FROM public."PreQuotationStateHistory" WHERE "preQuotationId" = p_id;
    DELETE FROM public."PreQuotation" WHERE id = p_id;

    -- Reseteo de secuencia si la tabla queda totalmente vacía
    IF NOT EXISTS (SELECT 1 FROM public."PreQuotation") THEN
        PERFORM setval('public."PreQuotation_id_seq"', 1, false);
    END IF;

    p_mensaje_resultado := 'SUCCESS: Pre-Cotización eliminada correctamente';
END;
$$;
