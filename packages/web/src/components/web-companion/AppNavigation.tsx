import { useTranslation } from 'react-i18next'
import { Icon } from '../ui/Icon'

type TabType = 'connect' | 'upload' | 'browse' | 'books'

interface AppNavigationProps {
  activeTab: TabType
  onTabChange: (tab: TabType) => void
}

export function AppNavigation({ activeTab, onTabChange }: AppNavigationProps) {
  const { t } = useTranslation()

  return (
    <nav className="app-nav" aria-label={t('webCompanion.navAria')}>
      <button className={activeTab === 'connect' ? 'active' : ''} onClick={() => onTabChange('connect')}>
        <Icon name="link" />
        {t('webCompanion.navConnect')}
      </button>
      <button className={activeTab === 'upload' ? 'active' : ''} onClick={() => onTabChange('upload')}>
        <Icon name="upload" />
        {t('webCompanion.navUpload')}
      </button>
      <button className={activeTab === 'browse' ? 'active' : ''} onClick={() => onTabChange('browse')}>
        <Icon name="search" />
        {t('webCompanion.navBrowse')}
      </button>
      <button className={activeTab === 'books' ? 'active' : ''} onClick={() => onTabChange('books')}>
        <Icon name="book" />
        {t('webCompanion.navBooks')}
      </button>
    </nav>
  )
}

export type { TabType }
