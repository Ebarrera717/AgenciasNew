import { NextRequest, NextResponse } from 'next/server'
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver'
import { executePostgresQuery } from '@/lib/postgres'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        if (isSQLServerMode()) {
            const { getSQLServerConnection } = await import('@/lib/sqlserver');
            const pool = await getSQLServerConnection();
            let historyRows: any[] = [];
            try {
                const res = await pool.request()
                    .input('id', id)
                    .query(`
                        SELECT sh.[id], sh.[quotationId], sh.[state], sh.[description], sh.[userId], 
                               COALESCE(u.[name], 'Sistema') AS [userName], sh.[createdAt], sh.[metadata]
                        FROM dbo.[QuotationStateHistory] sh
                        LEFT JOIN dbo.[User] u ON sh.[userId] = u.[id]
                        WHERE sh.[quotationId] = @id
                        ORDER BY sh.[createdAt] DESC, sh.[id] DESC
                    `);
                historyRows = res.recordset || [];
            } catch (err: any) {
                console.warn('Warning reading SQL Server QuotationStateHistory:', err.message);
            }

            if (historyRows.length === 0) {
                try {
                    const qRes = await pool.request()
                        .input('id', id)
                        .query(`
                            SELECT q.[id], q.[id] AS [quotationId], COALESCE(q.[state], 'NUEVO') AS [state],
                                   COALESCE(q.[stateDescription], 'Creación de cotización') AS [description],
                                   q.[userId], COALESCE(u.[name], 'Sistema') AS [userName],
                                   COALESCE(q.[stateUpdatedAt], q.[date], GETDATE()) AS [createdAt]
                            FROM dbo.[Quotation] q
                            LEFT JOIN dbo.[User] u ON q.[userId] = u.[id]
                            WHERE q.[id] = @id
                        `);
                    if (qRes.recordset && qRes.recordset.length > 0) {
                        historyRows = qRes.recordset;
                    }
                } catch (err: any) {
                    console.warn('Warning creating baseline SQL Server history:', err.message);
                }
            }

            await pool.close();
            return NextResponse.json(historyRows);
        } else {
            let historyRows: any[] = [];
            try {
                historyRows = await executePostgresQuery(
                    `SELECT * FROM public.fn_obtener_historial_estados($1::INT)`,
                    [id]
                );
            } catch (pgErr: any) {
                console.warn('Warning executing fn_obtener_historial_estados:', pgErr.message);
            }

            if (!historyRows || historyRows.length === 0) {
                try {
                    historyRows = await executePostgresQuery(
                        `SELECT q.id, q.id AS "quotationId", COALESCE(q.state, 'NUEVO') AS state,
                                COALESCE(q."stateDescription", 'Creación de cotización') AS description,
                                q."userId", COALESCE(u.name, 'Sistema') AS "userName",
                                COALESCE(q."stateUpdatedAt", q.date, NOW()) AS "createdAt"
                         FROM public."Quotation" q
                         LEFT JOIN public."User" u ON q."userId" = u.id
                         WHERE q.id = $1::INT`,
                        [id]
                    );
                } catch (err: any) {
                    console.warn('Warning creating baseline Postgres history:', err.message);
                }
            }

            return NextResponse.json(historyRows || []);
        }
    } catch (error: any) {
        console.error('Error fetching quotation state history:', error);
        return NextResponse.json({ message: 'Error interno', error: error.message }, { status: 500 });
    }
}

export async function PUT(request: NextRequest, context: { params: Promise<{ id: string }> }) {
    try {
        const { id: paramId } = await context.params
        const id = parseInt(paramId)
        if (isNaN(id)) return NextResponse.json({ message: 'ID inválido' }, { status: 400 })

        const body = await request.json()
        const { state, description } = body
        const userIdHeader = request.headers.get('X-User-Id')
        const actingUserId = userIdHeader ? parseInt(userIdHeader) : 1

        let message = '';
        if (isSQLServerMode()) {
            let pool;
            try {
                const { executeSQLServerProcedure } = await import('@/lib/sqlserver');
                const res = await executeSQLServerProcedure('spCotizacionActualizarEstadoManual', {
                    p_quotation_id: id,
                    p_state: state,
                    p_description: description || null,
                    p_acting_user_id: actingUserId
                });
                const row = Array.isArray(res) ? res[0] : {};
                message = row?.p_mensaje_resultado || 'Estado de cotización actualizado en SQL Server';
                if (message.startsWith('ERROR')) {
                    throw new Error(message);
                }
            } catch (sqlErr: any) {
                if (sqlErr.message?.startsWith('ERROR')) throw sqlErr;
                try {
                    pool = await getSQLServerConnection();
                    await pool.request()
                        .input('id', id)
                        .input('state', state)
                        .query(`UPDATE dbo.[Quotation] SET [state] = @state, [updatedAt] = GETDATE() WHERE [id] = @id`);
                    await pool.close();
                    message = 'Estado de cotización actualizado en SQL Server';
                } catch (fallbackErr: any) {
                    if (pool) await pool.close();
                    console.warn('Warning updating quotation state in SQL Server:', fallbackErr.message);
                    message = 'Estado actualizado';
                }
            }
        } else {
            let results: any[];
            try {
                results = await executePostgresQuery(
                    `CALL public.spCotizacionActualizarEstadoManual($1::INT, $2::TEXT, $3::TEXT, $4::INT, $5::TEXT)`,
                    [id, state, description || null, actingUserId, '']
                );
            } catch (pgErr: any) {
                if (pgErr.message?.includes('does not exist')) {
                    results = await executePostgresQuery(
                        `CALL public."spCotizacionActualizarEstadoManual"($1::INT, $2::TEXT, $3::TEXT, $4::INT, $5::TEXT)`,
                        [id, state, description || null, actingUserId, '']
                    );
                } else {
                    throw pgErr;
                }
            }
            message = results[0]?.p_mensaje_resultado || '';
            if (message.startsWith('ERROR')) {
                throw new Error(message);
            }
        }

        import('@/lib/logger').then(({ logSystemEvent }) => {
            logSystemEvent({
                userId: actingUserId,
                action: 'UPDATE_STATE',
                module: 'QUOTATION',
                description: `Se actualizó el estado de la cotización #${id} a ${state}. Descripción: ${description || ''}`,
                metadata: { id, state, description }
            });
        });

        return NextResponse.json({ message: message || 'Estado de cotización actualizado', quotation: { id } })
    } catch (error: any) {
        console.error('Error updating quotation state:', error)
        return NextResponse.json({ message: 'Error al cambiar estado: ' + (error.message || 'Error desconocido') }, { status: 500 })
    }
}
