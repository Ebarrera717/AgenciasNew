import { NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import ExcelJS from 'exceljs'
import path from 'path'
import * as XLSX from 'xlsx'
import fs from 'fs'
import { generateHtmlTemplate } from '@/lib/excel-to-html'
import { getCellCustomizationConfig } from '@/lib/cell-customization'

interface ProductInfo {
    idProducto: number;
    // Producto
    productDescripcion: string;
    productTipo: string;
    productCodigo: string;
    productConcepto: string;
    productItinerario: string;
    productClase: string;
    productVuelo: string;
    precio: number;
    cantidad: number;
    costo: number;
    checkIn: string;
    checkOut: string;
    noches: number;
    paxAdultos: number;
    paxNinos: number;
    destino: string;
    codigoReserva: string;
    tipoServicio: string;
    servicio: string;
    descripcion: string;
    // Proveedor
    proveedorNombre: string;
    proveedorNIT: string;
    proveedorContacto: string;
    // Prestadora
    prestadoraNombre: string;
    prestadoraCategoria: string;
    prestadoraUbicacion: string;
    // Valores financieros
    tarifaNeta: number;
    tarifaNetaPago: number;
    impuestos: number;
    impuestosPago: number;
    adicionalesServ: number;
    adicionalesServPago: number;
    comision: number;
    descuento: number;
    sobrecomision: number;
    fee: number;
    total: number;
    totalPago: number;
    // Legados (para compatibilidad con plantillas actuales)
    fechasViaje: string;
    hotelesServicios: string;
    pasajeros: string;
    totalAdultos: number;
    totalNinos: number;
    vendedor: string;
    [key: string]: any;
}

interface GroupedQuotation {
    idCotizacion: number;
    internalNumber: string;
    asesor: string;
    fecha: string;
    currency: string;
    tCambio: number;
    state: string;
    descripcionPlan: string;
    observaciones: string;
    baseCommissionable: number;
    commissionPercentage: number;
    totalAmount: number;
    costoTotal: number;
    valorBase: number;
    utilidad: number;
    comisionFreelanceValue: number;
    comisionPropiaValue: number;
    comisionTotalPercentage: number;
    comisionFreelancePercentage: number;
    comisionPropiaPercentage: number;
    comisionUtilidadPercentage: number;
    clienteNombre: string;
    clienteIdentificacion: string;
    clienteDireccion: string;
    clienteTelefono: string;
    pasajeros: string;
    totalAdultos: number;
    totalNinos: number;
    baseComisionable: number;
    comisionAsesor: number;
    fechasViaje: string;
    hotelesServicios: string;
    vendedor: string;
    logo: Buffer | null;
    products: ProductInfo[];
    [key: string]: any;
}

const DEFAULT_CONFIG = {
    asesor: "B4",
    fecha: "G4",
    clienteNombre: "B7",
    clienteIdentificacion: "G7",
    clienteDireccion: "B8",
    clienteTelefono: "G8",
    centroCosto: "B9",
    solicita: "G9",
    tCambio: "G11",
    descripcionPlan: "B12",
    fechasViaje: "G12",
    hotelesServicios: "A13",
    pasajeros: "B14",
    totalAdultos: "C15",
    totalNinos: "G15",
    proveedorNombre: "B18",
    proveedorNIT: "E18",
    proveedorContacto: "H18",
    tarifaNeta: "B23",
    tarifaNetaPago: "D23",
    impuestos: "B24",
    impuestosPago: "D24",
    adicionalesServ: "B25",
    adicionalesServPago: "D25",
    comision: "B26",
    descuento: "B27",
    sobrecomision: "B28",
    fee: "B29",
    total: "B30",
    totalPago: "D30",
    baseComisionable: "B35",
    comisionAsesor: "B36",
    baseComisionTop: "B37",
    observaciones: "B42",
    logo: "A1"
};

function cleanString(str: string): string {
    return str
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^a-z0-9]/g, "");
}

const FIELD_KEYWORDS: Record<string, string[]> = {
    asesor: ['asesor', 'ejecutivo'],
    fecha: ['fecha'],
    clienteNombre: ['cliente', 'cliente facturar', 'nombre cliente', 'nombre/razon social'],
    clienteIdentificacion: ['identificacion', 'nit', 'cedula', 'nit cedula', 'nit/cedula', 'documento', 'nit o cedula'],
    clienteDireccion: ['direccion', 'dir'],
    clienteTelefono: ['telefono', 'tel', 'contacto'],
    centroCosto: ['centro de costo', 'centro costo', 'c. costo', 'centrocosto'],
    solicita: ['solicita', 'solicitado por'],
    tCambio: ['tasa de cambio', 'tasa cambio', 't. cambio', 'cambio', 'tasacambio'],
    descripcionPlan: ['descripcion plan', 'plan', 'descripcion', 'descripcionplan'],
    fechasViaje: ['fechas de viaje', 'fechas viaje', 'fecha viaje', 'fechasviaje'],
    hotelesServicios: ['hoteles o servicios', 'hoteles/servicios', 'servicios', 'hoteles'],
    pasajeros: ['pasajeros', 'pasajero', 'nombre pasajero'],
    pasajerosNombres: ['pasajeros nombres', 'nombres pasajeros', 'nombres'],
    pasajerosApellidos: ['pasajeros apellidos', 'apellidos pasajeros', 'apellidos'],
    pasajeroCabeceraNombres: ['pasajero nombres', 'titular nombres'],
    pasajeroCabeceraApellidos: ['pasajero apellidos', 'titular apellidos'],
    totalAdultos: ['total adultos', 'adultos', 'totaladultos'],
    totalNinos: ['total ninos', 'ninos', 'totalninos'],
    observaciones: ['observaciones', 'notas'],
    idCotizacion: ['id cotizacion', 'cotizacion', 'numero cotizacion', 'num cotizacion']
};

function clearUnconfiguredFields(sheet: ExcelJS.Worksheet, config: any) {
    if (!config || typeof config !== 'object') return;

    // Detect productStartRow to protect column headers and product rows
    let productStartRow = 0;
    const productFieldsToTry = [
        'proveedorNombre', 'proveedorNIT', 'proveedorContacto', 'tarifaNeta',
        'total', 'servicio', 'productDescripcion', 'checkIn', 'destino'
    ];
    for (const field of productFieldsToTry) {
        const cell = config[field];
        if (cell && typeof cell === 'string') {
            const rowMatch = cell.match(/\d+/);
            if (rowMatch) {
                productStartRow = parseInt(rowMatch[0]);
                break;
            }
        }
    }

    const unconfiguredKeys = new Set<string>();
    const allPossibleKeys = new Set([
        ...Object.keys(FIELD_KEYWORDS),
        ...Object.keys(config).filter(k => k !== '__customNames')
    ]);

    allPossibleKeys.forEach(key => {
        const val = config[key];
        if (val === null || val === undefined || val === '') {
            unconfiguredKeys.add(key);
        }
    });

    if (unconfiguredKeys.size === 0) return;

    const keywordsToMatch = new Map<string, Set<string>>();
    unconfiguredKeys.forEach(key => {
        const words = new Set<string>();
        
        if (FIELD_KEYWORDS[key]) {
            FIELD_KEYWORDS[key].forEach(w => words.add(cleanString(w)));
        }

        if (config.__customNames?.[key]) {
            words.add(cleanString(config.__customNames[key]));
        }

        words.add(cleanString(key));
        keywordsToMatch.set(key, words);
    });

    sheet.eachRow({ includeEmpty: true }, (row) => {
        if (productStartRow > 0 && row.number >= productStartRow - 1) {
            return;
        }
        row.eachCell({ includeEmpty: true }, (cell) => {
            const cellVal = cell.value;
            if (cellVal && typeof cellVal === 'string') {
                const cleanedVal = cleanString(cellVal);
                
                for (const [key, words] of keywordsToMatch.entries()) {
                    if (words.has(cleanedVal)) {
                        cell.value = null;

                        const colNumber = cell.col as unknown as number;
                        for (let offset = 1; offset <= 4; offset++) {
                            const targetCell = row.getCell(colNumber + offset);
                            if (targetCell) {
                                targetCell.value = null;
                            }
                        }

                        const rowNumber = row.number;
                        const nextRow = sheet.getRow(rowNumber + 1);
                        if (nextRow) {
                            const cellBelow = nextRow.getCell(colNumber);
                            if (cellBelow) {
                                cellBelow.value = null;
                            }
                        }
                        break;
                    }
                }
            }
        });
    });
}

function colNameToIndex(colName: string): number {
    let index = 0;
    for (let i = 0; i < colName.length; i++) {
        index = index * 26 + (colName.charCodeAt(i) - 64);
    }
    return index - 1;
}

function copySheet(src: ExcelJS.Worksheet, dest: ExcelJS.Worksheet, srcWorkbook: ExcelJS.Workbook, destWorkbook: ExcelJS.Workbook) {
    dest.views = src.views;
    dest.properties = src.properties;
    dest.pageSetup = src.pageSetup;

    src.columns?.forEach((col, idx) => {
        if (col && dest.getColumn(idx + 1)) {
            dest.getColumn(idx + 1).width = col.width;
        }
    });

    src.eachRow({ includeEmpty: true }, (row, rowNum) => {
        const destRow = dest.getRow(rowNum);
        destRow.height = row.height;

        row.eachCell({ includeEmpty: true }, (cell, colNum) => {
            const destCell = destRow.getCell(colNum);
            destCell.value = cell.value;
            destCell.style = cell.style;
        });
    });

    src.getImages().forEach((img) => {
        try {
            const mediaObj = srcWorkbook.model.media?.find((m: any) => m.index === img.imageId);
            if (mediaObj) {
                const imageId = destWorkbook.addImage({
                    buffer: mediaObj.buffer,
                    extension: mediaObj.extension as any,
                });
                dest.addImage(imageId, img.range);
            }
        } catch (err) {
            console.error("Error copying image between sheets:", err);
        }
    });
}

function copyRowStyle(sheet: ExcelJS.Worksheet, srcRowNumber: number, destRowNumber: number) {
    const srcRow = sheet.getRow(srcRowNumber);
    const destRow = sheet.getRow(destRowNumber);
    destRow.height = srcRow.height;

    srcRow.eachCell({ includeEmpty: true }, (cell, colNumber) => {
        const destCell = destRow.getCell(colNumber);
        destCell.style = cell.style;
    });
}

function sheetToHtmlJson(sheet: ExcelJS.Worksheet, workbook: ExcelJS.Workbook) {
    const rows = [];
    let maxCol = 1;

    sheet.eachRow({ includeEmpty: true }, (row) => {
        row.eachCell({ includeEmpty: true }, (cell) => {
            const col = cell.col as unknown as number;
            if (col > maxCol) maxCol = col;
        });
    });

    for (let r = 1; r <= sheet.rowCount; r++) {
        const row = sheet.getRow(r);
        const rowJson = {
            height: row.height || 20,
            cells: [] as any[]
        };

        for (let c = 1; c <= maxCol; c++) {
            const cell = row.getCell(c);
            let val = cell.value;
            
            if (val && typeof val === 'object') {
                if ('result' in val) {
                    val = (val as any).result;
                } else if ('richText' in val) {
                    val = (val as any).richText.map((t: any) => t.text).join('');
                } else if ('text' in val) {
                    val = (val as any).text;
                }
            }

            const parseColor = (colorObj: any) => {
                if (!colorObj) return 'transparent';
                if (typeof colorObj === 'string') return colorObj;
                if (colorObj.argb) return `#${colorObj.argb.substring(2)}`;
                return 'transparent';
            };

            const parseBorderSide = (side: any) => {
                if (!side || !side.style) return 'none';
                const style = side.style;
                const color = parseColor(side.color);
                const width = style === 'thin' ? '1px' : style === 'medium' ? '2px' : '3px';
                return `${width} ${style === 'dotted' || style === 'dashed' ? style : 'solid'} ${color}`;
            };

            const cellJson = {
                value: val !== null && val !== undefined ? String(val) : '',
                style: {
                    backgroundColor: parseColor(cell.fill?.type === 'pattern' ? (cell.fill as any).fgColor : null),
                    color: parseColor(cell.font?.color),
                    fontFamily: cell.font?.name || 'inherit',
                    fontSize: cell.font?.size ? `${cell.font.size}pt` : '10pt',
                    fontWeight: cell.font?.bold ? 'bold' : 'normal',
                    fontStyle: cell.font?.italic ? 'italic' : 'normal',
                    textAlign: cell.alignment?.horizontal || 'left',
                    verticalAlign: cell.alignment?.vertical || 'middle',
                    borderTop: parseBorderSide(cell.border?.top),
                    borderBottom: parseBorderSide(cell.border?.bottom),
                    borderLeft: parseBorderSide(cell.border?.left),
                    borderRight: parseBorderSide(cell.border?.right),
                }
            };

            rowJson.cells.push(cellJson);
        }
        rows.push(rowJson);
    }

    const colWidths = [];
    for (let c = 1; c <= maxCol; c++) {
        const col = sheet.getColumn(c);
        colWidths.push(col.width || 10);
    }

    return {
        name: sheet.name,
        rows,
        colWidths
    };
}

export async function GET(req: Request) {
    try {
        const { searchParams } = new URL(req.url);
        const idIni = searchParams.get('idIni');
        const idFin = searchParams.get('idFin');
        const formatId = searchParams.get('formatId') ? parseInt(searchParams.get('formatId')!) : null;

        if (!idIni || !idFin) {
            return NextResponse.json({ error: 'idIni and idFin are required' }, { status: 400 });
        }

        // Si se especifica un formatId, precargamos ese formato de cotización personalizado
        let customFormat: any = null;
        if (formatId) {
            customFormat = await prisma.quotationFormat.findUnique({
                where: { id: formatId },
                include: { FormatCellCustomization: true }
            });
        }

        // 1. Fetch raw quotation data from database function
        const rawRows: any[] = await prisma.$queryRawUnsafe(
            `SELECT * FROM public."fnRptCotizacion"($1, $2)`,
            parseInt(idIni), parseInt(idFin)
        );

        if (rawRows.length === 0) {
            return NextResponse.json({ error: 'No data found for the specified range' }, { status: 404 });
        }

        // Fetch dynamic variables for all products in rawRows
        const productIds = rawRows
            .map((r: any) => r.idProducto)
            .filter((id: any) => id !== null && id !== undefined && typeof id === 'number');

        const productVariables = productIds.length > 0 ? await prisma.quotationProductVariable.findMany({
            where: {
                quotationProductId: { in: productIds }
            },
            include: {
                masterVariable: true
            }
        }) : [];

        const varsByProductMap = new Map<number, any[]>();
        productVariables.forEach((pv: any) => {
            const pId = pv.quotationProductId;
            if (!varsByProductMap.has(pId)) {
                varsByProductMap.set(pId, []);
            }
            varsByProductMap.get(pId)!.push(pv);
        });

        // Group rows by idCotizacion
        const grouped: { [key: number]: GroupedQuotation } = {};
        rawRows.forEach((row: any) => {
            const id = row.idCotizacion;
            if (!grouped[id]) {
                grouped[id] = {
                    // Cotización cabecera
                    idCotizacion: id,
                    internalNumber: row.internalNumber || '',
                    asesor: row.asesor || '',
                    fecha: row.fecha,
                    currency: row.currency || '',
                    tCambio: row.tCambio || 1.0,
                    state: row.state || '',
                    descripcionPlan: row.descripcionPlan || `Cotización #${id}`,
                    observaciones: row.observaciones || '',
                    baseCommissionable: row.baseCommissionable || 0,
                    commissionPercentage: row.commissionPercentage || 0,
                    totalAmount: row.totalAmount || 0,
                    costoTotal: row.costoTotal || 0,
                    valorBase: row.valorBase || 0,
                    utilidad: row.utilidad || 0,
                    comisionFreelanceValue: row.comisionFreelanceValue || 0,
                    comisionPropiaValue: row.comisionPropiaValue || 0,
                    comisionTotalPercentage: row.comisionTotalPercentage || 0,
                    comisionFreelancePercentage: row.comisionFreelancePercentage || 0,
                    comisionPropiaPercentage: row.comisionPropiaPercentage || 0,
                    comisionUtilidadPercentage: row.comisionUtilidadPercentage || 0,
                    // Cliente
                    clienteNombre: row.clienteNombre || '',
                    clienteIdentificacion: row.clienteIdentificacion || '',
                    clienteDireccion: row.clienteDireccion || '',
                    clienteTelefono: row.clienteTelefono || '',
                    // Resúmenes
                    pasajeros: row.pasajeros || '',
                    totalAdultos: row.totalAdultos || 0,
                    totalNinos: row.totalNinos || 0,
                    baseComisionable: row.baseComisionable || 0,
                    comisionAsesor: row.comisionAsesor || 0,
                    fechasViaje: row.fechasViaje || '',
                    hotelesServicios: row.hotelesServicios || '',
                    vendedor: row.vendedor || '',
                    logo: row.logo || null,
                    destinoCabecera: row.destinoCabecera || '',
                    fechaInicioCabecera: row.fechaInicioCabecera || '',
                    fechaFinCabecera: row.fechaFinCabecera || '',
                    pasajeroCabecera: row.pasajeroCabecera || '',
                    pasajeroCabeceraNombres: row.pasajeroCabeceraNombres || '',
                    pasajeroCabeceraApellidos: row.pasajeroCabeceraApellidos || '',
                    pasajerosNombres: row.pasajerosNombres || '',
                    pasajerosApellidos: row.pasajerosApellidos || '',
                    paxAdultosCabecera: row.paxAdultosCabecera || 0,
                    paxNinosCabecera: row.paxNinosCabecera || 0,
                    reservacionCabecera: row.reservacionCabecera || '',
                    descripcionManualCabecera: row.descripcionManualCabecera || '',
                    products: []
                };
            }

            if (row.idProducto) {
                const tarifaNeta = row.tarifaNeta || 0;
                const impuestos = row.impuestos || 0;
                const adicionalesServ = row.adicionalesServ || 0;
                const comision = row.comision || 0;
                const total = row.total || 0;
                const prodObj: any = {
                    idProducto: row.idProducto,
                    // Producto
                    productDescripcion: row.productDescripcion || '',
                    productTipo: row.productTipo || '',
                    productCodigo: row.productCodigo || '',
                    productConcepto: row.productConcepto || '',
                    productItinerario: row.productItinerario || '',
                    productClase: row.productClase || '',
                    productVuelo: row.productVuelo || '',
                    precio: row.precio || 0,
                    cantidad: row.cantidad || 1,
                    costo: row.costo || 0,
                    checkIn: row.checkIn || '',
                    checkOut: row.checkOut || '',
                    noches: row.noches || 0,
                    paxAdultos: row.paxAdultos || 0,
                    paxNinos: row.paxNinos || 0,
                    destino: row.destino || '',
                    codigoReserva: row.codigoReserva || '',
                    tipoServicio: row.tipoServicio || '',
                    servicio: row.servicio || '',
                    descripcion: row.descripcion || '',
                    // Proveedor
                    proveedorNombre: row.proveedorNombre || '',
                    proveedorNIT: row.proveedorNIT || '',
                    proveedorContacto: row.proveedorContacto || '',
                    // Prestadora
                    prestadoraNombre: row.prestadoraNombre || '',
                    prestadoraCategoria: row.prestadoraCategoria || '',
                    prestadoraUbicacion: row.prestadoraUbicacion || '',
                    // Valores financieros
                    tarifaNeta,
                    tarifaNetaPago: tarifaNeta - comision,
                    impuestos,
                    impuestosPago: impuestos,
                    adicionalesServ,
                    adicionalesServPago: adicionalesServ,
                    comision,
                    descuento: row.descuento || 0,
                    sobrecomision: row.sobrecomision || 0,
                    fee: row.fee || 0,
                    total,
                    totalPago: total - comision,
                    // Legados / compatibilidad
                    fechasViaje: row.fechasViaje || '',
                    hotelesServicios: row.hotelesServicios || '',
                    pasajeros: row.pasajeros || '',
                    totalAdultos: row.totalAdultos || 0,
                    totalNinos: row.totalNinos || 0,
                    vendedor: row.vendedor || ''
                };

                // Inject dynamic variables into the product object
                const pVars = varsByProductMap.get(row.idProducto) || [];
                pVars.forEach((pv: any) => {
                    const code = pv.masterVariable.code;
                    prodObj[code] = pv.value || '';
                    prodObj[`var_${pv.masterVariable.id}`] = pv.value || '';
                });

                grouped[id].products.push(prodObj);
            }
        });

        const groupedList = Object.values(grouped);

        // Inject 1-to-9 indexed variables for static Excel template mapping compatibility
        groupedList.forEach((q: any) => {
            q.products.forEach((prod: any, idx: number) => {
                const pNum = idx + 1;
                if (pNum > 9) return;

                q[`proveedor${pNum}Nombre`] = prod.proveedorNombre || '';
                q[`proveedor${pNum}NIT`] = prod.proveedorNIT || '';
                q[`proveedor${pNum}Contacto`] = prod.proveedorContacto || '';
                q[`prov${pNum}TarifaNeta`] = prod.tarifaNeta || 0;
                q[`prov${pNum}TarifaNetaPago`] = prod.tarifaNetaPago || 0;
                q[`prov${pNum}Impuestos`] = prod.impuestos || 0;
                q[`prov${pNum}ImpuestosPago`] = prod.impuestosPago || 0;
                q[`prov${pNum}Adicionales`] = prod.adicionalesServ || 0;
                q[`prov${pNum}AdicionalesPago`] = prod.adicionalesServPago || 0;
                q[`prov${pNum}Comision`] = prod.comision || 0;
                q[`prov${pNum}Descuento`] = prod.descuento || 0;
                q[`prov${pNum}Sobrecomision`] = prod.sobrecomision || 0;
                q[`prov${pNum}Fee`] = prod.fee || 0;
                q[`prov${pNum}Total`] = prod.total || 0;
                q[`prov${pNum}TotalPago`] = prod.totalPago || 0;
                q[`prov${pNum}checkIn`] = prod.checkIn || '';
                q[`prov${pNum}checkOut`] = prod.checkOut || '';
                q[`prov${pNum}nights`] = prod.noches || 0;
                q[`prov${pNum}destination`] = prod.destino || '';
                q[`prov${pNum}quantity`] = prod.cantidad || 1;
                q[`prov${pNum}price`] = prod.precio || 0;
                q[`prov${pNum}cost`] = prod.costo || 0;
                q[`prov${pNum}paxAdultos`] = prod.paxAdultos || 0;
                q[`prov${pNum}paxNinos`] = prod.paxNinos || 0;
                q[`prov${pNum}sellerCommission`] = prod.sellerCommission || 0;
                q[`prov${pNum}ticketPrinterCommission`] = prod.ticketPrinterCommission || 0;
                q[`prov${pNum}inNationality`] = prod.inNationality || 1;
                q[`prov${pNum}servicio`] = prod.servicio || '';
                q[`prov${pNum}descripcion`] = prod.descripcion || '';
                q[`prov${pNum}prestadoraNombre`] = prod.prestadoraNombre || '';
                q[`prov${pNum}prestadoraCategoria`] = prod.prestadoraCategoria || '';
                q[`prov${pNum}prestadoraUbicacion`] = prod.prestadoraUbicacion || '';

                q[`prov${pNum}productDescripcion`] = prod.productDescripcion || '';
                q[`prov${pNum}productTipo`] = prod.productTipo || '';
                q[`prov${pNum}productCodigo`] = prod.productCodigo || '';
                q[`prov${pNum}productConcepto`] = prod.productConcepto || '';
                q[`prov${pNum}productItinerario`] = prod.productItinerario || '';
                q[`prov${pNum}productClase`] = prod.productClase || '';
                q[`prov${pNum}productVuelo`] = prod.productVuelo || '';

                const standardProductFields = [
                    'idProducto', 'productDescripcion', 'productTipo', 'productCodigo', 'productConcepto',
                    'productItinerario', 'productClase', 'productVuelo', 'precio', 'cantidad', 'costo',
                    'checkIn', 'checkOut', 'noches', 'paxAdultos', 'paxNinos', 'destino', 'codigoReserva',
                    'tipoServicio', 'servicio', 'descripcion', 'proveedorNombre', 'proveedorNIT',
                    'proveedorContacto', 'prestadoraNombre', 'prestadoraCategoria', 'prestadoraUbicacion',
                    'tarifaNeta', 'tarifaNetaPago', 'impuestos', 'impuestosPago', 'adicionalesServ',
                    'adicionalesServPago', 'comision', 'descuento', 'sobrecomision', 'fee', 'total', 'totalPago',
                    'fechasViaje', 'hotelesServicios', 'pasajeros', 'totalAdultos', 'totalNinos', 'vendedor'
                ];
                
                Object.keys(prod).forEach(key => {
                    if (!standardProductFields.includes(key)) {
                        q[`prov${pNum}_${key}`] = prod[key];
                    }
                });
            });
        });

        // Get sucursal configs to mapping values
        const qDbMap = new Map<number, any>();
        for (const q of groupedList) {
            const dbQuo = await prisma.quotation.findUnique({
                where: { id: q.idCotizacion },
                include: {
                    branch: true,
                    implant: true
                }
            });
            if (dbQuo) {
                qDbMap.set(q.idCotizacion, dbQuo);
            }
        }

        const outWorkbook = new ExcelJS.Workbook();
        const defaultTemplatePath = path.join(process.cwd(), 'templates', 'default_template.xlsx');

        for (const q of groupedList) {
            const dbInfo = qDbMap.get(q.idCotizacion);

            let templateBuffer: Buffer | null = null;
            let config: any = DEFAULT_CONFIG;

            if (customFormat) {
                // Usar el formato personalizado si se especificó formatId
                templateBuffer = customFormat.template ? Buffer.from(customFormat.template) : null;
                const formatCellConfig = (customFormat.FormatCellCustomization || []).reduce((acc: any, c: any) => {
                    if (c.value) acc[c.code] = c.value;
                    return acc;
                }, {});
                config = {
                    ...DEFAULT_CONFIG,
                    ...(customFormat.templateConfig as any || {}),
                    ...formatCellConfig,
                };
            } else {
                // Usar el formato de la sucursal/implant como antes
                const physicalConfig = await getCellCustomizationConfig(
                    dbInfo?.branch?.id || null,
                    dbInfo?.implant?.id || null
                );
                const templateConfigRaw = dbInfo?.implant?.templateConfig || dbInfo?.branch?.templateConfig;
                const branchTemplateBuffer = dbInfo?.implant?.template || dbInfo?.branch?.template;
                templateBuffer = branchTemplateBuffer ? Buffer.from(branchTemplateBuffer) : null;

                if (templateBuffer) {
                    config = {
                        ...(templateConfigRaw as any || {}),
                        ...(physicalConfig || {})
                    };
                } else if (templateConfigRaw || physicalConfig) {
                    config = {
                        ...DEFAULT_CONFIG,
                        ...(templateConfigRaw as any || {}),
                        ...(physicalConfig || {})
                    };
                }
            }

            const tempWorkbook = new ExcelJS.Workbook();
            
            if (templateBuffer) {
                let finalBuffer: Buffer = Buffer.from(templateBuffer) as unknown as Buffer;
                if (finalBuffer[0] === 0xD0 && finalBuffer[1] === 0xCF && finalBuffer[2] === 0x11 && finalBuffer[3] === 0xE0) {
                    try {
                        const xlsWorkbook = XLSX.read(finalBuffer, { type: 'buffer' });
                        finalBuffer = Buffer.from(XLSX.write(xlsWorkbook, { bookType: 'xlsx', type: 'buffer' })) as unknown as Buffer;
                    } catch (convErr) {
                        console.error("Error converting XLS template to XLSX:", convErr);
                    }
                }
                await tempWorkbook.xlsx.load(finalBuffer as any);
            } else {
                await tempWorkbook.xlsx.readFile(defaultTemplatePath);
            }

            const srcSheet = tempWorkbook.getWorksheet(1);
            if (!srcSheet) continue;

            const destSheet = outWorkbook.addWorksheet(`Cotización ${q.idCotizacion}`);
            
            // Clone template sheet layout & styles
            copySheet(srcSheet, destSheet, tempWorkbook, outWorkbook);

            // Clear any unconfigured labels/fields from the template sheet
            clearUnconfiguredFields(destSheet, config);

            // Clear configuration JSON or metadata from cell A1 and the logo cell
            const a1Cell = destSheet.getCell('A1');
            const a1Val = a1Cell.value;
            if (a1Val && typeof a1Val === 'string' && a1Val.trim().startsWith('{')) {
                a1Cell.value = '';
            }
            const logoCellKey = config.logo || 'A1';
            const logoCell = destSheet.getCell(logoCellKey);
            const logoVal = logoCell.value;
            if (logoVal && typeof logoVal === 'string' && (logoVal.trim().startsWith('{') || logoVal.includes('logo'))) {
                logoCell.value = '';
            }

            // Helper to set cell value safely
            const setVal = (cellKey: string, value: any) => {
                if (cellKey) {
                    const cell = destSheet.getCell(cellKey);
                    cell.value = value;
                }
            };

            // Set Header variables (Quotation-level fields)
            setVal(config.asesor, q.asesor || '');
            setVal(config.fecha, q.fecha ? new Date(q.fecha) : '');
            setVal(config.clienteNombre, q.clienteNombre || '');
            setVal(config.clienteIdentificacion, q.clienteIdentificacion || '');
            setVal(config.clienteDireccion, q.clienteDireccion || '');
            setVal(config.clienteTelefono, q.clienteTelefono || '');
            setVal(config.tCambio, q.tCambio);
            setVal(config.descripcionPlan, q.descripcionPlan || '');
            setVal(config.pasajeros, q.pasajeros || 'Mismo titular');
            setVal(config.totalAdultos, q.totalAdultos);
            setVal(config.totalNinos, q.totalNinos);
            // New header fields
            setVal((config as any).internalNumber, q.internalNumber || '');
            setVal((config as any).currency, q.currency || '');
            setVal((config as any).state, q.state || '');
            setVal((config as any).totalAmount, q.totalAmount || 0);
            setVal((config as any).costoTotal, q.costoTotal || 0);
            setVal((config as any).valorBase, q.valorBase || 0);
            setVal((config as any).utilidad, q.utilidad || 0);
            setVal((config as any).baseCommissionable, q.baseCommissionable || 0);
            setVal((config as any).commissionPercentage, q.commissionPercentage || 0);
            setVal((config as any).comisionFreelanceValue, q.comisionFreelanceValue || 0);
            setVal((config as any).comisionPropiaValue, q.comisionPropiaValue || 0);
            setVal((config as any).comisionTotalPercentage, q.comisionTotalPercentage || 0);
            setVal((config as any).comisionFreelancePercentage, q.comisionFreelancePercentage || 0);
            setVal((config as any).comisionPropiaPercentage, q.comisionPropiaPercentage || 0);
            setVal((config as any).comisionUtilidadPercentage, q.comisionUtilidadPercentage || 0);
            setVal((config as any).vendedor, q.vendedor || '');
            setVal((config as any).destinoCabecera, q.destinoCabecera || '');
            setVal((config as any).fechaInicioCabecera, q.fechaInicioCabecera ? new Date(q.fechaInicioCabecera) : '');
            setVal((config as any).fechaFinCabecera, q.fechaFinCabecera ? new Date(q.fechaFinCabecera) : '');
            setVal((config as any).pasajeroCabecera, q.pasajeroCabecera || '');
            setVal((config as any).pasajeroCabeceraNombres, q.pasajeroCabeceraNombres || '');
            setVal((config as any).pasajeroCabeceraApellidos, q.pasajeroCabeceraApellidos || '');
            setVal((config as any).pasajerosNombres, q.pasajerosNombres || '');
            setVal((config as any).pasajerosApellidos, q.pasajerosApellidos || '');
            setVal((config as any).paxAdultosCabecera, q.paxAdultosCabecera || 0);
            setVal((config as any).paxNinosCabecera, q.paxNinosCabecera || 0);
            setVal((config as any).reservacionCabecera, q.reservacionCabecera || '');
            setVal((config as any).descripcionManualCabecera, q.descripcionManualCabecera || '');

            // Process dynamic product rows
            // 1. Identify product start row number from config
            let productStartRow = 0;
            const productFieldsToTry = [
                'proveedorNombre', 'proveedorNIT', 'proveedorContacto', 'tarifaNeta',
                'total', 'servicio', 'productDescripcion', 'checkIn', 'destino'
            ];
            for (const field of productFieldsToTry) {
                const cell = (config as any)[field];
                if (cell && typeof cell === 'string') {
                    const rowMatch = cell.match(/\d+/);
                    if (rowMatch) {
                        productStartRow = parseInt(rowMatch[0]);
                        break;
                    }
                }
            }

            // Deducimos los campos repetitivos del producto a partir de config
            const productFields = Object.keys(config).filter(key => {
                if (key === '__customNames' || key === '__productFields') return false;
                // Excluimos campos indexados tradicionales (heredados)
                if (key.match(/^(prov|proveedor)\d+.+$/)) return false;
                
                const cellVal = (config as any)[key];
                if (cellVal && typeof cellVal === 'string') {
                    const rowMatch = cellVal.match(/\d+/);
                    if (rowMatch) {
                        const rowNum = parseInt(rowMatch[0]);
                        // Si la fila del mapeo coincide con la fila de productos,
                        // ¡definitivamente es un campo de producto repetitivo!
                        if (rowNum === productStartRow) {
                            return true;
                        }
                    }
                }
                return false;
            });

            if (productStartRow > 0 && q.products.length > 0) {
                if (productFields.length > 0) {
                    for (let i = 0; i < 9; i++) {
                        destSheet.spliceRows(productStartRow + 1, 1);
                    }
                }

                // Insert additional rows if there is more than 1 product
                for (let idx = 1; idx < q.products.length; idx++) {
                    const insertRowIndex = productStartRow + idx;
                    destSheet.insertRow(insertRowIndex, []);
                    copyRowStyle(destSheet, productStartRow, insertRowIndex);
                }

                const fieldAliases: Record<string, string> = {
                    nights: 'noches',
                    destination: 'destino',
                    price: 'precio',
                    cost: 'costo',
                    quantity: 'cantidad',
                    adicionalesServ: 'adicionalesServ'
                };

                // Write product properties row by row
                q.products.forEach((prod, idx) => {
                    const currentRow = productStartRow + idx;

                    productFields.forEach(field => {
                        const cellKey = (config as any)[field];
                        if (cellKey && typeof cellKey === 'string') {
                            const colName = cellKey.match(/[A-Z]+/)?.[0] || '';
                            if (colName) {
                                const targetCellKey = `${colName}${currentRow}`;
                                
                                // Extraer valor con soporte para aliases y variables dinámicas
                                let value = (prod as any)[field];
                                if (value === undefined) {
                                    const aliasKey = fieldAliases[field];
                                    if (aliasKey) {
                                        value = (prod as any)[aliasKey];
                                    }
                                }

                                if (field.endsWith('Pago') && field !== 'pasajeros') {
                                    const baseField = field.substring(0, field.length - 4);
                                    const aliasKey = fieldAliases[baseField];
                                    const baseVal = (prod as any)[baseField] !== undefined 
                                        ? (prod as any)[baseField] 
                                        : ((prod as any)[aliasKey || baseField] || 0);
                                    const comisionVal = prod.comision || 0;
                                    value = baseVal - comisionVal;
                                }

                                setVal(targetCellKey, value);
                            }
                        }
                    });
                });
            }

            // Overall Totals
            setVal(config.baseComisionable, q.baseComisionable);
            setVal(config.comisionAsesor, q.comisionAsesor);
            setVal(config.baseComisionTop, q.baseComisionable - q.comisionAsesor);
            setVal(config.observaciones, q.observaciones || '');
            setVal(config.fechasViaje, q.fechasViaje || '');
            setVal(config.hotelesServicios, q.hotelesServicios || '');

            const totalTarifaNeta = q.products.reduce((sum, p) => sum + p.tarifaNeta, 0);
            const totalImpuestos = q.products.reduce((sum, p) => sum + p.impuestos, 0);
            const totalAdicionalesServ = q.products.reduce((sum, p) => sum + p.adicionalesServ, 0);
            const totalComision = q.products.reduce((sum, p) => sum + p.comision, 0);
            const totalDescuento = q.products.reduce((sum, p) => sum + p.descuento, 0);
            const totalSobrecomision = q.products.reduce((sum, p) => sum + p.sobrecomision, 0);
            const totalFee = q.products.reduce((sum, p) => sum + p.fee, 0);
            const totalTotal = q.products.reduce((sum, p) => sum + p.total, 0);

            setVal((config as any).tarifaNeta, totalTarifaNeta);
            setVal((config as any).tarifaNetaPago, totalTarifaNeta - totalComision);
            setVal((config as any).impuestos, totalImpuestos);
            setVal((config as any).impuestosPago, totalImpuestos);
            setVal((config as any).adicionalesServ, totalAdicionalesServ);
            setVal((config as any).adicionalesServPago, totalAdicionalesServ);
            setVal((config as any).comision, totalComision);
            setVal((config as any).descuento, totalDescuento);
            setVal((config as any).sobrecomision, totalSobrecomision);
            setVal((config as any).fee, totalFee);
            setVal((config as any).total, totalTotal);
            setVal((config as any).totalPago, totalTotal - totalComision);
            setVal((config as any).idCotizacion, q.idCotizacion);

            // Dynamically set any other columns from config/q (header fields not covered above)
            Object.entries(config).forEach(([key, cellKey]) => {
                if (cellKey && typeof cellKey === 'string' && key !== '__customNames' && key !== '__productFields') {
                    // Skip meta keys
                    if (key.startsWith('__')) return;
                    // Skip if this key is a product (item) field - those are handled per-row above
                    if (productFields.includes(key)) return;
                    // Skip if this key is logo
                    if (key === 'logo') return;
                    // All remaining keys are header fields — write value from quotation object
                    const qVal = (q as any)[key];
                    if (qVal !== undefined && qVal !== null && qVal !== '') {
                        setVal(cellKey, qVal);
                    }
                }
            });


            // Forcefully clear cell A1 and the designated logo cell to remove any copied JSON or buffer strings
            destSheet.getCell('A1').value = null;
            if (config.logo) {
                destSheet.getCell(config.logo).value = null;
            }

            // Inject logo if present
            if (q.logo) {
                try {
                    const imageId = outWorkbook.addImage({
                        buffer: Buffer.from(q.logo as any) as any,
                        extension: 'png',
                    });

                    const logoCell = config.logo || 'A1';
                    const colName = logoCell.match(/[A-Z]+/)?.[0] || 'A';
                    const rowNum = parseInt(logoCell.match(/\d+/)?.[0] || '1') - 1;
                    const colIndex = colNameToIndex(colName);

                    destSheet.addImage(imageId, {
                        tl: { col: colIndex, row: rowNum },
                        ext: { width: 120, height: 48 },
                        editAs: 'oneCell'
                    });
                } catch (logoErr) {
                    console.error("Error embedding logo in Excel sheet:", logoErr);
                }
            }
        }

        const formatParam = searchParams.get('format');
        if (formatParam === 'html') {
            const htmlReports = [];
            
            for (const q of groupedList) {
                const dbInfo = qDbMap.get(q.idCotizacion);

                // Buscar si existe una personalización guardada para esta cotización
                const savedCustomization = await prisma.quotationPrintCustomization.findUnique({
                    where: { quotationId: q.idCotizacion }
                });

                let htmlTemplate = null;
                let templateBuffer: Buffer | null = null;
                let config: any = DEFAULT_CONFIG;

                if (savedCustomization && savedCustomization.html) {
                    htmlTemplate = savedCustomization.html;
                }

                if (customFormat) {
                    templateBuffer = customFormat.template ? Buffer.from(customFormat.template) : null;
                    const formatCellConfig = (customFormat.FormatCellCustomization || []).reduce((acc: any, c: any) => {
                        if (c.value) acc[c.code] = c.value;
                        return acc;
                    }, {});
                    config = {
                        ...DEFAULT_CONFIG,
                        ...(customFormat.templateConfig as any || {}),
                        ...formatCellConfig,
                    };
                } else {
                    const physicalConfig = await getCellCustomizationConfig(
                        dbInfo?.branch?.id || null,
                        dbInfo?.implant?.id || null
                    );
                    const templateConfigRaw = dbInfo?.implant?.templateConfig || dbInfo?.branch?.templateConfig;
                    const branchTemplateBuffer = dbInfo?.implant?.template || dbInfo?.branch?.template;
                    const branchHtmlTemplate = dbInfo?.implant?.htmlTemplate || dbInfo?.branch?.htmlTemplate;
                    templateBuffer = branchTemplateBuffer ? Buffer.from(branchTemplateBuffer) : null;

                    if (templateBuffer) {
                        config = {
                            ...(templateConfigRaw as any || {}),
                            ...(physicalConfig || {})
                        };
                    } else if (templateConfigRaw || physicalConfig) {
                        config = { 
                            ...DEFAULT_CONFIG, 
                            ...(templateConfigRaw as any || {}), 
                            ...(physicalConfig || {}) 
                        };
                    }

                    if (!htmlTemplate && branchHtmlTemplate && branchHtmlTemplate.trim().length > 200) {
                        htmlTemplate = branchHtmlTemplate;
                    }
                }

                // 3. If no htmlTemplate yet, try auto-generating from Branch / Implant Excel template
                if (!htmlTemplate && templateBuffer) {
                    try {
                        const logoBuf = dbInfo?.implant?.logo || dbInfo?.branch?.logo;
                        htmlTemplate = await generateHtmlTemplate(Buffer.from(templateBuffer), config, logoBuf ? Buffer.from(logoBuf) : null, q.products.length);
                    } catch (err) {
                        console.error(`Error auto-generating htmlTemplate for quotation ${q.idCotizacion} from branch template:`, err);
                    }
                }

                // 4. System default template fallback (only if no quotation, format, or branch template exists)
                if (!htmlTemplate) {
                    const defaultSystemTemplate = await prisma.quotationPrintDefaultTemplate.findFirst({
                        orderBy: { id: 'asc' }
                    });
                    if (defaultSystemTemplate && defaultSystemTemplate.html) {
                        htmlTemplate = defaultSystemTemplate.html;
                    }
                }

                // 5. Final fallback to default_template.xlsx file
                if (!htmlTemplate) {
                    try {
                        const defaultTemplatePath = path.join(process.cwd(), 'templates', 'default_template.xlsx');
                        const defaultBuffer = fs.readFileSync(defaultTemplatePath);
                        htmlTemplate = await generateHtmlTemplate(defaultBuffer, config, null, q.products.length);
                    } catch (err) {
                        console.error(`Error loading default template HTML:`, err);
                        htmlTemplate = '<div>No template layout available.</div>';
                    }
                }

                let compiledHtml = htmlTemplate;

                const formatDate = (dStr: string) => {
                    if (!dStr) return '';
                    const d = new Date(dStr);
                    return isNaN(d.getTime()) ? dStr : d.toLocaleDateString();
                };

                const formatCurrency = (val: number) => {
                    if (val === null || val === undefined) return '0';
                    return val.toLocaleString('es-CO', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
                };

                const totalTarifaNeta = q.products.reduce((sum, p) => sum + p.tarifaNeta, 0);
                const totalImpuestos = q.products.reduce((sum, p) => sum + p.impuestos, 0);
                const totalAdicionalesServ = q.products.reduce((sum, p) => sum + p.adicionalesServ, 0);
                const totalComision = q.products.reduce((sum, p) => sum + p.comision, 0);
                const totalDescuento = q.products.reduce((sum, p) => sum + p.descuento, 0);
                const totalSobrecomision = q.products.reduce((sum, p) => sum + p.sobrecomision, 0);
                const totalFee = q.products.reduce((sum, p) => sum + p.fee, 0);
                const totalTotal = q.products.reduce((sum, p) => sum + p.total, 0);

                const replacements: { [key: string]: string } = {
                    logo: q.logo ? `<img src="data:image/png;base64,${Buffer.from(q.logo as any).toString('base64')}" alt="Logo" style="max-height: 48px; max-width: 120px; object-fit: contain; display: block; margin: auto;" />` : '',
                    asesor: q.asesor || '',
                    fecha: formatDate(q.fecha),
                    clienteNombre: q.clienteNombre || '',
                    clienteIdentificacion: q.clienteIdentificacion || '',
                    clienteDireccion: q.clienteDireccion || '',
                    clienteTelefono: q.clienteTelefono || '',
                    centroCosto: '',
                    solicita: '',
                    tCambio: String(q.tCambio || 1.0),
                    descripcionPlan: q.descripcionPlan || `Cotización #${q.idCotizacion}`,
                    fechasViaje: q.fechasViaje || '',
                    hotelesServicios: q.hotelesServicios || '',
                    pasajeros: q.pasajeros || 'Mismo titular',
                    pasajerosNombres: q.pasajerosNombres || '',
                    pasajerosApellidos: q.pasajerosApellidos || '',
                    pasajeroCabecera: q.pasajeroCabecera || '',
                    pasajeroCabeceraNombres: q.pasajeroCabeceraNombres || '',
                    pasajeroCabeceraApellidos: q.pasajeroCabeceraApellidos || '',
                    totalAdultos: String(q.totalAdultos),
                    totalNinos: String(q.totalNinos),
                    baseComisionable: formatCurrency(q.baseComisionable),
                    comisionAsesor: formatCurrency(q.comisionAsesor),
                    baseComisionTop: formatCurrency(q.baseComisionable - q.comisionAsesor),
                    observaciones: q.observaciones || '',
                    idCotizacion: String(q.idCotizacion),
                    vendedor: q.vendedor || '',
                    internalNumber: q.internalNumber || '',
                    costoTotal: formatCurrency(q.costoTotal),
                    valorBase: formatCurrency(q.valorBase),
                    utilidad: formatCurrency(q.utilidad),
                    comisionFreelanceValue: formatCurrency(q.comisionFreelanceValue),
                    comisionPropiaValue: formatCurrency(q.comisionPropiaValue),
                    comisionTotalPercentage: String(q.comisionTotalPercentage),
                    comisionFreelancePercentage: String(q.comisionFreelancePercentage),
                    comisionPropiaPercentage: String(q.comisionPropiaPercentage),
                    comisionUtilidadPercentage: String(q.comisionUtilidadPercentage),
                    totalAmount: formatCurrency(q.totalAmount),

                    tarifaNeta: formatCurrency(totalTarifaNeta),
                    tarifaNetaPago: formatCurrency(totalTarifaNeta - totalComision),
                    impuestos: formatCurrency(totalImpuestos),
                    impuestosPago: formatCurrency(totalImpuestos),
                    adicionalesServ: formatCurrency(totalAdicionalesServ),
                    adicionalesServPago: formatCurrency(totalAdicionalesServ),
                    comision: formatCurrency(totalComision),
                    descuento: formatCurrency(totalDescuento),
                    sobrecomision: formatCurrency(totalSobrecomision),
                    fee: formatCurrency(totalFee),
                    total: formatCurrency(totalTotal),
                    totalPago: formatCurrency(totalTotal - totalComision),
                };

                // Add dynamic replacement for product rows in HTML tokens if configured
                q.products.forEach((prod, pIdx) => {
                    const pNum = pIdx + 1;
                    replacements[`proveedor${pNum}Nombre`] = prod.proveedorNombre;
                    replacements[`proveedor${pNum}NIT`] = prod.proveedorNIT;
                    replacements[`proveedor${pNum}Contacto`] = prod.proveedorContacto;
                    replacements[`prov${pNum}TarifaNeta`] = formatCurrency(prod.tarifaNeta);
                    replacements[`prov${pNum}TarifaNetaPago`] = formatCurrency(prod.tarifaNeta - prod.comision);
                    replacements[`prov${pNum}Impuestos`] = formatCurrency(prod.impuestos);
                    replacements[`prov${pNum}ImpuestosPago`] = formatCurrency(prod.impuestos);
                    replacements[`prov${pNum}Adicionales`] = formatCurrency(prod.adicionalesServ);
                    replacements[`prov${pNum}AdicionalesPago`] = formatCurrency(prod.adicionalesServ);
                    replacements[`prov${pNum}Comision`] = formatCurrency(prod.comision);
                    replacements[`prov${pNum}Descuento`] = formatCurrency(prod.descuento);
                    replacements[`prov${pNum}Sobrecomision`] = formatCurrency(prod.sobrecomision);
                    replacements[`prov${pNum}Fee`] = formatCurrency(prod.fee);
                    replacements[`prov${pNum}Total`] = formatCurrency(prod.total);
                    replacements[`prov${pNum}TotalPago`] = formatCurrency(prod.total - prod.comision);

                    // Dynamic mappings for any property in prod:
                    Object.entries(prod).forEach(([propKey, propVal]) => {
                        let formattedVal = propVal !== null && propVal !== undefined ? String(propVal) : '';
                        if (typeof propVal === 'number') {
                            formattedVal = formatCurrency(propVal);
                        } else if (propVal instanceof Date) {
                            formattedVal = formatDate(propVal.toISOString());
                        } else if (typeof propVal === 'string' && propVal.match(/^\d{4}-\d{2}-\d{2}/)) {
                            formattedVal = formatDate(propVal);
                        }
                        
                        const capitalizedKey = propKey.charAt(0).toUpperCase() + propKey.slice(1);
                        replacements[`prov${pNum}${propKey}`] = formattedVal;
                        replacements[`prov${pNum}${capitalizedKey}`] = formattedVal;
                        replacements[`proveedor${pNum}${propKey}`] = formattedVal;
                        replacements[`proveedor${pNum}${capitalizedKey}`] = formattedVal;

                        // Support bidirectional aliases for English/Spanish compatibility
                        const reverseAliases: Record<string, string> = {
                            noches: 'nights',
                            destino: 'destination',
                            precio: 'price',
                            costo: 'cost',
                            cantidad: 'quantity'
                        };
                        const enKey = reverseAliases[propKey];
                        if (enKey) {
                            const capitalizedEnKey = enKey.charAt(0).toUpperCase() + enKey.slice(1);
                            replacements[`prov${pNum}${enKey}`] = formattedVal;
                            replacements[`prov${pNum}${capitalizedEnKey}`] = formattedVal;
                            replacements[`proveedor${pNum}${enKey}`] = formattedVal;
                            replacements[`proveedor${pNum}${capitalizedEnKey}`] = formattedVal;
                        }
                    });
                });

                Object.keys(q).forEach(key => {
                    if (replacements[key] === undefined && key !== 'logo') {
                        const qVal = (q as any)[key];
                        replacements[key] = qVal !== null && qVal !== undefined ? String(qVal) : '';
                    }
                });

                Object.entries(replacements).forEach(([key, val]) => {
                    const token = `{{${key}}}`;
                    compiledHtml = compiledHtml.split(token).join(val);
                });

                // Dynamic replacer for Rentabilidad Negocio table: replaces ALL rows below header with a single dynamic row
                const rentabilidadPattern = /(% COMI?SI[OÓ]N COLAREO[\s\S]*?COMI?SI[OÓ]N COLAEREO[\s\S]*?%COM FRE\/AGE[\s\S]*?COMI?SI[OÓ]N FRE\/AGE[\s\S]*?TOTAL COMI?SI[OÓ]N[\s\S]*?<\/tr>)([\s\S]*?)(<\/tbody>|<\/table>)/i;
                compiledHtml = compiledHtml.replace(rentabilidadPattern, (match: string, headerRow: string, oldRows: string, closingTag: string) => {
                    const singleDataRow = `
<tr>
<td style="text-align: left; vertical-align: middle; padding: 4px; word-break: break-word; white-space: pre-wrap;">${replacements.comisionPropiaPercentage}</td>
<td style="text-align: left; vertical-align: middle; padding: 4px; word-break: break-word; white-space: pre-wrap;">${replacements.comisionPropiaValue}</td>
<td style="text-align: left; vertical-align: middle; padding: 4px; word-break: break-word; white-space: pre-wrap;">${replacements.comisionFreelancePercentage}</td>
<td style="text-align: left; vertical-align: middle; padding: 4px; word-break: break-word; white-space: pre-wrap;">${replacements.comisionFreelanceValue}</td>
<td style="text-align: left; vertical-align: middle; padding: 4px; word-break: break-word; white-space: pre-wrap;">${replacements.utilidad}</td>
</tr>
`;
                    return headerRow + singleDataRow + closingTag;
                });

                // Reemplazo de seguridad global para cualquier remanente estático de plantillas anteriores
                compiledHtml = compiledHtml
                    .replace(/68\.28/g, replacements.comisionPropiaPercentage)
                    .replace(/8\.979\.503/g, replacements.comisionPropiaValue)
                    .replace(/11\.083\.688/g, replacements.utilidad);

                // Limpieza de cualquier token huérfano no configurado o antiguo (ej. {{proveedorNIT}})
                compiledHtml = compiledHtml.replace(/\{\{[^}]+\}\}/g, '');

                htmlReports.push({
                    idCotizacion: q.idCotizacion,
                    html: compiledHtml
                });
            }

            return NextResponse.json(htmlReports);
        }

        if (formatParam === 'json') {
            const worksheetsJson = [];
            for (const sheet of outWorkbook.worksheets) {
                worksheetsJson.push(sheetToHtmlJson(sheet, outWorkbook));
            }
            return NextResponse.json(worksheetsJson);
        }

        const buffer = await outWorkbook.xlsx.writeBuffer();

        return new Response(buffer, {
            headers: {
                'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition': `attachment; filename=Reporte_Cotizaciones_${idIni}_a_${idFin}.xlsx`
            }
        });

    } catch (error: any) {
        console.error('Error generating dynamic Excel report:', error);
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
