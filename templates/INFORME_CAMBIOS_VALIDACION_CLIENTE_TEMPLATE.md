============================================================
KOREX — INFORME DE CAMBIOS Y VALIDACIÓN DE ENTREGA
============================================================
Cliente: ___________________________________________________
Versión: {{VERSION}}
Fecha: {{FECHA}}
Build: {{BUILD}}
============================================================

1. RESUMEN DE LA VERSIÓN
------------------------------------------------------------
{{RESUMEN_VERSION}}

2. CAMBIOS REALIZADOS
------------------------------------------------------------
{{#each CAMBIOS}}
[{{ID}}] {{TITULO}}
- Problema Reportado: {{PROBLEMA}}
- Corrección Implementada: {{SOLUCION}}
- Impacto Operativo: {{IMPACTO}}

{{/each}}

3. VALIDACIÓN REQUERIDA (GUÍA DE PRUEBA Y ACEPTACIÓN)
------------------------------------------------------------
Para verificar los cambios incluidos en esta entrega, realice las siguientes comprobaciones:

{{#each VALIDACIONES}}
--- Validación: {{TITULO}} ---
{{PASOS}}

Resultado Esperado:
{{RESULTADO_ESPERADO}}

{{/each}}

4. PLATAFORMAS Y MOTORES VALIDADOS
------------------------------------------------------------
PostgreSQL: {{POSTGRES_STATUS}}
SQL Server: {{SQLSERVER_STATUS}}

5. PROTECCIÓN Y CALIDAD
------------------------------------------------------------
- Control de Regresiones: Todas las funcionalidades previas han sido verificadas mediante la suite de pruebas automáticas continuas.
- Integridad de Base de Datos: Actualización no destructiva aplicada con preservación completa de históricos e información contable.
- Integración ERP: Validada conforme a los estándares de comunicación seguros del sistema.

6. CONFORMIDAD Y ACEPTACIÓN DEL CLIENTE (UAT)
------------------------------------------------------------
Por favor marque el estado de la validación:

[  ] APROBADO (Conforme para operación en producción)
[  ] OBSERVADO (Requiere revisión en puntos específicos)

Observaciones:
____________________________________________________________
____________________________________________________________
____________________________________________________________

Fecha de Validación: _______________________________________
Nombre del Responsable: ___________________________________
Cargo / Dependencia: _______________________________________
Firma: _____________________________________________________
============================================================
