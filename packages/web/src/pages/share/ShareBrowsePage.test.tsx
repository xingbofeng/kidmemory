import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { ShareBrowsePage } from './ShareBrowsePage'
import { getSharedAssets, validateShareToken } from '../../api/shareApi'

vi.mock('../../api/shareApi', () => ({
  validateShareToken: vi.fn(),
  getSharedAssets: vi.fn(),
}))

const mockValidateShareToken = vi.mocked(validateShareToken)
const mockGetSharedAssets = vi.mocked(getSharedAssets)

describe('ShareBrowsePage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should show loading state initially', () => {
    mockValidateShareToken.mockImplementation(() => new Promise(() => {}))

    render(<ShareBrowsePage shareToken="test-token" />)

    expect(screen.getByText('正在验证分享链接...')).toBeInTheDocument()
  })

  it('should show error for invalid share token', async () => {
    mockValidateShareToken.mockResolvedValueOnce({
      isValid: false,
      error: '分享链接已过期',
    })

    render(<ShareBrowsePage shareToken="invalid-token" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('分享链接已过期')).toBeInTheDocument()
    })
  })

  it('should show shared assets for valid token', async () => {
    mockValidateShareToken.mockResolvedValueOnce({
      isValid: true,
      shareToken: {
        id: 'share_123',
        childId: 'child_456',
        resourceType: 'child_assets',
        accessType: 'read_only',
      },
    })
    mockGetSharedAssets.mockResolvedValueOnce([
      {
        id: 'asset_1',
        title: '阳光下的笑容',
        type: 'image',
        createdAt: '2024-01-15T10:00:00Z',
        previewUrl: '/preview/asset_1.jpg',
      },
      {
        id: 'asset_2',
        title: '春天的花朵',
        type: 'image',
        createdAt: '2024-01-16T10:00:00Z',
        previewUrl: '/preview/asset_2.jpg',
      },
      {
        id: 'asset_3',
        title: '家庭合影',
        type: 'image',
        createdAt: '2024-01-17T10:00:00Z',
        previewUrl: '/preview/asset_3.jpg',
      },
    ])

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
    mockValidateShareToken.mockRejectedValueOnce(new Error('Network error'))

    render(<ShareBrowsePage shareToken="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('分享链接无效')).toBeInTheDocument()
      expect(screen.getByText('Network error')).toBeInTheDocument()
    })
  })
})
