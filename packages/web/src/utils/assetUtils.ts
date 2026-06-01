import i18n from '../i18n'
import { Asset, AssetFilter, AssetType } from '../types/asset'

export const filterAssets = (assets: Asset[], filter: AssetFilter, searchQuery: string): Asset[] => {
  let filtered = assets

  if (filter !== 'all' && filter !== 'recent') {
    filtered = filtered.filter((asset) => asset.type === filter)
  }

  const query = searchQuery.toLowerCase().trim()
  if (query) {
    filtered = filtered.filter((asset) => {
      const fields = [
        asset.name,
        asset.description ?? '',
        ...(asset.tags ?? []),
      ]
      return fields.some((field) => field.toLowerCase().includes(query))
    })
  }

  if (filter === 'recent') {
    return [...filtered].sort((a, b) => safeTime(b.createdAt) - safeTime(a.createdAt))
  }

  return filtered
}

const safeTime = (value: string): number => {
  const time = new Date(value).getTime()
  return Number.isFinite(time) ? time : 0
}

const ASSET_TYPE_LABEL_KEYS: Record<AssetType, string> = {
  drawing: 'assetType.drawing',
  photo: 'assetType.photo',
  video: 'assetType.video',
  craft: 'assetType.craft',
  other: 'assetType.other',
}

export const getAssetTypeLabel = (type: AssetType): string => i18n.t(ASSET_TYPE_LABEL_KEYS[type])

export const getFilterLabel = (filter: AssetFilter): string => {
  if (filter === 'all') return i18n.t('assetType.all')
  if (filter === 'recent') return i18n.t('upload.recentUpload')
  return getAssetTypeLabel(filter)
}
