const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const rootPath = path.join(__dirname, '..');
require('dotenv').config({ path: path.join(rootPath, '.env') });

let host = 'localhost';
let port = '5432';
let database = 'korex_db';
let user = 'postgres';
let password = '';

const pgUrl = process.env.DATABASE_URL_POSTGRES || (process.env.DATABASE_URL && process.env.DATABASE_URL.startsWith('postgresql://') ? process.env.DATABASE_URL : 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public');

if (pgUrl) {
    try {
        const parsedUrl = new URL(pgUrl);
        host = parsedUrl.hostname || 'localhost';
        port = parsedUrl.port || '5432';
        database = parsedUrl.pathname.replace(/^\//, '') || 'korex_db';
        user = parsedUrl.username || 'postgres';
        password = decodeURIComponent(parsedUrl.password || '');
    } catch (e) {
        const match = process.env.DATABASE_URL.match(/postgresql:\/\/([^:]+):([^@]*)@([^:]+):([0-9]+)\/([^?]+)/);
        if (match) {
            user = match[1];
            password = decodeURIComponent(match[2]);
            host = match[3];
            port = match[4];
            database = match[5];
        }
    }
}

async function exportSchema() {
    // 0. Ejecutar validación y preparación automatizada de esquema antes de compilar
    try {
        const validatorPath = path.join(__dirname, 'validate_schema_before_package.js');
        if (fs.existsSync(validatorPath)) {
            const { execSync } = require('child_process');
            console.log("[Schema Generator] Ejecutando validación pre-compilación de esquema...");
            execSync(`node "${validatorPath}"`, { stdio: 'inherit', cwd: rootPath });
        }
    } catch (valErr) {
        console.error("[Schema Generator] ERROR EN VALIDADOR PRE-COMPILACION:", valErr.message);
        process.exit(1);
    }

    console.log(`[Schema Generator] Conectando a la base de datos de desarrollo: ${database} en ${host}:${port}...`);
    const client = new Client({
        connectionString: pgUrl
    });

    try {
        await client.connect();

        const schema = {
            metadata: {
                generatedAt: new Date().toISOString(),
                databaseName: database
            },
            tables: {},
            indexes: {},
            routines: {}
        };

        // 1. Obtener Tablas y Columnas
        console.log("  -> Consultando tablas y columnas...");
        const colsRes = await client.query(`
            SELECT 
                table_name,
                column_name,
                data_type,
                character_maximum_length,
                is_nullable,
                column_default
            FROM information_schema.columns
            WHERE table_schema = 'public'
            ORDER BY table_name, ordinal_position;
        `);

        for (const row of colsRes.rows) {
            const tbl = row.table_name;
            if (!schema.tables[tbl]) {
                schema.tables[tbl] = {
                    columns: {},
                    primaryKey: [],
                    foreignKeys: [],
                    uniques: []
                };
            }
            schema.tables[tbl].columns[row.column_name] = {
                dataType: row.data_type,
                maxLength: row.character_maximum_length,
                isNullable: row.is_nullable,
                columnDefault: row.column_default
            };
        }

        // 2. Obtener Constraints (Primary Keys, Foreign Keys, Uniques)
        console.log("  -> Consultando constraints (PKs, FKs, Uniques)...");
        const constRes = await client.query(`
            SELECT
                tc.constraint_name, 
                tc.table_name, 
                kcu.column_name, 
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name,
                tc.constraint_type
            FROM information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            LEFT JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
            WHERE tc.table_schema = 'public'
              AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE');
        `);

        for (const row of constRes.rows) {
            const tbl = row.table_name;
            if (!schema.tables[tbl]) continue;

            const cType = row.constraint_type;
            if (cType === 'PRIMARY KEY') {
                if (!schema.tables[tbl].primaryKey.includes(row.column_name)) {
                    schema.tables[tbl].primaryKey.push(row.column_name);
                }
            } else if (cType === 'FOREIGN KEY') {
                // Verificar si ya existe este foreign key para no duplicar en claves compuestas
                const exists = schema.tables[tbl].foreignKeys.some(fk => 
                    fk.constraintName === row.constraint_name && fk.columnName === row.column_name
                );
                if (!exists) {
                    schema.tables[tbl].foreignKeys.push({
                        constraintName: row.constraint_name,
                        columnName: row.column_name,
                        foreignTable: row.foreign_table_name,
                        foreignColumn: row.foreign_column_name
                    });
                }
            } else if (cType === 'UNIQUE') {
                const exists = schema.tables[tbl].uniques.some(u => 
                    u.constraintName === row.constraint_name && u.columnName === row.column_name
                );
                if (!exists) {
                    schema.tables[tbl].uniques.push({
                        constraintName: row.constraint_name,
                        columnName: row.column_name
                    });
                }
            }
        }

        // 3. Obtener Índices (excluyendo los creados automáticamente por PKs)
        console.log("  -> Consultando índices...");
        const idxRes = await client.query(`
            SELECT
                tablename,
                indexname,
                indexdef
            FROM pg_indexes
            WHERE schemaname = 'public'
              AND indexname NOT IN (
                  SELECT constraint_name FROM information_schema.table_constraints WHERE table_schema = 'public'
              );
        `);

        for (const row of idxRes.rows) {
            schema.indexes[row.indexname] = {
                tableName: row.tablename,
                definition: row.indexdef
            };
        }

        // 4. Obtener Funciones y Stored Procedures (definiciones DDL)
        console.log("  -> Consultando funciones y procedimientos...");
        const funcRes = await client.query(`
            SELECT 
                p.proname AS name,
                n.nspname AS schema,
                pg_get_functiondef(p.oid) AS definition,
                t.typname AS return_type,
                p.prokind AS kind
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            JOIN pg_type t ON p.prorettype = t.oid
            WHERE n.nspname = 'public' 
              AND p.prokind IN ('f', 'p');
        `);

        for (const row of funcRes.rows) {
            // Filtrar funciones internas o de librerías comunes (como uuid-ossp o prisma si las hay)
            if (row.name.startsWith('pg_') || row.name.startsWith('uuid_')) continue;
            
            schema.routines[row.name] = {
                kind: row.kind === 'p' ? 'PROCEDURE' : 'FUNCTION',
                returnType: row.return_type,
                definition: row.definition
            };
        }

        // Guardar schema_reference.json en la carpeta SQL
        const sqlDir = path.join(rootPath, 'SQL');
        if (!fs.existsSync(sqlDir)) {
            fs.mkdirSync(sqlDir, { recursive: true });
        }
        
        const schemaFile = path.join(sqlDir, 'schema_reference.json');
        fs.writeFileSync(schemaFile, JSON.stringify(schema, null, 2), 'utf8');
        console.log(`[Schema Generator] EXITO: Archivo descriptor guardado en: ${schemaFile} (${fs.statSync(schemaFile).size} bytes)`);

        await client.end();
        process.exit(0);

    } catch (err) {
        console.error("[Schema Generator] ERROR CRITICO al extraer esquema:", err.message);
        process.exit(1);
    }
}

exportSchema();
