@echo off
cd /d "%~dp0"
title Generador del Actualizador SQL Server - AgenciasNew

echo ================================================================
echo    GENERADOR DEL ACTUALIZADOR STANDALONE PARA SQL SERVER
echo ================================================================
echo.

echo [PASO 1/3] Sincronizando scripts T-SQL en ActualizadorSERVER.sql y Manifest...
node deploy/sync_sqlserver_updater.js
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo al sincronizar el script del actualizador SQL Server.
    pause
    exit /b %ERRORLEVEL%
)

node scripts/generate_release_manifest.js
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo al generar el manifest de SQL Server.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [PASO 2/3] Ejecutando script de empaquetado...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Generar_Empaquetado.ps1"
if %errorlevel% neq 0 (
    echo Error durante el empaquetado.
    pause
    exit /b %errorlevel%
)
echo.

echo [PASO 3/3] Compilando actualizador Korex_SQLServer_Update_Setup.exe con Inno Setup...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
if exist "C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe"

if "%ISCC_PATH%"=="" (
    echo Error: No se pudo encontrar Inno Setup ^(ISCC.exe^) en las rutas comunes.
    echo Por favor, instala Inno Setup o compila deploy\Korex_SQLServer_Update.iss manualmente.
    pause
    exit /b 1
)

echo Usando compilador en: "%ISCC_PATH%"
"%ISCC_PATH%" "%~dp0deploy\Korex_SQLServer_Update.iss"
if %errorlevel% neq 0 (
    echo Error compilando actualizador de SQL Server con Inno Setup.
    pause
    exit /b %errorlevel%
)
echo.

echo ================================================================
echo EXITO: ACTUALIZADOR DE SQL SERVER GENERADO EN:
echo   Instalador\Korex_SQLServer_Update_Setup.exe
echo ================================================================
echo.
pause
