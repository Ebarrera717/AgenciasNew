DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProduct') THEN
        CREATE TABLE public."QuotationProduct" (
            id SERIAL PRIMARY KEY,
            "quotationId" INT NOT NULL,
            "productId" INT NOT NULL,
            quantity INT NOT NULL,
            price FLOAT NOT NULL,
            cost FLOAT DEFAULT 0,
            "providerId" INT,
            "prestadoraId" INT,
            "checkInDate" TIMESTAMP,
            "checkOutDate" TIMESTAMP,
            nights INT,
            "paxAdults" INT,
            "paxChildren" INT,
            "serviceType" VARCHAR(255),
            destination VARCHAR(255),
            "reservationCode" VARCHAR(255),
            "sellerCommission" FLOAT,
            "ticketPrinterCommission" FLOAT,
            "comboId" INT,
            "mainTaxId" INT,
            "inNationality" INT DEFAULT 1,
            "service" TEXT,
            "servicios" TEXT,
            "descripcion" TEXT
        );
    END IF;
END $$;
