'use client';

import React, { useState, useEffect } from 'react';
import {
    FilePlus,
    Search,
    Calendar,
    ArrowRight,
    Clock,
    CheckCircle2,
    AlertCircle,
    Building2,
    Plus,
    X,
    RefreshCw,
    Receipt,
    Eye,
    Info,
    MessageSquare,
    Check,
    Send
} from 'lucide-react';
import { useRouter } from 'next/navigation';
import { SearchSelect } from '@/components/SearchSelect';

export const dynamic = 'force-dynamic';

interface PreQuotationItem {
    id: number;
    consecutivo: number;
    client_name: string;
    client_id: number | null;
    header_description: string;
    provider_id: number | null;
    provider_name: string;
    ticket_printer_id: number | null;
    ticket_printer_name: string;
    seller_id: number | null;
    seller_name: string;
    branch_id: number;
    branch_name: string;
    pre_quotation_type: string;
    quotation_notice: string;
    notice_response: string;
    start_date: string | null;
    end_date: string | null;
    custom_fields: any;
    state: string;
    user_id: number;
    user_name: string;
    created_at: string;
    converted_quotation_id: number | null;
    converted_internal_number: string;
    converted_at: string | null;
    converted_user_name: string;
    invoice_number: string;
    elapsed_minutes: number;
}

export default function PreQuotationsPage() {
    const router = useRouter();
    const [items, setItems] = useState<PreQuotationItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterState, setFilterState] = useState('');

    // Modal de Nueva Pre-Cotización
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [saving, setSaving] = useState(false);
    const [errorMsg, setErrorMsg] = useState('');

    // Listas maestras para selectores
    const [branches, setBranches] = useState<any[]>([]);
    const [sellers, setSellers] = useState<any[]>([]);
    const [providers, setProviders] = useState<any[]>([]);
    const [ticketPrinters, setTicketPrinters] = useState<any[]>([]);
    const [clients, setClients] = useState<any[]>([]);

    // Formulario de Pre-Cotización
    const [clientType, setClientType] = useState<'text' | 'select'>('text');
    const [clientNameText, setClientNameText] = useState('');
    const [selectedClientId, setSelectedClientId] = useState('');
    const [headerDescription, setHeaderDescription] = useState('');
    const [selectedBranchId, setSelectedBranchId] = useState('');
    const [selectedSellerId, setSelectedSellerId] = useState('');
    const [selectedProviderId, setSelectedProviderId] = useState('');
    const [selectedTicketPrinterId, setSelectedTicketPrinterId] = useState('');
    const [preQuotationType, setPreQuotationType] = useState('General');
    const [quotationNotice, setQuotationNotice] = useState('');
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');

    // Campos personalizables dinámicos
    const [customFields, setCustomFields] = useState<{ name: string; value: string; required: boolean }[]>([]);
    const [newFieldName, setNewFieldName] = useState('');
    const [newFieldReq, setNewFieldReq] = useState(false);

    // Modal de detalle y trazabilidad
    const [selectedDetail, setSelectedDetail] = useState<PreQuotationItem | null>(null);
    const [modalNoticeResponse, setModalNoticeResponse] = useState('');
    const [savingModalResponse, setSavingModalResponse] = useState(false);
    const [modalResponseSuccess, setModalResponseSuccess] = useState('');

    useEffect(() => {
        if (selectedDetail) {
            setModalNoticeResponse(selectedDetail.notice_response || '');
            setModalResponseSuccess('');
        }
    }, [selectedDetail]);

    const handleSaveModalResponse = async () => {
        if (!selectedDetail || !modalNoticeResponse.trim()) return;
        setSavingModalResponse(true);
        setModalResponseSuccess('');
        try {
            let userObj: any = null;
            try {
                const stored = localStorage.getItem('user');
                if (stored) userObj = JSON.parse(stored);
            } catch (e) {}

            const res = await fetch('/api/prequotations', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': userObj?.id?.toString() || '1'
                },
                body: JSON.stringify({
                    preQuotationId: selectedDetail.id,
                    noticeResponse: modalNoticeResponse.trim()
                })
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.message || 'Error al guardar respuesta');
            setModalResponseSuccess(data.message || 'Respuesta / Duda registrada correctamente.');
            fetchPreQuotations();
        } catch (err: any) {
            alert(err.message || 'Error al guardar respuesta');
        } finally {
            setSavingModalResponse(false);
        }
    };

    const fetchPreQuotations = async () => {
        setLoading(true);
        try {
            const url = `/api/prequotations?q=${encodeURIComponent(searchTerm)}&state=${encodeURIComponent(filterState)}`;
            const res = await fetch(url);
            if (res.ok) {
                const data = await res.json();
                setItems(Array.isArray(data) ? data : []);
            }
        } catch (e) {
            console.error('Error cargando pre-cotizaciones:', e);
        } finally {
            setLoading(false);
        }
    };

    const fetchMasters = async () => {
        try {
            const [resB, resS, resP, resT, resC] = await Promise.all([
                fetch('/api/config/branches').then(r => r.json()).catch(() => []),
                fetch('/api/config/sellers').then(r => r.json()).catch(() => []),
                fetch('/api/providers').then(r => r.json()).catch(() => []),
                fetch('/api/config/ticket-printers').then(r => r.json()).catch(() => []),
                fetch('/api/clients').then(r => r.json()).catch(() => [])
            ]);
            setBranches(Array.isArray(resB) ? resB : []);
            setSellers(Array.isArray(resS) ? resS : []);
            setProviders(Array.isArray(resP) ? resP : []);
            setTicketPrinters(Array.isArray(resT) ? resT : []);
            setClients(Array.isArray(resC) ? resC : []);
        } catch (e) {
            console.error('Error cargando maestros:', e);
        }
    };

    useEffect(() => {
        fetchMasters();
    }, []);

    useEffect(() => {
        fetchPreQuotations();
    }, [searchTerm, filterState]);

    const handleAddCustomField = () => {
        if (!newFieldName.trim()) return;
        setCustomFields(prev => [...prev, { name: newFieldName.trim(), value: '', required: newFieldReq }]);
        setNewFieldName('');
        setNewFieldReq(false);
    };

    const handleRemoveCustomField = (index: number) => {
        setCustomFields(prev => prev.filter((_, i) => i !== index));
    };

    const handleCreatePreQuotation = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorMsg('');

        if (!selectedBranchId) {
            setErrorMsg('La sucursal es obligatoria.');
            return;
        }

        if (clientType === 'text' && !clientNameText.trim()) {
            setErrorMsg('Debe digitar el nombre del cliente.');
            return;
        }

        if (clientType === 'select' && !selectedClientId) {
            setErrorMsg('Debe seleccionar un cliente.');
            return;
        }

        for (const cf of customFields) {
            if (cf.required && !cf.value.trim()) {
                setErrorMsg(`El campo personalizado "${cf.name}" es obligatorio.`);
                return;
            }
        }

        setSaving(true);
        try {
            let userObj: any = null;
            try {
                const stored = localStorage.getItem('user');
                if (stored) userObj = JSON.parse(stored);
            } catch (e) {}

            const body = {
                branchId: Number(selectedBranchId),
                clientNameText: clientType === 'text' ? clientNameText.trim() : null,
                clientId: clientType === 'select' ? Number(selectedClientId) : null,
                headerDescription: headerDescription.trim(),
                sellerId: selectedSellerId ? Number(selectedSellerId) : null,
                providerId: selectedProviderId ? Number(selectedProviderId) : null,
                ticketPrinterId: selectedTicketPrinterId ? Number(selectedTicketPrinterId) : null,
                preQuotationType: preQuotationType.trim(),
                quotationNotice: quotationNotice.trim(),
                startDate,
                endDate,
                customFields,
                userId: userObj?.id || 1
            };

            const res = await fetch('/api/prequotations', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': String(userObj?.id || 1)
                },
                body: JSON.stringify(body)
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.message || 'Error guardando pre-cotización');

            setIsModalOpen(false);
            resetForm();
            fetchPreQuotations();
        } catch (err: any) {
            setErrorMsg(err.message);
        } finally {
            setSaving(false);
        }
    };

    const resetForm = () => {
        setClientType('text');
        setClientNameText('');
        setSelectedClientId('');
        setHeaderDescription('');
        setSelectedBranchId('');
        setSelectedSellerId('');
        setSelectedProviderId('');
        setSelectedTicketPrinterId('');
        setPreQuotationType('General');
        setQuotationNotice('');
        setStartDate('');
        setEndDate('');
        setCustomFields([]);
        setErrorMsg('');
    };

    const handleConvertToQuotation = (item: PreQuotationItem) => {
        const query = new URLSearchParams({
            preQuotationId: String(item.id),
            consecutivo: String(item.consecutivo),
            clientName: item.client_name,
            clientId: item.client_id ? String(item.client_id) : '',
            branchId: String(item.branch_id),
            sellerId: item.seller_id ? String(item.seller_id) : '',
            providerId: item.provider_id ? String(item.provider_id) : '',
            ticketPrinterId: item.ticket_printer_id ? String(item.ticket_printer_id) : '',
            headerDescription: item.header_description,
            quotationNotice: item.quotation_notice,
            startDate: item.start_date ? item.start_date.split('T')[0] : '',
            endDate: item.end_date ? item.end_date.split('T')[0] : ''
        });

        router.push(`/dashboard/quotations/new?${query.toString()}`);
    };

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-6 md:p-8">
            
            {/* Header del Módulo */}
            <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white dark:bg-zinc-900/50 p-6 rounded-3xl border border-zinc-200 dark:border-zinc-800 mb-6 shadow-sm">
                <div>
                    <h1 className="text-3xl font-extrabold text-zinc-900 dark:text-white flex items-center gap-3">
                        <FilePlus className="w-8 h-8 text-amber-500" />
                        Gestión de Pre-Cotizaciones
                        <span className="text-xs font-bold bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20 px-3 py-1 rounded-full">
                            Consecutivo Compartido
                        </span>
                    </h1>
                    <p className="text-zinc-500 text-sm mt-1">
                        Solicitudes preliminares con avisos destacados y traza completa <strong className="text-emerald-600 dark:text-emerald-400">Pre-Cotización ➔ Cotización ➔ Factura ERP</strong>.
                    </p>
                </div>

                <button
                    onClick={() => { resetForm(); setIsModalOpen(true); }}
                    className="px-5 h-11 bg-amber-500 hover:bg-amber-600 text-zinc-950 font-bold rounded-2xl shadow-md transition-all flex items-center gap-2 text-xs cursor-pointer active:scale-95 shrink-0"
                >
                    <Plus className="w-4 h-4" />
                    <span>+ Nueva Pre-Cotización</span>
                </button>
            </header>

            {/* Filtros de Búsqueda */}
            <div className="bg-white dark:bg-zinc-900/50 p-4 sm:p-5 rounded-3xl border border-zinc-200 dark:border-zinc-800 mb-6 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                    <Search className="w-4 h-4 text-blue-600" />
                    <h2 className="text-xs font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-widest">FILTROS DE BÚSQUEDA</h2>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Búsqueda General</label>
                        <div className="relative">
                            <Search className="w-4 h-4 absolute left-3 top-2.5 text-zinc-400" />
                            <input
                                type="text"
                                value={searchTerm}
                                onChange={e => setSearchTerm(e.target.value)}
                                placeholder="Consecutivo, cliente o aviso..."
                                className="w-full h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl pl-9 pr-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            />
                        </div>
                    </div>

                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Estado</label>
                        <select
                            value={filterState}
                            onChange={e => setFilterState(e.target.value)}
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-semibold"
                        >
                            <option value="">TODOS LOS ESTADOS</option>
                            <option value="POR COTIZAR">POR COTIZAR</option>
                            <option value="COTIZADA">COTIZADA</option>
                        </select>
                    </div>

                    <div className="flex items-end">
                        <button
                            onClick={fetchPreQuotations}
                            className="h-9 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-xs flex items-center gap-2 shadow-sm transition-all cursor-pointer w-full justify-center"
                        >
                            <RefreshCw className="w-4 h-4" />
                            <span>Actualizar</span>
                        </button>
                    </div>
                </div>
            </div>

            {/* Tabla de Pre-Cotizaciones */}
            <div className="bg-white dark:bg-zinc-900/50 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm overflow-hidden">
                <div className="p-4 sm:p-5 border-b border-zinc-100 dark:border-zinc-800/80 flex items-center justify-between">
                    <div className="text-xs font-bold text-zinc-600 dark:text-zinc-400">
                        Total pre-cotizaciones: <span className="text-blue-600 font-extrabold">{items.length}</span>
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-zinc-50 dark:bg-zinc-800/50 border-b border-zinc-100 dark:border-zinc-800 text-[11px] font-black text-zinc-400 uppercase tracking-widest">
                                <th className="py-4 px-4">Consecutivo</th>
                                <th className="py-4 px-4">Cliente</th>
                                <th className="py-4 px-4">Sucursal / Asesor</th>
                                <th className="py-4 px-4">Fechas Solicitadas</th>
                                <th className="py-4 px-4">Tiempo Transcurrido</th>
                                <th className="py-4 px-4">Estado</th>
                                <th className="py-4 px-4">Trazabilidad</th>
                                <th className="py-4 px-4 text-right">Acciones</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60 text-xs">
                            {items.map((item) => {
                                const isConverted = item.state === 'COTIZADA';
                                const hours = Math.floor(item.elapsed_minutes / 60);
                                const mins = item.elapsed_minutes % 60;
                                const timeStr = `${hours > 0 ? `${hours}h ` : ''}${mins}m`;

                                return (
                                    <tr key={item.id} className="hover:bg-zinc-50/80 dark:hover:bg-zinc-800/30 transition-colors">
                                        <td className="py-4 px-4 font-mono font-bold text-amber-600 dark:text-amber-400">
                                            #{item.consecutivo}
                                        </td>
                                        <td className="py-4 px-4 font-bold text-zinc-900 dark:text-white">
                                            <div>{item.client_name}</div>
                                            {item.pre_quotation_type && (
                                                <div className="text-[10px] text-zinc-400 font-normal">Tipo: {item.pre_quotation_type}</div>
                                            )}
                                        </td>
                                        <td className="py-4 px-4 text-zinc-600 dark:text-zinc-300">
                                            <div className="font-semibold">{item.branch_name}</div>
                                            <div className="text-[10px] text-zinc-400">{item.seller_name || 'Sin asesor'}</div>
                                        </td>
                                        <td className="py-4 px-4 text-zinc-600 dark:text-zinc-300 font-medium">
                                            {item.start_date ? item.start_date.split('T')[0] : 'Sin fecha'}
                                            {item.end_date ? ` al ${item.end_date.split('T')[0]}` : ''}
                                        </td>
                                        <td className="py-4 px-4 font-mono">
                                            <span className="inline-flex items-center gap-1.5 bg-zinc-100 dark:bg-zinc-800 px-2.5 py-1 rounded-lg text-zinc-700 dark:text-zinc-300 border border-zinc-200 dark:border-zinc-700 font-semibold text-[11px]">
                                                <Clock className="w-3.5 h-3.5 text-amber-500" />
                                                {timeStr}
                                            </span>
                                        </td>
                                        <td className="py-4 px-4">
                                            <span className={`px-3 py-1 rounded-full text-xs font-bold border ${
                                                isConverted
                                                    ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20'
                                                    : 'bg-amber-500/10 text-amber-600 border-amber-500/20'
                                            }`}>
                                                {item.state}
                                            </span>
                                        </td>
                                        <td className="py-4 px-4 text-zinc-600 dark:text-zinc-300 space-y-1">
                                            {isConverted ? (
                                                <div className="text-xs space-y-1">
                                                    <div className="font-mono text-emerald-600 dark:text-emerald-400 font-bold flex items-center gap-1">
                                                        <CheckCircle2 className="w-3.5 h-3.5" />
                                                        <span>Cotización #{item.converted_internal_number || item.consecutivo}</span>
                                                    </div>
                                                    {item.invoice_number && (
                                                        <div className="font-mono text-blue-600 dark:text-blue-400 font-bold flex items-center gap-1">
                                                            <Receipt className="w-3.5 h-3.5" />
                                                            <span>Factura: {item.invoice_number}</span>
                                                        </div>
                                                    )}
                                                </div>
                                            ) : (
                                                <span className="text-[11px] text-zinc-400 italic">Pendiente por cotizar</span>
                                            )}
                                        </td>
                                        <td className="py-4 px-4 text-right space-x-2">
                                            <button
                                                onClick={() => setSelectedDetail(item)}
                                                className="p-2 bg-zinc-100 dark:bg-zinc-800 hover:bg-zinc-200 dark:hover:bg-zinc-700 text-zinc-600 dark:text-zinc-300 rounded-xl transition-all"
                                                title="Ver Detalle y Trazabilidad"
                                            >
                                                <Eye className="w-4 h-4" />
                                            </button>

                                            {!isConverted && (
                                                <button
                                                    onClick={() => handleConvertToQuotation(item)}
                                                    className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold text-xs flex items-center gap-1.5 inline-flex shadow-sm transition-all cursor-pointer active:scale-95"
                                                >
                                                    <span>Convertir</span>
                                                    <ArrowRight className="w-3.5 h-3.5" />
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                );
                            })}

                            {items.length === 0 && (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-zinc-400 text-xs font-medium">
                                        No hay pre-cotizaciones registradas o coincidentes con los filtros.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal de Nueva Pre-Cotización */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-zinc-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl max-w-3xl w-full max-h-[90vh] flex flex-col shadow-2xl overflow-hidden">
                        
                        {/* Header Modal */}
                        <div className="p-6 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                            <div>
                                <h3 className="text-lg font-extrabold text-zinc-900 dark:text-white flex items-center gap-2">
                                    <FilePlus className="w-5 h-5 text-amber-500" />
                                    Nueva Pre-Cotización (Consecutivo Automático)
                                </h3>
                                <p className="text-xs text-zinc-500 mt-0.5 font-medium">
                                    Ingrese la información preliminar. La pre-cotización tomará el siguiente número consecutivo unificado.
                                </p>
                            </div>
                            <button onClick={() => setIsModalOpen(false)} className="text-zinc-400 hover:text-zinc-600 p-1.5 rounded-xl hover:bg-zinc-100 dark:hover:bg-zinc-800">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        {/* Cuerpo Formulario */}
                        <form onSubmit={handleCreatePreQuotation} className="flex-1 overflow-y-auto p-6 space-y-5">
                            
                            {/* Sucursal y Tipo */}
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Sucursal emisora *</label>
                                    <SearchSelect
                                        options={branches}
                                        value={selectedBranchId}
                                        onChange={v => setSelectedBranchId(v)}
                                        placeholder="Seleccionar Sucursal"
                                    />
                                </div>

                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Tipo de Pre-Cotización</label>
                                    <input
                                        type="text"
                                        value={preQuotationType}
                                        onChange={e => setPreQuotationType(e.target.value)}
                                        placeholder="Ej. Paquete Vacacional, Vuelo Corporativo, Hotel"
                                        className="w-full h-11 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border border-zinc-200 dark:border-zinc-700 text-xs font-medium text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </div>
                            </div>

                            {/* Cliente (Selección vs Texto Libre) */}
                            <div className="space-y-2 bg-zinc-50 dark:bg-zinc-800/50 p-4 rounded-2xl border border-zinc-200 dark:border-zinc-700/60">
                                <div className="flex items-center justify-between">
                                    <label className="text-xs font-extrabold text-amber-600 dark:text-amber-400 uppercase tracking-wider">Datos del Cliente *</label>
                                    <div className="flex items-center gap-2 text-xs">
                                        <button
                                            type="button"
                                            onClick={() => setClientType('text')}
                                            className={`px-3 py-1 rounded-xl text-xs font-bold transition-all cursor-pointer ${clientType === 'text' ? 'bg-amber-500 text-zinc-950 shadow-sm' : 'bg-zinc-200 dark:bg-zinc-700 text-zinc-600 dark:text-zinc-400'}`}
                                        >
                                            Digitar Nombre
                                        </button>
                                        <button
                                            type="button"
                                            onClick={() => setClientType('select')}
                                            className={`px-3 py-1 rounded-xl text-xs font-bold transition-all cursor-pointer ${clientType === 'select' ? 'bg-amber-500 text-zinc-950 shadow-sm' : 'bg-zinc-200 dark:bg-zinc-700 text-zinc-600 dark:text-zinc-400'}`}
                                        >
                                            Seleccionar de Lista
                                        </button>
                                    </div>
                                </div>

                                {clientType === 'text' ? (
                                    <input
                                        type="text"
                                        value={clientNameText}
                                        onChange={e => setClientNameText(e.target.value)}
                                        placeholder="Escriba el nombre del cliente o empresa..."
                                        className="w-full h-11 bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl px-4 text-xs font-medium text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500"
                                        required
                                    />
                                ) : (
                                    <SearchSelect
                                        options={clients}
                                        value={selectedClientId}
                                        onChange={v => setSelectedClientId(v)}
                                        placeholder="Buscar Cliente Registrado"
                                    />
                                )}
                            </div>

                            {/* Datos de Encabezado (Información relevante) */}
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Datos de Cotización (Instrucción de Encabezado para el Cotizador)</label>
                                <textarea
                                    value={headerDescription}
                                    onChange={e => setHeaderDescription(e.target.value)}
                                    placeholder="Detalles preliminares de la solicitud (destinos deseados, categoría de hotel, presupuesto cliente, etc.)..."
                                    className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-3 text-xs font-medium text-zinc-900 dark:text-white h-20 outline-none focus:ring-2 focus:ring-blue-500"
                                />
                            </div>

                            {/* Aviso Destacado para Cotización */}
                            <div className="space-y-1.5 bg-amber-500/10 border border-amber-500/30 p-4 rounded-2xl">
                                <label className="text-xs font-extrabold text-amber-700 dark:text-amber-300 flex items-center gap-1.5">
                                    <MessageSquare className="w-4 h-4 text-amber-500" />
                                    <span>Aviso Especial para Cotización (Instrucción Visible)</span>
                                </label>
                                <textarea
                                    value={quotationNotice}
                                    onChange={e => setQuotationNotice(e.target.value)}
                                    placeholder="Escriba aquí cualquier advertencia o aviso especial. Este mensaje aparecerá de forma prominente cuando se genere la cotización..."
                                    className="w-full bg-white dark:bg-zinc-900 border border-amber-500/40 rounded-xl p-3 text-xs font-medium text-zinc-900 dark:text-white h-16 outline-none focus:ring-2 focus:ring-amber-500"
                                />
                            </div>

                            {/* Asesores y Prestador */}
                            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Vendedor / Asesor</label>
                                    <SearchSelect options={sellers} value={selectedSellerId} onChange={v => setSelectedSellerId(v)} placeholder="Opcional" />
                                </div>
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Prestador / Hotel</label>
                                    <SearchSelect options={providers} value={selectedProviderId} onChange={v => setSelectedProviderId(v)} placeholder="Opcional" />
                                </div>
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Tiqueteador</label>
                                    <SearchSelect options={ticketPrinters} value={selectedTicketPrinterId} onChange={v => setSelectedTicketPrinterId(v)} placeholder="Opcional" />
                                </div>
                            </div>

                            {/* Fechas Inicio / Fin */}
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Fecha Inicio Solicitada</label>
                                    <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} className="w-full h-11 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl px-4 text-xs font-medium text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Fecha Fin Solicitada</label>
                                    <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} className="w-full h-11 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl px-4 text-xs font-medium text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                            </div>

                            {/* Campos Personalizados Dinámicos */}
                            <div className="space-y-3 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                                <div className="flex items-center justify-between">
                                    <label className="text-xs font-extrabold text-zinc-800 dark:text-zinc-200 uppercase tracking-wider">Campos Personalizables Adicionales</label>
                                </div>

                                <div className="flex items-center gap-2">
                                    <input
                                        type="text"
                                        value={newFieldName}
                                        onChange={e => setNewFieldName(e.target.value)}
                                        placeholder="Nombre del nuevo campo (ej. Centro de Costos)"
                                        className="flex-1 h-10 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl px-3 text-xs font-medium text-zinc-900 dark:text-white"
                                    />
                                    <label className="flex items-center gap-1.5 text-xs text-zinc-600 dark:text-zinc-400 font-semibold cursor-pointer">
                                        <input
                                            type="checkbox"
                                            checked={newFieldReq}
                                            onChange={e => setNewFieldReq(e.target.checked)}
                                            className="w-4 h-4 accent-amber-500 rounded"
                                        />
                                        <span>Obligatorio</span>
                                    </label>
                                    <button
                                        type="button"
                                        onClick={handleAddCustomField}
                                        className="px-3 h-10 bg-zinc-200 dark:bg-zinc-800 hover:bg-zinc-300 dark:hover:bg-zinc-700 text-zinc-800 dark:text-zinc-200 rounded-xl text-xs font-bold cursor-pointer"
                                    >
                                        + Agregar Campo
                                    </button>
                                </div>

                                {customFields.length > 0 && (
                                    <div className="space-y-2">
                                        {customFields.map((cf, idx) => (
                                            <div key={idx} className="p-3 bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 rounded-2xl flex items-center justify-between gap-3">
                                                <div className="flex-1 space-y-1">
                                                    <div className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-2">
                                                        <span>{cf.name}</span>
                                                        {cf.required && <span className="text-[10px] bg-rose-500/10 text-rose-600 border border-rose-500/20 px-1.5 py-0.5 rounded-md font-bold">Obligatorio</span>}
                                                    </div>
                                                    <input
                                                        type="text"
                                                        value={cf.value}
                                                        onChange={e => {
                                                            const val = e.target.value;
                                                            setCustomFields(prev => prev.map((item, i) => i === idx ? { ...item, value: val } : item));
                                                        }}
                                                        placeholder={`Ingresar ${cf.name}...`}
                                                        className="w-full h-9 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 rounded-xl px-3 text-xs font-medium text-zinc-900 dark:text-white"
                                                    />
                                                </div>
                                                <button
                                                    type="button"
                                                    onClick={() => handleRemoveCustomField(idx)}
                                                    className="p-1.5 text-rose-500 hover:bg-rose-500/10 rounded-xl"
                                                >
                                                    <X className="w-4 h-4" />
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>

                            {errorMsg && (
                                <div className="p-3 bg-rose-500/10 border border-rose-500/20 rounded-2xl text-xs font-bold text-rose-600 dark:text-rose-400 flex items-center gap-2">
                                    <AlertCircle className="w-4 h-4 shrink-0" />
                                    <span>{errorMsg}</span>
                                </div>
                            )}

                            {/* Footer Modal */}
                            <div className="pt-4 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-end gap-3">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="px-5 py-2.5 bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 font-bold rounded-2xl text-xs cursor-pointer"
                                >
                                    Cancelar
                                </button>
                                <button
                                    type="submit"
                                    disabled={saving}
                                    className="px-6 py-2.5 bg-amber-500 hover:bg-amber-600 text-zinc-950 font-extrabold rounded-2xl text-xs flex items-center gap-2 shadow-md transition-all cursor-pointer active:scale-95"
                                >
                                    {saving && <RefreshCw className="w-3.5 h-3.5 animate-spin" />}
                                    <span>Crear Pre-Cotización</span>
                                </button>
                            </div>

                        </form>
                    </div>
                </div>
            )}

            {/* Modal de Detalle y Trazabilidad */}
            {selectedDetail && (
                <div className="fixed inset-0 bg-zinc-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl max-w-2xl w-full p-6 space-y-6 shadow-2xl">
                        <div className="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-4">
                            <h3 className="text-base font-extrabold text-zinc-900 dark:text-white flex items-center gap-2">
                                <Info className="w-5 h-5 text-amber-500" />
                                Detalle y Trazabilidad de Pre-Cotización #{selectedDetail.consecutivo}
                            </h3>
                            <button onClick={() => setSelectedDetail(null)} className="text-zinc-400 hover:text-zinc-600 p-1.5 rounded-xl hover:bg-zinc-100 dark:hover:bg-zinc-800">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        <div className="space-y-4 text-xs">
                            <div className="grid grid-cols-2 gap-4 bg-zinc-50 dark:bg-zinc-800/50 p-4 rounded-2xl border border-zinc-200 dark:border-zinc-700/60">
                                <div>
                                    <div className="text-zinc-400 font-bold uppercase text-[10px]">Cliente:</div>
                                    <div className="font-extrabold text-zinc-900 dark:text-white text-sm">{selectedDetail.client_name}</div>
                                </div>
                                <div>
                                    <div className="text-zinc-400 font-bold uppercase text-[10px]">Estado:</div>
                                    <div className="font-extrabold text-amber-600 dark:text-amber-400">{selectedDetail.state}</div>
                                </div>
                                <div>
                                    <div className="text-zinc-400 font-bold uppercase text-[10px]">Sucursal:</div>
                                    <div className="text-zinc-700 dark:text-zinc-300 font-semibold">{selectedDetail.branch_name}</div>
                                </div>
                                <div>
                                    <div className="text-zinc-400 font-bold uppercase text-[10px]">Vendedor:</div>
                                    <div className="text-zinc-700 dark:text-zinc-300 font-semibold">{selectedDetail.seller_name || 'N/A'}</div>
                                </div>
                            </div>

                            {selectedDetail.quotation_notice && (
                                <div className="bg-amber-500/10 border border-amber-500/30 p-4 rounded-2xl space-y-1">
                                    <div className="font-extrabold text-amber-700 dark:text-amber-300">Aviso Especial del Solicitante:</div>
                                    <div className="text-zinc-800 dark:text-zinc-200 font-medium leading-relaxed">{selectedDetail.quotation_notice}</div>
                                </div>
                            )}

                            <div className="bg-zinc-50 dark:bg-zinc-800/40 p-4 rounded-2xl border border-zinc-200 dark:border-zinc-700/60 space-y-2">
                                <div className="font-extrabold text-zinc-800 dark:text-zinc-200 text-xs">Respuesta al Aviso / Generación de Duda (Pre-Cotización):</div>
                                <div className="flex gap-2">
                                    <input
                                        type="text"
                                        value={modalNoticeResponse}
                                        onChange={e => {
                                            setModalNoticeResponse(e.target.value);
                                            setModalResponseSuccess('');
                                        }}
                                        placeholder="Escriba su respuesta o duda (ej. 'En el hotel solicitado no hay cupo, le cotizamos en Sol Caribe')..."
                                        className="flex-1 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 rounded-xl px-3 text-xs font-medium text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-amber-500"
                                    />
                                    <button
                                        type="button"
                                        onClick={handleSaveModalResponse}
                                        disabled={savingModalResponse || !modalNoticeResponse.trim()}
                                        className="px-4 h-10 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-zinc-950 font-extrabold rounded-xl text-xs flex items-center gap-1.5 shrink-0 transition-all cursor-pointer"
                                    >
                                        {savingModalResponse ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Send className="w-3.5 h-3.5" />}
                                        <span>Guardar Respuesta / Duda</span>
                                    </button>
                                </div>
                                {modalResponseSuccess && (
                                    <div className="text-xs font-bold text-emerald-600 dark:text-emerald-400 flex items-center gap-1.5 pt-1">
                                        <CheckCircle2 className="w-3.5 h-3.5" />
                                        <span>{modalResponseSuccess}</span>
                                    </div>
                                )}
                            </div>

                            {/* Trazabilidad End-to-End */}
                            <div className="space-y-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                                <div className="font-black text-zinc-400 uppercase tracking-widest text-[10px]">Trazabilidad del Ciclo de Vida:</div>
                                <div className="space-y-3 bg-zinc-50 dark:bg-zinc-800/50 p-4 rounded-2xl border border-zinc-200 dark:border-zinc-700/60">
                                    <div className="flex items-center gap-3">
                                        <div className="w-3 h-3 rounded-full bg-amber-500 shrink-0"></div>
                                        <div>
                                            <div className="font-bold text-zinc-900 dark:text-white">1. Pre-Cotización #{selectedDetail.consecutivo} Solicitada</div>
                                            <div className="text-[11px] text-zinc-500">Ingresada por {selectedDetail.user_name} el {selectedDetail.created_at.split('T')[0]}</div>
                                        </div>
                                    </div>

                                    {selectedDetail.converted_quotation_id && (
                                        <div className="flex items-center gap-3 pl-1">
                                            <div className="w-3 h-3 rounded-full bg-emerald-500 shrink-0"></div>
                                            <div>
                                                <div className="font-bold text-emerald-600 dark:text-emerald-400">2. Convertida a Cotización #{selectedDetail.converted_internal_number}</div>
                                                <div className="text-[11px] text-zinc-500">Convertida por {selectedDetail.converted_user_name} el {selectedDetail.converted_at?.split('T')[0]}</div>
                                            </div>
                                        </div>
                                    )}

                                    {selectedDetail.invoice_number && (
                                        <div className="flex items-center gap-3 pl-1">
                                            <div className="w-3 h-3 rounded-full bg-blue-600 shrink-0"></div>
                                            <div>
                                                <div className="font-bold text-blue-600 dark:text-blue-400">3. Factura ERP Emitida ({selectedDetail.invoice_number})</div>
                                                <div className="text-[11px] text-zinc-500">Integración con Zeus ERP completada</div>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>

                        <div className="text-right pt-2 border-t border-zinc-100 dark:border-zinc-800">
                            <button
                                onClick={() => setSelectedDetail(null)}
                                className="px-5 py-2 bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 font-bold rounded-2xl text-xs cursor-pointer"
                            >
                                Cerrar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
