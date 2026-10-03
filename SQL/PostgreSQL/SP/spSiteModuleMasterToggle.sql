DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spSiteModuleMasterToggle'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spSiteModuleMasterToggle"(
    p_type text,
    p_id integer,
    p_active boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF UPPER(p_type) = 'MENU' THEN
        UPDATE public."Menu"
        SET activo = p_active
        WHERE id = p_id;
    ELSIF UPPER(p_type) = 'MASTER' THEN
        UPDATE public."Master"
        SET inactivo = NOT p_active
        WHERE id = p_id;
    ELSE
        RAISE EXCEPTION 'Tipo no válido: %. Se requiere MENU o MASTER.', p_type;
    END IF;
END;
$$;
