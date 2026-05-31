/**
 * HTTP Client Tests
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios, { type AxiosInstance } from 'axios';
import { readFileSync } from 'node:fs';
import { HttpClient, ApiError } from './http-client';
import { ApiCode } from '@kidmemory/protocol';

vi.mock('axios');

type MockAxiosInstance = {
  get: ReturnType<typeof vi.fn>;
  post: ReturnType<typeof vi.fn>;
  put: ReturnType<typeof vi.fn>;
  delete: ReturnType<typeof vi.fn>;
  patch: ReturnType<typeof vi.fn>;
  interceptors: {
    response: {
      use: ReturnType<typeof vi.fn>;
    };
  };
};

describe('HttpClient', () => {
  let mockAxiosInstance: MockAxiosInstance;

  it('uses typed axios requests instead of double-casting promises', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');

    expect(source).not.toContain('as unknown as Promise');
  });

  it('does not double-cast through unknown at axios boundaries', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');

    expect(source).not.toContain('as unknown as');
  });

  it('exports the default client without a compatibility proxy shim', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');

    expect(source).not.toContain('new Proxy');
    expect(source).not.toContain('backward compatibility');
  });

  it('handles responses without a mutable placeholder variable', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');

    expect(source).not.toContain('let response');
  });

  it('retries with an iterative loop instead of recursive retry plumbing', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');

    expect(source).not.toContain('retriesLeft');
    expect(source).not.toContain('this.executeWithRetry(fn,');
  });

  it('does not carry comments that restate the next line', () => {
    const source = readFileSync('src/lib/http-client.ts', 'utf8');
    const comments = source
      .split('\n')
      .filter((line) => line.trim().startsWith('//') || line.trim().startsWith('*'))
      .join('\n');

    expect(comments).not.toMatch(/Check if|Return unwrapped|Return as-is|Fallback for|Network error|Wait before retry|Re-export for convenience/);
  });

  it('uses typed axios test doubles without never casts', () => {
    const source = readFileSync('src/lib/http-client.test.ts', 'utf8');
    const forbidden = ['as', 'never'].join(' ');

    expect(source).not.toContain(forbidden);
  });

  beforeEach(() => {
    // Create mock axios instance
    mockAxiosInstance = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn(),
      patch: vi.fn(),
      interceptors: {
        response: {
          use: vi.fn(),
        },
      },
    };

    // Mock axios.create to return our mock instance
    vi.mocked(axios.create).mockImplementation(() => mockAxiosInstance as AxiosInstance);
    vi.mocked(axios.isAxiosError).mockImplementation(() => false);
  });

  describe('API format handling', () => {
    it('should make GET request', async () => {
      const client = new HttpClient();
      const mockData = { id: 1, name: 'test' };

      mockAxiosInstance.get.mockResolvedValueOnce({ data: mockData });

      const result = await client.get('/api/test');

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/api/test', undefined);
      expect(result).toEqual(mockData);
    });

    it('should make POST request', async () => {
      const client = new HttpClient();
      const mockData = { success: true };
      const postData = { name: 'test' };

      mockAxiosInstance.post.mockResolvedValueOnce({ data: mockData });

      const result = await client.post('/api/test', postData);

      expect(mockAxiosInstance.post).toHaveBeenCalledWith('/api/test', postData, undefined);
      expect(result).toEqual(mockData);
    });

    it('should unwrap successful API response', async () => {
      const client = new HttpClient();
      mockAxiosInstance.get.mockResolvedValueOnce({
        data: {
          code: ApiCode.SUCCESS,
          msg: 'success',
          data: { id: 1, name: 'test' },
        },
      });

      const result = await client.get('/api/test');

      expect(result).toEqual({ id: 1, name: 'test' });
    });

    it('should throw ApiError for non-zero code', async () => {
      const client = new HttpClient();
      mockAxiosInstance.get.mockResolvedValueOnce({
        data: {
          code: ApiCode.NOT_FOUND,
          msg: 'Resource not found',
          data: { path: '/api/test' },
        },
      });

      const request = client.get('/api/test');
      await expect(request).rejects.toThrow(ApiError);
      await expect(request).rejects.toThrow('Resource not found');
    });

    it('should handle API error response', async () => {
      const client = new HttpClient();

      const error = {
        response: {
          data: {
            code: ApiCode.INVALID_PARAMS,
            msg: 'Invalid parameters',
            data: { issues: [] },
          },
        },
      };

      vi.mocked(axios.isAxiosError).mockReturnValue(true);
      mockAxiosInstance.get.mockRejectedValue(error);

      const request = client.get('/api/test');
      await expect(request).rejects.toThrow(ApiError);
      await expect(request).rejects.toThrow('Invalid parameters');
    });

    it('should handle network error', async () => {
      const client = new HttpClient();

      const error = new Error('Network error');

      vi.mocked(axios.isAxiosError).mockReturnValue(false);
      mockAxiosInstance.get.mockRejectedValue(error);

      const request = client.get('/api/test');
      await expect(request).rejects.toThrow(ApiError);
      await expect(request).rejects.toThrow('Network error');
    });

    it('should pass through non-API format responses', async () => {
      const client = new HttpClient();

      // File download or other non-API response
      const data = new Blob(['file content']);
      mockAxiosInstance.get.mockResolvedValueOnce({ data });

      const result = await client.get('/api/download');

      expect(result).toEqual(data);
    });
  });

  describe('Retry mechanism', () => {
    it('should retry on network error', async () => {
      const client = new HttpClient({ retries: 2, retryDelay: 10 });
      const mockData = { success: true };

      // First two calls fail, third succeeds
      mockAxiosInstance.get
        .mockRejectedValueOnce(new Error('Network error'))
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValueOnce({ data: mockData });

      const result = await client.get('/api/test');

      expect(mockAxiosInstance.get).toHaveBeenCalledTimes(3);
      expect(result).toEqual(mockData);
    });

    it('should retry on 5xx errors', async () => {
      const client = new HttpClient({ retries: 2, retryDelay: 10 });
      const mockData = { success: true };

      const serverError = {
        response: {
          status: 503,
          data: { error: 'Service unavailable' },
        },
      };

      vi.mocked(axios.isAxiosError).mockReturnValue(true);

      // First two calls fail with 503, third succeeds
      mockAxiosInstance.get
        .mockRejectedValueOnce(serverError)
        .mockRejectedValueOnce(serverError)
        .mockResolvedValueOnce({ data: mockData });

      const result = await client.get('/api/test');

      expect(mockAxiosInstance.get).toHaveBeenCalledTimes(3);
      expect(result).toEqual(mockData);
    });

    it('should not retry on 4xx errors', async () => {
      const client = new HttpClient({ retries: 2, retryDelay: 10 });

      const clientError = {
        response: {
          status: 404,
          data: {
            code: ApiCode.NOT_FOUND,
            msg: 'Not found',
            data: null,
          },
        },
      };

      vi.mocked(axios.isAxiosError).mockReturnValue(true);

      mockAxiosInstance.get.mockRejectedValueOnce(clientError);

      // The error interceptor will convert this to ApiError
      await expect(client.get('/api/test')).rejects.toThrow();
      expect(mockAxiosInstance.get).toHaveBeenCalledTimes(1);
    });

    it('should throw after max retries', async () => {
      const client = new HttpClient({ retries: 2, retryDelay: 10 });

      mockAxiosInstance.get.mockRejectedValue(new Error('Network error'));

      await expect(client.get('/api/test')).rejects.toThrow();
      expect(mockAxiosInstance.get).toHaveBeenCalledTimes(3); // initial + 2 retries
    });

    it('should work without retry config', async () => {
      const client = new HttpClient();
      const mockData = { success: true };

      mockAxiosInstance.get.mockResolvedValueOnce({ data: mockData });

      const result = await client.get('/api/test');

      expect(result).toEqual(mockData);
    });
  });
});
