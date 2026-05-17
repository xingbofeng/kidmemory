import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import { TrustedUploadPage } from './TrustedUploadPage'
import { useTrustedUploadSession } from '../../hooks/useTrustedUploadSession'
import type { FileTask, SessionSummary, UploadProvider } from '../../types/trustedUpload'

vi.mock('../../hooks/useTrustedUploadSession', () => ({
  useTrustedUploadSession: vi.fn(),
}))

const mockedUseTrustedUploadSession = vi.mocked(useTrustedUploadSession)

function createSessionSummary(overrides?: Partial<SessionSummary>): SessionSummary {
  return {
    sessionId: 'test-session',
    status: 'active',
    child: {
      id: 'child-123',
      displayName: '小明',
    },
    expiresAt: new Date(Date.now() + 3600000).toISOString(),
    maxItems: 50,
    usedItems: 5,
    providers: {
      lan: { available: true },
      supabase: { available: true },
    },
    ...overrides,
  }
}

function createHookState(overrides?: {
  session?: SessionSummary | null
  tasks?: FileTask[]
  loading?: boolean
  error?: string | null
  selectedProvider?: UploadProvider
  remainingText?: string
  usedCount?: number
}) {
  const session = overrides?.session ?? createSessionSummary()
  const tasks = overrides?.tasks ?? []
  const loading = overrides?.loading ?? false
  const error = overrides?.error ?? null
  const selectedProvider = overrides?.selectedProvider ?? 'supabase'
  const usedCount = overrides?.usedCount ?? session?.usedItems ?? 0

  mockedUseTrustedUploadSession.mockReturnValue({
    session,
    tasks,
    loading,
    error,
    selectedProvider,
    remainingText: overrides?.remainingText ?? '59 分钟',
    usedCount,
    setSelectedProvider: vi.fn(),
    handleFileSelect: vi.fn(),
    handleClearTasks: vi.fn(),
  })
}

describe('TrustedUploadPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('shows loading state initially', () => {
    createHookState({ session: null, loading: true })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('正在连接电脑端会话…')).toBeInTheDocument()
  })

  it('displays error when session fetch fails', () => {
    createHookState({ session: null, loading: false, error: 'Network error' })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('Network error')).toBeInTheDocument()
  })

  it('displays session information when loaded successfully', () => {
    createHookState()

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('选择并上传照片')).toBeInTheDocument()
    expect(screen.getByText('正在为 小明 导入素材')).toBeInTheDocument()
    const statsSection = screen.getByLabelText('会话状态')
    expect(statsSection).toHaveTextContent('5')
    expect(statsSection).toHaveTextContent('50')
    expect(statsSection).toHaveTextContent('张')
  })

  it('shows provider selection buttons', () => {
    createHookState()

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('📶 局域网直传')).toBeInTheDocument()
    expect(screen.getByText('☁ 公网直传')).toBeInTheDocument()
    expect(screen.getByText('优先使用，速度更快')).toBeInTheDocument()
    expect(screen.getByText('Supabase 兜底')).toBeInTheDocument()
  })

  it('shows file picker options', () => {
    createHookState()

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByLabelText('拍照上传')).toBeInTheDocument()
    expect(screen.getByLabelText('从相册选择')).toBeInTheDocument()
    expect(screen.getByText('📷 拍照')).toBeInTheDocument()
    expect(screen.getByText('🖼 从相册选择')).toBeInTheDocument()
  })

  it('shows empty upload queue initially', () => {
    createHookState({ tasks: [] })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('上传队列（0）')).toBeInTheDocument()
    expect(screen.getByText('还没有选择图片。请拍照或从相册选择，素材会先上传到可信会话，再由电脑端回拉入库。')).toBeInTheDocument()
  })

  it('shows session expiry time', () => {
    createHookState({ remainingText: '59 分钟' })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    const statsSection = screen.getByLabelText('会话状态')
    expect(statsSection).toHaveTextContent('会话剩余')
    expect(statsSection).toHaveTextContent('59 分钟')
  })

  it('disables LAN provider when not available', () => {
    createHookState({
      session: createSessionSummary({
        providers: {
          lan: { available: false },
          supabase: { available: true },
        },
      }),
    })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('当前网络不可用')).toBeInTheDocument()
    const lanButton = screen.getByText('📶 局域网直传')
    // eslint-disable-next-line testing-library/no-node-access
    expect(lanButton.parentElement).toHaveAttribute('disabled')
  })

  it('allows continuing upload via footer button', () => {
    createHookState()

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    const continueButton = screen.getByRole('button', { name: /继续上传/ })
    expect(continueButton).toBeInTheDocument()
    expect(continueButton).not.toBeDisabled()
  })

  it('shows clear queue button and handles clearing tasks', () => {
    createHookState({ tasks: [] })

    render(<TrustedUploadPage sessionId="test-session" token="test-token" />)

    expect(screen.getByText('上传队列（0）')).toBeInTheDocument()
    const clearButton = screen.getByRole('button', { name: /清空队列/ })
    expect(clearButton).toBeInTheDocument()
    expect(clearButton).toBeDisabled()
  })
})
