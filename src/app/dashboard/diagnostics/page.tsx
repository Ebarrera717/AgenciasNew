'use client';

import React, { useState, useEffect } from 'react';
import { 
    Activity, ShieldAlert, Search, Download, RefreshCw, Sliders, X, 
    Clock, CheckCircle2, AlertTriangle, Database, Cpu, Trash2, FileText, ChevronRight, Eye,
    Copy, Check, Lightbulb, Wrench, Terminal, Code2, AlertCircle
} from 'lucide-react';

interface TraceSession {
    id: number;
    code: string;
    userId: number | null;
    userName: string;
    module: string;
    screen: string | null;
    action: string;
    process: string | null;
    status: string;
    totalDurationMs: number;
    errorMessage: string | null;
    eventCount: number;
    createdAt: string;
    updatedAt: string;
    origin?: string;
}

interface TraceLogDetail {
    log_id: number;
    session_code: string;
    userId: number | null;
    userName: string;
    eventType: string;
    stepName: string;
    spName: string | null;
    endpoint: string | null;
    durationMs: number;
    status: string;
    inputData: any;
    outputData: any;
    techMessage: string | null;
    functionalMessage: string | null;
    stackTrace: string | null;
    affectedId: string | null;
    createdAt: string;
}

export interface DiagnosticAnalysis {
    category: string;
    title: string;
    rootCause: string;
    suggestions: string[];
    technicalSummary: string;
    severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'INFO';
}

export function analyzeDiagnosticDetails(log: any): DiagnosticAnalysis {
    if (!log) {
        return {
            category: 'INFORMACION',
            title: 'Sin Datos de Evento',
            rootCause: 'No se ha seleccionado ningún evento o la traza carece de metadatos.',
            suggestions: ['Seleccione un evento del listado para inspeccionar los detalles.'],
            technicalSummary: 'Sin traza',
            severity: 'INFO'
        };
    }

    const msg = `${log.techMessage || ''} ${log.functionalMessage || ''} ${log.stepName || ''} ${log.spName || ''}`.toLowerCase();
    const isError = log.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(log.eventType);

    if (!isError) {
        return {
            category: 'OPERACION_EXITOSA',
            title: 'Paso Ejecutado Correctamente',
            rootCause: `El procedimiento o servicio '${log.spName || log.endpoint || log.stepName}' finalizó sin errores en ${log.durationMs || 0} ms.`,
            suggestions: ['No se requieren acciones adicionales para este paso.'],
            technicalSummary: `Ejecución limpia (${log.durationMs || 0}ms)`,
            severity: 'INFO'
        };
    }

    // 1. Violación de Restricción Única / Código Duplicado
    if (msg.includes('unique key') || msg.includes('uq_') || msg.includes('duplicate key') || msg.includes('duplicado') || msg.includes('error 2627') || msg.includes('error 2601')) {
        return {
            category: 'BASE_DATOS_RESTRICCION_UNICA',
            title: 'Código o Llave Única Duplicada (Constraint Violation)',
            rootCause: 'El sistema intentó insertar un registro con un código o identificador que ya existe en la base de datos.',
            suggestions: [
                'Verifique el valor del código asignado en el formulario o en la importación.',
                'Compruebe en la tabla maestra si la entidad ya fue creada anteriormente.',
                'Asigne un código único que no colisione con registros existentes.'
            ],
            technicalSummary: log.techMessage || 'Violation of UNIQUE KEY constraint',
            severity: 'HIGH'
        };
    }

    // 2. Violación de Llave Foránea / Maestro Inexistente
    if (msg.includes('foreign key') || msg.includes('fk_') || msg.includes('referential constraint') || msg.includes('error 547')) {
        return {
            category: 'BASE_DATOS_LLAVE_FORANEA',
            title: 'Referencia a Maestro Inexistente (Foreign Key Error)',
            rootCause: 'El registro enviado referencia a una entidad (Cliente, Vendedor, Sucursal, Producto, Impuesto, etc.) que no existe o fue eliminada de los catálogos.',
            suggestions: [
                'Examine los parámetros de entrada (inputData) para identificar las llaves de relación enviadas.',
                'Verifique que el Cliente, Vendedor, Sucursal o Producto exista en las tablas maestras de Korex o Zeus ERP.',
                'Si opera con Zeus ERP, compruebe la presencia del catálogo en dbo.CLIENTES, dbo.MAEVENDE, dbo.PROVEEDORES o dbo.PRODUCTOS.'
            ],
            technicalSummary: log.techMessage || 'Foreign Key Constraint Violation',
            severity: 'CRITICAL'
        };
    }

    // 3. Objeto o Columna Inexistente (Error DDL / Esquema)
    if (msg.includes('invalid column name') || msg.includes('invalid object name') || msg.includes('does not exist') || msg.includes('error 207') || msg.includes('error 208') || msg.includes('no existe la columna')) {
        return {
            category: 'BASE_DATOS_ESQUEMA_DDL',
            title: 'Estructura DDL Desfasada (Columna o Tabla Inexistente)',
            rootCause: 'El procedimiento almacenado o consulta SQL intentó acceder a una columna o tabla no presente en la base de datos activa.',
            suggestions: [
                'Ejecute el compilador de base de datos ejecutando: `node deploy/gen_schema_json.js`.',
                'Asegúrese de aplicar las alteraciones DDL correspondientes en `SQL/Table/Alter_New_Columns.sql` o `ActualizadorSERVER.sql`.',
                'Valide que el motor de base de datos activo (PostgreSQL local o SQL Server) contenga el esquema actualizado.'
            ],
            technicalSummary: log.techMessage || 'Invalid Column/Table Name',
            severity: 'CRITICAL'
        };
    }

    // 4. Procedimientos Almacenados Zeus ERP (Facturación / Cotización / Exportación)
    if (log.spName?.toLowerCase().includes('spfacturacionescrear') || log.spName?.toLowerCase().includes('spcotizacionescrear') || msg.includes('zeus') || msg.includes('facturacion') || msg.includes('cotizacion')) {
        return {
            category: 'INTEGRACION_ZEUS_ERP',
            title: 'Rechazo de Procesamiento en Stored Procedure Zeus ERP',
            rootCause: `El procedimiento '${log.spName || 'spFacturacionesCrear'}' no pudo procesar la transacción debido a una inconsistencia técnica en el XML entregado o en la parametrización de Zeus ERP.`,
            suggestions: [
                'Revise el cuadro "Mensaje Técnico de Error" para ubicar la línea exacta y la causa del fallo dentro del SP.',
                'Compruebe si el consecutivo del documento o la factura ya existía registrada en Zeus ERP.',
                'Verifique que la fecha, la resolución de facturación y el tipo de documento coincidan con los parámetros vigentes de la agencia.',
                'Examine los datos de entrada (inputData / XML) para verificar que las etiquetas XML mantengan la nomenclatura correcta.'
            ],
            technicalSummary: log.techMessage || log.functionalMessage || 'Error de procesamiento en SP Zeus ERP',
            severity: 'HIGH'
        };
    }

    // 5. Conversión de Tipo de Dato o Campo Nulo Inesperado
    if (msg.includes('conversion failed') || msg.includes('cannot insert the value null') || msg.includes('null value in column') || msg.includes('error 245') || msg.includes('error 515')) {
        return {
            category: 'ERROR_SINTAXIS_DATO',
            title: 'Conversión de Tipo de Dato Incompatible o Valor Nulo',
            rootCause: 'Se intentó asignar un valor nulo a un campo obligatorio (NOT NULL) o enviar un formato de texto a un campo numérico/fecha.',
            suggestions: [
                'Inspeccione el objeto de parámetros (inputData) para detectar variables nulas o tipos incompatibles.',
                'Asegúrese de suministrar valores predeterminados para campos obligatorios.',
                'Compruebe el casteo explícito de variables en el SP o endpoint.'
            ],
            technicalSummary: log.techMessage || 'Data Type / Null Constraint Error',
            severity: 'MEDIUM'
        };
    }

    // 6. Conexión de Red / Servidor de Base de Datos
    if (msg.includes('connection') || msg.includes('timeout') || msg.includes('connect') || msg.includes('network') || msg.includes('econnrefused')) {
        return {
            category: 'CONEXION_BASE_DATOS',
            title: 'Fallo de Conexión de Red con el Servidor SQL',
            rootCause: 'El servidor web Next.js no logró establecer o mantener la comunicación con el motor de base de datos.',
            suggestions: [
                'Compruebe la conectividad de red con el host configurado en la cadena de conexión.',
                'Verifique en la sección Parámetros -> SQL Server las credenciales (Servidor, Instancia, Usuario, Clave).',
                'Asegúrese de que el servicio de SQL Server / PostgreSQL se encuentre activo y respondiendo peticiones.'
            ],
            technicalSummary: log.techMessage || 'Database Network / Timeout Failure',
            severity: 'CRITICAL'
        };
    }

    // 7. General Error Fallback
    return {
        category: 'ERROR_GENERAL_SISTEMA',
        title: 'Excepción Técnica Detectada durante el Proceso',
        rootCause: log.techMessage || log.functionalMessage || 'El servicio o procedimiento registró una respuesta de error durante la ejecución.',
        suggestions: [
            'Revise la pestaña "Mensaje Técnico de Error" y la pila de llamadas para identificar el archivo o SP donde ocurrió la excepción.',
            'Verifique el contenido del objeto de parámetros de entrada (inputData).',
            'Exportar el informe en formato JSON mediante el botón "Exportar Informe (.json)" para adjuntarlo al equipo de soporte.'
        ],
        technicalSummary: log.techMessage || log.stepName || 'Error no clasificado',
        severity: 'HIGH'
    };
}

export default function DiagnosticsPage() {
    const [mode, setMode] = useState<'OFF' | 'BASIC' | 'DETAILED' | 'DIAGNOSTIC'>('OFF');
    const [sessions, setSessions] = useState<TraceSession[]>([]);
    const [loading, setLoading] = useState(true);
    const [updatingMode, setUpdatingMode] = useState(false);
    
    // Filtros
    const [filterCode, setFilterCode] = useState('');
    const [filterModule, setFilterModule] = useState('');
    const [filterStatus, setFilterStatus] = useState('');

    // Modal de detalle y línea de tiempo
    const [selectedCode, setSelectedCode] = useState<string | null>(null);
    const [detailSummary, setDetailSummary] = useState<any>(null);
    const [detailLogs, setDetailLogs] = useState<TraceLogDetail[]>([]);
    const [loadingDetails, setLoadingDetails] = useState(false);
    const [selectedLog, setSelectedLog] = useState<TraceLogDetail | null>(null);
    const [copiedKey, setCopiedKey] = useState<string | null>(null);

    // Cargar lista de sesiones
    const fetchSessions = async () => {
        setLoading(true);
        try {
            const queryParams = new URLSearchParams();
            if (filterCode) queryParams.set('code', filterCode);
            if (filterModule) queryParams.set('module', filterModule);
            if (filterStatus) queryParams.set('status', filterStatus);

            const res = await fetch(`/api/traceability?${queryParams.toString()}`);
            if (res.ok) {
                const data = await res.json();
                setSessions(data.data || []);
                if (data.mode) setMode(data.mode);
            }
        } catch (e) {
            console.error('Fallo al cargar trazas:', e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSessions();
    }, [filterCode, filterModule, filterStatus]);

    // Cambiar modo de trazabilidad
    const handleModeChange = async (newMode: 'OFF' | 'BASIC' | 'DETAILED' | 'DIAGNOSTIC') => {
        setUpdatingMode(true);
        try {
            const res = await fetch('/api/traceability', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'SET_MODE', mode: newMode })
            });
            if (res.ok) {
                setMode(newMode);
                fetchSessions();
            }
        } catch (e) {
            console.error('Fallo al cambiar modo:', e);
        } finally {
            setUpdatingMode(false);
        }
    };

    // Ver detalle de traza (Línea de Tiempo)
    const handleOpenDetails = async (code: string) => {
        setSelectedCode(code);
        setLoadingDetails(true);
        setSelectedLog(null);
        try {
            const res = await fetch(`/api/traceability/${code}`);
            if (res.ok) {
                const data = await res.json();
                setDetailSummary(data.summary);
                setDetailLogs(data.logs || []);
                if (data.logs && data.logs.length > 0) {
                    const errLog = data.logs.find((l: any) => l.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(l.eventType));
                    setSelectedLog(errLog || data.logs[0]);
                }
            }
        } catch (e) {
            console.error('Fallo al cargar detalle:', e);
        } finally {
            setLoadingDetails(false);
        }
    };

    // Copiar al portapapeles
    const handleCopy = (text: string, key: string) => {
        navigator.clipboard.writeText(text);
        setCopiedKey(key);
        setTimeout(() => setCopiedKey(null), 2000);
    };

    // Exportar informe de diagnóstico en JSON
    const handleExportDiagnostic = () => {
        if (!selectedCode || !detailSummary) return;
        
        const enrichedEvents = (detailLogs || []).map(log => ({
            ...log,
            diagnosticAnalysis: analyzeDiagnosticDetails(log)
        }));

        const exportData = {
            exportTitle: 'INFORME TECNICO Y DIAGNOSTICO ENRIQUECIDO DE TRAZABILIDAD',
            system: 'Korex ERP AgenciasNew Platform',
            exportDate: new Date().toISOString(),
            traceabilityCode: selectedCode,
            summary: detailSummary,
            eventsCount: enrichedEvents.length,
            events: enrichedEvents
        };

        const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `Diagnostico-${selectedCode}.json`;
        a.click();
        URL.revokeObjectURL(url);
    };

    // Depurar trazas antiguas
    const handleCleanOldTraces = async () => {
        if (!confirm('¿Desea depurar registros de trazabilidad anteriores a 30 días?')) return;
        try {
            const res = await fetch('/api/traceability/clean', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ days: 30 })
            });
            if (res.ok) {
                const data = await res.json();
                alert(data.message);
                fetchSessions();
            }
        } catch (e) {
            alert('Fallo al depurar trazas');
        }
    };

    return (
        <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
            {/* Header Banner */}
            <div className="bg-gradient-to-r from-slate-900 via-blue-900 to-indigo-900 rounded-3xl p-6 md:p-8 text-white shadow-xl relative overflow-hidden">
                <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <span className="p-2 bg-blue-500/20 rounded-xl border border-blue-400/30 text-blue-300">
                                <Activity className="w-6 h-6" />
                            </span>
                            <h1 className="text-2xl md:text-3xl font-black tracking-tight">Trazabilidad y Diagnóstico</h1>
                        </div>
                        <p className="text-slate-300 text-sm md:text-base max-w-2xl">
                            Herramienta transversal de auditoría técnica, diagnóstico de errores e inspección paso a paso de transacciones y SPs.
                        </p>
                    </div>

                    <div className="flex items-center gap-3">
                        <button 
                            onClick={fetchSessions}
                            className="bg-white/10 hover:bg-white/20 text-white px-4 py-2.5 rounded-xl text-sm font-semibold flex items-center gap-2 transition backdrop-blur-md"
                        >
                            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                            Actualizar
                        </button>
                        <button 
                            onClick={handleCleanOldTraces}
                            className="bg-red-500/20 hover:bg-red-500/30 text-red-200 border border-red-500/30 px-4 py-2.5 rounded-xl text-sm font-semibold flex items-center gap-2 transition"
                        >
                            <Trash2 className="w-4 h-4" />
                            Depurar 30d
                        </button>
                    </div>
                </div>
            </div>

            {/* Selector de Modo de Trazabilidad */}
            <div className="bg-white dark:bg-zinc-900 rounded-2xl p-6 border border-zinc-200 dark:border-zinc-800 shadow-sm">
                <div className="flex items-center justify-between mb-4">
                    <div>
                        <h2 className="text-lg font-bold text-zinc-900 dark:text-white flex items-center gap-2">
                            <Sliders className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                            Nivel de Trazabilidad Activo
                        </h2>
                        <p className="text-xs text-zinc-500 dark:text-zinc-400">
                            Ajusta la profundidad del diagnóstico sin reiniciar la aplicación.
                        </p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                        mode === 'OFF' ? 'bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400' :
                        mode === 'BASIC' ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400' :
                        mode === 'DETAILED' ? 'bg-blue-100 text-blue-700 dark:bg-blue-950/40 dark:text-blue-400' :
                        'bg-purple-100 text-purple-700 dark:bg-purple-950/40 dark:text-purple-400 animate-pulse'
                    }`}>
                        MODO ACTUAL: {mode}
                    </span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    {[
                        { id: 'OFF', label: 'Desactivado (OFF)', desc: 'Sin traza. Cero impacto en rendimiento (Por defecto)', color: 'zinc' },
                        { id: 'BASIC', label: 'Básico', desc: 'Registra solo errores no capturados y transacciones fallidas', color: 'emerald' },
                        { id: 'DETAILED', label: 'Detallado', desc: 'Registra acciones de usuario, endpoints y SPs principales', color: 'blue' },
                        { id: 'DIAGNOSTIC', label: 'Diagnóstico Profundo', desc: 'Traza completa paso a paso, duraciones ms y metadatos', color: 'purple' },
                    ].map((item) => (
                        <button
                            key={item.id}
                            disabled={updatingMode}
                            onClick={() => handleModeChange(item.id as any)}
                            className={`p-4 rounded-xl text-left border transition-all relative ${
                                mode === item.id 
                                    ? 'border-blue-600 bg-blue-50/50 dark:bg-blue-950/20 dark:border-blue-500 ring-2 ring-blue-500/20' 
                                    : 'border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700 bg-zinc-50/50 dark:bg-zinc-900/50'
                            }`}
                        >
                            <div className="font-bold text-sm text-zinc-900 dark:text-white mb-1 flex items-center justify-between">
                                {item.label}
                                {mode === item.id && <CheckCircle2 className="w-4 h-4 text-blue-600 dark:text-blue-400" />}
                            </div>
                            <p className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">{item.desc}</p>
                        </button>
                    ))}
                </div>
            </div>

            {/* Filtros de Búsqueda */}
            <div className="bg-white dark:bg-zinc-900 rounded-2xl p-4 border border-zinc-200 dark:border-zinc-800 shadow-sm grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="relative">
                    <Search className="w-4 h-4 absolute left-3 top-3.5 text-zinc-400" />
                    <input 
                        type="text" 
                        placeholder="Buscar por código (ej: TRC-...)"
                        value={filterCode}
                        onChange={(e) => setFilterCode(e.target.value)}
                        className="w-full pl-9 pr-4 py-2.5 bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 rounded-xl text-sm font-medium focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                    />
                </div>
                <div>
                    <input 
                        type="text" 
                        placeholder="Filtrar por Módulo (ej: Cotizaciones, Facturación)"
                        value={filterModule}
                        onChange={(e) => setFilterModule(e.target.value)}
                        className="w-full px-4 py-2.5 bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 rounded-xl text-sm font-medium focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                    />
                </div>
                <div>
                    <select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                        className="w-full px-4 py-2.5 bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 rounded-xl text-sm font-medium focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                    >
                        <option value="">Todos los Estados</option>
                        <option value="ERROR">Errores / Excepciones</option>
                        <option value="SUCCESS">Exitosos</option>
                        <option value="IN_PROGRESS">En Proceso</option>
                    </select>
                </div>
            </div>

            {/* Tabla de Traza de Diagnóstico */}
            <div className="bg-white dark:bg-zinc-900 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-sm overflow-hidden">
                <div className="p-4 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                    <h3 className="font-bold text-zinc-900 dark:text-white text-sm flex items-center gap-2">
                        <FileText className="w-4 h-4 text-blue-600" />
                        Historial de Sesiones de Trazabilidad ({sessions.length})
                    </h3>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-zinc-50 dark:bg-zinc-800/50 text-xs font-bold text-zinc-500 dark:text-zinc-400 border-b border-zinc-200 dark:border-zinc-800">
                                <th className="p-4">CÓDIGO DE TRAZA</th>
                                <th className="p-4">FECHA / HORA</th>
                                <th className="p-4">ORIGEN</th>
                                <th className="p-4">USUARIO</th>
                                <th className="p-4">MÓDULO</th>
                                <th className="p-4">ACCIÓN / PROCESO</th>
                                <th className="p-4">EVENTOS</th>
                                <th className="p-4">TIEMPO (MS)</th>
                                <th className="p-4">ESTADO</th>
                                <th className="p-4 text-right">ACCIONES</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800 text-sm">
                            {loading ? (
                                <tr>
                                    <td colSpan={10} className="p-12 text-center text-zinc-400">
                                        <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2" />
                                        Cargando trazabilidad...
                                    </td>
                                </tr>
                            ) : sessions.length === 0 ? (
                                <tr>
                                    <td colSpan={10} className="p-12 text-center text-zinc-400 font-medium">
                                        No se encontraron registros de trazabilidad para los filtros seleccionados.
                                    </td>
                                </tr>
                            ) : (
                                sessions.map((s) => (
                                    <tr key={s.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-colors">
                                        <td className="p-4 font-mono text-xs font-bold text-blue-600 dark:text-blue-400">
                                            {s.code}
                                        </td>
                                        <td className="p-4 text-xs text-zinc-500 dark:text-zinc-400">
                                            {new Date(s.createdAt).toLocaleString()}
                                        </td>
                                        <td className="p-4">
                                            <span className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
                                                (s.origin || 'WEB') === 'EXCEL'
                                                    ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/50 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-700'
                                                    : (s.origin || 'WEB') === 'API'
                                                    ? 'bg-purple-100 text-purple-800 dark:bg-purple-950/50 dark:text-purple-300 border border-purple-300 dark:border-purple-700'
                                                    : 'bg-zinc-100 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-300 border border-zinc-300 dark:border-zinc-700'
                                            }`}>
                                                {s.origin || 'WEB'}
                                            </span>
                                        </td>
                                        <td className="p-4 font-medium text-zinc-900 dark:text-white">
                                            {s.userName}
                                        </td>
                                        <td className="p-4">
                                            <span className="px-2.5 py-1 bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-lg text-xs font-semibold">
                                                {s.module}
                                            </span>
                                        </td>
                                        <td className="p-4 text-zinc-700 dark:text-zinc-300 font-medium">
                                            {s.action} {s.process ? `(${s.process})` : ''}
                                        </td>
                                        <td className="p-4 font-semibold text-zinc-600 dark:text-zinc-400 text-xs">
                                            {s.eventCount} pas{s.eventCount === 1 ? 'o' : 'os'}
                                        </td>
                                        <td className="p-4 font-mono text-xs text-zinc-600 dark:text-zinc-400">
                                            {s.totalDurationMs ? `${s.totalDurationMs.toFixed(1)} ms` : '0 ms'}
                                        </td>
                                        <td className="p-4">
                                            <span className={`px-2.5 py-1 rounded-full text-xs font-bold flex items-center gap-1 w-fit ${
                                                s.status === 'ERROR' 
                                                    ? 'bg-red-100 text-red-700 dark:bg-red-950/40 dark:text-red-400' 
                                                    : s.status === 'IN_PROGRESS'
                                                    ? 'bg-blue-100 text-blue-700 dark:bg-blue-950/40 dark:text-blue-400'
                                                    : 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400'
                                            }`}>
                                                {s.status === 'ERROR' ? <ShieldAlert className="w-3.5 h-3.5" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                                                {s.status}
                                            </span>
                                        </td>
                                        <td className="p-4 text-right">
                                            <button
                                                onClick={() => handleOpenDetails(s.code)}
                                                className="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 ml-auto shadow-sm"
                                            >
                                                <Eye className="w-3.5 h-3.5" />
                                                Inspeccionar
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal de Línea de Tiempo de Diagnóstico */}
            {selectedCode && (
                <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
                    <div className="bg-white dark:bg-zinc-900 rounded-3xl max-w-5xl w-full max-h-[90vh] flex flex-col shadow-2xl border border-zinc-200 dark:border-zinc-800 overflow-hidden">
                        {/* Modal Header */}
                        <div className="p-6 bg-zinc-900 text-white flex items-center justify-between">
                            <div>
                                <span className="text-xs font-bold text-blue-400 tracking-wider uppercase">MODO DIAGNÓSTICO</span>
                                <h3 className="text-xl font-black flex items-center gap-2 mt-0.5">
                                    Traza: {selectedCode}
                                </h3>
                            </div>
                            <div className="flex items-center gap-3">
                                <button
                                    onClick={handleExportDiagnostic}
                                    className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 transition"
                                >
                                    <Download className="w-4 h-4" />
                                    Exportar Informe (.json)
                                </button>
                                <button 
                                    onClick={() => setSelectedCode(null)}
                                    className="p-2 hover:bg-white/10 rounded-xl text-zinc-400 hover:text-white transition"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>
                        </div>

                        {/* Modal Content */}
                        <div className="flex-1 overflow-y-auto p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
                            {/* Columna Izquierda: Línea de Tiempo */}
                            <div className="lg:col-span-6 space-y-4">
                                <h4 className="font-bold text-sm text-zinc-900 dark:text-white flex items-center gap-2 border-b border-zinc-200 dark:border-zinc-800 pb-2">
                                    <Clock className="w-4 h-4 text-blue-600" />
                                    Línea de Tiempo del Proceso ({detailLogs.length} eventos)
                                </h4>

                                {loadingDetails ? (
                                    <div className="p-8 text-center text-zinc-400">
                                        <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2" />
                                        Reconstruyendo traza paso a paso...
                                    </div>
                                ) : (
                                    <div className="relative pl-6 space-y-4 before:absolute before:left-2.5 before:top-3 before:bottom-3 before:w-0.5 before:bg-zinc-200 dark:before:bg-zinc-800">
                                        {detailLogs.map((log, idx) => (
                                            <div 
                                                key={log.log_id || idx}
                                                onClick={() => setSelectedLog(log)}
                                                className={`cursor-pointer p-4 rounded-2xl border transition-all relative ${
                                                    selectedLog?.log_id === log.log_id 
                                                        ? 'border-blue-600 bg-blue-50/40 dark:bg-blue-950/30 ring-2 ring-blue-500/20 shadow-md' 
                                                        : 'border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700 bg-white dark:bg-zinc-900'
                                                }`}
                                            >
                                                {/* Bullet Point */}
                                                <div className={`absolute -left-6 top-5 w-3.5 h-3.5 rounded-full border-2 border-white dark:border-zinc-900 ${
                                                    log.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(log.eventType)
                                                        ? 'bg-red-500'
                                                        : 'bg-blue-600'
                                                }`} />

                                                <div className="flex items-center justify-between text-xs mb-1">
                                                    <span className="font-bold text-blue-600 dark:text-blue-400 uppercase tracking-wide">
                                                        {log.eventType}
                                                    </span>
                                                    <span className="text-zinc-400 font-mono">
                                                        {new Date(log.createdAt).toLocaleTimeString()} ({log.durationMs}ms)
                                                    </span>
                                                </div>

                                                <div className="font-bold text-sm text-zinc-900 dark:text-white">
                                                    {log.stepName}
                                                </div>

                                                {log.spName && (
                                                    <div className="text-xs font-mono text-indigo-600 dark:text-indigo-400 mt-1">
                                                        SP: {log.spName}
                                                    </div>
                                                )}

                                                {log.techMessage && (
                                                    <div className="text-xs text-red-600 dark:text-red-400 font-medium mt-1 truncate">
                                                        {log.techMessage}
                                                    </div>
                                                )}
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>

                            {/* Columna Derecha: Detalle Técnico del Paso Seleccionado y Diagnóstico Inteligente */}
                            <div className="lg:col-span-6 bg-zinc-50 dark:bg-zinc-950 rounded-2xl p-5 border border-zinc-200 dark:border-zinc-800 space-y-4 overflow-y-auto max-h-[70vh]">
                                <h4 className="font-bold text-sm text-zinc-900 dark:text-white flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-2">
                                    <span className="flex items-center gap-2">
                                        <Cpu className="w-4 h-4 text-purple-600" />
                                        Inspección Técnica & Diagnóstico
                                    </span>
                                    {selectedLog && (
                                        <span className="text-[11px] font-mono text-zinc-400">
                                            ID Log #{selectedLog.log_id}
                                        </span>
                                    )}
                                </h4>

                                {selectedLog ? (() => {
                                    const diag = analyzeDiagnosticDetails(selectedLog);
                                    const isError = selectedLog.status === 'ERROR' || ['ERROR', 'EXCEPCION'].includes(selectedLog.eventType);
                                    
                                    return (
                                        <div className="space-y-4 text-xs">
                                            {/* Tarjeta de Diagnóstico Inteligente y Causa Raíz */}
                                            <div className={`p-4 rounded-2xl border ${
                                                isError 
                                                    ? 'bg-amber-500/10 dark:bg-amber-950/30 border-amber-300 dark:border-amber-800/60' 
                                                    : 'bg-emerald-500/10 dark:bg-emerald-950/30 border-emerald-300 dark:border-emerald-800/60'
                                            }`}>
                                                <div className="flex items-center justify-between mb-2">
                                                    <span className={`px-2.5 py-0.5 rounded-full font-black text-[10px] uppercase tracking-wider flex items-center gap-1.5 ${
                                                        isError 
                                                            ? 'bg-amber-500 text-white' 
                                                            : 'bg-emerald-600 text-white'
                                                    }`}>
                                                        {isError ? <AlertTriangle className="w-3 h-3" /> : <CheckCircle2 className="w-3 h-3" />}
                                                        {diag.category}
                                                    </span>

                                                    <button 
                                                        onClick={() => handleCopy(
                                                            `[DIAGNOSTICO KOREX]\nCategoría: ${diag.category}\nTítulo: ${diag.title}\nCausa Raíz: ${diag.rootCause}\nSolución Sugerida:\n${diag.suggestions.map((s, i) => `${i+1}. ${s}`).join('\n')}\nMensaje Técnico: ${selectedLog.techMessage || 'N/A'}\nSP: ${selectedLog.spName || 'N/A'}`,
                                                            'diag'
                                                        )}
                                                        className="px-2.5 py-1 bg-white/80 dark:bg-zinc-800/80 hover:bg-white text-zinc-700 dark:text-zinc-200 rounded-lg border border-zinc-300 dark:border-zinc-700 text-[11px] font-bold flex items-center gap-1 transition shadow-sm"
                                                    >
                                                        {copiedKey === 'diag' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                                        {copiedKey === 'diag' ? 'Copiado!' : 'Copiar Diagnóstico'}
                                                    </button>
                                                </div>

                                                <h5 className="text-sm font-black text-zinc-900 dark:text-white mb-1">
                                                    {diag.title}
                                                </h5>

                                                {/* Causa Raíz Probable */}
                                                <div className="mt-2.5 space-y-1">
                                                    <span className="font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 text-xs">
                                                        <Lightbulb className="w-4 h-4 text-amber-500 shrink-0" />
                                                        Causa Raíz Probable:
                                                    </span>
                                                    <p className="text-zinc-700 dark:text-zinc-300 pl-5 leading-relaxed font-medium">
                                                        {diag.rootCause}
                                                    </p>
                                                </div>

                                                {/* Pasos Sugeridos para Solución */}
                                                <div className="mt-3 pt-2.5 border-t border-zinc-200 dark:border-zinc-800/60 space-y-1.5">
                                                    <span className="font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 text-xs">
                                                        <Wrench className="w-4 h-4 text-blue-500 shrink-0" />
                                                        Acciones Recomendadas para Solucionar:
                                                    </span>
                                                    <ul className="pl-5 space-y-1 text-zinc-600 dark:text-zinc-300 list-disc font-medium">
                                                        {diag.suggestions.map((sug, idx) => (
                                                            <li key={idx} className="leading-relaxed">{sug}</li>
                                                        ))}
                                                    </ul>
                                                </div>
                                            </div>

                                            {/* Grilla de Atributos Básicos del Evento */}
                                            <div className="grid grid-cols-2 gap-3 bg-white dark:bg-zinc-900 p-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800">
                                                <div>
                                                    <span className="text-zinc-400 block font-medium">Tipo de Evento</span>
                                                    <span className="font-bold text-zinc-900 dark:text-white">{selectedLog.eventType}</span>
                                                </div>
                                                <div>
                                                    <span className="text-zinc-400 block font-medium">Estado Paso</span>
                                                    <span className={`font-bold ${selectedLog.status === 'ERROR' ? 'text-red-500' : 'text-emerald-500'}`}>
                                                        {selectedLog.status}
                                                    </span>
                                                </div>
                                                <div>
                                                    <span className="text-zinc-400 block font-medium">Procedimiento (SP)</span>
                                                    <span className="font-mono text-indigo-500 font-bold truncate block">{selectedLog.spName || 'N/A'}</span>
                                                </div>
                                                <div>
                                                    <span className="text-zinc-400 block font-medium">Duración</span>
                                                    <span className="font-mono font-bold text-zinc-900 dark:text-white">{selectedLog.durationMs} ms</span>
                                                </div>
                                                {selectedLog.endpoint && (
                                                    <div className="col-span-2">
                                                        <span className="text-zinc-400 block font-medium">Endpoint HTTP</span>
                                                        <span className="font-mono text-blue-500 font-bold block truncate">{selectedLog.endpoint}</span>
                                                    </div>
                                                )}
                                            </div>

                                            {/* Mensaje Técnico de Error Detallado */}
                                            {(selectedLog.techMessage || (selectedLog.status === 'ERROR' && (selectedLog.functionalMessage || selectedLog.outputData || selectedLog.stackTrace))) && (
                                                <div className="bg-red-50 dark:bg-red-950/30 p-4 rounded-xl border border-red-200 dark:border-red-900/50 space-y-1.5">
                                                    <div className="flex items-center justify-between">
                                                        <span className="font-bold text-red-700 dark:text-red-400 flex items-center gap-1.5">
                                                            <Terminal className="w-4 h-4 text-red-500" />
                                                            Mensaje Técnico de Error (SQL / API):
                                                        </span>
                                                        <button 
                                                            onClick={() => handleCopy(
                                                                selectedLog.techMessage || selectedLog.functionalMessage || (typeof selectedLog.outputData === 'string' ? selectedLog.outputData : JSON.stringify(selectedLog.outputData)) || selectedLog.stackTrace || '', 
                                                                'techMsg'
                                                            )}
                                                            className="p-1 hover:bg-red-200/50 dark:hover:bg-red-900/50 rounded text-red-700 dark:text-red-300 transition"
                                                            title="Copiar mensaje"
                                                        >
                                                            {copiedKey === 'techMsg' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                                        </button>
                                                    </div>
                                                    <p className="font-mono text-red-600 dark:text-red-300 leading-relaxed text-[11px] whitespace-pre-wrap break-words bg-white/60 dark:bg-zinc-900/60 p-2.5 rounded-lg border border-red-200/50 dark:border-red-900/30">
                                                        {selectedLog.techMessage || selectedLog.functionalMessage || (typeof selectedLog.outputData === 'string' ? selectedLog.outputData : (selectedLog.outputData ? JSON.stringify(selectedLog.outputData, null, 2) : 'Error no especificado'))}
                                                    </p>
                                                </div>
                                            )}

                                            {/* Mensaje Funcional para el Usuario */}
                                            {selectedLog.functionalMessage && (
                                                <div className="bg-blue-50 dark:bg-blue-950/30 p-3.5 rounded-xl border border-blue-200 dark:border-blue-900/50">
                                                    <span className="font-bold text-blue-700 dark:text-blue-400 block mb-1">Mensaje Funcional:</span>
                                                    <p className="text-zinc-700 dark:text-zinc-300 leading-relaxed font-medium">{selectedLog.functionalMessage}</p>
                                                </div>
                                            )}

                                            {/* Pila de Llamadas / Stack Trace */}
                                            {selectedLog.stackTrace && (
                                                <div className="bg-zinc-900 text-zinc-300 p-3.5 rounded-xl border border-zinc-800 space-y-1">
                                                    <div className="flex items-center justify-between text-zinc-400 font-bold mb-1">
                                                        <span className="flex items-center gap-1.5">
                                                            <Code2 className="w-4 h-4 text-purple-400" />
                                                            Pila de Llamadas (Stack Trace):
                                                        </span>
                                                        <button 
                                                            onClick={() => handleCopy(selectedLog.stackTrace || '', 'stack')}
                                                            className="p-1 hover:bg-zinc-800 rounded text-zinc-400 hover:text-white transition"
                                                        >
                                                            {copiedKey === 'stack' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                                        </button>
                                                    </div>
                                                    <pre className="font-mono text-[10px] text-purple-300 overflow-x-auto p-2 bg-zinc-950 rounded-lg max-h-40">
                                                        {selectedLog.stackTrace}
                                                    </pre>
                                                </div>
                                            )}

                                            {/* Parámetros de Entrada (Enmascarados) */}
                                            {selectedLog.inputData && (
                                                <div className="space-y-1">
                                                    <div className="flex items-center justify-between text-zinc-700 dark:text-zinc-300 font-bold">
                                                        <span>Parámetros Entrada (Enmascarados):</span>
                                                        <button 
                                                            onClick={() => handleCopy(JSON.stringify(selectedLog.inputData, null, 2), 'input')}
                                                            className="p-1 hover:bg-zinc-200 dark:hover:bg-zinc-800 rounded text-zinc-500 transition"
                                                        >
                                                            {copiedKey === 'input' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                                        </button>
                                                    </div>
                                                    <pre className="bg-zinc-900 text-emerald-400 p-3 rounded-xl font-mono text-[11px] overflow-x-auto border border-zinc-800 max-h-52">
                                                        {JSON.stringify(selectedLog.inputData, null, 2)}
                                                    </pre>
                                                </div>
                                            )}

                                            {/* Resultado / Salida del Servidor */}
                                            {selectedLog.outputData && (
                                                <div className="space-y-1">
                                                    <div className="flex items-center justify-between text-zinc-700 dark:text-zinc-300 font-bold">
                                                        <span>Resultado / Salida:</span>
                                                        <button 
                                                            onClick={() => handleCopy(JSON.stringify(selectedLog.outputData, null, 2), 'output')}
                                                            className="p-1 hover:bg-zinc-200 dark:hover:bg-zinc-800 rounded text-zinc-500 transition"
                                                        >
                                                            {copiedKey === 'output' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
                                                        </button>
                                                    </div>
                                                    <pre className="bg-zinc-900 text-blue-400 p-3 rounded-xl font-mono text-[11px] overflow-x-auto border border-zinc-800 max-h-52">
                                                        {JSON.stringify(selectedLog.outputData, null, 2)}
                                                    </pre>
                                                </div>
                                            )}
                                        </div>
                                    );
                                })() : (
                                    <div className="p-8 text-center text-zinc-400 text-xs">
                                        Selecciona un evento de la línea de tiempo para inspeccionar sus parámetros y resultado técnico.
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
