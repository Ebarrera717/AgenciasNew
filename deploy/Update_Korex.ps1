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
Write-Log "Deteniendo instancias previas (Servicio o Tarea Programada)..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "korex_nextjs.exe" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "AgenciasNew_NextJS" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Detener tarea programada si existe
$taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
if (Test-Path $taskMgrScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Stop -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort > $null 2>&1
}

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

# Paso 2. Extraer configuración de base de datos (priorizando parámetros de instalación)
$EnvFile = "$TargetDir\.env"
$DbUrl = ""
$OldSitePort = 3000
$OldNextjsPort = 3001

# Primero, verificar y leer el archivo .env existente
if (-not (Test-Path $EnvFile)) {
    Write-Log "ERROR CRITICO: No se encontro el archivo .env de la instalacion existente del cliente. Abortando actualizacion." "ERROR"
    Show-Alert "Error Critico de Actualizacion" "No se encontro el archivo .env de la instalacion existente en este directorio:`n$TargetDir`n`nEl actualizador de PostgreSQL no puede continuar sin la configuracion previa del cliente."
    exit 1
}

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

if ([string]::IsNullOrWhiteSpace($DbUrl)) {
    Write-Log "ERROR CRITICO: El archivo .env existente no contiene una variable DATABASE_URL valida." "ERROR"
    Show-Alert "Error de Configuracion" "El archivo .env de la instalacion no contiene informacion de conexion valida.`n`nRevise el archivo .env antes de actualizar."
    exit 1
}

# Si se pasaron los parámetros completos por linea de comandos, los usamos
if (![string]::IsNullOrEmpty($PgHost) -and ![string]::IsNullOrEmpty($PgPort) -and ![string]::IsNullOrEmpty($PgDb) -and ![string]::IsNullOrEmpty($PgUser)) {
    Write-Log "Usando configuracion de conexion DB recibida por parametros: Host=$PgHost, Port=$PgPort, DB=$PgDb, User=$PgUser"
} else {
    Write-Log "Extrayendo credenciales PostgreSQL desde .env existente..."
    if ($DbUrl -match '^postgresql://([^:]+):([^@]*)@([^:]+):([0-9]+)/([^?]+)') {
        $PgUser = [System.Uri]::UnescapeDataString($matches[1])
        $PgPass = [System.Uri]::UnescapeDataString($matches[2])
        $PgHost = $matches[3]
        $PgPort = $matches[4]
        $PgDb = $matches[5]
    } else {
        Write-Log "ERROR CRITICO: No fue posible parsear el string de conexion PostgreSQL desde el .env del cliente." "ERROR"
        Show-Alert "Error de Formato de Conexion" "La cadena de conexion en .env no tiene el formato esperado de PostgreSQL (postgresql://user:pass@host:port/db)."
        exit 1
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
    $NewEnvContent = "DATABASE_PROVIDER=`"postgresql`"`nDATABASE_URL=`"$DatabaseUrl`"`nNEXTAUTH_SECRET=`"KorexProductionSecretKey2024_Security`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
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
    Start-Sleep -Seconds 4
}

# Forzar arranque y verificar estado
# Paso 5. Reanudar / Actualizar el mecanismo de ejecucion activo
$activeMechanism = "WINDOWS_SERVICE"
if (Test-Path $EnvFile) {
    $envLines = Get-Content $EnvFile
    foreach ($el in $envLines) {
        if ($el -match '^EXECUTION_MECHANISM="?(TASK_SCHEDULER|WINDOWS_SERVICE)"?') {
            $activeMechanism = $matches[1]
        }
    }
}

Write-Log "Mecanismo de ejecucion activo detectado: $activeMechanism"

$startedOk = $false

if ($activeMechanism -eq "TASK_SCHEDULER") {
    Write-Log "Actualizando y reiniciando via Windows Task Scheduler (Korex NextJS - Startup)..."
    $taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
    if (Test-Path $taskMgrScript) {
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 2
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 3
        
        $chk = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($chk) {
            Write-Log "Task Scheduler reiniciado exitosamente. Backend escuchando en puerto $NextjsPort (PID: $($chk.OwningProcess))."
            $startedOk = $true
        }
    }
} else {
    # Intentar Windows Service
    try {
        $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue
        if (-not $svc) {
            $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
        }
        
        if ($svc) {
            Write-Log "Iniciando Servicio de Windows $($svc.Name)..."
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 4
            $svcRefresh = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($svcRefresh -and $svcRefresh.Status -eq 'Running') {
                $chk = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($chk) {
                    Write-Log "Servicio de Windows $($svc.Name) activo y escuchando en puerto $NextjsPort (PID: $($chk.OwningProcess))."
                    $startedOk = $true
                }
            }
        }
    } catch {
        Write-Log "Aviso al interactuar con el Servicio Windows: $_" "WARN"
    }
    
    # Si fallo el servicio en actualizacion, fallback a Task Scheduler
    if (-not $startedOk) {
        Write-Log "Aviso: Servicio Windows fallo al reiniciar. Activando fallback a Task Scheduler..." "WARN"
        $taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
        if (Test-Path $taskMgrScript) {
            & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 2
            & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 3
            $chk = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($chk) {
                Write-Log "Fallback a Task Scheduler completado exitosamente en puerto $NextjsPort."
                $startedOk = $true
                Add-Content -Path $EnvFile -Value "EXECUTION_MECHANISM=`"TASK_SCHEDULER`"" -Encoding UTF8
            }
        }
    }
}

if (-not $startedOk) {
    Write-Log "ERROR CRITICO: No fue posible reanudar el backend tras la actualizacion." "ERROR"
    Show-Alert "Fallo de Inicio del Backend" "La aplicacion se actualizo pero no fue posible reiniciar el proceso en el puerto $NextjsPort.`n`nPor favor revise update_log.txt."
    exit 1
}

# Paso 6. Recrear el sitio web y AppPool de IIS para asegurar configuración limpia
$SiteName = "Korex"
Write-Log "Reconfigurando el sitio web y AppPool de '$SiteName' en IIS..."
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
    if (Get-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue) {
        Write-Log "Removiendo AppPool IIS existente..."
        Remove-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue
    }
} catch {}

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

# Paso 7. Diagnóstico Profundo, Validación y Soporte Remoto (PostgreSQL)
Write-Log "Ejecutando motor de diagnóstico profundo y validación para PostgreSQL..."
$DiagScript = Join-Path $TargetDir "deploy\Korex_Diagnostics_Engine.ps1"
if (Test-Path $DiagScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$DiagScript" `
        -Engine "POSTGRESQL" `
        -Mode "Reparacion" `
        -TargetDir "$TargetDir" `
        -PgHost "$PgHost" `
        -PgPort "$PgPort" `
        -PgDb "$PgDb" `
        -PgUser "$PgUser" `
        -PgPass "$PgPass" `
        -SitePort $SitePort `
        -NextjsPort $NextjsPort `
        -GenerateZip
}

Write-Log "PROCESO DE ACTUALIZACION FINALIZADO CON EXITO."
