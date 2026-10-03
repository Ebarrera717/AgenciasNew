DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Branch') THEN
        CREATE TABLE public."Branch" (
            id SERIAL PRIMARY KEY,
            code VARCHAR(255) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            logo BYTEA,
            template BYTEA,
            "templateConfig" JSONB,
            "htmlTemplate" TEXT
        );
    END IF;
END $$;
