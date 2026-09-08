@echo off
title Generador de Base de Datos Limpia - KoreX
cd /d "%~dp0"
echo ================================================================
echo   GENERADOR DE BASE DE DATOS LIMPIA - AGENCIASNEW (KOREX)
echo ================================================================
node "%~dp0deploy\gen_clean_db.js"
pause
