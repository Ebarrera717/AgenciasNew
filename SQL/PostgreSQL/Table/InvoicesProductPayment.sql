DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment') THEN
        CREATE TABLE public."InvoicesProductPayment" (
            "id" SERIAL PRIMARY KEY,
            "invoiceProductId" INT NOT NULL,
            "amount" FLOAT NOT NULL,
            "paymentMethod" VARCHAR(100),
            "date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            "reference" VARCHAR(255)
        );
    END IF;
END $$;
