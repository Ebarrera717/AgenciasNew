@echo off
cd /d "%~dp0"
title Generador de SPs y Funciones SQL Server - AgenciasNew

echo ================================================================
echo    GENERADOR CONSOLIDADO DE SPS Y FUNCIONES PARA SQL SERVER
echo ================================================================
echo.

echo [PASO 1/3] Compilando y ensamblando Procedimientos Almacenados y Funciones...
node deploy\gen_tsql_sps_and_functions.js
if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo ERROR: Fallo la generacion de SPs y Funciones T-SQL.
    echo ================================================================
    pause
    exit /b %errorlevel%
)

echo.
echo [PASO 2/3] Sincronizando script actualizador SQL Server...
node deploy\sync_sqlserver_updater.js
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Fallo al sincronizar ActualizadorSERVER.sql.
    pause
    exit /b %errorlevel%
)

echo.
echo [PASO 3/3] Ejecutando Release Guardian de Integridad Universal...
node scripts\korex_database_release_guardian.js
if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo ERROR BLOQUEANTE: Release Guardian detecto inconsistencias.
    echo ================================================================
    pause
    exit /b 1
)

echo.
echo ================================================================
echo EXITO: ARCHIVOS GENERADOS Y VERIFICADOS POR RELEASE GUARDIAN:
echo.
echo   1. SQL\SqlServer\ActualizadorSERVER.sql  (Script Actualizador)
echo   2. SQL\SqlServer\TODOS_LOS_SPS_Y_FUNCIONES_SQLSERVER.sql
echo   3. SQL\SqlServer\03_Functions_And_SPs.sql
echo   4. SQL\SqlServer\SP\  (44 SPs individuales)
echo   5. SQL\SqlServer\Function\  (3 Funciones individuales)
echo ================================================================
echo.
pause
