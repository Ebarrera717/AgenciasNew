DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProduct') THEN
        CREATE TABLE public."InvoicesProduct" (
            "id" SERIAL PRIMARY KEY,
            "invoiceId" INT NOT NULL,
            "productId" INT NOT NULL,
            "quantity" INT NOT NULL,
            "price" FLOAT NOT NULL,
            "cost" FLOAT DEFAULT 0,
            "providerId" INT,
            "prestadoraId" INT,
            "checkInDate" TIMESTAMP,
            "checkOutDate" TIMESTAMP,
            "nights" INT,
            "paxAdults" INT,
            "paxChildren" INT,
            "serviceType" VARCHAR(255),
            "destination" VARCHAR(255),
            "reservationCode" VARCHAR(255),
            "sellerCommission" FLOAT,
            "ticketPrinterCommission" FLOAT,
            "comboId" INT,
            "mainTaxId" INT,
            "inNationality" INT DEFAULT 1,
            
            -- Nuevos campos solicitados
            "servicios" TEXT,
            "descripcion" TEXT,
            "itinerary" TEXT,
            "class" VARCHAR(100),
            "ticketTypeId" INT,
            "airline" VARCHAR(100)
        );
    END IF;
END $$;
