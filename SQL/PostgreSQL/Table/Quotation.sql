DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Quotation') THEN
        CREATE TABLE public."Quotation" (
            id SERIAL PRIMARY KEY,
            "internalNumber" TEXT NOT NULL,
            date TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "clientId" INTEGER NOT NULL,
            currency TEXT NOT NULL,
            "exchangeRate" DOUBLE PRECISION NOT NULL,
            "branchId" INTEGER NOT NULL,
            "implantId" INTEGER,
            "sellerId" INTEGER,
            "ticketPrinterId" INTEGER,
            "baseCommissionable" DOUBLE PRECISION NOT NULL,
            "commissionPercentage" DOUBLE PRECISION NOT NULL,
            "chargesAndTaxes" DOUBLE PRECISION NOT NULL,
            "totalAmount" DOUBLE PRECISION NOT NULL,
            "userId" INTEGER,
            "state" VARCHAR(25) DEFAULT 'NUEVO'
        );
    END IF;
END $$;
