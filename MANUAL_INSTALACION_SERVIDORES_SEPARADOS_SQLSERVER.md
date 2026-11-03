# MANUAL DE INSTALACIÓN Y ACTUALIZACIÓN PASO A PASO PARA USUARIOS FINALES
## Plataforma Korex AgenciasNew — Arquitectura Desacoplada (Base de Datos SQL Server + Servidor Web Next.js)

**Versión del Documento:** 1.0  
**Plataforma:** Korex AgenciasNew (Edición Microsoft SQL Server)  
**Público Objetivo:** Administradores de Base de Datos (DBA), Administradores de Servidores Windows / IIS y Personal de Soporte Técnico IT.

---

## ÍNDICE DE CONTENIDO

1. [Resumen de Arquitectura (Servidores Separados)](#1-resumen-de-arquitectura-servidores-separados)
2. [Requisitos Previos por Servidor y Red](#2-requisitos-previos-por-servidor-y-red)
3. [Orden Obligatorio de Instalación](#3-orden-obligatorio-de-instalación)
4. [PARTE 1: Manual del Instalador de Base de Datos (`Korex_SQLServer_DB_Update_Setup.exe`)](#4-parte-1-manual-del-instalador-de-base-de-datos-korex_sqlserver_db_update_setupexe)
   - 4.1. Propósito y Alcance
   - 4.2. Paso a Paso Detallado de las Pantallas del Asistente
   - 4.3. Comportamiento Automático: Base de Datos Nueva vs. Existente
   - 4.4. Qué instala y valida internamente (Korex Update Guardian)
   - 4.5. Archivos de Registro (Logs) de Base de Datos
5. [PARTE 2: Manual del Instalador del Sitio Web (`Korex_SQLServer_Web_Update_Setup.exe`)](#5-parte-2-manual-del-instalador-del-sitio-web-korex_sqlserver_web_update_setupexe)
   - 5.1. Propósito y Alcance
   - 5.2. Paso a Paso Detallado de las Pantallas del Asistente
   - 5.3. Qué configura internamente (IIS, Servicio de Windows, Task Scheduler y `.env`)
   - 5.4. Archivos de Registro (Logs) y Diagnóstico del Sitio Web
6. [PARTE 3: Activación de Licencia en Servidores Separados](#6-parte-3-activación-de-licencia-en-servidores-separados)
   - 6.1. ¿Cómo funciona la licencia entre el Servidor Web y el Servidor SQL Server?
   - 6.2. Opción A: Activación desde el Navegador Web (Recomendada)
   - 6.3. Opción B: Activación por Consola (`ActivarLicencia.bat`)
7. [PARTE 4: Primer Ingreso al Sistema y Credenciales Iniciales](#7-parte-4-primer-ingreso-al-sistema-y-credenciales-iniciales)
8. [PARTE 5: Guía de Solución de Problemas Frecuentes (Troubleshooting)](#8-parte-5-guía-de-solución-de-problemas-frecuentes-troubleshooting)

---

## 1. RESUMEN DE ARQUITECTURA (SERVIDORES SEPARADOS)

El sistema **Korex AgenciasNew** cuenta con **dos instaladores independientes** diseñados para permitir que el **Servidor de Base de Datos (Microsoft SQL Server)** y el **Servidor de Aplicaciones Web (Next.js + IIS)** operen en máquinas físicas o virtuales distintas (o en el mismo servidor si así se desea) y sean administrados por responsables diferentes:

```text
┌─────────────────────────────────────────────┐          ┌─────────────────────────────────────────────┐
│             SERVIDOR WEB (APP)              │          │        SERVIDOR DE BASE DE DATOS            │
│       Instalador:                           │          │       Instalador:                           │
│   Korex_SQLServer_Web_Update_Setup.exe      │          │    Korex_SQLServer_DB_Update_Setup.exe      │
├─────────────────────────────────────────────┤          ├─────────────────────────────────────────────┤
│ • Recibe peticiones HTTP (Puerto 3000 IIS)  │          │ • Motor Microsoft SQL Server (2016+)        │
│ • Proxy Inverso hacia Node.js (Puerto 3001) │  TCP/IP  │ • Base de Datos de Korex (ej. Korex_db)     │
│ • Servicio Windows (korex_nextjs.exe)       │ ───────► │ • 185 Objetos (Tablas, Vistas, Funciones y  │
│   o Tarea Programada (Fallback automático)  │  Puerto  │   Procedimientos Almacenados)               │
│ • Archivo .env apuntando al SQL remoto      │ 1433/TCP │ • Almacena la Licencia compartida           │
└─────────────────────────────────────────────┘          └─────────────────────────────────────────────┘
```

| Instalador | Archivo Ejecutable (`.exe`) | ¿En qué servidor se ejecuta? | ¿Quién lo ejecuta? |
| :--- | :--- | :--- | :--- |
| **1. Instalador de Base de Datos** | `Korex_SQLServer_DB_Update_Setup.exe` | En el Servidor de Base de Datos (o desde un equipo con acceso a SQL Server) | Administrador de Base de Datos (DBA) |
| **2. Instalador del Sitio Web** | `Korex_SQLServer_Web_Update_Setup.exe` | En el Servidor Web de Aplicaciones | Administrador de Servidores / Infraestructura Web |

---

## 2. REQUISITOS PREVIOS POR SERVIDOR Y RED

### 2.1. En el Servidor de Base de Datos (SQL Server)
1. **Sistema Operativo:** Windows Server 2016 / 2019 / 2022 / 2025 o Windows 10 / 11 (64 bits).
2. **Motor de Base de Datos:** Microsoft SQL Server 2016 o superior (Express, Standard o Enterprise).
3. **Autenticación Mixta habilitada:** SQL Server debe tener habilitado el modo **SQL Server and Windows Authentication mode** (Autenticación Mixta).
4. **Protocolo TCP/IP habilitado en SQL Server:**
   - Abrir *SQL Server Configuration Manager* $\rightarrow$ *SQL Server Network Configuration* $\rightarrow$ *Protocols for [INSTANCIA]*.
   - Verificar que **TCP/IP** esté en estado **Enabled**.
   - Si utiliza una instancia nombrada (ejemplo: `SERVIDOR\AGENCIAS`), verificar el puerto TCP asignado en la pestaña *IP Addresses* $\rightarrow$ sección *IPAll* $\rightarrow$ *TCP Port* (por defecto `1433`, o el puerto específico configurado, ej. `1434`), o mantener activo el servicio **SQL Server Browser**.
5. **Permisos del Usuario SQL:**
   - Si la base de datos **NO existe** aún y desea que el instalador la cree automáticamente: el usuario SQL ingresado debe tener rol `sysadmin` o `dbcreator`.
   - Si la base de datos **YA existe**: el usuario SQL ingresado debe ser `db_owner` de esa base de datos.
6. **Node.js (v20 LTS o superior):** El instalador de Base de Datos utiliza el motor de Node.js para ejecutar los lotes transaccionales y el verificador *Korex Update Guardian*.
7. **Regla de Firewall de Entrada (Inbound Rule):**
   - Permitir tráfico entrante en el puerto TCP de SQL Server (ej. `1433` o el puerto de la instancia) desde la dirección IP del Servidor Web.

### 2.2. En el Servidor Web (Aplicación Next.js)
1. **Sistema Operativo:** Windows Server 2016 / 2019 / 2022 / 2025 o Windows 10 / 11 (64 bits).
2. **Privilegios:** Ejecutar el instalador con una cuenta de **Administrador Local** (Clic derecho $\rightarrow$ *Ejecutar como administrador*).
3. **Node.js (v20 LTS o superior):** Instalado en `C:\Program Files\nodejs`.
4. **Internet Information Services (IIS) (Opcional pero Recomendado):**
   - Rol *Web Server (IIS)* activo.
   - Módulos **URL Rewrite 2.1** y **Application Request Routing (ARR 3.0)** instalados para enrutar el puerto externo `3000` hacia el motor interno `3001`.
5. **Conectividad de Red hacia el Servidor SQL Server:**
   - El Servidor Web debe poder alcanzar la IP/Host y el puerto TCP del Servidor SQL Server.
   - Puede comprobarlo abriendo PowerShell en el Servidor Web y ejecutando:
     ```powershell
     Test-NetConnection -ComputerName <IP_SERVIDOR_SQL> -Port 1433
     ```
     El resultado debe mostrar `TcpTestSucceeded : True`.

---

## 3. ORDEN OBLIGATORIO DE INSTALACIÓN

> **REGLA DE ORO:** Siempre debe ejecutarse **PRIMERO** el Instalador de Base de Datos y **SEGUNDO** el Instalador del Sitio Web.

1. **Paso 1 (En el Servidor de Base de Datos):** Ejecutar `Korex_SQLServer_DB_Update_Setup.exe`. Este instalador verifica si la base de datos existe (si no existe la crea automáticamente) e inyecta las 185 estructuras, tablas, semillas y procedimientos almacenados.
2. **Paso 2 (En el Servidor Web):** Ejecutar `Korex_SQLServer_Web_Update_Setup.exe`. Durante el asistente, este instalador verifica en vivo que la base de datos del Paso 1 ya exista y responda antes de instalar y arrancar el sitio web.
3. **Paso 3 (Activación de Licencia):** Ingresar al portal web (o ejecutar `ActivarLicencia.bat`) y registrar la clave de licencia `KOR1...`.

---

## 4. PARTE 1: MANUAL DEL INSTALADOR DE BASE DE DATOS (`Korex_SQLServer_DB_Update_Setup.exe`)

### 4.1. Propósito y Alcance
Este instalador es **100% exclusivo para la Base de Datos SQL Server**.
- **NO** instala archivos del sitio web Next.js.
- **NO** crea ni modifica servicios de Windows ni sitios en IIS.
- Puede ejecutarse tanto para una **instalación desde cero (base de datos nueva)** como para una **actualización de versión** sobre una base de datos existente (preservando el 100% de la información operativa del cliente).

### 4.2. Paso a Paso Detallado de las Pantallas del Asistente

#### Paso 1: Iniciar el Ejecutable como Administrador
1. Ubique el archivo **`Korex_SQLServer_DB_Update_Setup.exe`**.
2. Haga clic derecho sobre el archivo y seleccione **"Ejecutar como administrador"**.
3. Si aparece el control de cuentas de usuario de Windows (UAC), haga clic en **Sí**.

#### Paso 2: Selección de Carpeta de Trabajo de Scripts SQL
1. El asistente mostrará la pantalla **Seleccione la carpeta de destino** (por defecto `C:\Korex_SQLServer_BD`).
2. En esta carpeta se depositarán los scripts `.sql` consolidados e individuales, el manifiesto de objetos (`manifest-sqlserver.json`), el motor de validación *Guardian* y el archivo de registro `install_sqlserver_bd_log.txt`.
3. Haga clic en **Siguiente**.

#### Paso 3: Pantalla 1 — Datos del Servidor y Nombre de la Base de Datos SQL Server
El asistente mostrará el formulario **"Servidor y Base de Datos SQL Server"** con tres campos:

| Campo en Pantalla | ¿Qué debe ingresar? | Ejemplo |
| :--- | :--- | :--- |
| **1. Servidor / Instancia SQL Server** | Dirección IP, nombre de red del servidor o `SERVIDOR\INSTANCIA`. Si está en el mismo servidor con instancia predeterminada, use `127.0.0.1`. | `127.0.0.1` o `192.168.1.50` o `SRVSQL\AGENCIAS` |
| **2. Puerto SQL Server** | Puerto TCP donde escucha el motor SQL Server. Por defecto es `1433` (si su instancia nombrada usa otro puerto como `1434`, indíquelo aquí). | `1433` (o `1434`) |
| **3. Nombre de la Base de Datos a Crear o Actualizar** | El nombre exacto de la base de datos de Korex. Si no existe en SQL Server, el instalador la creará con este nombre. | `Korex_colaereo` (o el nombre elegido por su empresa) |

4. Complete los tres campos y haga clic en **Siguiente**.

#### Paso 4: Pantalla 2 — Credenciales de Microsoft SQL Server
El asistente mostrará el formulario **"Credenciales de Microsoft SQL Server"**:

| Campo en Pantalla | ¿Qué debe ingresar? | Ejemplo |
| :--- | :--- | :--- |
| **1. Usuario de SQL Server** | Usuario de autenticación SQL Server con permisos sobre la instancia/base de datos. | `sa` o `zeusagencias` |
| **2. Contraseña de SQL Server** | Contraseña correspondiente al usuario SQL Server. | `********` |

5. Haga clic en **Siguiente**.

### 4.3. Comportamiento Automático: Base de Datos Nueva vs. Existente
Al hacer clic en **Siguiente** en la pantalla de credenciales, el instalador se conecta en tiempo real a la base `master` de SQL Server y realiza la siguiente validación automática:

* **CASO A — Las credenciales o el servidor son incorrectos:**
  - El asistente muestra una alerta de error indicando que no fue posible conectar al servidor SQL Server y permanece en la pantalla para que corrija el host, puerto, usuario o contraseña.
* **CASO B — La Base de Datos NO EXISTE en el servidor SQL Server:**
  - El asistente muestra un cuadro de confirmación informándole:
    > *"Conexión exitosa al servidor SQL Server. La base de datos `[NombreBD]` NO EXISTE actualmente en el servidor. El instalador CREARÁ automáticamente la base de datos `[NombreBD]` y posteriormente ejecutará todos los scripts de estructura, semillas y procedimientos almacenados. ¿Desea crear la base de datos y continuar?"*
  - Al hacer clic en **Sí**, el asistente avanza a la ventana de instalación.
* **CASO C — La Base de Datos YA EXISTE en el servidor SQL Server:**
  - El asistente valida la conexión silenciosamente y avanza directo a la ventana de instalación para aplicar únicamente las actualizaciones de forma incremental y segura (sin borrar ningún dato existente).

#### Paso 5: Ejecución y Verificación Automática
1. Haga clic en **Instalar**.
2. Se abrirá una ventana de consola que mostrará el avance en tiempo real:
   - `[PASO 0]` Verifica en `master` si la base existe; si no existe, ejecuta `CREATE DATABASE [...]` y espera a que el estado sea `ONLINE`.
   - `[PASO 1]` Conecta a la base de datos destino y valida la identidad del servidor.
   - `[PASO 2]` Ejecuta los **153 lotes T-SQL** (Tablas, Columnas incrementales, Índices, Semillas Maestras, Funciones y Procedimientos Almacenados).
   - `[PASO 3]` Ejecuta automáticamente el **Korex Update Guardian**, verificando uno por uno los **185 objetos obligatorios** contra `sys.objects`.
3. Al finalizar con `0 errores`, haga clic en **Finalizar**.

### 4.4. Archivos de Registro (Logs) de Base de Datos
Si desea auditar el resultado técnico de la ejecución en el Servidor de Base de Datos, revise el archivo:
- **`<Carpeta_Instalacion_BD>\install_sqlserver_bd_log.txt`** (por defecto `C:\Korex_SQLServer_BD\install_sqlserver_bd_log.txt`).

---

## 5. PARTE 2: MANUAL DEL INSTALADOR DEL SITIO WEB (`Korex_SQLServer_Web_Update_Setup.exe`)

### 5.1. Propósito y Alcance
Este instalador es **100% exclusivo para el Servidor Web (Aplicación Next.js)**.
- **NO** ejecuta scripts DDL ni crea/altera tablas o procedimientos almacenados en SQL Server.
- Instala y actualiza los binarios de producción de **Next.js Standalone**, configura el archivo `.env` apuntando al Servidor SQL Server (local o remoto), registra el **Servicio de Windows (`korex_nextjs.exe`)** —con contingencia automática por **Tarea Programada (Task Scheduler)**—, configura el sitio **Korex en IIS (puerto `3000`)** y ejecuta los **11 dominios de autodiagnóstico**.

### 5.2. Paso a Paso Detallado de las Pantallas del Asistente

#### Paso 1: Iniciar el Ejecutable como Administrador en el Servidor Web
1. En el **Servidor Web**, ubique el archivo **`Korex_SQLServer_Web_Update_Setup.exe`**.
2. Haga clic derecho sobre el archivo y seleccione **"Ejecutar como administrador"**.

#### Paso 2: Selección del Directorio de Instalación del Sitio Web
1. En la pantalla **Seleccione la carpeta de destino**, indique la ruta donde residirá la aplicación web (por ejemplo: `C:\inetpub\Korex` o `F:\Korex_Sistema_SQLServer`).
   - *Nota:* Si está actualizando un servidor web existente, seleccione exactamente la misma carpeta donde estaba instalado previamente; el instalador creará automáticamente una copia de respaldo de su `.env` anterior (`.env.bak_YYYYMMDD_HHMMSS`).
2. Haga clic en **Siguiente**.

#### Paso 3: Pantalla 1 — Conexión al Servidor de Base de Datos SQL Server
El asistente mostrará la página **"Conexión al Servidor de Base de Datos SQL Server"**:

| Campo en Pantalla | ¿Qué debe ingresar? | Ejemplo |
| :--- | :--- | :--- |
| **1. Servidor / IP SQL Server** | La dirección IP o nombre de red del **Servidor de Base de Datos** donde ejecutó la Parte 1 (incluir `\INSTANCIA` si aplica). | `192.168.1.50` o `SRVSQL\AGENCIAS_PRUEBA` |
| **2. Puerto SQL Server** | El puerto TCP del servidor SQL Server remoto. | `1433` (o `1434`) |
| **3. Nombre de la Base de Datos en SQL Server** | El nombre exacto de la base de datos que fue creada/actualizada en la Parte 1. | `Korex_colaereo` |

3. Haga clic en **Siguiente**.

#### Paso 4: Pantalla 2 — Credenciales de Conexión a SQL Server
El asistente mostrará la página **"Credenciales de Conexión a SQL Server"**:

| Campo en Pantalla | ¿Qué debe ingresar? | Ejemplo |
| :--- | :--- | :--- |
| **1. Usuario de SQL Server** | Usuario SQL Server con acceso de lectura y escritura a la base de datos de Korex. | `sa` o `zeusagencias` |
| **2. Contraseña de SQL Server** | Contraseña del usuario SQL Server. | `********` |

4. Haga clic en **Siguiente**.
   - **Validación en tiempo real:** En este momento, el Servidor Web comprueba la conexión directa hacia la base de datos en el Servidor SQL Server.
   - Si la base de datos aún no existe en el servidor SQL Server o hay un bloqueo de Firewall/red, el asistente le mostrará un mensaje preventivo indicando que primero debe ejecutar `Korex_SQLServer_DB_Update_Setup.exe` en el servidor de base de datos o abrir el puerto en el Firewall.

#### Paso 5: Instalación, Arranque de Servicios y Autodiagnóstico
1. Haga clic en **Instalar**.
2. El instalador copiará los archivos del proyecto web y ejecutará automáticamente el configurador del servidor web (`Update_Korex_SQLServer_Web.ps1`), realizando:
   - **Respaldo y generación de `.env`:** Configura `DATABASE_PROVIDER="sqlserver"` y `DATABASE_URL` apuntando a la IP y puerto del Servidor SQL Server.
   - **Registro del Servicio de Windows (`korex_nextjs.exe`):** Registra e inicia el backend de Next.js Standalone en el puerto interno **`3001`**.
   - **Fallback Automático (Task Scheduler):** Si una política de seguridad corporativa bloquea la creación de servicios de Windows, activa automáticamente la Tarea Programada `Korex SQLServer - Startup` para garantizar que el puerto **`3001`** quede en escucha.
   - **Publicación en IIS:** Registra e inicia el sitio **`Korex`** en IIS en el puerto **`3000`** con proxy inverso hacia `http://127.0.0.1:3001/`.
   - **Motor de Diagnóstico (11 Dominios):** Verifica conectividad a SQL Server, puertos `3000` y `3001`, respuesta HTTP 200 y genera el reporte HTML en la subcarpeta `Diagnosticos\`.
3. Al finalizar, deje marcada la casilla **"Abrir la plataforma AgenciasNew en mi Navegador"** y haga clic en **Finalizar**.

### 5.3. Archivos de Registro (Logs) y Diagnóstico del Sitio Web
En la carpeta donde instaló el sitio web (ej. `C:\inetpub\Korex\`) encontrará:
- **`install_sqlserver_web_log.txt`**: Registro paso a paso de la configuración del sitio web.
- **`Diagnosticos\Korex_Diagnostico_SQLSERVER_YYYYMMDD_HHMMSS.html`**: Informe visual completo con el estado de los 11 dominios del servidor web y la conexión a SQL Server.

---

## 6. PARTE 3: ACTIVACIÓN DE LICENCIA EN SERVIDORES SEPARADOS

### 6.1. ¿Cómo funciona la licencia entre el Servidor Web y el Servidor SQL Server?
El sistema de licenciamiento de Korex almacena la clave criptográfica (`LICENSE_KEY` con formato `KOR1.<payload>.<firma>`) directamente en la tabla **`dbo.SystemParameter`** de la base de datos SQL Server y valida su firma digital (`HMAC-SHA256`) en el Servidor Web.
Gracias a este diseño:
- **No está atada al hardware físico (MAC/CPU) de un único servidor.**
- Funciona de forma transparente cuando el Servidor Web está en una máquina y el Servidor SQL Server está en otra.

### 6.2. Opción A: Activación desde el Navegador Web (Recomendada)
1. Abra su navegador e ingrese a la URL del Servidor Web:
   - Desde el mismo Servidor Web: `http://localhost:3000/` (o `http://localhost:3001/`)
   - Desde cualquier equipo de la red: `http://<IP_DEL_SERVIDOR_WEB>:3000/`
2. Si el sistema aún no cuenta con una licencia activa (o si ha expirado), se mostrará automáticamente la pantalla **Activación de Licencia Korex**.
3. Copie y pegue su clave de licencia completa (que inicia por **`KOR1.`**) en el campo **Clave de Licencia**.
4. Haga clic en **Activar Licencia**. El sistema validará la firma criptográfica, guardará la licencia en la base de datos SQL Server remota y lo redirigirá al inicio de sesión.

### 6.3. Opción B: Activación por Consola (`ActivarLicencia.bat`)
Si prefiere activar la licencia por línea de comandos desde el **Servidor Web**:
1. Abra la carpeta donde instaló el Sitio Web (ej. `C:\inetpub\Korex\`).
2. Haga clic derecho sobre **`ActivarLicencia.bat`** y seleccione **Ejecutar como administrador**.
3. Cuando la consola lo solicite, pegue la clave de licencia (`KOR1....`) y presione **Enter**.
4. El script leerá automáticamente la cadena de conexión del archivo `.env` del Servidor Web, se conectará al Servidor SQL Server remoto y registrará `LICENSE_KEY` y `LICENSE_EXPIRATION_DATE` en `dbo.SystemParameter`.

---

## 7. PARTE 4: PRIMER INGRESO AL SISTEMA Y CREDENCIALES INICIALES

Una vez activada la licencia, ingrese a `http://<IP_DEL_SERVIDOR_WEB>:3000/login` con las credenciales iniciales de **Superadministrador** sembradas por el instalador de base de datos:

| Dato | Valor Inicial |
| :--- | :--- |
| **Correo Electrónico (Usuario)** | `ebarrera@zagencias.com` |
| **Contraseña Inicial** | `admin123` |
| **Rol** | `SUPERADMINISTRADOR` |

> **Recomendación de Seguridad:** Tras realizar el primer inicio de sesión, diríjase a **Configuración (Maestros) $\rightarrow$ Usuarios** para crear los usuarios operativos de la agencia y actualizar las contraseñas administrativas.

---

## 8. PARTE 5: GUÍA DE SOLUCIÓN DE PROBLEMAS FRECUENTES (TROUBLESHOOTING)

### Problema 1: El instalador Web muestra *"No fue posible conectar desde este Servidor Web hacia la base de datos en el servidor SQL Server"*
**Causas y Solución:**
1. **No se ha ejecutado primero el instalador de Base de Datos:** Verifique que ya se haya ejecutado `Korex_SQLServer_DB_Update_Setup.exe` en el servidor SQL Server y que la base de datos indicada ya exista.
2. **Firewall de Windows en el Servidor SQL Server:** En el Servidor SQL Server, abra *Windows Defender Firewall con seguridad avanzada* $\rightarrow$ *Reglas de entrada* y cree una regla que permita el puerto TCP de SQL Server (`1433` o el puerto de la instancia nombrada).
3. **Instancia Nombrada con Puerto Dinámico:** Si su servidor SQL usa instancia nombrada (ej. `SRVSQL\AGENCIAS`), verifique que el servicio **SQL Server Browser** esté iniciado en el Servidor SQL Server o especifique en la pantalla del instalador el puerto TCP exacto de esa instancia.

### Problema 2: El sitio abre en `http://localhost:3001/` pero NO en `http://localhost:3000/`
**Causa y Solución:**
- El puerto `3001` corresponde directamente al motor Node.js (Next.js Standalone), mientras que el puerto `3000` es expuesto por **IIS** mediante **URL Rewrite** y **Application Request Routing (ARR)**.
- Verifique en el Administrador de IIS que los módulos **URL Rewrite** y **ARR 3.0** estén instalados y que el sitio **Korex** se encuentre en estado **Iniciado (Started)**.

### Problema 3: ¿Cómo verificar si el servicio del Sitio Web está corriendo o cómo reiniciarlo manualmente?
En el **Servidor Web**, puede verificar o reiniciar el proceso desde PowerShell como Administrador:
- **Si opera bajo Servicio de Windows:**
  ```powershell
  Get-Service -Name "korex_nextjs.exe"
  Restart-Service -Name "korex_nextjs.exe"
  ```
- **Si opera bajo Tarea Programada (Task Scheduler):**
  ```powershell
  powershell -ExecutionPolicy Bypass -File "C:\inetpub\Korex\deploy\task_scheduler_manager.ps1" -Action Status -Engine SQLSERVER -Port 3001
  powershell -ExecutionPolicy Bypass -File "C:\inetpub\Korex\deploy\task_scheduler_manager.ps1" -Action Restart -Engine SQLSERVER -Port 3001
  ```
