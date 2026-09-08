DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_namespace.nspname = 'public' AND proname = 'spLimpiarMovimientosProduccion'
    LOOP
        EXECUTE 'DROP PROCEDURE IF EXISTS public."spLimpiarMovimientosProduccion"(' || r.argtypes || ') CASCADE;';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spLimpiarMovimientosProduccion"(
    INOUT p_mensaje_resultado text DEFAULT ''
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_tbl TEXT;
    v_tables TEXT[] := ARRAY[
        'Quotation', 'QuotationProduct', 'QuotationProductTax', 'QuotationProductVariable', 
        'QuotationProductPassenger', 'QuotationProductPayment', 'QuotationCombo', 'QuotationInvoice', 
        'QuotationStateHistory', 'QuotationPrintCustomization', 'QuotationManualService', 'PreQuotation', 
        'PreQuotationStateHistory', 'Invoices', 'Invoice', 'InvoicesProduct', 'InvoicesProductTax', 
        'InvoicesProductVariable', 'InvoicesProductPasenger', 'InvoicesProductPayment', 
        'InvoicesProductCombo', 'InvoicesProductItinerary', 'BookingGDS', 'BookingsGDS_log', 
        'BookingProductGDS', 'BookingProductItineraryGDS', 'BookingProductPassangerGDS', 
        'BookingProductTaxGDS', 'BookingProductVariableGDS', 'BookingProductFEEGDS', 
        'BookingProductPaymentGDS', 'BookingsGDSInvoiceAuto', 'BookingGDSInvoiceAutoLog', 
        'BranchGDSInvoiceAuto', 'SystemLog', 'ExecutionPreset', 'ExecutionProcedure', 'Attachment', 
        'EquivalenciasInterfaces_Log'
    ];
BEGIN
    FOREACH v_tbl IN ARRAY v_tables
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = v_tbl) THEN
            EXECUTE 'TRUNCATE TABLE public."' || v_tbl || '" CASCADE;';
        END IF;
    END LOOP;

    -- Reinicio dinámico universal de TODAS las secuencias en public (IDs y Consecutivos)
    FOR r IN 
        SELECT c.relname 
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relkind = 'S'
    LOOP
        EXECUTE 'ALTER SEQUENCE public."' || r.relname || '" RESTART WITH 1;';
    END LOOP;

    -- Reiniciar los consecutivos de transacciones a su valor inicial configurado
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TransactionConsecutive') THEN
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = COALESCE("initialNumber", 1);
    END IF;

    p_mensaje_resultado := 'SUCCESS: Tablas de movimientos vaciadas y consecutivos/secuencias reiniciados exitosamente a 1.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
