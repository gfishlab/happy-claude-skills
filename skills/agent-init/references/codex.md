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
- `.codex/subagents/planner.md`
- `.codex/subagents/executor.md`
- `.codex/subagents/verifier.md`

## 写入风格

- `AGENTS.md` 保持精简
- 详细执行细则写入 `.codex/`
- 规则优先使用正向表达
