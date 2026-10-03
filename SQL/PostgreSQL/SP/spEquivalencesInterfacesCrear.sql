DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spEquivalencesInterfacesCrear'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public."spEquivalencesInterfacesCrear"(
    IN p_id_interfaces integer,
    IN p_id_master integer,
    IN p_cd_maestro text,
    IN p_cd_codigo text,
    IN p_cd_codigoInte text,
    IN p_user_id integer,
    INOUT p_new_id integer DEFAULT NULL
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_log_id INT;
BEGIN
    INSERT INTO public."EquivalencesInterfaces" (
        id_interfaces, 
        id_master, 
        cd_maestro, 
        cd_codigo, 
        cd_codigoInte
    ) VALUES (
        p_id_interfaces,
        p_id_master,
        p_cd_maestro,
        p_cd_codigo,
        p_cd_codigoInte
    ) RETURNING id INTO p_new_id;

    -- Registrar en SystemLog
    CALL public."spLogRegistrar"(
        p_user_id,
        'EQUIVALENCES_INTERFACES',
        'CREATE',
        'Creación de equivalencia de interface con ID: ' || p_new_id,
        jsonb_build_object(
            'id_interfaces', p_id_interfaces,
            'id_master', p_id_master,
            'cd_maestro', p_cd_maestro,
            'cd_codigo', p_cd_codigo,
            'cd_codigoInte', p_cd_codigoInte
        ),
        v_log_id
    );
END;
$BODY$;
