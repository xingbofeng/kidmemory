export interface CreateDirectUploadSessionRequest {
  childId: string;
}

export interface CreateDirectUploadSessionResponse {
  sessionId: string;
  childId: string;
  bucket: string;
  sessionPath: string;
  supabaseUrl: string;
  anonKey: string;
  provider: string;
  uploadMode: "supabase-js" | "signed-url";
  publicUrl: string;
  recommendedClientLimit: number;
  expiresAtHintSeconds: number;
  token: string;
}
