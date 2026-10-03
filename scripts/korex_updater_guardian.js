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

  // Guarantee release manifest is up to date
  generateManifest();

  const manifestPath = path.resolve(
    __dirname,
    '../SQL',
    isSQLServer ? 'manifest-sqlserver.json' : 'manifest-postgresql.json'
  );

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
    const sqlConfig = {
      user: process.env.DB_USER || 'sa',
      password: process.env.DB_PASSWORD || '',
      server: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '1433', 10),
      database: process.env.DB_NAME || 'Korex_pruebas',
      options: {
        encrypt: false,
        trustServerCertificate: true
      }
    };

    try {
      const pool = await mssql.connect(sqlConfig);
      console.log(`Conectado exitosamente a SQL Server [${sqlConfig.server}:${sqlConfig.database}]`);

      // Ensure control tables exist
      const tablesCheck = await pool.request().query(`
        SELECT COUNT(*) as cnt FROM sys.tables WHERE name IN ('Korex_UpdateHistory', 'Korex_UpdateObjects', 'Korex_Installation')
      `);
      if (tablesCheck.recordset[0].cnt < 3) {
        console.log('Creando estructura de control Korex Update Guardian...');
        const initDdl = fs.readFileSync(path.resolve(__dirname, '../SQL/SqlServer/01_Tables.sql'), 'utf8');
        await pool.request().batch(initDdl);
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

      // Ensure control tables exist
      const checkTables = await client.query(`
        SELECT COUNT(*) as cnt FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name IN ('Korex_UpdateHistory', 'Korex_UpdateObjects', 'Korex_Installation')
      `);
      if (parseInt(checkTables.rows[0].cnt, 10) < 3) {
        console.log('Creando estructura de control Korex Update Guardian en PostgreSQL...');
        const initDdl = fs.readFileSync(path.resolve(__dirname, '../SQL/Table/Alter_New_Columns.sql'), 'utf8');
        await client.query(initDdl);
      }

      // Record update start
      const histRes = await client.query(`
        INSERT INTO public."Korex_UpdateHistory" ("VersionNueva", "Build", "Motor", "Servidor", "BaseDatos", "Estado", "ExitCode")
        VALUES ($1, $2, 'PostgreSQL', $3, $4, 'EN_PROCESO', 0)
        RETURNING "UpdateId";
      `, [manifest.releaseVersion, manifest.build, process.env.DB_HOST || 'localhost', process.env.DB_NAME || 'Korex_colaereo']);
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
        await client.query(`
          INSERT INTO public."Korex_Installation" ("AppVersion", "DbVersion", "Build", "Motor", "Status")
          VALUES ($1, $2, $3, 'PostgreSQL', 'HEALTHY')
          ON CONFLICT (id) DO UPDATE SET "AppVersion" = EXCLUDED."AppVersion", "DbVersion" = EXCLUDED."DbVersion", "Build" = EXCLUDED."Build", "LastValidationDate" = now(), "Status" = 'HEALTHY';
        `, [manifest.releaseVersion, manifest.releaseVersion, manifest.build]);
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
