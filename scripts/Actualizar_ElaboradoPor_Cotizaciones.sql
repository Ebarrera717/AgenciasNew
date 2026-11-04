-- =====================================================================================
-- SCRIPT DE REPARACIÓN: CORREGIR "ELABORADO POR" (userId) EN COTIZACIONES
-- Base de Datos Destino: Korex_Colaereo (PostgreSQL)
-- Propósito:
--   Corrige todas las cotizaciones (incluyendo #144 y #145 de ISABEL CRISTINA VELEZ LOPEZ,
--   así como #11, #77, #91, #109 y #140 de SEBASTIAN GAVIRIA SANABRIA) en las cuales
--   el campo "userId" quedó asignado por fallback al ID 1 (ANGIE PAOLA ARROYAVE AGUDELO)
--   o NULL cuando el navegador no envió la cabecera X-User-Id.
--   Cruza el Tiqueteador (TicketPrinter) de la cotización con el Usuario (User) real
--   y actualiza tanto public."Quotation" como public."QuotationStateHistory" (estado NUEVO).
-- =====================================================================================

BEGIN;

-- 1. Actualizar el usuario creador (userId) en public."Quotation"
UPDATE public."Quotation" q
SET "userId" = sub.real_user_id
FROM (
    SELECT DISTINCT ON (q2.id)
        q2.id AS quotation_id,
        u2.id AS real_user_id
    FROM public."Quotation" q2
    INNER JOIN public."TicketPrinter" tp2 ON tp2.id = q2."ticketPrinterId"
    INNER JOIN public."User" u2 ON (
        u2."ticketPrinterId" = tp2.id
        OR (NULLIF(TRIM(tp2.email), '') IS NOT NULL AND LOWER(TRIM(u2.email)) = LOWER(TRIM(tp2.email)))
        OR (NULLIF(TRIM(tp2.name), '') IS NOT NULL AND UPPER(TRIM(u2.name)) = UPPER(TRIM(tp2.name)))
    )
    WHERE (q2."userId" IS NULL OR q2."userId" = 1)
      AND u2.id <> 1
    ORDER BY q2.id,
             CASE WHEN u2."ticketPrinterId" = tp2.id THEN 0 ELSE 1 END,
             u2.id ASC
) sub
WHERE q.id = sub.quotation_id
  AND (q."userId" IS NULL OR q."userId" <> sub.real_user_id);

-- 2. Actualizar también el registro inicial de trazabilidad en public."QuotationStateHistory"
UPDATE public."QuotationStateHistory" qsh
SET "userId" = q."userId"
FROM public."Quotation" q
WHERE qsh."quotationId" = q.id
  AND qsh.state = 'NUEVO'
  AND (qsh."userId" IS NULL OR qsh."userId" = 1)
  AND q."userId" IS NOT NULL
  AND q."userId" <> 1;

COMMIT;

-- 3. Verificación de las cotizaciones corregidas (incluyendo #144 y #145)
SELECT
    q.id AS "ID Cotización",
    q."internalNumber" AS "N° Interno",
    c.name AS "Cliente",
    tp.name AS "Tiqueteador",
    u.id AS "User ID",
    u.name AS "Elaborado Por"
FROM public."Quotation" q
LEFT JOIN public."Client" c ON c.id = q."clientId"
LEFT JOIN public."TicketPrinter" tp ON tp.id = q."ticketPrinterId"
LEFT JOIN public."User" u ON u.id = q."userId"
WHERE q.id IN (11, 77, 91, 109, 140, 144, 145)
ORDER BY q.id ASC;
