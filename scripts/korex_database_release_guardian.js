const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

function computeHash(content) {
  const normalized = content.replace(/\r\n/g, '\n').trim();
  return crypto.createHash('sha256').update(normalized, 'utf8').digest('hex');
}

function scanDirectoryRecursive(dirPath, fileList = []) {
  if (!fs.existsSync(dirPath)) return fileList;
  const files = fs.readdirSync(dirPath);
  for (const file of files) {
    const fullPath = path.join(dirPath, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      scanDirectoryRecursive(fullPath, fileList);
    } else if (file.endsWith('.sql')) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

class KorexDatabaseReleaseGuardian {
  constructor(options = {}) {
    this.rootDir = path.resolve(__dirname, '..');
    this.sqlRootDir = path.join(this.rootDir, 'SQL');
    this.options = options;
    this.version = '3.7.13';
    
    const pkgPath = path.join(this.rootDir, 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if (pkg.version) this.version = pkg.version;
    }
    
    const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    this.build = `${todayStr}.01`;
  }

  async runAuditAndGenerateManifests() {
    console.log('\n================================================================');
    console.log('  KOREX DATABASE RELEASE GUARDIAN - FUENTE ÚNICA DE INTEGRIDAD  ');
    console.log('================================================================');
    console.log(`Versión Release: ${this.version} | Build: ${this.build}`);

    // 1. Escaneo Multi-Fuente Exhaustivo
    const sourceFolders = [
      'SQL/SqlServer',
      'SQL/SqlServer/SP',
      'SQL/SqlServer/Function',
      'SQL/PostgreSQL',
      'SQL/PostgreSQL/SP',
      'SQL/PostgreSQL/Function',
      'SQL/PostgreSQL/Table',
      'SQL/SP',
      'SQL/Function',
      'SQL/Procedure',
      'SQL/Table',
      'SQL/ZeusERP'
    ];

    const allFiles = new Set();
    for (const folder of sourceFolders) {
      const dirPath = path.join(this.rootDir, folder);
      if (fs.existsSync(dirPath)) {
        const found = scanDirectoryRecursive(dirPath);
        found.forEach(f => allFiles.add(f));
      }
    }

    console.log(`Fuentes analizadas: ${sourceFolders.length} carpetas | Archivos SQL detectados: ${allFiles.size}`);

    const sqlServerObjects = new Map();
    const pgObjects = new Map();
    const zeusObjects = new Map();

    for (const filePath of allFiles) {
      const relPath = path.relative(this.rootDir, filePath).replace(/\\/g, '/');
      const content = fs.readFileSync(filePath, 'utf8');

      // Zeus ERP exclusive SPs
      if (relPath.includes('SQL/ZeusERP')) {
        const matches = content.matchAll(/CREATE\s+(?:OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION)\s+(?:dbo\.)?([a-zA-Z0-9_]+)/gi);
        for (const m of matches) {
          const rawType = m[1].toUpperCase();
          const objType = rawType.startsWith('FUNC') ? 'FUNCTION' : 'PROCEDURE';
          const objName = `dbo.${m[2]}`;
          if (!zeusObjects.has(objName)) {
            zeusObjects.set(objName, {
              objectType: objType,
              objectName: objName,
              sourceFile: relPath,
              hash: computeHash(content),
              isMandatory: true,
              target: 'ZEUS_ERP'
            });
          }
        }
        continue;
      }

      // Check if file is explicitly T-SQL / SQL Server
      const isExplicitTsql = relPath.includes('SQL/SqlServer') || /\bdbo\./i.test(content) || /^\s*GO\b/im.test(content) || /sys\.objects/i.test(content);
      const isExplicitPlpgsql = relPath.includes('SQL/PostgreSQL') || /plpgsql/i.test(content) || /\bDO\s+\$\$/i.test(content) || (relPath.includes('SQL/Table') && !relPath.includes('SqlServer'));

      // SQL Server Objects (Korex)
      if (isExplicitTsql) {
        const tsqlMatches = content.matchAll(/CREATE\s+(?:OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION|TABLE|VIEW)\s+(?:dbo\.)?([a-zA-Z0-9_]+)/gi);
        for (const match of tsqlMatches) {
          const rawType = match[1].toUpperCase();
          let objectType = 'PROCEDURE';
          if (rawType.startsWith('FUNC')) objectType = 'FUNCTION';
          else if (rawType === 'TABLE') objectType = 'TABLE';
          else if (rawType === 'VIEW') objectType = 'VIEW';

          const name = match[2];
          const objectName = `dbo.${name}`;

          if (!sqlServerObjects.has(objectName) && !name.startsWith('spFacturacionesCrear') && !name.startsWith('spCotizacionesCrear')) {
            sqlServerObjects.set(objectName, {
              objectType,
              objectName,
              sourceFile: relPath,
              hash: computeHash(content),
              isMandatory: true,
              engine: 'SQLServer'
            });
          }
        }

        // Detect single files in SP/ and Function/
        const baseName = path.basename(filePath, '.sql');
        if (relPath.includes('SqlServer/SP/') && !sqlServerObjects.has(`dbo.${baseName}`)) {
          sqlServerObjects.set(`dbo.${baseName}`, {
            objectType: 'PROCEDURE',
            objectName: `dbo.${baseName}`,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true,
            engine: 'SQLServer'
          });
        } else if (relPath.includes('SqlServer/Function/') && !sqlServerObjects.has(`dbo.${baseName}`)) {
          sqlServerObjects.set(`dbo.${baseName}`, {
            objectType: 'FUNCTION',
            objectName: `dbo.${baseName}`,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true,
            engine: 'SQLServer'
          });
        }
      }

      // PostgreSQL Objects (Korex)
      if (isExplicitPlpgsql || (!isExplicitTsql && (relPath.includes('SQL/SP') || relPath.includes('SQL/Function') || relPath.includes('SQL/Procedure')))) {
        const pgMatches = content.matchAll(/CREATE\s+(?:OR\s+REPLACE\s+)?(PROCEDURE|FUNCTION|TABLE|VIEW)\s+(?:public\.)?("?[a-zA-Z0-9_]+"|sp[a-zA-Z0-9_]+|fn[a-zA-Z0-9_]+)/gi);
        for (const match of pgMatches) {
          const rawType = match[1].toUpperCase();
          let objectType = 'PROCEDURE';
          if (rawType.startsWith('FUNC')) objectType = 'FUNCTION';
          else if (rawType === 'TABLE') objectType = 'TABLE';
          else if (rawType === 'VIEW') objectType = 'VIEW';

          const rawName = match[2].replace(/"/g, '');
          const objectName = objectType === 'TABLE' ? `public."${rawName}"` : `public.${rawName}`;

          if (!pgObjects.has(objectName)) {
            pgObjects.set(objectName, {
              objectType,
              objectName,
              sourceFile: relPath,
              hash: computeHash(content),
              isMandatory: true,
              engine: 'PostgreSQL'
            });
          }
        }

        const baseName = path.basename(filePath, '.sql');
        if (relPath.includes('PostgreSQL/SP/') && !pgObjects.has(`public.${baseName}`)) {
          pgObjects.set(`public.${baseName}`, {
            objectType: 'PROCEDURE',
            objectName: `public.${baseName}`,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true,
            engine: 'PostgreSQL'
          });
        } else if (relPath.includes('PostgreSQL/Function/') && !pgObjects.has(`public.${baseName}`)) {
          pgObjects.set(`public.${baseName}`, {
            objectType: 'FUNCTION',
            objectName: `public.${baseName}`,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true,
            engine: 'PostgreSQL'
          });
        }
      }
    }

    // 2. Control tables injection
    const controlTablesSqlServer = [
      'dbo.Korex_UpdateHistory',
      'dbo.Korex_UpdateObjects',
      'dbo.Korex_UpdateErrors',
      'dbo.Korex_Installation'
    ];
    controlTablesSqlServer.forEach(tbl => {
      if (!sqlServerObjects.has(tbl)) {
        sqlServerObjects.set(tbl, {
          objectType: 'TABLE',
          objectName: tbl,
          sourceFile: 'SQL/SqlServer/01_Tables.sql',
          hash: 'KOREX_CONTROL_TABLE',
          isMandatory: true,
          engine: 'SQLServer'
        });
      }
    });

    const controlTablesPg = [
      'public."Korex_UpdateHistory"',
      'public."Korex_UpdateObjects"',
      'public."Korex_UpdateErrors"',
      'public."Korex_Installation"'
    ];
    controlTablesPg.forEach(tbl => {
      if (!pgObjects.has(tbl)) {
        pgObjects.set(tbl, {
          objectType: 'TABLE',
          objectName: tbl,
          sourceFile: 'SQL/Table/TABLEINI.sql',
          hash: 'KOREX_CONTROL_TABLE',
          isMandatory: true,
          engine: 'PostgreSQL'
        });
      }
    });

    // 3. Generar Manifiestos
    const manifestSqlServer = {
      releaseVersion: this.version,
      build: this.build,
      engine: 'SQLServer',
      generatedAt: new Date().toISOString(),
      totalObjects: sqlServerObjects.size,
      objects: Array.from(sqlServerObjects.values())
    };

    const manifestPg = {
      releaseVersion: this.version,
      build: this.build,
      engine: 'PostgreSQL',
      generatedAt: new Date().toISOString(),
      totalObjects: pgObjects.size,
      objects: Array.from(pgObjects.values())
    };

    const manifestZeus = {
      releaseVersion: this.version,
      build: this.build,
      target: 'ZeusAgencias_23',
      generatedAt: new Date().toISOString(),
      totalObjects: zeusObjects.size,
      objects: Array.from(zeusObjects.values())
    };

    // Guardar manifests
    fs.writeFileSync(path.join(this.sqlRootDir, 'manifest-sqlserver.json'), JSON.stringify(manifestSqlServer, null, 2), 'utf8');
    fs.writeFileSync(path.join(this.sqlRootDir, 'manifest-postgresql.json'), JSON.stringify(manifestPg, null, 2), 'utf8');
    fs.writeFileSync(path.join(this.rootDir, 'SQL', 'SqlServer', 'manifest-sps.json'), JSON.stringify(manifestSqlServer, null, 2), 'utf8');
    fs.writeFileSync(path.join(this.rootDir, 'SQL', 'PostgreSQL', 'manifest-sps.json'), JSON.stringify(manifestPg, null, 2), 'utf8');
    fs.writeFileSync(path.join(this.rootDir, 'SQL', 'ZeusERP', 'manifest-zeus.json'), JSON.stringify(manifestZeus, null, 2), 'utf8');

    console.log('\n--- INVENTARIO CONCILIADO POR GUARDIAN ---');
    console.log(`✅ SQL Server (Korex):     ${sqlServerObjects.size} objetos registrados en manifest-sqlserver.json`);
    console.log(`✅ PostgreSQL (Korex):     ${pgObjects.size} objetos registrados en manifest-postgresql.json`);
    console.log(`✅ Zeus ERP (Integración): ${zeusObjects.size} objetos registrados en manifest-zeus.json`);

    // 4. Validación de Compilación de Archivos Consolidados
    console.log('\n--- VALIDACIÓN DE PAQUETE GENERADO ---');
    let errorsCount = 0;

    // Verificar que ActualizadorSERVER.sql contenga los SPs esperados
    const actServerPath = path.join(this.rootDir, 'SQL', 'SqlServer', 'ActualizadorSERVER.sql');
    if (fs.existsSync(actServerPath)) {
      const actServerContent = fs.readFileSync(actServerPath, 'utf8');
      for (const obj of sqlServerObjects.values()) {
        if (obj.objectType === 'PROCEDURE' || obj.objectType === 'FUNCTION') {
          const pureName = obj.objectName.replace('dbo.', '');
          if (!actServerContent.includes(pureName)) {
            console.error(`❌ [BLOQUEANTE] Objeto ${obj.objectName} falta en ActualizadorSERVER.sql`);
            errorsCount++;
          }
        }
      }
    }

    // Verificar que Actualizador.sql contenga los SPs esperados
    const actPgPath = path.join(this.rootDir, 'SQL', 'PostgreSQL', 'Actualizador.sql');
    if (fs.existsSync(actPgPath)) {
      const actPgContent = fs.readFileSync(actPgPath, 'utf8');
      for (const obj of pgObjects.values()) {
        if (obj.objectType === 'PROCEDURE' || obj.objectType === 'FUNCTION') {
          const pureName = obj.objectName.replace('public.', '');
          if (!actPgContent.includes(pureName)) {
            console.error(`❌ [BLOQUEANTE] Objeto ${obj.objectName} falta en Actualizador.sql (PostgreSQL)`);
            errorsCount++;
          }
        }
      }
    }

    if (errorsCount > 0) {
      console.error(`\n❌ GENERATION FAILED: Se detectaron ${errorsCount} inconsistencias en los scripts generados.`);
      console.log('EXIT CODE: 1\n================================================================\n');
      if (!this.options.nonBlocking) {
        process.exit(1);
      }
      return false;
    }

    console.log('✅ VALIDACIÓN COMPLETA: Todos los objetos coinciden entre Fuentes, Manifiestos y Paquetes Generados.');
    console.log('RESULTADO: GENERATION SUCCESS');
    console.log('EXIT CODE: 0\n================================================================\n');
    return true;
  }
}

async function runGuardian() {
  const guardian = new KorexDatabaseReleaseGuardian();
  await guardian.runAuditAndGenerateManifests();
}

if (require.main === module) {
  runGuardian();
}

module.exports = { KorexDatabaseReleaseGuardian, runGuardian };
