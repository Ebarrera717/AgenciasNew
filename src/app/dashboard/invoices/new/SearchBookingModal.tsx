'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, X, Calendar, User, Ticket, Plane, Building2, Check, Loader2, ArrowRight, RefreshCw, FileText } from 'lucide-react'
import { format } from 'date-fns'

interface SearchBookingModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSelectBooking: (booking: any) => void;
}

export default function SearchBookingModal({ isOpen, onClose, onSelectBooking }: SearchBookingModalProps) {
    const [filters, setFilters] = useState({
        client: '',
        passenger: '',
        record: '',
        ticket: '',
        airline: ''
    })

    const [loading, setLoading] = useState(false)
    const [results, setResults] = useState<any[]>([])
    const [searched, setSearched] = useState(false)

    const fetchBookings = async () => {
        setLoading(true)
        setSearched(true)
        try {
            const queryParams = new URLSearchParams()
            if (filters.client.trim()) queryParams.append('client', filters.client.trim())
            if (filters.passenger.trim()) queryParams.append('passenger', filters.passenger.trim())
            if (filters.record.trim()) queryParams.append('record', filters.record.trim())
            if (filters.ticket.trim()) queryParams.append('ticket', filters.ticket.trim())
            if (filters.airline.trim()) queryParams.append('airline', filters.airline.trim())

            const res = await fetch(`/api/invoices/search-bookings?${queryParams.toString()}`)
            const json = await res.json()
            if (json.success) {
                setResults(json.data || [])
            } else {
                setResults([])
            }
        } catch (err) {
            console.error('Error cargando reservas:', err)
            setResults([])
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        if (isOpen) {
            fetchBookings()
        }
    }, [isOpen])

    const handleClear = () => {
        setFilters({
            client: '',
            passenger: '',
            record: '',
            ticket: '',
            airline: ''
        })
    }

    const [selectedTicketIds, setSelectedTicketIds] = useState<number[]>([])

    // Aplanar tiquetes/productos individuales de todas las reservas
    const ticketRows: { id: number; booking: any; item: any }[] = []
    results.forEach((bk: any) => {
        (bk.items || []).forEach((it: any) => {
            ticketRows.push({
                id: it.id,
                booking: bk,
                item: it
            })
        })
    })

    const handleToggleSelectAll = () => {
        if (selectedTicketIds.length === ticketRows.length) {
            setSelectedTicketIds([])
        } else {
            setSelectedTicketIds(ticketRows.map(r => r.id))
        }
    }

    const handleToggleTicket = (id: number) => {
        if (selectedTicketIds.includes(id)) {
            setSelectedTicketIds(selectedTicketIds.filter(i => i !== id))
        } else {
            setSelectedTicketIds([...selectedTicketIds, id])
        }
    }

    const handleImportSelected = (itemsToImport: { booking: any; item: any }[]) => {
        if (itemsToImport.length === 0) return
        // Usar la cabecera de la primera reserva y adjuntar los items seleccionados
        const baseBooking = itemsToImport[0].booking
        const combinedBooking = {
            ...baseBooking,
            items: itemsToImport.map(r => r.item)
        }
        onSelectBooking(combinedBooking)
        onClose()
    }

    const calculateItemPrice = (item: any) => {
        const itemPrice = Number(item.price || 0) * Number(item.quantity || 1)
        if (itemPrice > 0) return itemPrice
        let taxSum = 0
        const taxes = item.appliedTaxes || []
        taxes.forEach((tax: any) => {
            taxSum += Number(tax.amount || 0)
        })
        return taxSum
    }

    if (!isOpen) return null

    return (
        <AnimatePresence>
            <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-md">
                <motion.div
                    initial={{ opacity: 0, scale: 0.96, y: 15 }}
                    animate={{ opacity: 1, scale: 1, y: 0 }}
                    exit={{ opacity: 0, scale: 0.96 }}
                    className="bg-white dark:bg-zinc-900 w-full max-w-6xl rounded-[2.5rem] shadow-2xl border border-zinc-200 dark:border-zinc-800 overflow-hidden flex flex-col max-h-[90vh]"
                >
                    {/* Encabezado */}
                    <div className="p-6 md:p-8 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between bg-zinc-50/50 dark:bg-zinc-900/50">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 bg-blue-600/10 text-blue-600 dark:text-blue-400 rounded-2xl flex items-center justify-center shadow-inner">
                                <FileText className="w-6 h-6" />
                            </div>
                            <div>
                                <h3 className="text-2xl font-black text-zinc-900 dark:text-white">
                                    Importar desde Reserva / GDS
                                </h3>
                                <p className="text-sm font-medium text-zinc-500 dark:text-zinc-400">
                                    Selecciona cada tiquete individualmente o varios a la vez para facturar
                                </p>
                            </div>
                        </div>

                        <button
                            onClick={onClose}
                            className="p-3 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-full transition-colors text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200"
                        >
                            <X className="w-6 h-6" />
                        </button>
                    </div>

                    {/* Formulario de Filtros */}
                    <div className="p-6 border-b border-zinc-100 dark:border-zinc-800 bg-zinc-50/30 dark:bg-zinc-900/30">
                        <div className="grid grid-cols-1 md:grid-cols-5 gap-3 mb-4">
                            <div>
                                <label className="text-[11px] font-black text-zinc-400 uppercase tracking-wider block mb-1">
                                    Cliente
                                </label>
                                <div className="relative">
                                    <Building2 className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Ej. Avianca / Cliente..."
                                        value={filters.client}
                                        onChange={(e) => setFilters({ ...filters, client: e.target.value })}
                                        onKeyDown={(e) => e.key === 'Enter' && fetchBookings()}
                                        className="w-full h-11 pl-9 pr-3 text-sm bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none font-medium dark:text-white"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-[11px] font-black text-zinc-400 uppercase tracking-wider block mb-1">
                                    Pasajero
                                </label>
                                <div className="relative">
                                    <User className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Ej. Nombre / Doc..."
                                        value={filters.passenger}
                                        onChange={(e) => setFilters({ ...filters, passenger: e.target.value })}
                                        onKeyDown={(e) => e.key === 'Enter' && fetchBookings()}
                                        className="w-full h-11 pl-9 pr-3 text-sm bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none font-medium dark:text-white"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-[11px] font-black text-zinc-400 uppercase tracking-wider block mb-1">
                                    Record (PNR)
                                </label>
                                <div className="relative">
                                    <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Ej. AZWRN9..."
                                        value={filters.record}
                                        onChange={(e) => setFilters({ ...filters, record: e.target.value })}
                                        onKeyDown={(e) => e.key === 'Enter' && fetchBookings()}
                                        className="w-full h-11 pl-9 pr-3 text-sm bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none font-medium dark:text-white"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-[11px] font-black text-zinc-400 uppercase tracking-wider block mb-1">
                                    Tiquete
                                </label>
                                <div className="relative">
                                    <Ticket className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Ej. 4856377538..."
                                        value={filters.ticket}
                                        onChange={(e) => setFilters({ ...filters, ticket: e.target.value })}
                                        onKeyDown={(e) => e.key === 'Enter' && fetchBookings()}
                                        className="w-full h-11 pl-9 pr-3 text-sm bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none font-medium dark:text-white"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-[11px] font-black text-zinc-400 uppercase tracking-wider block mb-1">
                                    Aerolínea / Proveedor
                                </label>
                                <div className="relative">
                                    <Plane className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Ej. AV, LA..."
                                        value={filters.airline}
                                        onChange={(e) => setFilters({ ...filters, airline: e.target.value })}
                                        onKeyDown={(e) => e.key === 'Enter' && fetchBookings()}
                                        className="w-full h-11 pl-9 pr-3 text-sm bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none font-medium dark:text-white"
                                    />
                                </div>
                            </div>
                        </div>

                        <div className="flex items-center justify-between gap-3">
                            <div className="flex items-center gap-2">
                                {selectedTicketIds.length > 0 && (
                                    <button
                                        type="button"
                                        onClick={() => {
                                            const selected = ticketRows.filter(r => selectedTicketIds.includes(r.id))
                                            handleImportSelected(selected)
                                        }}
                                        className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl shadow-lg shadow-emerald-500/20 text-xs flex items-center gap-2 transition-all cursor-pointer"
                                    >
                                        <Check className="w-4 h-4" />
                                        Importar {selectedTicketIds.length} Tiquete(s) Seleccionado(s)
                                    </button>
                                )}
                            </div>

                            <div className="flex items-center gap-3">
                                <button
                                    type="button"
                                    onClick={handleClear}
                                    className="px-4 py-2.5 text-xs font-bold text-zinc-500 hover:text-zinc-800 dark:text-zinc-400 dark:hover:text-white transition-colors"
                                >
                                    Limpiar Filtros
                                </button>
                                <button
                                    type="button"
                                    onClick={fetchBookings}
                                    disabled={loading}
                                    className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-lg shadow-blue-500/20 text-xs flex items-center gap-2 transition-all disabled:opacity-50 cursor-pointer"
                                >
                                    {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Search className="w-4 h-4" />}
                                    Buscar Reservas
                                </button>
                            </div>
                        </div>
                    </div>

                    {/* Resultados por Tiquete */}
                    <div className="flex-1 overflow-y-auto p-6 min-h-[300px]">
                        {loading ? (
                            <div className="flex flex-col items-center justify-center p-16 text-zinc-400">
                                <Loader2 className="w-10 h-10 animate-spin text-blue-600 mb-3" />
                                <p className="text-sm font-medium">Buscando tiquetes disponibles para facturar...</p>
                            </div>
                        ) : ticketRows.length === 0 ? (
                            <div className="flex flex-col items-center justify-center p-16 text-zinc-400 text-center">
                                <FileText className="w-12 h-12 mb-3 text-zinc-300 dark:text-zinc-700" />
                                <p className="text-base font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                                    No se encontraron tiquetes pendientes por facturar
                                </p>
                                <p className="text-xs text-zinc-400 max-w-sm">
                                    Todos los tiquetes de las reservas buscadas ya han sido facturados o no existen en el sistema.
                                </p>
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="border-b border-zinc-200 dark:border-zinc-800 text-[11px] font-black text-zinc-400 uppercase tracking-wider">
                                            <th className="py-3 px-3 text-center">
                                                <input
                                                    type="checkbox"
                                                    className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                    checked={selectedTicketIds.length > 0 && selectedTicketIds.length === ticketRows.length}
                                                    onChange={handleToggleSelectAll}
                                                />
                                            </th>
                                            <th className="py-3 px-4">RECORD (PNR)</th>
                                            <th className="py-3 px-4">CLIENTE / VENDEDOR</th>
                                            <th className="py-3 px-4">PASAJERO</th>
                                            <th className="py-3 px-4">TIQUETE / AEROLÍNEA</th>
                                            <th className="py-3 px-4 text-right">VALOR TIQUETE</th>
                                            <th className="py-3 px-4 text-center">ACCIÓN</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800 text-sm">
                                        {ticketRows.map(({ id, booking: bk, item }) => {
                                            const isSelected = selectedTicketIds.includes(id)
                                            const paxList = (item.passengers || []).map((p: any) => p.name || `${p.firstName || ''} ${p.lastName || ''}`.trim()).filter(Boolean)
                                            const ticketVal = calculateItemPrice(item)
                                            const ticketCode = item.code || item.ticketCode || 'VUE'
                                            const airline = item.prestadoracode || bk.prestadoracode || ''

                                            return (
                                                <tr
                                                    key={id}
                                                    className={`transition-colors group ${isSelected ? 'bg-blue-50/70 dark:bg-blue-900/20' : 'hover:bg-blue-50/30 dark:hover:bg-blue-900/10'}`}
                                                >
                                                    <td className="py-4 px-3 text-center">
                                                        <input
                                                            type="checkbox"
                                                            className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                            checked={isSelected}
                                                            onChange={() => handleToggleTicket(id)}
                                                        />
                                                    </td>

                                                    <td className="py-4 px-4">
                                                        <div className="font-black text-blue-600 dark:text-blue-400 font-mono text-base">
                                                            {bk.code}
                                                        </div>
                                                        <div className="text-[11px] text-zinc-400 font-medium flex items-center gap-1 mt-0.5">
                                                            <Calendar className="w-3 h-3" />
                                                            {bk.date ? format(new Date(bk.date), 'dd/MM/yyyy HH:mm') : 'Sin fecha'}
                                                        </div>
                                                    </td>

                                                    <td className="py-4 px-4">
                                                        <div className="font-bold text-zinc-800 dark:text-zinc-200">
                                                            {bk.client || 'Cliente General'}
                                                        </div>
                                                        <div className="text-xs text-zinc-400 font-medium">
                                                            Vendedor: {bk.seller || 'No asignado'}
                                                        </div>
                                                    </td>

                                                    <td className="py-4 px-4">
                                                        {paxList.length > 0 ? (
                                                            <div className="text-xs font-semibold text-zinc-700 dark:text-zinc-300 flex items-center gap-1.5">
                                                                <User className="w-3.5 h-3.5 text-zinc-400" />
                                                                {paxList.join(', ')}
                                                            </div>
                                                        ) : (
                                                            <span className="text-xs text-zinc-400 italic">Pasajero General</span>
                                                        )}
                                                    </td>

                                                    <td className="py-4 px-4">
                                                        <div className="flex flex-wrap gap-1.5 items-center">
                                                            {airline && (
                                                                <span className="px-2 py-0.5 bg-blue-100 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 rounded-md text-xs font-bold font-mono">
                                                                    {airline}
                                                                </span>
                                                            )}
                                                            <span className="px-2 py-0.5 bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-md text-xs font-mono font-medium">
                                                                Tkt: {ticketCode}
                                                            </span>
                                                        </div>
                                                    </td>

                                                    <td className="py-4 px-4 text-right">
                                                        <div className="font-black text-emerald-600 dark:text-emerald-400 text-base font-mono">
                                                            ${ticketVal.toLocaleString('es-CO')}
                                                        </div>
                                                        <div className="text-[11px] text-zinc-400 font-bold uppercase">
                                                            {bk.currency || 'COP'}
                                                        </div>
                                                    </td>

                                                    <td className="py-4 px-4 text-center">
                                                        <button
                                                            type="button"
                                                            onClick={() => handleImportSelected([{ booking: bk, item }])}
                                                            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-xs flex items-center gap-1.5 shadow-md shadow-blue-500/20 transition-all cursor-pointer mx-auto"
                                                        >
                                                            Importar <ArrowRight className="w-3.5 h-3.5" />
                                                        </button>
                                                    </td>
                                                </tr>
                                            )
                                        })}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </motion.div>
            </div>
        </AnimatePresence>
    )
}
