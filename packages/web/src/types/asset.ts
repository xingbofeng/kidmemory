export type AssetType = 'drawing' | 'photo' | 'video' | 'craft' | 'other'

export type AssetFilter = 'all' | AssetType | 'recent'

export interface Asset {
  id: string
  name: string
  type: AssetType
  thumbnailUrl: string
  createdAt: string
  description?: string
  tags?: string[]
}

export interface AssetListResult {
  assets: Asset[]
  total: number
}
