import { vi } from 'vitest';

type ResponseHandler = (value: unknown) => unknown;
type ErrorHandler = (reason: unknown) => unknown;

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
      use: vi.fn((onSuccess: ResponseHandler, onError: ErrorHandler) => {
        // Store interceptors for testing
        mockAxiosInstance._responseInterceptor = onSuccess;
        mockAxiosInstance._errorInterceptor = onError;
      }),
      eject: vi.fn(),
    },
  },
  _responseInterceptor: null as ResponseHandler | null,
  _errorInterceptor: null as ErrorHandler | null,
};

const mockAxios = {
  create: vi.fn(() => mockAxiosInstance),
  isAxiosError: vi.fn((error: unknown) => {
    return typeof error === 'object' && error !== null && 'isAxiosError' in error;
  }),
  get: mockAxiosInstance.get,
  post: mockAxiosInstance.post,
  put: mockAxiosInstance.put,
  delete: mockAxiosInstance.delete,
  patch: mockAxiosInstance.patch,
};

export default mockAxios;
