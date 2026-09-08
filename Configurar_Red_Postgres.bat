@echo off
title Configurar Red PostgreSQL y Firewall - Korex Platform
echo ==========================================================
echo Configurar Red PostgreSQL (0.0.0.0/0) y Firewall de Windows
echo ==========================================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0deploy\Configure-PostgresRemote.ps1"
echo.
echo Presione cualquier tecla para salir...
pause > nul
