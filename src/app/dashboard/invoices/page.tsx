'use client'

import React, { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, Plus, Filter, FileText, Download, Trash2, Eye, Edit2, MoreVertical, Printer, FileCode, Upload, Send } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { format } from 'date-fns'
import { generateInvoicePDF } from '@/lib/pdf-utils'
import ExcelImportInvoices from '@/components/excel-import-invoices'

export default function InvoicesListPage() {
    const [invoices, setInvoices] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [selectedIds, setSelectedIds] = useState<number[]>([])
    const [isPrintModalOpen, setIsPrintModalOpen] = useState(false)
    const [isImportOpen, setIsImportOpen] = useState(false)
    const [idIni, setIdIni] = useState('')
    const [idFin, setIdFin] = useState('')
    const router = useRouter()

    const loadInvoices = () => {
        setLoading(true)
        fetch('/api/invoices/list')
            .then(res => (res.ok ? res.json() : []))
            .then(data => {
                if (Array.isArray(data)) {
                    setInvoices(data)
                } else {
                    console.error("API returned error or non-array:", data)
                    setInvoices([])
                    alert("Error cargando facturas: " + (data?.details || data?.message || "Desconocido"))
                }
                setLoading(false)
            })
            .catch(err => {
                console.error(err)
                setLoading(false)
            })
    }

    useEffect(() => {
        loadInvoices()
    }, [])

    const filteredInvoices = invoices.filter(q => {
        const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
        const firstProd = mainProd;
        const firstPaxName = q.paxName || (firstProd?.passengers && Array.isArray(firstProd.passengers) && firstProd.passengers.length > 0 ? firstProd.passengers[0].name : (firstProd?.passengerName || ''));
        const providerNameStr = q.providerName || firstProd?.prestadora?.name || '';
        const searchLower = search.toLowerCase();
        return q.id.toString().includes(searchLower) ||
            (q.internalNumber || '').toLowerCase().includes(searchLower) ||
            (q.client?.name || q.clientName || '').toLowerCase().includes(searchLower) ||
            (firstPaxName && firstPaxName.toLowerCase().includes(searchLower)) ||
            (providerNameStr && providerNameStr.toLowerCase().includes(searchLower))
    });

    const toggleSelectAll = () => {
        if (selectedIds.length === filteredInvoices.length && filteredInvoices.length > 0) {
            setSelectedIds([]);
        } else {
            setSelectedIds(filteredInvoices.map(q => q.id));
        }
    };

    const toggleSelectOne = (id: number) => {
        if (selectedIds.includes(id)) {
            setSelectedIds(selectedIds.filter(item => item !== id));
        } else {
            setSelectedIds([...selectedIds, id]);
        }
    };

    const handleExportSelectedToZeus = async () => {
        if (selectedIds.length === 0) {
            alert("Por favor seleccione al menos una factura para enviar a Zeus ERP.");
            return;
        }

        try {
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{"id": 1}');
            const res = await fetch('/api/invoices/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: selectedIds,
                    userId: loggedUser.id
                })
            });

            const data = await res.json();

            if (!res.ok) {
                alert("ERROR DE SERVIDOR: " + (data.message || "Error desconocido") + (data.details ? "\nDetalles: " + data.details : ""));
                return;
            }

            if (data.success) {
                alert("EXPORTACIÓN EXITOSA A ZEUS ERP:\n" + data.message);
                setSelectedIds([]);
                loadInvoices();
            } else {
                alert("ATENCIÓN: " + data.message);
            }
        } catch (err: any) {
            console.error(err);
            alert("Error al exportar a Zeus ERP: " + err.message);
        }
    };

    const handleDownloadPdf = (q: any) => {
        const firstProd = q.products && q.products.length > 0 ? q.products[0] : null;

        const pdfData = {
            ...q,
            clientName: q.client?.name || q.clientName || 'Cliente sin nombre',
            clientDocument: q.client?.document || '',
            providerName: q.providerName || firstProd?.provider?.name || 'Varios/Ninguno',
            prestadoraName: firstProd?.prestadora?.name || q.providerName || 'Varios/Ninguno',
            checkIn: (q.checkInDate || firstProd?.checkInDate) ? format(new Date(q.checkInDate || firstProd.checkInDate), 'yyyy-MM-dd') : '',
            checkOut: (q.checkOutDate || firstProd?.checkOutDate) ? format(new Date(q.checkOutDate || firstProd.checkOutDate), 'yyyy-MM-dd') : '',
            paxName: q.paxName || firstProd?.passengers?.[0]?.name || firstProd?.passengerName || 'N/A',
            paxDocument: firstProd?.passengers?.[0]?.document || 'N/A',
            paxAdults: firstProd?.paxAdults || 1,
            paxChildren: firstProd?.paxChildren || 0,
            nights: firstProd?.nights || 0,
            items: (q.products || []).map((p: any) => ({
                ...p,
                productDescription: p.product?.description || ''
            }))
        }
        generateInvoicePDF(pdfData)
    }

    const handleExportXml = async (q: any) => {
        try {
            const loggedUser = JSON.parse(localStorage.getItem('user') || '{"id": 1}');
            const res = await fetch('/api/invoices/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: [q.id],
                    userId: loggedUser.id
                })
            });

            const data = await res.json();

            if (!res.ok) {
                alert("ERROR DE SERVIDOR: " + (data.message || "Error desconocido") + (data.details ? "\nDetalles: " + data.details : ""));
                return;
            }

            if (data.success) {
                alert("EXPORTACIÓN EXITOSA A ZEUS ERP:\n" + data.message);
                loadInvoices();
            } else {
                alert("ATENCIÓN: Se generó el XML pero hubo un problema con SQL Server.\nMensaje: " + data.message);
            }

            if (data.xml) {
                const blob = new Blob([data.xml], { type: 'application/xml' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `factura_${q.id}.xml`;
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
                    <h1 className="text-4xl font-bold text-zinc-900 dark:text-white mb-2">Facturas</h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium">Gestión y seguimiento de tus ofertas</p>
                </div>
                <div className="flex items-center gap-3">
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={handleExportSelectedToZeus}
                        disabled={selectedIds.length === 0}
                        className={`px-5 h-12 rounded-xl flex items-center gap-2 text-sm font-bold transition-all cursor-pointer active:scale-95 ${
                            selectedIds.length > 0
                            ? "bg-blue-600 hover:bg-blue-700 text-white shadow-md shadow-blue-500/20"
                            : "bg-zinc-200 text-zinc-400 dark:bg-zinc-800 dark:text-zinc-600 cursor-not-allowed"
                        }`}
                        title="Enviar facturas seleccionadas a Zeus ERP / SQL Server"
                    >
                        <Send className="w-5 h-5" />
                        Enviar a Zeus ERP {selectedIds.length > 0 ? `(${selectedIds.length})` : ''}
                    </motion.button>
                    <motion.button
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => setIsImportOpen(!isImportOpen)}
                        className="px-5 h-12 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl flex items-center gap-2 shadow-sm text-sm font-bold transition-all cursor-pointer active:scale-95"
                    >
                        <Upload className="w-5 h-5" />
                        Importar Excel
                    </motion.button>
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
                        onClick={() => router.push('/dashboard/invoices/new')}
                        className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl flex items-center gap-2 shadow-md shadow-blue-500/20 text-sm font-bold transition-all cursor-pointer active:scale-95 shrink-0"
                    >
                        <Plus className="w-5 h-5" />
                        Nueva Factura
                    </motion.button>
                </div>
            </header>

            <AnimatePresence>
                {isImportOpen && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden mb-8"
                    >
                        <ExcelImportInvoices onImportSuccess={loadInvoices} />
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Filters & Search */}
            <div className="bg-white dark:bg-zinc-900/50 p-4 rounded-3xl border border-zinc-200 dark:border-zinc-800 mb-8 flex items-center gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400 w-5 h-5" />
                    <input
                        type="text"
                        placeholder="Buscar por cliente, ID, pasajero o prestadora..."
                        className="w-full h-12 pl-12 pr-4 bg-zinc-50 dark:bg-zinc-800 rounded-2xl border-none outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </div>
                <button className="h-12 px-6 flex items-center gap-2 border border-zinc-200 dark:border-zinc-700 rounded-2xl text-zinc-600 dark:text-zinc-400 font-bold hover:bg-zinc-50 transition-all">
                    <Filter className="w-4 h-4" /> Filtros
                </button>
            </div>

            {/* Table */}
            <div className="bg-white dark:bg-zinc-900/50 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-zinc-50 dark:bg-zinc-800/50 border-b border-zinc-200 dark:border-zinc-800">
                            <th className="px-4 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider text-center w-12">
                                <input
                                    type="checkbox"
                                    checked={filteredInvoices.length > 0 && selectedIds.length === filteredInvoices.length}
                                    onChange={toggleSelectAll}
                                    className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                />
                            </th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Referencia</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Cliente</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Fechas</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Total</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Estado</th>
                            <th className="px-6 py-4 text-xs font-bold text-zinc-400 uppercase tracking-wider">Acciones</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                        {loading ? (
                            <tr><td colSpan={7} className="p-20 text-center"><div className="animate-spin rounded-full h-8 w-8 border-t-2 border-blue-600 mx-auto"></div></td></tr>
                        ) : invoices.length === 0 ? (
                            <tr><td colSpan={7} className="p-20 text-center text-zinc-500 font-medium">No se encontraron facturas.</td></tr>
                        ) : (
                            filteredInvoices.map((q) => {
                                const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
                                const firstProd = mainProd;
                                const paxNameDisplay = q.paxName || (firstProd?.passengers && Array.isArray(firstProd.passengers) && firstProd.passengers.length > 0 ? firstProd.passengers[0].name : (firstProd?.passengerName || 'Mismo titular'));
                                const providerNameDisplay = q.providerName || firstProd?.prestadora?.name || 'Varios/Ninguno';
                                const checkInDisplay = q.checkInDate || firstProd?.checkInDate;
                                const checkOutDisplay = q.checkOutDate || firstProd?.checkOutDate;
                                const isSelected = selectedIds.includes(q.id);

                                return (
                                    <tr key={q.id} className={`hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all ${isSelected ? 'bg-blue-50/50 dark:bg-blue-950/20' : ''}`}>
                                        <td className="px-4 py-4 text-center">
                                            <input
                                                type="checkbox"
                                                checked={isSelected}
                                                onChange={() => toggleSelectOne(q.id)}
                                                className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                            />
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-blue-600">{q.internalNumber || `#${q.id}`}</div>
                                            <div className="text-[10px] text-zinc-400 mt-0.5">ID #{q.id} • {q.date ? format(new Date(q.date), 'dd MMM, yyyy') : '-'}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-bold text-zinc-900 dark:text-white">{q.client?.name || q.clientName || 'Consumidor Final'}</div>
                                            <div className="text-[10px] text-zinc-500 font-medium">Pax: {paxNameDisplay}</div>
                                            <div className="text-xs text-zinc-400 mt-1">{providerNameDisplay}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="text-xs font-medium text-zinc-600 dark:text-zinc-400">
                                                {checkInDisplay ? format(new Date(checkInDisplay), 'dd/MM/yy') : '-'} - {checkOutDisplay ? format(new Date(checkOutDisplay), 'dd/MM/yy') : '-'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="font-black text-zinc-900 dark:text-white">
                                                ${(Number(q.totalAmount) || 0).toLocaleString()} <span className="text-[10px] text-zinc-500 uppercase">{q.currency || 'COP'}</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-2 py-1 rounded-md text-[10px] font-bold uppercase ${
                                                q.state === 'ENVIADO' 
                                                ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400" 
                                                : "bg-blue-100 text-blue-700 dark:bg-blue-500/10 dark:text-blue-400"
                                            }`}>
                                                {q.state || 'NUEVO'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-2">
                                                <button
                                                    onClick={() => handleExportXml(q)}
                                                    className="p-2 text-zinc-400 hover:text-emerald-500 hover:bg-emerald-50 dark:hover:bg-emerald-500/10 rounded-lg transition-all"
                                                    title="Enviar a Zeus ERP / Descargar XML"
                                                >
                                                    <FileCode className="w-5 h-5" />
                                                </button>
                                                <button
                                                    onClick={() => window.open(`/dashboard/invoices/print?idIni=${q.id}&idFin=${q.id}`, '_blank')}
                                                    className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-lg transition-all"
                                                    title="Imprimir Factura"
                                                >
                                                    <Printer className="w-5 h-5" />
                                                </button>
                                                <button
                                                    onClick={() => router.push(`/dashboard/invoices/${q.id}/edit`)}
                                                    className="p-2 text-zinc-400 hover:text-indigo-500 hover:bg-indigo-50 dark:hover:bg-indigo-500/10 rounded-lg transition-all"
                                                    title="Editar Factura"
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
                                <p className="text-zinc-500 text-sm mb-6">Selecciona el rango de facturas para generar el reporte.</p>
                                
                                <div className="space-y-4 mb-8">
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Factura Inicial</label>
                                        <input
                                            type="number"
                                            value={idIni}
                                            onChange={(e) => setIdIni(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                            placeholder="Ej. 1"
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Factura Final</label>
                                        <input
                                            type="number"
                                            value={idFin}
                                            onChange={(e) => setIdFin(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                            placeholder="Ej. 100"
                                        />
                                    </div>
                                </div>

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
                                                window.open(`/dashboard/invoices/print?idIni=${idIni}&idFin=${idFin}`, '_blank');
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
        </div>
    )
}
