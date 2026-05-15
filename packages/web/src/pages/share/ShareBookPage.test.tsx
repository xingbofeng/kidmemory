import { describe, it, expect, vi, beforeEach, beforeAll, afterAll } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { ShareBookPage } from './ShareBookPage'
import { server } from '../../test/setup'
import axios from 'axios'

// Mock axios
vi.mock('axios')
const mockAxios = vi.mocked(axios)

describe('ShareBookPage', () => {
  beforeAll(() => {
    // Disable MSW for these tests since we're mocking axios directly
    server.close()
  })

  afterAll(() => {
    // Restart MSW for other tests
    server.listen({ onUnhandledRequest: 'error' })
  })

  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should show loading state initially', () => {
    // Mock pending axios request
    mockAxios.get.mockImplementation(() => new Promise(() => {}))

    render(<ShareBookPage shareToken="test-token" bookId="book_1" />)

    expect(screen.getByText('正在验证分享链接...')).toBeInTheDocument()
  })

  it('should show error for invalid share token', async () => {
    // Mock failed validation
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: false,
        error: '分享链接已过期'
      }
    })

    render(<ShareBookPage shareToken="invalid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接已过期')).toBeInTheDocument()
    })
  })

  it('should show error for mismatched book ID', async () => {
    // Mock validation with different book ID
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: true,
        shareToken: {
          id: 'share_123',
          childId: 'child_456',
          resourceType: 'specific_book',
          resourceId: 'book_2', // Different book ID
          accessType: 'read_only'
        }
      }
    })

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接与请求的作品集不匹配')).toBeInTheDocument()
    })
  })

  it('should show shared book for valid token', async () => {
    // Mock successful validation
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: true,
        shareToken: {
          id: 'share_123',
          childId: 'child_456',
          resourceType: 'specific_book',
          resourceId: 'book_1',
          accessType: 'read_only'
        }
      }
    })

    // Mock book data fetch
    mockAxios.get.mockResolvedValueOnce({
      data: {
        id: 'book_1',
        title: '阳光的一天',
        childId: 'child_456',
        createdAt: '2024-01-15T10:00:00Z',
        status: 'completed',
        description: '记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。',
        previewUrl: '/preview/book_1.jpg',
        pageCount: 12
      }
    })

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('阳光的一天')).toBeInTheDocument()
      expect(screen.getByText('已完成')).toBeInTheDocument()
      expect(screen.getByText('12 页')).toBeInTheDocument()
      expect(screen.getByText('记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。')).toBeInTheDocument()
    })
  })

  it('should show preview pages', async () => {
    // Mock successful validation
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: true,
        shareToken: {
          id: 'share_123',
          childId: 'child_456',
          resourceType: 'specific_book',
          resourceId: 'book_1',
          accessType: 'read_only'
        }
      }
    })

    // Mock book data fetch
    mockAxios.get.mockResolvedValueOnce({
      data: {
        id: 'book_1',
        title: '阳光的一天',
        childId: 'child_456',
        createdAt: '2024-01-15T10:00:00Z',
        status: 'completed',
        description: '记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。',
        previewUrl: '/preview/book_1.jpg',
        pageCount: 12
      }
    })

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('作品集预览')).toBeInTheDocument()
      expect(screen.getByText('点击下方按钮查看完整的 12 页作品集')).toBeInTheDocument()
      expect(screen.getByText('第 1 页')).toBeInTheDocument()
      expect(screen.getByText('第 2 页')).toBeInTheDocument()
      expect(screen.getByText('第 3 页')).toBeInTheDocument()
      expect(screen.getByText('第 4 页')).toBeInTheDocument()
      expect(screen.getByText('还有 8 页')).toBeInTheDocument()
    })
  })

  it('should handle network errors gracefully', async () => {
    // Mock network error
    mockAxios.get.mockRejectedValueOnce(new Error('Network error'))

    render(<ShareBookPage shareToken="test-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('Network error')).toBeInTheDocument()
    })
  })

  it('should show book tags', async () => {
    // Mock successful validation
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: true,
        shareToken: {
          id: 'share_123',
          childId: 'child_456',
          resourceType: 'specific_book',
          resourceId: 'book_1',
          accessType: 'read_only'
        }
      }
    })

    // Mock book data fetch
    mockAxios.get.mockResolvedValueOnce({
      data: {
        id: 'book_1',
        title: '阳光的一天',
        childId: 'child_456',
        createdAt: '2024-01-15T10:00:00Z',
        status: 'completed',
        description: '记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。',
        previewUrl: '/preview/book_1.jpg',
        pageCount: 12
      }
    })

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('儿童绘本')).toBeInTheDocument()
      expect(screen.getByText('成长记录')).toBeInTheDocument()
      expect(screen.getByText('家庭回忆')).toBeInTheDocument()
    })
  })
})