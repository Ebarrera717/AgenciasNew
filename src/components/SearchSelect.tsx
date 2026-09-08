'use client'

import React, { useState, useMemo, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, X, Check } from 'lucide-react'

interface SearchSelectProps {
    options: any[];
    value: string;
    onChange: (val: string, option?: any) => void;
    placeholder?: string;
    disabled?: boolean;
    labelKey?: string;
    secondaryKey?: string;
    valueKey?: string;
    allowCustomValue?: boolean;
    hasError?: boolean;
    className?: string;
    remoteSearchEndpoint?: string;
    minSearchLength?: number;
}

export function SearchSelect({ 
    options = [], 
    value, 
    onChange, 
    placeholder = "Seleccionar...", 
    disabled = false, 
    labelKey = "name", 
    secondaryKey = "code",
    valueKey,
    allowCustomValue = false,
    hasError = false,
    className = "",
    remoteSearchEndpoint,
    minSearchLength = 1
}: SearchSelectProps) {
    const [isOpen, setIsOpen] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [localOptions, setLocalOptions] = useState<any[]>(options);
    const [isLoading, setIsLoading] = useState(false);

    // Merge options without duplicates
    const mergeOptions = (existing: any[], incoming: any[]) => {
        const map = new Map();
        existing.forEach(item => {
            if (item.id !== undefined && item.id !== null) map.set(String(item.id), item);
            else if (item.code !== undefined && item.code !== null) map.set(String(item.code), item);
            else if (item.name !== undefined && item.name !== null) map.set(String(item.name), item);
        });
        incoming.forEach(item => {
            if (item.id !== undefined && item.id !== null) map.set(String(item.id), item);
            else if (item.code !== undefined && item.code !== null) map.set(String(item.code), item);
            else if (item.name !== undefined && item.name !== null) map.set(String(item.name), item);
        });
        return Array.from(map.values());
    };

    // Update localOptions when options prop changes
    useEffect(() => {
        if (options && options.length > 0) {
            setLocalOptions(prev => mergeOptions(prev, options));
        }
    }, [options]);

    // Fetch initial selected option if not present in localOptions
    useEffect(() => {
        if (!value || !remoteSearchEndpoint) return;
        
        const found = localOptions.find(o => 
            (o.id !== undefined && o.id !== null && String(o.id) === String(value)) ||
            (o.code !== undefined && o.code !== null && String(o.code) === String(value)) ||
            (o[labelKey] !== undefined && o[labelKey] !== null && String(o[labelKey]).toLowerCase() === String(value).toLowerCase())
        );

        if (!found) {
            const fetchInitial = async () => {
                try {
                    const res = await fetch(`${remoteSearchEndpoint}?id=${encodeURIComponent(value)}`);
                    if (res.ok) {
                        const item = await res.json();
                        if (item && !item.message) {
                            setLocalOptions(prev => mergeOptions(prev, [item]));
                        }
                    }
                } catch (err) {
                    console.error("Error fetching initial option:", err);
                }
            };
            fetchInitial();
        }
    }, [value, remoteSearchEndpoint, labelKey]);

    // Handle remote search
    useEffect(() => {
        if (!isOpen || !remoteSearchEndpoint) return;
        
        if (searchTerm.trim().length < minSearchLength) {
            return;
        }

        const delayDebounce = setTimeout(async () => {
            setIsLoading(true);
            try {
                const res = await fetch(`${remoteSearchEndpoint}?search=${encodeURIComponent(searchTerm)}`);
                if (res.ok) {
                    const resData = await res.json();
                    const results = Array.isArray(resData) ? resData : (Array.isArray(resData?.data) ? resData.data : []);
                    setLocalOptions(prev => mergeOptions(prev, results));
                }
            } catch (err) {
                console.error("Error fetching remote options:", err);
            } finally {
                setIsLoading(false);
            }
        }, 300);

        return () => clearTimeout(delayDebounce);
    }, [searchTerm, isOpen, remoteSearchEndpoint, minSearchLength]);

    const selectedOption = useMemo(() => {
        if (!value) return null;
        
        // 1. Priority: exact match on ID
        let found = localOptions.find(o => o.id !== undefined && o.id !== null && String(o.id) === String(value));
        if (found) return found;

        // 2. Exact match on code
        found = localOptions.find(o => o.code !== undefined && o.code !== null && String(o.code) === String(value));
        if (found) return found;

        // 3. Match on document or secondaryKey
        found = localOptions.find(o => 
            (o.document !== undefined && o.document !== null && String(o.document) === String(value)) ||
            (secondaryKey && o[secondaryKey] !== undefined && o[secondaryKey] !== null && String(o[secondaryKey]) === String(value))
        );
        if (found) return found;

        // 4. Match on labelKey (name) or valueKey
        found = localOptions.find(o => 
            (labelKey && o[labelKey] !== undefined && o[labelKey] !== null && String(o[labelKey]).toLowerCase() === String(value).toLowerCase()) ||
            (valueKey && o[valueKey] !== undefined && o[valueKey] !== null && String(o[valueKey]).toLowerCase() === String(value).toLowerCase())
        );
        if (found) return found;

        // 5. Fallback custom value option
        if (allowCustomValue && value) {
            return { [labelKey || 'name']: value, [secondaryKey || 'code']: '' };
        }

        return null;
    }, [localOptions, value, secondaryKey, labelKey, valueKey, allowCustomValue]);

    const filteredOptions = useMemo(() => {
        if (!searchTerm) {
            if (remoteSearchEndpoint) return localOptions;
            return localOptions;
        }
        const lowerTerm = searchTerm.toLowerCase();
        return localOptions.filter(o => 
            (o[labelKey] && String(o[labelKey]).toLowerCase().includes(lowerTerm)) ||
            (o[secondaryKey] && String(o[secondaryKey]).toLowerCase().includes(lowerTerm))
        );
    }, [localOptions, searchTerm, labelKey, secondaryKey, remoteSearchEndpoint]);

    return (
        <>
            <button
                type="button"
                onClick={() => !disabled && setIsOpen(true)}
                disabled={disabled}
                className={className || `w-full h-11 sm:h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-3 sm:px-4 border outline-none flex items-center justify-between text-left focus:ring-2 focus:ring-blue-500 ${disabled ? 'opacity-50 cursor-not-allowed' : 'hover:bg-zinc-100 dark:hover:bg-zinc-700'} ${hasError ? 'border-red-500 ring-2 ring-red-100 dark:ring-red-950/30' : 'border-zinc-200 dark:border-zinc-700'}`}
            >
                <span className="truncate text-xs sm:text-sm font-medium dark:text-white">
                    {selectedOption 
                        ? `${selectedOption[labelKey]}${selectedOption[secondaryKey] ? ` - ${selectedOption[secondaryKey]}` : ''}` 
                        : <span className="text-zinc-400">{placeholder}</span>
                    }
                </span>
                <Search className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-zinc-400 shrink-0" />
            </button>

            <AnimatePresence>
                {isOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setIsOpen(false)}
                            className="absolute inset-0 bg-black/50 backdrop-blur-sm"
                        />
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.95, y: 20 }}
                            className="relative w-full max-w-lg bg-white dark:bg-zinc-900 rounded-2xl shadow-xl border border-zinc-200 dark:border-zinc-800 overflow-hidden flex flex-col max-h-[85vh] sm:max-h-[80vh]"
                        >
                            <div className="p-3 sm:p-4 border-b border-zinc-200 dark:border-zinc-800 flex items-center gap-3">
                                <Search className="w-4 h-4 sm:w-5 sm:h-5 text-zinc-400" />
                                <input
                                    type="text"
                                    autoFocus
                                    placeholder={`Buscar por nombre o código...`}
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    className="flex-1 bg-transparent outline-none text-zinc-900 dark:text-white text-sm sm:text-base"
                                />
                                <button onClick={() => setIsOpen(false)} className="p-1.5 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg text-zinc-500">
                                    <X className="w-4 h-4 sm:w-5 sm:h-5" />
                                </button>
                            </div>
                            
                            <div className="overflow-y-auto flex-1 p-2">
                                {isLoading ? (
                                    <div className="text-center p-8 text-zinc-500 text-sm flex items-center justify-center gap-2">
                                        <span className="animate-spin border-2 border-blue-500 border-t-transparent rounded-full w-4 h-4" />
                                        Cargando...
                                    </div>
                                ) : (
                                    <div className="space-y-1">
                                        {allowCustomValue && searchTerm.trim() && !filteredOptions.some(o => String(o[labelKey || 'name']).toLowerCase() === searchTerm.trim().toLowerCase()) && (
                                            <button
                                                type="button"
                                                onClick={() => {
                                                    onChange(searchTerm.trim());
                                                    setIsOpen(false);
                                                    setSearchTerm('');
                                                }}
                                                className="w-full text-left p-2.5 sm:p-3 rounded-xl flex items-center justify-between hover:bg-blue-50 dark:hover:bg-blue-900/20 text-blue-600 dark:text-blue-400 font-medium transition-colors border border-dashed border-blue-300 dark:border-blue-700 mb-2"
                                            >
                                                <div className="text-xs sm:text-sm">
                                                    Usar "<span className="font-bold">{searchTerm.trim()}</span>" como valor personalizado
                                                </div>
                                                <Check className="w-4 h-4 shrink-0" />
                                            </button>
                                        )}

                                        {filteredOptions.length === 0 && (!allowCustomValue || !searchTerm.trim()) ? (
                                            <div className="text-center p-8 text-zinc-500 text-sm">No se encontraron resultados</div>
                                        ) : (
                                            filteredOptions.map(opt => {
                                                const isSelected = selectedOption && (
                                                    (opt.id !== undefined && String(opt.id) === String(selectedOption.id)) ||
                                                    (opt.code !== undefined && String(opt.code) === String(selectedOption.code)) ||
                                                    (opt[labelKey] !== undefined && String(opt[labelKey]).toLowerCase() === String(selectedOption[labelKey]).toLowerCase())
                                                );
                                                return (
                                                    <button
                                                        key={opt.id || opt.code || opt[labelKey] || Math.random()}
                                                        type="button"
                                                        onClick={() => {
                                                            const valToEmit = valueKey && opt[valueKey] !== undefined && opt[valueKey] !== null
                                                                ? String(opt[valueKey])
                                                                : (opt.code && value === String(opt.code) ? String(opt.code) : String(opt.id || opt.code || opt[labelKey] || ''));
                                                            onChange(valToEmit, opt);
                                                            setIsOpen(false);
                                                            setSearchTerm('');
                                                        }}
                                                        className={`w-full text-left p-2.5 sm:p-3 rounded-xl flex items-center justify-between group transition-colors ${
                                                            isSelected 
                                                                ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 font-semibold' 
                                                                : 'hover:bg-zinc-50 dark:hover:bg-zinc-800/50 text-zinc-700 dark:text-zinc-300'
                                                        }`}
                                                    >
                                                        <div>
                                                            <div className="text-xs sm:text-sm">{opt[labelKey]}</div>
                                                            {opt[secondaryKey] && (
                                                                <div className="text-[10px] sm:text-xs opacity-60 mt-0.5">{opt[secondaryKey]}</div>
                                                            )}
                                                        </div>
                                                        {isSelected && <Check className="w-4 h-4 shrink-0" />}
                                                    </button>
                                                )
                                            })
                                        )}
                                    </div>
                                )}
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </>
    )
}
