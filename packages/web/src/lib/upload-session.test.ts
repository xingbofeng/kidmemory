import { describe, it, expect, vi, beforeEach } from 'vitest'
import axios from 'axios'
import { fetchUploadSession, uploadSessionFile } from './upload-session'
import { UploadSession } from '../types/api'

// Mock axios
vi.mock('axios')
const mockAxios = vi.mocked(axios)

describe('upload-session', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('fetchUploadSession', () => {
    it('fetches session data successfully', async () => {
      const mockSession: UploadSession = {
        sessionId: 'test-session',
        token: 'test-token',
        childId: 'child-123',
        childName: '小明',
        expiresAt: '2024-12-31T23:59:59Z',
        uploadCount: 5,
        maxUploads: 50
      }

      mockAxios.get.mockResolvedValueOnce({
        data: mockSession
      })

      const result = await fetchUploadSession('test-session')

      expect(mockAxios.get).toHaveBeenCalledWith('/api/web-companion/sessions/test-session')
      expect(result).toEqual(mockSession)
    })

    it('throws error when session fetch fails', async () => {
      mockAxios.get.mockRejectedValueOnce(new Error('Session not found'))

      await expect(fetchUploadSession('invalid-session')).rejects.toThrow('Session not found')
    })
  })

  describe('uploadSessionFile', () => {
    const mockSession: UploadSession = {
      sessionId: 'test-session',
      token: 'test-token',
      childId: 'child-123',
      childName: '小明',
      expiresAt: '2024-12-31T23:59:59Z',
      uploadCount: 5,
      maxUploads: 50
    }

    const mockFile = new File(['test content'], 'test.jpg', { type: 'image/jpeg' })

    it('uploads file successfully', async () => {
      const mockResponse = {
        status: 'success',
        assetId: 'asset-123',
        message: 'Upload successful'
      }

      mockAxios.post.mockResolvedValueOnce({
        data: mockResponse
      })

      const result = await uploadSessionFile(mockSession, mockFile)

      expect(mockAxios.post).toHaveBeenCalledWith(
        '/api/web-companion/upload',
        expect.any(FormData),
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      )
      expect(result).toEqual(mockResponse)
    })

    it('throws error with custom message when upload fails', async () => {
      const errorResponse = {
        response: {
          data: {
            error: 'File too large'
          }
        }
      }

      mockAxios.isAxiosError.mockReturnValue(true)
      mockAxios.post.mockRejectedValueOnce(errorResponse)

      await expect(uploadSessionFile(mockSession, mockFile)).rejects.toThrow('File too large')
    })

    it('throws generic error when upload fails without specific message', async () => {
      mockAxios.isAxiosError.mockReturnValue(false)
      mockAxios.post.mockRejectedValueOnce(new Error('Network error'))

      await expect(uploadSessionFile(mockSession, mockFile)).rejects.toThrow('Upload failed')
    })

    it('creates FormData with correct fields', async () => {
      const mockResponse = { status: 'success' }
      mockAxios.post.mockResolvedValueOnce({ data: mockResponse })

      await uploadSessionFile(mockSession, mockFile)

      const formDataCall = mockAxios.post.mock.calls[0]
      const formData = formDataCall[1] as FormData

      expect(formData.get('sessionId')).toBe('test-session')
      expect(formData.get('token')).toBe('test-token')
      expect(formData.get('childId')).toBe('child-123')
      expect(formData.get('file')).toBe(mockFile)
    })
  })
})