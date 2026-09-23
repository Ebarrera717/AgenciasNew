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
$NewEnvContent = "DATABASE_PROVIDER=`"postgresql`"`nDATABASE_URL=`"$DatabaseUrl`"`nNEXTAUTH_SECRET=`"KorexProductionSecretKey2024_Security`"`nLICENSE_SECRET=`"Korex_Master_License_Secret_Key_2026_Secure`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
Set-Content -Path $EnvFile -Value $NewEnvContent -Encoding UTF8
Write-Log "Archivo .env de PostgreSQL creado/actualizado correctamente (DATABASE_PROVIDER=postgresql)."

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

# Paso 7. REGISTRAR E INICIAR MECANISMO DE CONTROL DE PROCESO (SERVICE O TASK SCHEDULER)
$executionMechanism = "NONE"
$serviceSuccess = $false

Write-Log "Deteniendo instancias y servicios previos para inicio limpio..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "AgenciasNew_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "korex_nextjs.exe" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Liberar cualquier proceso que mantenga bloqueado el puerto de backend ($NextjsPort)
$portOwner = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($portOwner) {
    Write-Log "Detectado proceso residual en puerto $NextjsPort (PID: $($portOwner.OwningProcess)). Finalizando..." "WARN"
    Stop-Process -Id $portOwner.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Start-Sleep -Seconds 1

# ESTRATEGIA A (OPCION PRINCIPAL): Windows Service
Write-Log "--- [ESTRATEGIA A] Intentando registrar Mecanismo Principal: Windows Service (Korex_NextJS) ---"
if (Test-Path ".\install-service.js") {
    try {
        node .\install-service.js >> $LogFile 2>&1
        Start-Sleep -Seconds 3
        
        $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue
        if (-not $svc) {
            $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
        }
        
        if ($svc) {
            Write-Log "Arrancando servicio de Windows $($svc.Name)..."
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 4
            
            $svcRefresh = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($svcRefresh -and $svcRefresh.Status -eq 'Running') {
                # Verificar si realmente está escuchando en el puerto
                Start-Sleep -Seconds 2
                $portCheck = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($portCheck) {
                    Write-Log "Mecanismo Principal [Windows Service] OPERATIVO al 100% en puerto $NextjsPort (PID: $($portCheck.OwningProcess))."
                    $serviceSuccess = $true
                    $executionMechanism = "WINDOWS_SERVICE"
                }
            }
            
            if (-not $serviceSuccess) {
                Write-Log "Aviso: El servicio $($svc.Name) se registro pero no mantuvo el puerto $NextjsPort en escucha." "WARN"
                $errLogPath = "$TargetDir\daemon\korex_nextjs.err.log"
                if (Test-Path $errLogPath) {
                    $errDetails = Get-Content $errLogPath -Tail 25 | Out-String
                    Write-Log "--- TRAZA DETALLADA DE ERROR DEL SERVICIO WINDOWS ---" "ERROR"
                    Write-Log "$errDetails" "ERROR"
                }
            }
        } else {
            Write-Log "Aviso: No fue posible registrar el Servicio de Windows Korex_NextJS (posible restriccion de politicas corporativas de Windows)." "WARN"
        }
    } catch {
        Write-Log "Aviso durante la configuracion del Servicio de Windows: $_" "WARN"
    }
}

# ESTRATEGIA B (MECANISMO ALTERNATIVO / FALLBACK): Windows Task Scheduler
if (-not $serviceSuccess) {
    Write-Log "=================================================================" "WARN"
    Write-Log "  ACTIVANDO ESTRATEGIA B (FALLBACK): WINDOWS TASK SCHEDULER     " "WARN"
    Write-Log "  Motivo: Politica de seguridad o restriccion en Windows Service " "WARN"
    Write-Log "=================================================================" "WARN"
    
    # Detener servicio previo fallido
    Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "korex_nextjs.exe" -Force -ErrorAction SilentlyContinue
    
    $taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
    if (-not (Test-Path $taskMgrScript)) {
        $taskMgrScript = Join-Path $PSScriptRoot "task_scheduler_manager.ps1"
    }
    
    if (Test-Path $taskMgrScript) {
        Write-Log "Configurando tarea programada ONSTART (Korex NextJS - Startup)..."
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 2
        
        Write-Log "Iniciando tarea programada y validando escucha en puerto $NextjsPort..."
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine POSTGRESQL -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 3
        
        $taskPortCheck = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($taskPortCheck) {
            Write-Log "Mecanismo Alternativo [Task Scheduler] ACTIVADO Y OPERATIVO exitosamente en puerto $NextjsPort (PID: $($taskPortCheck.OwningProcess))."
            $executionMechanism = "TASK_SCHEDULER"
        } else {
            Write-Log "ERROR: Task Scheduler se registro pero el proceso Node no logro escuchar en puerto $NextjsPort." "ERROR"
            $startupLogPath = "$TargetDir\korex_startup.log"
            if (Test-Path $startupLogPath) {
                $startupDetails = Get-Content $startupLogPath -Tail 30 | Out-String
                Write-Log "--- TRAZA DE ARRANQUE (korex_startup.log) ---" "ERROR"
                Write-Log "$startupDetails" "ERROR"
            }
        }
    } else {
        Write-Log "ERROR: No se encontro task_scheduler_manager.ps1 en deploy." "ERROR"
    }
}

if ($executionMechanism -eq "NONE") {
    Write-Log "ERROR CRITICO: Tanto Windows Service como Task Scheduler fallaron por politicas del servidor." "ERROR"
    $errLogPath = "$TargetDir\daemon\korex_nextjs.err.log"
    if (Test-Path $errLogPath) {
        $errDetails = Get-Content $errLogPath -Tail 25 | Out-String
        Write-Log "--- ULTIMO LOG DEL DAEMON WINDOWS SERVICE ---" "ERROR"
        Write-Log "$errDetails" "ERROR"
    }
    $startupLogPath = "$TargetDir\korex_startup.log"
    if (Test-Path $startupLogPath) {
        $startupDetails = Get-Content $startupLogPath -Tail 30 | Out-String
        Write-Log "--- ULTIMO LOG DE TASK SCHEDULER / RUNNER ---" "ERROR"
        Write-Log "$startupDetails" "ERROR"
    }
    Show-Alert "Fallo de Arranque de la Aplicación" "No fue posible iniciar Korex como Servicio de Windows ni como Tarea Programada (Task Scheduler).`n`nPor favor revise install_log.txt y consulte con el administrador del sistema."
    exit 1
}

# Registrar mecanismo activo en .env para persistencia en futuras actualizaciones
if (Test-Path $EnvFile) {
    Add-Content -Path $EnvFile -Value "EXECUTION_MECHANISM=`"$executionMechanism`"" -Encoding UTF8
    Write-Log "Mecanismo activo persistido en .env: EXECUTION_MECHANISM=$executionMechanism"
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

# Paso 10. Diagnóstico Profundo, Validación y Soporte Remoto (PostgreSQL)
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

Write-Log "PROCESO DE INSTALACION COMPLETADO CON EXITO."
