DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT oid::regprocedure AS proc_name 
        FROM pg_proc 
        WHERE proname ILIKE 'spMaestroImportar'
    LOOP
        EXECUTE 'DROP PROCEDURE ' || r.proc_name || '';
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE public.spMaestroImportar(
    p_tipo TEXT,
    p_text_data TEXT, -- Delimited text (Rows by \n, Cols by ^)
    p_acting_user_id INT,
    INOUT p_mensaje_resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_text TEXT;
    v_cols TEXT[];
    v_count INT := 0;
    v_errors TEXT := '';
    v_branch_id INT;
    v_provider_id INT;
    v_prov_type_id INT;
    v_role_id INT;
    v_hashed_password TEXT := '$2a$10$7zB.Y7S5y5y5y5y5y5y5y.y5y5y5y5y5y5y5y5y5y5y5y5y5y5y'; -- Placeholder hash
BEGIN
    FOR v_row_text IN SELECT unnest(string_to_array(p_text_data, E'\n')) LOOP
        IF TRIM(v_row_text) = '' THEN CONTINUE; END IF;
        
        BEGIN
            v_cols := string_to_array(v_row_text, '^');
            
            IF p_tipo = 'sucursales' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Branch" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'implants' THEN
                -- Format: code^name^branchCode
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    v_branch_id := NULL;
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        SELECT id INTO v_branch_id FROM public."Branch" WHERE LOWER("code") = LOWER(TRIM(v_cols[3]));
                    END IF;
                    
                    INSERT INTO public."Implant" ("code", "name", "branchId")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), v_branch_id)
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "branchId" = EXCLUDED."branchId";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'vendedores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Seller" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."Seller" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tiqueteadores' THEN
                -- Format: name^email^code
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."TicketPrinter" ("code", "name", "email")
                        VALUES (TRIM(v_cols[3]), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''))
                        ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";
                    ELSE
                        INSERT INTO public."TicketPrinter" ("name", "email") VALUES (TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), ''));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'impuestos' THEN
                -- Format: code^name^type^valueType^value
                IF v_cols[2] IS NOT NULL AND v_cols[3] IS NOT NULL THEN
                    INSERT INTO public."ChargeAndTax" ("code", "name", "type", "valueType", "value", "isEditable", "inNationality")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]), NULLIF(TRIM(v_cols[5]), '')::DECIMAL, TRUE, COALESCE(NULLIF(TRIM(v_cols[6]), '')::INT, 1))
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "type" = EXCLUDED."type",
                        "valueType" = EXCLUDED."valueType",
                        "value" = EXCLUDED."value",
                        "inNationality" = EXCLUDED."inNationality";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'clientes' THEN
                -- Format: document^name^contactInfo^address
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."Client" ("document", "name", "contactInfo", "address")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]), TRIM(v_cols[4]))
                    ON CONFLICT ("document") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo", 
                        "address" = EXCLUDED."address";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'proveedores' THEN
                -- Format: code^name^contactInfo^providerTypeCode^airlineCode^sigla
                IF v_cols[2] IS NOT NULL OR v_cols[1] IS NOT NULL THEN
                    v_prov_type_id := NULL;
                    IF array_length(v_cols, 1) >= 4 AND v_cols[4] IS NOT NULL AND TRIM(v_cols[4]) <> '' THEN
                        SELECT id INTO v_prov_type_id FROM public."ProviderType" WHERE LOWER("code") = LOWER(TRIM(v_cols[4])) OR LOWER("name") = LOWER(TRIM(v_cols[4])) LIMIT 1;
                    END IF;

                    INSERT INTO public."Provider" ("code", "name", "contactInfo", "providerTypeId", "airlineCode", "sigla")
                    VALUES (
                        NULLIF(TRIM(v_cols[1]), ''), 
                        TRIM(v_cols[2]), 
                        NULLIF(TRIM(v_cols[3]), ''), 
                        v_prov_type_id, 
                        CASE WHEN array_length(v_cols, 1) >= 5 THEN NULLIF(TRIM(v_cols[5]), '') ELSE NULL END,
                        CASE WHEN array_length(v_cols, 1) >= 6 THEN NULLIF(TRIM(v_cols[6]), '') ELSE NULL END
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name", 
                        "contactInfo" = EXCLUDED."contactInfo",
                        "providerTypeId" = COALESCE(EXCLUDED."providerTypeId", public."Provider"."providerTypeId"),
                        "airlineCode" = COALESCE(EXCLUDED."airlineCode", public."Provider"."airlineCode"),
                        "sigla" = COALESCE(EXCLUDED."sigla", public."Provider"."sigla");
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'tipos-proveedores' THEN
                -- Format: code^name^isAirline
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."ProviderType" ("code", "name", "isAirline", "active")
                    VALUES (
                        TRIM(v_cols[1]), 
                        TRIM(v_cols[2]), 
                        (UPPER(TRIM(v_cols[3])) IN ('SI', 'S', 'TRUE', '1')), 
                        true
                    )
                    ON CONFLICT ("code") DO UPDATE SET 
                        "name" = EXCLUDED."name",
                        "isAirline" = EXCLUDED."isAirline";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'productos' THEN
                -- Format: description^basePrice^code^type^billingConcept^serviceType
                IF v_cols[1] IS NOT NULL THEN
                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Product" ("code", "type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (TRIM(v_cols[3]), COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "type" = EXCLUDED."type",
                            "description" = EXCLUDED."description",
                            "basePrice" = EXCLUDED."basePrice",
                            "billingConcept" = EXCLUDED."billingConcept",
                            "serviceType" = EXCLUDED."serviceType";
                    ELSE
                        INSERT INTO public."Product" ("type", "description", "basePrice", "billingConcept", "serviceType")
                        VALUES (COALESCE(TRIM(v_cols[4]), 'SERVICE'), TRIM(v_cols[1]), NULLIF(TRIM(v_cols[2]), '')::DECIMAL, TRIM(v_cols[5]), TRIM(v_cols[6]));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'prestadoras' THEN
                -- Format: name^providerCode^code^category^location^type
                IF v_cols[1] IS NOT NULL THEN
                    v_provider_id := NULL;
                    IF v_cols[2] IS NOT NULL AND TRIM(v_cols[2]) <> '' THEN
                        SELECT id INTO v_provider_id FROM public."Provider" WHERE LOWER("code") = LOWER(TRIM(v_cols[2])) OR LOWER("name") = LOWER(TRIM(v_cols[2])) LIMIT 1;
                    END IF;

                    IF v_cols[3] IS NOT NULL AND TRIM(v_cols[3]) <> '' THEN
                        INSERT INTO public."Prestadora" ("name", "providerId", "code", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[3]), TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'))
                        ON CONFLICT ("code") DO UPDATE SET 
                            "name" = EXCLUDED."name",
                            "providerId" = EXCLUDED."providerId",
                            "category" = EXCLUDED."category",
                            "location" = EXCLUDED."location",
                            "type" = EXCLUDED."type";
                    ELSE
                        INSERT INTO public."Prestadora" ("name", "providerId", "category", "location", "type")
                        VALUES (TRIM(v_cols[1]), v_provider_id, TRIM(v_cols[4]), TRIM(v_cols[5]), COALESCE(TRIM(v_cols[6]), 'HOTEL'));
                    END IF;
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'variables' THEN
                -- Format: code^name
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."MasterVariable" ("code", "name")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name";
                    v_count := v_count + 1;
                END IF;

            ELSIF p_tipo = 'parametros' THEN
                -- Format: code^name^value
                IF v_cols[1] IS NOT NULL AND v_cols[2] IS NOT NULL THEN
                    INSERT INTO public."SystemParameter" ("code", "name", "value")
                    VALUES (TRIM(v_cols[1]), TRIM(v_cols[2]), TRIM(v_cols[3]))
                    ON CONFLICT ("code") DO UPDATE SET "name" = EXCLUDED."name", "value" = EXCLUDED."value";
                    v_count := v_count + 1;
                END IF;

            END IF;

        EXCEPTION WHEN OTHERS THEN
            v_errors := v_errors || 'Error en fila [' || v_row_text || ']: ' || SQLERRM || '; ';
        END;
    END LOOP;

    p_mensaje_resultado := 'SUCCESS: Registros procesados: ' || v_count || '. ' || COALESCE(v_errors, '');
END;
$$;
