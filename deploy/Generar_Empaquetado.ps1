param(
    [switch]$SkipBuild
)

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " CONSTRUYENDO PAQUETE DE INSTALACION PARA CLIENTE FINAL " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$ReleaseDir = "$RootDir\RELEASE_KOREX"

# 1. Compilar modo Produccion
Set-Location $RootDir
if ($SkipBuild) {
    Write-Host "`n[1/5] OMITIENDO COMPILACION NEXT.JS (Modo Rapido - Solo base de datos/scripts)..." -ForegroundColor Yellow
} else {
    Write-Host "`n[1/5] Compilando el proyecto Next.js en Modo Standalone..." -ForegroundColor Yellow
    
    # Liberar servicios y procesos remanentes para evitar bloqueo EBUSY de archivos .log en .next/standalone
    Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
    Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$RootDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (Test-Path "$RootDir\.next\standalone\daemon") {
        Remove-Item "$RootDir\.next\standalone\daemon" -Recurse -Force -ErrorAction SilentlyContinue
    }

    npm.cmd run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR EN COMPILACION" -ForegroundColor Red
        exit 1
    }
}

# 2. Recrear directorio de Release (preservando node_modules para optimizar velocidad)
Write-Host "`n[2/5] Creando directorio de distribucion seguro..." -ForegroundColor Yellow
if (Test-Path $ReleaseDir) {
    # Limpiar cualquier residuo de directorios temporales node_modules_old_ de ejecuciones anteriores
    Get-ChildItem $ReleaseDir -Filter "node_modules_old_*" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    # Limpiar node_modules anidados si existieran por versiones previas
    if (Test-Path "$ReleaseDir\node_modules\node_modules") {
        Remove-Item "$ReleaseDir\node_modules\node_modules" -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Si detectamos que node_modules contiene dependencias pesadas de desarrollo (como eslint), lo limpiamos en segundo plano
    if (Test-Path "$ReleaseDir\node_modules\eslint") {
        Write-Host "Detectadas dependencias de desarrollo redundantes en Release. Limpiando en segundo plano..." -ForegroundColor Yellow
        $RandomId = Get-Random
        $OldNodeModules = "$RootDir\node_modules_old_$RandomId"
        if (Test-Path "$ReleaseDir\node_modules") {
            Move-Item "$ReleaseDir\node_modules" -Destination $OldNodeModules -Force -ErrorAction SilentlyContinue
            Start-Process cmd.exe -ArgumentList "/c rmdir /s /q `"$OldNodeModules`"" -WindowStyle Hidden -ErrorAction SilentlyContinue
        }
    }
    Get-ChildItem $ReleaseDir -Exclude "node_modules", ".next", "public" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
}
if (!(Test-Path "$ReleaseDir\SQL")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL" | Out-Null }

# Sobrescribir package.json en Release con una version minimal para los conectores de instalacion (node-windows, pg, mssql, dotenv)
$MinimalPackageJson = '{"name":"korex-standalone","version":"1.0.0","private":true,"dependencies":{"node-windows":"^1.0.0-beta.8","pg":"^8.22.0","mssql":"^11.0.1","dotenv":"^16.4.5"}}'
Set-Content -Path "$ReleaseDir\package.json" -Value $MinimalPackageJson -Encoding UTF8

# IMPORTANTE: Instalar conectores ANTES de copiar .next\standalone para evitar que 'npm install' haga prune y elimine 'next', 'react' o 'react-dom'
if (-not (Test-Path "$ReleaseDir\node_modules\pg") -or -not (Test-Path "$ReleaseDir\node_modules\node-windows") -or -not (Test-Path "$ReleaseDir\node_modules\mssql") -or -not (Test-Path "$ReleaseDir\node_modules\dotenv")) {
    Write-Host "Inyectando conectores base (pg, mssql, node-windows, dotenv) en Release..." -ForegroundColor Yellow
    Set-Location $ReleaseDir
    npm.cmd install pg mssql node-windows dotenv --no-save --no-audit --no-fund --silent | Out-Null
    Set-Location $RootDir
}

# Copiar .next\standalone DESPUÉS de npm install usando robocopy multihilo (/MT:16) e incremental (/XO /MIR)
Write-Host "Sincronizando runtime Next.js Standalone (.next/standalone -> RELEASE_KOREX) [Multihilo /MT:16]..." -ForegroundColor Yellow
& robocopy ".\.next\standalone" "$ReleaseDir" /E /XO /XD ".next" /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
if (-not (Test-Path "$ReleaseDir\.next")) { New-Item -ItemType Directory -Path "$ReleaseDir\.next" -Force | Out-Null }
& robocopy ".\.next\standalone\.next" "$ReleaseDir\.next" /MIR /XD "static" /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
& robocopy ".\public" "$ReleaseDir\public" /MIR /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
if (-not (Test-Path "$ReleaseDir\.next\static")) { New-Item -ItemType Directory -Path "$ReleaseDir\.next\static" -Force | Out-Null }
& robocopy ".\.next\static" "$ReleaseDir\.next\static" /MIR /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null

# REGLA INVIOLABLE SKILL MAESTRO 74163: EL .ENV DE PRUEBAS NUNCA PUEDE VIAJAR AL CLIENTE FINAL
if (Test-Path "$ReleaseDir\.env") { Remove-Item "$ReleaseDir\.env" -Force -ErrorAction SilentlyContinue }
node "$PSScriptRoot\optimize_release_dir.js" "$ReleaseDir"
Write-Host "[SEGURIDAD] Verificado: 0 archivos .env en RELEASE_KOREX (Configuracion de desarrollo aislada)." -ForegroundColor Green

# Restaurar package.json minimal limpio en Release
Set-Content -Path "$ReleaseDir\package.json" -Value $MinimalPackageJson -Encoding UTF8

# Borrar carpeta 'daemon' si se copio, para evitar archivos XML hardcodeados y rotos en el cliente
if (Test-Path "$ReleaseDir\daemon") { Remove-Item "$ReleaseDir\daemon" -Recurse -Force }

# Inyectar cargador de variables de entorno (.env) en server.js
$ServerJsPath = "$ReleaseDir\server.js"
if (Test-Path $ServerJsPath) {
    Write-Host "Inyectando cargador de variables de entorno (.env) en server.js..." -ForegroundColor Yellow
    $EnvLoader = @'
const fs = require('fs');
const path = require('path');
try {
  require('dotenv').config();
  console.log('Loaded environment variables via dotenv');
} catch (e) {
  try {
    const envPath = path.join(__dirname, '.env');
    if (fs.existsSync(envPath)) {
      fs.readFileSync(envPath, 'utf8').split(/\r?\n/).forEach(line => {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#')) {
          const eqIdx = trimmed.indexOf('=');
          if (eqIdx > 0) {
            const key = trimmed.slice(0, eqIdx).trim();
            let val = trimmed.slice(eqIdx + 1).trim();
            if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
              val = val.slice(1, -1);
            }
            process.env[key] = val;
          }
        }
      });
      console.log('Loaded environment variables manually from .env');
    }
  } catch (err) {
    console.error('Failed to load .env manually:', err);
  }
}
'@
    $OriginalContent = Get-Content -Path $ServerJsPath -Raw
    # Reemplazar la declaracion original de path para evitar duplicados en el scope global
    if ($OriginalContent -match "const path = require\('path'\)") {
        $NewContent = $OriginalContent -replace "const path = require\('path'\)", $EnvLoader
    } else {
        $NewContent = $EnvLoader + "`n" + $OriginalContent
    }
    Set-Content -Path $ServerJsPath -Value $NewContent -Encoding UTF8
}

# 4. Copiar Herramientas y SQL
Write-Host "`n[4/5] Ensamblando Assets y Bases de Datos..." -ForegroundColor Yellow
Copy-Item ".\deploy\install-service.js" -Destination $ReleaseDir -Force
Copy-Item ".\deploy\Setup_Korex.ps1" -Destination $ReleaseDir -Force
Copy-Item ".\deploy\Update_Korex.ps1" -Destination $ReleaseDir -Force
Copy-Item ".\deploy\Update_Korex_SQLServer.ps1" -Destination $ReleaseDir -Force
if (Test-Path ".\deploy\Update_Korex_SQLServer_Web.ps1") { Copy-Item ".\deploy\Update_Korex_SQLServer_Web.ps1" -Destination $ReleaseDir -Force }
if (Test-Path ".\deploy\Update_Korex_SQLServer_BD.ps1") { Copy-Item ".\deploy\Update_Korex_SQLServer_BD.ps1" -Destination $ReleaseDir -Force }
Copy-Item ".\deploy\db_installer.js" -Destination $ReleaseDir -Force
Copy-Item ".\deploy\web.config" -Destination $ReleaseDir -Force

# Herramientas Administrativas (Limpieza de Movimientos, Activar Licencia y Actualización Directa)
if (Test-Path ".\Limpiar_Movimientos_Produccion.bat") { Copy-Item ".\Limpiar_Movimientos_Produccion.bat" -Destination $ReleaseDir -Force }
if (Test-Path ".\ActivarLicencia.bat") { Copy-Item ".\ActivarLicencia.bat" -Destination $ReleaseDir -Force }
if (Test-Path ".\Actualizar_Korex_SQLServer.bat") { Copy-Item ".\Actualizar_Korex_SQLServer.bat" -Destination $ReleaseDir -Force }
if (Test-Path ".\Actualizar_Korex_SQLServer_BD.bat") { Copy-Item ".\Actualizar_Korex_SQLServer_BD.bat" -Destination $ReleaseDir -Force }

# Garantizar que GenerarLicencia NO viaje al cliente final por seguridad
if (Test-Path "$ReleaseDir\GenerarLicencia.bat") { Remove-Item "$ReleaseDir\GenerarLicencia.bat" -Force }

if (!(Test-Path "$ReleaseDir\deploy")) { New-Item -ItemType Directory -Path "$ReleaseDir\deploy" | Out-Null }
if (Test-Path ".\deploy\clean_movement_tables.js") { Copy-Item ".\deploy\clean_movement_tables.js" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\Korex_Diagnostics_Engine.ps1") { Copy-Item ".\deploy\Korex_Diagnostics_Engine.ps1" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\Korex_Performance_Engine.ps1") { Copy-Item ".\deploy\Korex_Performance_Engine.ps1" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\task_scheduler_manager.ps1") { Copy-Item ".\deploy\task_scheduler_manager.ps1" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\update_db_sqlserver.js") { Copy-Item ".\deploy\update_db_sqlserver.js" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\Update_Korex_SQLServer.ps1") { Copy-Item ".\deploy\Update_Korex_SQLServer.ps1" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\Update_Korex_SQLServer_Web.ps1") { Copy-Item ".\deploy\Update_Korex_SQLServer_Web.ps1" -Destination "$ReleaseDir\deploy" -Force }
if (Test-Path ".\deploy\Update_Korex_SQLServer_BD.ps1") { Copy-Item ".\deploy\Update_Korex_SQLServer_BD.ps1" -Destination "$ReleaseDir\deploy" -Force }

if (!(Test-Path "$ReleaseDir\scripts")) { New-Item -ItemType Directory -Path "$ReleaseDir\scripts" | Out-Null }
if (Test-Path ".\scripts\activar-licencia.js") { Copy-Item ".\scripts\activar-licencia.js" -Destination "$ReleaseDir\scripts" -Force }
if (Test-Path ".\scripts\korex_diagnostic_engine.js") { Copy-Item ".\scripts\korex_diagnostic_engine.js" -Destination "$ReleaseDir\scripts" -Force }
if (Test-Path ".\scripts\korex_performance_engine.js") { Copy-Item ".\scripts\korex_performance_engine.js" -Destination "$ReleaseDir\scripts" -Force }
if (Test-Path ".\scripts\korex_updater_guardian.js") { Copy-Item ".\scripts\korex_updater_guardian.js" -Destination "$ReleaseDir\scripts" -Force }
if (Test-Path ".\scripts\generate_release_manifest.js") { Copy-Item ".\scripts\generate_release_manifest.js" -Destination "$ReleaseDir\scripts" -Force }

# Garantizar que generar-licencia.js NO viaje al cliente final
if (Test-Path "$ReleaseDir\scripts\generar-licencia.js") { Remove-Item "$ReleaseDir\scripts\generar-licencia.js" -Force }

# SQL Master
if (!(Test-Path "$ReleaseDir\SQL\SP")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL\SP" -Force | Out-Null }
if (!(Test-Path "$ReleaseDir\SQL\Actualizador")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL\Actualizador" -Force | Out-Null }
if (!(Test-Path "$ReleaseDir\SQL\SqlServer")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL\SqlServer" -Force | Out-Null }
if (Test-Path ".\SQL\SP\spLimpiarMovimientosProduccion.sql") { Copy-Item ".\SQL\SP\spLimpiarMovimientosProduccion.sql" -Destination "$ReleaseDir\SQL\SP" -Force }
if (Test-Path ".\SQL\Actualizador\Actualizador.SQL") { Copy-Item ".\SQL\Actualizador\Actualizador.SQL" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\Actualizador\ActualizadorSERVER.SQL") {
    Copy-Item ".\SQL\Actualizador\ActualizadorSERVER.SQL" -Destination "$ReleaseDir\SQL" -Force
    Copy-Item ".\SQL\Actualizador\ActualizadorSERVER.SQL" -Destination "$ReleaseDir\SQL\Actualizador\ActualizadorSERVER.sql" -Force
}
if (Test-Path ".\SQL\SqlServer\01_Tables.sql") { Copy-Item ".\SQL\SqlServer\01_Tables.sql" -Destination "$ReleaseDir\SQL\SqlServer\01_Tables.sql" -Force }
if (Test-Path ".\SQL\SqlServer\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql") { Copy-Item ".\SQL\SqlServer\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\manifest-sqlserver.json") { Copy-Item ".\SQL\manifest-sqlserver.json" -Destination "$ReleaseDir\SQL\manifest-sqlserver.json" -Force }
if (Test-Path ".\SQL\manifest-postgresql.json") { Copy-Item ".\SQL\manifest-postgresql.json" -Destination "$ReleaseDir\SQL\manifest-postgresql.json" -Force }
if (Test-Path ".\SQL\Data\Inicial.sql") { Copy-Item ".\SQL\Data\Inicial.sql" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\schema_reference.json") { Copy-Item ".\SQL\schema_reference.json" -Destination "$ReleaseDir\SQL" -Force }

# 5. Validar integridad de dependencias criticas en RELEASE_KOREX\node_modules
Write-Host "`n[5/5] Verificando integridad de modulos en RELEASE_KOREX\node_modules..." -ForegroundColor Yellow
$RequiredModules = @("next", "react", "react-dom", "pg", "mssql", "node-windows")
foreach ($mod in $RequiredModules) {
    if (-not (Test-Path "$ReleaseDir\node_modules\$mod\package.json")) {
        if (Test-Path ".\.next\standalone\node_modules\$mod") {
            & robocopy ".\.next\standalone\node_modules" "$ReleaseDir\node_modules" /E /XO /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
        } elseif (Test-Path ".\node_modules\$mod") {
            & robocopy ".\node_modules\$mod" "$ReleaseDir\node_modules\$mod" /E /XO /MT:16 /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
        }
    }
    if (-not (Test-Path "$ReleaseDir\node_modules\$mod\package.json")) {
        Write-Host "[ERROR CRITICO] El modulo obligatorio '$mod' no se encuentra en RELEASE_KOREX\node_modules." -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] Verificados modulos obligatorios en RELEASE_KOREX\node_modules: $($RequiredModules -join ', ')" -ForegroundColor Green

Write-Host "`n==========================================================================" -ForegroundColor Green
Write-Host " PAQUETE CONSTRUIDO CON EXITO!" -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "Puedes encontrar todo el sistema listo para entregar comprimido en la ruta: "
Write-Host "--> $ReleaseDir" -ForegroundColor Cyan
Write-Host "`nInstruccion: Entrega esa carpeta comprimida en ZIP al encargado de IT del cliente."
Write-Host "El encargado solo debera hacer Clic Derecho y Ejecutar 'Setup_Korex.ps1'."
