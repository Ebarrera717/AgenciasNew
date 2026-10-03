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
    v_key TEXT;
    v_id INT;
    v_estado TEXT;
    v_row_json JSONB;
    v_cot_val TEXT;
BEGIN
    /**
     * Este procedimiento recibe la respuesta de SQL Server (spCotizacionesCrear)
     * Soporta:
     * 1. Nodo 'Estados': formato 'CONSECUTIVO:Estado|CONSECUTIVO:Estado|'
     * 2. Objetos directos con { "Cotizacion": "...", "Estado": "...", "bl_existe": ..., "quotationId": ... }
     * 3. Actualización flexible por internalNumber o id de forma segura
     */
    
    IF JSONB_TYPEOF(p_response) = 'array' THEN
        FOR v_row_json IN SELECT jsonb_array_elements(p_response)
        LOOP
            -- 1. Parsear el nodo 'Estados' si está presente
            v_estados_str := v_row_json->>'Estados';
            
            IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
                FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
                LOOP
                    v_item_text := trim(v_item_text);
                    IF v_item_text LIKE '%:%' THEN
                        v_key := split_part(v_item_text, ':', 1);
                        v_estado := split_part(v_item_text, ':', 2);
                        
                        IF UPPER(v_estado) = 'ENVIADO' THEN
                            v_estado := 'ENVIADO';
                        ELSIF UPPER(v_estado) = 'NUEVO' THEN
                            v_estado := 'NUEVO';
                        END IF;
                        
                        -- Intentar actualizar por internalNumber
                        UPDATE public."Quotation"
                        SET "state" = v_estado,
                            "stateUpdatedAt" = CURRENT_TIMESTAMP
                        WHERE "internalNumber" = v_key;
                        
                        IF NOT FOUND THEN
                            BEGIN
                                IF v_key ~ '^[0-9]+$' THEN
                                    v_id := v_key::INT;
                                    UPDATE public."Quotation"
                                    SET "state" = v_estado,
                                        "stateUpdatedAt" = CURRENT_TIMESTAMP
                                    WHERE id = v_id;
                                ELSIF v_key ~ '^Q[0-9]+$' THEN
                                    v_id := substring(v_key from 2)::INT;
                                    UPDATE public."Quotation"
                                    SET "state" = v_estado,
                                        "stateUpdatedAt" = CURRENT_TIMESTAMP
                                    WHERE id = v_id;
                                END IF;
                            EXCEPTION WHEN OTHERS THEN END;
                        END IF;
                    END IF;
                END LOOP;
            END IF;

            -- 2. Procesar por quotationId o Cotizacion directa
            IF v_row_json->>'quotationId' IS NOT NULL AND (v_row_json->>'quotationId') ~ '^[0-9]+$' THEN
                v_id := (v_row_json->>'quotationId')::INT;
                UPDATE public."Quotation"
                SET "state" = 'ENVIADO',
                    "stateUpdatedAt" = CURRENT_TIMESTAMP
                WHERE id = v_id;
            END IF;

            v_cot_val := COALESCE(v_row_json->>'Cotizacion', v_row_json->>'cd_consecutivo');
            IF v_cot_val IS NOT NULL AND v_cot_val <> '' THEN
                UPDATE public."Quotation"
                SET "state" = 'ENVIADO',
                    "stateUpdatedAt" = CURRENT_TIMESTAMP
                WHERE "internalNumber" = v_cot_val;
                
                IF NOT FOUND THEN
                    BEGIN
                        IF v_cot_val ~ '^[0-9]+$' THEN
                            UPDATE public."Quotation"
                            SET "state" = 'ENVIADO',
                                "stateUpdatedAt" = CURRENT_TIMESTAMP
                            WHERE id = v_cot_val::INT;
                        ELSIF v_cot_val ~ '^Q[0-9]+$' THEN
                            UPDATE public."Quotation"
                            SET "state" = 'ENVIADO',
                                "stateUpdatedAt" = CURRENT_TIMESTAMP
                            WHERE id = substring(v_cot_val from 2)::INT;
                        END IF;
                    EXCEPTION WHEN OTHERS THEN END;
                END IF;
            END IF;
        END LOOP;

    ELSIF JSONB_TYPEOF(p_response) = 'object' THEN
        v_estados_str := p_response->>'Estados';
        IF v_estados_str IS NOT NULL AND v_estados_str <> '' THEN
            FOR v_item_text IN SELECT unnest(string_to_array(btrim(v_estados_str, '|'), '|'))
            LOOP
                v_item_text := trim(v_item_text);
                IF v_item_text LIKE '%:%' THEN
                    v_key := split_part(v_item_text, ':', 1);
                    v_estado := split_part(v_item_text, ':', 2);
                    
                    IF UPPER(v_estado) = 'ENVIADO' THEN
                        v_estado := 'ENVIADO';
                    ELSIF UPPER(v_estado) = 'NUEVO' THEN
                        v_estado := 'NUEVO';
                    END IF;
                    
                    UPDATE public."Quotation"
                    SET "state" = v_estado,
                        "stateUpdatedAt" = CURRENT_TIMESTAMP
                    WHERE "internalNumber" = v_key;
                    
                    IF NOT FOUND THEN
                        BEGIN
                            IF v_key ~ '^[0-9]+$' THEN
                                v_id := v_key::INT;
                                UPDATE public."Quotation"
                                SET "state" = v_estado,
                                    "stateUpdatedAt" = CURRENT_TIMESTAMP
                                WHERE id = v_id;
                            ELSIF v_key ~ '^Q[0-9]+$' THEN
                                v_id := substring(v_key from 2)::INT;
                                UPDATE public."Quotation"
                                SET "state" = v_estado,
                                    "stateUpdatedAt" = CURRENT_TIMESTAMP
                                WHERE id = v_id;
                            END IF;
                        EXCEPTION WHEN OTHERS THEN END;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        IF p_response->>'quotationId' IS NOT NULL AND (p_response->>'quotationId') ~ '^[0-9]+$' THEN
            v_id := (p_response->>'quotationId')::INT;
            UPDATE public."Quotation"
            SET "state" = 'ENVIADO',
                "stateUpdatedAt" = CURRENT_TIMESTAMP
            WHERE id = v_id;
        END IF;

        v_cot_val := COALESCE(p_response->>'Cotizacion', p_response->>'cd_consecutivo');
        IF v_cot_val IS NOT NULL AND v_cot_val <> '' THEN
            UPDATE public."Quotation"
            SET "state" = 'ENVIADO',
                "stateUpdatedAt" = CURRENT_TIMESTAMP
            WHERE "internalNumber" = v_cot_val;
            
            IF NOT FOUND THEN
                BEGIN
                    IF v_cot_val ~ '^[0-9]+$' THEN
                        UPDATE public."Quotation"
                        SET "state" = 'ENVIADO',
                            "stateUpdatedAt" = CURRENT_TIMESTAMP
                        WHERE id = v_cot_val::INT;
                    ELSIF v_cot_val ~ '^Q[0-9]+$' THEN
                        UPDATE public."Quotation"
                        SET "state" = 'ENVIADO',
                            "stateUpdatedAt" = CURRENT_TIMESTAMP
                        WHERE id = substring(v_cot_val from 2)::INT;
                    END IF;
                EXCEPTION WHEN OTHERS THEN END;
            END IF;
        END IF;
    END IF;
END;
$$;
