## Repository Simplification Pass - 2026-05-31

**目标**：先对全仓做冗余扫描，并落地可由现有测试/静态检查证明的低风险精简。

**设计决策**：选择先删除无调用 helper、重复实现、无用导入和 lint suppression，而不是直接删除公共入口或整目录；原因是整目录、兼容 API 和跨包合同删除需要单独确认删除清单和兼容风险。

**偏差说明**：用户目标是“全仓能简化的都简化”。本轮只完成第一批可验证源码精简，没有删除 `CLAUDE.md`、`.claude/`、本地 build 目录或云端 legacy job enum。

**权衡分析**：
- 方案一：先做源码内可证明的局部精简。优点是风险低、测试覆盖明确；缺点是不能一次性清完所有历史包袱。
- 方案二：直接删除历史目录和兼容字段。优点是改动更激进；缺点是会破坏 Claude/Codex 工作流入口或跨包 API 合同。
- 选择方案一，因为：本仓库协作约定要求破坏性删除前先列清单确认。

**旧决策项**：
- 不再待用户决策：是否删除或合并 `CLAUDE.md` 与 `.claude/` 历史工作流入口？
- 不再待用户决策：是否清理未跟踪的 `packages/desktop/build` 与 `packages/desktop/macos/build` 本地构建产物？
- 不再待用户决策：是否移除 cloud/sidecar legacy job 类型和对应 OpenAPI/协议生成物？

## Archived Sidecar Typing Passes - 2026-05-31

**目标**：从主 `implementation-notes.md` 迁出较早的 Sidecar 测试 typing 记录，保持主文件可维护。

**归档条目**：
- Agent Config Runtime Provider Boundary Pass：把 provider 运行时输入建模为 `string`，实体内部收窄。
- Sidecar Integration Test Typing Pass：用 `unknown` 错误 helper 和 typed validation result 替换 integration 测试中的 `any`。
- Sidecar Share Token Repository Double Typing Pass：显式建模 share-token SQL mock row/result。
- Direct Upload Provider Test Double Typing Pass：用 pullback row 类型和构造器参数约束 Prisma fake。
- Direct Upload Security Test Dependency Typing Pass：收窄 DirectUploadService config 依赖并表达缺失 pullback request 边界。
- Signed Upload Test Fixture Typing Pass：收窄 signed upload 配置依赖并类型化 fixture。

**旧决策项**：
- 不再待用户决策：是否继续处理未跟踪的 `browse-service-repository.test.ts`？

## Web Companion Route Contract Typing Pass - 2026-05-31

**目标**：清理 `route-contract.test.ts` 里的 controller 空依赖和 provider fixture `as any`。

**设计决策**：选择用 `WebCompanionService`、`BrowseService`、`ShareTokenService` 的具体类型标注空依赖，并用 `StorageProvider.SUPABASE` 替代裸字符串强转；原因是该测试只验证方法 arity 和 DTO 形状，不需要运行依赖。

**偏差说明**：没有删除或重写这个 route contract 测试；虽然它仍通过读取 controller source 验证手动装饰器，但删除测试文件需要先确认。

**权衡分析**：
- 方案一：局部类型化现有 contract 测试。优点是删除类型逃逸，改动小；缺点是测试仍保留 source-string contract 检查。
- 方案二：改成 Nest metadata 行为测试。优点是更贴近运行时；缺点是要引入更完整 Nest 测试模块，扩大验证面。
- 选择方案一，因为：当前目标是持续删除可证明冗余，不改变路由契约测试策略。

**旧决策项**：
- 不再待用户决策：是否后续把 route contract source-string 测试改成 Nest metadata 测试？
- 不再待用户决策：是否继续清理 Web Companion controller/service 测试里的 `any`？

## Web Companion Search Indexing Dependency Typing Pass - 2026-05-31

**目标**：清理 `search-indexing.test.ts` 里构造 dataset domain service 所需的 `as any`。

**设计决策**：选择把 `createDatasetService` 的依赖收窄为 `activatePersistent/current` 和 `paths.dataDir`，并在测试中用 typed config helper 与 `Object.assign` 构造 retryable error；原因是 dataset domain 实际只需要这些能力，不应要求完整 Nest service 类型。

**偏差说明**：没有改变索引行为、embedding 维度或 retry/backoff 策略；所有验证都走内存 dataset 和单元测试路径。

**权衡分析**：
- 方案一：收窄 domain factory 依赖到最小能力。优点是删除测试类型逃逸，生产依赖更明确；缺点是 domain factory 类型多一个局部结构。
- 方案二：只在测试中改成 `unknown as DatasetStateService`。优点是生产代码不动；缺点是继续隐藏 domain 实际依赖。
- 选择方案一，因为：它让测试和生产边界同时变简单。

**旧决策项**：
- 不再待用户决策：是否继续清理 Web Companion service/controller 测试里的 `any`？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？

## Web Companion Controller Test Double Typing Pass - 2026-05-31

**目标**：清理 `web-companion.controller.test.ts` 里的宽泛 service mock、空 browse/share 依赖和 `err: any`。

**设计决策**：选择把 `WebCompanionController` 构造器依赖收窄为 controller 实际调用的方法集合，并在单测里用 typed async spy 记录调用；原因是 controller 不需要完整服务实例，测试也不需要依赖 Node mock 的宽泛函数签名。

**偏差说明**：把“service 返回 ErrorResponse”的旧测试改为真实错误抛出路径；这更贴近当前 controller 的 `handleError` 行为。

**权衡分析**：
- 方案一：收窄 controller 依赖并类型化测试 spy。优点是删除 `any`，同时让 controller 依赖面更小；缺点是测试文件维护一个小型 async spy helper。
- 方案二：继续把 mockService 作为 `any` 传入。优点是短；缺点是隐藏 controller 方法调用合同，也让旧错误返回模式继续存在。
- 选择方案一，因为：它同时减少测试冗余和生产构造边界。

**旧决策项**：
- 不再待用户决策：是否继续清理 `web-companion-service.test.ts` 的 query-backed fake？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？

## Creation Service Test Double Typing Pass - 2026-05-31

**目标**：清理 `creation-service.test.ts` 里的 `Record<string, any>` 和构造 `CreationService` 时的 `as any`。

**设计决策**：选择把内存 Prisma stub 拆成明确的 `TaskInput/TaskRecord`、`ArtifactInput/ArtifactRecord`、`EventInput/EventRecord` 类型，并给 agent runtime fake 一个最小 typed port；原因是这些测试只需要创建、查询和更新 creation 记录，不需要完整 Prisma/AgentRuntime 实例。

**偏差说明**：没有改变 CreationService 的业务逻辑、PDF 导出路径或 agent stage 行为；构造真实 Nest 依赖的位置仍由运行时 DI 管理，单测只用内存 stub。

**权衡分析**：
- 方案一：类型化现有内存 stub。优点是删除 `any`，保留现有行为测试和真实 PDF 文件验证；缺点是测试文件多了几个局部记录类型。
- 方案二：实例化真实 PrismaService 并覆盖 delegate。优点是构造签名少转换；缺点是引入 Prisma 客户端对象和潜在外部配置干扰。
- 选择方案一，因为：它保持测试轻量、无数据库依赖，同时让 stub 的数据形状显式。

**旧决策项**：
- 不再待用户决策：是否后续把 CreationService 构造器也收窄为显式 port 类型？
- 不再待用户决策：是否继续清理 `cloud-sync.test.ts` 和 `web-companion-service.test.ts` 中的剩余私有方法访问？

## Browse Controller Test Double Typing Pass - 2026-05-31

**目标**：清理 `browse-controller.test.ts` 里的 request/response/service `any`，并保持 pullback worker smoke test 的最小 typed 形态。

**设计决策**：选择改为直接实例化 `WebCompanionController`，并从 controller 构造器参数推导 `BrowseServiceDouble`；原因是原测试只模拟 controller 逻辑，真实 controller 调用能删除 request/response fake 并提高覆盖价值。

**偏差说明**：没有引入完整 Nest TestingModule 或 metadata 断言；本轮使用 controller 实例和 typed service double 覆盖 browse endpoint 行为。

**权衡分析**：
- 方案一：直接实例化 `WebCompanionController`。优点是删除模拟 request/response 逻辑，测试覆盖真实方法和错误映射；缺点是需要提供另外两组 unused service doubles。
- 方案二：只局部类型化旧模拟测试。优点是改动最小；缺点是继续测试复制出来的 controller-like 逻辑。
- 选择方案一，因为：它在不引入 Nest TestingModule 的前提下同时减少冗余和提高测试可信度。

**旧决策项**：
- 不再待用户决策：是否后续将 browse endpoint 用例合并进 `web-companion.controller.test.ts`？
- 不再待用户决策：是否继续清理 `commit-idempotency.test.ts` / `pullback-idempotency.test.ts` 的 service 依赖强转？

## Web Companion Idempotency Dependency Typing Pass - 2026-05-31

**目标**：清理 `commit-idempotency.test.ts` 和 `pullback-idempotency.test.ts` 里的 service 依赖 `as any`、重复 config/repository fixture 和私有方法 `as any`。

**设计决策**：选择复用 typed `WebCompanionRepository` factory、`WebCompanionService` constructor 参数推导出的 config/dataset 类型，以及一个 `PullbackWorkerSurface` 测试探针；原因是这两组测试只需要 repository 的少量方法，但应当让未使用方法显式失败而不是通过 `any` 隐藏。

**偏差说明**：pullback 正向路径仍因 mock storage/fetch 限制预期失败后断言状态更新尝试；没有真实下载 Supabase 对象，也没有真实导入 DatasetService。

**权衡分析**：
- 方案一：类型化测试工厂并保留现有行为断言。优点是删除 `any`，降低重复 fixture；缺点是私有 pullback worker 仍通过 typed surface 探针访问。
- 方案二：改成公开 pullback API 行为测试。优点是避免私有方法访问；缺点是要构造 direct-upload 会话、对象列表和存储 provider，改动更大。
- 选择方案一，因为：它保持当前测试边界，同时把依赖形状和 idempotency 行为表达清楚。

**旧决策项**：
- 不再待用户决策：是否后续把 pullback worker 的私有方法测试迁移到公开 pullback endpoint/worker port？
- 不再待用户决策：是否继续清理 `web-companion-service.test.ts` 的 query-backed fake？

## Test Placeholder Simplification Pass - 2026-05-31

**目标**：删除或替换只记录计划、占位或重复覆盖的测试，让单元测试直接约束生产代码行为。

**设计决策**：选择将 Sidecar 和 Cloud API 的占位测试改为生产模块行为测试，并用架构测试阻止新增 placeholder；原因是静态“文档型”测试会制造维护噪音，却不能捕获回归。

**偏差说明**：未扩大到生成物里的 lint suppression 清理；这些文件由 OpenAPI 生成器维护，直接手改会被下次生成覆盖。

**权衡分析**：
- 方案一：删除重复占位测试，保留或补强已有行为测试。优点是减少冗余且保留回归保护；缺点是需要确认已有测试覆盖同一风险。
- 方案二：保留占位测试作为历史说明。优点是改动少；缺点是测试套件继续携带无断言噪音。
- 选择方案一，因为：本轮已补充架构约束和生产模块导入检查。

**旧决策项**：
- 不再待用户决策：是否继续清理生成协议代码的 suppression 源头配置？
- 不再待用户决策：是否进一步移除 legacy job API 合同？

## Typed Boundary Simplification Pass - 2026-05-31

**目标**：继续清理 Web、Sidecar、Cloud API 中可验证的历史兼容层、double cast、lint suppression 和历史命名测试。

**设计决策**：选择保留公开导出名称但删除内部兼容实现，例如 `httpClient` 仍导出但不再通过 Proxy 懒加载；原因是这样能删除历史维护层，同时不要求调用方迁移。

**偏差说明**：没有手工修改 Flutter l10n 和协议 generated 文件里的 suppression；这些属于生成物。Sidecar legacy cloud job 合同也未删除，因为它影响跨包 API/同步语义，仍需删除清单确认。

**权衡分析**：
- 方案一：清理实现内部类型边界和手写测试历史文件。优点是风险低、测试可直接证明；缺点是仍保留部分公共兼容合同。
- 方案二：立即删除所有 legacy job/API/generated 合同。优点是历史包袱更少；缺点是会破坏现有同步和协议消费者。
- 选择方案一，因为：当前仓库规则要求公共入口和跨包合同删除前先确认范围。

**旧决策项**：
- 不再待用户决策：是否允许删除 cloud/sidecar legacy job 同步合同及生成协议？
- 不再待用户决策：是否允许清理本地未跟踪构建目录以恢复完整 Flutter analyze？

## Naming And Bundle Simplification Pass - 2026-05-31

**目标**：继续移除非公共合同里的历史命名和兼容路径，减少全仓 legacy 噪音。

**设计决策**：选择将 Web i18n `uploadLegacy` namespace 改为 `upload`，并删除桌面 release 打包脚本对旧 `sidecar/sql` 布局的拷贝；原因是这些不是外部 API，且现有测试能证明调用方和打包脚本改动。

**偏差说明**：保留了测试里用于证明旧入口已移除的 legacy 文案，也保留了 PDF.js 官方 `legacy/build` 导入路径。

**权衡分析**：
- 方案一：只改内部命名和 release bundle 历史分支。优点是清理真实维护噪音且风险低；缺点是 grep 仍会看到负向测试中的 legacy。
- 方案二：重写所有测试文案避免 legacy 字样。优点是 grep 更干净；缺点是会削弱“旧入口已移除”的测试意图。
- 选择方案一，因为：测试中的 legacy 是当前约束语义，不是运行时代码包袱。

**旧决策项**：
- 不再待用户决策：是否删除 legacy cloud job 同步合同？
- 不再待用户决策：是否删除 Claude 历史入口文件/目录？

## Explicit Runtime Dependency Simplification Pass - 2026-05-31

**目标**：删除 Sidecar 中已被替代的请求日志中间件，并移除 Web Companion 关闭会话时对全局变量的依赖。

**设计决策**：选择保留 `TraceRequestLoggingMiddleware` 作为唯一请求日志实现，并将 `SessionQuotaMiddleware` 通过 Nest factory 注入 `WebCompanionService`；原因是两者都是现有生产 provider，显式依赖比 `global as any` 更容易测试和维护。

**偏差说明**：没有重写大量测试中的 `as any` mock；这些属于测试替身边界，适合后续按模块逐步收窄。

**权衡分析**：
- 方案一：删除孤立旧中间件，并把 session quota 释放改为 DI。优点是删除真实冗余和全局状态；缺点是需要更新模块 factory 注入列表。
- 方案二：只加注释保留旧全局桥接。优点是改动更少；缺点是继续留下隐藏 runtime 依赖。
- 选择方案一，因为：架构测试、lint、type-check 和 sidecar unit 都能覆盖该变更。

**旧决策项**：
- 不再待用户决策：是否继续按模块清理测试 mock 里的 `as any`？
- 不再待用户决策：是否删除 legacy cloud job 同步合同？

## Typed Boundary And Test Artifact Simplification Pass - 2026-05-31

**目标**：继续清理 Sidecar 的测试占位、例行日志和可消除的生产 `any` 边界。

**设计决策**：先用架构测试捕捉占位测试、未类型化 Express mock、例行 stdout 日志和简单生产边界 `any`，再收紧实现；只处理能用局部测试验证的文件。

**偏差说明**：没有全局删除所有测试 double 中的 `any`，因为部分 mock 覆盖 Prisma/Nest 私有边界，盲目收紧会扩大重构范围。

**权衡分析**：
- 方案一：全仓库强制禁止 `any`。优点是规则简单；缺点是会误伤生成类型、复杂测试 double 和渐进迁移边界。
- 方案二：对当前可简化生产文件加定点护栏。优点是风险小、验证清晰；缺点是仍保留一部分测试 mock 技术债。
- 选择方案二，因为：本轮目标是删掉明确冗余和低风险历史痕迹，而不是重写所有测试基础设施。

**旧决策项**：
- 不再待用户决策：是否继续投入一轮专门清理测试 double 类型？
- 不再待用户决策：是否调整 Flutter analyzer 配置，排除 `build/` 和 `macos/build/` 生成产物？

## Analyzer And Runtime Noise Simplification Pass - 2026-05-31

**目标**：继续减少生成产物噪音、例行 stdout 日志和手写生产代码里的宽泛类型边界。

**设计决策**：通过桌面架构测试要求 analyzer 排除 `build/**` 与 `macos/build/**`，并通过 Sidecar 架构测试禁止 Web Companion、session quota 与 rate-limit cleanup 的 routine `console.log`；原因是这些输出不承载业务语义，只会污染测试和运行日志。

**偏差说明**：`flutter analyze` 仍有 74 个 `use_build_context_synchronously` info，未在本轮一次性修完；这些涉及多条 setup/sidecar async UI 流程，需要按工作流逐段验证。

**权衡分析**：
- 方案一：用 analyzer exclude 去掉生成目录，并逐步修源码问题。优点是信号更真实；缺点是仍要继续处理现有 async context lint。
- 方案二：直接关闭 `use_build_context_synchronously`。优点是 analyze 立即安静；缺点是掩盖真实 lifecycle 风险。
- 选择方案一，因为：本轮目标是删除冗余和收紧边界，不是用配置隐藏风险。

**旧决策项**：
- 不再待用户决策：是否继续专项修复桌面端 async `BuildContext` lint？
- 不再待用户决策：是否将 Sidecar 启停日志迁移到 Nest Logger，替代剩余 bootstrap `console.log`？

## Desktop Analyzer Simplification Pass - 2026-05-31

**目标**：清理桌面端剩余源码 analyzer 噪音，让 `flutter analyze` 只检查真实源码且无 `BuildContext` async gap 提示。

**设计决策**：选择缓存 `AppLocalizations` 和固定标题/提示文案，并在 async 返回后、继续更新 UI 前增加 mounted guard；原因是这些变更保留现有用户文案和流程，同时删除重复 `AppLocalizations.of(context)!` 调用和 lifecycle 风险。

**偏差说明**：没有关闭 `use_build_context_synchronously` lint，也没有把 setup workflow 重构成新的控制器；本轮只做低风险、局部可验证的简化。

**权衡分析**：
- 方案一：逐个文件缓存局部 UI 文案并保留现有流程。优点是改动小，`flutter analyze` 和现有 widget tests 能覆盖；缺点是 setup action 仍是 extension 组织。
- 方案二：一次性抽出独立 setup controller。优点是长期结构更清晰；缺点是会扩大公共状态边界和测试迁移范围。
- 选择方案一，因为：当前目标是删除冗余和 analyzer 噪音，不是重新设计桌面 setup 架构。

**旧决策项**：
- 不再待用户决策：是否继续把 setup action extension 抽成更明确的状态/服务边界？
- 不再待用户决策：是否将 Sidecar 剩余 bootstrap `console.log` 迁移到 Nest Logger？

## Sidecar Bootstrap And Browse Test Simplification Pass - 2026-05-31

**目标**：继续清理 Sidecar 剩余 stdout 日志和测试 double 中的宽泛类型边界。

**设计决策**：选择用 Nest `Logger("SidecarBootstrap")` 替代 `main.ts` 里的 bootstrap `console.log`，并让 `browse-service.test.ts` 的 fake repository 直接使用 `BrowseRepository` 的领域记录类型；原因是这样删除了一层模拟数据库字段映射，同时保留服务行为测试。

**偏差说明**：没有删除未跟踪的 `browse-service-repository.test.ts`，因为删除测试文件需要先确认删除清单；本轮只收紧已跟踪测试和生产入口日志。

**权衡分析**：
- 方案一：先收紧已跟踪测试 double 和 bootstrap 日志。优点是风险低、能用架构测试证明；缺点是仍保留一个旧决策项的测试文件清理点。
- 方案二：直接删除重复的 repository 风格测试文件。优点是删得更多；缺点是仓库规则要求删除测试文件前先确认。
- 选择方案一，因为：当前能继续推进简化，同时不越过删除确认边界。

**旧决策项**：
- 不再待用户决策：是否允许删除或合并 `packages/sidecar/tests/unit/modules/web-companion/browse-service-repository.test.ts`？
- 不再待用户决策：是否允许删除 Claude 历史入口文件/目录和 legacy cloud job 同步合同？

## Agent Runtime Env And Sync Message Simplification Pass - 2026-05-31

**目标**：清理 agent-runtime 脚本测试里的旧 provider 专属环境变量 fixture，并移除 Sidecar sync 运行时错误里的历史 API 说法。

**设计决策**：选择保留通用 `OPENAI_*` provider 配置测试，并增加脚本测试守卫防止 `OPENROUTER_*` fixture 回流；Sidecar cloud job 错误改为描述当前事实：这些 job 不由 Sidecar sync 执行，应走 creation task 路径。

**偏差说明**：没有删除 OpenRouter 作为 provider host 的诊断/trace 测试，因为那不是旧 env 兼容层，而是当前 OpenAI-compatible provider 行为。

**权衡分析**：
- 方案一：删除旧 env fixture，只保留通用 provider 配置。优点是减少历史维护点；缺点是少了对已移除 env 名称的负向兼容测试。
- 方案二：继续保留旧 env fixture。优点是能证明旧变量被忽略；缺点是测试继续传播已废弃配置名。
- 选择方案一，因为：生产代码已不读取旧 env 名，继续在测试里维护它只会增加历史噪音。

**旧决策项**：
- 不再待用户决策：是否继续清理 Sidecar sync 测试 double 里的 `as any` 私有方法调用？
- 不再待用户决策：是否允许删除或合并未跟踪的 `browse-service-repository.test.ts`？

## Desktop Test Fake API Simplification Pass - 2026-05-31

**目标**：删除桌面端 app 测试里未使用的 fake Sidecar API，去掉 `unused_element` suppressions。

**设计决策**：选择新增静态架构测试并删除未引用的私有 fake 类，而不是继续保留 analyzer suppression；原因是这些类只剩定义，没有调用点，保留会掩盖真实死代码。

**偏差说明**：原目标是仓库级简化；本次只处理桌面端测试替身中的低风险死代码，避免扩大到需要确认的测试文件删除。

**权衡分析**：
- 方案一：删除未引用私有类。优点是最直接减少测试维护面；缺点是如果未来需要对应场景要重新构造测试替身。
- 方案二：保留类并继续 suppression。优点是零行为变化；缺点是继续留下死代码和静态检查例外。
- 选择方案一，因为：现有搜索确认没有引用点，且相关 app 测试仍通过。

**旧决策项**：
- 不再待用户决策：是否继续清理 Sidecar 测试中的 `any` test double？
- 不再待用户决策：是否确认删除或合并未跟踪的 browse-service-repository 测试文件？

## Child Profile Widget Key Simplification Pass - 2026-05-31

**目标**：删除 child profile widget 文件里的 `use_key_in_widget_constructors` 文件级 suppression。

**设计决策**：选择给各个 `StatelessWidget` 构造函数补 `super.key`，保留 `CustomPainter` 构造函数不变；原因是这样满足 Flutter lint，不改变 UI 结构或调用语义。

**偏差说明**：本次只处理 child profile widget 目录；生成的 l10n 文件和 MSW 文件中的 suppression 属于生成物/工具文件，暂不修改。

**权衡分析**：
- 方案一：删除 suppression 并补 key。优点是消除文件级例外，便于 analyzer 持续发现真实问题；缺点是构造函数签名有轻微机械变化。
- 方案二：继续保留 suppression。优点是改动少；缺点是会隐藏未来同类 lint。
- 选择方案一，因为：相关 widget 测试和 analyzer 都能直接验证。

**旧决策项**：
- 不再待用户决策：是否继续同样处理 asset library widgets 的 key constructor suppression？
- 不再待用户决策：是否进一步清理 Sidecar 测试 double 中的宽泛类型？


## Asset Library Widget Key Simplification Pass - 2026-05-31

**目标**：删除 asset library widget 文件里的 `use_key_in_widget_constructors` 文件级 suppression。

**设计决策**：沿用 child profile 的做法，给 asset library 的 `StatelessWidget` 构造函数补 `super.key`，并新增静态测试守卫防止 suppression 回流；原因是这些 widget 都是普通 UI 组件，传递 key 是 Flutter 约定。

**偏差说明**：没有修改生成的 l10n suppression 或 MSW 的 eslint suppression，因为它们属于生成文件或外部工具产物，不是业务冗余代码。

**权衡分析**：
- 方案一：补 key 并删除文件级 suppression。优点是 analyzer 规则保持有效；缺点是需要机械更新多个构造函数。
- 方案二：保留 suppression。优点是零改动；缺点是隐藏未来未传 key 的新 widget。
- 选择方案一，因为：静态测试、asset library widget 测试和 analyzer 都可验证。

**旧决策项**：
- 不再待用户决策：是否继续处理非生成文件里的 production `console.warn/error` 到统一 Logger？
- 不再待用户决策：是否清理或确认保留未跟踪的 browse-service-repository 测试文件？


## Cloud API Protocol DTO Simplification Pass - 2026-05-31

**目标**：把 Cloud API 的设备、任务、上传项和 Web Companion DTO 模块收敛为 protocol generated 类型别名，删除本地手写 DTO class。

**设计决策**：选择在 DTO 模块中引用 `@kidmemory/protocol/generated/cloud-api/ts`，控制器 Swagger 装饰器改用 schema `$ref`，避免为了文档再维护一套运行时 class；对当前 generated schema 过窄的 `SessionSummary` 和 `ShareTokenValidation` 保留最小类型细化。

**偏差说明**：本次没有重新生成协议文件；仓库级测试只验证当前源码、构建、运行 smoke 和既有协议产物一致性。

**权衡分析**：
- 方案一：DTO 模块只保留协议类型别名。优点是消除重复模型定义；缺点是 Swagger 装饰器不能再直接引用 DTO class。
- 方案二：继续保留本地 class。优点是 Swagger 生成字段更直接；缺点是继续维护两套 API 类型。
- 选择方案一，因为：已有架构测试明确要求 DTO 模块别名协议类型，且仓库级脚本通过。

**旧决策项**：
- 不再待用户决策：是否后续增强 OpenAPI 生成脚本，从 protocol schema 回填 `$ref` 对应 components？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Cloud API Logger Simplification Pass - 2026-05-31

**目标**：清理 Cloud API 生产源码里的裸 `console.warn/error`，统一通过 Nest Logger 输出基础设施日志。

**设计决策**：选择给 bootstrap、PrismaService 和 GlobalExceptionFilter 使用 `Logger`，并增加架构测试禁止 Cloud API `src` 继续使用 `console.log/warn/error`；原因是服务端日志应走框架 logger，避免 stdout/stderr 直写散落在基础设施层。

**偏差说明**：没有处理 Sidecar 仍存在的业务错误日志；本轮只处理 Cloud API，因为它能用单一架构测试闭环验证。

**权衡分析**：
- 方案一：Cloud API `src` 全面禁止裸 console。优点是规则清晰，后续不回流；缺点是未来 CLI 风格入口若放进 `src` 需要改规则。
- 方案二：只替换当前三处，不加守卫。优点是改动少；缺点是同类日志容易重新出现。
- 选择方案一，因为：Cloud API `src` 是 Nest 服务代码，不是 CLI 输出面。

**旧决策项**：
- 不再待用户决策：是否继续按同样方式清理 Sidecar 剩余业务/安全日志？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Archived Implementation Notes Batch - 2026-05-31

## Sidecar Infrastructure Logger Simplification Pass - 2026-05-31

**目标**：继续清理 Sidecar 基础设施层和 dataset 服务里的裸 `console.warn/error/info`。

**设计决策**：选择给 security middlewares、GlobalExceptionFilter、DatasetState、DatasetService 和 asset metadata inference 使用 Nest `Logger`，并用架构测试分别约束 security、HTTP exception filter 和 dataset 相关文件；原因是这些都是服务端运行日志，不应散落为裸 console 输出。

**偏差说明**：Web Companion 服务、agent-config module 和 HTTP runtime config 仍有裸 console；本轮先处理能用局部架构测试和聚焦单元测试验证的基础设施/dataset 组。

**权衡分析**：
- 方案一：按模块分组迁移到 Nest Logger。优点是每组变更可验证、风险小；缺点是剩余服务日志还要继续清理。
- 方案二：一次性全 Sidecar 禁止 console。优点是规则最简单；缺点是会同时触及 Web Companion 业务错误日志和模块启动配置边界，验证面更大。
- 选择方案一，因为：当前目标是持续删冗余，保持每步有红绿测试保护。

**旧决策项**：
- 不再待用户决策：是否继续清理 Web Companion 服务和 agent-config module 的裸 console 日志？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Sidecar Source Logger Completion Pass - 2026-05-31

**目标**：清理 Sidecar `src` 剩余裸 `console.*` 输出，统一生产源码日志入口。

**设计决策**：选择新增全 `src` 架构测试禁止 `console.log/warn/error/info`，并把 HTTP runtime CORS 提示、agent-config 开发密钥提示迁移到 Nest `Logger`；原因是 Sidecar `src` 是服务端运行代码，日志应由框架统一管理。

**偏差说明**：本轮只处理生产源码日志；测试里的断言、脚本和 CLI 风格输出不纳入这条 Sidecar `src` 规则。

**权衡分析**：
- 方案一：全 `src` 建立 no-console 守卫。优点是能防止同类冗余日志回流；缺点是未来若在 `src` 放 CLI 入口需要显式调整规则。
- 方案二：只替换当前剩余两处文件。优点是改动更少；缺点是没有长期保护。
- 选择方案一，因为：当前 Sidecar 生产源码已经全部迁到 Nest Logger，可以用单一规则稳定约束。

**旧决策项**：
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？
- 不再待用户决策：是否继续清理测试代码中的 `any` 和历史兼容分支？


## Sidecar Test Double Typing Simplification Pass - 2026-05-31

**目标**：继续清理 Sidecar 测试替身里的宽泛 `any`，先处理小而独立的 asset preview、trace propagation 与 creation contract 测试。

**设计决策**：选择为三个测试文件增加架构守卫，并用 `DatasetService`/`Response`、Express `Request`/`Response`/`NextFunction` 交叉类型、creation store record 类型替代 `as any` 和 `: any`；原因是这些测试替身边界明确，可以提升类型信号而不重写业务逻辑。

**偏差说明**：本轮没有全局禁止 Sidecar tests 的 `any`，因为 Prisma/Nest 复杂 mock 仍需要逐模块收敛；也没有处理未跟踪的 browse-service-repository 测试文件。

**权衡分析**：
- 方案一：按小文件加定点守卫。优点是红绿验证清晰，避免大规模测试重写；缺点是剩余测试 double 仍有宽泛类型。
- 方案二：一次性禁止 tests 目录全部 `any`。优点是规则彻底；缺点是会同时触碰大量复杂 mock，风险和验证成本过高。
- 选择方案一，因为：当前简化目标需要持续删除可证明的冗余，同时遵守测试文件删除和公共边界确认规则。

**旧决策项**：
- 不再待用户决策：是否继续逐模块清理 Sidecar 测试 double 的 `any`？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Sidecar Config And Security Test Double Typing Pass - 2026-05-31

**目标**：继续清理 Sidecar config/security 单测里的宽泛 `any` 测试替身。

**设计决策**：选择给 `config-service-singleton.test.ts`、`config-ui.test.ts`、`config.test.ts` 和 `security-middleware.test.ts` 增加架构守卫，并用 typed Prisma/migration stubs 与 Express `Request`/`Response` 断言替代 `as any`；原因是这些文件的依赖面小，能直接提升测试类型信号。

**偏差说明**：本轮没有处理 `share-token.test.ts` 中更大的数据库 mock；这些需要更细的 helper 抽取，避免一次重写过多测试基础设施。

**权衡分析**：
- 方案一：逐个小测试文件收紧替身类型。优点是红绿验证明确，lint/type-check 风险低；缺点是剩余 `any` 还需要后续分批处理。
- 方案二：抽一个全局测试 mock 工具并批量迁移。优点是最终重复更少；缺点是会扩大改动面，并可能和现有测试结构冲突。
- 选择方案一，因为：当前目标是持续删除可证明冗余，保持每步可验证。

**旧决策项**：
- 不再待用户决策：是否继续清理 `share-token.test.ts` 的数据库 mock？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Sidecar Dataset Worker Test Double Typing Pass - 2026-05-31

**目标**：继续清理 Sidecar dataset 单测里的宽泛 `any` 测试替身。

**设计决策**：选择给 `sample-dataset.test.ts`、`search-indexing.worker.test.ts`、`dataset-service-singleton.test.ts` 和 `dataset-domain.test.ts` 增加架构守卫，并用 `Child`/`SampleAsset`/`SampleDb`、`DatasetService["runSearchIndexer"]`、`AppConfigService` 与 typed `DatasetStateService` adapter 替代 `any`；原因是这些测试的 fake 数据结构直接对应生产类型，使用真实类型能减少重复维护。

**偏差说明**：本轮没有处理 sync 测试里对私有方法的调用，也没有处理 share-token 的数据库 mock；这些需要先评估是否应改为公开行为测试或专用 typed repository double。

**权衡分析**：
- 方案一：直接复用生产领域类型给小 fake 建模。优点是删除测试内重复宽类型，后续生产类型变化能被测试捕获；缺点是测试与当前领域类型耦合更直接。
- 方案二：保留 `any` fake。优点是写法短；缺点是绕过类型系统，容易让测试替身与真实接口漂移。
- 选择方案一，因为：这些测试已经围绕 sample dataset 和 worker 公开行为，复用生产类型更符合简化目标。

**旧决策项**：
- 不再待用户决策：是否继续清理 sync 测试里的私有方法调用？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？


## Cloud API Service Prisma Double Typing Pass - 2026-05-31

**目标**：清理 Cloud API 设备、任务和上传项服务单测里的 `as never` Prisma double。

**设计决策**：选择为 `DevicesService`、`JobsService`、`UploadItemsService` 暴露最小 Prisma client 接口，并让单测 helper 通过这些接口构造 fake；原因是这些服务只依赖各自 model delegate 的少数方法，不需要在构造边界绑定完整 `PrismaService` 类型。

**偏差说明**：没有改 Cloud API 路由、DTO 或 Prisma schema；本轮验证覆盖 unit/static 路径，没有连接真实 PostgreSQL。

**权衡分析**：
- 方案一：收窄服务构造依赖到实际 delegate 方法。优点是删除 `as never`，服务依赖更清楚；缺点是每个服务文件新增一个小接口。
- 方案二：在测试中继续强转完整 `PrismaService`。优点是生产文件不动；缺点是测试仍绕过类型系统，且隐藏服务真实依赖面。
- 选择方案一，因为：它符合最小依赖边界，也能让 architecture guard 防止宽泛测试 double 回流。

**旧决策项**：
- 不再待用户决策：是否继续处理 Cloud API 剩余 `as never` 测试 double？
- 不再待用户决策：是否配置真实 PostgreSQL 后运行 Cloud API 集成测试？


## Web HTTP Client Test Double Typing Pass - 2026-05-31

**目标**：清理 Web `http-client.test.ts` 里的 axios mock `as never`。

**设计决策**：选择定义显式 `MockAxiosInstance` 测试类型，并在 `axios.create` mock 边界只转换为 `AxiosInstance`；原因是测试需要 Vitest mock 方法能力，而 production `HttpClient` 只通过 axios 实例接口调用请求方法。

**偏差说明**：没有改 `HttpClient` runtime 行为；本轮没有做浏览器 UI 验证，因为变更只涉及单元测试 double 和静态类型。

**权衡分析**：
- 方案一：显式声明测试 mock 形状。优点是删除 `as never`，mock 的方法需求更清楚；缺点是测试文件维护一个小类型。
- 方案二：继续用 `as never` 让 axios mock 编译。优点是短；缺点是隐藏 mock 与 axios 实例接口之间的差异。
- 选择方案一，因为：它保留现有测试行为，同时去掉无意义的类型逃逸。

**旧决策项**：
- 不再待用户决策：是否继续处理 agent-runtime 剩余 `as never`？
- 不再待用户决策：是否需要为 Web 测试文件新增更通用的 no-`as never` 守卫？

## Agent Runtime OpenAI Tool Adapter Typing Pass - 2026-05-31

**目标**：清理 agent-runtime OpenAI tool adapter 和相邻测试里的 `as never`。

**设计决策**：选择从 `@openai/agents` 的 `tool()` 参数类型中提取 `strict:false` 分支的 `parameters` 类型，并在测试中用真实 `RunContext` 调用 `FunctionTool.invoke`；原因是这里的类型边界来自 SDK API，应该适配到 SDK 公开类型而不是通过 `never` 跳过检查。

**偏差说明**：没有修改 AgentTool schema 的运行时内容，也没有真实调用 OpenAI 服务；验证覆盖 SDK 本地适配、静态类型和 agent-runtime 全包测试。

**权衡分析**：
- 方案一：集中提取 SDK non-strict tool parameter 类型。优点是删除 `as never`，保留现有 schema 传递行为；缺点是仍在 SDK 边界有一次明确的参数类型适配。
- 方案二：把所有工具 schema 改成 SDK strict schema。优点是类型更强；缺点是会改变工具 schema 暴露方式和模型调用约束。
- 选择方案一，因为：当前目标是删掉无意义类型逃逸，不改变 agent runtime 行为。

**旧决策项**：
- 不再待用户决策：是否继续把 AgentTool schema 类型从 `unknown` 收窄为仓库自有 JSON schema 类型？
- 不再待用户决策：是否真实运行 OpenAI provider healthcheck 验证 SDK tool invocation？


## Sidecar Direct Upload Test Double Typing Pass - 2026-05-31

**目标**：清理 Direct Upload controller/provider 单测里的宽泛 `any` 与 `as never` 测试替身。

**设计决策**：选择给 controller 错误断言增加 `unknown` 捕获和结构化 assertion helper，并把 direct-upload provider 构造函数参数收窄到实际使用的 `DatasetService.importAssets` 与 `directUploadPullback` delegate；原因是 adapter 本身只依赖这两个最小边界，测试不应为了传入 fake 而绕过类型系统。

**偏差说明**：本轮没有改 Direct Upload 业务行为或数据库 schema；provider 单测仍使用内存 Prisma double，package build 运行的是静态/单元测试路径，不是真实 PostgreSQL。

**权衡分析**：
- 方案一：收窄生产构造边界并让测试 double 通过结构化类型校验。优点是删除 `any`/`as never`，也让 adapter 依赖更明确；缺点是 provider 文件新增了一个最小 Prisma delegate 接口。
- 方案二：只把测试里的 `any` 改成 `unknown as PrismaService`。优点是改动更少；缺点是保留类型逃逸，不能真正表达 adapter 需要的最小能力。
- 选择方案一，因为：它同时减少测试冗余和生产 adapter 的隐式依赖面。

**旧决策项**：
- 不再待用户决策：是否继续清理 sync 测试里的私有方法调用？
- 不再待用户决策：是否允许处理或删除未跟踪的 browse-service-repository 测试文件？

## Sidecar Cloud API Client Constructor Simplification Pass - 2026-05-31

**目标**：归档主 notes 中较早的 Sidecar Cloud API Client 构造器清理记录。

**设计决策**：`CloudApiClient` 删除未使用的 `AppConfigService` 构造依赖，测试改为直接 `new CloudApiClient()`；原因是该 client 当前只读取 `CLOUD_API_URL` / `CLOUD_API_TIMEOUT` 环境变量。

**偏差说明**：没有改变 Cloud-API 请求路径、超时逻辑或 env 配置来源；验证使用 fetch mock，没有真实调用 Cloud API。

## Web Companion Service Query Double Typing Pass - 2026-05-31

**目标**：清理 `web-companion-service.test.ts` 中 query-backed repository fake 的 `any`、重复错误断言和宽泛 app config/dataset double。

**设计决策**：选择引入局部 `QueryRow/QueryParam/QueryResult` 类型、统一 `assertErrorIncludes`，并用 `WebCompanionService` 构造器参数推导测试 config/dataset 类型；原因是该测试仍然验证 service 的 SQL-backed repository fake 行为，但不需要把 query rows 和错误对象退回到 `any`。

**偏差说明**：没有改变 WebCompanionService 生产行为；commit 上传测试仍会触发一次 mock pullback 失败日志，属于现有测试副作用，未在本轮引入真实 Supabase/fetch/DatasetService 调用。

**权衡分析**：
- 方案一：保留 query-backed fake 并显式类型化。优点是改动小、覆盖面不变、删除 `any`；缺点是测试仍有较多手写 SQL 字符串分支。
- 方案二：改成纯 `WebCompanionRepository` typed fake。优点是测试更短；缺点是会降低当前测试对 SQL-backed adapter 行为的覆盖。
- 选择方案一，因为：本轮目标是简化类型逃逸而非重写测试策略。

**旧决策项**：
- 不再待用户决策：是否后续把 query-backed fake 拆成共享测试 helper？
- 不再待用户决策：是否允许继续处理未跟踪的 `browse-service-repository.test.ts`？

## Cloud Sync Test Dependency Typing Pass - 2026-05-31

**目标**：清理 `cloud-sync.test.ts` 里的多依赖 `as any`、多余 `booksService` 实参，以及私有 `initializeSync/sleep` 的 `as any` 访问。

**设计决策**：选择用 `ConstructorParameters<typeof SyncService>` 推导构造依赖类型，并给测试增加 `SyncServiceTestSurface` 访问 `initializeSync` 与 `sleep`；原因是这些测试需要触发启动注册流程和加速 retry，但不需要隐藏构造器边界或传入不存在的旧服务依赖。

**偏差说明**：没有改变 `SyncService` 的注册、离线降级、心跳或 env flag 行为；测试仍使用 Cloud API、Prisma、Dataset 的本地 fake，没有真实调用 Cloud API 或数据库。

**权衡分析**：
- 方案一：类型化现有测试替身并保留私有测试探针。优点是删除 `any` 和多余构造参数，行为断言不变；缺点是仍有 private method surface 用于直接测试初始化分支。
- 方案二：只通过 `onModuleInit` 覆盖所有分支。优点是完全避免私有方法访问；缺点是失败/retry/disable 分支需要更多定时等待，测试会更慢更不稳定。
- 选择方案一，因为：它以最小行为风险删除冗余，同时保持 retry 分支测试可控。

**旧决策项**：
- 不再待用户决策：是否后续将 `initializeSync` 抽成显式 internal port 或公开测试入口？
- 不再待用户决策：是否继续处理未跟踪的 `browse-service-repository.test.ts`？

## Web Companion Controller Test Double Sharing Pass - 2026-05-31

**目标**：删除 Web Companion controller 单测里重复维护的 unused service doubles。

**设计决策**：选择新增 `controller-test-doubles.ts` 作为同目录测试 helper，并在 `browse-controller.test.ts` 与 `web-companion.controller.test.ts` 复用它；原因是这些 unused doubles 是构造真实 controller 的测试基础设施，不属于各行为测试自身逻辑。

**偏差说明**：没有改 `WebCompanionController` 的生产构造器、路由或错误映射；本轮只简化测试重复代码，并用架构守卫防止重复 helper 回流。

**权衡分析**：
- 方案一：抽同目录测试 helper。优点是删除重复替身，类型仍从真实 controller 构造器推导；缺点是多一个测试辅助文件。
- 方案二：保留各测试文件局部 helper。优点是单文件自包含；缺点是同一组 unused 依赖会继续重复维护。
- 选择方案一，因为：两个 controller 单测已经共享同一构造边界，抽取后更少冗余且不改变行为覆盖。

**旧决策项**：
- 不再待用户决策：是否后续继续把 controller 行为测试里的通用 async spy 也抽成共享测试工具？
- 不再待用户决策：是否允许处理未跟踪的 `browse-service-repository.test.ts`？

## Archived Cross-Package Cleanup Notes - 2026-05-31

The following entries were moved out of the main implementation notes once it approached the maintainability threshold.

## Protocol Contract Simplification Pass - 2026-05-31

**目标**：删除协议 TS 生成物里空 component map 的 `Record<string, any>`，并把 creation task contract 测试从迁移历史措辞改为当前 task-first 合同表达。

**设计决策**：选择把 `generate-ts-client.mjs` 的 `schemas: never` fallback 从 `Record<string, any>` 改为 `Record<string, unknown>`，并重新生成 cloud-api/sidecar TS clients；同时用 test-quality guard 禁止 creation task contract 测试继续使用 `migration`/`old`/`must add`/`must remove` 历史措辞，原因是空 schemas map 不需要可任意读写的 `any`，task-first 已是当前合同而不是迁移计划。

**偏差说明**：没有改变 OpenAPI JSON、协议源码、Dart 生成物或 creation task contract 断言覆盖面；Dart `pubspec.yaml` 中的 `build_runner: any` 属于生成器依赖约束，本轮未改。

**权衡分析**：
- 方案一：生成脚本统一输出 `unknown`，creation task contract 测试使用当前态名称和表驱动断言。优点是以后重生成不会回退到宽类型，测试不再维护迁移历史措辞；缺点是若调用方依赖任意 schemas 访问，需要先做类型收窄。
- 方案二：只手改生成物并保留历史测试措辞。优点是改动更小；缺点是下一次生成会覆盖，测试继续表达已经结束的迁移过程。
- 选择方案一，因为：源头和生成物一起改，防回归测试覆盖同一约束，creation task contract 测试仍覆盖 taskId、artifact/event 和 generated route 合同。

**旧决策项**：
- 不再待用户决策：是否后续清理 Dart 生成配置里的宽版本约束？

## Protocol Dart Client Dependency Constraint Pass - 2026-05-31

**目标**：删除协议 Dart 生成物中的 `build_runner: any` 宽版本约束。

**设计决策**：选择在 `generate-dart-client.mjs` 生成后统一收窄 `build_runner` 为 `^2.4.15`，并清理 OpenAPI Generator 输出中的尾随空格；原因是直接手改生成物会在下一次生成时回退，后处理能保持生成命令幂等且通过 `git diff --check`。

**偏差说明**：运行了真实 Dart client 生成器，会同步一批当前 OpenAPI 对应的 Dart 生成物；没有运行 `dart pub get` 或 Dart analyzer，因此只验证了协议 TypeScript 检查、协议测试和生成物静态质量。

**权衡分析**：
- 方案一：生成后处理 pubspec 与尾随空格。优点是源头稳定、生成物干净；缺点是仍依赖 OpenAPI Generator 模板输出后再修正。
- 方案二：只改当前两个 `pubspec.yaml`。优点是改动更少；缺点是下一次 `gen:dart` 会恢复 `any`。
- 选择方案一，因为：目标是删除历史维护噪音，而不是只修当前快照。

**旧决策项**：
- 不再待用户决策：是否后续对生成 Dart client 运行 `dart pub get` / analyzer 做真实 Dart 侧验证？

## Desktop Cleanup Pass - 2026-05-31

**目标**：删除桌面端 `pubspec.yaml` 中的 `intl: any` 宽版本约束，并把 setup/route/module 架构测试从已完成的迁移历史措辞改为当前态描述。

**设计决策**：选择把 `intl` 收窄到当前 Flutter 解析并锁定的 `^0.20.2`，并用静态架构测试禁止普通依赖继续使用 `any`；同时增加 setup identifier 和 architecture reason wording guards，禁止 `setup migration keeps common Dart and Flutter identifiers intact`、`legacyOpenAi`/`legacyAgent`、removed legacy book job/API 和 legacy part-file migration 这类历史测试措辞回流，原因是 setup extraction、persisted agent config、removed book routes 和 asset library focused modules 都已是当前结构，不需要继续维护迁移叙事。

**偏差说明**：没有修改 Flutter 生成的 `app_localizations.dart` 注释，那里仍会展示模板建议中的 `intl: any`；实际依赖约束已在 `pubspec.yaml` 收窄。setup identifier 和 architecture reason 测试只改名称/reason/局部变量措辞并增加源码守卫，断言覆盖的损坏标识符、removed route 和模块边界集合不变。

**权衡分析**：
- 方案一：显式约束 `intl: ^0.20.2`，并用当前态测试名加守卫。优点是删除宽依赖和历史叙事且与当前解析版本一致；缺点是未来 Flutter SDK 若要求不同 major/minor 需要主动调整。
- 方案二：保留 `any` 与历史 test name。优点是少改动；缺点是继续保留无边界依赖声明和已完成迁移的维护噪音。
- 选择方案一，因为：本轮目标是清理冗余宽约束和历史维护措辞，且 focused Flutter architecture test 已验证通过。

**旧决策项**：
- 不再待用户决策：是否后续处理 Flutter 生成注释中的示例 `intl: any` 文案？

## Web API/Page Architecture Simplification Pass - 2026-05-31

**目标**：删除 Web Companion 页面加载失败路径中的冗余 `console.error`，并把生成 API 类型架构测试从迁移历史名改为当前态合同名。

**设计决策**：选择在 Web 架构测试中禁止 `src/pages` 生产文件保留 `console.error`，并删除 `AssetBrowser`、`ShareBrowsePage`、`ShareBookPage` 中已经由 UI error state 表达的日志；同时给 `api-generated-types-architecture.test.ts` 增加当前态措辞守卫，原因是这些 catch 分支已经把错误消息展示给用户，测试环境也会拦截 console error，保留日志只增加噪音，生成类型合同也不需要继续用 migration 命名维护历史阶段。

**偏差说明**：没有改变加载、分享 token 校验、错误消息选择或重试行为；本轮验证只走 Vitest/jsdom、TypeScript、ESLint 和 Vite 构建，没有真实浏览器或真实后端调用。

**权衡分析**：
- 方案一：删除页面日志并加静态守卫，生成 API 类型测试使用当前态 suite 名称。优点是减少重复错误通道和历史测试叙事；缺点是开发时不再从这些页面 catch 分支直接看到 console 输出。
- 方案二：保留日志和 migration suite 名称，只依赖现有 UI/架构测试。优点是改动更少；缺点是生产页面错误处理同时走 UI 和 console，生成类型合同继续表达已经结束的迁移过程。
- 选择方案一，因为：用户可见错误状态已经覆盖该行为，页面层无需额外维护 console 日志，生成 API 类型测试应描述当前架构约束。

**旧决策项**：
- 不再待用户决策：是否后续把其它 Web 非页面模块的 console 使用也按可见性分层清理？

## Web Share Helper Pass - 2026-05-31

**目标**：合并分享作品集和分享素材页 footer 中重复的当前页面分享逻辑，并合并作品集卡片与素材网格中重复的分享日期格式化。

**设计决策**：选择新增 `shareCurrentPage` 与 `formatShareDate` 纯 helper，并让 `ShareFooter`/`ShareBrowseFooter` 只负责提供本地化 title/text/copiedMessage、`BookShowcase`/`AssetsGrid` 只传入当前 i18n language；原因是两个 footer 的 native share 优先、clipboard fallback 和 alert 行为完全一致，两个展示组件的 locale 归一化与 `toLocaleDateString` 参数也完全一致，重复维护会增加分叉风险。

**偏差说明**：没有改变按钮文案、分享数据内容、复制链接、alert 行为、日期 locale 选择或日期显示格式；helper 测试使用注入的 navigator/alert fake，没有触发真实系统分享或真实剪贴板，日期验证使用本地组件/源码测试。

**权衡分析**：
- 方案一：抽成 helper 并单测/源码保护。优点是删除重复浏览器能力分支和重复日期格式化，测试可以覆盖两种分享路径与两个展示 surface；缺点是多两个小 helper 文件。
- 方案二：保留组件内重复实现。优点是组件自包含；缺点是同一 fallback 逻辑和日期格式继续复制两份。
- 选择方案一，因为：这些逻辑是跨两个分享 surface 的相同行为，抽取后更容易测试和维护。

**旧决策项**：
- 不再待用户决策：是否后续补充组件级点击测试覆盖 footer 按钮到 helper 的接线？

## Web Http Client Request Flow Simplification Pass - 2026-05-31

**目标**：简化 `HttpClient.request` 中的可变 response 占位变量，并把 `executeWithRetry` 从递归 retry 改成迭代 retry loop。

**设计决策**：选择在 `try` 内直接执行 retry、处理 response 并返回，catch 仍统一委托 `handleError`；同时用 bounded `for` loop 表达 initial attempt + retries，原因是 `handleError` 的返回类型已经是 `never`，递归参数 `retriesLeft` 只是控制流 plumbing。

**偏差说明**：没有改变 API response unwrap、ApiError 映射或 retry 行为；本轮验证使用 axios mock，没有真实网络请求。

**权衡分析**：
- 方案一：直接返回 `handleResponse(await executeWithRetry(fn))` 的结果，并用迭代 loop 管理 retry 次数。优点是控制流更短，避免未初始化变量和递归参数噪音；缺点是 source-level 测试约束了实现风格。
- 方案二：保留 `let response` 和递归 retry。优点是 diff 更少；缺点是多一个不必要的 mutable binding 和只服务递归的参数。
- 选择方案一，因为：行为测试已经覆盖成功、错误和 retry 分支，简化后表达更直接。

**旧决策项**：
- 不再待用户决策：是否后续继续清理 `http-client.ts` 中只复述方法名的注释？

## Sidecar Config Readiness Dependency Pass - 2026-05-31

**目标**：删除 `createConfigReadinessService` 未使用的 Prisma 依赖。

**设计决策**：选择让 config readiness domain 只接收实际使用的 `config` 与 `migrations`，外层 `ConfigService` 继续保留 Prisma 用于 runtime config hydration；原因是 readiness domain 的 `health/status/uiConfig/readiness/initializeSchema` 路径不直接访问 Prisma。

**偏差说明**：没有改变 runtime config 数据库读取、schema initialize 或 UI config 内容；本轮 Sidecar 全包 type-check 因 Web Companion 生成协议 schema 当前为 `Record<string, unknown>` 暴露的既有 DTO 类型问题失败，未在本轮混入修复。

**权衡分析**：
- 方案一：删除 domain 未使用依赖。优点是减少测试替身和构造参数，边界更贴近实际能力；缺点是如果未来 readiness domain 直接查库，需要重新显式加回依赖。
- 方案二：保留 Prisma 作为潜在扩展点。优点是以后扩展少改签名；缺点是继续维护一个当前无用途依赖。
- 选择方案一，因为：当前代码已经通过 AppConfig 和 PrismaMigrationService 完成所有 readiness 行为。

**旧决策项**：
- 不再待用户决策：是否后续统一处理 Sidecar 对空 OpenAPI `components.schemas` 的 generated type 依赖？

## Desktop Sidecar API Response Comment Cleanup Pass - 2026-05-31

**目标**：删除 `packages/desktop/lib/core/sidecar/sidecar_api.dart` 中只复述 `_send`、`_sendList`、`_unwrapApiResponse` 和错误响应解析分支的注释。

**设计决策**：选择在 desktop architecture static test 中新增 guard，禁止 `If the unwrapped data is a list`、`Otherwise return empty list`、`Throw the last error instead of returning empty object/list`、`Check if response is in unified API format`、`Return unwrapped data`、`For null or other types, return empty map`、`Fallback for non-API format responses`、`Try to parse error response in unified format` 和 `If parsing fails, fall through to generic error` 等注释回流；原因是这些分支已经由类型判断、return/throw 语句和 `SidecarApiException` 表达。

**偏差说明**：没有改变 Sidecar HTTP retry、list fallback、unified API envelope unwrap、non-envelope fallback、HTTP error parsing、exception rethrow 或 request context header 行为；本轮只删除注释并增加静态 guard。

**权衡分析**：
- 方案一：删除复述性分支注释并保留顶部 API envelope 语义说明。优点是减少噪音，同时留下真正描述协议形状的文档；缺点是局部分支少了视觉提示。
- 方案二：删除该文件全部注释。优点是更短；缺点是 timeout rationale、base URL resolution 和 envelope contract 注释仍有实际上下文价值。
- 选择方案一，因为：本轮目标是去除无信息增量注释，不破坏有约束含义的说明。

**旧决策项**：
- 不再待用户决策：是否继续清理 Desktop 测试文件中的同类步骤注释？

## Storage Sync Provider Test Double Typing Pass - 2026-05-31

**目标**：删除 `storage-sync-service.test.ts` 中 provider upload double 的 `Promise<any>` 返回类型。

**设计决策**：选择从 `StorageProviderForSync["uploadFile"]` 推导 `UploadFileInput` 和 `UploadFileResult`，并让测试 helper 的 `uploadCalls` 与 override 回调共享同一类型；原因是测试替身应跟随生产 provider port，而不是复制一份较窄但返回值为 `any` 的签名。

**偏差说明**：没有改变 storage sync 的 enqueue、upload、retry、signed URL 或 remote state 行为；本轮仍使用 `MemoryDatasetDb` 和 provider fake，没有真实调用 Supabase Storage。

**权衡分析**：
- 方案一：从生产 port 推导测试类型。优点是删除 `any`，减少重复类型声明，生产 port 变化时测试自动跟随；缺点是测试文件多两个局部 type alias。
- 方案二：手写显式 union 返回类型。优点是少依赖生产类型导出；缺点是会复制 provider 合同，后续容易分叉。
- 选择方案一，因为：这是测试 double，直接复用生产 port 最能减少维护面。

**旧决策项**：
- 不再待用户决策：是否后续清理未跟踪的 `browse-service-repository.test.ts`？
- 不再待用户决策：是否继续处理生成物/第三方 mock 中不可直接删除的 `any` 文本？

## Sidecar Sync Service Comment Cleanup Pass - 2026-05-31

**目标**：删除 `SyncService` 中只复述生命周期、注册、心跳、上传同步、任务同步和临时文件处理步骤的注释，以及已经失真的“稍后实现”历史文案。

**设计决策**：选择加 architecture guard 禁止这些复述性注释回流，只保留代码和日志表达同步流程；原因是方法名、错误消息和现有 `cloud-sync` 行为测试已经覆盖这些语义，注释只增加维护负担。

**偏差说明**：没有改变 Cloud API 注册、离线降级、心跳、upload/job sync 定时器、重试退避、Supabase 下载、asset 导入、metadata 去重或云端状态更新行为；本轮没有真实 Cloud API、Supabase、PostgreSQL 或浏览器调用。

**权衡分析**：
- 方案一：删除复述性注释并用架构测试约束。优点是源码更紧凑，避免历史 TODO 和步骤编号继续漂移；缺点是少了视觉分段。
- 方案二：保留方法级注释。优点是文件分段感不变；缺点是这些注释没有提供额外约束，且部分历史文案已经不准确。
- 选择方案一，因为：同步流程已经由函数边界、日志和测试表达，删除注释能直接减少历史维护面。

**旧决策项**：
- 不再待用户决策：是否继续清理 `SyncService` 中构造依赖测试 double 的类型逃逸，或先保持现状避免扩大构造接口重构？

## Sidecar Web Companion Service Comment Cleanup Pass - 2026-05-31

**目标**：删除 `WebCompanionService` 中只复述会话、上传项、token 校验、状态更新、Supabase signed URL 和 pullback 临时文件步骤的注释，以及“数据库操作方法（待实现）”历史分段。

**设计决策**：选择新增 architecture guard 禁止这些流程型注释回流，同时保留常量时间比较、防并发提交、Supabase 回拉边界、事务原子性和可重试错误类别等约束性注释；原因是前者只是重复代码，后者解释安全或并发边界。

**偏差说明**：没有改变 session 创建/查询/关闭、upload item 创建/提交/重试、signed upload 生成、pullback 导入、hash 计算、失败状态更新或错误码映射行为；本轮没有真实调用 Supabase、PostgreSQL、Cloud API 或浏览器。

**权衡分析**：
- 方案一：删除复述性注释并保留约束性注释。优点是减少维护噪音，同时不丢掉安全和并发语义；缺点是文件仍保留少量注释。
- 方案二：删除该 service 中所有注释。优点是更短；缺点是会抹掉常量时间比较和并发提交等需要解释的设计边界。
- 选择方案一，因为：目标是删冗余，不是为了短而短。

**旧决策项**：
- 不再待用户决策：是否继续清理 `LanReceiverService` 中同类流程型注释？

## Sidecar LAN Receiver Comment Cleanup Pass - 2026-05-31

**目标**：删除 `LanReceiverService` 中只复述设备发现、配对、直传上传、token 验证、文件校验、临时文件和过期会话清理步骤的注释，并清掉两个 controller 里遗留的错误映射复述注释。

**设计决策**：选择新增 architecture guard 约束 LAN receiver 流程型注释不回流，同时保留已有的 logger/type 收窄改动；原因是这些注释只重复方法名、条件分支或下一行调用，删除后代码边界仍由类型、错误码和单测表达。

**偏差说明**：没有改变 LAN pairing、token hash/validation、concurrent upload limit、DatasetService import、temporary file cleanup、session status、mDNS discovery、cleanup timer、agent config error mapping 或 Web Companion share error mapping 行为；本轮没有真实局域网设备、PostgreSQL、Supabase、Cloud API 或浏览器调用。

**权衡分析**：
- 方案一：删除复述性注释并用 architecture guard 固化。优点是减少历史维护面，避免同类流程标签继续漂移；缺点是文件少了视觉分段。
- 方案二：保留 section/header 注释。优点是局部导航更醒目；缺点是这些分段和方法名重复，且之前已在同包服务里清理同类模式。
- 选择方案一，因为：它和 Sidecar Web Companion、SyncService 的清理规则一致，且 focused tests 覆盖核心 LAN 行为。

**旧决策项**：
- 不再待用户决策：是否继续清理 Web Companion controller 中 `Browse endpoints`、`Share token endpoints` 等分段注释？

## May 31 Main-File Cleanup Notes Archive - 2026-06-01

The following detailed 2026-05-31 entries were moved out of `implementation-notes.md` to keep the active notes file under the maintenance threshold:

- Sidecar Web Companion Local DTO Boundary Pass
- Sidecar Generated Schema DTO Cleanup Pass
- Agent Runtime MCP Adapter Single-Pass Pass
- Cloud API Upload Item Mapper Dedup Pass
- Cloud API Share Token Invalid Response Helper Pass
- Agent Runtime Path Policy Input Reader Pass
- Cloud API Sync Service Comment Cleanup Pass
- Web API Comment Cleanup Pass
- Sidecar Web Companion Comment Cleanup Pass
- Sidecar Agent Config Comment Cleanup Pass
- Sidecar Infrastructure Simplification Pass
- Sidecar Bootstrap Comment Cleanup Pass

这些条目的共同结论是：空 generated sidecar schemas 不作为运行时 DTO 来源；重复 mapper、错误判断、env/url/time helper、fake SQL 测试替身和复述性注释只在有测试或架构 guard 保护的边界内清理；真实外部服务调用需要在最终汇报中单独区分。


## Archived implementation-notes.md entries - 2026-06-03

## Archived Sidecar Typing Notes - 2026-05-31

较早的 Sidecar typing pass 已迁入 `implementation-notes-archive.md`，主文件只保留近期高频规则和最近任务要点。

## Archived Cross-Package Cleanup Notes - 2026-05-31

Earlier Protocol, Desktop, Web, and Sidecar Config readiness cleanup passes were moved to `implementation-notes-archive.md` to keep this file focused on recent work.

## Archived May 31 Cleanup Notes - 2026-06-01

Sidecar DTO/comment cleanup, Agent Runtime helper cleanup, Cloud API mapper/share-token cleanup, Web API comment cleanup, and Sidecar bootstrap/infrastructure cleanup notes from 2026-05-31 were moved to `implementation-notes-archive.md` before appending this session's Web Companion completion notes.

## Archived Late-May Cleanup Notes - 2026-05-31

Desktop sidecar API response comment cleanup, Storage Sync test-double typing, Sidecar SyncService comment cleanup, Sidecar Web Companion service comment cleanup, and Sidecar LAN Receiver comment cleanup were moved to `implementation-notes-archive.md` before this file crossed the 300-line maintenance threshold.

## Sidecar Web Companion Test Boundary Simplification Pass - 2026-05-31

**目标**：继续完成 Code Simplifier 未收口项，清理 Web Companion controller endpoint 分段注释、Direct Upload task-number 注释，以及 Web Companion/Browse/ShareToken 测试中的 fake SQL/`any` 历史替身。

**设计决策**：选择用 architecture tests 先暴露回归，再把 `web-companion-service.test.ts`、`browse-service-repository.test.ts` 与 `share-token.test.ts` 改成 typed in-memory repository 行为测试；原因是测试应验证 session/upload-item/child/share-token 边界行为，而不是断言假的 SQL 字符串。旧 `protocol-api-dto-architecture.test.ts` 改为守住当前事实：generated sidecar `components.schemas` 为空时，Sidecar runtime DTO 使用本地显式边界，禁止重新依赖空 generated schema。

**偏差说明**：没有改变 Web Companion 路由、WebCompanionService、Direct Upload pullback 状态机、BrowseService、ShareTokenService 或 Agent Config DTO 运行时行为；本轮以本地单元/架构/HTTP 合同测试验证，没有真实 PostgreSQL、Supabase、OpenAI、LAN 设备或浏览器 UI 调用。

**权衡分析**：
- 方案一：typed memory repository doubles + behavior assertions。优点是删除 fake SQL 和类型逃逸，测试贴近 service port 合同；缺点是测试 helper 比字符串 mock 略多。
- 方案二：继续保留 SQL 字符串 mock。优点是 diff 少；缺点是它没有真实数据库约束，且容易和 repository port 漂移。
- 选择方案一，因为：当前目标是删除历史维护面，行为测试比假的查询文本更能保护真实功能。

**决策状态**：
- [x] 已决策：只清理生产/一方测试中的宽类型与 fake SQL；第三方生成物中必须存在的宽类型不再当作本轮问题。

## Cloud Jobs Sync Removal and OpenAPI Schema Restoration Pass - 2026-06-01

**目标**：按用户授权自行决策，删除 Cloud API 与 Sidecar 之间的历史 `/jobs` 分布式同步链路，并让 Cloud OpenAPI/TS/Dart 生成物不再暴露 Job API。

**设计决策**：选择一次性移除 Cloud API `JobsModule`、`jobs` Prisma 模型/初始化迁移、Sidecar cloud job polling、Job DTO 别名、相关单元测试和生成客户端中的 `JobsApi`/`JobResponseDto`；原因是当前产品以 `/creation/tasks` 和本地 storage/embedding/agent jobs 为正统任务入口，Cloud `/jobs` 没有真实执行价值，保留只会让 Sidecar 多跑一条空的历史同步链路。

**偏差说明**：保留了本地非 Cloud-sync job 概念，包括 Sidecar storage sync jobs、embedding jobs、agent job store，以及 `/creation/jobs`、`/books/jobs` 的已移除入口 404 合同测试；本轮没有启动真实 Cloud API/Sidecar 服务，也没有连接真实 PostgreSQL、Supabase 或外部网络服务。

**权衡分析**：
- 方案一：删除 Cloud `/jobs` API、数据库表和 Sidecar polling。优点是合同、数据库、运行时和生成客户端一致，直接消除旧任务入口；缺点是外部仍调用 Cloud `/jobs/*` 的客户端会断。
- 方案二：保留 Cloud `/jobs` API，只让 Sidecar 不执行部分 job type。优点是兼容旧客户端；缺点是继续维护没有当前产品路径支撑的 API、DTO、迁移和生成物。
- 选择方案一，因为：用户已授权自行决策，且 `CONTEXT.md` 明确 `/creation/tasks` 是 canonical creation API，历史 `/creation/jobs` 应保持移除，Cloud `/jobs` 也不再承担当前有效职责。

**附加修复**：Cloud API 控制器使用 protocol 类型别名时，Swagger 无法从运行时反射生成 `components.schemas`；本轮在 `packages/cloud-api/scripts/generate-openapi.ts` 明确登记 Cloud API 当前 DTO schemas，重新生成 OpenAPI、TS 与 Dart 客户端，并用测试守住不再回流 Job schemas。

**决策状态**：
- [x] 无需用户继续决策；已按“删除历史 Cloud jobs 同步链路、保留本地非 Cloud-sync jobs”的最优方案执行。

## Cloud API Named Schema Generation Pass - 2026-06-01

**目标**：完成 Cloud OpenAPI schema 恢复后的生成物收口，避免 Dart client 继续生成 `SessionSummaryResponseDtoChild`、`SessionSummaryResponseDtoProviders` 等 inline resolver 模型名。

**设计决策**：选择把 Web Companion 嵌套响应对象提升为稳定命名 schema：`TrustedUploadSessionChildDto`、`ProviderAvailabilityDto`、`DirectUploadProvidersDto` 和 `ShareTokenAccessDto`；同时禁止 Cloud API DTO 模块用本地 `Omit<...>` 修补 generated response 类型，原因是稳定 schema 应该由 OpenAPI 合同表达，而不是由运行时代码和生成客户端各自补丁。

**偏差说明**：没有改变 trusted upload session summary、direct upload providers、share token validation 或分享/上传运行时字段；本轮改变的是 OpenAPI 组件命名、生成客户端模型名和类型别名边界。

**权衡分析**：
- 方案一：提升嵌套对象为命名 schema。优点是 TS/Dart 生成物稳定、可读，旧 inline model 文件会自然删除；缺点是 OpenAPI 脚本多维护几个组件。
- 方案二：接受 generator 的 inline resolver 名。优点是脚本少写 schema；缺点是生成物命名不稳定，后续字段调整容易让客户端 API 产生无意义漂移。
- 选择方案一，因为：协议生成物是跨 Web、Desktop 和服务端的公共边界，命名稳定比少写几行 schema 更重要。

**决策状态**：
- [x] 已决策：Cloud API response DTO 只直接 alias generated schemas；嵌套对象必须有稳定 component schema 名，测试禁止 inline resolver 模型名回流。

## Sidecar MCP HTTP Test Env Helper Pass - 2026-06-01

**目标**：继续清理全仓扫描发现的重复测试逻辑，删除多份 Sidecar MCP HTTP 测试里手写保存/恢复 `KIDMEMORY_MCP_ENABLED` 与 `KIDMEMORY_MCP_PATH` 的分支。

**设计决策**：选择在 `tests/http/mcp-test-helpers.ts` 增加 `useMcpTestEnv`，由测试上下文统一注册环境变量恢复；原因是这些测试只差 enabled true/false，重复 `oldEnabled`/`oldPath` 分支没有行为差异。

**偏差说明**：没有改变 MCP endpoint 注册条件、测试端口启动、SDK client 调用或 tools/list/tools/call 行为；本轮只收敛测试环境设置与恢复逻辑。

**权衡分析**：
- 方案一：共享 `useMcpTestEnv`。优点是环境恢复规则单点维护，后续新增 MCP HTTP 测试不再复制分支；缺点是测试读者需要跳到 helper 查看恢复细节。
- 方案二：保留每个测试内联保存/恢复。优点是局部完整；缺点是多份 MCP HTTP 测试重复同一套易漂移代码。
- 选择方案一，因为：这是纯测试基础设施重复，且已用 architecture guard 防止回流。

**决策状态**：
- [x] 已决策：MCP HTTP 测试环境设置统一走 `useMcpTestEnv`；允许各测试继续各自关闭 app/client，因为资源生命周期不同。

## Web Companion Session Upload and Browse Completion - 2026-06-01

**目标**：收口 Web Companion 真实会话入口，确保 `/app` 必须携带 `sessionId/token`，Trusted Upload 与 Direct Upload 都沿会话 token 边界提交，浏览页使用真实 session recent 数据而不是本地假 childId。

**设计决策**：选择让 Web Companion 路由只消费 URL 中的 `sessionId/token`，让 `AssetBrowser` 调用 `/api/web-companion/sessions/:sessionId/recent?token=...&limit=20`，Direct Upload 回拉只在匹配 objectKey 的结果为 `ready` 时标记成功；原因是 Sidecar 的会话 token 才是 Web Companion 授权边界，空回拉结果不能被当成已入库。

**偏差说明**：保留 `/trusted-upload` 路由兼容，但 Sidecar 生成的 trusted upload `webUrl` 改为 `/app`；没有真实调用 Supabase Storage 或外部 OpenAI/Cloud 服务，Direct Upload 的 Supabase 客户端路径以组件/单元测试和 Sidecar 单测覆盖。

**权衡分析**：
- 方案一：Web 端统一依赖 sessionId/token，并在 browse/upload/direct-upload 各路径显式传递 token。优点是授权边界一致、真实 sidecar 浏览可用、空回拉不误报成功；缺点是组件 props 和 query 参数处理更明确。
- 方案二：继续由 Web 端创建 sample child/session 或按 childId 浏览素材。优点是页面更容易脱离 sidecar 单独演示；缺点是绕开真实上传会话，真实桌面生成链接时会出现数据与权限漂移。
- 选择方案一，因为：这次修复的是真实桌面生成 Web Companion 链接后的端到端合同，而不是 demo fallback。

**验证方式与结果**：
- [x] 静态/单元/构建：Web lint/test/build、Sidecar build、Protocol test/build、Cloud API build、Desktop flutter test/analyze 均通过。
- [x] 真实桌面运行：Xcode macOS Debug 构建 `KidMemory.app` 成功，Computer Use 确认窗口打开，sidecar 健康检查通过。
- [x] 真实浏览器运行：Codex Browser 打开真实 `/app?sessionId=...&token=...`，缺参页拦截、连接页会话有效、浏览页显示 9 张 sample 素材、搜索空结果和控制台 error 检查通过。
- [ ] 未验证真实 Supabase Storage 上传；当前环境未配置可用外部 Supabase，Direct Upload 以 mock/单元测试和 sidecar 服务测试替代。

## Sidecar Agent Runtime File Dependency Preparation Pass - 2026-06-01

**目标**：修复 Sidecar runtime/test 脚本隐式依赖未跟踪 `packages/agent-runtime/dist` 的问题，避免本地残留构建产物决定 Sidecar app 是否能加载。

**设计决策**：选择在 Sidecar package scripts 中增加 `prepare:agent-runtime`，并让 `dev`、`test*`、`type-check`、`check:tests`、`build:prod` 和 `gen:openapi` 在加载 Sidecar runtime 前通过 Node 脚本准备 `../agent-runtime`：缺少 TypeScript/Node 类型依赖时先运行 `npm ci`，再显式编译；原因是 Sidecar 通过 `file:../agent-runtime` 依赖 package export，而该 package 的 `main`/`exports` 指向被 gitignore 的 `dist/`。

**偏差说明**：没有改变 AgentRuntimeService、CreationService、MCP 工具或运行时执行逻辑；本轮只让脚本自举 file dependency，避免靠开发机上的旧 dist 目录。

**权衡分析**：
- 方案一：Sidecar 脚本显式准备 agent-runtime。优点是测试、开发、OpenAPI 生成和生产构建入口都可从干净工作区运行；缺点是这些脚本多一次 TypeScript compile。
- 方案二：提交 agent-runtime `dist/`。优点是运行时少一步；缺点是提交生成物会扩大维护面，并和当前 gitignore 约定冲突。
- 选择方案一，因为：`dist/` 是生成产物，正确边界是脚本生成而不是源码仓库保存。

**决策状态**：
- [x] 已决策：Sidecar 不依赖预先存在的 agent-runtime dist；所有会加载 Sidecar runtime 的脚本先执行 `node scripts/prepare-agent-runtime.mjs`，并在 agent-runtime dev 依赖缺失时自动 `npm ci` 后编译。

## Shared Test Env and Integration Skip Cleanup Pass - 2026-06-01

**目标**：收口 Code Simplifier 最后发现的测试环境重复逻辑，避免 env 污染、误导性 skip 日志和慢重试测试继续维护。

**设计决策**：选择新增 Sidecar `tests/test-env.ts` 的 `useTestEnv`，让 MCP/trace/contracts/sync/cloud-client/search-indexing 测试统一恢复 `process.env`；`cloud-sync` 重试失败测试改用 `node:test` mock timers；integration 数据库测试只通过 `describe({ skip })` 表达无 `DATABASE_URL` 跳过；agent-runtime workspace command 测试恢复原有 env 值。

**偏差说明**：没有改变 Sidecar/Agent Runtime 生产行为、MCP 路由、Cloud sync 语义、integration 数据库行为或命令隔离策略；当前真实数据库 integration 仍因本机未配置 `DATABASE_URL` 按预期 skip。

**权衡分析**：方案一：共享 env helper 与 mock timers，优点是测试更短、更快且恢复规则一致；缺点是多一个测试 helper。方案二：保留内联恢复与真实退避等待，优点是局部完整；缺点是重复且容易污染环境。选择方案一，因为：这是纯测试基础设施冗余，已有 architecture guard 防止回流。

**决策状态**：
- [x] 无需用户继续决策；按统一 env helper、真实 skip 语义和无真实退避等待的方案收口。

## Web Companion 安全边界与合同补强 - 2026-06-01

**目标**：核对复审文本中指出的 token 边界、Direct Upload 暴露面、上传成功语义、recent 缩略图和 OpenAPI 合同问题，并修复属实项。

**设计决策**：选择在服务端强制 summary/detail 与 Direct Upload config/list/status 的 token 校验，而不是只依赖前端 URL 参数；Trusted Upload 暂不阻塞等待后台 pullback ready，先把 UI 文案改为“已上传，等待入库”，避免把 remote uploaded 误表达成已入库。

**偏差说明**：复审中提到的 Direct Upload session 持久化、旧上传路径删除、上传工具抽离属于较大结构调整，本次未扩散处理；先收口安全边界、合同和用户可见语义。

**权衡分析**：
- 方案一：commit 后同步等待 pullback ready。优点是语义最强；缺点是上传响应会被后台回拉和外部存储拖慢。
- 方案二：保留后台 pullback，但 UI 明确显示“已上传，等待入库”。优点是改动小且不误导；缺点是还没有细粒度 ready 轮询。
- 选择方案二，因为：本轮目标是快速修正真实风险，同时避免引入新的长耗时请求边界。

**待确认**：
- [ ] 是否需要为 Trusted Upload 增加 upload item detail 轮询，直到 READY 再显示“已入库”？
- [ ] Direct Upload 验证版 session 是否需要持久化到数据库，支持 sidecar 重启后继续 pullback？

## Web Companion 上传与 Sidecar 合同补完 - 2026-06-01

**目标**：修复复审确认仍未完成的 Direct Upload 错误映射、Web 使用 cloud-api 类型、Books/Share/Public Share sidecar generated contract 缺 content/requestBody、Direct Upload session 进程内 Map、Trusted Upload 未等 READY，以及旧上传 helper 清理问题。

**设计决策**：选择让 Direct Upload session 元数据通过 `web_companion_upload_sessions` 持久化 token hash/child/expiresAt，并在 Prisma-backed store 中只接受/清理 `wcs_direct_` 前缀会话，bucket 继续从当前 sidecar config 解析；原因是这张表已经承担 Web Companion 会话 token 边界，不需要新增 Prisma 模型。Web 前端统一改为 `@kidmemory/protocol/sidecar` generated operations 类型；Trusted Upload 在 commit 后轮询 session detail，只有 item status 为 `ready` 才进入 UI success。

**偏差说明**：没有新增真实 Supabase Storage 端到端上传验证；Direct Upload/Trusted Upload 的外部存储路径仍以单元测试、HTTP 合同、类型检查和 build 验证覆盖。`generated/sidecar/ts` 中其它历史 GET endpoint 仍可能有 `content?: never`，本轮只为用户点名的 Books/Share/Public Share 和 Direct Upload 合同补齐 guard。

**权衡分析**：
- 方案一：复用 `web_companion_upload_sessions` 存 Direct Upload session。优点是无需迁移新表，重启可恢复 token 校验；缺点是 Direct Upload 与 Trusted Upload 共用会话表，需要用 `wcs_direct_*` id 和当前配置区分语义。
- 方案二：新增 direct_upload_sessions 表。优点是边界更显式；缺点是需要迁移和更多 repository 代码，当前字段与现有会话表高度重叠。
- 选择方案一，因为：最小改动即可修复重启不可恢复，并保持 token hash 不落明文。

**验证方式与结果**：
- [x] `npm --prefix packages/web run test -- src/test/api-generated-types-architecture.test.ts src/hooks/useTrustedUploadSession.test.tsx src/lib/upload-session.test.ts src/pages/upload/FileUpload.test.tsx src/App.test.tsx --run`
- [x] `npm --prefix packages/web run build`
- [x] `npm --prefix packages/protocol run test -- tests/openapi-path-params.test.ts`
- [x] `npm --prefix packages/protocol run build`
- [x] `npm --prefix packages/sidecar run type-check`
- [x] `npm --prefix packages/sidecar run build`

**待确认**：
- [ ] 是否要为所有 sidecar generated endpoints 统一补齐 response schemas，而不是只覆盖 Web Companion Books/Share/Public Share？

## Web Companion READY 与 Direct Upload 边界补强 - 2026-06-01

**目标**：补齐新一轮 review 指出的 `/app` 主上传未等 READY、Direct Upload 回拉临时文件泄漏、browse/share 缺 token 返回 400、Direct Upload bucket 未随 session 持久化与前缀隔离不足问题。

**设计决策**：把 READY 轮询抽到 Web 共享 helper，`/app` 与 legacy Trusted Upload 共用同一等待逻辑；Direct Upload bucket 使用 `web_companion_upload_sessions.direct_upload_bucket` 持久化，旧 session 缺字段时仍回退当前配置；临时回拉目录用 `finally fs.rm(..., { recursive: true, force: true })` 清理。

**偏差说明**：未在本轮做真实 Supabase Storage smoke test；该项需要可用的真实 Supabase 项目、bucket policy 与外部凭据。

**权衡分析**：
- 方案一：仅改文案承认 `/app` 是 accepted 状态。优点是改动小；缺点是成功语义继续分叉。
- 方案二：让 `/app` 也等 sidecar detail READY。优点是成功语义统一；缺点是用户等待时间更长。
- 选择方案二，因为：review 明确要求“成功”等于真正 READY，且已有 detail API 可复用。

**待确认**：
- [ ] 是否要继续把 `FileTask.status` 从 `success` 迁移为后端同名 `ready`。
- [ ] 是否安排真实 Supabase Storage upload/list/pullback/import smoke test。


## Archived Early-June Active Notes - 2026-06-03

## COS/S3 Direct Upload 与 Agent Runtime Smoke 收口 - 2026-06-01

**目标**：继续完成上轮中断的 Direct Upload provider 兼容与真实链路验证，确保 COS/S3 不依赖 Supabase REST 配置，并把 sidecar 到 agent runtime 的最小生成链路跑通。

**设计决策**：选择把对象存储健康检查统一到 provider-neutral `createObjectStorageProvider`，让 `KIDMEMORY_OBJECT_STORAGE_PROVIDER=s3` 从 `.env` 读取 S3 endpoint/bucket/credential，并为 COS/通用 S3 使用 signed-url 上传模式；同时收紧 Direct Upload signed upload 的 objectKey 校验，要求第一段严格等于 sessionId，且后续 path segment 不得为空、`.` 或 `..`。

**偏差说明**：没有改变 `/creation/tasks` 的生产任务状态机，也没有把 agent config 持久化逻辑迁到 `.env`；本轮用 OpenRouter 配置真实调用 AgentRuntimeService smoke，通过 sidecar service 层确认可产出 `output/plan.json`。优先 OpenAI 配置的 smoke 返回 401，判定为该 provider key 不可用而非 runtime 链路失败。

**权衡分析**：
- 方案一：Direct Upload 继续只识别 Supabase/COS。优点是改动少；缺点是类型中已有 `s3` provider 但 env 无法启用，和“兼容所有 provider”目标冲突。
- 方案二：补齐通用 S3 env 入口并复用现有 S3 签名实现。优点是 COS、Supabase S3 和普通 S3 共享安全边界；缺点是配置命名仍沿用历史 `SUPABASE_S3_*`。
- 选择方案二，因为：最小改动即可让三个 provider 在配置、签名、上传和回拉边界上保持一致。

**验证方式与结果**：
- [x] TDD 红/绿：`config.test.ts` 覆盖 S3 env、COS provider-neutral health gateway；`direct-upload-security.test.ts` 覆盖 traversal objectKey 拒签。
- [x] `npm --prefix packages/sidecar run build`
- [x] `npm --prefix packages/web run build`
- [x] `npm --prefix packages/protocol run build`
- [x] 真实 COS SDK smoke：upload/list/download/sign 成功并清理 `kidmemory-smoke/` 临时对象。
- [x] 真实 DirectUploadService + COS smoke：sidecar 签发 PUT URL、真实 PUT、list、download、pullback ready 成功并清理对象。
- [x] 真实 AgentRuntimeService smoke：OpenRouter `custom-chat` 产出 `output/plan.json` 成功。

**待确认**：
- [ ] 是否要把配置 UI 中的 `SUPABASE_S3_*` 文案进一步泛化为对象存储 S3，而不仅是 Supabase S3。
- [ ] 当前 `.env` 的优先 OpenAI-compatible key 返回 401；是否要清理或替换这组 OpenAI 配置，避免后续 smoke 优先命中失效凭据。

## 桌面端素材库智能挑选交互说明 - 2026-06-02

**目标**：修复素材库“帮我挑素材”弹窗里“重新挑选”看起来无响应的问题，并确认素材搜索与调素材的数据来源。

**设计决策**：选择让智能挑选弹窗展示本次建议素材预览，并在当前可见素材不超过 12 张时禁用“重新挑选”且显示“全部纳入”提示；原因是当前智能挑选是桌面端本地启发式重排，不调用 Agent 或 sidecar，候选不足时继续重算不会产生新结果。

**偏差说明**：没有把素材库智能挑选改成后端 Agent/PGSQL 搜索，也没有改变确认使用后的 selectedAssets 行为；搜索按钮仍走 `DesktopSidecarGateway.searchAssetsDto -> /search/query -> DatasetService.searchAssets`，持久化成功时由 Prisma-backed PostgreSQL 素材与 embedding 数据支撑，sidecar 持久库激活失败时仍可能 fallback 到内存数据集。

**权衡分析**：
- 方案一：只给“重新挑选”加 toast。优点是改动更小；缺点是用户仍看不到具体换了哪组素材。
- 方案二：展示建议素材预览并禁用无效重挑。优点是按钮行为可见，候选不足时语义明确；缺点是弹窗内容略多。
- 选择方案二，因为：问题根因是状态不可见和候选不足时无差异结果，预览与禁用能直接解释交互。

**验证方式与结果**：
- [x] TDD 红/绿：新增 `smart pick dialog explains when no alternate batch exists` widget 测试，先复现缺少提示，再验证修复。
- [x] `cd packages/desktop && flutter test test/features/asset_library/asset_library_test.dart`
- [x] `cd packages/desktop && flutter test test/architecture_static_test.dart --plain-name 'asset library page delegates smart pick dialog UI'`
- [x] `cd packages/desktop && flutter analyze lib/features/asset_library test/features/asset_library/asset_library_test.dart lib/l10n`
- [ ] 全量 `cd packages/desktop && flutter analyze` 未通过；阻塞在既有 `test/features/setup/openai_setup_dialog_test.dart` 的 `SecondaryButton` 未定义与未使用 import，非本次改动文件。

**待确认**：
- [ ] 是否要把素材库“智能挑选”升级为真正调用 sidecar 搜索/Agent 的推荐接口，而不是继续使用桌面端本地启发式？

## 删除孩子档案级联清理 - 2026-06-02

**目标**：删除孩子档案时不再要求用户先清空关联素材；确认弹窗明确提示风险，用户确认后允许删除孩子及关联本地数据。

**设计决策**：选择在桌面端保留确认 modal，并在 Sidecar dataset domain 中先清理孩子关联记录、embedding jobs、候选池和素材，再删除孩子档案；原因是删除边界应由 sidecar 可信服务统一执行，不能让 UI 用“先清空数据”的前置条件阻断真实删除。

**偏差说明**：本轮没有启动真实桌面 `.app` 或真实 PostgreSQL 数据库；Prisma 适配器新增关联清理方法并通过 TypeScript type-check 验证，行为以内存 dataset 单元测试覆盖。

**权衡分析**：
- 方案一：只改 modal 文案，后端仍遇到素材返回 409。优点是 UI 改动小；缺点是用户确认后仍无法删除示例孩子。
- 方案二：确认后由 sidecar 级联清理关联数据。优点是符合用户“确认后真的删除”的预期；缺点是删除是不可逆操作，必须在 modal 中清楚提示。
- 选择方案二，因为：删除孩子档案是数据所有权操作，确认后应由后端一次性完成关联数据清理。

**验证方式与结果**：
- [x] TDD 红/绿：`npx tsx --test tests/unit/modules/dataset/dataset-domain.test.ts`
- [x] `npm --prefix packages/sidecar run type-check`
- [ ] 桌面 widget 测试当前工作区未能 fresh 通过；`cd packages/desktop && flutter test test/features/app/app_test.dart --name "delete child profile confirms before deleting linked data"` 被既有 GenerateExport/SmartGenerateActions 参数不匹配阻塞。

**待确认**：
- [ ] 是否需要继续把真实 PostgreSQL 中的书、导出 artifact 等更广义历史生成记录纳入可审计删除报告。

## 桌面端设置目录按钮与 COS 配置入口修复 - 2026-06-02

**目标**：修复设置页“本地数据目录”卡片中“打开目录 / 配置目录”点击无响应的问题，并让“云端分享设置”支持选择 Supabase 或腾讯云 COS。

**设计决策**：选择让本地数据目录操作不受前置 OpenAI 配置顺序锁阻断；云端分享弹窗在现有 `/config/supabase-storage` 合同上补传 `provider`，通过下拉框在 `supabase` 与 `cos` 间切换。COS 复用已有 S3 兼容字段（endpoint、region、bucket、access key、secret key），Supabase 继续保留既有 S3 与 REST 可选字段。

**偏差说明**：没有改 sidecar 对象存储运行时，也没有新增真实 COS 连接 smoke；本次只修桌面端配置入口、DTO 字段透传和 widget 行为测试。

**权衡分析**：
- 方案一：新增独立 COS 配置弹窗。优点是文案可完全贴合 COS；缺点是会复制大量对象存储字段与保存逻辑。
- 方案二：在现有云端分享弹窗增加 provider 下拉框。优点是最小改动复用 sidecar 已支持的 provider-neutral 配置；缺点是 Supabase 命名历史仍存在于部分内部类型名中。
- 选择方案二，因为：当前 sidecar 合同已经统一在 `/config/supabase-storage`，桌面端缺的是 provider 选择和字段透传，而不是新的配置边界。

**验证方式与结果**：
- [x] TDD 红/绿：新增设置页 widget 测试覆盖 OpenAI 未配置时本地目录按钮仍可打开/配置，以及 COS provider 下拉框提交 `provider: cos` 与 COS S3 字段。
- [x] `cd packages/desktop && flutter test test/features/app/app_test.dart --name 'setup local data directory actions stay clickable|setup page can configure COS object storage provider'`
- [x] `cd packages/desktop && flutter test test/features/app/app_test.dart --name 'setup page manages Supabase Storage|setup page storage test failure|setup page configures Supabase S3|setup local data directory actions stay clickable|setup page can configure COS'`
- [x] `cd packages/desktop && flutter analyze lib/app/desktop_shell.dart lib/core/sidecar/desktop_sidecar_gateway.dart lib/core/sidecar/sidecar_dtos.dart lib/features/setup/setup_page.dart test/features/app/app_test.dart`

**待确认**：
- [ ] 是否要把云端分享弹窗中的 Supabase S3 帮助链接进一步按 provider 切换为腾讯云 COS 官方文档？

## 真实导入素材默认类型调整 - 2026-06-02

**目标**：把真实导入图片的默认素材类型从 `artwork` 调整为更中性的 `photo`，避免所有本地图片导入后都被智能挑选当作绘画素材。

**设计决策**：选择只修改 `importLocalAssets` 的默认 `type`，不在本轮新增 `unknown` 类型或 AI 分类字段；原因是新增类型会牵动筛选、统计、搜索和生成逻辑，而用户当前目标是先把写死的 `artwork` 调整为 `photo`。

**偏差说明**：本轮没有实现导入时用户选择类型，也没有让 OpenAI metadata inferer 返回/覆盖 `type`；当前 AI metadata 仍只补充标题、描述和标签。

**权衡分析**：
- 方案一：默认改为 `photo`。优点是最小改动，导入图片不再全部冒充绘画；缺点是儿童画图片仍需要后续手动或 AI 归类。
- 方案二：立即新增 `unknown` 并重做 UI。优点是语义最准确；缺点是改动面大，当前筛选和统计都要同步扩展。
- 选择方案一，因为：它满足当前修正目标，并保留后续分类能力的设计空间。

**验证方式与结果**：
- [x] TDD 红/绿：`asset-import.test.ts` 增加真实导入默认 `photo` 断言，先复现 `artwork`，再改实现通过。
- [x] `cd packages/sidecar && npx tsx --test tests/unit/infrastructure/asset-import.test.ts`
- [x] `npm --prefix packages/sidecar run type-check`
- [ ] `npm --prefix packages/sidecar run test -- tests/unit/infrastructure/asset-import.test.ts` 会额外执行整套测试，并被当前工作区已有 Direct Upload 架构守卫失败阻塞，非本次导入类型改动。

**待确认**：
- [ ] 后续导入流程支持用户选择素材类型。
- [ ] 后续 AI metadata inference 支持白名单判别 `artwork` / `photo` / `craft` 并允许覆盖默认类型。

## 桌面端大模型配置弹窗 404 兜底 - 2026-06-02

**目标**：修复设置页点击“大模型接口配置”的“修改配置”在默认 agent 配置接口返回 404 时没有弹窗、看起来无响应的问题。

**设计决策**：选择让 `AgentConfigApi.getDefaultAgentConfig()` 将 404 归一为 `null`，并让桌面端弹窗读取默认配置失败时继续打开空配置表单；原因是“没有默认配置”是可编辑的初始状态，不应阻塞用户填写新配置。

**偏差说明**：没有改变保存配置的 create/update/set-default 行为，也没有真实调用外部 OpenAI/OpenRouter 服务；本轮只修复配置表单打开前的本地 UI/API 兜底。

**权衡分析**：
- 方案一：只在 UI 层 catch 404。优点是改动局部；缺点是其它调用默认配置的桌面入口仍会把“未配置”当异常。
- 方案二：API 层把 404 归一为 null，UI 层同时对读取失败兜底。优点是语义集中且按钮不会再被默认配置读取失败卡住；缺点是非 404 异常在 UI 打开阶段也会被记录后继续显示空表单。
- 选择方案二，因为：默认配置缺失本来就是首次配置路径，用户最需要看到可填写表单。

**验证方式与结果**：
- [x] TDD 红/绿：`flutter test test/core/sidecar/sidecar_api_test.dart --plain-name "AgentConfigApi treats missing default agent config as empty"`
- [x] Widget 回归：`flutter test test/features/setup/openai_setup_dialog_test.dart`
- [x] 静态检查：`flutter analyze lib/app/setup/dialogs/dialog_openai.dart lib/app/desktop_shell.dart lib/core/sidecar/agent_config_api.dart test/features/setup/openai_setup_dialog_test.dart test/core/sidecar/sidecar_api_test.dart`

**待确认**：
- [ ] 是否需要把读取默认配置失败时的日志文案改为本地化字符串。
