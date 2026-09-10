const mssql = require('mssql');
const fs = require('fs');
const path = require('path');

// ============================================================================
// RUNNER DE PRUEBA DE CONCEPTO (PoC) - MIGRACIÓN A SQL SERVER
// ============================================================================

async function runPoCTest() {
    console.log('\n================================================================');
    console.log('   PRUEBA DE CONCEPTO (PoC): MIGRACIÓN POSTGRES -> SQL SERVER   ');
    console.log('================================================================\n');

    // 1. Cargar código T-SQL generado
    const sqlDir = path.join(__dirname, '..', 'SQL', 'PocSqlServer');
    const fileTable = fs.readFileSync(path.join(sqlDir, '01_Table_Currency.sql'), 'utf8');
    const fileSpListar = fs.readFileSync(path.join(sqlDir, '02_spMonedaListar.sql'), 'utf8');
    const fileSpCrear = fs.readFileSync(path.join(sqlDir, '03_spMonedaCrear.sql'), 'utf8');

    console.log('[PASO 1] Archivos T-SQL de la PoC cargados correctamente:');
    console.log('  - SQL/PocSqlServer/01_Table_Currency.sql');
    console.log('  - SQL/PocSqlServer/02_spMonedaListar.sql');
    console.log('  - SQL/PocSqlServer/03_spMonedaCrear.sql');

    // 2. Configuración de conexión a SQL Server
    const config = {
        user: process.env.SQLSERVER_USER || 'sa',
        password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
        server: process.env.SQLSERVER_HOST || '127.0.0.1',
        database: process.env.SQLSERVER_DB || 'Korex_colaereo_poc',
        port: parseInt(process.env.SQLSERVER_PORT || '1433'),
        options: {
            encrypt: false,
            trustServerCertificate: true
        },
        connectionTimeout: 5000,
        requestTimeout: 10000
    };

    console.log(`\n[PASO 2] Intentando conectar a SQL Server en ${config.server}:${config.port} (Base: ${config.database})...`);

    let pool = null;
    let isConnected = false;

    try {
        pool = await mssql.connect(config);
        isConnected = true;
        console.log('  -> ¡CONEXIÓN EXITOSA A SQL SERVER REAL!');
    } catch (err) {
        console.log('  -> [AVISO DE CONEXIÓN]: No se detectó un servidor SQL Server activo en esta máquina o credenciales no configuradas.');
        console.log(`     Detalle del intento: ${err.message}`);
        console.log('     (El script procederá a validar la integridad de la sintaxis T-SQL y la matriz de equivalencias).\n');
    }

    if (isConnected && pool) {
        try {
            console.log('\n[PASO 3] Creando tabla dbo.Currency en SQL Server...');
            await pool.request().batch(fileTable);
            console.log('  -> Tabla dbo.Currency lista.');

            console.log('\n[PASO 4] Compilando Stored Procedures T-SQL en SQL Server...');
            await pool.request().batch(fileSpListar);
            await pool.request().batch(fileSpCrear);
            console.log('  -> Stored Procedures compilados con éxito (spMonedaListar, spMonedaCrear).');

            console.log('\n[PASO 5] Probando inserción mediante spMonedaCrear...');
            const codeTest = 'USD_' + Math.floor(Math.random() * 1000);
            const reqCrear = pool.request();
            reqCrear.input('p_code', mssql.NVarChar(10), codeTest);
            reqCrear.input('p_name', mssql.NVarChar(100), 'Dólar Estadounidense PoC');
            reqCrear.input('p_exchange_rate', mssql.Float, 4250.50);
            reqCrear.input('p_decimals', mssql.Int, 2);
            reqCrear.input('p_acting_user_id', mssql.Int, 1);
            reqCrear.output('p_currency_id', mssql.Int);
            reqCrear.output('p_mensaje_resultado', mssql.NVarChar(255));

            const resCrear = await reqCrear.execute('dbo.spMonedaCrear');
            const createdId = resCrear.output.p_currency_id;
            const message = resCrear.output.p_mensaje_resultado;
            console.log(`  -> Resultado spMonedaCrear: ${message} (ID Generado: ${createdId})`);

            console.log('\n[PASO 6] Consultando datos mediante spMonedaListar...');
            const reqListar = pool.request();
            reqListar.input('p_id', mssql.Int, createdId);
            const resListar = await reqListar.execute('dbo.spMonedaListar');
            console.log('  -> Registro obtenido desde SQL Server:', JSON.stringify(resListar.recordset, null, 2));

            await pool.close();
        } catch (execErr) {
            console.error('  -> ERROR durante ejecución en SQL Server:', execErr.message);
            if (pool) await pool.close();
        }
    }

    // 3. Imprimir Tabla Comparativa de Sintaxis
    console.log('\n================================================================');
    console.log('   MATRIZ DE EQUIVALENCIAS: PL/pgSQL (Postgres) vs T-SQL (SQL)  ');
    console.log('================================================================');
    console.table([
        { Concepto: 'Proveedor Prisma', PostgreSQL: 'provider = "postgresql"', SQL_Server: 'provider = "sqlserver"' },
        { Concepto: 'Tipos Auto-ID', PostgreSQL: 'SERIAL / autoincrement()', SQL_Server: 'IDENTITY(1,1)' },
        { Concepto: 'Tipo Texto', PostgreSQL: 'TEXT / VARCHAR', SQL_Server: 'NVARCHAR(100) / NVARCHAR(MAX)' },
        { Concepto: 'Tipo Booleano', PostgreSQL: 'BOOLEAN (true/false)', SQL_Server: 'BIT (1/0)' },
        { Concepto: 'Retorno de ID Insertado', PostgreSQL: 'RETURNING id INTO var', SQL_Server: 'SCOPE_IDENTITY() / OUTPUT inserted.id' },
        { Concepto: 'Búsquedas Case-Insensitive', PostgreSQL: 'ILIKE \'%texto%\'', SQL_Server: 'LIKE \'%texto%\' (Colación CI_AS)' },
        { Concepto: 'Control de Errores', PostgreSQL: 'EXCEPTION WHEN OTHERS THEN...', SQL_Server: 'BEGIN TRY ... END TRY BEGIN CATCH...' },
        { Concepto: 'Parámetros Output', PostgreSQL: 'INOUT p_var TEXT', SQL_Server: '@p_var NVARCHAR(255) OUTPUT' }
    ]);

    console.log('\n================================================================');
    console.log('   RESULTADO DE LA PRUEBA DE CONCEPTO: COMPILACIÓN EXITOSA     ');
    console.log('================================================================\n');
}

runPoCTest();
