param(
    [string]$PgHost,
    [string]$PgPort,
    [string]$PgDb,
    [string]$PgUser,
    [string]$PgPass
)

$TargetDir = $PSScriptRoot
Set-Location -Path $TargetDir
$ProgressPreference = 'SilentlyContinue'

# Crear / Limpiar log de instalación
$LogFile = "$TargetDir\install_log.txt"
"======================================================" > $LogFile
"  LOG DE INSTALACION - KOREX PLATFORM                 " >> $LogFile
"  Fecha: $(Get-Date)" >> $LogFile
"======================================================" >> $LogFile

function Write-Log($message, $level = "INFO") {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$date] [$level] $message"
    Write-Host $logLine
    if ($LogFile) {
        $logLine >> $LogFile
    }
}

function Show-Alert($title, $message, $icon = "Error") {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::$icon) | Out-Null
    } catch {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($message, 0, $title, 16) | Out-Null
    }
}

Write-Log "Iniciando proceso de instalación silenciosa..."

# ==========================================
# FUNCIONES DE PRE-FLIGHT Y SALUD DEL ENTORNO
# ==========================================

# 1. Comprobación y Liberación/Resolución de Puertos
function Resolve-PortConflict($port, $defaultFallback) {
    Write-Log "Verificando puerto $port..."
    $proc = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        $owningPid = $proc.OwningProcess
        $pInfo = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
        $pName = if ($pInfo) { $pInfo.ProcessName } else { "Desconocido" }
        Write-Log "Puerto $port ocupado por el proceso: $pName (PID: $owningPid)" "WARN"
        
        # Si es un proceso node o de nuestro servicio, podemos intentar matarlo
        if ($pName -eq "node" -or $pName -like "*korex_nextjs*" -or $pName -eq "korex_nextjs") {
            Write-Log "Intentando detener proceso remanente de nuestra app en puerto $port..."
            Stop-Process -Id $owningPid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            # Verificar si se liberó
            $stillProc = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
            if (-not $stillProc) {
                Write-Log "Puerto $port liberado con éxito."
                return $port
            }
        }
        
        # Si sigue ocupado por otra cosa, buscar puerto alternativo libre
        Write-Log "El puerto $port sigue ocupado. Buscando puerto alternativo libre..." "WARN"
        $newPort = $defaultFallback
        while ($true) {
            $check = Get-NetTCPConnection -LocalPort $newPort -ErrorAction SilentlyContinue
            if (-not $check) {
                Write-Log "Se asignará el puerto libre alternativo: $newPort"
                return $newPort
            }
            $newPort++
        }
    }
    return $port
}

# 2. Comprobación de Conexión Postgres
function Check-PostgresConnection($pgHost, $pgPort) {
    Write-Log "Comprobando conectividad TCP con PostgreSQL en $($pgHost):$($pgPort)..."
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $connection = $tcpClient.BeginConnect($pgHost, $pgPort, $null, $null)
        $wait = $connection.AsyncWaitHandle.WaitOne(3000, $false) # 3 segundos timeout
        if (-not $wait) {
            Write-Log "Timeout de conexion a PostgreSQL en $($pgHost):$($pgPort). El motor PostgreSQL podria estar inactivo o el puerto bloqueado." "ERROR"
            return $false
        }
        $tcpClient.EndConnect($connection)
        Write-Log "Conexion TCP establecida exitosamente con PostgreSQL."
        return $true
    } catch {
        Write-Log "Fallo de conexion TCP a PostgreSQL en $($pgHost):$($pgPort): $_" "ERROR"
        return $false
    } finally {
        $tcpClient.Close()
    }
}

# ==========================================
# EJECUCIÓN DE PASOS DE INSTALACIÓN
# ==========================================

# Paso 1. VALIDAR / INSTALAR NODE.JS Core
Write-Log "Comprobando dependencia de Node.js..."
try {
    $nodeVer = node -v
    Write-Log "Node.js detectado: $nodeVer"
} catch {
    Write-Log "Node.js no encontrado. Iniciando descarga e instalación silenciosa de Node.js v20..." "WARN"
    $NodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
    $NodeMsi = "$env:TEMP\node.msi"
    try {
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeMsi
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$NodeMsi`" /qn /norestart" -Wait -NoNewWindow
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\nodejs\", [EnvironmentVariableTarget]::Machine)
        $env:Path += ";C:\Program Files\nodejs\"
        Write-Log "Node.js instalado exitosamente en el sistema."
    } catch {
        Write-Log "Fallo crítico descargando/instalando Node.js: $_" "ERROR"
        Show-Alert "Fallo de Requisito: Node.js" "No se pudo descargar o instalar Node.js automáticamente.`n`nDetalle: $_`n`nPor favor instale Node.js manualmente (v20 o superior) antes de reintentar la instalación."
        exit 1
    }
}

# Paso 2. INSTALAR MODULOS DE IIS (ARR / Proxy / URL Rewrite)
Write-Log "Comprobando módulos de IIS..."
$iisSvc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if (-not $iisSvc) {
    Write-Log "ERROR: El servicio de IIS (W3SVC) no está presente." "ERROR"
    Show-Alert "Requisito Faltante: IIS" "El servidor web IIS (W3SVC) no está instalado o habilitado en este equipo.`n`nPor favor instálelo y habilítelo desde 'Activar o desactivar características de Windows' antes de instalar el portal."
    exit 1
} else {
    if ($iisSvc.Status -ne 'Running') {
        Write-Log "El servicio IIS está apagado. Intentando arrancar..."
        Start-Service -Name W3SVC -ErrorAction SilentlyContinue
    }
}

# Verificar e instalar URL Rewrite
$RewriteInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\rewrite.dll"
if (-not $RewriteInstalled) {
    Write-Log "URL Rewrite no detectado. Descargando e instalando..." "WARN"
    $RewriteMsi = "$env:TEMP\rewrite_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_es-ES.msi" -OutFile $RewriteMsi
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$RewriteMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Log "URL Rewrite instalado correctamente."
    } catch {
        Write-Log "Error al instalar URL Rewrite: $_" "ERROR"
        Show-Alert "Fallo de Requisito: URL Rewrite" "No se pudo instalar el modulo URL Rewrite de IIS.`n`nDetalle: $_`n`nPor favor instálelo manualmente antes de reintentar."
        exit 1
    }
} else {
    Write-Log "Módulo URL Rewrite verificado."
}

# Verificar e instalar ARR
$ArrInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\requestRouter.dll"
if (-not $ArrInstalled) {
    Write-Log "ARR (Application Request Routing) no detectado. Descargando e instalando..." "WARN"
    $ArrMsi = "$env:TEMP\requestRouter_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi" -OutFile $ArrMsi
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$ArrMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Log "ARR instalado correctamente."
    } catch {
        Write-Log "Error al instalar ARR: $_" "ERROR"
    }
} else {
    Write-Log "Módulo ARR verificado."
}

# Asegurar habilitación del proxy inverso en IIS
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"
if (Test-Path $AppCmd) {
    Write-Log "Habilitando funcionalidad Proxy en IIS Application Request Routing..."
    & $AppCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>&1 >> $LogFile
}

# Paso 2.5. CONFIGURAR ACCESO REMOTO POSTGRESQL Y FIREWALL
Write-Log "Configurando reglas de red y Firewall para PostgreSQL y Servidor Web..."
$RemoteScript = Join-Path $PSScriptRoot "Configure-PostgresRemote.ps1"
if (Test-Path $RemoteScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$RemoteScript" -Elevated
}

# Paso 3. CONFIGURAR PUERTOS Y DETENER SERVICIOS REMANENTES
$SitePort = 3000
$NextjsPort = 3001

# Detener el servicio anterior antes de validar puertos para no chocarnos con nosotros mismos
Write-Log "Deteniendo servicios y procesos de la app para liberación..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Log "Deteniendo el sitio web Korex en IIS para liberar puertos..."
try {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    if (Test-Path "IIS:\Sites\Korex") {
        Stop-Website -Name "Korex" -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "Aviso IIS previo: $_" "WARN"
}
Start-Sleep -Seconds 2

# Resolver posibles conflictos de puertos
$SitePort = Resolve-PortConflict 3000 3010
$NextjsPort = Resolve-PortConflict 3001 3020

# Paso 4. PROCESAR VARIABLES DE ENTORNO (.env) (priorizando parámetros de instalación)
$EnvFile = "$TargetDir\.env"
$DbUrl = ""

if (Test-Path $EnvFile) {
    $EnvContent = Get-Content $EnvFile
    foreach ($line in $EnvContent) {
        if ($line -match '^DATABASE_URL="(.*)"') { 
            $DbUrl = $matches[1]
        }
    }
}

# Si se pasaron los parámetros completos por linea de comandos, los usamos
if (![string]::IsNullOrEmpty($PgHost) -and ![string]::IsNullOrEmpty($PgPort) -and ![string]::IsNullOrEmpty($PgDb) -and ![string]::IsNullOrEmpty($PgUser)) {
    Write-Log "Usando configuracion de conexion DB recibida por parametros: Host=$PgHost, Port=$PgPort, DB=$PgDb, User=$PgUser"
} else {
    Write-Log "No se recibieron parametros completos de conexion. Leyendo del archivo .env..."
    if ($DbUrl -and ($DbUrl -match '^postgresql://([^:]+):([^@]*)@([^:]+):([0-9]+)/([^?]+)')) {
        $PgUser = $matches[1]
        $PgPass = $matches[2]
        $PgHost = $matches[3]
        $PgPort = $matches[4]
        $PgDb = $matches[5]
    } else {
        $PgUser = "postgres"; $PgPass = ""; $PgHost = "localhost"; $PgPort = "5432"; $PgDb = "agencias_new"
    }
}

Write-Log "Configuracion de conexion DB cargada para ejecucion: Host=$PgHost, Port=$PgPort, DB=$PgDb, User=$PgUser"

# Actualizar el archivo .env con los puertos dinámicos resultantes
Write-Log "Actualizando archivo .env con puertos finales (IIS=$SitePort, Next.js=$NextjsPort)..."
$DatabaseUrl = "postgresql://$($PgUser):$($PgPass)@$($PgHost):$($PgPort)/$($PgDb)?schema=public"
$NewEnvContent = "DATABASE_URL=`"$DatabaseUrl`"`nNEXTAUTH_SECRET=`"KorexProductionSecretKey2024_Security`"`nLICENSE_SECRET=`"Korex_Master_License_Secret_Key_2026_Secure`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
Set-Content -Path $EnvFile -Value $NewEnvContent -Encoding UTF8

# Paso 5. ACTUALIZAR CONFIGURACIÓN DE PROXY EN web.config
$WebConfigPath = "$TargetDir\web.config"
if (Test-Path $WebConfigPath) {
    Write-Log "Actualizando proxy inverso en web.config al puerto $NextjsPort..."
    $configContent = Get-Content $WebConfigPath -Raw
    $configContent = $configContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$NextjsPort/{R:1}`""
    Set-Content -Path $WebConfigPath -Value $configContent -Encoding UTF8
}

# Paso 6. COMPROBAR POSTGRES Y CORRER db_installer.js
$pgReady = Check-PostgresConnection $PgHost $PgPort
if ($pgReady) {
    Set-Location $TargetDir
    if (Test-Path ".\db_installer.js") {
        Write-Log "Ejecutando comparador de base de datos db_installer.js..."
        node .\db_installer.js $PgHost $PgPort $PgDb $PgUser $PgPass >> $LogFile 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Esquema y sincronización de base de datos aplicados con éxito."
        } else {
            Write-Log "ERROR CRITICO: El comparador de base de datos finalizo con errores. Abortando instalacion." "ERROR"
            Show-Alert "Fallo de Base de Datos" "El comparador inteligente falló al aplicar la estructura a la base de datos.`n`nPor favor revise el log detallado de errores en: $LogFile"
            exit 1
        }
    } else {
        Write-Log "Error: db_installer.js no encontrado." "ERROR"
        Show-Alert "Error de Archivos" "No se encontró el ejecutable db_installer.js en el directorio de la aplicación."
        exit 1
    }
} else {
    Write-Log "ERROR: El servicio Postgres en $($PgHost):$($PgPort) no está disponible." "ERROR"
    Show-Alert "Error de Conexion Postgres" "No se pudo establecer conexion con PostgreSQL en $($PgHost):$($PgPort).`n`nAsegurese de que el motor de base de datos este encendido y acepte conexiones."
    exit 1
}

# Paso 7. REGISTRAR E INICIAR SERVICIO WINDOWS
Write-Log "Deteniendo servicio de Node.js en Windows si ya existe..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "AgenciasNew_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (Test-Path ".\install-service.js") {
    node .\install-service.js >> $LogFile 2>&1
    Start-Sleep -Seconds 4
    
    $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue
    if (-not $svc) {
        $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
    }
    
    if ($svc) {
        Write-Log "Arrancando servicio de Windows $($svc.Name)..."
        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 4
        
        $svcRefresh = Get-Service -Name $svc.Name
        if ($svcRefresh.Status -ne 'Running') {
            Write-Log "ERROR CRÍTICO: El servicio $($svc.Name) se cerró inmediatamente después de arrancar." "ERROR"
            
            $errLogPath = "$TargetDir\daemon\korex_nextjs.err.log"
            $errDetails = ""
            if (Test-Path $errLogPath) {
                $errDetails = Get-Content $errLogPath -Tail 20 | Out-String
            }
            if (-not $errDetails) {
                $errDetails = "No se pudieron recuperar detalles adicionales del log de daemon."
            }
            
            Show-Alert "Fallo de Arranque de la Aplicación" "El portal web Next.js (Korex_NextJS) no pudo iniciar de forma estable y se cerró en el arranque.`n`nDetalle del error en el servidor (Node.js):`n$errDetails"
            exit 1
        }
        Write-Log "Estado final del servicio: $($svcRefresh.Status)"
    } else {
        Write-Log "ERROR CRÍTICO: No se pudo registrar el servicio de Windows." "ERROR"
        Show-Alert "Error del Servicio de Windows" "No se pudo registrar ni iniciar el servicio de Windows 'Korex_NextJS' de la aplicación.`n`nPor favor verifique los permisos administrativos."
        exit 1
    }
}

# Paso 8. CONFIGURAR IIS SITIO WEB
$SiteName = "Korex"
Write-Log "Registrando Portal en Internet Information Services (IIS)..."
try {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    if (Test-Path "IIS:\Sites\$SiteName") {
        Write-Log "Removiendo sitio IIS existente..."
        Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
        Remove-Website -Name $SiteName -Force -Confirm:$false -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "Aviso al remover sitio previo ${SiteName}: $_" "WARN"
}

try {
    Write-Log "Creando nuevo sitio IIS '$SiteName' en puerto $SitePort, apuntando a: $TargetDir"
    New-Website -Name $SiteName -PhysicalPath $TargetDir -Port $SitePort -Force >> $LogFile 2>&1
    Start-Website -Name $SiteName -ErrorAction SilentlyContinue
    Write-Log "Sitio de IIS iniciado correctamente. Acceso en: http://localhost:$SitePort/"
} catch {
    Write-Log "Fallo configurando el sitio de IIS: $_" "ERROR"
    Show-Alert "Error de Configuración IIS" "Ocurrió un error al intentar registrar el portal en IIS.`n`nDetalle: $_"
    exit 1
}

# Paso 9. Verificación de salud HTTP final
Write-Log "Realizando verificación de salud HTTP en http://localhost:$SitePort/..."
$healthSuccess = $false
for ($i = 1; $i -le 6; $i++) {
    Write-Log "Intento $i de 6 para conectar al portal web..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$SitePort/" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
            Write-Log "Verificación de salud exitosa: El portal respondió con código $($response.StatusCode)."
            $healthSuccess = $true
            break
        } else {
            Write-Log "El servidor respondió con código de estado HTTP: $($response.StatusCode)" "WARN"
        }
    } catch {
        Write-Log "El portal web no respondió en este intento. Detalles: $_" "WARN"
    }
    Start-Sleep -Seconds 2
}

if (-not $healthSuccess) {
    Write-Log "ERROR CRITICO: La verificación de salud HTTP falló. El portal no respondió exitosamente." "ERROR"
    Show-Alert "Fallo de Verificación de Salud" "La instalación de archivos se completó, pero el portal web en http://localhost:$SitePort/ no responde o devolvió un error.`n`nPor favor verifique los logs de error en: $LogFile"
    exit 1
}

Write-Log "PROCESO DE INSTALACION COMPLETADO CON EXITO."
