## ADDED Requirements

### Requirement: Controller 必须使用标准 NestJS 装饰器

系统 SHALL 将所有 Controller 从手动装饰器注册改为标准 NestJS 装饰器（@Controller、@Post、@Get、@Body、@Param 等）。

#### Scenario: 使用 @Controller 装饰器
- **WHEN** 定义 Controller 类
- **THEN** 必须使用 @Controller('prefix') 装饰器

#### Scenario: 使用 @Post/@Get 装饰器
- **WHEN** 定义路由方法
- **THEN** 必须使用 @Post('path') 或 @Get('path') 装饰器

#### Scenario: 使用 @Body/@Param 装饰器
- **WHEN** 定义方法参数
- **THEN** 必须使用 @Body()、@Param('id')、@Query() 等装饰器

#### Scenario: 禁止手动调用 Post/Get
- **WHEN** 检查 Controller 代码
- **THEN** 不能出现 `Post(...)(proto, ...)` 这样的手动调用

### Requirement: Service 必须使用标准 @Injectable

系统 SHALL 将所有 Service 从手动 registerInjectable 改为标准 @Injectable() 装饰器。

#### Scenario: 使用 @Injectable 装饰器
- **WHEN** 定义 Service 类
- **THEN** 必须使用 @Injectable() 装饰器

#### Scenario: 使用 constructor 注入
- **WHEN** Service 依赖其他 Service
- **THEN** 必须通过 constructor 参数注入

#### Scenario: 禁止使用 registerInjectable
- **WHEN** 检查 Service 代码
- **THEN** 不能出现 `registerInjectable(...)` 调用

### Requirement: 必须删除手动注册相关代码

系统 SHALL 删除 `registerInjectable` 函数和相关的手动注册代码。

#### Scenario: 删除 registerInjectable 函数
- **WHEN** 检查代码库
- **THEN** 不能存在 `infrastructure/nest/register-injectable.ts` 文件

#### Scenario: 删除 check-sidecar-runtime-imports 脚本
- **WHEN** 检查 package.json scripts
- **THEN** 不能存在 `check-sidecar-runtime-imports` 脚本

### Requirement: dev 命令必须使用 tsx watch

系统 SHALL 将 `dev` 命令从直接运行 TypeScript 改为使用 `tsx watch src/main.ts`。

#### Scenario: dev 命令使用 tsx
- **WHEN** 运行 `npm run dev`
- **THEN** 必须执行 `tsx watch src/main.ts`

#### Scenario: 支持热重载
- **WHEN** 修改源码文件
- **THEN** tsx 自动重启服务

### Requirement: build:prod 必须使用 tsc

系统 SHALL 保持 `build:prod` 命令使用 `tsc` 编译，输出到 `dist/` 目录。

#### Scenario: build:prod 使用 tsc
- **WHEN** 运行 `npm run build:prod`
- **THEN** 必须执行 `tsc -p tsconfig.build.json`

#### Scenario: 输出到 dist 目录
- **WHEN** build:prod 完成
- **THEN** 编译产物在 `dist/` 目录

#### Scenario: start:prod 运行编译产物
- **WHEN** 运行 `npm run start:prod`
- **THEN** 必须执行 `node dist/main.js`

### Requirement: 必须按模块顺序迁移

系统 SHALL 按照复杂度从低到高的顺序迁移模块：ConfigModule → DatasetModule → BooksModule → WebCompanionModule。

#### Scenario: 先迁移 ConfigModule
- **WHEN** 开始迁移
- **THEN** 第一个迁移 ConfigModule（最简单）

#### Scenario: 每个模块迁移后立即测试
- **WHEN** 完成一个模块迁移
- **THEN** 必须运行该模块的测试，确保通过

#### Scenario: 最后迁移 WebCompanionModule
- **WHEN** 迁移顺序
- **THEN** WebCompanionModule 最后迁移（最复杂）

### Requirement: 必须更新 architecture tests

系统 SHALL 更新 architecture tests，删除对手动注册的检查，增加对标准装饰器的检查。

#### Scenario: 检查 Controller 使用装饰器
- **WHEN** 运行 architecture tests
- **THEN** 必须检查所有 Controller 使用 @Controller 装饰器

#### Scenario: 检查 Service 使用 @Injectable
- **WHEN** 运行 architecture tests
- **THEN** 必须检查所有 Service 使用 @Injectable 装饰器

#### Scenario: 禁止手动注册
- **WHEN** 运行 architecture tests
- **THEN** 必须检查代码中不存在 registerInjectable 调用

### Requirement: 必须保持测试通过

系统 SHALL 确保每个模块迁移后，所有测试都能通过。

#### Scenario: 单元测试通过
- **WHEN** 完成模块迁移
- **THEN** 该模块的单元测试必须通过

#### Scenario: 集成测试通过
- **WHEN** 完成模块迁移
- **THEN** 该模块的集成测试必须通过

#### Scenario: 端到端测试通过
- **WHEN** 完成所有模块迁移
- **THEN** 端到端测试必须通过
