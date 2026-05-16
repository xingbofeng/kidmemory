## ADDED Requirements

### Requirement: 内存限流必须定时清理过期数据

系统 SHALL 使用定时器（而非随机概率）清理过期的限流数据，防止内存泄漏。

#### Scenario: 每 60 秒清理一次
- **WHEN** RateLimitMiddleware 启动
- **THEN** 必须启动定时器，每 60 秒调用一次 cleanup()

#### Scenario: 清理过期的全局时间戳
- **WHEN** cleanup() 执行
- **THEN** 必须过滤掉所有早于 (now - windowMs) 的时间戳

#### Scenario: 清理过期的 IP 时间戳
- **WHEN** cleanup() 执行
- **THEN** 必须遍历所有 IP，过滤掉过期时间戳，删除空的 IP 记录

#### Scenario: 全局时间戳达到上限时拒绝请求
- **WHEN** globalTimestamps 长度达到 10000（说明服务器过载，60s 清理尚未执行）
- **THEN** 直接返回 `{ code: 16001, msg: "服务器过载", data: { retryAfter: 60 } }`，不截断历史记录
- **AND** 理由：截断历史会导致计数下降，攻击者可通过触发截断绕过限流；拒绝请求才是正确的语义

#### Scenario: 模块销毁时清理定时器
- **WHEN** RateLimitMiddleware 销毁
- **THEN** 必须调用 clearInterval() 清理定时器

### Requirement: IP 限流必须正常工作

系统 SHALL 对每个 IP 地址进行限流，默认每分钟最多 100 次请求。

#### Scenario: IP 未超限
- **WHEN** 同一 IP 在 1 分钟内发起 50 次请求
- **THEN** 所有请求都应该通过

#### Scenario: IP 超限
- **WHEN** 同一 IP 在 1 分钟内发起 101 次请求
- **THEN** 第 101 次请求返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60 } }`

#### Scenario: 不同 IP 不互相影响
- **WHEN** IP A 发起 100 次请求，IP B 发起 1 次请求
- **THEN** IP B 的请求应该通过

### Requirement: 全局限流必须正常工作

系统 SHALL 对所有请求进行全局限流，默认每分钟最多 1000 次请求。

#### Scenario: 全局未超限
- **WHEN** 所有 IP 合计在 1 分钟内发起 500 次请求
- **THEN** 所有请求都应该通过

#### Scenario: 全局超限
- **WHEN** 所有 IP 合计在 1 分钟内发起 1001 次请求
- **THEN** 第 1001 次请求返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60 } }`

### Requirement: Session 配额限流必须正常工作

系统 SHALL 对每个 childId 进行 Session 配额限流，默认最多 5 个活跃 session，每天最多 20 个 session。

#### Scenario: 活跃 session 未超限
- **WHEN** childId 有 3 个活跃 session
- **THEN** 创建新 session 应该成功

#### Scenario: 活跃 session 超限
- **WHEN** childId 已有 5 个活跃 session
- **THEN** 创建新 session 返回 `{ code: 16003, msg: "活跃会话数超限", data: null }`

#### Scenario: 每日 session 未超限
- **WHEN** childId 今天已创建 15 个 session
- **THEN** 创建新 session 应该成功

#### Scenario: 每日 session 超限
- **WHEN** childId 今天已创建 20 个 session
- **THEN** 创建新 session 返回 `{ code: 16004, msg: "每日会话数超限", data: null }`

### Requirement: 上传 commit 必须幂等

系统 SHALL 确保同一 uploadItemId 重复 commit 不会重复触发 pullback。

#### Scenario: 首次 commit 成功
- **WHEN** uploadItemId 首次 commit
- **THEN** 触发 pullback，返回成功

#### Scenario: 重复 commit 返回幂等结果
- **WHEN** uploadItemId 已 commit，再次 commit
- **THEN** 不触发 pullback，返回 `{ code: 15005, msg: "上传项已提交", data: { uploadItemId } }`

#### Scenario: 并发 commit 只触发一次 pullback
- **WHEN** 同一 uploadItemId 并发 commit 10 次
- **THEN** 只有 1 次触发 pullback，其他 9 次返回幂等结果

### Requirement: pullback 必须防重复触发

系统 SHALL 确保同一 pullback 任务不会重复执行。

#### Scenario: 首次 pullback 成功
- **WHEN** pullback 任务首次执行
- **THEN** 下载文件，创建 asset，状态改为 completed

#### Scenario: 重复 pullback 被阻止
- **WHEN** pullback 任务已 completed，再次触发
- **THEN** 返回 `{ code: 15006, msg: "回拉任务已完成", data: null }`

#### Scenario: 并发 pullback 只执行一次
- **WHEN** 同一 pullback 任务并发触发 10 次
- **THEN** 只有 1 次执行成功，其他 9 次被阻止

### Requirement: pullback 状态变更必须使用数据库原子操作

系统 SHALL 使用原子 UPDATE 而非先读后写来变更 pullback 状态，防止并发竞态。

#### Scenario: 原子 UPDATE 抢占 pending 状态
- **WHEN** pullback 被触发
- **THEN** 必须执行原子操作：`UPDATE upload_items SET status='processing' WHERE id=? AND status='pending' RETURNING id`
- **AND** 仅当 RETURNING 返回行数 = 1 时，才继续执行下载流程
- **AND** 行数 = 0 说明已被其他并发请求抢占，直接返回幂等结果

#### Scenario: 不允许先读后写
- **WHEN** 实现 pullback 状态检查
- **THEN** 禁止先 SELECT status 再 UPDATE status 的两步写法（存在并发窗口）
- **AND** 必须使用单条带条件的原子 UPDATE

### Requirement: 分享访问必须限流

系统 SHALL 对分享链接的访问进行限流，防止恶意刷访问次数。

#### Scenario: 分享访问未超限
- **WHEN** 同一 IP 访问分享链接 5 次
- **THEN** 所有访问都应该成功

#### Scenario: 分享访问超限
- **WHEN** 同一 IP 在 1 分钟内访问分享链接 21 次
- **THEN** 第 21 次访问返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60 } }`

### Requirement: share token accessCount 必须原子消费

系统 SHALL 确保 share token 的 accessCount 在并发访问时不会突破 maxAccessCount。

#### Scenario: accessCount 未超限
- **WHEN** share token maxAccessCount=10，当前 accessCount=5
- **THEN** 访问成功，accessCount 增加到 6

#### Scenario: accessCount 超限
- **WHEN** share token maxAccessCount=10，当前 accessCount=10
- **THEN** 访问失败，返回 `{ code: 14004, msg: "分享访问次数已用尽", data: null }`

#### Scenario: 并发访问不突破 maxAccessCount
- **WHEN** share token maxAccessCount=10，当前 accessCount=0，并发 20 次访问
- **THEN** 只有 10 次访问成功，accessCount 最终为 10

### Requirement: accessCount 递增必须使用条件原子 SQL

系统 SHALL 使用带边界检查的原子 SQL 实现 accessCount 递增，禁止在应用层先读后写。

#### Scenario: 条件原子递增
- **WHEN** 用户访问分享链接
- **THEN** 必须执行：`UPDATE share_tokens SET access_count = access_count + 1 WHERE id=? AND access_count < max_access_count RETURNING access_count`
- **AND** 仅当 RETURNING 有结果时，认为访问成功
- **AND** 无结果时返回 `{ code: 14004, msg: "分享访问次数已用尽", data: null }`

#### Scenario: 禁止 Prisma increment 直接操作
- **WHEN** 实现 accessCount 消费逻辑
- **THEN** 禁止使用 `prisma.shareToken.update({ data: { accessCount: { increment: 1 } } })` 后再判断是否超限（无原子性）
- **AND** 必须使用 `prisma.$queryRaw` 或 `prisma.$executeRaw` 执行带条件的原子 SQL

### Requirement: 限流错误必须统一格式

系统 SHALL 确保所有限流错误返回 code/msg/data 格式，data 中包含 retryAfter。

#### Scenario: IP 限流错误格式
- **WHEN** IP 限流触发
- **THEN** 返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60, count: 101, maxRequests: 100 } }`

#### Scenario: Session 配额错误格式
- **WHEN** Session 配额超限
- **THEN** 返回 `{ code: 16003, msg: "活跃会话数超限", data: { activeCount: 5, maxActive: 5 } }`

### Requirement: 必须有并发测试覆盖

系统 SHALL 编写并发测试，验证限流在高并发下的正确性。

#### Scenario: 并发测试 IP 限流
- **WHEN** 50 个并发请求，maxRequests=10
- **THEN** 最终成功数必须为 10，失败数必须为 40

#### Scenario: 并发测试 accessCount 原子性
- **WHEN** 20 个并发访问，maxAccessCount=10
- **THEN** 最终 accessCount 必须为 10，不能超过

#### Scenario: 并发测试 commit 幂等性
- **WHEN** 10 个并发 commit 同一 uploadItemId
- **THEN** 只有 1 次触发 pullback
