import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fetchUploadSession } from './upload-session'
import { UploadSession } from '../types/api'
import { httpClient } from './http-client'

vi.mock('./http-client', () => ({
  ApiError: class ApiError extends Error {
    code: number
    data?: unknown

    constructor(code: number, message: string, data?: unknown) {
      super(message)
      this.name = 'ApiError'
      this.code = code
      this.data = data
    }
  },
  httpClient: {
    get: vi.fn(),
    post: vi.fn(),
  },
}))

const mockHttpClient = vi.mocked(httpClient)

describe('upload-session', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('fetchUploadSession', () => {
    it('fetches session data successfully', async () => {
      const mockSession: UploadSession = {
        sessionId: 'test-session',
        token: 'test-token',
        status: 'active',
        childId: 'child-123',
        childName: '小明',
        expiresAt: '2024-12-31T23:59:59Z',
        maxItems: 50,
        usedItems: 5,
        uploadCount: 5,
        maxUploads: 50,
        isValid: true,
      }

      mockHttpClient.get.mockResolvedValueOnce(mockSession)

      const result = await fetchUploadSession('test-session', 'test-token')

      expect(mockHttpClient.get).toHaveBeenCalledWith('/api/web-companion/sessions/test-session?token=test-token')
      expect(result).toEqual({
        ...mockSession,
        maxItems: 50,
        usedItems: 5,
      })
    })

    it('throws error when session fetch fails', async () => {
      mockHttpClient.get.mockRejectedValueOnce(new Error('Session not found'))

      await expect(fetchUploadSession('invalid-session', 'test-token')).rejects.toThrow('Session not found')
    })
  })

})
