import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import axios from 'axios'
import { AssetBrowser } from './AssetBrowser'

// Mock axios
vi.mock('axios')
const mockAxios = vi.mocked(axios)

describe('AssetBrowser', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    mockAxios.get.mockResolvedValue({
      data: {
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
      }
    })
  })

  it('displays assets in grid layout', async () => {
    // Mock API response
    mockAxios.get.mockResolvedValueOnce({
      data: {
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
      }
    })

    render(<AssetBrowser childId="child-123" />)

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.getByText('生日照片')).toBeInTheDocument()
    })

    expect(mockAxios.get).toHaveBeenCalledWith('/api/web-companion/children/child-123/assets')
  })

  it('filters assets by type', async () => {
    const user = userEvent.setup()

    // Mock API response with multiple asset types
    mockAxios.get.mockResolvedValueOnce({
      data: {
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
      }
    })

    render(<AssetBrowser childId="child-123" />)

    // Wait for initial load
    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    // Click on drawing filter
    const drawingFilter = screen.getByRole('button', { name: /绘画/ })
    await user.click(drawingFilter)

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      // Photo should be filtered out
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
    })
  })

  it('searches assets by keyword', async () => {
    const user = userEvent.setup()

    // Mock API response
    mockAxios.get.mockResolvedValueOnce({
      data: {
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
      }
    })

    render(<AssetBrowser childId="child-123" />)

    // Wait for loading to complete first
    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const searchInput = screen.getByPlaceholderText(/搜索素材/)
    await user.type(searchInput, '画作')

    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
      expect(screen.queryByText('生日照片')).not.toBeInTheDocument()
    })
  })

  it('shows empty state when no assets found', async () => {
    const user = userEvent.setup()
    render(<AssetBrowser childId="child-123" />)

    // Wait for loading to complete first
    await waitFor(() => {
      expect(screen.getByText('我的画作')).toBeInTheDocument()
    })

    const searchInput = screen.getByPlaceholderText(/搜索素材/)
    await user.type(searchInput, '不存在的内容')

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
    mockAxios.get.mockRejectedValueOnce(new Error('加载失败'))

    render(<AssetBrowser childId="invalid-child" />)

    // Should show loading initially
    expect(screen.getByText(/加载中/)).toBeInTheDocument()

    // Should show error for invalid child
    await waitFor(() => {
      expect(screen.getByText(/加载失败/)).toBeInTheDocument()
    })
  })
})
