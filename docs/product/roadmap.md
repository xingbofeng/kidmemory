# KidMemory Roadmap

## 功能路线

KidMemory 当前按功能里程碑推进，避免在产品文案和代码中暴露发布编号。

| 名称 | 发布状态 |
|------|----------|
| macOS 桌面 MVP | 已完成 |
| 桌面素材管理增强 | 已完成 |
| 桌面搜图增强 | 已完成 |
| 导出与存储增强 | 已完成 |
| Web Companion 扫码上传 | 部分实现 |
| Web Companion 浏览与分享 | 规划中 |
| Web Companion Supabase 直传验证 | 技术验证完成 |
| Web Companion 后端可信上传 | 核心链路已跑通，待发布收口 |
| Agent 增强 | 部分实现 |
| macOS 开源稳定发布 | 目标里程碑，未发布 |

## 近期收口重点

1. 完成 Web Companion 后端可信上传发布收口：文档、旧入口清理、最终验收记录。
2. Direct Upload 保留为回滚入口：不再扩展新功能，只保留配置检查、状态查询和回拉故障排查能力，待后端可信上传稳定发布后再移除。
3. 继续实现 Agent 增强中未完成的 Runner、修复和可观察性能力。
4. 补齐安装包、fresh setup、备份恢复和 migration 验证。
