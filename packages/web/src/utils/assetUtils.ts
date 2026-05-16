import i18n from '../i18n'
import { Asset, AssetFilter, AssetType } from '../types/asset'

export const filterAssets = (assets: Asset[], filter: AssetFilter, searchQuery: string): Asset[] => {
  let filtered = assets

  if (filter !== 'all') {
    filtered = filtered.filter((asset) => asset.type === filter)
  }

  const query = searchQuery.toLowerCase().trim()
  if (query) {
    filtered = filtered.filter((asset) => asset.name.toLowerCase().includes(query))
  }

  return filtered
}

const ASSET_TYPE_LABEL_KEYS: Record<AssetType, string> = {
  drawing: 'assetType.drawing',
  photo: 'assetType.photo',
  video: 'assetType.video',
}

export const getAssetTypeLabel = (type: AssetType): string => i18n.t(ASSET_TYPE_LABEL_KEYS[type])

export const getFilterLabel = (filter: AssetFilter): string => {
  if (filter === 'all') return i18n.t('assetType.all')
  return getAssetTypeLabel(filter)
}
