'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
    Settings,
    Users,
    Building2,
    Tags,
    Tag,
    DollarSign,
    Plus,
    Search,
    Trash2,
    ShieldCheck,
    Mail,
    Key,
    Database,
    Loader2,
    X,
    Check,
    UserCheck,
    Printer,
    Edit2,
    Download,
    Hotel as HotelIcon,
    TerminalSquare,
    Copy,
    ArrowUp,
    ArrowDown,
    FileText,
    Upload,
    Activity,
    Stethoscope,
    RefreshCw,
    Server,
    SlidersHorizontal,
    ArrowUpDown
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { SearchSelect } from '@/components/SearchSelect'
import { QuotationFormatsTab } from '@/components/QuotationFormatsTab'
import RoleManagerTab from '@/components/RoleManagerTab'
import LicenseStatusCard from '@/components/LicenseStatusCard'
import { AdministrativeFeeTab } from '@/components/AdministrativeFeeTab'
import ErrorDiagnosticModal, { DiagnosticErrorData } from '@/components/ErrorDiagnosticModal'
import { isSuperAdminRole } from '@/lib/permissions'

type Tab = 'parametros' | 'roles' | 'usuarios' | 'sucursales' | 'implants' | 'impuestos' | 'vendedores' | 'tiqueteadores' | 'prestadoras' | 'clientes' | 'proveedores' | 'tipos-proveedores' | 'productos' | 'variables' | 'combos' | 'logs' | 'monedas' | 'equivalencias' | 'extraccion-interfaces' | 'tarjetas-credito' | 'formas-pago' | 'paises' | 'ciudades' | 'aeropuertos' | 'tipos-tiquetes' | 'estados-cotizacion' | 'formatos-cotizacion' | 'modulos-sitio' | 'resoluciones-documentos' | 'consecutivos-transacciones' | 'tarifa-administrativa' | 'diagnostico';


interface TabConfigItem {
    endpoint: string;
    singular: string;
    plural: string;
    article: 'un' | 'una';
    newLabel: string;
}

const TAB_CONFIG: Record<Tab, TabConfigItem> = {
    'diagnostico': { endpoint: '/api/config/diagnostics', singular: 'Diagnóstico', plural: 'Diagnóstico y Salud', article: 'un', newLabel: 'Diagnóstico de Salud' },
    'usuarios': { endpoint: '/api/config/users', singular: 'Usuario', plural: 'Usuarios', article: 'un', newLabel: 'Nuevo Usuario' },
    'sucursales': { endpoint: '/api/config/branches', singular: 'Sucursal', plural: 'Sucursales', article: 'una', newLabel: 'Nueva Sucursal' },
    'implants': { endpoint: '/api/config/implants', singular: 'Implant', plural: 'Implants', article: 'un', newLabel: 'Nuevo Implant' },
    'impuestos': { endpoint: '/api/config/taxes', singular: 'Cargo/Impuesto', plural: 'Cargos e Impuestos', article: 'un', newLabel: 'Nuevo Cargo/Impuesto' },
    'vendedores': { endpoint: '/api/config/sellers', singular: 'Vendedor', plural: 'Vendedores', article: 'un', newLabel: 'Nuevo Vendedor' },
    'tiqueteadores': { endpoint: '/api/config/ticket-printers', singular: 'Tiqueteador', plural: 'Tiqueteadores', article: 'un', newLabel: 'Nuevo Tiqueteador' },
    'prestadoras': { endpoint: '/api/config/prestadoras', singular: 'Prestadora', plural: 'Prestadoras', article: 'una', newLabel: 'Nueva Prestadora' },
    'clientes': { endpoint: '/api/clients', singular: 'Cliente', plural: 'Clientes', article: 'un', newLabel: 'Nuevo Cliente' },
    'proveedores': { endpoint: '/api/providers', singular: 'Proveedor', plural: 'Proveedores', article: 'un', newLabel: 'Nuevo Proveedor' },
    'tipos-proveedores': { endpoint: '/api/provider-types', singular: 'Tipo de Proveedor', plural: 'Tipos de Proveedor', article: 'un', newLabel: 'Nuevo Tipo de Proveedor' },
    'productos': { endpoint: '/api/products', singular: 'Producto', plural: 'Productos', article: 'un', newLabel: 'Nuevo Producto' },
    'variables': { endpoint: '/api/config/variables', singular: 'Variable', plural: 'Variables', article: 'una', newLabel: 'Nueva Variable' },
    'parametros': { endpoint: '/api/config/parameters', singular: 'Parámetro', plural: 'Parámetros', article: 'un', newLabel: 'Nuevo Parámetro' },
    'monedas': { endpoint: '/api/config/currencies', singular: 'Moneda', plural: 'Monedas', article: 'una', newLabel: 'Nueva Moneda' },
    'combos': { endpoint: '/api/combos', singular: 'Combo', plural: 'Combos', article: 'un', newLabel: 'Nuevo Combo' },
    'equivalencias': { endpoint: '/api/config/equivalences', singular: 'Equivalencia', plural: 'Equivalencias', article: 'una', newLabel: 'Nueva Equivalencia' },
    'extraccion-interfaces': { endpoint: '/api/config/interface-extract-params', singular: 'Parámetro de Extracción', plural: 'Extracción Interfaces', article: 'un', newLabel: 'Nuevo Parámetro' },
    'resoluciones-documentos': { endpoint: '/api/config/document-resolutions', singular: 'Resolución', plural: 'Resoluciones', article: 'una', newLabel: 'Nueva Resolución' },
    'consecutivos-transacciones': { endpoint: '/api/config/transaction-consecutives', singular: 'Consecutivo', plural: 'Consecutivos', article: 'un', newLabel: 'Nuevo Consecutivo' },
    'tarjetas-credito': { endpoint: '/api/config/credit-cards', singular: 'Tarjeta', plural: 'Tarjetas de Crédito', article: 'una', newLabel: 'Nueva Tarjeta' },
    'formas-pago': { endpoint: '/api/config/payments', singular: 'Forma de Pago', plural: 'Formas de Pago', article: 'una', newLabel: 'Nueva Forma de Pago' },
    'paises': { endpoint: '/api/config/countries', singular: 'País', plural: 'Países', article: 'un', newLabel: 'Nuevo País' },
    'ciudades': { endpoint: '/api/config/cities', singular: 'Ciudad', plural: 'Ciudades', article: 'una', newLabel: 'Nueva Ciudad' },
    'aeropuertos': { endpoint: '/api/config/airports', singular: 'Aeropuerto', plural: 'Aeropuertos', article: 'un', newLabel: 'Nuevo Aeropuerto' },
    'tipos-tiquetes': { endpoint: '/api/config/ticket-types', singular: 'Tipo de Tiquete', plural: 'Tipos de Tiquete', article: 'un', newLabel: 'Nuevo Tipo de Tiquete' },
    'estados-cotizacion': { endpoint: '/api/config/quotation-states', singular: 'Estado Cotización', plural: 'Estados de Cotización', article: 'un', newLabel: 'Nuevo Estado Cotización' },
    'formatos-cotizacion': { endpoint: '/api/config/quotation-formats', singular: 'Formato Cotización', plural: 'Formatos de Cotización', article: 'un', newLabel: 'Nuevo Formato Cotización' },
    'modulos-sitio': { endpoint: '', singular: 'Módulo del Sitio', plural: 'Módulos del Sitio', article: 'un', newLabel: 'Nuevo Módulo' },
    'roles': { endpoint: '/api/config/roles', singular: 'Rol', plural: 'Roles', article: 'un', newLabel: 'Nuevo Rol' },
    'tarifa-administrativa': { endpoint: '/api/config/parameters', singular: 'Parámetro Tarifa Administrativa', plural: 'Parámetros Tarifa Administrativa', article: 'un', newLabel: 'Nuevo Parámetro' },
    'logs': { endpoint: '/api/config/logs', singular: 'Log', plural: 'Logs del Sistema', article: 'un', newLabel: 'Logs' }
};


const AVAILABLE_MANDATORY_FIELDS = [
    { key: 'QuotationProduct.passengers', label: 'Pasajeros (Nombre obligatorio)', group: 'Por Producto' },
    { key: 'QuotationProduct.payments', label: 'Formas de Pago (Al menos un pago registrado)', group: 'Por Producto' },
    { key: 'QuotationProduct.checkInDate', label: 'Fecha de Inicio (Check-In)', group: 'Por Producto' },
    { key: 'QuotationProduct.checkOutDate', label: 'Fecha de Fin (Check-Out)', group: 'Por Producto' },
    { key: 'QuotationProduct.destination', label: 'Destino', group: 'Por Producto' },
    { key: 'QuotationProduct.reservationCode', label: 'Código de Reserva', group: 'Por Producto' },
    { key: 'QuotationProduct.providerId', label: 'Proveedor', group: 'Por Producto' },
    { key: 'QuotationProduct.prestadoraId', label: 'Prestadora / Hotel', group: 'Por Producto' },
    { key: 'QuotationProduct.serviceType', label: 'Clasificación de Servicio', group: 'Por Producto' },
    { key: 'QuotationProduct.cost', label: 'Costo de Producto', group: 'Por Producto' },
    { key: 'QuotationProduct.quantity', label: 'Cantidad', group: 'Por Producto' },
    { key: 'QuotationProduct.price', label: 'Precio de Venta', group: 'Por Producto' },
    { key: 'QuotationProduct.paxAdults', label: 'Pasajeros Adultos', group: 'Por Producto' },
    { key: 'QuotationProduct.paxChildren', label: 'Pasajeros Niños', group: 'Por Producto' },
    { key: 'QuotationProduct.sellerCommission', label: 'Comisión Vendedor', group: 'Por Producto' },
    { key: 'QuotationProduct.ticketPrinterCommission', label: 'Comisión Tiqueteador', group: 'Por Producto' },
    { key: 'QuotationProduct.inNationality', label: 'Nacionalidad', group: 'Por Producto' },
    { key: 'QuotationProduct.service', label: 'Detalle de Servicio', group: 'Por Producto' },
    { key: 'QuotationProduct.description', label: 'Descripción Manual', group: 'Por Producto' },
    { key: 'QuotationProduct.providerDueDate', label: 'Fecha Vencimiento Proveedor', group: 'Por Producto' },
    { key: 'QuotationProduct.providerInvoice', label: 'Factura Proveedor', group: 'Por Producto' },
    { key: 'QuotationProduct.nights', label: 'Noches', group: 'Por Producto' },
    { key: 'Quotation.sellerId', label: 'Vendedor', group: 'Cabecera' },
    { key: 'Quotation.ticketPrinterId', label: 'Tiqueteador', group: 'Cabecera' },
    { key: 'Quotation.clientId', label: 'Cliente', group: 'Cabecera' },
    { key: 'Quotation.branchId', label: 'Sucursal', group: 'Cabecera' },
    { key: 'Quotation.implantId', label: 'Implant', group: 'Cabecera' },
    { key: 'Quotation.currency', label: 'Moneda', group: 'Cabecera' },
    { key: 'Quotation.exchangeRate', label: 'Tasa de Cambio', group: 'Cabecera' },
];

export default function SettingsPage() {
    const [activeTab, setActiveTab] = useState<Tab>('usuarios')
    const [loading, setLoading] = useState(true)
    const [isModalOpen, setIsModalOpen] = useState(false)
    const [submitting, setSubmitting] = useState(false)
    const [uploading, setUploading] = useState(false)
    const fileInputRef = React.useRef<HTMLInputElement>(null)

    const [currentUserRole, setCurrentUserRole] = useState<string>('')
    const isSuperAdmin = isSuperAdminRole(currentUserRole)

    useEffect(() => {
        try {
            const storedUser = localStorage.getItem('user');
            if (storedUser) {
                const parsed = JSON.parse(storedUser);
                setCurrentUserRole(parsed.role || parsed.roleName || '');
            }
        } catch (e) {}
    }, [])

    // Site Modules & Masters State
    const [siteModules, setSiteModules] = useState<any[]>([])
    const [siteMasters, setSiteMasters] = useState<any[]>([])
    const [loadingSiteModules, setLoadingSiteModules] = useState(false)

    const fetchSiteModulesAndMasters = async () => {
        setLoadingSiteModules(true)
        try {
            let roleStr = currentUserRole;
            if (!roleStr && typeof window !== 'undefined') {
                try {
                    const storedUser = localStorage.getItem('user');
                    if (storedUser) {
                        const parsed = JSON.parse(storedUser);
                        roleStr = parsed.role || parsed.roleName || '';
                    }
                } catch (e) {}
            }

            const res = await fetch(`/api/config/site-modules?userRole=${encodeURIComponent(roleStr)}`, {
                headers: { 'X-User-Role': roleStr }
            })
            if (res.ok) {
                const data = await res.json()
                setSiteModules(data.modules || [])
                setSiteMasters(data.masters || [])
            }
        } catch (err) {
            console.error('Error fetching site modules and masters:', err)
        } finally {
            setLoadingSiteModules(false)
        }
    }

    const handleToggleSiteItem = async (type: 'MENU' | 'MASTER', id: number, currentActive: boolean) => {
        try {
            let roleStr = currentUserRole;
            if (!roleStr && typeof window !== 'undefined') {
                try {
                    const storedUser = localStorage.getItem('user');
                    if (storedUser) {
                        const parsedObj = JSON.parse(storedUser);
                        roleStr = parsedObj.role || parsedObj.roleName || '';
                    }
                } catch (e) {}
            }
            const res = await fetch(`/api/config/site-modules?userRole=${encodeURIComponent(roleStr)}`, {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json',
                    'X-User-Role': roleStr
                },
                body: JSON.stringify({ type, id, active: !currentActive })
            })
            if (res.ok) {
                fetchSiteModulesAndMasters()
                if (typeof window !== 'undefined') {
                    window.dispatchEvent(new Event('menuUpdated'))
                }
            }
        } catch (err) {
            console.error('Error toggling site item:', err)
        }
    }

    const handleResetAllSiteItems = async () => {
        try {
            let roleStr = currentUserRole;
            if (!roleStr && typeof window !== 'undefined') {
                try {
                    const storedUser = localStorage.getItem('user');
                    if (storedUser) {
                        const parsedObj = JSON.parse(storedUser);
                        roleStr = parsedObj.role || parsedObj.roleName || '';
                    }
                } catch (e) {}
            }
            const res = await fetch(`/api/config/site-modules?userRole=${encodeURIComponent(roleStr)}`, {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'X-User-Role': roleStr
                },
                body: JSON.stringify({ action: 'RESET_ALL' })
            })
            if (res.ok) {
                fetchSiteModulesAndMasters()
                if (typeof window !== 'undefined') {
                    window.dispatchEvent(new Event('menuUpdated'))
                }
            }
        } catch (err) {
            console.error('Error resetting all site items:', err)
        }
    }

    const isMasterTabEnabled = (tabKey: Tab) => {
        if (tabKey === 'modulos-sitio' || tabKey === 'diagnostico') return true;
        if (!siteMasters || siteMasters.length === 0) return true;

        const tabCodeMap: Record<string, string[]> = {
            'parametros': ['systemparameter', 'parametros'],
            'usuarios': ['user', 'usuarios'],
            'sucursales': ['branch', 'sucursales', 'sucursal'],
            'implants': ['implant', 'implantes', 'implante'],
            'impuestos': ['chargeandtax', 'impuestos', 'cargos e impuesto'],
            'vendedores': ['seller', 'vendedores', 'vendedor'],
            'tiqueteadores': ['ticketprinter', 'tiqueteadores', 'tiqueteador'],
            'prestadoras': ['prestadora', 'prestadoras'],
            'clientes': ['client', 'clientes'],
            'proveedores': ['provider', 'proveedores', 'proveedor'],
            'productos': ['product', 'productos', 'producto'],
            'variables': ['mastervariable', 'variables'],
            'combos': ['combo', 'combos'],
            'logs': ['systemlog', 'logs'],
            'monedas': ['currency', 'monedas', 'moneda'],
            'equivalencias': ['equivalences', 'equivalencias'],
            'extraccion-interfaces': ['interfaces', 'extraccion-interfaces'],
            'tarjetas-credito': ['creditcard', 'tarjetas-credito'],
            'formas-pago': ['payment', 'formas-pago'],
            'paises': ['countries', 'paises'],
            'ciudades': ['cities', 'ciudades'],
            'aeropuertos': ['airports', 'aeropuertos'],
            'tipos-tiquetes': ['tickettype', 'tipos-tiquetes'],
            'tipos-proveedores': ['providertype', 'tipos-proveedores'],
            'estados-cotizacion': ['quotationstate', 'estados-cotizacion'],
            'formatos-cotizacion': ['quotationformat', 'formatos-cotizacion'],
            'resoluciones-documentos': ['documentresolution', 'resoluciones', 'resoluciones-documentos'],
            'consecutivos-transacciones': ['transactionconsecutive', 'consecutivos', 'consecutivos-transacciones'],
            'tarifa-administrativa': ['administrativefee', 'tarifa-administrativa']
        };


        const keysToMatch = tabCodeMap[tabKey] || [tabKey.toLowerCase()];
        const master = siteMasters.find(m =>
            keysToMatch.includes((m.code || '').toLowerCase()) ||
            keysToMatch.includes((m.name || '').toLowerCase())
        );

        return master ? !master.inactivo : true;
    };

    useEffect(() => {
        fetchSiteModulesAndMasters()
    }, [activeTab, currentUserRole])



    // Data states
    const [users, setUsers] = useState<any[]>([])
    const [roles, setRoles] = useState<any[]>([])
    const [branches, setBranches] = useState<any[]>([])
    const [implants, setImplants] = useState<any[]>([])
    const [taxes, setTaxes] = useState<any[]>([])
    const [allTaxes, setAllTaxes] = useState<any[]>([])
    const [sellers, setSellers] = useState<any[]>([])
    const [ticketPrinters, setTicketPrinters] = useState<any[]>([])
    const [prestadoras, setHotels] = useState<any[]>([])
    const [providers, setProviders] = useState<any[]>([])
    const [providerTypes, setProviderTypes] = useState<any[]>([])
    const [logs, setLogs] = useState<any[]>([])
    const [clients, setClients] = useState<any[]>([])
    const [products, setProducts] = useState<any[]>([])
    const [variables, setVariables] = useState<any[]>([])
    const [parameters, setParameters] = useState<any[]>([])
    const [combos, setCombos] = useState<any[]>([])
    const [currencies, setCurrencies] = useState<any[]>([])
    const [equivalences, setEquivalences] = useState<any[]>([])
    const [creditCards, setCreditCards] = useState<any[]>([])
    const [payments, setPayments] = useState<any[]>([])
    const [countries, setCountries] = useState<any[]>([])
    const [cities, setCities] = useState<any[]>([])
    const [airports, setAirports] = useState<any[]>([])
    const [ticketTypes, setTicketTypes] = useState<any[]>([])
    const [quotationStates, setQuotationStates] = useState<any[]>([])
    const [interfacesList, setInterfacesList] = useState<any[]>([])
    const [interfaceExtractRules, setInterfaceExtractRules] = useState<any[]>([])
    const [documentResolutions, setDocumentResolutions] = useState<any[]>([])
    const [transactionConsecutives, setTransactionConsecutives] = useState<any[]>([])
    const [masterList, setMasterList] = useState<any[]>([])
    const [dynamicMasterOptions, setDynamicMasterOptions] = useState<any[]>([])

    // Sub-pestaña para la categorización de Parámetros del Sistema (SQL Server, Tarifa Admin, Licencia, General)
    const [paramSubTab, setParamSubTab] = useState<'sql' | 'tarifa_admin' | 'licencia' | 'general' | 'todos'>('sql')

    const getParamCategory = (item: any): 'sql' | 'tarifa_admin' | 'licencia' | 'general' => {
        const code = (item?.code || '').toUpperCase();
        const name = (item?.name || '').toUpperCase();

        if (
            code.includes('SQL') || 
            name.includes('SQL') || 
            code.includes('ENCRIPT') || 
            name.includes('ENCRIPT') || 
            code.includes('ZEUS') || 
            name.includes('ZEUS')
        ) {
            return 'sql';
        }
        if (
            code.includes('TARIFA_ADMIN') || 
            name.includes('TARIFA ADMIN') || 
            code.includes('ADMINISTRATIV') || 
            name.includes('ADMINISTRATIV')
        ) {
            return 'tarifa_admin';
        }
        if (
            code.includes('LICENSE') || 
            name.includes('LICENCIA') || 
            code.includes('AGENCY_') || 
            name.includes('AGENCIA') ||
            code === 'AGENCY_NAME' || 
            code === 'AGENCY_NIT' ||
            name.includes('NIT')
        ) {
            return 'licencia';
        }
        return 'general';
    };

    // Pagination states
    const [currentPage, setCurrentPage] = useState(1)
    const [pageSize, setPageSize] = useState(25)
    const [totalItems, setTotalItems] = useState(0)
    const [totalPages, setTotalPages] = useState(1)

    // Diagnostic and Error states
    const [diagnosticError, setDiagnosticError] = useState<DiagnosticErrorData | null>(null);
    const [isDiagnosticModalOpen, setIsDiagnosticModalOpen] = useState(false);
    const [healthData, setHealthData] = useState<any>(null);
    const [loadingHealth, setLoadingHealth] = useState(false);

    const triggerDiagnosticError = (errData: { title?: string; message: string; endpoint?: string; statusCode?: number; details?: string; module?: string; action?: string }) => {
        setDiagnosticError({
            title: errData.title || 'Ha ocurrido un error en el proceso',
            message: errData.message,
            endpoint: errData.endpoint || TAB_CONFIG[activeTab]?.endpoint,
            statusCode: errData.statusCode || 400,
            details: errData.details,
            module: errData.module || activeTab.toUpperCase(),
            action: errData.action || (formData.id ? 'UPDATE' : 'CREATE'),
            timestamp: new Date().toLocaleString('es-CO', { dateStyle: 'short', timeStyle: 'medium' })
        });
        setIsDiagnosticModalOpen(true);
        fetch('/api/config/diagnostics', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                module: activeTab,
                description: errData.message,
                errorDetails: errData.details,
                endpoint: errData.endpoint || TAB_CONFIG[activeTab]?.endpoint,
                statusCode: errData.statusCode || 400
            })
        }).catch(() => {});
    };

    const runSystemHealthCheck = async () => {
        setLoadingHealth(true);
        try {
            const res = await fetch('/api/config/diagnostics');
            const data = await res.json();
            setHealthData(data);
        } catch (err: any) {
            triggerDiagnosticError({
                title: 'Error ejecutando autodiagnóstico',
                message: err.message,
                endpoint: '/api/config/diagnostics'
            });
        } finally {
            setLoadingHealth(false);
        }
    };

    // Copy-template feature state
    const [copyTemplateSrcId, setCopyTemplateSrcId] = useState<string>('')
    const [copyingTemplate, setCopyingTemplate] = useState(false)

    // Form states
    const [formData, setFormData] = useState<any>({})
    const [searchTerm, setSearchTerm] = useState('')
    const [debouncedSearchTerm, setDebouncedSearchTerm] = useState('')
    const [statusSort, setStatusSort] = useState<'all' | 'active-first' | 'inactive-first' | 'only-active' | 'only-inactive'>('all')

    // Debounce search term
    useEffect(() => {
        const handler = setTimeout(() => {
            setDebouncedSearchTerm(searchTerm)
        }, 300)
        return () => clearTimeout(handler)
    }, [searchTerm])

    const getFieldLabel = (key: string) => {
        const customNames = formData.templateConfig?.__customNames || {};
        if (customNames[key]) return customNames[key];

        const productGenericLabels: Record<string, string> = {
            proveedorNombre: 'Proveedor Nombre',
            proveedorNIT: 'Proveedor NIT',
            proveedorContacto: 'Proveedor Contacto',
            tarifaNeta: 'Tarifa Neta',
            tarifaNetaPago: 'Tarifa Neta Pago',
            impuestos: 'Impuestos',
            impuestosPago: 'Impuestos Pago',
            adicionalesServ: 'Adicionales',
            adicionalesServPago: 'Adicionales Pago',
            comision: 'Comisión',
            descuento: 'Descuento',
            sobrecomision: 'Sobrecomisión',
            fee: 'Fee',
            total: 'Total',
            totalPago: 'Total Pago',
            checkIn: 'Check-In',
            checkOut: 'Check-Out',
            nights: 'Noches',
            destination: 'Destino',
            quantity: 'Cantidad',
            price: 'Precio de Venta',
            cost: 'Costo',
            paxAdultos: 'Adultos',
            paxNinos: 'Niños',
            sellerCommission: 'Comisión Asesor',
            ticketPrinterCommission: 'Comisión Tiqueteador',
            inNationality: 'Nacionalidad',
            servicio: 'Detalle Servicio',
            descripcion: 'Descripción Manual',
            prestadoraNombre: 'Prestadora Nombre',
            prestadoraCategoria: 'Prestadora Categoría',
            prestadoraUbicacion: 'Prestadora Ubicación',
            productDescripcion: 'Producto Descripción',
            productTipo: 'Producto Tipo',
            productCodigo: 'Producto Código',
            productConcepto: 'Producto Concepto',
            productItinerario: 'Producto Itinerario',
            productClase: 'Producto Clase',
            productVuelo: 'Producto Vuelo'
        };

        if (productGenericLabels[key]) {
            return `Producto: ${productGenericLabels[key]}`;
        }

        const dynamicVarMatch = key.match(/^prov(\d+)_(.+)$/);
        if (dynamicVarMatch) {
            const pNum = dynamicVarMatch[1];
            const varCode = dynamicVarMatch[2];
            const v = variables.find(x => x.code === varCode);
            return `Prov ${pNum}: ${v ? v.name : varCode}`;
        }

        const vGen = variables.find(x => x.code === key);
        if (vGen) return `Producto: ${vGen.name}`;

        const prodMatch = key.match(/^(prov|proveedor)(\d+)(.+)$/);
        if (prodMatch) {
            const prefix = prodMatch[1];
            const pNum = prodMatch[2];
            const suffix = prodMatch[3];
            
            const labels: Record<string, string> = {
                Nombre: 'Nombre',
                NIT: 'NIT',
                Contacto: 'Contacto',
                TarifaNeta: 'Tarifa Neta',
                TarifaNetaPago: 'Tarifa Neta Pago',
                Impuestos: 'Impuestos',
                ImpuestosPago: 'Impuestos Pago',
                Adicionales: 'Adicionales',
                AdicionalesPago: 'Adicionales Pago',
                Comision: 'Comisión',
                Descuento: 'Descuento',
                Sobrecomision: 'Sobrecomisión',
                Fee: 'Fee',
                Total: 'Total',
                TotalPago: 'Total Pago',
                checkIn: 'Check-In',
                checkOut: 'Check-Out',
                nights: 'Noches',
                destination: 'Destino',
                quantity: 'Cantidad',
                price: 'Precio de Venta',
                cost: 'Costo',
                paxAdultos: 'Adultos',
                paxNinos: 'Niños',
                sellerCommission: 'Comisión Asesor',
                ticketPrinterCommission: 'Comisión Tiqueteador',
                inNationality: 'Nacionalidad',
                servicio: 'Detalle Servicio',
                descripcion: 'Descripción Manual',
                prestadoraNombre: 'Prestadora Nombre',
                prestadoraCategoria: 'Prestadora Categoría',
                prestadoraUbicacion: 'Prestadora Ubicación',
                productDescripcion: 'Producto Descripción',
                productTipo: 'Producto Tipo',
                productCodigo: 'Producto Código',
                productConcepto: 'Producto Concepto',
                productItinerario: 'Producto Itinerario',
                productClase: 'Producto Clase',
                productVuelo: 'Producto Vuelo'
            };
            const baseName = prefix === 'proveedor' ? `Proveedor ${pNum}` : `Prov ${pNum}`;
            return `${baseName}: ${labels[suffix] || suffix}`;
        }

        const generalLabels: Record<string, string> = {
            idCotizacion: 'ID Cotización',
            internalNumber: 'Número Interno',
            fecha: 'Fecha',
            fechaVencimiento: 'Fecha Vencimiento',
            clienteNombre: 'Cliente Nombre',
            clienteIdentificacion: 'Cliente ID / NIT',
            clienteDireccion: 'Dirección',
            clienteTelefono: 'Teléfono',
            asesor: 'Asesor',
            vendedor: 'Vendedor',
            currency: 'Moneda',
            tCambio: 'Tasa de Cambio',
            comisionTotalPercentage: 'Comisión Total (%)',
            comisionFreelancePercentage: 'Comisión Freelance (%)',
            comisionPropiaPercentage: 'Comisión Propia (%)',
            comisionUtilidadPercentage: 'Comisión Utilidad (%)',
            comisionFreelanceValue: 'Comisión Freelance ($)',
            comisionPropiaValue: 'Comisión Propia ($)',
            costoTotal: 'Resumen: Costo Total',
            valorBase: 'Resumen: Valor Base',
            utilidad: 'Resumen: Utilidad',
            totalAmount: 'Resumen: Valor Facturar / Total',
            state: 'Estado de Cotización',
            descripcionPlan: 'Descripción Plan',
            fechasViaje: 'Fechas Viaje',
            logo: 'Celda Logo',
            observaciones: 'Observaciones',
            pasajeros: 'Pasajeros',
            totalAdultos: 'Total Adultos',
            totalNinos: 'Total Niños',
            destinoCabecera: 'Destino (Cabecera)',
            fechaInicioCabecera: 'Fecha Inicio (Cabecera)',
            fechaFinCabecera: 'Fecha Fin (Cabecera)',
            pasajeroCabecera: 'Pasajero Principal (Cabecera)',
            paxAdultosCabecera: 'Cantidad Adultos (Cabecera)',
            paxNinosCabecera: 'Cantidad Niños (Cabecera)',
            reservacionCabecera: 'Reservación / Localizador (Cabecera)',
            descripcionManualCabecera: 'Descripción Manual (Cabecera)',
            tarifaNeta: 'Total: Tarifa Neta',
            tarifaNetaPago: 'Total: Tarifa Neta Pago',
            impuestos: 'Total: Impuestos',
            impuestosPago: 'Total: Impuestos Pago',
            adicionalesServ: 'Total: Adicionales',
            adicionalesServPago: 'Total: Adicionales Pago',
            comision: 'Total: Comisión',
            descuento: 'Total: Descuento',
            sobrecomision: 'Total: Sobrecomisión',
            fee: 'Total: Fee',
            total: 'Total: Total',
            totalPago: 'Total: Total Pago',
            baseComisionable: 'Base Comisión',
            comisionAsesor: 'Comisión Asesor'
        };

        return generalLabels[key] || key;
    };

    const renderMappingOptions = () => {
        const headerFields = [
            { key: 'idCotizacion', label: 'ID Cotización' },
            { key: 'internalNumber', label: 'Número Interno' },
            { key: 'fecha', label: 'Fecha' },
            { key: 'fechaVencimiento', label: 'Fecha Vencimiento' },
            { key: 'clienteNombre', label: 'Cliente Nombre' },
            { key: 'clienteIdentificacion', label: 'Cliente ID / NIT' },
            { key: 'clienteDireccion', label: 'Dirección' },
            { key: 'clienteTelefono', label: 'Teléfono' },
            { key: 'asesor', label: 'Asesor' },
            { key: 'vendedor', label: 'Vendedor' },
            { key: 'currency', label: 'Moneda' },
            { key: 'tCambio', label: 'Tasa de Cambio' },
            { key: 'comisionTotalPercentage', label: 'Comisión Total (%)' },
            { key: 'comisionFreelancePercentage', label: 'Comisión Freelance (%)' },
            { key: 'comisionPropiaPercentage', label: 'Comisión Propia (%)' },
            { key: 'comisionUtilidadPercentage', label: 'Comisión Utilidad (%)' },
            { key: 'comisionFreelanceValue', label: 'Comisión Freelance ($)' },
            { key: 'comisionPropiaValue', label: 'Comisión Propia ($)' },
            { key: 'costoTotal', label: 'Resumen: Costo Total' },
            { key: 'valorBase', label: 'Resumen: Valor Base' },
            { key: 'utilidad', label: 'Resumen: Utilidad' },
            { key: 'totalAmount', label: 'Resumen: Valor Facturar / Total' },
            { key: 'state', label: 'Estado de Cotización' },
            { key: 'descripcionPlan', label: 'Descripción Plan' },
            { key: 'fechasViaje', label: 'Fechas Viaje' },
            { key: 'logo', label: 'Celda Logo' },
            { key: 'observaciones', label: 'Observaciones' },
            { key: 'pasajeros', label: 'Pasajeros' },
            { key: 'totalAdultos', label: 'Total Adultos' },
            { key: 'totalNinos', label: 'Total Niños' },
            { key: 'destinoCabecera', label: 'Destino (Cabecera)' },
            { key: 'fechaInicioCabecera', label: 'Fecha Inicio (Cabecera)' },
            { key: 'fechaFinCabecera', label: 'Fecha Fin (Cabecera)' },
            { key: 'pasajeroCabecera', label: 'Pasajero Principal (Cabecera)' },
            { key: 'paxAdultosCabecera', label: 'Cantidad Adultos (Cabecera)' },
            { key: 'paxNinosCabecera', label: 'Cantidad Niños (Cabecera)' },
            { key: 'reservacionCabecera', label: 'Reservación / Localizador (Cabecera)' },
            { key: 'descripcionManualCabecera', label: 'Descripción Manual (Cabecera)' },
            { key: 'tarifaNeta', label: 'Total: Tarifa Neta' },
            { key: 'tarifaNetaPago', label: 'Total: Tarifa Neta Pago' },
            { key: 'impuestos', label: 'Total: Impuestos' },
            { key: 'impuestosPago', label: 'Total: Impuestos Pago' },
            { key: 'adicionalesServ', label: 'Total: Adicionales' },
            { key: 'adicionalesServPago', label: 'Total: Adicionales Pago' },
            { key: 'comision', label: 'Total: Comisión' },
            { key: 'descuento', label: 'Total: Descuento' },
            { key: 'sobrecomision', label: 'Total: Sobrecomisión' },
            { key: 'fee', label: 'Total: Fee' },
            { key: 'total', label: 'Total: Total' },
            { key: 'totalPago', label: 'Total: Total Pago' },
            { key: 'baseComisionable', label: 'Base Comisión' },
            { key: 'comisionAsesor', label: 'Comisión Asesor' }
        ];

        const baseProductFields = [
            { keySuffix: 'Nombre', keyPrefix: 'proveedor', labelSuffix: 'Nombre', labelPrefix: 'Proveedor' },
            { keySuffix: 'NIT', keyPrefix: 'proveedor', labelSuffix: 'NIT', labelPrefix: 'Proveedor' },
            { keySuffix: 'Contacto', keyPrefix: 'proveedor', labelSuffix: 'Contacto', labelPrefix: 'Proveedor' },
            { keySuffix: 'TarifaNeta', keyPrefix: 'prov', labelSuffix: 'Tarifa Neta', labelPrefix: 'Prov' },
            { keySuffix: 'TarifaNetaPago', keyPrefix: 'prov', labelSuffix: 'Tarifa Neta Pago', labelPrefix: 'Prov' },
            { keySuffix: 'Impuestos', keyPrefix: 'prov', labelSuffix: 'Impuestos', labelPrefix: 'Prov' },
            { keySuffix: 'ImpuestosPago', keyPrefix: 'prov', labelSuffix: 'Impuestos Pago', labelPrefix: 'Prov' },
            { keySuffix: 'Adicionales', keyPrefix: 'prov', labelSuffix: 'Adicionales', labelPrefix: 'Prov' },
            { keySuffix: 'AdicionalesPago', keyPrefix: 'prov', labelSuffix: 'Adicionales Pago', labelPrefix: 'Prov' },
            { keySuffix: 'Comision', keyPrefix: 'prov', labelSuffix: 'Comisión', labelPrefix: 'Prov' },
            { keySuffix: 'Descuento', keyPrefix: 'prov', labelSuffix: 'Descuento', labelPrefix: 'Prov' },
            { keySuffix: 'Sobrecomision', keyPrefix: 'prov', labelSuffix: 'Sobrecomisión', labelPrefix: 'Prov' },
            { keySuffix: 'Fee', keyPrefix: 'prov', labelSuffix: 'Fee', labelPrefix: 'Prov' },
            { keySuffix: 'Total', keyPrefix: 'prov', labelSuffix: 'Total', labelPrefix: 'Prov' },
            { keySuffix: 'TotalPago', keyPrefix: 'prov', labelSuffix: 'Total Pago', labelPrefix: 'Prov' },
            { keySuffix: 'checkIn', keyPrefix: 'prov', labelSuffix: 'Check-In', labelPrefix: 'Prov' },
            { keySuffix: 'checkOut', keyPrefix: 'prov', labelSuffix: 'Check-Out', labelPrefix: 'Prov' },
            { keySuffix: 'nights', keyPrefix: 'prov', labelSuffix: 'Noches', labelPrefix: 'Prov' },
            { keySuffix: 'destination', keyPrefix: 'prov', labelSuffix: 'Destino', labelPrefix: 'Prov' },
            { keySuffix: 'quantity', keyPrefix: 'prov', labelSuffix: 'Cantidad', labelPrefix: 'Prov' },
            { keySuffix: 'price', keyPrefix: 'prov', labelSuffix: 'Precio de Venta', labelPrefix: 'Prov' },
            { keySuffix: 'cost', keyPrefix: 'prov', labelSuffix: 'Costo', labelPrefix: 'Prov' },
            { keySuffix: 'paxAdultos', keyPrefix: 'prov', labelSuffix: 'Adultos', labelPrefix: 'Prov' },
            { keySuffix: 'paxNinos', keyPrefix: 'prov', labelSuffix: 'Niños', labelPrefix: 'Prov' },
            { keySuffix: 'sellerCommission', keyPrefix: 'prov', labelSuffix: 'Comisión Asesor', labelPrefix: 'Prov' },
            { keySuffix: 'ticketPrinterCommission', keyPrefix: 'prov', labelSuffix: 'Comisión Tiqueteador', labelPrefix: 'Prov' },
            { keySuffix: 'inNationality', keyPrefix: 'prov', labelSuffix: 'Nacionalidad', labelPrefix: 'Prov' },
            { keySuffix: 'servicio', keyPrefix: 'prov', labelSuffix: 'Detalle Servicio', labelPrefix: 'Prov' },
            { keySuffix: 'descripcion', keyPrefix: 'prov', labelSuffix: 'Descripción Manual', labelPrefix: 'Prov' },
            { keySuffix: 'prestadoraNombre', keyPrefix: 'prov', labelSuffix: 'Prestadora Nombre', labelPrefix: 'Prov' },
            { keySuffix: 'prestadoraCategoria', keyPrefix: 'prov', labelSuffix: 'Prestadora Categoría', labelPrefix: 'Prov' },
            { keySuffix: 'prestadoraUbicacion', keyPrefix: 'prov', labelSuffix: 'Prestadora Ubicación', labelPrefix: 'Prov' },
            { keySuffix: 'productDescripcion', keyPrefix: 'prov', labelSuffix: 'Producto Descripción', labelPrefix: 'Prov' },
            { keySuffix: 'productTipo', keyPrefix: 'prov', labelSuffix: 'Producto Tipo', labelPrefix: 'Prov' },
            { keySuffix: 'productCodigo', keyPrefix: 'prov', labelSuffix: 'Producto Código', labelPrefix: 'Prov' },
            { keySuffix: 'productConcepto', keyPrefix: 'prov', labelSuffix: 'Producto Concepto', labelPrefix: 'Prov' },
            { keySuffix: 'productItinerario', keyPrefix: 'prov', labelSuffix: 'Producto Itinerario', labelPrefix: 'Prov' },
            { keySuffix: 'productClase', keyPrefix: 'prov', labelSuffix: 'Producto Clase', labelPrefix: 'Prov' },
            { keySuffix: 'productVuelo', keyPrefix: 'prov', labelSuffix: 'Producto Vuelo', labelPrefix: 'Prov' },
        ];

        const genericProductFields = [
            { key: 'proveedorNombre', label: 'Proveedor Nombre' },
            { key: 'proveedorNIT', label: 'Proveedor NIT' },
            { key: 'proveedorContacto', label: 'Proveedor Contacto' },
            { key: 'tarifaNeta', label: 'Tarifa Neta' },
            { key: 'tarifaNetaPago', label: 'Tarifa Neta Pago' },
            { key: 'impuestos', label: 'Impuestos' },
            { key: 'impuestosPago', label: 'Impuestos Pago' },
            { key: 'adicionalesServ', label: 'Adicionales' },
            { key: 'adicionalesServPago', label: 'Adicionales Pago' },
            { key: 'comision', label: 'Comisión' },
            { key: 'descuento', label: 'Descuento' },
            { key: 'sobrecomision', label: 'Sobrecomisión' },
            { key: 'fee', label: 'Fee' },
            { key: 'total', label: 'Total' },
            { key: 'totalPago', label: 'Total Pago' },
            { key: 'checkIn', label: 'Check-In' },
            { key: 'checkOut', label: 'Check-Out' },
            { key: 'nights', label: 'Noches' },
            { key: 'destination', label: 'Destino' },
            { key: 'quantity', label: 'Cantidad' },
            { key: 'price', label: 'Precio de Venta' },
            { key: 'cost', label: 'Costo' },
            { key: 'paxAdultos', label: 'Adultos' },
            { key: 'paxNinos', label: 'Niños' },
            { key: 'sellerCommission', label: 'Comisión Asesor' },
            { key: 'ticketPrinterCommission', label: 'Comisión Tiqueteador' },
            { key: 'inNationality', label: 'Nacionalidad' },
            { key: 'servicio', label: 'Detalle Servicio' },
            { key: 'descripcion', label: 'Descripción Manual' },
            { key: 'prestadoraNombre', label: 'Prestadora Nombre' },
            { key: 'prestadoraCategoria', label: 'Prestadora Categoría' },
            { key: 'prestadoraUbicacion', label: 'Prestadora Ubicación' },
            { key: 'productDescripcion', label: 'Producto Descripción' },
            { key: 'productTipo', label: 'Producto Tipo' },
            { key: 'productCodigo', label: 'Producto Código' },
            { key: 'productConcepto', label: 'Producto Concepto' },
            { key: 'productItinerario', label: 'Producto Itinerario' },
            { key: 'productClase', label: 'Producto Clase' },
            { key: 'productVuelo', label: 'Producto Vuelo' }
        ];

        // Ordenamos alfabéticamente por etiqueta
        const sortedHeaderFields = [...headerFields].sort((a, b) => a.label.localeCompare(b.label));
        const sortedGenericProductFields = [...genericProductFields].sort((a, b) => a.label.localeCompare(b.label));
        const sortedBaseProductFields = [...baseProductFields].sort((a, b) => a.labelSuffix.localeCompare(b.labelSuffix));

        return (
            <>
                <optgroup label="Campos Generales (Cabecera)">
                    {sortedHeaderFields.map(f => (
                        <option key={f.key} value={`${f.key}|${f.label}`}>{f.label}</option>
                    ))}
                </optgroup>

                <optgroup label="Campos de Producto (Dinámico / Fila Repetida)">
                    {sortedGenericProductFields.map(f => (
                        <option key={f.key} value={`${f.key}|${f.label}`}>{f.label}</option>
                    ))}
                    {variables && [...variables].sort((a: any, b: any) => a.name.localeCompare(b.name)).map((v: any) => (
                        <option key={v.code} value={`${v.code}|Producto: ${v.name}`}>{v.name}</option>
                    ))}
                </optgroup>

                {[1, 2, 3, 4, 5, 6, 7, 8, 9].map(pNum => (
                    <optgroup key={pNum} label={`Producto ${pNum} (Estático)`}>
                        {sortedBaseProductFields.map(f => {
                            const key = `${f.keyPrefix}${pNum}${f.keySuffix}`;
                            const label = `${f.labelPrefix} ${pNum}: ${f.labelSuffix}`;
                            return (
                                <option key={key} value={`${key}|${label}`}>{f.labelSuffix}</option>
                            );
                        })}
                        {variables && [...variables].sort((a: any, b: any) => a.name.localeCompare(b.name)).map((v: any) => {
                            const key = `prov${pNum}_${v.code}`;
                            const label = `Prov ${pNum}: ${v.name}`;
                            return (
                                <option key={key} value={`${key}|${label}`}>{v.name}</option>
                            );
                        })}
                    </optgroup>
                ))}

                <optgroup label="Personalizado">
                    <option value="custom|Personalizado (Ingresar manualmente)">Personalizado (Ingresar manualmente)</option>
                </optgroup>
            </>
        );
    };

    // Reset pagination and search on tab change
    useEffect(() => {
        setCurrentPage(1)
        setSearchTerm('')
        setDebouncedSearchTerm('')
    }, [activeTab])

    // Load initial metadata once on mount
    useEffect(() => {
        fetchMetadata()
    }, [])

    // Load active tab data whenever pagination/search dependencies change
    useEffect(() => {
        fetchActiveTabData(activeTab, currentPage, pageSize, debouncedSearchTerm)
        fetchLookupData(activeTab)
    }, [activeTab, currentPage, pageSize, debouncedSearchTerm])

    const fetchMetadata = async () => {
        try {
            let userRoleStr = '';
            try {
                const storedUser = localStorage.getItem('user');
                if (storedUser) userRoleStr = JSON.parse(storedUser).role || '';
            } catch (e) {}

            const [resInterfaces, resMasters, resRoles] = await Promise.all([
                fetch('/api/config/interfaces').then(res => res.json()).catch(() => []),
                fetch('/api/config/masters').then(res => res.json()).catch(() => []),
                fetch(`/api/config/roles?userRole=${encodeURIComponent(userRoleStr)}`).then(res => res.json()).catch(() => []),
            ]);
            setInterfacesList(Array.isArray(resInterfaces) ? resInterfaces : []);
            setMasterList(Array.isArray(resMasters) ? resMasters : []);
            setRoles(Array.isArray(resRoles) ? resRoles : []);
        } catch (error) {
            console.error('Error fetching metadata:', error);
        }
    }

    const fetchLookupData = async (tab: Tab) => {
        const safeFetch = (url: string) => fetch(url).then(res => (res.ok ? res.json() : [])).catch(() => []);
        try {
            if (tab === 'aeropuertos') {
                const res = await safeFetch('/api/config/cities');
                setCities(Array.isArray(res) ? res : []);
            } else if (tab === 'prestadoras' || tab === 'proveedores') {
                const [pRes, ptRes] = await Promise.all([
                    safeFetch('/api/providers'),
                    safeFetch('/api/provider-types')
                ]);
                setProviders(Array.isArray(pRes) ? pRes : []);
                setProviderTypes(Array.isArray(ptRes) ? ptRes : []);
            } else if (tab === 'ciudades') {
                const res = await safeFetch('/api/config/countries');
                setCountries(Array.isArray(res) ? res : []);
            } else if (tab === 'paises') {
                const res = await safeFetch('/api/config/currencies');
                setCurrencies(Array.isArray(res) ? res : []);
            } else if (tab === 'productos') {
                const [ttRes, taxRes] = await Promise.all([
                    safeFetch('/api/config/ticket-types'),
                    safeFetch('/api/config/taxes')
                ]);
                setTicketTypes(Array.isArray(ttRes) ? ttRes : (ttRes?.data || []));
                const list = Array.isArray(taxRes) ? taxRes : (taxRes?.data || []);
                setTaxes(list);
                setAllTaxes(list);
            } else if (tab === 'combos') {
                const [prodRes, taxRes, provRes, prestRes] = await Promise.all([
                    safeFetch('/api/products'),
                    safeFetch('/api/config/taxes'),
                    safeFetch('/api/providers'),
                    safeFetch('/api/config/prestadoras')
                ]);
                setProducts(Array.isArray(prodRes) ? prodRes : (prodRes?.data || []));
                const list = Array.isArray(taxRes) ? taxRes : (taxRes?.data || []);
                setTaxes(list);
                setAllTaxes(list);
                setProviders(Array.isArray(provRes) ? provRes : []);
                setHotels(Array.isArray(prestRes) ? prestRes : []);
            } else if (tab === 'impuestos') {
                const taxRes = await safeFetch('/api/config/taxes');
                const list = Array.isArray(taxRes) ? taxRes : (taxRes?.data || []);
                setAllTaxes(list);
            } else if (tab === 'usuarios' || tab === 'resoluciones-documentos' || tab === 'consecutivos-transacciones') {
                const [b, i, tp] = await Promise.all([
                    safeFetch('/api/config/branches'),
                    safeFetch('/api/config/implants'),
                    safeFetch('/api/config/ticket-printers')
                ]);
                setBranches(Array.isArray(b) ? b : []);
                setImplants(Array.isArray(i) ? i : []);
                setTicketPrinters(Array.isArray(tp) ? tp : []);
            } else if (tab === 'clientes') {
                const [vRes, sRes] = await Promise.all([
                    safeFetch('/api/config/variables'),
                    safeFetch('/api/config/sellers')
                ]);
                setVariables(Array.isArray(vRes) ? vRes : []);
                setSellers(Array.isArray(sRes) ? sRes : []);
            } else if (tab === 'sucursales' || tab === 'implants' || tab === 'extraccion-interfaces') {
                const res = await safeFetch('/api/config/variables');
                setVariables(Array.isArray(res) ? res : []);
            } else if (tab === 'parametros') {
                const res = await safeFetch('/api/products');
                setProducts(Array.isArray(res) ? res : (res?.data || []));
            }
        } catch (err) {
            console.error("Error fetching lookup data:", err);
        }
    }

    const setTabListState = (tab: Tab, data: any[]) => {
        switch (tab) {
            case 'usuarios': setUsers(data); break;
            case 'sucursales': setBranches(data); break;
            case 'implants': setImplants(data); break;
            case 'impuestos': setTaxes(data); break;
            case 'vendedores': setSellers(data); break;
            case 'tiqueteadores': setTicketPrinters(data); break;
            case 'prestadoras': setHotels(data); break;
            case 'proveedores': setProviders(data); break;
            case 'clientes': setClients(data); break;
            case 'productos': setProducts(data); break;
            case 'variables': setVariables(data); break;
            case 'parametros': setParameters(data); break;
            case 'monedas': setCurrencies(data); break;
            case 'equivalencias': setEquivalences(data); break;
            case 'extraccion-interfaces': setInterfaceExtractRules(data); break;
            case 'resoluciones-documentos': setDocumentResolutions(data); break;
            case 'consecutivos-transacciones': setTransactionConsecutives(data); break;
            case 'tarjetas-credito': setCreditCards(data); break;
            case 'formas-pago': setPayments(data); break;
            case 'paises': setCountries(data); break;
            case 'ciudades': setCities(data); break;
            case 'aeropuertos': setAirports(data); break;
            case 'tipos-tiquetes': setTicketTypes(data); break;
            case 'tipos-proveedores': setProviderTypes(data); break;
            case 'estados-cotizacion': setQuotationStates(data); break;
            case 'combos': setCombos(data); break;
            case 'logs': setLogs(data); break;
        }
    }

    const fetchActiveTabData = async (tab: Tab, pageNum: number, limitNum: number, searchVal: string) => {
        setLoading(true)
        try {
            const endpoint = TAB_CONFIG[tab]?.endpoint || '';
            if (!endpoint) return;

            const queryParams = new URLSearchParams();
            queryParams.append('page', pageNum.toString());
            queryParams.append('limit', limitNum.toString());
            queryParams.append('includeInactive', 'true');
            if (searchVal) {
                queryParams.append('search', searchVal);
            }

            const res = await fetch(`${endpoint}?${queryParams.toString()}`);
            const json = await res.json();

            if (json && typeof json === 'object' && 'data' in json) {
                setTotalItems(json.total || 0);
                setTotalPages(json.totalPages || 1);
                setTabListState(tab, json.data);
            } else {
                const list = Array.isArray(json) ? json : [];
                setTotalItems(list.length);
                setTotalPages(1);
                setTabListState(tab, list);
            }
        } catch (error) {
            console.error('Error fetching active tab data:', error);
            setTabListState(tab, []);
        } finally {
            setLoading(false);
        }
    }

    const fetchData = async () => {
        await fetchActiveTabData(activeTab, currentPage, pageSize, debouncedSearchTerm);
    }

    useEffect(() => {
        if (formData.id_master && activeTab === 'equivalencias') {
            const selectedMaster = masterList.find((m: any) => m.id == formData.id_master);
            if (selectedMaster && selectedMaster.code) {
                fetch(`/api/config/masters/dynamic?table=${selectedMaster.code}`)
                    .then(res => res.json())
                    .then(data => {
                        if (Array.isArray(data)) {
                            setDynamicMasterOptions(data);
                        } else {
                            setDynamicMasterOptions([]);
                        }
                    })
                    .catch(() => setDynamicMasterOptions([]));
            } else {
                setDynamicMasterOptions([]);
            }
        } else {
            setDynamicMasterOptions([]);
        }
    }, [formData.id_master, activeTab, masterList]);

    const toggleMasterStatus = async (item: any) => {
        if (!item || !item.id) return;
        const isAct = item.isActive !== false && item.inactive !== true && item.is_active !== false && item.inactivo !== true;
        const newStatus = !isAct;
        const endpoint = TAB_CONFIG[activeTab]?.endpoint || '';
        if (!endpoint) return;

        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');
        try {
            const payload = {
                ...item,
                isActive: newStatus,
                inactive: !newStatus,
                is_active: newStatus
            };
            const res = await fetch(endpoint, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: JSON.stringify(payload)
            });
            const resData = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(resData.error || resData.message || 'Error al cambiar estado');
            await fetchData();
        } catch (err: any) {
            alert(err.message || 'Error al cambiar estado');
        }
    };

    const renderMasterStatusTd = (item: any) => {
        const isAct = item?.isActive !== false && item?.inactive !== true && item?.is_active !== false && item?.inactivo !== true;
        return (
            <td className="px-8 py-6">
                <button
                    type="button"
                    onClick={() => toggleMasterStatus(item)}
                    title="Haga clic aquí para cambiar de Activo a Inactivo y viceversa"
                    className={cn(
                        "px-3 py-1 text-[10px] font-black rounded-lg uppercase tracking-wider border transition-all cursor-pointer hover:scale-105 active:scale-95 shadow-sm flex items-center gap-1.5",
                        isAct
                            ? "bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100 dark:bg-emerald-950/40 dark:text-emerald-400 dark:border-emerald-800"
                            : "bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100 dark:bg-rose-950/40 dark:text-rose-400 dark:border-rose-800"
                    )}
                >
                    <span className={cn("w-1.5 h-1.5 rounded-full", isAct ? "bg-emerald-500 animate-pulse" : "bg-rose-500")} />
                    {isAct ? 'Activo' : 'Inactivo'}
                </button>
            </td>
        );
    };

    const isItemActive = (item: any) => {
        if (!item || typeof item !== 'object') return true;
        if (item.isActive === false || item.isActive === 0 || item.isActive === 'false') return false;
        if (item.is_active === false || item.is_active === 0 || item.is_active === 'false') return false;
        if (item.active === false || item.active === 0 || item.active === 'false') return false;
        if (item.activo === false || item.activo === 0 || item.activo === 'false') return false;
        if (item.inactive === true || item.inactive === 1 || item.inactive === 'true') return false;
        if (item.inactivo === true || item.inactivo === 1 || item.inactivo === 'true') return false;
        return true;
    };

    const sortAndFilterMasterItems = <T extends any>(items: T[]): T[] => {
        if (!Array.isArray(items)) return [];
        let result = [...items];

        if (statusSort === 'only-active') {
            result = result.filter(item => isItemActive(item));
        } else if (statusSort === 'only-inactive') {
            result = result.filter(item => !isItemActive(item));
        }

        if (statusSort === 'active-first') {
            result.sort((a, b) => {
                const aAct = isItemActive(a) ? 1 : 0;
                const bAct = isItemActive(b) ? 1 : 0;
                return bAct - aAct;
            });
        } else if (statusSort === 'inactive-first') {
            result.sort((a, b) => {
                const aAct = isItemActive(a) ? 1 : 0;
                const bAct = isItemActive(b) ? 1 : 0;
                return aAct - bAct;
            });
        }

        return result;
    };

    const cycleStatusSort = () => {
        setStatusSort(prev => {
            if (prev === 'all') return 'active-first';
            if (prev === 'active-first') return 'inactive-first';
            if (prev === 'inactive-first') return 'only-active';
            if (prev === 'only-active') return 'only-inactive';
            return 'all';
        });
    };

    const renderEstadoTh = () => (
        <th
            onClick={cycleStatusSort}
            title="Haga clic para ordenar o filtrar por Estado (Activos primero, Inactivos primero, Solo Activos, Solo Inactivos, Todos)"
            className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest cursor-pointer select-none hover:text-blue-600 dark:hover:text-blue-400 transition-colors group"
        >
            <div className="flex items-center gap-1.5">
                <span>Estado</span>
                {statusSort === 'active-first' && (
                    <span className="px-1.5 py-0.5 text-[9px] bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400 rounded-md font-extrabold flex items-center gap-1 normal-case tracking-normal">
                        🟢 Activos ⬇
                    </span>
                )}
                {statusSort === 'inactive-first' && (
                    <span className="px-1.5 py-0.5 text-[9px] bg-rose-100 text-rose-700 dark:bg-rose-950/60 dark:text-rose-400 rounded-md font-extrabold flex items-center gap-1 normal-case tracking-normal">
                        🔴 Inactivos ⬇
                    </span>
                )}
                {statusSort === 'only-active' && (
                    <span className="px-1.5 py-0.5 text-[9px] bg-emerald-600 text-white rounded-md font-extrabold flex items-center gap-1 normal-case tracking-normal">
                        Solo Activos
                    </span>
                )}
                {statusSort === 'only-inactive' && (
                    <span className="px-1.5 py-0.5 text-[9px] bg-rose-600 text-white rounded-md font-extrabold flex items-center gap-1 normal-case tracking-normal">
                        Solo Inactivos
                    </span>
                )}
                {statusSort === 'all' && (
                    <ArrowUpDown className="w-3.5 h-3.5 opacity-40 group-hover:opacity-100 transition-opacity" />
                )}
            </div>
        </th>
    );

    const handleOpenModal = (item?: any) => {
        fetchLookupData(activeTab);
        if (item) {
            if (activeTab === 'combos' && item.products) {
                // Normalizar los tipos de datos de los productos del combo al cargar para editar
                const normalizedProducts = item.products.map((cp: any) => ({
                    ...cp,
                    productId: cp.productId ? parseInt(cp.productId) : '',
                    quantity: parseInt(cp.quantity) || 1,
                    price: parseFloat(cp.price) || 0,
                    cost: parseFloat(cp.cost) || 0,
                    providerId: cp.providerId ? parseInt(cp.providerId) : null,
                    prestadoraId: cp.prestadoraId ? parseInt(cp.prestadoraId) : null,
                    mainTaxId: cp.mainTaxId ? parseInt(cp.mainTaxId) : null,
                    appliedTaxes: (cp.appliedTaxes || []).map((at: any) => ({
                        chargeAndTaxId: parseInt(at.chargeAndTaxId),
                        amount: parseFloat(at.amount) || 0,
                        isMain: at.isMain || false,
                    })),
                    inNationality: cp.inNationality || 1
                }));
                setFormData({ ...item, products: normalizedProducts });
            } else if (activeTab === 'clientes') {
                let mandatoryVars = item.mandatoryVariables;
                if (typeof mandatoryVars === 'string') {
                    try {
                        mandatoryVars = JSON.parse(mandatoryVars);
                    } catch (e) {
                        mandatoryVars = { quotation: [], invoice: [] };
                    }
                }
                let quotationVars: any[] = [];
                let invoiceVars: any[] = [];
                if (Array.isArray(mandatoryVars)) {
                    quotationVars = mandatoryVars;
                    invoiceVars = [];
                } else if (mandatoryVars && typeof mandatoryVars === 'object') {
                    quotationVars = Array.isArray(mandatoryVars.quotation) ? mandatoryVars.quotation : (Array.isArray(mandatoryVars.quotations) ? mandatoryVars.quotations : []);
                    invoiceVars = Array.isArray(mandatoryVars.invoice) ? mandatoryVars.invoice : (Array.isArray(mandatoryVars.invoices) ? mandatoryVars.invoices : []);
                }
                setFormData({ ...item, sellerId: item.sellerId ? item.sellerId.toString() : '', mandatoryVariables: { quotation: quotationVars, invoice: invoiceVars } })
            } else if (activeTab === 'productos') {
                let mandatory = item.mandatoryFields;
                if (typeof mandatory === 'string') {
                    try {
                        mandatory = JSON.parse(mandatory);
                    } catch (e) {
                        mandatory = [];
                    }
                }
                if (!Array.isArray(mandatory)) {
                    mandatory = [];
                }
                let tIds = item.taxIds;
                if (typeof tIds === 'string') {
                    try { tIds = JSON.parse(tIds); } catch (e) { tIds = []; }
                }
                if (!Array.isArray(tIds)) tIds = [];
                setFormData({
                    ...item,
                    billingConcept: item.billingConcept || '',
                    serviceType: item.serviceType || '',
                    mandatoryFields: mandatory,
                    taxIds: tIds
                })
            } else if (activeTab === 'impuestos') {
                setFormData({ ...item, orden: item.orden ?? 0 })
            } else {
                setFormData({ ...item })
            }

        } else {
            if (activeTab === 'usuarios') {
                setFormData({ name: '', email: '', password: '', roleId: roles[0]?.id || '', branchId: '', implantId: '', ticketPrinterId: '', canEditReports: false })
            } else if (activeTab === 'impuestos') {
                setFormData({ code: '', name: '', type: 'TAX', valueType: 'PERCENTAGE', value: '', isEditable: true, orden: 0 })
            } else if (activeTab === 'productos') {
                setFormData({ code: '', type: 'Servicio', description: '', basePrice: '', cost: '', billingConcept: '', serviceType: '', mandatoryFields: [], taxIds: [] })
            } else if (activeTab === 'vendedores' || activeTab === 'tiqueteadores') {
                setFormData({ code: '', name: '', email: '' })
            } else if (activeTab === 'prestadoras') {
                setFormData({ code: '', name: '', category: '', location: '', providerId: '', type: '' })
            } else if (activeTab === 'clientes') {
                setFormData({ name: '', document: '', contactInfo: '', address: '', sellerId: '', mandatoryVariables: { quotation: [], invoice: [] } })
            } else if (activeTab === 'proveedores') {
                setFormData({ code: '', name: '', contactInfo: '', providerTypeId: '', airlineCode: '', sigla: '' })
            } else if (activeTab === 'tipos-proveedores') {
                setFormData({ code: '', name: '', isAirline: false, active: true })
            } else if (activeTab === 'variables') {
                setFormData({ code: '', name: '' })
            } else if (activeTab === 'monedas') {
                setFormData({ code: '', name: '', exchangeRate: '', decimals: 2 })
            } else if (activeTab === 'combos') {
                setFormData({ code: '', name: '', cupos: 0, currencyId: '', products: [] })
            } else if (activeTab === 'equivalencias') {
                setFormData({ id_interfaces: '', id_master: '', cd_maestro: '', cd_codigo: '', cd_codigoInte: '' })
            } else if (activeTab === 'extraccion-interfaces') {
                if (item) {
                    setFormData({
                        id: item.id,
                        interfaceId: item.interfaceId?.toString() || '',
                        fieldCode: item.fieldCode || '',
                        fieldName: item.fieldName || '',
                        prefix: item.prefix || '',
                        delimiter: item.delimiter || '-',
                        isActive: item.isActive !== undefined ? item.isActive : true
                    })
                } else {
                    setFormData({
                        interfaceId: '2',
                        fieldCode: '',
                        fieldName: '',
                        prefix: '',
                        delimiter: '-',
                        isActive: true
                    })
                }
            } else if (activeTab === 'tarjetas-credito') {
                setFormData({ code: '', name: '', type: 'CC', inactive: false })
            } else if (activeTab === 'formas-pago') {
                setFormData({ code: '', name: '', iscash: false, iscredit: false, inactive: false })
            } else if (activeTab === 'paises') {
                setFormData({ code: '', name: '', dane: '', region: '', prefix: '', curencyId: '' })
            } else if (activeTab === 'ciudades') {
                setFormData({ code: '', name: '', countriesId: '', statecode: '', iata: '' })
            } else if (activeTab === 'aeropuertos') {
                setFormData({ code: '', name: '', citiesId: '' })
            } else if (activeTab === 'tipos-tiquetes') {
                setFormData({ code: '', name: '', description: '', isActive: true })
            } else {
                setFormData({ code: '', name: '' })
            }
        }
        setIsModalOpen(true)
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setSubmitting(true)

        let endpoint = TAB_CONFIG[activeTab]?.endpoint || '';
        if (activeTab === 'combos' && formData.id) {
            endpoint = `/api/combos/${formData.id}`;
        }

        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}')

        try {
            const res = await fetch(endpoint, {
                method: formData.id ? 'PUT' : 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: JSON.stringify(formData)
            })

            const resData = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(resData.error || resData.message || 'Error al guardar el registro');

            await fetchData()
            setIsModalOpen(false)
        } catch (err: any) {
            triggerDiagnosticError({
                title: `Error al guardar ${TAB_CONFIG[activeTab]?.singular || activeTab}`,
                message: err.message || 'Error procesando la solicitud',
                endpoint,
                statusCode: 400,
                details: err.stack || err.details
            });
        } finally {
            setSubmitting(false)
        }
    }

    const handleDuplicateCombo = async (combo: any) => {
        const newCode = prompt(`Introduce el nuevo código para el combo duplicado:`, `${combo.code}_COPY`);
        if (!newCode) return;

        const newName = prompt(`Introduce el nuevo nombre para el combo duplicado:`, `${combo.name} (Copia)`);
        if (!newName) return;

        setSubmitting(true);
        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}');

        // Clonar datos básicos y productos
        const duplicateData = {
            code: newCode,
            name: newName,
            products: (combo.products || []).map((cp: any) => ({
                productId: cp.productId?.toString(),
                quantity: cp.quantity || 1,
                price: cp.price || 0,
                providerId: cp.providerId?.toString(),
                prestadoraId: cp.prestadoraId?.toString(),
                checkInDate: cp.checkInDate,
                checkOutDate: cp.checkOutDate,
                paxAdults: cp.paxAdults || 1,
                paxChildren: cp.paxChildren || 0,
                mainTaxId: cp.mainTaxId,
                appliedTaxes: (cp.appliedTaxes || []).map((t: any) => ({
                    chargeAndTaxId: t.chargeAndTaxId,
                    amount: t.amount
                }))
            }))
        };

        try {
            const res = await fetch('/api/combos', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: JSON.stringify(duplicateData)
            });

            const resData = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(resData.error || resData.message || 'Error al duplicar combo');

            await fetchData();
            alert('Combo duplicado exitosamente');
        } catch (err: any) {
            triggerDiagnosticError({
                title: 'Error al duplicar Combo',
                message: err.message || 'Fallo al procesar duplicación',
                endpoint: '/api/combos',
                statusCode: 400
            });
        } finally {
            setSubmitting(false);
        }
    }

    const handleDelete = async (id: number) => {
        if (!confirm(`¿Estás seguro de que deseas eliminar este registro? Esta acción no se puede deshacer.`)) return

        let endpoint = TAB_CONFIG[activeTab]?.endpoint || '';
        if (activeTab === 'combos') {
            endpoint = `/api/combos/${id}`;
        }

        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}')

        try {
            const url = activeTab === 'combos' ? endpoint : `${endpoint}?id=${id}`
            const res = await fetch(url, {
                method: 'DELETE',
                headers: {
                    'X-User-Id': loggedUser.id?.toString() || ''
                }
            })

            const resData = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(resData.error || resData.message || 'Error al eliminar')

            await fetchData()
        } catch (err: any) {
            triggerDiagnosticError({
                title: `Error al eliminar ${TAB_CONFIG[activeTab]?.singular || activeTab}`,
                message: err.message || 'No se pudo eliminar el registro',
                endpoint,
                statusCode: 400
            });
        }
    }

    const handleBulkUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file) return

        setUploading(true)
        const formData = new FormData()
        formData.append('file', file)
        formData.append('type', activeTab)

        const loggedUser = JSON.parse(localStorage.getItem('user') || '{}')

        try {
            const res = await fetch('/api/config/bulk-upload', {
                method: 'POST',
                headers: {
                    'X-User-Id': loggedUser.id?.toString() || ''
                },
                body: formData
            })

            const result = await res.json()
            if (!res.ok) throw new Error(result.message || 'Error en la carga masiva')

            alert(result.message + (result.errors ? '\nErrores:\n' + result.errors.join('\n') : ''))
            await fetchData()
        } catch (err: any) {
            alert(err.message)
        } finally {
            setUploading(false)
            if (fileInputRef.current) fileInputRef.current.value = ''
        }
    }

    return (
        <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 p-8 md:p-12">
            <header className="flex items-center justify-between mb-12">
                <div>
                    <h1 className="text-4xl font-bold text-zinc-900 dark:text-white mb-2 flex items-center gap-3">
                        <Settings className="w-8 h-8 text-blue-600" /> Configuración del Sistema
                    </h1>
                    <p className="text-zinc-500 dark:text-zinc-400 font-medium font-outfit">Control de acceso, sucursales y parámetros operativos</p>
                </div>
                <div className="flex gap-3">
                    <input
                        type="file"
                        ref={fileInputRef}
                        className="hidden"
                        accept=".xlsx, .xls, .csv"
                        onChange={handleBulkUpload}
                    />
                    {activeTab !== 'logs' && (
                        <>
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={() => window.open(`/api/config/templates?type=${activeTab}`)}
                                disabled={false}
                                className="px-6 h-14 bg-zinc-200 dark:bg-zinc-800 text-zinc-900 dark:text-white rounded-2xl flex items-center gap-3 shadow-xl font-bold transition-all disabled:opacity-50"
                                title="Descargar Plantilla Excel"
                            >
                                <Download className="w-5 h-5" />
                                Plantilla
                            </motion.button>
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                onClick={() => fileInputRef.current?.click()}
                                disabled={uploading}
                                className="px-5 h-12 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl flex items-center gap-2 text-sm font-bold shadow-sm transition-all cursor-pointer active:scale-95 disabled:opacity-50"
                            >
                                {uploading ? <Loader2 className="animate-spin w-5 h-5" /> : <Database className="w-5 h-5 text-blue-600" />}
                                Carga Masiva
                            </motion.button>
                            <motion.button
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                onClick={() => handleOpenModal()}
                                className="px-5 h-12 bg-blue-600 hover:bg-blue-700 text-white rounded-xl flex items-center gap-2 shadow-md shadow-blue-500/20 text-sm font-bold transition-all cursor-pointer active:scale-95 shrink-0"
                            >
                                <Plus className="w-5 h-5" />
                                {TAB_CONFIG[activeTab]?.newLabel || 'Nuevo Registro'}
                            </motion.button>
                        </>
                    )}
                </div>
            </header>

            <div className="mb-8">
                <LicenseStatusCard />
            </div>

            {/* Tabs Layout (Columnas Ordenadas Alfabéticamente) */}
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-2 p-3 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-3xl mb-8 shadow-sm">
                {[
                    { key: 'aeropuertos' as Tab, label: 'Aeropuertos', icon: <Tags className="w-4 h-4" /> },
                    { key: 'impuestos' as Tab, label: 'Cargos e Impuestos', icon: <Tags className="w-4 h-4" /> },
                    { key: 'ciudades' as Tab, label: 'Ciudades', icon: <Tags className="w-4 h-4" /> },
                    { key: 'clientes' as Tab, label: 'Clientes', icon: <Users className="w-4 h-4" /> },
                    { key: 'combos' as Tab, label: 'Combos', icon: <Database className="w-4 h-4" /> },
                    { key: 'consecutivos-transacciones' as Tab, label: 'Consecutivos', icon: <Database className="w-4 h-4" /> },
                    { key: 'diagnostico' as Tab, label: 'Diagnóstico y Salud', icon: <Activity className="w-4 h-4" />, isSystem: true },
                    { key: 'equivalencias' as Tab, label: 'Equivalencias', icon: <Tags className="w-4 h-4" /> },
                    { key: 'estados-cotizacion' as Tab, label: 'Estados Cotiz.', icon: <Tags className="w-4 h-4" /> },
                    { key: 'extraccion-interfaces' as Tab, label: 'Extracción Interfaces', icon: <TerminalSquare className="w-4 h-4" /> },
                    { key: 'formas-pago' as Tab, label: 'Formas de Pago', icon: <Tags className="w-4 h-4" /> },
                    { key: 'formatos-cotizacion' as Tab, label: 'Formatos Cotiz.', icon: <FileText className="w-4 h-4" /> },
                    { key: 'implants' as Tab, label: 'Implants', icon: <Database className="w-4 h-4" /> },
                    { key: 'logs' as Tab, label: 'Logs del Sistema', icon: <TerminalSquare className="w-4 h-4" /> },
                    { key: 'modulos-sitio' as Tab, label: 'Módulos del Sitio', icon: <ShieldCheck className="w-4 h-4" />, isSystem: true },
                    { key: 'monedas' as Tab, label: 'Monedas', icon: <DollarSign className="w-4 h-4" /> },
                    { key: 'paises' as Tab, label: 'Países', icon: <Tags className="w-4 h-4" /> },
                    { key: 'parametros' as Tab, label: 'Parámetros', icon: <Settings className="w-4 h-4" /> },
                    { key: 'prestadoras' as Tab, label: 'Prestadoras', icon: <HotelIcon className="w-4 h-4" /> },
                    { key: 'productos' as Tab, label: 'Productos', icon: <Tags className="w-4 h-4" /> },
                    { key: 'proveedores' as Tab, label: 'Proveedores', icon: <Building2 className="w-4 h-4" /> },
                    { key: 'resoluciones-documentos' as Tab, label: 'Resoluciones', icon: <FileText className="w-4 h-4" /> },
                    { key: 'roles' as Tab, label: 'Roles y Permisos', icon: <ShieldCheck className="w-4 h-4" />, isSystem: true },
                    { key: 'sucursales' as Tab, label: 'Sucursales', icon: <Building2 className="w-4 h-4" /> },
                    { key: 'tarifa-administrativa' as Tab, label: 'Tarifa Admin', icon: <DollarSign className="w-4 h-4" /> },
                    { key: 'tarjetas-credito' as Tab, label: 'Tarjetas de Crédito', icon: <Tags className="w-4 h-4" /> },
                    { key: 'tipos-proveedores' as Tab, label: 'Tipos de Proveedor', icon: <Building2 className="w-4 h-4" /> },
                    { key: 'tipos-tiquetes' as Tab, label: 'Tipos Tiquete', icon: <Tags className="w-4 h-4" /> },
                    { key: 'tiqueteadores' as Tab, label: 'Tiqueteadores', icon: <Printer className="w-4 h-4" /> },
                    { key: 'usuarios' as Tab, label: 'Usuarios', icon: <Users className="w-4 h-4" /> },
                    { key: 'variables' as Tab, label: 'Variables Adic.', icon: <Tags className="w-4 h-4" /> },
                    { key: 'vendedores' as Tab, label: 'Vendedores', icon: <UserCheck className="w-4 h-4" /> }
                ]
                .filter(tab => (tab.key === 'modulos-sitio' ? isSuperAdmin : (tab.isSystem || isMasterTabEnabled(tab.key))))
                .map((tab) => (
                    <TabButton
                        key={tab.key}
                        active={activeTab === tab.key}
                        onClick={() => {
                            setActiveTab(tab.key);
                            if (tab.key === 'diagnostico' && !healthData) runSystemHealthCheck();
                        }}
                        icon={tab.icon}
                        label={tab.label}
                    />
                ))}
            </div>



            {/* Barra de Búsqueda y Sub-pestañas de Parámetros */}
            <div className="mb-8 space-y-4">
                {activeTab === 'parametros' && (
                    <div className="flex flex-wrap items-center gap-2 p-1.5 bg-zinc-100 dark:bg-zinc-800/60 rounded-2xl border border-zinc-200/80 dark:border-zinc-700/50">
                        {[
                            { id: 'sql', label: 'SQL Server', icon: Server, color: 'text-blue-500' },
                            { id: 'tarifa_admin', label: 'Tarifa Administrativa', icon: DollarSign, color: 'text-emerald-500' },
                            { id: 'licencia', label: 'Licencia', icon: Key, color: 'text-amber-500' },
                            { id: 'general', label: 'General', icon: Settings, color: 'text-zinc-500' },
                            { id: 'todos', label: 'Todos los Parámetros', icon: Database, color: 'text-purple-500' },
                        ].map((subTab) => {
                            const count = (parameters || []).filter(item => {
                                if (subTab.id === 'todos') return true;
                                return getParamCategory(item) === subTab.id;
                            }).length;
                            const Icon = subTab.icon;
                            const isSelected = paramSubTab === subTab.id;
                            return (
                                <button
                                    key={subTab.id}
                                    type="button"
                                    onClick={() => setParamSubTab(subTab.id as any)}
                                    className={cn(
                                        "flex items-center gap-2 px-4 py-2.5 rounded-xl font-bold text-xs transition-all cursor-pointer",
                                        isSelected
                                            ? "bg-white dark:bg-zinc-900 text-zinc-900 dark:text-white shadow-sm border border-zinc-200 dark:border-zinc-700"
                                            : "text-zinc-500 hover:text-zinc-900 dark:hover:text-white hover:bg-white/50 dark:hover:bg-zinc-800/40"
                                    )}
                                >
                                    <Icon className={cn("w-4 h-4", subTab.color)} />
                                    <span>{subTab.label}</span>
                                    <span className={cn(
                                        "px-2 py-0.5 rounded-full text-[10px] font-extrabold",
                                        isSelected
                                            ? "bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300"
                                            : "bg-zinc-200/60 dark:bg-zinc-700/60 text-zinc-500 dark:text-zinc-400"
                                    )}>
                                        {count}
                                    </span>
                                </button>
                            );
                        })}
                    </div>
                )}

                <div className="flex flex-wrap items-center gap-3">
                    <div className="relative flex-1 min-w-[260px]">
                        <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-zinc-400" />
                        <input
                            type="text"
                            placeholder={`Buscar en ${TAB_CONFIG[activeTab]?.plural || activeTab}...`}
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full h-14 pl-14 pr-6 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all font-medium text-zinc-900 dark:text-white"
                        />
                    </div>

                    {/* Selector de Orden y Filtro por Estado */}
                    <div className="flex items-center gap-2 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 h-14 px-4 rounded-2xl shadow-sm">
                        <SlidersHorizontal className="w-4 h-4 text-zinc-400" />
                        <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400 hidden sm:inline">Estado:</span>
                        <select
                            value={statusSort}
                            onChange={(e) => setStatusSort(e.target.value as any)}
                            className="bg-transparent text-xs font-bold text-zinc-800 dark:text-zinc-200 outline-none cursor-pointer pr-1"
                        >
                            <option value="all" className="dark:bg-zinc-900">Todos los estados</option>
                            <option value="active-first" className="dark:bg-zinc-900">🟢 Activos primero</option>
                            <option value="inactive-first" className="dark:bg-zinc-900">🔴 Inactivos primero</option>
                            <option value="only-active" className="dark:bg-zinc-900">Solo Activos</option>
                            <option value="only-inactive" className="dark:bg-zinc-900">Solo Inactivos</option>
                        </select>
                    </div>
                </div>
            </div>

            {/* Content Area */}
            <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[2.5rem] shadow-sm overflow-hidden min-h-[500px]">
                {activeTab === 'diagnostico' ? (
                    <div className="p-8 space-y-8">
                        <div className="flex items-center justify-between">
                            <div>
                                <h3 className="text-xl font-bold dark:text-white flex items-center gap-2">
                                    <Activity className="w-6 h-6 text-emerald-500" />
                                    Consola de Diagnóstico y Salud del Sistema
                                </h3>
                                <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
                                    Evaluación rápida de bases de datos, conectividad con Zeus ERP, estado del licenciamiento y visor de novedades.
                                </p>
                            </div>
                            <button
                                type="button"
                                onClick={runSystemHealthCheck}
                                disabled={loadingHealth}
                                className="px-5 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl font-bold text-xs shadow-lg shadow-emerald-500/20 transition-all flex items-center gap-2 disabled:opacity-50 cursor-pointer"
                            >
                                {loadingHealth ? <Loader2 className="w-4 h-4 animate-spin" /> : <RefreshCw className="w-4 h-4" />}
                                <span>{loadingHealth ? 'Verificando...' : 'Ejecutar Checkup de Salud'}</span>
                            </button>
                        </div>

                        {healthData ? (
                            <div className="space-y-6">
                                {/* 3 Tarjetas de estado */}
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                    {/* Tarjeta Postgres */}
                                    <div className="p-6 bg-zinc-50 dark:bg-zinc-800/50 rounded-3xl border border-zinc-200 dark:border-zinc-700/60 relative overflow-hidden">
                                        <div className="flex items-center justify-between mb-4">
                                            <div className="flex items-center gap-3">
                                                <div className="p-2.5 bg-blue-100 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 rounded-xl">
                                                    <Database className="w-5 h-5" />
                                                </div>
                                                <span className="font-bold text-sm dark:text-white">PostgreSQL Local</span>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase ${
                                                healthData.postgres?.status === 'OK' 
                                                    ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400' 
                                                    : 'bg-red-100 text-red-700 dark:bg-red-950/60 dark:text-red-400'
                                            }`}>
                                                {healthData.postgres?.status || 'UNKNOWN'}
                                            </span>
                                        </div>
                                        <p className="text-xs text-zinc-600 dark:text-zinc-300 font-medium">
                                            {healthData.postgres?.message}
                                        </p>
                                    </div>

                                    {/* Tarjeta SQL Server */}
                                    <div className="p-6 bg-zinc-50 dark:bg-zinc-800/50 rounded-3xl border border-zinc-200 dark:border-zinc-700/60 relative overflow-hidden">
                                        <div className="flex items-center justify-between mb-4">
                                            <div className="flex items-center gap-3">
                                                <div className="p-2.5 bg-purple-100 dark:bg-purple-950/60 text-purple-600 dark:text-purple-400 rounded-xl">
                                                    <Server className="w-5 h-5" />
                                                </div>
                                                <span className="font-bold text-sm dark:text-white">SQL Server ERP Zeus</span>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase ${
                                                healthData.sqlServer?.status === 'OK' 
                                                    ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400' 
                                                    : 'bg-amber-100 text-amber-700 dark:bg-amber-950/60 dark:text-amber-400'
                                            }`}>
                                                {healthData.sqlServer?.status || 'UNKNOWN'}
                                            </span>
                                        </div>
                                        <p className="text-xs text-zinc-600 dark:text-zinc-300 font-medium">
                                            {healthData.sqlServer?.message}
                                        </p>
                                    </div>

                                    {/* Tarjeta Licencia */}
                                    <div className="p-6 bg-zinc-50 dark:bg-zinc-800/50 rounded-3xl border border-zinc-200 dark:border-zinc-700/60 relative overflow-hidden">
                                        <div className="flex items-center justify-between mb-4">
                                            <div className="flex items-center gap-3">
                                                <div className="p-2.5 bg-amber-100 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400 rounded-xl">
                                                    <ShieldCheck className="w-5 h-5" />
                                                </div>
                                                <span className="font-bold text-sm dark:text-white">Licencia del Sistema</span>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase ${
                                                healthData.license?.status === 'ACTIVE' 
                                                    ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400' 
                                                    : 'bg-red-100 text-red-700 dark:bg-red-950/60 dark:text-red-400'
                                            }`}>
                                                {healthData.license?.status || 'UNKNOWN'}
                                            </span>
                                        </div>
                                        <p className="text-xs text-zinc-600 dark:text-zinc-300 font-medium">
                                            {healthData.license?.clientName ? `Agencia: ${healthData.license.clientName}` : healthData.license?.message}
                                        </p>
                                        {healthData.license?.expirationDate && (
                                            <div className="text-[10px] text-zinc-400 mt-2 font-bold uppercase">
                                                Vence: {healthData.license.expirationDate} ({healthData.license.daysRemaining ?? 0} días restantes)
                                            </div>
                                        )}
                                    </div>
                                </div>

                                {/* Tabla de Registros de Error Recientes */}
                                <div className="bg-zinc-50 dark:bg-zinc-800/30 rounded-3xl p-6 border border-zinc-200 dark:border-zinc-800 space-y-4">
                                    <h4 className="text-base font-bold text-zinc-900 dark:text-white flex items-center gap-2">
                                        <TerminalSquare className="w-5 h-5 text-red-500" />
                                        Últimas Novedades y Errores Registrados en la Base de Datos
                                    </h4>
                                    
                                    {healthData.recentErrors && healthData.recentErrors.length > 0 ? (
                                        <div className="overflow-x-auto">
                                            <table className="w-full text-left text-xs font-medium">
                                                <thead>
                                                    <tr className="border-b border-zinc-200 dark:border-zinc-700 text-zinc-400 font-bold uppercase tracking-wider">
                                                        <th className="pb-3">Fecha</th>
                                                        <th className="pb-3">Módulo</th>
                                                        <th className="pb-3">Usuario</th>
                                                        <th className="pb-3">Descripción</th>
                                                        <th className="pb-3 text-right">Diagnóstico</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800">
                                                    {healthData.recentErrors.map((errItem: any) => (
                                                        <tr key={errItem.id} className="hover:bg-zinc-100 dark:hover:bg-zinc-800/60 transition-all">
                                                            <td className="py-3 font-mono text-zinc-500">{new Date(errItem.createdAt).toLocaleString()}</td>
                                                            <td className="py-3">
                                                                <span className="px-2 py-0.5 bg-red-100 text-red-700 dark:bg-red-950/60 dark:text-red-400 font-black rounded-md text-[10px] uppercase">
                                                                    {errItem.module}
                                                                </span>
                                                            </td>
                                                            <td className="py-3 text-zinc-700 dark:text-zinc-300 font-bold">{errItem.userName}</td>
                                                            <td className="py-3 text-zinc-600 dark:text-zinc-400 max-w-xs truncate">{errItem.description}</td>
                                                            <td className="py-3 text-right">
                                                                <button
                                                                    onClick={() => triggerDiagnosticError({
                                                                        title: `Revisión de Novedad #${errItem.id}`,
                                                                        message: errItem.description,
                                                                        module: errItem.module,
                                                                        action: errItem.action,
                                                                        details: errItem.metadata ? JSON.stringify(errItem.metadata, null, 2) : errItem.description,
                                                                        statusCode: errItem.metadata?.statusCode || 500,
                                                                        endpoint: errItem.metadata?.endpoint
                                                                    })}
                                                                    className="px-3 py-1 bg-zinc-200 dark:bg-zinc-700 text-zinc-800 dark:text-zinc-200 rounded-lg font-bold text-[10px] hover:bg-zinc-300 dark:hover:bg-zinc-600 transition-all cursor-pointer"
                                                                >
                                                                    Ver / Copiar
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    ) : (
                                        <div className="p-8 text-center text-zinc-400 text-sm italic">
                                            No se han registrado errores o excepciones recientes en el sistema.
                                        </div>
                                    )}
                                </div>
                            </div>
                        ) : (
                            <div className="p-12 text-center bg-zinc-50 dark:bg-zinc-800/30 rounded-3xl border border-dashed border-zinc-300 dark:border-zinc-700">
                                <Stethoscope className="w-12 h-12 text-zinc-400 mx-auto mb-3" />
                                <h4 className="text-base font-bold text-zinc-700 dark:text-zinc-300 mb-1">Evaluación de Salud del Sistema</h4>
                                <p className="text-xs text-zinc-400 mb-4">Haz clic en el botón superior para realizar la prueba rápida de componentes y consultar el diagnóstico.</p>
                                <button
                                    type="button"
                                    onClick={runSystemHealthCheck}
                                    className="px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl font-bold text-xs shadow-lg transition-all cursor-pointer"
                                >
                                    Iniciar Autodiagnóstico
                                </button>
                            </div>
                        )}
                    </div>
                ) : activeTab === 'roles' ? (
                    <div className="p-8">
                        <RoleManagerTab />
                    </div>
                ) : activeTab === 'modulos-sitio' ? (
                    !isSuperAdmin ? (
                        <div className="p-8 text-center space-y-4">
                            <ShieldCheck className="w-16 h-16 text-rose-500 mx-auto" />
                            <h3 className="text-xl font-bold text-zinc-800 dark:text-zinc-100">Acceso Restringido</h3>
                            <p className="text-zinc-500 dark:text-zinc-400 text-sm max-w-md mx-auto">
                                Esta sección es exclusiva para usuarios con el perfil <strong className="text-blue-600">SUPERADMINISTRADOR</strong>.
                            </p>
                        </div>
                    ) : (
                    <div className="p-8 space-y-8">
                        <div>
                            <div className="flex items-center justify-between mb-2">
                                <h3 className="text-xl font-bold dark:text-white flex items-center gap-2">
                                    <ShieldCheck className="w-6 h-6 text-blue-600" />
                                    Módulos de Navegación del Sitio (Menú Principal)
                                </h3>
                                <button
                                    type="button"
                                    onClick={handleResetAllSiteItems}
                                    className="px-4 py-2 bg-amber-500/10 hover:bg-amber-500/20 text-amber-600 dark:text-amber-400 rounded-xl text-xs font-bold transition-all flex items-center gap-2 cursor-pointer"
                                >
                                    <Settings className="w-4 h-4" />
                                    Restablecer Todos a Activo
                                </button>
                            </div>
                            <p className="text-sm text-zinc-500 dark:text-zinc-400 mb-6">
                                Activa o desactiva las secciones principales visibles en la barra lateral del sistema para este sitio.
                            </p>

                            {loadingSiteModules ? (
                                <div className="flex items-center justify-center p-12">
                                    <Loader2 className="animate-spin w-8 h-8 text-blue-600" />
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                    {siteModules.map((mod: any) => (
                                        <div key={mod.id} className="flex items-center justify-between p-5 bg-zinc-50 dark:bg-zinc-800/40 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-sm">
                                            <div>
                                                <div className="font-bold dark:text-white text-base">{mod.name}</div>
                                                <div className="text-xs text-zinc-400 font-mono mt-0.5">{mod.action}</div>
                                                <div className="mt-2">
                                                    <span className={cn(
                                                        "text-[10px] font-extrabold px-2.5 py-1 rounded-full uppercase tracking-wider",
                                                        mod.activo ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400" : "bg-zinc-500/10 text-zinc-500"
                                                    )}>
                                                        {mod.activo ? 'Activo' : 'Inactivo'}
                                                    </span>
                                                </div>
                                            </div>
                                            <button
                                                type="button"
                                                onClick={() => handleToggleSiteItem('MENU', mod.id, mod.activo)}
                                                className={cn(
                                                    "relative inline-flex h-8 w-16 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none",
                                                    mod.activo ? "bg-emerald-600" : "bg-zinc-300 dark:bg-zinc-700"
                                                )}
                                            >
                                                <span
                                                    className={cn(
                                                        "pointer-events-none inline-block h-7 w-7 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out",
                                                        mod.activo ? "translate-x-8" : "translate-x-0"
                                                    )}
                                                />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <hr className="border-zinc-200 dark:border-zinc-800" />

                        <div>
                            <h3 className="text-xl font-bold dark:text-white mb-2 flex items-center gap-2">
                                <Database className="w-6 h-6 text-amber-500" />
                                Tablas Maestras y Pestañas de Configuración (Sitio)
                            </h3>
                            <p className="text-sm text-zinc-500 dark:text-zinc-400 mb-6">
                                Habilita o deshabilita los maestros disponibles en este panel de configuración.
                            </p>
                            {loadingSiteModules ? (
                                <div className="flex items-center justify-center p-12">
                                    <Loader2 className="animate-spin w-8 h-8 text-amber-500" />
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                                    {siteMasters.map((mst: any) => (
                                        <div key={mst.id} className="flex items-center justify-between p-4 bg-zinc-50 dark:bg-zinc-800/40 border border-zinc-200 dark:border-zinc-800 rounded-2xl shadow-sm">
                                            <div>
                                                <div className="font-bold dark:text-white capitalize text-sm">{mst.name}</div>
                                                <div className="text-[11px] text-zinc-400 font-mono mt-0.5">{mst.code}</div>
                                                <div className="mt-1.5">
                                                    <span className={cn(
                                                        "text-[9px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider",
                                                        !mst.inactivo ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400" : "bg-red-500/10 text-red-500"
                                                    )}>
                                                        {!mst.inactivo ? 'Habilitado' : 'Deshabilitado'}
                                                    </span>
                                                </div>
                                            </div>
                                            <button
                                                type="button"
                                                onClick={() => handleToggleSiteItem('MASTER', mst.id, !mst.inactivo)}
                                                className={cn(
                                                    "relative inline-flex h-7 w-14 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none",
                                                    !mst.inactivo ? "bg-emerald-600" : "bg-zinc-300 dark:bg-zinc-700"
                                                )}
                                            >
                                                <span
                                                    className={cn(
                                                        "pointer-events-none inline-block h-6 w-6 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out",
                                                        !mst.inactivo ? "translate-x-7" : "translate-x-0"
                                                    )}
                                                />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                    )
                ) : activeTab === 'formatos-cotizacion' ? (

                    <div className="p-8">
                        <QuotationFormatsTab branches={branches} implants={implants} />
                    </div>
                ) : activeTab === 'tarifa-administrativa' ? (
                    <div className="p-8">
                        <AdministrativeFeeTab />
                    </div>

                ) : loading ? (
                    <div className="flex items-center justify-center h-full p-20">
                        <Loader2 className="animate-spin w-12 h-12 text-blue-600" />
                    </div>
                ) : (
                    <>
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead className="bg-zinc-50 dark:bg-zinc-800/30">
                                <tr>
                                    {activeTab === 'usuarios' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Usuario</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Rol</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Edición Reportes</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'extraccion-interfaces' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Interfaz</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Campo a Extraer</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código del Campo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Prefijo / Constante en Archivo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Delimitador</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'resoluciones-documentos' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Sucursal</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Implante</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Num. Resolución</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Prefijo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Rango Numeración</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Consecutivo Actual</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Vencimiento</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'consecutivos-transacciones' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Transacción</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Descripción</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Prefijo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Inicio</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Consecutivo Actual</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Sucursal</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Implante</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'impuestos' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Orden</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre del Cargo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Tipo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Valor</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Homologación</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Editable</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'vendedores' || activeTab === 'tiqueteadores' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre del {activeTab === 'vendedores' ? 'Vendedor' : 'Tiqueteador'}</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'prestadoras' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Prestadora</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Proveedor</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Categoría</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Tipo</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'proveedores' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Tipo Proveedor</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Sigla / Aerolínea</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Contacto</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'tipos-proveedores' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">¿Es Aerolínea?</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'clientes' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Documento</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Vendedor por Defecto</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Contacto</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'productos' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Tipo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Descripción</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Concepto / Clasif.</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Costo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Precio Base</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Cargos Asignados</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'monedas' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Moneda</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Tasa Conv.</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Decimales</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'logs' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Fecha y Hora</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Usuario</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Acción / Módulo</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Detalle del Evento</th>
                                        </>
                                    ) : activeTab === 'variables' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código Único</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Variable</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Aplica A</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'parametros' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Valor</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'combos' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'equivalencias' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Interface</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Maestro</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código Maestro</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código Equiv.</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'tarjetas-credito' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'formas-pago' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'paises' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'ciudades' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'aeropuertos' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : activeTab === 'tipos-tiquetes' ? (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Nombre</th>
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    ) : (
                                        <>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Código</th>
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Descripción</th>
                                            {activeTab === 'implants' && <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest">Sucursal</th>}
                                            {renderEstadoTh()}
                                            <th className="px-8 py-5 text-xs font-bold text-zinc-400 uppercase tracking-widest text-right">Acciones</th>
                                        </>
                                    )}
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-zinc-200 dark:divide-zinc-800 font-medium">
                                {activeTab === 'usuarios' && sortAndFilterMasterItems((users || []).filter(user => 
                                    user.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    user.email.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(user => (
                                    <tr key={user.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all">
                                        <td className="px-8 py-6">
                                            <div className="font-bold text-zinc-900 dark:text-white mb-0.5">{user.name}</div>
                                            <div className="text-zinc-400 text-xs flex items-center gap-1"><Mail className="w-3 h-3" /> {user.email}</div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className="px-3 py-1 bg-blue-50 dark:bg-blue-900/20 text-blue-600 text-[10px] font-black rounded-lg uppercase tracking-wider border border-blue-100 dark:border-blue-900/30">
                                                {user.role.name}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className={`px-3 py-1 text-[10px] font-black rounded-lg uppercase tracking-wider border ${
                                                user.canEditReports 
                                                    ? 'bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border-emerald-200 dark:border-emerald-800' 
                                                    : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-200 dark:border-zinc-700'
                                            }`}>
                                                {user.canEditReports ? 'Permitido' : 'No permitido'}
                                            </span>
                                        </td>
                                        {renderMasterStatusTd(user)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(user)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(user.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'impuestos' && sortAndFilterMasterItems((taxes || []).filter(tax => 
                                    tax?.name?.toLowerCase().includes((searchTerm || '').toLowerCase()) || 
                                    tax?.code?.toLowerCase().includes((searchTerm || '').toLowerCase())
                                )).map(tax => (
                                    <tr key={tax.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-zinc-600 dark:text-zinc-400 text-sm">
                                            <span className="w-7 h-7 bg-zinc-100 dark:bg-zinc-800 rounded-lg flex items-center justify-center font-mono font-bold text-xs">
                                                {tax.orden || 0}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{tax.code || '-'}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">
                                            <div>{tax.name}</div>
                                            {tax.targetTaxId && (() => {
                                                const targetT = ((allTaxes && allTaxes.length > 0 ? allTaxes : taxes) || []).find((t: any) => Number(t.id) === Number(tax.targetTaxId));
                                                return targetT ? (
                                                    <span className="inline-block mt-1 px-2 py-0.5 bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 text-[10px] font-bold rounded-md border border-amber-200/60 dark:border-amber-800/40">
                                                        Sumar en: {targetT.name} {targetT.code ? `(${targetT.code})` : ''}
                                                    </span>
                                                ) : null;
                                            })()}
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className="px-3 py-1 bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 text-[10px] font-black rounded-lg uppercase tracking-wider">
                                                {tax.type === 'TAX' ? 'Impuesto' : tax.type === 'CHARGE' ? 'Cargo Adic.' : 'Comisión'}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 font-black text-emerald-600">
                                            {tax.valueType === 'PERCENTAGE' ? `${tax.value}%` : tax.valueType === 'FIXED' ? `$${tax.value?.toLocaleString()}` : 'Ninguna (Libre)'}
                                        </td>
                                        <td className="px-8 py-6">
                                            {tax.gdsEquivalences ? (
                                                <span className="px-2.5 py-1 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 text-xs font-bold rounded-lg border border-blue-100 dark:border-blue-800/40">
                                                    {tax.gdsEquivalences}
                                                </span>
                                            ) : (
                                                <span className="text-zinc-400 text-xs italic">Sin homologar</span>
                                            )}
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className={cn(
                                                "px-2 py-0.5 text-[9px] font-black rounded uppercase tracking-wider border",
                                                tax.isEditable
                                                    ? "bg-emerald-50 text-emerald-600 border-emerald-100 dark:bg-emerald-900/10 dark:border-emerald-900/30"
                                                    : "bg-zinc-100 text-zinc-500 border-zinc-200 dark:bg-zinc-800 dark:border-zinc-700"
                                            )}>
                                                {tax.isEditable ? 'Sí' : 'No'}
                                            </span>
                                        </td>
                                        {renderMasterStatusTd(tax)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(tax)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(tax.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'prestadoras' && sortAndFilterMasterItems((prestadoras || []).filter(p => 
                                    p.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    p.code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    p.provider?.name?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(prestadora => (
                                    <tr key={prestadora.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{prestadora.code || '-'}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{prestadora.name}</td>
                                        <td className="px-8 py-6 font-medium text-zinc-600 dark:text-zinc-300 text-xs">
                                            {prestadora.provider?.name || <span className="text-zinc-400 text-xs italic">Sin proveedor</span>}
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className="px-3 py-1 bg-amber-50 dark:bg-amber-900/20 text-amber-600 text-[10px] font-black rounded-lg uppercase tracking-wider border border-amber-100 dark:border-amber-900/30">
                                                {prestadora.category || '-'}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 font-medium text-zinc-600 dark:text-zinc-300 text-xs">
                                            {prestadora.type || '-'}
                                        </td>
                                        {renderMasterStatusTd(prestadora)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(prestadora)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(prestadora.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'equivalencias' && sortAndFilterMasterItems((equivalences || []).filter(item => 
                                    item.interface_name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.master_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.cd_maestro?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.cd_codigo?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(item => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.interface_name}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.master_name}</td>
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.cd_maestro}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.cd_codigo}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}

                                {activeTab === 'extraccion-interfaces' && sortAndFilterMasterItems((interfaceExtractRules || []).filter(item => 
                                    item.fieldName?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.fieldCode?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.prefix?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.Interfaces?.name?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(item => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.Interfaces?.name || `ID ${item.interfaceId}`}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.fieldName}</td>
                                        <td className="px-8 py-6">
                                            <span className="font-mono text-xs font-bold text-blue-600 bg-blue-50 dark:bg-blue-900/20 px-2.5 py-1 rounded-lg border border-blue-200 dark:border-blue-800/50">{item.fieldCode}</span>
                                        </td>
                                        <td className="px-8 py-6">
                                            <span className="font-mono text-sm font-black text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-900/20 px-2.5 py-1 rounded-lg border border-emerald-200 dark:border-emerald-800/50">{item.prefix}</span>
                                        </td>
                                        <td className="px-8 py-6 font-mono text-xs text-zinc-500">{item.delimiter || '-'}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'clientes' && sortAndFilterMasterItems((clients || []).filter(item => 
                                    (item.name || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    (item.document || '').toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.document || item.id || '-'}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.name || item.document || 'Sin nombre'}</td>
                                        <td className="px-8 py-6">
                                            {item.sellerName ? (
                                                <span className="font-bold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20 px-2.5 py-1 rounded-lg border border-blue-200 dark:border-blue-800/50">
                                                    {item.sellerName} {item.sellerCode ? `(${item.sellerCode})` : ''}
                                                </span>
                                            ) : (
                                                <span className="text-zinc-400 font-medium text-xs">Sin asignar</span>
                                            )}
                                        </td>
                                        <td className="px-8 py-6 text-zinc-500">
                                            {item.email && <div className="text-xs flex items-center gap-1"><Mail className="w-3 h-3" /> {item.email}</div>}
                                            {item.phone && <div className="text-xs mt-1">{item.phone}</div>}
                                            {item.contactInfo && <div className="text-xs mt-1">{item.contactInfo}</div>}
                                        </td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'proveedores' && sortAndFilterMasterItems((providers || []).filter((item: any) => 
                                    item.name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.providerTypeName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.sigla?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.airlineCode?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.contactInfo?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code || item.document || item.id || '-'}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.name}</td>
                                        <td className="px-8 py-6">
                                            {item.providerTypeName ? (
                                                <span className="px-3 py-1 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 text-[10px] font-black rounded-lg uppercase tracking-wider border border-blue-100 dark:border-blue-900/30">
                                                    {item.providerTypeName}
                                                </span>
                                            ) : (
                                                <span className="text-zinc-400 text-xs italic">Sin tipo</span>
                                            )}
                                        </td>
                                        <td className="px-8 py-6 font-bold text-zinc-600 dark:text-zinc-400 text-xs">
                                            {item.sigla || item.airlineCode ? (
                                                <span className="font-mono text-xs font-bold text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-900/20 px-2.5 py-1 rounded-lg border border-emerald-100 dark:border-emerald-900/30">
                                                    {item.sigla || ''} {item.airlineCode ? `(${item.airlineCode})` : ''}
                                                </span>
                                            ) : (
                                                '-'
                                            )}
                                        </td>
                                        <td className="px-8 py-6 text-zinc-500 text-xs">
                                            {item.contactInfo || item.email || item.phone || '-'}
                                        </td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'productos' && sortAndFilterMasterItems((products || []).filter(item => 
                                    (item.description || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    (item.code || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    (item.type || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    (item.billingConcept || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    (item.serviceType || '').toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code || '-'}</td>
                                        <td className="px-8 py-6">
                                            <span className="px-3 py-1 bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 text-[10px] font-black rounded-lg uppercase tracking-wider">
                                                {item.type}
                                            </span>
                                        </td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.description}</td>
                                        <td className="px-8 py-6">
                                            <div className="flex flex-col text-xs font-medium">
                                                <span className="text-zinc-700 dark:text-zinc-300 font-bold">{item.billingConcept || '-'}</span>
                                                <span className="text-zinc-400 text-[10px]">{item.serviceType ? `Clasif: ${item.serviceType}` : '-'}</span>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6 font-medium text-zinc-500">
                                            {item.cost != null ? `$${item.cost.toLocaleString()}` : '-'}
                                        </td>
                                        <td className="px-8 py-6 font-black text-emerald-600">
                                            ${item.basePrice?.toLocaleString() || '0'}
                                        </td>
                                        <td className="px-8 py-6 font-medium text-zinc-500">
                                            {Array.isArray(item.taxIds) && item.taxIds.length > 0 ? (
                                                <span className="text-xs font-bold text-blue-600 bg-blue-50 dark:bg-blue-900/20 px-2 py-1 rounded-lg">
                                                    {item.taxIds.length} asignados
                                                </span>
                                            ) : (
                                                <span className="text-xs text-zinc-400 italic">Ninguno</span>
                                            )}
                                        </td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'parametros' && (() => {
                                    const filtered = (parameters || []).filter(item => {
                                        const matchesCategory = paramSubTab === 'todos' || getParamCategory(item) === paramSubTab;
                                        const matchesSearch = 
                                            (item.name || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
                                            (item.code || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
                                            (item.value || '').toString().toLowerCase().includes(searchTerm.toLowerCase());
                                        return matchesCategory && matchesSearch;
                                    });

                                    if (filtered.length === 0) {
                                        return (
                                            <tr>
                                                <td colSpan={4} className="px-8 py-12 text-center text-zinc-400 dark:text-zinc-500 font-medium">
                                                    No se encontraron parámetros en esta categoría.
                                                </td>
                                            </tr>
                                        );
                                    }

                                    return filtered.map(item => (
                                        <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                            <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code}</td>
                                            <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.name}</td>
                                            <td className="px-8 py-6 font-medium text-zinc-600 dark:text-zinc-300 max-w-md truncate">{item.value}</td>
                                            <td className="px-8 py-6 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                    <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                                </div>
                                            </td>
                                        </tr>
                                    ));
                                })()}
                                {activeTab === 'combos' && sortAndFilterMasterItems((combos || []).filter(item => 
                                    item.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.code?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(item => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.name}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleDuplicateCombo(item)} title="Duplicar Combo" className="p-2 text-zinc-400 hover:text-emerald-500 hover:bg-emerald-50 dark:hover:bg-emerald-500/10 rounded-xl transition-all"><Copy className="w-5 h-5" /></button>
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'monedas' && sortAndFilterMasterItems((currencies || []).filter(item => 
                                    item.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.code?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map(item => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.name}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.exchangeRate}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.decimals ?? 2}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}

                                {activeTab === 'resoluciones-documentos' && sortAndFilterMasterItems((documentResolutions || [])
                                .filter((item: any) => 
                                    item.resolutionNumber?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.branchName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.implantName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.prefix?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-bold text-zinc-900 dark:text-white">{item.branchName || 'Todas'}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-600 dark:text-zinc-300">{item.implantName || 'Todos'}</td>
                                        <td className="px-8 py-6 font-mono font-bold text-blue-600 dark:text-blue-400">{item.resolutionNumber}</td>
                                        <td className="px-8 py-6 font-mono text-xs font-bold text-zinc-700 dark:text-zinc-300">
                                            <span className="bg-blue-50 dark:bg-blue-900/20 px-2.5 py-1 rounded-lg border border-blue-200 dark:border-blue-800/50">{item.prefix || '-'}</span>
                                        </td>
                                        <td className="px-8 py-6 font-mono text-xs text-zinc-600 dark:text-zinc-400">{item.initialNumber} - {item.finalNumber}</td>
                                        <td className="px-8 py-6 font-mono text-sm font-black text-emerald-600 dark:text-emerald-400">{item.currentNumber}</td>
                                        <td className="px-8 py-6 text-xs text-zinc-500">{item.expirationDate ? new Date(item.expirationDate).toLocaleDateString() : '-'}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}

                                {activeTab === 'consecutivos-transacciones' && sortAndFilterMasterItems((transactionConsecutives || [])
                                .filter((item: any) => 
                                    item.transactionType?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.branchName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.implantName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.prefix?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-mono font-bold text-blue-600 dark:text-blue-400">{item.transactionType}</td>
                                        <td className="px-8 py-6 font-bold text-zinc-800 dark:text-zinc-200">{item.description}</td>
                                        <td className="px-8 py-6 font-mono text-xs font-bold text-zinc-700 dark:text-zinc-300">
                                            <span className="bg-blue-50 dark:bg-blue-900/20 px-2.5 py-1 rounded-lg border border-blue-200 dark:border-blue-800/50">{item.prefix || '-'}</span>
                                        </td>
                                        <td className="px-8 py-6 font-mono text-xs text-zinc-500">{item.initialNumber}</td>
                                        <td className="px-8 py-6 font-mono text-sm font-black text-emerald-600 dark:text-emerald-400">{item.currentNumber}</td>
                                         <td className="px-8 py-6 font-bold text-zinc-700 dark:text-zinc-300">{item.branchName || 'Todas'}</td>
                                        <td className="px-8 py-6 text-xs text-zinc-500">{item.implantName || 'Todos'}</td>
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}

                                {sortAndFilterMasterItems(((activeTab === 'vendedores' ? sellers : activeTab === 'tiqueteadores' ? ticketPrinters : activeTab === 'sucursales' ? branches : activeTab === 'implants' ? implants : activeTab === 'variables' ? variables : activeTab === 'tarjetas-credito' ? creditCards : activeTab === 'formas-pago' ? payments : activeTab === 'paises' ? countries : activeTab === 'ciudades' ? cities : activeTab === 'aeropuertos' ? airports : activeTab === 'tipos-tiquetes' ? ticketTypes : activeTab === 'estados-cotizacion' ? quotationStates : activeTab === 'tipos-proveedores' ? providerTypes : []) || [])
                                .filter((item: any) => 
                                    item.name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    item.code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    item.email?.toLowerCase().includes(searchTerm.toLowerCase())
                                )).map((item: any) => (
                                    <tr key={item.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-6 font-black text-blue-600 tracking-tighter text-base">{item.code || '-'}</td>
                                        <td className="px-8 py-6">
                                            <div className="text-zinc-600 dark:text-zinc-300 font-bold">{item.name}</div>
                                            {(activeTab === 'vendedores' || activeTab === 'tiqueteadores') && item.email && (
                                                <div className="text-zinc-400 text-xs flex items-center gap-1 mt-1"><Mail className="w-3 h-3" /> {item.email}</div>
                                            )}
                                        </td>
                                        {activeTab === 'implants' && (
                                            <td className="px-8 py-6">
                                                {item.branch ? (
                                                    <span className="px-3 py-1 bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-300 text-[10px] font-black rounded-lg uppercase tracking-wider">
                                                        {item.branch.name}
                                                    </span>
                                                ) : <span className="text-zinc-400 text-xs italic">No asignada</span>}
                                            </td>
                                        )}
                                        {activeTab === 'tipos-proveedores' && (
                                            <td className="px-8 py-6">
                                                <span className={`px-3 py-1 text-[10px] font-black rounded-lg uppercase tracking-wider border ${
                                                    item.isAirline 
                                                        ? 'bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-800' 
                                                        : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-200 dark:border-zinc-700'
                                                }`}>
                                                    {item.isAirline ? 'Sí' : 'No'}
                                                </span>
                                            </td>
                                        )}
                                        {activeTab === 'variables' && (
                                            <td className="px-8 py-6">
                                                <span className={`px-3 py-1 text-[10px] font-black rounded-lg uppercase tracking-wider border ${
                                                    item.isForAllClients 
                                                        ? 'bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-800' 
                                                        : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-200 dark:border-zinc-700'
                                                }`}>
                                                    {item.isForAllClients ? 'Todos los Clientes' : 'Solo Obligatorias'}
                                                </span>
                                            </td>
                                        )}
                                        {renderMasterStatusTd(item)}
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button onClick={() => handleOpenModal(item)} className="p-2 text-zinc-400 hover:text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-500/10 rounded-xl transition-all"><Edit2 className="w-5 h-5" /></button>
                                                <button onClick={() => handleDelete(item.id)} className="p-2 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-xl transition-all"><Trash2 className="w-5 h-5" /></button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                                {activeTab === 'logs' && logs.filter(log => 
                                    log.description.toLowerCase().includes(searchTerm.toLowerCase()) || 
                                    log.action?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    log.module?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                                    log.user?.name?.toLowerCase().includes(searchTerm.toLowerCase())
                                ).map(log => (
                                    <tr key={log.id} className="group hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all text-sm">
                                        <td className="px-8 py-4 whitespace-nowrap text-zinc-500 dark:text-zinc-400 text-xs font-mono">
                                            {new Date(log.createdAt).toLocaleString()}
                                        </td>
                                        <td className="px-8 py-4">
                                            {log.user ? (
                                                <div className="font-bold text-zinc-900 dark:text-white">{log.user.name}</div>
                                            ) : (
                                                <div className="italic text-zinc-400">Sistema / Automático</div>
                                            )}
                                        </td>
                                        <td className="px-8 py-4">
                                            <div className="flex flex-col gap-1 items-start">
                                                <span className={cn(
                                                    "px-2 py-0.5 text-[10px] font-black rounded-lg uppercase tracking-wider",
                                                    log.action === 'CREATE' ? "bg-emerald-50 text-emerald-600 dark:bg-emerald-900/20 dark:border-emerald-900/40" :
                                                        log.action === 'UPDATE' ? "bg-blue-50 text-blue-600 dark:bg-blue-900/20 dark:border-blue-900/40" :
                                                            log.action === 'DELETE' ? "bg-red-50 text-red-600 dark:bg-red-900/20 dark:border-red-900/40" :
                                                                log.action === 'LOGIN' ? "bg-purple-50 text-purple-600 dark:bg-purple-900/20 dark:border-purple-900/40" :
                                                                    "bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400"
                                                )}>
                                                    {log.action}
                                                </span>
                                                <span className="text-[10px] text-zinc-400 font-bold uppercase tracking-widest">{log.module}</span>
                                            </div>
                                        </td>
                                        <td className="px-8 py-4">
                                            <div className="text-zinc-700 dark:text-zinc-300 mb-1">{log.description}</div>
                                            {log.metadata && (
                                                <details className="mt-1">
                                                    <summary className="text-[10px] text-zinc-400 cursor-pointer hover:text-blue-500 font-bold uppercase tracking-widest inline-flex items-center gap-1">Ver Metadata Técnica</summary>
                                                    <pre className="mt-2 p-3 bg-zinc-100 dark:bg-zinc-950 rounded-xl text-[10px] text-zinc-500 dark:text-zinc-400 overflow-x-auto border border-zinc-200 dark:border-zinc-800">
                                                        {JSON.stringify(log.metadata, null, 2)}
                                                    </pre>
                                                </details>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                    {/* Pagination Controls */}
                    <div className="px-8 py-5 bg-zinc-50 dark:bg-zinc-800/30 border-t border-zinc-200 dark:border-zinc-800 flex flex-col sm:flex-row items-center justify-between gap-4 shrink-0">
                        <div className="text-zinc-500 dark:text-zinc-400 text-sm font-medium">
                            Mostrando <span className="font-bold text-zinc-900 dark:text-white">{totalItems === 0 ? 0 : Math.min(totalItems, (currentPage - 1) * pageSize + 1)}</span> a <span className="font-bold text-zinc-900 dark:text-white">{Math.min(totalItems, currentPage * pageSize)}</span> de <span className="font-bold text-zinc-900 dark:text-white">{totalItems}</span> registros
                        </div>
                        <div className="flex items-center gap-4">
                            <div className="flex items-center gap-2">
                                <label className="text-xs font-bold text-zinc-400 uppercase tracking-wider">Filas por página:</label>
                                <select
                                    className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-1.5 text-xs font-bold text-zinc-900 dark:text-white focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer"
                                    value={pageSize}
                                    onChange={(e) => {
                                        setPageSize(parseInt(e.target.value))
                                        setCurrentPage(1)
                                    }}
                                >
                                    <option value="10">10</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                </select>
                            </div>
                            <div className="flex items-center gap-1.5">
                                <button
                                    onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                                    disabled={currentPage === 1}
                                    className="px-3.5 py-2 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 font-bold text-xs rounded-xl shadow-sm transition-all"
                                >
                                    Anterior
                                </button>
                                <span className="text-zinc-500 dark:text-zinc-400 text-xs font-bold px-2">
                                    {currentPage} de {totalPages}
                                </span>
                                <button
                                    onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                                    disabled={currentPage === totalPages || totalPages === 0}
                                    className="px-3.5 py-2 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 font-bold text-xs rounded-xl shadow-sm transition-all"
                                >
                                    Siguiente
                                </button>
                            </div>
                        </div>
                    </div>
                    </>
                )}
            </div>

            {/* Modal - Unified for Settings */}
            <AnimatePresence>
                {isModalOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-md">
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className={cn(
                                "bg-white dark:bg-zinc-900 w-full rounded-[3.5rem] shadow-2xl border border-zinc-200 dark:border-zinc-800 overflow-hidden transition-all duration-300 max-h-[90vh] flex flex-col",
                                activeTab === 'combos' ? "max-w-6xl" : "max-w-xl"
                            )}
                        >
                            <div className="p-10 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between shrink-0">
                                <div className="flex items-center gap-4">
                                    <div className="w-12 h-12 bg-blue-600/10 text-blue-600 rounded-2xl flex items-center justify-center shadow-inner">
                                        {activeTab === 'usuarios' ? <Users className="w-6 h-6" /> : <Building2 className="w-6 h-6" />}
                                    </div>
                                    <div>
                                        <h3 className="text-2xl font-black dark:text-white">{formData.id ? 'Editar' : (TAB_CONFIG[activeTab]?.article === 'una' ? 'Nueva' : 'Nuevo')} {TAB_CONFIG[activeTab]?.singular || ''}</h3>
                                        <p className="text-zinc-500 text-sm font-medium">Asigna los parámetros correspondientes</p>
                                    </div>
                                </div>
                                <button onClick={() => setIsModalOpen(false)} className="p-3 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-full transition-colors text-zinc-400">
                                    <X className="w-6 h-6" />
                                </button>
                            </div>

                            <form onSubmit={handleSubmit} className="flex-1 flex flex-col overflow-hidden min-h-0">
                                <div className="flex-1 overflow-y-auto p-10 space-y-6 min-h-0">
                                {activeTab === 'usuarios' ? (
                                    <>
                                        <Input label="Nombre Completo" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Alex Smith" />
                                        <Input label="Email de Acceso" value={formData.email || ''} onChange={(v: string) => setFormData({ ...formData, email: v })} required type="email" placeholder="email@ejemplo.com" />
                                        <Input label="Contraseña" value={formData.password || ''} onChange={(v: string) => setFormData({ ...formData, password: v })} required={!formData.id} type="password" placeholder={formData.id ? "Dejar vacío para no cambiar" : "Min. 8 caracteres"} />
                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Rol de Usuario</label>
                                                <select
                                                    className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                    value={formData.roleId || ''}
                                                    onChange={(e) => setFormData({ ...formData, roleId: e.target.value })}
                                                    required
                                                >
                                                    <option value="">Seleccionar Rol</option>
                                                    {roles.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                                                </select>
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Sucursal</label>
                                                <SearchSelect
                                                    options={branches}
                                                    value={formData.branchId?.toString() || ''}
                                                    onChange={(val) => setFormData({ ...formData, branchId: val })}
                                                    placeholder="Ninguna / No aplica"
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Implant Asignado</label>
                                                <SearchSelect
                                                    options={implants}
                                                    value={formData.implantId?.toString() || ''}
                                                    onChange={(val) => setFormData({ ...formData, implantId: val })}
                                                    placeholder="Ninguno / No aplica"
                                                />
                                            </div>
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Tiqueteador Pred.</label>
                                                <SearchSelect
                                                    options={ticketPrinters}
                                                    value={formData.ticketPrinterId?.toString() || ''}
                                                    onChange={(val) => setFormData({ ...formData, ticketPrinterId: val })}
                                                    placeholder="Ninguno / No aplica"
                                                />
                                            </div>
                                        </div>
                                        <div className="pt-2">
                                            <label className="flex items-center gap-3 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-200 dark:border-zinc-700 cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-all">
                                                <input
                                                    type="checkbox"
                                                    checked={formData.canEditReports || false}
                                                    onChange={(e) => setFormData({ ...formData, canEditReports: e.target.checked })}
                                                    className="w-5 h-5 text-blue-600 rounded-lg focus:ring-blue-500 cursor-pointer"
                                                />
                                                <div>
                                                    <span className="text-xs font-bold text-zinc-800 dark:text-zinc-200 block">
                                                        Permitir edición de reportes / cotizaciones (Botón Activar Editor)
                                                    </span>
                                                    <span className="text-[11px] text-zinc-400 font-normal">
                                                        Habilita la capacidad de modificar visualmente celdas, estilos y márgenes en los reportes de impresión.
                                                    </span>
                                                </div>
                                            </label>
                                        </div>
                                    </>
                                ) : activeTab === 'impuestos' ? (
                                    <>
                                        <div className="grid grid-cols-3 gap-4">
                                            <Input label="Código (Ej. IVA_19)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} placeholder="Ej. IVA_19 (Opcional)" />
                                            <Input label="Nombre (Ej. IVA 19%)" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. IVA 19%" />
                                            <Input label="Orden (Prioridad)" value={formData.orden !== undefined && formData.orden !== null ? formData.orden : 0} onChange={(v: string) => setFormData({ ...formData, orden: parseInt(v) || 0 })} type="number" min="0" placeholder="Ej. 1, 2, 3..." />
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Tipo de Cargo</label>
                                            <select
                                                className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                value={formData.type}
                                                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                                            >
                                                <option value="TAX">Impuesto Tributario (Ej. IVA)</option>
                                                <option value="CHARGE">Servicio / Cargo Extra</option>
                                                <option value="COMMISSION">Comisión de Agencia</option>
                                            </select>
                                        </div>

                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Operación</label>
                                                <select
                                                    className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                    value={formData.valueType || 'NONE'}
                                                    onChange={(e) => setFormData({ ...formData, valueType: e.target.value })}
                                                >
                                                    <option value="NONE">Ninguna (Digitar / Libre)</option>
                                                    <option value="PERCENTAGE">Porcentaje (%)</option>
                                                    <option value="FIXED">Costo Fijo ($)</option>
                                                </select>
                                            </div>
                                            <Input
                                                label="Valor"
                                                value={formData.value !== undefined && formData.value !== null ? formData.value : ''}
                                                onChange={(v: string) => setFormData({ ...formData, value: v })}
                                                required={formData.valueType !== 'NONE'}
                                                type="number"
                                                step="0.01"
                                                placeholder={formData.valueType === 'NONE' ? "Ej. 0 (Opcional)" : "Ej. 19"}
                                            />
                                        </div>

                                        <div className="flex items-center gap-3 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-dashed border-zinc-200 dark:border-zinc-700">
                                            <input
                                                type="checkbox"
                                                id="isEditable"
                                                className="w-5 h-5 rounded-lg border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                checked={formData.isEditable !== false}
                                                onChange={(e) => setFormData({ ...formData, isEditable: e.target.checked })}
                                            />
                                            <label htmlFor="isEditable" className="text-sm font-bold text-zinc-700 dark:text-zinc-300 cursor-pointer">
                                                Permitir editar libremente en cotizaciones
                                                <span className="block text-[10px] font-medium text-zinc-400 uppercase tracking-wider mt-0.5">Si se desactiva, el valor será fijo según este maestro</span>
                                            </label>
                                        </div>

                                         <div className="space-y-2 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-200 dark:border-zinc-700">
                                             <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">
                                                 Sumar valor en otro Cargo/Impuesto (Cargo Destino)
                                             </label>
                                             <select
                                                 className="w-full h-12 bg-white dark:bg-zinc-900 rounded-xl px-4 border border-zinc-200 dark:border-zinc-700 outline-none text-xs font-bold focus:ring-2 focus:ring-blue-500 dark:text-white"
                                                 value={formData.targetTaxId || ''}
                                                 onChange={(e) => setFormData({ ...formData, targetTaxId: e.target.value ? parseInt(e.target.value) : null })}
                                             >
                                                 <option value="">Ninguno (Mantener independiente)</option>
                                                 {((allTaxes && allTaxes.length > 0 ? allTaxes : taxes) || []).filter((t: any) => Number(t.id) !== Number(formData.id)).map((t: any) => (
                                                     <option key={t.id} value={t.id}>
                                                         {t.name} {t.code ? `(${t.code})` : ''}
                                                     </option>
                                                 ))}
                                             </select>
                                             <p className="text-[10px] text-zinc-400 italic pl-1">
                                                 Si seleccionas un cargo destino, el valor acumulado de este impuesto se sumará en los totales y envíos a Zeus dentro del cargo seleccionado, pero se mantendrá desglosado en las líneas de detalle del producto.
                                             </p>
                                         </div>

                                        <div className="p-4 bg-blue-50/60 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800/40 rounded-2xl space-y-2">
                                            <Input label="Códigos GDS Equivalentes (Homologación Interfaz)" value={formData.gdsEquivalences || ''} onChange={(v: string) => setFormData({ ...formData, gdsEquivalences: v })} placeholder="Ej. CO, AE, VZ, DP (separados por coma)" />
                                            <p className="text-[11px] text-zinc-500 pl-1">
                                                Ingresa los códigos de impuestos de tiquetes/reservas GDS (Amadeus/Sabre) que deben mapearse automáticamente a este impuesto del sistema. Si un código GDS no se encuentra mapeado, se sumará automáticamente bajo el impuesto <strong>OTR</strong>.
                                            </p>
                                        </div>
                                    </>
                                ) : activeTab === 'vendedores' || activeTab === 'tiqueteadores' ? (
                                    <>
                                        <Input label="Código" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} placeholder="Ej. VEN-001 (Opcional)" />
                                        <Input label="Nombre del Profesional" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder={`Ej. ${activeTab === 'vendedores' ? 'Pedro Perez' : 'Oficina Principal'}`} />
                                        <Input label="Email de Contacto" value={formData.email || ''} onChange={(v: string) => setFormData({ ...formData, email: v })} type="email" placeholder="ejemplo@correo.com (Opcional)" />
                                    </>
                                ) : activeTab === 'prestadoras' ? (
                                    <>
                                        <Input label="Código de la Prestadora" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} placeholder="Ej. P-001 (Opcional)" />
                                        <Input label="Nombre de la Prestadora" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Decameron San Luis" />
                                        <div className="grid grid-cols-2 gap-4">
                                            <Input label="Estrellas/Cat." value={formData.category || ''} onChange={(v: string) => setFormData({ ...formData, category: v })} placeholder="Ej. 4*" />
                                            <Input label="Ubicación" value={formData.location || ''} onChange={(v: string) => setFormData({ ...formData, location: v })} placeholder="Ej. San Andrés, Colombia" />
                                        </div>
                                        <Input label="Tipo (Texto Abierto)" value={formData.type || ''} onChange={(v: string) => setFormData({ ...formData, type: v })} placeholder="Ej. Alojamiento, Transporte, etc" />
                                        <div className="space-y-2">
                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Proveedor / Operador</label>
                                            <SearchSelect
                                                options={providers}
                                                value={formData.providerId?.toString() || ''}
                                                onChange={(val) => setFormData({ ...formData, providerId: val })}
                                                placeholder="Seleccionar Proveedor"
                                            />
                                        </div>
                                    </>
                                ) : activeTab === 'implants' ? (
                                    <>
                                        <Input label="Código Único" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. BOG-01" />
                                        <Input label="Nombre / Descripción" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Sede Norte Bogotá" />
                                        <div className="space-y-2">
                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Sucursal Asociada</label>
                                            <SearchSelect
                                                options={branches}
                                                value={formData.branchId?.toString() || ''}
                                                onChange={(val) => setFormData({ ...formData, branchId: val })}
                                                placeholder="Seleccionar Sucursal"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Logo de Implant (Opcional)</label>
                                            <div className="flex items-center gap-4">
                                                {formData.logo && (
                                                    <img src={formData.logo} alt="Logo preview" className="w-16 h-16 object-contain bg-white rounded-xl border border-zinc-200" />
                                                )}
                                                <input 
                                                    type="file" 
                                                    accept="image/*"
                                                    onChange={(e) => {
                                                        const file = e.target.files?.[0];
                                                        if (file) {
                                                            const reader = new FileReader();
                                                            reader.onloadend = () => {
                                                                setFormData({ ...formData, logo: reader.result });
                                                            };
                                                            reader.readAsDataURL(file);
                                                        }
                                                    }}
                                                    className="w-full text-sm text-zinc-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                                                />
                                            </div>
                                        </div>

                                        {/* Excel Template and Configuration Section */}
                                        <div className="border-t border-zinc-200 dark:border-zinc-800 pt-6 mt-6 space-y-4">
                                            <h4 className="text-sm font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-wider">
                                                Plantilla de Reporte Excel
                                            </h4>
                                            
                                            <div className="space-y-2">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">
                                                    Archivo de Plantilla (.xlsx, .xls)
                                                </label>
                                                <div className="flex items-center gap-4">
                                                    <input 
                                                         type="file" 
                                                         id="implant-template-file-input"
                                                         accept=".xlsx,.xls"
                                                         onChange={(e) => {
                                                             const file = e.target.files?.[0];
                                                             if (file) {
                                                                 const reader = new FileReader();
                                                                 reader.onloadend = () => {
                                                                     setFormData({ ...formData, template: reader.result, clearTemplate: false });
                                                                 };
                                                                 reader.readAsDataURL(file);
                                                             }
                                                         }}
                                                         className="w-full text-sm text-zinc-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-emerald-700 hover:file:bg-emerald-100"
                                                     />
                                                     {formData.hasTemplate && !formData.template && !formData.clearTemplate && (
                                                         <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-md shrink-0">
                                                             ✓ Guardada
                                                         </span>
                                                     )}
                                                     {formData.template && (
                                                         <span className="text-xs font-bold text-blue-600 bg-blue-50 px-2.5 py-1 rounded-md shrink-0">
                                                             ✓ Nueva
                                                         </span>
                                                     )}
                                                     {((formData.hasTemplate && !formData.clearTemplate) || formData.template) && (
                                                         <button
                                                             type="button"
                                                             onClick={() => {
                                                                 setFormData({ ...formData, template: null, hasTemplate: false, clearTemplate: true });
                                                                 const fileInput = document.getElementById('implant-template-file-input') as HTMLInputElement;
                                                                 if (fileInput) fileInput.value = '';
                                                             }}
                                                             className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 hover:text-red-700 rounded-xl text-xs font-bold transition-all border border-red-100 shrink-0"
                                                             title="Eliminar plantilla actual de la base de datos"
                                                         >
                                                             <Trash2 className="w-3.5 h-3.5" />
                                                             <span>Eliminar</span>
                                                         </button>
                                                     )}
                                                </div>
                                            </div>

                                            {/* Coordinates Editor */}
                                            <div className="space-y-3">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1 block">
                                                    Coordenadas de Celdas (Ej. B4, G4)
                                                </label>
                                                
                                                <details className="group border border-zinc-200 dark:border-zinc-800 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 overflow-hidden">
                                                    <summary className="p-4 font-bold text-xs uppercase cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800/50 flex items-center justify-between dark:text-zinc-300">
                                                        <span>Personalizar Mapeo de Celdas</span>
                                                        <span className="text-zinc-400 group-open:rotate-180 transition-transform">▼</span>
                                                    </summary>                                                    <div className="p-4 border-t border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 space-y-4">
                                                        <div className="overflow-x-auto max-h-96 overflow-y-auto">
                                                            <table className="w-full text-left text-xs border-collapse">
                                                                <thead>
                                                                    <tr className="border-b border-zinc-200 dark:border-zinc-800 text-zinc-400 font-bold uppercase tracking-wider">
                                                                        <th className="py-2 px-3">Campo / Descripción</th>
                                                                        <th className="py-2 px-3">Token / Código</th>
                                                                        <th className="py-2 px-3 w-32">Coordenada</th>
                                                                        <th className="py-2 px-3 w-28 text-center">Acción</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                                                                    {(() => {
                                                                        const config = formData.templateConfig || {};
                                                                        const customNames = config.__customNames || {};
                                                                        const defaultPlaceholders: Record<string, string> = {
                                                                            asesor: "B4", fecha: "G4", clienteNombre: "B7", clienteIdentificacion: "G7",
                                                                            clienteDireccion: "B8", clienteTelefono: "G8", centroCosto: "B9", solicita: "G9",
                                                                            tCambio: "G11", descripcionPlan: "B12", fechasViaje: "G12", hotelesServicios: "A13",
                                                                            pasajeros: "B14", totalAdultos: "C15", totalNinos: "G15", logo: "A1"
                                                                        };

                                                                        let mappedKeys = Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                        if (config && Array.isArray(config.__keysOrder)) {
                                                                            const ordered = config.__keysOrder.filter((k: string) => k in config);
                                                                            const missing = mappedKeys.filter(k => !ordered.includes(k));
                                                                            mappedKeys = [...ordered, ...missing];
                                                                        }
                                                                        
                                                                        const allFields = mappedKeys.map(key => ({
                                                                            key,
                                                                            label: getFieldLabel(key),
                                                                            isCustom: key.startsWith('col_') || !!customNames[key]
                                                                        }));

                                                                        const DEFAULT_CONFIG = defaultPlaceholders as any;

                                                                        return allFields.map((f, idx) => (
                                                                            <tr key={f.key} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all">
                                                                                <td className="py-2 px-3 font-semibold text-zinc-700 dark:text-zinc-300">
                                                                                    {f.isCustom ? (
                                                                                        <input 
                                                                                            type="text"
                                                                                            value={f.label}
                                                                                            onChange={(e) => {
                                                                                                const newNames = { ...customNames, [f.key]: e.target.value };
                                                                                                const newConfig = { ...config, __customNames: newNames };
                                                                                                setFormData({ ...formData, templateConfig: newConfig });
                                                                                            }}
                                                                                            className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                                            placeholder="Nombre del campo"
                                                                                        />
                                                                                    ) : (
                                                                                        <span>{f.label}</span>
                                                                                    )}
                                                                                </td>
                                                                                <td className="py-2 px-3 font-mono text-[10px] text-zinc-400">
                                                                                    {f.isCustom ? (
                                                                                        <input 
                                                                                            type="text"
                                                                                            value={f.key}
                                                                                            onChange={(e) => {
                                                                                                const newKey = e.target.value.replace(/[^a-zA-Z0-9]/g, '');
                                                                                                if (!newKey || newKey === '__customNames') return;
                                                                                                
                                                                                                const newNames = { ...customNames };
                                                                                                const newConfig = { ...config };
                                                                                                
                                                                                                const val = newConfig[f.key];
                                                                                                delete newConfig[f.key];
                                                                                                newConfig[newKey] = val || '';
                                                                                                
                                                                                                const label = newNames[f.key];
                                                                                                delete newNames[f.key];
                                                                                                newNames[newKey] = label || f.label;
                                                                                                
                                                                                                newConfig.__customNames = newNames;
                                                                                                
                                                                                                // Actualizar la clave en __keysOrder
                                                                                                if (Array.isArray(config.__keysOrder)) {
                                                                                                    newConfig.__keysOrder = config.__keysOrder.map((k: string) => k === f.key ? newKey : k);
                                                                                                }
                                                                                                
                                                                                                setFormData({ ...formData, templateConfig: newConfig });
                                                                                            }}
                                                                                            className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                                            placeholder="token"
                                                                                        />
                                                                                    ) : (
                                                                                        <span>{f.key}</span>
                                                                                    )}
                                                                                </td>
                                                                                <td className="py-2 px-3">
                                                                                    <input 
                                                                                        type="text"
                                                                                        value={config[f.key] || ''}
                                                                                        onChange={(e) => {
                                                                                            const val = e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
                                                                                            const newConfig = { ...config, [f.key]: val };
                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                        }}
                                                                                        placeholder={DEFAULT_CONFIG[f.key as keyof typeof DEFAULT_CONFIG] || 'A1'}
                                                                                        className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white uppercase"
                                                                                    />
                                                                                </td>
                                                                                <td className="py-2 px-3 text-center">
                                                                                    <div className="flex items-center justify-center gap-1.5">
                                                                                        <button
                                                                                            type="button"
                                                                                            disabled={idx === 0}
                                                                                            onClick={() => {
                                                                                                const keys = [...mappedKeys];
                                                                                                const temp = keys[idx];
                                                                                                keys[idx] = keys[idx - 1];
                                                                                                keys[idx - 1] = temp;
                                                                                                
                                                                                                const newConfig: any = {};
                                                                                                keys.forEach(k => {
                                                                                                    newConfig[k] = config[k];
                                                                                                });
                                                                                                newConfig.__keysOrder = keys;
                                                                                                if (config.__customNames) newConfig.__customNames = config.__customNames;
                                                                                                if (config.__productFields) newConfig.__productFields = config.__productFields;
                                                                                                setFormData({ ...formData, templateConfig: newConfig });
                                                                                            }}
                                                                                            className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                                            title="Subir Posición"
                                                                                        >
                                                                                            <ArrowUp className="w-3.5 h-3.5" />
                                                                                        </button>
                                                                                        <button
                                                                                            type="button"
                                                                                            disabled={idx === mappedKeys.length - 1}
                                                                                            onClick={() => {
                                                                                                const keys = [...mappedKeys];
                                                                                                const temp = keys[idx];
                                                                                                keys[idx] = keys[idx + 1];
                                                                                                keys[idx + 1] = temp;
                                                                                                
                                                                                                const newConfig: any = {};
                                                                                                keys.forEach(k => {
                                                                                                    newConfig[k] = config[k];
                                                                                                });
                                                                                                newConfig.__keysOrder = keys;
                                                                                                if (config.__customNames) newConfig.__customNames = config.__customNames;
                                                                                                if (config.__productFields) newConfig.__productFields = config.__productFields;
                                                                                                setFormData({ ...formData, templateConfig: newConfig });
                                                                                            }}
                                                                                            className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                                            title="Bajar Posición"
                                                                                        >
                                                                                            <ArrowDown className="w-3.5 h-3.5" />
                                                                                        </button>
                                                                                        <button
                                                                                            type="button"
                                                                                            onClick={() => {
                                                                                                const newNames = { ...customNames };
                                                                                                delete newNames[f.key];
                                                                                                const newConfig = { ...config };
                                                                                                delete newConfig[f.key];
                                                                                                newConfig.__customNames = newNames;
                                                                                                if (Array.isArray(config.__keysOrder)) {
                                                                                                    newConfig.__keysOrder = config.__keysOrder.filter((k: string) => k !== f.key);
                                                                                                }
                                                                                                setFormData({ ...formData, templateConfig: newConfig });
                                                                                            }}
                                                                                            className="p-1 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                                                                                            title="Eliminar del Mapeo"
                                                                                        >
                                                                                            <Trash2 className="w-3.5 h-3.5" />
                                                                                        </button>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        ));
                                                                    })()}
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                        <div className="flex flex-col gap-4 mt-4 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                                                            <span className="text-[10px] font-bold text-zinc-400 uppercase tracking-wider pl-1 block">Agregar Variable de Cotización al Mapeo</span>
                                                            <div className="flex items-center gap-3">
                                                                <div className="flex-1">
                                                                    <select
                                                                        id="field-selector-implant"
                                                                        className="w-full h-10 px-3 rounded-xl bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-bold focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                        defaultValue=""
                                                                    >
                                                                        <option value="" disabled>-- Seleccionar Campo de Cotización --</option>
                                                                        {renderMappingOptions()}
                                                                    </select>
                                                                </div>
                                                                <button
                                                                    type="button"
                                                                    onClick={() => {
                                                                        const selectEl = document.getElementById('field-selector-implant') as HTMLSelectElement;
                                                                        if (!selectEl || !selectEl.value) return;
                                                                        const [key, label] = selectEl.value.split('|');
                                                                        
                                                                        const config = formData.templateConfig || {};
                                                                        const customNames = config.__customNames || {};
                                                                        
                                                                        let finalKey = key;
                                                                        let finalLabel = label;
                                                                        if (key === 'custom') {
                                                                            finalKey = 'col_' + Date.now();
                                                                            finalLabel = 'Nueva Columna';
                                                                        }
                                                                        
                                                                        const newConfig = { ...config, [finalKey]: '' };
                                                                        if (key === 'custom' || !getFieldLabel(finalKey)) {
                                                                            newConfig.__customNames = { ...customNames, [finalKey]: finalLabel };
                                                                        } else if (label) {
                                                                            newConfig.__customNames = { ...customNames, [finalKey]: finalLabel };
                                                                        }
                                                                        
                                                                        let currentKeys = Array.isArray(config.__keysOrder) ? [...config.__keysOrder] : Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                        if (!currentKeys.includes(finalKey)) {
                                                                            currentKeys.push(finalKey);
                                                                        }
                                                                        newConfig.__keysOrder = currentKeys;
                                                                        
                                                                        setFormData({ ...formData, templateConfig: newConfig });
                                                                        selectEl.value = "";
                                                                    }}
                                                                    className="px-4 h-10 text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white rounded-xl transition-all"
                                                                >
                                                                    + Agregar al Mapeo
                                                                </button>
                                                                <button
                                                                    type="button"
                                                                    onClick={() => {
                                                                        const config = formData.templateConfig || {};
                                                                        const customNames = config.__customNames || {};
                                                                        const newId = 'col_' + Date.now();
                                                                        const newConfig = { ...config, [newId]: '' };
                                                                        newConfig.__customNames = { ...customNames, [newId]: 'Nueva Columna' };
                                                                        
                                                                        let currentKeys = Array.isArray(config.__keysOrder) ? [...config.__keysOrder] : Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                        if (!currentKeys.includes(newId)) {
                                                                            currentKeys.push(newId);
                                                                        }
                                                                        newConfig.__keysOrder = currentKeys;
                                                                        
                                                                        setFormData({ ...formData, templateConfig: newConfig });
                                                                    }}
                                                                    className="px-4 h-10 text-xs font-bold bg-zinc-100 hover:bg-zinc-200 text-zinc-700 rounded-xl transition-all"
                                                                >
                                                                    + Campo Personalizado
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </details>
                                            </div>
                                        </div>
                                    </>
                                ) : (
                                    <>
                                        {activeTab === 'clientes' || activeTab === 'proveedores' ? (
                                            <>
                                                {activeTab === 'clientes' && <Input label="Documento / NIT" value={formData.document || ''} onChange={(v: string) => setFormData({ ...formData, document: v })} required placeholder="No. de Documento" />}
                                                {activeTab === 'proveedores' && (
                                                     <>
                                                         <Input label="Código del Proveedor" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} placeholder="Ej. AMADEUS" />
                                                         <div>
                                                             <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Tipo de Proveedor</label>
                                                             <select
                                                                 className="w-full mt-1.5 px-4 py-3 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-xl text-sm font-medium focus:ring-2 focus:ring-blue-500 transition-all dark:text-white"
                                                                 value={formData.providerTypeId || ''}
                                                                 onChange={(e) => {
                                                                     const typeId = e.target.value ? parseInt(e.target.value) : null;
                                                                     const selectedType = (providerTypes || []).find((t: any) => t.id === typeId);
                                                                     setFormData({
                                                                         ...formData,
                                                                         providerTypeId: typeId,
                                                                         _isAirline: selectedType?.isAirline || false
                                                                     });
                                                                 }}
                                                             >
                                                                 <option value="">-- Seleccionar Tipo de Proveedor --</option>
                                                                 {(providerTypes || []).map((pt: any) => (
                                                                     <option key={pt.id} value={pt.id}>
                                                                         {pt.name} {pt.isAirline ? '(Aerolínea)' : ''}
                                                                     </option>
                                                                 ))}
                                                             </select>
                                                         </div>
                                                         {(formData._isAirline || (providerTypes || []).find((t: any) => t.id === formData.providerTypeId)?.isAirline || formData.isAirline) && (
                                                             <div className="grid grid-cols-2 gap-4 p-3 bg-blue-50/50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800/40 rounded-xl">
                                                                 <Input label="Código de Aerolínea (IATA)" value={formData.airlineCode || ''} onChange={(v: string) => setFormData({ ...formData, airlineCode: v })} placeholder="Ej. 134" />
                                                                 <Input label="Sigla de Aerolínea" value={formData.sigla || ''} onChange={(v: string) => setFormData({ ...formData, sigla: v })} placeholder="Ej. AV" />
                                                             </div>
                                                         )}
                                                     </>
                                                 )}
                                                 <Input label="Nombre o Razón Social" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Nombre de Empresa / Persona" />
                                                <div className="grid grid-cols-2 gap-4">
                                                    <Input label="Email de Contacto" value={formData.email || ''} onChange={(v: string) => setFormData({ ...formData, email: v })} type="email" placeholder="Opcional" />
                                                    <Input label="Teléfono / Contacto" value={formData.contactInfo || formData.phone || ''} onChange={(v: string) => setFormData({ ...formData, contactInfo: v, phone: v })} placeholder="Opcional" />
                                                </div>
                                                {activeTab === 'clientes' && <Input label="Dirección" value={formData.address || ''} onChange={(v: string) => setFormData({ ...formData, address: v })} placeholder="Opcional" />}
                                                {activeTab === 'clientes' && (
                                                    <div className="grid grid-cols-2 gap-4">
                                                        <div className="space-y-2 group">
                                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Vendedor por Defecto</label>
                                                            <SearchSelect 
                                                                options={sellers} 
                                                                value={formData.sellerId} 
                                                                onChange={(val) => setFormData({ ...formData, sellerId: val })}
                                                                labelKey="name"
                                                                secondaryKey="code"
                                                                placeholder="Seleccionar Vendedor por Defecto (Opcional)"
                                                            />
                                                        </div>
                                                        <Input 
                                                            label="Plazo de Crédito (Días)" 
                                                            type="number"
                                                            min="0"
                                                            value={formData.creditDays !== undefined && formData.creditDays !== null ? formData.creditDays : 0} 
                                                            onChange={(v: string) => setFormData({ ...formData, creditDays: v ? parseInt(v) : 0 })} 
                                                            placeholder="Ej. 30" 
                                                        />
                                                    </div>
                                                )}
                                                {activeTab === 'clientes' && (
                                                    <div className="border-t border-zinc-200 dark:border-zinc-800 pt-6 mt-6 space-y-4">
                                                        <div>
                                                            <h4 className="text-sm font-bold text-zinc-900 dark:text-white uppercase tracking-wider">
                                                                Variables Adicionales Obligatorias
                                                            </h4>
                                                            <p className="text-xs text-zinc-500 mt-1">
                                                                Selecciona qué variables adicionales serán de carácter obligatorio al guardar una <b>Cotización</b> o <b>Factura</b> para este cliente.
                                                            </p>
                                                        </div>
                                                        <div className="space-y-2 max-h-72 overflow-y-auto p-2 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-200/60 dark:border-zinc-800">
                                                            {variables && variables.length > 0 ? (
                                                                variables.map((v: any) => {
                                                                    const quotationMandatory: any[] = Array.isArray(formData.mandatoryVariables?.quotation)
                                                                        ? formData.mandatoryVariables.quotation
                                                                        : (Array.isArray(formData.mandatoryVariables) ? formData.mandatoryVariables : []);
                                                                    const invoiceMandatory: any[] = Array.isArray(formData.mandatoryVariables?.invoice)
                                                                        ? formData.mandatoryVariables.invoice
                                                                        : [];

                                                                    const isQuotationChecked = quotationMandatory.some((id: any) => String(id) === String(v.id) || String(id) === String(v.code));
                                                                    const isInvoiceChecked = invoiceMandatory.some((id: any) => String(id) === String(v.id) || String(id) === String(v.code));

                                                                    return (
                                                                        <div key={v.id} className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3 bg-white dark:bg-zinc-900/80 hover:bg-zinc-100/80 dark:hover:bg-zinc-800/80 rounded-xl border border-zinc-200 dark:border-zinc-800 transition-colors">
                                                                            <div className="flex flex-col">
                                                                                <div className="flex items-center gap-2">
                                                                                    <span className="text-xs font-black text-zinc-800 dark:text-zinc-200">{v.name}</span>
                                                                                    {v.isForAllClients && (
                                                                                        <span className="text-[10px] text-blue-600 dark:text-blue-400 font-bold bg-blue-50 dark:bg-blue-900/30 px-2 py-0.5 rounded-md border border-blue-200 dark:border-blue-800">Global</span>
                                                                                    )}
                                                                                </div>
                                                                                <span className="text-[10px] text-zinc-400 font-mono">{v.code}</span>
                                                                            </div>
                                                                            
                                                                            <div className="flex items-center gap-4 shrink-0">
                                                                                <label className="flex items-center gap-2 cursor-pointer bg-zinc-50 dark:bg-zinc-800 px-2.5 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 hover:border-blue-400 dark:hover:border-blue-500 transition-all">
                                                                                    <input
                                                                                        type="checkbox"
                                                                                        className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500 border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900 cursor-pointer"
                                                                                        checked={isQuotationChecked}
                                                                                        onChange={(e) => {
                                                                                            const currentQ = [...quotationMandatory];
                                                                                            const currentI = [...invoiceMandatory];
                                                                                            if (e.target.checked) {
                                                                                                if (!currentQ.includes(v.id)) currentQ.push(v.id);
                                                                                            } else {
                                                                                                const idx = currentQ.findIndex((id: any) => String(id) === String(v.id) || String(id) === String(v.code));
                                                                                                if (idx > -1) currentQ.splice(idx, 1);
                                                                                            }
                                                                                            setFormData({
                                                                                                ...formData,
                                                                                                mandatoryVariables: { quotation: currentQ, invoice: currentI }
                                                                                            });
                                                                                        }}
                                                                                    />
                                                                                    <span className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Cotización</span>
                                                                                </label>

                                                                                <label className="flex items-center gap-2 cursor-pointer bg-zinc-50 dark:bg-zinc-800 px-2.5 py-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 hover:border-emerald-400 dark:hover:border-emerald-500 transition-all">
                                                                                    <input
                                                                                        type="checkbox"
                                                                                        className="w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900 cursor-pointer"
                                                                                        checked={isInvoiceChecked}
                                                                                        onChange={(e) => {
                                                                                            const currentQ = [...quotationMandatory];
                                                                                            const currentI = [...invoiceMandatory];
                                                                                            if (e.target.checked) {
                                                                                                if (!currentI.includes(v.id)) currentI.push(v.id);
                                                                                            } else {
                                                                                                const idx = currentI.findIndex((id: any) => String(id) === String(v.id) || String(id) === String(v.code));
                                                                                                if (idx > -1) currentI.splice(idx, 1);
                                                                                            }
                                                                                            setFormData({
                                                                                                ...formData,
                                                                                                mandatoryVariables: { quotation: currentQ, invoice: currentI }
                                                                                            });
                                                                                        }}
                                                                                    />
                                                                                    <span className="text-xs font-bold text-zinc-700 dark:text-zinc-300">Factura</span>
                                                                                </label>
                                                                            </div>
                                                                        </div>
                                                                    );
                                                                })
                                                            ) : (
                                                                <div className="text-center py-6 text-xs text-zinc-400">
                                                                    No hay variables adicionales configuradas en el sistema.
                                                                </div>
                                                            )}
                                                        </div>
                                                    </div>
                                                )}
                                            </>
                                        ) : activeTab === 'productos' ? (
                                            <>
                                                <Input label="Código del Producto" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} placeholder="Ej. P-001 (Opcional)" />
                                                <div className="grid grid-cols-2 gap-4">
                                                    <div className="space-y-2">
                                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Tipo de Servicio</label>
                                                        <select
                                                            className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                            value={formData.type || 'Servicio'}
                                                            onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                                                        >
                                                            <option value="Servicio">Servicio</option>
                                                            <option value="Boleto">Boleto Aéreo</option>
                                                            <option value="Alojamiento">Alojamiento</option>
                                                            <option value="Asistencia">Asistencia Médica</option>
                                                            <option value="Otro">Otro</option>
                                                        </select>
                                                    </div>
                                                    <Input label="Costo ($)" value={formData.cost ?? ''} onChange={(v: string) => setFormData({ ...formData, cost: v === '' ? '' : parseFloat(v) })} type="number" step="0.01" placeholder="0.00" />
                                                    <Input label="Precio Base ($)" value={formData.basePrice ?? ''} onChange={(v: string) => setFormData({ ...formData, basePrice: v === '' ? '' : parseFloat(v) })} type="number" step="0.01" required placeholder="0.00" />
                                                </div>
                                                <Input label="Descripción / Nombre" value={formData.description || ''} onChange={(v: string) => setFormData({ ...formData, description: v })} required placeholder="Ej. Tiquete Aéreo Nacional" />
                                                <div className="grid grid-cols-2 gap-4">
                                                    <Input label="Concepto de Facturación" value={formData.billingConcept || ''} onChange={(v: string) => setFormData({ ...formData, billingConcept: v })} placeholder="Opcional" />
                                                    <Input label="Clasificación Servicio" value={formData.serviceType || ''} onChange={(v: string) => setFormData({ ...formData, serviceType: v })} placeholder="Opcional" />
                                                </div>

                                                {/* Selección de Cargos e Impuestos Asignados al Producto */}
                                                <div className="space-y-2 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-200 dark:border-zinc-700 mt-4">
                                                    <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">
                                                        Cargos e Impuestos Asignados (Seleccionar impuestos aplicables a este producto)
                                                    </label>
                                                    <div className="grid grid-cols-2 gap-2 mt-2 max-h-40 overflow-y-auto pr-1">
                                                        {(!taxes || taxes.length === 0) ? (
                                                            <div className="col-span-2 text-xs text-zinc-400 italic p-3 text-center bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800">
                                                                No se encontraron impuestos o cargos registrados en el sistema.
                                                            </div>
                                                        ) : (
                                                            taxes.map((tax: any) => {
                                                                const tId = Number(tax.id);
                                                                const currentTaxIds: number[] = Array.isArray(formData.taxIds) ? formData.taxIds.map(Number) : [];
                                                                const isChecked = currentTaxIds.includes(tId);

                                                                return (
                                                                    <label key={tax.id} className="flex items-center gap-2 cursor-pointer text-xs font-bold text-zinc-700 dark:text-zinc-300 bg-white dark:bg-zinc-900 p-2 rounded-xl border border-zinc-200 dark:border-zinc-800 hover:border-blue-400 transition-all">
                                                                        <input
                                                                            type="checkbox"
                                                                            className="w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                                            checked={isChecked}
                                                                            onChange={(e) => {
                                                                                let nextIds = [...currentTaxIds];
                                                                                if (e.target.checked) {
                                                                                    if (!nextIds.includes(tId)) nextIds.push(tId);
                                                                                } else {
                                                                                    nextIds = nextIds.filter(id => id !== tId);
                                                                                }
                                                                                setFormData({ ...formData, taxIds: nextIds });
                                                                            }}
                                                                        />
                                                                        <span className="truncate">{tax.name} {tax.code ? `(${tax.code})` : ''}</span>
                                                                    </label>
                                                                );
                                                            })
                                                        )}
                                                    </div>
                                                    <p className="text-[10px] text-zinc-400 italic mt-1">
                                                        * Si dejas sin marcar todos los impuestos, a este producto le aplicarán **todos los impuestos globales por defecto**.
                                                    </p>
                                                </div>
                                                {formData.type === 'Boleto' && (
                                                    <div className="border-t border-zinc-200 dark:border-zinc-800 pt-6 mt-6 space-y-4">
                                                        <h4 className="text-sm font-bold text-zinc-900 dark:text-white uppercase tracking-wider">Itinerario y Tiquete</h4>
                                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                            <div className="space-y-2">
                                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Tipo de Tiquete</label>
                                                                <SearchSelect
                                                                    options={ticketTypes}
                                                                    value={formData.ticketTypeId?.toString() || ''}
                                                                    onChange={(val) => setFormData({ ...formData, ticketTypeId: val })}
                                                                    labelKey="name"
                                                                    placeholder="Seleccionar Tipo"
                                                                />
                                                            </div>
                                                            <Input label="Itinerario de Vuelo" value={formData.flightItinerary || ''} onChange={(v: string) => setFormData({ ...formData, flightItinerary: v })} placeholder="Ej. BOG/CTG" />
                                                            <Input label="Itinerario de Clases" value={formData.classItinerary || ''} onChange={(v: string) => setFormData({ ...formData, classItinerary: v })} placeholder="Ej. C/C" />
                                                            <Input label="Itinerario de Aerolínea" value={formData.airlineItinerary || ''} onChange={(v: string) => setFormData({ ...formData, airlineItinerary: v })} placeholder="Ej. AV/AV" />
                                                        </div>
                                                    </div>
                                                )}

                                                <div className="border-t border-zinc-200 dark:border-zinc-800 pt-6 mt-6 space-y-4">
                                                    <h4 className="text-sm font-bold text-zinc-900 dark:text-white uppercase tracking-wider pl-1 font-title">Campos Obligatorios en Cotización</h4>
                                                    <p className="text-xs text-zinc-400 pl-1">Seleccione qué campos serán obligatorios cuando un asesor agregue este producto a una cotización.</p>
                                                    
                                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 bg-zinc-50 dark:bg-zinc-800/20 p-5 rounded-2xl border border-zinc-100 dark:border-zinc-800/50">
                                                        <div className="space-y-3">
                                                            <span className="text-xs font-black text-zinc-400 uppercase tracking-widest block mb-1">Por Producto</span>
                                                            {AVAILABLE_MANDATORY_FIELDS.filter(f => f.group === 'Por Producto').map(f => {
                                                                const isChecked = (formData.mandatoryFields || []).includes(f.key);
                                                                return (
                                                                    <label key={f.key} className="flex items-center gap-3 cursor-pointer text-sm font-bold text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-white transition-colors">
                                                                        <input
                                                                            type="checkbox"
                                                                            className="w-4 h-4 rounded text-blue-600 border-zinc-300 focus:ring-blue-500 bg-white dark:bg-zinc-800 dark:border-zinc-700 cursor-pointer"
                                                                            checked={isChecked}
                                                                            onChange={(e) => {
                                                                                let current = [...(formData.mandatoryFields || [])];
                                                                                if (e.target.checked) {
                                                                                    current.push(f.key);
                                                                                } else {
                                                                                    current = current.filter(k => k !== f.key);
                                                                                }
                                                                                setFormData({ ...formData, mandatoryFields: current });
                                                                            }}
                                                                        />
                                                                        {f.label}
                                                                    </label>
                                                                );
                                                            })}
                                                        </div>

                                                        <div className="space-y-3">
                                                            <span className="text-xs font-black text-zinc-400 uppercase tracking-widest block mb-1">Cabecera (General)</span>
                                                            {AVAILABLE_MANDATORY_FIELDS.filter(f => f.group === 'Cabecera').map(f => {
                                                                const isChecked = (formData.mandatoryFields || []).includes(f.key);
                                                                return (
                                                                    <label key={f.key} className="flex items-center gap-3 cursor-pointer text-sm font-bold text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-white transition-colors">
                                                                        <input
                                                                            type="checkbox"
                                                                            className="w-4 h-4 rounded text-blue-600 border-zinc-300 focus:ring-blue-500 bg-white dark:bg-zinc-800 dark:border-zinc-700 cursor-pointer"
                                                                            checked={isChecked}
                                                                            onChange={(e) => {
                                                                                let current = [...(formData.mandatoryFields || [])];
                                                                                if (e.target.checked) {
                                                                                    current.push(f.key);
                                                                                } else {
                                                                                    current = current.filter(k => k !== f.key);
                                                                                }
                                                                                setFormData({ ...formData, mandatoryFields: current });
                                                                            }}
                                                                        />
                                                                        {f.label}
                                                                    </label>
                                                                );
                                                            })}
                                                        </div>
                                                    </div>
                                                </div>
                                            </>
                                        ) : activeTab === 'monedas' ? (
                                            <>
                                                <Input label="Código de Moneda" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. USD, EUR, PA" />
                                                <Input label="Nombre de la Moneda" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Dólar Estadounidense" />
                                                <Input label="Tasa de Cambio (respecto a moneda base)" value={formData.exchangeRate ?? ''} onChange={(v: string) => setFormData({ ...formData, exchangeRate: v === '' ? '' : parseFloat(v) })} type="number" step="0.0001" required placeholder="Ej. 1.000" />
                                                <Input label="Número de Decimales" value={formData.decimals !== undefined ? formData.decimals : 2} onChange={(v: string) => setFormData({ ...formData, decimals: v === '' ? 2 : parseInt(v) })} type="number" min="0" max="6" step="1" required placeholder="Ej. 2" />
                                            </>
                                        ) : activeTab === 'combos' ? (
                                            <div className="max-h-[70vh] overflow-y-auto pr-4 custom-scrollbar space-y-10 p-2">
                                                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                                                    <Input label="Código del Combo" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. COMBO-PROMO" />
                                                    <Input label="Nombre del Combo" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Paquete Turístico" />
                                                    <div className="space-y-2">
                                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Cupos Disponibles</label>
                                                        <input
                                                            type="number"
                                                            min="0"
                                                            step="1"
                                                            className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-emerald-500 transition-all outline-none text-emerald-600 dark:text-emerald-400"
                                                            value={formData.cupos ?? 0}
                                                            placeholder="0"
                                                            onChange={(e) => setFormData({ ...formData, cupos: parseInt(e.target.value) || 0 })}
                                                        />
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Moneda del Combo</label>
                                                        <select
                                                            className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                                                            value={formData.currencyId || ''}
                                                            onChange={(e) => setFormData({ ...formData, currencyId: e.target.value ? parseInt(e.target.value) : null })}
                                                        >
                                                            <option value="">Seleccionar Moneda...</option>
                                                            {currencies.map((c: any) => <option key={c.id} value={c.id}>{c.code} - {c.name}</option>)}
                                                        </select>
                                                    </div>
                                                </div>
                                                
                                                <div className="space-y-6">
                                                    <div className="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-4">
                                                        <div className="space-y-1">
                                                            <label className="text-xs font-black text-zinc-900 dark:text-white uppercase tracking-wider pl-1 font-title">Productos del Combo</label>
                                                            <p className="text-[10px] text-zinc-400 pl-1">Define los servicios individuales que componen este paquete</p>
                                                        </div>
                                                        <button 
                                                            type="button"
                                                            onClick={() => {
                                                                const newProds = [...(formData.products || []), { productId: '', quantity: 1, price: 0, appliedTaxes: [], inNationality: 1 }];
                                                                setFormData({ ...formData, products: newProds });
                                                            }}
                                                            className="h-10 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl text-xs font-bold flex items-center gap-2 shadow-lg shadow-blue-500/20 transition-all border-b-2 border-blue-800 active:translate-y-px"
                                                        >
                                                            <Plus className="w-4 h-4" /> Agregar Producto
                                                        </button>
                                                    </div>

                                                    <div className="grid grid-cols-1 gap-8">
                                                        {(formData.products || []).map((cp: any, idx: number) => (
                                                        <div key={idx} className="p-6 bg-white dark:bg-zinc-900 rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-sm space-y-6 relative group/item">
                                                            <button 
                                                                type="button"
                                                                onClick={() => {
                                                                    const newProds = formData.products.filter((_: any, i: number) => i !== idx);
                                                                    setFormData({ ...formData, products: newProds });
                                                                }}
                                                                className="absolute top-4 right-4 w-8 h-8 bg-red-50 text-red-500 hover:bg-red-100 rounded-xl flex items-center justify-center transition-all"
                                                                title="Eliminar producto"
                                                            >
                                                                <Trash2 className="w-4 h-4" />
                                                            </button>

                                                            {/* Section: Service Info */}
                                                            <div className="space-y-3">
                                                                <label className="text-[10px] font-black text-blue-500 uppercase tracking-widest pl-1 flex items-center gap-2">
                                                                    <Tag className="w-3 h-3" /> Información del Servicio
                                                                </label>
                                                                <div className="grid grid-cols-12 gap-4">
                                                                    <div className="col-span-12">
                                                                        <SearchSelect
                                                                            options={products}
                                                                            value={cp.productId?.toString() || ''}
                                                                            onChange={(val) => {
                                                                                const prod = products.find((p: any) => p.id === parseInt(val));
                                                                                const newProds = [...formData.products];
                                                                                newProds[idx] = {
                                                                                    ...cp,
                                                                                    productId: val,
                                                                                    price: prod?.basePrice || 0,
                                                                                    cost: prod?.cost ?? 0
                                                                                };
                                                                                setFormData({ ...formData, products: newProds });
                                                                            }}
                                                                            placeholder="Seleccionar Producto..."
                                                                            labelKey="description"
                                                                            secondaryKey="code"
                                                                        />
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            {/* Section: Prestadora & Dates */}
                                                            <div className="bg-zinc-50 dark:bg-zinc-800/30 p-4 rounded-2xl space-y-4">
                                                                <label className="text-[10px] font-black text-emerald-500 uppercase tracking-widest pl-1 flex items-center gap-2">
                                                                    <HotelIcon className="w-3 h-3" /> Alojamiento y Fechas
                                                                </label>
                                                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                                                    <div className="space-y-1">
                                                                        <SearchSelect
                                                                            options={providers}
                                                                            value={cp.providerId?.toString() || ''}
                                                                            onChange={(val) => {
                                                                                const numericVal = val ? parseInt(val) : null;
                                                                                const newProds = [...formData.products];
                                                                                newProds[idx] = { ...cp, providerId: numericVal, prestadoraId: null };
                                                                                setFormData({ ...formData, products: newProds });
                                                                            }}
                                                                            placeholder="Sel. Proveedor..."
                                                                            secondaryKey="code"
                                                                        />
                                                                    </div>
                                                                    <div className="space-y-1">
                                                                        <SearchSelect
                                                                            options={prestadoras.filter(h => !cp.providerId || h.providerId === cp.providerId)}
                                                                            value={cp.prestadoraId?.toString() || ''}
                                                                            onChange={(val) => {
                                                                                const numericVal = val ? parseInt(val) : null;
                                                                                const newProds = [...formData.products];
                                                                                newProds[idx] = { ...cp, prestadoraId: numericVal };
                                                                                setFormData({ ...formData, products: newProds });
                                                                            }}
                                                                            disabled={!cp.providerId}
                                                                            placeholder="Sel. Prestadora..."
                                                                            secondaryKey="code"
                                                                        />
                                                                    </div>
                                                                    <div className="space-y-1">
                                                                        <select 
                                                                            className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-3 border border-zinc-200 dark:border-zinc-700 text-[11px] font-black text-emerald-600 dark:text-emerald-400 outline-none"
                                                                            value={cp.inNationality || 1}
                                                                            onChange={(e) => {
                                                                                const val = parseInt(e.target.value);
                                                                                const newProds = [...formData.products];
                                                                                newProds[idx] = { ...cp, inNationality: val };
                                                                                setFormData({ ...formData, products: newProds });
                                                                            }}
                                                                        >
                                                                            <option value={1}>Nacional</option>
                                                                            <option value={2}>Internacional</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
                                                                    <div>
                                                                        <label className="text-[9px] font-bold text-zinc-400 uppercase ml-1">Check-In</label>
                                                                        <input type="date" className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-2 border border-zinc-200 dark:border-zinc-700 text-[10px] font-bold outline-none" value={cp.checkInDate ? cp.checkInDate.split('T')[0] : ''} onChange={(e) => {
                                                                            const newProds = [...formData.products];
                                                                            newProds[idx] = { ...cp, checkInDate: e.target.value };
                                                                            setFormData({ ...formData, products: newProds });
                                                                        }} />
                                                                    </div>
                                                                    <div>
                                                                        <label className="text-[9px] font-bold text-zinc-400 uppercase ml-1">Check-Out</label>
                                                                        <input type="date" className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-2 border border-zinc-200 dark:border-zinc-700 text-[10px] font-bold outline-none" value={cp.checkOutDate ? cp.checkOutDate.split('T')[0] : ''} onChange={(e) => {
                                                                            const newProds = [...formData.products];
                                                                            newProds[idx] = { ...cp, checkOutDate: e.target.value };
                                                                            setFormData({ ...formData, products: newProds });
                                                                        }} />
                                                                    </div>
                                                                    <div>
                                                                        <label className="text-[9px] font-bold text-zinc-400 uppercase ml-1">Cantidad</label>
                                                                        <input type="number" min="1" className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-2 border border-zinc-200 dark:border-zinc-700 text-xs font-bold outline-none transition-all focus:ring-1 focus:ring-emerald-500" value={cp.quantity || 1} onChange={(e) => {
                                                                            const val = Math.max(1, parseInt(e.target.value) || 1);
                                                                            const newProds = [...formData.products];
                                                                            newProds[idx] = { ...cp, quantity: val };
                                                                            setFormData({ ...formData, products: newProds });
                                                                        }} />
                                                                    </div>
                                                                    <div>
                                                                        <label className="text-[9px] font-bold text-zinc-400 uppercase ml-1">Adultos</label>
                                                                        <input type="number" className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-2 border border-zinc-200 dark:border-zinc-700 text-xs font-bold outline-none transition-all focus:ring-1 focus:ring-emerald-500" value={cp.paxAdults || ''} onChange={(e) => {
                                                                            const newProds = [...formData.products];
                                                                            newProds[idx] = { ...cp, paxAdults: parseInt(e.target.value) || 0 };
                                                                            setFormData({ ...formData, products: newProds });
                                                                        }} />
                                                                    </div>
                                                                    <div>
                                                                        <label className="text-[9px] font-bold text-zinc-400 uppercase ml-1">Niños</label>
                                                                        <input type="number" className="w-full h-10 bg-white dark:bg-zinc-900 rounded-xl px-2 border border-zinc-200 dark:border-zinc-700 text-xs font-bold outline-none transition-all focus:ring-1 focus:ring-emerald-500" value={cp.paxChildren || ''} onChange={(e) => {
                                                                            const newProds = [...formData.products];
                                                                            newProds[idx] = { ...cp, paxChildren: parseInt(e.target.value) || 0 };
                                                                            setFormData({ ...formData, products: newProds });
                                                                        }} />
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            {/* Section: Values & Taxes */}
                                                            <div className="space-y-4">
                                                                <div className="flex items-center justify-between">
                                                                    <label className="text-[10px] font-black text-purple-500 uppercase tracking-widest pl-1 flex items-center gap-2">
                                                                        <DollarSign className="w-3 h-3" /> Valores e Impuestos
                                                                    </label>
                                                                    <div className="flex items-center gap-2 bg-purple-50 dark:bg-purple-900/10 px-3 py-1.5 rounded-xl border border-purple-100 dark:border-purple-800">
                                                                        <span className="text-[9px] font-black text-purple-600 uppercase tracking-wider">Cargo Principal:</span>
                                                                        <select 
                                                                            className="h-7 bg-transparent text-[10px] font-black text-purple-700 dark:text-purple-300 outline-none border-none cursor-pointer"
                                                                            value={cp.mainTaxId?.toString() || ''}
                                                                            onChange={(e) => {
                                                                                const val = e.target.value ? parseInt(e.target.value) : null;
                                                                                const newProds = [...formData.products];
                                                                                let nextApplied = [...(cp.appliedTaxes || [])];
                                                                                
                                                                                if (val && !nextApplied.some(t => t.chargeAndTaxId === val)) {
                                                                                    const tax = taxes.find(t => t.id === val);
                                                                                    const initialAmount = tax.valueType === 'PERCENTAGE' ? (cp.price * cp.quantity * tax.value / 100) : tax.value * cp.quantity;
                                                                                    nextApplied.push({ chargeAndTaxId: val, amount: initialAmount });
                                                                                }
                                                                                if (val) {
                                                                                    const mainAmount = nextApplied.find(t => t.chargeAndTaxId === val)?.amount || 0;
                                                                                    nextApplied = nextApplied.map(at => {
                                                                                        if (at.chargeAndTaxId === val) return at;
                                                                                        const originalTax = taxes.find(t => t.id === at.chargeAndTaxId);
                                                                                        if (originalTax?.valueType === 'PERCENTAGE') {
                                                                                            return { ...at, amount: (originalTax.value / 100) * mainAmount };
                                                                                        }
                                                                                        return at;
                                                                                    });
                                                                                    // Important: Ensure price is updated to match the new main tax amount
                                                                                    newProds[idx] = { 
                                                                                        ...cp, 
                                                                                        mainTaxId: val, 
                                                                                        price: mainAmount / (cp.quantity || 1),
                                                                                        appliedTaxes: nextApplied 
                                                                                    };
                                                                                } else {
                                                                                    newProds[idx] = { ...cp, mainTaxId: val, appliedTaxes: nextApplied };
                                                                                }
                                                                                setFormData({ ...formData, products: newProds });
                                                                            }}
                                                                        >
                                                                            <option value="">Seleccionar...</option>
                                                                            {taxes.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                                                                        </select>
                                                                    </div>
                                                                </div>

                                                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                                    {/* Left: Total Calculation Area */}
                                                                    <div className="p-4 bg-blue-50/50 dark:bg-blue-900/10 rounded-2xl border border-blue-100 dark:border-blue-800 flex flex-col justify-center gap-2">
                                                                        <label className="text-[10px] font-black text-blue-600 uppercase tracking-widest text-center">Valor Total de Fila (Sumatoria)</label>
                                                                        <div className="relative">
                                                                            <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-blue-500" />
                                                                            <input 
                                                                                type="number"
                                                                                className="w-full h-14 bg-white dark:bg-zinc-900 rounded-2xl pl-10 pr-4 text-xl font-black text-blue-600 outline-none border-2 border-blue-200 focus:border-blue-500 shadow-sm text-center"
                                                                                value={((cp.price * cp.quantity) + (cp.appliedTaxes || []).filter((t: any) => t.chargeAndTaxId !== cp.mainTaxId).reduce((acc: number, t: any) => acc + (t.amount || 0), 0)).toFixed(2)}
                                                                                onChange={(e) => {
                                                                                    const newTotal = parseFloat(e.target.value) || 0;
                                                                                    const currentOtherTaxes = (cp.appliedTaxes || []).filter((t: any) => t.chargeAndTaxId !== cp.mainTaxId).reduce((acc: number, t: any) => acc + (t.amount || 0), 0);
                                                                                    const newChargeAmount = newTotal - currentOtherTaxes;
                                                                                    const newProds = [...formData.products];
                                                                                    
                                                                                    let newApplied = (cp.appliedTaxes || []).map((at: any) => {
                                                                                        if (at.chargeAndTaxId === cp.mainTaxId) return { ...at, amount: newChargeAmount };
                                                                                        const originalTax = taxes.find(t => t.id === at.chargeAndTaxId);
                                                                                        if (originalTax?.valueType === 'PERCENTAGE') {
                                                                                            return { ...at, amount: (originalTax.value / 100) * newChargeAmount };
                                                                                        }
                                                                                        return at;
                                                                                    });

                                                                                    newProds[idx] = { 
                                                                                        ...cp, 
                                                                                        price: newChargeAmount / (cp.quantity || 1),
                                                                                        appliedTaxes: newApplied
                                                                                    };
                                                                                    setFormData({ ...formData, products: newProds });
                                                                                }}
                                                                            />
                                                                        </div>
                                                                    </div>

                                                                    {/* Center: Cost Field */}
                                                                    <div className="p-4 bg-orange-50/50 dark:bg-orange-900/10 rounded-2xl border border-orange-100 dark:border-orange-800 flex flex-col justify-center gap-2">
                                                                        <label className="text-[10px] font-black text-orange-500 uppercase tracking-widest text-center">Costo del Producto ($)</label>
                                                                        <div className="relative">
                                                                            <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-orange-400" />
                                                                            <input
                                                                                type="number"
                                                                                min="0"
                                                                                step="0.01"
                                                                                className="w-full h-14 bg-white dark:bg-zinc-900 rounded-2xl pl-10 pr-4 text-xl font-black text-orange-600 outline-none border-2 border-orange-200 focus:border-orange-500 shadow-sm text-center"
                                                                                value={cp.cost ?? 0}
                                                                                placeholder="0.00"
                                                                                onChange={(e) => {
                                                                                    const newProds = [...formData.products];
                                                                                    newProds[idx] = { ...cp, cost: parseFloat(e.target.value) || 0 };
                                                                                    setFormData({ ...formData, products: newProds });
                                                                                }}
                                                                            />
                                                                        </div>
                                                                    </div>

                                                                    {/* Right: Individually applied taxes */}
                                                                    <div className="grid grid-cols-1 gap-2 max-h-40 overflow-y-auto pr-1 custom-scrollbar">
                                                                        {(allTaxes && allTaxes.length > 0 ? allTaxes : taxes).map(tax => {
                                                                            const appliedTax = (cp.appliedTaxes || []).find((at: any) => at.chargeAndTaxId === tax.id);
                                                                            const checked = !!appliedTax;
                                                                            return (
                                                                                <div key={tax.id} className={cn(
                                                                                    "flex items-center gap-3 p-2.5 rounded-xl border transition-all",
                                                                                    cp.mainTaxId === tax.id ? "bg-purple-50 border-purple-200 dark:bg-purple-900/10 dark:border-purple-800" : "bg-white dark:bg-zinc-900 border-zinc-100 dark:border-zinc-800"
                                                                                )}>
                                                                                    <input 
                                                                                        type="checkbox"
                                                                                        className="w-4 h-4 rounded text-blue-600 focus:ring-0 cursor-pointer"
                                                                                        checked={checked}
                                                                                        onChange={(e) => {
                                                                                                const newProds = [...formData.products];
                                                                                                let newApplied = [...(cp.appliedTaxes || [])];
                                                                                                if (e.target.checked) {
                                                                                                    const baseForCalc = cp.mainTaxId 
                                                                                                        ? (newApplied.find((at: any) => at.chargeAndTaxId === cp.mainTaxId)?.amount || 0)
                                                                                                        : (cp.price * cp.quantity);
                                                                                                    const initialAmount = tax.valueType === 'PERCENTAGE' ? (baseForCalc * tax.value / 100) : tax.value * cp.quantity;
                                                                                                    newApplied.push({ chargeAndTaxId: tax.id, amount: initialAmount });
                                                                                                } else {
                                                                                                    newApplied = newApplied.filter((at: any) => at.chargeAndTaxId !== tax.id);
                                                                                                }
                                                                                                newProds[idx] = { ...cp, appliedTaxes: newApplied };
                                                                                                setFormData({ ...formData, products: newProds });
                                                                                            }}
                                                                                        />
                                                                                    <div className="flex-1 min-w-0 flex items-center justify-between gap-2">
                                                                                        <div className="text-[10px] font-black text-zinc-600 dark:text-zinc-400 truncate uppercase mt-0.5">{tax.name}</div>
                                                                                        {checked && (
                                                                                            <div className="relative w-24">
                                                                                                <DollarSign className="absolute left-1.5 top-1/2 -translate-y-1/2 w-2.5 h-2.5 text-zinc-400" />
                                                                                                <input 
                                                                                                    type="number"
                                                                                                    className="w-full h-8 bg-zinc-50 dark:bg-zinc-800 rounded-lg pl-5 pr-2 text-[11px] font-black text-zinc-700 dark:text-zinc-200 outline-none border border-zinc-200 dark:border-zinc-700 focus:border-blue-500 shadow-inner"
                                                                                                    value={appliedTax.amount || ''}
                                                                                                    onChange={(e) => {
                                                                                                        const val = parseFloat(e.target.value) || 0;
                                                                                                        const newProds = [...formData.products];
                                                                                                        let newApplied = cp.appliedTaxes.map((at: any) => 
                                                                                                            at.chargeAndTaxId === tax.id ? { ...at, amount: val } : at
                                                                                                        );

                                                                                                        if (cp.mainTaxId === tax.id) {
                                                                                                            newApplied = newApplied.map((at: any) => {
                                                                                                                if (at.chargeAndTaxId === tax.id) return at;
                                                                                                                const originalTax = taxes.find(t => t.id === at.chargeAndTaxId);
                                                                                                                if (originalTax?.valueType === 'PERCENTAGE') {
                                                                                                                    return { ...at, amount: (originalTax.value / 100) * val };
                                                                                                                }
                                                                                                                return at;
                                                                                                            });
                                                                                                        }

                                                                                                        let newPrice = cp.price;
                                                                                                        if (cp.mainTaxId === tax.id) {
                                                                                                            newPrice = val / (cp.quantity || 1);
                                                                                                        }
                                                                                                        newProds[idx] = { ...cp, price: newPrice, appliedTaxes: newApplied };
                                                                                                        setFormData({ ...formData, products: newProds });
                                                                                                    }}
                                                                                                />
                                                                                            </div>
                                                                                        )}
                                                                                    </div>
                                                                                </div>
                                                                            );
                                                                        })}
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>
                                    ) : activeTab === 'variables' ? (
                                        <>
                                            <Input label="Código Único" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. TKT-VUELO" />
                                            <Input label="Nombre de Variable" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Número de Tiquete / Reserva" />
                                            <label className="flex items-center space-x-3 cursor-pointer p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-xl border border-zinc-200 dark:border-zinc-700/50 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors mt-2">
                                                <input
                                                    type="checkbox"
                                                    className="w-5 h-5 rounded text-blue-600 focus:ring-blue-500 border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900"
                                                    checked={Boolean(formData.isForAllClients)}
                                                    onChange={(e) => setFormData({ ...formData, isForAllClients: e.target.checked })}
                                                />
                                                <div className="flex flex-col">
                                                    <span className="text-xs font-bold text-zinc-900 dark:text-white">Aplica para todos los clientes</span>
                                                    <span className="text-[11px] text-zinc-500">Si se marca, esta variable aparecerá para todos los clientes al cotizar o facturar. Si no, solo aparecerá para los clientes que la tengan obligatoria.</span>
                                                </div>
                                            </label>
                                        </>
                                    ) : activeTab === 'parametros' ? (
                                        <>
                                            <Input label="Código Único" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. EMPRESA_NIT" />
                                            <Input label="Nombre descriptivo" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. NIT de la Empresa" />
                                            {formData.code === 'PRODUCTO_RESERVA_GDS' || formData.code === 'DEFAULT_GDS_PRODUCT_ID' || formData.code?.toUpperCase().includes('PRODUCTO') ? (
                                                <div className="space-y-2 group">
                                                    <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">
                                                        Producto por Defecto
                                                    </label>
                                                    <SearchSelect
                                                        options={(products || []).map((p: any) => ({
                                                            ...p,
                                                            name: `${p.description || p.name || p.code} ${p.code ? `(${p.code})` : ''}`,
                                                            code: p.code || p.id.toString()
                                                        }))}
                                                        value={formData.value || ''}
                                                        onChange={(val) => setFormData({ ...formData, value: val })}
                                                        labelKey="name"
                                                        secondaryKey="code"
                                                        placeholder="Buscar y seleccionar Producto del Maestro..."
                                                    />
                                                    <p className="text-[11px] text-zinc-400 pl-1">
                                                        Selecciona el producto maestro que se asignará automáticamente a las reservas/tiquetes importados de GDS.
                                                    </p>
                                                </div>
                                            ) : (
                                                <Input label="Valor" value={formData.value || ''} onChange={(v: string) => setFormData({ ...formData, value: v })} required placeholder="Ej. 900.000.000-1" />
                                            )}
                                        </>
                                    ) : activeTab === 'equivalencias' ? (
                                        <>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Interface</label>
                                                <SearchSelect 
                                                    options={interfacesList} 
                                                    value={formData.id_interfaces} 
                                                    onChange={(val) => setFormData({ ...formData, id_interfaces: val })}
                                                    labelKey="name"
                                                    placeholder="Seleccionar Interface"
                                                />
                                            </div>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Maestro</label>
                                                <SearchSelect 
                                                    options={masterList} 
                                                    value={formData.id_master} 
                                                    onChange={(val) => {
                                                        setFormData({ ...formData, id_master: val, cd_maestro: '' })
                                                    }}
                                                    labelKey="name"
                                                    placeholder="Seleccionar Maestro"
                                                />
                                            </div>
                                            {(() => {
                                                const selectedMaster = formData.id_master ? masterList.find((m: any) => m.id == formData.id_master) : null;
                                                return (
                                                    <div className="space-y-2 group">
                                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Código Maestro {selectedMaster ? `(${selectedMaster.name})` : ''}</label>
                                                        {selectedMaster && dynamicMasterOptions.length > 0 ? (
                                                            <>
                                                                <SearchSelect 
                                                                    options={dynamicMasterOptions} 
                                                                    value={formData.cd_maestro} 
                                                                    onChange={(val) => {
                                                                        const selectedItem = dynamicMasterOptions.find(o => String(o.id) === String(val) || String(o.code) === String(val) || String(o.document) === String(val));
                                                                        setFormData({ ...formData, cd_maestro: selectedItem?.code || selectedItem?.document || selectedItem?.id?.toString() || '' })
                                                                    }}
                                                                    labelKey="name"
                                                                    secondaryKey={selectedMaster.code === 'Client' ? 'document' : 'code'}
                                                                    placeholder={`Seleccionar registro en ${selectedMaster.name}`}
                                                                />
                                                                {formData.cd_maestro && (
                                                                    <div className="text-[10px] text-blue-600 font-black uppercase">
                                                                        Código interno seleccionado: {formData.cd_maestro}
                                                                    </div>
                                                                )}
                                                            </>
                                                        ) : (
                                                            <div className="relative">
                                                                <input
                                                                    type="text"
                                                                    className={`w-full h-11 sm:h-12 rounded-xl px-3 sm:px-4 border outline-none flex items-center justify-between text-left text-xs sm:text-sm font-medium ${!selectedMaster ? 'bg-zinc-100 dark:bg-zinc-800/50 border-zinc-200/50 dark:border-zinc-800/50 text-zinc-400 cursor-not-allowed' : 'bg-zinc-50 dark:bg-zinc-800 border-zinc-200 dark:border-zinc-700 dark:text-white focus:ring-2 focus:ring-blue-500'}`}
                                                                    value={formData.cd_maestro || ''}
                                                                    onChange={(e) => setFormData({ ...formData, cd_maestro: e.target.value })}
                                                                    disabled={!selectedMaster}
                                                                    placeholder={selectedMaster ? "Escriba el código del maestro" : "Seleccione un Maestro primero..."}
                                                                />
                                                            </div>
                                                        )}
                                                    </div>
                                                );
                                            })()}
                                            <Input label="Código Equivalente" value={formData.cd_codigo || ''} onChange={(v: string) => setFormData({ ...formData, cd_codigo: v })} required placeholder="Ej. BOG" />
                                        </>
                                    ) : activeTab === 'extraccion-interfaces' ? (
                                        <>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Interfaz GDS / Sistema</label>
                                                <SearchSelect 
                                                    options={interfacesList} 
                                                    value={formData.interfaceId} 
                                                    onChange={(val) => setFormData({ ...formData, interfaceId: val })}
                                                    labelKey="name"
                                                    placeholder="Seleccionar Interfaz"
                                                />
                                            </div>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Seleccionar o Escribir Campo Fijo</label>
                                                <div className="grid grid-cols-2 gap-2 mb-1">
                                                    {['Client', 'Seller', 'TicketPrinter', 'Branch', 'Implant', 'CostCenter'].map(code => (
                                                        <button
                                                            type="button"
                                                            key={code}
                                                            onClick={() => {
                                                                const nameMap: Record<string, string> = {
                                                                    Client: 'Cliente',
                                                                    Seller: 'Vendedor',
                                                                    TicketPrinter: 'Tiqueteador',
                                                                    Branch: 'Sucursal',
                                                                    Implant: 'Implante',
                                                                    CostCenter: 'Centro de Costo'
                                                                };
                                                                setFormData({
                                                                    ...formData,
                                                                    fieldCode: code,
                                                                    fieldName: nameMap[code] || code,
                                                                    prefix: formData.prefix || (code === 'Client' ? 'RM*NC-' : code === 'Seller' ? 'RM*VE-' : code === 'TicketPrinter' ? 'RM*TK-' : code === 'Branch' ? 'RM*SUC-' : code === 'Implant' ? 'RM*IMP-' : 'RM*CC-')
                                                                });
                                                            }}
                                                            className={`text-xs p-2 rounded-lg border font-bold text-left transition-all ${formData.fieldCode === code ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-300' : 'border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:border-zinc-800 text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-800'}`}
                                                        >
                                                            {code === 'Client' ? 'Cliente' : code === 'Seller' ? 'Vendedor' : code === 'TicketPrinter' ? 'Tiqueteador' : code === 'Branch' ? 'Sucursal' : code === 'Implant' ? 'Implante' : 'Centro Costo'}
                                                        </button>
                                                    ))}
                                                </div>
                                            </div>
                                            {variables && variables.length > 0 && (
                                                <div className="space-y-2 group">
                                                    <label className="text-xs font-black text-blue-600 dark:text-blue-400 uppercase tracking-widest pl-1">
                                                        Variables Adicionales del Sistema (MasterVariable)
                                                    </label>
                                                    <SearchSelect 
                                                        options={variables}
                                                        value={formData.fieldCode}
                                                        onChange={(val) => {
                                                            const vItem = variables.find((v: any) => String(v.id) === String(val) || String(v.code) === String(val));
                                                            if (vItem) {
                                                                setFormData({
                                                                    ...formData,
                                                                    fieldCode: vItem.code || String(vItem.id),
                                                                    fieldName: vItem.name || vItem.code,
                                                                    prefix: formData.prefix || `RM*${(vItem.code || 'VAR').toUpperCase()}-`
                                                                });
                                                            }
                                                        }}
                                                        labelKey="name"
                                                        secondaryKey="code"
                                                        placeholder="Seleccionar Variable Adicional (ej. centro de costo)"
                                                    />
                                                </div>
                                            )}
                                            <Input label="Código del Campo (ID Interno)" value={formData.fieldCode || ''} onChange={(v: string) => setFormData({ ...formData, fieldCode: v })} required placeholder="Ej: Client, Seller, TicketPrinter, Branch, Implant, 001..." />
                                            <Input label="Nombre Descriptivo del Campo" value={formData.fieldName || ''} onChange={(v: string) => setFormData({ ...formData, fieldName: v })} required placeholder="Ej: Cliente, Vendedor, Tiqueteador, Sucursal, Implante, centro de costo..." />
                                            <Input label="Prefijo / Constante en Archivo (PNR Remark)" value={formData.prefix || ''} onChange={(v: string) => setFormData({ ...formData, prefix: v })} required placeholder="Ej: RM*NC-, RM*VE-, RM*TK-, RM*SUC-, RM*IMP-, RM*CC-..." />
                                            <Input label="Delimitador / Separador Final (Opcional)" value={formData.delimiter || ''} onChange={(v: string) => setFormData({ ...formData, delimiter: v })} placeholder="Ej: - o / (por defecto -)" />
                                        </>
                                    ) : activeTab === 'resoluciones-documentos' ? (
                                        <>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Sucursal</label>
                                                <SearchSelect 
                                                    options={branches} 
                                                    value={formData.branchId} 
                                                    onChange={(val) => setFormData({ ...formData, branchId: val })}
                                                    labelKey="name"
                                                    placeholder="Seleccionar Sucursal"
                                                />
                                            </div>
                                            <div className="space-y-2 group">
                                                <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Implante (Opcional)</label>
                                                <SearchSelect 
                                                    options={implants} 
                                                    value={formData.implantId} 
                                                    onChange={(val) => setFormData({ ...formData, implantId: val })}
                                                    labelKey="name"
                                                    placeholder="Todas / Sin Implante Específico"
                                                />
                                            </div>
                                            <Input label="Número de Resolución DIAN / ERP" value={formData.resolutionNumber || ''} onChange={(v: string) => setFormData({ ...formData, resolutionNumber: v })} required placeholder="Ej. 187600000001" />
                                            <div className="grid grid-cols-3 gap-4">
                                                <Input label="Num. Inicial" value={formData.initialNumber || ''} onChange={(v: string) => setFormData({ ...formData, initialNumber: v })} type="number" required placeholder="Ej. 1" />
                                                <Input label="Num. Final" value={formData.finalNumber || ''} onChange={(v: string) => setFormData({ ...formData, finalNumber: v })} type="number" required placeholder="Ej. 5000" />
                                                <Input label="Consecutivo Actual" value={formData.currentNumber || ''} onChange={(v: string) => setFormData({ ...formData, currentNumber: v })} type="number" placeholder="Ej. 1" />
                                            </div>
                                            <div className="grid grid-cols-3 gap-4">
                                                <Input label="Prefijo (Opcional)" value={formData.prefix || ''} onChange={(v: string) => setFormData({ ...formData, prefix: v })} placeholder="Ej. FE, FAC, SET" />
                                                <Input label="Fecha Resolución" value={formData.resolutionDate ? String(formData.resolutionDate).substring(0, 10) : ''} onChange={(v: string) => setFormData({ ...formData, resolutionDate: v })} type="date" required />
                                                <Input label="Fecha Vencimiento" value={formData.expirationDate ? String(formData.expirationDate).substring(0, 10) : ''} onChange={(v: string) => setFormData({ ...formData, expirationDate: v })} type="date" required />
                                            </div>
                                            <div className="flex items-center gap-3 pt-2">
                                                <input 
                                                    type="checkbox" 
                                                    id="isActiveRes" 
                                                    checked={formData.isActive !== false} 
                                                    onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                                                    className="w-5 h-5 accent-blue-600 rounded"
                                                />
                                                <label htmlFor="isActiveRes" className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
                                                    Resolución Activa (Desactivará automáticamente otras resoluciones activas de la misma sucursal/implante)
                                                </label>
                                            </div>
                                        </>
                                    ) : activeTab === 'consecutivos-transacciones' ? (
                                        <>
                                            <Input label="Tipo de Transacción (Código)" value={formData.transactionType || ''} onChange={(v: string) => setFormData({ ...formData, transactionType: v })} required placeholder="Ej. INVOICE, CREDIT_NOTE, QUOTATION" />
                                            <Input label="Descripción de la Transacción" value={formData.description || ''} onChange={(v: string) => setFormData({ ...formData, description: v })} required placeholder="Ej. Facturación Electrónica de Venta" />
                                            <div className="grid grid-cols-3 gap-4">
                                                <Input label="Prefijo" value={formData.prefix || ''} onChange={(v: string) => setFormData({ ...formData, prefix: v })} placeholder="Ej. INV, NC, COT" />
                                                <Input label="Número Inicial" value={formData.initialNumber || ''} onChange={(v: string) => setFormData({ ...formData, initialNumber: v })} type="number" required placeholder="Ej. 1001" />
                                                <Input label="Consecutivo Actual / Próximo" value={formData.currentNumber || ''} onChange={(v: string) => setFormData({ ...formData, currentNumber: v })} type="number" placeholder="Ej. 1001" />
                                            </div>
                                            <div className="grid grid-cols-2 gap-4">
                                                <div className="space-y-2 group">
                                                    <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Sucursal (Opcional)</label>
                                                    <SearchSelect 
                                                        options={branches} 
                                                        value={formData.branchId} 
                                                        onChange={(val) => setFormData({ ...formData, branchId: val })}
                                                        labelKey="name"
                                                        placeholder="Todas las Sucursales"
                                                    />
                                                </div>
                                                <div className="space-y-2 group">
                                                    <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Implante (Opcional)</label>
                                                    <SearchSelect 
                                                        options={implants} 
                                                        value={formData.implantId} 
                                                        onChange={(val) => setFormData({ ...formData, implantId: val })}
                                                        labelKey="name"
                                                        placeholder="Todos los Implantes"
                                                    />
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-3 pt-2">
                                                <input 
                                                    type="checkbox" 
                                                    id="isActiveConsec" 
                                                    checked={formData.isActive !== false} 
                                                    onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                                                    className="w-5 h-5 accent-blue-600 rounded"
                                                />
                                                <label htmlFor="isActiveConsec" className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
                                                    Consecutivo Activo
                                                </label>
                                            </div>
                                        </>
                                    ) : activeTab === 'tarjetas-credito' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. VISA" />
                                            <Input label="Nombre de la Tarjeta" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Visa" />
                                        </>
                                    ) : activeTab === 'formas-pago' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. EF" />
                                            <Input label="Nombre de Forma de Pago" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Efectivo" />
                                        </>
                                    ) : activeTab === 'paises' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. CO" />
                                            <Input label="Nombre del País" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Colombia" />
                                        </>
                                    ) : activeTab === 'ciudades' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. BOG" />
                                            <Input label="Nombre de la Ciudad" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Bogotá" />
                                        </>
                                    ) : activeTab === 'aeropuertos' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. BOG" />
                                            <Input label="Nombre del Aeropuerto" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. El Dorado" />
                                        </>
                                    ) : activeTab === 'tipos-tiquetes' ? (
                                        <>
                                            <Input label="Código" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. INTERNACIONAL" />
                                            <Input label="Nombre" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Tiquete Internacional" />
                                            <Input label="Descripción" value={formData.description || ''} onChange={(v: string) => setFormData({ ...formData, description: v })} placeholder="Descripción opcional" />
                                        </>
                                    ) : activeTab === 'estados-cotizacion' ? (
                                        <>
                                            <Input label="Código (Único)" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. NUEVO" />
                                            <Input label="Nombre del Estado" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Nuevo" />
                                            <Input label="Color (Opcional)" value={formData.color || ''} onChange={(v: string) => setFormData({ ...formData, color: v })} placeholder="Ej. blue, emerald, red o código hex" />
                                        </>
                                    ) : activeTab === 'tipos-proveedores' ? (
                                        <>
                                            <Input label="Código Único" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. AERO" />
                                            <Input label="Nombre del Tipo de Proveedor" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Aerolínea / Hotel" />
                                            <div className="flex items-center gap-3 p-4 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-dashed border-zinc-200 dark:border-zinc-700">
                                                <input
                                                    type="checkbox"
                                                    id="isAirline"
                                                    className="w-5 h-5 rounded-lg border-zinc-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                    checked={formData.isAirline || false}
                                                    onChange={(e) => setFormData({ ...formData, isAirline: e.target.checked })}
                                                />
                                                <label htmlFor="isAirline" className="text-sm font-bold text-zinc-700 dark:text-zinc-300 cursor-pointer">
                                                    ¿Es Aerolínea?
                                                    <span className="block text-[10px] font-medium text-zinc-400 uppercase tracking-wider mt-0.5">Si se marca, habilitará los campos de Código IATA y Sigla en los proveedores asociados.</span>
                                                </label>
                                            </div>
                                        </>
                                    ) : (
                                        <>
                                            <Input label="Código Único" value={formData.code || ''} onChange={(v: string) => setFormData({ ...formData, code: v })} required placeholder="Ej. BOG-01" />
                                            <Input label="Nombre / Descripción" value={formData.name || ''} onChange={(v: string) => setFormData({ ...formData, name: v })} required placeholder="Ej. Sede Norte Bogotá" />
                                            {activeTab === 'sucursales' && (
                                                <>
                                                    <div className="space-y-2 mt-4">
                                                        <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">Logo de Sucursal (Opcional)</label>
                                                        <div className="flex items-center gap-4">
                                                            {formData.logo && (
                                                                <img src={formData.logo} alt="Logo preview" className="w-16 h-16 object-contain bg-white rounded-xl border border-zinc-200" />
                                                            )}
                                                            <input 
                                                                type="file" 
                                                                accept="image/*"
                                                                onChange={(e) => {
                                                                    const file = e.target.files?.[0];
                                                                    if (file) {
                                                                        const reader = new FileReader();
                                                                        reader.onloadend = () => {
                                                                            setFormData({ ...formData, logo: reader.result });
                                                                        };
                                                                        reader.readAsDataURL(file);
                                                                    }
                                                                }}
                                                                className="w-full text-sm text-zinc-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                                                            />
                                                        </div>
                                                    </div>
                                                    {/* Excel Template and Configuration Section */}
                                                    <div className="border-t border-zinc-200 dark:border-zinc-800 pt-6 mt-6 space-y-4">
                                                        <div className="flex items-center justify-between">
                                                            <h4 className="text-sm font-black text-zinc-800 dark:text-zinc-200 uppercase tracking-wider">
                                                                Plantilla de Reporte Excel
                                                            </h4>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="file"
                                                                    id="branch-json-import-input"
                                                                    accept=".json"
                                                                    className="hidden"
                                                                    onChange={(e) => {
                                                                        const file = e.target.files?.[0];
                                                                        if (!file) return;
                                                                        const reader = new FileReader();
                                                                        reader.onload = (evt) => {
                                                                            try {
                                                                                const json = JSON.parse(evt.target?.result as string);
                                                                                if (!json.templateConfig && !json.template && !json.cellCustomizations) {
                                                                                    alert('El archivo JSON no contiene una configuración de formato válida.');
                                                                                    return;
                                                                                }

                                                                                let newConfig = { ...(formData.templateConfig || {}), ...(json.templateConfig || {}) };
                                                                                if (Array.isArray(json.cellCustomizations)) {
                                                                                    json.cellCustomizations.forEach((c: any) => {
                                                                                        if (c.code && c.value) {
                                                                                            newConfig[c.code] = c.value;
                                                                                        }
                                                                                    });
                                                                                }

                                                                                setFormData((prev: any) => ({
                                                                                    ...prev,
                                                                                    template: json.template || prev.template,
                                                                                    hasTemplate: !!(json.template || prev.hasTemplate),
                                                                                    templateConfig: newConfig,
                                                                                    clearTemplate: false,
                                                                                }));

                                                                                alert(`✅ Configuración importada correctamente desde "${file.name}".\n\nHaga clic en "Confirmar Registro" o "Guardar" para aplicar los cambios en la sucursal.`);
                                                                            } catch (err: any) {
                                                                                alert('Error al leer el archivo JSON: ' + err.message);
                                                                            }
                                                                        };
                                                                        reader.readAsText(file);
                                                                        e.target.value = '';
                                                                    }}
                                                                />
                                                                <button
                                                                    type="button"
                                                                    onClick={() => document.getElementById('branch-json-import-input')?.click()}
                                                                    className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 rounded-xl text-xs font-bold transition-all border border-emerald-200 dark:border-emerald-800 shrink-0"
                                                                    title="Importar plantilla y mapeo de celdas desde un archivo JSON exportado"
                                                                >
                                                                    <Upload className="w-3.5 h-3.5" />
                                                                    <span>Importar JSON</span>
                                                                </button>
                                                                {formData.id && formData.hasTemplate && (
                                                                    <button
                                                                        type="button"
                                                                        onClick={async () => {
                                                                            try {
                                                                                const res = await fetch(`/api/config/branches/${formData.id}?export=true`);
                                                                                if (!res.ok) throw new Error('Error exportando');
                                                                                const blob = await res.blob();
                                                                                const url = URL.createObjectURL(blob);
                                                                                const a = document.createElement('a');
                                                                                const safe = (formData.name || 'sucursal').replace(/[^a-zA-Z0-9_-]/g, '_');
                                                                                a.href = url;
                                                                                a.download = `formato_${safe}.json`;
                                                                                a.click();
                                                                                URL.revokeObjectURL(url);
                                                                            } catch (err: any) {
                                                                                alert('Error al exportar: ' + err.message);
                                                                            }
                                                                        }}
                                                                        className="flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-600 rounded-xl text-xs font-bold transition-all border border-blue-100 shrink-0"
                                                                        title="Exportar configuración como JSON para importar en Formatos de Cotización u otra sucursal"
                                                                    >
                                                                        <Download className="w-3.5 h-3.5" />
                                                                        <span>Exportar Configuración</span>
                                                                    </button>
                                                                )}
                                                            </div>
                                                        </div>
                                                        <div className="space-y-2">
                                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1">
                                                                Archivo de Plantilla (.xlsx, .xls)
                                                            </label>
                                                            <div className="flex items-center gap-4">
                                                                <input 
                                                                     type="file" 
                                                                     id="branch-template-file-input"
                                                                     accept=".xlsx,.xls"
                                                                     onChange={(e) => {
                                                                         const file = e.target.files?.[0];
                                                                         if (file) {
                                                                             const reader = new FileReader();
                                                                             reader.onloadend = () => {
                                                                                 setFormData({ ...formData, template: reader.result, clearTemplate: false });
                                                                             };
                                                                             reader.readAsDataURL(file);
                                                                         }
                                                                     }}
                                                                     className="w-full text-sm text-zinc-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-emerald-700 hover:file:bg-emerald-100"
                                                                 />
                                                                 {formData.hasTemplate && !formData.template && !formData.clearTemplate && (
                                                                     <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-md shrink-0">
                                                                         ✓ Guardada
                                                                     </span>
                                                                 )}
                                                                 {formData.template && (
                                                                     <span className="text-xs font-bold text-blue-600 bg-blue-50 px-2.5 py-1 rounded-md shrink-0">
                                                                         ✓ Nueva
                                                                     </span>
                                                                 )}
                                                                 {((formData.hasTemplate && !formData.clearTemplate) || formData.template) && (
                                                                     <button
                                                                         type="button"
                                                                         onClick={() => {
                                                                             setFormData({ ...formData, template: null, hasTemplate: false, clearTemplate: true });
                                                                             const fileInput = document.getElementById('branch-template-file-input') as HTMLInputElement;
                                                                             if (fileInput) fileInput.value = '';
                                                                         }}
                                                                         className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 hover:text-red-700 rounded-xl text-xs font-bold transition-all border border-red-100 shrink-0"
                                                                         title="Eliminar plantilla actual de la base de datos"
                                                                     >
                                                                         <Trash2 className="w-3.5 h-3.5" />
                                                                         <span>Eliminar</span>
                                                                     </button>
                                                                 )}
                                                            </div>
                                                        </div>

                                                        {/* ── Copiar formato desde otra sucursal ── */}
                                                        {formData.id && (
                                                            <div className="border border-dashed border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-950/30 rounded-2xl p-4 space-y-3">
                                                                <div className="flex items-center gap-2">
                                                                    <Copy className="w-4 h-4 text-blue-500" />
                                                                    <span className="text-xs font-black text-blue-700 dark:text-blue-300 uppercase tracking-widest">Copiar formato desde otra sucursal</span>
                                                                </div>
                                                                <p className="text-xs text-zinc-500 dark:text-zinc-400">
                                                                    Copia la plantilla Excel y la configuración de celdas de otra sucursal hacia <b>{formData.name}</b>. Esto reemplazará el formato actual de esta sucursal.
                                                                </p>
                                                                <div className="flex items-center gap-3 flex-wrap">
                                                                    <select
                                                                        value={copyTemplateSrcId}
                                                                        onChange={e => setCopyTemplateSrcId(e.target.value)}
                                                                        className="flex-1 min-w-[180px] h-10 px-3 rounded-xl border border-blue-200 dark:border-blue-700 bg-white dark:bg-zinc-900 text-sm font-medium focus:outline-none focus:ring-2 focus:ring-blue-500"
                                                                    >
                                                                        <option value="">— Seleccionar sucursal origen —</option>
                                                                        {branches
                                                                            .filter((b: any) => b.id !== formData.id && b.hasTemplate)
                                                                            .map((b: any) => (
                                                                                <option key={b.id} value={b.id}>[{b.code}] {b.name}</option>
                                                                            ))
                                                                        }
                                                                    </select>
                                                                    <button
                                                                        type="button"
                                                                        disabled={!copyTemplateSrcId || copyingTemplate}
                                                                        onClick={async () => {
                                                                            if (!copyTemplateSrcId) return
                                                                            const srcBranch = branches.find((b: any) => String(b.id) === String(copyTemplateSrcId))
                                                                            if (!confirm(`¿Copiar el formato de "${srcBranch?.name}" hacia "${formData.name}"?\n\nEsto reemplazará el formato actual de ${formData.name}.`)) return
                                                                            setCopyingTemplate(true)
                                                                            try {
                                                                                const res = await fetch('/api/config/branches/copy-template', {
                                                                                    method: 'POST',
                                                                                    headers: { 'Content-Type': 'application/json' },
                                                                                    body: JSON.stringify({
                                                                                        sourceBranchId: parseInt(copyTemplateSrcId),
                                                                                        targetBranchId: formData.id
                                                                                    })
                                                                                })
                                                                                const result = await res.json()
                                                                                if (!res.ok) throw new Error(result.message || 'Error')
                                                                                alert('✅ ' + result.message)
                                                                                setCopyTemplateSrcId('')
                                                                                setFormData({ ...formData, hasTemplate: true })
                                                                            } catch(err: any) {
                                                                                alert('Error: ' + err.message)
                                                                            } finally {
                                                                                setCopyingTemplate(false)
                                                                            }
                                                                        }}
                                                                        className="h-10 px-5 bg-blue-600 hover:bg-blue-700 disabled:opacity-40 text-white rounded-xl text-xs font-black flex items-center gap-2 transition-all shrink-0"
                                                                    >
                                                                        {copyingTemplate ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Copy className="w-3.5 h-3.5" />}
                                                                        {copyingTemplate ? 'Copiando...' : 'Copiar Formato'}
                                                                    </button>
                                                                </div>
                                                                {branches.filter((b: any) => b.id !== formData.id && b.hasTemplate).length === 0 && (
                                                                    <p className="text-xs text-amber-600 dark:text-amber-400 font-medium">Ninguna otra sucursal tiene un formato de plantilla configurado.</p>
                                                                )}
                                                            </div>
                                                        )}

                                                        {/* Coordinates Editor */}
                                                        <div className="space-y-3">
                                                            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1 block">
                                                                Coordenadas de Celdas (Ej. B4, G4)
                                                            </label>
                                                            
                                                            <details className="group border border-zinc-200 dark:border-zinc-800 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 overflow-hidden">
                                                                <summary className="p-4 font-bold text-xs uppercase cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800/50 flex items-center justify-between dark:text-zinc-300">
                                                                    <span>Personalizar Mapeo de Celdas</span>
                                                                    <span className="text-zinc-400 group-open:rotate-180 transition-transform">▼</span>
                                                                </summary>
                                                                <div className="p-4 border-t border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 space-y-4">
                                                                    <div className="overflow-x-auto max-h-96 overflow-y-auto">
                                                                        <table className="w-full text-left text-xs border-collapse">
                                                                            <thead>
                                                                                <tr className="border-b border-zinc-200 dark:border-zinc-800 text-zinc-400 font-bold uppercase tracking-wider">
                                                                                    <th className="py-2 px-3">Campo / Descripción</th>
                                                                                    <th className="py-2 px-3">Token / Código</th>
                                                                                    <th className="py-2 px-3 w-32">Coordenada</th>
                                                                                    <th className="py-2 px-3 w-28 text-center">Acción</th>
                                                                                </tr>
                                                                            </thead>
                                                                            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
                                                                                {(() => {
                                                                                    const config = formData.templateConfig || {};
                                                                                    const customNames = config.__customNames || {};
                                                                                    const defaultPlaceholders: Record<string, string> = {
                                                                                        asesor: "B4", fecha: "G4", clienteNombre: "B7", clienteIdentificacion: "G7",
                                                                                        clienteDireccion: "B8", clienteTelefono: "G8", centroCosto: "B9", solicita: "G9",
                                                                                        tCambio: "G11", descripcionPlan: "B12", fechasViaje: "G12", hotelesServicios: "A13",
                                                                                        pasajeros: "B14", totalAdultos: "C15", totalNinos: "G15", logo: "A1"
                                                                                    };

                                                                                    let mappedKeys = Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                                    if (config && Array.isArray(config.__keysOrder)) {
                                                                                        const ordered = config.__keysOrder.filter((k: string) => k in config);
                                                                                        const missing = mappedKeys.filter(k => !ordered.includes(k));
                                                                                        mappedKeys = [...ordered, ...missing];
                                                                                    }
                                                                                    
                                                                                    const allFields = mappedKeys.map(key => ({
                                                                                        key,
                                                                                        label: getFieldLabel(key),
                                                                                        isCustom: key.startsWith('col_') || !!customNames[key]
                                                                                    }));

                                                                                    const DEFAULT_CONFIG = defaultPlaceholders as any;

                                                                                    return allFields.map((f, idx) => (
                                                                                        <tr key={f.key} className="hover:bg-zinc-50 dark:hover:bg-zinc-800/30 transition-all">
                                                                                            <td className="py-2 px-3 font-semibold text-zinc-700 dark:text-zinc-300">
                                                                                                {f.isCustom ? (
                                                                                                    <input 
                                                                                                        type="text"
                                                                                                        value={f.label}
                                                                                                        onChange={(e) => {
                                                                                                            const newNames = { ...customNames, [f.key]: e.target.value };
                                                                                                            const newConfig = { ...config, __customNames: newNames };
                                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                                        }}
                                                                                                        className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                                                        placeholder="Nombre del campo"
                                                                                                    />
                                                                                                ) : (
                                                                                                    <span>{f.label}</span>
                                                                                                )}
                                                                                            </td>
                                                                                            <td className="py-2 px-3 font-mono text-[10px] text-zinc-400">
                                                                                                {f.isCustom ? (
                                                                                                    <input 
                                                                                                        type="text"
                                                                                                        value={f.key}
                                                                                                        onChange={(e) => {
                                                                                                            const newKey = e.target.value.replace(/[^a-zA-Z0-9]/g, '');
                                                                                                            if (!newKey || newKey === '__customNames') return;
                                                                                                            
                                                                                                            const newNames = { ...customNames };
                                                                                                            const newConfig = { ...config };
                                                                                                            
                                                                                                            const val = newConfig[f.key];
                                                                                                            delete newConfig[f.key];
                                                                                                            newConfig[newKey] = val || '';
                                                                                                            
                                                                                                            const label = newNames[f.key];
                                                                                                            delete newNames[f.key];
                                                                                                            newNames[newKey] = label || f.label;
                                                                                                            
                                                                                                            newConfig.__customNames = newNames;
                                                                                                            
                                                                                                            // Actualizar la clave en __keysOrder
                                                                                                            if (Array.isArray(config.__keysOrder)) {
                                                                                                                newConfig.__keysOrder = config.__keysOrder.map((k: string) => k === f.key ? newKey : k);
                                                                                                            }
                                                                                                            
                                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                                        }}
                                                                                                        className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                                                        placeholder="token"
                                                                                                    />
                                                                                                ) : (
                                                                                                    <span>{f.key}</span>
                                                                                                )}
                                                                                            </td>
                                                                                            <td className="py-2 px-3">
                                                                                                <input 
                                                                                                    type="text"
                                                                                                    value={config[f.key] || ''}
                                                                                                    onChange={(e) => {
                                                                                                        const val = e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
                                                                                                        const newConfig = { ...config, [f.key]: val };
                                                                                                        setFormData({ ...formData, templateConfig: newConfig });
                                                                                                    }}
                                                                                                    placeholder={DEFAULT_CONFIG[f.key as keyof typeof DEFAULT_CONFIG] || 'A1'}
                                                                                                    className="w-full h-8 px-2 rounded-lg bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-semibold focus:ring-1 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white uppercase"
                                                                                                />
                                                                                            </td>
                                                                                            <td className="py-2 px-3 text-center">
                                                                                                <div className="flex items-center justify-center gap-1.5">
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        disabled={idx === 0}
                                                                                                        onClick={() => {
                                                                                                            const keys = [...mappedKeys];
                                                                                                            const temp = keys[idx];
                                                                                                            keys[idx] = keys[idx - 1];
                                                                                                            keys[idx - 1] = temp;
                                                                                                            
                                                                                                            const newConfig: any = {};
                                                                                                            keys.forEach(k => {
                                                                                                                newConfig[k] = config[k];
                                                                                                            });
                                                                                                            newConfig.__keysOrder = keys;
                                                                                                            if (config.__customNames) newConfig.__customNames = config.__customNames;
                                                                                                            if (config.__productFields) newConfig.__productFields = config.__productFields;
                                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                                        }}
                                                                                                        className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                                                        title="Subir Posición"
                                                                                                    >
                                                                                                        <ArrowUp className="w-3.5 h-3.5" />
                                                                                                    </button>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        disabled={idx === mappedKeys.length - 1}
                                                                                                        onClick={() => {
                                                                                                            const keys = [...mappedKeys];
                                                                                                            const temp = keys[idx];
                                                                                                            keys[idx] = keys[idx + 1];
                                                                                                            keys[idx + 1] = temp;
                                                                                                            
                                                                                                            const newConfig: any = {};
                                                                                                            keys.forEach(k => {
                                                                                                                newConfig[k] = config[k];
                                                                                                            });
                                                                                                            newConfig.__keysOrder = keys;
                                                                                                            if (config.__customNames) newConfig.__customNames = config.__customNames;
                                                                                                            if (config.__productFields) newConfig.__productFields = config.__productFields;
                                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                                        }}
                                                                                                        className="p-1 text-zinc-400 hover:text-blue-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-all disabled:opacity-20 disabled:pointer-events-none"
                                                                                                        title="Bajar Posición"
                                                                                                    >
                                                                                                        <ArrowDown className="w-3.5 h-3.5" />
                                                                                                    </button>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        onClick={() => {
                                                                                                            const newNames = { ...customNames };
                                                                                                            delete newNames[f.key];
                                                                                                            const newConfig = { ...config };
                                                                                                            delete newConfig[f.key];
                                                                                                            newConfig.__customNames = newNames;
                                                                                                            if (Array.isArray(config.__keysOrder)) {
                                                                                                                newConfig.__keysOrder = config.__keysOrder.filter((k: string) => k !== f.key);
                                                                                                            }
                                                                                                            setFormData({ ...formData, templateConfig: newConfig });
                                                                                                        }}
                                                                                                        className="p-1 text-zinc-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-all"
                                                                                                        title="Eliminar del Mapeo"
                                                                                                    >
                                                                                                        <Trash2 className="w-3.5 h-3.5" />
                                                                                                    </button>
                                                                                                </div>
                                                                                            </td>
                                                                                        </tr>
                                                                                    ));
                                                                                })()}
                                                                            </tbody>
                                                                        </table>
                                                                    </div>
                                                                    <div className="flex flex-col gap-4 mt-4 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                                                                        <span className="text-[10px] font-bold text-zinc-400 uppercase tracking-wider pl-1 block">Agregar Variable de Cotización al Mapeo</span>
                                                                        <div className="flex items-center gap-3">
                                                                            <div className="flex-1">
                                                                                <select
                                                                                    id="field-selector-branch"
                                                                                    className="w-full h-10 px-3 rounded-xl bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-bold focus:ring-2 focus:ring-blue-500 outline-none text-zinc-900 dark:text-white"
                                                                                    defaultValue=""
                                                                                >
                                                                                    <option value="" disabled>-- Seleccionar Campo de Cotización --</option>
                                                                                    {renderMappingOptions()}
                                                                                </select>
                                                                            </div>
                                                                            <button
                                                                                type="button"
                                                                                onClick={() => {
                                                                                    const selectEl = document.getElementById('field-selector-branch') as HTMLSelectElement;
                                                                                    if (!selectEl || !selectEl.value) return;
                                                                                    const [key, label] = selectEl.value.split('|');
                                                                                    
                                                                                    const config = formData.templateConfig || {};
                                                                                    const customNames = config.__customNames || {};
                                                                                    
                                                                                    let finalKey = key;
                                                                                    let finalLabel = label;
                                                                                    if (key === 'custom') {
                                                                                        finalKey = 'col_' + Date.now();
                                                                                        finalLabel = 'Nueva Columna';
                                                                                    }
                                                                                    
                                                                                    const newConfig = { ...config, [finalKey]: '' };
                                                                                    if (key === 'custom' || !getFieldLabel(finalKey)) {
                                                                                        newConfig.__customNames = { ...customNames, [finalKey]: finalLabel };
                                                                                    } else if (label) {
                                                                                        newConfig.__customNames = { ...customNames, [finalKey]: finalLabel };
                                                                                    }
                                                                                    
                                                                                    let currentKeys = Array.isArray(config.__keysOrder) ? [...config.__keysOrder] : Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                                    if (!currentKeys.includes(finalKey)) {
                                                                                        currentKeys.push(finalKey);
                                                                                    }
                                                                                    newConfig.__keysOrder = currentKeys;
                                                                                    
                                                                                    setFormData({ ...formData, templateConfig: newConfig });
                                                                                    selectEl.value = "";
                                                                                }}
                                                                                className="px-4 h-10 text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white rounded-xl transition-all"
                                                                            >
                                                                                + Agregar al Mapeo
                                                                            </button>
                                                                            <button
                                                                                type="button"
                                                                                onClick={() => {
                                                                                    const config = formData.templateConfig || {};
                                                                                    const customNames = config.__customNames || {};
                                                                                    const newId = 'col_' + Date.now();
                                                                                    const newConfig = { ...config, [newId]: '' };
                                                                                    newConfig.__customNames = { ...customNames, [newId]: 'Nueva Columna' };
                                                                                    
                                                                                    let currentKeys = Array.isArray(config.__keysOrder) ? [...config.__keysOrder] : Object.keys(config).filter(k => k !== '__customNames' && k !== '__productFields' && k !== '__keysOrder');
                                                                                    if (!currentKeys.includes(newId)) {
                                                                                        currentKeys.push(newId);
                                                                                    }
                                                                                    newConfig.__keysOrder = currentKeys;
                                                                                    
                                                                                    setFormData({ ...formData, templateConfig: newConfig });
                                                                                }}
                                                                                className="px-4 h-10 text-xs font-bold bg-zinc-100 hover:bg-zinc-200 text-zinc-700 rounded-xl transition-all"
                                                                            >
                                                                                + Campo Personalizado
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </details>
                                                        </div>
                                                    </div>
                                                </>
                                            )}
                                        </>
                                    )}
                                </>
                            )}

                                </div>
                                <div className="p-10 pt-6 border-t border-zinc-100 dark:border-zinc-800 shrink-0 bg-white dark:bg-zinc-900 flex gap-4">
                                    <button
                                        type="button"
                                        onClick={() => setIsModalOpen(false)}
                                        className="flex-1 h-14 rounded-2xl bg-zinc-100 dark:bg-zinc-800 font-bold text-zinc-600 hover:bg-zinc-200 transition-all"
                                    >
                                        Descartar
                                    </button>
                                    <button
                                        type="submit"
                                        disabled={submitting}
                                        className="flex-[2] h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-black shadow-xl shadow-blue-500/20 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                                    >
                                        {submitting ? <Loader2 className="animate-spin w-5 h-5" /> : <Check className="w-6 h-6" />}
                                        Confirmar Registro
                                    </button>
                                </div>
                            </form>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
        <ErrorDiagnosticModal
            isOpen={isDiagnosticModalOpen}
            onClose={() => setIsDiagnosticModalOpen(false)}
            errorData={diagnosticError}
        />
        </div>
    )
}

function TabButton({ active, icon, label, onClick }: { active: boolean, icon: React.ReactNode, label: string, onClick: () => void }) {
    return (
        <button
            onClick={onClick}
            title={label}
            className={cn(
                "w-full flex items-center gap-2.5 px-4 h-11 rounded-2xl font-bold transition-all text-xs justify-start truncate",
                active
                    ? "bg-zinc-900 border border-zinc-700 dark:bg-zinc-100 dark:text-zinc-900 text-white shadow-lg shadow-zinc-950/20"
                    : "text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800"
            )}
        >
            <span className="shrink-0">{icon}</span>
            <span className="truncate">{label}</span>
        </button>
    )
}

function Input({ label, value, onChange, ...props }: { label: string, value: string, onChange: (v: string) => void, [key: string]: any }) {
    return (
        <div className="space-y-2 group">
            <label className="text-xs font-black text-zinc-400 uppercase tracking-widest pl-1 group-focus-within:text-blue-500 transition-colors">{label}</label>
            <input
                className="w-full h-14 bg-zinc-50 dark:bg-zinc-800 rounded-2xl px-5 border-none shadow-inner text-sm font-bold focus:ring-2 focus:ring-blue-500 transition-all outline-none"
                value={value}
                onChange={(e) => onChange(e.target.value)}
                {...props}
            />
        </div>
    )
}
