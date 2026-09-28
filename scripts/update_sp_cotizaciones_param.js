const fs = require('fs');
const path = require('path');

// 1. Update SQL/Procedure/spCotizacionCrear.sql
const spCrearPath = path.join(__dirname, '..', 'SQL', 'Procedure', 'spCotizacionCrear.sql');
if (fs.existsSync(spCrearPath)) {
    let content = fs.readFileSync(spCrearPath, 'utf8');

    // Add v_permitir_sin_productos declaration
    if (!content.includes('v_permitir_sin_productos TEXT;')) {
        content = content.replace('v_acting_user_id INT := NULL;', 'v_acting_user_id INT := NULL;\n    v_permitir_sin_productos TEXT := \'1\';');
    }

    // Replace items validation block
    const oldValBlock = `    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
        WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
    ) THEN
        p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
        RETURN;
    END IF;`;

    const newValBlock = `    -- Parámetro del Sistema para permitir o no cotizaciones sin productos
    SELECT COALESCE(value, '1') INTO v_permitir_sin_productos
    FROM public."SystemParameter"
    WHERE code IN ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'PermitirCotizacionSinProductos')
    LIMIT 1;

    IF v_permitir_sin_productos IS NULL THEN
        v_permitir_sin_productos := '1';
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(COALESCE(p_data->'items', '[]'::jsonb)) = 0 THEN
        IF v_permitir_sin_productos NOT IN ('1', 'true', 'TRUE', 't', 'SI', 'si') THEN
            p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
            RETURN;
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
            WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
        ) THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
            RETURN;
        END IF;
    END IF;`;

    content = content.replace(oldValBlock, newValBlock);
    content = content.replace(oldValBlock.replace(/\r\n/g, '\n'), newValBlock);

    // Ensure client mandatory variables are only checked when items exist
    content = content.replace(
        `        IF jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN`,
        `        IF p_data->'items' IS NOT NULL AND jsonb_typeof(p_data->'items') = 'array' AND jsonb_array_length(p_data->'items') > 0 AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN`
    );

    // Ensure items loops use COALESCE
    content = content.replace(
        `FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items')`,
        `FOR v_item IN SELECT * FROM jsonb_to_recordset(COALESCE(p_data->'items', '[]'::jsonb))`
    );

    fs.writeFileSync(spCrearPath, content, 'utf8');
    console.log('spCotizacionCrear.sql updated');
}

// 2. Update SQL/Procedure/spCotizacionActualizar.sql
const spActualizarPath = path.join(__dirname, '..', 'SQL', 'Procedure', 'spCotizacionActualizar.sql');
if (fs.existsSync(spActualizarPath)) {
    let content = fs.readFileSync(spActualizarPath, 'utf8');

    // Add v_permitir_sin_productos declaration
    if (!content.includes('v_permitir_sin_productos TEXT;')) {
        content = content.replace('v_acting_user_id INT := NULL;', 'v_acting_user_id INT := NULL;\n    v_permitir_sin_productos TEXT := \'1\';');
    }

    const oldValBlock = `    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
        WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
    ) THEN
        p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
        RETURN;
    END IF;`;

    const newValBlock = `    -- Parámetro del Sistema para permitir o no cotizaciones sin productos
    SELECT COALESCE(value, '1') INTO v_permitir_sin_productos
    FROM public."SystemParameter"
    WHERE code IN ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'PermitirCotizacionSinProductos')
    LIMIT 1;

    IF v_permitir_sin_productos IS NULL THEN
        v_permitir_sin_productos := '1';
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(COALESCE(p_data->'items', '[]'::jsonb)) = 0 THEN
        IF v_permitir_sin_productos NOT IN ('1', 'true', 'TRUE', 't', 'SI', 'si') THEN
            p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
            RETURN;
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
            WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
        ) THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
            RETURN;
        END IF;
    END IF;`;

    content = content.replace(oldValBlock, newValBlock);
    content = content.replace(oldValBlock.replace(/\r\n/g, '\n'), newValBlock);

    content = content.replace(
        `        IF jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN`,
        `        IF p_data->'items' IS NOT NULL AND jsonb_typeof(p_data->'items') = 'array' AND jsonb_array_length(p_data->'items') > 0 AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN`
    );

    content = content.replace(
        `FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items')`,
        `FOR v_item IN SELECT * FROM jsonb_to_recordset(COALESCE(p_data->'items', '[]'::jsonb))`
    );

    fs.writeFileSync(spActualizarPath, content, 'utf8');
    console.log('spCotizacionActualizar.sql updated');
}
