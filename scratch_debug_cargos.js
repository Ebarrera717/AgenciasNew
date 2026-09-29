const mssql = require('mssql');

(async () => {
    const configZeus = { server: 'ZEUSAGENCIAS10', user: 'zeusagencias', password: 'zzeusagencias', database: 'ZeusAgencias_23', options: { encrypt: false, trustServerCertificate: true }, port: 1433 };
    const poolZeus = await mssql.connect(configZeus);
    const res = await poolZeus.request().query(`
        SELECT p.name, t.name AS type_name, p.max_length, p.is_output
        FROM sys.parameters p
        JOIN sys.types t ON p.user_type_id = t.user_type_id
        WHERE p.object_id = OBJECT_ID('dbo.spza_Factura_Crear')
        ORDER BY p.parameter_id
    `);
    console.log('Parameters of spza_Factura_Crear:', res.recordset);
    await poolZeus.close();
})().catch(e => console.error(e));
