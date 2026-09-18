---
name: correcciones-permanencia-proteccion
description: SKILL obligatorio de control de cambios, regresión y trazabilidad para garantizar que ninguna corrección, ajuste o solución validada sea eliminada, sobrescrita, degradada o pierda su comportamiento en desarrollos posteriores.
---

# SKILL OBLIGATORIO – CONTROL, PERMANENCIA Y PROTECCIÓN DE CORRECCIONES

## 1. OBJETIVO

Garantizar que ninguna corrección, ajuste, funcionalidad o solución previamente implementada y validada sea eliminada, reemplazada, degradada o pierda su comportamiento como consecuencia de desarrollos posteriores.

El objetivo principal es evitar:

* Correcciones que desaparecen.
* Funcionalidades que vuelven a presentar errores ya solucionados.
* Código que es sobrescrito accidentalmente.
* SPs, funciones, tablas o componentes que pierden cambios anteriores.
* Correcciones realizadas en un motor de base de datos que no son trasladadas al otro.
* Regresiones ocasionadas por nuevos desarrollos.
* Repetición innecesaria de trabajos ya realizados.
* Pérdida de tiempo reconstruyendo soluciones que ya habían sido implementadas.

Esta regla es **PERMANENTE y OBLIGATORIA** para todo el proyecto.

---

## 2. REGLA PRINCIPAL

### NINGUNA CORRECCIÓN VALIDADA PUEDE PERDERSE.

Una corrección que haya sido implementada y validada debe considerarse parte del comportamiento oficial del sistema.

Ningún desarrollo posterior puede eliminarla o modificar su comportamiento sin:

1. Identificar explícitamente la corrección existente.
2. Analizar el impacto del nuevo cambio.
3. Justificar técnicamente la modificación.
4. Mantener el comportamiento anterior cuando siga siendo requerido.
5. Actualizar las pruebas correspondientes.
6. Ejecutar nuevamente la prueba de regresión.
7. Registrar el cambio.

Está **PROHIBIDO** asumir que un comportamiento anterior puede eliminarse simplemente porque no aparece mencionado en el nuevo requerimiento.

---

## 3. ANTES DE MODIFICAR CUALQUIER COSA

Antes de realizar un desarrollo o corrección, el agente DEBE investigar:

* Código existente.
* SPs existentes.
* Funciones existentes.
* Tablas.
* Vistas.
* Triggers.
* Validaciones.
* Reglas de negocio.
* Configuraciones.
* Integraciones.
* Correcciones anteriores.
* Pruebas existentes.
* Casos de regresión existentes.
* Documentación del proyecto.
* Historial de cambios disponible.

**NO** se debe comenzar directamente modificando código.

Primero se debe determinar:

> ¿Qué existe actualmente y qué comportamiento debe preservarse?

---

## 4. INVENTARIO DE CORRECCIONES

Cada corrección importante debe quedar identificada mediante un registro permanente.

El registro debe contener como mínimo:

* ID de corrección (`COR-XXXX`).
* Fecha.
* Descripción del problema.
* Causa identificada.
* Solución implementada.
* Archivos modificados.
* SPs modificados.
* Funciones modificadas.
* Tablas involucradas.
* Motor afectado (PostgreSQL / SQL Server / Ambos).
* Evidencia de prueba.
* Resultado esperado.
* Resultado obtenido.
* Estado (VALIDADA / EN PROCESO / REGRESIÓN).
* Prueba de regresión asociada (`TEST-REG-XXXX`).

---

## 5. TODA CORRECCIÓN VALIDADA SE CONVIERTE EN UNA PRUEBA DE REGRESIÓN

Esta es una regla crítica.

Cada vez que una corrección sea validada, debe crearse o actualizarse automáticamente una prueba en la suite del sistema que compruebe que dicha corrección continúa funcionando.

Mientras esta prueba continúe pasando en la suite automatizada (`node scripts/validate_full_suite.js`), se demuestra que la corrección sigue protegida.

---

## 6. NINGÚN DESARROLLO SE CONSIDERA TERMINADO SIN REGRESIÓN

Después de realizar cualquier cambio, se debe comprobar:

### A. Funcionalidad nueva
¿El nuevo requerimiento funciona?

### B. Corrección original
¿La corrección que existía antes continúa funcionando?

### C. Funcionalidades relacionadas
¿El cambio afectó otras funcionalidades?

### D. Base de datos
¿Se conservaron SPs, funciones, tablas, restricciones, índices y demás objetos existentes?

### E. Integraciones
¿Continúan funcionando las integraciones existentes (Zeus ERP, interfaces, exportaciones)?

### F. PostgreSQL
¿Continúa funcionando correctamente?

### G. SQL Server
¿Continúa funcionando correctamente?

Un desarrollo **NO** puede marcarse como terminado solamente porque la nueva funcionalidad funciona.

---

## 7. REGLA DE NO SOBRESCRITURA

Está prohibido reemplazar archivos, SPs, funciones o componentes completos sin revisar previamente las modificaciones existentes.

Especialmente:
* Stored Procedures.
* Functions.
* Views.
* Triggers.
* Migrations.
* Servicios / API Routes.
* Componentes frontend.
* Configuraciones.

Antes de reemplazar un objeto se debe comparar:
```text
VERSIÓN ACTUAL + CAMBIOS PREVIOS + NUEVO CAMBIO = VERSIÓN CONSERVADA
```
El resultado debe conservar todos los comportamientos requeridos.

---

## 8. REGLA DE PRESERVACIÓN DE LÓGICA

Cuando se modifique una función o procedimiento existente, **NO** se debe reconstruir desde cero sin analizar su comportamiento actual.

La lógica existente debe considerarse protegida.

Si el nuevo requerimiento necesita modificarla:
1. Identificar la lógica existente.
2. Identificar la nueva lógica.
3. Integrar ambas de manera aditiva.
4. Ejecutar las pruebas anteriores.
5. Ejecutar las nuevas pruebas.

El nuevo desarrollo debe ser **ADITIVO** siempre que técnicamente sea posible.

---

## 9. CAMBIOS QUE ELIMINAN COMPORTAMIENTO

Si un nuevo requerimiento aparentemente entra en conflicto con una funcionalidad existente, **NO** eliminar automáticamente la funcionalidad anterior.

Debe marcarse:
### CONFLICTO DE REQUERIMIENTOS

Y documentar:
* Comportamiento actual.
* Nuevo comportamiento solicitado.
* Funcionalidad que podría perderse.
* Impacto.
* Alternativas.
* Decisión requerida.

No se debe eliminar una funcionalidad existente simplemente porque el nuevo requerimiento no la menciona.

---

## 10. PROTECCIÓN DE BASE DE DATOS

Los objetos de base de datos son parte del código del sistema y deben mantenerse bajo control de cambios.

Toda modificación debe estar representada mediante scripts/migrations versionados (`SQL/Table/Alter_New_Columns.sql`, `SQL/SP/`, `SQL/SqlServer/`).

Debe poder determinarse:
* Qué objeto existía.
* Qué cambio se realizó.
* Cuándo se realizó.
* Por qué se realizó.
* Qué versión lo contiene.
* Qué pruebas lo validan.

No se deben realizar modificaciones manuales permanentes en una base de datos que no queden posteriormente reflejadas en el mecanismo oficial de instalación/migración (`node deploy/gen_schema_json.js`, `deploy/sync_zeus_erp.js`).

---

## 11. POSTGRESQL Y SQL SERVER

Como el proyecto soporta oficialmente PostgreSQL y SQL Server:

Toda corrección relacionada con base de datos debe analizarse para **AMBOS** motores.

Debe determinarse:
* Implementación PostgreSQL.
* Implementación SQL Server.
* Diferencias necesarias.
* Pruebas PostgreSQL.
* Pruebas SQL Server.

Una corrección no se considera completamente terminada si funciona solamente en uno de los motores.

Además, debe mantenerse la regla de aislamiento:
- **SI SE ESTÁ EJECUTANDO CON POSTGRESQL:** solamente PostgreSQL puede ser modificado y consultado en operaciones runtime.
- **SI SE ESTÁ EJECUTANDO CON SQL SERVER:** solamente SQL Server puede ser modificado y consultado en operaciones runtime.

Nunca realizar modificaciones ocultas o simultáneas en el motor no seleccionado durante la ejecución.

---

## 12. CONTROL ANTES DE FINALIZAR UN DESARROLLO

Antes de declarar una tarea como **FINALIZADA**, el agente debe realizar obligatoriamente este checklist:

- [ ] Revisé el comportamiento existente.
- [ ] Identifiqué correcciones anteriores relacionadas.
- [ ] No eliminé funcionalidades existentes.
- [ ] No sobrescribí accidentalmente cambios anteriores.
- [ ] Implementé el nuevo requerimiento.
- [ ] Probé la nueva funcionalidad.
- [ ] Ejecuté las pruebas de regresión (`node scripts/validate_full_suite.js`).
- [ ] Verifiqué los SPs relacionados.
- [ ] Verifiqué las funciones relacionadas.
- [ ] Verifiqué las tablas relacionadas.
- [ ] Verifiqué las validaciones.
- [ ] Verifiqué las integraciones afectadas (Zeus ERP, exportación, etc.).
- [ ] Probé PostgreSQL.
- [ ] Probé SQL Server.
- [ ] Actualicé las pruebas correspondientes.
- [ ] Registré la corrección/cambio.
- [ ] Confirmé que las correcciones anteriores continúan funcionando.

Solo después de completar este proceso se puede considerar **FINALIZADO** el desarrollo.

---

## 13. PROHIBICIÓN DE "REHACER SIN REVISAR"

Si el agente encuentra una funcionalidad que aparentemente debe volver a desarrollarse, primero debe verificar si ya existe una implementación anterior.

Está prohibido:
* Crear nuevamente una solución que ya existe.
* Reemplazar una solución existente sin analizarla.
* Eliminar una implementación porque "parece innecesaria".
* Crear un nuevo SP cuando ya existe uno que cumple parcialmente la función sin analizarlo.
* Modificar una funcionalidad sin revisar sus pruebas anteriores.

Flujo obligatorio:
```text
BUSCAR → ANALIZAR → PRESERVAR → MODIFICAR → PROBAR
```

---

## 14. REGISTRO DE REGRESIONES

Si una corrección anteriormente solucionada vuelve a fallar, debe registrarse inmediatamente como **REGRESIÓN** (`REG-XXXX`).

Ejemplo:
```text
REG-0007
Corrección afectada: COR-0021
Descripción: Una modificación realizada en el módulo de cotizaciones provocó que nuevamente se permitiera guardar información sin las validaciones implementadas anteriormente.
Causa: Cambio en SP utilizado por el proceso de guardado.
Acción: Restaurar comportamiento anterior e integrar correctamente el nuevo requerimiento.
Prueba de protección: TEST-REG-COT-001.
```

---

## 15. REPORTE DE CADA DESARROLLO

Al finalizar un desarrollo, debe generarse un resumen técnico con:

1. **CAMBIO REALIZADO**: Qué se modificó.
2. **CORRECCIONES PRESERVADAS**: Qué correcciones existentes fueron verificadas.
3. **ARCHIVOS AFECTADOS**: Lista de archivos modificados.
4. **BASE DE DATOS**: SPs, funciones, tablas, vistas, triggers, índices, etc.
5. **POSTGRESQL**: Resultado de pruebas.
6. **SQL SERVER**: Resultado de pruebas.
7. **REGRESIONES**: Cantidad de pruebas ejecutadas y resultado.
8. **RIESGOS**: Cambios que puedan afectar otras funcionalidades.
9. **RESULTADO**: APROBADO o REQUIERE CORRECCIÓN.

---

## 16. REGLA DE BLOQUEO

Si durante un desarrollo se detecta que una corrección anterior dejó de funcionar:

**NO** se debe continuar marcando el desarrollo como finalizado.

El estado debe declararse como:
> **BLOQUEADO – REGRESIÓN DETECTADA**

El agente debe:
1. Identificar la corrección afectada.
2. Identificar qué cambio provocó la regresión.
3. Corregir la regresión.
4. Ejecutar nuevamente las pruebas de regresión.
5. Confirmar que la funcionalidad nueva también continúa funcionando.

---

## 17. PROTECCIÓN CONTRA PÉRDIDA DE CAMBIOS

El proyecto debe mantener mecanismos de versionamiento y trazabilidad suficientes para poder identificar y recuperar modificaciones anteriores.

Cada desarrollo debe estar asociado a:
* ID de requerimiento.
* ID de corrección (`COR-XXXX`).
* Commit / versión en Git.
* Fecha.
* Archivos modificados.
* Scripts de BD.
* Pruebas de regresión.
* Resultado de pruebas.

Nunca depender exclusivamente de la memoria del desarrollador o del agente.

---

## 18. REGLA FUNDAMENTAL PARA AGENTES DE IA

Antes de modificar cualquier parte del proyecto, el agente debe asumir:

> *"El código existente puede contener correcciones importantes que no aparecen explícitamente en el requerimiento actual."*

Por lo tanto:
* **NO** modificar por suposición.
* **NO** eliminar por desconocimiento.
* **NO** reemplazar sin comparar.
* **NO** reconstruir sin investigar.
* **NO** considerar terminado sin pruebas de regresión.

---

## 19. PRINCIPIO FINAL

El proyecto debe evolucionar acumulando funcionalidades y correcciones, **NO** perdiéndolas.

La regla dorada es:
```text
  NUEVO DESARROLLO
+ CORRECCIONES EXISTENTES
+ PRUEBAS EXISTENTES
+ NUEVAS PRUEBAS
= NUEVA VERSIÓN PROTEGIDA
```

Nunca:
```text
  NUEVO DESARROLLO
- CORRECCIONES ANTERIORES
= REGRESIÓN (PROHIBIDO)
```

---

## 20. CRITERIO OBLIGATORIO DE ACEPTACIÓN

Una tarea solamente puede considerarse **FINALIZADA** cuando se pueda demostrar:

1. El nuevo requerimiento funciona.
2. Las correcciones anteriores relacionadas continúan funcionando.
3. No se eliminaron comportamientos existentes sin autorización.
4. Las pruebas de regresión pasan (`node scripts/validate_full_suite.js`).
5. PostgreSQL fue validado.
6. SQL Server fue validado.
7. Los cambios quedaron registrados.
8. La solución puede reproducirse desde el código / migrations / scripts oficiales.

Si cualquiera de estos puntos falla:
> **NO FINALIZAR EL DESARROLLO.**
