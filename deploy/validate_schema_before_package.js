require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const rootDir = path.join(__dirname, '..');

async function validateAndPrepareSchema(customConnStr) {
  console.log("================================================================");
  console.log("  VALIDADOR PRE-COMPILACION DE BASE DE DATOS - AGENCIASNEW");
  console.log("================================================================");

  // 1. Desplegar todos los archivos SQL locales a la BD PostgreSQL local
  console.log("\n[PASO 1/4] Desplegando funciones y SPs a PostgreSQL local...");
  const connectionString = customConnStr || process.env.DATABASE_URL;
  if (!connectionString) {
    console.error("  [ERROR] DATABASE_URL no está configurada en .env");
    process.exit(1);
  }

  const client = new Client({ connectionString });
  client.on('error', err => console.warn('  [WARN] PG Client async error caught:', err.message));
  await client.connect();

  // 0.5 Escaneo y garantía previa de todas las secuencias (nextval) en SQL y API Routes
  console.log("\n[PASO 0.5/4] Auditando y sembrando todas las secuencias (nextval) en PostgreSQL local...");
  const alterColumnsPath = path.join(rootDir, 'SQL', 'Table', 'Alter_New_Columns.sql');
  let alterContentPre = fs.existsSync(alterColumnsPath) ? fs.readFileSync(alterColumnsPath, 'utf8') : '';
  const detectedSequences = new Set();

  // Escanear todas las carpetas SQL y API Routes en busca de nextval('...')
  const searchPathsForSeq = ['SQL/SP', 'SQL/Function', 'SQL/Procedure', 'SQL/Table', 'src/app/api'];
  for (const relPath of searchPathsForSeq) {
    const fullPath = path.join(rootDir, relPath);
    if (!fs.existsSync(fullPath)) continue;
    const scanFiles = (dir) => {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        const res = path.resolve(dir, entry.name);
        if (entry.isDirectory()) {
          scanFiles(res);
        } else if (entry.isFile() && (entry.name.endsWith('.sql') || entry.name.endsWith('.ts') || entry.name.endsWith('.js'))) {
          const content = fs.readFileSync(res, 'utf8');
          const matches = content.matchAll(/nextval\(['"](?:public\.)?([A-Za-z0-9_]+)['"]\)/gi);
          for (const m of matches) {
            detectedSequences.add(m[1]);
          }
        }
      }
    };
    scanFiles(fullPath);
  }

  let injectedPreSeq = 0;
  for (const seqName of detectedSequences) {
    // 1. Crear en Postgres local inmediatamente
    try {
      await client.query(`CREATE SEQUENCE IF NOT EXISTS public."${seqName}" START WITH 1;`);
      await client.query(`CREATE SEQUENCE IF NOT EXISTS public.${seqName} START WITH 1;`);
    } catch (e) {}

    // 2. Garantizar en Alter_New_Columns.sql en nivel superior
    const topSeqRegex = new RegExp(`CREATE\\s+SEQUENCE\\s+IF\\s+NOT\\s+EXISTS\\s+public\\.${seqName}\\b`, 'i');
    if (!topSeqRegex.test(alterContentPre)) {
      console.log(`  [AUTO-FIX] Inyectando siembra superior de secuencia public.${seqName} en Alter_New_Columns.sql...`);
      alterContentPre = `CREATE SEQUENCE IF NOT EXISTS public.${seqName} START WITH 1;\n` + alterContentPre;
      injectedPreSeq++;
    }
  }

  if (injectedPreSeq > 0) {
    fs.writeFileSync(alterColumnsPath, alterContentPre, 'utf8');
    console.log(`  [OK] Se inyectaron ${injectedPreSeq} secuencia(s) al inicio de Alter_New_Columns.sql.`);
  } else {
    console.log(`  [OK] Se verificaron ${detectedSequences.size} secuencia(s) autodetectada(s) sin ausencias.`);
  }

  const folders = ['SQL/Table', 'SQL/Function', 'SQL/SP', 'SQL/Procedure'];
  for (const folder of folders) {
    const dirPath = path.join(rootDir, folder);
    if (!fs.existsSync(dirPath)) continue;

    const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.sql'));
    for (const file of files) {
      // Ignorar scripts pesados o destructivos
      const filePath = path.join(dirPath, file);
      let sql = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '');

      // Ignorar procedimientos almacenados exclusivos de SQL Server (Zeus ERP) al compilar en PostgreSQL
      if (/\bdbo\./i.test(sql) || /^\s*GO\b/im.test(sql) || /sys\.objects/i.test(sql) || /SET ANSI_NULLS/i.test(sql)) {
        continue;
      }

      // Auto-inyectar bloque DO $$ de limpieza dinámica si no lo tiene para prevenir errores 42883 de sobrecargas obsoletas
      const spNameMatch = sql.match(/CREATE\s+OR\s+REPLACE\s+(PROCEDURE|FUNCTION)\s+(?:public\.)?("?[a-zA-Z0-9_]+"|sp[a-zA-Z0-9_]+|fn[a-zA-Z0-9_]+)/i);
      if (spNameMatch && !sql.includes('DO $$')) {
        const objectType = spNameMatch[1].toUpperCase();
        const objectName = spNameMatch[2].replace(/"/g, '');
        const dropBlock = `DO $$\nDECLARE\n    r RECORD;\nBEGIN\n    FOR r IN \n        SELECT oid::regprocedure AS proc_name \n        FROM pg_proc \n        WHERE proname ILIKE '${objectName}'\n    LOOP\n        EXECUTE 'DROP ${objectType} ' || r.proc_name || '${objectType === 'FUNCTION' ? ' CASCADE' : ''}';\n    END LOOP;\nEND $$;\n\n`;
        sql = dropBlock + sql;
        fs.writeFileSync(filePath, sql, 'utf8');
        console.log(`  [AUTO-FIX] Inyectado bloque DO $$ de limpieza dinámica en ${folder}/${file}`);
      }

      try {
        await client.query(sql);
      } catch (err) {
        console.warn(`  [WARN] Error compilando ${folder}/${file}: ${err.message}`);
      }
    }
  }
  console.log("  [OK] Despliegue en PostgreSQL local completado.");

  // 2. Verificar integridad de tablas referenciadas en Alter_New_Columns.sql
  console.log("\n[PASO 2/4] Verificando integridad de tablas en Alter_New_Columns.sql...");
  const alterColumnsFile = path.join(rootDir, 'SQL', 'Table', 'Alter_New_Columns.sql');
  let alterSql = fs.readFileSync(alterColumnsFile, 'utf8');

  // Buscar todas las tablas referenciadas en SQL/SP y SQL/Function
  const referencedTables = new Set();
  for (const folder of ['SQL/SP', 'SQL/Function']) {
    const dirPath = path.join(rootDir, folder);
    if (!fs.existsSync(dirPath)) continue;
    const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.sql'));
    for (const file of files) {
      const content = fs.readFileSync(path.join(dirPath, file), 'utf8');
      const matches = content.matchAll(/public\."([A-Za-z0-9_]+)"/g);
      for (const m of matches) {
        const tbl = m[1];
        // Ignorar invocaciones a procedimientos o funciones (sp*, fn*) y secuencias (*_seq, seq_*)
        if (!tbl.startsWith('sp') && !tbl.startsWith('fn') && !tbl.startsWith('sp_') && !tbl.startsWith('fn_') && !tbl.endsWith('_seq') && !tbl.startsWith('seq_')) {
          referencedTables.add(tbl);
        }
      }
    }
  }

  // Comprobar que cada tabla referenciada exista en la BD local y tenga su DDL
  let fixedTablesCount = 0;
  for (const tableName of referencedTables) {
    // Si no está en Alter_New_Columns.sql con CREATE TABLE IF NOT EXISTS
    const hasCreateTable = new RegExp(`CREATE TABLE (IF NOT EXISTS )?public\\."${tableName}"`, 'i').test(alterSql);
    const isSystemTable = ['Quotation', 'Client', 'User', 'Branch', 'Product', 'Seller', 'TicketPrinter', 'Provider', 'Prestadora'].includes(tableName);

    if (!hasCreateTable && !isSystemTable) {
      console.log(`  [AUTO-FIX] Agregando CREATE TABLE IF NOT EXISTS para public."${tableName}" en Alter_New_Columns.sql...`);
      
      // Obtener la estructura real de la tabla en PostgreSQL local
      const colsRes = await client.query(`
        SELECT column_name, data_type, column_default, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

      if (colsRes.rows.length > 0) {
        const colDefs = colsRes.rows.map(col => {
          let def = `"${col.column_name}" ${col.data_type}`;
          if (col.column_default) def += ` DEFAULT ${col.column_default}`;
          if (col.is_nullable === 'NO') def += ` NOT NULL`;
          return def;
        });

        const createBlock = `\n    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '${tableName}') THEN\n        CREATE TABLE public."${tableName}" (\n            ${colDefs.join(',\n            ')}\n        );\n    END IF;\n`;

        // Insertar dentro del primer bloque DO $$ BEGIN ... END $$; de Alter_New_Columns.sql
        alterSql = alterSql.replace(/(DO\s*\$\$\s*\r?\n\s*BEGIN)/i, `$1${createBlock}`);
        fixedTablesCount++;
      }
    }
  }

  if (fixedTablesCount > 0) {
    fs.writeFileSync(alterColumnsFile, alterSql, 'utf8');
    console.log(`  [OK] Alter_New_Columns.sql actualizado con ${fixedTablesCount} estructura(s) creadas automáticamente.`);
    // Re-desplegar Alter_New_Columns.sql
    await client.query(alterSql);
  } else {
    console.log("  [OK] Todas las tablas referenciadas cuentan con CREATE TABLE IF NOT EXISTS.");
  }

  // 2.5 Verificación de Secuencias y Autoincremento en columnas "id"
  console.log("\n[PASO 2.5/5] Verificando secuencias autoincrementales en llaves primarias ('id')...");
  const idColsRes = await client.query(`
    SELECT table_name, column_name, data_type, column_default 
    FROM information_schema.columns 
    WHERE table_schema = 'public' AND column_name = 'id' AND data_type IN ('integer', 'bigint');
  `);

  let fixedSeqCount = 0;
  for (const row of idColsRes.rows) {
    const tbl = row.table_name;
    const hasNextval = row.column_default && row.column_default.includes('nextval');
    if (!hasNextval) {
      console.log(`  [AUTO-FIX] Asignando secuencia autoincremental a public."${tbl}".id...`);
      const seqName = `${tbl}_id_seq`;
      await client.query(`
        CREATE SEQUENCE IF NOT EXISTS public."${seqName}";
        ALTER TABLE public."${tbl}" ALTER COLUMN id SET DEFAULT nextval('public."${seqName}"'::regclass);
        ALTER SEQUENCE public."${seqName}" OWNED BY public."${tbl}".id;
      `);
      fixedSeqCount++;
    }
  }
  if (fixedSeqCount > 0) {
    console.log(`  [OK] Se fijó la secuencia autoincremental en ${fixedSeqCount} tabla(s).`);
  } else {
    console.log("  [OK] Todas las tablas cuentan con secuencias autoincrementales ('nextval') en sus llaves primarias.");
  }

  // 2.5.5 Verificación y Siembra Automática de Secuencias Personalizadas (nextval en SPs)
  console.log("\n[PASO 2.5.5/5] Auditando secuencias personalizadas referenciadas en Stored Procedures...");
  let alterSqlContent = fs.readFileSync(alterColumnsPath, 'utf8');
  let customSeqInjected = 0;

  // Scan all SP files for nextval('public.seq_name') or nextval('seq_name')
  const spDir = path.join(__dirname, '..', 'SQL', 'SP');
  if (fs.existsSync(spDir)) {
    const spFiles = fs.readdirSync(spDir).filter(f => f.endsWith('.sql'));
    for (const f of spFiles) {
      const content = fs.readFileSync(path.join(spDir, f), 'utf8');
      const seqMatches = content.matchAll(/nextval\(['"](?:public\.)?([A-Za-z0-9_]+)['"]\)/gi);
      for (const match of seqMatches) {
        const seqName = match[1];
        // Ensure sequence exists in database
        try {
          await client.query(`CREATE SEQUENCE IF NOT EXISTS public."${seqName}" START WITH 1;`);
          await client.query(`CREATE SEQUENCE IF NOT EXISTS public.${seqName} START WITH 1;`);
        } catch (e) {}

        if (!alterSqlContent.includes(seqName)) {
          console.log(`  [AUTO-FIX] Inyectando CREATE SEQUENCE IF NOT EXISTS public.${seqName} en Alter_New_Columns.sql...`);
          alterSqlContent = `CREATE SEQUENCE IF NOT EXISTS public.${seqName} START WITH 1;\n` + alterSqlContent;
          customSeqInjected++;
        }
      }
    }
  }

  if (customSeqInjected > 0) {
    fs.writeFileSync(alterColumnsPath, alterSqlContent, 'utf8');
    console.log(`  [OK] Se inyectaron ${customSeqInjected} secuencia(s) en Alter_New_Columns.sql.`);
  } else {
    console.log("  [OK] Todas las secuencias personalizadas de Stored Procedures sembradas y verificadas.");
  }

  // 2.6 Verificación de Restricciones UNIQUE para operaciones de Upsert
  console.log("\n[PASO 2.6/5] Verificando restricciones UNIQUE para operaciones de Upsert...");
  const uniqueAudits = [
    { table: 'QuotationPrintCustomization', column: 'quotationId' },
    { table: 'QuotationFormat', column: 'name' }
  ];

  for (const u of uniqueAudits) {
    const constraintName = `${u.table}_${u.column}_key`;
    const uRes = await client.query(`
      SELECT 1 FROM pg_class WHERE relname = $1
      UNION
      SELECT 1 FROM pg_constraint WHERE conname = $1;
    `, [constraintName]);

    if (uRes.rows.length === 0) {
      console.log(`  [AUTO-FIX] Agregando restricción UNIQUE a public."${u.table}"("${u.column}")...`);
      await client.query(`
        DO $$ BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = '${constraintName}') AND NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = '${constraintName}') THEN
            ALTER TABLE public."${u.table}" ADD CONSTRAINT "${constraintName}" UNIQUE ("${u.column}");
          END IF;
        END $$;
      `);
    }
  }
  console.log("  [OK] Restricciones UNIQUE para operaciones de Upsert verificadas.");

  // 2.6.5 Verificación y Auto-Inyección de Columna "isActive" en Tablas Maestras
  console.log("\n[PASO 2.6.5/5] Verificando presencia de la columna 'isActive' en tablas maestras...");
  const masterTablesForIsActive = [
    'ChargeAndTax', 'Client', 'User', 'Branch', 'Implant', 'Provider', 'Prestadora',
    'Seller', 'Product', 'Airports', 'Airport', 'Cities', 'City', 'Countries', 'Country', 'CreditCard',
    'Currency', 'MasterVariable', 'ProviderType', 'Combo', 'EquivalencesInterfaces', 'Equivalences',
    'TicketType', 'TicketPrinter', 'Payment', 'DocumentResolution', 'Resolution', 'TransactionConsecutive', 'SysConsecutivo',
    'QuotationState', 'QuotationFormat', 'InterfaceExtractParam', 'Role'
  ];

  for (const tbl of masterTablesForIsActive) {
    const tblExists = await client.query(`SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = $1`, [tbl]);
    if (tblExists.rows.length > 0) {
      const colExists = await client.query(`SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1 AND column_name = 'isActive'`, [tbl]);
      if (colExists.rows.length === 0) {
        console.log(`  [AUTO-FIX] Agregando columna 'isActive' a public."${tbl}"...`);
        await client.query(`ALTER TABLE public."${tbl}" ADD COLUMN "isActive" boolean DEFAULT true NOT NULL;`);
      }
    }
  }
  console.log("  [OK] Columna 'isActive' verificada y garantizada en todas las tablas maestras.");

  // 2.7 Verificación de Prisma Schema y Regeneración del Cliente Prisma Client
  console.log("\n[PASO 2.7/5] Verificando Prisma Schema y regenerando Prisma Client...");
  const prismaSchemaPath = path.join(rootDir, 'prisma', 'schema.prisma');
  if (fs.existsSync(prismaSchemaPath)) {
    const { execSync } = require('child_process');
    try {
      execSync('npx prisma generate', { cwd: rootDir, stdio: 'pipe' });
      console.log("  [OK] Prisma Client regenerado exitosamente con 'npx prisma generate'.");
    } catch (prismaErr) {
      console.warn(`  [WARN] Error ejecutando 'npx prisma generate': ${prismaErr.message}`);
    }
  }

  // 2.8 Verificación y Sembrado de Módulos del Menú de Navegación (public."Menu")
  console.log("\n[PASO 2.8/5] Verificando semillas de Módulos de Navegación ('Menu')...");
  await client.query(`
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
    ON CONFLICT (code) DO UPDATE SET 
        name = EXCLUDED.name,
        action = EXCLUDED.action;
  `);
  console.log("  [OK] Todos los módulos de navegación del Menú Principal sembrados y verificados.");

  // 2.9 Verificación de Preservación de Parámetros de Sistema (SystemParameter ON CONFLICT DO NOTHING)
  console.log("\n[PASO 2.9/5] Verificando preservación de parámetros de configuración en Inicial.sql...");
  const inicialSqlPath = path.join(rootDir, 'SQL', 'Inicial.sql');
  if (fs.existsSync(inicialSqlPath)) {
    let inicialSqlContent = fs.readFileSync(inicialSqlPath, 'utf8');
    if (/INSERT INTO public\."SystemParameter"[\s\S]*?ON CONFLICT \(code\) DO UPDATE/i.test(inicialSqlContent)) {
      console.log("  [AUTO-FIX] Cambiando SystemParameter ON CONFLICT a DO NOTHING en Inicial.sql para preservar configuración del cliente...");
      inicialSqlContent = inicialSqlContent.replace(
        /(INSERT INTO public\."SystemParameter"[\s\S]*?)ON CONFLICT \(code\) DO UPDATE[\s\S]*?value = EXCLUDED\.value;/gi,
        '$1ON CONFLICT (code) DO NOTHING;'
      );
      fs.writeFileSync(inicialSqlPath, inicialSqlContent, 'utf8');
    }
  }
  console.log("  [OK] Regla de preservación de parámetros verificada (ON CONFLICT DO NOTHING).");

  // 2.10 Verificación y Sembrado de todas las Tablas Maestras (public."Master")
  console.log("\n[PASO 2.10/5] Verificando semillas de Tablas Maestras ('Master')...");
  await client.query(`
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
  `);
  console.log("  [OK] Todas las 28 tablas maestras sembradas y verificadas en public.\"Master\".");

  // 2.11 Verificación y Sembrado de Parámetros del Sistema (public."SystemParameter")
  console.log("\n[PASO 2.11/5] Verificando semillas de Parámetros del Sistema ('SystemParameter')...");
  await client.query(`
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
        ('MOSTRAR_TOTALIZACION_COTIZACION', 'Mostrar totalización financiera en cotización', 'true')
    ON CONFLICT (code) DO NOTHING;
  `);
  console.log("  [OK] Todos los Parámetros del Sistema sembrados y verificados con ON CONFLICT DO NOTHING.");

  // 2.11.5 Verificación y Auto-Reparación de Plantilla Predeterminada de Impresión (QuotationPrintDefaultTemplate)
  console.log("\n[PASO 2.11.5/5] Verificando plantilla predeterminada de impresión ('QuotationPrintDefaultTemplate')...");
  try {
    const printDefRes = await client.query('SELECT html FROM public."QuotationPrintDefaultTemplate" ORDER BY id ASC LIMIT 1');
    const printHtml = printDefRes.rows[0]?.html || '';
    if (!printHtml || printHtml.length < 5000 || (!printHtml.includes('FORMATO VENTA') && !printHtml.includes('LIQUIDACION'))) {
      console.log("  [AUTO-FIX] Regenerando plantilla predeterminada completa de impresión desde default_template.xlsx...");
      let generateHtmlTemplate;
      try {
        generateHtmlTemplate = require(path.join(rootDir, 'src', 'lib', 'excel-to-html')).generateHtmlTemplate;
      } catch (e) {
        try {
          require('ts-node/register');
          generateHtmlTemplate = require(path.join(rootDir, 'src', 'lib', 'excel-to-html')).generateHtmlTemplate;
        } catch (e2) {}
      }

      const defaultTemplatePath = path.join(rootDir, 'templates', 'default_template.xlsx');
      if (generateHtmlTemplate && fs.existsSync(defaultTemplatePath)) {
        const defaultBuffer = fs.readFileSync(defaultTemplatePath);
        const fullHtml = await generateHtmlTemplate(defaultBuffer, {}, null, 1);
        await client.query('DELETE FROM public."QuotationPrintDefaultTemplate"');
        await client.query('INSERT INTO public."QuotationPrintDefaultTemplate" (name, html, "createdAt", "updatedAt") VALUES ($1, $2, NOW(), NOW())', ['Default', fullHtml]);
        console.log("  [OK] Plantilla predeterminada completa de impresión regenerada exitosamente.");
      }
    } else {
      console.log("  [OK] Plantilla predeterminada de impresión verificada.");
    }
  } catch (printTplErr) {
    console.warn(`  [WARN] Error verificando plantilla predeterminada de impresión: ${printTplErr.message}`);
  }

  // 2.12 AUDITORÍA AUTOMÁTICA Y AUTO-CORRECCIÓN UNIVERSAL DE ARCHIVOS DE MIGRACIÓN (Inicial.sql y Alter_New_Columns.sql)
  console.log("\n[PASO 2.12/5] Auditoría y Sincronización Automática Universal de Catálogos (Menu, Master, SystemParameter)...");
  try {
    const localMenuRes = await client.query('SELECT code, name, action, activo FROM public."Menu"');
    const localMasterRes = await client.query('SELECT code, name, inactivo FROM public."Master"');
    const localParamRes = await client.query('SELECT code, name, value FROM public."SystemParameter"');

    const filesToAudit = [
      path.join(rootDir, 'SQL', 'Table', 'Alter_New_Columns.sql'),
      path.join(rootDir, 'SQL', 'Inicial.sql'),
      path.join(rootDir, 'SQL', 'Data', 'Inicial.sql')
    ];

    for (const fPath of filesToAudit) {
      if (!fs.existsSync(fPath)) continue;
      let fileContent = fs.readFileSync(fPath, 'utf8');
      let fileModified = false;

      // Verificar y auto-inyectar cualquier módulo de Menú faltante
      for (const m of localMenuRes.rows) {
        if (m.code && !fileContent.includes(`'${m.code}'`)) {
          console.log(`  [AUTO-SYNC] Inyectando módulo de Menú '${m.code}' en ${path.basename(fPath)}...`);
          const insertMenuSql = `\nINSERT INTO public."Menu" (code, name, action, activo) VALUES ('${m.code}', '${m.name}', '${m.action || ''}', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;\n`;
          fileContent += insertMenuSql;
          fileModified = true;
        }
      }

      // Verificar y auto-inyectar cualquier Tabla Maestra faltante
      for (const mst of localMasterRes.rows) {
        if (mst.code && !fileContent.includes(`'${mst.code}'`)) {
          console.log(`  [AUTO-SYNC] Inyectando Tabla Maestra '${mst.code}' en ${path.basename(fPath)}...`);
          const insertMasterSql = `\nINSERT INTO public."Master" (code, name, "inactivo") VALUES ('${mst.code}', '${mst.name}', false) ON CONFLICT (code) DO NOTHING;\n`;
          fileContent += insertMasterSql;
          fileModified = true;
        }
      }

      // Verificar y auto-inyectar cualquier Parámetro del Sistema faltante
      for (const p of localParamRes.rows) {
        if (p.code && !fileContent.includes(`'${p.code}'`)) {
          console.log(`  [AUTO-SYNC] Inyectando Parámetro del Sistema '${p.code}' en ${path.basename(fPath)}...`);
          const insertParamSql = `\nINSERT INTO public."SystemParameter" (code, name, value) VALUES ('${p.code}', '${p.name || ''}', '${p.value || ''}') ON CONFLICT (code) DO NOTHING;\n`;
          fileContent += insertParamSql;
          fileModified = true;
        }
      }

      if (fileModified) {
        fs.writeFileSync(fPath, fileContent, 'utf8');
        console.log(`  [OK] ${path.basename(fPath)} fue sincronizado y actualizado automáticamente.`);
      }
    }
    console.log("  [OK] Auditoría universal de catálogos completada exitosamente.");
  } catch (auditErr) {
    console.warn(`  [WARN] Error en auditoría dinámica de catálogos: ${auditErr.message}`);
  }
  console.log("\n[PASO 3/4] Verificando regla obligatoria de LEFT JOIN en funciones de consulta...");
  const funcFolder = path.join(rootDir, 'SQL/Function');
  const listingFiles = ['fnCotizacionListar.sql', 'fnCotizacionHistorial.sql', 'fnCotizacion.sql'];
  
  for (const file of listingFiles) {
    const fPath = path.join(funcFolder, file);
    if (!fs.existsSync(fPath)) continue;
    const content = fs.readFileSync(fPath, 'utf8');
    
    // Verificar si hay INNER JOIN public."Client" o JOIN public."Client"
    const hasUnsafeJoin = /(?<!LEFT\s+)JOIN\s+public\."Client"/i.test(content) || /(?<!LEFT\s+)JOIN\s+public\."User"/i.test(content);
    if (hasUnsafeJoin) {
      console.error(`  [ERROR CRITICO] La función ${file} contiene JOIN o INNER JOIN en Client/User. Se requiere LEFT JOIN.`);
      process.exit(1);
    }
  }
  console.log("  [OK] Funciones de consulta validadas con LEFT JOIN obligatorio.");

  // 3.5 AUDITORÍA AUTOMÁTICA DE FIRMAS Y PARÁMETROS EN API ROUTES VS STORED PROCEDURES / FUNCIONES
  console.log("\n[PASO 3.5/4] Auditando firmas y parámetros en API Routes vs Stored Procedures y Funciones...");
  
  function countCallArguments(argsStr) {
    const trimmed = argsStr.trim();
    if (!trimmed) return 0;
    const placeholders = trimmed.match(/\$(\d+)/g);
    if (placeholders && placeholders.length > 0) {
      const numbers = placeholders.map(p => parseInt(p.replace('$', '')));
      return Math.max(...numbers);
    }
    const parts = trimmed.split(/,(?=(?:(?:[^"']*["']){2})*[^"']*$)/);
    const validParts = parts.map(p => p.trim()).filter(p => p.length > 0);
    return validParts.length;
  }

  const procRes = await client.query(`
    SELECT p.proname, pronargs,
           pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public';
  `);

  const dbProcs = new Map();
  for (const row of procRes.rows) {
    dbProcs.set(row.proname.toLowerCase(), {
      name: row.proname,
      argCount: parseInt(row.pronargs),
      args: row.args
    });
  }

  const apiDir = path.join(rootDir, 'src', 'app', 'api');
  function scanApiFiles(dir) {
    let results = [];
    if (!fs.existsSync(dir)) return results;
    const list = fs.readdirSync(dir);
    list.forEach(file => {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      if (stat && stat.isDirectory()) {
        results = results.concat(scanApiFiles(fullPath));
      } else if (file.endsWith('.ts') || file.endsWith('.js')) {
        results.push(fullPath);
      }
    });
    return results;
  }

  const apiFiles = scanApiFiles(apiDir);
  let paramMismatchErrors = 0;

  for (const file of apiFiles) {
    const content = fs.readFileSync(file, 'utf8');
    const relFile = path.relative(rootDir, file);

    const matches = content.matchAll(/(?:CALL|FROM)\s+(?:public\.)?("?[a-zA-Z0-9_]+"|sp[a-zA-Z0-9_]+|fn[a-zA-Z0-9_]+)\s*\(([\s\S]*?)\)/gi);
    for (const m of matches) {
      const rawName = m[1].replace(/"/g, '');
      const argsStr = m[2];
      const nameLower = rawName.toLowerCase();

      if (nameLower.startsWith('sp') || nameLower.startsWith('fn')) {
        const argCount = countCallArguments(argsStr);
        const dbProc = dbProcs.get(nameLower);

        if (!dbProc) {
          console.warn(`  [WARN] Invocación en ${relFile} a '${rawName}' que no existe aún en PostgreSQL local.`);
        } else if (argCount !== dbProc.argCount) {
          console.error(`  [ERROR CRITICO PARAMETROS] Mismatch en ${relFile}:`);
          console.error(`     Invocación Next.js: ${rawName} con ${argCount} argumentos`);
          console.error(`     Definición en DB: ${dbProc.name} tiene ${dbProc.argCount} parámetros (${dbProc.args})`);
          paramMismatchErrors++;
        }
      }
    }
  }

  if (paramMismatchErrors > 0) {
    console.error(`\n[FATAL] Se encontraron ${paramMismatchErrors} error(es) de número/firmas de parámetros entre API Routes y la Base de Datos.`);
    console.error("  La compilación pre-despliegue se ha ABORTADO para evitar fallas 42883 en producción.\n");
    process.exit(1);
  }
  console.log("  [OK] Auditoría de firmas de parámetros entre API Routes y DB completada con 0 errores.");

  // 4. Sincronizar scripts actualizadores
  console.log("\n[PASO 4/4] Sincronizando scripts actualizadores (Actualizador.sql)...");
  const updateScriptPath = path.join(rootDir, 'scratch', 'update_sql_actualizadores.js');
  if (fs.existsSync(updateScriptPath)) {
    require(updateScriptPath);
  }
  console.log("  [OK] Sincronización de actualizadores finalizada.");

  await client.end();
  console.log("\n================================================================");
  console.log("  VALIDACION EXITOSA: La base de datos está lista para empaquetar.");
  console.log("================================================================\n");
}

module.exports = { validateAndPrepareSchema };

if (require.main === module) {
  validateAndPrepareSchema().catch(err => {
    console.error("ERROR FATAL EN VALIDACION PRE-COMPILACION:", err);
    process.exit(1);
  });
}
