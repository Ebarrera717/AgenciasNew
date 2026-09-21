param(
    [string]$SqlHost,
    [string]$SqlPort,
    [string]$SqlDb,
    [string]$SqlUser,
    [string]$SqlPass
)

$TargetDir = $PSScriptRoot
Set-Location -Path $TargetDir
$ProgressPreference = 'SilentlyContinue'

# Crear / Limpiar log de instalación SQL Server
$LogFile = "$TargetDir\install_sqlserver_log.txt"
"======================================================" > $LogFile
"  LOG DE INSTALACION - KOREX PLATFORM (SQL SERVER)    " >> $LogFile
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

# Trap Global de Excepciones para Visibilidad Total en Pantalla (Skill installer-error-telemetry)
trap {
    $eLine = $_.InvocationInfo.ScriptLineNumber
    $eMsg = $_.Exception.Message
    Write-Log "ERROR CRITICO EN INSTALADOR (Linea ${eLine}): ${eMsg}" "ERROR"
    Show-Alert "Error de Instalacion de la Plataforma" "Ocurrio un error en la linea ${eLine}:`n`nDetalle: ${eMsg}`n`nConsulte el log en:`n$LogFile"
    exit 1
}

Write-Log "Iniciando proceso de instalacion de servicios para SQL Server..."

# 1. Comprobacion y Liberacion de Puertos
function Resolve-PortConflict($port, $defaultFallback) {
    Write-Log "Verificando puerto $port..."
    $proc = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        $owningPid = $proc.OwningProcess
        $pInfo = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
        $pName = if ($pInfo) { $pInfo.ProcessName } else { "Desconocido" }
        Write-Log "Puerto $port ocupado por proceso: $pName (PID: $owningPid)" "WARN"
        
        if ($pName -eq "node" -or $pName -like "*korex*" -or $pName -eq "korex_nextjs") {
            Write-Log "Intentando detener proceso remanente en puerto $port..."
            Stop-Process -Id $owningPid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            $stillProc = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
            if (-not $stillProc) {
                Write-Log "Puerto $port liberado con exito."
                return $port
            }
        }
        
        Write-Log "Buscando puerto alternativo libre..." "WARN"
        $newPort = $defaultFallback
        while ($true) {
            $check = Get-NetTCPConnection -LocalPort $newPort -ErrorAction SilentlyContinue
            if (-not $check) {
                Write-Log "Asignado puerto libre alternativo: $newPort"
                return $newPort
            }
            $newPort++
        }
    }
    return $port
}

# 2. Comprobacion de Conexion y Estructura SQL Server
function Check-SQLServerConnection($hostVal, $portVal, $dbVal, $userVal, $passVal) {
    Write-Log "Validando conectividad y estructura en SQL Server [$dbVal] en $($hostVal):$($portVal)..."
    
    $serverSpec = if ($portVal -and $portVal -ne "1433" -and $hostVal -notlike "*,*" -and $hostVal -notlike "*\*") { "$hostVal,$portVal" } else { $hostVal }
    $connStr = "Server=$serverSpec;Database=$dbVal;User Id=$userVal;Password=$passVal;Encrypt=False;TrustServerCertificate=True;Connection Timeout=8;"
    
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        $conn.Open()
        
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');"
        $tableCount = [int]$cmd.ExecuteScalar()
        
        $conn.Close()
        
        Write-Log "Conexion a SQL Server validada exitosamente ($tableCount tablas dbo encontradas)."
        return $true
    } catch {
        Write-Log "Aviso de conexion a SQL Server [$dbVal] en $($serverSpec): $_" "WARN"
        return $true
    }
}

# ==========================================
# EJECUCION DE PASOS DE INSTALACION
# ==========================================

# Paso 1. BUSCAR / COMPROBAR NODE.JS
Write-Log "Comprobando Node.js..."
$nodePaths = @("C:\Program Files\nodejs", "C:\Program Files (x86)\nodejs", "$TargetDir")
foreach ($np in $nodePaths) {
    if (Test-Path "$np\node.exe") {
        if ($env:Path -notlike "*$np*") {
            $env:Path += ";$np"
        }
    }
}

try {
    $nodeVer = node -v
    Write-Log "Node.js verificado: $nodeVer"
} catch {
    Write-Log "Node.js no esta en PATH global. Intentando instalar..." "WARN"
    $NodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
    $NodeMsi = "$env:TEMP\node.msi"
    try {
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeMsi -ErrorAction Stop
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$NodeMsi`" /qn /norestart" -Wait -NoNewWindow
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\nodejs\", [EnvironmentVariableTarget]::Machine)
        $env:Path += ";C:\Program Files\nodejs\"
        Write-Log "Node.js instalado exitosamente."
    } catch {
        Write-Log "No se pudo descargar Node.js automaticamente: $_" "WARN"
        Show-Alert "Aviso Node.js" "Node.js no se encontro en el servidor. Si el portal no inicia, instale Node.js v20+ manualmente." "Warning"
    }
}

# Paso 2. VERIFICAR SERVICIO DE IIS (W3SVC)
Write-Log "Comprobando servicio de IIS (W3SVC)..."
$iisSvc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if (-not $iisSvc) {
    Write-Log "AVISO: El servicio IIS (W3SVC) no esta instalado." "WARN"
    Show-Alert "Requisito IIS Faltante" "El rol Web Server (IIS) no se encuentra habilitado en el servidor.`n`nHabiltelo desde el Administrador del Servidor para exponer la aplicacion por el puerto HTTP 3000." "Warning"
} else {
    if ($iisSvc.Status -ne 'Running') {
        Start-Service -Name W3SVC -ErrorAction SilentlyContinue
    }
}

# URL Rewrite
$RewriteInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\rewrite.dll"
if (-not $RewriteInstalled) {
    Write-Log "Intentando instalar modulo URL Rewrite en IIS..." "WARN"
    $RewriteMsi = "$env:TEMP\rewrite_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_es-ES.msi" -OutFile $RewriteMsi -ErrorAction Stop
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$RewriteMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Log "URL Rewrite instalado correctamente."
    } catch {
        Write-Log "Aviso URL Rewrite: $_" "WARN"
    }
}

# ARR (Application Request Routing)
$ArrInstalled = Test-Path "$env:SystemRoot\system32\inetsrv\requestRouter.dll"
if (-not $ArrInstalled) {
    Write-Log "Intentando instalar modulo ARR en IIS..." "WARN"
    $ArrMsi = "$env:TEMP\requestRouter_amd64.msi"
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi" -OutFile $ArrMsi -ErrorAction Stop
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$ArrMsi`" /qn /norestart" -Wait -NoNewWindow
        Write-Log "ARR instalado correctamente."
    } catch {
        Write-Log "Aviso ARR: $_" "WARN"
    }
}

# Habilitar proxy en IIS
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"
if (Test-Path $AppCmd) {
    & $AppCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>&1 >> $LogFile
}

# Paso 3. DETENER SERVICIOS REMANENTES Y RESOLVER PUERTOS
Write-Log "Deteniendo procesos previos para liberar puertos..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "Korex_SQLServer_Service" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue

try {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    if (Test-Path "IIS:\Sites\Korex") {
        Stop-Website -Name "Korex" -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "Aviso IIS previo: $_" "WARN"
}
Start-Sleep -Seconds 2

$SitePort = Resolve-PortConflict 3000 3010
$NextjsPort = Resolve-PortConflict 3001 3020

# Paso 4. CONFIGURAR VARIABLES DE ENTORNO (.env)
if ([string]::IsNullOrEmpty($SqlHost)) { $SqlHost = "127.0.0.1" }
if ([string]::IsNullOrEmpty($SqlPort)) { $SqlPort = "1433" }
if ([string]::IsNullOrEmpty($SqlDb)) { $SqlDb = "Korex_colaereo" }
if ([string]::IsNullOrEmpty($SqlUser)) { $SqlUser = "sa" }
if ([string]::IsNullOrEmpty($SqlPass)) { $SqlPass = "zzeusagencias" }

Write-Log "Parametros SQL Server recibidos: Host=$SqlHost, Port=$SqlPort, DB=$SqlDb, User=$SqlUser"

$targetSqlHost = $SqlHost
if ($SqlHost -eq $env:COMPUTERNAME -or $SqlHost.ToLower() -eq "localhost" -or $SqlHost -eq "." -or $SqlHost -eq "(local)") {
    Write-Log "Detectado host local ($SqlHost). Usando 127.0.0.1 en .env para garantizar resolucion IPv4 inmediata en Node.js."
    $targetSqlHost = "127.0.0.1"
}

$EncodedUser = [System.Uri]::EscapeDataString($SqlUser)
$EncodedPass = [System.Uri]::EscapeDataString($SqlPass)
$DatabaseUrlSql = "sqlserver://$($targetSqlHost):$($SqlPort);database=$($SqlDb);user=$($EncodedUser);password=$($EncodedPass);encrypt=false;trustServerCertificate=true"

$EnvFile = "$TargetDir\.env"
$NewEnvContent = "DATABASE_PROVIDER=`"sqlserver`"`nDATABASE_URL_SQLSERVER=`"$DatabaseUrlSql`"`nDATABASE_URL=`"$DatabaseUrlSql`"`nNEXTAUTH_SECRET=`"KorexProductionSecretKey2024_Security`"`nLICENSE_SECRET=`"Korex_Master_License_Secret_Key_2026_Secure`"`nNEXTAUTH_URL=`"http://localhost:$SitePort`"`nPORT=`"$NextjsPort`"`n"
Set-Content -Path $EnvFile -Value $NewEnvContent -Encoding UTF8
Write-Log "Archivo .env de SQL Server creado/actualizado correctamente (DATABASE_PROVIDER=sqlserver, Host=$targetSqlHost)."

# Paso 5. ACTUALIZAR PROXY INVERSO EN web.config
$WebConfigPath = "$TargetDir\web.config"
if (Test-Path $WebConfigPath) {
    Write-Log "Actualizando puerto $NextjsPort en web.config..."
    $configContent = Get-Content $WebConfigPath -Raw
    $configContent = $configContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$NextjsPort/{R:1}`""
    Set-Content -Path $WebConfigPath -Value $configContent -Encoding UTF8
}

# Paso 6. REGISTRAR E INICIAR MECANISMO DE CONTROL DE PROCESO (SERVICE O TASK SCHEDULER)
Check-SQLServerConnection $SqlHost $SqlPort $SqlDb $SqlUser $SqlPass

$executionMechanism = "NONE"
$serviceSuccess = $false

Write-Log "Deteniendo instancias y servicios previos para inicio limpio en SQL Server..."
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "korex_nextjs.exe" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "Korex_SQLServer_Service" -Force -ErrorAction SilentlyContinue
Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Liberar cualquier proceso residual que mantenga bloqueado el puerto de backend ($NextjsPort)
$portOwner = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($portOwner) {
    Write-Log "Detectado proceso residual en puerto $NextjsPort (PID: $($portOwner.OwningProcess)). Finalizando..." "WARN"
    Stop-Process -Id $portOwner.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Start-Sleep -Seconds 1

# ESTRATEGIA A (OPCION PRINCIPAL): Windows Service
Write-Log "--- [ESTRATEGIA A] Intentando registrar Mecanismo Principal: Windows Service (Korex_NextJS) ---"
if (Test-Path "$TargetDir\install-service.js") {
    Set-Location $TargetDir
    node .\install-service.js >> $LogFile 2>&1
    Start-Sleep -Seconds 3
    
    $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue
    if (-not $svc) {
        $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue
    }
    
    if (-not $svc -and (Test-Path "$TargetDir\daemon\korex_nextjs.exe")) {
        Write-Log "Verificando servicio en SCM con daemon/korex_nextjs.exe..."
        Start-Process -FilePath "$TargetDir\daemon\korex_nextjs.exe" -ArgumentList "install" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue
        if (-not $svc) { $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue }
    }
    
    if ($svc) {
        Write-Log "Iniciando Servicio de Windows $($svc.Name)..."
        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 4
        
        $svcRefresh = Get-Service -Name $svc.Name
        if ($svcRefresh.Status -eq 'Running') {
            # Verificar escucha real en puerto
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
                Write-Log "--- TRAZA DETALLADA DE ERROR DEL SERVICIO WINDOWS (SQL SERVER) ---" "ERROR"
                Write-Log "$errDetails" "ERROR"
            }
        }
    } else {
        Write-Log "Aviso: No fue posible registrar el Servicio de Windows en SQL Server (posible restriccion de politicas corporativas de Windows)." "WARN"
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
    Stop-Service -Name "Korex_SQLServer_Service" -Force -ErrorAction SilentlyContinue
    
    $taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
    if (-not (Test-Path $taskMgrScript)) {
        $taskMgrScript = Join-Path $PSScriptRoot "task_scheduler_manager.ps1"
    }
    
    if (Test-Path $taskMgrScript) {
        Write-Log "Configurando tarea programada ONSTART (Korex SQLServer - Startup)..."
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine SQLSERVER -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 2
        
        Write-Log "Iniciando tarea programada y validando escucha en puerto $NextjsPort..."
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine SQLSERVER -TargetDir "$TargetDir" -Port $NextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 3
        
        $taskPortCheck = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($taskPortCheck) {
            Write-Log "Mecanismo Alternativo [Task Scheduler] ACTIVADO Y OPERATIVO exitosamente para SQL Server en puerto $NextjsPort (PID: $($taskPortCheck.OwningProcess))."
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
    Write-Log "ERROR CRITICO: Tanto Windows Service como Task Scheduler fallaron por politicas del servidor en SQL Server." "ERROR"
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
    Show-Alert "Fallo de Arranque de la Aplicación" "No fue posible iniciar Korex como Servicio de Windows ni como Tarea Programada (Task Scheduler).`n`nPor favor revise install_sqlserver_log.txt y consulte con el administrador del sistema."
    exit 1
}

# Registrar mecanismo activo en .env para persistencia en futuras actualizaciones
$EnvFile = Join-Path $TargetDir ".env"
if (Test-Path $EnvFile) {
    Add-Content -Path $EnvFile -Value "EXECUTION_MECHANISM=`"$executionMechanism`"" -Encoding UTF8
    Write-Log "Mecanismo activo persistido en .env: EXECUTION_MECHANISM=$executionMechanism"
}

# Paso 7. REGISTRAR SITIO WEB EN IIS
$SiteName = "Korex"
Write-Log "Registrando Sitio Web $SiteName en IIS (Puerto $SitePort -> $TargetDir)..."
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"

if (Test-Path $AppCmd) {
    try {
        Write-Log "Configurando IIS con appcmd.exe..."
        & $AppCmd delete site /site.name:"$SiteName" 2>&1 | Out-Null
        $res = & $AppCmd add site /name:"$SiteName" /bindings:"http/*:$($SitePort):" /physicalPath:"$TargetDir" 2>&1
        Write-Log "Respuesta appcmd: $res"
        & $AppCmd start site /site.name:"$SiteName" 2>&1 | Out-Null
        Write-Log "Sitio IIS $SiteName registrado e iniciado exitosamente en http://localhost:$SitePort/!"
    } catch {
        Write-Log "ERROR creando sitio IIS con appcmd: $_" "ERROR"
        Show-Alert "Fallo IIS" "No se pudo crear el sitio web $SiteName en IIS.`n`nDetalle: $_"
    }
} else {
    try {
        Import-Module WebAdministration -ErrorAction SilentlyContinue
        if (Test-Path "IIS:\Sites\$SiteName") {
            Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
            Remove-Website -Name $SiteName -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
        New-Website -Name $SiteName -PhysicalPath $TargetDir -Port $SitePort -Force | Out-Null
        Start-Website -Name $SiteName -ErrorAction SilentlyContinue
        Write-Log "Sitio IIS $SiteName registrado e iniciado con exito en http://localhost:$SitePort/!"
    } catch {
        Write-Log "ERROR creando sitio en IIS (WebAdministration): $_" "ERROR"
        Show-Alert "Fallo IIS" "No se pudo crear el sitio web $SiteName en IIS.`n`nDetalle: $_"
    }
}

# Paso 8. Diagnóstico Profundo, Validación y Soporte Remoto (SQL Server)
Write-Log "Ejecutando motor de diagnóstico profundo y validación para SQL Server..."
$DiagScript = Join-Path $TargetDir "deploy\Korex_Diagnostics_Engine.ps1"
if (Test-Path $DiagScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$DiagScript" `
        -Engine "SQLSERVER" `
        -Mode "Reparacion" `
        -TargetDir "$TargetDir" `
        -SqlHost "$SqlHost" `
        -SqlPort "$SqlPort" `
        -SqlDb "$SqlDb" `
        -SqlUser "$SqlUser" `
        -SqlPass "$SqlPass" `
        -SitePort $SitePort `
        -NextjsPort $NextjsPort `
        -GenerateZip
}

Write-Log "PROCESO DE INSTALACION SQL SERVER COMPLETADO CON EXITO."
