DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportFilters') THEN
        CREATE TABLE public."ReportFilters" (
            id SERIAL PRIMARY KEY,
            report_id INTEGER NOT NULL REFERENCES public."Report"(id) ON DELETE CASCADE,
            table_alias VARCHAR(20),
            column_name VARCHAR(100) NOT NULL,
            filter_label VARCHAR(150),
            filter_type VARCHAR(50) NOT NULL,
            operator VARCHAR(20) DEFAULT '=',
            sort_order INTEGER DEFAULT 0
        );
    END IF;
END $$;
