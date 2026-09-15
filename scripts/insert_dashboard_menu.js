const mssql = require('mssql');

const config = {
    user: process.env.SQLSERVER_USER || 'zeusagencias',
    password: process.env.SQLSERVER_PASSWORD || 'zzeusagencias',
    server: process.env.SQLSERVER_HOST || 'ZEUSAGENCIAS10',
    database: process.env.SQLSERVER_DB || 'Korex_Pruebas',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

async function main() {
    try {
        console.log('Conectando a SQL Server:', config.server, config.database);
        const pool = await mssql.connect(config);
        const check = await pool.request().query("SELECT * FROM dbo.[Menu] WHERE [code] IN ('DASHBOARD', 'dashboard')");
        if (check.recordset.length === 0) {
            await pool.request().query("INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES ('DASHBOARD', 'Dashboard', '/dashboard', 1)");
            console.log('¡DASHBOARD insertado exitosamente en SQL Server dbo.Menu!');
        } else {
            console.log('DASHBOARD ya existe en dbo.Menu:', check.recordset);
            await pool.request().query("UPDATE dbo.[Menu] SET [activo] = 1, [action] = '/dashboard' WHERE [code] IN ('DASHBOARD', 'dashboard')");
            console.log('¡DASHBOARD actualizado a activo = 1!');
        }
        await pool.close();
    } catch (e) {
        console.error('Error:', e);
    }
}

main();
