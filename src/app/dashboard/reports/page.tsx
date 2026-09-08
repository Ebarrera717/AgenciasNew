'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { 
    FileText, 
    Plus, 
    Database, 
    Table as TableIcon, 
    X, 
    Check, 
    Calculator, 
    Download, 
    Play, 
    Save, 
    Loader2, 
    Trash2, 
    PieChart, 
    Edit, 
    Eye, 
    EyeOff, 
    Filter, 
    Search, 
    Printer, 
    FileSpreadsheet,
    ArrowUp,
    ArrowDown,
    Copy,
    CheckSquare,
    Square,
    Users,
    Building2,
    SlidersHorizontal,
    Layers
} from 'lucide-react'
import * as XLSX from 'xlsx'
import { cn } from '@/lib/utils'

export default function ReportsPage() {
    const [reports, setReports] = useState<any[]>([])
    const [modules, setModules] = useState<Record<string, any>>({})
    const [loading, setLoading] = useState(true)
    const [view, setView] = useState<'list' | 'builder' | 'viewer'>('list')
    
    // Builder State
    const [templateName, setTemplateName] = useState('')
    const [baseTable, setBaseTable] = useState<string>('Quotation')
    const [selectedColumns, setSelectedColumns] = useState<any[]>([])
    const [reportFilters, setReportFilters] = useState<any[]>([])
    const [isCustomSql, setIsCustomSql] = useState(false)
    const [customSql, setCustomSql] = useState('')
    const [editingReportId, setEditingReportId] = useState<number | null>(null)
    
    // Field Selector Modal State (Selector de Campos tipo chequeo estilo Sucursales)
    const [isFieldSelectorModalOpen, setIsFieldSelectorModalOpen] = useState(false)
    const [fieldSearchTerm, setFieldSearchTerm] = useState('')
    const [activeFieldCategory, setActiveFieldCategory] = useState<'all' | 'cabecera' | 'productos'>('all')

    // Manual Filter Modal
    const [isManualFilterModalOpen, setIsManualFilterModalOpen] = useState(false)
    const [manualFilterField, setManualFilterField] = useState('')
    const [manualFilterLabel, setManualFilterLabel] = useState('')
    const [manualFilterType, setManualFilterType] = useState('text')
    const [manualFilterIndex, setManualFilterIndex] = useState<number | null>(null)
    
    // Viewer State
    const [reportResult, setReportResult] = useState<any[]>([])
    const [running, setRunning] = useState(false)
    const [activeReport, setActiveReport] = useState<any>(null)
    const [sorts, setSorts] = useState<any[]>([])
    const [runtimeFilterValues, setRuntimeFilterValues] = useState<Record<string, any>>({})
    const [isRuntimeFilterModalOpen, setIsRuntimeFilterModalOpen] = useState(false)
    const [copiedToClipboard, setCopiedToClipboard] = useState(false)
    const [isScreenReportModalOpen, setIsScreenReportModalOpen] = useState(false)

    // Lookup Helper Modal State (Activado por la Lupa en los filtros)
    const [isLookupModalOpen, setIsLookupModalOpen] = useState(false)
    const [lookupFilter, setLookupFilter] = useState<any>(null)
    const [lookupSearchTerm, setLookupSearchTerm] = useState('')
    const [lookupData, setLookupData] = useState<any[]>([])
    const [loadingLookup, setLoadingLookup] = useState(false)

    const openLookupHelper = async (f: any) => {
        setLookupFilter(f)
        setLookupSearchTerm('')
        setLoadingLookup(true)
        setIsLookupModalOpen(true)

        const tableAlias = (f.table_alias || '').toLowerCase()
        const columnName = (f.column_name || '').toLowerCase()
        const label = (f.filter_label || '').toLowerCase()

        let endpoint = ''

        if (tableAlias.includes('client') || columnName.includes('client') || label.includes('cliente')) {
            endpoint = '/api/clients'
        } else if (tableAlias.includes('seller') || columnName.includes('seller') || label.includes('vendedor') || label.includes('asesor')) {
            endpoint = '/api/config/sellers'
        } else if (tableAlias.includes('ticketprinter') || columnName.includes('ticketprinter') || label.includes('tiqueteador')) {
            endpoint = '/api/config/ticket-printers'
        } else if (tableAlias.includes('provider') || columnName.includes('provider') || label.includes('proveedor')) {
            endpoint = '/api/providers'
        } else if (tableAlias.includes('prestadora') || columnName.includes('prestadora') || label.includes('hotel')) {
            endpoint = '/api/config/prestadoras'
        } else if (tableAlias.includes('branch') || columnName.includes('branch') || label.includes('sucursal')) {
            endpoint = '/api/config/branches'
        } else if (tableAlias.includes('implant') || columnName.includes('implant')) {
            endpoint = '/api/config/implants'
        } else if (columnName.includes('state') || label.includes('estado')) {
            endpoint = '/api/config/quotation-states'
        } else if (columnName.includes('currency') || label.includes('moneda')) {
            endpoint = '/api/config/currencies'
        } else if (tableAlias.includes('product') || columnName.includes('product') || label.includes('producto')) {
            endpoint = '/api/products'
        }

        try {
            if (endpoint) {
                const res = await fetch(endpoint)
                if (res.ok) {
                    const data = await res.json()
                    const list = Array.isArray(data) ? data : data.data || []
                    setLookupData(list)
                } else {
                    setLookupData([])
                }
            } else {
                setLookupData([])
            }
        } catch (err) {
            console.error('Error fetching lookup helper options:', err)
            setLookupData([])
        } finally {
            setLoadingLookup(false)
        }
    }

    const selectLookupValue = (val: string) => {
        if (!lookupFilter) return
        const key = `${lookupFilter.table_alias}.${lookupFilter.column_name}`
        setRuntimeFilterValues(prev => ({ ...prev, [key]: val }))
        setIsLookupModalOpen(false)
    }

    // Formula Modal
    const [isFormulaModalOpen, setIsFormulaModalOpen] = useState(false)
    const [formulaAlias, setFormulaAlias] = useState('')
    const [formulaExpression, setFormulaExpression] = useState('')

    // Batch Report Modal State
    const [isBatchReportModalOpen, setIsBatchReportModalOpen] = useState(false)
    const [batchIdIni, setBatchIdIni] = useState('')
    const [batchIdFin, setBatchIdFin] = useState('')

    useEffect(() => {
        fetchReports()
        fetchMetadata()
    }, [])

    const fetchMetadata = async () => {
        try {
            const res = await fetch('/api/reports/metadata')
            if (res.ok) {
                const data = await res.json()
                setModules(data)
            }
        } catch (error) {
            console.error("Error fetching metadata", error)
        }
    }

    const fetchReports = async () => {
        try {
            setLoading(true)
            const res = await fetch('/api/reports')
            if (res.ok) {
                const data = await res.json()
                setReports(Array.isArray(data) ? data : [])
            }
        } catch (error) {
            console.error("Error fetching reports", error)
        } finally {
            setLoading(false)
        }
    }

    // Default configuration for initial new report
    const initDefaultQuotationReport = () => {
        setBaseTable('Quotation')
        setTemplateName('Reporte Cotizaciones Personalizado')
        setEditingReportId(null)
        setIsCustomSql(false)
        setCustomSql('')
        setSorts([{ columnExpr: 't1."id"', direction: 'DESC' }])

        // Add standard columns default
        const defaultCols = [
            { id: 't1.internalNumber', tableAlias: 't1', columnName: 'internalNumber', alias: 'Número Cotización', isCalculated: false, isVisible: true, type: 'character varying' },
            { id: 't1.date', tableAlias: 't1', columnName: 'date', alias: 'Fecha', isCalculated: false, isVisible: true, type: 'timestamp without time zone' },
            { id: 't1.state', tableAlias: 't1', columnName: 'state', alias: 'Estado', isCalculated: false, isVisible: true, type: 'character varying' },
            { id: 't_client.name', tableAlias: 't_client', columnName: 'name', alias: 'Cliente', isCalculated: false, isVisible: true, type: 'character varying' },
            { id: 't_seller.name', tableAlias: 't_seller', columnName: 'name', alias: 'Vendedor / Asesor', isCalculated: false, isVisible: true, type: 'character varying' },
            { id: 't1.totalAmount', tableAlias: 't1', columnName: 'totalAmount', alias: 'Valor Total', isCalculated: false, isVisible: true, type: 'double precision' }
        ]
        setSelectedColumns(defaultCols)

        // Add default configurable filters (Cotización ID / Número range & Dates)
        setReportFilters([
            { tableAlias: 't1', columnName: 'internalNumber', filterLabel: 'Código / Número Cotización', filterType: 'text', operator: 'LIKE' },
            { tableAlias: 't1', columnName: 'date', filterLabel: 'Fecha Cotización (Desde/Hasta)', filterType: 'date', operator: '=' }
        ])

        setView('builder')
    }

    // Toggle column selection
    const toggleColumn = (tableKey: string, tableAlias: string, col: any, friendlyNamePrefix: string = '') => {
        const colId = `${tableAlias}.${col.id}`;
        const exists = selectedColumns.find(c => c.id === colId);
        if (exists) {
            setSelectedColumns(selectedColumns.filter(c => c.id !== colId));
        } else {
            setSelectedColumns([...selectedColumns, {
                id: colId,
                tableAlias: tableAlias || 't1',
                columnName: col.id,
                alias: friendlyNamePrefix ? `${friendlyNamePrefix} - ${col.name}` : col.name,
                isCalculated: false,
                isVisible: true,
                type: col.type
            }]);
        }
    }

    const addFormula = (e: React.FormEvent) => {
        e.preventDefault()
        if (!formulaAlias || !formulaExpression) return;
        
        setSelectedColumns([...selectedColumns, {
            id: `calc_${Date.now()}`,
            tableAlias: 'calc',
            columnName: 'calc',
            alias: formulaAlias,
            isCalculated: true,
            isVisible: true,
            formulaExpression: formulaExpression
        }]);
        
        setIsFormulaModalOpen(false);
        setFormulaAlias('');
        setFormulaExpression('');
    }

    const removeColumn = (idx: number) => {
        const newCols = [...selectedColumns];
        newCols.splice(idx, 1);
        setSelectedColumns(newCols);
    }

    const editFormula = (idx: number) => {
        const col = selectedColumns[idx];
        setFormulaAlias(col.alias);
        setFormulaExpression(col.formulaExpression || '');
        removeColumn(idx);
        setIsFormulaModalOpen(true);
    }

    const moveColumnPosition = (fromIdx: number, toIdx: number) => {
        if (toIdx < 0 || toIdx >= selectedColumns.length) return;
        const newCols = [...selectedColumns];
        const [moved] = newCols.splice(fromIdx, 1);
        newCols.splice(toIdx, 0, moved);
        setSelectedColumns(newCols);
    }

    const changeColumnOrder = (idx: number, newPos: number) => {
        if (isNaN(newPos) || newPos < 1 || newPos > selectedColumns.length) return;
        moveColumnPosition(idx, newPos - 1);
    }

    const handleEdit = async (reportId: number) => {
        try {
            setLoading(true)
            const res = await fetch(`/api/reports/${reportId}`)
            if (res.ok) {
                const data = await res.json()
                setEditingReportId(reportId)
                setTemplateName(data.name)
                setBaseTable(data.base_table || 'Quotation')
                setCustomSql(data.custom_sql || '')
                setIsCustomSql(!!data.custom_sql)
                setSorts(data.sorts.map((s: any) => ({
                    columnExpr: s.column_expr,
                    direction: s.direction
                })))
                setReportFilters(data.filters?.map((f: any) => ({
                    tableAlias: f.table_alias,
                    columnName: f.column_name,
                    filterLabel: f.filter_label,
                    filterType: f.filter_type,
                    operator: f.operator
                })) || [])
                setSelectedColumns(data.columns.map((c: any) => ({
                    id: c.is_calculated ? `calc_${c.id}` : `${c.table_alias}.${c.column_name}`,
                    tableAlias: c.table_alias || 't1',
                    columnName: c.column_name,
                    alias: c.alias,
                    isCalculated: c.is_calculated,
                    isVisible: c.is_visible,
                    formulaExpression: c.formula_expression,
                    type: c.data_type
                })))
                setView('builder')
            }
        } catch (error) {
            console.error(error)
        } finally {
            setLoading(false)
        }
    }

    const saveTemplate = async () => {
        if (!templateName || (!isCustomSql && (!baseTable || selectedColumns.length === 0))) {
            alert('Debes ponerle un nombre al reporte y seleccionar al menos una columna.');
            return;
        }

        // Automatic table joins resolution
        const requiredAliases = new Set(selectedColumns.filter(c => !c.isCalculated).map(c => c.tableAlias));
        requiredAliases.delete('t1');
        
        const finalJoins: any[] = [];
        const addedAliases = new Set();

        const processRelation = (table: string, currentRelations: any[], parentAlias: string) => {
            if (!currentRelations) return;
            currentRelations.forEach(rel => {
                if (requiredAliases.has(rel.alias) && !addedAliases.has(rel.alias)) {
                    finalJoins.push({
                        tableName: rel.table,
                        alias: rel.alias,
                        joinType: rel.type,
                        joinCondition: rel.condition
                            .replace('{alias}', rel.alias)
                            .replace('{parentAlias}', parentAlias)
                    });
                    addedAliases.add(rel.alias);
                    
                    const nextModule = modules[rel.table];
                    if (nextModule && nextModule.relations) {
                        processRelation(rel.table, nextModule.relations, rel.alias);
                    }
                }
            });
        }

        if (modules[baseTable] && modules[baseTable].relations) {
            processRelation(baseTable, modules[baseTable].relations, 't1');
        }

        const payload = {
            id: editingReportId,
            name: templateName,
            baseTable: baseTable,
            joins: finalJoins,
            sorts: sorts,
            filters: reportFilters,
            custom_sql: isCustomSql ? customSql : null,
            columns: selectedColumns.map((col, index) => ({
                tableAlias: col.tableAlias || null,
                columnName: col.columnName || null,
                alias: col.alias,
                isCalculated: col.isCalculated,
                isVisible: col.isVisible,
                formulaExpression: col.formulaExpression || null,
                sortOrder: index
            }))
        };

        try {
            setRunning(true);
            const res = await fetch('/api/reports', {
                method: editingReportId ? 'PUT' : 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                await fetchReports();
                setView('list');
            } else {
                const err = await res.json();
                alert(`Error al guardar: ${err.message || 'Error desconocido'}`);
            }
        } catch (error) {
            console.error(error);
        } finally {
            setRunning(false);
        }
    }

    const runReport = async (reportId: number) => {
        try {
            setLoading(true)
            const res = await fetch(`/api/reports/${reportId}`)
            if (res.ok) {
                const data = await res.json()
                setActiveReport(data)
                
                if (data.filters && data.filters.length > 0) {
                    setRuntimeFilterValues({})
                    setIsRuntimeFilterModalOpen(true)
                } else {
                    executeReport(reportId, {})
                }
            }
        } catch (error) {
            console.error(error)
        } finally {
            setLoading(false)
        }
    }

    const executeReport = async (reportId: number, filters: any) => {
        try {
            setRunning(true)
            const res = await fetch(`/api/reports/${reportId}/execute`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ filters })
            })
            if (res.ok) {
                const data = await res.json()
                setReportResult(data || [])
                setIsRuntimeFilterModalOpen(false)
                setView('viewer')
            } else {
                const err = await res.json()
                alert(`Error: ${err.message || 'Error al ejecutar el reporte'}`)
            }
        } catch (error) {
            console.error(error)
        } finally {
            setRunning(false)
        }
    }

    const exportToExcel = () => {
        if (!reportResult || reportResult.length === 0) return;
        const ws = XLSX.utils.json_to_sheet(reportResult);
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Reporte");
        XLSX.writeFile(wb, `${activeReport?.name || 'Reporte'}.xlsx`);
    }

    const copyToClipboardExcel = () => {
        if (!reportResult || reportResult.length === 0) return;
        const headers = Object.keys(reportResult[0]);
        const rows = reportResult.map(row => 
            headers.map(h => {
                const val = row[h];
                if (val === null || val === undefined) return '';
                return String(val).replace(/\t/g, ' ').replace(/\n/g, ' ');
            }).join('\t')
        );
        const tsvContent = [headers.join('\t'), ...rows].join('\n');
        navigator.clipboard.writeText(tsvContent);
        setCopiedToClipboard(true);
        setTimeout(() => setCopiedToClipboard(false), 3500);
    }
    
    const handleDelete = async (id: number) => {
        if (!confirm('¿Eliminar este reporte permanentemente?')) return;
        await fetch(`/api/reports?id=${id}`, { method: 'DELETE' });
        fetchReports();
    }

    const currentModule = baseTable ? modules[baseTable] : null;

    // Helper for rendering available fields inside the checklist modal
    const getCategorizedFields = () => {
        const cabeceraTables = ['Quotation', 'Client', 'Seller', 'TicketPrinter', 'Branch', 'Implant', 'User'];
        const productoTables = ['QuotationProduct', 'Product', 'Provider', 'Prestadora', 'QuotationManualService'];

        const result: { category: 'Cabecera' | 'Productos'; tableKey: string; tableAlias: string; tableName: string; col: any }[] = [];

        Object.keys(modules).forEach(tKey => {
            const mod = modules[tKey];
            if (!mod || !mod.columns) return;

            let cat: 'Cabecera' | 'Productos' = cabeceraTables.includes(tKey) ? 'Cabecera' : 'Productos';
            let alias = 't1';

            if (tKey === 'Quotation') alias = 't1';
            else if (tKey === 'QuotationProduct') alias = 't_quotationproduct';
            else alias = `t_${tKey.toLowerCase()}`;

            mod.columns.forEach((col: any) => {
                const searchLower = fieldSearchTerm.toLowerCase();
                const matchesSearch = !searchLower || col.name.toLowerCase().includes(searchLower);

                if (matchesSearch) {
                    if (activeFieldCategory === 'all' || (activeFieldCategory === 'cabecera' && cat === 'Cabecera') || (activeFieldCategory === 'productos' && cat === 'Productos')) {
                        result.push({
                            category: cat,
                            tableKey: tKey,
                            tableAlias: alias,
                            tableName: mod.name,
                            col
                        });
                    }
                }
            });
        });

        return result;
    }

    return (
        <div className="p-4 md:p-8 max-w-[100rem] mx-auto space-y-8">
            {/* Encabezado */}
            <header className="flex flex-col md:flex-row md:items-center justify-between gap-6 bg-white dark:bg-zinc-900 p-8 rounded-[2.5rem] shadow-sm border border-zinc-200 dark:border-zinc-800">
                <div>
                    <div className="flex items-center gap-3 mb-2">
                        <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 text-blue-600 rounded-xl flex items-center justify-center">
                            <PieChart className="w-5 h-5" />
                        </div>
                        <h1 className="text-3xl font-black tracking-tight text-zinc-900 dark:text-white">Centro y Diseñador de Reportes</h1>
                    </div>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium">Crea, personaliza y exporta tus informes de cotizaciones y productos a tu medida</p>
                </div>
                
                {view === 'list' && (
                    <div className="flex flex-wrap gap-4">
                        <button
                            onClick={() => {
                                setBatchIdIni('');
                                setBatchIdFin('');
                                setIsBatchReportModalOpen(true);
                            }}
                            className="px-6 h-14 bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 rounded-2xl flex items-center gap-2.5 font-bold transition-all border border-zinc-200 dark:border-zinc-700"
                        >
                            <FileText className="w-5 h-5 text-blue-600" />
                            Reporte Dinámico (Lote)
                        </button>
                        <button
                            onClick={initDefaultQuotationReport}
                            className="px-6 h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl flex items-center gap-3 shadow-xl shadow-blue-500/20 font-bold transition-all"
                        >
                            <Plus className="w-5 h-5" />
                            Diseñar Nuevo Reporte
                        </button>
                    </div>
                )}
                {view !== 'list' && (
                    <button onClick={() => setView('list')} className="px-6 h-12 bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 rounded-xl font-bold transition-all">
                        Volver a la Lista
                    </button>
                )}
            </header>

            {/* Vista Lista de Reportes */}
            {view === 'list' && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {loading ? (
                        <div className="col-span-full py-20 flex justify-center"><Loader2 className="w-10 h-10 animate-spin text-blue-600" /></div>
                    ) : reports.length === 0 ? (
                        <div className="col-span-full py-20 text-center text-zinc-500 bg-white dark:bg-zinc-900 rounded-[2rem] border border-dashed border-zinc-300 dark:border-zinc-800 space-y-4">
                            <TableIcon className="w-12 h-12 mx-auto text-zinc-300" />
                            <p className="font-bold text-lg text-zinc-700 dark:text-zinc-300">Aún no tienes reportes personalizados guardados</p>
                            <button onClick={initDefaultQuotationReport} className="px-6 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold transition-all">
                                Crear Primer Reporte
                            </button>
                        </div>
                    ) : (
                        reports.map(rep => (
                            <div key={rep.id} className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[2rem] p-6 shadow-sm hover:shadow-xl transition-all group relative overflow-hidden flex flex-col justify-between">
                                <div>
                                    <div className="flex items-center justify-between mb-4">
                                        <div className="w-12 h-12 bg-blue-50 dark:bg-blue-900/30 text-blue-600 rounded-2xl flex items-center justify-center">
                                            <TableIcon className="w-6 h-6" />
                                        </div>
                                        <div className="flex items-center gap-1">
                                            <button onClick={() => runReport(rep.id)} className="w-10 h-10 bg-blue-600 text-white rounded-xl flex items-center justify-center hover:bg-blue-700 transition-colors shadow-md shadow-blue-500/20" title="Ejecutar Reporte">
                                                <Play className="w-4 h-4 ml-0.5" />
                                            </button>
                                            <button onClick={() => handleEdit(rep.id)} className="w-10 h-10 bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-300 rounded-xl flex items-center justify-center hover:bg-zinc-200 dark:hover:bg-zinc-700 transition-colors" title="Editar Reporte">
                                                <Edit className="w-4 h-4" />
                                            </button>
                                            <button onClick={() => handleDelete(rep.id)} className="w-10 h-10 bg-red-50 text-red-600 dark:bg-red-900/20 dark:text-red-400 rounded-xl flex items-center justify-center hover:bg-red-600 hover:text-white transition-colors" title="Eliminar Reporte">
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white mb-2">{rep.name}</h3>
                                </div>
                                <div className="mt-4 pt-4 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                                    <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-400">
                                        Fuente: {modules[rep.base_table]?.name || rep.base_table || 'Cotizaciones'}
                                    </span>
                                    <button onClick={() => runReport(rep.id)} className="text-xs font-bold text-blue-600 hover:text-blue-700 flex items-center gap-1">
                                        Generar <Play className="w-3 h-3" />
                                    </button>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            )}

            {/* Diseñador / Builder Panel */}
            {view === 'builder' && (
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Panel Izquierdo: Configuración General del Reporte */}
                    <div className="lg:col-span-1 space-y-6">
                        <div className="bg-white dark:bg-zinc-900 rounded-[2rem] p-6 shadow-sm border border-zinc-200 dark:border-zinc-800 space-y-6">
                            <div>
                                <h3 className="text-lg font-black mb-1">1. Origen de Datos</h3>
                                <p className="text-xs text-zinc-400 font-medium">Selecciona la tabla principal para tu reporte</p>
                            </div>

                            <div className="flex gap-2">
                                <button 
                                    onClick={() => setIsCustomSql(false)}
                                    className={cn("flex-1 h-12 rounded-xl font-bold text-xs transition-all border", !isCustomSql ? "bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-500/20" : "bg-zinc-50 text-zinc-500 border-zinc-200 hover:border-zinc-300")}
                                >
                                    Asistente Visual
                                </button>
                                <button 
                                    onClick={() => setIsCustomSql(true)}
                                    className={cn("flex-1 h-12 rounded-xl font-bold text-xs transition-all border", isCustomSql ? "bg-purple-600 text-white border-purple-600 shadow-md shadow-purple-500/20" : "bg-zinc-50 text-zinc-500 border-zinc-200 hover:border-zinc-300")}
                                >
                                    Script SQL
                                </button>
                            </div>

                            {!isCustomSql ? (
                                <div className="space-y-2">
                                    <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Tabla Base</label>
                                    <select
                                        value={baseTable}
                                        onChange={(e) => setBaseTable(e.target.value)}
                                        className="w-full h-12 bg-zinc-50 dark:bg-zinc-800 rounded-xl px-4 font-bold text-sm border border-zinc-200 dark:border-zinc-700 outline-none text-zinc-900 dark:text-white focus:ring-2 focus:ring-blue-500"
                                    >
                                        <option value="Quotation">Cotizaciones (Cabecera Principal)</option>
                                        <option value="QuotationProduct">Productos de Cotización</option>
                                        {Object.keys(modules).filter(k => k !== 'Quotation' && k !== 'QuotationProduct').map(k => (
                                            <option key={k} value={k}>{modules[k].name || k}</option>
                                        ))}
                                    </select>
                                </div>
                            ) : (
                                <div className="space-y-4">
                                    <textarea 
                                        rows={10}
                                        value={customSql}
                                        onChange={(e) => setCustomSql(e.target.value)}
                                        placeholder="SELECT q.*, c.name FROM public.Quotation q JOIN public.Client c ON q.clientId = c.id"
                                        className="w-full bg-zinc-50 dark:bg-zinc-800 rounded-2xl p-4 font-mono text-xs border border-zinc-200 dark:border-zinc-700 shadow-inner focus:ring-2 focus:ring-purple-500 outline-none"
                                    />
                                    
                                    <div className="flex items-center justify-between">
                                        <h4 className="text-xs font-black text-purple-600 uppercase tracking-widest">Filtros para el Script</h4>
                                        <button 
                                            onClick={() => setIsManualFilterModalOpen(true)}
                                            className="flex items-center gap-1.5 text-[10px] font-black bg-purple-50 text-purple-600 px-3 py-1.5 rounded-xl hover:bg-purple-100 transition-colors"
                                        >
                                            <Plus className="w-3 h-3" /> Agregar Filtro
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>

                        {/* Guardar Plantilla */}
                        <div className="bg-white dark:bg-zinc-900 rounded-[2rem] p-6 shadow-sm border border-zinc-200 dark:border-zinc-800 space-y-4">
                            <div>
                                <h3 className="text-lg font-black">2. Guardar Plantilla</h3>
                                <p className="text-xs text-zinc-400 font-medium">Guarda tu diseño para ejecutarlo cuantas veces quieras</p>
                            </div>

                            <div className="space-y-2">
                                <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Nombre del Reporte</label>
                                <input 
                                    type="text" 
                                    placeholder="Ej. Reporte General de Cotizaciones" 
                                    value={templateName} 
                                    onChange={e => setTemplateName(e.target.value)} 
                                    className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border border-zinc-200 dark:border-zinc-700 text-sm font-bold focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white" 
                                    required 
                                />
                            </div>

                            <button onClick={saveTemplate} disabled={running} className="w-full h-14 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl font-bold flex items-center justify-center gap-2 shadow-lg shadow-emerald-500/20 transition-all">
                                {running ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
                                Guardar Reporte por Defecto
                            </button>
                        </div>
                    </div>

                    {/* Panel Derecho: Selección y Personalización de Columnas */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="bg-white dark:bg-zinc-900 rounded-[2.5rem] shadow-sm border border-zinc-200 dark:border-zinc-800 overflow-hidden">
                            <div className="p-6 md:p-8 border-b border-zinc-100 dark:border-zinc-800 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-zinc-50/50 dark:bg-zinc-800/20">
                                <div>
                                    <h2 className="text-xl font-black">3. Selección y Personalización de Columnas</h2>
                                    <p className="text-zinc-500 text-sm font-medium mt-1">Escoge los campos de cabecera y productos, modifica sus nombres y ajusta el orden de izquierda a derecha.</p>
                                </div>
                                <div className="flex flex-wrap gap-2">
                                    <button 
                                        onClick={() => setIsFieldSelectorModalOpen(true)}
                                        className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-lg shadow-blue-500/20 transition-all"
                                    >
                                        <Plus className="w-4 h-4" />
                                        Seleccionar Campos (Chequeo)
                                    </button>
                                    <button onClick={() => setIsFormulaModalOpen(true)} className="px-4 h-12 bg-purple-50 hover:bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300 rounded-xl text-xs font-bold flex items-center gap-2 transition-colors">
                                        <Calculator className="w-4 h-4" />
                                        Fórmula Matemática
                                    </button>
                                </div>
                            </div>

                            <div className="p-6 md:p-8 space-y-6">
                                {/* Tabla de Columnas Seleccionadas (Con edición de nombre y orden) */}
                                {selectedColumns.length === 0 ? (
                                    <div className="py-12 text-center border-2 border-dashed border-zinc-200 dark:border-zinc-800 rounded-2xl p-6 space-y-3">
                                        <Layers className="w-10 h-10 mx-auto text-zinc-300" />
                                        <p className="text-zinc-500 font-bold text-sm">No has agregado ninguna columna al reporte</p>
                                        <button onClick={() => setIsFieldSelectorModalOpen(true)} className="px-4 h-10 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-xl text-xs font-bold transition-colors">
                                            Abrir Selector de Campos
                                        </button>
                                    </div>
                                ) : (
                                    <div className="space-y-4">
                                        <div className="flex items-center justify-between">
                                            <span className="text-xs font-black uppercase tracking-widest text-zinc-400">
                                                Columnas del Reporte ({selectedColumns.length})
                                            </span>
                                            <span className="text-[10px] text-zinc-400 font-medium italic">
                                                Usa los botones de flecha o el número para cambiar la posición
                                            </span>
                                        </div>

                                        <div className="overflow-x-auto border border-zinc-200 dark:border-zinc-800 rounded-2xl">
                                            <table className="w-full text-left text-xs border-collapse">
                                                <thead>
                                                    <tr className="bg-zinc-100 dark:bg-zinc-800 text-zinc-500 font-bold uppercase tracking-wider border-b border-zinc-200 dark:border-zinc-700">
                                                        <th className="py-3 px-3 w-16 text-center">Orden</th>
                                                        <th className="py-3 px-3">Campo / Origen DB</th>
                                                        <th className="py-3 px-3">Nombre Columna (Alias)</th>
                                                        <th className="py-3 px-3 w-32 text-center">Filtro / Opciones</th>
                                                        <th className="py-3 px-3 w-28 text-center">Acciones</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                                                    {selectedColumns.map((col, idx) => {
                                                        const isFilter = reportFilters.some(f => f.tableAlias === col.tableAlias && f.columnName === col.columnName);
                                                        return (
                                                            <tr key={col.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/40 transition-colors">
                                                                <td className="py-2 px-3 text-center">
                                                                    <div className="flex items-center justify-center gap-1">
                                                                        <input 
                                                                            type="number" 
                                                                            value={idx + 1} 
                                                                            onChange={(e) => changeColumnOrder(idx, parseInt(e.target.value))}
                                                                            className="w-10 h-8 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg text-center font-bold text-xs outline-none focus:ring-1 focus:ring-blue-500"
                                                                            min="1"
                                                                            max={selectedColumns.length}
                                                                        />
                                                                    </div>
                                                                </td>
                                                                <td className="py-2 px-3">
                                                                    <div className="flex flex-col">
                                                                        <span className="font-bold text-zinc-900 dark:text-zinc-100">{col.alias || col.columnName}</span>
                                                                        <span className="font-mono text-[10px] text-zinc-400">{col.tableAlias}.{col.columnName}</span>
                                                                    </div>
                                                                </td>
                                                                <td className="py-2 px-3">
                                                                    <input 
                                                                        type="text"
                                                                        value={col.alias || ''}
                                                                        onChange={(e) => {
                                                                            const newCols = [...selectedColumns];
                                                                            newCols[idx].alias = e.target.value;
                                                                            setSelectedColumns(newCols);
                                                                        }}
                                                                        placeholder="Nombre personalizado"
                                                                        className="w-full h-8 px-3 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-bold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                    />
                                                                </td>
                                                                <td className="py-2 px-3 text-center">
                                                                    <button 
                                                                        onClick={() => {
                                                                            if (isFilter) {
                                                                                setReportFilters(reportFilters.filter(f => !(f.tableAlias === col.tableAlias && f.columnName === col.columnName)));
                                                                            } else {
                                                                                const type = col.type?.toLowerCase() || '';
                                                                                const isNum = type.includes('int') || type.includes('numeric') || type.includes('decimal') || type.includes('float') || type === 'number';
                                                                                const isDate = type.includes('date') || type.includes('time') || type.includes('timestamp');
                                                                                
                                                                                setReportFilters([...reportFilters, {
                                                                                    tableAlias: col.tableAlias || 't1',
                                                                                    columnName: col.columnName,
                                                                                    filterLabel: col.alias,
                                                                                    filterType: isNum ? 'number' : isDate ? 'date' : 'text',
                                                                                    operator: (isNum || isDate) ? '=' : 'LIKE'
                                                                                }]);
                                                                            }
                                                                        }}
                                                                        className={cn("px-2 py-1 rounded-lg text-[10px] font-bold inline-flex items-center gap-1 transition-all", isFilter ? "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300" : "bg-zinc-100 text-zinc-500 dark:bg-zinc-800")}
                                                                        title="Activar como filtro de búsqueda en ejecución"
                                                                    >
                                                                        <Filter className="w-3 h-3" />
                                                                        {isFilter ? 'Es Filtro' : '+ Filtro'}
                                                                    </button>
                                                                </td>
                                                                <td className="py-2 px-3 text-center">
                                                                    <div className="flex items-center justify-center gap-1">
                                                                        <button
                                                                            type="button"
                                                                            disabled={idx === 0}
                                                                            onClick={() => moveColumnPosition(idx, idx - 1)}
                                                                            className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                            title="Subir Posición"
                                                                        >
                                                                            <ArrowUp className="w-3.5 h-3.5" />
                                                                        </button>
                                                                        <button
                                                                            type="button"
                                                                            disabled={idx === selectedColumns.length - 1}
                                                                            onClick={() => moveColumnPosition(idx, idx + 1)}
                                                                            className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                            title="Bajar Posición"
                                                                        >
                                                                            <ArrowDown className="w-3.5 h-3.5" />
                                                                        </button>
                                                                        {col.isCalculated && (
                                                                            <button 
                                                                                onClick={() => editFormula(idx)}
                                                                                className="p-1 text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
                                                                                title="Editar Fórmula"
                                                                            >
                                                                                <Edit className="w-3.5 h-3.5" />
                                                                            </button>
                                                                        )}
                                                                        <button 
                                                                            onClick={() => removeColumn(idx)}
                                                                            className="p-1 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                                                                            title="Quitar Columna"
                                                                        >
                                                                            <Trash2 className="w-3.5 h-3.5" />
                                                                        </button>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        )
                                                    })}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                )}

                                {/* Configuración de Filtros de Ejecución */}
                                <div className="space-y-4 pt-6 border-t border-zinc-100 dark:border-zinc-800">
                                    <div className="flex items-center justify-between">
                                        <div>
                                            <h3 className="text-base font-black">Filtros de Ejecución Disponibles</h3>
                                            <p className="text-xs text-zinc-400">Estos campos solicitarán valores al usuario al presionar "Ejecutar Reporte"</p>
                                        </div>
                                        <button 
                                            onClick={() => setIsManualFilterModalOpen(true)}
                                            className="px-3 py-1.5 bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-xl text-xs font-bold flex items-center gap-1 transition-colors"
                                        >
                                            <Plus className="w-3.5 h-3.5" /> Nuevo Filtro Manual
                                        </button>
                                    </div>

                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                                        {reportFilters.length === 0 ? (
                                            <div className="col-span-full text-center py-6 bg-zinc-50 dark:bg-zinc-800/30 rounded-xl text-zinc-400 text-xs font-bold border border-dashed border-zinc-200 dark:border-zinc-700">
                                                No se han configurado filtros. Se mostrarán todos los registros al ejecutar.
                                            </div>
                                        ) : (
                                            reportFilters.map((filter, idx) => (
                                                <div key={idx} className="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl border border-zinc-200 dark:border-zinc-700 flex items-center justify-between gap-3">
                                                    <div className="flex-1">
                                                        <input 
                                                            type="text" 
                                                            placeholder="Etiqueta del Filtro"
                                                            className="w-full bg-white dark:bg-zinc-900 rounded-lg px-2 py-1 text-xs font-bold border border-zinc-200 dark:border-zinc-700 outline-none"
                                                            value={filter.filterLabel}
                                                            onChange={(e) => {
                                                                const newFilters = [...reportFilters];
                                                                newFilters[idx].filterLabel = e.target.value;
                                                                setReportFilters(newFilters);
                                                            }}
                                                        />
                                                        <div className="flex items-center gap-2 mt-1 text-[10px] text-zinc-400">
                                                            <span className="font-mono">{filter.tableAlias}.{filter.columnName}</span>
                                                            <span>•</span>
                                                            <span className="uppercase font-bold">{filter.filterType}</span>
                                                        </div>
                                                    </div>
                                                    <button onClick={() => setReportFilters(reportFilters.filter((_, i) => i !== idx))} className="text-red-500 hover:bg-red-50 p-1.5 rounded-lg transition-colors"><X className="w-4 h-4" /></button>
                                                </div>
                                            ))
                                        )}
                                    </div>
                                </div>

                                {/* Criterios de Ordenamiento */}
                                <div className="space-y-4 pt-6 border-t border-zinc-100 dark:border-zinc-800">
                                    <div className="flex items-center justify-between">
                                        <h3 className="text-base font-black">Ordenamiento de los Datos</h3>
                                        <button 
                                            onClick={() => setSorts([...sorts, { columnExpr: selectedColumns[0]?.id || 't1."id"', direction: 'DESC' }])}
                                            className="text-xs font-bold text-blue-600 hover:text-blue-700 flex items-center gap-1"
                                        >
                                            <Plus className="w-3.5 h-3.5" /> Agregar Criterio
                                        </button>
                                    </div>

                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                                        {sorts.map((sort, idx) => (
                                            <div key={idx} className="flex items-center gap-2 p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl border border-zinc-200 dark:border-zinc-700">
                                                <select 
                                                    className="flex-1 h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-700 outline-none font-bold text-xs"
                                                    value={sort.columnExpr}
                                                    onChange={(e) => {
                                                        const newSorts = [...sorts];
                                                        newSorts[idx].columnExpr = e.target.value;
                                                        setSorts(newSorts);
                                                    }}
                                                >
                                                    <option value="">Seleccionar Campo</option>
                                                    {selectedColumns.filter(c => !c.isCalculated).map(c => (
                                                        <option key={c.id} value={`${c.tableAlias}."${c.columnName}"`}>{c.alias || c.columnName}</option>
                                                    ))}
                                                </select>
                                                <select 
                                                    className="w-24 h-9 bg-white dark:bg-zinc-900 rounded-lg px-2 border border-zinc-200 dark:border-zinc-700 outline-none font-bold text-xs"
                                                    value={sort.direction}
                                                    onChange={(e) => {
                                                        const newSorts = [...sorts];
                                                        newSorts[idx].direction = e.target.value;
                                                        setSorts(newSorts);
                                                    }}
                                                >
                                                    <option value="ASC">ASC (A-Z)</option>
                                                    <option value="DESC">DESC (Z-A)</option>
                                                </select>
                                                <button 
                                                    onClick={() => setSorts(sorts.filter((_, i) => i !== idx))}
                                                    className="text-red-500 hover:bg-red-50 p-1 rounded-lg"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Viewer Panel - Visualización de Resultados */}
            {view === 'viewer' && (
                <div className="bg-white dark:bg-zinc-900 rounded-[2.5rem] shadow-sm border border-zinc-200 dark:border-zinc-800 overflow-hidden flex flex-col h-[75vh]">
                    <div className="p-6 border-b border-zinc-100 dark:border-zinc-800 flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <h2 className="text-xl font-black">{activeReport?.name}</h2>
                            <p className="text-zinc-500 text-xs font-medium">{reportResult.length} registros generados</p>
                        </div>
                        <div className="flex items-center gap-3">
                            <button 
                                onClick={() => setIsScreenReportModalOpen(true)}
                                className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-2 transition-all shadow-md shadow-blue-500/20 text-xs"
                            >
                                <Printer className="w-4 h-4" /> 
                                Ver Reporte en Pantalla
                            </button>
                            <button 
                                onClick={copyToClipboardExcel} 
                                className="px-5 h-12 bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300 hover:bg-blue-100 rounded-xl font-bold flex items-center gap-2 transition-all border border-blue-200 dark:border-blue-800 text-xs"
                            >
                                <Copy className="w-4 h-4" /> 
                                {copiedToClipboard ? '¡Copiado a Excel!' : 'Copiar a Excel'}
                            </button>
                            <button onClick={exportToExcel} className="px-6 h-12 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-2 transition-all shadow-md shadow-emerald-500/20 text-xs">
                                <Download className="w-4 h-4" /> Descargar Excel (.xlsx)
                            </button>
                        </div>
                    </div>
                    
                    <div className="flex-1 overflow-auto bg-zinc-50 dark:bg-zinc-950 p-6 custom-scrollbar">
                        {reportResult.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-zinc-400 font-bold space-y-2">
                                <TableIcon className="w-12 h-12 text-zinc-300" />
                                <p>No se encontraron registros con los filtros aplicados</p>
                            </div>
                        ) : (
                            <div className="overflow-x-auto border border-zinc-200 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-900 shadow-sm">
                                <table className="w-full border-collapse">
                                    <thead className="bg-zinc-100 dark:bg-zinc-800 sticky top-0 z-10">
                                        <tr className="border-b border-zinc-200 dark:border-zinc-700">
                                            {Object.keys(reportResult[0]).map(key => (
                                                <th key={key} className="px-6 py-4 text-xs font-black uppercase tracking-widest text-zinc-600 dark:text-zinc-300 text-left whitespace-nowrap">
                                                    {key}
                                                </th>
                                            ))}
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                                        {reportResult.map((row, idx) => (
                                            <tr key={idx} className="hover:bg-blue-50/50 dark:hover:bg-zinc-800/40 transition-colors">
                                                {Object.values(row).map((val: any, j) => (
                                                    <td key={j} className="px-6 py-4 text-sm font-medium text-zinc-700 dark:text-zinc-300 whitespace-nowrap">
                                                        {val === null ? '-' : String(val)}
                                                    </td>
                                                ))}
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* Field Selector Modal (Selección de Campos estilo chequeo similar a Sucursales) */}
            <AnimatePresence>
                {isFieldSelectorModalOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                        <motion.div 
                            initial={{ scale: 0.95, opacity: 0 }} 
                            animate={{ scale: 1, opacity: 1 }} 
                            exit={{ scale: 0.95, opacity: 0 }} 
                            className="bg-white dark:bg-zinc-900 rounded-[2.5rem] max-w-4xl w-full h-[85vh] flex flex-col overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            {/* Modal Header */}
                            <div className="p-6 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between bg-zinc-50/50 dark:bg-zinc-800/30">
                                <div>
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white flex items-center gap-2">
                                        <SlidersHorizontal className="w-5 h-5 text-blue-600" />
                                        Seleccionar Campos para el Reporte
                                    </h3>
                                    <p className="text-xs text-zinc-400 font-medium mt-0.5">Marca los campos de Cabecera y Productos que deseas incluir</p>
                                </div>
                                <button onClick={() => setIsFieldSelectorModalOpen(false)} className="w-10 h-10 flex items-center justify-center text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors">
                                    <X className="w-6 h-6" />
                                </button>
                            </div>

                            {/* Search and Category Filter Bar */}
                            <div className="p-4 border-b border-zinc-100 dark:border-zinc-800 flex flex-col md:flex-row gap-3">
                                <div className="relative flex-1">
                                    <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-400" />
                                    <input 
                                        type="text" 
                                        placeholder="Buscar por nombre de campo (ej. Cliente, Total, Fecha, Vendedor)..." 
                                        value={fieldSearchTerm} 
                                        onChange={(e) => setFieldSearchTerm(e.target.value)} 
                                        className="w-full h-11 pl-10 pr-4 bg-zinc-50 dark:bg-zinc-800 rounded-xl font-bold text-xs border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500"
                                    />
                                </div>
                                <div className="flex gap-1.5">
                                    <button 
                                        onClick={() => setActiveFieldCategory('all')} 
                                        className={cn("px-4 h-11 rounded-xl text-xs font-bold transition-all", activeFieldCategory === 'all' ? "bg-blue-600 text-white" : "bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400")}
                                    >
                                        Todos
                                    </button>
                                    <button 
                                        onClick={() => setActiveFieldCategory('cabecera')} 
                                        className={cn("px-4 h-11 rounded-xl text-xs font-bold transition-all", activeFieldCategory === 'cabecera' ? "bg-blue-600 text-white" : "bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400")}
                                    >
                                        Cabecera
                                    </button>
                                    <button 
                                        onClick={() => setActiveFieldCategory('productos')} 
                                        className={cn("px-4 h-11 rounded-xl text-xs font-bold transition-all", activeFieldCategory === 'productos' ? "bg-blue-600 text-white" : "bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400")}
                                    >
                                        Productos
                                    </button>
                                </div>
                            </div>

                            {/* Checklist Field Grid */}
                            <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
                                {(() => {
                                    const fields = getCategorizedFields();
                                    if (fields.length === 0) {
                                        return (
                                            <div className="py-20 text-center text-zinc-400 font-bold">
                                                No se encontraron campos con el término de búsqueda.
                                            </div>
                                        );
                                    }

                                    const cabeceraFields = fields.filter(f => f.category === 'Cabecera');
                                    const productoFields = fields.filter(f => f.category === 'Productos');

                                    return (
                                        <>
                                            {cabeceraFields.length > 0 && (
                                                <div className="space-y-3">
                                                    <div className="flex items-center justify-between pb-2 border-b border-zinc-100 dark:border-zinc-800">
                                                        <h4 className="text-xs font-black uppercase tracking-widest text-blue-600 dark:text-blue-400 flex items-center gap-1.5">
                                                            <Building2 className="w-4 h-4" />
                                                            Campos Generales (Cabecera de Cotización)
                                                        </h4>
                                                        <span className="text-[10px] font-bold text-zinc-400 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded-md">
                                                            {cabeceraFields.length} campos
                                                        </span>
                                                    </div>
                                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
                                                        {cabeceraFields.map((item, idx) => {
                                                            const colId = `${item.tableAlias}.${item.col.id}`;
                                                            const isChecked = selectedColumns.some(c => c.id === colId);
                                                            return (
                                                                <button
                                                                    key={`${colId}_${idx}`}
                                                                    onClick={() => toggleColumn(item.tableKey, item.tableAlias, item.col, item.tableAlias !== 't1' ? item.tableName : '')}
                                                                    className={cn(
                                                                        "p-3 rounded-xl border flex items-center justify-between text-left transition-all",
                                                                        isChecked 
                                                                            ? "bg-blue-50 border-blue-300 text-blue-900 dark:bg-blue-950/40 dark:border-blue-800 dark:text-blue-200 font-bold shadow-sm" 
                                                                            : "bg-white border-zinc-200 text-zinc-700 hover:bg-zinc-50 dark:bg-zinc-900 dark:border-zinc-800 dark:text-zinc-300"
                                                                    )}
                                                                >
                                                                    <div className="flex items-center gap-3">
                                                                        {isChecked ? (
                                                                            <CheckSquare className="w-5 h-5 text-blue-600 dark:text-blue-400 shrink-0" />
                                                                        ) : (
                                                                            <Square className="w-5 h-5 text-zinc-300 dark:text-zinc-700 shrink-0" />
                                                                        )}
                                                                        <div className="flex flex-col">
                                                                            <span className="text-xs font-bold">{item.col.name}</span>
                                                                        </div>
                                                                    </div>
                                                                </button>
                                                            );
                                                        })}
                                                    </div>
                                                </div>
                                            )}

                                            {productoFields.length > 0 && (
                                                <div className="space-y-3 pt-4">
                                                    <div className="flex items-center justify-between pb-2 border-b border-zinc-100 dark:border-zinc-800">
                                                        <h4 className="text-xs font-black uppercase tracking-widest text-purple-600 dark:text-purple-400 flex items-center gap-1.5">
                                                            <Layers className="w-4 h-4" />
                                                            Campos de Productos / Servicios
                                                        </h4>
                                                        <span className="text-[10px] font-bold text-zinc-400 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded-md">
                                                            {productoFields.length} campos
                                                        </span>
                                                    </div>
                                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
                                                        {productoFields.map((item, idx) => {
                                                            const colId = `${item.tableAlias}.${item.col.id}`;
                                                            const isChecked = selectedColumns.some(c => c.id === colId);
                                                            return (
                                                                <button
                                                                    key={`${colId}_${idx}`}
                                                                    onClick={() => toggleColumn(item.tableKey, item.tableAlias, item.col, item.tableName)}
                                                                    className={cn(
                                                                        "p-3 rounded-xl border flex items-center justify-between text-left transition-all",
                                                                        isChecked 
                                                                            ? "bg-purple-50 border-purple-300 text-purple-900 dark:bg-purple-950/40 dark:border-purple-800 dark:text-purple-200 font-bold shadow-sm" 
                                                                            : "bg-white border-zinc-200 text-zinc-700 hover:bg-zinc-50 dark:bg-zinc-900 dark:border-zinc-800 dark:text-zinc-300"
                                                                    )}
                                                                >
                                                                    <div className="flex items-center gap-3">
                                                                        {isChecked ? (
                                                                            <CheckSquare className="w-5 h-5 text-purple-600 dark:text-purple-400 shrink-0" />
                                                                        ) : (
                                                                            <Square className="w-5 h-5 text-zinc-300 dark:text-zinc-700 shrink-0" />
                                                                        )}
                                                                        <div className="flex flex-col">
                                                                            <span className="text-xs font-bold">{item.col.name}</span>
                                                                        </div>
                                                                    </div>
                                                                </button>
                                                            );
                                                        })}
                                                    </div>
                                                </div>
                                            )}
                                        </>
                                    );
                                })()}
                            </div>

                            {/* Modal Footer */}
                            <div className="p-6 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between bg-zinc-50/50 dark:bg-zinc-800/30">
                                <span className="text-xs font-bold text-zinc-500">
                                    {selectedColumns.length} columnas seleccionadas
                                </span>
                                <button 
                                    onClick={() => setIsFieldSelectorModalOpen(false)}
                                    className="px-8 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition-all shadow-lg shadow-blue-500/20"
                                >
                                    Confirmar Selección
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Formula Modal */}
            <AnimatePresence>
                {isFormulaModalOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                        <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }} className="bg-white dark:bg-zinc-900 rounded-[2rem] p-8 max-w-lg w-full shadow-2xl border border-zinc-200 dark:border-zinc-800">
                            <div className="flex justify-between items-center mb-6">
                                <h3 className="text-xl font-black">Campo Calculado / Expresión SQL</h3>
                                <button onClick={() => setIsFormulaModalOpen(false)} className="text-zinc-400 hover:text-zinc-600"><X className="w-6 h-6" /></button>
                            </div>
                            <form onSubmit={addFormula} className="space-y-6">
                                <div className="space-y-2">
                                    <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Nombre de la Columna (Alias)</label>
                                    <input type="text" placeholder="Ej. Utilidad Total" value={formulaAlias} onChange={e => setFormulaAlias(e.target.value)} className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border border-zinc-200 dark:border-zinc-700 text-sm font-bold focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white" required />
                                </div>

                                <div className="space-y-4">
                                    <div className="flex items-center justify-between">
                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Expresión SQL</label>
                                        <div className="flex gap-2">
                                            <button type="button" onClick={() => setFormulaExpression("(t1.\"totalAmount\" - t1.\"costoTotal\")")} className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-1 rounded">Utilidad</button>
                                            <button type="button" onClick={() => setFormulaExpression("CASE WHEN t1.state = 'Aprobado' THEN t1.\"totalAmount\" ELSE 0 END")} className="text-[10px] font-bold text-purple-600 bg-purple-50 px-2 py-1 rounded">Ejemplo Lógico</button>
                                        </div>
                                    </div>
                                    <textarea 
                                        rows={4}
                                        placeholder="Ejemplo: (t1.&quot;totalAmount&quot; * 0.10)"
                                        value={formulaExpression}
                                        onChange={e => setFormulaExpression(e.target.value)}
                                        className="w-full bg-zinc-50 dark:bg-zinc-800 rounded-2xl p-5 border border-zinc-200 dark:border-zinc-700 text-xs font-mono focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                        required
                                    />
                                </div>

                                <button type="submit" className="w-full h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-bold transition-colors shadow-xl shadow-blue-500/20">
                                    Guardar Expresión
                                </button>
                            </form>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Runtime Filter Modal */}
            <AnimatePresence>
                {isRuntimeFilterModalOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-zinc-900/60 backdrop-blur-sm">
                        <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }} className="bg-white dark:bg-zinc-900 rounded-[2.5rem] w-full max-w-lg overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800">
                            <div className="p-8 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                                <div>
                                    <h2 className="text-2xl font-black">Filtros de Ejecución</h2>
                                    <p className="text-zinc-500 text-sm font-medium">Ingresa los parámetros para consultar el reporte.</p>
                                </div>
                                <button onClick={() => setIsRuntimeFilterModalOpen(false)} className="w-12 h-12 flex items-center justify-center bg-zinc-100 dark:bg-zinc-800 rounded-2xl hover:bg-zinc-200 dark:hover:bg-zinc-700 transition-colors">
                                    <X className="w-6 h-6" />
                                </button>
                            </div>
                            
                            <div className="p-8 space-y-6">
                                {activeReport?.filters?.map((f: any) => (
                                    <div key={`${f.table_alias}.${f.column_name}`} className="space-y-2 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-[1.5rem] border border-zinc-200 dark:border-zinc-700 shadow-sm">
                                        <label className="text-xs font-black text-zinc-700 dark:text-zinc-300 uppercase tracking-widest pl-1">{f.filter_label || f.column_name}</label>
                                        
                                        {f.filter_type === 'date' ? (
                                            <div className="grid grid-cols-2 gap-4">
                                                <div className="space-y-1">
                                                    <span className="text-[10px] font-bold text-zinc-400 pl-1">Desde</span>
                                                    <input 
                                                        type="date" 
                                                        className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl px-4 font-bold text-xs border border-zinc-200 dark:border-zinc-700 focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                        onChange={(e) => setRuntimeFilterValues({ ...runtimeFilterValues, [`${f.table_alias}.${f.column_name}`]: e.target.value })}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <span className="text-[10px] font-bold text-zinc-400 pl-1">Hasta</span>
                                                    <input 
                                                        type="date" 
                                                        className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl px-4 font-bold text-xs border border-zinc-200 dark:border-zinc-700 focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                        onChange={(e) => setRuntimeFilterValues({ ...runtimeFilterValues, [`${f.table_alias}.${f.column_name}_to`]: e.target.value })}
                                                    />
                                                </div>
                                            </div>
                                        ) : f.filter_type === 'number' ? (
                                            <div className="grid grid-cols-2 gap-4">
                                                <div className="space-y-1">
                                                    <span className="text-[10px] font-bold text-zinc-400 pl-1">Inicial / Mínimo</span>
                                                    <input 
                                                        type="number" 
                                                        placeholder="Ej: 1"
                                                        className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl px-4 font-bold text-xs border border-zinc-200 dark:border-zinc-700 focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                        onChange={(e) => setRuntimeFilterValues({ ...runtimeFilterValues, [`${f.table_alias}.${f.column_name}`]: e.target.value })}
                                                    />
                                                </div>
                                                <div className="space-y-1">
                                                    <span className="text-[10px] font-bold text-zinc-400 pl-1">Final / Máximo</span>
                                                    <input 
                                                        type="number" 
                                                        placeholder="Ej: 100"
                                                        className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl px-4 font-bold text-xs border border-zinc-200 dark:border-zinc-700 focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                        onChange={(e) => setRuntimeFilterValues({ ...runtimeFilterValues, [`${f.table_alias}.${f.column_name}_to`]: e.target.value })}
                                                    />
                                                </div>
                                            </div>
                                        ) : (
                                            <div className="relative flex items-center">
                                                <button
                                                    type="button"
                                                    onClick={() => openLookupHelper(f)}
                                                    className="absolute left-2.5 z-10 p-2 hover:bg-blue-100 dark:hover:bg-blue-900/40 text-zinc-400 hover:text-blue-600 rounded-lg transition-all"
                                                    title={`Abrir ayuda de búsqueda y selección para ${f.filter_label || f.column_name}`}
                                                >
                                                    <Search className="w-4 h-4" />
                                                </button>
                                                <input 
                                                    type="text" 
                                                    className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl pl-11 pr-4 font-bold text-xs border border-zinc-200 dark:border-zinc-700 focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                    placeholder={`Filtrar por ${f.filter_label || f.column_name}...`}
                                                    value={runtimeFilterValues[`${f.table_alias}.${f.column_name}`] || ''}
                                                    onChange={(e) => setRuntimeFilterValues({ ...runtimeFilterValues, [`${f.table_alias}.${f.column_name}`]: e.target.value })}
                                                />
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </div>

                            <div className="p-8 bg-zinc-50 dark:bg-zinc-800/50 flex gap-3">
                                <button onClick={() => setIsRuntimeFilterModalOpen(false)} className="flex-1 h-14 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 rounded-2xl font-bold hover:bg-zinc-100 transition-colors">
                                    Cancelar
                                </button>
                                <button 
                                    onClick={() => executeReport(activeReport.id, runtimeFilterValues)}
                                    className="flex-[2] h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-bold shadow-xl shadow-blue-500/20 flex items-center justify-center gap-3 transition-all"
                                    disabled={running}
                                >
                                    {running ? <Loader2 className="w-5 h-5 animate-spin" /> : <Play className="w-5 h-5" />}
                                    Ejecutar Reporte
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Lookup Helper Modal (Ayuda de Búsqueda y Selección activada por la Lupa) */}
            <AnimatePresence>
                {isLookupModalOpen && (
                    <div className="fixed inset-0 z-[120] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                        <motion.div initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.95, opacity: 0 }} className="bg-white dark:bg-zinc-900 rounded-[2.5rem] w-full max-w-lg h-[75vh] flex flex-col overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800">
                            <div className="p-6 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between bg-zinc-50/50 dark:bg-zinc-800/30">
                                <div>
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white flex items-center gap-2">
                                        <Search className="w-5 h-5 text-blue-600" />
                                        Ayuda de Selección
                                    </h3>
                                    <p className="text-xs text-zinc-400 font-bold mt-0.5">
                                        {lookupFilter?.filter_label || lookupFilter?.column_name}
                                    </p>
                                </div>
                                <button onClick={() => setIsLookupModalOpen(false)} className="w-10 h-10 flex items-center justify-center text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors">
                                    <X className="w-6 h-6" />
                                </button>
                            </div>

                            <div className="p-4 border-b border-zinc-100 dark:border-zinc-800">
                                <div className="relative">
                                    <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-400" />
                                    <input
                                        type="text"
                                        placeholder="Buscar en la lista de catálogo..."
                                        value={lookupSearchTerm}
                                        onChange={(e) => setLookupSearchTerm(e.target.value)}
                                        className="w-full h-11 pl-10 pr-4 bg-zinc-50 dark:bg-zinc-800 rounded-xl font-bold text-xs border border-zinc-200 dark:border-zinc-700 outline-none focus:ring-2 focus:ring-blue-500"
                                        autoFocus
                                    />
                                </div>
                            </div>

                            <div className="flex-1 overflow-y-auto p-4 space-y-2 custom-scrollbar">
                                {loadingLookup ? (
                                    <div className="py-16 text-center font-bold text-zinc-400 animate-pulse">Cargando opciones del catálogo...</div>
                                ) : (() => {
                                    const searchLower = lookupSearchTerm.toLowerCase()
                                    const filtered = lookupData.filter((item: any) => {
                                        if (!searchLower) return true
                                        const text = `${item.name || ''} ${item.code || ''} ${item.document || ''} ${item.email || ''} ${item.location || ''}`.toLowerCase()
                                        return text.includes(searchLower)
                                    })

                                    if (filtered.length === 0) {
                                        return (
                                            <div className="py-16 text-center space-y-3">
                                                <p className="text-zinc-400 font-bold text-sm">No se encontraron opciones coincidentes.</p>
                                                <p className="text-zinc-400 text-xs">Puedes ingresar el valor directamente en la casilla del filtro.</p>
                                            </div>
                                        )
                                    }

                                    return filtered.map((item: any, idx: number) => {
                                        const mainLabel = item.name || item.code || item.document || String(item.id)
                                        const subLabel = item.document || item.code || item.email || item.location || ''
                                        const valueToUse = item.name || item.code || item.document || String(item.id)

                                        return (
                                            <button
                                                key={item.id || idx}
                                                onClick={() => selectLookupValue(valueToUse)}
                                                className="w-full p-3.5 bg-white hover:bg-blue-50/70 dark:bg-zinc-900 dark:hover:bg-blue-950/40 rounded-2xl border border-zinc-200 dark:border-zinc-800 hover:border-blue-300 dark:hover:border-blue-800 text-left transition-all flex items-center justify-between group"
                                            >
                                                <div className="flex flex-col">
                                                    <span className="text-xs font-black text-zinc-800 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
                                                        {mainLabel}
                                                    </span>
                                                    {subLabel && subLabel !== mainLabel && (
                                                        <span className="text-[10px] font-bold text-zinc-400">
                                                            {subLabel}
                                                        </span>
                                                    )}
                                                </div>
                                                <Check className="w-4 h-4 text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity" />
                                            </button>
                                        )
                                    })
                                })()}
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Modal de Filtro Manual */}
            <AnimatePresence>
                {isManualFilterModalOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.95, y: 20 }}
                            className="bg-white dark:bg-zinc-900 rounded-[2.5rem] w-full max-w-md overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            <div className="p-8 space-y-6">
                                <div className="flex items-center justify-between">
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white uppercase tracking-tighter italic">Configurar Filtro</h3>
                                    <button onClick={() => setIsManualFilterModalOpen(false)} className="text-zinc-400 hover:bg-zinc-100 p-2 rounded-xl transition-colors"><X className="w-5 h-5" /></button>
                                </div>

                                <div className="space-y-4">
                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Nombre del Campo en SQL</label>
                                        <input 
                                            type="text" 
                                            value={manualFilterField}
                                            onChange={(e) => setManualFilterField(e.target.value)}
                                            placeholder="ej: internalNumber, date, totalAmount"
                                            className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-4 font-bold text-sm focus:ring-2 focus:ring-purple-500 outline-none"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Etiqueta para el Usuario</label>
                                        <input 
                                            type="text" 
                                            value={manualFilterLabel}
                                            onChange={(e) => setManualFilterLabel(e.target.value)}
                                            placeholder="ej: Código / Número Cotización"
                                            className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-4 font-bold text-sm focus:ring-2 focus:ring-purple-500 outline-none"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Tipo de Dato</label>
                                        <select 
                                            value={manualFilterType}
                                            onChange={(e) => setManualFilterType(e.target.value)}
                                            className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-4 font-bold text-sm focus:ring-2 focus:ring-purple-500 outline-none"
                                        >
                                            <option value="text">Texto (Búsqueda parcial)</option>
                                            <option value="number">Número / ID (Rango Mín/Máx)</option>
                                            <option value="date">Fecha (Rango Desde/Hasta)</option>
                                        </select>
                                    </div>
                                </div>

                                <button 
                                    onClick={() => {
                                        if (!manualFilterField) return;
                                        const newFilter = {
                                            tableAlias: 't1',
                                            columnName: manualFilterField,
                                            filterLabel: manualFilterLabel || manualFilterField,
                                            filterType: manualFilterType,
                                            operator: (manualFilterType === 'date' || manualFilterType === 'number') ? '=' : 'LIKE'
                                        };

                                        if (manualFilterIndex !== null) {
                                            const newFilters = [...reportFilters];
                                            newFilters[manualFilterIndex] = newFilter;
                                            setReportFilters(newFilters);
                                        } else {
                                            setReportFilters([...reportFilters, newFilter]);
                                        }

                                        setIsManualFilterModalOpen(false);
                                        setManualFilterField('');
                                        setManualFilterLabel('');
                                        setManualFilterType('text');
                                        setManualFilterIndex(null);
                                    }}
                                    className="w-full bg-purple-600 hover:bg-purple-700 text-white h-14 rounded-2xl font-black uppercase tracking-widest shadow-lg shadow-purple-500/20 transition-all active:scale-[0.98]"
                                >
                                    {manualFilterIndex !== null ? 'Actualizar Filtro' : 'Agregar Filtro al Script'}
                                </button>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Modal de Reporte Dinámico por Lote */}
            <AnimatePresence>
                {isBatchReportModalOpen && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.95, y: 20 }}
                            className="bg-white dark:bg-zinc-900 rounded-[2.5rem] w-full max-w-md overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            <div className="p-8 space-y-6">
                                <div className="flex items-center justify-between">
                                    <h3 className="text-xl font-black text-zinc-900 dark:text-white uppercase tracking-tight flex items-center gap-2">
                                        <FileText className="w-5 h-5 text-blue-600" />
                                        Reporte por Lote
                                    </h3>
                                    <button 
                                        onClick={() => setIsBatchReportModalOpen(false)} 
                                        className="text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 p-2 rounded-xl transition-colors"
                                    >
                                        <X className="w-5 h-5" />
                                    </button>
                                </div>

                                <div className="space-y-4">
                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Cotización Inicial (ID)</label>
                                        <input 
                                            type="number" 
                                            value={batchIdIni}
                                            onChange={(e) => setBatchIdIni(e.target.value)}
                                            placeholder="Ej: 1"
                                            className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-4 font-bold text-sm focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <label className="text-[10px] font-black text-zinc-400 uppercase tracking-widest pl-1">Cotización Final (ID)</label>
                                        <input 
                                            type="number" 
                                            value={batchIdFin}
                                            onChange={(e) => setBatchIdFin(e.target.value)}
                                            placeholder="Ej: 10"
                                            className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-2xl p-4 font-bold text-sm focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                        />
                                    </div>
                                </div>

                                <div className="flex flex-col gap-3 pt-2">
                                    <button 
                                        onClick={() => {
                                            if (!batchIdIni || !batchIdFin) {
                                                alert("Por favor ingrese el rango completo (ID Inicial e ID Final).");
                                                return;
                                            }
                                            window.open(`/dashboard/quotations/print?idIni=${batchIdIni}&idFin=${batchIdFin}`, '_blank');
                                        }}
                                        className="w-full bg-blue-600 hover:bg-blue-700 text-white h-14 rounded-2xl font-bold flex items-center justify-center gap-2 shadow-lg shadow-blue-500/20 transition-all active:scale-[0.98]"
                                    >
                                        <Printer className="w-5 h-5" />
                                        Generar Impresión HTML / PDF
                                    </button>

                                    <button 
                                        onClick={() => {
                                            if (!batchIdIni || !batchIdFin) {
                                                alert("Por favor ingrese el rango completo (ID Inicial e ID Final).");
                                                return;
                                            }
                                            window.open(`/api/reports/cotizaciones/export-excel?idIni=${batchIdIni}&idFin=${batchIdFin}`, '_blank');
                                        }}
                                        className="w-full bg-emerald-600 hover:bg-emerald-700 text-white h-14 rounded-2xl font-bold flex items-center justify-center gap-2 shadow-lg shadow-emerald-500/20 transition-all active:scale-[0.98]"
                                    >
                                        <FileSpreadsheet className="w-5 h-5" />
                                        Descargar Reporte Excel
                                    </button>

                                    <button 
                                        onClick={() => setIsBatchReportModalOpen(false)}
                                        className="w-full bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 h-12 rounded-2xl font-bold hover:bg-zinc-200 dark:hover:bg-zinc-750 transition-colors"
                                    >
                                        Cancelar
                                    </button>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            {/* Modal de Reporte en Pantalla (Imprimible / Vista Previa Documental) */}
            <AnimatePresence>
                {isScreenReportModalOpen && (
                    <div className="fixed inset-0 z-[150] flex items-center justify-center p-4 md:p-8 bg-black/70 backdrop-blur-md overflow-y-auto">
                        <style>{`
                            @page {
                                size: landscape;
                                margin: 8mm;
                            }
                            @media print {
                                body * { visibility: hidden !important; }
                                #printable-screen-report, #printable-screen-report * { visibility: visible !important; }
                                #printable-screen-report {
                                    position: absolute !important;
                                    left: 0 !important;
                                    top: 0 !important;
                                    width: 100% !important;
                                    margin: 0 !important;
                                    padding: 10px !important;
                                    background: white !important;
                                    color: black !important;
                                    box-shadow: none !important;
                                    border: none !important;
                                    font-size: 9px !important;
                                }
                                #printable-screen-report table {
                                    width: 100% !important;
                                    table-layout: auto !important;
                                    border-collapse: collapse !important;
                                }
                                #printable-screen-report th, #printable-screen-report td {
                                    padding: 4px 6px !important;
                                    font-size: 9px !important;
                                    white-space: nowrap !important;
                                    word-break: keep-all !important;
                                }
                                #printable-screen-report tr {
                                    page-break-inside: avoid !important;
                                    break-inside: avoid !important;
                                }
                                .no-print-area { display: none !important; }
                            }
                        `}</style>
                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className="bg-white dark:bg-zinc-900 rounded-[2.5rem] w-full max-w-6xl max-h-[92vh] flex flex-col overflow-hidden shadow-2xl border border-zinc-200 dark:border-zinc-800"
                        >
                            {/* Barra superior de control del Modal */}
                            <div className="no-print-area p-6 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between bg-zinc-50/80 dark:bg-zinc-800/40">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 text-blue-600 rounded-xl flex items-center justify-center">
                                        <Printer className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <h3 className="text-xl font-black text-zinc-900 dark:text-white">Vista Previa del Reporte</h3>
                                        <p className="text-xs text-zinc-400 font-medium">{activeReport?.name || 'Reporte de Información'}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    <button 
                                        onClick={() => window.print()}
                                        className="px-5 h-11 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 transition-all shadow-md shadow-blue-500/20"
                                    >
                                        <Printer className="w-4 h-4" />
                                        Imprimir / PDF
                                    </button>
                                    <button 
                                        onClick={() => setIsScreenReportModalOpen(false)} 
                                        className="w-10 h-10 flex items-center justify-center text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors"
                                    >
                                        <X className="w-6 h-6" />
                                    </button>
                                </div>
                            </div>

                            {/* Documento Imprimible del Reporte en Pantalla */}
                            <div className="flex-1 overflow-y-auto p-8 custom-scrollbar bg-zinc-50/50 dark:bg-zinc-950">
                                <div id="printable-screen-report" className="bg-white text-zinc-900 p-8 md:p-12 rounded-[2rem] shadow-sm border border-zinc-200 space-y-8">
                                    {/* Encabezado Corporativo del Reporte */}
                                    <div className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-zinc-200 gap-4">
                                        <div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-2xl font-black tracking-tight text-blue-600">KoreX</span>
                                                <span className="text-xs font-bold bg-blue-100 text-blue-800 px-2 py-0.5 rounded-md">ERP AGENCIAS</span>
                                            </div>
                                            <h1 className="text-2xl font-black tracking-tight text-zinc-900 mt-2">{activeReport?.name || 'REPORTE OPERATIVO'}</h1>
                                            <p className="text-xs font-medium text-zinc-500 mt-0.5">Informe de datos en pantalla exportado directamente del sistema</p>
                                        </div>
                                        <div className="text-left md:text-right text-xs font-medium text-zinc-500 space-y-1 bg-zinc-50 p-4 rounded-xl border border-zinc-100">
                                            <div><strong className="text-zinc-700">Fecha de Generación:</strong> {new Date().toLocaleDateString('es-CO', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}</div>
                                            <div><strong className="text-zinc-700">Total Registros:</strong> {reportResult.length}</div>
                                            <div><strong className="text-zinc-700">Origen Tabla:</strong> {activeReport?.base_table || 'Cotizaciones'}</div>
                                        </div>
                                    </div>

                                    {/* Resumen de Filtros Aplicados */}
                                    {Object.keys(runtimeFilterValues).length > 0 && (
                                        <div className="p-4 bg-blue-50/60 rounded-xl border border-blue-100 text-xs space-y-1.5">
                                            <span className="font-bold text-blue-900 uppercase text-[10px] tracking-wider block">Filtros de Búsqueda Aplicados:</span>
                                            <div className="flex flex-wrap gap-x-4 gap-y-1 text-zinc-700">
                                                {Object.entries(runtimeFilterValues).map(([k, v]) => (
                                                    v ? <div key={k}><strong className="text-zinc-900">{k}:</strong> {String(v)}</div> : null
                                                ))}
                                            </div>
                                        </div>
                                    )}

                                    {/* Tabla de Registros en Pantalla */}
                                    {reportResult.length === 0 ? (
                                        <div className="py-16 text-center text-zinc-400 font-bold">No existen datos registrados para mostrar en este reporte.</div>
                                    ) : (
                                        <div className="overflow-x-auto">
                                            <table className="w-full text-left text-xs border-collapse border border-zinc-200">
                                                <thead>
                                                    <tr className="bg-zinc-100 text-zinc-800 font-bold uppercase tracking-wider border-b border-zinc-300">
                                                        <th className="py-2.5 px-2.5 border-r border-zinc-200 text-center w-10 whitespace-nowrap">#</th>
                                                        {Object.keys(reportResult[0]).map(key => (
                                                            <th key={key} className="py-2.5 px-3 border-r border-zinc-200 whitespace-nowrap">{key}</th>
                                                        ))}
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-zinc-200 text-zinc-800">
                                                    {reportResult.map((row, idx) => (
                                                        <tr key={idx} className={idx % 2 === 0 ? 'bg-white' : 'bg-zinc-50/70'}>
                                                            <td className="py-2 px-2.5 border-r border-zinc-200 font-bold text-center text-zinc-500 whitespace-nowrap">{idx + 1}</td>
                                                            {Object.entries(row).map(([colKey, val], j) => {
                                                                const keyLower = colKey.toLowerCase();
                                                                let formattedVal = val === null || val === undefined || val === '' ? '-' : String(val);
                                                                
                                                                if (typeof val === 'string' && val.includes('T') && (keyLower.includes('fecha') || keyLower.includes('date') || keyLower.includes('createdat'))) {
                                                                    const d = new Date(val);
                                                                    if (!isNaN(d.getTime())) {
                                                                        const year = d.getFullYear();
                                                                        const month = String(d.getMonth() + 1).padStart(2, '0');
                                                                        const day = String(d.getDate()).padStart(2, '0');
                                                                        const hours = String(d.getHours()).padStart(2, '0');
                                                                        const minutes = String(d.getMinutes()).padStart(2, '0');
                                                                        formattedVal = `${year}-${month}-${day} ${hours}:${minutes}`;
                                                                    }
                                                                }

                                                                const isNum = typeof val === 'number' || (!isNaN(Number(val)) && val !== '' && val !== null && !keyLower.includes('nit') && !keyLower.includes('documento') && !keyLower.includes('tel') && !keyLower.includes('código') && !keyLower.includes('codigo') && !keyLower.includes('numero') && !keyLower.includes('número') && !keyLower.includes('id'));
                                                                const isCurrency = isNum && (keyLower.includes('valor') || keyLower.includes('monto') || keyLower.includes('total') || keyLower.includes('precio') || keyLower.includes('tarifa') || keyLower.includes('costo') || keyLower.includes('utilidad'));
                                                                
                                                                if (isCurrency && typeof val !== 'string') {
                                                                    formattedVal = `$ ${Number(val).toLocaleString('es-CO', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
                                                                }

                                                                return (
                                                                    <td key={j} className={`py-2 px-3 border-r border-zinc-200 whitespace-nowrap ${isNum ? 'text-right font-mono' : ''}`}>
                                                                        {formattedVal}
                                                                    </td>
                                                                )
                                                            })}
                                                        </tr>
                                                    ))}
                                                </tbody>
                                                {/* Fila de Totales Sumarizados al final si existen columnas numéricas */}
                                                <tfoot>
                                                    <tr className="bg-zinc-100 font-black text-zinc-900 border-t-2 border-zinc-300">
                                                        <td className="py-2.5 px-2.5 border-r border-zinc-200 text-center whitespace-nowrap">TOTAL</td>
                                                        {Object.entries(reportResult[0]).map(([colKey, firstVal], j) => {
                                                            const isNumCol = (typeof firstVal === 'number' || !isNaN(Number(firstVal))) && (colKey.toLowerCase().includes('valor') || colKey.toLowerCase().includes('monto') || colKey.toLowerCase().includes('total') || colKey.toLowerCase().includes('precio') || colKey.toLowerCase().includes('tarifa') || colKey.toLowerCase().includes('costo') || colKey.toLowerCase().includes('utilidad'));
                                                            if (isNumCol) {
                                                                const sum = reportResult.reduce((acc, row) => acc + (Number(row[colKey]) || 0), 0);
                                                                return (
                                                                    <td key={j} className="py-2.5 px-3 border-r border-zinc-200 text-right font-mono text-xs text-blue-700 font-extrabold whitespace-nowrap">
                                                                        $ {sum.toLocaleString('es-CO', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                                                    </td>
                                                                )
                                                            }
                                                            return <td key={j} className="py-2.5 px-3 border-r border-zinc-200 whitespace-nowrap"></td>;
                                                        })}
                                                    </tr>
                                                </tfoot>
                                            </table>
                                        </div>
                                    )}

                                    {/* Pie del Reporte */}
                                    <div className="pt-6 border-t border-zinc-200 flex items-center justify-between text-[11px] text-zinc-500 font-medium">
                                        <div>KoreX ERP Agencias - Sistema de Gestión e Informes Operativos</div>
                                        <div>Página 1 de 1</div>
                                    </div>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </div>
    )
}
