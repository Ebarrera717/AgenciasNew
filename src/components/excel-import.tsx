'use client'

import React, { useRef, useState } from 'react'
import { Upload, FileDown, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react'
import { motion } from 'framer-motion'
import * as XLSX from 'xlsx'
import { cn } from '@/lib/utils'

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
        let templateData: any[] = [];
        let filename = 'plantilla_cotizacion.xlsx';

        if (importType === 'QUOTATION') {
            templateData = [
                {
                    Grupo_Cotizacion: '1',
                    Cliente_Documento: '12345678',
                    Sucursal_Codigo: 'BOG01',
                    Implant_Codigo: 'IMP01',
                    Vendedor_Codigo: 'VEN-001',
                    Tiqueteador_Codigo: 'TIQ-001',
                    Moneda: 'USD',
                    Tasa_Cambio: 4000,
                    Comision_Global_Pct: 10,
                    Cargos_A_Cotizacion: 0,
                    Producto_Codigo: 'AL-DES',
                    Proveedor_Codigo: 'GHL',
                    Prestadora_Codigo: 'GHL-BOG',
                    Impuestos_Nombres_Y_Valores: 'IVA:95.50|FEE:10.00',
                    Variables_Codigos_Y_Valores: 'TKT-VUELO:784561|PNR-RESERVA:XYZZ12',
                    Pasajeros: 'Juan Perez:12345678|Maria Garcia:87654321',
                    Precio_Unitario: 15.0,
                    Cantidad: 2,
                    CheckIn: '2026-12-01',
                    CheckOut: '2026-12-10',
                    Pax_Adultos: 2,
                    Pax_Ninos: 0,
                    Destino: 'BOG',
                    Tipo_Servicio: 'ALIMENTACION',
                    Reserva: 'RES123',
                    Comision_Vendedor_Producto: 0,
                    Comision_Tiqueteador_Producto: 0,
                    Combo_Codigos: 'COM-001|COM-002',
                    Cargo_Principal: '',
                    Fecha_Vencimiento_Proveedor: '2026-11-25',
                    Factura_Proveedor: 'FPROV-99881'
                },
                {
                    Grupo_Cotizacion: '1',
                    Cliente_Documento: '12345678',
                    Sucursal_Codigo: 'BOG01',
                    Implant_Codigo: 'IMP01',
                    Vendedor_Codigo: 'VEN-001',
                    Tiqueteador_Codigo: 'TIQ-001',
                    Moneda: 'USD',
                    Tasa_Cambio: 4000,
                    Comision_Global_Pct: 10,
                    Cargos_A_Cotizacion: 0,
                    Producto_Codigo: 'TR-AERO',
                    Proveedor_Codigo: 'DEC',
                    Prestadora_Codigo: 'DEC-BARU',
                    Impuestos_Nombres_Y_Valores: '',
                    Variables_Codigos_Y_Valores: '',
                    Pasajeros: '',
                    Precio_Unitario: 25.0,
                    Cantidad: 1,
                    CheckIn: '',
                    CheckOut: '',
                    Pax_Adultos: 2,
                    Pax_Ninos: 0,
                    Destino: 'CTG',
                    Tipo_Servicio: 'TRANSPORTE',
                    Reserva: 'XXL123',
                    Comision_Vendedor_Producto: 5,
                    Comision_Tiqueteador_Producto: 2,
                    Combo_Codigos: '',
                    Cargo_Principal: 'IVA-19',
                    Fecha_Vencimiento_Proveedor: '',
                    Factura_Proveedor: ''
                }
            ];
            filename = 'plantilla_cotizacion.xlsx';
        } else {
            templateData = [
                {
                    Grupo_Factura: '1',
                    Cliente_Documento: '12345678',
                    Sucursal_Codigo: 'BOG01',
                    Implant_Codigo: 'IMP01',
                    Vendedor_Codigo: 'VEN-001',
                    Tiqueteador_Codigo: 'TIQ-001',
                    Moneda: 'USD',
                    Tasa_Cambio: 4000,
                    Comision_Global_Pct: 10,
                    Cargos_A_Factura: 0,
                    Producto_Codigo: 'AL-DES',
                    Proveedor_Nombre: 'Hotel GHL',
                    Proveedor_Codigo: 'GHL',
                    Prestadora_Codigo: 'GHL-BOG',
                    Impuestos_Nombres_Y_Valores: 'IVA-19:19000|FEE:5000',
                    Variables_Codigos_Y_Valores: 'PNR-RESERVA:XYZZ12',
                    Pasajeros: 'Juan Perez:12345678|Maria Garcia:87654321',
                    Precio_Unitario: 100000.0,
                    Cantidad: 2,
                    CheckIn: '2026-12-01',
                    CheckOut: '2026-12-10',
                    Pax_Adultos: 2,
                    Pax_Ninos: 0,
                    Destino: 'BOG',
                    Tipo_Servicio: 'ALIMENTACION',
                    Reserva: 'RES123',
                    Comision_Vendedor_Producto: 5.0,
                    Comision_Tiqueteador_Producto: 2.0,
                    Combo_Codigos: '',
                    Nacionalidad: 1,
                    Cargo_Principal: 'IVA-19',
                    Costo: 80000.0,
                    Servicios: 'Desayuno incluido',
                    Descripcion: 'Habitación doble estándar',
                    Itinerario: '',
                    Clase: '',
                    Aerolinea: '',
                    Tipo_Tiquete_Codigo: '',
                    Pagos: '100000:Efectivo:REF-123|100000:Tarjeta:REF-456:2026-12-01:1:1234:AUTH123:VOUCH456:2028-12',
                    Itinerarios: '',
                    Fuente: 'FAC',
                    Serie: 'A',
                    Consecutivo: '000123',
                    Fecha_Vencimiento_Proveedor: '2026-11-25',
                    Factura_Proveedor: 'FPROV-99881'
                },
                {
                    Grupo_Factura: '2',
                    Cliente_Documento: '87654321',
                    Sucursal_Codigo: 'BOG01',
                    Implant_Codigo: 'IMP01',
                    Vendedor_Codigo: 'VEN-002',
                    Tiqueteador_Codigo: 'TIQ-002',
                    Moneda: 'COP',
                    Tasa_Cambio: 1,
                    Comision_Global_Pct: 0,
                    Cargos_A_Factura: 15000,
                    Producto_Codigo: 'TKT-AIR',
                    Proveedor_Nombre: 'Avianca',
                    Proveedor_Codigo: 'AV',
                    Prestadora_Codigo: 'AV-BOG',
                    Impuestos_Nombres_Y_Valores: 'IVA-19:57000',
                    Variables_Codigos_Y_Valores: 'TKT-N:000123456',
                    Pasajeros: 'Carlos Gomez:10987654',
                    Precio_Unitario: 300000.0,
                    Cantidad: 1,
                    CheckIn: '2026-10-15',
                    CheckOut: '2026-10-15',
                    Pax_Adultos: 1,
                    Pax_Ninos: 0,
                    Destino: 'CTG',
                    Tipo_Servicio: 'Tiquete',
                    Reserva: 'AVPNR7',
                    Comision_Vendedor_Producto: 0,
                    Comision_Tiqueteador_Producto: 0,
                    Combo_Codigos: '',
                    Nacionalidad: 1,
                    Cargo_Principal: 'IVA-19',
                    Costo: 250000.0,
                    Servicios: 'Equipaje de mano',
                    Descripcion: 'Vuelo directo de ida',
                    Itinerario: 'BOG-CTG',
                    Clase: 'Económica',
                    Aerolinea: 'Avianca',
                    Tipo_Tiquete_Codigo: 'TKT-NAC',
                    Pagos: '357000:Efectivo:REF-789',
                    Itinerarios: 'BOG:CTG:Económica:2026-10-15:2026-10-15:1|CTG:BOG:Económica:2026-10-20:2026-10-20:2',
                    Fuente: 'FAC',
                    Serie: 'A',
                    Consecutivo: '000124'
                }
            ];
            filename = 'plantilla_factura.xlsx';
        }

        const ws = XLSX.utils.json_to_sheet(templateData)
        const wb = XLSX.utils.book_new()
        XLSX.utils.book_append_sheet(wb, ws, 'Template')
        XLSX.writeFile(wb, filename)
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
