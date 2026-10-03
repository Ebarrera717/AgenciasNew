@echo off
cd /d "%~dp0"
title Generador del Actualizador SQL Server - AgenciasNew

echo ================================================================
echo    GENERADOR DEL ACTUALIZADOR STANDALONE PARA SQL SERVER
echo ================================================================
echo.
echo Ingrese los datos de conexion a SQL Server (Presione ENTER para usar los valores por defecto):
echo.

set "SQLSERVER_HOST=ZEUSAGENCIAS10"
set /p SQLSERVER_HOST="Servidor SQL Server [ZEUSAGENCIAS10]: "

set "SQLSERVER_PORT=1433"
set /p SQLSERVER_PORT="Puerto SQL Server [1433]: "

set "SQLSERVER_USER=zeusagencias"
set /p SQLSERVER_USER="Usuario SQL Server [zeusagencias]: "

set "SQLSERVER_PASSWORD=zzeusagencias"
set /p SQLSERVER_PASSWORD="Clave SQL Server [zzeusagencias]: "

echo.
echo [PASO 0/4] Verificando conectividad y credenciales con SQL Server [%SQLSERVER_HOST%:%SQLSERVER_PORT%]...
node scripts/test_sqlserver_connection.js "%SQLSERVER_HOST%" "%SQLSERVER_PORT%" "%SQLSERVER_USER%" "%SQLSERVER_PASSWORD%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ===============================================================================
    echo ERROR CRITICO DE CONEXION: No fue posible conectar con el servidor SQL Server.
    echo La compilacion del actualizador fue CANCELADA.
    echo ===============================================================================
    pause
    exit /b %ERRORLEVEL%
)

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
echo Ejecutando Release Guardian de Integridad Universal...
node scripts/korex_database_release_guardian.js
if %errorlevel% neq 0 (
    echo.
    echo ===============================================================================
    echo ERROR CRITICO: Release Guardian emitio dictamen [BLOQUEADO]. Actualizador CANCELADO.
    echo ===============================================================================
    pause
    exit /b %errorlevel%
)

echo.
echo Ejecutando KorexValidator Oficial (Pre-Build Actualizador SQL Server)...
node scripts/korex_validator.js --engine=sqlserver --phase=pre-build
if %errorlevel% neq 0 (
    echo.
    echo ===============================================================================
    echo ERROR CRITICO: KorexValidator emitio dictamen [NO GO]. Actualizador SQL Server CANCELADO.
    echo ===============================================================================
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

echo [PASO ADICIONAL] Empaquetando ZIP de Actualizacion Directa (Bypass WDAC/AppLocker)...
powershell.exe -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%~dp0RELEASE_KOREX\*' -DestinationPath '%~dp0Instalador\Korex_SQLServer_Update_Directo.zip' -Force"

echo ================================================================
echo EXITO: ACTUALIZADOR DE SQL SERVER GENERADO EN:
echo        1. Instalador\Korex_SQLServer_Update_Setup.exe  (Instalador EXE)
echo        2. Instalador\Korex_SQLServer_Update_Directo.zip (Paquete ZIP sin bloqueo WDAC)
echo ================================================================
echo.
pause
