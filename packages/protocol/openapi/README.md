# OpenAPI 生成文件目录

此目录存放从 NestJS 生成的 OpenAPI 规范文件。

## 文件说明

- `sidecar.openapi.json` - Sidecar API 的 OpenAPI 3.0 规范（JSON 格式）
- `sidecar.openapi.yaml` - Sidecar API 的 OpenAPI 3.0 规范（YAML 格式）
- `cloud-api.openapi.json` - Cloud API 的 OpenAPI 3.0 规范（JSON 格式）
- `cloud-api.openapi.yaml` - Cloud API 的 OpenAPI 3.0 规范（YAML 格式）

## 生成方式

这些文件由脚本自动生成，不应手动编辑：

```bash
# 生成 sidecar OpenAPI
npm run gen:openapi:sidecar

# 生成 cloud-api OpenAPI
npm run gen:openapi:cloud-api
```

## 注意事项

- 这些文件应提交到 Git，作为 API 文档的一部分
- CI 会检查这些文件是否与源码同步
- 修改 API 后，必须重新生成这些文件
