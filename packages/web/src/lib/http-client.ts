/**
 * HTTP Client with unified API response format
 * 
 * Provides a wrapper around axios that:
 * - Automatically unwraps { code, msg, data } responses
 * - Throws ApiError for non-zero codes
 * - Handles network errors
 */

import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { ApiCode, type ApiResponse } from '@kidmemory/protocol';

export interface HttpClientConfig extends AxiosRequestConfig {
  retries?: number;
  retryDelay?: number;
}

export class ApiError extends Error {
  constructor(
    public code: number,
    message: string,
    public data?: unknown
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export class HttpClient {
  private axios: AxiosInstance;
  private retries: number;
  private retryDelay: number;

  constructor(config?: HttpClientConfig) {
    const { retries = 0, retryDelay = 1000, ...axiosConfig } = config || {};
    
    this.retries = retries;
    this.retryDelay = retryDelay;
    this.axios = axios.create(axiosConfig);

    // Response interceptor to unwrap API format
    this.axios.interceptors.response.use(
      this.handleResponse.bind(this) as unknown as (value: AxiosResponse) => AxiosResponse,
      this.handleError.bind(this)
    );
  }

  /**
   * Handle successful response
   */
  private handleResponse(response: AxiosResponse): unknown {
    const data = response.data;

    // Check if response is in API format
    if (this.isApiFormat(data)) {
      // Check for error code
      if (data.code !== ApiCode.SUCCESS) {
        throw new ApiError(data.code, data.msg, data.data);
      }

      // Return unwrapped data
      return data.data;
    }

    // Return as-is for non-API responses (e.g., file downloads)
    return data;
  }

  /**
   * Handle error response
   */
  private handleError(error: unknown): Promise<never> {
    if (axios.isAxiosError(error) && error.response) {
      const data = error.response.data;

      // Check if error response is in API format
      if (this.isApiFormat(data)) {
        throw new ApiError(data.code, data.msg, data.data);
      }

      // Fallback for non-standard errors
      const message = data?.message || data?.error || 'Request failed';
      throw new ApiError(ApiCode.UNKNOWN_ERROR, message, data);
    }

    // Network error or other error
    throw new ApiError(
      ApiCode.UNKNOWN_ERROR,
      error instanceof Error ? error.message : 'Network error',
      error
    );
  }

  /**
   * Check if response is in API format
   */
  private isApiFormat(data: unknown): data is ApiResponse<unknown> {
    return Boolean(
      data &&
      typeof data === 'object' &&
      'code' in data &&
      'msg' in data &&
      'data' in data
    );
  }

  /**
   * Check if error is retryable
   */
  private isRetryableError(error: unknown): boolean {
    // Network errors are retryable
    if (!axios.isAxiosError(error) || !error.response) {
      return true;
    }

    // 5xx errors are retryable
    const status = error.response.status;
    return status >= 500 && status < 600;
  }

  /**
   * Execute request with retry logic
   */
  private async executeWithRetry<T>(
    fn: () => Promise<T>,
    retriesLeft: number = this.retries
  ): Promise<T> {
    try {
      return await fn();
    } catch (error) {
      if (retriesLeft > 0 && this.isRetryableError(error)) {
        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, this.retryDelay));
        return this.executeWithRetry(fn, retriesLeft - 1);
      }
      throw error;
    }
  }

  /**
   * GET request
   */
  async get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.executeWithRetry(() => this.axios.get<T>(url, config) as unknown as Promise<T>);
  }

  /**
   * POST request
   */
  async post<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.executeWithRetry(() => this.axios.post<T>(url, data, config) as unknown as Promise<T>);
  }

  /**
   * PUT request
   */
  async put<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.executeWithRetry(() => this.axios.put<T>(url, data, config) as unknown as Promise<T>);
  }

  /**
   * DELETE request
   */
  async delete<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.executeWithRetry(() => this.axios.delete<T>(url, config) as unknown as Promise<T>);
  }

  /**
   * PATCH request
   */
  async patch<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.executeWithRetry(() => this.axios.patch<T>(url, data, config) as unknown as Promise<T>);
  }
}

// Default client instance (lazy initialization to support testing)
let _httpClient: HttpClient | null = null;

export function getHttpClient(): HttpClient {
  if (!_httpClient) {
    _httpClient = new HttpClient();
  }
  return _httpClient;
}

// For backward compatibility
export const httpClient = new Proxy({} as HttpClient, {
  get(_target, prop) {
    return Reflect.get(getHttpClient(), prop);
  }
});

// Re-export for convenience
export { ApiCode, type ApiResponse };
