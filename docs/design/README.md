# KidMemory 设计稿目录

本目录存放产品设计规范、roadmap 图、桌面端页面图和 Web Companion 参考图。图片文件下一步会单独整理，当前先保持文件不移动。

## 当前图片

- `images/design-system-overview.png`：总体设计规范。
- `images/roadmap.png`：产品 Roadmap 图。
- `images/desktop-setup.png`：初始化 / 设置页。
- `images/desktop-sample-dataset.png`：示例数据集页。
- `images/desktop-child-profile.png`：孩子档案页。
- `images/desktop-asset-library.png`：素材库页。
- `images/desktop-generate-export.png`：生成 / 预览 / PDF 导出页。
- `images/web-companion-connect-upload.png`：Web Companion 会话与批量上传参考稿。
- `images/mobile-connect.png`：手机连接概念参考稿。
- `images/mobile-upload.png`：手机上传素材视觉参考稿。
- `images/mobile-browse.png`：手机素材浏览 / 轻量搜图参考稿。
- `images/mobile-books-share.png`：手机作品集 / 分享参考稿。
- `images/concept-board.png`：概念氛围板。

## 版本对应

- 0.1 到 0.4：桌面端为主，使用 desktop 系列设计稿。
- 0.5：Web Companion 扫码上传，参考 `images/web-companion-connect-upload.png`、`images/mobile-connect.png`、`images/mobile-upload.png`。
- 0.6：Web Companion 浏览与分享，参考 `images/mobile-browse.png`、`images/mobile-books-share.png`。
- 0.7：Supabase Direct Upload 验证版，沿用 Web Companion 上传视觉，但需要明确“直传验证版”和“电脑端回拉后才算入库”的风险提示。
- 0.8：后端可信上传版，沿用 Web Companion 上传视觉，重点展示短效会话、数量上限、上传进度、ready/failed 状态和桌面端回拉结果。

## 后续整理规则

- 图片整理阶段再移动文件，不在本轮文本整理中改路径。
- 设计稿命名应按端和用途归类，例如 `desktop-*`、`mobile-*`、`web-companion-*`。
- 里程碑文档只引用长期稳定的设计稿，不引用临时 review 或 OpenSpec 文件。
