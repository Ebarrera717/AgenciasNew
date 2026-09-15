const fs = require('fs');
const path = require('path');

function checkFile(filePath) {
    if (!fs.existsSync(filePath)) return;
    const content = fs.readFileSync(filePath, 'utf16le'); // or utf8
    console.log(`=== ${path.basename(filePath)} ===`);
    const matches = content.match(/CREATE\s+(PROCEDURE|PROC)\s+dbo\.\[?(\w+)\]?/gi);
    if (matches) {
        matches.forEach(m => console.log("  ", m));
    } else {
        // try utf8
        const contentUtf8 = fs.readFileSync(filePath, 'utf8');
        const matchesUtf8 = contentUtf8.match(/CREATE\s+(PROCEDURE|PROC)\s+dbo\.\[?(\w+)\]?/gi);
        if (matchesUtf8) {
            matchesUtf8.forEach(m => console.log("  ", m));
        } else {
            console.log("   No SPs found.");
        }
    }
}

checkFile('f:/Proyectos/AgenciasNew/SQL/SqlServer/03_Functions_And_SPs.sql');
checkFile('f:/Proyectos/AgenciasNew/SQL/Actualizador/ActualizadorSERVER.sql');
