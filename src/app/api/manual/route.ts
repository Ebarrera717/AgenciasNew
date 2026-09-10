import { NextRequest, NextResponse } from 'next/server';
import { MANUAL_MODULES } from '@/data/manual/modules';
import prisma from '@/lib/prisma';
import { isSQLServerMode, getSQLServerConnection } from '@/lib/sqlserver';

export const dynamic = 'force-dynamic';

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const query = searchParams.get('q')?.toLowerCase().trim();
        const role = searchParams.get('role')?.toUpperCase().trim() || req.headers.get('x-user-role')?.toUpperCase().trim() || '';

        let activeMenuItems: any[] = [];
        let activeMasters: any[] = [];

        if (isSQLServerMode()) {
            let pool;
            try {
                pool = await getSQLServerConnection();
                const mRes = await pool.request().query('SELECT [code], [name], [action], [activo] FROM dbo.[Menu] WHERE [activo] = 1');
                const maRes = await pool.request().query('SELECT [code], [name], [inactivo] FROM dbo.[Master] WHERE [inactivo] = 0');
                await pool.close();
                activeMenuItems = mRes.recordset;
                activeMasters = maRes.recordset;
            } catch (sqle) {
                if (pool) await pool.close();
            }
        } else {
            try {
                activeMenuItems = await prisma.$queryRawUnsafe(`SELECT * FROM public.fnMenu()`);
            } catch (dbErr) {
                console.error('Error llamando fnMenu():', dbErr);
                activeMenuItems = await prisma.menu.findMany({ where: { activo: true } });
            }

            try {
                const masterList: any[] = await prisma.$queryRawUnsafe(`SELECT * FROM public."fnMasterList"()`);
                activeMasters = masterList.filter((m: any) => !m.inactivo);
            } catch (mErr) {
                console.error('Error llamando fnMasterList():', mErr);
            }
        }

        const isSuperAdmin = role.includes('SUPERADMIN');

        const isModuleActive = (moduleId: string): boolean => {
            if (moduleId === 'licensing') {
                return isSuperAdmin;
            }

            if (activeMenuItems.length === 0) return true;

            switch (moduleId) {
                case 'quotations':
                    return activeMenuItems.some(m => (m.code || '').toUpperCase().includes('COTIZACION') || (m.action || '').includes('quotations'));
                case 'invoices':
                    return activeMenuItems.some(m => (m.code || '').toUpperCase().includes('FACTURA') || (m.action || '').includes('invoices'));
                case 'executions':
                    return activeMenuItems.some(m => (m.code || '').toUpperCase().includes('EJECUCION') || (m.action || '').includes('executions'));
                case 'reports':
                    return activeMenuItems.some(m => (m.code || '').toUpperCase().includes('REPORTE') || (m.action || '').includes('reports'));
                case 'config':
                    return activeMenuItems.some(m => (m.code || '').toUpperCase().includes('MAESTRO') || (m.code || '').toUpperCase().includes('SETTING') || (m.action || '').includes('settings'));
                default:
                    return true;
            }
        };

        let availableModules = MANUAL_MODULES
            .filter(module => isModuleActive(module.id))
            .map(module => {
                if (module.id === 'config' && activeMasters.length > 0) {
                    const activeProcedures = module.procedures.filter(proc => {
                        if (!proc.masterCode) return true;
                        return activeMasters.some(m => (m.code || '').toLowerCase() === proc.masterCode?.toLowerCase());
                    });
                    return { ...module, procedures: activeProcedures };
                }
                return module;
            });

        if (query) {
            availableModules = availableModules.map(module => {
                const matchedProcedures = module.procedures.filter(proc => {
                    const inName = proc.name.toLowerCase().includes(query);
                    const inCode = proc.code?.toLowerCase().includes(query);
                    const inSummary = proc.summary.toLowerCase().includes(query);
                    const inConcept = proc.concept.toLowerCase().includes(query);
                    const inFields = proc.fields?.some(f => f.name.toLowerCase().includes(query) || f.description.toLowerCase().includes(query));
                    const inSteps = proc.steps.some(s =>
                        s.title.toLowerCase().includes(query) ||
                        s.description.toLowerCase().includes(query) ||
                        (s.codeSnippet && s.codeSnippet.toLowerCase().includes(query))
                    );
                    return inName || inCode || inSummary || inConcept || inFields || inSteps;
                });

                const inModuleTitle = module.title.toLowerCase().includes(query);
                const inModuleDesc = module.description.toLowerCase().includes(query);

                if (inModuleTitle || inModuleDesc || matchedProcedures.length > 0) {
                    return {
                        ...module,
                        procedures: matchedProcedures.length > 0 ? matchedProcedures : module.procedures
                    };
                }
                return null;
            }).filter(Boolean) as typeof MANUAL_MODULES;
        }

        return NextResponse.json({
            isSuperAdmin,
            totalModules: availableModules.length,
            modules: availableModules
        });
    } catch (error: any) {
        console.error('Error serving manual data:', error);
        return NextResponse.json({ message: 'Error consultando manual operativo' }, { status: 500 });
    }
}
