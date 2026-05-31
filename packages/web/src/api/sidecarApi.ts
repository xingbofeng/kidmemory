import { httpClient } from '../lib/http-client';

export interface HealthCheckResult {
  status: 'ok';
  timestamp: string;
}

export async function healthCheck(): Promise<HealthCheckResult> {
  return httpClient.get<HealthCheckResult>('/api/health');
}
