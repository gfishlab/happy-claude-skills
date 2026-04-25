## Agent 工程运行约定

- `.claude/rules`：任务分类、记忆写入、子代理路由、验证清单等执行细则
- `.claude/memory`：会话启动摘要、项目进度快照、纠正记录（含反模式）、阶段观察（含演化记录）、已学规则等工程记忆
- `.claude/agents`：`planner`、`executor`、`verifier` 等子代理职责说明
- `.claude/settings.json`：项目级 Hook 配置（SessionStart 自动加载会话启动摘要等，随仓库提交共享）

## 记忆协作关系

- 项目内部记忆存放在 `.claude/memory`
- 外部记忆插件可用于恢复跨会话动态记忆
- 项目内部记忆负责项目规则、项目边界和项目级纠偏
- 外部恢复记忆负责补充历史工作上下文
- 当前任务优先以本项目入口文件和项目内部记忆作为项目事实来源
- 外部恢复结果适合作为补充上下文，不替代项目内部规则与文档

## 记忆优先级顺序

1. 本 `CLAUDE.md`
2. `.claude/rules`
3. `.claude/memory`
4. 外部记忆插件恢复出的动态上下文

读取记忆时优先先核对项目内部规则和项目内部记忆，再参考外部恢复结果。

## 默认加载顺序

1. 识别任务作用域、影响路径与模块范围
2. 读取本 `CLAUDE.md`
3. 读取 `.claude/memory/session-brief.md` 了解宏观进度与记忆读取策略
4. 按任务类型读取 `.claude/rules`
5. 中等及以上任务、跨模块任务、阶段规划、重大功能收口时，读取 `.claude/memory/project-progress.md` 与相关工程记忆
6. 判断是否启用子代理分工
7. 执行任务
8. 在关键 hook 阶段完成验证、复盘与沉淀
9. 大块功能模块完成、阶段性提交、路线变化或重大验收通过后，主动更新 `.claude/memory/project-progress.md`，并同步更新 `.claude/memory/session-brief.md`
