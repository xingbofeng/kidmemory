export interface SharedAsset {
  id: string
  title: string
  type: string
  createdAt: string
  previewUrl?: string
}

export interface ShareTokenValidation {
  isValid: boolean
  shareToken?: {
    id: string
    childId: string
    resourceType: string
    accessType: string
  }
  error?: string
}