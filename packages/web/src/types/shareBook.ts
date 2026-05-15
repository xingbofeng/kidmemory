export interface SharedBook {
  id: string
  title: string
  childId: string
  createdAt: string
  status: string
  description?: string
  previewUrl?: string
  pageCount?: number
}

export interface ShareTokenValidation {
  isValid: boolean
  shareToken?: {
    id: string
    childId: string
    resourceType: string
    resourceId?: string
    accessType: string
  }
  error?: string
}