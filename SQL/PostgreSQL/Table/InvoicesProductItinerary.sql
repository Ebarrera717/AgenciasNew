DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary') THEN
        CREATE TABLE public."InvoicesProductItinerary" (
            "id" SERIAL PRIMARY KEY,
            "invoiceProductId" INT NOT NULL,
            "orden" INT,
            "origin" VARCHAR(255) NOT NULL,
            "destination" VARCHAR(255) NOT NULL,
            "class" VARCHAR(255),
            "checkInDate" TIMESTAMP,
            "checkOutDate" TIMESTAMP,
            "terminal" VARCHAR(255),
            "prestadoraCode" VARCHAR(255),
            "farebasis" VARCHAR(255),
            "Numflight" VARCHAR(25),
            "Typeflight" VARCHAR(1),
            "amount" FLOAT,
            "co2" DECIMAL(10,4),
            CONSTRAINT "InvoicesProductItinerary_invoiceProductId_fkey" FOREIGN KEY ("invoiceProductId") REFERENCES public."InvoicesProduct" (id) ON UPDATE CASCADE ON DELETE CASCADE
        );
    END IF;
END $$;
