## ADDED Requirements

### Requirement: 根目录必须提供统一的 ESLint 配置

系统 SHALL 在根目录新增 `eslint.config.mjs`，统一管理所有包的 ESLint 规则。

#### Scenario: 根目录 ESLint 配置
- **WHEN** 检查根目录
- **THEN** 必须存在 `eslint.config.mjs` 文件

#### Scenario: 支持不同包的规则覆盖
- **WHEN** 配置 ESLint
- **THEN** 必须支持 Node/Nest、React/Web、tests 等不同文件的规则覆盖

#### Scenario: 统一 ESLint 版本
- **WHEN** 检查所有包的 ESLint 版本
- **THEN** 必须使用相同的 ESLint 9 和 @typescript-eslint 8

#### Scenario: 删除包级别的 ESLint 配置
- **WHEN** 完成根目录配置
- **THEN** 删除 packages/backend/eslint.config.cjs 和 packages/web/eslint.config.js

### Requirement: 根目录必须提供统一的 TypeScript 配置

系统 SHALL 在根目录新增 `tsconfig.*.json` 系列配置，统一管理 TypeScript 编译选项。

#### Scenario: 根目录 tsconfig 系列
- **WHEN** 检查根目录
- **THEN** 必须存在 tsconfig.base.json、tsconfig.node.json、tsconfig.nest.json、tsconfig.react.json

#### Scenario: 包级别继承根配置
- **WHEN** 检查包的 tsconfig.json
- **THEN** 必须通过 extends 继承根目录配置

#### Scenario: tsconfig.nest.json 用于 NestJS
- **WHEN** sidecar 或 cloud-api 的 tsconfig.json
- **THEN** 必须 extends tsconfig.nest.json

#### Scenario: tsconfig.react.json 用于 React
- **WHEN** web 的 tsconfig.json
- **THEN** 必须 extends tsconfig.react.json

### Requirement: 必须统一编译器选项

系统 SHALL 统一所有包的 TypeScript 编译器选项（strict、target、module 等）。

#### Scenario: 启用 strict 模式
- **WHEN** 检查 tsconfig.base.json
- **THEN** 必须设置 strict: true

#### Scenario: 统一 target 和 module
- **WHEN** 检查 tsconfig.node.json
- **THEN** 必须设置 target: "ES2022", module: "ESNext"

#### Scenario: 统一路径映射
- **WHEN** 检查 tsconfig.base.json
- **THEN** 必须配置统一的 paths 映射（如 @/* 等）

### Requirement: 必须支持 monorepo 引用

系统 SHALL 支持包之间的 TypeScript 引用（project references）。

#### Scenario: protocol 被其他包引用
- **WHEN** sidecar 引用 protocol
- **THEN** 必须通过 tsconfig references 配置

#### Scenario: 支持增量编译
- **WHEN** 修改 protocol 代码
- **THEN** 只重新编译 protocol 和依赖它的包

### Requirement: 必须保持构建成功

系统 SHALL 确保统一配置后，所有包都能成功构建。

#### Scenario: protocol 构建成功
- **WHEN** 运行 `npm --prefix packages/protocol run build`
- **THEN** 构建成功，无 TypeScript 错误

#### Scenario: sidecar 构建成功
- **WHEN** 运行 `npm --prefix packages/backend run build:prod`
- **THEN** 构建成功，无 TypeScript 错误

#### Scenario: web 构建成功
- **WHEN** 运行 `npm --prefix packages/web run build`
- **THEN** 构建成功，无 TypeScript 错误

### Requirement: 必须支持 IDE 集成

系统 SHALL 确保根目录配置能被 VSCode 和 JetBrains IDE 正确识别。

#### Scenario: VSCode 识别 ESLint 配置
- **WHEN** 在 VSCode 中打开项目
- **THEN** ESLint 插件能正确识别根目录配置

#### Scenario: VSCode 识别 TypeScript 配置
- **WHEN** 在 VSCode 中打开项目
- **THEN** TypeScript 插件能正确识别根目录配置

#### Scenario: 支持 workspace 设置
- **WHEN** 检查 .vscode/settings.json
- **THEN** 必须配置 ESLint 和 TypeScript 的 workspace 设置

### Requirement: 必须有 CI 检查

系统 SHALL 在 CI 中检查 ESLint 和 TypeScript 配置的正确性。

#### Scenario: CI 检查 ESLint
- **WHEN** 运行 CI
- **THEN** 必须执行 `npm run lint` 检查所有包

#### Scenario: CI 检查 TypeScript
- **WHEN** 运行 CI
- **THEN** 必须执行 `npm run type-check` 检查所有包

#### Scenario: CI 检查配置一致性
- **WHEN** 运行 CI
- **THEN** 必须检查所有包的 ESLint 和 TypeScript 版本一致
