import { readFileSync } from 'node:fs'
import { describe, it, expect, vi } from 'vitest'
import {
  startDirectUpload,
  validateAddFiles,
  createDirectUploadClient,
} from './direct-upload-client'
import type { DirectUploadConfig } from './direct-upload-types'

/**
 * Web Companion provider-neutral Direct Upload — client 单元测试。
 *
 * 关键约束（必须由测试守住）：
 *   - 真正调用的是注入的 signed URL helper；测试不发起任何网络请求。
 *   - object key 必须经 buildDirectUploadObjectKey 生成（含 sessionId/前缀清洗后的文件名）。
 *   - 单张失败不阻塞其它文件继续上传。
 *   - 超过 recommendedClientLimit 必须以结构化错误（含 code）拒绝，并且不请求签名上传目标。
 *   - 非图片 MIME 必须以 unsupported_mime 拒绝，并且不请求签名上传目标。
 *   - onProgress 必须为每个文件至少触发一次。
 */

function makeFile(name: string, type = 'image/jpeg', size = 16): File {
  return new File([new Uint8Array(size)], name, { type })
}

function makeSignedUploadDeps(options?: { failAt?: number }) {
  let uploadIndex = 0
  const signUpload = vi.fn(async (input: { objectKey: string; contentType: string }) => ({
    method: 'PUT' as const,
    url: `https://cos.ap-guangzhou.myqcloud.com/counter-1252496948/${input.objectKey}?X-Amz-Signature=test`,
    headers: { 'content-type': input.contentType },
  }))
  const uploadWithSignedUrl = vi.fn(async (
    file: File,
    signedUpload: { method?: string; url: string; headers?: Record<string, string> },
    onProgress: (progress: number) => void,
  ) => {
    uploadIndex += 1
    if (options?.failAt === uploadIndex) {
      throw new Error('simulated network failure')
    }
    expect(signedUpload.url).toContain('X-Amz-Signature=test')
    expect(signedUpload.headers?.['content-type']).toBe(file.type)
    onProgress(1)
  })
  return { signUpload, uploadWithSignedUrl }
}

const baseConfig: DirectUploadConfig = {
  sessionId: 'wcs_direct_abc',
  bucket: 'web-companion-uploads',
  sessionPath: 'web-companion-uploads/wcs_direct_abc',
  provider: 'cos',
  uploadMode: 'signed-url',
  publicUrl: 'https://example.com',
  recommendedClientLimit: 200,
  expiresAtHintSeconds: 3 * 60 * 60,
  childId: 'child-123',
}

describe('direct upload type boundaries', () => {
  it('does not use double unknown casts to satisfy local client types', () => {
    const source = readFileSync('src/lib/direct-upload-client.ts', 'utf8')
    const testSource = readFileSync('src/lib/direct-upload-client.test.ts', 'utf8')
    const doubleCast = ['as unknown', 'as'].join(' ')

    expect(source).not.toContain(doubleCast)
    expect(testSource).not.toContain(doubleCast)
  })

  it('does not keep the browser Supabase SDK direct-upload path', () => {
    const clientSource = readFileSync('src/lib/direct-upload-client.ts', 'utf8')
    const typeSource = readFileSync('src/lib/direct-upload-types.ts', 'utf8')

    expect(clientSource).not.toContain('@supabase/supabase-js')
    expect(typeSource).not.toContain("'supabase'")
    expect(typeSource).not.toContain("'supabase-js'")
  })
})

describe('validateAddFiles', () => {
  it('returns ok with the cleaned file list when within limit and all images', () => {
    const result = validateAddFiles({
      existingCount: 0,
      newFiles: [
        makeFile('a.jpg', 'image/jpeg'),
        makeFile('b.png', 'image/png'),
        makeFile('c.heic', 'image/heic'),
      ],
      recommendedClientLimit: 200,
    })
    expect(result.ok).toBe(true)
    if (result.ok) {
      expect(result.files).toHaveLength(3)
    }
  })

  it('rejects with limit_exceeded when existingCount + newFiles exceeds recommendedClientLimit', () => {
    const result = validateAddFiles({
      existingCount: 199,
      newFiles: [makeFile('a.jpg'), makeFile('b.jpg')],
      recommendedClientLimit: 200,
    })
    expect(result.ok).toBe(false)
    if (!result.ok && result.code === 'limit_exceeded') {
      expect(result.code).toBe('limit_exceeded')
      expect(result.limit).toBe(200)
      expect(result.message).toMatch(/200|上限|limit/i)
    } else {
      throw new Error('expected limit_exceeded result')
    }
  })

  it('rejects with unsupported_mime when any file is not an allowed image type', () => {
    const result = validateAddFiles({
      existingCount: 0,
      newFiles: [makeFile('x.pdf', 'application/pdf')],
      recommendedClientLimit: 200,
    })
    expect(result.ok).toBe(false)
    if (!result.ok) {
      expect(result.code).toBe('unsupported_mime')
    }

    const textResult = validateAddFiles({
      existingCount: 0,
      newFiles: [makeFile('x.txt', 'text/plain')],
      recommendedClientLimit: 200,
    })
    expect(textResult.ok).toBe(false)
    if (!textResult.ok) {
      expect(textResult.code).toBe('unsupported_mime')
    }
  })
})

describe('createDirectUploadClient', () => {
  it('uploadFile requests a signed PUT target and uploads the file through it', async () => {
    const deps = makeSignedUploadDeps()
    const client = createDirectUploadClient(baseConfig, deps)
    const file = makeFile('hello.jpg', 'image/jpeg')

    const result = await client.uploadFile(file, {})

    expect(result.ok).toBe(true)
    expect(deps.signUpload).toHaveBeenCalledTimes(1)
    const [signedInput] = deps.signUpload.mock.calls[0]
    expect(signedInput.objectKey.startsWith(`${baseConfig.sessionId}/`)).toBe(true)
    expect(signedInput.objectKey.endsWith('__hello.jpg')).toBe(true)
    expect(signedInput.contentType).toBe('image/jpeg')
    expect(deps.uploadWithSignedUrl).toHaveBeenCalledTimes(1)
    expect(deps.uploadWithSignedUrl.mock.calls[0][0]).toBe(file)
  })

  it('returns a structured failure when the signer is missing', async () => {
    const client = createDirectUploadClient(baseConfig)
    const file = makeFile('hello.jpg', 'image/jpeg')

    const result = await client.uploadFile(file, {})

    expect(result.ok).toBe(false)
    if (!result.ok) {
      expect(result.errorMessage).toMatch(/Missing signed upload target signer/)
    }
  })
})

describe('startDirectUpload', () => {
  it('uploads each file via a signed PUT target', async () => {
    const deps = makeSignedUploadDeps()
    const files = [
      makeFile('alpha.jpg', 'image/jpeg'),
      makeFile('beta.png', 'image/png'),
    ]

    const results = await startDirectUpload({
      files,
      config: baseConfig,
      deps,
    })

    expect(deps.signUpload).toHaveBeenCalledTimes(2)
    expect(deps.uploadWithSignedUrl).toHaveBeenCalledTimes(2)
    expect(results).toHaveLength(2)

    const firstSignedInput = deps.signUpload.mock.calls[0][0]
    expect(firstSignedInput.objectKey).toMatch(new RegExp(`^${baseConfig.sessionId}/.+__alpha\\.jpg$`))
    expect(firstSignedInput.contentType).toBe('image/jpeg')
    expect(deps.uploadWithSignedUrl.mock.calls[0][0]).toBe(files[0])

    const secondSignedInput = deps.signUpload.mock.calls[1][0]
    expect(secondSignedInput.objectKey).toMatch(new RegExp(`^${baseConfig.sessionId}/.+__beta\\.png$`))
    expect(secondSignedInput.contentType).toBe('image/png')
    expect(deps.uploadWithSignedUrl.mock.calls[1][0]).toBe(files[1])

    for (const r of results) {
      expect(r.ok).toBe(true)
      if (r.ok) {
        expect(r.objectKey).toBeTruthy()
      }
    }
  })

  it('continues uploading remaining files when a single file fails', async () => {
    const deps = makeSignedUploadDeps({ failAt: 1 })

    const files = [
      makeFile('first.jpg', 'image/jpeg'),
      makeFile('second.jpg', 'image/jpeg'),
    ]

    const results = await startDirectUpload({
      files,
      config: baseConfig,
      deps,
    })

    expect(deps.uploadWithSignedUrl).toHaveBeenCalledTimes(2)
    expect(results).toHaveLength(2)
    expect(results[0].ok).toBe(false)
    if (!results[0].ok) {
      expect(results[0].errorMessage).toMatch(/simulated network failure/)
    }
    expect(results[1].ok).toBe(true)
  })

  it('throws limit_exceeded when files exceed recommendedClientLimit and does NOT call upload', async () => {
    const deps = makeSignedUploadDeps()
    const files = [
      makeFile('a.jpg'),
      makeFile('b.jpg'),
      makeFile('c.jpg'),
    ]

    await expect(
      startDirectUpload({
        files,
        config: { ...baseConfig, recommendedClientLimit: 2 },
        deps,
      }),
    ).rejects.toMatchObject({ code: 'limit_exceeded', limit: 2 })

    expect(deps.signUpload).not.toHaveBeenCalled()
    expect(deps.uploadWithSignedUrl).not.toHaveBeenCalled()
  })

  it('throws unsupported_mime when a non-image file is passed and does NOT call upload', async () => {
    const deps = makeSignedUploadDeps()

    await expect(
      startDirectUpload({
        files: [makeFile('doc.pdf', 'application/pdf')],
        config: baseConfig,
        deps,
      }),
    ).rejects.toMatchObject({ code: 'unsupported_mime' })

    expect(deps.signUpload).not.toHaveBeenCalled()
    expect(deps.uploadWithSignedUrl).not.toHaveBeenCalled()

    await expect(
      startDirectUpload({
        files: [makeFile('note.txt', 'text/plain')],
        config: baseConfig,
        deps,
      }),
    ).rejects.toMatchObject({ code: 'unsupported_mime' })
  })

  it('invokes onProgress at least once for each file', async () => {
    const deps = makeSignedUploadDeps()
    const files = [makeFile('one.jpg'), makeFile('two.jpg')]
    const onProgress = vi.fn()

    await startDirectUpload({
      files,
      config: baseConfig,
      onProgress,
      deps,
    })

    expect(onProgress).toHaveBeenCalled()
    const filesCalledFor = new Set(
      onProgress.mock.calls.map((call) => (call[0] as File)),
    )
    expect(filesCalledFor.has(files[0])).toBe(true)
    expect(filesCalledFor.has(files[1])).toBe(true)
  })
})
