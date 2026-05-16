# 代码生成目录

此目录存放从 OpenAPI 规范自动生成的客户端代码。

## 目录结构

```
generated/
├── sidecar/
│   └── dart/          # Dart 客户端（供 Flutter Desktop 使用）
└── cloud-api/
    └── ts/            # TypeScript 类型（供 Web 使用，可选）
```

## 生成方式

这些文件由脚本自动生成，不应手动编辑：

```bash
# 生成 Dart 客户端（从 sidecar OpenAPI）
npm run gen:dart:sidecar

# 生成 TypeScript 类型（从 cloud-api OpenAPI）
npm run gen:ts:cloud-api
```

## 使用方式

### Flutter Desktop

```dart
import 'package:kidmemory_protocol/generated/sidecar/dart/api.dart';
```

### Web (可选)

Web 端可以直接 import protocol 的 TypeScript interface：

```typescript
import type { UploadSession } from '@kidmemory/protocol/cloud-api';
```

也可以使用生成的类型：

```typescript
import type { components } from '@kidmemory/protocol/generated/cloud-api/ts';
```

## 注意事项

- 生成的代码应提交到 Git
- CI 会检查生成的代码是否与 OpenAPI 同步
- 不要手动修改生成的代码
