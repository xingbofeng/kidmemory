import { describe, it, expect, beforeEach, vi } from 'vitest'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { FileUpload } from './FileUpload'
import * as uploadSession from '../../lib/upload-session'

// Mock upload-session module
vi.mock('../../lib/upload-session', () => ({
  uploadSessionFile: vi.fn(),
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

  beforeEach(() => {
    // Reset mocks between tests
    vi.clearAllMocks()
    // Default mock implementation - successful upload
    vi.mocked(uploadSession.uploadSessionFile).mockResolvedValue({
      status: 'success',
      fileId: 'mock-file-id',
    })
  })

  it('allows selecting multiple files', async () => {
    const user = userEvent.setup()
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file1 = new File(['image1'], 'image1.jpg', { type: 'image/jpeg' })
    const file2 = new File(['image2'], 'image2.png', { type: 'image/png' })

    await user.upload(fileInput, [file1, file2])

    expect(screen.getByText('image1.jpg')).toBeInTheDocument()
    expect(screen.getByText('image2.png')).toBeInTheDocument()
  })

  it('shows upload progress for each file', async () => {
    const user = userEvent.setup()
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'test.jpg', { type: 'image/jpeg' })

    await user.upload(fileInput, file)

    const uploadButton = screen.getByRole('button', { name: /开始上传/ })
    await user.click(uploadButton)

    await waitFor(() => {
      expect(screen.getByText(/上传中/)).toBeInTheDocument()
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
    const user = userEvent.setup()
    render(<FileUpload session={nearLimitSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const files = Array.from({ length: 5 }, (_, i) =>
      new File([`image${i}`], `image${i}.jpg`, { type: 'image/jpeg' })
    )

    await user.upload(fileInput, files)

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
    const user = userEvent.setup()
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'test.jpg', { type: 'image/jpeg' })

    await user.upload(fileInput, file)
    expect(screen.getByText('test.jpg')).toBeInTheDocument()

    const removeButton = screen.getByRole('button', { name: /删除/ })
    await user.click(removeButton)

    expect(screen.queryByText('test.jpg')).not.toBeInTheDocument()
  })

  it('shows upload success and failure states', async () => {
    const user = userEvent.setup()
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file = new File(['image'], 'success.jpg', { type: 'image/jpeg' })

    await user.upload(fileInput, file)

    const uploadButton = screen.getByRole('button', { name: /开始上传/ })
    await user.click(uploadButton)

    await waitFor(() => {
      expect(screen.getByText(/上传成功/)).toBeInTheDocument()
    }, { timeout: 3000 })
  })

  it('allows clearing all selected files', async () => {
    const user = userEvent.setup()
    render(<FileUpload session={mockSession} />)

    const fileInput = screen.getByLabelText(/选择图片/)
    const file1 = new File(['image1'], 'image1.jpg', { type: 'image/jpeg' })
    const file2 = new File(['image2'], 'image2.png', { type: 'image/png' })

    await user.upload(fileInput, [file1, file2])

    expect(screen.getByText('image1.jpg')).toBeInTheDocument()
    expect(screen.getByText('image2.png')).toBeInTheDocument()
    expect(screen.getByText('上传队列（2）')).toBeInTheDocument()

    const clearButton = screen.getByRole('button', { name: /清空队列/ })
    expect(clearButton).not.toBeDisabled()

    await user.click(clearButton)

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
