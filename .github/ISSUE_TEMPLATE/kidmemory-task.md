---
name: KidMemory task
about: Ready-to-implement product or engineering task for Hermes, Harness, and Codex
title: ""
labels: "status:ready"
assignees: ""
---

# <任务标题>

## 1. 背景

说明为什么要做这件事。

- 当前用户遇到什么问题？
- 现有系统有什么限制？
- 为什么现在要做？

## 2. 用户故事

使用 `US1`、`US2` 编号。

US1. 作为 <用户角色>，我希望 <完成某个动作>，以便 <获得某个价值>。

US2. 当 <某个场景发生> 时，作为 <用户角色>，我希望 <系统行为>，以便 <结果>。

## 3. 目标

本 Issue 要完成：

- 
- 
- 

## 4. 不做什么

本 Issue 明确不处理：

- 
- 
- 

## 5. 产品方案

### 功能入口


### 用户路径


### 正常状态


### 空状态


### 错误状态


### 权限 / 可见性


## 6. 设计图 / 视觉参考

如果涉及 UI、交互、视觉样式、页面布局或组件状态，必须填写本模块。

如果不涉及，写：

```text
不适用
```

### 设计来源

- Figma:
- 截图:
- 文档:
- 其他:

### 设计范围

本 Issue 需要实现的设计范围：

- 

明确不需要实现的设计范围：

- 

### 关键视觉要求

- 布局:
- 文案:
- 颜色:
- 字体:
- 间距:
- 动效:
- 响应式:

### 设计验收方式

- 是否需要截图对比:
- 是否需要浏览器 / 桌面端手动验证:
- 需要覆盖的状态:

## 7. 技术方案

### 现状


### 目标设计


### 数据流 / 调用链

```text
输入 -> 处理 -> 输出
```

### 关键类型 / API

```ts
// 如适用，写关键类型或 API 伪代码。
```

### 错误处理


### 复用与约束

优先复用：

- 

不要重复实现：

- 

## 8. 改动目录结构

预计改动：

```text
packages/.../...
```

预计新增文件：

```text
packages/.../<file>
```

预计修改文件：

```text
packages/.../<file>
```

明确不应改动：

```text
packages/.../...
```

## 9. 依赖关系

前置依赖：

- 无

后续依赖：

- 无

## 10. 验收标准

使用 `AC1`、`AC2` 编号，并尽量关联用户故事。

AC1. 覆盖 US1：当用户 <操作> 时，系统会 <明确结果>。

AC2. 覆盖 US2：当 <空数据/异常/边界场景> 时，系统会 <明确表现>。

AC3. 已有 <相关功能> 行为不受影响。

AC4. 实际改动不超出「改动目录结构」；如必须超出，PR 需要写偏离说明。

AC5. 如涉及设计图，实现结果符合「设计图 / 视觉参考」中列出的范围和关键视觉要求。

## 11. 分支建议

```text
feature/<issue-number>-<slug>
```

示例：

```text
feature/<issue-number>-memory-timeline
fix/<issue-number>-missing-memory-metadata
refactor/<issue-number>-protocol-event-schema
chore/<issue-number>-update-test-fixtures
```

## 必填要求

Hermes 提交 `status:ready` 前，以上 11 个模块都必须填写。

如果某个小节不适用，写：

```text
不适用
```

不要留空。
