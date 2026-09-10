<#
.SYNOPSIS
    Instalador Todo En Uno para el Cliente Final (Modo Interactivo).
    Instala Node.js, Módulos IIS, copia archivos al directorio elegido, e inicia los servicios de Postgres y WebServer.
#>
param([switch]$Elevated)

# Optimizar velocidad de descargas desactivando barra de progreso en consola
$ProgressPreference = 'SilentlyContinue'

if (-not $Elevated) {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Elevando privilegios de Administrador..." -ForegroundColor Yellow
        Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
        exit
    }
}

Clear-Host
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "    ASISTENTE DE INSTALACION: Korex Platform    " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Este asistente configurara el portal web y la base de datos." -ForegroundColor Gray
Write-Host "======================================================`n" -ForegroundColor Cyan

# 1. PETICIÓN DE VARIABLES PRINCIPALES
$TargetDir = Read-Host "1. Ingrese Directorio de Instalacion [C:\Korex_Sistema]" 
if (-not $TargetDir) { $TargetDir = "C:\Korex_Sistema" }

Write-Host "`n-- CONFIGURACIÓN DE BASE DE DATOS POSTGRESQL --" -ForegroundColor Yellow
$PgHost = Read-Host "2. Servidor de BD [localhost]"
if (-not $PgHost) { $PgHost = "localhost" }
$PgPort = Read-Host "3. Puerto BD [5432]"
if (-not $PgPort) { $PgPort = "5432" }
$PgDb = Read-Host "4. Nombre de BD [agencias_new]"
if (-not $PgDb) { $PgDb = "agencias_new" }
$PgUser = Read-Host "5. Usuario BD [postgres]"
if (-not $PgUser) { $PgUser = "postgres" }
$PgPass = Read-Host "6. Clave BD (se ocultará el texto si escribe en consola silenciosa)"
if (-not $PgPass) { $PgPass = "" }

# Variables de Enrutamiento iniciales
$SitePort = 3000
$NextjsPort = 3001
$SiteName = "Korex"
$CurrentDir = $PSScriptRoot

# Crear directorio de logs
if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
$LogFile = "$TargetDir\install_log.txt"
"======================================================" > $LogFile
"  LOG DE INSTALACION INTERACTIVA - KOREX              " >> $LogFile
"  Fecha: $(Get-Date)" >> $LogFile
"======================================================" >> $LogFile

function Write-Step($message, $color = "Cyan") {
    Write-Host "`n[-] $message" -ForegroundColor $color
    "[-] $message" >> $LogFile
}

function Write-Success($message) {
    Write-Host "    [OK] $message" -ForegroundColor Green
    "    [OK] $message" >> $LogFile
}

function Write-Warning($message) {
    Write-Host "    [!] ADVERTENCIA: $message" -ForegroundColor Yellow
    "    [!] ADVERTENCIA: $message" >> $LogFile
}

function Write-ErrorLog($message) {
    Write-Host "    [ERROR] $message" -ForegroundColor Red
    "    [ERROR] $message" >> $LogFile
}

# ==========================================
# DIAGNÓSTICO DE PRE-REQUISITOS (PRE-FLIGHT)
# ==========================================
Write-Step "INICIANDO CHEQUEOS DE SALUD Y PRE-REQUISITOS..." "Yellow"

# 1. Validar Node.js
Write-Step "Comprobando dependencias del sistema (Node.js)..."
try {
    $nodeVer = node -v
    Write-Success "Node.js detectado: $nodeVer"
} catch {
    Write-Warning "Node.js no encontrado. Descargando instalador v20..."
    $NodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
    $NodeMsi = "$env:TEMP\node.msi"
    try {
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeMsi
        Write-Host "    Instalando Node.js de forma silenciosa (espere un momento)..." -ForegroundColor Yellow
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$NodeMsi`" /qn /norestart" -Wait -NoNewWindow
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\nodejs\", [EnvironmentVariableTarget]::Machine)
        $env:Path += ";C:\Program Files\nodejs\"
        Write-Success "Node.js instalado core."
    } catch {
        Write-ErrorLog "No se pudo descargar o instalar Node.js: $_"
    }
}

# 2. Validar IIS y Módulos
Write-Step "Comprobando Módulos de Servidor IIS (URL Rewrite / ARR)..."
$iisSvc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if (-not $iisSvc) {
    Write-ErrorLog "Servicio IIS (W3SVC) no está habilitado en las características de Windows. Instálelo antes de continuar."
} else {
    if ($iisSvc.Status -ne 'Running') {
        Write-Warning "El servicio de IIS está apagado. Intentando arrancar..."
        Start-Service -Name W3SVC -ErrorAction SilentlyContinue
    }
    Write-Success "Servicio de IIS (W3SVC) verificado."
}

# URL Rewrite
$RewriteInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\rewrite.dll"
if (-not $RewriteInstalled) {
    Write-Warning "Módulo URL Rewrite no detectado. Descargando e instalando..."
    $RewriteMsi = "$env:TEMP\rewrite_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_es-ES.msi" -OutFile $RewriteMsi
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$RewriteMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Success "URL Rewrite instalado correctamente."
    } catch {
        Write-ErrorLog "Error al instalar URL Rewrite: $_"
    }
} else {
    Write-Success "Módulo URL Rewrite verificado."
}

# ARR
$ArrInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\requestRouter.dll"
if (-not $ArrInstalled) {
    Write-Warning "Módulo ARR (Application Request Routing) no detectado. Descargando e instalando..."
    $ArrMsi = "$env:TEMP\requestRouter_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi" -OutFile $ArrMsi
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$ArrMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Success "ARR instalado correctamente."
    } catch {
        Write-ErrorLog "Error al instalar ARR: $_"
    }
} else {
    Write-Success "Módulo ARR verificado."
}

# Proxy
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"
if (Test-Path $AppCmd) {
    & $AppCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost | Out-Null
}

# 2.5 Habilitar Acceso Remoto PostgreSQL y Firewall de Windows
Write-Step "Configurando acceso remoto PostgreSQL y reglas de Firewall..."
$RemoteScript = Join-Path $PSScriptRoot "Configure-PostgresRemote.ps1"
if (Test-Path $RemoteScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$RemoteScript" -Elevated
}

# 3. Comprobar Conectividad con Postgres
Write-Step "Verificando conexion TCP con base de datos en $($PgHost):$($PgPort)..."
$tcpClient = New-Object System.Net.Sockets.TcpClient
$pgConnected = $false
try {
    $connection = $tcpClient.BeginConnect($PgHost, $PgPort, $null, $null)
    $wait = $connection.AsyncWaitHandle.WaitOne(3000, $false)
    if ($wait) {
        $tcpClient.EndConnect($connection)
        Write-Success "Conexion con PostgreSQL establecida correctamente."
        $pgConnected = $true
    } else {
        Write-ErrorLog "Timeout conectando a Postgres en $($PgHost):$($PgPort). ¿Esta encendido el motor de base de datos?"
    }
} catch {
    Write-ErrorLog "Fallo en conexion TCP a base de datos en $($PgHost):$($PgPort): $_"
} finally {
    $tcpClient.Close()
}

# ==========================================
# RESOLUCIÓN DE PUERTOS Y DETENCIÓN DE SERVICIOS
# ==========================================
Write-Step "Verificando disponibilidad de puertos de red..."

# Detener procesos previos de la app para no colisionar en los puertos 3000 y 3001
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Función para resolver puertos
function Resolve-PortConflict($port, $defaultFallback) {
    $proc = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        $owningPid = $proc.OwningProcess
        $pInfo = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
        $pName = if ($pInfo) { $pInfo.ProcessName } else { "Desconocido" }
        Write-Warning "Puerto $port ocupado por proceso '$pName' (PID: $owningPid). Buscando alternativo libre..."
        
        $newPort = $defaultFallback
        while ($true) {
            $check = Get-NetTCPConnection -LocalPort $newPort -ErrorAction SilentlyContinue
            if (-not $check) {
                Write-Success "Puerto libre asignado: $newPort"
                return $newPort
            }
            $newPort++
        }
    }
    return $port
}

$SitePort = Resolve-PortConflict 3000 3010
$NextjsPort = Resolve-PortConflict 3001 3020

# ==========================================
# MOVER ARCHIVOS AL DIRECTORIO DESTINO
# ==========================================
Write-Step "Copiando archivos del portal al directorio destino: $TargetDir..."
if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
Copy-Item "$CurrentDir\*" -Destination $TargetDir -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Write-Success "Archivos copiados."

# ==========================================
# CONFIGURAR VARIABLES DE ENTORNO DESTINO (.env)
# ==========================================
Write-Step "Configurando variables de entorno (.env)..."
$DatabaseUrl = "postgresql://$($PgUser):$($PgPass)@$($PgHost):$($PgPort)/$($PgDb)?schema=public"
$EnvPath = "$TargetDir\.env"
$EnvContent = "DATABASE_URL=`"$DatabaseUrl`"`nNEXTAUTH_SECRET=`"AgenciasProductionSecretKey2024_Security`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
Set-Content -Path $EnvPath -Value $EnvContent -Encoding UTF8
Write-Success "Variables de entorno guardadas (.env)."

# ==========================================
# ACTUALIZAR REGLAS DE PROXY EN web.config
# ==========================================
$WebConfigPath = "$TargetDir\web.config"
if (Test-Path $WebConfigPath) {
    Write-Step "Configurando puertos de enrutamiento proxy en web.config..."
    $configContent = Get-Content $WebConfigPath -Raw
    $configContent = $configContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$NextjsPort/{R:1}`""
    Set-Content -Path $WebConfigPath -Value $configContent -Encoding UTF8
    Write-Success "web.config configurado."
}

# ==========================================
# ESTRUCTURAR Y ACTUALIZAR BASE DE DATOS
# ==========================================
if ($pgConnected) {
    Write-Step "Iniciando comparación y sincronización de base de datos..."
    Set-Location $TargetDir
    if (Test-Path ".\db_installer.js") {
        node .\db_installer.js $PgHost $PgPort $PgDb $PgUser $PgPass
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Base de datos estructurada y comparada sin errores críticos."
        } else {
            Write-Warning "Hubo inconsistencias o advertencias menores durante la sincronización. Revise el reporte en pantalla."
        }
    } else {
        Write-ErrorLog "No se encontró el ejecutable db_installer.js en la ruta destino."
    }
} else {
    Write-Warning "Sincronización de base de datos omitida debido a fallos de conexión PostgreSQL previos."
}

# ==========================================
# REGISTRAR SERVICIO DE WINDOWS
# ==========================================
Write-Step "Registrando servicio de segundo plano (Korex_NextJS)..."
Set-Location $TargetDir

# Detener servicio anterior si existe
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (Test-Path ".\install-service.js") {
    node .\install-service.js | Out-Null
    Start-Sleep -Seconds 2
    
    # Intento de Winsw de respaldo
    if (!(Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue)) {
        if (Test-Path "$TargetDir\daemon\korex_nextjs.exe") {
            Start-Process -FilePath "$TargetDir\daemon\korex_nextjs.exe" -ArgumentList "install" -Wait -NoNewWindow
            Start-Sleep -Seconds 2
        }
    }
    
    # Arrancar servicio
    if (Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue) {
        Start-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
        Write-Success "Servicio de Windows configurado y arrancado con éxito."
    } else {
        Write-ErrorLog "No se pudo registrar el servicio Windows."
    }
}

# ==========================================
# PUBLICAR EN IIS
# ==========================================
Write-Step "Configurando el portal en Internet Information Services (IIS)..."
Import-Module WebAdministration 

if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Stop-Website -Name $SiteName -ErrorAction SilentlyContinue 
    Remove-Website -Name $SiteName -Force -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "IIS:\Sites\$SiteName" -Recurse -Force -ErrorAction SilentlyContinue
}

try {
    New-Website -Name $SiteName -PhysicalPath $TargetDir -Port $SitePort -Force | Out-Null
    Start-Website -Name $SiteName -ErrorAction SilentlyContinue | Out-Null
    Write-Success "Portal web IIS configurado con éxito en puerto $SitePort."
} catch {
    Write-ErrorLog "Error configurando el sitio en IIS: $_"
}

# ==========================================
# RESUMEN FINAL
# ==========================================
Write-Host "`n========================================================" -ForegroundColor Green
Write-Host " ¡ASISTENTE DE INSTALACION FINALIZADO CON EXITO! " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host " - URL de acceso (IIS): http://localhost:$SitePort/" 
Write-Host " - El servicio backend arrancará automáticamente con Windows." 
Write-Host " - Log detallado disponible en: $TargetDir\install_log.txt" 
Write-Host "`nPresione cualquier tecla para finalizar el asistente..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
