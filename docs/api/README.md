# KidMemory Sidecar API 文档

本目录是 `packages/backend` 当前代码的全量 HTTP 接口文档。

## 基础信息

- 默认地址：`http://127.0.0.1:4317`
- 协议：HTTP + JSON（少数接口返回文件流/HTML）
- 运行时：NestJS（手动装饰器注册）

## 模块导航

1. [配置模块（Config）](./config.md)
2. [数据集模块（Dataset）](./dataset.md)
3. [书稿模块（Books）](./books.md)
4. [Agent 配置模块（Agent Config）](./agent-config.md)
5. [Web Companion（含 Direct Upload / LAN）](./web-companion.md)

## 通用错误响应

大多数接口在失败时返回如下结构（字段会因模块略有差异）：

```json
{
  "ok": false,
  "code": "BAD_REQUEST",
  "message": "Invalid payload",
  "timestamp": "2026-05-16T00:00:00.000Z",
  "path": "/some/path"
}
```

## 说明

- 文档以控制器源码为准（`src/modules/**/**.controller.ts`）。
- DTO 校验错误通常返回 `400` 并包含 `issues` 字段。
