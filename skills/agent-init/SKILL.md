---
name: agent-init
description: 为 Claude Code 初始化项目协作骨架。当用户希望创建或补齐 CLAUDE.md 与 .claude，并生成 rules、memory、agents、hooks 配置的起始模板时使用。Codex 仅作为 Claude Code 临时调用的任务执行工具，本 skill 不生成 AGENTS.md、.codex 或 Codex agents。
---

# Agent Init

用于为项目初始化轻量协作骨架。默认只初始化 **Claude Code 主工作流**。

## 调用前环境检查

使用本 skill 的第一步必须检查当前执行环境。

- 当前执行者是 Claude Code：继续执行初始化流程
- 当前执行者不是 Claude Code（例如 Codex、ChatGPT 或其他 agent）：停止执行，不运行脚本，不创建或修改文件，并提示用户：

```text
agent-init 只支持在 Claude Code 中调用。当前执行环境不是 Claude Code，请切换到 Claude Code 后再执行初始化。
```

当前支持：
- `claude-code`：生成 `CLAUDE.md` 与 `.claude/`

执行初始化前，先读取对应参考文件：
- `references/claude-code.md`

## 初始化参数

期望参数：
- `init`
- `agent=claude-code`
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

## Codex 使用边界

Codex 只作为 Claude Code 在具体任务中临时调用的执行工具，不作为项目级协作骨架初始化目标。

- 不生成 `AGENTS.md`
- 不生成 `.codex/`
- 不生成 `.codex/agents`
- 不维护独立 Codex rules/memory
- 需要 Codex 执行时，由 Claude Code 在任务提示中显式传入范围、事实源、验收标准和必要上下文

### Claude Code

- 顶层入口文件：`CLAUDE.md`
- 运行目录：`.claude/`
- 主工作流事实源

## 运行目录结构

### Claude Code 主体结构

```text
.claude/
  rules/
    task-classification.md
    document-lifecycle.md
    memory-write-policy.md
    subagent-routing.md
    review-checklist.md
  memory/
    index.md
    session-brief.md
    project-progress.md
    corrections.md
    observations.md
    learned-rules.md
  agents/
    planner.md
    executor.md
    verifier.md
```

### agents 目录

Claude Code 使用 Markdown 格式，并且每个文件必须包含 YAML frontmatter（至少 `name` 与 `description`），以便 Claude Code 正确识别子代理：

```text
.claude/agents/
  planner.md
  executor.md
  verifier.md
```

### Hook 配置

Claude Code 配置在 `.claude/settings.json`（随仓库提交共享），hook 条目使用 `hooks` 数组结构：

```text
.claude/settings.json
```

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$(git rev-parse --show-toplevel)/.claude/memory/session-brief.md\""
          }
        ]
      }
    ]
  }
}
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

- `references/claude-code.md`
  - Claude Code 的入口文件与运行目录约定
