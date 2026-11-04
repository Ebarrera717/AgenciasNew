const fs = require('fs');

function updateSpFile(filePath) {
    if (!fs.existsSync(filePath)) {
        console.log('File does not exist:', filePath);
        return;
    }
    let content = fs.readFileSync(filePath, 'utf8');

    // 1. Reemplazar resolución de id_tiqueteador
    const oldTqPattern = /id_tiqueteador\s*=\s*ISNULL\(\(SELECT TOP 1 id FROM dbo\.Tiqueteadores WHERE id = TRY_CAST\(C\.Cotizacion\.value\('cd_tiqueteador\[1\]','VARCHAR\(6\)'\) AS INT\)\),\s*ISNULL\(\(SELECT TOP 1 id FROM dbo\.Tiqueteadores WHERE bl_inactivo = 0 ORDER BY id ASC\),\s*1\)\),/;
    const newTqCode = `id_tiqueteador = ISNULL(
				(SELECT TOP 1 id FROM dbo.Tiqueteadores WHERE RTRIM(LTRIM(cd_codigo)) = RTRIM(LTRIM(C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(25)')))),
				ISNULL(
					(SELECT TOP 1 id FROM dbo.Tiqueteadores WHERE RTRIM(LTRIM(cd_alterno)) = RTRIM(LTRIM(C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(25)')))),
					ISNULL(
						(SELECT TOP 1 id FROM dbo.Tiqueteadores WHERE id = TRY_CAST(C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(25)') AS INT)),
						ISNULL(
							(SELECT TOP 1 id FROM dbo.Tiqueteadores WHERE ds_nombre LIKE '%' + RTRIM(LTRIM(C.Cotizacion.value('cd_tiqueteador[1]','VARCHAR(50)'))) + '%'),
							ISNULL((SELECT TOP 1 id FROM dbo.Tiqueteadores WHERE bl_inactivo = 0 ORDER BY id ASC), 1)
						)
					)
				)
			),`;

    if (oldTqPattern.test(content)) {
        content = content.replace(oldTqPattern, newTqCode);
        console.log(`[${filePath}] id_tiqueteador updated.`);
    }

    // Asegurar punto y coma después de FROM @xmlData.nodes(...) AS C(Cotizacion)
    content = content.replace(/FROM\s+@xmlData\.nodes\('Cotizaciones\/Cotizacion'\)\s+AS\s+C\(Cotizacion\)(?!;)/g, "FROM @xmlData.nodes('Cotizaciones/Cotizacion') AS C(Cotizacion);");

    // 2. Reemplazar bloque de resolución de cliente
    const clientBlockRegex = /-- Resolver (?:IDCLIENTE|datos del Cliente)[\s\S]*?UPDATE @Cotizacion[\s\S]*?WHERE ds_cliente_ciudad IS NULL OR RTRIM\(LTRIM\(ds_cliente_ciudad\)\) = '';/m;
    const fallbackClientRegex = /-- Resolver IDCLIENTE[\s\S]*?END;/m;

    const newClientBlock = `		-- Resolver datos del Cliente (Código, Tercero, Ciudad, Dirección, Teléfono, Email, etc.) desde dbo.CLIENTES para @Cotizacion
		IF OBJECT_ID('dbo.CLIENTES', 'U') IS NOT NULL
		BEGIN
			UPDATE COT
			SET 
				COT.cd_cliente_codigo = COALESCE(NULLIF(RTRIM(LTRIM(CL.IDCLIENTE)), ''), COT.cd_cliente_codigo),
				COT.cd_tercero_codigo = COALESCE(NULLIF(RTRIM(LTRIM(CL.IDTERCERO)), ''), COT.cd_cliente_codigo),
				COT.ds_cliente_nombre = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_nombre)), ''), NULLIF(RTRIM(LTRIM(CL.RAZONCIAL)), ''), COT.ds_cliente_nombre),
				COT.ds_tercero_nombre = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_tercero_nombre)), ''), NULLIF(RTRIM(LTRIM(CL.RAZONCIAL)), ''), COT.ds_tercero_nombre),
				COT.ds_cliente_ciudad = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_ciudad)), ''), NULLIF(RTRIM(LTRIM(CL.CIUDAD)), ''), 'BOGOTA'),
				COT.ds_cliente_dir = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_dir)), ''), NULLIF(RTRIM(LTRIM(CL.DIRECCION)), ''), COT.ds_cliente_dir),
				COT.ds_cliente_tel = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_tel)), ''), NULLIF(RTRIM(LTRIM(CL.TELEFONO)), ''), COT.ds_cliente_tel),
				COT.ds_cliente_email = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_email)), ''), NULLIF(RTRIM(LTRIM(CL.EMAIL)), ''), COT.ds_cliente_email)
			FROM @Cotizacion COT
			JOIN dbo.CLIENTES CL ON 
				RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(COT.cd_cliente_codigo)) 
				OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(COT.cd_cliente_codigo))
				OR RTRIM(LTRIM(CL.IDCLIENTE)) = RTRIM(LTRIM(COT.cd_tercero_codigo))
				OR RTRIM(LTRIM(CL.IDTERCERO)) = RTRIM(LTRIM(COT.cd_tercero_codigo));
		END;

		-- Si la ciudad aún está vacía, buscar en dbo.TERCEROS si existe
		IF OBJECT_ID('dbo.TERCEROS', 'U') IS NOT NULL
		BEGIN
			UPDATE COT
			SET COT.ds_cliente_ciudad = COALESCE(NULLIF(RTRIM(LTRIM(COT.ds_cliente_ciudad)), ''), NULLIF(RTRIM(LTRIM(T.CIUDAD)), ''))
			FROM @Cotizacion COT
			JOIN dbo.TERCEROS T ON RTRIM(LTRIM(T.IDTERCERO)) = RTRIM(LTRIM(COT.cd_tercero_codigo)) OR RTRIM(LTRIM(T.IDTERCERO)) = RTRIM(LTRIM(COT.cd_cliente_codigo))
			WHERE COT.ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(COT.ds_cliente_ciudad)) = '';
		END;

		-- Salvaguarda: garantizar que ds_cliente_ciudad nunca quede vacía en @Cotizacion para que no detenga el proceso
		UPDATE @Cotizacion
		SET ds_cliente_ciudad = 'BOGOTA'
		WHERE ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(ds_cliente_ciudad)) = '';`;

    if (clientBlockRegex.test(content)) {
        content = content.replace(clientBlockRegex, newClientBlock);
        console.log(`[${filePath}] Client block updated with COT.`);
    } else if (fallbackClientRegex.test(content)) {
        content = content.replace(fallbackClientRegex, newClientBlock);
        console.log(`[${filePath}] Fallback client block updated with COT.`);
    }

    // 3. Normalizar consecutivo, ciudad, teléfono y tiqueteador en dbo.Cotizacion si la cotización ya existe
    const existingBlockRegex = /-- Normalizar consecutivo[\s\S]*?EX\.id = C\.id_Cotizacion[\s\S]*?;/m;
    const newExistingUpdate = `-- Normalizar consecutivo, ciudad, teléfono y tiqueteador en dbo.Cotizacion si estaban vacíos o descalzados
			UPDATE EX
			SET 
				EX.cd_consecutivo = C.cd_consecutivo,
				EX.ds_cliente_ciudad = CASE WHEN EX.ds_cliente_ciudad IS NULL OR RTRIM(LTRIM(EX.ds_cliente_ciudad)) = '' THEN C.ds_cliente_ciudad ELSE EX.ds_cliente_ciudad END,
				EX.ds_cliente_tel = CASE WHEN EX.ds_cliente_tel IS NULL OR RTRIM(LTRIM(EX.ds_cliente_tel)) = '' THEN C.ds_cliente_tel ELSE EX.ds_cliente_tel END,
				EX.id_tiqueteador = CASE WHEN C.id_tiqueteador IS NOT NULL AND C.id_tiqueteador > 0 AND (EX.id_tiqueteador IS NULL OR EX.id_tiqueteador = 49) THEN C.id_tiqueteador ELSE EX.id_tiqueteador END
			FROM dbo.Cotizacion EX
			JOIN @Cotizacion C ON 
				EX.id = C.id_Cotizacion;`;

    if (existingBlockRegex.test(content)) {
        content = content.replace(existingBlockRegex, newExistingUpdate);
        console.log(`[${filePath}] Existing update block updated.`);
    }

    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`[${filePath}] Saved.`);
}

updateSpFile('F:/Proyectos/AgenciasNew/SQL/ZeusERP/spCotizacionesCrear.sql');
updateSpFile('F:/Proyectos/AgenciasNew/SQL/SP/spCotizacionesCrear.sql');
