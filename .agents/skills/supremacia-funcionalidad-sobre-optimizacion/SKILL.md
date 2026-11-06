---
name: supremacia-funcionalidad-sobre-optimizacion
description: SKILL OBLIGATORIA — Principio universal de supremacía de la funcionalidad operativa sobre optimizaciones técnicas, estéticas o de rendimiento en AgenciasNew.
---

# SKILL OBLIGATORIA: SUPREMACÍA DE LA FUNCIONALIDAD SOBRE OPTIMIZACIÓN Y DISEÑO
## AGENCIASNEW / KOREX PLATFORM

---

## 1. PRINCIPIO FUNDAMENTAL (AXIOMA DEL SISTEMA)

> **"LA FUNCIONALIDAD OPERATIVA Y DE NEGOCIO PRIMA ABSOLUTA E INQUEBRANTABLEMENTE SOBRE CUALQUIER OPTIMIZACIÓN TÉCNICA, RENDIMIENTO, REFUNDICIÓN DE CÓDIGO O DISEÑO ESTÉTICO."**

Ningún cambio, reducción de paquetes, lazy-loading, paginación, caché, ajuste visual, simplificación de consultas, estandarización de componentes o depuración puede llevarse a cabo si existe el más mínimo riesgo de:
1. Perder, alterar o degradar una funcionalidad ya validada o en uso por el cliente.
2. Alterar cálculos financieros, subtotales, totales, comisiones, impuestos o liquidaciones contables.
3. Omitir, recortar o alterar datos exportados (Excel, XML a Zeus ERP, reportes PDF).
4. Introducir fricción, pasos adicionales o comportamientos inesperados para los operadores del sistema.
5. Romper contratos de API, parámetros de SPs, estructuras de tablas o flujos de trabajo existentes.

---

## 2. REGLAS MANDATORIAS DE DESARROLLO

### Regla 1: Análisis Funcional Previo a Cualquier Optimización
Antes de aplicar cualquier técnica de optimización (ej. lazy loading, virtualización, paginación, compresión, refactorización):
- Se debe identificar **exactamente qué hace la funcionalidad actual**:
  - ¿Qué datos muestra?
  - ¿Qué acciones desencadena?
  - ¿Qué exporta o envía a terceros (Zeus ERP, impresiones, Excel)?
  - ¿Qué dependencias de estado o ciclo de vida utiliza?
- Si una optimización modifica el comportamiento visible o el resultado funcional, **la optimización debe descartarse de inmediato o replantearse**.

### Regla 2: Inmutabilidad de la Capacidad de Exportación y Filtro
- Si se optimiza el listado (por ejemplo, paginando filas para que el navegador no consuma memoria):
  - **La exportación a Excel / Portapapeles NUNCA se limita a la página actual**. Debe seguir permitiendo exportar el total filtrado o seleccionado sin truncar registros.
  - La búsqueda y filtros multicampo deben seguir evaluando la totalidad de los datos o delegarse con total precisión a la base de datos sin omitir registros válidos.

### Regla 3: Pruebas Funcionales No Negociables Post-Optimización
Cualquier módulo intervenido con fines de rendimiento o alivio de recursos debe superar obligatoriamente:
1. **Validación de Integridad Operativa**:
   - Crear / editar / consultar cotizaciones o facturas.
   - Probar exportación a Excel (.xlsx) y verificar que genere exactamente las mismas columnas y filas que antes.
   - Probar copia al portapapeles (Ctrl+V) y verificar tabulaciones.
   - Probar envío o exportación XML a Zeus ERP.
2. **Validación de Tipado y Build**:
   - `node .\node_modules\typescript\bin\tsc --noEmit` (Cero errores de compilación).
3. **Validación Release Guardian**:
   - `node scripts/korex_database_release_guardian.js` (Cero inconsistencias entre fuentes y manifests).

### Regla 4: Retrocompatibilidad y Fallbacks Transparentes
- Toda carga asíncrona o diferida (como `import('xlsx')` o modales dinámicos) debe contemplar:
  - Manejo de excepciones con notificación amigable en pantalla.
  - Estados de carga claros (spinners discretos) para que el usuario nunca perciba una pantalla congelada ni botones mudos.
  - El usuario debe obtener exactamente la misma respuesta funcional con o sin optimización.

### Regla 5: Estética al Servicio de la Funcionalidad (No al Revés)
- Los elementos de diseño (sombras, efectos de desenfoque, transiciones, colores de estado) jamás deben sacrificar:
  - Legibilidad de cifras, monedas, fechas y estados.
  - Velocidad de respuesta ante clics del operador.
  - Accesibilidad y estabilidad en navegadores y monitores de cualquier resolución de clientes reales.
- Si un efecto visual moderno compromete la fluidez del equipo del cliente, se prioriza una representación visual limpia, sólida y de alto rendimiento.

---

## 3. CHECKLIST OBLIGATORIO DE SUPREMACÍA FUNCIONAL

Antes de dar por concluida cualquier optimización:

- [ ] ¿La pantalla sigue haciendo el 100% de lo que hacía antes del cambio?
- [ ] ¿Los botones de acción rápida (Editar, Duplicar, Facturar, Imprimir, Cambiar Estado, Exportar XML, Eliminar) funcionan idénticos?
- [ ] ¿La exportación a Excel genera el archivo con todas las cotizaciones/facturas esperadas y no solo con las de la vista actual?
- [ ] ¿Los filtros de búsqueda arrojan exactamente los mismos resultados?
- [ ] ¿La compilación de TypeScript (`tsc --noEmit`) pasa con 0 errores?
- [ ] ¿El Release Guardian (`node scripts/korex_database_release_guardian.js`) valida con código de salida 0?
