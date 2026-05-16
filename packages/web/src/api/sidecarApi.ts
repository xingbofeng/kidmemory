/**
 * Sidecar API Module
 * 
 * Handles all sidecar-related API calls
 * (Currently web app doesn't directly call sidecar APIs, but this module
 * is created for future use and consistency)
 */

import { httpClient } from '../lib/http-client';

/**
 * Health check
 */
export interface HealthCheckResponse {
  status: 'ok';
  timestamp: string;
}

export async function healthCheck(): Promise<HealthCheckResponse> {
  return httpClient.get<HealthCheckResponse>('/api/health');
}

// Additional sidecar API methods will be added here as needed
