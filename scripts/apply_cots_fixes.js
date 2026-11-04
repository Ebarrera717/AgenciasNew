const mssql = require('mssql');

(async () => {
    const targetDbs = ['ZeusAgencias_Colaereo', 'ZeusAgencias_Colaereo_Prueba'];
    const cots = [
        '00000001', '00000006', '00000009', '00000017', '00000012',
        '00000010', '00000008', '00000018', '00000005', '00000003',
        '00000004', '00000007', '00000020', '00000021', '00000023',
        '00000024', '00000025', '00000026', '00000019'
    ];
    const inList = cots.map(c => `'${c}'`).join(',');

    for (const db of targetDbs) {
        console.log(`\n======================================================`);
        console.log(`Actualizando cotizaciones en [${db}]...`);
        console.log(`======================================================`);

        let pool = null;
        try {
            pool = await mssql.connect({
                server: '192.168.15.8', user: 'zeusagencias', password: 'zzeusagencias', database: db,
                options: { encrypt: false, trustServerCertificate: true },
                requestTimeout: 60000
            });

            // 1. Ejecutar UPDATE enriqueciendo Ciudad, Teléfono, Dirección y Tiqueteador (148 - IV)
            const updateSql = `
                UPDATE C
                SET 
                    C.ds_cliente_ciudad = COALESCE(
                        NULLIF(RTRIM(LTRIM(CL.CIUDAD)), ''),
                        NULLIF(RTRIM(LTRIM(C.ds_cliente_ciudad)), ''),
                        'BOGOTA'
                    ),
                    C.ds_cliente_tel = COALESCE(
                        NULLIF(RTRIM(LTRIM(CL.TELEFONO)), ''),
                        C.ds_cliente_tel
                    ),
                    C.ds_cliente_dir = COALESCE(
                        NULLIF(RTRIM(LTRIM(CL.DIRECCION)), ''),
                        C.ds_cliente_dir
                    ),
                    C.id_tiqueteador = 148
                FROM dbo.Cotizacion C
                LEFT JOIN dbo.CLIENTES CL ON CL.IDCLIENTE = C.cd_cliente_codigo OR CL.IDTERCERO = C.cd_cliente_codigo
                WHERE C.cd_consecutivo IN (${inList});
            `;

            const updateRes = await pool.request().query(updateSql);
            console.log(`Filas afectadas en dbo.Cotizacion: ${updateRes.rowsAffected[0]}`);

            // 2. Verificar resultado
            const checkSql = `
                SELECT 
                    C.id, 
                    C.cd_consecutivo, 
                    C.cd_cliente_codigo, 
                    SUBSTRING(C.ds_cliente_nombre, 1, 28) as cliente_nombre, 
                    C.ds_cliente_ciudad, 
                    C.ds_cliente_tel, 
                    C.id_tiqueteador,
                    T.cd_codigo as tq_code,
                    T.ds_nombre as tq_name
                FROM dbo.Cotizacion C
                LEFT JOIN dbo.Tiqueteadores T ON T.id = C.id_tiqueteador
                WHERE C.cd_consecutivo IN (${inList})
                ORDER BY TRY_CAST(C.cd_consecutivo AS INT);
            `;

            const checkRes = await pool.request().query(checkSql);
            console.table(checkRes.recordset);

            await pool.close();
        } catch (e) {
            console.error(`Error en [${db}]:`, e.message);
            if (pool) await pool.close().catch(() => {});
        }
    }
})();
