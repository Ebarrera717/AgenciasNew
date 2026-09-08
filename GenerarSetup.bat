@echo off
cd /d "%~dp0"
echo ========================================================
echo   GENERANDO ENSAMBLADO Y PROGRAMA DE INSTALACION
echo ========================================================
echo.

echo Paso 0: Generando descriptor de esquema de base de datos...
node "%~dp0deploy\gen_schema_json.js"
if %errorlevel% neq 0 (
    echo Error generando el descriptor del esquema de la base de datos.
    pause
    exit /b %errorlevel%
)
echo.

set /p COMPILAR_NEXT="Desea compilar el sitio web (Next.js)? (S/N) [S]: "
set "ARGS_EMPAQUETAR="
if /i "%COMPILAR_NEXT%"=="N" (
    set "ARGS_EMPAQUETAR=-SkipBuild"
)
echo.

echo Paso 1: Ejecutando script de empaquetado...
powershell.exe -ExecutionPolicy Bypass -File "F:\Proyectos\AgenciasNew\deploy\Generar_Empaquetado.ps1" %ARGS_EMPAQUETAR%
if %errorlevel% neq 0 (
    echo Error durante el empaquetado.
    pause
    exit /b %errorlevel%
)
echo.

echo Paso 2: Buscando Inno Setup y compilando...
set "ISCC_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "ISCC_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"
if exist "C:\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Inno Setup 6\ISCC.exe"
if exist "C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set "ISCC_PATH=C:\Users\rubie\AppData\Local\Programs\Inno Setup 6\ISCC.exe"

if "%ISCC_PATH%"=="" (
    echo Error: No se pudo encontrar Inno Setup ^(ISCC.exe^) en las rutas comunes.
    echo Por favor, instala Inno Setup o compila el archivo .iss manualmente haciendo clic derecho sobre el y seleccionando "Compile".
    pause
    exit /b 1
)

echo Usando compilador en: "%ISCC_PATH%"
"%ISCC_PATH%" "F:\Proyectos\AgenciasNew\deploy\Korex.iss"
if %errorlevel% neq 0 (
    echo Error compilando instalador de Inno Setup.
    pause
    exit /b %errorlevel%
)
echo.

echo ========================================================
echo   EXITO: Instalador generado en la carpeta: Instalador (Korex_Setup.exe)
echo ========================================================
pause
