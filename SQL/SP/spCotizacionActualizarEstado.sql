DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spCotizacionActualizarEstado'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spCotizacionActualizarEstado(
    p_response JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estados_str TEXT;
    v_item_text TEXT;
    v_id INT;
    v_estado TEXT;
    v_row_json JSONB;
BEGIN
    /**
     * Este procedimiento recibe la respuesta de SQL Server (spCotizacionesCrear)
     * Parsea UNICAMENTE el nodo 'Estados' que contiene el formato 'ID:Estado|ID:Estado|'
     */
    
    -- El input puede ser un array de objetos o un objeto individual
    -- Buscamos el campo 'Estados' en cada objeto
	
    IF JSONB_TYPEOF(p_response) = 'array' THEN
        FOR v_row_json IN SELECT jsonb_array_elements(p_response)
        LOOP
            v_estados_str := v_row_json->>'Estados';
            
            IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
                -- Iterar sobre cada par ID:Estado separado por '|'
                FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
                LOOP
                    v_item_text := trim(v_item_text);
                    IF v_item_text LIKE '%:%' THEN
                        BEGIN
                            -- Split por ':'
                            v_id := split_part(v_item_text, ':', 1)::INT;
                            v_estado := split_part(v_item_text, ':', 2);
                            
                            -- Actualizar con el estado LITERAL recibido
                            UPDATE public."Quotation"
                            SET "state" = v_estado
                            WHERE id = v_id;
                        EXCEPTION WHEN OTHERS THEN
                            -- Ignorar errores de casteo en items individuales
                        END;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    ELSIF JSONB_TYPEOF(p_response) = 'object' THEN
        v_estados_str := p_response->>'Estados';
        IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
            FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
            LOOP
                v_item_text := trim(v_item_text);
                IF v_item_text LIKE '%:%' THEN
                    BEGIN
                        v_id := split_part(v_item_text, ':', 1)::INT;
                        v_estado := split_part(v_item_text, ':', 2);
                        
                        UPDATE public."Quotation"
                        SET "state" = v_estado
                        WHERE id = v_id;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END LOOP;
        END IF;
    END IF;
	--SELECT * from public."Quotation" WHERE id = 31; 
	--UPDATE public."Quotation"
	--SET "state" = 'Nuevo'--v_row_json::text
	--WHERE id = 31; 
END;
$$;
