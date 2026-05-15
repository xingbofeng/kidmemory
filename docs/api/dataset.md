# Dataset API

前缀：无（根路由）。

## 路由总览

| Method | Path | 说明 |
|---|---|---|
| POST | `/sample/import` | 导入示例数据 |
| POST | `/sample/reset` | 重置某 child 的示例素材 |
| POST | `/children` | 创建 child |
| GET | `/children` | 列表 child |
| GET | `/children/:id` | 获取 child |
| POST | `/assets/import` | 导入本地/目录素材 |
| GET | `/assets` | 列表素材（可按 `type`/`childId` 过滤） |
| GET | `/assets/:id` | 获取素材详情 |
| GET | `/assets/:id/preview` | 读取素材预览图/源图流 |
| POST | `/assets/:id/update` | 更新素材元数据 |
| DELETE | `/assets/:id` | 删除素材 |
| POST | `/search/query` | 语义检索 |
| GET | `/search/candidate-pool` | 候选池列表 |
| POST | `/search/candidate-pool/items` | 添加候选池项 |
| DELETE | `/search/candidate-pool/items` | 删除候选池项 |
| POST | `/search/candidate-pool/items/remove` | 删除候选池项（POST 兼容） |
| GET | `/search/indexing-status` | 索引队列状态 |
| POST | `/search/indexing/run` | 手动触发索引 worker |
| POST | `/storage/assets/:id/sync` | 入队素材存储同步 |
| POST | `/storage/export-artifacts/:id/sync` | 入队导出物存储同步 |
| POST | `/storage/sync/run` | 手动触发存储同步 worker |
| GET | `/storage/export-artifacts/:id/share` | 获取导出物分享元信息 |

## 常用请求体示例

### `POST /sample/import`

```json
{ "persist": true }
```

### `POST /children`

```json
{ "id": "child-001", "name": "小朋友" }
```

### `POST /assets/import`

```json
{
  "childId": "child-001",
  "paths": ["/Users/me/Pictures/kids"],
  "recursive": true
}
```

### `POST /assets/:id/update`

```json
{
  "title": "海边涂鸦",
  "description": "周末活动",
  "tags": ["海边", "绘画"]
}
```

### `POST /search/query`

```json
{
  "childId": "child-001",
  "query": "有太阳的画",
  "limit": 20
}
```

## 备注

- `GET /assets/:id/preview` 返回二进制流，`Content-Type` 由文件后缀推断。
- DTO 校验失败返回 `400`，并附 `issues` 字段。
