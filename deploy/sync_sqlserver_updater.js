const fs = require('fs');
const path = require('path');

// ============================================================================
// AGENCIASNEW - SINCRONIZADOR DEL ACTUALIZADOR T-SQL PARA SQL SERVER
// Archivo: deploy/sync_sqlserver_updater.js
// ============================================================================

function syncSqlServerUpdater() {
    console.log('\n================================================================');
    console.log('  SINCRONIZADOR DE ACTUALIZADOR T-SQL (ActualizadorSERVER.sql)   ');
    console.log('================================================================\n');

    const sqlDir = path.join(__dirname, '..', 'SQL', 'SqlServer');
    const pathTables = path.join(sqlDir, '01_Tables.sql');
    const pathSeeds = path.join(sqlDir, '02_Seeds.sql');
    const pathSps = path.join(sqlDir, '03_Functions_And_SPs.sql');

    if (!fs.existsSync(pathTables) || !fs.existsSync(pathSeeds) || !fs.existsSync(pathSps)) {
        console.error('❌ ERROR: No se encontraron los archivos fuente en SQL/SqlServer/');
        return;
    }

    const contentTables = fs.readFileSync(pathTables, 'utf8');
    const contentSeeds = fs.readFileSync(pathSeeds, 'utf8');
    const contentSps = fs.readFileSync(pathSps, 'utf8');

    const header = `-- ============================================================================
-- AGENCIASNEW - SCRIPT DE ACTUALIZACIÓN IDEMPOTENTE PARA SQL SERVER
-- Generado Automáticamente por deploy/sync_sqlserver_updater.js
-- Fecha de Generación: ${new Date().toISOString()}
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

`;

    const fullScript = header + 
        '-- --------------------------------------------------------------------------\n' +
        '-- SECCIÓN 1: ALTERACIÓN Y CREACIÓN IDEMPOTENTE DE TABLAS (DDL)\n' +
        '-- --------------------------------------------------------------------------\n' +
        contentTables + '\n\nGO\n\n' +
        '-- --------------------------------------------------------------------------\n' +
        '-- SECCIÓN 2: INYECCIÓN Y PRESERVACIÓN DE SEMILLAS Y PARÁMETROS\n' +
        '-- --------------------------------------------------------------------------\n' +
        contentSeeds + '\n\nGO\n\n' +
        '-- --------------------------------------------------------------------------\n' +
        '-- SECCIÓN 3: COMPILACIÓN Y ACTUALIZACIÓN DE PROCEDIMIENTOS Y FUNCIONES\n' +
        '-- --------------------------------------------------------------------------\n' +
        contentSps + '\n\nGO\n';

    const targetPaths = [
        path.join(__dirname, '..', 'SQL', 'Actualizador', 'ActualizadorSERVER.sql'),
        path.join(__dirname, '..', 'RELEASE_KOREX', 'SQL', 'ActualizadorSERVER.SQL')
    ];

    for (const targetPath of targetPaths) {
        const targetDir = path.dirname(targetPath);
        if (!fs.existsSync(targetDir)) {
            fs.mkdirSync(targetDir, { recursive: true });
        }
        fs.writeFileSync(targetPath, fullScript, 'utf8');
        console.log(` -> Actualizador T-SQL generado exitosamente en: ${targetPath}`);
    }

    console.log('\n================================================================');
    console.log('   SINCRONIZACIÓN DEL ACTUALIZADOR SQL SERVER FINALIZADA        ');
    console.log('================================================================\n');
}

if (require.main === module) {
    syncSqlServerUpdater();
}

module.exports = { syncSqlServerUpdater };
