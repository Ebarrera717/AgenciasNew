const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function runStep(name, command) {
    console.log(`\n============================================================`);
    console.log(`  [PASO DE COMPILACIÓN] ${name}`);
    console.log(`============================================================`);
    try {
        const out = execSync(command, { cwd: path.join(__dirname, '..'), stdio: 'inherit' });
        console.log(`✅ COMPLETO: ${name}`);
    } catch (err) {
        console.error(`❌ ERROR en ${name}:`, err.message);
        process.exit(1);
    }
}

const iscc = `"C:\\Program Files (x86)\\Inno Setup 6\\ISCC.exe"`;

// 1. Sincronización y Validaciones Pre-Build
runStep('Prueba previa de Conexión SQL Server', 'node scripts/test_sqlserver_connection.js');
runStep('Sincronización de Actualizador SQL Server', 'node deploy/sync_sqlserver_updater.js');
runStep('Validación de Maestros SQL Server', 'node scripts/validate_sqlserver.js');
runStep('KorexValidator Pre-Build SQL Server', 'node scripts/korex_validator.js --engine=sqlserver --phase=pre-build');

// 2. Compilación del Instalador y Actualizador SQL Server
runStep('Compilando Actualizador SQL Server (Korex_SQLServer_Update_Setup.exe)', `${iscc} deploy/Korex_SQLServer_Update.iss`);
runStep('Compilando Instalador SQL Server (Korex_SQLServer_Setup.exe)', `${iscc} deploy/Korex_SQLServer.iss`);
runStep('Empaquetando ZIP Actualización Directa SQL Server', `powershell -ExecutionPolicy Bypass -Command "Compress-Archive -Path RELEASE_KOREX\\* -DestinationPath Instalador/Korex_SQLServer_Update_Directo.zip -Force"`);

// 3. Compilación del Instalador y Actualizador PostgreSQL
runStep('Compilando Actualizador PostgreSQL (Korex_Update_Setup.exe)', `${iscc} deploy/Korex_Update.iss`);
runStep('Compilando Instalador PostgreSQL (Korex_Setup.exe)', `${iscc} deploy/Korex.iss`);
runStep('Empaquetando ZIP Actualización Directa PostgreSQL', `powershell -ExecutionPolicy Bypass -Command "Compress-Archive -Path RELEASE_KOREX\\* -DestinationPath Instalador/Korex_Update_Directo.zip -Force"`);

console.log(`\n==========================================================================`);
console.log(`  🎉 TODOS LOS INSTALADORES Y ACTUALIZADORES COMPILADOS CON ÉXITO!`);
console.log(`==========================================================================`);
console.log(`  Ubicación: F:\\Proyectos\\AgenciasNew\\Instalador\\`);
console.log(`    - Korex_SQLServer_Update_Setup.exe`);
console.log(`    - Korex_SQLServer_Setup.exe`);
console.log(`    - Korex_SQLServer_Update_Directo.zip`);
console.log(`    - Korex_Update_Setup.exe`);
console.log(`    - Korex_Setup.exe`);
console.log(`    - Korex_Update_Directo.zip`);
