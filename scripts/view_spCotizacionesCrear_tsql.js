const fs = require('fs');

function viewSP() {
    const filePath = 'f:/Proyectos/AgenciasNew/SQL/SqlServer/03_Functions_And_SPs.sql';
    let content = fs.readFileSync(filePath, 'utf16le');
    if (!content.includes('spCotizacionesCrear')) {
        content = fs.readFileSync(filePath, 'utf8');
    }
    const idx = content.indexOf('spCotizacionesCrear');
    if (idx !== -1) {
        console.log(content.substring(idx - 50, idx + 3000));
    } else {
        console.log("NOT FOUND");
    }
}

viewSP();
