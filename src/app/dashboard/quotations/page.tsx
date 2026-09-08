'use client'

import React, { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, Plus, Filter, FileText, Download, Trash2, Eye, Edit2, MoreVertical, Printer, FileCode } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { format } from 'date-fns'
import { generateQuotationPDF } from '@/lib/pdf-utils'

export default function QuotationsListPage() {
    const [quotations, setQuotations] = useState<any[]>([])
    const [states, setStates] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    
    // Filtros de búsqueda
    const [filterReferencia, setFilterReferencia] = useState('')
    const [filterFechaDesde, setFilterFechaDesde] = useState('')
    const [filterFechaHasta, setFilterFechaHasta] = useState('')
    const [filterCliente, setFilterCliente] = useState('')
    const [filterElaboradoPor, setFilterElaboradoPor] = useState('')
    const [filterMontoTotal, setFilterMontoTotal] = useState('')
    const [filterEstado, setFilterEstado] = useState('')

    const [isPrintModalOpen, setIsPrintModalOpen] = useState(false)
    const [idIni, setIdIni] = useState('')
    const [idFin, setIdFin] = useState('')
    const [quotationFormats, setQuotationFormats] = useState<any[]>([])
    const [selectedFormatId, setSelectedFormatId] = useState<number | null>(null)
    const [openFormatMenuId, setOpenFormatMenuId] = useState<number | null>(null)

    // Para modal de cambio de estado
    const [selectedQuotationForState, setSelectedQuotationForState] = useState<any | null>(null)
    const [newState, setNewState] = useState('')
    const [stateDescription, setStateDescription] = useState('')
    const [savingState, setSavingState] = useState(false)

    const router = useRouter()

    const fetchQuotations = (filters?: {
        referencia?: string;
        fechaDesde?: string;
        fechaHasta?: string;
        cliente?: string;
        elaboradoPor?: string;
        montoTotal?: string;
        estado?: string;
    }) => {
        setLoading(true)
        
        const params = new URLSearchParams()
        if (filters) {
            if (filters.referencia) params.append('referencia', filters.referencia)
            if (filters.fechaDesde) params.append('fechaDesde', filters.fechaDesde)
            if (filters.fechaHasta) params.append('fechaHasta', filters.fechaHasta)
            if (filters.cliente) params.append('cliente', filters.cliente)
            if (filters.elaboradoPor) params.append('elaboradoPor', filters.elaboradoPor)
            if (filters.montoTotal) params.append('montoTotal', filters.montoTotal)
            if (filters.estado) params.append('estado', filters.estado)
        }

        const url = `/api/quotations/list?${params.toString()}`

        Promise.all([
            fetch(url).then(res => res.json()),
            fetch('/api/config/quotation-states').then(res => res.json()).catch(() => []),
            fetch('/api/config/quotation-formats').then(res => res.json()).catch(() => [])
        ])
            .then(([quoData, stateData, fmtData]) => {
                if (Array.isArray(quoData)) {
                    setQuotations(quoData)
                } else {
                    console.error("API returned error or non-array:", quoData)
                    setQuotations([])
                }
                if (Array.isArray(stateData) && stateData.length > 0) {
                    setStates(stateData)
                } else {
                    setStates(prev => prev.length > 0 ? prev : [
                        { code: 'NUEVO', name: 'Nuevo', color: 'blue' },
                        { code: 'ENVIADO', name: 'ENVIADO', color: 'emerald' }
                    ])
                }
                if (Array.isArray(fmtData)) {
                    setQuotationFormats(fmtData)
                }
                setLoading(false)
            })
            .catch(err => {
                console.error(err)
                setLoading(false)
            })
    }

    const handleApplyFilters = () => {
        fetchQuotations({
            referencia: filterReferencia,
            fechaDesde: filterFechaDesde,
            fechaHasta: filterFechaHasta,
            cliente: filterCliente,
            elaboradoPor: filterElaboradoPor,
            montoTotal: filterMontoTotal,
            estado: filterEstado
        })
    }

    const handleClearFilters = () => {
        setFilterReferencia('')
        setFilterFechaDesde('')
        setFilterFechaHasta('')
        setFilterCliente('')
        setFilterElaboradoPor('')
        setFilterMontoTotal('')
        setFilterEstado('')
        fetchQuotations({})
    }

    useEffect(() => {
        fetchQuotations()
    }, [])

    const handleSaveState = async () => {
        if (!selectedQuotationForState || !newState) return
        setSavingState(true)
        try {
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{"id": 1}');
            const res = await fetch(`/api/quotations/${selectedQuotationForState.id}/state`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: JSON.stringify({
                    state: newState,
                    description: stateDescription
                })
            })
            const result = await res.json()
            if (!res.ok) throw new Error(result.message || 'Error al guardar estado')
            
            alert(result.message || 'Estado actualizado exitosamente')
            setSelectedQuotationForState(null)
            setStateDescription('')
            fetchQuotations()
        } catch (err: any) {
            console.error(err)
            alert(err.message || 'Ocurrió un error al cambiar el estado')
        } finally {
            setSavingState(false)
        }
    }

    const handleDownloadPdf = (q: any) => {
        const firstProd = q.products && q.products.length > 0 ? q.products[0] : null;

        const pdfData = {
            ...q,
            clientName: q.client?.name || 'Cliente sin nombre',
            clientDocument: q.client?.document || '',
            providerName: firstProd?.provider?.name || 'Varios/Ninguno',
            prestadoraName: firstProd?.prestadora?.name || 'Varios/Ninguno',
            checkIn: firstProd?.checkInDate ? format(new Date(firstProd.checkInDate), 'yyyy-MM-dd') : '',
            checkOut: firstProd?.checkOutDate ? format(new Date(firstProd.checkOutDate), 'yyyy-MM-dd') : '',
            paxName: firstProd?.passengers?.[0]?.name || 'N/A',
            paxDocument: firstProd?.passengers?.[0]?.document || 'N/A',
            paxAdults: firstProd?.paxAdults || 1,
            paxChildren: firstProd?.paxChildren || 0,
            nights: firstProd?.nights || 0,
            items: (q.products || []).map((p: any) => ({
                ...p,
                productDescription: p.product?.description || ''
            }))
        }
        generateQuotationPDF(pdfData)
    }

    const handleExportXml = async (q: any) => {
        try {
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{"id": 1}');
            const res = await fetch('/api/quotations/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: [q.id], // Enviamos como arreglo para consistencia
                    userId: loggedUser.id,
                    exportType: 'QUOTATION'
                })
            });

            const data = await res.json();

            if (!res.ok) {
                // Si el servidor devolvió un error (400, 500), mostramos el mensaje detallado
                alert("ERROR DE SERVIDOR: " + (data.message || "Error desconocido") + (data.details ? "\nDetalles: " + data.details : ""));
                return;
            }

            // Mostrar resultado de SQL Server si existe
            if (data.success) {
                alert("EXPORTACIÓN EXITOSA A SQL SERVER:\n" + data.message);
            } else {
                alert("ATENCIÓN: Se generó el XML pero hubo un problema con SQL Server.\nMensaje: " + data.message);
            }

            // Descargar el XML localmente
            if (data.xml) {
                const blob = new Blob([data.xml], { type: 'application/xml' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `cotizacion_${q.id}.xml`;
                document.body.appendChild(a);
                a.click();
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);
            }
        } catch (err: any) {
            console.error(err);
            alert("Error al exportar: " + err.message);
        }
    }

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-8 md:p-12">
            <header className="flex items-center justify-between mb-12">
                <div>
                    <h1 className="text-4xl font-bold text-zinc-900 dark:text-white mb-2">Cotizaciones</h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium">Gestión y seguimiento de tus ofertas</p>
                </div>
                <div className="flex items-center gap-3">
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => setIsPrintModalOpen(true)}
                        className="px-5 h-12 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl flex items-center gap-2 shadow-sm text-sm font-bold transition-all cursor-pointer active:scale-95"
                    >
                        <Printer className="w-5 h-5" />
                        Imprimir Reporte
                    </motion.button>
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => router.push('/dashboard/quotations/new')}
                        className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl flex items-center gap-2 shadow-md shadow-blue-500/20 text-sm font-bold transition-all cursor-pointer active:scale-95 shrink-0"
                    >
                        <Plus className="w-5 h-5" />
                        Nueva Cotización
                    </motion.button>
                </div>
            </header>
            {/* Filtros Avanzados */}
            <div className="bg-white dark:bg-zinc-900/50 p-6 rounded-3xl border border-zinc-200 dark:border-zinc-800 mb-8 shadow-sm">
                <div className="flex items-center gap-2 mb-4">
                    <Filter className="w-5 h-5 text-blue-600" />
                    <h2 className="text-sm font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-widest">Filtros de Búsqueda</h2>
                </div>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    {/* Referencia */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Referencia / ID</label>
                        <input
                            type="text"
                            placeholder="Ej. #12 o COT-001..."
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterReferencia}
                            onChange={(e) => setFilterReferencia(e.target.value)}
                        />
                    </div>
                    
                    {/* Cliente */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Cliente</label>
                        <input
                            type="text"
                            placeholder="Nombre del cliente..."
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterCliente}
                            onChange={(e) => setFilterCliente(e.target.value)}
                        />
                    </div>

                    {/* Elaborado por */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Elaborado por</label>
                        <input
                            type="text"
                            placeholder="Nombre del vendedor..."
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterElaboradoPor}
                            onChange={(e) => setFilterElaboradoPor(e.target.value)}
                        />
                    </div>

                    {/* Estado */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Estado</label>
                        <select
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-semibold"
                            value={filterEstado}
                            onChange={(e) => setFilterEstado(e.target.value)}
                        >
                            <option value="">TODOS</option>
                            {states.map((s: any) => (
                                <option key={s.id || s.code} value={s.code}>{s.name.toUpperCase()}</option>
                            ))}
                        </select>
                    </div>

                    {/* Fecha Desde */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Fecha Desde</label>
                        <input
                            type="date"
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterFechaDesde}
                            onChange={(e) => setFilterFechaDesde(e.target.value)}
                        />
                    </div>

                    {/* Fecha Hasta */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Fecha Hasta</label>
                        <input
                            type="date"
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterFechaHasta}
                            onChange={(e) => setFilterFechaHasta(e.target.value)}
                        />
                    </div>

                    {/* Monto Total */}
                    <div className="flex flex-col gap-1.5">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Monto Total</label>
                        <input
                            type="number"
                            placeholder="Monto exacto..."
                            className="h-11 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 border border-zinc-100 dark:border-zinc-700/50 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterMontoTotal}
                            onChange={(e) => setFilterMontoTotal(e.target.value)}
                        />
                    </div>

                    {/* Acciones de Filtro */}
                    <div className="flex items-end gap-2 h-11 mt-auto">
                        <button
                            onClick={handleApplyFilters}
                            className="flex-1 h-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-black text-sm shadow-md shadow-blue-500/10 flex items-center justify-center gap-2 transition-all active:scale-[0.98]"
                        >
                            <Search className="w-4 h-4" /> Buscar
                        </button>
                        <button
                            onClick={handleClearFilters}
                            className="h-full px-4 border border-zinc-200 dark:border-zinc-700 text-zinc-500 hover:text-zinc-700 dark:text-zinc-400 dark:hover:text-zinc-200 hover:bg-zinc-50 dark:hover:bg-zinc-850 rounded-xl font-black text-xs uppercase tracking-wider transition-all"
                            title="Limpiar filtros"
                        >
                            Limpiar
                        </button>
                    </div>
                </div>
            </div>

            {/* Table */}
            <div className="bg-white dark:bg-zinc-900/50 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-zinc-50 dark:bg-zinc-800/50 border-b border-zinc-200 dark:border-zinc-800">
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Referencia</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Cliente</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Elaborado por</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Fechas</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Total</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Estado</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Acciones</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                        {loading ? (
                            <tr><td colSpan={7} className="p-20 text-center"><div className="animate-spin rounded-full h-8 w-8 border-t-2 border-blue-600 mx-auto"></div></td></tr>
                        ) : quotations.length === 0 ? (
                            <tr><td colSpan={7} className="p-20 text-center text-zinc-500 font-medium">No se encontraron cotizaciones.</td></tr>
                        ) : (
                            quotations.map((q) => {
                                const mainProd = q.products.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
                                const firstProd = mainProd;
                                return (
                                    <tr key={q.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all">
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-blue-600">#{q.id}</div>
                                            <div className="text-[10px] text-zinc-400 mt-0.5">{format(new Date(q.date), 'dd MMM, yyyy')}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-zinc-900 dark:text-white">{q.client?.name}</div>
                                            <div className="text-[10px] text-zinc-500 font-medium">Pax: {(firstProd?.passengers && Array.isArray(firstProd.passengers) && firstProd.passengers.length > 0) ? firstProd.passengers[0].name : 'Mismo titular'}</div>
                                            <div className="text-xs text-zinc-400 mt-1">{firstProd?.prestadora?.name || 'Varios/Ninguno'}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-zinc-700 dark:text-zinc-300 text-xs">
                                                {q.user?.name || <span className="text-zinc-400 italic text-xs font-normal">N/A</span>}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="text-xs font-medium text-zinc-600 dark:text-zinc-400">
                                                {firstProd?.checkInDate ? format(new Date(firstProd.checkInDate), 'dd/MM/yy') : '-'} - {firstProd?.checkOutDate ? format(new Date(firstProd.checkOutDate), 'dd/MM/yy') : '-'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-black text-zinc-900 dark:text-white">
                                                ${q.totalAmount.toLocaleString()} <span className="text-[10px] text-zinc-500 uppercase">{q.currency}</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex flex-col gap-1 items-start">
                                                <button
                                                    onClick={() => {
                                                        setSelectedQuotationForState(q)
                                                        setNewState(q.state || 'NUEVO')
                                                        setStateDescription(q.stateDescription || '')
                                                    }}
                                                    className={`px-2.5 py-1 rounded-md text-[10px] font-bold uppercase cursor-pointer hover:opacity-85 transition-all text-left flex items-center gap-1 border border-zinc-200 dark:border-zinc-800 shadow-sm ${
                                                        (q.state || 'NUEVO') === 'ENVIADO' 
                                                        ? "bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-950/30" 
                                                        : "bg-blue-50 text-blue-700 border-blue-100 dark:bg-blue-500/10 dark:text-blue-400 dark:border-blue-950/30"
                                                    }`}
                                                    title="Haga clic para cambiar el estado"
                                                >
                                                    {q.state || 'NUEVO'}
                                                </button>
                                                
                                                {/* Mostrar la descripción si existe */}
                                                {q.stateDescription && (
                                                    <span className="text-[10px] text-zinc-500 dark:text-zinc-400 font-medium italic max-w-[200px] truncate" title={q.stateDescription}>
                                                        {q.stateDescription}
                                                    </span>
                                                )}
                                                
                                                {/* Mostrar la fecha y hora si existe */}
                                                {q.stateUpdatedAt && (
                                                    <span className="text-[9px] text-zinc-400 dark:text-zinc-500 font-bold uppercase tracking-wider">
                                                        {format(new Date(q.stateUpdatedAt), 'dd/MM/yy HH:mm')}
                                                    </span>
                                                )}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-2 relative">
                                                <button
                                                    onClick={() => handleExportXml(q)}
                                                    className="p-2 text-zinc-400 hover:text-emerald-500 hover:bg-emerald-50 dark:hover:bg-emerald-500/10 rounded-lg transition-all"
                                                    title="Descargar XML (Integración)"
                                                >
                                                    <FileCode className="w-5 h-5" />
                                                </button>
                                                <button
                                                    onClick={() => {
                                                        if (quotationFormats.length === 0) {
                                                            window.open(`/dashboard/quotations/print?idIni=${q.id}&idFin=${q.id}`, '_blank')
                                                        } else {
                                                            setOpenFormatMenuId(openFormatMenuId === q.id ? null : q.id)
                                                        }
                                                    }}
                                                    className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-lg transition-all relative"
                                                    title="Imprimir Cotización"
                                                >
                                                    <Printer className="w-5 h-5" />
                                                </button>
                                                {openFormatMenuId === q.id && quotationFormats.length > 0 && (
                                                    <div className="absolute right-0 mt-1 w-52 bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl shadow-xl z-20 overflow-hidden"
                                                        style={{ top: '100%' }}>
                                                        <div className="p-2 space-y-0.5">
                                                            <button
                                                                onClick={() => {
                                                                    window.open(`/dashboard/quotations/print?idIni=${q.id}&idFin=${q.id}`, '_blank')
                                                                    setOpenFormatMenuId(null)
                                                                }}
                                                                className="w-full text-left px-3 py-2 rounded-xl text-sm font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-700 transition-all"
                                                            >
                                                                Formato Predeterminado
                                                            </button>
                                                            {quotationFormats.map((fmt: any) => (
                                                                <button
                                                                    key={fmt.id}
                                                                    onClick={() => {
                                                                        window.open(`/dashboard/quotations/print?idIni=${q.id}&idFin=${q.id}&formatId=${fmt.id}`, '_blank')
                                                                        setOpenFormatMenuId(null)
                                                                    }}
                                                                    className="w-full text-left px-3 py-2 rounded-xl text-sm font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-blue-50 dark:hover:bg-blue-500/10 hover:text-blue-600 transition-all"
                                                                >
                                                                    {fmt.name}
                                                                </button>
                                                            ))}
                                                        </div>
                                                    </div>
                                                )}
                                                <button
                                                    onClick={() => router.push(`/dashboard/quotations/${q.id}/edit`)}
                                                    className="p-2 text-zinc-400 hover:text-indigo-500 hover:bg-indigo-50 dark:hover:bg-indigo-500/10 rounded-lg transition-all"
                                                    title="Editar Cotización"
                                                >
                                                    <Edit2 className="w-5 h-5" />
                                                </button>
                                                <button className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all">
                                                    <Trash2 className="w-5 h-5" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                )
                            })
                        )}
                    </tbody>
                </table>
            </div>

            {/* Print Range Modal */}
            <AnimatePresence>
                {isPrintModalOpen && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-900/40 backdrop-blur-sm"
                    >
                        <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.95, opacity: 0 }}
                            className="bg-white dark:bg-zinc-900 rounded-3xl w-full max-w-md shadow-2xl border border-zinc-200 dark:border-zinc-800 overflow-hidden"
                        >
                            <div className="p-8">
                                <h3 className="text-2xl font-black text-zinc-900 dark:text-white mb-2">Imprimir Reporte</h3>
                                <p className="text-zinc-500 text-sm mb-6">Selecciona el rango de cotizaciones para generar el reporte.</p>
                                
                                <div className="space-y-4 mb-8">
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Cotización Inicial</label>
                                        <input
                                            type="number"
                                            value={idIni}
                                            onChange={(e) => setIdIni(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                            placeholder="Ej. 1"
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Cotización Final</label>
                                        <input
                                            type="number"
                                            value={idFin}
                                            onChange={(e) => setIdFin(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                            placeholder="Ej. 100"
                                        />
                                    </div>
                                </div>

                                {/* Selector de Formato de Cotización */}
                                {quotationFormats.length > 0 && (
                                    <div className="space-y-2 mb-6">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Formato de Cotización</label>
                                        <select
                                            value={selectedFormatId ?? ''}
                                            onChange={e => setSelectedFormatId(e.target.value ? parseInt(e.target.value) : null)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none dark:text-white"
                                        >
                                            <option value="">Formato Predeterminado</option>
                                            {quotationFormats.map((fmt: any) => (
                                                <option key={fmt.id} value={fmt.id}>{fmt.name}</option>
                                            ))}
                                        </select>
                                    </div>
                                )}

                                <div className="flex gap-4">
                                    <button
                                        onClick={() => setIsPrintModalOpen(false)}
                                        className="flex-1 h-12 rounded-xl bg-zinc-100 dark:bg-zinc-800 font-bold text-zinc-600 hover:bg-zinc-200 transition-all"
                                    >
                                        Cancelar
                                    </button>
                                    <button
                                        onClick={() => {
                                            if (idIni && idFin) {
                                                const fmtParam = selectedFormatId ? `&formatId=${selectedFormatId}` : ''
                                                window.open(`/dashboard/quotations/print?idIni=${idIni}&idFin=${idFin}${fmtParam}`, '_blank');
                                                setIsPrintModalOpen(false);
                                            } else {
                                                alert("Ingresa ambos IDs para continuar.");
                                            }
                                        }}
                                        className="flex-1 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-black shadow-lg shadow-blue-500/20 transition-all flex items-center justify-center gap-2"
                                    >
                                        <Printer className="w-4 h-4" />
                                        Generar
                                    </button>
                                </div>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Modal para Cambiar Estado */}
            <AnimatePresence>
                {selectedQuotationForState && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-900/40 backdrop-blur-sm"
                    >
                        <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.95, opacity: 0 }}
                            className="bg-white dark:bg-zinc-900 rounded-3xl w-full max-w-md shadow-2xl border border-zinc-200 dark:border-zinc-800 overflow-hidden"
                        >
                            <div className="p-8">
                                <h3 className="text-2xl font-black text-zinc-900 dark:text-white mb-2">Cambiar Estado</h3>
                                <p className="text-zinc-500 text-sm mb-6">Actualiza el estado de la cotización #{selectedQuotationForState.id}.</p>
                                
                                <div className="space-y-4 mb-8">
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Nuevo Estado</label>
                                        <select
                                            value={newState}
                                            onChange={(e) => setNewState(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none dark:text-white"
                                        >
                                            {states.map((s: any) => (
                                                <option key={s.id || s.code} value={s.code}>{s.name.toUpperCase()}</option>
                                            ))}
                                        </select>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Descripción del Cambio</label>
                                        <textarea
                                            value={stateDescription}
                                            onChange={(e) => setStateDescription(e.target.value)}
                                            className="w-full h-24 bg-zinc-50 dark:bg-zinc-800 rounded-2xl p-4 border-none shadow-inner text-sm font-semibold focus:ring-2 focus:ring-blue-500 transition-all outline-none resize-none dark:text-white"
                                            placeholder="Ej. Cambio de tarifas solicitadas por el cliente..."
                                        />
                                    </div>
                                </div>

                                <div className="flex gap-4">
                                    <button
                                        onClick={() => setSelectedQuotationForState(null)}
                                        disabled={savingState}
                                        className="flex-1 h-12 rounded-xl bg-zinc-100 dark:bg-zinc-800 font-bold text-zinc-600 dark:text-zinc-300 hover:bg-zinc-200 transition-all disabled:opacity-50"
                                    >
                                        Cancelar
                                    </button>
                                    <button
                                        onClick={handleSaveState}
                                        disabled={savingState}
                                        className="flex-1 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-black shadow-lg shadow-blue-500/20 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
                                    >
                                        {savingState ? 'Guardando...' : 'Guardar'}
                                    </button>
                                </div>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    )
}
