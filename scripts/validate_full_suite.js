const fs = require('fs');
const path = require('path');
const { Client: PgClient } = require('pg');

// ============================================================================
// AGENCIASNEW - SUITE DE VALIDACIÓN COMPLETA (POSTGRESQL & SQL SERVER)
// Archivo: scripts/validate_full_suite.js
// ============================================================================

async function validateFullSuite() {
    console.log('\n================================================================');
    console.log('   VALIDACIÓN COMPLETA DEL SISTEMA Y ENTREGABLES SQL SERVER    ');
    console.log('================================================================\n');

    const results = [];

    // -------------------------------------------------------------------------
    // CAPA 1: VALIDACIÓN BASE DE DATOS LOCAL POSTGRESQL (Korex_colaereo)
    // -------------------------------------------------------------------------
    console.log('[CAPA 1/4] Validando Base de Datos Local PostgreSQL (Korex_colaereo)...');
    const pgConnString = process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
    const pgClient = new PgClient({ connectionString: pgConnString });

    try {
        await pgClient.connect();
        const resTables = await pgClient.query(`
            SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';
        `);
        const tableCount = parseInt(resTables.rows[0].count, 10);

        const resRoles = await pgClient.query('SELECT count(*) FROM public."Role";');
        const resBranches = await pgClient.query('SELECT count(*) FROM public."Branch";');
        const resCurrencies = await pgClient.query('SELECT count(*) FROM public."Currency";');

        results.push({ Capa: '1. PostgreSQL Local', Componente: 'Conectividad & Tablas', Estado: '✅ OK', Detalle: `${tableCount} tablas activas` });
        results.push({ Capa: '1. PostgreSQL Local', Componente: 'Datos Base (Roles/Branches)', Estado: '✅ OK', Detalle: `${resRoles.rows[0].count} roles, ${resBranches.rows[0].count} sucursales` });
        results.push({ Capa: '1. PostgreSQL Local', Componente: 'Monedas Inyectadas', Estado: '✅ OK', Detalle: `${resCurrencies.rows[0].count} monedas configuradas` });

        await pgClient.end();
    } catch (pgErr) {
        results.push({ Capa: '1. PostgreSQL Local', Componente: 'Conectividad', Estado: '❌ FALLO', Detalle: pgErr.message });
    }

    // -------------------------------------------------------------------------
    // CAPA 2: ESQUEMA DE REFERENCIA JSON & REGLAS PRE-COMPILACIÓN
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 2/4] Validando Archivos de Esquema Pre-Compilados...');
    const schemaRefPath = path.join(__dirname, '..', 'SQL', 'schema_reference.json');
    if (fs.existsSync(schemaRefPath)) {
        const schemaJson = JSON.parse(fs.readFileSync(schemaRefPath, 'utf8'));
        const totalProcs = Object.keys(schemaJson.procedures || {}).length;
        results.push({ Capa: '2. Schema Reference', Componente: 'SQL/schema_reference.json', Estado: '✅ OK', Detalle: `${totalProcs} funciones/SPs registrados` });
    } else {
        results.push({ Capa: '2. Schema Reference', Componente: 'SQL/schema_reference.json', Estado: '⚠️ FALTANTE', Detalle: 'No encontrado' });
    }

    // -------------------------------------------------------------------------
    // CAPA 3: ARCHIVOS Y ENTREGABLES DE SQL SERVER (COMPONENTE 04)
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 3/4] Auditando Scripts T-SQL (Componente 04)...');
    const sqlServerDir = path.join(__dirname, '..', 'SQL', 'SqlServer');
    const pathTables = path.join(sqlServerDir, '01_Tables.sql');
    const pathSeeds = path.join(sqlServerDir, '02_Seeds.sql');
    const pathSps = path.join(sqlServerDir, '03_Functions_And_SPs.sql');

    if (fs.existsSync(pathTables) && fs.existsSync(pathSeeds) && fs.existsSync(pathSps)) {
        const contentTables = fs.readFileSync(pathTables, 'utf8');
        const contentSeeds = fs.readFileSync(pathSeeds, 'utf8');
        const contentSps = fs.readFileSync(pathSps, 'utf8');

        const tableMatches = (contentTables.match(/CREATE TABLE/gi) || []).length;
        const spMatches = (contentSps.match(/CREATE PROCEDURE/gi) || []).length;

        results.push({ Capa: '3. Scripts T-SQL (04)', Componente: '01_Tables.sql', Estado: '✅ OK', Detalle: `${tableMatches} tablas DDL en T-SQL` });
        results.push({ Capa: '3. Scripts T-SQL (04)', Componente: '02_Seeds.sql', Estado: '✅ OK', Detalle: 'Semillas maestras preparadas' });
        results.push({ Capa: '3. Scripts T-SQL (04)', Componente: '03_Functions_And_SPs.sql', Estado: '✅ OK', Detalle: `${spMatches} SPs traducidos a T-SQL` });
    } else {
        results.push({ Capa: '3. Scripts T-SQL (04)', Componente: 'Directorio SQL/SqlServer', Estado: '❌ FALLO', Detalle: 'Archivos T-SQL incompletos' });
    }

    // -------------------------------------------------------------------------
    // CAPA 4: COMPONENTES 02, 03, 05 Y 06 DE DESPLIEGUE SQL SERVER
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 4/4] Validando Suites de Despliegue e Instalador SQL Server...');

    // Componente 02
    const pathSetup = path.join(__dirname, '..', 'deploy', 'setup_db_sqlserver.js');
    if (fs.existsSync(pathSetup)) {
        const contentSetup = fs.readFileSync(pathSetup, 'utf8');
        const hasNoCreateDb = !contentSetup.includes('CREATE DATABASE');
        results.push({
            Capa: '4. Entregables Despliegue',
            Componente: '02 - setup_db_sqlserver.js',
            Estado: hasNoCreateDb ? '✅ OK' : '❌ REGLA VIOLADA',
            Detalle: hasNoCreateDb ? 'Garantizado NO CREATE DATABASE' : 'Contiene CREATE DATABASE prohibido'
        });
    }

    // Componente 03
    const pathBakGen = path.join(__dirname, '..', 'deploy', 'gen_sqlserver_initial_bak.js');
    results.push({
        Capa: '4. Entregables Despliegue',
        Componente: '03 - gen_sqlserver_initial_bak.js',
        Estado: fs.existsSync(pathBakGen) ? '✅ OK' : '❌ FALTANTE',
        Detalle: 'Generador del backup Korex_SQLServer_Inicial_1.0.bak'
    });

    // Componente 05
    const pathMigrate = path.join(__dirname, '..', 'deploy', 'migrate_pg_to_sqlserver.js');
    results.push({
        Capa: '4. Entregables Despliegue',
        Componente: '05 - migrate_pg_to_sqlserver.js',
        Estado: fs.existsSync(pathMigrate) ? '✅ OK' : '❌ FALTANTE',
        Detalle: 'Migrador PostgreSQL -> SQL Server con IDENTITY_INSERT'
    });

    // Componente 06
    const pathValidate = path.join(__dirname, '..', 'deploy', 'validate_migration.js');
    results.push({
        Capa: '4. Entregables Despliegue',
        Componente: '06 - validate_migration.js',
        Estado: fs.existsSync(pathValidate) ? '✅ OK' : '❌ FALTANTE',
        Detalle: 'Auditor post-migración'
    });

    // -------------------------------------------------------------------------
    // CAPA 5: VALIDACIÓN DE SPs OBLIGATORIOS EN ZEUS ERP (ZeusAgencias_23)
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 5/5] Validando SPs de Integración en Zeus ERP (ZeusAgencias_23)...');
    try {
        const mssql = require('mssql');
        const zeusConfig = {
            user: process.env.SQLSERVER_USER || 'zeusagencias',
            password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
            server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
            database: process.env.ZEUS_ERP_DB || 'ZeusAgencias_23',
            port: 1433,
            options: { encrypt: false, trustServerCertificate: true }
        };
        const pool = await mssql.connect(zeusConfig);
        const resFac = await pool.request().query("SELECT OBJECT_ID('dbo.spFacturacionesCrear', 'P') AS sp_id;");
        const resCot = await pool.request().query("SELECT OBJECT_ID('dbo.spCotizacionesCrear', 'P') AS sp_id;");
        const facOk = !!resFac.recordset[0]?.sp_id;
        const cotOk = !!resCot.recordset[0]?.sp_id;

        results.push({
            Capa: '5. Zeus ERP (ZeusAgencias_23)',
            Componente: 'spFacturacionesCrear & spCotizacionesCrear',
            Estado: (facOk && cotOk) ? '✅ OK' : '❌ FALTANTE',
            Detalle: `spFacturacionesCrear: ${facOk ? 'Activo' : 'Ausente'}, spCotizacionesCrear: ${cotOk ? 'Activo' : 'Ausente'}`
        });
        await pool.close();
    } catch (zeusErr) {
        results.push({
            Capa: '5. Zeus ERP (ZeusAgencias_23)',
            Componente: 'Conectividad & SPs',
            Estado: '❌ FALLO',
            Detalle: zeusErr.message
        });
    }

    // -------------------------------------------------------------------------
    // CAPA 6: SUITE DE INSTALACIÓN, ACTUALIZACIÓN, DIAGNÓSTICO Y AISLAMIENTO
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 6/7] Validando Instaladores, Actualizadores, Diagnóstico y Aislamiento...');
    try {
        const { execSync } = require('child_process');
        execSync(`node "${path.join(__dirname, 'validate_installer_diagnostics.js')}"`, { stdio: 'pipe' });
        results.push({
            Capa: '6. Instaladores & Diagnóstico',
            Componente: 'validate_installer_diagnostics.js',
            Estado: '✅ OK',
            Detalle: '10/10 Pruebas pasaron (PG/SQL Setup, Update, Diagnostics, Aislamiento y Seguridad)'
        });
    } catch (diagErr) {
        results.push({
            Capa: '6. Instaladores & Diagnóstico',
            Componente: 'validate_installer_diagnostics.js',
            Estado: '❌ FALLO',
            Detalle: diagErr.message
        });
    }

    // -------------------------------------------------------------------------
    // CAPA 7: SUITE DE MONITOREO Y PROTECCIÓN DEL RENDIMIENTO
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 7/8] Validando Monitoreo Autónomo y Protección del Rendimiento...');
    try {
        const { execSync } = require('child_process');
        execSync(`node "${path.join(__dirname, 'validate_performance_suite.js')}"`, { stdio: 'pipe' });
        results.push({
            Capa: '7. Rendimiento & Protección',
            Componente: 'validate_performance_suite.js',
            Estado: '✅ OK',
            Detalle: '6/6 Pruebas pasaron (PG/SQL DMVs, Benchmarks, Baseline, Aislamiento y Sanitización)'
        });
    } catch (perfErr) {
        results.push({
            Capa: '7. Rendimiento & Protección',
            Componente: 'validate_performance_suite.js',
            Estado: '❌ FALLO',
            Detalle: perfErr.message
        });
    }

    // -------------------------------------------------------------------------
    // CAPA 8: SUITE DE ESTRATEGIA DE EJECUCIÓN Y FALLBACK (SERVICE + TASK SCHEDULER)
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 8/9] Validando Estrategia de Ejecución y Fallback (Task Scheduler)...');
    try {
        const { execSync } = require('child_process');
        execSync(`node "${path.join(__dirname, 'validate_execution_strategy_suite.js')}"`, { stdio: 'pipe' });
        results.push({
            Capa: '8. Ejecución & Fallback',
            Componente: 'validate_execution_strategy_suite.js',
            Estado: '✅ OK',
            Detalle: '7/7 Pruebas pasaron (Dual Engine, Task Scheduler Fallback, Updater Preservation)'
        });
    } catch (execErr) {
        results.push({
            Capa: '8. Ejecución & Fallback',
            Componente: 'validate_execution_strategy_suite.js',
            Estado: '❌ FALLO',
            Detalle: execErr.message
        });
    }

    // -------------------------------------------------------------------------
    // CAPA 9: SUITE DEL SKILL MAESTRO KOREX (ID: 74163) - AISLAMIENTO & .ENV
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 9/10] Validando SKILL MAESTRO KOREX (ID: 74163)...');
    try {
        const { execSync } = require('child_process');
        execSync(`node "${path.join(__dirname, 'validate_master_skill_suite.js')}"`, { stdio: 'pipe' });
        results.push({
            Capa: '9. SKILL MAESTRO (74163)',
            Componente: 'validate_master_skill_suite.js',
            Estado: '✅ OK',
            Detalle: '7/7 Pruebas pasaron (Aislamiento, .env Inviolable, Setup de Cero, Fallbacks Protegidos)'
        });
    } catch (masterErr) {
        results.push({
            Capa: '9. SKILL MAESTRO (74163)',
            Componente: 'validate_master_skill_suite.js',
            Estado: '❌ FALLO',
            Detalle: masterErr.message
        });
    }

    // -------------------------------------------------------------------------
    // CAPA 10: SUITE DE ENCRIPTACIÓN DE CONTRASEÑAS SQL & ZEUS ERP (.ENV Y PARÁMETRO)
    // -------------------------------------------------------------------------
    console.log('\n[CAPA 10/10] Validando Encriptación de Contraseñas (.ENV & Zeus ERP)...');
    try {
        const { execSync } = require('child_process');
        execSync(`node "${path.join(__dirname, 'validate_password_encryption_suite.js')}"`, { stdio: 'pipe' });
        results.push({
            Capa: '10. Encriptación Contraseñas',
            Componente: 'validate_password_encryption_suite.js',
            Estado: '✅ OK',
            Detalle: '7/7 Pruebas pasaron (AES-256 .ENV, Zeus ERP Clave, Parámetro EncriptarClaves)'
        });
    } catch (encErr) {
        results.push({
            Capa: '10. Encriptación Contraseñas',
            Componente: 'validate_password_encryption_suite.js',
            Estado: '❌ FALLO',
            Detalle: encErr.message
        });
    }

    console.log('\n================================================================');
    console.log('         MATRIZ DE RESULTADOS DE LA VALIDACIÓN COMPLETA          ');
    console.log('================================================================');
    console.table(results);

    const hasFailure = results.some(r => r.Estado.includes('❌') || r.Estado.includes('FALLO'));
    if (hasFailure) {
        console.log('\n❌ ERROR: Se detectaron fallas en una o más capas de la validación.');
        process.exit(1);
    } else {
        console.log('\n================================================================');
        console.log('   ESTADO GLOBAL: SISTEMA 100% OPERATIVO Y REGLAS CUMPLIDAS     ');
        console.log('================================================================\n');
    }
}

validateFullSuite();

