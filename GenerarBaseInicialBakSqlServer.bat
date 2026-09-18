@echo off
cd /d "%~dp0"
title Generador del Backup Inicial Korex_SQLServer_Inicial_1.0.bak - AgenciasNew

echo ================================================================
echo    GENERADOR DE BASE DE DATOS INICIAL EN BLANCO (.BAK)
echo ================================================================
echo.
echo Ingrese los datos de conexion a SQL Server (Presione ENTER para usar los valores por defecto configurados en .env):
echo.

set "SQLSERVER_HOST=ZEUSAGENCIAS10"
set /p SQLSERVER_HOST="Servidor SQL Server [ZEUSAGENCIAS10 / 127.0.0.1]: "

set "SQLSERVER_PORT=1433"
set /p SQLSERVER_PORT="Puerto SQL Server [1433]: "

set "SQLSERVER_USER=zeusagencias"
set /p SQLSERVER_USER="Usuario SQL Server [zeusagencias]: "

set "SQLSERVER_PASSWORD=zzeusagencias"
set /p SQLSERVER_PASSWORD="Clave SQL Server [zzeusagencias]: "

echo.
echo [PASO 1/2] Sincronizando scripts T-SQL...
node deploy/sync_sqlserver_updater.js
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Fallo la sincronizacion de scripts T-SQL.
    pause
    exit /b 1
)

echo.
echo [PASO 2/2] Construyendo base temporal y exportando Korex_SQLServer_Inicial_1.0.bak...
node deploy/gen_sqlserver_initial_bak.js
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] No se pudo generar el archivo .BAK. Verifique los errores anteriores.
    pause
    exit /b 1
)

echo.
echo ================================================================
echo  PROCESO DE GENERACION DE BAK FINALIZADO CON EXITO
echo  Archivo generado en: deploy/BaseLimpia/Korex_SQLServer_Inicial_1.0.bak
echo ================================================================
echo.
pause

