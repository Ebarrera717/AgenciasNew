@echo off
cd /d "%~dp0"
title Herramienta de Migracion y Auditoria PostgreSQL -> SQL Server - AgenciasNew

echo ================================================================
echo   HERRAMIENTA DE MIGRACION Y AUDITORIA: POSTGRESQL -> SQL SERVER
echo ================================================================
echo.
echo Ingrese las credenciales de conexion (Presione ENTER para usar los valores por defecto):
echo.

set "DATABASE_URL=postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo?schema=public"
set /p DATABASE_URL="Cadena PostgreSQL Origen [postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo]: "

set "SQLSERVER_HOST=127.0.0.1"
set /p SQLSERVER_HOST="Servidor SQL Server Destino [127.0.0.1]: "

set "SQLSERVER_PORT=1433"
set /p SQLSERVER_PORT="Puerto SQL Server Destino [1433]: "

set "SQLSERVER_DB=Korex_colaereo"
set /p SQLSERVER_DB="Base de Datos SQL Server Destino [Korex_colaereo]: "

set "SQLSERVER_USER=sa"
set /p SQLSERVER_USER="Usuario SQL Server [sa]: "

set "SQLSERVER_PASSWORD=zzeusagencias"
set /p SQLSERVER_PASSWORD="Clave SQL Server [zzeusagencias]: "

echo.
echo [PASO 1/2] Iniciando Proceso de Migracion Operativa...
echo  - PostgreSQL (Origen): %DATABASE_URL%
echo  - SQL Server (Destino): %SQLSERVER_HOST%:%SQLSERVER_PORT% / Base: %SQLSERVER_DB%
echo.

node deploy/migrate_pg_to_sqlserver.js

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Fallo en el proceso de migracion.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ================================================================
echo [PASO 2/2] Ejecutando Auditoria de Integridad (PostgreSQL vs SQL Server)...
echo ================================================================
echo.

node deploy/validate_migration.js

echo.
echo ================================================================
echo PROCESO COMPLETO Y AUDITADO EXITOSAMENTE
echo ================================================================
echo.
pause
