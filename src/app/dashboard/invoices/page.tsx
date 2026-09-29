'use client'

import React, { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
    Search,
    Plus,
    Filter,
    FileText,
    Calendar,
    Download,
    Trash2,
    Eye,
    Edit2,
    MoreVertical,
    Printer,
    FileCode,
    Upload,
    Send,
    FileDown,
    Loader2,
    Copy,
    FileSpreadsheet,
    ArrowUp,
    ArrowDown,
    Database,
    CheckCircle2
} from 'lucide-react'
import { useRouter } from 'next/navigation'
import { format } from 'date-fns'
import Link from 'next/link'
import * as XLSX from 'xlsx'
import { generateInvoicePDF } from '@/lib/pdf-utils'
import ExcelImportInvoices from '@/components/excel-import-invoices'
import { downloadInvoiceTemplate } from '@/lib/excel-templates'

export default function InvoicesListPage() {
    const [invoices, setInvoices] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [isExporting, setIsExporting] = useState(false)
    const [selectedIds, setSelectedIds] = useState<number[]>([])
    const [isPrintModalOpen, setIsPrintModalOpen] = useState(false)
    const [isImportOpen, setIsImportOpen] = useState(false)
    const [idIni, setIdIni] = useState('')
    const [idFin, setIdFin] = useState('')
    const [dbInfo, setDbInfo] = useState<{ isSQLServer: boolean; shortName: string; dbName: string; name: string } | null>(null)
    const router = useRouter()

    // Filtros de búsqueda (idénticos a Cotizaciones)
    const [filterReferencia, setFilterReferencia] = useState('')
    const [filterFechaDesde, setFilterFechaDesde] = useState('')
    const [filterFechaHasta, setFilterFechaHasta] = useState('')
    const [filterCliente, setFilterCliente] = useState('')
    const [filterElaboradoPor, setFilterElaboradoPor] = useState('')
    const [filterMontoTotal, setFilterMontoTotal] = useState('')
    const [filterEstado, setFilterEstado] = useState('')
    const [filterReserva, setFilterReserva] = useState('')
    const [filterPasajero, setFilterPasajero] = useState('')

    // Ordenamiento por Referencia / ID
    const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc')

    const loadInvoices = () => {
        setLoading(true)
        Promise.all([
            fetch('/api/invoices/list').then(res => (res.ok ? res.json() : [])).catch(() => []),
            fetch('/api/config/db-provider').then(res => (res.ok ? res.json() : null)).catch(() => null)
        ])
            .then(([data, dbRes]) => {
                if (dbRes) setDbInfo(dbRes)
                if (Array.isArray(data)) {
                    setInvoices(data)
                } else {
                    console.error("API returned error or non-array:", data)
                    setInvoices([])
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

    const isInvoiceExported = (q: any) => {
        const st = (q?.state || '').toUpperCase();
        return st === 'EXPORTED' || st === 'EXPORTADA' || st === 'ENVIADO' || Boolean(q?.zeusInvoiceNumber && String(q?.zeusInvoiceNumber).trim() !== '');
    };

    // Aplicar filtros locales exhaustivos
    const filteredInvoices = invoices.filter(q => {
        const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
        const firstProd = mainProd;
        const firstPaxName = q.paxName || (firstProd?.passengers && Array.isArray(firstProd.passengers) && firstProd.passengers.length > 0 ? firstProd.passengers[0].name : (firstProd?.passengerName || ''));
        const providerNameStr = q.providerName || firstProd?.prestadora?.name || '';
        const clientNameStr = q.client?.name || q.clientName || '';
        const userNameStr = q.userName || q.sellerName || q.seller?.name || '';
        const refStr = `${q.id} ${q.internalNumber || ''} ${q.consecutivo || ''} ${q.serie || ''} ${q.zeusInvoiceNumber || ''}`;
        const reservaStr = q.reservationCode || q.bookingCode || q.cd_reserva || q.pnr || '';
        const totalAmountNum = Number(q.totalAmount) || 0;
        const invDate = q.date || q.createdAt;

        if (filterReferencia && !refStr.toLowerCase().includes(filterReferencia.toLowerCase())) {
            return false;
        }
        if (filterReserva && !reservaStr.toLowerCase().includes(filterReserva.toLowerCase())) {
            return false;
        }
        if (filterPasajero && (!firstPaxName || !firstPaxName.toLowerCase().includes(filterPasajero.toLowerCase()))) {
            return false;
        }
        if (filterCliente && (!clientNameStr || !clientNameStr.toLowerCase().includes(filterCliente.toLowerCase()))) {
            return false;
        }
        if (filterElaboradoPor && (!userNameStr || !userNameStr.toLowerCase().includes(filterElaboradoPor.toLowerCase()))) {
            return false;
        }
        if (filterEstado && filterEstado !== '') {
            const st = (q.state || 'NUEVO').toUpperCase();
            if (filterEstado === 'EXPORTADO' || filterEstado === 'EXPORTED') {
                if (!isInvoiceExported(q)) return false;
            } else if (filterEstado === 'NUEVO') {
                if (isInvoiceExported(q) || st !== 'NUEVO') return false;
            } else {
                if (st !== filterEstado.toUpperCase()) return false;
            }
        }
        if (filterFechaDesde) {
            const d = new Date(invDate);
            const fromD = new Date(filterFechaDesde + 'T00:00:00');
            if (!isNaN(d.getTime()) && !isNaN(fromD.getTime()) && d < fromD) return false;
        }
        if (filterFechaHasta) {
            const d = new Date(invDate);
            const toD = new Date(filterFechaHasta + 'T23:59:59');
            if (!isNaN(d.getTime()) && !isNaN(toD.getTime()) && d > toD) return false;
        }
        if (filterMontoTotal && filterMontoTotal.trim() !== '') {
            const targetVal = parseFloat(filterMontoTotal);
            if (!isNaN(targetVal) && Math.abs(totalAmountNum - targetVal) > 0.01) {
                return false;
            }
        }
        return true;
    });

    // Ordenamiento natural (numérico y alfanumérico) por Referencia / ID
    const sortedInvoices = [...filteredInvoices].sort((a, b) => {
        const keyA = String(a.internalNumber || a.consecutivo || a.id || '').trim();
        const keyB = String(b.internalNumber || b.consecutivo || b.id || '').trim();
        const res = keyA.localeCompare(keyB, undefined, { numeric: true, sensitivity: 'base' });
        if (res !== 0) {
            return sortDirection === 'asc' ? res : -res;
        }
        const numA = Number(a.id) || 0;
        const numB = Number(b.id) || 0;
        return sortDirection === 'asc' ? numA - numB : numB - numA;
    });

    const handleToggleSort = () => {
        setSortDirection(prev => prev === 'asc' ? 'desc' : 'asc');
    };

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
    };

    const selectableInvoices = sortedInvoices.filter(q => !isInvoiceExported(q));

    const toggleSelectAll = () => {
        if (selectableInvoices.length > 0 && selectedIds.length === selectableInvoices.length) {
            setSelectedIds([]);
        } else {
            setSelectedIds(selectableInvoices.map(q => q.id));
        }
    };

    const toggleSelectOne = (id: number) => {
        const target = invoices.find(q => q.id === id);
        if (target && isInvoiceExported(target)) {
            return;
        }
        if (selectedIds.includes(id)) {
            setSelectedIds(selectedIds.filter(item => item !== id));
        } else {
            setSelectedIds([...selectedIds, id]);
        }
    };

    // Copiar a Portapapeles para Excel (Ctrl+V)
    const handleCopyToClipboard = () => {
        const listToCopy = selectedIds.length > 0
            ? sortedInvoices.filter(q => selectedIds.includes(q.id))
            : sortedInvoices;

        if (listToCopy.length === 0) {
            alert('No hay facturas para copiar.');
            return;
        }

        const headers = [
            'Referencia ID',
            'No. Interno',
            'Factura Zeus ERP',
            'Fecha',
            'Cliente',
            'Pasajero / Titular',
            'Elaborado por',
            'Proveedor',
            'Monto Total',
            'Moneda',
            'Estado'
        ];

        const rows = listToCopy.map(q => {
            const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
            const pax = q.paxName || (mainProd?.passengers?.[0]?.name || mainProd?.passengerName || 'Mismo titular');
            const prov = q.providerName || mainProd?.prestadora?.name || 'Varios/Ninguno';
            const zeusNum = q.zeusInvoiceNumber || (isInvoiceExported(q) && q.consecutivo ? `${q.serie || ''}${q.consecutivo}` : '-');
            return [
                q.id,
                q.internalNumber || `FAC-${q.id}`,
                zeusNum,
                q.date ? format(new Date(q.date), 'dd/MM/yyyy') : '',
                q.client?.name || q.clientName || 'Consumidor Final',
                pax,
                q.userName || q.sellerName || 'Sistema',
                prov,
                Number(q.totalAmount) || 0,
                q.currency || 'COP',
                q.state || 'NUEVO'
            ];
        });

        const tsvContent = [
            headers.join('\t'),
            ...rows.map(row => row.join('\t'))
        ].join('\n');

        const htmlContent = `
            <table>
                <thead>
                    <tr>${headers.map(h => `<th style="background-color:#f4f4f5;font-weight:bold;">${h}</th>`).join('')}</tr>
                </thead>
                <tbody>
                    ${rows.map(row => `<tr>${row.map(cell => `<td>${cell}</td>`).join('')}</tr>`).join('')}
                </tbody>
            </table>
        `;

        try {
            const blobText = new Blob([tsvContent], { type: 'text/plain' });
            const blobHtml = new Blob([htmlContent], { type: 'text/html' });
            const clipboardItem = new ClipboardItem({
                'text/plain': blobText,
                'text/html': blobHtml
            });
            navigator.clipboard.write([clipboardItem]).then(() => {
                alert(`✅ ${listToCopy.length} factura(s) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`);
            }).catch(() => {
                navigator.clipboard.writeText(tsvContent);
                alert(`✅ ${listToCopy.length} factura(s) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`);
            });
        } catch (err) {
            navigator.clipboard.writeText(tsvContent);
            alert(`✅ ${listToCopy.length} factura(s) copiada(s) al portapapeles. ¡Puedes pegarlas directamente en Excel (Ctrl+V)!`);
        }
    };

    // Descargar a archivo Excel (.xlsx)
    const handleDownloadExcel = () => {
        const listToDownload = selectedIds.length > 0
            ? sortedInvoices.filter(q => selectedIds.includes(q.id))
            : sortedInvoices;

        if (listToDownload.length === 0) {
            alert('No hay facturas para exportar a Excel.');
            return;
        }

        const dataForExcel = listToDownload.map(q => {
            const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
            const pax = q.paxName || (mainProd?.passengers?.[0]?.name || mainProd?.passengerName || 'Mismo titular');
            const prov = q.providerName || mainProd?.prestadora?.name || 'Varios/Ninguno';
            const zeusNum = q.zeusInvoiceNumber || (isInvoiceExported(q) && q.consecutivo ? `${q.serie || ''}${q.consecutivo}` : '-');
            return {
                'Referencia ID': q.id,
                'No. Interno': q.internalNumber || `FAC-${q.id}`,
                'Factura Zeus ERP': zeusNum,
                'Fecha': q.date ? format(new Date(q.date), 'dd/MM/yyyy') : '',
                'Cliente': q.client?.name || q.clientName || 'Consumidor Final',
                'Pasajero / Titular': pax,
                'Elaborado por': q.userName || q.sellerName || 'Sistema',
                'Proveedor': prov,
                'Monto Total': Number(q.totalAmount) || 0,
                'Moneda': q.currency || 'COP',
                'Estado': q.state || 'NUEVO'
            };
        });

        const worksheet = XLSX.utils.json_to_sheet(dataForExcel);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, 'Facturas');
        XLSX.writeFile(workbook, `Historial_Facturas_${format(new Date(), 'yyyyMMdd_HHmmss')}.xlsx`);
    };

    const handleExportSelectedToZeus = async () => {
        if (selectedIds.length === 0 || isExporting) {
            alert("Por favor seleccione al menos una factura para enviar a Zeus ERP.");
            return;
        }

        setIsExporting(true);
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
        } finally {
            setIsExporting(false);
        }
    };

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
    };

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-4 sm:p-6 max-w-[1700px] mx-auto">
            {/* Header Estandarizado */}
            <header className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-5">
                <div>
                    <h1 className="text-2xl md:text-3xl font-black text-zinc-900 dark:text-white flex items-center gap-2.5 tracking-tight flex-wrap">
                        <FileText className="w-7 h-7 text-blue-600 shrink-0" /> Historial de Facturas
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
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium text-xs md:text-sm mt-0.5">Consulta y administra todas las facturas emitidas</p>
                </div>
                <div className="flex items-center gap-2.5 shrink-0 flex-wrap">
                    <button
                        onClick={handleExportSelectedToZeus}
                        disabled={selectedIds.length === 0 || isExporting}
                        className={`px-4 h-10 rounded-xl flex items-center gap-2 text-xs font-bold transition-all cursor-pointer active:scale-95 ${
                            selectedIds.length > 0 && !isExporting
                            ? "bg-blue-600 hover:bg-blue-700 text-white shadow-md shadow-blue-500/20"
                            : "bg-zinc-200 text-zinc-400 dark:bg-zinc-800 dark:text-zinc-600 cursor-not-allowed"
                        }`}
                        title="Enviar facturas seleccionadas a Zeus ERP / SQL Server"
                    >
                        {isExporting ? (
                            <>
                                <Loader2 className="w-4 h-4 animate-spin" />
                                Enviando a Zeus ERP ({selectedIds.length})...
                            </>
                        ) : (
                            <>
                                <Send className="w-4 h-4" />
                                Enviar a Zeus ERP {selectedIds.length > 0 ? `(${selectedIds.length})` : ''}
                            </>
                        )}
                    </button>

                    <button
                        onClick={downloadInvoiceTemplate}
                        className="px-3.5 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/30 rounded-xl shadow-xs font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                        title="Descargar plantilla Excel para importación de facturas"
                    >
                        <FileDown className="w-4 h-4" /> Descargar Plantilla
                    </button>

                    <button
                        onClick={() => setIsImportOpen(!isImportOpen)}
                        className="px-3.5 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl shadow-xs font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                        title="Importar facturas desde archivo Excel"
                    >
                        <Upload className="w-4 h-4" /> Importar Excel
                    </button>

                    <button
                        onClick={() => setIsPrintModalOpen(true)}
                        className="px-3.5 h-10 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl shadow-xs font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                        title="Imprimir reporte de facturas por rango"
                    >
                        <Printer className="w-4 h-4" /> Imprimir Reporte
                    </button>

                    <Link href="/dashboard/invoices/new">
                        <button className="px-4 h-10 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-md font-bold transition-all flex items-center gap-2 text-xs cursor-pointer active:scale-95">
                            <Plus className="w-4 h-4" /> Nueva Factura
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
                        <ExcelImportInvoices onImportSuccess={loadInvoices} />
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Filtros de Búsqueda (Estandarizado con Cotizaciones) */}
            <div className="bg-white dark:bg-zinc-900/50 p-4 sm:p-5 rounded-2xl border border-zinc-200 dark:border-zinc-800 mb-5 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                    <Calendar className="w-4 h-4 text-blue-600" />
                    <h2 className="text-xs font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-widest">Filtros de Búsqueda</h2>
                </div>
                
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
                    {/* Referencia / ID */}
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
                            <option value="NUEVO">NUEVO</option>
                            <option value="EXPORTADO">EXPORTADO A ZEUS</option>
                            <option value="ENVIADO">ENVIADO</option>
                            <option value="CANCELADO">CANCELADO</option>
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
                            onClick={() => {}}
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
                {/* Barra Superior de Herramientas Excel */}
                <div className="flex flex-wrap items-center justify-between gap-3 px-5 py-3.5 bg-zinc-50 dark:bg-zinc-800/40 border-b border-zinc-200 dark:border-zinc-800 rounded-t-2xl">
                    <div className="flex items-center gap-3 text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                        <span>Total facturas: <strong className="text-blue-600 dark:text-blue-400 font-black text-sm">{sortedInvoices.length}</strong></span>
                        {selectedIds.length > 0 && (
                            <span className="px-2.5 py-0.5 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300 text-[11px] font-bold">
                                {selectedIds.length} seleccionada(s)
                            </span>
                        )}
                    </div>

                    <div className="flex items-center gap-2">
                        <button
                            onClick={handleCopyToClipboard}
                            className="px-3.5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl shadow-sm font-bold transition-all flex items-center gap-1.5 text-xs cursor-pointer active:scale-95"
                            title="Copiar facturas al portapapeles para pegar en Excel (Ctrl+V)"
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
                ) : sortedInvoices.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-[400px] text-zinc-400">
                        <FileText className="w-16 h-16 mb-4 opacity-20" />
                        <h3 className="text-xl font-bold text-zinc-600 dark:text-zinc-300 mb-1">No hay facturas</h3>
                        <p className="text-xs">Aún no se ha emitido ninguna o no coincide con la búsqueda.</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto w-full min-h-[420px]">
                        <table className="w-full text-left border-collapse text-xs md:text-sm">
                            <thead className="bg-zinc-50/70 dark:bg-zinc-800/40">
                                <tr>
                                    <th className="px-4 py-3.5 w-10 border-b border-zinc-200 dark:border-zinc-800 text-center">
                                        <input
                                            type="checkbox"
                                            checked={selectableInvoices.length > 0 && selectedIds.length === selectableInvoices.length}
                                            disabled={selectableInvoices.length === 0}
                                            onChange={toggleSelectAll}
                                            className={`w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 ${selectableInvoices.length === 0 ? 'opacity-40 cursor-not-allowed' : 'cursor-pointer'}`}
                                            title={selectableInvoices.length === 0 ? "No hay facturas pendientes por exportar" : "Seleccionar todas las facturas pendientes"}
                                        />
                                    </th>
                                    <th 
                                        onClick={handleToggleSort} 
                                        className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 cursor-pointer hover:text-blue-600 transition-colors select-none whitespace-nowrap"
                                        title="Hacer clic para alternar orden por Referencia / ID"
                                    >
                                        <div className="flex items-center gap-1.5">
                                            <span>Referencia / ID</span>
                                            {sortDirection === 'asc' ? <ArrowUp className="w-3.5 h-3.5 text-blue-600" /> : <ArrowDown className="w-3.5 h-3.5 text-blue-600" />}
                                        </div>
                                    </th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Factura Zeus ERP</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap min-w-[160px]">Cliente</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Fechas</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Monto Total</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-400 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 whitespace-nowrap">Estado</th>
                                    <th className="px-4 py-3.5 text-[11px] font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-800 text-right whitespace-nowrap sticky right-0 bg-zinc-50 dark:bg-zinc-800/95 backdrop-blur-sm z-10 shadow-[-4px_0_8px_-2px_rgba(0,0,0,0.06)]">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                                {sortedInvoices.map((q) => {
                                    const mainProd = q.products?.find((p: any) => p.mainTaxId) || (q.products && q.products.length > 0 ? q.products[0] : null);
                                    const firstProd = mainProd;
                                    const paxNameDisplay = q.paxName || (firstProd?.passengers && Array.isArray(firstProd.passengers) && firstProd.passengers.length > 0 ? firstProd.passengers[0].name : (firstProd?.passengerName || 'Mismo titular'));
                                    const providerNameDisplay = q.providerName || firstProd?.prestadora?.name || 'Varios/Ninguno';
                                    const checkInDisplay = q.checkInDate || firstProd?.checkInDate;
                                    const checkOutDisplay = q.checkOutDate || firstProd?.checkOutDate;
                                    const isSelected = selectedIds.includes(q.id);
                                    const isExportedToZeus = isInvoiceExported(q);
                                    const zeusDisplayNum = q.zeusInvoiceNumber || (isExportedToZeus && q.consecutivo && q.serie !== 'FAC' ? (q.serie && !q.consecutivo.startsWith(q.serie) ? `${q.serie}${q.consecutivo}` : q.consecutivo) : null);
                                    const isImportedFromExcel = q.isExcelImport || (q.internalNumber || '').startsWith('FAC-');

                                    return (
                                        <tr key={q.id} className={`group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all ${isSelected ? 'bg-blue-50/50 dark:bg-blue-900/10' : ''}`}>
                                            <td className="px-4 py-3.5 text-center">
                                                <input
                                                    type="checkbox"
                                                    checked={isSelected}
                                                    disabled={isExportedToZeus}
                                                    onChange={() => toggleSelectOne(q.id)}
                                                    className={`w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 ${
                                                        isExportedToZeus ? 'opacity-30 cursor-not-allowed bg-zinc-200 dark:bg-zinc-700' : 'cursor-pointer'
                                                    }`}
                                                    title={isExportedToZeus ? `Factura ${q.internalNumber || q.id} ya fue exportada a Zeus ERP` : 'Seleccionar para exportar'}
                                                />
                                            </td>
                                            <td className="px-4 py-3.5 whitespace-nowrap">
                                                <div className="font-bold text-zinc-900 dark:text-white text-xs md:text-sm">{q.internalNumber || `#${q.id}`}</div>
                                                <div className="text-[10px] text-zinc-400 mt-0.5">ID #{q.id} • {q.date ? format(new Date(q.date), 'dd/MM/yyyy') : '-'}</div>
                                            </td>
                                            <td className="px-4 py-3.5 whitespace-nowrap">
                                                {isExportedToZeus && zeusDisplayNum ? (
                                                    <span className={`inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-black border shadow-xs ${
                                                        isImportedFromExcel 
                                                        ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800"
                                                        : "bg-blue-50 text-blue-700 dark:bg-blue-950/40 dark:text-blue-300 border-blue-200 dark:border-blue-800"
                                                    }`}>
                                                        {zeusDisplayNum}
                                                    </span>
                                                ) : (
                                                    <span className="text-zinc-400 text-xs font-medium">-</span>
                                                )}
                                            </td>
                                            <td className="px-4 py-3.5 max-w-[220px]">
                                                <div className="font-bold text-zinc-900 dark:text-white text-xs md:text-sm max-w-[210px] truncate">{q.client?.name || q.clientName || 'Consumidor Final'}</div>
                                                <div className="text-[11px] text-zinc-400 max-w-[210px] truncate">Pax: {paxNameDisplay}</div>
                                                <div className="text-[11px] text-zinc-400 mt-0.5 max-w-[210px] truncate">{providerNameDisplay}</div>
                                            </td>
                                            <td className="px-4 py-3.5 whitespace-nowrap">
                                                <div className="flex items-center gap-1.5 text-zinc-600 dark:text-zinc-300 text-xs">
                                                    <Calendar className="w-3.5 h-3.5 text-zinc-400" />
                                                    <span>{checkInDisplay ? format(new Date(checkInDisplay), 'dd/MM/yy') : '-'} - {checkOutDisplay ? format(new Date(checkOutDisplay), 'dd/MM/yy') : '-'}</span>
                                                </div>
                                            </td>
                                            <td className="px-4 py-3.5 whitespace-nowrap">
                                                <div className="font-black text-emerald-600 dark:text-emerald-400 text-xs md:text-sm tabular-nums">
                                                    ${(Number(q.totalAmount) || 0).toLocaleString()} <span className="text-[10px] text-zinc-400 font-normal uppercase">{q.currency || 'COP'}</span>
                                                </div>
                                            </td>
                                            <td className="px-4 py-3.5 whitespace-nowrap">
                                                <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${
                                                    isExportedToZeus || q.state === 'ENVIADO' 
                                                    ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400" 
                                                    : "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
                                                }`}>
                                                    {q.state || 'NUEVO'}
                                                </span>
                                            </td>
                                            <td className="px-4 py-3.5 text-right whitespace-nowrap sticky right-0 bg-white/95 dark:bg-zinc-900/95 group-hover:bg-zinc-50/95 dark:group-hover:bg-zinc-800/90 backdrop-blur-sm z-10 transition-colors shadow-[-4px_0_8px_-2px_rgba(0,0,0,0.06)]">
                                                <div className="flex items-center justify-end gap-1">
                                                    <button
                                                        onClick={() => handleExportXml(q)}
                                                        className="p-1.5 text-zinc-400 hover:text-emerald-600 hover:bg-emerald-50 dark:hover:bg-emerald-500/10 rounded-lg transition-all"
                                                        title="Enviar a Zeus ERP / Descargar XML"
                                                    >
                                                        <FileCode className="w-4 h-4" />
                                                    </button>
                                                    <button
                                                        onClick={() => window.open(`/dashboard/invoices/print?idIni=${q.id}&idFin=${q.id}`, '_blank')}
                                                        className="p-1.5 text-zinc-400 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-lg transition-all"
                                                        title="Imprimir Factura"
                                                    >
                                                        <Printer className="w-4 h-4" />
                                                    </button>
                                                    <button
                                                        onClick={() => router.push(`/dashboard/invoices/${q.id}/edit`)}
                                                        className="p-1.5 text-zinc-400 hover:text-amber-600 hover:bg-amber-50 dark:hover:bg-amber-500/10 rounded-lg transition-all"
                                                        title="Editar Factura"
                                                    >
                                                        <Edit2 className="w-4 h-4" />
                                                    </button>
                                                    <button 
                                                        onClick={async () => {
                                                            if (!confirm(`¿Estás seguro de eliminar la factura #${q.id}?`)) return;
                                                            try {
                                                                const res = await fetch(`/api/invoices/${q.id}`, { method: 'DELETE' });
                                                                if (res.ok) {
                                                                    setInvoices(invoices.filter(item => item.id !== q.id));
                                                                } else {
                                                                    alert('Error al eliminar la factura');
                                                                }
                                                            } catch (err: any) {
                                                                alert('Error al eliminar: ' + err.message);
                                                            }
                                                        }}
                                                        className="p-1.5 text-zinc-400 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                                                        title="Eliminar Factura"
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    )
                                })}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Modal de Impresión por Rango */}
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
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border border-zinc-200 dark:border-zinc-700 text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                            placeholder="Ej. 1"
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Factura Final</label>
                                        <input
                                            type="number"
                                            value={idFin}
                                            onChange={(e) => setIdFin(e.target.value)}
                                            className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-4 border border-zinc-200 dark:border-zinc-700 text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
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
