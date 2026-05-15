import { Icon } from '../ui/Icon'

type TabType = 'connect' | 'upload' | 'browse' | 'books'

interface AppNavigationProps {
  activeTab: TabType
  onTabChange: (tab: TabType) => void
}

export function AppNavigation({ activeTab, onTabChange }: AppNavigationProps) {
  return (
    <nav className="app-nav" aria-label="Web Companion 主要导航">
      <button
        className={activeTab === 'connect' ? 'active' : ''}
        onClick={() => onTabChange('connect')}
      >
        <Icon name="link" />
        连接
      </button>
      <button
        className={activeTab === 'upload' ? 'active' : ''}
        onClick={() => onTabChange('upload')}
      >
        <Icon name="upload" />
        上传
      </button>
      <button
        className={activeTab === 'browse' ? 'active' : ''}
        onClick={() => onTabChange('browse')}
      >
        <Icon name="search" />
        浏览
      </button>
      <button
        className={activeTab === 'books' ? 'active' : ''}
        onClick={() => onTabChange('books')}
      >
        <Icon name="book" />
        作品集
      </button>
    </nav>
  )
}

export type { TabType }