# KidMemory Sidecar API 文档

本目录是 `packages/sidecar` 当前代码的全量 HTTP 接口文档。

## 基础信息

- 默认地址：`http://127.0.0.1:4317`
- 协议：HTTP + JSON（少数接口返回文件流/HTML）
- 运行时：NestJS（标准模块/控制器/服务装饰器）

## 模块导航

1. [配置模块（Config）](./config.md)
2. [数据集模块（Dataset）](./dataset.md)
3. [书稿模块（Books）](./books.md)
4. [Agent 配置模块（Agent Config）](./agent-config.md)
5. [Web Companion（含 Direct Upload / LAN）](./web-companion.md)

## 通用错误响应

大多数接口在成功/失败时均返回统一结构：

```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

## 说明

- 文档以控制器源码为准（`src/modules/**/**.controller.ts`）。
- DTO 校验错误返回非 0 `code`，并在 `data.details.issues` 中包含字段级问题。
