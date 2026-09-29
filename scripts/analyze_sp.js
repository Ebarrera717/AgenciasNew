const fs = require('fs');

const lines = fs.readFileSync('SQL/ZeusERP/spFacturacionesCrear.sql', 'utf8').split('\n');
lines.forEach((l, idx) => {
    if (l.toLowerCase().includes('spza_')) {
        console.log(`Line ${idx + 1}: ${l.trim()}`);
    }
});
