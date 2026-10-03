@echo off
chcp 65001 > nul
title Servidor Next.js - AgenciasNew Platform
cd /d "%~dp0"

IF NOT EXIST package.json (
  echo ERROR: No se encontro package.json
  pause
  exit /b 1
)

echo ==========================================================
echo        PLATAFORMA AGENCIASNEW - INICIO DE SERVIDOR        
echo ==========================================================
echo.
echo  [1] Continuar con la configuracion actual de .env (Recomendado)
echo  [2] Activar SQL Server (Sin alterar credenciales de .env)
echo  [3] Activar PostgreSQL (Sin alterar credenciales de .env)
echo  [4] Abrir Asistente de Configuracion (.env)
echo.
set DB_CHOICE=1
set /p DB_CHOICE="Seleccione una opcion [1-4, por defecto 1]: "

if "%DB_CHOICE%"=="2" goto SWITCH_SQLSERVER
if "%DB_CHOICE%"=="3" goto SWITCH_POSTGRES
if "%DB_CHOICE%"=="4" goto OPEN_CONFIG
goto START_CURRENT

:SWITCH_SQLSERVER
echo.
echo Cambiando motor a SQL Server...
call node scripts/select_db_provider.js sqlserver
goto START_CURRENT

:SWITCH_POSTGRES
echo.
echo Cambiando motor a PostgreSQL...
call node scripts/select_db_provider.js postgresql
goto START_CURRENT

:OPEN_CONFIG
call "%~dp0Configurar_Env.bat"
goto START_CURRENT

:START_CURRENT
echo.
echo Sincronizando modelos Prisma...
call npx prisma generate

echo.
echo Iniciando servidor Next.js en Puerto 3001...
call npm run dev -- -p 3001

IF %ERRORLEVEL% NEQ 0 (
  echo.
  echo Error al iniciar el servidor Next.js
  pause
)
