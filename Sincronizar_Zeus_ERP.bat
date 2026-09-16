@echo off
chcp 65001 > nul
title Sincronizador Autónomo Zeus ERP - AgenciasNew

echo ================================================================
echo    SINCRONIZADOR AUTÓNOMO DE BASE DE DATOS ZEUS ERP (SQL SERVER)
echo ================================================================
echo.

cd /d "%~dp0"

echo Ejecutando sincronización de Stored Procedures, Funciones y Tablas DDL en Zeus ERP...
echo.

node deploy/sync_zeus_erp.js

echo.
echo ================================================================
echo La ejecución ha finalizado.
echo Ubicación de archivos y logs de ejecución:
echo   1. Consola / Pantalla actual (Salida detallada de lotes en tiempo real)
echo   2. Script compilado de SPs: SQL\SqlServer\03_Functions_And_SPs.sql
echo   3. Script de actualización: SQL\Actualizador\ActualizadorSERVER.sql
echo ================================================================
echo.
pause
