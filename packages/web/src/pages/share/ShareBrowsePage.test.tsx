import { describe, it, expect, vi, beforeEach, beforeAll, afterAll } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { ShareBrowsePage } from './ShareBrowsePage'
import { server } from '../../test/setup'
import axios from 'axios'

// Mock axios
vi.mock('axios')
const mockAxios = vi.mocked(axios)

describe('ShareBrowsePage', () => {
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

    render(<ShareBrowsePage shareToken="test-token" />)

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

    render(<ShareBrowsePage shareToken="invalid-token" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接已过期')).toBeInTheDocument()
    })
  })

  it('should show shared assets for valid token', async () => {
    // Mock successful validation
    mockAxios.get.mockResolvedValueOnce({
      data: {
        isValid: true,
        shareToken: {
          id: 'share_123',
          childId: 'child_456',
          resourceType: 'child_assets',
          accessType: 'read_only'
        }
      }
    })

    // Mock assets data fetch
    mockAxios.get.mockResolvedValueOnce({
      data: [
        {
          id: 'asset_1',
          title: '阳光下的笑容',
          type: 'image',
          createdAt: '2024-01-15T10:00:00Z',
          previewUrl: '/preview/asset_1.jpg'
        },
        {
          id: 'asset_2',
          title: '春天的花朵',
          type: 'image',
          createdAt: '2024-01-16T10:00:00Z',
          previewUrl: '/preview/asset_2.jpg'
        },
        {
          id: 'asset_3',
          title: '家庭合影',
          type: 'image',
          createdAt: '2024-01-17T10:00:00Z',
          previewUrl: '/preview/asset_3.jpg'
        }
      ]
    })

    render(<ShareBrowsePage shareToken="valid-token" />)

    await waitFor(() => {
      expect(screen.getByText('分享的素材')).toBeInTheDocument()
      expect(screen.getByText('共 3 张照片')).toBeInTheDocument()
      expect(screen.getByText('阳光下的笑容')).toBeInTheDocument()
      expect(screen.getByText('春天的花朵')).toBeInTheDocument()
      expect(screen.getByText('家庭合影')).toBeInTheDocument()
    })
  })

  it('should handle network errors gracefully', async () => {
    // Mock network error
    mockAxios.get.mockRejectedValueOnce(new Error('Network error'))

    render(<ShareBrowsePage shareToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('Network error')).toBeInTheDocument()
    })
  })
})