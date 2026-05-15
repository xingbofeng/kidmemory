# Config API

前缀：无（根路由）。

## 路由总览

| Method | Path | 说明 |
|---|---|---|
| GET | `/health` | 服务健康检查 |
| GET | `/config/status` | 返回脱敏后的当前配置状态 |
| GET | `/config/ui` | 返回前端初始化所需 UI 配置 |
| POST | `/config/paths` | 更新本地数据目录相关路径 |
| POST | `/config/postgres` | 更新 PostgreSQL 配置 |
| POST | `/config/openai` | 更新 OpenAI 配置 |
| POST | `/config/supabase-storage` | 更新 Supabase 存储配置 |
| POST | `/config/supabase-storage/test` | 测试存储连接 |
| POST | `/config/check/postgres` | PostgreSQL 就绪检查 |
| POST | `/config/check/openai` | OpenAI 就绪检查 |
| POST | `/config/check/claude` | Claude 就绪检查 |
| POST | `/config/check/pgvector` | pgvector/embedding schema 就绪检查 |
| POST | `/schema/init` | 执行 schema 初始化（先 migrate deploy，失败可 fallback repair） |

## 请求体说明（关键接口）

### `POST /config/paths`

```json
{
  "rootDir": "/data/kidmemory",
  "dataDir": "/data/kidmemory/data",
  "workspaceDir": "/data/kidmemory/workspace",
  "exportDir": "/data/kidmemory/exports"
}
```

### `POST /config/postgres`

```json
{
  "host": "localhost",
  "port": 5432,
  "database": "kidmemory",
  "user": "postgres",
  "password": "secret",
  "connectionUrl": "postgresql://..."
}
```

### `POST /config/openai`

```json
{
  "baseUrl": "https://api.openai.com/v1",
  "apiKey": "sk-...",
  "model": "gpt-4o-mini"
}
```

### `POST /config/supabase-storage`

```json
{
  "url": "https://xxx.supabase.co",
  "bucket": "kidmemory",
  "serviceRoleKey": "xxx",
  "publicBaseUrl": "https://xxx.storage.supabase.co/storage/v1/object/public/kidmemory",
  "signedUrlTtlSeconds": 3600,
  "s3Endpoint": "https://xxx.storage.supabase.co/storage/v1/s3",
  "s3Region": "auto",
  "s3AccessKeyId": "xxx",
  "s3SecretAccessKey": "xxx"
}
```

## 响应说明

- 配置更新接口成功通常返回 `201`，结构为 `{ "ok": true, ... }`。
- 校验失败返回 `400`，包含 `issues`。
- readiness 接口统一返回“可行动错误信息”（例如 `action`、`message`）。
