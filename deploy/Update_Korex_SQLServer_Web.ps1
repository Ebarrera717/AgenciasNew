param(
    [string]$SqlHost,
    [string]$SqlPort,
    [string]$SqlDb,
    [string]$SqlUser,
    [string]$SqlPass
)

$TargetDir = $PSScriptRoot
if (-not (Test-Path "$TargetDir\server.js")) {
    $parent = Split-Path -Parent $PSScriptRoot
    if (Test-Path "$parent\server.js") {
        $TargetDir = $parent
    }
}
Set-Location -Path $TargetDir
$ProgressPreference = 'SilentlyContinue'

$LogFile = "$TargetDir\install_sqlserver_web_log.txt"
"`n======================================================" >> $LogFile
"  LOG DE ACTUALIZACION SITIO WEB NEXT.JS (SQL SERVER) " >> $LogFile
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
    Write-Host "====================================================" -ForegroundColor Red
    Write-Host "[$title] $message" -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Red
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::$icon) | Out-Null
    } catch {
        try {
            $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
            $wshell.Popup($message, 0, $title, 16) | Out-Null
        } catch {}
    }
}

trap {
    $eLine = $_.InvocationInfo.ScriptLineNumber
    $eMsg = $_.Exception.Message
    Write-Log "ERROR CRITICO EN ACTUALIZADOR WEB SQL SERVER (Linea ${eLine}): ${eMsg}" "ERROR"
    Show-Alert "Error de Actualizacion Sitio Web" "Ocurrio un error en la linea ${eLine}:`n`nDetalle: ${eMsg}`n`nConsulte el log en:`n$LogFile"
    exit 1
}

Write-Log "Iniciando actualizacion exclusiva del Proyecto Web Next.js (conectado a SQL Server)..."
$env:Path += ";C:\Program Files\nodejs;C:\Program Files (x86)\nodejs;$TargetDir"

# =============================================================================
# PASO 1: GESTIÓN Y RESPALDO DE .ENV EN EL SERVIDOR WEB
# =============================================================================
$EnvFile = "$TargetDir\.env"
$DbUrl = ""
$OldSitePort = 3000
$OldNextjsPort = 3001
$activeMechanism = "WINDOWS_SERVICE"
$NextAuthSecret = "KorexProductionSecretKey2024_Security"
$LicenseSecret = "Korex_Master_License_Secret_Key_2026_Secure"

if (Test-Path $EnvFile) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $EnvBackup = "$TargetDir\.env.bak_$Timestamp"
    Copy-Item -Path $EnvFile -Destination $EnvBackup -Force
    Write-Log "Respaldo de configuracion .env generado en: $EnvBackup"

    $EnvContent = Get-Content $EnvFile
    foreach ($line in $EnvContent) {
        if ($line -match '^DATABASE_URL="(.*)"') { $DbUrl = $matches[1] }
        if ($line -match '^DATABASE_URL_SQLSERVER="(.*)"') { $DbUrl = $matches[1] }
        if ($line -match '^NEXTAUTH_URL="http://[^:]+:([0-9]+)"') { $OldSitePort = [int]$matches[1] }
        if ($line -match '^PORT="?([0-9]+)"?') { $OldNextjsPort = [int]$matches[1] }
        if ($line -match '^EXECUTION_MECHANISM="?(TASK_SCHEDULER|WINDOWS_SERVICE)"?') { $activeMechanism = $matches[1] }
        if ($line -match '^NEXTAUTH_SECRET="?(.*?)"?$') { $NextAuthSecret = $matches[1] }
        if ($line -match '^LICENSE_SECRET="?(.*?)"?$') { $LicenseSecret = $matches[1] }
    }
}

if (![string]::IsNullOrWhiteSpace($SqlHost) -and ![string]::IsNullOrWhiteSpace($SqlDb) -and ![string]::IsNullOrWhiteSpace($SqlUser)) {
    if ([string]::IsNullOrWhiteSpace($SqlPort)) { $SqlPort = "1433" }

    # Si es instancia nombrada, descubrir su puerto TCP real para que Node.js (mssql) conecte sin depender de SQLBrowser
    if ($SqlHost -match '^([^\\]+)\\(.+)$') {
        $instPart = $matches[2]
        try {
            $regTcp = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL*.$instPart\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($regTcp -and -not [string]::IsNullOrWhiteSpace($regTcp.TcpPort)) {
                $SqlPort = $regTcp.TcpPort.Trim()
                Write-Log "Puerto TCP real detectado para la instancia [$instPart]: $SqlPort"
            }
        } catch {}
    }

    $targetSqlHost = $SqlHost
    if ($SqlHost -eq $env:COMPUTERNAME -or $SqlHost.ToLower() -eq "localhost" -or $SqlHost -eq "." -or $SqlHost -eq "(local)") {
        $targetSqlHost = "127.0.0.1"
    }
    $EncodedUser = [System.Uri]::EscapeDataString($SqlUser)
    $EncodedPass = [System.Uri]::EscapeDataString($SqlPass)
    $DatabaseUrlSql = "sqlserver://$($targetSqlHost):$($SqlPort);database=$($SqlDb);user=$($EncodedUser);password=$($EncodedPass);encrypt=false;trustServerCertificate=true"

    Write-Log "Configurando archivo .env en el Servidor Web apuntando a SQL Server [$targetSqlHost : $SqlDb]..."
    $NewEnvLines = @(
        "DATABASE_PROVIDER=`"sqlserver`"",
        "DATABASE_URL_SQLSERVER=`"$DatabaseUrlSql`"",
        "DATABASE_URL=`"$DatabaseUrlSql`"",
        "NEXTAUTH_SECRET=`"$NextAuthSecret`"",
        "LICENSE_SECRET=`"$LicenseSecret`"",
        "NEXTAUTH_URL=`"http://localhost:$OldSitePort`"",
        "PORT=`"$OldNextjsPort`"",
        "EXECUTION_MECHANISM=`"$activeMechanism`""
    ) -join "`r`n"
    Set-Content -Path $EnvFile -Value ($NewEnvLines + "`r`n") -Encoding UTF8
} elseif (-not (Test-Path $EnvFile)) {
    Write-Log "ERROR CRITICO: No existe archivo .env ni se proporcionaron credenciales del servidor SQL Server." "ERROR"
    Show-Alert "Configuracion Faltante" "No se encontro archivo .env en el Servidor Web ni se recibieron parametros de conexion a SQL Server."
    exit 1
} else {
    Write-Log "Extrayendo parametros de conexion desde .env existente del Servidor Web..."
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
}

Write-Log "[MODO EXCLUSIVO SITIO WEB] Se omite la ejecucion de scripts DDL/SPs (la Base de Datos se gestiona con su propio instalador)."

# =============================================================================
# PASO 2: ACTUALIZAR PUERTO EN web.config SI EXISTE
# =============================================================================
$WebConfigPath = "$TargetDir\web.config"
if (Test-Path $WebConfigPath) {
    $configContent = Get-Content $WebConfigPath -Raw
    $configContent = $configContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$OldNextjsPort/{R:1}`""
    Set-Content -Path $WebConfigPath -Value $configContent -Encoding UTF8
}

# =============================================================================
# PASO 3: REINICIAR / ACTUALIZAR MECANISMO DE EJECUCIÓN WEB (SERVICE O TASK SCHEDULER)
# =============================================================================
Write-Log "Mecanismo de ejecucion activo en Servidor Web: $activeMechanism"

# Detener instancias previas ordenadamente (Graceful Shutdown para prevenir pérdida de datos)
function Stop-KorexServiceGraceful($name, $timeoutSec = 10) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Log "Solicitando detencion limpia y ordenada de servicio $name..."
        try {
            Stop-Service -Name $name -NoWait -ErrorAction SilentlyContinue
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            while ($sw.Elapsed.TotalSeconds -lt $timeoutSec) {
                Start-Sleep -Milliseconds 500
                $svc.Refresh()
                if ($svc.Status -eq 'Stopped') {
                    Write-Log "Servicio $name detenido ordenadamente."
                    return $true
                }
            }
            Write-Log "Tiempo de espera superado ($timeoutSec s) al detener servicio $name." "WARN"
        } catch {
            Write-Log "Aviso al detener servicio ${name}: $_" "WARN"
        }
    }
    return $false
}

Stop-KorexServiceGraceful "Korex_SQLServer_Service"
Stop-KorexServiceGraceful "Korex_NextJS"
Stop-KorexServiceGraceful "korex_nextjs.exe"

# Cierre ordenado de procesos Node.js de la aplicación con tiempo de gracia
Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object {
    try { $_.Path -like "*$TargetDir*" } catch { $false }
} | ForEach-Object {
    Write-Log "Solicitando cierre ordenado de proceso Node.js (PID: $($_.Id)) en $TargetDir..."
    try { $_.CloseMainWindow() | Out-Null } catch {}
    if (-not $_.WaitForExit(3000)) {
        try { Stop-Process -Id $_.Id -ErrorAction SilentlyContinue } catch {}
    }
}

$taskMgrScript = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
if (Test-Path $taskMgrScript) {
    & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$taskMgrScript" -Action Stop -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort > $null 2>&1
}

Start-Sleep -Seconds 2

$startedOk = $false

if ($activeMechanism -eq "TASK_SCHEDULER") {
    Write-Log "Actualizando y reiniciando via Windows Task Scheduler (Korex SQLServer - Startup)..."
    if (Test-Path $taskMgrScript) {
        & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$taskMgrScript" -Action Register -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 2
        & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$taskMgrScript" -Action Start -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
        Start-Sleep -Seconds 3

        $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($chk) {
            Write-Log "Task Scheduler Web reiniciado exitosamente. Backend escuchando en puerto $OldNextjsPort (PID: $($chk.OwningProcess))."
            $startedOk = $true
        }
    }
} else {
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
            for ($w = 0; $w -lt 12; $w++) {
                Start-Sleep -Seconds 1
                $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($chk) {
                    Write-Log "Servicio de Windows Web ($($svc.Name)) activo y escuchando en puerto $OldNextjsPort (PID: $($chk.OwningProcess))."
                    $startedOk = $true
                    break
                }
            }
        }
    } catch {
        Write-Log "Aviso al interactuar con el Servicio Windows Web: $_" "WARN"
    }

    if (-not $startedOk) {
        Write-Log "Aviso: Servicio Windows Web fallo al reiniciar. Activando fallback a Task Scheduler..." "WARN"
        if (Test-Path $taskMgrScript) {
            & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$taskMgrScript" -Action Register -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 2
            & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$taskMgrScript" -Action Start -Engine SQLSERVER -TargetDir "$TargetDir" -Port $OldNextjsPort >> $LogFile 2>&1
            Start-Sleep -Seconds 3
            $chk = Get-NetTCPConnection -LocalPort $OldNextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($chk) {
                Write-Log "Fallback a Task Scheduler Web completado exitosamente en puerto $OldNextjsPort."
                $startedOk = $true
                Add-Content -Path $EnvFile -Value "EXECUTION_MECHANISM=`"TASK_SCHEDULER`"" -Encoding UTF8
            }
        }
    }
}

if (-not $startedOk) {
    Write-Log "ERROR CRITICO: No fue posible reanudar el backend Next.js tras la actualizacion." "ERROR"
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
    Show-Alert "Fallo de Inicio del Sitio Web" "El proyecto web se actualizo pero no fue posible reiniciar el proceso en el puerto $OldNextjsPort.`n`nPor favor revise $LogFile."
    exit 1
}

# =============================================================================
# PASO 3.5: ASEGURAR REGISTRO DEL SITIO WEB EN IIS APUNTANDO A $TargetDir
# =============================================================================
$SiteName = "Korex"
Write-Log "Verificando/registrando Sitio Web '$SiteName' en IIS (Puerto $OldSitePort -> $TargetDir)..."
$AppCmd = "$env:windir\system32\inetsrv\appcmd.exe"
if (Test-Path $AppCmd) {
    try {
        & $AppCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>&1 | Out-Null
        & $AppCmd delete site /site.name:"$SiteName" 2>&1 | Out-Null
        & $AppCmd add site /name:"$SiteName" /bindings:"http/*:$($OldSitePort):" /physicalPath:"$TargetDir" 2>&1 | Out-Null
        & $AppCmd start site /site.name:"$SiteName" 2>&1 | Out-Null
        Write-Log "Sitio IIS '$SiteName' activo en http://localhost:$OldSitePort/ -> $TargetDir"
    } catch {
        Write-Log "Aviso configurando sitio IIS con appcmd: $_" "WARN"
    }
}

# =============================================================================
# PASO 4: EJECUTAR DIAGNÓSTICO DEL SERVIDOR WEB Y CONECTIVIDAD A SQL SERVER
# =============================================================================
$DiagScript = Join-Path $TargetDir "deploy\Korex_Diagnostics_Engine.ps1"
if (Test-Path $DiagScript) {
    & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "$DiagScript" `
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

Write-Log "ACTUALIZACION DEL PROYECTO WEB NEXT.JS COMPLETADA EXITOSAMENTE."
