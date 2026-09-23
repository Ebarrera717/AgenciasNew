const fs = require('fs');
const path = require('path');

try {
    const root = path.join(__dirname, '..', 'SQL');
    const actFile = path.join(root, 'Actualizador', 'Actualizador.SQL');

    console.log("Generando Actualizador.SQL...");

    let content = '-- ==========================================================\n';
    content += '-- ARCHIVO ACTUALIZADOR COMPLETO: TABLAS + FUNCIONES + SPS\n';
    content += '-- Generado Automáticamente\n';
    content += '-- ==========================================================\n\n';

    // 1. TABLEINI (Mantenemos exactamente el archivo manual del usuario)
    content += '-- >>> 1. CREACIÓN DE TABLAS E ÍNDICES (TABLEINI) <<<\n\n';
    const tableIni = fs.readFileSync(path.join(root, 'Table', 'TABLEINI.sql'), 'utf8');
    content += tableIni + '\n\n';

    // 1.1 ALTER COLUMNS
    content += '-- >>> 1.1. ADICIÓN DE COLUMNAS A TABLAS EXISTENTES (ALTER COLUMNS) <<<\n\n';
    const alterFile = path.join(root, 'Table', 'Alter_New_Columns.sql');
    if (fs.existsSync(alterFile)) {
        content += fs.readFileSync(alterFile, 'utf8') + '\n\n';
    }

    // 2. Functions
    content += '-- >>> 2. FUNCIONES <<<\n\n';
    const fnDir = path.join(root, 'Function');
    if (fs.existsSync(fnDir)) {
        const fns = fs.readdirSync(fnDir).filter(f => f.endsWith('.sql'));
        for (const f of fns) {
            content += `-- Archivo: ${f}\n`;
            content += fs.readFileSync(path.join(fnDir, f), 'utf8') + '\n\n';
        }
    }

    // 3. Stored Procedures
    content += '-- >>> 3. PROCEDIMIENTOS ALMACENADOS (SP) <<<\n\n';
    
    let contentServer = '-- ==========================================================\n';
    contentServer += '-- ARCHIVO ACTUALIZADOR COMPLETO: SPS (SQL SERVER)\n';
    contentServer += '-- Generado Automáticamente\n';
    contentServer += '-- ==========================================================\n\n';
    contentServer += '-- >>> PROCEDIMIENTOS ALMACENADOS (SQL SERVER) <<<\n\n';

    const spDirs = [path.join(root, 'SP'), path.join(root, 'Procedure')];
    for (const spDir of spDirs) {
        if (fs.existsSync(spDir)) {
            const sps = fs.readdirSync(spDir).filter(f => f.endsWith('.sql'));
            for (const sp of sps) {
                const fileContent = fs.readFileSync(path.join(spDir, sp), 'utf8');
                if (fileContent.toLowerCase().includes('plpgsql')) {
                    content += `-- Archivo: ${sp}\n`;
                    content += fileContent + '\n\n';
                }
            }
        }
    }

    fs.writeFileSync(actFile, content, 'utf8');
    console.log('Actualizador.SQL (PostgreSQL) regenerado con éxito (' + content.length + ' bytes).');

    const releaseSqlDir = path.join(__dirname, '..', 'RELEASE_KOREX', 'SQL');
    if (!fs.existsSync(releaseSqlDir)) {
        fs.mkdirSync(releaseSqlDir, { recursive: true });
    }
    fs.writeFileSync(path.join(releaseSqlDir, 'Actualizador.SQL'), content, 'utf8');
    console.log('Copia de Actualizador.SQL guardada en RELEASE_KOREX/SQL/Actualizador.SQL');
} catch (e) {
    console.error("Error construyendo Actualizador:", e);
}
