-- ============================================================================
-- AGENCIASNEW - SEMILLAS MAESTRAS E INICIALES PARA BASE EN BLANCO (SQL SERVER)
-- Archivo: SQL/SqlServer/02_Seeds.sql
-- Motor: Microsoft SQL Server 2016+ (T-SQL)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Roles Iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'SUPERADMINISTRADOR' OR UPPER([name]) LIKE '%SUPERADMIN%')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'SUPERADMINISTRADOR', N'Super Administrador de la plataforma con privilegios de gestión de módulos del sitio y asignación de superadministradores', N'{"all": true, "superadmin": true}', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'Administrador')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'Administrador', N'Rol administrador de la plataforma', N'{"all": true}', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Role] WHERE [name] = N'Agente')
BEGIN
    INSERT INTO dbo.[Role] ([name], [description], [permissions], [isActive])
    VALUES (N'Agente', N'Rol de agente de ventas y cotizaciones', N'{"quotations": true}', 1);
END;

-- 2. Parámetros del Sistema Requeridos
IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ServidorSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ServidorSQLServer', N'Host de SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'BaseSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'BaseSQLServer', N'Base de Datos SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'UsuarioSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'UsuarioSQLServer', N'Usuario SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ClaveSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ClaveSQLServer', N'Contraseña SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EncriptarClaves')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EncriptarClaves', N'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', N'0');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PuertoSQLServer')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PuertoSQLServer', N'Puerto SQL Server', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarCotizacionesAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarCotizacionesAutoSQLserver', N'Envío automático de cotizaciones a SQL Server (1: Sí, 0: No)', N'0');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'EnviarFacturacionAutoSQLserver')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'EnviarFacturacionAutoSQLserver', N'Envío automático a Facturacion SQL Server (1: Sí, 0: No)', N'0');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'ModoFacturacionAuto')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'ModoFacturacionAuto', N'Modo de Facturación Automática (Zeus/Local)', N'FALSE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'AGENCY_NAME')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'AGENCY_NAME', N'Nombre o Razón Social de la Agencia', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'AGENCY_NIT')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'AGENCY_NIT', N'NIT de la Agencia', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TASA_CAMBIO_IATA')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TASA_CAMBIO_IATA', N'Tasa de Cambio IATA', N'4200.00');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_OW')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_OW', N'Tarifa Administrativa Nacional One Way', N'29100');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_RT')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_RT', N'Tarifa Administrativa Nacional Roundtrip', N'52800');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PRODUCTO_TARIFA_ADMINISTRATIVA')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PRODUCTO_TARIFA_ADMINISTRATIVA', N'Producto por Defecto para Tarifa Administrativa', N'77');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TARIFA_ADMIN_INT_RANGES')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'TARIFA_ADMIN_INT_RANGES', N'Rangos Tarifa Administrativa Internacional (JSON)', N'[{"min":0,"max":354,"feeUsd":15,"label":"Menores o iguales a USD 354"},{"min":354.01,"max":590,"feeUsd":28,"label":"Mayores de USD 354 hasta USD 590"},{"min":590.01,"max":944,"feeUsd":46,"label":"Mayores de USD 590 hasta USD 944"},{"min":944.01,"max":999999,"feeUsd":95,"label":"Mayores de USD 944"}]');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'PRODUCTO_RESERVA_GDS')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'PRODUCTO_RESERVA_GDS', N'Producto por Defecto para Reservas GDS', N'TAN');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'LICENSE_KEY')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'LICENSE_KEY', N'Clave de Licencia del Sistema', N'');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'LICENSE_EXPIRATION_DATE')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value]) VALUES (N'LICENSE_EXPIRATION_DATE', N'Fecha de Expiración de Licencia', N'');
END;


-- 3. Módulos de Menú de Navegación
IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'quotations')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'quotations', N'Cotizaciones', N'/dashboard/quotations', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'invoices')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'invoices', N'Facturación', N'/dashboard/invoices', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'prequotations')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'prequotations', N'Pre-Cotizaciones', N'/dashboard/prequotations', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'executions')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'executions', N'Ejecuciones', N'/dashboard/executions', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'reports')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'reports', N'Reportes', N'/dashboard/reports', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'settings')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'settings', N'Configuración', N'/dashboard/settings', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'manual')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'manual', N'Manual Operativo', N'/dashboard/manual', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Menu] WHERE [code] = N'DIAGNOSTICS')
BEGIN
    INSERT INTO dbo.[Menu] ([code], [name], [action], [activo]) VALUES (N'DIAGNOSTICS', N'Trazabilidad y Diagnóstico', N'/dashboard/diagnostics', 1);
END;


-- 4. Tablas Maestras del Sitio (Master)
DECLARE @masters TABLE (code NVARCHAR(100), name NVARCHAR(255));
INSERT INTO @masters (code, name) VALUES
(N'Equivalences', N'equivalencias'),
(N'Diagnostics', N'diagnostico'),
(N'SystemParameter', N'parametros'),
(N'User', N'usuarios'),
(N'Branch', N'sucursales'),
(N'Implant', N'implantes'),
(N'ChargeAndTax', N'impuestos'),
(N'Seller', N'vendedores'),
(N'TicketPrinter', N'tiqueteadores'),
(N'Prestadora', N'prestadoras'),
(N'Client', N'clientes'),
(N'Provider', N'proveedores'),
(N'ProviderType', N'tipos-proveedores'),
(N'Product', N'productos'),
(N'MasterVariable', N'variables'),
(N'Combo', N'combos'),
(N'SystemLog', N'logs'),
(N'Currency', N'monedas'),
(N'InterfaceExtractParam', N'extraccion-interfaces'),
(N'DocumentResolution', N'resoluciones-documentos'),
(N'TransactionConsecutive', N'consecutivos-transacciones'),
(N'CreditCard', N'tarjetas-credito'),
(N'Payment', N'formas-pago'),
(N'Countries', N'paises'),
(N'Cities', N'ciudades'),
(N'Airports', N'aeropuertos'),
(N'TicketType', N'tipos-tiquetes'),
(N'QuotationState', N'estados-cotizacion'),
(N'QuotationFormat', N'formatos-cotizacion');

INSERT INTO dbo.[Master] ([code], [name], [inactivo])
SELECT m.code, m.name, 0
FROM @masters m
WHERE NOT EXISTS (SELECT 1 FROM dbo.[Master] target WHERE target.code = m.code);


-- 5. Monedas por Defecto
IF NOT EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = N'COP')
BEGIN
    INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
    VALUES (N'COP', N'Peso Colombiano', 1.0, 0, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[Currency] WHERE [code] = N'USD')
BEGIN
    INSERT INTO dbo.[Currency] ([code], [name], [exchangeRate], [decimals], [isActive])
    VALUES (N'USD', N'Dólar Estadounidense', 4200.0, 2, 1);
END;

-- 5.1 Estados de Cotización Iniciales
IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'NUEVO')
BEGIN
    INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive])
    VALUES (N'NUEVO', N'Nuevo', N'blue', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[QuotationState] WHERE [code] = N'ENVIADO')
BEGIN
    INSERT INTO dbo.[QuotationState] ([code], [name], [color], [isActive])
    VALUES (N'ENVIADO', N'ENVIADO', N'emerald', 1);
END;



-- 6. Usuarios Iniciales de Administración
DECLARE @SuperAdminRoleId INT;
SELECT TOP 1 @SuperAdminRoleId = [id] FROM dbo.[Role] WHERE UPPER([name]) LIKE '%SUPERADMIN%';
IF @SuperAdminRoleId IS NULL
    SET @SuperAdminRoleId = 1;

IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE [email] = N'ebarrera@zagencias.com')
BEGIN
    INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [isActive])
    VALUES (N'Eduardo Barrera', N'ebarrera@zagencias.com', N'$2b$10$e1v0/9V8ZPVqejcqarQfq.hDLlKuva.M/mNsSUxOTefeyuUTqoaW2', @SuperAdminRoleId, 1);
END
ELSE
BEGIN
    UPDATE dbo.[User] SET [roleId] = @SuperAdminRoleId WHERE [email] = N'ebarrera@zagencias.com';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE [email] = N'rubiel1985@msn.com')
BEGIN
    INSERT INTO dbo.[User] ([name], [email], [passwordHash], [roleId], [isActive])
    VALUES (N'Rubiel', N'rubiel1985@msn.com', N'$2b$10$e1v0/9V8ZPVqejcqarQfq.hDLlKuva.M/mNsSUxOTefeyuUTqoaW2', 1, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = N'TRACEABILITY_MODE')
BEGIN
    INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
    VALUES (N'TRACEABILITY_MODE', N'Modo de Trazabilidad y Diagnóstico', N'OFF');
END;

PRINT 'Semillas iniciales inyectadas exitosamente.';

-- ============================================================================
-- 7. MAESTROS GLOBALES (Países, Ciudades, Aeropuertos, Formas de Pago)
-- ============================================================================

-- 7.1 Países (194 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CO', N'Colombia', N'169', N'LA', N'57', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'US') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'US', N'Estados Unidos', N'249', N'NA', N'1', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ES') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ES', N'España', N'245', N'EUR', N'34', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DZ', N'Algeria', N'059', N'AFR', N'213', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DK', N'Denmark', N'232', N'EUR', N'45', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CI', N'Cote d Ivoire', N'193', N'AFR', N'225', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SA', N'Saudi Arabia', N'053', N'MEA', N'966', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NG', N'Nigeria', N'528', N'AFR', N'234', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AU', N'Australia', N'069', N'PAC', N'61', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GB', N'United Kingdom', N'628', N'EUR', N'44', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MX') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MX', N'Mexico', N'493', N'LA', N'52', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GH', N'Ghana', N'289', N'AFR', N'233', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TR', N'Turkey', N'827', N'ASI', N'90', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ET') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ET', N'Ethiopia', N'253', N'AFR', N'251', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'YE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'YE', N'Yemen', N'880', N'MEA', N'967', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AR', N'Argentina', N'063', N'LA', N'54', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RU', N'Russian Federation', N'670', N'EUR', N'7', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NO', N'Norway', N'538', N'EUR', N'47', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IS', N'Iceland', N'379', N'EUR', N'354', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MA', N'Morocco', N'474', N'AFR', N'212', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DE', N'Germany', N'023', N'EUR', N'49', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FR', N'France', N'275', N'EUR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SE', N'Sweden', N'764', N'EUR', N'46', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IN', N'India', N'361', N'ASI', N'91', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ID') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ID', N'Indonesia', N'365', N'ASI', N'62', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IT', N'Italy', N'386', N'EUR', N'39', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CK', N'Cook Islands', N'183', N'PAC', N'682', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BR', N'Brazil', N'105', N'LA', N'55', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NZ', N'New Zealand', N'548', N'PAC', N'64', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KZ', N'Kazakstan', N'406', N'ASI', N'7', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZA', N'South Africa', N'756', N'AFR', N'27', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SY', N'Syrian Arab Republic', N'744', N'MEA', N'963', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AD', N'Andorra', N'037', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EG', N'Egypt', N'240', N'MEA', N'20', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JO', N'Jordan', N'403', N'MEA', N'962', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NL', N'Netherlands', N'573', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CL', N'Chile', N'211', N'LA', N'56', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BE', N'Belgium', N'087', N'EUR', N'32', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AG', N'Antigua and Barbuda', N'043', N'CAR', N'1268', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MY', N'Malaysia', N'455', N'ASI', N'60', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MZ', N'Mozambique', N'505', N'AFR', N'258', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'WS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'WS', N'Samoa', N'687', N'PAC', N'685', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PE', N'Peru', N'589', N'LA', N'51', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JP', N'Japan', N'399', N'ASI', N'81', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ER') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ER', N'Eritrea', N'243', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PY', N'Paraguay', N'586', N'LA', N'595', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BS', N'Bahamas', N'077', N'CAR', N'1242', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GR', N'Greece', N'301', N'EUR', N'30', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AW', N'Aruba', N'027', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AE', N'United Arab Emirates', N'244', N'MEA', N'971', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PF', N'French Polynesia', N'599', N'PAC', N'689', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CU', N'Cuba', N'199', N'CAR', N'53', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AI', N'Anguilla', N'041', N'CAR', N'1264', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PH', N'Philippines', N'267', N'ASI', N'63', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BH', N'Bahrain', N'080', N'ASI', N'973', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AZ', N'Azerbaijan', N'074', N'ASI', N'994', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BW', N'Botswana', N'101', N'AFR', N'267', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RO', N'Romania', N'670', N'EUR', N'40', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BM', N'Bermuda', N'090', N'CAR', N'1441', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'YU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'YU', N'Yugoslavia', N'885', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LB', N'Lebanon', N'431', N'MEA', N'961', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FJ', N'Fiji', N'870', N'PAC', N'679', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CF', N'Central African Republic', N'640', N'AFR', N'236', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BB', N'Barbados', N'083', N'CAR', N'1246', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IQ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IQ', N'Iraq', N'369', N'MEA', N'964', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CN', N'China', N'215', N'ASI', N'86', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MH', N'Marshall Islands', N'472', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GM', N'Gambia', N'285', N'AFR', N'220', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BI', N'Burundi', N'115', N'AFR', N'257', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TH', N'Thailand', N'776', N'ASI', N'66', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ML') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ML', N'Mali', N'464', N'AFR', N'223', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VE', N'Venezuela', N'850', N'LA', N'58', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MW', N'Malawi', N'458', N'AFR', N'265', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AN', N'Netherlands Antilles', N'047', N'CAR', N'31', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CH', N'Switzerland', N'767', N'EUR', N'41', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CZ', N'Czech Republic', N'644', N'EUR', N'420', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DO', N'Dominican Republic', N'647', N'CAR', N'1089', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SK', N'Slovakia', N'246', N'EUR', N'421', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HU', N'Hungary', N'355', N'EUR', N'36', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZW', N'Zimbabwe', N'665', N'AFR', N'263', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CV', N'Cape Verde', N'127', N'AFR', N'238', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BN', N'Brunei Darussalam', N'108', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BZ', N'Belize', N'088', N'LA', N'501', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CG', N'Congo', N'177', N'AFR', N'242', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BO', N'Bolivia', N'097', N'LA', N'591', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HT', N'Haiti', N'341', N'CAR', N'509', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GF', N'French Guiana', N'325', N'LA', N'594', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PT', N'Portugal', N'607', N'EUR', N'351', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GP', N'Guadeloupe', N'309', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IE', N'Ireland', N'375', N'EUR', N'353', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BD', N'Bangladesh', N'081', N'ASI', N'880', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PA', N'Panama', N'580', N'LA', N'507', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KR', N'Korea, Republic Of', N'190', N'ASI', N'82', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GN', N'Guinea', N'329', N'AFR', N'224', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LK', N'Sri Lanka', N'750', N'ASI', N'94', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BJ', N'Benin', N'229', N'AFR', N'229', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EC', N'Ecuador', N'239', N'LA', N'593', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CA', N'Canada', N'149', N'NA', N'1', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KY', N'Cayman Islands', N'137', N'CAR', N'1345', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UY', N'Uruguay', N'845', N'LA', N'598', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TZ', N'Tanzania, United Republic Of', N'780', N'AFR', N'255', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HR', N'Croatia', N'198', N'EUR', N'385', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DM', N'Dominica', N'235', N'CAR', N'1767', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TN', N'Tunisia', N'820', N'AFR', N'216', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SN', N'Senegal', N'728', N'AFR', N'221', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CM', N'Cameroon', N'145', N'AFR', N'237', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VN', N'Vietnam', N'855', N'ASI', N'84', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'QA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'QA', N'Qatar', N'618', N'MEA', N'974', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UG', N'Uganda', N'833', N'AFR', N'256', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CY', N'Cyprus', N'221', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VG', N'Virgin Islands, British', N'863', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NA', N'Namibia', N'507', N'AFR', N'264', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IL', N'Israel', N'383', N'MEA', N'972', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CD', N'Congo, The Democratic Republic Of', N'NULL', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MQ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MQ', N'Martinique', N'477', N'CAR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SL', N'Sierra Leone', N'735', N'AFR', N'232', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GT', N'Guatemala', N'317', N'CAR', N'502', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PL', N'Poland', N'603', N'EUR', N'48', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TC', N'Turks and Caicos Islands', N'823', N'CAR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NC', N'New Caledonia', N'542', N'PAC', N'687', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GI', N'Gibraltar', N'293', N'EUR', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PG', N'Papua New Guinea', N'545', N'PAC', N'675', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GL', N'Greenland', N'305', N'NA', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AT', N'Austria', N'072', N'EUR', N'43', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GU', N'Guam', N'313', N'PAC', N'671', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MT', N'Malta', N'467', N'EUR', N'356', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KM', N'Comoros', N'173', N'AFR', N'269', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TW', N'Taiwan, Province of China', N'218', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PK', N'Pakistan', N'576', N'ASI', N'92', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'FI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'FI', N'Finland', N'271', N'EUR', N'358', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SB') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SB', N'Solomon Islands', N'677', N'PAC', N'677', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HK', N'Hong Kong', N'351', N'ASI', N'852', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UA', N'Ukraine', N'830', N'EUR', N'380', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NU', N'Niue', N'531', N'PAC', N'683', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'DJ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'DJ', N'Djibouti', N'NULL', N'AFR', N'253', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RW', N'Rwanda', N'675', N'AFR', N'250', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'JM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'JM', N'Jamaica', N'391', N'CAR', N'1876', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SD', N'Sudan', N'759', N'AFR', N'249', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NP', N'Nepal', N'517', N'ASI', N'977', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LT', N'Lithuania', N'443', N'EUR', N'9876', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KW', N'Kuwait', N'413', N'MEA', N'965', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AO', N'Angola', N'040', N'AFR', N'244', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GA', N'Gabon', N'281', N'AFR', N'241', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TG', N'Togo', N'800', N'AFR', N'228', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'CR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'CR', N'Costa Rica', N'196', N'LA', N'506', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SI', N'Slovenia', N'247', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ZM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ZM', N'Zambia', N'890', N'AFR', N'260', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LU', N'Luxembourg', N'445', N'EUR', N'352', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KE', N'Kenya', N'410', N'AFR', N'254', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MC', N'Monaco', N'498', N'EUR', N'377', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'OM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'OM', N'Oman', N'556', N'MEA', N'968', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MO', N'Macau', N'447', N'ASI', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NI', N'Nicaragua', N'521', N'LA', N'505', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MV', N'Maldives', N'461', N'ASI', N'960', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LR', N'Liberia', N'434', N'AFR', N'231', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KI') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KI', N'Kiribati', N'411', N'PAC', N'686', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MU', N'Mauritius', N'485', N'AFR', N'230', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BY', N'Belarus', N'091', N'EUR', N'375', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LS', N'Lesotho', N'426', N'AFR', N'266', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SZ', N'Swaziland', N'773', N'AFR', N'268', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MR', N'Mauritania', N'488', N'AFR', N'222', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TD') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TD', N'Chad', N'203', N'AFR', N'235', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KN', N'Saint Kitts and Nevis', N'695', N'CAR', N'1869', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'NE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'NE', N'Niger', N'525', N'AFR', N'227', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BF') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BF', N'Burkina Faso', N'031', N'AFR', N'226', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GW', N'Guinea-Bissau', N'334', N'AFR', N'245', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SR', N'Suriname', N'770', N'LA', N'597', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'KH') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'KH', N'Cambodia', N'141', N'ASI', N'855', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TT') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TT', N'Trinidad and Tobago', N'815', N'CAR', N'1868', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AS') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AS', N'American Samoa', N'690', N'PAC', N'1684', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MM') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MM', N'Myanmar', N'093', N'ASI', N'95', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LV', N'Latvia', N'429', N'EUR', N'371', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MP') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MP', N'Northern Mariana Islands', N'NULL', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'PW') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'PW', N'Palau', N'578', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'HN') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'HN', N'Honduras', N'345', N'LA', N'504', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'RE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'RE', N'Reunion', N'660', N'AFR', N'33', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SV') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SV', N'El Salvador', N'242', N'LA', N'503', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SC', N'Seychelles', N'731', N'AFR', N'248', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'SG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'SG', N'Singapore', N'741', N'ASI', N'65', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BA', N'Bosnia and Herzegovina', N'029', N'EUR', N'387', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MK') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MK', N'Macedonia, The Former Yugoslav Republic of', N'448', N'NULL', N'NULL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'BG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'BG', N'Bulgaria', N'111', N'EUR', N'359', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'UZ') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'UZ', N'Uzbekistan', N'847', N'ASI', N'998', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'GE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'GE', N'Georgia', N'287', N'ASI', N'995', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'TO') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'TO', N'Tonga', N'810', N'PAC', N'676', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'IR') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'IR', N'Iran, Islamic Republic Of', N'372', N'MEA', N'98', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'AL') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'AL', N'Albania', N'017', N'EUR', N'355', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'EE') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'EE', N'Estonia', N'251', N'EUR', N'372', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'MG') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'MG', N'Madagascar', N'450', N'AFR', N'261', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LY') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LY', N'Libyan Arab Jamahiriya', N'438', N'AFR', N'218', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VC') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VC', N'Saint Vincent and The Grenadines', N'705', N'CAR', N'1784', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'VU') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'VU', N'Vanuatu', N'551', N'PAC', N'678', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'LA') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'LA', N'Lao People s Democratic Republic', N'420', N'ASI', N'856', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Countries] WHERE [code] = N'ST') INSERT INTO dbo.[Countries] ([code], [name], [dane], [region], [prefix], [isActive]) VALUES (N'ST', N'STONIA', N'251', N'AFR', N'239', 1);

-- 7.2 Ciudades (297 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOG', N'Bogotá', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'CUN', N'BOG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MDE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MDE', N'Medellín', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'ANT', N'MDE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MIA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MIA', N'Miami', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'FL', N'MIA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAD', N'Madrid', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'MAD', N'MAD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HOU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HOU', N'Houston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'HOU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANC', N'Anchorage', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ANC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LIM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LIM', N'Lima', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LIM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DEN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DEN', N'Denver', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DEN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ATL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ATL', N'Atlanta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ATL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CMH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CMH', N'Columbus', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CMH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOL', N'Hartford', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BOL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SEA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SEA', N'Seattle', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SEA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CLE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CLE', N'Cleveland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CLE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BNA', N'Nashville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOS', N'Boston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUF', N'Buffalo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BUF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BWI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BWI', N'Baltimore', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'BWI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHI', N'Chicago', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHS', N'Charleston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'CHS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DFW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DFW', N'Dallas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DFW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAY', N'Dayton', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DAY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUB', N'Dublin', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DUB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DTT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DTT', N'Detroit', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'DTT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'EWR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'EWR', N'Newark', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'EWR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GEO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GEO', N'Georgetown', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'GEO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GLA', N'Glasgow', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'GLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HNL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HNL', N'Honolulu', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'HNL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAX', N'Los Angeles', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LAX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SFO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SFO', N'San Francisco', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SFO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NYC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NYC', N'New York', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'NYC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAS', N'Las Vegas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LGB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LGB', N'Long Beach', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'LGB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ORL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ORL', N'Orlando', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ORL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MEM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MEM', N'Memphis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MEM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MKE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MKE', N'Milwaukee', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MKE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MSP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MSP', N'Minneapolis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MSP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MSY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MSY', N'New Orleans', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'MSY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAN', N'San Diego', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NOR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NOR', N'Norfolk', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'NOR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PDX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PDX', N'Portland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'PDX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PHX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PHX', N'Phoenix', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'PHX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RDU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RDU', N'Raleigh', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'RDU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RIC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RIC', N'Richmond', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'RIC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ROC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ROC', N'Rochester', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'ROC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAI', N'San Antonio', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAV', N'Savannah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SAV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SLC', N'Salt Lake City', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'SLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TPA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TPA', N'Tampa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'TPA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TUS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TUS', N'Tucson', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'TUS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YYJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YYJ', N'Victoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'YYJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VAP', N'Valparaiso', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'US'), N'', N'VAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ABJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ABJ', N'Abidjan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CI'), N'null', N'ABJ', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DHA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DHA', N'Dhahran', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'DHA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RUH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RUH', N'Riyadh', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'RUH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JED') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JED', N'Jeddah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SA'), N'', N'JED', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KAN', N'Kano', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NG'), N'', N'KAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LOS', N'Lagos', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NG'), N'', N'LOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SYD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SYD', N'Sydney', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'SYD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MEL', N'Melbourne', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'MEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ROM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ROM', N'Roma', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'ROM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PER') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PER', N'Perth', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'PER', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CNS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CNS', N'Cairns', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'CNS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HBA', N'Hobart', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AU'), N'', N'HBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHD', N'Belfast', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'BHD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MME') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MME', N'Teesside', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'MME', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LBA', N'Leeds', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GB'), N'', N'LBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LPB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LPB', N'La Paz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'LPB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MID') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MID', N'Merida', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MID', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MZT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MZT', N'Mazatlan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MZT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MTY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MTY', N'Monterrey', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'MTY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PVR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PVR', N'Puerto Vallarta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'PVR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VER') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VER', N'Veracruz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'VER', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TAM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TAM', N'Tampico', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'TAM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYM', N'Guaymas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'GYM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GDL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GDL', N'Guadalajara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'GDL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CUN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CUN', N'Cancun', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'CUN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CZM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CZM', N'Cozumel', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MX'), N'', N'CZM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ACC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ACC', N'Accra', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GH'), N'', N'ACC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ALC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ALC', N'Alicante', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'ALC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AGP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AGP', N'Malaga', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'AGP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BCN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BCN', N'Barcelona', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'BCN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BIO', N'Bilbao', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'BIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GND') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GND', N'Granada', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'GND', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IBZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IBZ', N'Ibiza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'IBZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SVQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SVQ', N'Sevilla', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'SVQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VGO', N'Vigo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VIX') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VIX', N'Vitoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VIX', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VLC', N'Valencia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'VLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZAZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZAZ', N'Zaragoza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'ZAZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SDR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SDR', N'Santander', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'SDR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PNA', N'Pamplona', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'PNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MJV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MJV', N'Murcia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'MJV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAH', N'Menorca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ES'), N'', N'MAH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AYT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AYT', N'Antalya', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TR'), N'', N'AYT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANK', N'Ankara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TR'), N'', N'ANK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ADD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ADD', N'Addis Ababa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ET'), N'', N'ADD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ADE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ADE', N'Aden', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'YE'), N'', N'ADE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BAQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BAQ', N'Barranquilla', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'ATL', N'BAQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTG', N'Cartagena', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'BOL', N'CTG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CLO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CLO', N'Cali', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'VAL', N'CLO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'000001') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'000001', N'chigorodo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CO'), N'', N'000001', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHI', N'Bahia Blanca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'BHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUE', N'Buenos Aires', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'BUE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SLZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SLZ', N'San Luis', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AR'), N'', N'SLZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KRS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KRS', N'Kristiansand', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'KRS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SVG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SVG', N'Stavanger', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'SVG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGO', N'Bergen', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'BGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OSL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OSL', N'Oslo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NO'), N'', N'OSL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAS', N'Casablanca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'CAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RAK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RAK', N'Marrakech', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'RAK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RBA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RBA', N'Rabat', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MA'), N'', N'RBA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'STR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'STR', N'Stuttgart', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'STR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LEJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LEJ', N'Leipzig', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'LEJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MUC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MUC', N'Munich', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'MUC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUS', N'Dusseldorf', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'DUS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FRA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FRA', N'Frankfurt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DE'), N'', N'FRA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PAR', N'Paris', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'PAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BOD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BOD', N'Bordeaux', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'BOD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LYS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LYS', N'Lyon', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LYS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LHV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LHV', N'Le Havre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LHV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LIL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LIL', N'Lille', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FR'), N'', N'LIL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MMA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MMA', N'Malmo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SE'), N'', N'MMA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DEL', N'Delhi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IN'), N'', N'DEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAA', N'Madras', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IN'), N'', N'MAA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DPS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DPS', N'Denpasar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ID'), N'', N'DPS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JKT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JKT', N'Jakarta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ID'), N'', N'JKT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BRI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BRI', N'Bari', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'BRI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MIL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MIL', N'Milan', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'MIL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMO', N'Palermo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IT'), N'', N'PMO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'POA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'POA', N'Porto Alegre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'POA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'REC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'REC', N'Recife', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'REC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SSA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SSA', N'Salvador', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'SSA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JPA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JPA', N'Joao Pessoa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'JPA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MCZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MCZ', N'Maceio', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'MCZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAT', N'Natal', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'NAT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BSB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BSB', N'Brasilia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BSB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BZC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BZC', N'Buzios', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BZC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BEL', N'Belem', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AJU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AJU', N'Aracaju', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'AJU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BHZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BHZ', N'Belo Horizonte', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'BHZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CWB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CWB', N'Curitiba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'CWB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CGB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CGB', N'Cuiaba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'CGB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IOS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IOS', N'Ilheus', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'IOS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYN', N'Goiania', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'GYN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FOR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FOR', N'Fortaleza', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'FOR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'RIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'RIO', N'Rio De Janeiro', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BR'), N'', N'RIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CHC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CHC', N'Christchurch', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'CHC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AKL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AKL', N'Auckland', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'AKL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'WLG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'WLG', N'Wellington', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NZ'), N'', N'WLG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PRY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PRY', N'Pretoria', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'PRY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PEZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PEZ', N'Port Elizabeth', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'PEZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DUR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DUR', N'Durban', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'DUR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTW', N'Cape Town', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZA'), N'', N'CTW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ALP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ALP', N'Aleppo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SY'), N'', N'ALP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAI', N'Cairo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EG'), N'', N'CAI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AMM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AMM', N'Amman', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JO'), N'', N'AMM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AMS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AMS', N'Amsterdam', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NL'), N'', N'AMS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANF', N'Antofagasta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ANF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ARI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ARI', N'Arica', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ARI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IQQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IQQ', N'Iquique', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'IQQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMC', N'Puerto Montt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'PMC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PUQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PUQ', N'Punta Arenas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'PUQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZCO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZCO', N'Temuco', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'ZCO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LSC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LSC', N'La Serena', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CL'), N'', N'LSC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ANR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ANR', N'Antwerp', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BE'), N'', N'ANR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KUL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KUL', N'Kuala Lumpur', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MY'), N'', N'KUL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PEN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PEN', N'Penang', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MY'), N'', N'PEN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MPM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MPM', N'Maputo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MZ'), N'', N'MPM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'APW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'APW', N'Apia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'WS'), N'', N'APW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AQP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AQP', N'Arequipa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PE'), N'', N'AQP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OSA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OSA', N'Osaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'OSA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FUK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FUK', N'Fukuoka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'FUK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NGO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NGO', N'Nagoya', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'NGO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'OKA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'OKA', N'Okinawa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JP'), N'', N'OKA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ASM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ASM', N'Asmara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ER'), N'', N'ASM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ASU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ASU', N'Asuncion', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PY'), N'', N'ASU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FPO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FPO', N'Freeport', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BS'), N'', N'FPO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAS', N'Nassau', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BS'), N'', N'NAS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AUA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AUA', N'Aruba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AW'), N'', N'AUA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AUH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AUH', N'Abu Dhabi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'AUH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DXB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DXB', N'Dubai', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'DXB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SHJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SHJ', N'Sharjah', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AE'), N'', N'SHJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PPT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PPT', N'Papeete', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PF'), N'', N'PPT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VRA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VRA', N'Varadero', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'VRA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZLO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZLO', N'Manzanillo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'ZLO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HOG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HOG', N'Holguin', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'HOG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'AVI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'AVI', N'Ciego De Avila', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CU'), N'', N'AVI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MNL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MNL', N'Manila', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PH'), N'', N'MNL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BAH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BAH', N'Bahrain', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BH'), N'', N'BAH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GBE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GBE', N'Gaborone', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BW'), N'', N'GBE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TSR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TSR', N'Timisoara', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'RO'), N'', N'TSR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BDA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BDA', N'Bermuda', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BM'), N'', N'BDA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BEY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BEY', N'Beirut', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LB'), N'', N'BEY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NAN', N'Nadi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FJ'), N'', N'NAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SUV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SUV', N'Suva', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FJ'), N'', N'SUV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGF', N'Bangui', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CF'), N'', N'BGF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGI', N'Barbados', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BB'), N'', N'BGI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BGW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BGW', N'Baghdad', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IQ'), N'', N'BGW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BSR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BSR', N'Basra', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IQ'), N'', N'BSR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAN', N'Guangzhou', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'CAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJS', N'Beijing', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'BJS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DLC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DLC', N'Dalian', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'DLC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SHA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SHA', N'Shanghai', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CN'), N'', N'SHA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJL', N'Banjul', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GM'), N'', N'BJL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BJM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BJM', N'Bujumbura', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BI'), N'', N'BJM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BKK') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BKK', N'Bangkok', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TH'), N'', N'BKK', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HKT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HKT', N'Phuket', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TH'), N'', N'HKT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BKO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BKO', N'Bamako', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ML'), N'', N'BKO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CCS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CCS', N'Caracas', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'CCS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PMV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PMV', N'Porlamar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'PMV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MAR', N'Maracaibo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'VE'), N'', N'MAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LLW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LLW', N'Lilongwe', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MW'), N'', N'LLW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BLZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BLZ', N'Blantyre', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MW'), N'', N'BLZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BON') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BON', N'Bonaire', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AN'), N'', N'BON', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLH', N'Mulhouse', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CH'), N'', N'MLH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZRH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZRH', N'Zurich', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CH'), N'', N'ZRH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SDQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SDQ', N'Santo Domingo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DO'), N'', N'SDQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BTS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BTS', N'Bratislava', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SK'), N'', N'BTS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUD', N'Budapest', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HU'), N'', N'BUD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BUQ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BUQ', N'Bulawayo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZW'), N'', N'BUQ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HRE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HRE', N'Harare', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZW'), N'', N'HRE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'BZV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'BZV', N'Brazzaville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CG'), N'', N'BZV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CBB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CBB', N'Cochabamba', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BO'), N'', N'CBB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PAP', N'Port Au Prince', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HT'), N'', N'PAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CAY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CAY', N'Cayenne', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GF'), N'', N'CAY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FAO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FAO', N'Faro', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PT'), N'', N'FAO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SNN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SNN', N'Shannon', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IE'), N'', N'SNN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAC', N'Dhaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BD'), N'', N'DAC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CKY') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CKY', N'Conakry', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GN'), N'', N'CKY', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CMB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CMB', N'Colombo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LK'), N'', N'CMB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'COO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'COO', N'Cotonou', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BJ'), N'', N'COO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GYE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GYE', N'Guayaquil', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EC'), N'', N'GYE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'UIO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'UIO', N'Quito', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'EC'), N'', N'UIO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YTO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YTO', N'Toronto', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YTO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YEG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YEG', N'Edmonton', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YEG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YUL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YUL', N'Montreal', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YUL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YOW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YOW', N'Ottawa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YOW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YYC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YYC', N'Calgary', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YYC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YQG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YQG', N'Windsor', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YQG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YWG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YWG', N'Winnipeg', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'YWG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'VAN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'VAN', N'Vancouver', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CA'), N'', N'VAN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CYR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CYR', N'Colonia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'CYR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PDP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PDP', N'Punta Del Este', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'PDP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MVD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MVD', N'Montevideo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UY'), N'', N'MVD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DAR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DAR', N'Dar Es Salaam', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TZ'), N'', N'DAR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ZAG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ZAG', N'Zagreb', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HR'), N'', N'ZAG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DKR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DKR', N'Dakar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SN'), N'', N'DKR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DLA', N'Douala', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CM'), N'', N'DLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'YAO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'YAO', N'Yaounde', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CM'), N'', N'YAO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'DOH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'DOH', N'Doha', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'QA'), N'', N'DOH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LCA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LCA', N'Larnaca', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CY'), N'', N'LCA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PFO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PFO', N'Paphos', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CY'), N'', N'PFO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'WDH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'WDH', N'Windhoek', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NA'), N'', N'WDH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TLV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TLV', N'Tel Aviv', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IL'), N'', N'TLV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'JRS') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'JRS', N'Jerusalem', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IL'), N'', N'JRS', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FBM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FBM', N'Lubumbashi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CD'), N'', N'FBM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FIH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FIH', N'Kinshasa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CD'), N'', N'FIH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'FNA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'FNA', N'Freetown', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SL'), N'', N'FNA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GIB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GIB', N'Gibraltar', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GI'), N'', N'GIB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'GRZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'GRZ', N'Graz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'GRZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KLU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KLU', N'Klagenfurt', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'KLU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LNZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LNZ', N'Linz', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AT'), N'', N'LNZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLA', N'Malta', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MT'), N'', N'MLA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KHH') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KHH', N'Kaohsiung', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TW'), N'', N'KHH', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TPE') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TPE', N'Taipei', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TW'), N'', N'TPE', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KHI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KHI', N'Karachi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PK'), N'', N'KHI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'ISB') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'ISB', N'Islamabad', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'PK'), N'', N'ISB', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HEL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HEL', N'Helsinki', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'FI'), N'', N'HEL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'HKG') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'HKG', N'Hong Kong', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HK'), N'', N'HKG', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'IEV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'IEV', N'Kiev', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'UA'), N'', N'IEV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KGL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KGL', N'Kigali', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'RW'), N'', N'KGL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KIN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KIN', N'Kingston', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JM'), N'', N'KIN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MBJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MBJ', N'Montego Bay', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'JM'), N'', N'MBJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KRT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KRT', N'Khartoum', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SD'), N'', N'KRT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'KWI') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'KWI', N'Kuwait', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'KW'), N'', N'KWI', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LAD') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LAD', N'Luanda', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AO'), N'', N'LAD', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LBV') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LBV', N'Libreville', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'GA'), N'', N'LBV', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LFW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LFW', N'Lome', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'TG'), N'', N'LFW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'CTF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'CTF', N'CARTAGO', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'CR'), N'', N'CTF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LJU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LJU', N'Ljubljana', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SI'), N'', N'LJU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'LUN') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'LUN', N'Lusaka', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'ZM'), N'', N'LUN', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NBO') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NBO', N'Nairobi', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'KE'), N'', N'NBO', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MCT') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MCT', N'Muscat', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'OM'), N'', N'MCT', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MGA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MGA', N'Managua', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NI'), N'', N'MGA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'MLW') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'MLW', N'Monrovia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'LR'), N'', N'MLW', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NKC') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NKC', N'Nouakchott', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'MR'), N'', N'NKC', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'NIM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'NIM', N'Niamey', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'NE'), N'', N'NIM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PBM') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PBM', N'Paramaribo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SR'), N'', N'PBM', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAP') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAP', N'San Pedro Sula', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HN'), N'', N'SAP', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TGU') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TGU', N'Tegucigalpa', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'HN'), N'', N'TGU', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SAL') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SAL', N'San Salvador', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SV'), N'', N'SAL', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SEZ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SEZ', N'Mahe Island', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'SC'), N'', N'SEZ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SJJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SJJ', N'Sarajevo', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BA'), N'', N'SJJ', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'SOF') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'SOF', N'Sofia', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'BG'), N'', N'SOF', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'THR') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'THR', N'Teheran', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'IR'), N'', N'THR', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'TIA') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'TIA', N'Tirana', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'AL'), N'', N'TIA', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Cities] WHERE [code] = N'PUJ') INSERT INTO dbo.[Cities] ([code], [name], [countriesId], [statecode], [iata], [isActive]) VALUES (N'PUJ', N'PUNTA CANA', (SELECT TOP 1 [id] FROM dbo.[Countries] WHERE [code] = N'DO'), NULL, N'PUJ', 1);

-- 7.3 Aeropuertos (433 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOG', N'Aeropuerto Internacional El Dorado', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MDE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MDE', N'Aeropuerto Internacional Jose Maria Cordova', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MDE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MIA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MIA', N'Miami International Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAD', N'Adolfo Suarez Madrid-Barajas', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AAP', N'Andrau Airpark', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ABJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ABJ', N'Felix Houphouet Boigny Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ABJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ACC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ACC', N'Kotoka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ACC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ADD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ADD', N'Bole Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ADD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ADE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ADE', N'Yemen Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ADE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AEP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AEP', N'Jorge Newbery', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AGB', N'Mehlhausen', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MUC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AGP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AGP', N'Malaga Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AGP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AJU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AJU', N'Santa Maria Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AJU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AKL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AKL', N'Auckland Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AKL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ALC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ALC', N'Alicante Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ALC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ALP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ALP', N'Nejrab Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ALP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AMM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AMM', N'Queen Alia Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AMM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AMS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AMS', N'Schiphol Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AMS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANC', N'Anchorage Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANF', N'Cerro Moreno Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANK', N'Etimesgut Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ANR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ANR', N'Deurne Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AOH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AOH', N'Allen County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'APA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'APA', N'Centennial Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'APW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'APW', N'Apia Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'APW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AQP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AQP', N'Rodriguez Ballon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AQP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ARI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ARI', N'Chacalluta Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ARI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ASM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ASM', N'Asmara Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ASM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ASU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ASU', N'Salvio Pettirosse Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ASU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ATL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ATL', N'Hartsfield Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUA', N'Reina Beatrix Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AUA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUH', N'Dhabi Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AUH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AUO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AUO', N'Auburn Opelika', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AVI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AVI', N'Maximo Gomez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AVI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'AYT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'AYT', N'Antalya Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'AYT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BAH', N'Muharraq Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BAH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BCN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BCN', N'Barcelona Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BCN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BDA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BDA', N'Bermuda International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BDA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BDL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BDL', N'Bradley Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BEL', N'Val De Cans Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BER', N'Berlin Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BEY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BEY', N'Beirut Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BEY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BFI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BFI', N'Seattle Boeing Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BFS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BFS', N'Belfast Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGF', N'Bangui Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGI', N'Grantley Adams Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGO', N'Flesland Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BGW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BGW', N'Al Muthana Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BHD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BHD', N'Belfast City Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BHI', N'Commandante Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BIO', N'Sondica Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJL', N'Yundum Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJM', N'Bujumbura Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BJS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BJS', N'Beijing', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKK', N'Bangkok Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BKK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKL', N'Burke Lakefront Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BKO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BKO', N'Senou Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BKO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BLA', N'Gen J A Anzoategui Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BCN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BLZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BLZ', N'Chileka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BLZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BNA', N'Nashville Metro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOD', N'Merignac Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BON') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BON', N'Flamingo Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BON'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BOS', N'Logan Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BRI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BRI', N'Bari Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BRI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BSB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BSB', N'Brasilia Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BSB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BSR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BSR', N'Basra Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BSR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BTS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BTS', N'Ivanka Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BTS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUD', N'Ferihegy Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUE', N'Buenos Aires Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUF', N'Greater Buffalo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BUQ', N'Bulawayo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BWI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BWI', N'Baltimore Washington Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BWI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BZC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BZC', N'Buzios Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BZC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BZV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BZV', N'Maya Maya Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BZV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAI', N'Cairo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAN', N'Baiyun Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAS', N'Anfa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CAY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CAY', N'Rochambeau Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CBB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CBB', N'J Wilsterman Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CBB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CCS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CCS', N'Simon Bolivar Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CCS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CDG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CDG', N'Charles De Gaulle Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGB', N'Marechal Rondon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CGB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGF', N'Cuyahoga County Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGK', N'Soekarno Hatta Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CGX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CGX', N'Meigs Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHC', N'Christchurch Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHI', N'Chicago Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CHS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CHS', N'Charleston Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CKY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CKY', N'Conakry Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CKY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLE', N'Hopkins Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLU', N'Columbus Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMB', N'Katunayake Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMH', N'Port Columbus Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CMN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CMN', N'Mohamed V Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CNF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CNF', N'Tancredo Neves Intl Arpt.', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BHZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CNS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CNS', N'Cairns Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CNS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'COO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'COO', N'Cotonou Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'COO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CPT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CPT', N'Cape Town International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CTW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CRW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CRW', N'Yeager Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CSG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CSG', N'Columbus Metro Ft Benning Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CUN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CUN', N'Cancun Aeropuerto Internacional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CUN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CUS', N'Columbus Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CWB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CWB', N'Afonso Pena Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CWB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CXH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CXH', N'Coal Harbor Sea Plane Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CYR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CYR', N'Colonia Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CYR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CZM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CZM', N'Aeropuerto Intl De Cozumel', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CZM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAC', N'Zia Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAL', N'Love Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAR', N'Es Salaam Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DAY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DAY', N'Dayton International Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DAY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DBN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DBN', N'Dublin Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DEL', N'Delhi Indira Gandhi Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DEN', N'Denver Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DET') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DET', N'Detroit City Apt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DFW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DFW', N'Dallas Ft Worth Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DHA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DHA', N'Dhahran Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DHA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DKR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DKR', N'Yoff Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DKR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DLA', N'Douala Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DLC', N'Dalian Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DOH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DOH', N'Doha Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DOH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DPS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DPS', N'Ngurah Rai Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DPS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DTW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DTW', N'Detroit Metro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUB', N'Dublin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUR', N'Durban International', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DUS', N'Dusseldorf Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DWH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DWH', N'David Wayne Hooks Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DXB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DXB', N'Dubai Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DXB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EAP', N'Mulhouse/Basel Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EFD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EFD', N'Ellington Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ERS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ERS', N'Eros Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WDH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ESB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ESB', N'Esenboga Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ANK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EWR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EWR', N'Newark Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'EWR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'EZE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'EZE', N'Ministro Pistarini', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BUE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FAO', N'Faro Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FBM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FBM', N'Luano', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FBM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FBU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FBU', N'Fornebu Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FIH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FIH', N'Kinshasa Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FIH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FNA', N'Lungi Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FOR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FOR', N'Pinto Martines Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FOR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FPO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FPO', N'Freeport Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FPO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FRA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FRA', N'Frankfurt Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FTY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FTY', N'Fulton Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'FUK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'FUK', N'Itazuke Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FUK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GBE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GBE', N'Gaborone Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GBE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GDL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GDL', N'Miguel Hidalgo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GDL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GED', N'Sussex County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GEO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GEN', N'Gardermoen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GEO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GEO', N'Timehri Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GEO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GGW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GGW', N'International Glasgow', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GIB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GIB', N'North Front Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GIB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GIG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GIG', N'Rio Internacional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GLA', N'Glasgow Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GRX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GRX', N'Granada Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GND'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GRZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GRZ', N'Thalerhof Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GRZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GTR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GTR', N'Golden Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYE', N'Simon Bolivar Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYM', N'Gen Jose M Yanez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'GYN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'GYN', N'Santa Genoveva', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GYN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HBA', N'Hobart Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HEL', N'Helsinki Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HFD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HFD', N'Brainard Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BOL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HKG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HKG', N'Hong Kong Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HKG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HKT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HKT', N'Phuket Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HMA', N'Malmo City Hvc Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HNL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HNL', N'Honolulu Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HNL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HOG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HOG', N'Frank Pias Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HOU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HOU', N'Houston Hobby Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'HRE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'HRE', N'Harare Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HRE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IAH', N'Houston Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IBZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IBZ', N'Ibiza Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IBZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IEV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IEV', N'Zhulhany Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IEV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IOS', N'Eduardo Gomes Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IQQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IQQ', N'Cavancha Chucumata Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IQQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ISB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ISB', N'Islamabad Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ISB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ITM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ITM', N'Itami Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'IWS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'IWS', N'West Houston', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JAJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JAJ', N'Perimeter Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JAO', N'Beaver Ruin Helpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JBP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JBP', N'Commerce Business Plaza Heliport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JCC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JCC', N'China Basin Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JDP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JDP', N'Issy Les Moulineaux Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JED', N'Jeddah Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JED'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JFK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JFK', N'John F Kennedy Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JKT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JKT', N'Kemayoran Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JKT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JPA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JPA', N'Castro Pinto Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JRE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JRE', N'East 60th St Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JRS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JRS', N'Atarot Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'JRS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'JTO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'JTO', N'Thousand Oaks Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KAN', N'Aminu Kano Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KBP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KBP', N'Borispol Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'IEV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KGL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KGL', N'Kayibanda Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KGL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KHH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KHH', N'Kaohsiung Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KHH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KHI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KHI', N'Karachi Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KIN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KIN', N'Norman Manly Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KIX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KIX', N'Kansai International Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KLU', N'Klagenfurt Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KLU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KRS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KRS', N'Kjevik Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KRS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KRT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KRT', N'Civil Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KRT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KTP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KTP', N'Tinson Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KUL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KUL', N'Subang Kuala Lumpur Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'KWI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'KWI', N'Kuwait Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KWI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAD', N'Four De Fevereiro Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAP', N'Aeropuerto Gen Marquez De Leon', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LPB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAS', N'McCarran Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LAX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LAX', N'Los Angeles Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBA', N'Leeds Bradford Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBG', N'Le Bourget Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBH', N'Palm Beach Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LBV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LBV', N'Libreville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LBV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LCA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LCA', N'Larnaca Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LCA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LEH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LEH', N'Octeville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LHV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LEJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LEJ', N'Schkeuditz Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LEJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LFW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LFW', N'Lome Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LGA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LGA', N'La Guardia', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LGB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LGB', N'Long Beach Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LGB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIL', N'Lesquin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIM', N'Nlima Intl Jorge Chavez', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LIN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LIN', N'Linate Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LJU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LJU', N'Brnik Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LJU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LKE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LKE', N'Lake Union Seaplane Base', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LLW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LLW', N'Lilongwe Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LNZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LNZ', N'Hoersching Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LNZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LOS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LOS', N'Murtala Muhammed Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LOS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LPB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LPB', N'El Alto Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LPB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LSC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LSC', N'La Florida', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LSC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LUN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LUN', N'Lusaka Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LUN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LUQ', N'San Luis Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SLZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LVS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LVS', N'Las Vegas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'LYS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'LYS', N'Satolas Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LYS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAA', N'Meenambarkkam Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAH', N'Aerop De Menorca', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MAR', N'La Chinita Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MBJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MBJ', N'Sangster Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MBJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCO', N'Orlando Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ORL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCT', N'Seeb Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MCT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MCZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MCZ', N'Palmeres Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MCZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MDW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MDW', N'Midway', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEB', N'Essendon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEL', N'Tullamarine Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MEM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MEM', N'Memphis Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MGA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MGA', N'Augusto C Sandino', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MGA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MID') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MID', N'Merida Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MID'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MIL', N'Milan Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MJV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MJV', N'San Javier Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MJV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MKE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MKE', N'General Mitchell Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MKE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLA', N'Luqa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLB', N'Melbourne Regional', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLH', N'Euroairport French', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MLW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MLW', N'Sprigg Payne Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MMA', N'Malmo Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MME') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MME', N'Teesside Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MME'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MMX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MMX', N'Sturup Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MMA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MNL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MNL', N'Ninoy Aquino Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MNL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MPM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MPM', N'Maputo Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MPM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MRD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MRD', N'Alberto Carnevalli Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MID'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MSP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MSP', N'Minneapolis St Paul Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MSY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MSY', N'Moisant Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MTC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MTC', N'Selfridge Air Natl Guard', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MTY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MTY', N'Escobedo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MTY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MUC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MUC', N'Franz Josef Strauss Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MUC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MVD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MVD', N'Carrasco Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MVD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MXP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MXP', N'Malpensa Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MYF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MYF', N'Montogomery Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MZO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MZO', N'Sierra Maestra Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'MZT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'MZT', N'Buelina Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MZT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAN', N'Nadi Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAS', N'Nassau Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NAT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NAT', N'Augusto Severo Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NBO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NBO', N'Jomo Kenyatta Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NBO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NEW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NEW', N'New Lakefront Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MSY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NGO', N'Komaki Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NIM', N'Niamey Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NIM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NKC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NKC', N'Nouakchott Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NKC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NQA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NQA', N'Memphis Naval Air Station', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MEM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NSI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NSI', N'Nsimalen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'NYC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'NYC', N'New York City Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OFK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OFK', N'Karl Stefan Fld', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NOR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OKA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OKA', N'Naha Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OKA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OLU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OLU', N'Columbus Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OPF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OPF', N'Opa Locka Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORD', N'OHare Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORL', N'Herndon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ORL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ORY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ORY', N'Orly Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSA', N'Osaka', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSL', N'Oslo Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'OSL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'OSU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'OSU', N'Ohio State Univ Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PAP', N'Mais Gate Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PAR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PAR', N'Paris Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PBM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PBM', N'Zanderij Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PBM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDK', N'Dekalb Peachtree', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ATL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDP', N'Cap Curbelo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PDX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PDX', N'Portland Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PEK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PEK', N'Beijing Capital Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BJS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PEN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PEN', N'Penang Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PEN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PER', N'Perth Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PFO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PFO', N'Paphos Intl Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PHT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PHT', N'Henry County Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PHX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PHX', N'Sky Harbor Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PHX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PID') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PID', N'Paradise Island Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PIK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PIK', N'Prestwick Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'GLA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PLZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PLZ', N'Port Elizabeth Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PEZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMC', N'Tepual Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMO', N'Punta Raisi Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PMV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PMV', N'Delcaribe Gen S Marino Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PMV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PNA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PNA', N'Pamplona Noain Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PNA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'POA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'POA', N'Porto Alegre Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'POA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PPT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PPT', N'Intl Tahiti Faaa', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PPT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PRX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PRX', N'Paris Cox Field Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PAR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PRY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PRY', N'Wonderboom Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PRY'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PSK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PSK', N'New River Valley Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DUB'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PTJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PTJ', N'Portland Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PUQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PUQ', N'Presidente Ibanez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PUQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PVR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PVR', N'Ordaz Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PVR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PWK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PWK', N'Pal Waukee Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CHI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'PWM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'PWM', N'Portland Intl Jetport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'PDX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QBA', N'San Francisco Bay Area Airpts', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QDF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QDF', N'Dallas Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DFW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QGV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QGV', N'Neu Isenburg Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'FRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QHO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QHO', N'Houston Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'HOU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QKN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QKN', N'Kingston Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QLA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QLA', N'Los Angeles Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QMI') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QMI', N'Miami Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QRV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QRV', N'Arras Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LIL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'QSE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'QSE', N'Seattle Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RAC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RAC', N'Horlick Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MKE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RAK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RAK', N'Menara Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RAK'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RBA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RBA', N'Sale Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RBA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RDU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RDU', N'Raleigh Durham Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RDU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'REC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'REC', N'Recife Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'REC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RIC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RIC', N'Byrd Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RIO', N'Rio De Janeiro Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RMA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RMA', N'Roma Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ROB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ROB', N'Roberts Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MLW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ROC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ROC', N'Monroe Cty Arpt New York', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RSE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RSE', N'Au Rose Bay Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RST') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RST', N'Rochester Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ROC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'RUH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'RUH', N'King Khaled Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RUH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAL', N'El Salvador Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAN', N'Lindbergh Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAP', N'La Mesa Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAT', N'San Antonio Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SAV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SAV', N'Travis Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDA', N'Saddam Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BGW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDM', N'Brown Fld Municipal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDQ', N'Las Americas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDR', N'Santander Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDU', N'Santos Dumont Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'RIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SDV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SDV', N'Dov Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TLV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SEA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SEA', N'Seattle Tacoma Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SEZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SEZ', N'Seychelles Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SEZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SFO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SFO', N'San Francisco Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SFO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SHA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SHA', N'Shanghai Intl Hongqiao', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SHA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SHJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SHJ', N'Sharjah Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SHJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SJJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SJJ', N'Butmir Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SJJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SLC', N'Salt Lake City Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SMO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SMO', N'Santa Monica Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SNN') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SNN', N'Shannon Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SNN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SOF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SOF', N'Sofia Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SOF'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SSA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SSA', N'Dois De Julho Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SSA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'STD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'STD', N'Mayor Humberto Vivas Guerrero Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SDQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'STR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'STR', N'Eghterdingen Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'STR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SUV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SUV', N'Nausori Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SUV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVG', N'Sola Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SVG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVQ', N'San Pablo Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SVQ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SVZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SVZ', N'San Antonio Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SAI'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SXF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SXF', N'Schoenefeld Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'SYD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'SYD', N'Sydney Kingsford Smith Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TAM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TAM', N'General F Javier Mina', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TAM'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TGU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TGU', N'Toncontin Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TGU'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'THF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'THF', N'Tempelhof Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'THR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'THR', N'Mehrabad Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'THR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TIA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TIA', N'Rinas Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TLV') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TLV', N'Ben Gurion Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TLV'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TMB') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TMB', N'Tamiami Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MIA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPA', N'Tampa Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPE') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPE', N'Chiang Kai Shek Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TPF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TPF', N'Peter O Knight Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TPA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TSR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TSR', N'Timisoara Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TSR'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TSS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TSS', N'East 34th St Hlpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TUS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TUS', N'Tucson Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'TUS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'TXL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'TXL', N'Tegel Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UBS') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UBS', N'Lowndes Cty Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CMH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UIO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UIO', N'Mariscal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'UIO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'UIZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'UIZ', N'Berz Macomb Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VCT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VCT', N'Victoria Regional Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VER') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VER', N'Las Bajadas General Heriberto Jara', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VER'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VGO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VGO', N'Vigo Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VGO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VGT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VGT', N'Las Vegas North Air Terminal', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VIT') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VIT', N'Vitoria Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VIX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VIX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VIX', N'Eurico Sales Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VIX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VLC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VLC', N'Valencia Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VLC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VNY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VNY', N'Los Angeles Van Nuys Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'LAX'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VPZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VPZ', N'Porter County', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAP'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'VRA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'VRA', N'Juan Gualberto Gomez Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VRA'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WDH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WDH', N'Windhoek Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WDH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WIL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WIL', N'Wilson Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NBO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WLG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WLG', N'Wellington Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'WLG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'WZY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'WZY', N'Seaplane Base Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'NAS'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YAO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YAO', N'Yaounde Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YAO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YBZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YBZ', N'Downtown Hlpt Toronto', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YEA') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YEA', N'Edmonton Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YED') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YED', N'Namao Field', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YEG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YEG', N'Edmonton Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YGK') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YGK', N'Norman Rodgers Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'KIN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YHU') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YHU', N'St Hubert Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YIP') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YIP', N'Willow Run Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'DTT'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YKZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YKZ', N'Buttonville Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMQ', N'Montreal Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMX') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMX', N'Mirabel Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YMY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YMY', N'Victoria Stol', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YOW') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YOW', N'Ottawa Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YOW'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQF') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQF', N'Red Deer Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQG', N'Windsor Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YQG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YQY') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YQY', N'Sydney Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'SYD'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YTO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YTO', N'Toronto Area Airports', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YTZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YTZ', N'Toronto City Centre Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YUL') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YUL', N'Dorval Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YUL'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YVR') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YVR', N'Vancouver Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'VAN'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YWG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YWG', N'Winnipeg Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YWG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YWH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YWH', N'Inner Harbor Sea Plane Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YXD') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YXD', N'Edmonton Municipal Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YEG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYC') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYC', N'Calgary Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYC'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYJ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYJ', N'Victoria Intl Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YYJ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'YYZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'YYZ', N'Lester B Pearson Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'YTO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZAG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZAG', N'Zagreb Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZAG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZAZ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZAZ', N'Zaragoza Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZAZ'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZCO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZCO', N'Manquehue Arpt', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZCO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZLO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZLO', N'Aeropuerto Intl', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'ZRH') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'ZRH', N'Zurich Airport', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'ZRH'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CTG') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CTG', N'Aeropuerto Internacional Rafael Nunez', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CTG'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'CLO') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'CLO', N'Alfonso Bonilla Arag¢n', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'CLO'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'DIM') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'DIM', N'Aeropuerto Olaya Herrera', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'MDE'), 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Airports] WHERE [code] = N'BAQ') INSERT INTO dbo.[Airports] ([code], [name], [citiesId], [isActive]) VALUES (N'BAQ', N'AEROPUERTO ERNESTO CORTIZO', (SELECT TOP 1 [id] FROM dbo.[Cities] WHERE [code] = N'BAQ'), 1);

-- 7.4 Formas de Pago (2 registros)
IF NOT EXISTS (SELECT 1 FROM dbo.[Payment] WHERE [code] = N'EFE') INSERT INTO dbo.[Payment] ([code], [name], [isActive]) VALUES (N'EFE', N'Efectivo', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.[Payment] WHERE [code] = N'TC') INSERT INTO dbo.[Payment] ([code], [name], [isActive]) VALUES (N'TC', N'Tarjeta De Credito', 1);
