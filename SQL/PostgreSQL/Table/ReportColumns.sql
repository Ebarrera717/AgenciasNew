DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportColumns') THEN
        CREATE TABLE public."ReportColumns" (
            id SERIAL PRIMARY KEY,
            report_id INTEGER NOT NULL REFERENCES public."Report"(id) ON DELETE CASCADE,
            table_alias VARCHAR(20),
            column_name VARCHAR(100) NOT NULL,
            alias VARCHAR(150),
            is_calculated BOOLEAN DEFAULT false,
            is_visible BOOLEAN DEFAULT true,
            formula_expression TEXT,
            sort_order INTEGER DEFAULT 0
        );
    END IF;
END $$;
