import { vi } from 'vitest';

const mockAxiosInstance = {
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  delete: vi.fn(),
  patch: vi.fn(),
  interceptors: {
    request: {
      use: vi.fn(),
      eject: vi.fn(),
    },
    response: {
      use: vi.fn((onSuccess, onError) => {
        // Store interceptors for testing
        mockAxiosInstance._responseInterceptor = onSuccess;
        mockAxiosInstance._errorInterceptor = onError;
      }),
      eject: vi.fn(),
    },
  },
  _responseInterceptor: null as any,
  _errorInterceptor: null as any,
};

const mockAxios = {
  create: vi.fn(() => mockAxiosInstance),
  isAxiosError: vi.fn((error: any) => error && error.isAxiosError === true),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  delete: vi.fn(),
  patch: vi.fn(),
};

export default mockAxios;
