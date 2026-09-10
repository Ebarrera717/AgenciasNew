DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log') THEN
        CREATE TABLE public."EquivalenciasInterfaces_Log" (
            "id" integer DEFAULT nextval('"EquivalenciasInterfaces_Log_id_seq"'::regclass) NOT NULL,
            "Id_Interfaces" integer,
            "cd_maestro" character varying,
            "cd_codigo" character varying,
            "cd_codigoInte" character varying,
            "cd_operacion" character varying,
            "ds_xmlpeticion" text,
            "ds_xmlrespuesta" text,
            "ds_xmlorg" text,
            "ds_Logpeticion" text,
            "fecha_creacion" timestamp without time zone DEFAULT now()
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Attachment') THEN
        CREATE TABLE public."Attachment" (
            "id" integer DEFAULT nextval('"Attachment_id_seq"'::regclass) NOT NULL,
            "quotationId" integer NOT NULL,
            "fileName" text NOT NULL,
            "fileType" text NOT NULL,
            "fileSize" integer NOT NULL,
            "fileContent" bytea NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ExecutionProcedure') THEN
        CREATE TABLE public."ExecutionProcedure" (
            "id" integer DEFAULT nextval('"ExecutionProcedure_id_seq"'::regclass) NOT NULL,
            "name" character varying NOT NULL,
            "spName" character varying NOT NULL,
            "description" text,
            "parameters" jsonb,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ExecutionPreset') THEN
        CREATE TABLE public."ExecutionPreset" (
            "id" integer DEFAULT nextval('"ExecutionPreset_id_seq"'::regclass) NOT NULL,
            "name" character varying NOT NULL,
            "procedureId" integer NOT NULL,
            "description" text,
            "filterValues" jsonb,
            "filterConfig" jsonb,
            "columnConfigs" jsonb,
            "selectedTotals" jsonb,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog') THEN
        CREATE TABLE public."BookingGDSInvoiceAutoLog" (
            "Id" integer DEFAULT nextval('"BookingGDSInvoiceAutoLog_id_seq"'::regclass) NOT NULL,
            "branchId" integer,
            "implanteId" integer,
            "date" timestamp without time zone,
            "menssage" text,
            "bookingCode" character varying,
            "bookingId" integer,
            "error" boolean,
            "file" text,
            "userId" integer
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto') THEN
        CREATE TABLE public."BookingsGDSInvoiceAuto" (
            "id" integer DEFAULT nextval('"BookingsGDSInvoiceAuto_id_seq"'::regclass) NOT NULL,
            "Branch" character varying,
            "implant" character varying,
            "bookingCode" character varying,
            "bookingId" integer
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS') THEN
        CREATE TABLE public."BookingProductFEEGDS" (
            "id" integer DEFAULT nextval('"BookingProductFEEGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "type" text NOT NULL,
            "description" text NOT NULL,
            "billigconcept" text NOT NULL,
            "servicetype" text NOT NULL,
            "amount" double precision NOT NULL,
            "tax" double precision NOT NULL,
            "other" double precision NOT NULL,
            "total" double precision NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log') THEN
        CREATE TABLE public."BookingsGDS_log" (
            "id" integer DEFAULT nextval('"BookingsGDS_log_id_seq"'::regclass) NOT NULL,
            "blanch" character varying,
            "implant" character varying,
            "message" text,
            "file" character varying,
            "codebooking" character varying,
            "booking" text,
            "error" integer DEFAULT 0 NOT NULL
        );
    END IF;


    CREATE SEQUENCE IF NOT EXISTS public.seq_quotation_consecutivo START WITH 1;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Resolution') THEN
        CREATE TABLE public."Resolution" (
            "id" integer DEFAULT nextval('"Resolution_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "date" timestamp with time zone,
            "expira" timestamp with time zone,
            "inicial" bigint,
            "end" bigint,
            "autoriza" character varying,
            "prefijo" character varying,
            "alerta" integer,
            "day" integer,
            "permitir" boolean DEFAULT false,
            "activo" boolean DEFAULT true
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS') THEN
        CREATE TABLE public."BookingProductVariableGDS" (
            "id" integer DEFAULT nextval('"BookingProductVariableGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer NOT NULL,
            "code" text,
            "name" text,
            "value" text
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingGDS') THEN
        CREATE TABLE public."BookingGDS" (
            "id" integer DEFAULT nextval('"BookingGDS_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "type" character varying NOT NULL,
            "blanch" character varying NOT NULL,
            "implant" character varying,
            "external" boolean DEFAULT false NOT NULL,
            "gds" integer,
            "date" timestamp without time zone DEFAULT now(),
            "currency" text NOT NULL,
            "exchangeRate" double precision NOT NULL,
            "tiquetPrinter" character varying NOT NULL,
            "seller" character varying NOT NULL,
            "client" character varying NOT NULL,
            "booking" text,
            "typetransaction" character varying,
            "iata" character varying,
            "description" text,
            "observation" text,
            "state" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductGDS') THEN
        CREATE TABLE public."BookingProductGDS" (
            "id" integer DEFAULT nextval('"BookingProductGDS_id_seq"'::regclass) NOT NULL,
            "bookingId" integer NOT NULL,
            "code" character varying NOT NULL,
            "type" character varying,
            "service" text,
            "description" text,
            "prestadoracode" character varying,
            "prestadorainitials" character varying,
            "prestadoradist" character varying,
            "provider" character varying,
            "quantity" integer NOT NULL,
            "price" double precision NOT NULL,
            "cost" double precision DEFAULT 0,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "nights" integer,
            "paxAdults" integer,
            "paxChildren" integer,
            "serviceType" text,
            "billingConcept" text,
            "destination" text,
            "reservationCode" text,
            "sellerCom" double precision,
            "ticketPrinterCom" double precision,
            "inNationality" integer DEFAULT 1,
            "state" character varying DEFAULT 'NUEVO'::character varying,
            "conjunction" integer DEFAULT 0,
            "revised" character varying,
            "typeproduct" character varying,
            "consecutive" character varying,
            "penalty" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS') THEN
        CREATE TABLE public."BookingProductItineraryGDS" (
            "id" integer DEFAULT nextval('"BookingProductItineraryGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer NOT NULL,
            "orden" integer,
            "origin" text NOT NULL,
            "destination" text NOT NULL,
            "class" text NOT NULL,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "terminal" text NOT NULL,
            "prestadoraCode" text NOT NULL,
            "farebasis" text NOT NULL,
            "Numflight" character varying,
            "Typeflight" character varying,
            "amount" double precision NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS') THEN
        CREATE TABLE public."BookingProductPaymentGDS" (
            "id" integer DEFAULT nextval('"BookingProductPaymentGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer,
            "bookingProductFEEId" integer,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "type" character varying NOT NULL,
            "typecreditcard" character varying,
            "numbercreditcard" character varying,
            "vouchercreditcard" character varying,
            "expiredcreditcard" character varying,
            "authcreditcard" character varying,
            "quotas" integer,
            "bank" character varying,
            "square" character varying,
            "reference" character varying,
            "policy" character varying,
            "policyannex" character varying,
            "amount" double precision NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS') THEN
        CREATE TABLE public."BookingProductTaxGDS" (
            "id" integer DEFAULT nextval('"BookingProductTaxGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "type" character varying NOT NULL,
            "ismain" boolean DEFAULT false,
            "percentage" double precision NOT NULL,
            "amount" double precision NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS') THEN
        CREATE TABLE public."BookingProductPassangerGDS" (
            "id" integer DEFAULT nextval('"BookingProductPassangerGDS_id_seq"'::regclass) NOT NULL,
            "bookingProductId" integer NOT NULL,
            "code" character varying,
            "firstnm" character varying,
            "lastnm" character varying,
            "prefix" character varying,
            "identification" character varying,
            "phone" character varying,
            "email" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ProviderType') THEN
        CREATE TABLE public."ProviderType" (
            "id" integer DEFAULT nextval('"ProviderType_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "isAirline" boolean DEFAULT false NOT NULL,
            "active" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'PreQuotationStateHistory') THEN
        CREATE TABLE public."PreQuotationStateHistory" (
            "id" integer DEFAULT nextval('"PreQuotationStateHistory_id_seq"'::regclass) NOT NULL,
            "preQuotationId" integer NOT NULL,
            "state" character varying NOT NULL,
            "description" text,
            "userId" integer NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'PreQuotation') THEN
        CREATE TABLE public."PreQuotation" (
            "id" integer DEFAULT nextval('"PreQuotation_id_seq"'::regclass) NOT NULL,
            "consecutivo" integer NOT NULL,
            "clientNameText" text,
            "clientId" integer,
            "headerDescription" text,
            "providerId" integer,
            "ticketPrinterId" integer,
            "sellerId" integer,
            "branchId" integer NOT NULL,
            "preQuotationType" character varying,
            "quotationNotice" text,
            "noticeResponse" text,
            "startDate" timestamp without time zone,
            "endDate" timestamp without time zone,
            "customFields" jsonb,
            "state" character varying DEFAULT 'POR COTIZAR'::character varying,
            "convertedQuotationId" integer,
            "convertedAt" timestamp without time zone,
            "convertedUserId" integer,
            "userId" integer NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportSorts') THEN
        CREATE TABLE public."ReportSorts" (
            "id" integer DEFAULT nextval('"ReportSorts_id_seq"'::regclass) NOT NULL,
            "report_id" integer NOT NULL,
            "column_expr" text NOT NULL,
            "direction" character varying DEFAULT 'ASC'::character varying,
            "sort_order" integer DEFAULT 0
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportFilters') THEN
        CREATE TABLE public."ReportFilters" (
            "id" integer DEFAULT nextval('"ReportFilters_id_seq"'::regclass) NOT NULL,
            "report_id" integer NOT NULL,
            "table_alias" character varying,
            "column_name" character varying NOT NULL,
            "filter_label" character varying,
            "filter_type" character varying NOT NULL,
            "operator" character varying DEFAULT '='::character varying,
            "sort_order" integer DEFAULT 0
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportJoins') THEN
        CREATE TABLE public."ReportJoins" (
            "id" integer DEFAULT nextval('"ReportJoins_id_seq"'::regclass) NOT NULL,
            "report_id" integer NOT NULL,
            "table_name" character varying NOT NULL,
            "alias" character varying NOT NULL,
            "join_type" character varying DEFAULT 'INNER JOIN'::character varying NOT NULL,
            "join_condition" text NOT NULL,
            "sort_order" integer DEFAULT 0
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ReportColumns') THEN
        CREATE TABLE public."ReportColumns" (
            "id" integer DEFAULT nextval('"ReportColumns_id_seq"'::regclass) NOT NULL,
            "report_id" integer NOT NULL,
            "table_alias" character varying,
            "column_name" character varying NOT NULL,
            "alias" character varying,
            "is_calculated" boolean DEFAULT false,
            "is_visible" boolean DEFAULT true,
            "formula_expression" text,
            "sort_order" integer DEFAULT 0
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Report') THEN
        CREATE TABLE public."Report" (
            "id" integer DEFAULT nextval('"Report_id_seq"'::regclass) NOT NULL,
            "name" character varying NOT NULL,
            "base_table" character varying,
            "description" text,
            "custom_sql" text,
            "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Menu') THEN
        CREATE TABLE public."Menu" (
            "id" integer DEFAULT nextval('"Menu_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "parent" integer,
            "action" character varying NOT NULL,
            "activo" boolean DEFAULT true
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Currency') THEN
        CREATE TABLE public."Currency" (
            "id" integer DEFAULT nextval('"Currency_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "exchangeRate" double precision NOT NULL,
            "decimals" integer DEFAULT 2 NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Role') THEN
        CREATE TABLE public."Role" (
            "id" integer DEFAULT nextval('"Role_id_seq"'::regclass) NOT NULL,
            "name" text NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'SystemLog') THEN
        CREATE TABLE public."SystemLog" (
            "id" integer DEFAULT nextval('"SystemLog_id_seq"'::regclass) NOT NULL,
            "userId" integer,
            "action" text NOT NULL,
            "module" text NOT NULL,
            "description" text NOT NULL,
            "metadata" jsonb,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductCombo') THEN
        CREATE TABLE public."InvoicesProductCombo" (
            "id" integer DEFAULT nextval('"InvoicesProductCombo_id_seq"'::regclass) NOT NULL,
            "invoiceId" integer NOT NULL,
            "comboId" integer NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary') THEN
        CREATE TABLE public."InvoicesProductItinerary" (
            "id" integer DEFAULT nextval('"InvoicesProductItinerary_id_seq"'::regclass) NOT NULL,
            "invoiceProductId" integer NOT NULL,
            "orden" integer,
            "origin" character varying NOT NULL,
            "destination" character varying NOT NULL,
            "class" character varying,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "terminal" character varying,
            "prestadoraCode" character varying,
            "farebasis" character varying,
            "Numflight" character varying,
            "Typeflight" character varying,
            "amount" double precision,
            "co2" double precision
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TicketType') THEN
        CREATE TABLE public."TicketType" (
            "id" integer DEFAULT nextval('"TicketType_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "description" text,
            "isActive" boolean DEFAULT true
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Payment') THEN
        CREATE TABLE public."Payment" (
            "id" integer DEFAULT nextval('"Payment_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "inactive" boolean DEFAULT false NOT NULL,
            "iscash" boolean DEFAULT false NOT NULL,
            "iscredit" boolean DEFAULT false NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable') THEN
        CREATE TABLE public."InvoicesProductVariable" (
            "id" integer DEFAULT nextval('"InvoicesProductVariable_id_seq"'::regclass) NOT NULL,
            "invoiceProductId" integer NOT NULL,
            "masterVariableId" integer NOT NULL,
            "value" character varying NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger') THEN
        CREATE TABLE public."InvoicesProductPasenger" (
            "id" integer DEFAULT nextval('"InvoicesProductPasenger_id_seq"'::regclass) NOT NULL,
            "invoiceProductId" integer NOT NULL,
            "name" character varying NOT NULL,
            "document" character varying NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProduct') THEN
        CREATE TABLE public."InvoicesProduct" (
            "id" integer DEFAULT nextval('"InvoicesProduct_id_seq"'::regclass) NOT NULL,
            "invoiceId" integer NOT NULL,
            "productId" integer NOT NULL,
            "ticketCode" text,
            "quantity" integer NOT NULL,
            "price" double precision NOT NULL,
            "cost" double precision DEFAULT 0,
            "providerId" integer,
            "prestadoraId" integer,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "nights" integer,
            "paxAdults" integer,
            "paxChildren" integer,
            "serviceType" character varying,
            "destination" character varying,
            "reservationCode" character varying,
            "sellerCommission" double precision,
            "ticketPrinterCommission" double precision,
            "comboId" integer,
            "mainTaxId" integer,
            "inNationality" integer DEFAULT 1,
            "servicios" text,
            "descripcion" text,
            "itinerary" text,
            "class" character varying,
            "ticketTypeId" integer,
            "airline" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment') THEN
        CREATE TABLE public."InvoicesProductPayment" (
            "id" integer DEFAULT nextval('"InvoicesProductPayment_id_seq"'::regclass) NOT NULL,
            "invoiceProductId" integer NOT NULL,
            "amount" double precision NOT NULL,
            "paymentMethod" character varying,
            "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
            "reference" character varying,
            "authorizationCode" text,
            "cardNumber" text,
            "creditCardId" integer,
            "expirationDate" text,
            "voucher" text
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax') THEN
        CREATE TABLE public."InvoicesProductTax" (
            "id" integer DEFAULT nextval('"InvoicesProductTax_id_seq"'::regclass) NOT NULL,
            "invoiceProductId" integer NOT NULL,
            "chargeAndTaxId" integer NOT NULL,
            "valueSnapshot" double precision NOT NULL,
            "valueTypeSnapshot" character varying NOT NULL,
            "explicitAmount" double precision,
            "isMain" boolean DEFAULT false
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Implant') THEN
        CREATE TABLE public."Implant" (
            "id" integer DEFAULT nextval('"Implant_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "branchId" integer,
            "logo" bytea,
            "template" bytea,
            "templateConfig" jsonb,
            "htmlTemplate" text,
            "Logo" bytea
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Invoices') THEN
        CREATE TABLE public."Invoices" (
            "id" integer DEFAULT nextval('"Invoices_id_seq"'::regclass) NOT NULL,
            "internalNumber" character varying NOT NULL,
            "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "clientId" integer NOT NULL,
            "currency" character varying NOT NULL,
            "exchangeRate" double precision NOT NULL,
            "branchId" integer NOT NULL,
            "implantId" integer,
            "sellerId" integer,
            "ticketPrinterId" integer,
            "baseCommissionable" double precision NOT NULL,
            "commissionPercentage" double precision NOT NULL,
            "chargesAndTaxes" double precision NOT NULL,
            "totalAmount" double precision NOT NULL,
            "userId" integer,
            "state" character varying DEFAULT 'NUEVO'::character varying,
            "fuente" character varying,
            "serie" character varying,
            "consecutivo" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Master') THEN
        CREATE TABLE public."Master" (
            "id" integer DEFAULT nextval('"Master_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "inactivo" boolean DEFAULT false NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Interfaces') THEN
        CREATE TABLE public."Interfaces" (
            "id" integer DEFAULT nextval('"Interfaces_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "inactivo" boolean DEFAULT false NOT NULL,
            "bl_genera_archivoplano" boolean DEFAULT false NOT NULL,
            "ds_storedprocedure_archivoplano" text,
            "bl_job" boolean DEFAULT false NOT NULL,
            "ds_namejob" text,
            "bl_facturador" boolean DEFAULT false NOT NULL,
            "id_gds" integer
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces') THEN
        CREATE TABLE public."EquivalencesInterfaces" (
            "id" integer DEFAULT nextval('"EquivalencesInterfaces_id_seq"'::regclass) NOT NULL,
            "id_interfaces" integer NOT NULL,
            "id_master" integer NOT NULL,
            "cd_maestro" text NOT NULL,
            "cd_codigo" text NOT NULL,
            "cd_codigointe" text NOT NULL,
            "dt_fecha" timestamp without time zone DEFAULT now()
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'CreditCard') THEN
        CREATE TABLE public."CreditCard" (
            "id" integer DEFAULT nextval('"CreditCard_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "type" text NOT NULL,
            "inactive" boolean DEFAULT false NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public."CreditCard" WHERE UPPER(TRIM("code")) = 'VI') THEN
        INSERT INTO public."CreditCard" ("code", "name", "type", "inactive") VALUES ('VI', 'Visa', 'CREDITO', false);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public."CreditCard" WHERE UPPER(TRIM("code")) = 'MC') THEN
        INSERT INTO public."CreditCard" ("code", "name", "type", "inactive") VALUES ('MC', 'Mastercard', 'CREDITO', false);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public."CreditCard" WHERE UPPER(TRIM("code")) = 'AX') THEN
        INSERT INTO public."CreditCard" ("code", "name", "type", "inactive") VALUES ('AX', 'American Express', 'CREDITO', false);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public."CreditCard" WHERE UPPER(TRIM("code")) = 'DC') THEN
        INSERT INTO public."CreditCard" ("code", "name", "type", "inactive") VALUES ('DC', 'Diners Club', 'CREDITO', false);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public."CreditCard" WHERE UPPER(TRIM("code")) = 'TP') THEN
        INSERT INTO public."CreditCard" ("code", "name", "type", "inactive") VALUES ('TP', 'Tarjeta Propia / UATP', 'CREDITO', false);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Countries') THEN
        CREATE TABLE public."Countries" (
            "id" integer DEFAULT nextval('"Countries_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "dane" character varying,
            "region" character varying,
            "prefix" character varying,
            "curencyId" integer
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationState') THEN
        CREATE TABLE public."QuotationState" (
            "id" integer DEFAULT nextval('"QuotationState_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "color" character varying,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'SystemParameter') THEN
        CREATE TABLE public."SystemParameter" (
            "id" integer DEFAULT nextval('"SystemParameter_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "value" text NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment') THEN
        CREATE TABLE public."QuotationProductPayment" (
            "id" integer DEFAULT nextval('"QuotationProductPayment_id_seq"'::regclass) NOT NULL,
            "quotationProductId" integer NOT NULL,
            "amount" double precision NOT NULL,
            "paymentMethod" character varying,
            "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
            "reference" character varying,
            "creditCardId" integer,
            "cardNumber" character varying,
            "authorizationCode" character varying,
            "voucher" character varying,
            "expirationDate" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProductVariable') THEN
        CREATE TABLE public."QuotationProductVariable" (
            "id" integer DEFAULT nextval('"QuotationProductVariable_id_seq"'::regclass) NOT NULL,
            "quotationProductId" integer NOT NULL,
            "masterVariableId" integer NOT NULL,
            "value" text NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ChargeAndTax') THEN
        CREATE TABLE public."ChargeAndTax" (
            "id" integer DEFAULT nextval('"ChargeAndTax_id_seq"'::regclass) NOT NULL,
            "name" text NOT NULL,
            "type" text NOT NULL,
            "valueType" text NOT NULL,
            "value" double precision NOT NULL,
            "isEditable" boolean DEFAULT true NOT NULL,
            "code" text
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProductTax') THEN
        CREATE TABLE public."QuotationProductTax" (
            "id" integer DEFAULT nextval('"QuotationProductTax_id_seq"'::regclass) NOT NULL,
            "quotationProductId" integer NOT NULL,
            "chargeAndTaxId" integer NOT NULL,
            "valueSnapshot" double precision NOT NULL,
            "valueTypeSnapshot" text NOT NULL,
            "explicitAmount" double precision,
            "isMain" boolean DEFAULT false NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProductPassenger') THEN
        CREATE TABLE public."QuotationProductPassenger" (
            "id" integer DEFAULT nextval('"QuotationProductPassenger_id_seq"'::regclass) NOT NULL,
            "quotationProductId" integer NOT NULL,
            "name" text NOT NULL,
            "document" text NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationProduct') THEN
        CREATE TABLE public."QuotationProduct" (
            "id" integer DEFAULT nextval('"QuotationProduct_id_seq"'::regclass) NOT NULL,
            "quotationId" integer NOT NULL,
            "productId" integer NOT NULL,
            "quantity" integer NOT NULL,
            "price" double precision NOT NULL,
            "cost" double precision DEFAULT 0,
            "providerId" integer,
            "prestadoraId" integer,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "nights" integer,
            "paxAdults" integer,
            "paxChildren" integer,
            "serviceType" text,
            "destination" text,
            "reservationCode" text,
            "sellerCommission" double precision,
            "ticketPrinterCommission" double precision,
            "comboId" integer,
            "mainTaxId" integer,
            "inNationality" integer DEFAULT 1,
            "service" text,
            "description" text,
            "servicios" text,
            "descripcion" text,
            "passenger" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationCombo') THEN
        CREATE TABLE public."QuotationCombo" (
            "id" integer DEFAULT nextval('"QuotationCombo_id_seq"'::regclass) NOT NULL,
            "quotationId" integer NOT NULL,
            "comboId" integer NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory') THEN
        CREATE TABLE public."QuotationStateHistory" (
            "id" integer DEFAULT nextval('"QuotationStateHistory_id_seq"'::regclass) NOT NULL,
            "quotationId" integer NOT NULL,
            "state" character varying NOT NULL,
            "description" text,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "userId" integer
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'MasterVariable') THEN
        CREATE TABLE public."MasterVariable" (
            "id" integer DEFAULT nextval('"MasterVariable_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ComboProduct') THEN
        CREATE TABLE public."ComboProduct" (
            "id" integer DEFAULT nextval('"ComboProduct_id_seq"'::regclass) NOT NULL,
            "comboId" integer NOT NULL,
            "productId" integer NOT NULL,
            "price" double precision NOT NULL,
            "cost" double precision DEFAULT 0,
            "checkInDate" timestamp without time zone,
            "checkOutDate" timestamp without time zone,
            "prestadoraId" integer,
            "mainTaxId" integer,
            "paxAdults" integer,
            "paxChildren" integer,
            "providerId" integer,
            "inNationality" integer DEFAULT 1,
            "quantity" integer DEFAULT 1 NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ComboProductTax') THEN
        CREATE TABLE public."ComboProductTax" (
            "id" integer DEFAULT nextval('"ComboProductTax_id_seq"'::regclass) NOT NULL,
            "comboProductId" integer NOT NULL,
            "chargeAndTaxId" integer NOT NULL,
            "amount" double precision NOT NULL,
            "isMain" boolean DEFAULT false NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Combo') THEN
        CREATE TABLE public."Combo" (
            "id" integer DEFAULT nextval('"Combo_id_seq"'::regclass) NOT NULL,
            "code" text NOT NULL,
            "name" text NOT NULL,
            "cupos" integer DEFAULT 0,
            "currencyId" integer,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "updatedAt" timestamp without time zone DEFAULT now()
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Cities') THEN
        CREATE TABLE public."Cities" (
            "id" integer DEFAULT nextval('"Cities_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "countriesId" integer NOT NULL,
            "statecode" character varying,
            "iata" character varying
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'CellCustomization') THEN
        CREATE TABLE public."CellCustomization" (
            "id" integer DEFAULT nextval('"CellCustomization_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "value" character varying,
            "branchId" integer,
            "implantId" integer
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Airports') THEN
        CREATE TABLE public."Airports" (
            "id" integer DEFAULT nextval('"Airports_id_seq"'::regclass) NOT NULL,
            "code" character varying NOT NULL,
            "name" character varying NOT NULL,
            "citiesId" integer NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'id') THEN
        ALTER TABLE public."Branch" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'code') THEN
        ALTER TABLE public."Branch" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'name') THEN
        ALTER TABLE public."Branch" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'logo') THEN
        ALTER TABLE public."Branch" ADD COLUMN "logo" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'template') THEN
        ALTER TABLE public."Branch" ADD COLUMN "template" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'templateConfig') THEN
        ALTER TABLE public."Branch" ADD COLUMN "templateConfig" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'htmlTemplate') THEN
        ALTER TABLE public."Branch" ADD COLUMN "htmlTemplate" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'id') THEN
        ALTER TABLE public."Client" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'name') THEN
        ALTER TABLE public."Client" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'document') THEN
        ALTER TABLE public."Client" ADD COLUMN "document" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'contactInfo') THEN
        ALTER TABLE public."Client" ADD COLUMN "contactInfo" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'address') THEN
        ALTER TABLE public."Client" ADD COLUMN "address" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'mandatoryVariables') THEN
        ALTER TABLE public."Client" ADD COLUMN "mandatoryVariables" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'creditDays') THEN
        ALTER TABLE public."Client" ADD COLUMN "creditDays" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'id') THEN
        ALTER TABLE public."Implant" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'code') THEN
        ALTER TABLE public."Implant" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'name') THEN
        ALTER TABLE public."Implant" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'branchId') THEN
        ALTER TABLE public."Implant" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'logo') THEN
        ALTER TABLE public."Implant" ADD COLUMN "logo" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'template') THEN
        ALTER TABLE public."Implant" ADD COLUMN "template" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'templateConfig') THEN
        ALTER TABLE public."Implant" ADD COLUMN "templateConfig" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'htmlTemplate') THEN
        ALTER TABLE public."Implant" ADD COLUMN "htmlTemplate" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'Logo') THEN
        ALTER TABLE public."Implant" ADD COLUMN "Logo" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'id') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'name') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'type') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "type" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'valueType') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "valueType" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'value') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "value" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'isEditable') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "isEditable" boolean DEFAULT true NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'code') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'targetTaxId') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "targetTaxId" integer NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'id') THEN
        ALTER TABLE public."Menu" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'code') THEN
        ALTER TABLE public."Menu" ADD COLUMN "code" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'name') THEN
        ALTER TABLE public."Menu" ADD COLUMN "name" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'parent') THEN
        ALTER TABLE public."Menu" ADD COLUMN "parent" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'action') THEN
        ALTER TABLE public."Menu" ADD COLUMN "action" character varying(500) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Menu' AND column_name = 'activo') THEN
        ALTER TABLE public."Menu" ADD COLUMN "activo" boolean DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemParameter' AND column_name = 'id') THEN
        ALTER TABLE public."SystemParameter" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemParameter' AND column_name = 'code') THEN
        ALTER TABLE public."SystemParameter" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemParameter' AND column_name = 'name') THEN
        ALTER TABLE public."SystemParameter" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemParameter' AND column_name = 'value') THEN
        ALTER TABLE public."SystemParameter" ADD COLUMN "value" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'id') THEN
        ALTER TABLE public."Product" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'type') THEN
        ALTER TABLE public."Product" ADD COLUMN "type" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'description') THEN
        ALTER TABLE public."Product" ADD COLUMN "description" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'basePrice') THEN
        ALTER TABLE public."Product" ADD COLUMN "basePrice" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'cost') THEN
        ALTER TABLE public."Product" ADD COLUMN "cost" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'billingConcept') THEN
        ALTER TABLE public."Product" ADD COLUMN "billingConcept" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'serviceType') THEN
        ALTER TABLE public."Product" ADD COLUMN "serviceType" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'code') THEN
        ALTER TABLE public."Product" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'airlineItinerary') THEN
        ALTER TABLE public."Product" ADD COLUMN "airlineItinerary" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'classItinerary') THEN
        ALTER TABLE public."Product" ADD COLUMN "classItinerary" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'flightItinerary') THEN
        ALTER TABLE public."Product" ADD COLUMN "flightItinerary" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'ticketTypeId') THEN
        ALTER TABLE public."Product" ADD COLUMN "ticketTypeId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'mandatoryFields') THEN
        ALTER TABLE public."Product" ADD COLUMN "mandatoryFields" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Seller' AND column_name = 'id') THEN
        ALTER TABLE public."Seller" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Seller' AND column_name = 'code') THEN
        ALTER TABLE public."Seller" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Seller' AND column_name = 'name') THEN
        ALTER TABLE public."Seller" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Seller' AND column_name = 'email') THEN
        ALTER TABLE public."Seller" ADD COLUMN "email" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketPrinter' AND column_name = 'id') THEN
        ALTER TABLE public."TicketPrinter" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketPrinter' AND column_name = 'code') THEN
        ALTER TABLE public."TicketPrinter" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketPrinter' AND column_name = 'name') THEN
        ALTER TABLE public."TicketPrinter" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketPrinter' AND column_name = 'email') THEN
        ALTER TABLE public."TicketPrinter" ADD COLUMN "email" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'MasterVariable' AND column_name = 'id') THEN
        ALTER TABLE public."MasterVariable" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'MasterVariable' AND column_name = 'code') THEN
        ALTER TABLE public."MasterVariable" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'MasterVariable' AND column_name = 'name') THEN
        ALTER TABLE public."MasterVariable" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'MasterVariable' AND column_name = 'isForAllClients') THEN
        ALTER TABLE public."MasterVariable" ADD COLUMN "isForAllClients" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'MasterVariable' AND column_name = 'isActive') THEN
        ALTER TABLE public."MasterVariable" ADD COLUMN "isActive" boolean DEFAULT true NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Airports' AND column_name = 'id') THEN
        ALTER TABLE public."Airports" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Airports' AND column_name = 'code') THEN
        ALTER TABLE public."Airports" ADD COLUMN "code" character varying(10) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Airports' AND column_name = 'name') THEN
        ALTER TABLE public."Airports" ADD COLUMN "name" character varying(150) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Airports' AND column_name = 'citiesId') THEN
        ALTER TABLE public."Airports" ADD COLUMN "citiesId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'id') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'quotationId') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "quotationId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'fileName') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "fileName" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'fileType') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "fileType" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'fileSize') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "fileSize" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'fileContent') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "fileContent" bytea NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Attachment' AND column_name = 'createdAt') THEN
        ALTER TABLE public."Attachment" ADD COLUMN "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "code" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'type') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "type" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'blanch') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "blanch" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'implant') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "implant" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'external') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "external" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'gds') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "gds" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'date') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "date" timestamp without time zone DEFAULT now();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'currency') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "currency" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'exchangeRate') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "exchangeRate" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'tiquetPrinter') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "tiquetPrinter" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'seller') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "seller" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'client') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "client" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'booking') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "booking" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'typetransaction') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "typetransaction" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'iata') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "iata" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'description') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'observation') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "observation" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDS' AND column_name = 'state') THEN
        ALTER TABLE public."BookingGDS" ADD COLUMN "state" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'Id') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "Id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'branchId') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'implanteId') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "implanteId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'date') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "date" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'menssage') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "menssage" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'bookingCode') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "bookingCode" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'bookingId') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "bookingId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'error') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "error" boolean;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'file') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "file" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingGDSInvoiceAutoLog' AND column_name = 'userId') THEN
        ALTER TABLE public."BookingGDSInvoiceAutoLog" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "bookingProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'name') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'type') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "type" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'description') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "description" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'billigconcept') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "billigconcept" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'servicetype') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "servicetype" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'amount') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'tax') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "tax" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'other') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "other" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductFEEGDS' AND column_name = 'total') THEN
        ALTER TABLE public."BookingProductFEEGDS" ADD COLUMN "total" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'bookingId') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "bookingId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "code" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'type') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "type" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'service') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "service" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'description') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'invoiceId') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "invoiceId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'prestadoracode') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "prestadoracode" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'prestadorainitials') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "prestadorainitials" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'prestadoradist') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "prestadoradist" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'provider') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "provider" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'quantity') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "quantity" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'price') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "price" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'cost') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "cost" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "checkInDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "checkOutDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'nights') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "nights" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'paxAdults') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "paxAdults" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'paxChildren') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "paxChildren" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'serviceType') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "serviceType" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'billingConcept') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "billingConcept" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'destination') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "destination" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'reservationCode') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "reservationCode" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'sellerCom') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "sellerCom" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'ticketPrinterCom') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "ticketPrinterCom" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'inNationality') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "inNationality" integer DEFAULT 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'state') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "state" character varying(25) DEFAULT 'NUEVO'::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'conjunction') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "conjunction" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'revised') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "revised" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'typeproduct') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "typeproduct" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'consecutive') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "consecutive" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductGDS' AND column_name = 'penalty') THEN
        ALTER TABLE public."BookingProductGDS" ADD COLUMN "penalty" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "bookingProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'orden') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "orden" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'origin') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "origin" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'destination') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "destination" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'class') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "class" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "checkInDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "checkOutDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'terminal') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "terminal" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'prestadoraCode') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "prestadoraCode" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'farebasis') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "farebasis" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'Numflight') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "Numflight" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'Typeflight') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "Typeflight" character varying(1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductItineraryGDS' AND column_name = 'amount') THEN
        ALTER TABLE public."BookingProductItineraryGDS" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "bookingProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "code" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'firstnm') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "firstnm" character varying(30);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'lastnm') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "lastnm" character varying(30);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'prefix') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "prefix" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'identification') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "identification" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'phone') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "phone" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPassangerGDS' AND column_name = 'email') THEN
        ALTER TABLE public."BookingProductPassangerGDS" ADD COLUMN "email" character varying(250);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "bookingProductId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'bookingProductFEEId') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "bookingProductFEEId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "code" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'name') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "name" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'type') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "type" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'typecreditcard') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "typecreditcard" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'numbercreditcard') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "numbercreditcard" character varying(50);
    ELSE
        ALTER TABLE public."BookingProductPaymentGDS" ALTER COLUMN "numbercreditcard" TYPE character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'vouchercreditcard') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "vouchercreditcard" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'expiredcreditcard') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "expiredcreditcard" character varying(5);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'authcreditcard') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "authcreditcard" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'quotas') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "quotas" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'bank') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "bank" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'square') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "square" character varying(30);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'reference') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "reference" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'policy') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "policy" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'policyannex') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "policyannex" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductPaymentGDS' AND column_name = 'amount') THEN
        ALTER TABLE public."BookingProductPaymentGDS" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "bookingProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "code" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'name') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "name" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'type') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "type" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'ismain') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "ismain" boolean DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'percentage') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "percentage" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductTaxGDS' AND column_name = 'amount') THEN
        ALTER TABLE public."BookingProductTaxGDS" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS' AND column_name = 'id') THEN
        ALTER TABLE public."BookingProductVariableGDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS' AND column_name = 'bookingProductId') THEN
        ALTER TABLE public."BookingProductVariableGDS" ADD COLUMN "bookingProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS' AND column_name = 'code') THEN
        ALTER TABLE public."BookingProductVariableGDS" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS' AND column_name = 'name') THEN
        ALTER TABLE public."BookingProductVariableGDS" ADD COLUMN "name" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingProductVariableGDS' AND column_name = 'value') THEN
        ALTER TABLE public."BookingProductVariableGDS" ADD COLUMN "value" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto' AND column_name = 'id') THEN
        ALTER TABLE public."BookingsGDSInvoiceAuto" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto' AND column_name = 'Branch') THEN
        ALTER TABLE public."BookingsGDSInvoiceAuto" ADD COLUMN "Branch" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto' AND column_name = 'implant') THEN
        ALTER TABLE public."BookingsGDSInvoiceAuto" ADD COLUMN "implant" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto' AND column_name = 'bookingCode') THEN
        ALTER TABLE public."BookingsGDSInvoiceAuto" ADD COLUMN "bookingCode" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDSInvoiceAuto' AND column_name = 'bookingId') THEN
        ALTER TABLE public."BookingsGDSInvoiceAuto" ADD COLUMN "bookingId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'id') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'blanch') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "blanch" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'implant') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "implant" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'message') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "message" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'file') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "file" character varying(250);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'codebooking') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "codebooking" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'booking') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "booking" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BookingsGDS_log' AND column_name = 'error') THEN
        ALTER TABLE public."BookingsGDS_log" ADD COLUMN "error" integer DEFAULT 0 NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BranchGDSInvoiceAuto' AND column_name = 'id') THEN
        ALTER TABLE public."BranchGDSInvoiceAuto" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BranchGDSInvoiceAuto' AND column_name = 'branchId') THEN
        ALTER TABLE public."BranchGDSInvoiceAuto" ADD COLUMN "branchId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BranchGDSInvoiceAuto' AND column_name = 'gdsId') THEN
        ALTER TABLE public."BranchGDSInvoiceAuto" ADD COLUMN "gdsId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'BranchGDSInvoiceAuto' AND column_name = 'EnvoiceAuto') THEN
        ALTER TABLE public."BranchGDSInvoiceAuto" ADD COLUMN "EnvoiceAuto" boolean DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'id') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'code') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "code" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'name') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'value') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "value" character varying(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'branchId') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CellCustomization' AND column_name = 'implantId') THEN
        ALTER TABLE public."CellCustomization" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'id') THEN
        ALTER TABLE public."Cities" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'code') THEN
        ALTER TABLE public."Cities" ADD COLUMN "code" character varying(10) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'name') THEN
        ALTER TABLE public."Cities" ADD COLUMN "name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'countriesId') THEN
        ALTER TABLE public."Cities" ADD COLUMN "countriesId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'statecode') THEN
        ALTER TABLE public."Cities" ADD COLUMN "statecode" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'iata') THEN
        ALTER TABLE public."Cities" ADD COLUMN "iata" character varying(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'id') THEN
        ALTER TABLE public."Combo" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'code') THEN
        ALTER TABLE public."Combo" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'name') THEN
        ALTER TABLE public."Combo" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'cupos') THEN
        ALTER TABLE public."Combo" ADD COLUMN "cupos" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'currencyId') THEN
        ALTER TABLE public."Combo" ADD COLUMN "currencyId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'createdAt') THEN
        ALTER TABLE public."Combo" ADD COLUMN "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Combo' AND column_name = 'updatedAt') THEN
        ALTER TABLE public."Combo" ADD COLUMN "updatedAt" timestamp without time zone DEFAULT now();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'id') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'comboId') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "comboId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'productId') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "productId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'price') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "price" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'cost') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "cost" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "checkInDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "checkOutDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'prestadoraId') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "prestadoraId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'mainTaxId') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "mainTaxId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'paxAdults') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "paxAdults" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'paxChildren') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "paxChildren" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'providerId') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "providerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'inNationality') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "inNationality" integer DEFAULT 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProduct' AND column_name = 'quantity') THEN
        ALTER TABLE public."ComboProduct" ADD COLUMN "quantity" integer DEFAULT 1 NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProductTax' AND column_name = 'id') THEN
        ALTER TABLE public."ComboProductTax" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProductTax' AND column_name = 'comboProductId') THEN
        ALTER TABLE public."ComboProductTax" ADD COLUMN "comboProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProductTax' AND column_name = 'chargeAndTaxId') THEN
        ALTER TABLE public."ComboProductTax" ADD COLUMN "chargeAndTaxId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProductTax' AND column_name = 'amount') THEN
        ALTER TABLE public."ComboProductTax" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ComboProductTax' AND column_name = 'isMain') THEN
        ALTER TABLE public."ComboProductTax" ADD COLUMN "isMain" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'id') THEN
        ALTER TABLE public."Countries" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'code') THEN
        ALTER TABLE public."Countries" ADD COLUMN "code" character varying(10) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'name') THEN
        ALTER TABLE public."Countries" ADD COLUMN "name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'dane') THEN
        ALTER TABLE public."Countries" ADD COLUMN "dane" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'region') THEN
        ALTER TABLE public."Countries" ADD COLUMN "region" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'prefix') THEN
        ALTER TABLE public."Countries" ADD COLUMN "prefix" character varying(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Countries' AND column_name = 'curencyId') THEN
        ALTER TABLE public."Countries" ADD COLUMN "curencyId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CreditCard' AND column_name = 'id') THEN
        ALTER TABLE public."CreditCard" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CreditCard' AND column_name = 'code') THEN
        ALTER TABLE public."CreditCard" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CreditCard' AND column_name = 'name') THEN
        ALTER TABLE public."CreditCard" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CreditCard' AND column_name = 'type') THEN
        ALTER TABLE public."CreditCard" ADD COLUMN "type" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'CreditCard' AND column_name = 'inactive') THEN
        ALTER TABLE public."CreditCard" ADD COLUMN "inactive" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Currency' AND column_name = 'id') THEN
        ALTER TABLE public."Currency" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Currency' AND column_name = 'code') THEN
        ALTER TABLE public."Currency" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Currency' AND column_name = 'name') THEN
        ALTER TABLE public."Currency" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Currency' AND column_name = 'exchangeRate') THEN
        ALTER TABLE public."Currency" ADD COLUMN "exchangeRate" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Currency' AND column_name = 'decimals') THEN
        ALTER TABLE public."Currency" ADD COLUMN "decimals" integer DEFAULT 2 NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'id') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'id_interfaces') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "id_interfaces" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'id_master') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "id_master" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'cd_maestro') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "cd_maestro" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'cd_codigo') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "cd_codigo" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'cd_codigointe') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "cd_codigointe" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalencesInterfaces' AND column_name = 'dt_fecha') THEN
        ALTER TABLE public."EquivalencesInterfaces" ADD COLUMN "dt_fecha" timestamp without time zone DEFAULT now();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'id') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'Id_Interfaces') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "Id_Interfaces" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'cd_maestro') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "cd_maestro" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'cd_codigo') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "cd_codigo" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'cd_codigoInte') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "cd_codigoInte" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'cd_operacion') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "cd_operacion" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'ds_xmlpeticion') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "ds_xmlpeticion" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'ds_xmlrespuesta') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "ds_xmlrespuesta" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'ds_xmlorg') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "ds_xmlorg" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'ds_Logpeticion') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "ds_Logpeticion" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'EquivalenciasInterfaces_Log' AND column_name = 'fecha_creacion') THEN
        ALTER TABLE public."EquivalenciasInterfaces_Log" ADD COLUMN "fecha_creacion" timestamp(6) without time zone DEFAULT now();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'FormatCellCustomization' AND column_name = 'id') THEN
        ALTER TABLE public."FormatCellCustomization" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'FormatCellCustomization' AND column_name = 'formatId') THEN
        ALTER TABLE public."FormatCellCustomization" ADD COLUMN "formatId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'FormatCellCustomization' AND column_name = 'code') THEN
        ALTER TABLE public."FormatCellCustomization" ADD COLUMN "code" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'FormatCellCustomization' AND column_name = 'name') THEN
        ALTER TABLE public."FormatCellCustomization" ADD COLUMN "name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'FormatCellCustomization' AND column_name = 'value') THEN
        ALTER TABLE public."FormatCellCustomization" ADD COLUMN "value" character varying(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'GDS' AND column_name = 'id') THEN
        ALTER TABLE public."GDS" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'GDS' AND column_name = 'name') THEN
        ALTER TABLE public."GDS" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'id') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'name') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'location') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "location" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'category') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "category" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'providerId') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "providerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'code') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'type') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "type" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'initials') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "initials" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Prestadora' AND column_name = 'nogds') THEN
        ALTER TABLE public."Prestadora" ADD COLUMN "nogds" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'id') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'code') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'name') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'inactivo') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "inactivo" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'bl_genera_archivoplano') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "bl_genera_archivoplano" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'ds_storedprocedure_archivoplano') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "ds_storedprocedure_archivoplano" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'bl_job') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "bl_job" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'ds_namejob') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "ds_namejob" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'bl_facturador') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "bl_facturador" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Interfaces' AND column_name = 'id_gds') THEN
        ALTER TABLE public."Interfaces" ADD COLUMN "id_gds" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'id') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'internalNumber') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "internalNumber" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'date') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'clientId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "clientId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'currency') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "currency" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'exchangeRate') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "exchangeRate" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'branchId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "branchId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'implantId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'sellerId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "sellerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'ticketPrinterId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "ticketPrinterId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'baseCommissionable') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "baseCommissionable" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'commissionPercentage') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "commissionPercentage" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'chargesAndTaxes') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "chargesAndTaxes" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'totalAmount') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "totalAmount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'userId') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'state') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "state" character varying(25) DEFAULT 'NUEVO'::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'fuente') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "fuente" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'serie') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "serie" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'consecutivo') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "consecutivo" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Invoices' AND column_name = 'dueDate') THEN
        ALTER TABLE public."Invoices" ADD COLUMN "dueDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'invoiceId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "invoiceId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'productId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "productId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'ticketCode') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "ticketCode" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'quantity') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "quantity" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'price') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "price" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'cost') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "cost" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'providerId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "providerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'prestadoraId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "prestadoraId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "checkInDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "checkOutDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'nights') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "nights" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'paxAdults') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "paxAdults" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'paxChildren') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "paxChildren" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'serviceType') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "serviceType" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'destination') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "destination" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'reservationCode') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "reservationCode" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'sellerCommission') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "sellerCommission" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'ticketPrinterCommission') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "ticketPrinterCommission" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'comboId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "comboId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'mainTaxId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "mainTaxId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'inNationality') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "inNationality" integer DEFAULT 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'servicios') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "servicios" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'descripcion') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "descripcion" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'itinerary') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "itinerary" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'class') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "class" character varying(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'ticketTypeId') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "ticketTypeId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProduct' AND column_name = 'airline') THEN
        ALTER TABLE public."InvoicesProduct" ADD COLUMN "airline" character varying(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductCombo' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductCombo" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductCombo' AND column_name = 'invoiceId') THEN
        ALTER TABLE public."InvoicesProductCombo" ADD COLUMN "invoiceId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductCombo' AND column_name = 'comboId') THEN
        ALTER TABLE public."InvoicesProductCombo" ADD COLUMN "comboId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'invoiceProductId') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "invoiceProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'orden') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "orden" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'origin') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "origin" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'destination') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "destination" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'class') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "class" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "checkInDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "checkOutDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'terminal') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "terminal" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'prestadoraCode') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "prestadoraCode" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'farebasis') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "farebasis" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'Numflight') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "Numflight" character varying(25);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'Typeflight') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "Typeflight" character varying(1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'amount') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "amount" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductItinerary' AND column_name = 'co2') THEN
        ALTER TABLE public."InvoicesProductItinerary" ADD COLUMN "co2" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductPasenger" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger' AND column_name = 'invoiceProductId') THEN
        ALTER TABLE public."InvoicesProductPasenger" ADD COLUMN "invoiceProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger' AND column_name = 'name') THEN
        ALTER TABLE public."InvoicesProductPasenger" ADD COLUMN "name" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPasenger' AND column_name = 'document') THEN
        ALTER TABLE public."InvoicesProductPasenger" ADD COLUMN "document" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'invoiceProductId') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "invoiceProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'amount') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'paymentMethod') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "paymentMethod" character varying(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'date') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'reference') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "reference" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'authorizationCode') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "authorizationCode" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'cardNumber') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "cardNumber" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'creditCardId') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "creditCardId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'expirationDate') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "expirationDate" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductPayment' AND column_name = 'voucher') THEN
        ALTER TABLE public."InvoicesProductPayment" ADD COLUMN "voucher" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'invoiceProductId') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "invoiceProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'chargeAndTaxId') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "chargeAndTaxId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'valueSnapshot') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "valueSnapshot" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'valueTypeSnapshot') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "valueTypeSnapshot" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'explicitAmount') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "explicitAmount" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductTax' AND column_name = 'isMain') THEN
        ALTER TABLE public."InvoicesProductTax" ADD COLUMN "isMain" boolean DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable' AND column_name = 'id') THEN
        ALTER TABLE public."InvoicesProductVariable" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable' AND column_name = 'invoiceProductId') THEN
        ALTER TABLE public."InvoicesProductVariable" ADD COLUMN "invoiceProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable' AND column_name = 'masterVariableId') THEN
        ALTER TABLE public."InvoicesProductVariable" ADD COLUMN "masterVariableId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'InvoicesProductVariable' AND column_name = 'value') THEN
        ALTER TABLE public."InvoicesProductVariable" ADD COLUMN "value" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Master' AND column_name = 'id') THEN
        ALTER TABLE public."Master" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Master' AND column_name = 'code') THEN
        ALTER TABLE public."Master" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Master' AND column_name = 'name') THEN
        ALTER TABLE public."Master" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Master' AND column_name = 'inactivo') THEN
        ALTER TABLE public."Master" ADD COLUMN "inactivo" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'id') THEN
        ALTER TABLE public."Payment" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'code') THEN
        ALTER TABLE public."Payment" ADD COLUMN "code" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'name') THEN
        ALTER TABLE public."Payment" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'inactive') THEN
        ALTER TABLE public."Payment" ADD COLUMN "inactive" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'iscash') THEN
        ALTER TABLE public."Payment" ADD COLUMN "iscash" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Payment' AND column_name = 'iscredit') THEN
        ALTER TABLE public."Payment" ADD COLUMN "iscredit" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Provider' AND column_name = 'id') THEN
        ALTER TABLE public."Provider" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Provider' AND column_name = 'code') THEN
        ALTER TABLE public."Provider" ADD COLUMN "code" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Provider' AND column_name = 'name') THEN
        ALTER TABLE public."Provider" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Provider' AND column_name = 'contactInfo') THEN
        ALTER TABLE public."Provider" ADD COLUMN "contactInfo" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Provider' AND column_name = 'commissionConfig') THEN
        ALTER TABLE public."Provider" ADD COLUMN "commissionConfig" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'id') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'internalNumber') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "internalNumber" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'date') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "date" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'clientId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "clientId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'currency') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "currency" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'exchangeRate') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "exchangeRate" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'branchId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "branchId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'implantId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'sellerId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "sellerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'ticketPrinterId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "ticketPrinterId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'baseCommissionable') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "baseCommissionable" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'commissionPercentage') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "commissionPercentage" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'chargesAndTaxes') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "chargesAndTaxes" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'totalAmount') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "totalAmount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'userId') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'state') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "state" character varying(25) DEFAULT 'Nuevo'::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'stateDescription') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "stateDescription" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'stateUpdatedAt') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "stateUpdatedAt" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'costoTotal') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "costoTotal" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'valorBase') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "valorBase" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'utilidad') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "utilidad" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionTotalPercentage') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionTotalPercentage" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionFreelancePercentage') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionFreelancePercentage" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionFreelanceValue') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionFreelanceValue" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionPropiaPercentage') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionPropiaPercentage" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionPropiaValue') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionPropiaValue" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'comisionUtilidadPercentage') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "comisionUtilidadPercentage" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'destination') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "destination" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'startDate') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "startDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'endDate') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "endDate" timestamp without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'passenger') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "passenger" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'paxAdults') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "paxAdults" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'paxChildren') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "paxChildren" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'reservationCode') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "reservationCode" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'copyFieldsToProducts') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "copyFieldsToProducts" boolean DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Quotation' AND column_name = 'manualDescription') THEN
        ALTER TABLE public."Quotation" ADD COLUMN "manualDescription" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationCombo' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationCombo" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationCombo' AND column_name = 'quotationId') THEN
        ALTER TABLE public."QuotationCombo" ADD COLUMN "quotationId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationCombo' AND column_name = 'comboId') THEN
        ALTER TABLE public."QuotationCombo" ADD COLUMN "comboId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'name') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'description') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "description" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'template') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "template" bytea;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'templateConfig') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "templateConfig" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'htmlTemplate') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "htmlTemplate" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'branchId') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'implantId') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'createdAt') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationFormat') THEN
        CREATE TABLE public."QuotationFormat" (
            id SERIAL PRIMARY KEY,
            "code" text NOT NULL DEFAULT '',
            "name" character varying(100) NOT NULL,
            "description" character varying(255),
            "template" bytea,
            "templateConfig" jsonb,
            "htmlTemplate" text,
            "branchId" integer,
            "implantId" integer,
            "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationFormat' AND column_name = 'updatedAt') THEN
        ALTER TABLE public."QuotationFormat" ADD COLUMN "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP;
    END IF;

    CREATE SEQUENCE IF NOT EXISTS public."QuotationManualService_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        CREATE TABLE public."QuotationManualService" (
            id SERIAL PRIMARY KEY,
            "quotationId" integer NOT NULL REFERENCES public."Quotation"(id) ON DELETE CASCADE,
            "providerName" character varying(255),
            "serviceName" character varying(255),
            "cost" double precision DEFAULT 0 NOT NULL,
            "salePrice" double precision DEFAULT 0 NOT NULL,
            "utility" double precision DEFAULT 0 NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
        );
    ELSE
        ALTER TABLE public."QuotationManualService" ALTER COLUMN id SET DEFAULT nextval('public."QuotationManualService_id_seq"'::regclass);
    END IF;
    ALTER SEQUENCE public."QuotationManualService_id_seq" OWNED BY public."QuotationManualService".id;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationPrintCustomization') THEN
        CREATE TABLE public."QuotationPrintCustomization" (
            id SERIAL PRIMARY KEY,
            "quotationId" integer NOT NULL UNIQUE REFERENCES public."Quotation"(id) ON DELETE CASCADE,
            "html" text NOT NULL,
            "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    ELSE
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationPrintCustomization_quotationId_key') AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'QuotationPrintCustomization_quotationId_key') THEN
            ALTER TABLE public."QuotationPrintCustomization" ADD CONSTRAINT "QuotationPrintCustomization_quotationId_key" UNIQUE ("quotationId");
        END IF;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationPrintDefaultTemplate') THEN
        CREATE TABLE public."QuotationPrintDefaultTemplate" (
            id SERIAL PRIMARY KEY,
            "html" text NOT NULL,
            "name" character varying(100) DEFAULT 'Default'::character varying,
            "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'quotationId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "quotationId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'productId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "productId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'quantity') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "quantity" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'price') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "price" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'cost') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "cost" double precision DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'providerId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "providerId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'prestadoraId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "prestadoraId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'checkInDate') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "checkInDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'checkOutDate') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "checkOutDate" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'nights') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "nights" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'paxAdults') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "paxAdults" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'paxChildren') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "paxChildren" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'serviceType') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "serviceType" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'destination') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "destination" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'reservationCode') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "reservationCode" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'sellerCommission') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "sellerCommission" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'ticketPrinterCommission') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "ticketPrinterCommission" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'comboId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "comboId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'mainTaxId') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "mainTaxId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'inNationality') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "inNationality" integer DEFAULT 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'service') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "service" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'description') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'servicios') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "servicios" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'descripcion') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "descripcion" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProduct' AND column_name = 'passenger') THEN
        ALTER TABLE public."QuotationProduct" ADD COLUMN "passenger" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPassenger' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationProductPassenger" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPassenger' AND column_name = 'quotationProductId') THEN
        ALTER TABLE public."QuotationProductPassenger" ADD COLUMN "quotationProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPassenger' AND column_name = 'name') THEN
        ALTER TABLE public."QuotationProductPassenger" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPassenger' AND column_name = 'document') THEN
        ALTER TABLE public."QuotationProductPassenger" ADD COLUMN "document" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'quotationProductId') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "quotationProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'amount') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "amount" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'paymentMethod') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "paymentMethod" character varying(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'date') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'reference') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "reference" character varying(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'creditCardId') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "creditCardId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'cardNumber') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "cardNumber" character varying(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'authorizationCode') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "authorizationCode" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'voucher') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "voucher" character varying(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductPayment' AND column_name = 'expirationDate') THEN
        ALTER TABLE public."QuotationProductPayment" ADD COLUMN "expirationDate" character varying(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'quotationProductId') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "quotationProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'chargeAndTaxId') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "chargeAndTaxId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'valueSnapshot') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "valueSnapshot" double precision NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'valueTypeSnapshot') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "valueTypeSnapshot" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'explicitAmount') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "explicitAmount" double precision;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductTax' AND column_name = 'isMain') THEN
        ALTER TABLE public."QuotationProductTax" ADD COLUMN "isMain" boolean DEFAULT false NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductVariable' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationProductVariable" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductVariable' AND column_name = 'quotationProductId') THEN
        ALTER TABLE public."QuotationProductVariable" ADD COLUMN "quotationProductId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductVariable' AND column_name = 'masterVariableId') THEN
        ALTER TABLE public."QuotationProductVariable" ADD COLUMN "masterVariableId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationProductVariable' AND column_name = 'value') THEN
        ALTER TABLE public."QuotationProductVariable" ADD COLUMN "value" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'code') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "code" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'name') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "name" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'color') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "color" character varying(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationState' AND column_name = 'createdAt') THEN
        ALTER TABLE public."QuotationState" ADD COLUMN "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'id') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'quotationId') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "quotationId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'state') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "state" character varying(25) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'description') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'createdAt') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'QuotationStateHistory' AND column_name = 'userId') THEN
        ALTER TABLE public."QuotationStateHistory" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'id') THEN
        ALTER TABLE public."Report" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'name') THEN
        ALTER TABLE public."Report" ADD COLUMN "name" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'base_table') THEN
        ALTER TABLE public."Report" ADD COLUMN "base_table" character varying(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'description') THEN
        ALTER TABLE public."Report" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'custom_sql') THEN
        ALTER TABLE public."Report" ADD COLUMN "custom_sql" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Report' AND column_name = 'created_at') THEN
        ALTER TABLE public."Report" ADD COLUMN "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'id') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'table_alias') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "table_alias" character varying(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'column_name') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "column_name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'alias') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "alias" character varying(150);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'is_calculated') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "is_calculated" boolean DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'is_visible') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "is_visible" boolean DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'formula_expression') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "formula_expression" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportColumns' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportColumns" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'id') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'table_alias') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "table_alias" character varying(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'column_name') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "column_name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'filter_label') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "filter_label" character varying(150);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'filter_type') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "filter_type" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'operator') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "operator" character varying(20) DEFAULT '='::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportFilters' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportFilters" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'id') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'table_name') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "table_name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'alias') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "alias" character varying(20) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'join_type') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "join_type" character varying(50) DEFAULT 'INNER JOIN'::character varying NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'join_condition') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "join_condition" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'id') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'column_expr') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "column_expr" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'direction') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "direction" character varying(10) DEFAULT 'ASC'::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Role' AND column_name = 'id') THEN
        ALTER TABLE public."Role" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Role' AND column_name = 'name') THEN
        ALTER TABLE public."Role" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'id') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'userId') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'action') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "action" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'module') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "module" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'description') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "description" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'metadata') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "metadata" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'createdAt') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'id') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'code') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "code" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'name') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "name" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'description') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'isActive') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "isActive" boolean DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'id') THEN
        ALTER TABLE public."User" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'name') THEN
        ALTER TABLE public."User" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'email') THEN
        ALTER TABLE public."User" ADD COLUMN "email" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'passwordHash') THEN
        ALTER TABLE public."User" ADD COLUMN "passwordHash" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordToken') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordToken" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordExpires') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordExpires" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'roleId') THEN
        ALTER TABLE public."User" ADD COLUMN "roleId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'branchId') THEN
        ALTER TABLE public."User" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'implantId') THEN
        ALTER TABLE public."User" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'ticketPrinterId') THEN
        ALTER TABLE public."User" ADD COLUMN "ticketPrinterId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'canEditReports') THEN
        ALTER TABLE public."User" ADD COLUMN "canEditReports" boolean DEFAULT false;
    END IF;

    -- Parámetro estándar por defecto para Producto de Reservas GDS
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE "code" = 'PRODUCTO_RESERVA_GDS') THEN
        INSERT INTO public."SystemParameter" ("code", "name", "value")
        VALUES ('PRODUCTO_RESERVA_GDS', 'Producto por Defecto para Reservas GDS', '');
    END IF;

    -- Columnas para Orden de visualización y Asignación por Producto en ChargeAndTax
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'orden') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "orden" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'productIds') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "productIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Columna para Asignación de Cargos e Impuestos por Producto en Product
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'taxIds') THEN
        ALTER TABLE public."Product" ADD COLUMN "taxIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Tabla de Parámetros/Reglas de Extracción de Interfaces (PNR/GDS)
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_id_seq') THEN
        CREATE SEQUENCE public."InterfaceExtractParam_id_seq" START WITH 1 INCREMENT BY 1;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InterfaceExtractParam') THEN
        CREATE TABLE public."InterfaceExtractParam" (
            "id" integer DEFAULT nextval('"InterfaceExtractParam_id_seq"'::regclass) NOT NULL,
            "interfaceId" integer NOT NULL,
            "fieldCode" character varying(50) NOT NULL,
            "fieldName" character varying(100) NOT NULL,
            "prefix" character varying(100) NOT NULL,
            "delimiter" character varying(20) DEFAULT '-'::character varying,
            "startPosition" integer DEFAULT 0,
            "length" integer DEFAULT 0,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT now(),
            CONSTRAINT "InterfaceExtractParam_pkey" PRIMARY KEY ("id")
        );
    END IF;

    -- Foreign Key de InterfaceExtractParam hacia Interfaces
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'InterfaceExtractParam_interfaceId_fkey') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_fkey" 
        FOREIGN KEY ("interfaceId") REFERENCES public."Interfaces"("id") ON DELETE CASCADE;
    END IF;

    -- Columna sellerId (Vendedor por Defecto) en Client
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'sellerId') THEN
        ALTER TABLE public."Client" ADD COLUMN "sellerId" integer;
    END IF;

    -- Foreign Key de Client.sellerId hacia Seller.id
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'Client_sellerId_fkey') THEN
        ALTER TABLE public."Client" 
        ADD CONSTRAINT "Client_sellerId_fkey" 
        FOREIGN KEY ("sellerId") REFERENCES public."Seller"("id") ON DELETE SET NULL;
    END IF;

    -- Limpieza de duplicados existentes por combinación de interfaceId y prefix
    DELETE FROM public."InterfaceExtractParam" a
    USING public."InterfaceExtractParam" b
    WHERE a.id > b.id 
      AND a."interfaceId" = b."interfaceId" 
      AND LOWER(TRIM(a.prefix)) = LOWER(TRIM(b.prefix));

    -- Restricción de Unicidad por combinación de Interfaz y Prefijo (interfaceId + prefix)
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InterfaceExtractParam_interfaceId_prefix_key') AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_interfaceId_prefix_key') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_prefix_key" 
        UNIQUE ("interfaceId", "prefix");
    END IF;

    -- Tabla DocumentResolution (Maestro de Resoluciones de Documentos)
    CREATE SEQUENCE IF NOT EXISTS public."DocumentResolution_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'DocumentResolution') THEN
        CREATE TABLE public."DocumentResolution" (
            "id" integer DEFAULT nextval('public."DocumentResolution_id_seq"'::regclass) NOT NULL PRIMARY KEY,
            "branchId" integer NOT NULL,
            "implantId" integer,
            "resolutionNumber" character varying(100) NOT NULL,
            "initialNumber" integer NOT NULL,
            "finalNumber" integer NOT NULL,
            "currentNumber" integer NOT NULL,
            "resolutionDate" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "prefix" character varying(20),
            "expirationDate" timestamp without time zone,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'table_name') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "table_name" character varying(100) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'alias') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "alias" character varying(20) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'join_type') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "join_type" character varying(50) DEFAULT 'INNER JOIN'::character varying NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'join_condition') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "join_condition" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportJoins' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportJoins" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'id') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'report_id') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "report_id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'column_expr') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "column_expr" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'direction') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "direction" character varying(10) DEFAULT 'ASC'::character varying;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ReportSorts' AND column_name = 'sort_order') THEN
        ALTER TABLE public."ReportSorts" ADD COLUMN "sort_order" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Role' AND column_name = 'id') THEN
        ALTER TABLE public."Role" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Role' AND column_name = 'name') THEN
        ALTER TABLE public."Role" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'id') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'userId') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "userId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'action') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "action" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'module') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "module" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'description') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "description" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'metadata') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "metadata" jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'SystemLog' AND column_name = 'createdAt') THEN
        ALTER TABLE public."SystemLog" ADD COLUMN "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'id') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'code') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "code" character varying(50) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'name') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "name" character varying(255) NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'description') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "description" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'TicketType' AND column_name = 'isActive') THEN
        ALTER TABLE public."TicketType" ADD COLUMN "isActive" boolean DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'id') THEN
        ALTER TABLE public."User" ADD COLUMN "id" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'name') THEN
        ALTER TABLE public."User" ADD COLUMN "name" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'email') THEN
        ALTER TABLE public."User" ADD COLUMN "email" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'passwordHash') THEN
        ALTER TABLE public."User" ADD COLUMN "passwordHash" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordToken') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordToken" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordExpires') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordExpires" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'roleId') THEN
        ALTER TABLE public."User" ADD COLUMN "roleId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'branchId') THEN
        ALTER TABLE public."User" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'implantId') THEN
        ALTER TABLE public."User" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'ticketPrinterId') THEN
        ALTER TABLE public."User" ADD COLUMN "ticketPrinterId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'canEditReports') THEN
        ALTER TABLE public."User" ADD COLUMN "canEditReports" boolean DEFAULT false;
    END IF;

    -- Parámetro estándar por defecto para Producto de Reservas GDS
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE "code" = 'PRODUCTO_RESERVA_GDS') THEN
        INSERT INTO public."SystemParameter" ("code", "name", "value")
        VALUES ('PRODUCTO_RESERVA_GDS', 'Producto por Defecto para Reservas GDS', '');
    END IF;

    -- Columnas para Orden de visualización y Asignación por Producto en ChargeAndTax
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'orden') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "orden" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'productIds') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "productIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Columna para Asignación de Cargos e Impuestos por Producto en Product
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'taxIds') THEN
        ALTER TABLE public."Product" ADD COLUMN "taxIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Tabla de Parámetros/Reglas de Extracción de Interfaces (PNR/GDS)
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_id_seq') THEN
        CREATE SEQUENCE public."InterfaceExtractParam_id_seq" START WITH 1 INCREMENT BY 1;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InterfaceExtractParam') THEN
        CREATE TABLE public."InterfaceExtractParam" (
            "id" integer DEFAULT nextval('"InterfaceExtractParam_id_seq"'::regclass) NOT NULL,
            "interfaceId" integer NOT NULL,
            "fieldCode" character varying(50) NOT NULL,
            "fieldName" character varying(100) NOT NULL,
            "prefix" character varying(100) NOT NULL,
            "delimiter" character varying(20) DEFAULT '-'::character varying,
            "startPosition" integer DEFAULT 0,
            "length" integer DEFAULT 0,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT now(),
            CONSTRAINT "InterfaceExtractParam_pkey" PRIMARY KEY ("id")
        );
    END IF;

    -- Foreign Key de InterfaceExtractParam hacia Interfaces
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'InterfaceExtractParam_interfaceId_fkey') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_fkey" 
        FOREIGN KEY ("interfaceId") REFERENCES public."Interfaces"("id") ON DELETE CASCADE;
    END IF;

    -- Columna sellerId (Vendedor por Defecto) en Client
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'sellerId') THEN
        ALTER TABLE public."Client" ADD COLUMN "sellerId" integer;
    END IF;

    -- Foreign Key de Client.sellerId hacia Seller.id
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'Client_sellerId_fkey') THEN
        ALTER TABLE public."Client" 
        ADD CONSTRAINT "Client_sellerId_fkey" 
        FOREIGN KEY ("sellerId") REFERENCES public."Seller"("id") ON DELETE SET NULL;
    END IF;

    -- Limpieza de duplicados existentes por combinación de interfaceId y prefix
    DELETE FROM public."InterfaceExtractParam" a
    USING public."InterfaceExtractParam" b
    WHERE a.id > b.id 
      AND a."interfaceId" = b."interfaceId" 
      AND LOWER(TRIM(a.prefix)) = LOWER(TRIM(b.prefix));

    -- Restricción de Unicidad por combinación de Interfaz y Prefijo (interfaceId + prefix)
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InterfaceExtractParam_interfaceId_prefix_key') AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_interfaceId_prefix_key') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_prefix_key" 
        UNIQUE ("interfaceId", "prefix");
    END IF;

    -- Tabla DocumentResolution (Maestro de Resoluciones de Documentos)
    CREATE SEQUENCE IF NOT EXISTS public."DocumentResolution_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'DocumentResolution') THEN
        CREATE TABLE public."DocumentResolution" (
            "id" integer DEFAULT nextval('public."DocumentResolution_id_seq"'::regclass) NOT NULL PRIMARY KEY,
            "branchId" integer NOT NULL,
            "implantId" integer,
            "resolutionNumber" character varying(100) NOT NULL,
            "initialNumber" integer NOT NULL,
            "finalNumber" integer NOT NULL,
            "currentNumber" integer NOT NULL,
            "resolutionDate" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "prefix" character varying(20),
            "expirationDate" timestamp without time zone NOT NULL,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'DocumentResolution_branchId_fkey') THEN
        ALTER TABLE public."DocumentResolution" 
        ADD CONSTRAINT "DocumentResolution_branchId_fkey" 
        FOREIGN KEY ("branchId") REFERENCES public."Branch"("id") ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'DocumentResolution_implantId_fkey') THEN
        ALTER TABLE public."DocumentResolution" 
        ADD CONSTRAINT "DocumentResolution_implantId_fkey" 
        FOREIGN KEY ("implantId") REFERENCES public."Implant"("id") ON DELETE SET NULL;
    END IF;

    -- Tabla TransactionConsecutive (Maestro de Consecutivos de Transacciones)
    CREATE SEQUENCE IF NOT EXISTS public."TransactionConsecutive_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TransactionConsecutive') THEN
        CREATE TABLE public."TransactionConsecutive" (
            "id" integer DEFAULT nextval('public."TransactionConsecutive_id_seq"'::regclass) NOT NULL PRIMARY KEY,
            "transactionType" character varying(50) NOT NULL,
            "description" character varying(150) NOT NULL,
            "prefix" character varying(20),
            "initialNumber" integer,
            "currentNumber" integer NOT NULL,
            "branchId" integer,
            "implantId" integer,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'TransactionConsecutive_branchId_fkey') THEN
        ALTER TABLE public."TransactionConsecutive" 
        ADD CONSTRAINT "TransactionConsecutive_branchId_fkey" 
        FOREIGN KEY ("branchId") REFERENCES public."Branch"("id") ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'TransactionConsecutive_implantId_fkey') THEN
        ALTER TABLE public."TransactionConsecutive" 
        ADD CONSTRAINT "TransactionConsecutive_implantId_fkey" 
        FOREIGN KEY ("implantId") REFERENCES public."Implant"("id") ON DELETE SET NULL;
    END IF;

    -- Columnas resolutionId e invoiceTemplate para Branch e Implant
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'resolutionId') THEN
        ALTER TABLE public."Branch" ADD COLUMN "resolutionId" INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceTemplate') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceTemplate" BYTEA;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceTemplateConfig') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceTemplateConfig" JSONB;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceHtmlTemplate') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceHtmlTemplate" TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'resolutionId') THEN
        ALTER TABLE public."Implant" ADD COLUMN "resolutionId" INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceTemplate') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceTemplate" BYTEA;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceTemplateConfig') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceTemplateConfig" JSONB;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceHtmlTemplate') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceHtmlTemplate" TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'SysConsecutivo') THEN
        CREATE TABLE public."SysConsecutivo" (
            "id" SERIAL PRIMARY KEY,
            "codigo" VARCHAR(50) NOT NULL,
            "nombre" VARCHAR(255) NOT NULL,
            "branchId" INT REFERENCES public."Branch"(id) ON DELETE SET NULL,
            "implantId" INT REFERENCES public."Implant"(id) ON DELETE SET NULL,
            "fuente" VARCHAR(50),
            "serie" VARCHAR(50),
            "consecutivo" BIGINT NOT NULL DEFAULT 0,
            "createdAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX "idx_sysconsecutivo_codigo" ON public."SysConsecutivo"("codigo");
        CREATE INDEX "idx_sysconsecutivo_branch" ON public."SysConsecutivo"("branchId");
        CREATE INDEX "idx_sysconsecutivo_implant" ON public."SysConsecutivo"("implantId");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'passwordHash') THEN
        ALTER TABLE public."User" ADD COLUMN "passwordHash" text NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordToken') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordToken" text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'resetPasswordExpires') THEN
        ALTER TABLE public."User" ADD COLUMN "resetPasswordExpires" timestamp(3) without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'roleId') THEN
        ALTER TABLE public."User" ADD COLUMN "roleId" integer NOT NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'branchId') THEN
        ALTER TABLE public."User" ADD COLUMN "branchId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'implantId') THEN
        ALTER TABLE public."User" ADD COLUMN "implantId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'ticketPrinterId') THEN
        ALTER TABLE public."User" ADD COLUMN "ticketPrinterId" integer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'User' AND column_name = 'canEditReports') THEN
        ALTER TABLE public."User" ADD COLUMN "canEditReports" boolean DEFAULT false;
    END IF;

    -- Parámetro estándar por defecto para Producto de Reservas GDS
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE "code" = 'PRODUCTO_RESERVA_GDS') THEN
        INSERT INTO public."SystemParameter" ("code", "name", "value")
        VALUES ('PRODUCTO_RESERVA_GDS', 'Producto por Defecto para Reservas GDS', '');
    END IF;

    -- Columnas para Orden de visualización y Asignación por Producto en ChargeAndTax
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'orden') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "orden" integer DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'ChargeAndTax' AND column_name = 'productIds') THEN
        ALTER TABLE public."ChargeAndTax" ADD COLUMN "productIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Columna para Asignación de Cargos e Impuestos por Producto en Product
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Product' AND column_name = 'taxIds') THEN
        ALTER TABLE public."Product" ADD COLUMN "taxIds" jsonb DEFAULT '[]'::jsonb;
    END IF;

    -- Tabla de Parámetros/Reglas de Extracción de Interfaces (PNR/GDS)
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_id_seq') THEN
        CREATE SEQUENCE public."InterfaceExtractParam_id_seq" START WITH 1 INCREMENT BY 1;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'InterfaceExtractParam') THEN
        CREATE TABLE public."InterfaceExtractParam" (
            "id" integer DEFAULT nextval('"InterfaceExtractParam_id_seq"'::regclass) NOT NULL,
            "interfaceId" integer NOT NULL,
            "fieldCode" character varying(50) NOT NULL,
            "fieldName" character varying(100) NOT NULL,
            "prefix" character varying(100) NOT NULL,
            "delimiter" character varying(20) DEFAULT '-'::character varying,
            "startPosition" integer DEFAULT 0,
            "length" integer DEFAULT 0,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT now(),
            CONSTRAINT "InterfaceExtractParam_pkey" PRIMARY KEY ("id")
        );
    END IF;

    -- Foreign Key de InterfaceExtractParam hacia Interfaces
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'InterfaceExtractParam_interfaceId_fkey') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_fkey" 
        FOREIGN KEY ("interfaceId") REFERENCES public."Interfaces"("id") ON DELETE CASCADE;
    END IF;

    -- Columna sellerId (Vendedor por Defecto) en Client
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Client' AND column_name = 'sellerId') THEN
        ALTER TABLE public."Client" ADD COLUMN "sellerId" integer;
    END IF;

    -- Foreign Key de Client.sellerId hacia Seller.id
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'Client_sellerId_fkey') THEN
        ALTER TABLE public."Client" 
        ADD CONSTRAINT "Client_sellerId_fkey" 
        FOREIGN KEY ("sellerId") REFERENCES public."Seller"("id") ON DELETE SET NULL;
    END IF;

    -- Limpieza de duplicados existentes por combinación de interfaceId y prefix
    DELETE FROM public."InterfaceExtractParam" a
    USING public."InterfaceExtractParam" b
    WHERE a.id > b.id 
      AND a."interfaceId" = b."interfaceId" 
      AND LOWER(TRIM(a.prefix)) = LOWER(TRIM(b.prefix));

    -- Restricción de Unicidad por combinación de Interfaz y Prefijo (interfaceId + prefix)
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InterfaceExtractParam_interfaceId_prefix_key') AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'InterfaceExtractParam_interfaceId_prefix_key') THEN
        ALTER TABLE public."InterfaceExtractParam" 
        ADD CONSTRAINT "InterfaceExtractParam_interfaceId_prefix_key" 
        UNIQUE ("interfaceId", "prefix");
    END IF;

    -- Tabla DocumentResolution (Maestro de Resoluciones de Documentos)
    CREATE SEQUENCE IF NOT EXISTS public."DocumentResolution_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'DocumentResolution') THEN
        CREATE TABLE public."DocumentResolution" (
            "id" integer DEFAULT nextval('public."DocumentResolution_id_seq"'::regclass) NOT NULL PRIMARY KEY,
            "branchId" integer NOT NULL,
            "implantId" integer,
            "resolutionNumber" character varying(100) NOT NULL,
            "initialNumber" integer NOT NULL,
            "finalNumber" integer NOT NULL,
            "currentNumber" integer NOT NULL,
            "resolutionDate" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
            "prefix" character varying(20),
            "expirationDate" timestamp without time zone NOT NULL,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'DocumentResolution_branchId_fkey') THEN
        ALTER TABLE public."DocumentResolution" 
        ADD CONSTRAINT "DocumentResolution_branchId_fkey" 
        FOREIGN KEY ("branchId") REFERENCES public."Branch"("id") ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'DocumentResolution_implantId_fkey') THEN
        ALTER TABLE public."DocumentResolution" 
        ADD CONSTRAINT "DocumentResolution_implantId_fkey" 
        FOREIGN KEY ("implantId") REFERENCES public."Implant"("id") ON DELETE SET NULL;
    END IF;

    -- Tabla TransactionConsecutive (Maestro de Consecutivos de Transacciones)
    CREATE SEQUENCE IF NOT EXISTS public."TransactionConsecutive_id_seq";
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'TransactionConsecutive') THEN
        CREATE TABLE public."TransactionConsecutive" (
            "id" integer DEFAULT nextval('public."TransactionConsecutive_id_seq"'::regclass) NOT NULL PRIMARY KEY,
            "transactionType" character varying(50) NOT NULL,
            "description" character varying(150) NOT NULL,
            "prefix" character varying(20),
            "initialNumber" integer,
            "currentNumber" integer NOT NULL,
            "branchId" integer,
            "implantId" integer,
            "isActive" boolean DEFAULT true NOT NULL,
            "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'TransactionConsecutive_branchId_fkey') THEN
        ALTER TABLE public."TransactionConsecutive" 
        ADD CONSTRAINT "TransactionConsecutive_branchId_fkey" 
        FOREIGN KEY ("branchId") REFERENCES public."Branch"("id") ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'TransactionConsecutive_implantId_fkey') THEN
        ALTER TABLE public."TransactionConsecutive" 
        ADD CONSTRAINT "TransactionConsecutive_implantId_fkey" 
        FOREIGN KEY ("implantId") REFERENCES public."Implant"("id") ON DELETE SET NULL;
    END IF;

    -- Columnas resolutionId e invoiceTemplate para Branch e Implant
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'resolutionId') THEN
        ALTER TABLE public."Branch" ADD COLUMN "resolutionId" INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceTemplate') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceTemplate" BYTEA;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceTemplateConfig') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceTemplateConfig" JSONB;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Branch' AND column_name = 'invoiceHtmlTemplate') THEN
        ALTER TABLE public."Branch" ADD COLUMN "invoiceHtmlTemplate" TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'resolutionId') THEN
        ALTER TABLE public."Implant" ADD COLUMN "resolutionId" INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceTemplate') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceTemplate" BYTEA;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceTemplateConfig') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceTemplateConfig" JSONB;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Implant' AND column_name = 'invoiceHtmlTemplate') THEN
        ALTER TABLE public."Implant" ADD COLUMN "invoiceHtmlTemplate" TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'SysConsecutivo') THEN
        CREATE TABLE public."SysConsecutivo" (
            "id" SERIAL PRIMARY KEY,
            "codigo" VARCHAR(50) NOT NULL,
            "nombre" VARCHAR(255) NOT NULL,
            "branchId" INT REFERENCES public."Branch"(id) ON DELETE SET NULL,
            "implantId" INT REFERENCES public."Implant"(id) ON DELETE SET NULL,
            "fuente" VARCHAR(50),
            "serie" VARCHAR(50),
            "consecutivo" BIGINT NOT NULL DEFAULT 0,
            "createdAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "updatedAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX "idx_sysconsecutivo_codigo" ON public."SysConsecutivo"("codigo");
        CREATE INDEX "idx_sysconsecutivo_branch" ON public."SysConsecutivo"("branchId");
        CREATE INDEX "idx_sysconsecutivo_implant" ON public."SysConsecutivo"("implantId");
    END IF;
END $$;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('MANUAL', 'Manual Operativo', '/dashboard/manual', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Equivalences', 'equivalencias', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Diagnostics', 'diagnostico', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('LICENSE_KEY', 'Clave de Licencia del Sistema', '') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', '') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PuertoSQLServer', 'Puerto SQL Server', '') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('EnviarCotizacionesAutoSQLserver', 'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', '1') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('EnviarFacturacionAutoSQLserver', 'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', '1') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('Pais', 'Pais', 'Colombia') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('MOSTRAR_TOTALIZACION_COTIZACION', 'Mostrar totalización financiera en cotización', 'true') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('ServidorSQLServer', 'Host de SQL Server', 'ZEUSAGENCIAS10') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('UsuarioSQLServer', 'Usuario SQL Server', 'zeusagencias') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('ClaveSQLServer', 'Contraseña SQL Server', 'zzeusagencias') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('BaseSQLServer', 'Base de Datos SQL Server', 'Zeusagencias_23') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('AGENCY_NAME', 'Nombre o Razón Social de la Agencia', 'KOREX AGENCIA PRUEBA') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('AGENCY_NIT', 'NIT de la Agencia', '79898456') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TASA_CAMBIO_IATA', 'Tasa de Cambio IATA', '4200.00') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_OW', 'Tarifa Administrativa Nacional One Way', '29100') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_RT', 'Tarifa Administrativa Nacional Roundtrip', '52800') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PRODUCTO_TARIFA_ADMINISTRATIVA', 'Producto por Defecto para Tarifa Administrativa', '77') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_INT_RANGES', 'Rangos Tarifa Administrativa Internacional (JSON)', '[{"min":0,"max":354,"feeUsd":15,"label":"Menores o iguales a USD 354"},{"min":354.01,"max":590,"feeUsd":28,"label":"Mayores de USD 354 hasta USD 590"},{"min":590.01,"max":944,"feeUsd":46,"label":"Mayores de USD 590 hasta USD 944"},{"min":944.01,"max":999999,"feeUsd":95,"label":"Mayores de USD 944"}]') ON CONFLICT (code) DO NOTHING;

-- Columna isActive en todas las tablas maestras del sistema
DO $$
DECLARE
    tbl TEXT;
    tables TEXT[] := ARRAY[
        'ChargeAndTax', 'Client', 'User', 'Branch', 'Implant', 'Provider', 'Prestadora',
        'Seller', 'Product', 'Airports', 'Airport', 'Cities', 'City', 'Countries', 'Country', 'CreditCard',
        'Currency', 'MasterVariable', 'ProviderType', 'Combo', 'EquivalencesInterfaces', 'Equivalences',
        'TicketType', 'TicketPrinter', 'Payment', 'DocumentResolution', 'Resolution', 'TransactionConsecutive', 'SysConsecutivo',
        'QuotationState', 'QuotationFormat', 'InterfaceExtractParam', 'Role'
    ];
BEGIN
    FOREACH tbl IN ARRAY tables LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = tbl) THEN
            IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = tbl AND column_name = 'isActive') THEN
                EXECUTE 'ALTER TABLE public."' || tbl || '" ADD COLUMN "isActive" boolean DEFAULT true NOT NULL;';
            END IF;
        END IF;
    END LOOP;
END $$;

UPDATE public."Currency" 
SET "isActive" = CASE 
    WHEN UPPER(TRIM(code)) IN ('COP', 'USD', 'EUR') THEN true 
    ELSE false 
END;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('DASHBOARD', 'Dashboard', '/dashboard', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('PRECOTIZACIONES', 'Pre-Cotizaciones', '/dashboard/prequotations', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('COTIZACIONES', 'Cotizaciones', '/dashboard/quotations/history', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('FACTURACION', 'Facturación', '/dashboard/invoices/history', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('MAESTROS', 'Maestros', '/dashboard/settings', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('REPORTES', 'Reportes', '/dashboard/reports', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

INSERT INTO public."Menu" (code, name, action, activo) VALUES ('EJECUCIONES', 'Ejecuciones', '/dashboard/executions', true) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, action = EXCLUDED.action;

-- Siembra obligatoria de Rol SUPERADMINISTRADOR y asignación a ebarrera@zagencias.com
DO $$
DECLARE
    v_super_role_id INT;
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Role') THEN
        IF NOT EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%') THEN
            INSERT INTO public."Role" (name, description, permissions, "isActive")
            VALUES ('SUPERADMINISTRADOR', 'Super Administrador con control total del sistema y gestión de módulos del sitio', '{"all": true, "superadmin": true}'::json, true);
        END IF;

        SELECT id INTO v_super_role_id FROM public."Role" WHERE UPPER(name) LIKE '%SUPERADMIN%' LIMIT 1;

        IF v_super_role_id IS NOT NULL AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'User') THEN
            UPDATE public."User"
            SET "roleId" = v_super_role_id
            WHERE email = 'ebarrera@zagencias.com';
        END IF;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "Payment_code_key" ON public."Payment"(code);
INSERT INTO public."Payment" (code, name, "isActive") VALUES ('CONTADO', 'Contado', true) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Payment" (code, name, "isActive") VALUES ('CREDITO', 'Crédito', true) ON CONFLICT (code) DO NOTHING;
SELECT setval('public."Payment_id_seq"', COALESCE((SELECT MAX(id) FROM public."Payment"), 1));
