# Codex 适配说明

## 顶层入口文件

- `AGENTS.md`

## 运行目录

- `.codex/`

## 初始化行为

1. 检查 `AGENTS.md` 是否存在
2. 检查 `.codex/` 是否存在
3. 入口文件存在时优先补齐缺失部分
4. 运行目录存在时优先补齐缺失模板
5. 缺失时创建对应文件和目录

## 目标产物

- `AGENTS.md`
- `.codex/rules/task-classification.md`
- `.codex/rules/document-lifecycle.md`
- `.codex/rules/memory-write-policy.md`
- `.codex/rules/subagent-routing.md`
- `.codex/rules/review-checklist.md`
- `.codex/hooks/pre-task.md`
- `.codex/hooks/post-task.md`
- `.codex/hooks/post-failure.md`
- `.codex/hooks/pre-commit.md`
- `.codex/memory/index.md`
- `.codex/memory/corrections.md`
- `.codex/memory/observations.md`
- `.codex/memory/learned-rules.md`
- `.codex/memory/anti-patterns.md`
- `.codex/memory/evolution-log.md`
- `.codex/agents/planner.toml`
- `.codex/agents/executor.toml`
- `.codex/agents/verifier.toml`

当 `docs-profile=engineering` 时，额外创建：

- `docs/architectures/`
- `docs/plans/`
- `docs/tasks/`

## 写入风格

- `AGENTS.md` 保持精简
- 详细执行细则写入 `.codex/`
- 规则优先使用正向表达
- 工程文档目录采用 `architectures / plans / tasks`
- 工程文档文件名优先使用稳定英文 slug，不使用年月日前缀
- Codex 自定义 agent 使用 TOML 格式（`name`、`description`、`developer_instructions` 必填），planner 和 verifier 设置 `sandbox_mode = "read-only"`
