import { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { TabType } from './AppNavigation'

interface PhoneShellProps {
  activeTab: TabType
  children: ReactNode
}

export function PhoneShell({ activeTab, children }: PhoneShellProps) {
  const { t } = useTranslation()

  return (
    <div className="phone-shell" data-view={activeTab}>
      <header className="phone-status" aria-label={t('trustedUpload.statusBar')}>
        <span>9:41</span>
        <span className="status-cluster">▮▮▮ ))) ▭</span>
      </header>
      <main className="app-main">{children}</main>
    </div>
  )
}
