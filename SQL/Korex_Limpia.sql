--
-- PostgreSQL database dump
--

\restrict W0l5rqHAu2hBc9ZD3MkW4HMeeQyOVnFNDs7u6RzsJuIk2s8dadjuQ9ij0120Z1H

-- Dumped from database version 18.2
-- Dumped by pg_dump version 18.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_ticketPrinterId_fkey";
ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_roleId_fkey";
ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."TransactionConsecutive" DROP CONSTRAINT IF EXISTS "TransactionConsecutive_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."TransactionConsecutive" DROP CONSTRAINT IF EXISTS "TransactionConsecutive_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."SystemLog" DROP CONSTRAINT IF EXISTS "SystemLog_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."SysConsecutivo" DROP CONSTRAINT IF EXISTS "SysConsecutivo_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."SysConsecutivo" DROP CONSTRAINT IF EXISTS "SysConsecutivo_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."ReportSorts" DROP CONSTRAINT IF EXISTS "ReportSorts_report_id_fkey";
ALTER TABLE IF EXISTS ONLY public."ReportJoins" DROP CONSTRAINT IF EXISTS "ReportJoins_report_id_fkey";
ALTER TABLE IF EXISTS ONLY public."ReportFilters" DROP CONSTRAINT IF EXISTS "ReportFilters_report_id_fkey";
ALTER TABLE IF EXISTS ONLY public."ReportColumns" DROP CONSTRAINT IF EXISTS "ReportColumns_report_id_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_ticketPrinterId_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_sellerId_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_clientId_fkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationStateHistory" DROP CONSTRAINT IF EXISTS "QuotationStateHistory_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationStateHistory" DROP CONSTRAINT IF EXISTS "QuotationStateHistory_quotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProduct" DROP CONSTRAINT IF EXISTS "QuotationProduct_quotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProduct" DROP CONSTRAINT IF EXISTS "QuotationProduct_providerId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProduct" DROP CONSTRAINT IF EXISTS "QuotationProduct_productId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProduct" DROP CONSTRAINT IF EXISTS "QuotationProduct_prestadoraId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductVariable" DROP CONSTRAINT IF EXISTS "QuotationProductVariable_quotationProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductVariable" DROP CONSTRAINT IF EXISTS "QuotationProductVariable_masterVariableId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductTax" DROP CONSTRAINT IF EXISTS "QuotationProductTax_quotationProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductTax" DROP CONSTRAINT IF EXISTS "QuotationProductTax_chargeAndTaxId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductPayment" DROP CONSTRAINT IF EXISTS "QuotationProductPayment_quotationProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductPassenger" DROP CONSTRAINT IF EXISTS "QuotationProductPassenger_quotationProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationManualService" DROP CONSTRAINT IF EXISTS "QuotationManualService_quotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationFormat" DROP CONSTRAINT IF EXISTS "QuotationFormat_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationFormat" DROP CONSTRAINT IF EXISTS "QuotationFormat_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationCombo" DROP CONSTRAINT IF EXISTS "QuotationCombo_quotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."QuotationCombo" DROP CONSTRAINT IF EXISTS "QuotationCombo_comboId_fkey";
ALTER TABLE IF EXISTS ONLY public."Provider" DROP CONSTRAINT IF EXISTS "Provider_providerTypeId_fkey";
ALTER TABLE IF EXISTS ONLY public."Product" DROP CONSTRAINT IF EXISTS "Product_ticketTypeId_fkey";
ALTER TABLE IF EXISTS ONLY public."Prestadora" DROP CONSTRAINT IF EXISTS "Prestadora_providerId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_ticketPrinterId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_sellerId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_providerId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_convertedUserId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_convertedQuotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_clientId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotationStateHistory" DROP CONSTRAINT IF EXISTS "PreQuotationStateHistory_userId_fkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotationStateHistory" DROP CONSTRAINT IF EXISTS "PreQuotationStateHistory_preQuotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductPayment" DROP CONSTRAINT IF EXISTS "InvoicesProductPayment_creditCardId_fkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductItinerary" DROP CONSTRAINT IF EXISTS "InvoicesProductItinerary_invoiceProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."InterfaceExtractParam" DROP CONSTRAINT IF EXISTS "InterfaceExtractParam_interfaceId_fkey";
ALTER TABLE IF EXISTS ONLY public."Implant" DROP CONSTRAINT IF EXISTS "Implant_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."FormatCellCustomization" DROP CONSTRAINT IF EXISTS "FormatCellCustomization_formatId_fkey";
ALTER TABLE IF EXISTS ONLY public."ExecutionPreset" DROP CONSTRAINT IF EXISTS "ExecutionPreset_procedureId_fkey";
ALTER TABLE IF EXISTS ONLY public."EquivalencesInterfaces" DROP CONSTRAINT IF EXISTS "EquivalencesInterfaces_id_master_fkey";
ALTER TABLE IF EXISTS ONLY public."EquivalencesInterfaces" DROP CONSTRAINT IF EXISTS "EquivalencesInterfaces_id_interfaces_fkey";
ALTER TABLE IF EXISTS ONLY public."DocumentResolution" DROP CONSTRAINT IF EXISTS "DocumentResolution_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."DocumentResolution" DROP CONSTRAINT IF EXISTS "DocumentResolution_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."Countries" DROP CONSTRAINT IF EXISTS "Countries_curencyId_fkey";
ALTER TABLE IF EXISTS ONLY public."Combo" DROP CONSTRAINT IF EXISTS "Combo_currencyId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProduct" DROP CONSTRAINT IF EXISTS "ComboProduct_providerId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProduct" DROP CONSTRAINT IF EXISTS "ComboProduct_productId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProduct" DROP CONSTRAINT IF EXISTS "ComboProduct_prestadoraId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProduct" DROP CONSTRAINT IF EXISTS "ComboProduct_comboId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProductTax" DROP CONSTRAINT IF EXISTS "ComboProductTax_comboProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."ComboProductTax" DROP CONSTRAINT IF EXISTS "ComboProductTax_chargeAndTaxId_fkey";
ALTER TABLE IF EXISTS ONLY public."Client" DROP CONSTRAINT IF EXISTS "Client_sellerId_fkey";
ALTER TABLE IF EXISTS ONLY public."Cities" DROP CONSTRAINT IF EXISTS "Cities_countriesId_fkey";
ALTER TABLE IF EXISTS ONLY public."CellCustomization" DROP CONSTRAINT IF EXISTS "CellCustomization_implantId_fkey";
ALTER TABLE IF EXISTS ONLY public."CellCustomization" DROP CONSTRAINT IF EXISTS "CellCustomization_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."BranchGDSInvoiceAuto" DROP CONSTRAINT IF EXISTS "BranchGDSInvoiceAuto_branchId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductVariableGDS" DROP CONSTRAINT IF EXISTS "BookingProductVariableGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductTaxGDS" DROP CONSTRAINT IF EXISTS "BookingProductTaxGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductPaymentGDS" DROP CONSTRAINT IF EXISTS "BookingProductPaymentGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductPaymentGDS" DROP CONSTRAINT IF EXISTS "BookingProductPaymentGDS_bookingProductFEEId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductPassangerGDS" DROP CONSTRAINT IF EXISTS "BookingProductPassangerGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductItineraryGDS" DROP CONSTRAINT IF EXISTS "BookingProductItineraryGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductGDS" DROP CONSTRAINT IF EXISTS "BookingProductGDS_bookingId_fkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductFEEGDS" DROP CONSTRAINT IF EXISTS "BookingProductFEEGDS_bookingProductId_fkey";
ALTER TABLE IF EXISTS ONLY public."Attachment" DROP CONSTRAINT IF EXISTS "Attachment_quotationId_fkey";
ALTER TABLE IF EXISTS ONLY public."Airports" DROP CONSTRAINT IF EXISTS "Airports_citiesId_fkey";
DROP INDEX IF EXISTS public.idx_sysconsecutivo_implant;
DROP INDEX IF EXISTS public.idx_sysconsecutivo_codigo;
DROP INDEX IF EXISTS public.idx_sysconsecutivo_branch;
DROP INDEX IF EXISTS public."User_resetPasswordToken_key";
DROP INDEX IF EXISTS public."User_email_key";
DROP INDEX IF EXISTS public."TicketType_code_key";
DROP INDEX IF EXISTS public."TicketPrinter_code_key";
DROP INDEX IF EXISTS public."SystemParameter_code_key";
DROP INDEX IF EXISTS public."Seller_code_key";
DROP INDEX IF EXISTS public."Role_name_key";
DROP INDEX IF EXISTS public."Resolution_code_key";
DROP INDEX IF EXISTS public."Quotation_internalNumber_key";
DROP INDEX IF EXISTS public."QuotationState_code_key";
DROP INDEX IF EXISTS public."QuotationStateHistory_quotationId_idx";
DROP INDEX IF EXISTS public."QuotationPrintCustomization_quotationId_key";
DROP INDEX IF EXISTS public."QuotationFormat_name_key";
DROP INDEX IF EXISTS public."Provider_code_key";
DROP INDEX IF EXISTS public."ProviderType_code_key";
DROP INDEX IF EXISTS public."Product_code_key";
DROP INDEX IF EXISTS public."PreQuotation_consecutivo_key";
DROP INDEX IF EXISTS public."Payment_code_key";
DROP INDEX IF EXISTS public."Menu_code_key";
DROP INDEX IF EXISTS public."Master_code_key";
DROP INDEX IF EXISTS public."MasterVariable_code_key";
DROP INDEX IF EXISTS public."Invoices_internalNumber_key";
DROP INDEX IF EXISTS public."Interfaces_code_key";
DROP INDEX IF EXISTS public."InterfaceExtractParam_interfaceId_prefix_key";
DROP INDEX IF EXISTS public."Implant_code_key";
DROP INDEX IF EXISTS public."Hotel_code_key";
DROP INDEX IF EXISTS public."GDS_name_key";
DROP INDEX IF EXISTS public."FormatCellCustomization_format_code_key";
DROP INDEX IF EXISTS public."Currency_code_key";
DROP INDEX IF EXISTS public."CreditCard_code_key";
DROP INDEX IF EXISTS public."Countries_code_key";
DROP INDEX IF EXISTS public."Combo_code_key";
DROP INDEX IF EXISTS public."Client_document_key";
DROP INDEX IF EXISTS public."Cities_code_key";
DROP INDEX IF EXISTS public."ChargeAndTax_code_key";
DROP INDEX IF EXISTS public."CellCustomization_implant_code_key";
DROP INDEX IF EXISTS public."CellCustomization_branch_code_key";
DROP INDEX IF EXISTS public."Branch_code_key";
DROP INDEX IF EXISTS public."BookingGDS_code_key";
DROP INDEX IF EXISTS public."Airports_code_key";
ALTER TABLE IF EXISTS ONLY public."Master" DROP CONSTRAINT IF EXISTS master_pkey;
ALTER TABLE IF EXISTS ONLY public."Interfaces" DROP CONSTRAINT IF EXISTS interfaces_pkey;
ALTER TABLE IF EXISTS ONLY public."User" DROP CONSTRAINT IF EXISTS "User_pkey";
ALTER TABLE IF EXISTS ONLY public."TransactionConsecutive" DROP CONSTRAINT IF EXISTS "TransactionConsecutive_pkey";
ALTER TABLE IF EXISTS ONLY public."TicketType" DROP CONSTRAINT IF EXISTS "TicketType_pkey";
ALTER TABLE IF EXISTS ONLY public."TicketPrinter" DROP CONSTRAINT IF EXISTS "TicketPrinter_pkey";
ALTER TABLE IF EXISTS ONLY public."SystemParameter" DROP CONSTRAINT IF EXISTS "SystemParameter_pkey";
ALTER TABLE IF EXISTS ONLY public."SystemLog" DROP CONSTRAINT IF EXISTS "SystemLog_pkey";
ALTER TABLE IF EXISTS ONLY public."SysConsecutivo" DROP CONSTRAINT IF EXISTS "SysConsecutivo_pkey";
ALTER TABLE IF EXISTS ONLY public."Seller" DROP CONSTRAINT IF EXISTS "Seller_pkey";
ALTER TABLE IF EXISTS ONLY public."Role" DROP CONSTRAINT IF EXISTS "Role_pkey";
ALTER TABLE IF EXISTS ONLY public."Resolution" DROP CONSTRAINT IF EXISTS "Resolution_pkey";
ALTER TABLE IF EXISTS ONLY public."Report" DROP CONSTRAINT IF EXISTS "Report_pkey";
ALTER TABLE IF EXISTS ONLY public."ReportSorts" DROP CONSTRAINT IF EXISTS "ReportSorts_pkey";
ALTER TABLE IF EXISTS ONLY public."ReportJoins" DROP CONSTRAINT IF EXISTS "ReportJoins_pkey";
ALTER TABLE IF EXISTS ONLY public."ReportFilters" DROP CONSTRAINT IF EXISTS "ReportFilters_pkey";
ALTER TABLE IF EXISTS ONLY public."ReportColumns" DROP CONSTRAINT IF EXISTS "ReportColumns_pkey";
ALTER TABLE IF EXISTS ONLY public."Quotation" DROP CONSTRAINT IF EXISTS "Quotation_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationState" DROP CONSTRAINT IF EXISTS "QuotationState_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationStateHistory" DROP CONSTRAINT IF EXISTS "QuotationStateHistory_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProduct" DROP CONSTRAINT IF EXISTS "QuotationProduct_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductVariable" DROP CONSTRAINT IF EXISTS "QuotationProductVariable_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductTax" DROP CONSTRAINT IF EXISTS "QuotationProductTax_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductPayment" DROP CONSTRAINT IF EXISTS "QuotationProductPayment_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationProductPassenger" DROP CONSTRAINT IF EXISTS "QuotationProductPassenger_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationPrintDefaultTemplate" DROP CONSTRAINT IF EXISTS "QuotationPrintDefaultTemplate_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationPrintCustomization" DROP CONSTRAINT IF EXISTS "QuotationPrintCustomization_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationManualService" DROP CONSTRAINT IF EXISTS "QuotationManualService_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationFormat" DROP CONSTRAINT IF EXISTS "QuotationFormat_pkey";
ALTER TABLE IF EXISTS ONLY public."QuotationCombo" DROP CONSTRAINT IF EXISTS "QuotationCombo_pkey";
ALTER TABLE IF EXISTS ONLY public."Provider" DROP CONSTRAINT IF EXISTS "Provider_pkey";
ALTER TABLE IF EXISTS ONLY public."ProviderType" DROP CONSTRAINT IF EXISTS "ProviderType_pkey";
ALTER TABLE IF EXISTS ONLY public."Product" DROP CONSTRAINT IF EXISTS "Product_pkey";
ALTER TABLE IF EXISTS ONLY public."Prestadora" DROP CONSTRAINT IF EXISTS "Prestadora_pkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotation" DROP CONSTRAINT IF EXISTS "PreQuotation_pkey";
ALTER TABLE IF EXISTS ONLY public."PreQuotationStateHistory" DROP CONSTRAINT IF EXISTS "PreQuotationStateHistory_pkey";
ALTER TABLE IF EXISTS ONLY public."Payment" DROP CONSTRAINT IF EXISTS "Payment_pkey";
ALTER TABLE IF EXISTS ONLY public."Menu" DROP CONSTRAINT IF EXISTS "Menu_pkey";
ALTER TABLE IF EXISTS ONLY public."MasterVariable" DROP CONSTRAINT IF EXISTS "MasterVariable_pkey";
ALTER TABLE IF EXISTS ONLY public."Invoices" DROP CONSTRAINT IF EXISTS "Invoices_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProduct" DROP CONSTRAINT IF EXISTS "InvoicesProduct_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductVariable" DROP CONSTRAINT IF EXISTS "InvoicesProductVariable_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductTax" DROP CONSTRAINT IF EXISTS "InvoicesProductTax_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductPayment" DROP CONSTRAINT IF EXISTS "InvoicesProductPayment_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductPasenger" DROP CONSTRAINT IF EXISTS "InvoicesProductPasenger_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductItinerary" DROP CONSTRAINT IF EXISTS "InvoicesProductItinerary_pkey";
ALTER TABLE IF EXISTS ONLY public."InvoicesProductCombo" DROP CONSTRAINT IF EXISTS "InvoicesProductCombo_pkey";
ALTER TABLE IF EXISTS ONLY public."InterfaceExtractParam" DROP CONSTRAINT IF EXISTS "InterfaceExtractParam_pkey";
ALTER TABLE IF EXISTS ONLY public."Implant" DROP CONSTRAINT IF EXISTS "Implant_pkey";
ALTER TABLE IF EXISTS ONLY public."GDS" DROP CONSTRAINT IF EXISTS "GDS_pkey";
ALTER TABLE IF EXISTS ONLY public."FormatCellCustomization" DROP CONSTRAINT IF EXISTS "FormatCellCustomization_pkey";
ALTER TABLE IF EXISTS ONLY public."ExecutionProcedure" DROP CONSTRAINT IF EXISTS "ExecutionProcedure_pkey";
ALTER TABLE IF EXISTS ONLY public."ExecutionPreset" DROP CONSTRAINT IF EXISTS "ExecutionPreset_pkey";
ALTER TABLE IF EXISTS ONLY public."EquivalenciasInterfaces_Log" DROP CONSTRAINT IF EXISTS "EquivalenciasInterfaces_Log_pkey";
ALTER TABLE IF EXISTS ONLY public."EquivalencesInterfaces" DROP CONSTRAINT IF EXISTS "EquivalencesInterfaces_pkey";
ALTER TABLE IF EXISTS ONLY public."DocumentResolution" DROP CONSTRAINT IF EXISTS "DocumentResolution_pkey";
ALTER TABLE IF EXISTS ONLY public."Currency" DROP CONSTRAINT IF EXISTS "Currency_pkey";
ALTER TABLE IF EXISTS ONLY public."CreditCard" DROP CONSTRAINT IF EXISTS "CreditCard_pkey";
ALTER TABLE IF EXISTS ONLY public."Countries" DROP CONSTRAINT IF EXISTS "Countries_pkey";
ALTER TABLE IF EXISTS ONLY public."Combo" DROP CONSTRAINT IF EXISTS "Combo_pkey";
ALTER TABLE IF EXISTS ONLY public."ComboProduct" DROP CONSTRAINT IF EXISTS "ComboProduct_pkey";
ALTER TABLE IF EXISTS ONLY public."ComboProductTax" DROP CONSTRAINT IF EXISTS "ComboProductTax_pkey";
ALTER TABLE IF EXISTS ONLY public."Client" DROP CONSTRAINT IF EXISTS "Client_pkey";
ALTER TABLE IF EXISTS ONLY public."Cities" DROP CONSTRAINT IF EXISTS "Cities_pkey";
ALTER TABLE IF EXISTS ONLY public."ChargeAndTax" DROP CONSTRAINT IF EXISTS "ChargeAndTax_pkey";
ALTER TABLE IF EXISTS ONLY public."CellCustomization" DROP CONSTRAINT IF EXISTS "CellCustomization_pkey";
ALTER TABLE IF EXISTS ONLY public."Branch" DROP CONSTRAINT IF EXISTS "Branch_pkey";
ALTER TABLE IF EXISTS ONLY public."BranchGDSInvoiceAuto" DROP CONSTRAINT IF EXISTS "BranchGDSInvoiceAuto_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingsGDS_log" DROP CONSTRAINT IF EXISTS "BookingsGDS_log_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingsGDSInvoiceAuto" DROP CONSTRAINT IF EXISTS "BookingsGDSInvoiceAuto_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductVariableGDS" DROP CONSTRAINT IF EXISTS "BookingProductVariableGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductTaxGDS" DROP CONSTRAINT IF EXISTS "BookingProductTaxGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductPaymentGDS" DROP CONSTRAINT IF EXISTS "BookingProductPaymentGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductPassangerGDS" DROP CONSTRAINT IF EXISTS "BookingProductPassangerGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductItineraryGDS" DROP CONSTRAINT IF EXISTS "BookingProductItineraryGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductGDS" DROP CONSTRAINT IF EXISTS "BookingProductGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingProductFEEGDS" DROP CONSTRAINT IF EXISTS "BookingProductFEEGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingGDS" DROP CONSTRAINT IF EXISTS "BookingGDS_pkey";
ALTER TABLE IF EXISTS ONLY public."BookingGDSInvoiceAutoLog" DROP CONSTRAINT IF EXISTS "BookingGDSInvoiceAutoLog_pkey";
ALTER TABLE IF EXISTS ONLY public."Attachment" DROP CONSTRAINT IF EXISTS "Attachment_pkey";
ALTER TABLE IF EXISTS ONLY public."Airports" DROP CONSTRAINT IF EXISTS "Airports_pkey";
ALTER TABLE IF EXISTS public."User" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."TransactionConsecutive" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."TicketType" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."TicketPrinter" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."SystemParameter" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."SystemLog" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."SysConsecutivo" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Seller" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Role" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Resolution" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ReportSorts" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ReportJoins" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ReportFilters" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ReportColumns" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Report" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationStateHistory" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationState" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationProductVariable" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationProductTax" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationProductPayment" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationProductPassenger" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationProduct" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationPrintDefaultTemplate" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationPrintCustomization" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationManualService" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationFormat" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."QuotationCombo" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Quotation" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ProviderType" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Provider" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Product" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Prestadora" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."PreQuotationStateHistory" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."PreQuotation" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Payment" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Menu" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."MasterVariable" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Master" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductVariable" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductTax" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductPayment" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductPasenger" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductItinerary" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProductCombo" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InvoicesProduct" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Invoices" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Interfaces" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."InterfaceExtractParam" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Implant" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."GDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."FormatCellCustomization" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ExecutionProcedure" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ExecutionPreset" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."EquivalenciasInterfaces_Log" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."EquivalencesInterfaces" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."DocumentResolution" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Currency" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."CreditCard" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Countries" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ComboProductTax" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ComboProduct" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Combo" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Client" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Cities" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."ChargeAndTax" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."CellCustomization" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BranchGDSInvoiceAuto" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Branch" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingsGDS_log" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingsGDSInvoiceAuto" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductVariableGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductTaxGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductPaymentGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductPassangerGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductItineraryGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingProductFEEGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingGDSInvoiceAutoLog" ALTER COLUMN "Id" DROP DEFAULT;
ALTER TABLE IF EXISTS public."BookingGDS" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Attachment" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."Airports" ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.seq_quotation_consecutivo;
DROP SEQUENCE IF EXISTS public."User_id_seq";
DROP TABLE IF EXISTS public."User";
DROP SEQUENCE IF EXISTS public."TransactionConsecutive_id_seq";
DROP TABLE IF EXISTS public."TransactionConsecutive";
DROP SEQUENCE IF EXISTS public."TicketType_id_seq";
DROP TABLE IF EXISTS public."TicketType";
DROP SEQUENCE IF EXISTS public."TicketPrinter_id_seq";
DROP SEQUENCE IF EXISTS public."SystemParameter_id_seq";
DROP SEQUENCE IF EXISTS public."SystemLog_id_seq";
DROP TABLE IF EXISTS public."SystemLog";
DROP SEQUENCE IF EXISTS public."SysConsecutivo_id_seq";
DROP TABLE IF EXISTS public."SysConsecutivo";
DROP SEQUENCE IF EXISTS public."Seller_id_seq";
DROP SEQUENCE IF EXISTS public."Role_id_seq";
DROP TABLE IF EXISTS public."Role";
DROP SEQUENCE IF EXISTS public."Resolution_id_seq";
DROP SEQUENCE IF EXISTS public."Report_id_seq";
DROP SEQUENCE IF EXISTS public."ReportSorts_id_seq";
DROP TABLE IF EXISTS public."ReportSorts";
DROP SEQUENCE IF EXISTS public."ReportJoins_id_seq";
DROP TABLE IF EXISTS public."ReportJoins";
DROP SEQUENCE IF EXISTS public."ReportFilters_id_seq";
DROP TABLE IF EXISTS public."ReportFilters";
DROP SEQUENCE IF EXISTS public."ReportColumns_id_seq";
DROP TABLE IF EXISTS public."ReportColumns";
DROP TABLE IF EXISTS public."Report";
DROP SEQUENCE IF EXISTS public."Quotation_id_seq";
DROP SEQUENCE IF EXISTS public."QuotationState_id_seq";
DROP SEQUENCE IF EXISTS public."QuotationStateHistory_id_seq";
DROP TABLE IF EXISTS public."QuotationStateHistory";
DROP TABLE IF EXISTS public."QuotationState";
DROP SEQUENCE IF EXISTS public."QuotationProduct_id_seq";
DROP SEQUENCE IF EXISTS public."QuotationProductVariable_id_seq";
DROP TABLE IF EXISTS public."QuotationProductVariable";
DROP SEQUENCE IF EXISTS public."QuotationProductTax_id_seq";
DROP TABLE IF EXISTS public."QuotationProductTax";
DROP SEQUENCE IF EXISTS public."QuotationProductPayment_id_seq";
DROP TABLE IF EXISTS public."QuotationProductPayment";
DROP SEQUENCE IF EXISTS public."QuotationProductPassenger_id_seq";
DROP TABLE IF EXISTS public."QuotationProductPassenger";
DROP TABLE IF EXISTS public."QuotationProduct";
DROP SEQUENCE IF EXISTS public."QuotationPrintDefaultTemplate_id_seq";
DROP TABLE IF EXISTS public."QuotationPrintDefaultTemplate";
DROP SEQUENCE IF EXISTS public."QuotationPrintCustomization_id_seq";
DROP TABLE IF EXISTS public."QuotationPrintCustomization";
DROP SEQUENCE IF EXISTS public."QuotationManualService_id_seq";
DROP TABLE IF EXISTS public."QuotationManualService";
DROP SEQUENCE IF EXISTS public."QuotationFormat_id_seq";
DROP TABLE IF EXISTS public."QuotationFormat";
DROP SEQUENCE IF EXISTS public."QuotationCombo_id_seq";
DROP TABLE IF EXISTS public."QuotationCombo";
DROP TABLE IF EXISTS public."Quotation";
DROP SEQUENCE IF EXISTS public."Provider_id_seq";
DROP SEQUENCE IF EXISTS public."ProviderType_id_seq";
DROP TABLE IF EXISTS public."ProviderType";
DROP TABLE IF EXISTS public."Provider";
DROP SEQUENCE IF EXISTS public."Product_id_seq";
DROP SEQUENCE IF EXISTS public."Prestadora_id_seq";
DROP TABLE IF EXISTS public."Prestadora";
DROP SEQUENCE IF EXISTS public."PreQuotation_id_seq";
DROP SEQUENCE IF EXISTS public."PreQuotationStateHistory_id_seq";
DROP TABLE IF EXISTS public."PreQuotationStateHistory";
DROP TABLE IF EXISTS public."PreQuotation";
DROP SEQUENCE IF EXISTS public."Payment_id_seq";
DROP TABLE IF EXISTS public."Payment";
DROP SEQUENCE IF EXISTS public."Menu_id_seq";
DROP SEQUENCE IF EXISTS public."Master_id_seq";
DROP SEQUENCE IF EXISTS public."MasterVariable_id_seq";
DROP TABLE IF EXISTS public."Master";
DROP SEQUENCE IF EXISTS public."Invoices_id_seq";
DROP SEQUENCE IF EXISTS public."InvoicesProduct_id_seq";
DROP SEQUENCE IF EXISTS public."InvoicesProductVariable_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductVariable";
DROP SEQUENCE IF EXISTS public."InvoicesProductTax_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductTax";
DROP SEQUENCE IF EXISTS public."InvoicesProductPayment_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductPayment";
DROP SEQUENCE IF EXISTS public."InvoicesProductPasenger_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductPasenger";
DROP SEQUENCE IF EXISTS public."InvoicesProductItinerary_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductItinerary";
DROP SEQUENCE IF EXISTS public."InvoicesProductCombo_id_seq";
DROP TABLE IF EXISTS public."InvoicesProductCombo";
DROP TABLE IF EXISTS public."InvoicesProduct";
DROP TABLE IF EXISTS public."Invoices";
DROP SEQUENCE IF EXISTS public."Interfaces_id_seq";
DROP TABLE IF EXISTS public."Interfaces";
DROP SEQUENCE IF EXISTS public."InterfaceExtractParam_id_seq";
DROP TABLE IF EXISTS public."InterfaceExtractParam";
DROP SEQUENCE IF EXISTS public."Implant_id_seq";
DROP SEQUENCE IF EXISTS public."GDS_id_seq";
DROP TABLE IF EXISTS public."GDS";
DROP SEQUENCE IF EXISTS public."FormatCellCustomization_id_seq";
DROP TABLE IF EXISTS public."FormatCellCustomization";
DROP SEQUENCE IF EXISTS public."ExecutionProcedure_id_seq";
DROP TABLE IF EXISTS public."ExecutionProcedure";
DROP SEQUENCE IF EXISTS public."ExecutionPreset_id_seq";
DROP TABLE IF EXISTS public."ExecutionPreset";
DROP SEQUENCE IF EXISTS public."EquivalenciasInterfaces_Log_id_seq";
DROP TABLE IF EXISTS public."EquivalenciasInterfaces_Log";
DROP SEQUENCE IF EXISTS public."EquivalencesInterfaces_id_seq";
DROP TABLE IF EXISTS public."EquivalencesInterfaces";
DROP SEQUENCE IF EXISTS public."DocumentResolution_id_seq";
DROP TABLE IF EXISTS public."DocumentResolution";
DROP SEQUENCE IF EXISTS public."Currency_id_seq";
DROP TABLE IF EXISTS public."Currency";
DROP SEQUENCE IF EXISTS public."CreditCard_id_seq";
DROP TABLE IF EXISTS public."CreditCard";
DROP SEQUENCE IF EXISTS public."Countries_id_seq";
DROP TABLE IF EXISTS public."Countries";
DROP SEQUENCE IF EXISTS public."Combo_id_seq";
DROP SEQUENCE IF EXISTS public."ComboProduct_id_seq";
DROP SEQUENCE IF EXISTS public."ComboProductTax_id_seq";
DROP TABLE IF EXISTS public."ComboProductTax";
DROP TABLE IF EXISTS public."ComboProduct";
DROP TABLE IF EXISTS public."Combo";
DROP SEQUENCE IF EXISTS public."Client_id_seq";
DROP TABLE IF EXISTS public."Client";
DROP SEQUENCE IF EXISTS public."Cities_id_seq";
DROP TABLE IF EXISTS public."Cities";
DROP SEQUENCE IF EXISTS public."ChargeAndTax_id_seq";
DROP TABLE IF EXISTS public."ChargeAndTax";
DROP SEQUENCE IF EXISTS public."CellCustomization_id_seq";
DROP TABLE IF EXISTS public."CellCustomization";
DROP SEQUENCE IF EXISTS public."Branch_id_seq";
DROP SEQUENCE IF EXISTS public."BranchGDSInvoiceAuto_id_seq";
DROP TABLE IF EXISTS public."BranchGDSInvoiceAuto";
DROP SEQUENCE IF EXISTS public."BookingsGDS_log_id_seq";
DROP TABLE IF EXISTS public."BookingsGDS_log";
DROP SEQUENCE IF EXISTS public."BookingsGDSInvoiceAuto_id_seq";
DROP TABLE IF EXISTS public."BookingsGDSInvoiceAuto";
DROP SEQUENCE IF EXISTS public."BookingProductVariableGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductVariableGDS";
DROP SEQUENCE IF EXISTS public."BookingProductTaxGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductTaxGDS";
DROP SEQUENCE IF EXISTS public."BookingProductPaymentGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductPaymentGDS";
DROP SEQUENCE IF EXISTS public."BookingProductPassangerGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductPassangerGDS";
DROP SEQUENCE IF EXISTS public."BookingProductItineraryGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductItineraryGDS";
DROP SEQUENCE IF EXISTS public."BookingProductGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductGDS";
DROP SEQUENCE IF EXISTS public."BookingProductFEEGDS_id_seq";
DROP TABLE IF EXISTS public."BookingProductFEEGDS";
DROP SEQUENCE IF EXISTS public."BookingGDS_id_seq";
DROP SEQUENCE IF EXISTS public."BookingGDSInvoiceAutoLog_Id_seq";
DROP TABLE IF EXISTS public."BookingGDSInvoiceAutoLog";
DROP TABLE IF EXISTS public."BookingGDS";
DROP SEQUENCE IF EXISTS public."Attachment_id_seq";
DROP TABLE IF EXISTS public."Attachment";
DROP SEQUENCE IF EXISTS public."Airports_id_seq";
DROP TABLE IF EXISTS public."Airports";
DROP PROCEDURE IF EXISTS public.spvariableeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spvariablecrear(IN p_code text, IN p_name text, IN p_acting_user_id integer, INOUT p_variable_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spvariableactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spusuarioeliminar(IN p_user_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spusuariocrear(IN p_name text, IN p_email text, IN p_password_hash text, IN p_role_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_ticket_printer_id integer, IN p_acting_user_id integer, INOUT p_user_id integer, INOUT p_mensaje_resultado text);
DROP FUNCTION IF EXISTS public.spusuarioconsultar(p_id integer, p_email text);
DROP PROCEDURE IF EXISTS public.spusuarioactualizar(IN p_user_id integer, IN p_name text, IN p_email text, IN p_password_hash text, IN p_role_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_ticket_printer_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spticketprintereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spticketprintercrear(IN p_code text, IN p_name text, IN p_email text, IN p_acting_user_id integer, INOUT p_printer_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spticketprinteractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_email text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spsysconsecutivoeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spsysconsecutivocrear(IN p_codigo character varying, IN p_nombre character varying, IN p_branch_id integer, IN p_implant_id integer, IN p_fuente character varying, IN p_serie character varying, IN p_consecutivo bigint, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spsysconsecutivoactualizar(IN p_id integer, IN p_codigo character varying, IN p_nombre character varying, IN p_branch_id integer, IN p_implant_id integer, IN p_fuente character varying, IN p_serie character varying, IN p_consecutivo bigint, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spsellereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spsellercrear(IN p_code text, IN p_name text, IN p_email text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_seller_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spselleractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_email text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spresolucioneliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spresolucioncrear(IN p_code text, IN p_name text, IN p_date timestamp with time zone, IN p_expira timestamp with time zone, IN p_inicial bigint, IN p_end bigint, IN p_autoriza text, IN p_prefijo text, IN p_alerta integer, IN p_day integer, IN p_permitir boolean, IN p_activo boolean, IN p_acting_user_id integer, INOUT p_resolution_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spresolucionactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_date timestamp with time zone, IN p_expira timestamp with time zone, IN p_inicial bigint, IN p_end bigint, IN p_autoriza text, IN p_prefijo text, IN p_alerta integer, IN p_day integer, IN p_permitir boolean, IN p_activo boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprovidertypeeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprovidertypecrear(IN p_code text, IN p_name text, IN p_is_airline boolean, IN p_active boolean, IN p_acting_user_id integer, INOUT p_prov_type_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprovidertypeactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_is_airline boolean, IN p_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproveedoreliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproveedorcrear(IN p_code text, IN p_name text, IN p_contact_info text, IN p_commission_config jsonb, IN p_provider_type_id integer, IN p_airline_code text, IN p_sigla text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_provider_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproveedoractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_contact_info text, IN p_commission_config jsonb, IN p_provider_type_id integer, IN p_airline_code text, IN p_sigla text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproductoeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproductocrear(IN p_code text, IN p_type text, IN p_description text, IN p_base_price double precision, IN p_cost double precision, IN p_billing_concept text, IN p_service_type text, IN p_acting_user_id integer, INOUT p_product_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spproductoactualizar(IN p_id integer, IN p_code text, IN p_type text, IN p_description text, IN p_base_price double precision, IN p_cost double precision, IN p_billing_concept text, IN p_service_type text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprestadoraeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprestadoracrear(IN p_code text, IN p_name text, IN p_category text, IN p_location text, IN p_provider_id integer, IN p_type text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_prestadora_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spprestadoraactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_category text, IN p_location text, IN p_provider_id integer, IN p_type text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spparametereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spparametercrear(IN p_code text, IN p_name text, IN p_value text, IN p_acting_user_id integer, INOUT p_parameter_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spparameteractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_value text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spmonedalistar(IN p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spmonedaeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spmonedacrear(IN p_code text, IN p_name text, IN p_exchange_rate double precision, IN p_decimals integer, IN p_acting_user_id integer, INOUT p_currency_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spmonedaactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_exchange_rate double precision, IN p_decimals integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spmaestroimportar(IN p_tipo text, IN p_text_data text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP FUNCTION IF EXISTS public.sploglistar(p_limit integer, p_offset integer, p_module text, p_user_id integer);
DROP PROCEDURE IF EXISTS public.spinvoiceseliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spinvoicescrear(IN p_data jsonb, IN p_acting_user_id integer, INOUT p_invoice_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spinvoicesactualizar(IN p_id integer, IN p_data jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spinterfacesabre(IN p_op text, IN p_booking text, IN p_file text);
DROP PROCEDURE IF EXISTS public.spinterfacefile(IN op text, IN booking text, IN file text);
DROP PROCEDURE IF EXISTS public.spinterfaceamadeus(IN p_op text, IN p_booking text, IN p_file text);
DROP PROCEDURE IF EXISTS public.spimpuestoeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spimpuestocrear(IN p_code text, IN p_name text, IN p_type text, IN p_value_type text, IN p_value numeric, IN p_is_editable boolean, IN p_orden integer, IN p_product_ids jsonb, IN p_target_tax_id integer, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_tax_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spimpuestoactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_type text, IN p_value_type text, IN p_value numeric, IN p_is_editable boolean, IN p_orden integer, IN p_product_ids jsonb, IN p_target_tax_id integer, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spimplanteliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spimplantcrear(IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_branch_id integer, IN p_resolution_id integer, IN p_invoice_template bytea, IN p_invoice_template_config jsonb, IN p_invoice_html_template text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_implant_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spimplantactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_branch_id integer, IN p_resolution_id integer, IN p_invoice_template bytea, IN p_invoice_template_config jsonb, IN p_invoice_html_template text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spexportquotation(IN quotation_id text, IN user_id integer, INOUT mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spexportinvoices(IN envoices_id text, IN user_id integer, INOUT mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcotizacioneliminar(IN p_quotation_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcotizacionduplicar(IN p_quotation_id integer, IN p_acting_user_id integer, INOUT p_new_quotation_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcotizacionactualizarestadomanual(IN p_quotation_id integer, IN p_state text, IN p_description text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcotizacionactualizarestado(IN p_response jsonb);
DROP PROCEDURE IF EXISTS public.spcotizacionactualizar(IN p_id integer, IN p_data jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcomboeliminar(IN p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcombocrear(IN p_code text, IN p_name text, IN p_cupos integer, IN p_currency_id integer, IN p_products jsonb, IN p_acting_user_id integer, INOUT p_combo_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcomboactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_cupos integer, IN p_currency_id integer, IN p_products jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spclienteeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spclientecrear(IN p_name text, IN p_document text, IN p_contact_info text, IN p_address text, IN p_mandatory_variables jsonb, IN p_acting_user_id integer, IN p_seller_id integer, IN p_is_active boolean, INOUT p_client_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spclienteactualizar(IN p_id integer, IN p_name text, IN p_document text, IN p_contact_info text, IN p_address text, IN p_mandatory_variables jsonb, IN p_acting_user_id integer, IN p_seller_id integer, IN p_is_active boolean, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spcellcustomizationupsert(IN p_code text, IN p_name text, IN p_value text, IN p_branch_id integer, IN p_implant_id integer);
DROP PROCEDURE IF EXISTS public.spcellcustomizationdelete(IN p_code text, IN p_branch_id integer, IN p_implant_id integer);
DROP PROCEDURE IF EXISTS public.spbrancheliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spbranchcrear(IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_resolution_id integer, IN p_invoice_template bytea, IN p_invoice_template_config jsonb, IN p_invoice_html_template text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_branch_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public.spbranchactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_resolution_id integer, IN p_invoice_template bytea, IN p_invoice_template_config jsonb, IN p_invoice_html_template text, IN p_is_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTransactionConsecutiveEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTransactionConsecutiveCrear"(IN p_transaction_type text, IN p_description text, IN p_prefix text, IN p_initial_number integer, IN p_branch_id integer, IN p_implant_id integer, IN p_is_active boolean, IN p_user_id integer, INOUT p_consecutivo_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTransactionConsecutiveActualizar"(IN p_id integer, IN p_transaction_type text, IN p_description text, IN p_prefix text, IN p_initial_number integer, IN p_current_number integer, IN p_branch_id integer, IN p_implant_id integer, IN p_is_active boolean, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTicketTypeEliminar"(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTicketTypeCrear"(IN p_code text, IN p_name text, IN p_description text, IN p_isactive boolean, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spTicketTypeActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_description text, IN p_isactive boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spSiteModuleMasterToggle"(IN p_type text, IN p_id integer, IN p_active boolean);
DROP PROCEDURE IF EXISTS public."spRoleGuardarYPermisos"(IN p_id integer, IN p_name character varying, IN p_description text, IN p_permissions jsonb, OUT p_res_id integer, OUT p_message text);
DROP PROCEDURE IF EXISTS public."spQuotationStateEliminar"(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spQuotationStateCrear"(IN p_code text, IN p_name text, IN p_color text, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spQuotationStateActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_color text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spPreCotizacionCrear"(IN p_data jsonb, IN p_acting_user_id integer, OUT p_pre_quotation_id integer, OUT p_consecutivo integer, OUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spPreCotizacionConvertir"(IN p_pre_quotation_id integer, IN p_quotation_id integer, IN p_acting_user_id integer, IN p_notice_response text, OUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spPaymentEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spPaymentCrear"(IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spPaymentActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_inactive boolean, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spLogRegistrar"(IN p_user_id integer, IN p_module text, IN p_action text, IN p_description text, IN p_metadata jsonb, INOUT p_temp_id integer);
DROP PROCEDURE IF EXISTS public."spLimpiarMovimientosProduccion"(INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spInterfaceSabre"(IN p_op text, IN p_booking text, IN p_file text);
DROP PROCEDURE IF EXISTS public."spInterfaceFile"(IN op text, IN booking text, IN file text);
DROP PROCEDURE IF EXISTS public."spImportQuotation"(IN p_text_data text, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spImportInvoices"(IN p_text_data text, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spFacturaActualizarEstado"(IN p_results jsonb);
DROP PROCEDURE IF EXISTS public."spEquivalencesInterfacesEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_success boolean);
DROP PROCEDURE IF EXISTS public."spEquivalencesInterfacesCrear"(IN p_id_interfaces integer, IN p_id_master integer, IN p_cd_maestro text, IN p_cd_codigo text, IN p_cd_codigointe text, IN p_user_id integer, INOUT p_new_id integer);
DROP PROCEDURE IF EXISTS public."spEquivalencesInterfacesConsultar"(IN p_id_interfaces integer, IN p_id_master integer);
DROP PROCEDURE IF EXISTS public."spDocumentResolutionEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spDocumentResolutionCrear"(IN p_branch_id integer, IN p_implant_id integer, IN p_resolution_number text, IN p_initial_number integer, IN p_final_number integer, IN p_resolution_date timestamp without time zone, IN p_prefix text, IN p_expiration_date timestamp without time zone, IN p_is_active boolean, IN p_user_id integer, INOUT p_resolution_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spDocumentResolutionActualizar"(IN p_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_resolution_number text, IN p_initial_number integer, IN p_final_number integer, IN p_current_number integer, IN p_resolution_date timestamp without time zone, IN p_prefix text, IN p_expiration_date timestamp without time zone, IN p_is_active boolean, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCreditCardEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCreditCardCrear"(IN p_code text, IN p_name text, IN p_type text, IN p_user_id integer, INOUT p_card_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCreditCardActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_type text, IN p_inactive boolean, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountryEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountryCrear"(IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountryActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountriesEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountriesCrear"(IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCountriesActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCotizacionCrear"(IN p_data jsonb, IN p_acting_user_id integer, INOUT p_quotation_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCityEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCityCrear"(IN p_code text, IN p_name text, IN p_countriesid integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spCityActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_countriesid integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spAirportEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spAirportCrear"(IN p_code text, IN p_name text, IN p_citiesid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text);
DROP PROCEDURE IF EXISTS public."spAirportActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_citiesid integer, IN p_user_id integer, INOUT p_mensaje_resultado text);
DROP FUNCTION IF EXISTS public.fnvariablelistar();
DROP TABLE IF EXISTS public."MasterVariable";
DROP FUNCTION IF EXISTS public.fnusuariolistar();
DROP FUNCTION IF EXISTS public.fnticketprinterlistar();
DROP TABLE IF EXISTS public."TicketPrinter";
DROP FUNCTION IF EXISTS public.fnsysconsecutivolistar();
DROP FUNCTION IF EXISTS public.fnsellerlistar();
DROP TABLE IF EXISTS public."Seller";
DROP FUNCTION IF EXISTS public.fnresolucionlistar();
DROP TABLE IF EXISTS public."Resolution";
DROP FUNCTION IF EXISTS public.fnreservabuscarparafacturar(p_client text, p_passenger text, p_record text, p_ticket text, p_airline text);
DROP FUNCTION IF EXISTS public.fnprovidertypelistar();
DROP FUNCTION IF EXISTS public.fnproveedorlistar();
DROP FUNCTION IF EXISTS public.fnproductolistar();
DROP TABLE IF EXISTS public."Product";
DROP FUNCTION IF EXISTS public.fnprestadoralistar();
DROP FUNCTION IF EXISTS public.fnparameterlistar();
DROP TABLE IF EXISTS public."SystemParameter";
DROP FUNCTION IF EXISTS public.fnmonedalistar(p_id integer);
DROP FUNCTION IF EXISTS public.fnmenuall();
DROP FUNCTION IF EXISTS public.fnmenu();
DROP TABLE IF EXISTS public."Menu";
DROP FUNCTION IF EXISTS public.fninvoiceslistar();
DROP FUNCTION IF EXISTS public.fnimpuestolistar();
DROP FUNCTION IF EXISTS public.fnimplantlistar();
DROP TABLE IF EXISTS public."Implant";
DROP FUNCTION IF EXISTS public.fncotizacionlistar(p_referencia character varying, p_fecha_desde date, p_fecha_hasta date, p_cliente character varying, p_elaborado_por character varying, p_monto_total numeric, p_estado character varying);
DROP FUNCTION IF EXISTS public.fncotizacionhistorial(p_referencia character varying, p_fecha_desde date, p_fecha_hasta date, p_cliente character varying, p_elaborado_por character varying, p_monto_total numeric, p_estado character varying, p_reserva character varying, p_pasajero character varying);
DROP FUNCTION IF EXISTS public.fncotizacion(p_quotation_id integer);
DROP FUNCTION IF EXISTS public.fncombolistar();
DROP FUNCTION IF EXISTS public.fnclientelistar();
DROP FUNCTION IF EXISTS public.fncellcustomizationlistar(p_branch_id integer, p_implant_id integer);
DROP FUNCTION IF EXISTS public.fnbranchlistar();
DROP TABLE IF EXISTS public."Branch";
DROP FUNCTION IF EXISTS public.fn_obtener_historial_estados(p_quotation_id integer);
DROP FUNCTION IF EXISTS public.fn_obtener_decimales_moneda(p_currency_code text);
DROP FUNCTION IF EXISTS public."fnUserPermissions"(p_user_id integer);
DROP FUNCTION IF EXISTS public."fnTransactionConsecutiveListar"();
DROP FUNCTION IF EXISTS public."fnTicketTypeListar"();
DROP FUNCTION IF EXISTS public."fnRptCotizacion"(p_id_ini integer, p_id_fin integer);
DROP FUNCTION IF EXISTS public."fnRoleListar"();
DROP FUNCTION IF EXISTS public."fnReportDinamic"(p_report_id integer, p_filter_values json);
DROP FUNCTION IF EXISTS public."fnQuotationStateListar"();
DROP FUNCTION IF EXISTS public."fnQuitarEspeciales"(texto text);
DROP FUNCTION IF EXISTS public."fnPreCotizacionListar"(p_search text, p_state text, p_branch_id integer);
DROP FUNCTION IF EXISTS public."fnPaymentListar"();
DROP FUNCTION IF EXISTS public."fnObtenerSiguienteConsecutivo"(p_transaction_type text, p_branch_id integer, p_implant_id integer);
DROP FUNCTION IF EXISTS public."fnMasterList"();
DROP FUNCTION IF EXISTS public."fnInterfacesList"();
DROP FUNCTION IF EXISTS public."fnInterfaceExtractParamValue"(p_interface_id integer, p_field_code text, p_booking_file text);
DROP FUNCTION IF EXISTS public."fnGetSQLServerConfig"();
DROP FUNCTION IF EXISTS public."fnEquivalencesInterfacesConsultar"(p_id_interfaces integer, p_id_master integer);
DROP FUNCTION IF EXISTS public."fnEquivalenceInterface"(p_id_interface integer, p_id_master integer, p_value text);
DROP FUNCTION IF EXISTS public."fnDocumentResolutionListar"();
DROP FUNCTION IF EXISTS public."fnCreditCardValidar"(p_referencia text);
DROP FUNCTION IF EXISTS public."fnCreditCardListar"();
DROP FUNCTION IF EXISTS public."fnCountryListar"();
DROP FUNCTION IF EXISTS public."fnCityListar"();
DROP FUNCTION IF EXISTS public."fnAirportListar"();
--
-- Name: fnAirportListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnAirportListar"() RETURNS TABLE(id integer, code text, name text, "citiesId" integer, "cityName" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT a.id, a.code::text, a.name::text, a."citiesId", c.name::text FROM public."Airports" a LEFT JOIN public."Cities" c ON a."citiesId" = c.id ORDER BY a.name ASC;
END; $$;


--
-- Name: fnCityListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnCityListar"() RETURNS TABLE(id integer, code text, name text, "countriesId" integer, statecode text, iata text, "countryName" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT c.id, c.code::text, c.name::text, c."countriesId", c.statecode::text, c.iata::text, co.name::text FROM public."Cities" c LEFT JOIN public."Countries" co ON c."countriesId" = co.id ORDER BY c.name ASC;
END; $$;


--
-- Name: fnCountryListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnCountryListar"() RETURNS TABLE(id integer, code text, name text, dane text, region text, prefix text, "curencyId" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT c.id, c.code::text, c.name::text, c.dane::text, c.region::text, c.prefix::text, c."curencyId" FROM public."Countries" c ORDER BY c.id ASC;
END; $$;


--
-- Name: fnCreditCardListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnCreditCardListar"() RETURNS TABLE(id integer, code text, name text, type text, inactive boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.code,
        c.name,
        c.type,
        c.inactive
    FROM public."CreditCard" c
    ORDER BY c.id ASC;
END;
$$;


--
-- Name: fnCreditCardValidar(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnCreditCardValidar"(p_referencia text) RETURNS TABLE(es_valido boolean, codigo_tarjeta text, numero_tarjeta text, tarjeta_id integer, nombre_tarjeta text, mensaje text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_code text;
    v_number text;
    v_id integer;
    v_name text;
BEGIN
    IF p_referencia IS NULL OR TRIM(p_referencia) = '' THEN
        RETURN QUERY SELECT true, ''::text, ''::text, NULL::integer, ''::text, 'OK'::text;
        RETURN;
    END IF;

    p_referencia := TRIM(p_referencia);

    -- Si tiene al menos 2 caracteres iniciales que son letras (ej: VI0000000000007023)
    IF length(p_referencia) >= 2 AND substring(p_referencia from 1 for 2) ~ '^[A-Za-z]{2}$' THEN
        v_code := UPPER(substring(p_referencia from 1 for 2));
        v_number := substring(p_referencia from 3);

        SELECT c.id, c.name INTO v_id, v_name
        FROM public."CreditCard" c
        WHERE UPPER(TRIM(c.code)) = v_code AND c.inactive = false
        LIMIT 1;

        IF v_id IS NOT NULL THEN
            RETURN QUERY SELECT true, v_code, v_number, v_id, v_name, 'SUCCESS'::text;
        ELSE
            RETURN QUERY SELECT false, v_code, v_number, NULL::integer, ''::text, ('El código de tarjeta "' || v_code || '" no existe en el Maestro de Tarjetas de Crédito.')::text;
        END IF;
    ELSE
        -- Si son solo números o no empieza por código de 2 letras
        RETURN QUERY SELECT true, ''::text, p_referencia, NULL::integer, ''::text, 'Sin código de tipo de tarjeta'::text;
    END IF;
END;
$_$;


--
-- Name: fnDocumentResolutionListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnDocumentResolutionListar"() RETURNS TABLE(id integer, "branchId" integer, "branchName" text, "implantId" integer, "implantName" text, "resolutionNumber" text, "initialNumber" integer, "finalNumber" integer, "currentNumber" integer, "resolutionDate" timestamp without time zone, prefix text, "expirationDate" timestamp without time zone, "isActive" boolean, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dr.id,
        dr."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        dr."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        dr."resolutionNumber"::text,
        dr."initialNumber",
        dr."finalNumber",
        dr."currentNumber",
        dr."resolutionDate",
        COALESCE(dr.prefix, '')::text,
        dr."expirationDate",
        dr."isActive",
        dr."createdAt"
    FROM public."DocumentResolution" dr
    LEFT JOIN public."Branch" b ON b.id = dr."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = dr."implantId"
    ORDER BY dr.id DESC;
END;
$$;


--
-- Name: fnEquivalenceInterface(integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnEquivalenceInterface"(p_id_interface integer, p_id_master integer, p_value text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_equivalence TEXT;
    v_master_code TEXT;
BEGIN
    -- Si el valor es nulo o vacío, retornamos el mismo valor
    IF p_value IS NULL OR trim(p_value) = '' THEN
        RETURN p_value;
    END IF;

    -- Buscamos el equivalente en la tabla EquivalencesInterfaces
    SELECT cd_codigo 
    INTO v_equivalence
    FROM public."EquivalencesInterfaces"
    WHERE id_interfaces = p_id_interface
      AND id_master = p_id_master
      AND cd_codigoInte = p_value
    LIMIT 1;

    -- Si no se encuentra equivalencia:
    IF v_equivalence IS NULL OR trim(v_equivalence) = '' THEN
        -- Si corresponde al maestro de Impuestos (ChargeAndTax), mapear por defecto a 'OTR' (Otros Impuestos)
        SELECT code INTO v_master_code FROM public."Master" WHERE id = p_id_master LIMIT 1;
        IF v_master_code = 'ChargeAndTax' THEN
            RETURN 'OTR';
        ELSE
            RETURN p_value;
        END IF;
    ELSE
        RETURN v_equivalence;
    END IF;
END;
$$;


--
-- Name: fnEquivalencesInterfacesConsultar(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnEquivalencesInterfacesConsultar"(p_id_interfaces integer DEFAULT NULL::integer, p_id_master integer DEFAULT NULL::integer) RETURNS TABLE(id integer, id_interfaces integer, id_master integer, cd_maestro text, cd_codigo text, cd_codigointe text, dt_fecha timestamp without time zone, interface_name text, master_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.id_interfaces,
        e.id_master,
        e.cd_maestro,
        e.cd_codigo,
        e.cd_codigoInte,
        e.dt_fecha,
        i.name AS interface_name,
        m.name AS master_name
    FROM public."EquivalencesInterfaces" e
    JOIN public."Interfaces" i ON e.id_interfaces = i.id
    JOIN public."Master" m ON e.id_master = m.id
    WHERE (p_id_interfaces IS NULL OR e.id_interfaces = p_id_interfaces)
      AND (p_id_master IS NULL OR e.id_master = p_id_master)
    ORDER BY e.dt_fecha DESC;
END;
$$;


--
-- Name: fnGetSQLServerConfig(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnGetSQLServerConfig"() RETURNS TABLE(servidor text, usuario text, clave text, base_datos text, puerto text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT value FROM "SystemParameter" WHERE code = 'ServidorSQLServer') as servidor,
        (SELECT value FROM "SystemParameter" WHERE code = 'UsuarioSQLServer') as usuario,
        (SELECT value FROM "SystemParameter" WHERE code = 'ClaveSQLServer') as clave,
        (SELECT value FROM "SystemParameter" WHERE code = 'BaseSQLServer') as base_datos,
        (SELECT value FROM "SystemParameter" WHERE code = 'PuertoSQLServer') as puerto;
END;
$$;


--
-- Name: fnInterfaceExtractParamValue(integer, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnInterfaceExtractParamValue"(p_interface_id integer, p_field_code text, p_booking_file text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_prefix TEXT;
    v_delimiter TEXT;
    v_start_pos INTEGER;
    v_length INTEGER;
    v_line TEXT;
    v_extracted TEXT := NULL;
    v_pos INTEGER;
    v_lines TEXT[];
    i INTEGER;
BEGIN
    IF p_booking_file IS NULL OR TRIM(p_booking_file) = '' THEN
        RETURN NULL;
    END IF;

    -- 1. Buscar regla parametrizada para la interfaz y código de campo
    SELECT "prefix", "delimiter", "startPosition", "length"
    INTO v_prefix, v_delimiter, v_start_pos, v_length
    FROM public."InterfaceExtractParam"
    WHERE "interfaceId" = p_interface_id
      AND UPPER("fieldCode") = UPPER(TRIM(p_field_code))
      AND "isActive" = TRUE
    ORDER BY id DESC
    LIMIT 1;

    -- Fallbacks por defecto si no hay regla configurada
    IF v_prefix IS NULL OR v_prefix = '' THEN
        IF UPPER(TRIM(p_field_code)) = 'CLIENT' THEN
            v_prefix := 'RM*NC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_prefix := 'RM*VEN-';
        ELSIF UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_prefix := 'RM*TK-';
        ELSIF UPPER(TRIM(p_field_code)) = 'BRANCH' THEN
            v_prefix := 'RM*SUC-';
        ELSIF UPPER(TRIM(p_field_code)) = 'IMPLANT' THEN
            v_prefix := 'RM*IMP-';
        ELSE
            RETURN NULL;
        END IF;
    END IF;

    IF v_delimiter IS NULL THEN
        v_delimiter := '-';
    END IF;

    -- 2. Dividir archivo en líneas
    v_lines := string_to_array(p_booking_file, E'\n');

    -- 3. Recorrer líneas buscando el prefijo constante
    FOR i IN 1..array_length(v_lines, 1) LOOP
        v_line := TRIM(v_lines[i]);
        v_line := REPLACE(v_line, E'\r', '');

        v_pos := POSITION(v_prefix IN v_line);
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'SELLER' THEN
            v_pos := POSITION('RM*VE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*VE-'; END IF;
        END IF;
        IF v_pos = 0 AND UPPER(TRIM(p_field_code)) = 'TICKETPRINTER' THEN
            v_pos := POSITION('RM*ASE-' IN v_line);
            IF v_pos > 0 THEN v_prefix := 'RM*ASE-'; END IF;
        END IF;
        IF v_pos > 0 THEN
            v_extracted := SUBSTRING(v_line FROM v_pos + CHAR_LENGTH(v_prefix));
            v_extracted := TRIM(v_extracted);

            IF v_delimiter IS NOT NULL AND v_delimiter <> '' THEN
                v_pos := POSITION(v_delimiter IN v_extracted);
                IF v_pos > 1 THEN
                    v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_pos - 1);
                END IF;
            END IF;

            IF v_length IS NOT NULL AND v_length > 0 AND CHAR_LENGTH(v_extracted) > v_length THEN
                v_extracted := SUBSTRING(v_extracted FROM 1 FOR v_length);
            END IF;

            v_extracted := TRIM(v_extracted);
            IF v_extracted <> '' THEN
                RETURN v_extracted;
            END IF;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$;


--
-- Name: fnInterfacesList(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnInterfacesList"() RETURNS TABLE(id integer, code text, name text, inactivo boolean, bl_genera_archivoplano boolean, ds_storedprocedure_archivoplano text, bl_job boolean, ds_namejob text, bl_facturador boolean, id_gds integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.code,
        i.name,
        i.inactivo,
        i.bl_genera_archivoplano,
        i.ds_storedprocedure_archivoplano,
        i.bl_job,
        i.ds_namejob,
        i.bl_facturador,
        i.id_gds
    FROM public."Interfaces" i
    ORDER BY i.name ASC;
END;
$$;


--
-- Name: fnMasterList(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnMasterList"() RETURNS TABLE(id integer, code text, name text, inactivo boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.code,
        m.name,
        m.inactivo
    FROM public."Master" m
    ORDER BY m.name ASC;
END;
$$;


--
-- Name: fnObtenerSiguienteConsecutivo(text, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnObtenerSiguienteConsecutivo"(p_transaction_type text, p_branch_id integer DEFAULT NULL::integer, p_implant_id integer DEFAULT NULL::integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rec RECORD;
    v_next_val integer;
    v_prefix text := '';
    v_res_json jsonb;
BEGIN
    p_transaction_type := UPPER(TRIM(COALESCE(p_transaction_type, 'INVOICE')));

    -- 1. Intentar buscar un consecutivo específico para la combinación sucursal e implante
    SELECT * INTO v_rec
    FROM public."TransactionConsecutive"
    WHERE UPPER("transactionType") = p_transaction_type
      AND "isActive" = true
      AND (
          (p_branch_id IS NOT NULL AND "branchId" = p_branch_id)
          OR ("branchId" IS NULL)
      )
      AND (
          (p_implant_id IS NOT NULL AND "implantId" = p_implant_id)
          OR ("implantId" IS NULL)
      )
    ORDER BY 
        CASE WHEN "branchId" = p_branch_id THEN 1 ELSE 2 END,
        CASE WHEN "implantId" = p_implant_id THEN 1 ELSE 2 END,
        id ASC
    LIMIT 1
    FOR UPDATE;

    -- Si existe un registro configurado
    IF v_rec.id IS NOT NULL THEN
        v_next_val := v_rec."currentNumber";
        v_prefix := COALESCE(v_rec.prefix, '');

        -- Incrementar atómicamente para la siguiente transacción
        UPDATE public."TransactionConsecutive"
        SET "currentNumber" = "currentNumber" + 1
        WHERE id = v_rec.id;
    ELSE
        -- Fallback si no existe parámetro de consecutivo configurado todavía
        v_prefix := CASE 
            WHEN p_transaction_type = 'INVOICE' THEN 'INV'
            WHEN p_transaction_type = 'CREDIT_NOTE' THEN 'NC'
            WHEN p_transaction_type = 'QUOTATION' THEN 'COT'
            ELSE 'DOC'
        END;

        -- Usar la secuencia PostgreSQL si no hay registro manual
        v_next_val := nextval('public."Invoices_id_seq"');
    END IF;

    v_res_json := jsonb_build_object(
        'consecutivoNumber', v_next_val,
        'prefix', v_prefix,
        'formattedConsecutive', CASE WHEN v_prefix <> '' THEN v_prefix || '-' || v_next_val::text ELSE v_next_val::text END
    );

    RETURN v_res_json;
END;
$$;


--
-- Name: fnPaymentListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnPaymentListar"() RETURNS TABLE(id integer, code text, name text, iscash boolean, iscredit boolean, inactive boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.id, p.code, p.name, p.iscash, p.iscredit, p.inactive FROM public."Payment" p ORDER BY p.id ASC;
END; $$;


--
-- Name: fnPreCotizacionListar(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnPreCotizacionListar"(p_search text DEFAULT NULL::text, p_state text DEFAULT NULL::text, p_branch_id integer DEFAULT NULL::integer) RETURNS TABLE(id integer, consecutivo integer, client_name text, client_id integer, header_description text, provider_id integer, provider_name text, ticket_printer_id integer, ticket_printer_name text, seller_id integer, seller_name text, branch_id integer, branch_name text, pre_quotation_type text, quotation_notice text, notice_response text, start_date timestamp without time zone, end_date timestamp without time zone, custom_fields jsonb, state text, user_id integer, user_name text, created_at timestamp without time zone, converted_quotation_id integer, converted_internal_number text, converted_at timestamp without time zone, converted_user_name text, invoice_number text, elapsed_minutes integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.consecutivo,
        COALESCE(c.name, p."clientNameText", 'Cliente sin nombre')::TEXT AS client_name,
        p."clientId",
        COALESCE(p."headerDescription", '')::TEXT,
        p."providerId",
        COALESCE(pr.name, '')::TEXT AS provider_name,
        p."ticketPrinterId",
        COALESCE(tp.name, '')::TEXT AS ticket_printer_name,
        p."sellerId",
        COALESCE(s.name, '')::TEXT AS seller_name,
        p."branchId",
        COALESCE(b.name, '')::TEXT AS branch_name,
        COALESCE(p."preQuotationType", 'General')::TEXT,
        COALESCE(p."quotationNotice", '')::TEXT,
        COALESCE(p."noticeResponse", '')::TEXT,
        p."startDate",
        p."endDate",
        COALESCE(p."customFields", '{}'::jsonb),
        p.state::TEXT,
        p."userId",
        COALESCE(u.name, 'Sistema')::TEXT AS user_name,
        p."createdAt",
        p."convertedQuotationId",
        COALESCE(q."internalNumber", '')::TEXT AS converted_internal_number,
        p."convertedAt",
        COALESCE(cu.name, '')::TEXT AS converted_user_name,
        ''::TEXT AS invoice_number,
        (EXTRACT(EPOCH FROM (COALESCE(p."convertedAt", CURRENT_TIMESTAMP) - p."createdAt")) / 60)::INT AS elapsed_minutes
    FROM public."PreQuotation" p
    LEFT JOIN public."Client" c ON p."clientId" = c.id
    LEFT JOIN public."Provider" pr ON p."providerId" = pr.id
    LEFT JOIN public."TicketPrinter" tp ON p."ticketPrinterId" = tp.id
    LEFT JOIN public."Seller" s ON p."sellerId" = s.id
    LEFT JOIN public."Branch" b ON p."branchId" = b.id
    LEFT JOIN public."User" u ON p."userId" = u.id
    LEFT JOIN public."User" cu ON p."convertedUserId" = cu.id
    LEFT JOIN public."Quotation" q ON p."convertedQuotationId" = q.id
    WHERE (p_branch_id IS NULL OR p_branch_id = 0 OR p."branchId" = p_branch_id)
      AND (p_state IS NULL OR p_state = '' OR p.state = p_state)
      AND (
        p_search IS NULL OR p_search = '' OR
        p.consecutivo::TEXT ILIKE '%' || TRIM(p_search) || '%' OR
        c.name ILIKE '%' || TRIM(p_search) || '%' OR
        p."clientNameText" ILIKE '%' || TRIM(p_search) || '%' OR
        p."headerDescription" ILIKE '%' || TRIM(p_search) || '%' OR
        p."quotationNotice" ILIKE '%' || TRIM(p_search) || '%'
      )
    ORDER BY p.id DESC;
END;
$$;


--
-- Name: fnQuitarEspeciales(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnQuitarEspeciales"(texto text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    IF texto IS NULL THEN
        RETURN NULL;
    END IF;

    -- Reemplaza cualquier carácter que NO sea letra, número o espacio por un espacio ' '
    -- Incluye soporte para letras con tildes y ñ (a-zA-Z0-9áéíóúÁÉÍÓÚñÑ)
    RETURN REGEXP_REPLACE(texto, '[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]', ' ', 'g');
END;
$$;


--
-- Name: fnQuotationStateListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnQuotationStateListar"() RETURNS TABLE(id integer, code text, name text, color text, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT t.id, t.code::text, t.name::text, t.color::text, t."createdAt"::timestamp FROM public."QuotationState" t ORDER BY t.name ASC;
END; $$;


--
-- Name: fnReportDinamic(integer, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnReportDinamic"(p_report_id integer, p_filter_values json DEFAULT '{}'::json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_base_table VARCHAR;
    v_custom_sql TEXT;
    v_sql TEXT;
    v_select_clause TEXT;
    v_from_clause TEXT;
    v_where_clause TEXT := '1=1';
    v_order_col VARCHAR;
    v_order_dir VARCHAR;
    v_result json;
    v_filter RECORD;
    v_val TEXT;
    v_val_to TEXT;
BEGIN
    -- 1. Obtener la configuración del reporte
    SELECT base_table, custom_sql INTO v_base_table, v_custom_sql
    FROM public."Report"
    WHERE id = p_report_id;

    IF v_base_table IS NULL AND v_custom_sql IS NULL THEN
        RAISE EXCEPTION 'Reporte no encontrado';
    END IF;

    -- 2. Construir el Origen de Datos (Custom SQL o Tabla Base)
    IF v_custom_sql IS NOT NULL AND v_custom_sql <> '' THEN
        -- Si hay SQL personalizado, lo usamos como fuente
        v_from_clause := '(' || v_custom_sql || ') t1 ';
        v_select_clause := '*';
    ELSE
        -- 2.1 Construir el SELECT (Columnas Visibles)
        SELECT string_agg(
            CASE 
                WHEN is_calculated THEN formula_expression || ' AS "' || COALESCE(alias, 'Calculado') || '"'
                ELSE COALESCE(table_alias || '.', '') || '"' || column_name || '"' || ' AS "' || COALESCE(alias, column_name) || '"'
            END,
            ', ' ORDER BY sort_order ASC
        ) INTO v_select_clause
        FROM public."ReportColumns"
        WHERE report_id = p_report_id AND is_visible = true;

        IF v_select_clause IS NULL THEN
            v_select_clause := '*'; 
        END IF;

        -- 2.2 Construir el FROM y los JOINS
        v_from_clause := 'public."' || v_base_table || '" t1 ';

        SELECT v_from_clause || string_agg(
            join_type || ' public."' || table_name || '" ' || alias || ' ON ' || join_condition,
            ' ' ORDER BY sort_order ASC
        ) INTO v_from_clause
        FROM public."ReportJoins"
        WHERE report_id = p_report_id;

        IF v_from_clause IS NULL THEN
            v_from_clause := 'public."' || v_base_table || '" t1 ';
        END IF;
    END IF;

    -- 4. Construir el WHERE (Filtros Dinámicos con Rangos)
    FOR v_filter IN SELECT * FROM public."ReportFilters" WHERE report_id = p_report_id LOOP
        v_val := p_filter_values->>(COALESCE(v_filter.table_alias, 't1') || '.' || v_filter.column_name);
        v_val_to := p_filter_values->>(COALESCE(v_filter.table_alias, 't1') || '.' || v_filter.column_name || '_to');
        
        DECLARE
            v_field_expr TEXT;
        BEGIN
            -- Determinar la expresión del campo
            IF v_custom_sql IS NOT NULL AND v_custom_sql <> '' THEN
                -- En Custom SQL, si el usuario puso algo como q."date", 
                -- debemos quitar el "q." porque afuera solo existe el alias "t1"
                IF v_filter.column_name ~ '\.' THEN
                    v_field_expr := 't1."' || split_part(v_filter.column_name, '.', 2) || '"';
                    -- Limpiar comillas si el split_part las dejó
                    v_field_expr := replace(v_field_expr, '"', ''); 
                    -- Re-envolver con comillas de forma segura
                    v_field_expr := 't1."' || v_field_expr || '"';
                ELSE
                    v_field_expr := 't1."' || v_filter.column_name || '"';
                END IF;
            ELSIF v_filter.column_name ~ '["\.]' THEN
                v_field_expr := v_filter.column_name;
            ELSE
                v_field_expr := COALESCE(v_filter.table_alias, 't1') || '."' || v_filter.column_name || '"';
            END IF;

            IF (v_val IS NOT NULL AND v_val <> '') OR (v_val_to IS NOT NULL AND v_val_to <> '') THEN
                IF v_filter.filter_type = 'date' THEN
                    IF v_val IS NOT NULL AND v_val <> '' AND v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' BETWEEN ''' || v_val || '''::date AND ''' || v_val_to || '''::date';
                    ELSIF v_val IS NOT NULL AND v_val <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' >= ''' || v_val || '''::date';
                    ELSIF v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' <= ''' || v_val_to || '''::date';
                    END IF;
                ELSIF v_filter.filter_type = 'number' THEN
                    IF v_val IS NOT NULL AND v_val <> '' AND v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' BETWEEN ' || v_val || ' AND ' || v_val_to;
                    ELSIF v_val IS NOT NULL AND v_val <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' >= ' || v_val;
                    ELSIF v_val_to IS NOT NULL AND v_val_to <> '' THEN
                        v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' <= ' || v_val_to;
                    END IF;
                ELSE -- text / like
                    v_where_clause := v_where_clause || ' AND ' || v_field_expr || ' ILIKE ''%' || v_val || '%''';
                END IF;
            END IF;
        END;
    END LOOP;

    -- 5. Ensamblar SQL Final con Ordenamiento Múltiple
    v_sql := 'SELECT json_agg(row_to_json(t)) FROM (SELECT ' || v_select_clause || ' FROM ' || v_from_clause || ' WHERE ' || v_where_clause;
    
    -- Agregar ORDER BY si está definido (Múltiple)
    DECLARE
        v_order_by TEXT;
    BEGIN
        SELECT string_agg(
            CASE 
                WHEN column_expr ~ '^[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+$' THEN -- Formato t1.columna
                    split_part(column_expr, '.', 1) || '."' || split_part(column_expr, '.', 2) || '"'
                ELSE column_expr 
            END || ' ' || direction, 
            ', ' ORDER BY sort_order ASC
        ) INTO v_order_by
        FROM public."ReportSorts" WHERE report_id = p_report_id;
        
        IF v_order_by IS NOT NULL THEN
            v_sql := v_sql || ' ORDER BY ' || v_order_by;
        END IF;
    END;

    v_sql := v_sql || ') t';

    -- 6. Ejecutar dinámicamente
    EXECUTE v_sql INTO v_result;

    IF v_result IS NULL THEN
        v_result := '[]'::json;
    END IF;

    RETURN v_result;
END;
$_$;


--
-- Name: fnRoleListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnRoleListar"() RETURNS TABLE(id integer, name character varying, description text, permissions jsonb, user_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name::VARCHAR,
        COALESCE(r.description, '')::TEXT,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB,
        COUNT(u.id)::BIGINT AS user_count
    FROM public."Role" r
    LEFT JOIN public."User" u ON u."roleId" = r.id
    GROUP BY r.id, r.name, r.description, r.permissions
    ORDER BY r.id ASC;
END;
$$;


--
-- Name: fnRptCotizacion(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnRptCotizacion"(p_id_ini integer, p_id_fin integer) RETURNS TABLE("idCotizacion" integer, "internalNumber" text, asesor text, fecha timestamp without time zone, currency text, "tCambio" double precision, state text, "descripcionPlan" text, observaciones text, "baseCommissionable" double precision, "commissionPercentage" double precision, "totalAmount" double precision, "costoTotal" double precision, "valorBase" double precision, utilidad double precision, "comisionFreelanceValue" double precision, "comisionPropiaValue" double precision, "comisionTotalPercentage" double precision, "comisionFreelancePercentage" double precision, "comisionPropiaPercentage" double precision, "comisionUtilidadPercentage" double precision, "clienteNombre" text, "clienteIdentificacion" text, "clienteDireccion" text, "clienteTelefono" text, pasajeros text, "totalAdultos" integer, "totalNinos" integer, "baseComisionable" double precision, "comisionAsesor" double precision, "fechasViaje" text, "hotelesServicios" text, vendedor text, logo bytea, "destinoCabecera" text, "fechaInicioCabecera" timestamp without time zone, "fechaFinCabecera" timestamp without time zone, "pasajeroCabecera" text, "paxAdultosCabecera" integer, "paxNinosCabecera" integer, "reservacionCabecera" text, "descripcionManualCabecera" text, "idProducto" integer, "productDescripcion" text, "productTipo" text, "productCodigo" text, "productConcepto" text, "productItinerario" text, "productClase" text, "productVuelo" text, precio double precision, cantidad integer, costo double precision, "checkIn" text, "checkOut" text, noches integer, "paxAdultos" integer, "paxNinos" integer, destino text, "codigoReserva" text, "tipoServicio" text, servicio text, descripcion text, "proveedorNombre" text, "proveedorNIT" text, "proveedorContacto" text, "prestadoraNombre" text, "prestadoraCategoria" text, "prestadoraUbicacion" text, "tarifaNeta" double precision, impuestos double precision, "adicionalesServ" double precision, comision double precision, descuento double precision, sobrecomision double precision, fee double precision, total double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        -- Cabecera Cotización
        q.id AS "idCotizacion",
        COALESCE(q."internalNumber", '')::text AS "internalNumber",
        COALESCE(u.name, '')::text AS "asesor",
        q.date AS "fecha",
        COALESCE(q.currency, '')::text AS "currency",
        q."exchangeRate"::double precision AS "tCambio",
        COALESCE(q.state, '')::text AS "state",
        ('Cotización ' || q."internalNumber")::text AS "descripcionPlan",
        COALESCE(q.state, '')::text AS "observaciones",
        COALESCE(q."baseCommissionable", 0)::double precision AS "baseCommissionable",
        COALESCE(q."commissionPercentage", 0)::double precision AS "commissionPercentage",
        COALESCE(q."totalAmount", 0)::double precision AS "totalAmount",
        COALESCE(q."costoTotal", 0)::double precision AS "costoTotal",
        COALESCE(q."valorBase", 0)::double precision AS "valorBase",
        COALESCE(q."utilidad", 0)::double precision AS "utilidad",
        COALESCE(
            q."comisionFreelanceValue", 
            CASE WHEN COALESCE(q."valorBase", 0) > 0 AND COALESCE(q."comisionFreelancePercentage", 0) > 0 
                 THEN ROUND(((COALESCE(q."comisionFreelancePercentage", 0) / 100.0) * q."valorBase")::numeric, 2) 
                 ELSE 0 END
        )::double precision AS "comisionFreelanceValue",
        COALESCE(
            q."comisionPropiaValue", 
            COALESCE(q."utilidad", 0) - COALESCE(
                q."comisionFreelanceValue", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 AND COALESCE(q."comisionFreelancePercentage", 0) > 0 
                     THEN ROUND(((COALESCE(q."comisionFreelancePercentage", 0) / 100.0) * q."valorBase")::numeric, 2) 
                     ELSE 0 END
            )
        )::double precision AS "comisionPropiaValue",
        COALESCE(
            q."comisionTotalPercentage", 
            COALESCE(
                q."comisionUtilidadPercentage", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 
                     THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                     ELSE 0 END
            )
        )::double precision AS "comisionTotalPercentage",
        COALESCE(q."comisionFreelancePercentage", 0)::double precision AS "comisionFreelancePercentage",
        ROUND(COALESCE(
            q."comisionPropiaPercentage", 
            COALESCE(
                q."comisionUtilidadPercentage", 
                CASE WHEN COALESCE(q."valorBase", 0) > 0 
                     THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                     ELSE 0 END
            ) - COALESCE(q."comisionFreelancePercentage", 0)
        )::numeric, 2)::double precision AS "comisionPropiaPercentage",
        COALESCE(
            q."comisionUtilidadPercentage", 
            CASE WHEN COALESCE(q."valorBase", 0) > 0 
                 THEN ROUND(((COALESCE(q."utilidad", 0) / q."valorBase") * 100.0)::numeric, 2) 
                 ELSE 0 END
        )::double precision AS "comisionUtilidadPercentage",

        -- Cliente
        COALESCE(c.name, '')::text AS "clienteNombre",
        COALESCE(c.document, '')::text AS "clienteIdentificacion",
        COALESCE(c.address, '')::text AS "clienteDireccion",
        COALESCE(c."contactInfo", '')::text AS "clienteTelefono",

        -- Resúmenes de cabecera (pasajeros/adultos/niños = del producto actual)
        (
            SELECT string_agg(p.name, ', ')
            FROM "QuotationProductPassenger" p
            WHERE p."quotationProductId" = qp.id
        )::text AS "pasajeros",
        COALESCE(qp."paxAdults", 0)::integer AS "totalAdultos",
        COALESCE(qp."paxChildren", 0)::integer AS "totalNinos",
        COALESCE(q."baseCommissionable", 0)::double precision AS "baseComisionable",
        COALESCE(q."commissionPercentage", 0)::double precision AS "comisionAsesor",
        COALESCE(to_char(qp."checkInDate", 'DD/MM/YYYY') || ' al ' || to_char(qp."checkOutDate", 'DD/MM/YYYY'), '')::text AS "fechasViaje",
        COALESCE(prod.description, '')::text AS "hotelesServicios",
        COALESCE(sel.name, '')::text AS "vendedor",
        COALESCE(i.logo, b.logo) AS "logo",
        COALESCE(q.destination, '')::text AS "destinoCabecera",
        q."startDate" AS "fechaInicioCabecera",
        q."endDate" AS "fechaFinCabecera",
        COALESCE(q.passenger, '')::text AS "pasajeroCabecera",
        COALESCE(q."paxAdults", 0)::integer AS "paxAdultosCabecera",
        COALESCE(q."paxChildren", 0)::integer AS "paxNinosCabecera",
        COALESCE(q."reservationCode", '')::text AS "reservacionCabecera",
        COALESCE(q."manualDescription", '')::text AS "descripcionManualCabecera",

        -- Datos del Producto/Item
        qp.id AS "idProducto",
        COALESCE(prod.description, '')::text AS "productDescripcion",
        COALESCE(prod.type, '')::text AS "productTipo",
        COALESCE(prod.code, '')::text AS "productCodigo",
        COALESCE(prod."billingConcept", '')::text AS "productConcepto",
        COALESCE(prod."airlineItinerary", '')::text AS "productItinerario",
        COALESCE(prod."classItinerary", '')::text AS "productClase",
        COALESCE(prod."flightItinerary", '')::text AS "productVuelo",
        COALESCE(qp.price, 0)::double precision AS "precio",
        COALESCE(qp.quantity, 1)::integer AS "cantidad",
        COALESCE(qp.cost, 0)::double precision AS "costo",
        COALESCE(to_char(qp."checkInDate", 'DD/MM/YYYY'), '')::text AS "checkIn",
        COALESCE(to_char(qp."checkOutDate", 'DD/MM/YYYY'), '')::text AS "checkOut",
        COALESCE(qp.nights, 0)::integer AS "noches",
        COALESCE(qp."paxAdults", 0)::integer AS "paxAdultos",
        COALESCE(qp."paxChildren", 0)::integer AS "paxNinos",
        COALESCE(qp.destination, '')::text AS "destino",
        COALESCE(qp."reservationCode", '')::text AS "codigoReserva",
        COALESCE(qp."serviceType", '')::text AS "tipoServicio",
        COALESCE(qp.service, '')::text AS "servicio",
        COALESCE(qp.description, '')::text AS "descripcion",

        -- Proveedor
        COALESCE(prov.name, '')::text AS "proveedorNombre",
        COALESCE(prov.code, '')::text AS "proveedorNIT",
        COALESCE(prov."contactInfo", '')::text AS "proveedorContacto",

        -- Prestadora
        COALESCE(pre.name, '')::text AS "prestadoraNombre",
        COALESCE(pre.category, '')::text AS "prestadoraCategoria",
        COALESCE(pre.location, '')::text AS "prestadoraUbicacion",

        -- Valores financieros del producto
        (
            COALESCE(qp.price, 0) +
            COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN "ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0)
        )::double precision AS "tarifaNeta",

        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2.type = 'TAX'
            ), 0
        )::double precision AS "impuestos",

        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                JOIN "ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN "ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2.type = 'CHARGE'
                  AND NOT (
                      ct2."targetTaxId" IS NOT NULL AND (
                          target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                      )
                  )
            ), 0
        )::double precision AS "adicionalesServ",

        COALESCE(qp."sellerCommission", 0)::double precision AS "comision",
        0::double precision AS "descuento",
        0::double precision AS "sobrecomision",
        0::double precision AS "fee",
        COALESCE(
            (
                SELECT SUM(qpt2."explicitAmount")
                FROM "QuotationProductTax" qpt2
                WHERE qpt2."quotationProductId" = qp.id
            ), 0
        )::double precision AS "total"

    FROM "Quotation" q
    LEFT JOIN "Client" c ON q."clientId" = c.id
    LEFT JOIN "Seller" sel ON q."sellerId" = sel.id
    LEFT JOIN "User" u ON q."userId" = u.id
    LEFT JOIN "Branch" b ON q."branchId" = b.id
    LEFT JOIN "Implant" i ON q."implantId" = i.id
    LEFT JOIN "QuotationProduct" qp ON qp."quotationId" = q.id
    LEFT JOIN "Product" prod ON qp."productId" = prod.id
    LEFT JOIN "Provider" prov ON qp."providerId" = prov.id
    LEFT JOIN "Prestadora" pre ON qp."prestadoraId" = pre.id
    WHERE q.id BETWEEN p_id_ini AND p_id_fin
    ORDER BY q.id, qp.id;
END;
$$;


--
-- Name: fnTicketTypeListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnTicketTypeListar"() RETURNS TABLE(id integer, code text, name text, description text, "isActive" boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT t.id, t.code::text, t.name::text, t.description::text, t."isActive" FROM public."TicketType" t ORDER BY t.name ASC;
END; $$;


--
-- Name: fnTransactionConsecutiveListar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnTransactionConsecutiveListar"() RETURNS TABLE(id integer, "transactionType" text, description text, prefix text, "initialNumber" integer, "currentNumber" integer, "branchId" integer, "branchName" text, "implantId" integer, "implantName" text, "isActive" boolean, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc.id,
        tc."transactionType"::text,
        tc."description"::text,
        COALESCE(tc.prefix, '')::text,
        tc."initialNumber",
        tc."currentNumber",
        tc."branchId",
        COALESCE(b.name, '')::text AS "branchName",
        tc."implantId",
        COALESCE(imp.name, '')::text AS "implantName",
        tc."isActive",
        tc."createdAt"
    FROM public."TransactionConsecutive" tc
    LEFT JOIN public."Branch" b ON b.id = tc."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = tc."implantId"
    ORDER BY tc.id DESC;
END;
$$;


--
-- Name: fnUserPermissions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public."fnUserPermissions"(p_user_id integer) RETURNS TABLE(user_id integer, role_id integer, role_name character varying, permissions jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id AS user_id,
        r.id AS role_id,
        r.name::VARCHAR AS role_name,
        COALESCE(r.permissions, '{}'::jsonb)::JSONB AS permissions
    FROM public."User" u
    JOIN public."Role" r ON u."roleId" = r.id
    WHERE u.id = p_user_id;
END;
$$;


--
-- Name: fn_obtener_decimales_moneda(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_obtener_decimales_moneda(p_currency_code text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_decimals INT;
BEGIN
    SELECT COALESCE(decimals, 2) INTO v_decimals
    FROM public."Currency"
    WHERE LOWER(code) = LOWER(p_currency_code);
    
    RETURN COALESCE(v_decimals, 2);
END;
$$;


--
-- Name: fn_obtener_historial_estados(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_obtener_historial_estados(p_quotation_id integer) RETURNS TABLE(id integer, state character varying, description text, "createdAt" timestamp without time zone, "userId" integer, "userName" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        qsh.id,
        qsh.state,
        qsh.description,
        qsh."createdAt",
        qsh."userId",
        COALESCE(u.name, 'Sistema'::TEXT) AS "userName"
    FROM public."QuotationStateHistory" qsh
    LEFT JOIN public."User" u ON qsh."userId" = u.id
    WHERE qsh."quotationId" = p_quotation_id
    ORDER BY qsh."createdAt" DESC;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Branch" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    logo bytea,
    template bytea,
    "templateConfig" jsonb,
    "htmlTemplate" text,
    "resolutionId" integer,
    "invoiceTemplate" bytea,
    "invoiceTemplateConfig" jsonb,
    "invoiceHtmlTemplate" text,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: fnbranchlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnbranchlistar() RETURNS SETOF public."Branch"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Branch" ORDER BY name ASC;
END;
$$;


--
-- Name: fncellcustomizationlistar(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fncellcustomizationlistar(p_branch_id integer, p_implant_id integer) RETURNS TABLE(id integer, code character varying, name character varying, value character varying, "branchId" integer, "implantId" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cc.id,
        cc.code::varchar(50),
        cc."name"::varchar(100),
        cc."value"::varchar(10),
        cc."branchId",
        cc."implantId"
    FROM public."CellCustomization" cc
    WHERE 
        (p_branch_id IS NOT NULL AND cc."branchId" = p_branch_id AND cc."implantId" IS NULL)
        OR
        (p_implant_id IS NOT NULL AND cc."implantId" = p_implant_id);
END;
$$;


--
-- Name: fnclientelistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnclientelistar() RETURNS TABLE(id integer, name text, document text, "contactInfo" text, address text, "mandatoryVariables" jsonb, "sellerId" integer, "sellerCode" text, "sellerName" text, "isActive" boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        COALESCE(c.name, '')::text,
        COALESCE(c.document, '')::text,
        c."contactInfo"::text,
        c.address::text,
        c."mandatoryVariables",
        c."sellerId",
        s.code::text AS "sellerCode",
        s.name::text AS "sellerName",
        COALESCE(c."isActive", true) AS "isActive"
    FROM public."Client" c
    LEFT JOIN public."Seller" s ON s.id = c."sellerId"
    ORDER BY c.id DESC;
END;
$$;


--
-- Name: fncombolistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fncombolistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', c.id,
            'code', c.code,
            'name', c.name,
            'cupos', c."cupos",
            'currencyId', c."currencyId",
            'createdAt', c."createdAt",
            'products', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', cp.id,
                        'productId', cp."productId",
                        'product', jsonb_build_object('id', p.id, 'code', p.code, 'description', p.description),
                        'quantity', cp.quantity,
                        'price', cp.price,
                        'cost', COALESCE(cp."cost", 0),
                        'providerId', cp."providerId",
                        'prestadoraId', cp."prestadoraId",
                        'checkInDate', cp."checkInDate",
                        'checkOutDate', cp."checkOutDate",
                        'paxAdults', cp."paxAdults",
                        'paxChildren', cp."paxChildren",
                        'mainTaxId', cp."mainTaxId",
                        'inNationality', COALESCE(cp."inNationality", 1),
                        'appliedTaxes', (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'id', cpt.id,
                                    'chargeAndTaxId', cpt."chargeAndTaxId",
                                    'amount', cpt.amount,
                                    'isMain', cpt."isMain",
                                    'chargeAndTax', (
                                        SELECT jsonb_build_object('id', ct.id, 'name', ct.name, 'value', ct.value, 'valueType', ct."valueType")
                                        FROM public."ChargeAndTax" ct WHERE ct.id = cpt."chargeAndTaxId"
                                    )
                                )
                            )
                            FROM public."ComboProductTax" cpt
                            WHERE cpt."comboProductId" = cp.id
                        )
                    )
                )
                FROM public."ComboProduct" cp
                JOIN public."Product" p ON cp."productId" = p.id
                WHERE cp."comboId" = c.id
            ), '[]'::jsonb)
        )
    FROM public."Combo" c
    ORDER BY c."createdAt" DESC;
END;
$$;


--
-- Name: fncotizacion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fncotizacion(p_quotation_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
            'date', q.date,
            'clientId', q."clientId",
            'currency', q.currency,
            'exchangeRate', q."exchangeRate",
            'branchId', q."branchId",
            'implantId', q."implantId",
            'sellerId', q."sellerId",
            'ticketPrinterId', q."ticketPrinterId",
            'commissionPercentage', q."commissionPercentage",
            'chargesAndTaxes', q."chargesAndTaxes",
            'totalAmount', q."totalAmount",
            'state', q.state,
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object(
                'id', c.id,
                'name', c.name,
                'document', c.document
            ) ELSE jsonb_build_object('id', null, 'name', 'Cliente desconocido', 'document', '') END,
            'combos', COALESCE((
                SELECT jsonb_agg(jsonb_build_object('id', qc."comboId", 'comboId', qc."comboId", 'name', cb.name))
                FROM public."QuotationCombo" qc
                JOIN public."Combo" cb ON qc."comboId" = cb.id
                WHERE qc."quotationId" = q.id
            ), '[]'::jsonb),
            'products', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', qp.id,
                            'productId', qp."productId",
                            'product', jsonb_build_object(
                                'id', p.id,
                                'description', p.description,
                                'code', p.code
                            ),
                            'provider', CASE WHEN prov.id IS NOT NULL THEN jsonb_build_object('id', prov.id, 'name', prov.name) ELSE NULL END,
                            'prestadora', CASE WHEN h.id IS NOT NULL THEN jsonb_build_object('id', h.id, 'name', h.name) ELSE NULL END,
                            'providerId', qp."providerId",
                            'prestadoraId', qp."prestadoraId",
                            'quantity', qp.quantity,
                            'price', qp.price,
                            'cost', qp.cost,
                            'checkInDate', qp."checkInDate",
                            'checkOutDate', qp."checkOutDate",
                            'nights', qp.nights,
                            'paxAdults', qp."paxAdults",
                            'paxChildren', qp."paxChildren",
                            'serviceType', qp."serviceType",
                            'destination', qp.destination,
                            'reservationCode', qp."reservationCode",
                            'sellerCommission', qp."sellerCommission",
                            'ticketPrinterCommission', qp."ticketPrinterCommission",
                            'comboId', qp."comboId",
                            'mainTaxId', qp."mainTaxId",
                            'inNationality', COALESCE(qp."inNationality", 1),
                            'service', COALESCE(qp.service, qp.servicios),
                            'servicios', COALESCE(qp.servicios, qp.service),
                            'descripcion', qp.descripcion,
                            'passengers', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpax.id, 'name', qpax.name, 'document', qpax.document))
                                FROM public."QuotationProductPassenger" qpax
                                WHERE qpax."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'variables', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qvar.id, 'masterVariableId', qvar."masterVariableId", 'value', qvar.value))
                                FROM public."QuotationProductVariable" qvar
                                WHERE qvar."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'appliedTaxes', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpt."chargeAndTaxId", 'chargeAndTaxId', qpt."chargeAndTaxId", 'explicitAmount', qpt."explicitAmount", 'valueSnapshot', qpt."valueSnapshot", 'valueTypeSnapshot', qpt."valueTypeSnapshot", 'isMain', qpt."isMain"))
                                FROM public."QuotationProductTax" qpt
                                WHERE qpt."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'payments', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object(
                                    'id', qpmt.id,
                                    'amount', qpmt.amount,
                                    'paymentMethod', qpmt."paymentMethod",
                                    'date', qpmt.date,
                                    'reference', qpmt.reference,
                                    'creditCardId', qpmt."creditCardId",
                                    'cardNumber', qpmt."cardNumber",
                                    'authorizationCode', qpmt."authorizationCode",
                                    'voucher', qpmt.voucher,
                                    'expirationDate', qpmt."expirationDate"
                                ))
                                FROM public."QuotationProductPayment" qpmt
                                WHERE qpmt."quotationProductId" = qp.id
                            ), '[]'::jsonb)
                        )
                    )
                    FROM public."QuotationProduct" qp
                    LEFT JOIN public."Product" p ON qp."productId" = p.id
                    LEFT JOIN public."Provider" prov ON qp."providerId" = prov.id
                    LEFT JOIN public."Prestadora" h ON qp."prestadoraId" = h.id
                    WHERE qp."quotationId" = q.id
                ),
                '[]'::jsonb
            )
        )
    INTO v_result
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    WHERE q.id = p_quotation_id;

    RETURN v_result;
END;
$$;


--
-- Name: fncotizacionhistorial(character varying, date, date, character varying, character varying, numeric, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fncotizacionhistorial(p_referencia character varying DEFAULT NULL::character varying, p_fecha_desde date DEFAULT NULL::date, p_fecha_hasta date DEFAULT NULL::date, p_cliente character varying DEFAULT NULL::character varying, p_elaborado_por character varying DEFAULT NULL::character varying, p_monto_total numeric DEFAULT NULL::numeric, p_estado character varying DEFAULT NULL::character varying, p_reserva character varying DEFAULT NULL::character varying, p_pasajero character varying DEFAULT NULL::character varying) RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_ref_clean VARCHAR;
    v_range_match TEXT[];
    v_id_start INT := NULL;
    v_id_end INT := NULL;
    v_single_id INT := NULL;
BEGIN
    IF p_referencia IS NOT NULL AND TRIM(p_referencia) <> '' THEN
        v_ref_clean := TRIM(p_referencia);
        -- Regex match for range e.g. "1-10", "01-10", "1 a 10", "1..10", "#1 - #10"
        v_range_match := regexp_match(v_ref_clean, '^\s*#?\s*(\d+)\s*(?:-|a|\.\.|\:|\s+a\s+)\s*#?\s*(\d+)\s*$', 'i');
        
        IF v_range_match IS NOT NULL THEN
            v_id_start := v_range_match[1]::INT;
            v_id_end := v_range_match[2]::INT;
            -- Ensure start is <= end
            IF v_id_start > v_id_end THEN
                v_single_id := v_id_start;
                v_id_start := v_id_end;
                v_id_end := v_single_id;
                v_single_id := NULL;
            END IF;
        ELSIF v_ref_clean ~ '^\s*#?\s*(\d+)\s*$' THEN
            v_single_id := (regexp_match(v_ref_clean, '(\d+)'))[1]::INT;
        END IF;
    END IF;

    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
            'clientName', COALESCE(c.name, 'Cliente desconocido'),
            'providerName', COALESCE((
                SELECT prov.name 
                FROM public."QuotationProduct" qp
                JOIN public."Provider" prov ON qp."providerId" = prov.id
                WHERE qp."quotationId" = q.id
                LIMIT 1
            ), 'Proveedor Desconocido'),
            'createdAt', q.date,
            'totalAmount', q."totalAmount",
            'currency', q.currency,
            'userName', COALESCE(u.name, 'Sistema'),
            'state', COALESCE(q.state, 'NUEVO'),
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'nights', COALESCE((
                SELECT qp.nights 
                FROM public."QuotationProduct" qp
                WHERE qp."quotationId" = q.id
                LIMIT 1
            ), 1),
            'reservationCode', COALESCE(
                NULLIF(q."reservationCode", ''),
                (
                    SELECT qp."reservationCode" 
                    FROM public."QuotationProduct" qp 
                    WHERE qp."quotationId" = q.id 
                    AND NULLIF(qp."reservationCode", '') IS NOT NULL 
                    LIMIT 1
                ),
                ''
            ),
            'passengerName', COALESCE(
                NULLIF(q.passenger, ''),
                (
                    SELECT qpax.name 
                    FROM public."QuotationProduct" qp
                    JOIN public."QuotationProductPassenger" qpax ON qpax."quotationProductId" = qp.id
                    WHERE qp."quotationId" = q.id
                    ORDER BY qpax.id ASC
                    LIMIT 1
                ),
                COALESCE((
                    SELECT qp.passenger 
                    FROM public."QuotationProduct" qp 
                    WHERE qp."quotationId" = q.id 
                    AND NULLIF(qp.passenger, '') IS NOT NULL 
                    LIMIT 1
                ), 'Mismo titular')
            )
        )
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."User" u ON q."userId" = u.id
    WHERE 
        (
            p_referencia IS NULL OR TRIM(p_referencia) = ''
            OR (v_id_start IS NOT NULL AND v_id_end IS NOT NULL AND q.id BETWEEN v_id_start AND v_id_end)
            OR (v_single_id IS NOT NULL AND q.id = v_single_id)
            OR (v_id_start IS NULL AND v_single_id IS NULL AND (
                q.id::text ILIKE '%' || p_referencia || '%' OR q."internalNumber" ILIKE '%' || p_referencia || '%'
            ))
        )
        AND (p_fecha_desde IS NULL OR q.date::date >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR q.date::date <= p_fecha_hasta)
        AND (p_cliente IS NULL OR TRIM(p_cliente) = '' OR (c.name IS NOT NULL AND c.name ILIKE '%' || TRIM(p_cliente) || '%'))
        AND (p_elaborado_por IS NULL OR TRIM(p_elaborado_por) = '' OR (u.name IS NOT NULL AND u.name ILIKE '%' || TRIM(p_elaborado_por) || '%'))
        AND (p_monto_total IS NULL OR q."totalAmount" = p_monto_total)
        AND (p_estado IS NULL OR TRIM(p_estado) = '' OR q.state ILIKE '%' || TRIM(p_estado) || '%')
        AND (
            p_reserva IS NULL OR TRIM(p_reserva) = ''
            OR q."reservationCode" ILIKE '%' || TRIM(p_reserva) || '%'
            OR EXISTS (
                SELECT 1 FROM public."QuotationProduct" qp 
                WHERE qp."quotationId" = q.id AND qp."reservationCode" ILIKE '%' || TRIM(p_reserva) || '%'
            )
        )
        AND (
            p_pasajero IS NULL OR TRIM(p_pasajero) = ''
            OR q.passenger ILIKE '%' || TRIM(p_pasajero) || '%'
            OR EXISTS (
                SELECT 1 FROM public."QuotationProduct" qp 
                LEFT JOIN public."QuotationProductPassenger" qpax ON qpax."quotationProductId" = qp.id
                WHERE qp."quotationId" = q.id 
                AND (qpax.name ILIKE '%' || TRIM(p_pasajero) || '%' OR qp.passenger ILIKE '%' || TRIM(p_pasajero) || '%')
            )
        )
    ORDER BY q.id DESC;
END;
$_$;


--
-- Name: fncotizacionlistar(character varying, date, date, character varying, character varying, numeric, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fncotizacionlistar(p_referencia character varying DEFAULT NULL::character varying, p_fecha_desde date DEFAULT NULL::date, p_fecha_hasta date DEFAULT NULL::date, p_cliente character varying DEFAULT NULL::character varying, p_elaborado_por character varying DEFAULT NULL::character varying, p_monto_total numeric DEFAULT NULL::numeric, p_estado character varying DEFAULT NULL::character varying) RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', q.id,
            'internalNumber', q."internalNumber",
            'date', q.date,
            'clientId', q."clientId",
            'currency', q.currency,
            'exchangeRate', q."exchangeRate",
            'totalAmount', q."totalAmount",
            'state', q.state,
            'stateDescription', q."stateDescription",
            'stateUpdatedAt', q."stateUpdatedAt",
            'user', CASE WHEN u.id IS NOT NULL THEN jsonb_build_object('id', u.id, 'name', u.name) ELSE NULL END,
            'client', CASE WHEN c.id IS NOT NULL THEN jsonb_build_object(
                'id', c.id,
                'name', c.name,
                'document', c.document
            ) ELSE jsonb_build_object('id', null, 'name', 'Cliente desconocido', 'document', '') END,
            'products', COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', qp.id,
                            'productId', qp."productId",
                            'product', jsonb_build_object(
                                'id', p.id,
                                'description', p.description
                            ),
                            'provider', CASE WHEN prov.id IS NOT NULL THEN jsonb_build_object('id', prov.id, 'name', prov.name) ELSE NULL END,
                            'prestadora', CASE WHEN h.id IS NOT NULL THEN jsonb_build_object('id', h.id, 'name', h.name) ELSE NULL END,
                            'quantity', qp.quantity,
                            'price', qp.price,
                            'checkInDate', qp."checkInDate",
                            'checkOutDate', qp."checkOutDate",
                            'inNationality', COALESCE(qp."inNationality", 1),
                            'mainTaxId', qp."mainTaxId",
                            'passengers', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qpax.id, 'name', qpax.name, 'document', qpax.document))
                                FROM public."QuotationProductPassenger" qpax
                                WHERE qpax."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'variables', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('id', qvar.id, 'masterVariableId', qvar."masterVariableId", 'value', qvar.value))
                                FROM public."QuotationProductVariable" qvar
                                WHERE qvar."quotationProductId" = qp.id
                            ), '[]'::jsonb),
                            'appliedTaxes', COALESCE((
                                SELECT jsonb_agg(jsonb_build_object('chargeAndTaxId', qpt."chargeAndTaxId", 'explicitAmount', qpt."explicitAmount", 'isMain', qpt."isMain"))
                                FROM public."QuotationProductTax" qpt
                                WHERE qpt."quotationProductId" = qp.id
                            ), '[]'::jsonb)
                        )
                    )
                    FROM public."QuotationProduct" qp
                    LEFT JOIN public."Product" p ON qp."productId" = p.id
                    LEFT JOIN public."Provider" prov ON qp."providerId" = prov.id
                    LEFT JOIN public."Prestadora" h ON qp."prestadoraId" = h.id
                    WHERE qp."quotationId" = q.id
                ),
                '[]'::jsonb
            )
        )
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."User" u ON q."userId" = u.id
    WHERE 
        (p_referencia IS NULL OR q.id::text ILIKE '%' || p_referencia || '%')
        AND (p_fecha_desde IS NULL OR q.date::date >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR q.date::date <= p_fecha_hasta)
        AND (p_cliente IS NULL OR TRIM(p_cliente) = '' OR (c.name IS NOT NULL AND c.name ILIKE '%' || TRIM(p_cliente) || '%'))
        AND (p_elaborado_por IS NULL OR TRIM(p_elaborado_por) = '' OR (u.name IS NOT NULL AND u.name ILIKE '%' || TRIM(p_elaborado_por) || '%'))
        AND (p_monto_total IS NULL OR q."totalAmount" = p_monto_total)
        AND (p_estado IS NULL OR TRIM(p_estado) = '' OR q.state ILIKE '%' || TRIM(p_estado) || '%')
    ORDER BY q.date DESC;
END;
$$;


--
-- Name: Implant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Implant" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    "branchId" integer,
    logo bytea,
    template bytea,
    "templateConfig" jsonb,
    "htmlTemplate" text,
    "Logo" bytea,
    "resolutionId" integer,
    "invoiceTemplate" bytea,
    "invoiceTemplateConfig" jsonb,
    "invoiceHtmlTemplate" text,
    "isActive" boolean DEFAULT true
);


--
-- Name: fnimplantlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnimplantlistar() RETURNS SETOF public."Implant"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Implant" ORDER BY name ASC;
END;
$$;


--
-- Name: fnimpuestolistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnimpuestolistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', t.id,
            'code', t.code,
            'name', t.name,
            'type', t.type,
            'valueType', t."valueType",
            'value', t.value,
            'isEditable', t."isEditable",
            'orden', COALESCE(t.orden, 0),
            'productIds', COALESCE(t."productIds", '[]'::jsonb),
            'targetTaxId', t."targetTaxId",
            'isActive', COALESCE(t."isActive", true),
            'gdsEquivalences', COALESCE((
                SELECT string_agg(DISTINCT eq."cd_codigointe", ', ')
                FROM public."EquivalencesInterfaces" eq
                INNER JOIN public."Master" m ON m.id = eq.id_master
                WHERE m.code = 'ChargeAndTax' AND eq.cd_codigo = t.code
            ), '')
        )
    FROM public."ChargeAndTax" t
    ORDER BY 
        CASE 
            WHEN COALESCE(t.orden, 0) > 0 THEN t.orden 
            WHEN t.code = 'TAR' THEN 1 
            ELSE 9999 
        END ASC, 
        t.name ASC;
END;
$$;


--
-- Name: fninvoiceslistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fninvoiceslistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', i.id,
            'code', i.code,
            'createdAt', i."createdAt",
            'updatedAt', i."updatedAt",
            'state', i.state,
            'clientName', COALESCE(c.name, ''),
            'total', COALESCE(i.total, 0)
        )
    FROM public."Invoice" i
    LEFT JOIN public."Client" c ON c.id = i."clientId"
    ORDER BY i.id DESC;
END;
$$;


--
-- Name: Menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Menu" (
    id integer NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    parent integer,
    action character varying(500) NOT NULL,
    activo boolean DEFAULT true
);


--
-- Name: fnmenu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnmenu() RETURNS SETOF public."Menu"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Menu"
    WHERE activo = true
    ORDER BY id ASC;
END;
$$;


--
-- Name: fnmenuall(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnmenuall() RETURNS SETOF public."Menu"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Menu"
    ORDER BY id ASC;
END;
$$;


--
-- Name: fnmonedalistar(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnmonedalistar(p_id integer DEFAULT NULL::integer) RETURNS TABLE(id integer, code text, name text, "exchangeRate" double precision, decimals integer, "isActive" boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.code,
        c.name,
        c."exchangeRate",
        c.decimals,
        COALESCE(c."isActive", true) AS "isActive"
    FROM public."Currency" c
    WHERE
        p_id IS NULL
        OR c.id = p_id
    ORDER BY c.code;
END;
$$;


--
-- Name: SystemParameter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SystemParameter" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    value text NOT NULL
);


--
-- Name: fnparameterlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnparameterlistar() RETURNS SETOF public."SystemParameter"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."SystemParameter" ORDER BY name ASC;
END;
$$;


--
-- Name: fnprestadoralistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnprestadoralistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', h.id,
            'code', h.code,
            'name', h.name,
            'category', h.category,
            'type', h.type,
            'location', h.location,
            'providerId', h."providerId",
            'isActive', COALESCE(h."isActive", true),
            'provider', (
                SELECT jsonb_build_object('id', p.id, 'name', p.name)
                FROM public."Provider" p WHERE p.id = h."providerId"
            )
        )
    FROM public."Prestadora" h
    ORDER BY h.name ASC;
END;
$$;


--
-- Name: Product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Product" (
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
    "mandatoryFields" jsonb,
    "taxIds" jsonb DEFAULT '[]'::jsonb,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: fnproductolistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnproductolistar() RETURNS SETOF public."Product"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Product" ORDER BY id DESC;
END;
$$;


--
-- Name: fnproveedorlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnproveedorlistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'name', p.name,
            'contactInfo', p."contactInfo",
            'commissionConfig', p."commissionConfig",
            'providerTypeId', p."providerTypeId",
            'providerTypeName', pt.name,
            'isAirline', COALESCE(pt."isAirline", false),
            'airlineCode', p."airlineCode",
            'sigla', p."sigla",
            'isActive', COALESCE(p."isActive", true),
            'prestadoras', COALESCE((
                SELECT jsonb_agg(h)
                FROM public."Prestadora" h
                WHERE h."providerId" = p.id
            ), '[]'::jsonb)
        )
    FROM public."Provider" p
    LEFT JOIN public."ProviderType" pt ON pt.id = p."providerTypeId"
    ORDER BY p.name ASC;
END;
$$;


--
-- Name: fnprovidertypelistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnprovidertypelistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', pt.id,
            'code', pt.code,
            'name', pt.name,
            'isAirline', pt."isAirline",
            'active', pt.active,
            'isActive', COALESCE(pt."isActive", pt.active, true)
        )
    FROM public."ProviderType" pt
    ORDER BY pt.name ASC;
END;
$$;


--
-- Name: fnreservabuscarparafacturar(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnreservabuscarparafacturar(p_client text DEFAULT NULL::text, p_passenger text DEFAULT NULL::text, p_record text DEFAULT NULL::text, p_ticket text DEFAULT NULL::text, p_airline text DEFAULT NULL::text) RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', b.id,
            'code', b.code,
            'client', COALESCE(b.client, ''),
            'seller', COALESCE(b.seller, ''),
            'tiquetPrinter', COALESCE(b."tiquetPrinter", ''),
            'blanch', COALESCE(b.blanch, 'BOG'),
            'implant', COALESCE(b.implant, ''),
            'currency', COALESCE(b.currency, 'COP'),
            'exchangeRate', COALESCE(b."exchangeRate", 1.0),
            'date', b.date,
            'description', COALESCE(b.description, ''),
            'observation', COALESCE(b.observation, ''),
            'state', COALESCE(b.state, 'NUEVO'),
            'items', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', bp.id,
                        'code', COALESCE(bp.code, ''),
                        'type', COALESCE(bp.type, 'flight'),
                        'description', COALESCE(bp.description, bp.service, ''),
                        'prestadoracode', COALESCE(bp.prestadoracode, ''),
                        'provider', COALESCE(bp.provider, ''),
                        'quantity', COALESCE(bp.quantity, 1),
                        'price', COALESCE(bp.price, 0),
                        'cost', COALESCE(bp.cost, 0),
                        'checkInDate', bp."checkInDate",
                        'checkOutDate', bp."checkOutDate",
                        'nights', COALESCE(bp.nights, 0),
                        'paxAdults', COALESCE(bp."paxAdults", 1),
                        'paxChildren', COALESCE(bp."paxChildren", 0),
                        'serviceType', COALESCE(bp."serviceType", 'flight'),
                        'billingConcept', COALESCE(bp."billingConcept", ''),
                        'destination', COALESCE(bp.destination, ''),
                        'reservationCode', COALESCE(bp."reservationCode", b.code, ''),
                        'ticketCode', COALESCE((
                            SELECT string_agg(DISTINCT bpp2.identification, ', ')
                            FROM public."BookingProductPassangerGDS" bpp2
                            WHERE bpp2."bookingProductId" = bp.id AND bpp2.identification <> ''
                        ), ''),
                        'passengers', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'name', TRIM(COALESCE(bpp2.firstnm, '') || ' ' || COALESCE(bpp2.lastnm, '')),
                                    'document', COALESCE(bpp2.identification, '')
                                )
                            )
                            FROM public."BookingProductPassangerGDS" bpp2
                            WHERE bpp2."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'appliedTaxes', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'code', bpt.code,
                                    'name', bpt.name,
                                    'type', bpt.type,
                                    'amount', COALESCE(bpt.amount, 0),
                                    'ismain', COALESCE(bpt.ismain, false)
                                )
                            )
                            FROM public."BookingProductTaxGDS" bpt
                            WHERE bpt."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'payments', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'code', bpay.code,
                                    'name', bpay.name,
                                    'type', bpay.type,
                                    'typecreditcard', COALESCE(bpay.typecreditcard, ''),
                                    'numbercreditcard', COALESCE(bpay.numbercreditcard, ''),
                                    'vouchercreditcard', COALESCE(bpay.vouchercreditcard, ''),
                                    'authcreditcard', COALESCE(bpay.authcreditcard, ''),
                                    'amount', COALESCE(bpay.amount, 0)
                                )
                            )
                            FROM public."BookingProductPaymentGDS" bpay
                            WHERE bpay."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'itinerary', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'orden', bpi.orden,
                                    'origin', bpi.origin,
                                    'destination', bpi.destination,
                                    'class', bpi.class,
                                    'checkInDate', bpi."checkInDate",
                                    'checkOutDate', bpi."checkOutDate",
                                    'prestadoraCode', bpi."prestadoraCode",
                                    'farebasis', bpi.farebasis,
                                    'Numflight', bpi."Numflight",
                                    'amount', bpi.amount
                                )
                            )
                            FROM public."BookingProductItineraryGDS" bpi
                            WHERE bpi."bookingProductId" = bp.id
                        ), '[]'::jsonb),
                        'variables', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'masterVariableId', COALESCE(mv.id, 0),
                                    'code', bpv.code,
                                    'name', bpv.name,
                                    'value', bpv.value
                                )
                            )
                            FROM public."BookingProductVariableGDS" bpv
                            LEFT JOIN public."MasterVariable" mv ON UPPER(mv.code) = UPPER(bpv.code) OR UPPER(mv.name) = UPPER(bpv.name)
                            WHERE bpv."bookingProductId" = bp.id
                        ), '[]'::jsonb)
                    )
                )
                FROM public."BookingProductGDS" bp
                WHERE bp."bookingId" = b.id
                  AND COALESCE(bp.state, '') <> 'FACTURADO' 
                  AND bp."invoiceId" IS NULL
            ), '[]'::jsonb)
        )
    FROM public."BookingGDS" b
    WHERE 
        EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_check 
            WHERE bp_check."bookingId" = b.id 
              AND COALESCE(bp_check.state, '') <> 'FACTURADO' 
              AND bp_check."invoiceId" IS NULL
        )
        AND (p_client IS NULL OR TRIM(p_client) = '' OR b.client ILIKE '%' || TRIM(p_client) || '%')
        AND (p_record IS NULL OR TRIM(p_record) = '' OR b.code ILIKE '%' || TRIM(p_record) || '%')
        AND (p_passenger IS NULL OR TRIM(p_passenger) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            INNER JOIN public."BookingProductPassangerGDS" bpp_sub ON bpp_sub."bookingProductId" = bp_sub.id
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND (
                (COALESCE(bpp_sub.firstnm, '') || ' ' || COALESCE(bpp_sub.lastnm, '')) ILIKE '%' || TRIM(p_passenger) || '%'
                OR bpp_sub.identification ILIKE '%' || TRIM(p_passenger) || '%'
            )
        ))
        AND (p_ticket IS NULL OR TRIM(p_ticket) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            INNER JOIN public."BookingProductPassangerGDS" bpp_sub ON bpp_sub."bookingProductId" = bp_sub.id
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND bpp_sub.identification ILIKE '%' || TRIM(p_ticket) || '%'
        ))
        AND (p_airline IS NULL OR TRIM(p_airline) = '' OR EXISTS (
            SELECT 1 FROM public."BookingProductGDS" bp_sub
            WHERE bp_sub."bookingId" = b.id 
              AND COALESCE(bp_sub.state, '') <> 'FACTURADO'
              AND (
                bp_sub.prestadoracode ILIKE '%' || TRIM(p_airline) || '%'
                OR bp_sub.provider ILIKE '%' || TRIM(p_airline) || '%'
            )
        ))
    ORDER BY b.id DESC
    LIMIT 50;
END;
$$;


--
-- Name: Resolution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Resolution" (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    date timestamp(6) with time zone,
    expira timestamp(6) with time zone,
    inicial bigint,
    "end" bigint,
    autoriza character varying(255),
    prefijo character varying(50),
    alerta integer,
    day integer,
    permitir boolean DEFAULT false,
    activo boolean DEFAULT true,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: fnresolucionlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnresolucionlistar() RETURNS SETOF public."Resolution"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Resolution" ORDER BY name ASC;
END;
$$;


--
-- Name: Seller; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Seller" (
    id integer NOT NULL,
    code text,
    name text NOT NULL,
    email text,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: fnsellerlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnsellerlistar() RETURNS SETOF public."Seller"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."Seller" ORDER BY name ASC;
END;
$$;


--
-- Name: fnsysconsecutivolistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnsysconsecutivolistar() RETURNS TABLE(id integer, codigo character varying, nombre character varying, "branchId" integer, "branchName" character varying, "implantId" integer, "implantName" character varying, fuente character varying, serie character varying, consecutivo bigint, "createdAt" timestamp without time zone, "updatedAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sc.id,
        sc.codigo,
        sc.nombre,
        sc."branchId",
        b.name AS "branchName",
        sc."implantId",
        imp.name AS "implantName",
        sc.fuente,
        sc.serie,
        sc.consecutivo,
        sc."createdAt",
        sc."updatedAt"
    FROM public."SysConsecutivo" sc
    LEFT JOIN public."Branch" b ON b.id = sc."branchId"
    LEFT JOIN public."Implant" imp ON imp.id = sc."implantId"
    ORDER BY sc.id DESC;
END;
$$;


--
-- Name: TicketPrinter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TicketPrinter" (
    id integer NOT NULL,
    code text,
    name text NOT NULL,
    email text,
    "isActive" boolean DEFAULT true
);


--
-- Name: fnticketprinterlistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnticketprinterlistar() RETURNS SETOF public."TicketPrinter"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."TicketPrinter" ORDER BY name ASC;
END;
$$;


--
-- Name: fnusuariolistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnusuariolistar() RETURNS SETOF jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', u.id,
            'name', u.name,
            'email', u.email,
            'roleId', u."roleId",
            'role', (
                SELECT jsonb_build_object('id', r.id, 'name', r.name)
                FROM public."Role" r
                WHERE r.id = u."roleId"
            ),
            'branchId', u."branchId",
            'branch', CASE WHEN u."branchId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', b.id, 'name', b.name, 'code', b.code)
                FROM public."Branch" b
                WHERE b.id = u."branchId"
            ) ELSE NULL END,
            'implantId', u."implantId",
            'implant', CASE WHEN u."implantId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', i.id, 'name', i.name, 'code', i.code)
                FROM public."Implant" i
                WHERE i.id = u."implantId"
            ) ELSE NULL END,
            'ticketPrinterId', u."ticketPrinterId",
            'ticketPrinter', CASE WHEN u."ticketPrinterId" IS NOT NULL THEN (
                SELECT jsonb_build_object('id', t.id, 'name', t.name, 'code', t.code)
                FROM public."TicketPrinter" t
                WHERE t.id = u."ticketPrinterId"
            ) ELSE NULL END
        )
    FROM public."User" u
    ORDER BY u.name ASC;
END;
$$;


--
-- Name: MasterVariable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MasterVariable" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: fnvariablelistar(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fnvariablelistar() RETURNS SETOF public."MasterVariable"
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public."MasterVariable" ORDER BY name ASC;
END;
$$;


--
-- Name: spAirportActualizar(integer, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spAirportActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_citiesid integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Airports" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Airports" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Airports" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "citiesId" = p_citiesId WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spAirportCrear(text, text, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spAirportCrear"(IN p_code text, IN p_name text, IN p_citiesid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Airports" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Airports" ("code", "name", "citiesId") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_citiesId) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $$;


--
-- Name: spAirportEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spAirportEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Airports" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spCityActualizar(integer, text, text, integer, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCityActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_countriesid integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Cities" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Cities" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Cities" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "countriesId" = p_countriesId, "statecode" = p_statecode, "iata" = p_iata WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spCityCrear(text, text, integer, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCityCrear"(IN p_code text, IN p_name text, IN p_countriesid integer, IN p_statecode text, IN p_iata text, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Cities" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Cities" ("code", "name", "countriesId", "statecode", "iata") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_countriesId, p_statecode, p_iata) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $$;


--
-- Name: spCityEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCityEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Cities" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spCotizacionCrear(jsonb, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCotizacionCrear"(IN p_data jsonb, IN p_acting_user_id integer, INOUT p_quotation_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_internal_number TEXT;
    v_quotation_id INT;
    v_item RECORD;
    v_tax RECORD;
    v_pax RECORD;
    v_var RECORD;
    v_pmt RECORD;
    v_combo RECORD;
    v_manual RECORD;
    v_quotation_product_id INT;
    -- Variables para validación de campos obligatorios dinámicos
    v_val_item JSONB;
    v_val_prod_id INT;
    v_mandatory_fields JSONB;
    v_field_key TEXT;
    v_model TEXT;
    v_field_name TEXT;
    v_prod_desc TEXT;
    v_has_passengers BOOLEAN;
    v_has_empty_pax_name BOOLEAN;
    v_has_payments BOOLEAN;
    v_json_field_name TEXT;
    -- Variables para validación de variables obligatorias específicas del cliente
    v_client_id INT;
    v_client_mandatory_vars JSONB;
    v_client_var_id_text TEXT;
    v_req_var_id INT;
    v_req_var_name TEXT;
    v_item_json JSONB;
    v_item_prod_id INT;
    v_item_prod_desc TEXT;
    v_has_var BOOLEAN;
    -- Variables para cálculos financieros
    v_mostrar_totalizacion BOOLEAN;
    v_comision_utilidad DOUBLE PRECISION;
    v_comision_freelance DOUBLE PRECISION;
    v_comision_propia DOUBLE PRECISION;
    v_costo_total DOUBLE PRECISION;
    v_valor_base DOUBLE PRECISION;
    v_decimals INT;
BEGIN
    -- Validaciones
    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
        WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
    ) THEN
        p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
        RETURN;
    END IF;

    -- Validación de campos obligatorios dinámicos por producto
    FOR v_val_item IN SELECT jsonb_array_elements(p_data->'items')
    LOOP
        v_val_prod_id := (v_val_item->>'productId')::INT;
        
        SELECT "mandatoryFields", "description" 
        INTO v_mandatory_fields, v_prod_desc 
        FROM public."Product" 
        WHERE id = v_val_prod_id;

        v_prod_desc := COALESCE(v_prod_desc, 'Producto #' || v_val_prod_id);

        IF v_mandatory_fields IS NOT NULL AND jsonb_typeof(v_mandatory_fields) = 'array' THEN
            FOR v_field_key IN SELECT jsonb_array_elements_text(v_mandatory_fields)
            LOOP
                v_model := split_part(v_field_key, '.', 1);
                v_field_name := split_part(v_field_key, '.', 2);

                IF v_model = 'Quotation' THEN
                    IF NULLIF(p_data->>v_field_name, '') IS NULL THEN
                        p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo general "' || v_field_name || '".';
                        RETURN;
                    END IF;
                ELSIF v_model = 'QuotationProduct' THEN
                    v_json_field_name := v_field_name;
                    IF v_field_name = 'checkInDate' THEN
                        v_json_field_name := 'checkIn';
                    ELSIF v_field_name = 'checkOutDate' THEN
                        v_json_field_name := 'checkOut';
                    ELSIF v_field_name = 'description' THEN
                        v_json_field_name := 'descripcion';
                    ELSIF v_field_name = 'service' THEN
                        IF NULLIF(v_val_item->>'service', '') IS NULL AND v_val_item->>'servicios' IS NOT NULL THEN
                            v_json_field_name := 'servicios';
                        END IF;
                    END IF;

                    IF v_field_name = 'passengers' THEN
                        v_has_passengers := FALSE;
                        v_has_empty_pax_name := FALSE;
                        
                        IF v_val_item->'passengers' IS NOT NULL AND jsonb_typeof(v_val_item->'passengers') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'passengers') > 0, FALSE) INTO v_has_passengers;
                            SELECT EXISTS (
                                SELECT 1 FROM jsonb_to_recordset(v_val_item->'passengers') AS p(name TEXT)
                                WHERE p.name IS NULL OR trim(p.name) = ''
                            ) INTO v_has_empty_pax_name;
                        END IF;

                        IF NOT v_has_passengers OR v_has_empty_pax_name THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pasajero con su nombre.';
                            RETURN;
                        END IF;
                    ELSIF v_field_name = 'payments' THEN
                        v_has_payments := FALSE;
                        IF v_val_item->'payments' IS NOT NULL AND jsonb_typeof(v_val_item->'payments') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'payments') > 0, FALSE) INTO v_has_payments;
                        END IF;

                        IF NOT v_has_payments THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pago.';
                            RETURN;
                        END IF;
                    ELSE
                        IF NULLIF(v_val_item->>v_json_field_name, '') IS NULL THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo "' || v_field_name || '".';
                            RETURN;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    -- Validación de variables obligatorias específicas del cliente
    v_client_id := NULLIF(p_data->>'clientId', '')::INT;
    IF v_client_id IS NOT NULL THEN
        SELECT "mandatoryVariables" INTO v_client_mandatory_vars
        FROM public."Client"
        WHERE id = v_client_id;

        IF v_client_mandatory_vars IS NOT NULL AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN
            FOR v_client_var_id_text IN SELECT jsonb_array_elements_text(v_client_mandatory_vars)
            LOOP
                v_req_var_id := v_client_var_id_text::INT;
                
                SELECT "name" INTO v_req_var_name FROM public."MasterVariable" WHERE id = v_req_var_id;
                v_req_var_name := COALESCE(v_req_var_name, 'Variable #' || v_req_var_id);

                FOR v_item_json IN SELECT jsonb_array_elements(p_data->'items')
                LOOP
                    v_item_prod_id := (v_item_json->>'productId')::INT;
                    SELECT "description" INTO v_item_prod_desc FROM public."Product" WHERE id = v_item_prod_id;
                    v_item_prod_desc := COALESCE(v_item_prod_desc, 'Producto #' || v_item_prod_id);

                    SELECT EXISTS (
                        SELECT 1 FROM jsonb_to_recordset(v_item_json->'variables') AS v("masterVariableId" INT, value TEXT)
                        WHERE v."masterVariableId" = v_req_var_id AND NULLIF(trim(v.value), '') IS NOT NULL
                    ) INTO v_has_var;

                    IF NOT v_has_var THEN
                        p_mensaje_resultado := 'ERROR: El cliente requiere completar la variable adicional "' || v_req_var_name || '" en el producto "' || v_item_prod_desc || '".';
                        RETURN;
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
    END IF;

    -- Obtener decimales de la moneda
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    v_internal_number := NULLIF(p_data->>'consecutivo', '');

    INSERT INTO public."Quotation" (
        "internalNumber", "date", "clientId", "currency", "exchangeRate", 
        "branchId", "implantId", "sellerId", "ticketPrinterId", 
        "baseCommissionable", "commissionPercentage", "chargesAndTaxes", 
        "totalAmount", "userId", "state", "stateDescription", "stateUpdatedAt",
        "destination", "startDate", "endDate", "passenger", "paxAdults", "paxChildren",
        "reservationCode", "copyFieldsToProducts", "manualDescription"
    ) VALUES (
        COALESCE(v_internal_number, 'TEMP_' || gen_random_uuid()::text), CURRENT_TIMESTAMP, NULLIF(p_data->>'clientId', '')::INT, p_data->>'currency', NULLIF(p_data->>'exchangeRate', '')::FLOAT,
        NULLIF(p_data->>'branchId', '')::INT, NULLIF(p_data->>'implantId', '')::INT, NULLIF(p_data->>'sellerId', '')::INT, NULLIF(p_data->>'ticketPrinterId', '')::INT,
        0, NULLIF(p_data->>'commissionPercentage', '')::FLOAT, ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision,
        ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision, p_acting_user_id, 'NUEVO', 'Creación de cotización', CURRENT_TIMESTAMP,
        p_data->>'destination', 
        CASE WHEN p_data->>'startDate' IS NOT NULL AND p_data->>'startDate' <> '' THEN (p_data->>'startDate')::TIMESTAMP ELSE NULL END,
        CASE WHEN p_data->>'endDate' IS NOT NULL AND p_data->>'endDate' <> '' THEN (p_data->>'endDate')::TIMESTAMP ELSE NULL END,
        p_data->>'passenger',
        NULLIF(p_data->>'paxAdults', '')::INT,
        NULLIF(p_data->>'paxChildren', '')::INT,
        p_data->>'reservationCode',
        COALESCE(NULLIF(p_data->>'copyFieldsToProducts', '')::BOOLEAN, TRUE),
        p_data->>'manualDescription'
    ) RETURNING id INTO v_quotation_id;

    IF v_internal_number IS NULL OR v_internal_number = '' THEN
        v_internal_number := v_quotation_id::text;
        UPDATE public."Quotation"
        SET "internalNumber" = v_internal_number
        WHERE id = v_quotation_id;
    END IF;

    -- Insertar historial de estado inicial
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (v_quotation_id, 'NUEVO', 'Creación de cotización', CURRENT_TIMESTAMP, p_acting_user_id);

    FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
    LOOP
        DECLARE
            v_combo_real_id INT := COALESCE(v_combo."comboId", v_combo.id);
            v_cupos_disponibles INT;
            v_combo_name TEXT;
        BEGIN
            SELECT "cupos", "name" INTO v_cupos_disponibles, v_combo_name
            FROM public."Combo" WHERE id = v_combo_real_id;

            IF v_cupos_disponibles IS NOT NULL AND v_cupos_disponibles <= 0 THEN
                p_mensaje_resultado := 'ERROR: El combo "' || COALESCE(v_combo_name, v_combo_real_id::TEXT) || '" no tiene cupos disponibles.';
                RETURN;
            END IF;

            INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
            VALUES (v_quotation_id, v_combo_real_id);

            -- Descontar 1 cupo
            UPDATE public."Combo" SET "cupos" = "cupos" - 1 WHERE id = v_combo_real_id;
        END;
    END LOOP;

    IF p_data->'manualServices' IS NOT NULL AND jsonb_typeof(p_data->'manualServices') = 'array' THEN
        FOR v_manual IN SELECT * FROM jsonb_to_recordset(p_data->'manualServices') AS x(
            "providerName" TEXT, "serviceName" TEXT, "cost" FLOAT, "salePrice" FLOAT, "utility" FLOAT
        )
        LOOP
            INSERT INTO public."QuotationManualService" (
                "quotationId", "providerName", "serviceName", "cost", "salePrice", "utility"
            ) VALUES (
                v_quotation_id, 
                v_manual."providerName", 
                v_manual."serviceName", 
                COALESCE(v_manual."cost", 0), 
                COALESCE(v_manual."salePrice", 0), 
                COALESCE(v_manual."utility", COALESCE(v_manual."salePrice", 0) - COALESCE(v_manual."cost", 0))
            );
        END LOOP;
    END IF;

    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                      "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                      "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                      "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                      "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "payments" JSONB, "inNationality" INT,
                      "service" TEXT, "servicios" TEXT, "descripcion" TEXT, "passenger" TEXT
                  )
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission", 
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_quotation_id, v_item."productId", v_item.quantity, 
            ROUND(v_item.price::numeric, v_decimals)::double precision, 
            ROUND(v_item.cost::numeric, v_decimals)::double precision, 
            NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
            CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
            CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
            v_item.nights, v_item."paxAdults", v_item."paxChildren",
            v_item."serviceType", v_item."destination", v_item."reservationCode", 
            ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
            ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
            NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
            COALESCE(v_item."service", v_item."servicios"), COALESCE(v_item."servicios", v_item."service"), v_item."descripcion",
            v_item."passenger"
        ) RETURNING id INTO v_quotation_product_id;

        IF v_item.passengers IS NOT NULL THEN
            FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
            LOOP
                INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                VALUES (v_quotation_product_id, v_pax.name, v_pax.document);
            END LOOP;
        END IF;

        IF v_item."appliedTaxes" IS NOT NULL THEN
            FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
            LOOP
                INSERT INTO public."QuotationProductTax" (
                    "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                )
                SELECT v_quotation_product_id, ct.id, ct.value, ct."valueType", 
                       ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                       CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                FROM public."ChargeAndTax" ct
                WHERE ct.id = v_tax."chargeAndTaxId";
            END LOOP;
        END IF;

        IF v_item.variables IS NOT NULL THEN
            FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
            LOOP
                INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                VALUES (v_quotation_product_id, v_var."masterVariableId", v_var.value);
            END LOOP;
        END IF;

        IF v_item.payments IS NOT NULL THEN
            FOR v_pmt IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(
                "amount" FLOAT, "paymentMethod" TEXT, "date" TEXT, "reference" TEXT,
                "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT
            )
            LOOP
                INSERT INTO public."QuotationProductPayment" (
                    "quotationProductId", "amount", "paymentMethod", "reference", "date",
                    "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                ) VALUES (
                    v_quotation_product_id, 
                    ROUND(v_pmt."amount"::numeric, v_decimals)::double precision, 
                    v_pmt."paymentMethod", v_pmt."reference",
                    CASE WHEN v_pmt."date" IS NOT NULL AND v_pmt."date" <> '' THEN v_pmt."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END,
                    v_pmt."creditCardId", v_pmt."cardNumber", v_pmt."authorizationCode", v_pmt."voucher", v_pmt."expirationDate"
                );
            END LOOP;
        END IF;
    END LOOP;

    -- Calcular y actualizar el totalAmount y los nuevos campos financieros
    SELECT 
        COALESCE(SUM(qp.cost), 0.0), 
        COALESCE(SUM(
            qp.price * qp.quantity + COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM public."QuotationProductTax" qpt2
                JOIN public."ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0.0)
        ), 0.0)
    INTO v_costo_total, v_valor_base
    FROM public."QuotationProduct" qp
    WHERE qp."quotationId" = v_quotation_id;

    SELECT COALESCE(value = 'true', FALSE) INTO v_mostrar_totalizacion
    FROM public."SystemParameter"
    WHERE code = 'MOSTRAR_TOTALIZACION_COTIZACION';

    v_comision_freelance := COALESCE(NULLIF(p_data->>'comisionFreelancePercentage', '')::DOUBLE PRECISION, 0.0);

    IF v_mostrar_totalizacion THEN
        v_comision_utilidad := ROUND(public.fn_calcular_porcentaje_comision(public.fn_calcular_utilidad(v_valor_base, v_costo_total), v_valor_base)::NUMERIC, 2)::DOUBLE PRECISION;
        v_comision_propia := v_comision_utilidad - v_comision_freelance;
    ELSE
        v_comision_propia := public.fn_calcular_comision_resta(
            COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
            v_comision_freelance
        );
    END IF;

    UPDATE public."Quotation"
    SET 
        "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0)
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = v_quotation_id
        ))::numeric, v_decimals)::double precision,
        "costoTotal" = ROUND(v_costo_total::numeric, v_decimals)::double precision,
        "valorBase" = ROUND(v_valor_base::numeric, v_decimals)::double precision,
        "comisionTotalPercentage" = COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
        "comisionFreelancePercentage" = v_comision_freelance,
        "comisionPropiaPercentage" = v_comision_propia,
        "commissionPercentage" = v_comision_propia,
        "utilidad" = ROUND(public.fn_calcular_utilidad(v_valor_base, v_costo_total)::numeric, v_decimals)::double precision,
        "comisionUtilidadPercentage" = public.fn_calcular_porcentaje_comision(
            public.fn_calcular_utilidad(v_valor_base, v_costo_total),
            v_valor_base
        ),
        "comisionFreelanceValue" = ROUND(public.fn_calcular_valor_comision(v_comision_freelance, v_valor_base)::numeric, v_decimals)::double precision,
        "comisionPropiaValue" = ROUND(public.fn_calcular_valor_comision(v_comision_propia, v_valor_base)::numeric, v_decimals)::double precision
    WHERE id = v_quotation_id;

    p_quotation_id := v_quotation_id;
    p_mensaje_resultado := 'SUCCESS: Cotización creada correctamente con ID ' || v_quotation_id;

    -- Registrar en Auditoría
    CALL public."spLogRegistrar"(
        p_acting_user_id, 
        'QUOTATION', 
        'CREATE', 
        'Se creó la cotización ' || v_internal_number || ' (ID: ' || v_quotation_id || ')', 
        p_data, 
        v_quotation_id -- Reutilizamos variable para el logId temporal
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spCountriesActualizar(integer, text, text, text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountriesActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public."spCountryActualizar"(p_id, p_code, p_name, p_dane, p_region, p_prefix, p_curencyId, p_user_id, p_mensaje_resultado);
END;
$$;


--
-- Name: spCountriesCrear(text, text, text, text, text, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountriesCrear"(IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public."spCountryCrear"(p_code, p_name, p_dane, p_region, p_prefix, p_curencyId, p_user_id, p_id, p_mensaje_resultado);
END;
$$;


--
-- Name: spCountriesEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountriesEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public."spCountryEliminar"(p_id, p_user_id, p_mensaje_resultado);
END;
$$;


--
-- Name: spCountryActualizar(integer, text, text, text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountryActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Countries" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Countries" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Countries" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "dane" = p_dane, "region" = p_region, "prefix" = p_prefix, "curencyId" = p_curencyId WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spCountryCrear(text, text, text, text, text, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountryCrear"(IN p_code text, IN p_name text, IN p_dane text, IN p_region text, IN p_prefix text, IN p_curencyid integer, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Countries" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Countries" ("code", "name", "dane", "region", "prefix", "curencyId") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), p_dane, p_region, p_prefix, p_curencyId) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $$;


--
-- Name: spCountryEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCountryEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Countries" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spCreditCardActualizar(integer, text, text, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCreditCardActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_type text, IN p_inactive boolean, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existente integer;
BEGIN
    -- Validar existencia
    SELECT id INTO v_existente FROM public."CreditCard" WHERE id = p_id;
    IF v_existente IS NULL THEN
        p_mensaje_resultado := 'ERROR: La tarjeta de crédito no existe.';
        RETURN;
    END IF;

    -- Validar código único
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        SELECT id INTO v_existente FROM public."CreditCard" WHERE "code" = p_code AND id <> p_id;
        IF v_existente IS NOT NULL THEN
            p_mensaje_resultado := 'ERROR: El código ya está registrado para otra tarjeta de crédito.';
            RETURN;
        END IF;
    END IF;

    -- Validar nombre
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        p_mensaje_resultado := 'ERROR: El nombre de la tarjeta es obligatorio.';
        RETURN;
    END IF;

    UPDATE public."CreditCard"
    SET
        "code" = COALESCE(TRIM(p_code), ''),
        "name" = TRIM(p_name),
        "type" = COALESCE(TRIM(p_type), ''),
        "inactive" = p_inactive
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
    
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spCreditCardCrear(text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCreditCardCrear"(IN p_code text, IN p_name text, IN p_type text, IN p_user_id integer, INOUT p_card_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existente integer;
BEGIN
    -- Validar código único
    IF p_code IS NOT NULL AND TRIM(p_code) <> '' THEN
        SELECT id INTO v_existente FROM public."CreditCard" WHERE "code" = p_code;
        IF v_existente IS NOT NULL THEN
            p_mensaje_resultado := 'ERROR: El código ya está registrado para otra tarjeta de crédito.';
            RETURN;
        END IF;
    END IF;

    -- Validar nombre
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        p_mensaje_resultado := 'ERROR: El nombre de la tarjeta es obligatorio.';
        RETURN;
    END IF;

    INSERT INTO public."CreditCard" (
        "code",
        "name",
        "type",
        "inactive"
    ) VALUES (
        COALESCE(TRIM(p_code), ''),
        TRIM(p_name),
        COALESCE(TRIM(p_type), ''),
        false
    ) RETURNING id INTO p_card_id;

    p_mensaje_resultado := 'SUCCESS';
    
    -- Log the action (handled by backend or DB trigger)
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_card_id := 0;
END;
$$;


--
-- Name: spCreditCardEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spCreditCardEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existente integer;
BEGIN
    -- Validar existencia
    SELECT id INTO v_existente FROM public."CreditCard" WHERE id = p_id;
    IF v_existente IS NULL THEN
        p_mensaje_resultado := 'ERROR: La tarjeta de crédito no existe.';
        RETURN;
    END IF;

    -- Podríamos verificar si tiene dependencias en InvoicesProductPayment
    -- antes de eliminar. Por simplicidad, intentamos eliminar directamente
    -- y si hay constraint, saltará excepción.
    
    DELETE FROM public."CreditCard" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
    
EXCEPTION
    WHEN foreign_key_violation THEN
        p_mensaje_resultado := 'ERROR: No se puede eliminar la tarjeta porque está en uso.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spDocumentResolutionActualizar(integer, integer, integer, text, integer, integer, integer, timestamp without time zone, text, timestamp without time zone, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spDocumentResolutionActualizar"(IN p_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_resolution_number text, IN p_initial_number integer, IN p_final_number integer, IN p_current_number integer, IN p_resolution_date timestamp without time zone, IN p_prefix text, IN p_expiration_date timestamp without time zone, IN p_is_active boolean, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID de resolución es obligatorio.';
        RETURN;
    END IF;

    IF p_branch_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        RETURN;
    END IF;

    IF p_resolution_number IS NULL OR TRIM(p_resolution_number) = '' THEN
        p_mensaje_resultado := 'ERROR: El número de resolución es obligatorio.';
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_final_number IS NULL OR p_initial_number > p_final_number THEN
        p_mensaje_resultado := 'ERROR: La numeración inicial no puede ser mayor que la numeración final.';
        RETURN;
    END IF;

    -- Si se activa esta resolución, deshabilitar las demás de la misma sucursal / implante
    IF COALESCE(p_is_active, false) = true THEN
        UPDATE public."DocumentResolution"
        SET "isActive" = false
        WHERE "branchId" = p_branch_id
          AND (
              ("implantId" IS NULL AND p_implant_id IS NULL)
              OR ("implantId" = p_implant_id)
          )
          AND id <> p_id
          AND "isActive" = true;
    END IF;

    UPDATE public."DocumentResolution"
    SET 
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "resolutionNumber" = TRIM(p_resolution_number),
        "initialNumber" = p_initial_number,
        "finalNumber" = p_final_number,
        "currentNumber" = COALESCE(p_current_number, "currentNumber"),
        "resolutionDate" = COALESCE(p_resolution_date, "resolutionDate"),
        "prefix" = TRIM(p_prefix),
        "expirationDate" = COALESCE(p_expiration_date, "expirationDate"),
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spDocumentResolutionCrear(integer, integer, text, integer, integer, timestamp without time zone, text, timestamp without time zone, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spDocumentResolutionCrear"(IN p_branch_id integer, IN p_implant_id integer, IN p_resolution_number text, IN p_initial_number integer, IN p_final_number integer, IN p_resolution_date timestamp without time zone, IN p_prefix text, IN p_expiration_date timestamp without time zone, IN p_is_active boolean, IN p_user_id integer, INOUT p_resolution_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_curr integer;
BEGIN
    -- Validaciones básicas
    IF p_branch_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_resolution_number IS NULL OR TRIM(p_resolution_number) = '' THEN
        p_mensaje_resultado := 'ERROR: El número de resolución es obligatorio.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_final_number IS NULL OR p_initial_number > p_final_number THEN
        p_mensaje_resultado := 'ERROR: La numeración inicial no puede ser mayor que la numeración final.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    IF p_expiration_date IS NULL THEN
        p_mensaje_resultado := 'ERROR: La fecha de vencimiento es obligatoria.';
        p_resolution_id := 0;
        RETURN;
    END IF;

    v_curr := COALESCE(p_initial_number, 1);

    -- REGLA: Si la nueva resolución es activa, desactivar cualquier otra resolución activa previa para esta misma combinación sucursal / implante
    IF COALESCE(p_is_active, true) = true THEN
        UPDATE public."DocumentResolution"
        SET "isActive" = false
        WHERE "branchId" = p_branch_id
          AND (
              ("implantId" IS NULL AND p_implant_id IS NULL)
              OR ("implantId" = p_implant_id)
          )
          AND "isActive" = true;
    END IF;

    INSERT INTO public."DocumentResolution" (
        "branchId",
        "implantId",
        "resolutionNumber",
        "initialNumber",
        "finalNumber",
        "currentNumber",
        "resolutionDate",
        "prefix",
        "expirationDate",
        "isActive",
        "createdAt"
    ) VALUES (
        p_branch_id,
        p_implant_id,
        TRIM(p_resolution_number),
        p_initial_number,
        p_final_number,
        v_curr,
        COALESCE(p_resolution_date, CURRENT_TIMESTAMP),
        TRIM(p_prefix),
        p_expiration_date,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_resolution_id := 0;
END;
$$;


--
-- Name: spDocumentResolutionEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spDocumentResolutionEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID de la resolución es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."DocumentResolution"
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spEquivalencesInterfacesConsultar(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spEquivalencesInterfacesConsultar"(IN p_id_interfaces integer DEFAULT NULL::integer, IN p_id_master integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- This procedure returns a result set. Since it's a procedure, returning result sets
    -- is not native in the same way as functions, but we can return a refcursor or
    -- just use a FUNCTION instead for querying.
    -- To align with the prompt requesting a "Consultar" SP, we can just do a select
    -- or we change it to a FUNCTION. I'll create a FUNCTION as well to make it easy to consume.
    -- But since prompt says "consultara spEquivalencesInterfacesConsultar", maybe it means a function or SP returning table.
    -- PostgreSQL 11+ procedures don't return tables directly without INOUT refcursors.
    -- I will drop this and create a FUNCTION fnEquivalencesInterfacesConsultar instead, or an SP that returns a refcursor.
    -- Let's define it as a PROCEDURE that doesn't strictly return, but we will create the FUNCTION.
END;
$$;


--
-- Name: spEquivalencesInterfacesCrear(integer, integer, text, text, text, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spEquivalencesInterfacesCrear"(IN p_id_interfaces integer, IN p_id_master integer, IN p_cd_maestro text, IN p_cd_codigo text, IN p_cd_codigointe text, IN p_user_id integer, INOUT p_new_id integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_log_id INT;
BEGIN
    INSERT INTO public."EquivalencesInterfaces" (
        id_interfaces, 
        id_master, 
        cd_maestro, 
        cd_codigo, 
        cd_codigoInte
    ) VALUES (
        p_id_interfaces,
        p_id_master,
        p_cd_maestro,
        p_cd_codigo,
        p_cd_codigoInte
    ) RETURNING id INTO p_new_id;

    -- Registrar en SystemLog
    CALL public."spLogRegistrar"(
        p_user_id,
        'EQUIVALENCES_INTERFACES',
        'CREATE',
        'Creación de equivalencia de interface con ID: ' || p_new_id,
        jsonb_build_object(
            'id_interfaces', p_id_interfaces,
            'id_master', p_id_master,
            'cd_maestro', p_cd_maestro,
            'cd_codigo', p_cd_codigo,
            'cd_codigoInte', p_cd_codigoInte
        ),
        v_log_id
    );
END;
$$;


--
-- Name: spEquivalencesInterfacesEliminar(integer, integer, boolean); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spEquivalencesInterfacesEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_success boolean DEFAULT false)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_log_id INT;
BEGIN
    DELETE FROM public."EquivalencesInterfaces"
    WHERE id = p_id;

    IF FOUND THEN
        p_success := true;
        
        -- Registrar en SystemLog
        CALL public."spLogRegistrar"(
            p_user_id,
            'EQUIVALENCES_INTERFACES',
            'DELETE',
            'Eliminación de equivalencia de interface con ID: ' || p_id,
            jsonb_build_object('id', p_id),
            v_log_id
        );
    ELSE
        p_success := false;
    END IF;
END;
$$;


--
-- Name: spFacturaActualizarEstado(jsonb); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spFacturaActualizarEstado"(IN p_results jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_item RECORD;
BEGIN
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_results) AS x("invoiceId" INT, "success" INT, "message" TEXT)
    LOOP
        -- success = 1 (true) maps to EXPORTADO, success = 0 (false) maps to ERROR_EXPORTACION
        IF v_item."success" = 1 THEN
            UPDATE public."Invoices"
            SET "state" = 'EXPORTADO'
            WHERE id = v_item."invoiceId";
        ELSE
            UPDATE public."Invoices"
            SET "state" = 'ERROR_EXPORTACION'
            WHERE id = v_item."invoiceId";
        END IF;
    END LOOP;
END;
$$;


--
-- Name: spImportInvoices(text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spImportInvoices"(IN p_text_data text, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de facturas desde TEXTO PLANO DELIMITADO con soporte para pagos e itinerarios.
    Formato esperado: 40 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_invoice_record RECORD;
    v_product_record RECORD;
    v_invoice_id INT;
    v_ip_id INT;
    v_internal_number TEXT;
    v_client_id INT;
    v_branch_id INT;
    v_implant_id INT;
    v_seller_id INT;
    v_ticket_printer_id INT;
    v_product_id INT;
    v_provider_id INT;
    v_prestadora_id INT;
    v_tax_id INT;
    v_main_tax_id INT;
    v_variable_id INT;
    v_ticket_type_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_pay_item TEXT;
    v_pay_parts TEXT[];
    v_pay_method TEXT;
    v_pay_ref TEXT;
    v_pay_date TIMESTAMP;
    v_pay_card_id INT;
    v_pay_card_num TEXT;
    v_pay_auth TEXT;
    v_pay_voucher TEXT;
    v_pay_exp TEXT;
    v_itin_item TEXT;
    v_itin_parts TEXT[];
    v_itin_origin TEXT;
    v_itin_dest TEXT;
    v_itin_class TEXT;
    v_itin_check_in TIMESTAMP;
    v_itin_check_out TIMESTAMP;
    v_itin_orden INT;
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_invoice_rows (
        row_id INT GENERATED ALWAYS AS IDENTITY, --0
        grupo TEXT, --1
        cliente_doc TEXT, --2
        sucursal_cd TEXT, --3
        implant_cd TEXT, --4
        vendedor_cd TEXT, --5
        tiqueteador_cd TEXT, --6
        moneda TEXT, --7
        tasa_cambio DECIMAL, -- 8
        comision_global DECIMAL, -- 9
        cargos_global DECIMAL, --10
        producto_cd TEXT, --11
        proveedor_nm TEXT, --12 
        proveedor_cd TEXT, --13
        prestadora_cd TEXT, --14
        impuestos_str TEXT, --15
        variables_str TEXT, --16
        pasajeros_str TEXT, --17
        precio DECIMAL, --18
        cantidad INT, --19
        check_in TIMESTAMP, --20
        check_out TIMESTAMP, --21
        pax_adultos INT, --22
        pax_ninos INT, --23
        destino TEXT, --24
        tipo_servicio TEXT, --25
        reserva TEXT, --26
        com_vendedor DECIMAL, --27
        com_tiqueteador DECIMAL, --28
        combos_str TEXT, --29
        nacionalidad INT DEFAULT 1, --30
        cargo_principal_cd TEXT, --31
        costo DECIMAL DEFAULT 0, --32
        servicios TEXT, --33
        descripcion TEXT, --34
        itinerary TEXT, --35
        class TEXT, --36
        airline TEXT, --37
        tipo_tiquete_cd TEXT, --38
        pagos_str TEXT, --39
        itinerarios_str TEXT, --40
        fuente TEXT, --41
        serie TEXT, --42
        consecutivo TEXT --43
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_invoice_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            -- Validar formato de Check-In (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[20]) <> '' AND TRIM(v_cols[20]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-In. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[20]);
                RETURN;
            END IF;

            -- Validar formato de Check-Out (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[21]) <> '' AND TRIM(v_cols[21]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-Out. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[21]);
                RETURN;
            END IF;
            
            INSERT INTO tmp_import_invoice_rows (
                grupo, cliente_doc, sucursal_cd, implant_cd, vendedor_cd, tiqueteador_cd,
                moneda, tasa_cambio, comision_global, cargos_global, producto_cd,
                proveedor_nm, proveedor_cd, prestadora_cd, impuestos_str, variables_str,
                pasajeros_str, precio, cantidad, check_in, check_out, pax_adultos, pax_ninos,
                destino, tipo_servicio, reserva, com_vendedor, com_tiqueteador, combos_str,
                nacionalidad, cargo_principal_cd, costo, servicios, descripcion, itinerary,
                class, airline, tipo_tiquete_cd, pagos_str, itinerarios_str,
                fuente, serie, consecutivo
            ) VALUES (
                TRIM(v_cols[1]), -- grupo 
                TRIM(v_cols[2]), -- cliente_doc 
                TRIM(v_cols[3]), -- sucursal_cd
                TRIM(v_cols[4]), -- implant_cd
                TRIM(v_cols[5]), -- vendedor_cd
                TRIM(v_cols[6]), -- tiqueteador_cd
                TRIM(v_cols[7]), -- moneda
                NULLIF(TRIM(v_cols[8]), '')::DECIMAL, -- tasa_cambio
                NULLIF(TRIM(v_cols[9]), '')::DECIMAL, -- comision_global
                NULLIF(TRIM(v_cols[10]), '')::DECIMAL, -- cargos_global
                TRIM(v_cols[11]), -- Producto Codigo
                TRIM(v_cols[12]), -- Prov Nombre
                TRIM(v_cols[13]), -- Prov Codigo
                TRIM(v_cols[14]), -- Prestadora Codigo
                TRIM(v_cols[15]), -- Impuestos
                TRIM(v_cols[16]), -- Variables
                TRIM(v_cols[17]), -- Pasajeros
                NULLIF(TRIM(v_cols[18]), '')::DECIMAL, -- precio
                NULLIF(TRIM(v_cols[19]), '')::INT, -- cantidad
                CASE WHEN TRIM(v_cols[20]) <> '' THEN TRIM(v_cols[20])::TIMESTAMP ELSE NULL END, -- check_in
                CASE WHEN TRIM(v_cols[21]) <> '' THEN TRIM(v_cols[21])::TIMESTAMP ELSE NULL END, -- check_out
                NULLIF(TRIM(v_cols[22]), '')::INT, -- pax_adultos
                NULLIF(TRIM(v_cols[23]), '')::INT, -- pax_ninos
                TRIM(v_cols[24]), -- destino
                TRIM(v_cols[25]), -- tipo_servicio
                TRIM(v_cols[26]), -- reserva 
                NULLIF(TRIM(v_cols[27]), '')::DECIMAL, -- comision vendedor
                NULLIF(TRIM(v_cols[28]), '')::DECIMAL, -- comision tiqueteador
                TRIM(v_cols[29]), -- codigo combos
                COALESCE(NULLIF(TRIM(v_cols[30]), '')::INT, 1), -- nacionalidad
                TRIM(v_cols[31]), -- cargo_principal_cd
                NULLIF(TRIM(v_cols[32]), '')::DECIMAL, -- costo
                TRIM(v_cols[33]), -- servicios
                TRIM(v_cols[34]), -- descripcion
                TRIM(v_cols[35]), -- itinerary
                TRIM(v_cols[36]), -- class
                TRIM(v_cols[37]), -- airline
                TRIM(v_cols[38]),  -- tipo_tiquete_cd
                TRIM(v_cols[39]),  -- pagos_str
                TRIM(v_cols[40]),  -- itinerarios_str
                TRIM(v_cols[41]),  -- fuente
                TRIM(v_cols[42]),  -- serie
                TRIM(v_cols[43])   -- consecutivo
            );
        EXCEPTION WHEN OTHERS THEN
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': ' || SQLERRM || ' (Valor: ' || v_row_text || ')';
            RETURN;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos de Facturas
    FOR v_invoice_record IN (
        SELECT grupo, 
               MAX(cliente_doc) as cliente_doc, 
               MAX(sucursal_cd) as sucursal_cd, 
               MAX(implant_cd) as implant_cd, 
               MAX(vendedor_cd) as vendedor_cd, 
               MAX(tiqueteador_cd) as tiqueteador_cd, 
               MAX(moneda) as moneda, 
               MAX(tasa_cambio) as tasa_cambio, 
               MAX(comision_global) as comision_global, 
               MAX(cargos_global) as cargos_global,
               MAX(combos_str) as combos_str,
               MAX(fuente) as fuente,
               MAX(serie) as serie,
               MAX(consecutivo) as consecutivo
        FROM tmp_import_invoice_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_invoice_record.cliente_doc;
        IF v_client_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Cliente con documento o código "' || v_invoice_record.cliente_doc || '" no encontrado en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_invoice_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Sucursal con código "' || v_invoice_record.sucursal_cd || '" no encontrada en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_invoice_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_invoice_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_invoice_record.tiqueteador_cd);

        -- Obtener decimales de la moneda
        v_decimals := public.fn_obtener_decimales_moneda(COALESCE(v_invoice_record.moneda, 'COP'));

        v_internal_number := 'INV-SP-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;

        INSERT INTO public."Invoices" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId", "state",
            "fuente", "serie", "consecutivo"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_invoice_record.moneda, 'COP'), 
            COALESCE(v_invoice_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_invoice_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_invoice_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id, 'NUEVO',
            v_invoice_record.fuente, v_invoice_record.serie, v_invoice_record.consecutivo
        ) RETURNING id INTO v_invoice_id;

        v_created_ids := v_created_ids || v_invoice_id || ',';

        v_total_amount := COALESCE(v_invoice_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_invoice_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId") VALUES (v_invoice_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."InvoicesProduct" (
                                "invoiceId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_invoice_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_ip_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."InvoicesProductTax" (
                                "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_ip_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
                                   ROUND(cpt.amount::numeric, v_decimals)::double precision, cpt."isMain"
                            FROM public."ComboProductTax" cpt
                            JOIN public."ChargeAndTax" ct ON cpt."chargeAndTaxId" = ct.id
                            WHERE cpt."comboProductId" = v_cp_record.id;
                            
                            -- Sumar impuestos al total
                            v_total_amount := v_total_amount + COALESCE((SELECT SUM(amount) FROM public."ComboProductTax" WHERE "comboProductId" = v_cp_record.id), 0);
                        END LOOP;
                    END IF;
                END;
            END LOOP;
        END IF;

        -- Procesar Productos Individuales
        FOR v_product_record IN (SELECT * FROM tmp_import_invoice_rows WHERE grupo = v_invoice_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN 
                DECLARE
                    v_temp_msg TEXT;
                BEGIN
                    CALL public.spProductoCrear(
                        v_product_record.producto_cd,
                        COALESCE(v_product_record.tipo_servicio, 'Tiquete'),
                        COALESCE(v_product_record.descripcion, 'Tiquete ' || v_product_record.producto_cd),
                        COALESCE(v_product_record.precio, 0),
                        COALESCE(v_product_record.costo, 0),
                        NULL, 
                        COALESCE(v_product_record.tipo_servicio, 'Aire'),
                        p_user_id,
                        v_product_id,
                        v_temp_msg
                    );
                    IF v_temp_msg LIKE 'ERROR%' THEN
                        p_mensaje_resultado := v_temp_msg;
                        RETURN;
                    END IF;
                END;
            END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            SELECT id INTO v_prestadora_id FROM public."Prestadora" WHERE LOWER(code) = LOWER(v_product_record.prestadora_cd);

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_ticket_type_id := NULL;
            IF v_product_record.tipo_tiquete_cd <> '' THEN
                SELECT id INTO v_ticket_type_id FROM public."TicketType" WHERE LOWER(code) = LOWER(v_product_record.tipo_tiquete_cd);
            END IF;

            v_ip_id := NULL;
            SELECT id INTO v_ip_id FROM public."InvoicesProduct" 
            WHERE "invoiceId" = v_invoice_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_ip_id IS NOT NULL THEN
                UPDATE public."InvoicesProduct" SET
                    "quantity" = COALESCE(v_product_record.cantidad, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "cost" = ROUND(COALESCE(v_product_record.costo, "cost")::numeric, v_decimals)::double precision,
                    "providerId" = COALESCE(v_provider_id, "providerId"),
                    "prestadoraId" = COALESCE(v_prestadora_id, "prestadoraId"),
                    "checkInDate" = COALESCE(v_product_record.check_in, "checkInDate"),
                    "checkOutDate" = COALESCE(v_product_record.check_out, "checkOutDate"),
                    "nights" = CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                                 THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                                 ELSE "nights" END,
                    "paxAdults" = COALESCE(v_product_record.pax_adultos, "paxAdults"),
                    "paxChildren" = COALESCE(v_product_record.pax_ninos, "paxChildren"),
                    "serviceType" = COALESCE(v_product_record.tipo_servicio, "serviceType"),
                    "destination" = COALESCE(v_product_record.destino, "destination"),
                    "reservationCode" = COALESCE(v_product_record.reserva, "reservationCode"),
                    "sellerCommission" = ROUND(COALESCE(v_product_record.com_vendedor, "sellerCommission")::numeric, v_decimals)::double precision,
                    "ticketPrinterCommission" = ROUND(COALESCE(v_product_record.com_tiqueteador, "ticketPrinterCommission")::numeric, v_decimals)::double precision,
                    "inNationality" = COALESCE(v_product_record.nacionalidad, "inNationality"),
                    "mainTaxId" = COALESCE(v_main_tax_id, "mainTaxId"),
                    "servicios" = COALESCE(v_product_record.servicios, "servicios"),
                    "descripcion" = COALESCE(v_product_record.descripcion, "descripcion"),
                    "itinerary" = COALESCE(v_product_record.itinerary, "itinerary"),
                    "class" = COALESCE(v_product_record.class, "class"),
                    "airline" = COALESCE(v_product_record.airline, "airline"),
                    "ticketTypeId" = COALESCE(v_ticket_type_id, "ticketTypeId")
                WHERE id = v_ip_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."InvoicesProductTax" WHERE "invoiceProductId" = v_ip_id;
                END IF;
            ELSE
                IF v_invoice_record.combos_str IS NOT NULL AND v_invoice_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."InvoicesProduct" (
                    "invoiceId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "comboId", "mainTaxId", "inNationality", "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
                ) VALUES (
                    v_invoice_id, v_product_id, COALESCE(v_product_record.cantidad, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.costo, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    NULL, v_main_tax_id, COALESCE(v_product_record.nacionalidad, 1),
                    v_product_record.servicios, v_product_record.descripcion, v_product_record.itinerary, v_product_record.class, v_product_record.airline, v_ticket_type_id
                ) RETURNING id INTO v_ip_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.cantidad, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductTax" (
                            "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                        ) 
                        SELECT v_ip_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision,
                               CASE WHEN v_main_tax_id = id THEN TRUE ELSE FALSE END
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                    VALUES (v_ip_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                        VALUES (v_ip_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pagos
            IF v_product_record.pagos_str IS NOT NULL AND v_product_record.pagos_str <> '' THEN
                FOREACH v_pay_item IN ARRAY string_to_array(v_product_record.pagos_str, '|') LOOP
                    v_pay_parts := string_to_array(v_pay_item, ':');
                    
                    v_pay_method := NULLIF(TRIM(v_pay_parts[2]), '');
                    v_pay_ref := NULLIF(TRIM(v_pay_parts[3]), '');
                    
                    v_pay_date := CURRENT_TIMESTAMP;
                    IF v_pay_parts[4] IS NOT NULL AND TRIM(v_pay_parts[4]) <> '' THEN
                        v_pay_date := TRIM(v_pay_parts[4])::TIMESTAMP;
                    END IF;

                    v_pay_card_id := NULL;
                    IF v_pay_parts[5] IS NOT NULL AND TRIM(v_pay_parts[5]) <> '' THEN
                        v_pay_card_id := TRIM(v_pay_parts[5])::INT;
                    END IF;

                    v_pay_card_num := NULLIF(TRIM(v_pay_parts[6]), '');
                    v_pay_auth := NULLIF(TRIM(v_pay_parts[7]), '');
                    v_pay_voucher := NULLIF(TRIM(v_pay_parts[8]), '');
                    v_pay_exp := NULLIF(TRIM(v_pay_parts[9]), '');

                    INSERT INTO public."InvoicesProductPayment" (
                        "invoiceProductId", "amount", "paymentMethod", "reference", "date", 
                        "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                    ) VALUES (
                        v_ip_id, 
                        ROUND(NULLIF(TRIM(v_pay_parts[1]), '')::numeric, v_decimals)::double precision, 
                        v_pay_method, 
                        v_pay_ref, 
                        v_pay_date, 
                        v_pay_card_id, 
                        v_pay_card_num, 
                        v_pay_auth, 
                        v_pay_voucher, 
                        v_pay_exp
                    );
                END LOOP;
            END IF;

            -- Split para Itinerarios
            IF v_product_record.itinerarios_str IS NOT NULL AND v_product_record.itinerarios_str <> '' THEN
                FOREACH v_itin_item IN ARRAY string_to_array(v_product_record.itinerarios_str, '|') LOOP
                    v_itin_parts := string_to_array(v_itin_item, ':');
                    
                    v_itin_origin := NULLIF(TRIM(v_itin_parts[1]), '');
                    v_itin_dest := NULLIF(TRIM(v_itin_parts[2]), '');
                    v_itin_class := NULLIF(TRIM(v_itin_parts[3]), '');
                    
                    v_itin_check_in := NULL;
                    IF v_itin_parts[4] IS NOT NULL AND TRIM(v_itin_parts[4]) <> '' THEN
                        v_itin_check_in := TRIM(v_itin_parts[4])::TIMESTAMP;
                    END IF;

                    v_itin_check_out := NULL;
                    IF v_itin_parts[5] IS NOT NULL AND TRIM(v_itin_parts[5]) <> '' THEN
                        v_itin_check_out := TRIM(v_itin_parts[5])::TIMESTAMP;
                    END IF;

                    v_itin_orden := NULL;
                    IF v_itin_parts[6] IS NOT NULL AND TRIM(v_itin_parts[6]) <> '' THEN
                        v_itin_orden := TRIM(v_itin_parts[6])::INT;
                    END IF;

                    INSERT INTO public."InvoicesProductItinerary" (
                        "invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "orden"
                    ) VALUES (
                        v_ip_id, 
                        v_itin_origin, 
                        v_itin_dest, 
                        v_itin_class, 
                        v_itin_check_in, 
                        v_itin_check_out, 
                        v_itin_orden
                    );
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en InvoicesProductTax
        UPDATE public."Invoices"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(ipt."explicitAmount"), 0) AS cargos_global
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = v_invoice_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_invoice_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' facturas importadas. [' || RTRIM(v_created_ids, ',') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;


--
-- Name: spImportQuotation(text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spImportQuotation"(IN p_text_data text, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Importación masiva de cotizaciones desde TEXTO PLANO DELIMITADO.
    Formato esperado: 28 Columnas separadas por '^' y Filas por salto de línea.
*/
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_quotation_record RECORD;
    v_product_record RECORD;
    v_quotation_id INT;
    v_qp_id INT;
    v_internal_number TEXT;
    v_client_id INT;
    v_branch_id INT;
    v_implant_id INT;
    v_seller_id INT;
    v_ticket_printer_id INT;
    v_product_id INT;
    v_provider_id INT;
    v_prestadora_id INT;
    v_tax_id INT;
    v_main_tax_id INT;
    v_variable_id INT;
    v_tax_item TEXT;
    v_tax_parts TEXT[];
    v_pass_item TEXT;
    v_pass_parts TEXT[];
    v_var_item TEXT;
    v_var_parts TEXT[];
    v_total_amount DECIMAL := 0;
    v_imported_count INT := 0;
    v_created_ids TEXT := '';
    v_decimals INT;
BEGIN
    -- 1. Crear tabla temporal
    CREATE TEMP TABLE IF NOT EXISTS tmp_import_rows (
        row_id INT GENERATED ALWAYS AS IDENTITY, --0
        grupo TEXT, --1
        cliente_doc TEXT, --2
        sucursal_cd TEXT, --3
        implant_cd TEXT, --4
        vendedor_cd TEXT, --5
        tiqueteador_cd TEXT, --6
        moneda TEXT, --7
        tasa_cambio DECIMAL, -- 8
        comision_global DECIMAL, -- 9
        cargos_global DECIMAL, --10
        producto_cd TEXT, --11
        proveedor_nm TEXT, --12 
        proveedor_cd TEXT, --13
        prestadora_cd TEXT, --14
        impuestos_str TEXT, --15
        variables_str TEXT, --16
        pasajeros_str TEXT, --17
        precio DECIMAL, --18
        cantidad INT, --19
        check_in TIMESTAMP, --20
        check_out TIMESTAMP, --21
        pax_adultos INT, --22
        pax_ninos INT, --23
        destino TEXT, --24
        tipo_servicio TEXT, --25
        reserva TEXT, --26
        com_vendedor DECIMAL, --27
        com_tiqueteador DECIMAL, --28
        combos_str TEXT, --29
        nacionalidad INT DEFAULT 1, --30
        cargo_principal_cd TEXT, --31
		cost DECIMAL DEFAULT 0--32
    ) ON COMMIT DROP;

    DELETE FROM tmp_import_rows;

    -- 2. "Split" del Texto a Tabla Temporal
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        v_imported_count := v_imported_count + 1;
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');

            -- Validar formato de Check-In (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[20]) <> '' AND TRIM(v_cols[20]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-In. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[20]);
                RETURN;
            END IF;

            -- Validar formato de Check-Out (Acepta YYYY-MM-DD y opcionalmente YYYY-MM-DD HH:MM:SS)
            IF TRIM(v_cols[21]) <> '' AND TRIM(v_cols[21]) !~ '^\d{4}-\d{2}-\d{2}' THEN
                p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': Formato incorrecto en la fecha de Check-Out. Se esperaba YYYY-MM-DD. Valor: ' || TRIM(v_cols[21]);
                RETURN;
            END IF;
            
            INSERT INTO tmp_import_rows (
                grupo, -- 1
				cliente_doc, -- 2 
				sucursal_cd, -- 3
				implant_cd, -- 4
				vendedor_cd, -- 5
				tiqueteador_cd, -- 6
                moneda, -- 7
				tasa_cambio, -- 8 
				comision_global, -- 9
				cargos_global, -- 10
				producto_cd, -- 11
                proveedor_nm, -- 12
				proveedor_cd, -- 13
				prestadora_cd, -- 14
				impuestos_str, -- 15
				variables_str, -- 16
				pasajeros_str, -- 17
                precio, -- 18
				cantidad, -- 19
				check_in, -- 20
				check_out, -- 21
				pax_adultos, -- 22
				pax_ninos, -- 23
                destino, -- 24
				tipo_servicio, -- 25
				reserva, -- 26
				com_vendedor, -- 27 
				com_tiqueteador, -- 28
                combos_str, -- 29
				nacionalidad, -- 30
				cargo_principal_cd, -- 31
				cost -- 32
            ) VALUES (
                TRIM(v_cols[1]), -- grupo 
				TRIM(v_cols[2]), -- cliente_doc 
				TRIM(v_cols[3]), -- sucursal_cd
				TRIM(v_cols[4]), -- implant_cd
				TRIM(v_cols[5]), -- vendedor_cd
				TRIM(v_cols[6]), -- tiqueteador_cd
                TRIM(v_cols[7]), -- moneda
				NULLIF(TRIM(v_cols[8]), '')::DECIMAL, -- tasa_cambio
				NULLIF(TRIM(v_cols[9]), '')::DECIMAL, -- comision_global
                NULLIF(TRIM(v_cols[10]), '')::DECIMAL, --cargos_global
				TRIM(v_cols[11]), -- Producto Codigo
                TRIM(v_cols[12]), -- Prov Nombre
                TRIM(v_cols[13]), -- Prov Codigo
                TRIM(v_cols[14]), -- Prestadora Codigo
                TRIM(v_cols[15]), -- Vars
				TRIM(v_cols[16]), -- Impuestos
				TRIM(v_cols[17]), -- Pasajeros
                NULLIF(TRIM(v_cols[18]), '')::DECIMAL, -- precio
				NULLIF(TRIM(v_cols[19]), '')::INT, -- cantidad
                CASE WHEN TRIM(v_cols[20]) <> '' THEN TRIM(v_cols[20])::TIMESTAMP ELSE NULL END, -- check_in
                CASE WHEN TRIM(v_cols[21]) <> '' THEN TRIM(v_cols[21])::TIMESTAMP ELSE NULL END, -- check_out
                NULLIF(TRIM(v_cols[22]), '')::INT, -- pax_adultos
				NULLIF(TRIM(v_cols[23]), '')::INT, -- pax_ninos
                TRIM(v_cols[24]), -- destino
				TRIM(v_cols[25]), -- tipo_servicio
				TRIM(v_cols[26]), -- reserva 
				NULLIF(TRIM(v_cols[27]), '')::DECIMAL, -- comision vendedor
				NULLIF(TRIM(v_cols[28]), '')::DECIMAL, -- comision tiqueteador
                TRIM(v_cols[29]), -- codigo combos
				COALESCE(NULLIF(TRIM(v_cols[30]), '')::INT, 1), -- nacionalidad
                TRIM(v_cols[31]), --cargo_principal_cd
				NULLIF(TRIM(v_cols[32]), '')::DECIMAL --costo
            );
        EXCEPTION WHEN OTHERS THEN
            p_mensaje_resultado := 'ERROR en FILA ' || v_imported_count || ': ' || SQLERRM || ' (Valor: ' || v_row_text || ')';
            RETURN;
        END;
    END LOOP;

    v_imported_count := 0;

    -- 3. Procesar Grupos
    FOR v_quotation_record IN (
        SELECT grupo, 
               MAX(cliente_doc) as cliente_doc, 
               MAX(sucursal_cd) as sucursal_cd, 
               MAX(implant_cd) as implant_cd, 
               MAX(vendedor_cd) as vendedor_cd, 
               MAX(tiqueteador_cd) as tiqueteador_cd, 
               MAX(moneda) as moneda, 
               MAX(tasa_cambio) as tasa_cambio, 
               MAX(comision_global) as comision_global, 
               MAX(cargos_global) as cargos_global,
               MAX(combos_str) as combos_str
        FROM tmp_import_rows
        GROUP BY grupo
    ) LOOP
        -- Resolución de Maestros
        SELECT id INTO v_client_id FROM public."Client" WHERE document = v_quotation_record.cliente_doc;
        IF v_client_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Cliente con documento o código "' || v_quotation_record.cliente_doc || '" no encontrado en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER(code) = LOWER(v_quotation_record.sucursal_cd);
        IF v_branch_id IS NULL THEN 
            p_mensaje_resultado := 'ERROR: Sucursal con código "' || v_quotation_record.sucursal_cd || '" no encontrada en el sistema.';
            RETURN;
        END IF;

        SELECT id INTO v_implant_id FROM public."Implant" WHERE LOWER(code) = LOWER(v_quotation_record.implant_cd);
        SELECT id INTO v_seller_id FROM public."Seller" WHERE LOWER(code) = LOWER(v_quotation_record.vendedor_cd);
        SELECT id INTO v_ticket_printer_id FROM public."TicketPrinter" WHERE LOWER(code) = LOWER(v_quotation_record.tiqueteador_cd);

        -- Obtener decimales de la moneda
        v_decimals := public.fn_obtener_decimales_moneda(COALESCE(v_quotation_record.moneda, 'COP'));

        v_internal_number := 'QUO-SP-' || to_char(now(), 'YYYYMMDD') || '-' || floor(random() * 10000)::TEXT;

        RAISE NOTICE 'DEBUG: moneda=%, tasa=%, seller=%', v_quotation_record.moneda, v_quotation_record.tasa_cambio, v_quotation_record.vendedor_cd;
        INSERT INTO public."Quotation" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", "totalAmount", "userId"
        ) VALUES (
            v_internal_number, now(), v_client_id, COALESCE(v_quotation_record.moneda, 'COP'), 
            COALESCE(v_quotation_record.tasa_cambio, 1), v_branch_id, v_implant_id, v_seller_id, 
            v_ticket_printer_id, 0, ROUND(COALESCE(v_quotation_record.comision_global, 0)::numeric, v_decimals)::double precision, 
            ROUND(COALESCE(v_quotation_record.cargos_global, 0)::numeric, v_decimals)::double precision, 0, p_user_id
        ) RETURNING id INTO v_quotation_id;

        v_created_ids := v_created_ids || v_quotation_id || ',';

        v_total_amount := COALESCE(v_quotation_record.cargos_global, 0);

        -- Procesar Combos (Expandir productos del combo)
        IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
            FOR v_var_item IN SELECT unnest(string_to_array(v_quotation_record.combos_str, '|')) LOOP
                DECLARE
                    v_combo_id INT;
                    v_cp_record RECORD;
                BEGIN
                    SELECT id INTO v_combo_id FROM public."Combo" WHERE LOWER(code) = LOWER(TRIM(v_var_item));
                    IF v_combo_id IS NOT NULL THEN
                        INSERT INTO public."QuotationCombo" ("quotationId", "comboId") VALUES (v_quotation_id, v_combo_id);
                        
                        -- Insertar productos del combo
                        FOR v_cp_record IN (SELECT * FROM public."ComboProduct" WHERE "comboId" = v_combo_id) LOOP
                            INSERT INTO public."QuotationProduct" (
                                "quotationId", "productId", "quantity", "price", "comboId", "mainTaxId", "inNationality", "cost"
                            ) VALUES (
                                v_quotation_id, v_cp_record."productId", v_cp_record.quantity, 
                                ROUND(v_cp_record.price::numeric, v_decimals)::double precision, 
                                v_combo_id, v_cp_record."mainTaxId", v_cp_record."inNationality", 
                                ROUND(v_cp_record."cost"::numeric, v_decimals)::double precision
                            ) RETURNING id INTO v_qp_id;

                            v_total_amount := v_total_amount + (v_cp_record.price * v_cp_record.quantity);

                            -- Insertar impuestos del combo product
                            INSERT INTO public."QuotationProductTax" (
                                "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                            )
                            SELECT v_qp_id, cpt."chargeAndTaxId", ct.value, ct."valueType", 
                                   ROUND(cpt.amount::numeric, v_decimals)::double precision, cpt."isMain"
                            FROM public."ComboProductTax" cpt
                            JOIN public."ChargeAndTax" ct ON cpt."chargeAndTaxId" = ct.id
                            WHERE cpt."comboProductId" = v_cp_record.id;
                            
                            -- Sumar impuestos al total
                            v_total_amount := v_total_amount + COALESCE((SELECT SUM(amount) FROM public."ComboProductTax" WHERE "comboProductId" = v_cp_record.id), 0);
                        END LOOP;
                    END IF;
                END;
            END LOOP;
        END IF;

        -- Procesar Productos Individuales
        FOR v_product_record IN (SELECT * FROM tmp_import_rows WHERE grupo = v_quotation_record.grupo) LOOP
            SELECT id INTO v_product_id FROM public."Product" WHERE LOWER(code) = LOWER(v_product_record.producto_cd);
            IF v_product_id IS NULL THEN CONTINUE; END IF; 

            -- Resolución de Proveedor por Código
            v_provider_id := NULL;
            IF v_product_record.proveedor_cd <> '' THEN
                SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER(code) = LOWER(v_product_record.proveedor_cd);
            END IF;

            SELECT id INTO v_prestadora_id FROM public."Prestadora" WHERE LOWER(code) = LOWER(v_product_record.prestadora_cd);

            v_main_tax_id := NULL;
            IF v_product_record.cargo_principal_cd <> '' THEN
                SELECT id INTO v_main_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(v_product_record.cargo_principal_cd);
            END IF;

            v_qp_id := NULL;
            SELECT id INTO v_qp_id FROM public."QuotationProduct" 
            WHERE "quotationId" = v_quotation_id AND "productId" = v_product_id AND "comboId" IS NOT NULL
            LIMIT 1;

            IF v_qp_id IS NOT NULL THEN
                UPDATE public."QuotationProduct" SET
                    "quantity" = COALESCE(v_product_record.quantity, "quantity"),
                    "price" = ROUND(COALESCE(v_product_record.precio, "price")::numeric, v_decimals)::double precision,
                    "providerId" = COALESCE(v_provider_id, "providerId"),
                    "prestadoraId" = COALESCE(v_prestadora_id, "prestadoraId"),
                    "checkInDate" = COALESCE(v_product_record.check_in, "checkInDate"),
                    "checkOutDate" = COALESCE(v_product_record.check_out, "checkOutDate"),
                    "nights" = CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                                 THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                                 ELSE "nights" END,
                    "paxAdults" = COALESCE(v_product_record.pax_adultos, "paxAdults"),
                    "paxChildren" = COALESCE(v_product_record.pax_ninos, "paxChildren"),
                    "serviceType" = COALESCE(v_product_record.tipo_servicio, "serviceType"),
                    "destination" = COALESCE(v_product_record.destino, "destination"),
                    "reservationCode" = COALESCE(v_product_record.reserva, "reservationCode"),
                    "sellerCommission" = ROUND(COALESCE(v_product_record.com_vendedor, "sellerCommission")::numeric, v_decimals)::double precision,
                    "ticketPrinterCommission" = ROUND(COALESCE(v_product_record.com_tiqueteador, "ticketPrinterCommission")::numeric, v_decimals)::double precision,
                    "inNationality" = COALESCE(v_product_record.nacionalidad, "inNationality"),
                    "mainTaxId" = COALESCE(v_main_tax_id, "mainTaxId"),
					"cost" = ROUND(COALESCE(v_product_record.cost, "cost")::numeric, v_decimals)::double precision
                WHERE id = v_qp_id;

                -- Eliminar impuestos base del combo si hay overrides en Excel
                IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                    DELETE FROM public."QuotationProductTax" WHERE "quotationProductId" = v_qp_id;
                END IF;
            ELSE
                IF v_quotation_record.combos_str IS NOT NULL AND v_quotation_record.combos_str <> '' THEN
                    CONTINUE; -- No crear productos diferentes a los del combo
                END IF;

                INSERT INTO public."QuotationProduct" (
                    "quotationId", "productId", "quantity", "price", "providerId", "prestadoraId", 
                    "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren", 
                    "serviceType", "destination", "reservationCode", "sellerCommission", "ticketPrinterCommission",
                    "inNationality", "mainTaxId", "cost"
                ) VALUES (
                    v_quotation_id, v_product_id, COALESCE(v_product_record.quantity, 1), 
                    ROUND(COALESCE(v_product_record.precio, 0)::numeric, v_decimals)::double precision, 
                    v_provider_id, v_prestadora_id, 
                    v_product_record.check_in, v_product_record.check_out, 
                    CASE WHEN v_product_record.check_in IS NOT NULL AND v_product_record.check_out IS NOT NULL 
                         THEN EXTRACT(DAY FROM (v_product_record.check_out - v_product_record.check_in))::INT 
                         ELSE 1 END,
                    COALESCE(v_product_record.pax_adultos, 1), COALESCE(v_product_record.pax_ninos, 0),
                    v_product_record.tipo_servicio, v_product_record.destino, v_product_record.reserva,
                    ROUND(COALESCE(v_product_record.com_vendedor, 0)::numeric, v_decimals)::double precision, 
                    ROUND(COALESCE(v_product_record.com_tiqueteador, 0)::numeric, v_decimals)::double precision,
                    COALESCE(v_product_record.nacionalidad, 1), v_main_tax_id, 
                    ROUND(COALESCE(v_product_record.cost, 0)::numeric, v_decimals)::double precision
                ) RETURNING id INTO v_qp_id;
            END IF;

            v_total_amount := v_total_amount + (COALESCE(v_product_record.precio, 0) * COALESCE(v_product_record.quantity, 1));

            -- Split para Impuestos
            IF v_product_record.impuestos_str IS NOT NULL AND v_product_record.impuestos_str <> '' THEN
                FOREACH v_tax_item IN ARRAY string_to_array(v_product_record.impuestos_str, '|') LOOP
                    v_tax_parts := string_to_array(v_tax_item, ':');
                    SELECT id INTO v_tax_id FROM public."ChargeAndTax" WHERE LOWER(code) = LOWER(TRIM(v_tax_parts[1]));
                    IF v_tax_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductTax" (
                            "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount"
                        ) 
                        SELECT v_qp_id, id, value, "valueType", 
                               ROUND(NULLIF(TRIM(v_tax_parts[2]), '')::numeric, v_decimals)::double precision
                        FROM public."ChargeAndTax" WHERE id = v_tax_id;
                        v_total_amount := v_total_amount + NULLIF(TRIM(v_tax_parts[2]), '')::DECIMAL;
                    END IF;
                END LOOP;
            END IF;

            -- Split para Pasajeros
            IF v_product_record.pasajeros_str IS NOT NULL AND v_product_record.pasajeros_str <> '' THEN
                FOREACH v_pass_item IN ARRAY string_to_array(v_product_record.pasajeros_str, '|') LOOP
                    v_pass_parts := string_to_array(v_pass_item, ':');
                    INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                    VALUES (v_qp_id, COALESCE(v_pass_parts[1], ''), COALESCE(v_pass_parts[2], ''));
                END LOOP;
            END IF;

            -- Split para Variables
            IF v_product_record.variables_str IS NOT NULL AND v_product_record.variables_str <> '' THEN
                FOREACH v_var_item IN ARRAY string_to_array(v_product_record.variables_str, '|') LOOP
                    v_var_parts := string_to_array(v_var_item, ':');
                    SELECT id INTO v_variable_id FROM public."MasterVariable" WHERE LOWER(code) = LOWER(TRIM(v_var_parts[1]));
                    IF v_variable_id IS NOT NULL THEN
                        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                        VALUES (v_qp_id, v_variable_id, COALESCE(v_var_parts[2], ''));
                    END IF;
                END LOOP;
            END IF;
        END LOOP;

        -- Calcular y actualizar el totalAmount basado en QuotationProductTax
        UPDATE public."Quotation"
        SET "totalAmount" = ROUND((
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0) AS cargos_global
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = v_quotation_id
        )::numeric, v_decimals)::double precision
        WHERE id = v_quotation_id;
        
        v_imported_count := v_imported_count + 1;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: ' || v_imported_count || ' cotizaciones importadas. [' || RTRIM(v_created_ids, ',') || ']';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM || ' | ' || SQLSTATE;
END;
$$;


--
-- Name: spInterfaceFile(text, text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spInterfaceFile"(IN op text, IN booking text, IN file text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.spinterfacefile(op, booking, file);
END;
$$;


--
-- Name: spInterfaceSabre(text, text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spInterfaceSabre"(IN p_op text, IN p_booking text, IN p_file text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Variables Generales
    v_code VARCHAR(12) := NULL;
    v_blanch VARCHAR(25) := '001';
    v_implant VARCHAR(25) := '';
    v_date TIMESTAMP := CURRENT_TIMESTAMP;
    v_seller VARCHAR(25) := '';
    v_client VARCHAR(50) := '';
    v_currency VARCHAR(10) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_aerolinea_vende VARCHAR(10) := 'AA';
    v_provider_matched VARCHAR(50) := NULL;
    v_tiqueteador VARCHAR(20) := '';
    
    -- Variables de Sistema Adicionales Extraídas
    v_var_codes TEXT[] := ARRAY[]::TEXT[];
    v_var_names TEXT[] := ARRAY[]::TEXT[];
    v_var_values TEXT[] := ARRAY[]::TEXT[];
    
    -- Lineas
    v_lines TEXT[];
    v_line TEXT;
    v_i INT;
    
    -- Pasajeros
    v_pax_nombres TEXT[] := ARRAY[]::TEXT[];
    v_pax_apellidos TEXT[] := ARRAY[]::TEXT[];
    
    -- M2 Totales e Impuestos Generales y Pago M2
    v_m2_currency VARCHAR(10) := 'COP';
    v_m2_tarifa DOUBLE PRECISION := 0.0;
    v_m2_total DOUBLE PRECISION := 0.0;
    v_m2_tax_codes TEXT[] := ARRAY[]::TEXT[];
    v_m2_tax_amounts DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_m2_pay_type TEXT := NULL;
    v_m2_pay_card TEXT := '';
    v_m2_pay_number TEXT := '';
    
    -- Tiquetes y M50
    v_tkt_codes TEXT[] := ARRAY[]::TEXT[];
    v_tkt_prestadoras TEXT[] := ARRAY[]::TEXT[];
    v_tkt_tarifas DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_impuestos DOUBLE PRECISION[] := ARRAY[]::DOUBLE PRECISION[];
    v_tkt_pay_types TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_cards TEXT[] := ARRAY[]::TEXT[];
    v_tkt_pay_numbers TEXT[] := ARRAY[]::TEXT[];
    
    -- Itinerarios M30
    v_iti_origenes TEXT[] := ARRAY[]::TEXT[];
    v_iti_destinos TEXT[] := ARRAY[]::TEXT[];
    v_iti_vuelos TEXT[] := ARRAY[]::TEXT[];
    v_iti_clases TEXT[] := ARRAY[]::TEXT[];
    v_iti_aerolineas TEXT[] := ARRAY[]::TEXT[];
    v_iti_fechas_salida TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    v_iti_fechas_llegada TIMESTAMP[] := ARRAY[]::TIMESTAMP[];
    
    -- IDs de Tablas
    v_booking_gds_id INT;
    v_booking_product_gds_id INT;
BEGIN
    -- 1. Separar líneas del contenido del archivo (p_Booking)
    v_lines := string_to_array(p_Booking, E'\n');
    IF v_lines IS NULL OR array_length(v_lines, 1) = 0 THEN
        RAISE EXCEPTION 'El contenido del archivo Sabre está vacío.' USING ERRCODE = 'P0001';
    END IF;

    -- 2. Recorrer archivo y parsear
    FOR v_i IN 1 .. array_length(v_lines, 1) LOOP
        v_line := REPLACE(REPLACE(v_lines[v_i], E'\r', ''), E'\uFEFF', '');
        
        -- Cabecera AA (PNR y Sucursal)
        IF v_line LIKE 'AA%' OR (v_code IS NULL AND POSITION('AA' IN v_line) = 1) THEN
            IF length(v_line) >= 61 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 6)), '');
            END IF;
            IF v_code IS NULL AND length(v_line) >= 20 THEN
                v_code := NULLIF(TRIM(SUBSTRING(v_line FROM 56 FOR 10)), '');
            END IF;
            IF length(v_line) >= 18 THEN
                v_blanch := COALESCE(NULLIF(TRIM(SUBSTRING(v_line FROM 12 FOR 7)), ''), v_blanch);
            END IF;
        END IF;

        -- Pasajeros M1
        IF v_line LIKE 'M1%' THEN
            DECLARE
                v_raw_pax TEXT;
                v_slash_pos INT;
                v_ape TEXT;
                v_nom TEXT;
            BEGIN
                v_raw_pax := TRIM(SUBSTRING(v_line FROM 5 FOR 80));
                v_slash_pos := POSITION('/' IN v_raw_pax);
                IF v_slash_pos > 0 THEN
                    v_ape := TRIM(SUBSTRING(v_raw_pax FROM 1 FOR v_slash_pos - 1));
                    v_nom := TRIM(SUBSTRING(v_raw_pax FROM v_slash_pos + 1));
                ELSE
                    v_ape := v_raw_pax;
                    v_nom := '';
                END IF;
                IF v_ape <> '' THEN
                    v_pax_apellidos := array_append(v_pax_apellidos, v_ape);
                    v_pax_nombres := array_append(v_pax_nombres, v_nom);
                END IF;
            END;
        END IF;

        -- Totales e Impuestos de linea M2 (M201ADT...)
        IF v_line LIKE 'M2%' THEN
            DECLARE
                v_cop1_pos INT;
                v_cop2_pos INT;
                v_curr_code TEXT := 'COP';
                v_between TEXT;
                v_base_match TEXT[];
                v_tax_part TEXT;
                v_r RECORD;
                v_after_cop2 TEXT;
                v_tot_match TEXT[];
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                v_cop1_pos := POSITION('COP' IN v_line);
                IF v_cop1_pos = 0 THEN
                    v_cop1_pos := POSITION('USD' IN v_line);
                    v_curr_code := 'USD';
                END IF;

                IF v_cop1_pos > 0 THEN
                    v_m2_currency := v_curr_code;
                    v_currency := v_curr_code;

                    v_cop2_pos := POSITION(v_curr_code IN SUBSTRING(v_line FROM v_cop1_pos + 3));
                    IF v_cop2_pos > 0 THEN
                        v_cop2_pos := v_cop1_pos + 3 + v_cop2_pos - 1;
                        v_between := TRIM(SUBSTRING(v_line FROM v_cop1_pos + 3 FOR v_cop2_pos - (v_cop1_pos + 3)));
                        
                        v_base_match := regexp_matches(v_between, '^([0-9.]+)');
                        IF array_length(v_base_match, 1) >= 1 THEN
                            v_m2_tarifa := (v_base_match[1])::DOUBLE PRECISION;
                            v_tax_part := TRIM(SUBSTRING(v_between FROM length(v_base_match[1]) + 1));
                            
                            FOR v_r IN SELECT (m[1])::DOUBLE PRECISION AS amt, m[2] AS code
                                       FROM regexp_matches(v_tax_part, '([0-9.]+)\s*([A-Z0-9]{2})', 'g') AS m
                            LOOP
                                v_m2_tax_amounts := array_append(v_m2_tax_amounts, v_r.amt);
                                v_m2_tax_codes := array_append(v_m2_tax_codes, v_r.code);
                            END LOOP;
                        END IF;

                        v_after_cop2 := TRIM(SUBSTRING(v_line FROM v_cop2_pos + 3));
                        v_tot_match := regexp_matches(v_after_cop2, '^([0-9.]+)');
                        IF array_length(v_tot_match, 1) >= 1 THEN
                            v_m2_total := (v_tot_match[1])::DOUBLE PRECISION;
                        END IF;
                    END IF;
                END IF;

                -- Extracción de Tarjeta de Crédito en M2 si contiene CC
                v_cc_pos := POSITION('CC' IN v_line);
                IF v_cc_pos > 0 THEN
                    v_m2_pay_type := 'TC';
                    v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                    IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                        v_m2_pay_card := v_cand_card;
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                    ELSE
                        v_m2_pay_card := '';
                        v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                    END IF;

                    IF array_length(v_num_match, 1) >= 1 THEN
                        v_m2_pay_number := v_num_match[1];
                    END IF;
                END IF;
            END;
        END IF;

        -- Itinerarios Vuelos M30 (AIRN)
        IF v_line LIKE 'M30%' THEN
            DECLARE
                v_airn_pos INT;
                v_date_str TEXT;
                v_day INT;
                v_mon_str TEXT;
                v_mon INT;
                v_year INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;
                v_orig TEXT;
                v_dest TEXT;
                v_rest TEXT;
                v_airline TEXT;
                v_flight TEXT;
                v_class TEXT;
                v_dep_time TEXT;
                v_arr_time TEXT;
                v_check_in TIMESTAMP;
                v_check_out TIMESTAMP;
            BEGIN
                v_airn_pos := POSITION('AIRN' IN v_line);
                IF v_airn_pos > 0 THEN
                    v_date_str := SUBSTRING(v_line FROM 10 FOR 5);
                    v_day := (SUBSTRING(v_date_str FROM 1 FOR 2))::INT;
                    v_mon_str := UPPER(SUBSTRING(v_date_str FROM 3 FOR 3));
                    
                    v_mon := CASE v_mon_str
                        WHEN 'JAN' THEN 1 WHEN 'FEB' THEN 2 WHEN 'MAR' THEN 3
                        WHEN 'APR' THEN 4 WHEN 'MAY' THEN 5 WHEN 'JUN' THEN 6
                        WHEN 'JUL' THEN 7 WHEN 'AUG' THEN 8 WHEN 'SEP' THEN 9
                        WHEN 'OCT' THEN 10 WHEN 'NOV' THEN 11 WHEN 'DEC' THEN 12
                        ELSE 1 END;
                        
                    v_orig := SUBSTRING(v_line FROM v_airn_pos + 4 FOR 3);
                    v_dest := SUBSTRING(v_line FROM v_airn_pos + 24 FOR 3);
                    
                    v_rest := TRIM(SUBSTRING(v_line FROM v_airn_pos + 44));
                    v_airline := SUBSTRING(v_rest FROM 1 FOR 2);
                    v_flight := TRIM(SUBSTRING(v_rest FROM 4 FOR 4));
                    v_class := SUBSTRING(v_rest FROM 8 FOR 1);
                    v_dep_time := SUBSTRING(v_rest FROM 10 FOR 4);
                    v_arr_time := SUBSTRING(v_rest FROM 15 FOR 4);
                    
                    v_check_in := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_dep_time FROM 1 FOR 2))::INT, (SUBSTRING(v_dep_time FROM 3 FOR 2))::INT, 0);
                    v_check_out := MAKE_TIMESTAMP(v_year, v_mon, v_day, (SUBSTRING(v_arr_time FROM 1 FOR 2))::INT, (SUBSTRING(v_arr_time FROM 3 FOR 2))::INT, 0);
                    IF v_check_out < v_check_in THEN
                        v_check_out := v_check_out + INTERVAL '1 day';
                    END IF;

                    IF v_airline IS NOT NULL AND v_airline <> '' THEN
                        v_aerolinea_vende := v_airline;
                    END IF;

                    IF v_orig IS NOT NULL AND v_dest IS NOT NULL THEN
                        v_iti_origenes := array_append(v_iti_origenes, v_orig);
                        v_iti_destinos := array_append(v_iti_destinos, v_dest);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, COALESCE(v_airline, 'AA'));
                        v_iti_vuelos := array_append(v_iti_vuelos, COALESCE(v_flight, '0000'));
                        v_iti_clases := array_append(v_iti_clases, COALESCE(v_class, 'Y'));
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_check_in);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_check_out);
                    END IF;
                END IF;
            END;
        END IF;

        -- Tiquetes, Valores e Impuestos M50 / M501 / M502
        IF v_line LIKE 'M50%' THEN
            DECLARE
                v_hash_pos INT;
                v_tkt_num TEXT := NULL;
                v_prestadora TEXT := 'AA';
                v_parts TEXT[];
                v_raw_tarifa TEXT;
                v_raw_tax TEXT;
                v_val_tarifa DOUBLE PRECISION := 0.0;
                v_val_tax DOUBLE PRECISION := 0.0;
                v_pay_type TEXT := 'TC';
                v_card_type TEXT := '';
                v_card_num TEXT := '';
                v_cc_pos INT;
                v_cand_card TEXT;
                v_num_match TEXT[];
            BEGIN
                -- 1. Numero de Tiquete y Prestadora Code
                v_hash_pos := POSITION('#' IN v_line);
                IF v_hash_pos > 2 THEN
                    v_prestadora := NULLIF(TRIM(SUBSTRING(v_line FROM v_hash_pos - 2 FOR 2)), '');
                    IF v_prestadora IS NULL THEN v_prestadora := 'AA'; END IF;
                END IF;

                IF v_hash_pos > 0 THEN
                    v_parts := string_to_array(v_line, '/');
                    IF array_length(v_parts, 1) >= 1 THEN
                        v_tkt_num := NULLIF(regexp_replace(v_parts[1], '^.*?#', ''), '');
                        IF v_tkt_num IS NOT NULL THEN
                            v_num_match := regexp_matches(v_tkt_num, '[0-9]{10,13}');
                            IF array_length(v_num_match, 1) >= 1 THEN
                                v_tkt_num := v_num_match[1];
                            END IF;
                        END IF;
                    END IF;

                    -- 2. Valor Tarifa (Segmento 3 por '/')
                    IF array_length(v_parts, 1) >= 3 THEN
                        v_raw_tarifa := regexp_replace(v_parts[3], '[^0-9.]', '', 'g');
                        IF v_raw_tarifa <> '' THEN
                            v_val_tarifa := v_raw_tarifa::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 3. Valor Otros Impuestos (Segmento 4 por '/')
                    IF array_length(v_parts, 1) >= 4 THEN
                        v_raw_tax := regexp_replace(v_parts[4], '[^0-9.]', '', 'g');
                        IF v_raw_tax <> '' THEN
                            v_val_tax := v_raw_tax::DOUBLE PRECISION;
                        END IF;
                    END IF;

                    -- 4. Forma de Pago y Tarjeta (Extraer franquicia VI/MC/AX/DC y numero despues de CC)
                    v_cc_pos := POSITION('CC' IN v_line);
                    IF v_cc_pos > 0 THEN
                        v_pay_type := 'TC';
                        v_cand_card := SUBSTRING(v_line FROM v_cc_pos + 2 FOR 2);
                        IF v_cand_card IN ('VI', 'MC', 'AX', 'DC', 'TP') THEN
                            v_card_type := v_cand_card;
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 4), '^([0-9]{4,16})');
                        ELSE
                            v_card_type := '';
                            v_num_match := regexp_matches(SUBSTRING(v_line FROM v_cc_pos + 2), '^([0-9]{4,16})');
                        END IF;

                        IF array_length(v_num_match, 1) >= 1 THEN
                            v_card_num := v_num_match[1];
                        END IF;
                    ELSIF POSITION('/CA ' IN v_line) > 0 OR POSITION('/CK ' IN v_line) > 0 THEN
                        v_pay_type := 'CA';
                        v_card_type := '';
                        v_card_num := '';
                    END IF;

                    IF v_tkt_num IS NOT NULL THEN
                        v_tkt_codes := array_append(v_tkt_codes, v_tkt_num);
                        v_tkt_prestadoras := array_append(v_tkt_prestadoras, COALESCE(v_prestadora, 'AA'));
                        v_tkt_tarifas := array_append(v_tkt_tarifas, v_val_tarifa);
                        v_tkt_impuestos := array_append(v_tkt_impuestos, v_val_tax);
                        v_tkt_pay_types := array_append(v_tkt_pay_types, v_pay_type);
                        v_tkt_pay_cards := array_append(v_tkt_pay_cards, v_card_type);
                        v_tkt_pay_numbers := array_append(v_tkt_pay_numbers, v_card_num);
                    END IF;
                END IF;
            END;
        END IF;

        -- Extracción de Parámetros y Variables M8 / M9 / RM
        IF v_line LIKE 'M8%' OR v_line LIKE 'M9%' OR v_line LIKE 'RM%' THEN
            DECLARE
                v_param RECORD;
                v_pref TEXT;
                v_pos INT;
                v_val TEXT;
            BEGIN
                -- M828AGENT* / M928AGENT*
                IF v_line LIKE 'M828AGENT*%' OR v_line LIKE 'M928AGENT*%' THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM 9 FOR 10));
                    v_seller := COALESCE(NULLIF(v_seller, ''), v_tiqueteador);
                END IF;

                -- Extracción por registros de InterfaceExtractParam
                FOR v_param IN 
                    SELECT p."fieldCode", p."fieldName", p.prefix, p.delimiter 
                    FROM public."InterfaceExtractParam" p
                    WHERE p."isActive" = true
                LOOP
                    v_pref := TRIM(COALESCE(v_param.prefix, ''));
                    IF v_pref <> '' AND POSITION(UPPER(v_pref) IN UPPER(v_line)) > 0 THEN
                        v_pos := POSITION(UPPER(v_pref) IN UPPER(v_line)) + length(v_pref);
                        v_val := TRIM(SUBSTRING(v_line FROM v_pos));

                        IF v_param."fieldCode" IN ('Client', 'CLI', 'Cliente') THEN
                            v_client := v_val;
                        ELSIF v_param."fieldCode" IN ('Branch', 'SUC', 'Sucursal') THEN
                            v_blanch := v_val;
                        ELSIF v_param."fieldCode" IN ('Implant', 'IMP', 'Implante') THEN
                            v_implant := v_val;
                        ELSIF v_param."fieldCode" IN ('TicketPrinter', 'ASE', 'Tiqueteador') THEN
                            v_tiqueteador := v_val;
                        ELSIF v_param."fieldCode" IN ('Seller', 'VEN', 'Vendedor') THEN
                            v_seller := v_val;
                        ELSE
                            -- Guardar Variable de Sistema Adicional (ej. 001, 002)
                            IF NOT (v_param."fieldCode" = ANY(v_var_codes)) THEN
                                v_var_codes := array_append(v_var_codes, v_param."fieldCode");
                                v_var_names := array_append(v_var_names, v_param."fieldName");
                                v_var_values := array_append(v_var_values, v_val);
                            END IF;
                        END IF;
                    END IF;
                END LOOP;

                -- Fallbacks estándar si no hay coincidencia en InterfaceExtractParam
                IF (v_client IS NULL OR v_client = '') AND POSITION('CLI-' IN v_line) > 0 THEN
                    v_client := TRIM(SUBSTRING(v_line FROM POSITION('CLI-' IN v_line) + 4));
                END IF;
                IF (v_blanch IS NULL OR v_blanch = '001') AND POSITION('SUC-' IN v_line) > 0 THEN
                    v_blanch := TRIM(SUBSTRING(v_line FROM POSITION('SUC-' IN v_line) + 4));
                END IF;
                IF (v_implant IS NULL OR v_implant = '') AND POSITION('IMP-' IN v_line) > 0 THEN
                    v_implant := TRIM(SUBSTRING(v_line FROM POSITION('IMP-' IN v_line) + 4));
                END IF;
                IF (v_tiqueteador IS NULL OR v_tiqueteador = '') AND POSITION('ASE-' IN v_line) > 0 THEN
                    v_tiqueteador := TRIM(SUBSTRING(v_line FROM POSITION('ASE-' IN v_line) + 4));
                END IF;
                IF (v_seller IS NULL OR v_seller = '') AND POSITION('VEN-' IN v_line) > 0 THEN
                    v_seller := TRIM(SUBSTRING(v_line FROM POSITION('VEN-' IN v_line) + 4));
                END IF;

                -- Fallback para CC- (001) y FF- (002)
                IF POSITION('CC-' IN v_line) > 0 AND NOT ('001' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('CC-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '001');
                    v_var_names := array_append(v_var_names, 'centro de costo');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
                IF POSITION('FF-' IN v_line) > 0 AND NOT ('002' = ANY(v_var_codes)) THEN
                    v_val := TRIM(SUBSTRING(v_line FROM POSITION('FF-' IN v_line) + 3));
                    v_var_codes := array_append(v_var_codes, '002');
                    v_var_names := array_append(v_var_names, 'Fecha de Facturacion');
                    v_var_values := array_append(v_var_values, v_val);
                END IF;
            END;
        END IF;

    END LOOP;

    -- Validar existencia de PNR
    IF v_code IS NULL OR v_code = '' THEN
        RAISE EXCEPTION 'No se encontro codigo de reserva en la cabecera (AA).' USING ERRCODE = 'P0001';
    END IF;

    -- Upsert en BookingGDS con gds = 1 (SABRE)
    SELECT id INTO v_booking_gds_id FROM public."BookingGDS" WHERE "code" = v_code LIMIT 1;

    IF v_booking_gds_id IS NOT NULL THEN
        UPDATE public."BookingGDS" SET
            "type" = 'RES',
            "blanch" = COALESCE(v_blanch, '001'),
            "implant" = COALESCE(v_implant, ''),
            "client" = COALESCE(v_client, ''),
            "seller" = COALESCE(v_seller, ''),
            "tiquetPrinter" = COALESCE(v_tiqueteador, ''),
            "gds" = 1, -- 1 = SABRE
            "date" = CURRENT_TIMESTAMP,
            "currency" = v_currency,
            "exchangeRate" = v_exchangeRate,
            "booking" = p_Booking,
            "state" = 'NUEVO'
        WHERE id = v_booking_gds_id;

        DELETE FROM public."BookingProductVariableGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            v_code, 'RES', COALESCE(v_blanch, '001'), COALESCE(v_implant, ''), false, 1, CURRENT_TIMESTAMP, -- 1 = SABRE
            v_currency, v_exchangeRate, COALESCE(v_tiqueteador, ''), COALESCE(v_seller, ''), COALESCE(v_client, ''), 
            p_Booking, '1', '', 'Sabre Interface', '', 'NUEVO'
        ) RETURNING id INTO v_booking_gds_id;
    END IF;

    -- Creación de productos y detalles por tiquete / M50 o M2
    DECLARE
        v_num_tkts INT;
        v_tkt_i INT;
        v_prod_code TEXT;
        v_prod_prestadora TEXT;
        v_prod_tarifa DOUBLE PRECISION;
        v_prod_tax DOUBLE PRECISION;
        v_total_prod_price DOUBLE PRECISION;
        v_final_pay_type TEXT;
        v_final_pay_card TEXT;
        v_final_pay_number TEXT;
    BEGIN
        v_num_tkts := COALESCE(array_length(v_tkt_codes, 1), 0);
        IF v_num_tkts = 0 THEN
            v_num_tkts := 1;
            v_tkt_codes := ARRAY['VUE'];
            v_tkt_prestadoras := ARRAY[v_aerolinea_vende];
            v_tkt_tarifas := ARRAY[COALESCE(v_m2_tarifa, 0.0)];
            v_tkt_impuestos := ARRAY[0.0];
            v_tkt_pay_types := ARRAY[COALESCE(v_m2_pay_type, 'TC')];
            v_tkt_pay_cards := ARRAY[COALESCE(v_m2_pay_card, '')];
            v_tkt_pay_numbers := ARRAY[COALESCE(v_m2_pay_number, '')];
        END IF;

        FOR v_tkt_i IN 1 .. v_num_tkts LOOP
            v_prod_code := v_tkt_codes[v_tkt_i];
            v_prod_prestadora := COALESCE(v_tkt_prestadoras[v_tkt_i], v_aerolinea_vende);
            
            IF v_m2_tarifa > 0 THEN
                v_prod_tarifa := v_m2_tarifa;
            ELSE
                v_prod_tarifa := COALESCE(v_tkt_tarifas[v_tkt_i], 0.0);
            END IF;

            IF v_m2_total > 0 THEN
                v_total_prod_price := v_m2_total;
            ELSE
                v_prod_tax := COALESCE(v_tkt_impuestos[v_tkt_i], 0.0);
                v_total_prod_price := v_prod_tarifa + v_prod_tax;
            END IF;

            -- Forma de pago final priorizando datos extraídos
            v_final_pay_type := COALESCE(v_tkt_pay_types[v_tkt_i], v_m2_pay_type, 'TC');
            v_final_pay_card := COALESCE(NULLIF(v_tkt_pay_cards[v_tkt_i], ''), v_m2_pay_card, '');
            v_final_pay_number := COALESCE(NULLIF(v_tkt_pay_numbers[v_tkt_i], ''), v_m2_pay_number, '');

            -- Buscar proveedor por prestadora code
            SELECT code INTO v_provider_matched
            FROM public."Provider"
            WHERE UPPER(sigla) = UPPER(v_prod_prestadora) 
               OR UPPER(code) = UPPER(v_prod_prestadora)
               OR UPPER("airlineCode") = UPPER(v_prod_prestadora)
            LIMIT 1;

            -- Inserción de Producto (Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_prod_prestadora, COALESCE(v_provider_matched, v_prod_prestadora),
                1, v_total_prod_price, v_code, 1, 'NUEVO', 'VUE'
            ) RETURNING id INTO v_booking_product_gds_id;

            -- 1. Impuesto Tarifa (TAR)
            IF v_prod_tarifa > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tarifa
                );
            END IF;

            -- 2. Impuestos detallados con Homologación
            IF array_length(v_m2_tax_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_m2_tax_codes, 1) LOOP
                    DECLARE
                        v_tax_code_gds TEXT;
                        v_tax_amt DOUBLE PRECISION;
                        v_homolog_code TEXT := NULL;
                        v_homolog_name TEXT := NULL;
                    BEGIN
                        v_tax_code_gds := v_m2_tax_codes[v_i];
                        v_tax_amt := v_m2_tax_amounts[v_i];

                        SELECT eq.cd_codigo, cat.name
                        INTO v_homolog_code, v_homolog_name
                        FROM public."EquivalencesInterfaces" eq
                        LEFT JOIN public."ChargeAndTax" cat ON cat.code = eq.cd_codigo
                        WHERE eq.cd_maestro = 'ChargeAndTax'
                          AND UPPER(TRIM(eq.cd_codigointe)) = UPPER(TRIM(v_tax_code_gds))
                        LIMIT 1;

                        IF v_homolog_code IS NULL THEN
                            SELECT code, name
                            INTO v_homolog_code, v_homolog_name
                            FROM public."ChargeAndTax"
                            WHERE UPPER(code) = UPPER(v_tax_code_gds)
                            LIMIT 1;
                        END IF;

                        IF v_homolog_code IS NULL THEN
                            v_homolog_code := v_tax_code_gds;
                            v_homolog_name := v_tax_code_gds;
                        END IF;

                        INSERT INTO public."BookingProductTaxGDS" (
                            "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                        ) VALUES (
                            v_booking_product_gds_id, v_homolog_code, COALESCE(v_homolog_name, v_homolog_code), 'tax', false, 0, v_tax_amt
                        );
                    END;
                END LOOP;
            ELSIF v_prod_tax > 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'OTR', 'Otros Impuestos', 'tax', false, 0, v_prod_tax
                );
            END IF;

            -- 3. Forma de Pago Única para ESTE tiquete
            IF v_final_pay_type IS NOT NULL AND v_final_pay_type <> '' THEN
                INSERT INTO public."BookingProductPaymentGDS" (
                    "bookingProductId", "code", "name", "type", "typecreditcard", "numbercreditcard", "amount"
                ) VALUES (
                    v_booking_product_gds_id, v_final_pay_type, v_final_pay_type, v_final_pay_type,
                    v_final_pay_card, COALESCE(v_final_pay_number, ''), v_total_prod_price
                );
            END IF;

            -- 4. Itinerario para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], 
                        v_iti_fechas_salida[v_i], v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], 
                        '', v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 5. Pasajero para este producto
            IF v_tkt_i <= COALESCE(array_length(v_pax_nombres, 1), 0) AND v_pax_nombres[v_tkt_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_tkt_i::TEXT, v_pax_nombres[v_tkt_i], v_pax_apellidos[v_tkt_i], '', COALESCE(v_tkt_codes[v_tkt_i], ''), '', ''
                );
            END IF;

            -- 6. Variables de Sistema Adicionales Extraídas
            IF array_length(v_var_codes, 1) > 0 THEN
                FOR v_i IN 1 .. array_length(v_var_codes, 1) LOOP
                    INSERT INTO public."BookingProductVariableGDS" (
                        "bookingProductId", "code", "name", "value"
                    ) VALUES (
                        v_booking_product_gds_id, v_var_codes[v_i], v_var_names[v_i], v_var_values[v_i]
                    );
                END LOOP;
            END IF;

        END LOOP;
    END;

    RAISE NOTICE 'Reserva Sabre PNR % procesada exitosamente.', v_code;
END;
$$;


--
-- Name: spLimpiarMovimientosProduccion(text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spLimpiarMovimientosProduccion"(INOUT p_mensaje_resultado text DEFAULT ''::text)
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


--
-- Name: spLogRegistrar(integer, text, text, text, jsonb, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spLogRegistrar"(IN p_user_id integer, IN p_module text, IN p_action text, IN p_description text, IN p_metadata jsonb, INOUT p_temp_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."SystemLog" (
        "userId", "module", "action", "description", "metadata", "createdAt"
    ) VALUES (
        p_user_id, UPPER(p_module), UPPER(p_action), p_description, p_metadata, NOW()
    ) RETURNING id INTO p_temp_id;
END;
$$;


--
-- Name: spPaymentActualizar(integer, text, text, boolean, boolean, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spPaymentActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_inactive boolean, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Payment" WHERE id = p_id;
    IF v_existente IS NULL THEN p_mensaje_resultado := 'ERROR: No existe.'; RETURN; END IF;
    SELECT id INTO v_existente FROM public."Payment" WHERE "code" = p_code AND id <> p_id;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    UPDATE public."Payment" SET "code" = COALESCE(TRIM(p_code), ''), "name" = TRIM(p_name), "iscash" = COALESCE(p_iscash, false), "iscredit" = COALESCE(p_iscredit, false), "inactive" = COALESCE(p_inactive, false) WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spPaymentCrear(text, text, boolean, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spPaymentCrear"(IN p_code text, IN p_name text, IN p_iscash boolean, IN p_iscredit boolean, IN p_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE v_existente integer;
BEGIN
    SELECT id INTO v_existente FROM public."Payment" WHERE "code" = p_code;
    IF v_existente IS NOT NULL THEN p_mensaje_resultado := 'ERROR: El código ya existe.'; RETURN; END IF;
    INSERT INTO public."Payment" ("code", "name", "iscash", "iscredit", "inactive") VALUES (COALESCE(TRIM(p_code), ''), TRIM(p_name), COALESCE(p_iscash, false), COALESCE(p_iscredit, false), false) RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; p_id := 0; END; $$;


--
-- Name: spPaymentEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spPaymentEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Payment" WHERE id = p_id; p_mensaje_resultado := 'SUCCESS';
EXCEPTION WHEN foreign_key_violation THEN p_mensaje_resultado := 'ERROR: En uso.'; WHEN OTHERS THEN p_mensaje_resultado := 'ERROR: ' || SQLERRM; END; $$;


--
-- Name: spPreCotizacionConvertir(integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spPreCotizacionConvertir"(IN p_pre_quotation_id integer, IN p_quotation_id integer, IN p_acting_user_id integer, IN p_notice_response text, OUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_is_convert BOOLEAN;
    v_current_state TEXT;
    v_acting_user_id INT;
BEGIN
    IF p_pre_quotation_id IS NULL OR p_pre_quotation_id = 0 THEN
        p_mensaje_resultado := 'ERROR: ID de Pre-Cotización inválido.';
        RETURN;
    END IF;

    -- Obtener userId válido garantizado para evitar NOT NULL / FK violations
    SELECT COALESCE(
        (SELECT id FROM public."User" WHERE id = p_acting_user_id LIMIT 1),
        (SELECT "userId" FROM public."PreQuotation" WHERE id = p_pre_quotation_id),
        (SELECT id FROM public."User" ORDER BY id ASC LIMIT 1),
        1
    ) INTO v_acting_user_id;

    v_is_convert := (p_quotation_id IS NOT NULL AND p_quotation_id > 0);

    SELECT state INTO v_current_state FROM public."PreQuotation" WHERE id = p_pre_quotation_id;

    IF v_is_convert THEN
        UPDATE public."PreQuotation"
        SET state = 'COTIZADA',
            "convertedQuotationId" = p_quotation_id,
            "convertedAt" = CURRENT_TIMESTAMP,
            "convertedUserId" = v_acting_user_id,
            "noticeResponse" = COALESCE(p_notice_response, "noticeResponse"),
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = p_pre_quotation_id;

        INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
        VALUES (p_pre_quotation_id, 'COTIZADA', 'Pre-cotización convertida exitosamente a cotización (ID: ' || p_quotation_id::TEXT || ')', v_acting_user_id, CURRENT_TIMESTAMP);

        p_mensaje_resultado := 'SUCCESS: Pre-Cotización convertida a Cotización correctamente.';
    ELSE
        UPDATE public."PreQuotation"
        SET "noticeResponse" = COALESCE(p_notice_response, "noticeResponse"),
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE id = p_pre_quotation_id;

        INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
        VALUES (p_pre_quotation_id, COALESCE(v_current_state, 'POR COTIZAR'), 'Respuesta / Duda registrada en la pre-cotización: ' || COALESCE(p_notice_response, ''), v_acting_user_id, CURRENT_TIMESTAMP);

        p_mensaje_resultado := 'SUCCESS: Respuesta / Duda registrada en la Pre-Cotización correctamente.';
    END IF;
END;
$$;


--
-- Name: spPreCotizacionCrear(jsonb, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spPreCotizacionCrear"(IN p_data jsonb, IN p_acting_user_id integer, OUT p_pre_quotation_id integer, OUT p_consecutivo integer, OUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_consecutivo INT;
    v_branch_id INT;
BEGIN
    v_branch_id := NULLIF(p_data->>'branchId', '')::INT;

    IF v_branch_id IS NULL THEN
        p_pre_quotation_id := 0;
        p_consecutivo := 0;
        p_mensaje_resultado := 'ERROR: La sucursal es obligatoria.';
        RETURN;
    END IF;

    -- Obtener el consecutivo único compartido de la secuencia
    v_consecutivo := nextval('public.seq_quotation_consecutivo')::INT;

    INSERT INTO public."PreQuotation" (
        consecutivo,
        "clientNameText",
        "clientId",
        "headerDescription",
        "providerId",
        "ticketPrinterId",
        "sellerId",
        "branchId",
        "preQuotationType",
        "quotationNotice",
        "noticeResponse",
        "startDate",
        "endDate",
        "customFields",
        "state",
        "userId",
        "createdAt",
        "updatedAt"
    ) VALUES (
        v_consecutivo,
        p_data->>'clientNameText',
        NULLIF(p_data->>'clientId', '')::INT,
        p_data->>'headerDescription',
        NULLIF(p_data->>'providerId', '')::INT,
        NULLIF(p_data->>'ticketPrinterId', '')::INT,
        NULLIF(p_data->>'sellerId', '')::INT,
        v_branch_id,
        COALESCE(NULLIF(p_data->>'preQuotationType', ''), 'General'),
        p_data->>'quotationNotice',
        p_data->>'noticeResponse',
        CASE WHEN p_data->>'startDate' IS NOT NULL AND p_data->>'startDate' <> '' THEN (p_data->>'startDate')::TIMESTAMP ELSE NULL END,
        CASE WHEN p_data->>'endDate' IS NOT NULL AND p_data->>'endDate' <> '' THEN (p_data->>'endDate')::TIMESTAMP ELSE NULL END,
        COALESCE(p_data->'customFields', '{}'::jsonb),
        'POR COTIZAR',
        p_acting_user_id,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_pre_quotation_id;

    -- Historial de estado inicial
    INSERT INTO public."PreQuotationStateHistory" ("preQuotationId", "state", "description", "userId", "createdAt")
    VALUES (p_pre_quotation_id, 'POR COTIZAR', 'Creación de pre-cotización con consecutivo #' || v_consecutivo, p_acting_user_id, CURRENT_TIMESTAMP);

    p_consecutivo := v_consecutivo;
    p_mensaje_resultado := 'SUCCESS: Pre-Cotización creada correctamente con consecutivo #' || v_consecutivo;
END;
$$;


--
-- Name: spQuotationStateActualizar(integer, text, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spQuotationStateActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_color text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."QuotationState"
    SET code = COALESCE(p_code, code),
        name = COALESCE(p_name, name),
        color = p_color
    WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización actualizado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spQuotationStateCrear(text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spQuotationStateCrear"(IN p_code text, IN p_name text, IN p_color text, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."QuotationState" (code, name, color)
    VALUES (p_code, p_name, p_color)
    RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización creado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spQuotationStateEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spQuotationStateEliminar"(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."QuotationState" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Estado de cotización eliminado correctamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spRoleGuardarYPermisos(integer, character varying, text, jsonb); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spRoleGuardarYPermisos"(IN p_id integer, IN p_name character varying, IN p_description text, IN p_permissions jsonb, OUT p_res_id integer, OUT p_message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_name VARCHAR;
BEGIN
    v_name := TRIM(p_name);
    
    IF v_name IS NULL OR v_name = '' THEN
        p_res_id := 0;
        p_message := 'El nombre del rol no puede estar vacío.';
        RETURN;
    END IF;

    -- Si p_id es nulo o 0 -> Crear Nuevo Rol
    IF p_id IS NULL OR p_id = 0 THEN
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name)) THEN
            p_res_id := 0;
            p_message := 'Ya existe un rol registrado con ese nombre.';
            RETURN;
        END IF;

        INSERT INTO public."Role" (name, description, permissions)
        VALUES (v_name, TRIM(p_description), COALESCE(p_permissions, '{}'::jsonb))
        RETURNING id INTO p_res_id;

        p_message := 'Rol creado exitosamente en la base de datos.';
        RETURN;
    ELSE
        -- Actualizar Rol Existente
        IF EXISTS (SELECT 1 FROM public."Role" WHERE UPPER(name) = UPPER(v_name) AND id <> p_id) THEN
            p_res_id := 0;
            p_message := 'El nombre especificado ya está en uso por otro rol.';
            RETURN;
        END IF;

        UPDATE public."Role"
        SET name = v_name,
            description = TRIM(p_description),
            permissions = COALESCE(p_permissions, permissions)
        WHERE id = p_id;

        p_res_id := p_id;
        p_message := 'Rol y matriz de permisos actualizados correctamente.';
        RETURN;
    END IF;
END;
$$;


--
-- Name: spSiteModuleMasterToggle(text, integer, boolean); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spSiteModuleMasterToggle"(IN p_type text, IN p_id integer, IN p_active boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF UPPER(p_type) = 'MENU' THEN
        UPDATE public."Menu"
        SET activo = p_active
        WHERE id = p_id;
    ELSIF UPPER(p_type) = 'MASTER' THEN
        UPDATE public."Master"
        SET inactivo = NOT p_active
        WHERE id = p_id;
    ELSE
        RAISE EXCEPTION 'Tipo no válido: %. Se requiere MENU o MASTER.', p_type;
    END IF;
END;
$$;


--
-- Name: spTicketTypeActualizar(integer, text, text, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTicketTypeActualizar"(IN p_id integer, IN p_code text, IN p_name text, IN p_description text, IN p_isactive boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."TicketType"
    SET code = COALESCE(p_code, code),
        name = COALESCE(p_name, name),
        description = p_description,
        "isActive" = COALESCE(p_isActive, "isActive")
    WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete actualizado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spTicketTypeCrear(text, text, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTicketTypeCrear"(IN p_code text, IN p_name text, IN p_description text, IN p_isactive boolean, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."TicketType" (code, name, description, "isActive")
    VALUES (p_code, p_name, p_description, COALESCE(p_isActive, true))
    RETURNING id INTO p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete creado correctamente.';
EXCEPTION
    WHEN unique_violation THEN
        p_mensaje_resultado := 'ERROR: El código ya existe.';
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spTicketTypeEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTicketTypeEliminar"(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."TicketType" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tipo de Tiquete eliminado correctamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END; $$;


--
-- Name: spTransactionConsecutiveActualizar(integer, text, text, text, integer, integer, integer, integer, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTransactionConsecutiveActualizar"(IN p_id integer, IN p_transaction_type text, IN p_description text, IN p_prefix text, IN p_initial_number integer, IN p_current_number integer, IN p_branch_id integer, IN p_implant_id integer, IN p_is_active boolean, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción es obligatoria.';
        RETURN;
    END IF;

    UPDATE public."TransactionConsecutive"
    SET 
        "transactionType" = UPPER(TRIM(p_transaction_type)),
        "description" = TRIM(p_description),
        "prefix" = TRIM(p_prefix),
        "initialNumber" = COALESCE(p_initial_number, "initialNumber"),
        "currentNumber" = COALESCE(p_current_number, "currentNumber"),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "isActive" = COALESCE(p_is_active, "isActive")
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spTransactionConsecutiveCrear(text, text, text, integer, integer, integer, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTransactionConsecutiveCrear"(IN p_transaction_type text, IN p_description text, IN p_prefix text, IN p_initial_number integer, IN p_branch_id integer, IN p_implant_id integer, IN p_is_active boolean, IN p_user_id integer, INOUT p_consecutivo_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_transaction_type IS NULL OR TRIM(p_transaction_type) = '' THEN
        p_mensaje_resultado := 'ERROR: El tipo de transacción es obligatorio.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        p_mensaje_resultado := 'ERROR: La descripción de la transacción es obligatoria.';
        p_consecutivo_id := 0;
        RETURN;
    END IF;

    IF p_initial_number IS NULL OR p_initial_number < 1 THEN
        p_initial_number := 1;
    END IF;

    INSERT INTO public."TransactionConsecutive" (
        "transactionType",
        "description",
        "prefix",
        "initialNumber",
        "currentNumber",
        "branchId",
        "implantId",
        "isActive",
        "createdAt"
    ) VALUES (
        UPPER(TRIM(p_transaction_type)),
        TRIM(p_description),
        TRIM(p_prefix),
        p_initial_number,
        p_initial_number,
        p_branch_id,
        p_implant_id,
        COALESCE(p_is_active, true),
        CURRENT_TIMESTAMP
    ) RETURNING id INTO p_consecutivo_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        p_consecutivo_id := 0;
END;
$$;


--
-- Name: spTransactionConsecutiveEliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public."spTransactionConsecutiveEliminar"(IN p_id integer, IN p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."TransactionConsecutive"
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spbranchactualizar(integer, text, text, bytea, bytea, jsonb, text, integer, bytea, jsonb, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spbranchactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_resolution_id integer DEFAULT NULL::integer, IN p_invoice_template bytea DEFAULT NULL::bytea, IN p_invoice_template_config jsonb DEFAULT NULL::jsonb, IN p_invoice_html_template text DEFAULT NULL::text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Branch" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Sucursal con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."Branch"
    SET "code" = p_code,
        "name" = p_name,
        "logo" = COALESCE(p_logo, "logo"),
        "template" = COALESCE(p_template, "template"),
        "templateConfig" = COALESCE(p_template_config, "templateConfig"),
        "htmlTemplate" = COALESCE(p_html_template, "htmlTemplate"),
        "resolutionId" = p_resolution_id,
        "invoiceTemplate" = COALESCE(p_invoice_template, "invoiceTemplate"),
        "invoiceTemplateConfig" = COALESCE(p_invoice_template_config, "invoiceTemplateConfig"),
        "invoiceHtmlTemplate" = COALESCE(p_invoice_html_template, "invoiceHtmlTemplate"),
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Sucursal actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spbranchcrear(text, text, bytea, bytea, jsonb, text, integer, bytea, jsonb, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spbranchcrear(IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_resolution_id integer DEFAULT NULL::integer, IN p_invoice_template bytea DEFAULT NULL::bytea, IN p_invoice_template_config jsonb DEFAULT NULL::jsonb, IN p_invoice_html_template text DEFAULT NULL::text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_branch_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Branch" (
        "code", "name", "logo", "template", "templateConfig", "htmlTemplate",
        "resolutionId", "invoiceTemplate", "invoiceTemplateConfig", "invoiceHtmlTemplate", "isActive"
    )
    VALUES (
        p_code, p_name, p_logo, p_template, p_template_config, p_html_template,
        p_resolution_id, p_invoice_template, p_invoice_template_config, p_invoice_html_template, COALESCE(p_is_active, true)
    )
    RETURNING id INTO p_branch_id;

    p_mensaje_resultado := 'SUCCESS: Sucursal creada con ID ' || p_branch_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spbrancheliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spbrancheliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Branch" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Sucursal con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."Branch" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Sucursal eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spcellcustomizationdelete(text, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcellcustomizationdelete(IN p_code text, IN p_branch_id integer, IN p_implant_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "branchId" = p_branch_id AND "implantId" IS NULL;
    ELSIF p_implant_id IS NOT NULL THEN
        DELETE FROM public."CellCustomization"
        WHERE "code" = p_code AND "implantId" = p_implant_id;
    END IF;
END;
$$;


--
-- Name: spcellcustomizationupsert(text, text, text, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcellcustomizationupsert(IN p_code text, IN p_name text, IN p_value text, IN p_branch_id integer, IN p_implant_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_branch_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, p_branch_id, NULL)
        ON CONFLICT ("branchId", "code") WHERE "branchId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    ELSIF p_implant_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" ("code", "name", "value", "branchId", "implantId")
        VALUES (p_code, p_name, p_value, NULL, p_implant_id)
        ON CONFLICT ("implantId", "code") WHERE "implantId" IS NOT NULL
        DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
    END IF;
END;
$$;


--
-- Name: spclienteactualizar(integer, text, text, text, text, jsonb, integer, integer, boolean, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spclienteactualizar(IN p_id integer, IN p_name text, IN p_document text, IN p_contact_info text, IN p_address text, IN p_mandatory_variables jsonb, IN p_acting_user_id integer, IN p_seller_id integer DEFAULT NULL::integer, IN p_is_active boolean DEFAULT true, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Client" WHERE document = p_document AND id <> p_id) THEN
        p_mensaje_resultado := 'ERROR: El documento ya está registrado por otro cliente.';
        RETURN;
    END IF;

    UPDATE public."Client" SET
        "name" = p_name,
        "document" = p_document,
        "contactInfo" = p_contact_info,
        "address" = p_address,
        "mandatoryVariables" = p_mandatory_variables,
        "sellerId" = p_seller_id,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cliente ' || p_id || ' actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spclientecrear(text, text, text, text, jsonb, integer, integer, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spclientecrear(IN p_name text, IN p_document text, IN p_contact_info text, IN p_address text, IN p_mandatory_variables jsonb, IN p_acting_user_id integer, IN p_seller_id integer DEFAULT NULL::integer, IN p_is_active boolean DEFAULT true, INOUT p_client_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Client" WHERE document = p_document) THEN
        p_mensaje_resultado := 'ERROR: El documento ya está registrado';
        RETURN;
    END IF;

    INSERT INTO public."Client" ("name", "document", "contactInfo", "address", "mandatoryVariables", "sellerId", "isActive")
    VALUES (p_name, p_document, p_contact_info, p_address, p_mandatory_variables, p_seller_id, COALESCE(p_is_active, true))
    RETURNING id INTO p_client_id;

    p_mensaje_resultado := 'SUCCESS: Cliente creado con ID ' || p_client_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spclienteeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spclienteeliminar(IN p_id integer, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT name INTO v_name FROM public."Client" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El cliente no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."Quotation" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."Invoices" WHERE "clientId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."PreQuotation" WHERE "clientId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el cliente "' || v_name || '" porque cuenta con ' || v_count || ' registro(s) de cotizaciones o facturas asociadas. Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Client" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Cliente eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spcomboactualizar(integer, text, text, integer, integer, jsonb, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcomboactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_cupos integer, IN p_currency_id integer, IN p_products jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_item RECORD;
        v_tax RECORD;
        v_combo_product_id INT;
        v_local_combo_id INT := p_id;
    BEGIN
        IF v_local_combo_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: p_id is NULL (backend error).';
            RETURN;
        END IF;

        -- Actualizar datos básicos
        UPDATE public."Combo" SET "code" = p_code, "name" = p_name, "cupos" = COALESCE(p_cupos, 0), "currencyId" = p_currency_id, "updatedAt"=CURRENT_TIMESTAMP WHERE id = v_local_combo_id;

        -- Limpiar productos previos
        DELETE FROM public."ComboProductTax" WHERE "comboProductId" IN (SELECT id FROM public."ComboProduct" WHERE "comboId" = v_local_combo_id);
        DELETE FROM public."ComboProduct" WHERE "comboId" = v_local_combo_id;

        -- Insertar productos nuevos
        IF p_products IS NOT NULL AND jsonb_array_length(p_products) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_to_recordset(p_products) AS x(
                "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" INT, "prestadoraId" INT, 
                "checkInDate" TIMESTAMP, "checkOutDate" TIMESTAMP,
                "paxAdults" INT, "paxChildren" INT, "mainTaxId" INT, "appliedTaxes" JSONB, "inNationality" INT
            )
            LOOP
                IF v_item."productId" IS NOT NULL THEN
                    INSERT INTO public."ComboProduct" (
                        "comboId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                        "checkInDate", "checkOutDate",
                        "paxAdults", "paxChildren", "mainTaxId", "inNationality"
                    ) VALUES (
                        v_local_combo_id, v_item."productId", COALESCE(v_item.quantity, 1), COALESCE(v_item.price, 0), v_item.cost, v_item."providerId", v_item."prestadoraId",
                        v_item."checkInDate", v_item."checkOutDate",
                        v_item."paxAdults", v_item."paxChildren", v_item."mainTaxId", COALESCE(v_item."inNationality", 1)
                    ) RETURNING id INTO v_combo_product_id;

                    -- Insertar impuestos del producto si existen
                    IF v_item."appliedTaxes" IS NOT NULL THEN
                        FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS t("chargeAndTaxId" INT, amount FLOAT, "isMain" BOOLEAN)
                        LOOP
                            INSERT INTO public."ComboProductTax" ("comboProductId", "chargeAndTaxId", "amount", "isMain")
                            VALUES (v_combo_product_id, v_tax."chargeAndTaxId", v_tax.amount, COALESCE(v_tax."isMain", FALSE));
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        p_mensaje_resultado := 'SUCCESS: Combo ' || v_local_combo_id || ' actualizado correctamente.';
    EXCEPTION WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
$$;


--
-- Name: spcombocrear(text, text, integer, integer, jsonb, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcombocrear(IN p_code text, IN p_name text, IN p_cupos integer, IN p_currency_id integer, IN p_products jsonb, IN p_acting_user_id integer, INOUT p_combo_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_item RECORD;
        v_tax RECORD;
        v_combo_product_id INT;
        v_inserted_combo_id INT;
    BEGIN
        -- Insertar el combo principal
        INSERT INTO public."Combo" ("code", "name", "cupos", "currencyId", "createdAt","updatedAt")
        VALUES (p_code, p_name, COALESCE(p_cupos, 0), p_currency_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING id INTO v_inserted_combo_id;

        IF v_inserted_combo_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: No se pudo generar el ID del Combo.';
            RETURN;
        END IF;

        -- Insertar productos del combo
        IF p_products IS NOT NULL AND jsonb_array_length(p_products) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_to_recordset(p_products) AS x(
                "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" INT, "prestadoraId" INT, 
                "checkInDate" TIMESTAMP, "checkOutDate" TIMESTAMP,
                "paxAdults" INT, "paxChildren" INT, "mainTaxId" INT, "appliedTaxes" JSONB, "inNationality" INT
            )
            LOOP
                -- Solo insertar si hay un producto válido
                IF v_item."productId" IS NOT NULL THEN
                    INSERT INTO public."ComboProduct" (
                        "comboId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId", 
                        "checkInDate", "checkOutDate",
                        "paxAdults", "paxChildren", "mainTaxId", "inNationality"
                    ) VALUES (
                        v_inserted_combo_id, v_item."productId", COALESCE(v_item.quantity, 1), COALESCE(v_item.price, 0), v_item.cost, v_item."providerId", v_item."prestadoraId",
                        v_item."checkInDate", v_item."checkOutDate",
                        v_item."paxAdults", v_item."paxChildren", v_item."mainTaxId", COALESCE(v_item."inNationality", 1)
                    ) RETURNING id INTO v_combo_product_id;

                    -- Insertar impuestos asociados si existen
                    IF v_item."appliedTaxes" IS NOT NULL THEN
                        FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS t("chargeAndTaxId" INT, amount FLOAT, "isMain" BOOLEAN)
                        LOOP
                            INSERT INTO public."ComboProductTax" ("comboProductId", "chargeAndTaxId", "amount", "isMain")
                            VALUES (v_combo_product_id, v_tax."chargeAndTaxId", v_tax.amount, COALESCE(v_tax."isMain", FALSE));
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        p_combo_id := v_inserted_combo_id;
        p_mensaje_resultado := 'SUCCESS: Combo creado correctamente con ID ' || v_inserted_combo_id;

    EXCEPTION WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
$$;


--
-- Name: spcomboeliminar(integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcomboeliminar(IN p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Combo" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Combo eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
        ROLLBACK;
END;
$$;


--
-- Name: spcotizacionactualizar(integer, jsonb, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcotizacionactualizar(IN p_id integer, IN p_data jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_item RECORD;
    v_tax RECORD;
    v_pax RECORD;
    v_var RECORD;
    v_pmt RECORD;
    v_combo RECORD;
    v_manual RECORD;
    v_quotation_product_id INT;
    -- Variables para validación de campos obligatorios dinámicos
    v_val_item JSONB;
    v_val_prod_id INT;
    v_mandatory_fields JSONB;
    v_field_key TEXT;
    v_model TEXT;
    v_field_name TEXT;
    v_prod_desc TEXT;
    v_has_passengers BOOLEAN;
    v_has_empty_pax_name BOOLEAN;
    v_has_payments BOOLEAN;
    v_json_field_name TEXT;
    -- Variables para validación de variables obligatorias específicas del cliente
    v_client_id INT;
    v_client_mandatory_vars JSONB;
    v_client_var_id_text TEXT;
    v_req_var_id INT;
    v_req_var_name TEXT;
    v_item_json JSONB;
    v_item_prod_id INT;
    v_item_prod_desc TEXT;
    v_has_var BOOLEAN;
    v_old_state TEXT;
    -- Variables para cálculos financieros
    v_mostrar_totalizacion BOOLEAN;
    v_comision_utilidad DOUBLE PRECISION;
    v_comision_freelance DOUBLE PRECISION;
    v_comision_propia DOUBLE PRECISION;
    v_costo_total DOUBLE PRECISION;
    v_valor_base DOUBLE PRECISION;
    v_decimals INT;
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM public."Quotation" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: La cotización con ID ' || p_id || ' no existe.';
        RETURN;
    END IF;

    SELECT "state" INTO v_old_state FROM public."Quotation" WHERE id = p_id;

    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La cotización debe tener al menos un producto.';
        RETURN;
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_to_recordset(p_data->'items') AS x("productId" INT, "mainTaxId" TEXT)
        WHERE "productId" IS NULL OR NULLIF("mainTaxId", '') IS NULL
    ) THEN
        p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto y un Cargo Principal seleccionado.';
        RETURN;
    END IF;

    -- Validación de campos obligatorios dinámicos por producto
    FOR v_val_item IN SELECT jsonb_array_elements(p_data->'items')
    LOOP
        v_val_prod_id := (v_val_item->>'productId')::INT;
        
        SELECT "mandatoryFields", "description" 
        INTO v_mandatory_fields, v_prod_desc 
        FROM public."Product" 
        WHERE id = v_val_prod_id;

        v_prod_desc := COALESCE(v_prod_desc, 'Producto #' || v_val_prod_id);

        IF v_mandatory_fields IS NOT NULL AND jsonb_typeof(v_mandatory_fields) = 'array' THEN
            FOR v_field_key IN SELECT jsonb_array_elements_text(v_mandatory_fields)
            LOOP
                v_model := split_part(v_field_key, '.', 1);
                v_field_name := split_part(v_field_key, '.', 2);

                IF v_model = 'Quotation' THEN
                    IF NULLIF(p_data->>v_field_name, '') IS NULL THEN
                        p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo general "' || v_field_name || '".';
                        RETURN;
                    END IF;
                ELSIF v_model = 'QuotationProduct' THEN
                    v_json_field_name := v_field_name;
                    IF v_field_name = 'checkInDate' THEN
                        v_json_field_name := 'checkIn';
                    ELSIF v_field_name = 'checkOutDate' THEN
                        v_json_field_name := 'checkOut';
                    ELSIF v_field_name = 'description' THEN
                        v_json_field_name := 'descripcion';
                    ELSIF v_field_name = 'service' THEN
                        IF NULLIF(v_val_item->>'service', '') IS NULL AND v_val_item->>'servicios' IS NOT NULL THEN
                            v_json_field_name := 'servicios';
                        END IF;
                    END IF;

                    IF v_field_name = 'passengers' THEN
                        v_has_passengers := FALSE;
                        v_has_empty_pax_name := FALSE;
                        
                        IF v_val_item->'passengers' IS NOT NULL AND jsonb_typeof(v_val_item->'passengers') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'passengers') > 0, FALSE) INTO v_has_passengers;
                            SELECT EXISTS (
                                SELECT 1 FROM jsonb_to_recordset(v_val_item->'passengers') AS p(name TEXT)
                                WHERE p.name IS NULL OR trim(p.name) = ''
                            ) INTO v_has_empty_pax_name;
                        END IF;

                        IF NOT v_has_passengers OR v_has_empty_pax_name THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pasajero con su nombre.';
                            RETURN;
                        END IF;
                    ELSIF v_field_name = 'payments' THEN
                        v_has_payments := FALSE;
                        IF v_val_item->'payments' IS NOT NULL AND jsonb_typeof(v_val_item->'payments') = 'array' THEN
                            SELECT COALESCE(jsonb_array_length(v_val_item->'payments') > 0, FALSE) INTO v_has_payments;
                        END IF;

                        IF NOT v_has_payments THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere registrar al menos un pago.';
                            RETURN;
                        END IF;
                    ELSE
                        IF NULLIF(v_val_item->>v_json_field_name, '') IS NULL THEN
                            p_mensaje_resultado := 'ERROR: El producto "' || v_prod_desc || '" requiere completar el campo "' || v_field_name || '".';
                            RETURN;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    -- Validación de variables obligatorias específicas del cliente
    v_client_id := NULLIF(p_data->>'clientId', '')::INT;
    IF v_client_id IS NOT NULL THEN
        SELECT "mandatoryVariables" INTO v_client_mandatory_vars
        FROM public."Client"
        WHERE id = v_client_id;

        IF v_client_mandatory_vars IS NOT NULL AND jsonb_typeof(v_client_mandatory_vars) = 'array' AND jsonb_array_length(v_client_mandatory_vars) > 0 THEN
            FOR v_client_var_id_text IN SELECT jsonb_array_elements_text(v_client_mandatory_vars)
            LOOP
                v_req_var_id := v_client_var_id_text::INT;
                
                SELECT "name" INTO v_req_var_name FROM public."MasterVariable" WHERE id = v_req_var_id;
                v_req_var_name := COALESCE(v_req_var_name, 'Variable #' || v_req_var_id);

                FOR v_item_json IN SELECT jsonb_array_elements(p_data->'items')
                LOOP
                    v_item_prod_id := (v_item_json->>'productId')::INT;
                    SELECT "description" INTO v_item_prod_desc FROM public."Product" WHERE id = v_item_prod_id;
                    v_item_prod_desc := COALESCE(v_item_prod_desc, 'Producto #' || v_item_prod_id);

                    SELECT EXISTS (
                        SELECT 1 FROM jsonb_to_recordset(v_item_json->'variables') AS v("masterVariableId" INT, value TEXT)
                        WHERE v."masterVariableId" = v_req_var_id AND NULLIF(trim(v.value), '') IS NOT NULL
                    ) INTO v_has_var;

                    IF NOT v_has_var THEN
                        p_mensaje_resultado := 'ERROR: El cliente requiere completar la variable adicional "' || v_req_var_name || '" en el producto "' || v_item_prod_desc || '".';
                        RETURN;
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
    END IF;

    -- Obtener decimales de la moneda
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    UPDATE public."Quotation" SET
        "clientId" = NULLIF(p_data->>'clientId', '')::INT,
        "currency" = p_data->>'currency',
        "exchangeRate" = NULLIF(p_data->>'exchangeRate', '')::FLOAT,
        "branchId" = NULLIF(p_data->>'branchId', '')::INT,
        "implantId" = NULLIF(p_data->>'implantId', '')::INT,
        "sellerId" = NULLIF(p_data->>'sellerId', '')::INT,
        "ticketPrinterId" = NULLIF(p_data->>'ticketPrinterId', '')::INT,
        "commissionPercentage" = NULLIF(p_data->>'commissionPercentage', '')::FLOAT,
        "chargesAndTaxes" = ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision,
        "totalAmount" = ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision,
        "state" = COALESCE(p_data->>'state', 'Nuevo'),
        "stateDescription" = CASE WHEN COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN p_data->>'stateDescription' ELSE "stateDescription" END,
        "stateUpdatedAt" = CASE WHEN COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN CURRENT_TIMESTAMP ELSE "stateUpdatedAt" END,
        "date" = CURRENT_TIMESTAMP,
        "destination" = p_data->>'destination',
        "startDate" = CASE WHEN p_data->>'startDate' IS NOT NULL AND p_data->>'startDate' <> '' THEN (p_data->>'startDate')::TIMESTAMP ELSE NULL END,
        "endDate" = CASE WHEN p_data->>'endDate' IS NOT NULL AND p_data->>'endDate' <> '' THEN (p_data->>'endDate')::TIMESTAMP ELSE NULL END,
        "passenger" = p_data->>'passenger',
        "paxAdults" = NULLIF(p_data->>'paxAdults', '')::INT,
        "paxChildren" = NULLIF(p_data->>'paxChildren', '')::INT,
        "reservationCode" = p_data->>'reservationCode',
        "copyFieldsToProducts" = COALESCE(NULLIF(p_data->>'copyFieldsToProducts', '')::BOOLEAN, TRUE),
        "manualDescription" = p_data->>'manualDescription'
    WHERE id = p_id;

    -- Insertar historial de estado si cambia
    IF COALESCE(v_old_state, '') <> COALESCE(p_data->>'state', 'Nuevo') THEN
        INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
        VALUES (p_id, COALESCE(p_data->>'state', 'Nuevo'), p_data->>'stateDescription', CURRENT_TIMESTAMP, p_acting_user_id);
    END IF;

    DELETE FROM public."QuotationCombo" WHERE "quotationId" = p_id;
    FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
    LOOP
        INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
        VALUES (p_id, COALESCE(v_combo."comboId", v_combo.id));
    END LOOP;

    DELETE FROM public."QuotationManualService" WHERE "quotationId" = p_id;
    IF p_data->'manualServices' IS NOT NULL AND jsonb_typeof(p_data->'manualServices') = 'array' THEN
        FOR v_manual IN SELECT * FROM jsonb_to_recordset(p_data->'manualServices') AS x(
            "providerName" TEXT, "serviceName" TEXT, "cost" FLOAT, "salePrice" FLOAT, "utility" FLOAT
        )
        LOOP
            INSERT INTO public."QuotationManualService" (
                "quotationId", "providerName", "serviceName", "cost", "salePrice", "utility"
            ) VALUES (
                p_id, 
                v_manual."providerName", 
                v_manual."serviceName", 
                COALESCE(v_manual."cost", 0), 
                COALESCE(v_manual."salePrice", 0), 
                COALESCE(v_manual."utility", COALESCE(v_manual."salePrice", 0) - COALESCE(v_manual."cost", 0))
            );
        END LOOP;
    END IF;

    DELETE FROM public."QuotationProduct" WHERE "quotationId" = p_id;
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                      "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                      "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                      "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                      "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "payments" JSONB, "inNationality" INT,
                      "service" TEXT, "servicios" TEXT, "descripcion" TEXT, "passenger" TEXT
                  )
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission", 
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            p_id, v_item."productId", v_item.quantity, 
            ROUND(v_item.price::numeric, v_decimals)::double precision, 
            ROUND(v_item.cost::numeric, v_decimals)::double precision, 
            NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
            CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
            CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
            v_item.nights, v_item."paxAdults", v_item."paxChildren",
            v_item."serviceType", v_item."destination", v_item."reservationCode", 
            ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
            ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
            NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
            COALESCE(v_item."service", v_item."servicios"), COALESCE(v_item."servicios", v_item."service"), v_item."descripcion",
            v_item."passenger"
        ) RETURNING id INTO v_quotation_product_id;

        IF v_item.passengers IS NOT NULL THEN
            FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
            LOOP
                INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
                VALUES (v_quotation_product_id, v_pax.name, v_pax.document);
            END LOOP;
        END IF;

        IF v_item."appliedTaxes" IS NOT NULL THEN
            FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
            LOOP
                INSERT INTO public."QuotationProductTax" (
                    "quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                )
                SELECT v_quotation_product_id, ct.id, ct.value, ct."valueType", 
                       ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                       CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                FROM public."ChargeAndTax" ct
                WHERE ct.id = v_tax."chargeAndTaxId";
            END LOOP;
        END IF;

        IF v_item.variables IS NOT NULL THEN
            FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
            LOOP
                INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
                VALUES (v_quotation_product_id, v_var."masterVariableId", v_var.value);
            END LOOP;
        END IF;

        IF v_item.payments IS NOT NULL THEN
            FOR v_pmt IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(
                "amount" FLOAT, "paymentMethod" TEXT, "date" TEXT, "reference" TEXT,
                "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT
            )
            LOOP
                INSERT INTO public."QuotationProductPayment" (
                    "quotationProductId", "amount", "paymentMethod", "reference", "date",
                    "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
                ) VALUES (
                    v_quotation_product_id, 
                    ROUND(v_pmt."amount"::numeric, v_decimals)::double precision, 
                    v_pmt."paymentMethod", v_pmt."reference",
                    CASE WHEN v_pmt."date" IS NOT NULL AND v_pmt."date" <> '' THEN v_pmt."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END,
                    v_pmt."creditCardId", v_pmt."cardNumber", v_pmt."authorizationCode", v_pmt."voucher", v_pmt."expirationDate"
                );
            END LOOP;
        END IF;
    END LOOP;

    -- Recalcular valores financieros
    SELECT 
        COALESCE(SUM(qp.cost), 0.0), 
        COALESCE(SUM(
            qp.price * qp.quantity + COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM public."QuotationProductTax" qpt2
                JOIN public."ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0.0)
        ), 0.0)
    INTO v_costo_total, v_valor_base
    FROM public."QuotationProduct" qp
    WHERE qp."quotationId" = p_id;

    SELECT COALESCE(value = 'true', FALSE) INTO v_mostrar_totalizacion
    FROM public."SystemParameter"
    WHERE code = 'MOSTRAR_TOTALIZACION_COTIZACION';

    v_comision_freelance := COALESCE(NULLIF(p_data->>'comisionFreelancePercentage', '')::DOUBLE PRECISION, 0.0);

    IF v_mostrar_totalizacion THEN
        v_comision_utilidad := ROUND(public.fn_calcular_porcentaje_comision(public.fn_calcular_utilidad(v_valor_base, v_costo_total), v_valor_base)::NUMERIC, 2)::DOUBLE PRECISION;
        v_comision_propia := v_comision_utilidad - v_comision_freelance;
    ELSE
        v_comision_propia := public.fn_calcular_comision_resta(
            COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
            v_comision_freelance
        );
    END IF;

    UPDATE public."Quotation"
    SET 
        "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
            SELECT COALESCE(SUM(qpt."explicitAmount"), 0)
            FROM public."QuotationProductTax" qpt
            JOIN public."QuotationProduct" qp ON qpt."quotationProductId" = qp.id
            WHERE qp."quotationId" = p_id
        ))::numeric, v_decimals)::double precision,
        "costoTotal" = ROUND(v_costo_total::numeric, v_decimals)::double precision,
        "valorBase" = ROUND(v_valor_base::numeric, v_decimals)::double precision,
        "comisionTotalPercentage" = COALESCE(NULLIF(p_data->>'comisionTotalPercentage', '')::DOUBLE PRECISION, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::DOUBLE PRECISION, 0.0)),
        "comisionFreelancePercentage" = v_comision_freelance,
        "comisionPropiaPercentage" = v_comision_propia,
        "commissionPercentage" = v_comision_propia,
        "utilidad" = ROUND(public.fn_calcular_utilidad(v_valor_base, v_costo_total)::numeric, v_decimals)::double precision,
        "comisionUtilidadPercentage" = public.fn_calcular_porcentaje_comision(
            public.fn_calcular_utilidad(v_valor_base, v_costo_total),
            v_valor_base
        ),
        "comisionFreelanceValue" = ROUND(public.fn_calcular_valor_comision(v_comision_freelance, v_valor_base)::numeric, v_decimals)::double precision,
        "comisionPropiaValue" = ROUND(public.fn_calcular_valor_comision(v_comision_propia, v_valor_base)::numeric, v_decimals)::double precision
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cotización ' || p_id || ' actualizada correctamente.';

    -- Registrar en Auditoría
    CALL public."spLogRegistrar"(
        p_acting_user_id, 
        'QUOTATION', 
        'UPDATE', 
        'Se actualizó la cotización con ID ' || p_id, 
        p_data, 
        v_quotation_product_id -- Reutilizamos variable para el logId temporal
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spcotizacionactualizarestado(jsonb); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcotizacionactualizarestado(IN p_response jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_estados_str TEXT;
    v_item_text TEXT;
    v_id INT;
    v_estado TEXT;
    v_row_json JSONB;
BEGIN
    /**
     * Este procedimiento recibe la respuesta de SQL Server (spCotizacionesCrear)
     * Parsea UNICAMENTE el nodo 'Estados' que contiene el formato 'ID:Estado|ID:Estado|'
     */
    
    -- El input puede ser un array de objetos o un objeto individual
    -- Buscamos el campo 'Estados' en cada objeto
	
    IF JSONB_TYPEOF(p_response) = 'array' THEN
        FOR v_row_json IN SELECT jsonb_array_elements(p_response)
        LOOP
            v_estados_str := v_row_json->>'Estados';
            
            IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
                -- Iterar sobre cada par ID:Estado separado por '|'
                FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
                LOOP
                    v_item_text := trim(v_item_text);
                    IF v_item_text LIKE '%:%' THEN
                        BEGIN
                            -- Split por ':'
                            v_id := split_part(v_item_text, ':', 1)::INT;
                            v_estado := split_part(v_item_text, ':', 2);
                            
                            -- Actualizar con el estado LITERAL recibido
                            UPDATE public."Quotation"
                            SET "state" = v_estado
                            WHERE id = v_id;
                        EXCEPTION WHEN OTHERS THEN
                            -- Ignorar errores de casteo en items individuales
                        END;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    ELSIF JSONB_TYPEOF(p_response) = 'object' THEN
        v_estados_str := p_response->>'Estados';
        IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
            FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
            LOOP
                v_item_text := trim(v_item_text);
                IF v_item_text LIKE '%:%' THEN
                    BEGIN
                        v_id := split_part(v_item_text, ':', 1)::INT;
                        v_estado := split_part(v_item_text, ':', 2);
                        
                        UPDATE public."Quotation"
                        SET "state" = v_estado
                        WHERE id = v_id;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END LOOP;
        END IF;
    END IF;
	--SELECT * from public."Quotation" WHERE id = 31; 
	--UPDATE public."Quotation"
	--SET "state" = 'Nuevo'--v_row_json::text
	--WHERE id = 31; 
END;
$$;


--
-- Name: spcotizacionactualizarestadomanual(integer, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcotizacionactualizarestadomanual(IN p_quotation_id integer, IN p_state text, IN p_description text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validaciones
    IF p_state IS NULL OR p_state = '' THEN
        p_mensaje_resultado := 'ERROR: El estado es obligatorio.';
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public."Quotation" WHERE id = p_quotation_id) THEN
        p_mensaje_resultado := 'ERROR: La cotización con ID ' || p_quotation_id || ' no existe.';
        RETURN;
    END IF;

    -- Validar si el estado existe en la tabla de estados
    IF NOT EXISTS (SELECT 1 FROM public."QuotationState" WHERE code = p_state) THEN
        p_mensaje_resultado := 'ERROR: El estado "' || p_state || '" no es válido.';
        RETURN;
    END IF;

    UPDATE public."Quotation" SET
        "state" = p_state,
        "stateDescription" = p_description,
        "stateUpdatedAt" = CURRENT_TIMESTAMP
    WHERE id = p_quotation_id;

    -- Insertar historial de estado
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (p_quotation_id, p_state, p_description, CURRENT_TIMESTAMP, p_acting_user_id);

    p_mensaje_resultado := 'SUCCESS: Estado de cotización actualizado correctamente.';

    -- Registrar en Auditoría
    CALL public."spLogRegistrar"(
        p_acting_user_id, 
        'QUOTATION', 
        'UPDATE_STATE', 
        'Se cambió el estado de la cotización ID ' || p_quotation_id || ' a ' || p_state || '. Descripción: ' || COALESCE(p_description, ''), 
        jsonb_build_object('quotationId', p_quotation_id, 'state', p_state, 'description', p_description), 
        p_quotation_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spcotizacionduplicar(integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcotizacionduplicar(IN p_quotation_id integer, IN p_acting_user_id integer, INOUT p_new_quotation_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_internal_number TEXT;
    v_new_id INT;
    v_orig_quotation RECORD;
    v_orig_qp RECORD;
    v_new_qp_id INT;
    v_user_id INT := NULL;
BEGIN
    -- Validar existencia de la cotización origen
    SELECT * INTO v_orig_quotation 
    FROM public."Quotation" 
    WHERE id = p_quotation_id;

    IF v_orig_quotation.id IS NULL THEN
        p_mensaje_resultado := 'ERROR: Cotización origen no encontrada (ID ' || p_quotation_id || ').';
        RETURN;
    END IF;

    -- Validar si p_acting_user_id existe en la tabla User, de lo contrario usar el de la cotización origen
    IF p_acting_user_id IS NOT NULL THEN
        SELECT id INTO v_user_id FROM public."User" WHERE id = p_acting_user_id;
    END IF;

    IF v_user_id IS NULL THEN
        v_user_id := v_orig_quotation."userId";
    END IF;

    -- Generar consecutivo único interno
    v_internal_number := 'QUO-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 10000)::text;

    -- Insertar la cabecera duplicada de la cotización
    INSERT INTO public."Quotation" (
        "internalNumber", "date", "clientId", "currency", "exchangeRate",
        "branchId", "implantId", "sellerId", "ticketPrinterId",
        "baseCommissionable", "commissionPercentage", "chargesAndTaxes",
        "totalAmount", "userId", "state", "stateDescription", "stateUpdatedAt",
        "costoTotal", "valorBase", "utilidad", "comisionTotalPercentage",
        "comisionFreelancePercentage", "comisionFreelanceValue",
        "comisionPropiaPercentage", "comisionPropiaValue", "comisionUtilidadPercentage",
        "destination", "startDate", "endDate", "passenger", "paxAdults", "paxChildren",
        "reservationCode", "copyFieldsToProducts", "manualDescription"
    ) VALUES (
        v_internal_number, CURRENT_TIMESTAMP, v_orig_quotation."clientId", v_orig_quotation."currency", v_orig_quotation."exchangeRate",
        v_orig_quotation."branchId", v_orig_quotation."implantId", v_orig_quotation."sellerId", v_orig_quotation."ticketPrinterId",
        v_orig_quotation."baseCommissionable", v_orig_quotation."commissionPercentage", v_orig_quotation."chargesAndTaxes",
        v_orig_quotation."totalAmount", v_user_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP,
        v_orig_quotation."costoTotal", v_orig_quotation."valorBase", v_orig_quotation."utilidad", v_orig_quotation."comisionTotalPercentage",
        v_orig_quotation."comisionFreelancePercentage", v_orig_quotation."comisionFreelanceValue",
        v_orig_quotation."comisionPropiaPercentage", v_orig_quotation."comisionPropiaValue", v_orig_quotation."comisionUtilidadPercentage",
        v_orig_quotation."destination", v_orig_quotation."startDate", v_orig_quotation."endDate", v_orig_quotation."passenger", v_orig_quotation."paxAdults", v_orig_quotation."paxChildren",
        v_orig_quotation."reservationCode", v_orig_quotation."copyFieldsToProducts", v_orig_quotation."manualDescription"
    ) RETURNING id INTO v_new_id;

    -- Insertar registro inicial en el historial de estados
    INSERT INTO public."QuotationStateHistory" ("quotationId", "state", "description", "createdAt", "userId")
    VALUES (v_new_id, 'NUEVO', 'Copia de cotización #' || p_quotation_id::text, CURRENT_TIMESTAMP, v_user_id);

    -- Duplicar combos asociados
    INSERT INTO public."QuotationCombo" ("quotationId", "comboId")
    SELECT v_new_id, "comboId"
    FROM public."QuotationCombo"
    WHERE "quotationId" = p_quotation_id;

    -- Duplicar servicios manuales si la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'QuotationManualService') THEN
        INSERT INTO public."QuotationManualService" ("quotationId", "providerName", "serviceName", "cost", "salePrice", "utility")
        SELECT v_new_id, "providerName", "serviceName", "cost", "salePrice", "utility"
        FROM public."QuotationManualService"
        WHERE "quotationId" = p_quotation_id;
    END IF;

    -- Duplicar productos y sus detalles
    FOR v_orig_qp IN 
        SELECT * FROM public."QuotationProduct" WHERE "quotationId" = p_quotation_id
    LOOP
        INSERT INTO public."QuotationProduct" (
            "quotationId", "productId", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission",
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "service", "servicios", "descripcion", "passenger"
        ) VALUES (
            v_new_id, v_orig_qp."productId", v_orig_qp."quantity", v_orig_qp."price", v_orig_qp."cost", v_orig_qp."providerId", v_orig_qp."prestadoraId",
            v_orig_qp."checkInDate", v_orig_qp."checkOutDate", v_orig_qp."nights", v_orig_qp."paxAdults", v_orig_qp."paxChildren",
            v_orig_qp."serviceType", v_orig_qp."destination", v_orig_qp."reservationCode", v_orig_qp."sellerCommission",
            v_orig_qp."ticketPrinterCommission", v_orig_qp."comboId", v_orig_qp."mainTaxId", v_orig_qp."inNationality",
            v_orig_qp."service", v_orig_qp."servicios", v_orig_qp."descripcion", v_orig_qp."passenger"
        ) RETURNING id INTO v_new_qp_id;

        -- Duplicar Pasajeros del producto
        INSERT INTO public."QuotationProductPassenger" ("quotationProductId", "name", "document")
        SELECT v_new_qp_id, "name", "document"
        FROM public."QuotationProductPassenger"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Impuestos del producto
        INSERT INTO public."QuotationProductTax" ("quotationProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain")
        SELECT v_new_qp_id, "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
        FROM public."QuotationProductTax"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Variables del producto
        INSERT INTO public."QuotationProductVariable" ("quotationProductId", "masterVariableId", "value")
        SELECT v_new_qp_id, "masterVariableId", "value"
        FROM public."QuotationProductVariable"
        WHERE "quotationProductId" = v_orig_qp.id;

        -- Duplicar Pagos del producto
        INSERT INTO public."QuotationProductPayment" ("quotationProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
        SELECT v_new_qp_id, "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate"
        FROM public."QuotationProductPayment"
        WHERE "quotationProductId" = v_orig_qp.id;

    END LOOP;

    p_new_quotation_id := v_new_id;
    p_mensaje_resultado := 'SUCCESS: Cotización duplicada correctamente con ID ' || v_new_id;

    -- Registrar en auditoría
    CALL public."spLogRegistrar"(
        v_user_id, 
        'QUOTATION', 
        'DUPLICATE', 
        'Se duplicó la cotización #' || p_quotation_id || ' generando la cotización #' || v_new_id || ' (' || v_internal_number || ')', 
        jsonb_build_object('sourceQuotationId', p_quotation_id, 'newQuotationId', v_new_id), 
        v_new_id
    );

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spcotizacioneliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spcotizacioneliminar(IN p_quotation_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists BOOLEAN;
    v_internal_number TEXT;
BEGIN
    SELECT "internalNumber" INTO v_internal_number FROM public."Quotation" WHERE id = p_quotation_id;
    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: Cotización no encontrada con ID ' || p_quotation_id;
        RETURN;
    END IF;

    DELETE FROM public."Quotation" WHERE id = p_quotation_id;
    p_mensaje_resultado := 'SUCCESS: Cotización ' || v_internal_number || ' eliminada con éxito.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spexportinvoices(text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spexportinvoices(IN envoices_id text, IN user_id integer, INOUT mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
/*
    AUTOR: Rubiel Gelis Guzman / Antigravity
    DESCRIPCIÓN: Generación de XML para exportación de Facturas (Invoices). Restructurado según especificaciones del usuario.
*/
DECLARE
    v_xml TEXT;
    v_nombre_usuario TEXT;
	v_state   TEXT;
    v_msg     TEXT;
    v_context TEXT;
    v_line    TEXT;
BEGIN
    -- 1. Inicializar
    mensaje_resultado := '';

    Envoices_id := TRIM(BOTH ',' FROM TRIM(COALESCE(Envoices_id, '')));
    IF Envoices_id = '' THEN
        mensaje_resultado := 'ERROR: No se han proporcionado IDs de Facturacion válidos.';
        RETURN;
    END IF;

    -- 2. Validación de usuario
    SELECT "name" INTO v_nombre_usuario FROM public."User" WHERE id = User_id;
    IF NOT FOUND THEN
        mensaje_resultado := 'ERROR: El usuario ' || User_id || ' no existe.';
        RETURN;
    END IF;

    -- 3. Crear Tablas Temporales
    CREATE TEMP TABLE IF NOT EXISTS Facturacion (
		id INTEGER GENERATED ALWAYS AS IDENTITY,
		id_factura INTEGER,
		cd_fuente VARCHAR(2),
		cd_serie VARCHAR(2),
		cd_consecutivo VARCHAR(8),
		cd_usuario INTEGER,  
		cd_sucursal VARCHAR(25), 
		cd_implante VARCHAR(25), 
		dt_fechacont TIMESTAMP,
		dt_vence TIMESTAMP,
		cd_tercero_codigo VARCHAR(25),
		ds_tercero_nombre VARCHAR(250),
		cd_cliente_codigo VARCHAR(25), 
		ds_cliente_nombre VARCHAR(250),
		ds_cliente_dir VARCHAR(250),
		ds_cliente_ciudad VARCHAR(40),
		ds_cliente_tel VARCHAR(50),
		ds_cliente_dirdesp VARCHAR(250),
		ds_cliente_email VARCHAR(60),
		ds_cliente_contacto VARCHAR(40),
		ds_cliente_contacto_email VARCHAR(60),
		cd_monedas_iata VARCHAR(25),
		cd_vendedor VARCHAR(3),
		cd_tiqueteador VARCHAR(25),
		bn_anexo BYTEA,
		Tcambio DECIMAL,
		am_tcambiousd DECIMAL,
		id_tipoventa INTEGER,
		ds_num_resolucion VARCHAR(20), 
		in_num_inicial NUMERIC(18,0), 
		in_num_final NUMERIC(18,0), 
		ds_numeracion_autorizada VARCHAR(50),
		dt_fecha_resolucion TIMESTAMP,	
		CodigoArchivoFisico VARCHAR(25),
		ds_Observacion VARCHAR(8000),
		ds_Campo_libre1 varchar(500),
		ds_Campo_libre2 varchar(500),
		cd_fuente_Reemplaza VARCHAR(2),
		cd_serie_Reemplaza VARCHAR(2),
		cd_consecutivo_Reemplaza VARCHAR(8),		
		ds_Actividad_Economica VARCHAR(10),
		ds_Tarifa_ICA VARCHAR(15),	
		SqlStmt TEXT,
		AnticiposSqlStmt TEXT,
		TotalFactura DECIMAL,
		TotalCupoCreditoCliente DECIMAL,
		bl_BloqueoCupoCredito BIT(1),
		bl_generadaauto BIT(1),
		ds_CotizacionesId Varchar(500),
		Id_Cierre INTEGER,
		cd_TipoFact VARCHAR(2),
		id_fac_remisionRelacionada INTEGER,
		id_fac_facturaRelacionada INTEGER,
		ds_DescripcionFac VARCHAR(500),
		bl_nocont BIT(1),
		ProductosSqlStmt TEXT,
		cd_CF_TipoComprobante VARCHAR(15),
		id_Licitacion INTEGER,
		ValorFactura DECIMAL,
		id_Especialista INTEGER,
		cd_tiqueteador_Facturador VARCHAR(25),
		id_TipoFormaPagoProveedor INTEGER,
		id_MedioReservacion INTEGER,
		bl_refacturacion BIT(1),
		bl_comisiona BIT(1),
		cd_fuente_factura VARCHAR(2),
		cd_serie_factura VARCHAR(2),
		cd_consecutivo_factura VARCHAR(8),
		id_NotasAerolinea INTEGER,
		bl_interface INTEGER,
		id_evento INTEGER,
		bl_NoEnviarFacElectronica BIT(1),
		bl_FacturaComision BIT(1),
		bl_DescontarComisionCxP BIT(1),
		ds_num_resolucion_Adicional VARCHAR(20),
		id_fac_facturaRefacturacion VARCHAR(8000),
		bl_refacturacion_contabilizar_saldos BIT(1),
		ZML_VariablesXML TEXT,
		bl_FormatoResumidoFactElectro BIT(1),
		bl_ExigeAdjuntoFactElectro BIT(1),
		bl_omitir_Validar_IVA_facturacion BIT(1),
		ds_Respuesta TEXT
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS Item (
		id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		tipo_item VARCHAR(10),
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		id_referencia_origen INTEGER,             
		cd_tiquete VARCHAR(50),
		ds_descrip VARCHAR(500),
		in_nacionalidad INTEGER,
		cd_cencosto VARCHAR(50),
		cd_auxiliar VARCHAR(50),
		cd_item VARCHAR(50),
		am_tarifa DECIMAL,
		am_iva DECIMAL,
		am_tua DECIMAL,
		am_comb DECIMAL,
		am_vat DECIMAL,
		am_Comision DECIMAL,
		ds_paxname VARCHAR(30),
		ds_paxape VARCHAR(30),
		ds_paxprefix VARCHAR(3),
		cd_tourcode VARCHAR(25),
		NumTktConj INTEGER,
		cd_TipoTiquete VARCHAR(3),
		id_air INTEGER,
		ds_itinerario VARCHAR(250),
		ds_itinerarioaerolinea VARCHAR(128),
		ds_clases VARCHAR(61),
		ds_Observaciones VARCHAR(8000),
		am_highfare DECIMAL,
		am_lowfare DECIMAL,
		ds_solicita VARCHAR(200),
		ds_lapsoviaje VARCHAR(50),
		cd_tktrevisado VARCHAR(14),
		cd_PasaportePax VARCHAR(25),
		cd_pax_CC VARCHAR(20),
		am_PorFacParcial DECIMAL,
		in_cantpax INTEGER,
		Id_Precompra INTEGER,
		cd_FormaPagoTAO VARCHAR(3),
		cd_TarjetaCreditoTAO VARCHAR(4),
		cd_NumeroTarjetaTAO VARCHAR(25),
		cd_VencimientoTarjetaTAO VARCHAR(6),
		cd_NumeroPolizaTAO VARCHAR(50),
		cd_AnexoPolizaTAO VARCHAR(50),
		ds_AutorizacionTarjetaTAO VARCHAR(25),
		in_cuotasTarjetaTAO INTEGER,
		cd_FormasPago VARCHAR(25),
		cd_TarjetasCredito VARCHAR(25),
		am_fp1 DECIMAL,
		ds_cc_code VARCHAR(2),
		ds_cc_number VARCHAR(25),
		ds_cc_vence VARCHAR(25),
		ds_cc_autorizacion VARCHAR(25),
		ds_cc_voucher VARCHAR(25),
		in_cc_cuotas INTEGER,
		am_fp2 DECIMAL,
		ds_cc_code2 VARCHAR(2),
		ds_cc_number2 VARCHAR(25),
		ds_cc_vence2 VARCHAR(25),
		ds_cc_autorizacion2 VARCHAR(25),
		ds_cc_voucher2 VARCHAR(25),
		in_cc_cuotas2 INTEGER,
		cd_monedas_iata VARCHAR(25),
		Tcambio DECIMAL,
		cd_sucursal VARCHAR(25),
		cd_implante VARCHAR(25),
		bl_ahorro BIT(1),
		cd_TipoTiqueteGDS VARCHAR(3),
		cd_TiposDocumento VARCHAR(25),
		cd_entdist VARCHAR(25),
		cd_entvend VARCHAR(25),
		cd_destino VARCHAR(3),
		dt_fechaexped TIMESTAMP,
		cd_tiqueteadores VARCHAR(25),
		id_gds INTEGER,
		iden_gds INTEGER,
		am_comisionPNR DECIMAL,
		ds_records VARCHAR(62),
		bl_NoCalcComision BIT(1),
		bl_NoCalcIvaComision BIT(1),
		am_basecomisionable DECIMAL,
		am_porcomision DECIMAL,
		cd_tiposconceptfac VARCHAR(25),
		cd_conceptofacturacion VARCHAR(25),
		cd_tiposservicio VARCHAR(25),
		cd_proveedores VARCHAR(25),
		ds_servicio VARCHAR(250),
		am_valorprov DECIMAL,
		cd_monedaprov VARCHAR(25),
		dt_llegada TIMESTAMP,
		dt_salida TIMESTAMP,
		am_pordescuento NUMERIC(8,4),
		am_basedescuento DECIMAL,
		Fecha_Salida TIMESTAMP,
		Fecha_Llegada TIMESTAMP,
		ColId VARCHAR(25),
		cd_Consecutivo_depende VARCHAR(50),
		CodigoReserva VARCHAR(50),
		cd_Consecutivo_variablesadicionales VARCHAR(50),
		am_valor_total DECIMAL,
		ds_proveedores VARCHAR(250),
		id_FormasPagoAirPlus INTEGER,
		cd_FormasPagoAirPlus VARCHAR(3),
		ds_FormasPagoAirPlus VARCHAR(100),
		id_TarjetasCreditoAirPlus INTEGER,
		cd_TarjetasCreditoAirPlus VARCHAR(4),
		ds_numerotarjetaAirPlus VARCHAR(25),
		id_reserva INTEGER,
		OrdenGrabacion INTEGER
    ) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS itinerarios(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		in_orden INTEGER,
		ds_origen VARCHAR(25),
		ds_destino VARCHAR(25),
		ds_clase VARCHAR(25),
		dt_llegada TIMESTAMP,
		dt_salida TIMESTAMP,
		ds_terminal VARCHAR(25),
		cd_aerolinea VARCHAR(25),
		cd_farebasis VARCHAR(25),
		ds_numerovuelo VARCHAR(25),
		ds_tipovuelo VARCHAR(25),
		am_valor DECIMAL,
		am_co2 DECIMAL
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Pasajeros(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		ds_paxape VARCHAR(30),
		ds_paxname VARCHAR(30),
		ds_paxprefix VARCHAR(3),
		ds_paxClasificacion VARCHAR(25),
		cd_voucherpax VARCHAR(25),
		cd_paxidentificacion VARCHAR(25),
		in_edad INT,
		cd_tiquete VARCHAR(50)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CargosImpuestos(
		id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		cd_codigo VARCHAR(20),
		ds_nombre VARCHAR(100),
		cd_tipo VARCHAR(1),
		am_porcentaje NUMERIC(8,4),
		am_valor DECIMAL,
		am_contado DECIMAL,
		am_credito DECIMAL,
		id_carg INTEGER,
		id_imp INTEGER,
		bl_iva BIT(1),
		in_orden INTEGER
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Formaspago(
		id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		id_formaspago INTEGER,
		cd_codigo VARCHAR(10),
		ds_nombre VARCHAR(50),
		id_tarjetascredito INTEGER,
		cd_tipotarjeta VARCHAR(10),
		ds_numerotarjeta VARCHAR(50),
		ds_vouchertarjeta VARCHAR(50),
		ds_expiraciontarjeta VARCHAR(10),
		ds_autorizaciontarjeta VARCHAR(50),
		in_cuotas INTEGER,
		cd_banco VARCHAR(50),
		ds_cheque VARCHAR(50),
		ds_plaza VARCHAR(50),
		ds_referencia VARCHAR(50),
		ds_Poliza VARCHAR(50),
		ds_PolizaAnexo VARCHAR(50),
		am_valor DECIMAL
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Variables(
		id INT GENERATED ALWAYS AS IDENTITY,
		id_factura INTEGER,
		id_item INTEGER,
		in_tipoitem INTEGER,
		ds_maestro VARCHAR(25), 
		ds_VariableAdicional VARCHAR(25),
		ds_valor VARCHAR(500),
		cd_codigo CHAR(25)
	) ON COMMIT DROP;

    -- 4. Poblar Tabla Facturacion
    INSERT INTO Facturacion (
		id_factura, cd_fuente, cd_serie, cd_consecutivo, cd_usuario, cd_sucursal, cd_implante, 
		dt_fechacont, dt_vence, cd_tercero_codigo, ds_tercero_nombre, cd_cliente_codigo, 
		ds_cliente_nombre, ds_cliente_dir, ds_cliente_ciudad, ds_cliente_tel, ds_cliente_dirdesp, 
		ds_cliente_email, ds_cliente_contacto, ds_cliente_contacto_email, cd_monedas_iata, 
		cd_vendedor, cd_tiqueteador, bn_anexo, Tcambio, am_tcambiousd, id_tipoventa, 
		ds_num_resolucion, in_num_inicial, in_num_final, ds_numeracion_autorizada, 
		dt_fecha_resolucion, CodigoArchivoFisico, ds_Observacion, ds_Campo_libre1, 
		ds_Campo_libre2, cd_fuente_Reemplaza, cd_serie_Reemplaza, cd_consecutivo_Reemplaza, 
		ds_Actividad_Economica, ds_Tarifa_ICA, SqlStmt, AnticiposSqlStmt, TotalFactura, 
		TotalCupoCreditoCliente, bl_BloqueoCupoCredito, bl_generadaauto, ds_CotizacionesId, 
		Id_Cierre, cd_TipoFact, id_fac_remisionRelacionada, id_fac_facturaRelacionada, 
		ds_DescripcionFac, bl_nocont, ProductosSqlStmt, cd_CF_TipoComprobante, id_Licitacion, 
		ValorFactura, id_Especialista, cd_tiqueteador_Facturador, id_TipoFormaPagoProveedor, 
		id_MedioReservacion, bl_refacturacion, bl_comisiona, cd_fuente_factura, cd_serie_factura, 
		cd_consecutivo_factura, id_NotasAerolinea, bl_interface, id_evento, bl_NoEnviarFacElectronica, 
		bl_FacturaComision, bl_DescontarComisionCxP, ds_num_resolucion_Adicional, 
		id_fac_facturaRefacturacion, bl_refacturacion_contabilizar_saldos, ZML_VariablesXML, 
		bl_FormatoResumidoFactElectro, bl_ExigeAdjuntoFactElectro, bl_omitir_Validar_IVA_facturacion, 
		ds_Respuesta
    )
    SELECT
		e.id AS id_factura,
        SUBSTRING(COALESCE(e.fuente, '55'), 1, 2) AS cd_fuente,
        SUBSTRING(COALESCE(e.serie, '00'), 1, 2) AS cd_serie,
        SUBSTRING(COALESCE(e.consecutivo, 'I' || LPAD(e.id::text, 7, '0')), 1, 8) AS cd_consecutivo,
        User_id AS cd_usuario,
        SUBSTRING(COALESCE(b.code, 'OFP'), 1, 3) AS cd_sucursal,
        SUBSTRING(COALESCE(i.code, ''), 1, 3) AS cd_implante,
        e.date AS dt_fechacont,
        e.date AS dt_vence,
        SUBSTRING(COALESCE(c.document, ''), 1, 25) AS cd_tercero_codigo,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.name, '')), 1, 250) AS ds_tercero_nombre,
        SUBSTRING(COALESCE(c.document, ''), 1, 25) AS cd_cliente_codigo,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.name, '')), 1, 250) AS ds_cliente_nombre,
        SUBSTRING(public."fnQuitarEspeciales"(COALESCE(c.address, '')), 1, 250) AS ds_cliente_dir,
        '' AS ds_cliente_ciudad,
        '' AS ds_cliente_tel,
        '' AS ds_cliente_dirdesp,
        SUBSTRING(COALESCE(u.email, ''), 1, 60) AS ds_cliente_email,
        '' AS ds_cliente_contacto,
        '' AS ds_cliente_contacto_email,
        COALESCE(e."currency", 'COP') AS cd_monedas_iata,
        SUBSTRING(COALESCE(s.code, ''), 1, 3)::char(3) AS cd_vendedor,
        SUBSTRING(COALESCE(tp.code, ''), 1, 25) AS cd_tiqueteador,
        NULL::bytea AS bn_anexo,
        COALESCE(e."exchangeRate", 1.0) AS Tcambio,
        1.0 AS am_tcambiousd,
        NULL AS id_tipoventa,
        '' AS ds_num_resolucion,
        0 AS in_num_inicial,
        0 AS in_num_final,
        '' AS ds_numeracion_autorizada,
        NULL AS dt_fecha_resolucion,
        '' AS CodigoArchivoFisico,
        '' AS ds_Observacion,
        '' AS ds_Campo_libre1,
        '' AS ds_Campo_libre2,
        '' AS cd_fuente_Reemplaza,
        '' AS cd_serie_Reemplaza,
        '' AS cd_consecutivo_Reemplaza,
        '' AS ds_Actividad_Economica,
        '' AS ds_Tarifa_ICA,
        '' AS SqlStmt,
        NULL AS AnticiposSqlStmt,
        COALESCE(e."totalAmount", 0) AS TotalFactura,
        0 AS TotalCupoCreditoCliente,
        B'0' AS bl_BloqueoCupoCredito,
        B'0' AS bl_generadaauto,
        NULL AS ds_CotizacionesId,
        NULL AS Id_Cierre,
        NULL AS cd_TipoFact,
        NULL AS id_fac_remisionRelacionada,
        NULL AS id_fac_facturaRelacionada,
        NULL AS ds_DescripcionFac,
        B'0' AS bl_nocont,
        NULL AS ProductosSqlStmt,
        NULL AS cd_CF_TipoComprobante,
        NULL AS id_Licitacion,
        COALESCE(e."totalAmount", 0) AS ValorFactura,
        NULL AS id_Especialista,
        NULL AS cd_tiqueteador_Facturador,
        NULL AS id_TipoFormaPagoProveedor,
        NULL AS id_MedioReservacion,
        B'0' AS bl_refacturacion,
        B'0' AS bl_comisiona,
        NULL AS cd_fuente_factura,
        NULL AS cd_serie_factura,
        NULL AS cd_consecutivo_factura,
        NULL AS id_NotasAerolinea,
        0 AS bl_interface,
        NULL AS id_evento,
        B'0' AS bl_NoEnviarFacElectronica,
        B'0' AS bl_FacturaComision,
        B'0' AS bl_DescontarComisionCxP,
        '' AS ds_num_resolucion_Adicional,
        NULL AS id_fac_facturaRefacturacion,
        B'0' AS bl_refacturacion_contabilizar_saldos,
        NULL AS ZML_VariablesXML,
        B'0' AS bl_FormatoResumidoFactElectro,
        B'0' AS bl_ExigeAdjuntoFactElectro,
        B'0' AS bl_omitir_Validar_IVA_facturacion,
        NULL AS ds_Respuesta
    FROM public."Invoices" e
    JOIN public."Client" c ON e."clientId" = c.id
    JOIN public."Branch" b ON e."branchId" = b.id
    LEFT JOIN public."Implant" i ON e."implantId" = i.id
    LEFT JOIN public."Seller" s ON e."sellerId" = s.id
    LEFT JOIN public."User" u ON e."userId" = u.id
    LEFT JOIN public."TicketPrinter" tp ON e."ticketPrinterId" = tp.id
    WHERE e.id = ANY(string_to_array(Envoices_id, ',')::int[]);

    -- 5. Poblar Tabla Item
    INSERT INTO Item (
		id_factura, id_item, tipo_item, in_tipoitem, id_referencia_origen, cd_tiquete, 
		ds_descrip, in_nacionalidad, cd_cencosto, cd_auxiliar, cd_item, 
		am_tarifa, am_iva, am_tua, am_comb, am_vat, am_Comision, 
		ds_paxname, ds_paxape, ds_paxprefix, cd_tourcode, NumTktConj, 
		cd_TipoTiquete, id_air, ds_itinerario, ds_itinerarioaerolinea, 
		ds_clases, ds_Observaciones, am_highfare, am_lowfare, ds_solicita, 
		ds_lapsoviaje, cd_tktrevisado, cd_PasaportePax, cd_pax_CC, 
		am_PorFacParcial, in_cantpax, Id_Precompra, cd_FormaPagoTAO, 
		cd_TarjetaCreditoTAO, cd_NumeroTarjetaTAO, cd_VencimientoTarjetaTAO, 
		cd_NumeroPolizaTAO, cd_AnexoPolizaTAO, ds_AutorizacionTarjetaTAO, 
		in_cuotasTarjetaTAO, cd_FormasPago, cd_TarjetasCredito, am_fp1, 
		ds_cc_code, ds_cc_number, ds_cc_vence, ds_cc_autorizacion, 
		ds_cc_voucher, in_cc_cuotas, am_fp2, ds_cc_code2, ds_cc_number2, 
		ds_cc_vence2, ds_cc_autorizacion2, ds_cc_voucher2, in_cc_cuotas2, 
		cd_monedas_iata, Tcambio, cd_sucursal, cd_implante, bl_ahorro, 
		cd_TipoTiqueteGDS, cd_TiposDocumento, cd_entdist, cd_entvend, 
		cd_destino, dt_fechaexped, cd_tiqueteadores, id_gds, iden_gds, 
		am_comisionPNR, ds_records, bl_NoCalcComision, bl_NoCalcIvaComision, 
		am_basecomisionable, am_porcomision, cd_tiposconceptfac, 
		cd_conceptofacturacion, cd_tiposservicio, cd_proveedores, 
		ds_servicio, am_valorprov, cd_monedaprov, dt_llegada, dt_salida, 
		am_pordescuento, am_basedescuento, Fecha_Salida, Fecha_Llegada, 
		ColId, cd_Consecutivo_depende, CodigoReserva, 
		cd_Consecutivo_variablesadicionales, am_valor_total, ds_proveedores, 
		id_FormasPagoAirPlus, cd_FormasPagoAirPlus, ds_FormasPagoAirPlus, 
		id_TarjetasCreditoAirPlus, cd_TarjetasCreditoAirPlus, 
		ds_numerotarjetaAirPlus, id_reserva, OrdenGrabacion
    )
    SELECT
		e.id AS id_factura,
		ep.id AS id_item,
		CASE WHEN pr.type='Tiquete' THEN 'Aire' 
			 WHEN pr.type='ALOJAMIENTO' THEN 'Hotel' 
			 WHEN pr.type='ALQUILER' THEN 'Auto'
			 WHEN pr.type='TAO' THEN 'TAO'
			 ELSE 'SRV'
		END AS tipo_item,
		CASE WHEN pr.type='Tiquete' THEN 1 
			 WHEN pr.type='ALOJAMIENTO' THEN 3
			 WHEN pr.type='ALQUILER' THEN 3
			 WHEN pr.type='TAO' THEN 2
			 ELSE 3
		END AS in_tipoitem,
        ep.id AS id_referencia_origen,
        CASE WHEN pr.type='Tiquete' THEN pr.code ELSE '' END AS cd_tiquete,
        SUBSTRING(COALESCE(ep.descripcion, ''), 1, 500) AS ds_descrip,
        COALESCE(ep."inNationality", 1) AS in_nacionalidad,
        '' AS cd_cencosto,
        '' AS cd_auxiliar,
        '' AS cd_item,
        COALESCE((
            SELECT SUM(ipt."explicitAmount")
            FROM public."InvoicesProductTax" ipt
            LEFT JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId"
            LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct."targetTaxId"
            WHERE ipt."invoiceProductId" = ep.id
              AND (
                  ipt."isMain" = true OR
                  (ipt."isMain" = false AND ct."targetTaxId" IS NOT NULL AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = ep."mainTaxId"
                  ))
              )
        ), 0) AS am_tarifa,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'IVA'), 0) AS am_iva,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'TUA'), 0) AS am_tua,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ct.code = 'CMB'), 0) AS am_comb,
        COALESCE((SELECT SUM(ipt."explicitAmount") FROM public."InvoicesProductTax" ipt JOIN public."ChargeAndTax" ct ON ct.id = ipt."chargeAndTaxId" WHERE ipt."invoiceProductId" = ep.id AND ipt."isMain" = false AND ct.code NOT IN('CMB','TUA','IVA')), 0) AS am_vat,
        COALESCE(ep."sellerCommission", 0) AS am_Comision,
		CASE WHEN epp.name IS NULL OR TRIM(epp.name) = '' THEN '' WHEN TRIM(epp.name) NOT LIKE '% %' THEN TRIM(epp.name) ELSE COALESCE(arr[1], '') END AS ds_paxname,
		CASE WHEN epp.name IS NULL OR TRIM(epp.name) = '' THEN '' WHEN TRIM(epp.name) NOT LIKE '% %' THEN '' ELSE COALESCE(arr[2], '') END AS ds_paxape,
		CASE WHEN TRIM(epp.name) LIKE '% %' THEN SUBSTRING(COALESCE(arr[3], ''), 1, 3)::char(3) ELSE ''::char(3) END AS ds_paxprefix,
        '' AS cd_tourcode,
        0 AS NumTktConj,
        COALESCE(tt.code,'') AS cd_TipoTiquete,
        CASE WHEN pr.type='Tiquete' THEN ep.id ELSE NULL END AS id_air,
        SUBSTRING(COALESCE(ep.itinerary, ''), 1, 250) AS ds_itinerario,
        SUBSTRING(COALESCE(ep.airline, ''), 1, 128) AS ds_itinerarioaerolinea,
        SUBSTRING(COALESCE(ep.class, ''), 1, 61) AS ds_clases,
        '' AS ds_Observaciones,
        0 AS am_highfare,
        0 AS am_lowfare,
        '' AS ds_solicita,
        '' AS ds_lapsoviaje,
        '' AS cd_tktrevisado,
        '' AS cd_PasaportePax,
        '' AS cd_pax_CC,
        0 AS am_PorFacParcial,
        COALESCE(cardinality(arr), 1) AS in_cantpax,
        NULL AS Id_Precompra,
        '' AS cd_FormaPagoTAO,
        '' AS cd_TarjetaCreditoTAO,
        '' AS cd_NumeroTarjetaTAO,
        '' AS cd_VencimientoTarjetaTAO,
        '' AS cd_NumeroPolizaTAO,
        '' AS cd_AnexoPolizaTAO,
        '' AS ds_AutorizacionTarjetaTAO,
        0 AS in_cuotasTarjetaTAO,
        COALESCE((SELECT pp.code FROM public."InvoicesProductPayment" ipp JOIN public."Payment" pp ON LOWER(pp."name") = LOWER(ipp."paymentMethod") WHERE ipp."invoiceProductId" = ep.id LIMIT 1), '') AS cd_FormasPago,
        COALESCE((SELECT cc.code FROM public."InvoicesProductPayment" ipp JOIN public."CreditCard" cc ON cc.id = ipp."creditCardId" WHERE ipp."invoiceProductId" = ep.id AND UPPER(ipp."paymentMethod") = 'TARJETA' LIMIT 1), '') AS cd_TarjetasCredito,
        (ep.price * ep.quantity) AS am_fp1,
		COALESCE((SELECT cc.code FROM public."InvoicesProductPayment" ipp JOIN public."CreditCard" cc ON cc.id = ipp."creditCardId" WHERE ipp."invoiceProductId" = ep.id AND UPPER(ipp."paymentMethod") = 'TARJETA' LIMIT 1), '') AS ds_cc_code,
		COALESCE((SELECT ipp."cardNumber" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND UPPER(ipp."paymentMethod") = 'TARJETA' LIMIT 1), '') AS ds_cc_number,
		COALESCE((SELECT ipp."expirationDate" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND ipp."paymentMethod" = 'TARJETA' LIMIT 1), '') AS ds_cc_vence,
		COALESCE((SELECT ipp."authorizationCode" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND UPPER(ipp."paymentMethod") = 'TARJETA' LIMIT 1), '') AS ds_cc_autorizacion,
		COALESCE((SELECT ipp."voucher" FROM public."InvoicesProductPayment" ipp WHERE ipp."invoiceProductId" = ep.id AND UPPER(ipp."paymentMethod") = 'TARJETA' LIMIT 1), '') AS ds_cc_voucher,
        0 AS in_cc_cuotas,
        0 AS am_fp2,
        '' AS ds_cc_code2,
        '' AS ds_cc_number2,
        '' AS ds_cc_vence2,
        '' AS ds_cc_autorizacion2,
        '' AS ds_cc_voucher2,
        0 AS in_cc_cuotas2,
        COALESCE(e."currency", 'COP') AS cd_monedas_iata,
        COALESCE(e."exchangeRate", 1.0) AS Tcambio,
        b."code" AS cd_sucursal,
        i."code" AS cd_implante,
        B'0' AS bl_ahorro,
        '' AS cd_TipoTiqueteGDS,
        COALESCE(tt.code,'') AS cd_TiposDocumento,
        CASE WHEN COALESCE(pre."nogds",'')<>'' THEN COALESCE(pre.code,'') ELSE 'BSP' END AS cd_entdist,
        COALESCE(pre.code,'') AS cd_entvend,
        SUBSTRING(COALESCE(ep.destination, ''), 1, 3) AS cd_destino,
        COALESCE(ep."checkInDate", e.date) AS dt_fechaexped,
        COALESCE(tp.code, '') AS cd_tiqueteadores,
        NULL AS id_gds,
        1 AS iden_gds,
        0 AS am_comisionPNR,
        COALESCE(ep."reservationCode", '') AS ds_records,
        B'0' AS bl_NoCalcComision,
        B'0' AS bl_NoCalcIvaComision,
        0 AS am_basecomisionable,
        0 AS am_porcomision,
        '' AS cd_tiposconceptfac,
        COALESCE(pr."billingConcept", '') AS cd_conceptofacturacion,
        COALESCE(pr."serviceType", '') AS cd_tiposservicio,
        SUBSTRING(COALESCE(prov.code, prov.name, ''), 1, 25) AS cd_proveedores,
        SUBSTRING(COALESCE(ep."servicios", ''), 1, 250) AS ds_servicio,
        (
            COALESCE(ep.price, 0) +
            COALESCE((
                SELECT SUM(ipt2."explicitAmount")
                FROM public."InvoicesProductTax" ipt2
                JOIN public."ChargeAndTax" ct2 ON ct2.id = ipt2."chargeAndTaxId"
                LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE ipt2."invoiceProductId" = ep.id
                  AND ipt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = ep."mainTaxId"
                  )
            ), 0)
        ) AS am_valorprov,
        '' AS cd_monedaprov,
        COALESCE(ep."checkInDate", e.date) AS dt_llegada,
        COALESCE(ep."checkOutDate", e.date) AS dt_salida,
        0 AS am_pordescuento,
        0 AS am_basedescuento,
        COALESCE(ep."checkInDate", e.date) AS Fecha_Salida,
        COALESCE(ep."checkOutDate", e.date) AS Fecha_Llegada,
        '' AS ColId,
        '' AS cd_Consecutivo_depende,
        SUBSTRING(COALESCE(ep."reservationCode", ''), 1, 50) AS CodigoReserva,
        'I' || LPAD(ep.id::text, 7, '0') AS cd_Consecutivo_variablesadicionales,
        COALESCE(e."totalAmount", 0) AS am_valor_total,
        SUBSTRING(COALESCE(prov.code, ''), 1, 250) AS ds_proveedores,
        NULL AS id_FormasPagoAirPlus,
        '' AS cd_FormasPagoAirPlus,
        '' AS ds_FormasPagoAirPlus,
        NULL AS id_TarjetasCreditoAirPlus,
        '' AS cd_TarjetasCreditoAirPlus,
        '' AS ds_numerotarjetaAirPlus,
        NULL AS id_reserva,
        NULL AS OrdenGrabacion
    FROM public."InvoicesProduct" ep
	JOIN public."Invoices" e ON ep."invoiceId" = e.id
	JOIN public."Branch" b ON e."branchId" = b.id
    LEFT JOIN public."Implant" i ON e."implantId" = i.id
    JOIN public."Product" pr ON ep."productId" = pr.id
	LEFT JOIN public."TicketType" tt ON tt.id = ep."ticketTypeId"
    JOIN Facturacion f ON ep."invoiceId" = f.id_factura
    LEFT JOIN public."Provider" prov ON ep."providerId" = prov."id"
	LEFT JOIN public."Prestadora" pre ON pre."id" = ep."prestadoraId"
	LEFT JOIN public."TicketPrinter" tp ON tp."id" = e."ticketPrinterId"
	LEFT JOIN LATERAL ( SELECT  pp.*,
		        				regexp_split_to_array(TRIM(pp.name), E'\\s+') AS arr
		    			FROM public."InvoicesProductPasenger" pp 
						WHERE pp."invoiceProductId" = ep.id
    					ORDER BY pp.id
    					LIMIT 1) epp ON true;

    -- 6. Poblar Tabla itinerarios
    INSERT INTO itinerarios (
		id_factura,	id_item, in_tipoitem, in_orden, ds_origen, ds_destino, ds_clase, 
		dt_llegada,	dt_salida, ds_terminal, cd_aerolinea, cd_farebasis,	ds_numerovuelo,	
		ds_tipovuelo, am_valor, am_co2 
    )
    SELECT
		ep."invoiceId" AS id_factura,	
		ep."id" AS id_item, 
		itm.in_tipoitem AS in_tipoitem,
		COALESCE(epi."orden",0) AS in_orden,
		COALESCE(epi."origin",'') AS ds_origen, 
		COALESCE(epi."destination",'') AS ds_destino, 
		COALESCE(epi."class",'') AS ds_clase,
		COALESCE(epi."checkInDate", CURRENT_DATE) AS dt_llegada,
		COALESCE(epi."checkOutDate",CURRENT_DATE) AS dt_salida,
		COALESCE(epi."terminal",'') AS ds_terminal,
		COALESCE(epi."prestadoraCode",'') AS cd_aerolinea,
		COALESCE(epi."farebasis",'') AS cd_farebasis,
		COALESCE(epi."Numflight",'') AS ds_numerovuelo,
		COALESCE(epi."Typeflight",'') AS ds_tipovuelo,
		COALESCE(epi."amount",0) AS am_valor,
		COALESCE(epi."co2",0) AS am_co2
    FROM public."InvoicesProduct" ep
    JOIN public."InvoicesProductItinerary" epi ON epi."invoiceProductId" = ep.id
	JOIN Item itm ON ep.id = itm.id_item
    JOIN Facturacion f ON ep."invoiceId" = f.id_factura
    WHERE ep.itinerary IS NOT NULL AND ep.itinerary <> '';

    -- 7. Poblar Tabla Pasajeros
    INSERT INTO Pasajeros (
        id_factura, id_item, in_tipoitem, ds_paxape, ds_paxname, ds_paxprefix,
        ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion, in_edad, cd_tiquete
    )
    SELECT 
        f.id_factura AS id_factura,
        itm.id_item AS id_item,
        itm.in_tipoitem AS in_tipoitem,
	    CASE WHEN p.name IS NULL OR TRIM(p.name) = '' THEN '' WHEN TRIM(p.name) NOT LIKE '% %' THEN '' ELSE COALESCE(arr[2], '') END AS ds_paxape,
	    CASE WHEN p.name IS NULL OR TRIM(p.name) = '' THEN '' WHEN TRIM(p.name) NOT LIKE '% %' THEN TRIM(p.name) ELSE COALESCE(arr[1], '') END AS ds_paxname,
	    CASE WHEN TRIM(p.name) LIKE '% %' THEN SUBSTRING(COALESCE(arr[3], ''), 1, 3)::char(3) ELSE ''::char(3) END AS ds_paxprefix,
        '' AS ds_paxClasificacion,
        '' AS cd_voucherpax,
        COALESCE(p.document,'') AS cd_paxidentificacion, 
        0 AS in_edad, 
        '' AS cd_tiquete
	FROM (
	    SELECT 
	        p.*,
	        regexp_split_to_array(TRIM(p.name), E'\\s+') AS arr,
	        ROW_NUMBER() OVER (
	            PARTITION BY p."invoiceProductId"
	            ORDER BY p.id
	        ) AS rn
	    FROM public."InvoicesProductPasenger" p
	) p
    JOIN Item itm ON p."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_factura
    WHERE p.rn > 1;

    -- 8. Poblar Tabla CargosImpuestos
    INSERT INTO CargosImpuestos (
        id_factura, id_item, in_tipoitem, cd_codigo, ds_nombre, cd_tipo,
        am_porcentaje, am_valor, am_contado, am_credito, id_carg, id_imp, bl_iva, in_orden
    )
    SELECT 
        f.id_factura AS id_factura,
        itm.id_item AS id_item,
        itm.in_tipoitem AS in_tipoitem,
        COALESCE(ct.code, 'TAR') AS cd_codigo,
        COALESCE(ct.name, 'Tarifa') AS ds_nombre,
        CASE WHEN t."isMain" = true THEN 'C' ELSE 'I' END AS cd_tipo,
        COALESCE(ct.value, 0) AS am_porcentaje,
        (
            t."explicitAmount" +
            CASE WHEN (t."isMain" = true OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name ILIKE '%TARIFA%') THEN
                COALESCE((
                    SELECT SUM(sub_t."explicitAmount")
                    FROM public."InvoicesProductTax" sub_t
                    JOIN public."ChargeAndTax" sub_ct ON sub_t."chargeAndTaxId" = sub_ct.id
                    WHERE sub_t."invoiceProductId" = t."invoiceProductId"
                      AND sub_t."isMain" = false
                      AND sub_ct."targetTaxId" = ct.id
                ), 0)
            ELSE 0 END
        ) AS am_valor,
        CASE WHEN itm.cd_FormasPago='EFE' THEN (
            t."explicitAmount" +
            CASE WHEN (t."isMain" = true OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name ILIKE '%TARIFA%') THEN
                COALESCE((
                    SELECT SUM(sub_t."explicitAmount")
                    FROM public."InvoicesProductTax" sub_t
                    JOIN public."ChargeAndTax" sub_ct ON sub_t."chargeAndTaxId" = sub_ct.id
                    WHERE sub_t."invoiceProductId" = t."invoiceProductId"
                      AND sub_t."isMain" = false
                      AND sub_ct."targetTaxId" = ct.id
                ), 0)
            ELSE 0 END
        ) ELSE 0 END AS am_contado,
        CASE WHEN itm.cd_FormasPago='TC' THEN (
            t."explicitAmount" +
            CASE WHEN (t."isMain" = true OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name ILIKE '%TARIFA%') THEN
                COALESCE((
                    SELECT SUM(sub_t."explicitAmount")
                    FROM public."InvoicesProductTax" sub_t
                    JOIN public."ChargeAndTax" sub_ct ON sub_t."chargeAndTaxId" = sub_ct.id
                    WHERE sub_t."invoiceProductId" = t."invoiceProductId"
                      AND sub_t."isMain" = false
                      AND sub_ct."targetTaxId" = ct.id
                ), 0)
            ELSE 0 END
        ) ELSE 0 END AS am_credito,
        ct.id AS id_carg,
        ct.id AS id_imp,
        CASE WHEN ct.code = 'IVA' THEN B'1' ELSE B'0' END AS bl_iva,
        1 AS in_orden
    FROM public."InvoicesProductTax" t
    JOIN public."ChargeAndTax" ct ON t."chargeAndTaxId" = ct.id
    LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct."targetTaxId"
    JOIN Item itm ON t."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_factura
    WHERE NOT (
        t."isMain" = false AND ct."targetTaxId" IS NOT NULL AND (
            target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = (SELECT ep."mainTaxId" FROM public."InvoicesProduct" ep WHERE ep.id = t."invoiceProductId")
        )
    );

    -- 9. Poblar Tabla Formaspago
    INSERT INTO Formaspago (
        id_factura, id_item, in_tipoitem, id_formaspago, cd_codigo, ds_nombre,
        id_tarjetascredito, cd_tipotarjeta, ds_numerotarjeta, ds_vouchertarjeta,
        ds_expiraciontarjeta, ds_autorizaciontarjeta, in_cuotas, cd_banco,
        ds_cheque, ds_plaza, ds_referencia, ds_Poliza, ds_PolizaAnexo, am_valor
    )
    SELECT 
        f.id_factura AS id_factura,
        itm.id_item AS id_item,
        itm.in_tipoitem AS in_tipoitem,
        COALESCE(pp.id,ipp.id) AS id_formaspago,
        COALESCE(pp.code, '') AS cd_codigo,
        ipp."paymentMethod" AS ds_nombre,
        ipp."creditCardId" AS id_tarjetascredito,
        COALESCE(cc.code, '') AS cd_tipotarjeta,
        COALESCE(ipp."cardNumber", '') AS ds_numerotarjeta,
        COALESCE(ipp.voucher, '') AS ds_vouchertarjeta,
        COALESCE(ipp."expirationDate", '') AS ds_expiraciontarjeta,
        COALESCE(ipp."authorizationCode", '') AS ds_autorizaciontarjeta,
        0 AS in_cuotas,
        '' AS cd_banco,
        '' AS ds_cheque,
        '' AS ds_plaza,
        COALESCE(ipp.reference, '') AS ds_referencia,
        '' AS ds_Poliza,
        '' AS ds_PolizaAnexo,
        ipp.amount AS am_valor
    FROM public."InvoicesProductPayment" ipp
    JOIN Item itm ON ipp."invoiceProductId" = itm.id_item
    JOIN Facturacion f ON itm.id_factura = f.id_factura
    LEFT JOIN public."Payment" pp ON LOWER(pp."name") LIKE ('%' || LOWER(ipp."paymentMethod") || '%') 
	LEFT JOIN public."CreditCard" cc ON ipp."creditCardId" = cc.id;

    -- 10. Poblar Tabla Variables
    INSERT INTO Variables (
        id_factura, id_item, in_tipoitem, ds_maestro, ds_VariableAdicional, ds_valor, cd_codigo
    )
    SELECT 
        f.id_factura AS id_factura,
        itm.id_item AS id_item,
        itm.in_tipoitem AS in_tipoitem,
        CASE WHEN itm.in_tipoitem=1 THEN itm.cd_tiquete ELSE itm.cd_Consecutivo_variablesadicionales END AS ds_maestro,
        COALESCE(mv.name, '') AS ds_VariableAdicional,
        COALESCE(v.value, '') AS ds_valor,
        COALESCE(mv.code, '') AS cd_codigo
    FROM public."InvoicesProductVariable" v
    JOIN public."MasterVariable" mv ON v."masterVariableId" = mv.id
    JOIN Item itm ON v."invoiceProductId" = itm.id_referencia_origen
    JOIN Facturacion f ON itm.id_factura = f.id_factura;

    -- 11. Generar XML
    SELECT xmlroot(
        xmlelement(name "Facturaciones",
            xmlagg(
                xmlelement(name "Facturacion",
                    xmlforest(
                        f.id,f.id_factura, f.cd_fuente, f.cd_serie, f.cd_consecutivo, f.cd_usuario, f.cd_sucursal, f.cd_implante, 
						f.dt_fechacont, f.dt_vence, f.cd_tercero_codigo, f.ds_tercero_nombre, f.cd_cliente_codigo, 
						f.ds_cliente_nombre, f.ds_cliente_dir, f.ds_cliente_ciudad, f.ds_cliente_tel, f.ds_cliente_dirdesp, 
						f.ds_cliente_email, f.ds_cliente_contacto, f.ds_cliente_contacto_email, f.cd_monedas_iata, 
						f.cd_vendedor, f.cd_tiqueteador, f.bn_anexo, f.Tcambio, f.am_tcambiousd, f.id_tipoventa, 
						f.ds_num_resolucion, f.in_num_inicial, f.in_num_final, f.ds_numeracion_autorizada, 
						f.dt_fecha_resolucion, f.CodigoArchivoFisico, f.ds_Observacion, f.ds_Campo_libre1, 
						f.ds_Campo_libre2, f.cd_fuente_Reemplaza, f.cd_serie_Reemplaza, f.cd_consecutivo_Reemplaza, 
						f.ds_Actividad_Economica, f.ds_Tarifa_ICA, f.SqlStmt, f.AnticiposSqlStmt, f.TotalFactura, 
						f.TotalCupoCreditoCliente, f.bl_BloqueoCupoCredito, f.bl_generadaauto, f.ds_CotizacionesId, 
						f.Id_Cierre, f.cd_TipoFact, f.id_fac_remisionRelacionada, f.id_fac_facturaRelacionada, 
						f.ds_DescripcionFac, f.bl_nocont, f.ProductosSqlStmt, f.cd_CF_TipoComprobante, f.id_Licitacion, 
						f.ValorFactura, f.id_Especialista, f.cd_tiqueteador_Facturador, f.id_TipoFormaPagoProveedor, 
						f.id_MedioReservacion, f.bl_refacturacion, f.bl_comisiona, f.cd_fuente_factura, f.cd_serie_factura, 
						f.cd_consecutivo_factura, f.id_NotasAerolinea, f.bl_interface, f.id_evento, f.bl_NoEnviarFacElectronica, 
						f.bl_FacturaComision, f.bl_DescontarComisionCxP, f.ds_num_resolucion_Adicional, 
						f.id_fac_facturaRefacturacion, f.bl_refacturacion_contabilizar_saldos, f.ZML_VariablesXML, 
						f.bl_FormatoResumidoFactElectro, f.bl_ExigeAdjuntoFactElectro, f.bl_omitir_Validar_IVA_facturacion, 
						f.ds_Respuesta
                    ),
                    (
                        SELECT xmlagg(
                            xmlelement(name "Item",
                                xmlforest(
									s.tipo_item, s.id_factura, s.id_item, s.in_tipoitem, s.id_referencia_origen, s.cd_tiquete, 
									s.ds_descrip, s.in_nacionalidad, s.cd_cencosto, s.cd_auxiliar, s.cd_item, 
									s.am_tarifa, s.am_iva, s.am_tua, s.am_comb, s.am_vat, s.am_Comision, 
									s.ds_paxname, s.ds_paxape, s.ds_paxprefix, s.cd_tourcode, s.NumTktConj, 
									s.cd_TipoTiquete, s.id_air, s.ds_itinerario, s.ds_itinerarioaerolinea, 
									s.ds_clases, s.ds_Observaciones, s.am_highfare, s.am_lowfare, s.ds_solicita, 
									s.ds_lapsoviaje, s.cd_tktrevisado, s.cd_PasaportePax, s.cd_pax_CC, 
									s.am_PorFacParcial, s.in_cantpax, s.Id_Precompra, s.cd_FormaPagoTAO, 
									s.cd_TarjetaCreditoTAO, s.cd_NumeroTarjetaTAO, s.cd_VencimientoTarjetaTAO, 
									s.cd_NumeroPolizaTAO, s.cd_AnexoPolizaTAO, s.ds_AutorizacionTarjetaTAO, 
									s.in_cuotasTarjetaTAO, s.cd_FormasPago, s.cd_TarjetasCredito, s.am_fp1, 
									s.ds_cc_code, s.ds_cc_number, s.ds_cc_vence, s.ds_cc_autorizacion, 
									s.ds_cc_voucher, s.in_cc_cuotas, s.am_fp2, s.ds_cc_code2, s.ds_cc_number2, 
									s.ds_cc_vence2, s.ds_cc_autorizacion2, s.ds_cc_voucher2, s.in_cc_cuotas2, 
									s.cd_monedas_iata, s.Tcambio, s.cd_sucursal, s.cd_implante, s.bl_ahorro, 
									s.cd_TipoTiqueteGDS, s.cd_TiposDocumento, s.cd_entdist, s.cd_entvend, 
									s.cd_destino, s.dt_fechaexped, s.cd_tiqueteadores, s.id_gds, s.iden_gds, 
									s.am_comisionPNR, s.ds_records, s.bl_NoCalcComision, s.bl_NoCalcIvaComision, 
									s.am_basecomisionable, s.am_porcomision, s.cd_tiposconceptfac, 
									s.cd_conceptofacturacion, s.cd_tiposservicio, s.cd_proveedores, 
									s.ds_servicio, s.am_valorprov, s.cd_monedaprov, s.dt_llegada, s.dt_salida, 
									s.am_pordescuento, s.am_basedescuento, s.Fecha_Salida, s.Fecha_Llegada, 
									s.ColId, s.cd_Consecutivo_depende, s.CodigoReserva, 
									s.cd_Consecutivo_variablesadicionales, s.am_valor_total, s.ds_proveedores, 
									s.id_FormasPagoAirPlus, s.cd_FormasPagoAirPlus, s.ds_FormasPagoAirPlus, 
									s.id_TarjetasCreditoAirPlus, s.cd_TarjetasCreditoAirPlus, 
									s.ds_numerotarjetaAirPlus, s.id_reserva, s.OrdenGrabacion
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "itinerarios",
                                            xmlforest(
                                                id_factura,	id_item, in_tipoitem, ds_origen, ds_destino, ds_clase, 
												dt_llegada,	dt_salida, ds_terminal, cd_aerolinea, cd_farebasis,	ds_numerovuelo,	
												ds_tipovuelo, am_valor, am_co2 
                                            )
                                        )
                                    )
                                    FROM itinerarios iti
                                    WHERE iti.id_item = s.id_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Pasajeros",
                                            xmlforest(
                                                p.id_factura, p.id_item, p.in_tipoitem, p.ds_paxape, p.ds_paxname, p.ds_paxprefix,
                                                p.ds_paxClasificacion, p.cd_voucherpax, p.cd_paxidentificacion, p.in_edad, p.cd_tiquete
                                            )
                                        )
                                    )
                                    FROM Pasajeros p
                                    WHERE p.id_item = s.id_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CargosImpuestos",
                                            xmlforest(
                                                ci.id_factura, ci.id_item, ci.in_tipoitem, ci.cd_codigo, ci.ds_nombre, ci.cd_tipo,
                                                ci.am_porcentaje, ci.am_valor, ci.am_contado, ci.am_credito, ci.id_carg, ci.id_imp,
                                                ci.bl_iva, ci.in_orden
                                            )
                                        )
                                    )
                                    FROM CargosImpuestos ci
                                    WHERE ci.id_item = s.id_item
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Formaspago",
                                            xmlforest(
                                                fp.id_factura, fp.id_item, fp.in_tipoitem, fp.id_formaspago, fp.cd_codigo, fp.ds_nombre,
                                                fp.id_tarjetascredito, fp.cd_tipotarjeta, fp.ds_numerotarjeta, fp.ds_vouchertarjeta,
                                                fp.ds_expiraciontarjeta, fp.ds_autorizaciontarjeta, fp.in_cuotas, fp.cd_banco,
                                                fp.ds_cheque, fp.ds_plaza, fp.ds_referencia, fp.ds_Poliza, fp.ds_PolizaAnexo, fp.am_valor
                                            )
                                        )
                                    )
                                    FROM Formaspago fp
                                    WHERE fp.id_item = s.id_item AND fp.in_tipoitem = s.in_tipoitem
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "Variables",
                                            xmlforest(
                                                v.id_factura, v.id_item, v.in_tipoitem, v.ds_maestro, v.ds_VariableAdicional, v.ds_valor, v.cd_codigo
                                            )
                                        )
                                    )
                                    FROM Variables v
                                    WHERE v.id_item = s.id_item AND v.in_tipoitem = s.in_tipoitem
                                )
                            )
                        )
                        FROM Item s
                        WHERE s.id_factura = f.id_factura 
                    )
                )
            )
        ),
        version '1.0', standalone yes
    )::text INTO v_xml
    FROM Facturacion f;

    mensaje_resultado := COALESCE(v_xml, '<?xml version="1.0" standalone="yes"?><Facturaciones />');

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_context = PG_EXCEPTION_CONTEXT;
		v_line := substring(v_context from 'line ([0-9]+)')::TEXT;
        mensaje_resultado := format('ERROR: %s | EN LÍNEA: %s | ESTADO: %s', v_msg, v_line, v_state);
END;
$$;


--
-- Name: spexportquotation(text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spexportquotation(IN quotation_id text, IN user_id integer, INOUT mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
/*
    AUTOR: Rubiel Gelis Guzman
    DESCRIPCIÓN: Generación de XML poblando TODAS las columnas de las tablas temporales con nombres explícitos en los SELECT.
*/
DECLARE
    v_xml TEXT;
    v_nombre_usuario TEXT;
	v_state   TEXT;
    v_msg     TEXT;
    v_context TEXT;
    v_line    TEXT;
BEGIN
    -- 1. Inicializar
    mensaje_resultado := '';

    Quotation_id := TRIM(BOTH ',' FROM TRIM(COALESCE(Quotation_id, '')));
    IF Quotation_id = '' THEN
        mensaje_resultado := 'ERROR: No se han proporcionado IDs de cotización válidos.';
        RETURN;
    END IF;

    -- 2. Validación de usuario
    SELECT "name" INTO v_nombre_usuario FROM public."User" WHERE id = User_id;
    IF NOT FOUND THEN
        mensaje_resultado := 'ERROR: El usuario ' || User_id || ' no existe.';
        RETURN;
    END IF;

    -- 3. Crear Tablas Temporales (ESQUEMA COMPLETO)
    CREATE TEMP TABLE IF NOT EXISTS Cotizacion (
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_sucursal VARCHAR(25),
		cd_implante VARCHAR(25),
		cd_consecutivo VARCHAR(25),
		cd_usuario VARCHAR(25),
		dt_fechacont TIMESTAMP ,
		dt_fecha TIMESTAMP ,
		cd_usuarioAct VARCHAR(25),
		dt_fechaAct TIMESTAMP ,
		cd_tercero_codigo VARCHAR(25) ,
		ds_tercero_nombre VARCHAR(250) ,
		cd_cliente_codigo VARCHAR(25) ,
		ds_cliente_nombre VARCHAR(250) ,
		ds_cliente_dir VARCHAR(250) ,
		ds_cliente_ciudad VARCHAR(100) ,
		ds_cliente_tel VARCHAR(25) ,
		ds_cliente_dirdesp VARCHAR(250) ,
		ds_cliente_email VARCHAR(60) ,
		ds_cliente_contacto VARCHAR(100) ,
		ds_cliente_contacto_email VARCHAR(60) ,
		cd_monedas_IATA VARCHAR(25),
		cd_vendedor VARCHAR(25) ,
		cd_tiqueteador VARCHAR(25) ,
		bn_anexo BYTEA ,
		am_tcambio DECIMAL ,
		am_tcambiousd DECIMAL ,
		cd_cencosto VARCHAR(16) ,
		ds_observacion VARCHAR(8000) ,
		ds_Campo_libre1 VARCHAR(500) ,
		ds_Campo_libre2 VARCHAR(500) ,
		cd_tipoventa VARCHAR(25),
		in_estado INT ,
		dt_vence TIMESTAMP ,
		cd_Etapa VARCHAR(25),
		ds_seguimiento_etapa VARCHAR(500) ,
		bl_ManejaOpciones BIT(1) DEFAULT B'0',
		in_NumeroOpciones INT ,
		bl_CerrarCotizacion BIT(1) DEFAULT B'0',
		in_OpcionSeleccionada INT ,
		bl_grupos BIT(1) DEFAULT B'0',
		gk_sabre VARCHAR(25) ,
		cd_Especialista VARCHAR(25),
		cd_TipoFormaPagoProveedor VARCHAR(25),
		cd_MedioReservacion VARCHAR(25),
		bl_bloqueada BIT(1) DEFAULT B'0',
		cd_usuario_Bloqueo VARCHAR(25),
		ds_AlertaSolicitud VARCHAR(8000) ,
		bl_comisiona BIT(1) DEFAULT B'0',
		ds_FormaDePago VARCHAR(250) ,
		ds_records VARCHAR(25) ,
		bl_entregadoCliente BIT(1) DEFAULT B'0',
		dt_entregadoCliente TIMESTAMP ,
		id_sys_entidades INT ,
		cd_MonedaPagoDestino VARCHAR(25) ,
		cd_FormaPagoDestino VARCHAR(25) ,
		ds_DocumentoPagoDestino VARCHAR(50) ,
		dt_CheckInPagoDestino TIMESTAMP ,
		dt_CheckOutPagoDestino TIMESTAMP ,
		bl_fechaPagoDestino BIT(1) DEFAULT B'0',
		ds_hotelTieneTiquete VARCHAR(2),
		ds_GDS VARCHAR(2),
		cd_Evento VARCHAR(25),
        orig_id_ref INT
    ) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionServicios(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_TiposConceptFac VARCHAR(25),
		cd_ConceptoFacturacion VARCHAR(25),
		cd_TiposServicio VARCHAR(25) ,
		cd_Cotizacion VARCHAR(25) ,
		cd_fac_factura VARCHAR(25) ,
		cd_fac_remision VARCHAR(25) ,
		cd_proveedores VARCHAR(25) ,
		ds_tiposervnm VARCHAR(50) ,
		cd_prov_hotel VARCHAR(10) ,
		cd_prov_car VARCHAR(10) ,
		cd_prov_air VARCHAR(10) ,
		ds_destino VARCHAR(30) ,
		ds_servicio VARCHAR(250) ,
		ds_descrip VARCHAR(4000) ,
		ds_paxname VARCHAR(20) ,
		ds_paxape VARCHAR(20) ,
		cd_paxtype VARCHAR(25) ,
		in_nacionalidad INT ,
		cd_voucher VARCHAR(20) ,
		in_cantpax INT ,
		dt_llegada TIMESTAMP ,
		dt_salida TIMESTAMP ,
		cd_cencosto VARCHAR(16) ,
		cd_auxiliar VARCHAR(16) ,
		cd_item VARCHAR(16) ,
		am_valorprov DECIMAL ,
		cd_monedaprov VARCHAR(25) ,
		ds_InfoAdicional VARCHAR(8000) ,
		cd_carrental VARCHAR(25) ,
		cd_hoteles VARCHAR(25) ,
		bl_anulado BIT(1) DEFAULT B'0' ,
		cd_tiquete VARCHAR(11) ,
		cd_fuente_anul VARCHAR(2) ,
		cd_serie_anul VARCHAR(2) ,
		cd_consecutivo_anul VARCHAR(8) ,
		cd_usuario_anul VARCHAR(25),
		cd_sucursal_anul VARCHAR(25) ,
		cd_implante_anul VARCHAR(25) ,
		am_basecomisionable DECIMAL ,
		am_porcomision NUMERIC(8, 4) ,
		cd_voucherPrefijo VARCHAR(25) ,
		bl_notdomicilionacional BIT(1) DEFAULT B'0' ,
		Valor_Comision DECIMAL ,
		Valor_Recaudo DECIMAL ,
		dias_recaudo INT ,
		ds_paxClasificacion VARCHAR(7) ,
		cd_tipoplan VARCHAR(25) ,
		cd_acomodacion VARCHAR(25) ,
		in_dias INT ,
		in_noches INT ,
		ds_records VARCHAR(25) ,
		cd_GrConcepto VARCHAR(25) ,
		in_diasSrv INT ,
		in_nochesSrv INT ,
		cd_Especialista VARCHAR(25),
		am_porcentaje_descuento NUMERIC(8, 4) ,
		am_valor_descuento DECIMAL ,
		ds_motivo_descuento VARCHAR(1000) ,
		cd_cargosdesc_descuento VARCHAR(25) ,
		in_NumeroOpcion INT ,
		dt_FechaSalidaSrv TIMESTAMP ,
		dt_FechaLlegadaSrv TIMESTAMP ,
		cd_localizador VARCHAR(25) ,
		cd_voucherpax VARCHAR(25) ,
		am_basecomisionableprov DECIMAL ,
		am_porcomisionprov NUMERIC(8, 4) ,
		cd_NumeFac VARCHAR(15) ,
		dt_VenceFac TIMESTAMP ,
		cd_AcomodacionSrv VARCHAR(25) ,
		cd_TipoPlanSrv VARCHAR(25) ,
		in_habitaciones INT ,
		in_habitacionesSrv INT ,
		cd_Consecutivo_VARiablesAdicionales VARCHAR(8) ,
		cd_confirmacion VARCHAR(25) ,
		ds_confirmadopor VARCHAR(250) ,
		cd_paxidentificacion VARCHAR(25) ,
		bl_politicaCancelacion BIT(1) DEFAULT B'0' ,
		dt_politicaCancelacion TIMESTAMP ,
		cd_tipoHabitacionacion VARCHAR(25) ,
		cd_fac_facturaComision VARCHAR(25) ,
		cd_fac_remisionComision VARCHAR(25) ,
		cd_TarjetaAsistencia VARCHAR(25) ,
		cd_Regiones VARCHAR(25) ,
		Iden_GDS INT ,
		id_sys_entidades INT ,
		ds_TipoAuto VARCHAR(50) ,
		ds_Origen VARCHAR(30) ,
		ds_DirOrigen VARCHAR(250) ,
		ds_DirDestino VARCHAR(250) ,
		ds_TipoTarifa VARCHAR(50) ,
		am_ValorUSD DECIMAL ,
		ds_NoVuelo VARCHAR(25) ,
		ds_Vehiculo VARCHAR(250) ,
		ds_Placa VARCHAR(25) ,
		ds_CategoriaVehiculo VARCHAR(250) ,
		ds_NombreConductor VARCHAR(50) ,
		ds_telefono VARCHAR(25) ,
		ds_IdiomaConductor VARCHAR(25) ,
		cd_MonedaSrv VARCHAR(25) ,
		cd_TipoServicio VARCHAR(25) ,
		cd_Aerolinea VARCHAR(25) ,
		in_EdadPax INT ,
		am_PorFacParcial NUMERIC(8, 4) ,
		ds_GDS VARCHAR(25) ,
		dt_fechaficheroBBVA TIMESTAMP ,
		bl_tiquete BIT(1) DEFAULT B'0' ,
		am_basedescuento DECIMAL ,
		am_pordescuento NUMERIC(18, 4) ,
		cd_CotizacionServicios_Depende VARCHAR(25),
        orig_id_ref INT,
		orig_id_quotationref INT,
		mainTaxId INT
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionServicios_PaxAdicional(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_Cotizacion VARCHAR(25),
		cd_CotizacionServicios VARCHAR(25),
		ds_paxape VARCHAR(30),
		ds_paxname VARCHAR(30),
		ds_paxprefix CHAR(25),
		ds_paxClasificacion CHAR(25),
		cd_voucherpax VARCHAR(25),
		cd_paxidentificacion VARCHAR(25),
		in_edad INT,
		cd_tiquete CHAR(50)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionServicios_VariableAdicional(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_Cotizacion VARCHAR(25),
		cd_CotizacionServicios VARCHAR(25),
		ds_maestro VARCHAR(25), 
		ds_VariableAdicional VARCHAR(25),
		ds_valor VARCHAR(500),
		cd_codigo CHAR(25)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionCargos(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_CotizacionServicios VARCHAR(25) ,
		cd_CotizacionCargos VARCHAR(25),
		cd_cargosdesc VARCHAR(25) ,
		ds_cargonm VARCHAR(50) ,
		bl_noshow BIT(1) DEFAULT B'0' ,
		am_contado DECIMAL ,
		am_credito DECIMAL ,
		am_valor DECIMAL GENERATED ALWAYS AS (am_contado + am_credito) STORED,
		am_contado_ME DECIMAL ,
		am_credito_ME DECIMAL ,
		am_valor_ME DECIMAL GENERATED ALWAYS AS (am_contado_ME + am_credito_ME) STORED,
        orig_id_ref INT,
		cd_Cotizacion VARCHAR(25) 
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionImpuestos(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_CotizacionCargos VARCHAR(25),
		cd_CotizacionImpuestos VARCHAR(25),
		cd_ImpRet VARCHAR(25),
		ds_Impas VARCHAR(50),
		cd_impcta VARCHAR(16),
		am_porcentaje DECIMAL,
		bl_contabilizar BIT(1) DEFAULT B'0' ,
		am_contado DECIMAL,
		am_credito DECIMAL,
		am_valor DECIMAL GENERATED ALWAYS AS (am_contado + am_credito) STORED,
		am_contado_ME DECIMAL,
		am_credito_ME DECIMAL,
		am_valor_ME DECIMAL GENERATED ALWAYS AS (am_contado_ME + am_credito_ME) STORED,
		cd_CotizacionServicios VARCHAR(25),
		cd_Cotizacion VARCHAR(25)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS Fac_Servicios_TiposFacturacionHoteles(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_Cotizacion varchar(25),
		cd_CotizacionServicios varchar(25),
		cd_TiposFacturacionHoteles varchar(25),
		cd_cargosdesc varchar(25),
		in_cantidad INT,
		am_contado DECIMAL,
		am_credito DECIMAL,
		am_valor DECIMAL GENERATED ALWAYS AS (am_contado + am_credito) STORED,
		ds_cargonm varchar(50) NULL
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionServicios_TipoProv(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_Cotizacion varchar(25),
		cd_CotizacionServicios varchar(25),
		cd_TipoProveedores varchar(25),
		ds_TipoProveedores varchar(60),
		cd_proveedores varchar(25),
		ds_proveedores varchar(250)
	) ON COMMIT DROP;

	CREATE TEMP TABLE IF NOT EXISTS CotizacionServiciosFormasPago(
		id INT GENERATED ALWAYS AS IDENTITY,
		cd_Cotizacion VARCHAR(25),
		cd_CotizacionServicios VARCHAR(25),
		cd_codigo VARCHAR(3),
		ds_FPnm VARCHAR(100),
		bl_FPrepresenta BIT(1) DEFAULT B'0',
		id_TarjetasCredito INT,
		cd_tccode VARCHAR(10),
		ds_tcnumber VARCHAR(16),
		ds_tcvoucher VARCHAR(25),
		cd_idbanco VARCHAR(3),
		ds_cheque VARCHAR(30),
		ds_referencia VARCHAR(50),
		am_valor DECIMAL,
		ds_tcexp VARCHAR(7),
		ds_plaza VARCHAR(3),
		ds_Poliza VARCHAR(20),
		ds_PolAnexo VARCHAR(20),
		am_valor_ME DECIMAL DEFAULT 0,
		ds_tcautorizacion VARCHAR(25),
		in_tccuotas INT
	) ON COMMIT DROP;

    -- 4. Poblar Tablas Temporales (POBLANDO TODAS LAS COLUMNAS CON NOMBRES EXPLÍCITOS)
    
    INSERT INTO Cotizacion (
        cd_sucursal, cd_implante, cd_consecutivo, cd_usuario, dt_fechacont, dt_fecha, 
        cd_usuarioAct, dt_fechaAct, cd_tercero_codigo, ds_tercero_nombre, cd_cliente_codigo, 
        ds_cliente_nombre, ds_cliente_dir, ds_cliente_ciudad, ds_cliente_tel, ds_cliente_dirdesp, 
        ds_cliente_email, ds_cliente_contacto, ds_cliente_contacto_email, cd_monedas_IATA, 
        cd_vendedor, cd_tiqueteador, bn_anexo, am_tcambio, am_tcambiousd, cd_cencosto, 
        ds_observacion, ds_Campo_libre1, ds_Campo_libre2, cd_tipoventa, in_estado, 
        dt_vence, cd_Etapa, ds_seguimiento_etapa, bl_ManejaOpciones, in_NumeroOpciones, 
        bl_CerrarCotizacion, in_OpcionSeleccionada, bl_grupos, gk_sabre, cd_Especialista, 
        cd_TipoFormaPagoProveedor, cd_MedioReservacion, bl_bloqueada, cd_usuario_Bloqueo, 
        ds_AlertaSolicitud, bl_comisiona, ds_FormaDePago, ds_records, bl_entregadoCliente, 
        dt_entregadoCliente, id_sys_entidades, cd_MonedaPagoDestino, cd_FormaPagoDestino, 
        ds_DocumentoPagoDestino, dt_CheckInPagoDestino, dt_CheckOutPagoDestino, 
        bl_fechaPagoDestino, ds_hotelTieneTiquete, ds_GDS, cd_Evento, orig_id_ref
    )
    SELECT 
        COALESCE(b.code, '') as cd_sucursal, 
        COALESCE(i.code, '') as cd_implante, 
        'Q' || LPAD(q."id"::text, 7, '0') as cd_consecutivo, 
        public."fnQuitarEspeciales"(v_nombre_usuario) as cd_usuario, 
        q.date as dt_fechacont, 
        q.date as dt_fecha,
        public."fnQuitarEspeciales"(v_nombre_usuario) as cd_usuarioAct, 
        q.date as dt_fechaAct, 
        COALESCE(c.document, '') as cd_tercero_codigo, 
        public."fnQuitarEspeciales"(c.name) as ds_tercero_nombre, 
        COALESCE(c.document, '') as cd_cliente_codigo,
        public."fnQuitarEspeciales"(c.name) as ds_cliente_nombre, 
        public."fnQuitarEspeciales"(COALESCE(c.address, '')) as ds_cliente_dir, 
        '' as ds_cliente_ciudad, 
        '' as ds_cliente_tel, 
        '' as ds_cliente_dirdesp, 
        COALESCE(u.email, '') as ds_cliente_email, 
        public."fnQuitarEspeciales"(c.name) as ds_cliente_contacto, 
        '' as ds_cliente_contacto_email, 
        q.currency as cd_monedas_IATA,
        COALESCE(s.code, '') as cd_vendedor, 
        public."fnQuitarEspeciales"(COALESCE(t.code, '')) as cd_tiqueteador, 
        NULL as bn_anexo, 
        q."exchangeRate" as am_tcambio, 
        q."exchangeRate" as am_tcambiousd, 
        '' as cd_cencosto,
        '' as ds_observacion, 
        '' as ds_Campo_libre1, 
        '' as ds_Campo_libre2, 
        '' as cd_tipoventa, 
        1 as in_estado, 
        q.date as dt_vence, 
        '' as cd_Etapa, 
        '' as ds_seguimiento_etapa, 
        B'0' as bl_ManejaOpciones, 
        0 as in_NumeroOpciones, 
        B'0' as bl_CerrarCotizacion, 
        0 as in_OpcionSeleccionada, 
        B'0' as bl_grupos, 
        '' as gk_sabre, 
        '' as cd_Especialista, 
        '' as cd_TipoFormaPagoProveedor, 
        '' as cd_MedioReservacion, 
        B'0' as bl_bloqueada, 
        '' as cd_usuario_Bloqueo, 
        '' as ds_AlertaSolicitud, 
        B'0' as bl_comisiona, 
        COALESCE((
            SELECT string_agg(DISTINCT qpmt."paymentMethod", ', ' ORDER BY qpmt."paymentMethod")
            FROM public."QuotationProduct" qp2
            JOIN public."QuotationProductPayment" qpmt ON qpmt."quotationProductId" = qp2.id
            WHERE qp2."quotationId" = q.id
              AND qpmt."paymentMethod" IS NOT NULL
              AND qpmt."paymentMethod" <> ''
        ), '') as ds_FormaDePago, 
        '' as ds_records, 
        B'0' as bl_entregadoCliente, 
        q.date as dt_entregadoCliente, 
        0 as id_sys_entidades, 
        '' as cd_MonedaPagoDestino, 
        '' as cd_FormaPagoDestino, 
        '' as ds_DocumentoPagoDestino, 
        q.date as dt_CheckInPagoDestino, 
        q.date as dt_CheckOutPagoDestino, 
        B'0' as bl_fechaPagoDestino, 
        '' as ds_hotelTieneTiquete, 
        '' as ds_GDS, 
        '' as cd_Evento, 
        q.id as orig_id_ref
    FROM public."Quotation" q
    LEFT JOIN public."Client" c ON q."clientId" = c.id
    LEFT JOIN public."Branch" b ON q."branchId" = b.id
    LEFT JOIN public."Implant" i ON q."implantId" = i.id
    LEFT JOIN public."Seller" s ON q."sellerId" = s.id
    LEFT JOIN public."TicketPrinter" t ON q."ticketPrinterId" = t.id
    LEFT JOIN public."User" u ON q."userId" = u.id -- Traer email del usuario creador
    WHERE q.id = ANY(string_to_array(Quotation_id, ',')::int[]);

    INSERT INTO CotizacionServicios (
        cd_TiposConceptFac, cd_ConceptoFacturacion, cd_TiposServicio, cd_Cotizacion,
        cd_fac_factura, cd_fac_remision, cd_proveedores, ds_tiposervnm, cd_prov_hotel,
        cd_prov_car, cd_prov_air, ds_destino, ds_servicio, ds_descrip, ds_paxname,
        ds_paxape, cd_paxtype, in_nacionalidad, cd_voucher, in_cantpax, dt_llegada,
        dt_salida, cd_cencosto, cd_auxiliar, cd_item, am_valorprov, cd_monedaprov,
        ds_InfoAdicional, cd_carrental, cd_hoteles, bl_anulado, cd_tiquete,
        cd_fuente_anul, cd_serie_anul, cd_consecutivo_anul, cd_usuario_anul,
        cd_sucursal_anul, cd_implante_anul, am_basecomisionable, am_porcomision,
        cd_voucherPrefijo, bl_notdomicilionacional, Valor_Comision, Valor_Recaudo,
        dias_recaudo, ds_paxClasificacion, cd_tipoplan, cd_acomodacion, in_dias,
        in_noches, ds_records, cd_GrConcepto, in_diasSrv, in_nochesSrv, cd_Especialista,
        am_porcentaje_descuento, am_valor_descuento, ds_motivo_descuento,
        cd_cargosdesc_descuento, in_NumeroOpcion, dt_FechaSalidaSrv, dt_FechaLlegadaSrv,
        cd_localizador, cd_voucherpax, am_basecomisionableprov, am_porcomisionprov,
        cd_NumeFac, dt_VenceFac, cd_AcomodacionSrv, cd_TipoPlanSrv, in_habitaciones,
        in_habitacionesSrv, cd_Consecutivo_VARiablesAdicionales, cd_confirmacion,
        ds_confirmadopor, cd_paxidentificacion, bl_politicaCancelacion,
        dt_politicaCancelacion, cd_tipoHabitacionacion, cd_fac_facturaComision,
        cd_fac_remisionComision, cd_TarjetaAsistencia, cd_Regiones, Iden_GDS, id_sys_entidades,
        ds_TipoAuto, ds_Origen, ds_DirOrigen, ds_DirDestino, ds_TipoTarifa, am_ValorUSD,
        ds_NoVuelo, ds_Vehiculo, ds_Placa, ds_CategoriaVehiculo, ds_NombreConductor,
        ds_telefono, ds_IdiomaConductor, cd_MonedaSrv, cd_TipoServicio, cd_Aerolinea,
        in_EdadPax, am_PorFacParcial, ds_GDS, dt_fechaficheroBBVA, bl_tiquete,
        am_basedescuento, am_pordescuento, cd_CotizacionServicios_Depende, 
		orig_id_ref, orig_id_quotationref, mainTaxId
    )
    SELECT 
        COALESCE(pr."type", '') as cd_TiposConceptFac, 
        COALESCE(pr."billingConcept", pr."code", '') as cd_ConceptoFacturacion, 
        COALESCE(pr."serviceType", qp."serviceType", '') as cd_TiposServicio, 
        q.cd_consecutivo as cd_Cotizacion,
        '' as cd_fac_factura, 
        '' as cd_fac_remision, 
        COALESCE(prov.code, prov.name, '') as cd_proveedores, 
        COALESCE(qp."serviceType", '') as ds_tiposervnm, 
        '' as cd_prov_hotel,
        '' as cd_prov_car, 
        '' as cd_prov_air, 
        COALESCE(qp.destination, '') as ds_destino, 
        COALESCE(pr.description, '') as ds_servicio, 
        COALESCE(pr.description, '') as ds_descrip, 
		CASE 
	        WHEN qpp.name IS NULL OR TRIM(qpp.name) = '' THEN ''
	        WHEN TRIM(qpp.name) NOT LIKE '% %' THEN TRIM(qpp.name)
	        ELSE COALESCE(arr[1], '')
	    END AS ds_paxname,
	    CASE 
	        WHEN qpp.name IS NULL OR TRIM(qpp.name) = '' THEN ''
	        WHEN TRIM(qpp.name) NOT LIKE '% %' THEN ''
	        ELSE COALESCE(arr[2], '')
	    END AS ds_paxape,
        CASE 
	        WHEN TRIM(qpp.name) LIKE '% %' THEN COALESCE(arr[3], '')
	        ELSE ''
	    END as cd_paxtype, 
        COALESCE(qp."inNationality", 1) as in_nacionalidad, 
        '' as cd_voucher, 
        qp.quantity as in_cantpax, 
        COALESCE(qp."checkInDate", q.dt_fecha) as dt_llegada,
        COALESCE(qp."checkOutDate", q.dt_fecha) as dt_salida, 
        '' as cd_cencosto, 
        '' as cd_auxiliar, 
        '' as cd_item, 
        (
            COALESCE(qp.price, 0) +
            COALESCE((
                SELECT SUM(qpt2."explicitAmount")
                FROM public."QuotationProductTax" qpt2
                JOIN public."ChargeAndTax" ct2 ON ct2.id = qpt2."chargeAndTaxId"
                LEFT JOIN public."ChargeAndTax" target_ct ON target_ct.id = ct2."targetTaxId"
                WHERE qpt2."quotationProductId" = qp.id
                  AND qpt2."isMain" = false
                  AND ct2."targetTaxId" IS NOT NULL
                  AND (
                      target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = qp."mainTaxId"
                  )
            ), 0)
        ) as am_valorprov, 
        qt.currency as cd_monedaprov,
        '' as ds_InfoAdicional, 
        '' as cd_carrental, 
        COALESCE(pre."code",'') as cd_hoteles, 
        B'0' as bl_anulado, 
        '' as cd_tiquete,
        '' as cd_fuente_anul, 
        '' as cd_serie_anul, 
        '' as cd_consecutivo_anul, 
        '' as cd_usuario_anul,
        '' as cd_sucursal_anul, 
        '' as cd_implante_anul, 
        0 as am_basecomisionable, 
        0 as am_porcomision,
        '' as cd_voucherPrefijo, 
        B'0' as bl_notdomicilionacional, 
        0 as Valor_Comision, 
        0 as Valor_Recaudo,
        0 as dias_recaudo, 
        CASE 
	        WHEN TRIM(qpp.name) LIKE '% %' THEN COALESCE(arr[4], '')
	        ELSE ''
	    END  as ds_paxClasificacion, 
        '' as cd_tipoplan, 
        '' as cd_acomodacion, 
        0 as in_dias,
        COALESCE(qp.nights, 0) as in_noches, 
        '' as ds_records, 
        '' as cd_GrConcepto, 
        0 as in_diasSrv, 
        0 as in_nochesSrv, 
        '' as cd_Especialista,
        0 as am_porcentaje_descuento, 
        0 as am_valor_descuento, 
        '' as ds_motivo_descuento,
        '' as cd_cargosdesc_descuento, 
        0 as in_NumeroOpcion, 
        q.dt_fecha as dt_FechaSalidaSrv, 
        q.dt_fecha as dt_FechaLlegadaSrv,
        '' as cd_localizador, 
        '' as cd_voucherpax, 
        0 as am_basecomisionableprov, 
        0 as am_porcomisionprov,
        '' as cd_NumeFac, 
        q.dt_fecha as dt_VenceFac, 
        '' as cd_AcomodacionSrv, 
        '' as cd_TipoPlanSrv, 
        0 as in_habitaciones,
        0 as in_habitacionesSrv, 
        'Q' || LPAD(qp."id"::text, 7, '0') as cd_Consecutivo_VARiablesAdicionales, 
        '' as cd_confirmacion,
        '' as ds_confirmadopor, 
        COALESCE(qpp.document,'') as cd_paxidentificacion, 
        B'0' as bl_politicaCancelacion,
        q.dt_fecha as dt_politicaCancelacion, 
        '' as cd_tipoHabitacionacion, 
        '' as cd_fac_facturaComision,
        '' as cd_fac_remisionComision, 
        '' as cd_TarjetaAsistencia, 
        '' as cd_Regiones, 
        0 as Iden_GDS, 
        0 as id_sys_entidades,
        '' as ds_TipoAuto, 
        '' as ds_Origen, 
        '' as ds_DirOrigen, 
        '' as ds_DirDestino, 
        '' as ds_TipoTarifa, 
        0 as am_ValorUSD,
        '' as ds_NoVuelo, 
        '' as ds_Vehiculo, 
        '' as ds_Placa, 
        '' as ds_CategoriaVehiculo, 
        '' as ds_NombreConductor,
        '' as ds_telefono, 
        '' as ds_IdiomaConductor, 
        qt.currency as cd_MonedaSrv, 
        '' as cd_TipoServicio, 
        '' as cd_Aerolinea,
        0 as in_EdadPax, 
        0 as am_PorFacParcial, 
        '' as ds_GDS, 
        q.dt_fecha as dt_fechaficheroBBVA, 
        B'0' as bl_tiquete,
        0 as am_basedescuento, 
        0 as am_pordescuento, 
        '' as cd_CotizacionServicios_Depende, 
        qp.id as orig_id_ref,
		q.orig_id_ref as orig_id_quotationref,
		qp."mainTaxId" as mainTaxId
    FROM public."QuotationProduct" qp
	JOIN public."Quotation" qt ON qp."quotationId" = qt.id
    JOIN public."Product" pr ON qp."productId" = pr.id
    JOIN Cotizacion q ON qp."quotationId" = q.orig_id_ref
    LEFT JOIN public."Provider" prov ON qp."providerId" = prov."id"
	LEFT JOIN public."Prestadora" pre ON pre."id" = qp."prestadoraId"
	LEFT JOIN LATERAL ( 
        SELECT 
            COALESCE(pp.id, 999999) as id,
            COALESCE(pp.name, qp.passenger, '') as name,
            COALESCE(pp.document, '') as document,
            regexp_split_to_array(TRIM(COALESCE(pp.name, qp.passenger, '')), '\s+') AS arr
        FROM (SELECT 1) dummy
        LEFT JOIN public."QuotationProductPassenger" pp ON pp."quotationProductId" = qp.id
        ORDER BY pp.id NULLS LAST
        LIMIT 1
    ) qpp ON true;

    --INSERT INTO CotizacionServicios_PaxAdicional (
    --    cd_Cotizacion, cd_CotizacionServicios, ds_paxape, ds_paxname, ds_paxprefix,
    --    ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion, in_edad, cd_tiquete
    --)
    --SELECT 
    --    cs.cd_Cotizacion, 
    --    cs.cd_Consecutivo_VARiablesAdicionales as cd_CotizacionServicios, 
    --    '' as ds_paxape, 
    --    p.name as ds_paxname, 
    --    '' as ds_paxprefix, 
    --    '' as ds_paxClasificacion, 
    --    '' as cd_voucherpax, 
    --    p.document as cd_paxidentificacion, 
    --    0 as in_edad, 
    --    '' as cd_tiquete
    --FROM public."QuotationProductPassenger" p
    --JOIN CotizacionServicios cs ON p."quotationProductId" = cs.orig_id_ref;

	INSERT INTO CotizacionServicios_PaxAdicional (
				cd_Cotizacion,cd_CotizacionServicios, ds_paxape, ds_paxname, ds_paxprefix,
				ds_paxClasificacion, cd_voucherpax, cd_paxidentificacion,in_edad, cd_tiquete
	)
	SELECT 
	    cs.cd_Cotizacion, 
	    cs.cd_Consecutivo_VARiablesAdicionales AS cd_CotizacionServicios, 
	    CASE 
	        WHEN p.name IS NULL OR TRIM(p.name) = '' THEN ''
	        WHEN TRIM(p.name) NOT LIKE '% %' THEN ''
	        ELSE COALESCE(arr[2], '')
	    END AS ds_paxape,
	    CASE 
	        WHEN p.name IS NULL OR TRIM(p.name) = '' THEN ''
	        WHEN TRIM(p.name) NOT LIKE '% %' THEN TRIM(p.name)
	        ELSE COALESCE(arr[1], '')
	    END AS ds_paxname,
	    CASE 
	        WHEN TRIM(p.name) LIKE '% %' THEN COALESCE(arr[3], '')
	        ELSE ''
	    END AS ds_paxprefix,
	    CASE 
	        WHEN TRIM(p.name) LIKE '% %' THEN COALESCE(arr[4], '')
	        ELSE ''
	    END AS ds_paxClasificacion,
	    CASE 
	        WHEN TRIM(p.name) LIKE '% %' THEN COALESCE(arr[5], '')
	        ELSE ''
	    END AS cd_voucherpax,
	    p.document AS cd_paxidentificacion, 
	    0 AS in_edad, 
	    '' AS cd_tiquete
		FROM (
		    SELECT 
		        p.*,
		        regexp_split_to_array(TRIM(p.name), '\s+') AS arr,
		        ROW_NUMBER() OVER (
		            PARTITION BY p."quotationProductId"
		            ORDER BY p.id
		        ) AS rn
		    FROM public."QuotationProductPassenger" p
		) p
		JOIN CotizacionServicios cs 
		    ON p."quotationProductId" = cs.orig_id_ref
		WHERE p.rn > 1;

    INSERT INTO CotizacionServicios_VariableAdicional (
        cd_Cotizacion, cd_CotizacionServicios, ds_maestro, ds_VariableAdicional, ds_valor, cd_codigo
    )
    SELECT 
        cs.cd_Cotizacion, 
        cs.cd_Consecutivo_VARiablesAdicionales as cd_CotizacionServicios, 
        'CotizacionServicios' as ds_maestro, 
        mv.name as ds_VariableAdicional, 
        v.value as ds_valor, 
        mv.code as cd_codigo
    FROM public."QuotationProductVariable" v
    JOIN public."MasterVariable" mv ON v."masterVariableId" = mv."id"
    JOIN CotizacionServicios cs ON v."quotationProductId" = cs.orig_id_ref;

    -- SEPARACIÓN CARGOS vs IMPUESTOS (respetando targetTaxId si está configurado)
    INSERT INTO CotizacionCargos (
        cd_CotizacionServicios, cd_CotizacionCargos, cd_cargosdesc, ds_cargonm, bl_noshow, am_contado,
        am_credito, am_contado_ME, am_credito_ME, orig_id_ref, cd_Cotizacion
    )
    SELECT 
        cs.cd_Consecutivo_VARiablesAdicionales as cd_CotizacionServicios,
		t."id"::text as cd_CotizacionCargos,
        COALESCE(target_ct.code, ct.code, '') as cd_cargosdesc, 
        COALESCE(target_ct.name, ct.name, '') as ds_cargonm, 
        B'0' as bl_noshow, 
        (
            t."explicitAmount" +
            CASE WHEN (t."isMain" = true OR ct.type = 'PRINCIPAL' OR ct.code = 'TAR' OR ct.name ILIKE '%TARIFA%' OR ct.id = cs.mainTaxId) THEN
                COALESCE((
                    SELECT SUM(sub_t."explicitAmount")
                    FROM public."QuotationProductTax" sub_t
                    JOIN public."ChargeAndTax" sub_ct ON sub_t."chargeAndTaxId" = sub_ct.id
                    WHERE sub_t."quotationProductId" = t."quotationProductId"
                      AND sub_t."isMain" = false
                      AND sub_ct."targetTaxId" = ct.id
                ), 0)
            ELSE 0 END
        ) as am_contado, 
        0 as am_credito, 
        0 as am_contado_ME, 
        0 as am_credito_ME, 
        t.id as orig_id_ref,
		cs.cd_Cotizacion as cd_Cotizacion 
    FROM public."QuotationProductTax" t
    JOIN public."ChargeAndTax" ct ON t."chargeAndTaxId" = ct.id
    LEFT JOIN public."ChargeAndTax" target_ct ON ct."targetTaxId" = target_ct.id
    JOIN CotizacionServicios cs ON t."quotationProductId" = cs.orig_id_ref
    WHERE COALESCE(target_ct.type, ct.type) <> 'TAX'
      AND NOT (
          t."isMain" = false AND ct."targetTaxId" IS NOT NULL AND (
              target_ct.type = 'PRINCIPAL' OR target_ct."isEditable" = false OR target_ct.code = 'TAR' OR target_ct.name ILIKE '%TARIFA%' OR target_ct.id = cs.mainTaxId
          )
      );

    INSERT INTO CotizacionImpuestos (
        cd_CotizacionCargos, cd_CotizacionImpuestos, cd_ImpRet, ds_Impas, cd_impcta, am_porcentaje,
        bl_contabilizar, am_contado, am_credito, am_contado_ME, am_credito_ME,
		cd_CotizacionServicios, cd_Cotizacion
    )
    SELECT 
        COALESCE(tp."id", 1)::text  as cd_CotizacionCargos,
		t."id"::text as cd_CotizacionImpuestos,
        COALESCE(target_ct.code, ct.code, '') as cd_ImpRet, 
        COALESCE(target_ct.name, ct.name, '') as ds_Impas, 
        '' as cd_impcta, 
        COALESCE(t."valueSnapshot", 0) as am_porcentaje,
        B'0' as bl_contabilizar, 
        COALESCE(t."explicitAmount", 0) as am_contado, 
        0 as am_credito, 
        0 as am_contado_ME, 
        0 as am_credito_ME,
		cs.cd_Consecutivo_VARiablesAdicionales as cd_CotizacionServicios,
		cs.cd_Cotizacion as cd_Cotizacion
    FROM public."QuotationProductTax" t
    JOIN public."ChargeAndTax" ct ON t."chargeAndTaxId" = ct.id
    LEFT JOIN public."ChargeAndTax" target_ct ON ct."targetTaxId" = target_ct.id
    JOIN CotizacionServicios cs ON t."quotationProductId" = cs.orig_id_ref
	LEFT JOIN public."QuotationProduct" qp ON qp.id = cs.orig_id_ref
	LEFT JOIN public."QuotationProductTax" tp ON tp."quotationProductId" = cs.orig_id_ref and tp."chargeAndTaxId" = qp."mainTaxId"
    WHERE COALESCE(target_ct.type, ct.type) = 'TAX';

	INSERT INTO Fac_Servicios_TiposFacturacionHoteles(
		cd_Cotizacion,
		cd_CotizacionServicios,
		cd_TiposFacturacionHoteles,
		cd_cargosdesc,
		in_cantidad,
		am_contado,
		am_credito,
		ds_cargonm
	)	
	SELECT 
		'Q' || LPAD(qp."quotationId"::text, 7, '0') as cd_Cotizacion, 
		'Q' || LPAD(qp."id"::text, 7, '0') as cd_CotizacionServicios,
		'NCH' AS cd_TiposFacturacionHoteles, --ADT Adulto,CHD Niño,HAB Habitacion,CAN Cantidad,NCH Noches
		COALESCE(ct."code",'TAR') AS cd_cargosdesc,
		COALESCE(qp."quantity",0) AS in_cantidad,
		COALESCE(tp."explicitAmount",0)/COALESCE(qp."quantity",1) AS am_contado,
		0 AS am_credito,
		COALESCE(ct."name",'Tarifa') AS ds_cargonm
	FROM public."QuotationProduct" qp
	JOIN Cotizacion q ON qp."quotationId" = q.orig_id_ref
	LEFT JOIN public."ChargeAndTax" ct ON ct.id = qp."mainTaxId"
	LEFT JOIN public."QuotationProductTax" tp ON tp."quotationProductId" = qp."id" and tp."chargeAndTaxId" = qp."mainTaxId";

	INSERT INTO CotizacionServicios_TipoProv(
		cd_Cotizacion,
		cd_CotizacionServicios,
		cd_TipoProveedores,
		ds_TipoProveedores,
		cd_proveedores,
		ds_proveedores
	)
	SELECT 
		'Q' || LPAD(qp."quotationId"::text, 7, '0') as cd_Cotizacion, 
		'Q' || LPAD(qp."id"::text, 7, '0') as cd_CotizacionServicios,
		'HTL' as cd_TipoProveedores,
		'HOTEL' as ds_TipoProveedores,
		COALESCE(pre."code",'') as cd_proveedores,
		COALESCE(pre."name",'') as ds_proveedores
	FROM public."QuotationProduct" qp
	JOIN Cotizacion q ON qp."quotationId" = q.orig_id_ref
	LEFT JOIN public."Prestadora" pre ON pre."id" = qp."prestadoraId";

	-- Poblar formas de pago por servicio desde QuotationProductPayment
	INSERT INTO CotizacionServiciosFormasPago(
		cd_Cotizacion,
		cd_CotizacionServicios,
		cd_codigo,
		ds_FPnm,
		bl_FPrepresenta,
		ds_tcnumber,
		ds_tcvoucher,
		ds_referencia,
		am_valor,
		ds_tcexp,
		am_valor_ME,
		ds_tcautorizacion
	)
	SELECT
		cs.cd_Cotizacion,
		cs.cd_Consecutivo_VARiablesAdicionales AS cd_CotizacionServicios,
		COALESCE(p.code,'') AS cd_codigo,
		COALESCE(qpmt."paymentMethod", '') AS ds_FPnm,
		B'0' AS bl_FPrepresenta,
		COALESCE(qpmt."cardNumber", '') AS ds_tcnumber,
		COALESCE(qpmt."voucher", '') AS ds_tcvoucher,
		COALESCE(qpmt."reference", '') AS ds_referencia,
		COALESCE(qpmt."amount", 0) AS am_valor,
		COALESCE(qpmt."expirationDate", '') AS ds_tcexp,
		0 AS am_valor_ME,
		COALESCE(qpmt."authorizationCode", '') AS ds_tcautorizacion
	FROM CotizacionServicios cs
	JOIN public."QuotationProductPayment" qpmt ON qpmt."quotationProductId" = cs.orig_id_ref
	LEFT JOIN public."Payment" p ON LOWER(p.name)=LOWER(qpmt."paymentMethod")  
	WHERE qpmt."paymentMethod" IS NOT NULL AND qpmt."paymentMethod" <> '';

    -- 5. Generar XML
    SELECT xmlroot(
        xmlelement(name "Cotizaciones",
            xmlagg(
                xmlelement(name "Cotizacion",
                    xmlforest(
                        q.cd_sucursal, q.cd_implante, q.cd_consecutivo, q.cd_usuario,
                        q.dt_fechacont, q.dt_fecha, q.cd_usuarioAct, q.dt_fechaAct,
                        q.cd_tercero_codigo, q.ds_tercero_nombre, q.cd_cliente_codigo,
                        q.ds_cliente_nombre, q.ds_cliente_dir, q.ds_cliente_ciudad,
                        q.ds_cliente_tel, q.ds_cliente_dirdesp, q.ds_cliente_email,
                        q.ds_cliente_contacto, q.ds_cliente_contacto_email, q.cd_monedas_IATA,
                        q.cd_vendedor, q.cd_tiqueteador, q.bn_anexo, q.am_tcambio,
                        q.am_tcambiousd, q.cd_cencosto, q.ds_observacion, q.ds_Campo_libre1,
                        q.ds_Campo_libre2, q.cd_tipoventa, q.in_estado, q.dt_vence,
                        q.cd_Etapa, q.ds_seguimiento_etapa, q.bl_ManejaOpciones,
                        q.in_NumeroOpciones, q.bl_CerrarCotizacion, q.in_OpcionSeleccionada,
                        q.bl_grupos, q.gk_sabre, q.cd_Especialista, q.cd_TipoFormaPagoProveedor,
                        q.cd_MedioReservacion, q.bl_bloqueada, q.cd_usuario_Bloqueo,
                        q.ds_AlertaSolicitud, q.bl_comisiona, q.ds_FormaDePago, q.ds_records,
                        q.bl_entregadoCliente, q.dt_entregadoCliente, q.id_sys_entidades,
                        q.cd_MonedaPagoDestino, q.cd_FormaPagoDestino, q.ds_DocumentoPagoDestino,
                        q.dt_CheckInPagoDestino, q.dt_CheckOutPagoDestino, q.bl_fechaPagoDestino,
                        q.ds_hotelTieneTiquete, q.ds_GDS, q.cd_Evento
                    ),
                    (
                        SELECT xmlagg(
                            xmlelement(name "CotizacionServicios",
                                xmlforest(
                                    s.cd_TiposConceptFac, s.cd_ConceptoFacturacion, s.cd_TiposServicio,
                                    s.cd_Cotizacion, s.cd_fac_factura, s.cd_fac_remision,
                                    s.cd_proveedores, s.ds_tiposervnm, s.cd_prov_hotel,
                                    s.cd_prov_car, s.cd_prov_air, s.ds_destino, s.ds_servicio,
                                    s.ds_descrip, s.ds_paxname, s.ds_paxape, s.cd_paxtype,
                                    s.in_nacionalidad, s.cd_voucher, s.in_cantpax, s.dt_llegada,
                                    s.dt_salida, s.cd_cencosto, s.cd_auxiliar, s.cd_item,
                                    s.am_valorprov, s.cd_monedaprov, s.ds_InfoAdicional,
                                    s.cd_carrental, s.cd_hoteles, s.bl_anulado, s.cd_tiquete,
                                    s.cd_fuente_anul, s.cd_serie_anul, s.cd_consecutivo_anul,
                                    s.cd_usuario_anul, s.cd_sucursal_anul, s.cd_implante_anul,
                                    s.am_basecomisionable, s.am_porcomision, s.cd_voucherPrefijo,
                                    s.bl_notdomicilionacional, s.Valor_Comision, s.Valor_Recaudo,
                                    s.dias_recaudo, s.ds_paxClasificacion, s.cd_tipoplan,
                                    s.cd_acomodacion, s.in_dias, s.in_noches, s.ds_records,
                                    s.cd_GrConcepto, s.in_diasSrv, s.in_nochesSrv, s.cd_Especialista,
                                    s.am_porcentaje_descuento, s.am_valor_descuento,
                                    s.ds_motivo_descuento, s.cd_cargosdesc_descuento,
                                    s.in_NumeroOpcion, s.dt_FechaSalidaSrv, s.dt_FechaLlegadaSrv,
                                    s.cd_localizador, s.cd_voucherpax, s.am_basecomisionableprov,
                                    s.am_porcomisionprov, s.cd_NumeFac, s.dt_VenceFac,
                                    s.cd_AcomodacionSrv, s.cd_TipoPlanSrv, s.in_habitaciones,
                                    s.in_habitacionesSrv, s.cd_Consecutivo_VARiablesAdicionales,
                                    s.cd_confirmacion, s.ds_confirmadopor, s.cd_paxidentificacion,
                                    s.bl_politicaCancelacion, s.dt_politicaCancelacion,
                                    s.cd_tipoHabitacionacion, s.cd_fac_facturaComision,
                                    s.cd_fac_remisionComision, s.cd_TarjetaAsistencia,
                                    s.cd_Regiones, s.Iden_GDS, s.id_sys_entidades,
                                    s.ds_TipoAuto, s.ds_Origen, s.ds_DirOrigen, s.ds_DirDestino, s.ds_TipoTarifa,
                                    s.am_ValorUSD, s.ds_NoVuelo, s.ds_Vehiculo, s.ds_Placa,
                                    s.ds_CategoriaVehiculo, s.ds_NombreConductor, s.ds_telefono,
                                    s.ds_IdiomaConductor, s.cd_MonedaSrv, s.cd_TipoServicio,
                                    s.cd_Aerolinea, s.in_EdadPax, s.am_PorFacParcial, s.ds_GDS,
                                    s.dt_fechaficheroBBVA, s.bl_tiquete, s.am_basedescuento,
                                    s.am_pordescuento, s.cd_CotizacionServicios_Depende
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CotizacionServicios_PaxAdicional",
                                            xmlforest(
                                                p.cd_Cotizacion, p.cd_CotizacionServicios, p.ds_paxape,
                                                p.ds_paxname, p.ds_paxprefix, p.ds_paxClasificacion,
                                                p.cd_voucherpax, p.cd_paxidentificacion, p.in_edad,
                                                p.cd_tiquete
                                            )
                                        )
                                    )
                                    FROM CotizacionServicios_PaxAdicional p
                                    WHERE p.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CotizacionServicios_VariableAdicional",
                                            xmlforest(
                                                v.cd_Cotizacion, v.cd_CotizacionServicios, v.ds_maestro,
                                                v.ds_VariableAdicional, v.ds_valor, v.cd_codigo
                                            )
                                        )
                                    )
                                    FROM CotizacionServicios_VariableAdicional v
                                    WHERE v.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CotizacionCargos",
                                            xmlforest(
                                                cr.cd_CotizacionServicios, cr.cd_cargosdesc,
                                                cr.ds_cargonm, cr.bl_noshow, cr.am_contado,
                                                cr.am_credito, cr.am_valor, cr.am_contado_ME,
                                                cr.am_credito_ME, cr.am_valor_ME,
												cr.orig_id_ref::text AS cd_CotizacionCargos,
												cr.cd_Cotizacion as cd_Cotizacion 
                                            )
                                        )
                                    )
                                    FROM CotizacionCargos cr
                                    WHERE cr.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
                                ),
                                (
                                    SELECT xmlagg(
                                        xmlelement(name "CotizacionImpuestos",
                                            xmlforest(
                                                imp.cd_CotizacionServicios, imp.cd_CotizacionCargos, imp.cd_ImpRet,
                                                imp.ds_Impas, imp.cd_impcta, imp.am_porcentaje,
                                                imp.bl_contabilizar, imp.am_contado,
                                                imp.am_credito, imp.am_valor, imp.am_contado_ME,
                                                imp.am_credito_ME, imp.am_valor_ME,
												imp.cd_CotizacionImpuestos AS cd_CotizacionImpuestos,
												imp.cd_Cotizacion as cd_Cotizacion 
                                            )
                                        )
                                    )
                                    FROM CotizacionImpuestos imp
                                    WHERE imp.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
                                ),
								(
									SELECT xmlagg(
                                        xmlelement(name "Fac_Servicios_TiposFacturacionHoteles",
                                            xmlforest(
													TF.cd_Cotizacion as cd_Cotizacion,
													TF.cd_CotizacionServicios as cd_CotizacionServicios,
													TF.cd_TiposFacturacionHoteles as cd_TiposFacturacionHoteles,
													TF.cd_cargosdesc as cd_cargosdesc,
													TF.in_cantidad as in_cantidad,
													TF.am_contado as am_contado,
													TF.am_credito as am_credito,
													TF.am_valor as am_valor,
													TF.ds_cargonm as ds_cargonm
											)
                                        )
                                    )				
									FROM Fac_Servicios_TiposFacturacionHoteles TF
									WHERE TF.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
								),
								(
									SELECT xmlagg(
                                        xmlelement(name "CotizacionServicios_TipoProv",
                                            xmlforest(
												PRE.cd_Cotizacion as cd_Cotizacion,
												PRE.cd_CotizacionServicios as cd_CotizacionServicios,
												PRE.cd_TipoProveedores as cd_TipoProveedores,
												PRE.ds_TipoProveedores as ds_TipoProveedores,
												PRE.cd_proveedores as cd_proveedores,
												PRE.ds_proveedores as ds_proveedores
											)
                                        )
                                    )				
									FROM CotizacionServicios_TipoProv PRE
									WHERE PRE.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales			
								),
								(
									SELECT xmlagg(
										xmlelement(name "CotizacionServiciosFormasPago",
											xmlforest(
												FP.cd_Cotizacion AS cd_Cotizacion,
												FP.cd_CotizacionServicios AS cd_CotizacionServicios,
												FP.cd_codigo AS cd_codigo,
												FP.ds_FPnm AS ds_FPnm,
												FP.bl_FPrepresenta::int AS bl_FPrepresenta,
												FP.ds_tcnumber AS ds_tcnumber,
												FP.ds_tcvoucher AS ds_tcvoucher,
												FP.ds_referencia AS ds_referencia,
												FP.am_valor AS am_valor,
												FP.ds_tcexp AS ds_tcexp,
												FP.am_valor_ME AS am_valor_ME,
												FP.ds_tcautorizacion AS ds_tcautorizacion
											)
										)
									)
									FROM CotizacionServiciosFormasPago FP
									WHERE FP.cd_CotizacionServicios = s.cd_Consecutivo_VARiablesAdicionales
								)
                            )
                        )
                        FROM CotizacionServicios s
                        WHERE s.cd_Cotizacion = q.cd_consecutivo
                    )
                )
            )
        ),
        version '1.0', standalone yes
    )::text INTO v_xml
    FROM Cotizacion q;

    -- 6. Resultado Final
    mensaje_resultado := coalesce(v_xml, '<?xml version="1.0" standalone="yes"?><Cotizaciones />');

EXCEPTION
    WHEN OTHERS THEN
	
		-- 1. Capturar los diagnósticos del error
        GET STACKED DIAGNOSTICS 
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_context = PG_EXCEPTION_CONTEXT;

        -- 2. Extraer la línea del texto del contexto (usando Regex)
		v_line :=substring(v_context from 'line ([0-9]+)')::TEXT;
	

        mensaje_resultado := format('ERROR: %s | EN LÍNEA: %s | ESTADO: %s', v_msg, v_line, v_state);
END;
$$;


--
-- Name: spimplantactualizar(integer, text, text, bytea, bytea, jsonb, text, integer, integer, bytea, jsonb, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimplantactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_branch_id integer, IN p_resolution_id integer DEFAULT NULL::integer, IN p_invoice_template bytea DEFAULT NULL::bytea, IN p_invoice_template_config jsonb DEFAULT NULL::jsonb, IN p_invoice_html_template text DEFAULT NULL::text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Implant" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Implant con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."Implant"
    SET "code" = p_code,
        "name" = p_name,
        "logo" = COALESCE(p_logo, "logo"),
        "template" = COALESCE(p_template, "template"),
        "templateConfig" = COALESCE(p_template_config, "templateConfig"),
        "htmlTemplate" = COALESCE(p_html_template, "htmlTemplate"),
        "branchId" = p_branch_id,
        "resolutionId" = p_resolution_id,
        "invoiceTemplate" = COALESCE(p_invoice_template, "invoiceTemplate"),
        "invoiceTemplateConfig" = COALESCE(p_invoice_template_config, "invoiceTemplateConfig"),
        "invoiceHtmlTemplate" = COALESCE(p_invoice_html_template, "invoiceHtmlTemplate"),
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Implant actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spimplantcrear(text, text, bytea, bytea, jsonb, text, integer, integer, bytea, jsonb, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimplantcrear(IN p_code text, IN p_name text, IN p_logo bytea, IN p_template bytea, IN p_template_config jsonb, IN p_html_template text, IN p_branch_id integer, IN p_resolution_id integer DEFAULT NULL::integer, IN p_invoice_template bytea DEFAULT NULL::bytea, IN p_invoice_template_config jsonb DEFAULT NULL::jsonb, IN p_invoice_html_template text DEFAULT NULL::text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_implant_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Implant" (
        "code", "name", "logo", "template", "templateConfig", "htmlTemplate", "branchId",
        "resolutionId", "invoiceTemplate", "invoiceTemplateConfig", "invoiceHtmlTemplate", "isActive"
    )
    VALUES (
        p_code, p_name, p_logo, p_template, p_template_config, p_html_template, p_branch_id,
        p_resolution_id, p_invoice_template, p_invoice_template_config, p_invoice_html_template, COALESCE(p_is_active, true)
    )
    RETURNING id INTO p_implant_id;

    p_mensaje_resultado := 'SUCCESS: Implant creado con ID ' || p_implant_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spimplanteliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimplanteliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Implant" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Implant con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."Implant" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Implant eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spimpuestoactualizar(integer, text, text, text, text, numeric, boolean, integer, jsonb, integer, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimpuestoactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_type text, IN p_value_type text, IN p_value numeric, IN p_is_editable boolean, IN p_orden integer DEFAULT 0, IN p_product_ids jsonb DEFAULT '[]'::jsonb, IN p_target_tax_id integer DEFAULT NULL::integer, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."ChargeAndTax" SET
        "code" = p_code,
        "name" = p_name,
        "type" = p_type,
        "valueType" = p_value_type,
        "value" = p_value,
        "isEditable" = p_is_editable,
        "orden" = COALESCE(p_orden, 0),
        "productIds" = COALESCE(p_product_ids, '[]'::jsonb),
        "targetTaxId" = p_target_tax_id,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spimpuestocrear(text, text, text, text, numeric, boolean, integer, jsonb, integer, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimpuestocrear(IN p_code text, IN p_name text, IN p_type text, IN p_value_type text, IN p_value numeric, IN p_is_editable boolean, IN p_orden integer DEFAULT 0, IN p_product_ids jsonb DEFAULT '[]'::jsonb, IN p_target_tax_id integer DEFAULT NULL::integer, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_tax_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "orden", "productIds", "targetTaxId", "isActive")
    VALUES (p_code, p_name, p_type, p_value_type, p_value, p_is_editable, COALESCE(p_orden, 0), COALESCE(p_product_ids, '[]'::jsonb), p_target_tax_id, COALESCE(p_is_active, true))
    RETURNING id INTO p_tax_id;

    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto creado con ID ' || p_tax_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spimpuestoeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spimpuestoeliminar(IN p_id integer, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT name INTO v_name FROM public."ChargeAndTax" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El cargo o impuesto no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."QuotationProductTax" WHERE "chargeAndTaxId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."InvoicesProductTax" WHERE "chargeAndTaxId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."ComboProductTax" WHERE "chargeAndTaxId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el cargo o impuesto "' || v_name || '" porque ya se encuentra registrado en ' || v_count || ' transacción(es) del sistema. Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."ChargeAndTax" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Cargo/Impuesto eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spinterfaceamadeus(text, text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinterfaceamadeus(IN p_op text, IN p_booking text, IN p_file text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    -- Variables generales de control
    v_line TEXT;
    v_lines TEXT[];
    v_state INTEGER := 0;
    
    -- Variables para la tabla BookingGDS
    v_code VARCHAR(10);
    v_type VARCHAR(10);
    v_blanch VARCHAR(25) := 'BOG';
    v_implant VARCHAR(25);
    v_external BOOLEAN := false;
    v_date TIMESTAMP;
    v_currency VARCHAR(3) := 'COP';
    v_exchangeRate DOUBLE PRECISION := 1.0;
    v_tiquetPrinter VARCHAR(25);
    v_seller VARCHAR(25);
    v_client VARCHAR(50);
    v_typetransaction VARCHAR(25) := '1';
    v_iata VARCHAR(25);
    v_description TEXT;
    v_observation TEXT;

    -- Variables temporales auxiliares
    v_nacionalidad INTEGER := 1;
    v_centrocosto VARCHAR(50);
    v_solicita VARCHAR(200);
    v_over VARCHAR(25);
    v_evento VARCHAR(250);
    v_highfare NUMERIC := 0;
    v_lowfare NUMERIC := 0;
    v_fare NUMERIC := 0;
    v_reasoncode VARCHAR(10);
    v_pax_cc VARCHAR(20);
    v_lapsoviaje VARCHAR(50);

    v_facturador VARCHAR(6);
    v_aerolinea_vende VARCHAR(10) := 'AV';
    v_provider_matched VARCHAR(50);
    v_tkt VARCHAR(20);
    
    -- Colecciones (Itinerarios, Pasajeros, Taxes, EMD, Pagos)
    v_iti_origenes TEXT[] := '{}';
    v_iti_destinos TEXT[] := '{}';
    v_iti_vuelos TEXT[] := '{}';
    v_iti_clases TEXT[] := '{}';
    v_iti_aerolineas TEXT[] := '{}';
    v_iti_farebasis TEXT[] := '{}';
    v_iti_fechas_llegada TIMESTAMP[] := '{}';
    v_iti_fechas_salida TIMESTAMP[] := '{}';

    v_pax_nombres TEXT[] := '{}';
    v_pax_apellidos TEXT[] := '{}';
    v_pax_prefixs TEXT[] := '{}';
    v_pax_tiquetes TEXT[] := '{}';
    v_pax_idx INTEGER := 0;

    v_tax_codes TEXT[] := '{}';
    v_tax_vals NUMERIC[] := '{}';
    v_tax_parsed BOOLEAN := false;
    v_id_master_chargeandtax INTEGER;
    v_raw_tax_code TEXT;
    v_equiv_tax_code TEXT;
    v_tax_exists_idx INTEGER;

    v_emd_codigos TEXT[] := '{}';
    v_emd_descripciones TEXT[] := '{}';
    v_emd_totales NUMERIC[] := '{}';

    v_pay_tipos TEXT[] := '{}';
    v_pay_tarjetas TEXT[] := '{}';
    v_pay_montos NUMERIC[] := '{}';
    v_pay_numbers TEXT[] := '{}';
    v_pay_expiries TEXT[] := '{}';
    v_pay_approvals TEXT[] := '{}';

    -- IDs de inserción
    v_booking_gds_id INTEGER;
    v_booking_product_gds_id INTEGER;
    v_booking_product_emd_id INTEGER;
    
    -- Variables para Tarifas
    v_am_tarifa NUMERIC := 0;
    v_am_tarifa_base NUMERIC := 0;
    v_am_impuestos NUMERIC := 0;
    v_am_otros NUMERIC := 0;
    v_am_tarifalocal NUMERIC := 0;
    v_am_total NUMERIC := 0;
    v_existing_booking TEXT;

    v_sub_line TEXT;
    v_i INTEGER;
    v_j INTEGER;

    v_parts TEXT[];
    v_item TEXT;
    v_clean_str TEXT;
    v_match TEXT[];
    v_val_monto NUMERIC;
BEGIN

    -- Obtener ID del Maestro ChargeAndTax para equivalencias
    SELECT id INTO v_id_master_chargeandtax FROM public."Master" WHERE code = 'ChargeAndTax' LIMIT 1;

    -- 1. Separar el archivo por saltos de línea
    v_lines := string_to_array(p_Booking, E'\n');
    
    -- Estado de la reserva
    IF p_Booking LIKE '%ENDX%' OR p_Booking LIKE '%END%' OR p_Booking LIKE '%CHD%' THEN
        v_state := 1;
    ELSE
        v_state := 0;
        RAISE EXCEPTION 'Reserva no confirmada: %', p_file;
    END IF;

    -- ==============================================================
    -- LECTURA ÚNICA DEL ARCHIVO: Extracción de datos y colecciones
    -- ==============================================================
    FOREACH v_line IN ARRAY v_lines
    LOOP
        v_line := rtrim(v_line, E'\r');
        
        -- D- Fechas (D-260716;260804...)
        IF starts_with(v_line, 'D-') THEN
            IF length(v_line) >= 14 THEN
                BEGIN
                    v_date := to_timestamp(substring(v_line from 9 for 6), 'YYMMDD');
                EXCEPTION WHEN OTHERS THEN
                    v_date := CURRENT_TIMESTAMP;
                END;
            END IF;

        -- Linea 3 (1A...;1A...;BOGZ12475;AIR) -> Sucursal y Pseudo
        ELSIF starts_with(v_line, '1A') AND position(';' in v_line) > 0 THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 3 THEN
                v_blanch := left(trim(v_parts[3]), 3);
                v_iata := trim(v_parts[3]);
            END IF;

        -- Linea MUC1A / M- / M (Localizador PNR)
        ELSIF (starts_with(v_line, 'MUC1A') OR starts_with(v_line, 'M-') OR starts_with(v_line, 'M')) AND v_code IS NULL THEN
            v_sub_line := trim(v_line);
            IF length(v_sub_line) >= 12 THEN
                v_code := trim(substring(v_sub_line from 7 for 6));
            END IF;
            
        -- A- Aerolínea Vendedora (Ej: A-LATAM AIRLINES COLOMBIA;4C)
        ELSIF starts_with(v_line, 'A-') THEN
            IF position(';' in v_line) > 0 THEN
                v_aerolinea_vende := LEFT(TRIM(split_part(v_line, ';', 2)), 2);
            ELSIF length(v_line) >= 12 THEN
                v_aerolinea_vende := LEFT(TRIM(substring(v_line from 11 for 2)), 2);
            END IF;
            IF v_aerolinea_vende IS NULL OR v_aerolinea_vende = '' THEN
                v_aerolinea_vende := 'AV';
            END IF;
            
        -- C- Agentes (Tiqueteador, Facturador, Vendedor)
        ELSIF starts_with(v_line, 'C-') THEN
            v_sub_line := substring(v_line from 3);
            v_parts := string_to_array(v_sub_line, '/');
            IF array_length(v_parts, 1) >= 1 THEN v_tiquetPrinter := trim(v_parts[1]); END IF;
            IF array_length(v_parts, 1) >= 2 THEN v_seller := left(trim(v_parts[2]), 6); END IF;

        -- H- ITINERARIOS
        ELSIF starts_with(v_line, 'H-') AND v_line NOT LIKE '%VOID%' THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 6 THEN
                DECLARE
                    v_origen VARCHAR(3);
                    v_destino VARCHAR(3);
                    v_aero VARCHAR(10);
                    v_vuelo VARCHAR(4);
                    v_clase VARCHAR(1);
                    v_f_str VARCHAR(100);
                    v_f_tokens TEXT[];
                    v_dia VARCHAR(2);
                    v_mes_str VARCHAR(3);
                    v_mes VARCHAR(2);
                    v_anio VARCHAR(4);
                    v_dep_h VARCHAR(2);
                    v_dep_m VARCHAR(2);
                    v_arr_h VARCHAR(2);
                    v_arr_m VARCHAR(2);
                    v_dt_token TEXT;
                    v_arr_token TEXT;
                    v_ts_salida TIMESTAMP;
                    v_ts_llegada TIMESTAMP;
                BEGIN
                    v_origen := right(trim(v_parts[2]), 3);
                    v_destino := trim(v_parts[4]);
                    
                    -- Normalizar espacios multiples en v_parts[6]
                    v_f_str := regexp_replace(trim(v_parts[6]), '\s+', ' ', 'g');
                    v_f_tokens := string_to_array(v_f_str, ' ');

                    IF array_length(v_f_tokens, 1) >= 6 THEN
                        v_aero := v_f_tokens[1];
                        v_vuelo := lpad(v_f_tokens[2], 4, '0');
                        v_clase := v_f_tokens[3];
                        v_dt_token := v_f_tokens[5]; -- ej: 15AUG0710
                        v_arr_token := v_f_tokens[6]; -- ej: 1130

                        IF length(v_dt_token) >= 9 THEN
                            v_dia := substring(v_dt_token from 1 for 2);
                            v_mes_str := upper(substring(v_dt_token from 3 for 3));
                            v_dep_h := substring(v_dt_token from 6 for 2);
                            v_dep_m := substring(v_dt_token from 8 for 2);
                        END IF;

                        IF length(v_arr_token) >= 4 THEN
                            v_arr_h := substring(v_arr_token from 1 for 2);
                            v_arr_m := substring(v_arr_token from 3 for 2);
                        END IF;

                        v_anio := to_char(COALESCE(v_date, CURRENT_TIMESTAMP), 'YYYY');
                        v_mes := CASE v_mes_str
                            WHEN 'JAN' THEN '01' WHEN 'FEB' THEN '02' WHEN 'MAR' THEN '03'
                            WHEN 'APR' THEN '04' WHEN 'MAY' THEN '05' WHEN 'JUN' THEN '06'
                            WHEN 'JUL' THEN '07' WHEN 'AUG' THEN '08' WHEN 'SEP' THEN '09'
                            WHEN 'OCT' THEN '10' WHEN 'NOV' THEN '11' WHEN 'DEC' THEN '12'
                            ELSE '01'
                        END;

                        BEGIN
                            v_ts_salida := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_dep_h, '00') || ':' || COALESCE(v_dep_m, '00'), 'YYYY-MM-DD HH24:MI');
                            v_ts_llegada := to_timestamp(v_anio || '-' || v_mes || '-' || v_dia || ' ' || COALESCE(v_arr_h, '00') || ':' || COALESCE(v_arr_m, '00'), 'YYYY-MM-DD HH24:MI');
                        EXCEPTION WHEN OTHERS THEN
                            v_ts_salida := COALESCE(v_date, CURRENT_TIMESTAMP);
                            v_ts_llegada := COALESCE(v_date, CURRENT_TIMESTAMP);
                        END;

                        v_iti_origenes := array_append(v_iti_origenes, v_origen);
                        v_iti_destinos := array_append(v_iti_destinos, v_destino);
                        v_iti_vuelos := array_append(v_iti_vuelos, v_vuelo);
                        v_iti_clases := array_append(v_iti_clases, v_clase);
                        v_iti_aerolineas := array_append(v_iti_aerolineas, v_aero);
                        IF array_length(v_f_tokens, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_f_tokens[7]));
                        ELSIF array_length(v_parts, 1) >= 7 THEN
                            v_iti_farebasis := array_append(v_iti_farebasis, trim(v_parts[7]));
                        ELSE
                            v_iti_farebasis := array_append(v_iti_farebasis, '');
                        END IF;
                        v_iti_fechas_salida := array_append(v_iti_fechas_salida, v_ts_salida);
                        v_iti_fechas_llegada := array_append(v_iti_fechas_llegada, v_ts_llegada);
                    END IF;
                END;
            END IF;

        -- I- PASAJEROS
        ELSIF starts_with(v_line, 'I-') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 2 THEN
                DECLARE
                    v_p_str TEXT;
                    v_pos_slash INT;
                    v_ape TEXT;
                    v_nom TEXT;
                    v_prefix VARCHAR(4) := 'MR';
                BEGIN
                    v_p_str := trim(v_parts[2]);
                    v_p_str := regexp_replace(v_p_str, '^[0-9]+', '');
                    v_pos_slash := position('/' in v_p_str);
                    IF v_pos_slash > 0 THEN
                        v_ape := substring(v_p_str from 1 for v_pos_slash - 1);
                        v_nom := substring(v_p_str from v_pos_slash + 1);
                        
                        IF v_nom LIKE '% MRS' OR v_nom LIKE '%MRS' THEN
                            v_prefix := 'MRS';
                            v_nom := trim(replace(v_nom, 'MRS', ''));
                        ELSIF v_nom LIKE '% MR' OR v_nom LIKE '%MR' THEN
                            v_prefix := 'MR';
                            v_nom := trim(replace(v_nom, 'MR', ''));
                        ELSIF v_nom LIKE '% MISS' OR v_nom LIKE '%MISS' THEN
                            v_prefix := 'MISS';
                            v_nom := trim(replace(v_nom, 'MISS', ''));
                        END IF;

                        v_pax_nombres := array_append(v_pax_nombres, trim(v_nom));
                        v_pax_apellidos := array_append(v_pax_apellidos, trim(v_ape));
                        v_pax_prefixs := array_append(v_pax_prefixs, v_prefix);
                        v_pax_tiquetes := array_append(v_pax_tiquetes, '');
                        v_pax_idx := v_pax_idx + 1;
                    END IF;
                END;
            END IF;

        -- T- TIQUETES (Extrae únicamente el número de 10 dígitos del tiquete)
        ELSIF starts_with(v_line, 'T-') THEN
            v_clean_str := substring(v_line from '[0-9]{10}');
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := split_part(split_part(v_line, ';', 1), '-', 3);
            END IF;
            IF v_clean_str IS NULL OR v_clean_str = '' THEN
                v_clean_str := regexp_replace(split_part(v_line, ';', 1), '^.*-', '');
            END IF;
            v_tkt := trim(v_clean_str);
            IF v_pax_idx > 0 THEN
                v_pax_tiquetes[v_pax_idx] := v_tkt;
            END IF;

        -- IMPUESTOS (KFTR, KFTF, KNTB, KFTB, KSTF, KFTI, KNTI, KSTI) - Tomar la primera linea encontrada y aplicar equivalencias (fallback a 'OTR')
        ELSIF (starts_with(v_line, 'KFTR') OR starts_with(v_line, 'KFTF') OR starts_with(v_line, 'KNTB') OR starts_with(v_line, 'KFTB') 
           OR starts_with(v_line, 'KSTF') OR starts_with(v_line, 'KFTI') OR starts_with(v_line, 'KNTI') OR starts_with(v_line, 'KSTI')) AND NOT v_tax_parsed THEN
            v_parts := string_to_array(v_line, ';');
            FOR v_i IN 2 .. COALESCE(array_length(v_parts, 1), 0) LOOP
                v_item := trim(v_parts[v_i]);
                IF length(v_item) >= 6 THEN
                    v_match := regexp_matches(v_item, '(COP|USD|EUR)([0-9.]+)\s+([A-Z0-9]{2})');
                    IF array_length(v_match, 1) >= 3 THEN
                        v_raw_tax_code := v_match[3];
                        v_val_monto := v_match[2]::NUMERIC;

                        -- Evaluar equivalencia en DB. Si no existe mapeo, retorna 'OTR'
                        IF v_id_master_chargeandtax IS NOT NULL THEN
                            v_equiv_tax_code := public."fnEquivalenceInterface"(2, v_id_master_chargeandtax, v_raw_tax_code);
                        ELSE
                            v_equiv_tax_code := v_raw_tax_code;
                        END IF;

                        -- Verificar si el código equivalente ya fue agregado para sumar su valor
                        v_tax_exists_idx := 0;
                        FOR v_j IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                            IF v_tax_codes[v_j] = v_equiv_tax_code THEN
                                v_tax_exists_idx := v_j;
                                EXIT;
                            END IF;
                        END LOOP;

                        IF v_tax_exists_idx > 0 THEN
                            v_tax_vals[v_tax_exists_idx] := v_tax_vals[v_tax_exists_idx] + v_val_monto;
                        ELSE
                            v_tax_codes := array_append(v_tax_codes, v_equiv_tax_code);
                            v_tax_vals := array_append(v_tax_vals, v_val_monto);
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            v_tax_parsed := true;

        -- TARIFAS (K-F, K-R, KN-F, KN-R, KS-F, KS-R, ATC, K-B)
        ELSIF starts_with(v_line, 'K-') OR starts_with(v_line, 'KN-') OR starts_with(v_line, 'KS-') OR starts_with(v_line, 'ATC') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 1 THEN
                v_currency := COALESCE(substring(v_parts[1] from '[A-Z]{3}'), 'COP');
            END IF;

            FOREACH v_item IN ARRAY v_parts
            LOOP
                IF v_item LIKE '%COP%' OR v_item LIKE '%USD%' THEN
                    BEGIN
                        v_val_monto := cast(regexp_replace(v_item, '[^0-9.]', '', 'g') as NUMERIC);
                        IF v_val_monto > v_am_tarifalocal THEN
                            v_am_tarifalocal := v_val_monto;
                        END IF;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END LOOP;
            v_am_total := v_am_tarifalocal;

        -- EMD - Electronic Miscellaneous Document
        ELSIF starts_with(v_line, 'EMD') THEN
            v_parts := string_to_array(v_line, ';');
            IF array_length(v_parts, 1) >= 20 THEN
                v_emd_codigos := array_append(v_emd_codigos, substring(v_parts[1] from 4));
                v_emd_descripciones := array_append(v_emd_descripciones, trim(v_parts[19]));
                BEGIN
                    v_emd_totales := array_append(v_emd_totales, cast(regexp_replace(v_parts[array_length(v_parts, 1)], '[^0-9.]', '', 'g') as NUMERIC));
                EXCEPTION WHEN OTHERS THEN 
                    v_emd_totales := array_append(v_emd_totales, 0.0); 
                END;
            END IF;

        -- FP - FORMAS DE PAGO (Ej: FPCCVI0000000000007023E01/0528/A076194;S3;P1-2)
        ELSIF starts_with(v_line, 'FP') THEN
            DECLARE
                v_fp_clean TEXT;
                v_fp_tipo TEXT := 'CA';
                v_fp_monto NUMERIC := 0;
                v_fp_card_type TEXT := '';
                v_fp_card_number TEXT := '';
                v_fp_exp TEXT := '__/__';
                v_fp_auth TEXT := '';
                v_already_exists BOOLEAN := false;
            BEGIN
                v_fp_clean := regexp_replace(v_line, '^FP-?', '');
                IF v_fp_clean LIKE 'CASH%' OR v_fp_clean LIKE 'CA%' THEN
                    v_fp_tipo := 'CA';
                ELSIF v_fp_clean LIKE 'CC%' OR v_fp_clean LIKE 'TC%' THEN
                    v_fp_tipo := 'CC';
                    -- Extraer franquicia (ej: VI, MC, AX, DC)
                    v_fp_card_type := substring(v_fp_clean from '^(?:CC|TC)([A-Za-z]{2})');
                    IF v_fp_card_type IS NULL OR v_fp_card_type = '' THEN
                        v_fp_card_type := substring(v_line from 'FPCC([A-Za-z]{2})');
                    END IF;
                    IF v_fp_card_type IS NULL THEN v_fp_card_type := ''; END IF;

                    v_fp_card_number := substring(v_line from 'FPCC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from 'CC([A-Za-z0-9]+?)(?:E[0-9]{2}|/|\s|;|$)');
                    END IF;
                    IF v_fp_card_number IS NULL OR v_fp_card_number = '' THEN
                        v_fp_card_number := substring(v_fp_clean from '([0-9]{13,16})');
                    END IF;

                    v_fp_exp := substring(v_line from '/([0-9]{4})/');
                    IF v_fp_exp IS NULL OR v_fp_exp = '' THEN v_fp_exp := '__/__'; END IF;

                    v_fp_auth := substring(v_line from '/([A-Z0-9]+)(?:;|\s|$)');
                    IF v_fp_auth IS NULL THEN v_fp_auth := ''; END IF;
                END IF;

                IF v_fp_clean LIKE '%COP%' OR v_fp_clean LIKE '%USD%' THEN
                    BEGIN
                        v_fp_monto := cast(substring(v_fp_clean from '[0-9.]+') as NUMERIC);
                    EXCEPTION WHEN OTHERS THEN v_fp_monto := v_am_total; END;
                ELSE
                    v_fp_monto := COALESCE(v_am_total, 0);
                END IF;

                -- Prevenir duplicar la misma forma de pago registrada en múltiples líneas del archivo
                FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                    IF v_pay_tipos[v_i] = v_fp_tipo AND COALESCE(v_pay_numbers[v_i], '') = COALESCE(v_fp_card_number, '') THEN
                        v_already_exists := true;
                        EXIT;
                    END IF;
                END LOOP;

                IF NOT v_already_exists THEN
                    v_pay_tipos := array_append(v_pay_tipos, v_fp_tipo);
                    v_pay_tarjetas := array_append(v_pay_tarjetas, COALESCE(v_fp_card_type, ''));
                    v_pay_montos := array_append(v_pay_montos, v_fp_monto);
                    v_pay_numbers := array_append(v_pay_numbers, COALESCE(v_fp_card_number, ''));
                    v_pay_expiries := array_append(v_pay_expiries, v_fp_exp);
                    v_pay_approvals := array_append(v_pay_approvals, COALESCE(v_fp_auth, ''));
                END IF;
            END;

        -- OTROS REMARKS
        ELSIF v_line LIKE '%CENTRO COSTO%' THEN
            v_centrocosto := left(substring(v_line from position('CENTRO COSTO' in v_line) + 13), 50);
        ELSIF v_line LIKE '%SOLICITA%' THEN
            v_solicita := left(substring(v_line from position('SOLICITA' in v_line) + 9), 200);
        ELSIF v_line LIKE '%RM*NC-' AND v_client IS NULL THEN
            v_client := trim(split_part(v_line, '-', 2));
        END IF;

    END LOOP;

    -- Extracción dinámica de parámetros según reglas de la interfaz Amadeus (id_interfaces = 2) y resolución de equivalencias
    DECLARE
        v_dyn_val TEXT;
        v_id_master_client INTEGER;
        v_id_master_seller INTEGER;
        v_id_master_tp INTEGER;
        v_id_master_branch INTEGER;
        v_id_master_implant INTEGER;
        v_resolved_client TEXT;
        v_resolved_seller TEXT;
        v_resolved_tp TEXT;
        v_resolved_branch TEXT;
        v_resolved_implant TEXT;
    BEGIN
        SELECT id INTO v_id_master_client FROM public."Master" WHERE UPPER(code) = 'CLIENT' LIMIT 1;
        SELECT id INTO v_id_master_seller FROM public."Master" WHERE UPPER(code) = 'SELLER' LIMIT 1;
        SELECT id INTO v_id_master_tp FROM public."Master" WHERE UPPER(code) = 'TICKETPRINTER' LIMIT 1;
        SELECT id INTO v_id_master_branch FROM public."Master" WHERE UPPER(code) = 'BRANCH' LIMIT 1;
        SELECT id INTO v_id_master_implant FROM public."Master" WHERE UPPER(code) = 'IMPLANT' LIMIT 1;

        -- 1. CLIENT
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Client', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_client := v_dyn_val; END IF;
        IF v_client IS NOT NULL AND v_client <> '' THEN
            IF v_id_master_client IS NOT NULL THEN
                v_client := public."fnEquivalenceInterface"(2, v_id_master_client, v_client);
            END IF;
            SELECT document INTO v_resolved_client FROM public."Client" 
            WHERE document = v_client OR UPPER(name) ILIKE '%' || UPPER(v_client) || '%' OR CAST(id AS TEXT) = v_client LIMIT 1;
            IF v_resolved_client IS NOT NULL THEN v_client := v_resolved_client; END IF;
        END IF;

        -- 2. SELLER (Comprobar RM*VEN- o RM*VE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Seller', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_seller := v_dyn_val; END IF;
        IF v_seller IS NULL OR v_seller = '' THEN
            v_seller := substring(p_Booking from 'RM\*VEN-([A-Za-z0-9]+)');
            IF v_seller IS NULL OR v_seller = '' THEN
                v_seller := substring(p_Booking from 'RM\*VE-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_seller IS NOT NULL AND v_seller <> '' THEN
            IF v_id_master_seller IS NOT NULL THEN
                v_seller := public."fnEquivalenceInterface"(2, v_id_master_seller, v_seller);
            END IF;
            SELECT code INTO v_resolved_seller FROM public."Seller" 
            WHERE UPPER(code) = UPPER(v_seller) OR UPPER(name) ILIKE '%' || UPPER(v_seller) || '%' OR CAST(id AS TEXT) = v_seller LIMIT 1;
            IF v_resolved_seller IS NOT NULL THEN v_seller := v_resolved_seller; END IF;
        END IF;

        -- 3. TICKETPRINTER (Comprobar RM*TK- o RM*ASE-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'TicketPrinter', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_tiquetPrinter := v_dyn_val; END IF;
        IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
            v_tiquetPrinter := substring(p_Booking from 'RM\*ASE-([A-Za-z0-9]+)');
            IF v_tiquetPrinter IS NULL OR v_tiquetPrinter = '' THEN
                v_tiquetPrinter := substring(p_Booking from 'RM\*TK-([A-Za-z0-9]+)');
            END IF;
        END IF;
        IF v_tiquetPrinter IS NOT NULL AND v_tiquetPrinter <> '' THEN
            IF v_id_master_tp IS NOT NULL THEN
                v_tiquetPrinter := public."fnEquivalenceInterface"(2, v_id_master_tp, v_tiquetPrinter);
            END IF;
            SELECT code INTO v_resolved_tp FROM public."TicketPrinter" 
            WHERE UPPER(code) = UPPER(v_tiquetPrinter) OR UPPER(name) ILIKE '%' || UPPER(v_tiquetPrinter) || '%' OR CAST(id AS TEXT) = v_tiquetPrinter LIMIT 1;
            IF v_resolved_tp IS NOT NULL THEN v_tiquetPrinter := v_resolved_tp; END IF;
        END IF;

        -- 4. BRANCH
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Branch', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_blanch := v_dyn_val; END IF;
        IF v_blanch IS NOT NULL AND v_blanch <> '' THEN
            IF v_id_master_branch IS NOT NULL THEN
                v_blanch := public."fnEquivalenceInterface"(2, v_id_master_branch, v_blanch);
            END IF;
            SELECT code INTO v_resolved_branch FROM public."Branch" 
            WHERE UPPER(code) = UPPER(v_blanch) OR UPPER(name) ILIKE '%' || UPPER(v_blanch) || '%' OR CAST(id AS TEXT) = v_blanch LIMIT 1;
            IF v_resolved_branch IS NOT NULL THEN v_blanch := v_resolved_branch; END IF;
        END IF;

        -- 5. IMPLANT (RM*IMP-)
        v_dyn_val := public."fnInterfaceExtractParamValue"(2, 'Implant', p_Booking);
        IF v_dyn_val IS NOT NULL AND v_dyn_val <> '' THEN v_implant := v_dyn_val; END IF;
        IF v_implant IS NULL OR v_implant = '' THEN
            v_implant := substring(p_Booking from 'RM\*IMP-([A-Za-z0-9]+)');
        END IF;
        IF v_implant IS NOT NULL AND v_implant <> '' THEN
            IF v_id_master_implant IS NOT NULL THEN
                v_implant := public."fnEquivalenceInterface"(2, v_id_master_implant, v_implant);
            END IF;
            SELECT code INTO v_resolved_implant FROM public."Implant" 
            WHERE UPPER(code) = UPPER(v_implant) OR UPPER(name) ILIKE '%' || UPPER(v_implant) || '%' OR CAST(id AS TEXT) = v_implant LIMIT 1;
            IF v_resolved_implant IS NOT NULL THEN v_implant := v_resolved_implant; END IF;
        END IF;
    END;

    -- ==============================================================
    -- VALIDACIÓN Y ASIGNACIÓN DE PROVEEDOR POR SIGLA DE AEROLÍNEA
    -- ==============================================================
    SELECT code INTO v_provider_matched
    FROM public."Provider"
    WHERE UPPER(sigla) = UPPER(v_aerolinea_vende) 
       OR UPPER(code) = UPPER(v_aerolinea_vende)
       OR UPPER("airlineCode") = UPPER(v_aerolinea_vende)
    LIMIT 1;

    -- ==============================================================
    -- INSERCIÓN EN TABLAS
    -- ==============================================================
    v_type := 'RES';
    v_description := COALESCE(v_evento, '') || ' ' || COALESCE(v_solicita, '');

    -- 1. Cabecera (Upsert y Verificación de Cambios)
    v_booking_gds_id := NULL;
    v_existing_booking := NULL;

    IF v_code IS NOT NULL AND v_code <> '' THEN
        SELECT id, "booking" INTO v_booking_gds_id, v_existing_booking 
        FROM public."BookingGDS" 
        WHERE "code" = v_code 
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NULL AND (v_tkt IS NOT NULL AND v_tkt <> '') THEN
        SELECT b."id", b."booking" INTO v_booking_gds_id, v_existing_booking
        FROM public."BookingGDS" b
        JOIN public."BookingProductGDS" bp ON bp."bookingId" = b."id"
        WHERE bp."code" = v_tkt
        LIMIT 1;
    END IF;

    IF v_booking_gds_id IS NOT NULL THEN
        -- Sobrescribir la reserva y reemplazar sus detalles
        UPDATE public."BookingGDS" SET
            "type" = COALESCE(v_type, 'RES'), 
            "blanch" = v_blanch, 
            "implant" = COALESCE(v_implant, ''), 
            "external" = v_external, 
            "gds" = 2, 
            "date" = COALESCE(v_date, CURRENT_TIMESTAMP), 
            "currency" = v_currency, 
            "exchangeRate" = v_exchangeRate, 
            "tiquetPrinter" = COALESCE(v_tiquetPrinter, ''), 
            "seller" = COALESCE(v_seller, ''), 
            "client" = COALESCE(v_client, ''), 
            "booking" = p_Booking, 
            "typetransaction" = v_typetransaction, 
            "iata" = COALESCE(v_iata, ''), 
            "description" = v_description, 
            "observation" = v_observation, 
            "state" = CAST(v_state AS VARCHAR)
        WHERE "id" = v_booking_gds_id;

        DELETE FROM public."BookingProductPaymentGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductTaxGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductPassangerGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductItineraryGDS" WHERE "bookingProductId" IN (SELECT id FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id);
        DELETE FROM public."BookingProductGDS" WHERE "bookingId" = v_booking_gds_id;
    ELSE
        INSERT INTO public."BookingGDS" (
            "code", "type", "blanch", "implant", "external", "gds", "date", 
            "currency", "exchangeRate", "tiquetPrinter", "seller", "client", 
            "booking", "typetransaction", "iata", "description", "observation", "state"
        ) VALUES (
            COALESCE(v_code, 'DESC'), 
            COALESCE(v_type, 'RES'), 
            v_blanch, 
            COALESCE(v_implant, ''), 
            v_external, 
            2, 
            COALESCE(v_date, CURRENT_TIMESTAMP), 
            v_currency, 
            v_exchangeRate, 
            COALESCE(v_tiquetPrinter, ''), 
            COALESCE(v_seller, ''), 
            COALESCE(v_client, ''), 
            p_Booking, 
            v_typetransaction, 
            COALESCE(v_iata, ''), 
            v_description, 
            v_observation, 
            CAST(v_state AS VARCHAR)
        ) RETURNING "id" INTO v_booking_gds_id;
    END IF;

    -- ==============================================================
    -- CREACIÓN DE PRODUCTOS (UN PRODUCTO POR CADA TIQUETE / PASAJERO)
    -- ==============================================================
    DECLARE
        v_num_pax INTEGER;
        v_num_prods INTEGER;
        v_pax_i INTEGER;
        v_prod_code TEXT;
        v_prod_price NUMERIC;
        v_prod_tax_base NUMERIC;
        v_prod_tax_val NUMERIC;
        v_prod_pay_val NUMERIC;
    BEGIN
        v_num_pax := GREATEST(COALESCE(array_length(v_pax_nombres, 1), 0), COALESCE(array_length(v_pax_tiquetes, 1), 0));
        v_num_prods := GREATEST(1, v_num_pax);

        FOR v_pax_i IN 1 .. v_num_prods LOOP
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_tiquetes, 1) AND v_pax_tiquetes[v_pax_i] IS NOT NULL AND v_pax_tiquetes[v_pax_i] <> '' THEN
                v_prod_code := v_pax_tiquetes[v_pax_i];
            ELSE
                v_prod_code := COALESCE(v_tkt, 'VUE');
            END IF;

            v_prod_price := v_am_total;

            -- 2. Producto Padre (Vuelo / Tiquete)
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_prod_code, 'flight', 'flight', v_aerolinea_vende, COALESCE(v_provider_matched, v_aerolinea_vende),
                1, v_prod_price, COALESCE(v_code, ''), v_nacionalidad, 'NUEVO', 'VUE'
            ) RETURNING "id" INTO v_booking_product_gds_id;

            -- 3. Detalle Itinerarios para este producto
            FOR v_i IN 1 .. COALESCE(array_length(v_iti_origenes, 1), 0) LOOP
                IF v_iti_origenes[v_i] IS NOT NULL THEN
                    INSERT INTO public."BookingProductItineraryGDS" (
                        "bookingProductId", "orden", "origin", "destination", "class", "checkInDate", 
                        "checkOutDate", "terminal", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_i, v_iti_origenes[v_i], v_iti_destinos[v_i], v_iti_clases[v_i], v_iti_fechas_salida[v_i], 
                        v_iti_fechas_llegada[v_i], v_iti_destinos[v_i], v_iti_aerolineas[v_i], COALESCE(v_iti_farebasis[v_i], ''), v_iti_vuelos[v_i], '', 0
                    );
                END IF;
            END LOOP;

            -- 4. Detalle Pasajero para este producto
            IF v_num_pax > 0 AND v_pax_i <= array_length(v_pax_nombres, 1) AND v_pax_nombres[v_pax_i] IS NOT NULL THEN
                INSERT INTO public."BookingProductPassangerGDS" (
                    "bookingProductId", "code", "firstnm", "lastnm", "prefix", "identification", "phone", "email"
                ) VALUES (
                    v_booking_product_gds_id, v_pax_i::TEXT, v_pax_nombres[v_pax_i], v_pax_apellidos[v_pax_i], v_pax_prefixs[v_pax_i], COALESCE(v_pax_tiquetes[v_pax_i], ''), '', ''
                );
            END IF;

            -- 5. Detalle Impuestos (Taxes) completo para este producto
            v_am_impuestos := 0;
            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_am_impuestos := v_am_impuestos + COALESCE(v_tax_vals[v_i], 0);
                END IF;
            END LOOP;

            v_prod_tax_base := GREATEST(0, v_prod_price - v_am_impuestos);

            IF v_prod_tax_base > 0 OR v_prod_price <> 0 THEN
                INSERT INTO public."BookingProductTaxGDS" (
                    "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                ) VALUES (
                    v_booking_product_gds_id, 'TAR', 'Tarifa', 'CHARGE', true, 0, v_prod_tax_base
                );
            END IF;

            FOR v_i IN 1 .. COALESCE(array_length(v_tax_codes, 1), 0) LOOP
                IF v_tax_codes[v_i] IS NOT NULL THEN
                    v_prod_tax_val := COALESCE(v_tax_vals[v_i], 0);
                    INSERT INTO public."BookingProductTaxGDS" (
                        "bookingProductId", "code", "name", "type", "ismain", "percentage", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, v_tax_codes[v_i], v_tax_codes[v_i], 'tax', false, 0, (v_prod_tax_val::DOUBLE PRECISION)
                    );
                END IF;
            END LOOP;

            -- 6. Formas de Pago proporcionales por tiquete para que la suma cuadre con el valor del tiquete
            FOR v_i IN 1 .. COALESCE(array_length(v_pay_tipos, 1), 0) LOOP
                IF v_pay_tipos[v_i] IS NOT NULL THEN
                    v_prod_pay_val := COALESCE(v_pay_montos[v_i], v_am_total);
                    INSERT INTO public."BookingProductPaymentGDS" (
                        "bookingProductId", "bookingProductFEEId", "code", "name", "type", "typecreditcard", 
                        "numbercreditcard", "vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
                        "bank", "square", "reference", "policy", "policyannex", "amount"
                    ) VALUES (
                        v_booking_product_gds_id, NULL, v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tipos[v_i], v_pay_tarjetas[v_i],
                        COALESCE(v_pay_numbers[v_i], ''), '', COALESCE(v_pay_expiries[v_i], '__/__'), COALESCE(v_pay_approvals[v_i], ''), 0,
                        '', '', '', '', '', v_prod_pay_val
                    );
                END IF;
            END LOOP;

            -- 7. Variables Adicionales Dinámicas para este producto
            DECLARE
                r_param RECORD;
                v_var_value TEXT;
                v_mv_code TEXT;
                v_mv_name TEXT;
            BEGIN
                FOR r_param IN 
                    SELECT "fieldCode", "fieldName"
                    FROM public."InterfaceExtractParam"
                    WHERE "interfaceId" = 2
                      AND "isActive" = TRUE
                      AND UPPER("fieldCode") NOT IN ('CLIENT', 'SELLER', 'TICKETPRINTER', 'BRANCH', 'IMPLANT')
                LOOP
                    v_var_value := public."fnInterfaceExtractParamValue"(2, r_param."fieldCode", p_Booking);
                    IF v_var_value IS NOT NULL AND v_var_value <> '' THEN
                        SELECT code, name INTO v_mv_code, v_mv_name
                        FROM public."MasterVariable"
                        WHERE UPPER(code) = UPPER(r_param."fieldCode") OR UPPER(name) = UPPER(r_param."fieldName")
                        LIMIT 1;

                        IF v_mv_code IS NULL THEN
                            v_mv_code := r_param."fieldCode";
                            v_mv_name := r_param."fieldName";
                        END IF;

                        INSERT INTO public."BookingProductVariableGDS" (
                            "bookingProductId", "code", "name", "value"
                        ) VALUES (
                            v_booking_product_gds_id, v_mv_code, v_mv_name, v_var_value
                        );
                    END IF;
                END LOOP;
            END;

        END LOOP;
    END;

    -- 8. Productos EMD
    FOR v_i IN 1 .. COALESCE(array_length(v_emd_codigos, 1), 0) LOOP
        IF v_emd_codigos[v_i] IS NOT NULL THEN
            INSERT INTO public."BookingProductGDS" (
                "bookingId", "code", "type", "description", "prestadoracode", "provider",
                "quantity", "price", "reservationCode", "inNationality", "state", "typeproduct"
            ) VALUES (
                v_booking_gds_id, v_emd_codigos[v_i], 'flight', COALESCE(v_emd_descripciones[v_i], ''), COALESCE(v_aerolinea_vende, ''), COALESCE(v_provider_matched, v_aerolinea_vende),
                1, COALESCE(v_emd_totales[v_i], 0), v_code, COALESCE(v_nacionalidad, 1), 'NUEVO', 'EMD'
            ) RETURNING "id" INTO v_booking_product_emd_id;
        END IF;
    END LOOP;

    RAISE NOTICE 'Amadeus Booking % successfully parsed and inserted.', v_code;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error processing Amadeus file: % - %', SQLSTATE, SQLERRM;
    ROLLBACK;
    RAISE;
END;
$_$;


--
-- Name: spinterfacefile(text, text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinterfacefile(IN op text, IN booking text, IN file text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    file_extension TEXT;
BEGIN
    file_extension := lower(substring(file from '\.[^\.]*$'));

    IF file_extension = '.fil' THEN
        CALL public.spinterfacesabre(op, booking, file);
    ELSE
        CALL public.spinterfaceamadeus(op, booking, file);
    END IF;
END;
$_$;


--
-- Name: spinterfacesabre(text, text, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinterfacesabre(IN p_op text, IN p_booking text, IN p_file text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public."spInterfaceSabre"(p_op, p_booking, p_file);
END;
$$;


--
-- Name: spinvoicesactualizar(integer, jsonb, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinvoicesactualizar(IN p_id integer, IN p_data jsonb, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_item RECORD;
    v_tax RECORD;
    v_pax RECORD;
    v_var RECORD;
    v_combo RECORD;
    v_payment RECORD;
    v_itinerary RECORD;
    v_invoice_product_id INT;
    v_real_product_id INT;
    v_existing_invoice_number TEXT;
    v_temp_msg TEXT;
    v_decimals INT;
BEGIN
    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM public."Invoices" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: La factura con ID ' || p_id || ' no existe.';
        RETURN;
    END IF;

    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La factura debe tener al menos un producto.';
        RETURN;
    END IF;

    -- Obtener decimales de la moneda
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    UPDATE public."Invoices" SET
        "clientId" = NULLIF(p_data->>'clientId', '')::INT,
        "currency" = p_data->>'currency',
        "exchangeRate" = NULLIF(p_data->>'exchangeRate', '')::FLOAT,
        "branchId" = NULLIF(p_data->>'branchId', '')::INT,
        "implantId" = NULLIF(p_data->>'implantId', '')::INT,
        "sellerId" = NULLIF(p_data->>'sellerId', '')::INT,
        "ticketPrinterId" = NULLIF(p_data->>'ticketPrinterId', '')::INT,
        "commissionPercentage" = NULLIF(p_data->>'commissionPercentage', '')::FLOAT,
        "chargesAndTaxes" = ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision,
        "totalAmount" = ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision,
        "state" = COALESCE(p_data->>'state', 'Nuevo'),
        "date" = CURRENT_TIMESTAMP,
        "fuente" = NULLIF(p_data->>'fuente', ''),
        "serie" = NULLIF(p_data->>'fuente', ''),
        "consecutivo" = NULLIF(p_data->>'consecutivo', '')
    WHERE id = p_id;

    DELETE FROM public."InvoicesProductCombo" WHERE "invoiceId" = p_id;
    FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
    LOOP
        INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId")
        VALUES (p_id, COALESCE(v_combo."comboId", v_combo.id));
    END LOOP;

    DELETE FROM public."InvoicesProductItinerary" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = p_id);
    DELETE FROM public."InvoicesProductPayment" WHERE "invoiceProductId" IN (SELECT id FROM public."InvoicesProduct" WHERE "invoiceId" = p_id);
    DELETE FROM public."InvoicesProduct" WHERE "invoiceId" = p_id;
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                      quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                      "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                      "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                      "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                      "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "inNationality" INT,
                      "servicios" TEXT, "itemDescription" TEXT, "itinerary" TEXT, "class" TEXT, "airline" TEXT, "ticketTypeId" TEXT, "payments" JSONB, "itinerariesItineraryList" JSONB
                  )
    LOOP
        -- 1. Lógica de Producto Al Vuelo
        IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL THEN
            SELECT id INTO v_real_product_id FROM public."Product" WHERE code = v_item."ticketCode";
            
            IF v_real_product_id IS NULL THEN
                CALL public.spProductoCrear(
                    v_item."ticketCode",
                    COALESCE(v_item."type", 'Tiquete'),
                    COALESCE(v_item."description", 'Tiquete ' || v_item."ticketCode"),
                    COALESCE(v_item.price, 0),
                    COALESCE(v_item.cost, 0),
                    NULL, 
                    COALESCE(v_item."serviceType", 'Aire'),
                    p_acting_user_id,
                    v_real_product_id,
                    v_temp_msg
                );
                IF v_temp_msg LIKE 'ERROR%' THEN
                    p_mensaje_resultado := v_temp_msg;
                    RETURN;
                END IF;
            END IF;
        ELSE
            v_real_product_id := v_item."productId";
        END IF;

        IF v_real_product_id IS NULL THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            RETURN;
        END IF;

        -- 2. Validación de Unicidad para Aire/Tiquete por número de tiquete (ticketCode)
        IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
            SELECT inv."internalNumber" INTO v_existing_invoice_number
            FROM public."InvoicesProduct" ip
            JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
            WHERE ip."ticketCode" = TRIM(v_item."ticketCode") AND inv.id <> p_id
            LIMIT 1;

            IF v_existing_invoice_number IS NOT NULL THEN
                p_mensaje_resultado := 'ERROR: El tiquete N° ' || TRIM(v_item."ticketCode") || ' ya está facturado en la factura ' || v_existing_invoice_number;
                RETURN;
            END IF;
        END IF;

        -- 3. Inserción de Producto
        INSERT INTO public."InvoicesProduct" (
            "invoiceId", "productId", "ticketCode", "quantity", "price", "cost", "providerId", "prestadoraId",
            "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
            "serviceType", "destination", "reservationCode", "sellerCommission", 
            "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
            "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
        ) VALUES (
            p_id, v_real_product_id, NULLIF(TRIM(v_item."ticketCode"), ''), v_item.quantity, 
            ROUND(v_item.price::numeric, v_decimals)::double precision, 
            ROUND(v_item.cost::numeric, v_decimals)::double precision, 
            NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
            CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
            CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
            v_item.nights, v_item."paxAdults", v_item."paxChildren",
            v_item."serviceType", v_item."destination", v_item."reservationCode", 
            ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
            ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
            NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
            v_item."servicios", COALESCE(v_item."itemDescription", v_item."description"), v_item."itinerary", v_item."class", v_item."airline", NULLIF(v_item."ticketTypeId", '')::INT
        ) RETURNING id INTO v_invoice_product_id;

        IF v_item.passengers IS NOT NULL THEN
            FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
            LOOP
                INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                VALUES (v_invoice_product_id, v_pax.name, v_pax.document);
            END LOOP;
        END IF;

        IF v_item."appliedTaxes" IS NOT NULL THEN
            FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
            LOOP
                INSERT INTO public."InvoicesProductTax" (
                    "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                )
                SELECT v_invoice_product_id, ct.id, ct.value, ct."valueType", 
                       ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                       CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                FROM public."ChargeAndTax" ct
                WHERE ct.id = v_tax."chargeAndTaxId";
            END LOOP;
        END IF;

        IF v_item.variables IS NOT NULL THEN
            FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
            LOOP
                INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                VALUES (v_invoice_product_id, v_var."masterVariableId", v_var.value);
            END LOOP;
        END IF;

        IF v_item.payments IS NOT NULL THEN
            FOR v_payment IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(amount FLOAT, "paymentMethod" TEXT, "reference" TEXT, "date" TEXT, "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT)
            LOOP
                INSERT INTO public."InvoicesProductPayment" ("invoiceProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
                VALUES (
                    v_invoice_product_id, 
                    ROUND(v_payment.amount::numeric, v_decimals)::double precision, 
                    v_payment."paymentMethod", v_payment.reference, 
                    CASE WHEN v_payment."date" IS NOT NULL AND v_payment."date" <> '' THEN v_payment."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END, 
                    v_payment."creditCardId", v_payment."cardNumber", v_payment."authorizationCode", v_payment."voucher", v_payment."expirationDate"
                );
            END LOOP;
        END IF;

        IF v_item."itinerariesItineraryList" IS NOT NULL THEN
            FOR v_itinerary IN SELECT * FROM jsonb_to_recordset(v_item."itinerariesItineraryList") AS x(origin TEXT, destination TEXT, class TEXT, "checkInDate" TEXT, "checkOutDate" TEXT, "prestadoraCode" TEXT, "farebasis" TEXT, "Numflight" TEXT, "Typeflight" TEXT, "amount" FLOAT, "co2" NUMERIC, orden INT)
            LOOP
                INSERT INTO public."InvoicesProductItinerary" ("invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount", "co2", "orden")
                VALUES (
                    v_invoice_product_id, v_itinerary.origin, v_itinerary.destination, v_itinerary.class, 
                    CASE WHEN v_itinerary."checkInDate" IS NOT NULL AND v_itinerary."checkInDate" <> '' THEN v_itinerary."checkInDate"::TIMESTAMP ELSE NULL END, 
                    CASE WHEN v_itinerary."checkOutDate" IS NOT NULL AND v_itinerary."checkOutDate" <> '' THEN v_itinerary."checkOutDate"::TIMESTAMP ELSE NULL END, 
                    COALESCE(v_itinerary."prestadoraCode", ''), COALESCE(v_itinerary."farebasis", ''), v_itinerary."Numflight", v_itinerary."Typeflight", 
                    ROUND(COALESCE(v_itinerary."amount", 0)::numeric, v_decimals)::double precision, 
                    v_itinerary."co2", v_itinerary.orden
                );
            END LOOP;
        END IF;

    END LOOP;

    -- Calcular y actualizar el totalAmount
    UPDATE public."Invoices"
    SET "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
        SELECT COALESCE(SUM(ipt."explicitAmount"), 0)
        FROM public."InvoicesProductTax" ipt
        JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
        WHERE ip."invoiceId" = p_id
    ))::numeric, v_decimals)::double precision
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Factura ' || p_id || ' actualizada correctamente.';

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spinvoicescrear(jsonb, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinvoicescrear(IN p_data jsonb, IN p_acting_user_id integer, INOUT p_invoice_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_internal_number TEXT;
    v_invoice_id INT;
    v_item RECORD;
    v_tax RECORD;
    v_pax RECORD;
    v_var RECORD;
    v_combo RECORD;
    v_payment RECORD;
    v_itinerary RECORD;
    v_invoice_product_id INT;
    v_real_product_id INT;
    v_existing_invoice_number TEXT;
    v_temp_msg TEXT;
    v_decimals INT;
    v_fuente TEXT;
    v_serie TEXT;
    v_consecutivo TEXT;
    v_consec_id INT;
    v_next_num BIGINT;
    v_billing_code TEXT;
    v_branch_id INT;
    v_implant_id INT;
    v_resolution_id INT;
    v_res RECORD;
    v_res_rec RECORD;
    v_consec_json JSONB;
    v_fuente_val TEXT;
    v_serie_val TEXT;
    v_consec_val TEXT;
    v_consec_num BIGINT;
BEGIN
    -- ----------------------------------------------------
    -- FASE 1: PRE-VALIDACIONES OBLIGATORIAS (Síncrona sin modificar BD)
    -- ----------------------------------------------------
    IF NULLIF(p_data->>'clientId', '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El campo Cliente es obligatorio.';
        RETURN;
    END IF;

    IF p_data->'items' IS NULL OR jsonb_array_length(p_data->'items') = 0 THEN
        p_mensaje_resultado := 'ERROR: La factura debe tener al menos un producto.';
        RETURN;
    END IF;

    v_branch_id := NULLIF(p_data->>'branchId', '')::INT;
    v_implant_id := NULLIF(p_data->>'implantId', '')::INT;

    -- Obtener decimales de la moneda
    v_decimals := public.fn_obtener_decimales_moneda(p_data->>'currency');

    v_resolution_id := NULLIF(p_data->>'resolutionId', '')::INT;

    v_internal_number := 'INV-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' || floor(random() * 1000)::text;

    v_fuente := NULLIF(p_data->>'fuente', '');
    v_serie := NULLIF(p_data->>'serie', '');
    v_consecutivo := NULLIF(p_data->>'consecutivo', '');

    -- Lógica de asignación de consecutivo automático desde SysConsecutivo si consecutivo es nulo o vacío
    IF v_consecutivo IS NULL THEN
        v_billing_code := COALESCE(
            NULLIF(p_data->>'codigo', ''), 
            NULLIF(p_data->>'codigoFacturacion', ''), 
            NULLIF(p_data->>'billingCode', ''), 
            v_fuente, 
            'FACT'
        );

        SELECT id, NULLIF(fuente, ''), NULLIF(serie, '') 
        INTO v_consec_id, v_fuente, v_serie
        FROM public."SysConsecutivo"
        WHERE LOWER(codigo) = LOWER(v_billing_code)
           OR (v_branch_id IS NOT NULL AND "branchId" = v_branch_id AND ("implantId" IS NULL OR "implantId" = v_implant_id))
        ORDER BY 
            (CASE WHEN LOWER(codigo) = LOWER(v_billing_code) THEN 1 ELSE 2 END),
            (CASE WHEN "implantId" IS NOT NULL THEN 1 WHEN "branchId" IS NOT NULL THEN 2 ELSE 3 END),
            id DESC
        LIMIT 1;

        IF v_consec_id IS NOT NULL THEN
            UPDATE public."SysConsecutivo"
            SET consecutivo = consecutivo + 1,
                "updatedAt" = CURRENT_TIMESTAMP
            WHERE id = v_consec_id
            RETURNING consecutivo INTO v_next_num;

            v_consecutivo := LPAD(v_next_num::TEXT, 8, '0');
        ELSE
            SELECT COALESCE(MAX(consecutivo::BIGINT), 0) + 1 INTO v_next_num 
            FROM public."Invoices" 
            WHERE consecutivo ~ '^[0-9]+$';

            v_consecutivo := LPAD(v_next_num::TEXT, 8, '0');
        END IF;
    END IF;

    -- Resolución y Validación de Rango de Numeración
    IF v_resolution_id IS NULL AND v_implant_id IS NOT NULL THEN
        SELECT "resolutionId" INTO v_resolution_id FROM public."Implant" WHERE id = v_implant_id;
    END IF;

    IF v_resolution_id IS NULL AND v_branch_id IS NOT NULL THEN
        SELECT "resolutionId" INTO v_resolution_id FROM public."Branch" WHERE id = v_branch_id;
    END IF;

    IF v_resolution_id IS NULL AND v_serie IS NOT NULL THEN
        SELECT id INTO v_resolution_id FROM public."Resolution" WHERE activo = TRUE AND prefijo ILIKE v_serie ORDER BY id DESC LIMIT 1;
    END IF;

    IF v_resolution_id IS NULL THEN
        SELECT id INTO v_resolution_id FROM public."Resolution" WHERE activo = TRUE ORDER BY id DESC LIMIT 1;
    END IF;

    IF v_resolution_id IS NOT NULL THEN
        SELECT * INTO v_res FROM public."Resolution" WHERE id = v_resolution_id;

        IF v_res.id IS NOT NULL THEN
            -- 1. Validar estado de la resolución
            IF v_res.activo IS FALSE THEN
                p_mensaje_resultado := 'ERROR: La resolución de facturación "' || v_res.name || '" (' || v_res.code || ') se encuentra inactiva.';
                RETURN;
            END IF;

            -- 2. Validar vigencia / expiración de la resolución
            IF v_res.expira IS NOT NULL AND v_res.expira::DATE < CURRENT_DATE THEN
                IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                    p_mensaje_resultado := 'ERROR: La resolución de facturación "' || v_res.name || '" (' || v_res.code || ') se encuentra vencida desde el ' || to_char(v_res.expira, 'YYYY-MM-DD') || '.';
                    RETURN;
                END IF;
            END IF;

            -- 3. Validar rango numérico autorizado del consecutivo
            IF v_consecutivo IS NOT NULL AND v_consecutivo ~ '^[0-9]+$' THEN
                v_consec_num := v_consecutivo::BIGINT;

                IF v_res.inicial IS NOT NULL AND v_consec_num < v_res.inicial THEN
                    IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                        p_mensaje_resultado := 'ERROR: El consecutivo generado (' || v_consec_num || ') es menor al rango inicial autorizado (' || v_res.inicial || ') para la resolución "' || v_res.name || '".';
                        RETURN;
                    END IF;
                END IF;

                IF v_res."end" IS NOT NULL AND v_consec_num > v_res."end" THEN
                    IF COALESCE(v_res.permitir, FALSE) IS FALSE THEN
                        p_mensaje_resultado := 'ERROR: El consecutivo generado (' || v_consec_num || ') supera el rango final autorizado (' || v_res."end" || ') para la resolución "' || v_res.name || '".';
                        RETURN;
                    END IF;
                END IF;
            END IF;

            -- 4. Asignar prefijo de resolución a la serie si no fue provisto
            IF v_serie IS NULL AND NULLIF(v_res.prefijo, '') IS NOT NULL THEN
                v_serie := v_res.prefijo;
            END IF;
        END IF;
    END IF;

    -- 5. Validar unicidad del consecutivo (evitar duplicidad)
    IF v_consecutivo IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM public."Invoices"
            WHERE consecutivo = v_consecutivo
              AND COALESCE(serie, '') = COALESCE(v_serie, '')
              AND COALESCE(fuente, '') = COALESCE(v_fuente, '')
        ) THEN
            p_mensaje_resultado := 'ERROR: Ya existe una factura emitida con la numeración ' || COALESCE(v_fuente || '-', '') || COALESCE(v_serie || '-', '') || v_consecutivo || '.';
            RETURN;
        END IF;
    END IF;

    -- Pre-validar items (Productos, tiquetes duplicados, productos al vuelo)
    FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                      "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                      "serviceType" TEXT
                  )
    LOOP
        v_real_product_id := NULL;
        IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' THEN
            SELECT id INTO v_real_product_id FROM public."Product" WHERE code = v_item."ticketCode";
        ELSE
            v_real_product_id := v_item."productId";
        END IF;

        -- Si no hay productId ni ticketCode válido
        IF v_real_product_id IS NULL AND (v_item."ticketCode" IS NULL OR TRIM(v_item."ticketCode") = '') THEN
            p_mensaje_resultado := 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            RETURN;
        END IF;

        -- Validación de Unicidad para Número de Tiquete / Voucher (ticketCode)
        IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
            SELECT inv."internalNumber" INTO v_existing_invoice_number
            FROM public."InvoicesProduct" ip
            JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
            WHERE ip."ticketCode" = TRIM(v_item."ticketCode")
            LIMIT 1;

            IF v_existing_invoice_number IS NOT NULL THEN
                p_mensaje_resultado := 'ERROR: El tiquete N° ' || TRIM(v_item."ticketCode") || ' ya está facturado en la factura ' || v_existing_invoice_number;
                RETURN;
            END IF;
        END IF;
    END LOOP;

    -- Buscar Resolución de Documentos Activa para la Sucursal e Implante
    SELECT * INTO v_res_rec
    FROM public."DocumentResolution"
    WHERE ("branchId" IS NULL OR "branchId" = v_branch_id)
      AND (
          (v_implant_id IS NOT NULL AND "implantId" = v_implant_id)
          OR ("implantId" IS NULL)
      )
      AND "isActive" = true
    ORDER BY CASE WHEN "branchId" = v_branch_id THEN 1 ELSE 2 END,
             CASE WHEN "implantId" = v_implant_id THEN 1 ELSE 2 END
    LIMIT 1
    FOR UPDATE;

    IF v_res_rec.id IS NOT NULL THEN
        -- Validar Vencimiento de la Resolución
        IF v_res_rec."expirationDate" IS NOT NULL AND v_res_rec."expirationDate" < CURRENT_DATE THEN
            p_mensaje_resultado := 'ERROR: La resolución N° ' || COALESCE(v_res_rec."resolutionNumber", '') || ' asignada a la sucursal venció el ' || to_char(v_res_rec."expirationDate", 'DD/MM/YYYY') || '.';
            RETURN;
        END IF;

        -- Validar Rango Final de Numeración
        IF v_res_rec."currentNumber" > v_res_rec."finalNumber" THEN
            p_mensaje_resultado := 'ERROR: La resolución N° ' || COALESCE(v_res_rec."resolutionNumber", '') || ' ha superado la numeración máxima autorizada (' || v_res_rec."finalNumber"::text || ').';
            RETURN;
        END IF;
    END IF;

    -- ----------------------------------------------------
    -- FASE 2: EJECUCIÓN TRANSACCIONAL PROTEGIDA CON ROLLBACK AUTOMÁTICO
    -- ----------------------------------------------------
    BEGIN
        IF v_res_rec.id IS NOT NULL THEN
            v_serie_val := COALESCE(NULLIF(p_data->>'serie', ''), v_res_rec.prefix);
            IF NULLIF(p_data->>'consecutivo', '') IS NOT NULL THEN
                v_consec_val := p_data->>'consecutivo';
            ELSE
                v_consec_val := v_res_rec."currentNumber"::text;
                -- Incrementar consecutivo actual en la resolución activa
                UPDATE public."DocumentResolution"
                SET "currentNumber" = "currentNumber" + 1
                WHERE id = v_res_rec.id;
            END IF;
        ELSE
            -- Fallback a Maestro de Consecutivos de Transacciones
            IF NULLIF(p_data->>'consecutivo', '') IS NOT NULL THEN
                v_consec_val := p_data->>'consecutivo';
                v_serie_val := NULLIF(p_data->>'serie', '');
            ELSE
                v_consec_json := public."fnObtenerSiguienteConsecutivo"('INVOICE', v_branch_id, v_implant_id);
                v_consec_val := v_consec_json->>'consecutivoNumber';
                v_serie_val := COALESCE(NULLIF(p_data->>'serie', ''), NULLIF(v_consec_json->>'prefix', ''));
            END IF;
        END IF;

        -- Construir internalNumber sin anteponer prefijo si este es nulo o vacío
        v_internal_number := CASE 
            WHEN v_serie_val IS NOT NULL AND TRIM(v_serie_val) <> '' THEN v_serie_val || '-' || v_consec_val 
            ELSE v_consec_val 
        END;

        v_fuente_val := COALESCE(NULLIF(p_data->>'fuente', ''), 'FE');

        -- Inserción de la Factura Cabecera
        INSERT INTO public."Invoices" (
            "internalNumber", "date", "clientId", "currency", "exchangeRate", 
            "branchId", "implantId", "sellerId", "ticketPrinterId", 
            "baseCommissionable", "commissionPercentage", "chargesAndTaxes", 
            "totalAmount", "userId", "state", "fuente", "serie", "consecutivo"
        ) VALUES (
            v_internal_number, CURRENT_TIMESTAMP, NULLIF(p_data->>'clientId', '')::INT, p_data->>'currency', COALESCE(NULLIF(p_data->>'exchangeRate', '')::FLOAT, 1.0),
            v_branch_id, v_implant_id, NULLIF(p_data->>'sellerId', '')::INT, NULLIF(p_data->>'ticketPrinterId', '')::INT,
            0, COALESCE(NULLIF(p_data->>'commissionPercentage', '')::FLOAT, 0.0), COALESCE(ROUND(NULLIF(p_data->>'chargesAndTaxes', '')::numeric, v_decimals)::double precision, 0.0),
            COALESCE(ROUND(NULLIF(p_data->>'totalAmount', '')::numeric, v_decimals)::double precision, 0.0), p_acting_user_id, 'NUEVO',
            v_fuente_val, v_serie_val, v_consec_val
        ) RETURNING id INTO v_invoice_id;

        FOR v_combo IN SELECT * FROM jsonb_to_recordset(p_data->'combos') AS x("comboId" INT, "id" INT)
        LOOP
            INSERT INTO public."InvoicesProductCombo" ("invoiceId", "comboId")
            VALUES (v_invoice_id, COALESCE(v_combo."comboId", v_combo.id));
        END LOOP;

        FOR v_item IN SELECT * FROM jsonb_to_recordset(p_data->'items') AS x(
                          "productId" INT, "ticketCode" TEXT, "type" TEXT, "description" TEXT,
                          quantity INT, price FLOAT, cost FLOAT, "providerId" TEXT, "prestadoraId" TEXT,
                          "checkIn" TEXT, "checkOut" TEXT, "nights" INT, "mainTaxId" TEXT,
                          "paxAdults" INT, "paxChildren" INT, "serviceType" TEXT, "destination" TEXT,
                          "reservationCode" TEXT, "sellerCommission" FLOAT, "ticketPrinterCommission" FLOAT,
                          "comboId" TEXT, "appliedTaxes" JSONB, "passengers" JSONB, "variables" JSONB, "inNationality" INT,
                          "servicios" TEXT, "itemDescription" TEXT, "itinerary" TEXT, "class" TEXT, "airline" TEXT, "ticketTypeId" TEXT, "payments" JSONB, "itinerariesItineraryList" JSONB
                      )
        LOOP
            -- 1. Lógica de Producto Al Vuelo
            IF v_item."productId" IS NULL AND v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' THEN
                SELECT id INTO v_real_product_id FROM public."Product" WHERE code = v_item."ticketCode";
                
                IF v_real_product_id IS NULL THEN
                    CALL public.spProductoCrear(
                        v_item."ticketCode",
                        COALESCE(v_item."type", 'Tiquete'),
                        COALESCE(v_item."description", 'Tiquete ' || v_item."ticketCode"),
                        COALESCE(v_item.price, 0),
                        COALESCE(v_item.cost, 0),
                        NULL, 
                        COALESCE(v_item."serviceType", 'Aire'),
                        p_acting_user_id,
                        v_real_product_id,
                        v_temp_msg
                    );
                    IF v_temp_msg LIKE 'ERROR%' THEN
                        RAISE EXCEPTION '%', v_temp_msg;
                    END IF;
                END IF;
            ELSE
                v_real_product_id := v_item."productId";
            END IF;

            IF v_real_product_id IS NULL THEN
                RAISE EXCEPTION 'ERROR: Todos los productos deben tener un producto seleccionado o un ticketCode.';
            END IF;

            -- 1.5 Validación de Unicidad para Número de Tiquete / Voucher (ticketCode)
            IF v_item."ticketCode" IS NOT NULL AND TRIM(v_item."ticketCode") <> '' AND TRIM(v_item."ticketCode") <> 'TAN' THEN
                SELECT inv."internalNumber" INTO v_existing_invoice_number
                FROM public."InvoicesProduct" ip
                JOIN public."Invoices" inv ON ip."invoiceId" = inv.id
                WHERE ip."ticketCode" = TRIM(v_item."ticketCode")
                LIMIT 1;

                IF v_existing_invoice_number IS NOT NULL THEN
                    RAISE EXCEPTION 'ERROR: El tiquete N° % ya está facturado en la factura %', TRIM(v_item."ticketCode"), v_existing_invoice_number;
                END IF;
            END IF;

            -- 2. Inserción de Producto
            INSERT INTO public."InvoicesProduct" (
                "invoiceId", "productId", "ticketCode", "quantity", "price", "cost", "providerId", "prestadoraId",
                "checkInDate", "checkOutDate", "nights", "paxAdults", "paxChildren",
                "serviceType", "destination", "reservationCode", "sellerCommission", 
                "ticketPrinterCommission", "comboId", "mainTaxId", "inNationality",
                "servicios", "descripcion", "itinerary", "class", "airline", "ticketTypeId"
            ) VALUES (
                v_invoice_id, v_real_product_id, NULLIF(TRIM(v_item."ticketCode"), ''), v_item.quantity, 
                ROUND(v_item.price::numeric, v_decimals)::double precision, 
                ROUND(v_item.cost::numeric, v_decimals)::double precision, 
                NULLIF(v_item."providerId", '')::INT, NULLIF(v_item."prestadoraId", '')::INT,
                CASE WHEN v_item."checkIn" IS NOT NULL AND v_item."checkIn" <> '' THEN v_item."checkIn"::TIMESTAMP ELSE NULL END,
                CASE WHEN v_item."checkOut" IS NOT NULL AND v_item."checkOut" <> '' THEN v_item."checkOut"::TIMESTAMP ELSE NULL END,
                v_item.nights, v_item."paxAdults", v_item."paxChildren",
                v_item."serviceType", v_item."destination", v_item."reservationCode", 
                ROUND(v_item."sellerCommission"::numeric, v_decimals)::double precision,
                ROUND(v_item."ticketPrinterCommission"::numeric, v_decimals)::double precision, 
                NULLIF(v_item."comboId", '')::INT, NULLIF(v_item."mainTaxId", '')::INT, COALESCE(v_item."inNationality", 1),
                v_item."servicios", COALESCE(v_item."itemDescription", v_item."description"), v_item."itinerary", v_item."class", v_item."airline", NULLIF(v_item."ticketTypeId", '')::INT
            ) RETURNING id INTO v_invoice_product_id;

            IF v_item.passengers IS NOT NULL THEN
                FOR v_pax IN SELECT * FROM jsonb_to_recordset(v_item.passengers) AS x(name TEXT, document TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductPasenger" ("invoiceProductId", "name", "document")
                    VALUES (v_invoice_product_id, v_pax.name, v_pax.document);
                END LOOP;
            END IF;

            IF v_item."appliedTaxes" IS NOT NULL THEN
                FOR v_tax IN SELECT * FROM jsonb_to_recordset(v_item."appliedTaxes") AS x("chargeAndTaxId" INT, "explicitAmount" FLOAT)
                LOOP
                    INSERT INTO public."InvoicesProductTax" (
                        "invoiceProductId", "chargeAndTaxId", "valueSnapshot", "valueTypeSnapshot", "explicitAmount", "isMain"
                    )
                    SELECT v_invoice_product_id, ct.id, ct.value, ct."valueType", 
                           ROUND(v_tax."explicitAmount"::numeric, v_decimals)::double precision, 
                           CASE WHEN NULLIF(v_item."mainTaxId", '')::INT = ct.id THEN TRUE ELSE FALSE END
                    FROM public."ChargeAndTax" ct
                    WHERE ct.id = v_tax."chargeAndTaxId";
                END LOOP;
            END IF;

            IF v_item.variables IS NOT NULL THEN
                FOR v_var IN SELECT * FROM jsonb_to_recordset(v_item.variables) AS x("masterVariableId" INT, value TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductVariable" ("invoiceProductId", "masterVariableId", "value")
                    VALUES (v_invoice_product_id, v_var."masterVariableId", v_var.value);
                END LOOP;
            END IF;

            IF v_item.payments IS NOT NULL THEN
                FOR v_payment IN SELECT * FROM jsonb_to_recordset(v_item.payments) AS x(amount FLOAT, "paymentMethod" TEXT, "reference" TEXT, "date" TEXT, "creditCardId" INT, "cardNumber" TEXT, "authorizationCode" TEXT, "voucher" TEXT, "expirationDate" TEXT)
                LOOP
                    INSERT INTO public."InvoicesProductPayment" ("invoiceProductId", "amount", "paymentMethod", "reference", "date", "creditCardId", "cardNumber", "authorizationCode", "voucher", "expirationDate")
                    VALUES (
                        v_invoice_product_id, 
                        ROUND(v_payment.amount::numeric, v_decimals)::double precision, 
                        v_payment."paymentMethod", v_payment.reference, 
                        CASE WHEN v_payment."date" IS NOT NULL AND v_payment."date" <> '' THEN v_payment."date"::TIMESTAMP ELSE CURRENT_TIMESTAMP END, 
                        v_payment."creditCardId", v_payment."cardNumber", v_payment."authorizationCode", v_payment."voucher", v_payment."expirationDate"
                    );
                END LOOP;
            END IF;

            IF v_item."itinerariesItineraryList" IS NOT NULL THEN
                FOR v_itinerary IN SELECT * FROM jsonb_to_recordset(v_item."itinerariesItineraryList") AS x(origin TEXT, destination TEXT, class TEXT, "checkInDate" TEXT, "checkOutDate" TEXT, "prestadoraCode" TEXT, "farebasis" TEXT, "Numflight" TEXT, "Typeflight" TEXT, "amount" FLOAT, "co2" NUMERIC, orden INT)
                LOOP
                    INSERT INTO public."InvoicesProductItinerary" ("invoiceProductId", "origin", "destination", "class", "checkInDate", "checkOutDate", "prestadoraCode", "farebasis", "Numflight", "Typeflight", "amount", "co2", "orden")
                    VALUES (
                        v_invoice_product_id, v_itinerary.origin, v_itinerary.destination, v_itinerary.class, 
                        CASE WHEN v_itinerary."checkInDate" IS NOT NULL AND v_itinerary."checkInDate" <> '' THEN v_itinerary."checkInDate"::TIMESTAMP ELSE NULL END, 
                        CASE WHEN v_itinerary."checkOutDate" IS NOT NULL AND v_itinerary."checkOutDate" <> '' THEN v_itinerary."checkOutDate"::TIMESTAMP ELSE NULL END, 
                        COALESCE(v_itinerary."prestadoraCode", ''), COALESCE(v_itinerary."farebasis", ''), v_itinerary."Numflight", v_itinerary."Typeflight", 
                        ROUND(COALESCE(v_itinerary."amount", 0)::numeric, v_decimals)::double precision, 
                        v_itinerary."co2", v_itinerary.orden
                    );
                END LOOP;
            END IF;

        END LOOP;

        -- Calcular y actualizar el totalAmount basado en impuestos si aplica
        UPDATE public."Invoices"
        SET "totalAmount" = ROUND((COALESCE("chargesAndTaxes", 0) + (
            SELECT COALESCE(SUM(ipt."explicitAmount"), 0)
            FROM public."InvoicesProductTax" ipt
            JOIN public."InvoicesProduct" ip ON ipt."invoiceProductId" = ip.id
            WHERE ip."invoiceId" = v_invoice_id
        ))::numeric, v_decimals)::double precision
        WHERE id = v_invoice_id;

        p_invoice_id := v_invoice_id;
        p_mensaje_resultado := 'SUCCESS: Factura creada correctamente con ID ' || v_invoice_id;

    EXCEPTION
        WHEN OTHERS THEN
            p_invoice_id := NULL;
            p_mensaje_resultado := 'ERROR: ' || SQLERRM;
    END;
END;
$_$;


--
-- Name: spinvoiceseliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spinvoiceseliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    p_mensaje_resultado := 'ERROR: Las facturas no se pueden eliminar del sistema. Solo pueden ser anuladas.';
    RETURN;
END;
$$;


--
-- Name: sploglistar(integer, integer, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sploglistar(p_limit integer DEFAULT 100, p_offset integer DEFAULT 0, p_module text DEFAULT NULL::text, p_user_id integer DEFAULT NULL::integer) RETURNS TABLE(id integer, "userId" integer, "userName" text, action text, module text, description text, metadata json, "createdAt" timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l."userId",
        u.name AS "userName",
        l.action AS "action",
        l.module AS "module",
        l.description AS "description",
        l.metadata::JSON AS "metadata",
        l."createdAt" AS "createdAt"
    FROM public."SystemLog" l
    LEFT JOIN public."User" u ON l."userId" = u.id
    WHERE (p_module IS NULL OR l.module = UPPER(p_module))
      AND (p_user_id IS NULL OR l."userId" = p_user_id)
    ORDER BY l."createdAt" DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


--
-- Name: spmaestroimportar(text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spmaestroimportar(IN p_tipo text, IN p_text_data text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_count INT := 0;
    v_errors TEXT := '';
    v_branch_id INT;
    v_provider_id INT;
    v_prov_type_id INT;
    v_role_id INT;
    v_hashed_password TEXT := '$2a$10$7zB.Y7S5y5y5y5y5y5y5y.y5y5y5y5y5y5y5y5y5y5y5y5y5y5y'; -- Placeholder hash
BEGIN
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');
            
            IF p_tipo = 'sucursales' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Branch" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'implants' THEN
                -- Format: code^name^branchCode
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    v_branch_id := NULL;
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER("code") = LOWER(TRIM(v_cols[3]));
                    END IF;
                    
                    INSERT INTO public."Implant" ("code", "name", "branchId")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), v_branch_id)
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "branchId" = EXCLUDED."branchId";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'vendedores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Seller" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."Seller" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tiqueteadores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."TicketPrinter" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."TicketPrinter" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'impuestos' THEN
                -- Format: code^name^type^valueType^value
                IF v_cols[2] IS NOT NULL AND v_cols[3] IS NOT NULL THEN
                    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "inNationality")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]), NULLIF(TRIM(v_cols[5]), '')::DECIMAL, TRUE, COALESCE(NULLIF(TRIM(v_cols[6]), '')::INT, 1))
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "type" = EXCLUDED."type",
                        "valueType" = EXCLUDED."valueType",
                        "value" = EXCLUDED."value",
                        "inNationality" = EXCLUDED."inNationality";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'clientes' THEN
                -- Format: document^name^contactInfo^address
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Client" ("document", "name", "contactInfo", "address")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]))
                    ON CONFLICT ("document") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo", 
                        "address" = EXCLUDED."address";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'proveedores' THEN
                -- Format: code^name^contactInfo^providerTypeCode^airlineCode^sigla
                IF v_cols[2] IS NOT NULL OR v_cols[1] IS NOT NULL THEN
                    v_prov_type_id := NULL;
                    IF array_length(v_cols, 1) >= 4 AND v_cols[4] IS NOT NULL AND TRIM(v_cols[4]) <> '' THEN
                        SELECT id INTO v_prov_type_id FROM public."ProviderType" WHERE LOWER("code") = LOWER(TRIM(v_cols[4])) OR LOWER("name") = LOWER(TRIM(v_cols[4])) LIMIT 1;
                    END IF;

                    INSERT INTO public."Provider" ("code", "name", "contactInfo", "providerTypeId", "airlineCode", "sigla")
                    VALUES (
                        NULLIF(TRIM(v_cols[1]), ''), 
                        TRIM(v_cols[2]), 
                        NULLIF(TRIM(v_cols[3]), ''), 
                        v_prov_type_id, 
                        CASE WHEN array_length(v_cols, 1) >= 5 THEN NULLIF(TRIM(v_cols[5]), '') ELSE NULL END,
                        CASE WHEN array_length(v_cols, 1) >= 6 THEN NULLIF(TRIM(v_cols[6]), '') ELSE NULL END
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo",
                        "providerTypeId" = COALESCE(EXCLUDED."providerTypeId", public."Provider"."providerTypeId"),
                        "airlineCode" = COALESCE(EXCLUDED."airlineCode", public."Provider"."airlineCode"),
                        "sigla" = COALESCE(EXCLUDED."sigla", public."Provider"."sigla");
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tipos-proveedores' THEN
                -- Format: code^name^isAirline
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
                    VALUES (
                        TRIM(v_cols[1]), 
                        TRIM(v_cols[2]), 
                        (UPPER(TRIM(v_cols[3])) IN ('SI', 'S', 'TRUE', '1')), 
                        true
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "isAirline" = EXCLUDED."isAirline";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'productos' THEN
                -- Format: description^basePrice^code^type^billingConcept^serviceType
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Product" ("code", "type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (TRIM(v_cols[3]), COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "type" = EXCLUDED."type",
                            "description" = EXCLUDED."description",
                            "basePrice" = EXCLUDED."basePrice",
                            "billingConcept" = EXCLUDED."billingConcept",
                            "serviceType" = EXCLUDED."serviceType";
                    ELSE
                        INSERT INTO public."Product" ("type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'prestadoras' THEN
                -- Format: name^providerCode^code^category^location^type
                IF v_cols[1] IS NOT NULL THEN
                    v_provider_id := NULL;
                    IF v_cols[2] IS NOT NULL AND TRIM(v_cols[2]) <> '' THEN
                        SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER("code") = LOWER(TRIM(v_cols[2])) OR LOWER("name") = LOWER(TRIM(v_cols[2])) LIMIT 1;
                    END IF;

                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Prestadora" ("name", "providerId", "code", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[3]), TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "name" = EXCLUDED."name",
                            "providerId" = EXCLUDED."providerId",
                            "category" = EXCLUDED."category",
                            "location" = EXCLUDED."location",
                            "type" = EXCLUDED."type";
                    ELSE
                        INSERT INTO public."Prestadora" ("name", "providerId", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'variables' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."MasterVariable" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'parametros' THEN
                -- Format: code^name^value
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."SystemParameter" ("code", "name", "value")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
                    v_count := v_count + 1;
                END IF;

            END IF;

        EXCEPTION WHEN OTHERS THEN
            v_errors := v_errors || 'Error en fila [' || v_row_text || ']: ' || SQLERRM || '; ';
        END;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: Registros procesados: ' || v_count || '. ' || COALESCE(v_errors, '');
END;
$_$;


--
-- Name: spmonedaactualizar(integer, text, text, double precision, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spmonedaactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_exchange_rate double precision, IN p_decimals integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    -- Verificar que el nuevo código no esté en uso por otra moneda
    IF EXISTS (SELECT 1 FROM public."Currency" WHERE code = p_code AND id <> p_id) THEN
        p_mensaje_resultado := 'ERROR: El código ' || p_code || ' ya está en uso por otra moneda';
        RETURN;
    END IF;

    UPDATE public."Currency"
    SET
        code           = p_code,
        name           = p_name,
        "exchangeRate" = p_exchange_rate,
        decimals       = COALESCE(p_decimals, 2)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Moneda ' || p_id || ' actualizada correctamente';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spmonedacrear(text, text, double precision, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spmonedacrear(IN p_code text, IN p_name text, IN p_exchange_rate double precision, IN p_decimals integer, IN p_acting_user_id integer, INOUT p_currency_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public."Currency" WHERE code = p_code) THEN
        p_mensaje_resultado := 'ERROR: El código de moneda ya está registrado';
        RETURN;
    END IF;

    INSERT INTO public."Currency" (code, name, "exchangeRate", decimals)
    VALUES (p_code, p_name, p_exchange_rate, COALESCE(p_decimals, 2))
    RETURNING id INTO p_currency_id;

    p_mensaje_resultado := 'SUCCESS: Moneda creada con ID ' || p_currency_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spmonedaeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spmonedaeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    DELETE FROM public."Currency" WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Moneda ' || p_id || ' eliminada correctamente';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spmonedalistar(integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spmonedalistar(IN p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM public."Currency" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Moneda con ID ' || p_id || ' no encontrada';
        RETURN;
    END IF;

    -- Retorna el resultado como conjunto de filas usando RETURN QUERY no aplica en PROCEDURE;
    -- El cliente (API) debe ejecutar un SELECT directamente después de llamar este SP,
    -- o usar una función (fnMonedaListar) para retornar rows.
    -- Este SP valida existencia y devuelve el mensaje de estado.

    IF p_id IS NULL THEN
        p_mensaje_resultado := 'SUCCESS: Consulta de todas las monedas';
    ELSE
        p_mensaje_resultado := 'SUCCESS: Consulta de moneda ID ' || p_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spparameteractualizar(integer, text, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spparameteractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_value text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Parámetro con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."SystemParameter"
    SET "code" = p_code,
        "name" = p_name,
        "value" = p_value
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Parámetro actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spparametercrear(text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spparametercrear(IN p_code text, IN p_name text, IN p_value text, IN p_acting_user_id integer, INOUT p_parameter_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."SystemParameter" ("code", "name", "value")
    VALUES (p_code, p_name, p_value)
    RETURNING id INTO p_parameter_id;

    p_mensaje_resultado := 'SUCCESS: Parámetro creado con ID ' || p_parameter_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spparametereliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spparametereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."SystemParameter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Parámetro con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."SystemParameter" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Parámetro eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprestadoraactualizar(integer, text, text, text, text, integer, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprestadoraactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_category text, IN p_location text, IN p_provider_id integer, IN p_type text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."Prestadora" SET
        "code" = p_code,
        "name" = p_name,
        "category" = p_category,
        "location" = p_location,
        "providerId" = p_provider_id,
        "type" = p_type,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Prestadora actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprestadoracrear(text, text, text, text, integer, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprestadoracrear(IN p_code text, IN p_name text, IN p_category text, IN p_location text, IN p_provider_id integer, IN p_type text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_prestadora_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Prestadora" ("code", "name", "category", "location", "providerId", "type", "isActive")
    VALUES (p_code, p_name, p_category, p_location, p_provider_id, p_type, COALESCE(p_is_active, true))
    RETURNING id INTO p_prestadora_id;

    p_mensaje_resultado := 'SUCCESS: Prestadora creado con ID ' || p_prestadora_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprestadoraeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprestadoraeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Prestadora" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Prestadora eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproductoactualizar(integer, text, text, text, double precision, double precision, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproductoactualizar(IN p_id integer, IN p_code text, IN p_type text, IN p_description text, IN p_base_price double precision, IN p_cost double precision, IN p_billing_concept text, IN p_service_type text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Product" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Producto con ID ' || p_id || ' no encontrado';
        RETURN;
    END IF;

    UPDATE public."Product" SET
        "code" = p_code,
        "type" = p_type,
        "description" = p_description,
        "basePrice" = p_base_price,
        "cost" = p_cost,
        "billingConcept" = p_billing_concept,
        "serviceType" = p_service_type
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Producto actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproductocrear(text, text, text, double precision, double precision, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproductocrear(IN p_code text, IN p_type text, IN p_description text, IN p_base_price double precision, IN p_cost double precision, IN p_billing_concept text, IN p_service_type text, IN p_acting_user_id integer, INOUT p_product_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Product" ("code", "type", "description", "basePrice", "cost", "billingConcept", "serviceType")
    VALUES (p_code, p_type, p_description, p_base_price, p_cost, p_billing_concept, p_service_type)
    RETURNING id INTO p_product_id;

    p_mensaje_resultado := 'SUCCESS: Producto creado con ID ' || p_product_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproductoeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproductoeliminar(IN p_id integer, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_name TEXT;
    v_count INT := 0;
BEGIN
    SELECT description INTO v_name FROM public."Product" WHERE id = p_id;
    IF v_name IS NULL THEN
        p_mensaje_resultado := 'ERROR: El producto especificado no existe.';
        RETURN;
    END IF;

    SELECT (
        SELECT COUNT(*) FROM public."QuotationProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."InvoicesProduct" WHERE "productId" = p_id
    ) + (
        SELECT COUNT(*) FROM public."ComboProduct" WHERE "productId" = p_id
    ) INTO v_count;

    IF v_count > 0 THEN
        p_mensaje_resultado := 'ERROR: No es posible eliminar el producto "' || v_name || '" porque ya se encuentra registrado en ' || v_count || ' cotización(es) o factura(s). Puedes marcarlo como INACTIVO para ocultarlo en futuras operaciones.';
        RETURN;
    END IF;

    DELETE FROM public."Product" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Producto eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproveedoractualizar(integer, text, text, text, jsonb, integer, text, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproveedoractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_contact_info text, IN p_commission_config jsonb, IN p_provider_type_id integer, IN p_airline_code text, IN p_sigla text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."Provider" SET
        "code" = p_code,
        "name" = p_name,
        "contactInfo" = p_contact_info,
        "commissionConfig" = p_commission_config,
        "providerTypeId" = p_provider_type_id,
        "airlineCode" = p_airline_code,
        "sigla" = p_sigla,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Proveedor actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproveedorcrear(text, text, text, jsonb, integer, text, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproveedorcrear(IN p_code text, IN p_name text, IN p_contact_info text, IN p_commission_config jsonb, IN p_provider_type_id integer, IN p_airline_code text, IN p_sigla text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_provider_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Provider" ("code", "name", "contactInfo", "commissionConfig", "providerTypeId", "airlineCode", "sigla", "isActive")
    VALUES (p_code, p_name, p_contact_info, p_commission_config, p_provider_type_id, p_airline_code, p_sigla, COALESCE(p_is_active, true))
    RETURNING id INTO p_provider_id;

    p_mensaje_resultado := 'SUCCESS: Proveedor creado con ID ' || p_provider_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spproveedoreliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spproveedoreliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."Provider" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Proveedor eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprovidertypeactualizar(integer, text, text, boolean, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprovidertypeactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_is_airline boolean, IN p_active boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public."ProviderType" SET
        "code" = p_code,
        "name" = p_name,
        "isAirline" = COALESCE(p_is_airline, false),
        "active" = COALESCE(p_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor actualizado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprovidertypecrear(text, text, boolean, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprovidertypecrear(IN p_code text, IN p_name text, IN p_is_airline boolean, IN p_active boolean, IN p_acting_user_id integer, INOUT p_prov_type_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
    VALUES (p_code, p_name, COALESCE(p_is_airline, false), COALESCE(p_active, true))
    RETURNING id INTO p_prov_type_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor creado con ID ' || p_prov_type_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spprovidertypeeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spprovidertypeeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM public."ProviderType" WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tipo de proveedor eliminado.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spresolucionactualizar(integer, text, text, timestamp with time zone, timestamp with time zone, bigint, bigint, text, text, integer, integer, boolean, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spresolucionactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_date timestamp with time zone, IN p_expira timestamp with time zone, IN p_inicial bigint, IN p_end bigint, IN p_autoriza text, IN p_prefijo text, IN p_alerta integer, IN p_day integer, IN p_permitir boolean, IN p_activo boolean, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Resolution" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Resolución con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."Resolution"
    SET "code" = p_code,
        "name" = p_name,
        "date" = p_date,
        "expira" = p_expira,
        "inicial" = p_inicial,
        "end" = p_end,
        "autoriza" = p_autoriza,
        "prefijo" = p_prefijo,
        "alerta" = p_alerta,
        "day" = p_day,
        "permitir" = COALESCE(p_permitir, false),
        "activo" = COALESCE(p_activo, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Resolución actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spresolucioncrear(text, text, timestamp with time zone, timestamp with time zone, bigint, bigint, text, text, integer, integer, boolean, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spresolucioncrear(IN p_code text, IN p_name text, IN p_date timestamp with time zone, IN p_expira timestamp with time zone, IN p_inicial bigint, IN p_end bigint, IN p_autoriza text, IN p_prefijo text, IN p_alerta integer, IN p_day integer, IN p_permitir boolean, IN p_activo boolean, IN p_acting_user_id integer, INOUT p_resolution_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Resolution" (
        "code", "name", "date", "expira", "inicial", "end", "autoriza", "prefijo", "alerta", "day", "permitir", "activo"
    )
    VALUES (
        p_code, p_name, p_date, p_expira, p_inicial, p_end, p_autoriza, p_prefijo, p_alerta, p_day, COALESCE(p_permitir, false), COALESCE(p_activo, true)
    )
    RETURNING id INTO p_resolution_id;

    p_mensaje_resultado := 'SUCCESS: Resolución creada con ID ' || p_resolution_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spresolucioneliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spresolucioneliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Resolution" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Resolución con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."Resolution" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Resolución eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spselleractualizar(integer, text, text, text, boolean, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spselleractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_email text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Seller" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Vendedor con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."Seller"
    SET "code" = p_code,
        "name" = p_name,
        "email" = p_email,
        "isActive" = COALESCE(p_is_active, true)
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Vendedor actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spsellercrear(text, text, text, boolean, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spsellercrear(IN p_code text, IN p_name text, IN p_email text, IN p_is_active boolean DEFAULT true, IN p_acting_user_id integer DEFAULT 1, INOUT p_seller_id integer DEFAULT 0, INOUT p_mensaje_resultado text DEFAULT ''::text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."Seller" ("code", "name", "email", "isActive")
    VALUES (p_code, p_name, p_email, COALESCE(p_is_active, true))
    RETURNING id INTO p_seller_id;

    p_mensaje_resultado := 'SUCCESS: Vendedor creado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spsellereliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spsellereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Seller" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Vendedor con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."Seller" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Vendedor eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spsysconsecutivoactualizar(integer, character varying, character varying, integer, integer, character varying, character varying, bigint, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spsysconsecutivoactualizar(IN p_id integer, IN p_codigo character varying, IN p_nombre character varying, IN p_branch_id integer, IN p_implant_id integer, IN p_fuente character varying, IN p_serie character varying, IN p_consecutivo bigint, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    UPDATE public."SysConsecutivo"
    SET 
        "codigo" = TRIM(p_codigo),
        "nombre" = TRIM(p_nombre),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "fuente" = TRIM(p_fuente),
        "serie" = TRIM(p_serie),
        "consecutivo" = COALESCE(p_consecutivo, 0),
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo actualizado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spsysconsecutivocrear(character varying, character varying, integer, integer, character varying, character varying, bigint, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spsysconsecutivocrear(IN p_codigo character varying, IN p_nombre character varying, IN p_branch_id integer, IN p_implant_id integer, IN p_fuente character varying, IN p_serie character varying, IN p_consecutivo bigint, IN p_acting_user_id integer, INOUT p_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NULLIF(TRIM(p_codigo), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El código del consecutivo es obligatorio.';
        RETURN;
    END IF;

    IF NULLIF(TRIM(p_nombre), '') IS NULL THEN
        p_mensaje_resultado := 'ERROR: El nombre del consecutivo es obligatorio.';
        RETURN;
    END IF;

    INSERT INTO public."SysConsecutivo" (
        "codigo", "nombre", "branchId", "implantId", "fuente", "serie", "consecutivo", "createdAt", "updatedAt"
    ) VALUES (
        TRIM(p_codigo), TRIM(p_nombre), p_branch_id, p_implant_id, TRIM(p_fuente), TRIM(p_serie), COALESCE(p_consecutivo, 0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id INTO p_id;

    p_mensaje_resultado := 'SUCCESS: Consecutivo creado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spsysconsecutivoeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spsysconsecutivoeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_id IS NULL THEN
        p_mensaje_resultado := 'ERROR: El ID del consecutivo es obligatorio.';
        RETURN;
    END IF;

    DELETE FROM public."SysConsecutivo"
    WHERE id = p_id;

    IF NOT FOUND THEN
        p_mensaje_resultado := 'ERROR: No se encontró el consecutivo con ID ' || p_id;
        RETURN;
    END IF;

    p_mensaje_resultado := 'SUCCESS: Consecutivo eliminado exitosamente.';
EXCEPTION WHEN OTHERS THEN
    p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spticketprinteractualizar(integer, text, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spticketprinteractualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_email text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."TicketPrinter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Tiqueteador con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    UPDATE public."TicketPrinter"
    SET "code" = p_code,
        "name" = p_name,
        "email" = p_email
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Tiqueteador actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spticketprintercrear(text, text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spticketprintercrear(IN p_code text, IN p_name text, IN p_email text, IN p_acting_user_id integer, INOUT p_printer_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."TicketPrinter" ("code", "name", "email")
    VALUES (p_code, p_name, p_email)
    RETURNING id INTO p_printer_id;

    p_mensaje_resultado := 'SUCCESS: Tiqueteador creado con ID ' || p_printer_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spticketprintereliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spticketprintereliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."TicketPrinter" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Tiqueteador con ID ' || p_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."TicketPrinter" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Tiqueteador eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spusuarioactualizar(integer, text, text, text, integer, integer, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spusuarioactualizar(IN p_user_id integer, IN p_name text, IN p_email text, IN p_password_hash text, IN p_role_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_ticket_printer_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM public."User" WHERE id = p_user_id) THEN
        p_mensaje_resultado := 'ERROR: Usuario con ID ' || p_user_id || ' no encontrado.';
        RETURN;
    END IF;

    -- Validar si el email ya existe en otro usuario
    IF EXISTS (SELECT 1 FROM public."User" WHERE email = p_email AND id != p_user_id) THEN
        p_mensaje_resultado := 'ERROR: El email ' || p_email || ' ya está registrado por otro usuario.';
        RETURN;
    END IF;

    -- Actualizar el usuario
    UPDATE public."User"
    SET 
        "name" = COALESCE(p_name, "name"),
        "email" = COALESCE(p_email, "email"),
        "passwordHash" = COALESCE(p_password_hash, "passwordHash"),
        "roleId" = COALESCE(p_role_id, "roleId"),
        "branchId" = p_branch_id,
        "implantId" = p_implant_id,
        "ticketPrinterId" = p_ticket_printer_id
    WHERE id = p_user_id;

    p_mensaje_resultado := 'SUCCESS: Usuario actualizado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spusuarioconsultar(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.spusuarioconsultar(p_id integer DEFAULT NULL::integer, p_email text DEFAULT NULL::text) RETURNS TABLE(id integer, name text, email text, "roleId" integer, "branchId" integer, "implantId" integer, "ticketPrinterId" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name AS "name",
        u.email AS "email",
        u."roleId" AS "roleId",
        u."branchId" AS "branchId",
        u."implantId" AS "implantId",
        u."ticketPrinterId" AS "ticketPrinterId"
    FROM public."User" u
    WHERE (p_id IS NULL OR u.id = p_id)
      AND (p_email IS NULL OR u.email = p_email)
    ORDER BY u.id ASC;
END;
$$;


--
-- Name: spusuariocrear(text, text, text, integer, integer, integer, integer, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spusuariocrear(IN p_name text, IN p_email text, IN p_password_hash text, IN p_role_id integer, IN p_branch_id integer, IN p_implant_id integer, IN p_ticket_printer_id integer, IN p_acting_user_id integer, INOUT p_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar si el email ya existe
    IF EXISTS (SELECT 1 FROM public."User" WHERE email = p_email) THEN
        p_mensaje_resultado := 'ERROR: El email ' || p_email || ' ya está registrado.';
        RETURN;
    END IF;

    INSERT INTO public."User" (
        "name", 
        "email", 
        "passwordHash", 
        "roleId", 
        "branchId", 
        "implantId", 
        "ticketPrinterId"
    )
    VALUES (
        p_name, 
        p_email, 
        p_password_hash, 
        p_role_id, 
        p_branch_id, 
        p_implant_id, 
        p_ticket_printer_id
    )
    RETURNING id INTO p_user_id;

    p_mensaje_resultado := 'SUCCESS: Usuario creado con ID ' || p_user_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spusuarioeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spusuarioeliminar(IN p_user_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM public."User" WHERE id = p_user_id) THEN
        p_mensaje_resultado := 'ERROR: Usuario con ID ' || p_user_id || ' no encontrado.';
        RETURN;
    END IF;

    DELETE FROM public."User" WHERE id = p_user_id;
    
    p_mensaje_resultado := 'SUCCESS: Usuario eliminado exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spvariableactualizar(integer, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spvariableactualizar(IN p_id integer, IN p_code text, IN p_name text, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."MasterVariable" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Variable con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    UPDATE public."MasterVariable"
    SET "code" = p_code,
        "name" = p_name
    WHERE id = p_id;

    p_mensaje_resultado := 'SUCCESS: Variable actualizada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spvariablecrear(text, text, integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spvariablecrear(IN p_code text, IN p_name text, IN p_acting_user_id integer, INOUT p_variable_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public."MasterVariable" ("code", "name")
    VALUES (p_code, p_name)
    RETURNING id INTO p_variable_id;

    p_mensaje_resultado := 'SUCCESS: Variable creada con ID ' || p_variable_id;
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: spvariableeliminar(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.spvariableeliminar(IN p_id integer, IN p_acting_user_id integer, INOUT p_mensaje_resultado text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."MasterVariable" WHERE id = p_id) THEN
        p_mensaje_resultado := 'ERROR: Variable con ID ' || p_id || ' no encontrada.';
        RETURN;
    END IF;

    DELETE FROM public."MasterVariable" WHERE id = p_id;
    p_mensaje_resultado := 'SUCCESS: Variable eliminada exitosamente.';
EXCEPTION
    WHEN OTHERS THEN
        p_mensaje_resultado := 'ERROR: ' || SQLERRM;
END;
$$;


--
-- Name: Airports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Airports" (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(150) NOT NULL,
    "citiesId" integer NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Airports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Airports_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Airports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Airports_id_seq" OWNED BY public."Airports".id;


--
-- Name: Attachment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Attachment" (
    id integer NOT NULL,
    "quotationId" integer NOT NULL,
    "fileName" text NOT NULL,
    "fileType" text NOT NULL,
    "fileSize" integer NOT NULL,
    "fileContent" bytea NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Attachment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Attachment_id_seq" OWNED BY public."Attachment".id;


--
-- Name: BookingGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingGDS" (
    id integer NOT NULL,
    code character varying(25) NOT NULL,
    type character varying(25) NOT NULL,
    blanch character varying(25) NOT NULL,
    implant character varying(25),
    external boolean DEFAULT false NOT NULL,
    gds integer,
    date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
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


--
-- Name: BookingGDSInvoiceAutoLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingGDSInvoiceAutoLog" (
    "Id" integer NOT NULL,
    "branchId" integer,
    "implanteId" integer,
    date timestamp(6) without time zone,
    menssage text,
    "bookingCode" character varying(25),
    "bookingId" integer,
    error boolean,
    file text,
    "userId" integer
);


--
-- Name: BookingGDSInvoiceAutoLog_Id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingGDSInvoiceAutoLog_Id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingGDSInvoiceAutoLog_Id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingGDSInvoiceAutoLog_Id_seq" OWNED BY public."BookingGDSInvoiceAutoLog"."Id";


--
-- Name: BookingGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingGDS_id_seq" OWNED BY public."BookingGDS".id;


--
-- Name: BookingProductFEEGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductFEEGDS" (
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


--
-- Name: BookingProductFEEGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductFEEGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductFEEGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductFEEGDS_id_seq" OWNED BY public."BookingProductFEEGDS".id;


--
-- Name: BookingProductGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductGDS" (
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
    penalty character varying(25),
    "invoiceId" integer
);


--
-- Name: BookingProductGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductGDS_id_seq" OWNED BY public."BookingProductGDS".id;


--
-- Name: BookingProductItineraryGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductItineraryGDS" (
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


--
-- Name: BookingProductItineraryGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductItineraryGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductItineraryGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductItineraryGDS_id_seq" OWNED BY public."BookingProductItineraryGDS".id;


--
-- Name: BookingProductPassangerGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductPassangerGDS" (
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


--
-- Name: BookingProductPassangerGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductPassangerGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductPassangerGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductPassangerGDS_id_seq" OWNED BY public."BookingProductPassangerGDS".id;


--
-- Name: BookingProductPaymentGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductPaymentGDS" (
    id integer NOT NULL,
    "bookingProductId" integer,
    "bookingProductFEEId" integer,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    type character varying(50) NOT NULL,
    typecreditcard character varying(25),
    numbercreditcard character varying(50),
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


--
-- Name: BookingProductPaymentGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductPaymentGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductPaymentGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductPaymentGDS_id_seq" OWNED BY public."BookingProductPaymentGDS".id;


--
-- Name: BookingProductTaxGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductTaxGDS" (
    id integer NOT NULL,
    "bookingProductId" integer NOT NULL,
    code character varying(25) NOT NULL,
    name character varying(50) NOT NULL,
    type character varying(25) NOT NULL,
    ismain boolean DEFAULT false,
    percentage double precision NOT NULL,
    amount double precision NOT NULL
);


--
-- Name: BookingProductTaxGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductTaxGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductTaxGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductTaxGDS_id_seq" OWNED BY public."BookingProductTaxGDS".id;


--
-- Name: BookingProductVariableGDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingProductVariableGDS" (
    id integer NOT NULL,
    "bookingProductId" integer NOT NULL,
    code text,
    name text,
    value text
);


--
-- Name: BookingProductVariableGDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingProductVariableGDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingProductVariableGDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingProductVariableGDS_id_seq" OWNED BY public."BookingProductVariableGDS".id;


--
-- Name: BookingsGDSInvoiceAuto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingsGDSInvoiceAuto" (
    id integer NOT NULL,
    "Branch" character varying(25),
    implant character varying(25),
    "bookingCode" character varying(25),
    "bookingId" integer
);


--
-- Name: BookingsGDSInvoiceAuto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingsGDSInvoiceAuto_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingsGDSInvoiceAuto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingsGDSInvoiceAuto_id_seq" OWNED BY public."BookingsGDSInvoiceAuto".id;


--
-- Name: BookingsGDS_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingsGDS_log" (
    id integer NOT NULL,
    blanch character varying(25),
    implant character varying(25),
    message text,
    file character varying(250),
    codebooking character varying(50),
    booking text,
    error integer DEFAULT 0 NOT NULL
);


--
-- Name: BookingsGDS_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingsGDS_log_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingsGDS_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingsGDS_log_id_seq" OWNED BY public."BookingsGDS_log".id;


--
-- Name: BranchGDSInvoiceAuto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BranchGDSInvoiceAuto" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "gdsId" integer NOT NULL,
    "EnvoiceAuto" boolean DEFAULT false
);


--
-- Name: BranchGDSInvoiceAuto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BranchGDSInvoiceAuto_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BranchGDSInvoiceAuto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BranchGDSInvoiceAuto_id_seq" OWNED BY public."BranchGDSInvoiceAuto".id;


--
-- Name: Branch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Branch_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Branch_id_seq" OWNED BY public."Branch".id;


--
-- Name: CellCustomization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CellCustomization" (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    value character varying(10),
    "branchId" integer,
    "implantId" integer
);


--
-- Name: CellCustomization_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CellCustomization_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CellCustomization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CellCustomization_id_seq" OWNED BY public."CellCustomization".id;


--
-- Name: ChargeAndTax; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChargeAndTax" (
    id integer NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    "valueType" text NOT NULL,
    value double precision NOT NULL,
    "isEditable" boolean DEFAULT true NOT NULL,
    code text,
    orden integer DEFAULT 0,
    "productIds" jsonb DEFAULT '[]'::jsonb,
    "targetTaxId" integer,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: ChargeAndTax_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ChargeAndTax_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ChargeAndTax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ChargeAndTax_id_seq" OWNED BY public."ChargeAndTax".id;


--
-- Name: Cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Cities" (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    "countriesId" integer NOT NULL,
    statecode character varying(25),
    iata character varying(10),
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Cities_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Cities_id_seq" OWNED BY public."Cities".id;


--
-- Name: Client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Client" (
    id integer NOT NULL,
    name text NOT NULL,
    document text NOT NULL,
    "contactInfo" text,
    address text,
    "mandatoryVariables" jsonb,
    "sellerId" integer,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Client_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Client_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Client_id_seq" OWNED BY public."Client".id;


--
-- Name: Combo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Combo" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    cupos integer DEFAULT 0,
    "currencyId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: ComboProduct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ComboProduct" (
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


--
-- Name: ComboProductTax; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ComboProductTax" (
    id integer NOT NULL,
    "comboProductId" integer NOT NULL,
    "chargeAndTaxId" integer NOT NULL,
    amount double precision NOT NULL,
    "isMain" boolean DEFAULT false NOT NULL
);


--
-- Name: ComboProductTax_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ComboProductTax_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ComboProductTax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ComboProductTax_id_seq" OWNED BY public."ComboProductTax".id;


--
-- Name: ComboProduct_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ComboProduct_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ComboProduct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ComboProduct_id_seq" OWNED BY public."ComboProduct".id;


--
-- Name: Combo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Combo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Combo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Combo_id_seq" OWNED BY public."Combo".id;


--
-- Name: Countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Countries" (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    dane character varying(25),
    region character varying(50),
    prefix character varying(10),
    "curencyId" integer,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Countries_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Countries_id_seq" OWNED BY public."Countries".id;


--
-- Name: CreditCard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditCard" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: CreditCard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CreditCard_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CreditCard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CreditCard_id_seq" OWNED BY public."CreditCard".id;


--
-- Name: Currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Currency" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    "exchangeRate" double precision NOT NULL,
    decimals integer DEFAULT 2 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Currency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Currency_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Currency_id_seq" OWNED BY public."Currency".id;


--
-- Name: DocumentResolution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DocumentResolution" (
    id integer NOT NULL,
    "branchId" integer NOT NULL,
    "implantId" integer,
    "resolutionNumber" character varying(100) NOT NULL,
    "initialNumber" integer NOT NULL,
    "finalNumber" integer NOT NULL,
    "currentNumber" integer NOT NULL,
    "resolutionDate" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    prefix character varying(20),
    "expirationDate" timestamp(6) without time zone NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: DocumentResolution_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DocumentResolution_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DocumentResolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DocumentResolution_id_seq" OWNED BY public."DocumentResolution".id;


--
-- Name: EquivalencesInterfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EquivalencesInterfaces" (
    id integer NOT NULL,
    id_interfaces integer NOT NULL,
    id_master integer NOT NULL,
    cd_maestro text NOT NULL,
    cd_codigo text NOT NULL,
    cd_codigointe text NOT NULL,
    dt_fecha timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: EquivalencesInterfaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."EquivalencesInterfaces_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: EquivalencesInterfaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."EquivalencesInterfaces_id_seq" OWNED BY public."EquivalencesInterfaces".id;


--
-- Name: EquivalenciasInterfaces_Log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EquivalenciasInterfaces_Log" (
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
    fecha_creacion timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: EquivalenciasInterfaces_Log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."EquivalenciasInterfaces_Log_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: EquivalenciasInterfaces_Log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."EquivalenciasInterfaces_Log_id_seq" OWNED BY public."EquivalenciasInterfaces_Log".id;


--
-- Name: ExecutionPreset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExecutionPreset" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "procedureId" integer NOT NULL,
    description text,
    "filterValues" jsonb,
    "filterConfig" jsonb,
    "columnConfigs" jsonb,
    "selectedTotals" jsonb,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ExecutionPreset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ExecutionPreset_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ExecutionPreset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ExecutionPreset_id_seq" OWNED BY public."ExecutionPreset".id;


--
-- Name: ExecutionProcedure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExecutionProcedure" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "spName" character varying(255) NOT NULL,
    description text,
    parameters jsonb,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ExecutionProcedure_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ExecutionProcedure_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ExecutionProcedure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ExecutionProcedure_id_seq" OWNED BY public."ExecutionProcedure".id;


--
-- Name: FormatCellCustomization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FormatCellCustomization" (
    id integer NOT NULL,
    "formatId" integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    value character varying(10)
);


--
-- Name: FormatCellCustomization_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."FormatCellCustomization_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FormatCellCustomization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."FormatCellCustomization_id_seq" OWNED BY public."FormatCellCustomization".id;


--
-- Name: GDS; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."GDS" (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: GDS_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."GDS_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: GDS_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."GDS_id_seq" OWNED BY public."GDS".id;


--
-- Name: Implant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Implant_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Implant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Implant_id_seq" OWNED BY public."Implant".id;


--
-- Name: InterfaceExtractParam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InterfaceExtractParam" (
    id integer NOT NULL,
    "interfaceId" integer NOT NULL,
    "fieldCode" character varying(50) NOT NULL,
    "fieldName" character varying(100) NOT NULL,
    prefix character varying(100) NOT NULL,
    delimiter character varying(20) DEFAULT '-'::character varying,
    "startPosition" integer DEFAULT 0,
    length integer DEFAULT 0,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: InterfaceExtractParam_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InterfaceExtractParam_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InterfaceExtractParam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InterfaceExtractParam_id_seq" OWNED BY public."InterfaceExtractParam".id;


--
-- Name: Interfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Interfaces" (
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


--
-- Name: Interfaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Interfaces_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Interfaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Interfaces_id_seq" OWNED BY public."Interfaces".id;


--
-- Name: Invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Invoices" (
    id integer NOT NULL,
    "internalNumber" character varying(255) NOT NULL,
    date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    state character varying(25) DEFAULT 'NUEVO'::character varying,
    fuente character varying(50),
    serie character varying(50),
    consecutivo character varying(50)
);


--
-- Name: InvoicesProduct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProduct" (
    id integer NOT NULL,
    "invoiceId" integer NOT NULL,
    "productId" integer NOT NULL,
    quantity integer NOT NULL,
    price double precision NOT NULL,
    cost double precision DEFAULT 0,
    "providerId" integer,
    "prestadoraId" integer,
    "checkInDate" timestamp(6) without time zone,
    "checkOutDate" timestamp(6) without time zone,
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
    airline character varying(100),
    "ticketCode" text
);


--
-- Name: InvoicesProductCombo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductCombo" (
    id integer NOT NULL,
    "invoiceId" integer NOT NULL,
    "comboId" integer NOT NULL
);


--
-- Name: InvoicesProductCombo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductCombo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductCombo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductCombo_id_seq" OWNED BY public."InvoicesProductCombo".id;


--
-- Name: InvoicesProductItinerary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductItinerary" (
    id integer NOT NULL,
    "invoiceProductId" integer NOT NULL,
    orden integer,
    origin character varying(255) NOT NULL,
    destination character varying(255) NOT NULL,
    class character varying(255),
    "checkInDate" timestamp(6) without time zone,
    "checkOutDate" timestamp(6) without time zone,
    terminal character varying(255),
    "prestadoraCode" character varying(255),
    farebasis character varying(255),
    "Numflight" character varying(25),
    "Typeflight" character varying(1),
    amount double precision,
    co2 double precision
);


--
-- Name: InvoicesProductItinerary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductItinerary_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductItinerary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductItinerary_id_seq" OWNED BY public."InvoicesProductItinerary".id;


--
-- Name: InvoicesProductPasenger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductPasenger" (
    id integer NOT NULL,
    "invoiceProductId" integer NOT NULL,
    name character varying(255) NOT NULL,
    document character varying(255) NOT NULL
);


--
-- Name: InvoicesProductPasenger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductPasenger_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductPasenger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductPasenger_id_seq" OWNED BY public."InvoicesProductPasenger".id;


--
-- Name: InvoicesProductPayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductPayment" (
    id integer NOT NULL,
    "invoiceProductId" integer NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" character varying(100),
    date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    reference character varying(255),
    "authorizationCode" text,
    "cardNumber" text,
    "creditCardId" integer,
    "expirationDate" text,
    voucher text
);


--
-- Name: InvoicesProductPayment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductPayment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductPayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductPayment_id_seq" OWNED BY public."InvoicesProductPayment".id;


--
-- Name: InvoicesProductTax; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductTax" (
    id integer NOT NULL,
    "invoiceProductId" integer NOT NULL,
    "chargeAndTaxId" integer NOT NULL,
    "valueSnapshot" double precision NOT NULL,
    "valueTypeSnapshot" character varying(50) NOT NULL,
    "explicitAmount" double precision,
    "isMain" boolean DEFAULT false
);


--
-- Name: InvoicesProductTax_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductTax_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductTax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductTax_id_seq" OWNED BY public."InvoicesProductTax".id;


--
-- Name: InvoicesProductVariable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoicesProductVariable" (
    id integer NOT NULL,
    "invoiceProductId" integer NOT NULL,
    "masterVariableId" integer NOT NULL,
    value character varying(255) NOT NULL
);


--
-- Name: InvoicesProductVariable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProductVariable_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProductVariable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProductVariable_id_seq" OWNED BY public."InvoicesProductVariable".id;


--
-- Name: InvoicesProduct_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InvoicesProduct_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InvoicesProduct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InvoicesProduct_id_seq" OWNED BY public."InvoicesProduct".id;


--
-- Name: Invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Invoices_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Invoices_id_seq" OWNED BY public."Invoices".id;


--
-- Name: Master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Master" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    inactivo boolean DEFAULT false NOT NULL
);


--
-- Name: MasterVariable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."MasterVariable_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: MasterVariable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."MasterVariable_id_seq" OWNED BY public."MasterVariable".id;


--
-- Name: Master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Master_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Master_id_seq" OWNED BY public."Master".id;


--
-- Name: Menu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Menu_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Menu_id_seq" OWNED BY public."Menu".id;


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payment" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    iscash boolean DEFAULT false NOT NULL,
    iscredit boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true
);


--
-- Name: Payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Payment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Payment_id_seq" OWNED BY public."Payment".id;


--
-- Name: PreQuotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PreQuotation" (
    id integer NOT NULL,
    consecutivo integer NOT NULL,
    "clientNameText" text,
    "clientId" integer,
    "headerDescription" text,
    "providerId" integer,
    "ticketPrinterId" integer,
    "sellerId" integer,
    "branchId" integer NOT NULL,
    "preQuotationType" character varying(100),
    "quotationNotice" text,
    "noticeResponse" text,
    "startDate" timestamp(6) without time zone,
    "endDate" timestamp(6) without time zone,
    "customFields" jsonb,
    state character varying(50) DEFAULT 'POR COTIZAR'::character varying,
    "convertedQuotationId" integer,
    "convertedAt" timestamp(6) without time zone,
    "convertedUserId" integer,
    "userId" integer NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: PreQuotationStateHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PreQuotationStateHistory" (
    id integer NOT NULL,
    "preQuotationId" integer NOT NULL,
    state character varying(50) NOT NULL,
    description text,
    "userId" integer NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: PreQuotationStateHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PreQuotationStateHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PreQuotationStateHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PreQuotationStateHistory_id_seq" OWNED BY public."PreQuotationStateHistory".id;


--
-- Name: PreQuotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PreQuotation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PreQuotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PreQuotation_id_seq" OWNED BY public."PreQuotation".id;


--
-- Name: Prestadora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Prestadora" (
    id integer NOT NULL,
    name text NOT NULL,
    location text,
    category text,
    "providerId" integer,
    code text,
    type text,
    initials text,
    nogds text,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Prestadora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Prestadora_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Prestadora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Prestadora_id_seq" OWNED BY public."Prestadora".id;


--
-- Name: Product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Product_id_seq" OWNED BY public."Product".id;


--
-- Name: Provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Provider" (
    id integer NOT NULL,
    code text,
    name text NOT NULL,
    "contactInfo" text,
    "commissionConfig" jsonb,
    "providerTypeId" integer,
    "airlineCode" character varying(10),
    sigla character varying(10),
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: ProviderType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ProviderType" (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    "isAirline" boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: ProviderType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ProviderType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ProviderType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ProviderType_id_seq" OWNED BY public."ProviderType".id;


--
-- Name: Provider_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Provider_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Provider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Provider_id_seq" OWNED BY public."Provider".id;


--
-- Name: Quotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Quotation" (
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
    "stateUpdatedAt" timestamp(6) without time zone,
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
    "startDate" timestamp(6) without time zone,
    "endDate" timestamp(6) without time zone,
    passenger character varying(255),
    "paxAdults" integer,
    "paxChildren" integer,
    "reservationCode" character varying(255),
    "copyFieldsToProducts" boolean DEFAULT true,
    "manualDescription" text
);


--
-- Name: QuotationCombo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationCombo" (
    id integer NOT NULL,
    "quotationId" integer NOT NULL,
    "comboId" integer NOT NULL
);


--
-- Name: QuotationCombo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationCombo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationCombo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationCombo_id_seq" OWNED BY public."QuotationCombo".id;


--
-- Name: QuotationFormat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationFormat" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    template bytea,
    "templateConfig" jsonb,
    "htmlTemplate" text,
    "branchId" integer,
    "implantId" integer,
    "createdAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: QuotationFormat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationFormat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationFormat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationFormat_id_seq" OWNED BY public."QuotationFormat".id;


--
-- Name: QuotationManualService; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationManualService" (
    id integer NOT NULL,
    "quotationId" integer NOT NULL,
    "providerName" character varying(255),
    "serviceName" character varying(255),
    cost double precision DEFAULT 0,
    "salePrice" double precision DEFAULT 0,
    utility double precision DEFAULT 0,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: QuotationManualService_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationManualService_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationManualService_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationManualService_id_seq" OWNED BY public."QuotationManualService".id;


--
-- Name: QuotationPrintCustomization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationPrintCustomization" (
    id integer NOT NULL,
    "quotationId" integer NOT NULL,
    html text NOT NULL,
    "createdAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: QuotationPrintCustomization_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationPrintCustomization_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationPrintCustomization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationPrintCustomization_id_seq" OWNED BY public."QuotationPrintCustomization".id;


--
-- Name: QuotationPrintDefaultTemplate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationPrintDefaultTemplate" (
    id integer NOT NULL,
    html text NOT NULL,
    name character varying(100) DEFAULT 'Default'::character varying,
    "createdAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: QuotationPrintDefaultTemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationPrintDefaultTemplate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationPrintDefaultTemplate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationPrintDefaultTemplate_id_seq" OWNED BY public."QuotationPrintDefaultTemplate".id;


--
-- Name: QuotationProduct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationProduct" (
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


--
-- Name: QuotationProductPassenger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationProductPassenger" (
    id integer NOT NULL,
    "quotationProductId" integer NOT NULL,
    name text NOT NULL,
    document text NOT NULL
);


--
-- Name: QuotationProductPassenger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationProductPassenger_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationProductPassenger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationProductPassenger_id_seq" OWNED BY public."QuotationProductPassenger".id;


--
-- Name: QuotationProductPayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationProductPayment" (
    id integer NOT NULL,
    "quotationProductId" integer NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" character varying(100),
    date timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    reference character varying(255),
    "creditCardId" integer,
    "cardNumber" character varying(20),
    "authorizationCode" character varying(50),
    voucher character varying(50),
    "expirationDate" character varying(10)
);


--
-- Name: QuotationProductPayment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationProductPayment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationProductPayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationProductPayment_id_seq" OWNED BY public."QuotationProductPayment".id;


--
-- Name: QuotationProductTax; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationProductTax" (
    id integer NOT NULL,
    "quotationProductId" integer NOT NULL,
    "chargeAndTaxId" integer NOT NULL,
    "valueSnapshot" double precision NOT NULL,
    "valueTypeSnapshot" text NOT NULL,
    "explicitAmount" double precision,
    "isMain" boolean DEFAULT false NOT NULL
);


--
-- Name: QuotationProductTax_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationProductTax_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationProductTax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationProductTax_id_seq" OWNED BY public."QuotationProductTax".id;


--
-- Name: QuotationProductVariable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationProductVariable" (
    id integer NOT NULL,
    "quotationProductId" integer NOT NULL,
    "masterVariableId" integer NOT NULL,
    value text NOT NULL
);


--
-- Name: QuotationProductVariable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationProductVariable_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationProductVariable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationProductVariable_id_seq" OWNED BY public."QuotationProductVariable".id;


--
-- Name: QuotationProduct_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationProduct_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationProduct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationProduct_id_seq" OWNED BY public."QuotationProduct".id;


--
-- Name: QuotationState; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationState" (
    id integer NOT NULL,
    code character varying(25) NOT NULL,
    name character varying(50) NOT NULL,
    color character varying(20),
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: QuotationStateHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationStateHistory" (
    id integer NOT NULL,
    "quotationId" integer NOT NULL,
    state character varying(25) NOT NULL,
    description text,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer
);


--
-- Name: QuotationStateHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationStateHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationStateHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationStateHistory_id_seq" OWNED BY public."QuotationStateHistory".id;


--
-- Name: QuotationState_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."QuotationState_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: QuotationState_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."QuotationState_id_seq" OWNED BY public."QuotationState".id;


--
-- Name: Quotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Quotation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Quotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Quotation_id_seq" OWNED BY public."Quotation".id;


--
-- Name: Report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Report" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    base_table character varying(100),
    description text,
    custom_sql text,
    created_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ReportColumns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReportColumns" (
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


--
-- Name: ReportColumns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReportColumns_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReportColumns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReportColumns_id_seq" OWNED BY public."ReportColumns".id;


--
-- Name: ReportFilters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReportFilters" (
    id integer NOT NULL,
    report_id integer NOT NULL,
    table_alias character varying(20),
    column_name character varying(100) NOT NULL,
    filter_label character varying(150),
    filter_type character varying(50) NOT NULL,
    operator character varying(20) DEFAULT '='::character varying,
    sort_order integer DEFAULT 0
);


--
-- Name: ReportFilters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReportFilters_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReportFilters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReportFilters_id_seq" OWNED BY public."ReportFilters".id;


--
-- Name: ReportJoins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReportJoins" (
    id integer NOT NULL,
    report_id integer NOT NULL,
    table_name character varying(100) NOT NULL,
    alias character varying(20) NOT NULL,
    join_type character varying(50) DEFAULT 'INNER JOIN'::character varying NOT NULL,
    join_condition text NOT NULL,
    sort_order integer DEFAULT 0
);


--
-- Name: ReportJoins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReportJoins_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReportJoins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReportJoins_id_seq" OWNED BY public."ReportJoins".id;


--
-- Name: ReportSorts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReportSorts" (
    id integer NOT NULL,
    report_id integer NOT NULL,
    column_expr text NOT NULL,
    direction character varying(10) DEFAULT 'ASC'::character varying,
    sort_order integer DEFAULT 0
);


--
-- Name: ReportSorts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReportSorts_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReportSorts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReportSorts_id_seq" OWNED BY public."ReportSorts".id;


--
-- Name: Report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Report_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Report_id_seq" OWNED BY public."Report".id;


--
-- Name: Resolution_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Resolution_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Resolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Resolution_id_seq" OWNED BY public."Resolution".id;


--
-- Name: Role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Role" (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    permissions jsonb,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: Role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Role_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Role_id_seq" OWNED BY public."Role".id;


--
-- Name: Seller_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Seller_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Seller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Seller_id_seq" OWNED BY public."Seller".id;


--
-- Name: SysConsecutivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SysConsecutivo" (
    id integer NOT NULL,
    codigo character varying(50) NOT NULL,
    nombre character varying(255) NOT NULL,
    "branchId" integer,
    "implantId" integer,
    fuente character varying(50),
    serie character varying(50),
    consecutivo bigint DEFAULT 0 NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: SysConsecutivo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SysConsecutivo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SysConsecutivo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SysConsecutivo_id_seq" OWNED BY public."SysConsecutivo".id;


--
-- Name: SystemLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SystemLog" (
    id integer NOT NULL,
    "userId" integer,
    action text NOT NULL,
    module text NOT NULL,
    description text NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: SystemLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SystemLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SystemLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SystemLog_id_seq" OWNED BY public."SystemLog".id;


--
-- Name: SystemParameter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SystemParameter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SystemParameter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SystemParameter_id_seq" OWNED BY public."SystemParameter".id;


--
-- Name: TicketPrinter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TicketPrinter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TicketPrinter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TicketPrinter_id_seq" OWNED BY public."TicketPrinter".id;


--
-- Name: TicketType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TicketType" (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    "isActive" boolean DEFAULT true
);


--
-- Name: TicketType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TicketType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TicketType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TicketType_id_seq" OWNED BY public."TicketType".id;


--
-- Name: TransactionConsecutive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TransactionConsecutive" (
    id integer NOT NULL,
    "transactionType" character varying(50) NOT NULL,
    description character varying(150) NOT NULL,
    prefix character varying(20),
    "initialNumber" integer NOT NULL,
    "currentNumber" integer NOT NULL,
    "branchId" integer,
    "implantId" integer,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TransactionConsecutive_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TransactionConsecutive_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TransactionConsecutive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TransactionConsecutive_id_seq" OWNED BY public."TransactionConsecutive".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
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
    "canEditReports" boolean DEFAULT false,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: seq_quotation_consecutivo; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_quotation_consecutivo
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Airports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Airports" ALTER COLUMN id SET DEFAULT nextval('public."Airports_id_seq"'::regclass);


--
-- Name: Attachment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attachment" ALTER COLUMN id SET DEFAULT nextval('public."Attachment_id_seq"'::regclass);


--
-- Name: BookingGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingGDS_id_seq"'::regclass);


--
-- Name: BookingGDSInvoiceAutoLog Id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingGDSInvoiceAutoLog" ALTER COLUMN "Id" SET DEFAULT nextval('public."BookingGDSInvoiceAutoLog_Id_seq"'::regclass);


--
-- Name: BookingProductFEEGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductFEEGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductFEEGDS_id_seq"'::regclass);


--
-- Name: BookingProductGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductGDS_id_seq"'::regclass);


--
-- Name: BookingProductItineraryGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductItineraryGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductItineraryGDS_id_seq"'::regclass);


--
-- Name: BookingProductPassangerGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPassangerGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductPassangerGDS_id_seq"'::regclass);


--
-- Name: BookingProductPaymentGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPaymentGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductPaymentGDS_id_seq"'::regclass);


--
-- Name: BookingProductTaxGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductTaxGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductTaxGDS_id_seq"'::regclass);


--
-- Name: BookingProductVariableGDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductVariableGDS" ALTER COLUMN id SET DEFAULT nextval('public."BookingProductVariableGDS_id_seq"'::regclass);


--
-- Name: BookingsGDSInvoiceAuto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingsGDSInvoiceAuto" ALTER COLUMN id SET DEFAULT nextval('public."BookingsGDSInvoiceAuto_id_seq"'::regclass);


--
-- Name: BookingsGDS_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingsGDS_log" ALTER COLUMN id SET DEFAULT nextval('public."BookingsGDS_log_id_seq"'::regclass);


--
-- Name: Branch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Branch" ALTER COLUMN id SET DEFAULT nextval('public."Branch_id_seq"'::regclass);


--
-- Name: BranchGDSInvoiceAuto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BranchGDSInvoiceAuto" ALTER COLUMN id SET DEFAULT nextval('public."BranchGDSInvoiceAuto_id_seq"'::regclass);


--
-- Name: CellCustomization id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CellCustomization" ALTER COLUMN id SET DEFAULT nextval('public."CellCustomization_id_seq"'::regclass);


--
-- Name: ChargeAndTax id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeAndTax" ALTER COLUMN id SET DEFAULT nextval('public."ChargeAndTax_id_seq"'::regclass);


--
-- Name: Cities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Cities" ALTER COLUMN id SET DEFAULT nextval('public."Cities_id_seq"'::regclass);


--
-- Name: Client id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Client" ALTER COLUMN id SET DEFAULT nextval('public."Client_id_seq"'::regclass);


--
-- Name: Combo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Combo" ALTER COLUMN id SET DEFAULT nextval('public."Combo_id_seq"'::regclass);


--
-- Name: ComboProduct id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct" ALTER COLUMN id SET DEFAULT nextval('public."ComboProduct_id_seq"'::regclass);


--
-- Name: ComboProductTax id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProductTax" ALTER COLUMN id SET DEFAULT nextval('public."ComboProductTax_id_seq"'::regclass);


--
-- Name: Countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Countries" ALTER COLUMN id SET DEFAULT nextval('public."Countries_id_seq"'::regclass);


--
-- Name: CreditCard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCard" ALTER COLUMN id SET DEFAULT nextval('public."CreditCard_id_seq"'::regclass);


--
-- Name: Currency id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Currency" ALTER COLUMN id SET DEFAULT nextval('public."Currency_id_seq"'::regclass);


--
-- Name: DocumentResolution id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentResolution" ALTER COLUMN id SET DEFAULT nextval('public."DocumentResolution_id_seq"'::regclass);


--
-- Name: EquivalencesInterfaces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalencesInterfaces" ALTER COLUMN id SET DEFAULT nextval('public."EquivalencesInterfaces_id_seq"'::regclass);


--
-- Name: EquivalenciasInterfaces_Log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalenciasInterfaces_Log" ALTER COLUMN id SET DEFAULT nextval('public."EquivalenciasInterfaces_Log_id_seq"'::regclass);


--
-- Name: ExecutionPreset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExecutionPreset" ALTER COLUMN id SET DEFAULT nextval('public."ExecutionPreset_id_seq"'::regclass);


--
-- Name: ExecutionProcedure id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExecutionProcedure" ALTER COLUMN id SET DEFAULT nextval('public."ExecutionProcedure_id_seq"'::regclass);


--
-- Name: FormatCellCustomization id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FormatCellCustomization" ALTER COLUMN id SET DEFAULT nextval('public."FormatCellCustomization_id_seq"'::regclass);


--
-- Name: GDS id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GDS" ALTER COLUMN id SET DEFAULT nextval('public."GDS_id_seq"'::regclass);


--
-- Name: Implant id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Implant" ALTER COLUMN id SET DEFAULT nextval('public."Implant_id_seq"'::regclass);


--
-- Name: InterfaceExtractParam id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InterfaceExtractParam" ALTER COLUMN id SET DEFAULT nextval('public."InterfaceExtractParam_id_seq"'::regclass);


--
-- Name: Interfaces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Interfaces" ALTER COLUMN id SET DEFAULT nextval('public."Interfaces_id_seq"'::regclass);


--
-- Name: Invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoices" ALTER COLUMN id SET DEFAULT nextval('public."Invoices_id_seq"'::regclass);


--
-- Name: InvoicesProduct id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProduct" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProduct_id_seq"'::regclass);


--
-- Name: InvoicesProductCombo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductCombo" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductCombo_id_seq"'::regclass);


--
-- Name: InvoicesProductItinerary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductItinerary" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductItinerary_id_seq"'::regclass);


--
-- Name: InvoicesProductPasenger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductPasenger" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductPasenger_id_seq"'::regclass);


--
-- Name: InvoicesProductPayment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductPayment" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductPayment_id_seq"'::regclass);


--
-- Name: InvoicesProductTax id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductTax" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductTax_id_seq"'::regclass);


--
-- Name: InvoicesProductVariable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductVariable" ALTER COLUMN id SET DEFAULT nextval('public."InvoicesProductVariable_id_seq"'::regclass);


--
-- Name: Master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Master" ALTER COLUMN id SET DEFAULT nextval('public."Master_id_seq"'::regclass);


--
-- Name: MasterVariable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MasterVariable" ALTER COLUMN id SET DEFAULT nextval('public."MasterVariable_id_seq"'::regclass);


--
-- Name: Menu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Menu" ALTER COLUMN id SET DEFAULT nextval('public."Menu_id_seq"'::regclass);


--
-- Name: Payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN id SET DEFAULT nextval('public."Payment_id_seq"'::regclass);


--
-- Name: PreQuotation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation" ALTER COLUMN id SET DEFAULT nextval('public."PreQuotation_id_seq"'::regclass);


--
-- Name: PreQuotationStateHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotationStateHistory" ALTER COLUMN id SET DEFAULT nextval('public."PreQuotationStateHistory_id_seq"'::regclass);


--
-- Name: Prestadora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Prestadora" ALTER COLUMN id SET DEFAULT nextval('public."Prestadora_id_seq"'::regclass);


--
-- Name: Product id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Product" ALTER COLUMN id SET DEFAULT nextval('public."Product_id_seq"'::regclass);


--
-- Name: Provider id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Provider" ALTER COLUMN id SET DEFAULT nextval('public."Provider_id_seq"'::regclass);


--
-- Name: ProviderType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProviderType" ALTER COLUMN id SET DEFAULT nextval('public."ProviderType_id_seq"'::regclass);


--
-- Name: Quotation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation" ALTER COLUMN id SET DEFAULT nextval('public."Quotation_id_seq"'::regclass);


--
-- Name: QuotationCombo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationCombo" ALTER COLUMN id SET DEFAULT nextval('public."QuotationCombo_id_seq"'::regclass);


--
-- Name: QuotationFormat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationFormat" ALTER COLUMN id SET DEFAULT nextval('public."QuotationFormat_id_seq"'::regclass);


--
-- Name: QuotationManualService id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationManualService" ALTER COLUMN id SET DEFAULT nextval('public."QuotationManualService_id_seq"'::regclass);


--
-- Name: QuotationPrintCustomization id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationPrintCustomization" ALTER COLUMN id SET DEFAULT nextval('public."QuotationPrintCustomization_id_seq"'::regclass);


--
-- Name: QuotationPrintDefaultTemplate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationPrintDefaultTemplate" ALTER COLUMN id SET DEFAULT nextval('public."QuotationPrintDefaultTemplate_id_seq"'::regclass);


--
-- Name: QuotationProduct id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProduct_id_seq"'::regclass);


--
-- Name: QuotationProductPassenger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPassenger" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductPassenger_id_seq"'::regclass);


--
-- Name: QuotationProductPayment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPayment" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductPayment_id_seq"'::regclass);


--
-- Name: QuotationProductTax id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductTax" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductTax_id_seq"'::regclass);


--
-- Name: QuotationProductVariable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductVariable" ALTER COLUMN id SET DEFAULT nextval('public."QuotationProductVariable_id_seq"'::regclass);


--
-- Name: QuotationState id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationState" ALTER COLUMN id SET DEFAULT nextval('public."QuotationState_id_seq"'::regclass);


--
-- Name: QuotationStateHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationStateHistory" ALTER COLUMN id SET DEFAULT nextval('public."QuotationStateHistory_id_seq"'::regclass);


--
-- Name: Report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Report" ALTER COLUMN id SET DEFAULT nextval('public."Report_id_seq"'::regclass);


--
-- Name: ReportColumns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportColumns" ALTER COLUMN id SET DEFAULT nextval('public."ReportColumns_id_seq"'::regclass);


--
-- Name: ReportFilters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportFilters" ALTER COLUMN id SET DEFAULT nextval('public."ReportFilters_id_seq"'::regclass);


--
-- Name: ReportJoins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportJoins" ALTER COLUMN id SET DEFAULT nextval('public."ReportJoins_id_seq"'::regclass);


--
-- Name: ReportSorts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportSorts" ALTER COLUMN id SET DEFAULT nextval('public."ReportSorts_id_seq"'::regclass);


--
-- Name: Resolution id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Resolution" ALTER COLUMN id SET DEFAULT nextval('public."Resolution_id_seq"'::regclass);


--
-- Name: Role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role" ALTER COLUMN id SET DEFAULT nextval('public."Role_id_seq"'::regclass);


--
-- Name: Seller id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Seller" ALTER COLUMN id SET DEFAULT nextval('public."Seller_id_seq"'::regclass);


--
-- Name: SysConsecutivo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SysConsecutivo" ALTER COLUMN id SET DEFAULT nextval('public."SysConsecutivo_id_seq"'::regclass);


--
-- Name: SystemLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SystemLog" ALTER COLUMN id SET DEFAULT nextval('public."SystemLog_id_seq"'::regclass);


--
-- Name: SystemParameter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SystemParameter" ALTER COLUMN id SET DEFAULT nextval('public."SystemParameter_id_seq"'::regclass);


--
-- Name: TicketPrinter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TicketPrinter" ALTER COLUMN id SET DEFAULT nextval('public."TicketPrinter_id_seq"'::regclass);


--
-- Name: TicketType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TicketType" ALTER COLUMN id SET DEFAULT nextval('public."TicketType_id_seq"'::regclass);


--
-- Name: TransactionConsecutive id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TransactionConsecutive" ALTER COLUMN id SET DEFAULT nextval('public."TransactionConsecutive_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Data for Name: Airports; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Airports" VALUES (1, 'BOG', 'Aeropuerto Internacional El Dorado', 1, true);
INSERT INTO public."Airports" VALUES (2, 'MDE', 'Aeropuerto Internacional Jose Maria Cordova', 2, true);
INSERT INTO public."Airports" VALUES (3, 'MIA', 'Miami International Airport', 3, true);
INSERT INTO public."Airports" VALUES (4, 'MAD', 'Adolfo Suarez Madrid-Barajas', 4, true);
INSERT INTO public."Airports" VALUES (5, 'AAP', 'Andrau Airpark', 5, true);
INSERT INTO public."Airports" VALUES (6, 'ABJ', 'Felix Houphouet Boigny Arpt', 53, true);
INSERT INTO public."Airports" VALUES (7, 'ACC', 'Kotoka Airport', 79, true);
INSERT INTO public."Airports" VALUES (8, 'ADD', 'Bole Airport', 98, true);
INSERT INTO public."Airports" VALUES (9, 'ADE', 'Yemen Intl Arpt', 99, true);
INSERT INTO public."Airports" VALUES (10, 'AEP', 'Jorge Newbery', 107, true);
INSERT INTO public."Airports" VALUES (11, 'AGB', 'Mehlhausen', 118, true);
INSERT INTO public."Airports" VALUES (12, 'AGP', 'Malaga Arpt', 81, true);
INSERT INTO public."Airports" VALUES (13, 'AJU', 'Santa Maria Arpt', 144, true);
INSERT INTO public."Airports" VALUES (14, 'AKL', 'Auckland Intl Arpt', 153, true);
INSERT INTO public."Airports" VALUES (15, 'ALC', 'Alicante Arpt', 80, true);
INSERT INTO public."Airports" VALUES (16, 'ALP', 'Nejrab Arpt', 159, true);
INSERT INTO public."Airports" VALUES (17, 'AMM', 'Queen Alia Intl Arpt', 161, true);
INSERT INTO public."Airports" VALUES (18, 'AMS', 'Schiphol Arpt', 162, true);
INSERT INTO public."Airports" VALUES (19, 'ANC', 'Anchorage Intl Arpt', 6, true);
INSERT INTO public."Airports" VALUES (20, 'ANF', 'Cerro Moreno Arpt', 163, true);
INSERT INTO public."Airports" VALUES (21, 'ANK', 'Etimesgut Arpt', 97, true);
INSERT INTO public."Airports" VALUES (22, 'ANR', 'Deurne Airport', 170, true);
INSERT INTO public."Airports" VALUES (23, 'AOH', 'Allen County Arpt', 7, true);
INSERT INTO public."Airports" VALUES (24, 'APA', 'Centennial Airport', 8, true);
INSERT INTO public."Airports" VALUES (25, 'APW', 'Apia Airport', 174, true);
INSERT INTO public."Airports" VALUES (26, 'AQP', 'Rodriguez Ballon Arpt', 175, true);
INSERT INTO public."Airports" VALUES (27, 'ARI', 'Chacalluta Arpt', 164, true);
INSERT INTO public."Airports" VALUES (28, 'ASM', 'Asmara Intl Arpt', 180, true);
INSERT INTO public."Airports" VALUES (29, 'ASU', 'Salvio Pettirosse Arpt', 181, true);
INSERT INTO public."Airports" VALUES (30, 'ATL', 'Hartsfield Intl Arpt', 9, true);
INSERT INTO public."Airports" VALUES (31, 'AUA', 'Reina Beatrix Arpt', 184, true);
INSERT INTO public."Airports" VALUES (32, 'AUH', 'Dhabi Intl Arpt', 185, true);
INSERT INTO public."Airports" VALUES (33, 'AUO', 'Auburn Opelika', 10, true);
INSERT INTO public."Airports" VALUES (34, 'AVI', 'Maximo Gomez Arpt', 192, true);
INSERT INTO public."Airports" VALUES (35, 'AYT', 'Antalya Airport', 96, true);
INSERT INTO public."Airports" VALUES (36, 'BAH', 'Muharraq Arpt', 194, true);
INSERT INTO public."Airports" VALUES (37, 'BCN', 'Barcelona Arpt', 82, true);
INSERT INTO public."Airports" VALUES (38, 'BDA', 'Bermuda International', 197, true);
INSERT INTO public."Airports" VALUES (39, 'BDL', 'Bradley Intl Arpt', 11, true);
INSERT INTO public."Airports" VALUES (40, 'BEL', 'Val De Cans Arpt', 143, true);
INSERT INTO public."Airports" VALUES (41, 'BER', 'Berlin Airports', 73, true);
INSERT INTO public."Airports" VALUES (42, 'BEY', 'Beirut Intl Arpt', 198, true);
INSERT INTO public."Airports" VALUES (43, 'BFI', 'Seattle Boeing Field', 12, true);
INSERT INTO public."Airports" VALUES (44, 'BFS', 'Belfast Intl Arpt', 65, true);
INSERT INTO public."Airports" VALUES (45, 'BGF', 'Bangui Airport', 201, true);
INSERT INTO public."Airports" VALUES (46, 'BGI', 'Grantley Adams Intl Arpt', 202, true);
INSERT INTO public."Airports" VALUES (47, 'BGO', 'Flesland Airport', 111, true);
INSERT INTO public."Airports" VALUES (48, 'BGW', 'Al Muthana Arpt', 203, true);
INSERT INTO public."Airports" VALUES (49, 'BHD', 'Belfast City Arpt', 65, true);
INSERT INTO public."Airports" VALUES (50, 'BHI', 'Commandante Airport', 106, true);
INSERT INTO public."Airports" VALUES (51, 'BIO', 'Sondica Arpt', 83, true);
INSERT INTO public."Airports" VALUES (52, 'BJL', 'Yundum Intl Arpt', 209, true);
INSERT INTO public."Airports" VALUES (53, 'BJM', 'Bujumbura Intl Arpt', 210, true);
INSERT INTO public."Airports" VALUES (54, 'BJS', 'Beijing', 206, true);
INSERT INTO public."Airports" VALUES (55, 'BKK', 'Bangkok Intl Arpt', 211, true);
INSERT INTO public."Airports" VALUES (56, 'BKL', 'Burke Lakefront Arpt', 13, true);
INSERT INTO public."Airports" VALUES (57, 'BKO', 'Senou Airport', 213, true);
INSERT INTO public."Airports" VALUES (58, 'BLA', 'Gen J A Anzoategui Arpt', 82, true);
INSERT INTO public."Airports" VALUES (59, 'BLZ', 'Chileka Airport', 218, true);
INSERT INTO public."Airports" VALUES (60, 'BNA', 'Nashville Metro Arpt', 14, true);
INSERT INTO public."Airports" VALUES (61, 'BOD', 'Merignac Arpt', 123, true);
INSERT INTO public."Airports" VALUES (62, 'BON', 'Flamingo Field', 219, true);
INSERT INTO public."Airports" VALUES (63, 'BOS', 'Logan Intl Arpt', 15, true);
INSERT INTO public."Airports" VALUES (64, 'BRI', 'Bari Airport', 132, true);
INSERT INTO public."Airports" VALUES (65, 'BSB', 'Brasilia Intl Arpt', 141, true);
INSERT INTO public."Airports" VALUES (66, 'BSR', 'Basra Intl Arpt', 204, true);
INSERT INTO public."Airports" VALUES (67, 'BTS', 'Ivanka Arpt', 223, true);
INSERT INTO public."Airports" VALUES (68, 'BUD', 'Ferihegy Arpt', 224, true);
INSERT INTO public."Airports" VALUES (69, 'BUE', 'Buenos Aires Airports', 107, true);
INSERT INTO public."Airports" VALUES (70, 'BUF', 'Greater Buffalo Intl Arpt', 16, true);
INSERT INTO public."Airports" VALUES (71, 'BUQ', 'Bulawayo Arpt', 225, true);
INSERT INTO public."Airports" VALUES (72, 'BWI', 'Baltimore Washington Intl Arpt', 17, true);
INSERT INTO public."Airports" VALUES (73, 'BZC', 'Buzios Arpt', 142, true);
INSERT INTO public."Airports" VALUES (74, 'BZV', 'Maya Maya Arpt', 227, true);
INSERT INTO public."Airports" VALUES (75, 'CAI', 'Cairo Intl Arpt', 160, true);
INSERT INTO public."Airports" VALUES (76, 'CAN', 'Baiyun Airport', 205, true);
INSERT INTO public."Airports" VALUES (77, 'CAS', 'Anfa Airport', 113, true);
INSERT INTO public."Airports" VALUES (78, 'CAY', 'Rochambeau Airport', 230, true);
INSERT INTO public."Airports" VALUES (79, 'CBB', 'J Wilsterman Arpt', 228, true);
INSERT INTO public."Airports" VALUES (80, 'CCS', 'Simon Bolivar Arpt', 214, true);
INSERT INTO public."Airports" VALUES (81, 'CDG', 'Charles De Gaulle Intl Arpt', 122, true);
INSERT INTO public."Airports" VALUES (82, 'CGB', 'Marechal Rondon Arpt', 147, true);
INSERT INTO public."Airports" VALUES (83, 'CGF', 'Cuyahoga County Airport', 13, true);
INSERT INTO public."Airports" VALUES (84, 'CGK', 'Soekarno Hatta Intl', 131, true);
INSERT INTO public."Airports" VALUES (85, 'CGX', 'Meigs Field', 18, true);
INSERT INTO public."Airports" VALUES (86, 'CHC', 'Christchurch Intl Arpt', 152, true);
INSERT INTO public."Airports" VALUES (87, 'CHI', 'Chicago Airports', 18, true);
INSERT INTO public."Airports" VALUES (88, 'CHS', 'Charleston Intl Arpt', 19, true);
INSERT INTO public."Airports" VALUES (89, 'CKY', 'Conakry Airport', 234, true);
INSERT INTO public."Airports" VALUES (90, 'CLE', 'Hopkins Intl Arpt', 13, true);
INSERT INTO public."Airports" VALUES (91, 'CLU', 'Columbus Municipal Arpt', 10, true);
INSERT INTO public."Airports" VALUES (92, 'CMB', 'Katunayake Arpt', 235, true);
INSERT INTO public."Airports" VALUES (93, 'CMH', 'Port Columbus Intl Arpt', 10, true);
INSERT INTO public."Airports" VALUES (94, 'CMN', 'Mohamed V Arpt', 113, true);
INSERT INTO public."Airports" VALUES (95, 'CNF', 'Tancredo Neves Intl Arpt.', 145, true);
INSERT INTO public."Airports" VALUES (96, 'CNS', 'Cairns Airport', 63, true);
INSERT INTO public."Airports" VALUES (97, 'COO', 'Cotonou Airport', 236, true);
INSERT INTO public."Airports" VALUES (98, 'CPT', 'Cape Town International', 158, true);
INSERT INTO public."Airports" VALUES (99, 'CRW', 'Yeager Arpt', 19, true);
INSERT INTO public."Airports" VALUES (100, 'CSG', 'Columbus Metro Ft Benning Arpt', 10, true);
INSERT INTO public."Airports" VALUES (101, 'CUN', 'Cancun Aeropuerto Internacional', 77, true);
INSERT INTO public."Airports" VALUES (102, 'CUS', 'Columbus Municipal', 10, true);
INSERT INTO public."Airports" VALUES (103, 'CWB', 'Afonso Pena Arpt', 146, true);
INSERT INTO public."Airports" VALUES (104, 'CXH', 'Coal Harbor Sea Plane Arpt', 246, true);
INSERT INTO public."Airports" VALUES (105, 'CYR', 'Colonia Arpt', 247, true);
INSERT INTO public."Airports" VALUES (106, 'CZM', 'Aeropuerto Intl De Cozumel', 78, true);
INSERT INTO public."Airports" VALUES (107, 'DAC', 'Zia Intl Airport', 233, true);
INSERT INTO public."Airports" VALUES (108, 'DAL', 'Love Field', 20, true);
INSERT INTO public."Airports" VALUES (109, 'DAR', 'Es Salaam Intl', 250, true);
INSERT INTO public."Airports" VALUES (110, 'DAY', 'Dayton International Airport', 21, true);
INSERT INTO public."Airports" VALUES (111, 'DBN', 'Dublin Municipal Arpt', 22, true);
INSERT INTO public."Airports" VALUES (112, 'DEL', 'Delhi Indira Gandhi Intl', 128, true);
INSERT INTO public."Airports" VALUES (113, 'DEN', 'Denver Intl Arpt', 8, true);
INSERT INTO public."Airports" VALUES (114, 'DET', 'Detroit City Apt', 23, true);
INSERT INTO public."Airports" VALUES (115, 'DFW', 'Dallas Ft Worth Intl', 20, true);
INSERT INTO public."Airports" VALUES (116, 'DHA', 'Dhahran Intl', 54, true);
INSERT INTO public."Airports" VALUES (117, 'DKR', 'Yoff Airport', 252, true);
INSERT INTO public."Airports" VALUES (118, 'DLA', 'Douala Arpt', 253, true);
INSERT INTO public."Airports" VALUES (119, 'DLC', 'Dalian Airport', 207, true);
INSERT INTO public."Airports" VALUES (120, 'DOH', 'Doha Airport', 255, true);
INSERT INTO public."Airports" VALUES (121, 'DPS', 'Ngurah Rai Arpt', 130, true);
INSERT INTO public."Airports" VALUES (122, 'DTW', 'Detroit Metro Arpt', 23, true);
INSERT INTO public."Airports" VALUES (123, 'DUB', 'Dublin Arpt', 22, true);
INSERT INTO public."Airports" VALUES (124, 'DUR', 'Durban International', 157, true);
INSERT INTO public."Airports" VALUES (125, 'DUS', 'Dusseldorf Arpt', 120, true);
INSERT INTO public."Airports" VALUES (126, 'DWH', 'David Wayne Hooks Arpt', 5, true);
INSERT INTO public."Airports" VALUES (127, 'DXB', 'Dubai Intl Arpt', 186, true);
INSERT INTO public."Airports" VALUES (128, 'EAP', 'Mulhouse/Basel Airports', 220, true);
INSERT INTO public."Airports" VALUES (129, 'EFD', 'Ellington Field', 5, true);
INSERT INTO public."Airports" VALUES (130, 'ERS', 'Eros Arpt', 258, true);
INSERT INTO public."Airports" VALUES (131, 'ESB', 'Esenboga Arpt', 97, true);
INSERT INTO public."Airports" VALUES (132, 'EWR', 'Newark Intl Arpt', 24, true);
INSERT INTO public."Airports" VALUES (133, 'EZE', 'Ministro Pistarini', 107, true);
INSERT INTO public."Airports" VALUES (134, 'FAO', 'Faro Airport', 231, true);
INSERT INTO public."Airports" VALUES (135, 'FBM', 'Luano', 261, true);
INSERT INTO public."Airports" VALUES (136, 'FBU', 'Fornebu Arpt', 112, true);
INSERT INTO public."Airports" VALUES (137, 'FIH', 'Kinshasa Arpt', 262, true);
INSERT INTO public."Airports" VALUES (138, 'FNA', 'Lungi Intl Arpt', 263, true);
INSERT INTO public."Airports" VALUES (139, 'FOR', 'Pinto Martines Arpt', 150, true);
INSERT INTO public."Airports" VALUES (140, 'FPO', 'Freeport Intl Arpt', 182, true);
INSERT INTO public."Airports" VALUES (141, 'FRA', 'Frankfurt Intl', 121, true);
INSERT INTO public."Airports" VALUES (142, 'FTY', 'Fulton Cty Arpt', 9, true);
INSERT INTO public."Airports" VALUES (143, 'FUK', 'Itazuke Arpt', 177, true);
INSERT INTO public."Airports" VALUES (144, 'GBE', 'Gaborone Arpt', 195, true);
INSERT INTO public."Airports" VALUES (145, 'GDL', 'Miguel Hidalgo Arpt', 76, true);
INSERT INTO public."Airports" VALUES (146, 'GED', 'Sussex County Arpt', 25, true);
INSERT INTO public."Airports" VALUES (147, 'GEN', 'Gardermoen Arpt', 112, true);
INSERT INTO public."Airports" VALUES (148, 'GEO', 'Timehri Airport', 25, true);
INSERT INTO public."Airports" VALUES (149, 'GGW', 'International Glasgow', 26, true);
INSERT INTO public."Airports" VALUES (150, 'GIB', 'North Front Arpt', 264, true);
INSERT INTO public."Airports" VALUES (151, 'GIG', 'Rio Internacional', 151, true);
INSERT INTO public."Airports" VALUES (152, 'GLA', 'Glasgow Arpt', 26, true);
INSERT INTO public."Airports" VALUES (153, 'GRX', 'Granada Arpt', 84, true);
INSERT INTO public."Airports" VALUES (154, 'GRZ', 'Thalerhof Arpt', 265, true);
INSERT INTO public."Airports" VALUES (155, 'GTR', 'Golden Arpt', 10, true);
INSERT INTO public."Airports" VALUES (156, 'GYE', 'Simon Bolivar Airport', 237, true);
INSERT INTO public."Airports" VALUES (157, 'GYM', 'Gen Jose M Yanez Arpt', 75, true);
INSERT INTO public."Airports" VALUES (158, 'GYN', 'Santa Genoveva', 149, true);
INSERT INTO public."Airports" VALUES (159, 'HBA', 'Hobart Arpt', 64, true);
INSERT INTO public."Airports" VALUES (160, 'HEL', 'Helsinki Arpt', 273, true);
INSERT INTO public."Airports" VALUES (161, 'HFD', 'Brainard Arpt', 11, true);
INSERT INTO public."Airports" VALUES (162, 'HKG', 'Hong Kong Intl', 274, true);
INSERT INTO public."Airports" VALUES (163, 'HKT', 'Phuket Intl Airport', 212, true);
INSERT INTO public."Airports" VALUES (164, 'HMA', 'Malmo City Hvc Arpt', 127, true);
INSERT INTO public."Airports" VALUES (165, 'HNL', 'Honolulu Intl', 27, true);
INSERT INTO public."Airports" VALUES (166, 'HOG', 'Frank Pias Arpt', 191, true);
INSERT INTO public."Airports" VALUES (167, 'HOU', 'Houston Hobby Arpt', 5, true);
INSERT INTO public."Airports" VALUES (168, 'HRE', 'Harare Arpt', 226, true);
INSERT INTO public."Airports" VALUES (169, 'IAH', 'Houston Intl', 5, true);
INSERT INTO public."Airports" VALUES (170, 'IBZ', 'Ibiza Airport', 85, true);
INSERT INTO public."Airports" VALUES (171, 'IEV', 'Zhulhany Arpt', 275, true);
INSERT INTO public."Airports" VALUES (172, 'IOS', 'Eduardo Gomes Airport', 148, true);
INSERT INTO public."Airports" VALUES (173, 'IQQ', 'Cavancha Chucumata Arpt', 165, true);
INSERT INTO public."Airports" VALUES (174, 'ISB', 'Islamabad Intl', 272, true);
INSERT INTO public."Airports" VALUES (175, 'ITM', 'Itami Arpt', 176, true);
INSERT INTO public."Airports" VALUES (176, 'IWS', 'West Houston', 5, true);
INSERT INTO public."Airports" VALUES (177, 'JAJ', 'Perimeter Hlpt', 9, true);
INSERT INTO public."Airports" VALUES (178, 'JAO', 'Beaver Ruin Helpt', 9, true);
INSERT INTO public."Airports" VALUES (179, 'JBP', 'Commerce Business Plaza Heliport', 28, true);
INSERT INTO public."Airports" VALUES (180, 'JCC', 'China Basin Hlpt', 29, true);
INSERT INTO public."Airports" VALUES (181, 'JDP', 'Issy Les Moulineaux Arpt', 122, true);
INSERT INTO public."Airports" VALUES (182, 'JED', 'Jeddah Intl', 56, true);
INSERT INTO public."Airports" VALUES (183, 'JFK', 'John F Kennedy Intl', 30, true);
INSERT INTO public."Airports" VALUES (184, 'JKT', 'Kemayoran Arpt', 131, true);
INSERT INTO public."Airports" VALUES (185, 'JPA', 'Castro Pinto Arpt', 138, true);
INSERT INTO public."Airports" VALUES (186, 'JRE', 'East 60th St Hlpt', 30, true);
INSERT INTO public."Airports" VALUES (187, 'JRS', 'Atarot Airport', 260, true);
INSERT INTO public."Airports" VALUES (188, 'JTO', 'Thousand Oaks Hlpt', 28, true);
INSERT INTO public."Airports" VALUES (189, 'KAN', 'Aminu Kano Intl Arpt', 57, true);
INSERT INTO public."Airports" VALUES (190, 'KBP', 'Borispol Arpt', 275, true);
INSERT INTO public."Airports" VALUES (191, 'KGL', 'Kayibanda Arpt', 276, true);
INSERT INTO public."Airports" VALUES (192, 'KHH', 'Kaohsiung Intl', 269, true);
INSERT INTO public."Airports" VALUES (193, 'KHI', 'Karachi Arpt', 271, true);
INSERT INTO public."Airports" VALUES (194, 'KIN', 'Norman Manly Arpt', 277, true);
INSERT INTO public."Airports" VALUES (195, 'KIX', 'Kansai International Arpt', 176, true);
INSERT INTO public."Airports" VALUES (196, 'KLU', 'Klagenfurt Arpt', 266, true);
INSERT INTO public."Airports" VALUES (197, 'KRS', 'Kjevik Airport', 109, true);
INSERT INTO public."Airports" VALUES (198, 'KRT', 'Civil Arpt', 279, true);
INSERT INTO public."Airports" VALUES (199, 'KTP', 'Tinson Arpt', 277, true);
INSERT INTO public."Airports" VALUES (200, 'KUL', 'Subang Kuala Lumpur Intl', 171, true);
INSERT INTO public."Airports" VALUES (201, 'KWI', 'Kuwait Intl', 280, true);
INSERT INTO public."Airports" VALUES (202, 'LAD', 'Four De Fevereiro Arpt', 281, true);
INSERT INTO public."Airports" VALUES (203, 'LAP', 'Aeropuerto Gen Marquez De Leon', 68, true);
INSERT INTO public."Airports" VALUES (204, 'LAS', 'McCarran Intl', 31, true);
INSERT INTO public."Airports" VALUES (205, 'LAX', 'Los Angeles Intl', 28, true);
INSERT INTO public."Airports" VALUES (206, 'LBA', 'Leeds Bradford Arpt', 67, true);
INSERT INTO public."Airports" VALUES (207, 'LBG', 'Le Bourget Arpt', 122, true);
INSERT INTO public."Airports" VALUES (208, 'LBH', 'Palm Beach Arpt', 59, true);
INSERT INTO public."Airports" VALUES (209, 'LBV', 'Libreville Arpt', 282, true);
INSERT INTO public."Airports" VALUES (210, 'LCA', 'Larnaca Intl', 256, true);
INSERT INTO public."Airports" VALUES (211, 'LEH', 'Octeville Arpt', 125, true);
INSERT INTO public."Airports" VALUES (212, 'LEJ', 'Schkeuditz Arpt', 117, true);
INSERT INTO public."Airports" VALUES (213, 'LFW', 'Lome Airport', 283, true);
INSERT INTO public."Airports" VALUES (214, 'LGA', 'La Guardia', 30, true);
INSERT INTO public."Airports" VALUES (215, 'LGB', 'Long Beach Municipal', 32, true);
INSERT INTO public."Airports" VALUES (216, 'LIL', 'Lesquin Arpt', 126, true);
INSERT INTO public."Airports" VALUES (217, 'LIM', 'Nlima Intl Jorge Chavez', 7, true);
INSERT INTO public."Airports" VALUES (218, 'LIN', 'Linate Arpt', 133, true);
INSERT INTO public."Airports" VALUES (219, 'LJU', 'Brnik Airport', 285, true);
INSERT INTO public."Airports" VALUES (220, 'LKE', 'Lake Union Seaplane Base', 12, true);
INSERT INTO public."Airports" VALUES (221, 'LLW', 'Lilongwe Intl Arpt', 217, true);
INSERT INTO public."Airports" VALUES (222, 'LNZ', 'Hoersching Arpt', 267, true);
INSERT INTO public."Airports" VALUES (223, 'LOS', 'Murtala Muhammed Arpt', 58, true);
INSERT INTO public."Airports" VALUES (224, 'LPB', 'El Alto Arpt', 68, true);
INSERT INTO public."Airports" VALUES (225, 'LSC', 'La Florida', 169, true);
INSERT INTO public."Airports" VALUES (226, 'LUN', 'Lusaka Airport', 286, true);
INSERT INTO public."Airports" VALUES (227, 'LUQ', 'San Luis Cty Arpt', 108, true);
INSERT INTO public."Airports" VALUES (228, 'LVS', 'Las Vegas Arpt', 31, true);
INSERT INTO public."Airports" VALUES (229, 'LYS', 'Satolas Airport', 124, true);
INSERT INTO public."Airports" VALUES (230, 'MAA', 'Meenambarkkam Arpt', 129, true);
INSERT INTO public."Airports" VALUES (232, 'MAH', 'Aerop De Menorca', 95, true);
INSERT INTO public."Airports" VALUES (233, 'MAR', 'La Chinita Arpt', 216, true);
INSERT INTO public."Airports" VALUES (234, 'MBJ', 'Sangster Arpt', 278, true);
INSERT INTO public."Airports" VALUES (235, 'MCO', 'Orlando Intl Arpt', 33, true);
INSERT INTO public."Airports" VALUES (236, 'MCT', 'Seeb Intl', 288, true);
INSERT INTO public."Airports" VALUES (237, 'MCZ', 'Palmeres Airport', 139, true);
INSERT INTO public."Airports" VALUES (238, 'MDW', 'Midway', 18, true);
INSERT INTO public."Airports" VALUES (239, 'MEB', 'Essendon Arpt', 60, true);
INSERT INTO public."Airports" VALUES (241, 'MEL', 'Tullamarine Arpt', 60, true);
INSERT INTO public."Airports" VALUES (242, 'MEM', 'Memphis Intl', 34, true);
INSERT INTO public."Airports" VALUES (243, 'MGA', 'Augusto C Sandino', 289, true);
INSERT INTO public."Airports" VALUES (245, 'MID', 'Merida Intl', 69, true);
INSERT INTO public."Airports" VALUES (246, 'MIL', 'Milan Airports', 133, true);
INSERT INTO public."Airports" VALUES (247, 'MJV', 'San Javier Airport', 93, true);
INSERT INTO public."Airports" VALUES (248, 'MKE', 'General Mitchell Fld', 36, true);
INSERT INTO public."Airports" VALUES (249, 'MLA', 'Luqa Airport', 268, true);
INSERT INTO public."Airports" VALUES (250, 'MLB', 'Melbourne Regional', 60, true);
INSERT INTO public."Airports" VALUES (251, 'MLH', 'Euroairport French', 220, true);
INSERT INTO public."Airports" VALUES (252, 'MLW', 'Sprigg Payne Arpt', 290, true);
INSERT INTO public."Airports" VALUES (253, 'MMA', 'Malmo Airports', 127, true);
INSERT INTO public."Airports" VALUES (254, 'MME', 'Teesside Arpt', 66, true);
INSERT INTO public."Airports" VALUES (255, 'MMX', 'Sturup Arpt', 127, true);
INSERT INTO public."Airports" VALUES (256, 'MNL', 'Ninoy Aquino Intl', 193, true);
INSERT INTO public."Airports" VALUES (257, 'MPM', 'Maputo Intl', 173, true);
INSERT INTO public."Airports" VALUES (258, 'MRD', 'Alberto Carnevalli Arpt', 69, true);
INSERT INTO public."Airports" VALUES (259, 'MSP', 'Minneapolis St Paul Intl', 37, true);
INSERT INTO public."Airports" VALUES (260, 'MSY', 'Moisant Intl', 38, true);
INSERT INTO public."Airports" VALUES (261, 'MTC', 'Selfridge Air Natl Guard', 23, true);
INSERT INTO public."Airports" VALUES (262, 'MTY', 'Escobedo Arpt', 71, true);
INSERT INTO public."Airports" VALUES (263, 'MUC', 'Franz Josef Strauss Arpt', 118, true);
INSERT INTO public."Airports" VALUES (264, 'MVD', 'Carrasco Arpt', 249, true);
INSERT INTO public."Airports" VALUES (265, 'MXP', 'Malpensa Arpt', 133, true);
INSERT INTO public."Airports" VALUES (266, 'MYF', 'Montogomery Fld', 39, true);
INSERT INTO public."Airports" VALUES (267, 'MZO', 'Sierra Maestra Arpt', 190, true);
INSERT INTO public."Airports" VALUES (268, 'MZT', 'Buelina Arpt', 70, true);
INSERT INTO public."Airports" VALUES (269, 'NAN', 'Nadi Intl', 199, true);
INSERT INTO public."Airports" VALUES (270, 'NAS', 'Nassau Intl', 183, true);
INSERT INTO public."Airports" VALUES (271, 'NAT', 'Augusto Severo Intl Arpt', 140, true);
INSERT INTO public."Airports" VALUES (272, 'NBO', 'Jomo Kenyatta Intl', 287, true);
INSERT INTO public."Airports" VALUES (273, 'NEW', 'New Lakefront Arpt', 38, true);
INSERT INTO public."Airports" VALUES (274, 'NGO', 'Komaki Arpt', 178, true);
INSERT INTO public."Airports" VALUES (275, 'NIM', 'Niamey Airport', 292, true);
INSERT INTO public."Airports" VALUES (276, 'NKC', 'Nouakchott Arpt', 291, true);
INSERT INTO public."Airports" VALUES (277, 'NQA', 'Memphis Naval Air Station', 34, true);
INSERT INTO public."Airports" VALUES (278, 'NSI', 'Nsimalen Arpt', 254, true);
INSERT INTO public."Airports" VALUES (279, 'NYC', 'New York City Area Airports', 30, true);
INSERT INTO public."Airports" VALUES (280, 'OFK', 'Karl Stefan Fld', 40, true);
INSERT INTO public."Airports" VALUES (281, 'OKA', 'Naha Field', 179, true);
INSERT INTO public."Airports" VALUES (282, 'OLU', 'Columbus Arpt', 10, true);
INSERT INTO public."Airports" VALUES (283, 'OPF', 'Opa Locka Arpt', 3, true);
INSERT INTO public."Airports" VALUES (284, 'ORD', 'OHare Intl Arpt', 18, true);
INSERT INTO public."Airports" VALUES (285, 'ORL', 'Herndon Arpt', 33, true);
INSERT INTO public."Airports" VALUES (286, 'ORY', 'Orly Arpt', 122, true);
INSERT INTO public."Airports" VALUES (287, 'OSA', 'Osaka', 176, true);
INSERT INTO public."Airports" VALUES (288, 'OSL', 'Oslo Airports', 112, true);
INSERT INTO public."Airports" VALUES (289, 'OSU', 'Ohio State Univ Arpt', 10, true);
INSERT INTO public."Airports" VALUES (290, 'PAP', 'Mais Gate Arpt', 229, true);
INSERT INTO public."Airports" VALUES (291, 'PAR', 'Paris Airports', 122, true);
INSERT INTO public."Airports" VALUES (292, 'PBM', 'Zanderij Intl Arpt', 293, true);
INSERT INTO public."Airports" VALUES (293, 'PDK', 'Dekalb Peachtree', 9, true);
INSERT INTO public."Airports" VALUES (294, 'PDP', 'Cap Curbelo Arpt', 248, true);
INSERT INTO public."Airports" VALUES (295, 'PDX', 'Portland Intl Arpt', 41, true);
INSERT INTO public."Airports" VALUES (296, 'PEK', 'Beijing Capital Arpt', 206, true);
INSERT INTO public."Airports" VALUES (297, 'PEN', 'Penang Intl Arpt', 172, true);
INSERT INTO public."Airports" VALUES (298, 'PER', 'Perth Arpt', 62, true);
INSERT INTO public."Airports" VALUES (299, 'PFO', 'Paphos Intl Airport', 257, true);
INSERT INTO public."Airports" VALUES (300, 'PHT', 'Henry County Arpt', 122, true);
INSERT INTO public."Airports" VALUES (301, 'PHX', 'Sky Harbor Intl Arpt', 42, true);
INSERT INTO public."Airports" VALUES (302, 'PID', 'Paradise Island Arpt', 183, true);
INSERT INTO public."Airports" VALUES (303, 'PIK', 'Prestwick Arpt', 26, true);
INSERT INTO public."Airports" VALUES (304, 'PLZ', 'Port Elizabeth Airport', 156, true);
INSERT INTO public."Airports" VALUES (305, 'PMC', 'Tepual Airport', 166, true);
INSERT INTO public."Airports" VALUES (306, 'PMO', 'Punta Raisi Arpt', 134, true);
INSERT INTO public."Airports" VALUES (307, 'PMV', 'Delcaribe Gen S Marino Arpt', 215, true);
INSERT INTO public."Airports" VALUES (308, 'PNA', 'Pamplona Noain Arpt', 92, true);
INSERT INTO public."Airports" VALUES (309, 'POA', 'Porto Alegre Airport', 135, true);
INSERT INTO public."Airports" VALUES (310, 'PPT', 'Intl Tahiti Faaa', 188, true);
INSERT INTO public."Airports" VALUES (311, 'PRX', 'Paris Cox Field Arpt', 122, true);
INSERT INTO public."Airports" VALUES (312, 'PRY', 'Wonderboom Arpt', 155, true);
INSERT INTO public."Airports" VALUES (313, 'PSK', 'New River Valley Arpt', 22, true);
INSERT INTO public."Airports" VALUES (314, 'PTJ', 'Portland Arpt', 41, true);
INSERT INTO public."Airports" VALUES (315, 'PUQ', 'Presidente Ibanez Arpt', 167, true);
INSERT INTO public."Airports" VALUES (316, 'PVR', 'Ordaz Arpt', 72, true);
INSERT INTO public."Airports" VALUES (317, 'PWK', 'Pal Waukee Arpt', 18, true);
INSERT INTO public."Airports" VALUES (318, 'PWM', 'Portland Intl Jetport', 41, true);
INSERT INTO public."Airports" VALUES (319, 'QBA', 'San Francisco Bay Area Airpts', 29, true);
INSERT INTO public."Airports" VALUES (320, 'QDF', 'Dallas Area Airports', 20, true);
INSERT INTO public."Airports" VALUES (321, 'QGV', 'Neu Isenburg Arpt', 121, true);
INSERT INTO public."Airports" VALUES (322, 'QHO', 'Houston Airports', 5, true);
INSERT INTO public."Airports" VALUES (323, 'QKN', 'Kingston Airports', 277, true);
INSERT INTO public."Airports" VALUES (324, 'QLA', 'Los Angeles Area Airports', 28, true);
INSERT INTO public."Airports" VALUES (325, 'QMI', 'Miami Area Airports', 3, true);
INSERT INTO public."Airports" VALUES (326, 'QRV', 'Arras Arpt', 126, true);
INSERT INTO public."Airports" VALUES (327, 'QSE', 'Seattle Area Airports', 12, true);
INSERT INTO public."Airports" VALUES (328, 'RAC', 'Horlick Arpt', 36, true);
INSERT INTO public."Airports" VALUES (329, 'RAK', 'Menara Airport', 114, true);
INSERT INTO public."Airports" VALUES (330, 'RBA', 'Sale Airport', 115, true);
INSERT INTO public."Airports" VALUES (331, 'RDU', 'Raleigh Durham Intl Arpt', 43, true);
INSERT INTO public."Airports" VALUES (332, 'REC', 'Recife Airport', 136, true);
INSERT INTO public."Airports" VALUES (333, 'RIC', 'Byrd Intl', 44, true);
INSERT INTO public."Airports" VALUES (334, 'RIO', 'Rio De Janeiro Airports', 151, true);
INSERT INTO public."Airports" VALUES (335, 'RMA', 'Roma Arpt', 61, true);
INSERT INTO public."Airports" VALUES (336, 'ROB', 'Roberts Intl', 290, true);
INSERT INTO public."Airports" VALUES (337, 'ROC', 'Monroe Cty Arpt New York', 45, true);
INSERT INTO public."Airports" VALUES (338, 'RSE', 'Au Rose Bay Arpt', 59, true);
INSERT INTO public."Airports" VALUES (339, 'RST', 'Rochester Municipal', 45, true);
INSERT INTO public."Airports" VALUES (340, 'RUH', 'King Khaled Intl', 55, true);
INSERT INTO public."Airports" VALUES (341, 'SAL', 'El Salvador Intl Arpt', 296, true);
INSERT INTO public."Airports" VALUES (342, 'SAN', 'Lindbergh Intl Arpt', 39, true);
INSERT INTO public."Airports" VALUES (343, 'SAP', 'La Mesa Airport', 294, true);
INSERT INTO public."Airports" VALUES (344, 'SAT', 'San Antonio Intl', 46, true);
INSERT INTO public."Airports" VALUES (345, 'SAV', 'Travis Field', 47, true);
INSERT INTO public."Airports" VALUES (346, 'SDA', 'Saddam Intl', 203, true);
INSERT INTO public."Airports" VALUES (347, 'SDM', 'Brown Fld Municipal', 39, true);
INSERT INTO public."Airports" VALUES (348, 'SDQ', 'Las Americas Arpt', 222, true);
INSERT INTO public."Airports" VALUES (349, 'SDR', 'Santander Airport', 91, true);
INSERT INTO public."Airports" VALUES (350, 'SDU', 'Santos Dumont Arpt', 151, true);
INSERT INTO public."Airports" VALUES (351, 'SDV', 'Dov Airport', 259, true);
INSERT INTO public."Airports" VALUES (352, 'SEA', 'Seattle Tacoma Intl Arpt', 12, true);
INSERT INTO public."Airports" VALUES (353, 'SEZ', 'Seychelles Intl Arpt', 297, true);
INSERT INTO public."Airports" VALUES (354, 'SFO', 'San Francisco Intl Arpt', 29, true);
INSERT INTO public."Airports" VALUES (355, 'SHA', 'Shanghai Intl Hongqiao', 208, true);
INSERT INTO public."Airports" VALUES (356, 'SHJ', 'Sharjah Airport', 187, true);
INSERT INTO public."Airports" VALUES (357, 'SJJ', 'Butmir Arpt', 298, true);
INSERT INTO public."Airports" VALUES (358, 'SLC', 'Salt Lake City Intl Arpt', 48, true);
INSERT INTO public."Airports" VALUES (359, 'SMO', 'Santa Monica Municipal Arpt', 28, true);
INSERT INTO public."Airports" VALUES (360, 'SNN', 'Shannon Arpt', 232, true);
INSERT INTO public."Airports" VALUES (361, 'SOF', 'Sofia Intl', 299, true);
INSERT INTO public."Airports" VALUES (362, 'SSA', 'Dois De Julho Arpt', 137, true);
INSERT INTO public."Airports" VALUES (363, 'STD', 'Mayor Humberto Vivas Guerrero Arpt', 222, true);
INSERT INTO public."Airports" VALUES (364, 'STR', 'Eghterdingen Arpt', 116, true);
INSERT INTO public."Airports" VALUES (365, 'SUV', 'Nausori Airport', 200, true);
INSERT INTO public."Airports" VALUES (366, 'SVG', 'Sola Airport', 110, true);
INSERT INTO public."Airports" VALUES (367, 'SVQ', 'San Pablo Arpt', 86, true);
INSERT INTO public."Airports" VALUES (368, 'SVZ', 'San Antonio Arpt', 46, true);
INSERT INTO public."Airports" VALUES (369, 'SXF', 'Schoenefeld Arpt', 73, true);
INSERT INTO public."Airports" VALUES (370, 'SYD', 'Sydney Kingsford Smith Arpt', 59, true);
INSERT INTO public."Airports" VALUES (371, 'TAM', 'General F Javier Mina', 74, true);
INSERT INTO public."Airports" VALUES (372, 'TGU', 'Toncontin Arpt', 295, true);
INSERT INTO public."Airports" VALUES (373, 'THF', 'Tempelhof Arpt', 73, true);
INSERT INTO public."Airports" VALUES (374, 'THR', 'Mehrabad Arpt', 300, true);
INSERT INTO public."Airports" VALUES (375, 'TIA', 'Rinas Arpt', 301, true);
INSERT INTO public."Airports" VALUES (376, 'TLV', 'Ben Gurion Intl Arpt', 259, true);
INSERT INTO public."Airports" VALUES (377, 'TMB', 'Tamiami Airport', 3, true);
INSERT INTO public."Airports" VALUES (378, 'TPA', 'Tampa Intl', 49, true);
INSERT INTO public."Airports" VALUES (379, 'TPE', 'Chiang Kai Shek Arpt', 270, true);
INSERT INTO public."Airports" VALUES (380, 'TPF', 'Peter O Knight Arpt', 49, true);
INSERT INTO public."Airports" VALUES (381, 'TSR', 'Timisoara Arpt', 196, true);
INSERT INTO public."Airports" VALUES (382, 'TSS', 'East 34th St Hlpt', 30, true);
INSERT INTO public."Airports" VALUES (383, 'TUS', 'Tucson Intl Arpt', 50, true);
INSERT INTO public."Airports" VALUES (384, 'TXL', 'Tegel Airport', 73, true);
INSERT INTO public."Airports" VALUES (385, 'UBS', 'Lowndes Cty Arpt', 10, true);
INSERT INTO public."Airports" VALUES (386, 'UIO', 'Mariscal Arpt', 238, true);
INSERT INTO public."Airports" VALUES (387, 'UIZ', 'Berz Macomb Arpt', 23, true);
INSERT INTO public."Airports" VALUES (388, 'VCT', 'Victoria Regional Arpt', 51, true);
INSERT INTO public."Airports" VALUES (389, 'VER', 'Las Bajadas General Heriberto Jara', 73, true);
INSERT INTO public."Airports" VALUES (390, 'VGO', 'Vigo Airport', 87, true);
INSERT INTO public."Airports" VALUES (391, 'VGT', 'Las Vegas North Air Terminal', 31, true);
INSERT INTO public."Airports" VALUES (392, 'VIT', 'Vitoria Arpt', 88, true);
INSERT INTO public."Airports" VALUES (393, 'VIX', 'Eurico Sales Arpt', 88, true);
INSERT INTO public."Airports" VALUES (394, 'VLC', 'Valencia Arpt', 89, true);
INSERT INTO public."Airports" VALUES (395, 'VNY', 'Los Angeles Van Nuys Arpt', 28, true);
INSERT INTO public."Airports" VALUES (396, 'VPZ', 'Porter County', 52, true);
INSERT INTO public."Airports" VALUES (397, 'VRA', 'Juan Gualberto Gomez Arpt', 189, true);
INSERT INTO public."Airports" VALUES (398, 'WDH', 'Windhoek Intl Arpt', 258, true);
INSERT INTO public."Airports" VALUES (399, 'WIL', 'Wilson Airport', 287, true);
INSERT INTO public."Airports" VALUES (400, 'WLG', 'Wellington Intl', 154, true);
INSERT INTO public."Airports" VALUES (401, 'WZY', 'Seaplane Base Arpt', 183, true);
INSERT INTO public."Airports" VALUES (402, 'YAO', 'Yaounde Airport', 254, true);
INSERT INTO public."Airports" VALUES (403, 'YBZ', 'Downtown Hlpt Toronto', 239, true);
INSERT INTO public."Airports" VALUES (404, 'YEA', 'Edmonton Airports', 240, true);
INSERT INTO public."Airports" VALUES (405, 'YED', 'Namao Field', 240, true);
INSERT INTO public."Airports" VALUES (406, 'YEG', 'Edmonton Intl Arpt', 240, true);
INSERT INTO public."Airports" VALUES (407, 'YGK', 'Norman Rodgers Arpt', 277, true);
INSERT INTO public."Airports" VALUES (408, 'YHU', 'St Hubert Arpt', 241, true);
INSERT INTO public."Airports" VALUES (409, 'YIP', 'Willow Run Arpt', 23, true);
INSERT INTO public."Airports" VALUES (410, 'YKZ', 'Buttonville Arpt', 239, true);
INSERT INTO public."Airports" VALUES (411, 'YMQ', 'Montreal Airports', 241, true);
INSERT INTO public."Airports" VALUES (412, 'YMX', 'Mirabel Intl Arpt', 241, true);
INSERT INTO public."Airports" VALUES (413, 'YMY', 'Victoria Stol', 241, true);
INSERT INTO public."Airports" VALUES (414, 'YOW', 'Ottawa Intl Arpt', 242, true);
INSERT INTO public."Airports" VALUES (415, 'YQF', 'Red Deer Arpt', 243, true);
INSERT INTO public."Airports" VALUES (416, 'YQG', 'Windsor Intl Arpt', 244, true);
INSERT INTO public."Airports" VALUES (417, 'YQY', 'Sydney Airport', 59, true);
INSERT INTO public."Airports" VALUES (418, 'YTO', 'Toronto Area Airports', 239, true);
INSERT INTO public."Airports" VALUES (419, 'YTZ', 'Toronto City Centre Airport', 239, true);
INSERT INTO public."Airports" VALUES (420, 'YUL', 'Dorval Intl', 241, true);
INSERT INTO public."Airports" VALUES (421, 'YVR', 'Vancouver Intl Arpt', 246, true);
INSERT INTO public."Airports" VALUES (422, 'YWG', 'Winnipeg Intl Arpt', 245, true);
INSERT INTO public."Airports" VALUES (423, 'YWH', 'Inner Harbor Sea Plane Arpt', 51, true);
INSERT INTO public."Airports" VALUES (424, 'YXD', 'Edmonton Municipal Arpt', 240, true);
INSERT INTO public."Airports" VALUES (425, 'YYC', 'Calgary Intl Arpt', 243, true);
INSERT INTO public."Airports" VALUES (426, 'YYJ', 'Victoria Intl Arpt', 51, true);
INSERT INTO public."Airports" VALUES (427, 'YYZ', 'Lester B Pearson Intl', 239, true);
INSERT INTO public."Airports" VALUES (428, 'ZAG', 'Zagreb Arpt', 251, true);
INSERT INTO public."Airports" VALUES (429, 'ZAZ', 'Zaragoza Airport', 90, true);
INSERT INTO public."Airports" VALUES (430, 'ZCO', 'Manquehue Arpt', 168, true);
INSERT INTO public."Airports" VALUES (431, 'ZLO', 'Aeropuerto Intl', 190, true);
INSERT INTO public."Airports" VALUES (432, 'ZRH', 'Zurich Airport', 221, true);
INSERT INTO public."Airports" VALUES (433, 'CTG', 'Aeropuerto Internacional Rafael Nunez', 103, true);
INSERT INTO public."Airports" VALUES (435, 'CLO', 'Alfonso Bonilla Arag¢n', 104, true);
INSERT INTO public."Airports" VALUES (436, 'DIM', 'Aeropuerto Olaya Herrera', 2, true);
INSERT INTO public."Airports" VALUES (437, 'BAQ', 'AEROPUERTO ERNESTO CORTIZO', 100, true);


--
-- Data for Name: Attachment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingGDSInvoiceAutoLog; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductFEEGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductItineraryGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductPassangerGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductPaymentGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductTaxGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingProductVariableGDS; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingsGDSInvoiceAuto; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: BookingsGDS_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Branch; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Branch" VALUES (1, 'BOG', 'BOG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true);


--
-- Data for Name: BranchGDSInvoiceAuto; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."BranchGDSInvoiceAuto" VALUES (1, 1, 1, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (2, 1, 2, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (3, 1, 3, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (4, 1, 4, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (5, 1, 5, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (6, 1, 6, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (7, 1, 7, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (8, 1, 8, false);
INSERT INTO public."BranchGDSInvoiceAuto" VALUES (9, 1, 9, false);


--
-- Data for Name: CellCustomization; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."CellCustomization" VALUES (1, 'idCotizacion', 'ID Cotización', 'B2', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (2, 'asesor', 'Asesor', 'B4', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (3, 'fecha', 'Fecha', 'G4', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (4, 'clienteNombre', 'Cliente Nombre', 'B7', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (5, 'clienteIdentificacion', 'Cliente ID', 'G7', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (6, 'clienteDireccion', 'Dirección', 'B8', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (7, 'clienteTelefono', 'Teléfono', 'G8', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (8, 'centroCosto', 'C. Costo', 'B9', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (9, 'solicita', 'Solicita', 'G9', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (10, 'tCambio', 'T. Cambio', 'I11', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (11, 'descripcionPlan', 'Desc Plan', 'B12', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (12, 'fechasViaje', 'Fechas Viaje', 'G12', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (13, 'hotelesServicios', 'Servicios', 'A13', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (14, 'pasajeros', 'Pasajeros', 'B14', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (15, 'totalAdultos', 'Total Adultos', 'C15', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (16, 'totalNinos', 'Total Niños', 'G15', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (17, 'logo', 'Celda Logo', 'A1', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (18, 'proveedor1Nombre', 'Prov 1: Nombre', 'B18', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (19, 'proveedor1NIT', 'Prov 1: NIT', 'E18', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (20, 'proveedor1Contacto', 'Prov 1: Contacto', 'H18', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (21, 'prov1TarifaNeta', 'Prov 1: Neta', 'B23', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (22, 'prov1TarifaNetaPago', 'Prov 1: Neta Pago', 'D23', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (23, 'prov1Impuestos', 'Prov 1: Impuestos', 'B24', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (24, 'prov1ImpuestosPago', 'Prov 1: Impuestos Pago', 'D24', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (25, 'prov1Adicionales', 'Prov 1: Adicionales', 'B25', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (26, 'prov1AdicionalesPago', 'Prov 1: Adicionales Pago', 'D25', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (27, 'prov1Comision', 'Prov 1: Comisión', 'B26', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (28, 'prov1Descuento', 'Prov 1: Descuento', 'B27', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (29, 'prov1Sobrecomision', 'Prov 1: Sobrecomisión', 'B28', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (30, 'prov1Fee', 'Prov 1: Fee', 'B29', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (31, 'prov1Total', 'Prov 1: Total', 'B30', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (32, 'prov1TotalPago', 'Prov 1: Total Pago', 'D30', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (33, 'proveedor2Nombre', 'Prov 2: Nombre', 'B19', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (34, 'proveedor2NIT', 'Prov 2: NIT', 'E19', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (35, 'proveedor2Contacto', 'Prov 2: Contacto', 'H29', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (36, 'prov2TarifaNeta', 'Prov 2: Neta', 'G23', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (37, 'prov2TarifaNetaPago', 'Prov 2: Neta Pago', 'I23', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (38, 'prov2Impuestos', 'Prov 2: Impuestos', 'G24', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (39, 'prov2ImpuestosPago', 'Prov 2: Impuestos Pago', 'I24', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (40, 'prov2Adicionales', 'Prov 2: Adicionales', 'G25', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (41, 'prov2AdicionalesPago', 'Prov 2: Adicionales Pago', 'I25', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (42, 'prov2Comision', 'Prov 2: Comisión', 'G26', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (43, 'prov2Descuento', 'Prov 2: Descuento', 'G27', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (44, 'prov2Sobrecomision', 'Prov 2: Sobrecomisión', 'G28', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (45, 'prov2Fee', 'Prov 2: Fee', 'G29', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (46, 'prov2Total', 'Prov 2: Total', 'G30', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (47, 'prov2TotalPago', 'Prov 2: Total Pago', 'I30', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (48, 'tarifaNeta', 'Total: Tarifa Neta', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (49, 'tarifaNetaPago', 'Total: Neta Pago', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (50, 'impuestos', 'Total: Impuestos', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (51, 'impuestosPago', 'Total: Impuestos Pago', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (52, 'adicionalesServ', 'Total: Adicionales', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (53, 'adicionalesServPago', 'Total: Adicionales Pago', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (54, 'comision', 'Total: Comisión', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (55, 'descuento', 'Total: Descuento', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (56, 'sobrecomision', 'Total: Sobrecomisión', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (57, 'fee', 'Total: Fee', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (58, 'total', 'Total: Total', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (59, 'totalPago', 'Total: Total Pago', '', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (60, 'baseComisionable', 'Base Comisión', 'B35', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (61, 'comisionAsesor', 'Comisión Asesor', 'B36', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (62, 'baseComisionTop', 'Comisión Top', 'B37', 1, NULL);
INSERT INTO public."CellCustomization" VALUES (63, 'observaciones', 'Observaciones', 'B42', 1, NULL);


--
-- Data for Name: ChargeAndTax; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."ChargeAndTax" VALUES (1, 'TAR', 'CHARGE', 'FIXED', 0, true, 'TAR', 0, '[]', NULL, true);
INSERT INTO public."ChargeAndTax" VALUES (2, 'IVA', 'TAX', 'PERCENTAGE', 19, true, 'IVA', 0, '[]', NULL, true);
INSERT INTO public."ChargeAndTax" VALUES (3, 'OTROS', 'CHARGE', 'FIXED', 0, true, 'OTROS', 0, '[]', NULL, true);


--
-- Data for Name: Cities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Cities" VALUES (1, 'BOG', 'Bogotá', 1, 'CUN', 'BOG', true);
INSERT INTO public."Cities" VALUES (2, 'MDE', 'Medellín', 1, 'ANT', 'MDE', true);
INSERT INTO public."Cities" VALUES (3, 'MIA', 'Miami', 2, 'FL', 'MIA', true);
INSERT INTO public."Cities" VALUES (4, 'MAD', 'Madrid', 3, 'MAD', 'MAD', true);
INSERT INTO public."Cities" VALUES (5, 'HOU', 'Houston', 2, '', 'HOU', true);
INSERT INTO public."Cities" VALUES (6, 'ANC', 'Anchorage', 2, '', 'ANC', true);
INSERT INTO public."Cities" VALUES (7, 'LIM', 'Lima', 2, '', 'LIM', true);
INSERT INTO public."Cities" VALUES (8, 'DEN', 'Denver', 2, '', 'DEN', true);
INSERT INTO public."Cities" VALUES (9, 'ATL', 'Atlanta', 2, '', 'ATL', true);
INSERT INTO public."Cities" VALUES (10, 'CMH', 'Columbus', 2, '', 'CMH', true);
INSERT INTO public."Cities" VALUES (11, 'BOL', 'Hartford', 2, '', 'BOL', true);
INSERT INTO public."Cities" VALUES (12, 'SEA', 'Seattle', 2, '', 'SEA', true);
INSERT INTO public."Cities" VALUES (13, 'CLE', 'Cleveland', 2, '', 'CLE', true);
INSERT INTO public."Cities" VALUES (14, 'BNA', 'Nashville', 2, '', 'BNA', true);
INSERT INTO public."Cities" VALUES (15, 'BOS', 'Boston', 2, '', 'BOS', true);
INSERT INTO public."Cities" VALUES (16, 'BUF', 'Buffalo', 2, '', 'BUF', true);
INSERT INTO public."Cities" VALUES (17, 'BWI', 'Baltimore', 2, '', 'BWI', true);
INSERT INTO public."Cities" VALUES (18, 'CHI', 'Chicago', 2, '', 'CHI', true);
INSERT INTO public."Cities" VALUES (19, 'CHS', 'Charleston', 2, '', 'CHS', true);
INSERT INTO public."Cities" VALUES (20, 'DFW', 'Dallas', 2, '', 'DFW', true);
INSERT INTO public."Cities" VALUES (21, 'DAY', 'Dayton', 2, '', 'DAY', true);
INSERT INTO public."Cities" VALUES (22, 'DUB', 'Dublin', 2, '', 'DUB', true);
INSERT INTO public."Cities" VALUES (23, 'DTT', 'Detroit', 2, '', 'DTT', true);
INSERT INTO public."Cities" VALUES (24, 'EWR', 'Newark', 2, '', 'EWR', true);
INSERT INTO public."Cities" VALUES (25, 'GEO', 'Georgetown', 2, '', 'GEO', true);
INSERT INTO public."Cities" VALUES (26, 'GLA', 'Glasgow', 2, '', 'GLA', true);
INSERT INTO public."Cities" VALUES (27, 'HNL', 'Honolulu', 2, '', 'HNL', true);
INSERT INTO public."Cities" VALUES (28, 'LAX', 'Los Angeles', 2, '', 'LAX', true);
INSERT INTO public."Cities" VALUES (29, 'SFO', 'San Francisco', 2, '', 'SFO', true);
INSERT INTO public."Cities" VALUES (30, 'NYC', 'New York', 2, '', 'NYC', true);
INSERT INTO public."Cities" VALUES (31, 'LAS', 'Las Vegas', 2, '', 'LAS', true);
INSERT INTO public."Cities" VALUES (32, 'LGB', 'Long Beach', 2, '', 'LGB', true);
INSERT INTO public."Cities" VALUES (33, 'ORL', 'Orlando', 2, '', 'ORL', true);
INSERT INTO public."Cities" VALUES (34, 'MEM', 'Memphis', 2, '', 'MEM', true);
INSERT INTO public."Cities" VALUES (36, 'MKE', 'Milwaukee', 2, '', 'MKE', true);
INSERT INTO public."Cities" VALUES (37, 'MSP', 'Minneapolis', 2, '', 'MSP', true);
INSERT INTO public."Cities" VALUES (38, 'MSY', 'New Orleans', 2, '', 'MSY', true);
INSERT INTO public."Cities" VALUES (39, 'SAN', 'San Diego', 2, '', 'SAN', true);
INSERT INTO public."Cities" VALUES (40, 'NOR', 'Norfolk', 2, '', 'NOR', true);
INSERT INTO public."Cities" VALUES (41, 'PDX', 'Portland', 2, '', 'PDX', true);
INSERT INTO public."Cities" VALUES (42, 'PHX', 'Phoenix', 2, '', 'PHX', true);
INSERT INTO public."Cities" VALUES (43, 'RDU', 'Raleigh', 2, '', 'RDU', true);
INSERT INTO public."Cities" VALUES (44, 'RIC', 'Richmond', 2, '', 'RIC', true);
INSERT INTO public."Cities" VALUES (45, 'ROC', 'Rochester', 2, '', 'ROC', true);
INSERT INTO public."Cities" VALUES (46, 'SAI', 'San Antonio', 2, '', 'SAI', true);
INSERT INTO public."Cities" VALUES (47, 'SAV', 'Savannah', 2, '', 'SAV', true);
INSERT INTO public."Cities" VALUES (48, 'SLC', 'Salt Lake City', 2, '', 'SLC', true);
INSERT INTO public."Cities" VALUES (49, 'TPA', 'Tampa', 2, '', 'TPA', true);
INSERT INTO public."Cities" VALUES (50, 'TUS', 'Tucson', 2, '', 'TUS', true);
INSERT INTO public."Cities" VALUES (51, 'YYJ', 'Victoria', 2, '', 'YYJ', true);
INSERT INTO public."Cities" VALUES (52, 'VAP', 'Valparaiso', 2, '', 'VAP', true);
INSERT INTO public."Cities" VALUES (53, 'ABJ', 'Abidjan', 7, '', 'ABJ', true);
INSERT INTO public."Cities" VALUES (54, 'DHA', 'Dhahran', 8, '', 'DHA', true);
INSERT INTO public."Cities" VALUES (55, 'RUH', 'Riyadh', 8, '', 'RUH', true);
INSERT INTO public."Cities" VALUES (56, 'JED', 'Jeddah', 8, '', 'JED', true);
INSERT INTO public."Cities" VALUES (57, 'KAN', 'Kano', 9, '', 'KAN', true);
INSERT INTO public."Cities" VALUES (58, 'LOS', 'Lagos', 9, '', 'LOS', true);
INSERT INTO public."Cities" VALUES (59, 'SYD', 'Sydney', 10, '', 'SYD', true);
INSERT INTO public."Cities" VALUES (60, 'MEL', 'Melbourne', 10, '', 'MEL', true);
INSERT INTO public."Cities" VALUES (61, 'ROM', 'Roma', 10, '', 'ROM', true);
INSERT INTO public."Cities" VALUES (62, 'PER', 'Perth', 10, '', 'PER', true);
INSERT INTO public."Cities" VALUES (63, 'CNS', 'Cairns', 10, '', 'CNS', true);
INSERT INTO public."Cities" VALUES (64, 'HBA', 'Hobart', 10, '', 'HBA', true);
INSERT INTO public."Cities" VALUES (65, 'BHD', 'Belfast', 11, '', 'BHD', true);
INSERT INTO public."Cities" VALUES (66, 'MME', 'Teesside', 11, '', 'MME', true);
INSERT INTO public."Cities" VALUES (67, 'LBA', 'Leeds', 11, '', 'LBA', true);
INSERT INTO public."Cities" VALUES (68, 'LPB', 'La Paz', 12, '', 'LPB', true);
INSERT INTO public."Cities" VALUES (69, 'MID', 'Merida', 12, '', 'MID', true);
INSERT INTO public."Cities" VALUES (70, 'MZT', 'Mazatlan', 12, '', 'MZT', true);
INSERT INTO public."Cities" VALUES (71, 'MTY', 'Monterrey', 12, '', 'MTY', true);
INSERT INTO public."Cities" VALUES (72, 'PVR', 'Puerto Vallarta', 12, '', 'PVR', true);
INSERT INTO public."Cities" VALUES (73, 'VER', 'Veracruz', 12, '', 'VER', true);
INSERT INTO public."Cities" VALUES (74, 'TAM', 'Tampico', 12, '', 'TAM', true);
INSERT INTO public."Cities" VALUES (75, 'GYM', 'Guaymas', 12, '', 'GYM', true);
INSERT INTO public."Cities" VALUES (76, 'GDL', 'Guadalajara', 12, '', 'GDL', true);
INSERT INTO public."Cities" VALUES (77, 'CUN', 'Cancun', 12, '', 'CUN', true);
INSERT INTO public."Cities" VALUES (78, 'CZM', 'Cozumel', 12, '', 'CZM', true);
INSERT INTO public."Cities" VALUES (79, 'ACC', 'Accra', 13, '', 'ACC', true);
INSERT INTO public."Cities" VALUES (80, 'ALC', 'Alicante', 3, '', 'ALC', true);
INSERT INTO public."Cities" VALUES (81, 'AGP', 'Malaga', 3, '', 'AGP', true);
INSERT INTO public."Cities" VALUES (82, 'BCN', 'Barcelona', 3, '', 'BCN', true);
INSERT INTO public."Cities" VALUES (83, 'BIO', 'Bilbao', 3, '', 'BIO', true);
INSERT INTO public."Cities" VALUES (84, 'GND', 'Granada', 3, '', 'GND', true);
INSERT INTO public."Cities" VALUES (85, 'IBZ', 'Ibiza', 3, '', 'IBZ', true);
INSERT INTO public."Cities" VALUES (86, 'SVQ', 'Sevilla', 3, '', 'SVQ', true);
INSERT INTO public."Cities" VALUES (87, 'VGO', 'Vigo', 3, '', 'VGO', true);
INSERT INTO public."Cities" VALUES (88, 'VIX', 'Vitoria', 3, '', 'VIX', true);
INSERT INTO public."Cities" VALUES (89, 'VLC', 'Valencia', 3, '', 'VLC', true);
INSERT INTO public."Cities" VALUES (90, 'ZAZ', 'Zaragoza', 3, '', 'ZAZ', true);
INSERT INTO public."Cities" VALUES (91, 'SDR', 'Santander', 3, '', 'SDR', true);
INSERT INTO public."Cities" VALUES (92, 'PNA', 'Pamplona', 3, '', 'PNA', true);
INSERT INTO public."Cities" VALUES (93, 'MJV', 'Murcia', 3, '', 'MJV', true);
INSERT INTO public."Cities" VALUES (95, 'MAH', 'Menorca', 3, '', 'MAH', true);
INSERT INTO public."Cities" VALUES (96, 'AYT', 'Antalya', 15, '', 'AYT', true);
INSERT INTO public."Cities" VALUES (97, 'ANK', 'Ankara', 15, '', 'ANK', true);
INSERT INTO public."Cities" VALUES (98, 'ADD', 'Addis Ababa', 16, '', 'ADD', true);
INSERT INTO public."Cities" VALUES (99, 'ADE', 'Aden', 17, '', 'ADE', true);
INSERT INTO public."Cities" VALUES (100, 'BAQ', 'Barranquilla', 1, 'ATL', 'BAQ', true);
INSERT INTO public."Cities" VALUES (103, 'CTG', 'Cartagena', 1, 'BOL', 'CTG', true);
INSERT INTO public."Cities" VALUES (104, 'CLO', 'Cali', 1, 'VAL', 'CLO', true);
INSERT INTO public."Cities" VALUES (105, '000001', 'chigorodo', 1, '', '000001', true);
INSERT INTO public."Cities" VALUES (106, 'BHI', 'Bahia Blanca', 19, '', 'BHI', true);
INSERT INTO public."Cities" VALUES (107, 'BUE', 'Buenos Aires', 19, '', 'BUE', true);
INSERT INTO public."Cities" VALUES (108, 'SLZ', 'San Luis', 19, '', 'SLZ', true);
INSERT INTO public."Cities" VALUES (109, 'KRS', 'Kristiansand', 21, '', 'KRS', true);
INSERT INTO public."Cities" VALUES (110, 'SVG', 'Stavanger', 21, '', 'SVG', true);
INSERT INTO public."Cities" VALUES (111, 'BGO', 'Bergen', 21, '', 'BGO', true);
INSERT INTO public."Cities" VALUES (112, 'OSL', 'Oslo', 21, '', 'OSL', true);
INSERT INTO public."Cities" VALUES (113, 'CAS', 'Casablanca', 23, '', 'CAS', true);
INSERT INTO public."Cities" VALUES (114, 'RAK', 'Marrakech', 23, '', 'RAK', true);
INSERT INTO public."Cities" VALUES (115, 'RBA', 'Rabat', 23, '', 'RBA', true);
INSERT INTO public."Cities" VALUES (116, 'STR', 'Stuttgart', 24, '', 'STR', true);
INSERT INTO public."Cities" VALUES (117, 'LEJ', 'Leipzig', 24, '', 'LEJ', true);
INSERT INTO public."Cities" VALUES (118, 'MUC', 'Munich', 24, '', 'MUC', true);
INSERT INTO public."Cities" VALUES (120, 'DUS', 'Dusseldorf', 24, '', 'DUS', true);
INSERT INTO public."Cities" VALUES (121, 'FRA', 'Frankfurt', 24, '', 'FRA', true);
INSERT INTO public."Cities" VALUES (122, 'PAR', 'Paris', 25, '', 'PAR', true);
INSERT INTO public."Cities" VALUES (123, 'BOD', 'Bordeaux', 25, '', 'BOD', true);
INSERT INTO public."Cities" VALUES (124, 'LYS', 'Lyon', 25, '', 'LYS', true);
INSERT INTO public."Cities" VALUES (125, 'LHV', 'Le Havre', 25, '', 'LHV', true);
INSERT INTO public."Cities" VALUES (126, 'LIL', 'Lille', 25, '', 'LIL', true);
INSERT INTO public."Cities" VALUES (127, 'MMA', 'Malmo', 26, '', 'MMA', true);
INSERT INTO public."Cities" VALUES (128, 'DEL', 'Delhi', 27, '', 'DEL', true);
INSERT INTO public."Cities" VALUES (129, 'MAA', 'Madras', 27, '', 'MAA', true);
INSERT INTO public."Cities" VALUES (130, 'DPS', 'Denpasar', 28, '', 'DPS', true);
INSERT INTO public."Cities" VALUES (131, 'JKT', 'Jakarta', 28, '', 'JKT', true);
INSERT INTO public."Cities" VALUES (132, 'BRI', 'Bari', 29, '', 'BRI', true);
INSERT INTO public."Cities" VALUES (133, 'MIL', 'Milan', 29, '', 'MIL', true);
INSERT INTO public."Cities" VALUES (134, 'PMO', 'Palermo', 29, '', 'PMO', true);
INSERT INTO public."Cities" VALUES (135, 'POA', 'Porto Alegre', 31, '', 'POA', true);
INSERT INTO public."Cities" VALUES (136, 'REC', 'Recife', 31, '', 'REC', true);
INSERT INTO public."Cities" VALUES (137, 'SSA', 'Salvador', 31, '', 'SSA', true);
INSERT INTO public."Cities" VALUES (138, 'JPA', 'Joao Pessoa', 31, '', 'JPA', true);
INSERT INTO public."Cities" VALUES (139, 'MCZ', 'Maceio', 31, '', 'MCZ', true);
INSERT INTO public."Cities" VALUES (140, 'NAT', 'Natal', 31, '', 'NAT', true);
INSERT INTO public."Cities" VALUES (141, 'BSB', 'Brasilia', 31, '', 'BSB', true);
INSERT INTO public."Cities" VALUES (142, 'BZC', 'Buzios', 31, '', 'BZC', true);
INSERT INTO public."Cities" VALUES (143, 'BEL', 'Belem', 31, '', 'BEL', true);
INSERT INTO public."Cities" VALUES (144, 'AJU', 'Aracaju', 31, '', 'AJU', true);
INSERT INTO public."Cities" VALUES (145, 'BHZ', 'Belo Horizonte', 31, '', 'BHZ', true);
INSERT INTO public."Cities" VALUES (146, 'CWB', 'Curitiba', 31, '', 'CWB', true);
INSERT INTO public."Cities" VALUES (147, 'CGB', 'Cuiaba', 31, '', 'CGB', true);
INSERT INTO public."Cities" VALUES (148, 'IOS', 'Ilheus', 31, '', 'IOS', true);
INSERT INTO public."Cities" VALUES (149, 'GYN', 'Goiania', 31, '', 'GYN', true);
INSERT INTO public."Cities" VALUES (150, 'FOR', 'Fortaleza', 31, '', 'FOR', true);
INSERT INTO public."Cities" VALUES (151, 'RIO', 'Rio De Janeiro', 31, '', 'RIO', true);
INSERT INTO public."Cities" VALUES (152, 'CHC', 'Christchurch', 32, '', 'CHC', true);
INSERT INTO public."Cities" VALUES (153, 'AKL', 'Auckland', 32, '', 'AKL', true);
INSERT INTO public."Cities" VALUES (154, 'WLG', 'Wellington', 32, '', 'WLG', true);
INSERT INTO public."Cities" VALUES (155, 'PRY', 'Pretoria', 34, '', 'PRY', true);
INSERT INTO public."Cities" VALUES (156, 'PEZ', 'Port Elizabeth', 34, '', 'PEZ', true);
INSERT INTO public."Cities" VALUES (157, 'DUR', 'Durban', 34, '', 'DUR', true);
INSERT INTO public."Cities" VALUES (158, 'CTW', 'Cape Town', 34, '', 'CTW', true);
INSERT INTO public."Cities" VALUES (159, 'ALP', 'Aleppo', 35, '', 'ALP', true);
INSERT INTO public."Cities" VALUES (160, 'CAI', 'Cairo', 37, '', 'CAI', true);
INSERT INTO public."Cities" VALUES (161, 'AMM', 'Amman', 38, '', 'AMM', true);
INSERT INTO public."Cities" VALUES (162, 'AMS', 'Amsterdam', 39, '', 'AMS', true);
INSERT INTO public."Cities" VALUES (163, 'ANF', 'Antofagasta', 40, '', 'ANF', true);
INSERT INTO public."Cities" VALUES (164, 'ARI', 'Arica', 40, '', 'ARI', true);
INSERT INTO public."Cities" VALUES (165, 'IQQ', 'Iquique', 40, '', 'IQQ', true);
INSERT INTO public."Cities" VALUES (166, 'PMC', 'Puerto Montt', 40, '', 'PMC', true);
INSERT INTO public."Cities" VALUES (167, 'PUQ', 'Punta Arenas', 40, '', 'PUQ', true);
INSERT INTO public."Cities" VALUES (168, 'ZCO', 'Temuco', 40, '', 'ZCO', true);
INSERT INTO public."Cities" VALUES (169, 'LSC', 'La Serena', 40, '', 'LSC', true);
INSERT INTO public."Cities" VALUES (170, 'ANR', 'Antwerp', 41, '', 'ANR', true);
INSERT INTO public."Cities" VALUES (171, 'KUL', 'Kuala Lumpur', 43, '', 'KUL', true);
INSERT INTO public."Cities" VALUES (172, 'PEN', 'Penang', 43, '', 'PEN', true);
INSERT INTO public."Cities" VALUES (173, 'MPM', 'Maputo', 44, '', 'MPM', true);
INSERT INTO public."Cities" VALUES (174, 'APW', 'Apia', 45, '', 'APW', true);
INSERT INTO public."Cities" VALUES (175, 'AQP', 'Arequipa', 46, '', 'AQP', true);
INSERT INTO public."Cities" VALUES (176, 'OSA', 'Osaka', 47, '', 'OSA', true);
INSERT INTO public."Cities" VALUES (177, 'FUK', 'Fukuoka', 47, '', 'FUK', true);
INSERT INTO public."Cities" VALUES (178, 'NGO', 'Nagoya', 47, '', 'NGO', true);
INSERT INTO public."Cities" VALUES (179, 'OKA', 'Okinawa', 47, '', 'OKA', true);
INSERT INTO public."Cities" VALUES (180, 'ASM', 'Asmara', 48, '', 'ASM', true);
INSERT INTO public."Cities" VALUES (181, 'ASU', 'Asuncion', 49, '', 'ASU', true);
INSERT INTO public."Cities" VALUES (182, 'FPO', 'Freeport', 50, '', 'FPO', true);
INSERT INTO public."Cities" VALUES (183, 'NAS', 'Nassau', 50, '', 'NAS', true);
INSERT INTO public."Cities" VALUES (184, 'AUA', 'Aruba', 52, '', 'AUA', true);
INSERT INTO public."Cities" VALUES (185, 'AUH', 'Abu Dhabi', 53, '', 'AUH', true);
INSERT INTO public."Cities" VALUES (186, 'DXB', 'Dubai', 53, '', 'DXB', true);
INSERT INTO public."Cities" VALUES (187, 'SHJ', 'Sharjah', 53, '', 'SHJ', true);
INSERT INTO public."Cities" VALUES (188, 'PPT', 'Papeete', 54, '', 'PPT', true);
INSERT INTO public."Cities" VALUES (189, 'VRA', 'Varadero', 55, '', 'VRA', true);
INSERT INTO public."Cities" VALUES (190, 'ZLO', 'Manzanillo', 55, '', 'ZLO', true);
INSERT INTO public."Cities" VALUES (191, 'HOG', 'Holguin', 55, '', 'HOG', true);
INSERT INTO public."Cities" VALUES (192, 'AVI', 'Ciego De Avila', 55, '', 'AVI', true);
INSERT INTO public."Cities" VALUES (193, 'MNL', 'Manila', 57, '', 'MNL', true);
INSERT INTO public."Cities" VALUES (194, 'BAH', 'Bahrain', 58, '', 'BAH', true);
INSERT INTO public."Cities" VALUES (195, 'GBE', 'Gaborone', 60, '', 'GBE', true);
INSERT INTO public."Cities" VALUES (196, 'TSR', 'Timisoara', 61, '', 'TSR', true);
INSERT INTO public."Cities" VALUES (197, 'BDA', 'Bermuda', 62, '', 'BDA', true);
INSERT INTO public."Cities" VALUES (198, 'BEY', 'Beirut', 64, '', 'BEY', true);
INSERT INTO public."Cities" VALUES (199, 'NAN', 'Nadi', 65, '', 'NAN', true);
INSERT INTO public."Cities" VALUES (200, 'SUV', 'Suva', 65, '', 'SUV', true);
INSERT INTO public."Cities" VALUES (201, 'BGF', 'Bangui', 66, '', 'BGF', true);
INSERT INTO public."Cities" VALUES (202, 'BGI', 'Barbados', 67, '', 'BGI', true);
INSERT INTO public."Cities" VALUES (203, 'BGW', 'Baghdad', 68, '', 'BGW', true);
INSERT INTO public."Cities" VALUES (204, 'BSR', 'Basra', 68, '', 'BSR', true);
INSERT INTO public."Cities" VALUES (205, 'CAN', 'Guangzhou', 69, '', 'CAN', true);
INSERT INTO public."Cities" VALUES (206, 'BJS', 'Beijing', 69, '', 'BJS', true);
INSERT INTO public."Cities" VALUES (207, 'DLC', 'Dalian', 69, '', 'DLC', true);
INSERT INTO public."Cities" VALUES (208, 'SHA', 'Shanghai', 69, '', 'SHA', true);
INSERT INTO public."Cities" VALUES (209, 'BJL', 'Banjul', 71, '', 'BJL', true);
INSERT INTO public."Cities" VALUES (210, 'BJM', 'Bujumbura', 72, '', 'BJM', true);
INSERT INTO public."Cities" VALUES (211, 'BKK', 'Bangkok', 73, '', 'BKK', true);
INSERT INTO public."Cities" VALUES (212, 'HKT', 'Phuket', 73, '', 'HKT', true);
INSERT INTO public."Cities" VALUES (213, 'BKO', 'Bamako', 74, '', 'BKO', true);
INSERT INTO public."Cities" VALUES (214, 'CCS', 'Caracas', 75, '', 'CCS', true);
INSERT INTO public."Cities" VALUES (215, 'PMV', 'Porlamar', 75, '', 'PMV', true);
INSERT INTO public."Cities" VALUES (216, 'MAR', 'Maracaibo', 75, '', 'MAR', true);
INSERT INTO public."Cities" VALUES (217, 'LLW', 'Lilongwe', 76, '', 'LLW', true);
INSERT INTO public."Cities" VALUES (218, 'BLZ', 'Blantyre', 76, '', 'BLZ', true);
INSERT INTO public."Cities" VALUES (219, 'BON', 'Bonaire', 77, '', 'BON', true);
INSERT INTO public."Cities" VALUES (220, 'MLH', 'Mulhouse', 78, '', 'MLH', true);
INSERT INTO public."Cities" VALUES (221, 'ZRH', 'Zurich', 78, '', 'ZRH', true);
INSERT INTO public."Cities" VALUES (222, 'SDQ', 'Santo Domingo', 80, '', 'SDQ', true);
INSERT INTO public."Cities" VALUES (223, 'BTS', 'Bratislava', 81, '', 'BTS', true);
INSERT INTO public."Cities" VALUES (224, 'BUD', 'Budapest', 82, '', 'BUD', true);
INSERT INTO public."Cities" VALUES (225, 'BUQ', 'Bulawayo', 83, '', 'BUQ', true);
INSERT INTO public."Cities" VALUES (226, 'HRE', 'Harare', 83, '', 'HRE', true);
INSERT INTO public."Cities" VALUES (227, 'BZV', 'Brazzaville', 87, '', 'BZV', true);
INSERT INTO public."Cities" VALUES (228, 'CBB', 'Cochabamba', 88, '', 'CBB', true);
INSERT INTO public."Cities" VALUES (229, 'PAP', 'Port Au Prince', 89, '', 'PAP', true);
INSERT INTO public."Cities" VALUES (230, 'CAY', 'Cayenne', 90, '', 'CAY', true);
INSERT INTO public."Cities" VALUES (231, 'FAO', 'Faro', 91, '', 'FAO', true);
INSERT INTO public."Cities" VALUES (232, 'SNN', 'Shannon', 93, '', 'SNN', true);
INSERT INTO public."Cities" VALUES (233, 'DAC', 'Dhaka', 94, '', 'DAC', true);
INSERT INTO public."Cities" VALUES (234, 'CKY', 'Conakry', 97, '', 'CKY', true);
INSERT INTO public."Cities" VALUES (235, 'CMB', 'Colombo', 98, '', 'CMB', true);
INSERT INTO public."Cities" VALUES (236, 'COO', 'Cotonou', 99, '', 'COO', true);
INSERT INTO public."Cities" VALUES (237, 'GYE', 'Guayaquil', 100, '', 'GYE', true);
INSERT INTO public."Cities" VALUES (238, 'UIO', 'Quito', 100, '', 'UIO', true);
INSERT INTO public."Cities" VALUES (239, 'YTO', 'Toronto', 101, '', 'YTO', true);
INSERT INTO public."Cities" VALUES (240, 'YEG', 'Edmonton', 101, '', 'YEG', true);
INSERT INTO public."Cities" VALUES (241, 'YUL', 'Montreal', 101, '', 'YUL', true);
INSERT INTO public."Cities" VALUES (242, 'YOW', 'Ottawa', 101, '', 'YOW', true);
INSERT INTO public."Cities" VALUES (243, 'YYC', 'Calgary', 101, '', 'YYC', true);
INSERT INTO public."Cities" VALUES (244, 'YQG', 'Windsor', 101, '', 'YQG', true);
INSERT INTO public."Cities" VALUES (245, 'YWG', 'Winnipeg', 101, '', 'YWG', true);
INSERT INTO public."Cities" VALUES (246, 'VAN', 'Vancouver', 101, '', 'VAN', true);
INSERT INTO public."Cities" VALUES (247, 'CYR', 'Colonia', 103, '', 'CYR', true);
INSERT INTO public."Cities" VALUES (248, 'PDP', 'Punta Del Este', 103, '', 'PDP', true);
INSERT INTO public."Cities" VALUES (249, 'MVD', 'Montevideo', 103, '', 'MVD', true);
INSERT INTO public."Cities" VALUES (250, 'DAR', 'Dar Es Salaam', 104, '', 'DAR', true);
INSERT INTO public."Cities" VALUES (251, 'ZAG', 'Zagreb', 105, '', 'ZAG', true);
INSERT INTO public."Cities" VALUES (252, 'DKR', 'Dakar', 108, '', 'DKR', true);
INSERT INTO public."Cities" VALUES (253, 'DLA', 'Douala', 109, '', 'DLA', true);
INSERT INTO public."Cities" VALUES (254, 'YAO', 'Yaounde', 109, '', 'YAO', true);
INSERT INTO public."Cities" VALUES (255, 'DOH', 'Doha', 111, '', 'DOH', true);
INSERT INTO public."Cities" VALUES (256, 'LCA', 'Larnaca', 113, '', 'LCA', true);
INSERT INTO public."Cities" VALUES (257, 'PFO', 'Paphos', 113, '', 'PFO', true);
INSERT INTO public."Cities" VALUES (258, 'WDH', 'Windhoek', 115, '', 'WDH', true);
INSERT INTO public."Cities" VALUES (259, 'TLV', 'Tel Aviv', 116, '', 'TLV', true);
INSERT INTO public."Cities" VALUES (260, 'JRS', 'Jerusalem', 116, '', 'JRS', true);
INSERT INTO public."Cities" VALUES (261, 'FBM', 'Lubumbashi', 117, '', 'FBM', true);
INSERT INTO public."Cities" VALUES (262, 'FIH', 'Kinshasa', 117, '', 'FIH', true);
INSERT INTO public."Cities" VALUES (263, 'FNA', 'Freetown', 119, '', 'FNA', true);
INSERT INTO public."Cities" VALUES (264, 'GIB', 'Gibraltar', 124, '', 'GIB', true);
INSERT INTO public."Cities" VALUES (265, 'GRZ', 'Graz', 127, '', 'GRZ', true);
INSERT INTO public."Cities" VALUES (266, 'KLU', 'Klagenfurt', 127, '', 'KLU', true);
INSERT INTO public."Cities" VALUES (267, 'LNZ', 'Linz', 127, '', 'LNZ', true);
INSERT INTO public."Cities" VALUES (268, 'MLA', 'Malta', 129, '', 'MLA', true);
INSERT INTO public."Cities" VALUES (269, 'KHH', 'Kaohsiung', 131, '', 'KHH', true);
INSERT INTO public."Cities" VALUES (270, 'TPE', 'Taipei', 131, '', 'TPE', true);
INSERT INTO public."Cities" VALUES (271, 'KHI', 'Karachi', 132, '', 'KHI', true);
INSERT INTO public."Cities" VALUES (272, 'ISB', 'Islamabad', 132, '', 'ISB', true);
INSERT INTO public."Cities" VALUES (273, 'HEL', 'Helsinki', 133, '', 'HEL', true);
INSERT INTO public."Cities" VALUES (274, 'HKG', 'Hong Kong', 135, '', 'HKG', true);
INSERT INTO public."Cities" VALUES (275, 'IEV', 'Kiev', 136, '', 'IEV', true);
INSERT INTO public."Cities" VALUES (276, 'KGL', 'Kigali', 139, '', 'KGL', true);
INSERT INTO public."Cities" VALUES (277, 'KIN', 'Kingston', 140, '', 'KIN', true);
INSERT INTO public."Cities" VALUES (278, 'MBJ', 'Montego Bay', 140, '', 'MBJ', true);
INSERT INTO public."Cities" VALUES (279, 'KRT', 'Khartoum', 141, '', 'KRT', true);
INSERT INTO public."Cities" VALUES (280, 'KWI', 'Kuwait', 144, '', 'KWI', true);
INSERT INTO public."Cities" VALUES (281, 'LAD', 'Luanda', 145, '', 'LAD', true);
INSERT INTO public."Cities" VALUES (282, 'LBV', 'Libreville', 146, '', 'LBV', true);
INSERT INTO public."Cities" VALUES (283, 'LFW', 'Lome', 147, '', 'LFW', true);
INSERT INTO public."Cities" VALUES (284, 'CTF', 'CARTAGO', 148, '', 'CTF', true);
INSERT INTO public."Cities" VALUES (285, 'LJU', 'Ljubljana', 149, '', 'LJU', true);
INSERT INTO public."Cities" VALUES (286, 'LUN', 'Lusaka', 150, '', 'LUN', true);
INSERT INTO public."Cities" VALUES (287, 'NBO', 'Nairobi', 152, '', 'NBO', true);
INSERT INTO public."Cities" VALUES (288, 'MCT', 'Muscat', 154, '', 'MCT', true);
INSERT INTO public."Cities" VALUES (289, 'MGA', 'Managua', 156, '', 'MGA', true);
INSERT INTO public."Cities" VALUES (290, 'MLW', 'Monrovia', 158, '', 'MLW', true);
INSERT INTO public."Cities" VALUES (291, 'NKC', 'Nouakchott', 164, '', 'NKC', true);
INSERT INTO public."Cities" VALUES (292, 'NIM', 'Niamey', 167, '', 'NIM', true);
INSERT INTO public."Cities" VALUES (293, 'PBM', 'Paramaribo', 170, '', 'PBM', true);
INSERT INTO public."Cities" VALUES (294, 'SAP', 'San Pedro Sula', 178, '', 'SAP', true);
INSERT INTO public."Cities" VALUES (295, 'TGU', 'Tegucigalpa', 178, '', 'TGU', true);
INSERT INTO public."Cities" VALUES (296, 'SAL', 'San Salvador', 180, '', 'SAL', true);
INSERT INTO public."Cities" VALUES (297, 'SEZ', 'Mahe Island', 181, '', 'SEZ', true);
INSERT INTO public."Cities" VALUES (298, 'SJJ', 'Sarajevo', 183, '', 'SJJ', true);
INSERT INTO public."Cities" VALUES (299, 'SOF', 'Sofia', 185, '', 'SOF', true);
INSERT INTO public."Cities" VALUES (300, 'THR', 'Teheran', 189, '', 'THR', true);
INSERT INTO public."Cities" VALUES (301, 'TIA', 'Tirana', 190, '', 'TIA', true);


--
-- Data for Name: Client; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Client" VALUES (1, 'Rubiel', '73009263', NULL, NULL, NULL, NULL, true);


--
-- Data for Name: Combo; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ComboProduct; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ComboProductTax; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Countries; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Countries" VALUES (1, 'CO', 'Colombia', '169', 'LA', '57', 1, true);
INSERT INTO public."Countries" VALUES (2, 'US', 'Estados Unidos', '249', 'NA', '1', 2, true);
INSERT INTO public."Countries" VALUES (3, 'ES', 'España', '245', 'EUR', '34', 3, true);
INSERT INTO public."Countries" VALUES (4, 'DZ', 'Algeria', '059', 'AFR', '213', 4, true);
INSERT INTO public."Countries" VALUES (5, 'DK', 'Denmark', '232', 'EUR', '45', 5, true);
INSERT INTO public."Countries" VALUES (7, 'CI', 'Cote d Ivoire', '193', 'AFR', '225', 7, true);
INSERT INTO public."Countries" VALUES (8, 'SA', 'Saudi Arabia', '053', 'MEA', '966', 8, true);
INSERT INTO public."Countries" VALUES (9, 'NG', 'Nigeria', '528', 'AFR', '234', 9, true);
INSERT INTO public."Countries" VALUES (10, 'AU', 'Australia', '069', 'PAC', '61', 10, true);
INSERT INTO public."Countries" VALUES (11, 'GB', 'United Kingdom', '628', 'EUR', '44', 11, true);
INSERT INTO public."Countries" VALUES (12, 'MX', 'Mexico', '493', 'LA', '52', 12, true);
INSERT INTO public."Countries" VALUES (13, 'GH', 'Ghana', '289', 'AFR', '233', 13, true);
INSERT INTO public."Countries" VALUES (15, 'TR', 'Turkey', '827', 'ASI', '90', 15, true);
INSERT INTO public."Countries" VALUES (16, 'ET', 'Ethiopia', '253', 'AFR', '251', 16, true);
INSERT INTO public."Countries" VALUES (17, 'YE', 'Yemen', '880', 'MEA', '967', 17, true);
INSERT INTO public."Countries" VALUES (19, 'AR', 'Argentina', '063', 'LA', '54', 19, true);
INSERT INTO public."Countries" VALUES (20, 'RU', 'Russian Federation', '670', 'EUR', '7', 20, true);
INSERT INTO public."Countries" VALUES (21, 'NO', 'Norway', '538', 'EUR', '47', 21, true);
INSERT INTO public."Countries" VALUES (22, 'IS', 'Iceland', '379', 'EUR', '354', 22, true);
INSERT INTO public."Countries" VALUES (23, 'MA', 'Morocco', '474', 'AFR', '212', 23, true);
INSERT INTO public."Countries" VALUES (24, 'DE', 'Germany', '023', 'EUR', '49', 3, true);
INSERT INTO public."Countries" VALUES (25, 'FR', 'France', '275', 'EUR', '33', 3, true);
INSERT INTO public."Countries" VALUES (26, 'SE', 'Sweden', '764', 'EUR', '46', 24, true);
INSERT INTO public."Countries" VALUES (27, 'IN', 'India', '361', 'ASI', '91', 25, true);
INSERT INTO public."Countries" VALUES (28, 'ID', 'Indonesia', '365', 'ASI', '62', 26, true);
INSERT INTO public."Countries" VALUES (29, 'IT', 'Italy', '386', 'EUR', '39', 3, true);
INSERT INTO public."Countries" VALUES (30, 'CK', 'Cook Islands', '183', 'PAC', '682', 27, true);
INSERT INTO public."Countries" VALUES (31, 'BR', 'Brazil', '105', 'LA', '55', 28, true);
INSERT INTO public."Countries" VALUES (32, 'NZ', 'New Zealand', '548', 'PAC', '64', 27, true);
INSERT INTO public."Countries" VALUES (33, 'KZ', 'Kazakstan', '406', 'ASI', '7', 29, true);
INSERT INTO public."Countries" VALUES (34, 'ZA', 'South Africa', '756', 'AFR', '27', 30, true);
INSERT INTO public."Countries" VALUES (35, 'SY', 'Syrian Arab Republic', '744', 'MEA', '963', 31, true);
INSERT INTO public."Countries" VALUES (36, 'AD', 'Andorra', '037', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (37, 'EG', 'Egypt', '240', 'MEA', '20', 32, true);
INSERT INTO public."Countries" VALUES (38, 'JO', 'Jordan', '403', 'MEA', '962', 33, true);
INSERT INTO public."Countries" VALUES (39, 'NL', 'Netherlands', '573', 'EUR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (40, 'CL', 'Chile', '211', 'LA', '56', 34, true);
INSERT INTO public."Countries" VALUES (41, 'BE', 'Belgium', '087', 'EUR', '32', 3, true);
INSERT INTO public."Countries" VALUES (42, 'AG', 'Antigua and Barbuda', '043', 'CAR', '1268', 35, true);
INSERT INTO public."Countries" VALUES (43, 'MY', 'Malaysia', '455', 'ASI', '60', 36, true);
INSERT INTO public."Countries" VALUES (44, 'MZ', 'Mozambique', '505', 'AFR', '258', 37, true);
INSERT INTO public."Countries" VALUES (45, 'WS', 'Samoa', '687', 'PAC', '685', 38, true);
INSERT INTO public."Countries" VALUES (46, 'PE', 'Peru', '589', 'LA', '51', 39, true);
INSERT INTO public."Countries" VALUES (47, 'JP', 'Japan', '399', 'ASI', '81', 40, true);
INSERT INTO public."Countries" VALUES (48, 'ER', 'Eritrea', '243', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (49, 'PY', 'Paraguay', '586', 'LA', '595', 41, true);
INSERT INTO public."Countries" VALUES (50, 'BS', 'Bahamas', '077', 'CAR', '1242', 42, true);
INSERT INTO public."Countries" VALUES (51, 'GR', 'Greece', '301', 'EUR', '30', 3, true);
INSERT INTO public."Countries" VALUES (52, 'AW', 'Aruba', '027', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (53, 'AE', 'United Arab Emirates', '244', 'MEA', '971', 43, true);
INSERT INTO public."Countries" VALUES (54, 'PF', 'French Polynesia', '599', 'PAC', '689', 44, true);
INSERT INTO public."Countries" VALUES (55, 'CU', 'Cuba', '199', 'CAR', '53', 45, true);
INSERT INTO public."Countries" VALUES (56, 'AI', 'Anguilla', '041', 'CAR', '1264', 35, true);
INSERT INTO public."Countries" VALUES (57, 'PH', 'Philippines', '267', 'ASI', '63', 46, true);
INSERT INTO public."Countries" VALUES (58, 'BH', 'Bahrain', '080', 'ASI', '973', 47, true);
INSERT INTO public."Countries" VALUES (59, 'AZ', 'Azerbaijan', '074', 'ASI', '994', 48, true);
INSERT INTO public."Countries" VALUES (60, 'BW', 'Botswana', '101', 'AFR', '267', 49, true);
INSERT INTO public."Countries" VALUES (61, 'RO', 'Romania', '670', 'EUR', '40', 50, true);
INSERT INTO public."Countries" VALUES (62, 'BM', 'Bermuda', '090', 'CAR', '1441', 51, true);
INSERT INTO public."Countries" VALUES (63, 'YU', 'Yugoslavia', '885', 'EUR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (64, 'LB', 'Lebanon', '431', 'MEA', '961', 52, true);
INSERT INTO public."Countries" VALUES (65, 'FJ', 'Fiji', '870', 'PAC', '679', 53, true);
INSERT INTO public."Countries" VALUES (66, 'CF', 'Central African Republic', '640', 'AFR', '236', 54, true);
INSERT INTO public."Countries" VALUES (67, 'BB', 'Barbados', '083', 'CAR', '1246', 55, true);
INSERT INTO public."Countries" VALUES (68, 'IQ', 'Iraq', '369', 'MEA', '964', 56, true);
INSERT INTO public."Countries" VALUES (69, 'CN', 'China', '215', 'ASI', '86', 57, true);
INSERT INTO public."Countries" VALUES (70, 'MH', 'Marshall Islands', '472', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (71, 'GM', 'Gambia', '285', 'AFR', '220', 58, true);
INSERT INTO public."Countries" VALUES (72, 'BI', 'Burundi', '115', 'AFR', '257', 59, true);
INSERT INTO public."Countries" VALUES (73, 'TH', 'Thailand', '776', 'ASI', '66', 60, true);
INSERT INTO public."Countries" VALUES (74, 'ML', 'Mali', '464', 'AFR', '223', 7, true);
INSERT INTO public."Countries" VALUES (75, 'VE', 'Venezuela', '850', 'LA', '58', 61, true);
INSERT INTO public."Countries" VALUES (76, 'MW', 'Malawi', '458', 'AFR', '265', 62, true);
INSERT INTO public."Countries" VALUES (77, 'AN', 'Netherlands Antilles', '047', 'CAR', '31', 63, true);
INSERT INTO public."Countries" VALUES (78, 'CH', 'Switzerland', '767', 'EUR', '41', 64, true);
INSERT INTO public."Countries" VALUES (79, 'CZ', 'Czech Republic', '644', 'EUR', '420', 65, true);
INSERT INTO public."Countries" VALUES (80, 'DO', 'Dominican Republic', '647', 'CAR', '1089', 66, true);
INSERT INTO public."Countries" VALUES (81, 'SK', 'Slovakia', '246', 'EUR', '421', 3, true);
INSERT INTO public."Countries" VALUES (82, 'HU', 'Hungary', '355', 'EUR', '36', 67, true);
INSERT INTO public."Countries" VALUES (83, 'ZW', 'Zimbabwe', '665', 'AFR', '263', 68, true);
INSERT INTO public."Countries" VALUES (84, 'CV', 'Cape Verde', '127', 'AFR', '238', 69, true);
INSERT INTO public."Countries" VALUES (85, 'BN', 'Brunei Darussalam', '108', 'ASI', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (86, 'BZ', 'Belize', '088', 'LA', '501', 70, true);
INSERT INTO public."Countries" VALUES (87, 'CG', 'Congo', '177', 'AFR', '242', 54, true);
INSERT INTO public."Countries" VALUES (88, 'BO', 'Bolivia', '097', 'LA', '591', 71, true);
INSERT INTO public."Countries" VALUES (89, 'HT', 'Haiti', '341', 'CAR', '509', 72, true);
INSERT INTO public."Countries" VALUES (90, 'GF', 'French Guiana', '325', 'LA', '594', 3, true);
INSERT INTO public."Countries" VALUES (91, 'PT', 'Portugal', '607', 'EUR', '351', 3, true);
INSERT INTO public."Countries" VALUES (92, 'GP', 'Guadeloupe', '309', 'CAR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (93, 'IE', 'Ireland', '375', 'EUR', '353', 3, true);
INSERT INTO public."Countries" VALUES (94, 'BD', 'Bangladesh', '081', 'ASI', '880', 73, true);
INSERT INTO public."Countries" VALUES (95, 'PA', 'Panama', '580', 'LA', '507', 2, true);
INSERT INTO public."Countries" VALUES (96, 'KR', 'Korea, Republic Of', '190', 'ASI', '82', 74, true);
INSERT INTO public."Countries" VALUES (97, 'GN', 'Guinea', '329', 'AFR', '224', 75, true);
INSERT INTO public."Countries" VALUES (98, 'LK', 'Sri Lanka', '750', 'ASI', '94', 76, true);
INSERT INTO public."Countries" VALUES (99, 'BJ', 'Benin', '229', 'AFR', '229', 7, true);
INSERT INTO public."Countries" VALUES (100, 'EC', 'Ecuador', '239', 'LA', '593', 2, true);
INSERT INTO public."Countries" VALUES (101, 'CA', 'Canada', '149', 'NA', '1', 77, true);
INSERT INTO public."Countries" VALUES (102, 'KY', 'Cayman Islands', '137', 'CAR', '1345', 78, true);
INSERT INTO public."Countries" VALUES (103, 'UY', 'Uruguay', '845', 'LA', '598', 79, true);
INSERT INTO public."Countries" VALUES (104, 'TZ', 'Tanzania, United Republic Of', '780', 'AFR', '255', 80, true);
INSERT INTO public."Countries" VALUES (105, 'HR', 'Croatia', '198', 'EUR', '385', 81, true);
INSERT INTO public."Countries" VALUES (106, 'DM', 'Dominica', '235', 'CAR', '1767', 35, true);
INSERT INTO public."Countries" VALUES (107, 'TN', 'Tunisia', '820', 'AFR', '216', 82, true);
INSERT INTO public."Countries" VALUES (108, 'SN', 'Senegal', '728', 'AFR', '221', 7, true);
INSERT INTO public."Countries" VALUES (109, 'CM', 'Cameroon', '145', 'AFR', '237', 54, true);
INSERT INTO public."Countries" VALUES (110, 'VN', 'Vietnam', '855', 'ASI', '84', 83, true);
INSERT INTO public."Countries" VALUES (111, 'QA', 'Qatar', '618', 'MEA', '974', 84, true);
INSERT INTO public."Countries" VALUES (112, 'UG', 'Uganda', '833', 'AFR', '256', 85, true);
INSERT INTO public."Countries" VALUES (113, 'CY', 'Cyprus', '221', 'EUR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (114, 'VG', 'Virgin Islands, British', '863', 'CAR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (115, 'NA', 'Namibia', '507', 'AFR', '264', 86, true);
INSERT INTO public."Countries" VALUES (116, 'IL', 'Israel', '383', 'MEA', '972', 87, true);
INSERT INTO public."Countries" VALUES (117, 'CD', 'Congo, The Democratic Republic Of', 'NULL', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (118, 'MQ', 'Martinique', '477', 'CAR', '33', 3, true);
INSERT INTO public."Countries" VALUES (119, 'SL', 'Sierra Leone', '735', 'AFR', '232', 88, true);
INSERT INTO public."Countries" VALUES (120, 'GT', 'Guatemala', '317', 'CAR', '502', 89, true);
INSERT INTO public."Countries" VALUES (121, 'PL', 'Poland', '603', 'EUR', '48', 90, true);
INSERT INTO public."Countries" VALUES (122, 'TC', 'Turks and Caicos Islands', '823', 'CAR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (123, 'NC', 'New Caledonia', '542', 'PAC', '687', 44, true);
INSERT INTO public."Countries" VALUES (124, 'GI', 'Gibraltar', '293', 'EUR', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (125, 'PG', 'Papua New Guinea', '545', 'PAC', '675', 91, true);
INSERT INTO public."Countries" VALUES (126, 'GL', 'Greenland', '305', 'NA', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (127, 'AT', 'Austria', '072', 'EUR', '43', 3, true);
INSERT INTO public."Countries" VALUES (128, 'GU', 'Guam', '313', 'PAC', '671', 2, true);
INSERT INTO public."Countries" VALUES (129, 'MT', 'Malta', '467', 'EUR', '356', 3, true);
INSERT INTO public."Countries" VALUES (130, 'KM', 'Comoros', '173', 'AFR', '269', 92, true);
INSERT INTO public."Countries" VALUES (131, 'TW', 'Taiwan, Province of China', '218', 'ASI', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (132, 'PK', 'Pakistan', '576', 'ASI', '92', 93, true);
INSERT INTO public."Countries" VALUES (133, 'FI', 'Finland', '271', 'EUR', '358', 3, true);
INSERT INTO public."Countries" VALUES (134, 'SB', 'Solomon Islands', '677', 'PAC', '677', 94, true);
INSERT INTO public."Countries" VALUES (135, 'HK', 'Hong Kong', '351', 'ASI', '852', 95, true);
INSERT INTO public."Countries" VALUES (136, 'UA', 'Ukraine', '830', 'EUR', '380', 96, true);
INSERT INTO public."Countries" VALUES (137, 'NU', 'Niue', '531', 'PAC', '683', 27, true);
INSERT INTO public."Countries" VALUES (138, 'DJ', 'Djibouti', 'NULL', 'AFR', '253', 97, true);
INSERT INTO public."Countries" VALUES (139, 'RW', 'Rwanda', '675', 'AFR', '250', 98, true);
INSERT INTO public."Countries" VALUES (140, 'JM', 'Jamaica', '391', 'CAR', '1876', 99, true);
INSERT INTO public."Countries" VALUES (141, 'SD', 'Sudan', '759', 'AFR', '249', 100, true);
INSERT INTO public."Countries" VALUES (142, 'NP', 'Nepal', '517', 'ASI', '977', 101, true);
INSERT INTO public."Countries" VALUES (143, 'LT', 'Lithuania', '443', 'EUR', '9876', 102, true);
INSERT INTO public."Countries" VALUES (144, 'KW', 'Kuwait', '413', 'MEA', '965', 103, true);
INSERT INTO public."Countries" VALUES (145, 'AO', 'Angola', '040', 'AFR', '244', 104, true);
INSERT INTO public."Countries" VALUES (146, 'GA', 'Gabon', '281', 'AFR', '241', 54, true);
INSERT INTO public."Countries" VALUES (147, 'TG', 'Togo', '800', 'AFR', '228', 7, true);
INSERT INTO public."Countries" VALUES (148, 'CR', 'Costa Rica', '196', 'LA', '506', 105, true);
INSERT INTO public."Countries" VALUES (149, 'SI', 'Slovenia', '247', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (150, 'ZM', 'Zambia', '890', 'AFR', '260', 106, true);
INSERT INTO public."Countries" VALUES (151, 'LU', 'Luxembourg', '445', 'EUR', '352', 3, true);
INSERT INTO public."Countries" VALUES (152, 'KE', 'Kenya', '410', 'AFR', '254', 107, true);
INSERT INTO public."Countries" VALUES (153, 'MC', 'Monaco', '498', 'EUR', '377', 3, true);
INSERT INTO public."Countries" VALUES (154, 'OM', 'Oman', '556', 'MEA', '968', 108, true);
INSERT INTO public."Countries" VALUES (155, 'MO', 'Macau', '447', 'ASI', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (156, 'NI', 'Nicaragua', '521', 'LA', '505', 109, true);
INSERT INTO public."Countries" VALUES (157, 'MV', 'Maldives', '461', 'ASI', '960', 110, true);
INSERT INTO public."Countries" VALUES (158, 'LR', 'Liberia', '434', 'AFR', '231', 111, true);
INSERT INTO public."Countries" VALUES (159, 'KI', 'Kiribati', '411', 'PAC', '686', 10, true);
INSERT INTO public."Countries" VALUES (160, 'MU', 'Mauritius', '485', 'AFR', '230', 112, true);
INSERT INTO public."Countries" VALUES (161, 'BY', 'Belarus', '091', 'EUR', '375', 3, true);
INSERT INTO public."Countries" VALUES (162, 'LS', 'Lesotho', '426', 'AFR', '266', 113, true);
INSERT INTO public."Countries" VALUES (163, 'SZ', 'Swaziland', '773', 'AFR', '268', 114, true);
INSERT INTO public."Countries" VALUES (164, 'MR', 'Mauritania', '488', 'AFR', '222', 115, true);
INSERT INTO public."Countries" VALUES (165, 'TD', 'Chad', '203', 'AFR', '235', 54, true);
INSERT INTO public."Countries" VALUES (166, 'KN', 'Saint Kitts and Nevis', '695', 'CAR', '1869', 35, true);
INSERT INTO public."Countries" VALUES (167, 'NE', 'Niger', '525', 'AFR', '227', 7, true);
INSERT INTO public."Countries" VALUES (168, 'BF', 'Burkina Faso', '031', 'AFR', '226', 7, true);
INSERT INTO public."Countries" VALUES (169, 'GW', 'Guinea-Bissau', '334', 'AFR', '245', 7, true);
INSERT INTO public."Countries" VALUES (170, 'SR', 'Suriname', '770', 'LA', '597', 116, true);
INSERT INTO public."Countries" VALUES (171, 'KH', 'Cambodia', '141', 'ASI', '855', 117, true);
INSERT INTO public."Countries" VALUES (172, 'TT', 'Trinidad and Tobago', '815', 'CAR', '1868', 118, true);
INSERT INTO public."Countries" VALUES (173, 'AS', 'American Samoa', '690', 'PAC', '1684', 2, true);
INSERT INTO public."Countries" VALUES (174, 'MM', 'Myanmar', '093', 'ASI', '95', 119, true);
INSERT INTO public."Countries" VALUES (175, 'LV', 'Latvia', '429', 'EUR', '371', 120, true);
INSERT INTO public."Countries" VALUES (176, 'MP', 'Northern Mariana Islands', 'NULL', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (177, 'PW', 'Palau', '578', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (178, 'HN', 'Honduras', '345', 'LA', '504', 121, true);
INSERT INTO public."Countries" VALUES (179, 'RE', 'Reunion', '660', 'AFR', '33', 3, true);
INSERT INTO public."Countries" VALUES (180, 'SV', 'El Salvador', '242', 'LA', '503', 122, true);
INSERT INTO public."Countries" VALUES (181, 'SC', 'Seychelles', '731', 'AFR', '248', 123, true);
INSERT INTO public."Countries" VALUES (182, 'SG', 'Singapore', '741', 'ASI', '65', 124, true);
INSERT INTO public."Countries" VALUES (183, 'BA', 'Bosnia and Herzegovina', '029', 'EUR', '387', 125, true);
INSERT INTO public."Countries" VALUES (184, 'MK', 'Macedonia, The Former Yugoslav Republic of', '448', 'NULL', 'NULL', NULL, true);
INSERT INTO public."Countries" VALUES (185, 'BG', 'Bulgaria', '111', 'EUR', '359', 126, true);
INSERT INTO public."Countries" VALUES (186, 'UZ', 'Uzbekistan', '847', 'ASI', '998', 127, true);
INSERT INTO public."Countries" VALUES (187, 'GE', 'Georgia', '287', 'ASI', '995', 128, true);
INSERT INTO public."Countries" VALUES (188, 'TO', 'Tonga', '810', 'PAC', '676', 129, true);
INSERT INTO public."Countries" VALUES (189, 'IR', 'Iran, Islamic Republic Of', '372', 'MEA', '98', 130, true);
INSERT INTO public."Countries" VALUES (190, 'AL', 'Albania', '017', 'EUR', '355', 131, true);
INSERT INTO public."Countries" VALUES (191, 'EE', 'Estonia', '251', 'EUR', '372', 3, true);
INSERT INTO public."Countries" VALUES (192, 'MG', 'Madagascar', '450', 'AFR', '261', 132, true);
INSERT INTO public."Countries" VALUES (193, 'LY', 'Libyan Arab Jamahiriya', '438', 'AFR', '218', 133, true);
INSERT INTO public."Countries" VALUES (194, 'VC', 'Saint Vincent and The Grenadines', '705', 'CAR', '1784', 35, true);
INSERT INTO public."Countries" VALUES (195, 'VU', 'Vanuatu', '551', 'PAC', '678', 134, true);
INSERT INTO public."Countries" VALUES (196, 'LA', 'Lao People s Democratic Republic', '420', 'ASI', '856', 135, true);
INSERT INTO public."Countries" VALUES (197, 'ST', 'STONIA', '251', 'AFR', '239', 136, true);


--
-- Data for Name: CreditCard; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."CreditCard" VALUES (1, 'VI', 'Visa', 'CREDITO', false, true);
INSERT INTO public."CreditCard" VALUES (2, 'MC', 'Mastercard', 'CREDITO', false, true);
INSERT INTO public."CreditCard" VALUES (3, 'AX', 'American Express', 'CREDITO', false, true);
INSERT INTO public."CreditCard" VALUES (4, 'DC', 'Diners Club', 'CREDITO', false, true);
INSERT INTO public."CreditCard" VALUES (5, 'TP', 'Tarjeta Propia / UATP', 'CREDITO', false, true);
INSERT INTO public."CreditCard" VALUES (6, 'VISA', 'Visa', 'CREDIT', false, true);
INSERT INTO public."CreditCard" VALUES (8, 'AMEX', 'American Express', 'CREDIT', false, true);
INSERT INTO public."CreditCard" VALUES (9, 'DINERS', 'Diners Club', 'CREDIT', false, true);


--
-- Data for Name: Currency; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Currency" VALUES (1, 'COP', 'Peso Colombiano', 1, 2, true);
INSERT INTO public."Currency" VALUES (2, 'USD', 'Dólar Estadounidense', 4200, 2, true);
INSERT INTO public."Currency" VALUES (3, 'EUR', 'Euro', 4500, 2, true);
INSERT INTO public."Currency" VALUES (4, 'DZD', 'Dinar algerino', 1, 2, false);
INSERT INTO public."Currency" VALUES (5, 'DKK', 'Corona danesa', 1, 2, false);
INSERT INTO public."Currency" VALUES (7, 'XOF', 'franco CFA', 1, 2, false);
INSERT INTO public."Currency" VALUES (8, 'SAR', 'Riyal saudi', 1, 2, false);
INSERT INTO public."Currency" VALUES (9, 'NGN', 'Naira nigeriana', 1, 2, false);
INSERT INTO public."Currency" VALUES (10, 'AUD', 'Dolar Australiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (11, 'GBP', 'Libra Estelina', 1, 2, false);
INSERT INTO public."Currency" VALUES (12, 'MXN', 'Peso Mexicano', 1, 2, false);
INSERT INTO public."Currency" VALUES (13, 'GHS', 'Cedi ghanes', 1, 2, false);
INSERT INTO public."Currency" VALUES (15, 'TRY', 'lira turca', 1, 2, false);
INSERT INTO public."Currency" VALUES (16, 'ETB', 'Birr etiope', 1, 2, false);
INSERT INTO public."Currency" VALUES (17, 'YER', 'Rial yemeni', 1, 2, false);
INSERT INTO public."Currency" VALUES (19, 'ARS', 'Peso argentino', 1, 2, false);
INSERT INTO public."Currency" VALUES (20, 'RUB', 'Rublo Ruso', 1, 2, false);
INSERT INTO public."Currency" VALUES (21, 'NOK', 'Corona noruega', 1, 2, false);
INSERT INTO public."Currency" VALUES (22, 'ISK', 'Krona islandesa', 1, 2, false);
INSERT INTO public."Currency" VALUES (23, 'MAD', 'Dirham marroqui', 1, 2, false);
INSERT INTO public."Currency" VALUES (24, 'SEK', 'Corona Sueca', 1, 2, false);
INSERT INTO public."Currency" VALUES (25, 'INR', 'India Rupees', 1, 2, false);
INSERT INTO public."Currency" VALUES (26, 'IDR', 'Rupiah indonesia', 1, 2, false);
INSERT INTO public."Currency" VALUES (27, 'NZD', 'Dolar neozelandes', 1, 2, false);
INSERT INTO public."Currency" VALUES (28, 'BRL', 'Real Brasilero', 1, 2, false);
INSERT INTO public."Currency" VALUES (29, 'KZT', 'Tenge kazajo', 1, 2, false);
INSERT INTO public."Currency" VALUES (30, 'ZAR', 'Rand Sudafricano', 1, 2, false);
INSERT INTO public."Currency" VALUES (31, 'SYP', 'Libra siria', 1, 2, false);
INSERT INTO public."Currency" VALUES (32, 'EGP', 'Libra egipcia', 1, 2, false);
INSERT INTO public."Currency" VALUES (33, 'JOD', 'Dinar', 1, 2, false);
INSERT INTO public."Currency" VALUES (34, 'CLP', 'Peso chileno', 1, 2, false);
INSERT INTO public."Currency" VALUES (35, 'XCD', 'Dolar del Caribe Oriental', 1, 2, false);
INSERT INTO public."Currency" VALUES (36, 'MYR', 'Ringgit malayo', 1, 2, false);
INSERT INTO public."Currency" VALUES (37, 'MZN', 'Metical mozambique¤o', 1, 2, false);
INSERT INTO public."Currency" VALUES (38, 'WST', 'Tala samoano', 1, 2, false);
INSERT INTO public."Currency" VALUES (39, 'PEN', 'Nuevo Sol', 1, 2, false);
INSERT INTO public."Currency" VALUES (40, 'JPY', 'Yen Japones', 1, 2, false);
INSERT INTO public."Currency" VALUES (41, 'PYG', 'Guaran¡ paraguayo', 1, 2, false);
INSERT INTO public."Currency" VALUES (42, 'BSD', 'Dolar bahameno', 1, 2, false);
INSERT INTO public."Currency" VALUES (43, 'AED', 'Dirham de los Emiratos arabes', 1, 2, false);
INSERT INTO public."Currency" VALUES (44, 'XPF', 'Franco CFP', 1, 2, false);
INSERT INTO public."Currency" VALUES (45, 'CUP', 'Cuba Pesos', 1, 2, false);
INSERT INTO public."Currency" VALUES (46, 'PHP', 'Filipinas Pesos', 1, 2, false);
INSERT INTO public."Currency" VALUES (47, 'BHD', 'Dinar bahreini', 1, 2, false);
INSERT INTO public."Currency" VALUES (48, 'AZN', 'Franco CFP', 1, 2, false);
INSERT INTO public."Currency" VALUES (49, 'BWP', 'Pula de Botsuana', 1, 2, false);
INSERT INTO public."Currency" VALUES (50, 'RON', 'Leu rumano', 1, 2, false);
INSERT INTO public."Currency" VALUES (51, 'BMD', 'Dolar de Bermuda', 1, 2, false);
INSERT INTO public."Currency" VALUES (52, 'LBP', 'Libra libanesa', 1, 2, false);
INSERT INTO public."Currency" VALUES (53, 'FJD', 'Dolar fijiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (54, 'XAF', 'Franco CFA', 1, 2, false);
INSERT INTO public."Currency" VALUES (55, 'BBD', 'Dolar de Barbados', 1, 2, false);
INSERT INTO public."Currency" VALUES (56, 'IQD', 'Dinar iraqui', 1, 2, false);
INSERT INTO public."Currency" VALUES (57, 'CNY', 'Yuan Renminbi Chino', 1, 2, false);
INSERT INTO public."Currency" VALUES (58, 'GMD', 'Dalasi gambiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (59, 'BIF', 'Franco burunds', 1, 2, false);
INSERT INTO public."Currency" VALUES (60, 'THB', 'Baht Thailandes', 1, 2, false);
INSERT INTO public."Currency" VALUES (61, 'VEF', 'Bolivar', 1, 2, false);
INSERT INTO public."Currency" VALUES (62, 'MWK', 'Kwacha malauiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (63, 'ANG', 'Florin antillano neerlandes', 1, 2, false);
INSERT INTO public."Currency" VALUES (64, 'CHF', 'FRANCO FRANCES', 1, 2, false);
INSERT INTO public."Currency" VALUES (65, 'CZK', 'Koruna', 1, 2, false);
INSERT INTO public."Currency" VALUES (66, 'DOP', 'Peso dominicano', 1, 2, false);
INSERT INTO public."Currency" VALUES (67, 'HUF', 'Forint hungaro', 1, 2, false);
INSERT INTO public."Currency" VALUES (68, 'ZWR', 'dolar zimbabuense', 1, 2, false);
INSERT INTO public."Currency" VALUES (69, 'CVE', 'Escudo caboverdiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (70, 'BZD', 'Dolar de Belice', 1, 2, false);
INSERT INTO public."Currency" VALUES (71, 'BOB', 'Boliviano', 1, 2, false);
INSERT INTO public."Currency" VALUES (72, 'HTG', 'Gourde haitiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (73, 'BDT', 'Taka de Bangladesh', 1, 2, false);
INSERT INTO public."Currency" VALUES (74, 'KRW', 'Won Surcoreano', 1, 2, false);
INSERT INTO public."Currency" VALUES (75, 'GNF', 'Franco guineano', 1, 2, false);
INSERT INTO public."Currency" VALUES (76, 'LKR', 'Rupia de Sri Lanka', 1, 2, false);
INSERT INTO public."Currency" VALUES (77, 'CAD', 'Dolar Canadiense', 1, 2, false);
INSERT INTO public."Currency" VALUES (78, 'KYD', 'Dolar caimano de Islas Caiman', 1, 2, false);
INSERT INTO public."Currency" VALUES (79, 'UYU', 'Peso Uruguayo', 1, 2, false);
INSERT INTO public."Currency" VALUES (80, 'TZS', 'Chelin tanzano', 1, 2, false);
INSERT INTO public."Currency" VALUES (81, 'HRK', 'Kuna croata', 1, 2, false);
INSERT INTO public."Currency" VALUES (82, 'TND', 'Dinar tunecino', 1, 2, false);
INSERT INTO public."Currency" VALUES (83, 'VND', 'dong vietnamita', 1, 2, false);
INSERT INTO public."Currency" VALUES (84, 'QAR', 'Rial qatari', 1, 2, false);
INSERT INTO public."Currency" VALUES (85, 'UGX', 'chelín ugandes', 1, 2, false);
INSERT INTO public."Currency" VALUES (86, 'NAD', 'Dolar namibio', 1, 2, false);
INSERT INTO public."Currency" VALUES (87, 'ILS', 'Nuevo shequel israeli', 1, 2, false);
INSERT INTO public."Currency" VALUES (88, 'SLL', 'Leone de Sierra Leona', 1, 2, false);
INSERT INTO public."Currency" VALUES (89, 'GTQ', 'Quetzal guatemalteco', 1, 2, false);
INSERT INTO public."Currency" VALUES (90, 'PLN', 'zloty polaco', 1, 2, false);
INSERT INTO public."Currency" VALUES (91, 'PGK', 'Kina de Papua Nueva Guinea', 1, 2, false);
INSERT INTO public."Currency" VALUES (92, 'KMF', 'Franco comoriano de Comoras', 1, 2, false);
INSERT INTO public."Currency" VALUES (93, 'PKR', 'Rupia pakistani', 1, 2, false);
INSERT INTO public."Currency" VALUES (94, 'SBD', 'Dolar de las Islas Salomon', 1, 2, false);
INSERT INTO public."Currency" VALUES (95, 'HKD', 'Dolar Honkones', 1, 2, false);
INSERT INTO public."Currency" VALUES (96, 'UAH', 'grivna ucraniana', 1, 2, false);
INSERT INTO public."Currency" VALUES (97, 'DJF', 'Franco yibutiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (98, 'RWF', 'Franco ruandes', 1, 2, false);
INSERT INTO public."Currency" VALUES (99, 'JMD', 'Dolar Jamaicano', 1, 2, false);
INSERT INTO public."Currency" VALUES (100, 'SDG', 'Dinar sudanes', 1, 2, false);
INSERT INTO public."Currency" VALUES (101, 'NPR', 'Rupia nepalesa', 1, 2, false);
INSERT INTO public."Currency" VALUES (102, 'LTL', 'Litas lituano', 1, 2, false);
INSERT INTO public."Currency" VALUES (103, 'KWD', 'Dinar kuwaiti', 1, 2, false);
INSERT INTO public."Currency" VALUES (104, 'AOA', 'Kwanza angoleno', 1, 2, false);
INSERT INTO public."Currency" VALUES (105, 'CRC', 'Colon costarricense', 1, 2, false);
INSERT INTO public."Currency" VALUES (106, 'ZMK', 'Kwacha zambiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (107, 'KES', 'Chelin keniata', 1, 2, false);
INSERT INTO public."Currency" VALUES (108, 'OMR', 'Rial omani', 1, 2, false);
INSERT INTO public."Currency" VALUES (109, 'NIO', 'Cordoba nicaraguense', 1, 2, false);
INSERT INTO public."Currency" VALUES (110, 'MVR', 'Rufiyaa maldiva', 1, 2, false);
INSERT INTO public."Currency" VALUES (111, 'LRD', 'Dolar liberiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (112, 'MUR', 'Rupia mauricia', 1, 2, false);
INSERT INTO public."Currency" VALUES (113, 'LSL', 'Loti lesotense', 1, 2, false);
INSERT INTO public."Currency" VALUES (114, 'SZL', 'Lilangeni suazi', 1, 2, false);
INSERT INTO public."Currency" VALUES (115, 'MRO', 'Ouguiya mauritana', 1, 2, false);
INSERT INTO public."Currency" VALUES (116, 'SRD', 'Dolar surinames', 1, 2, false);
INSERT INTO public."Currency" VALUES (117, 'KHR', 'Riel camboyano', 1, 2, false);
INSERT INTO public."Currency" VALUES (118, 'TTD', 'dolar de Trinidad y Tobago', 1, 2, false);
INSERT INTO public."Currency" VALUES (119, 'MMK', 'Kyat birmano', 1, 2, false);
INSERT INTO public."Currency" VALUES (120, 'LVL', 'Lat leton', 1, 2, false);
INSERT INTO public."Currency" VALUES (121, 'HNL', 'Lempira hondureno', 1, 2, false);
INSERT INTO public."Currency" VALUES (122, 'SVC', 'Colón salvadoreno', 1, 2, false);
INSERT INTO public."Currency" VALUES (123, 'SCR', 'Rupia de Seychelles', 1, 2, false);
INSERT INTO public."Currency" VALUES (124, 'SGD', 'Dolar Singapur', 1, 2, false);
INSERT INTO public."Currency" VALUES (125, 'BAM', 'Marco convertible de BosniaHe', 1, 2, false);
INSERT INTO public."Currency" VALUES (126, 'BGN', 'Lev belgaro', 1, 2, false);
INSERT INTO public."Currency" VALUES (127, 'UZS', 'Som uzbeko', 1, 2, false);
INSERT INTO public."Currency" VALUES (128, 'GEL', 'Lari georgiano', 1, 2, false);
INSERT INTO public."Currency" VALUES (129, 'TOP', 'Dinar kuwaiti', 1, 2, false);
INSERT INTO public."Currency" VALUES (130, 'IRR', 'Rial irani', 1, 2, false);
INSERT INTO public."Currency" VALUES (131, 'ALL', 'Lek albanes', 1, 2, false);
INSERT INTO public."Currency" VALUES (132, 'MGA', 'Ariary malgache', 1, 2, false);
INSERT INTO public."Currency" VALUES (133, 'LYD', 'Dinar libio', 1, 2, false);
INSERT INTO public."Currency" VALUES (134, 'VUV', 'Vatu de Vanuatu', 1, 2, false);
INSERT INTO public."Currency" VALUES (135, 'LAK', 'Kip lao', 1, 2, false);
INSERT INTO public."Currency" VALUES (136, 'STD', 'Dobra de Santo Tomas y Principe', 1, 2, false);


--
-- Data for Name: DocumentResolution; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: EquivalencesInterfaces; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: EquivalenciasInterfaces_Log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ExecutionPreset; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ExecutionProcedure; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: FormatCellCustomization; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: GDS; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."GDS" VALUES (1, 'SABRE');
INSERT INTO public."GDS" VALUES (2, 'AMADEUS');
INSERT INTO public."GDS" VALUES (3, 'AEROGAL');
INSERT INTO public."GDS" VALUES (4, 'GALILEO');
INSERT INTO public."GDS" VALUES (5, 'ZEUS ON LINE (ZOL)');
INSERT INTO public."GDS" VALUES (6, 'WEB SERVICE');
INSERT INTO public."GDS" VALUES (7, 'KIU');
INSERT INTO public."GDS" VALUES (8, 'IdeasFractal');
INSERT INTO public."GDS" VALUES (9, 'SparkCopa');


--
-- Data for Name: Implant; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InterfaceExtractParam; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Interfaces; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Interfaces" VALUES (1, 'SABRE', 'SABRE', true, false, 'spInterfaceSabre', false, '', false, 1);
INSERT INTO public."Interfaces" VALUES (2, 'AMADEUS', 'AMADEUS', true, false, 'spInterfaceAmadeus', false, '', false, 2);
INSERT INTO public."Interfaces" VALUES (3, 'IdeasFractal', 'IdeasFractal', false, false, 'spInterfaceIdeasFractal', false, '', false, 8);


--
-- Data for Name: Invoices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProduct; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductCombo; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductItinerary; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductPasenger; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductPayment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductTax; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: InvoicesProductVariable; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Master; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Master" VALUES (1, 'Equivalences', 'equivalencias', false);
INSERT INTO public."Master" VALUES (2, 'Diagnostics', 'diagnostico', false);
INSERT INTO public."Master" VALUES (3, 'SystemParameter', 'parametros', false);
INSERT INTO public."Master" VALUES (4, 'User', 'usuarios', false);
INSERT INTO public."Master" VALUES (5, 'Branch', 'sucursales', false);
INSERT INTO public."Master" VALUES (6, 'Implant', 'implantes', false);
INSERT INTO public."Master" VALUES (7, 'ChargeAndTax', 'impuestos', false);
INSERT INTO public."Master" VALUES (8, 'Seller', 'vendedores', false);
INSERT INTO public."Master" VALUES (9, 'TicketPrinter', 'tiqueteadores', false);
INSERT INTO public."Master" VALUES (10, 'Prestadora', 'prestadoras', false);
INSERT INTO public."Master" VALUES (11, 'Client', 'clientes', false);
INSERT INTO public."Master" VALUES (12, 'Provider', 'proveedores', false);
INSERT INTO public."Master" VALUES (13, 'ProviderType', 'tipos-proveedores', false);
INSERT INTO public."Master" VALUES (14, 'Product', 'productos', false);
INSERT INTO public."Master" VALUES (15, 'MasterVariable', 'variables', false);
INSERT INTO public."Master" VALUES (16, 'Combo', 'combos', false);
INSERT INTO public."Master" VALUES (17, 'SystemLog', 'logs', false);
INSERT INTO public."Master" VALUES (18, 'Currency', 'monedas', false);
INSERT INTO public."Master" VALUES (20, 'InterfaceExtractParam', 'extraccion-interfaces', false);
INSERT INTO public."Master" VALUES (21, 'DocumentResolution', 'resoluciones-documentos', false);
INSERT INTO public."Master" VALUES (22, 'TransactionConsecutive', 'consecutivos-transacciones', false);
INSERT INTO public."Master" VALUES (23, 'CreditCard', 'tarjetas-credito', false);
INSERT INTO public."Master" VALUES (24, 'Payment', 'formas-pago', false);
INSERT INTO public."Master" VALUES (25, 'Countries', 'paises', false);
INSERT INTO public."Master" VALUES (26, 'Cities', 'ciudades', false);
INSERT INTO public."Master" VALUES (27, 'Airports', 'aeropuertos', false);
INSERT INTO public."Master" VALUES (28, 'TicketType', 'tipos-tiquetes', false);
INSERT INTO public."Master" VALUES (29, 'QuotationState', 'estados-cotizacion', false);
INSERT INTO public."Master" VALUES (30, 'QuotationFormat', 'formatos-cotizacion', false);


--
-- Data for Name: MasterVariable; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Menu; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Menu" VALUES (3, 'PRECOTIZACIONES', 'Pre-Cotizaciones', NULL, '/dashboard/prequotations', true);
INSERT INTO public."Menu" VALUES (8, 'EJECUCIONES', 'Ejecuciones', NULL, '/dashboard/executions', true);
INSERT INTO public."Menu" VALUES (1, 'MANUAL', 'Manual Operativo', NULL, '/dashboard/manual', true);
INSERT INTO public."Menu" VALUES (2, 'DASHBOARD', 'Dashboard', NULL, '/dashboard', true);
INSERT INTO public."Menu" VALUES (4, 'COTIZACIONES', 'Cotizaciones', NULL, '/dashboard/quotations/history', true);
INSERT INTO public."Menu" VALUES (5, 'FACTURACION', 'Facturación', NULL, '/dashboard/invoices/history', true);
INSERT INTO public."Menu" VALUES (6, 'MAESTROS', 'Maestros', NULL, '/dashboard/settings', true);
INSERT INTO public."Menu" VALUES (7, 'REPORTES', 'Reportes', NULL, '/dashboard/reports', true);


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Payment" VALUES (1, 'EFECTIVO', 'Efectivo', false, false, false, true);
INSERT INTO public."Payment" VALUES (2, 'TARJETA', 'Tarjeta de Crédito', false, false, false, true);
INSERT INTO public."Payment" VALUES (3, 'TRANSFERENCIA', 'Transferencia Bancaria', false, false, false, true);
INSERT INTO public."Payment" VALUES (4, 'CHEQUE', 'Cheque', false, false, false, true);
INSERT INTO public."Payment" VALUES (5, 'CREDITO', 'Crédito / Cuenta por Cobrar', false, false, false, true);


--
-- Data for Name: PreQuotation; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: PreQuotationStateHistory; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Prestadora; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Product; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Product" VALUES (1, 'ALOJAMIENTO', 'Hotel', 0, 0, NULL, NULL, 'HTL', NULL, NULL, NULL, NULL, NULL, '[]', true);
INSERT INTO public."Product" VALUES (2, 'ALQUILER', 'RestaAuto', 0, 0, NULL, NULL, 'RTA', NULL, NULL, NULL, NULL, NULL, '[]', true);


--
-- Data for Name: Provider; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Provider" VALUES (1, '73009263', 'Rubiel', NULL, NULL, NULL, NULL, NULL, true);


--
-- Data for Name: ProviderType; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Quotation; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationCombo; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationFormat; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationManualService; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationPrintCustomization; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationPrintDefaultTemplate; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationProduct; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationProductPassenger; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationProductPayment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationProductTax; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationProductVariable; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: QuotationState; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."QuotationState" VALUES (1, 'NUEVO', 'Nuevo', 'blue', '2026-09-08 10:24:41.105105', true);
INSERT INTO public."QuotationState" VALUES (2, 'ENVIADO', 'ENVIADO', 'emerald', '2026-09-08 10:24:41.105105', true);


--
-- Data for Name: QuotationStateHistory; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Report; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReportColumns; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReportFilters; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReportJoins; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ReportSorts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Resolution; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Role" VALUES (1, 'Admin', NULL, NULL, true);
INSERT INTO public."Role" VALUES (2, 'Superadministrador', NULL, NULL, true);


--
-- Data for Name: Seller; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Seller" VALUES (1, '73009263', 'Rubiel', 'rubiel1985@msn.com', true);


--
-- Data for Name: SysConsecutivo; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: SystemLog; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: SystemParameter; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."SystemParameter" VALUES (1, 'PRODUCTO_RESERVA_GDS', 'Producto por Defecto para Reservas GDS', '');
INSERT INTO public."SystemParameter" VALUES (2, 'LICENSE_KEY', 'Clave de Licencia del Sistema', '');
INSERT INTO public."SystemParameter" VALUES (3, 'LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', '');
INSERT INTO public."SystemParameter" VALUES (4, 'PuertoSQLServer', 'Puerto SQL Server', '');
INSERT INTO public."SystemParameter" VALUES (5, 'EnviarCotizacionesAutoSQLserver', 'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', '1');
INSERT INTO public."SystemParameter" VALUES (6, 'EnviarFacturacionAutoSQLserver', 'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', '1');
INSERT INTO public."SystemParameter" VALUES (7, 'Pais', 'Pais', 'Colombia');
INSERT INTO public."SystemParameter" VALUES (8, 'MOSTRAR_TOTALIZACION_COTIZACION', 'Mostrar totalización financiera en cotización', 'true');
INSERT INTO public."SystemParameter" VALUES (9, 'ServidorSQLServer', 'Host de SQL Server', 'ZEUSAGENCIAS10');
INSERT INTO public."SystemParameter" VALUES (10, 'UsuarioSQLServer', 'Usuario SQL Server', 'zeusagencias');
INSERT INTO public."SystemParameter" VALUES (11, 'ClaveSQLServer', 'Contraseña SQL Server', 'zzeusagencias');
INSERT INTO public."SystemParameter" VALUES (12, 'BaseSQLServer', 'Base de Datos SQL Server', 'Zeusagencias_23');
INSERT INTO public."SystemParameter" VALUES (13, 'AGENCY_NAME', 'Nombre o Razón Social de la Agencia', '');
INSERT INTO public."SystemParameter" VALUES (14, 'AGENCY_NIT', 'NIT de la Agencia', '');
INSERT INTO public."SystemParameter" VALUES (15, 'TASA_CAMBIO_IATA', 'Tasa de Cambio IATA', '4200.00');
INSERT INTO public."SystemParameter" VALUES (16, 'TARIFA_ADMIN_OW', 'Tarifa Administrativa Nacional One Way', '29100');
INSERT INTO public."SystemParameter" VALUES (17, 'TARIFA_ADMIN_RT', 'Tarifa Administrativa Nacional Roundtrip', '52800');
INSERT INTO public."SystemParameter" VALUES (18, 'PRODUCTO_TARIFA_ADMINISTRATIVA', 'Producto por Defecto para Tarifa Administrativa', '77');
INSERT INTO public."SystemParameter" VALUES (19, 'TARIFA_ADMIN_INT_RANGES', 'Rangos Tarifa Administrativa Internacional (JSON)', '[{"min":0,"max":354,"feeUsd":15,"label":"Menores o iguales a USD 354"},{"min":354.01,"max":590,"feeUsd":28,"label":"Mayores de USD 354 hasta USD 590"},{"min":590.01,"max":944,"feeUsd":46,"label":"Mayores de USD 590 hasta USD 944"},{"min":944.01,"max":999999,"feeUsd":95,"label":"Mayores de USD 944"}]');


--
-- Data for Name: TicketPrinter; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."TicketPrinter" VALUES (1, '73009263', 'Rubiel', 'rubiel1985@msn.com', true);


--
-- Data for Name: TicketType; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: TransactionConsecutive; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" VALUES (1, 'Rubiel', 'rubiel1985@msn.com', '$2b$10$IUxxw/yzr2bpC4wRMUcBYOsrIJrG4e0j.FI/p2baH2CGNfKNLbn.S', NULL, NULL, 1, 1, NULL, 1, false, true);
INSERT INTO public."User" VALUES (2, 'Superadministrador', 'ebarrera@zagencias.com', '$2b$10$EvqWyDZ9b/rcMCNNuSdplOyS/NooFO.keByM/UsOgJ6Zy8tgqSYxS', NULL, NULL, 2, 1, NULL, NULL, false, true);


--
-- Name: Airports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Airports_id_seq"', 437, true);


--
-- Name: Attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Attachment_id_seq"', 1, false);


--
-- Name: BookingGDSInvoiceAutoLog_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingGDSInvoiceAutoLog_Id_seq"', 1, false);


--
-- Name: BookingGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingGDS_id_seq"', 1, false);


--
-- Name: BookingProductFEEGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductFEEGDS_id_seq"', 1, false);


--
-- Name: BookingProductGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductGDS_id_seq"', 1, false);


--
-- Name: BookingProductItineraryGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductItineraryGDS_id_seq"', 1, false);


--
-- Name: BookingProductPassangerGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductPassangerGDS_id_seq"', 1, false);


--
-- Name: BookingProductPaymentGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductPaymentGDS_id_seq"', 1, false);


--
-- Name: BookingProductTaxGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductTaxGDS_id_seq"', 1, false);


--
-- Name: BookingProductVariableGDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingProductVariableGDS_id_seq"', 1, false);


--
-- Name: BookingsGDSInvoiceAuto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingsGDSInvoiceAuto_id_seq"', 1, false);


--
-- Name: BookingsGDS_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BookingsGDS_log_id_seq"', 1, false);


--
-- Name: BranchGDSInvoiceAuto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."BranchGDSInvoiceAuto_id_seq"', 9, true);


--
-- Name: Branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Branch_id_seq"', 1, true);


--
-- Name: CellCustomization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."CellCustomization_id_seq"', 63, true);


--
-- Name: ChargeAndTax_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ChargeAndTax_id_seq"', 3, true);


--
-- Name: Cities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Cities_id_seq"', 301, true);


--
-- Name: Client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Client_id_seq"', 1, true);


--
-- Name: ComboProductTax_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ComboProductTax_id_seq"', 1, false);


--
-- Name: ComboProduct_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ComboProduct_id_seq"', 1, false);


--
-- Name: Combo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Combo_id_seq"', 1, false);


--
-- Name: Countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Countries_id_seq"', 197, true);


--
-- Name: CreditCard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."CreditCard_id_seq"', 9, true);


--
-- Name: Currency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Currency_id_seq"', 136, true);


--
-- Name: DocumentResolution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."DocumentResolution_id_seq"', 1, false);


--
-- Name: EquivalencesInterfaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."EquivalencesInterfaces_id_seq"', 1, false);


--
-- Name: EquivalenciasInterfaces_Log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."EquivalenciasInterfaces_Log_id_seq"', 1, false);


--
-- Name: ExecutionPreset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ExecutionPreset_id_seq"', 1, false);


--
-- Name: ExecutionProcedure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ExecutionProcedure_id_seq"', 1, false);


--
-- Name: FormatCellCustomization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."FormatCellCustomization_id_seq"', 1, false);


--
-- Name: GDS_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."GDS_id_seq"', 9, true);


--
-- Name: Implant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Implant_id_seq"', 1, false);


--
-- Name: InterfaceExtractParam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InterfaceExtractParam_id_seq"', 1, false);


--
-- Name: Interfaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Interfaces_id_seq"', 3, true);


--
-- Name: InvoicesProductCombo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductCombo_id_seq"', 1, false);


--
-- Name: InvoicesProductItinerary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductItinerary_id_seq"', 1, false);


--
-- Name: InvoicesProductPasenger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductPasenger_id_seq"', 1, false);


--
-- Name: InvoicesProductPayment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductPayment_id_seq"', 1, false);


--
-- Name: InvoicesProductTax_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductTax_id_seq"', 1, false);


--
-- Name: InvoicesProductVariable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProductVariable_id_seq"', 1, false);


--
-- Name: InvoicesProduct_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."InvoicesProduct_id_seq"', 1, false);


--
-- Name: Invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Invoices_id_seq"', 1, false);


--
-- Name: MasterVariable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."MasterVariable_id_seq"', 1, false);


--
-- Name: Master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Master_id_seq"', 59, true);


--
-- Name: Menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Menu_id_seq"', 29, true);


--
-- Name: Payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Payment_id_seq"', 5, true);


--
-- Name: PreQuotationStateHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."PreQuotationStateHistory_id_seq"', 1, false);


--
-- Name: PreQuotation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."PreQuotation_id_seq"', 1, false);


--
-- Name: Prestadora_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Prestadora_id_seq"', 1, false);


--
-- Name: Product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Product_id_seq"', 2, true);


--
-- Name: ProviderType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ProviderType_id_seq"', 1, false);


--
-- Name: Provider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Provider_id_seq"', 1, true);


--
-- Name: QuotationCombo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationCombo_id_seq"', 1, false);


--
-- Name: QuotationFormat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationFormat_id_seq"', 1, false);


--
-- Name: QuotationManualService_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationManualService_id_seq"', 1, false);


--
-- Name: QuotationPrintCustomization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationPrintCustomization_id_seq"', 1, false);


--
-- Name: QuotationPrintDefaultTemplate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationPrintDefaultTemplate_id_seq"', 1, false);


--
-- Name: QuotationProductPassenger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationProductPassenger_id_seq"', 1, false);


--
-- Name: QuotationProductPayment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationProductPayment_id_seq"', 1, false);


--
-- Name: QuotationProductTax_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationProductTax_id_seq"', 1, false);


--
-- Name: QuotationProductVariable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationProductVariable_id_seq"', 1, false);


--
-- Name: QuotationProduct_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationProduct_id_seq"', 1, false);


--
-- Name: QuotationStateHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationStateHistory_id_seq"', 1, false);


--
-- Name: QuotationState_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."QuotationState_id_seq"', 2, true);


--
-- Name: Quotation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Quotation_id_seq"', 1, false);


--
-- Name: ReportColumns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ReportColumns_id_seq"', 1, false);


--
-- Name: ReportFilters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ReportFilters_id_seq"', 1, false);


--
-- Name: ReportJoins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ReportJoins_id_seq"', 1, false);


--
-- Name: ReportSorts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ReportSorts_id_seq"', 1, false);


--
-- Name: Report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Report_id_seq"', 1, false);


--
-- Name: Resolution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Resolution_id_seq"', 1, false);


--
-- Name: Role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Role_id_seq"', 2, true);


--
-- Name: Seller_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Seller_id_seq"', 1, true);


--
-- Name: SysConsecutivo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."SysConsecutivo_id_seq"', 1, false);


--
-- Name: SystemLog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."SystemLog_id_seq"', 1, false);


--
-- Name: SystemParameter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."SystemParameter_id_seq"', 47, true);


--
-- Name: TicketPrinter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TicketPrinter_id_seq"', 1, true);


--
-- Name: TicketType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TicketType_id_seq"', 1, false);


--
-- Name: TransactionConsecutive_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TransactionConsecutive_id_seq"', 1, false);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."User_id_seq"', 2, true);


--
-- Name: seq_quotation_consecutivo; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_quotation_consecutivo', 1, false);


--
-- Name: Airports Airports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Airports"
    ADD CONSTRAINT "Airports_pkey" PRIMARY KEY (id);


--
-- Name: Attachment Attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attachment"
    ADD CONSTRAINT "Attachment_pkey" PRIMARY KEY (id);


--
-- Name: BookingGDSInvoiceAutoLog BookingGDSInvoiceAutoLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingGDSInvoiceAutoLog"
    ADD CONSTRAINT "BookingGDSInvoiceAutoLog_pkey" PRIMARY KEY ("Id");


--
-- Name: BookingGDS BookingGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingGDS"
    ADD CONSTRAINT "BookingGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductFEEGDS BookingProductFEEGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductFEEGDS"
    ADD CONSTRAINT "BookingProductFEEGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductGDS BookingProductGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductGDS"
    ADD CONSTRAINT "BookingProductGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductItineraryGDS BookingProductItineraryGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductItineraryGDS"
    ADD CONSTRAINT "BookingProductItineraryGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductPassangerGDS BookingProductPassangerGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPassangerGDS"
    ADD CONSTRAINT "BookingProductPassangerGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductPaymentGDS BookingProductPaymentGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPaymentGDS"
    ADD CONSTRAINT "BookingProductPaymentGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductTaxGDS BookingProductTaxGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductTaxGDS"
    ADD CONSTRAINT "BookingProductTaxGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingProductVariableGDS BookingProductVariableGDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductVariableGDS"
    ADD CONSTRAINT "BookingProductVariableGDS_pkey" PRIMARY KEY (id);


--
-- Name: BookingsGDSInvoiceAuto BookingsGDSInvoiceAuto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingsGDSInvoiceAuto"
    ADD CONSTRAINT "BookingsGDSInvoiceAuto_pkey" PRIMARY KEY (id);


--
-- Name: BookingsGDS_log BookingsGDS_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingsGDS_log"
    ADD CONSTRAINT "BookingsGDS_log_pkey" PRIMARY KEY (id);


--
-- Name: BranchGDSInvoiceAuto BranchGDSInvoiceAuto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BranchGDSInvoiceAuto"
    ADD CONSTRAINT "BranchGDSInvoiceAuto_pkey" PRIMARY KEY (id);


--
-- Name: Branch Branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);


--
-- Name: CellCustomization CellCustomization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CellCustomization"
    ADD CONSTRAINT "CellCustomization_pkey" PRIMARY KEY (id);


--
-- Name: ChargeAndTax ChargeAndTax_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeAndTax"
    ADD CONSTRAINT "ChargeAndTax_pkey" PRIMARY KEY (id);


--
-- Name: Cities Cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Cities"
    ADD CONSTRAINT "Cities_pkey" PRIMARY KEY (id);


--
-- Name: Client Client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Client"
    ADD CONSTRAINT "Client_pkey" PRIMARY KEY (id);


--
-- Name: ComboProductTax ComboProductTax_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProductTax"
    ADD CONSTRAINT "ComboProductTax_pkey" PRIMARY KEY (id);


--
-- Name: ComboProduct ComboProduct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct"
    ADD CONSTRAINT "ComboProduct_pkey" PRIMARY KEY (id);


--
-- Name: Combo Combo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Combo"
    ADD CONSTRAINT "Combo_pkey" PRIMARY KEY (id);


--
-- Name: Countries Countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Countries"
    ADD CONSTRAINT "Countries_pkey" PRIMARY KEY (id);


--
-- Name: CreditCard CreditCard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_pkey" PRIMARY KEY (id);


--
-- Name: Currency Currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Currency"
    ADD CONSTRAINT "Currency_pkey" PRIMARY KEY (id);


--
-- Name: DocumentResolution DocumentResolution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentResolution"
    ADD CONSTRAINT "DocumentResolution_pkey" PRIMARY KEY (id);


--
-- Name: EquivalencesInterfaces EquivalencesInterfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalencesInterfaces"
    ADD CONSTRAINT "EquivalencesInterfaces_pkey" PRIMARY KEY (id);


--
-- Name: EquivalenciasInterfaces_Log EquivalenciasInterfaces_Log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalenciasInterfaces_Log"
    ADD CONSTRAINT "EquivalenciasInterfaces_Log_pkey" PRIMARY KEY (id);


--
-- Name: ExecutionPreset ExecutionPreset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExecutionPreset"
    ADD CONSTRAINT "ExecutionPreset_pkey" PRIMARY KEY (id);


--
-- Name: ExecutionProcedure ExecutionProcedure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExecutionProcedure"
    ADD CONSTRAINT "ExecutionProcedure_pkey" PRIMARY KEY (id);


--
-- Name: FormatCellCustomization FormatCellCustomization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FormatCellCustomization"
    ADD CONSTRAINT "FormatCellCustomization_pkey" PRIMARY KEY (id);


--
-- Name: GDS GDS_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GDS"
    ADD CONSTRAINT "GDS_pkey" PRIMARY KEY (id);


--
-- Name: Implant Implant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Implant"
    ADD CONSTRAINT "Implant_pkey" PRIMARY KEY (id);


--
-- Name: InterfaceExtractParam InterfaceExtractParam_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InterfaceExtractParam"
    ADD CONSTRAINT "InterfaceExtractParam_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductCombo InvoicesProductCombo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductCombo"
    ADD CONSTRAINT "InvoicesProductCombo_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductItinerary InvoicesProductItinerary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductItinerary"
    ADD CONSTRAINT "InvoicesProductItinerary_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductPasenger InvoicesProductPasenger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductPasenger"
    ADD CONSTRAINT "InvoicesProductPasenger_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductPayment InvoicesProductPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductPayment"
    ADD CONSTRAINT "InvoicesProductPayment_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductTax InvoicesProductTax_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductTax"
    ADD CONSTRAINT "InvoicesProductTax_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProductVariable InvoicesProductVariable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductVariable"
    ADD CONSTRAINT "InvoicesProductVariable_pkey" PRIMARY KEY (id);


--
-- Name: InvoicesProduct InvoicesProduct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProduct"
    ADD CONSTRAINT "InvoicesProduct_pkey" PRIMARY KEY (id);


--
-- Name: Invoices Invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoices"
    ADD CONSTRAINT "Invoices_pkey" PRIMARY KEY (id);


--
-- Name: MasterVariable MasterVariable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MasterVariable"
    ADD CONSTRAINT "MasterVariable_pkey" PRIMARY KEY (id);


--
-- Name: Menu Menu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Menu"
    ADD CONSTRAINT "Menu_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: PreQuotationStateHistory PreQuotationStateHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotationStateHistory"
    ADD CONSTRAINT "PreQuotationStateHistory_pkey" PRIMARY KEY (id);


--
-- Name: PreQuotation PreQuotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_pkey" PRIMARY KEY (id);


--
-- Name: Prestadora Prestadora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Prestadora"
    ADD CONSTRAINT "Prestadora_pkey" PRIMARY KEY (id);


--
-- Name: Product Product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);


--
-- Name: ProviderType ProviderType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProviderType"
    ADD CONSTRAINT "ProviderType_pkey" PRIMARY KEY (id);


--
-- Name: Provider Provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Provider"
    ADD CONSTRAINT "Provider_pkey" PRIMARY KEY (id);


--
-- Name: QuotationCombo QuotationCombo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationCombo"
    ADD CONSTRAINT "QuotationCombo_pkey" PRIMARY KEY (id);


--
-- Name: QuotationFormat QuotationFormat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationFormat"
    ADD CONSTRAINT "QuotationFormat_pkey" PRIMARY KEY (id);


--
-- Name: QuotationManualService QuotationManualService_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationManualService"
    ADD CONSTRAINT "QuotationManualService_pkey" PRIMARY KEY (id);


--
-- Name: QuotationPrintCustomization QuotationPrintCustomization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationPrintCustomization"
    ADD CONSTRAINT "QuotationPrintCustomization_pkey" PRIMARY KEY (id);


--
-- Name: QuotationPrintDefaultTemplate QuotationPrintDefaultTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationPrintDefaultTemplate"
    ADD CONSTRAINT "QuotationPrintDefaultTemplate_pkey" PRIMARY KEY (id);


--
-- Name: QuotationProductPassenger QuotationProductPassenger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPassenger"
    ADD CONSTRAINT "QuotationProductPassenger_pkey" PRIMARY KEY (id);


--
-- Name: QuotationProductPayment QuotationProductPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPayment"
    ADD CONSTRAINT "QuotationProductPayment_pkey" PRIMARY KEY (id);


--
-- Name: QuotationProductTax QuotationProductTax_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductTax"
    ADD CONSTRAINT "QuotationProductTax_pkey" PRIMARY KEY (id);


--
-- Name: QuotationProductVariable QuotationProductVariable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductVariable"
    ADD CONSTRAINT "QuotationProductVariable_pkey" PRIMARY KEY (id);


--
-- Name: QuotationProduct QuotationProduct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct"
    ADD CONSTRAINT "QuotationProduct_pkey" PRIMARY KEY (id);


--
-- Name: QuotationStateHistory QuotationStateHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationStateHistory"
    ADD CONSTRAINT "QuotationStateHistory_pkey" PRIMARY KEY (id);


--
-- Name: QuotationState QuotationState_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationState"
    ADD CONSTRAINT "QuotationState_pkey" PRIMARY KEY (id);


--
-- Name: Quotation Quotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_pkey" PRIMARY KEY (id);


--
-- Name: ReportColumns ReportColumns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportColumns"
    ADD CONSTRAINT "ReportColumns_pkey" PRIMARY KEY (id);


--
-- Name: ReportFilters ReportFilters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportFilters"
    ADD CONSTRAINT "ReportFilters_pkey" PRIMARY KEY (id);


--
-- Name: ReportJoins ReportJoins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportJoins"
    ADD CONSTRAINT "ReportJoins_pkey" PRIMARY KEY (id);


--
-- Name: ReportSorts ReportSorts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportSorts"
    ADD CONSTRAINT "ReportSorts_pkey" PRIMARY KEY (id);


--
-- Name: Report Report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Report"
    ADD CONSTRAINT "Report_pkey" PRIMARY KEY (id);


--
-- Name: Resolution Resolution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Resolution"
    ADD CONSTRAINT "Resolution_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: Seller Seller_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Seller"
    ADD CONSTRAINT "Seller_pkey" PRIMARY KEY (id);


--
-- Name: SysConsecutivo SysConsecutivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SysConsecutivo"
    ADD CONSTRAINT "SysConsecutivo_pkey" PRIMARY KEY (id);


--
-- Name: SystemLog SystemLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SystemLog"
    ADD CONSTRAINT "SystemLog_pkey" PRIMARY KEY (id);


--
-- Name: SystemParameter SystemParameter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SystemParameter"
    ADD CONSTRAINT "SystemParameter_pkey" PRIMARY KEY (id);


--
-- Name: TicketPrinter TicketPrinter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TicketPrinter"
    ADD CONSTRAINT "TicketPrinter_pkey" PRIMARY KEY (id);


--
-- Name: TicketType TicketType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TicketType"
    ADD CONSTRAINT "TicketType_pkey" PRIMARY KEY (id);


--
-- Name: TransactionConsecutive TransactionConsecutive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TransactionConsecutive"
    ADD CONSTRAINT "TransactionConsecutive_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Interfaces interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Interfaces"
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (id);


--
-- Name: Master master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Master"
    ADD CONSTRAINT master_pkey PRIMARY KEY (id);


--
-- Name: Airports_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Airports_code_key" ON public."Airports" USING btree (code);


--
-- Name: BookingGDS_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingGDS_code_key" ON public."BookingGDS" USING btree (code);


--
-- Name: Branch_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Branch_code_key" ON public."Branch" USING btree (code);


--
-- Name: CellCustomization_branch_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CellCustomization_branch_code_key" ON public."CellCustomization" USING btree ("branchId", code) WHERE ("branchId" IS NOT NULL);


--
-- Name: CellCustomization_implant_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CellCustomization_implant_code_key" ON public."CellCustomization" USING btree ("implantId", code) WHERE ("implantId" IS NOT NULL);


--
-- Name: ChargeAndTax_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChargeAndTax_code_key" ON public."ChargeAndTax" USING btree (code);


--
-- Name: Cities_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Cities_code_key" ON public."Cities" USING btree (code);


--
-- Name: Client_document_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Client_document_key" ON public."Client" USING btree (document);


--
-- Name: Combo_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Combo_code_key" ON public."Combo" USING btree (code);


--
-- Name: Countries_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Countries_code_key" ON public."Countries" USING btree (code);


--
-- Name: CreditCard_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CreditCard_code_key" ON public."CreditCard" USING btree (code);


--
-- Name: Currency_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Currency_code_key" ON public."Currency" USING btree (code);


--
-- Name: FormatCellCustomization_format_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "FormatCellCustomization_format_code_key" ON public."FormatCellCustomization" USING btree ("formatId", code);


--
-- Name: GDS_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "GDS_name_key" ON public."GDS" USING btree (name);


--
-- Name: Hotel_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Hotel_code_key" ON public."Prestadora" USING btree (code);


--
-- Name: Implant_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Implant_code_key" ON public."Implant" USING btree (code);


--
-- Name: InterfaceExtractParam_interfaceId_prefix_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InterfaceExtractParam_interfaceId_prefix_key" ON public."InterfaceExtractParam" USING btree ("interfaceId", prefix);


--
-- Name: Interfaces_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Interfaces_code_key" ON public."Interfaces" USING btree (code);


--
-- Name: Invoices_internalNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Invoices_internalNumber_key" ON public."Invoices" USING btree ("internalNumber");


--
-- Name: MasterVariable_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MasterVariable_code_key" ON public."MasterVariable" USING btree (code);


--
-- Name: Master_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Master_code_key" ON public."Master" USING btree (code);


--
-- Name: Menu_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Menu_code_key" ON public."Menu" USING btree (code);


--
-- Name: Payment_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Payment_code_key" ON public."Payment" USING btree (code);


--
-- Name: PreQuotation_consecutivo_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PreQuotation_consecutivo_key" ON public."PreQuotation" USING btree (consecutivo);


--
-- Name: Product_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Product_code_key" ON public."Product" USING btree (code);


--
-- Name: ProviderType_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ProviderType_code_key" ON public."ProviderType" USING btree (code);


--
-- Name: Provider_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Provider_code_key" ON public."Provider" USING btree (code);


--
-- Name: QuotationFormat_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuotationFormat_name_key" ON public."QuotationFormat" USING btree (name);


--
-- Name: QuotationPrintCustomization_quotationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuotationPrintCustomization_quotationId_key" ON public."QuotationPrintCustomization" USING btree ("quotationId");


--
-- Name: QuotationStateHistory_quotationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationStateHistory_quotationId_idx" ON public."QuotationStateHistory" USING btree ("quotationId");


--
-- Name: QuotationState_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuotationState_code_key" ON public."QuotationState" USING btree (code);


--
-- Name: Quotation_internalNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Quotation_internalNumber_key" ON public."Quotation" USING btree ("internalNumber");


--
-- Name: Resolution_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Resolution_code_key" ON public."Resolution" USING btree (code);


--
-- Name: Role_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Role_name_key" ON public."Role" USING btree (name);


--
-- Name: Seller_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Seller_code_key" ON public."Seller" USING btree (code);


--
-- Name: SystemParameter_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SystemParameter_code_key" ON public."SystemParameter" USING btree (code);


--
-- Name: TicketPrinter_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TicketPrinter_code_key" ON public."TicketPrinter" USING btree (code);


--
-- Name: TicketType_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TicketType_code_key" ON public."TicketType" USING btree (code);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_resetPasswordToken_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_resetPasswordToken_key" ON public."User" USING btree ("resetPasswordToken");


--
-- Name: idx_sysconsecutivo_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sysconsecutivo_branch ON public."SysConsecutivo" USING btree ("branchId");


--
-- Name: idx_sysconsecutivo_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sysconsecutivo_codigo ON public."SysConsecutivo" USING btree (codigo);


--
-- Name: idx_sysconsecutivo_implant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sysconsecutivo_implant ON public."SysConsecutivo" USING btree ("implantId");


--
-- Name: Airports Airports_citiesId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Airports"
    ADD CONSTRAINT "Airports_citiesId_fkey" FOREIGN KEY ("citiesId") REFERENCES public."Cities"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Attachment Attachment_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attachment"
    ADD CONSTRAINT "Attachment_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductFEEGDS BookingProductFEEGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductFEEGDS"
    ADD CONSTRAINT "BookingProductFEEGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductGDS BookingProductGDS_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductGDS"
    ADD CONSTRAINT "BookingProductGDS_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."BookingGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductItineraryGDS BookingProductItineraryGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductItineraryGDS"
    ADD CONSTRAINT "BookingProductItineraryGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductPassangerGDS BookingProductPassangerGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPassangerGDS"
    ADD CONSTRAINT "BookingProductPassangerGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductPaymentGDS BookingProductPaymentGDS_bookingProductFEEId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPaymentGDS"
    ADD CONSTRAINT "BookingProductPaymentGDS_bookingProductFEEId_fkey" FOREIGN KEY ("bookingProductFEEId") REFERENCES public."BookingProductFEEGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductPaymentGDS BookingProductPaymentGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductPaymentGDS"
    ADD CONSTRAINT "BookingProductPaymentGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductTaxGDS BookingProductTaxGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductTaxGDS"
    ADD CONSTRAINT "BookingProductTaxGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingProductVariableGDS BookingProductVariableGDS_bookingProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingProductVariableGDS"
    ADD CONSTRAINT "BookingProductVariableGDS_bookingProductId_fkey" FOREIGN KEY ("bookingProductId") REFERENCES public."BookingProductGDS"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BranchGDSInvoiceAuto BranchGDSInvoiceAuto_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BranchGDSInvoiceAuto"
    ADD CONSTRAINT "BranchGDSInvoiceAuto_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CellCustomization CellCustomization_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CellCustomization"
    ADD CONSTRAINT "CellCustomization_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CellCustomization CellCustomization_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CellCustomization"
    ADD CONSTRAINT "CellCustomization_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Cities Cities_countriesId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Cities"
    ADD CONSTRAINT "Cities_countriesId_fkey" FOREIGN KEY ("countriesId") REFERENCES public."Countries"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Client Client_sellerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Client"
    ADD CONSTRAINT "Client_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."Seller"(id) ON DELETE SET NULL;


--
-- Name: ComboProductTax ComboProductTax_chargeAndTaxId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProductTax"
    ADD CONSTRAINT "ComboProductTax_chargeAndTaxId_fkey" FOREIGN KEY ("chargeAndTaxId") REFERENCES public."ChargeAndTax"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ComboProductTax ComboProductTax_comboProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProductTax"
    ADD CONSTRAINT "ComboProductTax_comboProductId_fkey" FOREIGN KEY ("comboProductId") REFERENCES public."ComboProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ComboProduct ComboProduct_comboId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct"
    ADD CONSTRAINT "ComboProduct_comboId_fkey" FOREIGN KEY ("comboId") REFERENCES public."Combo"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ComboProduct ComboProduct_prestadoraId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct"
    ADD CONSTRAINT "ComboProduct_prestadoraId_fkey" FOREIGN KEY ("prestadoraId") REFERENCES public."Prestadora"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ComboProduct ComboProduct_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct"
    ADD CONSTRAINT "ComboProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ComboProduct ComboProduct_providerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ComboProduct"
    ADD CONSTRAINT "ComboProduct_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Combo Combo_currencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Combo"
    ADD CONSTRAINT "Combo_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Countries Countries_curencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Countries"
    ADD CONSTRAINT "Countries_curencyId_fkey" FOREIGN KEY ("curencyId") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DocumentResolution DocumentResolution_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentResolution"
    ADD CONSTRAINT "DocumentResolution_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE CASCADE;


--
-- Name: DocumentResolution DocumentResolution_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentResolution"
    ADD CONSTRAINT "DocumentResolution_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON DELETE SET NULL;


--
-- Name: EquivalencesInterfaces EquivalencesInterfaces_id_interfaces_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalencesInterfaces"
    ADD CONSTRAINT "EquivalencesInterfaces_id_interfaces_fkey" FOREIGN KEY (id_interfaces) REFERENCES public."Interfaces"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EquivalencesInterfaces EquivalencesInterfaces_id_master_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EquivalencesInterfaces"
    ADD CONSTRAINT "EquivalencesInterfaces_id_master_fkey" FOREIGN KEY (id_master) REFERENCES public."Master"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExecutionPreset ExecutionPreset_procedureId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExecutionPreset"
    ADD CONSTRAINT "ExecutionPreset_procedureId_fkey" FOREIGN KEY ("procedureId") REFERENCES public."ExecutionProcedure"(id) ON DELETE CASCADE;


--
-- Name: FormatCellCustomization FormatCellCustomization_formatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FormatCellCustomization"
    ADD CONSTRAINT "FormatCellCustomization_formatId_fkey" FOREIGN KEY ("formatId") REFERENCES public."QuotationFormat"(id) ON DELETE CASCADE;


--
-- Name: Implant Implant_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Implant"
    ADD CONSTRAINT "Implant_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: InterfaceExtractParam InterfaceExtractParam_interfaceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InterfaceExtractParam"
    ADD CONSTRAINT "InterfaceExtractParam_interfaceId_fkey" FOREIGN KEY ("interfaceId") REFERENCES public."Interfaces"(id) ON DELETE CASCADE;


--
-- Name: InvoicesProductItinerary InvoicesProductItinerary_invoiceProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductItinerary"
    ADD CONSTRAINT "InvoicesProductItinerary_invoiceProductId_fkey" FOREIGN KEY ("invoiceProductId") REFERENCES public."InvoicesProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InvoicesProductPayment InvoicesProductPayment_creditCardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoicesProductPayment"
    ADD CONSTRAINT "InvoicesProductPayment_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES public."CreditCard"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PreQuotationStateHistory PreQuotationStateHistory_preQuotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotationStateHistory"
    ADD CONSTRAINT "PreQuotationStateHistory_preQuotationId_fkey" FOREIGN KEY ("preQuotationId") REFERENCES public."PreQuotation"(id) ON DELETE CASCADE;


--
-- Name: PreQuotationStateHistory PreQuotationStateHistory_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotationStateHistory"
    ADD CONSTRAINT "PreQuotationStateHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT;


--
-- Name: PreQuotation PreQuotation_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE RESTRICT;


--
-- Name: PreQuotation PreQuotation_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."Client"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_convertedQuotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_convertedQuotationId_fkey" FOREIGN KEY ("convertedQuotationId") REFERENCES public."Quotation"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_convertedUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_convertedUserId_fkey" FOREIGN KEY ("convertedUserId") REFERENCES public."User"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_providerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_sellerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."Seller"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_ticketPrinterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_ticketPrinterId_fkey" FOREIGN KEY ("ticketPrinterId") REFERENCES public."TicketPrinter"(id) ON DELETE SET NULL;


--
-- Name: PreQuotation PreQuotation_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PreQuotation"
    ADD CONSTRAINT "PreQuotation_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT;


--
-- Name: Prestadora Prestadora_providerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Prestadora"
    ADD CONSTRAINT "Prestadora_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Product Product_ticketTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_ticketTypeId_fkey" FOREIGN KEY ("ticketTypeId") REFERENCES public."TicketType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Provider Provider_providerTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Provider"
    ADD CONSTRAINT "Provider_providerTypeId_fkey" FOREIGN KEY ("providerTypeId") REFERENCES public."ProviderType"(id) ON DELETE SET NULL;


--
-- Name: QuotationCombo QuotationCombo_comboId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationCombo"
    ADD CONSTRAINT "QuotationCombo_comboId_fkey" FOREIGN KEY ("comboId") REFERENCES public."Combo"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: QuotationCombo QuotationCombo_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationCombo"
    ADD CONSTRAINT "QuotationCombo_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationFormat QuotationFormat_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationFormat"
    ADD CONSTRAINT "QuotationFormat_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE CASCADE;


--
-- Name: QuotationFormat QuotationFormat_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationFormat"
    ADD CONSTRAINT "QuotationFormat_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON DELETE CASCADE;


--
-- Name: QuotationManualService QuotationManualService_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationManualService"
    ADD CONSTRAINT "QuotationManualService_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON DELETE CASCADE;


--
-- Name: QuotationProductPassenger QuotationProductPassenger_quotationProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPassenger"
    ADD CONSTRAINT "QuotationProductPassenger_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationProductPayment QuotationProductPayment_quotationProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductPayment"
    ADD CONSTRAINT "QuotationProductPayment_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationProductTax QuotationProductTax_chargeAndTaxId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductTax"
    ADD CONSTRAINT "QuotationProductTax_chargeAndTaxId_fkey" FOREIGN KEY ("chargeAndTaxId") REFERENCES public."ChargeAndTax"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: QuotationProductTax QuotationProductTax_quotationProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductTax"
    ADD CONSTRAINT "QuotationProductTax_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationProductVariable QuotationProductVariable_masterVariableId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductVariable"
    ADD CONSTRAINT "QuotationProductVariable_masterVariableId_fkey" FOREIGN KEY ("masterVariableId") REFERENCES public."MasterVariable"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: QuotationProductVariable QuotationProductVariable_quotationProductId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProductVariable"
    ADD CONSTRAINT "QuotationProductVariable_quotationProductId_fkey" FOREIGN KEY ("quotationProductId") REFERENCES public."QuotationProduct"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationProduct QuotationProduct_prestadoraId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct"
    ADD CONSTRAINT "QuotationProduct_prestadoraId_fkey" FOREIGN KEY ("prestadoraId") REFERENCES public."Prestadora"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: QuotationProduct QuotationProduct_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct"
    ADD CONSTRAINT "QuotationProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationProduct QuotationProduct_providerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct"
    ADD CONSTRAINT "QuotationProduct_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES public."Provider"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: QuotationProduct QuotationProduct_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationProduct"
    ADD CONSTRAINT "QuotationProduct_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationStateHistory QuotationStateHistory_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationStateHistory"
    ADD CONSTRAINT "QuotationStateHistory_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationStateHistory QuotationStateHistory_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationStateHistory"
    ADD CONSTRAINT "QuotationStateHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Quotation Quotation_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."Client"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Quotation Quotation_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_sellerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."Seller"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_ticketPrinterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_ticketPrinterId_fkey" FOREIGN KEY ("ticketPrinterId") REFERENCES public."TicketPrinter"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ReportColumns ReportColumns_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportColumns"
    ADD CONSTRAINT "ReportColumns_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;


--
-- Name: ReportFilters ReportFilters_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportFilters"
    ADD CONSTRAINT "ReportFilters_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;


--
-- Name: ReportJoins ReportJoins_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportJoins"
    ADD CONSTRAINT "ReportJoins_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;


--
-- Name: ReportSorts ReportSorts_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReportSorts"
    ADD CONSTRAINT "ReportSorts_report_id_fkey" FOREIGN KEY (report_id) REFERENCES public."Report"(id) ON DELETE CASCADE;


--
-- Name: SysConsecutivo SysConsecutivo_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SysConsecutivo"
    ADD CONSTRAINT "SysConsecutivo_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE SET NULL;


--
-- Name: SysConsecutivo SysConsecutivo_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SysConsecutivo"
    ADD CONSTRAINT "SysConsecutivo_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON DELETE SET NULL;


--
-- Name: SystemLog SystemLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SystemLog"
    ADD CONSTRAINT "SystemLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: TransactionConsecutive TransactionConsecutive_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TransactionConsecutive"
    ADD CONSTRAINT "TransactionConsecutive_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON DELETE SET NULL;


--
-- Name: TransactionConsecutive TransactionConsecutive_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TransactionConsecutive"
    ADD CONSTRAINT "TransactionConsecutive_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON DELETE SET NULL;


--
-- Name: User User_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: User User_implantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_implantId_fkey" FOREIGN KEY ("implantId") REFERENCES public."Implant"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: User User_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_ticketPrinterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_ticketPrinterId_fkey" FOREIGN KEY ("ticketPrinterId") REFERENCES public."TicketPrinter"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict W0l5rqHAu2hBc9ZD3MkW4HMeeQyOVnFNDs7u6RzsJuIk2s8dadjuQ9ij0120Z1H

