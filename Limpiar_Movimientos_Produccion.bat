@echo off
title Limpiador de Movimientos para Paso a Producción - KoreX
cd /d "%~dp0"
echo ================================================================
echo   LIMPIADOR DE MOVIMIENTOS PARA PASO A PRODUCCION - KOREX
echo   ADVERTENCIA: Este proceso vaciará todas las Cotizaciones,
echo   Facturas, Pre-Cotizaciones, Reservas GDS y Logs de Prueba.
echo   TODOS LOS PARAMETROS, MAESTROS Y CONFIGURACIONES PERMANECERAN INTACTOS.
echo ================================================================
set /p confirm="¿Está seguro de limpiar los movimientos para pasar a producción? (S/N): "
if /i "%confirm%" NEQ "S" (
    echo Operacion cancelada por el usuario.
    pause
    exit /b
)
node "%~dp0deploy\clean_movement_tables.js"
pause
