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
    Eye,
    Trash2,
    Printer,
    Plus
} from 'lucide-react'
import { format } from 'date-fns'
import Link from 'next/link'
import * as XLSX from 'xlsx'

export default function InvoicesHistoryPage() {
    const [invoices, setInvoices] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')
    const [selectedIds, setSelectedIds] = useState<number[]>([])

    const fetchInvoices = async () => {
        try {
            const res = await fetch('/api/invoices/history')
            const data = await res.json()
            setInvoices(Array.isArray(data) ? data : [])
        } catch (error) {
            console.error('Error fetching history:', error)
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        fetchInvoices()
    }, [])

    const filteredQs = invoices.filter(q =>
        q.id.toString().includes(searchTerm) ||
        q.clientName.toLowerCase().includes(searchTerm.toLowerCase())
    )

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

    const handleExport = async () => {
        if (selectedIds.length === 0) {
            alert('Por favor selecciona al menos una factura para exportar.')
            return
        }

        try {
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            const res = await fetch('/api/invoices/export', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ids: selectedIds, // Enviamos como arreglo
                    userId: user.id || 1
                })
            });

            const data = await res.json();

            if (!res.ok) {
                alert("ERROR DE EXPORTACIÓN:\n" + (data.message || "Error desconocido") + (data.details ? "\nDetalles: " + data.details : ""));
                return;
            }

            if (data.success) {
                // Construir detalle del resultado del SP
                let detalle = "✅ EXPORTACIÓN EXITOSA\n\n";
                if (data.spResult && data.spResult.length > 0) {
                    detalle += "Resultado por factura:\n";
                    data.spResult.forEach((row: any) => {
                        detalle += `  • ${row.Factura}: ${row.Estado}${row.IdProcesado ? ' (ID SQL: ' + row.IdProcesado + ')' : ''}\n`;
                    });
                } else {
                    detalle += "Factura enviada a SQL Server correctamente.";
                }
                alert(detalle);
                fetchInvoices(); // Recargar la lista para ver los estados actualizados
            } else {
                alert("❌ ERROR EN SQL SERVER:\n" + data.message);
            }

        } catch (error: any) {
            console.error('Export error:', error);
            alert(`Error crítico al conectar con el servidor: ${error.message}`);
        }
    }

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-8 md:p-12">
            <header className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12">
                <div>
                    <h1 className="text-4xl font-black text-zinc-900 dark:text-white mb-2 flex items-center gap-3 tracking-tight">
                        <FileText className="w-9 h-9 text-blue-600" /> Historial de Facturas
                    </h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium text-lg">Consulta y administra todas las facturas emitidas</p>
                </div>
                <div className="flex gap-4">
                    <div className="relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400 w-5 h-5" />
                        <input
                            type="text"
                            placeholder="Buscar ID o cliente..."
                            className="h-14 bg-white dark:bg-zinc-900 rounded-2xl pl-12 pr-6 border border-zinc-200 dark:border-zinc-800 focus:ring-2 focus:ring-blue-500 outline-none w-full md:w-80 font-medium transition-all shadow-sm"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                    <motion.button
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={handleExport}
                        className="px-5 h-12 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl shadow-sm text-sm font-bold transition-all flex items-center gap-2 shrink-0 cursor-pointer active:scale-95"
                    >
                        <Download className="w-5 h-5 text-emerald-600" /> Exportar
                    </motion.button>
                    <Link href="/dashboard/invoices/new">
                        <motion.button
                            whileHover={{ scale: 1.02 }}
                            whileTap={{ scale: 0.98 }}
                            className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-md shadow-blue-500/20 text-sm font-bold transition-all flex items-center gap-2 shrink-0 cursor-pointer active:scale-95"
                        >
                            <Plus className="w-5 h-5" /> Nueva Factura
                        </motion.button>
                    </Link>
                </div>
            </header>

            <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[2.5rem] shadow-sm overflow-hidden min-h-[500px]">
                {loading ? (
                    <div className="flex items-center justify-center h-[500px]">
                        <Loader2 className="animate-spin w-12 h-12 text-blue-600" />
                    </div>
                ) : filteredQs.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-[500px] text-zinc-400">
                        <FileText className="w-20 h-20 mb-6 opacity-20" />
                        <h3 className="text-2xl font-bold text-zinc-600 dark:text-zinc-300 mb-2">No hay facturas</h3>
                        <p>Aún no se ha emitido ninguna o no coincide con la búsqueda.</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead className="bg-zinc-50 dark:bg-zinc-800/30">
                                <tr>
                                    <th className="px-8 py-6 w-10 border-b border-zinc-100 dark:border-zinc-800">
                                        <input
                                            type="checkbox"
                                            className="w-5 h-5 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                            checked={selectedIds.length === filteredQs.length && filteredQs.length > 0}
                                            onChange={handleSelectAll}
                                        />
                                    </th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Referencia</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Fecha</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Cliente</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Elaborado por</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Monto Total</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800">Estado</th>
                                    <th className="px-8 py-6 text-xs font-bold text-zinc-400 uppercase tracking-widest border-b border-zinc-100 dark:border-zinc-800 text-right">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                                {filteredQs.map((q) => (
                                    <tr key={q.id} className={`group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all ${selectedIds.includes(q.id) ? 'bg-blue-50/50 dark:bg-blue-900/10' : ''}`}>
                                        <td className="px-8 py-6">
                                            <input
                                                type="checkbox"
                                                className="w-5 h-5 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                checked={selectedIds.includes(q.id)}
                                                onChange={() => handleSelectOne(q.id)}
                                            />
                                        </td>
                                        <td className="px-8 py-6">
                                            <div className="font-mono font-black text-blue-600 dark:text-blue-400 text-base flex items-center gap-2">
                                                {q.invoiceNumber || q.internalNumber || `#${q.id}`}
                                            </div>
                                            {(q.fuente || q.serie || q.consecutivo) && (
                                                <div className="text-[11px] text-zinc-400 font-mono mt-0.5">
                                                    {q.fuente ? `Fuente: ${q.fuente}` : ''} {q.serie ? `| Serie: ${q.serie}` : ''} {q.consecutivo ? `| Cons: ${q.consecutivo}` : ''}
                                                </div>
                                            )}
                                        </td>
                                         <td className="px-8 py-6">
                                             <div className="flex items-center gap-2 text-zinc-600 dark:text-zinc-400 text-sm font-medium">
                                                 <Calendar className="w-4 h-4 opacity-50" />
                                                 <div>
                                                     <div>{q.date ? format(new Date(q.date), 'dd/MM/yyyy') : '-'}</div>
                                                     {q.dueDate && (
                                                         <div className="text-[11px] text-amber-600 dark:text-amber-400 font-semibold mt-0.5">
                                                             Venc: {format(new Date(q.dueDate), 'dd/MM/yyyy')}
                                                         </div>
                                                     )}
                                                 </div>
                                             </div>
                                         </td>
                                        <td className="px-8 py-6">
                                            <div className="font-semibold text-zinc-800 dark:text-zinc-200">{q.clientName}</div>
                                            <div className="text-xs text-zinc-500">{q.branchName ? `Sucursal: ${q.branchName}` : ''}</div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <div className="text-sm font-medium text-zinc-600 dark:text-zinc-400">
                                                {q.userName || q.sellerName || 'Sistema'}
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <div className="font-black text-emerald-600 dark:text-emerald-400 tabular-nums">
                                                ${parseFloat(q.amount ?? q.totalAmount ?? 0).toLocaleString()} <span className="text-xs opacity-70">{q.currency || 'COP'}</span>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className={`px-3 py-1.5 rounded-xl text-[10px] font-bold uppercase tracking-wider ${
                                                q.state === 'ENVIADO' 
                                                ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400" 
                                                : "bg-blue-100 text-blue-700 dark:bg-blue-500/10 dark:text-blue-400"
                                            }`}>
                                                {q.state || 'NUEVO'}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <Link
                                                    href={`/dashboard/invoices/print?idIni=${q.id}&idFin=${q.id}`}
                                                    target="_blank"
                                                    className="p-2 text-zinc-400 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"
                                                    title="Imprimir Factura"
                                                >
                                                    <Printer className="w-5 h-5" />
                                                </Link>
                                                <Link
                                                    href={`/dashboard/invoices/${q.id}/edit`}
                                                    className="p-2 text-zinc-400 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"
                                                    title="Ver Detalle de Factura"
                                                >
                                                    <Eye className="w-5 h-5" />
                                                </Link>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    )
}
