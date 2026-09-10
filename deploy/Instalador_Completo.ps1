<#
.SYNOPSIS
    Script Automatizado y Completo para desplegar AgenciasNew en IIS.
    NOTA: Requiere ser ejecutado como Administrador.

    Este instalador:
    - Instala URL Rewrite module automáticamente.
    - Instala Application Request Routing (ARR) module automáticamente.
    - Configura el enrutamiento Proxy en IIS.
    - Compila la app Next.js en Standalone.
    - Construye un Servicio Oculto en Windows usando node-windows.
    - Crea y enciende el sitio completo en IIS (Puerto 3000).
#>

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " INICIANDO INSTALADOR TODO EN UNO: AgenciasNew en IIS " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Variables y Rutas
$RootDir = Split-Path -Parent $PSScriptRoot
$StandalonePath = "$RootDir\.next\standalone"
$SiteName = "AgenciasNew"
$SitePort = 3000

# 1. Descarga e Instalación Automática de Módulos (ARR y Rewrite)
Write-Host "`n1. Verificando e instalando complementos IIS necesarios en segundo plano..." -ForegroundColor Yellow

$RewriteUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_es-ES.msi"
$ArrUrl = "https://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi"

$RewriteMsi = "$env:TEMP\rewrite_amd64.msi"
$ArrMsi = "$env:TEMP\requestRouter_amd64.msi"

# Descargar módulos si no existen localmente
if (!(Test-Path $RewriteMsi)) { Invoke-WebRequest -Uri $RewriteUrl -OutFile $RewriteMsi }
if (!(Test-Path $ArrMsi)) { Invoke-WebRequest -Uri $ArrUrl -OutFile $ArrMsi }

# Ejecutar instalaciones silenciosas MSI
Write-Host "   -> Instalando IIS URL Rewrite 2.1..." -ForegroundColor Gray
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$RewriteMsi`" /qn /norestart" -Wait -NoNewWindow
Write-Host "   -> Instalando IIS Application Request Routing (ARR 3.0)..." -ForegroundColor Gray
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$ArrMsi`" /qn /norestart" -Wait -NoNewWindow

# Activar el Proxy Routing a nivel de Servidor IIS
Write-Host "   -> Habilitando Proxy en la configuración de IIS..." -ForegroundColor Gray
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"
& $AppCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost | Out-Null
Write-Host "   [+] Complementos de IIS configurados exitosamente." -ForegroundColor Green

# 1.5 Configuración de Red PostgreSQL y Firewall de Windows
Write-Host "`n1.5. Configurando red de PostgreSQL (0.0.0.0/0) y Firewall..." -ForegroundColor Yellow
$RemoteScript = "$PSScriptRoot\Configure-PostgresRemote.ps1"
if (Test-Path $RemoteScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$RemoteScript" -Elevated
}

# 2. Compilar Next.js en Modo Standalone
Write-Host "`n2. Compilando código de la plataforma Next.js... (Puede tardar 2+ minutos)" -ForegroundColor Yellow
Set-Location $RootDir
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: La compilación de NPM falló." -ForegroundColor Red
    exit 1
}

# 3. Empaquetar Entorno Óptimo
Write-Host "`n3. Armando servidor de producción ligero en $StandalonePath..." -ForegroundColor Yellow
if (Test-Path "$StandalonePath\public") { Remove-Item "$StandalonePath\public" -Recurse -Force }
if (Test-Path "$StandalonePath\.next\static") { Remove-Item "$StandalonePath\.next\static" -Recurse -Force }

Copy-Item ".\public" -Destination "$StandalonePath\public" -Recurse -Force
Copy-Item ".\.next\static" -Destination "$StandalonePath\.next\static" -Recurse -Force
if (Test-Path ".\.env") { Copy-Item ".\.env" -Destination "$StandalonePath\.env" -Force }
Copy-Item ".\deploy\web.config" -Destination "$StandalonePath\web.config" -Force

# 4. Crear o Reiniciar el Servicio Oculto de Windows (node-windows)
Write-Host "`n4. Instalando y arrancando servicio interno Windows (AgenciasNew_NextJS)..." -ForegroundColor Yellow
if (Get-Service -Name "AgenciasNew_NextJS" -ErrorAction SilentlyContinue) {
    Stop-Service -Name "AgenciasNew_NextJS" -Force -ErrorAction SilentlyContinue 
    Start-Sleep -Seconds 2
}
node .\deploy\install-service.js | Out-Null

# 5. Crear e Iniciar el Sitio IIS Oficial
Write-Host "`n5. Desplegando el sitio en Internet Information Services..." -ForegroundColor Yellow
Import-Module WebAdministration 

# Eliminarlo si ya existe para evitar errores
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Remove-IISSite -Name $SiteName -Confirm:$false
    Remove-Item "IIS:\Sites\$SiteName" -Recurse -Force -ErrorAction SilentlyContinue
}

# Crearlo
New-IISSite -Name $SiteName -PhysicalPath $StandalonePath -BindingInformation "*:${SitePort}:"

# Iniciar sitio nativo o forzar refresco
Start-IISSite -Name $SiteName -ErrorAction SilentlyContinue

Write-Host "==========================================================================" -ForegroundColor Green
Write-Host " ¡PLATAFORMA INSTALADA Y ACTIVA PARA EL CLIENTE FINAL EN SU SERVIDOR! " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "- Motor de fondo: Servicio Windows en ejecución transparente (Puerto 3000)."
Write-Host "- Puerta expuesta IIS ($SiteName): Accesible desde $env:COMPUTERNAME localmente y externamente."
Write-Host "- Haz Clic acá para ingresar desde esta máquina: http://localhost:$SitePort/" 
Write-Host "==========================================================================" -ForegroundColor Green
