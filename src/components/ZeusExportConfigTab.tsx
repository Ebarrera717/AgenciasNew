'use client'

import React, { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import {
    SlidersHorizontal,
    ArrowUp,
    ArrowDown,
    Save,
    RotateCcw,
    CheckCircle2,
    AlertCircle,
    Eye,
    FileText,
    Layers,
    Sparkles,
    Info,
    RefreshCw
} from 'lucide-react'
import { cn } from '@/lib/utils'
import {
    ZeusFieldConfig,
    ZeusTextSectionConfig,
    DEFAULT_ITEM_DESCRIPTION_CONFIG,
    DEFAULT_OBSERVATIONS_CONFIG,
    buildZeusItemDescription,
    buildZeusObservations
} from '@/lib/zeus-text-formatter'

// Datos de prueba para la vista previa interactiva en vivo
const PREVIEW_ITEM_DATA = {
    descripcion: 'HOTEL CARTAGENA',
    checkInDate: '2026-11-10',
    checkOutDate: '2026-11-15',
    providerCode: 'ABC',
    prestadoraCode: 'HOTEL GHL',
    inNationality: 1, // NACIONAL
    consecutive: '12580',
    quotationConsecutive: '12580',
    passenger: 'JUAN PEREZ',
    destination: 'CARTAGENA',
    reservationCode: 'RES-9988'
};

const PREVIEW_OBSERVATIONS_DATA = {
    quotationConsecutive: '12580',
    invoiceConsecutive: 'FAC-00452',
    passenger: 'JUAN PEREZ',
    providerCode: 'ABC',
    prestadoraCode: 'HOTEL GHL',
    checkInDate: '2026-11-10',
    checkOutDate: '2026-11-15',
    servicesSummary: 'PAQUETE TURISTICO COMPLETO'
};

const PREVIEW_ORIGINAL_OBSERVATIONS = 'Servicio solicitado por el cliente. Confirmación pendiente.';

export default function ZeusExportConfigTab() {
    const [loading, setLoading] = useState(true)
    const [saving, setSaving] = useState(false)
    const [statusMessage, setStatusMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

    const [itemConfig, setItemConfig] = useState<ZeusTextSectionConfig>(DEFAULT_ITEM_DESCRIPTION_CONFIG)
    const [obsConfig, setObsConfig] = useState<ZeusTextSectionConfig>(DEFAULT_OBSERVATIONS_CONFIG)

    useEffect(() => {
        fetchConfig()
    }, [])

    const fetchConfig = async () => {
        setLoading(true)
        try {
            const res = await fetch('/api/config/zeus-export-config')
            if (res.ok) {
                const data = await res.json()
                if (data.itemDescriptionConfig) setItemConfig(data.itemDescriptionConfig)
                if (data.observationsConfig) setObsConfig(data.observationsConfig)
            }
        } catch (err: any) {
            console.error('Error al cargar configuración Zeus:', err)
        } finally {
            setLoading(false)
        }
    }

    const handleSave = async () => {
        setSaving(true)
        setStatusMessage(null)
        try {
            const res = await fetch('/api/config/zeus-export-config', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    itemDescriptionConfig: itemConfig,
                    observationsConfig: obsConfig
                })
            })
            const data = await res.json()
            if (res.ok && data.success) {
                setStatusMessage({ type: 'success', text: '¡Configuración guardada exitosamente y lista para exportar a Zeus ERP!' })
                setTimeout(() => setStatusMessage(null), 5000)
            } else {
                setStatusMessage({ type: 'error', text: data.message || 'Error al guardar la configuración.' })
            }
        } catch (err: any) {
            setStatusMessage({ type: 'error', text: 'Error de conexión: ' + err.message })
        } finally {
            setSaving(false)
        }
    }

    const handleResetDefaults = () => {
        if (confirm('¿Deseas restablecer las configuraciones a sus valores sugeridos por defecto?')) {
            setItemConfig(JSON.parse(JSON.stringify(DEFAULT_ITEM_DESCRIPTION_CONFIG)))
            setObsConfig(JSON.parse(JSON.stringify(DEFAULT_OBSERVATIONS_CONFIG)))
            setStatusMessage({ type: 'success', text: 'Valores restablecidos a los valores por defecto (recuerda presionar Guardar).' })
        }
    }

    // Funciones de reordenamiento y manipulación de campos
    const moveField = (
        section: 'item' | 'obs',
        index: number,
        direction: 'up' | 'down'
    ) => {
        const config = section === 'item' ? { ...itemConfig } : { ...obsConfig }
        const fields = [...config.fields]
        const targetIndex = direction === 'up' ? index - 1 : index + 1
        if (targetIndex < 0 || targetIndex >= fields.length) return

        const temp = fields[index]
        fields[index] = fields[targetIndex]
        fields[targetIndex] = temp

        // Actualizar número de orden
        fields.forEach((f, i) => { f.order = i + 1 })
        config.fields = fields

        if (section === 'item') {
            setItemConfig(config)
        } else {
            setObsConfig(config)
        }
    }

    const toggleField = (section: 'item' | 'obs', id: string) => {
        const config = section === 'item' ? { ...itemConfig } : { ...obsConfig }
        config.fields = config.fields.map(f => f.id === id ? { ...f, enabled: !f.enabled } : f)
        if (section === 'item') setItemConfig(config)
        else setObsConfig(config)
    }

    const updateLabel = (section: 'item' | 'obs', id: string, newLabel: string) => {
        const config = section === 'item' ? { ...itemConfig } : { ...obsConfig }
        config.fields = config.fields.map(f => f.id === id ? { ...f, label: newLabel } : f)
        if (section === 'item') setItemConfig(config)
        else setObsConfig(config)
    }

    const updateSeparator = (section: 'item' | 'obs', sep: string) => {
        if (section === 'item') setItemConfig({ ...itemConfig, separator: sep })
        else setObsConfig({ ...obsConfig, separator: sep })
    }

    // Vistas previas en vivo
    const liveItemPreview = buildZeusItemDescription(PREVIEW_ITEM_DATA, itemConfig, 4000)
    const liveObsPreview = buildZeusObservations(PREVIEW_ORIGINAL_OBSERVATIONS, PREVIEW_OBSERVATIONS_DATA, obsConfig, 8000)

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center p-16 gap-3 text-zinc-500">
                <RefreshCw className="w-7 h-7 animate-spin text-blue-500" />
                <span className="text-sm font-semibold">Cargando parametrización de Zeus ERP...</span>
            </div>
        )
    }

    return (
        <div className="space-y-8">
            {/* Header explicativo con acciones */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-6 bg-gradient-to-r from-blue-50/80 via-indigo-50/50 to-white dark:from-zinc-900/80 dark:via-zinc-800/40 dark:to-zinc-900 rounded-3xl border border-blue-200/60 dark:border-zinc-800 shadow-sm">
                <div className="space-y-1">
                    <div className="flex items-center gap-3">
                        <div className="p-2.5 bg-blue-600 text-white rounded-2xl shadow-md shadow-blue-500/20">
                            <SlidersHorizontal className="w-5 h-5" />
                        </div>
                        <div>
                            <h2 className="text-lg font-black text-zinc-900 dark:text-white tracking-tight">
                                Parametrización de Información para Zeus ERP
                            </h2>
                            <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                Configura de forma dinámica qué campos se envían a Zeus en la <b>Descripción de Ítems</b> y <b>Observaciones</b>, su orden, separadores y etiquetas personalizadas.
                            </p>
                        </div>
                    </div>
                </div>

                <div className="flex items-center gap-2 self-end md:self-auto">
                    <button
                        type="button"
                        onClick={handleResetDefaults}
                        className="px-4 py-2.5 rounded-xl border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 font-bold text-xs hover:bg-zinc-50 dark:hover:bg-zinc-700 transition-all flex items-center gap-2 cursor-pointer shadow-sm"
                    >
                        <RotateCcw className="w-4 h-4 text-zinc-400" />
                        <span>Restablecer</span>
                    </button>
                    <button
                        type="button"
                        onClick={handleSave}
                        disabled={saving}
                        className="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-xs shadow-md shadow-blue-500/20 transition-all flex items-center gap-2 cursor-pointer disabled:opacity-50"
                    >
                        {saving ? (
                            <RefreshCw className="w-4 h-4 animate-spin" />
                        ) : (
                            <Save className="w-4 h-4" />
                        )}
                        <span>{saving ? 'Guardando...' : 'Guardar Configuración'}</span>
                    </button>
                </div>
            </div>

            {/* Mensajes de estado */}
            {statusMessage && (
                <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={cn(
                        "p-4 rounded-2xl border flex items-center gap-3 text-sm font-bold",
                        statusMessage.type === 'success'
                            ? "bg-emerald-50 dark:bg-emerald-950/40 border-emerald-200 dark:border-emerald-800 text-emerald-800 dark:text-emerald-300"
                            : "bg-rose-50 dark:bg-rose-950/40 border-rose-200 dark:border-rose-800 text-rose-800 dark:text-rose-300"
                    )}
                >
                    {statusMessage.type === 'success' ? (
                        <CheckCircle2 className="w-5 h-5 text-emerald-600 dark:text-emerald-400 shrink-0" />
                    ) : (
                        <AlertCircle className="w-5 h-5 text-rose-600 dark:text-rose-400 shrink-0" />
                    )}
                    <span>{statusMessage.text}</span>
                </motion.div>
            )}

            {/* ========================================================= */}
            {/* SECCIÓN A: DESCRIPCIÓN DE ÍTEMS */}
            {/* ========================================================= */}
            <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm space-y-6">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-zinc-100 dark:border-zinc-800">
                    <div className="flex items-center gap-3">
                        <div className="p-2 bg-blue-100 dark:bg-blue-900/40 text-blue-600 dark:text-blue-400 rounded-xl">
                            <Layers className="w-5 h-5" />
                        </div>
                        <div>
                            <h3 className="text-base font-black text-zinc-900 dark:text-white">
                                A. Descripción de los Ítems (Servicios)
                            </h3>
                            <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                Selecciona los campos a incluir en la descripción del producto enviado a Zeus (campo <code>ds_descrip</code>).
                            </p>
                        </div>
                    </div>

                    {/* Selector de Separador */}
                    <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-zinc-600 dark:text-zinc-400">Separador:</span>
                        <input
                            type="text"
                            value={itemConfig.separator}
                            onChange={(e) => updateSeparator('item', e.target.value)}
                            placeholder=" - "
                            className="w-20 px-3 py-1.5 text-center font-mono text-xs font-bold bg-zinc-100 dark:bg-zinc-800 border border-zinc-300 dark:border-zinc-700 rounded-lg text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500"
                        />
                        <div className="flex items-center gap-1">
                            {[' - ', ' | ', ', ', ' / '].map(sep => (
                                <button
                                    key={sep}
                                    type="button"
                                    onClick={() => updateSeparator('item', sep)}
                                    className={cn(
                                        "px-2 py-1 text-[10px] font-mono font-bold rounded border cursor-pointer transition-all",
                                        itemConfig.separator === sep
                                            ? "bg-blue-600 text-white border-blue-600"
                                            : "bg-zinc-100 dark:bg-zinc-800 border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200"
                                    )}
                                >
                                    {sep.trim() || 'espacio'}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Tabla Interactiva de Campos */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                        <thead>
                            <tr className="border-b border-zinc-200 dark:border-zinc-800 text-zinc-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="pb-3 w-16 text-center">Enviar</th>
                                <th className="pb-3 w-20 text-center">Orden</th>
                                <th className="pb-3">Campo en Korex</th>
                                <th className="pb-3">Etiqueta Personalizada (editable)</th>
                                <th className="pb-3 w-24 text-center">Reordenar</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60 font-medium">
                            {itemConfig.fields.map((field, idx) => (
                                <tr
                                    key={field.id}
                                    className={cn(
                                        "transition-colors",
                                        field.enabled
                                            ? "hover:bg-blue-50/40 dark:hover:bg-blue-950/20"
                                            : "opacity-50 bg-zinc-50/40 dark:bg-zinc-800/20"
                                    )}
                                >
                                    {/* Toggle Enviar */}
                                    <td className="py-3 text-center">
                                        <label className="relative inline-flex items-center cursor-pointer">
                                            <input
                                                type="checkbox"
                                                checked={field.enabled}
                                                onChange={() => toggleField('item', field.id)}
                                                className="sr-only peer"
                                            />
                                            <div className="w-9 h-5 bg-zinc-200 peer-focus:outline-none rounded-full peer dark:bg-zinc-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-zinc-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-zinc-600 peer-checked:bg-blue-600"></div>
                                        </label>
                                    </td>

                                    {/* Número de Orden */}
                                    <td className="py-3 text-center">
                                        <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 font-extrabold text-[11px]">
                                            {field.order}
                                        </span>
                                    </td>

                                    {/* Nombre del Campo */}
                                    <td className="py-3 font-bold text-zinc-900 dark:text-white">
                                        {field.name}
                                    </td>

                                    {/* Input de Etiqueta */}
                                    <td className="py-3">
                                        <input
                                            type="text"
                                            value={field.label}
                                            disabled={!field.enabled}
                                            onChange={(e) => updateLabel('item', field.id, e.target.value)}
                                            placeholder="Etiqueta..."
                                            className="w-full max-w-xs px-3 py-1.5 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg text-xs font-semibold text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-40"
                                        />
                                    </td>

                                    {/* Botones de Orden */}
                                    <td className="py-3 text-center">
                                        <div className="flex items-center justify-center gap-1">
                                            <button
                                                type="button"
                                                disabled={idx === 0}
                                                onClick={() => moveField('item', idx, 'up')}
                                                className="p-1 rounded bg-zinc-100 dark:bg-zinc-800 hover:bg-blue-100 hover:text-blue-600 dark:hover:bg-blue-900/50 disabled:opacity-30 cursor-pointer"
                                                title="Subir"
                                            >
                                                <ArrowUp className="w-3.5 h-3.5" />
                                            </button>
                                            <button
                                                type="button"
                                                disabled={idx === itemConfig.fields.length - 1}
                                                onClick={() => moveField('item', idx, 'down')}
                                                className="p-1 rounded bg-zinc-100 dark:bg-zinc-800 hover:bg-blue-100 hover:text-blue-600 dark:hover:bg-blue-900/50 disabled:opacity-30 cursor-pointer"
                                                title="Bajar"
                                            >
                                                <ArrowDown className="w-3.5 h-3.5" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* Caja de Vista Previa en Vivo de la Descripción */}
                <div className="p-4 rounded-2xl bg-zinc-900 text-zinc-100 border border-zinc-800 space-y-2">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2 text-xs font-bold text-blue-400">
                            <Eye className="w-4 h-4" />
                            <span>VISTA PREVIA EN VIVO — RESULTADO ENVIADO A ZEUS (ds_descrip):</span>
                        </div>
                        <span className="text-[10px] text-zinc-400 font-mono">
                            {liveItemPreview.length} caracteres
                        </span>
                    </div>
                    <div className="p-3 bg-black/50 rounded-xl font-mono text-xs text-emerald-400 break-words border border-zinc-800/80 leading-relaxed">
                        {liveItemPreview || <span className="text-zinc-600 italic">(Sin contenido generado)</span>}
                    </div>
                    <div className="flex items-center gap-1.5 text-[11px] text-zinc-400">
                        <Info className="w-3.5 h-3.5 text-blue-400 shrink-0" />
                        <span>Si un campo está vacío en una cotización o factura real, se omite automáticamente sin generar etiquetas ni separadores sobrantes.</span>
                    </div>
                </div>
            </div>

            {/* ========================================================= */}
            {/* SECCIÓN B: OBSERVACIONES */}
            {/* ========================================================= */}
            <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm space-y-6">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-zinc-100 dark:border-zinc-800">
                    <div className="flex items-center gap-3">
                        <div className="p-2 bg-indigo-100 dark:bg-indigo-900/40 text-indigo-600 dark:text-indigo-400 rounded-xl">
                            <FileText className="w-5 h-5" />
                        </div>
                        <div>
                            <h3 className="text-base font-black text-zinc-900 dark:text-white">
                                B. Observaciones (Encabezado)
                            </h3>
                            <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                Define la información complementaria a incorporar en Observaciones (campo <code>ds_observacion</code>). <b>El contenido original siempre se conserva.</b>
                            </p>
                        </div>
                    </div>

                    {/* Selector de Separador */}
                    <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-zinc-600 dark:text-zinc-400">Separador:</span>
                        <input
                            type="text"
                            value={obsConfig.separator}
                            onChange={(e) => updateSeparator('obs', e.target.value)}
                            placeholder=" - "
                            className="w-20 px-3 py-1.5 text-center font-mono text-xs font-bold bg-zinc-100 dark:bg-zinc-800 border border-zinc-300 dark:border-zinc-700 rounded-lg text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                        <div className="flex items-center gap-1">
                            {[' - ', ' | ', ', ', ' / '].map(sep => (
                                <button
                                    key={sep}
                                    type="button"
                                    onClick={() => updateSeparator('obs', sep)}
                                    className={cn(
                                        "px-2 py-1 text-[10px] font-mono font-bold rounded border cursor-pointer transition-all",
                                        obsConfig.separator === sep
                                            ? "bg-indigo-600 text-white border-indigo-600"
                                            : "bg-zinc-100 dark:bg-zinc-800 border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200"
                                    )}
                                >
                                    {sep.trim() || 'espacio'}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Tabla Interactiva de Campos */}
                <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                        <thead>
                            <tr className="border-b border-zinc-200 dark:border-zinc-800 text-zinc-400 font-bold uppercase tracking-wider text-[10px]">
                                <th className="pb-3 w-16 text-center">Enviar</th>
                                <th className="pb-3 w-20 text-center">Orden</th>
                                <th className="pb-3">Campo en Korex</th>
                                <th className="pb-3">Etiqueta Personalizada (editable)</th>
                                <th className="pb-3 w-24 text-center">Reordenar</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60 font-medium">
                            {obsConfig.fields.map((field, idx) => (
                                <tr
                                    key={field.id}
                                    className={cn(
                                        "transition-colors",
                                        field.enabled
                                            ? "hover:bg-indigo-50/40 dark:hover:bg-indigo-950/20"
                                            : "opacity-50 bg-zinc-50/40 dark:bg-zinc-800/20"
                                    )}
                                >
                                    {/* Toggle Enviar */}
                                    <td className="py-3 text-center">
                                        <label className="relative inline-flex items-center cursor-pointer">
                                            <input
                                                type="checkbox"
                                                checked={field.enabled}
                                                onChange={() => toggleField('obs', field.id)}
                                                className="sr-only peer"
                                            />
                                            <div className="w-9 h-5 bg-zinc-200 peer-focus:outline-none rounded-full peer dark:bg-zinc-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-zinc-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all dark:border-zinc-600 peer-checked:bg-indigo-600"></div>
                                        </label>
                                    </td>

                                    {/* Número de Orden */}
                                    <td className="py-3 text-center">
                                        <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 font-extrabold text-[11px]">
                                            {field.order}
                                        </span>
                                    </td>

                                    {/* Nombre del Campo */}
                                    <td className="py-3 font-bold text-zinc-900 dark:text-white">
                                        {field.name}
                                    </td>

                                    {/* Input de Etiqueta */}
                                    <td className="py-3">
                                        <input
                                            type="text"
                                            value={field.label}
                                            disabled={!field.enabled}
                                            onChange={(e) => updateLabel('obs', field.id, e.target.value)}
                                            placeholder="Etiqueta..."
                                            className="w-full max-w-xs px-3 py-1.5 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg text-xs font-semibold text-zinc-900 dark:text-white outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-40"
                                        />
                                    </td>

                                    {/* Botones de Orden */}
                                    <td className="py-3 text-center">
                                        <div className="flex items-center justify-center gap-1">
                                            <button
                                                type="button"
                                                disabled={idx === 0}
                                                onClick={() => moveField('obs', idx, 'up')}
                                                className="p-1 rounded bg-zinc-100 dark:bg-zinc-800 hover:bg-indigo-100 hover:text-indigo-600 dark:hover:bg-indigo-900/50 disabled:opacity-30 cursor-pointer"
                                                title="Subir"
                                            >
                                                <ArrowUp className="w-3.5 h-3.5" />
                                            </button>
                                            <button
                                                type="button"
                                                disabled={idx === obsConfig.fields.length - 1}
                                                onClick={() => moveField('obs', idx, 'down')}
                                                className="p-1 rounded bg-zinc-100 dark:bg-zinc-800 hover:bg-indigo-100 hover:text-indigo-600 dark:hover:bg-indigo-900/50 disabled:opacity-30 cursor-pointer"
                                                title="Bajar"
                                            >
                                                <ArrowDown className="w-3.5 h-3.5" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* Caja de Vista Previa en Vivo de Observaciones */}
                <div className="p-4 rounded-2xl bg-zinc-900 text-zinc-100 border border-zinc-800 space-y-2">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2 text-xs font-bold text-indigo-400">
                            <Eye className="w-4 h-4" />
                            <span>VISTA PREVIA EN VIVO — OBSERVACIONES ENVIADAS A ZEUS (ds_observacion):</span>
                        </div>
                        <span className="text-[10px] text-zinc-400 font-mono">
                            {liveObsPreview.length} caracteres
                        </span>
                    </div>
                    <div className="p-3 bg-black/50 rounded-xl font-mono text-xs text-amber-300 break-words border border-zinc-800/80 leading-relaxed">
                        {liveObsPreview || <span className="text-zinc-600 italic">(Sin observaciones)</span>}
                    </div>
                    <div className="flex items-center gap-1.5 text-[11px] text-zinc-400">
                        <Sparkles className="w-3.5 h-3.5 text-indigo-400 shrink-0" />
                        <span>Se conservan al 100% las observaciones originales digitadas por el asesor y se anexan los datos complementarios seleccionados.</span>
                    </div>
                </div>
            </div>
        </div>
    )
}
