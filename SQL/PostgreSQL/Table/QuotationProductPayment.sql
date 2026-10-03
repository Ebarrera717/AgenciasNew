DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment') THEN
        CREATE TABLE public."QuotationProductPayment" (
            "id" SERIAL PRIMARY KEY,
            "quotationProductId" INT NOT NULL,
            "amount" FLOAT NOT NULL,
            "paymentMethod" VARCHAR(100),
            "date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            "reference" VARCHAR(255),
            "creditCardId" INT,
            "cardNumber" VARCHAR(20),
            "authorizationCode" VARCHAR(50),
            "voucher" VARCHAR(50),
            "expirationDate" VARCHAR(10),
            CONSTRAINT "QuotationProductPayment_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct" (id) ON UPDATE CASCADE ON DELETE CASCADE
        );
    END IF;
END $$;
