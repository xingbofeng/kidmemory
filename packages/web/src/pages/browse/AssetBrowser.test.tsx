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

describe('AssetBrowser', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockHttpClient.get.mockResolvedValue({
      assets: [
        {
          id: 'asset-1',
          name: '我的画作',
          type: 'drawing',
          thumbnailUrl: '/sample-assets/sun-garden.png',
          createdAt: '2024-01-15'
        },
        {
          id: 'asset-2',
          name: '生日照片',
          type: 'photo',
          thumbnailUrl: '/sample-assets/birthday-boy.png',
          createdAt: '2024-01-14'
        }
      ]
    })
  })

  it('displays assets in grid layout', async () => {
    // Mock API response
    mockHttpClient.get.mockResolvedValueOnce({
        assets: [
          {
            id: 'asset-1',
            name: '我的画作',
            type: 'drawing',
            thumbnailUrl: '/sample-assets/sun-garden.png',
            createdAt: '2024-01-15'
          },
          {
            id: 'asset-2',
            name: '生日照片',
            type: 'photo',
            thumbnailUrl: '/sample-assets/birthday-boy.png',
            createdAt: '2024-01-14'
          }
        ]
    })

    render(<AssetBrowser childId="child-123" />)

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.getByText('生日照片')).toBeInTheDocument()
    })

    expect(mockHttpClient.get).toHaveBeenCalledWith('/api/web-companion/children/child-123/assets')
  })

  it('filters assets by type', async () => {
    // Mock API response with multiple asset types
    mockHttpClient.get.mockResolvedValueOnce({
        assets: [
          {
            id: 'asset-1',
            name: '我的画作',
            type: 'drawing',
            thumbnailUrl: '/sample-assets/sun-garden.png',
            createdAt: '2024-01-15'
          },
          {
            id: 'asset-2',
            name: '生日照片',
            type: 'photo',
            thumbnailUrl: '/sample-assets/birthday-boy.png',
            createdAt: '2024-01-14'
          }
        ]
    })

    render(<AssetBrowser childId="child-123" />)

    // Wait for initial load
    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    // Click on drawing filter
    const drawingFilter = screen.getByRole('button', { name: /绘画/ })
    fireEvent.click(drawingFilter)

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      // Photo should be filtered out
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
    })
  })

  it('searches assets by keyword', async () => {
    // Mock API response
    mockHttpClient.get.mockResolvedValueOnce({
        assets: [
          {
            id: 'asset-1',
            name: '我的画作',
            type: 'drawing',
            thumbnailUrl: '/sample-assets/sun-garden.png',
            createdAt: '2024-01-15'
          },
          {
            id: 'asset-2',
            name: '生日照片',
            type: 'photo',
            thumbnailUrl: '/sample-assets/birthday-boy.png',
            createdAt: '2024-01-14'
          }
        ]
    })

    render(<AssetBrowser childId="child-123" />)

    // Wait for loading to complete first
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
    render(<AssetBrowser childId="child-123" />)

    // Wait for loading to complete first
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
    render(<AssetBrowser childId="child-123" />)

    await waitFor(() => {
      // Check for thumbnail images
      const thumbnails = screen.getAllByRole('img')
      expect(thumbnails.length).toBeGreaterThan(0)

      // Check for asset types - use getAllByText since there are multiple instances
      const drawingLabels = screen.getAllByText(/绘画/)
      expect(drawingLabels.length).toBeGreaterThan(0)

      const photoLabels = screen.getAllByText(/照片/)
      expect(photoLabels.length).toBeGreaterThan(0)
    })
  })

  it('handles loading and error states', async () => {
    mockHttpClient.get.mockRejectedValueOnce(new Error('加载失败'))

    render(<AssetBrowser childId="invalid-child" />)

    // Should show loading initially
    expect(screen.getByText(/加载中/)).toBeInTheDocument()

    // Should show error for invalid child
    await waitFor(() => {
      expect(screen.getByText(/加载失败/)).toBeInTheDocument()
    })
  })
})
