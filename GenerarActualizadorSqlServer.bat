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
echo [PASO 1/3] Sincronizando scripts T-SQL en ActualizadorSERVER.sql...
node deploy/sync_sqlserver_updater.js

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo al sincronizar el script del actualizador SQL Server.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [PASO 2/3] Auditando suite completa de maestros y funcionalidades (PG + SQL)...
node scripts/validate_full_system.js

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo la validacion pre-empaquetado para SQL Server.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ================================================================
echo ACTUALIZADOR DE SQL SERVER GENERADO CORRECTAMENTE
echo ================================================================
echo.
pause
