import { beforeEach, vi } from 'vitest'

// Mock localStorage
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
}

// Mock IntersectionObserver
const intersectionObserverMock = vi.fn(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))

beforeEach(() => {
  // Reset mocks before each test
  vi.clearAllMocks()

  // Setup localStorage mock
  Object.defineProperty(window, 'localStorage', {
    value: localStorageMock,
    writable: true,
  })

  // Setup IntersectionObserver mock
  Object.defineProperty(window, 'IntersectionObserver', {
    value: intersectionObserverMock,
    writable: true,
  })

  // Setup default localStorage behavior
  localStorageMock.getItem.mockReturnValue('zh')
})