import { Icon } from '../ui/Icon'
import { AssetBrowser } from '../../pages/browse/AssetBrowser'

interface BrowseViewProps {
  childId: string
}

export function BrowseView({ childId }: BrowseViewProps) {
  return (
    <section className="browse-view" aria-labelledby="browse-title">
      <div className="screen-title">
        <span className="cloud-mini" />
        <h1 id="browse-title">素材浏览</h1>
        <button className="help-button" aria-label="帮助">
          <Icon name="info" label="帮助" />
        </button>
      </div>
      <AssetBrowser childId={childId} />
    </section>
  )
}