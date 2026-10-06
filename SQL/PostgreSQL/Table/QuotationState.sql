DO $$
DECLARE
    v_max INT;
BEGIN
    CREATE SEQUENCE IF NOT EXISTS public."QuotationState_id_seq" START WITH 1;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationState') THEN
        CREATE TABLE public."QuotationState" (
            "id" integer DEFAULT nextval('public."QuotationState_id_seq"'::regclass) PRIMARY KEY,
            "name" VARCHAR(50) NOT NULL,
            "color" VARCHAR(20),
            "createdAt" TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "code" VARCHAR(25) UNIQUE NOT NULL,
            "isActive" BOOLEAN NOT NULL DEFAULT true
        );
        ALTER SEQUENCE public."QuotationState_id_seq" OWNED BY public."QuotationState".id;
    END IF;

    -- Asegurar columna isActive si la tabla ya existía
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'isActive') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "isActive" BOOLEAN NOT NULL DEFAULT true;
    END IF;

    -- Asegurar pertenencia y default de la secuencia
    BEGIN
        ALTER SEQUENCE public."QuotationState_id_seq" OWNED BY public."QuotationState".id;
        ALTER TABLE public."QuotationState" ALTER COLUMN id SET DEFAULT nextval('public."QuotationState_id_seq"'::regclass);
    EXCEPTION WHEN OTHERS THEN
    END;

    -- Sincronización automática de secuencia al MAX(id)
    BEGIN
        SELECT MAX(id) INTO v_max FROM public."QuotationState";
        IF v_max IS NULL THEN
            PERFORM setval('public."QuotationState_id_seq"', 1, false);
        ELSE
            PERFORM setval('public."QuotationState_id_seq"', v_max, true);
        END IF;
    EXCEPTION WHEN OTHERS THEN
    END;
END $$;
