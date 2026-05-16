## ADDED Requirements

### Requirement: 上传 commit 幂等性必须保证

系统 SHALL 确保上传 commit 操作是幂等的，重复 commit 不会导致重复导入或数据污染。

#### Scenario: 首次 commit 触发 pullback
- **WHEN** uploadItem 首次 commit
- **THEN** 状态改为 committed，触发 pullback 任务

#### Scenario: 重复 commit 返回幂等结果
- **WHEN** uploadItem 已 committed，再次 commit
- **THEN** 返回 `{ code: 15005, msg: "上传项已提交", data: { uploadItemId, committedAt } }`

#### Scenario: 并发 commit 只触发一次
- **WHEN** 同一 uploadItem 并发 commit 10 次
- **THEN** 只有 1 次成功，其他 9 次返回幂等结果

### Requirement: pullback 防重复触发必须保证

系统 SHALL 使用状态机确保 pullback 任务不会重复执行。

#### Scenario: pullback 状态机
- **WHEN** pullback 任务创建
- **THEN** 状态为 pending → processing → completed 或 failed

#### Scenario: processing 状态防重复
- **WHEN** pullback 任务状态为 processing
- **THEN** 再次触发返回 `{ code: 15006, msg: "回拉任务正在执行", data: null }`

#### Scenario: completed 状态防重复
- **WHEN** pullback 任务状态为 completed
- **THEN** 再次触发返回 `{ code: 15006, msg: "回拉任务已完成", data: null }`

#### Scenario: 并发 pullback 只执行一次
- **WHEN** 同一 pullback 任务并发触发 10 次
- **THEN** 只有 1 次进入 processing 状态，其他 9 次被阻止

### Requirement: 上传项状态必须正确流转

系统 SHALL 确保 uploadItem 状态按照正确的流程流转：pending → uploaded → committed → ready。

#### Scenario: 创建时状态为 pending
- **WHEN** 创建 uploadItem
- **THEN** 状态为 pending

#### Scenario: 上传完成后状态为 uploaded
- **WHEN** 文件上传到对象存储完成
- **THEN** 状态改为 uploaded

#### Scenario: commit 后状态为 committed
- **WHEN** uploadItem commit 成功
- **THEN** 状态改为 committed，committedAt 记录时间

#### Scenario: pullback 完成后状态为 ready
- **WHEN** pullback 任务完成，asset 创建成功
- **THEN** 状态改为 ready，readyAt 记录时间

### Requirement: 错误状态必须记录详细信息

系统 SHALL 在 uploadItem 或 pullback 失败时记录 errorCode 和 errorMessage。

#### Scenario: 上传失败记录错误
- **WHEN** 文件上传到对象存储失败
- **THEN** 状态改为 failed，errorCode 和 errorMessage 记录失败原因

#### Scenario: pullback 失败记录错误
- **WHEN** pullback 下载文件失败
- **THEN** 状态改为 failed，errorCode 和 errorMessage 记录失败原因

#### Scenario: 错误可重试
- **WHEN** uploadItem 或 pullback 状态为 failed
- **THEN** 可以通过 retry 接口重新触发
