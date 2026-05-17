# Supabase RLS 策略配置

## Direct Upload Bucket 策略

为保护 Direct Upload 功能的安全性，需要在 Supabase 控制台为 `web-companion-uploads` bucket 配置以下 RLS 策略。

### 上传策略（INSERT）

允许匿名用户仅上传到自己的 session 路径下：

```sql
-- 策略名称：allow_session_upload
-- 操作：INSERT
-- 角色：anon
CREATE POLICY "allow_session_upload" ON storage.objects
  FOR INSERT TO anon
  WITH CHECK (
    bucket_id = 'web-companion-uploads'
    AND (storage.foldername(name))[1] IS NOT NULL
  );
```

### 读取策略（SELECT）

仅允许 service role 读取（sidecar pullback 使用 service role key）：

```sql
-- service_role 默认已有全部权限，无需额外配置
-- 确保 bucket 设置为 private，禁止 anon 读取
```

### 安全说明

1. **anon key 只能写入**，不能读取其他 session 的文件
2. **sidecar 使用 service role key** 进行 list 和 download
3. **session 路径格式**：`{sessionId}/{filename}`，由 sidecar 签发 sessionId
4. **建议设置 bucket 为 private**，禁止公开访问
5. **一次性 token**：sidecar 在签发 session 时生成 token，pullback 时需携带验证

## 配置步骤

1. 登录 Supabase 控制台
2. 进入 **Storage → Policies**
3. 选择 `web-companion-uploads` bucket
4. 添加上述 INSERT 策略
5. 确认 bucket 设置为 **private**
6. 在 `.env` 中配置：
   - `SUPABASE_SERVICE_ROLE_KEY`：用于 sidecar pullback
   - `SUPABASE_ANON_KEY`：下发给 Web Companion 前端
   - `SUPABASE_DIRECT_UPLOAD_BUCKET`：bucket 名称

## 环境变量说明

| 变量名 | 用途 | 是否下发前端 |
|--------|------|------------|
| `SUPABASE_SERVICE_ROLE_KEY` | sidecar list/download | ❌ 绝不 |
| `SUPABASE_ANON_KEY` | Web Companion 上传 | ✅ 可以 |
| `SUPABASE_URL` | Supabase 项目地址 | ✅ 可以 |
| `SUPABASE_DIRECT_UPLOAD_BUCKET` | bucket 名称 | ✅ 可以 |
