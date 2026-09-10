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

# Registrar logs en install_log.txt (anexar ya que es una actualización)
$LogFile = "$TargetDir\install_log.txt"
"`n======================================================" >> $LogFile
"  LOG DE ACTUALIZACION - KOREX PLATFORM               " >> $LogFile
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

Write-Log "Iniciando proceso de actualización silenciosa..."
# Asegurar que el PATH tenga Node para esta sesion
$env:Path += ";C:\Program Files\nodejs"

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
# PROCESO DE ACTUALIZACIÓN
# ==========================================

# Paso 1. Detener procesos previos para liberar bloqueos
Write-Log "Deteniendo el servicio Windows Korex_NextJS..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Log "Deteniendo el sitio web Korex en IIS para liberar puertos..."
Import-Module WebAdministration -ErrorAction SilentlyContinue
Stop-Website -Name "Korex" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Paso 2. Extraer configuración de base de datos (priorizando parámetros de instalación)
$EnvFile = "$TargetDir\.env"
$DbUrl = ""
$OldSitePort = 3000
$OldNextjsPort = 3001

# Primero, leer puertos y conexión existentes en el .env si este existe
if (Test-Path $EnvFile) {
    $EnvContent = Get-Content $EnvFile
    foreach ($line in $EnvContent) {
        if ($line -match '^NEXTAUTH_URL="http://localhost:(\d+)"') {
            $OldSitePort = [int]$matches[1]
        }
        if ($line -match '^PORT="?(\d+)"?') {
            $OldNextjsPort = [int]$matches[1]
        }
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
        $PgUser = [System.Uri]::UnescapeDataString($matches[1])
        $PgPass = [System.Uri]::UnescapeDataString($matches[2])
        $PgHost = $matches[3]
        $PgPort = $matches[4]
        $PgDb = $matches[5]
    } else {
        $PgUser = "postgres"; $PgPass = ""; $PgHost = "localhost"; $PgPort = "5432"; $PgDb = "agencias_new"
    }
}

Write-Log "Configuracion de conexion DB cargada para ejecucion: Host=$PgHost, Port=$PgPort, DB=$PgDb"

# Paso 3. Verificar y resolver conflictos de puertos
$SitePort = Resolve-PortConflict $OldSitePort 3010
$NextjsPort = Resolve-PortConflict $OldNextjsPort 3020

# Asegurar que el .env y web.config tengan siempre los puertos correctos de IIS y Next.js Standalone
if ($DbUrl) {
    Write-Log "Actualizando archivo .env con puertos (IIS=$SitePort, Next.js=$NextjsPort)..."
    $DatabaseUrl = "postgresql://$($PgUser):$($PgPass)@$($PgHost):$($PgPort)/$($PgDb)?schema=public"
    $NewEnvContent = "DATABASE_URL=`"$DatabaseUrl`"`nNEXTAUTH_SECRET=`"KorexProductionSecretKey2024_Security`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
    Set-Content -Path $EnvFile -Value $NewEnvContent -Encoding UTF8
}

$WebConfigPath = "$TargetDir\web.config"
if (Test-Path $WebConfigPath) {
    Write-Log "Asegurando enrutamiento inverso en web.config al puerto $NextjsPort..."
    $configContent = Get-Content $WebConfigPath -Raw
    $configContent = $configContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$NextjsPort/{R:1}`""
    Set-Content -Path $WebConfigPath -Value $configContent -Encoding UTF8
}

# Paso 4. Ejecutar el comparador inteligente de base de datos
if ($DbUrl) {
    $pgReady = Check-PostgresConnection $PgHost $PgPort
    if ($pgReady) {
        if (Test-Path ".\db_installer.js") {
            Write-Log "Ejecutando actualización de base de datos con comparador inteligente..."
            Set-Location $TargetDir
            node .\db_installer.js $PgHost $PgPort $PgDb $PgUser $PgPass >> $LogFile 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Base de datos sincronizada y actualizada correctamente."
            } else {
                Write-Log "ERROR CRITICO: El comparador de base de datos finalizo con errores. Abortando actualizacion." "ERROR"
                Show-Alert "Fallo de Base de Datos" "El comparador inteligente falló al aplicar la actualización de base de datos.`n`nPor favor revise el log detallado de errores en: $LogFile"
                exit 1
            }
        } else {
            Write-Log "No se encontro el archivo db_installer.js en la carpeta del sitio." "ERROR"
            Show-Alert "Error de Archivos" "No se encontró el ejecutable db_installer.js en el directorio de la aplicación."
            exit 1
        }
    } else {
        Write-Log "ERROR CRITICO: El servicio Postgres en $($PgHost):$($PgPort) no esta disponible para actualizacion estructural. Abortando actualizacion." "ERROR"
        Show-Alert "Error de Conexion Postgres" "No se pudo establecer conexion con PostgreSQL en $($PgHost):$($PgPort).`n`nAsegurese de que el motor de base de datos este encendido y acepte conexiones."
        exit 1
    }
}

# Paso 5. Re-registrar e Iniciar el Servicio Windows (Total Update)
Write-Log "Deteniendo servicio de Windows para aplicar la nueva versión de la aplicación..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "AgenciasNew_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (Test-Path ".\install-service.js") {
    Write-Log "Ejecutando install-service.js con la nueva versión..."
    node .\install-service.js >> $LogFile 2>&1
    Start-Sleep -Seconds 2
}

# Forzar arranque y verificar estado
if (Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue) {
    $svcStatus = (Get-Service -Name "Korex_NextJS").Status
    if ($svcStatus -ne 'Running') {
        Start-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 4
        $svcStatus = (Get-Service -Name "Korex_NextJS").Status
    }
    if ($svcStatus -ne 'Running') {
        Write-Log "ERROR: El servicio Korex_NextJS está registrado pero no pudo iniciarse de forma estable en el arranque." "ERROR"
        
        # Intentar extraer el error desde el log de daemon
        $errLogPath = "$TargetDir\daemon\korex_nextjs.err.log"
        $errDetails = ""
        if (Test-Path $errLogPath) {
            $errDetails = Get-Content $errLogPath -Tail 20 | Out-String
        }
        if (-not $errDetails) {
            $errDetails = "No se pudieron recuperar detalles adicionales del log de daemon."
        }
        
        Show-Alert "Fallo de Inicio del Servicio" "El servicio de Windows 'Korex_NextJS' se registró pero se cerró inmediatamente en el arranque.`n`nDetalle del error en el servidor (Node.js):`n$errDetails"
        exit 1
    }
    Write-Log "Estado final del servicio: $svcStatus"
} else {
    Write-Log "ERROR: El servicio Korex_NextJS no está registrado en el sistema." "ERROR"
    Show-Alert "Error del Servicio de Windows" "No se pudo registrar el servicio Windows 'Korex_NextJS'.`n`nPor favor verifique los permisos administrativos."
    exit 1
}

# Paso 6. Recrear el sitio web y AppPool de IIS para asegurar configuración limpia
$SiteName = "Korex"
Write-Log "Reconfigurando el sitio web y AppPool de '$SiteName' en IIS..."
Import-Module WebAdministration

if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Log "Removiendo sitio IIS existente..."
    Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
    Remove-Website -Name $SiteName -Force -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "IIS:\Sites\$SiteName" -Recurse -Force -ErrorAction SilentlyContinue
}

if (Get-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Log "Removiendo AppPool IIS existente..."
    Remove-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue
}

try {
    Write-Log "Creando nuevo sitio IIS y AppPool '$SiteName' en puerto $SitePort..."
    New-Website -Name $SiteName -PhysicalPath $TargetDir -Port $SitePort -Force
    
    Start-Sleep -Seconds 1
    $pool = Get-Item "IIS:\AppPools\$SiteName" -ErrorAction SilentlyContinue
    if ($pool) {
        Write-Log "Configurando AppPool '$SiteName' a Sin Código Administrado (No Managed Code)..."
        $pool.managedRuntimeVersion = ""
        $pool | Set-Item
    }
    
    Start-Website -Name $SiteName -ErrorAction Stop
    Write-Log "Sitio web '$SiteName' iniciado correctamente."
} catch {
    Write-Log "ERROR al recrear o iniciar el sitio/AppPool '$SiteName': $_" "ERROR"
    Show-Alert "Error de Configuración IIS" "Ocurrió un error al intentar registrar o iniciar el portal en IIS.`n`nDetalle: $_"
    exit 1
}

Write-Log "DIAGNOSTICO DE SITIOS IIS:"
Get-Website | ForEach-Object {
    $bindingsStr = ($_.bindings.Collection | ForEach-Object { $_.bindingInformation }) -join " | "
    Write-Log "Sitio: $($_.name), Estado: $($_.State), Bindings: $bindingsStr"
}

    Write-Log "DIAGNOSTICO DE DETALLES DE RED Y APPPOOL:"
    $proc = Get-NetTCPConnection -LocalPort $SitePort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        $owningPid = $proc.OwningProcess
        $pInfo = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
        $pName = if ($pInfo) { $pInfo.ProcessName } else { "Desconocido" }
        Write-Log "Puerto $SitePort está siendo ocupado por: $pName (PID: $owningPid)" "WARN"
    } else {
        Write-Log "Ningún proceso está escuchando en el puerto $SitePort."
    }
    
    $poolState = Get-WebAppPoolState -Name $SiteName -ErrorAction SilentlyContinue
    if ($poolState) {
        Write-Log "AppPool '$SiteName' Estado: $($poolState.Value)"
    } else {
        Write-Log "No se encontró AppPool con nombre '$SiteName'."
    }

# Paso 7. Verificación de salud HTTP final
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
    Show-Alert "Fallo de Verificación de Salud" "La actualización de archivos se completó, pero el portal web en http://localhost:$SitePort/ no responde o devolvió un error.`n`nPor favor verifique los logs de error en: $LogFile"
    exit 1
}

Write-Log "PROCESO DE ACTUALIZACION FINALIZADO CON EXITO."
