---
name: agent-init
description: 为 Codex 或 Claude Code 初始化轻量项目协作骨架。当用户希望创建或补齐 AGENTS.md 与 .codex，或创建或补齐 CLAUDE.md 与 .claude，并生成 rules、hooks、memory、agents 的起始模板时使用。支持简单的 init 初始化流程，适用于新项目和已有项目。
---

# Agent Init

用于为项目初始化轻量协作骨架。

当前支持：
- `codex`
- `claude-code`

执行初始化前，先读取对应参考文件：
- `references/codex.md`
- `references/claude-code.md`

## 初始化参数

期望参数：
- `init`
- `agent=<codex|claude-code>`
- `root=<项目根目录>`
- `docs-profile=<none|engineering>`

## 初始化流程

1. 检查项目根目录
2. 选择目标 agent 适配器
3. 检查顶层入口文件是否存在
4. 检查运行目录是否存在
5. 创建缺失的目录与模板文件
6. 对已有文件补齐缺失部分
7. 输出复用项与新增项摘要

当 `docs-profile=engineering` 时，额外初始化：

```text
docs/
  architectures/
  plans/
  tasks/
```

并补齐顶层入口文件中的文档治理规则，但不额外生成目录级 `README.md`。

## Agent 对应关系

### Codex

- 顶层入口文件：`AGENTS.md`
- 运行目录：`.codex/`

### Claude Code

- 顶层入口文件：`CLAUDE.md`
- 运行目录：`.claude/`

## 运行目录结构

### 通用部分

```text
<运行目录>/
  rules/
    task-classification.md
    document-lifecycle.md
    memory-write-policy.md
    subagent-routing.md
    review-checklist.md
  hooks/
    pre-task.md
    post-task.md
    post-failure.md
    pre-commit.md
  memory/
    index.md
    corrections.md
    observations.md
    learned-rules.md
    anti-patterns.md
    evolution-log.md
```

### agents 目录（按工具区分）

Claude Code 使用 Markdown 格式：

```text
.claude/agents/
  planner.md
  executor.md
  verifier.md
```

Codex 使用 TOML 格式：

```text
.codex/agents/
  planner.toml
  executor.toml
  verifier.toml
```

## 内容风格

- 顶层入口文件保持精简
- 执行细则下沉到运行目录
- 规则表达优先使用正向描述
- 优先采用补齐和扩展方式，而不是整体替换
- 工程文档目录只提供最小骨架，不预生成冗长 spec 文档
- 工程文档文件名优先使用稳定英文 slug，不使用年月日前缀
- 文档生命周期规则写入 `rules/document-lifecycle.md`

## Resources

### scripts/

- `scripts/init_agent.py`
  - 根据 `agent` 和 `root` 初始化对应的顶层入口文件与运行目录

### references/

- `references/codex.md`
  - Codex 的入口文件与运行目录约定
- `references/claude-code.md`
  - Claude Code 的入口文件与运行目录约定
