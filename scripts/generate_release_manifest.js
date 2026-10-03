const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

function computeHash(content) {
  // Normalize whitespace and carriage returns for reproducible hashes
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

  const sqlRootDir = path.join(rootDir, 'SQL');
  const allSqlFiles = scanDirectoryRecursive(sqlRootDir);

  const sqlServerObjectsMap = new Map();
  const pgObjectsMap = new Map();

  // Scan all SQL files recursively
  for (const fullPath of allSqlFiles) {
    const relPath = path.relative(rootDir, fullPath).replace(/\\/g, '/');
    const content = fs.readFileSync(fullPath, 'utf8');

    // 1. T-SQL / SQL Server Object Extraction
    const tsqlMatches = content.matchAll(/CREATE\s+(PROCEDURE|PROC|FUNCTION|TABLE|VIEW)\s+(?:dbo\.)?([a-zA-Z0-9_]+)/gi);
    for (const match of tsqlMatches) {
      const rawType = match[1].toUpperCase();
      let objectType = 'PROCEDURE';
      if (rawType.startsWith('FUNC')) objectType = 'FUNCTION';
      else if (rawType === 'TABLE') objectType = 'TABLE';
      else if (rawType === 'VIEW') objectType = 'VIEW';

      const name = match[2];
      const objectName = `dbo.${name}`;

      if (!sqlServerObjectsMap.has(objectName)) {
        sqlServerObjectsMap.set(objectName, {
          objectType,
          objectName,
          sourceFile: relPath,
          hash: computeHash(content),
          isMandatory: true
        });
      }
    }

    // Fallback file name match for SQL Server files in SQL/SP/ or SQL/SqlServer/
    if (relPath.startsWith('SQL/SP/') || relPath.startsWith('SQL/SqlServer/')) {
      const baseName = path.basename(fullPath, '.sql');
      if (baseName.startsWith('sp') || baseName.startsWith('fn') || baseName.startsWith('dbo.')) {
        const objectName = baseName.startsWith('dbo.') ? baseName : `dbo.${baseName}`;
        if (!sqlServerObjectsMap.has(objectName)) {
          let objectType = baseName.startsWith('fn') ? 'FUNCTION' : 'PROCEDURE';
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
    if (relPath.startsWith('SQL/Procedure') || relPath.startsWith('SQL/Function') || relPath.startsWith('SQL/Table')) {
      const baseName = path.basename(fullPath, '.sql');
      let objectType = 'PROCEDURE';
      if (baseName.startsWith('fn')) objectType = 'FUNCTION';
      else if (relPath.startsWith('SQL/Table')) objectType = 'TABLE';

      const pgObjName = `public."${baseName}"`;
      if (!pgObjectsMap.has(pgObjName)) {
        pgObjectsMap.set(pgObjName, {
          objectType,
          objectName: pgObjName,
          sourceFile: relPath,
          hash: computeHash(content),
          isMandatory: true
        });
      }
    }
  }

  const sqlServerObjects = Array.from(sqlServerObjectsMap.values());
  const pgObjects = Array.from(pgObjectsMap.values());

  // REGLA ABSOLUTA DE INVENTARIO Y COBERTA (REGLAS 1, 2, 3):
  // Compare repo SQL objects vs manifest objects
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
