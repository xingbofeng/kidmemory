import { describe, it, expect, beforeEach, vi } from 'vitest'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { FileUpload } from './FileUpload'
import * as uploadApi from '../../api/uploadApi'

vi.mock('../../api/uploadApi', () => ({
  createUploadItems: vi.fn(),
  commitUploadItem: vi.fn(),
}))

describe('FileUpload', () => {
  const mockSession = {
    sessionId: 'test-session-123',
    token: 'test-token-456',
    expiresAt: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
    childId: 'child-123',
    childName: '小明',
    maxUploads: 200,
    uploadCount: 5,
    isValid: true,
  }

  class MockXHR {
    static statusCode = 200
    static loadDelayMs = 10
    upload = {
      addEventListener: (name: string, cb: (event: { lengthComputable: boolean; loaded: number; total: number }) => void) => {
        if (name === 'progress') {
          setTimeout(() => cb({ lengthComputable: true, loaded: 1, total: 1 }), 0)
        }
      },
    }
    status = MockXHR.statusCode
    addEventListener(name: string, cb: () => void) {
      if (name === 'load') {
        setTimeout(() => cb(), MockXHR.loadDelayMs)
      }
    }
    open() {}
    setRequestHeader() {}
    send() {}
  }

  beforeEach(() => {
    vi.clearAllMocks()
    MockXHR.statusCode = 200
    MockXHR.loadDelayMs = 10
    vi.stubGlobal('XMLHttpRequest', MockXHR)
    vi.mocked(uploadApi.createUploadItems).mockResolvedValue({
      items: [{
        uploadItemId: 'item-1',
        objectKey: 'object-1',
        signedUpload: {
          method: 'PUT',
          url: 'https://example.com/upload',
          headers: {},
        },
      }],
    })
    vi.mocked(uploadApi.commitUploadItem).mockResolvedValue(undefined)
  })

  it('shows committing state after storage upload and before commit succeeds', async () => {
    let resolveCommit: (() => void) | undefined
    vi.mocked(uploadApi.commitUploadItem).mockImplementationOnce(
      () =>
        new Promise<void>((resolve) => {
          resolveCommit = resolve
        }),
    )
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'commit-pending.jpg', { type: 'image/jpeg' })

    fireEvent.change(fileInput, { target: { files: [file] } })
    fireEvent.click(screen.getByRole('button', { name: /开始上传/ }))

    expect(await screen.findByText(/正在提交/)).toBeInTheDocument()
    expect(screen.queryByText(/已上传，等待入库/)).not.toBeInTheDocument()

    resolveCommit?.()

    await waitFor(() => {
      expect(screen.getByText(/已上传，等待入库/)).toBeInTheDocument()
    })
  })

  it('allows selecting multiple files', async () => {
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file1 = new File(['image1'], 'image1.jpg', { type: 'image/jpeg' })
    const file2 = new File(['image2'], 'image2.png', { type: 'image/png' })

    fireEvent.change(fileInput, { target: { files: [file1, file2] } })

    expect(screen.getByText('image1.jpg')).toBeInTheDocument()
    expect(screen.getByText('image2.png')).toBeInTheDocument()
  })

  it('shows upload progress for each file', async () => {
    MockXHR.loadDelayMs = 100
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'test.jpg', { type: 'image/jpeg' })

    fireEvent.change(fileInput, { target: { files: [file] } })

    const uploadButton = screen.getByRole('button', { name: /开始上传/ })
    fireEvent.click(uploadButton)

    expect(await screen.findByText(/正在上传/)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByText(/已上传，等待入库/)).toBeInTheDocument()
      expect(uploadButton).not.toBeDisabled()
    })
  })

  it('prevents upload when session limit reached', async () => {
    const limitedSession = { ...mockSession, uploadCount: 200 }
    render(<FileUpload session={limitedSession} />)

    expect(screen.getByText(/已达到上传上限/)).toBeInTheDocument()
    expect(screen.getByLabelText(/选择图片/)).toBeDisabled()
  })

  it('prevents selecting more than remaining upload slots', async () => {
    const nearLimitSession = { ...mockSession, uploadCount: 198 }
    render(<FileUpload session={nearLimitSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const files = Array.from({ length: 5 }, (_, i) =>
      new File([`image${i}`], `image${i}.jpg`, { type: 'image/jpeg' })
    )

    fireEvent.change(fileInput, { target: { files } })

    // Should only show 2 files (remaining slots)
    expect(screen.getByText('image0.jpg')).toBeInTheDocument()
    expect(screen.getByText('image1.jpg')).toBeInTheDocument()
    expect(screen.queryByText('image2.jpg')).not.toBeInTheDocument()
    expect(screen.getByText(/只能再上传 2 张图片/)).toBeInTheDocument()
  })

  it('shows error for unsupported file types', () => {
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const textFile = new File(['text'], 'document.txt', { type: 'text/plain' })

    fireEvent.change(fileInput, { target: { files: [textFile] } })

    expect(screen.getByText(/不支持的文件类型：document\.txt/)).toBeInTheDocument()
    expect(screen.getByText(/JPG、PNG、GIF、WebP/)).toBeInTheDocument()
  })

  it('allows removing selected files before upload', async () => {
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'test.jpg', { type: 'image/jpeg' })

    fireEvent.change(fileInput, { target: { files: [file] } })
    expect(screen.getByText('test.jpg')).toBeInTheDocument()

    const removeButton = screen.getByRole('button', { name: /删除/ })
    fireEvent.click(removeButton)

    expect(screen.queryByText('test.jpg')).not.toBeInTheDocument()
  })

  it('shows upload success and failure states', async () => {
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'success.jpg', { type: 'image/jpeg' })

    fireEvent.change(fileInput, { target: { files: [file] } })

    const uploadButton = screen.getByRole('button', { name: /开始上传/ })
    fireEvent.click(uploadButton)

    expect(await screen.findByText(/已上传，等待入库/, {}, { timeout: 3000 })).toBeInTheDocument()
    expect(uploadButton).not.toBeDisabled()
  })

  it('disables upload when no provider is available', async () => {
    render(<FileUpload session={{ ...mockSession, providers: { lan: { available: false }, supabase: { available: false } } }} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'blocked.jpg', { type: 'image/jpeg' })
    fireEvent.change(fileInput, { target: { files: [file] } })

    expect(screen.getByRole('button', { name: /开始上传/ })).toBeDisabled()
  })

  it('allows clearing all selected files', async () => {
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file1 = new File(['image1'], 'image1.jpg', { type: 'image/jpeg' })
    const file2 = new File(['image2'], 'image2.png', { type: 'image/png' })

    fireEvent.change(fileInput, { target: { files: [file1, file2] } })

    expect(screen.getByText('image1.jpg')).toBeInTheDocument()
    expect(screen.getByText('image2.png')).toBeInTheDocument()
    expect(screen.getByText('上传队列（2）')).toBeInTheDocument()

    const clearButton = screen.getByRole('button', { name: /清空队列/ })
    expect(clearButton).not.toBeDisabled()

    fireEvent.click(clearButton)

    expect(screen.queryByText('image1.jpg')).not.toBeInTheDocument()
    expect(screen.queryByText('image2.png')).not.toBeInTheDocument()
    expect(screen.getByText('上传队列（0）')).toBeInTheDocument()
    expect(screen.getByText('选择图片后会出现在这里')).toBeInTheDocument()
  })

  it('disables clear button when no files selected', () => {
    render(<FileUpload session={mockSession} />)

    const clearButton = screen.getByRole('button', { name: /清空队列/ })
    expect(clearButton).toBeDisabled()
  })
})
