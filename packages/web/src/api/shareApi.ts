/**
 * Share API Module
 * 
 * Handles all share-related API calls
 */

import { httpClient } from '../lib/http-client';

/**
 * Share Token Validation
 */
export interface ShareTokenValidation {
  isValid: boolean;
  shareToken?: {
    id: string;
    childId: string;
    resourceType: string;
    resourceId?: string;
    accessType: string;
  };
  error?: string;
}

export interface SharedAsset {
  id: string;
  title: string;
  type: string;
  createdAt: string;
  previewUrl?: string;
}

export interface SharedBook {
  id: string;
  title: string;
  childId: string;
  createdAt: string;
  status: string;
  description?: string;
  previewUrl?: string;
  pageCount?: number;
}

export async function validateShareToken(shareToken: string): Promise<ShareTokenValidation> {
  return httpClient.get<ShareTokenValidation>(
    `/api/web-companion/share/${shareToken}/access`
  );
}

export async function getSharedAssets(shareToken: string): Promise<SharedAsset[]> {
  return httpClient.get<SharedAsset[]>(
    `/api/web-companion/share/${shareToken}/assets`
  );
}

export async function getSharedBook(shareToken: string, bookId: string): Promise<SharedBook> {
  return httpClient.get<SharedBook>(
    `/api/web-companion/share/${shareToken}/book?bookId=${bookId}`
  );
}
