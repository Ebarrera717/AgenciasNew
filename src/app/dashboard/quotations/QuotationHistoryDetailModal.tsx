'use client'

import React, { useState } from 'react'
import { X, Clock, User, FileText, CheckCircle2, Copy, Check, Info, Calendar, DollarSign, Users, Plane, Briefcase } from 'lucide-react'
import { cn } from '@/lib/utils'

interface QuotationHistoryDetailModalProps {
    isOpen: boolean
    onClose: () => void
    historyItem: any | null
    quotationNumber?: string | number
}

export default function QuotationHistoryDetailModal({
    isOpen,
    onClose,
    historyItem,
    quotationNumber
}: QuotationHistoryDetailModalProps) {
    const [activeTab, setActiveTab] = useState<'summary' | 'raw'>('summary')
    const [copied, setCopied] = useState(false)

    if (!isOpen || !historyItem) return null

    let meta: any = null
    if (historyItem.metadata) {
        if (typeof historyItem.metadata === 'string') {
            try {
                meta = JSON.parse(historyItem.metadata)
            } catch (e) {
                meta = { raw: historyItem.metadata }
            }
        } else {
            meta = historyItem.metadata
        }
    }

    const handleCopy = () => {
        if (!meta) return
        navigator.clipboard.writeText(JSON.stringify(meta, null, 2))
        setCopied(true)
        setTimeout(() => setCopied(false), 2000)
    }

    const s = (historyItem.state || '').toUpperCase()
    const isNuevo = s === 'NUEVO'
    const isMod = s === 'MODIFICADO' || s === 'EDICION'
    const isAprob = s === 'APROBADO' || s === 'ENVIADO'
    const isFact = s === 'FACTURADO'
    const isCancel = s === 'CANCELADO' || s === 'ANULADO'

    const badgeStyle = isNuevo
        ? 'bg-blue-50 dark:bg-blue-500/10 border-blue-200 dark:border-blue-500/20 text-blue-600 dark:text-blue-400'
        : isMod
        ? 'bg-amber-50 dark:bg-amber-500/10 border-amber-200 dark:border-amber-500/20 text-amber-600 dark:text-amber-400'
        : isAprob
        ? 'bg-emerald-50 dark:bg-emerald-500/10 border-emerald-200 dark:border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
        : isFact
        ? 'bg-teal-50 dark:bg-teal-500/10 border-teal-200 dark:border-teal-500/20 text-teal-600 dark:text-teal-400'
        : isCancel
        ? 'bg-red-50 dark:bg-red-500/10 border-red-200 dark:border-red-500/20 text-red-600 dark:text-red-400'
        : 'bg-zinc-50 dark:bg-zinc-500/10 border-zinc-200 dark:border-zinc-500/20 text-zinc-600 dark:text-zinc-400'

    const currency = meta?.currency || 'COP'
    const totalAmount = meta?.totalAmount ?? null
    const items = Array.isArray(meta?.items) ? meta.items : (Array.isArray(meta?.products) ? meta.products : [])
    const manualServices = Array.isArray(meta?.manualServices) ? meta.manualServices : []

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-150">
            <div 
                className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl w-full max-w-4xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden animate-in zoom-in-95 duration-150"
                onClick={(e) => e.stopPropagation()}
            >
                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-950/40">
                    <div className="flex items-center gap-3">
                        <div className="p-2 rounded-xl bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400">
                            <FileText className="w-5 h-5" />
                        </div>
                        <div>
                            <div className="flex items-center gap-2">
                                <h2 className="text-base font-bold dark:text-white">
                                    Detalle del Registro de Historial
                                </h2>
                                <span className={cn("px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider text-[10px] border", badgeStyle)}>
                                    {historyItem.state || 'MODIFICADO'}
                                </span>
                            </div>
                            <p className="text-xs text-zinc-500 dark:text-zinc-400 flex items-center gap-2 mt-0.5">
                                <span>Cotización #{quotationNumber || historyItem.quotationId}</span>
                                <span>•</span>
                                <span className="flex items-center gap-1 font-medium">
                                    <Clock className="w-3.5 h-3.5 text-zinc-400" />
                                    {new Date(historyItem.createdAt).toLocaleString()}
                                </span>
                                <span>•</span>
                                <span className="flex items-center gap-1 font-medium text-zinc-700 dark:text-zinc-300">
                                    <User className="w-3.5 h-3.5 text-blue-500" />
                                    {historyItem.userName || 'Sistema'}
                                </span>
                            </p>
                        </div>
                    </div>
                    <button
                        type="button"
                        onClick={onClose}
                        className="p-2 rounded-xl hover:bg-zinc-200 dark:hover:bg-zinc-800 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 transition-colors"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Tabs & Description Bar */}
                <div className="px-6 py-3 bg-zinc-100/60 dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 flex flex-wrap items-center justify-between gap-3">
                    <div className="flex items-center gap-2">
                        <Info className="w-4 h-4 text-blue-500 shrink-0" />
                        <span className="text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                            {historyItem.description || 'Modificación registrada en la cotización.'}
                        </span>
                    </div>

                    <div className="flex items-center gap-1.5 bg-zinc-200/70 dark:bg-zinc-800 p-1 rounded-xl">
                        <button
                            type="button"
                            onClick={() => setActiveTab('summary')}
                            className={cn(
                                "px-3 py-1 rounded-lg text-xs font-bold transition-all",
                                activeTab === 'summary'
                                    ? "bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-sm"
                                    : "text-zinc-500 hover:text-zinc-800 dark:text-zinc-400"
                            )}
                        >
                            Resumen de Datos Guardados
                        </button>
                        <button
                            type="button"
                            onClick={() => setActiveTab('raw')}
                            className={cn(
                                "px-3 py-1 rounded-lg text-xs font-bold transition-all",
                                activeTab === 'raw'
                                    ? "bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-sm"
                                    : "text-zinc-500 hover:text-zinc-800 dark:text-zinc-400"
                            )}
                        >
                            Auditoría Técnica (JSON)
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto p-6 space-y-6">
                    {activeTab === 'summary' ? (
                        meta ? (
                            <div className="space-y-6">
                                {/* General Information Cards */}
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div className="p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200/80 dark:border-zinc-800 space-y-1">
                                        <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-400">Total Cotización</p>
                                        <p className="text-xl font-black text-emerald-600 dark:text-emerald-400">
                                            {totalAmount != null ? `$${Number(totalAmount).toLocaleString(undefined, { minimumFractionDigits: 2 })} ${currency}` : 'No registrado'}
                                        </p>
                                        <p className="text-[11px] text-zinc-500">
                                            Moneda: <span className="font-semibold text-zinc-700 dark:text-zinc-300">{currency}</span>
                                            {meta.exchangeRate && ` (TRM: ${meta.exchangeRate})`}
                                        </p>
                                    </div>

                                    <div className="p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200/80 dark:border-zinc-800 space-y-1">
                                        <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-400">Pasajero y Fechas</p>
                                        <p className="text-xs font-bold text-zinc-800 dark:text-zinc-200 truncate" title={meta.passenger}>
                                            {meta.passenger || 'Pasajero no especificado'}
                                        </p>
                                        <p className="text-[11px] text-zinc-500">
                                            {meta.startDate && meta.endDate
                                                ? `${new Date(meta.startDate).toLocaleDateString()} al ${new Date(meta.endDate).toLocaleDateString()}`
                                                : (meta.destination ? `Destino: ${meta.destination}` : 'Sin fechas definidas')}
                                        </p>
                                    </div>

                                    <div className="p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200/80 dark:border-zinc-800 space-y-1">
                                        <p className="text-[10px] font-bold uppercase tracking-wider text-zinc-400">Asesor y Sucursal</p>
                                        <p className="text-xs font-bold text-zinc-800 dark:text-zinc-200 truncate">
                                            {meta.sellerCode ? `Vendedor: ${meta.sellerCode}` : (meta.sellerId ? `Vendedor ID: ${meta.sellerId}` : 'Vendedor general')}
                                        </p>
                                        <p className="text-[11px] text-zinc-500 truncate">
                                            {meta.branchCode ? `Sucursal: ${meta.branchCode}` : (meta.branchId ? `Sucursal ID: ${meta.branchId}` : 'Principal')}
                                        </p>
                                    </div>
                                </div>

                                {/* Products Breakdown */}
                                <div className="space-y-3">
                                    <h4 className="text-xs font-bold uppercase tracking-wider text-zinc-500 flex items-center gap-1.5">
                                        <Plane className="w-4 h-4 text-blue-500" />
                                        Productos y Servicios Registrados ({items.length})
                                    </h4>

                                    {items.length === 0 ? (
                                        <div className="text-center py-6 border border-dashed border-zinc-200 dark:border-zinc-800 rounded-2xl text-xs text-zinc-400">
                                            No se registraron productos en esta captura.
                                        </div>
                                    ) : (
                                        <div className="border border-zinc-200 dark:border-zinc-800 rounded-2xl overflow-hidden shadow-sm">
                                            <div className="overflow-x-auto">
                                                <table className="w-full text-left border-collapse text-xs">
                                                    <thead>
                                                        <tr className="bg-zinc-100 dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 font-bold text-zinc-500 text-[10px] uppercase">
                                                            <th className="px-4 py-2.5">#</th>
                                                            <th className="px-4 py-2.5">Servicio / Descripción</th>
                                                            <th className="px-4 py-2.5 text-center">Cant.</th>
                                                            <th className="px-4 py-2.5 text-right">Precio Venta</th>
                                                            <th className="px-4 py-2.5 text-right">Costo</th>
                                                            <th className="px-4 py-2.5">Detalles / Pasajeros</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                                                        {items.map((it: any, idx: number) => {
                                                            const itDesc = it.descripcion || it.description || it.service || it.servicios || `Producto #${it.productId || idx + 1}`
                                                            const price = Number(it.price || it.amount || 0)
                                                            const cost = Number(it.cost || 0)
                                                            const qty = Number(it.quantity || 1)
                                                            const paxList = Array.isArray(it.passengers) ? it.passengers : []
                                                            const varList = Array.isArray(it.variables) ? it.variables : []

                                                            return (
                                                                <tr key={idx} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 text-zinc-700 dark:text-zinc-300">
                                                                    <td className="px-4 py-2.5 font-bold text-zinc-400">{idx + 1}</td>
                                                                    <td className="px-4 py-2.5">
                                                                        <p className="font-bold dark:text-white truncate max-w-[220px]" title={itDesc}>
                                                                            {itDesc}
                                                                        </p>
                                                                        {it.serviceType && (
                                                                            <span className="text-[9px] px-1.5 py-0.5 rounded bg-zinc-100 dark:bg-zinc-800 text-zinc-500 uppercase font-semibold">
                                                                                {it.serviceType}
                                                                            </span>
                                                                        )}
                                                                    </td>
                                                                    <td className="px-4 py-2.5 text-center font-semibold">{qty}</td>
                                                                    <td className="px-4 py-2.5 text-right font-bold text-emerald-600 dark:text-emerald-400">
                                                                        ${price.toLocaleString(undefined, { minimumFractionDigits: 2 })}
                                                                    </td>
                                                                    <td className="px-4 py-2.5 text-right text-zinc-500">
                                                                        ${cost.toLocaleString(undefined, { minimumFractionDigits: 2 })}
                                                                    </td>
                                                                    <td className="px-4 py-2.5 space-y-0.5">
                                                                        {paxList.length > 0 && (
                                                                            <p className="text-[10px] text-zinc-500 truncate max-w-[180px]" title={paxList.map((p: any) => p.name).join(', ')}>
                                                                                👥 {paxList.map((p: any) => p.name).join(', ')}
                                                                            </p>
                                                                        )}
                                                                        {varList.length > 0 && (
                                                                            <p className="text-[10px] text-blue-500 dark:text-blue-400 truncate max-w-[180px]">
                                                                                🏷️ {varList.map((v: any) => `${v.value}`).join(' | ')}
                                                                            </p>
                                                                        )}
                                                                        {paxList.length === 0 && varList.length === 0 && (
                                                                            <span className="text-[10px] text-zinc-400">Sin detalles adic.</span>
                                                                        )}
                                                                    </td>
                                                                </tr>
                                                            )
                                                        })}
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    )}
                                </div>

                                {/* Manual Services if any */}
                                {manualServices.length > 0 && (
                                    <div className="space-y-3">
                                        <h4 className="text-xs font-bold uppercase tracking-wider text-zinc-500 flex items-center gap-1.5">
                                            <Briefcase className="w-4 h-4 text-purple-500" />
                                            Servicios Manuales ({manualServices.length})
                                        </h4>
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                                            {manualServices.map((ms: any, mIdx: number) => (
                                                <div key={mIdx} className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-800/40 border border-zinc-200 dark:border-zinc-800 flex items-center justify-between text-xs">
                                                    <div>
                                                        <p className="font-bold dark:text-white">{ms.serviceName || ms.name || `Servicio #${mIdx + 1}`}</p>
                                                        <p className="text-[10px] text-zinc-400">{ms.providerName || 'Proveedor directo'}</p>
                                                    </div>
                                                    <div className="text-right">
                                                        <p className="font-bold text-emerald-600 dark:text-emerald-400">${Number(ms.salePrice || ms.amount || 0).toLocaleString()}</p>
                                                        <p className="text-[10px] text-zinc-400">Costo: ${Number(ms.cost || 0).toLocaleString()}</p>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}
                            </div>
                        ) : (
                            <div className="text-center py-12 text-zinc-400">
                                <Info className="w-10 h-10 mx-auto mb-2 text-zinc-300 dark:text-zinc-700" />
                                <p className="text-sm font-semibold">Este registro histórico contiene el estado y responsable del cambio.</p>
                                <p className="text-xs mt-1">Los detalles completos del snapshot se capturan a partir de las modificaciones actuales.</p>
                            </div>
                        )
                    ) : (
                        <div className="space-y-3">
                            <div className="flex items-center justify-between">
                                <span className="text-xs font-bold uppercase text-zinc-400">Estructura JSON Completa del Guardado</span>
                                <button
                                    type="button"
                                    onClick={handleCopy}
                                    className="px-3 py-1.5 rounded-lg bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-xs font-bold flex items-center gap-1.5 text-zinc-700 dark:text-zinc-300 transition-colors"
                                >
                                    {copied ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                    {copied ? 'Copiado!' : 'Copiar JSON'}
                                </button>
                            </div>
                            <pre className="p-4 rounded-2xl bg-zinc-950 text-zinc-200 text-xs font-mono overflow-x-auto max-h-[50vh] border border-zinc-800 leading-relaxed select-all">
                                {JSON.stringify(meta || historyItem, null, 2)}
                            </pre>
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="px-6 py-3 border-t border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-950/40 flex justify-end">
                    <button
                        type="button"
                        onClick={onClose}
                        className="px-5 py-2 rounded-xl bg-zinc-900 hover:bg-zinc-800 dark:bg-zinc-100 dark:hover:bg-zinc-200 text-white dark:text-zinc-900 font-bold text-xs transition-colors"
                    >
                        Cerrar
                    </button>
                </div>
            </div>
        </div>
    )
}
