import { NextResponse } from 'next/server';
import { checkSystemHealth } from '@/lib/health-check';

export async function GET() {
  try {
    const health = await checkSystemHealth(true);
    return NextResponse.json(health, { status: health.status === 'UNHEALTHY' ? 500 : 200 });
  } catch (error: any) {
    return NextResponse.json(
      { status: 'UNHEALTHY', message: error.message, checkedAt: new Date().toISOString() },
      { status: 500 }
    );
  }
}
