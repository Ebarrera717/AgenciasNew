DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationState') THEN
        CREATE TABLE public."QuotationState" (
            "id" SERIAL PRIMARY KEY,
            "name" VARCHAR(50) NOT NULL,
            "color" VARCHAR(20),
            "createdAt" TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "code" VARCHAR(25) UNIQUE NOT NULL
        );
    END IF;
END $$;
