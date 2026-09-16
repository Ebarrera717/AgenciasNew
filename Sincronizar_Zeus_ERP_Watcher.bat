@echo off
chcp 65001 > nul
title Observador en Tiempo Real (Watcher) Zeus ERP - AgenciasNew

echo ================================================================
echo    MODO VIGÍA (WATCHER) DE ZEUS ERP EN TIEMPO REAL
echo ================================================================
echo Monitoreando la carpeta SQL\ continuamente...
echo Cada cambio guardado en un archivo .sql se inyectará automáticamente en Zeus ERP.
echo.

cd /d "%~dp0"

node deploy/sync_zeus_erp.js --watch

pause
