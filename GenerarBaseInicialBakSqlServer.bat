@echo off
cd /d "%~dp0"
title Generador del Backup Inicial Korex_SQLServer_Inicial_1.0.bak - AgenciasNew

echo ================================================================
echo    GENERADOR DE BASE DE DATOS INICIAL EN BLANCO (.BAK)
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
echo [PASO 1/2] Sincronizando scripts T-SQL...
node deploy/sync_sqlserver_updater.js

echo.
echo [PASO 2/2] Construyendo base temporal y exportando Korex_SQLServer_Inicial_1.0.bak...
node deploy/gen_sqlserver_initial_bak.js

echo.
echo ================================================================
echo PROCESO DE GENERACION DE BAK FINALIZADO
echo Archivo generado en: deploy/BaseLimpia/Korex_SQLServer_Inicial_1.0.bak
echo ================================================================
echo.
pause
