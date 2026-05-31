import { httpClient } from '../lib/http-client';
import type { ShareTokenValidation } from '../types/shareBook';
import type { SharedAsset } from '../types/shareBrowse';
import type { SharedBook } from '../types/shareBook';

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
