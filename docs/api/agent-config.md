# Agent Config API

前缀：`/api/config`

## 路由总览

| Method | Path | 说明 |
|---|---|---|
| GET | `/api/config/agent-configs` | 列出配置 |
| GET | `/api/config/agent-configs/default` | 获取默认配置 |
| GET | `/api/config/agent-configs/:id` | 获取单个配置 |
| POST | `/api/config/agent-configs` | 创建配置 |
| PUT | `/api/config/agent-configs/:id` | 更新配置 |
| DELETE | `/api/config/agent-configs/:id` | 删除配置 |
| POST | `/api/config/agent-configs/:id/set-default` | 设为默认 |
| POST | `/api/config/agent-configs/:id/test` | 测试配置连通性 |

## 请求体示例

### `POST /api/config/agent-configs`

```json
{
  "name": "OpenAI 4o mini",
  "provider": "openai",
  "model": "gpt-4o-mini",
  "apiKey": "sk-...",
  "baseUrl": "https://api.openai.com/v1",
  "temperature": 0.7,
  "maxTokens": 4000,
  "isDefault": false
}
```

### `PUT /api/config/agent-configs/:id`

```json
{
  "description": "用于绘本生成",
  "isActive": true
}
```

### `POST /api/config/agent-configs/:id/test`

```json
{
  "testPrompt": "hello"
}
```

## 错误码（常见）

- `CONFIG_NOT_FOUND`
- `DUPLICATE_CONFIG`
- `CANNOT_DELETE_DEFAULT`
- `ENCRYPTION_UNAVAILABLE`
- `VALIDATION_ERROR`
- `INTERNAL_ERROR`
