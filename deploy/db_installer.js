const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

function resolvePath(subFolder, filename) {
    const paths = [
        path.join(__dirname, subFolder, filename),
        path.join(__dirname, '..', subFolder, filename),
        path.join(__dirname, '..', filename)
    ];
    for (const p of paths) {
        if (fs.existsSync(p)) return p;
    }
    return paths[0]; // fallback
}

const host = process.argv[2] && process.argv[2] !== '' ? process.argv[2] : 'localhost';
const port = process.argv[3] && process.argv[3] !== '' ? process.argv[3] : '5432';
const database = process.argv[4] && process.argv[4] !== '' ? process.argv[4] : 'korex_db';
const user = process.argv[5] && process.argv[5] !== '' ? process.argv[5] : 'postgres';
const password = process.argv[6] || '';

// Colores de consola para mejor visualización de diagnóstico
const colors = {
    reset: "\x1b[0m",
    bright: "\x1b[1m",
    green: "\x1b[32m",
    yellow: "\x1b[33m",
    red: "\x1b[31m",
    cyan: "\x1b[36m",
    gray: "\x1b[90m"
};

async function run() {
    console.log(`\n${colors.bright}${colors.cyan}======================================================`);
    console.log(`  SISTEMA DE DIAGNÓSTICO Y COMPARACIÓN DE BASE DE DATOS`);
    console.log(`======================================================${colors.reset}`);
    console.log(`Conexión destino: ${user}@${host}:${port}/${database}\n`);
    
    // 1. Validar / Crear base de datos
    const adminClient = new Client({ 
        connectionString: `postgresql://${encodeURIComponent(user)}:${encodeURIComponent(password)}@${host}:${port}/postgres` 
    });
    
    try {
        await adminClient.connect();
        const res = await adminClient.query(`SELECT datname FROM pg_catalog.pg_database WHERE datname = $1;`, [database]);
        if (res.rowCount === 0) {
            console.log(`${colors.yellow}[+] Creando la base de datos '${database}' por primera vez...${colors.reset}`);
            await adminClient.query(`CREATE DATABASE "${database}";`);
        } else {
            console.log(`${colors.green}[OK] La base de datos '${database}' existe.${colors.reset}`);
        }
        await adminClient.end();
    } catch (e) {
        console.error(`${colors.red}[ERROR CRÍTICO] Falló la conexión al servicio PostgreSQL maestro.${colors.reset}`);
        console.error(`DETALLE: ${e.message}`);
        process.exit(1);
    }

    // 2. Conectarse a la BD de trabajo
    const dbClient = new Client({ 
        connectionString: `postgresql://${encodeURIComponent(user)}:${encodeURIComponent(password)}@${host}:${port}/${database}` 
    });
    
    try {
        await dbClient.connect();
    } catch (e) {
        console.error(`${colors.red}[ERROR CRÍTICO] No se pudo conectar a la base de datos '${database}' recién creada/verificada.${colors.reset}`);
        console.error(e.message);
        process.exit(1);
    }

    // 3. Comparador de Esquemas Inteligente (schema_reference.json) - EJECUTADO PRIMERO
    const schemaFile = resolvePath('SQL', 'schema_reference.json');
    if (fs.existsSync(schemaFile)) {
        console.log(`\n${colors.bright}[1/4] Iniciando comparación de esquemas con el perfil de desarrollo...${colors.reset}`);
        try {
            const refSchema = JSON.parse(fs.readFileSync(schemaFile, 'utf8'));
            
            // A. Consultar la estructura actual del cliente
            const liveCols = await dbClient.query(`
                SELECT 
                    table_name,
                    column_name,
                    data_type,
                    character_maximum_length,
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_schema = 'public';
            `);
            
            const liveSchema = {};
            for (const row of liveCols.rows) {
                const tbl = row.table_name;
                if (!liveSchema[tbl]) {
                    liveSchema[tbl] = { columns: {} };
                }
                liveSchema[tbl].columns[row.column_name] = {
                    dataType: row.data_type,
                    maxLength: row.character_maximum_length,
                    isNullable: row.is_nullable,
                    columnDefault: row.column_default
                };
            }

            let changesApplied = 0;
            let warningsCount = 0;

            // B. Comparar tabla por tabla y columna por columna
            for (const [tblName, tblMeta] of Object.entries(refSchema.tables)) {
                // Si la tabla no existe en el cliente
                if (!liveSchema[tblName]) {
                    console.log(`  ${colors.yellow}[ADD TABLE] Creando tabla faltante: public."${tblName}"...${colors.reset}`);
                    
                    // Crear secuencias previas si hay columnas de tipo nextval
                    for (const [colName, colMeta] of Object.entries(tblMeta.columns)) {
                        if (colMeta.columnDefault && colMeta.columnDefault.includes('nextval')) {
                            const seqMatch = colMeta.columnDefault.match(/nextval\('"?([^"']+)"?'::regclass\)/i);
                            if (seqMatch) {
                                const seqName = seqMatch[1].replace(/^public\./, '').replace(/"/g, '');
                                try {
                                    await dbClient.query(`CREATE SEQUENCE IF NOT EXISTS public."${seqName}";`);
                                } catch (seqErr) {}
                            }
                        }
                    }

                    // Reconstruir CREATE TABLE desde el descriptor
                    const colDefs = [];
                    for (const [colName, colMeta] of Object.entries(tblMeta.columns)) {
                        colDefs.push(getColumnSqlDefinition(colName, colMeta));
                    }
                    
                    // Añadir llaves primarias
                    if (tblMeta.primaryKey && tblMeta.primaryKey.length > 0) {
                        const pkCols = tblMeta.primaryKey.map(pk => `"${pk}"`).join(', ');
                        colDefs.push(`CONSTRAINT "${tblName}_pkey" PRIMARY KEY (${pkCols})`);
                    }
                    
                    const createTableSql = `CREATE TABLE public."${tblName}" (\n  ${colDefs.join(',\n  ')}\n);`;
                    try {
                        await dbClient.query(createTableSql);
                        console.log(`    ${colors.green}[OK] Tabla "${tblName}" creada con éxito.${colors.reset}`);
                        changesApplied++;
                    } catch (err) {
                        console.error(`    ${colors.red}[ERROR] Falló crear la tabla "${tblName}": ${err.message}${colors.reset}`);
                        warningsCount++;
                    }
                    continue;
                }

                // Si la tabla existe, comparar columnas
                for (const [colName, colMeta] of Object.entries(tblMeta.columns)) {
                    const liveCol = liveSchema[tblName].columns[colName];
                    
                    // Si la columna no existe en el cliente
                    if (!liveCol) {
                        if (colMeta.columnDefault && colMeta.columnDefault.includes('nextval')) {
                            const seqMatch = colMeta.columnDefault.match(/nextval\('"?([^"']+)"?'::regclass\)/i);
                            if (seqMatch) {
                                const seqName = seqMatch[1].replace(/^public\./, '').replace(/"/g, '');
                                try {
                                    await dbClient.query(`CREATE SEQUENCE IF NOT EXISTS public."${seqName}";`);
                                } catch (seqErr) {}
                            }
                        }
                        const colDefSql = getColumnSqlDefinitionForAdd(colName, colMeta);
                        const addColSql = `ALTER TABLE public."${tblName}" ADD COLUMN ${colDefSql};`;
                        console.log(`  ${colors.yellow}[ADD COLUMN] Tabla "${tblName}": agregando campo faltante "${colName}"...${colors.reset}`);
                        try {
                            await dbClient.query(addColSql);
                            console.log(`    ${colors.green}[OK] Columna "${colName}" agregada.${colors.reset}`);
                            changesApplied++;
                        } catch (err) {
                            console.error(`    ${colors.red}[ERROR] Falló agregar columna "${colName}": ${err.message}${colors.reset}`);
                            warningsCount++;
                        }
                        continue;
                    }

                    // Comparar tipo de datos, nullability y valor por defecto
                    let needsAlterType = false;
                    let needsAlterNull = false;
                    let needsAlterDefault = false;

                    // Normalizar tipos comunes para evitar falsos positivos
                    const refType = normalizeDataType(colMeta.dataType);
                    const curType = normalizeDataType(liveCol.dataType);

                    if (refType !== curType || (colMeta.maxLength && colMeta.maxLength !== liveCol.maxLength)) {
                        needsAlterType = true;
                    }
                    if (colMeta.isNullable !== liveCol.isNullable) {
                        needsAlterNull = true;
                    }
                    if (colMeta.columnDefault !== null && colMeta.columnDefault !== undefined && (!liveCol.columnDefault || liveCol.columnDefault === null)) {
                        needsAlterDefault = true;
                    }

                    if (needsAlterType) {
                        let typeSql = colMeta.dataType;
                        if (colMeta.maxLength && colMeta.dataType.includes('char')) {
                            typeSql += `(${colMeta.maxLength})`;
                        }
                        const alterTypeSql = `ALTER TABLE public."${tblName}" ALTER COLUMN "${colName}" TYPE ${typeSql} USING "${colName}"::${colMeta.dataType};`;
                        console.log(`  ${colors.cyan}[MODIFY TYPE] Tabla "${tblName}": cambiando tipo de "${colName}" de [${liveCol.dataType}] a [${colMeta.dataType}]...${colors.reset}`);
                        try {
                            await dbClient.query(alterTypeSql);
                            console.log(`    ${colors.green}[OK] Tipo actualizado.${colors.reset}`);
                            changesApplied++;
                        } catch (err) {
                            console.error(`    ${colors.red}[AVISO] No se pudo cambiar tipo automáticamente en "${tblName}.${colName}": ${err.message}${colors.reset}`);
                            warningsCount++;
                        }
                    }

                    if (needsAlterDefault) {
                        if (colMeta.columnDefault.includes('nextval')) {
                            const seqMatch = colMeta.columnDefault.match(/nextval\('"?([^"']+)"?'::regclass\)/i);
                            if (seqMatch) {
                                const seqName = seqMatch[1].replace(/^public\./, '').replace(/"/g, '');
                                try {
                                    await dbClient.query(`CREATE SEQUENCE IF NOT EXISTS public."${seqName}";`);
                                } catch (seqErr) {}
                            }
                        }
                        const alterDefSql = `ALTER TABLE public."${tblName}" ALTER COLUMN "${colName}" SET DEFAULT ${colMeta.columnDefault};`;
                        console.log(`  ${colors.cyan}[MODIFY DEFAULT] Tabla "${tblName}": restaurando DEFAULT en "${colName}" -> ${colMeta.columnDefault}...${colors.reset}`);
                        try {
                            await dbClient.query(alterDefSql);
                            console.log(`    ${colors.green}[OK] Valor por defecto actualizado.${colors.reset}`);
                            changesApplied++;
                        } catch (err) {
                            console.error(`    ${colors.red}[ERROR] Falló configurar DEFAULT en "${tblName}.${colName}": ${err.message}${colors.reset}`);
                            warningsCount++;
                        }
                    }

                    if (needsAlterNull) {
                        const nullSql = colMeta.isNullable === 'NO' ? 'SET NOT NULL' : 'DROP NOT NULL';
                        const alterNullSql = `ALTER TABLE public."${tblName}" ALTER COLUMN "${colName}" ${nullSql};`;
                        console.log(`  ${colors.cyan}[MODIFY NULL] Tabla "${tblName}": cambiando nulidad de "${colName}" a ${colMeta.isNullable === 'NO' ? 'NOT NULL' : 'NULL'}...${colors.reset}`);
                        try {
                            await dbClient.query(alterNullSql);
                            console.log(`    ${colors.green}[OK] Nulidad actualizada.${colors.reset}`);
                            changesApplied++;
                        } catch (err) {
                            console.error(`    ${colors.red}[ERROR] Falló cambiar nulidad en "${tblName}.${colName}": ${err.message}${colors.reset}`);
                            warningsCount++;
                        }
                    }
                }
            }

            // C. Sincronizar Routines (Funciones y Procedimientos)
            console.log(`\n${colors.bright}[2/4] Sincronizando Funciones y Procedimientos Almacenados...${colors.reset}`);
            for (const [rtName, rtMeta] of Object.entries(refSchema.routines)) {
                try {
                    await dbClient.query(rtMeta.definition);
                    process.stdout.write(`${colors.gray}.`);
                } catch (err) {
                    try {
                        const kind = rtMeta.kind || 'FUNCTION';
                        await dbClient.query(`DROP ${kind} IF EXISTS public."${rtName}" CASCADE;`);
                        await dbClient.query(rtMeta.definition);
                        process.stdout.write(`${colors.gray}.`);
                    } catch (retryErr) {
                        process.stdout.write(`\n`);
                        console.error(`  ${colors.red}[ERROR SP] Error al recrear routine "${rtName}": ${retryErr.message}${colors.reset}`);
                        warningsCount++;
                    }
                }
            }
            console.log(`\n  ${colors.green}[OK] Funciones y SPs procesados.${colors.reset}`);

            // Reporte final de comparación
            console.log(`\n${colors.bright}Resultado de la comparación de esquemas:`);
            console.log(`  - Cambios automáticos aplicados con éxito: ${colors.green}${changesApplied}${colors.reset}`);
            console.log(`  - Advertencias / Errores que requieren validación manual: ${warningsCount > 0 ? colors.red : colors.green}${warningsCount}${colors.reset}`);
            
            if (warningsCount > 0) {
                console.log(`  ${colors.yellow}[!] Alerta: Se detectaron advertencias de inconsistencias de datos que impidieron cambios de tipos automáticos.`);
                console.log(`      Por favor revise los errores detallados arriba y el archivo 'install_log.txt'.${colors.reset}`);
            } else {
                console.log(`  ${colors.green}[OK] Esquema de la base de datos perfectamente sincronizado con el modelo de desarrollo.${colors.reset}`);
            }

        } catch (schemaErr) {
            console.error(`${colors.red}[ERROR COMPARADOR] Falló la lectura o parsing de schema_reference.json:${colors.reset}`, schemaErr.message);
            warningsCount++;
        }
    } else {
        console.log(`\n${colors.yellow}[!] No se detectó 'schema_reference.json'. El comparador avanzado de campos y tipos fue omitido.${colors.reset}`);
    }

    // 5. Insertar Semilla Inicial (Inicial.sql) - Ejecución sentencia por sentencia para evitar abortar el lote por llaves duplicadas
    const dataFile = resolvePath('SQL', 'Inicial.sql');
    if (fs.existsSync(dataFile)) {
        console.log(`\n${colors.bright}[4/5] Sembrando catálogos y datos iniciales requeridos (Inicial.sql)...${colors.reset}`);
        const sqlInit = fs.readFileSync(dataFile, 'utf8');
        const statements = sqlInit.split(/;\s*[\r\n]+/);
        let executedCount = 0;
        let skippedCount = 0;

        for (const stmt of statements) {
            const trimmed = stmt.trim();
            if (!trimmed || trimmed.startsWith('--')) continue;
            try {
                await dbClient.query(trimmed + ';');
                executedCount++;
            } catch (e) {
                if (e.code === '23505') {
                    skippedCount++;
                } else {
                    console.warn(`  ${colors.yellow}[!] Aviso ejecución instrucción inicial: ${e.message}${colors.reset}`);
                }
            }
        }
        console.log(`  ${colors.green}[OK] Semilla procesada: ${executedCount} sentencias ejecutadas, ${skippedCount} omitidas por existencia previa.${colors.reset}`);
    }

    // 6. Sincronización Forzada de Catálogos (Menu, Master, SystemParameter)
    console.log(`\n${colors.bright}[5/5] Garantizando siembra completa de Menús (8), Tablas Maestras (28) y Parámetros...${colors.reset}`);
    try {
        await dbClient.query(`
            CREATE UNIQUE INDEX IF NOT EXISTS "Menu_code_key" ON public."Menu" ("code");
            INSERT INTO public."Menu" (code, name, parent, action, activo)
            VALUES 
                ('DASHBOARD', 'Dashboard', NULL, '/dashboard', true),
                ('PRECOTIZACIONES', 'Pre-Cotizaciones', NULL, '/dashboard/prequotations', true),
                ('COTIZACIONES', 'Cotizaciones', NULL, '/dashboard/quotations/history', true),
                ('FACTURACION', 'Facturación', NULL, '/dashboard/invoices/history', true),
                ('MAESTROS', 'Maestros', NULL, '/dashboard/settings', true),
                ('REPORTES', 'Reportes', NULL, '/dashboard/reports', true),
                ('EJECUCIONES', 'Ejecuciones', NULL, '/dashboard/executions', true),
                ('MANUAL', 'Manual Operativo', NULL, '/dashboard/manual', true)
            ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

            CREATE UNIQUE INDEX IF NOT EXISTS "Master_code_key" ON public."Master" ("code");
            INSERT INTO public."Master" (code, name, "inactivo")
            VALUES
                ('SystemParameter', 'parametros', false),
                ('User', 'usuarios', false),
                ('Branch', 'sucursales', false),
                ('Implant', 'implantes', false),
                ('ChargeAndTax', 'impuestos', false),
                ('Seller', 'vendedores', false),
                ('TicketPrinter', 'tiqueteadores', false),
                ('Prestadora', 'prestadoras', false),
                ('Client', 'clientes', false),
                ('Provider', 'proveedores', false),
                ('ProviderType', 'tipos-proveedores', false),
                ('Product', 'productos', false),
                ('MasterVariable', 'variables', false),
                ('Combo', 'combos', false),
                ('SystemLog', 'logs', false),
                ('Currency', 'monedas', false),
                ('Equivalences', 'equivalencias', false),
                ('InterfaceExtractParam', 'extraccion-interfaces', false),
                ('DocumentResolution', 'resoluciones-documentos', false),
                ('TransactionConsecutive', 'consecutivos-transacciones', false),
                ('CreditCard', 'tarjetas-credito', false),
                ('Payment', 'formas-pago', false),
                ('Countries', 'paises', false),
                ('Cities', 'ciudades', false),
                ('Airports', 'aeropuertos', false),
                ('TicketType', 'tipos-tiquetes', false),
                ('QuotationState', 'estados-cotizacion', false),
                ('QuotationFormat', 'formatos-cotizacion', false)
            ON CONFLICT (code) DO NOTHING;

            CREATE UNIQUE INDEX IF NOT EXISTS "SystemParameter_code_key" ON public."SystemParameter" ("code");
            INSERT INTO public."SystemParameter" (code, name, value)
            VALUES
                ('ServidorSQLServer', 'Host de SQL Server', 'Rubiel/RUBIEL'),
                ('UsuarioSQLServer', 'Usuario SQL Server', 'sa'),
                ('ClaveSQLServer', 'Contraseña SQL Server', '111985*'),
                ('BaseSQLServer', 'Base de Datos SQL Server', 'Agencias'),
                ('PuertoSQLServer', 'Puerto SQL Server', ''),
                ('EnviarCotizacionesAutoSQLserver', 'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', '1'),
                ('EnviarFacturacionAutoSQLserver', 'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', '1'),
                ('Pais', 'Pais', 'Colombia'),
                ('MOSTRAR_TOTALIZACION_COTIZACION', 'Mostrar totalización financiera en cotización', 'true'),
                ('LICENSE_KEY', 'Clave de Licencia del Sistema', ''),
                ('AGENCY_NAME', 'Nombre o Razón Social de la Agencia', ''),
                ('AGENCY_NIT', 'NIT de la Agencia', ''),
                ('LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', '')
            ON CONFLICT (code) DO NOTHING;
        `);
        console.log(`  ${colors.green}[OK] Menús (8), Tablas Maestras (28) y Parámetros garantizados al 100%.${colors.reset}`);
    } catch (catErr) {
        console.warn(`  ${colors.yellow}[!] Aviso sincronizando catálogos: ${catErr.message}${colors.reset}`);
    }

    await dbClient.end();
    console.log(`\n${colors.bright}${colors.green}>> PROCESAMIENTO DE BASE DE DATOS FINALIZADO EXITOSAMENTE <<\n${colors.reset}`);
}

// Función auxiliar para reconstruir definición de columna
function getColumnSqlDefinition(colName, colMeta) {
    let sql = `"${colName}" ${colMeta.dataType}`;
    
    // Si contiene longitud máxima (varchar/char/etc)
    if (colMeta.maxLength && colMeta.dataType.includes('char')) {
        sql += `(${colMeta.maxLength})`;
    }
    
    // Valor por defecto
    if (colMeta.columnDefault !== null && colMeta.columnDefault !== undefined) {
        sql += ` DEFAULT ${colMeta.columnDefault}`;
    }

    // Nulidad
    if (colMeta.isNullable === 'NO') {
        sql += ' NOT NULL';
    } else {
        sql += ' NULL';
    }
    
    return sql;
}

// Función auxiliar para agregar columnas a tablas existentes sin romper por NOT NULL
function getColumnSqlDefinitionForAdd(colName, colMeta) {
    let sql = `"${colName}" ${colMeta.dataType}`;
    
    if (colMeta.maxLength && colMeta.dataType.includes('char')) {
        sql += `(${colMeta.maxLength})`;
    }
    
    if (colMeta.columnDefault !== null && colMeta.columnDefault !== undefined) {
        sql += ` DEFAULT ${colMeta.columnDefault}`;
    } else if (colMeta.isNullable === 'NO') {
        const t = colMeta.dataType.toLowerCase();
        if (t.includes('int') || t.includes('double') || t.includes('float') || t.includes('numeric')) {
            sql += ` DEFAULT 0`;
        } else if (t.includes('bool')) {
            sql += ` DEFAULT false`;
        } else if (t.includes('timestamp') || t.includes('date')) {
            sql += ` DEFAULT CURRENT_TIMESTAMP`;
        } else if (t.includes('json')) {
            sql += ` DEFAULT '{}'::jsonb`;
        } else {
            sql += ` DEFAULT ''`;
        }
    }

    if (colMeta.isNullable === 'NO') {
        sql += ' NOT NULL';
    } else {
        sql += ' NULL';
    }
    
    return sql;
}

// Normalización de tipos de datos de Postgres para comparar equivalencias lógicas y evitar falsos positivos
function normalizeDataType(type) {
    if (!type) return '';
    const t = type.toLowerCase();
    if (t === 'character varying' || t === 'varchar') return 'varchar';
    if (t === 'character' || t === 'char') return 'char';
    if (t === 'integer' || t === 'int' || t === 'int4') return 'integer';
    if (t === 'double precision' || t === 'float' || t === 'float8') return 'double precision';
    if (t === 'boolean' || t === 'bool') return 'boolean';
    if (t === 'timestamp without time zone' || t === 'timestamp') return 'timestamp';
    if (t === 'timestamp with time zone' || t === 'timestamptz') return 'timestamptz';
    return t;
}

run();
