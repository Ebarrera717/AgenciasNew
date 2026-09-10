import { paginateArray } from '@/lib/pagination'
import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
    try {
        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request().query(`
                    SELECT [id], [code], [name], [type], [valueType], [value], [isEditable], [orden], [productIds], [targetTaxId], [isActive],
                           CASE WHEN [isActive] = 1 THEN 0 ELSE 1 END AS [inactive]
                    FROM dbo.[ChargeAndTax]
                    ORDER BY [id] DESC
                `);
                await pool.close();
                return NextResponse.json(paginateArray(req, res.recordset as any[], (t: any) => [t?.code, t?.name, t?.type]));
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }
        const results = await prisma.$queryRawUnsafe<any[]>(`SELECT * FROM public.fnImpuestoListar()`)
        const taxes = (results || []).map(row => row.fnimpuestolistar || Object.values(row)[0]).filter(Boolean);
        return NextResponse.json(paginateArray(req, taxes, t => [t?.code, t?.name, t?.type, t?.gdsEquivalences]))
    } catch (error: any) {
        console.error('Error fetching taxes:', error);
        return NextResponse.json({ message: 'Error al obtener cargos e impuestos: ' + error?.message }, { status: 500 })
    }
}

async function syncGdsEquivalences(taxCode: string, gdsEquivalencesStr: string) {
    if (!taxCode) return;
    
    // Get master id for ChargeAndTax
    const masterRows: any[] = await prisma.$queryRawUnsafe(`SELECT id FROM public."Master" WHERE code = 'ChargeAndTax' LIMIT 1`);
    const masterId = masterRows[0]?.id;
    if (!masterId) return;

    // Split comma separated GDS codes
    const codes = (gdsEquivalencesStr || '')
        .split(',')
        .map(c => c.trim().toUpperCase())
        .filter(c => c.length > 0);

    // Delete existing equivalences for this tax code
    await prisma.$executeRawUnsafe(
        `DELETE FROM public."EquivalencesInterfaces" WHERE id_master = $1 AND cd_codigo = $2`,
        masterId, taxCode
    );

    // Insert new equivalences for Amadeus (id_interfaces = 2) and Sabre (id_interfaces = 1)
    for (const inteCode of codes) {
        // Amadeus (2)
        await prisma.$executeRawUnsafe(
            `INSERT INTO public."EquivalencesInterfaces" (id_interfaces, id_master, cd_maestro, cd_codigo, "cd_codigointe")
             VALUES (2, $1, 'ChargeAndTax', $2, $3)
             ON CONFLICT DO NOTHING`,
            masterId, taxCode, inteCode
        );
        // Sabre (1)
        await prisma.$executeRawUnsafe(
            `INSERT INTO public."EquivalencesInterfaces" (id_interfaces, id_master, cd_maestro, cd_codigo, "cd_codigointe")
             VALUES (1, $1, 'ChargeAndTax', $2, $3)
             ON CONFLICT DO NOTHING`,
            masterId, taxCode, inteCode
        );
    }
}

export async function POST(req: NextRequest) {
    try {
        const body = await req.json()
        const { code, name, type, valueType, value, isEditable, gdsEquivalences, orden, productIds, targetTaxId } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const numericVal = value !== undefined && value !== null && value !== '' && !isNaN(parseFloat(value)) ? parseFloat(value) : 0;
        const numericOrden = orden !== undefined && orden !== null && orden !== '' && !isNaN(parseInt(orden)) ? parseInt(orden) : 0;
        const productIdsJson = JSON.stringify(Array.isArray(productIds) ? productIds : []);
        const parsedTargetTaxId = targetTaxId !== undefined && targetTaxId !== null && targetTaxId !== '' ? parseInt(targetTaxId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const res = await pool.request()
                    .input('code', code || null)
                    .input('name', name || '')
                    .input('type', type || '')
                    .input('valueType', valueType || 'NONE')
                    .input('value', numericVal)
                    .input('isEditable', isEditable !== undefined ? (isEditable ? 1 : 0) : 1)
                    .input('orden', numericOrden)
                    .input('productIds', productIdsJson)
                    .input('targetTaxId', parsedTargetTaxId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        INSERT INTO dbo.[ChargeAndTax] ([code], [name], [type], [valueType], [value], [isEditable], [orden], [productIds], [targetTaxId], [isActive])
                        OUTPUT INSERTED.id
                        VALUES (@code, @name, @type, @valueType, @value, @isEditable, @orden, @productIds, @targetTaxId, @isActive)
                    `);
                await pool.close();
                const dbId = res.recordset[0]?.id;
                const tax = { id: dbId, ...body };
                return NextResponse.json(tax);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImpuestoCrear($1::TEXT, $2::TEXT, $3::TEXT, $4::TEXT, $5::DECIMAL, $6::BOOLEAN, $7::INT, $8::JSONB, $9::INT, $10::BOOLEAN, $11::INT, $12::INT, $13::TEXT)`,
            code || null,
            name,
            type,
            valueType || 'NONE',
            numericVal,
            isEditable !== undefined ? isEditable : true,
            numericOrden,
            productIdsJson,
            parsedTargetTaxId,
            isAct,
            actingUserId,
            0, // p_tax_id
            '' // p_mensaje_resultado
        );

        const dbId = results[0]?.p_tax_id;
        const message = results[0]?.p_mensaje_resultado || '';

        if (!dbId || message.startsWith('ERROR')) {
            throw new Error(message || 'Error creating tax');
        }

        if (code && gdsEquivalences !== undefined) {
            await syncGdsEquivalences(code, gdsEquivalences);
        }

        const tax = { id: dbId, ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'CREATE', module: 'MASTER_DATA', description: `Cargo/Impuesto ${tax.name} creado (SP).`, metadata: tax });
        });

        return NextResponse.json(tax)
    } catch (error: any) {
        console.error('Error creating tax:', error);
        return NextResponse.json({ message: 'Error al crear el cargo o impuesto: ' + error.message }, { status: 500 })
    }
}

export async function PUT(req: NextRequest) {
    try {
        const body = await req.json()
        const { id, code, name, type, valueType, value, isEditable, gdsEquivalences, orden, productIds, targetTaxId } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const numericVal = value !== undefined && value !== null && value !== '' && !isNaN(parseFloat(value)) ? parseFloat(value) : 0;
        const numericOrden = orden !== undefined && orden !== null && orden !== '' && !isNaN(parseInt(orden)) ? parseInt(orden) : 0;
        const productIdsJson = JSON.stringify(Array.isArray(productIds) ? productIds : []);
        const parsedTargetTaxId = targetTaxId !== undefined && targetTaxId !== null && targetTaxId !== '' ? parseInt(targetTaxId) : null;
        const isAct = body.isActive !== undefined ? body.isActive : (body.inactive !== undefined ? !body.inactive : true);

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .input('code', code || null)
                    .input('name', name || '')
                    .input('type', type || '')
                    .input('valueType', valueType || 'NONE')
                    .input('value', numericVal)
                    .input('isEditable', isEditable !== undefined ? (isEditable ? 1 : 0) : 1)
                    .input('orden', numericOrden)
                    .input('productIds', productIdsJson)
                    .input('targetTaxId', parsedTargetTaxId)
                    .input('isActive', isAct ? 1 : 0)
                    .query(`
                        UPDATE dbo.[ChargeAndTax]
                        SET [code] = @code, [name] = @name, [type] = @type, [valueType] = @valueType, [value] = @value,
                            [isEditable] = @isEditable, [orden] = @orden, [productIds] = @productIds, [targetTaxId] = @targetTaxId, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const tax = { ...body };
                return NextResponse.json(tax);
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImpuestoActualizar($1::INT, $2::TEXT, $3::TEXT, $4::TEXT, $5::TEXT, $6::DECIMAL, $7::BOOLEAN, $8::INT, $9::JSONB, $10::INT, $11::BOOLEAN, $12::INT, $13::TEXT)`,
            parseInt(id),
            code || null,
            name,
            type,
            valueType || 'NONE',
            numericVal,
            isEditable !== undefined ? isEditable : true,
            numericOrden,
            productIdsJson,
            parsedTargetTaxId,
            isAct,
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        if (code && gdsEquivalences !== undefined) {
            await syncGdsEquivalences(code, gdsEquivalences);
        }

        const tax = { ...body };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'MASTER_DATA', description: `Cargo/Impuesto ${tax.name} actualizado (SP).`, metadata: tax });
        });

        return NextResponse.json(tax)
    } catch (error: any) {
        console.error('Error updating tax:', error);
        return NextResponse.json({ message: 'Error al actualizar el cargo o impuesto: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const id = searchParams.get('id')
        if (!id) return NextResponse.json({ message: 'ID is required' }, { status: 400 })
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', parseInt(id))
                    .query(`DELETE FROM dbo.[ChargeAndTax] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Cargo eliminado exitosamente' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spImpuestoEliminar($1::INT, $2::INT, $3::TEXT)`,
            parseInt(id),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'MASTER_DATA', description: `Cargo/Impuesto con ID ${id} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Cargo eliminado exitosamente' })
    } catch (error: any) {
        console.error('Error deleting tax:', error);
        return NextResponse.json({ message: 'Error al eliminar el cargo: ' + error.message }, { status: 500 })
    }
}
