'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
    Search,
    FileText,
    Calendar,
    ArrowRight,
    Loader2,
    Download,
    Edit,
    Trash2,
    Printer,
    Receipt,
    Copy,
    CopyPlus,
    FileSpreadsheet,
    ArrowUp,
    ArrowDown,
    MoreVertical,
    RefreshCw,
    FileCode,
    Eye,
    X,
    CheckCircle2,
    Database,
    Upload,
    FileDown,
    Send,
    Plus,
    AlertCircle,
    ExternalLink,
    Check
} from 'lucide-react'
import { format } from 'date-fns'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import * as XLSX from 'xlsx'
import QuotationInvoiceModal from './QuotationInvoiceModal'
import ExcelImportQuotations from '@/components/excel-import-quotations'
import { downloadQuotationTemplate } from '@/lib/excel-templates'

export default function QuotationsListPage() {
    const router = useRouter()
    const [quotations, setQuotations] = useState<any[]>([])
    const [states, setStates] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [isImportOpen, setIsImportOpen] = useState(false)
    const [duplicatingId, setDuplicatingId] = useState<number | null>(null)
    const [exportingXmlId, setExportingXmlId] = useState<number | null>(null)
    
    // Filtros de búsqueda
    const [filterReferencia, setFilterReferencia] = useState('')
    const [filterFechaDesde, setFilterFechaDesde] = useState('')
    const [filterFechaHasta, setFilterFechaHasta] = useState('')
    const [filterCliente, setFilterCliente] = useState('')
    const [filterElaboradoPor, setFilterElaboradoPor] = useState('')
    const [filterMontoTotal, setFilterMontoTotal] = useState('')
    const [filterEstado, setFilterEstado] = useState('')
    const [filterReserva, setFilterReserva] = useState('')
    const [filterPasajero, setFilterPasajero] = useState('')

    // Ordenamiento por ID (Por defecto DESC por ID de mayor a menor)
    const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc')

    // Paginación
    const [currentPage, setCurrentPage] = useState(1)
    const [pageSize, setPageSize] = useState<number>(25)

    const [selectedIds, setSelectedIds] = useState<number[]>([])
    const [isInvoiceModalOpen, setIsInvoiceModalOpen] = useState(false)
    const [invoiceQuotationId, setInvoiceQuotationId] = useState<number | null>(null)
    const [activeMenuId, setActiveMenuId] = useState<number | null>(null)

    // Modal de Cambio de Estado
    const [selectedQuotationForState, setSelectedQuotationForState] = useState<any | null>(null)
    const [newState, setNewState] = useState('')
    const [stateDescription, setStateDescription] = useState('')
    const [savingState, setSavingState] = useState(false)

    // Modal de Detalle
    const [detailQuotation, setDetailQuotation] = useState<any | null>(null)

    // Modal de Resultado de Exportación a Zeus ERP (Copiable y con link a Diagnóstico)
    const [exportModal, setExportModal] = useState<{
        isOpen: boolean;
        isError: boolean;
        title: string;
        message: string;
        traceCode?: string;
        items?: Array<{
            cotDisplay: string;
            statusType: 'success' | 'warning' | 'error';
            message: string;
            idZeus?: string | number;
        }>;
    }>({
        isOpen: false,
        isError: false,
        title: '',
        message: '',
        items: []
    })
    const [copiedTrace, setCopiedTrace] = useState(false)
    const [copiedDetails, setCopiedDetails] = useState(false)

    const [dbInfo, setDbInfo] = useState<{ isSQLServer: boolean; shortName: string; dbName: string; name: string } | null>(null)

    const fetchQuotations = async (filters?: {
        referencia?: string;
        fechaDesde?: string;
        fechaHasta?: string;
        cliente?: string;
        elaboradoPor?: string;
        montoTotal?: string;
        estado?: string;
        reserva?: string;
        pasajero?: string;
    }) => {
        setLoading(true)
        try {
            const params = new URLSearchParams()
            if (filters) {
                if (filters.referencia) params.append('referencia', filters.referencia)
                if (filters.fechaDesde) params.append('fechaDesde', filters.fechaDesde)
                if (filters.fechaHasta) params.append('fechaHasta', filters.fechaHasta)
                if (filters.cliente) params.append('cliente', filters.cliente)
                if (filters.elaboradoPor) params.append('elaboradoPor', filters.elaboradoPor)
                if (filters.montoTotal) params.append('montoTotal', filters.montoTotal)
                if (filters.estado) params.append('estado', filters.estado)
                if (filters.reserva) params.append('reserva', filters.reserva)
                if (filters.pasajero) params.append('pasajero', filters.pasajero)
            }

            const url = `/api/quotations/history?${params.toString()}`

            const [quoRes, statesRes, dbRes] = await Promise.all([
                fetch(url).then(res => (res.ok ? res.json() : [])).catch(() => []),
                fetch('/api/config/quotation-states').then(res => (res.ok ? res.json() : [])).catch(() => []),
                fetch('/api/config/db-provider').then(res => (res.ok ? res.json() : null)).catch(() => null)
            ])

            if (dbRes) setDbInfo(dbRes)
            setQuotations(Array.isArray(quoRes) ? quoRes : [])
            setCurrentPage(1)
            if (Array.isArray(statesRes) && statesRes.length > 0) {
                setStates(statesRes)
            } else {
                setStates([
                    { code: 'NUEVO', name: 'Nuevo', color: 'blue' },
                    { code: 'ENVIADO', name: 'Enviado', color: 'emerald' },
                    { code: 'APROBADO', name: 'Aprobado', color: 'emerald' },
                    { code: 'RECHAZADO', name: 'Rechazado', color: 'red' },
                    { code: 'CANCELADO', name: 'Cancelado', color: 'zinc' }
                ])
            }
        } catch (error) {
            console.error('Error fetching history:', error)
        } finally {
            setLoading(false)
        }
    }

    const handleApplyFilters = () => {
        setCurrentPage(1)
        fetchQuotations({
            referencia: filterReferencia,
            fechaDesde: filterFechaDesde,
            fechaHasta: filterFechaHasta,
            cliente: filterCliente,
            elaboradoPor: filterElaboradoPor,
            montoTotal: filterMontoTotal,
            estado: filterEstado,
            reserva: filterReserva,
            pasajero: filterPasajero
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
        setFilterReserva('')
        setFilterPasajero('')
        setCurrentPage(1)
        fetchQuotations({})
    }

    useEffect(() => {
        fetchQuotations()
    }, [])

    // Aplicar ordenamiento estricto por ID de Cotización
    const sortedQs = [...quotations].sort((a, b) => {
        const numA = Number(a.id) || 0;
        const numB = Number(b.id) || 0;
        return sortDirection === 'asc' ? numA - numB : numB - numA;
    })

    const filteredQs = sortedQs

    // Cálculos de paginación
    const totalItems = filteredQs.length
    const effectivePageSize = pageSize > 0 ? pageSize : Math.max(totalItems, 1)
    const totalPages = Math.max(1, Math.ceil(totalItems / effectivePageSize))
    const safeCurrentPage = Math.min(currentPage, totalPages)
    const startIdx = totalItems === 0 ? 0 : (safeCurrentPage - 1) * effectivePageSize
    const endIdx = Math.min(startIdx + effectivePageSize, totalItems)
    const paginatedQs = pageSize > 0 ? filteredQs.slice(startIdx, endIdx) : filteredQs

    const handleToggleSort = () => {
        setSortDirection(prev => prev === 'asc' ? 'desc' : 'asc')
        setCurrentPage(1)
    }

    const handleSelectAll = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.checked) {
            setSelectedIds(filteredQs.map(q => q.id))
        } else {
            setSelectedIds([])
        }
    }

    const handleSelectOne = (id: number) => {
        setSelectedIds(prev =>
            prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
        )
    }

    // Guardar Cambio de Estado
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

    // Exportar XML individual
    const handleExportSingleXml = async (q: any) => {
        setExportingXmlId(q.id)
        try {
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            const res = await fetch('/api/quotations/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: [q.id],
                    userId: user.id || 1,
                    exportType: 'QUOTATION'
                })
            });
            const data = await res.json();
            if (!res.ok) {
                alert("ERROR AL EXPORTAR XML:\n" + (data.message || "Error desconocido"));
                return;
            }
            if (data.xml) {
                const blob = new Blob([data.xml], { type: 'application/xml' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `Cotizacion_${q.id}.xml`;
                document.body.appendChild(a);
                a.click();
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);
            }
            alert(`✅ XML de la Cotización #${q.id} generado exitosamente.`);
        } catch (err: any) {
            console.error(err);
            alert("Error al exportar XML: " + err.message);
        } finally {
            setExportingXmlId(null)
        }
    }

    // Copiar resultado completo a Excel (Portapapeles TSV/HTML)
    const handleCopyToClipboard = () => {
        const listToCopy = selectedIds.length > 0
            ? filteredQs.filter(q => selectedIds.includes(q.id))
            : filteredQs;

        if (listToCopy.length === 0) {
            alert('No hay cotizaciones para copiar.')
            return
        }

        const headers = ['ID', 'No. Interno', 'Fecha', 'Reserva / Localizador', 'Cliente', 'Pasajero / Titular', 'Elaborado por', 'Proveedor', 'Noches', 'Monto Total', 'Moneda', 'Estado']
        
        const rows = listToCopy.map(q => [
            q.id,
            q.internalNumber || '',
            format(new Date(q.createdAt || new Date()), 'dd/MM/yyyy'),
            q.reservationCode || '',
            q.clientName || '',
            q.passengerName || 'Mismo titular',
            q.userName || '',
            q.providerName || '',
            q.nights || 1,
            q.totalAmount,
            q.currency || 'USD',
            q.state || 'NUEVO'
        ])

        const tsvContent = [
            headers.join('\t'),
            ...rows.map(row => row.join('\t'))
        ].join('\n')

        const htmlContent = `
            <table>
                <thead>
                    <tr>${headers.map(h => `<th style="background-color:#f4f4f5;font-weight:bold;">${h}</th>`).join('')}</tr>
                </thead>
                <tbody>
                    ${rows.map(row => `<tr>${row.map(cell => `<td>${cell}</td>`).join('')}</tr>`).join('')}
                </tbody>
            </table>
        `

        try {
            const blobText = new Blob([tsvContent], { type: 'text/plain' })
            const blobHtml = new Blob([htmlContent], { type: 'text/html' })
            const clipboardItem = new ClipboardItem({
                'text/plain': blobText,
                'text/html': blobHtml
            })
            navigator.clipboard.write([clipboardItem]).then(() => {
                alert(`✅ ${listToCopy.length} cotización(es) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`)
            }).catch(() => {
                navigator.clipboard.writeText(tsvContent)
                alert(`✅ ${listToCopy.length} cotización(es) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`)
            })
        } catch (err) {
            navigator.clipboard.writeText(tsvContent)
            alert(`✅ ${listToCopy.length} cotización(es) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`)
        }
    }

    // Exportar a Excel (.xlsx)
    const handleDownloadExcel = () => {
        const listToDownload = selectedIds.length > 0
            ? filteredQs.filter(q => selectedIds.includes(q.id))
            : filteredQs;

        if (listToDownload.length === 0) {
            alert('No hay cotizaciones para exportar a Excel.')
            return
        }

        const dataForExcel = listToDownload.map(q => ({
            'ID Cotización': q.id,
            'No. Referencia': q.internalNumber || '',
            'Fecha': format(new Date(q.createdAt || new Date()), 'dd/MM/yyyy'),
            'Reserva / Localizador': q.reservationCode || '',
            'Cliente': q.clientName || '',
            'Pasajero / Titular': q.passengerName || 'Mismo titular',
            'Elaborado por': q.userName || '',
            'Proveedor': q.providerName || '',
            'Noches': q.nights || 1,
            'Monto Total': parseFloat(q.totalAmount) || 0,
            'Moneda': q.currency || 'USD',
            'Estado': q.state || 'NUEVO'
        }))

        const worksheet = XLSX.utils.json_to_sheet(dataForExcel)
        const workbook = XLSX.utils.book_new()
        XLSX.utils.book_append_sheet(workbook, worksheet, 'Cotizaciones')
        XLSX.writeFile(workbook, `Historial_Cotizaciones_${format(new Date(), 'yyyyMMdd_HHmmss')}.xlsx`)
    }

    // Exportar a Zeus ERP
    const handleExportZeus = async () => {
        if (selectedIds.length === 0) {
            setExportModal({
                isOpen: true,
                isError: true,
                title: 'Selección requerida',
                message: 'Por favor selecciona al menos una cotización para exportar a Zeus ERP.',
                items: []
            })
            return
        }

        try {
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            const res = await fetch('/api/quotations/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: selectedIds,
                    userId: user.id || 1,
                    exportType: 'QUOTATION'
                })
            });

            const data = await res.json();

            if (!res.ok) {
                setExportModal({
                    isOpen: true,
                    isError: true,
                    title: 'Error de exportación a Zeus ERP',
                    message: data.message || 'Error desconocido al conectar con Zeus ERP.',
                    traceCode: data.traceCode,
                    items: []
                });
                return;
            }

            if (data.success) {
                const items: Array<{
                    cotDisplay: string;
                    statusType: 'success' | 'warning' | 'error';
                    message: string;
                    idZeus?: string | number;
                }> = [];

                if (data.spResult && data.spResult.length > 0) {
                    data.spResult.forEach((row: any) => {
                        const cotNum = row.Cotizacion || row.cd_consecutivo || row.IdProcesado || selectedIds.join(', ');
                        const cotDisplay = String(cotNum).startsWith('#') ? String(cotNum) : `#${cotNum}`;
                        const idZeus = row.IdProcesado || row.id_Cotizacion || row.id;
                        const isAlreadyExisted = row.bl_existe === 1 || row.bl_existe === true || (row.Estado && String(row.Estado).toLowerCase().includes('ya existe'));
                        const resp = String(row.Respuesta || row.respuesta || row.Estado || '').toLowerCase();
                        const isErr = resp.includes('error') || resp.includes('no existe') || resp.includes('no válido') || resp.includes('no valido');

                        if (isErr) {
                            items.push({
                                cotDisplay,
                                statusType: 'error',
                                message: row.Respuesta || row.respuesta || row.Estado || 'Error al procesar en Zeus ERP',
                                idZeus
                            });
                        } else if (isAlreadyExisted) {
                            items.push({
                                cotDisplay,
                                statusType: 'warning',
                                message: 'Ya existe registrada en Zeus ERP',
                                idZeus
                            });
                        } else {
                            items.push({
                                cotDisplay,
                                statusType: 'success',
                                message: 'Creada exitosamente en Zeus ERP',
                                idZeus
                            });
                        }
                    });
                }

                setExportModal({
                    isOpen: true,
                    isError: false,
                    title: 'Exportación a Zeus ERP Completada',
                    message: data.message || 'El proceso de exportación finalizó correctamente.',
                    traceCode: data.traceCode,
                    items
                });
                fetchQuotations();
            } else {
                setExportModal({
                    isOpen: true,
                    isError: true,
                    title: 'Error en Zeus ERP',
                    message: data.message || 'Ocurrió un problema durante la exportación a Zeus ERP.',
                    traceCode: data.traceCode,
                    items: []
                });
            }

        } catch (error: any) {
            console.error('Export error:', error);
            setExportModal({
                isOpen: true,
                isError: true,
                title: 'Error crítico de comunicación',
                message: `No fue posible conectar con el servidor: ${error.message}`,
                items: []
            });
        }
    }

    const handleDelete = async (id: number) => {
        if (!confirm('¿Estás seguro de que deseas eliminar esta cotización? Esta acción no se puede deshacer.')) return;
        try {
            const res = await fetch(`/api/quotations/${id}`, {
                method: 'DELETE',
                headers: {
                    'X-User-Id': JSON.parse(localStorage.getItem('user') || '{}').id?.toString() || ''
                }
            });
            if (res.ok) {
                setQuotations(quotations.filter(q => q.id !== id));
            } else {
                const error = await res.json();
                alert(`Error: ${error.message}`);
            }
        } catch (error) {
            console.error('Error deleting quotation:', error);
            alert('Ocurrió un error al eliminar la cotización.');
        }
    }

    const handleDuplicate = async (id: number) => {
        if (!confirm(`¿Estás seguro de duplicar la cotización #${id}? Se generará una nueva cotización idéntica con un nuevo consecutivo para que puedas editarla.`)) return;
        setDuplicatingId(id);
        try {
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            const res = await fetch(`/api/quotations/${id}/duplicate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': user.id?.toString() || '1'
                }
            });
            const data = await res.json();
            if (res.ok && data.newQuotationId) {
                const consecutiveDisplay = data.internalNumber ? (data.internalNumber.startsWith('#') ? data.internalNumber : '#' + data.internalNumber) : `#${data.newQuotationId}`;
                alert(`✅ Cotización duplicada exitosamente. Se ha creado la nueva cotización ${consecutiveDisplay}. Redirigiendo a la pantalla de edición...`);
                router.push(`/dashboard/quotations/${data.newQuotationId}/edit`);
            } else {
                alert(`❌ Error al duplicar cotización: ${data.message}`);
            }
        } catch (error: any) {
            console.error('Error duplicating quotation:', error);
            alert('Ocurrió un error al duplicar la cotización.');
        } finally {
            setDuplicatingId(null);
        }
    }

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-4 sm:p-6 max-w-[1700px] mx-auto">
            <header className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-5">
                <div>
                    <h1 className="text-2xl md:text-3xl font-black text-zinc-900 dark:text-white flex items-center gap-2.5 tracking-tight flex-wrap">
                        <FileText className="w-7 h-7 text-blue-600 shrink-0" /> Historial de Cotizaciones
                        {dbInfo && (
                            <span className={`px-3 py-1 rounded-xl text-xs font-black border flex items-center gap-1.5 shadow-xs ${
                                dbInfo.isSQLServer 
                                    ? 'bg-amber-500/10 border-amber-500/30 text-amber-600 dark:text-amber-400' 
                                    : 'bg-blue-500/10 border-blue-500/30 text-blue-600 dark:text-blue-400'
                            }`}>
                                <Database className="w-3.5 h-3.5" />
                                {dbInfo.shortName} ({dbInfo.dbName})
                            </span>
                        )}
                    </h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium text-xs md:text-sm mt-0.5">Consulta y administra todas las cotizaciones emitidas</p>
                </div>
                <div className="flex items-center gap-2.5 shrink-0 flex-wrap">
                    <button
                        onClick={handleExportZeus}
                        disabled={selectedIds.length === 0}
                        className={`px-4 h-10 rounded-xl flex items-center gap-2 text-xs font-bold transition-all cursor-pointer active:scale-95 ${
                            selectedIds.length > 0
                            ? "bg-blue-600 hover:bg-blue-700 text-white shadow-md shadow-blue-500/20"
                            : "bg-zinc-200 text-zinc-400 dark:bg-zinc-800 dark:text-zinc-600 cursor-not-allowed"
                        }`}
                        title="Exportar cotizaciones seleccionadas a Zeus ERP"
                    >
                        <Send className="w-4 h-4" />
                        Exportar Zeus ERP {selectedIds.length > 0 ? `(${selectedIds.length})` : ''}
                    </button>

                    <button
                        onClick={downloadQuotationTemplate}
                        className="px-3.5 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/30 rounded-xl shadow-xs font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                        title="Descargar plantilla Excel para importación de cotizaciones"
                    >
                        <FileDown className="w-4 h-4" /> Descargar Plantilla
                    </button>

                    <button
                        onClick={() => setIsImportOpen(!isImportOpen)}
                        className="px-3.5 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl shadow-xs font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                        title="Importar cotizaciones desde archivo Excel"
                    >
                        <Upload className="w-4 h-4" /> Importar Excel
                    </button>

                    <Link href="/dashboard/quotations/new">
                        <button className="px-4 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-md font-bold transition-all flex items-center gap-2 text-xs cursor-pointer active:scale-95">
                            <Plus className="w-4 h-4" /> Nueva Cotización
                        </button>
                    </Link>
                </div>
            </header>

            <AnimatePresence>
                {isImportOpen && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden mb-5"
                    >
                        <ExcelImportQuotations onImportSuccess={fetchQuotations} />
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Filtros Avanzados */}
            <div className="bg-white dark:bg-zinc-900/50 p-4 sm:p-5 rounded-2xl border border-zinc-200 dark:border-zinc-800 mb-5 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                    <Calendar className="w-4 h-4 text-blue-600" />
                    <h2 className="text-xs font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-widest">Filtros de Búsqueda</h2>
                </div>
                
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
                    {/* Referencia */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Referencia / ID</label>
                        <input
                            type="text"
                            placeholder="Ej. 5 o 01-10..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterReferencia}
                            onChange={(e) => setFilterReferencia(e.target.value)}
                        />
                    </div>

                    {/* Reserva / Localizador */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Reserva / Localizador</label>
                        <input
                            type="text"
                            placeholder="Ej. ABC123..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterReserva}
                            onChange={(e) => setFilterReserva(e.target.value)}
                        />
                    </div>

                    {/* Pasajero */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Pasajero</label>
                        <input
                            type="text"
                            placeholder="Nombre del pasajero..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterPasajero}
                            onChange={(e) => setFilterPasajero(e.target.value)}
                        />
                    </div>
                    
                    {/* Cliente */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Cliente</label>
                        <input
                            type="text"
                            placeholder="Nombre del cliente..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterCliente}
                            onChange={(e) => setFilterCliente(e.target.value)}
                        />
                    </div>

                    {/* Elaborado por */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Elaborado por</label>
                        <input
                            type="text"
                            placeholder="Nombre vendedor..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterElaboradoPor}
                            onChange={(e) => setFilterElaboradoPor(e.target.value)}
                        />
                    </div>

                    {/* Estado */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Estado</label>
                        <select
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-2.5 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-semibold"
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
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Fecha Desde</label>
                        <input
                            type="date"
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterFechaDesde}
                            onChange={(e) => setFilterFechaDesde(e.target.value)}
                        />
                    </div>

                    {/* Fecha Hasta */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Fecha Hasta</label>
                        <input
                            type="date"
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterFechaHasta}
                            onChange={(e) => setFilterFechaHasta(e.target.value)}
                        />
                    </div>

                    {/* Monto Total */}
                    <div className="flex flex-col gap-1">
                        <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest pl-1">Monto Total</label>
                        <input
                            type="number"
                            placeholder="Monto exacto..."
                            className="h-9 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700/50 text-xs outline-none focus:ring-2 focus:ring-blue-500 text-zinc-700 dark:text-zinc-200 font-medium"
                            value={filterMontoTotal}
                            onChange={(e) => setFilterMontoTotal(e.target.value)}
                        />
                    </div>

                    {/* Acciones de Filtro */}
                    <div className="flex items-end gap-2 h-9 mt-auto col-span-2 sm:col-span-1 lg:col-span-1">
                        <button
                            onClick={handleApplyFilters}
                            className="flex-1 h-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold text-xs shadow-md shadow-blue-500/10 flex items-center justify-center gap-1.5 transition-all active:scale-[0.98]"
                        >
                            <Search className="w-3.5 h-3.5" /> Buscar
                        </button>
                        <button
                            onClick={handleClearFilters}
                            className="h-full px-3 border border-zinc-200 dark:border-zinc-700 text-zinc-500 hover:text-zinc-700 dark:text-zinc-400 dark:hover:text-zinc-200 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl font-bold text-[11px] uppercase tracking-wider transition-all"
                            title="Limpiar filtros"
                        >
                            Limpiar
                        </button>
                    </div>
                </div>
            </div>

            {/* Contenedor de Tabla con Barra de Herramientas de Exportación */}
            <div className="w-full max-w-full overflow-hidden bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-sm min-h-[450px]">
                {/* Barra Superior de Herramientas Excel y Paginación */}
                <div className="flex flex-wrap items-center justify-between gap-3 px-5 py-3.5 bg-zinc-50 dark:bg-zinc-800/40 border-b border-zinc-200 dark:border-zinc-800 rounded-t-2xl">
                    <div className="flex flex-wrap items-center gap-3 text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                        <span>Total cotizaciones: <strong className="text-blue-600 dark:text-blue-400 font-black text-sm">{totalItems}</strong></span>
                        {totalItems > 0 && (
                            <span className="text-zinc-500 dark:text-zinc-400 font-medium">
                                (Mostrando <strong className="text-zinc-800 dark:text-zinc-200">{startIdx + 1}</strong> a <strong className="text-zinc-800 dark:text-zinc-200">{endIdx}</strong>)
                            </span>
                        )}
                        <div className="flex items-center gap-1.5 ml-1">
                            <span className="text-[11px] text-zinc-500 dark:text-zinc-400">Mostrar:</span>
                            <select
                                value={pageSize}
                                onChange={(e) => {
                                    setPageSize(Number(e.target.value));
                                    setCurrentPage(1);
                                }}
                                className="h-7 px-2 rounded-lg bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 text-xs font-bold text-zinc-700 dark:text-zinc-200 outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
                            >
                                <option value={10}>10</option>
                                <option value={25}>25</option>
                                <option value={50}>50</option>
                                <option value={100}>100</option>
                                <option value={200}>200</option>
                                <option value={500}>500</option>
                                <option value={0}>Todas</option>
                            </select>
                        </div>
                        {selectedIds.length > 0 && (
                            <span className="px-2.5 py-0.5 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300 text-[11px] font-bold">
                                {selectedIds.length} seleccionada(s)
                            </span>
                        )}
                    </div>

                    <div className="flex flex-wrap items-center gap-2">
                        {totalPages > 1 && (
                            <div className="flex items-center gap-1 mr-2 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 rounded-xl px-1.5 py-1">
                                <button
                                    onClick={() => setCurrentPage(1)}
                                    disabled={safeCurrentPage <= 1}
                                    className="px-2 py-0.5 text-[11px] font-bold rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                                    title="Primera página"
                                >
                                    «
                                </button>
                                <button
                                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                    disabled={safeCurrentPage <= 1}
                                    className="px-2 py-0.5 text-[11px] font-bold rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                                    title="Página anterior"
                                >
                                    ‹ Ant
                                </button>
                                <span className="px-2 text-[11px] font-bold text-zinc-700 dark:text-zinc-300">
                                    Pág. <strong className="text-blue-600 dark:text-blue-400">{safeCurrentPage}</strong> de {totalPages}
                                </span>
                                <button
                                    onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                                    disabled={safeCurrentPage >= totalPages}
                                    className="px-2 py-0.5 text-[11px] font-bold rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                                    title="Página siguiente"
                                >
                                    Sig ›
                                </button>
                                <button
                                    onClick={() => setCurrentPage(totalPages)}
                                    disabled={safeCurrentPage >= totalPages}
                                    className="px-2 py-0.5 text-[11px] font-bold rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                                    title="Última página"
                                >
                                    »
                                </button>
                            </div>
                        )}

                        <button
                            onClick={handleCopyToClipboard}
                            className="px-3.5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl shadow-sm font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                            title="Copiar cotizaciones al portapapeles para pegar en Excel (Ctrl+V)"
                        >
                            <Copy className="w-3.5 h-3.5" /> Copiar a Excel
                        </button>

                        <button
                            onClick={handleDownloadExcel}
                            className="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl shadow-sm font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                            title="Descargar archivo Excel (.xlsx)"
                        >
                            <FileSpreadsheet className="w-3.5 h-3.5" /> Excel (.xlsx)
                        </button>
                    </div>
                </div>

                {loading ? (
                    <div className="flex items-center justify-center h-[400px]">
                        <Loader2 className="animate-spin w-10 h-10 text-blue-600" />
                    </div>
                ) : filteredQs.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-[400px] text-zinc-400">
                        <FileText className="w-16 h-16 mb-4 opacity-20" />
                        <h3 className="text-xl font-bold text-zinc-600 dark:text-zinc-300 mb-1">No hay cotizaciones</h3>
                        <p className="text-xs">Aún no se ha emitido ninguna o no coincide con la búsqueda.</p>
                    </div>
                ) : (
                    <>
                    <div className="overflow-x-auto w-full min-h-[420px] pb-36">
                        <table className="w-full min-w-[900px] text-left border-collapse text-xs md:text-sm">
                            <thead className="bg-zinc-50/70 dark:bg-zinc-800/40">
                                <tr>
                                    <th className="px-4 py-3.5 w-10 border-b border-zinc-200 dark:border-zinc-800">
                                        <input
                                            type="checkbox"
                                            className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                            checked={selectedIds.length === filteredQs.length && filteredQs.length > 0}
                                            onChange={handleSelectAll}
                                        />
                                    </th>
                                    <th 
                                        onClick={handleToggleSort} 
                                        className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 cursor-pointer hover:text-blue-600 transition-colors select-none whitespace-nowrap"
                                        title="Hacer clic para alternar orden por ID de Cotización"
                                    >
                                        <div className="flex items-center gap-1.5" data-pagination-controls="true">
                                            <span>ID Cotización</span>
                                            {sortDirection === 'asc' ? <ArrowUp className="w-3.5 h-3.5 text-blue-600" /> : <ArrowDown className="w-3.5 h-3.5 text-blue-600" />}
                                        </div>
                                    </th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap min-w-[120px]">Reserva / Localizador</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Fecha</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap min-w-[160px]">Cliente</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap min-w-[120px]">Elaborado por</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Monto Total</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Estado</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 text-right whitespace-nowrap sticky right-0 bg-zinc-50 dark:bg-zinc-800/95 backdrop-blur-sm z-10 shadow-[-4px_0_8px_-2px_rgba(0,0,0,0.06)]">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                                {paginatedQs.map((q, qIndex) => (
                                    <tr key={q.id} className={`group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all ${selectedIds.includes(q.id) ? 'bg-blue-50/50 dark:bg-blue-900/10' : ''}`}>
                                        <td className="px-4 py-3.5">
                                            <input
                                                type="checkbox"
                                                className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                checked={selectedIds.includes(q.id)}
                                                onChange={() => handleSelectOne(q.id)}
                                            />
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap">
                                            <div className="font-black text-zinc-900 dark:text-white text-xs md:text-sm flex items-center gap-1.5">
                                                <span>#{q.id}</span>
                                            </div>
                                            {q.internalNumber && String(q.internalNumber) !== String(q.id) && (
                                                <div className="text-[10px] text-zinc-400 font-medium truncate max-w-[140px]" title={q.internalNumber}>
                                                    Ref: {q.internalNumber}
                                                </div>
                                            )}
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap max-w-[180px]">
                                            <div className="font-semibold text-zinc-800 dark:text-zinc-200 text-xs md:text-sm max-w-[170px] truncate" title={q.reservationCode || '-'}>
                                                {q.reservationCode || '-'}
                                            </div>
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap">
                                            <div className="flex items-center gap-1.5 text-zinc-600 dark:text-zinc-300 text-xs">
                                                <Calendar className="w-3.5 h-3.5 text-zinc-400" />
                                                <span>{format(new Date(q.createdAt || new Date()), 'dd/MM/yyyy')}</span>
                                            </div>
                                        </td>
                                        <td className="px-4 py-3.5 max-w-[220px]">
                                            <div className="font-bold text-zinc-900 dark:text-white text-xs md:text-sm max-w-[210px] truncate" title={q.clientName || 'Cliente'}>
                                                {q.clientName || 'Cliente'}
                                            </div>
                                            <div className="text-[11px] text-zinc-400 max-w-[210px] truncate" title={q.passengerName || 'Mismo titular'}>
                                                Pax: {q.passengerName || 'Mismo titular'}
                                            </div>
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap max-w-[160px]">
                                            <div className="font-medium text-zinc-700 dark:text-zinc-300 text-xs max-w-[150px] truncate" title={q.userName || 'Sistema'}>
                                                {q.userName || 'Sistema'}
                                            </div>
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap">
                                            <div className="font-black text-emerald-600 dark:text-emerald-400 text-xs md:text-sm tabular-nums">
                                                ${parseFloat(q.totalAmount).toLocaleString()} <span className="text-[10px] text-zinc-400 font-normal">{q.currency || 'COP'}</span>
                                            </div>
                                        </td>
                                        <td className="px-4 py-3.5 whitespace-nowrap">
                                            {(() => {
                                                const rawState = (q.state || 'NUEVO').trim();
                                                const stateUpper = rawState.toUpperCase();
                                                const matchedState = (states || []).find(
                                                    (s: any) =>
                                                        String(s.code || '').trim().toUpperCase() === stateUpper ||
                                                        String(s.name || '').trim().toUpperCase() === stateUpper
                                                );
                                                const rawColor = String(matchedState?.color || q.stateColor || '').trim().toLowerCase();

                                                let badgeClass = 'bg-blue-100 text-blue-700 border border-blue-200/80 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800/50';
                                                let inlineStyle: React.CSSProperties | undefined = undefined;

                                                if (rawColor.startsWith('#') || rawColor.startsWith('rgb')) {
                                                    badgeClass = 'border';
                                                    inlineStyle = {
                                                        backgroundColor: rawColor.startsWith('#') && rawColor.length === 7 ? `${rawColor}22` : rawColor,
                                                        color: rawColor,
                                                        borderColor: rawColor.startsWith('#') && rawColor.length === 7 ? `${rawColor}55` : rawColor
                                                    };
                                                } else if (['yellow', 'amarillo', 'amber', 'ámbar', 'ambar', 'gold', 'dorado'].includes(rawColor)) {
                                                    badgeClass = 'bg-amber-100 text-amber-800 border border-amber-300/80 dark:bg-amber-900/40 dark:text-amber-300 dark:border-amber-700/50';
                                                } else if (['green', 'verde', 'emerald', 'esmeralda', 'lime', 'lima'].includes(rawColor)) {
                                                    badgeClass = 'bg-emerald-100 text-emerald-800 border border-emerald-300/80 dark:bg-emerald-900/40 dark:text-emerald-300 dark:border-emerald-700/50';
                                                } else if (['red', 'rojo', 'rose', 'crimson', 'vino'].includes(rawColor)) {
                                                    badgeClass = 'bg-red-100 text-red-700 border border-red-300/80 dark:bg-red-900/30 dark:text-red-400 dark:border-red-700/50';
                                                } else if (['orange', 'naranja', 'anaranjado'].includes(rawColor)) {
                                                    badgeClass = 'bg-orange-100 text-orange-800 border border-orange-300/80 dark:bg-orange-900/40 dark:text-orange-300 dark:border-orange-700/50';
                                                } else if (['purple', 'morado', 'violet', 'violeta', 'lila', 'fuchsia', 'fucsia'].includes(rawColor)) {
                                                    badgeClass = 'bg-purple-100 text-purple-800 border border-purple-300/80 dark:bg-purple-900/40 dark:text-purple-300 dark:border-purple-700/50';
                                                } else if (['cyan', 'celeste', 'teal', 'turquesa', 'sky', 'aqua'].includes(rawColor)) {
                                                    badgeClass = 'bg-cyan-100 text-cyan-800 border border-cyan-300/80 dark:bg-cyan-900/40 dark:text-cyan-300 dark:border-cyan-700/50';
                                                } else if (['indigo', 'añil', 'anil', 'navy', 'azul oscuro'].includes(rawColor)) {
                                                    badgeClass = 'bg-indigo-100 text-indigo-800 border border-indigo-300/80 dark:bg-indigo-900/40 dark:text-indigo-300 dark:border-indigo-700/50';
                                                } else if (['pink', 'rosa', 'rosado'].includes(rawColor)) {
                                                    badgeClass = 'bg-pink-100 text-pink-800 border border-pink-300/80 dark:bg-pink-900/40 dark:text-pink-300 dark:border-pink-700/50';
                                                } else if (['gray', 'grey', 'gris', 'zinc', 'slate', 'neutral'].includes(rawColor)) {
                                                    badgeClass = 'bg-zinc-200 text-zinc-700 border border-zinc-300/80 dark:bg-zinc-800 dark:text-zinc-300 dark:border-zinc-700';
                                                } else if (['blue', 'azul'].includes(rawColor)) {
                                                    badgeClass = 'bg-blue-100 text-blue-700 border border-blue-200/80 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800/50';
                                                } else if (!rawColor) {
                                                    if (stateUpper === 'ENVIADO' || stateUpper === 'APROBADO' || stateUpper === 'FACTURADO') {
                                                        badgeClass = 'bg-emerald-100 text-emerald-700 border border-emerald-200/80 dark:bg-emerald-900/30 dark:text-emerald-400';
                                                    } else if (stateUpper.includes('RECHAZAD') || stateUpper.includes('ANULAD')) {
                                                        badgeClass = 'bg-red-100 text-red-700 border border-red-200/80 dark:bg-red-900/30 dark:text-red-400';
                                                    } else if (stateUpper.includes('CANCELAD')) {
                                                        badgeClass = 'bg-zinc-200 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-400';
                                                    }
                                                }

                                                return (
                                                    <span
                                                        style={inlineStyle}
                                                        className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider inline-block ${badgeClass}`}
                                                    >
                                                        {rawState}
                                                    </span>
                                                );
                                            })()}
                                        </td>
                                        <td className="px-4 py-3.5 text-right whitespace-nowrap sticky right-0 bg-white/95 dark:bg-zinc-900/95 group-hover:bg-zinc-50/95 dark:group-hover:bg-zinc-800/90 backdrop-blur-sm z-10 transition-colors shadow-[-4px_0_8px_-2px_rgba(0,0,0,0.06)]">
                                            <button
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    setActiveMenuId(activeMenuId === q.id ? null : q.id);
                                                }}
                                                className="p-1.5 px-3 text-zinc-600 dark:text-zinc-300 hover:text-blue-600 dark:hover:text-blue-400 bg-zinc-100 hover:bg-zinc-200/80 dark:bg-zinc-800 dark:hover:bg-zinc-700/80 rounded-xl transition-all font-bold text-xs inline-flex items-center gap-1.5 cursor-pointer active:scale-95 shadow-sm"
                                                title="Opciones de cotización"
                                            >
                                                <MoreVertical className="w-4 h-4" />
                                                <span>Acciones</span>
                                            </button>

                                            <AnimatePresence>
                                                {activeMenuId === q.id && (
                                                    <>
                                                        {/* Backdrop invisible para cerrar el menú al hacer clic fuera */}
                                                        <div
                                                            className="fixed inset-0 z-20 cursor-default"
                                                            onClick={(e) => {
                                                                e.stopPropagation();
                                                                setActiveMenuId(null);
                                                            }}
                                                        />
                                                        
                                                        {/* Menú Flotante de Acciones */}
                                                        {(() => {
                                                            const openUpwards = paginatedQs.length > 3 && qIndex >= paginatedQs.length - 2 && qIndex > 1;
                                                            return (
                                                                <motion.div
                                                                    initial={{ opacity: 0, scale: 0.95, y: openUpwards ? 4 : -4 }}
                                                                    animate={{ opacity: 1, scale: 1, y: 0 }}
                                                                    exit={{ opacity: 0, scale: 0.95, y: openUpwards ? 4 : -4 }}
                                                                    transition={{ duration: 0.12 }}
                                                                    className={`absolute right-4 ${openUpwards ? 'bottom-12' : 'top-12'} z-30 w-56 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-2xl p-1.5 space-y-0.5 text-left`}
                                                                >
                                                                    {/* 1. Duplicar */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    handleDuplicate(q.id);
                                                                }}
                                                                disabled={duplicatingId === q.id}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-indigo-600 dark:text-indigo-400 hover:bg-indigo-50 dark:hover:bg-indigo-500/10 rounded-xl transition-all flex items-center gap-2.5 disabled:opacity-50 cursor-pointer"
                                                            >
                                                                {duplicatingId === q.id ? (
                                                                    <Loader2 className="w-4 h-4 animate-spin text-indigo-600" />
                                                                ) : (
                                                                    <CopyPlus className="w-4 h-4 text-indigo-600 dark:text-indigo-400 shrink-0" />
                                                                )}
                                                                <span>Duplicar Cotización</span>
                                                            </button>

                                                            {/* 2. Facturar */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    setInvoiceQuotationId(q.id);
                                                                    setIsInvoiceModalOpen(true);
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <Receipt className="w-4 h-4 text-emerald-600 dark:text-emerald-400 shrink-0" />
                                                                <span>Facturar Cotización</span>
                                                            </button>

                                                            {/* 3. Imprimir */}
                                                            <Link
                                                                href={`/dashboard/quotations/print?idIni=${q.id}&idFin=${q.id}`}
                                                                target="_blank"
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <Printer className="w-4 h-4 text-blue-600 dark:text-blue-400 shrink-0" />
                                                                <span>Imprimir Cotización</span>
                                                            </Link>

                                                            {/* 4. Editar */}
                                                            <Link
                                                                href={`/dashboard/quotations/${q.id}/edit`}
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-amber-600 dark:text-amber-400 hover:bg-amber-50 dark:hover:bg-amber-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <Edit className="w-4 h-4 text-amber-600 dark:text-amber-400 shrink-0" />
                                                                <span>Editar Cotización</span>
                                                            </Link>

                                                            {/* 5. Cambiar Estado */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    setSelectedQuotationForState(q);
                                                                    setNewState(q.state || 'NUEVO');
                                                                    setStateDescription('');
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-purple-600 dark:text-purple-400 hover:bg-purple-50 dark:hover:bg-purple-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <RefreshCw className="w-4 h-4 text-purple-600 dark:text-purple-400 shrink-0" />
                                                                <span>Cambiar Estado</span>
                                                            </button>

                                                            {/* 6. Exportar XML */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    handleExportSingleXml(q);
                                                                }}
                                                                disabled={exportingXmlId === q.id}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-cyan-600 dark:text-cyan-400 hover:bg-cyan-50 dark:hover:bg-cyan-500/10 rounded-xl transition-all flex items-center gap-2.5 disabled:opacity-50 cursor-pointer"
                                                            >
                                                                {exportingXmlId === q.id ? (
                                                                    <Loader2 className="w-4 h-4 animate-spin text-cyan-600" />
                                                                ) : (
                                                                    <FileCode className="w-4 h-4 text-cyan-600 dark:text-cyan-400 shrink-0" />
                                                                )}
                                                                <span>Exportar XML</span>
                                                            </button>

                                                            {/* 7. Ver Detalle */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    setDetailQuotation(q);
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-teal-600 dark:text-teal-400 hover:bg-teal-50 dark:hover:bg-teal-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <Eye className="w-4 h-4 text-teal-600 dark:text-teal-400 shrink-0" />
                                                                <span>Ver Detalle</span>
                                                            </button>

                                                            <div className="h-px bg-zinc-100 dark:bg-zinc-800/80 my-1" />

                                                            {/* 8. Eliminar */}
                                                            <button
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    setActiveMenuId(null);
                                                                    handleDelete(q.id);
                                                                }}
                                                                className="w-full px-3 py-2 text-xs font-semibold text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all flex items-center gap-2.5 cursor-pointer"
                                                            >
                                                                <Trash2 className="w-4 h-4 text-red-600 dark:text-red-400 shrink-0" />
                                                                <span>Eliminar Cotización</span>
                                                            </button>
                                                         </motion.div>
                                                             );
                                                         })()}
                    </>
                                                )}
                                            </AnimatePresence>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>

                    {/* Barra Inferior de Paginación */}
                    <div className="flex flex-col sm:flex-row items-center justify-between gap-3 px-5 py-3.5 bg-zinc-50 dark:bg-zinc-800/40 border-t border-zinc-200 dark:border-zinc-800 rounded-b-2xl text-xs">
                        <div className="flex flex-wrap items-center gap-3 text-zinc-600 dark:text-zinc-400 font-medium">
                            <span>
                                Mostrando <strong className="text-zinc-900 dark:text-white">{totalItems === 0 ? 0 : startIdx + 1}</strong> a <strong className="text-zinc-900 dark:text-white">{endIdx}</strong> de <strong className="text-blue-600 dark:text-blue-400">{totalItems}</strong> cotizaciones
                            </span>
                            <div className="flex items-center gap-1.5">
                                <span>Filas por página:</span>
                                <select
                                    value={pageSize}
                                    onChange={(e) => {
                                        setPageSize(Number(e.target.value));
                                        setCurrentPage(1);
                                    }}
                                    className="h-8 px-2.5 rounded-lg bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 text-xs font-bold text-zinc-700 dark:text-zinc-200 outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
                                >
                                    <option value={10}>10</option>
                                    <option value={25}>25</option>
                                    <option value={50}>50</option>
                                    <option value={100}>100</option>
                                    <option value={200}>200</option>
                                    <option value={500}>500</option>
                                    <option value={0}>Todas</option>
                                </select>
                            </div>
                        </div>

                        <div className="flex items-center gap-1.5 flex-wrap justify-center">
                            <button
                                onClick={() => setCurrentPage(1)}
                                disabled={safeCurrentPage <= 1}
                                className="px-2.5 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 font-bold hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all cursor-pointer"
                                title="Ir a la primera página"
                            >
                                « Inicio
                            </button>
                            <button
                                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                disabled={safeCurrentPage <= 1}
                                className="px-3 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 font-bold hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all cursor-pointer"
                                title="Página anterior"
                            >
                                ‹ Anterior
                            </button>

                            {(() => {
                                const pages: number[] = [];
                                const maxButtons = 5;
                                let startPage = Math.max(1, safeCurrentPage - Math.floor(maxButtons / 2));
                                const endPage = Math.min(totalPages, startPage + maxButtons - 1);
                                if (endPage - startPage + 1 < maxButtons) {
                                    startPage = Math.max(1, endPage - maxButtons + 1);
                                }
                                for (let i = startPage; i <= endPage; i++) {
                                    pages.push(i);
                                }
                                return pages.map(p => (
                                    <button
                                        key={p}
                                        onClick={() => setCurrentPage(p)}
                                        className={`min-w-[32px] h-8 px-2 rounded-lg font-bold text-xs transition-all cursor-pointer ${
                                            p === safeCurrentPage
                                                ? 'bg-blue-600 text-white shadow-sm shadow-blue-500/20'
                                                : 'border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                                        }`}
                                    >
                                        {p}
                                    </button>
                                ));
                            })()}

                            <button
                                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                                disabled={safeCurrentPage >= totalPages}
                                className="px-3 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 font-bold hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all cursor-pointer"
                                title="Página siguiente"
                            >
                                Siguiente ›
                            </button>
                            <button
                                onClick={() => setCurrentPage(totalPages)}
                                disabled={safeCurrentPage >= totalPages}
                                className="px-2.5 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 font-bold hover:bg-zinc-100 dark:hover:bg-zinc-800 disabled:opacity-40 disabled:cursor-not-allowed transition-all cursor-pointer"
                                title="Ir a la última página"
                            >
                                Fin »
                            </button>
                        </div>
                    </div>
                    </>
                )}
            </div>

            {/* Modal Facturación */}
            <QuotationInvoiceModal
                isOpen={isInvoiceModalOpen}
                onClose={() => {
                    setIsInvoiceModalOpen(false);
                    setInvoiceQuotationId(null);
                }}
                quotationId={invoiceQuotationId}
            />

            {/* Modal Cambiar Estado */}
            <AnimatePresence>
                {selectedQuotationForState && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className="bg-white dark:bg-zinc-900 rounded-3xl p-6 max-w-md w-full shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            <div className="flex items-center justify-between mb-4">
                                <h3 className="text-lg font-bold text-zinc-900 dark:text-white flex items-center gap-2">
                                    <RefreshCw className="w-5 h-5 text-purple-600" />
                                    Cambiar Estado (#{selectedQuotationForState.id})
                                </h3>
                                <button
                                    onClick={() => setSelectedQuotationForState(null)}
                                    className="p-1 rounded-full text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>

                            <div className="space-y-4">
                                <div>
                                    <label className="block text-xs font-bold text-zinc-500 uppercase mb-1">Estado</label>
                                    <select
                                        value={newState}
                                        onChange={(e) => setNewState(e.target.value)}
                                        className="w-full h-11 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl px-3 text-sm font-semibold text-zinc-800 dark:text-zinc-200 outline-none focus:ring-2 focus:ring-purple-500"
                                    >
                                        {states.map((s: any) => (
                                            <option key={s.id || s.code} value={s.code}>{s.name}</option>
                                        ))}
                                    </select>
                                </div>

                                <div>
                                    <label className="block text-xs font-bold text-zinc-500 uppercase mb-1">Observaciones / Motivo</label>
                                    <textarea
                                        rows={3}
                                        value={stateDescription}
                                        onChange={(e) => setStateDescription(e.target.value)}
                                        placeholder="Motivo del cambio de estado..."
                                        className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl p-3 text-sm font-medium text-zinc-800 dark:text-zinc-200 outline-none focus:ring-2 focus:ring-purple-500"
                                    />
                                </div>

                                <div className="flex items-center justify-end gap-2 pt-2">
                                    <button
                                        onClick={() => setSelectedQuotationForState(null)}
                                        className="px-4 h-10 rounded-xl border border-zinc-200 dark:border-zinc-700 text-xs font-bold text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                                    >
                                        Cancelar
                                    </button>
                                    <button
                                        onClick={handleSaveState}
                                        disabled={savingState}
                                        className="px-5 h-10 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-bold shadow-md shadow-purple-500/20 flex items-center gap-1.5 disabled:opacity-50"
                                    >
                                        {savingState ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
                                        Guardar Estado
                                    </button>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Modal Ver Detalle Rápido */}
            <AnimatePresence>
                {detailQuotation && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className="bg-white dark:bg-zinc-900 rounded-3xl p-6 max-w-2xl w-full shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            <div className="flex items-center justify-between mb-4 border-b border-zinc-200 dark:border-zinc-800 pb-3">
                                <div>
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white flex items-center gap-2">
                                        Cotización #{detailQuotation.id}
                                    </h3>
                                    <p className="text-xs text-zinc-400 font-medium">Fecha: {format(new Date(detailQuotation.createdAt || new Date()), 'dd/MM/yyyy HH:mm')}</p>
                                </div>
                                <button
                                    onClick={() => setDetailQuotation(null)}
                                    className="p-1 rounded-full text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>

                            <div className="grid grid-cols-2 gap-4 text-xs mb-6">
                                <div className="bg-zinc-50 dark:bg-zinc-800/50 p-3.5 rounded-2xl">
                                    <span className="font-bold text-zinc-400 uppercase tracking-widest block text-[10px] mb-1">Cliente</span>
                                    <span className="font-bold text-zinc-800 dark:text-zinc-200 text-sm block">{detailQuotation.clientName}</span>
                                    <span className="text-zinc-500">Pasajero: {detailQuotation.passengerName || 'Mismo titular'}</span>
                                </div>

                                <div className="bg-zinc-50 dark:bg-zinc-800/50 p-3.5 rounded-2xl">
                                    <span className="font-bold text-zinc-400 uppercase tracking-widest block text-[10px] mb-1">Elaborado Por</span>
                                    <span className="font-bold text-zinc-800 dark:text-zinc-200 text-sm block">{detailQuotation.userName}</span>
                                    <span className="text-zinc-500">Reserva: {detailQuotation.reservationCode || 'N/A'}</span>
                                </div>

                                <div className="bg-zinc-50 dark:bg-zinc-800/50 p-3.5 rounded-2xl">
                                    <span className="font-bold text-zinc-400 uppercase tracking-widest block text-[10px] mb-1">Proveedor</span>
                                    <span className="font-bold text-zinc-800 dark:text-zinc-200 text-sm block">{detailQuotation.providerName || 'Varios/Ninguno'}</span>
                                </div>

                                <div className="bg-emerald-50 dark:bg-emerald-950/30 p-3.5 rounded-2xl border border-emerald-100 dark:border-emerald-800/30">
                                    <span className="font-bold text-emerald-600 dark:text-emerald-400 uppercase tracking-widest block text-[10px] mb-1">Monto Total</span>
                                    <span className="font-black text-emerald-700 dark:text-emerald-300 text-lg block tabular-nums">
                                        ${parseFloat(detailQuotation.totalAmount).toLocaleString()} {detailQuotation.currency}
                                    </span>
                                </div>
                            </div>

                            <div className="flex justify-end gap-2">
                                <Link
                                    href={`/dashboard/quotations/print?idIni=${detailQuotation.id}&idFin=${detailQuotation.id}`}
                                    target="_blank"
                                    className="px-4 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold shadow-md shadow-blue-500/20 flex items-center gap-1.5"
                                >
                                    <Printer className="w-4 h-4" /> Imprimir
                                </Link>
                                <button
                                    onClick={() => setDetailQuotation(null)}
                                    className="px-4 h-10 bg-zinc-200 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-xl text-xs font-bold"
                                >
                                    Cerrar
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Modal de Resultado de Exportación a Zeus ERP (Copiable, Estado Visual y Link Directo a Diagnóstico) */}
            <AnimatePresence>
                {exportModal.isOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className="bg-white dark:bg-zinc-900 rounded-3xl p-6 max-w-xl w-full shadow-2xl border border-zinc-200 dark:border-zinc-800 space-y-5"
                        >
                            {/* Encabezado */}
                            <div className="flex items-start justify-between gap-3 border-b border-zinc-100 dark:border-zinc-800 pb-4">
                                <div className="flex items-center gap-3">
                                    <div className={`p-2.5 rounded-2xl ${
                                        exportModal.isError 
                                            ? 'bg-rose-100 text-rose-600 dark:bg-rose-950/50 dark:text-rose-400' 
                                            : 'bg-emerald-100 text-emerald-600 dark:bg-emerald-950/50 dark:text-emerald-400'
                                    }`}>
                                        {exportModal.isError ? (
                                            <AlertCircle className="w-6 h-6" />
                                        ) : (
                                            <CheckCircle2 className="w-6 h-6" />
                                        )}
                                    </div>
                                    <div>
                                        <h3 className="text-lg font-black text-zinc-900 dark:text-white">
                                            {exportModal.title}
                                        </h3>
                                        <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                            {exportModal.message}
                                        </p>
                                    </div>
                                </div>
                                <button
                                    onClick={() => setExportModal(prev => ({ ...prev, isOpen: false }))}
                                    className="p-1.5 rounded-full text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>

                            {/* Detalle de ítems exportados */}
                            {exportModal.items && exportModal.items.length > 0 && (
                                <div className="space-y-2 max-h-56 overflow-y-auto pr-1">
                                    <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">
                                        Detalle por Cotización:
                                    </span>
                                    {exportModal.items.map((item, idx) => (
                                        <div
                                            key={idx}
                                            className={`p-3 rounded-2xl flex items-center justify-between gap-3 border text-xs ${
                                                item.statusType === 'error'
                                                    ? 'bg-rose-50/80 border-rose-200 dark:bg-rose-950/20 dark:border-rose-900/40 text-rose-800 dark:text-rose-300'
                                                    : item.statusType === 'warning'
                                                    ? 'bg-amber-50/80 border-amber-200 dark:bg-amber-950/20 dark:border-amber-900/40 text-amber-800 dark:text-amber-300'
                                                    : 'bg-emerald-50/80 border-emerald-200 dark:bg-emerald-950/20 dark:border-emerald-900/40 text-emerald-800 dark:text-emerald-300'
                                            }`}
                                        >
                                            <div className="flex items-center gap-2">
                                                {item.statusType === 'error' && <AlertCircle className="w-4 h-4 text-rose-500 flex-shrink-0" />}
                                                {item.statusType === 'warning' && <AlertCircle className="w-4 h-4 text-amber-500 flex-shrink-0" />}
                                                {item.statusType === 'success' && <CheckCircle2 className="w-4 h-4 text-emerald-500 flex-shrink-0" />}
                                                <span className="font-bold">Cotización {item.cotDisplay}:</span>
                                                <span>{item.message}</span>
                                            </div>
                                            {item.idZeus && (
                                                <span className="px-2 py-0.5 rounded-full bg-black/5 dark:bg-white/10 text-[10px] font-mono font-bold whitespace-nowrap">
                                                    ID Zeus: #{item.idZeus}
                                                </span>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* Tarjeta de Trazabilidad y Diagnóstico */}
                            {exportModal.traceCode && (
                                <div className="bg-zinc-50 dark:bg-zinc-800/60 p-3.5 rounded-2xl border border-zinc-200 dark:border-zinc-700 space-y-2">
                                    <div className="flex items-center justify-between text-xs">
                                        <span className="font-bold text-zinc-500 dark:text-zinc-400">
                                            Código de Traza Único:
                                        </span>
                                        <div className="flex items-center gap-2">
                                            <code className="px-2 py-1 bg-white dark:bg-zinc-900 rounded-lg border border-zinc-200 dark:border-zinc-700 font-mono font-bold text-blue-600 dark:text-blue-400 select-all">
                                                {exportModal.traceCode}
                                            </code>
                                            <button
                                                type="button"
                                                onClick={() => {
                                                    navigator.clipboard.writeText(exportModal.traceCode || '')
                                                    setCopiedTrace(true)
                                                    setTimeout(() => setCopiedTrace(false), 2000)
                                                }}
                                                className="px-2.5 py-1 bg-white hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-lg border border-zinc-200 dark:border-zinc-700 flex items-center gap-1 text-[11px] font-medium transition"
                                                title="Copiar código al portapapeles"
                                            >
                                                {copiedTrace ? (
                                                    <>
                                                        <Check className="w-3.5 h-3.5 text-emerald-600" />
                                                        <span className="text-emerald-600 font-bold">¡Copiado!</span>
                                                    </>
                                                ) : (
                                                    <>
                                                        <Copy className="w-3.5 h-3.5" />
                                                        <span>Copiar</span>
                                                    </>
                                                )}
                                            </button>
                                        </div>
                                    </div>

                                    <div className="pt-2 border-t border-zinc-200 dark:border-zinc-700/60 flex items-center justify-between text-[11px]">
                                        <span className="text-zinc-400">
                                            Auditado en módulo de Trazabilidad y Diagnóstico
                                        </span>
                                        <Link
                                            href={`/dashboard/diagnostics?code=${exportModal.traceCode}`}
                                            target="_blank"
                                            className="text-blue-600 dark:text-blue-400 hover:underline font-bold flex items-center gap-1"
                                        >
                                            Ver traza detallada <ExternalLink className="w-3 h-3" />
                                        </Link>
                                    </div>
                                </div>
                            )}

                            {/* Botones de acción */}
                            <div className="flex items-center justify-between pt-2">
                                <button
                                    type="button"
                                    onClick={() => {
                                        const textToCopy = [
                                            `[${exportModal.title}]`,
                                            exportModal.message,
                                            exportModal.traceCode ? `Código de Traza: ${exportModal.traceCode}` : '',
                                            exportModal.items && exportModal.items.length > 0
                                                ? '\nDetalle:\n' + exportModal.items.map(it => `• Cotización ${it.cotDisplay}: ${it.message}${it.idZeus ? ` (ID Zeus: #${it.idZeus})` : ''}`).join('\n')
                                                : ''
                                        ].filter(Boolean).join('\n');

                                        navigator.clipboard.writeText(textToCopy);
                                        setCopiedDetails(true);
                                        setTimeout(() => setCopiedDetails(false), 2000);
                                    }}
                                    className="px-3 py-2 bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 rounded-xl text-xs font-semibold flex items-center gap-1.5 transition"
                                >
                                    {copiedDetails ? (
                                        <>
                                            <Check className="w-3.5 h-3.5 text-emerald-600" />
                                            <span className="text-emerald-600">¡Texto copiado!</span>
                                        </>
                                    ) : (
                                        <>
                                            <Copy className="w-3.5 h-3.5" />
                                            <span>Copiar mensaje completo</span>
                                        </>
                                    )}
                                </button>

                                <button
                                    type="button"
                                    onClick={() => setExportModal(prev => ({ ...prev, isOpen: false }))}
                                    className="px-5 py-2 bg-zinc-900 hover:bg-zinc-800 text-white dark:bg-white dark:text-zinc-900 dark:hover:bg-zinc-100 rounded-xl text-xs font-bold transition shadow-sm"
                                >
                                    Aceptar
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </div>
    )
}
