DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'service') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "service" TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'servicios') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "servicios" TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'descripcion') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "descripcion" TEXT;
    END IF;
END $$;
