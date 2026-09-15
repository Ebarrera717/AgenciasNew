'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Save, Trash2, Plus, ChevronDown, Calendar, Users, Globe, DollarSign, Briefcase, Hotel as HotelIcon, Tag, Tags, Percent, Calculator, ArrowRight, Loader2, FileDown, Paperclip, FileText, Download, X, Printer, CreditCard, Receipt, Plane, AlertCircle, Send, CheckCircle2 } from 'lucide-react'
import { format, differenceInDays } from 'date-fns'
import { useRouter, useSearchParams } from 'next/navigation'
import { cn } from '@/lib/utils'
import { generateQuotationPDF } from '@/lib/pdf-utils'
import { SearchSelect } from '@/components/SearchSelect'
import ItemPaymentModal from '@/app/dashboard/invoices/new/ItemPaymentModal'
import GlobalPaymentModal from '@/app/dashboard/invoices/new/GlobalPaymentModal'
import QuotationInvoiceModal from '../QuotationInvoiceModal'
import ManualServicesModal, { ManualServiceItem } from './ManualServicesModal'


interface QuotationFormData {
    clientId: string;
    branchId: string;
    implantId: string;
    currency: string;
    exchangeRate: number;
    sellerId: string;
    ticketPrinterId: string;
    commissionPercentage: number;
    comisionTotalPercentage: number;
    comisionFreelancePercentage: number;
    comisionPropiaPercentage: number;
    chargesAndTaxes: number;
    destination?: string;
    startDate?: string;
    endDate?: string;
    passenger?: string;
    paxAdults?: number;
    paxChildren?: number;
    reservationCode?: string;
    copyFieldsToProducts?: boolean;
    manualDescription?: string;
    manualServices?: ManualServiceItem[];
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
        service?: string;
        servicios?: string;
        descripcion?: string;
        passenger?: string;
        passengers: { name: string, document: string }[];
        sellerCommission: number;
        ticketPrinterCommission: number;
        mainTaxId?: number;
        appliedTaxes: { id?: number, name?: string, amount: number }[],
        variables: { id?: number, masterVariableId: number, value: string }[];
        payments?: { amount: number, paymentMethod: string, date: string, reference: string, creditCardId?: number, cardNumber?: string, authorizationCode?: string, voucher?: string, expirationDate?: string }[];
        isPaymentModalOpen?: boolean;
        comboId?: number;
        inNationality?: number;
        totalInput?: string;
        _productName?: string;
        _providerName?: string;
        _prestadoraName?: string;
    }[];
    selectedCombos?: { id: number, name: string }[];
    state: string;
    stateDescription?: string;
    stateUpdatedAt?: string | null;
    internalNumber?: string;
}

const formatMoney = (val: any, decimals: number = 2) => {
    if (val === null || val === undefined || val === '') return '';
    const num = parseFloat(val);
    if (isNaN(num)) return '';
    return num.toLocaleString('es-CO', { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
};

const getStateColorClass = (stateName: string, statesList: any[]) => {
    const stateObj = (statesList || []).find((s: any) => s.code === stateName || s.name === stateName);
    const color = stateObj?.color?.toLowerCase() || 'blue';
    
    if (color === 'emerald' || color === 'green') {
        return "bg-emerald-50/50 dark:bg-emerald-500/5 border-emerald-200 dark:border-emerald-500/20 text-emerald-600 dark:text-emerald-400 focus:ring-emerald-500";
    }
    if (color === 'red' || color === 'rose') {
        return "bg-red-50/50 dark:bg-red-500/5 border-red-200 dark:border-red-500/20 text-red-600 dark:text-red-400 focus:ring-red-500";
    }
    if (color === 'amber' || color === 'orange' || color === 'yellow') {
        return "bg-amber-50/50 dark:bg-amber-500/5 border-amber-200 dark:border-amber-500/20 text-amber-600 dark:text-amber-400 focus:ring-amber-500";
    }
    if (color === 'purple' || color === 'violet') {
        return "bg-purple-50/50 dark:bg-purple-500/5 border-purple-200 dark:border-purple-500/20 text-purple-600 dark:text-purple-400 focus:ring-purple-500";
    }
    return "bg-blue-50/50 dark:bg-blue-500/5 border-blue-200 dark:border-blue-500/20 text-blue-600 dark:text-blue-400 focus:ring-blue-500";
};

export default function QuotationForm({ quotationId }: { quotationId?: string }) {
    const searchParams = useSearchParams()
    const preQuotationId = searchParams.get('preQuotationId')
    const consecutivoParam = searchParams.get('consecutivo')
    const quotationNoticeParam = searchParams.get('quotationNotice')
    const [noticeResponse, setNoticeResponse] = useState('')
    const [sendingNoticeOnly, setSendingNoticeOnly] = useState(false)
    const [noticeSendSuccess, setNoticeSendSuccess] = useState('')

    const handleSendNoticeOnly = async () => {
        if (!preQuotationId || !noticeResponse.trim()) return
        setSendingNoticeOnly(true)
        setNoticeSendSuccess('')
        try {
            let userObj: any = null
            try {
                const stored = localStorage.getItem('user')
                if (stored) userObj = JSON.parse(stored)
            } catch (e) {}

            const res = await fetch('/api/prequotations', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': userObj?.id?.toString() || '1'
                },
                body: JSON.stringify({
                    preQuotationId: Number(preQuotationId),
                    noticeResponse: noticeResponse.trim()
                })
            })
            const resData = await res.json()
            if (!res.ok) throw new Error(resData.message || 'Error al guardar respuesta')
            setNoticeSendSuccess(resData.message || 'Respuesta / Duda registrada exitosamente en la Pre-Cotización.')
        } catch (err: any) {
            alert(err.message || 'Error guardando respuesta')
        } finally {
            setSendingNoticeOnly(false)
        }
    }

    const [data, setData] = useState<any>(null)
    const [originalState, setOriginalState] = useState('Nuevo')
    const [formData, setFormData] = useState<QuotationFormData>({
        clientId: '',
        branchId: '',
        implantId: '',
        currency: 'USD',
        exchangeRate: 1,
        sellerId: '',
        ticketPrinterId: '',
        commissionPercentage: 10,
        comisionTotalPercentage: 10,
        comisionFreelancePercentage: 0,
        comisionPropiaPercentage: 10,
        chargesAndTaxes: 0,
        destination: '',
        startDate: '',
        endDate: '',
        passenger: '',
        paxAdults: 1,
        paxChildren: 0,
        reservationCode: '',
        copyFieldsToProducts: true,
        manualDescription: '',
        manualServices: [],
        items: [],
        selectedCombos: [],
        state: 'Nuevo',
        stateDescription: '',
        stateUpdatedAt: null,
        internalNumber: ''
    })

    useEffect(() => {
        if (preQuotationId) {
            const cId = searchParams.get('clientId') || ''
            const bId = searchParams.get('branchId') || ''
            const sId = searchParams.get('sellerId') || ''
            const tId = searchParams.get('ticketPrinterId') || ''
            const hDesc = searchParams.get('headerDescription') || ''
            const sDate = searchParams.get('startDate') || ''
            const eDate = searchParams.get('endDate') || ''

            setFormData(prev => ({
                ...prev,
                clientId: cId || prev.clientId,
                branchId: bId || prev.branchId,
                sellerId: sId || prev.sellerId,
                ticketPrinterId: tId || prev.ticketPrinterId,
                manualDescription: hDesc || prev.manualDescription,
                startDate: sDate || prev.startDate,
                endDate: eDate || prev.endDate,
                consecutivo: consecutivoParam || (prev as any).consecutivo
            }))
        }
    }, [preQuotationId])
    const [saving, setSaving] = useState(false)
    const [isInvoiceModalOpen, setIsInvoiceModalOpen] = useState(false)
    const [isGlobalPaymentOpen, setIsGlobalPaymentOpen] = useState(false)
    const [isManualServicesModalOpen, setIsManualServicesModalOpen] = useState(false)
    const [attachments, setAttachments] = useState<any[]>([])
    const [uploadingAttachment, setUploadingAttachment] = useState(false)
    const [focusedTax, setFocusedTax] = useState<{ itemIdx: number, taxId: number, rawValue?: string } | null>(null)
    const [focusedField, setFocusedField] = useState<{ itemIdx?: number, field: string, rawValue?: string } | null>(null)
    const [activeGeneralTab, setActiveGeneralTab] = useState<'info' | 'history'>('info')
    const [stateHistoryList, setStateHistoryList] = useState<any[]>([])
    const router = useRouter()

    const activeCurrency = data?.currencies?.find((c: any) => c.code === formData.currency);
    const decimals = activeCurrency ? (activeCurrency.decimals ?? 2) : 2;

    const handleSave = async (e: React.FormEvent, downloadPdf = false) => {
        e.preventDefault();
        // Synchronously open a blank window if printing, to bypass browser popup blockers
        const printWindow = downloadPdf ? window.open('about:blank', '_blank') : null;
        setSaving(true)
        try {
            const calculatedComisionPropia = showTotals
                ? porcentajeComisionUtilidad - (formData.comisionFreelancePercentage || 0)
                : (formData.comisionTotalPercentage || 0) - (formData.comisionFreelancePercentage || 0);

            const selectedBranch = data?.branches?.find((b: any) => String(b.id) === String(formData.branchId));
            const selectedSeller = data?.sellers?.find((s: any) => String(s.id) === String(formData.sellerId));
            const selectedImplant = data?.implants?.find((i: any) => String(i.id) === String(formData.implantId));
            const selectedPrinter = data?.ticketPrinters?.find((t: any) => String(t.id) === String(formData.ticketPrinterId));
            const selectedClient = data?.clients?.find((c: any) => String(c.id) === String(formData.clientId));

            const payload = {
                ...formData,
                comisionPropiaPercentage: calculatedComisionPropia,
                commissionPercentage: calculatedComisionPropia,
                clientId: formData.clientId || null,
                clientDocument: selectedClient?.document || null,
                branchId: formData.branchId || null,
                branchCode: selectedBranch?.code || null,
                implantId: formData.implantId || null,
                implantCode: selectedImplant?.code || null,
                sellerId: formData.sellerId || null,
                sellerCode: selectedSeller?.code || null,
                ticketPrinterId: formData.ticketPrinterId || null,
                ticketPrinterCode: selectedPrinter?.code || null,
                totalAmount: total,
                combos: (formData.selectedCombos || []).map(c => ({ comboId: c.id })),
                items: formData.items.map(item => {
                    const taxes: any[] = [];

                    const defaultMainTax = data?.taxes?.find((t: any) => t.type === 'PRINCIPAL' || t.code === 'TAR' || t.name?.toUpperCase().includes('TARIFA'));
                    const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : (defaultMainTax ? Number(defaultMainTax.id) : null);

                    // Add main tax if exists
                    if (mainTaxIdNum != null) {
                        const mainTaxEntryInApplied = (item.appliedTaxes || []).find((t: any) => Number(t.id || t.chargeAndTaxId) === mainTaxIdNum);
                        const amount = mainTaxEntryInApplied?.amount ?? ((item.price || 0) * (item.quantity || 1));
                        taxes.push({ chargeAndTaxId: mainTaxIdNum, explicitAmount: amount });
                    }

                    // Add secondary taxes
                    (item.appliedTaxes || []).forEach((t: any) => {
                        const taxId = Number(t.id || t.chargeAndTaxId);
                        if (taxId && taxId !== mainTaxIdNum) {
                            taxes.push({ chargeAndTaxId: taxId, explicitAmount: t.amount });
                        }
                    });

                    const selProd = data?.products?.find((p: any) => String(p.id) === String(item.productId));
                    const selProv = data?.providers?.find((p: any) => String(p.id) === String(item.providerId));
                    const selPrest = data?.prestadoras?.find((p: any) => String(p.id) === String(item.prestadoraId));

                    return {
                        ...item,
                        productId: item.productId || null,
                        productCode: selProd?.code || null,
                        providerId: item.providerId || null,
                        providerCode: selProv?.code || null,
                        prestadoraId: item.prestadoraId || null,
                        prestadoraCode: selPrest?.code || null,
                        cost: item.cost || 0,
                        service: item.service || item.servicios || '',
                        servicios: item.servicios || item.service || '',
                        payments: Array.isArray(item.payments) ? item.payments : [],
                        appliedTaxes: taxes,
                        variables: item.variables || []
                    };
                })
            }

            const endpoint = quotationId ? `/api/quotations/${quotationId}` : '/api/quotations';
            const method = quotationId ? 'PUT' : 'POST';
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');

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

            if (preQuotationId && result.quotation?.id) {
                try {
                    await fetch('/api/prequotations', {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-User-Id': loggedUser.id?.toString() || ''
                        },
                        body: JSON.stringify({
                            preQuotationId: Number(preQuotationId),
                            quotationId: result.quotation.id,
                            noticeResponse
                        })
                    })
                } catch (errPre) {
                    console.error('Error actualizando estado de pre-cotización:', errPre)
                }
            }

            if (downloadPdf && printWindow) {
                try {
                    const targetId = result.quotation?.id || quotationId;
                    if (targetId) {
                        printWindow.location.href = `/dashboard/quotations/print?idIni=${targetId}&idFin=${targetId}`;
                    } else {
                        printWindow.close();
                    }
                } catch (printErr) {
                    console.error('Error opening print page:', printErr);
                    printWindow.close();
                }
            } else {
                if (printWindow) printWindow.close();
                const successMessage = result.message || 'Cotización guardada exitosamente';
                alert(successMessage);
            }

            router.push('/dashboard')
        } catch (err: any) {
            if (printWindow) {
                try { printWindow.close(); } catch (e) {}
            }
            console.error(err)
            alert(err.message || 'Ocurrió un error al guardar la cotización')
        } finally {
            setSaving(false)
        }
    }

    const fetchAttachments = async () => {
        if (!quotationId) return
        try {
            const res = await fetch(`/api/quotations/${quotationId}/attachments`)
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
        if (!file || !quotationId) return

        setUploadingAttachment(true)
        try {
            const reader = new FileReader()
            reader.readAsDataURL(file)
            reader.onload = async () => {
                const base64 = reader.result as string
                const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
                const res = await fetch(`/api/quotations/${quotationId}/attachments`, {
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
            const res = await fetch(`/api/quotations/${quotationId}/attachments?attachmentId=${id}`, {
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

    // Get unique taxes that have been applied anywhere, and sum their amounts (redirecting taxes with targetTaxId)
    const taxSummary = React.useMemo(() => {
        const summary: Record<string, number> = {}
        if (!data?.taxes) return summary;

        const defaultMainTax = data.taxes.find((t: any) => t.type === 'PRINCIPAL' || t.code === 'TAR' || t.name?.toUpperCase().includes('TARIFA'));

        formData.items.forEach(item => {
            const itemTaxesMap = new Map<number, number>();

            // 1. Incluir el cargo principal (TARIFA) basado en el precio total del ítem
            const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : (defaultMainTax ? Number(defaultMainTax.id) : null);
            const mainTaxAmt = (item.price || 0) * (item.quantity || 1);
            if (mainTaxIdNum != null) {
                itemTaxesMap.set(mainTaxIdNum, mainTaxAmt);
            }

            // 2. Incluir/Sobrescribir desde el arreglo de cargos e impuestos adicionales (appliedTaxes)
            (item.appliedTaxes || []).forEach(tax => {
                const rawTaxId = (tax as any).id ?? (tax as any).chargeAndTaxId;
                const taxId = rawTaxId != null ? Number(rawTaxId) : null;
                if (taxId != null) {
                    const amt = Number(tax.amount || 0);
                    if (taxId === mainTaxIdNum && amt === 0 && mainTaxAmt > 0) {
                        itemTaxesMap.set(taxId, mainTaxAmt);
                    } else {
                        itemTaxesMap.set(taxId, amt);
                    }
                }
            });

            // 3. Agrupar por nombre de cargo maestro con soporte de redirección por targetTaxId
            itemTaxesMap.forEach((amount, taxId) => {
                let master = data.taxes.find((t: any) => Number(t.id) === taxId);

                if (master && master.targetTaxId) {
                    const targetMaster = data.taxes.find((t: any) => Number(t.id) === Number(master.targetTaxId));
                    if (targetMaster) {
                        master = targetMaster;
                    }
                }

                const name = master ? master.name : 'Otros';
                summary[name] = (summary[name] || 0) + amount;
            });
        });
        return summary;
    }, [formData.items, data?.taxes]);

    const total = Object.values(taxSummary).reduce((sum, val) => sum + val, 0);

    const showTotals = data?.showTotals ?? true;
    const costoTotal = formData.items.reduce((sum, item) => sum + (item.cost || 0), 0);
    const valorBase = React.useMemo(() => {
        let baseSum = 0;
        formData.items.forEach(item => {
            let itemBase = (item.price || 0) * (item.quantity || 1);
            (item.appliedTaxes || []).forEach((tax: any) => {
                const rawTaxId = tax.id ?? tax.chargeAndTaxId;
                const taxId = rawTaxId != null ? Number(rawTaxId) : null;
                const master = data?.taxes?.find((t: any) => Number(t.id) === taxId);
                if (master && master.targetTaxId) {
                    const targetMaster = data?.taxes?.find((t: any) => Number(t.id) === Number(master.targetTaxId));
                    if (targetMaster && (targetMaster.type === 'PRINCIPAL' || targetMaster.isEditable === false || targetMaster.code === 'TAR' || targetMaster.name?.toUpperCase().includes('TARIFA') || Number(targetMaster.id) === Number(item.mainTaxId))) {
                        itemBase += Number(tax.amount || 0);
                    }
                }
            });
            baseSum += itemBase;
        });
        return baseSum;
    }, [formData.items, data?.taxes]);
    const utilidad = valorBase - costoTotal;
    const porcentajeComisionUtilidad = valorBase > 0 ? parseFloat(((utilidad / valorBase) * 100).toFixed(2)) : 0;
    const comisionPropiaPercentage = showTotals
        ? porcentajeComisionUtilidad - (formData.comisionFreelancePercentage || 0)
        : (formData.comisionTotalPercentage || 0) - (formData.comisionFreelancePercentage || 0);
    const comisionFreelanceValue = ((formData.comisionFreelancePercentage || 0) / 100) * valorBase;
    const comisionPropiaValue = (comisionPropiaPercentage / 100) * valorBase;

    const applyGlobalPayment = (amount: number, method: string, date: string, reference: string, ccData?: any) => {
        const newItems = [...formData.items];
        
        const getItemTotal = (item: any) => {
            const taxesTotal = (item.appliedTaxes || []).reduce((acc: number, t: any) => acc + (t.amount || 0), 0);
            return taxesTotal || (item.price || 0) * (item.quantity || 1);
        };
        
        const totalValue = newItems.reduce((acc, item) => acc + getItemTotal(item), 0);
        
        if (totalValue === 0) {
            const equalShare = amount / newItems.length;
            newItems.forEach(item => {
                const updatedPayments = [...(item.payments || [])];
                updatedPayments.push({
                    amount: parseFloat(equalShare.toFixed(decimals)),
                    paymentMethod: method,
                    date,
                    reference,
                    ...ccData
                });
                item.payments = updatedPayments;
            });
        } else {
            let distributedSum = 0;
            newItems.forEach((item, idx) => {
                const updatedPayments = [...(item.payments || [])];
                const itemTotal = getItemTotal(item);
                
                let itemShare = 0;
                if (idx === newItems.length - 1) {
                    itemShare = amount - distributedSum;
                } else {
                    itemShare = parseFloat((amount * (itemTotal / totalValue)).toFixed(decimals));
                    distributedSum += itemShare;
                }
                
                updatedPayments.push({
                    amount: itemShare,
                    paymentMethod: method,
                    date,
                    reference,
                    ...ccData
                });
                item.payments = updatedPayments;
            });
        }
        
        setFormData({ ...formData, items: newItems });
        alert('Pago global distribuido proporcionalmente con éxito.');
    };

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
                const baseRes = await fetch('/api/quotations/base-data', {
                    headers: { 'X-User-Id': loggedUserCache.id?.toString() || '' }
                })
                const baseData = await baseRes.json()
                if (baseRes.ok && baseData?.clients) {
                    setData(baseData)
                } else {
                    setData({ clients: [], providers: [], prestadoras: [], branches: [], implants: [], products: [], taxes: [], sellers: [], ticketPrinters: [], variables: [], combos: [], quotationStates: [] })
                }

                if (!quotationId) {
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

                if (quotationId) {
                    fetchAttachments()
                    let qRes = await fetch(`/api/quotations/${quotationId}`)
                    if (!qRes.ok) {
                        // Fallback to fn-cotizacion endpoint
                        qRes = await fetch(`/api/quotations/${quotationId}/fn-cotizacion`)
                    }

                    if (qRes.ok) {
                        const qData = await qRes.json()
                        setOriginalState(qData.state || 'Nuevo')
                        setStateHistoryList(qData.stateHistory || [])
                        setData((prev: any) => ({
                            ...prev,
                            clients: qData.client ? [...(prev?.clients || []).filter((c: any) => String(c.id) !== String(qData.client.id)), qData.client] : prev?.clients,
                            sellers: qData.seller ? [...(prev?.sellers || []).filter((s: any) => String(s.id) !== String(qData.seller.id)), qData.seller] : prev?.sellers,
                            branches: qData.branch ? [...(prev?.branches || []).filter((b: any) => String(b.id) !== String(qData.branch.id)), qData.branch] : prev?.branches,
                            implants: qData.implant ? [...(prev?.implants || []).filter((i: any) => String(i.id) !== String(qData.implant.id)), qData.implant] : prev?.implants,
                            ticketPrinters: qData.ticketPrinter ? [...(prev?.ticketPrinters || []).filter((t: any) => String(t.id) !== String(qData.ticketPrinter.id)), qData.ticketPrinter] : prev?.ticketPrinters
                        }));
                        setFormData({
                            clientId: qData.clientId?.toString() || '',
                            branchId: qData.branchId?.toString() || '',
                            implantId: qData.implantId?.toString() || '',
                            currency: qData.currency || 'USD',
                            exchangeRate: qData.exchangeRate,
                            sellerId: qData.sellerId?.toString() || '',
                            ticketPrinterId: qData.ticketPrinterId?.toString() || '',
                            commissionPercentage: qData.comisionPropiaPercentage ?? qData.commissionPercentage ?? 0,
                            comisionTotalPercentage: qData.comisionTotalPercentage ?? qData.commissionPercentage ?? 10,
                            comisionFreelancePercentage: qData.comisionFreelancePercentage ?? 0,
                            comisionPropiaPercentage: qData.comisionPropiaPercentage ?? qData.commissionPercentage ?? 10,
                            chargesAndTaxes: qData.chargesAndTaxes || 0,
                            destination: qData.destination || '',
                            startDate: qData.startDate ? new Date(qData.startDate).toISOString().split('T')[0] : '',
                            endDate: qData.endDate ? new Date(qData.endDate).toISOString().split('T')[0] : '',
                            passenger: qData.passenger || '',
                            paxAdults: qData.paxAdults ?? 1,
                            paxChildren: qData.paxChildren ?? 0,
                            reservationCode: qData.reservationCode || '',
                            copyFieldsToProducts: qData.copyFieldsToProducts ?? true,
                            manualDescription: qData.manualDescription || '',
                            manualServices: qData.manualServices || [],
                            state: qData.state || 'Nuevo',
                            stateDescription: qData.stateDescription || '',
                            stateUpdatedAt: qData.stateUpdatedAt || null,
                            internalNumber: qData.internalNumber || '',
                            items: (qData.products || []).map((p: any) => {
                                const safeAppliedTaxes = Array.isArray(p.appliedTaxes) ? p.appliedTaxes : [];
                                const safeVariables = Array.isArray(p.variables) ? p.variables : [];

                                const mainTaxId = p.mainTaxId;

                                // Inferir el precio desde el monto del cargo principal guardado o primera tarifa
                                const mainTaxEntry = safeAppliedTaxes.find((t: any) => Number(t.chargeAndTaxId || t.id) === Number(mainTaxId));
                                let inferredPrice = p.price;
                                if (mainTaxEntry) {
                                    const taxVal = mainTaxEntry.explicitAmount ?? mainTaxEntry.amount;
                                    if (taxVal != null && taxVal > 0) {
                                        inferredPrice = taxVal / (p.quantity || 1);
                                    }
                                } else if ((!inferredPrice || inferredPrice === 0) && safeAppliedTaxes.length > 0) {
                                    const firstTax = safeAppliedTaxes[0];
                                    const taxVal = firstTax.explicitAmount ?? firstTax.amount;
                                    if (taxVal != null && taxVal > 0) {
                                        inferredPrice = taxVal / (p.quantity || 1);
                                    }
                                }

                                // Usar el costo exacto guardado sin realizar divisiones ni calculos
                                const inferredCost = p.cost || 0;

                                return {
                                    productId: p.productId?.toString() || '',
                                    quantity: p.quantity,
                                    price: inferredPrice,
                                    cost: inferredCost,
                                    providerId: p.providerId?.toString() || '',
                                    prestadoraId: p.prestadoraId?.toString() || '',
                                    checkIn: p.checkInDate ? new Date(p.checkInDate).toISOString().split('T')[0] : '',
                                    checkOut: p.checkOutDate ? new Date(p.checkOutDate).toISOString().split('T')[0] : '',
                                    paxAdults: p.paxAdults || 1,
                                    paxChildren: p.paxChildren || 0,
                                    destination: p.destination || '',
                                    serviceType: p.serviceType || '',
                                    reservationCode: p.reservationCode || '',
                                    service: p.service || p.servicios || '',
                                    servicios: p.servicios || p.service || '',
                                    descripcion: p.descripcion || '',
                                    passenger: p.passenger || '',
                                    passengers: Array.isArray(p.passengers) ? p.passengers : [],
                                    payments: Array.isArray(p.payments) ? p.payments : [],
                                    sellerCommission: p.sellerCommission || 0,
                                    ticketPrinterCommission: p.ticketPrinterCommission || 0,
                                    mainTaxId,
                                    inNationality: p.inNationality || 1,
                                    // Info extra para renderizado si el maestro no carga a tiempo
                                    _productName: p.product?.description,
                                    _providerName: p.provider?.name,
                                    _prestadoraName: p.prestadora?.name,
                                    appliedTaxes: safeAppliedTaxes.map((t: any) => ({
                                        id: t.chargeAndTaxId || t.id,
                                        chargeAndTaxId: t.chargeAndTaxId || t.id,
                                        amount: t.explicitAmount ?? t.amount ?? 0
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
                console.error("Failed to load generic or quotation data", err);
                setData({ clients: [], providers: [], prestadoras: [], branches: [], implants: [], products: [], taxes: [], sellers: [], ticketPrinters: [], variables: [], combos: [], quotationStates: [] })
            }
        }
        loadInitialData()
    }, [quotationId])

    const updateHeaderField = (field: keyof QuotationFormData, value: any) => {
        setFormData(prev => {
            const nextState = { ...prev, [field]: value };
            const copyFields = nextState.copyFieldsToProducts !== false;
            
            if (copyFields) {
                const mapHeaderToProduct: Record<string, string> = {
                    destination: 'destination',
                    startDate: 'checkIn',
                    endDate: 'checkOut',
                    passenger: 'passenger',
                    paxAdults: 'paxAdults',
                    paxChildren: 'paxChildren',
                    reservationCode: 'reservationCode',
                    manualDescription: 'descripcion',
                };
                
                if (mapHeaderToProduct[field]) {
                    const prodField = mapHeaderToProduct[field];
                    nextState.items = nextState.items.map(item => ({
                        ...item,
                        [prodField]: value
                    }));
                } else if (field === 'copyFieldsToProducts' && value === true) {
                    nextState.items = nextState.items.map(item => ({
                        ...item,
                        destination: nextState.destination || item.destination,
                        checkIn: nextState.startDate || item.checkIn,
                        checkOut: nextState.endDate || item.checkOut,
                        passenger: nextState.passenger || item.passenger,
                        paxAdults: nextState.paxAdults !== undefined ? nextState.paxAdults : item.paxAdults,
                        paxChildren: nextState.paxChildren !== undefined ? nextState.paxChildren : item.paxChildren,
                        reservationCode: nextState.reservationCode || item.reservationCode,
                        descripcion: nextState.manualDescription || item.descripcion,
                    }));
                }
            }
            return nextState;
        });
    };

    const addItem = () => {
        const copyFields = formData.copyFieldsToProducts !== false;
        setFormData({
            ...formData,
            items: [...formData.items, {
                productId: '', quantity: 1, price: 0, cost: 0,
                providerId: '', prestadoraId: '', 
                checkIn: copyFields && formData.startDate ? formData.startDate : '', 
                checkOut: copyFields && formData.endDate ? formData.endDate : '',
                paxAdults: copyFields && formData.paxAdults !== undefined ? formData.paxAdults : 1, 
                paxChildren: copyFields && formData.paxChildren !== undefined ? formData.paxChildren : 0, 
                destination: copyFields && formData.destination ? formData.destination : '', 
                serviceType: '', 
                reservationCode: copyFields && formData.reservationCode ? formData.reservationCode : '', 
                descripcion: copyFields && formData.manualDescription ? formData.manualDescription : '', 
                passenger: copyFields && formData.passenger ? formData.passenger : '',
                passengers: [{ name: '', document: '' }],
                sellerCommission: 0, ticketPrinterCommission: 0,
                appliedTaxes: [],
                variables: [],
                inNationality: 1,
                totalInput: ''
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

        const alreadyIn = formData.selectedCombos?.find(c => c.id === comboId);
        if (alreadyIn) {
            alert("Este combo ya ha sido agregado.");
            return;
        }

        const newItemsFromCombo = combo.products.map((cp: any) => {
            const mainTaxId: number | undefined = cp.mainTaxId || undefined;
            const appliedTaxes = (cp.appliedTaxes || []).map((t: any) => ({
                id: t.chargeAndTaxId,
                amount: t.amount
            }));

            const copyFields = formData.copyFieldsToProducts !== false;
            return {
                productId: cp.productId.toString(),
                quantity: 1,
                price: cp.price,
                cost: cp.product?.cost || 0,
                providerId: cp.providerId?.toString() || '',
                prestadoraId: cp.prestadoraId?.toString() || '',
                checkIn: (copyFields && formData.startDate) ? formData.startDate : (cp.checkInDate ? new Date(cp.checkInDate).toISOString().split('T')[0] : ''),
                checkOut: (copyFields && formData.endDate) ? formData.endDate : (cp.checkOutDate ? new Date(cp.checkOutDate).toISOString().split('T')[0] : ''),
                paxAdults: (copyFields && formData.paxAdults !== undefined) ? formData.paxAdults : (cp.paxAdults || 1),
                paxChildren: (copyFields && formData.paxChildren !== undefined) ? formData.paxChildren : (cp.paxChildren || 0),
                destination: (copyFields && formData.destination) ? formData.destination : '',
                serviceType: '',
                reservationCode: (copyFields && formData.reservationCode) ? formData.reservationCode : '',
                descripcion: copyFields && formData.manualDescription ? formData.manualDescription : '',
                passenger: (copyFields && formData.passenger) ? formData.passenger : '',
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
        <form onSubmit={handleSave} className="max-w-6xl mx-auto space-y-8 pb-20">
            
            {/* Banner de Aviso Prominente de Pre-Cotización */}
            {preQuotationId && (
                <div className="bg-amber-950/40 border-2 border-amber-500/50 p-6 rounded-3xl space-y-4 shadow-2xl backdrop-blur-md">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <div className="p-2.5 bg-amber-500/20 rounded-xl text-amber-400 border border-amber-500/30">
                                <AlertCircle className="w-6 h-6 animate-pulse" />
                            </div>
                            <div>
                                <h3 className="text-base font-bold text-amber-300">
                                    AVISO ESPECIAL PROVENIENTE DE PRE-COTIZACIÓN #{consecutivoParam}
                                </h3>
                                <p className="text-xs text-amber-200/80">
                                    Por favor lea las instrucciones del solicitante e ingrese su respuesta antes de guardar la cotización.
                                </p>
                            </div>
                        </div>
                        <span className="px-3 py-1 bg-amber-500/20 border border-amber-500/40 text-amber-300 font-mono font-bold rounded-lg text-xs">
                            Pre-Cotización #{consecutivoParam}
                        </span>
                    </div>

                    {quotationNoticeParam && (
                        <div className="bg-slate-950/80 p-4 rounded-2xl border border-amber-500/30 text-xs text-amber-100 leading-relaxed font-medium">
                            <span className="text-amber-400 font-bold block mb-1">Mensaje de Aviso del Solicitante:</span>
                            {quotationNoticeParam}
                        </div>
                    )}

                    <div className="space-y-2 pt-1">
                        <label className="text-xs font-bold text-amber-300">Respuesta al Aviso / Registro de Duda (Pre-Cotización):</label>
                        <div className="flex flex-col sm:flex-row gap-2">
                            <input
                                type="text"
                                value={noticeResponse}
                                onChange={e => {
                                    setNoticeResponse(e.target.value)
                                    setNoticeSendSuccess('')
                                }}
                                placeholder="Escriba su respuesta aclaratoria o duda (ej. 'No hay cupo en ese hotel, ¿desea cotizar Sol Caribe?')..."
                                className="flex-1 bg-slate-950 border border-amber-500/50 rounded-xl p-3 text-xs text-white placeholder:text-slate-500 focus:ring-2 focus:ring-amber-500 outline-none"
                            />
                            <button
                                type="button"
                                onClick={handleSendNoticeOnly}
                                disabled={sendingNoticeOnly || !noticeResponse.trim()}
                                className="px-5 py-2.5 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-zinc-950 font-extrabold rounded-xl text-xs shrink-0 flex items-center justify-center gap-2 transition-all shadow-md cursor-pointer active:scale-95"
                            >
                                {sendingNoticeOnly ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
                                <span>Enviar Respuesta / Duda</span>
                            </button>
                        </div>
                        {noticeSendSuccess && (
                            <div className="p-3 bg-emerald-500/20 border border-emerald-500/40 rounded-xl text-xs font-bold text-emerald-300 flex items-center gap-2 mt-2">
                                <CheckCircle2 className="w-4 h-4 shrink-0" />
                                <span>{noticeSendSuccess}</span>
                            </div>
                        )}
                    </div>
                </div>
            )}

            <div className="flex items-center justify-between bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <div>
                    <h2 className="text-2xl font-bold dark:text-white">
                        {quotationId ? `Cotización #${quotationId}` : 'Generar Cotización'}
                    </h2>
                    <p className="text-zinc-500 text-sm mt-1">Completa los detalles para tu cliente</p>
                </div>
                <div className="flex gap-3">
                    <button
                        type="button"
                        onClick={() => router.push('/dashboard')}
                        className="px-6 py-3 border border-zinc-200 dark:border-zinc-700 rounded-xl font-bold text-zinc-600 hover:bg-zinc-50 transition-all flex items-center gap-2"
                    >
                        Cancelar
                    </button>
                    {quotationId && (
                        <button
                            type="button"
                            onClick={() => setIsInvoiceModalOpen(true)}
                            className="px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold shadow-lg shadow-emerald-500/20 transition-all flex items-center gap-2"
                            title="Facturar Cotización"
                        >
                            <Receipt className="w-5 h-5" />
                            Facturar
                        </button>
                    )}
                    <button
                        type="button"
                        onClick={(e) => handleSave(e as any, true)}
                        disabled={saving}
                        className="px-6 py-3 bg-zinc-800 hover:bg-zinc-700 text-white rounded-xl font-bold shadow-lg transition-all flex items-center gap-2 disabled:opacity-50"
                        title="Imprimir Cotización"
                    >
                        <Printer className="w-5 h-5" />
                        Imprimir
                    </button>
                    <button
                        type="submit"
                        disabled={saving}
                        className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg shadow-blue-500/20 transition-all flex items-center gap-2 disabled:opacity-50"
                    >
                        {saving ? <Loader2 className="animate-spin w-5 h-5" /> : <Save className="w-5 h-5" />}
                        {saving ? 'Guardando...' : 'Guardar'}
                    </button>
                </div>
            </div>
            <QuotationInvoiceModal
                isOpen={isInvoiceModalOpen}
                onClose={() => setIsInvoiceModalOpen(false)}
                quotationId={quotationId ? parseInt(quotationId) : null}
            />

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Core Details */}
                <div className="lg:col-span-2 space-y-8">

                    {/* Section: Client & Origin */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm space-y-6">
                        <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-4 gap-4">
                            <div className="flex items-center gap-4">
                                <h3 className="text-lg font-bold flex items-center gap-2 dark:text-white">
                                    <Users className="w-5 h-5 text-blue-500" />
                                    Cliente y Origen
                                </h3>
                                {quotationId && (
                                    <div className="flex bg-zinc-100 dark:bg-zinc-800 p-1 rounded-xl">
                                        <button
                                            type="button"
                                            onClick={() => setActiveGeneralTab('info')}
                                            className={cn(
                                                "px-3 py-1.5 rounded-lg text-[10px] font-bold transition-all",
                                                activeGeneralTab === 'info'
                                                    ? "bg-white dark:bg-zinc-700 shadow-sm text-blue-600 dark:text-white"
                                                    : "text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-300"
                                            )}
                                        >
                                            Datos
                                        </button>
                                        <button
                                            type="button"
                                            onClick={() => setActiveGeneralTab('history')}
                                            className={cn(
                                                "px-3 py-1.5 rounded-lg text-[10px] font-bold transition-all",
                                                activeGeneralTab === 'history'
                                                    ? "bg-white dark:bg-zinc-700 shadow-sm text-blue-600 dark:text-white"
                                                    : "text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-300"
                                            )}
                                        >
                                            Historial ({stateHistoryList.length})
                                        </button>
                                    </div>
                                )}
                            </div>
                            {formData.internalNumber && (
                                <span className="text-xs font-black bg-zinc-100 dark:bg-zinc-800 px-3 py-1.5 rounded-xl text-zinc-500 tracking-wider self-start sm:self-auto">
                                    {formData.internalNumber}
                                </span>
                            )}
                        </div>

                        {activeGeneralTab === 'info' ? (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-zinc-500">Cliente</label>
                                    <SearchSelect
                                        options={data.clients}
                                        value={formData.clientId}
                                        onChange={async (val, opt) => {
                                            let selectedC = opt || data.clients?.find((c: any) => String(c.id) === String(val));
                                            if ((!selectedC || selectedC.sellerId === undefined) && val) {
                                                try {
                                                    const res = await fetch(`/api/clients?id=${encodeURIComponent(val)}`);
                                                    if (res.ok) {
                                                        const clientData = await res.json();
                                                        if (clientData && !clientData.message) {
                                                            selectedC = clientData;
                                                        }
                                                    }
                                                } catch (err) {
                                                    console.error("Error fetching client seller:", err);
                                                }
                                            }
                                            const sellerIdToSet = selectedC?.sellerId ? String(selectedC.sellerId) : '';
                                            setFormData(prev => ({
                                                ...prev,
                                                clientId: val,
                                                sellerId: sellerIdToSet || prev.sellerId
                                            }));
                                        }}
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
                                        placeholder="Seleccionar Vendedor"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-zinc-500">Sucursal</label>
                                    <SearchSelect
                                        options={data.branches}
                                        value={formData.branchId}
                                        onChange={(val) => setFormData({ ...formData, branchId: val, implantId: '' })}
                                        placeholder="Sel. Sucursal"
                                        secondaryKey="code"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-zinc-500">Implant</label>
                                    <SearchSelect
                                        options={data.implants.filter((i: any) => i.branchId?.toString() === formData.branchId)}
                                        value={formData.implantId}
                                        onChange={(val) => setFormData({ ...formData, implantId: val })}
                                        disabled={!formData.branchId}
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
                                        placeholder="Sel. Tiqueteador"
                                        secondaryKey="code"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-zinc-500">Moneda a Cotizar</label>
                                    <select
                                        className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500"
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
                                    <label className="text-sm font-semibold text-zinc-500">
                                        Estado de Cotización {!quotationId && <span className="text-xs text-zinc-400 font-normal">(Bloqueado en Nuevo al crear)</span>}
                                    </label>
                                    <select
                                        disabled={!quotationId}
                                        className={cn(
                                            "w-full h-12 rounded-xl px-4 border outline-none font-bold focus:ring-2 transition-all",
                                            getStateColorClass(formData.state, data.quotationStates),
                                            !quotationId && "opacity-75 cursor-not-allowed bg-zinc-100 dark:bg-zinc-800"
                                        )}
                                        value={formData.state}
                                        onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                                        title={!quotationId ? "El estado es Nuevo al crear una cotización" : undefined}
                                    >
                                        {(data.quotationStates || [
                                            { code: 'NUEVO', name: 'Nuevo' },
                                            { code: 'ENVIADO', name: 'ENVIADO' }
                                        ]).map((s: any) => (
                                            <option key={s.id || s.code} value={s.code}>{s.name.toUpperCase()}</option>
                                        ))}
                                    </select>
                                </div>

                                {formData.state !== originalState && (
                                    <div className="col-span-2 space-y-2">
                                        <label className="text-sm font-semibold text-zinc-500">Descripción del Cambio de Estado</label>
                                        <textarea
                                            className="w-full h-20 rounded-xl p-4 border border-zinc-250 dark:border-zinc-800 outline-none font-semibold focus:ring-2 focus:ring-blue-500 transition-all dark:bg-zinc-900 dark:text-white resize-none text-sm shadow-inner"
                                            value={formData.stateDescription || ''}
                                            onChange={(e) => setFormData({ ...formData, stateDescription: e.target.value })}
                                            placeholder="Escribe la descripción de la actualización del estado..."
                                            required
                                        />
                                    </div>
                                )}

                                {/* Sección: Datos de Viaje en la Cabecera */}
                                <div className="col-span-1 md:col-span-2 border-t border-zinc-100 dark:border-zinc-800 pt-6 mt-6 space-y-6">
                                    <div className="flex flex-col sm:flex-row sm:items-center justify-between pb-2 gap-4">
                                        <h4 className="text-md font-bold flex items-center gap-2 dark:text-white">
                                            <Plane className="w-5 h-5 text-blue-500" />
                                            Información de Viaje (Cabecera)
                                        </h4>
                                        <label className="flex items-center gap-2 text-xs font-bold text-zinc-500 cursor-pointer">
                                            <input 
                                                type="checkbox"
                                                checked={formData.copyFieldsToProducts !== false}
                                                onChange={(e) => updateHeaderField('copyFieldsToProducts', e.target.checked)}
                                                className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500"
                                            />
                                            Copiar campos automáticamente a los productos
                                        </label>
                                    </div>
                                    
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Destino</label>
                                            <SearchSelect
                                                options={data.cities || []}
                                                value={formData.destination || ''}
                                                onChange={(val) => updateHeaderField('destination', val)}
                                                placeholder="Buscar Destino / Ciudad..."
                                                labelKey="name"
                                                secondaryKey="code"
                                                valueKey="name"
                                                remoteSearchEndpoint="/api/config/cities"
                                                allowCustomValue={true}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Reservación / Localizador</label>
                                            <input 
                                                type="text"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.reservationCode || ''}
                                                onChange={(e) => updateHeaderField('reservationCode', e.target.value)}
                                                placeholder="Código de reservación"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Fecha Inicio</label>
                                            <input 
                                                type="date"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.startDate || ''}
                                                onChange={(e) => updateHeaderField('startDate', e.target.value)}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Fecha Fin</label>
                                            <input 
                                                type="date"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.endDate || ''}
                                                onChange={(e) => updateHeaderField('endDate', e.target.value)}
                                            />
                                        </div>
                                        <div className="space-y-2 md:col-span-2">
                                            <label className="text-sm font-semibold text-zinc-500">Pasajero Principal</label>
                                            <input 
                                                type="text"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.passenger || ''}
                                                onChange={(e) => updateHeaderField('passenger', e.target.value)}
                                                placeholder="Nombre del pasajero principal"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Cantidad Adultos</label>
                                            <input 
                                                type="number"
                                                min="0"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.paxAdults !== undefined ? formData.paxAdults : ''}
                                                onChange={(e) => updateHeaderField('paxAdults', e.target.value === '' ? undefined : parseInt(e.target.value))}
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-sm font-semibold text-zinc-500">Cantidad Niños</label>
                                            <input 
                                                type="number"
                                                min="0"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.paxChildren !== undefined ? formData.paxChildren : ''}
                                                onChange={(e) => updateHeaderField('paxChildren', e.target.value === '' ? undefined : parseInt(e.target.value))}
                                            />
                                        </div>
                                        <div className="space-y-2 md:col-span-2">
                                            <label className="text-sm font-semibold text-zinc-500">Descripción Manual</label>
                                            <input 
                                                type="text"
                                                className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                                                value={formData.manualDescription || ''}
                                                onChange={(e) => updateHeaderField('manualDescription', e.target.value)}
                                                placeholder="Descripción manual por defecto para los productos..."
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ) : (
                            <div className="space-y-4">
                                {stateHistoryList.length === 0 ? (
                                    <div className="text-center py-8 text-zinc-450 dark:text-zinc-550 font-semibold text-sm">
                                        No hay historial de cambios de estado registrado.
                                    </div>
                                ) : (
                                    <div className="border border-zinc-100 dark:border-zinc-800 rounded-2xl overflow-hidden shadow-inner bg-zinc-50/50 dark:bg-zinc-950/20">
                                        <div className="overflow-x-auto">
                                            <table className="w-full text-left border-collapse text-xs">
                                                <thead>
                                                    <tr className="bg-zinc-100 dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 font-bold text-zinc-500 uppercase tracking-wider text-[10px]">
                                                        <th className="px-5 py-3">Estado</th>
                                                        <th className="px-5 py-3">Comentario</th>
                                                        <th className="px-5 py-3">Fecha y Hora</th>
                                                        <th className="px-5 py-3">Usuario</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800 font-medium">
                                                    {stateHistoryList.map((h: any) => (
                                                        <tr key={h.id} className="hover:bg-zinc-100/30 dark:hover:bg-zinc-800/10 text-zinc-700 dark:text-zinc-300">
                                                            <td className="px-5 py-3">
                                                                <span className={cn(
                                                                    "px-2.5 py-1 rounded-full font-bold uppercase tracking-wider text-[9px] border",
                                                                    h.state === 'NUEVO' ? 'bg-blue-50 dark:bg-blue-500/10 border-blue-200 dark:border-blue-500/20 text-blue-600 dark:text-blue-400' :
                                                                    h.state === 'ENVIADO' ? 'bg-emerald-50 dark:bg-emerald-500/10 border-emerald-200 dark:border-emerald-500/20 text-emerald-600 dark:text-emerald-400' :
                                                                    'bg-zinc-50 dark:bg-zinc-500/10 border-zinc-200 dark:border-zinc-500/20 text-zinc-600 dark:text-zinc-400'
                                                                )}>
                                                                    {h.state}
                                                                </span>
                                                            </td>
                                                            <td className="px-5 py-3 italic font-semibold max-w-[200px] truncate" title={h.description}>
                                                                {h.description || 'Sin comentarios.'}
                                                            </td>
                                                            <td className="px-5 py-3 text-zinc-500 dark:text-zinc-400 font-bold">
                                                                {new Date(h.createdAt).toLocaleString()}
                                                            </td>
                                                            <td className="px-5 py-3 font-semibold text-zinc-900 dark:text-zinc-250">
                                                                {h.userName || 'Sistema'}
                                                            </td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>

                    {/* Section: Combos */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                        <div className="flex items-center justify-between mb-6">
                            <h3 className="text-lg font-bold flex items-center gap-2 dark:text-white">
                                <Briefcase className="w-5 h-5 text-purple-500" />
                                Combos de Venta
                            </h3>
                            <div className="flex items-center gap-3">
                                <div className="w-[300px]">
                                    <SearchSelect
                                        options={(data.combos || []).map((c: any) => ({...c, cuposText: c.cupos != null ? `${c.cupos} cupos` : 'Sin límite'}))}
                                        value=""
                                        onChange={(val) => {
                                            if (val) addCombo(parseInt(val));
                                        }}
                                        placeholder="+ Agregar un Combo..."
                                        secondaryKey="cuposText"
                                    />
                                </div>
                            </div>
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
                            <p className="text-zinc-400 text-xs italic">No has seleccionado ningún combo para esta cotización.</p>
                        )}
                    </div>



                    {/* Section: Products Grid */}
                    <div className="bg-white dark:bg-zinc-900 p-8 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
                        <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
                            <h3 className="text-lg font-bold flex items-center gap-2 dark:text-white">
                                <Tag className="w-5 h-5 text-emerald-500" />
                                Desglose de Productos
                            </h3>
                            <div className="flex items-center gap-3">
                                <button
                                    type="button"
                                    onClick={() => setIsManualServicesModalOpen(true)}
                                    className="text-emerald-700 dark:text-emerald-300 font-bold flex items-center gap-2 text-xs md:text-sm bg-emerald-50 dark:bg-emerald-950/50 hover:bg-emerald-100 dark:hover:bg-emerald-900/60 px-3.5 py-2 rounded-xl border border-emerald-200 dark:border-emerald-800/80 transition-all shadow-xs hover:shadow-sm"
                                    title="Digitar y consultar información manual de Proveedores, Servicios, Costos, Venta y Utilidad"
                                >
                                    <Calculator className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
                                    <span>Servicios / Proveedores Manuales</span>
                                    {formData.manualServices && formData.manualServices.length > 0 && (
                                        <span className="ml-1 text-[11px] font-extrabold px-2 py-0.5 rounded-full bg-emerald-600 text-white dark:bg-emerald-500">
                                            {formData.manualServices.length}
                                        </span>
                                    )}
                                </button>
                                <button
                                    type="button"
                                    onClick={addItem}
                                    className="text-emerald-600 font-bold flex items-center gap-1 hover:underline text-xs md:text-sm px-2 py-2"
                                >
                                    <Plus className="w-4 h-4" /> Agregar Producto
                                </button>
                            </div>
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
                                                placeholder="Seleccionar Producto"
                                                labelKey="description"
                                            />
                                        </div>
                                        <div className="col-span-4 md:col-span-2 space-y-1">
                                            <label className="text-[10px] uppercase font-bold text-zinc-400">Cant.</label>
                                            <input
                                                type="number"
                                                min="1"
                                                className="w-full h-11 bg-white dark:bg-zinc-900 rounded-lg px-3 border border-zinc-200 dark:border-zinc-800 outline-none text-sm"
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
                                                    className="w-1/2 min-w-[120px] shrink-0 h-11 bg-white dark:bg-zinc-900 rounded-lg px-3 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold text-blue-600 dark:text-blue-400 focus:ring-2 focus:ring-blue-500 shadow-sm"
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
                                                        type="text"
                                                        className="w-full h-11 bg-white dark:bg-zinc-900 rounded-lg pl-7 pr-2 border border-blue-200 dark:border-blue-800 outline-none text-sm font-bold text-blue-600 dark:text-blue-400 focus:ring-2 focus:ring-blue-5 shadow-sm"
                                                        value={item.totalInput ?? ((item.appliedTaxes || []).reduce((acc: number, t: any) => acc + (t.amount || 0), 0)).toFixed(decimals)}
                                                        onChange={(e) => updateItem(index, 'totalInput', e.target.value)}
                                                        onBlur={(e) => {
                                                            const newTotal = parseFloat(e.target.value) || 0;
                                                            const currentTaxes = item.appliedTaxes || [];
                                                            const currentTotal = currentTaxes.reduce((acc: number, t: any) => acc + (t.amount || 0), 0);
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
                                                            // clear temporary input after applying
                                                            updateItem(index, 'totalInput', undefined);
                                                        }}
                                                        placeholder="V. Total"
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                        <div className="col-span-2 md:col-span-1 flex justify-center pb-2">
                                            <button
                                                type="button"
                                                onClick={() => removeItem(index)}
                                                className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                                            >
                                                <Trash2 className="w-5 h-5" />
                                            </button>
                                        </div>

                                        {/* Per-Product Details Row */}
                                        <div className="col-span-12 mt-2 pt-4 border-t border-zinc-200 dark:border-zinc-700/50">
                                            <p className="text-[10px] uppercase font-bold text-zinc-400 mb-3">Detalles de Proveedor y Pasajero</p>
                                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                                                <div className="md:col-span-2 grid grid-cols-2 gap-2">
                                                    <div className="space-y-1">
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
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Adultos</label>
                                                    <input type="number" min="1" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.paxAdults} onChange={(e) => updateItem(index, 'paxAdults', parseInt(e.target.value))} />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Niños</label>
                                                    <input type="number" min="0" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.paxChildren} onChange={(e) => updateItem(index, 'paxChildren', parseInt(e.target.value))} />
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
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Servicio / Tipo</label>
                                                    <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.serviceType} onChange={(e) => updateItem(index, 'serviceType', e.target.value)} />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-zinc-400">Reservación</label>
                                                    <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.reservationCode} onChange={(e) => updateItem(index, 'reservationCode', e.target.value)} />
                                                </div>
                                                <div className="space-y-1 md:col-span-2">
                                                     <label className="text-[10px] uppercase font-bold text-zinc-400">Pasajero</label>
                                                     <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={item.passenger || ''} onChange={(e) => updateItem(index, 'passenger', e.target.value)} placeholder="Pasajero del producto..." />
                                                 </div>
                                                 <div className="space-y-1 md:col-span-2">
                                                     <label className="text-[10px] uppercase font-bold text-blue-500">Servicio</label>
                                                     <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs" value={item.servicios || item.service || ''} onChange={(e) => { updateItem(index, 'servicios', e.target.value); updateItem(index, 'service', e.target.value); }} placeholder="Servicio (ej. Desayuno incluido, Traslado VIP)..." />
                                                 </div>
                                                 <div className="space-y-1 md:col-span-2">
                                                     <label className="text-[10px] uppercase font-bold text-blue-500">Descripción Manual</label>
                                                     <input type="text" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-blue-200 dark:border-blue-800 outline-none text-xs" value={item.descripcion || ''} onChange={(e) => updateItem(index, 'descripcion', e.target.value)} placeholder="Descripción manual del producto..." />
                                                 </div>
                                            </div>

                                            <div className="col-span-12 mt-4 flex justify-between items-center bg-blue-50/50 dark:bg-blue-900/10 p-3 rounded-xl border border-blue-100 dark:border-blue-800/30">
                                                 <div>
                                                     <p className="text-[10px] uppercase font-bold text-blue-600 dark:text-blue-400">Pagos Registrados</p>
                                                     <p className="text-xs font-bold text-zinc-600 dark:text-zinc-300">
                                                         Total: ${((item.appliedTaxes || []).reduce((acc: number, t: any) => acc + (t.amount || 0), 0) || (item.price || 0) * (item.quantity || 1)).toLocaleString(undefined, {minimumFractionDigits: decimals, maximumFractionDigits: decimals})} | Pagado: ${((item.payments || []).reduce((acc: number, p: any) => acc + p.amount, 0)).toLocaleString(undefined, {minimumFractionDigits: decimals, maximumFractionDigits: decimals})}
                                                     </p>
                                                 </div>
                                                 <button type="button" onClick={() => updateItem(index, 'isPaymentModalOpen', true)} className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1 shadow-sm transition-all">
                                                     <CreditCard className="w-3.5 h-3.5" /> Administrar Pagos
                                                 </button>
                                             </div>
                                             <ItemPaymentModal
                                                 isOpen={item.isPaymentModalOpen || false}
                                                 onClose={() => updateItem(index, 'isPaymentModalOpen', false)}
                                                 productName={item.productId ? (data?.products?.find((p:any) => p.id.toString() === item.productId?.toString())?.description || 'Producto') : 'Producto sin nombre'}
                                                 itemTotal={(item.appliedTaxes || []).reduce((acc: number, t: any) => acc + (t.amount || 0), 0) || (item.price || 0) * (item.quantity || 1)}
                                                 payments={item.payments || []}
                                                 onUpdatePayments={(payments) => updateItem(index, 'payments', payments)}
                                                 creditCards={data?.creditCards || []}
                                                 paymentsList={data?.payments || []}
                                             />

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
                                                                const newPass = [...item.passengers];
                                                                newPass[pIdx] = { ...pax, name: e.target.value };
                                                                updateItem(index, 'passengers', newPass);
                                                            }} />
                                                            <input type="text" placeholder="Documento" className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs" value={pax.document} onChange={(e) => {
                                                                const newPass = [...item.passengers];
                                                                newPass[pIdx] = { ...pax, document: e.target.value };
                                                                updateItem(index, 'passengers', newPass);
                                                            }} />
                                                            <button type="button" onClick={() => {
                                                                const newPass = item.passengers.filter((_: any, idx: number) => idx !== pIdx);
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
                                                        type="text"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-orange-200 dark:border-orange-800 outline-none text-xs font-bold text-orange-600 dark:text-orange-400 focus:ring-1 focus:ring-orange-400"
                                                        value={focusedField?.itemIdx === index && focusedField?.field === 'cost' ? (focusedField.rawValue ?? '') : ((item.cost || 0) ? (item.cost || 0).toString() : '')}
                                                        onFocus={() => setFocusedField({ itemIdx: index, field: 'cost', rawValue: (item.cost || 0) ? (item.cost || 0).toString() : '' })}
                                                        onBlur={() => setFocusedField(null)}
                                                        onChange={(e) => {
                                                            const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                                            setFocusedField(prev => prev ? { ...prev, rawValue: cleanVal } : { itemIdx: index, field: 'cost', rawValue: cleanVal });
                                                            const lineTotalCost = parseFloat(cleanVal) || 0;
                                                            updateItem(index, 'cost', lineTotalCost);
                                                        }}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-emerald-600 dark:text-emerald-400">Com. Vend. ($)</label>
                                                    <input
                                                        type="text"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold"
                                                        value={focusedField?.itemIdx === index && focusedField?.field === 'sellerCommission' ? (focusedField.rawValue ?? item.sellerCommission ?? '') : (item.sellerCommission ?? '')}
                                                        onFocus={() => setFocusedField({ itemIdx: index, field: 'sellerCommission', rawValue: item.sellerCommission?.toString() || '' })}
                                                        onBlur={() => setFocusedField(null)}
                                                        onChange={(e) => {
                                                            const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                                            setFocusedField(prev => prev ? { ...prev, rawValue: cleanVal } : { itemIdx: index, field: 'sellerCommission', rawValue: cleanVal });
                                                            updateItem(index, 'sellerCommission', parseFloat(cleanVal) || 0);
                                                        }}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <label className="text-[10px] uppercase font-bold text-emerald-600 dark:text-emerald-400">Com. Tiq. ($)</label>
                                                    <input
                                                        type="text"
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-800 outline-none text-xs font-bold"
                                                        value={focusedField?.itemIdx === index && focusedField?.field === 'ticketPrinterCommission' ? (focusedField.rawValue ?? item.ticketPrinterCommission ?? '') : (item.ticketPrinterCommission ?? '')}
                                                        onFocus={() => setFocusedField({ itemIdx: index, field: 'ticketPrinterCommission', rawValue: item.ticketPrinterCommission?.toString() || '' })}
                                                        onBlur={() => setFocusedField(null)}
                                                        onChange={(e) => {
                                                            const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                                            setFocusedField(prev => prev ? { ...prev, rawValue: cleanVal } : { itemIdx: index, field: 'ticketPrinterCommission', rawValue: cleanVal });
                                                            updateItem(index, 'ticketPrinterCommission', parseFloat(cleanVal) || 0);
                                                        }}
                                                    />
                                                </div>
                                            </div>
                                        </div>

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
                                                {data.taxes.length === 0 && (
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
                                                        const defaultMainTax = data?.taxes?.find((t: any) => t.type === 'PRINCIPAL' || t.code === 'TAR' || t.name?.toUpperCase().includes('TARIFA'));
                                                        const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : (defaultMainTax ? Number(defaultMainTax.id) : null);
                                                        const isPrincipal = mainTaxIdNum != null && mainTaxIdNum === taxIdNum;
                                                        const isChecked = isPrincipal || !!appliedTax;
                                                        const currentTaxAmount = appliedTax?.amount ?? (isPrincipal ? (item.price || 0) * (item.quantity || 1) : 0);

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
                                                                                const taxIdNum = Number(tax.id);

                                                                                if (checked) {
                                                                                    let initialAmount = 0;
                                                                                    const baseValue = item.price * item.quantity;
                                                                                    if (tax.valueType === 'PERCENTAGE') {
                                                                                        initialAmount = (baseValue * (tax.value || 0)) / 100;
                                                                                    } else if (tax.valueType === 'FIXED') {
                                                                                        initialAmount = (tax.value || 0) * item.quantity;
                                                                                    } else {
                                                                                        initialAmount = baseValue || (tax.value || 0) * item.quantity;
                                                                                    }
                                                                                    const nextTaxes = [...currentTaxes, { id: taxIdNum, chargeAndTaxId: taxIdNum, amount: initialAmount }];

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
                                                                                    if (mainTaxIdNum === taxIdNum) {
                                                                                        const newItems = [...formData.items];
                                                                                        newItems[index] = { ...item, mainTaxId: undefined, appliedTaxes: nextTaxes };
                                                                                        setFormData({ ...formData, items: newItems });
                                                                                    } else {
                                                                                        updateItem(index, 'appliedTaxes', nextTaxes);
                                                                                    }
                                                                                }
                                                                            }}
                                                                        />
                                                                        <span>
                                                                            {tax.name}
                                                                            {isPrincipal && <span className="text-[9px] bg-blue-100 dark:bg-blue-900/40 text-blue-600 dark:text-blue-400 font-extrabold px-1.5 py-0.5 rounded ml-1 uppercase">Principal</span>}
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
                                                                        <span className="opacity-50 text-[10px] ml-auto">({tax.valueType === 'PERCENTAGE' ? `${tax.value}%` : tax.valueType === 'FIXED' ? `$${tax.value}` : 'Libre'})</span>
                                                                    </label>
                                                                </div>
                                                                {isChecked && (
                                                                    <div className="flex-1 flex flex-col md:flex-row md:items-center gap-2 border-l border-zinc-200 dark:border-zinc-700 pl-4 py-1">
                                                                        <span className="text-xs font-bold text-zinc-500">Valor Cobrado:</span>
                                                                        <div className="relative w-32">
                                                                            <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-zinc-400 font-bold">$</span>
                                                                            <input
                                                                                type="text"
                                                                                className={cn(
                                                                                    "w-full h-8 bg-white dark:bg-zinc-900 rounded-lg pl-7 pr-3 border border-zinc-200 dark:border-zinc-700 text-sm font-bold outline-none focus:ring-2 focus:ring-blue-500 shadow-sm transition-all",
                                                                                    tax.isEditable === false && !isPrincipal && "opacity-50 cursor-not-allowed bg-zinc-50 dark:bg-zinc-800"
                                                                                )}
                                                                                value={
                                                                                    focusedTax?.itemIdx === index && focusedTax?.taxId === Number(tax.id)
                                                                                        ? (focusedTax.rawValue ?? currentTaxAmount ?? '')
                                                                                        : formatMoney(currentTaxAmount, decimals)
                                                                                }
                                                                                disabled={tax.isEditable === false && !isPrincipal}
                                                                                onFocus={() => setFocusedTax({ itemIdx: index, taxId: Number(tax.id), rawValue: appliedTax?.amount?.toString() || currentTaxAmount.toString() })}
                                                                                onBlur={() => {
                                                                                    setFocusedTax(null);
                                                                                    const taxIdNum = Number(tax.id);
                                                                                    const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : null;
                                                                                    if (mainTaxIdNum === taxIdNum) {
                                                                                        const currentPrice = parseFloat(item.price as any) || 0;
                                                                                        updateItem(index, 'price', currentPrice);
                                                                                    } else {
                                                                                        const newTaxes = (item.appliedTaxes || []).map((t: any) => {
                                                                                            const rawId = t.id ?? t.chargeAndTaxId;
                                                                                            const currentAmt = parseFloat(t.amount as any) || 0;
                                                                                            return rawId != null && Number(rawId) === taxIdNum ? { ...t, amount: currentAmt } : t;
                                                                                        });
                                                                                        updateItem(index, 'appliedTaxes', newTaxes);
                                                                                    }
                                                                                }}
                                                                                onChange={(e) => {
                                                                                    const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                                                                    
                                                                                    setFocusedTax(prev => prev ? { ...prev, rawValue: cleanVal } : { itemIdx: index, taxId: Number(tax.id), rawValue: cleanVal });

                                                                                    const parsedVal = parseFloat(cleanVal) || 0;
                                                                                    const taxIdNum = Number(tax.id);
                                                                                    const mainTaxIdNum = item.mainTaxId != null ? Number(item.mainTaxId) : null;

                                                                                    if (mainTaxIdNum === taxIdNum) {
                                                                                        updateItem(index, 'price', parsedVal / (item.quantity || 1));
                                                                                    } else {
                                                                                        const newTaxes = (item.appliedTaxes || []).map((t: any) => {
                                                                                            const rawId = t.id ?? t.chargeAndTaxId;
                                                                                            return rawId != null && Number(rawId) === taxIdNum ? { ...t, amount: parsedVal } : t;
                                                                                        });
                                                                                        updateItem(index, 'appliedTaxes', newTaxes);
                                                                                    }
                                                                                }}
                                                                            />
                                                                        </div>
                                                                        <div className="text-[10px] text-zinc-400 leading-tight md:ml-2">
                                                                            Puedes modificar este valor <br className="hidden md:block" /> manualmente.
                                                                        </div>
                                                                    </div>
                                                                )}
                                                            </div>
                                                        );
                                                    });
                                                })()}
                                            </div>
                                        </div>

                                        {/* Additional Variables Row - Visible only if NOT a combo item */}
                                        {!item.comboId && (
                                            <div className="col-span-12 mt-2 pt-4 border-t border-zinc-200 dark:border-zinc-700/50">
                                                <p className="text-[10px] uppercase font-bold text-zinc-400 mb-3">
                                                    Variables Adicionales (Maestro)
                                                </p>
                                                <div className="flex flex-col gap-2">
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
                                                            return <span className="text-xs text-zinc-400 font-medium">No hay variables adicionales aplicables para este cliente.</span>;
                                                        }

                                                        return availableVariables.map((vMaster: any) => {
                                                            const assigned = item.variables?.find((v: any) => String(v.masterVariableId) === String(vMaster.id));
                                                            const isSelected = !!assigned;

                                                            return (
                                                                <div key={vMaster.id} className="flex items-center gap-4 bg-zinc-50 dark:bg-zinc-800/80 p-2 rounded-xl border border-zinc-200 dark:border-zinc-800">
                                                                    <div className="flex items-center gap-2 min-w-[200px]">
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
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold"
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
                                        type="text"
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold text-right"
                                        value={focusedField?.field === 'exchangeRate' ? (focusedField.rawValue ?? formData.exchangeRate ?? '') : (formData.exchangeRate ?? '')}
                                        onFocus={() => setFocusedField({ field: 'exchangeRate', rawValue: formData.exchangeRate?.toString() || '' })}
                                        onBlur={() => setFocusedField(null)}
                                        onChange={(e) => {
                                            const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                            setFocusedField({ field: 'exchangeRate', rawValue: cleanVal });
                                            setFormData({ ...formData, exchangeRate: parseFloat(cleanVal) || 0 });
                                        }}
                                    />
                                </div>
                                <div className="space-y-1 flex-1">
                                    <label className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider">Comisión (%)</label>
                                    <input
                                        type="text"
                                        className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold text-right text-white"
                                        value={focusedField?.field === 'comisionTotalPercentage' ? (focusedField.rawValue ?? formData.comisionTotalPercentage ?? '') : (formData.comisionTotalPercentage ?? '')}
                                        onFocus={() => setFocusedField({ field: 'comisionTotalPercentage', rawValue: formData.comisionTotalPercentage?.toString() || '' })}
                                        onBlur={() => setFocusedField(null)}
                                        onChange={(e) => {
                                            const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                            setFocusedField({ field: 'comisionTotalPercentage', rawValue: cleanVal });
                                            const totalPct = parseFloat(cleanVal) || 0;
                                            const freelancePct = formData.comisionFreelancePercentage || 0;
                                            const ownPct = totalPct - freelancePct;
                                            setFormData({
                                                ...formData,
                                                comisionTotalPercentage: totalPct,
                                                comisionPropiaPercentage: ownPct,
                                                commissionPercentage: ownPct
                                            });
                                        }}
                                    />
                                </div>
                            </div>

                            <div className="space-y-4 relative z-10 pt-4">
                                {Object.entries(taxSummary).length === 0 && (
                                    <div className="text-zinc-500 text-sm font-medium text-center pb-4">Aún no se han configurado cargos en los productos.</div>
                                )}
                                {Object.entries(taxSummary).map(([name, amount]) => (
                                    <div key={name} className="flex justify-between items-center text-sm font-bold text-zinc-300 border-b border-zinc-800 pb-3">
                                        <span className="flex items-center gap-2">
                                            <Tag className="w-4 h-4 text-emerald-400" />
                                            {name}
                                        </span>
                                        <span className="text-white">${amount.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}</span>
                                    </div>
                                ))}
                            </div>

                            {/* NUEVOS CAMPOS FINANCIEROS */}
                            {showTotals && (
                                <div className="pt-6 border-t border-zinc-800 space-y-3 relative z-10 text-sm">
                                    <h4 className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider mb-2">Resumen Financiero Interno</h4>
                                    
                                    <div className="flex justify-between items-center text-zinc-400">
                                        <span>Costo Total:</span>
                                        <span className="font-bold text-white">${costoTotal.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}</span>
                                    </div>
                                    <div className="flex justify-between items-center text-zinc-400">
                                        <span>Valor Base (Cargo Principal):</span>
                                        <span className="font-bold text-white">${valorBase.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}</span>
                                    </div>
                                    <div className="flex justify-between items-center text-zinc-400">
                                        <span>Utilidad:</span>
                                        <span className={`font-bold ${utilidad >= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
                                            ${utilidad.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}
                                        </span>
                                    </div>
                                    <div className="flex justify-between items-center text-zinc-400">
                                        <span>% Comisión s/ Utilidad:</span>
                                        <span className="font-bold text-white">
                                            {porcentajeComisionUtilidad.toFixed(2)}%
                                        </span>
                                    </div>

                                    <div className="pt-4 border-t border-zinc-800/50 space-y-3">
                                        <div className="space-y-1.5">
                                            <label className="text-[10px] uppercase font-bold text-zinc-500 tracking-wider">% Comisión Free Lance/Agencia</label>
                                            <input
                                                type="text"
                                                className="w-full h-11 bg-zinc-800 rounded-xl px-3 border border-zinc-700 outline-none text-sm font-bold text-right text-white"
                                                value={focusedField?.field === 'comisionFreelancePercentage' ? (focusedField.rawValue ?? formData.comisionFreelancePercentage ?? '') : (formData.comisionFreelancePercentage ?? '')}
                                                onFocus={() => setFocusedField({ field: 'comisionFreelancePercentage', rawValue: formData.comisionFreelancePercentage?.toString() || '' })}
                                                onBlur={() => setFocusedField(null)}
                                                onChange={(e) => {
                                                    const cleanVal = e.target.value.replace(/[^0-9.,]/g, '').replace(/,/g, '.');
                                                    setFocusedField({ field: 'comisionFreelancePercentage', rawValue: cleanVal });
                                                    const freelancePct = parseFloat(cleanVal) || 0;
                                                    const totalPct = formData.comisionTotalPercentage || 0;
                                                    const ownPct = totalPct - freelancePct;
                                                    setFormData({
                                                        ...formData,
                                                        comisionFreelancePercentage: freelancePct,
                                                        comisionPropiaPercentage: ownPct,
                                                        commissionPercentage: ownPct
                                                    });
                                                }}
                                            />
                                        </div>

                                        <div className="flex justify-between items-center text-zinc-400">
                                            <span>Comisión Free Lance/Agencia:</span>
                                            <span className="font-bold text-white">
                                                ${comisionFreelanceValue.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}
                                            </span>
                                        </div>
                                        <div className="flex justify-between items-center text-zinc-400">
                                            <span>% Comisión Propia:</span>
                                            <span className="font-bold text-white">
                                                {comisionPropiaPercentage.toFixed(2)}%
                                            </span>
                                        </div>
                                        <div className="flex justify-between items-center text-zinc-400 border-b border-dashed border-zinc-800 pb-3">
                                            <span>Comisión Propia:</span>
                                            <span className="font-bold text-white">
                                                ${comisionPropiaValue.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* Final Math */}
                            <div className="pt-8 space-y-4 relative z-10">
                                <div className="flex justify-between items-end">
                                    <span className="text-lg font-bold">Costo Real Total</span>
                                    <div className="text-right">
                                        <div className="text-4xl font-black text-emerald-400">
                                            ${total.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals })}
                                        </div>
                                        <p className="text-[10px] uppercase text-zinc-500 mt-1">Suma exacta en {formData.currency}</p>
                                        <div className="mt-4">
                                            <button type="button" onClick={() => setIsGlobalPaymentOpen(true)} className="w-full py-2 bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 font-bold rounded-xl border border-emerald-500/50 transition-all flex items-center justify-center gap-2">
                                                <DollarSign className="w-4 h-4" /> Distribuir Pago Global
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {quotationId && (
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
            <GlobalPaymentModal
                isOpen={isGlobalPaymentOpen}
                onClose={() => setIsGlobalPaymentOpen(false)}
                totalAmount={total}
                onApplyPayment={applyGlobalPayment}
                creditCards={data?.creditCards || []}
                paymentsList={data?.payments || []}
            />
            <ManualServicesModal
                isOpen={isManualServicesModalOpen}
                onClose={() => setIsManualServicesModalOpen(false)}
                services={formData.manualServices || []}
                onChange={(updatedServices) => setFormData({ ...formData, manualServices: updatedServices })}
                currency={formData.currency}
            />
        </form >
    )
}
