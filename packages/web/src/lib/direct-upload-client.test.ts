import { readFileSync } from 'node:fs'
import { describe, it, expect, vi } from 'vitest'
import {
  startDirectUpload,
  validateAddFiles,
  createDirectUploadClient,
  type DirectUploadCreateClient,
  type DirectUploadStorageBucket,
  type DirectUploadSupabaseClient,
} from './direct-upload-client'
import type { DirectUploadConfig } from './direct-upload-types'

/**
 * Web Companion Supabase Direct Upload — client 单元测试。
 *
 * 对照 spec/web-companion-supabase-direct/spec.md「拍照或选择图片直传 Supabase Storage」、
 * 「文件类型与单次张数体验约束」与「文件名清洗」三个 Scenario。
 *
 * 关键约束（必须由测试守住）：
 *   - 真正调用的是注入的 fake Supabase client；测试不发起任何网络请求。
 *   - object key 必须经 buildDirectUploadObjectKey 生成（含 sessionId/前缀清洗后的文件名）。
 *   - 单张失败不阻塞其它文件继续上传。
 *   - 超过 recommendedClientLimit 必须以结构化错误（含 code）拒绝，并且不调用 storage.from(...).upload。
 *   - 非图片 MIME 必须以 unsupported_mime 拒绝，并且不调用 storage.from(...).upload。
 *   - onProgress 必须为每个文件至少触发一次。
 */

function makeFile(name: string, type = 'image/jpeg', size = 16): File {
  return new File([new Uint8Array(size)], name, { type })
}

interface FakeSupabase {
  client: DirectUploadSupabaseClient
  createClient: ReturnType<typeof vi.fn<DirectUploadCreateClient>>
  from: ReturnType<typeof vi.fn>
  upload: ReturnType<typeof vi.fn<DirectUploadStorageBucket['upload']>>
}

function makeFakeSupabase(
  uploadImpl?: (
    objectKey: string,
    file: File,
    options: { contentType: string; upsert?: boolean },
  ) => Promise<{ data: { path: string } | null; error: { message: string } | null }>,
): FakeSupabase {
  const defaultImpl = async (objectKey: string) => ({
    data: { path: objectKey },
    error: null,
  })
  const upload = vi.fn<DirectUploadStorageBucket['upload']>(uploadImpl ?? defaultImpl)
  const from = vi.fn((() => ({ upload })) as DirectUploadSupabaseClient['storage']['from'])
  const client = { storage: { from } }
  const createClient = vi.fn<DirectUploadCreateClient>(() => client)
  return { client, createClient, from, upload }
}

const baseConfig: DirectUploadConfig = {
  sessionId: 'wcs_direct_abc',
  bucket: 'web-companion-uploads',
  sessionPath: 'web-companion-uploads/wcs_direct_abc',
  supabaseUrl: 'https://example.supabase.co',
  anonKey: 'anon-key',
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
  it('uploadFile delegates to storage.from(bucket).upload(objectKey, file, { contentType })', async () => {
    const { createClient, from, upload } = makeFakeSupabase()
    const client = createDirectUploadClient(baseConfig, {
      createClient,
    })
    const file = makeFile('hello.jpg', 'image/jpeg')
    const result = await client.uploadFile(file, {})
    expect(result.ok).toBe(true)
    expect(from).toHaveBeenCalledWith(baseConfig.bucket)
    expect(upload).toHaveBeenCalledTimes(1)
    const [objectKey, uploadedFile, options] = upload.mock.calls[0] as [
      string,
      File,
      { contentType: string; upsert?: boolean },
    ]
    expect(objectKey.startsWith(`${baseConfig.sessionId}/`)).toBe(true)
    expect(objectKey.endsWith('__hello.jpg')).toBe(true)
    expect(uploadedFile).toBe(file)
    expect(options.contentType).toBe('image/jpeg')
    expect(options.upsert).toBe(false)
  })

  it('uses provider-neutral signed URL upload when the sidecar exposes a signer', async () => {
    const createClient = vi.fn<DirectUploadCreateClient>(() => {
      throw new Error('Supabase SDK should not be used for signed-url direct upload')
    })
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
      expect(file.name).toBe('hello.jpg')
      expect(signedUpload.url).toContain('X-Amz-Signature=test')
      onProgress(1)
    })
    const client = createDirectUploadClient(
      { ...baseConfig, provider: 'cos', uploadMode: 'signed-url', anonKey: '', supabaseUrl: '' },
      { createClient, signUpload, uploadWithSignedUrl },
    )
    const file = makeFile('hello.jpg', 'image/jpeg')

    const result = await client.uploadFile(file, {})

    expect(result.ok).toBe(true)
    expect(createClient).not.toHaveBeenCalled()
    expect(signUpload).toHaveBeenCalledTimes(1)
    expect(signUpload.mock.calls[0][0]).toMatchObject({ contentType: 'image/jpeg' })
    expect(uploadWithSignedUrl).toHaveBeenCalledTimes(1)
  })
})

describe('startDirectUpload', () => {
  it('uploads each file via storage.from(bucket).upload(objectKey, file, { contentType, upsert:false })', async () => {
    const { createClient, from, upload } = makeFakeSupabase()
    const files = [
      makeFile('alpha.jpg', 'image/jpeg'),
      makeFile('beta.png', 'image/png'),
    ]

    const results = await startDirectUpload({
      files,
      config: baseConfig,
      deps: { createClient },
    })

    expect(from).toHaveBeenCalledWith(baseConfig.bucket)
    expect(upload).toHaveBeenCalledTimes(2)
    expect(results).toHaveLength(2)

    const firstCall = upload.mock.calls[0] as [
      string,
      File,
      { contentType: string; upsert?: boolean },
    ]
    expect(firstCall[0]).toMatch(new RegExp(`^${baseConfig.sessionId}/.+__alpha\\.jpg$`))
    expect(firstCall[1]).toBe(files[0])
    expect(firstCall[2]).toMatchObject({ contentType: 'image/jpeg', upsert: false })

    const secondCall = upload.mock.calls[1] as [
      string,
      File,
      { contentType: string; upsert?: boolean },
    ]
    expect(secondCall[0]).toMatch(new RegExp(`^${baseConfig.sessionId}/.+__beta\\.png$`))
    expect(secondCall[1]).toBe(files[1])
    expect(secondCall[2]).toMatchObject({ contentType: 'image/png', upsert: false })

    for (const r of results) {
      expect(r.ok).toBe(true)
      if (r.ok) {
        expect(r.objectKey).toBeTruthy()
      }
    }
  })

  it('continues uploading remaining files when a single file fails', async () => {
    let callIndex = 0
    const { createClient, upload } = makeFakeSupabase(async (objectKey) => {
      const isFirst = callIndex === 0
      callIndex += 1
      if (isFirst) {
        return { data: null, error: { message: 'simulated network failure' } }
      }
      return { data: { path: objectKey }, error: null }
    })

    const files = [
      makeFile('first.jpg', 'image/jpeg'),
      makeFile('second.jpg', 'image/jpeg'),
    ]

    const results = await startDirectUpload({
      files,
      config: baseConfig,
      deps: { createClient },
    })

    expect(upload).toHaveBeenCalledTimes(2)
    expect(results).toHaveLength(2)
    expect(results[0].ok).toBe(false)
    if (!results[0].ok) {
      expect(results[0].errorMessage).toMatch(/simulated network failure/)
    }
    expect(results[1].ok).toBe(true)
  })

  it('throws limit_exceeded when files exceed recommendedClientLimit and does NOT call upload', async () => {
    const { createClient, upload } = makeFakeSupabase()
    const files = [
      makeFile('a.jpg'),
      makeFile('b.jpg'),
      makeFile('c.jpg'),
    ]

    await expect(
      startDirectUpload({
        files,
        config: { ...baseConfig, recommendedClientLimit: 2 },
        deps: { createClient },
      }),
    ).rejects.toMatchObject({ code: 'limit_exceeded', limit: 2 })

    expect(upload).not.toHaveBeenCalled()
  })

  it('throws unsupported_mime when a non-image file is passed and does NOT call upload', async () => {
    const { createClient, upload } = makeFakeSupabase()

    await expect(
      startDirectUpload({
        files: [makeFile('doc.pdf', 'application/pdf')],
        config: baseConfig,
        deps: { createClient },
      }),
    ).rejects.toMatchObject({ code: 'unsupported_mime' })

    expect(upload).not.toHaveBeenCalled()

    await expect(
      startDirectUpload({
        files: [makeFile('note.txt', 'text/plain')],
        config: baseConfig,
        deps: { createClient },
      }),
    ).rejects.toMatchObject({ code: 'unsupported_mime' })
  })

  it('invokes onProgress at least once for each file', async () => {
    const { createClient } = makeFakeSupabase()
    const files = [makeFile('one.jpg'), makeFile('two.jpg')]
    const onProgress = vi.fn()

    await startDirectUpload({
      files,
      config: baseConfig,
      onProgress,
      deps: { createClient },
    })

    expect(onProgress).toHaveBeenCalled()
    const filesCalledFor = new Set(
      onProgress.mock.calls.map((call) => (call[0] as File)),
    )
    expect(filesCalledFor.has(files[0])).toBe(true)
    expect(filesCalledFor.has(files[1])).toBe(true)
  })
})
