type HealthResponse = {
  status: string;
  timestamp: string;
  uptime: number;
  version: string;
};

import { NextResponse } from 'next/server';

export async function GET(): Promise<NextResponse<HealthResponse>> {
  const response: HealthResponse = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime()), // seconds
    version: process.env.APP_VERSION ?? '1.0.0',
  };

  return NextResponse.json(response, { status: 200 });
}
