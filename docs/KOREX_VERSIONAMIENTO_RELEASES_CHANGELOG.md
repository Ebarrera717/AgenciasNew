# DOCUMENTO DEFINITIVO — POLÍTICA DE VERSIONAMIENTO, RELEASES Y CHANGELOG DE KOREX

```
============================================================
KOREX
POLÍTICA OFICIAL DE VERSIONAMIENTO, RELEASES,
TRAZABILIDAD, VALIDACIÓN Y CHANGELOG
============================================================
Documento: KOREX-VERSIONAMIENTO-001
Versión del documento: 1.0
Estado: OBLIGATORIO
Aplicación: Todo el proyecto Korex
Motores soportados: PostgreSQL y SQL Server
============================================================
```

---

## 1. OBJETIVO

Establecer una política obligatoria y permanente para:
- Generar versiones de Korex.
- Controlar cambios.
- Evitar pérdida de correcciones.
- Evitar regresiones.
- Mantener trazabilidad completa.
- Identificar exactamente qué versión está instalada.
- Identificar exactamente qué código fue utilizado para generar una versión.
- Controlar los cuatro procesos de instalación/actualización.
- Validar PostgreSQL y SQL Server.
- Documentar los cambios realizados.
- Entregar al cliente información clara y verificable de cada versión.
- Permitir que el cliente pueda validar funcionalmente los cambios de cada versión.

**NINGUNA VERSIÓN DE KOREX SE CONSIDERA OFICIALMENTE LIBERADA SI NO CUMPLE ESTA POLÍTICA.**

---

## 2. PRINCIPIO FUNDAMENTAL

Toda modificación realizada sobre Korex debe poder responder claramente:
1. ¿Qué se cambió?
2. ¿Por qué se cambió?
3. ¿Qué problema solucionó?
4. ¿Qué funcionalidad afecta?
5. ¿Qué archivos/componentes fueron modificados?
6. ¿Qué objetos de base de datos fueron modificados?
7. ¿Qué motores fueron afectados?
8. ¿Qué riesgos tiene?
9. ¿Cómo fue probado?
10. ¿Qué debe validar el cliente?
11. ¿Qué versión contiene la corrección?
12. ¿Qué versión anterior tenía el problema?
13. ¿Qué resultado se esperaba?
14. ¿Qué resultado se obtuvo?

Si una modificación no puede responder estas preguntas, **NO debe considerarse completamente documentada**.

---

## 3. ESQUEMA DE VERSIONAMIENTO

Korex utilizará el estándar **Semantic Versioning 2.0.0 (SemVer)**:
$$\text{MAJOR}.\text{MINOR}.\text{PATCH}$$
*Ejemplo:* `3.7.12`

Donde:
- **MAJOR**: cambios incompatibles o arquitectónicos mayores.
- **MINOR**: nuevas funcionalidades compatibles.
- **PATCH**: correcciones, ajustes y mejoras compatibles.

### 3.1 MAJOR
*Ejemplo:* `3.9.15` → `4.0.0`
Se utilizará únicamente cuando exista:
- Cambio arquitectónico incompatible.
- Cambio incompatible de interfaces.
- Cambio que obligue a modificar procesos existentes.
- Cambio importante de contrato funcional.
- Cambio que requiera migración especial.
- Cambio que rompa compatibilidad con instalaciones existentes.
*Nota:* No incrementar MAJOR simplemente porque el cambio sea grande.

### 3.2 MINOR
*Ejemplo:* `3.7.12` → `3.8.0`
Se utilizará para:
- Nuevas funcionalidades.
- Nuevos módulos.
- Nuevos informes.
- Nuevas opciones.
- Nuevas integraciones.
- Ampliaciones compatibles.
- Mejoras funcionales que no rompen la compatibilidad.

### 3.3 PATCH
*Ejemplo:* `3.7.12` → `3.7.13`
Se utilizará para:
- Corrección de errores.
- Corrección de regresiones.
- Corrección de SP.
- Corrección de funciones.
- Corrección de consultas.
- Corrección de procesos.
- Corrección de instaladores.
- Corrección de actualizadores.
- Corrección de problemas PostgreSQL.
- Corrección de problemas SQL Server.
- Ajustes de interfaz.
- Optimizaciones compatibles.
- Correcciones de seguridad.
- Correcciones de trazabilidad.

---

## 4. REGLA DE INMUTABILIDAD

**UNA VERSIÓN PUBLICADA ES INMUTABLE.**

*Ejemplo:* Korex `3.7.12`
Una vez liberada, **NO** puede modificarse y volver a distribuirse como `3.7.12`.

Si posteriormente se encuentra un error:
$$\text{3.7.12} \longrightarrow \text{corrección} \longrightarrow \text{3.7.13}$$

Está **ESTRICTAMENTE PROHIBIDO**:
- `"3.7.12 corregida"`
- `"3.7.12 final"`
- `"3.7.12 definitiva"`
- `"3.7.12 nueva"`
- `"3.7.12 final2"`

Toda modificación genera obligatoriamente una nueva versión.

---

## 5. BUILD NUMBER

Además de la versión funcional, cada compilación debe tener un identificador único de **BUILD**.

*Ejemplo:*
- Versión: `3.7.13`
- Build: `20260923.01`

**Formato recomendado:** `YYYYMMDD.NN`
- `YYYYMMDD`: fecha de compilación
- `NN`: número secuencial de compilación del día

*El Build NO reemplaza la versión. Sirve para identificar exactamente el artefacto generado.*

---

## 6. COMMIT / IDENTIFICADOR DEL CÓDIGO

Toda versión liberada debe quedar asociada al identificador exacto del código utilizado. Debe registrarse:
- Versión
- Build
- Commit
- Fecha
- Rama
- Responsable de release

*Ejemplo:*
- Versión: `3.7.13`
- Build: `20260923.01`
- Commit: `8f42a91`
- Rama: `release/3.7.13`

---

## 7. VERSIÓN DE BASE DE DATOS

La versión de aplicación y la versión de estructura de base de datos deben ser trazables independientemente:
- `APP_VERSION = 3.7.13`
- `DB_SCHEMA_VERSION = 3.7.13`
- `BUILD = 20260923.01`

Debe poder determinarse qué estructura de base de datos espera cada versión de Korex.

---

## 8. POSTGRESQL Y SQL SERVER

PostgreSQL y SQL Server son plataformas oficialmente soportadas. Una versión funcional de Korex debe validarse en ambos motores.

$$\text{Korex 3.7.13} \begin{cases} \text{PostgreSQL} \\ \text{SQL Server} \end{cases}$$

- No se debe considerar liberada una versión solamente porque funcione en PostgreSQL.
- Tampoco se debe considerar liberada solamente porque funcione en SQL Server.

### 8.1 REGLA DE AISLAMIENTO
- Cuando se ejecuta Korex sobre PostgreSQL: **SOLO PostgreSQL**.
- Cuando se ejecuta Korex sobre SQL Server: **SOLO SQL Server**.
- No se permiten conexiones ocultas al otro motor.
- No se permite fallback automático, conexión alternativa silenciosa, sincronización automática, creación de objetos en el otro motor, ni migraciones en el motor no seleccionado.

---

## 9. LOS CUATRO PROCESOS DE EMPAQUETADO

Deben permanecer completamente separados e independientes:
1. `GenerarSetup.bat` $\longrightarrow$ PostgreSQL Setup Inicial
2. `GenerarActualizador.bat` $\longrightarrow$ PostgreSQL Actualizador
3. `GenerarSetupSqlServer.bat` $\longrightarrow$ SQL Server Setup Inicial
4. `GenerarActualizadorSqlServer.bat` $\longrightarrow$ SQL Server Actualizador

Cada proceso debe poder identificarse claramente en el CHANGELOG y en el registro de release.

---

## 10. POLÍTICA DEL ARCHIVO `.ENV`

La política del `.env` es obligatoria:
- **SETUP**: CREA EL `.env` DESDE CERO.
- **ACTUALIZADOR**: CONSERVA EL `.env` EXISTENTE.

El actualizador **NO** puede:
- Reemplazarlo
- Sobrescribirlo
- Regenerarlo
- Eliminarlo
- Moverlo
- Modificar credenciales
- Modificar servidor
- Modificar puerto
- Modificar base de datos
- Modificar proveedor
- Modificar conexiones existentes

El `.env` de pruebas **NUNCA** debe transportarse a producción.

Si durante una actualización el `.env` cambia: **LA ACTUALIZACIÓN DEBE CONSIDERARSE FALLIDA**.
Debe:
1. Detectar el cambio.
2. Restaurar el `.env` protegido.
3. Validar integridad.
4. Validar conexión.
5. Registrar el incidente.
6. NO informar actualización exitosa.

---

## 11. BASE DE DATOS EXTERNA ZEUS ERP

Zeus ERP (`ZeusAgencias_23`) es una base externa de interfase. Korex **NO** debe modificar objetos nativos existentes de Zeus ERP.

Está prohibido modificar: tablas, SPs nativos, funciones nativas, vistas, triggers, índices, constraints, estructura o configuración existente.

Si Korex requiere lógica adicional: **CREAR SP/OBJETOS PROPIOS DE KOREX** (`SQL/ZeusERP/`) o resolver la lógica dentro de Korex. Nunca modificar un SP externo para "facilitar" Korex.

Los objetos propios deben:
- Tener nombres identificables (`spCotizacionesCrear`, `spFacturacionesCrear`).
- Estar documentados y versionados.
- Tener scripts controlados.
- No reemplazar objetos existentes.

---

## 12. CADA CORRECCIÓN DEBE GENERAR PRUEBA DE REGRESIÓN

Toda corrección debe convertirse, cuando técnicamente sea posible, en una prueba de regresión permanente.

*Ejemplo:*
- **Problema**: `EnviarFacturacionAutoSQLserver = 1` pero no se generaba el proceso esperado.
- **Corrección**: Se corrige el proceso.
- **Prueba permanente**:
  1. Verificar parámetro = 1.
  2. Ejecutar proceso.
  3. Verificar generación.
  4. Verificar resultado.
  5. Verificar trazabilidad.
  6. Verificar PostgreSQL.
  7. Verificar SQL Server.

La corrección **no se considera completa** hasta que la prueba automatizada pueda detectar nuevamente el problema si alguien lo reintroduce.

---

## 13. CHANGELOG – DOCUMENTO OFICIAL PARA EL CLIENTE Y EL EQUIPO

El `CHANGELOG.md` será el registro oficial de cambios funcionales y técnicos relevantes de Korex.
- Debe estar escrito para personas, no como una simple lista de commits.
- Debe permitir que el cliente entienda: qué cambió, qué problema existía, qué fue solucionado, qué debe probar y cuál es el resultado esperado.

---

## 14. ESTRUCTURA OBLIGATORIA DEL CHANGELOG

Cada versión debe contener:
- Versión
- Fecha
- Tipo de release
- Build
- Commit
- Resumen ejecutivo
- Problemas corregidos
- Funcionalidades nuevas
- Cambios funcionales
- Cambios de base de datos
- Cambios PostgreSQL
- Cambios SQL Server
- Cambios de interfaz
- Cambios de integración
- Cambios de instalador
- Cambios de actualizador
- Seguridad
- Rendimiento
- Regresiones corregidas
- Impacto
- Riesgo
- Compatibilidad
- Pruebas realizadas
- Resultado de pruebas
- Validación requerida por el cliente
- Resultado esperado
- Consideraciones de actualización

---

## 15. IDENTIFICADOR ÚNICO DE CADA CAMBIO

Cada cambio importante debe tener un identificador único:
$$\text{KRX-YYYY-NNNNN}$$
*Ejemplo:* `KRX-2026-00125`

El identificador debe mantenerse durante todo su ciclo de vida:
$$\text{Requerimiento} \longrightarrow \text{Desarrollo} \longrightarrow \text{Prueba} \longrightarrow \text{Release} \longrightarrow \text{CHANGELOG}$$

---

## 16. FORMATO DETALLADO DE CADA CAMBIO

Cada cambio relevante debe documentarse bajo la siguiente ficha:

```text
------------------------------------------------------------
ID DEL CAMBIO: KRX-2026-00125
TIPO: Fixed / Added / Changed / Security
TÍTULO: Corrección del envío automático de facturación SQL Server
PROBLEMA REPORTADO: Describir exactamente qué estaba ocurriendo.
COMPORTAMIENTO ANTERIOR: Describir qué hacía el sistema antes de la corrección.
CAUSA: Describir la causa técnica cuando esté identificada.
SOLUCIÓN IMPLEMENTADA: Describir exactamente qué fue modificado.
COMPONENTES AFECTADOS:
  Backend:
  Frontend:
  SP:
  Función:
  Tabla:
  Integración:
  Instalador:
  Actualizador:
MOTOR: PostgreSQL / SQL Server / Ambos
COMPORTAMIENTO NUEVO: Describir qué ocurre después de la corrección.
IMPACTO FUNCIONAL: Explicar qué cambia para el usuario.
RIESGO: Bajo / Medio / Alto
COMPATIBILIDAD: Indicar versiones/ambientes afectados.
PRUEBAS REALIZADAS: Enumerar las pruebas.
RESULTADO: OK / NO OK
REGRESIÓN: Indicar prueba creada o actualizada.
VALIDACIÓN DEL CLIENTE: Indicar exactamente qué debe verificar.
PASOS DE VALIDACIÓN:
  1. 
  2. 
  3. 
  4. 
RESULTADO ESPERADO: Describir claramente el resultado.
------------------------------------------------------------
```

---

## 17. EL CHANGELOG DEBE SER UTILIZABLE POR EL CLIENTE

- **PROHIBIDO**: Escribir vagas generalidades como *"Se hicieron ajustes en facturación."*
- **OBLIGATORIO**: Escribir explicaciones claras y reproducibles:
  > *"Se corrigió el proceso de envío automático de facturación cuando el parámetro EnviarFacturacionAutoSQLserver está configurado en 1.*
  > *Antes: el sistema podía no generar el envío automático aun cuando el parámetro estuviera habilitado.*
  > *Ahora: con el parámetro en 1, el proceso debe ejecutar el envío automático correspondiente.*
  > *Validación:*
  > *1. Configurar EnviarFacturacionAutoSQLserver = 1.*
  > *2. Generar una factura de prueba.*
  > *3. Ejecutar el proceso automático.*
  > *4. Verificar que el envío se genere.*
  > *5. Verificar la trazabilidad.*
  > *Resultado esperado: el envío automático debe generarse correctamente."*

El cliente debe poder ejecutar la validación sin necesidad de conocer el código fuente.

---

## 18. NO OCULTAR CAMBIOS TÉCNICOS IMPORTANTES

El CHANGELOG destinado al cliente debe ser entendible, pero **NO debe ocultar cambios** que puedan afectar:
- Base de datos
- Rendimiento
- Integraciones
- Seguridad
- Instalación / Actualización
- Configuración
- Compatibilidad
- Comportamiento existente

---

## 19. DOCUMENTACIÓN DE CAMBIOS DE BASE DE DATOS

Cuando una versión modifique la base de datos se debe indicar:
- Motor
- Objeto
- Tipo de cambio
- Motivo
- Impacto
- Compatibilidad
- Migración requerida
- Rollback disponible
- Validación

*Ejemplo:*
```text
Motor: SQL Server
Objeto: SP_Korex_Facturacion
Cambio: corrección de validación
Motivo: evitar generación incorrecta
Migración: requerida
Rollback: disponible
PostgreSQL: validado
Resultado: OK
```

---

## 20. CAMBIOS QUE AFECTEN AMBOS MOTORES

Si una funcionalidad fue modificada para ambos motores, el CHANGELOG debe indicar expresamente:
- `PostgreSQL: IMPLEMENTADO Y VALIDADO`
- `SQL Server: IMPLEMENTADO Y VALIDADO`

**PROHIBIDO** utilizar `"Base de datos: OK"` porque no permite saber qué motor fue probado.

---

## 21. REGISTRO DE INSTALADORES

Cada release debe registrar el estado exacto de los 4 ejecutables:
- Setup PostgreSQL: versión y resultado
- Actualizador PostgreSQL: versión y resultado
- Setup SQL Server: versión y resultado
- Actualizador SQL Server: versión resultado

---

## 22. CHECKLIST DE VALIDACIÓN DEL ACTUALIZADOR

Toda actualización debe validar:
- [ ] Versión anterior identificada
- [ ] Versión nueva identificada
- [ ] Backup realizado cuando corresponda
- [ ] `.env` existente detectado
- [ ] Hash inicial del `.env`
- [ ] `.env` excluido de reemplazo
- [ ] Actualización ejecutada
- [ ] Hash final del `.env`
- [ ] Hash inicial = Hash final
- [ ] Conexión conservada
- [ ] Motor correcto
- [ ] Base correcta
- [ ] Archivos actualizados
- [ ] Servicios/proceso funcionando
- [ ] Pruebas funcionales superadas
- [ ] Pruebas de regresión superadas
- [ ] Resultado registrado

---

## 23. PRUEBAS DE RELEASE

Antes de liberar una versión deben ejecutarse:

### PostgreSQL
- [ ] Maestros
- [ ] Movimientos
- [ ] Facturación
- [ ] Cotizaciones
- [ ] Integraciones
- [ ] Reportes
- [ ] Stored Procedures
- [ ] Funciones SQL

### SQL Server
- [ ] Maestros
- [ ] Movimientos
- [ ] Facturación
- [ ] Cotizaciones
- [ ] Integraciones
- [ ] Reportes
- [ ] Stored Procedures
- [ ] Funciones T-SQL

### Pruebas Comunes
- [ ] Login y Seguridad
- [ ] Permisos y Roles
- [ ] Trazabilidad
- [ ] Instalador Setup
- [ ] Actualizador
- [ ] Integridad de `.env`
- [ ] Interfase con Zeus ERP
- [ ] Rendimiento y tiempos de respuesta
- [ ] Batería de Regresión
- [ ] Seguridad y contraseñas cifradas

---

## 24. NO FALSEAR RESULTADOS

Nunca registrar `"OK"` si la prueba no fue ejecutada. Utilizar estrictamente los siguientes estados:
- `OK`
- `NO OK`
- `NO EJECUTADA`
- `NO APLICA`

Si una prueba no pudo ejecutarse, debe indicarse expresamente la causa técnica.

---

## 25. CRITERIOS PARA LIBERAR UNA VERSIÓN (RELEASE GATE)

Una versión solamente puede pasar a estado **RELEASED** cuando cumple:
- [ ] Código congelado
- [ ] Versión definida (SemVer)
- [ ] Build definido (`YYYYMMDD.NN`)
- [ ] Commit identificado
- [ ] CHANGELOG terminado y curado
- [ ] Pruebas ejecutadas
- [ ] PostgreSQL validado
- [ ] SQL Server validado
- [ ] Regresiones validadas
- [ ] Instaladores validados
- [ ] Actualizadores validados
- [ ] `.env` validado
- [ ] Zeus ERP validado
- [ ] Seguridad validada
- [ ] Rendimiento validado
- [ ] Artefactos generados y almacenados
- [ ] Versión etiquetada en Git
- [ ] Evidencia de pruebas almacenada

---

## 26. RELEASE CANDIDATE (RC)

Antes de liberar una versión definitiva se puede utilizar la convención:
$$\text{3.7.13-RC.1}$$
Esto permite pruebas de campo finales sin declarar todavía la versión como definitiva.
- Si se detecta un error: `3.7.13-RC.2`
- Si se aprueba: `3.7.13`

---

## 27. ARTEFACTOS DE RELEASE

Cada versión debe conservar en almacenamiento histórico:
- `/releases/<VERSION>/postgresql/`
- `/releases/<VERSION>/sqlserver/`
- `/releases/<VERSION>/tests/`
- `/releases/<VERSION>/changelog/`
- `/releases/<VERSION>/documentation/`
- `/releases/<VERSION>/checksums/`

Debe conservarse evidencia suficiente para reconstruir con 100% de precisión qué fue entregado.

---

## 28. CHECKSUM / HASH DE ARTEFACTOS

Los instaladores y archivos críticos deben tener checksum SHA-256.
*Ejemplo:*
`Korex_Setup_SQLServer_3.7.13.exe` $\longrightarrow$ `SHA-256: 8f42a91...`
Esto permite verificar posteriormente que el archivo entregado no fue alterado ni dañado.

---

## 29. EL CHANGELOG NO DEBE SER UN GIT LOG

No copiar directamente mensajes de commits como `"fix invoice update sp"`, `"change button"`, `"fix sql test"`.
El CHANGELOG debe explicar el cambio desde el punto de vista del producto, la arquitectura y el usuario final.

---

## 30. RESUMEN EJECUTIVO DE CADA RELEASE

Cada versión debe comenzar con un **RESUMEN DE LA VERSIÓN** que indique en lenguaje claro:
- Objetivo principal
- Principales correcciones
- Nuevas funcionalidades
- Riesgos
- Impacto
- Recomendaciones de validación

---

## 31. SECCIÓN OBLIGATORIA "VALIDACIÓN DEL CLIENTE"

Cada release debe incluir la sección **VALIDACIÓN DEL CLIENTE** con pasos concretos de reproducción y verificación:
1. Ingresar al módulo Cotizaciones.
2. Crear una cotización.
3. Seleccionar el cliente.
4. Agregar producto.
5. Guardar.
6. Generar factura.
7. Verificar envío.
8. Consultar trazabilidad.
*Resultado esperado:* la operación debe finalizar correctamente y registrar la trazabilidad correspondiente.

---

## 32. MATRIZ DE VALIDACIÓN DE CAMBIOS

Cada release debe incluir una matriz sintética:

| ID | Cambio | PostgreSQL | SQL Server | Prueba Cliente | Resultado |
|---|---|:---:|:---:|:---:|:---:|
| KRX-2026-00125 | Facturación automática | OK | OK | Requerida | Pendiente |

Esto permite controlar rápidamente qué debe validar el cliente.

---

## 33. ESTADO DE VALIDACIÓN DEL CLIENTE (UAT)

Los cambios entregados para validación de usuario pueden tener 4 estados:
- `PENDIENTE`
- `EN PRUEBA`
- `APROBADO`
- `OBSERVADO`

*Regla:* No modificar el código silenciosamente por una observación. Si una observación genera un cambio adicional:
1. Generar un nuevo ID de cambio.
2. Actualizar las pruebas.
3. Generar una nueva versión cuando corresponda.

---

## 34. EL CHANGELOG COMO DOCUMENTO DE ENTREGA FORMAL (UAT)

El CHANGELOG o Informe de Entrega al cliente debe poder exportarse como **PDF**, **DOCX** o **HTML** cuando sea necesario.
El documento entregado debe contener:
- Identificación y Logo de Korex
- Nombre del Cliente
- Versión y Build
- Fecha
- Resumen Ejecutivo
- Cambios y Correcciones realizadas
- Pasos de Validación Requerida
- Resultados esperados
- Sección formal de Aprobación/Observación del Cliente con firma y fecha

---

## 35. HISTORIAL DE CAMBIOS PERMANENTE

**NUNCA** eliminar del historial una versión publicada.
`3.7.13`, `3.7.12`, `3.7.11`, `3.7.10`... Todas deben conservarse cronológicamente de forma acumulativa e inmutable.

---

## 36. CONTROL DE REGRESIONES CONTINUO

Antes de liberar una nueva versión:
$$\text{Versión anterior} \longrightarrow \text{Pruebas existentes} \longrightarrow \text{Nueva versión} \longrightarrow \text{Mismas pruebas} \longrightarrow \text{Comparación} \longrightarrow \text{0 Diferencias no autorizadas}$$
Una corrección anterior **no puede desaparecer** sin que sea detectada por la suite automatizada.

---

## 37. IDENTIFICACIÓN Y TRATAMIENTO DE CAMBIOS CRÍTICOS

Cuando un cambio afecte:
- Base de datos
- Facturación
- Información financiera
- Seguridad
- Instalación / Actualización
- Conexiones
- Archivo `.env`
- Integraciones externas (Zeus ERP)

Debe marcarse explícitamente como **CAMBIO CRÍTICO** y requiere validación específica reforzada.

---

## 38. PRINCIPIO DE TRAZABILIDAD COMPLETA DE EXTREMO A EXTREMO

Debe ser posible recorrer en ambos sentidos la cadena de valor:
$$\text{Requerimiento} \longleftrightarrow \text{ID de Cambio} \longleftrightarrow \text{Código} \longleftrightarrow \text{Commit} \longleftrightarrow \text{Build} \longleftrightarrow \text{Versión} \longleftrightarrow \text{Pruebas} \longleftrightarrow \text{Instalador} \longleftrightarrow \text{Cliente} \longleftrightarrow \text{Validación UAT}$$
Sin saltos, omisiones ni vacíos de información.

---

## 39. RESPONSABILIDAD DEL DESARROLLO

Ningún desarrollador o agente de IA puede:
- Modificar una versión ya publicada.
- Eliminar una corrección existente.
- Eliminar una prueba de regresión.
- Omitir la validación de PostgreSQL.
- Omitir la validación de SQL Server.
- Modificar el `.env` del cliente en actualizaciones.
- Modificar objetos nativos de Zeus ERP.
- Declarar una prueba como `OK` sin haberla ejecutado.
- Declarar una versión como liberada sin cumplir los 17 criterios de Release Gate.

---

## 40. REGLA ESPECIAL PARA AGENTES DE IA

Todo agente de IA que modifique Korex debe:
1. Revisar la versión actual y el último Build.
2. Revisar los cambios pendientes y el estado de la rama.
3. Revisar las correcciones existentes para prevenir regresiones.
4. Revisar y ejecutar las pruebas de regresión.
5. Identificar el impacto en PostgreSQL y SQL Server.
6. Identificar si Zeus ERP está involucrado.
7. Identificar si `.env` o la configuración del sistema están involucrados.
8. No eliminar funcionalidades existentes.
9. No sobrescribir correcciones anteriores.
10. Crear o actualizar pruebas automatizadas para el nuevo cambio.
11. Actualizar el `CHANGELOG.md` interno con la ficha técnica completa.
12. Informar al usuario exactamente qué modificó.
13. Validar ambos motores (`node scripts/validate_full_suite.js`).
14. Generar el reporte de resultados de pruebas.
15. Proponer la nueva versión y generar el borrador de entrega al cliente.

---

## 41. FORMATO MÍNIMO DEL CHANGELOG INTERNO / TÉCNICO

```markdown
# KOREX - CHANGELOG

## [3.7.13] - 2026-09-23
- **Build**: 20260923.01
- **Commit**: 8f42a91
- **Tipo de Release**: Patch / Minor / Major

### Resumen Ejecutivo
[Descripción ejecutiva clara y concisa]

### Nuevas Funcionalidades
- [Detalle]

### Cambios Funcionales
- [Detalle]

### Correcciones
- [Detalle]

### Base de Datos
- **PostgreSQL**: [Detalle]
- **SQL Server**: [Detalle]

### Integraciones y Zeus ERP
- [Detalle]

### Instaladores y Actualizadores
- Setup PostgreSQL: OK (v3.7.13)
- Actualizador PostgreSQL: OK (v3.7.13)
- Setup SQL Server: OK (v3.7.13)
- Actualizador SQL Server: OK (v3.7.13)

### Seguridad y Rendimiento
- [Detalle]

### Regresiones y Pruebas
- [Detalle]

### Validación Requerida del Cliente
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

### Resultado Esperado
[Resultado esperado verificable]
```

---

## 42. FORMATO DEL INFORME DE CAMBIOS Y VALIDACIÓN PARA EL CLIENTE (UAT)

Para la entrega a clientes se genera un documento limpio, sin rutas internas, commits ni tecnicismos de código:

```text
============================================================
KOREX
INFORME DE CAMBIOS Y VALIDACIÓN DE ENTREGA
============================================================
Cliente: ___________________________________________________
Versión: 3.7.13
Fecha: 23/09/2026
Build: 20260923.01
============================================================

1. RESUMEN DE LA VERSIÓN
------------------------------------------------------------
Esta versión contiene correcciones relacionadas con el proceso de 
facturación automática y mejoras en la estabilidad de la plataforma.

2. CAMBIOS REALIZADOS
------------------------------------------------------------
[KRX-2026-00125] Corrección del envío automático de facturación SQL Server
- Problema: Cuando el parámetro EnviarFacturacionAutoSQLserver se encontraba en 1,
  bajo determinadas condiciones el proceso no generaba el envío automático esperado.
- Corrección: Se ajustó el proceso responsable de evaluar el parámetro y generar
  el envío correspondiente.
- Impacto: Asegura la correcta ejecución desatendida del proceso de facturación.

3. VALIDACIÓN REQUERIDA (PASOS DE PRUEBA)
------------------------------------------------------------
1. Ingresar al módulo de Parámetros del Sistema.
2. Verificar que EnviarFacturacionAutoSQLserver esté configurado en 1.
3. Generar una factura de prueba en el módulo de Facturación.
4. Ejecutar el proceso automático de envío.
5. Verificar el resultado de la operación.
6. Consultar el log de trazabilidad y auditoría.

Resultado esperado:
La factura debe procesarse conforme a la configuración establecida y debe 
quedar registrada la trazabilidad correspondiente sin generar duplicidades.

4. MOTORES VALIDADOS
------------------------------------------------------------
PostgreSQL: OK
SQL Server: OK

5. PROTECCIÓN CONTRA REGRESIONES
------------------------------------------------------------
Se incorporó una prueba automatizada para garantizar que este comportamiento 
se mantenga estable y operativo en futuras actualizaciones.

6. CONFORMIDAD Y RESULTADO DEL CLIENTE
------------------------------------------------------------
Estado de Aceptación:
[ ] APROBADO
[ ] OBSERVADO

Observaciones: 
____________________________________________________________
____________________________________________________________

Fecha de Validación: _______________________________________
Responsable / Firma: _______________________________________
============================================================
```

---

## 43. REGLA DE ORO DEL CHANGELOG

**EL CLIENTE NO DEBE TENER QUE ADIVINAR QUÉ DEBE PROBAR.**
Cada cambio funcional debe decir explícitamente:
- **QUÉ PROBAR**
- **CÓMO PROBARLO**
- **QUÉ RESULTADO ESPERAR**

---

## 44. REGLA DE ORO DEL VERSIONAMIENTO Y CRITERIO FINAL

1. **NINGUNA CORRECCIÓN SE PIERDE.**
2. **NINGUNA VERSIÓN PUBLICADA SE MODIFICA.**
3. **NINGÚN CAMBIO IMPORTANTE QUEDA SIN DOCUMENTAR.**
4. **NINGUNA VERSIÓN SE LIBERA SIN VALIDAR POSTGRESQL Y SQL SERVER.**

Una versión de Korex solamente puede considerarse **OFICIAL** cuando el código, base de datos, instaladores, pruebas, CHANGELOG, seguridad y trazabilidad están 100% alineados. El número de versión no representa solamente una compilación: **representa un ESTADO CONTROLADO, VALIDADO Y DOCUMENTADO del producto.**

============================================================
FIN DEL DOCUMENTO KOREX-VERSIONAMIENTO-001
============================================================
