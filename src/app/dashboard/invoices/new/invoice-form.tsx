'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Save, Trash2, Plus, ChevronDown, ChevronUp, Calendar, Users, Globe, DollarSign, Briefcase, Hotel as HotelIcon, Tag, Tags, Percent, Calculator, ArrowRight, Loader2, FileDown, Paperclip, FileText, Download, X, Printer, Search, ExternalLink, CheckCircle2, AlertTriangle, Lock } from 'lucide-react'
import { format, differenceInDays } from 'date-fns'
import { useRouter } from 'next/navigation'
import { cn } from '@/lib/utils'
import { generateInvoicePDF } from '@/lib/pdf-utils'
import { SearchSelect } from '@/components/SearchSelect'
import GlobalPaymentModal from './GlobalPaymentModal';
import ItemPaymentModal from './ItemPaymentModal';
import SearchBookingModal from './SearchBookingModal';
import { CreditCard } from 'lucide-react';
import { parseAndValidateCreditCard } from '@/lib/creditCardUtils';


interface InvoiceFormData {
    clientId: string;
    branchId: string;
    implantId: string;
    currency: string;
    exchangeRate: number;
    sellerId: string;
    ticketPrinterId: string;
    commissionPercentage: number;
    chargesAndTaxes: number;
    items: {
        productId: string;
        quantity: number;
        price: number;
        cost: number;
        providerId: string;
        prestadoraId: string;
        checkIn: string;
        checkOut: string;
        paxAdults: number;
        paxChildren: number;
        destination: string;
        serviceType: string;
        reservationCode: string;
        passengers?: { name: string, document: string }[];
        servicios?: string;
        descripcion?: string;
        ticketCode?: string;
        class?: string;
        itinerary?: string;
          airline?: string;
        ticketTypeId?: number;
        payments?: { amount: number, paymentMethod: string, date: string, reference: string, creditCardId?: number, cardNumber?: string, authorizationCode?: string, voucher?: string, expirationDate?: string }[];
        itinerariesItineraryList?: { id?: number, orden?: number, origin: string, destination: string, class?: string, checkInDate?: string, checkOutDate?: string, terminal?: string, prestadoraCode?: string, farebasis?: string, Numflight?: string, Typeflight?: string, amount?: number, co2?: number }[];
        isPaymentModalOpen?: boolean;
        sellerCommission: number;
        ticketPrinterCommission: number;
        mainTaxId?: number;
        appliedTaxes: { id?: number, name?: string, amount: number }[],
        variables: { id?: number, masterVariableId: number, value: string }[];
        comboId?: number;
        inNationality?: number;
        _productName?: string;
        _providerName?: string;
        _prestadoraName?: string;
    }[];
    selectedCombos?: { id: number, name: string }[];
    state: string;
    fuente?: string;
    serie?: string;
    consecutivo?: string;
    date?: string;
    dueDate?: string;
}

export function computeItinerarySummaries(itineraryList: any[]) {
    if (!Array.isArray(itineraryList) || itineraryList.length === 0) {
        return { flightItinerary: '', classItinerary: '', airlineItinerary: '' };
    }

    const flightParts: string[] = [];
    for (let i = 0; i < itineraryList.length; i++) {
        const leg = itineraryList[i];
        const orig = (leg.origin || leg.origen || '').trim().toUpperCase();
        const dest = (leg.destination || leg.destino || '').trim().toUpperCase();

        if (i === 0) {
            if (orig) flightParts.push(orig);
            if (dest) flightParts.push(dest);
        } else {
            const prevDest = flightParts[flightParts.length - 1] || '';
            if (orig && orig !== prevDest) {
                flightParts.push(orig);
            }
            if (dest) {
                flightParts.push(dest);
            }
        }
    }

    const classList = itineraryList
        .map((leg: any) => (leg.class || leg.clase || '').trim().toUpperCase())
        .filter(Boolean);

    const airlineList = itineraryList
        .map((leg: any) => (leg.prestadoraCode || leg.aero || leg.provider || leg.airline || '').trim().toUpperCase())
        .filter(Boolean);

    return {
        flightItinerary: flightParts.join('/'),
        classItinerary: classList.join('/'),
        airlineItinerary: airlineList.join('/')
    };
}

export default function InvoiceForm({ invoiceId, quotationId, initialData, onCancel }: { invoiceId?: string; quotationId?: string; initialData?: any; onCancel?: () => void }) {
    const router = useRouter()
    const isReadOnly = Boolean(invoiceId)
    const [invoiceNumberDisplay, setInvoiceNumberDisplay] = useState<string>('')
    const [resolutionModalOpen, setResolutionModalOpen] = useState(false)
    const [activeResolutionInfo, setActiveResolutionInfo] = useState<any>(null)
    const [loadingResolution, setLoadingResolution] = useState(false)
    const [data, setData] = useState<any>(null)
    const [formData, setFormData] = useState<InvoiceFormData>({
        clientId: '',
        branchId: '',
        implantId: '',
        currency: 'USD',
        exchangeRate: 1,
        sellerId: '',
        ticketPrinterId: '',
        commissionPercentage: 10,
        chargesAndTaxes: 0,
        items: [],
        selectedCombos: [],
        state: 'Nuevo',
        fuente: '',
        serie: '',
        consecutivo: '',
        date: new Date().toISOString().split('T')[0],
        dueDate: new Date().toISOString().split('T')[0]
    })
    const [saving, setSaving] = useState(false)
    const [isGlobalPaymentOpen, setIsGlobalPaymentOpen] = useState(false)
    const [isSearchBookingOpen, setIsSearchBookingOpen] = useState(false)
    const [attachments, setAttachments] = useState<any[]>([])
    const [uploadingAttachment, setUploadingAttachment] = useState(false)
    const [openItineraries, setOpenItineraries] = useState<Record<number, boolean>>({})

    const updateItineraryListAndSummaries = (itemIndex: number, list: any[]) => {
        const summaries = computeItinerarySummaries(list);
        setFormData(prev => {
            const newItems = [...prev.items];
            const cur = newItems[itemIndex];
            newItems[itemIndex] = {
                ...cur,
                itinerariesItineraryList: list,
                itinerary: list.length > 0 ? summaries.flightItinerary : cur.itinerary,
                class: list.length > 0 ? summaries.classItinerary : cur.class,
                airline: list.length > 0 ? summaries.airlineItinerary : cur.airline,
            };
            return { ...prev, items: newItems };
        });
    };

    const handleImportBooking = (booking: any) => {
        if (!booking) return;

        // 1. Matchear Cliente por código/nombre/documento/id
        let matchedClientId = '';
        if (booking.client) {
            const searchClient = booking.client.toString().trim().toLowerCase();
            const foundClient = data?.clients?.find((c: any) => 
                c.id?.toString() === booking.client?.toString() ||
                c.document?.toString().toLowerCase() === searchClient ||
                c.code?.toString().toLowerCase() === searchClient ||
                c.name?.toLowerCase()?.includes(searchClient)
            );
            if (foundClient) matchedClientId = foundClient.id.toString();
        }

        // 2. Matchear Vendedor
        let matchedSellerId = '';
        if (booking.seller) {
            const searchSeller = booking.seller.toString().trim().toLowerCase();
            const foundSeller = data?.sellers?.find((s: any) => 
                s.id?.toString() === booking.seller?.toString() ||
                s.code?.toString().trim().toLowerCase() === searchSeller ||
                s.name?.toLowerCase()?.includes(searchSeller)
            );
            if (foundSeller) matchedSellerId = foundSeller.id.toString();
        }
        if (!matchedSellerId && matchedClientId) {
            const foundClient = data?.clients?.find((c: any) => c.id?.toString() === matchedClientId);
            if (foundClient?.sellerId) {
                matchedSellerId = foundClient.sellerId.toString();
            }
        }

        // 3. Matchear Tiqueteador
        let matchedTicketPrinterId = '';
        if (booking.tiquetPrinter) {
            const searchTP = booking.tiquetPrinter.toString().trim().toLowerCase();
            const foundTP = data?.ticketPrinters?.find((tp: any) => 
                tp.id?.toString() === booking.tiquetPrinter?.toString() ||
                tp.code?.toString().trim().toLowerCase() === searchTP ||
                tp.name?.toLowerCase()?.includes(searchTP)
            );
            if (foundTP) matchedTicketPrinterId = foundTP.id.toString();
        }

        // 4. Matchear Sucursal e Implant
        let matchedBranchId = '';
        if (booking.blanch) {
            const searchBranch = booking.blanch.toString().trim().toLowerCase();
            const foundBranch = data?.branches?.find((b: any) => 
                b.id?.toString() === booking.blanch?.toString() ||
                b.code?.toString().trim().toLowerCase() === searchBranch ||
                b.name?.toLowerCase()?.includes(searchBranch)
            );
            if (foundBranch) matchedBranchId = foundBranch.id.toString();
        }

        let matchedImplantId = '';
        if (booking.implant) {
            const searchImplant = booking.implant.toString().trim().toLowerCase();
            const foundImplant = data?.implants?.find((imp: any) => 
                imp.id?.toString() === booking.implant?.toString() ||
                imp.code?.toString().trim().toLowerCase() === searchImplant ||
                imp.name?.toLowerCase()?.includes(searchImplant)
            );
            if (foundImplant) matchedImplantId = foundImplant.id.toString();
        }

        // 5. Determinar Producto por Defecto (por Parámetro o fallback a Tiquetes/Aéreo)
        const gdsParam = data?.parameters?.find((pm: any) => 
            pm.code === 'PRODUCTO_RESERVA_GDS' || pm.code === 'DEFAULT_GDS_PRODUCT_ID'
        );
        let configuredGdsProduct = null;
        if (gdsParam && gdsParam.value) {
            const cleanVal = gdsParam.value.toString().trim().toUpperCase();
            configuredGdsProduct = data?.products?.find((p: any) => 
                p.id?.toString() === cleanVal || 
                p.code?.toString().trim().toUpperCase() === cleanVal ||
                p.billingConcept?.toString().trim().toUpperCase() === cleanVal ||
                p.description?.toString().trim().toUpperCase() === cleanVal
            );
        }
        const defaultProduct = configuredGdsProduct || data?.products?.find((p: any) => 
            p.type === 'flight' || 
            p.serviceType === 'flight' || 
            p.code?.toUpperCase() === 'TIQUETE' || 
            p.code?.toUpperCase() === 'TIQUETES' ||
            p.code?.toUpperCase() === 'TAN' ||
            p.description?.toUpperCase().includes('TIQUETE') || 
            p.description?.toUpperCase().includes('AEREO')
        ) || data?.products?.[0];

        // 6. Mapear Productos
        const importedItems = (booking.items || []).map((bkItem: any) => {
            // Asignación de Proveedor STRICTAMENTE por Código de Aerolínea / Sigla / Código de Proveedor (NUNCA por nombre)
            let matchedProviderId = '';
            const siglaKey = (bkItem.prestadoracode || '').trim().toUpperCase();
            const providerCodeKey = (bkItem.provider || '').trim().toUpperCase();
            const allProviders = data?.providers || [];

            // 1. Búsqueda por Sigla, Código IATA de Aerolínea ('AV', '134', 'TK') o Código de Proveedor
            if (siglaKey) {
                const provBySigla = allProviders.find((pv: any) => 
                    pv.sigla?.trim().toUpperCase() === siglaKey ||
                    pv.airlineCode?.trim().toUpperCase() === siglaKey ||
                    pv.code?.trim().toUpperCase() === siglaKey
                );
                if (provBySigla) {
                    matchedProviderId = provBySigla.id.toString();
                }
            }

            // 2. Búsqueda por Código de Proveedor ('890100577', '134')
            if (!matchedProviderId && providerCodeKey) {
                const provByCode = allProviders.find((pv: any) => 
                    pv.code?.trim().toUpperCase() === providerCodeKey ||
                    pv.sigla?.trim().toUpperCase() === providerCodeKey ||
                    pv.airlineCode?.trim().toUpperCase() === providerCodeKey
                );
                if (provByCode) {
                    matchedProviderId = provByCode.id.toString();
                }
            }

            // REGLA: Si no encuentra el código de la aerolínea en el maestro, matchedProviderId queda vacío ('')
            // para que la interfaz muestre despejado ("Sel. Proveedor") e indique al usuario que falta por configurar.

            let matchedPrestadoraId = '';
            if (bkItem.prestadoracode) {
                const searchKey = bkItem.prestadoracode.trim().toUpperCase();
                const foundPrest = data?.prestadoras?.find((pr: any) => 
                    pr.code?.trim().toUpperCase() === searchKey
                );
                if (foundPrest) matchedPrestadoraId = foundPrest.id.toString();
            }

            // DESGLOSE DE IMPUESTOS Y TARIFA BASE
            const totalTicketAmount = Number(bkItem.price || 0);
            const masterTaxes = data?.taxes || [];
            const otrTaxMaster = masterTaxes.find((t: any) => t.code === 'OTR');
            const tarTaxMaster = masterTaxes.find((t: any) => t.code === 'TAR');

            let nonTarTaxTotal = 0;
            const taxGroupedMap = new Map<number, { id: number; chargeAndTaxId: number; name: string; amount: number }>();

            (bkItem.appliedTaxes || []).forEach((bkTax: any) => {
                const code = (bkTax.code || '').trim().toUpperCase();
                const amount = Number(bkTax.amount || 0);

                if (code === 'TAR') return; // Se calculará como tarifa neta

                nonTarTaxTotal += amount;

                const matchedTax = masterTaxes.find((st: any) => {
                    if (st.code?.toUpperCase() === code) return true;
                    if (st.gdsEquivalences) {
                        const eqList = st.gdsEquivalences.split(',').map((e: string) => e.trim().toUpperCase());
                        return eqList.includes(code);
                    }
                    return false;
                });

                const targetTaxMaster = matchedTax || otrTaxMaster;

                if (targetTaxMaster) {
                    const taxId = Number(targetTaxMaster.id);
                    if (taxGroupedMap.has(taxId)) {
                        const existing = taxGroupedMap.get(taxId)!;
                        existing.amount += amount;
                    } else {
                        taxGroupedMap.set(taxId, {
                            id: taxId,
                            chargeAndTaxId: taxId,
                            name: targetTaxMaster.name,
                            amount: amount
                        });
                    }
                }
            });

            // Tarifa Base Neta = Precio Total del Tiquete - Suma de Impuestos (No TAR)
            const netBaseFare = Math.max(0, totalTicketAmount - nonTarTaxTotal);

            let mainTaxId: number | undefined = undefined;
            if (tarTaxMaster) {
                const tarId = Number(tarTaxMaster.id);
                mainTaxId = tarId;
                taxGroupedMap.set(tarId, {
                    id: tarId,
                    chargeAndTaxId: tarId,
                    name: tarTaxMaster.name,
                    amount: netBaseFare
                });
            }

            const appliedTaxes = Array.from(taxGroupedMap.values());

            // ITINERARIO Y FECHA INICIAL / FINAL
            let initialDate = '';
            let finalDate = '';
            const itineraryList = Array.isArray(bkItem.itinerary) ? bkItem.itinerary : [];

            if (itineraryList.length > 0) {
                const sortedItinerary = [...itineraryList].sort((a: any, b: any) => (a.orden || 0) - (b.orden || 0));
                const firstLeg = sortedItinerary[0];
                const lastLeg = sortedItinerary[sortedItinerary.length - 1];

                if (firstLeg.checkInDate) {
                    initialDate = format(new Date(firstLeg.checkInDate), 'yyyy-MM-dd');
                }
                if (lastLeg.checkOutDate || lastLeg.checkInDate) {
                    const rawDate = lastLeg.checkOutDate || lastLeg.checkInDate;
                    finalDate = format(new Date(rawDate), 'yyyy-MM-dd');
                }
            }

            if (!initialDate && bkItem.checkInDate) {
                initialDate = format(new Date(bkItem.checkInDate), 'yyyy-MM-dd');
            }
            if (!finalDate && bkItem.checkOutDate) {
                finalDate = format(new Date(bkItem.checkOutDate), 'yyyy-MM-dd');
            }

            const importedPayments = (bkItem.payments || []).map((pay: any) => {
                const isCreditCard = (pay.code || '').toUpperCase().startsWith('CC') || 
                                     (pay.code || '').toUpperCase().startsWith('FPCC') || 
                                     (pay.code || '').toUpperCase() === 'TC' ||
                                     Boolean(pay.numbercreditcard || pay.cardNumber);

                const matchedPayMethod = data?.payments?.find((pm: any) => 
                    pm.code?.toUpperCase() === pay.code?.toUpperCase() ||
                    (isCreditCard && (pm.code?.toUpperCase() === 'TC' || pm.code?.toUpperCase() === 'CC' || pm.name?.toLowerCase().includes('tarjeta'))) ||
                    (pay.name && pm.name?.toLowerCase()?.includes(pay.name?.toLowerCase()))
                ) || (isCreditCard ? (data?.payments?.find((pm: any) => pm.name?.toLowerCase().includes('tarjeta')) || { name: 'Tarjeta de Crédito', code: 'CC' }) : data?.payments?.[0]);

                const fullRefStr = (pay.numbercreditcard || pay.cardNumber || pay.reference || '').toString().trim();
                const cardParseResult = parseAndValidateCreditCard(fullRefStr, data?.creditCards || []);
                let matchedCreditCardId = cardParseResult.matchedCard?.id;

                if (!matchedCreditCardId) {
                    const rawCardType = (pay.typecreditcard || pay.typeCreditCard || fullRefStr.substring(0, 2) || '').toString().trim().toUpperCase();
                    if (rawCardType && data?.creditCards) {
                        const foundCard = data.creditCards.find((c: any) => 
                            c.code?.toUpperCase() === rawCardType ||
                            c.name?.toUpperCase()?.includes(rawCardType) ||
                            (rawCardType === 'VI' && c.name?.toUpperCase()?.includes('VISA')) ||
                            (rawCardType === 'MC' && c.name?.toUpperCase()?.includes('MASTER'))
                        );
                        if (foundCard) matchedCreditCardId = Number(foundCard.id);
                    }
                }

                return {
                    amount: Number(pay.amount || 0),
                    paymentMethod: matchedPayMethod?.name || (isCreditCard ? 'Tarjeta de Crédito' : 'Efectivo'),
                    date: format(new Date(), 'yyyy-MM-dd'),
                    reference: fullRefStr || pay.authcreditcard || pay.vouchercreditcard || '',
                    authorizationCode: pay.authcreditcard || pay.authorizationCode || '',
                    voucher: pay.vouchercreditcard || pay.voucher || '',
                    cardNumber: cardParseResult.cardNumber || pay.numbercreditcard || pay.cardNumber || '',
                    expirationDate: pay.expiredcreditcard || pay.expirationDate || '',
                    creditCardId: matchedCreditCardId
                };

            });

            const COLOMBIAN_AIRPORTS = new Set([
                'BOG', 'MDE', 'EOH', 'CLO', 'CTG', 'BGA', 'CUC', 'PEI', 'MTR', 'SMR', 
                'BAQ', 'VUP', 'NVA', 'AYO', 'VVC', 'PSO', 'AXM', 'RCH', 'FLA', 'UIZ', 
                'MZL', 'ADZ', 'EYP', 'APO', 'IBE', 'GPI', 'TCO', 'PJA', 'PUU', 'NQU', 
                'PCR', 'RAV', 'SVI', 'TME', 'VGZ', 'AUC', 'OBC', 'IPI', 'CVI', 'CAQ', 
                'PDA', 'LQM', 'MMP', 'PVP', 'MVP', 'LPD', 'SJH', 'MCJ', 'MQU', 'SNN', 
                'ORC', 'TBD', 'LCR', 'KGC', 'TLU', 'ULQ', 'ACD', 'PBE', 'BCG', 'MFS', 
                'SOC', 'RON', 'BSJ', 'HTZ', 'PZA', 'PAL', 'ARQ', 'TRB', 'MHD', 'CPS', 
                'TQS', 'NOC', 'CUA', 'NKG', 'PACO', 'PVA'
            ]);

            const calcNationality = (): number => {
                if (bkItem.inNationality != null) return Number(bkItem.inNationality);
                if (bkItem.nacionalidad != null) {
                    const nacStr = bkItem.nacionalidad.toString().toLowerCase();
                    if (nacStr.includes('internac') || nacStr === '2') return 2;
                    if (nacStr.includes('nac') || nacStr === '1') return 1;
                }
                if (Array.isArray(itineraryList) && itineraryList.length > 0) {
                    for (const leg of itineraryList) {
                        const orig = (leg.origin || leg.origen || '').trim().toUpperCase();
                        const dest = (leg.destination || leg.destino || '').trim().toUpperCase();
                        if (orig && !COLOMBIAN_AIRPORTS.has(orig)) return 2;
                        if (dest && !COLOMBIAN_AIRPORTS.has(dest)) return 2;
                    }
                    return 1;
                }
                const destText = (bkItem.destination || bkItem.destino || '').trim().toUpperCase();
                if (destText) {
                    const codes = destText.split(/[\s\/,\-]+/);
                    for (const code of codes) {
                        if (code.length === 3 && /^[A-Z]{3}$/.test(code)) {
                            if (!COLOMBIAN_AIRPORTS.has(code)) return 2;
                        }
                    }
                }
                return 1;
            };

            const summaries = computeItinerarySummaries(itineraryList);

            const importedVariables: { id?: number, masterVariableId: number, value: string }[] = [];
            if (Array.isArray(bkItem.variables)) {
                for (const v of bkItem.variables) {
                    const matchedMaster = data?.variables?.find((mv: any) =>
                        (mv.id && v.masterVariableId && mv.id == v.masterVariableId) ||
                        (mv.code && v.code && mv.code.toString().toLowerCase() === v.code.toString().toLowerCase()) ||
                        (mv.name && v.name && mv.name.toString().toLowerCase() === v.name.toString().toLowerCase())
                    );
                    if (matchedMaster && v.value) {
                        importedVariables.push({
                            masterVariableId: matchedMaster.id,
                            value: String(v.value)
                        });
                    }
                }
            }

            return {
                bookingProductId: bkItem.id,
                productId: defaultProduct?.id?.toString() || '',
                quantity: bkItem.quantity || 1,
                price: netBaseFare,
                cost: Number(bkItem.cost || 0),
                providerId: matchedProviderId,
                prestadoraId: matchedPrestadoraId,
                reservationCode: bkItem.reservationCode || booking.code || '',
                ticketCode: bkItem.code || bkItem.ticketCode || bkItem.ticketNumber || '',
                serviceType: 'Tiquete',
                descripcion: bkItem.description || bkItem.service || 'flight',
                checkIn: initialDate,
                checkOut: finalDate,
                paxAdults: bkItem.paxAdults || 1,
                paxChildren: bkItem.paxChildren || 0,
                destination: bkItem.destination || '',
                passengers: (bkItem.passengers || []).map((px: any) => ({
                    name: px.name || '',
                    document: px.document || ''
                })),
                mainTaxId,
                appliedTaxes,
                payments: importedPayments,
                itinerariesItineraryList: itineraryList,
                itinerary: summaries.flightItinerary,
                class: summaries.classItinerary,
                airline: summaries.airlineItinerary,
                sellerCommission: 0,
                ticketPrinterCommission: 0,
                variables: importedVariables,
                inNationality: calcNationality(),
                _productName: defaultProduct?.description
            };
        });

        setFormData(prev => ({
            ...prev,
            clientId: matchedClientId || prev.clientId,
            sellerId: matchedSellerId || prev.sellerId,
            ticketPrinterId: matchedTicketPrinterId || prev.ticketPrinterId,
            branchId: matchedBranchId || prev.branchId,
            implantId: matchedImplantId || prev.implantId,
            currency: booking.currency || prev.currency,
            exchangeRate: booking.exchangeRate || prev.exchangeRate,
            items: [...prev.items, ...importedItems]
        }));

        setIsSearchBookingOpen(false);
    };

    const activeCurrency = data?.currencies?.find((c: any) => c.code === formData.currency);
    const decimals = activeCurrency ? (activeCurrency.decimals ?? 2) : 2;

    
    const getItemTotal = (item: any) => {
        const base = (item.price * item.quantity) || 0;
        const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : null;
        const secondaryTaxes = (item.appliedTaxes || [])
            .filter((t: any) => {
                const rawTaxId = t.id ?? t.chargeAndTaxId;
                const taxId = rawTaxId != null ? Number(rawTaxId) : null;
                return taxId !== mainTaxIdNum;
            })
            .reduce((acc: number, t: any) => acc + (t.amount || 0), 0);
        return base + secondaryTaxes;
    };

    const applyGlobalPayment = (amount: number, method: string, date: string, reference: string) => {
        let remaining = amount;
        const newItems = [...formData.items];
        for (let i = 0; i < newItems.length; i++) {
            if (remaining <= 0) break;
            const itemTotal = getItemTotal(newItems[i]);
            
            let paymentAmount = itemTotal;
            if (remaining < itemTotal) {
                paymentAmount = remaining;
            }
            if (!newItems[i].payments) newItems[i].payments = [];
            newItems[i].payments!.push({ amount: paymentAmount, paymentMethod: method, date, reference });
            remaining -= paymentAmount;
        }
        setFormData({ ...formData, items: newItems });
        alert('Pago global distribuido con éxito.');
    };

    const handleSave = async (e: React.FormEvent, downloadPdf = false) => {
        e.preventDefault();
        // Synchronously open a blank window if printing, to bypass browser popup blockers
        const printWindow = downloadPdf ? window.open('about:blank', '_blank') : null;
        setSaving(true)
        try {
            const payload = {
                ...formData,
                clientId: formData.clientId || null,
                branchId: formData.branchId || null,
                implantId: formData.implantId || null,
                sellerId: formData.sellerId || null,
                ticketPrinterId: formData.ticketPrinterId || null,
                totalAmount: total,
                combos: (formData.selectedCombos || []).map(c => ({ comboId: c.id })),
                items: formData.items.map(item => {
                    const taxes: any[] = [];

                    // Add main tax if exists
                    if (item.mainTaxId) {
                        const amount = item.price * item.quantity;
                        taxes.push({ chargeAndTaxId: item.mainTaxId, explicitAmount: amount });
                    }

                    // Add secondary taxes
                    (item.appliedTaxes || []).forEach(t => {
                        const taxId = t.id || (t as any).chargeAndTaxId;
                        if (taxId && taxId !== item.mainTaxId) {
                            taxes.push({ chargeAndTaxId: taxId, explicitAmount: t.amount });
                        }
                    });

                    return {
                        ...item,
                        productId: item.productId || null,
                        providerId: item.providerId || null,
                        prestadoraId: item.prestadoraId || null,
                        ticketCode: item.ticketCode || null,
                        ticketTypeId: item.ticketTypeId || null,
                        serviceType: item.serviceType || null,
                        descripcion: item.descripcion || null,
                        cost: item.cost || 0,
                        appliedTaxes: taxes,
                        variables: item.variables || []
                    };
                })
            }

            const endpoint = invoiceId ? `/api/invoices/${invoiceId}` : '/api/invoices';
            const method = invoiceId ? 'PUT' : 'POST';
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
            console.log("PAYLOAD BEING SENT TO SERVER:", JSON.stringify(payload, null, 2));

            const res = await fetch(endpoint, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: JSON.stringify(payload)
            })

            const result = await res.json()
            if (!res.ok) throw new Error(result.message || 'Error al guardar')

            if (downloadPdf && printWindow) {
                try {
                    const targetId = result.invoice?.id || invoiceId;
                    if (targetId) {
                        printWindow.location.href = `/dashboard/invoices/print?idIni=${targetId}&idFin=${targetId}`;
                    } else {
                        printWindow.close();
                    }
                } catch (printErr) {
                    console.error('Error opening print page:', printErr);
                    printWindow.close();
                }
            } else {
                if (printWindow) printWindow.close();
                const successMessage = result.message || 'Facturación guardada exitosamente';
                alert(successMessage);
            }

            router.push('/dashboard')
        } catch (err: any) {
            if (printWindow) {
                try { printWindow.close(); } catch (e) {}
            }
            console.error(err)
            alert(err.message || 'Ocurrió un error al guardar la facturación')
        } finally {
            setSaving(false)
        }
    }

    const fetchAttachments = async () => {
        if (!invoiceId) return
        try {
            const res = await fetch(`/api/invoices/${invoiceId}/attachments`)
            if (res.ok) {
                const data = await res.json()
                setAttachments(data)
            }
        } catch (err) {
            console.error("Error fetching attachments:", err)
        }
    }

    const handleUploadAttachment = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file || !invoiceId) return

        setUploadingAttachment(true)
        try {
            const reader = new FileReader()
            reader.readAsDataURL(file)
            reader.onload = async () => {
                const base64 = reader.result as string
                const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
                const res = await fetch(`/api/invoices/${invoiceId}/attachments`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-User-Id': loggedUser.id?.toString() || ''
                    },
                    body: JSON.stringify({
                        fileName: file.name,
                        fileType: file.type,
                        fileSize: file.size,
                        fileUrl: base64
                    })
                })

                if (res.ok) {
                    fetchAttachments()
                } else {
                    const result = await res.json()
                    alert(result.message || 'Error al cargar adjunto')
                }
            }
        } catch (err) {
            console.error(err)
            alert('Error al procesar el archivo')
        } finally {
            setUploadingAttachment(false)
            e.target.value = ''
        }
    }

    const handleDeleteAttachment = async (id: number) => {
        if (!confirm('¿Estás seguro de eliminar este adjunto?')) return
        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
        try {
            const res = await fetch(`/api/invoices/${invoiceId}/attachments?attachmentId=${id}`, {
                method: 'DELETE',
                headers: {
                    'X-User-Id': loggedUser.id?.toString() || ''
                }
            })
            if (res.ok) {
                fetchAttachments()
            }
        } catch (err) {
            console.error(err)
            alert('Error al eliminar adjunto')
        }
    }

    const handleDownloadAttachment = (attachment: any) => {
        const link = document.createElement('a')
        link.href = attachment.fileUrl
        link.download = attachment.fileName
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }

    // Get unique taxes that have been applied anywhere, putting Tarifa first and respecting master order
    const sortedTaxSummaryList = React.useMemo(() => {
        const map = new Map<string, { id: number; code: string; name: string; orden: number; amount: number }>();
        if (!data?.taxes) return [];

        formData.items.forEach(item => {
            (item.appliedTaxes || []).forEach(tax => {
                const rawTaxId = (tax as any).id ?? (tax as any).chargeAndTaxId;
                const taxId = rawTaxId != null ? Number(rawTaxId) : null;
                let master = data.taxes.find((t: any) => Number(t.id) === taxId);

                if (master && master.targetTaxId) {
                    const targetMaster = data.taxes.find((t: any) => Number(t.id) === Number(master.targetTaxId));
                    if (targetMaster) {
                        master = targetMaster;
                    }
                }

                const key = master ? master.name : ((tax as any).name || 'Otros');
                const code = master ? (master.code || '') : ((tax as any).code || '');
                const orden = master && master.orden != null ? Number(master.orden) : 9999;
                const id = master ? Number(master.id) : 9999;

                if (!map.has(key)) {
                    map.set(key, { id, code, name: key, orden, amount: 0 });
                }
                const curr = map.get(key)!;
                curr.amount += Number(tax.amount || 0);
            });
        });

        const list = Array.from(map.values());
        list.sort((a, b) => {
            const isTarA = a.code === 'TAR' || a.name.toUpperCase().includes('TARIFA');
            const isTarB = b.code === 'TAR' || b.name.toUpperCase().includes('TARIFA');
            if (isTarA && !isTarB) return -1;
            if (!isTarA && isTarB) return 1;
            if (a.orden !== b.orden) return a.orden - b.orden;
            return a.id - b.id;
        });

        return list;
    }, [formData.items, data?.taxes]);

    const total = sortedTaxSummaryList.reduce((sum, item) => sum + item.amount, 0);

    const handleCalculateTaxes = (index: number) => {
        const item = formData.items[index];
        if (!item.mainTaxId || item.price <= 0) {
            alert("Selecciona un Cargo Principal y escribe su valor primero antes de calcular.");
            return;
        }
        const baseValue = item.price * item.quantity;
        const newAppliedTaxes = item.appliedTaxes.map((taxApp: any) => {
            const rawTaxId = taxApp.id ?? taxApp.chargeAndTaxId;
            const taxId = rawTaxId != null ? Number(rawTaxId) : null;
            const taxMaster = data.taxes.find((t: any) => Number(t.id) === taxId);
            if (taxMaster && taxMaster.valueType === 'PERCENTAGE') {
                return { ...taxApp, amount: parseFloat(((baseValue * taxMaster.value) / 100).toFixed(decimals)) };
            }
            return taxApp;
        });
        updateItem(index, 'appliedTaxes', newAppliedTaxes);
    }

    useEffect(() => {
        const loadInitialData = async () => {
            try {
                const loggedUserCache = JSON.parse(localStorage.getItem('user') || '{}');
                const baseRes = await fetch('/api/invoices/base-data', {
                    headers: { 'X-User-Id': loggedUserCache.id?.toString() || '' }
                })
                const baseData = await baseRes.json()
                if (baseRes.ok && baseData?.clients) {
                    setData(baseData)
                } else {
                    console.error("No valid data received from base-data:", baseData)
                    setData({ clients: [], providers: [], prestadoras: [], branches: [], implants: [], products: [], taxes: [], sellers: [], ticketPrinters: [], variables: [], combos: [], currencies: [], creditCards: [], payments: [], ticketTypes: [] })
                }

                if (!invoiceId && (initialData || quotationId)) {
                    let qData = initialData;
                    if (!qData && quotationId) {
                        try {
                            const quoRes = await fetch(`/api/quotations/${quotationId}/fn-cotizacion`)
                            if (quoRes.ok) {
                                qData = await quoRes.json()
                            }
                        } catch (err) {
                            console.error("Error fetching fnCotizacion for invoice:", err)
                        }
                    }

                    if (qData) {
                        setFormData({
                            clientId: qData.clientId?.toString() || '',
                            branchId: qData.branchId?.toString() || '',
                            implantId: qData.implantId?.toString() || '',
                            currency: qData.currency || 'USD',
                            exchangeRate: qData.exchangeRate || 1,
                            sellerId: qData.sellerId?.toString() || '',
                            ticketPrinterId: qData.ticketPrinterId?.toString() || '',
                            commissionPercentage: qData.commissionPercentage || 0,
                            chargesAndTaxes: qData.chargesAndTaxes || 0,
                            state: 'Nuevo',
                            fuente: '',
                            serie: '',
                            consecutivo: '',
                            selectedCombos: (qData.combos || []).map((c: any) => ({ id: c.comboId || c.id, name: c.name })),
                            items: (qData.products || []).map((p: any) => {
                                const safeAppliedTaxes = Array.isArray(p.appliedTaxes) ? p.appliedTaxes.map((t: any) => ({
                                    id: t.id ?? t.chargeAndTaxId,
                                    chargeAndTaxId: t.id ?? t.chargeAndTaxId,
                                    amount: t.explicitAmount ?? t.amount ?? 0
                                })) : [];

                                return {
                                    productId: p.productId?.toString() || '',
                                    ticketCode: p.ticketCode || (Array.isArray(p.passengers) && p.passengers[0]?.document ? p.passengers[0].document : ''),
                                    ticketTypeId: p.ticketTypeId || '',
                                    quantity: p.quantity || 1,
                                    price: p.price || 0,
                                    cost: p.cost || 0,
                                    providerId: p.providerId?.toString() || '',
                                    prestadoraId: p.prestadoraId?.toString() || '',
                                    checkIn: p.checkInDate ? new Date(p.checkInDate).toISOString().split('T')[0] : '',
                                    checkOut: p.checkOutDate ? new Date(p.checkOutDate).toISOString().split('T')[0] : '',
                                    paxAdults: p.paxAdults || 1,
                                    paxChildren: p.paxChildren || 0,
                                    destination: p.destination || '',
                                    serviceType: p.serviceType || '',
                                    reservationCode: p.reservationCode || '',
                                    servicios: p.servicios || p.service || '',
                                    descripcion: p.descripcion || '',
                                    passengers: Array.isArray(p.passengers) ? p.passengers : [],
                                    sellerCommission: p.sellerCommission || 0,
                                    ticketPrinterCommission: p.ticketPrinterCommission || 0,
                                    mainTaxId: p.mainTaxId,
                                    inNationality: p.inNationality || 1,
                                    appliedTaxes: safeAppliedTaxes,
                                    variables: Array.isArray(p.variables) ? p.variables : [],
                                    payments: Array.isArray(p.payments) ? p.payments : [],
                                    comboId: p.comboId,
                                    _productName: p.product?.description,
                                    _providerName: p.provider?.name,
                                    _prestadoraName: p.prestadora?.name
                                };
                            })
                        });
                    }
                } else if (!invoiceId) {
                    try {
                        const defaultUser = baseData?.currentUser || loggedUserCache;
                        setFormData((prev: any) => ({
                            ...prev,
                            branchId: defaultUser.branchId?.toString() || '',
                            implantId: defaultUser.implantId?.toString() || '',
                            ticketPrinterId: defaultUser.ticketPrinterId?.toString() || ''
                        }));
                    } catch (e) {
                        // Ignore parse error
                    }
                }

                if (invoiceId) {
                    fetchAttachments()
                    const qRes = await fetch(`/api/invoices/${invoiceId}`)
                    if (qRes.ok) {
                        const qData = await qRes.json()
                        const formattedNum = qData.internalNumber || (qData.serie && qData.consecutivo ? `${qData.serie}-${qData.consecutivo}` : qData.consecutivo) || `#${invoiceId}`;
                        setInvoiceNumberDisplay(formattedNum);
                        setFormData({
                            clientId: qData.clientId?.toString() || '',
                            branchId: qData.branchId?.toString() || '',
                            implantId: qData.implantId?.toString() || '',
                            currency: qData.currency || 'USD',
                            exchangeRate: qData.exchangeRate,
                            sellerId: qData.sellerId?.toString() || '',
                            ticketPrinterId: qData.ticketPrinterId?.toString() || '',
                            commissionPercentage: qData.commissionPercentage || 0,
                            chargesAndTaxes: qData.chargesAndTaxes || 0,
                            state: qData.state || 'Nuevo',
                            fuente: qData.fuente || '',
                            serie: qData.serie || '',
                            consecutivo: qData.consecutivo || '',
                            date: qData.date ? new Date(qData.date).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
                            dueDate: qData.dueDate ? new Date(qData.dueDate).toISOString().split('T')[0] : (qData.date ? new Date(qData.date).toISOString().split('T')[0] : new Date().toISOString().split('T')[0]),
                            items: (qData.products || []).map((p: any) => {
                                const safeAppliedTaxes = Array.isArray(p.appliedTaxes) ? p.appliedTaxes : [];
                                const safeVariables = Array.isArray(p.variables) ? p.variables : [];

                                const mainTaxId = p.mainTaxId;

                                // Inferir el precio desde el monto del cargo principal guardado
                                const mainTaxEntry = safeAppliedTaxes.find((t: any) => t.chargeAndTaxId === mainTaxId);
                                let inferredPrice = p.price;
                                if (mainTaxEntry && mainTaxEntry.explicitAmount != null) {
                                    inferredPrice = mainTaxEntry.explicitAmount / (p.quantity || 1);
                                }

                                return {
                                    productId: p.productId?.toString() || '',
                                    ticketCode: p.ticketCode || (Array.isArray(p.passengers) && p.passengers[0]?.document ? p.passengers[0].document : ''),
                                    ticketTypeId: p.ticketTypeId || '',
                                    quantity: p.quantity,
                                    price: inferredPrice,
                                    cost: p.cost || 0,
                                    providerId: p.providerId?.toString() || '',
                                    prestadoraId: p.prestadoraId?.toString() || '',
                                    checkIn: p.checkInDate ? new Date(p.checkInDate).toISOString().split('T')[0] : '',
                                    checkOut: p.checkOutDate ? new Date(p.checkOutDate).toISOString().split('T')[0] : '',
                                    paxAdults: p.paxAdults || 1,
                                    paxChildren: p.paxChildren || 0,
                                    destination: p.destination || '',
                                    serviceType: p.serviceType || '',
                                    reservationCode: p.reservationCode || '',
                                    passengers: Array.isArray(p.passengers) ? p.passengers : [],
                                    sellerCommission: p.sellerCommission || 0,
                                    ticketPrinterCommission: p.ticketPrinterCommission || 0,
                                    mainTaxId,
                                    inNationality: p.inNationality || 1,
                                    itemDescription: p.itemDescription || '',
                                    servicios: p.servicios || '',
                                    itinerary: p.itinerary || '',
                                    class: p.class || '',
                                    airline: p.airline || '',
                                    itinerariesItineraryList: Array.isArray(p.itinerariesItineraryList) ? p.itinerariesItineraryList : [],
                                    payments: Array.isArray(p.payments) ? p.payments : [],
                                    // Info extra para renderizado si el maestro no carga a tiempo
                                    _productName: p.product?.description,
                                    _providerName: p.provider?.name,
                                    _prestadoraName: p.prestadora?.name,
                                    appliedTaxes: safeAppliedTaxes.map((t: any) => ({
                                        chargeAndTaxId: t.chargeAndTaxId,
                                        amount: t.explicitAmount ?? 0
                                    })),
                                    variables: safeVariables.map((v: any) => ({
                                        id: v.id,
                                        masterVariableId: v.masterVariableId,
                                        value: v.value
                                    }))
                                }
                            }) || [],
                            selectedCombos: qData.combos?.map((c: any) => ({ id: c.comboId, name: c.combo?.name })) || []
                        })
                    }
                }
            } catch (err) {
                console.error("Failed to load generic or invoice data", err);
                setData({ clients: [], providers: [], prestadoras: [], branches: [], implants: [], products: [], taxes: [], sellers: [], ticketPrinters: [], variables: [], combos: [], currencies: [], creditCards: [], payments: [], ticketTypes: [] })
            }
        }
        loadInitialData()
    }, [invoiceId])

    const addItem = () => {
        setFormData({
            ...formData,
            items: [...formData.items, {
                productId: '', quantity: 1, price: 0, cost: 0,
                providerId: '', prestadoraId: '', checkIn: '', checkOut: '',
                paxAdults: 1, paxChildren: 0, destination: '', serviceType: '', reservationCode: '', passengers: [{ name: '', document: '' }],
                sellerCommission: 0, ticketPrinterCommission: 0,
                appliedTaxes: [],
                variables: [],
                inNationality: 1
            }]
        })
    }

    const removeItem = (index: number) => {
        setFormData({
            ...formData,
            items: formData.items.filter((_, i) => i !== index)
        })
    }

    const addCombo = (comboId: number) => {
        const combo = data.combos.find((c: any) => c.id === comboId);
        if (!combo) return;

        // Prevent duplicate combos if needed, or just add products again
        const alreadyIn = formData.selectedCombos?.find(c => c.id === comboId);
        if (alreadyIn) {
            alert("Este combo ya ha sido agregado.");
            return;
        }

        const newItemsFromCombo = combo.products.map((cp: any) => {
            // Usar mainTaxId directamente desde el combo guardado en BD
            const mainTaxId: number | undefined = cp.mainTaxId || undefined;

            // Incluir TODOS los taxes en appliedTaxes (incluido el cargo principal)
            // igual a como funcionan los ítems creados manualmente
            const appliedTaxes = (cp.appliedTaxes || []).map((t: any) => ({
                id: t.chargeAndTaxId,
                amount: t.amount
            }));

            return {
                productId: cp.productId.toString(),
                quantity: 1,
                price: cp.price,
                cost: cp.product?.cost || 0,
                providerId: cp.providerId?.toString() || '',
                prestadoraId: cp.prestadoraId?.toString() || '',
                checkIn: cp.checkInDate ? new Date(cp.checkInDate).toISOString().split('T')[0] : '',
                checkOut: cp.checkOutDate ? new Date(cp.checkOutDate).toISOString().split('T')[0] : '',
                paxAdults: cp.paxAdults || 1,
                paxChildren: cp.paxChildren || 0,
                destination: '',
                serviceType: '',
                reservationCode: '',
                passengers: [],
                sellerCommission: 0,
                ticketPrinterCommission: 0,
                mainTaxId,
                appliedTaxes,
                variables: [],
                comboId: combo.id,
                inNationality: cp.inNationality || 1
            };
        });

        let newCurrency = formData.currency;
        let newExchangeRate = formData.exchangeRate;
        if (combo.currencyId && data.currencies) {
            const comboCurrency = data.currencies.find((c: any) => c.id === combo.currencyId);
            if (comboCurrency) {
                newCurrency = comboCurrency.code;
                newExchangeRate = comboCurrency.exchangeRate;
            }
        }

        setFormData({
            ...formData,
            currency: newCurrency,
            exchangeRate: newExchangeRate,
            items: [...formData.items, ...newItemsFromCombo],
            selectedCombos: [...(formData.selectedCombos || []), { id: combo.id, name: combo.name }]
        });
    }

    const removeCombo = (comboId: number) => {
        setFormData({
            ...formData,
            items: formData.items.filter(item => item.comboId !== comboId),
            selectedCombos: (formData.selectedCombos || []).filter(c => c.id !== comboId)
        });
    }

    const updateItem = (index: number, field: string, value: any) => {
        setFormData((prev) => {
            const newItems = [...prev.items];
            const oldItem = newItems[index];
            const newItem = { ...oldItem, [field]: value };

            // AUTO-RECALCULATE: Manejo de cambios en Cantidad, Precio o Cargo Principal
            if (field === 'quantity' || field === 'price' || field === 'mainTaxId') {
                const oldQty = oldItem.quantity || 1;
                const newQty = field === 'quantity' ? value : oldQty;
                const ratio = field === 'quantity' ? newQty / oldQty : 1;

                const baseValue = (field === 'price' ? value : (oldItem.price || 0)) * newQty;
                const mainTaxIdNum = field === 'mainTaxId' ? (value != null ? Number(value) : null) : (oldItem.mainTaxId != null ? Number(oldItem.mainTaxId) : null);

                newItem.appliedTaxes = (oldItem.appliedTaxes || []).map((t: any) => {
                    const rawTaxId = t.id ?? t.chargeAndTaxId;
                    const taxId = rawTaxId != null ? Number(rawTaxId) : null;

                    // 1. El Cargo principal siempre escala proporcionalmente al precio total
                    if (mainTaxIdNum != null && taxId === mainTaxIdNum) {
                        return { ...t, amount: baseValue };
                    }

                    // 2. Los impuestos porcentuales se recalculan sobre la nueva base (Precio Unitario * Cantidad)
                    const taxMaster = data?.taxes?.find((m: any) => Number(m.id) === taxId);
                    if (taxMaster && taxMaster.valueType === 'PERCENTAGE') {
                        return { ...t, amount: parseFloat(((baseValue * taxMaster.value) / 100).toFixed(decimals)) };
                    }

                    // 3. Otros cargos (fijos o manuales): 
                    // Si cambió la cantidad, escalan proporcionalmente (Ej: $10 -> $20 si duplicas)
                    if (field === 'quantity') {
                        return { ...t, amount: parseFloat((t.amount * ratio).toFixed(decimals)) };
                    }

                    return t;
                });
            }

            newItems[index] = newItem;
            return { ...prev, items: newItems };
        });
    }

    if (!data) return (
        <div className="flex items-center justify-center p-20">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-600"></div>
        </div>
    )

    return (
        <>
        <form onSubmit={handleSave} className="max-w-6xl mx-auto space-y-8 pb-20">
            <div className="flex items-center justify-between bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <div>
                    <h2 className="text-2xl font-bold dark:text-white flex items-center gap-3">
                        {invoiceId ? `Facturación ${invoiceNumberDisplay || (formData.serie && formData.consecutivo ? `${formData.serie}-${formData.consecutivo}` : formData.consecutivo || `#${invoiceId}`)}` : 'Generar Facturación'}
                    </h2>
                    <p className="text-zinc-500 text-sm mt-1">Completa los detalles para tu cliente</p>
                </div>
                <div className="flex gap-4 items-center">
                    {!isReadOnly && (
                        <button
                            type="button"
                            onClick={() => setIsSearchBookingOpen(true)}
                            className="px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-bold shadow-lg shadow-blue-500/20 transition-all flex items-center gap-2 cursor-pointer text-sm"
                        >
                            <Search className="w-5 h-5" />
                            Cargar desde Reserva / GDS
                        </button>
                    )}
                    {onCancel ? (
                        <button
                            type="button"
                            onClick={onCancel}
                            className="px-6 py-3 bg-zinc-200 dark:bg-zinc-800 hover:bg-zinc-300 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-200 rounded-xl font-bold transition-all flex items-center gap-2"
                        >
                            Atrás
                        </button>
                    ) : (
                        <button
                            type="button"
                            onClick={() => router.push('/dashboard/invoices')}
                            className="px-6 py-3 bg-zinc-100 text-zinc-700 rounded-xl font-bold hover:bg-zinc-200 transition-all"
                        >
                            Cancelar
                        </button>
                    )}
                    <button
                        type="button"
                        onClick={(e) => handleSave(e as any, true)}
                        disabled={saving}
                        className="px-6 py-3 bg-zinc-800 hover:bg-zinc-700 text-white rounded-xl font-bold shadow-lg transition-all flex items-center gap-2 disabled:opacity-50"
                        title="Imprimir Facturación"
                    >
                        <Printer className="w-5 h-5" />
                        Imprimir
                    </button>
                    {isReadOnly ? (
                        <div className="px-6 py-3 bg-amber-50 dark:bg-amber-950/40 text-amber-700 dark:text-amber-400 font-bold rounded-xl flex items-center gap-2 border border-amber-200 dark:border-amber-800/50 shadow-sm text-sm">
                            <Lock className="w-4 h-4 text-amber-500" /> Factura Guardada (Solo Lectura)
                        </div>
                    ) : (
                        <button
                            type="submit"
                            disabled={saving}
                            className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg shadow-blue-500/20 transition-all flex items-center gap-2 disabled:opacity-50"
                        >
                            {saving ? <Loader2 className="animate-spin w-5 h-5" /> : <Save className="w-5 h-5" />}
                            {saving ? 'Guardando...' : 'Guardar'}
                        </button>
                    )}
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Core Details */}
                <div className="lg:col-span-2 space-y-8">

                    {/* Section: Client & Origin */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                        <h3 className="text-lg font-bold mb-6 flex items-center gap-2 dark:text-white">
                            <Users className="w-5 h-5 text-blue-500" />
                            Cliente y Origen
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Cliente</label>
                                <SearchSelect
                                    options={data.clients}
                                    value={formData.clientId}
                                    onChange={async (val, opt) => {
                                        let selectedC = opt || data.clients?.find((c: any) => String(c.id) === String(val));
                                        if ((!selectedC || selectedC.creditDays === undefined || selectedC.sellerId === undefined) && val) {
                                            try {
                                                const res = await fetch(`/api/clients?id=${encodeURIComponent(val)}`);
                                                if (res.ok) {
                                                    const clientData = await res.json();
                                                    if (clientData && !clientData.message) {
                                                        selectedC = clientData;
                                                    }
                                                }
                                            } catch (err) {
                                                console.error("Error fetching client details:", err);
                                            }
                                        }
                                        const creditDays = Number(selectedC?.creditDays) || 0;
                                        const baseDate = formData.date || new Date().toISOString().split('T')[0];
                                        const d = new Date(baseDate + 'T00:00:00');
                                        d.setDate(d.getDate() + creditDays);
                                        const calculatedDueDate = d.toISOString().split('T')[0];
                                        const sellerIdToSet = selectedC?.sellerId ? String(selectedC.sellerId) : '';

                                        setFormData(prev => ({
                                            ...prev,
                                            clientId: val,
                                            sellerId: sellerIdToSet || prev.sellerId,
                                            date: baseDate,
                                            dueDate: calculatedDueDate
                                        }));
                                    }}
                                    disabled={isReadOnly}
                                    placeholder="Seleccionar Cliente"
                                    secondaryKey="document"
                                    remoteSearchEndpoint="/api/clients"
                                    minSearchLength={2}
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Vendedor</label>
                                <SearchSelect
                                    options={data.sellers || []}
                                    value={formData.sellerId}
                                    onChange={(val) => setFormData({ ...formData, sellerId: val })}
                                    disabled={isReadOnly}
                                    placeholder="Seleccionar Vendedor"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Fecha de Realización</label>
                                <input
                                    type="date"
                                    disabled={isReadOnly}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm font-medium dark:text-white disabled:opacity-60 disabled:cursor-not-allowed"
                                    value={formData.date || ''}
                                    onChange={(e) => {
                                        const newDateStr = e.target.value;
                                        const selectedC = data.clients?.find((c: any) => String(c.id) === String(formData.clientId));
                                        const creditDays = Number(selectedC?.creditDays) || 0;
                                        let calculatedDueDate = newDateStr;
                                        if (newDateStr) {
                                            const d = new Date(newDateStr + 'T00:00:00');
                                            d.setDate(d.getDate() + creditDays);
                                            calculatedDueDate = d.toISOString().split('T')[0];
                                        }
                                        setFormData(prev => ({
                                            ...prev,
                                            date: newDateStr,
                                            dueDate: calculatedDueDate
                                        }));
                                    }}
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">
                                    Fecha de Vencimiento
                                    {(() => {
                                        const selectedC = data.clients?.find((c: any) => String(c.id) === String(formData.clientId));
                                        const creditDays = Number(selectedC?.creditDays) || 0;
                                        return creditDays > 0 ? ` (${creditDays} días plazo)` : '';
                                    })()}
                                </label>
                                <input
                                    type="date"
                                    disabled={isReadOnly}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm font-medium dark:text-white disabled:opacity-60 disabled:cursor-not-allowed"
                                    value={formData.dueDate || ''}
                                    onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Sucursal</label>
                                <SearchSelect
                                    options={data.branches}
                                    value={formData.branchId}
                                    onChange={(val) => setFormData({ ...formData, branchId: val, implantId: '' })}
                                    disabled={isReadOnly}
                                    placeholder="Sel. Sucursal"
                                    secondaryKey="code"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Implant</label>
                                <SearchSelect
                                    options={(data.implants || []).filter((i: any) => 
                                        !formData.branchId || 
                                        !i.branchId || 
                                        i.branchId?.toString() === formData.branchId || 
                                        i.id?.toString() === formData.implantId
                                    )}
                                    value={formData.implantId}
                                    onChange={(val) => setFormData({ ...formData, implantId: val })}
                                    disabled={isReadOnly || (!formData.branchId && (data.implants || []).length === 0)}
                                    placeholder="Sel. Implant"
                                    secondaryKey="code"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Tiqueteador</label>
                                <SearchSelect
                                    options={data.ticketPrinters || []}
                                    value={formData.ticketPrinterId}
                                    onChange={(val) => setFormData({ ...formData, ticketPrinterId: val })}
                                    disabled={isReadOnly}
                                    placeholder="Sel. Tiqueteador"
                                    secondaryKey="code"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Moneda a Cotizar</label>
                                <select
                                    disabled={isReadOnly}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-60 disabled:cursor-not-allowed"
                                    value={formData.currency}
                                    onChange={(e) => {
                                        const code = e.target.value;
                                        const curr = data.currencies?.find((c: any) => c.code === code);
                                        setFormData({
                                            ...formData,
                                            currency: code,
                                            exchangeRate: curr ? curr.exchangeRate : 1
                                        });
                                    }}
                                >
                                    {(data.currencies || [{ code: 'USD', name: 'Dólar Estadounidense' }]).map((c: any) => (
                                        <option key={c.id || c.code} value={c.code}>{c.code} - {c.name}</option>
                                    ))}
                                </select>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Estado de Facturación</label>
                                <select
                                    disabled={isReadOnly}
                                    className={cn(
                                        "w-full h-12 rounded-xl px-4 border outline-none font-bold focus:ring-2 transition-all disabled:opacity-60 disabled:cursor-not-allowed",
                                        formData.state === 'ENVIADO' 
                                            ? "bg-emerald-50/50 dark:bg-emerald-500/5 border-emerald-200 dark:border-emerald-500/20 text-emerald-600 dark:text-emerald-400 focus:ring-emerald-500" 
                                            : "bg-blue-50/50 dark:bg-blue-500/5 border-blue-200 dark:border-blue-500/20 text-blue-600 dark:text-blue-400 focus:ring-blue-500"
                                    )}
                                    value={formData.state}
                                    onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                                >
                                    <option value="Nuevo">NUEVO</option>
                                    <option value="ENVIADO">ENVIADO</option>
                                </select>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Fuente</label>
                                <input
                                    type="text"
                                    maxLength={25}
                                    readOnly={isReadOnly}
                                    disabled={isReadOnly}
                                    value={formData.fuente || ''}
                                    onChange={(e) => setFormData({ ...formData, fuente: e.target.value })}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-60 disabled:cursor-not-allowed"
                                    placeholder="Ej: FAC"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Serie</label>
                                <input
                                    type="text"
                                    maxLength={25}
                                    readOnly={isReadOnly}
                                    disabled={isReadOnly}
                                    value={formData.serie || ''}
                                    onChange={(e) => setFormData({ ...formData, serie: e.target.value })}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-60 disabled:cursor-not-allowed"
                                    placeholder="Ej: A"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-zinc-500">Consecutivo</label>
                                <input
                                    type="text"
                                    maxLength={25}
                                    readOnly={isReadOnly}
                                    disabled={isReadOnly}
                                    value={formData.consecutivo || ''}
                                    onChange={(e) => setFormData({ ...formData, consecutivo: e.target.value })}
                                    className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-60 disabled:cursor-not-allowed"
                                    placeholder="Ej: 0000123"
                                />
                            </div>
                            
                            <div className="col-span-full pt-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-t border-zinc-100 dark:border-zinc-800">
                                <div className="flex items-center gap-2 text-xs text-zinc-500 font-medium">
                                    <FileText className="w-4 h-4 text-blue-600 shrink-0" />
                                    <span>Resolución de Documentos DIAN para la Sucursal</span>
                                </div>
                                <button
                                    type="button"
                                    onClick={async () => {
                                        setLoadingResolution(true);
                                        setResolutionModalOpen(true);
                                        try {
                                            const res = await fetch('/api/config/document-resolutions');
                                            if (res.ok) {
                                                const list = await res.json();
                                                const curBranch = formData.branchId ? parseInt(formData.branchId) : null;
                                                const curImplant = formData.implantId ? parseInt(formData.implantId) : null;
                                                const matched = (Array.isArray(list) ? list : []).find((item: any) => 
                                                    item.isActive && (
                                                        (curBranch && item.branchId === curBranch) || 
                                                        (curImplant && item.implantId === curImplant) ||
                                                        (!item.branchId && !item.implantId)
                                                    )
                                                ) || (Array.isArray(list) ? list : []).find((item: any) => item.isActive) || null;
                                                setActiveResolutionInfo(matched);
                                            }
                                        } catch (err) {
                                            console.error('Error loading resolution:', err);
                                        } finally {
                                            setLoadingResolution(false);
                                        }
                                    }}
                                    className="px-4 py-2 bg-blue-50 dark:bg-blue-950/40 hover:bg-blue-100 dark:hover:bg-blue-900/60 text-blue-600 dark:text-blue-400 rounded-xl text-xs font-bold transition-all flex items-center gap-2 cursor-pointer border border-blue-200 dark:border-blue-800/50 shadow-sm"
                                >
                                    <FileText className="w-3.5 h-3.5" /> Validar Resolución Aplicada <ExternalLink className="w-3 h-3 opacity-60" />
                                </button>
                            </div>
                        </div>
                    </div>

                    {/* Section: Combos */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                        <div className="flex items-center justify-between mb-6">
                            <h3 className="text-lg font-bold flex items-center gap-2 dark:text-white">
                                <Briefcase className="w-5 h-5 text-purple-500" />
                                Combos de Venta
                            </h3>
                            {!isReadOnly && (
                                <div className="flex items-center gap-3">
                                    <div className="w-[300px]">
                                        <SearchSelect
                                            options={(data.combos || []).map((c: any) => ({...c, cuposText: c.cupos != null ? `${c.cupos} cupos` : 'Sin límite'}))}
                                            value=""
                                            onChange={(val) => {
                                                if (val) addCombo(parseInt(val));
                                            }}
                                            disabled={isReadOnly}
                                            placeholder="+ Agregar un Combo..."
                                            secondaryKey="cuposText"
                                        />
                                    </div>
                                </div>
                            )}
                        </div>

                        {formData.selectedCombos && formData.selectedCombos.length > 0 ? (
                            <div className="flex flex-wrap gap-2">
                                {formData.selectedCombos.map(combo => (
                                    <div key={combo.id} className="flex items-center gap-2 px-3 py-1.5 bg-purple-50 dark:bg-purple-900/20 text-purple-600 dark:text-purple-300 rounded-xl border border-purple-100 dark:border-purple-800 text-xs font-bold animate-in fade-in zoom-in duration-300">
                                        <Briefcase className="w-3 h-3" />
                                        {combo.name}
                                        <button
                                            type="button"
                                            onClick={() => removeCombo(combo.id)}
                                            className="p-0.5 hover:bg-purple-200 dark:hover:bg-purple-800 rounded-full transition-colors"
                                        >
                                            <X className="w-3 h-3" />
                                        </button>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <p className="text-zinc-400 text-xs italic">No has seleccionado ningún combo para esta facturación.</p>
                        )}
                    </div>



                    {/* Section: Products Grid */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                        <div className="flex items-center justify-between mb-6">
                            <h3 className="text-lg font-bold flex items-center gap-2 dark:text-white">
                                <Tag className="w-5 h-5 text-emerald-500" />
                                Desglose de Productos
                            </h3>
                            {!isReadOnly && (
                                <button
                                    type="button"
                                    onClick={addItem}
                                    className="px-4 py-2 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-xl font-bold text-xs hover:bg-blue-100 transition-all flex items-center gap-2"
                                >
                                    <Plus className="w-4 h-4" /> Agregar Producto
                                </button>
                            )}
                        </div>

                        <div className="space-y-4">
                            <AnimatePresence>
                                {formData.items.length === 0 && (
                                    <div className="text-center py-10 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border-2 border-dashed border-zinc-200 dark:border-zinc-700 text-zinc-400">
                                        No hay productos agregados.
                                    </div>
                                )}
                                {formData.items.map((item, index) => (
                                    <motion.div
                                        initial={{ opacity: 0, scale: 0.95 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        exit={{ opacity: 0, scale: 0.95 }}
                                        key={index}
                                        className="grid grid-cols-12 gap-4 items-end bg-zinc-50 dark:bg-zinc-800/50 p-6 rounded-2xl border border-zinc-200 dark:border-zinc-700"
                                    >
                                        <div className="col-span-12 md:col-span-3 space-y-1">
                                            <label className="text-[10px] uppercase font-bold text-zinc-400">Producto</label>
                                            <SearchSelect
                                                options={data.products || []}
                                                value={item.productId}
                                                onChange={(val) => {
                                                    const p = data.products.find((prod: any) => prod.id.toString() === val);
                                                    const newItems = [...formData.items];
                                                    newItems[index] = {
                                                        ...newItems[index],
                                                        productId: val,
                                                        price: 0,
                                                        cost: p?.cost || 0
                                                    };
                                                    setFormData({ ...formData, items: newItems });
                                                }}
                                                disabled={isReadOnly}
                                                placeholder="Seleccionar Producto"
                                                labelKey="description"
                                            />
                                        </div>
                                        <div className="col-span-4 md:col-span-2 space-y-1">
                                            <label className="text-[10px] uppercase font-bold text-zinc-400">Cant.</label>
                                            <input
                                                type="number"
                                                min="1"
                                                readOnly={isReadOnly}
                                                disabled={isReadOnly}
                                                className="w-full h-11 bg-white dark:bg-zinc-900 rounded-lg px-3 border border-zinc-200 dark:border-zinc-800 outline-none text-sm disabled:opacity-60"
                                                value={item.quantity}
                                                onChange={(e) => updateItem(index, 'quantity', Math.max(1, parseInt(e.target.value) || 1))}
                                            />
                                        </div>
                                        <div className="col-span-12 md:col-span-6 space-y-1">
                                            <div className="flex justify-between items-center">
                                                <label className="text-[10px] uppercase font-bold text-zinc-400">Cargo Principal / Valor Total (Sumatoria)</label>
                                            </div>
                                            <div className="flex gap-2">
                                                <select
                                                    disabled={isReadOnly}
                                                    className="w-1/2 min-w-[120px] shrink-0 h-11 bg-white dark:bg-zinc-900 rounded-lg px-3 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold text-blue-600 dark:text-blue-400 focus:ring-2 focus:ring-blue-500 disabled:opacity-60 shadow-sm"
                                                    value={item.mainTaxId || ''}
                                                    onChange={(e) => {
                                                        const val = e.target.value ? parseInt(e.target.value) : undefined;
                                                        const master = data.taxes.find((t: any) => t.id === val);
                                                        const newItems = [...formData.items];
                                                        const currentItem = newItems[index];

                                                        let nextTaxes = [...(currentItem.appliedTaxes || [])];
                                                        let newPrice = currentItem.price;

                                                        if (val) {
                                                            const existingTaxIdx = nextTaxes.findIndex((t: any) => (t.id || t.chargeAndTaxId) === val);
                                                            if (existingTaxIdx !== -1) {
                                                                newPrice = nextTaxes[existingTaxIdx].amount / (currentItem.quantity || 1);
                                                            } else {
                                                                newPrice = master ? master.value : currentItem.price;
                                                                const initialAmount = master ? (master.valueType === 'PERCENTAGE' ? (newPrice * currentItem.quantity * master.value / 100) : master.value * currentItem.quantity) : 0;
                                                                nextTaxes.push({ id: val, amount: initialAmount });
                                                            }
                                                        }

                                                        newItems[index] = {
                                                            ...currentItem,
                                                            mainTaxId: val,
                                                            price: newPrice,
                                                            appliedTaxes: nextTaxes
                                                        };
                                                        setFormData({ ...formData, items: newItems });
                                                    }}
                                                >
                                                    <option value="">Selecciona Master...</option>
                                                    {(data.taxes || []).map((t: any) => <option key={t.id} value={String(t.id)}>{t.name}</option>)}
                                                </select>

                                                <div className="relative w-1/2 min-w-[160px] shrink-0">
                                                    <DollarSign className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3 h-3 text-zinc-400" />
                                                    <input
                                                        type="number"
                                                        readOnly={isReadOnly}
                                                        disabled={isReadOnly}
                                                        className="w-full h-11 bg-white dark:bg-zinc-900 rounded-lg pl-7 pr-2 border border-blue-200 dark:border-blue-800 outline-none text-sm font-bold text-blue-600 dark:text-blue-400 focus:ring-2 focus:ring-blue-500 shadow-sm disabled:opacity-60"
                                                        value={((item.appliedTaxes || []).reduce((acc: number, t: any) => acc + (t.amount || 0), 0)).toFixed(decimals)}
                                                        onChange={(e) => {
                                                            const newTotal = parseFloat(e.target.value) || 0;
                                                            const currentTaxes = item.appliedTaxes || [];
                                                            const currentTotal = currentTaxes.reduce((acc: number, t: any) => acc + (t.amount || 0), 0);

                                                            // Calculate how much we need to add to the main tax
                                                            const diff = newTotal - currentTotal;

                                                            const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : null;
                                                            const mainTax = currentTaxes.find((t: any) => {
                                                                const rawId = t.id ?? t.chargeAndTaxId;
                                                                return rawId != null && Number(rawId) === mainTaxIdNum;
                                                            });

                                                            if (mainTax) {
                                                                const newMainAmount = (mainTax.amount || 0) + diff;
                                                                updateItem(index, 'price', newMainAmount / (item.quantity || 1));
                                                            } else {
                                                                updateItem(index, 'price', newTotal / (item.quantity || 1));
                                                            }
                                                        }}
                                                        placeholder="V. Total"
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                        {!isReadOnly && (
                                            <div className="col-span-2 md:col-span-1 flex justify-center pb-2">
                                                <button
                                                    type="button"
                                                    onClick={() => removeItem(index)}
                                                    className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                                                >
                                                    <Trash2 className="w-5 h-5" />
                                                </button>
                                            </div>
                                        )}

                                        {/* Per-Product Details Row */}
                                        <div className="col-span-12 mt-2 pt-4 border-t border-zinc-200 dark:border-zinc-700/50">
                                            <p className="text-[10px] uppercase font-bold text-zinc-400 mb-3">Detalles de Proveedor y Pasajero</p>
                                            
                                            {/* Fila de Datos Manuales (Tiquetes/Servicios) */}
                                            <div className="grid grid-cols-1 md:grid-cols-6 gap-4 mb-4">
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-blue-500">Código Tiquete/Voucher</label>
                                                    <input
                                                        type="text"
                                                        placeholder="Ej: 134-1234567890"
                                                        className="w-full h-9 bg-blue-50 dark:bg-blue-900/20 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs"
                                                        value={item.ticketCode || ''}
                                                        onChange={(e) => updateItem(index, 'ticketCode', e.target.value)}
                                                        disabled={isReadOnly}
                                                        readOnly={isReadOnly}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-blue-500">Tipo (Tiquete/Servicio)</label>
                                                    <select
                                                        className="w-full h-9 bg-blue-50 dark:bg-blue-900/20 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs"
                                                        value={item.serviceType || ''}
                                                        onChange={(e) => updateItem(index, 'serviceType', e.target.value)}
                                                        disabled={isReadOnly}
                                                    >
                                                        <option value="">(Ninguno)</option>
                                                        <option value="Tiquete">Tiquete</option>
                                                        <option value="Servicio">Servicio</option>
                                                        <option value="Paquete">Paquete</option>
                                                        <option value="Hotel">Hotel</option>
                                                        <option value="Auto">Auto</option>
                                                    </select>
                                                </div>
                                                <div className="space-y-1">
                                                     <label className="text-[10px] uppercase font-bold text-blue-500">Tipo Tiquete</label>
                                                     <select
                                                         className="w-full h-9 bg-blue-50 dark:bg-blue-900/20 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs"
                                                         value={item.ticketTypeId || ''}
                                                         onChange={(e) => updateItem(index, 'ticketTypeId', e.target.value ? parseInt(e.target.value) : undefined)}
                                                         disabled={isReadOnly}
                                                     >
                                                         <option value="">(Ninguno)</option>
                                                         {data.ticketTypes?.map((t: any) => (
                                                             <option key={t.id} value={t.id}>{t.name}</option>
                                                         ))}
                                                     </select>
                                                 </div>
                                                 <div className="space-y-1">
                                                     <label className="text-[10px] uppercase font-bold text-blue-500">Servicio</label>
                                                     <input
                                                         type="text"
                                                         placeholder="Ej: Alimentación..."
                                                         className="w-full h-9 bg-blue-50 dark:bg-blue-900/20 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs"
                                                         value={item.servicios || ''}
                                                         onChange={(e) => updateItem(index, 'servicios', e.target.value)}
                                                         disabled={isReadOnly}
                                                         readOnly={isReadOnly}
                                                     />
                                                 </div>
                                                 <div className="md:col-span-2 space-y-1">
                                                     <label className="text-[10px] uppercase font-bold text-blue-500">Descripción Manual</label>
                                                     <input
                                                         type="text"
                                                         placeholder="Descripción de lo que se está cobrando..."
                                                         className="w-full h-9 bg-blue-50 dark:bg-blue-900/20 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs"
                                                         value={item.descripcion || ''}
                                                         onChange={(e) => updateItem(index, 'descripcion', e.target.value)}
                                                         disabled={isReadOnly}
                                                         readOnly={isReadOnly}
                                                     />
                                                 </div>
                                            </div>

                                            {['tiquete', 'aereo', 'aéreo', 'aire'].includes(item.serviceType?.toLowerCase() || '') && (
                                                <>
                                                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4 bg-blue-50/50 dark:bg-blue-900/10 p-3 rounded-xl border border-blue-100 dark:border-blue-800/50">
                                                        <div className="space-y-1">
                                                            <label className="text-[10px] uppercase font-bold text-blue-500">Itinerario de Vuelo</label>
                                                            <input
                                                                type="text"
                                                                placeholder="Ej: BOG/CTG"
                                                                className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs uppercase"
                                                                value={item.itinerary || ''}
                                                                onChange={(e) => updateItem(index, 'itinerary', e.target.value)}
                                                                disabled={isReadOnly}
                                                                readOnly={isReadOnly}
                                                                onBlur={() => {
                                                                    if (item.itinerary && item.itinerary.includes('/')) {
                                                                        const parts = item.itinerary.split('/');
                                                                        if (parts.length === 2 && parts[0].length === 3 && parts[1].length === 3) {
                                                                            const list = item.itinerariesItineraryList || [];
                                                                            if (list.length === 0) {
                                                                                updateItem(index, 'itinerariesItineraryList', [{
                                                                                    origin: parts[0].toUpperCase(),
                                                                                    destination: parts[1].toUpperCase(),
                                                                                    class: item.class ? item.class.split('/')[0] : '',
                                                                                    checkInDate: item.checkIn || undefined,
                                                                                    checkOutDate: item.checkOut || undefined,
                                                                                    prestadoraCode: item.airline ? item.airline.split('/')[0].toUpperCase() : ''
                                                                                }]);
                                                                            }
                                                                        }
                                                                    }
                                                                }}
                                                            />
                                                        </div>
                                                        <div className="space-y-1">
                                                            <label className="text-[10px] uppercase font-bold text-blue-500">Itinerario de Clases</label>
                                                            <input
                                                                type="text"
                                                                placeholder="Ej: C/C"
                                                                className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs uppercase"
                                                                value={item.class || ''}
                                                                onChange={(e) => updateItem(index, 'class', e.target.value)}
                                                                disabled={isReadOnly}
                                                                readOnly={isReadOnly}
                                                            />
                                                        </div>
                                                        <div className="space-y-1">
                                                            <label className="text-[10px] uppercase font-bold text-blue-500">Itinerario de Aerolínea</label>
                                                            <input
                                                                type="text"
                                                                placeholder="Ej: AV/AV"
                                                                className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs uppercase"
                                                                value={item.airline || ''}
                                                                onChange={(e) => updateItem(index, 'airline', e.target.value)}
                                                                disabled={isReadOnly}
                                                                readOnly={isReadOnly}
                                                            />
                                                        </div>
                                                    </div>
                                                    <div className="mb-4">
                                                            <div className="flex items-center justify-between mb-2 bg-zinc-100 dark:bg-zinc-800/80 px-3 py-2 rounded-lg border border-zinc-200 dark:border-zinc-700">
                                                                <div className="flex items-center gap-2">
                                                                    <span className="text-xs uppercase font-bold text-zinc-700 dark:text-zinc-300">Detalle de Itinerarios</span>
                                                                    {item.itinerariesItineraryList && item.itinerariesItineraryList.length > 0 ? (
                                                                        <span className="text-[10px] bg-blue-100 dark:bg-blue-900/50 text-blue-700 dark:text-blue-300 font-bold px-2.5 py-0.5 rounded-full">
                                                                            {item.itinerariesItineraryList.length} tramo{item.itinerariesItineraryList.length > 1 ? 's' : ''}
                                                                        </span>
                                                                    ) : (
                                                                        <span className="text-[10px] text-zinc-400 italic">(Opcional)</span>
                                                                    )}
                                                                </div>
                                                                <button
                                                                    type="button"
                                                                    onClick={() => setOpenItineraries(prev => ({ ...prev, [index]: !prev[index] }))}
                                                                    className="text-xs text-blue-600 dark:text-blue-400 font-semibold flex items-center gap-1 hover:underline cursor-pointer"
                                                                >
                                                                    {openItineraries[index] ? (
                                                                        <>
                                                                            <span>Ocultar Detalle</span>
                                                                            <ChevronUp className="w-4 h-4" />
                                                                        </>
                                                                    ) : (
                                                                        <>
                                                                            <span>+ Desplegar Detalle de Itinerarios</span>
                                                                            <ChevronDown className="w-4 h-4" />
                                                                        </>
                                                                    )}
                                                                </button>
                                                            </div>

                                                            {openItineraries[index] && (
                                                                <div className="bg-zinc-50 dark:bg-zinc-800/50 rounded-lg p-3 border border-zinc-200 dark:border-zinc-700">
                                                                    {item.itinerariesItineraryList && item.itinerariesItineraryList.length > 0 ? (
                                                                        <div className="overflow-x-auto w-full border border-zinc-200 dark:border-zinc-700 rounded-lg bg-white dark:bg-zinc-900/50 p-2 scrollbar-thin">
                                                                            <div className="min-w-[1050px] space-y-2">
                                                                                {/* Encabezado */}
                                                                                <div className="flex gap-2 text-[9px] uppercase font-bold text-zinc-400 px-1 select-none">
                                                                                    <div className="w-16">Origen</div>
                                                                                    <div className="w-16">Destino</div>
                                                                                    <div className="w-16">Aero</div>
                                                                                    <div className="w-14">Clase</div>
                                                                                    <div className="w-32">Salida</div>
                                                                                    <div className="w-32">Llegada</div>
                                                                                    <div className="w-24">Fare Basis</div>
                                                                                    <div className="w-20">Nro. Vuelo</div>
                                                                                    <div className="w-14">Tipo</div>
                                                                                    <div className="w-24">Valor</div>
                                                                                    <div className="w-20">CO2</div>
                                                                                    <div className="w-8"></div>
                                                                                </div>
                                                                                {/* Filas */}
                                                                                {item.itinerariesItineraryList.map((itin: any, itinIdx: number) => (
                                                                                    <div key={itinIdx} className="flex gap-2 items-center text-xs">
                                                                                        <div className="w-16 flex-shrink-0">
                                                                                            <input type="text" placeholder="Origen" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.origin || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].origin = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-16 flex-shrink-0">
                                                                                            <input type="text" placeholder="Destino" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.destination || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].destination = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-16 flex-shrink-0">
                                                                                            <input type="text" placeholder="Aero" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.prestadoraCode || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].prestadoraCode = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-14 flex-shrink-0">
                                                                                            <input type="text" placeholder="Clase" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.class || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].class = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-32 flex-shrink-0">
                                                                                            <input type="date" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1 outline-none text-[10px]" value={itin.checkInDate ? (itin.checkInDate.includes('T') ? itin.checkInDate.split('T')[0] : itin.checkInDate) : ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].checkInDate = e.target.value;
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-32 flex-shrink-0">
                                                                                            <input type="date" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1 outline-none text-[10px]" value={itin.checkOutDate ? (itin.checkOutDate.includes('T') ? itin.checkOutDate.split('T')[0] : itin.checkOutDate) : ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].checkOutDate = e.target.value;
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-24 flex-shrink-0">
                                                                                            <input type="text" placeholder="Farebasis" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.farebasis || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].farebasis = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-20 flex-shrink-0">
                                                                                            <input type="text" placeholder="Vuelo" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none text-xs" value={itin.Numflight || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].Numflight = e.target.value;
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-14 flex-shrink-0">
                                                                                            <input type="text" placeholder="Tipo" maxLength={1} className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none uppercase text-xs" value={itin.Typeflight || ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].Typeflight = e.target.value.toUpperCase();
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-24 flex-shrink-0">
                                                                                            <input type="number" step="any" placeholder="Valor" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none text-xs" value={itin.amount != null ? itin.amount : ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].amount = e.target.value !== '' ? parseFloat(e.target.value) : undefined;
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-20 flex-shrink-0">
                                                                                            <input type="number" step="any" placeholder="CO2" className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded border border-zinc-200 dark:border-zinc-700 px-1.5 outline-none text-xs" value={itin.co2 != null ? itin.co2 : ''} onChange={e => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list[itinIdx].co2 = e.target.value !== '' ? parseFloat(e.target.value) : undefined;
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} />
                                                                                        </div>
                                                                                        <div className="w-8 flex-shrink-0 text-center">
                                                                                            <button type="button" onClick={() => {
                                                                                                const list = [...(item.itinerariesItineraryList || [])];
                                                                                                list.splice(itinIdx, 1);
                                                                                                updateItineraryListAndSummaries(index, list);
                                                                                            }} className="text-red-500 hover:text-red-700 bg-red-50 dark:bg-red-900/20 p-1.5 rounded transition-colors">
                                                                                                <Trash2 className="w-3.5 h-3.5 mx-auto" />
                                                                                            </button>
                                                                                        </div>
                                                                                    </div>
                                                                                ))}
                                                                            </div>
                                                                        </div>
                                                                    ) : (
                                                                        <div className="text-center text-[10px] text-zinc-400 py-3 italic">Sin itinerarios detallados</div>
                                                                    )}
                                                                    <button type="button" onClick={() => {
                                                                        const list = [...(item.itinerariesItineraryList || [])];
                                                                        list.push({ origin: '', destination: '', class: '', checkInDate: '', checkOutDate: '', prestadoraCode: '', farebasis: '', Numflight: '', Typeflight: '', amount: undefined, co2: undefined });
                                                                        updateItineraryListAndSummaries(index, list);
                                                                    }} className="mt-2 text-[10px] text-blue-500 font-bold hover:bg-blue-50 dark:hover:bg-blue-900/20 px-2 py-1 rounded transition-colors inline-flex items-center gap-1">
                                                                        <Plus className="w-3.5 h-3.5" /> Añadir Tramo
                                                                    </button>
                                                                </div>
                                                            )}
                                                        </div>
                                                </>
                                            )}

                                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                                                <div className="md:col-span-2 space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Proveedor</label>
                                                    <SearchSelect
                                                        options={data.providers || []}
                                                        value={item.providerId}
                                                        onChange={(val) => updateItem(index, 'providerId', val)}
                                                        placeholder="Sel. Proveedor"
                                                        secondaryKey="code"
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Prestadora</label>
                                                    <SearchSelect
                                                        options={data.prestadoras || []}
                                                        value={item.prestadoraId}
                                                        onChange={(val) => updateItem(index, 'prestadoraId', val)}
                                                        placeholder="Sel. Prestadora"
                                                        secondaryKey="code"
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Nacionalidad</label>
                                                    <select
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-[10px] font-bold text-emerald-600 dark:text-emerald-400"
                                                        value={item.inNationality || 1}
                                                        onChange={(e) => updateItem(index, 'inNationality', parseInt(e.target.value))}
                                                    >
                                                        <option value={1}>Nacional</option>
                                                        <option value={2}>Internacional</option>
                                                    </select>
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Fecha Inicial</label>
                                                    <input
                                                        type="date"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs p-1"
                                                        value={item.checkIn}
                                                        onChange={(e) => updateItem(index, 'checkIn', e.target.value)}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Fecha Final</label>
                                                    <input
                                                        type="date"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs p-1"
                                                        value={item.checkOut}
                                                        onChange={(e) => updateItem(index, 'checkOut', e.target.value)}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Reservación</label>
                                                    <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.reservationCode} onChange={(e) => updateItem(index, 'reservationCode', e.target.value)} />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Destino</label>
                                                    <SearchSelect
                                                        options={data.cities || []}
                                                        value={item.destination || ''}
                                                        onChange={(val) => updateItem(index, 'destination', val)}
                                                        placeholder="Buscar Destino..."
                                                        labelKey="name"
                                                        secondaryKey="code"
                                                        valueKey="name"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs"
                                                        remoteSearchEndpoint="/api/config/cities"
                                                        allowCustomValue={true}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Adultos</label>
                                                    <input type="number" min="1" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.paxAdults} onChange={(e) => updateItem(index, 'paxAdults', parseInt(e.target.value))} />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Niños</label>
                                                    <input type="number" min="0" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.paxChildren} onChange={(e) => updateItem(index, 'paxChildren', parseInt(e.target.value))} />
                                                </div>
                                            </div>

                                            {/* Dynamic Passengers Array - Visible only if NOT a combo item */}
                                            {!item.comboId && (
                                                <div className="mt-4 space-y-2">
                                                    <p className="text-[10px] uppercase font-bold text-zinc-400 flex justify-between items-center">
                                                        Detalle de Pasajeros
                                                        <button type="button" onClick={() => {
                                                            const p = [...(item.passengers || [])];
                                                            p.push({ name: '', document: '' });
                                                            updateItem(index, 'passengers', p);
                                                        }} className="text-blue-500 font-medium hover:underline lowercase text-xs flex items-center gap-1">+ agregar pasajero</button>
                                                    </p>
                                                    {(item.passengers || []).map((pax: any, pIdx: number) => (
                                                        <div key={pIdx} className="flex gap-2">
                                                            <input type="text" placeholder="Nombre" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={pax.name} onChange={(e) => {
                                                                const newPass = [...(item.passengers || [])];
                                                                newPass[pIdx] = { ...pax, name: e.target.value };
                                                                updateItem(index, 'passengers', newPass);
                                                            }} />
                                                            <input type="text" placeholder="Documento" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={pax.document} onChange={(e) => {
                                                                const newPass = [...(item.passengers || [])];
                                                                newPass[pIdx] = { ...pax, document: e.target.value };
                                                                updateItem(index, 'passengers', newPass);
                                                            }} />
                                                            <button type="button" onClick={() => {
                                                                const newPass = (item.passengers || []).filter((_: any, idx: number) => idx !== pIdx);
                                                                updateItem(index, 'passengers', newPass);
                                                            }} className="text-red-400 p-2 hover:bg-red-50 rounded"><Trash2 className="w-4 h-4" /></button>
                                                        </div>
                                                    ))}
                                                </div>
                                            )}

                                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-4">
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-orange-500 dark:text-orange-400">Costo ($)</label>
                                                    <input
                                                        type="number"
                                                        min="0"
                                                        step="0.01"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-orange-200 dark:border-orange-800 outline-none text-xs font-bold text-orange-600 dark:text-orange-400 focus:ring-1 focus:ring-orange-400"
                                                        value={item.cost ?? 0}
                                                        onChange={(e) => updateItem(index, 'cost', parseFloat(e.target.value) || 0)}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-emerald-600 dark:text-emerald-400">Com. Vend. ($)</label>
                                                    <input
                                                        type="number"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold"
                                                        value={item.sellerCommission}
                                                        onChange={(e) => updateItem(index, 'sellerCommission', parseFloat(e.target.value) || 0)}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-emerald-600 dark:text-emerald-400">Com. Tiq. ($)</label>
                                                    <input
                                                        type="number"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold"
                                                        value={item.ticketPrinterCommission}
                                                        onChange={(e) => updateItem(index, 'ticketPrinterCommission', parseFloat(e.target.value) || 0)}
                                                    />
                                                </div>
                                            </div>
                                        </div>


                                            <div className="col-span-12 mt-4 flex justify-between items-center bg-blue-50/50 dark:bg-blue-900/10 p-3 rounded-xl border border-blue-100 dark:border-blue-800/30">
                                                <div>
                                                    <p className="text-[10px] uppercase font-bold text-blue-600 dark:text-blue-400">Pagos Registrados</p>
                                                    <p className="text-xs font-bold text-zinc-600 dark:text-zinc-300">
                                                        Total: ${getItemTotal(item).toLocaleString(undefined, {minimumFractionDigits: decimals, maximumFractionDigits: decimals})} | Pagado: ${((item.payments || []).reduce((acc: number, p: any) => acc + p.amount, 0)).toLocaleString(undefined, {minimumFractionDigits: decimals, maximumFractionDigits: decimals})}
                                                    </p>
                                                </div>
                                                <button type="button" onClick={() => updateItem(index, 'isPaymentModalOpen', true)} className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1 shadow-sm transition-all">
                                                    <CreditCard className="w-3.5 h-3.5" /> Administrar Pagos
                                                </button>
                                            </div>
                                            <ItemPaymentModal
                                                isOpen={item.isPaymentModalOpen || false}
                                                onClose={() => updateItem(index, 'isPaymentModalOpen', false)}
                                                productName={item.productId ? (data.products?.find((p:any) => p.id.toString() === item.productId?.toString())?.description || 'Producto') : 'Producto sin nombre'}
                                                itemTotal={getItemTotal(item)}
                                                payments={item.payments || []}
                                                onUpdatePayments={(payments) => updateItem(index, 'payments', payments)}
                                                creditCards={data.creditCards || []}
                                                paymentsList={data.payments || []}
                                            />
                                            
                                        {/* Product Taxes Row */}
                                        <div className="col-span-12 mt-2 pt-4 border-t border-zinc-200 dark:border-zinc-700/50">
                                            <p className="text-[10px] uppercase font-bold text-zinc-400 mb-3 flex items-center justify-between">
                                                <span>Cargos e Impuestos Adicionales</span>
                                                <button
                                                    type="button"
                                                    onClick={() => handleCalculateTaxes(index)}
                                                    className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded text-xs transition-all flex items-center gap-1 shadow-sm"
                                                >
                                                    <Calculator className="w-3 h-3" /> Calcular Impuestos (%)
                                                </button>
                                            </p>
                                            <div className="flex flex-col gap-2">
                                                {(data.taxes || []).length === 0 && (
                                                    <span className="text-xs text-zinc-400 font-medium">No hay cargos maestros configurados.</span>
                                                )}

                                                {/* Render taxes sorted by orden/name and filtered by product assignment */}
                                                {(() => {
                                                    const rawProductId = item.productId ? Number(item.productId) : null;
                                                    
                                                    const sortedTaxes = [...(data.taxes || [])].sort((a: any, b: any) => {
                                                        const orderA = a.orden && Number(a.orden) > 0 ? Number(a.orden) : (a.code === 'TAR' ? 1 : 9999);
                                                        const orderB = b.orden && Number(b.orden) > 0 ? Number(b.orden) : (b.code === 'TAR' ? 1 : 9999);
                                                        if (orderA !== orderB) return orderA - orderB;
                                                        return (a.name || '').localeCompare(b.name || '');
                                                    });

                                                    const filteredTaxes = sortedTaxes.filter((tax: any) => {
                                                        const taxIdNum = Number(tax.id);
                                                        const isPrincipal = item.mainTaxId != null && Number(item.mainTaxId) === taxIdNum;
                                                        const isApplied = (item.appliedTaxes || []).some((t: any) => Number(t.id ?? t.chargeAndTaxId) === taxIdNum);
                                                        
                                                        if (isPrincipal || isApplied || tax.code === 'TAR') return true;

                                                        if (rawProductId != null && Array.isArray(data.products)) {
                                                            const selectedProduct = data.products.find((p: any) => Number(p.id) === rawProductId);
                                                            if (selectedProduct) {
                                                                let tIds: number[] = [];
                                                                if (Array.isArray(selectedProduct.taxIds)) {
                                                                    tIds = selectedProduct.taxIds.map(Number);
                                                                } else if (typeof selectedProduct.taxIds === 'string') {
                                                                    try { tIds = JSON.parse(selectedProduct.taxIds).map(Number); } catch(e) { tIds = []; }
                                                                }

                                                                if (tIds.length > 0) {
                                                                    return tIds.includes(taxIdNum);
                                                                }
                                                            }
                                                        }

                                                        return true;
                                                    });

                                                    return filteredTaxes.map((tax: any) => {
                                                        const taxIdNum = Number(tax.id);
                                                        const appliedTax = item.appliedTaxes?.find((t: any) => {
                                                            const rawId = (t as any).id ?? (t as any).chargeAndTaxId;
                                                            return rawId != null && Number(rawId) === taxIdNum;
                                                        });
                                                        const isChecked = !!appliedTax;
                                                        const isPrincipal = item.mainTaxId != null && Number(item.mainTaxId) === taxIdNum;
                                                    
                                                    return (
                                                        <div key={tax.id} className="flex items-center gap-4 bg-zinc-50 dark:bg-zinc-800/80 p-2 rounded-xl border border-zinc-200 dark:border-zinc-800">
                                                            <div className="flex items-center gap-2 min-w-[200px]">
                                                                <label className={cn(
                                                                    "flex items-center gap-2 cursor-pointer text-sm font-bold flex-1",
                                                                    isPrincipal ? "text-blue-600 dark:text-blue-400" : (isChecked ? "text-emerald-600 dark:text-emerald-400" : "text-zinc-600 dark:text-zinc-400")
                                                                )}>
                                                                    <input
                                                                        type="checkbox"
                                                                        className="rounded border-zinc-300 text-blue-600 focus:ring-blue-500 w-4 h-4"
                                                                        checked={isChecked}
                                                                        onChange={(e) => {
                                                                            const checked = e.target.checked;
                                                                            const currentTaxes = item.appliedTaxes || [];
                                                                            const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : null;

                                                                            if (checked) {
                                                                                let initialAmount = 0;
                                                                                const baseValue = item.price * item.quantity;
                                                                                if (tax.valueType === 'PERCENTAGE') {
                                                                                    initialAmount = (baseValue * (tax.value || 0)) / 100;
                                                                                } else if (tax.valueType === 'FIXED') {
                                                                                    initialAmount = (tax.value || 0) * item.quantity;
                                                                                } else {
                                                                                    initialAmount = (tax.value || 0) * item.quantity;
                                                                                }
                                                                                const nextTaxes = [...currentTaxes, { id: taxIdNum, amount: initialAmount }];

                                                                                // AUTO-PROMOTE to principal if none exists
                                                                                if (mainTaxIdNum === null) {
                                                                                    const newItems = [...formData.items];
                                                                                    const newPrice = initialAmount / (item.quantity || 1);
                                                                                    newItems[index] = { ...item, mainTaxId: taxIdNum, price: newPrice, appliedTaxes: nextTaxes };
                                                                                    setFormData({ ...formData, items: newItems });
                                                                                } else {
                                                                                    updateItem(index, 'appliedTaxes', nextTaxes);
                                                                                }
                                                                            } else {
                                                                                const nextTaxes = currentTaxes.filter((t: any) => {
                                                                                    const rawId = t.id ?? t.chargeAndTaxId;
                                                                                    return rawId != null && Number(rawId) !== taxIdNum;
                                                                                });
                                                                                
                                                                                // DEMOTE if it was principal
                                                                                if (mainTaxIdNum === taxIdNum) {
                                                                                    const newItems = [...formData.items];
                                                                                    newItems[index] = { ...item, mainTaxId: undefined, price: 0, appliedTaxes: nextTaxes };
                                                                                    setFormData({ ...formData, items: newItems });
                                                                                } else {
                                                                                    updateItem(index, 'appliedTaxes', nextTaxes);
                                                                                }
                                                                            }
                                                                        }}
                                                                    />
                                                                    <span>
                                                                        {tax.name}
                                                                        {isPrincipal && <span className="ml-1 px-1.5 py-0.5 bg-blue-100 dark:bg-blue-900/40 text-blue-600 dark:text-blue-400 rounded text-[9px] uppercase tracking-wider font-extrabold">Principal</span>}
                                                                        {(() => {
                                                                            if (!tax.targetTaxId) return null;
                                                                            const targetTax = data?.taxes?.find((t: any) => Number(t.id) === Number(tax.targetTaxId));
                                                                            const targetName = targetTax?.name || 'TARIFA';
                                                                            return (
                                                                                <span className="text-[9px] bg-amber-100 dark:bg-amber-900/40 text-amber-800 dark:text-amber-300 font-extrabold px-1.5 py-0.5 rounded ml-1.5 uppercase inline-flex items-center gap-0.5">
                                                                                    ↳ Suma en {targetName}
                                                                                </span>
                                                                            );
                                                                        })()}
                                                                    </span>
                                                                </label>
                                                            </div>
                                                            
                                                            {isChecked && (
                                                                <div className="flex items-center gap-2 flex-1 ml-4 border-l border-zinc-200 dark:border-zinc-700 pl-4 py-1">
                                                                    <div className="relative group/tooltip flex-1">
                                                                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 text-xs font-bold">$</span>
                                                                        <input
                                                                            type="number"
                                                                            step="0.01"
                                                                            className="w-full h-8 bg-white dark:bg-zinc-900 rounded-lg pl-6 pr-2 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-emerald-500 shadow-sm transition-all text-sm font-bold text-emerald-600 dark:text-emerald-400"
                                                                            value={appliedTax?.amount != null ? appliedTax.amount : (isPrincipal ? (item.price * item.quantity) : '')}
                                                                            onChange={(e) => {
                                                                                const val = parseFloat(e.target.value) || 0;
                                                                                if (isPrincipal) {
                                                                                    updateItem(index, 'price', val / (item.quantity || 1));
                                                                                }
                                                                                const newTaxes = (item.appliedTaxes || []).map((t: any) => {
                                                                                    const rawId = t.id ?? t.chargeAndTaxId;
                                                                                    return (rawId != null && Number(rawId) === taxIdNum) ? { ...t, amount: val } : t;
                                                                                });
                                                                                updateItem(index, 'appliedTaxes', newTaxes);
                                                                            }}
                                                                        />
                                                                    </div>
                                                                </div>
                                                            )}
                                                        </div>
                                                    );
                                                });
                                            })()}
                                            </div>
                                        </div>

                                        {/* Variables Adicionales Row */}
                                        {data.variables && data.variables.length > 0 && (
                                            <div className="col-span-12 mt-2 pt-4 border-t border-zinc-200 dark:border-zinc-700/50">
                                                <p className="text-[10px] uppercase font-bold text-zinc-400 mb-3 flex items-center justify-between">
                                                    <span>Variables de Sistema Adicionales</span>
                                                </p>
                                                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                                                    {(() => {
                                                        const selectedClient = data.clients?.find((c: any) => String(c.id) === String(formData.clientId));
                                                        let clientMandatoryIds: any[] = [];
                                                        if (selectedClient?.mandatoryVariables) {
                                                            if (Array.isArray(selectedClient.mandatoryVariables)) {
                                                                clientMandatoryIds = selectedClient.mandatoryVariables;
                                                            } else if (typeof selectedClient.mandatoryVariables === 'string') {
                                                                try { clientMandatoryIds = JSON.parse(selectedClient.mandatoryVariables); } catch (e) {}
                                                            }
                                                        }

                                                        const availableVariables = (data.variables || []).filter((vMaster: any) => {
                                                            if (vMaster.isForAllClients) return true;
                                                            const isMandatoryForClient = clientMandatoryIds.some(
                                                                id => String(id) === String(vMaster.id) || String(id) === String(vMaster.code)
                                                            );
                                                            if (isMandatoryForClient) return true;
                                                            const hasValueInItem = item.variables?.some(
                                                                (v: any) => String(v.masterVariableId) === String(vMaster.id) && v.value
                                                            );
                                                            if (hasValueInItem) return true;
                                                            return false;
                                                        });

                                                        if (availableVariables.length === 0) {
                                                            return <span className="col-span-2 text-xs text-zinc-400 font-medium">No hay variables adicionales aplicables para este cliente.</span>;
                                                        }

                                                        return availableVariables.map((vMaster: any) => {
                                                            const assigned = (item.variables || []).find((v: any) => String(v.masterVariableId) === String(vMaster.id));
                                                            const isSelected = !!assigned;

                                                            return (
                                                                <div key={vMaster.id} className={cn(
                                                                    "flex flex-col gap-2 p-3 rounded-xl border transition-all",
                                                                    isSelected ? "bg-blue-50/50 dark:bg-blue-900/10 border-blue-200 dark:border-blue-800/50" : "bg-zinc-50 dark:bg-zinc-800/50 border-zinc-200 dark:border-zinc-800"
                                                                )}>
                                                                    <div className="flex items-center gap-2">
                                                                        <label className={cn(
                                                                            "flex items-center gap-2 cursor-pointer text-sm font-bold flex-1",
                                                                            isSelected ? "text-blue-600 dark:text-blue-400" : "text-zinc-600 dark:text-zinc-400"
                                                                        )}>
                                                                            <input
                                                                                type="checkbox"
                                                                                className="rounded border-zinc-300 text-blue-600 focus:ring-blue-500 w-4 h-4"
                                                                                checked={isSelected}
                                                                                onChange={(e) => {
                                                                                    const checked = e.target.checked;
                                                                                    const currentVars = item.variables || [];
                                                                                    if (checked) {
                                                                                        updateItem(index, 'variables', [...currentVars, { masterVariableId: vMaster.id, value: '' }]);
                                                                                    } else {
                                                                                        updateItem(index, 'variables', currentVars.filter((v: any) => String(v.masterVariableId) !== String(vMaster.id)));
                                                                                    }
                                                                                }}
                                                                            />
                                                                            <span>{vMaster.name}</span>
                                                                            <span className="opacity-50 text-[10px] ml-auto">({vMaster.code})</span>
                                                                        </label>
                                                                    </div>

                                                                    {isSelected && (
                                                                        <div className="flex-1 border-l border-zinc-200 dark:border-zinc-700 pl-4 py-1">
                                                                            <input
                                                                                type="text"
                                                                                placeholder={`Ingresar valor para ${vMaster.name}`}
                                                                                className="w-full h-8 bg-white dark:bg-zinc-900 rounded-lg px-3 border border-zinc-200 dark:border-zinc-700 text-sm font-bold outline-none focus:ring-2 focus:ring-blue-500 shadow-sm transition-all"
                                                                                value={assigned.value}
                                                                                onChange={(e) => {
                                                                                    const val = e.target.value;
                                                                                    const newVars = (item.variables || []).map((v: any) =>
                                                                                        String(v.masterVariableId) === String(vMaster.id) ? { ...v, value: val } : v
                                                                                    );
                                                                                    updateItem(index, 'variables', newVars);
                                                                                }}
                                                                            />
                                                                        </div>
                                                                    )}
                                                                </div>
                                                            )
                                                        });
                                                    })()}
                                                </div>
                                            </div>
                                        )}
                                    </motion.div>
                                ))}
                            </AnimatePresence>
                        </div>
                    </div>
                </div>

                {/* Right Column: Pricing & Guests */}
                <div className="space-y-8">
                    {/* Pricing & Summary */}
                    <div className="bg-zinc-900 text-white p-8 rounded-3xl shadow-xl shadow-zinc-900/40 space-y-8 relative overflow-hidden">
                        <div className="absolute top-0 right-0 p-10 bg-blue-600/10 blur-[60px] rounded-full" />

                        <h3 className="text-lg font-bold relative z-10 flex items-center gap-2">
                            <Calculator className="w-5 h-5 text-blue-400" />
                            Resumen de Cargos e Impuestos
                        </h3>

                        <div className="space-y-6 relative z-10">
                            <div className="flex items-center justify-between gap-4">
                                <div className="space-y-1 flex-1">
                                    <label className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider">Moneda</label>
                                    <select
                                        disabled={isReadOnly}
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold disabled:opacity-60 disabled:cursor-not-allowed"
                                        value={formData.currency}
                                        onChange={(e) => {
                                            const code = e.target.value;
                                            const curr = data.currencies?.find((c: any) => c.code === code);
                                            setFormData({
                                                ...formData,
                                                currency: code,
                                                exchangeRate: curr ? curr.exchangeRate : formData.exchangeRate
                                            });
                                        }}
                                    >
                                        {(data.currencies || []).map((c: any) => (
                                            <option key={c.id || c.code} value={c.code}>{c.code} - {c.name}</option>
                                        ))}
                                    </select>
                                </div>
                                <div className="space-y-1 flex-1">
                                    <label className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider">Tasa Cambio</label>
                                    <input
                                        type="number"
                                        readOnly={isReadOnly}
                                        disabled={isReadOnly}
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold text-right disabled:opacity-60 disabled:cursor-not-allowed"
                                        value={formData.exchangeRate}
                                        onChange={(e) => setFormData({ ...formData, exchangeRate: parseFloat(e.target.value) })}
                                    />
                                </div>
                                <div className="space-y-1 flex-1">
                                    <label className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider">Comisión (%)</label>
                                    <input
                                        type="number"
                                        readOnly={isReadOnly}
                                        disabled={isReadOnly}
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold text-right disabled:opacity-60 disabled:cursor-not-allowed"
                                        value={formData.commissionPercentage}
                                        onChange={(e) => setFormData({ ...formData, commissionPercentage: parseFloat(e.target.value) || 0 })}
                                    />
                                </div>
                            </div>

                            <div className="space-y-4 relative z-10 pt-4">
                                {sortedTaxSummaryList.length === 0 && (
                                    <div className="text-zinc-500 text-sm font-medium text-center pb-4">Aún no se han configurado cargos en los productos.</div>
                                )}
                                {sortedTaxSummaryList.map((taxItem) => (
                                    <div key={taxItem.name} className="flex justify-between items-center text-sm font-bold text-zinc-300 border-b border-zinc-800 pb-3">
                                        <span className="flex items-center gap-2">
                                            <Tag className="w-4 h-4 text-emerald-400" />
                                            {taxItem.name}
                                        </span>
                                        <span className="text-white">${taxItem.amount.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}</span>
                                    </div>
                                ))}
                            </div>

                            {/* Final Math */}
                            <div className="pt-8 space-y-4 relative z-10">
                                <div className="flex justify-between items-end">
                                    <span className="text-lg font-bold">Costo Real Total</span>
                                    <div className="text-right">
                                        <div className="text-4xl font-black text-emerald-400">
                                            ${total.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}
                                        </div>
                                        <p className="text-[10px] uppercase text-zinc-500 mt-1">Suma exacta en {formData.currency}</p>
                                        {!isReadOnly && (
                                            <div className="mt-4">
                                                <button type="button" onClick={() => setIsGlobalPaymentOpen(true)} className="w-full py-2 bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 font-bold rounded-xl border border-emerald-500/50 transition-all flex items-center justify-center gap-2">
                                                    <DollarSign className="w-4 h-4" /> Distribuir Pago Global
                                                </button>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {invoiceId && (
                        <div className="bg-white dark:bg-zinc-900 p-6 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm mt-8">
                            <div className="flex items-center justify-between mb-4">
                                <h3 className="text-sm font-bold flex items-center gap-2 dark:text-white">
                                    <Paperclip className="w-4 h-4 text-blue-500" />
                                    Adjuntos
                                </h3>
                                <label className="cursor-pointer bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 px-3 py-1.5 rounded-lg text-[10px] font-bold flex items-center gap-1.5 transition-all hover:bg-blue-100">
                                    {uploadingAttachment ? <Loader2 className="animate-spin w-3 h-3" /> : <Plus className="w-3 h-3" />}
                                    Cargar
                                    <input type="file" className="hidden" onChange={handleUploadAttachment} disabled={uploadingAttachment} />
                                </label>
                            </div>

                            {attachments.length === 0 ? (
                                <div className="text-center py-6 border border-dashed border-zinc-100 dark:border-zinc-800 rounded-2xl">
                                    <FileText className="w-8 h-8 text-zinc-200 dark:text-zinc-800 mx-auto mb-2" />
                                    <p className="text-zinc-400 text-[10px]">Sin documentos.</p>
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {attachments.map((att) => (
                                        <div key={att.id} className="flex items-center justify-between p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl border border-zinc-100 dark:border-zinc-800 group">
                                            <div className="flex items-center gap-2 overflow-hidden flex-1">
                                                <FileText className="w-4 h-4 text-blue-500 shrink-0" />
                                                <div className="overflow-hidden">
                                                    <p className="text-[11px] font-bold truncate dark:text-white" title={att.fileName}>{att.fileName}</p>
                                                    <p className="text-[9px] text-zinc-400">{(att.fileSize / 1024).toFixed(0)} KB</p>
                                                </div>
                                            </div>
                                            <div className="flex gap-1 ml-2">
                                                <button
                                                    type="button"
                                                    onClick={() => handleDownloadAttachment(att)}
                                                    className="p-1.5 hover:bg-zinc-200 dark:hover:bg-zinc-700 rounded-md text-zinc-500 dark:text-zinc-400"
                                                >
                                                    <Download className="w-3.5 h-3.5" />
                                                </button>
                                                <button
                                                    type="button"
                                                    onClick={() => handleDeleteAttachment(att.id)}
                                                    className="p-1.5 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-md text-red-400"
                                                >
                                                    <X className="w-3.5 h-3.5" />
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    )}
                </div>
            </div>
        </form>
            <GlobalPaymentModal isOpen={isGlobalPaymentOpen} onClose={() => setIsGlobalPaymentOpen(false)} totalAmount={total} onApplyPayment={applyGlobalPayment} creditCards={data.creditCards || []} paymentsList={data.payments || []} />
            <SearchBookingModal isOpen={isSearchBookingOpen} onClose={() => setIsSearchBookingOpen(false)} onSelectBooking={handleImportBooking} />
            
            {/* Modal Popover de Validación de Resolución DIAN */}
            <AnimatePresence>
                {resolutionModalOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl p-8 max-w-lg w-full shadow-2xl space-y-6"
                        >
                            <div className="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-4">
                                <div className="flex items-center gap-3">
                                    <div className="p-3 bg-blue-50 dark:bg-blue-950/50 text-blue-600 rounded-2xl">
                                        <FileText className="w-6 h-6" />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-bold text-zinc-900 dark:text-white">Resolución de Documentos</h3>
                                        <p className="text-xs text-zinc-500 font-medium">Información DIAN de la Sucursal / Implante</p>
                                    </div>
                                </div>
                                <button
                                    onClick={() => setResolutionModalOpen(false)}
                                    className="p-2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 rounded-xl hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-all"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>

                            {loadingResolution ? (
                                <div className="flex flex-col items-center justify-center py-12 text-zinc-400 gap-3">
                                    <Loader2 className="animate-spin w-8 h-8 text-blue-600" />
                                    <span className="text-sm font-medium">Consultando resolución activa...</span>
                                </div>
                            ) : activeResolutionInfo ? (
                                <div className="space-y-4 text-sm">
                                    <div className="p-4 bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800/50 rounded-2xl flex items-center justify-between">
                                        <div className="flex items-center gap-2 text-emerald-700 dark:text-emerald-400 font-bold">
                                            <CheckCircle2 className="w-5 h-5" />
                                            <span>Resolución Vigente y Activa</span>
                                        </div>
                                        <span className="px-2.5 py-1 bg-emerald-100 dark:bg-emerald-900/60 text-emerald-800 dark:text-emerald-300 text-[10px] font-black rounded-lg uppercase tracking-wider">
                                            {activeResolutionInfo.prefix || 'Sin Prefijo'}
                                        </span>
                                    </div>

                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="p-3.5 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl">
                                            <span className="text-xs text-zinc-400 font-semibold uppercase block">N° Resolución</span>
                                            <span className="text-base font-black text-zinc-900 dark:text-white font-mono">{activeResolutionInfo.resolutionNumber || '-'}</span>
                                        </div>
                                        <div className="p-3.5 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl">
                                            <span className="text-xs text-zinc-400 font-semibold uppercase block">Prefijo</span>
                                            <span className="text-base font-black text-blue-600 dark:text-blue-400 font-mono">{activeResolutionInfo.prefix || '-'}</span>
                                        </div>
                                        <div className="p-3.5 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl">
                                            <span className="text-xs text-zinc-400 font-semibold uppercase block">Rango Autorizado</span>
                                            <span className="text-sm font-bold text-zinc-800 dark:text-zinc-200 font-mono">{activeResolutionInfo.initialNumber} al {activeResolutionInfo.finalNumber}</span>
                                        </div>
                                        <div className="p-3.5 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl">
                                            <span className="text-xs text-zinc-400 font-semibold uppercase block">Consecutivo Actual</span>
                                            <span className="text-base font-black text-emerald-600 dark:text-emerald-400 font-mono">{activeResolutionInfo.currentNumber}</span>
                                        </div>
                                        <div className="col-span-2 p-3.5 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl flex items-center justify-between">
                                            <div>
                                                <span className="text-xs text-zinc-400 font-semibold uppercase block">Fecha de Vencimiento</span>
                                                <span className="text-sm font-bold text-zinc-800 dark:text-zinc-200">
                                                    {activeResolutionInfo.expirationDate ? new Date(activeResolutionInfo.expirationDate).toLocaleDateString() : 'Sin fecha'}
                                                </span>
                                            </div>
                                            <div>
                                                <span className="text-xs text-zinc-400 font-semibold uppercase block">Sucursal / Implante</span>
                                                <span className="text-sm font-bold text-zinc-800 dark:text-zinc-200">
                                                    {activeResolutionInfo.branchName || activeResolutionInfo.implantName || 'Global'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ) : (
                                <div className="p-6 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800/50 rounded-2xl space-y-2 text-center">
                                    <div className="flex justify-center text-amber-600">
                                        <AlertTriangle className="w-8 h-8" />
                                    </div>
                                    <h4 className="font-bold text-amber-900 dark:text-amber-300">Sin Resolución Específica Activa</h4>
                                    <p className="text-xs text-amber-700 dark:text-amber-400">
                                        Esta sucursal usará la secuencia por defecto del Maestro de Consecutivos. Puedes configurar una resolución oficial DIAN en Maestros.
                                    </p>
                                </div>
                            )}

                            <div className="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                                <button
                                    type="button"
                                    onClick={() => window.open('/dashboard/settings?tab=resoluciones-documentos', '_blank')}
                                    className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-xs transition-all flex items-center gap-2 cursor-pointer shadow-lg shadow-blue-500/20"
                                >
                                    <ExternalLink className="w-4 h-4" /> Ir a Maestro de Resoluciones
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setResolutionModalOpen(false)}
                                    className="px-5 py-2.5 bg-zinc-100 dark:bg-zinc-800 hover:bg-zinc-200 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-200 rounded-xl font-bold text-xs transition-all"
                                >
                                    Cerrar
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </>
    )
}
