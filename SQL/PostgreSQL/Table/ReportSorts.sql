DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportSorts') THEN
        CREATE TABLE public."ReportSorts" (
            id SERIAL PRIMARY KEY,
            report_id INTEGER NOT NULL REFERENCES public."Report"(id) ON DELETE CASCADE,
            column_expr TEXT NOT NULL,
            direction VARCHAR(10) DEFAULT 'ASC',
            sort_order INTEGER DEFAULT 0
        );
    END IF;
END $$;
