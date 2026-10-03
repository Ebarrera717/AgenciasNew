const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');

function generatePostgresFunctionsAndSps() {
    console.log('\n================================================================');
    console.log('   ORGANIZANDO Y COMPILANDO OBJETOS SQL DE POSTGRESQL           ');
    console.log('================================================================\n');

    const pgBaseDir = path.join(rootDir, 'SQL', 'PostgreSQL');
    const pgSpDir = path.join(pgBaseDir, 'SP');
    const pgFuncDir = path.join(pgBaseDir, 'Function');
    const pgTableDir = path.join(pgBaseDir, 'Table');

    // 1. Crear directorios si no existen
    [pgBaseDir, pgSpDir, pgFuncDir, pgTableDir].forEach(dir => {
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
    });

    // 2. Sincronizar Funciones de PostgreSQL
    const srcFuncDir = path.join(rootDir, 'SQL', 'Function');
    let functionsList = [];
    if (fs.existsSync(srcFuncDir)) {
        const funcFiles = fs.readdirSync(srcFuncDir).filter(f => f.endsWith('.sql')).sort();
        for (const file of funcFiles) {
            const srcPath = path.join(srcFuncDir, file);
            const content = fs.readFileSync(srcPath, 'utf8').replace(/^\uFEFF/, '');
            // Verificar que no sea T-SQL
            if (!/\bdbo\./i.test(content) && !/^\s*GO\b/im.test(content)) {
                const destPath = path.join(pgFuncDir, file);
                fs.writeFileSync(destPath, content, 'utf8');
                functionsList.push({ file, content });
            }
        }
    }
    console.log(`✅ ${functionsList.length} funciones sincronizadas en SQL/PostgreSQL/Function/`);

    // 3. Sincronizar Procedimientos Almacenados (SPs) de PostgreSQL
    const spSourceDirs = [
        path.join(rootDir, 'SQL', 'SP'),
        path.join(rootDir, 'SQL', 'Procedure')
    ];
    let spsList = [];
    const seenSps = new Set();

    for (const srcDir of spSourceDirs) {
        if (fs.existsSync(srcDir)) {
            const spFiles = fs.readdirSync(srcDir).filter(f => f.endsWith('.sql')).sort();
            for (const file of spFiles) {
                if (seenSps.has(file)) continue;
                const srcPath = path.join(srcDir, file);
                const content = fs.readFileSync(srcPath, 'utf8').replace(/^\uFEFF/, '');
                // Verificar que sea PostgreSQL y no T-SQL
                if (!/\bdbo\./i.test(content) && !/^\s*GO\b/im.test(content) && !/sys\.objects/i.test(content)) {
                    const destPath = path.join(pgSpDir, file);
                    fs.writeFileSync(destPath, content, 'utf8');
                    seenSps.add(file);
                    spsList.push({ file, content });
                }
            }
        }
    }
    console.log(`✅ ${spsList.length} procedimientos almacenados (SPs) sincronizados en SQL/PostgreSQL/SP/`);

    // 4. Sincronizar Tablas y DDL de PostgreSQL
    const srcTableDir = path.join(rootDir, 'SQL', 'Table');
    let tablesList = [];
    if (fs.existsSync(srcTableDir)) {
        const tableFiles = fs.readdirSync(srcTableDir).filter(f => f.endsWith('.sql')).sort();
        for (const file of tableFiles) {
            const srcPath = path.join(srcTableDir, file);
            const content = fs.readFileSync(srcPath, 'utf8').replace(/^\uFEFF/, '');
            const destPath = path.join(pgTableDir, file);
            fs.writeFileSync(destPath, content, 'utf8');
            tablesList.push(file);
        }
    }
    console.log(`✅ ${tablesList.length} archivos de tablas sincronizados en SQL/PostgreSQL/Table/`);

    // 5. Generar 01_Tables.sql para PostgreSQL (basado en Alter_New_Columns.sql)
    const alterColPath = path.join(srcTableDir, 'Alter_New_Columns.sql');
    if (fs.existsSync(alterColPath)) {
        const alterContent = fs.readFileSync(alterColPath, 'utf8');
        fs.writeFileSync(path.join(pgBaseDir, '01_Tables.sql'), alterContent, 'utf8');
        console.log('✅ SQL/PostgreSQL/01_Tables.sql generado exitosamente.');
    }

    // 5.5 Generar 02_Seeds.sql para PostgreSQL (basado en Inicial.sql)
    const inicialPath = path.join(rootDir, 'SQL', 'Inicial.sql');
    let seedsContent = '';
    if (fs.existsSync(inicialPath)) {
        seedsContent = fs.readFileSync(inicialPath, 'utf8');
        fs.writeFileSync(path.join(pgBaseDir, '02_Seeds.sql'), seedsContent, 'utf8');
        console.log('✅ SQL/PostgreSQL/02_Seeds.sql generado exitosamente.');
    }

    // 6. Generar TODOS_LOS_SPS_Y_FUNCIONES_POSTGRESQL.sql y 03_Functions_And_SPs.sql
    let consolidatedSql = `-- ============================================================================
-- AGENCIASNEW - PROCEDIMIENTOS ALMACENADOS Y FUNCIONES EN POSTGRESQL
-- Archivo: SQL/PostgreSQL/TODOS_LOS_SPS_Y_FUNCIONES_POSTGRESQL.sql
-- Motor: PostgreSQL 12+ (PL/pgSQL)
-- ============================================================================

-- Configuración de Codificación y Parámetros
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

`;

    // Agregar todas las funciones
    consolidatedSql += `\n-- ############################################################################\n`;
    consolidatedSql += `-- 1. FUNCIONES SQL (PL/pgSQL)\n`;
    consolidatedSql += `-- ############################################################################\n\n`;

    for (const item of functionsList) {
        consolidatedSql += `-- ============================================================================\n`;
        consolidatedSql += `-- Función: ${item.file}\n`;
        consolidatedSql += `-- ============================================================================\n`;
        consolidatedSql += item.content.trim() + '\n\n';
    }

    // Agregar todos los SPs
    consolidatedSql += `\n-- ############################################################################\n`;
    consolidatedSql += `-- 2. PROCEDIMIENTOS ALMACENADOS (SPs) (PL/pgSQL)\n`;
    consolidatedSql += `-- ############################################################################\n\n`;

    for (const item of spsList) {
        consolidatedSql += `-- ============================================================================\n`;
        consolidatedSql += `-- Procedimiento Almacenado: ${item.file}\n`;
        consolidatedSql += `-- ============================================================================\n`;
        consolidatedSql += item.content.trim() + '\n\n';
    }

    const compiledAllPath = path.join(pgBaseDir, 'TODOS_LOS_SPS_Y_FUNCIONES_POSTGRESQL.sql');
    fs.writeFileSync(compiledAllPath, consolidatedSql, 'utf8');

    const compiled03Path = path.join(pgBaseDir, '03_Functions_And_SPs.sql');
    fs.writeFileSync(compiled03Path, consolidatedSql, 'utf8');

    // 7. Generar Actualizador.sql completo de PostgreSQL en SQL/PostgreSQL/Actualizador.sql
    let pgActualizador = `-- ============================================================================
-- AGENCIASNEW - SCRIPT DE ACTUALIZACIÓN COMPLETA PARA POSTGRESQL
-- Archivo: SQL/PostgreSQL/Actualizador.sql
-- Motor: PostgreSQL 12+ (PL/pgSQL)
-- ============================================================================

-- >>> 1. ESTRUCTURA Y TABLAS DDL <<<
` + (fs.existsSync(alterColPath) ? fs.readFileSync(alterColPath, 'utf8') : '') + `\n\n` +
`-- >>> 2. SEMILLAS Y CONFIGURACIÓN INICIAL <<<
` + seedsContent + `\n\n` +
`-- >>> 3. PROCEDIMIENTOS ALMACENADOS Y FUNCIONES <<<
` + consolidatedSql;

    const pgActualizadorPath = path.join(pgBaseDir, 'Actualizador.sql');
    fs.writeFileSync(pgActualizadorPath, pgActualizador, 'utf8');

    console.log('✅ SQL/PostgreSQL/TODOS_LOS_SPS_Y_FUNCIONES_POSTGRESQL.sql generado exitosamente.');
    console.log('✅ SQL/PostgreSQL/03_Functions_And_SPs.sql generado exitosamente.');
    console.log('✅ SQL/PostgreSQL/Actualizador.sql generado exitosamente.');
    console.log('================================================================\n');

    return {
        functionsCount: functionsList.length,
        spsCount: spsList.length,
        tablesCount: tablesList.length
    };
}

if (require.main === module) {
    generatePostgresFunctionsAndSps();
}

module.exports = { generatePostgresFunctionsAndSps };
