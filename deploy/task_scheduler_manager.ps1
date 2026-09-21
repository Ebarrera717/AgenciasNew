<#
.SYNOPSIS
    task_scheduler_manager.ps1
    Manejador de Tareas Programadas de Windows (Task Scheduler) para Korex.
    Mecanismo de Ejecucion Alternativo y Fallback de Produccion (Next.js Standalone).
#>

param(
    [ValidateSet("Register", "Start", "Stop", "Unregister", "Status", "Restart")]
    [string]$Action = "Status",

    [ValidateSet("POSTGRESQL", "SQLSERVER")]
    [string]$Engine = "POSTGRESQL",

    [string]$TargetDir = "",
    [int]$Port = 3001
)

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $TargetDir = $PSScriptRoot
    if ($TargetDir.EndsWith("\deploy")) {
        $TargetDir = Split-Path $TargetDir -Parent
    }
}

$TaskName = if ($Engine -eq "SQLSERVER") { "Korex SQLServer - Startup" } else { "Korex NextJS - Startup" }
$MonitorTaskName = if ($Engine -eq "SQLSERVER") { "Korex SQLServer - Monitor" } else { "Korex NextJS - Monitor" }

function Get-NodeExecutablePath {
    $candidates = @(
        (Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        "C:\Program Files\nodejs\node.exe",
        "C:\Program Files (x86)\nodejs\node.exe",
        "$TargetDir\node.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    return "node.exe"
}

function Register-KorexStartupTask {
    param([string]$target, [string]$task, [int]$p)
    Write-Host "[TASK SCHEDULER] Registrando tarea de arranque del sistema: '$task'..." -ForegroundColor Cyan

    $nodeExe = Get-NodeExecutablePath
    $serverJs = Join-Path $target "server.js"
    if (-not (Test-Path $serverJs)) {
        $serverJs = Join-Path $target ".next\standalone\server.js"
    }

    # Crear runner script batch seguro para fijar variables de entorno y directorio
    $runnerBat = Join-Path $target "korex_task_runner.bat"
    $startupLog = Join-Path $target "korex_startup.log"
    $batContent = @"
@echo off
cd /d "$target"
set PORT=$p
set HOSTNAME=127.0.0.1
set NODE_ENV=production
echo [%%date%% %%time%%] Iniciando servidor Korex Standalone en puerto $p... >> "$startupLog"
"$nodeExe" "$serverJs" >> "$startupLog" 2>&1
echo [%%date%% %%time%%] Servidor Korex finalizo con codigo %%ERRORLEVEL%% >> "$startupLog"
"@
    Set-Content -Path $runnerBat -Value $batContent -Encoding ASCII -Force

    # Intentar con modulo nativo de PowerShell o schtasks.exe
    $registered = $false
    try {
        if (Get-Command Register-ScheduledTask -ErrorAction SilentlyContinue) {
            $actionObj = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"`"$runnerBat`"`"" -WorkingDirectory "$target"
            $triggerObj = New-ScheduledTaskTrigger -AtStartup
            $principalObj = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
            $settingsObj = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit (New-TimeSpan -Days 365)
            
            Register-ScheduledTask -TaskName $task -Action $actionObj -Trigger $triggerObj -Principal $principalObj -Settings $settingsObj -Force | Out-Null
            $registered = $true
            Write-Host "[TASK SCHEDULER] Tarea '$task' registrada con Register-ScheduledTask (cmd.exe /c, SYSTEM, Highest)." -ForegroundColor Green
        }
    } catch {
        Write-Host "[TASK SCHEDULER] Aviso con cmdlet nativo: $($_.Exception.Message). Usando schtasks.exe..." -ForegroundColor Yellow
    }

    if (-not $registered) {
        try {
            $cmd = "schtasks.exe /create /tn `"$task`" /tr `"cmd.exe /c \`"$runnerBat\`"`" /sc onstart /ru `"SYSTEM`" /rl highest /f"
            $output = cmd.exe /c $cmd 2>&1
            if ($LASTEXITCODE -eq 0) {
                $registered = $true
                Write-Host "[TASK SCHEDULER] Tarea '$task' creada exitosamente via schtasks.exe (SYSTEM)." -ForegroundColor Green
            } else {
                # Fallback sin usuario SYSTEM explicito si la politica corporativa restringe /ru SYSTEM
                $cmdUser = "schtasks.exe /create /tn `"$task`" /tr `"cmd.exe /c \`"$runnerBat\`"`" /sc onstart /rl highest /f"
                $outputUser = cmd.exe /c $cmdUser 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $registered = $true
                    Write-Host "[TASK SCHEDULER] Tarea '$task' creada exitosamente con credenciales locales." -ForegroundColor Green
                } else {
                    Write-Host "[TASK SCHEDULER] ERROR registrando tarea con schtasks.exe: $outputUser" -ForegroundColor Red
                    return $false
                }
            }
        } catch {
            Write-Host "[TASK SCHEDULER] Excepcion creando tarea: $_" -ForegroundColor Red
            return $false
        }
    }

    return $registered
}

function Start-KorexStartupTask {
    param([string]$task, [string]$target, [int]$p)
    Write-Host "[TASK SCHEDULER] Iniciando tarea programada '$task'..." -ForegroundColor Cyan

    # 1. Liberar procesos huérfanos previos en el puerto
    try {
        $conn = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($conn) {
            Write-Host "[TASK SCHEDULER] Deteniendo proceso previo ocupando puerto $p (PID: $($conn.OwningProcess))..." -ForegroundColor Yellow
            Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
    } catch {}

    # 2. Ejecutar tarea programada via Task Scheduler
    try {
        if (Get-Command Start-ScheduledTask -ErrorAction SilentlyContinue) {
            Start-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
        } else {
            cmd.exe /c "schtasks.exe /run /tn `"$task`"" 2>&1 | Out-Null
        }
    } catch {
        cmd.exe /c "schtasks.exe /run /tn `"$task`"" 2>&1 | Out-Null
    }

    # 3. Esperar y validar escucha en puerto (hasta 10s)
    Write-Host "[TASK SCHEDULER] Esperando arranque del servidor Next.js en puerto $p..." -ForegroundColor Cyan
    $started = $false
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        $chk = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($chk) {
            $proc = Get-Process -Id $chk.OwningProcess -ErrorAction SilentlyContinue
            $procName = if ($proc) { $proc.ProcessName } else { "node" }
            Write-Host "[TASK SCHEDULER] Servidor Next.js Standalone activo en puerto $p (Proceso: $procName, PID: $($chk.OwningProcess))." -ForegroundColor Green
            $started = $true
            break
        }
    }

    # 4. Fallback directo si Task Scheduler no logro arrancar por politicas de sesion 0 en Windows Server
    if (-not $started) {
        Write-Host "[TASK SCHEDULER] Task Scheduler no inicio en 10s. Probando ejecucion en segundo plano directa..." -ForegroundColor Yellow
        $runnerBat = Join-Path $target "korex_task_runner.bat"
        if (Test-Path $runnerBat) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"`"$runnerBat`"`"" -WorkingDirectory "$target" -WindowStyle Hidden -ErrorAction SilentlyContinue
            for ($j = 0; $j -lt 8; $j++) {
                Start-Sleep -Seconds 1
                $chk = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($chk) {
                    $proc = Get-Process -Id $chk.OwningProcess -ErrorAction SilentlyContinue
                    $procName = if ($proc) { $proc.ProcessName } else { "node" }
                    Write-Host "[TASK SCHEDULER] Servidor iniciado exitosamente en segundo plano en puerto $p (Proceso: $procName, PID: $($chk.OwningProcess))." -ForegroundColor Green
                    $started = $true
                    break
                }
            }
        }
    }

    if (-not $started) {
        Write-Host "[TASK SCHEDULER] El servidor no respondio en puerto $p." -ForegroundColor Red
        $logPath = Join-Path $target "korex_startup.log"
        if (Test-Path $logPath) {
            Write-Host "[TASK SCHEDULER] --- Ultimas lineas de korex_startup.log ---" -ForegroundColor Red
            Get-Content $logPath -Tail 25 | Write-Host -ForegroundColor Red
        }
    }

    return $started
}

function Stop-KorexStartupTask {
    param([string]$task, [string]$target)
    Write-Host "[TASK SCHEDULER] Deteniendo tarea y procesos de Korex..." -ForegroundColor Yellow
    try {
        if (Get-Command Stop-ScheduledTask -ErrorAction SilentlyContinue) {
            Stop-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
        } else {
            cmd.exe /c "schtasks.exe /end /tn `"$task`"" 2>&1 | Out-Null
        }
    } catch {}

    # Matar cualquier proceso node en el directorio
    Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -like "*$target*" } catch { $false }
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

function Unregister-KorexStartupTask {
    param([string]$task)
    Write-Host "[TASK SCHEDULER] Removiendo tarea programada '$task'..." -ForegroundColor Yellow
    try {
        if (Get-Command Unregister-ScheduledTask -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
        } else {
            cmd.exe /c "schtasks.exe /delete /tn `"$task`" /f" 2>&1 | Out-Null
        }
    } catch {
        cmd.exe /c "schtasks.exe /delete /tn `"$task`" /f" 2>&1 | Out-Null
    }
}

function Get-KorexStartupTaskStatus {
    param([string]$task, [int]$p)
    $taskExists = $false
    $taskState = "No Registrada"
    $portListening = $false
    $owningPid = 0

    try {
        if (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) {
            $t = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
            if ($t) {
                $taskExists = $true
                $taskState = [string]$t.State
            }
        } else {
            $out = cmd.exe /c "schtasks.exe /query /tn `"$task`" /fo csv /nh" 2>&1
            if ($LASTEXITCODE -eq 0 -and $out) {
                $taskExists = $true
                $taskState = "Registrada"
            }
        }
    } catch {}

    try {
        $conn = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($conn) {
            $portListening = $true
            $owningPid = $conn.OwningProcess
        }
    } catch {}

    return [PSCustomObject]@{
        TaskName      = $task
        Exists        = $taskExists
        State         = $taskState
        Port          = $p
        PortListening = $portListening
        OwningPid     = $owningPid
    }
}

# Ejecución según parámetro $Action
switch ($Action) {
    "Register" {
        $ok = Register-KorexStartupTask -target $TargetDir -task $TaskName -p $Port
        if ($ok) { exit 0 } else { exit 1 }
    }
    "Start" {
        $ok = Start-KorexStartupTask -task $TaskName -target $TargetDir -p $Port
        if ($ok) { exit 0 } else { exit 1 }
    }
    "Stop" {
        Stop-KorexStartupTask -task $TaskName -target $TargetDir
        exit 0
    }
    "Restart" {
        Stop-KorexStartupTask -task $TaskName -target $TargetDir
        $ok = Start-KorexStartupTask -task $TaskName -target $TargetDir -p $Port
        if ($ok) { exit 0 } else { exit 1 }
    }
    "Unregister" {
        Stop-KorexStartupTask -task $TaskName -target $TargetDir
        Unregister-KorexStartupTask -task $TaskName
        exit 0
    }
    "Status" {
        $status = Get-KorexStartupTaskStatus -task $TaskName -p $Port
        Write-Host "Tarea: $($status.TaskName) | Existe: $($status.Exists) | Estado: $($status.State) | Puerto $($status.Port) Escuchando: $($status.PortListening) (PID: $($status.OwningPid))"
        if ($status.PortListening) { exit 0 } else { exit 1 }
    }
}
