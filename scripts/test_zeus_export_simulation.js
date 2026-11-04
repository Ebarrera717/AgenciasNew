const mssql = require('mssql');

(async () => {
    const pool = await mssql.connect({
        server: '192.168.15.8', user: 'zeusagencias', password: 'zzeusagencias', database: 'ZeusAgencias_Colaereo',
        options: { encrypt: false, trustServerCertificate: true }
    });

    const testXml = `
<Cotizaciones>
    <Cotizacion>
        <cd_sucursal>1</cd_sucursal>
        <cd_implante></cd_implante>
        <cd_consecutivo>00000018</cd_consecutivo>
        <cd_usuario>1</cd_usuario>
        <dt_fechacont>2026-10-06T08:52:00</dt_fechacont>
        <dt_fecha>2026-10-06T08:52:00</dt_fecha>
        <dt_fechaAct>2026-10-06T08:52:00</dt_fechaAct>
        <cd_tercero_codigo>890906312</cd_tercero_codigo>
        <ds_tercero_nombre>LIGA DE NATACION DE ANTIOQUIA</ds_tercero_nombre>
        <cd_cliente_codigo>890906312</cd_cliente_codigo>
        <ds_cliente_nombre>LIGA DE NATACION DE ANTIOQUIA</ds_cliente_nombre>
        <ds_cliente_dir>CR 72 CL 48 100</ds_cliente_dir>
        <ds_cliente_ciudad></ds_cliente_ciudad>
        <ds_cliente_tel></ds_cliente_tel>
        <ds_cliente_dirdesp></ds_cliente_dirdesp>
        <ds_cliente_email>mayoreo2.medellin@colaereo.com</ds_cliente_email>
        <ds_cliente_contacto>LIGA DE NATACION DE ANTIOQUIA</ds_cliente_contacto>
        <ds_cliente_contacto_email></ds_cliente_contacto_email>
        <cd_monedas_IATA>COP</cd_monedas_IATA>
        <cd_vendedor>JLR</cd_vendedor>
        <cd_tiqueteador>IV</cd_tiqueteador>
        <am_tcambio>1</am_tcambio>
        <am_tcambiousd>1</am_tcambiousd>
        <cd_cencosto></cd_cencosto>
        <ds_observacion></ds_observacion>
        <ds_Campo_libre1></ds_Campo_libre1>
        <ds_Campo_libre2></ds_Campo_libre2>
        <cd_tipoventa></cd_tipoventa>
        <in_estado>1</in_estado>
        <dt_vence>2026-10-06T08:52:00</dt_vence>
        <ds_FormaDePago></ds_FormaDePago>
        <id_sys_entidades>65</id_sys_entidades>
        <orig_id_ref>18</orig_id_ref>
        <CotizacionServicios>
            <cd_TiposConceptFac>1</cd_TiposConceptFac>
            <cd_ConceptoFacturacion>1</cd_ConceptoFacturacion>
            <cd_TiposServicio>1</cd_TiposServicio>
            <cd_Cotizacion>00000018</cd_Cotizacion>
            <cd_proveedores></cd_proveedores>
            <ds_tiposervnm>TIQUETES</ds_tiposervnm>
            <ds_destino>MDE</ds_destino>
            <ds_servicio>TIQUETE AEREO</ds_servicio>
            <ds_descrip>TIQUETE AEREO</ds_descrip>
            <ds_paxname>SHARA STEFANIA</ds_paxname>
            <ds_paxape>MUNERA</ds_paxape>
            <cd_paxtype>ADT</cd_paxtype>
            <in_nacionalidad>1</in_nacionalidad>
            <cd_voucher></cd_voucher>
            <in_cantpax>1</in_cantpax>
            <dt_llegada>2026-10-06T08:52:00</dt_llegada>
            <dt_salida>2026-10-06T08:52:00</dt_salida>
            <am_valorprov>100000</am_valorprov>
            <id_monedaprov>1</id_monedaprov>
            <ds_InfoAdicional></ds_InfoAdicional>
            <bl_anulado>0</bl_anulado>
            <cd_tiquete></cd_tiquete>
            <am_basecomisionable>100000</am_basecomisionable>
            <am_porcomision>0</am_porcomision>
            <CotizacionCargos>
                <id_cargosdesc>1</id_cargosdesc>
                <ds_cargonm>TARIFA</ds_cargonm>
                <bl_noshow>0</bl_noshow>
                <am_contado>121504</am_contado>
                <am_credito>0</am_credito>
                <am_contado_ME>121504</am_contado_ME>
                <am_credito_ME>0</am_credito_ME>
            </CotizacionCargos>
        </CotizacionServicios>
    </Cotizacion>
</Cotizaciones>
    `;

    console.log('Ejecutando dbo.spCotizacionesCrear con XML de prueba (consecutivo 00000018, tiqueteador IV, ciudad vacía)...');
    const req = pool.request();
    req.input('xml', mssql.VarChar(mssql.MAX), testXml);
    const result = await req.execute('dbo.spCotizacionesCrear');
    console.log('Resultado SP:', result.recordset);

    const check = await pool.request().query("SELECT TOP 1 id, cd_consecutivo, cd_cliente_codigo, ds_cliente_nombre, ds_cliente_dir, ds_cliente_ciudad, ds_cliente_tel, id_tiqueteador FROM dbo.Cotizacion WHERE cd_consecutivo = '00000018'");
    console.log('Cotizacion 18 en dbo.Cotizacion:', check.recordset[0]);

    const tq = await pool.request().query("SELECT id, cd_codigo, ds_nombre FROM dbo.Tiqueteadores WHERE id = " + check.recordset[0].id_tiqueteador);
    console.log('Tiqueteador asignado:', tq.recordset[0]);

    await pool.close();
})();
