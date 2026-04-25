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
- `.claude/memory/index.md`
- `.claude/memory/session-brief.md`
- `.claude/memory/project-progress.md`
- `.claude/memory/corrections.md`
- `.claude/memory/observations.md`
- `.claude/memory/learned-rules.md`
- `.claude/agents/planner.md`
- `.claude/agents/executor.md`
- `.claude/agents/verifier.md`
- `.claude/settings.json`（项目级 Hook 配置：SessionStart 自动加载 session-brief.md）

## Codex 使用边界

Codex 只作为 Claude Code 在具体任务中临时调用的执行工具，本初始化流程不生成 `AGENTS.md`、`.codex/` 或 Codex agents。

需要 Codex 执行时，由 Claude Code 在任务提示中显式传入：

- 任务边界
- 事实来源
- 相关文件
- 验收标准
- 输出要求

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
- Claude Code 子代理 Markdown 文件必须包含 YAML frontmatter（至少 `name` 与 `description`）
- 新会话默认加载 `session-brief.md`，中等及以上任务再读取 `project-progress.md`
