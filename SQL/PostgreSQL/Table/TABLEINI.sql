do $$
BEGIN

    CREATE TABLE IF NOT EXISTS public."Branch" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        logo bytea,
        template bytea,
        "templateConfig" jsonb,
        "htmlTemplate" text
    );
    CREATE TABLE IF NOT EXISTS public."Client" (
        id integer NOT NULL,
        name text NOT NULL,
        document text NOT NULL,
        "contactInfo" text,
        address text,
        "mandatoryVariables" jsonb
    );
    CREATE TABLE IF NOT EXISTS public."Implant" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        "branchId" integer,
        logo bytea,
        template bytea,
        "templateConfig" jsonb,
        "htmlTemplate" text,
        "Logo" bytea
    );
    CREATE TABLE IF NOT EXISTS public."ChargeAndTax" (
        id integer NOT NULL,
        name text NOT NULL,
        type text NOT NULL,
        "valueType" text NOT NULL,
        value double precision NOT NULL,
        "isEditable" boolean DEFAULT true NOT NULL,
        code text
    );
    CREATE TABLE IF NOT EXISTS public."Menu" (
        id integer NOT NULL,
        code character varying(100) NOT NULL,
        name character varying(255) NOT NULL,
        parent integer,
        action character varying(500) NOT NULL,
        activo boolean DEFAULT true
    );
    CREATE TABLE IF NOT EXISTS public."SystemParameter" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        value text NOT NULL
    );
    CREATE TABLE IF NOT EXISTS public."Product" (
        id integer NOT NULL,
        type text NOT NULL,
        description text NOT NULL,
        "basePrice" double precision NOT NULL,
        cost double precision DEFAULT 0,
        "billingConcept" text,
        "serviceType" text,
        code text,
        "airlineItinerary" text,
        "classItinerary" text,
        "flightItinerary" text,
        "ticketTypeId" integer,
        "mandatoryFields" jsonb
    );
    CREATE TABLE IF NOT EXISTS public."Seller" (
        id integer NOT NULL,
        code text,
        name text NOT NULL,
        email text
    );
    CREATE TABLE IF NOT EXISTS public."TicketPrinter" (
        id integer NOT NULL,
        code text,
        name text NOT NULL,
        email text
    );
    CREATE TABLE IF NOT EXISTS public."MasterVariable" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL
    );
    CREATE TABLE IF NOT EXISTS public."Airports" (
        id integer NOT NULL,
        code character varying(10) NOT NULL,
        name character varying(150) NOT NULL,
        "citiesId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."Airports_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Airports_id_seq" OWNED BY public."Airports".id;
    CREATE TABLE IF NOT EXISTS public."Attachment" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        "fileName" text NOT NULL,
        "fileType" text NOT NULL,
        "fileSize" integer NOT NULL,
        "fileContent" bytea NOT NULL,
        "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."Attachment_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Attachment_id_seq" OWNED BY public."Attachment".id;
    CREATE TABLE IF NOT EXISTS public."BookingGDS" (
        id integer NOT NULL,
        code character varying(25) NOT NULL,
        type character varying(25) NOT NULL,
        blanch character varying(25) NOT NULL,
        implant character varying(25),
        external boolean DEFAULT false NOT NULL,
        gds integer,
        date timestamp without time zone DEFAULT now(),
        currency text NOT NULL,
        "exchangeRate" double precision NOT NULL,
        "tiquetPrinter" character varying(25) NOT NULL,
        seller character varying(25) NOT NULL,
        client character varying(25) NOT NULL,
        booking text,
        typetransaction character varying(25),
        iata character varying(25),
        description text,
        observation text,
        state character varying(25)
    );
    CREATE TABLE IF NOT EXISTS public."BookingGDSInvoiceAutoLog" (
        "Id" integer NOT NULL,
        "branchId" integer,
        "implanteId" integer,
        date timestamp without time zone,
        menssage text,
        "bookingCode" character varying(25),
        "bookingId" integer,
        error boolean,
        file text,
        "userId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingGDSInvoiceAutoLog_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingGDSInvoiceAutoLog_id_seq" OWNED BY public."BookingGDSInvoiceAutoLog"."Id";
    CREATE SEQUENCE IF NOT EXISTS public."BookingGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingGDS_id_seq" OWNED BY public."BookingGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductFEEGDS" (
        id integer NOT NULL,
        "bookingProductId" integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        type text NOT NULL,
        description text NOT NULL,
        billigconcept text NOT NULL,
        servicetype text NOT NULL,
        amount double precision NOT NULL,
        tax double precision NOT NULL,
        other double precision NOT NULL,
        total double precision NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductFEEGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductFEEGDS_id_seq" OWNED BY public."BookingProductFEEGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductGDS" (
        id integer NOT NULL,
        "bookingId" integer NOT NULL,
        code character varying(25) NOT NULL,
        type character varying(25),
        service text,
        description text,
        prestadoracode character varying(25),
        prestadorainitials character varying(25),
        prestadoradist character varying(25),
        provider character varying(25),
        quantity integer NOT NULL,
        price double precision NOT NULL,
        cost double precision DEFAULT 0,
        "checkInDate" timestamp(3) without time zone,
        "checkOutDate" timestamp(3) without time zone,
        nights integer,
        "paxAdults" integer,
        "paxChildren" integer,
        "serviceType" text,
        "billingConcept" text,
        destination text,
        "reservationCode" text,
        "sellerCom" double precision,
        "ticketPrinterCom" double precision,
        "inNationality" integer DEFAULT 1,
        state character varying(25) DEFAULT 'NUEVO'::character varying,
        conjunction integer DEFAULT 0,
        revised character varying(25),
        typeproduct character varying(25),
        consecutive character varying(25),
        penalty character varying(25)
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductGDS_id_seq" OWNED BY public."BookingProductGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductItineraryGDS" (
        id integer NOT NULL,
        "bookingProductId" integer NOT NULL,
        orden integer,
        origin text NOT NULL,
        destination text NOT NULL,
        class text NOT NULL,
        "checkInDate" timestamp(3) without time zone,
        "checkOutDate" timestamp(3) without time zone,
        terminal text NOT NULL,
        "prestadoraCode" text NOT NULL,
        farebasis text NOT NULL,
        "Numflight" character varying(25),
        "Typeflight" character varying(1),
        amount double precision NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductItineraryGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductItineraryGDS_id_seq" OWNED BY public."BookingProductItineraryGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductPassangerGDS" (
        id integer NOT NULL,
        "bookingProductId" integer NOT NULL,
        code character varying(25),
        firstnm character varying(30),
        lastnm character varying(30),
        prefix character varying(25),
        identification character varying(25),
        phone character varying(25),
        email character varying(250)
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductPassangerGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductPassangerGDS_id_seq" OWNED BY public."BookingProductPassangerGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductPaymentGDS" (
        id integer NOT NULL,
        "bookingProductId" integer,
        "bookingProductFEEId" integer,
        code character varying(50) NOT NULL,
        name character varying(50) NOT NULL,
        type character varying(50) NOT NULL,
        typecreditcard character varying(25),
        numbercreditcard character varying(16),
        vouchercreditcard character varying(25),
        expiredcreditcard character varying(5),
        authcreditcard character varying(25),
        quotas integer,
        bank character varying(25),
        square character varying(30),
        reference character varying(50),
        policy character varying(25),
        policyannex character varying(25),
        amount double precision NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductPaymentGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductPaymentGDS_id_seq" OWNED BY public."BookingProductPaymentGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductTaxGDS" (
        id integer NOT NULL,
        "bookingProductId" integer NOT NULL,
        code character varying(25) NOT NULL,
        name character varying(50) NOT NULL,
        type character varying(25) NOT NULL,
        ismain boolean DEFAULT false,
        percentage double precision NOT NULL,
        amount double precision NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductTaxGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductTaxGDS_id_seq" OWNED BY public."BookingProductTaxGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingProductVariableGDS" (
        id integer NOT NULL,
        "bookingProductId" integer NOT NULL,
        code text,
        name text,
        value text
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingProductVariableGDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingProductVariableGDS_id_seq" OWNED BY public."BookingProductVariableGDS".id;
    CREATE TABLE IF NOT EXISTS public."BookingsGDSInvoiceAuto" (
        id integer NOT NULL,
        "Branch" character varying(25),
        implant character varying(25),
        "bookingCode" character varying(25),
        "bookingId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingsGDSInvoiceAuto_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingsGDSInvoiceAuto_id_seq" OWNED BY public."BookingsGDSInvoiceAuto".id;
    CREATE TABLE IF NOT EXISTS public."BookingsGDS_log" (
        id integer NOT NULL,
        blanch character varying(25),
        implant character varying(25),
        message text,
        file character varying(250),
        codebooking character varying(50),
        booking text,
        error integer DEFAULT 0 NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."BookingsGDS_log_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BookingsGDS_log_id_seq" OWNED BY public."BookingsGDS_log".id;
    CREATE TABLE IF NOT EXISTS public."BranchGDSInvoiceAuto" (
        id integer NOT NULL,
        "branchId" integer NOT NULL,
        "gdsId" integer NOT NULL,
        "EnvoiceAuto" boolean DEFAULT false
    );
    CREATE SEQUENCE IF NOT EXISTS public."BranchGDSInvoiceAuto_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BranchGDSInvoiceAuto_id_seq" OWNED BY public."BranchGDSInvoiceAuto".id;
    CREATE SEQUENCE IF NOT EXISTS public."Branch_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Branch_id_seq" OWNED BY public."Branch".id;
    CREATE TABLE IF NOT EXISTS public."CellCustomization" (
        id integer NOT NULL,
        code character varying(50) NOT NULL,
        name character varying(100) NOT NULL,
        value character varying(10),
        "branchId" integer,
        "implantId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."CellCustomization_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."CellCustomization_id_seq" OWNED BY public."CellCustomization".id;
    CREATE SEQUENCE IF NOT EXISTS public."ChargeAndTax_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."ChargeAndTax_id_seq" OWNED BY public."ChargeAndTax".id;
    CREATE TABLE IF NOT EXISTS public."Cities" (
        id integer NOT NULL,
        code character varying(10) NOT NULL,
        name character varying(100) NOT NULL,
        "countriesId" integer,
        statecode character varying(25),
        iata character varying(10)
    );
    CREATE SEQUENCE IF NOT EXISTS public."Cities_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Cities_id_seq" OWNED BY public."Cities".id;
    CREATE SEQUENCE IF NOT EXISTS public."Client_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Client_id_seq" OWNED BY public."Client".id;
    CREATE TABLE IF NOT EXISTS public."Combo" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        cupos integer DEFAULT 0,
        "currencyId" integer,
        "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "updatedAt" timestamp without time zone DEFAULT now()
    );
    CREATE TABLE IF NOT EXISTS public."ComboProduct" (
        id integer NOT NULL,
        "comboId" integer NOT NULL,
        "productId" integer NOT NULL,
        price double precision NOT NULL,
        cost double precision DEFAULT 0,
        "checkInDate" timestamp(3) without time zone,
        "checkOutDate" timestamp(3) without time zone,
        "prestadoraId" integer,
        "mainTaxId" integer,
        "paxAdults" integer,
        "paxChildren" integer,
        "providerId" integer,
        "inNationality" integer DEFAULT 1,
        quantity integer DEFAULT 1 NOT NULL
    );
    CREATE TABLE IF NOT EXISTS public."ComboProductTax" (
        id integer NOT NULL,
        "comboProductId" integer NOT NULL,
        "chargeAndTaxId" integer NOT NULL,
        amount double precision NOT NULL,
        "isMain" boolean DEFAULT false NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."ComboProductTax_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."ComboProductTax_id_seq" OWNED BY public."ComboProductTax".id;
    CREATE SEQUENCE IF NOT EXISTS public."ComboProduct_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."ComboProduct_id_seq" OWNED BY public."ComboProduct".id;
    CREATE SEQUENCE IF NOT EXISTS public."Combo_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Combo_id_seq" OWNED BY public."Combo".id;
    CREATE TABLE IF NOT EXISTS public."Countries" (
        id integer NOT NULL,
        code character varying(10) NOT NULL,
        name character varying(100) NOT NULL,
        dane character varying(25),
        region character varying(50),
        prefix character varying(10),
        "curencyId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."Countries_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Countries_id_seq" OWNED BY public."Countries".id;
    CREATE TABLE IF NOT EXISTS public."CreditCard" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        type text NOT NULL,
        inactive boolean DEFAULT false NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."CreditCard_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."CreditCard_id_seq" OWNED BY public."CreditCard".id;
    CREATE TABLE IF NOT EXISTS public."Currency" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        "exchangeRate" double precision NOT NULL,
        decimals integer DEFAULT 2 NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."Currency_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Currency_id_seq" OWNED BY public."Currency".id;
    CREATE TABLE IF NOT EXISTS public."EquivalencesInterfaces" (
        id integer NOT NULL,
        id_interfaces integer NOT NULL,
        id_master integer NOT NULL,
        cd_maestro text NOT NULL,
        cd_codigo text NOT NULL,
        cd_codigointe text NOT NULL,
        dt_fecha timestamp without time zone DEFAULT now()
    );
    CREATE SEQUENCE IF NOT EXISTS public."EquivalencesInterfaces_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."EquivalencesInterfaces_id_seq" OWNED BY public."EquivalencesInterfaces".id;
    CREATE TABLE IF NOT EXISTS public."EquivalenciasInterfaces_Log" (
        id integer NOT NULL,
        "Id_Interfaces" integer,
        cd_maestro character varying(50),
        cd_codigo character varying(50),
        "cd_codigoInte" character varying(50),
        cd_operacion character varying(50),
        ds_xmlpeticion text,
        ds_xmlrespuesta text,
        ds_xmlorg text,
        "ds_Logpeticion" text,
        fecha_creacion timestamp(6) without time zone DEFAULT now()
    );
    CREATE SEQUENCE IF NOT EXISTS public."EquivalenciasInterfaces_Log_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."EquivalenciasInterfaces_Log_id_seq" OWNED BY public."EquivalenciasInterfaces_Log".id;
    CREATE TABLE IF NOT EXISTS public."FormatCellCustomization" (
        id integer NOT NULL,
        "formatId" integer NOT NULL,
        code character varying(50) NOT NULL,
        name character varying(100) NOT NULL,
        value character varying(10)
    );
    CREATE SEQUENCE IF NOT EXISTS public."FormatCellCustomization_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."FormatCellCustomization_id_seq" OWNED BY public."FormatCellCustomization".id;
    CREATE TABLE IF NOT EXISTS public."GDS" (
        id integer NOT NULL,
        name text NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."GDS_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."GDS_id_seq" OWNED BY public."GDS".id;
    CREATE TABLE IF NOT EXISTS public."Prestadora" (
        id integer NOT NULL,
        name text NOT NULL,
        location text,
        category text,
        "providerId" integer,
        code text,
        type text,
        initials text,
        nogds text
    );
    CREATE SEQUENCE IF NOT EXISTS public."Hotel_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Hotel_id_seq" OWNED BY public."Prestadora".id;
    CREATE SEQUENCE IF NOT EXISTS public."Implant_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Implant_id_seq" OWNED BY public."Implant".id;
    CREATE TABLE IF NOT EXISTS public."Interfaces" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        inactivo boolean DEFAULT false NOT NULL,
        bl_genera_archivoplano boolean DEFAULT false NOT NULL,
        ds_storedprocedure_archivoplano text,
        bl_job boolean DEFAULT false NOT NULL,
        ds_namejob text,
        bl_facturador boolean DEFAULT false NOT NULL,
        id_gds integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."Interfaces_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Interfaces_id_seq" OWNED BY public."Interfaces".id;
    CREATE TABLE IF NOT EXISTS public."Invoices" (
        id integer NOT NULL,
        "internalNumber" character varying(255) NOT NULL,
        date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "clientId" integer NOT NULL,
        currency character varying(50) NOT NULL,
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
        state character varying(25) DEFAULT 'NUEVO'::character varying
    );
    CREATE TABLE IF NOT EXISTS public."InvoicesProduct" (
        id integer NOT NULL,
        "invoiceId" integer NOT NULL,
        "productId" integer NOT NULL,
        quantity integer NOT NULL,
        price double precision NOT NULL,
        cost double precision DEFAULT 0,
        "providerId" integer,
        "prestadoraId" integer,
        "checkInDate" timestamp without time zone,
        "checkOutDate" timestamp without time zone,
        nights integer,
        "paxAdults" integer,
        "paxChildren" integer,
        "serviceType" character varying(255),
        destination character varying(255),
        "reservationCode" character varying(255),
        "sellerCommission" double precision,
        "ticketPrinterCommission" double precision,
        "comboId" integer,
        "mainTaxId" integer,
        "inNationality" integer DEFAULT 1,
        servicios text,
        descripcion text,
        itinerary text,
        class character varying(100),
        "ticketTypeId" integer,
        airline character varying(100)
    );
    CREATE TABLE IF NOT EXISTS public."InvoicesProductCombo" (
        id integer NOT NULL,
        "invoiceId" integer NOT NULL,
        "comboId" integer NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductCombo_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductCombo_id_seq" OWNED BY public."InvoicesProductCombo".id;
    CREATE TABLE IF NOT EXISTS public."InvoicesProductItinerary" (
        id integer NOT NULL,
        "invoiceProductId" integer NOT NULL,
        orden integer,
        origin character varying(255) NOT NULL,
        destination character varying(255) NOT NULL,
        class character varying(255),
        "checkInDate" timestamp without time zone,
        "checkOutDate" timestamp without time zone,
        terminal character varying(255),
        "prestadoraCode" character varying(255),
        farebasis character varying(255),
        "Numflight" character varying(25),
        "Typeflight" character varying(1),
        amount double precision
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductItinerary_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductItinerary_id_seq" OWNED BY public."InvoicesProductItinerary".id;
    CREATE TABLE IF NOT EXISTS public."InvoicesProductPasenger" (
        id integer NOT NULL,
        "invoiceProductId" integer NOT NULL,
        name character varying(255) NOT NULL,
        document character varying(255) NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductPasenger_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductPasenger_id_seq" OWNED BY public."InvoicesProductPasenger".id;
    CREATE TABLE IF NOT EXISTS public."InvoicesProductPayment" (
        id integer NOT NULL,
        "invoiceProductId" integer NOT NULL,
        amount double precision NOT NULL,
        "paymentMethod" character varying(100),
        date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
        reference character varying(255),
        "authorizationCode" text,
        "cardNumber" text,
        "creditCardId" integer,
        "expirationDate" text,
        voucher text
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductPayment_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductPayment_id_seq" OWNED BY public."InvoicesProductPayment".id;
    CREATE TABLE IF NOT EXISTS public."InvoicesProductTax" (
        id integer NOT NULL,
        "invoiceProductId" integer NOT NULL,
        "chargeAndTaxId" integer NOT NULL,
        "valueSnapshot" double precision NOT NULL,
        "valueTypeSnapshot" character varying(50) NOT NULL,
        "explicitAmount" double precision,
        "isMain" boolean DEFAULT false
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductTax_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductTax_id_seq" OWNED BY public."InvoicesProductTax".id;
    CREATE TABLE IF NOT EXISTS public."InvoicesProductVariable" (
        id integer NOT NULL,
        "invoiceProductId" integer NOT NULL,
        "masterVariableId" integer NOT NULL,
        value character varying(255) NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProductVariable_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProductVariable_id_seq" OWNED BY public."InvoicesProductVariable".id;
    CREATE SEQUENCE IF NOT EXISTS public."InvoicesProduct_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."InvoicesProduct_id_seq" OWNED BY public."InvoicesProduct".id;
    CREATE SEQUENCE IF NOT EXISTS public."Invoices_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."Invoices_id_seq" OWNED BY public."Invoices".id;
    CREATE TABLE IF NOT EXISTS public."Master" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        inactivo boolean DEFAULT false NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."MasterVariable_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."MasterVariable_id_seq" OWNED BY public."MasterVariable".id;
    CREATE SEQUENCE IF NOT EXISTS public."Master_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Master_id_seq" OWNED BY public."Master".id;
    CREATE SEQUENCE IF NOT EXISTS public."Menu_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."Menu_id_seq" OWNED BY public."Menu".id;
    CREATE TABLE IF NOT EXISTS public."Payment" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        inactive boolean DEFAULT false NOT NULL,
        iscash boolean DEFAULT false NOT NULL,
        iscredit boolean DEFAULT false NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."Payment_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Payment_id_seq" OWNED BY public."Payment".id;
    CREATE SEQUENCE IF NOT EXISTS public."Product_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Product_id_seq" OWNED BY public."Product".id;
    CREATE TABLE IF NOT EXISTS public."Provider" (
        id integer NOT NULL,
        code text,
        name text NOT NULL,
        "contactInfo" text,
        "commissionConfig" jsonb
    );
    CREATE SEQUENCE IF NOT EXISTS public."Provider_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Provider_id_seq" OWNED BY public."Provider".id;
    CREATE TABLE IF NOT EXISTS public."Quotation" (
        id integer NOT NULL,
        "internalNumber" text NOT NULL,
        date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "clientId" integer NOT NULL,
        currency text NOT NULL,
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
        state character varying(25) DEFAULT 'Nuevo'::character varying,
        "stateDescription" text,
        "stateUpdatedAt" timestamp without time zone,
        "costoTotal" double precision DEFAULT 0,
        "valorBase" double precision DEFAULT 0,
        utilidad double precision DEFAULT 0,
        "comisionTotalPercentage" double precision DEFAULT 0,
        "comisionFreelancePercentage" double precision DEFAULT 0,
        "comisionFreelanceValue" double precision DEFAULT 0,
        "comisionPropiaPercentage" double precision DEFAULT 0,
        "comisionPropiaValue" double precision DEFAULT 0,
        "comisionUtilidadPercentage" double precision DEFAULT 0,
        destination character varying(255),
        "startDate" timestamp without time zone,
        "endDate" timestamp without time zone,
        passenger character varying(255),
        "paxAdults" integer,
        "paxChildren" integer,
        "reservationCode" character varying(255),
        "copyFieldsToProducts" boolean DEFAULT true,
        "manualDescription" text
    );
    CREATE TABLE IF NOT EXISTS public."QuotationCombo" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        "comboId" integer NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationCombo_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationCombo_id_seq" OWNED BY public."QuotationCombo".id;
    CREATE TABLE IF NOT EXISTS public."QuotationFormat" (
        id integer NOT NULL,
        name character varying(100) NOT NULL,
        description character varying(255),
        template bytea,
        "templateConfig" jsonb,
        "htmlTemplate" text,
        "branchId" integer,
        "implantId" integer,
        "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationFormat_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationFormat_id_seq" OWNED BY public."QuotationFormat".id;
    CREATE TABLE IF NOT EXISTS public."QuotationManualService" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        "providerName" character varying(255),
        "serviceName" character varying(255),
        cost double precision DEFAULT 0,
        "salePrice" double precision DEFAULT 0,
        utility double precision DEFAULT 0,
        "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationManualService_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationManualService_id_seq" OWNED BY public."QuotationManualService".id;
    CREATE TABLE IF NOT EXISTS public."QuotationPrintCustomization" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        html text NOT NULL,
        "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationPrintCustomization_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationPrintCustomization_id_seq" OWNED BY public."QuotationPrintCustomization".id;
    CREATE TABLE IF NOT EXISTS public."QuotationPrintDefaultTemplate" (
        id integer NOT NULL,
        html text NOT NULL,
        name character varying(100) DEFAULT 'Default'::character varying,
        "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationPrintDefaultTemplate_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationPrintDefaultTemplate_id_seq" OWNED BY public."QuotationPrintDefaultTemplate".id;
    CREATE TABLE IF NOT EXISTS public."QuotationProduct" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        "productId" integer NOT NULL,
        quantity integer NOT NULL,
        price double precision NOT NULL,
        cost double precision DEFAULT 0,
        "providerId" integer,
        "prestadoraId" integer,
        "checkInDate" timestamp(3) without time zone,
        "checkOutDate" timestamp(3) without time zone,
        nights integer,
        "paxAdults" integer,
        "paxChildren" integer,
        "serviceType" text,
        destination text,
        "reservationCode" text,
        "sellerCommission" double precision,
        "ticketPrinterCommission" double precision,
        "comboId" integer,
        "mainTaxId" integer,
        "inNationality" integer DEFAULT 1,
        service text,
        description text,
        servicios text,
        descripcion text,
        passenger character varying(255)
    );
    CREATE TABLE IF NOT EXISTS public."QuotationProductPassenger" (
        id integer NOT NULL,
        "quotationProductId" integer NOT NULL,
        name text NOT NULL,
        document text NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationProductPassenger_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationProductPassenger_id_seq" OWNED BY public."QuotationProductPassenger".id;
    CREATE TABLE IF NOT EXISTS public."QuotationProductPayment" (
        id integer NOT NULL,
        "quotationProductId" integer NOT NULL,
        amount double precision NOT NULL,
        "paymentMethod" character varying(100),
        date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
        reference character varying(255),
        "creditCardId" integer,
        "cardNumber" character varying(20),
        "authorizationCode" character varying(50),
        voucher character varying(50),
        "expirationDate" character varying(10)
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationProductPayment_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationProductPayment_id_seq" OWNED BY public."QuotationProductPayment".id;
    CREATE TABLE IF NOT EXISTS public."QuotationProductTax" (
        id integer NOT NULL,
        "quotationProductId" integer NOT NULL,
        "chargeAndTaxId" integer NOT NULL,
        "valueSnapshot" double precision NOT NULL,
        "valueTypeSnapshot" text NOT NULL,
        "explicitAmount" double precision,
        "isMain" boolean DEFAULT false NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationProductTax_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationProductTax_id_seq" OWNED BY public."QuotationProductTax".id;
    CREATE TABLE IF NOT EXISTS public."QuotationProductVariable" (
        id integer NOT NULL,
        "quotationProductId" integer NOT NULL,
        "masterVariableId" integer NOT NULL,
        value text NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationProductVariable_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationProductVariable_id_seq" OWNED BY public."QuotationProductVariable".id;
    CREATE SEQUENCE IF NOT EXISTS public."QuotationProduct_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationProduct_id_seq" OWNED BY public."QuotationProduct".id;
    CREATE TABLE IF NOT EXISTS public."QuotationState" (
        id integer NOT NULL,
        code character varying(25) NOT NULL,
        name character varying(50) NOT NULL,
        color character varying(20),
        "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    CREATE TABLE IF NOT EXISTS public."QuotationStateHistory" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        state character varying(25) NOT NULL,
        description text,
        "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "userId" integer
    );
    CREATE SEQUENCE IF NOT EXISTS public."QuotationStateHistory_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."QuotationStateHistory_id_seq" OWNED BY public."QuotationStateHistory".id;
    CREATE SEQUENCE IF NOT EXISTS public."QuotationState_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."QuotationState_id_seq" OWNED BY public."QuotationState".id;
    CREATE SEQUENCE IF NOT EXISTS public."Quotation_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Quotation_id_seq" OWNED BY public."Quotation".id;
    CREATE TABLE IF NOT EXISTS public."Report" (
        id integer NOT NULL,
        name character varying(255) NOT NULL,
        base_table character varying(100),
        description text,
        custom_sql text,
        created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS public."ReportColumns" (
        id integer NOT NULL,
        report_id integer NOT NULL,
        table_alias character varying(20),
        column_name character varying(100) NOT NULL,
        alias character varying(150),
        is_calculated boolean DEFAULT false,
        is_visible boolean DEFAULT true,
        formula_expression text,
        sort_order integer DEFAULT 0
    );
    CREATE SEQUENCE IF NOT EXISTS public."ReportColumns_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."ReportColumns_id_seq" OWNED BY public."ReportColumns".id;
    CREATE TABLE IF NOT EXISTS public."ReportFilters" (
        id integer NOT NULL,
        report_id integer NOT NULL,
        table_alias character varying(20),
        column_name character varying(100) NOT NULL,
        filter_label character varying(150),
        filter_type character varying(50) NOT NULL,
        operator character varying(20) DEFAULT '='::character varying,
        sort_order integer DEFAULT 0
    );
    CREATE SEQUENCE IF NOT EXISTS public."ReportFilters_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."ReportFilters_id_seq" OWNED BY public."ReportFilters".id;
    CREATE TABLE IF NOT EXISTS public."ReportJoins" (
        id integer NOT NULL,
        report_id integer NOT NULL,
        table_name character varying(100) NOT NULL,
        alias character varying(20) NOT NULL,
        join_type character varying(50) DEFAULT 'INNER JOIN'::character varying NOT NULL,
        join_condition text NOT NULL,
        sort_order integer DEFAULT 0
    );
    CREATE SEQUENCE IF NOT EXISTS public."ReportJoins_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."ReportJoins_id_seq" OWNED BY public."ReportJoins".id;
    CREATE TABLE IF NOT EXISTS public."ReportSorts" (
        id integer NOT NULL,
        report_id integer NOT NULL,
        column_expr text NOT NULL,
        direction character varying(10) DEFAULT 'ASC'::character varying,
        sort_order integer DEFAULT 0
    );
    CREATE SEQUENCE IF NOT EXISTS public."ReportSorts_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."ReportSorts_id_seq" OWNED BY public."ReportSorts".id;
    CREATE SEQUENCE IF NOT EXISTS public."Report_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."Report_id_seq" OWNED BY public."Report".id;
    CREATE TABLE IF NOT EXISTS public."Role" (
        id integer NOT NULL,
        name text NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."Role_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Role_id_seq" OWNED BY public."Role".id;
    CREATE SEQUENCE IF NOT EXISTS public."Seller_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Seller_id_seq" OWNED BY public."Seller".id;
    CREATE TABLE IF NOT EXISTS public."SystemLog" (
        id integer NOT NULL,
        "userId" integer,
        action text NOT NULL,
        module text NOT NULL,
        description text NOT NULL,
        metadata jsonb,
        "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    CREATE SEQUENCE IF NOT EXISTS public."SystemLog_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."SystemLog_id_seq" OWNED BY public."SystemLog".id;
    CREATE SEQUENCE IF NOT EXISTS public."SystemParameter_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."SystemParameter_id_seq" OWNED BY public."SystemParameter".id;
    CREATE SEQUENCE IF NOT EXISTS public."TicketPrinter_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."TicketPrinter_id_seq" OWNED BY public."TicketPrinter".id;
    CREATE TABLE IF NOT EXISTS public."TicketType" (
        id integer NOT NULL,
        code character varying(50) NOT NULL,
        name character varying(255) NOT NULL,
        description text,
        "isActive" boolean DEFAULT true
    );
    CREATE SEQUENCE IF NOT EXISTS public."TicketType_id_seq"
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;
    ALTER SEQUENCE public."TicketType_id_seq" OWNED BY public."TicketType".id;
    CREATE TABLE IF NOT EXISTS public."User" (
        id integer NOT NULL,
        name text NOT NULL,
        email text NOT NULL,
        "passwordHash" text NOT NULL,
        "resetPasswordToken" text,
        "resetPasswordExpires" timestamp(3) without time zone,
        "roleId" integer NOT NULL,
        "branchId" integer,
        "implantId" integer,
        "ticketPrinterId" integer,
        "canEditReports" boolean DEFAULT false
    );
    CREATE SEQUENCE IF NOT EXISTS public."User_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;
    ALTER TABLE ONLY public."Airports" ALTER COLUMN id SET DEFAULT nextval('public."Airports_id_seq"'::regclass);
    ALTER TABLE ONLY public."Attachment" ALTER COLUMN id SET DEFAULT nextval('public."Attachment_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingGDSInvoiceAutoLog" ALTER COLUMN "Id" SET DEFAULT nextval('public."BookingGDSInvoiceAutoLog_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductFEEGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductFEEGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductItineraryGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductItineraryGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductPassangerGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductPassangerGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductPaymentGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductPaymentGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductTaxGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductTaxGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingProductVariableGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductVariableGDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingsGDSInvoiceAuto" ALTER COLUMN id SET DEFAULT nextval('public."BookingsGDSInvoiceAuto_id_seq"'::regclass);
    ALTER TABLE ONLY public."BookingsGDS_log" ALTER COLUMN id SET DEFAULT nextval('public."BookingsGDS_log_id_seq"'::regclass);
    ALTER TABLE ONLY public."Branch" ALTER COLUMN id SET DEFAULT nextval('public."Branch_id_seq"'::regclass);
    ALTER TABLE ONLY public."BranchGDSInvoiceAuto" ALTER COLUMN id SET DEFAULT nextval('public."BranchGDSInvoiceAuto_id_seq"'::regclass);
    ALTER TABLE ONLY public."CellCustomization" ALTER COLUMN id SET DEFAULT nextval('public."CellCustomization_id_seq"'::regclass);
    ALTER TABLE ONLY public."ChargeAndTax" ALTER COLUMN id SET DEFAULT nextval('public."ChargeAndTax_id_seq"'::regclass);
    ALTER TABLE ONLY public."Cities" ALTER COLUMN id SET DEFAULT nextval('public."Cities_id_seq"'::regclass);
    ALTER TABLE ONLY public."Client" ALTER COLUMN id SET DEFAULT nextval('public."Client_id_seq"'::regclass);
    ALTER TABLE ONLY public."Combo" ALTER COLUMN id SET DEFAULT nextval('public."Combo_id_seq"'::regclass);
    ALTER TABLE ONLY public."ComboProduct" ALTER COLUMN id SET DEFAULT nextval('public."ComboProduct_id_seq"'::regclass);
    ALTER TABLE ONLY public."ComboProductTax" ALTER COLUMN id SET DEFAULT nextval('public."ComboProductTax_id_seq"'::regclass);
    ALTER TABLE ONLY public."Countries" ALTER COLUMN id SET DEFAULT nextval('public."Countries_id_seq"'::regclass);
    ALTER TABLE ONLY public."CreditCard" ALTER COLUMN id SET DEFAULT nextval('public."CreditCard_id_seq"'::regclass);
    ALTER TABLE ONLY public."Currency" ALTER COLUMN id SET DEFAULT nextval('public."Currency_id_seq"'::regclass);
    ALTER TABLE ONLY public."EquivalencesInterfaces" ALTER COLUMN id SET DEFAULT nextval('public."EquivalencesInterfaces_id_seq"'::regclass);
    ALTER TABLE ONLY public."EquivalenciasInterfaces_Log" ALTER COLUMN id SET DEFAULT nextval('public."EquivalenciasInterfaces_Log_id_seq"'::regclass);
    ALTER TABLE ONLY public."FormatCellCustomization" ALTER COLUMN id SET DEFAULT nextval('public."FormatCellCustomization_id_seq"'::regclass);
    ALTER TABLE ONLY public."GDS" ALTER COLUMN id SET DEFAULT nextval('public."GDS_id_seq"'::regclass);
    ALTER TABLE ONLY public."Implant" ALTER COLUMN id SET DEFAULT nextval('public."Implant_id_seq"'::regclass);
    ALTER TABLE ONLY public."Interfaces" ALTER COLUMN id SET DEFAULT nextval('public."Interfaces_id_seq"'::regclass);
    ALTER TABLE ONLY public."Invoices" ALTER COLUMN id SET DEFAULT nextval('public."Invoices_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProduct" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProduct_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductCombo" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductCombo_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductItinerary" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductItinerary_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductPasenger" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductPasenger_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductPayment" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductPayment_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductTax" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductTax_id_seq"'::regclass);
    ALTER TABLE ONLY public."InvoicesProductVariable" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductVariable_id_seq"'::regclass);
    ALTER TABLE ONLY public."Master" ALTER COLUMN id SET DEFAULT nextval('public."Master_id_seq"'::regclass);
    ALTER TABLE ONLY public."MasterVariable" ALTER COLUMN id SET DEFAULT nextval('public."MasterVariable_id_seq"'::regclass);
    ALTER TABLE ONLY public."Menu" ALTER COLUMN id SET DEFAULT nextval('public."Menu_id_seq"'::regclass);
    ALTER TABLE ONLY public."Payment" ALTER COLUMN id SET DEFAULT nextval('public."Payment_id_seq"'::regclass);
    ALTER TABLE ONLY public."Prestadora" ALTER COLUMN id SET DEFAULT nextval('public."Hotel_id_seq"'::regclass);
    ALTER TABLE ONLY public."Product" ALTER COLUMN id SET DEFAULT nextval('public."Product_id_seq"'::regclass);
    ALTER TABLE ONLY public."Provider" ALTER COLUMN id SET DEFAULT nextval('public."Provider_id_seq"'::regclass);
    ALTER TABLE ONLY public."Quotation" ALTER COLUMN id SET DEFAULT nextval('public."Quotation_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationCombo" ALTER COLUMN id SET DEFAULT nextval('public."QuotationCombo_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationFormat" ALTER COLUMN id SET DEFAULT nextval('public."QuotationFormat_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationManualService" ALTER COLUMN id SET DEFAULT nextval('public."QuotationManualService_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationPrintCustomization" ALTER COLUMN id SET DEFAULT nextval('public."QuotationPrintCustomization_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationPrintDefaultTemplate" ALTER COLUMN id SET DEFAULT nextval('public."QuotationPrintDefaultTemplate_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationProduct" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProduct_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationProductPassenger" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductPassenger_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationProductPayment" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductPayment_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationProductTax" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductTax_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationProductVariable" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductVariable_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationState" ALTER COLUMN id SET DEFAULT nextval('public."QuotationState_id_seq"'::regclass);
    ALTER TABLE ONLY public."QuotationStateHistory" ALTER COLUMN id SET DEFAULT nextval('public."QuotationStateHistory_id_seq"'::regclass);
    ALTER TABLE ONLY public."Report" ALTER COLUMN id SET DEFAULT nextval('public."Report_id_seq"'::regclass);
    ALTER TABLE ONLY public."ReportColumns" ALTER COLUMN id SET DEFAULT nextval('public."ReportColumns_id_seq"'::regclass);
    ALTER TABLE ONLY public."ReportFilters" ALTER COLUMN id SET DEFAULT nextval('public."ReportFilters_id_seq"'::regclass);
    ALTER TABLE ONLY public."ReportJoins" ALTER COLUMN id SET DEFAULT nextval('public."ReportJoins_id_seq"'::regclass);
    ALTER TABLE ONLY public."ReportSorts" ALTER COLUMN id SET DEFAULT nextval('public."ReportSorts_id_seq"'::regclass);
    ALTER TABLE ONLY public."Role" ALTER COLUMN id SET DEFAULT nextval('public."Role_id_seq"'::regclass);
    ALTER TABLE ONLY public."Seller" ALTER COLUMN id SET DEFAULT nextval('public."Seller_id_seq"'::regclass);
    ALTER TABLE ONLY public."SystemLog" ALTER COLUMN id SET DEFAULT nextval('public."SystemLog_id_seq"'::regclass);
    ALTER TABLE ONLY public."SystemParameter" ALTER COLUMN id SET DEFAULT nextval('public."SystemParameter_id_seq"'::regclass);
    ALTER TABLE ONLY public."TicketPrinter" ALTER COLUMN id SET DEFAULT nextval('public."TicketPrinter_id_seq"'::regclass);
    ALTER TABLE ONLY public."TicketType" ALTER COLUMN id SET DEFAULT nextval('public."TicketType_id_seq"'::regclass);
    ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Airports_pkey') THEN
            ALTER TABLE ONLY public."Airports" ADD CONSTRAINT "Airports_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Attachment_pkey') THEN
            ALTER TABLE ONLY public."Attachment" ADD CONSTRAINT "Attachment_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingGDSInvoiceAutoLog_pkey') THEN
            ALTER TABLE ONLY public."BookingGDSInvoiceAutoLog" ADD CONSTRAINT "BookingGDSInvoiceAutoLog_pkey" PRIMARY KEY ("Id");
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingGDS" ADD CONSTRAINT "BookingGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductFEEGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductFEEGDS" ADD CONSTRAINT "BookingProductFEEGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductGDS" ADD CONSTRAINT "BookingProductGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductItineraryGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductItineraryGDS" ADD CONSTRAINT "BookingProductItineraryGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductPassangerGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductPassangerGDS" ADD CONSTRAINT "BookingProductPassangerGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductPaymentGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductPaymentGDS" ADD CONSTRAINT "BookingProductPaymentGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductTaxGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductTaxGDS" ADD CONSTRAINT "BookingProductTaxGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductVariableGDS_pkey') THEN
            ALTER TABLE ONLY public."BookingProductVariableGDS" ADD CONSTRAINT "BookingProductVariableGDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingsGDSInvoiceAuto_pkey') THEN
            ALTER TABLE ONLY public."BookingsGDSInvoiceAuto" ADD CONSTRAINT "BookingsGDSInvoiceAuto_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingsGDS_log_pkey') THEN
            ALTER TABLE ONLY public."BookingsGDS_log" ADD CONSTRAINT "BookingsGDS_log_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BranchGDSInvoiceAuto_pkey') THEN
            ALTER TABLE ONLY public."BranchGDSInvoiceAuto" ADD CONSTRAINT "BranchGDSInvoiceAuto_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Branch_pkey') THEN
            ALTER TABLE ONLY public."Branch" ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'CellCustomization_pkey') THEN
            ALTER TABLE ONLY public."CellCustomization" ADD CONSTRAINT "CellCustomization_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ChargeAndTax_code_key') THEN
            ALTER TABLE ONLY public."ChargeAndTax" ADD CONSTRAINT "ChargeAndTax_code_key" UNIQUE (code);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ChargeAndTax_pkey') THEN
            ALTER TABLE ONLY public."ChargeAndTax" ADD CONSTRAINT "ChargeAndTax_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Cities_pkey') THEN
            ALTER TABLE ONLY public."Cities" ADD CONSTRAINT "Cities_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Client_pkey') THEN
            ALTER TABLE ONLY public."Client" ADD CONSTRAINT "Client_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProductTax_pkey') THEN
            ALTER TABLE ONLY public."ComboProductTax" ADD CONSTRAINT "ComboProductTax_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProduct_pkey') THEN
            ALTER TABLE ONLY public."ComboProduct" ADD CONSTRAINT "ComboProduct_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Combo_pkey') THEN
            ALTER TABLE ONLY public."Combo" ADD CONSTRAINT "Combo_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Countries_pkey') THEN
            ALTER TABLE ONLY public."Countries" ADD CONSTRAINT "Countries_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'CreditCard_pkey') THEN
            ALTER TABLE ONLY public."CreditCard" ADD CONSTRAINT "CreditCard_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Currency_pkey') THEN
            ALTER TABLE ONLY public."Currency" ADD CONSTRAINT "Currency_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'EquivalencesInterfaces_pkey') THEN
            ALTER TABLE ONLY public."EquivalencesInterfaces" ADD CONSTRAINT "EquivalencesInterfaces_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'EquivalenciasInterfaces_Log_pkey') THEN
            ALTER TABLE ONLY public."EquivalenciasInterfaces_Log" ADD CONSTRAINT "EquivalenciasInterfaces_Log_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FormatCellCustomization_format_code_key') THEN
            ALTER TABLE ONLY public."FormatCellCustomization" ADD CONSTRAINT "FormatCellCustomization_format_code_key" UNIQUE ("formatId", code);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FormatCellCustomization_pkey') THEN
            ALTER TABLE ONLY public."FormatCellCustomization" ADD CONSTRAINT "FormatCellCustomization_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'GDS_pkey') THEN
            ALTER TABLE ONLY public."GDS" ADD CONSTRAINT "GDS_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Implant_pkey') THEN
            ALTER TABLE ONLY public."Implant" ADD CONSTRAINT "Implant_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductCombo_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductCombo" ADD CONSTRAINT "InvoicesProductCombo_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductItinerary_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductItinerary" ADD CONSTRAINT "InvoicesProductItinerary_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductPasenger_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductPasenger" ADD CONSTRAINT "InvoicesProductPasenger_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductPayment_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductPayment" ADD CONSTRAINT "InvoicesProductPayment_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductTax_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductTax" ADD CONSTRAINT "InvoicesProductTax_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductVariable_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProductVariable" ADD CONSTRAINT "InvoicesProductVariable_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProduct_pkey') THEN
            ALTER TABLE ONLY public."InvoicesProduct" ADD CONSTRAINT "InvoicesProduct_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Invoices_internalNumber_key') THEN
            ALTER TABLE ONLY public."Invoices" ADD CONSTRAINT "Invoices_internalNumber_key" UNIQUE ("internalNumber");
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Invoices_pkey') THEN
            ALTER TABLE ONLY public."Invoices" ADD CONSTRAINT "Invoices_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'MasterVariable_pkey') THEN
            ALTER TABLE ONLY public."MasterVariable" ADD CONSTRAINT "MasterVariable_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Menu_code_key') THEN
            ALTER TABLE ONLY public."Menu" ADD CONSTRAINT "Menu_code_key" UNIQUE (code);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Menu_pkey') THEN
            ALTER TABLE ONLY public."Menu" ADD CONSTRAINT "Menu_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Payment_pkey') THEN
            ALTER TABLE ONLY public."Payment" ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Prestadora_pkey') THEN
            ALTER TABLE ONLY public."Prestadora" ADD CONSTRAINT "Prestadora_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Product_pkey') THEN
            ALTER TABLE ONLY public."Product" ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Provider_pkey') THEN
            ALTER TABLE ONLY public."Provider" ADD CONSTRAINT "Provider_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationCombo_pkey') THEN
            ALTER TABLE ONLY public."QuotationCombo" ADD CONSTRAINT "QuotationCombo_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationFormat_pkey') THEN
            ALTER TABLE ONLY public."QuotationFormat" ADD CONSTRAINT "QuotationFormat_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationManualService_pkey') THEN
            ALTER TABLE ONLY public."QuotationManualService" ADD CONSTRAINT "QuotationManualService_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationPrintCustomization_pkey') THEN
            ALTER TABLE ONLY public."QuotationPrintCustomization" ADD CONSTRAINT "QuotationPrintCustomization_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationPrintCustomization_quotationId_key') THEN
            ALTER TABLE ONLY public."QuotationPrintCustomization" ADD CONSTRAINT "QuotationPrintCustomization_quotationId_key" UNIQUE ("quotationId");
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationPrintDefaultTemplate_pkey') THEN
            ALTER TABLE ONLY public."QuotationPrintDefaultTemplate" ADD CONSTRAINT "QuotationPrintDefaultTemplate_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductPassenger_pkey') THEN
            ALTER TABLE ONLY public."QuotationProductPassenger" ADD CONSTRAINT "QuotationProductPassenger_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductPayment_pkey') THEN
            ALTER TABLE ONLY public."QuotationProductPayment" ADD CONSTRAINT "QuotationProductPayment_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductTax_pkey') THEN
            ALTER TABLE ONLY public."QuotationProductTax" ADD CONSTRAINT "QuotationProductTax_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductVariable_pkey') THEN
            ALTER TABLE ONLY public."QuotationProductVariable" ADD CONSTRAINT "QuotationProductVariable_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProduct_pkey') THEN
            ALTER TABLE ONLY public."QuotationProduct" ADD CONSTRAINT "QuotationProduct_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationStateHistory_pkey') THEN
            ALTER TABLE ONLY public."QuotationStateHistory" ADD CONSTRAINT "QuotationStateHistory_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationState_code_key') THEN
            ALTER TABLE ONLY public."QuotationState" ADD CONSTRAINT "QuotationState_code_key" UNIQUE (code);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationState_pkey') THEN
            ALTER TABLE ONLY public."QuotationState" ADD CONSTRAINT "QuotationState_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_pkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportColumns_pkey') THEN
            ALTER TABLE ONLY public."ReportColumns" ADD CONSTRAINT "ReportColumns_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportFilters_pkey') THEN
            ALTER TABLE ONLY public."ReportFilters" ADD CONSTRAINT "ReportFilters_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportJoins_pkey') THEN
            ALTER TABLE ONLY public."ReportJoins" ADD CONSTRAINT "ReportJoins_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportSorts_pkey') THEN
            ALTER TABLE ONLY public."ReportSorts" ADD CONSTRAINT "ReportSorts_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Report_pkey') THEN
            ALTER TABLE ONLY public."Report" ADD CONSTRAINT "Report_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Role_pkey') THEN
            ALTER TABLE ONLY public."Role" ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Seller_pkey') THEN
            ALTER TABLE ONLY public."Seller" ADD CONSTRAINT "Seller_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'SystemLog_pkey') THEN
            ALTER TABLE ONLY public."SystemLog" ADD CONSTRAINT "SystemLog_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'SystemParameter_pkey') THEN
            ALTER TABLE ONLY public."SystemParameter" ADD CONSTRAINT "SystemParameter_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'TicketPrinter_pkey') THEN
            ALTER TABLE ONLY public."TicketPrinter" ADD CONSTRAINT "TicketPrinter_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'TicketType_code_key') THEN
            ALTER TABLE ONLY public."TicketType" ADD CONSTRAINT "TicketType_code_key" UNIQUE (code);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'TicketType_pkey') THEN
            ALTER TABLE ONLY public."TicketType" ADD CONSTRAINT "TicketType_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'User_pkey') THEN
            ALTER TABLE ONLY public."User" ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'interfaces_pkey') THEN
            ALTER TABLE ONLY public."Interfaces" ADD CONSTRAINT "interfaces_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'master_pkey') THEN
            ALTER TABLE ONLY public."Master" ADD CONSTRAINT "master_pkey" PRIMARY KEY (id);
        END IF;
    END $con$;
    CREATE UNIQUE INDEX IF NOT EXISTS "Branch_code_key" ON public."Branch" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "CellCustomization_branch_code_key" ON public."CellCustomization" USING btree ("branchId", code) WHERE ("branchId" IS NOT NULL);
    CREATE UNIQUE INDEX IF NOT EXISTS "CellCustomization_implant_code_key" ON public."CellCustomization" USING btree ("implantId", code) WHERE ("implantId" IS NOT NULL);
    CREATE UNIQUE INDEX IF NOT EXISTS "Client_document_key" ON public."Client" USING btree (document) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Combo_code_key" ON public."Combo" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "CreditCard_code_key" ON public."CreditCard" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Currency_code_key" ON public."Currency" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Hotel_code_key" ON public."Prestadora" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Implant_code_key" ON public."Implant" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "MasterVariable_code_key" ON public."MasterVariable" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Payment_code_key" ON public."Payment" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Product_code_key" ON public."Product" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Provider_code_key" ON public."Provider" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE INDEX IF NOT EXISTS "QuotationStateHistory_quotationId_idx" ON public."QuotationStateHistory" USING btree ("quotationId");
    CREATE UNIQUE INDEX IF NOT EXISTS "Quotation_internalNumber_key" ON public."Quotation" USING btree ("internalNumber") WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Role_name_key" ON public."Role" USING btree (name) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "Seller_code_key" ON public."Seller" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "SystemParameter_code_key" ON public."SystemParameter" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "TicketPrinter_code_key" ON public."TicketPrinter" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "User_email_key" ON public."User" USING btree (email) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS "User_resetPasswordToken_key" ON public."User" USING btree ("resetPasswordToken") WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS airports_code_key ON public."Airports" USING btree (code);
    CREATE UNIQUE INDEX IF NOT EXISTS bookingds_code_key ON public."BookingGDS" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS cities_code_key ON public."Cities" USING btree (code);
    CREATE UNIQUE INDEX IF NOT EXISTS countries_code_key ON public."Countries" USING btree (code);
    CREATE UNIQUE INDEX IF NOT EXISTS currency_code_key ON public."Currency" USING btree (code);
    CREATE UNIQUE INDEX IF NOT EXISTS gds_name_key ON public."GDS" USING btree (name) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS interfaces_code_key ON public."Interfaces" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    CREATE UNIQUE INDEX IF NOT EXISTS master_code_key ON public."Master" USING btree (code) WITH (fillfactor='100', deduplicate_items='true');
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Airports_citiesId_fkey') THEN
            ALTER TABLE ONLY public."Airports" ADD CONSTRAINT "Airports_citiesId_fkey" FOREIGN KEY ("citiesId") REFERENCES public."Cities"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Attachment_quotationId_fkey') THEN
            ALTER TABLE ONLY public."Attachment" ADD CONSTRAINT "Attachment_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductFEEGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductFEEGDS" ADD CONSTRAINT "BookingProductFEEGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductGDS_bookingId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductGDS" ADD CONSTRAINT "BookingProductGDS_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."BookingGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductItineraryGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductItineraryGDS" ADD CONSTRAINT "BookingProductItineraryGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductPassangerGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductPassangerGDS" ADD CONSTRAINT "BookingProductPassangerGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductPaymentGDS_bookingProductFEEId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductPaymentGDS" ADD CONSTRAINT "BookingProductPaymentGDS_bookingProductFEEId_fkey" FOREIGN KEY ("bookingProductFEEId") REFERENCES public."BookingProductFEEGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductPaymentGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductPaymentGDS" ADD CONSTRAINT "BookingProductPaymentGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductTaxGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductTaxGDS" ADD CONSTRAINT "BookingProductTaxGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BookingProductVariableGDS_bookingProductId_fkey') THEN
            ALTER TABLE ONLY public."BookingProductVariableGDS" ADD CONSTRAINT "BookingProductVariableGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'BranchGDSInvoiceAuto_branchId_fkey') THEN
            ALTER TABLE ONLY public."BranchGDSInvoiceAuto" ADD CONSTRAINT "BranchGDSInvoiceAuto_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'CellCustomization_branchId_fkey') THEN
            ALTER TABLE ONLY public."CellCustomization" ADD CONSTRAINT "CellCustomization_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'CellCustomization_implantId_fkey') THEN
            ALTER TABLE ONLY public."CellCustomization" ADD CONSTRAINT "CellCustomization_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Cities_countriesId_fkey') THEN
            ALTER TABLE ONLY public."Cities" ADD CONSTRAINT "Cities_countriesId_fkey" FOREIGN KEY ("countriesId") REFERENCES public."Countries"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProductTax_chargeAndTaxId_fkey') THEN
            ALTER TABLE ONLY public."ComboProductTax" ADD CONSTRAINT "ComboProductTax_chargeAndTaxId_fkey" FOREIGN KEY ("chargeAndTaxId") REFERENCES public."ChargeAndTax"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProductTax_comboProductId_fkey') THEN
            ALTER TABLE ONLY public."ComboProductTax" ADD CONSTRAINT "ComboProductTax_comboProductId_fkey" FOREIGN KEY ("comboProductId") REFERENCES public."ComboProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProduct_comboId_fkey') THEN
            ALTER TABLE ONLY public."ComboProduct" ADD CONSTRAINT "ComboProduct_comboId_fkey" FOREIGN KEY ("comboId") REFERENCES public."Combo"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProduct_prestadoraId_fkey') THEN
            ALTER TABLE ONLY public."ComboProduct" ADD CONSTRAINT "ComboProduct_prestadoraId_fkey" FOREIGN KEY ("prestadoraId") REFERENCES public."Prestadora"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProduct_productId_fkey') THEN
            ALTER TABLE ONLY public."ComboProduct" ADD CONSTRAINT "ComboProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ComboProduct_providerId_fkey') THEN
            ALTER TABLE ONLY public."ComboProduct" ADD CONSTRAINT "ComboProduct_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Combo_currencyId_fkey') THEN
            ALTER TABLE ONLY public."Combo" ADD CONSTRAINT "Combo_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Countries_curencyId_fkey') THEN
            ALTER TABLE ONLY public."Countries" ADD CONSTRAINT "Countries_curencyId_fkey" FOREIGN KEY ("curencyId") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'EquivalencesInterfaces_id_interfaces_fkey') THEN
            ALTER TABLE ONLY public."EquivalencesInterfaces" ADD CONSTRAINT "EquivalencesInterfaces_id_interfaces_fkey" FOREIGN KEY (id_interfaces) REFERENCES public."Interfaces"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'EquivalencesInterfaces_id_master_fkey') THEN
            ALTER TABLE ONLY public."EquivalencesInterfaces" ADD CONSTRAINT "EquivalencesInterfaces_id_master_fkey" FOREIGN KEY (id_master) REFERENCES public."Master"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FormatCellCustomization_formatId_fkey') THEN
            ALTER TABLE ONLY public."FormatCellCustomization" ADD CONSTRAINT "FormatCellCustomization_formatId_fkey" FOREIGN KEY ("formatId") REFERENCES public."QuotationFormat"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Implant_branchId_fkey') THEN
            ALTER TABLE ONLY public."Implant" ADD CONSTRAINT "Implant_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductItinerary_invoiceProductId_fkey') THEN
            ALTER TABLE ONLY public."InvoicesProductItinerary" ADD CONSTRAINT "InvoicesProductItinerary_invoiceProductId_fkey" FOREIGN KEY ("invoiceProductId") REFERENCES public."InvoicesProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'InvoicesProductPayment_creditCardId_fkey') THEN
            ALTER TABLE ONLY public."InvoicesProductPayment" ADD CONSTRAINT "InvoicesProductPayment_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES public."CreditCard"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Prestadora_providerId_fkey') THEN
            ALTER TABLE ONLY public."Prestadora" ADD CONSTRAINT "Prestadora_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Product_ticketTypeId_fkey') THEN
            ALTER TABLE ONLY public."Product" ADD CONSTRAINT "Product_ticketTypeId_fkey" FOREIGN KEY ("ticketTypeId") REFERENCES public."TicketType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationCombo_comboId_fkey') THEN
            ALTER TABLE ONLY public."QuotationCombo" ADD CONSTRAINT "QuotationCombo_comboId_fkey" FOREIGN KEY ("comboId") REFERENCES public."Combo"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationCombo_quotationId_fkey') THEN
            ALTER TABLE ONLY public."QuotationCombo" ADD CONSTRAINT "QuotationCombo_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationFormat_branchId_fkey') THEN
            ALTER TABLE ONLY public."QuotationFormat" ADD CONSTRAINT "QuotationFormat_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationFormat_implantId_fkey') THEN
            ALTER TABLE ONLY public."QuotationFormat" ADD CONSTRAINT "QuotationFormat_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationManualService_quotationId_fkey') THEN
            ALTER TABLE ONLY public."QuotationManualService" ADD CONSTRAINT "QuotationManualService_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductPassenger_quotationProductId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductPassenger" ADD CONSTRAINT "QuotationProductPassenger_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductPayment_quotationProductId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductPayment" ADD CONSTRAINT "QuotationProductPayment_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductTax_chargeAndTaxId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductTax" ADD CONSTRAINT "QuotationProductTax_chargeAndTaxId_fkey" FOREIGN KEY ("chargeAndTaxId") REFERENCES public."ChargeAndTax"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductTax_quotationProductId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductTax" ADD CONSTRAINT "QuotationProductTax_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductVariable_masterVariableId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductVariable" ADD CONSTRAINT "QuotationProductVariable_masterVariableId_fkey" FOREIGN KEY ("masterVariableId") REFERENCES public."MasterVariable"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProductVariable_quotationProductId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProductVariable" ADD CONSTRAINT "QuotationProductVariable_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProduct_prestadoraId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProduct" ADD CONSTRAINT "QuotationProduct_prestadoraId_fkey" FOREIGN KEY ("prestadoraId") REFERENCES public."Prestadora"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProduct_productId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProduct" ADD CONSTRAINT "QuotationProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProduct_providerId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProduct" ADD CONSTRAINT "QuotationProduct_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationProduct_quotationId_fkey') THEN
            ALTER TABLE ONLY public."QuotationProduct" ADD CONSTRAINT "QuotationProduct_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationStateHistory_quotationId_fkey') THEN
            ALTER TABLE ONLY public."QuotationStateHistory" ADD CONSTRAINT "QuotationStateHistory_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'QuotationStateHistory_userId_fkey') THEN
            ALTER TABLE ONLY public."QuotationStateHistory" ADD CONSTRAINT "QuotationStateHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_branchId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_clientId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."Client"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_implantId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_sellerId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."Seller"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_ticketPrinterId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_ticketPrinterId_fkey" FOREIGN KEY ("ticketPrinterId") REFERENCES public."TicketPrinter"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'Quotation_userId_fkey') THEN
            ALTER TABLE ONLY public."Quotation" ADD CONSTRAINT "Quotation_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportColumns_report_id_fkey') THEN
            ALTER TABLE ONLY public."ReportColumns" ADD CONSTRAINT "ReportColumns_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportFilters_report_id_fkey') THEN
            ALTER TABLE ONLY public."ReportFilters" ADD CONSTRAINT "ReportFilters_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportJoins_report_id_fkey') THEN
            ALTER TABLE ONLY public."ReportJoins" ADD CONSTRAINT "ReportJoins_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ReportSorts_report_id_fkey') THEN
            ALTER TABLE ONLY public."ReportSorts" ADD CONSTRAINT "ReportSorts_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'SystemLog_userId_fkey') THEN
            ALTER TABLE ONLY public."SystemLog" ADD CONSTRAINT "SystemLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'User_branchId_fkey') THEN
            ALTER TABLE ONLY public."User" ADD CONSTRAINT "User_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'User_implantId_fkey') THEN
            ALTER TABLE ONLY public."User" ADD CONSTRAINT "User_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'User_roleId_fkey') THEN
            ALTER TABLE ONLY public."User" ADD CONSTRAINT "User_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
        END IF;
    END $con$;
    DO $con$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'User_ticketPrinterId_fkey') THEN
            ALTER TABLE ONLY public."User" ADD CONSTRAINT "User_ticketPrinterId_fkey" FOREIGN KEY ("ticketPrinterId") REFERENCES public."TicketPrinter"(id) ON UPDATE CASCADE ON DELETE SET NULL;
        END IF;
    END $con$;

END $$;