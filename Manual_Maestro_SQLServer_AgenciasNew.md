# Manual Maestro y Documento de Arquitectura Unificado: Despliegue, Migración y Operación con Microsoft SQL Server — AgenciasNew

Este documento constituye la **guía maestra unificada y oficial** del proyecto **AgenciasNew** para el diseño de arquitectura, generación de entregables, instalación, migración de datos, actualización y administración de bases de datos utilizando **Microsoft SQL Server**.

---

## 1. Reglas Fundamentales de Arquitectura y Principios de Despliegue

### 1.1 Regla Primordial de Lógica en Base de Datos (Database-First)
Todo cálculo, proceso de negocio, liquidación de comisiones, consulta de listado, validación o mutación de datos en AgenciasNew **DEBE realizarse obligatoriamente a través de Procedimientos Almacenados (SPs), Funciones SQL y Tablas de Base de Datos**.

### 1.2 Prohibición Absoluta de `CREATE DATABASE` en Instaladores
* **El instalador de SQL Server NUNCA debe ejecutar `CREATE DATABASE`** ni requerir que el usuario ejecutor posea permisos administrativos para crear bases de datos.
* La infraestructura/cliente es la única responsable de crear o restaurar la base de datos manualmente y entregar los parámetros de conexión (`Servidor`, `Instancia`, `Puerto`, `Base de Datos`, `Usuario`, `Clave`).
* El instalador únicamente solicita las credenciales y valida la conectividad, estructura y permisos en la base de datos existente.

### 1.3 Separación Estricta entre Clientes Nuevos y Migración
Existe una separación conceptual y técnica completa entre los dos escenarios de despliegue:

```text
                                SQL SERVER
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
                  ▼                                   ▼
       CLIENTE NUEVO (BAK)                    MIGRACIÓN CLIENTE PG
                  │                                   │
                  ▼                                   ▼
    Restauración de backup .BAK               Herramienta independiente
     'Korex_SQLServer_Inicial_1.0.bak'           'PostgreSQL ➔ SQL Server'
```

---

## 2. Los 6 Entregables Oficiales del Proyecto + Suite de Actualización

```text
01 - Instalador PostgreSQL
     └── Mantiene el paquete de instalación local PostgreSQL intacto.

02 - Instalador SQL Server (Korex_SQLServer_Setup.exe)
     └── Generado mediante 'GenerarSetupSqlServer.bat' (deploy/Korex_SQLServer.iss).
     └── Instala la aplicación Next.js y valida la conexión a la base existente (NO CREATE DATABASE).

03 - Base SQL Server Inicial (.BAK) (deploy/BaseLimpia/Korex_SQLServer_Inicial_1.0.bak)
     └── Backup oficial estructurado en blanco con semillas maestras, libre de datos de clientes.

04 - Scripts SQL Server (SQL/SqlServer/)
     └── Archivos T-SQL ('01_Tables.sql', '02_Seeds.sql', '03_Functions_And_SPs.sql').

05 - Proceso de Migración (deploy/migrate_pg_to_sqlserver.js)
     └── Herramienta independiente de transferencia de datos PostgreSQL → SQL Server con IDENTITY_INSERT.

06 - Proceso de Validación (deploy/validate_migration.js)
     └── Auditor de integridad post-migración que compara registros y saldos 1 a 1.

[NUEVO] Suite del Actualizador (SQL/Actualizador/ActualizadorSERVER.sql & deploy/update_db_sqlserver.js)
     └── Actualizador T-SQL 100% idempotente para bases en producción.
```

---

## 3. Generación de la Base Inicial en Blanco (`Korex_SQLServer_Inicial_1.0.bak`)

### 3.1 Procedimiento de Construcción para Desarrollo (1 solo clic)
Para generar o actualizar el backup `.BAK` inicial con cada nueva versión de la plataforma, ejecute:

```cmd
GenerarBaseInicialBakSqlServer.bat
```

O desde la consola Node.js:

```bash
node deploy/gen_sqlserver_initial_bak.js
```

### 3.2 Flujo Interno de Construcción Automatizado

```text
                 1. Conexión a master
                          │
                          ▼
 2. Crear BD Temporal [Korex_SQLServer_Inicial_Temp]
                          │
                          ▼
3. Aplicar Estructura DDL Completa (01_Tables.sql)
                          │
                          ▼
4. Inyectar Semillas Maestras y Menús (02_Seeds.sql)
                          │
                          ▼
5. Compilar Procedimientos y Funciones (03_Functions_And_SPs.sql)
                          │
                          ▼
6. Validar Integridad (Tablas > 0, Registros Operativos = 0)
                          │
                          ▼
7. Generar Backup Físico -> deploy/BaseLimpia/Korex_SQLServer_Inicial_1.0.bak
                          │
                          ▼
8. Eliminar BD Temporal [Korex_SQLServer_Inicial_Temp]
```

---

## 4. Manual Paso a Paso para Clientes Nuevos (Escenario A)

### Paso 1: Copiar el Backup `.BAK` Inicial
Copie el archivo entregado `Korex_SQLServer_Inicial_1.0.bak` (Componente 03) a la carpeta de backups de SQL Server (por ejemplo: `C:\Backup\`).

### Paso 2: Restaurar la Base de Datos desde SSMS
Abra **SQL Server Management Studio (SSMS)** y ejecute:

```sql
RESTORE DATABASE [Korex_colaereo]
FROM DISK = N'C:\Backup\Korex_SQLServer_Inicial_1.0.bak'
WITH FILE = 1,
MOVE N'Korex_SQLServer_Inicial_Temp' TO N'C:\SQLData\Korex_colaereo.mdf',
MOVE N'Korex_SQLServer_Inicial_Temp_log' TO N'C:\SQLData\Korex_colaereo_log.ldf',
NOUNLOAD, STATS = 5;
GO
```

### Paso 3: Crear el Usuario y Otorgar Permisos
```sql
USE [master];
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'korex_user')
BEGIN
    CREATE LOGIN [korex_user] WITH PASSWORD=N'ClaveSegura123*', DEFAULT_DATABASE=[Korex_colaereo], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
END;
GO

USE [Korex_colaereo];
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'korex_user')
BEGIN
    CREATE USER [korex_user] FOR LOGIN [korex_user];
    ALTER ROLE [db_owner] ADD MEMBER [korex_user];
END;
GO
```

### Paso 4: Ejecutar el Instalador de la Aplicación
1. Ejecute `Korex_SQLServer_Setup.exe` como Administrador.
2. Complete la pantalla de parámetros de conexión:

| Campo | Valor / Ejemplo |
| :--- | :--- |
| **Servidor / Host** | `localhost` o `192.168.1.50` |
| **Instancia** | *(Dejar en blanco si es MSSQLSERVER)* |
| **Puerto** | `1433` |
| **Nombre de Base de Datos** | `Korex_colaereo` |
| **Usuario** | `korex_user` (o `sa`) |
| **Contraseña** | `ClaveSegura123*` |

3. Presione **Validar Conexión y Continuar**. La aplicación iniciará en el puerto `3001`.

---

## 5. Manual Paso a Paso para Clientes Existentes (Escenario B - Migración)

### Opción 1: Ejecución en 1 solo Clic (Recomendado)
Ejecute en el servidor el lanzador interactivo:

```cmd
Ejecutar_Migracion_SQLServer.bat
```

### Opción 2: Ejecución Manual desde Consola

#### Paso 1: Restaurar Base en Blanco
Restaurar `Korex_SQLServer_Inicial_1.0.bak` en el servidor SQL Server de destino.

#### Paso 2: Configurar Variables de Entorno de Conexión (CMD)
```cmd
set DATABASE_URL=postgresql://postgres:zzeusagencias@localhost:5432/Korex_colaereo
set SQLSERVER_HOST=127.0.0.1
set SQLSERVER_PORT=1433
set SQLSERVER_DB=Korex_colaereo
set SQLSERVER_USER=sa
set SQLSERVER_PASSWORD=zzeusagencias
```

#### Paso 3: Ejecutar Migrador de Datos Operativos
```bash
node deploy/migrate_pg_to_sqlserver.js
```
* **Comportamiento**: Activa automáticamente `SET IDENTITY_INSERT dbo.[Tabla] ON` en SQL Server para transferir todos los registros manteniendo exactamente las mismas llaves primarias (IDs) de PostgreSQL y resincroniza contadores con `DBCC CHECKIDENT`.

#### Paso 4: Ejecutar Auditoría de Integridad
```bash
node deploy/validate_migration.js
```
* **Comportamiento**: Compara recuentos y confirma `✅ MATCH PERFECTO` en la totalidad de las tablas del sistema.

#### Paso 5: Configurar la Aplicación
Ejecutar `Korex_SQLServer_Setup.exe` apuntando a la base de datos SQL Server recién migrada.

---

## 6. Manual Paso a Paso para Actualizaciones de Clientes en Producción

Para actualizar un cliente existente que ya opera sobre SQL Server hacia nuevas versiones sin alterar sus datos operativos:

### Paso 1: Compilar Paquete Actualizador
```cmd
GenerarActualizadorSqlServer.bat
```

### Paso 2: Ejecutar Actualización en Producción
```bash
node deploy/update_db_sqlserver.js
```
* **Comportamiento**: Aplica [ActualizadorSERVER.sql](file:///f:/Proyectos/AgenciasNew/SQL/Actualizador/ActualizadorSERVER.sql) de forma 100% idempotente (`IF NOT EXISTS` en tablas/columnas y reemplazo limpio de SPs).

---

## 7. Suite de Validación Completa y Control de Calidad

Ejecute la auditoría integral en 4 capas ejecutando:

```bash
node scripts/validate_full_suite.js
```

### Matriz de Auditoría Integrada:

```text
================================================================
         MATRIZ DE RESULTADOS DE LA VALIDACIÓN COMPLETA          
================================================================
┌─────────┬─────────────────────────────┬─────────────────────────────────────┬─────────┬─────────────────────────────────────────────────────────┐
│ (index) │ Capa                        │ Componente                          │ Estado  │ Detalle                                                 │
├─────────┼─────────────────────────────┼─────────────────────────────────────┼─────────┼─────────────────────────────────────────────────────────┤
│ 0       │ '1. PostgreSQL Local'       │ 'Conectividad & Tablas'             │ '✅ OK' │ '82 tablas activas'                                     │
│ 1       │ '1. PostgreSQL Local'       │ 'Datos Base (Roles/Branches)'       │ '✅ OK' │ '2 roles, 5 sucursales'                                 │
│ 2       │ '1. PostgreSQL Local'       │ 'Monedas Inyectadas'                │ '✅ OK' │ '133 monedas configuradas'                              │
│ 3       │ '2. Schema Reference'       │ 'SQL/schema_reference.json'         │ '✅ OK' │ 'Esquema de referencia registrado'                      │
│ 4       │ '3. Scripts T-SQL (04)'     │ '01_Tables.sql'                     │ '✅ OK' │ '20 tablas DDL en T-SQL'                                │
│ 5       │ '3. Scripts T-SQL (04)'     │ '02_Seeds.sql'                      │ '✅ OK' │ 'Semillas maestras preparadas'                          │
│ 6       │ '3. Scripts T-SQL (04)'     │ '03_Functions_And_SPs.sql'          │ '✅ OK' │ '4 SPs traducidos a T-SQL'                              │
│ 7       │ '4. Entregables Despliegue' │ '02 - setup_db_sqlserver.js'        │ '✅ OK' │ 'Garantizado NO CREATE DATABASE'                        │
│ 8       │ '4. Entregables Despliegue' │ '03 - gen_sqlserver_initial_bak.js' │ '✅ OK' │ 'Generador del backup Korex_SQLServer_Inicial_1.0.bak'   │
│ 9       │ '4. Entregables Despliegue' │ '05 - migrate_pg_to_sqlserver.js'   │ '✅ OK' │ 'Migrador PostgreSQL -> SQL Server con IDENTITY_INSERT' │
│ 10      │ '4. Entregables Despliegue' │ '06 - validate_migration.js'        │ '✅ OK' │ 'Auditor post-migración'                                │
└─────────┴─────────────────────────────┴─────────────────────────────────────┴─────────┴─────────────────────────────────────────────────────────┘

================================================================
   ESTADO GLOBAL: SISTEMA 100% OPERATIVO Y REGLAS CUMPLIDAS     
================================================================
```

---

## 8. Guía de Solución de Problemas (Troubleshooting)

### ❌ Error: *"Login failed for user 'korex_user'"*
* **Causa**: Contraseña incorrecta o SQL Server no está configurado en Modo Mixto.
* **Solución**: Abra SSMS, vaya a las propiedades del Servidor $\rightarrow$ **Security** y seleccione **SQL Server and Windows Authentication mode**. Reinicie el servicio SQL Server.

### ❌ Error: *"No se puede conectar en puerto 1433"*
* **Causa**: El protocolo TCP/IP está deshabilitado en SQL Server o el Firewall de Windows bloquea el puerto.
* **Solución**:
  1. Abra **SQL Server Configuration Manager**.
  2. Vaya a **SQL Server Network Configuration** $\rightarrow$ **Protocols for MSSQLSERVER**.
  3. Habilite **TCP/IP** y en las propiedades establezca **TCP Port** = `1433`.
  4. Reinicie el servicio SQL Server.
  5. Agregue una regla de entrada en el Firewall de Windows para el puerto `1433`.

### ❌ Error en Instalador: *"La base de datos no existe"*
* **Causa**: Se intenta ejecutar el instalador sin haber creado/restaurado la base de datos primero.
* **Solución**: El instalador no crea bases de datos. Restaure el archivo `Korex_SQLServer_Inicial_1.0.bak` antes de iniciar la instalación de la aplicación.
