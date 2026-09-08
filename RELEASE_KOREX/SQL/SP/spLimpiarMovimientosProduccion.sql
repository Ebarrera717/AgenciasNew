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

    -- Reinicio de secuencias
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_quotation_consecutivo') THEN
        ALTER SEQUENCE public.seq_quotation_consecutivo RESTART WITH 1;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'Invoices_id_seq') THEN
        ALTER SEQUENCE public."Invoices_id_seq" RESTART WITH 1;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Tablas de movimientos vaciadas exitosamente. Parámetros y maestros intactos.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;
