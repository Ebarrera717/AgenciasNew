import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { encryptPassword, decryptPassword, isEncrypted } from '@/lib/security'

export const dynamic = 'force-dynamic'

async function isPasswordEncryptionActive(): Promise<boolean> {
    if (process.env.ENCRYPT_PASSWORDS === '1' || process.env.ENCRYPT_PASSWORDS?.toLowerCase() === 'true') {
        return true;
    }
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query("SELECT [value] FROM dbo.[SystemParameter] WHERE [code] = 'EncriptarClaves'");
                await pool.close();
                const val = res.recordset[0]?.value;
                return val === '1' || val === 'true' || val === 'SI';
            } catch (err) {
                if (pool) await pool.close();
                return false;
            }
        } else {
            const rows = await prisma.$queryRawUnsafe<any[]>("SELECT value FROM public.\"SystemParameter\" WHERE code = 'EncriptarClaves'");
            const val = rows[0]?.value;
            return val === '1' || val === 'true' || val === 'SI';
        }
    } catch (e) {
        return false;
    }
}

async function syncClaveSQLServerEncryption(targetEncrypted: boolean) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query("SELECT [id], [value] FROM dbo.[SystemParameter] WHERE [code] = 'ClaveSQLServer'");
                const row = res.recordset[0];
                if (row && row.value && row.value.trim() !== '') {
                    const currVal = row.value.trim();
                    let newVal = currVal;
                    if (targetEncrypted && !isEncrypted(currVal)) {
                        newVal = encryptPassword(currVal);
                    } else if (!targetEncrypted && isEncrypted(currVal)) {
                        newVal = decryptPassword(currVal);
                    }
                    if (newVal !== currVal) {
                        await pool.request()
                            .input('id', row.id)
                            .input('val', newVal)
                            .query("UPDATE dbo.[SystemParameter] SET [value] = @val WHERE [id] = @id");
                    }
                }
                await pool.close();
            } catch (err) {
                if (pool) await pool.close();
            }
        } else {
            const rows = await prisma.$queryRawUnsafe<any[]>("SELECT id, value FROM public.\"SystemParameter\" WHERE code = 'ClaveSQLServer'");
            const row = rows[0];
            if (row && row.value && row.value.trim() !== '') {
                const currVal = row.value.trim();
                let newVal = currVal;
                if (targetEncrypted && !isEncrypted(currVal)) {
                    newVal = encryptPassword(currVal);
                } else if (!targetEncrypted && isEncrypted(currVal)) {
                    newVal = decryptPassword(currVal);
                }
                if (newVal !== currVal) {
                    await prisma.$queryRawUnsafe("UPDATE public.\"SystemParameter\" SET value = $1 WHERE id = $2", newVal, row.id);
                }
            }
        }
    } catch (e) {
        console.warn('[PARAMETERS_ENCRYPTION_SYNC] Error al sincronizar ClaveSQLServer:', e);
    }
}

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request().query(`
                    IF NOT EXISTS (SELECT 1 FROM dbo.[SystemParameter] WHERE [code] = 'EncriptarClaves')
                    BEGIN
                        INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
                        VALUES ('EncriptarClaves', 'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', '0');
                    END;
                `);
                const res = await pool.request().query(`
                    SELECT [id], [code], [name], [value]
                    FROM dbo.[SystemParameter]
                    ORDER BY [code] ASC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (p: any) => [p.code, p.name, p.value]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        await prisma.$queryRawUnsafe(`
            INSERT INTO public."SystemParameter" (code, name, value)
            VALUES ('EncriptarClaves', 'Encriptar Contraseñas de Base de Datos y Zeus ERP (1: Sí, 0: No)', '0')
            ON CONFLICT (code) DO NOTHING;
        `).catch(() => {});
        const parameters = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnParameterListar()`)
        return NextResponse.json(paginateArray(req, parameters, p => [p.code, p.name, p.value]))
    } catch (error) {
        return NextResponse.json({ message: 'Error retrieving system parameters' }, { status: 500 })
    }
}

export async function POST(req: NextRequest) {
    try {
        const { code, name, value } = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        let processedValue = value || '';
        if (code === 'ClaveSQLServer') {
            const encActive = await isPasswordEncryptionActive();
            if (encActive && processedValue && !isEncrypted(processedValue)) {
                processedValue = encryptPassword(processedValue);
            }
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', code || '')
                    .input('name', name || '')
                    .input('value', processedValue)
                    .query(`
                        INSERT INTO dbo.[SystemParameter] ([code], [name], [value])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @value)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const parameter = { id: dbId, code, name, value: processedValue };

                if (code === 'EncriptarClaves') {
                    await syncClaveSQLServerEncryption(processedValue === '1' || processedValue === 'true');
                }

                return NextResponse.json({ message: 'Parámetro creado', parameter });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::INT, $5::INT, $6::TEXT)`,
            code,
            name,
            processedValue,
            actingUserId,
            0, // p_parameter_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_parameter_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating parameter');
        }

        const parameter = { id: dbId, code, name, value: processedValue };

        if (code === 'EncriptarClaves') {
            await syncClaveSQLServerEncryption(processedValue === '1' || processedValue === 'true');
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'PARAMETER', description: `Parámetro ${parameter.name} creado (SP).`, metadata: parameter });
        });

        return NextResponse.json({ message: 'Parámetro creado', parameter })
    } catch (error: any) {
        console.error('Error creating parameter:', error);
        return NextResponse.json({ message: 'Error al crear parámetro: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const { id, code, name, value } = await req.json()
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        let processedValue = value || '';
        if (code === 'ClaveSQLServer') {
            const encActive = await isPasswordEncryptionActive();
            if (encActive && processedValue && !isEncrypted(processedValue)) {
                processedValue = encryptPassword(processedValue);
            } else if (!encActive && processedValue && isEncrypted(processedValue)) {
                processedValue = decryptPassword(processedValue);
            }
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code || '')
                    .input('name', name || '')
                    .input('value', processedValue)
                    .query(`
                        UPDATE dbo.[SystemParameter]
                        SET [code] = @code, [name] = @name, [value] = @value
                        WHERE [id] = @id
                    `);
                await pool.close();
                const parameter = { id, code, name, value: processedValue };

                if (code === 'EncriptarClaves') {
                    await syncClaveSQLServerEncryption(processedValue === '1' || processedValue === 'true');
                }

                return NextResponse.json({ message: 'Parámetro actualizado', parameter });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::INT, $6::TEXT)`,
            parseInt(id),
            code,
            name,
            processedValue,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        const parameter = { id, code, name, value: processedValue };

        if (code === 'EncriptarClaves') {
            await syncClaveSQLServerEncryption(processedValue === '1' || processedValue === 'true');
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'PARAMETER', description: `Parámetro ${parameter.name} actualizado (SP).`, metadata: parameter });
        });

        return NextResponse.json({ message: 'Parámetro actualizado', parameter })
    } catch (error: any) {
        console.error('Error updating parameter:', error);
        return NextResponse.json({ message: 'Error al actualizar parámetro: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const url = new URL(req.url)
        const id = url.searchParams.get('id')
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1
        
        if (!id) return NextResponse.json({ message: 'Missing ID' }, { status: 400 })

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[SystemParameter] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Parámetro eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spParameterEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'PARAMETER', description: `Parámetro con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Parámetro eliminado' })
    } catch (error: any) {
        console.error('Error deleting parameter:', error);
        return NextResponse.json({ message: 'Error al eliminar parámetro: ' + error.message }, { status: 500 })
    }
}
