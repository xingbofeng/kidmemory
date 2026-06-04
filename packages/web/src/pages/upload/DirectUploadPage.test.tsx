import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { DirectUploadPage } from './DirectUploadPage'
import type { DirectUploadConfig } from '../../lib/direct-upload-types'
import { getDirectUploadConfig, pullbackDirectUpload } from '../../api/uploadApi'

vi.mock('../../api/uploadApi', () => ({
  getDirectUploadConfig: vi.fn(),
  pullbackDirectUpload: vi.fn(),
}))

/**
 * Web Companion Direct Upload Page — 组件契约测试。
 *
 * 对照 spec：
 *   - 「扫码进入上传页并展示会话信息」: 必须显示 child、`{bucket}/{sessionId}` 路径与「腾讯云 COS 直传验证版」横幅。
 *   - 「文件类型与单次张数体验约束」: 必须展示「体验约束」提示。
 *   - 缺失必需 query 参数（sessionId/childId/bucket/token）时显示错误横幅；不渲染上传 UI。
 *   - 默认计数 `0 / 200`，初始无进度行。
 *
 * 真实对象存储调用通过 `clientFactory` prop 注入 fake，避免任何网络。
 */

function makeSearchParams(overrides: Partial<Record<string, string>> = {}): URLSearchParams {
  const base: Record<string, string> = {
    sessionId: 'wcs_direct_abc',
    childId: 'child-123',
    bucket: 'web-companion-uploads',
    provider: 'cos',
    uploadMode: 'signed-url',
    token: 'session-token',
  }
  const merged: Record<string, string> = { ...base }
  for (const [k, v] of Object.entries(overrides)) {
    if (v !== undefined) merged[k] = v
  }
  return new URLSearchParams(merged)
}

function makeFakeClientFactory() {
  const upload = vi.fn(async (objectKey: string) => ({
    data: { path: objectKey },
    error: null,
  }))
  const factory = vi.fn((_config: DirectUploadConfig) => ({
    uploadFile: vi.fn(async (_file: File, _cb: { onProgress?: (p: number) => void }) => ({
      ok: true as const,
      objectKey: 'fake-object-key',
    })),
  }))
  return { factory, upload }
}

describe('DirectUploadPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(getDirectUploadConfig).mockResolvedValue({
      provider: 'cos',
      uploadMode: 'signed-url',
    })
    vi.mocked(pullbackDirectUpload).mockResolvedValue({ sessionId: 'wcs_direct_abc', results: [] })
  })

  it('renders childId, session path and risk banner using query params', async () => {
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )

    // child ID is shown
    expect(await screen.findByText(/child-123/)).toBeInTheDocument()
    // {bucket}/{sessionId} session path
    expect(screen.getByText(/web-companion-uploads\/wcs_direct_abc/)).toBeInTheDocument()
    // risk banner
    expect(screen.getByText(/腾讯云 COS 直传验证版/)).toBeInTheDocument()
    expect(screen.getByText(/自动通知电脑端入库/)).toBeInTheDocument()
    expect(getDirectUploadConfig).toHaveBeenCalledWith('wcs_direct_abc', 'session-token')
  })

  it('shows the default file count "0 / 200" before any selection', async () => {
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )
    expect(await screen.findByText(/0\s*\/\s*200/)).toBeInTheDocument()
  })

  it('shows an error banner when required query params are missing', () => {
    const { factory } = makeFakeClientFactory()
    const params = makeSearchParams()
    params.delete('sessionId')
    render(<DirectUploadPage searchParams={params} clientFactory={factory} />)

    expect(screen.getByText(/缺少必需参数|missing required/i)).toBeInTheDocument()
    // upload UI must not render
    expect(screen.queryByLabelText(/选择图片/)).not.toBeInTheDocument()
  })

  it('renders the "体验约束" hint near the file picker', async () => {
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )
    expect(await screen.findByText(/体验约束/)).toBeInTheDocument()
  })

  it('renders no upload progress rows initially', async () => {
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )
    expect(await screen.findByText(/0\s*\/\s*200/)).toBeInTheDocument()
    expect(screen.queryAllByTestId('direct-upload-row')).toHaveLength(0)
  })

  it('triggers sidecar pullback after each successful direct upload', async () => {
    vi.mocked(pullbackDirectUpload).mockResolvedValue({
      sessionId: 'wcs_direct_abc',
      results: [{ objectKey: 'fake-object-key', status: 'ready' }],
    })
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )

    const fileInput = await screen.findByLabelText(/选择图片/)
    fireEvent.change(fileInput, {
      target: {
        files: [new File(['image'], 'pullback.jpg', { type: 'image/jpeg' })],
      },
    })

    await waitFor(() => {
      expect(pullbackDirectUpload).toHaveBeenCalledWith('wcs_direct_abc', {
        token: 'session-token',
        objectKeys: ['fake-object-key'],
      })
      expect(screen.getByText(/已入库|Imported/)).toBeInTheDocument()
    })
  })

  it('does not mark an upload imported when pullback omits the uploaded object', async () => {
    vi.mocked(pullbackDirectUpload).mockResolvedValue({
      sessionId: 'wcs_direct_abc',
      results: [],
    })
    const { factory } = makeFakeClientFactory()
    render(
      <DirectUploadPage
        searchParams={makeSearchParams()}
        clientFactory={factory}
      />,
    )

    const fileInput = await screen.findByLabelText(/选择图片/)
    fireEvent.change(fileInput, {
      target: {
        files: [new File(['image'], 'missing-result.jpg', { type: 'image/jpeg' })],
      },
    })

    await waitFor(() => {
      expect(pullbackDirectUpload).toHaveBeenCalled()
      expect(screen.getByText(/入库失败|Import failed/i)).toBeInTheDocument()
    })
    expect(screen.queryByText(/已入库|Imported/)).not.toBeInTheDocument()
  })
})
