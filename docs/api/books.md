# Books API

前缀：`/books`

## 路由总览

| Method | Path | 说明 |
|---|---|---|
| POST | `/books/jobs` | 创建书稿生成任务 |
| GET | `/books/jobs/:id` | 获取任务状态/结果 |
| GET | `/books/jobs/:id/preview` | 获取预览 HTML |
| POST | `/books/jobs/:id/export/pdf` | 导出 PDF |
| POST | `/books/jobs/:id/export/long-image` | 导出长图 |

## 请求体示例

### `POST /books/jobs`

```json
{
  "childId": "child-001",
  "assetIds": ["asset-a", "asset-b"],
  "title": "成长记忆册",
  "theme": "温暖童趣"
}
```

### `POST /books/jobs/:id/export/pdf`

```json
{
  "targetPath": "/Users/me/Downloads/book.pdf"
}
```

### `POST /books/jobs/:id/export/long-image`

```json
{
  "format": "png",
  "targetPath": "/Users/me/Downloads/book.png"
}
```

## 响应行为

- 控制器根据 service 返回的 `status` 透传 HTTP 状态码。
- 预览接口成功时返回 `text/html`。
- 任务不存在时常见返回 `404` 或 `{ ok: false, message: "Job not found" }`（由服务层决定）。
