DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnEquivalenceInterface'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnEquivalenceInterface"(
	p_id_interface integer,
	p_id_master integer,
	p_value text
)
RETURNS text
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    v_equivalence TEXT;
    v_master_code TEXT;
BEGIN
    -- Si el valor es nulo o vacío, retornamos el mismo valor
    IF p_value IS NULL OR trim(p_value) = '' THEN
        RETURN p_value;
    END IF;

    -- Buscamos el equivalente en la tabla EquivalencesInterfaces
    SELECT cd_codigo 
    INTO v_equivalence
    FROM public."EquivalencesInterfaces"
    WHERE id_interfaces = p_id_interface
      AND id_master = p_id_master
      AND cd_codigoInte = p_value
    LIMIT 1;

    -- Si no se encuentra equivalencia:
    IF v_equivalence IS NULL OR trim(v_equivalence) = '' THEN
        -- Si corresponde al maestro de Impuestos (ChargeAndTax), mapear por defecto a 'OTR' (Otros Impuestos)
        SELECT code INTO v_master_code FROM public."Master" WHERE id = p_id_master LIMIT 1;
        IF v_master_code = 'ChargeAndTax' THEN
            RETURN 'OTR';
        ELSE
            RETURN p_value;
        END IF;
    ELSE
        RETURN v_equivalence;
    END IF;
END;
$BODY$;

ALTER FUNCTION public."fnEquivalenceInterface"(integer, integer, text) OWNER TO postgres;
