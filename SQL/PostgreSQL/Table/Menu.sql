DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Menu') THEN
        CREATE TABLE public."Menu" (
            id SERIAL PRIMARY KEY,
            code VARCHAR(100) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            parent INT NULL,
            action VARCHAR(500) NOT NULL,
            activo BOOLEAN DEFAULT true
        );
    END IF;
END $$;
