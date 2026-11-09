@echo off
cd /d "%~dp0"
title Actualizador Exclusivo de Base de Datos SQL Server - Korex
echo ================================================================
echo    ACTUALIZADOR DIRECTO DE BASE DE DATOS KOREX - SQL SERVER
echo ================================================================
echo.
set /p SQL_HOST="Servidor SQL Server [127.0.0.1]: "
if "%SQL_HOST%"=="" set "SQL_HOST=127.0.0.1"

set /p SQL_PORT="Puerto SQL Server [1433]: "
if "%SQL_PORT%"=="" set "SQL_PORT=1433"

set /p SQL_DB="Nombre de la Base de Datos (se creara si no existe): "
if "%SQL_DB%"=="" (
    echo [ERROR] Debe indicar el nombre de la Base de Datos.
    pause
    exit /b 1
)

set /p SQL_USER="Usuario SQL Server [sa]: "
if "%SQL_USER%"=="" set "SQL_USER=sa"

set /p SQL_PASS="Clave SQL Server: "

echo.
echo Iniciando verificacion/creacion y actualizacion de la base [%SQL_DB%]...
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0deploy\Update_Korex_SQLServer_BD.ps1" -SqlHost "%SQL_HOST%" -SqlPort "%SQL_PORT%" -SqlDb "%SQL_DB%" -SqlUser "%SQL_USER%" -SqlPass "%SQL_PASS%"
if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo [ERROR] La actualizacion de Base de Datos fallo. Revise install_sqlserver_db_log.txt
    echo ================================================================
    pause
    exit /b %errorlevel%
)
echo.
echo ================================================================
echo [EXITO] BASE DE DATOS SQL SERVER [%SQL_DB%] ACTUALIZADA CON EXITO
echo ================================================================
pause
