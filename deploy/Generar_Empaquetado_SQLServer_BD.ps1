Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " CONSTRUYENDO PAQUETE EXCLUSIVO DE BASE DE DATOS SQL SERVER " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$RootDir = Split-Path -Parent $PSScriptRoot
$ReleaseDbDir = "$RootDir\RELEASE_KOREX_SQLSERVER_BD"

Set-Location $RootDir

Write-Host "`n[1/4] Preparando directorio de distribucion de Base de Datos..." -ForegroundColor Yellow
if (Test-Path $ReleaseDbDir) {
    Get-ChildItem $ReleaseDbDir -Exclude "node_modules" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $ReleaseDbDir | Out-Null
}

New-Item -ItemType Directory -Path "$ReleaseDbDir\SQL\Actualizador" -Force | Out-Null
New-Item -ItemType Directory -Path "$ReleaseDbDir\SQL\SqlServer" -Force | Out-Null
New-Item -ItemType Directory -Path "$ReleaseDbDir\deploy" -Force | Out-Null
New-Item -ItemType Directory -Path "$ReleaseDbDir\scripts" -Force | Out-Null

Write-Host "`n[2/4] Copiando scripts T-SQL, Manifest y Guardian..." -ForegroundColor Yellow
if (Test-Path ".\SQL\Actualizador\ActualizadorSERVER.sql") {
    Copy-Item ".\SQL\Actualizador\ActualizadorSERVER.sql" -Destination "$ReleaseDbDir\SQL\Actualizador\ActualizadorSERVER.sql" -Force
    Copy-Item ".\SQL\Actualizador\ActualizadorSERVER.sql" -Destination "$ReleaseDbDir\SQL\ActualizadorSERVER.sql" -Force
}
if (Test-Path ".\SQL\SqlServer\01_Tables.sql") {
    Copy-Item ".\SQL\SqlServer\01_Tables.sql" -Destination "$ReleaseDbDir\SQL\SqlServer\01_Tables.sql" -Force
}
if (Test-Path ".\SQL\SqlServer\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql") {
    Copy-Item ".\SQL\SqlServer\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql" -Destination "$ReleaseDbDir\SQL\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql" -Force
}
if (Test-Path ".\SQL\manifest-sqlserver.json") {
    Copy-Item ".\SQL\manifest-sqlserver.json" -Destination "$ReleaseDbDir\SQL\manifest-sqlserver.json" -Force
}

Copy-Item ".\deploy\update_db_sqlserver.js" -Destination "$ReleaseDbDir\deploy\update_db_sqlserver.js" -Force
Copy-Item ".\deploy\Update_Korex_SQLServer_BD.ps1" -Destination "$ReleaseDbDir\deploy\Update_Korex_SQLServer_BD.ps1" -Force
Copy-Item ".\deploy\Update_Korex_SQLServer_BD.ps1" -Destination "$ReleaseDbDir\Update_Korex_SQLServer_BD.ps1" -Force

if (Test-Path ".\scripts\korex_updater_guardian.js") {
    Copy-Item ".\scripts\korex_updater_guardian.js" -Destination "$ReleaseDbDir\scripts\korex_updater_guardian.js" -Force
}
if (Test-Path ".\scripts\generate_release_manifest.js") {
    Copy-Item ".\scripts\generate_release_manifest.js" -Destination "$ReleaseDbDir\scripts\generate_release_manifest.js" -Force
}
if (Test-Path ".\scripts\activar-licencia.js") {
    Copy-Item ".\scripts\activar-licencia.js" -Destination "$ReleaseDbDir\scripts\activar-licencia.js" -Force
}
if (Test-Path ".\ActivarLicencia.bat") {
    Copy-Item ".\ActivarLicencia.bat" -Destination "$ReleaseDbDir\ActivarLicencia.bat" -Force
}
if (Test-Path ".\Actualizar_Korex_SQLServer_BD.bat") {
    Copy-Item ".\Actualizar_Korex_SQLServer_BD.bat" -Destination "$ReleaseDbDir\Actualizar_Korex_SQLServer_BD.bat" -Force
}

# Garantizar que archivos .env de desarrollo NO viajen al paquete
Get-ChildItem -Path $ReleaseDbDir -Filter ".env*" -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "`n[3/4] Configurando package.json minimal y dependencias SQL Server (mssql, dotenv)..." -ForegroundColor Yellow
$MinimalDbPkg = '{"name":"korex-sqlserver-db-updater","version":"1.0.0","private":true,"dependencies":{"mssql":"^11.0.1","dotenv":"^16.4.5"}}'
Set-Content -Path "$ReleaseDbDir\package.json" -Value $MinimalDbPkg -Encoding UTF8

if (-not (Test-Path "$ReleaseDbDir\node_modules\mssql") -or -not (Test-Path "$ReleaseDbDir\node_modules\dotenv")) {
    Write-Host "Inyectando conectores mssql y dotenv en RELEASE_KOREX_SQLSERVER_BD..." -ForegroundColor Yellow
    Set-Location $ReleaseDbDir
    npm.cmd install mssql dotenv --no-save --silent | Out-Null
    Set-Location $RootDir
} else {
    Write-Host "Los conectores mssql y dotenv ya estan presentes en RELEASE_KOREX_SQLSERVER_BD." -ForegroundColor Green
}

Write-Host "`n[4/4] Limpiando archivos temporales..." -ForegroundColor Yellow
if (Test-Path "$ReleaseDbDir\node_modules") {
    Get-ChildItem "$ReleaseDbDir\node_modules" -Filter ".cache" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n==========================================================================" -ForegroundColor Green
Write-Host " PAQUETE DE BASE DE DATOS SQL SERVER CONSTRUIDO CON EXITO!" -ForegroundColor Green
Write-Host " --> $ReleaseDbDir" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Green
