/**
 * HTTP Client Tests
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios from 'axios';
import { HttpClient, ApiError } from './http-client';
import { ApiCode } from '@kidmemory/protocol';

vi.mock('axios');

describe('HttpClient', () => {
  let mockAxiosInstance: ReturnType<typeof vi.fn> extends never ? never : {
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
  let responseInterceptor: ((input: unknown) => unknown) | undefined;
  let errorInterceptor: ((input: unknown) => unknown) | undefined;

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
          use: vi.fn((onSuccess, onError) => {
            responseInterceptor = onSuccess;
            errorInterceptor = onError;
          }),
        },
      },
    };

    // Mock axios.create to return our mock instance
    vi.mocked(axios.create).mockImplementation(() => mockAxiosInstance as never);
    vi.mocked(axios.isAxiosError).mockImplementation(() => false);
  });

  describe('API format handling', () => {
    it('should make GET request', async () => {
      const client = new HttpClient();
      const mockData = { id: 1, name: 'test' };

      mockAxiosInstance.get.mockResolvedValueOnce(mockData);

      const result = await client.get('/api/test');

      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/api/test', undefined);
      expect(result).toEqual(mockData);
    });

    it('should make POST request', async () => {
      const client = new HttpClient();
      const mockData = { success: true };
      const postData = { name: 'test' };

      mockAxiosInstance.post.mockResolvedValueOnce(mockData);

      const result = await client.post('/api/test', postData);

      expect(mockAxiosInstance.post).toHaveBeenCalledWith('/api/test', postData, undefined);
      expect(result).toEqual(mockData);
    });

    it('should unwrap successful API response', () => {
      // Create client to register interceptors
      new HttpClient();

      // Simulate the interceptor behavior
      const apiResponse = {
        data: {
          code: ApiCode.SUCCESS,
          msg: 'success',
          data: { id: 1, name: 'test' },
        },
      };

      // The interceptor would unwrap this
      const result = responseInterceptor!(apiResponse);

      expect(result).toEqual({ id: 1, name: 'test' });
    });

    it('should throw ApiError for non-zero code', () => {
      // Create client to register interceptors
      new HttpClient();

      const apiResponse = {
        data: {
          code: ApiCode.NOT_FOUND,
          msg: 'Resource not found',
          data: { path: '/api/test' },
        },
      };

      expect(() => responseInterceptor!(apiResponse)).toThrow(ApiError);
      expect(() => responseInterceptor!(apiResponse)).toThrow('Resource not found');
    });

    it('should handle API error response', () => {
      // Create client to register interceptors
      new HttpClient();

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

      expect(() => errorInterceptor!(error)).toThrow(ApiError);
      expect(() => errorInterceptor!(error)).toThrow('Invalid parameters');
    });

    it('should handle network error', () => {
      // Create client to register interceptors
      new HttpClient();

      const error = new Error('Network error');

      vi.mocked(axios.isAxiosError).mockReturnValue(false);

      expect(() => errorInterceptor!(error)).toThrow(ApiError);
      expect(() => errorInterceptor!(error)).toThrow('Network error');
    });

    it('should pass through non-API format responses', () => {
      // Create client to register interceptors
      new HttpClient();

      // File download or other non-API response
      const rawResponse = {
        data: new Blob(['file content']),
      };

      const result = responseInterceptor!(rawResponse);

      expect(result).toEqual(rawResponse.data);
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
        .mockResolvedValueOnce(mockData); // axios.get returns the value directly after interceptor

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
        .mockResolvedValueOnce(mockData);

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

      mockAxiosInstance.get.mockResolvedValueOnce(mockData);

      const result = await client.get('/api/test');

      expect(result).toEqual(mockData);
    });
  });
});
