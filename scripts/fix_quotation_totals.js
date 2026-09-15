const { getSQLServerConnection } = require('../src/lib/sqlserver');
const { Pool } = require('pg');

async function fixTotals() {
    console.log('--- Fixing Quotation Totals in SQL Server ---');
    try {
        const pool = await getSQLServerConnection();
        const resBefore = await pool.request().query('SELECT id, totalAmount FROM dbo.[Quotation]');
        console.log('SQL Server Quotations BEFORE:', resBefore.recordset);

        await pool.request().query(`
            UPDATE q
            SET q.totalAmount = ISNULL((
                SELECT SUM(ISNULL(qpt.explicitAmount, 0))
                FROM dbo.[QuotationProductTax] qpt
                JOIN dbo.[QuotationProduct] qp ON qpt.quotationProductId = qp.id
                WHERE qp.quotationId = q.id
            ), ISNULL((
                SELECT SUM(ISNULL(qp.price, 0) * ISNULL(qp.quantity, 1))
                FROM dbo.[QuotationProduct] qp
                WHERE qp.quotationId = q.id
            ), 0))
            FROM dbo.[Quotation] q
            WHERE q.totalAmount IS NULL OR q.totalAmount = 0;
        `);

        const resAfter = await pool.request().query('SELECT id, totalAmount FROM dbo.[Quotation]');
        console.log('SQL Server Quotations AFTER:', resAfter.recordset);
        await pool.close();
    } catch (e) {
        console.error('SQL Server Error:', e.message);
    }

    console.log('\n--- Fixing Quotation Totals in PostgreSQL ---');
    try {
        const pgPool = new Pool({
            connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@192.168.80.26:5432/Korex_colaereo'
        });
        const pgBefore = await pgPool.query('SELECT id, "totalAmount" FROM public."Quotation"');
        console.log('PostgreSQL Quotations BEFORE:', pgBefore.rows);

        await pgPool.query(`
            UPDATE public."Quotation" q
            SET "totalAmount" = COALESCE((
                SELECT COALESCE(SUM(qpt."explicitAmount"), 0)
                FROM public."QuotationProductTax" qpt
                JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
                WHERE qp."quotationId" = q.id
            ), (
                SELECT COALESCE(SUM(qp.price * qp.quantity), 0)
                FROM public."QuotationProduct" qp
                WHERE qp."quotationId" = q.id
            ), 0)
            WHERE q."totalAmount" IS NULL OR q."totalAmount" = 0;
        `);

        const pgAfter = await pgPool.query('SELECT id, "totalAmount" FROM public."Quotation"');
        console.log('PostgreSQL Quotations AFTER:', pgAfter.rows);
        await pgPool.end();
    } catch (e) {
        console.error('PostgreSQL Error:', e.message);
    }
}

fixTotals();
