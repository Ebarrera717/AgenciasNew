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
    # Si detectamos que node_modules contiene dependencias de desarrollo (bloqueo por npm install anterior), lo limpiamos de forma instantanea en segundo plano
    if (Test-Path "$ReleaseDir\node_modules\typescript") {
        Write-Host "Detectadas dependencias de desarrollo redundantes en Release. Limpiando en segundo plano..." -ForegroundColor Yellow
        $RandomId = Get-Random
        $OldNodeModules = "$RootDir\node_modules_old_$RandomId"
        if (Test-Path "$ReleaseDir\node_modules") {
            # Mover a la raiz del proyecto (fuera de RELEASE_AGENCIAS) es instantaneo y evita que Inno Setup lo intente compilar
            Move-Item "$ReleaseDir\node_modules" -Destination $OldNodeModules -Force -ErrorAction SilentlyContinue
            # Borrar la carpeta movida en segundo plano de forma invisible para no retrasar al usuario
            Start-Process cmd.exe -ArgumentList "/c rmdir /s /q `"$OldNodeModules`"" -WindowStyle Hidden -ErrorAction SilentlyContinue
        }
    }
    Get-ChildItem $ReleaseDir -Exclude "node_modules" | Remove-Item -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
}
if (!(Test-Path "$ReleaseDir\SQL")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL" | Out-Null }

# 3. Copiar sistema Node.js (Standalone)
Write-Host "`n[3/5] Ensamblando Motor (Archivos Binarios)..." -ForegroundColor Yellow
Copy-Item ".\.next\standalone\*" -Destination $ReleaseDir -Recurse -Force
Copy-Item ".\public" -Destination "$ReleaseDir\public" -Recurse -Force
if (-not (Test-Path "$ReleaseDir\.next\static")) { New-Item -ItemType Directory -Path "$ReleaseDir\.next\static" -Force | Out-Null }
Copy-Item ".\.next\static\*" -Destination "$ReleaseDir\.next\static" -Recurse -Force

# Sobrescribir package.json en Release con una version minimal para evitar que npm instale dependencias de desarrollo redundantes, pero conservando dependencias criticas del instalador (node-windows y pg)
$MinimalPackageJson = '{"name":"korex-standalone","version":"1.0.0","private":true,"dependencies":{"node-windows":"^1.0.0-beta.8","pg":"^8.22.0"}}'
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
Copy-Item ".\deploy\db_installer.js" -Destination $ReleaseDir -Force
Copy-Item ".\deploy\web.config" -Destination $ReleaseDir -Force

# Herramientas Administrativas (Limpieza de Movimientos y Activar Licencia)
if (Test-Path ".\Limpiar_Movimientos_Produccion.bat") { Copy-Item ".\Limpiar_Movimientos_Produccion.bat" -Destination $ReleaseDir -Force }
if (Test-Path ".\ActivarLicencia.bat") { Copy-Item ".\ActivarLicencia.bat" -Destination $ReleaseDir -Force }

# Garantizar que GenerarLicencia NO viaje al cliente final por seguridad
if (Test-Path "$ReleaseDir\GenerarLicencia.bat") { Remove-Item "$ReleaseDir\GenerarLicencia.bat" -Force }

if (!(Test-Path "$ReleaseDir\deploy")) { New-Item -ItemType Directory -Path "$ReleaseDir\deploy" | Out-Null }
if (Test-Path ".\deploy\clean_movement_tables.js") { Copy-Item ".\deploy\clean_movement_tables.js" -Destination "$ReleaseDir\deploy" -Force }

if (!(Test-Path "$ReleaseDir\scripts")) { New-Item -ItemType Directory -Path "$ReleaseDir\scripts" | Out-Null }
if (Test-Path ".\scripts\activar-licencia.js") { Copy-Item ".\scripts\activar-licencia.js" -Destination "$ReleaseDir\scripts" -Force }

# Garantizar que generar-licencia.js NO viaje al cliente final
if (Test-Path "$ReleaseDir\scripts\generar-licencia.js") { Remove-Item "$ReleaseDir\scripts\generar-licencia.js" -Force }

# SQL Master
if (!(Test-Path "$ReleaseDir\SQL\SP")) { New-Item -ItemType Directory -Path "$ReleaseDir\SQL\SP" -Force | Out-Null }
if (Test-Path ".\SQL\SP\spLimpiarMovimientosProduccion.sql") { Copy-Item ".\SQL\SP\spLimpiarMovimientosProduccion.sql" -Destination "$ReleaseDir\SQL\SP" -Force }
if (Test-Path ".\SQL\Actualizador\Actualizador.SQL") { Copy-Item ".\SQL\Actualizador\Actualizador.SQL" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\Actualizador\ActualizadorSERVER.SQL") { Copy-Item ".\SQL\Actualizador\ActualizadorSERVER.SQL" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\Data\Inicial.sql") { Copy-Item ".\SQL\Data\Inicial.sql" -Destination "$ReleaseDir\SQL" -Force }
if (Test-Path ".\SQL\schema_reference.json") { Copy-Item ".\SQL\schema_reference.json" -Destination "$ReleaseDir\SQL" -Force }

# 5. Instalar libreria temporal de PG en Release para el auto-setup (solo si no existen)
if (-not (Test-Path "$ReleaseDir\node_modules\pg") -or -not (Test-Path "$ReleaseDir\node_modules\node-windows")) {
    Write-Host "`n[5/5] Inyectando conectores de Postgres al Release..." -ForegroundColor Yellow
    Set-Location $ReleaseDir
    npm.cmd install pg node-windows --no-save --silent | Out-Null
    Set-Location $RootDir
} else {
    Write-Host "`n[5/5] Los conectores de Postgres ya estan presentes en Release. Omitiendo instalacion..." -ForegroundColor Green
}

# Limpieza de archivos temporales/ocultos en node_modules que puedan interferir con Inno Setup
if (Test-Path "$ReleaseDir\node_modules") {
    Write-Host "Limpiando archivos temporales en node_modules..." -ForegroundColor Yellow
    Get-ChildItem "$ReleaseDir\node_modules" -Filter ".next-*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem "$ReleaseDir\node_modules" -Filter ".cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n==========================================================================" -ForegroundColor Green
Write-Host " PAQUETE CONSTRUIDO CON EXITO!" -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "Puedes encontrar todo el sistema listo para entregar comprimido en la ruta: "
Write-Host "--> $ReleaseDir" -ForegroundColor Cyan
Write-Host "`nInstruccion: Entrega esa carpeta comprimida en ZIP al encargado de IT del cliente."
Write-Host "El encargado solo debera hacer Clic Derecho y Ejecutar 'Setup_Korex.ps1'."
