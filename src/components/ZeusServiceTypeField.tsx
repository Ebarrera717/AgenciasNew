'use client'

import React, { useState, useEffect, useRef } from 'react';
import { Search, X, CheckCircle2, AlertTriangle, Loader2, RefreshCw } from 'lucide-react';

export interface ZeusServiceTypeItem {
    id: number;
    code: string;
    description: string;
    detail?: string;
}

export interface ZeusServiceTypeValidation {
    valid: boolean;
    status: 'IDLE' | 'EMPTY' | 'ACTIVE' | 'INACTIVE' | 'NOT_FOUND' | 'ERROR';
    code?: string;
    description?: string;
    message?: string;
}

interface ZeusServiceTypeFieldProps {
    value: string;
    onChange: (val: string) => void;
    onValidationChange?: (validation: ZeusServiceTypeValidation) => void;
    preloadedTypes?: ZeusServiceTypeItem[];
    placeholder?: string;
}

export default function ZeusServiceTypeField({
    value,
    onChange,
    onValidationChange,
    preloadedTypes,
    placeholder = 'Ej. HTN o buscar...'
}: ZeusServiceTypeFieldProps) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [items, setItems] = useState<ZeusServiceTypeItem[]>(preloadedTypes || []);
    const [loadingList, setLoadingList] = useState(false);
    const [listError, setListError] = useState<string | null>(null);

    const [validating, setValidating] = useState(false);
    const [validation, setValidation] = useState<ZeusServiceTypeValidation>({
        valid: true,
        status: 'IDLE'
    });

    const lastValidatedValue = useRef<string | null>(null);

    useEffect(() => {
        if (preloadedTypes && preloadedTypes.length > 0 && items.length === 0) {
            setItems(preloadedTypes);
        }
    }, [preloadedTypes]);

    // Validar valor inicial si ya viene diligenciado al cargar una cotización existente
    useEffect(() => {
        const trimmed = (value || '').trim();
        if (!trimmed) {
            const emptyState: ZeusServiceTypeValidation = { valid: true, status: 'EMPTY', code: '', description: '', message: '' };
            setValidation(emptyState);
            onValidationChange?.(emptyState);
            lastValidatedValue.current = '';
            return;
        }
        // Si ya tenemos preloadedTypes, verificar rápido en memoria primero
        if (preloadedTypes && preloadedTypes.length > 0 && lastValidatedValue.current === null) {
            const found = preloadedTypes.find(
                t => t.code.toUpperCase() === trimmed.toUpperCase() || t.description.toUpperCase() === trimmed.toUpperCase()
            );
            if (found) {
                const okState: ZeusServiceTypeValidation = {
                    valid: true,
                    status: 'ACTIVE',
                    code: found.code,
                    description: found.description,
                    message: ''
                };
                setValidation(okState);
                onValidationChange?.(okState);
                lastValidatedValue.current = trimmed;
            }
        }
    }, [value, preloadedTypes]);

    const fetchServiceTypes = async (query = '') => {
        setLoadingList(true);
        setListError(null);
        try {
            const url = `/api/zeus/service-types${query ? `?search=${encodeURIComponent(query)}` : ''}`;
            const res = await fetch(url);
            const data = await res.json();
            if (!res.ok || !data.success) {
                setListError(data.error || 'No fue posible consultar los tipos de servicio en ZeusERP.');
                setItems([]);
            } else {
                setItems(Array.isArray(data.items) ? data.items : []);
            }
        } catch (err: any) {
            setListError(err?.message || 'Error de conexión al consultar ZeusERP.');
            setItems([]);
        } finally {
            setLoadingList(false);
        }
    };

    const validateAgainstZeus = async (rawValue: string) => {
        const trimmed = (rawValue || '').trim();
        if (!trimmed) {
            const emptyState: ZeusServiceTypeValidation = { valid: true, status: 'EMPTY', code: '', description: '', message: '' };
            setValidation(emptyState);
            onValidationChange?.(emptyState);
            lastValidatedValue.current = '';
            return;
        }

        if (lastValidatedValue.current === trimmed && validation.status !== 'IDLE' && validation.status !== 'ERROR') {
            return;
        }

        setValidating(true);
        try {
            const res = await fetch(`/api/zeus/service-types?validate=${encodeURIComponent(trimmed)}`);
            const data = await res.json();

            if (!res.ok || !data.success) {
                const errState: ZeusServiceTypeValidation = {
                    valid: false,
                    status: 'ERROR',
                    message: data.error || 'No se pudo validar el tipo de servicio contra ZeusERP.'
                };
                setValidation(errState);
                onValidationChange?.(errState);
                return;
            }

            if (data.valid && data.status === 'ACTIVE') {
                const okState: ZeusServiceTypeValidation = {
                    valid: true,
                    status: 'ACTIVE',
                    code: data.code,
                    description: data.description,
                    message: ''
                };
                setValidation(okState);
                onValidationChange?.(okState);
                lastValidatedValue.current = data.code;
                // Normalizar el código si el usuario escribió minúsculas o el nombre exacto
                if (data.code && data.code !== rawValue) {
                    onChange(data.code);
                }
            } else {
                const invalidState: ZeusServiceTypeValidation = {
                    valid: false,
                    status: data.status || 'NOT_FOUND',
                    code: data.code || '',
                    description: data.description || '',
                    message: data.message || `El tipo de servicio "${trimmed}" no es válido o está inactivo en ZeusERP.`
                };
                setValidation(invalidState);
                onValidationChange?.(invalidState);
                lastValidatedValue.current = trimmed;
            }
        } catch (err: any) {
            const errState: ZeusServiceTypeValidation = {
                valid: false,
                status: 'ERROR',
                message: err?.message || 'Error de red validando tipo de servicio en ZeusERP.'
            };
            setValidation(errState);
            onValidationChange?.(errState);
        } finally {
            setValidating(false);
        }
    };

    const handleOpenModal = () => {
        setSearchTerm('');
        setIsModalOpen(true);
        fetchServiceTypes('');
    };

    const handleSelectItem = (item: ZeusServiceTypeItem) => {
        onChange(item.code);
        const okState: ZeusServiceTypeValidation = {
            valid: true,
            status: 'ACTIVE',
            code: item.code,
            description: item.description,
            message: ''
        };
        setValidation(okState);
        onValidationChange?.(okState);
        lastValidatedValue.current = item.code;
        setIsModalOpen(false);
    };

    const filteredItems = items.filter((item) => {
        const q = searchTerm.trim().toLowerCase();
        if (!q) return true;
        return (
            item.code.toLowerCase().includes(q) ||
            item.description.toLowerCase().includes(q) ||
            (item.detail || '').toLowerCase().includes(q)
        );
    });

    const isInvalid = !validation.valid && (validation.status === 'INACTIVE' || validation.status === 'NOT_FOUND' || validation.status === 'ERROR');
    const isValidActive = validation.valid && validation.status === 'ACTIVE' && Boolean((value || '').trim());

    return (
        <div className="w-full">
            <div className="relative flex items-center">
                <input
                    type="text"
                    className={`w-full h-9 bg-white dark:bg-zinc-900 rounded-lg pl-2.5 pr-9 border outline-none text-xs transition-colors ${
                        isInvalid
                            ? 'border-red-400 dark:border-red-500 focus:ring-1 focus:ring-red-400'
                            : isValidActive
                            ? 'border-emerald-400 dark:border-emerald-600 focus:ring-1 focus:ring-emerald-400'
                            : 'border-zinc-200 dark:border-zinc-800 focus:border-blue-400'
                    }`}
                    value={value || ''}
                    placeholder={placeholder}
                    onChange={(e) => {
                        const nextVal = e.target.value;
                        onChange(nextVal);
                        lastValidatedValue.current = null;
                        if (!nextVal.trim()) {
                            const emptyState: ZeusServiceTypeValidation = { valid: true, status: 'EMPTY', code: '', description: '', message: '' };
                            setValidation(emptyState);
                            onValidationChange?.(emptyState);
                        } else if (validation.status !== 'IDLE') {
                            setValidation({ valid: true, status: 'IDLE' });
                        }
                    }}
                    onBlur={() => validateAgainstZeus(value || '')}
                />
                <button
                    type="button"
                    onClick={handleOpenModal}
                    title="Buscar tipo de servicio activo en ZeusERP"
                    className="absolute right-1 top-1/2 -translate-y-1/2 h-7 w-7 flex items-center justify-center rounded-md text-zinc-500 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-950/40 transition-colors"
                >
                    {validating ? (
                        <Loader2 className="w-3.5 h-3.5 animate-spin text-blue-500" />
                    ) : (
                        <Search className="w-3.5 h-3.5" />
                    )}
                </button>
            </div>

            {isValidActive && validation.description && (
                <p className="mt-1 flex items-center gap-1 text-[10px] text-emerald-600 dark:text-emerald-400 leading-tight truncate" title={`${validation.code} - ${validation.description}`}>
                    <CheckCircle2 className="w-3 h-3 shrink-0" />
                    <span className="truncate">{validation.description}</span>
                </p>
            )}

            {isInvalid && validation.message && (
                <p className="mt-1 flex items-start gap-1 text-[10px] text-red-600 dark:text-red-400 leading-tight" title={validation.message}>
                    <AlertTriangle className="w-3 h-3 shrink-0 mt-0.5" />
                    <span>{validation.message}</span>
                </p>
            )}

            {isModalOpen && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
                    <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-2xl w-full max-w-xl max-h-[80vh] flex flex-col overflow-hidden">
                        {/* Header */}
                        <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-200 dark:border-zinc-800">
                            <div>
                                <h3 className="text-sm font-bold text-zinc-900 dark:text-zinc-100">
                                    Tipos de Servicio — ZeusERP
                                </h3>
                                <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                    Solo se muestran tipos de servicio activos y disponibles en ZeusERP
                                </p>
                            </div>
                            <button
                                type="button"
                                onClick={() => setIsModalOpen(false)}
                                className="p-1.5 rounded-lg text-zinc-400 hover:text-zinc-600 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
                            >
                                <X className="w-4 h-4" />
                            </button>
                        </div>

                        {/* Search Bar */}
                        <div className="px-5 py-3 border-b border-zinc-100 dark:border-zinc-800/80 flex items-center gap-2">
                            <div className="relative flex-1">
                                <Search className="w-4 h-4 text-zinc-400 absolute left-3 top-1/2 -translate-y-1/2" />
                                <input
                                    type="text"
                                    autoFocus
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    placeholder="Buscar por código o descripción (ej. HTN, HOTEL, TRASLADO)..."
                                    className="w-full h-9 pl-9 pr-3 text-xs bg-zinc-50 dark:bg-zinc-950 border border-zinc-200 dark:border-zinc-800 rounded-lg outline-none focus:border-blue-500"
                                />
                            </div>
                            <button
                                type="button"
                                onClick={() => fetchServiceTypes('')}
                                disabled={loadingList}
                                title="Actualizar desde ZeusERP"
                                className="h-9 px-3 rounded-lg border border-zinc-200 dark:border-zinc-800 text-xs font-medium text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 flex items-center gap-1.5 transition-colors disabled:opacity-50"
                            >
                                <RefreshCw className={`w-3.5 h-3.5 ${loadingList ? 'animate-spin' : ''}`} />
                                Actualizar
                            </button>
                        </div>

                        {/* Table / Results */}
                        <div className="flex-1 overflow-y-auto px-5 py-3">
                            {loadingList ? (
                                <div className="py-12 flex flex-col items-center justify-center gap-2 text-zinc-500">
                                    <Loader2 className="w-6 h-6 animate-spin text-blue-600" />
                                    <span className="text-xs">Consultando tipos de servicio en ZeusERP...</span>
                                </div>
                            ) : listError ? (
                                <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-900/50 text-red-700 dark:text-red-300 text-xs flex items-start gap-2">
                                    <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
                                    <div>
                                        <p className="font-semibold">No fue posible consultar ZeusERP</p>
                                        <p className="mt-0.5 opacity-90">{listError}</p>
                                    </div>
                                </div>
                            ) : filteredItems.length === 0 ? (
                                <div className="py-10 text-center text-xs text-zinc-500">
                                    No se encontraron tipos de servicio activos que coincidan con &ldquo;{searchTerm}&rdquo;.
                                </div>
                            ) : (
                                <table className="w-full text-left border-collapse">
                                    <thead>
                                        <tr className="border-b border-zinc-200 dark:border-zinc-800 text-[10px] uppercase font-bold text-zinc-400">
                                            <th className="py-2 px-2 w-24">Código</th>
                                            <th className="py-2 px-2">Descripción</th>
                                            <th className="py-2 px-2 w-24 text-right">Acción</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60">
                                        {filteredItems.map((item) => {
                                            const isSelected = (value || '').trim().toUpperCase() === item.code.toUpperCase();
                                            return (
                                                <tr
                                                    key={item.id}
                                                    onClick={() => handleSelectItem(item)}
                                                    className={`cursor-pointer transition-colors ${
                                                        isSelected
                                                            ? 'bg-blue-50/80 dark:bg-blue-950/30'
                                                            : 'hover:bg-zinc-50 dark:hover:bg-zinc-800/60'
                                                    }`}
                                                >
                                                    <td className="py-2.5 px-2 text-xs font-mono font-bold text-blue-600 dark:text-blue-400">
                                                        {item.code}
                                                    </td>
                                                    <td className="py-2.5 px-2 text-xs text-zinc-800 dark:text-zinc-200">
                                                        {item.description}
                                                    </td>
                                                    <td className="py-2.5 px-2 text-right">
                                                        <span className="inline-flex items-center px-2.5 py-1 rounded-md text-[11px] font-semibold bg-blue-600 text-white hover:bg-blue-700">
                                                            Seleccionar
                                                        </span>
                                                    </td>
                                                </tr>
                                            );
                                        })}
                                    </tbody>
                                </table>
                            )}
                        </div>

                        {/* Footer */}
                        <div className="px-5 py-3 border-t border-zinc-200 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-950/50 flex items-center justify-between text-[11px] text-zinc-500">
                            <span>{filteredItems.length} tipo(s) de servicio activos</span>
                            <button
                                type="button"
                                onClick={() => setIsModalOpen(false)}
                                className="px-3 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 font-medium"
                            >
                                Cerrar
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
