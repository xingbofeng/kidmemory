## ADDED Requirements

### Requirement: picturebook-maker 必须可作为 KidMemory Skill 使用

系统 SHALL 从 `https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker` 引入 picturebook-maker 到 skills 包，并补齐 KidMemory 运行边界与扩展脚本。

#### Scenario: picturebook-maker 完整可见
- **WHEN** 检查 `packages/skills/skills/picturebook-maker`
- **THEN** 必须包含完整 skill 文件与 KidMemory 使用说明

#### Scenario: Pollinations 扩展存在
- **WHEN** 检查 skill 扩展目录
- **THEN** 必须存在 `generate_pollinations_image` 扩展脚本与文档

### Requirement: Hyperframes Skill 必须以挂载方式接入

系统 SHALL 通过 source + install/mount 接入 Hyperframes skill，不重写其内部结构。

#### Scenario: Hyperframes 可安装挂载
- **WHEN** 执行 Hyperframes 安装脚本
- **THEN** skill 必须可被 runtime 识别并可用于视频流程

### Requirement: Hyperframes Registry 必须同时接入

系统 SHALL 在引入 Hyperframes 全家桶时，同时支持 registry 的安装与组件引入流程。

#### Scenario: Hyperframes registry 可用
- **WHEN** 执行 registry 安装/挂载与组件引入
- **THEN** runtime 必须可识别 registry 项并用于 composition 生成
