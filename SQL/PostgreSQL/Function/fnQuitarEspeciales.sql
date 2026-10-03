DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnQuitarEspeciales'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnQuitarEspeciales"(texto TEXT)
RETURNS TEXT AS $$
BEGIN
    IF texto IS NULL THEN
        RETURN NULL;
    END IF;

    -- Reemplaza cualquier carácter que NO sea letra, número o espacio por un espacio ' '
    -- Incluye soporte para letras con tildes y ñ (a-zA-Z0-9áéíóúÁÉÍÓÚñÑ)
    RETURN REGEXP_REPLACE(texto, '[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]', ' ', 'g');
END;
$$ LANGUAGE plpgsql IMMUTABLE;
