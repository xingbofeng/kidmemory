/**
 * Direct Upload create session DTOs.
 *
 * 严格按 sidecar-api spec 中「桌面端请求会话签发」Scenario 定义。
 */

export interface CreateDirectUploadSessionRequest {
  childId: string;
}

/**
 * Sidecar 暴露给桌面端的会话签发响应。
 *
 * 安全约束：响应**不**包含 service role key、数据库连接串、本地绝对路径。
 * `anonKey` 是 Supabase public key，可由 sidecar 转发给前端使用，但前端不应缓存。
 */
export interface CreateDirectUploadSessionResponse {
  sessionId: string;
  childId: string;
  bucket: string;
  /** {bucket}/{sessionId} 形如 `web-companion-uploads/wcs_direct_xxx`。 */
  sessionPath: string;
  supabaseUrl: string;
  anonKey: string;
  /** Web Companion 直传上传页加上 query 参数后的完整 URL，可直接编码为二维码。 */
  publicUrl: string;
  /** 体验约束（不是安全约束）：单次推荐张数。 */
  recommendedClientLimit: number;
  /** 体验约束（不是安全约束）：建议会话有效期，仅作为前端提示。 */
  expiresAtHintSeconds: number;
  /** 一次性验证 token，pullback 时需携带以防止未授权回拉。 */
  token: string;
}
