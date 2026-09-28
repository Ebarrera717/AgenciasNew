const fs = require('fs');
const path = require('path');

const alterPath = path.join(__dirname, '..', 'SQL', 'Table', 'Alter_New_Columns.sql');
if (fs.existsSync(alterPath)) {
    let content = fs.readFileSync(alterPath, 'utf8');

    // Remove stray IF EXISTS outside DO block
    const strayRegex = /\r?\n\s*-- Nullable foreign keys for Cities and Airports[\s\S]*?ALTER TABLE public\."Airports" ALTER COLUMN "citiesId" DROP NOT NULL;\s*\r?\n\s*END IF;/g;
    content = content.replace(strayRegex, '');

    // Now insert inside the main DO block before the final END $$;
    const injection = `
    -- Nullable foreign keys for Cities and Airports
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Cities' AND column_name = 'countriesId' AND is_nullable = 'NO') THEN
        ALTER TABLE public."Cities" ALTER COLUMN "countriesId" DROP NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'Airports' AND column_name = 'citiesId' AND is_nullable = 'NO') THEN
        ALTER TABLE public."Airports" ALTER COLUMN "citiesId" DROP NOT NULL;
    END IF;
END $$;`;

    // Only add if not already inside
    if (!content.includes('ALTER TABLE public."Cities" ALTER COLUMN "countriesId" DROP NOT NULL;')) {
        content = content.replace(/END \$\$;/g, (match, offset, str) => {
            // Replace the last occurrence of END $$;
            if (offset === str.lastIndexOf('END $$;')) {
                return injection;
            }
            return match;
        });
    }

    fs.writeFileSync(alterPath, content, 'utf8');
    console.log('Alter_New_Columns.sql cleaned and updated.');
}
