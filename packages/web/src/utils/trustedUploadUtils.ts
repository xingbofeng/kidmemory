export function nextTaskId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `task-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`
}

export function formatRemaining(expiresAt: string): string {
  const remainingMs = new Date(expiresAt).getTime() - Date.now()
  if (!Number.isFinite(remainingMs) || remainingMs <= 0) return '已过期'
  const minutes = Math.floor(remainingMs / 60000)
  const hours = Math.floor(minutes / 60)
  const rest = minutes % 60
  if (hours <= 0) return `${rest} 分钟`
  return `${hours}小时${rest}分`
}

export function formatSize(size: number): string {
  if (size >= 1024 * 1024) return `${(size / 1024 / 1024).toFixed(1)} MB`
  return `${Math.max(1, Math.round(size / 1024))} KB`
}

export function statusLabel(status: 'pending' | 'uploading' | 'committing' | 'success' | 'failed'): string {
  switch (status) {
    case 'pending':
      return '等待上传'
    case 'uploading':
      return '上传中'
    case 'committing':
      return '等待电脑同步'
    case 'success':
      return '已入库'
    case 'failed':
      return '失败'
  }
}