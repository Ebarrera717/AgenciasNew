DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnGetSQLServerConfig'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION "fnGetSQLServerConfig"()
RETURNS TABLE (
    servidor TEXT,
    usuario TEXT,
    clave TEXT,
    base_datos TEXT,
    puerto TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT value FROM "SystemParameter" WHERE code = 'ServidorSQLServer') as servidor,
        (SELECT value FROM "SystemParameter" WHERE code = 'UsuarioSQLServer') as usuario,
        (SELECT value FROM "SystemParameter" WHERE code = 'ClaveSQLServer') as clave,
        (SELECT value FROM "SystemParameter" WHERE code = 'BaseSQLServer') as base_datos,
        (SELECT value FROM "SystemParameter" WHERE code = 'PuertoSQLServer') as puerto;
END;
$$ LANGUAGE plpgsql;
