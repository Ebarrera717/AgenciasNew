DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Invoices') THEN
        CREATE TABLE public."Invoices" (
            "id" SERIAL PRIMARY KEY,
            "internalNumber" VARCHAR(255) UNIQUE NOT NULL,
            "date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "clientId" INT NOT NULL,
            "currency" VARCHAR(50) NOT NULL,
            "exchangeRate" FLOAT NOT NULL,
            "branchId" INT NOT NULL,
            "implantId" INT,
            "sellerId" INT,
            "ticketPrinterId" INT,
            "baseCommissionable" FLOAT NOT NULL,
            "commissionPercentage" FLOAT NOT NULL,
            "chargesAndTaxes" FLOAT NOT NULL,
            "totalAmount" FLOAT NOT NULL,
            "userId" INT,
            "state" VARCHAR(25) DEFAULT 'NUEVO'
        );
    END IF;
END $$;
