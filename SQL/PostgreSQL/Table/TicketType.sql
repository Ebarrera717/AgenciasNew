-- Script para la tabla maestra TicketType
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TicketType') THEN
        CREATE TABLE public."TicketType" (
            "id" SERIAL PRIMARY KEY,
            "code" VARCHAR(50) UNIQUE NOT NULL,
            "name" VARCHAR(255) NOT NULL,
            "description" TEXT,
            "isActive" BOOLEAN DEFAULT true
        );
    END IF;
END $$;
