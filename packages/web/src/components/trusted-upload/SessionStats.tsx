import type { SessionSummary } from '../../types/trustedUpload'

interface SessionStatsProps {
  session: SessionSummary
  usedCount: number
  remainingText: string
}

export function SessionStats({ session, usedCount, remainingText }: SessionStatsProps) {
  return (
    <div className="trusted-stats" aria-label="会话状态">
      <span>🖼 <strong>{usedCount}</strong> / {session.maxItems} 张</span>
      <span>◷ 会话剩余 <strong>{remainingText}</strong></span>
    </div>
  )
}