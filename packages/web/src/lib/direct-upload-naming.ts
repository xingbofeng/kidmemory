/**
 * Web Companion Supabase Direct Upload filename cleaning and object key generation.
 *
 * 安全约束：
 *   - 浏览器侧不能信任原始文件名作为完整路径或对象 key 的一部分。
 *   - 必须剔除控制字符、路径分隔符和不在白名单内的扩展名。
 *   - object key 必须包含不可猜测前缀（uuid），同输入名多次调用产生不同 key。
 */

const MAX_BASE_NAME_LENGTH = 128

/**
 * 已知图片扩展名白名单（小写）。其它扩展名一律标记为 `.bin`，
 * 触发 sidecar 端的二次类型识别与可能的拒绝。
 */
const ALLOWED_IMAGE_EXTENSIONS = new Set([
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
  'gif',
])

const FALLBACK_FILENAME = 'upload.bin'

/**
 * 清洗用户提供的文件名。结果只包含 ASCII 字母数字、下划线、连字符与点。
 *
 *   - 移除 0x00-0x1F 与 0x7F 控制字符。
 *   - 不接受 `/` 或 `\` 路径分隔符（直接剔除）。
 *   - 抽取扩展名并限制为图片白名单；不在白名单的回退为 `.bin`，无扩展名为 `.bin`。
 *   - 基础名超过 {@link MAX_BASE_NAME_LENGTH} 字符时截断。
 *   - 全空或仅控制字符的输入返回 {@link FALLBACK_FILENAME}。
 */
export function cleanDirectUploadFilename(filename: string): string {
  if (typeof filename !== 'string') return FALLBACK_FILENAME

  // 1. 剔除控制字符与路径分隔符
  let stripped = ''
  for (const char of filename) {
    const code = char.charCodeAt(0)
    if (code <= 0x1F || code === 0x7F || char === '/' || char === '\\') continue
    stripped += char
  }

  if (stripped.length === 0) return FALLBACK_FILENAME

  // 1b. 拒绝原始 dotfile（例如 `.gitignore`）：原始第一个非空字符就是 `.` 且不来自 path traversal。
  //     path traversal `../foo.png` 在 step 1 被去掉 `/` 后变成 `..foo.png`，仍以 `..` 开头但来自 `..` 序列；
  //     这里只在第一个字符是 `.` 且第二个字符不是 `.` 时拒绝，识别真正的 dotfile。
  if (stripped[0] === '.' && stripped[1] !== '.') {
    return FALLBACK_FILENAME
  }

  // 1c. 剥离开头的连续 `.`（例如 `../`-traversal 在去掉 `/` 后剩 `..xxx`）
  stripped = stripped.replace(/^\.+/, '')

  if (stripped.length === 0) return FALLBACK_FILENAME

  // 2. 抽取扩展名（最后一个点之后的部分）。
  //    前导点（如 `.gitignore`）的 lastDot===0 视为无效扩展名，触发 fallback。
  const lastDot = stripped.lastIndexOf('.')
  const rawBase = lastDot > 0 ? stripped.slice(0, lastDot) : stripped
  const rawExt = lastDot > 0 ? stripped.slice(lastDot + 1) : ''

  // 3. 基础名只保留 [a-zA-Z0-9_-]，其它（含点）替换为 _，再剥离首尾下划线
  const base = rawBase
    .replace(/[^a-zA-Z0-9_-]+/g, '_')
    .replace(/^_+/, '')
    .replace(/_+$/, '')
    .toLowerCase()

  // 4. 扩展名白名单化
  const ext = rawExt.replace(/[^a-zA-Z0-9]+/g, '').toLowerCase()
  // 前导点（lastDot===0）即 base 为空：此时强制走 fallback 而不是 .gitignore.bin
  const safeExt = lastDot > 0 && ALLOWED_IMAGE_EXTENSIONS.has(ext) ? ext : 'bin'

  if (base.length === 0) return FALLBACK_FILENAME

  // 5. 长度限制
  const truncatedBase = base.slice(0, MAX_BASE_NAME_LENGTH - safeExt.length - 1)

  return `${truncatedBase}.${safeExt}`
}

export interface BuildDirectUploadObjectKeyInput {
  sessionId: string
  filename: string
}

/**
 * 构造 Supabase Storage 内的 object key：`{sessionId}/{uuid}-{cleanedName}`。
 *
 * sessionId 由 sidecar 分配；调用方不允许传入含 `/` 的 sessionId（避免污染前缀）。
 */
export function buildDirectUploadObjectKey({
  sessionId,
  filename,
}: BuildDirectUploadObjectKeyInput): string {
  if (typeof sessionId !== 'string' || sessionId.length === 0) {
    throw new Error('buildDirectUploadObjectKey: sessionId required')
  }
  if (sessionId.includes('/') || sessionId.includes('\\')) {
    throw new Error('buildDirectUploadObjectKey: sessionId must not contain path separators')
  }

  const cleanedName = cleanDirectUploadFilename(filename)
  const uniquePrefix = generateUuid()
  return `${sessionId}/${uniquePrefix}__${cleanedName}`
}

function generateUuid(): string {
  // 优先使用浏览器 crypto.randomUUID（Vite/jsdom 都支持）。
  // jsdom 在某些版本上可能没有 crypto.randomUUID；这里给出回退避免测试环境差异。
  const cryptoRef = globalThis.crypto
  if (cryptoRef && typeof cryptoRef.randomUUID === 'function') {
    return cryptoRef.randomUUID()
  }
  // 兼容回退：基于 getRandomValues 拼出 16 字节 hex
  if (cryptoRef && typeof cryptoRef.getRandomValues === 'function') {
    const buffer = new Uint8Array(16)
    cryptoRef.getRandomValues(buffer)
    return Array.from(buffer, (b) => b.toString(16).padStart(2, '0')).join('')
  }
  // 最后兜底：低质量随机（仅用于不支持 crypto 的环境，不应进入生产）
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`
}
