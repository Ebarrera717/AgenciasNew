@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Validador Automatico de Integridad y Regresiones - KorexValidator

:MENU
cls
echo ===============================================================================
echo                      KOREX VALIDATOR - VALIDADOR OFICIAL
echo          Control Integral de BD, DDL, SPs, Codigo, Instalador y Actualizador
echo ===============================================================================
echo.
echo Seleccione el motor o alcance de validacion:
echo.
echo   [1] Validacion Integral Completa (PostgreSQL + SQL Server - Todo el Sistema)
echo   [2] Validar Unicamente Entorno PostgreSQL (Korex_colaereo)
echo   [3] Validar Unicamente Entorno SQL Server (01_Tables, ActualizadorSERVER, SPs)
echo   [4] Ejecutar Suite Completa Automatizada (validate_full_suite.js)
echo   [5] Salir
echo.
set /p OPCION="Ingrese su opcion (1-5) [1]: "

if "%OPCION%"=="" set OPCION=1
if "%OPCION%"=="1" goto VALIDAR_ALL
if "%OPCION%"=="2" goto VALIDAR_PG
if "%OPCION%"=="3" goto VALIDAR_SQL
if "%OPCION%"=="4" goto VALIDAR_SUITE
if "%OPCION%"=="5" goto FIN

echo Opcion invalida.
pause
goto MENU

:VALIDAR_ALL
echo.
echo Ejecutando KorexValidator para TODOS los motores...
node "%~dp0scripts\korex_validator.js" --engine=all --phase=manual
if %errorlevel% neq 0 (
    echo.
    echo ===============================================================================
    echo  [NO GO] SE DETECTARON ERRORES CRITICOS DE INTEGRIDAD. REVISE EL REPORTE.
    echo ===============================================================================
) else (
    echo.
    echo ===============================================================================
    echo  [GO] EL SISTEMA CUMPLE CON EL 100%% DE LAS REGLAS DE INTEGRIDAD KOREX.
    echo ===============================================================================
)
echo.
pause
goto MENU

:VALIDAR_PG
echo.
echo Ejecutando KorexValidator para PostgreSQL...
node "%~dp0scripts\korex_validator.js" --engine=postgres --phase=manual
if %errorlevel% neq 0 (
    echo.
    echo [NO GO] Fallo en la validacion de PostgreSQL.
) else (
    echo.
    echo [GO] PostgreSQL validado exitosamente.
)
echo.
pause
goto MENU

:VALIDAR_SQL
echo.
echo Ejecutando KorexValidator para SQL Server...
node "%~dp0scripts\korex_validator.js" --engine=sqlserver --phase=manual
if %errorlevel% neq 0 (
    echo.
    echo [NO GO] Fallo en la validacion de SQL Server.
) else (
    echo.
    echo [GO] SQL Server validado exitosamente.
)
echo.
pause
goto MENU

:VALIDAR_SUITE
echo.
echo Ejecutando Suite Completa Multibase...
node "%~dp0scripts\validate_full_suite.js"
echo.
pause
goto MENU

:FIN
echo Saliendo de KorexValidator.
exit /b 0
