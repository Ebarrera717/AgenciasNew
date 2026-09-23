# KOREX — REGISTRO OFICIAL DE CAMBIOS (CHANGELOG)

Todos los cambios notables de este proyecto se documentan en este archivo.
El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y este proyecto se adhiere a [Semantic Versioning 2.0.0](https://semver.org/lang/es/).

---

## [3.7.13] - 2026-09-23
- **Build**: 20260923.01
- **Commit**: 8f42a91
- **Tipo de Release**: Patch / Consolidación Multibase y Gobernanza de Releases

### Resumen Ejecutivo
Esta versión consolida el sistema de gobernanza de releases, trazabilidad 360°, política oficial de versionamiento SemVer 2.0.0, soporte multibase dual PostgreSQL/SQL Server con aislamiento estricto, protección inviolable del archivo `.env` en los actualizadores y el protocolo de validación guiada de entrega al cliente (UAT).

---

### KRX-2026-00125: Gobernanza Integral de Versionamiento y Generación de Informes UAT
- **Tipo**: Added / Governance
- **Problema Reportado**: Se requería un esquema unificado y estandarizado para documentar cambios funcionales sin tecnicismos para el cliente y con total trazabilidad técnica interna para desarrolladores y agentes de IA.
- **Solución Implementada**: Creación del Documento Normativo `KOREX-VERSIONAMIENTO-001`, implementación del Skill `versioning-release-changelog`, estandarización de identificadores de cambio `KRX-YYYY-NNNNN` y herramienta de generación de fichas de prueba y aceptación para clientes.
- **Componentes Afectados**:
  - `docs/KOREX_VERSIONAMIENTO_RELEASES_CHANGELOG.md`
  - `.agents/skills/versioning-release-changelog/SKILL.md`
  - `scripts/release_changelog_manager.js`
  - `templates/INFORME_CAMBIOS_VALIDACION_CLIENTE_TEMPLATE.md`
- **Motor**: PostgreSQL / SQL Server (Ambos)
- **Impacto Funcional**: El cliente dispone de una guía paso a paso clara para comprobar cada ajuste sin necesidad de interpretar código.
- **Riesgo**: Bajo
- **Pruebas Realizadas**: Validación automatizada con `node scripts/release_changelog_manager.js --validate` y generación de informes con `--generate-client`.
- **Resultado**: OK

---

### KRX-2026-00120: Protección Inviolable de Conexiones (.env) en Actualizaciones
- **Tipo**: Security / Fixed
- **Problema Reportado**: Las actualizaciones automáticas debían garantizar de forma matemática que las credenciales de base de datos del cliente nunca sean reemplazadas por configuraciones de desarrollo.
- **Solución Implementada**: Exclusión explícita de archivos `.env*` en el empaquetado de Inno Setup y validación de hash SHA-256 antes y después del proceso de actualización en `Update_Korex.ps1` y `Update_Korex_SQLServer.ps1`.
- **Componentes Afectados**:
  - `deploy/Generar_Empaquetado.ps1`
  - `Update_Korex.ps1`
  - `Instalador/Korex_Update.iss`
  - `Instalador/Korex_Update_SQLServer.iss`
- **Motor**: PostgreSQL / SQL Server (Ambos)
- **Impacto Funcional**: 0 riesgo de pérdida de conexión tras actualizar versiones del sistema.
- **Riesgo**: Bajo
- **Pruebas Realizadas**: Verificación automatizada con `node scripts/validate_master_skill_suite.js`.
- **Resultado**: OK

---

### KRX-2026-00115: Aislamiento Absoluto de Motores y Ejecución Dual
- **Tipo**: Changed / Architecture
- **Problema Reportado**: Cuando el sistema opera en PostgreSQL o SQL Server, debe garantizarse que el 100% de consultas, transacciones y SPs se ejecuten de forma aislada en el motor seleccionado, sin llamadas cruzadas ocultas.
- **Solución Implementada**: Centralización de directivas de aislamiento en `src/lib/prisma.ts`, `src/lib/postgres.ts` y `src/lib/sqlserver.ts`.
- **Componentes Afectados**:
  - `src/lib/prisma.ts`
  - `src/lib/postgres.ts`
  - `src/lib/sqlserver.ts`
  - `scripts/validate_motor_isolation_suite.js`
- **Motor**: PostgreSQL / SQL Server (Ambos)
- **Impacto Funcional**: Estabilidad total e independencia de infraestructura para la agencia.
- **Riesgo**: Bajo
- **Pruebas Realizadas**: Ejecución de las 11 capas de `node scripts/validate_full_suite.js`.
- **Resultado**: OK

---

### Base de Datos
- **PostgreSQL**: IMPLEMENTADO Y VALIDADO
- **SQL Server**: IMPLEMENTADO Y VALIDADO
- **Migraciones**: Incrementales y no destructivas (`ALTER TABLE`, `CREATE OR REPLACE`, `IF NOT EXISTS`).

### Integraciones y Zeus ERP
- Integración con base externa `ZeusAgencias_23` mediante SPs propios controlados (`spFacturacionesCrear`, `spCotizacionesCrear`) con 0 alteraciones sobre objetos nativos del ERP.

### Instaladores y Actualizadores
- Setup PostgreSQL: OK (v3.7.13)
- Actualizador PostgreSQL: OK (v3.7.13)
- Setup SQL Server: OK (v3.7.13)
- Actualizador SQL Server: OK (v3.7.13)

### Validación Requerida del Cliente
1. Iniciar sesión en el portal de Korex con credenciales de usuario autorizado.
2. Ingresar a la sección de Configuración / Diagnósticos del Sistema.
3. Verificar que la versión mostrada corresponda a 3.7.13 y el Build a 20260923.01.
4. Generar una cotización y su correspondiente factura de prueba en el módulo operativo.
5. Comprobar que los cálculos contables, cargos e impuestos se liquiden con total precisión.
6. Consultar la traza de auditoría para confirmar el registro limpio de la transacción.

### Resultado Esperado
La aplicación debe operar de forma fluida, sin advertencias de conexión, liquidando los documentos con exactitud y preservando la trazabilidad en la base de datos correspondiente.

---
