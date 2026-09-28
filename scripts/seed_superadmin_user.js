const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const bcryptHash = '$2b$10$AVrdrbg93Vxi1zrUw4EZguaJZzV4BiVmYk/kiGM8CesmbzyfIcbG2'; // admin123

async function run() {
    console.log('--- Iniciando siembra fija de ebarrera@zagencias.com y ebarrrera@zagencias.com ---');

    // 1. Inyectar directamente en PostgreSQL local (Korex_colaereo)
    const pgUrl = 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
    try {
        const client = new Client({ connectionString: pgUrl });
        await client.connect();
        
        // Rol
        await client.query(`
            INSERT INTO public."Role" (name, description, permissions, "isActive")
            VALUES ('SUPERADMINISTRADOR', 'Super Administrador con control total del sistema y gestión de módulos del sitio', '{"all": true, "superadmin": true}'::json, true)
            ON CONFLICT (name) DO NOTHING;
        `);

        const roleRes = await client.query(`SELECT id FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%' LIMIT 1;`);
        const roleId = roleRes.rows[0]?.id || 1;

        // ebarrera@zagencias.com
        await client.query(`
            INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
            VALUES ('Eduardo Barrera', 'ebarrera@zagencias.com', $1, $2, true)
            ON CONFLICT (email) DO UPDATE SET
                name = EXCLUDED.name,
                "passwordHash" = EXCLUDED."passwordHash",
                "roleId" = EXCLUDED."roleId",
                "isActive" = true;
        `, [bcryptHash, roleId]);

        // ebarrrera@zagencias.com
        await client.query(`
            INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
            VALUES ('Eduardo Barrera', 'ebarrrera@zagencias.com', $1, $2, true)
            ON CONFLICT (email) DO UPDATE SET
                name = EXCLUDED.name,
                "passwordHash" = EXCLUDED."passwordHash",
                "roleId" = EXCLUDED."roleId",
                "isActive" = true;
        `, [bcryptHash, roleId]);

        console.log('✅ Usuarios sembrados y actualizados exitosamente en PostgreSQL (Korex_colaereo).');
        await client.end();
    } catch (err) {
        console.warn('⚠️ Nota Postgres:', err.message);
    }

    // 2. Inyectar directamente en PostgreSQL local (Korex_contabilidad_pg)
    const pgContabUrl = 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_contabilidad_pg?schema=public';
    try {
        const clientContab = new Client({ connectionString: pgContabUrl });
        await clientContab.connect();

        await clientContab.query(`
            INSERT INTO public."Role" (name, description, permissions, "isActive")
            VALUES ('SUPERADMINISTRADOR', 'Super Administrador con control total del sistema y gestión de módulos del sitio', '{"all": true, "superadmin": true}'::json, true)
            ON CONFLICT (name) DO NOTHING;
        `);

        const roleResContab = await clientContab.query(`SELECT id FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%' LIMIT 1;`);
        const roleIdContab = roleResContab.rows[0]?.id || 1;

        await clientContab.query(`
            INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
            VALUES ('Eduardo Barrera', 'ebarrera@zagencias.com', $1, $2, true)
            ON CONFLICT (email) DO UPDATE SET
                name = EXCLUDED.name,
                "passwordHash" = EXCLUDED."passwordHash",
                "roleId" = EXCLUDED."roleId",
                "isActive" = true;
        `, [bcryptHash, roleIdContab]);

        await clientContab.query(`
            INSERT INTO public."User" (name, email, "passwordHash", "roleId", "isActive")
            VALUES ('Eduardo Barrera', 'ebarrrera@zagencias.com', $1, $2, true)
            ON CONFLICT (email) DO UPDATE SET
                name = EXCLUDED.name,
                "passwordHash" = EXCLUDED."passwordHash",
                "roleId" = EXCLUDED."roleId",
                "isActive" = true;
        `, [bcryptHash, roleIdContab]);

        console.log('✅ Usuarios sembrados y actualizados exitosamente en PostgreSQL (Korex_contabilidad_pg).');
        await clientContab.end();
    } catch (err) {
        console.warn('⚠️ Nota Postgres Contabilidad:', err.message);
    }
}

run();
