<#
.SYNOPSIS
    Korex Performance Monitoring & Optimization Engine (PostgreSQL + SQL Server).
    Permite monitorear, detectar lentitudes, analizar índices y generar reportes de rendimiento.
#>

param(
    [ValidateSet("postgres", "sqlserver", "POSTGRESQL", "SQLSERVER")]
    [string]$Engine = "postgres",

    [ValidateSet("monitor", "recommend", "optimize", "maintenance")]
    [string]$Mode = "monitor",

    [switch]$Zip,
    [string]$OutputDir = ""
)

$TargetDir = $PSScriptRoot
if ($TargetDir.EndsWith("\deploy")) {
    $TargetDir = Split-Path $TargetDir -Parent
}

$ScriptPath = Join-Path $TargetDir "scripts\korex_performance_engine.js"
if (-not (Test-Path $ScriptPath)) {
    Write-Error "No se encontro el motor de rendimiento en: $ScriptPath"
    exit 1
}

$ZipArg = if ($Zip) { "--zip" } else { "" }
$OutArg = if ($OutputDir) { "--output-dir=$OutputDir" } else { "" }

Write-Host "Ejecutando Korex Performance Engine ($Engine | $Mode)..." -ForegroundColor Cyan
node "$ScriptPath" "--engine=$Engine" "--mode=$Mode" $ZipArg $OutArg
exit $LASTEXITCODE
