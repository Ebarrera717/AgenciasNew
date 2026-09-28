@echo off
cd /d "%~dp0"
title Actualizador Korex SQL Server (Modo Directo)
echo ================================================================
echo       ACTUALIZADOR DIRECTO KOREX PLATFORM - SQL SERVER
echo ================================================================
echo.
echo Iniciando actualizacion de archivos, base de datos y servicios...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Update_Korex_SQLServer.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo [ERROR] La actualizacion fallo. Revise install_sqlserver_log.txt
    echo ================================================================
    pause
    exit /b %errorlevel%
)
echo.
echo ================================================================
echo [EXITO] ACTUALIZACION DE KOREX SQL SERVER COMPLETADA CON EXITO
echo ================================================================
pause
