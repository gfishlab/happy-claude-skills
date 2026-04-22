# Claude Code 适配说明

## 顶层入口文件

- `CLAUDE.md`

## 运行目录

- `.claude/`

## 初始化行为

1. 检查 `CLAUDE.md` 是否存在
2. 检查 `.claude/` 是否存在
3. 入口文件存在时优先补齐缺失部分
4. 运行目录存在时优先补齐缺失模板
5. 缺失时创建对应文件和目录

## 目标产物

- `CLAUDE.md`
- `.claude/rules/task-classification.md`
- `.claude/rules/document-lifecycle.md`
- `.claude/rules/memory-write-policy.md`
- `.claude/rules/subagent-routing.md`
- `.claude/rules/review-checklist.md`
- `.claude/hooks/pre-task.md`
- `.claude/hooks/post-task.md`
- `.claude/hooks/post-failure.md`
- `.claude/hooks/pre-commit.md`
- `.claude/memory/index.md`
- `.claude/memory/corrections.md`
- `.claude/memory/observations.md`
- `.claude/memory/learned-rules.md`
- `.claude/memory/anti-patterns.md`
- `.claude/memory/evolution-log.md`
- `.claude/agents/planner.md`
- `.claude/agents/executor.md`
- `.claude/agents/verifier.md`

当 `docs-profile=engineering` 时，额外创建：

- `docs/architectures/`
- `docs/plans/`
- `docs/tasks/`

## 写入风格

- `CLAUDE.md` 保持精简
- 详细执行细则写入 `.claude/`
- 规则优先使用正向表达
- 工程文档目录采用 `architectures / plans / tasks`
- 工程文档文件名优先使用稳定英文 slug，不使用年月日前缀
