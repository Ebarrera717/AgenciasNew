---
name: updater-parity-and-dryrun-guardian
description: Principio universal de arquitectura para garantizar Fuente Única de Verdad, paridad criptográfica SHA-256 obligatoria entre todas las copias de distribución de actualizadores SQL (PostgreSQL, SQL Server y Zeus ERP) y validación de ejecución end-to-end con 0 errores antes de liberar a producción.
---

# SKILL OBLIGATORIA — PARIDAD CRIPTOGRÁFICA Y EJECUCIÓN VERIFICADA DE ACTUALIZADORES (`updater-parity-and-dryrun-guardian`)

## 1. Principio de Arquitectura Universal

> **Ningún artefacto de actualización o distribución de base de datos puede coexistir en múltiples rutas del repositorio o del paquete de release sin una replicación determinística desde una Fuente Única de Verdad (SSOT) y una verificación bloqueante de paridad SHA-256.**

### Causa Raíz Técnica que Resuelve
En sistemas multibase donde un mismo script de actualización o consolidado SQL se consume desde múltiples ubicaciones (carpeta del motor, carpeta heredada `Actualizador/`, carpeta de empaquetado `RELEASE_KOREX/SQL/`, etc.), cualquier fallo silencioso o dependencia opcional en el paso de copia provoca **deriva silenciosa de artefactos** (*artifact drift*): la fuente maestra queda actualizada pero las copias de distribución conservan versiones antiguas, exponiendo a producción a despliegues incompletos o regresiones.

---

## 2. Reglas Permanentes de Diseño

### Regla 1: Fuente Única de Verdad (SSOT) por Motor
Cada familia de scripts de distribución posee exactamente una fuente maestra generada y un conjunto explícito de destinos sincronizados automáticamente en cada compilación:

1. **Actualizador PostgreSQL (Korex)**:
   - **Fuente Maestra**: `SQL/PostgreSQL/Actualizador.sql`
   - **Destinos Sincronizados Obligatorios**:
     - `SQL/Actualizador/Actualizador.sql`
     - `SQL/Actualizador.SQL`
     - `RELEASE_KOREX/SQL/Actualizador.SQL` (cuando existe el directorio de release)
2. **Actualizador SQL Server (Korex)**:
   - **Fuente Maestra**: `SQL/SqlServer/ActualizadorSERVER.sql`
   - **Destinos Sincronizados Obligatorios**:
     - `SQL/SqlServer/Actualizador.sql`
     - `SQL/Actualizador/ActualizadorSERVER.sql`
     - `RELEASE_KOREX/SQL/ActualizadorSERVER.SQL` (cuando existe el directorio de release)
3. **Consolidado Zeus ERP (SQL Server)**:
   - **Fuente Maestra**: `SQL/ZeusERP/TODOS_LOS_SPS_Y_FUNCIONES_ZEUSERP.sql`
   - **Destinos Sincronizados Obligatorios**:
     - `SQL/ZeusERP/TODOS_LOS_SPS_ZEUSERP.sql`

### Regla 2: Prohibición de Dependencias Opcionales / `scratch/` en el Pipeline de Sincronización
El pipeline oficial de compilación (`deploy/validate_schema_before_package.js` y `deploy/sync_sqlserver_updater.js`) **NUNCA** debe depender exclusivamente de scripts externos, temporales o de carpetas `scratch/` para replicar artefactos críticos de producción. La replicación desde la fuente maestra debe ser nativa, incondicional y determinística.

### Regla 3: Barrera Bloqueante de Paridad SHA-256 (Fail Fast)
El **Release Guardian** (`scripts/korex_database_release_guardian.js`) debe calcular y comparar el hash **SHA-256** de cada fuente maestra contra todos sus destinos sincronizados existentes:
- Si **cualquier** copia destino difiere en 1 solo byte (`hash(destino) !== hash(maestra)`), el proceso debe **ABORTAR INMEDIATAMENTE** con `EXIT CODE: 1`, reportando la ruta desincronizada y ambos hashes.
- Ningún paquete, instalador o actualizador puede considerarse apto para producción si existe deriva de hashes.

### Regla 4: Validación de Ejecución Real End-to-End (Idempotencia y 0 Errores)
Antes de aprobar cualquier actualizador para producción tras cambios de esquema, parámetros o SPs:
1. Los scripts actualizadores deben ser **100% idempotentes** (poder ejecutarse múltiples veces sobre bases existentes sin errores de objetos duplicados ni sobrescritura de parámetros configurados por el cliente mediante `ON CONFLICT DO NOTHING` / `IF NOT EXISTS`).
2. Se debe validar la ejecución real completa de los actualizadores contra las bases locales correspondientes:
   - PostgreSQL: ejecución completa de `SQL/PostgreSQL/Actualizador.sql` con **0 errores**.
   - SQL Server: ejecución de todos los lotes `GO` de `SQL/SqlServer/ActualizadorSERVER.sql` con **0 errores**.
   - Zeus ERP: ejecución de todos los lotes `GO` de `SQL/ZeusERP/TODOS_LOS_SPS_Y_FUNCIONES_ZEUSERP.sql` contra la base externa configurada (`BaseSQLServer`) con **0 errores**.

---

## 3. Checklist de Verificación Obligatoria Pre-Producción

- [ ] `node deploy/gen_schema_json.js` ejecutado sin errores (sincroniza todas las fuentes y destinos).
- [ ] `node scripts/korex_database_release_guardian.js` ejecutado con `EXIT CODE: 0` y **Paridad SHA-256 100% aprobada**.
- [ ] `node scripts/korex_validator.js --all` ejecutado con dictamen **`[ GO ]`**.
- [ ] Ejecución real de actualizadores verificada con **0 errores** en PostgreSQL, SQL Server y Zeus ERP.
