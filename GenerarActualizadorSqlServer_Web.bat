@echo off
cd /d "%~dp0"
title Generador del Instalador de Sitio Web Next.js (SQL Server) - Korex

echo =======================================================================
echo    GENERANDO INSTALADOR / ACTUALIZADOR DEL PROYECTO WEB (NEXT.JS)
echo =======================================================================
echo.

echo [PASO 1/2] Compilando y empaquetando el proyecto Web Next.js...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy\Generar_Empaquetado.ps1"
if %errorlevel% neq 0 (
    echo Error durante el empaquetado del Sitio Web.
    pause
    exit /b %errorlevel%
)
echo.

echo [PASO 2/2] Compilando instalador Korex_SQLServer_Web_Update_Setup.exe con Inno Setup...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
if exist "C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe"

if "%ISCC_PATH%"=="" (
    echo Error: No se pudo encontrar Inno Setup ^(ISCC.exe^) en las rutas comunes.
    echo Por favor, instala Inno Setup o compila deploy\Korex_SQLServer_Web_Update.iss manualmente.
    pause
    exit /b 1
)

echo Usando compilador en: "%ISCC_PATH%"
"%ISCC_PATH%" "%~dp0deploy\Korex_SQLServer_Web_Update.iss"
if %errorlevel% neq 0 (
    echo Error compilando instalador del Sitio Web con Inno Setup.
    pause
    exit /b %errorlevel%
)

echo.
echo =======================================================================
echo EXITO: INSTALADOR DE SITIO WEB NEXT.JS GENERADO EN:
echo   Instalador\Korex_SQLServer_Web_Update_Setup.exe
echo =======================================================================
pause
