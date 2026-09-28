'use client'

import React, { useRef, useState } from 'react'
import { Upload, FileDown, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react'
import { motion } from 'framer-motion'
import * as XLSX from 'xlsx'
import { cn } from '@/lib/utils'
import { downloadQuotationTemplate, downloadInvoiceTemplate } from '@/lib/excel-templates'

export default function ExcelImport() {
    const fileInputRef = useRef<HTMLInputElement>(null)
    const [importing, setImporting] = useState(false)
    const [status, setStatus] = useState<{ type: 'success' | 'error', message: string } | null>(null)
    const [importType, setImportType] = useState<'QUOTATION' | 'INVOICE'>('QUOTATION')

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file) return

        setImporting(true)
        setStatus(null)

        const reader = new FileReader()
        reader.onload = async (evt) => {
            try {
                const bstr = evt.target?.result
                const wb = XLSX.read(bstr, { type: 'binary' })
                const wsname = wb.SheetNames[0]
                const ws = wb.Sheets[wsname]
                const data = XLSX.utils.sheet_to_json(ws)

                console.log('Excel Data:', data)

                const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
                const apiUrl = importType === 'QUOTATION' ? '/api/quotations/import' : '/api/invoices/import';
                const res = await fetch(apiUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-User-Id': loggedUser.id?.toString() || '',
                        'X-Origin': 'EXCEL'
                    },
                    body: JSON.stringify(data)
                })

                const resText = await res.text();
                let result: any = {};
                try {
                    result = JSON.parse(resText);
                } catch {
                    result = { message: resText || `Error HTTP ${res.status}` };
                }

                if (res.ok) {
                    const successMsg = result.detail || `Se importaron ${result.importedCount || 0} registros exitosamente.`;
                    setStatus({ type: 'success', message: successMsg })
                    if (fileInputRef.current) fileInputRef.current.value = ''
                } else {
                    const errorMsg = result.detail || result.error || result.message || `Error HTTP ${res.status}: ${resText.substring(0, 200)}`;
                    setStatus({ type: 'error', message: errorMsg })
                }
            } catch (err: any) {
                setStatus({ type: 'error', message: err.message || 'Ocurrió un error inesperado al leer el archivo.' })
            } finally {
                setImporting(false)
            }
        }
        reader.readAsBinaryString(file)
    }

    const downloadTemplate = () => {
        if (importType === 'QUOTATION') {
            downloadQuotationTemplate()
        } else {
            downloadInvoiceTemplate()
        }
    }

    return (
        <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 p-8 rounded-3xl shadow-sm space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h3 className="text-xl font-bold dark:text-white text-zinc-900">Importación Masiva</h3>
                    <p className="text-zinc-500 text-sm">
                        Carga {importType === 'QUOTATION' ? 'cotizaciones' : 'facturas'} desde un archivo Excel (.xlsx)
                    </p>
                </div>
                
                <div className="flex items-center gap-6">
                    <div className="flex bg-zinc-100 dark:bg-zinc-800 p-1 rounded-xl">
                        <button
                            type="button"
                            onClick={() => { setImportType('QUOTATION'); setStatus(null); }}
                            className={cn(
                                "px-4 py-2 rounded-lg text-xs font-bold transition-all cursor-pointer",
                                importType === 'QUOTATION'
                                    ? "bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-sm"
                                    : "text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200"
                            )}
                        >
                            Cotizaciones
                        </button>
                        <button
                            type="button"
                            onClick={() => { setImportType('INVOICE'); setStatus(null); }}
                            className={cn(
                                "px-4 py-2 rounded-lg text-xs font-bold transition-all cursor-pointer",
                                importType === 'INVOICE'
                                    ? "bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-sm"
                                    : "text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200"
                            )}
                        >
                            Facturaciones
                        </button>
                    </div>

                    <button
                        onClick={downloadTemplate}
                        className="flex items-center gap-2 text-blue-600 font-bold hover:underline text-sm cursor-pointer"
                    >
                        <FileDown className="w-4 h-4" /> Descargar Plantilla
                    </button>
                </div>
            </div>

            <div
                onClick={() => fileInputRef.current?.click()}
                className="border-2 border-dashed border-zinc-200 dark:border-zinc-800 rounded-2xl p-12 flex flex-col items-center justify-center cursor-pointer hover:bg-zinc-50 dark:hover:bg-zinc-800/20 transition-all group"
            >
                <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept=".xlsx, .xls"
                    onChange={handleFileUpload}
                />

                <div className="w-16 h-16 bg-blue-50 dark:bg-blue-900/20 rounded-full flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    {importing ? (
                        <Loader2 className="w-8 h-8 text-blue-600 animate-spin" />
                    ) : (
                        <Upload className="w-8 h-8 text-blue-600" />
                    )}
                </div>

                <p className="font-bold text-zinc-900 dark:text-white">
                    {importing ? 'Procesando archivo...' : 'Haz clic para cargar Excel'}
                </p>
                <p className="text-zinc-500 text-sm mt-1">O arrastra y suelta el archivo aquí</p>
            </div>

            {status && (
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={cn(
                        "p-4 rounded-xl flex items-center gap-3",
                        status.type === 'success' ? "bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600" : "bg-red-50 dark:bg-red-900/20 text-red-600"
                    )}
                >
                    {status.type === 'success' ? <CheckCircle2 className="w-5 h-5" /> : <AlertCircle className="w-5 h-5" />}
                    <span className="font-medium text-sm">{status.message}</span>
                </motion.div>
            )}
        </div>
    )
}
