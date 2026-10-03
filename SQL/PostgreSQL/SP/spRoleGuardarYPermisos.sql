DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spRoleGuardarYPermisos'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

-- =============================================
-- Procedimiento Almacenado: spRoleGuardarYPermisos
-- Descripción: Procedimiento en PostgreSQL para crear, actualizar y gestionar los permisos de los roles.
-- Base de Datos: PostgreSQL (Korex_colaereo)
-- =============================================
CREATE OR REPLACE PROCEDURE public."spRoleGuardarYPermisos"(
    IN p_id INT,
    IN p_name VARCHAR,
    IN p_description TEXT,
    IN p_permissions JSONB,
    OUT p_res_id INT,
    OUT p_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
BEGIN
    v_name := TRIM(p_name);
    
    IF v_name IS NULL OR v_name = '' THEN
        p_res_id := 0;
        p_message := 'El nombre del rol no puede estar vacío.';
        RETURN;
    END IF;

    -- Si p_id es nulo o 0 -> Crear Nuevo Rol
    IF p_id IS NULL OR p_id = 0 THEN
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name)) THEN
            p_res_id := 0;
            p_message := 'Ya existe un rol registrado con ese nombre.';
            RETURN;
        END IF;

        INSERT INTO public."Role" (name, description, permissions)
        VALUES (v_name, TRIM(p_description), COALESCE(p_permissions, '{}'::jsonb))
        RETURNING id INTO p_res_id;

        p_message := 'Rol creado exitosamente en la base de datos.';
        RETURN;
    ELSE
        -- Actualizar Rol Existente
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name) AND id <> p_id) THEN
            p_res_id := 0;
            p_message := 'El nombre especificado ya está en uso por otro rol.';
            RETURN;
        END IF;

        UPDATE public."Role"
        SET name = v_name,
            description = TRIM(p_description),
            permissions = COALESCE(p_permissions, permissions)
        WHERE id = p_id;

        p_res_id := p_id;
        p_message := 'Rol y matriz de permisos actualizados correctamente.';
        RETURN;
    END IF;
END;
$$;
