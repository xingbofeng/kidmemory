# KidMemory 图片资源目录

本目录存放 README、产品设计规范、桌面端页面图、Web Companion 参考图、架构图和流程图。

## 当前图片

- `design-system-overview.png`：总体设计规范。
- `first-bear-icon.png`：README 和品牌展示用图标。
- `desktop-setup.png`：初始化 / 设置页。
- `desktop-sample-dataset.png`：示例数据集页。
- `desktop-child-profile.png`：孩子档案页。
- `desktop-asset-library.png`：素材库页。
- `desktop-generate-export.png`：生成 / 预览 / PDF 导出页。
- `desktop-child-profile-detail-reference.png`：孩子档案详情页参考稿。
- `desktop-asset-library-reference.png`：素材库页参考稿。
- `desktop-generate-workbench-reference.png`：创作台页参考稿。
- `desktop-setup-reference.png`：设置页参考稿。
- `web-companion-connect-upload.png`：Web Companion 会话与批量上传参考稿。
- `mobile-connect.png`：手机连接概念参考稿。
- `mobile-upload.png`：手机上传素材视觉参考稿。
- `mobile-browse.png`：手机素材浏览 / 轻量搜图参考稿。
- `mobile-books-share.png`：手机作品集 / 分享参考稿。
- `concept-board.png`：概念氛围板。
- `kidmemory-product-flow-zh.svg`：中文 README 产品流程图。
- `kidmemory-product-flow-en.svg`：英文 README 产品流程图。
- `kidmemory-runtime-architecture.svg`：默认运行时架构图（英文版语义一致，兼容历史引用）。
- `kidmemory-runtime-architecture-en.svg`：英语 README 使用的运行时架构图。
- `kidmemory-runtime-architecture-zh.svg`：中文 README 使用的运行时架构图。

## 版本对应

- 0.1 到 0.4：桌面端为主，使用 desktop 系列设计稿。
- 0.5：Web Companion 扫码上传，参考 `web-companion-connect-upload.png`、`mobile-connect.png`、`mobile-upload.png`。
- 0.6：Web Companion 浏览与分享，参考 `mobile-browse.png`、`mobile-books-share.png`。
- 0.7：Supabase Direct Upload 验证版，沿用 Web Companion 上传视觉，但需要明确“直传验证版”和“电脑端回拉后才算入库”的风险提示。
- 0.8：后端可信上传版，沿用 Web Companion 上传视觉，重点展示短效会话、数量上限、上传进度、ready/failed 状态和桌面端回拉结果。

## 后续整理规则

- 新增长期设计图、架构图和流程图统一放在 `docs/images/`。
- 设计稿命名应按端和用途归类，例如 `desktop-*`、`mobile-*`、`web-companion-*`。
- 里程碑文档只引用长期稳定的设计稿，不引用临时 review 或 OpenSpec 文件。
