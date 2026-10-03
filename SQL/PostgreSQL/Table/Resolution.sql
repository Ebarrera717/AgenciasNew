DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Resolution') THEN
        CREATE TABLE public."Resolution" (
            id SERIAL PRIMARY KEY,
            code VARCHAR(255) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            "date" TIMESTAMP WITH TIME ZONE,
            expira TIMESTAMP WITH TIME ZONE,
            inicial BIGINT,
            "end" BIGINT,
            autoriza VARCHAR(255),
            prefijo VARCHAR(50),
            alerta INT,
            "day" INT,
            permitir BOOLEAN DEFAULT false,
            activo BOOLEAN DEFAULT true
        );
    END IF;
END $$;
