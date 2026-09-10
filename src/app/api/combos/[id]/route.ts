import { NextRequest, NextResponse } from 'next/server'
import prisma from '@/lib/prisma'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'

export async function PUT(req: NextRequest, context: any) {
    try {
        const body = await req.json()
        const { code, name, cupos, currencyId, products } = body
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const urlId = req.nextUrl.pathname.split('/').pop();
        let fallbackId = urlId;
        
        try {
            const resolvedParams = await context.params;
            if (resolvedParams?.id) fallbackId = resolvedParams.id;
        } catch(e) {}

        const comboId = body.id ? parseInt(body.id) : parseInt(fallbackId || '');
        
        if (isNaN(comboId)) {
            return NextResponse.json({ message: `ID de combo no válido (Body: ${body.id}, URL: ${urlId})` }, { status: 400 });
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const isAct = body.isActive !== undefined ? (body.isActive ? 1 : 0) : (body.inactive ? 0 : 1);
                await pool.request()
                    .input('id', comboId)
                    .input('code', code || '')
                    .input('name', name || '')
                    .input('cupos', parseInt(cupos?.toString() || '0'))
                    .input('currencyId', currencyId ? parseInt(currencyId) : null)
                    .input('isActive', isAct)
                    .query(`
                        UPDATE dbo.[Combo]
                        SET [code] = @code, [name] = @name, [cupos] = @cupos, [currencyId] = @currencyId, [isActive] = @isActive
                        WHERE [id] = @id
                    `);
                await pool.close();
                const combo = { id: comboId, name };
                return NextResponse.json({ message: 'Combo actualizado', combo });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spComboActualizar($1::INT, $2::TEXT, $3::TEXT, $4::INT, $5::INT, $6::JSONB, $7::INT, $8::TEXT)`,
           comboId,
            code,
            name,
            parseInt(cupos?.toString() || '0'),
            currencyId || null,
            JSON.stringify((products || []).map((p: any) => ({
                ...p,
                cost: p.cost || 0,
                checkInDate: p.checkInDate || null,
                checkOutDate: p.checkOutDate || null,
                providerId: p.providerId || null,
                prestadoraId: p.prestadoraId || null,
                paxAdults: p.paxAdults || null,
                paxChildren: p.paxChildren || null
            }))),
            actingUserId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        if (body.isActive !== undefined || body.inactive !== undefined) {
            const isAct = body.isActive !== undefined ? Boolean(body.isActive) : !body.inactive;
            await prisma.$executeRawUnsafe(`UPDATE public."Combo" SET "isActive" = $1 WHERE id = $2`, isAct, comboId);
        }

        const combo = { id: comboId, name };

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'UPDATE', module: 'COMBO', description: `Combo ${combo.name} actualizado (SP).`, metadata: combo });
        });

        return NextResponse.json({ message: 'Combo actualizado', combo })
    } catch (error: any) {
        console.error('Error updating combo:', error);
        return NextResponse.json({ message: 'Error updating combo: ' + error.message }, { status: 500 })
    }
}

export async function DELETE(req: NextRequest, context: any) {
    try {
        const userIdHeader = req.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        const urlId = req.nextUrl.pathname.split('/').pop();
        let fallbackId = urlId;
        
        try {
            const resolvedParams = await context.params;
            if (resolvedParams?.id) fallbackId = resolvedParams.id;
        } catch(e) {}

        const comboId = parseInt(fallbackId || '');

        if (isNaN(comboId)) {
            return NextResponse.json({ message: `ID de combo no válido (URL: ${urlId})` }, { status: 400 });
        }

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                await pool.request()
                    .input('id', comboId)
                    .query(`DELETE FROM dbo.[Combo] WHERE [id] = @id`);
                await pool.close();
                return NextResponse.json({ message: 'Combo eliminado' });
            } catch (err: any) {
                if (pool) await pool.close();
                throw err;
            }
        }

        const results: any[] = await prisma.$queryRawUnsafe(
            `CALL public.spComboEliminar($1::INT, $2::TEXT)`,
            comboId,
            '' // p_mensaje_resultado
        );

        const message = results[0]?.p_mensaje_resultado || '';
        if (message.startsWith('ERROR')) {
            throw new Error(message);
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({ userId: actingUserId, action: 'DELETE', module: 'COMBO', description: `Combo con ID ${comboId} eliminado (SP).` });
        });

        return NextResponse.json({ message: 'Combo eliminado' })
    } catch (error: any) {
        console.error('Error deleting combo:', error);
        return NextResponse.json({ message: 'Error deleting combo: ' + error.message }, { status: 500 })
    }
}
