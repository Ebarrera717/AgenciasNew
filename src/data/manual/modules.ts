export interface ManualField {
    name: string;
    type: string;
    description: string;
}

export interface ManualStep {
    number: number;
    title: string;
    description: string;
    codeSnippet?: string;
    tip?: string;
}

export interface ManualProcedure {
    code?: string;
    masterCode?: string; // Código de correspondencia con fnMasterList() (ej: 'User', 'Branch', 'Client', etc.)
    name: string;
    summary: string;
    concept: string;
    fields?: ManualField[];
    steps: ManualStep[];
    businessRules?: string[];
}

export interface ManualModule {
    id: string;
    title: string;
    iconName: string;
    category: string;
    description: string;
    overview: string;
    procedures: ManualProcedure[];
}

export const MANUAL_MODULES: ManualModule[] = [
    {
        id: 'prequotations',
        title: 'Gestión de Pre-Cotizaciones y Trazabilidad',
        iconName: 'FilePlus',
        category: 'Operaciones Comerciales',
        description: 'Manual de procedimiento para el registro básico de pre-cotizaciones, avisos destacados para cotización, consecutivo compartido y seguimiento de ciclo de vida.',
        overview: 'El módulo de Pre-Cotizaciones permite capturar solicitudes preliminares con datos básicos (cliente digitado o seleccionado, sucursal, fechas, prestador y observaciones). Comparte el mismo consecutivo numérico con las Cotizaciones y permite realizar el seguimiento completo del ciclo de vida (Pre-Cotización ➔ Cotización ➔ Factura ERP).',
        procedures: [
            {
                code: 'PRE-01',
                name: 'Registro de Nueva Pre-Cotización',
                summary: 'Captura rápida de solicitudes preliminares asignando automáticamente el consecutivo unificado.',
                concept: 'Permite registrar la solicitud de un cliente (nombre digitado libremente o seleccionado), adjuntando datos de encabezado, avisos especiales de atención para el cotizador y fechas estimadas.',
                fields: [
                    { name: 'Sucursal', type: 'Selección Obligatoria', description: 'Sucursal de la agencia responsable de atender la solicitud.' },
                    { name: 'Cliente', type: 'Texto / Selección', description: 'Permite digitar el nombre del cliente libremente o elegir un cliente ya registrado.' },
                    { name: 'Datos de Cotización', type: 'Texto Multilínea', description: 'Instrucciones preliminares que viajarán al encabezado de la cotización.' },
                    { name: 'Aviso para Cotización', type: 'Texto Destacado', description: 'Mensaje de advertencia o recomendación especial que aparecerá de forma prominente en la pantalla del cotizador.' },
                    { name: 'Fecha Inicio / Fin', type: 'Fechas', description: 'Rango de fechas solicitadas para el viaje o servicio.' }
                ],
                businessRules: [
                    'El consecutivo numérico asignado a la pre-cotización se reservará y compartirá exactamente con la cotización que se genere posteriormente.',
                    'Si el cliente fue digitado como texto libre, la validación y selección del cliente en la base de datos se requerirá al convertir la solicitud en Cotización.'
                ],
                steps: [
                    { number: 1, title: 'Ingresar a Pre-Cotizaciones', description: 'Haga clic en la opción "Pre-Cotizaciones" del menú lateral principal.' },
                    { number: 2, title: 'Crear Registro', description: 'Haga clic en "+ Nueva Pre-Cotización", complete la sucursal y los datos del cliente.' },
                    { number: 3, title: 'Guardar Solicitud', description: 'Haga clic en "Crear Pre-Cotización". El sistema asignará el número consecutivo correspondiente.' }
                ]
            },
            {
                code: 'PRE-02',
                name: 'Conversión a Cotización y Respuesta al Aviso',
                summary: 'Transformación de Pre-Cotización a Cotización con transferencia de datos, aviso prominente y respuesta.',
                concept: 'Proceso por el cual el asesor toma la pre-cotización, visualiza el aviso destacado del solicitante, ingresa su respuesta y guarda la cotización manteniendo el consecutivo numérico.',
                fields: [
                    { name: 'Aviso Especial', type: 'Banner de Alerta', description: 'Mensaje de atención cargado de forma prominente en la pantalla de cotización.' },
                    { name: 'Respuesta al Aviso', type: 'Texto', description: 'Aclaración o respuesta digitada por la persona que armó la cotización.' }
                ],
                businessRules: [
                    'Al guardar la cotización, la Pre-Cotización cambiará automáticamente su estado a "COTIZADA" y vinculará el ID de la cotización creada.',
                    'La respuesta digitada quedará registrada en el historial de la pre-cotización para consulta del solicitante original.'
                ],
                steps: [
                    { number: 1, title: 'Seleccionar Pre-Cotización', description: 'En la lista de Pre-Cotizaciones con estado "POR COTIZAR", haga clic en el botón "Convertir".' },
                    { number: 2, title: 'Atender el Aviso', description: 'Lea el banner destacado de aviso especial e ingrese su respuesta aclaratoria.' },
                    { number: 3, title: 'Completar Productos y Guardar', description: 'Adicione los servicios solicitados y guarde la cotización. El estado se actualizará automáticamente a "COTIZADA".' }
                ]
            }
        ]
    },
    {
        id: 'licensing',
        title: 'Licenciamiento y Seguridad por Fecha',
        iconName: 'ShieldCheck',
        category: 'Administración y Seguridad (Exclusivo SUPERADMINISTRADOR)',
        description: 'Manual de funcionamiento del control de expiración por fecha, autenticidad por NIT de empresa y renovación del servicio.',
        overview: 'El módulo de Licenciamiento garantiza que el sistema funcione únicamente dentro de la fecha contratada y en la infraestructura de la agencia autorizada. Utiliza un empaquetado seguro de certificado de licencia con prefijo KOR1 que vincula la razón social, el NIT de la empresa y la fecha de vencimiento.',
        procedures: [
            {
                code: 'LIC-01',
                name: 'Generación de Claves de Licencia (Herramienta Proveedor)',
                summary: 'Emisión de certificados de licencia cifrados para entregar al cliente.',
                concept: 'Cada clave generada constituye un certificado digital que empaqueta los tres datos de validación: Razón Social, NIT del cliente y Fecha de Vencimiento.',
                fields: [
                    { name: 'Nombre / Razón Social', type: 'Texto', description: 'Nombre oficial de la agencia cliente autorizada.' },
                    { name: 'NIT / Cédula', type: 'Texto Alfanumérico', description: 'Identificación tributaria única de la empresa para amarrar la licencia.' },
                    { name: 'Fecha Expiración', type: 'Fecha (Año-Mes-Día)', description: 'Fecha límite exacta en la cual el sistema solicitará renovación.' }
                ],
                businessRules: [
                    'Si el NIT grabado en el certificado no coincide con el NIT registrado en la agencia, el sistema bloqueará la activación por seguridad.',
                    'Modificar manualmente los caracteres del certificado invalidará la licencia.'
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Iniciar el Programa Generador',
                        description: 'En el equipo del proveedor, ejecute GenerarLicencia.bat ubicado en la carpeta principal del sistema.',
                        codeSnippet: 'GenerarLicencia.bat'
                    },
                    {
                        number: 2,
                        title: 'Diligenciar Datos del Contrato',
                        description: 'Escriba el Nombre de la Agencia, el NIT sin puntos ni guiones, y la fecha límite acordada (formato YYYY-MM-DD).'
                    },
                    {
                        number: 3,
                        title: 'Copiar y Entregar el Certificado KOR1',
                        description: 'Copie el texto completo generado con el prefijo KOR1... y entréguelo a la agencia para su activación.'
                    }
                ]
            },
            {
                code: 'LIC-02',
                name: 'Activación y Renovación del Servicio',
                summary: 'Aplicación de la clave de renovación en la pantalla web o mediante ejecutable local.',
                concept: 'Al ingresar un nuevo certificado KOR1, el sistema descifra el contenido, verifica que pertenezca a la empresa y actualiza la fecha de vencimiento sin requerir reiniciar el servidor.',
                fields: [
                    { name: 'Clave de Licencia (Token)', type: 'Texto Largo', description: 'Cadena completa emitida por el soporte técnico que inicia con el prefijo KOR1.' }
                ],
                businessRules: [
                    'Si la fecha expira, la plataforma redirige automáticamente a la pantalla de renovación.',
                    'Al activar con éxito, el sistema desbloquea la navegación de inmediato.'
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Activación desde la Pantalla Web',
                        description: 'Pega la clave KOR1 en el formulario de la pantalla de bloqueo y presione "Activar Nueva Licencia".'
                    },
                    {
                        number: 2,
                        title: 'Activación por Ejecutable de Consola',
                        description: 'En el servidor de la agencia, ejecute ActivarLicencia.bat, pegue la clave y presione Enter.',
                        codeSnippet: 'ActivarLicencia.bat'
                    }
                ]
            }
        ]
    },
    {
        id: 'quotations',
        title: 'Módulo de Cotizaciones',
        iconName: 'FileText',
        category: 'Operaciones Comerciales',
        description: 'Manual descriptivo para el ciclo completo de cotizaciones: creación, liquidación de margen, comisiones e impresión de propuestas.',
        overview: 'El módulo de Cotizaciones gestiona el ciclo comercial completo para agencias de viajes. Permite estructurar cotizaciones de tiquetes aéreos, servicios terrestres, hoteles y paquetes, calculando automáticamente comisiones, impuestos e itinerarios.',
        procedures: [
            {
                code: 'COT-01',
                name: 'Consulta e Historial de Cotizaciones',
                summary: 'Consola principal para buscar, filtrar, editar, duplicar, imprimir y facturar cotizaciones.',
                concept: 'Muestra el listado de propuestas comerciales de la agencia con filtros por cliente, consecutivo, asesor comercial o estado.',
                fields: [
                    { name: 'Buscador General', type: 'Campo Texto', description: 'Filtra en tiempo real por consecutivo, cliente o destino.' },
                    { name: 'Filtro por Estado', type: 'Selector', description: 'Permite acotar por estado (Nuevo, Aprobado, Facturado, Cancelado).' },
                    { name: 'Botón + Nueva Cotización', type: 'Botón Acción', description: 'Abre el formulario de registro de cotizaciones desde cero.' },
                    { name: 'Acción Editar', type: 'Botón Fila', description: 'Abre el formulario para ajustar precios, productos o pasajeros.' },
                    { name: 'Acción Duplicar', type: 'Botón Fila', description: 'Crea una copia idéntica de la cotización con un consecutivo nuevo.' },
                    { name: 'Acción Imprimir', type: 'Botón Fila', description: 'Genera la propuesta en formato PDF o Excel listo para enviar al cliente.' },
                    { name: 'Acción Facturar', type: 'Botón Fila', description: 'Convierte la cotización en factura de venta conectada con la contabilidad.' }
                ],
                businessRules: [
                    'Una cotización facturada preserva su registro para auditoría contable.',
                    'Duplicar una cotización genera un nuevo consecutivo conservando los pasajeros y productos.'
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Navegar al Historial de Cotizaciones',
                        description: 'En el menú lateral, seleccione Cotizaciones > Historial.'
                    },
                    {
                        number: 2,
                        title: 'Filtrar y Buscar Cotizaciones',
                        description: 'Escriba el nombre del cliente o filtre por estado para ubicar la propuesta.'
                    },
                    {
                        number: 3,
                        title: 'Ejecutar Acciones Comerciales',
                        description: 'Utilice los botones de acción para editar, imprimir en PDF o convertir la cotización a factura.'
                    }
                ]
            },
            {
                code: 'COT-02',
                name: 'Formulario de Creación de Cotizaciones',
                summary: 'Registro detallado de cliente, divisa, productos, liquidación de costos, utilidades e itinerarios.',
                concept: 'Calcula en tiempo real los costos, precios de venta, utilidades, comisiones de asesores e impuestos aplicables.',
                fields: [
                    { name: 'Cliente', type: 'Buscador / Selector', description: 'Selecciona el cliente de la base de datos o permite crear uno nuevo.' },
                    { name: 'Moneda y Tasa de Cambio', type: 'Selector / Numérico', description: 'Define la divisa de la transacción (COP, USD, EUR) y la tasa de conversión.' },
                    { name: 'Sucursal / Implant', type: 'Selector', description: 'Asigna la sucursal emisora para definir logos y plantillas.' },
                    { name: 'Vendedor', type: 'Selector', description: 'Asigna el asesor comercial para el cálculo de comisiones de venta.' },
                    { name: 'Productos y Servicios', type: 'Grilla de Ítems', description: 'Permite incorporar vuelos, hoteles, tours o servicios manuales.' },
                    { name: 'Pasajeros e Itinerarios', type: 'Detalle de Ítem', description: 'Especifica nombres, documentos, fechas de viaje y trayectos.' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Diligenciar Encabezado y Cliente',
                        description: 'Seleccione el cliente, la moneda de cotización y la sucursal correspondiente.'
                    },
                    {
                        number: 2,
                        title: 'Agregar Servicios o Productos',
                        description: 'Haga clic en "+ Agregar Producto", especifique el tipo de servicio, costo y precio de venta.'
                    },
                    {
                        number: 3,
                        title: 'Guardar y Generar Propuesta',
                        description: 'Presione "Guardar Cotización" para emitir la propuesta oficial.'
                    }
                ]
            }
        ]
    },
    {
        id: 'invoices',
        title: 'Módulo de Facturación ERP',
        iconName: 'Receipt',
        category: 'Contabilidad e Integración ERP',
        description: 'Manual de funcionamiento para la emisión de facturas de venta, carga masiva de tiquetes e integración contable.',
        overview: 'Automatiza el flujo de facturación de la agencia. Permite emitir facturas individuales desde cotizaciones aprobadas o procesar cargas masivas de tiquetes desde archivos de Excel.',
        procedures: [
            {
                code: 'FAC-01',
                name: 'Emisión e Historial de Facturas',
                summary: 'Gestión del historial de facturación de venta y estado contable.',
                concept: 'Registra los movimientos contables de venta, cartera, cuentas por cobrar e impuestos a partir de las cotizaciones aprobadas.',
                fields: [
                    { name: 'Buscador de Facturas', type: 'Texto', description: 'Busca facturas por número de consecutivo, cliente o estado.' },
                    { name: 'Estado Contable', type: 'Indicador', description: 'Muestra el estado de la factura (Nuevo, Facturado, Cancelado).' },
                    { name: 'Forma de Pago', type: 'Selector', description: 'Define la modalidad de pago (Efectivo, Tarjeta, Transferencia, Crédito).' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Facturar desde Cotización',
                        description: 'En el historial de cotizaciones, ubique una propuesta aprobada y presione "Facturar".'
                    },
                    {
                        number: 2,
                        title: 'Confirmar Datos de Pago y Emitir',
                        description: 'Verifique la forma de pago y emita la factura oficial.'
                    }
                ]
            },
            {
                code: 'FAC-03',
                name: 'Facturación Directa desde Reservas GDS',
                summary: 'Búsqueda multiterminal y precarga automática de facturas a partir de reservas procesadas por la interfaz Amadeus/Sabre.',
                concept: 'Permite buscar reservas en base de datos combinando 5 filtros (Cliente, Pasajero, Record/PNR, Tiquete, Aerolínea) y precargar automáticamente la factura desglosando la Tarifa Base neta ($1.953.300) y los cargos/impuestos leídos (IVA, Tasas Aer y Otros), asignando el producto configurado por parámetro, el proveedor aerolínea por sigla, el itinerario editable y calculando Fecha Inicial y Fecha Final.',
                fields: [
                    { name: 'Cargar desde Reserva / GDS', type: 'Botonera', description: 'Abre el modal de búsqueda multiterminal de reservas GDS por tiquete individual.' },
                    { name: 'Filtro Cliente / PNR / Tiquete', type: 'Texto', description: 'Filtra los tiquetes por código PNR, cliente, tiquete o aerolínea.' },
                    { name: 'Selección Múltiple de Tiquetes', type: 'Casilla de Selección', description: 'Permite seleccionar uno o varios tiquetes individuales para facturarlos en lote.' },
                    { name: 'Desglose Tarifa e Impuestos', type: 'Cálculo Automático', description: 'Calcula la Tarifa Base neta como precio base e inserta IVA, Tasas (TUA) y Otros (OTR) con sus montos leídos por tiquete.' },
                    { name: 'Fecha Inicial / Fecha Final', type: 'Fecha', description: 'Fechas del primer y último tramo del itinerario de vuelo.' },
                    { name: 'Itinerario de Vuelo', type: 'Tabla Editable', description: 'Detalle de tramos aéreos (Origen, Destino, Aerolínea, Clase, Vuelo, Fechas, Farebasis).' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Abrir Búsqueda de Reservas / Tiquetes',
                        description: 'En la pantalla de Facturación Nueva (/dashboard/invoices/new), presione el botón "Cargar desde Reserva / GDS".'
                    },
                    {
                        number: 2,
                        title: 'Aplicar Filtros Combinados y Selección',
                        description: 'Ingrese los criterios de búsqueda (Cliente, Pasajero, PNR, Tiquete o Aerolínea) y presione "Buscar Reservas". Marque las casillas de los tiquetes que desea facturar.'
                    },
                    {
                        number: 3,
                        title: 'Importar y Marcar como Vendido',
                        description: 'Presione "Importar Tiquetes Seleccionados". Al guardar la factura, la base de datos marcará automáticamente dichos tiquetes como FACTURADOS e indicará el ID de factura generado, excluyéndolos de futuras búsquedas.'
                    }
                ]
            },
            {
                code: 'FAC-02',
                name: 'Importación Masiva desde Excel / GDS',
                summary: 'Carga de lotes de tiquetes y servicios procedentes de sistemas de reserva.',
                concept: 'Lee archivos de Excel estandarizados y genera automáticamente las cotizaciones y facturas en lote.',
                fields: [
                    { name: 'Archivo Excel', type: 'Selector Archivo', description: 'Archivo con la estructura de tiquetes o ventas a importar.' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Cargar el Archivo',
                        description: 'En Facturación > Importar Excel, arrastre el archivo de ventas.'
                    },
                    {
                        number: 2,
                        title: 'Validar y Procesar Lote',
                        description: 'Verifique la vista previa sin errores y presione "Procesar Lote".'
                    }
                ]
            }
        ]
    },
    {
        id: 'executions',
        title: 'Ejecución Interactiva de Procedimientos',
        iconName: 'PlaySquare',
        category: 'Herramientas de Consulta y Procesos',
        description: 'Manual de funcionamiento de la consola interactiva de consultas, filtros dinámicos y plantillas de pruebas.',
        overview: 'Permite a los administradores ejecutar consultas avanzadas y procesos del sistema mediante formularios interactivos construidos dinámicamente.',
        procedures: [
            {
                code: 'EJE-01',
                name: 'Consola de Ejecuciones y Consultas',
                summary: 'Ejecución interactiva de procedimientos con resultados en tabla y exportación.',
                concept: 'Construye automáticamente formularios con selectores de fecha, listas desplegables o cajas de texto según la consulta seleccionada.',
                fields: [
                    { name: 'Lista de Consultas', type: 'Desplegable', description: 'Lista de los procedimientos y reportes de consulta registrados.' },
                    { name: 'Filtros Dinámicos', type: 'Formulario Mixto', description: 'Campos de fecha, cliente o sucursal requeridos por la consulta.' },
                    { name: 'Botón Cargar Preset', type: 'Botón Acción', description: 'Carga filtros predeterminados para pruebas frecuentes.' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Seleccionar la Consulta',
                        description: 'En Ejecuciones > Procedimientos, escoja la consulta en la lista desplegable.'
                    },
                    {
                        number: 2,
                        title: 'Diligenciar Filtros y Ejecutar',
                        description: 'Complete los filtros requeridos y presione "Ejecutar".'
                    }
                ]
            }
        ]
    },
    {
        id: 'reports',
        title: 'Reportes y Diseñador de Informes',
        iconName: 'BarChart3',
        category: 'Analítica e Informes Gerenciales',
        description: 'Manual de funcionamiento del centro de informes estadísticos, producción por cliente y rentabilidad.',
        overview: 'Ofrece informes consolidados de ventas por asesor, rentabilidad por producto e indicadores comerciales con exportación a Excel corporativo.',
        procedures: [
            {
                code: 'REP-01',
                name: 'Informes Gerenciales y de Ventas',
                summary: 'Generación de reportes de producción con filtros por fechas y sucursales.',
                concept: 'Calcula totales de ventas, utilidad, comisiones y niveles de conversión comercial.',
                fields: [
                    { name: 'Tipo de Reporte', type: 'Selector', description: 'Elija entre Ventas por Vendedor, Producción por Cliente o Rentabilidad.' },
                    { name: 'Rango de Fechas', type: 'Fechas', description: 'Período de inicio y fin a consultar.' },
                    { name: 'Ver Reporte en Pantalla', type: 'Botón Primario (Azul)', description: 'Abre la vista previa documental en pantalla formateada con totales sumarizados e impresión directa/PDF.' },
                    { name: 'Copiar a Excel', type: 'Botón Secundario (Azul Claro)', description: 'Copia el resultado en formato TSV directamente al portapapeles para pegar en Excel.' },
                    { name: 'Descargar Excel (.xlsx)', type: 'Botón Éxito (Verde)', description: 'Exporta el informe estructurado a un libro de cálculo Microsoft Excel.' }
                ],
                steps: [
                    {
                        number: 1,
                        title: 'Seleccionar o Diseñar el Reporte',
                        description: 'En el centro de reportes (/dashboard/reports), elija una plantilla guardada o cree un reporte personalizado.'
                    },
                    {
                        number: 2,
                        title: 'Visualizar e Imprimir en Pantalla',
                        description: 'Tras aplicar los filtros, presione "Ver Reporte en Pantalla" para abrir la vista previa formal en documento imprimible con encabezado corporativo y totales sumarizados al pie de las columnas de valor.'
                    }
                ]
            }
        ]
    },
    {
        id: 'config',
        title: 'Configuración del Sistema y Maestros',
        iconName: 'Settings',
        category: 'Configuración Global',
        description: 'Manual de funcionamiento detallado para cada una de las 25 tablas maestras, parámetros, usuarios y módulos del sitio.',
        overview: 'El módulo de Configuración (/dashboard/settings) administra todas las tablas maestras de la plataforma. Cuenta con selector dinámico de ordenamiento y filtrado por estado (Activos primero, Inactivos primero, Solo Activos, Solo Inactivos) tanto en los controles principales como haciendo clic directo en el encabezado de la columna "Estado" de las tablas.',
        procedures: [
            {
                code: 'MAE-01',
                masterCode: 'User',
                name: 'Maestro de Usuarios y Control de Acceso',
                summary: 'Administración de cuentas de usuarios, credenciales, sucursales y roles de acceso.',
                concept: 'Define el registro de colaboradores de la agencia asignando su rol (SUPERADMINISTRADOR, ADMIN, VENDEDOR) para controlar la visibilidad de pantallas y permisos.',
                fields: [
                    { name: 'Nombre de Usuario', type: 'Texto', description: 'Nombre completo del colaborador.' },
                    { name: 'Correo Electrónico', type: 'Email', description: 'Usuario de ingreso a la plataforma.' },
                    { name: 'Rol Asignado', type: 'Selector', description: 'Nivel de acceso en la plataforma (SUPERADMINISTRADOR, ADMIN, VENDEDOR).' },
                    { name: 'Sucursal / Implant', type: 'Selector', description: 'Sucursal a la cual está vinculado el usuario.' },
                    { name: 'Edición de Reportes', type: 'Switch', description: 'Autoriza al usuario a modificar diseños de plantilla.' }
                ],
                steps: [
                    { number: 1, title: 'Abrir pestaña Usuarios', description: 'En Ajustes (/dashboard/settings), seleccione la pestaña "Usuarios".' },
                    { number: 2, title: 'Crear o Modificar', description: 'Haga clic en "+ Nuevo Usuario", complete el formulario con datos y rol, y guarde.' }
                ]
            },
            {
                code: 'MAE-02',
                masterCode: 'Branch',
                name: 'Maestro de Sucursales',
                summary: 'Registro de agencias físicas o virtuales, logos y datos de contacto para encabezados de cotización.',
                concept: 'Permite administrar las diferentes sucursales de la empresa para personalizar el logo, la plantilla HTML y la información legal impresos en los documentos.',
                fields: [
                    { name: 'Código Sucursal', type: 'Texto Único', description: 'Identificador corto de la sucursal.' },
                    { name: 'Nombre Sucursal', type: 'Texto', description: 'Nombre de la agencia o punto de atención.' },
                    { name: 'Logo Corporativo', type: 'Imagen', description: 'Logo que aparecerá en los PDF de cotizaciones de esta sucursal.' }
                ],
                steps: [
                    { number: 1, title: 'Gestión de Sucursal', description: 'Seleccione la pestaña "Sucursales", cargue el logo institucional y configure los datos de contacto.' }
                ]
            },
            {
                code: 'MAE-03',
                masterCode: 'Implant',
                name: 'Maestro de Implants',
                summary: 'Administración de oficinas implantadas en clientes corporativos.',
                concept: 'Gestiona los puntos de atención ubicados dentro de las instalaciones de clientes empresariales.',
                fields: [
                    { name: 'Nombre Implant', type: 'Texto', description: 'Denominación de la oficina implantada.' },
                    { name: 'Sucursal Padre', type: 'Selector', description: 'Sucursal a la que pertenece operativamente el implant.' }
                ],
                steps: [
                    { number: 1, title: 'Configurar Implant', description: 'En la pestaña "Implants", agregue o edite el punto corporativo asignando su sucursal.' }
                ]
            },
            {
                code: 'MAE-04',
                masterCode: 'Client',
                name: 'Maestro de Clientes',
                summary: 'Base de datos de clientes individuales y corporativos con NIT/Cédula y contactos.',
                concept: 'Almacena la información de los clientes para agilizar la emisión de cotizaciones y facturas contables.',
                fields: [
                    { name: 'Nombre / Razón Social', type: 'Texto', description: 'Nombre completo o razón social del cliente.' },
                    { name: 'Documento / NIT', type: 'Texto Único', description: 'Cédula o NIT único para facturación.' },
                    { name: 'Información de Contacto', type: 'Texto / Email', description: 'Teléfonos, dirección y correo electrónico de notificación.' },
                    { name: 'Plazo (Días)', type: 'Numérico', description: 'Días de plazo de crédito concedidos al cliente para el cálculo automático de la fecha de vencimiento en las facturas.' }
                ],
                steps: [
                    { number: 1, title: 'Registrar Cliente', description: 'En la pestaña "Clientes", presione "+ Nuevo Cliente" e ingrese documento, plazo de crédito en días y datos de contacto.' }
                ]
            },
            {
                code: 'MAE-05',
                masterCode: 'Provider',
                name: 'Maestro de Proveedores',
                summary: 'Administración de proveedores de servicios turísticos, consolidadores y aerolíneas.',
                concept: 'Registra los proveedores con los cuales la agencia contrata servicios (consolidadores, mayoristas, aerolíneas). Permite asociar un Tipo de Proveedor y, para aerolíneas, ingresar el Código IATA y la Sigla (ej. AV) para homologación y asignación automática en la lectura de archivos GDS.',
                fields: [
                    { name: 'Código Proveedor', type: 'Texto', description: 'Código asignado al proveedor (ej. AMADEUS, AVIANCA).' },
                    { name: 'Nombre Proveedor', type: 'Texto', description: 'Razón social del proveedor o mayorista.' },
                    { name: 'Tipo de Proveedor', type: 'Selección Maestro', description: 'Tipo asignado desde el maestro de Tipos de Proveedor (ej. Aerolínea, Hotel, Mayorista).' },
                    { name: 'Código de Aerolínea', type: 'Texto (IATA)', description: 'Código numérico de aerolínea (ej. 134 para Avianca). Requerido si el tipo es Aerolínea.' },
                    { name: 'Sigla de Aerolínea', type: 'Texto (2 letras)', description: 'Sigla IATA de 2 letras de la aerolínea (ej. AV). Se valida contra el tiquete GDS (prestadoraCode) para enlazar el proveedor automáticamente.' }
                ],
                businessRules: [
                    'Si el Tipo de Proveedor tiene activa la casilla "¿Es Aerolínea?", el sistema desplegará automáticamente los campos Código de Aerolínea y Sigla.',
                    'Al importar reservas o tiquetes GDS, el procedimiento emparejará la sigla de la aerolínea con el campo Sigla del proveedor para asignar la relación automáticamente en BookingProductGDS.'
                ],
                steps: [
                    { number: 1, title: 'Administrar Proveedor', description: 'En la pestaña "Proveedores", haga clic en "+ Nuevo Proveedor", seleccione el Tipo de Proveedor e ingrese el código y la sigla si aplica.' }
                ]
            },
            {
                code: 'MAE-05B',
                masterCode: 'ProviderType',
                name: 'Maestro de Tipos de Proveedor',
                summary: 'Categorización parametrizable de los proveedores comerciales.',
                concept: 'Permite crear y clasificar los distintos tipos de proveedores (Aerolíneas, Hoteles, Mayoristas, Renta de Autos), marcando de manera específica cuáles tipos corresponden a Aerolíneas para habilitar sus atributos IATA.',
                fields: [
                    { name: 'Código', type: 'Texto Único', description: 'Identificador del tipo de proveedor (ej. AIRLINE, HOTEL).' },
                    { name: 'Nombre', type: 'Texto', description: 'Nombre descriptivo del tipo (ej. Aerolínea, Mayorista Internacional).' },
                    { name: '¿Es Aerolínea?', type: 'Booleano / Switch', description: 'Indicador que habilita dinámicamente el código y la sigla IATA en la ficha del proveedor.' }
                ],
                steps: [
                    { number: 1, title: 'Crear Tipo de Proveedor', description: 'En la pestaña "Tipos de Proveedor", presione "+ Nuevo Tipo de Proveedor", defina el código, nombre y active la casilla "¿Es Aerolínea?" si corresponde.' }
                ]
            },
            {
                code: 'MAE-06',
                masterCode: 'Prestadora',
                name: 'Maestro de Prestadoras y Hoteles',
                summary: 'Catálogo de hoteles, cadenas hoteleras y operadores locales de servicios.',
                concept: 'Permite asociar hoteles y prestadoras de servicios a los productos cotizados.',
                fields: [
                    { name: 'Nombre Prestadora', type: 'Texto', description: 'Nombre del hotel o prestadora turística.' },
                    { name: 'Código IATA / Ciudad', type: 'Texto', description: 'Ubicación geográfica o código de destino.' }
                ],
                steps: [
                    { number: 1, title: 'Cargar Prestadora', description: 'En la pestaña "Prestadoras", cree la ficha del hotel u operador.' }
                ]
            },
            {
                code: 'MAE-07',
                masterCode: 'Product',
                name: 'Maestro de Productos y Catálogo',
                summary: 'Catálogo de productos (vuelos, paquetes, seguros, hoteles) con precios base, tarifas y asignación específica de cargos e impuestos.',
                concept: 'Almacena los productos recurrentes que ofrece la agencia para ser añadidos rápidamente a las cotizaciones y definir los cargos/impuestos aplicables a cada uno.',
                fields: [
                    { name: 'Tipo de Producto', type: 'Selector', description: 'Vuelo, Hotel, Asistencia, Paquete, Tour.' },
                    { name: 'Descripción / Tarifa', type: 'Texto / Numérico', description: 'Detalle del servicio y costo de referencia.' },
                    { name: 'Cargos e Impuestos Asignados', type: 'Selección Múltiple', description: 'Permite seleccionar qué cargos/impuestos específicos aplican a este producto. Si no se selecciona ninguno, aplicarán todos por defecto.' }
                ],
                businessRules: [
                    'Si un producto tiene impuestos específicos asignados en el maestro de Productos, al cotizarlo/facturarlo solo se mostrarán esos impuestos seleccionados.',
                    'Si no se asignan impuestos a un producto, estará sujeto a los impuestos globales configurados.'
                ],
                steps: [
                    { number: 1, title: 'Gestionar Producto', description: 'En la pestaña "Productos", configure las tarifas base del catálogo y asigne los cargos/impuestos correspondientes.' }
                ]
            },
            {
                code: 'MAE-08',
                masterCode: 'Seller',
                name: 'Maestro de Vendedores / Asesores',
                summary: 'Registro de asesores comerciales y vendedores para cálculo de producción y comisiones.',
                concept: 'Permite asignar el vendedor a cada cotización y liquidar sus métricas comerciales.',
                fields: [
                    { name: 'Nombre Vendedor', type: 'Texto', description: 'Nombre del asesor comercial.' },
                    { name: 'Correo / Código', type: 'Email / Texto', description: 'Correo del asesor e identificador interno.' }
                ],
                steps: [
                    { number: 1, title: 'Registrar Vendedor', description: 'En la pestaña "Vendedores", agregue al nuevo asesor comercial.' }
                ]
            },
            {
                code: 'MAE-09',
                masterCode: 'TicketPrinter',
                name: 'Maestro de Tiqueteadores',
                summary: 'Registro de asesores tiqueteadores responsables de la emisión de billetes aéreos.',
                concept: 'Identifica al tiqueteador que emitió la reserva o el boleto aéreo.',
                fields: [
                    { name: 'Nombre Tiqueteador', type: 'Texto', description: 'Nombre del emisor de tiquetes.' }
                ],
                steps: [
                    { number: 1, title: 'Configurar Tiqueteador', description: 'En la pestaña "Tiqueteadores", registre los usuarios emisores.' }
                ]
            },
            {
                code: 'MAE-10',
                masterCode: 'ChargeAndTax',
                name: 'Maestro de Cargos e Impuestos',
                summary: 'Configuración de impuestos (IVA, FEE, Tasas aeroportuarias) con ordenamiento prioritario de presentación.',
                concept: 'Define las reglas de impuestos y cargos administrativos de la agencia y su prioridad de visualización.',
                fields: [
                    { name: 'Nombre Impuesto', type: 'Texto', description: 'IVA 19%, FEE Agencia, Tasa Administrativa, OTR (Otros Impuestos).' },
                    { name: 'Orden (Prioridad)', type: 'Numérico', description: 'Permite definir un orden numérico (1, 2, 3...). Si no se especifica, TARIFA siempre aparece primero y los demás se ordenan alfabéticamente.' },
                    { name: 'Operación y Valor', type: 'Porcentaje / Costo Fijo / Ninguna', description: 'Porcentaje (%), Costo Fijo ($) o Ninguna (Digitar / Libre en Cotización), donde el valor se ingresa manualmente al cotizar.' }
                ],
                businessRules: [
                    'Si un cargo/impuesto cuenta con un orden definido (> 0), se respetará dicha prioridad en pantalla; de lo contrario, TARIFA saldrá de primero y los demás alfabéticamente.',
                    'Si un código de impuesto procedente de un tiquete/reserva GDS no cuenta con equivalencia asignada en la tabla EquivalencesInterfaces, se asignará y sumará automáticamente al impuesto con código "OTR" (Otros Impuestos).'
                ],
                steps: [
                    { number: 1, title: 'Crear Impuesto', description: 'En la pestaña "Cargos e Impuestos", defina el nombre, orden de presentación y valor del cargo.' }
                ]
            },
            {
                code: 'MAE-11',
                masterCode: 'Combo',
                name: 'Maestro de Combos y Paquetes',
                summary: 'Agrupación de múltiples productos en paquetes promocionales con cupos.',
                concept: 'Permite empaquetar vuelo + hotel + seguro bajo una tarifa combo preferencial.',
                fields: [
                    { name: 'Nombre Combo', type: 'Texto', description: 'Ej. Cancún Todo Incluido 5 Días.' },
                    { name: 'Cupos Disponibles', type: 'Numérico', description: 'Cantidad de cupos inventariados para el paquete.' }
                ],
                steps: [
                    { number: 1, title: 'Diseñar Combo', description: 'En la pestaña "Combos", cree el paquete y asocie los productos que lo integran.' }
                ]
            },
            {
                code: 'MAE-12',
                masterCode: 'Currency',
                name: 'Maestro de Monedas y Divisas',
                summary: 'Administración de divisas (COP, USD, EUR) y sus tasas de cambio operativas.',
                concept: 'Gestión multimoneda para realizar cotizaciones y facturas en moneda extranjera.',
                fields: [
                    { name: 'Código Moneda', type: 'Texto (3 letras)', description: 'COP, USD, EUR.' },
                    { name: 'Tasa de Cambio', type: 'Decimal', description: 'Valor de conversión respecto a la moneda base.' }
                ],
                steps: [
                    { number: 1, title: 'Actualizar Tasa', description: 'En la pestaña "Monedas", ajuste la tasa de cambio vigente.' }
                ]
            },
            {
                code: 'MAE-13',
                masterCode: 'CreditCard',
                name: 'Maestro de Tarjetas de Crédito',
                summary: 'Registro y validación de franquicias de tarjetas de crédito (Visa, Mastercard, Amex, Diners, etc.) asociadas a los pagos.',
                concept: 'Administra las franquicias de tarjetas de crédito y sus códigos de 2 letras (ej. VI, MC, AX, DC). Al ingresar referencias de pago con tarjeta en facturación (ej. VI0000000000007023), el sistema extrae automáticamente las 2 primeras letras como código de franquicia, las valida contra este maestro y asigna el ID de la tarjeta correspondiente.',
                fields: [
                    { name: 'Código Franquicia', type: 'Texto (2 letras)', description: 'VI (Visa), MC (Mastercard), AX (Amex), DC (Diners).' },
                    { name: 'Nombre Franquicia', type: 'Texto', description: 'Visa, Mastercard, Diners, Amex.' }
                ],
                steps: [
                    { number: 1, title: 'Administrar Franquicia', description: 'En la pestaña "Tarjetas de Crédito", administre las franquicias y sus códigos asignados.' },
                    { number: 2, title: 'Validación en Pagos', description: 'En el modal de formas de pago de facturación, la referencia tipo "VI0000000000007023" separará automáticamente el código "VI" para seleccionar la tarjeta de crédito y el número "0000000000007023".' }
                ]
            },
            {
                code: 'MAE-14',
                masterCode: 'Payment',
                name: 'Maestro de Formas de Pago',
                summary: 'Configuración de modalidades de pago (Efectivo, Transferencia, Crédito).',
                concept: 'Especifica las alternativas de recaudación disponibles en facturación.',
                fields: [
                    { name: 'Nombre Medio', type: 'Texto', description: 'Efectivo, Consignación, Crédito 30 días.' }
                ],
                steps: [
                    { number: 1, title: 'Configurar Medio', description: 'En la pestaña "Formas de Pago", administre las opciones activas.' }
                ]
            },
            {
                code: 'MAE-16',
                masterCode: 'InterfaceExtractParam',
                name: 'Parámetros de Extracción de Interfaces (PNR/GDS)',
                summary: 'Configuración dinámica de prefijos y constantes en archivos de interfaz (Amadeus, Sabre, Galileo) para extraer Cliente, Vendedor, Tiqueteador, Sucursal, Implante y Variables Adicionales del Sistema (ej. centro de costo, Fecha de Facturación).',
                concept: 'Permite definir prefijos constantes como RM*NC-, RM*VE-, RM*TK-, RM*SUC-, RM*IMP-, RM*CC- o seleccionar cualquier Variable Adicional (MasterVariable) para indicarle al sistema la ubicación exacta de los datos de facturación en el archivo PNR sin modificar código fuente. Al importar la reserva, las casillas de variables adicionales se marcarán y diligenciarán automáticamente.',
                fields: [
                    { name: 'Interfaz GDS', type: 'Selección', description: 'Sistema emisor del archivo (Amadeus, Sabre, Galileo, etc.).' },
                    { name: 'Campo o Variable Adicional', type: 'Selección / Botones', description: 'Campos fijos (Client, Seller, TicketPrinter, Branch, Implant) o cualquier Variable Adicional (ej. centro de costo).' },
                    { name: 'Prefijo en Archivo', type: 'Texto', description: 'Constante previa al valor deseado (ej. RM*NC- para Cliente, RM*CC- para Centro de Costo).' },
                    { name: 'Delimitador', type: 'Texto', description: 'Caracter separador de fin de campo (ej. - o /).' }
                ],
                steps: [
                    { number: 1, title: 'Acceder a Extracción Interfaces', description: 'En /dashboard/settings, haga clic en la pestaña "Extracción Interfaces".' },
                    { number: 2, title: 'Configurar Regla de Extracción', description: 'Seleccione la interfaz (ej. Amadeus), escoja un campo fijo o una Variable Adicional (ej. centro de costo) y defina su prefijo en el archivo (ej. RM*CC-).' },
                    { number: 3, title: 'Guardar y Procesar', description: 'Guarde la regla. Al importar reservas GDS en Facturación, las Variables Adicionales se autocompletarán de inmediato.' }
                ]
            },
            {
                code: 'MAE-15',
                masterCode: 'Countries',
                name: 'Maestro de Países',
                summary: 'Catálogo de países para la clasificación de destinos y clientes.',
                concept: 'Base geográfica de países para itinerarios y reportes de producción por destino.',
                fields: [
                    { name: 'Código País', type: 'Texto', description: 'Código ISO del país (ej. CO, US, ES).' },
                    { name: 'Nombre País', type: 'Texto', description: 'Nombre oficial del país.' }
                ],
                steps: [
                    { number: 1, title: 'Gestionar País', description: 'En la pestaña "Países", consulte o edite la lista geográfica.' }
                ]
            },
            {
                code: 'MAE-16',
                masterCode: 'Cities',
                name: 'Maestro de Ciudades',
                summary: 'Catálogo de ciudades vinculadas a sus respectivos países.',
                concept: 'Clasificación de destinos de viaje e infraestructuras turísticas.',
                fields: [
                    { name: 'Nombre Ciudad', type: 'Texto', description: 'Nombre de la ciudad de origen o destino.' }
                ],
                steps: [
                    { number: 1, title: 'Gestionar Ciudad', description: 'En la pestaña "Ciudades", adicione o edite ciudades del catálogo.' }
                ]
            },
            {
                code: 'MAE-17',
                masterCode: 'Airports',
                name: 'Maestro de Aeropuertos',
                summary: 'Catálogo de aeropuertos del mundo con sus códigos IATA.',
                concept: 'Utilizado en los itinerarios de vuelos de las cotizaciones (ej. BOG, MIA, MAD).',
                fields: [
                    { name: 'Código IATA', type: 'Texto (3 letras)', description: 'Código oficial del aeropuerto (ej. BOG).' },
                    { name: 'Nombre Aeropuerto', type: 'Texto', description: 'Nombre de la terminal aérea.' }
                ],
                steps: [
                    { number: 1, title: 'Gestionar Aeropuerto', description: 'En la pestaña "Aeropuertos", registre códigos IATA adicionales.' }
                ]
            },
            {
                code: 'MAE-18',
                masterCode: 'TicketType',
                name: 'Maestro de Tipos de Tiquete',
                summary: 'Clasificación de boletos aéreos (Nacional, Internacional, EMD, Fee).',
                concept: 'Define el tipo de emisión aérea para efectos de liquidación contable.',
                fields: [
                    { name: 'Nombre Tipo', type: 'Texto', description: 'Tiquete Nacional, Tiquete Internacional, EMD.' }
                ],
                steps: [
                    { number: 1, title: 'Configurar Tipo', description: 'En la pestaña "Tipos Tiquete", administre las categorías de boletos.' }
                ]
            },
            {
                code: 'MAE-19',
                masterCode: 'QuotationState',
                name: 'Maestro de Estados de Cotización',
                summary: 'Definición del flujo de estados (Nuevo, Aprobado, Facturado, Cancelado).',
                concept: 'Determina las etapas del ciclo de vida comercial de una propuesta.',
                fields: [
                    { name: 'Nombre Estado', type: 'Texto', description: 'Denominación del estado comercial.' }
                ],
                steps: [
                    { number: 1, title: 'Gestionar Estado', description: 'En la pestaña "Estados Cotiz.", consulte el flujo de aprobaciones.' }
                ]
            },
            {
                code: 'MAE-20',
                masterCode: 'QuotationFormat',
                name: 'Maestro de Formatos de Cotización',
                summary: 'Plantillas de diseño para la exportación de propuestas en PDF o Excel.',
                concept: 'Permite personalizar la presentación estética y logos de los presupuestos.',
                fields: [
                    { name: 'Nombre Plantilla', type: 'Texto', description: 'Formato Corporativo, Formato Ejecutivo.' }
                ],
                steps: [
                    { number: 1, title: 'Diseñar Formato', description: 'En la pestaña "Formatos Cotiz.", cargue plantillas HTML o Excel.' }
                ]
            },
            {
                code: 'MAE-21',
                masterCode: 'Equivalences',
                name: 'Maestro de Equivalencias de Interfaces',
                summary: 'Homologación de códigos entre sistemas GDS y contabilidad Zeus ERP.',
                concept: 'Permite traducir códigos de aerolíneas u hoteles de Amadeus/Sabre a los códigos del ERP.',
                fields: [
                    { name: 'Código Origen', type: 'Texto', description: 'Código en el sistema GDS.' },
                    { name: 'Código ERP', type: 'Texto', description: 'Código equivalente en Zeus ERP.' }
                ],
                steps: [
                    { number: 1, title: 'Mapear Equivalencia', description: 'En la pestaña "Equivalencias", asocie los códigos entre sistemas.' }
                ]
            },
            {
                code: 'MAE-22',
                masterCode: 'MasterVariable',
                name: 'Maestro de Variables Adicionales',
                summary: 'Campos personalizados obligatorios para clientes o productos específicos.',
                concept: 'Permite solicitar datos adicionales (Centro de Costos, Pasaje Frecuente) en la cotización.',
                fields: [
                    { name: 'Nombre Variable', type: 'Texto', description: 'Nombre del campo adicional requerido.' }
                ],
                steps: [
                    { number: 1, title: 'Crear Variable', description: 'En la pestaña "Variables Adic.", configure los campos personalizados.' }
                ]
            },
            {
                code: 'MAE-23',
                masterCode: 'SystemParameter',
                name: 'Maestro de Parámetros del Sistema',
                summary: 'Variables de configuración global organizadas en sub-pestañas categóricas (SQL Server, Tarifa Administrativa, Licencia y General).',
                concept: 'Administra configuraciones globales agrupadas dinámicamente en sub-pestañas: SQL Server (conexión y exportación automática Zeus ERP), Tarifa Administrativa (rangos y cobros), Licencia (NIT, Razón Social y claves cifradas) y General (tasa IATA, país, etc.).',
                fields: [
                    { name: 'Categorías (Sub-pestañas)', type: 'Navegación', description: 'Permite filtrar parámetros entre SQL Server, Tarifa Administrativa, Licencia, General y Todos.' },
                    { name: 'Código Parámetro', type: 'Texto', description: 'Identificador técnico único del parámetro.' },
                    { name: 'Nombre descriptivo', type: 'Texto', description: 'Nombre funcional del parámetro.' },
                    { name: 'Valor Parámetro', type: 'Texto / JSON', description: 'Valor activo o configuración en formato texto o JSON.' }
                ],
                steps: [
                    { number: 1, title: 'Filtrar por Categoría', description: 'Seleccione la sub-pestaña deseada ("SQL Server", "Tarifa Administrativa", "Licencia" o "General") para ubicar rápidamente la variable a modificar.' },
                    { number: 2, title: 'Ajustar Parámetro', description: 'Haga clic en el botón de edición para actualizar el valor global correspondiente.' }
                ]
            },
            {
                code: 'MAE-24',
                masterCode: 'SystemLog',
                name: 'Maestro de Logs del Sistema y Auditoría',
                summary: 'Historial de auditoría de eventos, inicios de sesión y cambios de datos.',
                concept: 'Registra los eventos realizados por los usuarios para efectos de seguridad e inspección.',
                fields: [
                    { name: 'Usuario / Acción', type: 'Texto', description: 'Colaborador que ejecutó la acción y descripción del evento.' }
                ],
                steps: [
                    { number: 1, title: 'Auditar Eventos', description: 'En la pestaña "Logs del Sistema", revise la bitácora de actividad.' }
                ]
            },
            {
                code: 'MAE-25',
                masterCode: 'SiteModules',
                name: 'Administración de Módulos del Sitio',
                summary: 'Interruptores para activar o desactivar menús y pestañas maestras.',
                concept: 'Permite habilitar o deshabilitar opciones del sistema en tiempo real. Las opciones desactivadas no aparecerán en la navegación ni en este manual.',
                fields: [
                    { name: 'Interruptor Módulo', type: 'Switch', description: 'Activa o desactiva la visibilidad del módulo o maestro.' }
                ],
                steps: [
                    { number: 1, title: 'Conmutar Módulo', description: 'En la pestaña "Módulos del Sitio", active o apague los módulos requeridos.' }
                ]
            },
            {
                code: 'MAE-26',
                masterCode: 'Role',
                name: 'Maestro de Roles y Control de Acceso (RBAC)',
                summary: 'Administración de roles personalizados, matriz de permisos por módulos, las 25 pestañas maestras y botones de acción.',
                concept: 'Permite definir perfiles de acceso granulares para los colaboradores de la agencia. Permite habilitar o deshabilitar módulos completos, pestañas maestras específicas y acciones como "Facturar / Enviar a Zeus", "Crear Cotización", "Exportar Excel" o "Ejecutar SPs". Detección e inclusión automática de nuevas funcionalidades creadas.',
                fields: [
                    { name: 'Nombre del Rol', type: 'Texto', description: 'Nombre identificador del perfil de acceso (ej. Asesor Comercial, Contador, Auxiliar).' },
                    { name: 'Descripción Funcional', type: 'Texto', description: 'Breve explicación del alcance del perfil.' },
                    { name: 'Pestaña Módulos Principales', type: 'Switches', description: 'Activa o desactiva pantallas principales (Cotizaciones, Facturación, Reportes, SPs, Ajustes).' },
                    { name: 'Pestaña Pestañas Maestras', type: 'Switches', description: 'Activa o desactiva individualmente la visibilidad de cualquiera de las 25 pestañas maestras de Ajustes.' },
                    { name: 'Pestaña Botones y Acciones', type: 'Switches Granulares', description: 'Autoriza o restringe la ejecución de acciones específicas como Facturar a Zeus, Editar o Duplicar.' }
                ],
                businessRules: [
                    'Los cambios aplicados a un rol surten efecto de forma inmediata para todos los usuarios vinculados al mismo.',
                    'Un rol no puede ser eliminado si posee usuarios asignados.'
                ],
                steps: [
                    { number: 1, title: 'Abrir pestaña Roles y Permisos', description: 'En Ajustes (/dashboard/settings), seleccione la pestaña "Roles y Permisos".' },
                    { number: 2, title: 'Crear o Editar Rol', description: 'Haga clic en "+ Crear Nuevo Rol", ingrese el nombre y configure la matriz de permisos deseada.' },
                    { number: 3, title: 'Asignar Rol a Usuario', description: 'En la pestaña "Usuarios", edite el colaborador deseado y asigne su nuevo rol en la lista desplegable.' }
                ]
            },
            {
                code: 'MAE-27',
                masterCode: 'DocumentResolution',
                name: 'Maestro de Resoluciones de Documentos',
                summary: 'Configuración de números de resolución DIAN/ERP por Sucursal e Implante con regla de resolución activa única.',
                concept: 'Permite registrar la autorización de numeración de la DIAN o del sistema ERP Zeus indicando la sucursal, implante opcional, número de resolución, prefijo, rangos autorizados (inicial/final) y fechas de vencimiento. Garantiza que solo pueda existir una resolución activa para la misma combinación de sucursal e implante.',
                fields: [
                    { name: 'Sucursal', type: 'Selección Obligatoria', description: 'Sucursal asignada a la resolución.' },
                    { name: 'Implante', type: 'Selección Opcional', description: 'Implante específico o global para todas las unidades.' },
                    { name: 'Número de Resolución', type: 'Texto', description: 'Número oficial otorgado por la DIAN o ERP.' },
                    { name: 'Rango de Numeración', type: 'Numérico', description: 'Numeración inicial y final autorizada.' },
                    { name: 'Prefijo y Vencimiento', type: 'Texto / Fechas', description: 'Prefijo oficial del documento y fecha límite de vigencia.' },
                    { name: 'Resolución Activa', type: 'Switch', description: 'Al activarla, desactiva automáticamente cualquier otra resolución previamente activa para la misma sucursal/implante.' }
                ],
                businessRules: [
                    'Solo puede haber una resolución marcada como activa por cada combinación de sucursal e implante.',
                    'Al registrar una nueva resolución activa, la base de datos desactiva de forma automática la anterior.'
                ],
                steps: [
                    { number: 1, title: 'Acceder a Resoluciones', description: 'En el menú Ajustes del sistema, haga clic en la pestaña "Resoluciones".' },
                    { number: 2, title: 'Registrar Resolución', description: 'Haga clic en "+ Nuevo", seleccione la sucursal, digite el número de resolución, rango y fecha de vencimiento.' }
                ]
            },
            {
                code: 'MAE-28',
                masterCode: 'TransactionConsecutive',
                name: 'Maestro de Consecutivos de Transacciones',
                summary: 'Control atómico del punto de inicio y secuencia de transacciones (Facturas, Notas Crédito, Cotizaciones).',
                concept: 'Permite definir en qué número inician las secuencias de transacciones (Factura, Nota Crédito, Cotización, etc.), asignando un prefijo predeterminado y manteniendo un incremento atómico y veloz libre de colisiones.',
                fields: [
                    { name: 'Tipo de Transacción', type: 'Texto (Código)', description: 'Identificador del tipo de documento (ej. INVOICE, CREDIT_NOTE, QUOTATION).' },
                    { name: 'Descripción', type: 'Texto', description: 'Nombre claro de la operación (ej. Facturación Electrónica de Venta).' },
                    { name: 'Prefijo y Número Inicial', type: 'Texto / Numérico', description: 'Prefijo predeterminado y número de partida de la secuencia.' },
                    { name: 'Consecutivo Actual', type: 'Numérico', description: 'Número de la siguiente transacción que será emitida por el sistema.' }
                ],
                businessRules: [
                    'La asignación de consecutivos utiliza la función fnObtenerSiguienteConsecutivo con bloqueo a nivel de fila para garantizar rendimiento máximo sin duplicados.'
                ],
                steps: [
                    { number: 1, title: 'Acceder a Consecutivos', description: 'En el menú Ajustes del sistema, seleccione la pestaña "Consecutivos".' },
                    { number: 2, title: 'Configurar Tipo de Transacción', description: 'Haga clic en "+ Nuevo", ingrese el código de transacción, descripción, prefijo y consecutivo de inicio.' }
                ]
            }
        ]
    }
];
