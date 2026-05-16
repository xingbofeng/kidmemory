## ADDED Requirements

### Requirement: sidecar 必须在启动时完成设备注册

系统 SHALL 在 sidecar 启动时向 cloud-api 注册当前设备，获取 deviceToken 用于后续认证。

#### Scenario: 首次注册成功
- **WHEN** sidecar 首次启动，cloud-api 可达
- **THEN** 向 cloud-api `POST /devices/register` 提交设备信息（machineId、hostname、platform）
- **AND** 获取 deviceToken，持久化到本地 config 表
- **AND** sidecar 正常启动，不因注册阻塞本地服务

#### Scenario: cloud-api 不可达时不阻塞启动
- **WHEN** sidecar 启动时 cloud-api 不可达
- **THEN** sidecar 正常启动，进入离线模式，记录 WARN 日志
- **AND** 每 60 秒自动重试注册，直到成功

#### Scenario: 已注册设备重新注册幂等
- **WHEN** sidecar 本地已有 deviceToken，向 cloud-api 重新注册（如重装后）
- **THEN** cloud-api 按 machineId 查找已有设备，返回同一 deviceId 的新 token
- **AND** 不创建重复设备记录

---

### Requirement: sidecar 必须定期发送心跳

系统 SHALL 每 30 秒向 cloud-api 发送心跳，更新设备在线状态。

#### Scenario: 心跳成功
- **WHEN** sidecar 发送心跳，cloud-api 可达
- **THEN** cloud-api 更新 `devices.lastSeenAt`，返回 200

#### Scenario: 心跳失败不影响本地功能
- **WHEN** 心跳请求失败（超时或网络错误）
- **THEN** sidecar 记录 WARN 日志，跳过本次，不累积重试
- **AND** 本地 sidecar 所有功能继续正常工作

---

### Requirement: sidecar 必须轮询并拉取新上传的素材

系统 SHALL 每 30 秒从 cloud-api 拉取分配给当前设备、状态为 `committed`、尚未同步的上传项，下载文件并创建本地 asset。

#### Scenario: 正常拉取新上传项
- **WHEN** cloud-api 存在新的 uploadItem（status=committed，assignedDeviceId=当前设备）
- **THEN** sidecar 下载文件到本地 workspacePath
- **AND** 创建本地 asset 记录（关联 cloudUploadItemId）
- **AND** 向 cloud-api 上报 `PUT /upload-items/:id/sync-status`，status=pulled

#### Scenario: 拉取操作幂等
- **WHEN** sidecar 重启后再次轮询，遇到已处理过的 uploadItem
- **THEN** 按 `cloudUploadItemId` 查本地 asset 表，已存在则跳过
- **AND** 不重复下载，不重复创建 asset

#### Scenario: 文件下载失败
- **WHEN** 下载文件失败（网络超时、存储空间不足等）
- **THEN** 向 cloud-api 上报 status=failed，附带 errorReason
- **AND** 记录 ERROR 日志
- **AND** 不影响同批次其他上传项的处理

#### Scenario: cloud-api 不可达时跳过本轮
- **WHEN** 轮询时 cloud-api 请求失败
- **THEN** 跳过本轮，等待下一个 30 秒周期
- **AND** 本地 sidecar 功能不受影响

---

### Requirement: sidecar 必须轮询并领取 cloud 任务

系统 SHALL 每 30 秒从 cloud-api 拉取分配给当前设备、状态为 `pending` 的云端任务（如书稿生成请求）。

#### Scenario: 正常领取并执行任务
- **WHEN** cloud-api 存在 status=pending 的 cloudJob，assignedDeviceId=当前设备
- **THEN** sidecar 向 cloud-api 上报 status=processing
- **AND** 创建本地 agentJob，关联 cloudJobId
- **AND** 开始执行任务

#### Scenario: 任务完成后上报
- **WHEN** 本地 agentJob 执行完成
- **THEN** 向 cloud-api `PUT /jobs/:id/status` 上报 status=completed，附带产物信息（artifactUrl 等）

#### Scenario: 任务失败后上报
- **WHEN** 本地 agentJob 执行失败
- **THEN** 向 cloud-api 上报 status=failed，附带 errorMessage

#### Scenario: 重复领取同一任务时跳过
- **WHEN** sidecar 轮询时发现 cloudJobId 已有对应本地 agentJob
- **THEN** 跳过，不重复创建本地任务

---

### Requirement: 所有同步操作必须在 cloud-api 不可达时降级

系统 SHALL 确保 sidecar 的所有本地功能（asset 管理、书稿生成、本地查询、配置读写）在 cloud-api 完全不可达时仍正常工作。

#### Scenario: 离线模式下本地功能完整
- **WHEN** cloud-api 持续不可达
- **THEN** Desktop 客户端可正常查看素材、生成书稿、读取配置
- **AND** sidecar 本地 API（/assets、/books、/config）不受影响

#### Scenario: 恢复连接后自动续传
- **WHEN** cloud-api 从不可达恢复为可达
- **THEN** 下一轮轮询（30s 内）自动恢复同步
- **AND** 离线期间积压的 uploadItem 按顺序被处理

---

### Requirement: deviceToken 必须安全存储

系统 SHALL 将 deviceToken 安全持久化到本地，不以明文形式出现在日志或响应体中。

#### Scenario: deviceToken 写入本地 config
- **WHEN** 设备注册成功
- **THEN** deviceToken 写入本地 config 表（加密字段或受限文件权限）

#### Scenario: deviceToken 不出现在日志
- **WHEN** sidecar 打印任何日志（INFO / WARN / ERROR）
- **THEN** 日志中不包含 deviceToken 明文

---

### Requirement: cloud-api 必须提供同步所需的所有 endpoint

系统 SHALL 在 cloud-api 中实现以下 endpoint，供 sidecar 调用。

#### Scenario: 设备注册 endpoint
- **WHEN** `POST /devices/register`，Body: `{ machineId, hostname, platform }`
- **THEN** 返回 `{ code: 0, msg: "success", data: { deviceId, deviceToken } }`

#### Scenario: 心跳 endpoint
- **WHEN** `PUT /devices/:id/heartbeat`，Header: `Authorization: Bearer <deviceToken>`
- **THEN** 返回 `{ code: 0, msg: "success", data: { lastSeenAt } }`

#### Scenario: 查询待同步上传项 endpoint
- **WHEN** `GET /upload-items/pending-sync`，Query: `deviceId`，Header: `Authorization: Bearer <deviceToken>`
- **THEN** 返回 `{ code: 0, msg: "success", data: { items: [{ id, fileUrl, childId, mimeType }] } }`

#### Scenario: 上报同步状态 endpoint
- **WHEN** `PUT /upload-items/:id/sync-status`，Body: `{ status: "pulled" | "failed", errorReason? }`
- **THEN** 返回 `{ code: 0, msg: "success", data: null }`

#### Scenario: 查询待执行任务 endpoint
- **WHEN** `GET /jobs/pending`，Query: `deviceId`，Header: `Authorization: Bearer <deviceToken>`
- **THEN** 返回 `{ code: 0, msg: "success", data: { jobs: [{ id, type, payload }] } }`

#### Scenario: 上报任务状态 endpoint
- **WHEN** `PUT /jobs/:id/status`，Body: `{ status: "processing" | "completed" | "failed", artifactUrl?, errorMessage? }`
- **THEN** 返回 `{ code: 0, msg: "success", data: null }`
