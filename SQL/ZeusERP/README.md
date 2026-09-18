# Procedimientos Almacenados Zeus ERP (SQL Server)

Esta carpeta (`SQL/ZeusERP/`) contiene los Procedimientos Almacenados (SPs) y Funciones T-SQL diseñados específicamente para su despliegue y ejecución en la base de datos de **Zeus ERP** (Microsoft SQL Server):

- `spCotizacionesCrear.sql`: Recibe la información XML de cotizaciones y las procesa en Zeus ERP / Korex SQL Server.
- `spFacturacionesCrear.sql`: Recibe la información XML de facturación e inyecta las facturas, remisiones y servicios en Zeus ERP (`spza_Servicio_Vender`).

Cualquier nuevo procedimiento o función T-SQL destinado a Zeus ERP debe alojarse en esta carpeta. El sincronizador autónomo (`node deploy/gen_tsql_sps_and_functions.js` y `node deploy/sync_zeus_erp.js`) escaneará e inyectará automáticamente todos los archivos `.sql` de esta carpeta en el compilador de SQL Server (`03_Functions_And_SPs.sql`) y en las bases de datos activas de Zeus ERP.
