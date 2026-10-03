DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportJoins') THEN
        CREATE TABLE public."ReportJoins" (
            id SERIAL PRIMARY KEY,
            report_id INTEGER NOT NULL REFERENCES public."Report"(id) ON DELETE CASCADE,
            table_name VARCHAR(100) NOT NULL,
            alias VARCHAR(20) NOT NULL,
            join_type VARCHAR(50) NOT NULL DEFAULT 'INNER JOIN',
            join_condition TEXT NOT NULL,
            sort_order INTEGER DEFAULT 0
        );
    END IF;
END $$;
