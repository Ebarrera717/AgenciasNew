const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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

function generateManifest() {
  const rootDir = path.resolve(__dirname, '..');
  const pkgPath = path.join(rootDir, 'package.json');
  let version = '3.7.13';
  if (fs.existsSync(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
    if (pkg.version) version = pkg.version;
  }

  const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const build = `${todayStr}.01`;

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
    'SQL/Table'
  ];

  const allFilesSet = new Set();
  for (const folder of sourceFolders) {
    const dirPath = path.join(rootDir, folder);
    if (fs.existsSync(dirPath)) {
      const found = scanDirectoryRecursive(dirPath);
      found.forEach(f => allFilesSet.add(f));
    }
  }
  const allSqlFiles = Array.from(allFilesSet);

  const sqlServerObjectsMap = new Map();
  const pgObjectsMap = new Map();

  for (const fullPath of allSqlFiles) {
    const relPath = path.relative(rootDir, fullPath).replace(/\\/g, '/');
    const content = fs.readFileSync(fullPath, 'utf8');

    if (relPath.includes('SQL/ZeusERP')) continue;
    const isZeusLegacyFile = relPath.includes('spFacturacionesCrear') || relPath.includes('spCotizacionesCrear') || relPath.includes('(2)');
    if (isZeusLegacyFile) continue;

    // 1. T-SQL / SQL Server Object Extraction (exclusivo SQL/SqlServer)
    if (relPath.startsWith('SQL/SqlServer/')) {
      const cleanTsql = content.replace(/\/\*[\s\S]*?\*\//g, '').replace(/--.*$/gm, '');
      const tsqlMatches = cleanTsql.matchAll(/CREATE\s+(?:OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION|TABLE|VIEW)\s+(?:\[?dbo\]?\.)?\[?([a-zA-Z0-9_]+)\]?/gi);
      for (const match of tsqlMatches) {
        const rawType = match[1].toUpperCase();
        let objectType = 'PROCEDURE';
        if (rawType.startsWith('FUNC')) objectType = 'FUNCTION';
        else if (rawType === 'TABLE') objectType = 'TABLE';
        else if (rawType === 'VIEW') objectType = 'VIEW';

        const name = match[2];
        if (/^(dbo|public|if|table|temp)$/i.test(name)) continue;
        const objectName = `dbo.${name}`;

        if (!sqlServerObjectsMap.has(objectName) && !name.startsWith('spFacturacionesCrear') && !name.startsWith('spCotizacionesCrear')) {
          sqlServerObjectsMap.set(objectName, {
            objectType,
            objectName,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true
          });
        }
      }
    }

    // 2. PostgreSQL Object Extraction
    const isExplicitTsql = !isZeusLegacyFile && relPath.includes('SQL/SqlServer');
    const isExplicitPlpgsql = relPath.includes('SQL/PostgreSQL') || /plpgsql/i.test(content) || /\bDO\s+\$\$/i.test(content) || (relPath.includes('SQL/Table') && !relPath.includes('SqlServer'));

    if (isExplicitPlpgsql || (!isExplicitTsql && (relPath.includes('SQL/SP') || relPath.includes('SQL/Function') || relPath.includes('SQL/Procedure')))) {
      let matchedPgInFile = 0;
      const pgMatches = content.matchAll(/CREATE\s+(?:OR\s+REPLACE\s+)?(PROCEDURE|FUNCTION|TABLE|VIEW)\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?("?[a-zA-Z0-9_]+"|sp[a-zA-Z0-9_]+|fn[a-zA-Z0-9_]+)/gi);
      for (const match of pgMatches) {
        const rawType = match[1].toUpperCase();
        let objectType = 'PROCEDURE';
        if (rawType.startsWith('FUNC')) objectType = 'FUNCTION';
        else if (rawType === 'TABLE') objectType = 'TABLE';
        else if (rawType === 'VIEW') objectType = 'VIEW';

        const rawName = match[2].replace(/"/g, '');
        if (/^(dbo|public|if|table|temp)$/i.test(rawName)) continue;
        const pgObjName = objectType === 'TABLE' ? `public."${rawName}"` : `public.${rawName}`;
        matchedPgInFile++;

        if (!pgObjectsMap.has(pgObjName)) {
          pgObjectsMap.set(pgObjName, {
            objectType,
            objectName: pgObjName,
            sourceFile: relPath,
            hash: computeHash(content),
            isMandatory: true,
            engine: 'PostgreSQL'
          });
        }
      }

      const baseName = path.basename(fullPath, '.sql');
      if (matchedPgInFile === 0 && relPath.includes('PostgreSQL/SP/') && !pgObjectsMap.has(`public.${baseName}`)) {
        pgObjectsMap.set(`public.${baseName}`, {
          objectType: 'PROCEDURE',
          objectName: `public.${baseName}`,
          sourceFile: relPath,
          hash: computeHash(content),
          isMandatory: true,
          engine: 'PostgreSQL'
        });
      } else if (matchedPgInFile === 0 && relPath.includes('PostgreSQL/Function/') && !pgObjectsMap.has(`public.${baseName}`)) {
        pgObjectsMap.set(`public.${baseName}`, {
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

  const controlTablesSqlServer = [
    'dbo.Korex_UpdateHistory',
    'dbo.Korex_UpdateObjects',
    'dbo.Korex_UpdateErrors',
    'dbo.Korex_Installation'
  ];
  controlTablesSqlServer.forEach(tbl => {
    if (!sqlServerObjectsMap.has(tbl)) {
      sqlServerObjectsMap.set(tbl, {
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
    if (!pgObjectsMap.has(tbl)) {
      pgObjectsMap.set(tbl, {
        objectType: 'TABLE',
        objectName: tbl,
        sourceFile: 'SQL/Table/TABLEINI.sql',
        hash: 'KOREX_CONTROL_TABLE',
        isMandatory: true,
        engine: 'PostgreSQL'
      });
    }
  });

  const sqlServerObjects = Array.from(sqlServerObjectsMap.values());
  const pgObjects = Array.from(pgObjectsMap.values());

  if (sqlServerObjects.length === 0 || pgObjects.length === 0) {
    console.error('❌ ERROR CRÍTICO [Exit Code 5]: El manifest no representa el inventario completo del proyecto. Se detectaron 0 objetos.');
    process.exit(5);
  }

  const manifestSqlServer = {
    releaseVersion: version,
    build,
    engine: 'SQLServer',
    generatedAt: new Date().toISOString(),
    totalObjects: sqlServerObjects.length,
    objects: sqlServerObjects
  };

  const manifestPostgreSql = {
    releaseVersion: version,
    build,
    engine: 'PostgreSQL',
    generatedAt: new Date().toISOString(),
    totalObjects: pgObjects.length,
    objects: pgObjects
  };

  const targetSqlServerPath = path.join(rootDir, 'SQL', 'manifest-sqlserver.json');
  const targetPgPath = path.join(rootDir, 'SQL', 'manifest-postgresql.json');

  fs.writeFileSync(targetSqlServerPath, JSON.stringify(manifestSqlServer, null, 2), 'utf8');
  fs.writeFileSync(targetPgPath, JSON.stringify(manifestPostgreSql, null, 2), 'utf8');

  console.log(`✅ Release Manifests generados exitosamente con inventario recursivo:`);
  console.log(`   - SQL Server: ${manifestSqlServer.totalObjects} objetos -> ${targetSqlServerPath}`);
  console.log(`   - PostgreSQL: ${manifestPostgreSql.totalObjects} objetos -> ${targetPgPath}`);
}

if (require.main === module) {
  try {
    generateManifest();
  } catch (e) {
    console.error('❌ ERROR CRÍTICO en la generación de manifest:', e.message);
    process.exit(5);
  }
}

module.exports = { generateManifest, computeHash };
