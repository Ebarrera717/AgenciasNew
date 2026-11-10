/**
 * zeus-text-formatter.ts
 * Motor universal y dinámico para parametrizar la descripción de ítems y observaciones enviadas a Zeus ERP.
 */

export interface ZeusFieldConfig {
    id: string;
    name: string;
    enabled: boolean;
    order: number;
    label: string;
}

export interface ZeusTextSectionConfig {
    separator: string;
    fields: ZeusFieldConfig[];
}

export const DEFAULT_ITEM_DESCRIPTION_CONFIG: ZeusTextSectionConfig = {
    separator: ' - ',
    fields: [
        { id: 'descripcion_manual', name: 'Descripción Manual', enabled: true, order: 1, label: 'Servicio' },
        { id: 'fecha_inicial', name: 'Fecha inicial', enabled: true, order: 2, label: 'Desde' },
        { id: 'fecha_final', name: 'Fecha final', enabled: true, order: 3, label: 'Hasta' },
        { id: 'proveedor', name: 'Proveedor', enabled: true, order: 4, label: 'Proveedor' },
        { id: 'prestador', name: 'Prestador', enabled: false, order: 5, label: 'Prestador' },
        { id: 'nacionalidad', name: 'Nacionalidad', enabled: true, order: 6, label: 'Nacionalidad' },
        { id: 'numero_cotizacion', name: 'Número de cotización', enabled: false, order: 7, label: 'Cotización' },
        { id: 'pasajero', name: 'Nombre del pasajero', enabled: false, order: 8, label: 'Pasajero' },
        { id: 'destino', name: 'Destino', enabled: false, order: 9, label: 'Destino' },
        { id: 'reservacion', name: 'Código de Reserva', enabled: false, order: 10, label: 'Reserva' }
    ]
};

export const DEFAULT_OBSERVATIONS_CONFIG: ZeusTextSectionConfig = {
    separator: ' - ',
    fields: [
        { id: 'numero_cotizacion', name: 'Número de cotización', enabled: true, order: 1, label: 'Cotización' },
        { id: 'numero_factura', name: 'Número de factura', enabled: false, order: 2, label: 'Factura' },
        { id: 'pasajero', name: 'Nombre del pasajero', enabled: true, order: 3, label: 'Pasajero' },
        { id: 'proveedor', name: 'Proveedor', enabled: false, order: 4, label: 'Proveedor' },
        { id: 'prestador', name: 'Prestador', enabled: false, order: 5, label: 'Prestador' },
        { id: 'fecha_inicial', name: 'Fecha inicial', enabled: false, order: 6, label: 'Desde' },
        { id: 'fecha_final', name: 'Fecha final', enabled: false, order: 7, label: 'Hasta' },
        { id: 'descripcion_adicional', name: 'Descripción adicional', enabled: false, order: 8, label: 'Servicios' }
    ]
};

/**
 * Normaliza y formatea una fecha a DD/MM/AAAA para presentación en Zeus
 */
export function formatDateForZeus(dateVal: any): string {
    if (!dateVal) return '';
    try {
        const str = String(dateVal).trim();
        // Si ya viene en formato de fecha ISO (YYYY-MM-DD o YYYY/MM/DD), extraer directamente sin shift de zona horaria
        if (str.match(/^\d{4}[-/]\d{2}[-/]\d{2}/)) {
            const parts = str.substring(0, 10).split(/[-/]/);
            return `${parts[2]}/${parts[1]}/${parts[0]}`;
        }
        // Si ya viene como DD/MM/YYYY o DD-MM-YYYY
        if (str.match(/^\d{2}[-/]\d{2}[-/]\d{4}/)) {
            const parts = str.substring(0, 10).split(/[-/]/);
            return `${parts[0]}/${parts[1]}/${parts[2]}`;
        }

        const d = new Date(dateVal);
        if (isNaN(d.getTime())) {
            return str;
        }
        const day = String(d.getDate()).padStart(2, '0');
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const year = d.getFullYear();
        return `${day}/${month}/${year}`;
    } catch {
        return String(dateVal);
    }
}

/**
 * Construye la descripción dinámica del ítem según la parametrización de la empresa.
 * @param itemData Datos del ítem de cotización o factura
 * @param config Parametrización configurada por el usuario
 * @param maxLen Longitud máxima permitida (por defecto 4000)
 */
export function buildZeusItemDescription(
    itemData: Record<string, any>,
    config?: ZeusTextSectionConfig | null,
    maxLen = 4000
): string {
    const activeConfig = config && Array.isArray(config.fields) ? config : DEFAULT_ITEM_DESCRIPTION_CONFIG;
    const separator = activeConfig.separator !== undefined ? activeConfig.separator : ' - ';

    const sortedFields = [...activeConfig.fields]
        .filter(f => f.enabled)
        .sort((a, b) => a.order - b.order);

    // Si ningún campo está habilitado, retornar la descripción manual original o vacía
    if (sortedFields.length === 0) {
        const fallback = String(itemData.descripcion || itemData.description || '').trim();
        return fallback.substring(0, maxLen);
    }

    const fragments: string[] = [];

    for (const field of sortedFields) {
        let val = '';
        switch (field.id) {
            case 'descripcion_manual':
                val = String(itemData.descripcion || itemData.description || '').trim();
                break;
            case 'fecha_inicial':
                val = formatDateForZeus(itemData.checkInDate || itemData.checkIn || itemData.dt_llegada || itemData.fechaInicial);
                break;
            case 'fecha_final':
                val = formatDateForZeus(itemData.checkOutDate || itemData.checkOut || itemData.dt_salida || itemData.fechaFinal);
                break;
            case 'proveedor':
                val = String(itemData.providerName || itemData.providerCode || itemData.proveedor || itemData.cd_proveedores || '').trim();
                break;
            case 'prestador':
                val = String(itemData.prestadoraName || itemData.prestadoraCode || itemData.prestadora || itemData.cd_hoteles || '').trim();
                break;
            case 'nacionalidad': {
                const nac = itemData.inNationality !== undefined ? itemData.inNationality : itemData.in_nacionalidad;
                if (nac === 1 || nac === '1' || nac === 'NACIONAL' || nac === 'Nacional') {
                    val = 'NACIONAL';
                } else if (nac === 2 || nac === '2' || nac === 'INTERNACIONAL' || nac === 'Internacional') {
                    val = 'INTERNACIONAL';
                } else if (typeof nac === 'string' && nac.trim()) {
                    val = nac.trim().toUpperCase();
                }
                break;
            }
            case 'numero_cotizacion':
                val = String(itemData.consecutive || itemData.consecutivo || itemData.quotationConsecutive || itemData.quotationId || itemData.id || '').trim();
                break;
            case 'pasajero': {
                const first = String(itemData.passengerFirstName || itemData.paxFirstName || itemData.firstName || '').trim();
                const last = String(itemData.passengerLastName || itemData.paxLastName || itemData.lastName || '').trim();
                if (first || last) {
                    val = `${first} ${last}`.trim();
                } else {
                    val = String(itemData.passenger || itemData.pasajero || itemData.paxName || itemData.name || '').trim();
                }
                break;
            }
            case 'destino':
                val = String(itemData.destination || itemData.destino || itemData.ds_destino || '').trim();
                break;
            case 'reservacion':
                val = String(itemData.reservationCode || itemData.reservation || itemData.cd_confirmacion || '').trim();
                break;
            default:
                val = String(itemData[field.id] || '').trim();
                break;
        }

        // Regla 5: Evitar el envío de campos sin información (no emitir etiqueta ni separador si está vacío)
        if (val) {
            const labelStr = field.label ? `${field.label.trim()}: ` : '';
            fragments.push(`${labelStr}${val}`);
        }
    }

    if (fragments.length === 0) {
        // Si todos los campos habilitados resultaron vacíos, usar fallback
        const fallback = String(itemData.descripcion || itemData.description || '').trim();
        return fallback.substring(0, maxLen);
    }

    const result = fragments.join(separator).trim();
    return result.length > maxLen ? result.substring(0, maxLen) : result;
}

/**
 * Construye el texto final de Observaciones conservando el contenido original y adicionando los campos configurados.
 * @param originalObservations Observaciones existentes registradas por el usuario
 * @param headerData Datos de cabecera de la cotización o factura
 * @param config Parametrización configurada
 * @param maxLen Longitud máxima permitida en Zeus (hasta 8000)
 */
export function buildZeusObservations(
    originalObservations: string | null | undefined,
    headerData: Record<string, any>,
    config?: ZeusTextSectionConfig | null,
    maxLen = 8000
): string {
    const rawOriginal = String(originalObservations || '').trim();
    const activeConfig = config && Array.isArray(config.fields) ? config : DEFAULT_OBSERVATIONS_CONFIG;
    const separator = activeConfig.separator !== undefined ? activeConfig.separator : ' - ';

    const sortedFields = [...activeConfig.fields]
        .filter(f => f.enabled)
        .sort((a, b) => a.order - b.order);

    const additionalFragments: string[] = [];

    for (const field of sortedFields) {
        let val = '';
        switch (field.id) {
            case 'numero_cotizacion':
                val = String(headerData.quotationConsecutive || headerData.quotationInternalNumber || headerData.quotationId || headerData.consecutive || headerData.consecutivo || '').trim();
                break;
            case 'numero_factura':
                val = String(headerData.invoiceConsecutive || headerData.invoiceInternalNumber || headerData.internalNumber || headerData.consecutivo || '').trim();
                break;
            case 'pasajero': {
                const first = String(headerData.passengerFirstName || headerData.paxFirstName || '').trim();
                const last = String(headerData.passengerLastName || headerData.paxLastName || '').trim();
                if (first || last) {
                    val = `${first} ${last}`.trim();
                } else {
                    val = String(headerData.passenger || headerData.pasajero || headerData.paxName || '').trim();
                }
                break;
            }
            case 'proveedor':
                val = String(headerData.providerName || headerData.providerCode || headerData.proveedor || '').trim();
                break;
            case 'prestador':
                val = String(headerData.prestadoraName || headerData.prestadoraCode || headerData.prestadora || '').trim();
                break;
            case 'fecha_inicial':
                val = formatDateForZeus(headerData.checkInDate || headerData.checkIn || headerData.fechaInicial);
                break;
            case 'fecha_final':
                val = formatDateForZeus(headerData.checkOutDate || headerData.checkOut || headerData.fechaFinal);
                break;
            case 'descripcion_adicional':
                val = String(headerData.servicesSummary || headerData.descripcion || headerData.servicios || '').trim();
                break;
            default:
                val = String(headerData[field.id] || '').trim();
                break;
        }

        // Regla: No emitir etiquetas ni separadores si el campo está vacío
        if (val) {
            const labelStr = field.label ? `${field.label.trim()}: ` : '';
            additionalFragments.push(`${labelStr}${val}`);
        }
    }

    if (additionalFragments.length === 0) {
        return rawOriginal.substring(0, maxLen);
    }

    const additionalText = additionalFragments.join(separator).trim();

    // Regla obligatoria: Conservar contenido original sin reemplazarlo ni eliminarlo
    let finalObservations = '';
    if (rawOriginal && additionalText) {
        finalObservations = `${rawOriginal}${separator}${additionalText}`;
    } else if (rawOriginal) {
        finalObservations = rawOriginal;
    } else {
        finalObservations = additionalText;
    }

    return finalObservations.length > maxLen ? finalObservations.substring(0, maxLen) : finalObservations;
}

/**
 * Escapa caracteres especiales XML para inyección segura en XML
 */
export function escapeXmlText(str: string): string {
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

/**
 * Desescapa caracteres XML básicos
 */
export function unescapeXmlText(str: string): string {
    return str
        .replace(/&apos;/g, "'")
        .replace(/&quot;/g, '"')
        .replace(/&gt;/g, '>')
        .replace(/&lt;/g, '<')
        .replace(/&amp;/g, '&');
}

/**
 * Extrae el valor de texto de una etiqueta XML
 */
export function extractXmlTag(xmlChunk: string, tagName: string): string {
    const regex = new RegExp(`<${tagName}(?:\\s+[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i');
    const match = xmlChunk.match(regex);
    return match ? unescapeXmlText(match[1].trim()) : '';
}

/**
 * Reemplaza o inserta una etiqueta XML con un nuevo valor escapado
 */
export function replaceOrInsertXmlTag(xmlChunk: string, tagName: string, newValue: string, parentClosingTag: string): string {
    const escapedVal = escapeXmlText(newValue);
    const regex = new RegExp(`<${tagName}(?:\\s+[^>]*)?>([\\s\\S]*?)<\\/${tagName}>`, 'i');
    if (regex.test(xmlChunk)) {
        return xmlChunk.replace(regex, `<${tagName}>${escapedVal}</${tagName}>`);
    }
    // Si no existía la etiqueta, insertarla justo antes de la etiqueta de cierre del padre
    const closeRegex = new RegExp(`(<\\/${parentClosingTag}>)`, 'i');
    return xmlChunk.replace(closeRegex, `    <${tagName}>${escapedVal}</${tagName}>\n$1`);
}

/**
 * Aplica la parametrización dinámica de Descripción de Ítems y Observaciones a una cadena XML para Zeus ERP.
 */
export function applyZeusTextFormattingToXml(
    xmlStr: string,
    itemConfig?: ZeusTextSectionConfig | null,
    obsConfig?: ZeusTextSectionConfig | null
): string {
    if (!xmlStr || typeof xmlStr !== 'string') return xmlStr;

    let processedXml = xmlStr;

    // 1. Procesar Cotizaciones: <Cotizacion>...</Cotizacion>
    processedXml = processedXml.replace(/<Cotizacion(?:\s+[^>]*)?>([\s\S]*?)<\/Cotizacion>/gi, (quotationBlock) => {
        let block = quotationBlock;

        // Extraer datos del encabezado
        const origObs = extractXmlTag(block, 'ds_observacion');
        const consecutivo = extractXmlTag(block, 'cd_consecutivo');
        const paxName = extractXmlTag(block, 'ds_paxname');
        const paxApe = extractXmlTag(block, 'ds_paxape');
        const fecha = extractXmlTag(block, 'dt_fecha');

        const headerData = {
            quotationConsecutive: consecutivo,
            consecutive: consecutivo,
            passengerFirstName: paxName,
            passengerLastName: paxApe,
            passenger: `${paxName} ${paxApe}`.trim(),
            date: fecha,
            fechaInicial: fecha
        };

        // Formatear y actualizar ds_observacion
        const newObs = buildZeusObservations(origObs, headerData, obsConfig, 8000);
        block = replaceOrInsertXmlTag(block, 'ds_observacion', newObs, 'Cotizacion');

        // Procesar cada ítem del detalle: <CotizacionServicios>...</CotizacionServicios>
        block = block.replace(/<CotizacionServicios(?:\s+[^>]*)?>([\s\S]*?)<\/CotizacionServicios>/gi, (itemBlock) => {
            let srvBlock = itemBlock;
            const itemData = {
                descripcion: extractXmlTag(srvBlock, 'ds_descrip'),
                checkInDate: extractXmlTag(srvBlock, 'dt_llegada'),
                checkOutDate: extractXmlTag(srvBlock, 'dt_salida'),
                providerCode: extractXmlTag(srvBlock, 'cd_proveedores'),
                prestadoraCode: extractXmlTag(srvBlock, 'cd_hoteles'),
                inNationality: extractXmlTag(srvBlock, 'in_nacionalidad'),
                quotationConsecutive: consecutivo,
                consecutive: consecutivo,
                paxFirstName: extractXmlTag(srvBlock, 'ds_paxname'),
                paxLastName: extractXmlTag(srvBlock, 'ds_paxape'),
                passenger: `${extractXmlTag(srvBlock, 'ds_paxname')} ${extractXmlTag(srvBlock, 'ds_paxape')}`.trim(),
                destination: extractXmlTag(srvBlock, 'ds_destino'),
                reservationCode: extractXmlTag(srvBlock, 'cd_confirmacion') || extractXmlTag(srvBlock, 'ds_records')
            };

            const newDesc = buildZeusItemDescription(itemData, itemConfig, 4000);
            srvBlock = replaceOrInsertXmlTag(srvBlock, 'ds_descrip', newDesc, 'CotizacionServicios');
            return srvBlock;
        });

        return block;
    });

    // 2. Procesar Facturas: <Factura>...</Factura>
    processedXml = processedXml.replace(/<Factura(?:\s+[^>]*)?>([\s\S]*?)<\/Factura>/gi, (invoiceBlock) => {
        let block = invoiceBlock;

        const origObs = extractXmlTag(block, 'ds_Observacion') || extractXmlTag(block, 'ds_observacion');
        const consecutivo = extractXmlTag(block, 'consecutivo') || extractXmlTag(block, 'id_factura');
        const internalNum = extractXmlTag(block, 'internalNumber') || consecutivo;
        const paxName = extractXmlTag(block, 'ds_paxname') || extractXmlTag(block, 'ds_pax_firstnm');
        const paxApe = extractXmlTag(block, 'ds_paxape') || extractXmlTag(block, 'ds_pax_lastnm');
        const fecha = extractXmlTag(block, 'fecha') || extractXmlTag(block, 'dt_fechacont');

        const headerData = {
            invoiceConsecutive: consecutivo,
            consecutive: consecutivo,
            internalNumber: internalNum,
            passengerFirstName: paxName,
            passengerLastName: paxApe,
            passenger: `${paxName} ${paxApe}`.trim(),
            date: fecha,
            fechaInicial: fecha
        };

        const newObs = buildZeusObservations(origObs, headerData, obsConfig, 8000);
        block = replaceOrInsertXmlTag(block, 'ds_Observacion', newObs, 'Factura');

        // Procesar cada ítem: <Item>...</Item> o <Fac_Servicios>...</Fac_Servicios>
        block = block.replace(/<(Item|Fac_Servicios)(?:\s+[^>]*)?>([\s\S]*?)<\/\1>/gi, (itemBlock, tagName) => {
            let srvBlock = itemBlock;
            const itemData = {
                descripcion: extractXmlTag(srvBlock, 'ds_descrip'),
                checkInDate: extractXmlTag(srvBlock, 'dt_llegada'),
                checkOutDate: extractXmlTag(srvBlock, 'dt_salida'),
                providerCode: extractXmlTag(srvBlock, 'cd_proveedores'),
                prestadoraCode: extractXmlTag(srvBlock, 'cd_hoteles'),
                inNationality: extractXmlTag(srvBlock, 'in_nacionalidad'),
                invoiceConsecutive: consecutivo,
                consecutive: consecutivo,
                paxFirstName: extractXmlTag(srvBlock, 'ds_paxname') || extractXmlTag(srvBlock, 'ds_pax_firstnm'),
                paxLastName: extractXmlTag(srvBlock, 'ds_paxape') || extractXmlTag(srvBlock, 'ds_pax_lastnm'),
                passenger: `${extractXmlTag(srvBlock, 'ds_paxname') || extractXmlTag(srvBlock, 'ds_pax_firstnm')} ${extractXmlTag(srvBlock, 'ds_paxape') || extractXmlTag(srvBlock, 'ds_pax_lastnm')}`.trim(),
                destination: extractXmlTag(srvBlock, 'ds_destino')
            };

            const newDesc = buildZeusItemDescription(itemData, itemConfig, 500); // 500 según esquema de Facturación Zeus
            srvBlock = replaceOrInsertXmlTag(srvBlock, 'ds_descrip', newDesc, tagName);
            return srvBlock;
        });

        return block;
    });

    return processedXml;
}
