# Web Companion API

包含三组接口：
- Trusted Upload + Browse + Share：`/api/web-companion/*`
- Direct Upload：`/api/web-companion/direct-upload/*`
- LAN Receiver：`/api/web-companion/lan/*`

---

## 1) Trusted Upload / Browse / Share

前缀：`/api/web-companion`

### 会话与上传

| Method | Path | 说明 |
|---|---|---|
| POST | `/api/web-companion/sessions` | 创建上传会话 |
| GET | `/api/web-companion/sessions/:sessionId` | 会话摘要 |
| GET | `/api/web-companion/sessions/:sessionId/detail` | 会话详情 |
| POST | `/api/web-companion/sessions/:sessionId/items` | 创建上传项（兼容 `files` 与 `items`） |
| PUT | `/api/web-companion/sessions/:sessionId/items/:uploadItemId/commit` | 提交上传完成 |
| POST | `/api/web-companion/sessions/:sessionId/items/:uploadItemId/retry` | 重试上传项 |
| POST | `/api/web-companion/sessions/:sessionId/close` | 关闭会话 |

`POST /sessions/:id/items` 请求体示例：

```json
{
  "token": "session-token",
  "provider": "supabase",
  "files": [
    {
      "clientFileId": "f1",
      "filename": "a.jpg",
      "contentType": "image/jpeg",
      "sizeBytes": 12345
    }
  ]
}
```

兼容写法（legacy）：

```json
{
  "token": "session-token",
  "items": [
    { "filename": "a.jpg", "mimeType": "image/jpeg", "size": 12345 }
  ]
}
```

### 浏览（需要 `token` query）

| Method | Path | 说明 |
|---|---|---|
| GET | `/api/web-companion/sessions/:sessionId/recent` | 最近上传 |
| GET | `/api/web-companion/sessions/:sessionId/assets/:assetId` | 素材详情 |
| GET | `/api/web-companion/sessions/:sessionId/books` | 书稿列表 |
| GET | `/api/web-companion/sessions/:sessionId/books/:bookId` | 书稿详情 |

### 分享

| Method | Path | 说明 |
|---|---|---|
| POST | `/api/web-companion/sessions/:sessionId/share` | 创建分享 token（需 `token` query） |
| POST | `/api/web-companion/sessions/:sessionId/share/:shareTokenId/revoke` | 撤销分享 |
| GET | `/api/web-companion/share/:shareToken/access` | 公共访问校验 |
| GET | `/api/web-companion/share/:shareToken/assets` | 公共素材列表 |
| GET | `/api/web-companion/share/:shareToken/book` | 公共书稿详情 |

---

## 2) Direct Upload

前缀：`/api/web-companion/direct-upload`

| Method | Path | 说明 |
|---|---|---|
| POST | `/api/web-companion/direct-upload/sessions` | 创建直传会话 |
| GET | `/api/web-companion/direct-upload/sessions/:sessionId/objects` | 列出远端对象 |
| POST | `/api/web-companion/direct-upload/sessions/:sessionId/pullback` | 回拉到本地素材库 |
| GET | `/api/web-companion/direct-upload/sessions/:sessionId/status` | 回拉状态 |
| GET | `/api/web-companion/direct-upload/sessions/:sessionId/config` | 前端直传配置 |

---

## 3) LAN Receiver

前缀：`/api/web-companion/lan`

| Method | Path | 说明 |
|---|---|---|
| GET | `/api/web-companion/lan/discover` | 设备发现信息 |
| POST | `/api/web-companion/lan/pair` | 配对 |
| POST | `/api/web-companion/lan/sessions/:sessionId/upload` | 局域网上传（multipart files） |
| GET | `/api/web-companion/lan/sessions/:sessionId/status` | LAN 会话状态 |
| GET | `/api/web-companion/lan/devices` | 探测局域网设备 |

`upload` 需要 query 参数 `token`，并上传 `files` 字段；空文件会返回 `400 NO_FILES`。
