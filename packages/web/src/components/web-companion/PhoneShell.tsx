import type { ReactNode } from 'react'

interface PhoneShellProps {
  children: ReactNode
  activeTab: string
}

export function PhoneShell({ children, activeTab }: PhoneShellProps) {
  return (
    <div className="phone-shell" data-view={activeTab}>
      <header className="phone-status" aria-label="手机状态栏">
        <span>9:41</span>
        <span className="status-cluster">▮▮▮ ))) ▭</span>
      </header>
      <main className="app-main">
        {children}
      </main>
    </div>
  )
}