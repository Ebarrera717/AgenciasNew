DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnRoleListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

-- =============================================
-- Función: fnRoleListar
-- Descripción: Consulta el listado de roles con su matriz de permisos y conteo de usuarios asignados.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE FUNCTION public."fnRoleListar"()
RETURNS TABLE (
    id INT,
    name VARCHAR,
    description TEXT,
    permissions JSONB,
    user_count BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name::VARCHAR,
        COALESCE(r.description, '')::TEXT,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB,
        COUNT(u.id)::BIGINT AS user_count
    FROM public."Role" r
    LEFT JOIN public."User" u ON u."roleId" = r.id
    GROUP BY r.id, r.name, r.description, r.permissions
    ORDER BY r.id ASC;
END;
$$;
