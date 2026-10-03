DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnUserPermissions'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Función: fnUserPermissions
-- Descripción: Retorna el rol y la matriz de permisos JSON de un usuario desde la base de datos PostgreSQL.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE FUNCTION public."fnUserPermissions"(p_user_id INT)
RETURNS TABLE (
    user_id INT,
    role_id INT,
    role_name VARCHAR,
    permissions JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        r.id AS role_id,
        r.name::VARCHAR AS role_name,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB AS permissions
    FROM public."User" u
    JOIN public."Role" r ON u."roleId" = r.id
    WHERE u.id = p_user_id;
END;
$$;
