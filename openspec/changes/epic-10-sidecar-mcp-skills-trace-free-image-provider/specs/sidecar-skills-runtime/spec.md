## ADDED Requirements

### Requirement: Sidecar 必须从 registry 加载 Skill 并在受控运行时执行

系统 SHALL 提供 loader/registry/workspace/permission 四类运行时能力。

#### Scenario: registry 解析成功
- **WHEN** 启动 skill runtime
- **THEN** 已注册 skill 可被加载并准备执行

#### Scenario: 权限策略强制执行
- **WHEN** skill 请求工具或文件访问
- **THEN** 仅允许白名单边界内能力

### Requirement: Runtime 必须可被 SDK 调用并触发 skill->tool 链路

系统 SHALL 支持通过 sidecar SDK 触发 skill 执行，并在 runtime 内调用 MCP tools。

#### Scenario: SDK 驱动 runtime 执行
- **WHEN** 使用 SDK 发起一次受控 skill 任务
- **THEN** runtime 必须完成 skill 加载、工具调用和结果回传
