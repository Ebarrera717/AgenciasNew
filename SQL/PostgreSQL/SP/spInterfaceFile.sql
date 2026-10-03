-- Drop de sobrecargas previas para prevenir error 42883
DO $$ 
BEGIN
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacefile(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceFile"(text, text, text) CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public.spinterfacefile CASCADE';
    EXECUTE 'DROP PROCEDURE IF EXISTS public."spInterfaceFile" CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Procedimiento Principal Case-Insensitive (para Npgsql / C#)
CREATE OR REPLACE PROCEDURE public.spinterfacefile(
    op TEXT,
    booking TEXT,
    file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    file_extension TEXT;
BEGIN
    file_extension := lower(substring(file from '\.[^\.]*$'));

    IF file_extension = '.fil' THEN
        CALL public.spinterfacesabre(op, booking, file);
    ELSE
        CALL public.spinterfaceamadeus(op, booking, file);
    END IF;
END;
$BODY$;

-- Alias con comillas para retrocompatibilidad
CREATE OR REPLACE PROCEDURE public."spInterfaceFile"(
    op TEXT,
    booking TEXT,
    file TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    CALL public.spinterfacefile(op, booking, file);
END;
$BODY$;
