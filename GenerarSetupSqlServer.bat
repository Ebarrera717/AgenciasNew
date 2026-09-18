@echo off
cd /d "%~dp0"
title Generador del Instalador SQL Server - Korex_SQLServer_Setup.exe

echo ========================================================
echo   GENERANDO PROGRAMA DE INSTALACION PARA SQL SERVER
echo ========================================================
echo.

echo Paso 0: Generando y auditando descriptor de esquema SQL Server...
node "%~dp0deploy\sync_sqlserver_updater.js"
if %errorlevel% neq 0 (
    echo Error durante la sincronizacion de scripts T-SQL de SQL Server.
    pause
    exit /b %errorlevel%
)
node "%~dp0scripts\validate_sqlserver.js"
if %errorlevel% neq 0 (
    echo ERROR: Fallo la validacion de maestros y funcionalidades SQL Server. Instalador cancelado.
    pause
    exit /b %errorlevel%
)
echo.

set /p COMPILAR_NEXT="Desea compilar el sitio web (Next.js)? (S/N) [S]: "
set "ARGS_EMPAQUETAR="
if /i "%COMPILAR_NEXT%"=="N" (
    set "ARGS_EMPAQUETAR=-SkipBuild"
)
echo.

echo Paso 1: Ejecutando script de empaquetado...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Generar_Empaquetado.ps1" %ARGS_EMPAQUETAR%
if %errorlevel% neq 0 (
    echo Error durante el empaquetado.
    pause
    exit /b %errorlevel%
)
echo.

echo Paso 2: Buscando Inno Setup y compilando Korex_SQLServer_Setup.exe...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
if exist "C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe"

if "%ISCC_PATH%"=="" (
    echo Error: No se pudo encontrar Inno Setup ^(ISCC.exe^) en las rutas comunes.
    echo Por favor, instala Inno Setup o compila el archivo deploy\Korex_SQLServer.iss manualmente.
    pause
    exit /b 1
)

echo Usando compilador en: "%ISCC_PATH%"
"%ISCC_PATH%" "%~dp0deploy\Korex_SQLServer.iss"
if %errorlevel% neq 0 (
    echo Error compilando instalador SQL Server con Inno Setup.
    pause
    exit /b %errorlevel%
)
echo.

echo ========================================================
echo   EXITO: Instalador de SQL Server generado en:
echo   Instalador\Korex_SQLServer_Setup.exe
echo ========================================================
pause
