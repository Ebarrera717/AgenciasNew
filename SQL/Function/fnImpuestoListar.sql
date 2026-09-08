DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'fnImpuestoListar'
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.proc_name || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fnImpuestoListar()
RETURNS SETOF JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsonb_build_object(
            'id', t.id,
            'code', t.code,
            'name', t.name,
            'type', t.type,
            'valueType', t."valueType",
            'value', t.value,
            'isEditable', t."isEditable",
            'orden', COALESCE(t.orden, 0),
            'productIds', COALESCE(t."productIds", '[]'::jsonb),
            'targetTaxId', t."targetTaxId",
            'isActive', COALESCE(t."isActive", true),
            'gdsEquivalences', COALESCE((
                SELECT string_agg(DISTINCT eq."cd_codigointe", ', ')
                FROM public."EquivalencesInterfaces" eq
                INNER JOIN public."Master" m ON m.id = eq.id_master
                WHERE m.code = 'ChargeAndTax' AND eq.cd_codigo = t.code
            ), '')
        )
    FROM public."ChargeAndTax" t
    ORDER BY 
        CASE 
            WHEN COALESCE(t.orden, 0) > 0 THEN t.orden 
            WHEN t.code = 'TAR' THEN 1 
            ELSE 9999 
        END ASC, 
        t.name ASC;
END;
$$;
