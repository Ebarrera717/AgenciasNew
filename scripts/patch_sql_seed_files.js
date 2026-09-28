const fs = require('fs');
const path = require('path');

const bcryptHash = '$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2'; // admin123

// 1. AgenciasNew - SQL/Table/Alter_New_Columns.sql
const alterPath = path.join(__dirname, '..', 'SQL', 'Table', 'Alter_New_Columns.sql');
if (fs.existsSync(alterPath)) {
    let content = fs.readFileSync(alterPath, 'utf8');
    const oldSuperBlock = /-- Siembra obligatoria de Rol SUPERADMINISTRADOR[\s\S]*?END \${1,2};/m;
    const newSuperBlock = `-- Siembra obligatoria de Rol SUPERADMINISTRADOR y asignación fija a ebarrera@zagencias.com y ebarrrera@zagencias.com (password: admin123)
DO $$
DECLARE
    v_super_role_id INT;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Role') THEN
        IF NOT EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%') THEN
            INSERT INTO public."Role" (name, description, permissions, "isActive")
            VALUES ('SUPERADMINISTRADOR', 'Super Administrador con control total del sistema y gestión de módulos del sitio', '{"all": true, "superadmin": true}'::json, true);
        END IF;

        SELECT id INTO v_super_role_id FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%' LIMIT 1;

        IF v_super_role_id IS NOT NULL AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'User') THEN
            -- 1. ebarrera@zagencias.com
            IF NOT EXISTS (SELECT 1 FROM public."User" WHERE LOWER(email) = 'ebarrera@zagencias.com') THEN
                INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
                VALUES ('Eduardo Barrera', 'ebarrera@zagencias.com', '${bcryptHash}', v_super_role_id, true);
            ELSE
                UPDATE public."User"
                SET "name" = 'Eduardo Barrera',
                    "passwordHash" = '${bcryptHash}',
                    "roleId" = v_super_role_id,
                    "isActive" = true
                WHERE LOWER(email) = 'ebarrera@zagencias.com';
            END IF;

            -- 2. ebarrrera@zagencias.com
            IF NOT EXISTS (SELECT 1 FROM public."User" WHERE LOWER(email) = 'ebarrrera@zagencias.com') THEN
                INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
                VALUES ('Eduardo Barrera', 'ebarrrera@zagencias.com', '${bcryptHash}', v_super_role_id, true);
            ELSE
                UPDATE public."User"
                SET "name" = 'Eduardo Barrera',
                    "passwordHash" = '${bcryptHash}',
                    "roleId" = v_super_role_id,
                    "isActive" = true
                WHERE LOWER(email) = 'ebarrrera@zagencias.com';
            END IF;
        END IF;
    END IF;
END $$;`;

    if (oldSuperBlock.test(content)) {
        // String replacement function prevents $ replacement pattern issues
        content = content.replace(oldSuperBlock, () => newSuperBlock);
        fs.writeFileSync(alterPath, content, 'utf8');
        console.log('✅ Alter_New_Columns.sql actualizado correctamente con $$');
    }
}
