DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductCombo') THEN
        CREATE TABLE public."InvoicesProductCombo" (
            "id" SERIAL PRIMARY KEY,
            "invoiceId" INT NOT NULL,
            "comboId" INT NOT NULL
        );
    END IF;
END $$;
