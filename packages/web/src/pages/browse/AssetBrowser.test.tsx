import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { AssetBrowser } from './AssetBrowser'
import { httpClient } from '../../lib/http-client'

vi.mock('../../lib/http-client', () => ({
  ApiError: class ApiError extends Error {
    code: number

    constructor(code: number, message: string) {
      super(message)
      this.name = 'ApiError'
      this.code = code
    }
  },
  httpClient: {
    get: vi.fn(),
  },
}))

const mockHttpClient = vi.mocked(httpClient)
const renderAssetBrowser = () => render(<AssetBrowser sessionId="session-123" sessionToken="token-abc" />)

describe('AssetBrowser', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockHttpClient.get.mockResolvedValue([
      {
        id: 'asset-1',
        title: '我的画作',
        type: 'drawing',
        previewUrl: '/sample-assets/sun-garden.png',
        createdAt: '2024-01-15'
      },
      {
        id: 'asset-2',
        title: '生日照片',
        type: 'photo',
        previewUrl: '/sample-assets/birthday-boy.png',
        createdAt: '2024-01-14'
      }
    ])
  })

  it('displays assets in grid layout', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.getByText('生日照片')).toBeInTheDocument()
    })

    expect(mockHttpClient.get).toHaveBeenCalledWith('/api/web-companion/sessions/session-123/recent?token=token-abc&limit=20')
  })

  it('filters assets by type', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const drawingFilter = screen.getByRole('button', { name: /绘画/ })
    fireEvent.click(drawingFilter)

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
    })
  })

  it('searches assets by keyword', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const searchInput = screen.getByPlaceholderText(/搜索素材/)
    fireEvent.change(searchInput, { target: { value: '画作' } })

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
    })
  })

  it('shows empty state when no assets found', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const searchInput = screen.getByPlaceholderText(/搜索素材/)
    fireEvent.change(searchInput, { target: { value: '不存在的内容' } })

    await waitFor(() => {
      expect(screen.getByText(/没有找到相关素材/)).toBeInTheDocument()
    })
  })

  it('shows asset thumbnails and metadata', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      const thumbnails = screen.getAllByRole('img')
      expect(thumbnails.length).toBeGreaterThan(0)

      const drawingLabels = screen.getAllByText(/绘画/)
      expect(drawingLabels.length).toBeGreaterThan(0)

      const photoLabels = screen.getAllByText(/照片/)
      expect(photoLabels.length).toBeGreaterThan(0)
    })
  })

  it('handles loading and error states', async () => {
    mockHttpClient.get.mockRejectedValueOnce(new Error('加载失败'))

    renderAssetBrowser()

    expect(screen.getByText(/加载中/)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByText(/加载失败/)).toBeInTheDocument()
    })
  })
})
