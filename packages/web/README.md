# KidMemory Web Companion

`packages/web` 是 KidMemory 的 Web Companion 前端应用，基于 Vite、React 和 TypeScript 构建。它面向移动端或浏览器访问场景，提供素材浏览、可信上传、直传会话、分享浏览和绘本分享等 Web 体验。

### 主要职责

- 提供 Web Companion 的用户界面，包括连接、上传、浏览和作品查看流程。
- 与 Sidecar 或 Cloud API 通信，处理素材上传、分享 token、浏览数据和直传任务。
- 承载移动端友好的页面，例如 `/upload`、`/browse`、`/share` 相关体验。
- 维护 Web 前端的国际化、组件、API client 和测试。

### 目录说明

- `src/components/`：可复用 UI 组件，包含 Web Companion、上传、分享等模块。
- `src/pages/`：路由级页面，例如落地页、上传页、浏览页和分享页。
- `src/api/`：面向 Sidecar、Cloud API 和上传服务的 API 封装。
- `src/hooks/`：上传流程、可信上传和错误处理相关 React hooks。
- `src/lib/`：HTTP client、直传 client、上传会话和命名规则等核心前端逻辑。
- `src/i18n/`：中英文文案和 i18n 初始化。
- `src/test/`、`*.test.ts(x)`：Vitest、Testing Library 和 MSW 测试。
- `public/`：图标、示例素材和公开静态资源。

### 常用命令

```bash
npm --prefix packages/web run dev
npm --prefix packages/web run build
npm --prefix packages/web run test
npm --prefix packages/web run lint
npm --prefix packages/web run type-check
```

### 开发提示

- 新增 UI 交互时，优先补充相邻的 `*.test.tsx`。
- API 类型和契约应与 `packages/protocol` 保持同步。
- 本包不应直接依赖桌面端内部实现，跨包共享内容应通过协议包或显式 API 完成。
