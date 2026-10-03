DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable') THEN
        CREATE TABLE public."InvoicesProductVariable" (
            "id" SERIAL PRIMARY KEY,
            "invoiceProductId" INT NOT NULL,
            "masterVariableId" INT NOT NULL,
            "value" VARCHAR(255) NOT NULL
        );
    END IF;
END $$;
