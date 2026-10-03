-- Tabla: public.SysConsecutivo
CREATE TABLE IF NOT EXISTS public."SysConsecutivo" (
    "id" SERIAL PRIMARY KEY,
    "codigo" VARCHAR(50) NOT NULL,
    "nombre" VARCHAR(255) NOT NULL,
    "branchId" INT REFERENCES public."Branch"(id) ON DELETE SET NULL,
    "implantId" INT REFERENCES public."Implant"(id) ON DELETE SET NULL,
    "fuente" VARCHAR(50),
    "serie" VARCHAR(50),
    "consecutivo" BIGINT NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS "idx_sysconsecutivo_codigo" ON public."SysConsecutivo"("codigo");
CREATE INDEX IF NOT EXISTS "idx_sysconsecutivo_branch" ON public."SysConsecutivo"("branchId");
CREATE INDEX IF NOT EXISTS "idx_sysconsecutivo_implant" ON public."SysConsecutivo"("implantId");
