# Reglas de Codificación y Desarrollo - Proyecto AgenciasNew

Este documento contiene las directrices, estándares y reglas del proyecto para guiar la asistencia en programación y despliegue del sistema AgenciasNew.

---

## 1. Reglas de Base de Datos y SQL

- **REGLA METODOLÓGICA DE CREACIÓN Y DISEÑO DE SKILLS**: Toda nueva Skill o actualización de Skill **DEBE redactarse como un principio de arquitectura universal, patrón abstracto de solución o regla de diseño reutilizable**, evitando limitar las instrucciones a casos de prueba puntuales o valores del momento. Debe abstraer la causa raíz técnica y ofrecer una directriz general que resuelva automáticamente esa categoría de problema en cualquier desarrollo futuro de la plataforma.
- **REGLA DE ORO DE DESARROLLO MULTIBASE (PostgreSQL + SQL Server)**: *"PostgreSQL y SQL Server son plataformas oficialmente soportadas. Todo cambio futuro debe diseñarse, implementarse y validarse para ambas desde el inicio. Ningún desarrollo se considera terminado si solo funciona en uno de los dos motores."* Se deben seguir estrictamente todas las directivas y el checklist obligatorio del Skill [`desarrollo-multibase`](file:///f:/Proyectos/AgenciasNew/.agents/skills/desarrollo-multibase/SKILL.md).
- **REGLA OBLIGATORIA DE TESTING AUTOMATIZADO MULTIBASE**: *"Todo cambio o requerimiento debe contar con su prueba automatizada ejecutable y ser validado en PostgreSQL y SQL Server con 100% de coincidencia funcional."* Se deben ejecutar y cumplir las 11 capas de verificación del Skill [`automated-multidb-testing`](file:///f:/Proyectos/AgenciasNew/.agents/skills/automated-multidb-testing/SKILL.md) (`node scripts/validate_full_suite.js`).
- **REGLA ABSOLUTA DE AISLAMIENTO DE MOTORES (UN MOTOR ACTIVO = UNA ÚNICA INFRAESTRUCTURA)**: *"PostgreSQL y SQL Server son infraestructuras independientes. Cuando el sistema opera en un motor seleccionado (`isSQLServerMode()`), el 100% de las operaciones, transacciones, SPs, importaciones, CRUDs, consultas y reportes DEBEN ejecutarse exclusivamente en ese motor. Queda estrictamente PROHIBIDO conectarse, insertar, actualizar, eliminar, consultar o ejecutar SPs en el motor que no se encuentra activo."* Se deben seguir estrictamente todas las directivas y la matriz de aislamiento del Skill [`motor-engine-isolation`](file:///f:/Proyectos/AgenciasNew/.agents/skills/motor-engine-isolation/SKILL.md).
- **REGLA DE SINCRONIZACIÓN AUTÓNOMA Y TIEMPO REAL ZEUS ERP (`zeus-sync`)**: *"Toda actualización o edición de procedimientos almacenados (`.sql`), funciones o tablas DDL en el proyecto DEBE sincronizarse e inyectarse automáticamente en la base de datos activa de Zeus ERP (SQL Server) en tiempo real durante el desarrollo."* Se debe usar la herramienta autónoma `node deploy/sync_zeus_erp.js` (o en modo observador `--watch`) y seguir el Skill [`zeus-sync`](file:///f:/Proyectos/AgenciasNew/.agents/skills/zeus-sync/SKILL.md).
- **REGLA ABSOLUTA DE IDENTIFICACIÓN DE BASE ZEUS ERP Y VALIDACIÓN DE SPS (`zeus-sp-execution-validator`)**: *"Siempre que se ejecute, sincronice o valide un Stored Procedure de integración con Zeus ERP (`spFacturacionesCrear`, `spCotizacionesCrear`), la base de datos destino es ESTRICTA Y EXCLUSIVAMENTE la configurada en los Parámetros del Sistema (`BaseSQLServer`), en este entorno `ZeusAgencias_23`, NUNCA `Korex_pruebas`. Queda estrictamente PROHIBIDO confundir `Korex_pruebas` (base interna de Korex) con `ZeusAgencias_23` (base protegida de Zeus ERP). Al terminar cualquier desarrollo que toque SPs de Zeus ERP, es OBLIGATORIO ejecutar `node scripts/validate_zeus_sps.js` para verificar la presencia activa de los SPs en Zeus ERP antes de dar por finalizada la tarea."* Seguir el Skill [`zeus-sp-execution-validator`](file:///f:/Proyectos/AgenciasNew/.agents/skills/zeus-sp-execution-validator/SKILL.md).
- **REGLA OBLIGATORIA DE SEPARACIÓN DE BASES DE DATOS (`.env` vs Parámetros → SQL Server)**: La base principal de Korex es únicamente la configurada en el `.env` (PostgreSQL o SQL Server local como `Korex_pruebas`), la cual almacena toda la operación interna, maestros, cotizaciones, facturas, movimientos, trazabilidad, diagnósticos y errores. La importación de Excel y la creación/edición local son **procesos 100% internos de Korex** y NUNCA deben invocar ni depender de los SPs de exportación a Zeus ERP (`spFacturacionesCrear`, `spCotizacionesCrear` en la base externa protegida `ZeusAgencias_23`) de forma automática. La exportación externa se ejecuta EXCLUSIVAMENTE al hacer clic en *"Enviar a Zeus ERP"* o cuando el parámetro automático (`EnviarFacturasAutoSQLserver` / `EnviarCotizacionesAutoSQLserver`) esté configurado explícitamente en `'1'`. Se deben seguir estrictamente todas las directivas del Skill [`db-separation-architecture`](file:///f:/Proyectos/AgenciasNew/.agents/skills/db-separation-architecture/SKILL.md).
- **REGLA CRÍTICA DE PROTECCIÓN DE BASES DE DATOS Y PREVENCIÓN DE PÉRDIDA DE INFORMACIÓN**: *"Ningún desarrollo, script, migración, instalador, proceso automático, prueba o actualización puede eliminar, recrear o reemplazar la base de datos principal de Korex (`.env`) ni la base externa protegida (`ZeusAgencias_23`). Toda migración debe ser estrictamente incremental y no destructiva (`ALTER TABLE`, `ADD COLUMN`, `CREATE INDEX`, `CREATE PROCEDURE`), preservando el 100% de la información operacional existente."* Se deben seguir estrictamente todas las directivas del Skill [`db-protection-security`](file:///f:/Proyectos/AgenciasNew/.agents/skills/db-protection-security/SKILL.md).
- **REGLA UNIVERSAL DE ASIGNACIÓN DE CUENTAS CONTABLES (`CARGOS` vs `IMPUESTOS`)**:
  - **Para CARGOS / SERVICIOS**: La determinación de la cuenta contable DEBE seguir estrictamente un orden de prioridad de 3 niveles:
    1. **1ª Prioridad - Tipo de Servicio (`TiposServicios.cd_cuenta`)**: Si el Tipo de Servicio posee una cuenta no nula y no vacía, se asigna esa cuenta.
    2. **2ª Prioridad - Concepto de Facturación (`ConceptoFacturacion.cd_cuenta`)**: Si el Tipo de Servicio no posee cuenta, se busca en el Concepto de Facturación.
    3. **3ª Prioridad - Cargo (`CargosDesc.cd_cuenta`)**: Como **último recurso**, si ni el Tipo de Servicio ni el Concepto de Facturación poseen cuenta, se toma la cuenta del Cargo.
    4. **Prohibición de Fallbacks Arbitrarios y Error Controlado**: Si NINGUNO de los 3 niveles posee cuenta contable parametrizada, QUEDA STRICTAMENTE PROHIBIDO asignar cuentas por defecto de forma arbitraria (ej. `ORDER BY id ASC`, `'28151080'`). En su lugar, se debe detener la transacción y emitir un error controlado (`RAISERROR` / excepción): `❌ Error de Parametrización Contable: No fue posible determinar la cuenta contable para el Cargo/Servicio "<NombreCargo>". Verifique la parametrización en Tipo de Servicio, Concepto de Facturación o Cargo.`
  - **Para IMPUESTOS**:
    1. La cuenta contable se obtiene **DIRECTAMENTE** de la configuración del Impuesto (`ImpRet.cd_cuenta`).
    2. **NO SE APLICA** la búsqueda de 3 niveles.
    3. Si el Impuesto no posee cuenta contable configurada, se debe detener la transacción y emitir un error controlado: `❌ Error de Parametrización Contable: El Impuesto "<NombreImpuesto>" no tiene cuenta contable configurada en la tabla de Impuestos (ImpRet).`
- **REGLA PRIMORDIAL DE ARQUITECTURA (Lógica en Base de Datos)**: Todo desarrollo, cálculo, proceso de negocio, liquidación, consulta de listado, validación o mutación de datos en AgenciasNew **DEBE realizarse obligatoria y prioritariamente a través de Procedimientos Almacenados (SPs), Funciones SQL y Tablas de Base de Datos** (PostgreSQL local `Korex_colaereo` y SQL Server producción).
  - **Excepción Única**: Únicamente cuando sea técnicamente imposible realizar el procesamiento dentro de la base de datos (por ejemplo: renderizado estético de interfaz React, manipulación directa del DOM o manejo de cookies HTTP de sesión en Edge Runtime), se permitirá implementar dicha lógica en el sitio web / frontend (Next.js).

### PostgreSQL (Base Local - Korex_colaereo)
- **Mayúsculas en Nombres de Tablas/Relaciones**: Las tablas del sistema local usan PascalCase y deben ser referenciadas exactamente igual con comillas dobles si es necesario (`public."Quotation"`, `public."Client"`, `public."QuotationProduct"`, `public."Role"`).
- **Tratamiento de Nulos y Joins**: 
  - Utilizar siempre `COALESCE` al realizar consultas para evitar valores inesperados de tipo `NULL`.
  - **Uso obligatorio de `LEFT JOIN`**: En funciones de listado/historial (`fnCotizacionListar`, `fnCotizacionHistorial`, `fnRoleListar`, `fnCotizacion`), usar **SIEMPRE `LEFT JOIN`** para las tablas relacionables (`Client`, `User`, `Branch`, etc.). NUNCA usar `INNER JOIN` (`JOIN`) al relacionar `Client` o `User` para evitar ocultar cotizaciones con clientes no asignados o descalzados en servidores externos.
  - En las cláusulas `WHERE`, asegurar que las búsquedas por texto soporten clientes o usuarios nulos: `(p_cliente IS NULL OR TRIM(p_cliente) = '' OR (c.name IS NOT NULL AND c.name ILIKE '%' || TRIM(p_cliente) || '%'))`.
- **Tratamiento de XML**: 
  - Al generar el XML de exportación en `spExportQuotation`, los nombres de las etiquetas deben ser coherentes (minúsculas).
  - Al agregar tablas secundarias como detalles, verificar la FK correcta usando el ID de referencia del producto/servicio (`orig_id_ref`) y no el ID de la cotización.
- **Garantía de Despliegues en Masa (0 Errores en Bases de Datos Actualizadas)**:
  - **Limpieza Dinámica Universal de Sobrecargas de SPs/Funciones**: Todo procedimiento almacenado o función en `Actualizador.sql` y en scripts `.sql` DEBE incluir un bloque `DO $$` que consulte `pg_proc` y elimine previamente cualquier firma/sobrecarga anterior del procedimiento o función (`DROP PROCEDURE/FUNCTION IF EXISTS ... CASCADE`). Esto evita de forma estricta que bases de datos de clientes actualizadas fallen con el error 42883 (`procedure does not exist`) al haber tenido firmas con distinto número o tipo de parámetros.
  - **Siembra Autodetectada de Secuencias (`CREATE SEQUENCE IF NOT EXISTS`)**: Ningún procedimiento almacenado, función o API puede depender de secuencias no declaradas (`error 42P01`). `deploy/gen_schema_json.js` auto-escaneará previamente (en PASO 0.5 antes de compilar SPs) todas las llamadas a `nextval(...)` en las carpetas `SQL/` y `src/app/api/`, creándolas inmediatamente en PostgreSQL local e inyectando `CREATE SEQUENCE IF NOT EXISTS public.nombre_secuencia START WITH 1;` en el nivel superior de `Alter_New_Columns.sql` y `Actualizador.sql`.
- **Regla General de Integridad Relacional, Columnas DDL y Prisma**:
  - **Prevención de Error 42703 (no existe la columna)**: Antes de escribir cualquier SP o consulta SQL que referencie una columna de tabla (ejemplo: `ip."ticketCode"`), **SE DEBE VERIFICAR Y DECLARAR LA COLUMNA PRIMERO**:
    1. En `SQL/Table/Alter_New_Columns.sql`: Tanto en `CREATE TABLE` como en el bloque de alteración `ALTER TABLE public."Tabla" ADD COLUMN IF NOT EXISTS "columna" tipo;`.
    2. En `prisma/schema.prisma`: Declarar el campo en el modelo correspondiente.
    3. Executar `node deploy/gen_schema_json.js`: Aplicar la alteración a PostgreSQL local y regenerar Prisma ORM (`npx prisma generate`) **ANTES** de compilar o invocar SPs o endpoints que consuman esa columna.
- **Garantía de Filtros y Datos Base (`base-data-integrity`)**: Toda actualización de base de datos o API base debe validar obligatoriamente las 4 capas del Skill [`base-data-integrity`](file:///f:/Proyectos/AgenciasNew/.agents/skills/base-data-integrity/SKILL.md), ejecutando `node deploy/gen_schema_json.js` y probando que `/api/quotations/base-data` devuelva HTTP 200 con todos sus arreglos poblados.
- **Flujo Obligatorio al modificar Funciones SQL / SPs (PostgreSQL + SQL Server)**:
  1. **Compilación e Inyección Inmediata Local**: Ejecutar obligatoria e INMEDIATAMENTE en el mismo turno el desplegador e inyector de base de datos en los entornos locales de PostgreSQL (`node deploy/gen_schema_json.js`) y SQL Server activos. NUNCA responder al usuario ni terminar el turno tras tocar o corregir un `.sql` sin haber inyectado y verificado la compilación limpia en la base de datos local.
  2. Consultar al usuario en español si desea generar el instalador y actualizador automáticamente o si prefiere realizarlo manualmente (Skill [`installer-decision`](file:///f:/Proyectos/AgenciasNew/.agents/skills/installer-decision/SKILL.md)).
  3. Si aprueba automático: Generar el empaquetado standalone (`powershell.exe -ExecutionPolicy Bypass -File deploy/Generar_Empaquetado.ps1`) y compilar con `GenerarSetup.bat` / `GenerarActualizador.bat`.
  4. Si prefiere manual: Entregar instrucciones y scripts para compilación manual por parte del usuario.

### SQL Server (Base de Producción/Agencias)
- **Estructura Zeus ERP**: Las tablas del ERP Zeus tienen nombres de columna heredados específicos. Evitar el uso de nombres genéricos:
  - En `dbo.CLIENTES`, usar `IDCLIENTE`, `RAZONCIAL`, `DIRECCION`, `TELEFONO`, `CIUDAD`, `EMAIL`.
  - En `dbo.MAEVENDE`, usar `IDVENDE`, `NOMBVENDE`.
  - En `dbo.PROVEEDORES`, usar `IDPROVE`, `RAZONCIAL`, `CODICTA`.
- **Sensibilidad a Mayúsculas en XML XPath**: Al procesar el XML importado en `spCotizacionesCrear`, utilizar exactamente las etiquetas generadas en Postgres (minúsculas como `cd_cotizacion`, `ds_fpnm`, `am_valor_me`, etc.) ya que la función `.value()` de SQL Server es strictly Case-Sensitive.
- **Sincronización del Actualizador**: Cualquier cambio realizado en los Procedimientos Almacenados (ej. `spCotizacionesCrear.sql` o `spFacturacionesCrear.sql`) **debe ser replicado obligatoriamente** en el archivo del script actualizador `SQL/Actualizador/ActualizadorSERVER.sql` y `SQL/Actualizador/Actualizador.sql`.
- **Casteo y Binding Dinámico de Parámetros T-SQL (`src/lib/sqlserver.ts`)**: Todo parámetro pasado a `executeSQLServerProcedure` DEBE evaluar dinámicamente su tipo JavaScript: enteros a `mssql.Int`, flotantes a `mssql.Float`, booleanos a `mssql.Bit` y nulos a `null`. NUNCA enviar números enteros a ciegas como `mssql.VarChar(MAX)`.
- **Resiliencia de Llaves Foráneas (FK) en SPs T-SQL**: Todo procedimiento de creación o edición (`spCotizacionCrear`, `spCotizacionActualizar`, etc.) DEBE validar la existencia de llaves foráneas optativas (`clientId`, `branchId`, `sellerId`, `implantId`, `ticketPrinterId`, `userId`) antes de insertar (`IF @clientId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.[Client] WHERE id = @clientId) SET @clientId = NULL;`), evitando que inserciones fallen si las tablas maestras locales están vacías.
- **Reseteo Universal de Consecutivos (IDs) al Vaciar Tablas**: Todo procedimiento de eliminación (`spCotizacionEliminar`, etc.) DEBE verificar si la tabla principal quedó totalmente vacía tras el borrado (`IF NOT EXISTS (SELECT 1 FROM dbo.[Quotation])`) y ejecutar `DBCC CHECKIDENT ('dbo.[Quotation]', RESEED, 0);` en SQL Server y reiniciar la secuencia correspondiente en PostgreSQL, garantizando que el siguiente registro inicie obligatoriamente en ID **#1**.
- **Defectos Numéricos y Nulabilidad Resiliente en DDL**: Todos los campos numéricos o financieros en `SQL/SqlServer/01_Tables.sql` DEBEN definirse como `FLOAT NULL CONSTRAINT DF_... DEFAULT 0` o `INT NULL`, evitando errores de inserción nula cuando faltan parámetros opcionales.

---

## 2. Reglas de Next.js y TypeScript (Frontend)

- **Puerto del Servidor**: El servidor local de desarrollo y producción de Next.js se arranca por defecto en el puerto **`3001`** (configurado en `iniciar-next.bat`).
- **Prisma ORM**: 
  - Al realizar modificaciones de base de datos en Postgres, ejecutar siempre `npx prisma db pull` seguido de `npx prisma generate` para sincronizar los modelos locales.
  - Asegurar la detención y el reinicio correcto del servidor Next.js cuando se modifique el esquema de la base de datos o variables de entorno.
- **Acceso a Datos**: Usar las relaciones de Prisma de forma segura y tipada en TypeScript, manejando correctamente los posibles nulos.
- **Validación Obligatoria de Listado en Maestros**: Antes de dar por finalizado cualquier desarrollo o modificación en cualquier pantalla o maestro (Cargos e Impuestos, Proveedores, Clientes, Usuarios, Productos, Sucursales, etc.), se debe ejecutar obligatoriamente la prueba de la API o función de consulta/listado correspondiente (`public.fn...Listar()` o API Route) y validar que liste los datos de manera limpia, sin desalinear columnas y sin devolver `0 registros` por fallas no capturadas.

---

## 3. Reglas de Control de Cambios y Git

- **Pruebas y Despliegue Local**: Todo desarrollo, modificación de base de datos o cambio en la interfaz debe ser generado y probado de manera strictly local.
- **Subida Completa del Proyecto Local**: Cuando el usuario indique **"subir a git"** (o equivalentes), se debe subir **todo el estado del proyecto local** (`git add .`), incluyendo nuevos scripts, modales, endpoints, componentes, funciones SQL y actualizadores creados, respetando únicamente el `.gitignore`.
- **Autorización para Git**: Bajo ninguna circunstancia se deben subir cambios a Git o realizar commits en ramas remotas sin la previa verificación de pruebas locales y la autorización explícita del usuario.
- **Descargas y Actualizaciones de Git**: No se deben realizar descargas automáticas, actualizaciones, clonaciones o `git pull` de ramas remotas de forma automática. Cualquier descarga o actualización de código desde Git debe realizarse única y exclusivamente cuando el usuario lo solicite de manera explícita.

---

## 4. Regla de Actualización Continua del Manual Operativo Interactivo

- **Actualización Obligatoria**: Cada vez que se agregue o modifique un desarrollo en la plataforma (nuevo SP, API route, modal o pantalla), se DEBE actualizar obligatoriamente el archivo [`src/data/manual/modules.ts`](file:///f:/Proyectos/AgenciasNew/src/data/manual/modules.ts) siguiendo la guía del Skill [`manual-updater`](file:///f:/Proyectos/AgenciasNew/.agents/skills/manual-updater/SKILL.md).
- **Mantenimiento**: La documentación interactiva disponible en la ruta `/dashboard/manual` debe acumular y reflejar de manera continua e incremental todas las funcionalidades activas del sistema.

---

## 5. Regla de Registro Estricto en Creación de Maestros (`TAB_CONFIG`)

- **Prohibición Absoluta de Fallbacks a "Implant"**: Todo nuevo maestro agregado a `/dashboard/settings` debe declararse obligatoriamente en el diccionario fuertemente tipado `TAB_CONFIG: Record<Tab, TabConfigItem>` en [`src/app/dashboard/settings/page.tsx`](file:///f:/Proyectos/AgenciasNew/src/app/dashboard/settings/page.tsx). Queda estrictamente prohibido usar cadenas de ternarios o fallbacks por defecto hacia `'Implant'` o `'/api/config/implants'`.
- **Skill Obligatorio**: Al crear o modificar cualquier maestro, se deben seguir sin excepción las instrucciones del Skill [`master-creation`](file:///f:/Proyectos/AgenciasNew/.agents/skills/master-creation/SKILL.md).

---

## 6. Reglas de Preservación y Sembrado en Empaquetado y Actualizadores

- **Siembra Obligatoria de Módulos de Menú (`public."Menu"`)**: Todo nuevo módulo de navegación (`Pre-Cotizaciones`, `Ejecuciones`, `Manual Operativo`, etc.) **DEBE ser sembrado e inyectado explícitamente en [`SQL/Table/Alter_New_Columns.sql`](file:///f:/Proyectos/AgenciasNew/SQL/Table/Alter_New_Columns.sql)** con `CREATE UNIQUE INDEX IF NOT EXISTS "Menu_code_key"` e `INSERT ... ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;`. De lo contrario, las bases de datos de clientes actualizados no recibirán los nuevos módulos en el menú lateral.
- **Siembra Obligatoria de Tablas Maestras (`public."Master"`)**: Todo nuevo maestro parametrizable agregado al sistema (`Tipos de Proveedor`, `Extracción Interfaces`, `Resoluciones`, `Consecutivos`, etc.) **DEBE ser sembrado explícitamente en [`SQL/Table/Alter_New_Columns.sql`](file:///f:/Proyectos/AgenciasNew/SQL/Table/Alter_New_Columns.sql)** con `CREATE UNIQUE INDEX IF NOT EXISTS "Master_code_key"` e `INSERT ... ON CONFLICT (code) DO NOTHING;`. Esto garantiza que la tarjeta con el interruptor para habilitar o deshabilitar la pestaña aparezca inmediatamente en `Módulos del Sitio`.
- **Preservación Estricta de Parámetros (`SystemParameter ON CONFLICT DO NOTHING`)**: Queda estrictamente prohibido utilizar `ON CONFLICT (code) DO UPDATE SET value = EXCLUDED.value;` en scripts de siembra de parámetros (`SystemParameter` en `SQL/Inicial.sql` o `Alter_New_Columns.sql`). Se debe usar **SIEMPRE `ON CONFLICT (code) DO NOTHING;`** para evitar sobreescribir o borrar la configuración de servidores y credenciales de la agencia en el cliente.
- **Visibilidad Permanente de Licencia (`<LicenseStatusCard />`)**: La pantalla de Configuración del Sistema (`src/app/dashboard/settings/page.tsx`) debe incluir de manera fija e inamovible el componente `<LicenseStatusCard />` para desplegar el estado de vigencia, NIT, razón social y panel de renovación/activación de claves cifradas (`KOR1`).
- **Verificación Automatizada Obligatoria**: Antes de generar ejecutables instaladores/actualizadores (`Korex_Setup.exe` y `Korex_Update_Setup.exe`), es obligatorio ejecutar `node deploy/gen_schema_json.js`, el cual valida automáticamente estas reglas en 6 capas de seguridad (Skill [`updater-verification`](file:///f:/Proyectos/AgenciasNew/.agents/skills/updater-verification/SKILL.md)).

---

## 7. Regla de Impresión y Comisiones (`quotation-print-commissions`)

- **Procesamiento de Comisiones y Empaquetado**: Toda modificación en el cálculo de comisiones, plantillas HTML de impresión o empaquetado standalone debe seguir estrictamente las directrices del Skill [`quotation-print-commissions`](file:///f:/Proyectos/AgenciasNew/.agents/skills/quotation-print-commissions/SKILL.md).

---

## 8. Reglas de Armonía y Estándar de Diseño de UI (`ui-design-harmony`)

- **Estandarización Obligatoria de Botones y Componentes**: Todo nuevo botón de creación (`+ Nuevo ...`), botón secundario, modal, icono de menú lateral o tarjeta de maestro **DEBE cumplir estrictamente los patrones de estilo y tokens Tailwind definidos en el Skill [`ui-design-harmony`](file:///f:/Proyectos/AgenciasNew/.agents/skills/ui-design-harmony/SKILL.md)**.
- **Prohibición de Estilos Inconsistentes**: Queda estrictamente prohibido usar colores arbitrarios o dispares (ej. botones de creación negros, naranjas o verdes sin justificación de token) o tamaños desiguales (`h-14`, `h-11`, `text-xs`) entre módulos. Los botones de creación principal siempre serán de azul primario (`bg-blue-600 hover:bg-blue-700 text-white rounded-xl h-12 px-5 text-sm font-bold shadow-md shadow-blue-500/20`).

---

## 9. Regla de Arquitectura de Instalación y Despliegue SQL Server (Base Inicial .BAK vs Migración)

- **Prohibición Absoluta de `CREATE DATABASE` en Instaladores**: El instalador de SQL Server **NO DEBE ejecutar `CREATE DATABASE`** ni depender de que el usuario ejecutor posea permisos administrativos para crear bases de datos. La infraestructura/cliente es la única responsable de crear/restaurar la base de datos y entregar las credenciales de conexión (`Servidor`, `Instancia`, `Puerto`, `Base de Datos`, `Usuario`, `Clave`). El instalador únicamente valida la conexión y los permisos en la base existente.
- **Entrega de Base SQL Server Inicial en Blanco (`.BAK`)**: Debe existir un proceso independiente mediante el cual el equipo de desarrollo genere un archivo de backup en blanco (`Korex_SQLServer_Inicial_X.X.bak`) preparado para nuevas instalaciones de clientes. Este backup debe contener:
  - Estructura completa de tablas, PKs, FKs, índices, constraints, vistas, SPs, funciones, triggers y consecutivos.
  - Catálogos maestros obligatorios y parámetros básicos requeridos por la aplicación.
  - **Sin información operativa del cliente**.
- **Generación Automatizada del Backup Inicial**: El proyecto debe contar con un procedimiento documentado/script que cree una base de datos temporal, aplique la estructura T-SQL completa, inyecte las semillas iniciales, valide la integridad y exporte el archivo `.BAK` emparejado con la versión exacta de la aplicación (`Korex_SQLServer_Inicial_1.0.bak`).
- **Separación Estricta entre Base Inicial y Migración**:
  - **Cliente Nuevo**: Restaura la base inicial `.BAK` en blanco y configura la conexión de la aplicación.
  - **Cliente Existente (PostgreSQL)**: Ejecuta el proceso de migración independiente `PostgreSQL -> SQL Server` para trasladar sus datos operativos y luego configura la aplicación.
- **Auditoría Automatizada Obligatoria de Entregables (`scripts/validate_full_suite.js`)**: Todo cambio en T-SQL, actualizadores o instaladores de SQL Server DEBE ser verificado ejecutando `node scripts/validate_full_suite.js` en 11 capas de seguridad (Skill [`updater-verification`](file:///f:/Proyectos/AgenciasNew/.agents/skills/updater-verification/SKILL.md)), garantizando 22 SPs T-SQL, 3 Funciones Escalares, 20 Tablas DDL y exportación limpia en `deploy/BaseLimpia/Korex_SQLServer_Inicial_1.0.bak`.
- **6 Componentes de Entregables del Proyecto**:
  1. `01 - Instalador PostgreSQL`: Se mantiene sin modificaciones funcionales.
  2. `02 - Instalador SQL Server`: Instala/configura la aplicación y valida la conexión; NO crea la base de datos.
  3. `03 - Base SQL Server inicial`: Archivo `.BAK` estructurado en blanco sin datos operativos.
  4. `04 - Scripts SQL Server`: Scripts T-SQL que permiten reconstruir la estructura y generar nuevas versiones del `.BAK`.
  5. `05 - Proceso de migración`: Herramienta independiente para trasladar datos desde PostgreSQL hacia SQL Server.
  6. `06 - Proceso de validación`: Validador de integridad para comparar y verificar la información migrada.

---

## 10. Regla de Trazabilidad y Diagnóstico del Sistema (`traceability-diagnostics`)

- **Trazabilidad Transversal Obligatoria**: Toda nueva funcionalidad desarrollada en el proyecto debe diseñarse considerando el mecanismo centralizado de trazabilidad (`TRC-YYYYMMDD-XXXXXX`).
- **Control de Niveles**: Se debe respetar el parámetro de configuración `TRACEABILITY_MODE` (`OFF`, `BASIC`, `DETAILED`, `DIAGNOSTIC`).
- **Garantía Multibase**: Toda infraestructura de trazabilidad debe funcionar con 100% de equivalencia en PostgreSQL y SQL Server siguiendo el Skill [`traceability-diagnostics`](file:///f:/Proyectos/AgenciasNew/.agents/skills/traceability-diagnostics/SKILL.md).
- **Protección de Datos Sensibles**: Queda estrictamente prohibido registrar contraseñas, tokens o números de tarjetas de crédito sin enmascarar (`***MASKED***`).

---

## 11. Regla Permanente de Protección, Permanencia de Correcciones y Regresión (`correcciones-permanencia-proteccion`)

- **NINGUNA CORRECCIÓN VALIDADA PUEDE PERDERSE**: Se prohíbe estrictamente eliminar, reemplazar, degradar o ignorar cualquier corrección o funcionalidad previa al implementar un nuevo requerimiento. Toda corrección validada se convierte en una prueba de regresión protegida.
- **Investigación Obligatoria Pre-Desarrollo**: Antes de modificar código o SQL, el agente debe investigar todo el contexto existente (`Buscar -> Analizar -> Preservar -> Modificar -> Probar`).
- **Regla de No Sobrescritura**: Queda estrictamente prohibido reemplazar archivos, SPs, funciones o componentes completos sin integrar aditivamente la versión actual con los cambios previos y el nuevo requerimiento.
- **Checklist Obligatorio de Aceptación**: Ningún desarrollo se considera terminado sin haber validado la suite automatizada de regresión (`node scripts/validate_full_suite.js`) en PostgreSQL y SQL Server y completado el checklist del Skill [`correcciones-permanencia-proteccion`](file:///f:/Proyectos/AgenciasNew/.agents/skills/correcciones-permanencia-proteccion/SKILL.md).

---

## 12. Regla Obligatoria de Separación Total de Instaladores y Actualizadores (`separacion-instaladores-actualizadores`)

- **Separación Absoluta de Procesos y Archivos**: Cada motor debe disponer de sus propios procesos, archivos, scripts, configuraciones y ejecutables de instalación y actualización. Queda estrictamente prohibido utilizar un instalador genérico que determine dinámicamente el motor o compartir procesos de instalación entre ambos motores.
- **Matriz Obligatoria de Archivos y Motores**:
  - **PostgreSQL**: `GenerarSetup.bat` y `GenerarActualizador.bat` son **EXCLUSIVOS** de PostgreSQL. Prohibido incluir scripts o consultar SQL Server.
  - **SQL Server**: `GenerarSetupSqlServer.bat` y `GenerarActualizadorSqlServer.bat` son **EXCLUSIVOS** de SQL Server. Prohibido incluir scripts o consultar PostgreSQL.
- **Prohibición de Instaladores Híbridos y Dinámicos**: La selección del motor debe estar determinada DESDE EL PROCESO DE GENERACIÓN (`GENERACIÓN -> INSTALACIÓN -> CONFIGURACIÓN -> ACTUALIZACIÓN -> EJECUCIÓN`).
- **Instalador SQL Server NO Crea la Base de Datos**: Asume que la base de datos SQL Server debe existir previamente (creada/restaurada por el administrador/cliente). Valida servidor, base de datos y credenciales, pero **NUNCA ejecuta `CREATE DATABASE`**.
- **Independencia Cruzada**: La ejecución o generación de un instalador para un motor garantiza 0 modificaciones en los archivos del otro motor.
- **Integración con Protección de Correcciones**: Cada instalador/actualizador posee su propio historial de cambios y pruebas de regresión protegidas según el Skill [`separacion-instaladores-actualizadores`](file:///f:/Proyectos/AgenciasNew/.agents/skills/separacion-instaladores-actualizadores/SKILL.md).





