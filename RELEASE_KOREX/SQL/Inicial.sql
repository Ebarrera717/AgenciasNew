-- SCRIPT DE DATOS INICIALES - AGENCIAS NEW
-- RUTA: c:\Proyectos\AgenciasNew\SQL\Data\Inicial.sql
-- IDEMPOTENTE: Puede ejecutarse múltiples veces sin errores

-- 1. Rol Admin
INSERT INTO public."Role" (name)
VALUES ('Admin')
ON CONFLICT (name) DO NOTHING;

-- 2. Sucursal
INSERT INTO public."Branch" (code, name)
VALUES ('BOG', 'BOG')
ON CONFLICT (code) DO NOTHING;

-- 3. Clientes, Vendedores, Proveedores y Tiqueteadores
INSERT INTO public."Client" (document, name)
VALUES ('73009263', 'Rubiel')
ON CONFLICT (document) DO NOTHING;

INSERT INTO public."Seller" (code, name, email)
VALUES ('73009263', 'Rubiel', 'rubiel1985@msn.com')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Provider" (code, name)
VALUES ('73009263', 'Rubiel')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public."TicketPrinter" (code, name, email)
VALUES ('73009263', 'Rubiel', 'rubiel1985@msn.com')
ON CONFLICT (code) DO NOTHING;

-- 4. Usuario Administrativo (Contraseña: 111985)
INSERT INTO public."User" (email, name, "passwordHash", "roleId", "branchId", "implantId", "ticketPrinterId")
VALUES (
    'rubiel1985@msn.com',
    'Rubiel',
    '$2b$10$IUxxw/yzr2bpC4wRMUcBYOsrIJrG4e0j.FI/p2baH2CGNfKNLbn.S',
    (SELECT id FROM public."Role"          WHERE name = 'Admin'),
    (SELECT id FROM public."Branch"        WHERE code = 'BOG'),
    null,
    (SELECT id FROM public."TicketPrinter" WHERE code = '73009263')
)
ON CONFLICT (email) DO NOTHING;

-- 5. Productos

INSERT INTO public."Product" (code, type, description, "basePrice", cost)
VALUES ('HTL','ALOJAMIENTO', 'Hotel', 0, 0)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Product" (code, type, description, "basePrice", cost)
VALUES ('RTA','ALQUILER', 'RestaAuto', 0, 0)
ON CONFLICT (code) DO NOTHING;


-- 6. Cargos e Impuestos
INSERT INTO public."ChargeAndTax" (code, name, type, "valueType", value, "isEditable")
VALUES
    ('TAR',   'TAR',   'CHARGE', 'FIXED',      0,  true),
    ('IVA',   'IVA',   'TAX',    'PERCENTAGE', 19,  true),
    ('OTROS', 'OTROS', 'CHARGE', 'FIXED',       0,  true)
ON CONFLICT (code) DO NOTHING;

-- 7. Parámetros de conectividad SQL Server
INSERT INTO public."SystemParameter" (code, name, value)
VALUES
    ('ServidorSQLServer',                'Host de SQL Server',                           'Rubiel/RUBIEL'),
    ('UsuarioSQLServer',                 'Usuario SQL Server',                           'sa'),
    ('ClaveSQLServer',                   'Contraseña SQL Server',                        '111985*'),
    ('BaseSQLServer',                    'Base de Datos SQL Server',                     'Agencias'),
    ('PuertoSQLServer',                  'Puerto SQL Server',                            ''),
    ('EnviarCotizacionesAutoSQLserver',  'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', '1'),
	('EnviarFacturacionAutoSQLserver',   'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', '1'),
	('Pais',                    		 'Pais',                     					 'Colombia'),
	('MOSTRAR_TOTALIZACION_COTIZACION',  'Mostrar totalización financiera en cotización', 'true')
ON CONFLICT (code) DO UPDATE
    SET name  = EXCLUDED.name,
        value = EXCLUDED.value;

-- 8. Monedas iniciales
INSERT INTO public."Currency" (code, name, "exchangeRate")
VALUES
    ('COP', 'Peso Colombiano',      1.00),
    ('USD', 'Dólar Estadounidense', 4200.00),
    ('EUR', 'Euro',                 4500.00)
ON CONFLICT (code) DO NOTHING;


-- 9. GDS iniciales
INSERT INTO public."GDS" (name)
VALUES
	('SABRE'),
	('AMADEUS'),
	('AEROGAL'),
	('GALILEO'),
	('ZEUS ON LINE (ZOL)'),
	('WEB SERVICE'),
	('KIU'),
	('IdeasFractal'),
	('SparkCopa')
ON CONFLICT (name) DO NOTHING;

-- 10. Configuración de Facturación Automática por Sucursal y GDS
INSERT INTO public."BranchGDSInvoiceAuto" ("branchId", "gdsId", "EnvoiceAuto")
SELECT b.id, g.id, false
FROM public."Branch" b, public."GDS" g
ON CONFLICT DO NOTHING;


-- 10. Interfaces iniciales


INSERT INTO public."Interfaces" (code, name, "inactivo", "bl_genera_archivoplano", "ds_storedprocedure_archivoplano", "bl_job", "ds_namejob" ,"bl_facturador", "id_gds")
VALUES
    ('SABRE', 'SABRE', true, false, 'spInterfaceSabre', false, '' ,false,  1),
    ('AMADEUS', 'AMADEUS', true, false, 'spInterfaceAmadeus', false, '', false, 2),
    ('IdeasFractal', 'IdeasFractal', false, false, 'spInterfaceIdeasFractal', false, '', false,  8)
ON CONFLICT (code) DO NOTHING;


-- 10.5 Módulos de Menú Principal
CREATE UNIQUE INDEX IF NOT EXISTS "Menu_code_key" ON public."Menu" ("code");
INSERT INTO public."Menu" (code, name, parent, action, activo)
VALUES 
    ('DASHBOARD', 'Dashboard', NULL, '/dashboard', true),
    ('PRECOTIZACIONES', 'Pre-Cotizaciones', NULL, '/dashboard/prequotations', true),
    ('COTIZACIONES', 'Cotizaciones', NULL, '/dashboard/quotations/history', true),
    ('FACTURACION', 'Facturación', NULL, '/dashboard/invoices/history', true),
    ('MAESTROS', 'Maestros', NULL, '/dashboard/settings', true),
    ('REPORTES', 'Reportes', NULL, '/dashboard/reports', true),
    ('EJECUCIONES', 'Ejecuciones', NULL, '/dashboard/executions', true),
    ('MANUAL', 'Manual Operativo', NULL, '/dashboard/manual', true)
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    action = EXCLUDED.action;

-- 11. Maestros
INSERT INTO public."Master" (code, name, "inactivo")
VALUES
    ('SystemParameter', 'parametros', false),
    ('Client', 'clientes', false),
    ('Provider', 'proveedor', false),
	('Seller', 'vendedor', false),
	('TicketPrinter', 'tiqueteador', false),
	('Prestadora', 'prestadora', false),
	('Branch', 'sucursal', false),
	('Implant', 'implante', false),
	('Product', 'producto', false),
	('ChargeAndTax', 'cargos e impuesto', false),
	('Currency', 'moneda', false)
ON CONFLICT (code) DO NOTHING;

-- 12. Paises Iniciales
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId")
VALUES
    ('CO', 'Colombia', '169', 'LA', '57', (SELECT id FROM public."Currency" WHERE code = 'COP')),
    ('US', 'Estados Unidos', '249', 'NA', '1', (SELECT id FROM public."Currency" WHERE code = 'USD')),
    ('ES', 'España', '245', 'EUR', '34', (SELECT id FROM public."Currency" WHERE code = 'EUR'))
ON CONFLICT (code) DO NOTHING;

-- 13. Ciudades Iniciales
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata)
VALUES
    ('BOG', 'Bogotá', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'CUN', 'BOG'),
    ('MDE', 'Medellín', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'ANT', 'MDE'),
    ('MIA', 'Miami', (SELECT id FROM public."Countries" WHERE code = 'US'), 'FL', 'MIA'),
    ('MAD', 'Madrid', (SELECT id FROM public."Countries" WHERE code = 'ES'), 'MAD', 'MAD')
ON CONFLICT (code) DO NOTHING;

-- 14. Aeropuertos Iniciales
INSERT INTO public."Airports" (code, name, "citiesId")
VALUES
    ('BOG', 'Aeropuerto Internacional El Dorado', (SELECT id FROM public."Cities" WHERE code = 'BOG')),
    ('MDE', 'Aeropuerto Internacional Jose Maria Cordova', (SELECT id FROM public."Cities" WHERE code = 'MDE')),
    ('MIA', 'Miami International Airport', (SELECT id FROM public."Cities" WHERE code = 'MIA')),
    ('MAD', 'Adolfo Suarez Madrid-Barajas', (SELECT id FROM public."Cities" WHERE code = 'MAD'))
ON CONFLICT (code) DO NOTHING;

-- DATOS EXTRAIDOS DE SQL SERVER

-- 15. Monedas Adicionales (desde Paises)
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('DZD', 'Dinar algerino', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('DKK', 'Corona danesa', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('USD', 'Dolares Americanos', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('XOF', 'franco CFA', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SAR', 'Riyal saudi', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NGN', 'Naira nigeriana', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('AUD', 'Dolar Australiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GBP', 'Libra Estelina', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MXN', 'Peso Mexicano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GHS', 'Cedi ghanes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('EUR', 'Euro', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('TRY', 'lira turca', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ETB', 'Birr etiope', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('YER', 'Rial yemeni', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('COP', 'Pesos Colombianos', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ARS', 'Peso argentino', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('RUB', 'Rublo Ruso', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NOK', 'Corona noruega', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ISK', 'Krona islandesa', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MAD', 'Dirham marroqui', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SEK', 'Corona Sueca', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('INR', 'India Rupees', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('IDR', 'Rupiah indonesia', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NZD', 'Dolar neozelandes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BRL', 'Real Brasilero', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KZT', 'Tenge kazajo', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ZAR', 'Rand Sudafricano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SYP', 'Libra siria', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('EGP', 'Libra egipcia', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('JOD', 'Dinar', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CLP', 'Peso chileno', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('XCD', 'Dolar del Caribe Oriental', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MYR', 'Ringgit malayo', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MZN', 'Metical mozambique¤o', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('WST', 'Tala samoano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PEN', 'Nuevo Sol', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('JPY', 'Yen Japones', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PYG', 'Guaran¡ paraguayo', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BSD', 'Dolar bahameno', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('AED', 'Dirham de los Emiratos arabes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('XPF', 'Franco CFP', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CUP', 'Cuba Pesos', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PHP', 'Filipinas Pesos', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BHD', 'Dinar bahreini', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('AZN', 'Franco CFP', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BWP', 'Pula de Botsuana', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('RON', 'Leu rumano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BMD', 'Dolar de Bermuda', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LBP', 'Libra libanesa', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('FJD', 'Dolar fijiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('XAF', 'Franco CFA', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BBD', 'Dolar de Barbados', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('IQD', 'Dinar iraqui', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CNY', 'Yuan Renminbi Chino', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GMD', 'Dalasi gambiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BIF', 'Franco burunds', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('THB', 'Baht Thailandes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('VEF', 'Bolivar', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MWK', 'Kwacha malauiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ANG', 'Florin antillano neerlandes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CHF', 'FRANCO FRANCES', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CZK', 'Koruna', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('DOP', 'Peso dominicano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('HUF', 'Forint hungaro', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ZWR', 'dolar zimbabuense', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CVE', 'Escudo caboverdiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BZD', 'Dolar de Belice', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BOB', 'Boliviano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('HTG', 'Gourde haitiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BDT', 'Taka de Bangladesh', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KRW', 'Won Surcoreano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GNF', 'Franco guineano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LKR', 'Rupia de Sri Lanka', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CAD', 'Dolar Canadiense', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KYD', 'Dolar caimano de Islas Caiman', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('UYU', 'Peso Uruguayo', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('TZS', 'Chelin tanzano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('HRK', 'Kuna croata', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('TND', 'Dinar tunecino', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('VND', 'dong vietnamita', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('QAR', 'Rial qatari', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('UGX', 'chelín ugandes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NAD', 'Dolar namibio', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ILS', 'Nuevo shequel israeli', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SLL', 'Leone de Sierra Leona', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GTQ', 'Quetzal guatemalteco', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PLN', 'zloty polaco', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PGK', 'Kina de Papua Nueva Guinea', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KMF', 'Franco comoriano de Comoras', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('PKR', 'Rupia pakistani', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SBD', 'Dolar de las Islas Salomon', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('HKD', 'Dolar Honkones', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('UAH', 'grivna ucraniana', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('DJF', 'Franco yibutiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('RWF', 'Franco ruandes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('JMD', 'Dolar Jamaicano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SDG', 'Dinar sudanes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NPR', 'Rupia nepalesa', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LTL', 'Litas lituano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KWD', 'Dinar kuwaiti', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('AOA', 'Kwanza angoleno', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('CRC', 'Colon costarricense', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ZMK', 'Kwacha zambiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KES', 'Chelin keniata', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('OMR', 'Rial omani', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('NIO', 'Cordoba nicaraguense', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MVR', 'Rufiyaa maldiva', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LRD', 'Dolar liberiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MUR', 'Rupia mauricia', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LSL', 'Loti lesotense', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SZL', 'Lilangeni suazi', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MRO', 'Ouguiya mauritana', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SRD', 'Dolar surinames', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('KHR', 'Riel camboyano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('TTD', 'dolar de Trinidad y Tobago', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MMK', 'Kyat birmano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LVL', 'Lat leton', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('HNL', 'Lempira hondureno', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SVC', 'Colón salvadoreno', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SCR', 'Rupia de Seychelles', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('SGD', 'Dolar Singapur', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BAM', 'Marco convertible de BosniaHe', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('BGN', 'Lev belgaro', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('UZS', 'Som uzbeko', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('GEL', 'Lari georgiano', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('TOP', 'Dinar kuwaiti', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('IRR', 'Rial irani', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('ALL', 'Lek albanes', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('MGA', 'Ariary malgache', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LYD', 'Dinar libio', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('VUV', 'Vatu de Vanuatu', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('LAK', 'Kip lao', 1.0) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Currency" (code, name, "exchangeRate") VALUES ('STD', 'Dobra de Santo Tomas y Principe', 1.0) ON CONFLICT (code) DO NOTHING;


-- 16. Paises (Completos)
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DZ', 'Algeria', '059', 'AFR', '213', (SELECT id FROM public."Currency" WHERE code = 'DZD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DK', 'Denmark', '232', 'EUR', '45', (SELECT id FROM public."Currency" WHERE code = 'DKK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('US', 'United States', '249', 'NA', '1', (SELECT id FROM public."Currency" WHERE code = 'USD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CI', 'Cote d Ivoire', '193', 'AFR', '225', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SA', 'Saudi Arabia', '053', 'MEA', '966', (SELECT id FROM public."Currency" WHERE code = 'SAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NG', 'Nigeria', '528', 'AFR', '234', (SELECT id FROM public."Currency" WHERE code = 'NGN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AU', 'Australia', '069', 'PAC', '61', (SELECT id FROM public."Currency" WHERE code = 'AUD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GB', 'United Kingdom', '628', 'EUR', '44', (SELECT id FROM public."Currency" WHERE code = 'GBP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MX', 'Mexico', '493', 'LA', '52', (SELECT id FROM public."Currency" WHERE code = 'MXN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GH', 'Ghana', '289', 'AFR', '233', (SELECT id FROM public."Currency" WHERE code = 'GHS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ES', 'Spain', '245', 'EUR', '34', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TR', 'Turkey', '827', 'ASI', '90', (SELECT id FROM public."Currency" WHERE code = 'TRY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ET', 'Ethiopia', '253', 'AFR', '251', (SELECT id FROM public."Currency" WHERE code = 'ETB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('YE', 'Yemen', '880', 'MEA', '967', (SELECT id FROM public."Currency" WHERE code = 'YER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CO', 'Colombia', '169', 'LA', '57', (SELECT id FROM public."Currency" WHERE code = 'COP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AR', 'Argentina', '063', 'LA', '54', (SELECT id FROM public."Currency" WHERE code = 'ARS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('RU', 'Russian Federation', '670', 'EUR', '7', (SELECT id FROM public."Currency" WHERE code = 'RUB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NO', 'Norway', '538', 'EUR', '47', (SELECT id FROM public."Currency" WHERE code = 'NOK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IS', 'Iceland', '379', 'EUR', '354', (SELECT id FROM public."Currency" WHERE code = 'ISK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MA', 'Morocco', '474', 'AFR', '212', (SELECT id FROM public."Currency" WHERE code = 'MAD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DE', 'Germany', '023', 'EUR', '49', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('FR', 'France', '275', 'EUR', '33', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SE', 'Sweden', '764', 'EUR', '46', (SELECT id FROM public."Currency" WHERE code = 'SEK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IN', 'India', '361', 'ASI', '91', (SELECT id FROM public."Currency" WHERE code = 'INR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ID', 'Indonesia', '365', 'ASI', '62', (SELECT id FROM public."Currency" WHERE code = 'IDR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IT', 'Italy', '386', 'EUR', '39', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CK', 'Cook Islands', '183', 'PAC', '682', (SELECT id FROM public."Currency" WHERE code = 'NZD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BR', 'Brazil', '105', 'LA', '55', (SELECT id FROM public."Currency" WHERE code = 'BRL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NZ', 'New Zealand', '548', 'PAC', '64', (SELECT id FROM public."Currency" WHERE code = 'NZD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KZ', 'Kazakstan', '406', 'ASI', '7', (SELECT id FROM public."Currency" WHERE code = 'KZT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ZA', 'South Africa', '756', 'AFR', '27', (SELECT id FROM public."Currency" WHERE code = 'ZAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SY', 'Syrian Arab Republic', '744', 'MEA', '963', (SELECT id FROM public."Currency" WHERE code = 'SYP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AD', 'Andorra', '037', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('EG', 'Egypt', '240', 'MEA', '20', (SELECT id FROM public."Currency" WHERE code = 'EGP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('JO', 'Jordan', '403', 'MEA', '962', (SELECT id FROM public."Currency" WHERE code = 'JOD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NL', 'Netherlands', '573', 'EUR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CL', 'Chile', '211', 'LA', '56', (SELECT id FROM public."Currency" WHERE code = 'CLP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BE', 'Belgium', '087', 'EUR', '32', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AG', 'Antigua and Barbuda', '043', 'CAR', '1268', (SELECT id FROM public."Currency" WHERE code = 'XCD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MY', 'Malaysia', '455', 'ASI', '60', (SELECT id FROM public."Currency" WHERE code = 'MYR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MZ', 'Mozambique', '505', 'AFR', '258', (SELECT id FROM public."Currency" WHERE code = 'MZN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('WS', 'Samoa', '687', 'PAC', '685', (SELECT id FROM public."Currency" WHERE code = 'WST')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PE', 'Peru', '589', 'LA', '51', (SELECT id FROM public."Currency" WHERE code = 'PEN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('JP', 'Japan', '399', 'ASI', '81', (SELECT id FROM public."Currency" WHERE code = 'JPY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ER', 'Eritrea', '243', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PY', 'Paraguay', '586', 'LA', '595', (SELECT id FROM public."Currency" WHERE code = 'PYG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BS', 'Bahamas', '077', 'CAR', '1242', (SELECT id FROM public."Currency" WHERE code = 'BSD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GR', 'Greece', '301', 'EUR', '30', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AW', 'Aruba', '027', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AE', 'United Arab Emirates', '244', 'MEA', '971', (SELECT id FROM public."Currency" WHERE code = 'AED')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PF', 'French Polynesia', '599', 'PAC', '689', (SELECT id FROM public."Currency" WHERE code = 'XPF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CU', 'Cuba', '199', 'CAR', '53', (SELECT id FROM public."Currency" WHERE code = 'CUP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AI', 'Anguilla', '041', 'CAR', '1264', (SELECT id FROM public."Currency" WHERE code = 'XCD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PH', 'Philippines', '267', 'ASI', '63', (SELECT id FROM public."Currency" WHERE code = 'PHP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BH', 'Bahrain', '080', 'ASI', '973', (SELECT id FROM public."Currency" WHERE code = 'BHD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AZ', 'Azerbaijan', '074', 'ASI', '994', (SELECT id FROM public."Currency" WHERE code = 'AZN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BW', 'Botswana', '101', 'AFR', '267', (SELECT id FROM public."Currency" WHERE code = 'BWP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('RO', 'Romania', '670', 'EUR', '40', (SELECT id FROM public."Currency" WHERE code = 'RON')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BM', 'Bermuda', '090', 'CAR', '1441', (SELECT id FROM public."Currency" WHERE code = 'BMD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('YU', 'Yugoslavia', '885', 'EUR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LB', 'Lebanon', '431', 'MEA', '961', (SELECT id FROM public."Currency" WHERE code = 'LBP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('FJ', 'Fiji', '870', 'PAC', '679', (SELECT id FROM public."Currency" WHERE code = 'FJD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CF', 'Central African Republic', '640', 'AFR', '236', (SELECT id FROM public."Currency" WHERE code = 'XAF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BB', 'Barbados', '083', 'CAR', '1246', (SELECT id FROM public."Currency" WHERE code = 'BBD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IQ', 'Iraq', '369', 'MEA', '964', (SELECT id FROM public."Currency" WHERE code = 'IQD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CN', 'China', '215', 'ASI', '86', (SELECT id FROM public."Currency" WHERE code = 'CNY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MH', 'Marshall Islands', '472', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GM', 'Gambia', '285', 'AFR', '220', (SELECT id FROM public."Currency" WHERE code = 'GMD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BI', 'Burundi', '115', 'AFR', '257', (SELECT id FROM public."Currency" WHERE code = 'BIF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TH', 'Thailand', '776', 'ASI', '66', (SELECT id FROM public."Currency" WHERE code = 'THB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ML', 'Mali', '464', 'AFR', '223', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('VE', 'Venezuela', '850', 'LA', '58', (SELECT id FROM public."Currency" WHERE code = 'VEF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MW', 'Malawi', '458', 'AFR', '265', (SELECT id FROM public."Currency" WHERE code = 'MWK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AN', 'Netherlands Antilles', '047', 'CAR', '31', (SELECT id FROM public."Currency" WHERE code = 'ANG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CH', 'Switzerland', '767', 'EUR', '41', (SELECT id FROM public."Currency" WHERE code = 'CHF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CZ', 'Czech Republic', '644', 'EUR', '420', (SELECT id FROM public."Currency" WHERE code = 'CZK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DO', 'Dominican Republic', '647', 'CAR', '1089', (SELECT id FROM public."Currency" WHERE code = 'DOP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SK', 'Slovakia', '246', 'EUR', '421', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('HU', 'Hungary', '355', 'EUR', '36', (SELECT id FROM public."Currency" WHERE code = 'HUF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ZW', 'Zimbabwe', '665', 'AFR', '263', (SELECT id FROM public."Currency" WHERE code = 'ZWR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CV', 'Cape Verde', '127', 'AFR', '238', (SELECT id FROM public."Currency" WHERE code = 'CVE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BN', 'Brunei Darussalam', '108', 'ASI', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BZ', 'Belize', '088', 'LA', '501', (SELECT id FROM public."Currency" WHERE code = 'BZD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CG', 'Congo', '177', 'AFR', '242', (SELECT id FROM public."Currency" WHERE code = 'XAF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BO', 'Bolivia', '097', 'LA', '591', (SELECT id FROM public."Currency" WHERE code = 'BOB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('HT', 'Haiti', '341', 'CAR', '509', (SELECT id FROM public."Currency" WHERE code = 'HTG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GF', 'French Guiana', '325', 'LA', '594', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PT', 'Portugal', '607', 'EUR', '351', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GP', 'Guadeloupe', '309', 'CAR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IE', 'Ireland', '375', 'EUR', '353', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BD', 'Bangladesh', '081', 'ASI', '880', (SELECT id FROM public."Currency" WHERE code = 'BDT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PA', 'Panama', '580', 'LA', '507', (SELECT id FROM public."Currency" WHERE code = 'USD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KR', 'Korea, Republic Of', '190', 'ASI', '82', (SELECT id FROM public."Currency" WHERE code = 'KRW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GN', 'Guinea', '329', 'AFR', '224', (SELECT id FROM public."Currency" WHERE code = 'GNF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LK', 'Sri Lanka', '750', 'ASI', '94', (SELECT id FROM public."Currency" WHERE code = 'LKR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BJ', 'Benin', '229', 'AFR', '229', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('EC', 'Ecuador', '239', 'LA', '593', (SELECT id FROM public."Currency" WHERE code = 'USD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CA', 'Canada', '149', 'NA', '1', (SELECT id FROM public."Currency" WHERE code = 'CAD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KY', 'Cayman Islands', '137', 'CAR', '1345', (SELECT id FROM public."Currency" WHERE code = 'KYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('UY', 'Uruguay', '845', 'LA', '598', (SELECT id FROM public."Currency" WHERE code = 'UYU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TZ', 'Tanzania, United Republic Of', '780', 'AFR', '255', (SELECT id FROM public."Currency" WHERE code = 'TZS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('HR', 'Croatia', '198', 'EUR', '385', (SELECT id FROM public."Currency" WHERE code = 'HRK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DM', 'Dominica', '235', 'CAR', '1767', (SELECT id FROM public."Currency" WHERE code = 'XCD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TN', 'Tunisia', '820', 'AFR', '216', (SELECT id FROM public."Currency" WHERE code = 'TND')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SN', 'Senegal', '728', 'AFR', '221', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CM', 'Cameroon', '145', 'AFR', '237', (SELECT id FROM public."Currency" WHERE code = 'XAF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('VN', 'Vietnam', '855', 'ASI', '84', (SELECT id FROM public."Currency" WHERE code = 'VND')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('QA', 'Qatar', '618', 'MEA', '974', (SELECT id FROM public."Currency" WHERE code = 'QAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('UG', 'Uganda', '833', 'AFR', '256', (SELECT id FROM public."Currency" WHERE code = 'UGX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CY', 'Cyprus', '221', 'EUR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('VG', 'Virgin Islands, British', '863', 'CAR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NA', 'Namibia', '507', 'AFR', '264', (SELECT id FROM public."Currency" WHERE code = 'NAD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IL', 'Israel', '383', 'MEA', '972', (SELECT id FROM public."Currency" WHERE code = 'ILS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CD', 'Congo, The Democratic Republic Of', 'NULL', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MQ', 'Martinique', '477', 'CAR', '33', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SL', 'Sierra Leone', '735', 'AFR', '232', (SELECT id FROM public."Currency" WHERE code = 'SLL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GT', 'Guatemala', '317', 'CAR', '502', (SELECT id FROM public."Currency" WHERE code = 'GTQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PL', 'Poland', '603', 'EUR', '48', (SELECT id FROM public."Currency" WHERE code = 'PLN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TC', 'Turks and Caicos Islands', '823', 'CAR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NC', 'New Caledonia', '542', 'PAC', '687', (SELECT id FROM public."Currency" WHERE code = 'XPF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GI', 'Gibraltar', '293', 'EUR', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PG', 'Papua New Guinea', '545', 'PAC', '675', (SELECT id FROM public."Currency" WHERE code = 'PGK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GL', 'Greenland', '305', 'NA', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AT', 'Austria', '072', 'EUR', '43', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GU', 'Guam', '313', 'PAC', '671', (SELECT id FROM public."Currency" WHERE code = 'USD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MT', 'Malta', '467', 'EUR', '356', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KM', 'Comoros', '173', 'AFR', '269', (SELECT id FROM public."Currency" WHERE code = 'KMF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TW', 'Taiwan, Province of China', '218', 'ASI', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PK', 'Pakistan', '576', 'ASI', '92', (SELECT id FROM public."Currency" WHERE code = 'PKR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('FI', 'Finland', '271', 'EUR', '358', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SB', 'Solomon Islands', '677', 'PAC', '677', (SELECT id FROM public."Currency" WHERE code = 'SBD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('HK', 'Hong Kong', '351', 'ASI', '852', (SELECT id FROM public."Currency" WHERE code = 'HKD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('UA', 'Ukraine', '830', 'EUR', '380', (SELECT id FROM public."Currency" WHERE code = 'UAH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NU', 'Niue', '531', 'PAC', '683', (SELECT id FROM public."Currency" WHERE code = 'NZD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('DJ', 'Djibouti', 'NULL', 'AFR', '253', (SELECT id FROM public."Currency" WHERE code = 'DJF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('RW', 'Rwanda', '675', 'AFR', '250', (SELECT id FROM public."Currency" WHERE code = 'RWF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('JM', 'Jamaica', '391', 'CAR', '1876', (SELECT id FROM public."Currency" WHERE code = 'JMD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SD', 'Sudan', '759', 'AFR', '249', (SELECT id FROM public."Currency" WHERE code = 'SDG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NP', 'Nepal', '517', 'ASI', '977', (SELECT id FROM public."Currency" WHERE code = 'NPR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LT', 'Lithuania', '443', 'EUR', '9876', (SELECT id FROM public."Currency" WHERE code = 'LTL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KW', 'Kuwait', '413', 'MEA', '965', (SELECT id FROM public."Currency" WHERE code = 'KWD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AO', 'Angola', '040', 'AFR', '244', (SELECT id FROM public."Currency" WHERE code = 'AOA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GA', 'Gabon', '281', 'AFR', '241', (SELECT id FROM public."Currency" WHERE code = 'XAF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TG', 'Togo', '800', 'AFR', '228', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('CR', 'Costa Rica', '196', 'LA', '506', (SELECT id FROM public."Currency" WHERE code = 'CRC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SI', 'Slovenia', '247', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ZM', 'Zambia', '890', 'AFR', '260', (SELECT id FROM public."Currency" WHERE code = 'ZMK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LU', 'Luxembourg', '445', 'EUR', '352', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KE', 'Kenya', '410', 'AFR', '254', (SELECT id FROM public."Currency" WHERE code = 'KES')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MC', 'Monaco', '498', 'EUR', '377', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('OM', 'Oman', '556', 'MEA', '968', (SELECT id FROM public."Currency" WHERE code = 'OMR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MO', 'Macau', '447', 'ASI', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NI', 'Nicaragua', '521', 'LA', '505', (SELECT id FROM public."Currency" WHERE code = 'NIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MV', 'Maldives', '461', 'ASI', '960', (SELECT id FROM public."Currency" WHERE code = 'MVR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LR', 'Liberia', '434', 'AFR', '231', (SELECT id FROM public."Currency" WHERE code = 'LRD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KI', 'Kiribati', '411', 'PAC', '686', (SELECT id FROM public."Currency" WHERE code = 'AUD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MU', 'Mauritius', '485', 'AFR', '230', (SELECT id FROM public."Currency" WHERE code = 'MUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BY', 'Belarus', '091', 'EUR', '375', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LS', 'Lesotho', '426', 'AFR', '266', (SELECT id FROM public."Currency" WHERE code = 'LSL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SZ', 'Swaziland', '773', 'AFR', '268', (SELECT id FROM public."Currency" WHERE code = 'SZL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MR', 'Mauritania', '488', 'AFR', '222', (SELECT id FROM public."Currency" WHERE code = 'MRO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TD', 'Chad', '203', 'AFR', '235', (SELECT id FROM public."Currency" WHERE code = 'XAF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KN', 'Saint Kitts and Nevis', '695', 'CAR', '1869', (SELECT id FROM public."Currency" WHERE code = 'XCD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('NE', 'Niger', '525', 'AFR', '227', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BF', 'Burkina Faso', '031', 'AFR', '226', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GW', 'Guinea-Bissau', '334', 'AFR', '245', (SELECT id FROM public."Currency" WHERE code = 'XOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SR', 'Suriname', '770', 'LA', '597', (SELECT id FROM public."Currency" WHERE code = 'SRD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('KH', 'Cambodia', '141', 'ASI', '855', (SELECT id FROM public."Currency" WHERE code = 'KHR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TT', 'Trinidad and Tobago', '815', 'CAR', '1868', (SELECT id FROM public."Currency" WHERE code = 'TTD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AS', 'American Samoa', '690', 'PAC', '1684', (SELECT id FROM public."Currency" WHERE code = 'USD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MM', 'Myanmar', '093', 'ASI', '95', (SELECT id FROM public."Currency" WHERE code = 'MMK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LV', 'Latvia', '429', 'EUR', '371', (SELECT id FROM public."Currency" WHERE code = 'LVL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MP', 'Northern Mariana Islands', 'NULL', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('PW', 'Palau', '578', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('HN', 'Honduras', '345', 'LA', '504', (SELECT id FROM public."Currency" WHERE code = 'HNL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('RE', 'Reunion', '660', 'AFR', '33', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SV', 'El Salvador', '242', 'LA', '503', (SELECT id FROM public."Currency" WHERE code = 'SVC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SC', 'Seychelles', '731', 'AFR', '248', (SELECT id FROM public."Currency" WHERE code = 'SCR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('SG', 'Singapore', '741', 'ASI', '65', (SELECT id FROM public."Currency" WHERE code = 'SGD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BA', 'Bosnia and Herzegovina', '029', 'EUR', '387', (SELECT id FROM public."Currency" WHERE code = 'BAM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MK', 'Macedonia, The Former Yugoslav Republic of', '448', 'NULL', 'NULL', (SELECT id FROM public."Currency" WHERE code = 'NULL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('BG', 'Bulgaria', '111', 'EUR', '359', (SELECT id FROM public."Currency" WHERE code = 'BGN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('UZ', 'Uzbekistan', '847', 'ASI', '998', (SELECT id FROM public."Currency" WHERE code = 'UZS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('GE', 'Georgia', '287', 'ASI', '995', (SELECT id FROM public."Currency" WHERE code = 'GEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('TO', 'Tonga', '810', 'PAC', '676', (SELECT id FROM public."Currency" WHERE code = 'TOP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('IR', 'Iran, Islamic Republic Of', '372', 'MEA', '98', (SELECT id FROM public."Currency" WHERE code = 'IRR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('AL', 'Albania', '017', 'EUR', '355', (SELECT id FROM public."Currency" WHERE code = 'ALL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('EE', 'Estonia', '251', 'EUR', '372', (SELECT id FROM public."Currency" WHERE code = 'EUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('MG', 'Madagascar', '450', 'AFR', '261', (SELECT id FROM public."Currency" WHERE code = 'MGA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LY', 'Libyan Arab Jamahiriya', '438', 'AFR', '218', (SELECT id FROM public."Currency" WHERE code = 'LYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('VC', 'Saint Vincent and The Grenadines', '705', 'CAR', '1784', (SELECT id FROM public."Currency" WHERE code = 'XCD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('VU', 'Vanuatu', '551', 'PAC', '678', (SELECT id FROM public."Currency" WHERE code = 'VUV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('LA', 'Lao People s Democratic Republic', '420', 'ASI', '856', (SELECT id FROM public."Currency" WHERE code = 'LAK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Countries" (code, name, dane, region, prefix, "curencyId") VALUES ('ST', 'STONIA', '251', 'AFR', '239', (SELECT id FROM public."Currency" WHERE code = 'STD')) ON CONFLICT (code) DO NOTHING;

-- 17. Ciudades (Completas)

-- 18. Aeropuertos (Completos)
-- 17. Ciudades (Completas)
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HOU', 'Houston', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'HOU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ANC', 'Anchorage', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'ANC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LIM', 'Lima', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'LIM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DEN', 'Denver', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'DEN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ATL', 'Atlanta', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'ATL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CMH', 'Columbus', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'CMH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BOL', 'Hartford', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'BOL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SEA', 'Seattle', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SEA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CLE', 'Cleveland', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'CLE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BNA', 'Nashville', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'BNA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BOS', 'Boston', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'BOS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BUF', 'Buffalo', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'BUF') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BWI', 'Baltimore', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'BWI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CHI', 'Chicago', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'CHI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CHS', 'Charleston', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'CHS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DFW', 'Dallas', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'DFW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DAY', 'Dayton', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'DAY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DUB', 'Dublin', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'DUB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DTT', 'Detroit', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'DTT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('EWR', 'Newark', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'EWR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GEO', 'Georgetown', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'GEO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GLA', 'Glasgow', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'GLA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HNL', 'Honolulu', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'HNL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LAX', 'Los Angeles', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'LAX') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SFO', 'San Francisco', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SFO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NYC', 'New York', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'NYC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LAS', 'Las Vegas', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'LAS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LGB', 'Long Beach', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'LGB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ORL', 'Orlando', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'ORL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MEM', 'Memphis', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'MEM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MIA', 'Miami', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'MIA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MKE', 'Milwaukee', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'MKE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MSP', 'Minneapolis', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'MSP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MSY', 'New Orleans', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'MSY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SAN', 'San Diego', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SAN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NOR', 'Norfolk', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'NOR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PDX', 'Portland', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'PDX') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PHX', 'Phoenix', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'PHX') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RDU', 'Raleigh', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'RDU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RIC', 'Richmond', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'RIC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ROC', 'Rochester', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'ROC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SAI', 'San Antonio', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SAI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SAV', 'Savannah', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SAV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SLC', 'Salt Lake City', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'SLC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TPA', 'Tampa', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'TPA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TUS', 'Tucson', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'TUS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YYJ', 'Victoria', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'YYJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VAP', 'Valparaiso', (SELECT id FROM public."Countries" WHERE code = 'US'), '', 'VAP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ABJ', 'Abidjan', (SELECT id FROM public."Countries" WHERE code = 'CI'), '', 'ABJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DHA', 'Dhahran', (SELECT id FROM public."Countries" WHERE code = 'SA'), '', 'DHA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RUH', 'Riyadh', (SELECT id FROM public."Countries" WHERE code = 'SA'), '', 'RUH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('JED', 'Jeddah', (SELECT id FROM public."Countries" WHERE code = 'SA'), '', 'JED') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KAN', 'Kano', (SELECT id FROM public."Countries" WHERE code = 'NG'), '', 'KAN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LOS', 'Lagos', (SELECT id FROM public."Countries" WHERE code = 'NG'), '', 'LOS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SYD', 'Sydney', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'SYD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MEL', 'Melbourne', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'MEL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ROM', 'Roma', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'ROM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PER', 'Perth', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'PER') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CNS', 'Cairns', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'CNS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HBA', 'Hobart', (SELECT id FROM public."Countries" WHERE code = 'AU'), '', 'HBA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BHD', 'Belfast', (SELECT id FROM public."Countries" WHERE code = 'GB'), '', 'BHD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MME', 'Teesside', (SELECT id FROM public."Countries" WHERE code = 'GB'), '', 'MME') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LBA', 'Leeds', (SELECT id FROM public."Countries" WHERE code = 'GB'), '', 'LBA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LPB', 'La Paz', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'LPB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MID', 'Merida', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'MID') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MZT', 'Mazatlan', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'MZT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MTY', 'Monterrey', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'MTY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PVR', 'Puerto Vallarta', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'PVR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VER', 'Veracruz', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'VER') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TAM', 'Tampico', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'TAM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GYM', 'Guaymas', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'GYM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GDL', 'Guadalajara', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'GDL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CUN', 'Cancun', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'CUN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CZM', 'Cozumel', (SELECT id FROM public."Countries" WHERE code = 'MX'), '', 'CZM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ACC', 'Accra', (SELECT id FROM public."Countries" WHERE code = 'GH'), '', 'ACC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ALC', 'Alicante', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'ALC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AGP', 'Malaga', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'AGP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BCN', 'Barcelona', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'BCN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BIO', 'Bilbao', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'BIO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GND', 'Granada', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'GND') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('IBZ', 'Ibiza', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'IBZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SVQ', 'Sevilla', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'SVQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VGO', 'Vigo', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'VGO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VIX', 'Vitoria', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'VIX') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VLC', 'Valencia', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'VLC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ZAZ', 'Zaragoza', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'ZAZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SDR', 'Santander', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'SDR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PNA', 'Pamplona', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'PNA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MJV', 'Murcia', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'MJV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MAD', 'Madrid', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'MAD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MAH', 'Menorca', (SELECT id FROM public."Countries" WHERE code = 'ES'), '', 'MAH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AYT', 'Antalya', (SELECT id FROM public."Countries" WHERE code = 'TR'), '', 'AYT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ANK', 'Ankara', (SELECT id FROM public."Countries" WHERE code = 'TR'), '', 'ANK') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ADD', 'Addis Ababa', (SELECT id FROM public."Countries" WHERE code = 'ET'), '', 'ADD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ADE', 'Aden', (SELECT id FROM public."Countries" WHERE code = 'YE'), '', 'ADE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BAQ', 'Barranquilla', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'ATL', 'BAQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BOG', 'Bogota', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'BOG', 'BOG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MDE', 'Medellin', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'ANT', 'MDE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CTG', 'Cartagena', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'BOL', 'CTG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CLO', 'Cali', (SELECT id FROM public."Countries" WHERE code = 'CO'), 'VAL', 'CLO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('000001', 'chigorodo', (SELECT id FROM public."Countries" WHERE code = 'CO'), '', '000001') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BHI', 'Bahia Blanca', (SELECT id FROM public."Countries" WHERE code = 'AR'), '', 'BHI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BUE', 'Buenos Aires', (SELECT id FROM public."Countries" WHERE code = 'AR'), '', 'BUE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SLZ', 'San Luis', (SELECT id FROM public."Countries" WHERE code = 'AR'), '', 'SLZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KRS', 'Kristiansand', (SELECT id FROM public."Countries" WHERE code = 'NO'), '', 'KRS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SVG', 'Stavanger', (SELECT id FROM public."Countries" WHERE code = 'NO'), '', 'SVG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BGO', 'Bergen', (SELECT id FROM public."Countries" WHERE code = 'NO'), '', 'BGO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('OSL', 'Oslo', (SELECT id FROM public."Countries" WHERE code = 'NO'), '', 'OSL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CAS', 'Casablanca', (SELECT id FROM public."Countries" WHERE code = 'MA'), '', 'CAS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RAK', 'Marrakech', (SELECT id FROM public."Countries" WHERE code = 'MA'), '', 'RAK') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RBA', 'Rabat', (SELECT id FROM public."Countries" WHERE code = 'MA'), '', 'RBA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('STR', 'Stuttgart', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'STR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LEJ', 'Leipzig', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'LEJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MUC', 'Munich', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'MUC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VER', 'Berlin', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'VER') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DUS', 'Dusseldorf', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'DUS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FRA', 'Frankfurt', (SELECT id FROM public."Countries" WHERE code = 'DE'), '', 'FRA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PAR', 'Paris', (SELECT id FROM public."Countries" WHERE code = 'FR'), '', 'PAR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BOD', 'Bordeaux', (SELECT id FROM public."Countries" WHERE code = 'FR'), '', 'BOD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LYS', 'Lyon', (SELECT id FROM public."Countries" WHERE code = 'FR'), '', 'LYS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LHV', 'Le Havre', (SELECT id FROM public."Countries" WHERE code = 'FR'), '', 'LHV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LIL', 'Lille', (SELECT id FROM public."Countries" WHERE code = 'FR'), '', 'LIL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MMA', 'Malmo', (SELECT id FROM public."Countries" WHERE code = 'SE'), '', 'MMA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DEL', 'Delhi', (SELECT id FROM public."Countries" WHERE code = 'IN'), '', 'DEL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MAA', 'Madras', (SELECT id FROM public."Countries" WHERE code = 'IN'), '', 'MAA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DPS', 'Denpasar', (SELECT id FROM public."Countries" WHERE code = 'ID'), '', 'DPS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('JKT', 'Jakarta', (SELECT id FROM public."Countries" WHERE code = 'ID'), '', 'JKT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BRI', 'Bari', (SELECT id FROM public."Countries" WHERE code = 'IT'), '', 'BRI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MIL', 'Milan', (SELECT id FROM public."Countries" WHERE code = 'IT'), '', 'MIL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PMO', 'Palermo', (SELECT id FROM public."Countries" WHERE code = 'IT'), '', 'PMO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('POA', 'Porto Alegre', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'POA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('REC', 'Recife', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'REC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SSA', 'Salvador', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'SSA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('JPA', 'Joao Pessoa', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'JPA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MCZ', 'Maceio', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'MCZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NAT', 'Natal', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'NAT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BSB', 'Brasilia', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'BSB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BZC', 'Buzios', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'BZC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BEL', 'Belem', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'BEL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AJU', 'Aracaju', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'AJU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BHZ', 'Belo Horizonte', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'BHZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CWB', 'Curitiba', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'CWB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CGB', 'Cuiaba', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'CGB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('IOS', 'Ilheus', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'IOS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GYN', 'Goiania', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'GYN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FOR', 'Fortaleza', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'FOR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('RIO', 'Rio De Janeiro', (SELECT id FROM public."Countries" WHERE code = 'BR'), '', 'RIO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CHC', 'Christchurch', (SELECT id FROM public."Countries" WHERE code = 'NZ'), '', 'CHC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AKL', 'Auckland', (SELECT id FROM public."Countries" WHERE code = 'NZ'), '', 'AKL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('WLG', 'Wellington', (SELECT id FROM public."Countries" WHERE code = 'NZ'), '', 'WLG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PRY', 'Pretoria', (SELECT id FROM public."Countries" WHERE code = 'ZA'), '', 'PRY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PEZ', 'Port Elizabeth', (SELECT id FROM public."Countries" WHERE code = 'ZA'), '', 'PEZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DUR', 'Durban', (SELECT id FROM public."Countries" WHERE code = 'ZA'), '', 'DUR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CTW', 'Cape Town', (SELECT id FROM public."Countries" WHERE code = 'ZA'), '', 'CTW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ALP', 'Aleppo', (SELECT id FROM public."Countries" WHERE code = 'SY'), '', 'ALP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CAI', 'Cairo', (SELECT id FROM public."Countries" WHERE code = 'EG'), '', 'CAI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AMM', 'Amman', (SELECT id FROM public."Countries" WHERE code = 'JO'), '', 'AMM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AMS', 'Amsterdam', (SELECT id FROM public."Countries" WHERE code = 'NL'), '', 'AMS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ANF', 'Antofagasta', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'ANF') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ARI', 'Arica', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'ARI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('IQQ', 'Iquique', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'IQQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PMC', 'Puerto Montt', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'PMC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PUQ', 'Punta Arenas', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'PUQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ZCO', 'Temuco', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'ZCO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LSC', 'La Serena', (SELECT id FROM public."Countries" WHERE code = 'CL'), '', 'LSC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ANR', 'Antwerp', (SELECT id FROM public."Countries" WHERE code = 'BE'), '', 'ANR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KUL', 'Kuala Lumpur', (SELECT id FROM public."Countries" WHERE code = 'MY'), '', 'KUL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PEN', 'Penang', (SELECT id FROM public."Countries" WHERE code = 'MY'), '', 'PEN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MPM', 'Maputo', (SELECT id FROM public."Countries" WHERE code = 'MZ'), '', 'MPM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('APW', 'Apia', (SELECT id FROM public."Countries" WHERE code = 'WS'), '', 'APW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AQP', 'Arequipa', (SELECT id FROM public."Countries" WHERE code = 'PE'), '', 'AQP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('OSA', 'Osaka', (SELECT id FROM public."Countries" WHERE code = 'JP'), '', 'OSA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FUK', 'Fukuoka', (SELECT id FROM public."Countries" WHERE code = 'JP'), '', 'FUK') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NGO', 'Nagoya', (SELECT id FROM public."Countries" WHERE code = 'JP'), '', 'NGO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('OKA', 'Okinawa', (SELECT id FROM public."Countries" WHERE code = 'JP'), '', 'OKA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ASM', 'Asmara', (SELECT id FROM public."Countries" WHERE code = 'ER'), '', 'ASM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ASU', 'Asuncion', (SELECT id FROM public."Countries" WHERE code = 'PY'), '', 'ASU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FPO', 'Freeport', (SELECT id FROM public."Countries" WHERE code = 'BS'), '', 'FPO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NAS', 'Nassau', (SELECT id FROM public."Countries" WHERE code = 'BS'), '', 'NAS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AUA', 'Aruba', (SELECT id FROM public."Countries" WHERE code = 'AW'), '', 'AUA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AUH', 'Abu Dhabi', (SELECT id FROM public."Countries" WHERE code = 'AE'), '', 'AUH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DXB', 'Dubai', (SELECT id FROM public."Countries" WHERE code = 'AE'), '', 'DXB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SHJ', 'Sharjah', (SELECT id FROM public."Countries" WHERE code = 'AE'), '', 'SHJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PPT', 'Papeete', (SELECT id FROM public."Countries" WHERE code = 'PF'), '', 'PPT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VRA', 'Varadero', (SELECT id FROM public."Countries" WHERE code = 'CU'), '', 'VRA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ZLO', 'Manzanillo', (SELECT id FROM public."Countries" WHERE code = 'CU'), '', 'ZLO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HOG', 'Holguin', (SELECT id FROM public."Countries" WHERE code = 'CU'), '', 'HOG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('AVI', 'Ciego De Avila', (SELECT id FROM public."Countries" WHERE code = 'CU'), '', 'AVI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MNL', 'Manila', (SELECT id FROM public."Countries" WHERE code = 'PH'), '', 'MNL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BAH', 'Bahrain', (SELECT id FROM public."Countries" WHERE code = 'BH'), '', 'BAH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GBE', 'Gaborone', (SELECT id FROM public."Countries" WHERE code = 'BW'), '', 'GBE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TSR', 'Timisoara', (SELECT id FROM public."Countries" WHERE code = 'RO'), '', 'TSR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BDA', 'Bermuda', (SELECT id FROM public."Countries" WHERE code = 'BM'), '', 'BDA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BEY', 'Beirut', (SELECT id FROM public."Countries" WHERE code = 'LB'), '', 'BEY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NAN', 'Nadi', (SELECT id FROM public."Countries" WHERE code = 'FJ'), '', 'NAN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SUV', 'Suva', (SELECT id FROM public."Countries" WHERE code = 'FJ'), '', 'SUV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BGF', 'Bangui', (SELECT id FROM public."Countries" WHERE code = 'CF'), '', 'BGF') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BGI', 'Barbados', (SELECT id FROM public."Countries" WHERE code = 'BB'), '', 'BGI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BGW', 'Baghdad', (SELECT id FROM public."Countries" WHERE code = 'IQ'), '', 'BGW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BSR', 'Basra', (SELECT id FROM public."Countries" WHERE code = 'IQ'), '', 'BSR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CAN', 'Guangzhou', (SELECT id FROM public."Countries" WHERE code = 'CN'), '', 'CAN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BJS', 'Beijing', (SELECT id FROM public."Countries" WHERE code = 'CN'), '', 'BJS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DLC', 'Dalian', (SELECT id FROM public."Countries" WHERE code = 'CN'), '', 'DLC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SHA', 'Shanghai', (SELECT id FROM public."Countries" WHERE code = 'CN'), '', 'SHA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BJL', 'Banjul', (SELECT id FROM public."Countries" WHERE code = 'GM'), '', 'BJL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BJM', 'Bujumbura', (SELECT id FROM public."Countries" WHERE code = 'BI'), '', 'BJM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BKK', 'Bangkok', (SELECT id FROM public."Countries" WHERE code = 'TH'), '', 'BKK') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HKT', 'Phuket', (SELECT id FROM public."Countries" WHERE code = 'TH'), '', 'HKT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BKO', 'Bamako', (SELECT id FROM public."Countries" WHERE code = 'ML'), '', 'BKO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CCS', 'Caracas', (SELECT id FROM public."Countries" WHERE code = 'VE'), '', 'CCS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PMV', 'Porlamar', (SELECT id FROM public."Countries" WHERE code = 'VE'), '', 'PMV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MAR', 'Maracaibo', (SELECT id FROM public."Countries" WHERE code = 'VE'), '', 'MAR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LLW', 'Lilongwe', (SELECT id FROM public."Countries" WHERE code = 'MW'), '', 'LLW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BLZ', 'Blantyre', (SELECT id FROM public."Countries" WHERE code = 'MW'), '', 'BLZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BON', 'Bonaire', (SELECT id FROM public."Countries" WHERE code = 'AN'), '', 'BON') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MLH', 'Mulhouse', (SELECT id FROM public."Countries" WHERE code = 'CH'), '', 'MLH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ZRH', 'Zurich', (SELECT id FROM public."Countries" WHERE code = 'CH'), '', 'ZRH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SDQ', 'Santo Domingo', (SELECT id FROM public."Countries" WHERE code = 'DO'), '', 'SDQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BTS', 'Bratislava', (SELECT id FROM public."Countries" WHERE code = 'SK'), '', 'BTS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BUD', 'Budapest', (SELECT id FROM public."Countries" WHERE code = 'HU'), '', 'BUD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BUQ', 'Bulawayo', (SELECT id FROM public."Countries" WHERE code = 'ZW'), '', 'BUQ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HRE', 'Harare', (SELECT id FROM public."Countries" WHERE code = 'ZW'), '', 'HRE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('BZV', 'Brazzaville', (SELECT id FROM public."Countries" WHERE code = 'CG'), '', 'BZV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CBB', 'Cochabamba', (SELECT id FROM public."Countries" WHERE code = 'BO'), '', 'CBB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PAP', 'Port Au Prince', (SELECT id FROM public."Countries" WHERE code = 'HT'), '', 'PAP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CAY', 'Cayenne', (SELECT id FROM public."Countries" WHERE code = 'GF'), '', 'CAY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FAO', 'Faro', (SELECT id FROM public."Countries" WHERE code = 'PT'), '', 'FAO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SNN', 'Shannon', (SELECT id FROM public."Countries" WHERE code = 'IE'), '', 'SNN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DAC', 'Dhaka', (SELECT id FROM public."Countries" WHERE code = 'BD'), '', 'DAC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CKY', 'Conakry', (SELECT id FROM public."Countries" WHERE code = 'GN'), '', 'CKY') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CMB', 'Colombo', (SELECT id FROM public."Countries" WHERE code = 'LK'), '', 'CMB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('COO', 'Cotonou', (SELECT id FROM public."Countries" WHERE code = 'BJ'), '', 'COO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GYE', 'Guayaquil', (SELECT id FROM public."Countries" WHERE code = 'EC'), '', 'GYE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('UIO', 'Quito', (SELECT id FROM public."Countries" WHERE code = 'EC'), '', 'UIO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YTO', 'Toronto', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YTO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YEG', 'Edmonton', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YEG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YUL', 'Montreal', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YUL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YOW', 'Ottawa', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YOW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YYC', 'Calgary', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YYC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YQG', 'Windsor', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YQG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YWG', 'Winnipeg', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'YWG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('VAN', 'Vancouver', (SELECT id FROM public."Countries" WHERE code = 'CA'), '', 'VAN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CYR', 'Colonia', (SELECT id FROM public."Countries" WHERE code = 'UY'), '', 'CYR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PDP', 'Punta Del Este', (SELECT id FROM public."Countries" WHERE code = 'UY'), '', 'PDP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MVD', 'Montevideo', (SELECT id FROM public."Countries" WHERE code = 'UY'), '', 'MVD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DAR', 'Dar Es Salaam', (SELECT id FROM public."Countries" WHERE code = 'TZ'), '', 'DAR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ZAG', 'Zagreb', (SELECT id FROM public."Countries" WHERE code = 'HR'), '', 'ZAG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DKR', 'Dakar', (SELECT id FROM public."Countries" WHERE code = 'SN'), '', 'DKR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DLA', 'Douala', (SELECT id FROM public."Countries" WHERE code = 'CM'), '', 'DLA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('YAO', 'Yaounde', (SELECT id FROM public."Countries" WHERE code = 'CM'), '', 'YAO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('DOH', 'Doha', (SELECT id FROM public."Countries" WHERE code = 'QA'), '', 'DOH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LCA', 'Larnaca', (SELECT id FROM public."Countries" WHERE code = 'CY'), '', 'LCA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PFO', 'Paphos', (SELECT id FROM public."Countries" WHERE code = 'CY'), '', 'PFO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('WDH', 'Windhoek', (SELECT id FROM public."Countries" WHERE code = 'NA'), '', 'WDH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TLV', 'Tel Aviv', (SELECT id FROM public."Countries" WHERE code = 'IL'), '', 'TLV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('JRS', 'Jerusalem', (SELECT id FROM public."Countries" WHERE code = 'IL'), '', 'JRS') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FBM', 'Lubumbashi', (SELECT id FROM public."Countries" WHERE code = 'CD'), '', 'FBM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FIH', 'Kinshasa', (SELECT id FROM public."Countries" WHERE code = 'CD'), '', 'FIH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('FNA', 'Freetown', (SELECT id FROM public."Countries" WHERE code = 'SL'), '', 'FNA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GIB', 'Gibraltar', (SELECT id FROM public."Countries" WHERE code = 'GI'), '', 'GIB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('GRZ', 'Graz', (SELECT id FROM public."Countries" WHERE code = 'AT'), '', 'GRZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KLU', 'Klagenfurt', (SELECT id FROM public."Countries" WHERE code = 'AT'), '', 'KLU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LNZ', 'Linz', (SELECT id FROM public."Countries" WHERE code = 'AT'), '', 'LNZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MLA', 'Malta', (SELECT id FROM public."Countries" WHERE code = 'MT'), '', 'MLA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KHH', 'Kaohsiung', (SELECT id FROM public."Countries" WHERE code = 'TW'), '', 'KHH') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TPE', 'Taipei', (SELECT id FROM public."Countries" WHERE code = 'TW'), '', 'TPE') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KHI', 'Karachi', (SELECT id FROM public."Countries" WHERE code = 'PK'), '', 'KHI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('ISB', 'Islamabad', (SELECT id FROM public."Countries" WHERE code = 'PK'), '', 'ISB') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HEL', 'Helsinki', (SELECT id FROM public."Countries" WHERE code = 'FI'), '', 'HEL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('HKG', 'Hong Kong', (SELECT id FROM public."Countries" WHERE code = 'HK'), '', 'HKG') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('IEV', 'Kiev', (SELECT id FROM public."Countries" WHERE code = 'UA'), '', 'IEV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KGL', 'Kigali', (SELECT id FROM public."Countries" WHERE code = 'RW'), '', 'KGL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KIN', 'Kingston', (SELECT id FROM public."Countries" WHERE code = 'JM'), '', 'KIN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MBJ', 'Montego Bay', (SELECT id FROM public."Countries" WHERE code = 'JM'), '', 'MBJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KRT', 'Khartoum', (SELECT id FROM public."Countries" WHERE code = 'SD'), '', 'KRT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('KWI', 'Kuwait', (SELECT id FROM public."Countries" WHERE code = 'KW'), '', 'KWI') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LAD', 'Luanda', (SELECT id FROM public."Countries" WHERE code = 'AO'), '', 'LAD') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LBV', 'Libreville', (SELECT id FROM public."Countries" WHERE code = 'GA'), '', 'LBV') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LFW', 'Lome', (SELECT id FROM public."Countries" WHERE code = 'TG'), '', 'LFW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('CTF', 'CARTAGO', (SELECT id FROM public."Countries" WHERE code = 'CR'), '', 'CTF') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LJU', 'Ljubljana', (SELECT id FROM public."Countries" WHERE code = 'SI'), '', 'LJU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('LUN', 'Lusaka', (SELECT id FROM public."Countries" WHERE code = 'ZM'), '', 'LUN') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NBO', 'Nairobi', (SELECT id FROM public."Countries" WHERE code = 'KE'), '', 'NBO') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MCT', 'Muscat', (SELECT id FROM public."Countries" WHERE code = 'OM'), '', 'MCT') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MGA', 'Managua', (SELECT id FROM public."Countries" WHERE code = 'NI'), '', 'MGA') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('MLW', 'Monrovia', (SELECT id FROM public."Countries" WHERE code = 'LR'), '', 'MLW') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NKC', 'Nouakchott', (SELECT id FROM public."Countries" WHERE code = 'MR'), '', 'NKC') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('NIM', 'Niamey', (SELECT id FROM public."Countries" WHERE code = 'NE'), '', 'NIM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('PBM', 'Paramaribo', (SELECT id FROM public."Countries" WHERE code = 'SR'), '', 'PBM') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SAP', 'San Pedro Sula', (SELECT id FROM public."Countries" WHERE code = 'HN'), '', 'SAP') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TGU', 'Tegucigalpa', (SELECT id FROM public."Countries" WHERE code = 'HN'), '', 'TGU') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SAL', 'San Salvador', (SELECT id FROM public."Countries" WHERE code = 'SV'), '', 'SAL') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SEZ', 'Mahe Island', (SELECT id FROM public."Countries" WHERE code = 'SC'), '', 'SEZ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SJJ', 'Sarajevo', (SELECT id FROM public."Countries" WHERE code = 'BA'), '', 'SJJ') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('SOF', 'Sofia', (SELECT id FROM public."Countries" WHERE code = 'BG'), '', 'SOF') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('THR', 'Teheran', (SELECT id FROM public."Countries" WHERE code = 'IR'), '', 'THR') ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Cities" (code, name, "countriesId", statecode, iata) VALUES ('TIA', 'Tirana', (SELECT id FROM public."Countries" WHERE code = 'AL'), '', 'TIA') ON CONFLICT (code) DO NOTHING;

-- 18. Aeropuertos (Completos)
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AAP', 'Andrau Airpark', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ABJ', 'Felix Houphouet Boigny Arpt', (SELECT id FROM public."Cities" WHERE code = 'ABJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ACC', 'Kotoka Airport', (SELECT id FROM public."Cities" WHERE code = 'ACC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ADD', 'Bole Airport', (SELECT id FROM public."Cities" WHERE code = 'ADD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ADE', 'Yemen Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'ADE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AEP', 'Jorge Newbery', (SELECT id FROM public."Cities" WHERE code = 'BUE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AGB', 'Mehlhausen', (SELECT id FROM public."Cities" WHERE code = 'MUC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AGP', 'Malaga Arpt', (SELECT id FROM public."Cities" WHERE code = 'AGP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AJU', 'Santa Maria Arpt', (SELECT id FROM public."Cities" WHERE code = 'AJU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AKL', 'Auckland Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'AKL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ALC', 'Alicante Arpt', (SELECT id FROM public."Cities" WHERE code = 'ALC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ALP', 'Nejrab Arpt', (SELECT id FROM public."Cities" WHERE code = 'ALP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AMM', 'Queen Alia Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'AMM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AMS', 'Schiphol Arpt', (SELECT id FROM public."Cities" WHERE code = 'AMS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ANC', 'Anchorage Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'ANC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ANF', 'Cerro Moreno Arpt', (SELECT id FROM public."Cities" WHERE code = 'ANF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ANK', 'Etimesgut Arpt', (SELECT id FROM public."Cities" WHERE code = 'ANK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ANR', 'Deurne Airport', (SELECT id FROM public."Cities" WHERE code = 'ANR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AOH', 'Allen County Arpt', (SELECT id FROM public."Cities" WHERE code = 'LIM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('APA', 'Centennial Airport', (SELECT id FROM public."Cities" WHERE code = 'DEN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('APW', 'Apia Airport', (SELECT id FROM public."Cities" WHERE code = 'APW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AQP', 'Rodriguez Ballon Arpt', (SELECT id FROM public."Cities" WHERE code = 'AQP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ARI', 'Chacalluta Arpt', (SELECT id FROM public."Cities" WHERE code = 'ARI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ASM', 'Asmara Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'ASM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ASU', 'Salvio Pettirosse Arpt', (SELECT id FROM public."Cities" WHERE code = 'ASU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ATL', 'Hartsfield Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'ATL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AUA', 'Reina Beatrix Arpt', (SELECT id FROM public."Cities" WHERE code = 'AUA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AUH', 'Dhabi Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'AUH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AUO', 'Auburn Opelika', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AVI', 'Maximo Gomez Arpt', (SELECT id FROM public."Cities" WHERE code = 'AVI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('AYT', 'Antalya Airport', (SELECT id FROM public."Cities" WHERE code = 'AYT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BAH', 'Muharraq Arpt', (SELECT id FROM public."Cities" WHERE code = 'BAH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BCN', 'Barcelona Arpt', (SELECT id FROM public."Cities" WHERE code = 'BCN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BDA', 'Bermuda International', (SELECT id FROM public."Cities" WHERE code = 'BDA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BDL', 'Bradley Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BOL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BEL', 'Val De Cans Arpt', (SELECT id FROM public."Cities" WHERE code = 'BEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BER', 'Berlin Airports', (SELECT id FROM public."Cities" WHERE code = 'VER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BEY', 'Beirut Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BEY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BFI', 'Seattle Boeing Field', (SELECT id FROM public."Cities" WHERE code = 'SEA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BFS', 'Belfast Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BHD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BGF', 'Bangui Airport', (SELECT id FROM public."Cities" WHERE code = 'BGF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BGI', 'Grantley Adams Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BGI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BGO', 'Flesland Airport', (SELECT id FROM public."Cities" WHERE code = 'BGO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BGW', 'Al Muthana Arpt', (SELECT id FROM public."Cities" WHERE code = 'BGW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BHD', 'Belfast City Arpt', (SELECT id FROM public."Cities" WHERE code = 'BHD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BHI', 'Commandante Airport', (SELECT id FROM public."Cities" WHERE code = 'BHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BIO', 'Sondica Arpt', (SELECT id FROM public."Cities" WHERE code = 'BIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BJL', 'Yundum Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BJL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BJM', 'Bujumbura Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BJM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BJS', 'Beijing', (SELECT id FROM public."Cities" WHERE code = 'BJS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BKK', 'Bangkok Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BKK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BKL', 'Burke Lakefront Arpt', (SELECT id FROM public."Cities" WHERE code = 'CLE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BKO', 'Senou Airport', (SELECT id FROM public."Cities" WHERE code = 'BKO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BLA', 'Gen J A Anzoategui Arpt', (SELECT id FROM public."Cities" WHERE code = 'BCN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BLZ', 'Chileka Airport', (SELECT id FROM public."Cities" WHERE code = 'BLZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BNA', 'Nashville Metro Arpt', (SELECT id FROM public."Cities" WHERE code = 'BNA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BOD', 'Merignac Arpt', (SELECT id FROM public."Cities" WHERE code = 'BOD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BON', 'Flamingo Field', (SELECT id FROM public."Cities" WHERE code = 'BON')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BOS', 'Logan Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BOS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BRI', 'Bari Airport', (SELECT id FROM public."Cities" WHERE code = 'BRI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BSB', 'Brasilia Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BSB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BSR', 'Basra Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BSR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BTS', 'Ivanka Arpt', (SELECT id FROM public."Cities" WHERE code = 'BTS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BUD', 'Ferihegy Arpt', (SELECT id FROM public."Cities" WHERE code = 'BUD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BUE', 'Buenos Aires Airports', (SELECT id FROM public."Cities" WHERE code = 'BUE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BUF', 'Greater Buffalo Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BUF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BUQ', 'Bulawayo Arpt', (SELECT id FROM public."Cities" WHERE code = 'BUQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BWI', 'Baltimore Washington Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'BWI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BZC', 'Buzios Arpt', (SELECT id FROM public."Cities" WHERE code = 'BZC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BZV', 'Maya Maya Arpt', (SELECT id FROM public."Cities" WHERE code = 'BZV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CAI', 'Cairo Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CAI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CAN', 'Baiyun Airport', (SELECT id FROM public."Cities" WHERE code = 'CAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CAS', 'Anfa Airport', (SELECT id FROM public."Cities" WHERE code = 'CAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CAY', 'Rochambeau Airport', (SELECT id FROM public."Cities" WHERE code = 'CAY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CBB', 'J Wilsterman Arpt', (SELECT id FROM public."Cities" WHERE code = 'CBB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CCS', 'Simon Bolivar Arpt', (SELECT id FROM public."Cities" WHERE code = 'CCS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CDG', 'Charles De Gaulle Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CGB', 'Marechal Rondon Arpt', (SELECT id FROM public."Cities" WHERE code = 'CGB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CGF', 'Cuyahoga County Airport', (SELECT id FROM public."Cities" WHERE code = 'CLE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CGK', 'Soekarno Hatta Intl', (SELECT id FROM public."Cities" WHERE code = 'JKT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CGX', 'Meigs Field', (SELECT id FROM public."Cities" WHERE code = 'CHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CHC', 'Christchurch Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CHC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CHI', 'Chicago Airports', (SELECT id FROM public."Cities" WHERE code = 'CHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CHS', 'Charleston Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CHS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CKY', 'Conakry Airport', (SELECT id FROM public."Cities" WHERE code = 'CKY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CLE', 'Hopkins Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CLE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CLU', 'Columbus Municipal Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CMB', 'Katunayake Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CMH', 'Port Columbus Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CMN', 'Mohamed V Arpt', (SELECT id FROM public."Cities" WHERE code = 'CAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CNF', 'Tancredo Neves Intl Arpt.', (SELECT id FROM public."Cities" WHERE code = 'BHZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CNS', 'Cairns Airport', (SELECT id FROM public."Cities" WHERE code = 'CNS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('COO', 'Cotonou Airport', (SELECT id FROM public."Cities" WHERE code = 'COO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CPT', 'Cape Town International', (SELECT id FROM public."Cities" WHERE code = 'CTW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CRW', 'Yeager Arpt', (SELECT id FROM public."Cities" WHERE code = 'CHS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CSG', 'Columbus Metro Ft Benning Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CUN', 'Cancun Aeropuerto Internacional', (SELECT id FROM public."Cities" WHERE code = 'CUN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CUS', 'Columbus Municipal', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CWB', 'Afonso Pena Arpt', (SELECT id FROM public."Cities" WHERE code = 'CWB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CXH', 'Coal Harbor Sea Plane Arpt', (SELECT id FROM public."Cities" WHERE code = 'VAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CYR', 'Colonia Arpt', (SELECT id FROM public."Cities" WHERE code = 'CYR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CZM', 'Aeropuerto Intl De Cozumel', (SELECT id FROM public."Cities" WHERE code = 'CZM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DAC', 'Zia Intl Airport', (SELECT id FROM public."Cities" WHERE code = 'DAC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DAL', 'Love Field', (SELECT id FROM public."Cities" WHERE code = 'DFW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DAR', 'Es Salaam Intl', (SELECT id FROM public."Cities" WHERE code = 'DAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DAY', 'Dayton International Airport', (SELECT id FROM public."Cities" WHERE code = 'DAY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DBN', 'Dublin Municipal Arpt', (SELECT id FROM public."Cities" WHERE code = 'DUB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DEL', 'Delhi Indira Gandhi Intl', (SELECT id FROM public."Cities" WHERE code = 'DEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DEN', 'Denver Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'DEN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DET', 'Detroit City Apt', (SELECT id FROM public."Cities" WHERE code = 'DTT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DFW', 'Dallas Ft Worth Intl', (SELECT id FROM public."Cities" WHERE code = 'DFW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DHA', 'Dhahran Intl', (SELECT id FROM public."Cities" WHERE code = 'DHA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DKR', 'Yoff Airport', (SELECT id FROM public."Cities" WHERE code = 'DKR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DLA', 'Douala Arpt', (SELECT id FROM public."Cities" WHERE code = 'DLA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DLC', 'Dalian Airport', (SELECT id FROM public."Cities" WHERE code = 'DLC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DOH', 'Doha Airport', (SELECT id FROM public."Cities" WHERE code = 'DOH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DPS', 'Ngurah Rai Arpt', (SELECT id FROM public."Cities" WHERE code = 'DPS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DTW', 'Detroit Metro Arpt', (SELECT id FROM public."Cities" WHERE code = 'DTT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DUB', 'Dublin Arpt', (SELECT id FROM public."Cities" WHERE code = 'DUB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DUR', 'Durban International', (SELECT id FROM public."Cities" WHERE code = 'DUR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DUS', 'Dusseldorf Arpt', (SELECT id FROM public."Cities" WHERE code = 'DUS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DWH', 'David Wayne Hooks Arpt', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DXB', 'Dubai Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'DXB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('EAP', 'Mulhouse/Basel Airports', (SELECT id FROM public."Cities" WHERE code = 'MLH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('EFD', 'Ellington Field', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ERS', 'Eros Arpt', (SELECT id FROM public."Cities" WHERE code = 'WDH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ESB', 'Esenboga Arpt', (SELECT id FROM public."Cities" WHERE code = 'ANK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('EWR', 'Newark Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'EWR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('EZE', 'Ministro Pistarini', (SELECT id FROM public."Cities" WHERE code = 'BUE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FAO', 'Faro Airport', (SELECT id FROM public."Cities" WHERE code = 'FAO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FBM', 'Luano', (SELECT id FROM public."Cities" WHERE code = 'FBM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FBU', 'Fornebu Arpt', (SELECT id FROM public."Cities" WHERE code = 'OSL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FIH', 'Kinshasa Arpt', (SELECT id FROM public."Cities" WHERE code = 'FIH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FNA', 'Lungi Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'FNA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FOR', 'Pinto Martines Arpt', (SELECT id FROM public."Cities" WHERE code = 'FOR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FPO', 'Freeport Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'FPO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FRA', 'Frankfurt Intl', (SELECT id FROM public."Cities" WHERE code = 'FRA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FTY', 'Fulton Cty Arpt', (SELECT id FROM public."Cities" WHERE code = 'ATL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('FUK', 'Itazuke Arpt', (SELECT id FROM public."Cities" WHERE code = 'FUK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GBE', 'Gaborone Arpt', (SELECT id FROM public."Cities" WHERE code = 'GBE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GDL', 'Miguel Hidalgo Arpt', (SELECT id FROM public."Cities" WHERE code = 'GDL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GED', 'Sussex County Arpt', (SELECT id FROM public."Cities" WHERE code = 'GEO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GEN', 'Gardermoen Arpt', (SELECT id FROM public."Cities" WHERE code = 'OSL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GEO', 'Timehri Airport', (SELECT id FROM public."Cities" WHERE code = 'GEO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GGW', 'International Glasgow', (SELECT id FROM public."Cities" WHERE code = 'GLA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GIB', 'North Front Arpt', (SELECT id FROM public."Cities" WHERE code = 'GIB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GIG', 'Rio Internacional', (SELECT id FROM public."Cities" WHERE code = 'RIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GLA', 'Glasgow Arpt', (SELECT id FROM public."Cities" WHERE code = 'GLA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GRX', 'Granada Arpt', (SELECT id FROM public."Cities" WHERE code = 'GND')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GRZ', 'Thalerhof Arpt', (SELECT id FROM public."Cities" WHERE code = 'GRZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GTR', 'Golden Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GYE', 'Simon Bolivar Airport', (SELECT id FROM public."Cities" WHERE code = 'GYE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GYM', 'Gen Jose M Yanez Arpt', (SELECT id FROM public."Cities" WHERE code = 'GYM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('GYN', 'Santa Genoveva', (SELECT id FROM public."Cities" WHERE code = 'GYN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HBA', 'Hobart Arpt', (SELECT id FROM public."Cities" WHERE code = 'HBA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HEL', 'Helsinki Arpt', (SELECT id FROM public."Cities" WHERE code = 'HEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HFD', 'Brainard Arpt', (SELECT id FROM public."Cities" WHERE code = 'BOL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HKG', 'Hong Kong Intl', (SELECT id FROM public."Cities" WHERE code = 'HKG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HKT', 'Phuket Intl Airport', (SELECT id FROM public."Cities" WHERE code = 'HKT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HMA', 'Malmo City Hvc Arpt', (SELECT id FROM public."Cities" WHERE code = 'MMA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HNL', 'Honolulu Intl', (SELECT id FROM public."Cities" WHERE code = 'HNL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HOG', 'Frank Pias Arpt', (SELECT id FROM public."Cities" WHERE code = 'HOG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HOU', 'Houston Hobby Arpt', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('HRE', 'Harare Arpt', (SELECT id FROM public."Cities" WHERE code = 'HRE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IAH', 'Houston Intl', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IBZ', 'Ibiza Airport', (SELECT id FROM public."Cities" WHERE code = 'IBZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IEV', 'Zhulhany Arpt', (SELECT id FROM public."Cities" WHERE code = 'IEV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IOS', 'Eduardo Gomes Airport', (SELECT id FROM public."Cities" WHERE code = 'IOS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IQQ', 'Cavancha Chucumata Arpt', (SELECT id FROM public."Cities" WHERE code = 'IQQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ISB', 'Islamabad Intl', (SELECT id FROM public."Cities" WHERE code = 'ISB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ITM', 'Itami Arpt', (SELECT id FROM public."Cities" WHERE code = 'OSA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('IWS', 'West Houston', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JAJ', 'Perimeter Hlpt', (SELECT id FROM public."Cities" WHERE code = 'ATL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JAO', 'Beaver Ruin Helpt', (SELECT id FROM public."Cities" WHERE code = 'ATL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JBP', 'Commerce Business Plaza Heliport', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JCC', 'China Basin Hlpt', (SELECT id FROM public."Cities" WHERE code = 'SFO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JDP', 'Issy Les Moulineaux Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JED', 'Jeddah Intl', (SELECT id FROM public."Cities" WHERE code = 'JED')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JFK', 'John F Kennedy Intl', (SELECT id FROM public."Cities" WHERE code = 'NYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JKT', 'Kemayoran Arpt', (SELECT id FROM public."Cities" WHERE code = 'JKT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JPA', 'Castro Pinto Arpt', (SELECT id FROM public."Cities" WHERE code = 'JPA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JRE', 'East 60th St Hlpt', (SELECT id FROM public."Cities" WHERE code = 'NYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JRS', 'Atarot Airport', (SELECT id FROM public."Cities" WHERE code = 'JRS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('JTO', 'Thousand Oaks Hlpt', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KAN', 'Aminu Kano Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'KAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KBP', 'Borispol Arpt', (SELECT id FROM public."Cities" WHERE code = 'IEV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KGL', 'Kayibanda Arpt', (SELECT id FROM public."Cities" WHERE code = 'KGL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KHH', 'Kaohsiung Intl', (SELECT id FROM public."Cities" WHERE code = 'KHH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KHI', 'Karachi Arpt', (SELECT id FROM public."Cities" WHERE code = 'KHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KIN', 'Norman Manly Arpt', (SELECT id FROM public."Cities" WHERE code = 'KIN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KIX', 'Kansai International Arpt', (SELECT id FROM public."Cities" WHERE code = 'OSA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KLU', 'Klagenfurt Arpt', (SELECT id FROM public."Cities" WHERE code = 'KLU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KRS', 'Kjevik Airport', (SELECT id FROM public."Cities" WHERE code = 'KRS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KRT', 'Civil Arpt', (SELECT id FROM public."Cities" WHERE code = 'KRT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KTP', 'Tinson Arpt', (SELECT id FROM public."Cities" WHERE code = 'KIN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KUL', 'Subang Kuala Lumpur Intl', (SELECT id FROM public."Cities" WHERE code = 'KUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('KWI', 'Kuwait Intl', (SELECT id FROM public."Cities" WHERE code = 'KWI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LAD', 'Four De Fevereiro Arpt', (SELECT id FROM public."Cities" WHERE code = 'LAD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LAP', 'Aeropuerto Gen Marquez De Leon', (SELECT id FROM public."Cities" WHERE code = 'LPB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LAS', 'McCarran Intl', (SELECT id FROM public."Cities" WHERE code = 'LAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LAX', 'Los Angeles Intl', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LBA', 'Leeds Bradford Arpt', (SELECT id FROM public."Cities" WHERE code = 'LBA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LBG', 'Le Bourget Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LBH', 'Palm Beach Arpt', (SELECT id FROM public."Cities" WHERE code = 'SYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LBV', 'Libreville Arpt', (SELECT id FROM public."Cities" WHERE code = 'LBV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LCA', 'Larnaca Intl', (SELECT id FROM public."Cities" WHERE code = 'LCA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LEH', 'Octeville Arpt', (SELECT id FROM public."Cities" WHERE code = 'LHV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LEJ', 'Schkeuditz Arpt', (SELECT id FROM public."Cities" WHERE code = 'LEJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LFW', 'Lome Airport', (SELECT id FROM public."Cities" WHERE code = 'LFW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LGA', 'La Guardia', (SELECT id FROM public."Cities" WHERE code = 'NYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LGB', 'Long Beach Municipal', (SELECT id FROM public."Cities" WHERE code = 'LGB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LIL', 'Lesquin Arpt', (SELECT id FROM public."Cities" WHERE code = 'LIL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LIM', 'Nlima Intl Jorge Chavez', (SELECT id FROM public."Cities" WHERE code = 'LIM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LIN', 'Linate Arpt', (SELECT id FROM public."Cities" WHERE code = 'MIL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LJU', 'Brnik Airport', (SELECT id FROM public."Cities" WHERE code = 'LJU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LKE', 'Lake Union Seaplane Base', (SELECT id FROM public."Cities" WHERE code = 'SEA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LLW', 'Lilongwe Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'LLW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LNZ', 'Hoersching Arpt', (SELECT id FROM public."Cities" WHERE code = 'LNZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LOS', 'Murtala Muhammed Arpt', (SELECT id FROM public."Cities" WHERE code = 'LOS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LPB', 'El Alto Arpt', (SELECT id FROM public."Cities" WHERE code = 'LPB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LSC', 'La Florida', (SELECT id FROM public."Cities" WHERE code = 'LSC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LUN', 'Lusaka Airport', (SELECT id FROM public."Cities" WHERE code = 'LUN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LUQ', 'San Luis Cty Arpt', (SELECT id FROM public."Cities" WHERE code = 'SLZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LVS', 'Las Vegas Arpt', (SELECT id FROM public."Cities" WHERE code = 'LAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('LYS', 'Satolas Airport', (SELECT id FROM public."Cities" WHERE code = 'LYS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MAA', 'Meenambarkkam Arpt', (SELECT id FROM public."Cities" WHERE code = 'MAA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MAD', 'Barajas Arpt', (SELECT id FROM public."Cities" WHERE code = 'MAD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MAH', 'Aerop De Menorca', (SELECT id FROM public."Cities" WHERE code = 'MAH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MAR', 'La Chinita Arpt', (SELECT id FROM public."Cities" WHERE code = 'MAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MBJ', 'Sangster Arpt', (SELECT id FROM public."Cities" WHERE code = 'MBJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MCO', 'Orlando Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'ORL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MCT', 'Seeb Intl', (SELECT id FROM public."Cities" WHERE code = 'MCT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MCZ', 'Palmeres Airport', (SELECT id FROM public."Cities" WHERE code = 'MCZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MDW', 'Midway', (SELECT id FROM public."Cities" WHERE code = 'CHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MEB', 'Essendon Arpt', (SELECT id FROM public."Cities" WHERE code = 'MEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MDE', 'Aeropuerto Internacional Jose Maria Cordoba', (SELECT id FROM public."Cities" WHERE code = 'MDE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MEL', 'Tullamarine Arpt', (SELECT id FROM public."Cities" WHERE code = 'MEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MEM', 'Memphis Intl', (SELECT id FROM public."Cities" WHERE code = 'MEM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MGA', 'Augusto C Sandino', (SELECT id FROM public."Cities" WHERE code = 'MGA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MIA', 'Miami Intl', (SELECT id FROM public."Cities" WHERE code = 'MIA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MID', 'Merida Intl', (SELECT id FROM public."Cities" WHERE code = 'MID')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MIL', 'Milan Airports', (SELECT id FROM public."Cities" WHERE code = 'MIL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MJV', 'San Javier Airport', (SELECT id FROM public."Cities" WHERE code = 'MJV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MKE', 'General Mitchell Fld', (SELECT id FROM public."Cities" WHERE code = 'MKE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MLA', 'Luqa Airport', (SELECT id FROM public."Cities" WHERE code = 'MLA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MLB', 'Melbourne Regional', (SELECT id FROM public."Cities" WHERE code = 'MEL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MLH', 'Euroairport French', (SELECT id FROM public."Cities" WHERE code = 'MLH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MLW', 'Sprigg Payne Arpt', (SELECT id FROM public."Cities" WHERE code = 'MLW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MMA', 'Malmo Airports', (SELECT id FROM public."Cities" WHERE code = 'MMA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MME', 'Teesside Arpt', (SELECT id FROM public."Cities" WHERE code = 'MME')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MMX', 'Sturup Arpt', (SELECT id FROM public."Cities" WHERE code = 'MMA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MNL', 'Ninoy Aquino Intl', (SELECT id FROM public."Cities" WHERE code = 'MNL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MPM', 'Maputo Intl', (SELECT id FROM public."Cities" WHERE code = 'MPM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MRD', 'Alberto Carnevalli Arpt', (SELECT id FROM public."Cities" WHERE code = 'MID')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MSP', 'Minneapolis St Paul Intl', (SELECT id FROM public."Cities" WHERE code = 'MSP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MSY', 'Moisant Intl', (SELECT id FROM public."Cities" WHERE code = 'MSY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MTC', 'Selfridge Air Natl Guard', (SELECT id FROM public."Cities" WHERE code = 'DTT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MTY', 'Escobedo Arpt', (SELECT id FROM public."Cities" WHERE code = 'MTY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MUC', 'Franz Josef Strauss Arpt', (SELECT id FROM public."Cities" WHERE code = 'MUC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MVD', 'Carrasco Arpt', (SELECT id FROM public."Cities" WHERE code = 'MVD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MXP', 'Malpensa Arpt', (SELECT id FROM public."Cities" WHERE code = 'MIL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MYF', 'Montogomery Fld', (SELECT id FROM public."Cities" WHERE code = 'SAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MZO', 'Sierra Maestra Arpt', (SELECT id FROM public."Cities" WHERE code = 'ZLO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('MZT', 'Buelina Arpt', (SELECT id FROM public."Cities" WHERE code = 'MZT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NAN', 'Nadi Intl', (SELECT id FROM public."Cities" WHERE code = 'NAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NAS', 'Nassau Intl', (SELECT id FROM public."Cities" WHERE code = 'NAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NAT', 'Augusto Severo Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'NAT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NBO', 'Jomo Kenyatta Intl', (SELECT id FROM public."Cities" WHERE code = 'NBO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NEW', 'New Lakefront Arpt', (SELECT id FROM public."Cities" WHERE code = 'MSY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NGO', 'Komaki Arpt', (SELECT id FROM public."Cities" WHERE code = 'NGO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NIM', 'Niamey Airport', (SELECT id FROM public."Cities" WHERE code = 'NIM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NKC', 'Nouakchott Arpt', (SELECT id FROM public."Cities" WHERE code = 'NKC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NQA', 'Memphis Naval Air Station', (SELECT id FROM public."Cities" WHERE code = 'MEM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NSI', 'Nsimalen Arpt', (SELECT id FROM public."Cities" WHERE code = 'YAO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('NYC', 'New York City Area Airports', (SELECT id FROM public."Cities" WHERE code = 'NYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OFK', 'Karl Stefan Fld', (SELECT id FROM public."Cities" WHERE code = 'NOR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OKA', 'Naha Field', (SELECT id FROM public."Cities" WHERE code = 'OKA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OLU', 'Columbus Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OPF', 'Opa Locka Arpt', (SELECT id FROM public."Cities" WHERE code = 'MIA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ORD', 'OHare Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'CHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ORL', 'Herndon Arpt', (SELECT id FROM public."Cities" WHERE code = 'ORL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ORY', 'Orly Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OSA', 'Osaka', (SELECT id FROM public."Cities" WHERE code = 'OSA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OSL', 'Oslo Airports', (SELECT id FROM public."Cities" WHERE code = 'OSL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('OSU', 'Ohio State Univ Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PAP', 'Mais Gate Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PAR', 'Paris Airports', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PBM', 'Zanderij Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'PBM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PDK', 'Dekalb Peachtree', (SELECT id FROM public."Cities" WHERE code = 'ATL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PDP', 'Cap Curbelo Arpt', (SELECT id FROM public."Cities" WHERE code = 'PDP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PDX', 'Portland Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'PDX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PEK', 'Beijing Capital Arpt', (SELECT id FROM public."Cities" WHERE code = 'BJS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PEN', 'Penang Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'PEN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PER', 'Perth Arpt', (SELECT id FROM public."Cities" WHERE code = 'PER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PFO', 'Paphos Intl Airport', (SELECT id FROM public."Cities" WHERE code = 'PFO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PHT', 'Henry County Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PHX', 'Sky Harbor Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'PHX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PID', 'Paradise Island Arpt', (SELECT id FROM public."Cities" WHERE code = 'NAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PIK', 'Prestwick Arpt', (SELECT id FROM public."Cities" WHERE code = 'GLA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PLZ', 'Port Elizabeth Airport', (SELECT id FROM public."Cities" WHERE code = 'PEZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PMC', 'Tepual Airport', (SELECT id FROM public."Cities" WHERE code = 'PMC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PMO', 'Punta Raisi Arpt', (SELECT id FROM public."Cities" WHERE code = 'PMO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PMV', 'Delcaribe Gen S Marino Arpt', (SELECT id FROM public."Cities" WHERE code = 'PMV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PNA', 'Pamplona Noain Arpt', (SELECT id FROM public."Cities" WHERE code = 'PNA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('POA', 'Porto Alegre Airport', (SELECT id FROM public."Cities" WHERE code = 'POA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PPT', 'Intl Tahiti Faaa', (SELECT id FROM public."Cities" WHERE code = 'PPT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PRX', 'Paris Cox Field Arpt', (SELECT id FROM public."Cities" WHERE code = 'PAR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PRY', 'Wonderboom Arpt', (SELECT id FROM public."Cities" WHERE code = 'PRY')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PSK', 'New River Valley Arpt', (SELECT id FROM public."Cities" WHERE code = 'DUB')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PTJ', 'Portland Arpt', (SELECT id FROM public."Cities" WHERE code = 'PDX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PUQ', 'Presidente Ibanez Arpt', (SELECT id FROM public."Cities" WHERE code = 'PUQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PVR', 'Ordaz Arpt', (SELECT id FROM public."Cities" WHERE code = 'PVR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PWK', 'Pal Waukee Arpt', (SELECT id FROM public."Cities" WHERE code = 'CHI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('PWM', 'Portland Intl Jetport', (SELECT id FROM public."Cities" WHERE code = 'PDX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QBA', 'San Francisco Bay Area Airpts', (SELECT id FROM public."Cities" WHERE code = 'SFO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QDF', 'Dallas Area Airports', (SELECT id FROM public."Cities" WHERE code = 'DFW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QGV', 'Neu Isenburg Arpt', (SELECT id FROM public."Cities" WHERE code = 'FRA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QHO', 'Houston Airports', (SELECT id FROM public."Cities" WHERE code = 'HOU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QKN', 'Kingston Airports', (SELECT id FROM public."Cities" WHERE code = 'KIN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QLA', 'Los Angeles Area Airports', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QMI', 'Miami Area Airports', (SELECT id FROM public."Cities" WHERE code = 'MIA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QRV', 'Arras Arpt', (SELECT id FROM public."Cities" WHERE code = 'LIL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('QSE', 'Seattle Area Airports', (SELECT id FROM public."Cities" WHERE code = 'SEA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RAC', 'Horlick Arpt', (SELECT id FROM public."Cities" WHERE code = 'MKE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RAK', 'Menara Airport', (SELECT id FROM public."Cities" WHERE code = 'RAK')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RBA', 'Sale Airport', (SELECT id FROM public."Cities" WHERE code = 'RBA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RDU', 'Raleigh Durham Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'RDU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('REC', 'Recife Airport', (SELECT id FROM public."Cities" WHERE code = 'REC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RIC', 'Byrd Intl', (SELECT id FROM public."Cities" WHERE code = 'RIC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RIO', 'Rio De Janeiro Airports', (SELECT id FROM public."Cities" WHERE code = 'RIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RMA', 'Roma Arpt', (SELECT id FROM public."Cities" WHERE code = 'ROM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ROB', 'Roberts Intl', (SELECT id FROM public."Cities" WHERE code = 'MLW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ROC', 'Monroe Cty Arpt New York', (SELECT id FROM public."Cities" WHERE code = 'ROC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RSE', 'Au Rose Bay Arpt', (SELECT id FROM public."Cities" WHERE code = 'SYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RST', 'Rochester Municipal', (SELECT id FROM public."Cities" WHERE code = 'ROC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('RUH', 'King Khaled Intl', (SELECT id FROM public."Cities" WHERE code = 'RUH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SAL', 'El Salvador Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SAL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SAN', 'Lindbergh Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SAP', 'La Mesa Airport', (SELECT id FROM public."Cities" WHERE code = 'SAP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SAT', 'San Antonio Intl', (SELECT id FROM public."Cities" WHERE code = 'SAI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SAV', 'Travis Field', (SELECT id FROM public."Cities" WHERE code = 'SAV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDA', 'Saddam Intl', (SELECT id FROM public."Cities" WHERE code = 'BGW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDM', 'Brown Fld Municipal', (SELECT id FROM public."Cities" WHERE code = 'SAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDQ', 'Las Americas Arpt', (SELECT id FROM public."Cities" WHERE code = 'SDQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDR', 'Santander Airport', (SELECT id FROM public."Cities" WHERE code = 'SDR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDU', 'Santos Dumont Arpt', (SELECT id FROM public."Cities" WHERE code = 'RIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SDV', 'Dov Airport', (SELECT id FROM public."Cities" WHERE code = 'TLV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SEA', 'Seattle Tacoma Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SEA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SEZ', 'Seychelles Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SEZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SFO', 'San Francisco Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SFO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SHA', 'Shanghai Intl Hongqiao', (SELECT id FROM public."Cities" WHERE code = 'SHA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SHJ', 'Sharjah Airport', (SELECT id FROM public."Cities" WHERE code = 'SHJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SJJ', 'Butmir Arpt', (SELECT id FROM public."Cities" WHERE code = 'SJJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SLC', 'Salt Lake City Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'SLC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SMO', 'Santa Monica Municipal Arpt', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SNN', 'Shannon Arpt', (SELECT id FROM public."Cities" WHERE code = 'SNN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SOF', 'Sofia Intl', (SELECT id FROM public."Cities" WHERE code = 'SOF')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SSA', 'Dois De Julho Arpt', (SELECT id FROM public."Cities" WHERE code = 'SSA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('STD', 'Mayor Humberto Vivas Guerrero Arpt', (SELECT id FROM public."Cities" WHERE code = 'SDQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('STR', 'Eghterdingen Arpt', (SELECT id FROM public."Cities" WHERE code = 'STR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SUV', 'Nausori Airport', (SELECT id FROM public."Cities" WHERE code = 'SUV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SVG', 'Sola Airport', (SELECT id FROM public."Cities" WHERE code = 'SVG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SVQ', 'San Pablo Arpt', (SELECT id FROM public."Cities" WHERE code = 'SVQ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SVZ', 'San Antonio Arpt', (SELECT id FROM public."Cities" WHERE code = 'SAI')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SXF', 'Schoenefeld Arpt', (SELECT id FROM public."Cities" WHERE code = 'VER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('SYD', 'Sydney Kingsford Smith Arpt', (SELECT id FROM public."Cities" WHERE code = 'SYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TAM', 'General F Javier Mina', (SELECT id FROM public."Cities" WHERE code = 'TAM')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TGU', 'Toncontin Arpt', (SELECT id FROM public."Cities" WHERE code = 'TGU')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('THF', 'Tempelhof Arpt', (SELECT id FROM public."Cities" WHERE code = 'VER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('THR', 'Mehrabad Arpt', (SELECT id FROM public."Cities" WHERE code = 'THR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TIA', 'Rinas Arpt', (SELECT id FROM public."Cities" WHERE code = 'TIA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TLV', 'Ben Gurion Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'TLV')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TMB', 'Tamiami Airport', (SELECT id FROM public."Cities" WHERE code = 'MIA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TPA', 'Tampa Intl', (SELECT id FROM public."Cities" WHERE code = 'TPA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TPE', 'Chiang Kai Shek Arpt', (SELECT id FROM public."Cities" WHERE code = 'TPE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TPF', 'Peter O Knight Arpt', (SELECT id FROM public."Cities" WHERE code = 'TPA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TSR', 'Timisoara Arpt', (SELECT id FROM public."Cities" WHERE code = 'TSR')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TSS', 'East 34th St Hlpt', (SELECT id FROM public."Cities" WHERE code = 'NYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TUS', 'Tucson Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'TUS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('TXL', 'Tegel Airport', (SELECT id FROM public."Cities" WHERE code = 'VER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('UBS', 'Lowndes Cty Arpt', (SELECT id FROM public."Cities" WHERE code = 'CMH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('UIO', 'Mariscal Arpt', (SELECT id FROM public."Cities" WHERE code = 'UIO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('UIZ', 'Berz Macomb Arpt', (SELECT id FROM public."Cities" WHERE code = 'DTT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VCT', 'Victoria Regional Arpt', (SELECT id FROM public."Cities" WHERE code = 'YYJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VER', 'Las Bajadas General Heriberto Jara', (SELECT id FROM public."Cities" WHERE code = 'VER')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VGO', 'Vigo Airport', (SELECT id FROM public."Cities" WHERE code = 'VGO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VGT', 'Las Vegas North Air Terminal', (SELECT id FROM public."Cities" WHERE code = 'LAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VIT', 'Vitoria Arpt', (SELECT id FROM public."Cities" WHERE code = 'VIX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VIX', 'Eurico Sales Arpt', (SELECT id FROM public."Cities" WHERE code = 'VIX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VLC', 'Valencia Arpt', (SELECT id FROM public."Cities" WHERE code = 'VLC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VNY', 'Los Angeles Van Nuys Arpt', (SELECT id FROM public."Cities" WHERE code = 'LAX')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VPZ', 'Porter County', (SELECT id FROM public."Cities" WHERE code = 'VAP')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('VRA', 'Juan Gualberto Gomez Arpt', (SELECT id FROM public."Cities" WHERE code = 'VRA')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('WDH', 'Windhoek Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'WDH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('WIL', 'Wilson Airport', (SELECT id FROM public."Cities" WHERE code = 'NBO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('WLG', 'Wellington Intl', (SELECT id FROM public."Cities" WHERE code = 'WLG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('WZY', 'Seaplane Base Arpt', (SELECT id FROM public."Cities" WHERE code = 'NAS')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YAO', 'Yaounde Airport', (SELECT id FROM public."Cities" WHERE code = 'YAO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YBZ', 'Downtown Hlpt Toronto', (SELECT id FROM public."Cities" WHERE code = 'YTO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YEA', 'Edmonton Airports', (SELECT id FROM public."Cities" WHERE code = 'YEG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YED', 'Namao Field', (SELECT id FROM public."Cities" WHERE code = 'YEG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YEG', 'Edmonton Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YEG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YGK', 'Norman Rodgers Arpt', (SELECT id FROM public."Cities" WHERE code = 'KIN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YHU', 'St Hubert Arpt', (SELECT id FROM public."Cities" WHERE code = 'YUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YIP', 'Willow Run Arpt', (SELECT id FROM public."Cities" WHERE code = 'DTT')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YKZ', 'Buttonville Arpt', (SELECT id FROM public."Cities" WHERE code = 'YTO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YMQ', 'Montreal Airports', (SELECT id FROM public."Cities" WHERE code = 'YUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YMX', 'Mirabel Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YMY', 'Victoria Stol', (SELECT id FROM public."Cities" WHERE code = 'YUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YOW', 'Ottawa Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YOW')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YQF', 'Red Deer Arpt', (SELECT id FROM public."Cities" WHERE code = 'YYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YQG', 'Windsor Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YQG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YQY', 'Sydney Airport', (SELECT id FROM public."Cities" WHERE code = 'SYD')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YTO', 'Toronto Area Airports', (SELECT id FROM public."Cities" WHERE code = 'YTO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YTZ', 'Toronto City Centre Airport', (SELECT id FROM public."Cities" WHERE code = 'YTO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YUL', 'Dorval Intl', (SELECT id FROM public."Cities" WHERE code = 'YUL')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YVR', 'Vancouver Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'VAN')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YWG', 'Winnipeg Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YWG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YWH', 'Inner Harbor Sea Plane Arpt', (SELECT id FROM public."Cities" WHERE code = 'YYJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YXD', 'Edmonton Municipal Arpt', (SELECT id FROM public."Cities" WHERE code = 'YEG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YYC', 'Calgary Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YYC')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YYJ', 'Victoria Intl Arpt', (SELECT id FROM public."Cities" WHERE code = 'YYJ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('YYZ', 'Lester B Pearson Intl', (SELECT id FROM public."Cities" WHERE code = 'YTO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ZAG', 'Zagreb Arpt', (SELECT id FROM public."Cities" WHERE code = 'ZAG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ZAZ', 'Zaragoza Airport', (SELECT id FROM public."Cities" WHERE code = 'ZAZ')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ZCO', 'Manquehue Arpt', (SELECT id FROM public."Cities" WHERE code = 'ZCO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ZLO', 'Aeropuerto Intl', (SELECT id FROM public."Cities" WHERE code = 'ZLO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('ZRH', 'Zurich Airport', (SELECT id FROM public."Cities" WHERE code = 'ZRH')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CTG', 'Aeropuerto Internacional Rafael Nunez', (SELECT id FROM public."Cities" WHERE code = 'CTG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BOG', 'Aeropuerto Internacional El Dorado', (SELECT id FROM public."Cities" WHERE code = 'BOG')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('CLO', 'Alfonso Bonilla Arag¢n', (SELECT id FROM public."Cities" WHERE code = 'CLO')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('DIM', 'Aeropuerto Olaya Herrera', (SELECT id FROM public."Cities" WHERE code = 'MDE')) ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Airports" (code, name, "citiesId") VALUES ('BAQ', 'AEROPUERTO ERNESTO CORTIZO', (SELECT id FROM public."Cities" WHERE code = 'BAQ')) ON CONFLICT (code) DO NOTHING;

-- 22. CellCustomizations (Initial inserts for default celdas mapping for BOG)
DO $$
DECLARE
    v_branch_id integer;
BEGIN
    SELECT id INTO v_branch_id FROM public."Branch" WHERE code = 'BOG' LIMIT 1;
    IF v_branch_id IS NOT NULL THEN
        INSERT INTO public."CellCustomization" (code, name, value, "branchId", "implantId") VALUES
        ('idCotizacion', 'ID Cotización', 'B2', v_branch_id, NULL),
        ('asesor', 'Asesor', 'B4', v_branch_id, NULL),
        ('fecha', 'Fecha', 'G4', v_branch_id, NULL),
        ('clienteNombre', 'Cliente Nombre', 'B7', v_branch_id, NULL),
        ('clienteIdentificacion', 'Cliente ID', 'G7', v_branch_id, NULL),
        ('clienteDireccion', 'Dirección', 'B8', v_branch_id, NULL),
        ('clienteTelefono', 'Teléfono', 'G8', v_branch_id, NULL),
        ('centroCosto', 'C. Costo', 'B9', v_branch_id, NULL),
        ('solicita', 'Solicita', 'G9', v_branch_id, NULL),
        ('tCambio', 'T. Cambio', 'I11', v_branch_id, NULL),
        ('descripcionPlan', 'Desc Plan', 'B12', v_branch_id, NULL),
        ('fechasViaje', 'Fechas Viaje', 'G12', v_branch_id, NULL),
        ('hotelesServicios', 'Servicios', 'A13', v_branch_id, NULL),
        ('pasajeros', 'Pasajeros', 'B14', v_branch_id, NULL),
        ('totalAdultos', 'Total Adultos', 'C15', v_branch_id, NULL),
        ('totalNinos', 'Total Niños', 'G15', v_branch_id, NULL),
        ('logo', 'Celda Logo', 'A1', v_branch_id, NULL),
        ('proveedor1Nombre', 'Prov 1: Nombre', 'B18', v_branch_id, NULL),
        ('proveedor1NIT', 'Prov 1: NIT', 'E18', v_branch_id, NULL),
        ('proveedor1Contacto', 'Prov 1: Contacto', 'H18', v_branch_id, NULL),
        ('prov1TarifaNeta', 'Prov 1: Neta', 'B23', v_branch_id, NULL),
        ('prov1TarifaNetaPago', 'Prov 1: Neta Pago', 'D23', v_branch_id, NULL),
        ('prov1Impuestos', 'Prov 1: Impuestos', 'B24', v_branch_id, NULL),
        ('prov1ImpuestosPago', 'Prov 1: Impuestos Pago', 'D24', v_branch_id, NULL),
        ('prov1Adicionales', 'Prov 1: Adicionales', 'B25', v_branch_id, NULL),
        ('prov1AdicionalesPago', 'Prov 1: Adicionales Pago', 'D25', v_branch_id, NULL),
        ('prov1Comision', 'Prov 1: Comisión', 'B26', v_branch_id, NULL),
        ('prov1Descuento', 'Prov 1: Descuento', 'B27', v_branch_id, NULL),
        ('prov1Sobrecomision', 'Prov 1: Sobrecomisión', 'B28', v_branch_id, NULL),
        ('prov1Fee', 'Prov 1: Fee', 'B29', v_branch_id, NULL),
        ('prov1Total', 'Prov 1: Total', 'B30', v_branch_id, NULL),
        ('prov1TotalPago', 'Prov 1: Total Pago', 'D30', v_branch_id, NULL),
        ('proveedor2Nombre', 'Prov 2: Nombre', 'B19', v_branch_id, NULL),
        ('proveedor2NIT', 'Prov 2: NIT', 'E19', v_branch_id, NULL),
        ('proveedor2Contacto', 'Prov 2: Contacto', 'H29', v_branch_id, NULL),
        ('prov2TarifaNeta', 'Prov 2: Neta', 'G23', v_branch_id, NULL),
        ('prov2TarifaNetaPago', 'Prov 2: Neta Pago', 'I23', v_branch_id, NULL),
        ('prov2Impuestos', 'Prov 2: Impuestos', 'G24', v_branch_id, NULL),
        ('prov2ImpuestosPago', 'Prov 2: Impuestos Pago', 'I24', v_branch_id, NULL),
        ('prov2Adicionales', 'Prov 2: Adicionales', 'G25', v_branch_id, NULL),
        ('prov2AdicionalesPago', 'Prov 2: Adicionales Pago', 'I25', v_branch_id, NULL),
        ('prov2Comision', 'Prov 2: Comisión', 'G26', v_branch_id, NULL),
        ('prov2Descuento', 'Prov 2: Descuento', 'G27', v_branch_id, NULL),
        ('prov2Sobrecomision', 'Prov 2: Sobrecomisión', 'G28', v_branch_id, NULL),
        ('prov2Fee', 'Prov 2: Fee', 'G29', v_branch_id, NULL),
        ('prov2Total', 'Prov 2: Total', 'G30', v_branch_id, NULL),
        ('prov2TotalPago', 'Prov 2: Total Pago', 'I30', v_branch_id, NULL),
        ('tarifaNeta', 'Total: Tarifa Neta', '', v_branch_id, NULL),
        ('tarifaNetaPago', 'Total: Neta Pago', '', v_branch_id, NULL),
        ('impuestos', 'Total: Impuestos', '', v_branch_id, NULL),
        ('impuestosPago', 'Total: Impuestos Pago', '', v_branch_id, NULL),
        ('adicionalesServ', 'Total: Adicionales', '', v_branch_id, NULL),
        ('adicionalesServPago', 'Total: Adicionales Pago', '', v_branch_id, NULL),
        ('comision', 'Total: Comisión', '', v_branch_id, NULL),
        ('descuento', 'Total: Descuento', '', v_branch_id, NULL),
        ('sobrecomision', 'Total: Sobrecomisión', '', v_branch_id, NULL),
        ('fee', 'Total: Fee', '', v_branch_id, NULL),
        ('total', 'Total: Total', '', v_branch_id, NULL),
        ('totalPago', 'Total: Total Pago', '', v_branch_id, NULL),
        ('baseComisionable', 'Base Comisión', 'B35', v_branch_id, NULL),
        ('comisionAsesor', 'Comisión Asesor', 'B36', v_branch_id, NULL),
        ('baseComisionTop', 'Comisión Top', 'B37', v_branch_id, NULL),
        ('observaciones', 'Observaciones', 'B42', v_branch_id, NULL)
        ON CONFLICT ("branchId", "code") WHERE "branchId" IS NOT NULL DO NOTHING;
    END IF;
END $$;

-- 11. Datos Iniciales para la tabla Menu
INSERT INTO public."Menu" (code, name, parent, action, activo)
VALUES 
    ('DASHBOARD', 'Dashboard', NULL, '/dashboard', true),
    ('COTIZACIONES', 'Cotizaciones', NULL, '/dashboard/quotations/history', true),
    ('FACTURACION', 'Facturación', NULL, '/dashboard/invoices/history', true),
    ('MAESTROS', 'Maestros', NULL, '/dashboard/settings', true),
    ('REPORTES', 'Reportes', NULL, '/dashboard/reports', true)
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    parent = EXCLUDED.parent,
    action = EXCLUDED.action,
    activo = EXCLUDED.activo;

-- 12. Estados de Cotización Iniciales
INSERT INTO public."QuotationState" (code, name, color)
VALUES
    ('NUEVO', 'Nuevo', 'blue'),
    ('ENVIADO', 'ENVIADO', 'emerald')
ON CONFLICT (code) DO NOTHING;
INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Equivalences', 'equivalencias', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Cities', 'ciudades', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('QuotationState', 'estados-cotizacion', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('CreditCard', 'tarjetas-credito', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('MasterVariable', 'variables', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Payment', 'formas-pago', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('TicketType', 'tipos-tiquetes', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('SystemLog', 'logs', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Airports', 'aeropuertos', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Combo', 'combos', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('QuotationFormat', 'formatos-cotizacion', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Countries', 'paises', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('User', 'usuarios', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('ProviderType', 'tipos-proveedores', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('DocumentResolution', 'resoluciones-documentos', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('TransactionConsecutive', 'consecutivos-transacciones', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('InterfaceExtractParam', 'extraccion-interfaces', false) ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('LICENSE_KEY', 'Clave de Licencia del Sistema', 'KOR1.eyJjIjoiS09SRVggQUdFTkNJQSBQUlVFQkEiLCJuIjoiNzk4OTg0NTYiLCJlIjoiMjAyNi0wOS0xOCIsImkiOiIyMDI2LTA4LTE4In0.c33014ec4605e0dfe9fa66a7bfaeb738875c88e030934e9212f75e72686a99b7') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('LICENSE_EXPIRATION_DATE', 'Fecha de Expiración de Licencia', '2026-09-18') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PRODUCTO_RESERVA_GDS', 'Producto por Defecto para Reservas GDS', 'TAN') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('AGENCY_NAME', 'Nombre o Razón Social de la Agencia', 'KOREX AGENCIA PRUEBA') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('AGENCY_NIT', 'NIT de la Agencia', '79898456') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TASA_CAMBIO_IATA', 'Tasa de Cambio IATA', '4200.00') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_OW', 'Tarifa Administrativa Nacional One Way', '29100') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_RT', 'Tarifa Administrativa Nacional Roundtrip', '52800') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('PRODUCTO_TARIFA_ADMINISTRATIVA', 'Producto por Defecto para Tarifa Administrativa', '77') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) VALUES ('TARIFA_ADMIN_INT_RANGES', 'Rangos Tarifa Administrativa Internacional (JSON)', '[{"min":0,"max":354,"feeUsd":15,"label":"Menores o iguales a USD 354"},{"min":354.01,"max":590,"feeUsd":28,"label":"Mayores de USD 354 hasta USD 590"},{"min":590.01,"max":944,"feeUsd":46,"label":"Mayores de USD 590 hasta USD 944"},{"min":944.01,"max":999999,"feeUsd":95,"label":"Mayores de USD 944"}]') ON CONFLICT (code) DO NOTHING;

INSERT INTO public."Master" (code, name, "inactivo") VALUES ('Diagnostics', 'diagnostico', false) ON CONFLICT (code) DO NOTHING;
