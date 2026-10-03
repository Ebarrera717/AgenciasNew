@echo off
cd /d "%~dp0"
title Generador del Actualizador Web SQL Server (Solo Aplicacion - Sin BD) - AgenciasNew

echo ================================================================
echo    GENERADOR DEL ACTUALIZADOR (SOLO APLICACION WEB / SIN BD)
echo ================================================================
echo.
echo Este generador compila la aplicacion Next.js y empaqueta el actualizador
echo OMITIENDO las validaciones y ejecucion de base de datos SQL Server.
echo.

echo [PASO 1/2] Compilando sitio Next.js y empaquetando archivos...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Generar_Empaquetado.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo ERROR: Fallo al compilar el proyecto Next.js.
    echo ================================================================
    pause
    exit /b %errorlevel%
)
echo.

echo [PASO 2/2] Buscando Inno Setup y compilando actualizador Korex_SQLServer_Update_SoloApp_Setup.exe...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
if exist "C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe"

if "%ISCC_PATH%"=="" (
    echo Error: No se pudo encontrar Inno Setup ^(ISCC.exe^) en las rutas comunes.
    echo Por favor, compila deploy\Korex_SQLServer_Update_SoloApp.iss manualmente con Inno Setup.
    pause
    exit /b 1
)

echo Usando Inno Setup en: "%ISCC_PATH%"
"%ISCC_PATH%" "%~dp0deploy\Korex_SQLServer_Update_SoloApp.iss"

if %errorlevel% neq 0 (
    echo.
    echo Error al compilar con Inno Setup.
    pause
    exit /b %errorlevel%
)

echo.
echo ===============================================================================
echo  ACTUALIZADOR (SOLO APLICACION WEB) GENERADO EXITOSAMENTE
echo ===============================================================================
echo  Ubicacion: Instalador\Korex_SQLServer_Update_SoloApp_Setup.exe
echo ===============================================================================
echo.
pause
