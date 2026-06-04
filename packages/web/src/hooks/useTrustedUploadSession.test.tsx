import { act, renderHook, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { commitUploadItem, createUploadItems, getUploadSession, getUploadSessionDetail } from '../api/uploadApi'
import { uploadFileWithSignedUrl } from '../lib/signed-upload'
import { useTrustedUploadSession } from './useTrustedUploadSession'

vi.mock('../api/uploadApi', () => ({
  getUploadSession: vi.fn(),
  getUploadSessionDetail: vi.fn(),
  createUploadItems: vi.fn(),
  commitUploadItem: vi.fn(),
}))

vi.mock('../lib/signed-upload', () => ({
  uploadFileWithSignedUrl: vi.fn(),
}))

const session = {
  sessionId: 'session-1',
  status: 'active',
  child: { id: 'child-1', displayName: '小明' },
  expiresAt: new Date(Date.now() + 60_000).toISOString(),
  maxItems: 10,
  usedItems: 0,
  providers: {
    lan: { available: false },
    cos: { available: true },
  },
}

describe('useTrustedUploadSession', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(getUploadSession).mockResolvedValue(session)
    vi.mocked(createUploadItems).mockResolvedValue({
      items: [{
        clientFileId: 'task-1',
        uploadItemId: 'item-1',
        assetId: 'asset-1',
        objectKey: 'object-1',
        status: 'uploading',
        signedUpload: {
          method: 'PUT',
          url: 'https://example.com/upload',
          expiresAt: new Date(Date.now() + 60_000).toISOString(),
          headers: {},
        },
      }],
    })
    vi.mocked(uploadFileWithSignedUrl).mockResolvedValue(undefined)
    vi.mocked(commitUploadItem).mockResolvedValue({ uploadItemId: 'item-1', status: 'uploaded_remote' })
    vi.mocked(getUploadSessionDetail)
      .mockResolvedValueOnce({
        sessionId: 'session-1',
        items: [{
          uploadItemId: 'item-1',
          assetId: 'asset-1',
          filename: 'photo.jpg',
          status: 'uploaded_remote',
          provider: 'cos',
          objectKey: 'object-1',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        }],
      })
      .mockResolvedValueOnce({
        sessionId: 'session-1',
        items: [{
          uploadItemId: 'item-1',
          assetId: 'asset-1',
          filename: 'photo.jpg',
          status: 'ready',
          provider: 'cos',
          objectKey: 'object-1',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        }],
      })
  })

  it('keeps a trusted upload task importing until the sidecar reports READY', async () => {
    const { result } = renderHook(() => useTrustedUploadSession({ sessionId: 'session-1', token: 'token-1' }))
    await waitFor(() => expect(result.current.loading).toBe(false))

    await act(async () => {
      await result.current.handleFileSelect([
        new File(['image'], 'photo.jpg', { type: 'image/jpeg' }),
      ])
    })

    expect(getUploadSessionDetail).toHaveBeenCalledWith('session-1', 'token-1')
    await waitFor(() => {
      expect(result.current.tasks[0].status).toBe('success')
    })
  })
})
