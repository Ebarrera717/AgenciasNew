@echo off
cd /d "%~dp0"
title Actualizador Korex SQL Server (Puro CMD - Anti Device Guard)

echo ================================================================
echo     ACTUALIZADOR KOREX SQL SERVER (MODO DIRECTO CMD)
echo ================================================================
echo.
echo [1/3] Deteniendo servicios y procesos de Korex...
net stop Korex_SQLServer_Service 2>nul
net stop Korex_NextJS 2>nul
taskkill /F /FI "WINDOWTITLE eq *korex*" 2>nul
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo [2/3] Actualizando Procedimientos Almacenados y Base de Datos...
if exist "C:\Program Files\nodejs\node.exe" (
    "C:\Program Files\nodejs\node.exe" deploy\update_db_sqlserver.js
) else (
    node deploy\update_db_sqlserver.js
)

if %errorlevel% neq 0 (
    echo.
    echo ================================================================
    echo [AVISO] Si Node fue bloqueado por directiva, ejecute:
    echo        SQL\ActualizadorSERVER.sql en SSMS sobre Korex_pruebas
    echo ================================================================
)

echo.
echo [3/3] Reiniciando servicio de Korex...
net start Korex_SQLServer_Service 2>nul

echo.
echo ================================================================
echo       PROCESO DE ACTUALIZACION DIRECTA FINALIZADO
echo ================================================================
pause
