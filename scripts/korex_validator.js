const fs = require('fs');
const path = require('path');
const { Client: PgClient } = require('pg');
const mssql = require('mssql');

// ============================================================================
// KOREX VALIDATOR - AUTOMATED INTEGRITY, REGRESSION & MULTI-DB VALIDATOR
// Archivo: scripts/korex_validator.js
// ============================================================================

const args = process.argv.slice(2);
let targetEngine = 'all'; // 'postgres' | 'sqlserver' | 'all'
let phase = 'pre-build'; // 'pre-dev' | 'pre-build' | 'post-build' | 'post-install'

for (const arg of args) {
    if (arg.startsWith('--engine=')) {
        targetEngine = arg.split('=')[1].toLowerCase();
    } else if (arg.startsWith('--phase=')) {
        phase = arg.split('=')[1].toLowerCase();
    }
}

const REPORT = {
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    phase: phase,
    targetEngine: targetEngine,
    items: [],
    errors: [],
    warnings: [],
    status: 'GO'
};

function addResult(category, component, status, detail, isCritical = false) {
    REPORT.items.push({ category, component, status, detail });
    if (status === '❌ ERROR' || status === '❌ BLOQUEANTE') {
        REPORT.errors.push({ category, component, detail, isCritical });
        if (isCritical) {
            REPORT.status = 'NO GO';
        }
    } else if (status === '⚠️ ADVERTENCIA') {
        REPORT.warnings.push({ category, component, detail });
    }
}

async function runValidator() {
    console.log('\n===============================================================================');
    console.log('                 KOREX VALIDATOR - VALIDACIÓN AUTOMÁTICA                       ');
    console.log(`   Fase: ${phase.toUpperCase()} | Motor Objetivo: ${targetEngine.toUpperCase()} `);
    console.log(`   Fecha: ${new Date().toLocaleString()}                                       `);
    console.log('===============================================================================\n');

    const rootDir = path.join(__dirname, '..');
    const sqlDir = path.join(rootDir, 'SQL');
    const sqlServerDir = path.join(sqlDir, 'SqlServer');
    const actualizadorServerPath = path.join(sqlDir, 'Actualizador', 'ActualizadorSERVER.sql');
    const alterNewColumnsPath = path.join(sqlDir, 'Table', 'Alter_New_Columns.sql');
    const actualizadorPgPath = path.join(sqlDir, 'Actualizador', 'Actualizador.sql');
    const prismaSchemaPath = path.join(rootDir, 'prisma', 'schema.prisma');

    // -------------------------------------------------------------------------
    // 1. VALIDACIÓN DE ESTRUCTURA Y COLUMNAS OBLIGATORIAS (EJ. isExcelImport)
    // -------------------------------------------------------------------------
    console.log('[PASO 1/5] Verificando consistencia de columnas y esquemas multibase...');
    
    // Lista de columnas críticas que DEBEN existir en DDL y Actualizadores
    const criticalColumns = [
        { table: 'Invoices', column: 'isExcelImport', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Invoices', column: 'zeusInvoiceNumber', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Invoices', column: 'dueDate', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Invoices', column: 'fuente', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Invoices', column: 'serie', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Invoices', column: 'consecutivo', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'InvoicesProduct', column: 'providerInvoice', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'InvoicesProduct', column: 'providerDueDate', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'Quotation', column: 'isExcelImport', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'QuotationProduct', column: 'providerInvoice', requiredIn: ['sqlserver', 'postgres'] },
        { table: 'QuotationProduct', column: 'providerDueDate', requiredIn: ['sqlserver', 'postgres'] }
    ];

    // Lista de SPs críticos que DEBEN existir en los compiladores y actualizadores (BARRERA 1)
    const criticalProcedures = [
        { name: 'spExportInvoices', requiredIn: ['sqlserver', 'postgres'] },
        { name: 'spExportQuotation', requiredIn: ['postgres'] },
        { name: 'spInvoicesListar', requiredIn: ['sqlserver'] },
        { name: 'fnInvoicesListar', requiredIn: ['postgres'] },
        { name: 'spInvoicesObtener', requiredIn: ['sqlserver'] },
        { name: 'spInvoicesCrear', requiredIn: ['sqlserver'] },
        { name: 'spInvoicesActualizar', requiredIn: ['sqlserver'] },
        { name: 'spInvoicesEliminar', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionListar', requiredIn: ['sqlserver'] },
        { name: 'fnCotizacionListar', requiredIn: ['postgres'] },
        { name: 'spCotizacionHistorial', requiredIn: ['sqlserver'] },
        { name: 'fnCotizacionHistorial', requiredIn: ['postgres'] },
        { name: 'spCotizacionObtener', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionCrear', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionActualizar', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionDuplicar', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionEliminar', requiredIn: ['sqlserver'] },
        { name: 'spPreCotizacionListar', requiredIn: ['sqlserver'] },
        { name: 'spPreCotizacionCrear', requiredIn: ['sqlserver'] },
        { name: 'spPreCotizacionConvertir', requiredIn: ['sqlserver'] },
        { name: 'spPreCotizacionEliminar', requiredIn: ['sqlserver'] },
        { name: 'spCotizacionesCrear', requiredIn: ['sqlserver'] },
        { name: 'spFacturacionesCrear', requiredIn: ['sqlserver'] }
    ];

    // Verificar en SQL Server DDL y ActualizadorSERVER
    if (targetEngine === 'all' || targetEngine === 'sqlserver') {
        const path01Tables = path.join(sqlServerDir, '01_Tables.sql');
        const content01Tables = fs.existsSync(path01Tables) ? fs.readFileSync(path01Tables, 'utf8') : '';
        const contentActServer = fs.existsSync(actualizadorServerPath) ? fs.readFileSync(actualizadorServerPath, 'utf8') : '';

        for (const col of criticalColumns) {
            if (col.requiredIn.includes('sqlserver')) {
                const in01 = content01Tables.toLowerCase().includes(col.column.toLowerCase());
                const inAct = contentActServer.toLowerCase().includes(col.column.toLowerCase());

                if (in01 && inAct) {
                    addResult('Estructura SQL Server', `${col.table}.${col.column}`, '✅ OK', 'Presente en 01_Tables.sql y ActualizadorSERVER.sql');
                } else {
                    addResult('Estructura SQL Server', `${col.table}.${col.column}`, '❌ BLOQUEANTE', 
                        `Falta en: ${!in01 ? '01_Tables.sql ' : ''}${!inAct ? 'ActualizadorSERVER.sql' : ''}`, true);
                }
            }
        }

        for (const sp of criticalProcedures) {
            if (sp.requiredIn.includes('sqlserver')) {
                const inAct = contentActServer.toLowerCase().includes(sp.name.toLowerCase());
                if (inAct) {
                    addResult('Procedimientos SQL Server', sp.name, '✅ OK', 'Compilado en ActualizadorSERVER.sql');
                } else {
                    addResult('Procedimientos SQL Server', sp.name, '❌ BLOQUEANTE', 'Falta en ActualizadorSERVER.sql', true);
                }
            }
        }
    }

    // Verificar en PostgreSQL DDL y Actualizador PG
    if (targetEngine === 'all' || targetEngine === 'postgres') {
        const contentAlterPg = fs.existsSync(alterNewColumnsPath) ? fs.readFileSync(alterNewColumnsPath, 'utf8') : '';
        const contentActPg = fs.existsSync(actualizadorPgPath) ? fs.readFileSync(actualizadorPgPath, 'utf8') : '';

        for (const col of criticalColumns) {
            if (col.requiredIn.includes('postgres')) {
                const inAlter = contentAlterPg.toLowerCase().includes(col.column.toLowerCase());
                const inAct = contentActPg.toLowerCase().includes(col.column.toLowerCase());

                if (inAlter && inAct) {
                    addResult('Estructura PostgreSQL', `${col.table}.${col.column}`, '✅ OK', 'Presente en Alter_New_Columns.sql y Actualizador.sql');
                } else {
                    addResult('Estructura PostgreSQL', `${col.table}.${col.column}`, '❌ BLOQUEANTE', 
                        `Falta en: ${!inAlter ? 'Alter_New_Columns.sql ' : ''}${!inAct ? 'Actualizador.sql' : ''}`, true);
                }
            }
        }

        for (const sp of criticalProcedures) {
            if (sp.requiredIn.includes('postgres')) {
                const inAct = contentActPg.toLowerCase().includes(sp.name.toLowerCase());
                if (inAct) {
                    addResult('Procedimientos PostgreSQL', sp.name, '✅ OK', 'Compilado en Actualizador.sql');
                } else {
                    addResult('Procedimientos PostgreSQL', sp.name, '❌ BLOQUEANTE', 'Falta en Actualizador.sql', true);
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 2. VALIDACIÓN DE CÓDIGO FUENTE VS MODELOS / ORM
    // -------------------------------------------------------------------------
    console.log('[PASO 2/5] Validando sincronía entre Código Fuente y Prisma Schema...');
    if (fs.existsSync(prismaSchemaPath)) {
        const prismaContent = fs.readFileSync(prismaSchemaPath, 'utf8');
        for (const col of criticalColumns) {
            const hasInPrisma = prismaContent.toLowerCase().includes(col.column.toLowerCase());
            if (hasInPrisma) {
                addResult('Prisma ORM', `${col.table}.${col.column}`, '✅ OK', 'Mapeado en schema.prisma');
            } else {
                addResult('Prisma ORM', `${col.table}.${col.column}`, '⚠️ ADVERTENCIA', 'No explícito en schema.prisma');
            }
        }
    }

    // -------------------------------------------------------------------------
    // 3. SEGURIDAD DEL .ENV Y AISLAMIENTO DE EMPAQUETADO
    // -------------------------------------------------------------------------
    console.log('[PASO 3/5] Auditando reglas de seguridad del .env e instaladores...');
    const releaseKorexDir = path.join(rootDir, 'RELEASE_KOREX');
    if (fs.existsSync(releaseKorexDir)) {
        const envInRelease = fs.existsSync(path.join(releaseKorexDir, '.env'));
        if (envInRelease) {
            addResult('Seguridad .env', 'RELEASE_KOREX/.env', '❌ BLOQUEANTE', 'Archivo .env productivo encontrado en paquete de salida. Prohibido empaquetar .env.', true);
        } else {
            addResult('Seguridad .env', 'RELEASE_KOREX/.env', '✅ OK', 'Empaquetado limpio sin archivos .env');
        }
    } else {
        addResult('Seguridad .env', 'RELEASE_KOREX', 'ℹ️ INFO', 'Carpeta RELEASE_KOREX no generada aún (se validará post-empaque)');
    }

    // -------------------------------------------------------------------------
    // 4. CONECTIVIDAD Y VERIFICACIÓN EN VIVO (MODO READ-ONLY)
    // -------------------------------------------------------------------------
    console.log('[PASO 4/5] Verificando base de datos activa en modo solo lectura...');

    // Probar PostgreSQL si aplica
    if (targetEngine === 'all' || targetEngine === 'postgres') {
        const pgUrl = process.env.DATABASE_URL || 'postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public';
        const pg = new PgClient({ connectionString: pgUrl });
        try {
            await pg.connect();
            const resCols = await pg.query(`
                SELECT column_name FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'isExcelImport';
            `);
            if (resCols.rows.length > 0) {
                addResult('BD PostgreSQL Activa', 'Invoices.isExcelImport', '✅ OK', 'Columna presente en PostgreSQL activo');
            } else {
                addResult('BD PostgreSQL Activa', 'Invoices.isExcelImport', '⚠️ ADVERTENCIA', 'Columna no detectada en BD local activa (requiere sincronizar)');
            }
            await pg.end();
        } catch (e) {
            addResult('BD PostgreSQL Activa', 'Conexión Local', '⚠️ ADVERTENCIA', `No disponible para lectura directa: ${e.message}`);
        }
    }

    // Probar SQL Server si aplica
    if (targetEngine === 'all' || targetEngine === 'sqlserver') {
        const sqlConfig = {
            user: process.env.SQLSERVER_USER || 'sa',
            password: process.env.SQLSERVER_PASSWORD || '123456',
            server: process.env.SQLSERVER_SERVER || 'localhost',
            database: process.env.SQLSERVER_DATABASE || 'Korex_pruebas',
            options: {
                encrypt: false,
                trustServerCertificate: true
            },
            connectionTimeout: 5000,
            requestTimeout: 5000
        };

        try {
            const pool = await mssql.connect(sqlConfig);
            const resCol = await pool.request().query(`
                SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoices') AND name = 'isExcelImport';
            `);
            if (resCol.recordset && resCol.recordset.length > 0) {
                addResult('BD SQL Server Activa', 'dbo.Invoices.isExcelImport', '✅ OK', 'Columna presente en SQL Server activo');
            } else {
                addResult('BD SQL Server Activa', 'dbo.Invoices.isExcelImport', '⚠️ ADVERTENCIA', 'Columna no existe en la BD SQL Server activa. Ejecute la migración.');
            }
            await pool.close();
        } catch (e) {
            addResult('BD SQL Server Activa', 'Conexión SQL Server', 'ℹ️ INFO', `Ambiente SQL Server no alcanzable localmente (${e.message}). Validación de scripts superada.`);
        }
    }

    // -------------------------------------------------------------------------
    // 5. INFORME FINAL Y DICTAMEN GO / NO GO
    // -------------------------------------------------------------------------
    console.log('\n[PASO 5/5] Generando Informe Final de Validación...');
    console.log('-------------------------------------------------------------------------------');
    console.log(String('CATEGORÍA').padEnd(25) + String('COMPONENTE').padEnd(30) + String('ESTADO').padEnd(15) + 'DETALLE');
    console.log('-------------------------------------------------------------------------------');
    
    for (const item of REPORT.items) {
        console.log(
            String(item.category).padEnd(25) + 
            String(item.component).padEnd(30) + 
            String(item.status).padEnd(15) + 
            item.detail
        );
    }
    console.log('-------------------------------------------------------------------------------');

    console.log(`\nResumen: ${REPORT.errors.length} Errores Críticos | ${REPORT.warnings.length} Advertencias`);
    console.log(`DICTAMEN FINAL: [ ${REPORT.status} ]\n`);

    // Guardar log del informe
    const reportsDir = path.join(rootDir, 'deploy', 'reports');
    if (!fs.existsSync(reportsDir)) {
        fs.mkdirSync(reportsDir, { recursive: true });
    }
    const reportPath = path.join(reportsDir, `korex_validator_${targetEngine}_${Date.now()}.json`);
    fs.writeFileSync(reportPath, JSON.stringify(REPORT, null, 2), 'utf8');

    if (REPORT.status === 'NO GO') {
        console.error('❌ ERROR CRÍTICO: KorexValidator detectó inconsistencias bloqueantes.');
        console.error('   El proceso de despliegue, empaquetado o instalación ha sido DETENIDO.');
        process.exit(1);
    } else {
        console.log('✅ VALIDACIÓN EXITOSA: KorexValidator aprobó la integridad del sistema (GO).');
        process.exit(0);
    }
}

runValidator().catch(err => {
    console.error('❌ Error no controlado en KorexValidator:', err);
    process.exit(1);
});
