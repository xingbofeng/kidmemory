import { describe, it, expect, vi, beforeEach } from 'vitest'
import { readFileSync } from 'node:fs'
import { render, screen, waitFor } from '@testing-library/react'
import { ShareBookPage } from './ShareBookPage'
import { getSharedBook, validateShareToken } from '../../api/shareApi'

vi.mock('../../api/shareApi', () => ({
  validateShareToken: vi.fn(),
  getSharedBook: vi.fn(),
}))

const mockValidateShareToken = vi.mocked(validateShareToken)
const mockGetSharedBook = vi.mocked(getSharedBook)

function mockValidToken(resourceType: 'specific_book' | 'child_assets' = 'specific_book', resourceId = 'book_1') {
  mockValidateShareToken.mockResolvedValueOnce({
    isValid: true,
    shareToken: {
      id: 'share_123',
      childId: 'child_456',
      resourceType,
      resourceId,
      accessType: 'read_only',
    },
  })
}

function mockBook() {
  mockGetSharedBook.mockResolvedValueOnce({
    id: 'book_1',
    title: '阳光的一天',
    childId: 'child_456',
    createdAt: '2024-01-15T10:00:00Z',
    status: 'completed',
    description: '记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。',
    previewUrl: '/preview/book_1.jpg',
    pageCount: 12,
  })
}

describe('ShareBookPage', () => {
  it('does not suppress hook dependency checks', () => {
    const source = readFileSync('src/pages/share/ShareBookPage.tsx', 'utf8')

    expect(source).not.toContain('react-hooks/exhaustive-deps')
  })

  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should show loading state initially', () => {
    mockValidateShareToken.mockImplementation(() => new Promise(() => {}))

    render(<ShareBookPage shareToken="test-token" bookId="book_1" />)

    expect(screen.getByText('正在验证分享链接...')).toBeInTheDocument()
  })

  it('should show error for invalid share token', async () => {
    mockValidateShareToken.mockResolvedValueOnce({
      isValid: false,
      error: '分享链接已过期',
    })

    render(<ShareBookPage shareToken="invalid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接已过期')).toBeInTheDocument()
    })
  })

  it('should show error for mismatched book ID', async () => {
    mockValidToken('specific_book', 'book_2')

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接与请求的作品集不匹配')).toBeInTheDocument()
    })
  })

  it('should show shared book for valid token', async () => {
    mockValidToken('specific_book', 'book_1')
    mockBook()

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('阳光的一天')).toBeInTheDocument()
      expect(screen.getByText('已完成')).toBeInTheDocument()
      expect(screen.getByText('12 页')).toBeInTheDocument()
      expect(screen.getByText('记录孩子在阳光下玩耍、探索和成长的美好时光。每一个笑容都是最珍贵的回忆。')).toBeInTheDocument()
    })
  })

  it('should show preview pages', async () => {
    mockValidToken('specific_book', 'book_1')
    mockBook()

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
    mockValidateShareToken.mockRejectedValueOnce(new Error('Network error'))

    render(<ShareBookPage shareToken="test-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('Network error')).toBeInTheDocument()
    })
  })

  it('should show book tags', async () => {
    mockValidToken('specific_book', 'book_1')
    mockBook()

    render(<ShareBookPage shareToken="valid-token" bookId="book_1" />)

    await waitFor(() => {
      expect(screen.getByText('儿童绘本')).toBeInTheDocument()
      expect(screen.getByText('成长记录')).toBeInTheDocument()
      expect(screen.getByText('家庭回忆')).toBeInTheDocument()
    })
  })
})
