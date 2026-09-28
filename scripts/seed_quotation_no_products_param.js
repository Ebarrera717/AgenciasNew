const fs = require('fs');
const path = require('path');

// 1. Alter_New_Columns.sql
const alterPath = path.join(__dirname, '..', 'SQL', 'Table', 'Alter_New_Columns.sql');
if (fs.existsSync(alterPath)) {
    let content = fs.readFileSync(alterPath, 'utf8');
    const paramSeed = `INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'Permitir Cotizaciones sin Productos (Solo Cliente/Origen)', '1') ON CONFLICT (code) DO NOTHING;`;
    if (!content.includes('PERMITIR_COTIZACION_SIN_PRODUCTOS')) {
        content += '\n' + paramSeed + '\n';
        fs.writeFileSync(alterPath, content, 'utf8');
        console.log('Added PERMITIR_COTIZACION_SIN_PRODUCTOS to Alter_New_Columns.sql');
    }
}

// 2. Inicial.sql
const inicialPath = path.join(__dirname, '..', 'SQL', 'Inicial.sql');
if (fs.existsSync(inicialPath)) {
    let content = fs.readFileSync(inicialPath, 'utf8');
    const paramSeed = `INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'Permitir Cotizaciones sin Productos (Solo Cliente/Origen)', '1') ON CONFLICT (code) DO NOTHING;`;
    if (!content.includes('PERMITIR_COTIZACION_SIN_PRODUCTOS')) {
        content += '\n' + paramSeed + '\n';
        fs.writeFileSync(inicialPath, content, 'utf8');
        console.log('Added PERMITIR_COTIZACION_SIN_PRODUCTOS to Inicial.sql');
    }
}

// 3. SQL Server 02_Seeds.sql
const sqlserverSeedPath = path.join(__dirname, '..', 'SQL', 'SqlServer', '02_Seeds.sql');
if (fs.existsSync(sqlserverSeedPath)) {
    let content = fs.readFileSync(sqlserverSeedPath, 'utf8');
    const paramSeed = `IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = 'PERMITIR_COTIZACION_SIN_PRODUCTOS')
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES ('PERMITIR_COTIZACION_SIN_PRODUCTOS', 'Permitir Cotizaciones sin Productos (Solo Cliente/Origen)', '1');`;
    if (!content.includes('PERMITIR_COTIZACION_SIN_PRODUCTOS')) {
        content += '\n' + paramSeed + '\n';
        fs.writeFileSync(sqlserverSeedPath, content, 'utf8');
        console.log('Added PERMITIR_COTIZACION_SIN_PRODUCTOS to 02_Seeds.sql');
    }
}
