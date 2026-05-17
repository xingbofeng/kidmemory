## ADDED Requirements

### Requirement: 分享访问必须限流

系统 SHALL 对分享链接的访问进行限流，防止恶意刷访问次数。

#### Scenario: 同一 IP 访问限流
- **WHEN** 同一 IP 在 1 分钟内访问分享链接超过 20 次
- **THEN** 返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60 } }`

#### Scenario: 不同 IP 不互相影响
- **WHEN** IP A 访问 20 次，IP B 访问 1 次
- **THEN** IP B 的访问应该成功

### Requirement: share token accessCount 必须原子消费

系统 SHALL 确保 share token 的 accessCount 在并发访问时原子递增，不会突破 maxAccessCount。

#### Scenario: accessCount 原子递增
- **WHEN** share token 被访问
- **THEN** accessCount 必须原子递增 1

#### Scenario: 并发访问不突破 maxAccessCount
- **WHEN** share token maxAccessCount=10，当前 accessCount=0，并发 20 次访问
- **THEN** 只有 10 次访问成功，accessCount 最终为 10

#### Scenario: 超过 maxAccessCount 拒绝访问
- **WHEN** share token accessCount >= maxAccessCount
- **THEN** 返回 `{ code: 14004, msg: "分享访问次数已用尽", data: null }`

### Requirement: share token 必须验证有效性

系统 SHALL 在消费 accessCount 前验证 share token 的有效性（未过期、未撤销）。

#### Scenario: 验证 token 未过期
- **WHEN** share token expiresAt < now
- **THEN** 返回 `{ code: 14003, msg: "分享链接已过期", data: null }`

#### Scenario: 验证 token 未撤销
- **WHEN** share token status = "revoked"
- **THEN** 返回 `{ code: 14002, msg: "分享链接已撤销", data: null }`

#### Scenario: 验证 token 存在
- **WHEN** share token 不存在
- **THEN** 返回 `{ code: 14001, msg: "分享链接不存在", data: null }`

### Requirement: 分享访问必须记录日志

系统 SHALL 记录每次分享访问的日志，包含 IP、User-Agent、访问结果。

#### Scenario: 记录成功访问
- **WHEN** 分享访问成功
- **THEN** 创建 ShareAccessLog，accessResult = "success"

#### Scenario: 记录失败访问
- **WHEN** 分享访问失败（token 无效、超限等）
- **THEN** 创建 ShareAccessLog，accessResult = "failed"，记录失败原因

#### Scenario: 记录客户端信息
- **WHEN** 记录访问日志
- **THEN** 必须记录 clientIp 和 userAgent

### Requirement: 分享资源访问必须消费 accessCount

系统 SHALL 确保访问分享的 assets / book / preview 都会消费 accessCount。

#### Scenario: 访问分享素材消费 accessCount
- **WHEN** 访问 GET /share/:token/assets/:assetId
- **THEN** share token accessCount 增加 1

#### Scenario: 访问分享书稿消费 accessCount
- **WHEN** 访问 GET /share/:token/books/:bookId
- **THEN** share token accessCount 增加 1

#### Scenario: 访问分享预览消费 accessCount
- **WHEN** 访问 GET /share/:token/preview
- **THEN** share token accessCount 增加 1

### Requirement: 必须有并发测试覆盖

系统 SHALL 编写并发测试，验证 accessCount 原子性。

#### Scenario: 并发访问测试
- **WHEN** maxAccessCount=10，并发 50 次访问
- **THEN** 只有 10 次成功，accessCount 最终为 10

#### Scenario: 并发访问不超限
- **WHEN** maxAccessCount=10，并发 50 次访问
- **THEN** 第 11-50 次访问返回 14004 错误
