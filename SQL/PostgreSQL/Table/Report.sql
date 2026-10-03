DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Report') THEN
        CREATE TABLE public."Report" (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            base_table VARCHAR(100),
            description TEXT,
            custom_sql TEXT,
            created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
END $$;
