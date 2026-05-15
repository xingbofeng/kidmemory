import { describe, it, expect, vi, beforeEach, beforeAll, afterAll } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { TrustedUploadPage } from './TrustedUploadPage'
import { server } from '../../test/setup'
import axios from 'axios'

// Mock axios
vi.mock('axios')
const mockAxios = vi.mocked(axios)

describe('TrustedUploadPage', () => {
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

  it('shows loading state initially', () => {
    // Mock pending axios request
    mockAxios.get.mockImplementation(() => new Promise(() => {}))

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('正在连接电脑端会话…')).toBeInTheDocument()
  })

  it('displays error when session fetch fails', async () => {
    // Mock failed session fetch
    mockAxios.get.mockRejectedValueOnce(new Error('Network error'))

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('Network error')).toBeInTheDocument()
    })
  })

  it('displays session information when loaded successfully', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(), // 1 hour from now
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    // Mock successful session fetch
    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('选择并上传照片')).toBeInTheDocument()
      expect(screen.getByText('正在为 小明 导入素材')).toBeInTheDocument()
      // Check for the stats section that contains the count
      const statsSection = screen.getByLabelText('会话状态')
      expect(statsSection).toBeInTheDocument()
      expect(statsSection).toHaveTextContent('5')
      expect(statsSection).toHaveTextContent('50')
      expect(statsSection).toHaveTextContent('张')
    })
  })

  it('shows provider selection buttons', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('📶 局域网直传')).toBeInTheDocument()
      expect(screen.getByText('☁ 公网直传')).toBeInTheDocument()
      expect(screen.getByText('优先使用，速度更快')).toBeInTheDocument()
      expect(screen.getByText('Supabase 兜底')).toBeInTheDocument()
    })
  })

  it('shows file picker options', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByLabelText('拍照上传')).toBeInTheDocument()
      expect(screen.getByLabelText('从相册选择')).toBeInTheDocument()
      expect(screen.getByText('📷 拍照')).toBeInTheDocument()
      expect(screen.getByText('🖼 从相册选择')).toBeInTheDocument()
    })
  })

  it('shows empty upload queue initially', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('上传队列（0）')).toBeInTheDocument()
      expect(screen.getByText('还没有选择图片。请拍照或从相册选择，素材会先上传到可信会话，再由电脑端回拉入库。')).toBeInTheDocument()
    })
  })

  it('shows session expiry time', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(), // 1 hour from now
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      const statsSection = screen.getByLabelText('会话状态')
      expect(statsSection).toHaveTextContent('会话剩余')
      expect(statsSection).toHaveTextContent('59 分钟')
    })
  })

  it('disables LAN provider when not available', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: false },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('当前网络不可用')).toBeInTheDocument()
      const lanButton = screen.getByText('📶 局域网直传')
      // eslint-disable-next-line testing-library/no-node-access
      expect(lanButton.parentElement).toHaveAttribute('disabled')
    })
  })

  it('allows continuing upload via footer button', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('☁ 继续上传')).toBeInTheDocument()
    })

    // The continue upload button should be present and clickable
    const continueButton = screen.getByRole('button', { name: /继续上传/ })
    expect(continueButton).toBeInTheDocument()
    expect(continueButton).not.toBeDisabled()
  })

  it('shows clear queue button and handles clearing tasks', async () => {
    const mockSession = {
      sessionId: 'test-session',
      status: 'active',
      child: {
        id: 'child-123',
        displayName: '小明'
      },
      expiresAt: new Date(Date.now() + 3600000).toISOString(),
      maxItems: 50,
      usedItems: 5,
      providers: {
        lan: { available: true },
        supabase: { available: true }
      }
    }

    mockAxios.get.mockResolvedValueOnce({
      data: mockSession
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    await waitFor(() => {
      expect(screen.getByText('上传队列（0）')).toBeInTheDocument()
      const clearButton = screen.getByRole('button', { name: /清空队列/ })
      expect(clearButton).toBeInTheDocument()
      expect(clearButton).toBeDisabled() // Should be disabled when no tasks
    })
  })
})