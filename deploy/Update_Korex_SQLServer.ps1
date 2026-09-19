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
# PASO 0: RESPALDO DE CONFIGURACIÓN PREVIA Y DIAGNÓSTICO PRE-FLIGHT
# =============================================================================
$EnvFile = "$TargetDir\.env"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (Test-Path $EnvFile) {
    $EnvBackup = "$TargetDir\.env.bak_$Timestamp"
    Copy-Item -Path $EnvFile -Destination $EnvBackup -Force
    Write-Log "Respaldo de configuracion .env generado en: $EnvBackup"
}

# =============================================================================
# PASO 1: LEER VARIABLES PREVIAS O PARÁMETROS
# =============================================================================
$DbUrl = ""
$OldSitePort = 3000
$OldNextjsPort = 3001

if (Test-Path $EnvFile) {
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
}

if (![string]::IsNullOrEmpty($SqlHost) -and ![string]::IsNullOrEmpty($SqlDb) -and ![string]::IsNullOrEmpty($SqlUser)) {
    Write-Log "Usando parametros SQL Server recibidos: Host=$SqlHost, Port=$SqlPort, DB=$SqlDb, User=$SqlUser"
} else {
    Write-Log "Extrayendo credenciales SQL Server desde .env..."
    if ($DbUrl -and ($DbUrl -match 'sqlserver://([^:]+):([0-9]+);database=([^;]+);user=([^;]+);password=([^;]+)')) {
        $SqlHost = $matches[1]
        $SqlPort = $matches[2]
        $SqlDb = $matches[3]
        $SqlUser = [System.Uri]::UnescapeDataString($matches[4])
        $SqlPass = [System.Uri]::UnescapeDataString($matches[5])
    } else {
        $SqlHost = "127.0.0.1"; $SqlPort = "1433"; $SqlDb = "Korex_colaereo"; $SqlUser = "sa"; $SqlPass = "zzeusagencias"
    }
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
    foreach ($el in $envLines) {
        if ($el -match '^EXECUTION_MECHANISM="?(TASK_SCHEDULER|WINDOWS_SERVICE)"?') {
            $activeMechanism = $matches[1]
        }
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
    # Intentar Windows Service
    if (Test-Path ".\install-service.js") {
        node .\install-service.js >> $LogFile 2>&1
        Start-Sleep -Seconds 3
    }
    
    $svc = Get-Service -Name "Korex_SQLServer_Service" -ErrorAction SilentlyContinue
    if (-not $svc) { $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue }
    if (-not $svc) { $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue }
    
    if ($svc) {
        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 4
        $svcRefresh = Get-Service -Name $svc.Name
        if ($svcRefresh.Status -eq 'Running') {
            $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($chk) {
                Write-Log "Servicio de Windows SQL Server ($($svc.Name)) activo y escuchando en puerto $OldNextjsPort (PID: $($chk.OwningProcess))."
                $startedOk = $true
            }
        }
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
