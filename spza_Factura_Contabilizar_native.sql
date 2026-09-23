CREATE   PROCEDURE [dbo].[spza_Factura_Contabilizar] 
	-- Parametros del procedimiento
	@id_usuario 			INT,
	@id_factura 			INT,
	@bl_ContAuto 			BIT = 0,
	@CodigoArchivoFisico 	VARCHAR(25) = NULL,
	@bl_mostrarmsg BIT = 0 --rgelis 2018/12/11 req.74447
 
AS

Begin
	SET NOCOUNT On;
	  set xact_abort On 
    --region: Declaracion e inicializacion de variables
  	Declare @bl_permit			 BIT 	, -- Permiso de ejecucion del proceso
  			@bl_as 	   			 BIT	, -- Auditar exito
	 		@bl_af 			     BIT	, -- Auditar fallido	 		
			@procmsg	VARCHAR(8000)	, -- Mensaje devuelto por procedimientos llamados desde este procedimiento
			@procret 	BIT 			, -- Valor de retorno de los procedimientos llamados desde este procedimiento
			@idproce	int		    	, -- Codigo de proceso
	 		@retry 		BIT			    , -- 1=Reintentar ; 0=Abortar  
	 		@retrycont	INT			    , -- Contador de reintentos
	 		@maxretries INT			    , -- Maximo numero de reintentos
	 		@timeout	NVARCHAR(4000)  , -- Tiempo de espera maximo por bloqueo de registros
	 		@stmt 		NVARCHAR(4000)  , -- Cadena de instrucciones T-SQL
			@tc			INT 			, -- Numero de transacciones abiertas
			@msg	    VARCHAR(8000)   , -- Mensaje retornado por el sistema
			@retval		TINYINT 		, -- Valor de retorno de este procedimiento: 0:Exito ; 1:Error(Bloque Catch)
			@totalant	MONEY 			 -- Total de anticipos aplicados
   			;	
	
	Select 	@idproce 			 = 136,
			@retry				 = 1 		   ,
			@retrycont			 = 0		   ,
			@tc 			 	 = @@TRANCOUNT ,
			@retval				 = 1;
  	--Endregion	
			
  	--region: Manejo de tiempo de espera y de reintentos por bloqueo de tablas/registros  
   	Select @maxretries = convert(INT,Valor) From dbo.Parametros Where Id = 60 ;
	Select @timeout    = convert(NVARCHAR(4000),Valor) From dbo.Parametros Where Id = 50 ;		
	SET @stmt = N'SET LOCK_TIMEOUT '+ltrim(rtrim(@timeout))
	EXEC sp_executesql @stmt,N''
	--Endregion
	
	WHILE ( (@retry = 1) AND (@retrycont <= @maxretries) )
	Begin
		SET @retry = 0;
    
    	--region: Bloque TRY
    	Begin TRY 
    	    --Si es una factura generada a partir de remision se debe contabilizar usando
    	    --el sp de contabilizacion de facturas generadas a partir de remisiones
    	    If EXISTS
	    	    	(Select * From dbo.fac_remision Where id_fac_factura = @id_factura 
	    	    		AND cd_fuente_anul 		IS  NULL
		    	    	AND cd_serie_anul 		IS  NULL
	    		    	AND cd_consecutivo_anul IS  NULL
	    	    	)
    	    Begin 	    		
    	    	
	    	    EXECUTE @retval=dbo.spza_Remision_ConvertirFactura_Contabilizar 
	    	    	 @id_usuario=@id_usuario 
					,@id_factura=@id_factura 
					,@idremisiones=''
					,@CodigoArchivoFisico=@CodigoArchivoFisico 
					,@rpta=@msg OUTPUT 	;
				Select @msg AS 'Respuesta', 1 AS 'Estado' /*rgelis 2014/04/30 req.19917*/	
				RETURN @retval;
			End 					
    	    
    	        	    
    		--ObteniEndo informacion de seguridad y auditoria--
			EXEC dbo.spzaProcesoUsuario_Consultar @id_usuario   = @id_usuario       ,
							 @id_proceso   = @idproce 		    , 
												  @bl_permit    = @bl_permit OUTPUT , 
												  @bl_auditsuc  = @bl_as 	 OUTPUT , 
												  @bl_auditfail = @bl_af 	 OUTPUT ;
			If (@bl_permit = 0)
			Begin 
				Select 'No posee permisos suficientes para ejecutar esta acción.' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;		
				RETURN @retval;
			End 
			


						--Instrucciones del procedimiento-----------------------------------------
			Declare @fuente CHAR(2), 
					@numdoctra CHAR(10),
					@factotal MONEY,
					@errorcont INT,
					@anomes CHAR(6),
					@fechadoc CHAR(10),
					@descridoc VARCHAR(120),
					@Bu VARCHAR(25),
					@idvEnde CHAR(3),
					@idtercero VARCHAR(25),
					@idcliente VARCHAR(25), --rgelis 2017/02/23 req.47387
					@vencefac CHAR(10),
					@ctacartera VARCHAR(16),
					@ctacartera_Cli VARCHAR(16),
					@Manejactacartera_Suc CHAR(1),
					@ctacartera_Suc VARCHAR(16),
					@Manejactacartera_Imp CHAR(1),
					@ctacartera_Imp VARCHAR(16),
					@ctacartera_Tv VARCHAR(16),/*rgelis 2014/06/06 req,20533*/
					@cliente VARCHAR(250),
					@Numdoc CHAR(13),
					@CxC_Val MONEY,					
					@moneda CHAR(3),
					@tcambio SMALLMONEY,
					@CxP_Nac VARCHAR(16),
					@CxP_Int VARCHAR(16),
					@BU_Anticipo VARCHAR(25),  
					@ManejarCtaAlternaTAO BIT, 
					@CtaAlternaTAONac VARCHAR(16), 
					@CtaAlternaTAOInter VARCHAR(16),
					@CtaCajaRcAuto VARCHAR(16),
					@IdBancoRcAuto CHAR(3),
					@IdPlazaRcAuto CHAR(3),
					@Cd_serieRcAuto CHAR(2),
					@CtaCajaRcOtrAuto VARCHAR(16),
					@IdBancoRcOtrAuto CHAR(3),
					@IdPlazaRcOtrAuto CHAR(3),
					@Cd_serieRcOtrAuto CHAR(2),
					@bl_RcAuto BIT,
					@bl_RcSoloTkt BIT,
					@bl_RcFac BIT,
					@bl_RcTktOtr BIT,
					@bl_ExistTksTCFac BIT,
					@id_sucursal INT, 
					@id_implante INT,
					@TotalFacTktTC AS MONEY,
					@TotalFacTC AS MONEY,
					@LongitudRefe INT,
					@bl_ReferenciaCxPProveSrv CHAR(1),
					@bl_ReferenciaCxCProveSrv CHAR(1), 
					@Id_Cierre INT,
					@CodIVAFacNuevaComCierre VARCHAR(3),
					@CodComisionFacNuevaComCierre VARCHAR(3),
					@NCF varchar(25),
					@TipoDocumento Varchar(2),
					@cd_cencoSucursal CHAR(16), /*rgelis 2012/09/04 req.10397*/
					@cd_cencoImplante CHAR(16), /*jramirez 2015/10/23*/
					@bl_manejarcencostoImplante INT,
					@cd_cencoSucursalTaoNac CHAR(16), /*rgelis 2014/10/22 req.22121*/
					@cd_cencoSucursalTaoInt CHAR(16), /*rgelis 2014/10/22 req.22121*/
					@bl_nocont BIT, --rgelis 2018/04/30 req.33683
					@LlevarCliTerContabil Varchar(1),
					@cd_cuenta_IVAPenalidad VARCHAR(16),
					@cd_cuenta_IVAPenalidadSUC VARCHAR(16),
					@cd_cuenta_IVAPenalidadIMP VARCHAR(16),
					@bl_cuenta_IVAPenalidad VARCHAR(1),
					@cd_impuestotaonac CHAR(3), /*inicio rgelis 2014/10/22 req.22121*/
					@cd_impuestotaoint CHAR(3), 
					@id_impuestotaonac INT, 
					@id_impuestotaoint INT, /*fin rgelis 2014/10/22 req.22121*/
					@bl_interface INT,
					@Decimales INT,
					@bl_ContabilizarNitProv BIT, /*rgelis 2016/12/09 req.34960*/
					--Inicio Jramirez 2016/10/11 R3244
					@SaldoFactura Money, 
					@bl_refacturacion  INT, 
					@bl_refacturacion_contabilizar_saldos INT,
					@fuente_refacturacion varchar(2), 
					@numdoctra_refacturacion varchar(10),
					@bl_LlevarSrvTercero INT, 
					@cd_proveedorTAO Varchar(25),
					--Fin Jramirez 2016/10/11 R3244
					@bl_QuitarCerosIzquierda BIT,
					@bl_QuitarSerieDocumento BIT,
					@bl_AgregarPrefijoResolucion BIT,
					@cd_prefijo varchar(25),
					@numefac varchar(25)
			--Variables de Resoluciones
			Declare 
				@procmsgRC varchar(8000)
				,@ResolucionmsgRC varchar(8000)
			--Variables RC automatico
			Declare @cd_fuenteRC CHAR(2)
				,@cd_serieRC CHAR(2)
				,@cd_consecutivoRC varCHAR(8)
				,@cd_fuenteRCOtr CHAR(2)
				,@cd_fuenteRC_F CHAR(2)
				,@TotalRc MONEY
				,@id_FpRc INT
				,@id_FpRcAux INT
				,@bl_GenerarSoloUnRCPorFP BIT;	/*rgelis 2016/07/15 req.32431*/			
				
			--Tipo de documento de la factura
			Select @TipoDocumento = rtrim(Valor) From dbo.parametros Where Id = 237
			--Llevar al Cliente y Tercero de la Factura la contabilización de cargos de servicios con cuentas parametrizadas
			Select @LlevarCliTerContabil = rtrim(Valor) From dbo.parametros Where Id = 332

			--Otra cuanta para el iva de las penalidades
			Select @cd_cuenta_IVAPenalidad = rtrim(Valor) From dbo.parametros Where Id = 349
			Select @bl_cuenta_IVAPenalidad = rtrim(Valor) From dbo.parametros Where Id = 350  
			
			Select @cd_impuestotaonac = rtrim(Valor) From dbo.parametros Where Id = 330	/*inicio rgelis 2014/10/22 req.22121*/
			Select @cd_impuestotaoint = rtrim(Valor) From dbo.parametros Where Id = 331 
			select @id_impuestotaonac=id from ImpRet where cd_codigo =@cd_impuestotaonac
			select @id_impuestotaoint=id from ImpRet where cd_codigo =@cd_impuestotaoint /*fin rgelis 2014/10/22 req.22121*/	
			
			Set @bl_manejarcencostoImplante = 0
			SELECT @bl_manejarcencostoImplante = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 137
			--Decimales
			SELECT @Decimales = Valor FROM Parametros WHERE id=33

			Set @bl_QuitarCerosIzquierda = 0
			Set @bl_QuitarSerieDocumento = 0
			Set @bl_AgregarPrefijoResolucion = 0
			SELECT @bl_QuitarCerosIzquierda = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 588
			SELECT @bl_QuitarSerieDocumento = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 589
			SELECT @bl_AgregarPrefijoResolucion = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 590

			SELECT @bl_ContabilizarNitProv = CASE WHEN RTRIM(VALOR) ='S' THEN 1 ELSE 0 END from parametros where Id = 478 /*rgelis 2016/12/09 req.34960*/
 			Select 	@fuente    = f.cd_fuente,
					@numdoctra = f.cd_serie+f.cd_consecutivo,
					@factotal  = dbo.fnza_Get_FacturaTotal(@id_factura),
					@anomes = dbo.fnza_Get_ANODCTO(f.dt_fechacont),
					@fechadoc = dbo.fnza_Get_FECHDCTO(f.dt_fechacont),
					@Numdoc = @FUENTE+'-'+@NUMDOCTRA,
					@descridoc = CASE WHEN ISNULL(f.cd_TipoFact,'')<>'' THEN f.cd_TipoFact
								      ELSE @TipoDocumento END + ' '+@Numdoc+'. '+RTRIM(f.ds_tercero_nombre),
					@Bu = isnull(i.cd_bu,isnull(s.cd_bu,'')),
					@idtercero = f.cd_tercero_codigo,
					@idcliente = f.cd_cliente_codigo,
					@idvEnde = f.cd_vEndedor,
					@vencefac = dbo.fnza_Get_FECHDCTO(f.dt_vence),
					@ctacartera_Cli = isnull(c.CODICTA,''),
					@ctacartera_Suc = isnull(s.cd_cuenta_cartera,''),
					@ctacartera_Imp = isnull(i.cd_cuenta_cartera,''),
					@cliente = rtrim(f.ds_cliente_nombre),
					@moneda = m.cd_codigo,
					@tcambio = CASE WHEN f.bl_generadaauto = 0 AND f.am_tcambio > 1 THEN f.am_tcambio ELSE m.am_tasa_cambio END, /*rgelis 2015/11/26 Orden.421302*/
					@id_sucursal = s.id,
					@id_implante = i.id,
					@CtaCajaRcAuto = cd_CuentaCaja,
					@IdBancoRcAuto = cd_banco,
					@IdPlazaRcAuto = cd_plaza,
					@Cd_serieRcAuto = Cd_serieRC,
					@CtaCajaRcOtrAuto = cd_CuentaCajaOtr,
					@IdBancoRcOtrAuto = cd_bancoOtr,
					@IdPlazaRcOtrAuto = cd_plazaOtr,
					@Cd_serieRcOtrAuto = Cd_serieRCOtr,
					--@bl_RcAuto = bl_RcAuto, /* inicio rgelis 2012/10/11 req.10702*/
					--@bl_RcSoloTkt = bl_RcSoloTkt,
					--@bl_RcFac = bl_RcFac,
					--@bl_RcTktOtr = bl_RcTktOtr,
					@bl_RcAuto = ISNULL(CRC.bl_GenerarRC_Auto,0),
					@bl_RcSoloTkt = ISNULL(CRC.bl_GenerarRCSoloTkt,0),
					@bl_RcFac = ISNULL(bl_GenerarRCSoloFac,0),
					@bl_RcTktOtr = ISNULL(bl_GenerarRCIndependiente,0), /* fin rgelis 2012/10/11 req.10702*/
					@Id_Cierre = Id_Cierre,
					@NCF = f.NCF,
					@cd_cencoSucursal = CASE WHEN ISNULL(Tq.bl_cencosto,0)=1 AND ISNULL(Tq.cd_cencosto,'')<>'' THEN ISNULL(Tq.cd_cencosto,'') ELSE ISNULL(s.cd_cencosto,'') END, --rgelis 2017/09/14 req.52526 
					@cd_cencoImplante = CASE WHEN ISNULL(Tq.bl_cencosto,0)=1 AND ISNULL(Tq.cd_cencosto,'')<>'' THEN ISNULL(Tq.cd_cencosto,'') ELSE ISNULL(I.cd_cencosto,'') END, --rgelis 2017/09/14 req.52526
					@TipoDocumento = CASE WHEN ISNULL(f.cd_TipoFact,'')<>'' THEN f.cd_TipoFact
										ELSE @TipoDocumento
									END,	/*rgelis 2012/10/31 req.10779*/
					@bl_nocont = f.bl_nocont, --rgelis 2018/02/16 req.33683*/
					@cd_cuenta_IVAPenalidadSUC = ISNULL(s.cd_cuenta_IVAPenalidad,''),
					@cd_cuenta_IVAPenalidadIMP = ISNULL(i.cd_cuenta_IVAPenalidad,''),
					@cd_cencoSucursalTaoNac = ISNULL(tao.cd_cencosto,''), /*inicio rgelis 2014/10/22 req.22121*/
					@cd_cencoSucursalTaoInt = ISNULL(tao.cd_cencostoInternacional,''), 
					@id_impuestotaonac = ISNULL(tao.id_ImpRetIva,@id_impuestotaonac),
					@id_impuestotaoint = ISNULL(tao.id_ImpRetIvaInter,@id_impuestotaoint), /*fin rgelis 2014/10/22 req.22121*/	
					@bl_interface = bl_interface,
					@bl_refacturacion  = bl_refacturacion,
					@bl_refacturacion_contabilizar_saldos = bl_refacturacion_contabilizar_saldos,
					@bl_LlevarSrvTercero = tao.bl_LlevarSrvTercero,
					@cd_proveedorTAO = tao.cd_proveedor,
					@cd_prefijo = ISNULL(r.cd_prefijo,''),
					@numefac = CASE WHEN @bl_AgregarPrefijoResolucion = 1 THEN ISNULL(r.cd_prefijo,'') ELSE '' END + CASE WHEN @bl_QuitarSerieDocumento = 0 THEN CASE WHEN @bl_QuitarCerosIzquierda = 1 THEN CONVERT(VARCHAR(8),CONVERT(NUMERIC(18,0),f.cd_serie)) ELSE f.cd_serie END ELSE '' END + CASE WHEN @bl_QuitarCerosIzquierda = 1 THEN CONVERT(VARCHAR(8),CONVERT(NUMERIC(18,0),f.cd_consecutivo)) ELSE f.cd_consecutivo END

				From dbo.fac_factura f 
					INNER JOIN dbo.CLIENTES c On (f.cd_cliente_codigo=c.IDCLIENTE)
					INNER JOIN dbo.Sucursales s On (f.id_sucursal = s.id)
					INNER JOIN dbo.Monedas_IATA m On (f.id_monedas_IATA = m.id)
					LEFT JOIN dbo.Implantes I On (f.id_implante = I.id)
					LEFT JOIN dbo.ConfiguracioRecibosCaja As CRC ON CRC.id_Sucursal=f.id_sucursal And ISNULL(CRC.id_implante,0) = ISNULL(f.id_implante,0) /* rgelis 2012/10/11 req.10702*/
					LEFT JOIN dbo.TarifaAdministrativa tao ON tao.id_Sucursal=f.id_sucursal And ISNULL(tao.id_implante,0) = ISNULL(f.id_implante,0) /* rgelis 2014/10/22 req.22121*/
					LEFT JOIN dbo.Tiqueteadores Tq ON Tq.id=f.id_tiqueteador  --rgelis 2017/09/14 req.52526
					LEFT JOIN dbo.resoluciones r ON r.ds_num_resolucion = f.ds_num_resolucion
				Where f.id = @id_factura;
				
				/*inicio rgelis 2013/09/09 req.16665*/
				--Total Comisiones
				DECLARE @result AS MONEY
				SET @result=0
				--Total de impuestos de servicios
				SELECT @result=@result+sum(isnull(fsi.am_valor,0))
				FROM dbo.fac_factura f 
					LEFT JOIN dbo.fac_servicios fs ON (fs.id_fac_factura =f.id)
					INNER JOIN dbo.Fac_ServiciosCargos  fsc ON (fs.id = fsc.id_Fac_Servicios )
					LEFT JOIN dbo.Fac_ServiciosImpuestos  fsi ON (fsi.id_FacServiciosCargos = fsc.id)
					INNER JOIN dbo.ConceptoFacturacion cf ON (cf.id = fs.id_ConceptoFacturacion)
				WHERE f.id = @id_factura AND fs.bl_anulado = 0 AND fs.id_TiposConceptFac=4 AND cf.bl_llevarAlGasto = 1
				GROUP BY f.id;
				
				--Total de cargos de servicios
				SELECT @result=@result+sum(isnull(fsc.am_valor,0))
				FROM dbo.fac_factura f 
					LEFT JOIN dbo.fac_servicios fs ON (fs.id_fac_factura =f.id)
					INNER JOIN dbo.Fac_ServiciosCargos  fsc ON (fs.id = fsc.id_Fac_Servicios )
					INNER JOIN dbo.ConceptoFacturacion cf ON (cf.id = fs.id_ConceptoFacturacion) 
				WHERE f.id = @id_factura AND fs.bl_anulado = 0 AND fs.id_TiposConceptFac=4 AND cf.bl_llevarAlGasto = 1
				GROUP BY f.id;	
				
				SET @factotal = @factotal - @result*2 				
				/*fin rgelis 2013/09/09 req.16665*/

			/*inicio rgelis 2012/10/31 req.10779*/
			If isnull(@TipoDocumento,'') = ''
			Begin 
				Select 'Debe ingresar un tipo de documento para las Facturas. Verifique los parametros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End 
			IF Not Exists (Select * From dbo.TIPOFACT Where Tipofact = @TipoDocumento)
			Begin 
				Select 'Debe ingresar un tipo de documento valido para las Facturas. Verifique los parametros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End				
			/*fin rgelis 2012/10/31 req.10779*/
			
			If EXISTS(Select ANODCTO From dbo.DOCUMENT Where FNTEDCTO = @fuente AND NUMEDCTO = @numdoctra AND SUDBDCTO<>0 AND SUCRDCTO<>0 AND NUMTDCTO<>0)
			Begin 
				Select 'La factura ya se encuentra contabilizada' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End

			/*inicio rgelis 2014/08/13 req.21488*/
			IF EXISTS(Select * From dbo.Fac_Servicios fs					
					    INNER JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
						Where fs.id_fac_factura = @id_factura
						  AND p.Deshabilitado = 1 
						)
			BEGIN
				Select TOP(1) 'El proveedor '+p.IDPROVE +' del servicio '+ fs.ds_servicio + ' esta desabilitado. Verifique en el maestro proveedores' AS 'Respuesta', 1 AS 'Estado'
				FROM dbo.Fac_Servicios fs
				INNER JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
				WHERE fs.id_fac_factura = @id_factura
				AND p.Deshabilitado = 1
				SET	@retval = 1;
				RETURN @retval;
			END 
			/*fin rgelis 2014/08/13 req.21488*/

			If EXISTS(SELECT * From dbo.tiquetes t 
						INNER JOIN dbo.tiquetecargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
						LEFT  JOIN dbo.TiqueteImpuestos ti On (ti.id_TiqueteCargos  = tc.id)
						INNER JOIN dbo.ImpRet ir On (ir.id = ti.id_ImpRet)
						LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id) 
					Where t.id_fac_factura = @id_factura 
						  AND @bl_cuenta_IVAPenalidad = 'S'
						  AND ISNULL(t.cd_Penalidad,'') <> ''
						  AND ti.id_ImpRet IN(1,2,3,4,12)
						  AND @cd_cuenta_IVAPenalidad=''
						  AND @cd_cuenta_IVAPenalidadSUC=''
						  AND @cd_cuenta_IVAPenalidadIMP=''
				)
			Begin 
				Select 'Esta activo el parámetro "Utilizar Otra Cuenta para el IVA de la Penalidad" '+CHAR(13)+CHAR(10)+'y no asigno ninguna Cuenta. Verifique los parámetros del sistema' AS 'Respuesta', 1 AS 'Estado'
				SET	@retval = 1;
				RETURN @retval;
			End

			/*inicio rgelis 2012/10/01 req.10699*/ 
			select @ctacartera = ISNULL(CCC.cd_Cuenta,'')
			From dbo.fac_factura As f
				INNER JOIN dbo.Configuracion_remisiones As CR ON CR.Id_Cliente=f.cd_cliente_codigo
				INNER JOIN dbo.Clientes_CuentasCartera As CCC ON CCC.Id_Configuracion_remisiones=CR.Id 
			Where f.id = @id_factura
				And CCC.id_Moneda=f.id_monedas_IATA 
				And CCC.id_Sucursal=f.id_sucursal 
				And ISNULL(CCC.id_Implante,0) = ISNULL(f.id_implante,0)
				And CR.bl_utilizarCuentasCartera = 1;
			/*fin rgelis 2012/10/01 req.10699*/

			/*inicio rgelis 2013/03/07 req.10699*/	
			If(@ctacartera IS NULL OR rtrim(ltrim(@ctacartera)) = '')
			BEGIN
				select @ctacartera = ISNULL(CCC.cd_Cuenta,'')
				From dbo.fac_factura As f
					INNER JOIN dbo.Sucursales As S ON S.Id=f.id_Sucursal
					LEFT JOIN dbo.Implantes As I ON I.id=f.id_Implante 
					INNER JOIN dbo.Clientes_CuentasCartera As CCC ON CCC.Id_Sucursal=f.id_Sucursal And ISNULL(CCC.Id_Implante,0)=ISNULL(f.id_implante,0)
					left join configuracion_remisiones cr on cr.id = ccc.Id_Configuracion_remisiones
				Where f.id = @id_factura
					And CCC.id_Moneda=f.id_monedas_IATA
					And (CCC.Id_Configuracion_remisiones is null  OR (ccc.Id_Configuracion_remisiones is not null and cr.id_cliente = f.cd_cliente_codigo))
					And ((S.bl_UtilizarCxCMoneda=1 AND I.id IS NULL) OR ISNULL(I.bl_UtilizarCxCMoneda,0)=1);
			END	
			/*fin rgelis 2013/03/07 req.10699*/
			
			--Si el cliente no tiene cuenta de cartera asignada entonces se usa la cuenta de cartera por defecto
			--SET @ctacartera = '' /*rgelis 2012/10/01 req.10699 se comenta para que no asigne vacio*/
			Select @Manejactacartera_Suc = rtrim(ltrim(valor)) From Parametros Where Id = 132
			Select @Manejactacartera_Imp = rtrim(ltrim(valor)) From Parametros Where Id = 135
			If @Manejactacartera_Imp = 'S'  AND (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL) /*rgelis 2012/10/01 req.10699 se agrega para verifique que este vacia la cuenta de cartera*/ 
				SET @ctacartera = @ctacartera_Imp
				
			If @Manejactacartera_Suc = 'S'  AND (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL)
				SET @ctacartera = @ctacartera_Suc
			
			If (rtrim(ltrim(@ctacartera)) = '' OR rtrim(ltrim(@ctacartera)) IS NULL)
				SET @ctacartera = @ctacartera_Cli
					
			If rtrim(ltrim(@ctacartera))='' or @ctacartera is null 
			Begin 
				Select @ctacartera=rtrim(ltrim(valopar)) From dbo.Parametr Where PARAMETRO = 'CxCCli'
			End 

			/*inicio rgelis 2014/06/06 req,20533*/
			IF Exists(SELECT * FROM Parametros WHERE Id=334 AND LTRIM(Valor)='S')
			BEGIN
				SELECT @ctacartera_Tv=ISNULL(tv.cd_cuenta_cartera,'')  
				FROM dbo.fac_factura f 
				INNER JOIN dbo.TipoVenta tv ON tv.id = f.id_tipoventa
				WHERE f.id = @id_factura
				
				If IsNull(@ctacartera_Tv,'')<>''
					SET @ctacartera = @ctacartera_Tv
				  
			END
			/*fin rgelis 2014/06/06 req,20533*/	 
			
			--ObteniEndo CxP Nacional e Internacional por defecto para aerolineas
			Select @CxP_Nac = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 13;
			Select @CxP_Int = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 14; 
			
			--ObteniEndo la Cuenta Alterna para la TAO cuando tiene retencion (FELIX)
			Select @ManejarCtaAlternaTAO = bl_CuentaAlternaTAO From Configuracion_remisiones Where id_cliente =  @idcliente	   

			If @ManejarCtaAlternaTAO = 1
			Begin
				Select @CtaAlternaTAONac = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 201;
				Select @CtaAlternaTAOInter = rtrim(LEFT(rtrim(ltrim(p.valor)),16)) From dbo.Parametros p Where p.Id = 205;
				/*inicio rgelis 2014/10/22 req.22121*/
				SELECT @CtaAlternaTAONac = cd_CuentaAlternaNac
					  ,@CtaAlternaTAOInter = cd_CuentaAlternaInter
				FROM dbo.fac_factura ff 
				INNER JOIN dbo.TarifaAdministrativa tao ON (ISNULL(tao.id_Sucursal,0) = ISNULL(ff.id_sucursal,0) 
															AND ISNULL(tao.id_Implante,0) = ISNULL(ff.id_implante,0)) 
				WHERE ff.id=@id_factura 
				/*fin rgelis 2014/10/22 req.22121*/
			End

			--Longitud de la referencia de la factura para la CxP de servicios de proveedores
			Select @LongitudRefe = VALOPAR From dbo.Parametr Where PARAMETRO = 'LongitudRefe'
			Select @bl_ReferenciaCxPProveSrv = rtrim(ltrim(valor)) From DBO.PARAMETROS Where id = 212
			SELECT @bl_ReferenciaCxCProveSrv = rtrim(ltrim(valor)) From DBO.PARAMETROS Where id = 578 --rgelis 2019/07/31 req.60143
			--Iniciando / salvando transaccion depEndiEndo si ya esta iniciada o no--

		  	Begin TRAN;		
			
 			--Datos Cabecera--------------------------------------------------------------------
 			DELETE dbo.Document_Insertar Where SpId = @@SpId
			DELETE dbo.Document_AGEMIN Where SpId = @@SpId
			--Insertar en document_agemin--
			Insert Into dbo.Document_AGEMIN 
					(
						SPID,
						ANODCTO,
						FNTEDCTO,
						NUMEDCTO,
						FECHDCTO,
						NUMTDCTO,
						SUDBDCTO,
						SUCRDCTO,
						DESCDCTO,
						IDTERCERO,
						IDCLIPRV,
						BU
					)
				VALUES 
					(
						@@SPID,			
						@anomes,
						@fuente,
						@numdoctra,
						@fechadoc,
						-1,
						@factotal,
						@factotal,
						@descridoc,
						@idtercero,
						@idcliente,
						@Bu
					)

			------------------------------------------------------------------------------------			
			Insert Into dbo.Document_Insertar 
			Select  * From dbo.document_agemin Where FNTEDCTO=@FUENTE And NUMEDCTO=@NUMDOCTRA
			------------------------------------------------------------------------------------
	
			--Datos Detalle---------------------------------------------------------------------------
			Delete dbo.Transac_Insertar Where SpId = @@SPID
			DELETE dbo.TRANSAC_agemin Where spid = @@SPID
			IF @bl_nocont = 0
			BEGIN  
				--Insertar en transac_agemin---									
			
				-----------------------------------------------------------
				--Inicio Jramirez 2016/10/11 R3244
				-----------------------------------------------------------
				IF @bl_refacturacion = 1 AND @bl_refacturacion_contabilizar_saldos = 1
				BEGIN

					Declare @NFacturasRefacturacion INT, @anomesfac char(7), @FechaCorte  CHAR(10);
					Declare @TableRefacturaciones Table (cd_fuente Varchar(2), Numero Varchar(10))
				
					--Obtenemos la fecha actual
					SELECT @FechaCorte=replace(rtrim(VALOPAR),'/','') FROM Parametr WHERE PARAMETRO = 'FECHACT';
					SELECT @anomesfac = dbo.fnza_Get_ANODCTO(@FechaCorte);

					--Debemos Verificar si fue uno a uno o factura consolidada
					Set @NFacturasRefacturacion  = 0
					Select @NFacturasRefacturacion  = Count(*) From dbo.fac_factura_Refacturacion Where id_fac_factura_refacturacion = @id_factura

					--Se es una a ana la refacturacion
					IF @NFacturasRefacturacion = 1
					BEGIN
						--Obtenemos la informacion de la factura que genera la refacturacion
						Select
							@fuente_refacturacion = cd_fuente
							,@numdoctra_refacturacion = numero
						From dbo.fac_factura_Refacturacion
						Inner Join Fac_factura on Fac_factura.id =fac_factura_Refacturacion.id_fac_factura
						Where id_fac_factura_refacturacion = @id_factura

						--Obtenemos el saldo de la factura CxC
						Set @SaldoFactura = 0
						Select @SaldoFactura = SUM(ff.SACTFAC)
						FROM dbo.Transac t 
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
						INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
													AND ff.IDCLIPRV	= t.CLIPRV
													AND ff.TIPOFACT	= t.TIPOFAC
													AND ff.NUMEFAC	= t.NUMEFAC
													AND ff.VENCFAC	= t.VENCEFAC
													AND ff.REFEFAC	= t.REFEFAC
													AND ff.CLASECP='C'
													AND ff.ANOMESFAC=@anomesfac
						Where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  --And t.INDCPITRA='2'
					
						If @SaldoFactura IS NULL
						Begin
							DELETE dbo.Document_Insertar Where SpId = @@SpId
							DELETE dbo.Document_AGEMIN Where SpId = @@SpId
							--Si la transaccion fue creada en el procedimiento entonces se actualiza--
 		 					If (XACT_STATE() <> 0) and (@@TRANCOUNT > 0) 
	   						Begin 
								COMMIT TRAN;	
							End 
							set @retval = 0;
							RETURN @retval;
						End
						If @SaldoFactura > 0
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@SaldoFactura,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										@SaldoFactura*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
							where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  And t.INDCPITRA='2'
						End
						If @SaldoFactura = 0 
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@factotal,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										@factotal*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
							where t.idfuente=@fuente_refacturacion and t.numdoctra =@numdoctra_refacturacion  And t.INDCPITRA='2'
						End
					
					END 
					ELSE IF @NFacturasRefacturacion > 1
					BEGIN
						--Obtenemos la informacion de la factura que genera la refacturacion
						Insert Into @TableRefacturaciones
						Select
							cd_fuente
							,numero
						From dbo.fac_factura_Refacturacion
						Inner Join dbo.Fac_factura on Fac_factura.id =fac_factura_Refacturacion.id_fac_factura
						Where id_fac_factura_refacturacion = @id_factura

						--Obtenemos el saldo de todas las facturas CxC
						Set @SaldoFactura = 0
						Select @SaldoFactura = sum(ff.SACTFAC)
						FROM dbo.Transac t 
						Inner Join @TableRefacturaciones tr on tr.cd_fuente = t.idfuente and tr.numero = t.numdoctra
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
						INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
													AND ff.IDCLIPRV	= t.CLIPRV
													AND ff.TIPOFACT	= t.TIPOFAC
													AND ff.NUMEFAC	= t.NUMEFAC
													AND ff.VENCFAC	= t.VENCEFAC
													AND ff.REFEFAC	= t.REFEFAC
													AND ff.CLASECP='C'
													AND ff.ANOMESFAC=@anomesfac

						If @SaldoFactura > 0
						Begin
							--Generamos la cartera del cliente por el saldo de la factura.
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							VALUES 
								(
									@@SPID,						
									@ctacartera,
									@idtercero,
									LEFT('CxC: '+ rtrim(@cliente),40),
									@SaldoFactura,
									2,
									@idcliente,
									@TipoDocumento,
									@vencefac,
									@numefac,--@numdoctra,
									@Bu,
									''
								)
							--Matamos la cartera en la factura anterior
 							Insert Into dbo.Transac_AGEMIN 
									(
										spid, codicta, nittra, descritra, valortra, indcpitra, cliprv, tipofac, vencefac, numefac, BU, RefeFac
									)
							Select 		@@SPID,
										t.codicta,
										t.nittra,
										t.descritra,
										ff.SACTFAC*-1,
										t.indcpitra,
										t.cliprv,
										t.tipofac,
										t.vencefac,
										t.numefac,
										t.BU,
										t.RefeFac	
							FROM dbo.Transac t 
							Inner Join @TableRefacturaciones tr on tr.cd_fuente = t.idfuente and tr.numero = t.numdoctra
							INNER JOIN dbo.BU b ON b.Codigo = t.BU
							INNER JOIN dbo.MaeLibros ON iden_libro = Libro AND eslibroprincipal = 1
							INNER JOIN facturas ff on	ff.CODICTA	= t.CODICTA
														AND ff.IDCLIPRV	= t.CLIPRV
														AND ff.TIPOFACT	= t.TIPOFAC
														AND ff.NUMEFAC	= t.NUMEFAC
														AND ff.VENCFAC	= t.VENCEFAC
														AND ff.REFEFAC	= t.REFEFAC
														AND ff.CLASECP='C'
														AND ff.ANOMESFAC=@anomesfac
						End

					END 

					--8) Actualizando campos comunes
					Update dbo.Transac_AGEMIN SET 
							anotra 	 	= @anomes,
							idfuente 	= @fuente,
							numdoctra	= @numdoctra,
							fechatra	= @fechadoc,
							idvEnde		= @idvEnde,
							idusuario	= 'Zeus Agencia Mn',
							fechafact	= @fechadoc,					
							indcpitra	= dbo.fnza_GetTipoCuenta(codicta),
							AUXIAUX		= CASE WHEN dbo.fnza_GetTipoCuenta(CODICTA)='5' AND ISNULL(AUXIAUX,'')='' THEN dbo.fnza_GetAuxiAbierto(CODICTA) ELSE AUXIAUX END
					Where SpId = @@SPID; 		

					Update dbo.Transac_AGEMIN 
					SET BU = @Bu
					Where SpId = @@SPID AND (BU IS NULL OR BU = ''); 
				END
				-----------------------------------------------------------
				--Fin Jramirez 2016/10/11 R3244
				-----------------------------------------------------------
				ELSE
				BEGIN 
					--1) Insertando registro de cartera (cuenta por cobrar)
					--1a) ObteniEndo las obligaciones a terceros
					Declare @t TABLE (
										spid 		INT  ,
										codicta 	VARCHAR (16) ,
										nittra 		VARCHAR(25),
										descritra 	VARCHAR(40),
										valortra 	MONEY ,
										indcpitra 	CHAR(1),
										cliprv 		CHAR(10)
									)

					Insert Into @t 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(tf.am_valor),'2',isnull(c.IDCLIENTE ,@idcliente)
						From dbo.Tiquetes t 
							INNER JOIN dbo.TiqueteFormasPago tf On (t.id = tf.id_Tiquetes AND tf.id_fac_factura = @id_factura)
							INNER JOIN dbo.FormasPago fp On (tf.id_FormasPago = fp.id)
							LEFT JOIN dbo.CLIENTES c On  (c.IDCLIENTE=isnull(fp.cd_Tercero,'')) --(c.IDTERCERO=fp.cd_Tercero or (fp.cd_tercero is null and c.idtercero=''))
						Where t.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre,c.IDCLIENTE 
					UNION 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(fsp.am_valor),'2',isnull(c.IDCLIENTE,@idcliente)
						From dbo.Fac_Servicios fs 
							INNER JOIN dbo.Fac_ServiciosFormasPago fsp On (fs.id = fsp.id_Fac_Servicios  AND fsp.id_fac_factura = @id_factura)
							INNER JOIN dbo.FormasPago fp On (fsp.id_FormasPago = fp.id)		
							LEFT JOIN dbo.CLIENTES c On (c.IDCLIENTE=isnull(fp.cd_Tercero,''))
						Where fs.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre,c.IDCLIENTE 
					UNION 
					Select @@SPID, ISNULL(fp.cd_Cuenta,@ctacartera),isnull(fp.cd_Tercero,@idtercero),'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0))), sum(ftp.am_valor),'2',isnull(c.IDCLIENTE,@idcliente)
						From dbo.fac_TAO ft 
							INNER JOIN dbo.Fac_TaoFormasPago ftp On (ft.id = ftp.id_Fac_Tao AND ftp.id_fac_factura = @id_factura)
							INNER JOIN FormasPago fp On (ftp.id_FormasPago = fp.id)		
							LEFT JOIN dbo.CLIENTES c On (c.IDCLIENTE=isnull(fp.cd_Tercero,''))
						Where ft.id_fac_factura = @id_factura 
							AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
						GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre ,c.IDCLIENTE
								
					/*--Se cambio por que en Halcon son mayoristas y alla necesitan que se valla a un proveedor.
					Select 
						@@SPID
						, ISNULL(fp.cd_Cuenta,@ctacartera)
						, isnull(fp.cd_Tercero,isnull(P.IDTERCERO,@idtercero))
						, 'CxC '+isnull(fp.cd_Tercero,rtrim(dbo.fn_padstr(rtrim(ltrim(fp.ds_nombre)),14,space(1),0)))
						, sum(ftp.am_valor)
						, '2'
						, isnull(c.IDCLIENTE,isnull(P.IDPROVE,@idcliente))
					From dbo.fac_TAO ft 
						INNER JOIN dbo.Fac_TaoFormasPago ftp On (ft.id = ftp.id_Fac_Tao AND ftp.id_fac_factura = @id_factura)
						INNER JOIN FormasPago fp On (ftp.id_FormasPago = fp.id)	
						INNER JOIN dbo.ConceptoFacturacion cf on cf.cd_codigo = CASE WHEN ft.in_nacionalidad=1 THEN 'CAN' ELSE 'CAI' END 
						LEFT JOIN PROVEEDORES p ON p.IDPROVE = cf.cd_proveedor
						LEFT JOIN dbo.CLIENTES c On (c.IDTERCERO=isnull(fp.cd_Tercero,''))
					Where ft.id_fac_factura = @id_factura 
						AND (fp.cd_Tercero IS NOT NULL OR fp.cd_Cuenta IS NOT NULL)
					GROUP BY fp.cd_Tercero,fp.cd_Cuenta,fp.ds_nombre ,c.IDCLIENTE,P.IDTERCERO, p.IDPROVE	*/				
			
					/* INICIO - JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/
					DECLARE 
						 @bl_DescontarComisionCxP		BIT
						, @CxP_Comisiones				VARCHAR(16)
						, @Descritra_Comisiones			VARCHAR(40)
						, @Factura_Comisiones			VARCHAR(10)
						, @RefeFac_Comisiones			VARCHAR(40)
						, @TipoFac_Comisiones			VARCHAR(2)
						, @VenceFac_Comisiones			VARCHAR(10)

					IF EXISTS(	SELECT ff.Id 
								FROM dbo.fac_factura f
								INNER JOIN dbo.fac_factura ff ON ff.id = f.id_fac_facturaRelacionada AND ff.bl_comisiona = 1
								WHERE f.id = @id_factura AND f.bl_DescontarComisionCxP = 1)
					BEGIN 
						SELECT 
							@CxP_Comisiones=t.CODICTA
							, @TipoFac_Comisiones = t.TIPOFAC
							, @Factura_Comisiones=t.NUMEFAC
							, @VenceFac_Comisiones = t.VENCEFAC
							, @RefeFac_Comisiones = t.REFEFAC
							, @Descritra_Comisiones = t.DESCRITRA 
							,@bl_DescontarComisionCxP = 1
						FROM dbo.fac_factura f
						INNER JOIN dbo.fac_factura ff ON ff.id = f.id_fac_facturaRelacionada
						INNER JOIN dbo.TRANSAC t on t.IDFUENTE = ff.cd_fuente AND t.NUMDOCTRA = ff.numero
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro
						WHERE f.id = @id_factura and t.INDCPITRA='3' AND eslibroprincipal = 1
					END 
					ELSE IF EXISTS(	SELECT ff.Id 
								FROM dbo.fac_factura f
								INNER JOIN dbo.fac_remision ff ON ff.id = f.id_fac_RemisionRelacionada AND ff.bl_comisiona = 1
								WHERE f.id = @id_factura AND f.bl_DescontarComisionCxP = 1)
					BEGIN 
						SELECT 
							@CxP_Comisiones=t.CODICTA
							, @TipoFac_Comisiones = t.TIPOFAC
							, @Factura_Comisiones=t.NUMEFAC
							, @VenceFac_Comisiones = t.VENCEFAC
							, @RefeFac_Comisiones = t.REFEFAC
							, @Descritra_Comisiones = t.DESCRITRA 
							, @bl_DescontarComisionCxP = 1
						FROM dbo.fac_factura f
						INNER JOIN dbo.fac_remision ff ON ff.id = f.id_fac_RemisionRelacionada
						INNER JOIN dbo.TRANSAC t on t.IDFUENTE = ff.cd_fuente AND t.NUMDOCTRA = ff.numero
						INNER JOIN dbo.BU b ON b.Codigo = t.BU
						INNER JOIN dbo.MaeLibros ON iden_libro = Libro
						WHERE f.id = @id_factura and t.INDCPITRA='3' AND eslibroprincipal = 1
					END 
					/* FIN - JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/

					--Restando el valor cubierto por FP u otros Terceros de  la CxC al cliente 
					Select @CxC_Val = @factotal - isnull(sum(valortra),0) From @t
					--Insertando CxC al cliente
 					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								BU,
								RefeFac		
							)
						VALUES 
							(
								@@SPID,						
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @CxP_Comisiones ELSE @ctacartera END, /*JARG - 2016/03/16 - Req.30452 - Generar alerta si el concepto de facturacion o tipo de servicio esta marcado*/
								@idtercero,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @Descritra_Comisiones ELSE LEFT('CxC: '+ rtrim(@cliente),40) END,
								@CxC_Val,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN 3 ELSE 2 END,
								@idcliente,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @TipoFac_Comisiones ELSE @TipoDocumento END,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @VenceFac_Comisiones ELSE @vencefac END,
								CASE WHEN @bl_DescontarComisionCxP = 1 THEN @Factura_Comisiones ELSE @numefac END, --@numdoctra END,
								@Bu,
								CASE 
									WHEN @bl_DescontarComisionCxP = 1 THEN @RefeFac_Comisiones 
									WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') --rgelis 2019/07/31 req.90143
									ELSE '' END
							)
						
					--Insertando registros de cartera a otros terceros
					Insert Into dbo.Transac_AGEMIN (spid,codicta,nittra,descritra,valortra,indcpitra,cliprv,TIPOFAC,vencefac,numefac)
						Select spid,codicta,nittra,descritra,ISNULL(sum(valortra),0),indcpitra,cliprv,@TipoDocumento,@vencefac,@NUMDOCTRA
							From @t
							GROUP BY spid,codicta,nittra,descritra,indcpitra,cliprv


					--Calculando valor totla cubierto por anticipos del cliente.
					-- y obteniEndo el BU del anticipo
					Select 
						@totalant=isnull(sum(valor) ,0)
						--,@BU_Anticipo = BU	/*rgelis 2015/10/13 se comentarea porque no permite realizar la suma de anticipos cuando hay varios BU */
					From dbo.AnticiposCliente 
					Where id_fac_factura=@id_factura;
					--GROUP BY BU; 			
		
					--Insertando registro de disminucion de cartera por el valor total cubieto por anticipos
		 			Insert Into dbo.Transac_AGEMIN 
						(
							spid,
							codicta,
							nittra,
							descritra,
							valortra,
							indcpitra,
							cliprv,
							tipofac,
							vencefac,
							numefac,
							bu,
							REFEFAC 
						)
					VALUES 
						(
							@@SPID,						
							@ctacartera,
							@idtercero,
							LEFT('Disminucion de CxC por cruce de anticipo',40),
							@totalant*-1,
							2,
							@idcliente
							,@TipoDocumento
							,@vencefac
							,@NUMDOCTRA
							,@BU
							,CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END--rgelis 2019/07/31 req.90143
						)					
			
			
					--Insertando registros para disminuir saldo a favor del cliente
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								valormoneda,
								tasacambio,
								BU,
								IdItem
							)
			 			Select 	 @@SPID
			 					,cuenta
			 					,@idtercero
			 					,LEFT('DB a anticipo #: '+rtrim(ltrim(numero)),40)
			 					,valor = a.Valor  			 			
			 					,'3'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,a.ValorUSD 
			 					,a.TcFac 
			 					,BU
								,IdItem 
			 				From dbo.AnticiposCliente a Where id_fac_factura=@id_factura;
			
					--Insertando registros de difrencia en cambio a favor
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								bu
							)
			 			Select 	 @@SPID
			 					,m.CODIAJUSTE
			 					,@idtercero
			 					,'Diferencia en cambio a favor'
			 					,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,bu
			 				From dbo.AnticiposCliente a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac<a.TcAnticipo
			 					AND m.CODIAJUSTE IS NOT NULL AND m.CODIAJUSTE <>''
			 					;
			
					--Insertando registros de ajuste en cambio a favor (cuenta de anticipo)
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								statustra,
								bu,
								IdItem
							)
			 			Select 	 @@SPID
			 					,a.Cuenta 
			 					,@idtercero
			 					,'Ajuste moneda en cambio a favor'
			 					,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,'AJ'
			 					,bu
								,IdItem
			 				From dbo.AnticiposCliente a 
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac<a.TcAnticipo
			 					AND a.TcAnticipo>0;
			
					--Insertando registros de difrencia en cambio a perdida
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								bu
							)
			 			Select 	 @@SPID
			 					,m.CtaAjusteMonPerdida 
			 					,@idtercero
			 					,'Ajuste moneda en cambio en contra'
			 					,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,bu
			 				From dbo.AnticiposCliente a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac>a.TcAnticipo
			 					AND m.CtaAjusteMonPerdida IS NOT NULL AND m.CtaAjusteMonPerdida<>''
			 					;
			
					--Insertando registros de difrencia en cambio a perdida
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								refefac,
								idzona,
								tipofac,
								idvEnde,
								vencefac,
								numefac,
								statustra,
								bu,
								IdItem
							)
			 			Select 	 @@SPID
			 					,a.Cuenta  
			 					,@idtercero
			 					,'Ajuste moneda en cambio en contra'
			 					,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 					,'1'
			 					,cliprv			 			
			 					,referencia			 			
			 					,zona
			 					,TIPO
			 					,vEndedor
			 					,vencimiento
			 					,numero
			 					,'AJ'
			 					,bu
								,IdItem
			 				From dbo.AnticiposCliente a
			 				Where id_fac_factura=@id_factura
			 					AND a.TcFac>a.TcAnticipo 
								AND a.TcAnticipo>0;
					---------------------------------------			
					-- Fin anticipo del cliente -----------
					---------------------------------------
			
					--Calculando valor totla cubierto por anticipos del Proveedor.
					-- y obteniEndo el BU del anticipo
					If EXISTS (Select * From dbo.AnticiposProveedores Where id_fac_factura=@id_factura)
					Begin 
						Declare 
							@Count INT,
							@Max_Id INT,
							@Id_fac_Servicio INT,
							@cd_tercero_AntProve VARCHAR(10),
							@cd_proveedores VARCHAR(10),
							@ds_proveedores VARCHAR(250),
							@id_ConceptoFacturacion INT, 
							@id_TiposServicio INT,
							@ds_servicio VARCHAR(25),
							@totalantProve MONEY,
							@BU_AnticipoProve VARCHAR(25),/*rgelis 2013/03/05 req.3505*/ 
							@CtaCxPAnticipoProve VARCHAR(16),
							@Id_Tiquete INT /*rgelis 2014/12/03 req.22131*/
				
						--Creamos una table temporal e insertamos los servicios con anticipos a proveedores.				
						Declare @TAntProve TABLE (Id INT IDENTITY, Id_fac_Servicio INT, cd_tercero_AntProve VARCHAR(10), cd_proveedores VARCHAR(10), ds_proveedores VARCHAR(250),id_ConceptoFacturacion INT, id_TiposServicio INT, ds_servicio VARCHAR(25),id_Tiquete INT) /*rgelis 2014/12/03 req.22131*/
				
						Insert Into @TAntProve (Id_fac_Servicio, cd_tercero_AntProve, cd_proveedores, ds_proveedores, id_ConceptoFacturacion, id_TiposServicio, ds_servicio,id_Tiquete)/*rgelis 2014/12/03 req.22131*/
						Select Fac_servicios.Id, IDTERCERO, cd_proveedores, RAZONCIAL, id_ConceptoFacturacion, id_TiposServicio, LEFT(rtrim(Fac_servicios.ds_servicio),25), NULL AS 'id_Tiquete' /*rgelis 2014/12/03 req.22131*/
						From dbo.Fac_servicios 
						INNER JOIN dbo.AnticiposProveedores On (AnticiposProveedores.id_fac_servicios = Fac_servicios.id AND AnticiposProveedores.id_fac_factura = Fac_servicios.id_fac_factura)
						INNER JOIN dbo.proveedores On (proveedores.IDPROVE = Fac_servicios.cd_proveedores)
						Where Fac_servicios.id_fac_factura = @Id_factura
				
						UNION ALL /*inicio rgelis 2014/12/03 req.22131*/
				
						Select NULL AS 'Id_fac_Servicio', P.IDTERCERO, E.cd_proveedor, P.RAZONCIAL, T.in_nacionalidad AS 'id_ConceptoFacturacion', T.id_TiposDocumento AS 'id_TiposServicio', 'Tkt. '+T.cd_tiquete AS 'ds_servicio', T.id AS 'id_Tiquete'
						From dbo.Tiquetes T
						INNER JOIN dbo.AnticiposProveedores A On (A.id_tiquetes = T.id AND A.id_fac_factura = T.id_fac_factura)
						INNER JOIN Entidades E ON (E.id = T.id_entvend) 
						INNER JOIN dbo.proveedores p On (p.IDPROVE = E.cd_proveedor)
						Where T.id_fac_factura = @Id_factura
						/*fin rgelis 2014/12/03 req.22131*/
				
						SET @Count = 1;
						Select @Max_Id = max(id) From @TAntProve;

						WHILE @Count <= @Max_Id
						Begin
							--Obtenemos los datos del servcio de proveedores que vamos a cruzar.
							Select 					
								@Id_fac_Servicio = Id_fac_Servicio,
								@cd_tercero_AntProve = cd_tercero_AntProve,
								@cd_proveedores = cd_proveedores,
								@ds_proveedores = ds_proveedores,
								@id_ConceptoFacturacion = id_ConceptoFacturacion, 
								@id_TiposServicio = id_TiposServicio,
								@ds_servicio = ds_servicio,
								@Id_Tiquete = id_Tiquete /*rgelis 2014/12/03 req.22131*/
							From @TAntProve Where id = @Count
					
							IF ISNULL(@Id_Tiquete,0) = 0  /*inicio rgelis 2014/12/03 req.22131*/
							BEGIN
								SET @CtaCxPAnticipoProve = dbo.fnza_GetServicioCxP(@id_fac_servicio,@cd_proveedores,@id_ConceptoFacturacion,@id_TiposServicio)

							END 
							ELSE
							BEGIN
								SELECT @CtaCxPAnticipoProve = CASE WHEN t.in_nacionalidad =1 AND e.cd_cta_nac IS NOT NULL AND e.cd_cta_nac<>'' 
																	 THEN e.cd_cta_nac
																   WHEN t.in_nacionalidad =1 AND @CxP_Nac IS NOT NULL AND @CxP_Nac<>''
																	 THEN @CxP_Nac
																   WHEN t.in_nacionalidad =2 AND e.cd_cta_int IS NOT NULL AND e.cd_cta_int<>'' 
																	 THEN e.cd_cta_int
																   WHEN t.in_nacionalidad =2 AND @CxP_Int IS NOT NULL AND @CxP_Int<>''
																	 THEN @CxP_Int
																   Else NULL 
															   END	
								FROM dbo.Tiquetes t	
								INNER JOIN dbo.Entidades e ON e.id=t.id_entvend
								WHERE t.id=	@Id_Tiquete

							END	 /*fin rgelis 2014/12/03 req.22131*/

							Select 
								@totalantProve=isnull(sum(valor),0),
								@BU_AnticipoProve = BU
							From dbo.AnticiposProveedores
							Where id_fac_factura=@id_factura and (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/ 
							GROUP BY BU;

							--Insertando registro de disminucion de cartera por el valor total cubieto por anticipos
		 					Insert Into dbo.Transac_AGEMIN 
								(
									spid,codicta,nittra,refefac,descritra,valortra,indcpitra,cliprv,tipofac,vencefac,numefac,bu
								)
							VALUES 
								(
									@@SPID,						
									@CtaCxPAnticipoProve,
									@cd_tercero_AntProve,
									@ds_servicio,
									LEFT('Disminucion de CxP por cruce de anticipo de proveedor',40),
									@totalantProve,
									2,
									@cd_proveedores,
									@TipoDocumento,
									@vencefac,
									@NUMDOCTRA,
									@BU_AnticipoProve
								)	

							--Insertando registros para disminuir saldo a favor del cliente
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,codicta,nittra,descritra,valortra,indcpitra,cliprv,refefac,idzona,tipofac,idvEnde,vencefac,numefac,valormoneda,tasacambio,BU,IdItem
									)
	 						Select 	 @@SPID
	 								,cuenta
	 								,@cd_tercero_AntProve
	 								,LEFT('DB a anticipo #: '+rtrim(ltrim(numero)),40)
	 								,valor = a.Valor*-1			 			
	 								,'3'
	 								,cliprv			 			
	 								,referencia			 			
	 								,zona
	 								,TIPO
	 								,vEndedor
	 								,vencimiento
	 								,numero
	 								,a.ValorUSD 
	 								,a.TcFac 
	 								,BU 
									,a.IdItem
	 						From dbo.AnticiposProveedores a
							Where id_fac_factura=@id_factura and (id_fac_servicios = @Id_fac_Servicio  OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/

							--Insertando registros de difrencia en cambio a favor
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										bu
									)
			 				Select 	 @@SPID
			 						,m.CODIAJUSTE
			 						,@cd_tercero_AntProve
			 						,'Diferencia en cambio a favor'
			 						,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,bu
			 				From dbo.AnticiposProveedores a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac<a.TcAnticipo
			 					AND m.CODIAJUSTE IS NOT NULL AND m.CODIAJUSTE <>''
			 					;
							
			
			
							--Insertando registros de ajuste en cambio a favor (cuenta de anticipo)
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										statustra,
										bu,
										IdItem
									)
			 				Select 	 @@SPID
			 						,a.Cuenta 
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio a favor'
			 						,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,'AJ'
			 						,bu
									,IdItem
			 				From dbo.AnticiposProveedores a 
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio  OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac<a.TcAnticipo
			 					AND a.TcAnticipo>0;
			
							--Insertando registros de difrencia en cambio a perdida
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										bu
									)
			 				Select 	 @@SPID
			 						,m.CtaAjusteMonPerdida 
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio en contra'
			 						,a.Valor - (a.ValorUSD*a.TcAnticipo)
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,bu
			 				From dbo.AnticiposProveedores a INNER JOIN dbo.MAECONT m On (a.Cuenta = m.CODICTA)
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac>a.TcAnticipo
			 					AND m.CtaAjusteMonPerdida IS NOT NULL AND m.CtaAjusteMonPerdida<>''
			 					;
			
							--Insertando registros de difrencia en cambio a perdida
							Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										cliprv,
										refefac,
										idzona,
										tipofac,
										idvEnde,
										vencefac,
										numefac,
										statustra,
										bu,
										IdItem
									)
			 				Select 	 @@SPID
			 						,a.Cuenta  
			 						,@cd_tercero_AntProve
			 						,'Ajuste moneda en cambio en contra'
			 						,(a.Valor - (a.ValorUSD*a.TcAnticipo))*-1
			 						,'1'
			 						,cliprv			 			
			 						,referencia			 			
			 						,zona
			 						,TIPO
			 						,vEndedor
			 						,vencimiento
			 						,numero
			 						,'AJ'
			 						,bu
									,IdItem
			 				From dbo.AnticiposProveedores a
			 				Where id_fac_factura=@id_factura
								AND (id_fac_servicios = @Id_fac_Servicio OR id_tiquetes = @Id_Tiquete) /*rgelis 2014/12/03 req.22131*/
			 					AND a.TcFac>a.TcAnticipo 
								AND a.TcAnticipo>0;

							SET @Count = @Count + 1;

						End 	
					End 
					--------------------------------------------------------
					-- Fin anticipo Proveedor ------------------------------
					--------------------------------------------------------
			
					--2) Insertando registros de tiquetes (cuenta por pagar)			
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac
							)
						Select 	@@SPID,
								'Codicta' = CASE 
												WHEN t.in_nacionalidad =1 AND e.cd_cta_nac IS NOT NULL AND e.cd_cta_nac<>'' 
													THEN e.cd_cta_nac
												WHEN t.in_nacionalidad =1 AND @CxP_Nac IS NOT NULL AND @CxP_Nac<>''
													THEN @CxP_Nac
												WHEN t.in_nacionalidad =2 AND e.cd_cta_int IS NOT NULL AND e.cd_cta_int<>'' 
													THEN e.cd_cta_int
												WHEN t.in_nacionalidad =2 AND @CxP_Int IS NOT NULL AND @CxP_Int<>''
													THEN @CxP_Int
												Else NULL 
											End,
								rtrim(p.IDTERCERO),
								LEFT('CxP '+rtrim(p.RAZONCIAL),40),
								sum(dbo.fnza_Get_TiqueteTotalCxP(@id_factura,NULL,t.id))*-1,
								convert(CHAR(1),'3'),
								rtrim(p.IDPROVE)
								,@TipoDocumento
								,@vencefac
								,@NUMDOCTRA
							From dbo.Tiquetes t
								INNER JOIN dbo.Entidades e On (t.id_entvEnd = e.id)			
								INNER JOIN dbo.PROVEEDORES p On (e.cd_proveedor = p.IDPROVE)			
							Where t.id_fac_factura = @id_factura
							GROUP BY p.IDTERCERO,p.IDPROVE, p.RAZONCIAL,e.cd_cta_nac,e.cd_cta_int,p.CODICTA,t.in_nacionalidad;

					--2.1)  Insertando cargos de tiquetes con cuentas parametrizadas
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,					
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								codicta = 	CASE 
												WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta
												Else c.cd_cuenta 
								   			End,	
								@idtercero,					
								LEFT(rtrim(tc.ds_cargonm)+ ': '+rtrim(t.cd_tiquete),40),
								sum(tc.am_valor)*-1,
								@idcliente  
							From dbo.tiquetes t 
								INNER JOIN dbo.TiqueteCargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
								INNER JOIN dbo.CargosDesc c On (c.id=tc.id_cargosdesc)		 
								LEFT JOIN dbo.Cargos_BU cb On (c.id=cb.id_cargo AND cb.id_cargo = tc.id)				
							Where t.id_fac_factura = @id_factura 
								AND abs(tc.am_valor)<>0
								AND dbo.fnza_CargoManejaCuenta(tc.id_cargosdesc)=1
								--AND isnull(cb.cd_bu,@Bu)=@Bu 
							GROUP BY c.cd_cuenta,cb.cd_cuenta,tc.ds_cargonm,t.cd_tiquete
			
					--2.2) Insertando registros de impuestos sobre cargos de tiquetes con cuentas parametrizadas 
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra, 
								baseretetra,
								tipofac,
								vencefac,
								numefac
							)
						Select 
							spid,
							codicta,
							nittra,
							descritra,
							valortra,
							indcpitra,
							cliprv,
							porretetra, 
							baseretetra,
							tipofac= Case WHEN indcpitra IN (2,3) THEN @TipoDocumento ELSE NULL END,
							vencefac=Case WHEN indcpitra IN (2,3) THEN @vencefac ELSE NULL END ,
							numefac=Case WHEN indcpitra IN (2,3) THEN @NUMDOCTRA ELSE NULL END 
						From(
							Select 	@@SPID As 'Spid',
								codicta = 	CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
													WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
													WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
													WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
													Else ir.cd_cuenta
								   			End,	
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN p.idtercero ELSE @idtercero END 'nittra',
								LEFT(ti.ds_Impas+': '+rtrim(t.cd_tiquete),40) As 'descritra',
								sum(ti.am_valor)*-1 as 'valortra',
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN dbo.fnza_GetTipoCuenta(CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End) ELSE convert(CHAR(1),'1') END AS 'indcpitra',
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN ti.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadSUC<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadSUC 
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidadIMP<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidadIMP
																	WHEN ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND @cd_cuenta_IVAPenalidad<>'' AND ti.id_ImpRet IN(1,2,3,4,12) THEN @cd_cuenta_IVAPenalidad  
																	WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																	Else ir.cd_cuenta
								   							End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN tid.id IS NOT NULL THEN ROUND(abs(tid.am_valor)*-1,@Decimales) ELSE ROUND((tc.am_valor)*-1 ,@Decimales) END
												End  
								From dbo.tiquetes t 
									INNER JOIN dbo.tiquetecargos tc On (t.id = tc.id_tiquetes AND t.id_fac_factura = tc.id_fac_factura)
									LEFT  JOIN dbo.TiqueteImpuestos ti On (ti.id_TiqueteCargos  = tc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = ti.id_ImpRet)
									LEFT  JOIN dbo.proveedores p on p.idprove = cd_proveedor
									LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id)
									LEFT  JOIN dbo.TiqueteImpuestos tid On (tid.id_ImpRet = ir.Id_imp_dep AND tid.id_TiqueteCargos  = ti.id_TiqueteCargos)
								Where t.id_fac_factura = @id_factura 
									AND abs(ti.am_valor)<>0
									AND isnull(ib.cd_bu,@bu)=@bu
									AND (dbo.fnza_CargoManejaCuenta(tc.id_cargosdesc)=1
										OR (ISNULL(t.cd_Penalidad,'') <>'' AND @bl_cuenta_IVAPenalidad = 'S' AND ti.id_ImpRet IN(1,2,3,4,12))
										OR (ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '')
										)
								GROUP BY ir.cd_cuenta,ti.ds_Impas,t.cd_tiquete,t.cd_Penalidad,ti.am_porcentaje,tc.am_valor,ib.cd_cuenta,ti.id_impret
								,ir.bl_contabilizar_proveedor,ir.cd_proveedor,p.idtercero,tid.id,tid.am_valor--R52825 - Jramirez - 20170919
							) Impuestos
						
					--3) Insertando registros de servicios de proveedor (cuenta por pagar) 
				
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								descritra,
								refefac,
								idcenco,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								iditem
							)
						SELECT 
							SPID
							, t.codicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN @idtercero ELSE nittra END AS 'nittra'
							, descritra
							, refefac
							, idcenco
							, valortra
							, m.indcpicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE cliprv END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE tipofac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE vencefac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE numefac END
							, cd_item 
						FROM (					
							Select 	SPID = @@SPID,
									dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio) AS 'codicta',
									p.IDTERCERO AS 'nittra',
									LEFT('CxP: '+rtrim(p.RAZONCIAL),40) AS 'descritra',
									CASE WHEN @bl_ReferenciaCxPProveSrv = 'S' THEN LEFT(rtrim(fs.ds_records),@LongitudRefe) Else '' END AS 'refefac',
									case when dbo.fnza_ManejaCenCo (dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio)) = 1 then ISNULL(fs.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
									sum(dbo.fnza_Get_FacServicioTotalCxP(fs.id,@BU))*-1 AS 'valortra',
									convert(CHAR(1),'3') AS 'indcpitra',
									p.IDPROVE AS 'cliprv'
									,@TipoDocumento AS 'tipofac'
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN dbo.fnza_Get_FECHDCTO(fs.dt_VenceFac) ELSE @vencefac END AS 'vencefac' /*inicio rgelis 2014/11/10 req.22115*/
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN fs.cd_NumeFac ELSE @NUMDOCTRA END AS 'numefac' /*fin rgelis 2014/11/10 req.22115*/
									, ts.bl_ContabilizarClienteFac
									, fs.cd_item
								From dbo.Fac_Servicios fs		
									INNER JOIN dbo.conceptofacturacion cf on (cf.id = fs.id_ConceptoFacturacion)			
									LEFT JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
									LEFT JOIN dbo.TiposServicios ts On (ts.id = fs.id_TiposServicio)
								Where fs.id_fac_factura = @id_factura 
									AND fs.id_TiposConceptFac = 2
									AND cf.bl_llevarAlIngreso = 0
								GROUP BY p.CODICTA
										,p.IDTERCERO
										,p.RAZONCIAL
										,p.IDPROVE
										,fs.id
										,fs.cd_proveedores
										,fs.id_ConceptoFacturacion
										,fs.id_TiposServicio
										,fs.cd_cencosto
										,fs.ds_records
										,ts.bl_ContabilizarClienteFac
										,fs.cd_item
										,fs.cd_NumeFac /*inicio rgelis 2014/11/10 req.22115*/
										,fs.dt_VenceFac	/*fin rgelis 2014/11/10 req.22115*/
						) AS T
						INNER JOIN MAECONT m ON m.CODICTA = t.CODICTA	
						
												
						--3.1)  Insertando cargos de servicios con cuentas parametrizadas
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,		
								auxiaux,
								idcenco,
								iditem,				
								descritra,
								valortra,
								cliprv,
								indcpitra,
								tipofac,
								vencefac,
								numefac
							)
						SELECT 
							SPID,
							t.codicta,
							t.nittra,
							t.cd_auxiliar,
							t.idcenco,
							t.cd_item,
							t.descritra,
							t.valortra,
							t.cliprv,
							m.indcpicta AS 'indcpitra',
							CASE WHEN m.indcpicta IN (1, 2, 3, 6) THEN @TipoDocumento ELSE NULL END AS 'tipofac',
							CASE WHEN m.indcpicta IN (1, 2, 3, 6) THEN (CASE WHEN RTRIM(ISNULL(t.cd_NumeFac,''))<>'' THEN dbo.fnza_Get_FECHDCTO(t.dt_VenceFac) ELSE @vencefac END) ELSE NULL END AS 'vencefac',
							CASE WHEN m.indcpicta IN (1, 2, 3, 6) THEN (CASE WHEN RTRIM(ISNULL(t.cd_NumeFac,''))<>'' THEN t.cd_NumeFac ELSE @NUMDOCTRA END) ELSE NULL END AS 'numefac'
						FROM (
							Select 	SPID = @@SPID,
									codicta = 	CASE 
													WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta
													WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta
													WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta
													Else c.cd_cuenta 
												End,	
									nittra = CASE 	WHEN EXISTS (
															SELECT 1 FROM dbo.Fac_ServiciosImpuestos fi_chk
															INNER JOIN dbo.ImpRet ir_chk ON ir_chk.id = fi_chk.id_ImpRet
															INNER JOIN dbo.Fac_ServiciosCargos fc_chk ON fc_chk.id = fi_chk.id_FacServiciosCargos
															WHERE fc_chk.id_Fac_Servicios = f.id AND ir_chk.bl_contabilizarCxPProvee = 1
														) AND dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 4 
														THEN ISNULL(p.IdTercero, @idtercero)
														WHEN @LlevarCliTerContabil = 'S' Then @idtercero
														WHEN dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 4 THEN p.IdTercero 
														Else @idtercero End,	
									f.cd_auxiliar,
									idcenco = case when dbo.fnza_ManejaCenCo (CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 1 then ISNULL(f.cd_cencosto,@cd_cencoSucursal) Else '' End,
									f.cd_item,				
									descritra = CASE WHEN EXISTS (
															SELECT 1 FROM dbo.Fac_ServiciosImpuestos fi_chk
															INNER JOIN dbo.ImpRet ir_chk ON ir_chk.id = fi_chk.id_ImpRet
															INNER JOIN dbo.Fac_ServiciosCargos fc_chk ON fc_chk.id = fi_chk.id_FacServiciosCargos
															WHERE fc_chk.id_Fac_Servicios = f.id AND ir_chk.bl_contabilizarCxPProvee = 1
														) AND dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 4 
														THEN LEFT('CxP: '+rtrim(p.RAZONCIAL),40) 
														ELSE LEFT(rtrim(fc.ds_cargonm)+ ': '+rtrim(f.ds_servicio),40) END,
									valortra = sum(fc.am_valor)*-1,
									cliprv = CASE 	WHEN EXISTS (
															SELECT 1 FROM dbo.Fac_ServiciosImpuestos fi_chk
															INNER JOIN dbo.ImpRet ir_chk ON ir_chk.id = fi_chk.id_ImpRet
															INNER JOIN dbo.Fac_ServiciosCargos fc_chk ON fc_chk.id = fi_chk.id_FacServiciosCargos
															WHERE fc_chk.id_Fac_Servicios = f.id AND ir_chk.bl_contabilizarCxPProvee = 1
														) AND dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 4 
														THEN ISNULL(p.IDPROVE, @idcliente)
														WHEN @LlevarCliTerContabil = 'S' Then @idcliente
														WHEN dbo.fnza_GetCatFinanciera(CASE WHEN cb.cd_cuenta IS NOT NULL AND cb.cd_cuenta<>'' THEN cb.cd_cuenta WHEN ts.cd_cuenta IS NOT NULL AND ts.cd_cuenta<>'' THEN ts.cd_cuenta WHEN cf.cd_cuenta IS NOT NULL AND cf.cd_cuenta<>'' THEN cf.cd_cuenta Else c.cd_cuenta End) = 4 THEN p.IDPROVE 
														Else @idtercero End,
									f.cd_NumeFac,
									f.dt_VenceFac,
									f.id AS id_fac_servicio
								From dbo.Fac_Servicios f 
									INNER JOIN dbo.conceptofacturacion cf on (cf.id = f.id_ConceptoFacturacion)
									LEFT JOIN dbo.TiposServicios ts On (ts.id = f.id_TiposServicio)
									LEFT JOIN dbo.PROVEEDORES p On (f.cd_proveedores = p.IDPROVE)					
									INNER JOIN dbo.Fac_ServiciosCargos fc On (f.id = fc.id_Fac_Servicios)
									INNER JOIN dbo.CargosDesc c On (c.id=fc.id_cargosdesc)		 
									LEFT JOIN dbo.Cargos_BU cb On (c.id=cb.id_cargo AND cb.id_cargo = fc.id)				
								Where f.id_fac_factura = @id_factura 
									AND abs(fc.am_valor)<>0
									AND dbo.fnza_CargoManejaCuenta(fc.id_cargosdesc)=1
									AND f.id_TiposConceptFac = 2
									AND cf.bl_llevarAlIngreso = 0
								GROUP BY c.cd_cuenta, cb.cd_cuenta, ts.cd_cuenta, cf.cd_cuenta, fc.ds_cargonm, f.ds_servicio, p.IdTercero, p.RAZONCIAL, p.IDPROVE, f.cd_auxiliar, f.cd_cencosto, f.cd_item, f.cd_NumeFac, f.dt_VenceFac, f.id
						) AS T
						INNER JOIN MAECONT m ON m.CODICTA = t.CODICTA
			
					--3.2) Insertando registros de Impuestos de servicios con cuentas parametrizadas	
					--xyz
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra,
								baseretetra
							)
						Select 	@@SPID,
								codicta = 	CASE
												WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
												Else ir.cd_cuenta
								   			End,
								@idtercero,
								f.cd_auxiliar,
								case when dbo.fnza_ManejaCenCo (CASE WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta Else ir.cd_cuenta End) = 1 then ISNULL(f.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								f.cd_item,	
								LEFT(fi.ds_Impas+': '+rtrim(f.ds_servicio),40),
								sum(fi.am_valor)*-1,
								convert(CHAR(1),'1'),
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE 
																WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																Else ir.cd_cuenta
									   						End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN fi.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE 
																WHEN ib.cd_cuenta IS NOT NULL AND ib.cd_cuenta<>'' THEN ib.cd_cuenta
																Else ir.cd_cuenta
									   						End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN fid.id IS NOT NULL THEN ROUND(abs(fid.am_valor)*-1,@Decimales) ELSE ROUND((fc.am_valor)*-1 ,@Decimales) END
												End  
							From dbo.Fac_Servicios  f 
								INNER JOIN dbo.conceptofacturacion cf on (cf.id = f.id_ConceptoFacturacion)
								INNER JOIN dbo.Fac_ServiciosCargos fc On (f.id = fc.id_Fac_Servicios)
								LEFT  JOIN dbo.Fac_ServiciosImpuestos  fi On (fi.id_FacServiciosCargos   = fc.id)
								INNER JOIN dbo.ImpRet ir On (ir.id = fi.id_ImpRet)
								LEFT  JOIN dbo.Impuestos_bu ib On (ib.id_impuesto = ir.id)
								LEFT  JOIN dbo.Fac_ServiciosImpuestos fid On (fid.id_ImpRet = ir.Id_imp_dep AND fid.id_FacServiciosCargos = fi.id_FacServiciosCargos)
							Where f.id_fac_factura = @id_factura 
								AND abs(fi.am_valor)<>0
								AND isnull(ib.cd_bu,@bu)=@bu
								AND dbo.fnza_ImpManejaCuenta(fi.Id_ImpRet,@BU)=1
								AND f.id_TiposConceptFac = 2 
								AND cf.bl_llevarAlIngreso = 0
							GROUP BY ir.cd_cuenta,fi.ds_Impas,f.ds_servicio,fi.am_porcentaje,fc.am_valor,ib.cd_cuenta,fi.id_impret,f.cd_auxiliar,f.cd_cencosto,f.cd_item,ir.bl_contabilizar_proveedor,ir.cd_proveedor,fid.id,fid.am_valor--R52825 - Jramirez - 20170919


					--Codigo del Cargo de comision para la factura nueva con las Comisiones y IVA de Comisiones de los tiquetes del cierre
					Select @CodComisionFacNuevaComCierre	= Valor From dbo.parametros Where Id = 224
					--Codigo del Impuesto IVA para la factura nueva con las Comisiones y IVA de Comisiones de los tiquetes del cierre
					Select @CodIVAFacNuevaComCierre	= Valor From dbo.parametros Where Id = 225
					
 					--4) Insertando registros de  ventas propias y comisiones (ingresos - contabilizacion por cargos)
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,						
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								codicta = 	CASE 
												WHEN (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1) THEN isnull(cd_cuenta_Causacion_Ingreso,'')
												WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, 'Comision')
												WHEN dbo.fnza_Get_CtaCargoBu(@Bu,fsc.id_cargosdesc)<>'' THEN dbo.fnza_Get_CtaCargoBu(@Bu,fsc.id_cargosdesc)
												WHEN isnull(c.cd_cuenta,'')<>'' THEN c.cd_cuenta
												WHEN cf.cd_codigo = 'CEM' THEN  dbo.fnza_Get_CargoEmisionCta(fs.in_nacionalidad,fs.cd_tiquete,@id_factura,null)
												WHEN cf.cd_codigo = 'SCR' THEN dbo.fnza_Get_ServiceChargeCta(fs.in_nacionalidad,fs.cd_tiquete)
												Else dbo.fnza_GetServicioCxP(fs.id,'',fs.id_ConceptoFacturacion,fs.id_TiposServicio)
								   			End,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,
								ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,						
								LEFT(rtrim(cf.ds_nombre)+ ': '+rtrim(fs.ds_servicio),40),
								CASE WHEN fs.id_TiposConceptFac = 3 Or cf.bl_llevarAlGasto = 0 THEN sum(fsc.am_valor)*-1 ELSE sum(fsc.am_valor)*1 END,/*rgelis 2013/09/09 req.16665*/
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDPROVE,'')<>'' THEN p.IDPROVE ELSE @idcliente END
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.CargosDesc c On (c.id=fsc.id_cargosdesc)
								INNER JOIN dbo.ConceptoFacturacion cf On (cf.id = fs.id_ConceptoFacturacion)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/ 
							Where fs.id_fac_factura = @id_factura 
							AND (fs.id_TiposConceptFac IN (3,4) OR (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1))
							AND abs(fsc.am_valor)<>0

							GROUP BY c.cd_cuenta,fs.ds_servicio,fsc.am_valor,cf.cd_cuenta,fsc.id_cargosdesc,cf.cd_codigo,fs.in_nacionalidad,fs.cd_tiquete,fs.id,fs.id_ConceptoFacturacion,fs.id_TiposServicio ,fs.cd_auxiliar ,fs.cd_cencosto,fs.cd_item ,cf.ds_nombre, fs.id_TiposConceptFac ,cf.bl_llevarAlGasto, p.IDTERCERO, p.IDPROVE/*rgelis 2013/09/09 req.16665*/ /*rgelis 2016/12/09 req.34960*/
							,bl_llevarAlIngreso, cd_cuenta_Causacion_Ingreso
					 

 					--5) Insertando registros de impuestos
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,
								auxiaux,/* inicio rgelis 2012/09/04 req.10397*/ 
								idcenco,
								iditem,/*fin rgelis 2012/09/04 req.10397*/ 
								descritra,
								valortra,
								indcpitra,
								cliprv,
								porretetra, 
								baseretetra
							)
						Select 	@@SPID,
								codicta = 	CASE 
												--WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, 'IVA sobre comisiones de tiquetes aereos')
												WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
												WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)
												--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
												WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta										
												Else ia.cd_cuenta
								   			End,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,/*inicio rgelis 2012/09/04 req.10397*/ 
								case when dbo.fnza_ManejaCenCo (CASE
																	WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																	WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																	WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)
																	--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																	WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta										
																	Else ia.cd_cuenta
								   								End) = 1 then ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,/*fin rgelis 2012/09/04 req.10397*/ 								
								--LEFT(fsi.ds_Impas+': '+rtrim(fs.ds_servicio),40),
								LEFT(fsi.ds_Impas+': ' + case when fs.cd_tiquete is not null then 'tkt.' + fs.cd_tiquete else '' end +rtrim(fs.ds_servicio),40),
								CASE WHEN fs.id_TiposConceptFac = 3 Or c.bl_llevarAlGasto = 0 THEN sum(fsi.am_valor)*-1 ELSE sum(fsi.am_valor)*1 END , /*rgelis 2013/09/09 req.16665*/
								convert(CHAR(1),'1'),
								CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
								'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE
																WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad) 
																WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)													
																--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta														
																Else ia.cd_cuenta
									   						End
								   						)
													WHEN 0 THEN 0
													WHEN 1 THEN fsi.am_porcentaje 
												End,
										
								'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje
														(
															CASE
																WHEN @Id_Cierre IS NOT NULL And @Id_Cierre <> '' THEN dbo.fnza_Get_CierreCtaFacturaCom (@Id_Cierre, CONVERT(VARCHAR(40),fsi.id_ImpRet))
																WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad) 
																WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fsi.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fsi.id_impret)													
																--WHEN c.cd_codigo = 'CEM' THEN dbo.fnza_Get_FacCemIvaCta(fs.in_nacionalidad)
																WHEN isnull(ia.cd_cuenta,'')='' THEN ir.cd_cuenta														
																Else ia.cd_cuenta
									   						End
								 						)
													WHEN 0 THEN 0
													WHEN 1 THEN CASE WHEN fsib.id IS NOT NULL 
																	 THEN ROUND((sum(fsib.am_valor))*-1 ,@Decimales) 
																	 ELSE ROUND((sum(fsc.am_valor))*-1 ,@Decimales)
																END
												End  
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.ConceptoFacturacion c On (fs.id_ConceptoFacturacion =c.id)					
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.Fac_ServiciosImpuestos fsi On (fsi.id_FacServiciosCargos = fsc.id)
								INNER JOIN dbo.ImpRet ir On (ir.id = fsi.id_ImpRet)
								LEFT  JOIN dbo.Impuestos_asignados ia On 
									(
											ia.id_ConceptoFacturacion = fs.id_ConceptoFacturacion
										AND ia.id_impuesto      	  = fsi.id_ImpRet 
									)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/
								LEFT JOIN dbo.Fac_ServiciosImpuestos fsib On (fsib.id_ImpRet = ir.Id_imp_dep AND fsib.id_FacServiciosCargos = fsi.id_FacServiciosCargos)
							Where fs.id_fac_factura = @id_factura AND fs.id_TiposConceptFac IN (3,4) AND abs(fsi.am_valor)>0
							GROUP BY fs.cd_tiquete, ir.cd_cuenta,fsi.ds_Impas,fs.ds_servicio,fsi.am_porcentaje,fsc.am_valor,ia.cd_cuenta,fsi.id_impret,c.cd_codigo,fs.in_nacionalidad,fs.cd_auxiliar,fs.cd_cencosto,fs.cd_item, fs.id_TiposConceptFac,c.bl_llevarAlGasto,p.IDTERCERO,fsib.id /*rgelis 2016/12/09 req.34960*/ /*rgelis 2013/09/09 req.16665*/,ir.bl_contabilizar_proveedor,ir.cd_proveedor--R52825 - Jramirez - 20170919
						
					--6) Insertando registros de TAO (ingresos)
					--xyz
					IF @bl_LlevarSrvTercero = 1 and isnull(@cd_proveedorTAO ,'') <> ''
					begin
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								codicta,
								nittra,					
								descritra,
								valortra,
								indcpitra,
								cliprv,
								TIPOFAC,
								VENCEFAC,
								NUMEFAC
							)
						Select 	
							@@SPID,
							CASE	WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 1 and @CtaAlternaTAONac is not null and @CtaAlternaTAONac <> '' THEN @CtaAlternaTAONac
									WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 2 and @CtaAlternaTAOInter is not null and @CtaAlternaTAOInter <> '' THEN @CtaAlternaTAOInter
									Else dbo.fnza_Get_FacTaoCta(ft.in_nacionalidad,ft.cd_tiquete,@id_factura,null) 
									End AS 'codicta',	
							p.IDTERCERO,					
							LEFT(rtrim(ftc.ds_cargonm)+ ' TAO TKT: '+rtrim(ft.cd_tiquete),40),
							sum(ftc.am_valor)*-1,
							convert(CHAR(1),'3'),
							p.IDPROVE,
							@TipoDocumento,
							@vencefac,
							@numdoctra
						From dbo.fac_tao ft 
							INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao AND ft.id_fac_factura = ftc.id_fac_factura)
							INNER JOIN dbo.CargosDesc c On (c.id=ftc.id_cargosdesc)		 
							outer apply (select * from proveedores where idprove = @cd_proveedorTAO) p 
						Where ft.id_fac_factura = @id_factura 
							AND abs(ftc.am_valor)<>0
						GROUP BY c.cd_cuenta,ftc.ds_cargonm,ft.cd_tiquete,ft.in_nacionalidad,p.IDTERCERO,p.IDPROVE	
						
						
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									cliprv,
								TIPOFAC,
								VENCEFAC,
								NUMEFAC
								)
							Select 	@@SPID,
									codicta = CASE 
												WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,null)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fti.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fti.id_impret)
												Else ir.cd_cuenta
											  End,
									p.IDTERCERO,
									LEFT(fti.ds_Impas+' . Tkt: '+rtrim(ft.cd_tiquete),40),
									(sum(fti.am_valor))*-1,
									convert(CHAR(1),'3'),
									p.IDPROVE,
									@TipoDocumento,
									@vencefac,
									@numdoctra 
								From dbo.fac_TAO ft 
									INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao)
									INNER JOIN dbo.Fac_TaoImpuestos fti On (fti.id_FacTaoCargos = ftc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = fti.id_ImpRet)
									outer apply (select * from proveedores where idprove = @cd_proveedorTAO) p 
								Where ft.id_fac_factura = @id_factura 
								GROUP BY ir.cd_cuenta
										,fti.ds_Impas 
										,ft.cd_tiquete
										,fti.am_porcentaje
										,ftc.am_valor
										,fti.id_ImpRet
										,ft.in_nacionalidad
										,ft.id_fac_factura  
										,p.IDTERCERO
										,p.IDPROVE
																						
					end
					else
					begin
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									auxiaux,
									idcenco,
									iditem,
									descritra,
									valortra,
									indcpitra,
									cliprv
								)
							Select 	@@SPID AS 'spid',
									CASE	WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 1 and @CtaAlternaTAONac is not null and @CtaAlternaTAONac <> '' THEN @CtaAlternaTAONac
											WHEN @ManejarCtaAlternaTAO = 1 and ft.in_nacionalidad = 2 and @CtaAlternaTAOInter is not null and @CtaAlternaTAOInter <> '' THEN @CtaAlternaTAOInter
											Else dbo.fnza_Get_FacTaoCta(ft.in_nacionalidad,ft.cd_tiquete,@id_factura,null) 
											End AS 'codicta',
									@idtercero AS 'nittra',
									ft.cd_aux AS 'auxiaux',
									CASE WHEN RTRIM(ISNULL(ft.cd_cencosto,''))<>'' THEN ft.cd_cencosto /*inicio rgelis 2014/10/22 req.22121*/
										 WHEN RTRIM(ISNULL(@cd_cencoSucursal,''))<>'' THEN @cd_cencoSucursal
										 WHEN ft.in_nacionalidad = 1 THEN @cd_cencoSucursalTaoNac
										 ELSE @cd_cencoSucursalTaoInt END AS 'idcenco', /*rgelis 2012/09/04 req.10397*//*fin rgelis 2014/10/22 req.22121*/
									ft.cd_coditem AS 'iditem',
									LEFT('TAO tkt: ' + rtrim(ft.cd_tiquete),40) AS 'descritra',
									dbo.fnza_Get_FacTaoCargos(ft.id)*-1 AS 'valortra',
									convert(CHAR(1),'1') AS 'indcpitra',
									@idcliente AS 'cliprv'
								From dbo.fac_TAO ft
								Where ft.id_fac_factura = @id_factura


			
						--7) Insertando registros de impuestos de TAO
						--xyz
						Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									cliprv,
									porretetra, 
									baseretetra
								)
							Select 	@@SPID,
									codicta = CASE 
												WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,null)
												WHEN dbo.fnza_Get_CtaImpuestoBu(@Bu,fti.id_impret)<>'' THEN dbo.fnza_Get_CtaImpuestoBu(@bu,fti.id_impret)
												Else ir.cd_cuenta
											  End,
									@idtercero,
									LEFT(fti.ds_Impas+' . Tkt: '+rtrim(ft.cd_tiquete),40),
									(sum(fti.am_valor))*-1,
									--sum((fti.am_valor))*-1,
									convert(CHAR(1),'1'),
									CASE WHEN ir.bl_contabilizar_proveedor = 1 And ISNULL(ir.cd_proveedor,'') <> '' THEN ir.cd_proveedor ELSE @idcliente END As 'cliprv',--R52825 - Jramirez - 20170919
						
									'porretetra'= 	CASE dbo.fnza_ManejaPorcentaje(CASE WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,NULL) Else ir.cd_cuenta End) /*rgelis 2014/10/22 req.22121*/
														WHEN 0 THEN 0
														WHEN 1 THEN fti.am_porcentaje
													End,
										
									'baseretetra'= 	CASE dbo.fnza_ManejaPorcentaje(CASE WHEN fti.id_ImpRet IN(1,@id_impuestotaonac,@id_impuestotaoint) THEN dbo.fnza_Get_FacTaoIvaCtaSuc(ft.in_nacionalidad,ft.id_fac_factura,NULL) Else ir.cd_cuenta End) /*rgelis 2014/10/22 req.22121*/
														WHEN 0 THEN 0
														WHEN 1 THEN CASE WHEN ftid.id IS NOT NULL THEN ROUND(abs(ftid.am_valor)*-1,@Decimales) ELSE ROUND(abs(ftc.am_valor)*-1,@Decimales) END
													End  
								From dbo.fac_TAO ft 
									INNER JOIN dbo.Fac_TaoCargos ftc On (ft.id = ftc.Id_Fac_Tao)
									INNER JOIN dbo.Fac_TaoImpuestos fti On (fti.id_FacTaoCargos = ftc.id)
									INNER JOIN dbo.ImpRet ir On (ir.id = fti.id_ImpRet)
									LEFT JOIN dbo.Fac_TaoImpuestos ftid ON (ftid.id_ImpRet = Ir.Id_imp_dep AND ftid.id_FacTaoCargos=fti.id_FacTaoCargos)
								Where ft.id_fac_factura = @id_factura 
								GROUP BY ir.cd_cuenta
										,fti.ds_Impas 
										,ft.cd_tiquete
										,fti.am_porcentaje
										,ftc.am_valor
										,fti.id_ImpRet
										,ft.in_nacionalidad
										,ft.id_fac_factura  /*rgelis 2014/10/22 req.22121*/		
										,ir.bl_contabilizar_proveedor,ir.cd_proveedor	--R52825 - Jramirez - 20170919
										,ftid.id
										,ftid.am_valor		
					end
					--8) Actualizando campos comunes
					Update dbo.Transac_AGEMIN SET 
							anotra 	 	= @anomes,
							idfuente 	= @fuente,
							numdoctra	= @numdoctra,
							fechatra	= @fechadoc,
							idvEnde		= @idvEnde,
							idusuario	= 'Zeus Agencia Mn',
							fechafact	= @fechadoc,					
							indcpitra	= dbo.fnza_GetTipoCuenta(codicta),
							AUXIAUX		= CASE WHEN dbo.fnza_GetTipoCuenta(CODICTA)='5' AND ISNULL(AUXIAUX,'')='' THEN dbo.fnza_GetAuxiAbierto(CODICTA) ELSE AUXIAUX END
						Where SpId = @@SPID; 		

					Update dbo.Transac_AGEMIN 
					SET BU = @Bu
					Where SpId = @@SPID AND (BU IS NULL OR BU = ''); 

					----------------------------------------------------------------------------------------------------
					---Inicio Causación CxP servicio de tercero
					----------------------------------------------------------------------------------------------------
					Declare 
						@fteCausacionCxPSrv3ros Varchar(25)
						,@sreCausacionCxPSrv3ros Varchar(25)
						,@cscutvoCausacionCxPSrv3ros Varchar(25)
						,@NumeroCausacionCxPSrv3ros Varchar(50)
						,@totalCausacionCxPSrv3ros MONEY
						
	   				--Incrementando y obteniendo consecutivo--
	   				SET @procmsg = ''  			
					IF EXISTS(	SELECT * 
								FROM fac_servicios fs
								INNER JOIN conceptofacturacion cf on cf.id = id_ConceptoFacturacion
								WHERE id_fac_Factura = @id_factura and bl_servicio_propio = 1
								)


					BEGIN
  						EXEC @procret = dbo.spza_IncrementaConsecutivo @id_MaeTipoTransacciones = 31,
														   			@id_sucursal             = @id_sucursal    ,
														   			@id_implante             = @id_implante    , 
														   			@cd_fuente               = @fteCausacionCxPSrv3ros     OUTPUT ,
														   			@cd_serie				 = @sreCausacionCxPSrv3ros     OUTPUT ,
														   			@cd_consecutivo          = @cscutvoCausacionCxPSrv3ros OUTPUT ,
														   			@errmsg					 = @procmsg OUTPUT ;
					END
					set @msg = @procmsg
				
					IF (@procmsg <> '') -- Proceso de incremento de consecutivo fallido				
					BEGIN 
						set @retval = 1
						IF (@@TRANCOUNT >0) ROLLBACK TRAN;	
					
						IF (@bl_af = 1)
						BEGIN
							EXEC dbo.spzaAuditoria_Insertar	@id_proceso = @idproce   ,
											 			 				@id_usuario = @id_usuario ,
											 			 				@cd_status  = 0           , 
											 			 				@admsg      = @msg	  ;			
						END	  
						
						Select @procmsg As 'Respuesta', 1 AS 'Estado' ;
						RETURN 1 ;
					END 


						--select @fteCausacionCxPSrv3ros as IDFUENTE
						--	, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA


					-- Insertando registros de servicios de proveedor (cuenta por pagar) para la nota de Causación CxP servicio de tercero
					Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								IDFUENTE,
								NUMDOCTRA,
								codicta,
								nittra,
								descritra,
								refefac,
								idcenco,
								valortra,
								indcpitra,
								cliprv,
								tipofac,
								vencefac,
								numefac,
								iditem
							)
						SELECT 
							SPID
							, @fteCausacionCxPSrv3ros as IDFUENTE
							, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA
							, t.codicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN @idtercero ELSE nittra END AS 'nittra'
							, descritra
							, refefac
							, idcenco
							, valortra
							, m.indcpicta
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE cliprv END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE tipofac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE vencefac END 
							, CASE WHEN bl_ContabilizarClienteFac = 1 AND m.indcpicta <> 3 THEN '' ELSE numefac END
							, cd_item 
						FROM (					
							Select 	SPID = @@SPID,
									dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio) AS 'codicta',
									p.IDTERCERO AS 'nittra',
									LEFT('CxP: '+rtrim(p.RAZONCIAL),40) AS 'descritra',
									CASE WHEN @bl_ReferenciaCxPProveSrv = 'S' THEN LEFT(rtrim(fs.ds_records),@LongitudRefe) Else '' END AS 'refefac',
									case when dbo.fnza_ManejaCenCo (dbo.fnza_GetServicioCxP(fs.id,fs.cd_proveedores,fs.id_ConceptoFacturacion,fs.id_TiposServicio)) = 1 then ISNULL(fs.cd_cencosto,@cd_cencoSucursal) Else '' End AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
									sum(dbo.fnza_Get_FacServicioTotalCxP(fs.id,@BU))*-1 AS 'valortra',
									convert(CHAR(1),'3') AS 'indcpitra',
									p.IDPROVE AS 'cliprv'
									,@TipoDocumento AS 'tipofac'
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN dbo.fnza_Get_FECHDCTO(fs.dt_VenceFac) ELSE @vencefac END AS 'vencefac' /*inicio rgelis 2014/11/10 req.22115*/
									,CASE WHEN RTRIM(ISNULL(fs.cd_NumeFac,''))<>'' THEN fs.cd_NumeFac ELSE @NUMDOCTRA END AS 'numefac' /*fin rgelis 2014/11/10 req.22115*/
									, ts.bl_ContabilizarClienteFac
									, fs.cd_item
								From dbo.Fac_Servicios fs		
									INNER JOIN dbo.conceptofacturacion cf on (cf.id = fs.id_ConceptoFacturacion)
									LEFT JOIN dbo.PROVEEDORES p On (fs.cd_proveedores = p.IDPROVE)
									LEFT JOIN dbo.TiposServicios ts On (ts.id = fs.id_TiposServicio)
								Where fs.id_fac_factura = @id_factura 
									AND fs.id_TiposConceptFac = 2
									AND cf.bl_llevarAlIngreso = 1
								GROUP BY p.CODICTA
										,p.IDTERCERO
										,p.RAZONCIAL
										,p.IDPROVE
										,fs.id
										,fs.cd_proveedores
										,fs.id_ConceptoFacturacion
										,fs.id_TiposServicio
										,fs.cd_cencosto
										,fs.ds_records
										,ts.bl_ContabilizarClienteFac
										,fs.cd_item
										,fs.cd_NumeFac /*inicio rgelis 2014/11/10 req.22115*/
										,fs.dt_VenceFac	/*fin rgelis 2014/11/10 req.22115*/
						) AS T
						INNER JOIN MAECONT m ON m.CODICTA = t.CODICTA	
						
						--select @fteCausacionCxPSrv3ros as IDFUENTE, @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA
						
						--) Insertando registros de  ventas propias y comisiones (ingresos - contabilizacion por cargos) 
						-- para la notaCausación CxP servicio de tercero
						Select @totalCausacionCxPSrv3ros = valortra from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros and numdoctra=@NumeroCausacionCxPSrv3ros and valortra>0
						Insert Into dbo.Transac_AGEMIN 
							(
								spid,
								IDFUENTE,
								NUMDOCTRA,
								codicta,
								nittra,
								auxiaux,
								idcenco,
								iditem,						
								descritra,
								valortra,
								cliprv
							)
						Select 	@@SPID,
								@fteCausacionCxPSrv3ros as IDFUENTE,
								@sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros As NUMDOCTRA,
								codicta = 	cd_cuenta_Causacion_GastoCosto,	
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDTERCERO,'')<>'' THEN p.IDTERCERO ELSE @idtercero END AS 'nittra',	/*rgelis 2016/12/09 req.34960*/
								fs.cd_auxiliar,
								ISNULL(fs.cd_cencosto,CASE WHEN @bl_manejarcencostoImplante = 1 AND isnull(@cd_cencoImplante,'') <> '' THEN @cd_cencoImplante ELSE @cd_cencoSucursal END) AS 'idcenco', /*rgelis 2012/09/04 req.10397*/
								fs.cd_item,						
								LEFT('Gasto ' + rtrim(cf.ds_nombre)+ ': '+rtrim(fs.ds_servicio),40),
								fsc.am_valor,
								CASE WHEN @bl_ContabilizarNitProv=1 AND ISNULL(p.IDPROVE,'')<>'' THEN p.IDPROVE ELSE @idcliente END
							From dbo.Fac_Servicios fs 
								INNER JOIN dbo.Fac_ServiciosCargos fsc On (fs.id = fsc.id_Fac_Servicios)
								INNER JOIN dbo.CargosDesc c On (c.id=fsc.id_cargosdesc)
								INNER JOIN dbo.ConceptoFacturacion cf On (cf.id = fs.id_ConceptoFacturacion)
								LEFT  JOIN dbo.proveedores p On (p.IDPROVE = fs.cd_proveedores)  /*rgelis 2016/12/09 req.34960*/ 
							Where fs.id_fac_factura = @id_factura 
							AND (fs.id_TiposConceptFac = 2 AND cf.bl_llevarAlIngreso = 1)
							AND abs(fsc.am_valor)<>0

							GROUP BY c.cd_cuenta,fs.ds_servicio,fsc.am_valor,cf.cd_cuenta,fsc.id_cargosdesc,cf.cd_codigo,fs.in_nacionalidad,fs.cd_tiquete,fs.id,fs.id_ConceptoFacturacion,fs.id_TiposServicio ,fs.cd_auxiliar ,fs.cd_cencosto,fs.cd_item ,cf.ds_nombre, fs.id_TiposConceptFac ,cf.bl_llevarAlGasto, p.IDTERCERO, p.IDPROVE/*rgelis 2013/09/09 req.16665*/ /*rgelis 2016/12/09 req.34960*/
							,bl_llevarAlIngreso, cd_cuenta_Causacion_GastoCosto
					

							IF EXISTS(select * from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros and spid=@@spid)
							BEGIN
								--select * from Transac_AGEMIN where idfuente=@fteCausacionCxPSrv3ros
								set @NumeroCausacionCxPSrv3ros = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros
								--Insertar en document_agemin--
								Insert Into dbo.Document_AGEMIN 
									(
										SPID,
										ANODCTO,
										FNTEDCTO,
										NUMEDCTO,
										FECHDCTO,
										NUMTDCTO,
										SUDBDCTO,
										SUCRDCTO,
										DESCDCTO,
										IDTERCERO,
										IDCLIPRV,
										BU
									)
								VALUES 
									(
										@@SPID,			
										@anomes,
										@fteCausacionCxPSrv3ros,
										@NumeroCausacionCxPSrv3ros,
										@fechadoc,
										-1,
										@totalCausacionCxPSrv3ros,
										@totalCausacionCxPSrv3ros,
										@descridoc,
										@idtercero,
										@idcliente,
										@Bu
									)

								Insert Into dbo.Document_Insertar 
								Select  * From dbo.document_agemin Where FNTEDCTO=@fteCausacionCxPSrv3ros And NUMEDCTO=@NumeroCausacionCxPSrv3ros


							END
							------------------------------------------------------------------------------------			


						
					----------------------------------------------------------------------------------------------------
					---Fin Causación CxP servicio de tercero
					----------------------------------------------------------------------------------------------------
					/*iniciorgelis 2012/10/11 req.10814*/
					--8.a) Recibo de Caja automatico
				
						--Si esta activo generar RC
					If (@bl_RcAuto = 1)
					Begin
						--Instrucciones del RC Automatico -----------------------------------------				
						SET @procmsgRC = ''  	
						SET @ResolucionmsgRC = ''		
				
						--Obtenemos la fuente de RC de los parametros.
						--Select @cd_fuenteRC = Valor From dbo.parametros Where id = 51 /*rgelis 2013/08/05 req.15991*/
						--Select @cd_fuenteRCOtr = Valor From dbo.parametros Where id = 206	/*rgelis 2013/08/05 req.15991*/
				
						If @cd_fuenteRCOtr is null or @cd_fuenteRCOtr = ''
						Begin
							SET @cd_fuenteRCOtr = @cd_fuenteRC
						End
						--Se declaran las variables contadoras
						DECLARE @CONTRC_D INT,@MAXRC_D INT; 
						--se daclaran las tablas de los recibos de caja para el document y el transac 
						DECLARE @RC_Document TABLE(id numeric identity( 1,1) NOT NULL
								,id_Fp INT
								,cd_FP CHAR(3)
								,am_FP MONEY
								,cd_Cuenta CHAR(16)
								,cd_Banco CHAR(3)
								,cd_Plaza CHAR(3)
								,cd_Serie CHAR(2)
								,cd_TipoFac CHAR(3)
								,in_Tipo INT
								,cd_Fuente CHAR(2)
								,cd_Consecutivo  VARCHAR(8)
								,id_TarjetasCredito INT /*rgelis 2014/03/04 req.18770*/
								,bl_GenerarSoloUnRCPorFP BIT
								,in_Fp INT); /*rgelis 2016/07/15 req.32431*/
						
						DECLARE @RC_Transac TABLE(id numeric identity( 1,1) NOT NULL
								,id_Fp INT
								,cd_FP CHAR(3)
								,am_FP MONEY
								,cd_Cuenta CHAR(16)
								,cd_Banco CHAR(3)
								,cd_Plaza CHAR(3)
								,cd_Serie CHAR(2)
								,cd_TipoFac CHAR(3)
								,ds_tcvoucher CHAR(25)
								,in_Tipo INT
								,in_item INT
								,cd_Fuente CHAR(2)
								,cd_Consecutivo VARCHAR(8)
								,id_TarjetasCredito INT
								,ds_tcnumber VARCHAR(16)
								,ds_tcautorizacion VARCHAR(25)/*rgelis 2014/03/04 req.18770*/
								,bl_GenerarSoloUnRCPorFP BIT /*rgelis 2016/07/15 req.32431*/
								,in_Fp INT
								,am_TarifaItem MONEY
								,am_IVAItem MONEY);
						--se consulta los recibos de caja de la factura y se inserta en la tabla para el transac 		
				
						INSERT INTO @RC_Transac(id_Fp, cd_FP, am_FP, cd_Cuenta, cd_Banco, cd_Plaza, cd_Fuente, cd_Serie, cd_TipoFac, ds_tcvoucher, in_Tipo, in_item, id_TarjetasCredito,ds_tcnumber,ds_tcautorizacion,bl_GenerarSoloUnRCPorFP,in_Fp, am_TarifaItem, am_IVAItem)/*rgelis 2014/03/04 req.18770*/ /*rgelis 2016/07/15 req.32431*/
						SELECT 
							id_Fp 
							, cd_FP
							, am_FP
							, cd_Cuenta
							, cd_Banco
							, cd_Plaza
							, cd_Fuente
							, cd_Serie
							, cd_TipoFac
							, ds_tcvoucher
							, in_Tipo
							, in_item
							, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							, right(rtrim(ltrim(ds_tcnumber)),4)
							, ds_tcautorizacion
							, bl_GenerarSoloUnRCPorFP /*rgelis 2016/07/15 req.32431*/
							, in_Fp = 1--ROW_NUMBER() OVER(PARTITION BY id_Fp ORDER BY id_Fp,id_TarjetasCredito)
							, am_TarifaItem
							, am_IVAItem
						FROM dbo.fnza_RCAutomaticoFPItems(@id_factura,null,CASE WHEN @bl_interface = 1 THEN 0 ELSE 1 END);

						UPDATE @RC_Transac
						SET cd_TipoFac = CASE 
							WHEN RTRIM(ISNULL(cd_TipoFac, '')) <> '' THEN cd_TipoFac
							WHEN EXISTS (SELECT 1 FROM dbo.FormasPago fp WHERE fp.id = id_Fp AND RTRIM(ISNULL(fp.id_MonedaContabilidad, '')) <> '') 
								THEN (SELECT TOP 1 RTRIM(fp.id_MonedaContabilidad) FROM dbo.FormasPago fp WHERE fp.id = id_Fp)
							ELSE 'EFE'
						END
						WHERE cd_TipoFac IS NULL OR RTRIM(cd_TipoFac) = '';
						

						
						--Retenciones en los RC
						Declare @MAxFileT_TC INT, @ContadorT_TC INT

						Declare @TTarjetasCreditoRCImpRet TABLE (Id Int Identity, id_TarjetasCredito	INT, am_fp	Money, 
						Id_CargosDesc INT, id_ImpRet	INT, cd_tipo INT, am_porcentaje	Numeric(18,4), 
						Id_cargo_dep	INT, Id_imp_dep	INT, am_TarifaItem Money, am_IVAItem Money, am_valor Money, cd_cuenta varchar(16), 
						id_fp INT, in_tipo INT, ds_tcnumber VARCHAR(16), ds_descripcion_item Varchar(40), cd_cencosto Varchar(16))
						
						INSERT INTO  @TTarjetasCreditoRCImpRet
						select 
							rct.id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							,am_fp
							, Id_CargosDesc = NULL
							, tc.id_ImpRet
							, cd_tipo
							, am_porcentaje
							, Id_cargo_dep
							, Id_imp_dep
							, am_TarifaItem
							, am_IVAItem
							, am_valor = 0
							, cd_cuenta = i.cd_cuenta
							, rct.id_fp, rct.in_tipo, rct.ds_tcnumber
							, ds_descripcion_item = left(i.ds_nombre,40)
							, cd_cencosto=NULL
						from @RC_Transac rct
						inner join TarjetasCreditoRCImpRet tc on tc.id_TarjetasCredito = rct.id_TarjetasCredito
						inner join ImpRet i on i.id = tc.id_ImpRet
						and id_Sucursales = @id_sucursal
						and isnull(id_Implantes,0) = isnull(@id_implante,0)
						
						UNION ALL

						select 
							rct.id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/ 
							,am_fp
							, Id_CargosDesc = 1
							, id_ImpRet = NULL
							, cd_tipo = 0
							, am_porcentaje = am_porcentaje_comision
							, Id_cargo_dep = NULL
							, Id_imp_dep = NULL
							, am_TarifaItem
							, am_IVAItem
							, am_valor = 0
							, cd_cuenta = tc.cd_cuenta
							, rct.id_fp, rct.in_tipo, rct.ds_tcnumber
							, ds_descripcion_item
							,cd_cencosto
						from @RC_Transac rct
						OUTER APPLY (
										Select top 1 tc.* ,cc.cd_cuenta, am_porcentaje_comision = cc.am_porcentaje, ds_descripcion_item = left(cc.ds_nombre,40),cd_cencosto
										From TarjetasCreditoRCImpRet tc 
										inner join ConceptoComisiones cc on cc.id = tc.id_ConceptoComisiones
										where tc.id_TarjetasCredito = rct.id_TarjetasCredito 						
										and id_Sucursales = @id_sucursal
										and isnull(id_Implantes,0) = isnull(@id_implante,0)
									) TC
						SET @MAxFileT_TC = @@ROWCOUNT
						Set @ContadorT_TC = 1
						If exists( Select * from @TTarjetasCreditoRCImpRet)
						Begin
							--Calculamos la comision
							Update @TTarjetasCreditoRCImpRet
							Set am_valor = round(am_TarifaItem * (am_porcentaje/100),0)
							Where Id_CargosDesc = 1
							
							--Calculamos los impuestos o retenciones que dependan de la tarifa
							Update t
							Set am_valor = round(t.am_TarifaItem * (t.am_porcentaje/100),0)
							From @TTarjetasCreditoRCImpRet t
							Where Id_cargo_dep = 1

							Update t
							Set am_valor = round(t.am_IVAItem * (t.am_porcentaje/100),0)
							From @TTarjetasCreditoRCImpRet t
							Where Id_imp_dep = 1


							While @ContadorT_TC < = @MAxFileT_TC
							Begin
								--Select 
								--	@Id_imp_depT_TC = Id_imp_dep
								--	,@Id_cargo_depT_TC = Id_cargo_dep
								--	,@id_TarjetasCreditoT_TC = id_TarjetasCredito
								--	,@am_fpT_TC = am_fp
								--From @TTarjetasCreditoRCImpRet Where Id = @ContadorT_TC

								Update t
								Set am_valor = round(tt.am_valor * (t.am_porcentaje/100),0)
								From @TTarjetasCreditoRCImpRet t
								Inner Join @TTarjetasCreditoRCImpRet tt on tt.id_TarjetasCredito = t.id_TarjetasCredito
																			AND tt.id_TarjetasCredito = t.id_TarjetasCredito	
																			AND tt.am_fp = t.am_fp
																			AND tt.Id_imp_dep = t.id_ImpRet
								Where t.Id = @ContadorT_TC and t.am_valor = 0
								set @ContadorT_TC = @ContadorT_TC + 1

							End

						End 
						
						--Select * From @TTarjetasCreditoRCImpRet
						--Select * From @RC_Transac

						Declare @RC_PagosCombinados TABLE (id int identity,id_Fp INT,in_tipo int,ds_tcnumber varchar(4)) /*Jramirez 2017/02/03 req.32431*/
						INSERT INTO @RC_PagosCombinados
						SELECT DISTINCT id_fp,in_tipo,ds_tcnumber from @RC_Transac

						Update rc
						Set rc.in_Fp = rcc.id
						From @RC_Transac rc
						Inner Join @RC_PagosCombinados rcc on rcc.id_fp = rc.id_fp and rcc.in_tipo = rc.in_tipo  and rcc.ds_tcnumber = rc.ds_tcnumber
						
						--se verifica que la factura tenga recibos de caja para generar
						IF EXISTS(SELECT * FROM @RC_Transac)
				
						BEGIN
					
							--se llena la tabla de recibos de caja para el document 
							INSERT INTO @RC_Document(id_Fp, cd_FP, am_FP, cd_Cuenta, cd_Banco, cd_Plaza, cd_Fuente,cd_Serie, cd_TipoFac, in_Tipo, id_TarjetasCredito, bl_GenerarSoloUnRCPorFP, in_FP)/*rgelis 2014/03/04 req.18770*/ /*rgelis 2016/07/15 req.32431*/
							SELECT 
								id_Fp 
								, cd_FP
								, SUM(am_FP) As 'am_FP' 
								, cd_Cuenta
								, cd_Banco
								, cd_Plaza
								, cd_Fuente
								, cd_Serie
								, cd_TipoFac
								, in_Tipo
								, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
								, bl_GenerarSoloUnRCPorFP /*rgelis 2016/07/15 req.32431*/
								, in_FP
							FROM @RC_Transac
							GROUP BY
								id_Fp 
								, cd_FP
								, cd_Cuenta
								, cd_Banco
								, cd_Plaza
								, cd_Fuente
								, cd_Serie
								, cd_TipoFac
								, in_Tipo
								, id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
								, bl_GenerarSoloUnRCPorFP 
								, in_Fp/*rgelis 2016/07/15 req.32431*/

							--se inicializa las variables contabilizadoras de las tablas	
							SELECT @MAXRC_D=COUNT(*) FROM @RC_Document;
							SET @CONTRC_D=1;
							SET @id_FpRcAux=0
							
							--se recorre las tablas de recibos de caja para el document
							WHILE (@CONTRC_D<=@MAXRC_D) 
							BEGIN
								--se obtiene la serie,fuente,cuenta,total de recibo de caja configurada 
				
								SELECT  @cd_serieRC = cd_Serie
										,@cd_fuenteRC_F = cd_Fuente /*rgelis 2013/08/05 req.15991(CASE WHEN in_Tipo = 2 AND LTRIM(RTRIM(cd_FP))='TC' THEN @cd_fuenteRCOtr
																WHEN LTRIM(RTRIM(cd_FP))='TC' THEN @cd_fuenteRC
															ELSE cd_Fuente
															END)*/
										,@id_FpRc = id_Fp
										,@bl_GenerarSoloUnRCPorFP = bl_GenerarSoloUnRCPorFP	/*rgelis 2016/07/15 req.32431*/								 	 
								FROM @RC_Document WHERE id=@CONTRC_D;
								--se crea el consecutivo
	

								If IsNull(@cd_fuenteRC_F,'') = ''
								Begin
									SET @retval = 1
									Set @msg = 'No se ha definido la fuente para los recibos de caja.'

									If @@TRANCOUNT > 0
									Begin 
										ROLLBACK TRAN;	
									End 

									RAISERROR (@msg,16,127);
									RETURN @retval;
								End

								IF (@id_FpRc<>@id_FpRcAux OR @bl_GenerarSoloUnRCPorFP = 0)
								BEGIN
									EXEC @procret = dbo.spza_IncrementaConsecutivo_Contabilidad 
											'*'
											, @cd_fuenteRC_F
											, @cd_serieRC
											, 'I'
											, @cd_consecutivoRC OUT
											, @procmsgRC OUT;
						
									set @cd_consecutivoRC = right('00000000'+@cd_consecutivoRC,8);
			
									If (@procmsgRC <> '' or @procret <> 0) -- Proceso de incremento de consecutivo fallido				
									Begin 
										If @@TRANCOUNT > 0
										Begin 
											ROLLBACK TRAN;	
										End 
									
										Select @procmsgRC As 'Respuesta',
												1 AS 'Estado' ;
										RETURN 1 ;

									End
									SET @id_FpRcAux = @id_FpRc	
								END
								-- se actualiza la tabla del document con las fuentes y los consecutivos creados
								UPDATE @RC_Document
								SET cd_Fuente = @cd_fuenteRC_F
									,cd_Consecutivo = @cd_consecutivoRC
								WHERE id=@CONTRC_D;
							   
								SET @CONTRC_D = @CONTRC_D + 1;   
							END
							
							/*inicio rgelis 2013/11/13 req.17600*/
							--se valida que las cuEntas para los recibos de caja solo sean de caja o de banco
							SET @procmsgRC='';
							SELECT @procmsgRC = @procmsgRC + RTRIM(CODICTA) + ','  
							FROM (SELECT M.CODICTA  
									FROM @RC_Transac As Rc 
									 INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta
									WHERE M.INDCPICTA NOT IN('1','6') OR (M.INDCPICTA = '1' AND M.IDBANCO IS NULL)
								) AS Tc
							GROUP BY CODICTA 
							IF LEN(@procmsgRC)>0
							BEGIN
								SET @procmsgRC = substring(@procmsgRC,1,len(@procmsgRC)-1)
							END 			 
							IF (@procmsgRC <> '')		  	  
							Begin 
								Select 'Las Cuentas : '+ @procmsgRC +' que fueron Configuradas para la creacion de recibos de caja automático no son de caja ni de banco ' AS 'Respuesta', 1 AS 'Estado'
								ROLLBACK TRAN;
								RETURN 1 ;
							End
							/*fin rgelis 2013/11/13 req.17600*/	
							-- se actualiza la tabla del Transac con las fuentes y los consecutivos creados 
							UPDATE T 
							SET T.cd_Fuente=D.cd_Fuente
								,T.cd_Consecutivo=D.cd_Consecutivo
							FROM @RC_Transac As T
								INNER JOIN @RC_Document As D ON D.id_FP=T.id_FP AND D.cd_FP=T.cd_FP And D.in_Tipo=T.in_Tipo And D.cd_TipoFac=T.cd_TipoFac And D.in_FP=T.in_FP ;/*rgelis 2017/05/09 req.49675*//*rgelis 2013/02/26 req.12870*/
							-- se inserta en el document las cabeceras de los recibos de caja 
					
					 
							Insert Into dbo.Document_AGEMIN 
								(
									SPID,
									ANODCTO,
									FNTEDCTO,
									NUMEDCTO,
									FECHDCTO,
									NUMTDCTO,
									SUDBDCTO,
									SUCRDCTO,
									DESCDCTO,
									IDTERCERO,
									IDCLIPRV,
									CBADCTO,
									BU
								)
							SELECT 		
									@@SPID,			
									@anomes,
									cd_Fuente,
									cd_Serie+cd_Consecutivo,
									@fechadoc,
									-1,
									SUM(am_Fp),
									SUM(am_Fp),
									LEFT('Cancelación de Factura: '+ @numdoctra,40),
									@idtercero,
									@idcliente,
									'' AS cd_Cuenta, /*rgelis 2016/07/15 req.32431*/
									@Bu
							FROM @RC_Document
							GROUP BY cd_Fuente,cd_Serie,cd_Consecutivo;/*rgelis 2016/07/15 req.32431*/
					
							-- se inserta en el transac las carteras de los recibos de caja 
					
							Insert Into dbo.Transac_AGEMIN 
								(
									spid,
									anotra,
									idfuente,
									numdoctra,
									fechatra,
									codicta,
									nittra,
									descritra,
									valortra,
									indcpitra,
									idvEnde,
									tipofac,
									numefac,
									vencefac,
									idusuario,
									cliprv,
									fechafact,
									BU,
									REFEFAC
								)
							Select 
									@@SPID,
									@anomes,
									Cd_Fuente													AS 'IDFUENTE',
									Cd_Serie+cd_consecutivo										AS 'NUMDOCTRA',
									@fechadoc													AS 'FECHATRA',
									Case When IsNull(Fp.Cd_cuenta,'') <> '' Then Fp.Cd_cuenta Else @ctacartera End AS 'CODICTA',
									Case When IsNull(Fp.cd_Tercero,'') <> '' Then Fp.cd_Tercero Else @idtercero End AS 'NITTRA',
									LEFT('Cancelación de Factura: '+ @numdoctra,40)				AS 'DESCRITRA',
									(am_FP)*-1													AS 'VALORTRA',
									'2'															AS 'INDCPITRA',
									@idvEnde													AS 'IDVEndE',
									@TipoDocumento												AS 'TIPOFAC',
									--@NUMDOCTRA													AS 'NUMEFAC',
									@numefac													AS 'NUMEFAC',
									@vencefac													AS 'VENCEFAC',
									'Zeus Agencia Mn'											AS 'IDUSUARIO',
									@idcliente													AS 'CLIPRV',
									@fechadoc													AS 'FECHAFACT',
									@Bu															AS 'BU',
									CASE WHEN @bl_ReferenciaCxCProveSrv = 'S' THEN ISNULL((SELECT TOP 1 LEFT(rtrim(fs.ds_records),@LongitudRefe) From dbo.Fac_Servicios fs Where fs.id_fac_factura = @id_factura ),'') ELSE '' END
							From @RC_Document 
							Inner Join FormasPago FP on fp.Id = id_Fp ; --Esto es para utilizar la CtaCxC general o de la FP
					
							-- se inserta en el transac los tkt, el tao y los servicios de los recibos de caja 
							If NOT exists( Select * from @TTarjetasCreditoRCImpRet)
							Begin
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Cancelación de Factura: '+ @numdoctra,40)					AS 'DESCRITRA',
										am_FP															AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher
											 ELSE @numefac END											AS 'NUMEFAC', 
											 --Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + ds_tcnumber,25) ELSE '' END 
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	  
							End
							Else
							Begin
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Cancelación de Factura: '+ @numdoctra ,40)					AS 'DESCRITRA',
										am_FP - am_valor													AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher
											 ELSE @numefac END											AS 'NUMEFAC',	 
											 --Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + rc.ds_tcnumber,25) ELSE '' END 
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
									INNER JOIN (	Select 
													id_fp, in_tipo, ds_tcnumber, am_valor = sum(isnull(am_valor,0)) 
													from @TTarjetasCreditoRCImpRet 
													group by id_fp, in_tipo, ds_tcnumber) tt 
											on tt.id_fp = rc.id_fp
											AND tt.in_tipo = rc.in_tipo
											AND tt.ds_tcnumber = rc.ds_tcnumber
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	  
								
								--registro de Comisiones - impuestos y retenciones
								Insert Into dbo.Transac_AGEMIN 
									(
										spid,
										anotra,
										idfuente,
										numdoctra,
										fechatra,
										codicta,
										nittra,
										descritra,
										valortra,
										indcpitra,
										idbanco,
										idplaza,
										tipofac,
										numefac,
										vencefac,
										idusuario,
										fechafact,
										BU,
										REFEFAC,
										IDCENCO
									)
								Select 	@@SPID,
										@anomes,
										cd_Fuente														AS 'IDFUENTE',
										cd_Serie+cd_Consecutivo											AS 'NUMDOCTRA',
										@fechadoc														AS 'FECHATRA',
										tt.cd_Cuenta														AS 'CODICTA',
										@idtercero														AS 'NITTRA',
										LEFT('Pago Factura: '+ @numdoctra + ' - ' + ds_descripcion_item,40)					AS 'DESCRITRA',
										am_valor													AS 'VALORTRA',
										M.INDCPICTA 													AS 'INDCPITRA',/*rgelis 2013/11/13 req.17600*/
										cd_Banco														AS 'IDBANCO',
										cd_Plaza														AS 'IDPLAZA',
										ISNULL(NULLIF(RTRIM(cd_TipoFac),''), 'EFE') AS 'TIPOFAC',
										CASE WHEN IsNull(ds_tcvoucher,'') <> '' THEN ds_tcvoucher 
											 Else @NUMDOCTRA End   										AS 'NUMEFAC',
										@fechadoc														AS 'VENCEFAC',
										'Zeus Agencia Mn'												AS 'IDUSUARIO',
										@fechadoc														AS 'FECHAFACT',
										@Bu																AS 'BU',
										Referencia = CASE WHEN M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) THEN LEFT(ds_tcautorizacion + ' TC: ' + rc.ds_tcnumber,25) ELSE '' END ,
										cd_cencosto
								From @RC_Transac AS Rc	/*inicio rgelis 2013/11/13 req.17600*/
									INNER JOIN MAECONT AS M ON M.CODICTA = Rc.cd_Cuenta	
									INNER JOIN (	Select 
													id_fp, in_tipo, ds_tcnumber, am_valor, cd_cuenta,  ds_descripcion_item, cd_cencosto
													from @TTarjetasCreditoRCImpRet ) tt 
													--group by id_fp, in_tipo, ds_tcnumber
											on tt.id_fp = rc.id_fp
											AND tt.in_tipo = rc.in_tipo
											AND tt.ds_tcnumber = rc.ds_tcnumber
								Where M.INDCPICTA ='6' Or (M.INDCPICTA = '1' AND M.IDBANCO IS NOT NULL) /*fin rgelis 2013/11/13 req.17600*/	 
								--select * from Transac_AGEMIN where SpId=@@SPID and idfuente='01'
							End
					
						END
								
						INSERT INTO dbo.Fac_RecibosCaja (id_fac_factura,id_fac_remision,id_FormaPago,cd_Fuente,cd_Serie,cd_Consecutivo,in_Tipo,am_valor,id_TarjetasCredito)/*rgelis 2014/03/04 req.18770*/
						SELECT @id_factura
								,NULL
								,id_FP
								,cd_Fuente
								,cd_Serie
								,cd_Consecutivo
								,in_Tipo
								,SUM(am_FP) AS 'am_FP'
								,id_TarjetasCredito/*rgelis 2014/03/04 req.18770*/
						FROM @RC_Document
						GROUP BY id_FP,cd_Fuente,cd_Serie,cd_Consecutivo,in_Tipo,id_TarjetasCredito;

						  /*inicio rgelis 2014/03/04 req.18770*/
						Set @Retval = 0


						Exec @Retval = dbo.spza_FacRecibosCajaTCPropia_Contabilizar @id_usuario=@id_usuario,@id_factura=@id_factura,@id_remision=NULL,@ctacartera=@ctacartera,@msg = @procmsg OUTPUT,@bl_Contabilizar=0

						IF (@Retval <> 0 ) -- Proceso fallido
						BEGIN
							IF @@TRANCOUNT > 0
							BEGIN
								ROLLBACK TRAN;
							END
		    
							raiserror( @procmsg,16,1)		    
		    

							IF (@bl_af = 1) --Se debe auditar proceso fallido
								BEGIN
									EXEC dbo.spzaAuditoria_Insertar @id_proceso = @idproce    ,
										@id_usuario = @id_usuario ,
										@cd_status  = 1           ,
										@admsg      = @procmsg       ;
								END
    

							RETURN 1 ;
						END
						/*inicio rgelis 2014/03/04 req.18770*/
								
						Insert Into dbo.Document_Insertar 
						Select  D.* From dbo.document_agemin As D  
						Where d.SpId = @@spid 
						And D.FNTEDCTO+D.NUMEDCTO in (SELECT cd_Fuente+cd_Serie+cd_Consecutivo FROM @RC_Document)		
					
						Insert Into dbo.Transac_Insertar
						Select  T.* From dbo.Transac_AGEMIN As T 
						Where t.SpId = @@spid
						and isnull(VALORTRA,0)<>0
						And t.IDFUENTE+t.NUMDOCTRA in (SELECT cd_Fuente+cd_Serie+cd_Consecutivo FROM @RC_Transac)			
				
					End 
			
					/*fin rgelis 2012/10/11 req.10814*/	
				END
				------------------------------------------------------------------------------------------
				--9) Actualizando Statustra, valor moneda y tasacambio a los registros de cuentas que manejan moneda y no tienen estado 'AJ'
				-- el estado 'AJ' causa que el validador de movimientos contables omita la comprobacion de 
				-- los registros de transacciones que tienen cuentas que manejan moneda.
				Declare @monedaLocal char(3), @MonedaEquivalente VARCHAR(3)
				SELECT @monedaLocal = valor From parametros Where id=10;
				SELECT @MonedaEquivalente = id_monedaContabilidad FROM dbo.Monedas_IATA where cd_codigo = @moneda

				If @moneda <> @monedaLocal and @moneda is not null and @moneda <> ''
				Begin
					IF EXISTS(
								SELECT *
								FROM Transac_AGEMIN
								INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
								Where 
									SpId = @@SPID 
									AND Valortra is not null 
									AND valortra <> 0 
									AND ISNULL(MAECONT.IDMONEDA,'') <> ''
								
									AND maecont.indcpicta='3'
							) and ISnull(@MonedaEquivalente,'') = ''
					BEGIN
						SET @retval = 1
						Set @msg = 'No se ha definido la moneda equivalante para la moneda: '  + @moneda + char(13) +  'Por favor en el maestro de monedas coloque esta información.'

						IF @@TRANCOUNT > 0
						BEGIN 
							ROLLBACK TRAN;	
						END 

						RAISERROR (@msg,16,127);
						RETURN @retval;					

					END 

					IF EXISTS(
								SELECT *
								FROM Transac_AGEMIN
								INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
								Where 
									SpId = @@SPID 
									AND Valortra is not null 
									AND valortra <> 0 
									AND ISNULL(MAECONT.IDMONEDA,'') <> ''
									AND MAECONT.IDMONEDA <> @MonedaEquivalente
									AND maecont.indcpicta='3'
							)
					BEGIN
						SET @retval = 1

						SELECT DISTINCT @msg = isnull(@msg,'') + 'Las cuenta de Proveedores parametrizada tienen diferente moneda a la moneda de la factura. Cuenta: ' + isnull(MAECONT.codicta,'') + char(13)
						FROM Transac_AGEMIN
						INNER JOIN dbo.MAECONT ON MAECONT.CODICTA = Transac_AGEMIN.CODICTA
						Where 
							SpId = @@SPID 
							AND Valortra is not null 
							AND valortra <> 0 
							AND ISNULL(MAECONT.IDMONEDA,'') <> ''
							AND MAECONT.IDMONEDA <> @MonedaEquivalente
							AND maecont.indcpicta='3'

						IF @@TRANCOUNT > 0
						BEGIN 
							ROLLBACK TRAN;	
						END 

						RAISERROR (@msg,16,127);
						RETURN @retval;		
					END 
				
					Update dbo.Transac_AGEMIN SET 
						valormoneda = case when DESCRITRA NOT LIKE '%ajuste%moneda%' then dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,0) else valormoneda end,	
						tasacambio  =  dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,1) 
					Where SpId = @@SPID and Valortra is not null and valortra <> 0  --SpId = @@SPID AND STATUSTRA <> 'AJ' AND TasaCambio <> 0 AND VALORMONEDA <>0; 		
				
					Update dbo.Transac_Insertar SET 
						valormoneda = case when DESCRITRA NOT LIKE '%ajuste%moneda%' then  dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,0) else valormoneda end,	
						tasacambio  = dbo.fnza_CalcularValorMoneda(codicta,valortra,@moneda,@tcambio,1) 
					Where SpId = @@SPID and Valortra is not null and valortra <> 0 AND ISNULL(valormoneda,0) = 0				
				End 
				
				
				Insert Into dbo.Transac_Insertar
				Select  * From dbo.Transac_AGEMIN Where IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0 AND SpId=@@spid;		
				
									
				
				-------------------------------------------------------------------------------------------------------------
				--Contabilizacion Causación CxP servicio de tercero


				Update dbo.Transac_AGEMIN SET 
						anotra 	 	= @anomes,
						--idfuente 	= @fuente,
						--numdoctra	= @numdoctra,
						fechatra	= @fechadoc,
						idvEnde		= @idvEnde,
						idusuario	= 'Zeus Agencia Mn',
						fechafact	= @fechadoc,					
						indcpitra	= dbo.fnza_GetTipoCuenta(codicta)
					Where SpId = @@SPID AND IDFUENTE = @fteCausacionCxPSrv3ros And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros; 		

				Update dbo.Transac_AGEMIN 
				SET BU = @Bu
				Where SpId = @@SPID AND (BU IS NULL OR BU = '') AND IDFUENTE = @fteCausacionCxPSrv3ros And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros; 

				Insert Into dbo.Transac_Insertar
				Select  * From dbo.Transac_AGEMIN Where IDFUENTE = @fteCausacionCxPSrv3ros 
				And NUMDOCTRA = @sreCausacionCxPSrv3ros+@cscutvoCausacionCxPSrv3ros AND VALORTRA <> 0 AND SpId=@@spid;						

				Update fac_Factura
				set
					cd_fuente_NCausacionSrvTer				= @fteCausacionCxPSrv3ros
					,cd_serie_NCausacionSrvTer				= @sreCausacionCxPSrv3ros
					,cd_consecutivo_NCausacionSrvTer		= @cscutvoCausacionCxPSrv3ros
				Where id = @id_factura

				--Select  * From dbo.Transac_AGEMIN Where SpId=@@spid AND VALORTRA <> 0
				--Contabilizacion Causación CxP servicio de tercero
				-------------------------------------------------------------------------------------------------------------

				--Select  * From dbo.Transac_AGEMIN WHERE SpId=@@spid ORDER BY NUMDOCTRA
				------------------------------------------------------------------------------------------
				-- Inicio Debug

	
				--Select  * From dbo.Document_Insertar Where SpId=@@spid;--DEBUG	
				--Select  * From dbo.Transac_Insertar Where SpId=@@spid;--DEBUG		
				--Factura
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0;--DEBUG		
				--Rc Tkt
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @cd_fuenteRC And NUMDOCTRA = @cd_serieRC+@cd_consecutivoRC AND VALORTRA <> 0; --DEBUG
				--RC otro		
				--Select  * From dbo.Transac_Insertar Where IDFUENTE = @cd_fuenteRCOtr And NUMDOCTRA = @cd_serieRCOtr+@cd_consecutivoRCOtr AND VALORTRA <> 0; --DEBUG
				-- Fin Debug			
			
				------------------------------------------------------------------------------------------
				-- Actualizamos el NFC
				------------------------------------------------------------------------------------------
				Update	Transac_Insertar
				Set	Transac_Insertar.NCF		= @NCF
				From dbo.Transac_Insertar Inner Join Maecont On Transac_Insertar.Codicta=Maecont.Codicta
				Where Maecont.IndNcf = 1
					And	Transac_Insertar.SpId = @@SpId
				------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------

				------Este Sp se encarga de realizar la contabilizacion NIIF
		   		SELECT @ERRORCONT=1			
				EXEC @ERRORCONT = dbo.Spza_NIIF_Contabilizar 
				IF @ERRORCONT<>0 
				BEGIN 
					IF @@TRANCOUNT > 0 
					BEGIN 
						ROLLBACK TRAN ;		
					END
					--Determinando si se debe auditar el proceso fallido
					IF (@bl_af = 1) 
					BEGIN 			
						EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
														 @id_usuario = @id_usuario ,
														 @cd_status  = 0           , 												 
														 @admsg      = ' Ocurrio un error generando la Contabilización NIIF',
								 						 @msgparams  = NULL;
					END 			 		
					RAISERROR ('Ocurrio un error generando la Contabilización NIIF',16,125);
					RETURN @ERRORCONT; 
				END

				Update dbo.Transac_Insertar SET 				
				Id_Movimiento = ISNULL(Id_Movimiento,''),statustra = ISNULL(statustra,'XA') 
				Where SpId = @@SPID 

				Select @ERRORCONT=1			
				EXEC @ERRORCONT=dbo.spInsertarDatosEnContabilidad @SoloValidarSinInsertar='S',
							   @ActualizacionEnLinea='S',
							   @DevolverLoteDeErrores='N',
							   @MostrarMensajesDeError='S',
							   @ValidarCuadre = 'S',
							   @AgruparRegistrosIguales = 'S',
							   @Aplicacion= 'Agencia Minorista SQL',
							   @TiposDeMensajes = 'G'
			
				If @ERRORCONT<>0 
				Begin 
   	        		If @@TRANCOUNT > 0 
   	        		Begin 
   	        			ROLLBACK TRAN ; 
   	        		End 
					--Determinando si se debe auditar el proceso exitoso
					If (@bl_af = 1) 
					Begin 											   	        	
						EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
														 @id_usuario = @id_usuario ,
														 @cd_status  = 0           , 												 
														 @admsg      = NULL,
								 						 @msgparams  = @Numdoc;
					End 			 		
					--Select 'Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles' AS 'Respuesta', 1 AS 'Estado'
					RAISERROR ('Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles',16,124);
					RETURN @ERRORCONT; 
				End
				Else 
				Begin 
					EXEC @ERRORCONT=dbo.spInsertarDatosEnContabilidad @SoloValidarSinInsertar='N',
					   @ActualizacionEnLinea='S',
					   @DevolverLoteDeErrores='N',
					   @MostrarMensajesDeError='N',
					   @ValidarCuadre = 'S',
					   @AgruparRegistrosIguales = 'S',
					   @Aplicacion= 'Agencia Minorista SQL',
					   @TiposDeMensajes = 'G'

					If @ERRORCONT<>0 
					Begin 
					
	   	        		If @@TRANCOUNT > 0 
	   	        		Begin 
	   	        			ROLLBACK TRAN ; 
	   	        		End 
	   	        	
						--If (@bl_af = 1) 
						--Begin 										
						--	EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
						--									 @id_usuario = @id_usuario ,
						--									 @cd_status  = 1           , 												 
						--									 @admsg      = NULL,
						--			 						 @msgparams  = @Numdoc;
						--End 	
						--Select 'Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles' AS 'Respuesta', 1 AS 'Estado'
						RAISERROR ('Ocurrio un error contabilizando la factura, consulte el informe de auditoria para mas detalles',16,124);
						RETURN @ERRORCONT; 
					End
				
					--Registrando formas de pago para ecibos de caja
					Declare @FormaPagoStr VARCHAR(max);
					EXEC dbo.spza_ExportarFormasPagoRC
						@id_factura = @id_factura,
						@FormaPagoStr = @FormaPagoStr OUTPUT 	
				
					--Insertando la forma de pago
					Insert Into dbo.FormaPago_Age
							(
								fuente,
								documento,
								cuenta,
								cliente,
								tipofac,
								numefac,
								vencefac,
								refefac,
								FormaPago
							)
						VALUES 
							(
								@fuente,
								@numdoctra,
								@ctacartera,
								@idcliente,
								@TipoDocumento,
								@numefac,--@numdoctra,
								@vencefac,
								'',
								LEFT(RTRIM(@FormaPagoStr),1519)
							);
				
					--Asignar Archivo Fisico--
					If @CodigoArchivoFisico IS NOT NULL and  @CodigoArchivoFisico <> ''
					Begin
					EXEC Dbo.SpArchivoFisico_Documentos 	@operacion = 'I'
															,@fuente = @fuente
															,@Documento = @numdoctra
															,@CodigoArchivoFisico = @CodigoArchivoFisico
												
					End
					--Fin Archivo Fisico--
					EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
													 @id_usuario = @id_usuario ,
													 @cd_status  = 1           , 												 
													 @admsg      = NULL,
								 					 @msgparams  = @Numdoc;
				
				
				End
			END	 
			--------------------------------------------------------------------------			
			IF @bl_mostrarmsg = 1 --inicio rgelis 2018/12/11 req.74447
			BEGIN								 		 
				IF EXISTS(SELECT * FROM dbo.Transac_Insertar WHERE IDFUENTE = @FUENTE And NUMDOCTRA = @NUMDOCTRA AND VALORTRA <> 0 AND SPID = @@SPID)
					SELECT 'La factura fue contabilizada satisfactoriamente' AS 'Respuesta', 1 AS 'Estado';
				ELSE IF @bl_nocont = 1
					SELECT 'La factura no se puede contabilizar, Tiene la bandera "no contabilizar" activa' AS 'Respuesta', 0 AS 'Estado';
			END --inicio rgelis 2018/12/11 req.74447
			UPDATE dbo.fac_factura SET cd_ctacartera=@ctacartera WHERE id=@id_factura --rgelis 2019/08/08 req.92012
 		 	--Si la transaccion fue creada en el procedimiento entonces se actualiza--
 		 	If (XACT_STATE() <> 0) and (@@TRANCOUNT > 0) 
	   	    Begin 
				COMMIT TRAN;	
			End 
			set @retval = 0;
			RETURN @retval;
	 End TRY 
		--Endregion
    	
		--region: Bloque CATCH (Manejo de excepciones)
    	Begin CATCH 
 			--Error de duplicado--
			If error_number()= 2601
 			Begin 
 				SET @msg =  'No se pudo crear la Factura. Ya existe';
      			SET @retval = 1
	   	       
	   	       If @@TRANCOUNT > 0 
	           Begin 
	           		ROLLBACK TRAN ; 
	           End
	   	       
	   	        RAISERROR (@msg,16,124);
	   	      	--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce ,
													 			 @id_usuario = @id_usuario ,
													 			 @cd_status  = 0      ,
													 			 @msgparams  = @Numdoc, 
													 			 @admsg      = @msg	   ;				
	   	        RETURN @retval;
		    End
		    
 			-- Tiempo de espera alcanzado --
		    If ERROR_NUMBER() = 1222
		    Begin
      			SET @msg =  'No se pudo ejecutar el proceso. Tiempo de espera agotado.';
      			SET @retval = 1
	   	        
	   	        If @@TRANCOUNT > 0 
   	        	Begin 
   	        		ROLLBACK TRAN ; 
   	        	End
   	        	
	   	        RAISERROR (@msg,16,125);
	   	       	--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce ,
													 			 @id_usuario = @id_usuario ,
													 			 @cd_status  = 0           ,
													 			 @msgparams  = @Numdoc,
													 			 @admsg      = @msg	   ;				
	   	        RETURN @retval;
		    End
		    
		    -- Registro bloqueado / Conflicto de actualizacion
		    Else If ERROR_NUMBER() IN (1205, 3960)
    		Begin
    			If @@TRANCOUNT > 0 
   	        	Begin 
   	        		ROLLBACK TRAN ; 
   	        	End 
	   	        
		       	SET @retry     = 1              ;
		       	SET @retrycont = @retrycont + 1 ; 

	    	 End
	    	 Else
		     Begin
		     	-- Error no manejado --			   	   	        
   	        	If @@TRANCOUNT > 0 
   	      		Begin 
   	        		ROLLBACK TRAN ; 
   	        	End
						
				SET @retval = 1;
 				SET @msg =	'Ha ocurrido un error. Información para soporte tecnico:'			+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						    'Numero: ' + isnull(CAST(ERROR_NUMBER()   AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Mensaje: ' + isnull(ERROR_MESSAGE(),'') 					   		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						 	'Severidad: ' + isnull(CAST(ERROR_SEVERITY() AS VARCHAR(10)),'') 	+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
						 	'Estado: ' + isnull(CAST(ERROR_STATE()    AS VARCHAR(10)),'') 		+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Procedimiento: ' + isnull(ERROR_PROCEDURE(),'')					+ CHAR(13)+ CHAR(10) + CHAR(13)+ CHAR(10) +
							'Linea: ' + isnull(CAST(ERROR_LINE() 	   AS VARCHAR(10)),''); 							
	
				RAISERROR (@msg,16,126);
				--Se debe auditar proceso fallido
				If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar	@id_proceso = @idproce   ,
										 			 			@id_usuario = @id_usuario ,
										 			 			@cd_status  = 0           ,
										 			 			@msgparams  = @Numdoc, 
										 			 			@admsg      = @msg	  ;				
				RETURN @retval;
		     End
		End CATCH  
	   --Endregion
	End 
	
	--region: Manejo de reintentos
	If (@retrycont>@maxretries) 
	Begin 
		SET @retval = 1
		SET @msg = 'No se pudo finalizar el proceso. Maximo numero de reintentos alcanzado.'
		--Se debe auditar proceso fallido
		If (@bl_af = 1) EXEC dbo.spzaAuditoria_Insertar  @id_proceso = @idproce    ,
											 			 @id_usuario = @id_usuario ,
											 			 @cd_status  = 0           ,
											 			 @msgparams  = @Numdoc, 
											 			 @admsg      = @msg	   ;												 	   					   
  		RAISERROR (@msg,16,127);
  		RETURN @retval;
  	End   	
    --Endregion
    RETURN @retval;
End