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
        tags: ['阳光'],
        description: '幼儿园手工课作品',
        previewUrl: '/sample-assets/sun-garden.png',
        createdAt: '2024-01-15'
      },
      {
        id: 'asset-2',
        title: '生日照片',
        type: 'photo',
        previewUrl: '/sample-assets/birthday-boy.png',
        createdAt: '2024-01-14'
      },
      {
        id: 'asset-3',
        title: '纸杯兔子',
        type: 'craft',
        previewUrl: '/sample-assets/family.png',
        createdAt: '2024-01-16'
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

  it('searches asset description and tags without showing placeholder assets', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    fireEvent.change(screen.getByPlaceholderText(/搜索素材/), { target: { value: '手工课' } })

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
      expect(screen.queryByText('彩虹房子')).not.toBeInTheDocument()
    })

    fireEvent.change(screen.getByPlaceholderText(/搜索素材/), { target: { value: '阳光' } })

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.queryByText('彩虹房子')).not.toBeInTheDocument()
    })
  })

  it('filters handmade assets and sorts recent uploads', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('纸杯兔子')).toBeInTheDocument()
    })

    fireEvent.click(screen.getByRole('button', { name: /手工/ }))

    await waitFor(() => {
      expect(screen.getByText('纸杯兔子')).toBeInTheDocument()
      expect(screen.queryByText('我的画作')).not.toBeInTheDocument()
    })

    fireEvent.click(screen.getByRole('button', { name: /最近上传/ }))

    const cards = screen.getAllByTestId('asset-card')
    expect(cards[0]).toHaveTextContent('纸杯兔子')
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

  it('renders real thumbnails in the recent strip', async () => {
    renderAssetBrowser()

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const images = screen.getAllByRole('img', { name: '我的画作' })
    expect(images.length).toBeGreaterThanOrEqual(2)
    expect(images[1]).toHaveAttribute('src', '/sample-assets/sun-garden.png')
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
