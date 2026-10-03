DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger') THEN
        CREATE TABLE public."InvoicesProductPasenger" (
            "id" SERIAL PRIMARY KEY,
            "invoiceProductId" INT NOT NULL,
            "name" VARCHAR(255) NOT NULL,
            "document" VARCHAR(255) NOT NULL
        );
    END IF;
END $$;
