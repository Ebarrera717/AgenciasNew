param(
    [string]$SqlHost,
    [string]$SqlPort,
    [string]$SqlDb,
    [string]$SqlUser,
    [string]$SqlPass
)

$TargetDir = $PSScriptRoot
if (Test-Path "$TargetDir\deploy\update_db_sqlserver.js") {
    # Estamos en la raiz del paquete instalado
} elseif (Test-Path (Join-Path (Split-Path -Parent $PSScriptRoot) "deploy\update_db_sqlserver.js")) {
    $TargetDir = Split-Path -Parent $PSScriptRoot
}
Set-Location -Path $TargetDir
$ProgressPreference = 'SilentlyContinue'

$LogFile = "$TargetDir\install_sqlserver_db_log.txt"
"`n======================================================" >> $LogFile
"  LOG DE ACTUALIZACION DE BASE DE DATOS (SQL SERVER)  " >> $LogFile
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
    Write-Log "ERROR CRITICO EN ACTUALIZADOR BD SQL SERVER (Linea ${eLine}): ${eMsg}" "ERROR"
    Show-Alert "Error en Actualizador de Base de Datos" "Ocurrio un error en la linea ${eLine}:`n`nDetalle: ${eMsg}`n`nConsulte el log en:`n$LogFile"
    exit 1
}

Write-Log "Iniciando proceso exclusivo de Base de Datos para SQL Server..."
$env:Path += ";C:\Program Files\nodejs;C:\Program Files (x86)\nodejs;$TargetDir"

$EnvFile = "$TargetDir\.env"

# Si no se recibieron parametros por linea de comandos, intentar leer .env existente
if ([string]::IsNullOrWhiteSpace($SqlHost) -or [string]::IsNullOrWhiteSpace($SqlDb) -or [string]::IsNullOrWhiteSpace($SqlUser)) {
    if (Test-Path $EnvFile) {
        Write-Log "Leyendo parametros de conexion desde .env local..."
        $DbUrl = ""
        foreach ($line in (Get-Content $EnvFile)) {
            if ($line -match '^DATABASE_URL="(.*)"') { $DbUrl = $matches[1] }
            if ($line -match '^DATABASE_URL_SQLSERVER="(.*)"') { $DbUrl = $matches[1] }
        }
        if (-not [string]::IsNullOrWhiteSpace($DbUrl)) {
            $cleanDbUrl = $DbUrl -replace '^(sqlserver|mssql)://', ''
            $parts = $cleanDbUrl -split ';'
            $serverPart = $parts[0]
            if ($serverPart -match '^([^:]+):([0-9]+)$') {
                if ([string]::IsNullOrWhiteSpace($SqlHost)) { $SqlHost = $matches[1] }
                if ([string]::IsNullOrWhiteSpace($SqlPort)) { $SqlPort = $matches[2] }
            } else {
                if ([string]::IsNullOrWhiteSpace($SqlHost)) { $SqlHost = $serverPart }
                if ([string]::IsNullOrWhiteSpace($SqlPort)) { $SqlPort = "1433" }
            }
            foreach ($part in $parts) {
                if ($part -match '^(?i)database\s*=\s*(.*)$' -and [string]::IsNullOrWhiteSpace($SqlDb)) { $SqlDb = $matches[1].Trim() }
                if ($part -match '^(?i)(user|user id|uid)\s*=\s*(.*)$' -and [string]::IsNullOrWhiteSpace($SqlUser)) { $SqlUser = [System.Uri]::UnescapeDataString($matches[2].Trim()) }
                if ($part -match '^(?i)(password|pwd)\s*=\s*(.*)$' -and [string]::IsNullOrWhiteSpace($SqlPass)) { $SqlPass = [System.Uri]::UnescapeDataString($matches[2].Trim()) }
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($SqlPort)) { $SqlPort = "1433" }

if ([string]::IsNullOrWhiteSpace($SqlHost) -or [string]::IsNullOrWhiteSpace($SqlDb) -or [string]::IsNullOrWhiteSpace($SqlUser)) {
    Write-Log "ERROR CRITICO: Faltan parametros de conexion a SQL Server (Servidor, Nombre de Base de Datos o Usuario)." "ERROR"
    Show-Alert "Datos de Conexion Incompletos" "Debe especificar el Servidor SQL Server, el Nombre de la Base de Datos y las credenciales de acceso."
    exit 1
}

# Si es una instancia nombrada (ej. LAPTOP-M9RF6IM8\AGENCIAS_PRUEBA), habilitar SQLBrowser y detectar puerto TCP real
if ($SqlHost -match '^([^\\]+)\\(.+)$') {
    $hostPart = $matches[1]
    $instPart = $matches[2]
    try {
        $browserSvc = Get-Service -Name "SQLBrowser" -ErrorAction SilentlyContinue
        if ($browserSvc -and $browserSvc.Status -ne 'Running') {
            Set-Service -Name "SQLBrowser" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "SQLBrowser" -ErrorAction SilentlyContinue
            Write-Log "Servicio SQLBrowser iniciado automaticamente para soporte de instancias nombradas."
        }
    } catch {}

    try {
        $regTcp = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL*.$instPart\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($regTcp) {
            if (-not [string]::IsNullOrWhiteSpace($regTcp.TcpPort)) {
                $SqlPort = $regTcp.TcpPort.Trim()
                Write-Log "Puerto TCP real detectado en registro para la instancia [$instPart]: $SqlPort"
            } elseif (-not [string]::IsNullOrWhiteSpace($regTcp.TcpDynamicPorts)) {
                $SqlPort = $regTcp.TcpDynamicPorts.Trim()
                Write-Log "Puerto TCP dinamico detectado en registro para la instancia [$instPart]: $SqlPort"
            }
        }
    } catch {}
}

if ($SqlHost -eq $env:COMPUTERNAME -or $SqlHost.ToLower() -eq "localhost" -or $SqlHost -eq "." -or $SqlHost -eq "(local)") {
    $SqlHost = "127.0.0.1"
}

Write-Log "Destino SQL Server: Servidor=$SqlHost, Puerto=$SqlPort, BaseDeDatos=$SqlDb, Usuario=$SqlUser"

# Definir variables de entorno ANTES de ejecutar update_db_sqlserver.js y korex_updater_guardian.js
$env:DB_ENGINE = "sqlserver"
$env:DB_HOST = $SqlHost
$env:DB_PORT = $SqlPort
$env:DB_NAME = $SqlDb
$env:DB_USER = $SqlUser
$env:DB_PASSWORD = $SqlPass

# =============================================================================
# PASO 1: VERIFICAR / CREAR BASE DE DATOS Y EJECUTAR SCRIPTS DE ACTUALIZACIÓN
# =============================================================================
Write-Log "Ejecutando verificacion/creacion de BD y scripts de actualizacion T-SQL en [$SqlHost / $SqlDb]..."
$UpdaterScript = Join-Path $TargetDir "deploy\update_db_sqlserver.js"
if (-not (Test-Path $UpdaterScript)) {
    Write-Log "ERROR CRITICO: No se encontro $UpdaterScript" "ERROR"
    Show-Alert "Archivo Faltante" "No se encontro el script deploy\update_db_sqlserver.js."
    exit 1
}

# Importante: Usar "DEFAULT" en lugar de "" porque PowerShell 5.1 omite argumentos vacios al invocar ejecutables nativos
node "$UpdaterScript" "$SqlHost" "DEFAULT" "$SqlPort" "$SqlDb" "$SqlUser" "$SqlPass" >> $LogFile 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR CRITICO: Fallo al ejecutar update_db_sqlserver.js en base '$SqlDb' (Exit Code: $LASTEXITCODE)." "ERROR"
    Show-Alert "Error en Base de Datos SQL Server" "No fue posible crear o actualizar la base de datos SQL Server '$SqlDb'.`n`nConsulte el log en:`n$LogFile"
    exit $LASTEXITCODE
}

# =============================================================================
# PASO 2: EJECUTAR VERIFICACIÓN DE OBJETOS CON KOREX UPDATE GUARDIAN
# =============================================================================
Write-Log "Ejecutando verificacion de objetos Korex Update Guardian en SQL Server ($SqlDb)..."

$GuardianScript = Join-Path $TargetDir "scripts\korex_updater_guardian.js"
if (Test-Path $GuardianScript) {
    node "$GuardianScript" >> $LogFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR CRITICO: Korex Update Guardian detecto objetos faltantes o con errores en SQL Server ($SqlDb)." "ERROR"
        Show-Alert "Error de Verificacion Guardian" "El actualizador detecto que uno o mas objetos obligatorios (Tablas/Funciones/SPs) no quedaron creados correctamente en la base '$SqlDb'.`n`nConsulte $LogFile para ver el detalle."
        exit 1
    }
}

# =============================================================================
# PASO 3: GUARDAR CONFIGURACIÓN DE REFERENCIA PARA FUTURAS ACTUALIZACIONES / LICENCIA
# =============================================================================
$EncodedUser = [System.Uri]::EscapeDataString($SqlUser)
$EncodedPass = [System.Uri]::EscapeDataString($SqlPass)
$DatabaseUrlSql = "sqlserver://$($SqlHost):$($SqlPort);database=$($SqlDb);user=$($EncodedUser);password=$($EncodedPass);encrypt=false;trustServerCertificate=true"

if (Test-Path $EnvFile) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item -Path $EnvFile -Destination "$TargetDir\.env.bak_$Timestamp" -Force
}

$EnvContent = @(
    "DATABASE_PROVIDER=`"sqlserver`"",
    "DATABASE_URL_SQLSERVER=`"$DatabaseUrlSql`"",
    "DATABASE_URL=`"$DatabaseUrlSql`"",
    "LICENSE_SECRET=`"Korex_Master_License_Secret_Key_2026_Secure`""
) -join "`r`n"
Set-Content -Path $EnvFile -Value ($EnvContent + "`r`n") -Encoding UTF8

Write-Log "PROCESO DE BASE DE DATOS SQL SERVER [$SqlDb] COMPLETADO EXITOSAMENTE."
