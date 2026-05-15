export type AssetType = 'drawing' | 'photo' | 'video'

export type AssetFilter = 'all' | AssetType

export interface Asset {
  id: string
  name: string
  type: AssetType
  thumbnailUrl: string
  createdAt: string
}

export interface AssetListResponse {
  assets: Asset[]
  total: number
}
