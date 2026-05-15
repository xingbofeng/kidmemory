import { describe, it, expect } from 'vitest'
import {
  buildDirectUploadObjectKey,
  cleanDirectUploadFilename,
} from './direct-upload-naming'

/**
 * Direct Upload — 文件名清洗与 object key 生成。
 *
 * 守住的安全/正确性约束（见 spec/web-companion-supabase-direct/spec.md「文件名清洗」Scenario）：
 *   - 移除控制字符（0x00-0x1f, 0x7f）。
 *   - 保留有效扩展名（小写化，剥离不安全字符）。
 *   - 不直接使用未经清洗的原始文件名。
 *   - object key = `{sessionId}/{cuid}-{cleanedName}`，cuid 使用 crypto.randomUUID()
 *     或同等不可猜测前缀，确保同输入名多次调用产生不同 object key。
 */

describe('cleanDirectUploadFilename', () => {
  it('保留可见 ASCII 字母数字与扩展名，剔除其他可见字符', () => {
    expect(cleanDirectUploadFilename('drawing.jpg')).toBe('drawing.jpg')
    // 括号被替换为 _ 后再剥离尾部的连续 _ → my_photo_2024.png
    expect(cleanDirectUploadFilename('My Photo (2024).PNG')).toBe('my_photo_2024.png')
  })

  it('剔除控制字符（0x00-0x1F, 0x7F）', () => {
    const dirty = 'foo\u0000bar\u001fbaz\u007f.JPG'
    expect(cleanDirectUploadFilename(dirty)).toBe('foobarbaz.jpg')
  })

  it('剔除路径分隔符与不可信路径片段', () => {
    expect(cleanDirectUploadFilename('../etc/passwd.png')).toBe('etcpasswd.png')
    expect(cleanDirectUploadFilename('a\\b/c.jpg')).toBe('abc.jpg')
  })

  it('保留扩展名小写并限制为已知图片扩展名集合', () => {
    expect(cleanDirectUploadFilename('shot.HEIC')).toBe('shot.heic')
    expect(cleanDirectUploadFilename('doc.exe')).toBe('doc.bin')
    expect(cleanDirectUploadFilename('.gitignore')).toBe('upload.bin')
  })

  it('完全空或全是控制字符时返回 fallback 占位符', () => {
    expect(cleanDirectUploadFilename('')).toBe('upload.bin')
    expect(cleanDirectUploadFilename('\u0000\u0000\u0000')).toBe('upload.bin')
  })

  it('限制基础名最大长度（避免极长文件名造成 storage path 问题）', () => {
    const longInput = `${'a'.repeat(500)}.jpg`
    const cleaned = cleanDirectUploadFilename(longInput)
    expect(cleaned.length).toBeLessThanOrEqual(128)
    expect(cleaned.endsWith('.jpg')).toBe(true)
  })
})

describe('buildDirectUploadObjectKey', () => {
  it('生成 `{sessionId}/{uuid}__{cleanedName}` 形式的 object key', () => {
    const key = buildDirectUploadObjectKey({
      sessionId: 'wcs_direct_abc',
      filename: 'drawing.jpg',
    })
    expect(key.startsWith('wcs_direct_abc/')).toBe(true)
    expect(key.endsWith('__drawing.jpg')).toBe(true)
    // {sessionId}/{uuid}__{cleanedName} → uuid 部分非空且看起来像 UUID（含连字符或 32 hex）
    const segment = key.slice('wcs_direct_abc/'.length)
    const sepIndex = segment.indexOf('__')
    const uuidPart = segment.slice(0, sepIndex)
    expect(uuidPart.length).toBeGreaterThan(8)
  })

  it('同输入文件名重复调用产生不同 object key（uuid 前缀保证不可猜测且唯一）', () => {
    const key1 = buildDirectUploadObjectKey({ sessionId: 's', filename: 'x.jpg' })
    const key2 = buildDirectUploadObjectKey({ sessionId: 's', filename: 'x.jpg' })
    const key3 = buildDirectUploadObjectKey({ sessionId: 's', filename: 'x.jpg' })
    expect(key1).not.toBe(key2)
    expect(key2).not.toBe(key3)
    expect(key1).not.toBe(key3)
  })

  it('对不可信文件名做清洗后再嵌入 object key', () => {
    const key = buildDirectUploadObjectKey({
      sessionId: 'wcs_direct_test',
      filename: '../../../etc/passwd.exe',
    })
    expect(key).not.toContain('..')
    expect(key).not.toContain('/etc/')
    // 由于扩展名 exe 不在白名单，应回退为 .bin
    expect(key.endsWith('.bin')).toBe(true)
    // 且必须以 sessionId/ 起始
    expect(key.startsWith('wcs_direct_test/')).toBe(true)
  })

  it('sessionId 不允许含 `/` 以避免对 prefix 的误解', () => {
    expect(() =>
      buildDirectUploadObjectKey({ sessionId: 'a/b', filename: 'x.jpg' }),
    ).toThrow(/sessionId/i)
  })
})
