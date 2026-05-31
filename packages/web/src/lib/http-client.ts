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
  }

  private handleResponse<T>(response: AxiosResponse): T {
    const data = response.data;

    if (this.isApiFormat(data)) {
      if (data.code !== ApiCode.SUCCESS) {
        throw new ApiError(data.code, data.msg, data.data);
      }

      return data.data as T;
    }

    return data as T;
  }

  private handleError(error: unknown): never {
    if (axios.isAxiosError(error) && error.response) {
      const data = error.response.data;

      if (this.isApiFormat(data)) {
        throw new ApiError(data.code, data.msg, data.data);
      }

      const message = data?.message || data?.error || 'Request failed';
      throw new ApiError(ApiCode.UNKNOWN_ERROR, message, data);
    }

    throw new ApiError(
      ApiCode.UNKNOWN_ERROR,
      error instanceof Error ? error.message : 'Network error',
      error
    );
  }

  private isApiFormat(data: unknown): data is ApiResponse<unknown> {
    return Boolean(
      data &&
      typeof data === 'object' &&
      'code' in data &&
      'msg' in data &&
      'data' in data
    );
  }

  private isRetryableError(error: unknown): boolean {
    if (!axios.isAxiosError(error) || !error.response) {
      return true;
    }

    const status = error.response.status;
    return status >= 500 && status < 600;
  }

  private async executeWithRetry<T>(fn: () => Promise<T>): Promise<T> {
    for (let attempt = 0; attempt <= this.retries; attempt += 1) {
      try {
        return await fn();
      } catch (error) {
        if (attempt >= this.retries || !this.isRetryableError(error)) {
          throw error;
        }

        await new Promise(resolve => setTimeout(resolve, this.retryDelay));
      }
    }

    throw new Error('Retry loop exhausted');
  }

  private async request<T>(fn: () => Promise<AxiosResponse<unknown>>): Promise<T> {
    try {
      const response = await this.executeWithRetry(fn);
      return this.handleResponse<T>(response);
    } catch (error) {
      this.handleError(error);
    }
  }

  async get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.request<T>(() => this.axios.get<unknown, AxiosResponse<unknown>>(url, config));
  }

  async post<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.request<T>(() => this.axios.post<unknown, AxiosResponse<unknown>>(url, data, config));
  }

  async put<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.request<T>(() => this.axios.put<unknown, AxiosResponse<unknown>>(url, data, config));
  }

  async delete<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.request<T>(() => this.axios.delete<unknown, AxiosResponse<unknown>>(url, config));
  }

  async patch<T = unknown>(
    url: string,
    data?: unknown,
    config?: AxiosRequestConfig
  ): Promise<T> {
    return this.request<T>(() => this.axios.patch<unknown, AxiosResponse<unknown>>(url, data, config));
  }
}

export const httpClient = new HttpClient();

export { ApiCode, type ApiResponse };
