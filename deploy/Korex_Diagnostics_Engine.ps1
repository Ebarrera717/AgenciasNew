<#
.SYNOPSIS
    Korex Diagnostics & Safe Auto-Repair Engine (PostgreSQL & SQL Server).
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("POSTGRESQL", "SQLSERVER")]
    [string]$Engine,

    [ValidateSet("Diagnostico", "Reparacion")]
    [string]$Mode = "Diagnostico",

    [string]$TargetDir = "",

    # Parametros PostgreSQL
    [string]$PgHost = "localhost",
    [string]$PgPort = "5432",
    [string]$PgDb = "agencias_new",
    [string]$PgUser = "postgres",
    [string]$PgPass = "",

    # Parametros SQL Server
    [string]$SqlHost = "127.0.0.1",
    [string]$SqlPort = "1433",
    [string]$SqlDb = "Korex_colaereo",
    [string]$SqlUser = "sa",
    [string]$SqlPass = "zzeusagencias",

    [int]$SitePort = 3000,
    [int]$NextjsPort = 3001,
    [string]$SiteName = "Korex",
    [switch]$GenerateZip,
    [string]$OutputReportDir = ""
)

$ProgressPreference = 'SilentlyContinue'

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $TargetDir = $PSScriptRoot
    if ($TargetDir.EndsWith("\deploy")) {
        $TargetDir = Split-Path $TargetDir -Parent
    }
}
if ([string]::IsNullOrWhiteSpace($OutputReportDir)) {
    $OutputReportDir = Join-Path $TargetDir "Diagnosticos"
}
if (-not (Test-Path $OutputReportDir)) {
    New-Item -ItemType Directory -Path $OutputReportDir -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportHtmlPath = Join-Path $OutputReportDir ("Korex_Diagnostico_" + $Engine + "_" + $Timestamp + ".html")
$ReportZipPath = Join-Path $OutputReportDir ("Korex_Diagnostico_" + $Engine + "_" + $Timestamp + ".zip")
$DiagLogPath = Join-Path $OutputReportDir ("diagnostico_" + $Engine + "_" + $Timestamp + ".log")

$TestResults = [System.Collections.Generic.List[PSCustomObject]]::new()
$IdentifiedIssues = [System.Collections.Generic.List[PSCustomObject]]::new()

function Write-DiagLog($msg, $level = "INFO") {
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$now] [$level] $msg"
    Write-Host $line
    Add-Content -Path $DiagLogPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Add-TestResult($id, $name, $status, $found, $expected, $severity, $action = "", $repairResult = "", $manualAction = "") {
    $item = [PSCustomObject]@{
        Id           = $id
        Name         = $name
        Status       = $status
        Found        = $found
        Expected     = $expected
        Severity     = $severity
        Action       = $action
        RepairResult = $repairResult
        ManualAction = $manualAction
    }
    $TestResults.Add($item)

    if ($status -in @("ERROR", "CRITICAL")) {
        $IdentifiedIssues.Add([PSCustomObject]@{
            Id           = $id
            Name         = $name
            Found        = $found
            Expected     = $expected
            Action       = $action
            RepairResult = $repairResult
            ManualAction = $manualAction
        })
    }
}

Write-DiagLog "================================================================="
Write-DiagLog "  KOREX DIAGNOSTICS & REPAIR ENGINE - INICIO"
Write-DiagLog ("  Motor: " + $Engine + " | Modo: " + $Mode + " | Fecha: " + (Get-Date))
Write-DiagLog ("  Directorio de Aplicacion: " + $TargetDir)
Write-DiagLog "================================================================="

# DOMINIO 1: DIAGNOSTICO DE WINDOWS Y ENTORNO
Write-DiagLog "--- [DOMINIO 1] Evaluando Entorno Windows ---"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$osName = if ($os) { "$($os.Caption) ($($os.Version))" } else { [System.Environment]::OSVersion.ToString() }
$arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
$drive = Get-PSDrive -Name (Split-Path -Qualifier $TargetDir).Replace(":", "") -ErrorAction SilentlyContinue
$freeSpaceGB = if ($drive) { [math]::Round($drive.Free / 1GB, 2) } else { "N/D" }

if ($isAdmin) {
    Add-TestResult "TEST-WIN-001" "Privilegios de Ejecucion" "OK" "Administrador" "Administrador" "OK" "Verificacion de privilegios" "N/A"
} else {
    Add-TestResult "TEST-WIN-001" "Privilegios de Ejecucion" "ERROR" "Usuario Estandar" "Administrador" "CRITICO" "Ejecutar PowerShell como Administrador" "NO CORREGIDO" "Debe ejecutar el instalador o herramienta con clic derecho -> Ejecutar como Administrador."
}

if ($drive -and $drive.Free -ge (2GB)) {
    Add-TestResult "TEST-WIN-002" "Espacio Libre en Disco" "OK" "$freeSpaceGB GB disponibles" "Minimo 2 GB" "OK" "Comprobacion de almacenamiento" "N/A"
} else {
    Add-TestResult "TEST-WIN-002" "Espacio Libre en Disco" "WARN" "$freeSpaceGB GB disponibles" "Minimo 2 GB" "ADVERTENCIA" "Liberar espacio en la unidad de instalacion" "N/A" "Libere espacio en disco para evitar fallos de I/O."
}

# DOMINIO 2: DIAGNOSTICO DE NODE.JS Y NPM
Write-DiagLog "--- [DOMINIO 2] Evaluando Node.js y npm ---"
$nodePath = ""
$nodeVersion = ""
try {
    $nodeVersion = node -v 2>$null
    if ($nodeVersion) {
        $nodePath = (Get-Command node -ErrorAction SilentlyContinue).Source
    }
} catch {}

if (-not $nodeVersion -and (Test-Path "C:\Program Files\nodejs\node.exe")) {
    $env:Path += ";C:\Program Files\nodejs"
    try {
        $nodeVersion = & "C:\Program Files\nodejs\node.exe" -v
        $nodePath = "C:\Program Files\nodejs\node.exe"
    } catch {}
}

if ($nodeVersion) {
    Add-TestResult "TEST-NODE-001" "Disponibilidad de Node.js" "OK" "Detectado: $nodeVersion en $nodePath" "Node.js >= v18" "OK" "Validacion de ejecutable Node.js" "N/A"
} else {
    if ($Mode -eq "Reparacion") {
        Write-DiagLog "Intentando autoreparacion: Descarga e instalacion desatendida de Node.js v20..." "WARN"
        $nodeMsi = "$env:TEMP\node-v20.msi"
        try {
            Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi" -OutFile $nodeMsi -TimeoutSec 30
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$nodeMsi`" /qn /norestart" -Wait -NoNewWindow
            $env:Path += ";C:\Program Files\nodejs"
            $nodeVersion = node -v
            if ($nodeVersion) {
                Add-TestResult "TEST-NODE-001" "Disponibilidad de Node.js" "OK" "Instalado exitosamente ($nodeVersion)" "Node.js >= v18" "ADVERTENCIA" "Descarga e instalacion silenciosa de Node.js v20" "CORREGIDO"
            } else {
                Add-TestResult "TEST-NODE-001" "Disponibilidad de Node.js" "ERROR" "No detectado tras instalacion" "Node.js >= v18" "CRITICO" "Instalacion fallida" "NO CORREGIDO" "Instale Node.js v20 de 64 bits manualmente."
            }
        } catch {
            Add-TestResult "TEST-NODE-001" "Disponibilidad de Node.js" "ERROR" "No instalado ($($_.Exception.Message))" "Node.js >= v18" "CRITICO" "Intento de descarga" "NO CORREGIDO" "Instale Node.js v20 manualmente en el servidor."
        }
    } else {
        Add-TestResult "TEST-NODE-001" "Disponibilidad de Node.js" "ERROR" "No instalado o fuera del PATH" "Node.js >= v18" "CRITICO" "Validacion de Node.js" "N/A" "Instale Node.js v20 LTS en el servidor."
    }
}

# DOMINIO 3: DIAGNOSTICO DE ARCHIVOS Y CONFIGURACION KOREX
Write-DiagLog "--- [DOMINIO 3] Evaluando Archivos de Instalacion Korex ---"
$essentialFiles = @("package.json", "web.config")
$missingFiles = @()
foreach ($f in $essentialFiles) {
    $fullPath = Join-Path $TargetDir $f
    if (-not (Test-Path $fullPath)) {
        $missingFiles += $f
    }
}

if ($missingFiles.Count -eq 0) {
    Add-TestResult "TEST-FILE-001" "Integridad de Archivos Principales" "OK" "Todos los archivos requeridos presentes" "package.json, web.config presentes" "OK" "Inspeccion de directorio" "N/A"
} else {
    Add-TestResult "TEST-FILE-001" "Integridad de Archivos Principales" "ERROR" "Archivos faltantes: $($missingFiles -join ', ')" "Todos los archivos presentes" "CRITICO" "Verificacion de release" "NO CORREGIDO" "Reinstale o copie el paquete completo de release en $TargetDir."
}

$envFile = Join-Path $TargetDir ".env"
$envOk = Test-Path $envFile
if ($envOk) {
    $envContent = Get-Content $envFile -Raw
    $hasDbUrl = $envContent -match 'DATABASE_URL='
    $hasSecret = $envContent -match 'NEXTAUTH_SECRET='
    if ($hasDbUrl -and $hasSecret) {
        Add-TestResult "TEST-CONF-001" "Configuracion de Entorno (.env)" "OK" "Variables de entorno detectadas y parametrizadas" "DATABASE_URL y NEXTAUTH_SECRET presentes" "OK" "Inspeccion de .env" "N/A"
    } else {
        Add-TestResult "TEST-CONF-001" "Configuracion de Entorno (.env)" "WARN" "Archivo .env incompleto" "Variables completas" "ADVERTENCIA" "Completar variables requeridas" "N/A" "Configure DATABASE_URL y NEXTAUTH_SECRET en .env."
    }
} else {
    Add-TestResult "TEST-CONF-001" "Configuracion de Entorno (.env)" "ERROR" "Archivo .env inexistente" "Archivo .env presente" "ERROR" "Inspeccion de .env" "N/A" "El instalador debe generar el archivo .env con la conexion correspondiente."
}

# DOMINIO 4: DIAGNOSTICO DE DEPENDENCIAS Y MODULOS
Write-DiagLog "--- [DOMINIO 4] Evaluando Dependencias y Modulos ---"
$nodeModulesPath = Join-Path $TargetDir "node_modules"
$hasNodeModules = Test-Path $nodeModulesPath
if ($hasNodeModules) {
    Add-TestResult "TEST-DEP-001" "Directorio node_modules" "OK" "Directorio node_modules presente" "node_modules presente" "OK" "Inspeccion de dependencias" "N/A"
} else {
    Add-TestResult "TEST-DEP-001" "Directorio node_modules" "WARN" "node_modules no encontrado en $TargetDir" "node_modules requerido para standalone/next" "ADVERTENCIA" "Validar si es build standalone con dependencias embebidas" "N/A" "Si el build no es standalone monolitico, ejecute npm install en el directorio."
}

# DOMINIO 5: DIAGNOSTICO DE IIS Y APPLICATION POOLS
Write-DiagLog "--- [DOMINIO 5] Evaluando Servidor Web IIS ---"
$iisSvc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if ($iisSvc) {
    if ($iisSvc.Status -eq "Running") {
        Add-TestResult "TEST-IIS-001" "Servicio IIS (W3SVC)" "OK" "Servicio en ejecucion (Running)" "W3SVC Running" "OK" "Inspeccion de servicio" "N/A"
    } else {
        if ($Mode -eq "Reparacion") {
            Write-DiagLog "Intentando autoreparacion: Iniciando servicio W3SVC..." "WARN"
            Start-Service -Name W3SVC -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $iisSvc = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
            if ($iisSvc -and $iisSvc.Status -eq "Running") {
                Add-TestResult "TEST-IIS-001" "Servicio IIS (W3SVC)" "OK" "Servicio iniciado con exito" "W3SVC Running" "ADVERTENCIA" "Start-Service W3SVC" "CORREGIDO"
            } else {
                Add-TestResult "TEST-IIS-001" "Servicio IIS (W3SVC)" "ERROR" "Servicio detenido ($([string]$iisSvc.Status))" "W3SVC Running" "CRITICO" "Start-Service W3SVC" "NO CORREGIDO" "Inicie el servicio de Administracion Web de IIS en services.msc."
            }
        } else {
            Add-TestResult "TEST-IIS-001" "Servicio IIS (W3SVC)" "ERROR" "Servicio detenido ($([string]$iisSvc.Status))" "W3SVC Running" "CRITICO" "Inspeccion de servicio" "N/A" "Inicie el servicio W3SVC en IIS."
        }
    }
} else {
    Add-TestResult "TEST-IIS-001" "Servicio IIS (W3SVC)" "ERROR" "IIS no esta instalado en este equipo" "IIS (W3SVC) Instalado" "CRITICO" "Verificacion de rol IIS" "NO CORREGIDO" "Habilite IIS desde 'Activar o desactivar caracteristicas de Windows'."
}

# DOMINIO 6: DIAGNOSTICO DE ARR Y URL REWRITE (PREVENCION 502.3)
Write-DiagLog "--- [DOMINIO 6] Evaluando ARR y URL Rewrite ---"
$rewriteDll = "$env:SystemRoot\system32\inetsrv\rewrite.dll"
$arrDll = "$env:SystemRoot\system32\inetsrv\requestRouter.dll"
$hasRewrite = Test-Path $rewriteDll
$hasArr = Test-Path $arrDll

if ($hasRewrite) {
    Add-TestResult "TEST-ARR-001" "Modulo URL Rewrite" "OK" "Detectado rewrite.dll en inetsrv" "URL Rewrite instalado" "OK" "Verificacion de modulo IIS" "N/A"
} else {
    Add-TestResult "TEST-ARR-001" "Modulo URL Rewrite" "ERROR" "No detectado rewrite.dll" "URL Rewrite instalado" "CRITICO" "Instalacion de rewrite_amd64.msi" "NO CORREGIDO" "Instale el modulo URL Rewrite de Microsoft para IIS."
}

if ($hasArr) {
    Add-TestResult "TEST-ARR-002" "Modulo ARR (Application Request Routing)" "OK" "Detectado requestRouter.dll en inetsrv" "ARR instalado" "OK" "Verificacion de modulo IIS" "N/A"
} else {
    Add-TestResult "TEST-ARR-002" "Modulo ARR (Application Request Routing)" "ERROR" "No detectado requestRouter.dll" "ARR instalado" "CRITICO" "Instalacion de requestRouter_amd64.msi" "NO CORREGIDO" "Instale ARR 3.0 para IIS."
}

$appCmd = "$env:windir\system32\inetsrv\appcmd.exe"
if (Test-Path $appCmd) {
    $proxyEnabled = $false
    try {
        $proxyConfig = & $appCmd list config -section:system.webServer/proxy 2>$null
        if ($proxyConfig -match 'enabled="true"') {
            $proxyEnabled = $true
        }
    } catch {}

    if ($proxyEnabled) {
        Add-TestResult "TEST-ARR-003" "Habilitacion de Reverse Proxy en IIS" "OK" "Proxy ARR habilitado (enabled=true)" "Proxy enabled=true" "OK" "Verificacion appcmd" "N/A"
    } else {
        if ($Mode -eq "Reparacion") {
            Write-DiagLog "Intentando autoreparacion: Habilitando proxy en appcmd..." "WARN"
            & $appCmd set config -section:system.webServer/proxy /enabled:"True" /commit:apphost 2>&1 | Out-Null
            Add-TestResult "TEST-ARR-003" "Habilitacion de Reverse Proxy en IIS" "OK" "Proxy ARR habilitado exitosamente" "Proxy enabled=true" "ADVERTENCIA" "appcmd set config proxy /enabled:True" "CORREGIDO"
        } else {
            Add-TestResult "TEST-ARR-003" "Habilitacion de Reverse Proxy en IIS" "WARN" "Proxy ARR no habilitado explicitamente" "Proxy enabled=true" "ADVERTENCIA" "Habilitar proxy en IIS ARR" "N/A" "Ejecute appcmd set config -section:system.webServer/proxy /enabled:True."
        }
    }
}

# DOMINIO 7: DIAGNOSTICO DE PUERTOS Y NETWORKING
Write-DiagLog "--- [DOMINIO 7] Evaluando Puertos de Red ($SitePort y $NextjsPort) ---"
function Check-PortListening($port) {
    try {
        $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        return $conn
    } catch {
        return $null
    }
}

$sitePortConn = Check-PortListening $SitePort
$nextPortConn = Check-PortListening $NextjsPort

if ($sitePortConn) {
    Add-TestResult "TEST-PORT-001" "Puerto Frontend IIS ($SitePort)" "OK" "Puerto $SitePort escuchando (PID: $($sitePortConn.OwningProcess))" "Puerto $SitePort escuchando" "OK" "Inspeccion de puertos TCP" "N/A"
} else {
    Add-TestResult "TEST-PORT-001" "Puerto Frontend IIS ($SitePort)" "WARN" "Puerto $SitePort no detectado en escucha" "Puerto $SitePort escuchando" "ADVERTENCIA" "Verificar sitio IIS" "N/A" "Asegurese de que el sitio Korex en IIS este iniciado en el puerto $SitePort."
}

if ($nextPortConn) {
    $procInfo = Get-Process -Id $nextPortConn.OwningProcess -ErrorAction SilentlyContinue
    $procName = if ($procInfo) { $procInfo.ProcessName } else { "Desconocido" }
    Add-TestResult "TEST-PORT-002" "Puerto Backend Node.js ($NextjsPort)" "OK" "Puerto $NextjsPort escuchando por '$procName' (PID: $($nextPortConn.OwningProcess))" "Puerto $NextjsPort escuchando" "OK" "Inspeccion de puertos TCP" "N/A"
} else {
    Add-TestResult "TEST-PORT-002" "Puerto Backend Node.js ($NextjsPort)" "WARN" "Puerto $NextjsPort no esta escuchando" "Puerto $NextjsPort escuchando" "ADVERTENCIA" "Verificar servicio Korex_NextJS" "N/A" "Inicie el servicio de Windows Korex_NextJS o ejecute node server.js."
}

# DOMINIO 8: DIAGNOSTICO DEL PROCESO KOREX (WINDOWS SERVICE / TASK SCHEDULER)
Write-DiagLog "--- [DOMINIO 8] Evaluando Mecanismo de Control del Proceso Korex (Servicio / Task Scheduler) ---"
$svcName = if ($Engine -eq "SQLSERVER") { "Korex_SQLServer_Service" } else { "Korex_NextJS" }
$taskName = if ($Engine -eq "SQLSERVER") { "Korex SQLServer - Startup" } else { "Korex NextJS - Startup" }

$activeExec = "DESCONOCIDO"
$envFileCheck = Join-Path $TargetDir ".env"
if (Test-Path $envFileCheck) {
    $eLines = Get-Content $envFileCheck
    foreach ($el in $eLines) {
        if ($el -match '^EXECUTION_MECHANISM="?(TASK_SCHEDULER|WINDOWS_SERVICE)"?') {
            $activeExec = $matches[1]
        }
    }
}

$svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
if (-not $svc) { $svc = Get-Service -Name "korex_nextjs.exe" -ErrorAction SilentlyContinue }
if (-not $svc) { $svc = Get-Service -Name "Korex_NextJS" -ErrorAction SilentlyContinue }

$taskExists = $false
$taskState = "No Registrada"
try {
    if (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) {
        $t = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($t) { $taskExists = $true; $taskState = [string]$t.State }
    } else {
        $out = cmd.exe /c "schtasks.exe /query /tn `"$taskName`" /fo csv /nh" 2>&1
        if ($LASTEXITCODE -eq 0) { $taskExists = $true; $taskState = "Registrada" }
    }
} catch {}

$backendPortActive = $false
$backendPid = 0
try {
    $bConn = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($bConn) {
        $backendPortActive = $true
        $backendPid = $bConn.OwningProcess
    }
} catch {}

$svcIsRunning = $false
try {
    if ($svc -and $svc.Status -eq "Running") { $svcIsRunning = $true }
} catch {}

if ($svcIsRunning -and $backendPortActive) {
    Add-TestResult "TEST-PROC-001" "Mecanismo de Ejecución Activo (Windows Service)" "OK" "Servicio $($svc.Name) en ejecución y escuchando en puerto $NextjsPort (PID: $backendPid)" "Servicio o Tarea en ejecución" "OK" "Verificación de servicio" "N/A"
} elseif ($taskExists -and $backendPortActive) {
    Add-TestResult "TEST-PROC-001" "Mecanismo de Ejecución Activo (Task Scheduler)" "OK" "Tarea '$taskName' activa ($taskState) y escuchando en puerto $NextjsPort (PID: $backendPid)" "Servicio o Tarea en ejecución" "OK" "Verificación de tarea programada" "N/A"
} elseif ($backendPortActive) {
    Add-TestResult "TEST-PROC-001" "Proceso Backend Node.js" "OK" "Proceso Node escuchando activamente en puerto $NextjsPort (PID: $backendPid)" "Puerto $NextjsPort escuchando" "OK" "Inspección de puertos" "N/A"
} else {
    # Backend no responde -> evaluar autoreparación
    if ($Mode -eq "Reparacion") {
        Write-DiagLog "Intentando autoreparación del proceso Korex..." "WARN"
        $repaired = $false
        
        # 1. Intentar Servicio si existe
        if ($svc) {
            try {
                Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 3
                $svcRef = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
                if ($svcRef -and $svcRef.Status -eq "Running") {
                    $bConn2 = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($bConn2) { $repaired = $true; $backendPid = $bConn2.OwningProcess }
                }
            } catch {}
        }
        
        # 2. Si no reparó, intentar Task Scheduler
        if (-not $repaired) {
            $taskMgr = Join-Path $TargetDir "deploy\task_scheduler_manager.ps1"
            if (Test-Path $taskMgr) {
                Write-DiagLog "Reintentando arranque mediante Task Scheduler..." "WARN"
                & powershell.exe -ExecutionPolicy Bypass -File "$taskMgr" -Action Start -Engine $Engine -TargetDir "$TargetDir" -Port $NextjsPort > $null 2>&1
                Start-Sleep -Seconds 3
                $bConn3 = Get-NetTCPConnection -LocalPort $NextjsPort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($bConn3) { $repaired = $true; $backendPid = $bConn3.OwningProcess }
            }
        }
        
        if ($repaired) {
            Add-TestResult "TEST-PROC-001" "Control de Proceso Korex" "OK" "Proceso backend restablecido con éxito en puerto $NextjsPort (PID: $backendPid)" "Proceso activo" "ADVERTENCIA" "Autoreparación de proceso" "CORREGIDO"
        } else {
            $errSnippet = "No se detectó proceso escuchando en puerto $NextjsPort."
            $daemonErrLog = Join-Path $TargetDir ("daemon\" + [string]$svcName + ".err.log")
            if (Test-Path $daemonErrLog) {
                $errSnippet += " Log daemon: " + ((Get-Content $daemonErrLog -Tail 5) -join " | ")
            }
            Add-TestResult "TEST-PROC-001" "Control de Proceso Korex" "ERROR" "No fue posible iniciar el backend como Servicio ni como Task Scheduler. $errSnippet" "Proceso activo en puerto $NextjsPort" "CRITICO" "Verificación de políticas de seguridad" "NO CORREGIDO" "Revise que el puerto $NextjsPort no esté bloqueado y los permisos de ejecución de Node.js."
        }
    } else {
        Add-TestResult "TEST-PROC-001" "Control de Proceso Korex" "ERROR" "Servicio o Tarea detenida. Puerto $NextjsPort no responde." "Proceso activo" "ERROR" "Verificación de proceso" "N/A" "Inicie el servicio $($svcName) o ejecute la tarea '$taskName'."
    }
}

# DOMINIO 9: DIAGNOSTICO EXCLUSIVO DE BASE DE DATOS
Write-DiagLog "--- [DOMINIO 9] Evaluando Conectividad y Estructura de Base de Datos ($Engine) ---"

if ($Engine -eq "POSTGRESQL") {
    Write-DiagLog "Comprobando conexion PostgreSQL en $($PgHost):$($PgPort) (Base: $PgDb)..."
    $pgTcpClient = New-Object System.Net.Sockets.TcpClient
    $pgConnected = $false
    try {
        $asyncConnect = $pgTcpClient.BeginConnect($PgHost, [int]$PgPort, $null, $null)
        $waitSuccess = $asyncConnect.AsyncWaitHandle.WaitOne(3000, $false)
        if ($waitSuccess) {
            $pgTcpClient.EndConnect($asyncConnect)
            $pgConnected = $true
        }
    } catch {} finally {
        $pgTcpClient.Close()
    }

    if ($pgConnected) {
        Add-TestResult "TEST-DB-PG-001" "Conectividad TCP PostgreSQL" "OK" "Conexion TCP exitosa en $($PgHost):$($PgPort)" "Puerto PostgreSQL accesible" "OK" "Socket TCP Connect" "N/A"
    } else {
        Add-TestResult "TEST-DB-PG-001" "Conectividad TCP PostgreSQL" "ERROR" "No se pudo conectar a PostgreSQL en $($PgHost):$($PgPort)" "Puerto PostgreSQL accesible" "CRITICO" "Socket TCP Connect" "NO CORREGIDO" "Verifique que el servicio de PostgreSQL este activo y el puerto $PgPort este abierto en el Firewall."
    }
}
elseif ($Engine -eq "SQLSERVER") {
    Write-DiagLog "Comprobando conexion SQL Server en $($SqlHost):$($SqlPort) (Base: $SqlDb)..."
    $serverSpec = if ($SqlPort -and $SqlPort -ne "1433" -and $SqlHost -notlike "*,*" -and $SqlHost -notlike "*\*") { "$SqlHost,$SqlPort" } else { $SqlHost }
    $connStr = "Server=$serverSpec;Database=$SqlDb;User Id=$SqlUser;Password=$SqlPass;Encrypt=False;TrustServerCertificate=True;Connection Timeout=6;"
    
    $sqlConnOk = $false
    $sqlTableCount = 0
    $sqlErr = ""
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');"
        $sqlTableCount = [int]$cmd.ExecuteScalar()
        $conn.Close()
        $sqlConnOk = $true
    } catch {
        $sqlErr = $_.Exception.Message
    }

    if ($sqlConnOk) {
        Add-TestResult "TEST-DB-SQL-001" "Conectividad y Estructura SQL Server" "OK" "Conectado exitosamente a [$SqlDb] ($sqlTableCount tablas dbo encontradas)" "Conexion exitosa y base existente" "OK" "SqlConnection Open + Query" "N/A"
    } else {
        Add-TestResult "TEST-DB-SQL-001" "Conectividad y Estructura SQL Server" "ERROR" "Fallo de conexion a SQL Server [$SqlDb]: $sqlErr" "Base creada/restaurada previamente" "CRITICO" "SqlConnection Open" "NO CORREGIDO" "REGLA OBLIGATORIA: La base de datos SQL Server [$SqlDb] NO se crea automaticamente. Debe restaurarla desde el backup inicial o crearla previamente antes de instalar."
    }
}

# DOMINIO 10: DIAGNOSTICO HTTP 502.3 PREVENCION
Write-DiagLog "--- [DOMINIO 10] Evaluando Prevencion HTTP 502.3 y Proxy Inverso ---"
$webConfigPath = Join-Path $TargetDir "web.config"
if (Test-Path $webConfigPath) {
    $wcContent = Get-Content $webConfigPath -Raw
    $hasProxyRule = $wcContent -match 'action type="Rewrite" url="http://127\.0\.0\.1:(\d+)/\{R:1\}"'
    if ($hasProxyRule) {
        $configuredPort = $matches[1]
        if ($configuredPort -eq "$NextjsPort") {
            Add-TestResult "TEST-502-001" "Sincronizacion de Puerto en web.config" "OK" "Proxy configurado correctamente hacia http://127.0.0.1:$NextjsPort" "Puerto configurado coincide con backend ($NextjsPort)" "OK" "Inspeccion de web.config" "N/A"
        } else {
            if ($Mode -eq "Reparacion") {
                Write-DiagLog "Intentando autoreparacion: Corrigiendo puerto en web.config ($configuredPort -> $NextjsPort)..." "WARN"
                $newWc = $wcContent -replace 'url="http://127\.0\.0\.1:\d+/{R:1}"', "url=`"http://127.0.0.1:$NextjsPort/{R:1}`""
                Set-Content -Path $webConfigPath -Value $newWc -Encoding UTF8
                Add-TestResult "TEST-502-001" "Sincronizacion de Puerto en web.config" "OK" "Puerto corregido a $NextjsPort en web.config" "Puerto sincronizado" "ADVERTENCIA" "Reemplazo de puerto en web.config" "CORREGIDO"
            } else {
                Add-TestResult "TEST-502-001" "Sincronizacion de Puerto en web.config" "ERROR" "Puerto descalzado: web.config apunta a $configuredPort pero Node escucha en $NextjsPort" "web.config apuntando a $NextjsPort" "CRITICO" "Inspeccion de web.config" "N/A" "Corrija el puerto de reescritura en web.config para que apunte al puerto $NextjsPort de Node.js."
            }
        }
    } else {
        Add-TestResult "TEST-502-001" "Sincronizacion de Puerto en web.config" "WARN" "No se detecto regla estandar de reescritura en web.config" "Regla de reescritura presente" "ADVERTENCIA" "Inspeccion de web.config" "N/A" "Verifique las reglas de Reverse Proxy en web.config."
    }
} else {
    Add-TestResult "TEST-502-001" "Sincronizacion de Puerto en web.config" "ERROR" "web.config no existe en $TargetDir" "web.config presente" "CRITICO" "Inspeccion de archivo" "NO CORREGIDO" "Copie el archivo web.config al directorio de instalacion."
}

# DOMINIO 11: PRUEBA FUNCIONAL END-TO-END
Write-DiagLog "--- [DOMINIO 11] Ejecutando Prueba Funcional End-to-End ---"
$httpTestPassed = $false
$httpStatus = "N/D"
$testUrls = @("http://localhost:$SitePort/", "http://127.0.0.1:$SitePort/")

foreach ($u in $testUrls) {
    try {
        $res = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $httpStatus = $res.StatusCode
        if ($res.StatusCode -ge 200 -and $res.StatusCode -lt 400) {
            $httpTestPassed = $true
            break
        }
    } catch {
        if ($_.Exception.Response) {
            $httpStatus = [int]$_.Exception.Response.StatusCode
        }
    }
}

if ($httpTestPassed) {
    Add-TestResult "TEST-E2E-001" "Respuesta HTTP End-to-End" "OK" "HTTP $httpStatus recibido en http://localhost:$SitePort/" "HTTP 200/30x" "OK" "Invoke-WebRequest a Portal" "N/A"
} else {
    Add-TestResult "TEST-E2E-001" "Respuesta HTTP End-to-End" "WARN" "Respuesta HTTP: $httpStatus (Portal no responde o requiere autenticacion/servicio)" "HTTP 200" "ADVERTENCIA" "Invoke-WebRequest" "N/A" "Asegurese de que los servicios IIS y Korex_NextJS esten iniciados para verificar la respuesta en navegador."
}

# GENERACION DE REPORTE HTML
Write-DiagLog "--- Generando Reporte HTML de Diagnostico ---"

$htmlRows = ""
foreach ($t in $TestResults) {
    $badgeClass = "background-color: #6B7280; color: white;"
    if ($t.Status -eq "OK") { $badgeClass = "background-color: #10B981; color: white;" }
    elseif ($t.Status -eq "WARN") { $badgeClass = "background-color: #F59E0B; color: black;" }
    elseif ($t.Status -eq "ERROR") { $badgeClass = "background-color: #EF4444; color: white;" }
    elseif ($t.Status -eq "CRITICAL") { $badgeClass = "background-color: #991B1B; color: white;" }

    $repairBadge = "<span style='color: #9CA3AF;'>N/A</span>"
    if ($t.RepairResult -eq "CORREGIDO") { $repairBadge = "<span style='color: #10B981; font-weight: bold;'>OK CORREGIDO</span>" }
    elseif ($t.RepairResult -eq "NO CORREGIDO") { $repairBadge = "<span style='color: #EF4444; font-weight: bold;'>NO CORREGIDO</span>" }

    $manualHelp = ""
    if ($t.ManualAction) {
        $manualHelp = "<div style='font-size: 11px; color: #DC2626; margin-top: 4px;'><strong>Accion Requerida:</strong> " + [string]$t.ManualAction + "</div>"
    }

    $htmlRows += "<tr>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; font-family: monospace; font-weight: bold;'>" + $t.Id + "</td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB;'><strong>" + $t.Name + "</strong>" + $manualHelp + "</td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; text-align: center;'><span style='display: inline-block; padding: 3px 8px; border-radius: 9999px; font-size: 12px; font-weight: bold; " + $badgeClass + "'>" + $t.Status + "</span></td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; font-size: 12px;'>" + $t.Found + "</td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; font-size: 12px; color: #4B5563;'>" + $t.Expected + "</td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; font-size: 12px;'>" + $t.Action + "</td>" +
        "<td style='padding: 10px; border-bottom: 1px solid #E5E7EB; text-align: center;'>" + $repairBadge + "</td>" +
        "</tr>"
}

$summaryErrors = ($TestResults | Where-Object { $_.Status -in @("ERROR", "CRITICAL") }).Count
$summaryWarnings = ($TestResults | Where-Object { $_.Status -eq "WARN" }).Count
$summaryOk = ($TestResults | Where-Object { $_.Status -eq "OK" }).Count
$globalStatusText = if ($summaryErrors -eq 0) { "SISTEMA SALUDABLE / LISTO" } else { "SE REQUIERE ATENCION" }
$globalStatusColor = if ($summaryErrors -eq 0) { "#10B981" } else { "#EF4444" }
$sanitizedDbServer = if ($Engine -eq "POSTGRESQL") { ($PgHost + ":" + $PgPort + " (BD: " + $PgDb + ", User: " + $PgUser + ")") } else { ($SqlHost + ":" + $SqlPort + " (BD: " + $SqlDb + ", User: " + $SqlUser + ")") }

$htmlHeader = "<!DOCTYPE html><html lang='es'><head><meta charset='UTF-8'><title>Reporte Diagnostico Korex</title>" +
    "<style>body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #F3F4F6; margin: 0; padding: 20px; color: #1F2937; }" +
    ".container { max-width: 1100px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); overflow: hidden; }" +
    ".header { background: #1E293B; color: white; padding: 24px 32px; display: flex; justify-content: space-between; align-items: center; }" +
    ".status-banner { background: " + $globalStatusColor + "; color: white; padding: 12px 32px; font-weight: bold; display: flex; justify-content: space-between; font-size: 14px; }" +
    ".grid-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; padding: 24px 32px; background: #F8FAFC; border-bottom: 1px solid #E2E8F0; }" +
    ".card-info { background: white; padding: 12px 16px; border-radius: 8px; border: 1px solid #E2E8F0; }" +
    "table { width: 100%; border-collapse: collapse; text-align: left; }" +
    "th { background-color: #F1F5F9; padding: 12px 10px; font-size: 12px; font-weight: 700; color: #475569; text-transform: uppercase; border-bottom: 2px solid #CBD5E1; }" +
    ".footer { background: #F8FAFC; padding: 16px 32px; text-align: center; font-size: 12px; color: #64748B; border-top: 1px solid #E2E8F0; }</style></head><body>"

$htmlBody = "<div class='container'><div class='header'><div><h1 style='margin:0;font-size:22px;'>Informe Tecnico de Diagnostico y Autoreparacion Korex</h1>" +
    "<div style='font-size:12px;color:#94A3B8;margin-top:4px;'>Generado el: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " | Motor: <strong>" + $Engine + "</strong> | Modo: <strong>" + $Mode + "</strong></div></div>" +
    "<div style='font-size:20px;font-weight:bold;color:#38BDF8;'>KOREX PLATFORM</div></div>" +
    "<div class='status-banner'><div>ESTADO GLOBAL: " + $globalStatusText + "</div><div>Pruebas OK: " + $summaryOk + " | Advertencias: " + $summaryWarnings + " | Errores: " + $summaryErrors + "</div></div>" +
    "<div class='grid-info'>" +
    "<div class='card-info'><div style='font-size:11px;color:#64748B;font-weight:600;'>SISTEMA OPERATIVO</div><div style='font-size:14px;font-weight:700;margin-top:2px;'>" + $osName + " (" + $arch + ")</div></div>" +
    "<div class='card-info'><div style='font-size:11px;color:#64748B;font-weight:600;'>DIRECTORIO KOREX</div><div style='font-size:14px;font-weight:700;margin-top:2px;'>" + $TargetDir + "</div></div>" +
    "<div class='card-info'><div style='font-size:11px;color:#64748B;font-weight:600;'>BASE DE DATOS (" + $Engine + ")</div><div style='font-size:14px;font-weight:700;margin-top:2px;'>" + $sanitizedDbServer + "</div></div>" +
    "<div class='card-info'><div style='font-size:11px;color:#64748B;font-weight:600;'>PUERTOS</div><div style='font-size:14px;font-weight:700;margin-top:2px;'>IIS: " + $SitePort + " | Node: " + $NextjsPort + "</div></div>" +
    "</div><div style='padding:20px 32px 12px;font-size:16px;font-weight:700;'>Resultados Detallados de Verificacion por Dominios</div>" +
    "<div style='overflow-x:auto;padding:0 32px 24px;'><table><thead><tr><th>ID</th><th>Prueba</th><th style='text-align:center;'>Estado</th><th>Valor Encontrado</th><th>Valor Esperado</th><th>Accion Realizada</th><th style='text-align:center;'>Reparacion</th></tr></thead>" +
    "<tbody>" + $htmlRows + "</tbody></table></div>" +
    "<div class='footer'>Korex Multi-Engine Diagnostics Framework &bull; Aislamiento Estricto PostgreSQL vs SQL Server &bull; Confidencial y Sanitizado</div></div></body></html>"

Set-Content -Path $ReportHtmlPath -Value ($htmlHeader + $htmlBody) -Encoding UTF8
Write-DiagLog ("Reporte HTML guardado exitosamente en: " + $ReportHtmlPath)

# GENERACION DE PAQUETE ZIP SANITIZADO
if ($GenerateZip) {
    Write-DiagLog "--- Generando Paquete de Soporte Remoto ZIP Sanitizado ---"
    $tempZipDir = Join-Path $env:TEMP ("Korex_Support_" + $Timestamp)
    if (Test-Path $tempZipDir) { Remove-Item $tempZipDir -Recurse -Force | Out-Null }
    
    $folderReporte = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Reporte") -Force
    $folderLogs = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Logs") -Force
    $folderConf = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Configuracion_Sanitizada") -Force
    $folderTests = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Resultados_Pruebas") -Force
    $folderSys = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Informacion_Sistema") -Force
    $folderIIS = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Informacion_IIS") -Force
    $folderNode = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Informacion_Node") -Force
    $folderDb = New-Item -ItemType Directory -Path (Join-Path $tempZipDir "Informacion_BaseDatos") -Force

    Copy-Item -Path $ReportHtmlPath -Destination $folderReporte.FullName -Force
    Copy-Item -Path $DiagLogPath -Destination $folderReporte.FullName -Force

    if (Test-Path "$TargetDir\install_log.txt") { Copy-Item -Path "$TargetDir\install_log.txt" -Destination $folderLogs.FullName -Force }
    if (Test-Path "$TargetDir\install_sqlserver_log.txt") { Copy-Item -Path "$TargetDir\install_sqlserver_log.txt" -Destination $folderLogs.FullName -Force }
    if (Test-Path "$TargetDir\daemon") { Copy-Item -Path "$TargetDir\daemon\*.log" -Destination $folderLogs.FullName -Force -ErrorAction SilentlyContinue }

    if (Test-Path "$TargetDir\.env") {
        $rawEnv = Get-Content "$TargetDir\.env"
        $sanitizedEnv = $rawEnv -replace ':[^:@/]+@', ':********@' -replace 'SECRET="[^"]+"', 'SECRET="[PROTECTED]"'
        Set-Content -Path (Join-Path $folderConf.FullName ".env.sanitized") -Value $sanitizedEnv -Encoding UTF8
    }
    if (Test-Path "$TargetDir\web.config") {
        Copy-Item -Path "$TargetDir\web.config" -Destination $folderConf.FullName -Force
    }

    $TestResults | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $folderTests.FullName "tests_summary.json") -Encoding UTF8

    @{ OS = $osName; Arch = $arch; FreeSpaceGB = $freeSpaceGB; Date = (Get-Date) } | ConvertTo-Json | Set-Content -Path (Join-Path $folderSys.FullName "sys_info.json") -Encoding UTF8
    @{ IISInstalled = ($iisSvc -ne $null); IISStatus = if ($iisSvc) { [string]$iisSvc.Status } else { "N/D" }; Rewrite = $hasRewrite; ARR = $hasArr } | ConvertTo-Json | Set-Content -Path (Join-Path $folderIIS.FullName "iis_info.json") -Encoding UTF8
    @{ NodeVersion = $nodeVersion; NodePath = $nodePath } | ConvertTo-Json | Set-Content -Path (Join-Path $folderNode.FullName "node_info.json") -Encoding UTF8
    @{ Engine = $Engine; Host = if ($Engine -eq "POSTGRESQL") { $PgHost } else { $SqlHost }; Port = if ($Engine -eq "POSTGRESQL") { $PgPort } else { $SqlPort }; Database = if ($Engine -eq "POSTGRESQL") { $PgDb } else { $SqlDb } } | ConvertTo-Json | Set-Content -Path (Join-Path $folderDb.FullName "db_info.json") -Encoding UTF8

    if (Test-Path $ReportZipPath) { Remove-Item $ReportZipPath -Force }
    Compress-Archive -Path "$tempZipDir\*" -DestinationPath $ReportZipPath -Force
    Remove-Item $tempZipDir -Recurse -Force | Out-Null
    Write-DiagLog ("Paquete de soporte remoto generado exitosamente en: " + $ReportZipPath)
}

Write-DiagLog "================================================================="
Write-DiagLog "  KOREX DIAGNOSTICS & REPAIR ENGINE - FINALIZADO"
Write-DiagLog ("  Resultados: " + $summaryOk + " OK, " + $summaryWarnings + " Advertencias, " + $summaryErrors + " Errores.")
Write-DiagLog "================================================================="
