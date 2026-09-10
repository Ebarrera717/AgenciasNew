@echo off
title Servidor Next.js - AgenciasNew Platform
cd /d "%~dp0"

IF NOT EXIST package.json (
  echo ERROR: No se encontro package.json
  pause
  exit
)

echo ==========================================================
echo        PLATAFORMA AGENCIASNEW - SELECCION DE MOTOR        
echo ==========================================================
echo.
echo  [1] PostgreSQL (Base Local Korex_colaereo)
echo  [2] SQL Server (Base Produccion ZEUSAGENCIAS10 / Directo)
echo.
set DB_CHOICE=1
set /p DB_CHOICE="Seleccione el motor de base de datos [1 o 2, por defecto 1]: "

if "%DB_CHOICE%"=="2" goto USE_SQLSERVER
goto USE_POSTGRES

:USE_SQLSERVER
echo.
echo MODO SELECCIONADO: SQL Server (ZEUSAGENCIAS10)
node scripts/select_db_provider.js sqlserver
goto START_PRISMA_SQL

:USE_POSTGRES
echo.
echo MODO SELECCIONADO: PostgreSQL (Korex_colaereo)
node scripts/select_db_provider.js postgresql
goto START_PRISMA_PG

:START_PRISMA_SQL
echo.
echo Generando cliente Prisma para SQL Server Mode...
call npx prisma generate
goto START_NEXT

:START_PRISMA_PG
echo.
echo Sincronizando base de datos con Prisma (db pull)...
call npx prisma db pull
IF %ERRORLEVEL% NEQ 0 (
    echo Error sincronizando base de datos Postgres
    pause
    exit
)
echo Generando cliente Prisma (generate)...
call npx prisma generate
IF %ERRORLEVEL% NEQ 0 (
    echo Error generando cliente Prisma
    pause
    exit
)
goto START_NEXT

:START_NEXT
echo.
echo Iniciando servidor Next.js en Puerto 3001...
call npm run dev -- -p 3001

IF %ERRORLEVEL% NEQ 0 (
 echo Error al iniciar el servidor Next.js
 pause
)
