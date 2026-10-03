DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax') THEN
        CREATE TABLE public."InvoicesProductTax" (
            "id" SERIAL PRIMARY KEY,
            "invoiceProductId" INT NOT NULL,
            "chargeAndTaxId" INT NOT NULL,
            "valueSnapshot" FLOAT NOT NULL,
            "valueTypeSnapshot" VARCHAR(50) NOT NULL,
            "explicitAmount" FLOAT,
            "isMain" BOOLEAN DEFAULT false
        );
    END IF;
END $$;
