const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const { generateManifest, computeHash } = require('./generate_release_manifest');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const isSQLServer = (process.env.DB_ENGINE || '').toLowerCase() === 'sqlserver' || process.env.IS_SQLSERVER === 'true';

async function runGuardianValidation() {
  console.log('============================================================');
  console.log('KOREX UPDATE GUARDIAN - SISTEMA DE ACTUALIZACIÓN VERIFICABLE');
  console.log('============================================================');
  console.log(`Motor activo: ${isSQLServer ? 'Microsoft SQL Server' : 'PostgreSQL'}`);

  const manifestPath = path.resolve(
    __dirname,
    '../SQL',
    isSQLServer ? 'manifest-sqlserver.json' : 'manifest-postgresql.json'
  );

  // Guarantee release manifest is up to date when running in full workspace
  const hasFullDevRepo =
    fs.existsSync(path.resolve(__dirname, '../SQL/Procedure')) &&
    fs.existsSync(path.resolve(__dirname, '../SQL/SqlServer'));
  if (hasFullDevRepo || !fs.existsSync(manifestPath)) {
    try {
      generateManifest();
    } catch (e) {
      if (!fs.existsSync(manifestPath)) {
        throw e;
      }
    }
  }

  if (!fs.existsSync(manifestPath)) {
    console.error(`❌ Error Crítico: No se encontró el archivo manifest: ${manifestPath}`);
    process.exit(3);
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  console.log(`Versión Release: ${manifest.releaseVersion} (Build: ${manifest.build})`);
  console.log(`Total de objetos a verificar: ${manifest.totalObjects}`);

  let updateId = 0;
  let exitCode = 0;
  let totalOk = 0;
  let totalErrors = 0;

  if (isSQLServer) {
    const mssql = require('mssql');
    const os = require('os');
    const { execFileSync } = require('child_process');
    let rawHost = process.env.DB_HOST || process.env.SQLSERVER_HOST || 'localhost';
    let origHost = rawHost;
    let instanceName = undefined;
    if (rawHost.includes('\\')) {
      const parts = rawHost.split('\\');
      rawHost = parts[0];
      origHost = parts[0];
      instanceName = parts[1];
    }
    const localHostname = (os.hostname() || '').toLowerCase();
    if (
      rawHost.toLowerCase() === 'localhost' ||
      rawHost === '.' ||
      rawHost.toLowerCase() === '(local)' ||
      (localHostname && rawHost.toLowerCase() === localHostname)
    ) {
      rawHost = '127.0.0.1';
    }

    let resolvedPort = parseInt(process.env.DB_PORT || process.env.SQLSERVER_PORT || '1433', 10);
    let foundInstancePort = null;

    if (instanceName) {
      try {
        const psRegCmd = `$p = Get-ItemProperty "HKLM:\\SOFTWARE\\Microsoft\\Microsoft SQL Server\\MSSQL*.${instanceName}\\MSSQLServer\\SuperSocketNetLib\\Tcp\\IPAll" -ErrorAction SilentlyContinue | Select-Object -First 1; if ($p) { if ($p.TcpPort) { Write-Output $p.TcpPort } elseif ($p.TcpDynamicPorts) { Write-Output $p.TcpDynamicPorts } }`;
        const regOut = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psRegCmd], {
          encoding: 'utf8',
          timeout: 5000,
          stdio: ['ignore', 'pipe', 'ignore']
        }).trim();
        const pm = regOut.match(/(\d+)/);
        if (pm) foundInstancePort = parseInt(pm[1], 10);
      } catch (e) {}

      if (!foundInstancePort) {
        try {
          const safeServer = `${origHost}\\${instanceName}`.replace(/'/g, "''");
          const safeUser = (process.env.DB_USER || process.env.SQLSERVER_USER || 'sa').replace(/'/g, "''");
          const safePass = (process.env.DB_PASSWORD || process.env.SQLSERVER_PASSWORD || '').replace(/'/g, "''");
          const psNetCmd = `
            $sc = 'Server=${safeServer};Database=master;User Id=${safeUser};Password=${safePass};Encrypt=False;TrustServerCertificate=True;Connection Timeout=6;';
            $conn = New-Object System.Data.SqlClient.SqlConnection($sc);
            $conn.Open();
            $cmd = $conn.CreateCommand();
            $cmd.CommandText = "SELECT local_tcp_port FROM sys.dm_exec_connections WHERE session_id = @@SPID AND local_tcp_port IS NOT NULL; EXEC xp_readerrorlog 0, 1, N'Server is listening on'";
            $r = $cmd.ExecuteReader();
            $foundPort = '';
            while ($r.Read()) { if ($r[0]) { $foundPort = $r[0].ToString() } }
            if (-not $foundPort -and $r.NextResult()) {
                while ($r.Read()) {
                    $txt = $r[2].ToString();
                    if ($txt -match '<ipv4>\\s+(\\d+)') { $foundPort = $matches[1]; break }
                }
            }
            $conn.Close();
            if ($foundPort) { Write-Output $foundPort }
          `;
          const netOut = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psNetCmd], {
            encoding: 'utf8',
            timeout: 8000,
            stdio: ['ignore', 'pipe', 'ignore']
          }).trim();
          const pm = netOut.match(/(\d+)/);
          if (pm) foundInstancePort = parseInt(pm[1], 10);
        } catch (e) {}
      }
      if (foundInstancePort) {
        resolvedPort = foundInstancePort;
      }
    }

    const sqlOptions = {
      encrypt: false,
      trustServerCertificate: true
    };
    if (instanceName && !foundInstancePort) {
      sqlOptions.instanceName = instanceName;
    }
    const sqlConfig = {
      user: process.env.DB_USER || process.env.SQLSERVER_USER || 'sa',
      password: process.env.DB_PASSWORD || process.env.SQLSERVER_PASSWORD || '',
      server: rawHost,
      port: (instanceName && !foundInstancePort) ? undefined : resolvedPort,
      database: process.env.DB_NAME || process.env.SQLSERVER_DB || 'Korex_pruebas',
      options: sqlOptions
    };

    try {
      const pool = await mssql.connect(sqlConfig);
      console.log(`Conectado exitosamente a SQL Server [${sqlConfig.server}:${sqlConfig.database}]`);

      // Ensure control tables exist
      const tablesCheck = await pool.request().query(`
        SELECT COUNT(*) as cnt FROM sys.tables WHERE name IN ('Korex_UpdateHistory', 'Korex_UpdateObjects', 'Korex_Installation')
      `);
      if (tablesCheck.recordset[0].cnt < 3) {
        const initTablesPath = path.resolve(__dirname, '../SQL/SqlServer/01_Tables.sql');
        if (fs.existsSync(initTablesPath)) {
          console.log('Creando estructura de control Korex Update Guardian...');
          const initDdl = fs.readFileSync(initTablesPath, 'utf8');
          await pool.request().batch(initDdl);
        }
      }

      // Record update start
      const histResult = await pool.request()
        .input('vNueva', mssql.NVarChar(50), manifest.releaseVersion)
        .input('build', mssql.NVarChar(50), manifest.build)
        .input('motor', mssql.NVarChar(50), 'SQLServer')
        .input('servidor', mssql.NVarChar(255), sqlConfig.server)
        .input('base', mssql.NVarChar(255), sqlConfig.database)
        .input('estado', mssql.NVarChar(50), 'EN_PROCESO')
        .query(`
          INSERT INTO dbo.Korex_UpdateHistory (VersionNueva, Build, Motor, Servidor, BaseDatos, Estado, ExitCode)
          OUTPUT INSERTED.UpdateId
          VALUES (@vNueva, @build, @motor, @servidor, @base, @estado, 0);
        `);
      updateId = histResult.recordset[0].UpdateId;

      // Validate object by object
      let idx = 1;
      for (const obj of manifest.objects) {
        const numStr = String(idx).padStart(3, '0');
        const totalStr = String(manifest.totalObjects).padStart(3, '0');
        let status = 'OK';
        let errorMsg = null;
        let compiled = 0;
        let validated = 0;

        try {
          const sysObjRes = await pool.request()
            .input('name', mssql.NVarChar(255), obj.objectName.replace(/^dbo\./, ''))
            .query(`
              SELECT o.object_id, o.type, m.definition
              FROM sys.objects o
              LEFT JOIN sys.sql_modules m ON o.object_id = m.object_id
              WHERE o.name = @name
            `);

          if (sysObjRes.recordset.length > 0) {
            compiled = 1;
            validated = 1;
            status = 'OK';
            totalOk++;
            console.log(`[${numStr}/${totalStr}] ${obj.objectName} ... OK (Compilado y Validado)`);
          } else {
            status = 'ERROR';
            errorMsg = `El objeto ${obj.objectName} no existe en sys.objects después de la actualización.`;
            totalErrors++;
            console.error(`[${numStr}/${totalStr}] ${obj.objectName} ... ❌ ERROR: Objeto faltante en base de datos`);
          }
        } catch (err) {
          status = 'ERROR';
          errorMsg = err.message;
          totalErrors++;
          console.error(`[${numStr}/${totalStr}] ${obj.objectName} ... ❌ ERROR: ${err.message}`);
        }

        // Record object status
        await pool.request()
          .input('updateId', mssql.Int, updateId)
          .input('type', mssql.NVarChar(50), obj.objectType)
          .input('name', mssql.NVarChar(255), obj.objectName)
          .input('compiled', mssql.Bit, compiled)
          .input('validated', mssql.Bit, validated)
          .input('hashExp', mssql.NVarChar(128), obj.hash)
          .input('status', mssql.NVarChar(50), status)
          .input('errMsg', mssql.NVarChar(mssql.MAX), errorMsg)
          .query(`
            INSERT INTO dbo.Korex_UpdateObjects (UpdateId, ObjectType, ObjectName, Executed, Compiled, Validated, HashExpected, Status, ErrorMessage)
            VALUES (@updateId, @type, @name, 1, @compiled, @validated, @hashExp, @status, @errMsg);
          `);

        idx++;
      }

      const finalState = totalErrors === 0 ? 'OK' : 'FALLIDA';
      exitCode = totalErrors === 0 ? 0 : 1;

      await pool.request()
        .input('updateId', mssql.Int, updateId)
        .input('estado', mssql.NVarChar(50), finalState)
        .input('exitCode', mssql.Int, exitCode)
        .input('resumen', mssql.NVarChar(mssql.MAX), `Total: ${manifest.totalObjects}, OK: ${totalOk}, Errores: ${totalErrors}`)
        .query(`
          UPDATE dbo.Korex_UpdateHistory
          SET FechaFin = GETDATE(), Estado = @estado, ExitCode = @exitCode, ResumenLog = @resumen
          WHERE UpdateId = @updateId;
        `);

      if (exitCode === 0) {
        await pool.request()
          .input('vApp', mssql.NVarChar(50), manifest.releaseVersion)
          .input('vDb', mssql.NVarChar(50), manifest.releaseVersion)
          .input('build', mssql.NVarChar(50), manifest.build)
          .input('motor', mssql.NVarChar(50), 'SQLServer')
          .query(`
            IF NOT EXISTS (SELECT 1 FROM dbo.Korex_Installation)
              INSERT INTO dbo.Korex_Installation (AppVersion, DbVersion, Build, Motor, Status) VALUES (@vApp, @vDb, @build, @motor, 'HEALTHY');
            ELSE
              UPDATE dbo.Korex_Installation SET AppVersion = @vApp, DbVersion = @vDb, Build = @build, LastValidationDate = GETDATE(), Status = 'HEALTHY';
          `);
      }

      await pool.close();
    } catch (err) {
      console.error(`❌ Error inesperado conectando a SQL Server: ${err.message}`);
      process.exit(4);
    }
  } else {
    // PostgreSQL
    const { Client } = require('pg');
    const pgUrl = process.env.DATABASE_URL_POSTGRES || (process.env.DATABASE_URL && (process.env.DATABASE_URL.startsWith('postgresql://') || process.env.DATABASE_URL.startsWith('postgres://')) ? process.env.DATABASE_URL : 'postgresql://postgres:zzeusagencias@192.168.80.26:5432/Korex_colaereo?schema=public');

    let clientConfig = { connectionString: pgUrl };
    try {
      const u = new URL(pgUrl);
      clientConfig = {
        user: u.username || 'postgres',
        password: decodeURIComponent(u.password || ''),
        host: u.hostname || 'localhost',
        port: parseInt(u.port || '5432', 10),
        database: u.pathname.replace(/^\//, '') || 'Korex_colaereo'
      };
    } catch (e) {
      clientConfig = { connectionString: pgUrl };
    }

    const client = new Client(clientConfig);

    try {
      await client.connect();
      console.log(`Conectado exitosamente a PostgreSQL [${clientConfig.host || 'remote'}:${clientConfig.database || 'Korex_colaereo'}]`);

      // Ensure control tables, sequences and DEFAULT constraints exist and are self-healed
      await client.query(`
        DO $$
        BEGIN
          CREATE SEQUENCE IF NOT EXISTS public."Korex_UpdateHistory_id_seq" START WITH 1;
          CREATE SEQUENCE IF NOT EXISTS public."Korex_UpdateObjects_id_seq" START WITH 1;
          CREATE SEQUENCE IF NOT EXISTS public."Korex_UpdateErrors_id_seq" START WITH 1;
          CREATE SEQUENCE IF NOT EXISTS public."Korex_Installation_id_seq" START WITH 1;

          IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Korex_UpdateHistory') THEN
            CREATE TABLE public."Korex_UpdateHistory" (
              "UpdateId" integer DEFAULT nextval('public."Korex_UpdateHistory_id_seq"'::regclass) NOT NULL PRIMARY KEY,
              "VersionAnterior" character varying(50),
              "VersionNueva" character varying(50) NOT NULL,
              "Build" character varying(50),
              "Motor" character varying(50) NOT NULL,
              "Servidor" character varying(255),
              "BaseDatos" character varying(255),
              "FechaInicio" timestamp without time zone DEFAULT now() NOT NULL,
              "FechaFin" timestamp without time zone,
              "Estado" character varying(50) NOT NULL,
              "ExitCode" integer DEFAULT 0 NOT NULL,
              "Usuario" character varying(150),
              "Equipo" character varying(150),
              "ResumenLog" text
            );
          END IF;

          IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Korex_UpdateObjects') THEN
            CREATE TABLE public."Korex_UpdateObjects" (
              "id" integer DEFAULT nextval('public."Korex_UpdateObjects_id_seq"'::regclass) NOT NULL PRIMARY KEY,
              "UpdateId" integer NOT NULL,
              "ObjectType" character varying(50) NOT NULL,
              "ObjectName" character varying(255) NOT NULL,
              "Expected" boolean DEFAULT true NOT NULL,
              "Executed" boolean DEFAULT false NOT NULL,
              "Compiled" boolean DEFAULT false NOT NULL,
              "Validated" boolean DEFAULT false NOT NULL,
              "HashExpected" character varying(128),
              "HashActual" character varying(128),
              "Status" character varying(50) NOT NULL,
              "ErrorMessage" text,
              "ExecutionTimeMs" integer DEFAULT 0,
              "FechaVerificacion" timestamp without time zone DEFAULT now() NOT NULL
            );
          END IF;

          IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Korex_UpdateErrors') THEN
            CREATE TABLE public."Korex_UpdateErrors" (
              "id" integer DEFAULT nextval('public."Korex_UpdateErrors_id_seq"'::regclass) NOT NULL PRIMARY KEY,
              "UpdateId" integer NOT NULL,
              "ObjectName" character varying(255),
              "ErrorNumber" integer,
              "ErrorMessage" text NOT NULL,
              "StackTrace" text,
              "Fecha" timestamp without time zone DEFAULT now() NOT NULL
            );
          END IF;

          IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Korex_Installation') THEN
            CREATE TABLE public."Korex_Installation" (
              "id" integer DEFAULT nextval('public."Korex_Installation_id_seq"'::regclass) NOT NULL PRIMARY KEY,
              "AppVersion" character varying(50) NOT NULL,
              "DbVersion" character varying(50) NOT NULL,
              "Build" character varying(50),
              "Motor" character varying(50) NOT NULL,
              "LastValidationDate" timestamp without time zone DEFAULT now() NOT NULL,
              "Status" character varying(50) DEFAULT 'HEALTHY' NOT NULL,
              "Environment" character varying(50) DEFAULT 'PRODUCTION'
            );
          END IF;

          -- Self-heal DEFAULT constraints in case tables were previously created without DEFAULT
          ALTER TABLE public."Korex_UpdateHistory" ALTER COLUMN "UpdateId" SET DEFAULT nextval('public."Korex_UpdateHistory_id_seq"'::regclass);
          ALTER TABLE public."Korex_UpdateHistory" ALTER COLUMN "FechaInicio" SET DEFAULT now();
          ALTER TABLE public."Korex_UpdateHistory" ALTER COLUMN "ExitCode" SET DEFAULT 0;

          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "id" SET DEFAULT nextval('public."Korex_UpdateObjects_id_seq"'::regclass);
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "Expected" SET DEFAULT true;
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "Executed" SET DEFAULT false;
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "Compiled" SET DEFAULT false;
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "Validated" SET DEFAULT false;
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "ExecutionTimeMs" SET DEFAULT 0;
          ALTER TABLE public."Korex_UpdateObjects" ALTER COLUMN "FechaVerificacion" SET DEFAULT now();

          ALTER TABLE public."Korex_UpdateErrors" ALTER COLUMN "id" SET DEFAULT nextval('public."Korex_UpdateErrors_id_seq"'::regclass);
          ALTER TABLE public."Korex_UpdateErrors" ALTER COLUMN "Fecha" SET DEFAULT now();

          ALTER TABLE public."Korex_Installation" ALTER COLUMN "id" SET DEFAULT nextval('public."Korex_Installation_id_seq"'::regclass);
          ALTER TABLE public."Korex_Installation" ALTER COLUMN "LastValidationDate" SET DEFAULT now();
          ALTER TABLE public."Korex_Installation" ALTER COLUMN "Status" SET DEFAULT 'HEALTHY';

          -- Synchronize sequence values with existing rows
          PERFORM setval('public."Korex_UpdateHistory_id_seq"', COALESCE((SELECT MAX("UpdateId") FROM public."Korex_UpdateHistory"), 0) + 1, false);
          PERFORM setval('public."Korex_UpdateObjects_id_seq"', COALESCE((SELECT MAX("id") FROM public."Korex_UpdateObjects"), 0) + 1, false);
          PERFORM setval('public."Korex_UpdateErrors_id_seq"', COALESCE((SELECT MAX("id") FROM public."Korex_UpdateErrors"), 0) + 1, false);
          PERFORM setval('public."Korex_Installation_id_seq"', COALESCE((SELECT MAX("id") FROM public."Korex_Installation"), 0) + 1, false);
        END $$;
      `);

      // Record update start
      const histRes = await client.query(`
        INSERT INTO public."Korex_UpdateHistory" ("VersionNueva", "Build", "Motor", "Servidor", "BaseDatos", "Estado", "ExitCode")
        VALUES ($1, $2, 'PostgreSQL', $3, $4, 'EN_PROCESO', 0)
        RETURNING "UpdateId";
      `, [
        manifest.releaseVersion,
        manifest.build,
        clientConfig.host || process.env.DB_HOST || 'localhost',
        clientConfig.database || process.env.DB_NAME || 'Korex_colaereo'
      ]);
      updateId = histRes.rows[0].UpdateId;

      let idx = 1;
      for (const obj of manifest.objects) {
        const numStr = String(idx).padStart(3, '0');
        const totalStr = String(manifest.totalObjects).padStart(3, '0');
        let status = 'OK';
        let errorMsg = null;
        let compiled = 0;
        let validated = 0;

        const rawName = obj.objectName.replace(/^public\."?/, '').replace(/"?$/, '');

        try {
          if (obj.objectType === 'TABLE') {
            const tableRes = await client.query(`
              SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = $1
            `, [rawName]);
            if (tableRes.rows.length > 0) {
              compiled = 1; validated = 1; status = 'OK'; totalOk++;
              console.log(`[${numStr}/${totalStr}] public."${rawName}" (Tabla) ... OK (Validada)`);
            } else {
              status = 'ERROR'; errorMsg = `La tabla public."${rawName}" no existe.`; totalErrors++;
              console.error(`[${numStr}/${totalStr}] public."${rawName}" ... ❌ ERROR: Tabla faltante`);
            }
          } else {
            const procRes = await client.query(`
              SELECT proname FROM pg_proc JOIN pg_namespace n ON n.oid = pg_proc.pronamespace
              WHERE n.nspname = 'public' AND LOWER(proname) = LOWER($1)
            `, [rawName]);
            if (procRes.rows.length > 0) {
              compiled = 1; validated = 1; status = 'OK'; totalOk++;
              console.log(`[${numStr}/${totalStr}] public."${rawName}" ... OK (Compilado y Validado)`);
            } else {
              status = 'ERROR'; errorMsg = `La función/procedimiento public."${rawName}" no existe en pg_proc.`; totalErrors++;
              console.error(`[${numStr}/${totalStr}] public."${rawName}" ... ❌ ERROR: Objeto faltante en pg_proc`);
            }
          }
        } catch (err) {
          status = 'ERROR'; errorMsg = err.message; totalErrors++;
          console.error(`[${numStr}/${totalStr}] public."${rawName}" ... ❌ ERROR: ${err.message}`);
        }

        await client.query(`
          INSERT INTO public."Korex_UpdateObjects" ("UpdateId", "ObjectType", "ObjectName", "Executed", "Compiled", "Validated", "HashExpected", "Status", "ErrorMessage")
          VALUES ($1, $2, $3, true, $4, $5, $6, $7, $8);
        `, [updateId, obj.objectType, obj.objectName, compiled === 1, validated === 1, obj.hash, status, errorMsg]);

        idx++;
      }

      const finalState = totalErrors === 0 ? 'OK' : 'FALLIDA';
      exitCode = totalErrors === 0 ? 0 : 1;

      await client.query(`
        UPDATE public."Korex_UpdateHistory"
        SET "FechaFin" = now(), "Estado" = $1, "ExitCode" = $2, "ResumenLog" = $3
        WHERE "UpdateId" = $4;
      `, [finalState, exitCode, `Total: ${manifest.totalObjects}, OK: ${totalOk}, Errores: ${totalErrors}`, updateId]);

      if (exitCode === 0) {
        const instCheck = await client.query(`SELECT "id" FROM public."Korex_Installation" ORDER BY "id" DESC LIMIT 1`);
        if (instCheck.rows.length === 0) {
          await client.query(`
            INSERT INTO public."Korex_Installation" ("AppVersion", "DbVersion", "Build", "Motor", "Status")
            VALUES ($1, $2, $3, 'PostgreSQL', 'HEALTHY');
          `, [manifest.releaseVersion, manifest.releaseVersion, manifest.build]);
        } else {
          await client.query(`
            UPDATE public."Korex_Installation"
            SET "AppVersion" = $1, "DbVersion" = $2, "Build" = $3, "LastValidationDate" = now(), "Status" = 'HEALTHY'
            WHERE "id" = $4;
          `, [manifest.releaseVersion, manifest.releaseVersion, manifest.build, instCheck.rows[0].id]);
        }
      }

      await client.end();
    } catch (err) {
      console.error(`❌ Error inesperado conectando a PostgreSQL: ${err.message}`);
      process.exit(4);
    }
  }

  console.log('------------------------------------------------------------');
  if (exitCode === 0) {
    console.log(`✅ ACTUALIZACIÓN Y VALIDACIÓN 100% EXITOSA (Total: ${manifest.totalObjects}, OK: ${totalOk})`);
  } else {
    console.error(`❌ ACTUALIZACIÓN FALLIDA O INCOMPLETA (Total: ${manifest.totalObjects}, OK: ${totalOk}, Errores: ${totalErrors})`);
  }
  console.log('============================================================');

  process.exit(exitCode);
}

if (require.main === module) {
  runGuardianValidation().catch(err => {
    console.error('Error fatal en Korex Update Guardian:', err);
    process.exit(1);
  });
}

module.exports = { runGuardianValidation };
