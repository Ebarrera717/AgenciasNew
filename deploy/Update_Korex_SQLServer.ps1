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

# Registrar logs en install_sqlserver_log.txt
$LogFile = "$TargetDir\install_sqlserver_log.txt"
"`n======================================================" >> $LogFile
"  LOG DE ACTUALIZACION - KOREX PLATFORM (SQL SERVER)  " >> $LogFile
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

trap {
    $eLine = $_.InvocationInfo.ScriptLineNumber
    $eMsg = $_.Exception.Message
    Write-Log "ERROR CRITICO EN ACTUALIZADOR SQL SERVER (Linea ${eLine}): ${eMsg}" "ERROR"
    Show-Alert "Error de Actualizacion SQL Server" "Ocurrio un error en la linea ${eLine}:`n`nDetalle: ${eMsg}`n`nConsulte el log en:`n$LogFile"
    exit 1
}

Write-Log "Iniciando proceso de actualizacion silenciosa para SQL Server..."
$env:Path += ";C:\Program Files\nodejs"

# =============================================================================
# PASO 0: DETECCIÓN, VALIDACIÓN DE HASH Y RESPALDO INVIOLABLE DE .ENV
# =============================================================================
$EnvFile = "$TargetDir\.env"
if (-not (Test-Path $EnvFile)) {
    Write-Log "ERROR CRITICO: No se encontro el archivo .env de la instalacion existente del cliente. Abortando actualizacion." "ERROR"
    Show-Alert "Error Critico de Actualizacion" "No se encontro el archivo .env de la instalacion existente en este directorio:`n$TargetDir`n`nEl actualizador de SQL Server no puede continuar sin la configuracion previa del cliente."
    exit 1
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$EnvBackup = "$TargetDir\.env.bak_$Timestamp"
Copy-Item -Path $EnvFile -Destination $EnvBackup -Force
Write-Log "Respaldo inviolable de configuracion .env generado en: $EnvBackup"

# =============================================================================
# PASO 1: LEER CONFIGURACIÓN DEL .ENV EXISTENTE
# =============================================================================
$DbUrl = ""
$OldSitePort = 3000
$OldNextjsPort = 3001

$EnvContent = Get-Content $EnvFile
foreach ($line in $EnvContent) {
    if ($line -match '^DATABASE_URL="(.*)"') { 
        $DbUrl = $matches[1]
    }
    if ($line -match '^DATABASE_URL_SQLSERVER="(.*)"') { 
        $DbUrl = $matches[1]
    }
    if ($line -match '^NEXTAUTH_URL="http://[^:]+:([0-9]+)"') {
        $OldSitePort = [int]$matches[1]
    }
    if ($line -match '^PORT="?([0-9]+)"?') {
        $OldNextjsPort = [int]$matches[1]
    }
}

if ([string]::IsNullOrWhiteSpace($DbUrl)) {
    Write-Log "ERROR CRITICO: El archivo .env existente no contiene una variable DATABASE_URL valida." "ERROR"
    Show-Alert "Error de Configuracion" "El archivo .env de la instalacion no contiene informacion de conexion valida.`n`nRevise el archivo .env antes de actualizar."
    exit 1
}

if (![string]::IsNullOrEmpty($SqlHost) -and ![string]::IsNullOrEmpty($SqlDb) -and ![string]::IsNullOrEmpty($SqlUser)) {
    Write-Log "Usando parametros SQL Server recibidos: Host=$SqlHost, Port=$SqlPort, DB=$SqlDb, User=$SqlUser"
} else {
    Write-Log "Extrayendo credenciales SQL Server desde .env existente..."
    $cleanDbUrl = $DbUrl -replace '^(sqlserver|mssql)://', ''
    $parts = $cleanDbUrl -split ';'
    $serverPart = $parts[0]
    
    if ($serverPart -match '^([^:]+):([0-9]+)$') {
        $SqlHost = $matches[1]
        $SqlPort = $matches[2]
    } else {
        $SqlHost = $serverPart
        $SqlPort = "1433"
    }
    
    foreach ($part in $parts) {
        if ($part -match '^(?i)database\s*=\s*(.*)$') { $SqlDb = $matches[1].Trim() }
        if ($part -match '^(?i)(user|user id|uid)\s*=\s*(.*)$') { $SqlUser = [System.Uri]::UnescapeDataString($matches[2].Trim()) }
        if ($part -match '^(?i)(password|pwd)\s*=\s*(.*)$') { $SqlPass = [System.Uri]::UnescapeDataString($matches[2].Trim()) }
    }
    
    if ([string]::IsNullOrWhiteSpace($SqlHost) -or [string]::IsNullOrWhiteSpace($SqlDb) -or [string]::IsNullOrWhiteSpace($SqlUser)) {
        Write-Log "ERROR CRITICO: No fue posible parsear el string de conexion SQL Server desde el .env del cliente." "ERROR"
        Show-Alert "Error de Formato de Conexion" "La cadena de conexion en .env no tiene el formato esperado de SQL Server (sqlserver://host[:port];database=...;user=...;password=...)."
        exit 1
    }
}

if ($SqlHost -eq $env:COMPUTERNAME -or $SqlHost.ToLower() -eq "localhost" -or $SqlHost -eq "." -or $SqlHost -eq "(local)") {
    $SqlHost = "127.0.0.1"
}

# =============================================================================
# PASO 2: APLICAR ACTUALIZACIÓN T-SQL DE SQL SERVER
# =============================================================================
Write-Log "Ejecutando actualizador T-SQL de base de datos SQL Server..."
if (Test-Path ".\deploy\update_db_sqlserver.js") {
    node .\deploy\update_db_sqlserver.js >> $LogFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Advertencia al ejecutar update_db_sqlserver.js. Verificando ejecucion con sync_sqlserver_updater..." "WARN"
    }
}

# =============================================================================
# PASO 3: REINICIAR / ACTUALIZAR MECANISMO DE EJECUCIÓN (SERVICE O TASK SCHEDULER)
# =============================================================================
$activeMechanism = "WINDOWS_SERVICE"
if (Test-Path $EnvFile) {
    $envLines = Get-Content $EnvFile
    $hasProvider = $false
    foreach ($el in $envLines) {
        if ($el -match '^EXECUTION_MECHANISM="?(TASK_SCHEDULER|WINDOWS_SERVICE)"?') {
            $activeMechanism = $matches[1]
        }
        if ($el -match '^DATABASE_PROVIDER=') {
            $hasProvider = $true
        }
    }
    if (-not $hasProvider) {
        Add-Content -Path $EnvFile -Value "DATABASE_PROVIDER=`"sqlserver`"" -Encoding UTF8
        Write-Log "Añadida configuracion DATABASE_PROVIDER=sqlserver al archivo .env."
    }
}

Write-Log "Mecanismo de ejecucion activo detectado en SQL Server: $activeMechanism"

# Detener instancias previas limpiamente
Stop-Service -Name "Korex_SQLServer_Service" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "Korex_NextJS" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "korex_nextjs.exe" -Force -ErrorAction SilentlyContinue
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*$TargetDir*" } | Stop-Process -Force -ErrorAction SilentlyContinue

$taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
if (Test-Path $taskMgrScript) {
    & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Stop -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort > $null 2>&1
}

Start-Sleep -Seconds 2

$startedOk = $false

if ($activeMechanism -eq "TASK_SCHEDULER") {
    Write-Log "Actualizando y reiniciando via Windows Task Scheduler (Korex SQLServer - Startup)..."
    if (Test-Path $taskMgrScript) {
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 2
        & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 3
        
        $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($chk) {
            Write-Log "Task Scheduler SQL Server reiniciado exitosamente. Backend escuchando en puerto $OldNextjsPort (PID: $($chk.OwningProcess))."
            $startedOk = $true
        }
    }
} else {
    # Intentar Windows Service con protección total contra fallos en SCM
    if (Test-Path ".\install-service.js") {
        try {
            node .\install-service.js >> $LogFile 2>&1
        } catch {}
        Start-Sleep -Seconds 3
    }
    
    try {
        $svc = Get-Service -Name "Korex_SQLServer_Service" -ErrorAction SilentlyContinue
        if (-not $svc) { $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue }
        if (-not $svc) { $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue }
        
        if ($svc) {
            Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 4
            $svcRefresh = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($svcRefresh -and $svcRefresh.Status -eq 'Running') {
                $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($chk) {
                    Write-Log "Servicio de Windows SQL Server ($($svc.Name)) activo y escuchando en puerto $OldNextjsPort (PID: $($chk.OwningProcess))."
                    $startedOk = $true
                }
            }
        }
    } catch {
        Write-Log "Aviso al interactuar con el Servicio Windows SQL Server: $_" "WARN"
    }
    
    # Fallback a Task Scheduler si el servicio fallo al reiniciar
    if (-not $startedOk) {
        Write-Log "Aviso: Servicio Windows SQL Server fallo al reiniciar. Activando fallback a Task Scheduler..." "WARN"
        if (Test-Path $taskMgrScript) {
            & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Register -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 2
            & powershell.exe -ExecutionPolicy Bypass -File "$taskMgrScript" -Action Start -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 3
            $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($chk) {
                Write-Log "Fallback a Task Scheduler SQL Server completado exitosamente en puerto $OldNextjsPort."
                $startedOk = $true
                Add-Content -Path $EnvFile -Value "EXECUTION_MECHANISM=`"TASK_SCHEDULER`"" -Encoding UTF8
            }
        }
    }
}

if (-not $startedOk) {
    Write-Log "ERROR CRITICO: No fue posible reanudar el backend SQL Server tras la actualizacion." "ERROR"
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
    Show-Alert "Fallo de Inicio del Backend" "La aplicacion se actualizo pero no fue posible reiniciar el proceso en el puerto $OldNextjsPort.`n`nPor favor revise install_sqlserver_log.txt."
    exit 1
}

# =============================================================================
# PASO 4: EJECUTAR MOTOR DE DIAGNÓSTICO Y AUTOREPARACIÓN SQL SERVER
# =============================================================================
Write-Log "Ejecutando motor de diagnostico, validacion y autoreparacion para SQL Server..."
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
        -SitePort $OldSitePort `
        -NextjsPort $OldNextjsPort `
        -GenerateZip
}

Write-Log "PROCESO DE ACTUALIZACION SQL SERVER COMPLETADO."
