'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { FileText, Search, PlusCircle, LayoutDashboard, Database, TrendingUp, Sparkles } from 'lucide-react'
import { useRouter } from 'next/navigation'
import ExcelImport from '@/components/excel-import'

export default function DashboardIndex() {
    const router = useRouter()
    const [recent, setRecent] = React.useState<any[]>([])
    const [loading, setLoading] = React.useState(true)

    React.useEffect(() => {
        fetch('/api/quotations/list')
            .then(res => (res.ok ? res.json() : []))
            .then(data => {
                setRecent(Array.isArray(data) ? data.slice(0, 5) : [])
                setLoading(false)
            })
            .catch(() => setLoading(false))
    }, [])



    return (
        <main className="flex-1 flex flex-col p-8 md:p-12">
            <header className="flex items-center justify-between mb-12">
                <div>
                    <h1 className="text-4xl font-bold text-zinc-900 dark:text-white mb-2">Hola, Administrador</h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium">Aquí tienes un resumen de hoy</p>
                </div>
                <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => router.push('/dashboard/quotations/new')}
                    className="px-6 h-14 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-2xl flex items-center gap-3 shadow-xl shadow-blue-500/20 font-bold"
                >
                    <PlusCircle className="w-5 h-5" />
                    Nueva Cotización
                </motion.button>
            </header>



            {/* Grid for Table and Import */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
                {/* Recent Activity Table */}
                <section className="bg-white dark:bg-zinc-900/50 border border-zinc-200 dark:border-zinc-800 rounded-3xl shadow-sm overflow-hidden min-h-[400px]">
                    <div className="p-8 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                        <h2 className="text-xl font-bold text-zinc-900 dark:text-white">Cotizaciones Recientes</h2>
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 w-4 h-4" />
                            <input
                                type="text"
                                placeholder="Buscar..."
                                className="pl-10 pr-4 py-2 bg-zinc-50 dark:bg-zinc-800/50 border border-zinc-200 dark:border-zinc-700 rounded-xl outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                            />
                        </div>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="w-full text-left">
                            <thead className="bg-zinc-50 dark:bg-zinc-800/50 text-[10px] font-bold text-zinc-400 uppercase tracking-wider">
                                <tr>
                                    <th className="px-8 py-3">Cliente</th>
                                    <th className="px-8 py-3">Total</th>
                                    <th className="px-8 py-3 text-right">Detalle</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                                {loading ? (
                                    <tr><td colSpan={3} className="p-10 text-center text-zinc-400">Cargando...</td></tr>
                                ) : recent.length === 0 ? (
                                    <tr><td colSpan={3} className="p-10 text-center text-zinc-500">Sin actividad reciente</td></tr>
                                ) : (
                                    recent.map((q) => (
                                        <tr key={q.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all">
                                            <td className="px-8 py-4">
                                                <div className="font-bold text-sm text-zinc-900 dark:text-white">{q.client.name}</div>
                                                <div className="text-[10px] text-zinc-400">#{q.id}</div>
                                            </td>
                                            <td className="px-8 py-4 font-black text-blue-600 text-sm">
                                                ${q.totalAmount.toLocaleString()}
                                            </td>
                                            <td className="px-8 py-4 text-right">
                                                <button onClick={() => router.push('/dashboard/quotations')} className="text-zinc-400 hover:text-blue-500"><TrendingUp className="w-4 h-4" /></button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                    {recent.length > 0 && (
                        <div className="p-4 border-t border-zinc-200 dark:border-zinc-800 text-center">
                            <button onClick={() => router.push('/dashboard/quotations')} className="text-xs font-bold text-blue-600 hover:underline">Ver todas</button>
                        </div>
                    )}
                </section>

                {/* Excel Import Utility */}
                <ExcelImport />
            </div>
        </main>
    )
}
