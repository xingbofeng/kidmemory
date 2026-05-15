import { Asset, AssetFilter, AssetType } from '../types/asset'

export const filterAssets = (
  assets: Asset[],
  filter: AssetFilter,
  searchQuery: string,
): Asset[] => {
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

const ASSET_TYPE_LABELS: Record<AssetType, string> = {
  drawing: '绘画',
  photo: '照片',
  video: '视频',
}

export const getAssetTypeLabel = (type: AssetType): string => ASSET_TYPE_LABELS[type]

export const getFilterLabel = (filter: AssetFilter): string => {
  if (filter === 'all') return '全部'
  return getAssetTypeLabel(filter)
}
