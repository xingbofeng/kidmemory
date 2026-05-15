# KidMemory 剩余功能实现设计

## 概述

基于当前项目PRD分析，本设计文档规划了KidMemory项目中尚未完成功能的实现路径。采用渐进式完善策略，确保每个阶段都有可交付成果，同时控制开发风险。

## 当前状态分析

### 已完成功能
- 0.1-0.4：macOS桌面端核心功能
- 0.8：Web Companion可信上传（核心链路完成，待收口）

### 未完成功能
- 0.6：Web Companion浏览与分享（规划中）
- 0.9：Agent增强（部分实现）
- 1.0：稳定版发布准备（目标里程碑）

## 实现策略

采用**渐进式完善路径**，优先级：0.8收口 → 0.6手机端 → 0.9Agent增强 → 1.0发布

### 策略优势
- 每个阶段都有明确的里程碑和可交付成果
- 在稳定基础上逐步添加新功能
- 风险可控，便于调整优先级
- 符合开源项目的迭代发布模式

## 详细实现计划

### 阶段1：0.8发布收口（1-2周）

**目标：** 完成当前核心功能的文档整理和最终验收

**具体任务：**
1. **文档统一**
   - 清理发布编号不一致问题
   - 更新README和安装说明
   - 整理旧里程碑文档引用

2. **验收完成**
   - 运行完整测试套件
   - 记录Web Companion可信上传验收结果
   - 确认数据库和对象存储链路

3. **技术决策**
   - 决定0.7 Direct Upload是否保留为回滚入口
   - 清理不再使用的代码路径

**交付物：**
- 统一的里程碑文档
- 完整的验收测试报告
- 清理后的代码库

**验收标准：**
- 所有测试通过
- 文档发布编号统一
- 核心上传链路稳定运行

### 阶段2：0.6 Web Companion浏览与分享（2-3周）

**目标：** 实现手机端轻量浏览和作品集分享功能

#### 架构设计

**前端架构：**
```
packages/web/src/
├── components/
│   ├── BrowsePage.tsx          # 浏览页面容器
│   ├── RecentUploads.tsx       # 最近上传列表
│   ├── AssetViewer.tsx         # 素材详情查看
│   ├── BookViewer.tsx          # 作品集查看
│   └── SharePage.tsx           # 分享页面
├── hooks/
│   ├── useBrowseApi.ts         # 浏览API调用
│   └── useShareToken.ts        # 分享token管理
└── utils/
    └── accessControl.ts        # 访问控制工具
```

**后端API设计：**
```typescript
// 浏览相关端点
GET /api/browse/recent          # 获取最近上传
GET /api/browse/assets/:id      # 获取素材详情
GET /api/browse/books           # 获取作品集列表
GET /api/browse/books/:id       # 获取作品集详情

// 分享相关端点
POST /api/share/create          # 创建分享链接
GET /api/share/:token           # 访问分享内容
DELETE /api/share/:token        # 撤销分享链接
```

#### 核心组件实现

**1. 最近上传列表**
- 显示最近24小时内的上传素材
- 支持缩略图预览
- 显示上传状态和时间

**2. 素材浏览器**
- 支持图片、视频预览
- 显示素材元数据
- 支持简单的标签和描述

**3. 作品集查看**
- 展示生成的作品集内容
- 支持PDF预览
- 提供下载链接

**4. 分享功能**
- 生成时效性分享链接
- 支持密码保护
- 访问日志记录

#### 访问控制设计

**Session验证：**
```typescript
interface BrowseSession {
  sessionId: string;
  childId: string;
  createdAt: Date;
  expiresAt: Date;
}
```

**Share Token：**
```typescript
interface ShareToken {
  token: string;
  resourceType: 'asset' | 'book';
  resourceId: string;
  password?: string;
  expiresAt: Date;
  accessCount: number;
  maxAccess?: number;
}
```

**安全边界：**
- 用户只能访问自己session关联的资源
- Share token有明确的过期时间和访问次数限制
- 私有资源通过Supabase Storage signed URL访问

### 阶段3：0.9 Agent增强（2-3周）

**目标：** 提升Agent生成质量和可观察性

#### Runner抽象化

**接口设计：**
```typescript
interface AgentRunner {
  name: string;
  version: string;
  
  // 核心方法
  generateBook(workspace: AgentWorkspace): Promise<GenerationResult>;
  validateOutput(output: BookOutput): ValidationResult;
  
  // 可观察性
  getStatus(): RunnerStatus;
  getLogs(): LogEntry[];
  
  // 配置
  configure(config: RunnerConfig): void;
}
```

**实现类：**
- `MockRunner` - 测试和开发用
- `ClaudeRunner` - 基于Claude Agent SDK
- `CodexRunner` - 基于OpenAI Codex（待完善）

#### 可观察性增强

**日志系统：**
```typescript
interface LogEntry {
  timestamp: Date;
  level: 'info' | 'warn' | 'error';
  stage: 'init' | 'processing' | 'validation' | 'complete';
  message: string;
  metadata?: Record<string, any>;
}
```

**桌面端展示：**
- 实时日志流显示
- 生成进度指示器
- 错误详情和建议修复方案
- 输出预览和校验结果

#### 稳定性提升

**重试机制：**
```typescript
interface RetryConfig {
  maxAttempts: number;
  backoffStrategy: 'linear' | 'exponential';
  retryableErrors: string[];
}
```

**输出校验：**
- JSON schema验证
- 必需字段检查
- 素材引用完整性验证
- 输出格式规范检查

**错误恢复：**
- 自动重试失败的生成任务
- 部分输出保存和恢复
- 降级策略（使用备用Runner）

### 阶段4：1.0发布准备（2-3周）

**目标：** 达到开源稳定版发布标准

#### 安装体验优化

**Fresh Setup流程：**
1. 环境检查脚本
2. 依赖自动安装
3. 数据库初始化
4. 配置向导
5. 示例数据导入

**安装脚本：**
```bash
#!/bin/bash
# install.sh - KidMemory一键安装脚本

# 检查系统要求
check_requirements() {
  # Node.js 22+
  # PostgreSQL with pgvector
  # Flutter SDK
}

# 安装依赖
install_dependencies() {
  # npm install
  # flutter pub get
  # 数据库初始化
}

# 配置向导
setup_config() {
  # 生成.env文件
  # 配置API keys
  # 设置存储路径
}
```

#### 数据管理功能

**备份功能：**
```typescript
interface BackupService {
  createBackup(): Promise<BackupResult>;
  restoreBackup(backupPath: string): Promise<RestoreResult>;
  listBackups(): BackupInfo[];
  validateBackup(backupPath: string): ValidationResult;
}
```

**Migration管理：**
```typescript
interface MigrationService {
  getCurrentVersion(): string;
  getAvailableMigrations(): Migration[];
  runMigration(targetVersion: string): Promise<MigrationResult>;
  rollbackMigration(targetVersion: string): Promise<RollbackResult>;
}
```

#### 发布准备

**打包构建：**
- macOS应用程序包(.app)
- 代码签名和公证
- 自动更新机制
- 安装器制作

**文档完善：**
- 用户安装指南
- 开发者贡献指南
- API文档
- 故障排除手册

**质量保证：**
- 完整的端到端测试
- 性能基准测试
- 安全审计
- 兼容性测试

## 风险控制

### 技术风险
- **Agent输出不稳定** - 通过多层校验和降级策略缓解
- **数据迁移风险** - 提供完整的备份恢复机制
- **依赖兼容性** - 锁定关键依赖版本，提供环境检查

### 项目风险
- **功能范围蔓延** - 严格按照PRD执行，避免添加计划外功能
- **质量vs进度** - 每个阶段都有明确的验收标准
- **用户体验一致性** - 建立设计规范和组件库

### 缓解策略
- 每个阶段独立测试和验证
- 关键功能提供回滚方案
- 持续集成和自动化测试
- 定期的代码审查和架构评估

## 成功标准

### 阶段性目标
- **0.8收口**：文档统一，核心功能稳定
- **0.6完成**：手机端可用，用户体验完整
- **0.9完成**：Agent质量可靠，可观察性良好
- **1.0发布**：安装简单，文档完善，质量稳定

### 最终目标
- 用户可以按照文档完成fresh setup
- 核心功能稳定运行，错误率低于1%
- 手机端和桌面端体验一致
- 开源社区可以参与贡献

## 时间规划

| 阶段 | 预计时间 | 关键里程碑 |
|------|----------|------------|
| 0.8收口 | 1-2周 | 文档统一，验收完成 |
| 0.6实现 | 2-3周 | 手机端功能可用 |
| 0.9增强 | 2-3周 | Agent质量提升 |
| 1.0准备 | 2-3周 | 发布就绪 |
| **总计** | **8-11周** | **稳定版发布** |

## 结论

本设计采用渐进式完善策略，在保证质量的前提下逐步完成剩余功能。每个阶段都有明确的目标和交付物，便于跟踪进度和控制风险。最终目标是发布一个稳定、完整、易用的开源版本。