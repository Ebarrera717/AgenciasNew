@echo off
cd /d "%~dp0"
title Generador del Actualizador SQL Server - AgenciasNew

echo ================================================================
echo    GENERADOR DEL ACTUALIZADOR STANDALONE PARA SQL SERVER
echo ================================================================
echo.
echo Ingrese los datos de conexion a SQL Server (Presione ENTER para usar los valores por defecto):
echo.

set "SQLSERVER_HOST=127.0.0.1"
set /p SQLSERVER_HOST="Servidor SQL Server [127.0.0.1]: "

set "SQLSERVER_PORT=1433"
set /p SQLSERVER_PORT="Puerto SQL Server [1433]: "

set "SQLSERVER_USER=sa"
set /p SQLSERVER_USER="Usuario SQL Server [sa]: "

set "SQLSERVER_PASSWORD=zzeusagencias"
set /p SQLSERVER_PASSWORD="Clave SQL Server [zzeusagencias]: "

echo.
echo [PASO 1/4] Sincronizando scripts T-SQL en ActualizadorSERVER.sql...
node deploy/sync_sqlserver_updater.js

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo al sincronizar el script del actualizador SQL Server.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [PASO 2/4] Auditando maestros y funcionalidades exclusivas de SQL Server...
node scripts/validate_sqlserver.js

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo la validacion de maestros y funcionalidades SQL Server. Actualizador cancelado.
    pause
    exit /b %ERRORLEVEL%
)

echo.
set /p COMPILAR_NEXT="Desea compilar el sitio web (Next.js)? (S/N) [S]: "
set "ARGS_EMPAQUETAR="
if /i "%COMPILAR_NEXT%"=="N" (
    set "ARGS_EMPAQUETAR=-SkipBuild"
)
echo.

echo [PASO 3/4] Ejecutando script de empaquetado...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Generar_Empaquetado.ps1" %ARGS_EMPAQUETAR%
if %errorlevel% neq 0 (
    echo Error durante el empaquetado.
    pause
    exit /b %errorlevel%
)
echo.

echo [PASO 4/4] Buscando Inno Setup y compilando actualizador Korex_SQLServer_Update_Setup.exe...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
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
echo        Instalador\Korex_SQLServer_Update_Setup.exe
echo ================================================================
echo.
pause
