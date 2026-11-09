<#
.SYNOPSIS
    Instalador del Servicio de Respaldos Automáticos de PostgreSQL para Windows.
    Generado por Antigravity.
#>

# Requerir Privilegios de Administrador para registrar la tarea programada y escribir en directorios del sistema
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Este instalador requiere ejecutarse como Administrador para registrar la tarea programada."
    Write-Host "Por favor, abre PowerShell como Administrador e inténtalo de nuevo." -ForegroundColor Red
    Write-Host "`nPresiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  INSTALADOR DE RESPALDOS AUTOMÁTICOS POSTGRESQL (KoreX)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Configuración de Base de Datos (con valores predeterminados)
$DbName = Read-Host "Nombre de la base de datos [Korex_test]"
if ([string]::IsNullOrWhiteSpace($DbName)) { $DbName = "Korex_test" }

$DbUser = Read-Host "Usuario de PostgreSQL [postgres]"
if ([string]::IsNullOrWhiteSpace($DbUser)) { $DbUser = "postgres" }

$DbPass = Read-Host "Contraseña de PostgreSQL [zzeusagencias]"
if ([string]::IsNullOrWhiteSpace($DbPass)) { $DbPass = "zzeusagencias" }

$DbHost = Read-Host "Host del servidor [localhost]"
if ([string]::IsNullOrWhiteSpace($DbHost)) { $DbHost = "localhost" }

$DbPort = Read-Host "Puerto de conexión [5432]"
if ([string]::IsNullOrWhiteSpace($DbPort)) { $DbPort = "5432" }

# 2. Configuración de Rutas locales
$InstallDir = Read-Host "Carpeta de instalación del script [C:\KorexBackup]"
if ([string]::IsNullOrWhiteSpace($InstallDir)) { $InstallDir = "C:\KorexBackup" }

$BackupDir = Read-Host "Carpeta de destino de los Backups [C:\Backups\Korex]"
if ([string]::IsNullOrWhiteSpace($BackupDir)) { $BackupDir = "C:\Backups\Korex" }

# 3. Detectar ruta de pg_dump.exe
Write-Host "`nBuscando pg_dump.exe en el sistema..." -ForegroundColor Yellow
$PgDumpPath = ""

# Rutas de búsqueda comunes
$CommonPaths = @(
    "C:\Program Files\PostgreSQL\*\bin\pg_dump.exe",
    "C:\Program Files (x86)\PostgreSQL\*\bin\pg_dump.exe"
)

foreach ($PathPattern in $CommonPaths) {
    $Matches = Get-ChildItem -Path $PathPattern -ErrorAction SilentlyContinue
    if ($Matches) {
        # Seleccionar la versión más reciente (última en orden alfabético)
        $PgDumpPath = $Matches | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
        break
    }
}

if ([string]::IsNullOrEmpty($PgDumpPath)) {
    Write-Host "No se encontró pg_dump.exe automáticamente." -ForegroundColor Red
    $PgDumpPath = Read-Host "Por favor ingresa la ruta completa a pg_dump.exe"
} else {
    Write-Host "Encontrado en: $PgDumpPath" -ForegroundColor Green
}

# 4. Crear carpeta de instalación y escribir el script de backup
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$BackupScriptPath = Join-Path $InstallDir "backup_korex.ps1"

# Contenido del script de backup dinámico
$ScriptContent = @"
# Script de respaldo automático para la base de datos $DbName
# Instalado de forma automatizada.

`$DbName = "$DbName"
`$DbUser = "$DbUser"
`$DbPass = "$DbPass"
`$DbHost = "$DbHost"
`$DbPort = "$DbPort"
`$BackupDir = "$BackupDir"
`$PgDumpPath = "$PgDumpPath"

if (-not (Test-Path `$BackupDir)) {
    New-Item -ItemType Directory -Path `$BackupDir -Force | Out-Null
}

`$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
`$BackupFile = Join-Path `$BackupDir "`$`{DbName`}_backup_`$Timestamp.backup"

`$env:PGPASSWORD = `$DbPass

try {
    Write-Host "Iniciando respaldo de `$DbName..."
    & `$PgDumpPath -U `$DbUser -h `$DbHost -p `$DbPort -d `$DbName -F c -b -v -f `$BackupFile
    Write-Host "Respaldo completado en: `$BackupFile" -ForegroundColor Green
    
    # Rotación: Borrar archivos de más de 15 días
    Get-ChildItem -Path `$BackupDir -Filter "`$`{DbName`}_backup_*.backup" | Where-Object { `$_.CreationTime -lt (Get-Date).AddDays(-15) } | Remove-Item -Force
} catch {
    Write-Error "Error en respaldo: `$_"
} finally {
    if (Test-Path env:PGPASSWORD) { Remove-Item env:PGPASSWORD }
}
"@

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($BackupScriptPath, $ScriptContent, $Utf8NoBom)
Write-Host "`nScript de backup creado en: $BackupScriptPath" -ForegroundColor Green

# 5. Programar la Tarea de Windows
Write-Host "Registrando Tarea Programada en Windows..." -ForegroundColor Yellow
$TaskName = "Backup_Korex_$DbName"

try {
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy RemoteSigned -File `"$BackupScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -Daily -At 11:00PM
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Respaldo diario automático de la base de datos $DbName de PostgreSQL" -Force | Out-Null
    
    Write-Host "¡Instalación Completada con Éxito!" -ForegroundColor Green
    Write-Host "La tarea '$TaskName' se ejecutará todos los días a las 11:00 PM." -ForegroundColor Green
    Write-Host "Los respaldos se guardarán en: $BackupDir" -ForegroundColor Green
} catch {
    Write-Error "Error al registrar la tarea programada: $_"
}

Read-Host "`nPresiona Enter para salir..."
