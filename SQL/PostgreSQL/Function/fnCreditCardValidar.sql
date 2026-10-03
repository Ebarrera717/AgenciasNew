DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnCreditCardValidar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public."fnCreditCardValidar"(
    p_referencia text
)
RETURNS TABLE(
    es_valido boolean,
    codigo_tarjeta text,
    numero_tarjeta text,
    tarjeta_id integer,
    nombre_tarjeta text,
    mensaje text
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_code text;
    v_number text;
    v_id integer;
    v_name text;
BEGIN
    IF p_referencia IS NULL OR TRIM(p_referencia) = '' THEN
        RETURN QUERY SELECT true, ''::text, ''::text, NULL::integer, ''::text, 'OK'::text;
        RETURN;
    END IF;

    p_referencia := TRIM(p_referencia);

    -- Si tiene al menos 2 caracteres iniciales que son letras (ej: VI0000000000007023)
    IF length(p_referencia) >= 2 AND substring(p_referencia from 1 for 2) ~ '^[A-Za-z]{2}$' THEN
        v_code := UPPER(substring(p_referencia from 1 for 2));
        v_number := substring(p_referencia from 3);

        SELECT c.id, c.name INTO v_id, v_name
        FROM public."CreditCard" c
        WHERE UPPER(TRIM(c.code)) = v_code AND c.inactive = false
        LIMIT 1;

        IF v_id IS NOT NULL THEN
            RETURN QUERY SELECT true, v_code, v_number, v_id, v_name, 'SUCCESS'::text;
        ELSE
            RETURN QUERY SELECT false, v_code, v_number, NULL::integer, ''::text, ('El código de tarjeta "' || v_code || '" no existe en el Maestro de Tarjetas de Crédito.')::text;
        END IF;
    ELSE
        -- Si son solo números o no empieza por código de 2 letras
        RETURN QUERY SELECT true, ''::text, p_referencia, NULL::integer, ''::text, 'Sin código de tipo de tarjeta'::text;
    END IF;
END;
$function$;
